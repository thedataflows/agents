---
type: concept
title: Four-layer test model
description: Layering scheme for acceptance tests used to structure AI-driven development.
tags: [atdd, test-architecture]

sources:
  - id: farley-video-2025
    resource: /references/source-video.md
    title: 'Acceptance Testing Is the FUTURE of Programming' — Dave Farley, Continuous Delivery (YouTube, Jan 15 2025)
  - id: willian-article-2025
    url: https://danielwilliansc.medium.com/executable-specifications-beyond-acceptance-tests-2b3f86c30ab4
    title: 'Executable Specifications Beyond Acceptance Tests' — Daniel Willian (Medium, Mar 10 2025)

status: stable
---
# Four-layer test model

Farley's structure for executable specifications, described to the AI as part
of the working context before generating anything. Separating test logic from
system implementation lets the same test cases target different entry points,
protocols, and even different systems.

## The four layers

1. **Test cases** — the specification: business rules in readable scenario language.
2. **DSL** — a readable abstraction over the test cases' actions.
3. **Protocol** — the driver that interacts with the system (HTTP requests, direct method calls, mock expectations).
4. **System under test** — the actual implementation.

Practical use in this workflow: describe the layering to the AI first, so the
test infrastructure it generates matches this structure.

## Running the same ES at multiple levels

The same executable specification can run at unit, integration, and acceptance
levels; only the protocol and system-under-test layers change:

- **Unit**: system initialized as in dependency injection, external
  dependencies replaced with test doubles; the protocol sets mock expectations
  and invokes methods directly. Best confidence in business rules at unit speed.
- **Integration**: system runs locally against test containers (databases,
  APIs, external services); the protocol is reused as in a live environment.
  Best confidence in business rules without a deployment.
- **Acceptance**: production-like environment, full deployment. Slowest, but
  highest overall confidence before release.

Running business rules at the earliest possible level gives the fastest
feedback and catches issues before they escalate. Trade-off: maintaining
multiple layers costs effort; if acceptance-level ES is already efficient,
lower levels may not add value.

## Explicit unknowns

- Recommended isolation techniques: functional and temporal isolation are named
  as strongly recommended but deferred to separate training material
