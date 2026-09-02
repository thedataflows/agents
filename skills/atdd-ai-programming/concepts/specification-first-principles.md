---
type: concept
title: Specification-first principles
description: Why the hard part of software development is precise description of intent, not writing code.
tags: [programming, specification, foundations]
---
# Specification-first principles

Programming languages exist as tools to help humans think at the right level of
detail. A program is a specification of what we want the system to achieve; the
steps are just the means. Natural language is too ambiguous for this job, which
is why languages evolved to be clear, expressive, and precise.

The common mistake (technical people included) is assuming the hard part is
writing code. Reality: the hard part is producing a sufficiently detailed,
accurate description of what we want so a computer can achieve it.

Programming reduces to three activities:

1. Understanding the problem well enough to explain it clearly
2. Translating that explanation into something executable
3. Verifying the result actually solves the original problem

These survive unchanged when AI writes the code. What changes is the mechanism
of step 2: instead of coding line by line, the developer collaborates with an
AI, and the hardest, most creative work — unambiguous problem definition —
stays with the human.

A prompt to an LLM is itself a program, and the AI acts as an advanced compiler
from that specification to executable code. Woolly, verbose, imprecise prompts
compile to woolly, imprecise software. See
[acceptance tests as executable specs](acceptance-tests-as-executable-specs.md).
