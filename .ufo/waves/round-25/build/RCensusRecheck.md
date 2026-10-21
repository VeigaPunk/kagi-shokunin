# RCensusRecheck — C3: what S033+ feed rows must provide

Seat `KagiR25.RCensusRecheck-2`, leaf, read-only. Base `4587c61a348e4528717404a68912c373f3ef4d03`; real HEAD = base, and `SOURCES.md`, `source-fetches.tsv`, `sources-census.sh` sha256 match `corpus/stamps.tsv:74,72,73`. Axes: lane gate · fleet exit · provenance · clock. Sandbox `/fast/scratch/kagi-r25/RCensusRecheck-2` (clone at base; `var/` variants, `results/` outputs). Present: gawk 5.4.1, curl 8.23.0, Python 3.14.8, git. Installed: nothing.

## Answer
- Every registry row, any status, needs exactly one `corpus/source-fetches.tsv` row. Missing: `SC_FETCH missing-provenance` (`sources-census.sh:328`; M2, M27). Two rows: `duplicate-provenance` (:286; M28).
- S033+ MUST NOT carry an in-row `Fetch sha256:`: `SC_INROW inrow-pin-not-historical` (:322-326; M11). Only S001–S016 are exempt (:295).
- Representation: `decoded-http-body-v1` for stable bodies such as feeds (precedent `source-fetches.tsv:61-64`), or `decoded-http-body-volatile-v1` for chrome-coupled HTML (S017–S032 pattern); both pass (M3). Normalization `raw-literal-v1` needs normalized `-` (:282); `rendered-text-v1` needs a 64-hex digest (:281; M5, M5b, M6). Markup quotes locate only under raw-literal-v1: rendered text is text, not markup (`rendered-text-v1.py:52-53`).
- Fleet exit 0 needs no capture row; it needs the E-free registry constraints in §2.

## 1. Lane gate reads (`corpus/sources-census.sh` @base)
- Reads columns 2,3,4,5,8,9,12 only (:173-234). `opened` (10) and `recheck` (11) are never parsed: M15, M16, M18 are CLEAN.
- used-by split on `,` and `;` (:223); path shape `^corpus/(knowledge|lessons)/…\.md$` (:215); file must exist (:200, :228); its first column-1 `source:` line (:151) must contain the id as a token (:229-231; M12, M13).
- Duplicate URLs: not checked. Only `SC_DUP` on ids (:187-189). The lane has no W04.
- URL role: capture identity only. First `https?://` token of the source cell (:247), exact equality (:261), digest `sha256("id\tstatus\turl\n")` (:262-263; M10).

## 2. Fleet gate reads (`scripts/sources-census.sh` @base, read-only)
- Exit: any E → 1; W never changes exit (:16-18, :737-746, :805).
- E08: `opened` ISO and ≤ `--today` (:660-662; M15). E09: `recheck` = ISO | `NNd` | symbolic `^[A-Za-z][A-Za-z0-9 _-]*$` (:582, :663-667). `on-release` passes; `v3.13.3` and `on-release (sops)` fail (M16, M18).
- URL key `url_of` strips `#frag` and trailing `/`, lowercases host (:600-605). W04 (warn): URL seen under a new scope (:644-645; M21). E04 (error): same URL and exact scope as an earlier non-rejected row, unless teaches has `supersedes S###` (:646-649; M19 fail, M20 pass).
- E11: used-by split on `,` ONLY (:562, :566-567). `a.md;b.md` passes the lane and fails the fleet (M14).
- E12 row outside `## Registry` (:618-621; M22). E01 NF≠13 (:635; M23). E05/E06/E07/E10 enums (:655-668; M24). W03 only for em-dash used-by (:673; M25).

## 3. Matrix (M1 = candidate S033 mined row + capture row + lesson; one change per variant)
| variant | lane `sources-census.sh` (rc, finding) | fleet `validate kagi` (rc, finding) |
|---|---|---|
| M0 base, no change | 0 `CLEAN (rows=32 … captures=32 …)` | 0; 8×W04 + `kagi ok` |
| M1 candidate S033 | 0 `CLEAN (rows=33 A=31 … mined=30 … captures=33 …)` | 0; same 8×W04 |
| M2 / M27 no capture (M27 queued) | 1 `missing-provenance` | 0 |
| M3 volatile rep / M26 queued+capture | 0 / 0 | 0 / 0 |
| M4 rep `decoded-http-body-v2` | 1 `representation` | 0 |
| M5 rendered, digest `-` / M6 raw + digest | 1 `normalized-digest` / 1 `…-not-applicable` | 0 |
| M5b rendered + 64-hex digest | 0 | 0 |
| M7 quote 26 words · M9 location 5 · M30 bytes 0 · M31 fetched non-ISO | 1 each: `quote` `location` `bytes` `fetched` | 0 |
| M8a `/main/` URL rev `-` / M8b rev 40-hex | 1 `moving-ref-revision` / 0 | 0 |
| M10 capture URL≠registry · M28 dup capture · M29 capture status≠registry | 1 each: `url-mismatch` `duplicate-provenance` `status=queued registry=mined` | 0 |
| M11 in-row `Fetch sha256:` on S033 | 1 `SC_INROW classification-missing` + `inrow-pin-not-historical` | 0 |
| M12 used-by file absent | 1 `SC_USEDBY_MISSING` | 1 `E11` |
| M13 used-by file lacks S033 in its source line | 1 `SC_USEDBY_NOCITE` | 0 |
| M14 used-by `a.md;b.md`, both exist and cite | 0 | 1 `E11` |
| M15 opened 2026-10-22 | 0 | 1 `E08` |
| M16 recheck `v3.13.3` · M18 `on-release (sops)` | 0 · 0 | 1 `E09` · 1 `E09` |
| M17 recheck `on release` | 0 | 0 |
| M19 same URL+scope as S016 · M20 + `supersedes S016` | 0 · 0 | 1 `E04` · 0 |
| M21 known URL (S032's), new scope | 0 | 0 + `W04 S033` |
| M22 row placed after `## Paths` | 0 (counted) | 1 `E12` |
| M23 `\|` inside a cell | 1 `SC_MALFORMED nf=14` | 1 `E01` |
| M24 `community` at tier A | 1 `SC_INFLATION` | 1 `E10` |
| M25 mined, used-by `—` | 1 `SC_MINED_UNUSED` | 0 (W03 warn) |
Outputs: `results/M*.lane.txt`, `results/M*.fleet.txt`, `results/summary.json`.

## 4. Templates (M1 passes both gates)
Registry row, inside `## Registry` after S032 (`SOURCES.md:38`; `## Paths` is :40):
```
| S033 | SOPS release feed, Atom — https://github.com/getsops/sops/releases.atom | code | A | SOPS release-feed version binding (on-release clock) | feed first entry `<title>v3.13.3</title>`, entry updated 2026-07-23; opened 2026-10-21 | Latest SOPS release entry in the official Atom feed is v3.13.3, updated 2026-07-23. Quote: `<title>v3.13.3</title>` (feed entry title). | mined | 2026-10-21 | on-release | corpus/lessons/round-25.md |
```
Capture row, appended to `source-fetches.tsv` (16 TAB columns; column list `:6-35`):
```
S033	mined	8d566e39054b671b19146b938ccb811dc4e7eb3536521d719c7e738fbe8d44d8	https://github.com/getsops/sops/releases.atom	https://github.com/getsops/sops/releases.atom	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-v1	47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6	253037	-	<title>v3.13.3</title>	raw-literal-v1	-	Atom feed first entry title (tag v3.13.3)
```
Used-by `corpus/lessons/round-25.md` needs one column-1 line naming every new id, comma-separated:
```
source: S033 (https://github.com/getsops/sops/releases.atom, first entry title v3.13.3, opened 2026-10-21)
```
Recipe: `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o F -w '%{http_code} %{url_effective}' URL`; `sha256sum F`; `stat -c %s F`; quote byte count ≥1 in F. Row digest: `printf 'S033\tmined\t<url>\n' | sha256sum`. The example feed is illustrative; L1 picks the C3 feeds. Two fetches 3 s apart gave identical sha256, so `decoded-http-body-v1` is supported for this feed.

## 5. Integration items (L1; not run here)
- R21-02 pin `corpus/claim-ledger.tsv:52` fails on M1 (`re.search` no match): re-pin with the new counts.
- `corpus/stamps.tsv:74` (SOURCES.md) → M1 `8eefeb61…`, 140 lines, 31558 B. `:72` (source-fetches.tsv) → `9418e044…`, 76 lines, 20131 B. A new lessons file follows round-22..24 practice (`stamps.tsv:55-58`), which changes the `stamps` selector in `row-identity.sh` (path column); re-pin that digest. Stamp consumers: `claim-ledger.sh`, `row-identity.sh`, `revision-audit.py`.
- No `row-identity.sh` selector covers the registry or capture rows. No current-tense SOURCES row count appears in README, QUALITY or SOURCES (grep), so C1 binds only R21-02 here.
- Keep `recheck` = `on-release`. Put release identity in `corpus/release-clocks.tsv`, never in the recheck cell (M16, M18).

## 6. Run ledger (env `PATH=/usr/bin:/bin HOME=<sandbox>/home`)
- Real lane, read-only: `bash corpus/sources-census.sh` → `CLEAN (rows=32 … captures=32 …)`, exit 0.
- Sandbox: `bash corpus/sources-census.sh --selftest` → `PASS (70 cases)`, exit 0.
- Real fleet, read-only: `bash scripts/sources-census.sh validate kagi --today 2026-10-21` → 8×W04 and `kagi ok`, exit 0. `census kagi` → `FLEET rows 32`, exit 0. `overdue kagi` → cadence lines only, exit 0. All-lane `validate` → 21 `ok`, exit 0. Fleet `selftest` → `selftest ok`, exit 0. M1 census → rows 33, A 31, mined 30; overdue exit 0.
- Feed: `curl -fsSL --compressed` on `github.com/getsops/sops/releases.atom`, ×2 → HTTP 200, final URL unchanged, 253037 B, identical sha256; `<title>v3.13.3</title>` counted 1.
- UNRUN: `claim-ledger.sh` verify/cells (prohibited on the real tree; not run in sandbox), stamp gate, content checks beyond the example quote. Installs: none.
