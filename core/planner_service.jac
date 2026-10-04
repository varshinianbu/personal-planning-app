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

def _today() -> datetime.date {
    return datetime.datetime.now().date();
}

def _clean_text(value: str, fallback: str = "") -> str {
    cleaned = (value or "").strip();
    if cleaned == "" {
        return fallback;
    }
    return cleaned;
}

def _normalize_priority(priority: str) -> str {
    cleaned = _clean_text(priority, "medium").lower();
    if cleaned == "high" {
        return "high";
    }
    if cleaned == "low" {
        return "low";
    }
    return "medium";
}

def _normalize_category(category: str) -> str {
    cleaned = _clean_text(category, "General");
    if cleaned == "" {
        return "General";
    }
    return cleaned;
}

def _normalize_due(due: str) -> str {
    cleaned = _clean_text(due, "");
    if cleaned == "" {
        return "";
    }
    try {
        datetime.datetime.strptime(cleaned, "%Y-%m-%d");
        return cleaned;
    } except Exception {
        return "";
    }
}

def _normalize_task(task: dict[str, any]) -> dict[str, any] {
    done = bool(task.get("done", task.get("completed", False)));
    created_at = _clean_text(task.get("created_at", ""), "");
    normalized = {
        "id": _clean_text(task.get("id", ""), str(uuid.uuid4())),
        "title": _clean_text(task.get("title", ""), "Untitled task"),
        "notes": _clean_text(task.get("notes", ""), ""),
        "due": _normalize_due(str(task.get("due", ""))),
        "category": _normalize_category(str(task.get("category", "General"))),
        "priority": _normalize_priority(str(task.get("priority", "medium"))),
        "done": done,
        "completed": done,
        "created_at": created_at,
    };
    return normalized;
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
    if not isinstance(data, list) {
        return [];
    }
    normalized_tasks = [];
    changed = False;
    for task in data {
        normalized_task = _normalize_task(task);
        if normalized_task != task {
            changed = True;
        }
        normalized_tasks.append(normalized_task);
    }
    if changed {
        _write_store(normalized_tasks);
    }
    return normalized_tasks;
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

def _priority_weight(priority: str) -> int {
    cleaned = _normalize_priority(priority);
    if cleaned == "high" {
        return 30;
    }
    if cleaned == "low" {
        return 10;
    }
    return 20;
}

def _due_weight(task: dict[str, any]) -> int {
    due_text = _normalize_due(str(task.get("due", "")));
    if due_text == "" {
        return 0;
    }
    try {
        due_date = datetime.datetime.strptime(due_text, "%Y-%m-%d").date();
    } except Exception {
        return 0;
    }
    days_until = (due_date - _today()).days;
    if days_until < 0 {
        return 60 + (abs(days_until) * 10);
    }
    if days_until == 0 {
        return 45;
    }
    if days_until == 1 {
        return 35;
    }
    if days_until <= 3 {
        return 25;
    }
    if days_until <= 7 {
        return 10;
    }
    return 0;
}

def _focus_sort_key(task: dict[str, any]) -> tuple[int, str, str, str] {
    return (
        -calculate_focus_score(task),
        str(task.get("due", "")),
        str(task.get("created_at", "")),
        str(task.get("title", "")),
    );
}

def _task_sort_key(task: dict[str, any]) -> tuple[int, int, str, str, str] {
    return (
        0 if not task.get("done", False) else 1,
        -calculate_focus_score(task),
        str(task.get("due", "")),
        str(task.get("created_at", "")),
        str(task.get("title", "")),
    );
}

def _set_task_completion(task_id: str, completed: bool) -> dict[str, any] | None {
    tasks = _read_store();
    updated = None;
    changed_tasks = [];
    for task in tasks {
        if task.get("id") == task_id {
            task["done"] = completed;
            task["completed"] = completed;
            updated = task;
        }
        changed_tasks.append(task);
    }
    if updated is not None {
        _write_store(changed_tasks);
    }
    return updated;
}

def:pub reset_planner_store() -> list[dict[str, any]] {
    _write_store([]);
    return [];
}

def:pub validate_task_input(title: str, due: str = "", priority: str = "medium") -> str | None {
    if _clean_text(title, "") == "" {
        return "Title is required.";
    }
    if _clean_text(due, "") != "" and _normalize_due(due) == "" {
        return "Due date must be in YYYY-MM-DD format.";
    }
    normalized_priority = _normalize_priority(priority);
    if _clean_text(priority, "medium") != "" and normalized_priority not in ["low", "medium", "high"] {
        return "Priority must be low, medium, or high.";
    }
    return None;
}

def:pub calculate_focus_score(task: dict[str, any]) -> int {
    normalized = _normalize_task(task);
    if normalized["done"] {
        return -1000;
    }
    return _priority_weight(normalized["priority"]) + _due_weight(normalized);
}

def:pub get_task(task_id: str) -> dict[str, any] | None {
    for task in _read_store() {
        if task.get("id") == task_id {
            return task;
        }
    }
    return None;
}

def:pub get_tasks() -> list[dict[str, any]] {
    tasks = _read_store();
    return sorted(tasks, key=_task_sort_key);
}

def:pub get_active_tasks() -> list[dict[str, any]] {
    return [task for task in get_tasks() if not task.get("done", False)];
}

def:pub get_completed_tasks() -> list[dict[str, any]] {
    return [task for task in get_tasks() if task.get("done", False)];
}

def:pub get_recommended_tasks(limit: int = 3) -> list[dict[str, any]] {
    if limit <= 0 {
        return [];
    }
    ranked = sorted(get_active_tasks(), key=_focus_sort_key);
    return ranked[:limit];
}

def:pub get_next_task() -> dict[str, any] | None {
    recommended = get_recommended_tasks(1);
    if len(recommended) == 0 {
        return None;
    }
    return recommended[0];
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
        p = _normalize_priority(str(task.get("priority", "medium")));
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
        "completed": done,
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
    cleaned_title = _clean_text(title, "");
    if cleaned_title == "" {
        cleaned_title = "Untitled task";
    }
    normalized_due = _normalize_due(due);
    task = {
        "id": str(uuid.uuid4()),
        "title": cleaned_title,
        "notes": _clean_text(notes, ""),
        "due": normalized_due,
        "category": _normalize_category(category),
        "priority": _normalize_priority(priority),
        "done": False,
        "completed": False,
        "created_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M"),
    };
    tasks = _read_store();
    tasks.append(task);
    _write_store(tasks);
    return task;
}

def:pub complete_task(task_id: str) -> dict[str, any] | None {
    return _set_task_completion(task_id, True);
}

def:pub reopen_task(task_id: str) -> dict[str, any] | None {
    return _set_task_completion(task_id, False);
}

def:pub toggle_task(task_id: str) -> dict[str, any] | None {
    task = get_task(task_id);
    if task is None {
        return None;
    }
    return _set_task_completion(task_id, not bool(task.get("done", False)));
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
