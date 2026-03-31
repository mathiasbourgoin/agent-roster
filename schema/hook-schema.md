# Hook Definition Schema

Hooks are markdown files that define automated behaviors triggered by assistant runtime events. Each hook lives in `hooks/<category>/<name>.md` and is installed into the shared harness before being projected into runtime-specific configuration.

## Required Frontmatter

```yaml
---
name: <string>               # Unique identifier (kebab-case)
description: <string>        # One-line summary of what this hook does
event: <string>              # Trigger event (see Events below)
---
```

## Optional Frontmatter

```yaml
matcher: <string>            # Tool name regex, only for PreToolUse/PostToolUse (e.g., "Bash", "Edit|Write")
timeout: <int>               # Timeout in milliseconds (default: 10000)
async: <bool>                # If true, hook runs without blocking (default: false)
requires: [<string>]         # External dependencies (CLI tools, etc.)
version: <semver>            # Version for tracking updates (e.g., 1.0.0)
```

## Events

| Event                | Fires when                                    |
|----------------------|-----------------------------------------------|
| `PreToolUse`         | Before a tool call executes (can block it)     |
| `PostToolUse`        | After a tool call completes                    |
| `SessionStart`       | When an assistant session begins               |
| `Stop`               | When the runtime finishes its turn             |
| `SessionEnd`         | When a session is terminated                   |
| `PostToolUseFailure` | After a tool call fails                        |

## Body

The markdown body has two sections:

1. **Documentation** — What the hook does, why it exists, any caveats.
2. **Command** — The actual shell command in a fenced code block tagged `command`.

## Claude Code `hooks` Format

When installed, hooks become entries in `settings.json`:

```json
{
  "hooks": {
    "<event>": [
      {
        "matcher": "<tool-pattern|omit-if-not-applicable>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command from the command block>"
          }
        ]
      }
    ]
  }
}
```

For `PreToolUse` hooks, a non-zero exit code blocks the tool call. Stdout from the hook is shown to the model as feedback.

## Example

```markdown
---
name: block-dangerous
description: Block destructive git commands (push --force, reset --hard, clean -f).
event: PreToolUse
matcher: Bash
timeout: 5000
---

# Block Dangerous Git Commands

Intercepts Bash tool calls and rejects any that contain destructive git operations. This prevents accidental data loss from force pushes, hard resets, and clean operations.

Blocked patterns:
- `git push --force` / `git push -f` (except to feature branches)
- `git reset --hard`
- `git clean -f`
- `git checkout .` / `git restore .`

## Command

```command
#!/bin/bash
INPUT=$(cat -)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if echo "$COMMAND" | grep -qE 'git\s+(push\s+(-f|--force)|reset\s+--hard|clean\s+-f|checkout\s+\.|restore\s+\.)'; then
  echo "BLOCKED: Destructive git command detected. Ask the user for explicit confirmation."
  exit 1
fi
exit 0
```

## Installed As

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "#!/bin/bash\nINPUT=$(cat -)\nCOMMAND=$(echo \"$INPUT\" | jq -r '.tool_input.command // empty')\nif echo \"$COMMAND\" | grep -qE 'git\\s+(push\\s+(-f|--force)|reset\\s+--hard|clean\\s+-f|checkout\\s+\\.|restore\\s+\\.)'; then\n  echo \"BLOCKED: Destructive git command detected.\"\n  exit 1\nfi\nexit 0"
          }
        ]
      }
    ]
  }
}
```

## Naming Convention

- File: `hooks/<category>/<name>.md`
- Category groups hooks by function (e.g., `safety`, `lint`, `workflow`)
- The `name` field must match the filename (without extension)

## Install Behavior

The canonical installer should place the hook in `.harness/hooks/<name>.md`, then render runtime-specific hook configuration:

- Claude Code: serialize the `command` block and merge it into `.claude/settings.json` or `.claude/settings.local.json`
- Other runtimes: project the same hook intent into the nearest equivalent mechanism, or mark it unsupported if no equivalent exists
