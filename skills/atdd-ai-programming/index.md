---
title: ATDD AI Programming Bundle
version: 0.1.0
entries:
- concepts/specification-first-principles.md
- concepts/ai-codegen-reproducibility-problem.md
- concepts/acceptance-tests-as-executable-specs.md
- concepts/four-layer-test-model.md
- concepts/incremental-atdd-loop.md
- concepts/failure-modes.md
- concepts/test-cheating.md
- concepts/experiment-findings.md
---

# ATDD AI Programming

Knowledge bundle extracted from Dave Farley's talk on using acceptance tests as
executable specifications to program AI coding agents. Read this index first,
then load only the concepts you need; [SKILL.md](SKILL.md) names the two every
run loads.

## Map

- [Specification-first principles](concepts/specification-first-principles.md) — why precise description, not code, is the hard part
- [AI codegen reproducibility problem](concepts/ai-codegen-reproducibility-problem.md) — why LLM output is nondeterministic and what to do about it
- [Acceptance tests as executable specs](concepts/acceptance-tests-as-executable-specs.md) — the core idea
- [Four-layer test model](concepts/four-layer-test-model.md) — preferred test layering
- [Incremental ATDD loop](concepts/incremental-atdd-loop.md) — why one test at a time, and the anti-patterns that break it
- [Failure modes](concepts/failure-modes.md) — observed ways this approach breaks
- [Test cheating](concepts/test-cheating.md) — the unsolved guardrail problem
- [Experiment findings](concepts/experiment-findings.md) — Farley's hands-on results with o1

Procedures live in the sibling [SKILL.md](SKILL.md); this bundle holds the
knowledge the procedure depends on.
