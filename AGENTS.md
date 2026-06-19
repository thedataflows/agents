<!-- AGENTS.md: Rules and configuration for AI agents operating in this workspace. -->

## Agent Activation & Communication

ALWAYS MUST use `caveman`: The default, ultra-compressed communication protocol. Strip fluff, pleasantries, articles, and filler. Focus on exact technical facts and direct steps.

- When entering `plan` mode, AI agents MUST activate and integrate the following skills:
  - `grill-with-docs`: For domain discovery, architectural discussions, and updating `CONTEXT.md`/ADRs.
  - `software-engineer`: For modern software engineering methodologies.
  - `critical-thinking`: To stress-test ideas and locate edge cases.
  - `go-tdd-patterns` & `go-software-designer`: When writing/refactoring Go codebase components.

## Guardrails & Boundaries

- **Rollbacks**: Assess every change for rollback capability and complexity. If a change is not reversible, or if rollback complexity exceeds your role, DO NOT proceed without explicit human confirmation.
- **Permissions**: NEVER execute commands utilizing `sudo` or touch/delete files or directories where the current user (`cri`) lacks standard permissions.
- **Integrity**: Prioritize correctness, code clarity, and next-maintainer readability. Do not introduce half-implemented mocks or unreachable code paths.
