# Pipeline Contract

Standard delivery chain for all phases. No phase merges to `main` without completing this pipeline.

## Roles

| Role | Agent | Receives | Produces |
|------|-------|----------|----------|
| Implementer | worktree implementer | Requirements + relevant source files | Code changes + passing `npm test` + handoff note |
| Reviewer | reviewer agent | Diff + review brief + handoff note | Findings (pass / conditional pass / fail) |
| QA | QA agent | Requirements + handoff claims | Independent `npm test` run + claim verification |
| Human | Mathias | Reviewer findings + QA report | Merge decision |

## Pipeline Steps

### Step 1: Implementation (worktree implementer)

1. Receive phase requirements from tech-lead.
2. Work in an isolated worktree branch (`worktree-agent-<id>`).
3. Implement changes. Respect code quality rules (500-line file max, 50-line function max, 4-level nesting max).
4. Run `npm test` locally. All tests must pass (exit code 0).
5. Produce a handoff note containing:
   - Files changed (with one-line summary per file).
   - Tests added or modified (count and description).
   - Known limitations or deferred items.
   - Exact `npm test` output (pass count, fail count).

Tier 1 gate: `npm test` passes. No merge without green tests.

### Step 2: Review (reviewer agent)

1. Receive from tech-lead: the diff, the review brief, and the handoff note.
2. Do NOT receive: prior conversation context, implementation discussion, or QA results.
3. Check the diff against the review brief checklist.
4. Produce findings with one of three verdicts:
   - **PASS**: All checklist items verified. No blocking issues.
   - **CONDITIONAL PASS**: Non-blocking issues found. List each with severity and remediation. Implementation may proceed but issues must be tracked.
   - **FAIL**: Blocking issues found. List each. Implementation must not merge.
5. Findings must reference specific lines/functions, not general impressions.

### Step 3: QA (QA agent)

1. Receive from tech-lead: phase requirements and the handoff claims.
2. Do NOT receive: the diff, reviewer findings, or implementation discussion.
3. Run `npm test` independently on the worktree branch.
4. Verify each handoff claim:
   - Does the claimed test count match actual?
   - Do the described behaviors actually work?
   - Are there silent failures or warnings in test output?
5. Produce a QA report: claims verified / claims disputed / independent findings.

QA and Review may run in parallel since they have disjoint inputs.

### Step 4: Human Gate (Mathias)

1. Receive from tech-lead: reviewer findings + QA report.
2. Merge decision criteria:
   - Reviewer verdict is PASS or CONDITIONAL PASS with all conditions accepted.
   - QA report confirms handoff claims.
   - No unresolved Tier 1 failures (tests, build, lint, typecheck).
3. If FAIL: tech-lead routes back to implementer with specific remediation items.
4. If CONDITIONAL PASS with unaccepted conditions: tech-lead routes back to implementer.
5. Merge executes only after explicit human approval.

## Context Isolation Rules

Each role receives only what is listed in "Receives" above. This is not optional.

- Implementer does not see reviewer or QA output from prior phases (unless explicitly routing a fix).
- Reviewer does not see QA output or implementation discussion.
- QA does not see the diff or reviewer output.
- Human sees the synthesized findings, not raw agent conversation.

Rationale: prevents confirmation bias, ensures independent verification, reduces context window waste.

## Handoff Format

All handoffs between pipeline steps use a structured file written to `briefs/`:

```
briefs/handoff-phase<N>.md    -- implementer -> tech-lead
briefs/review-phase<N>.md     -- tech-lead -> reviewer (review brief)
briefs/findings-phase<N>.md   -- reviewer -> tech-lead (findings)
briefs/qa-phase<N>.md         -- QA -> tech-lead (QA report)
```

## Failure Modes

| Failure | Action |
|---------|--------|
| `npm test` fails in implementer step | Implementer fixes before handoff. No handoff with red tests. |
| Reviewer returns FAIL | Tech-lead routes findings to implementer. New implementation cycle. |
| QA disputes handoff claims | Tech-lead routes QA report to implementer. Handoff note must be corrected. |
| Human rejects merge | Tech-lead captures rejection reason and routes to appropriate step. |
| CI failure after merge | Tech-lead inspects logs, classifies, fixes root cause. No blind reruns beyond one retry. |

### Step 5: Session Closure (tech-lead)

1. Write a phase report to `reports/phase<N>-<date>.md` (under 60 lines, precise).
2. Report includes:
   - What merged (commits, files changed, tests added).
   - Reviewer verdict and any conditional findings.
   - Carry-forward items for the next phase.
   - Next phase entry point (which files to read first).
3. Tell the user the session is done and they can close it safely.
4. The report is the only context that needs to survive the session boundary. No conversation state carries forward.

Rationale: each session starts fresh from a report, not from a polluted conversation. This enforces context hygiene across session boundaries.

## Applies To

All remaining phases (2 through 5) and any future phases added to the plan.

Phase 1 is retroactively reviewed under `briefs/review-phase1.md` but was not gated by this pipeline (merged before pipeline was established).
