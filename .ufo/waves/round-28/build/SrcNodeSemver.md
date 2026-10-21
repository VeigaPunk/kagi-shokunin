# SrcNodeSemver — node-semver README source opening (round-28 SOURCES curation)

Item: prior art for **strict vs loose parsing and leading-zero handling**. Access date **2026-10-21**; lane BASE `3553d499577084a6c98d7078906017840bbf7b28`.

## Verdict

**ACCEPT as tier B** (kind `docs`, status `mined`) with the narrowed scope below. **REJECT** citing this page as authority for *core* `X.Y.Z` leading-zero canonicality: its only explicit leading-zero sentence is prerelease-scoped (`README.md:410-411`) and it delegates the definition of a version to semver.org (`README.md:140-142`). The core rule stays on the spec row `corpus/SOURCES.md:49` (S042) — F5.

## Findings

**F1 — page and raw README are one document at the pin.** The raw README at `main`, at commit `7257c14239476205b4b0bf7e47b07b3e7a517be6`, and at `master` is byte-identical (25669 B, sha256 `f1a789dcec285150be24db2ea04dd3175031554fa9834ec92fab83fb5e025a57`); the page payload carries `"currentOid":"7257c14…"` (1 occurrence) equal to the `ls-remote` head, so the opening observed exactly one revision.

**F2 — the page capture is representation-volatile; the declared-profile capture is the attestation.** Two page fetches differ by 4 bytes (`469f22…`/487542 vs `c1c080…`/487546) but normalize to the *same* digest (`24fc18…`). Declare `decoded-http-body-volatile-v1`, as S041–S043 do (`corpus/source-fetches.tsv:85`).

**F3 — the prior art is implementation evidence, not this README.** At the pin: `internal/re.js:59` `NUMERICIDENTIFIER = '0|[1-9]\\d*'` (strict) vs `:60` `NUMERICIDENTIFIERLOOSE = '\\d+'`; `MAINVERSION` `:71-73` vs `MAINVERSIONLOOSE` `:75-77`; the constructor numbers the components (`classes/semver.js:62-64`) and re-formats `${major}.${minor}.${patch}` (`:98`). Probe of published `semver@7.8.5` (sandbox-only install; Node v24.21.0, npm 11.19.0): `valid('3.15.01')` → `null`; `valid('3.15.01',{loose:true})` → `'3.15.1'`; `compare('3.15.01','3.15.1',{loose:true})` → `0`; strict `compare` **throws TypeError**; `valid('1.2.3-00')` → `null`, loose → `'1.2.3-0'`; `valid('1.2.3+00')` → `'1.2.3'`. This is round-27's “leading-zero equality” debt: canonicalize or reject, never string-compare raw tokens. The README alone does not state the core rule; citing it for that is a scope overreach.

**F4 — the README's leading-zero statement is prerelease-scoped.** `README.md:410-411`: “Prerelease identifiers (`pre`) use `nr` for numeric parts, which disallows leading zeros (e.g., `1.2.3-00` is invalid).” `README.md:411-413` says build metadata *allows* leading zeros (`1.2.3+00` valid). The production is `README.md:399` (`nr ::= '0' | ['1'-'9'] ( ['0'-'9'] ) *`); the core `X.Y.Z` production has no leading-zero sentence anywhere in the page.

**F5 — calibration adjacency (outside my item, flagged for L1).** `plans/round-28.md:22` cites “no leading zero in a multi-digit component, SemVer S042 §2”, but S042's registered anchor/scope are §11.2 precedence only (`corpus/SOURCES.md:49`: `§11 Precedence, item 11.2`; quote about numeric comparison). Widen S042's anchor/scope or open a §2 anchor; S044 cannot stand in — it does not state the core rule. At BASE there is also **no** row for the plan's stated C1 source, the Python integer-string conversion limit doc (`grep -c -i 'int_max_str\|integer-string\|int-string' corpus/SOURCES.md` → 0, exit 1).

**F6 — no duplicate URL.** `github.com/npm/node-semver` occurs **0** times in `corpus/SOURCES.md` (exit 1) and 0 times under `corpus/` or `plans/`; none of the 11 W04 warnings in `.ufo/waves/round-28/census-start.txt:2-12` names it, so no W04 pair arises.

**F7 — do not register the raw markdown under `rendered-text-v1`.** The normalizer is an HTML tag stripper (`corpus/rendered-text-v1.py:67-79`); on the raw README it deletes angle-bracket spans and loses the Range Grammar note (`locate node-semver-readme.md 'Be more forgiving …'` → `count=0`, exit 1; `'Prerelease identifiers'` count 0). The raw file is usable only under `raw-literal-v1`, whose quote must be a single-line byte-exact fragment (`grep -nF` confirms `README.md:422`). The page capture is the clean target: the quote and the prerelease note each locate once (`count=1`, exit 0).

## Quote (18 words, ≤25) and locator

> Be more forgiving about not-quite-valid semver strings. (Any resulting output will always be 100% strict compliant, of course.)

Locator: **`## Functions` (`README.md:416`) → `loose` option bullet (`README.md:422-424`)**, page anchor `#functions`. Located in the declared capture with `python3 -I -B rendered-text-v1.py locate node-semver-page-compressed.html '<quote>'` → `count=1`, exit 0. The markdown wraps `loose` in backticks (syntax, not content) and breaks the line after “of”; the quoted form is the rendered text, verbatim under the normalizer's declared whitespace collapse.

## Titles

- README H1 (`README.md:1`): `semver(1) -- The semantic versioner for npm`
- Page `<title>`: `GitHub - npm/node-semver: The semver parser for node (the one npm uses) · GitHub`; repository tagline: `The semver parser for node (the one npm uses)`

## Access record (bytes under `.ufo/waves/round-28/sandboxes/SrcNodeSemver/`)

| what | value |
|---|---|
| page GET | `https://github.com/npm/node-semver#readme` → HTTP **200**, exit 0; fragment is client-side, server sees the bare path |
| page body, plain curl | 487542 B, sha256 `469f22f0fd2814aa9d3a1a0f9ab460d527eeb13791af7ee327d4961b6cd61ad7` |
| page body, declared profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` | **487546 B**, sha256 `c1c080855f80faaa924a2c456857b4134c1ec91837fd657108be73f7f1593870` |
| page normalized (rendered-text-v1) | 27928 B, sha256 `24fc18913e8dc8dd484eaf6f777f04c42202ee651a6645cf8dfe422b569f818b` — identical for both page captures |
| raw README / pin | `main`, `master`, and commit copies all HTTP 200, 25669 B, sha256 `f1a789…`; `package.json` at pin says `semver 7.8.5`; `git ls-remote` exit 0 → `main` = `7257c14239476205b4b0bf7e47b07b3e7a517be6` |

## Proposed registry row (11 columns; no `|` inside cells)

- **id**: S044
- **source**: node-semver README — https://github.com/npm/node-semver
- **kind**: docs
- **tier**: **B** — vendor README of the reference implementation, non-normative: it defines a version by pointing at semver.org v2.0.0 (`README.md:140-142`); A fits only a claim narrowed to “node-semver's own behaviour”, which is not the round's rule
- **scope**: Node/npm semver strict-versus-loose parsing design and prerelease-leading-zero rule; no core X.Y.Z canonicality claim
- **anchor**: §Functions, `loose` option (#functions); default-branch README at commit 7257c14239476205b4b0bf7e47b07b3e7a517be6, page fetched 2026-10-21
- **teaches**: Loose parsing is more forgiving about not-quite-valid semver strings while any resulting output stays 100% strict-compliant; the README's only explicit leading-zero sentence is prerelease-scoped (`pre` uses `nr`: `1.2.3-00` invalid, `1.2.3+00` valid) and core version definition is delegated to semver.org v2.0.0, so it is prior art, not the core-token rule. Quote: “Be more forgiving about not-quite-valid semver strings. (Any resulting output will always be 100% strict compliant, of course.)” (§Functions, `loose`).
- **status**: mined (or `queued` if the lesson does not yet cite S044)
- **opened**: 2026-10-21
- **recheck**: 180d
- **used-by**: corpus/lessons/round-28.md

`SC_USEDBY_NOCITE` requires `corpus/lessons/round-28.md` to carry `S044` on its `source:` line; otherwise use `queued` with used-by `—`.

## Proposed capture row (`corpus/source-fetches.tsv`, 16 tab-separated columns)

```
S044	mined	2fa201e080e76ad2e9d0f9287506856f921538c3c3c4426546213b1cb7632fa4	https://github.com/npm/node-semver	https://github.com/npm/node-semver	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	c1c080855f80faaa924a2c456857b4134c1ec91837fd657108be73f7f1593870	487546	7257c14239476205b4b0bf7e47b07b3e7a517be6	Be more forgiving about not-quite-valid semver strings. (Any resulting output will always be 100% strict compliant, of course.)	rendered-text-v1	24fc18913e8dc8dd484eaf6f777f04c42202ee651a6645cf8dfe422b569f818b	Functions, loose option (#functions)
```

`row_identity_sha256` = `printf 'S044\tmined\thttps://github.com/npm/node-semver\n' | sha256sum` → `2fa201e0…2fa4`; `SC_FETCH` recomputes the same (`corpus/sources-census.sh:259-286`). Quote word count 18 (`wc -w`). The URL cell is extracted by `https?:\/\/[^ |]+` (`corpus/sources-census.sh:247`), so keep `#readme` in the anchor, not the URL.

## Commands run (sandbox; exits)

| command | exit |
|---|---|
| `curl -sS -L https://github.com/npm/node-semver#readme` | 0 (HTTP 200) |
| `curl -sS -L https://raw.githubusercontent.com/npm/node-semver/{master,main}/README.md` | 0, 0 |
| `curl -sS -L .../7257c14…/README.md` | 0 (identical) |
| `git ls-remote https://github.com/npm/node-semver refs/heads/master refs/heads/main` | 0 (`main` only) |
| `curl -fsSL --compressed -A '<profile UA>' https://github.com/npm/node-semver` | 0 (487546 decoded B) |
| `python3 -I -B rendered-text-v1.py digest node-semver-page-compressed.html` | 0 (`24fc18…`, 27928) |
| `python3 -I -B rendered-text-v1.py locate node-semver-page-compressed.html '<quote>'` | 0 (`count=1`) |
| `python3 -I -B rendered-text-v1.py locate node-semver-readme.md '<quote>'` | 1 (`count=0`, F7) |
| `npm install --prefix . semver@7.8.5` (sandbox only; no host tool install) | 0 |
| `node -e '…valid/parse/compare probes…'` | 0 |
| `grep -c 'github.com/npm/node-semver' corpus/SOURCES.md` | 1 (count 0) |
| `grep -c -i 'int_max_str\|integer-string\|int-string' corpus/SOURCES.md` | 1 (count 0) |

No pacman/uv/global installs; `semver@7.8.5` exists only in the sandbox `node_modules`. No lane gate, selftest, or production file was touched.

## What I did NOT check

- No lane census/gate run (`corpus/sources-census.sh`); the proposed rows are unvalidated until L1 runs it.
- No browser/JS-rendered DOM check; only the decoded HTML capture was normalized.
- No CHANGELOG/releases/tag inspection for a released-version anchor; the pin is a branch commit, not a release.
- No probes of `clean()`, range/hyphen parsing, or `coerce()` beyond the listed calls.
- No repeated-fetch drift measurement; only two page captures (same normalized digest).
- S042's §2 sentence itself was not re-read; F5 concerns the registered row's anchor.
