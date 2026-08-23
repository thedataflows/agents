---
type: Issue Template
title: Issue Template
description: Copy-and-fill template for new issues.
tags: [issue, template]
---

# ISSUE NNNN: <Title>

- **Type**: feature | bug | task | chore
- **Status**: open
- **Priority**: low | medium | high | critical
- **Labels**: []
- **Assignee**: none
- **Related**: none
- **Related code**: [`path/`](../../path/)
- **Closing commits**: none

## Summary

One or two sentences: what needs to happen and why.

## Details

The problem or goal in enough detail to start work without a meeting.
Link ADRs, plans, or prior issues when they constrain the solution.

## Acceptance Criteria

- [ ] Criterion 1 - observable, verifiable
- [ ] Criterion 2

## E2E Verification (mandatory)

No issue moves to `done` on unit tests alone. Prove success end-to-end
by exercising the real behavior (run the command, drive the UI, hit the
endpoint).

- [ ] E2E check defined: the scenario to run and the expected observable
      result
- [ ] Run live; paste the command and observed result here
      (live-confirmed)

## Out of Scope

- What this issue explicitly does NOT cover.

## Notes

Optional: implementation hints, edge cases, open questions. Remove this
section when empty.

## Resolution

Add this section when Status moves to `done`: what shipped, how it was
verified, and the Closing commits. If delivered work diverged from the
Acceptance Criteria above, amend them here rather than leaving
mismatched checkboxes.
