# Agent Roster

A curated registry of reusable Claude Code agent definitions. One command gives your project a full AI agent team — recruiter, tech lead, implementers, reviewers, QA, security vetting, and more. The recruiter assembles the right team for your stack, installs it, and keeps it up to date.

## Quick install

Run this from your project root to install the recruiter as both an agent and a `/recruit` skill — no clone needed:

```bash
mkdir -p .claude/agents .claude/commands && curl -sL https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/recruiter/recruiter.md | tee .claude/agents/recruiter.md .claude/commands/recruit.md > /dev/null
```

Then use `/recruit` in Claude Code to assemble or audit your agent team. After assembling your team, run `/recruit govern` to set up governance rules.

### Optional: install the governor standalone

The governor can also be installed independently as a `/govern` skill:

```bash
mkdir -p .claude/agents .claude/commands && \
  curl -sL https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/agents/management/governor.md > .claude/agents/governor.md && \
  curl -sL https://raw.githubusercontent.com/mathiasbourgoin/agent-roster/main/governor/governor.md > .claude/commands/govern.md
```

The recruiter fetches everything it needs from GitHub at runtime — the roster index, individual agent definitions, and external sources. No local clone required.

### Optional: fork for your own roster

If you want to maintain your own curated agents and have the recruiter PR new agents back to your repo (Mode 4), fork this repo and update the `roster_repo` tunable in the recruiter with your fork's GitHub URL.

## Agents

| Agent | Domain | Description |
|-------|--------|-------------|
| **recruiter** | meta | Assembles and evolves project teams — the entry point |
| **governor** | management | Generates `.claude/rules/` governance files via Socratic dialogue — anti-sycophancy, escalation, scope |
| **tech-lead** | management | Orchestrates team, gates tool/skill/MCP requests, owns merge process |
| **skill-creator** | management | Creates skills from MCP servers, CLIs, or ideas; searches registries first |
| **tool-provisioner** | devops | Discovers and provisions MCP servers and CLI tools; searches registries first |
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
| **mcp-vetter** | security | Vets MCP candidates before approval — reputation, permissions, code patterns |

## Structure

```
agent-roster/
├── agents/                  # Agent definitions by domain
│   ├── backend/
│   ├── devops/              # tool-provisioner, performance-monitor
│   ├── frontend/
│   ├── management/          # tech-lead, architect, skill-creator, context-manager, ...
│   ├── security/
│   ├── specialist/          # expert-debugger, config-migrator
│   └── testing/             # reviewer, qa
├── skills/                  # Reusable skill definitions (populated over time)
├── recruiter/               # The recruiter meta-agent (entry point)
│   └── recruiter.md
├── governor/                # The governor meta-agent (installable as /govern)
│   └── governor.md
├── schema/                  # Agent/skill definition format spec
│   └── agent-schema.md
├── scripts/
│   ├── build-index.sh       # Generate index.json from agent files
│   └── search.sh            # CLI search across the index
└── index.json               # Searchable index (fetched via raw URL)
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

The recruiter has 5 modes:

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

**Mode 5 — Governance setup** (`/recruit govern`):
- Installs the governor agent if not already present
- Invokes it to generate `.claude/rules/` governance files via a short Socratic dialogue
- Produces: `sycophancy.md` (anti-sycophancy + L0 self-checks), `escalation.md` (when to pause for human approval), `agent-scope.md` (autonomous action limits), plus path-scoped rules inferred from the tech stack
- Also refactors bloated `CLAUDE.md` by extracting rules into the right files

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
- [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — 144+ agents across 12 professional domains
- [mk-knight23/AGENTS-COLLECTION](https://github.com/mk-knight23/AGENTS-COLLECTION) — 700+ definitions, 68 canonical agents with Claude Code-specific variants

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

## How agents request tools and skills

Agents don't install tools or create skills autonomously. Everything goes through the tech lead:

```
Agent needs a capability
  → Requests it from Tech Lead
    → Tech Lead validates (reject if frivolous)
      → Tool Provisioner searches MCP/CLI registries
        OR Skill Creator searches skill registries
          → Proposes options to Tech Lead
            → MCP Vetter checks reputation, permissions, code patterns
              → Tech Lead approves
                → Install + configure
                  → If no existing tool/skill fits:
                      → Scaffold a new MCP server
                      → OR create a new skill
                      → PR it back to this repo
```

**MCP server registries searched:**
- [modelcontextprotocol/registry](https://github.com/modelcontextprotocol/registry) — official
- [mcp.so](https://mcp.so) — 18K+ servers
- [PulseMCP](https://www.pulsemcp.com/servers) — 10K+ daily-updated
- [MCP Market](https://mcpmarket.com) — curated
- [Glama](https://glama.ai/mcp/servers) — production-ready, sorted by popularity

**Skill registries searched:**
- [anthropics/skills](https://github.com/anthropics/skills) — official
- [claude-skill-registry](https://github.com/majiayu000/claude-skill-registry) — 80K+ skills
- [claude-skills](https://github.com/alirezarezvani/claude-skills) — 192 production-ready
- [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) — 35 curated + 15K via SkillKit

## Keeping your team up to date

Run `/recruit update` at any time to check for newer versions of your installed agents and the recruiter itself. Local tunables are preserved — only the agent instructions update.

The recruiter also self-improves: during searches it checks external sources for better recruiters and proposes replacing itself if one is found. Generalizable improvements your team makes locally get PRed back to this repo.
