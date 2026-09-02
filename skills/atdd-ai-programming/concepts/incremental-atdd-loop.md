---
type: concept
title: Incremental ATDD loop
description: Why the loop is one test at a time, and the anti-patterns that break it.
tags: [atdd, workflow]
---
# Incremental ATDD loop

The step-by-step procedure lives in the [SKILL.md](../SKILL.md) workflow. This
note holds the rationale behind it and the ways teams slide out of it.

**Resist the rush.** AI assistants eagerly generate the whole application,
tests and all, in one shot. Do not accept that. The goal is to *program the AI
with acceptance tests*, not have it freestyle. One behavioral increment per
cycle is what keeps the human in control of the specification — the AI may
draft tests, but humans own and rework them.

Anti-patterns: accepting bulk generation, hand-editing implementation while
leaving tests untouched, and letting the AI invent behavior no test specifies.
The ownership boundary — human shapes tests; AI generates all application
code, changed by prompting, with environment/config fixes as the only
hand-edit — is stated in [SKILL.md](../SKILL.md).
