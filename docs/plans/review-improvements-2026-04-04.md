# Plan: Address External Review Findings
**Date:** 2026-04-04
**Branch:** feat/review-improvements
**Status:** draft

---

## Context

An external review identified six problems with agent-roster. This plan addresses all actionable items in priority order. Non-actionable items (get a second user, write a blog post) are noted but not tracked here.

**Review verdict:** "Improve, don't forget — but don't advertise yet."

---

## Findings and Priority

| # | Finding | Severity | Actionable here? |
|---|---------|----------|------------------|
| 1 | Zero tests — indexer, YAML parsing, scoring all untested | High | Yes |
| 2 | `parseFrontmatter` bug — line 152 returns `null` instead of `fm` | High | Yes |
| 3 | `build-index.ts` is 958 lines — violates 500-line code-quality rule | Medium | Yes |
| 4 | Recruiter overengineered — 33KB, 5 modes, for what is essentially agent selection | Medium | Partially |
| 5 | No real-world validation — no example project, no end-to-end evidence | High | Yes |
| 6 | No "just try it" path — onboarding requires understanding the whole system | Medium | Yes |

---

## Phase 1 — Code Correctness (highest priority)

### 1.1 Fix `parseFrontmatter`

**File:** `scripts/build-index.ts:152`

The closing `---` branch falls through to `return null`. Fix: change `return null` to `return fm` at line 152.

**Impact:** currently all files silently fall through to `parseLooseMetadata` as the de facto parser. After the fix, files with valid YAML frontmatter will be parsed by the correct path. Behavior is identical for well-formed files, but error cases improve: files with valid frontmatter but edge-case loose metadata will now parse correctly.

### 1.2 Add test suite for `build-index.ts`

**Test runner:** Node.js built-in `node:test` — zero new dependencies, available since Node 18.

**Test file:** `scripts/build-index.test.ts`

Functions to cover:

| Function | Test cases |
|----------|-----------|
| `parseFrontmatter` | valid frontmatter, missing closing `---`, inline arrays, scalar values, empty body |
| `parseLooseMetadata` | file with no frontmatter markers, mixed content, missing name field |
| `inferComponentType` | each path prefix (agents/, skills/, rules/, hooks/, kb/, unknown) |
| `normalizeEntry` | valid entry, missing name returns null, defaults applied |
| `chooseBestSourceEntries` | no cache, empty refresh uses cache, refresh < 95% of cache uses cache |
| `enrichRemoteEntry` | domain inference, tag deduplication, complexity inference thresholds |
| `inferComplexity` | < 120 lines = low, 120–279 = medium, ≥ 280 = high |

**New script in `package.json`:**
```json
"test": "tsc -p tsconfig.json && node --test dist/scripts/build-index.test.js"
```

**Note:** functions are currently not exported. The test file will require either (a) exporting them explicitly, or (b) testing through the compiled output. Option (a) is cleaner — add `export` to each tested function.

---

## Phase 2 — Code Quality

### 2.0 Reviewer carry-forward fixes (from Phase 1 review)

These gaps were identified by the reviewer and must be resolved before Phase 2 work is considered complete:

1. **Export `IndexEntry` and `SourceCache` types** from `build-index.ts` and import them in `build-index.test.ts` — currently the test file duplicates the type shape, which will silently drift if the types change.
2. **Document multi-line YAML silent-drop** — add a comment at `build-index.ts:130` explaining that indented lines (block scalars, nested keys) are intentionally skipped. Add one test confirming the behavior.
3. **Add CRLF test** — one `parseFrontmatter` test using `\r\n` delimiters.
4. **Add empty-empty test** — `chooseBestSourceEntries(emptyCache, [])` should return `[]`.

These are bundled into Phase 2 because the module split will restructure the files anyway — fix before splitting, then split.

### 2.1 Split `build-index.ts` (958 lines → modules)

The file exceeds the 500-line limit in `code-quality.md`. It has five distinct responsibilities that map cleanly to modules:

| Module | Responsibility | Est. lines |
|--------|---------------|------------|
| `scripts/lib/frontmatter.ts` | `parseFrontmatter`, `parseLooseMetadata`, `parseInlineArray`, `parseScalar` | ~80 |
| `scripts/lib/infer.ts` | `inferComponentType`, `inferComplexity`, `inferDomainBySource`, `inferCompatible*` | ~150 |
| `scripts/lib/normalize.ts` | `normalizeEntry`, `enrichRemoteEntry`, `fallbackRemoteEntry`, `sanitizeName` | ~130 |
| `scripts/lib/remote.ts` | `fetchText`, `fetchJson`, `collectRemoteCandidates`, `collectCatalogEntries`, `resolveCandidatePath`, `parseMarkdownLinks*` | ~180 |
| `scripts/lib/cache.ts` | `readSourceCacheRecord`, `writeSourceCache`, `fingerprint*`, `chooseBestSourceEntries` | ~80 |
| `scripts/build-index.ts` | CLI entry, `run()`, `collectLocalMarkdownFiles`, `mapLimit`, `sortEntries` | ~150 |

Total: ~770 lines across 6 files (each under 200). The split is purely mechanical — no logic changes.

**Test file benefit:** modules can be imported individually, making unit tests simpler and not requiring function exports from the CLI entry point.

---

## Phase 3 — Onboarding

### 3.1 README quick-start section

**File:** `README.md` — insert immediately after the three-bullet principles block, before "The harness is the mechanism..."

Content to insert:

```markdown
## Quick Start

Install in any project:

```
/recruit
```

The recruiter assembles a minimal team and configures the harness. Default team (covers 80% of tasks):

| Agent | Role |
|-------|------|
| tech-lead | Orchestration, Ralph Loop, human gates |
| implementer | Code execution in isolated worktrees |
| reviewer | Structured review: correctness, security, regression |
| qa | Independent test verification |

Then: ask `tech-lead` to research and plan your first task.
```

**Acceptance criteria:**
- Quick Start section appears before any architecture explanation
- Table renders correctly in GitHub markdown
- `/recruit` is the only command shown (no flags, no modes)
- No mention of `.harness/`, projections, or harness model in this section

### 3.2 Recruiter: focus pass (not a trim)

**File:** `recruiter/recruiter.md` (canonical) — sync to `.claude/agents/recruiter.md` after

The recruiter's decision logic is buried in prose across 5 mode descriptions. Restructure for clarity without removing capability:

1. **Add mode-detection table at the top** (before any mode prose) — a single table mapping invocation pattern → mode number, so the reader knows in 3 seconds which section applies to them.

2. **Extract scoring algorithm** from Mode 1 prose into a dedicated `## Scoring Reference` section — a standalone table, not embedded mid-paragraph. Mode 1 prose replaces it with a one-line reference: "See Scoring Reference."

3. **Deduplicate search strategy** — the GitHub tree traversal instructions appear in Mode 1, Mode 2, and Mode 3 in equivalent form. Extract to a single `## Search Strategy` section. Modes reference it by name.

4. **Split "what recruiter decides" from "what recruiter asks"** — add a `## Decision Boundaries` section that explicitly lists: decisions the recruiter makes autonomously vs. questions it must ask the human before proceeding.

**Acceptance criteria:**
- Mode detection table is the first substantive content after frontmatter
- Scoring algorithm appears exactly once
- Search strategy appears exactly once
- Total line count reduced (deduplication effect) — target under 500 lines
- No capability removed: all 5 modes, all scoring factors, all search logic preserved

---

## Phase 4 — Real-World Validation

### 4.1 End-to-end example

This is the highest-value item per the reviewer: *"A non-trivial project, install the harness, run the full pipeline, and document the experience end-to-end."*

**Output:** `docs/examples/getting-started.md` + `docs/examples/fixtures/`

**Approach:** synthetic example project tuned for the demonstration, with specific expected outputs at each stage. This makes the example reproducible by anyone, verifiable, and immune to drift from a real project's evolution.

Structure:
- `docs/examples/fixtures/sample-project/` — a small but realistic project (e.g. a TypeScript CLI tool with intentional bugs and missing tests)
- The example walks through: `/recruit` → tech-lead research brief → planner decomposition → implementer fix → reviewer pass → qa verification
- Each stage includes the actual agent output (abbreviated but real, not paraphrased)
- Expected outputs are explicit: "reviewer should flag X", "qa should report pass on Y"

**Benefit over real-project approach:** anyone can reproduce the exact same run, the example never goes stale, and it doubles as a test fixture for future validation.

---

## Delivery Sequence

```
Phase 1a: fix parseFrontmatter bug          → implementer (isolated worktree)
Phase 1b: add test suite (node:test)        → implementer (continues in worktree)
Phase 2:  split build-index.ts              → implementer (new worktree after Phase 1 merges)
Phase 3:  README quick-start               → implementer (small, can be parallel with Phase 2)
Phase 4:  synthetic end-to-end example     → implementer + human review of outputs
Phase 5:  recruiter focus pass             → implementer (after example, restructure not trim)
```

Reviewer and QA run after each phase before merge.

---

## Out of Scope

- Getting a second external user — network effect, not a code problem
- Writing a blog post / design doc — valuable but separate effort
- Adding a YAML parsing library — `parseFrontmatter` is simple enough; the bug is one line, not a design flaw
- Runtime schema validation on agent files — scope creep, adds complexity
