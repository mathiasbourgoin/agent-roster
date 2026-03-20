# AUDIT REPORT — agent-roster

**Date:** 2026-03-20
**Team:** tech-lead (synthesis), architect (structural), reviewer (security/quality)
**Scope:** All 15 agent definitions, recruiter, schema, README, index.json

---

## BLOCKERS — Fix Before Next Merge

### B1. mcp-vetter missing from index.json
**Flagged by:** architect + reviewer (independent corroboration)
**File:** `index.json`
**Impact:** Recruiter cannot discover or recommend mcp-vetter via search. README lists it; index does not. Discovery pipeline is broken.
**Fix:** Rebuild index with `./scripts/build-index.sh > index.json` — **done in this commit**.

### B2. Recruiter self-update overwrites local tunables without merging
**Flagged by:** reviewer
**File:** `recruiter/recruiter.md`, Self-Update section
**Impact:** `/recruit update` overwrites `.claude/agents/recruiter.md`, `.claude/commands/recruit.md`, and `~/.claude/commands/recruit.md` wholesale. Any local tuning (custom `external_sources`, `roster_repo`, `max_team_size`) is silently lost on update.
**Fix:** Self-update must extract the current file's `tunables` block, apply it over the new version before writing. Added to recruiter.md — **done in this commit**.

---

## REQUIRED — Address Soon

### R1. config-migrator missing `requires:` field
**File:** `agents/specialist/config-migrator.md`
**Impact:** Breaks consistency pattern — all 14 other agents have explicit `requires:` (even if empty). Schema permits omission, but tooling that parses the field may behave unexpectedly.
**Fix:** Add `requires: []` between `tunables` and `isolation`.

### R2. MCP vetter: no guidance on transitive dependency scanning
**File:** `agents/security/mcp-vetter.md`
**Impact:** An MCP server with clean direct code but a compromised deep transitive dependency (e.g., a poisoned npm package 3 levels down) would pass vetting.
**Fix:** Add note to Code Pattern Scan section recommending `npm audit` / `pip-audit` when source is available.

### R3. MCP vetter: block condition #2 wording is soft
**File:** `agents/security/mcp-vetter.md`, block conditions
**Current:** "Reads from ~/.ssh, ~/.aws… without an explicit stated reason"
**Risk:** A server claiming a "legitimate reason" could escape the block.
**Fix:** Tighten to "without a documented, verifiable technical justification in the README."

### R4. Chinese Wall is a behavioral contract, not a technical lock
**File:** `agents/management/tech-lead.md`, Chinese Wall section
**Impact:** Claude Code's Agent tool cannot prevent the tech-lead from passing disallowed context. The wall is only as strong as the tech-lead's prompt discipline. No audit trail exists.
**Fix:** Add a note explicitly calling this a behavioral contract, and add a "context log" step: tech-lead records what context it passed to each agent in the session.

### R5. QA retry behavior relative to Chinese Wall is undefined
**File:** `agents/management/tech-lead.md`
**Impact:** On a second QA pass (after implementer fixes an issue), QA has memory of the first failure. It may anchor on its prior findings rather than testing fresh.
**Fix:** Add: "On retries, QA must test from first principles — treat the MR as if seeing it for the first time."

### R6. Recruiter scoring: stale personal roster agents still score high
**File:** `recruiter/recruiter.md`, scoring formula
**Impact:** A personal roster agent with no commits in 2 years scores ≥10, while a well-maintained 500-star external agent scores ≤21. The personal roster bias is intentional, but stale agents should not unconditionally beat fresh external alternatives.
**Fix:** Add rule: "If a personal roster agent's last commit is > 365 days old AND a higher-freshness external agent covers the same domain, present the external agent as primary recommendation with the roster agent flagged as 'potentially stale'."

### R7. Vague triggering conditions for context-manager, error-coordinator, architect
**Files:** respective agent .md files
**Impact:** Agents without defined invocation triggers may never be called, or may be called too often.
**Details:**
- `context-manager`: no defined update triggers
- `error-coordinator`: "recurring failures" not quantified (3+ identical errors? Same error across 2+ agents?)
- `architect`: `metrics_command` empty by default — agent has no concrete workflow without configuration
**Fix:** Add example triggering conditions and a sample `metrics_command` for common stacks.

---

## OPTIONAL — Nice to Have

| # | Finding | File |
|---|---------|------|
| O1 | Clarify that Reviewer and QA run concurrently only on *different* MRs, not the same MR | tech-lead.md, Spawn Mode |
| O2 | Define "generic persona only" for the scoring penalty | recruiter.md, scoring formula |
| O3 | Document semver comparison algorithm (what about pre-release versions?) | recruiter.md, Self-Update |
| O4 | Add self-upgrade rejection logging (avoid re-proposing the same replacement) | recruiter.md, Self-Upgrade |
| O5 | Add `.gitkeep` + stub README to empty `agents/frontend/` directory | agents/frontend/ |
| O6 | Standardize README agent description length | README.md |

---

## PASSED — No Action Needed

| Check | Result |
|-------|--------|
| Schema compliance (all 15 agents) | ✅ All required fields present, valid values |
| Cross-reference validity (all tech-lead references) | ✅ All referenced agents exist |
| Tag/domain consistency | ✅ Consistent hyphen convention, no synonyms |
| Instruction duplication | ✅ None found |
| Agent contradictions | ✅ None found |
| Tunable usage in agent bodies | ✅ All tunables referenced |
| MCP vetting pipeline position | ✅ Cannot be bypassed |
| Spawn mode deadlock risk | ✅ None — tech-lead serializes |
| Recruiter scoring balance | ✅ Personal roster bias is intentional and correct |

---

## Fix Status

| ID | Finding | Status |
|----|---------|--------|
| B1 | mcp-vetter missing from index.json | ✅ Fixed |
| B2 | Self-update overwrites tunables | ✅ Fixed |
| R1 | config-migrator missing requires | ✅ Fixed |
| R2–R7 | See Required section above | 🔲 Open |
| O1–O6 | See Optional section above | 🔲 Open |
