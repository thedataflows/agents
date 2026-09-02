---
type: concept
title: Acceptance tests as executable specifications
description: The core idea - write tests that specify user-visible behavior, let AI generate all implementation code to satisfy them.
tags: [atdd, acceptance-testing, core-idea]
---
# Acceptance tests as executable specifications

Automated acceptance tests written as executable specifications describe, from a
user's perspective, exactly how a system should behave in each scenario. At the
right level of abstraction they are clear, easy to write, precise, and
reproducible — which makes them the right tool to solve both the specification
and verification problems of AI code generation.

The shift: instead of writing code, write detailed specifications. Each one
tells the AI what the system must do in a specific scenario. The AI generates
the implementation *and* the low-level test infrastructure needed to verify the
specification. Code is then written more easily (accurate spec of intent) and
verified by running the tests.

This is not just testing — it is programming at a higher level of abstraction.
The developer's job moves from writing solutions to specifying behavior. The
analogy is the leap from assembly to high-level languages: focus on what you
want from the system, not the mechanics of achieving it.

Why this succeeds where earlier abstraction-raising attempts (model-driven
development, low-code platforms) failed: those work only for narrowly
constrained problems and leave maintainability, flexibility, and
reproducibility unresolved. Acceptance testing already works extremely well for
human programmers and integrates seamlessly into modern development workflows —
CI/CD included. See the procedure in
[the incremental ATDD loop](incremental-atdd-loop.md).
