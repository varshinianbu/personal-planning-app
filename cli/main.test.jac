test "default command is list" {
    inv = parse_args([]);
    assert inv.command == "list";
    assert not inv.all;
}

test "list accepts --all" {
    inv = parse_args(["list", "--all"]);
    assert inv.command == "list";
    assert inv.all;
}

test "add command parses task metadata" {
    inv = parse_args([
        "add",
        "Ship planner",
        "--notes",
        "Finish the web screen",
        "--due",
        "2026-09-30",
        "--category",
        "Work",
        "--priority",
        "high",
    ]);
    assert inv.command == "add";
    assert inv.title == "Ship planner";
    assert inv.notes == "Finish the web screen";
    assert inv.due == "2026-09-30";
    assert inv.category == "Work";
    assert inv.priority == "high";
}

test "complete, delete, done, and remove pass through task ids" {
    complete_inv = parse_args(["complete", "abc-123"]);
    assert complete_inv.command == "complete";
    assert complete_inv.task_id == "abc-123";

    delete_inv = parse_args(["delete", "xyz-999"]);
    assert delete_inv.command == "delete";
    assert delete_inv.task_id == "xyz-999";

    done_inv = parse_args(["done", "abc-123"]);
    assert done_inv.command == "done";
    assert done_inv.task_id == "abc-123";

    remove_inv = parse_args(["remove", "xyz-999"]);
    assert remove_inv.command == "remove";
    assert remove_inv.task_id == "xyz-999";
}

test "today stats summary and unknown commands are accepted as plain commands" {
    today_inv = parse_args(["today"]);
    assert today_inv.command == "today";

    stats_inv = parse_args(["stats"]);
    assert stats_inv.command == "stats";

    sum_inv = parse_args(["summary"]);
    assert sum_inv.command == "summary";

    bad_inv = parse_args(["dance"]);
    assert bad_inv.command == "unknown";
}
