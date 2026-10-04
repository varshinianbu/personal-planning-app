import os;

test "planner service persists and toggles tasks" {
    state_path: str = os.path.join(os.getcwd(), ".planner_test_state.json");
    os.environ["PLANNER_STATE_PATH"] = state_path;
    reset_planner_store();

    created = add_task(
        title="Review CSE449 notes",
        notes="Summarize lecture 4 before lab",
        due="2026-10-01",
        category="Coursework",
        priority="high",
    );
    assert created["title"] == "Review CSE449 notes";
    assert created["done"] == False;

    tasks = get_tasks();
    assert len(tasks) == 1;
    assert tasks[0]["id"] == created["id"];

    toggled = toggle_task(created["id"]);
    assert toggled["done"] == True;

    summary = get_summary();
    assert summary["total"] == 1;
    assert summary["done"] == 1;
    assert summary["pending"] == 0;

    removed = remove_task(created["id"]);
    assert removed == True;
    assert len(get_tasks()) == 0;

    cleared = clear_completed();
    assert cleared == [];
    reset_planner_store();
}
