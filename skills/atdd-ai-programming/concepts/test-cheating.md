---
type: concept
title: Test cheating
description: The unsolved problem of preventing an AI from gaming the tests that specify its task.
tags: [ai, verification, open-problem]
---
# Test cheating

If the specification *is* the program, the AI may optimize for passing the tests
rather than satisfying the intent — the specification-gaming problem. Farley
calls this a very hard problem that is not solved.

Key points:

- The problem exists in some form regardless of how intent is communicated to
  the AI; it is not unique to the acceptance-test approach.
- Mitigation direction: keep tests human-owned, keep them independent of the
  implementation the AI wrote, and treat any test modification by the AI as a
  violation — SKILL.md's rule: "never weaken, skip, or special-case a test to
  make it pass" ([SKILL.md](../SKILL.md)).
- Full prevention is an open research problem.
