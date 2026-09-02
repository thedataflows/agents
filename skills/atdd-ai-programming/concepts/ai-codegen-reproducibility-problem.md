---
type: concept
title: AI codegen reproducibility problem
description: Why AI-generated code is nondeterministic and why verification must be external to the generation process.
tags: [ai, reproducibility, risk]
---
# AI codegen reproducibility problem

Traditional programming is deterministic: same code compiled twice yields the
same program. A compiler is a program too, so it obeys the same rule.

AI code generation breaks this. Output varies with:

- Sampling randomness / temperature settings
- Model version or provider updates
- Prompt phrasing drift

This raises two questions the workflow must answer:

1. **Specification** — how to state what we want with enough clarity and detail
   that the AI gets it right the first time.
2. **Verification** — how to confirm the code works, and keeps working after
   changes to the AI, the model, or the requirements.

The answer to both is the same artifact: an executable acceptance test suite
that is independent of the implementation. Even if the AI rewrites the
underlying implementation, the tests verify that the second version behaves
identically to the first. See
[acceptance tests as executable specs](acceptance-tests-as-executable-specs.md).
