# AGENTS.md — agent-roster audit team

## Mission

Audit and review the agent-roster project: schema compliance, cross-reference validity,
consistency across agent definitions, documentation accuracy, and security of the
provisioning pipeline.

## Team

| Agent | Role | Model |
|-------|------|-------|
| tech-lead | Orchestrates audit — assigns work, collects reports, synthesizes findings | opus |
| architect | Structural audit — schema compliance, cross-references, consistency, duplication | sonnet |
| reviewer | Quality review — correctness, security of pipeline definitions, completeness | opus |

## Audit Scope

- **Schema compliance**: all 15 agent `.md` files vs `schema/agent-schema.md`
- **Cross-reference validity**: tech-lead references mcp-vetter, tool-provisioner, skill-creator, expert-debugger — do they all exist and are names correct?
- **Tag/domain consistency**: are domains and tags used consistently across agents?
- **Duplication**: are any instructions copy-pasted across agents when they should be shared?
- **README accuracy**: does README reflect the current agent set (15 agents including mcp-vetter)?
- **Pipeline security**: is the mcp-vetter's vetting checklist sound? Any gaps?
- **index.json integrity**: does it match the actual agent files?

## Conventions

- Commit convention: conventional commits
- Issue tracker: GitHub
- No implementation in this pass — audit produces a findings report only
- Tech-lead produces a final `AUDIT-REPORT.md` summarizing all findings with severity (required / optional)
