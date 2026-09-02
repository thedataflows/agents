---
type: concept
title: Experiment findings
description: Quantitative and qualitative results of Farley's experiment programming with AI via acceptance tests.
tags: [experiment, findings, evidence]
---
# Experiment findings

Setup: OpenAI 4o first, then o1. Task: Flask application. Context given to the
model: the script of the talk itself (explaining the idea) plus the four-layer
acceptance test model.

Results:

- 4o: did "pretty well" but needed extended prompting to reach a working Flask app.
- o1: clearly more capable; produced most necessary behaviors, though with
  heavy coaching.
- Human role: reworked AI-drafted tests into a clearer preferred style; pasted
  generated code into the IDE; made only minor corrections (mostly environment
  config mismatches); changed application code by prompting the AI, not by hand.
- Time: several hours of prompt/code fiddling. Author estimates he could have
  written equivalent code solo in similar time and would have been more
  satisfied with the result, including fewer test-infrastructure mistakes.
- Conclusion: with better prompting, future iterations would be faster; the
  model is genuinely viable as a higher-abstraction programming strategy, but
  current assistants still need strong experienced guidance.
