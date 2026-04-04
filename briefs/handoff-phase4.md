# Handoff — Phase 4: Synthetic End-to-End Example

## Files Created

- `docs/examples/fixtures/sample-project/package.json` — name: sample-cli, scripts: build (tsc) and test (node --test), devDependency: typescript only
- `docs/examples/fixtures/sample-project/tsconfig.json` — strict, ES2022, NodeNext module, outDir dist
- `docs/examples/fixtures/sample-project/src/index.ts` — CLI entry point, uses parseArgs + formatOutput, ~30 lines
- `docs/examples/fixtures/sample-project/src/parser.ts` — parseArgs with intentional bug #1: argv.slice(1) at line 20 (should be slice(2)), ~45 lines
- `docs/examples/fixtures/sample-project/src/formatter.ts` — formatOutput with intentional bug #2: item.length at line 14 (should be i+1), plus real silent-return-empty-string for unknown format, ~28 lines
- `docs/examples/fixtures/sample-project/tests/parser.test.ts` — 2 tests (default count, --count flag); missing: invalid --count test, all formatter tests, ~25 lines
- `docs/examples/getting-started.md` — end-to-end walkthrough guide (5 steps + outcome), internally consistent

## Test Count

No new tests were added to the main project. The sample-project test files are fixtures (documentation), not runnable from the repo root. The main project test suite is unchanged at 32 tests.

## npm test Output (main project)

```
> agent-roster@0.0.0 test
> npm run build:ts && node --test dist/scripts/build-index.test.js

# tests 32
# suites 7
# pass 32
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 106.738504
```

All 32 tests pass.

## Known Limitations

1. **sample-project is not runnable without npm install.** TypeScript is listed as a devDependency but not installed in the fixture directory. The brief specifies this is intentional (do not run npm test on the sample-project).

2. **parser.ts bug subtlety.** With slice(1), the node executable path is dropped but the script path becomes argv[0] after slicing. The test for `--count 5` still passes because the flag is still found later in the array — the bug manifests as the first positional argument being silently consumed, not as a hard failure. This is accurate to real-world off-by-one argv bugs and is noted in the test file comments.

3. **getting-started.md references a GitHub URL placeholder.** The Prerequisites section contains `https://github.com/your-org/agent-roster` — this should be updated when the repo URL is known.

4. **No carry-forward issue filed.** The unknown-format condition flagged by the reviewer is described as a carry-forward item in the guide but no actual issue tracker entry exists. A follow-up phase brief should formalize this as Tier 1.
