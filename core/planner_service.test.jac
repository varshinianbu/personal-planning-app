import datetime;
import os;

test "planner service validates, ranks, and persists tasks" {
    state_path: str = os.path.join(os.getcwd(), ".planner_test_state.json");
    os.environ["PLANNER_STATE_PATH"] = state_path;
    reset_planner_store();

    assert validate_task_input("", "", "medium") == "Title is required.";
    assert validate_task_input("Draft outline", "2026-13-40", "medium") == "Due date must be in YYYY-MM-DD format.";

    today = datetime.datetime.now().date();
    overdue_due = (today - datetime.timedelta(days=1)).strftime("%Y-%m-%d");
    soon_due = (today + datetime.timedelta(days=1)).strftime("%Y-%m-%d");

    urgent = add_task(
        title="Submit report",
        notes="Finish the polished draft",
        due=overdue_due,
        category="Coursework",
        priority="high",
    );
    soon = add_task(
        title="Pack bag",
        notes="Prepare for tomorrow",
        due=soon_due,
        category="Personal",
        priority="low",
    );
    floating = add_task(
        title="Read notes",
        category="Coursework",
        priority="medium",
    );

    assert os.path.exists(state_path);

    tasks = get_tasks();
    assert len(tasks) == 3;
    assert tasks[0]["id"] == urgent["id"];

    recommended = get_recommended_tasks(3);
    assert len(recommended) == 3;
    assert recommended[0]["id"] == urgent["id"];

    next_task = get_next_task();
    assert next_task["id"] == urgent["id"];

    summary = get_summary();
    assert summary["total"] == 3;
    assert summary["done"] == 0;
    assert summary["completed"] == 0;
    assert summary["pending"] == 3;
    assert summary["high"] == 1;
    assert summary["medium"] == 1;
    assert summary["low"] == 1;

    completed = complete_task(urgent["id"]);
    assert completed["done"];

    recommended_after_complete = get_recommended_tasks(3);
    assert len(recommended_after_complete) == 2;
    assert recommended_after_complete[0]["id"] != urgent["id"];

    removed = remove_task(soon["id"]);
    assert removed;

    cleared = clear_completed();
    assert len(cleared) == 1;

    remaining = get_tasks();
    assert len(remaining) == 1;
    assert remaining[0]["id"] == floating["id"];
    assert not remaining[0]["done"];

    reset_planner_store();
}
