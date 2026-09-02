---
name: atdd-ai-programming
description: >
  Program AI coding agents by writing acceptance tests as executable specifications
  instead of prompting for code. Use when implementing a feature, endpoint, or
  application with an LLM assistant, when requirements are ambiguous, when
  AI-generated code must be verified against behavior, or when the user asks for
  ATDD/TDD-style collaboration with an AI.
---

# ATDD AI Programming

Treat acceptance tests as the program. AI writes implementation to make tests
pass. You (the agent) never invent behavior not pinned by a test.

## Workflow

1. Load context. Read index.md, then
   concepts/acceptance-tests-as-executable-specs.md and
   concepts/ai-codegen-reproducibility-problem.md.
2. Elicit the spec. Ask the user for concrete scenarios: given/when/then from the
   user's perspective. Ambiguity in the spec -> ambiguity in the output. Resolve
   it before writing anything. See concepts/specification-first-principles.md.
3. Write ONE test first. Get the test harness structure in place for that single
   test: a runner that actually executes it — confirm the first run fails for
   the right reason (missing implementation), because zero tests executed also
   exits 0. A framework is optional. See concepts/four-layer-test-model.md for
   layering.
4. Generate the minimal implementation that makes that test pass.
5. Add the next test. Re-run all tests. Extend implementation only as far as the
   tests demand.
6. Shape tests, not code. If the implementation is wrong, fix the prompt or the
   test — do not hand-edit generated application code outside prompting. Only
   exception: environment/config fixes, never logic. Tests are human-owned;
   implementation is AI-owned.
7. Keep test infrastructure consistent with application architecture (REST API
   tests for a REST API, not UI tests). See
   concepts/failure-modes.md.
8. Never weaken, skip, or special-case a test to make it pass. Report cheating
   temptations instead. See concepts/test-cheating.md.

## Rules

- Prompt = program; you are the compiler. Precision in, precision out.
- Tests must be deterministic and isolated (functional + temporal isolation)
  so they are reproducible across model versions and runs.
- One behavioral increment per cycle: test -> fail -> implement -> pass.
- If a scenario cannot be expressed as a test, the spec is not ready.
