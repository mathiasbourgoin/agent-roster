# Skill Definition Schema

Skills are markdown files that become Claude Code slash commands. Each skill lives in `skills/<domain>/<name>.md` and is installed to `.claude/commands/<name>.md`.

## Required Frontmatter

```yaml
---
description: <string>        # One-liner shown in Claude Code /help output
---
```

That's it. Claude Code only reads `description` from skill frontmatter.

## Body

The markdown body contains the full instructions Claude executes when the user invokes `/<name>`. Write it as a direct system prompt — imperative mood, clear steps.

## Naming Convention

- File: `skills/<domain>/<name>.md`
- Installed to: `.claude/commands/<name>.md`
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

The installer copies the file to `.claude/commands/<name>.md`. The skill then appears in Claude Code's `/help` output with the `description` field as its summary. No settings.json entry needed — Claude Code discovers commands from the directory automatically.
