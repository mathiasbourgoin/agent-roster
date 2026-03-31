# Changes

## Unreleased

### Shared Harness

- Added canonical shared harness support via `.harness/`
- Added runtime projection model instead of treating Claude files as the source of truth
- Added Claude projection into `.claude/...`
- Added Codex projection into `.agents/skills/...`

### Tooling

- Added `scripts/sync-harness.sh` to project shared harness files into runtime-specific layouts
- Added `scripts/init-harness.sh` to bootstrap a starter shared harness in a target project
- Added lightweight project detection in `init-harness.sh` for languages, frameworks, and CI

### Schema And Prompt Changes

- Updated harness, skill, rule, and hook schemas to describe a shared canonical harness with runtime-specific projections
- Updated recruiter and harness-builder prompts to operate on `.harness/` first and treat runtime files as generated surfaces

### Upgrade Notes

- Existing Claude-only installs are still supported
- Shared-harness migration for legacy `.claude/...` installs is a transitional concern and should be surfaced during recruiter updates
