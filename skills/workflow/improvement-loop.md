---
description: Run a bounded verification-first improvement loop from an approved loop spec.
version: 1.0.0
---

# Improvement Loop

Execute a **bounded** self-improvement loop using a user-approved loop spec supplied in $ARGUMENTS.

This skill is for controlled iterative improvement, not open-ended autonomy.

## Required Inputs

Before doing any work, extract or confirm:

- `Objective:`
- `Writable scope:`
- `Metric:`
- `Verify:`
- `Max iterations:`

Optional:

- `Read-only context:`
- `Guard:`
- `KB basis:`

If any required field is missing or too vague to execute safely, stop and ask the user to complete the loop spec.

## Setup

### 1. Validate Safety

- Read `AGENTS.md`, `README.md`, and any relevant project instructions
- If `kb/` exists and the loop references KB, read the referenced KB files first
- Confirm the writable scope is narrow enough to reason about
- If the repo is dirty in ways unrelated to the loop scope, warn the user before proceeding
- Prefer running on a disposable feature branch; if not on one, tell the user the risk

### 2. Read The Full Relevant Context

- Read all in-scope source files
- Read all verification-relevant test files and configuration
- Read all read-only context documents listed in the loop spec

### 3. Establish Baseline

- Run the verify command before any changes
- Run the guard command too, if provided
- Record baseline results in a simple log at:

```text
improvement/<date>-<slug>/results.tsv
```

Use tab-separated columns:

```text
iteration	status	metric	verify	guard	note
```

Log baseline as iteration `0`.

If the verify command is broken in a way that prevents comparison, stop and report that the loop cannot run safely.

## Execution Loop

Run exactly `Max iterations` iterations unless:

- the objective is achieved early, or
- the loop becomes unsafe or invalid

For each iteration:

1. Pick **one focused change** within the writable scope
2. Make the change
3. Run `Verify`
4. Run `Guard` if provided
5. Compare against the baseline or prior kept state
6. Decide:
   - **Keep** if the metric improves or the binary target condition is met and guard still passes
   - **Discard** if the metric regresses, the change is neutral with added complexity, or guard fails
7. Log the outcome to `results.tsv`

## Keep/Discard Discipline

- One meaningful change per iteration
- Do not stack multiple speculative edits before verification
- Simpler changes win when results are equal
- If a discarded iteration changed tracked files, restore only the in-scope files touched during that iteration
- Do not revert or overwrite unrelated user work
- If an iteration creates new files in scope and is discarded, remove only those new in-scope files

## Final Report

At the end, report:

- objective
- iterations run
- kept vs discarded count
- final metric vs baseline
- files changed in kept iterations
- unresolved risks
- whether a KB update or follow-up audit is warranted

## Rules

- Default to bounded loops; do not continue forever
- Never modify files outside the declared writable scope
- Never use subjective “looks better” as the primary keep rule
- Never keep a change that fails the guard command
- Never silently discard user changes outside the current loop
- If the metric cannot be measured reliably, stop rather than pretending
