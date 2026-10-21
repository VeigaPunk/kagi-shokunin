# SourceS046 — S046 (Python `int()`) source row: PASS

Candidate 62a33b1bd15217ed729df2ca40c8a30aba3076c0. Verdict: **PASS** — the registered
source/scope/anchor/teaches/status all hold against the page; the registered quote locates
count=1 under the declared normalizer; identity/bytes reproduce. Two observations, neither
falsifies the row: (a) the registered raw and normalized digests no longer reproduce against
the live page, which the row's own representation (`decoded-http-body-volatile-v1`) declares
non-binding; the entire difference is the page's rebuild stamp (2 bytes). (b) the scope's
final clause ("why int() cannot decide version canonicality") is lane inference, not page
text — reported as a wording note, not a FAIL.

## Row under test (candidate; S046 is absent at BASE)
- `corpus/SOURCES.md:53` — registry row; `git show 3553d49:corpus/SOURCES.md | grep -c '^| S046 '` → 0 (BASE), 1 (candidate).
- `corpus/source-fetches.tsv:89` — 16-field provenance row (status `mined`, sha `15ae2918…`, bytes 330313, repr `decoded-http-body-volatile-v1`, norm `rendered-text-v1`, norm-sha `f3fbf619…`).
- `corpus/lessons/round-28.md:33` — `used-by` Gate entry; quote string identical to the provenance row (checked programmatically).
- `.ufo/waves/round-28/captures/S046.body` (330313 B) + `captures/metadata.json:42` (fetched_at 2026-10-21T17:27:21Z).
- Receipt: `.ufo/waves/round-28/build/SourceS046-recapture.txt`.

## Commands run (exit codes)
1. `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o functions.html -w 'http=%{http_code} final=%{url_effective} size=%{size_download}\n' 'https://docs.python.org/3/builtins/functions.html'` → **exit 0**; http=200, final = registered URL, transfer 49005, decoded 330313 B.
2. `sha256sum functions.html` → exit 0; live raw `118795e1ab3a9274f2c81846a439b8bf98fd2148a4278e500b8cb5a8635239e6`.
3. `python3 -I -B corpus/rendered-text-v1.py digest <live>` → **exit 0**: bytes=330313, normalized_sha256 `bd4ff0339a2eef4043ad16a212edae0a358dd8c32d272f5e645b5af8128721b3`, normalized_bytes=82134.
4. `python3 -I -B corpus/rendered-text-v1.py locate <live> '<registered quote>'` → **exit 0**, `count=1`.
5. Same locate on the retained capture → **exit 0**, `count=1`.
6. `digest` on the retained capture → **exit 0**: raw `15ae2918…d2ed8` (= col 10), normalized `f3fbf619…42625` (= col 15), bytes 330313 (= col 11).
7. `printf '%s' "<quote>" | wc -w` → **17** (≤25).
8. Identity recompute `sha256("S046\tmined\t<url>\n")` → `b6658da9e54cfb3abf5c9318e3e9e6bdc295cf55bc13cb628a3d0869f61d2ed8` (= col 3).
9. `curl -sS --compressed … 'https://docs.python.org/3/library/functions.html'` → **exit 0**; http=301 → `https://docs.python.org/3/builtins/functions.html` (the row's redirect note is true).
10. `cmp <capture> <live>` → **exit 1** (differs); differing offsets only `{330060, 330062}`.
11. Normalized-text diff (`difflib`, autojunk off) → exactly 2 replaces: `'3'→'7'`, `'0'→'2'` — the footer `S046.body:2735` `Last updated on Oct 21, 2026 (13:02 UTC).` vs live `(17:22 UTC).`.
12. `python3 -I -B -c` int probes → **exit 0**: `int('010')=10`; `int('01')==int('1')` True; `int('010', 0)` raises `ValueError: invalid literal for int() with base 0: '010'`; component collapse `3.15.01 == 3.15.1` True.
13. `grep -c 'id="int"' <capture>` → 1; `grep -c 'devdocs\|/3.16/\|development' <live>` → 0 (exit 1).

## Field verification against the page
- **source** — page `<title>` = "Built-in functions — Python 3.15.1 documentation" in both the retained capture and the live body; `class int` is a section on it (`S046.body:1295` `<dt … id="int">`, unique). Matches "Built-in functions, class int".
- **scope** (leading zeros, underscores, whitespace, Unicode digits) — all four appear under `class int`: `S046.body:1323` "have leading zeros, be surrounded by whitespace, and have single underscores interspersed between digits"; `S046.body:1326` "The values 0–9 can be represented by any Unicode decimal digit"; `int(' -12_345 \n ')` → -12345 (default base) in the same section. No page-content overclaim for the parenthetical.
- **anchor** — quote is in the base-0 paragraph (`S046.body:1331-1334`: "…For base 0 … Base\n0 also disallows leading zeros: int('010', 0) is not legal, while int('010') and int('010', 8) are."), under `#int`. Accurate.
- **teaches** — page states `int('010')` (default base) is legal and `int('010', 0)` is not; probes confirm the collapse and equality claim. "never through int()" is a design conclusion explicitly referred to S045, and the consumer agrees: `corpus/release-clock.py:395-415` decides canonicality lexically (no `int()`; comment `release-clock.py:382-387`).
- **status/eligibility/draft** — registry `mined` = provenance `mined` = capture status `mined`; tier A docs, recheck 180d, opened 2026-10-21. The page is stable 3.15.1 documentation (self-canonical `<link rel="canonical">`, no development/draft/unreleased marker), so no draft qualifier is owed; the row's `decoded-http-body-volatile-v1` is the correct qualifier for a deploy-stamped live page.

## Version-drift observation (not a falsifier)
The registered capture was fetched 2026-10-21T17:27:21Z and still served the 13:02-UTC build;
my live fetch at 17:46Z served the 17:22-UTC build. Both fetches were 200 on the registered URL
and byte-identical except the two footer digits, so every registered field except the digest
pair reproduces exactly. `decoded-http-body-volatile-v1` is defined as
"[n]o cross-capture equality is enforced" (`corpus/source-fetches.tsv:19-23`); the census
shape-checks digests only (`corpus/sources-census.sh:277-284`), and no gate recomputes them
(the literal occurs only in that row, its sandbox copies, and the build seat's report
`.ufo/waves/round-28/build/SrcPythonIntBuiltin.md:18,35`). Concrete counterexample sought: a
fresh fetch under the declared profile that fails to locate the quote or changes a
scope/teaches element. Result: none — locate count=1 on the new build; only the footer stamp
moved.

## Scope wording note (LOW)
`corpus/SOURCES.md:53` scope ends "…: why int() cannot decide version canonicality". The page
never mentions versions or canonicality; the clause is the one-step consequence of default-base
`int()` accepting leading zeros and is attributed to S045 in `teaches`. It is a lane inference,
not a claim about page text — tighten to "why int() cannot preserve a leading-zero distinction"
if scope columns are read as page-content claims.

## Not checked
Other source rows (S044/S045/S047–S049) and any C1/C2 fixture behaviour; the lane census and
selftests were not run in the lane checkout (contract); no production file written; no tool
installs were needed. Old scout/build reports were not used as verification.
