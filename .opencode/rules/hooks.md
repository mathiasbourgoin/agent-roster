# Hooks — OpenCode Gap Documentation

## Summary

OpenCode has no native hook API equivalent to Claude's `PreToolUse` / `PostToolUse` hooks. The two hooks defined in `.harness/hooks/` cannot be automatically installed in OpenCode.

This file documents what each hook does and the manual workaround for each.

---

## Hook: block-dangerous-commands

**Canonical source:** `.harness/hooks/block-dangerous-commands.md`  
**Event:** PreToolUse (Bash)  
**Purpose:** Block destructive shell commands — `rm -rf` targeting root/home/cwd, force push to main/master, `git reset --hard`, destructive SQL (`DROP TABLE`, `DROP DATABASE`, `TRUNCATE`), `chmod 777`, piping remote content to shell.

**OpenCode workaround:**

This hook's intent is covered by the `escalation` rule (`.opencode/rules/escalation.md`), which instructs the model to pause and ask for confirmation before any destructive operation. Because OpenCode has no pre-tool interception, the model itself is the enforcement layer.

Agents operating in OpenCode must self-enforce by:
1. Recognising blocked patterns from the escalation rule before issuing a Bash call.
2. Refusing to issue the command and asking the user for explicit confirmation instead.
3. Never proceeding with a blocked pattern even if the user appears to have requested it implicitly.

**Gap:** Unlike Claude's hook, this is not enforced at the infrastructure level. A misbehaving or jailbroken model could bypass it.

---

## Hook: post-edit-lint

**Canonical source:** `.harness/hooks/post-edit-lint.md`  
**Event:** PostToolUse (Edit | Write)  
**Purpose:** Auto-detect the project linter (ESLint, Biome, Ruff, Flake8, Rustfmt/Clippy, golangci-lint, dune fmt) and run it on the edited file after every Edit or Write call. Informational only — never blocks.

**OpenCode workaround:**

OpenCode has no PostToolUse hook. Linting must be triggered manually or via a skill invocation.

Recommended practice:
1. After a sequence of edits, run the appropriate linter manually using the Bash tool.
2. Use the `tdd-workflow` skill, which includes a verify step that catches lint issues as part of its coverage check.
3. For projects with CI, rely on the CI pipeline to surface lint failures before merge.

**Gap:** Lint feedback is not automatic per-edit. Agents must remember to run the linter at the end of an edit session, not after each individual file change.

---

## Recommendation for Future Versions

If OpenCode adds a plugin or hook API, these two hooks should be the first to be ported:

1. `block-dangerous-commands` as a pre-tool plugin on the Bash tool.
2. `post-edit-lint` as a post-tool plugin on Edit and Write tools.

The full command scripts are in `.harness/hooks/` and are ready to install.
