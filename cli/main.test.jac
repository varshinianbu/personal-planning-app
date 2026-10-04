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

test "done and remove pass through task ids" {
    done_inv = parse_args(["done", "abc-123"]);
    assert done_inv.command == "done";
    assert done_inv.task_id == "abc-123";

    remove_inv = parse_args(["remove", "xyz-999"]);
    assert remove_inv.command == "remove";
    assert remove_inv.task_id == "xyz-999";
}

test "summary and unknown commands are accepted as plain commands" {
    sum_inv = parse_args(["summary"]);
    assert sum_inv.command == "summary";

    bad_inv = parse_args(["dance"]);
    assert bad_inv.command == "unknown";
}
