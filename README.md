# PlanPilot

PlanPilot is a personal planning app built in Jac. It keeps a shared task list that persists on disk, offers a browser dashboard for planning, includes a mobile-friendly quick view, and exposes a terminal interface for fast updates.

## Author

Vijayavarshini Anbu
UMID: 94826214

## Features

- Shared task storage with persistent JSON-backed data in the workspace
- Web planner dashboard for creating, editing, and clearing tasks
- Mobile quick view for on-the-go task completion
- CLI actions for listing, adding, completing, and deleting tasks
- Priorities, categories, due dates, and completion tracking

## Run the app

From the project root:

```bash
jac install
jac run
```

This starts the web app at the default app route for the project.

## Mobile app

```bash
jac run mobile
```

This starts the mobile planner view in the same workspace, using the same shared task backend.

## CLI

```bash
jac run cli -- list
jac run cli -- add "Finish project plan" --notes "Review the prototype" --due 2026-10-02 --category Coursework --priority high
jac run cli -- summary
jac run cli -- done <task-id>
jac run cli -- remove <task-id>
```

## Architecture

The four app surfaces all share a single backend module in `core/planner_service.jac`:

- Web app: planning dashboard and detailed task creation UI
- Mobile app: compact quick-task interface for daily triage
- CLI: terminal actions for quick updates from the shell
- Server/storage layer: JSON-backed planner data that persists between sessions in `.planner_state.json`

This keeps the same planning data synchronized across the different interfaces without duplicating logic.

## Storage

Planner data is stored in a local JSON file at the project root. If the environment variable `PLANNER_STATE_PATH` is set, that path is used instead.

## Notes

The app is built as a personal workflow for keeping coursework, errands, and personal goals in one place. It is intentionally compact, but the shared backend makes it easy to extend with recurring tasks, calendar views, or AI suggestions later.
