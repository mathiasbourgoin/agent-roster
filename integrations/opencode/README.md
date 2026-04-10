# OpenCode Integration

OpenCode agents are `.md` files with YAML frontmatter stored in `.opencode/agents/`.

This integration provides the **Tech-Lead** agent as a **primary role** in OpenCode, appearing directly in the main Tab-cycle list alongside Build and Plan.

## Features

- **Tech-Lead as Primary Role**: Available directly in the main agent picker (no `@` prefix needed)
- **Full Workflow Preservation**: Maintains all properties from the agent-roster definition including Ralph Loop workflow, model preferences, and tunables
- **Harness Integration**: Works seamlessly with the shared harness model (`.harness/` → `.opencode/`)

## Agent Mode

Unlike typical OpenCode agent integrations that use `mode: subagent` (requiring `@agent-name` invocation), Tech-Lead is configured with `mode: agent` to make it a primary role:

```yaml
---
name: Tech Lead
description: Orchestrates agent teams, gates tool and skill requests, and owns merge/governance quality bars.
mode: agent          # ← PRIMARY ROLE (not subagent)
color: '#3498DB'
---
```

## Installation

### Option 1: Via Harness (Recommended)

If your project uses the agent-roster harness model:

1. **Enable OpenCode runtime** in `.harness/harness.json`:

   ```json
   {
     "runtimes": [
       {"name": "claude-code", "enabled": true},
       {"name": "opencode", "enabled": true}
     ]
   }
   ```

2. **Copy Tech-Lead agent** to your harness:

   ```bash
   mkdir -p .harness/agents
   cp /path/to/agent-roster/integrations/opencode/agents/tech-lead.md .harness/agents/
   ```

3. **Sync the harness** to generate `.opencode/` files:

   ```bash
   /path/to/agent-roster/scripts/sync-harness.sh .
   ```

   This creates `.opencode/agents/tech-lead.md` in your project.

### Option 2: Direct Copy

For standalone usage without the harness:

```bash
# Project-scoped (recommended for team projects)
mkdir -p .opencode/agents
cp integrations/opencode/agents/tech-lead.md .opencode/agents/

# Global (available across all your projects)
mkdir -p ~/.config/opencode/agents
cp integrations/opencode/agents/tech-lead.md ~/.config/opencode/agents/
```

## Usage

Once installed, Tech-Lead appears as a primary agent in OpenCode:

### Main Tab-Cycle

Tech-Lead is available directly in the primary agent picker. Tab through agents:
- `Build` → `Plan` → `Tech Lead` → ...

No `@` prefix needed - just switch to Tech-Lead mode and start giving instructions.

### Example Workflows

```
[Switch to Tech-Lead agent]

Plan the implementation for issues #123, #124, and #125. 
Identify dependencies and create parallel execution batches.
```

```
[Tech-Lead mode]

Coordinate the reviewer and QA flow for PR #42.
Check if all Tier 1 criteria pass before merge.
```

```
[Tech-Lead mode]

We need a new MCP server for database migrations.
Evaluate necessity and coordinate with tool-provisioner.
```

## Regenerate

To regenerate the OpenCode agent files from the source agent definitions:

```bash
cd /path/to/agent-roster
./integrations/opencode/convert-agents.sh
```

This updates `integrations/opencode/agents/tech-lead.md` from the canonical source at `agents/management/tech-lead.md`.

## Tech-Lead Capabilities

The Tech-Lead agent provides:

- **Batch Planning**: Analyzes work sets, maps dependencies, creates safe parallel execution plans
- **Delegation**: Coordinates implementer → reviewer → QA workflows
- **Ralph Loop Enforcement**: Defines Tier 1 (deterministic) and Tier 2 (judgment) evaluation criteria
- **Tool Gatekeeping**: Validates necessity of tool/MCP/skill requests before provisioning
- **Merge Governance**: Makes merge/no-merge decisions based on review, QA, and quality bars
- **CI Failure Handling**: Investigates failed builds, classifies issues, coordinates fixes

See the full agent definition in `agents/management/tech-lead.md` for complete workflow details.

## Project vs Global

**Project-scoped** (`.opencode/agents/`):
- Agent available only in this project
- Different projects can use different versions
- Recommended for team projects with shared configuration

**Global** (`~/.config/opencode/agents/`):
- Agent available across all your projects
- Convenient for personal workflows
- Updates apply everywhere

## Extending

To add more agents as subagents (on-demand via `@agent-name`):

Edit `integrations/opencode/convert-agents.sh` and add:

```bash
# Convert additional agents as subagents
convert_agent "$REPO_ROOT/agents/backend/implementer.md" "subagent"
convert_agent "$REPO_ROOT/agents/testing/reviewer.md" "subagent"
```

Then regenerate:

```bash
./integrations/opencode/convert-agents.sh
```

## Technical Details

- **Source**: `agents/management/tech-lead.md` (canonical definition)
- **Output**: `integrations/opencode/agents/tech-lead.md` (OpenCode format)
- **Mode**: `agent` (primary role, not subagent)
- **Color**: Blue (#3498DB) for leadership/orchestration
- **Model**: Preserves `opus` recommendation from source
- **Workflow**: Full Ralph Loop, batch planning, delegation boundaries maintained
