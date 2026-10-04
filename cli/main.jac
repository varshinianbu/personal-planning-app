import asyncio;
import sys;

import from core.planner_service {
    add_task,
    calculate_focus_score,
    clear_completed,
    complete_task,
    get_next_task,
    get_summary,
    get_task,
    get_tasks,
    get_recommended_tasks,
    remove_task,
    validate_task_input,
}

glob PROG: str = "planner";

obj Invocation {
    has command: str = "",
        title: str = "",
        notes: str = "",
        due: str = "",
        category: str = "General",
        priority: str = "medium",
        task_id: str = "",
        all: bool = False;
}

def parse_args(argv: list[str]) -> Invocation {
    inv = Invocation();
    if len(argv) == 0 {
        inv.command = "list";
        return inv;
    }

    inv.command = argv[0];
    if inv.command == "list" {
        inv.all = len(argv) > 1 and argv[1] == "--all";
        return inv;
    }
    if inv.command == "add" {
        if len(argv) > 1 {
            inv.title = argv[1];
        }
        idx = 2;
        while idx < len(argv) {
            if argv[idx] == "--notes" and idx + 1 < len(argv) {
                inv.notes = argv[idx + 1];
                idx = idx + 2;
            } elif argv[idx] == "--due" and idx + 1 < len(argv) {
                inv.due = argv[idx + 1];
                idx = idx + 2;
            } elif argv[idx] == "--category" and idx + 1 < len(argv) {
                inv.category = argv[idx + 1];
                idx = idx + 2;
            } elif argv[idx] == "--priority" and idx + 1 < len(argv) {
                inv.priority = argv[idx + 1];
                idx = idx + 2;
            } else {
                idx = idx + 1;
            }
        }
        return inv;
    }
    if inv.command == "done" or inv.command == "complete" or inv.command == "remove" or inv.command == "delete" {
        if len(argv) > 1 {
            inv.task_id = argv[1];
        }
        return inv;
    }
    if inv.command == "summary" or inv.command == "stats" or inv.command == "today" {
        return inv;
    }
    inv.command = "unknown";
    return inv;
}

def _priority_label(priority: str) -> str {
    cleaned = (priority or "medium").lower();
    if cleaned == "high" {
        return "High priority";
    }
    if cleaned == "low" {
        return "Low priority";
    }
    return "Medium priority";
}

def _due_label(due: str) -> str {
    if due == "" {
        return "No due date";
    }
    return "Due " + due;
}

def _print_task(task: dict[str, any], prefix: str = "") {
    status = "[x]" if task.get("done", False) else "[ ]";
    due = _due_label(str(task.get("due", "")));
    priority = _priority_label(str(task.get("priority", "medium")));
    print(prefix + status + " " + str(task.get("title", "")));
    print("    " + priority + " • " + due + " • id " + str(task.get("id", "")));
}

async def dispatch(inv: Invocation) -> int {
    if inv.command == "list" {
        tasks = get_tasks();
        if not inv.all {
            tasks = [task for task in tasks if not task.get("done", False)];
        }
        if not tasks {
            print("No tasks yet.");
            return 0;
        }
        print("PlanPilot — Tasks");
        for task in tasks {
            _print_task(task);
            print("    Category: " + str(task.get("category", "General")) + " • Focus " + str(calculate_focus_score(task)));
        }
        return 0;
    }
    if inv.command == "add" {
        validation_error = validate_task_input(inv.title, inv.due, inv.priority);
        if validation_error is not None {
            print(validation_error);
            return 1;
        }
        task = add_task(
            title=inv.title,
            notes=inv.notes,
            due=inv.due,
            category=inv.category,
            priority=inv.priority,
        );
        print("Added: " + task["title"] + " (" + task["id"] + ")");
        return 0;
    }
    if inv.command == "done" or inv.command == "complete" {
        current_task = get_task(inv.task_id);
        if current_task is None {
            print("Task not found.");
            return 1;
        }
        if current_task.get("done", False) {
            print("Task already completed.");
            return 0;
        }
        updated_task = complete_task(inv.task_id);
        if updated_task is None {
            print("Task not found.");
            return 1;
        }
        print("Completed: " + updated_task["title"]);
        return 0;
    }
    if inv.command == "remove" or inv.command == "delete" {
        removed = remove_task(inv.task_id);
        if removed {
            print("Removed task " + inv.task_id);
            return 0;
        }
        print("Task not found.");
        return 1;
    }
    if inv.command == "today" {
        next_task = get_next_task();
        today_tasks = get_recommended_tasks(5);
        print("PlanPilot — Today");
        if len(today_tasks) == 0 {
            print("No active tasks yet.");
            return 0;
        }
        index = 1;
        for task in today_tasks {
            print("[" + str(index) + "] " + str(task.get("title", "")));
            print("    " + _priority_label(str(task.get("priority", "medium"))) + " • " + _due_label(str(task.get("due", ""))) + " • Focus " + str(calculate_focus_score(task)));
            index = index + 1;
        }
        if next_task is not None {
            print("Recommended next: " + str(next_task["title"]));
        }
        return 0;
    }
    if inv.command == "summary" or inv.command == "stats" {
        summary = get_summary();
        print("PlanPilot — Summary");
        print("Total: " + str(summary["total"]));
        print("Pending: " + str(summary["pending"]));
        print("Completed: " + str(summary["done"]));
        print("High priority: " + str(summary["high"]));
        return 0;
    }
    print("Unknown command. Try: list, today, add, complete, remove, stats");
    return 1;
}

async def main(argv: list[str]) -> int {
    return await dispatch(parse_args(argv));
}

with entry:__main__ {
    sys.exit(asyncio.run(main(sys.argv[1:])));
}
