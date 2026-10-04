# PlanPilot

## Author

<<<<<<< HEAD
Vijayavarshini Anbu
UMID: 94826214
=======
Name: Varshini Anbu
UMID: TODO
>>>>>>> 391d6d0 (Finalize PlanPilot submission)

## Description

PlanPilot is a personal planning application built in Jac with a shared backend, a polished web planner, a mobile task workflow, a CLI, persistent planning data, and deterministic smart prioritization.

## Main Features

- Create tasks with a title, due date, category, notes, and priority
- Mark tasks complete from the web, mobile app, or CLI
- Persist planner data between sessions in a local JSON store
- Show dashboard counts for total, pending, high-priority, and completed tasks
- Surface a recommended next task using a deterministic focus score
- Keep web, mobile, and CLI views in sync through shared planning logic

## Project Structure

- `core/` contains the shared planner service, persistence helpers, date handling, and task ranking logic
- `web/` contains the browser planner experience and route pages
- `mobile/` contains the focused mobile task workflow
- `cli/` contains the terminal interface for listing, adding, completing, and reviewing tasks
- `jac.toml` defines the Jac apps, entry points, and workspace configuration

## Prerequisites

- Jac `==0.37.23`
- The workspace dependencies declared in `jac.toml`

## Running the Main Application

From the repository root:

```bash
jac run
```

This launches the default web app for the project.

## Using the Web App

```bash
jac run
```

Open the running app in the browser shown by Jac. The web planner supports task creation, completion, deletion, clearing completed tasks, and the recommended-next view.

## Using the Mobile App

```bash
jac run --dev mobile
```

Use a Jac-supported mobile/web preview environment. The mobile view focuses on active tasks, quick add, and completion actions.

## Using the CLI

```bash
jac run cli -- list
jac run cli -- today
jac run cli -- add "Finish EECS 449 project" --priority high --due 2026-10-05
jac run cli -- complete <task-id>
jac run cli -- stats
```

The CLI uses the same shared planner store as the web and mobile views.

## How the Components Work Together

All four interfaces consume the shared task service in `core/planner_service.jac`. That module owns the canonical task shape, persistence, summary counts, completion updates, and recommendation scoring, so actions from one interface are visible in the others.

## Smart Prioritization

PlanPilot calculates a deterministic focus score from task priority, due date urgency, and overdue status. Completed tasks are excluded from recommendations, and the highest-scoring active task becomes the next recommended item.

## What Makes PlanPilot Stand Out

- Cohesive cross-platform planning with one shared source of truth
- Persistent task storage without an external database
- Polished paper-planner web design preserved from the current implementation
- Purpose-built mobile workflow for quick task triage
- Useful CLI commands for day-to-day planning
- Deterministic recommendations instead of opaque AI scoring

## Screenshots

### Web
[Add screenshot here]

### Mobile
[Add screenshot here]
