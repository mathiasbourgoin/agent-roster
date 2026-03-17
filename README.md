# Agent Roster

A curated registry of reusable AI agent definitions + a recruiter meta-agent that assembles, audits, and evolves project teams.

## Quick install

Run this from your project root to install the recruiter as both an agent and a `/recruit` skill — no clone needed:

```bash
mkdir -p .claude/agents .claude/commands && curl -sL https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/recruiter/recruiter.md | tee .claude/agents/recruiter.md .claude/commands/recruit.md > /dev/null
```

Then use `/recruit` in Claude Code to assemble or audit your agent team.

The recruiter fetches everything it needs from GitHub at runtime — the roster index, individual agent definitions, and external sources. No local clone required.

### Optional: fork for your own roster

If you want to maintain your own curated agents and have the recruiter PR new agents back to your repo (Mode 4), fork this repo and update the `roster_repo` tunable in the recruiter with your fork's GitHub URL.

## Agents

| Agent | Domain | Description |
|-------|--------|-------------|
| tech-lead | management | Orchestrates agent teams, triage, batch planning, merge sequencing |
| architect | management | Code quality guardian, metrics regression checks, duplication detection |
| context-manager | management | Maintains shared context document across multi-agent workflows |
| error-coordinator | management | Correlates CI/test failures, root cause analysis |
| knowledge-synthesizer | management | Distills patterns from completed work back into project docs |
| implementer | backend | Parallel worktree implementation, opens MRs/PRs |
| reviewer | testing | Structured code review with required/optional feedback |
| qa | testing | Automated + manual Playwright testing |
| performance-monitor | devops | Profiles slow tests/CI/endpoints, proposes optimizations |
| config-migrator | specialist | One-shot pydantic-settings migration |
| expert-debugger | specialist | Escalation agent for hard build/dependency/API failures |
| recruiter | meta | Assembles and evolves project teams (this is the entry point) |

## Structure

```
agent-roster/
├── agents/                  # Agent definitions by domain
│   ├── backend/
│   ├── devops/
│   ├── frontend/
│   ├── management/
│   ├── security/
│   ├── specialist/
│   └── testing/
├── recruiter/               # The recruiter meta-agent
│   └── recruiter.md
├── schema/                  # Agent definition format spec
│   └── agent-schema.md
├── scripts/
│   ├── build-index.sh       # Generate index.json from agent files
│   └── search.sh            # CLI search across the index
└── index.json               # Auto-generated searchable index
```

## Usage

### Browse agents online

The roster index is available at:
```
https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/index.json
```

### Search agents (if cloned locally)

```bash
./scripts/build-index.sh > index.json
./scripts/search.sh "review"
./scripts/search.sh "" --domain testing
./scripts/search.sh "" --tag security
```

### Recruiter modes

The recruiter has 4 modes:

**Mode 1 — Initial team assembly** (no existing `.claude/agents/`):
1. Analyzes the project's tech stack, languages, CI, issue tracker
2. Searches this roster + external sources (deep GitHub API crawl)
3. Proposes a team with **alternatives for each role** — you pick
4. Resolves tool dependencies (MCP servers, CLI tools) — offers to install them
5. On approval, installs agents into `.claude/agents/` with local tuning

**Mode 2 — Team audit & upgrade** (existing `.claude/agents/` found):
- Compares existing agents against roster and external sources
- Proposes upgrades, additions, and removals

**Mode 3 — Contextual recruitment** (triggered by project changes):
- "We're adding Docker" → proposes relevant agents
- Never removes without explicit request

**Mode 4 — Agent creation** (no suitable agent exists):
- Drafts a new agent definition following the schema
- Installs it locally in the project
- **Opens a PR on this roster repo** so it's available for future projects
- Also detects generalizable improvements to existing agents and PRs them back

### Agent dependencies

Agents declare structured dependencies in their `requires` field:

```yaml
requires:
  - name: playwright
    type: mcp                    # mcp | builtin | cli
    install: "npx @anthropic-ai/mcp-playwright@latest --install"
    check: "grep -q playwright .mcp.json 2>/dev/null"
    optional: true               # Works without it, with reduced capability
```

The recruiter checks availability during team assembly and presents a dependency report before installation.

### Add a new agent

**Via the recruiter (recommended):** The recruiter's Mode 4 drafts new agents and opens a PR back to this repo automatically — no clone needed.

**Manually (requires a fork/clone):**
1. Fork this repo
2. Create a `.md` file in the appropriate `agents/<domain>/` directory
3. Follow the schema in `schema/agent-schema.md`
4. Run `./scripts/build-index.sh > index.json`
5. Commit and open a PR

## External Sources

The recruiter deep-searches these public registries (full directory tree crawl, not just READMEs):

- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) — 100+ specialized subagents
- [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) — 500+ agent skills
- [wshobson/agents](https://github.com/wshobson/agents) — 112 specialized personas
- [heilcheng/awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills) — curated skills collection

## Use as a Claude Code skill

You can make the recruiter available as a `/recruit` slash command in any project.

### Global skill (available everywhere)

```bash
mkdir -p ~/.claude/commands && curl -sL https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/recruiter/recruiter.md > ~/.claude/commands/recruit.md
```

Then use `/recruit` in any project to assemble or audit the agent team.

### Project-level skill only

The quick install command at the top already sets this up. Or manually:

```bash
mkdir -p .claude/commands && curl -sL https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/recruiter/recruiter.md > .claude/commands/recruit.md
```

## Self-improvement

The recruiter checks if a better version of itself exists in external sources and proposes self-replacement when found. It also PRs generalizable improvements from project-local agent customizations back to this repo.
