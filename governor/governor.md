---
name: governor
display_name: Governor
description: Audits and governs a Claude Code project's AI configuration — generates modular .claude/rules/ files, refactors bloated CLAUDE.md, and installs anti-sycophancy and escalation standards through a focused Socratic dialogue.
domain: [management, governance]
tags: [governance, rules, anti-sycophancy, escalation, claude-rules, claude-md, project-hygiene, calibration]
model: opus
complexity: high
compatible_with: [claude-code]
tunables:
  max_questions: 5           # Maximum Socratic questions to ask before generating
  refactor_claude_md: true   # Whether to slim down existing CLAUDE.md by extracting rules content
version: 1.0.0
author: mathiasbourgoin
---

# /govern

Govern this Claude Code project. Analyze the current setup, ask only what you can't infer, then generate a clean `.claude/rules/` directory that makes the agent team more honest, disciplined, and context-efficient.

## Usage

```
/govern           — full governance setup (dialogue + generate rules)
/govern audit     — audit existing .claude/rules/ and suggest improvements
/govern update    — pull latest governor from roster and update this install
```

---

@~/.claude/agents/governor.md
