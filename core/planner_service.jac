import json;
import os;
import uuid;
import datetime;

glob STORAGE_FILE: str = ".planner_state.json";

def planner_state_path() -> str {
    env_path = os.environ.get("PLANNER_STATE_PATH");
    if env_path and env_path.strip() != "" {
        return env_path;
    }
    return os.path.join(os.getcwd(), STORAGE_FILE);
}

def _read_store() -> list[dict[str, any]] {
    path = planner_state_path();
    if not os.path.exists(path) {
        return [];
    }
    try {
        with open(path, "r", encoding="utf-8") as handle {
            data = json.load(handle);
        }
    } except Exception {
        return [];
    }
    if isinstance(data, list) {
        return data;
    }
    return [];
}

def _write_store(tasks: list[dict[str, any]]) {
    path = planner_state_path();
    folder = os.path.dirname(path);
    if folder and not os.path.exists(folder) {
        os.makedirs(folder, exist_ok=True);
    }
    with open(path, "w", encoding="utf-8") as handle {
        json.dump(tasks, handle, indent=2);
    }
}

def _priority_rank(priority: str) -> int {
    p = (priority or "medium").lower();
    if p == "high" {
        return 0;
    }
    if p == "medium" {
        return 1;
    }
    return 2;
}

def _sort_key(task: dict[str, any]) -> tuple[int, int, str, str] {
    return (
        0 if task.get("done", False) else 1,
        _priority_rank(task.get("priority", "medium")),
        str(task.get("due", "")),
        str(task.get("created_at", "")),
    );
}

def:pub reset_planner_store() -> list[dict[str, any]] {
    _write_store([]);
    return [];
}

def:pub get_tasks() -> list[dict[str, any]] {
    tasks = _read_store();
    return sorted(tasks, key=_sort_key);
}

def:pub get_summary() -> dict[str, any] {
    tasks = get_tasks();
    total = len(tasks);
    done = 0;
    pending = 0;
    high = 0;
    medium = 0;
    low = 0;
    for task in tasks {
        if task.get("done", False) {
            done = done + 1;
        } else {
            pending = pending + 1;
        }
        p = (task.get("priority", "medium") or "medium").lower();
        if p == "high" {
            high = high + 1;
        } elif p == "medium" {
            medium = medium + 1;
        } else {
            low = low + 1;
        }
    }
    return {
        "total": total,
        "done": done,
        "pending": pending,
        "high": high,
        "medium": medium,
        "low": low,
    };
}

def:pub add_task(
    title: str,
    notes: str = "",
    due: str = "",
    category: str = "General",
    priority: str = "medium",
) -> dict[str, any] {
    cleaned_title = (title or "Untitled task").strip();
    if cleaned_title == "" {
        cleaned_title = "Untitled task";
    }
    task = {
        "id": str(uuid.uuid4()),
        "title": cleaned_title,
        "notes": notes or "",
        "due": due or "",
        "category": category or "General",
        "priority": (priority or "medium").lower(),
        "done": False,
        "created_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M"),
    };
    tasks = _read_store();
    tasks.append(task);
    _write_store(tasks);
    return task;
}

def:pub toggle_task(task_id: str) -> dict[str, any] | None {
    tasks = _read_store();
    updated = None;
    changed = [];
    for task in tasks {
        if task.get("id") == task_id {
            task["done"] = not bool(task.get("done", False));
            updated = task;
        }
        changed.append(task);
    }
    if updated is not None {
        _write_store(changed);
    }
    return updated;
}

def:pub remove_task(task_id: str) -> bool {
    tasks = _read_store();
    original_count = len(tasks);
    remaining = [task for task in tasks if task.get("id") != task_id];
    if len(remaining) != original_count {
        _write_store(remaining);
        return True;
    }
    return False;
}

def:pub clear_completed() -> list[dict[str, any]] {
    remaining = [task for task in _read_store() if not task.get("done", False)];
    _write_store(remaining);
    return get_tasks();
}
