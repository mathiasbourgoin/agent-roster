# Review Brief — Phase 4: Synthetic End-to-End Example

## Scope

Phase 4 adds a synthetic end-to-end walkthrough for the agent-roster harness. No existing source files were modified. All changes are new files.

## Files Added

- `docs/examples/getting-started.md` — 5-step walkthrough guide
- `docs/examples/fixtures/sample-project/package.json`
- `docs/examples/fixtures/sample-project/tsconfig.json`
- `docs/examples/fixtures/sample-project/src/index.ts`
- `docs/examples/fixtures/sample-project/src/parser.ts`
- `docs/examples/fixtures/sample-project/src/formatter.ts`
- `docs/examples/fixtures/sample-project/tests/parser.test.ts`
- `briefs/handoff-phase4.md`

## Checklist

### Content correctness
- [ ] Every bug described in getting-started.md Step 2 is present in the corresponding fixture file (correct file + correct line)
- [ ] Every fix described in Step 3 corresponds to a real, non-trivial change
- [ ] Test counts in Step 3 (5 tests) match test counts in Step 5 (5 tests)
- [ ] The reviewer finding in Step 4 (unknown-format silent return) is a real behavior in formatter.ts — not fabricated
- [ ] QA report in Step 5 does NOT reference the diff or reviewer findings (context isolation preserved in the narrative)

### Internal consistency
- [ ] Bug line numbers cited in the guide match actual line numbers in the fixture files
- [ ] All tests listed in the handoff note are described in the guide

### Code quality (fixtures only)
- [ ] Each fixture source file is under 50 lines
- [ ] No fixture file has dead code or unreachable paths beyond the intentional bugs
- [ ] TypeScript is syntactically valid (strict mode compatible)

### Documentation quality
- [ ] getting-started.md has explicit expected outcome statements ("reviewer should flag X", "qa should report pass on Y")
- [ ] Guide is self-contained: a reader with no prior agent-roster knowledge can follow it
- [ ] No placeholder URLs left unflagged (the GitHub URL placeholder is a known limitation per handoff)

## Handoff Note

See `briefs/handoff-phase4.md`.

## Verdict Format

Return one of: PASS / CONDITIONAL PASS / FAIL  
List each finding with: severity (blocking/non-blocking), location (file:line), description, remediation.
