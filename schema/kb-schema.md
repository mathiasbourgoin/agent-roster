# Knowledge Base Schema

The knowledge base (`kb/`) stores project documentation, specifications, and audit reports. Managed by **kb-agent**, audited by configured auditor agents.

## File Format

All KB files are markdown with YAML frontmatter:

```yaml
---
title: <string>              # Document title
last-updated: <date>         # ISO 8601 date
status: <draft|reviewed|stale>  # Current state
owner: <string>              # Agent or human responsible
---
```

Body is standard markdown. Cross-references use relative markdown links (e.g., `[architecture](../architecture.md)`).

## Structure Tiers

### Minimal

For small projects or initial bootstrap.

```
kb/
├── index.md
├── spec.md
└── glossary.md
```

### Standard

For active development projects.

```
kb/
├── index.md
├── spec.md
├── architecture.md
├── glossary.md
├── properties.md
├── decisions/
│   ├── index.md
│   └── 001-<title>.md
└── reports/
    ├── index.md
    └── audit-<date>.md
```

### Large

For multi-module or monorepo projects.

```
kb/
├── index.md
├── spec.md
├── architecture.md
├── glossary.md
├── properties.md
├── decisions/
│   ├── index.md
│   └── 001-<title>.md
├── modules/
│   ├── index.md
│   └── <module-name>/
│       ├── index.md
│       ├── spec.md
│       └── architecture.md
├── reports/
│   ├── index.md
│   └── audit-<date>.md
└── runbooks/
    ├── index.md
    └── <runbook-name>.md
```

## Index Files

An `index.md` is required at every directory level. It lists the contents of that directory with one-line descriptions and relative links.

## Immutability Rules

**Spec files** are immutable except by explicit human intent:

- `spec.md` — Project specification
- `architecture.md` — System architecture
- `properties.md` — Invariants and correctness properties
- `glossary.md` — Term definitions
- `decisions/*.md` — Architecture Decision Records

Agents may propose changes to spec files but must not apply them without human approval. Proposals go through the governor agent's review process.

**Operational files** update freely:

- `reports/*.md` — Audit reports, status reports
- `index.md` — Auto-updated when files are added/removed
- TODOs and tracking documents

## Auditor Report Format

Audit reports in `reports/` use this frontmatter:

```yaml
---
title: <string>              # e.g., "KB Audit — 2026-03-31"
auditor: <string>            # Agent name that produced the report
date: <date>                 # ISO 8601 audit date
status: <pass|warn|fail>     # Overall audit result
---
```

Body is organized by severity:

```markdown
## Critical

- [finding description + file reference]

## Warning

- [finding description + file reference]

## Info

- [finding description + file reference]
```

Empty severity sections may be omitted.

## Cross-Reference Conventions

- Always use relative paths from the current file.
- Link to specific sections with anchors: `[decisions](decisions/index.md#pending)`.
- When referencing code, use the pattern: `see [module](../src/module.ml) L42-58`.
- Broken links are flagged as warnings during KB audit.
