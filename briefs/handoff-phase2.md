# Phase 2 Handoff

## Commits

1. `fix: address reviewer carry-forward gaps from Phase 1`
2. `refactor: split build-index.ts into 6 modules (scripts/lib/)`

## Files Changed

### Commit 1 (carry-forward fixes)

- `scripts/build-index.ts` — exported `IndexEntry`, `SourceCache`, and `ComponentType` types; added comment to `parseFrontmatter` documenting indented-line silent-drop behavior
- `scripts/build-index.test.ts` — replaced local `IndexEntry`/`SourceCache` type definitions with `import type` from `build-index.js`; added 3 new tests (see below)

### Commit 2 (module split)

- `scripts/build-index.ts` — rewritten as slim CLI entry point (~274 lines); re-exports the public surface from lib modules; retains `run()`, `collectLocalMarkdownFiles()`, `mapLimit()`, `parseArgs()`
- `scripts/lib/types.ts` (new, 35 lines) — shared types: `ComponentType`, `IndexEntry`, `RemoteSource`, `SourceCache`
- `scripts/lib/frontmatter.ts` (new, 106 lines) — `parseFrontmatter`, `parseLooseMetadata`, `parseInlineArray`, `parseScalar`
- `scripts/lib/infer.ts` (new, 156 lines) — `inferComponentType`, `inferComplexity`, `inferDomainBySource`, `inferCompatible`, `inferCompatibleFromText`, `inferCatalogCompatible`, `inferCatalogComponentType`, `tokenize`, `unique`, `deriveDomainFromPath`
- `scripts/lib/normalize.ts` (new, 141 lines) — `normalizeEntry`, `enrichRemoteEntry`, `fallbackRemoteEntry`, `sanitizeName`, `firstMarkdownHeading`, `firstDescriptionLine`
- `scripts/lib/remote.ts` (new, 230 lines) — `fetchText`, `fetchJson`, `fetchJson`, `toRawUrl`, `resolveCandidatePath`, `parseMarkdownLinks`, `parseMarkdownLinkPairs`, `matchesPatterns`, `collectRemoteCandidates`, `collectCatalogEntries`, `sortEntries`
- `scripts/lib/cache.ts` (new, 62 lines) — `readSourceCacheRecord`, `writeSourceCache`, `fingerprintParts`, `fingerprintCandidates`, `chooseBestSourceEntries`, `sourceCacheFile`

## Tests Added

3 new tests added in commit 1 (32 total, up from 29):

1. `parseFrontmatter > indented continuation lines are silently dropped, rest parses correctly` — verifies multi-line YAML block scalar drop behavior
2. `parseFrontmatter > CRLF line endings parse the same as LF` — verifies `\r\n` delimiter handling
3. `chooseBestSourceEntries > null cache and empty refreshed returns empty array` — verifies `(null, [])` returns `[]`

## npm test Output

```
# tests 32
# suites 7
# pass 32
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 99.64765
```

## Known Limitations / Deferred Items

- `sortEntries` ends up in `scripts/lib/remote.ts` rather than staying in `build-index.ts` as the brief suggested; this avoids a circular import since `collectCatalogEntries` in `remote.ts` calls it. It is re-exported from `build-index.ts`. No behavior change.
- `toRawUrl` is private to `remote.ts` but imported in `build-index.ts` via the module — it is not re-exported in the public surface since tests do not need it.
- `RemoteSource` type moved to `lib/types.ts`. The brief did not mention it explicitly but it is needed by both `remote.ts` and `build-index.ts`.
- Test file still imports from `./build-index.js` rather than directly from lib module paths. This is intentional — `build-index.ts` re-exports everything, so the test's import path remains stable if modules are reorganized further.
