# Implementer Brief — Phase 4: Synthetic End-to-End Example

## Task

Create a synthetic end-to-end walkthrough for the agent-roster harness. This is documentation, not code that runs.

## Files to Create

### 1. `docs/examples/fixtures/sample-project/`

A small but realistic TypeScript CLI tool with intentional bugs and missing tests. This serves as the "client project" in the walkthrough.

#### Required structure:

```
docs/examples/fixtures/sample-project/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts          — CLI entry point
│   ├── parser.ts         — argument parser (has a bug)
│   └── formatter.ts      — output formatter (has a bug)
└── tests/
    └── parser.test.ts    — tests for parser only (formatter has no tests)
```

#### Content requirements:

**package.json** — name: `sample-cli`, version 0.1.0, scripts: `build: tsc`, `test: node --test`. devDependencies: `typescript` only.

**tsconfig.json** — strict mode, target ES2022, module NodeNext, outDir dist.

**src/index.ts** — A CLI that accepts `--count N` and `--format (table|json)` flags, reads a hardcoded list of items, and prints them. Uses `parser.ts` and `formatter.ts`. ~30 lines.

**src/parser.ts** — Parses `process.argv`. Contains **intentional bug #1**: off-by-one when slicing argv (uses `process.argv.slice(1)` instead of `process.argv.slice(2)`). The function is `parseArgs(argv: string[]): { count: number; format: string }`. ~25 lines.

**src/formatter.ts** — Formats an array of strings as table or JSON. Contains **intentional bug #2**: in table format, uses `item.length` instead of `index + 1` for row numbering (all rows get the same number). The function is `formatOutput(items: string[], format: string): string`. ~30 lines.

**tests/parser.test.ts** — Uses Node.js built-in `node:test` and `node:assert`. Tests `parseArgs`. Tests: (1) default count is 10, (2) --count flag sets count. **Missing**: no test for formatter. **Missing**: no test for invalid --count values. ~30 lines.

### 2. `docs/examples/getting-started.md`

A walkthrough guide using the sample-project as the client. It must be self-contained and reproducible.

#### Structure (follow this exactly):

```markdown
# Getting Started with Agent Roster

## Prerequisites
[3 bullet points: Node 20+, TypeScript, clone agent-roster]

## The Sample Project
[1 paragraph describing sample-cli and its intentional issues. Be explicit: "parser.ts line 8 slices argv at index 1 instead of 2", "formatter.ts line 14 uses item.length instead of i+1"]

## Step 1: Recruit Your Team

User runs: `/recruit`

Recruiter output (abbreviated real format):
\`\`\`
[recruiter] Scanning project...
Mode: greenfield (no .claude/agents/ found)
Recommended team:
  - implementer  (score 9/10) — fix bugs, add tests
  - reviewer     (score 8/10) — diff review + policy check
  - qa           (score 8/10) — independent test run
  - tech-lead    (score 7/10) — orchestrate pipeline
Installing to .claude/agents/...done (4 agents)
\`\`\`

Expected: recruiter selects implementer, reviewer, QA, tech-lead. Does NOT select architect or kb-agent (project is small, no spec yet).

## Step 2: Tech-Lead Research Brief

Tech-lead reads the project and produces a research brief.

Brief content (abbreviated):
\`\`\`
Project: sample-cli v0.1.0
Issues found:
  - parser.ts:8  — argv slice off-by-one (BUG, Tier 1)
  - formatter.ts:14 — row numbering uses item.length (BUG, Tier 1)
  - formatter.ts — no test coverage (MISSING TESTS, Tier 1)
  - parser.ts — no test for invalid --count (MISSING TESTS, Tier 2)
Completion criteria:
  Tier 1: npm test passes, both bugs fixed, formatter test added
  Tier 2: invalid input test added
\`\`\`

## Step 3: Implementer Fixes

Implementer receives: requirements above + relevant source files. Implementer does NOT receive prior conversation context.

Changes made:
- `src/parser.ts` line 8: `argv.slice(1)` → `argv.slice(2)`
- `src/formatter.ts` line 14: `item.length` → `i + 1`
- `tests/formatter.test.ts` (new): tests formatOutput for table and json modes
- `tests/parser.test.ts`: adds test for invalid --count (expects throw)

Implementer handoff note:
\`\`\`
Files changed:
  src/parser.ts       — fixed argv slice index (line 8)
  src/formatter.ts    — fixed row numbering (line 14)
  tests/formatter.test.ts — new: 2 tests (table format, json format)
  tests/parser.test.ts    — added: 1 test (invalid --count throws)
Tests: 5 pass, 0 fail
npm test output:
  ✔ parseArgs: default count is 10 (1.2ms)
  ✔ parseArgs: --count flag sets count (0.8ms)
  ✔ parseArgs: invalid --count throws (0.6ms)
  ✔ formatOutput: table format numbers rows correctly (0.9ms)
  ✔ formatOutput: json format is valid JSON (0.7ms)
\`\`\`

## Step 4: Reviewer Pass

Reviewer receives: diff + review brief + handoff note. Does NOT receive prior conversation or QA results.

Reviewer checks:
- [x] Both bugs fixed (verified at correct lines)
- [x] formatter test covers table and json modes
- [x] parser test covers invalid input
- [x] No file exceeds 500 lines
- [x] No function exceeds 50 lines

Reviewer flags (non-blocking):
- `formatter.ts` has no handling for unknown `format` values — silently returns empty string. Should throw or default.

Reviewer verdict: **CONDITIONAL PASS**
Condition: formatter unknown-format behavior should be documented or fixed in a follow-up issue.

Expected: reviewer flags the unknown-format silent failure. This is the correct finding — it is not a false alarm.

## Step 5: QA Verification

QA receives: phase requirements + handoff claims. Does NOT receive the diff or reviewer findings.

QA runs `npm test` independently on the worktree branch:
\`\`\`
✔ parseArgs: default count is 10 (1.1ms)
✔ parseArgs: --count flag sets count (0.9ms)
✔ parseArgs: invalid --count throws (0.5ms)
✔ formatOutput: table format numbers rows correctly (0.8ms)
✔ formatOutput: json format is valid JSON (0.6ms)
pass: 5, fail: 0
\`\`\`

QA verifies handoff claims:
- [x] Claimed 5 tests — actual 5 tests ✓
- [x] Both bugs fixed — verified by test pass ✓
- [x] formatter.test.ts exists — confirmed ✓

QA report: **All claims verified. No disputes.**

Expected: QA passes all claims. QA does NOT flag the unknown-format issue (that is the reviewer's domain and QA did not see the diff).

## Outcome

Human reviews:
- Reviewer: CONDITIONAL PASS (one non-blocking condition)
- QA: all claims verified

Human approves merge. Tech-lead merges worktree branch to main.

The unknown-format condition is tracked as a carry-forward item for the next phase.
```

## Quality Requirements

- The sample-project files must be syntactically correct TypeScript (they should be runnable if someone installs deps).
- The getting-started.md walkthrough must be internally consistent: every bug mentioned in Step 2 is fixed in Step 3, every fix is tested, every test appears in the QA output.
- The reviewer finding in Step 4 (unknown-format silent return) must be a REAL issue present in the `formatter.ts` fixture — not fabricated. Make sure formatter.ts actually has this behavior.
- Expected outcome statements must be precise: "reviewer should flag X" and "qa should report pass on Y" — not vague.
- File line count: getting-started.md may exceed 500 lines (it is documentation, not code). Code files in sample-project must stay under 50 lines each (they are fixtures illustrating correct sizing).

## Handoff Note

After completing all files, write `briefs/handoff-phase4.md` with:
- Files created (one-line summary each)
- Test count (there are no new tests in the main project — the sample-project tests are fixtures, not runnable in the main project)
- npm test output for the main project (run `npm test` in the repo root)
- Known limitations

## Completion Criteria

Tier 1 (non-negotiable):
- All files created at correct paths
- sample-project TypeScript is syntactically valid
- getting-started.md is internally consistent (every bug fixed, every fix tested, test counts match)
- Main project `npm test` passes

Tier 2 (judgment):
- Sample-project files are realistic (not toy code)
- Walkthrough reads naturally without prior knowledge of agent-roster
