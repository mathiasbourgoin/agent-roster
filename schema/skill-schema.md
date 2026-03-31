# Skill Definition Schema

Skills are reusable workflow prompts. Each skill lives in `skills/<domain>/<name>.md` and can be exposed through runtime-specific entrypoints.

## Required Frontmatter

```yaml
---
description: <string>        # One-liner shown in Claude Code /help output
---
```

That's it. Claude Code only reads `description` from skill frontmatter, so the shared source schema stays intentionally small.

## Body

The markdown body contains the full workflow instructions. Write it as a direct system prompt in runtime-neutral terms when possible: imperative mood, clear steps, minimal assumptions about slash-command syntax.

## Naming Convention

- File: `skills/<domain>/<name>.md`
- Canonical shared location after install: `.harness/skills/<name>.md`
- Claude compatibility location: `.claude/commands/<name>.md`
- Name must be kebab-case, unique across all skills
- Domain groups skills by function (e.g., `dev`, `security`, `workflow`)

## Example

```markdown
---
description: Run TDD cycle — write failing test, implement, refactor, verify green.
---

# TDD Workflow

You guide the user through a strict red-green-refactor cycle.

## Steps

1. **Red** — Ask the user what behavior to add. Write a failing test for it. Run the test suite and confirm it fails.
2. **Green** — Write the minimum code to make the test pass. Run the suite again.
3. **Refactor** — Look for duplication or clarity improvements in both test and production code. Apply changes. Run suite to confirm green.
4. **Report** — Summarize what was added, tests passing, and any refactoring done.

## Rules

- Never write production code before a failing test exists.
- Never skip the refactor step, even if the code looks clean.
- Run the full test suite after every change, not just the new test.
```

## Install Behavior

The canonical installer should place the skill in the shared harness and then generate runtime entrypoints:

- Claude Code: copy or render to `.claude/commands/<name>.md`
- Codex: expose the same workflow through `.agents/skills/<name>.md` or another Codex-native skill surface

Runtime wrappers should stay thin and mechanically regenerable from the shared source.
