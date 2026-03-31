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
- Added TypeScript indexer workflow (`npm run build:index`) with deterministic source config in `index-sources.json`
- Added `scripts/build-index.sh` compatibility wrapper that delegates to the TS indexer
- Added cache-first indexer behavior with `--refresh-remotes` for explicit remote refresh
- Added source fingerprint reuse for fast refreshes when remote candidate sets are unchanged
- Added smart build runner (`scripts/run-build-index.js`) to compile TS only when needed
- Added bounded parallel remote fetch in index builds for faster cold refresh performance

### Schema And Prompt Changes

- Updated harness, skill, rule, and hook schemas to describe a shared canonical harness with runtime-specific projections
- Updated recruiter and harness-builder prompts to operate on `.harness/` first and treat runtime files as generated surfaces
- Updated recruiter discovery strategy to consume rebuilt `index.json` instead of ad-hoc remote crawling
- Updated recruiter tunables and instructions to use deterministic index build flow (`index_sources_file`, `index_build_command`)

### Upgrade Notes

- Existing Claude-only installs are still supported
- Shared-harness migration for legacy `.claude/...` installs is a transitional concern and should be surfaced during recruiter updates
