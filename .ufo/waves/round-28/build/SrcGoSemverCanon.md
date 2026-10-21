# SrcGoSemverCanon — source opening: `golang.org/x/mod/semver` (round-28 curation)

Item: prior art that a canonical version token is checked before ordering. Seats advise; L1 integrates.
Opened 2026-10-21T17:06:40Z (server `date` header Wed, 21 Oct 2026 17:06:40 GMT).

## Capture (raw body saved in my sandbox)
- URL/HTTP: `https://pkg.go.dev/golang.org/x/mod/semver` → **HTTP 200**, final URL identical, no redirect.
- Bytes **65077**, sha256 **`e3618a1dc9421369b9794c32663ce0db0d37296bf04b397eb488ff6af9d0ae50`**.
- Reproduced byte-identical under the census request profile `curl-fsSL-compressed-v1` (`cmp` → no output, exit 0; same sha/bytes). `content-encoding` absent, so identity and compressed fetch agree.
- `corpus/rendered-text-v1.py digest` (exit 0): normalized_sha256 **`fbfe2fc0b3cdd9e461826b56d1decae3b870a1ee5401234d1e6ec98c64901468`**, normalized_bytes 7080.
- Exact title: **`semver package - golang.org/x/mod/semver - Go Packages`**.
- Version facts in the page header: module **v0.42.0**, `Published: Oct  9, 2026`, and the banner `This package is not in the latest version of its module.` — the bare URL serves this pinned doc version, not a floating latest.

## Findings
1. **Purpose is grounded, but only for two of its three clauses.** The page's accepted grammar excludes leading zeros, and canonical formatting is the stated basis of string equality. It does **not** ground "non-canonical tokens are rejected by ordering": `Compare` documents the opposite (see F3). The composite "canonicality is checked before ordering" is an `[INFERENCE]` from two separate sentences, not one located sentence.
2. **Primary quote (11 words, ≤25), verbatim, uniquely located:**
   > “MAJOR, MINOR, and PATCH are decimal integers without extra leading zeros”

   Locator: Documentation → **Overview (`#pkg-overview`)**, second grammar paragraph, immediately after the `<pre>` grammar line `vMAJOR[.MINOR[.PATCH[-PRERELEASE][+BUILD]]]`. `rendered-text-v1.py locate` → `count=1` (exit 0). Raw-HTML check: the sentence appears once, inside `<section class="Documentation-overview">` opened by `<h3 id="pkg-overview">`.
3. **Counterexample inside the same page (do not overclaim).** `Compare` (`#Compare`) says verbatim: “An invalid semantic version string is considered less than a valid one. All invalid semantic version strings compare equal to each other.” (`locate` count=1). So the Go package does **not** reject a non-canonical token — it silently ranks it below every valid one. C1's predicate requires a typed finding (exit 1), which is stricter than this precedent; citing this page as support for "rejection" would be false. A token like `v3.15.01` is not accepted grammatically and then sorts below `v3.15.1`, i.e. exactly the lane's string-equality bug class resolved as a quiet ordering, not a finding.
4. **Supporting verbatim sentence for the canonical-equality half** (14 words, `#Canonical`, `locate` count=1): “Two semantic versions compare equal only if their canonical formatting is an identical string.” I recommend this as a second quote in `teaches`, not as the row quote (the leading-zero sentence is the one that matches C1's defect).
5. **Grammar differs from the lane's parser — scope must say so.** The page requires a leading `v` and allows `vMAJOR` / `vMAJOR.MINOR` shorthands (“This package follows Semantic Versioning 2.0.0 (see semver.org) with two exceptions.”), while `corpus/release-clock.py:362-380` strips an optional `v` and requires exactly three numeric components (`NUMERIC_VERSION_RE` at `corpus/release-clock.py:366`). The overlap is only "multi-digit component with a leading zero is not canonical".
6. **No duplicate URL.** `grep -c -i 'golang\|pkg\.go\.dev' corpus/SOURCES.md` → **0 matches, exit 1**; `grep -n -F 'pkg.go.dev'` → exit 1. Highest registered id is S043 (`corpus/SOURCES.md:50`), so the next free id is **S044**. Adding this URL produces **no new W04 line**: W04 fires only for a URL already carried by another row (the 11 pre-existing lines are `.ufo/waves/round-28/census-start.txt:2-12`; URL duplicates already exist by design, e.g. S036/S039 on the python.org feed).
7. **Registry-scope gap this item exposes (calibration-adjacent, advice only).** `plans/round-28.md:22` cites “SemVer S042 §2” for the leading-zero rule, but S042's registered anchor is `§11 Precedence, item 11.2` and its scope is precedence only (`corpus/SOURCES.md:49`). I re-fetched `https://semver.org/spec/v2.0.0.html` (HTTP 200, 9108 bytes, sha256 `f9d4b8b1a5e9a0de6621dbbc70d69fdf05310b7a737509317b94a7bddfb9409e`) purely to check: the normative sentence is §2 item 2, verbatim “A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.” That sentence lies **outside** S042's registered anchor, so the plan's citation name does not currently cover it. I am **not** proposing a semver.org row (another seat may own it); if the lesson needs normative authority for leading-zero exclusion, this page cannot supply it.
8. **Calibration (C2) relevance: none.** The page says nothing about feed anchoring or `derived:` rows; it cannot ground C2. The 15 `derived:` rows (`corpus/release-clocks.tsv` S008–S011, S013–S016, S021–S026, S029) and the bypass at `corpus/release-clock.py:565-566` (`anchor_ok = is_derived or version_is_named(...)`) are unaffected by this source.

## Tier proposal
**B (secondary / implementation prior art).** The normative authority for canonical components is semver.org; this page documents one library's grammar and comparison choice. It is primary vendor documentation *of that library* (A would be defensible only if `teaches` were narrowed to "the Go package documents X"), but B records that it must not be cited as a versioning rule. A-tier neighbours for contrast: S042/S043 (`corpus/SOURCES.md:49-50`).

## Proposed row (for L1 to place; not written anywhere)
- `| S044 | semver package — https://pkg.go.dev/golang.org/x/mod/semver | docs | B |`
- scope: `Go x/mod/semver documented grammar and comparison: extra leading zeros excluded from the accepted form; canonical formatting defines string equality; invalid strings rank below valid ones — implementation precedent, not a versioning standard`
- anchor: `Documentation → Overview (#pkg-overview), grammar paragraph; module v0.42.0, Published 2026-10-09, page states it is not the latest version of its module; opened 2026-10-21`
- teaches: `Prior art for canonical-before-order: the accepted grammar excludes extra leading zeros and equality requires identical canonical formatting, but Compare still orders invalid strings below valid ones rather than rejecting them — it does not evidence a typed finding. Quote: “MAJOR, MINOR, and PATCH are decimal integers without extra leading zeros” (Overview, #pkg-overview).`
- status: `mined` (only if the round-28 Gate actually cites it) · opened `2026-10-21` · recheck `180d` (versioned vendor doc, no product release stream; matches S042) · used-by `corpus/lessons/round-28.md`
- Required `corpus/source-fetches.tsv` row (16 fields, `corpus/sources-census.sh:238-296`): status `mined`, url above, final url same, http `200`, profile **`curl-fsSL-compressed-v1`** (enforced at `corpus/sources-census.sh:266`), fetched `2026-10-21`, representation `decoded-http-body-v1`, sha256 `e3618a1d…ae50`, bytes `65077`, revision `-`, quote = the 11-word sentence, normalization `rendered-text-v1`, normalized sha256 `fbfe2fc0…1468`, location `Documentation → Overview (#pkg-overview), grammar paragraph`.

## REJECT?
**Not recommended.** It does ground the leading-zero/canonical-equality half, verbatim and uniquely locatable. Reject is warranted only for the stronger reading "ordering rejects non-canonical tokens", which F3 shows the page contradicts. If a reviewer wants a leaner registry, the honest alternative is: keep S042's precedence scope, add a **semver.org §2** row for the normative leading-zero sentence, and drop this B row as optional colour.

## Commands run (exit codes)
- `curl -sS -L … -o body.html` → `HTTP_CODE=200`, exit 0; `sha256sum`/`wc -c` → 65077.
- `curl -fsSL --compressed … -o body-compressed.html` → 200, exit 0; `cmp body.html body-compressed.html` → no output, exit 0.
- `python3 -I -B corpus/rendered-text-v1.py digest …` → exit 0; `locate …` (3 quotes) → `count=1`, exit 0 each.
- `grep -o '<title>[^<]*</title>'` → title above, exit 0; raw-HTML enclosing-anchor scan → `#pkg-overview`, exit 0.
- `grep -c -i 'golang\|pkg\.go\.dev' corpus/SOURCES.md` → 0, exit 1; `grep -n -F 'pkg.go.dev'` → exit 1.
- URL-duplicate scan over `corpus/SOURCES.md` (`sort | uniq -d`) → 9 pre-existing dup URLs, exit 0.
- `git show 3553d49…:corpus/SOURCES.md | sha256sum` = working-tree sha `daa3af5e…fd5f` → SOURCES.md identical to BASE, so every `corpus/SOURCES.md:49` citation is a BASE citation.
- `curl … semver.org/spec/v2.0.0.html` → 200, exit 0 (cross-check only).
- No tool installed or upgraded; no package manager touched.

## Not checked
- Did not run any lane gate, selftest, census, or `kagi` command; did not execute `corpus/release-clock.py` (no fixture, no BASE-vs-after measurement) — the C1/C2 numbers are the reviewers' business, not mine.
- Did not verify the Go **source** (`IsValid`/`Compare` implementation) — only the rendered API documentation was read; the leading-zero rejection is documented grammar, not an observed function call.
- Did not check whether a sibling seat is opening semver.org §2, and did not propose that row.
- Did not test any normalization profile other than `rendered-text-v1`, and did not hash the page's `raw-literal-v1` form.
- Did not assess pkg.go.dev's stability (whether v0.42.0 remains the served version), nor whether the module's latest version restores the package.
