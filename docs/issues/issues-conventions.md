---
type: Reference
title: Issue Conventions
description: Numbering, header fields, body sections, and lifecycle rules for project issues.
tags: [issue, conventions, documentation]
timestamp: 2026-08-04T00:00:00Z
---

# Issue Conventions

This document defines the conventions for issues in this project. An
issue tracks a unit of work: a feature, bug, task, or chore. Issues
describe *what* needs to happen; ADRs describe *why* things are the way
they are. When an issue conflicts with an ADR, the ADR wins — fix the
issue, not the ADR.

## Numbering and filenames

- Issues are numbered with **4-digit zero-padded** integers: `0001`,
  `0002`, and so on. Numbers are monotonic and never reused, even if an
  issue is closed as won't-do.
- Filenames follow `NNNN-kebab-case-title.md`, for example
  `0001-config-file-not-reloaded.md`.
- The H1 heading matches the filename title:
  `# ISSUE 0001: Config file not reloaded`.

## Frontmatter (optional)

Issues may begin with a short YAML frontmatter block (`type: Issue`,
`title`, `description`, `tags`, optionally `timestamp`). This is
metadata only — the issue's lifecycle (Status, Closing commits, ...)
always lives in the bold-label header below, never in YAML.

## Header fields

Every issue begins with a markdown bullet list of header fields:

```
- **Type**: feature
- **Status**: open
- **Priority**: high
- **Labels**: [config, cli]
- **Assignee**: none
- **Related**: [ISSUE 0002](0002-title.md), [plan](../plans/2026-08-04-example.md)
- **Related code**: [`cmd/`](../../cmd/)
- **Closing commits**: none
```

- **Type**: `feature`, `bug`, `task`, or `chore`.
- **Status**: `open`, `in-progress`, `blocked`, `done`, or `wont-do`. Do
  not use other words (e.g. `resolved`) for a closed issue — `done` is
  the only closed-and-shipped state.
- **Priority**: `low`, `medium`, `high`, or `critical`.
- **Labels**: short free-form tags; reuse existing labels when possible.
- **Assignee**: person (current repo), or `none`.
- **Related**: other issues, plans, ADRs, or `none`.
- **Related code**: relative markdown links to packages or files touched.
- **Closing commits**: short SHAs when done, or `none` while open.

## Body sections

Every issue has these sections, in order:

1. **Summary** — what and why (one or two sentences).
2. **Details** — enough context to start work without a meeting. Link
   the ADRs, plans, or prior issues that constrain the solution.
3. **Acceptance Criteria** — observable, verifiable checklist. The issue
   is done when every box is checked.
4. **E2E Verification** (mandatory) — an end-to-end check that exercises
   the real behavior (run the command, drive the UI, hit the endpoint),
   plus a live-confirmed run: the command and the observed result. No
   issue moves to `done` on unit tests alone.
5. **Out of Scope** — explicit exclusions, so scope creep is visible.
6. **Notes** (optional) — implementation hints, edge cases, open
   questions while the issue is in flight. Remove the section when empty.
7. **Resolution** (added when moving to `done`) — what actually shipped
   and how it was verified. If the delivered work diverged from the
   written Acceptance Criteria (different scope, different config
   values, a follow-up filed instead), amend the Acceptance Criteria and
   note the drift here — never leave checked-off criteria that no longer
   match the shipped code.

## Lifecycle

- Created as `open`; move to `in-progress` when work starts and set
  **Assignee**.
- Move to `done` only when every acceptance criterion is met (amend the
  criteria first if scope drifted — see **Resolution** above), the
  mandatory **E2E Verification** is live-confirmed, and the change is
  merged. In the same edit that flips the status:
  - check every Acceptance Criteria box,
  - record the merge's short SHAs in **Closing commits**,
  - add a **Resolution** section,
  - link the implementing plan (`docs/plans/`) in **Related** when one
    exists,
  - move the issue to the Done list in `index.md`.
- Move to `wont-do` with a one-line reason in **Notes**.
- Done and won't-do issues stay in the repository. They are the
  project's memory — never delete them, never reuse their numbers.

## Relationship to plans and ADRs

- **Plans** (`docs/plans/`, see `plans/plans-conventions.md`) describe
  *how* to implement an issue — task-by-task, TDD checkboxes. Link the
  plan from the issue's **Related** field once one exists; persist the
  plan under `docs/plans/` (not only editor-local plan files)
  proactively when implementing a tracked issue.
- **ADRs** (`docs/adr/`) record architectural decisions. An issue never
  changes an architectural decision: if the work requires revisiting a
  decision, a new or superseding ADR lands before (or with) the closing
  commit.
