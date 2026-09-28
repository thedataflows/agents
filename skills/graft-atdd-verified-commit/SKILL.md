---
name: graft-atdd-verified-commit
description: "Trigger when user asks to implement, change, fix, or refactor code in repository. Use ATDD/TDD workflow, inspect code with approved tools, verify and review changes, then commit."
---

- ALWAYS Use graft tools to read/grep code. If not available, fallback to /ast-grep and /ast-grep-outline skills instead of grep/rg/sed
- ALWAYS use first /atdd-ai-programming and TDD practices
- After implementation and written code, use /verification-before-completion and /ponytail-review skills and accept recommendations
- git commit
