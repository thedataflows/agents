---
name: subagent-atdd-verified-commit
description: "Trigger when user asks to implement, change, fix, or refactor code in repository. Use ATDD/TDD workflow, inspect code with approved tools, verify and review changes, then commit."
---

## Sub-Agents

- Use sub-agents, do not do work yourself. You only coordinate.
- Always reserve agents to review the code of other agents.
- If you must reuse existing agent sessions, compact their context first
- The user might specify what models to use for sub-agents, accept it
- In case of sub-agent failure, attempt to recover the session using the next available model

## Rules

- ALWAYS obey and check the governing specs and rules. DO NOT go into any edge case that was not designed or asked of you. DO NOT let your sub-agents to it as well.
- ALWAYS Use graft tools and `ast-grep`/`ast-grep-outline` tools and skills to read/grep existing code. Resolve code callers with local AST and available language server (gopls, etc) or use ast-grep embedded language servers. DO NOT use grep/rg/sed or `read` file tools unless there is nothing else or not code.
- ALWAYS use first /atdd-ai-programming and TDD practices
- After implementation and written code, spawn separate agents with /verification-before-completion and /ponytail-review skills and accept recommendations
- Update ALL relevant docs (issues, specs, diagrams, context, etc)
- git commit
