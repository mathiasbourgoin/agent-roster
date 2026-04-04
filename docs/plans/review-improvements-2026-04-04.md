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

Add a "Get started in 3 steps" section at the top of README.md, before the architectural explanation:

```markdown
## Quick Start

1. In your project: `/recruit` — assembles a team (4 core agents by default)
2. Start a task: ask tech-lead to research and plan
3. Execute: follow the brief, human-gate each stage
```

Recommended default team (4 agents, covers 80% of tasks):
- `tech-lead` — orchestration + Ralph Loop
- `implementer` — execution
- `reviewer` — code review
- `qa` — verification

The recruiter already supports this. The gap is documentation — new users have no obvious "minimal" starting point.

### 3.2 Recruiter: focus pass (not a trim)

The reviewer's concern is that the recruiter feels heavy and ceremonial. The 33KB size is real but not the root problem — the issue is that the recruiter's decision logic is buried in prose. Making it more focused and targeted means:

- Tighter mode detection (currently implicit in prose, should be explicit decision tree upfront)
- Scoring algorithm presented as a reference table, not embedded mid-paragraph
- Mode docs deduplicated (the search strategy section is repeated in spirit across Mode 1, 2, and 3)
- Clearer separation: what the recruiter decides vs. what it asks the human

**Decision:** recruiter gets a focus/targeting pass as Phase 3b, after README quick-start. No content removal — restructure for clarity and reduce cognitive load at the entry point.

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
