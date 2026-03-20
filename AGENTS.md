# AGENTS.md — agent-roster

## Project

A curated registry of reusable Claude Code agent definitions paired with a recruiter meta-agent that assembles, audits, and evolves project teams.

## Conventions

- **Commit convention:** conventional commits (`feat:`, `fix:`, `docs:`, `chore:`)
- **Issue tracker:** GitHub
- **Branch strategy:** feature branches → PR → merge to main
- **Versioning:** semver on each agent (`version:` frontmatter field) — bump on any behavioral change

## Agent Definitions

All agents live in `agents/<domain>/` or `recruiter/`. They follow the schema in `schema/agent-schema.md`.

When modifying an agent:
1. Bump its `version` field (patch for fixes, minor for new behavior)
2. Run `./scripts/build-index.sh > index.json` to update the index
3. Update README.md agent table if the description changed

## Adding a New Agent

1. Create `agents/<domain>/<agent-name>.md` following `schema/agent-schema.md`
2. Run `./scripts/build-index.sh > index.json`
3. Add a row to the README agent table
4. Open a PR

Preferred path: use the recruiter's Mode 4 — it handles creation, local install, and PR in one step.

## Pipeline & Governance

The tech-lead orchestrates all agents. No agent provisions tools, creates skills, or installs MCP servers without going through the tech-lead → tool-provisioner → mcp-vetter pipeline.

See `agents/management/tech-lead.md` for the full governance model.
