---
type: concept
title: Failure modes
description: Observed ways AI-driven ATDD breaks in practice, from Farley's experiment.
tags: [ai, risks, experiment]
---
# Failure modes

Observed during the hands-on experiment with OpenAI models (o1, and 4o before
it, building a Flask REST application):

- **Test/application mismatch.** The AI generated a REST web application but
  produced test infrastructure for a web-UI application. They were incompatible
  and had to be reconciled by prompting and editing. Always pin the
  architecture in the spec.
- **Non-working code that is close enough.** Too often the AI produced code
  that did not run at all, yet was near enough to the goal that correcting it
  beat rewriting — which drifts into legacy-code tinkering.
- **Speed illusion.** Despite impressive moments, total time spent (fiddling
  with prompts + fixing output) exceeded what an experienced programmer needed
  to write the same application from scratch. The approach is viable but not
  yet faster for an expert.
- **Heavy handholding.** Current models needed continuous coaching from an
  experienced programmer to stay on the right path. Without that guidance,
  reliability drops.
- **Skipped isolation.** The experiment omitted functional and temporal test
  isolation for speed, leaving tests more fragile than production-grade suites
  should be.

Net assessment: the target — AI generating both test infrastructure and
implementation from an executable specification — was achieved at some level,
and is a viable strategy for raising abstraction, but requires refinement of
prompts and technique.
