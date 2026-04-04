# Findings — Phase 4: Synthetic End-to-End Example

## Verdict: CONDITIONAL PASS

Two line-number mismatches between the guide and the fixture files. Both are fixable in minutes and do not affect the structural quality of the walkthrough. Everything else checks out.

---

## Findings

### 1. Line-number mismatch: parser.ts bug reference

- **Severity:** blocking
- **Location:** `docs/examples/getting-started.md:11` and `:37` — cite "parser.ts line 8"; `briefs/handoff-phase4.md:8` cites "line 20"
- **Actual:** The `argv.slice(1)` call is on `docs/examples/fixtures/sample-project/src/parser.ts:21`
- **Description:** The guide and the handoff note both point to the wrong line. A reader following the walkthrough will look at line 8 (blank line at end of docblock) and find nothing. The brief cites line 20, also off by one.
- **Remediation:** Update guide references to line 21. Update handoff note to line 21. Alternatively, renumber the fixture (remove or shorten the docblock) so the code lands on line 8 — but updating the prose is simpler.

### 2. Line-number mismatch: formatter.ts bug reference

- **Severity:** blocking
- **Location:** `docs/examples/getting-started.md:11` and `:39` — cite "formatter.ts line 14"
- **Actual:** Line 14 in `docs/examples/fixtures/sample-project/src/formatter.ts` is a comment (`// BUG: should be...`). The buggy assignment `const rowNum = item.length;` is on line 15.
- **Description:** Off-by-one between the comment and the code. A reader looking at line 14 sees the comment, not the bug. Minor but inconsistent with the precision the guide claims.
- **Remediation:** Update guide references to line 15, or shift the comment so the assignment lands on line 14.

---

## Checklist Results

### Content correctness

| Item | Result | Reference |
|---|---|---|
| Every bug in Step 2 is present in the corresponding fixture | **partial** — bugs exist but cited line numbers are wrong | `parser.ts:21`, `formatter.ts:15` vs guide citing `:8` and `:14` |
| Every fix in Step 3 corresponds to a real change | **verified** | `getting-started.md:52-57` |
| Test counts match (Step 3 = 5, Step 5 = 5) | **verified** | `getting-started.md:67` and `:110` |
| Reviewer finding (unknown-format silent return) is real | **verified** | `formatter.ts:27` returns `""` with no error |
| QA report does not reference diff or reviewer findings | **verified** | `getting-started.md:99-121` — QA only verifies handoff claims |

### Internal consistency

| Item | Result | Reference |
|---|---|---|
| Bug line numbers in guide match fixture files | **not verified** — parser bug: guide says 8, actual 21; formatter bug: guide says 14, actual 15 | see findings #1 and #2 |
| All tests in handoff note are described in guide | **verified** | `handoff-phase4.md:10` lists same tests as `getting-started.md:69-73` |

### Code quality (fixtures)

| Item | Result | Reference |
|---|---|---|
| Each fixture source file under 50 lines | **verified** | parser.ts: 47, formatter.ts: 28, index.ts: 38, parser.test.ts: 23 |
| No dead code beyond intentional bugs | **verified** | all code paths are reachable |
| TypeScript syntactically valid (strict-compatible) | **verified** | proper type annotations, `as const`, strict-compatible patterns throughout |

### Documentation quality

| Item | Result | Reference |
|---|---|---|
| Explicit expected-outcome statements | **verified** | `getting-started.md:28`, `:96`, `:119-121` |
| Guide is self-contained | **verified** | prerequisites, project description, and all 5 steps are complete |
| No unflagged placeholder URLs | **verified** | `getting-started.md:7` placeholder is documented in `handoff-phase4.md:43` |
