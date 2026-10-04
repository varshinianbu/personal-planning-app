import asyncio;
import sys;

import from core.planner_service {
    add_task,
    clear_completed,
    get_summary,
    get_tasks,
    remove_task,
    toggle_task,
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
    if inv.command == "done" or inv.command == "remove" {
        if len(argv) > 1 {
            inv.task_id = argv[1];
        }
        return inv;
    }
    if inv.command == "summary" {
        return inv;
    }
    inv.command = "unknown";
    return inv;
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
        for task in tasks {
            status = "[x]" if task.get("done", False) else "[ ]";
            due = "" if task.get("due", "") == "" else " | due " + str(task.get("due"));
            print(status + " " + task.get("title", "") + " | " + str(task.get("priority", "medium")).upper() + due);
            print("    id: " + str(task.get("id", "")) + " | " + str(task.get("category", "General")));
        }
        return 0;
    }
    if inv.command == "add" {
        if inv.title == "" {
            print("Title required.");
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
    if inv.command == "done" {
        updated_task = toggle_task(inv.task_id);
        if updated_task is None {
            print("Task not found.");
            return 1;
        }
        print("Updated: " + updated_task["title"]);
        return 0;
    }
    if inv.command == "remove" {
        removed = remove_task(inv.task_id);
        if removed {
            print("Removed task " + inv.task_id);
            return 0;
        }
        print("Task not found.");
        return 1;
    }
    if inv.command == "summary" {
        summary = get_summary();
        print("Total: " + str(summary["total"]));
        print("Pending: " + str(summary["pending"]));
        print("Done: " + str(summary["done"]));
        print("High: " + str(summary["high"]));
        return 0;
    }
    print("Unknown command. Try: list, add, done, remove, summary");
    return 1;
}

async def main(argv: list[str]) -> int {
    return await dispatch(parse_args(argv));
}

with entry:__main__ {
    sys.exit(asyncio.run(main(sys.argv[1:])));
}
