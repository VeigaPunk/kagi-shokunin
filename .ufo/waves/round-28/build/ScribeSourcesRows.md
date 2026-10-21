# ScribeSourcesRows — round-28 SOURCES.md row templates (S044, S042 extension)

Frozen BASE `3553d499577084a6c98d7078906017840bbf7b28`. Lane `corpus/SOURCES.md` is identical to BASE (`git diff --quiet BASE -- corpus/SOURCES.md`, exit 0). No quote was fetched or verified by me: every quote, locator and digest below is a marker for the scout. Nothing here is a pass.

## Findings (path:line at BASE)

1. **S044 must be `recheck` 180d or 90d, never `on-release`.** `corpus/release-clock.py:511` and `:518` bind every `on-release` registry row to a clock; an unbound row is `UNBOUND` (`:532`) and `passed` is false (`:640`). Sandbox probe v4 (S044 set to `on-release`): `UNBOUND S044`, `RELEASE_CLOCK: FAILED (on_release=31 bound=30 unbound=1 ...)`, exit 1. Base control is `on_release=30 bound=30 unbound=0`, exit 0. The frozen C1 control line in `plans/round-28.md:42-43` would break.
2. **S044 used-by must be an existing file that names S044 on its `source:` line.** Path shape `corpus/sources-census.sh:215`; existence and citation checks `:229-231` (`src_field` at `:151`). Probe v1 (row only, no lesson): `SC_USEDBY_MISSING path=corpus/lessons/round-28.md`, exit 1. Probe v2 (lesson with `source: S044`): that finding clears.
3. **S044 needs a `corpus/source-fetches.tsv` row and must carry no in-row pin.** A row without an in-row pin needs a provenance row: `sources-census.sh:328` (`missing-provenance`). Probes v1, v2, v3 all emit `SC_FETCH id=S044 missing-provenance`, exit 1. An in-row `Fetch sha256:` on a non-historical id is `SC_INROW inrow-pin-not-historical` (`:326`); the historical set is `HIST_RE` S001–S016 (`:295`). The template below carries no pin.
4. **S042 "old→new" used-by: keep `corpus/lessons/round-27.md` and append round-28.** `sources-census.sh:354` requires every entry cited by a knowledge entry's `source:` line to be listed in the cited row's used-by. Removing the old path would break that for any knowledge entry citing S042 and erases the historical receipt (round-27 lesson `source: S042, S043`, `corpus/lessons/round-27.md:1`). Probe v3 (used-by `round-27.md, round-28.md`, lesson `source: S042, S044`): no finding beyond the missing S044 provenance row, exit 1.
5. **The plan's authority for leading zeroes is not in the registry.** `plans/round-28.md:22` cites "SemVer S042 §2". BASE S042 (`corpus/SOURCES.md:49`) locates only §11.2 ("Major, minor, and patch versions are always compared numerically."). No BASE row locates §2, so the leading-zero claim is unsupported until a row is opened. This is a plan-versus-registry defect; the templates cannot fix it by themselves.
6. **The frozen ledger pin breaks on any row addition.** `corpus/claim-ledger.tsv:52` (R21-02) pins `rows=43 A=41 B=0 C=2 queued=1 mined=39 rejected=3 entries_sourced=4 legacy=21 captures=43 inrow=16 inrow_only=0 inrow_nonreproducing=12`; the base census reproduces it exactly (commands below). INFERENCE for one added mined tier-A row with one provenance row: `rows=44 A=42 B=0 C=2 queued=1 mined=40 rejected=3 entries_sourced=4 legacy=21 captures=44 inrow=16 inrow_only=0 inrow_nonreproducing=12`. `entries_sourced` and `legacy` should not move, because the entry loop reads only `corpus/knowledge/*.md` (`sources-census.sh:335`). Probe v1 printed `rows=44`, confirming the row count only.
7. **The Python limit row's content is unverified; the lane's bound must not follow the runtime setting.** [INFERENCE, scout to confirm] CPython's integer-string conversion limit is runtime-configurable (`sys.set_int_max_str_digits`, env `PYTHONINTMAXSTRDIGITS`), so a bound read from the running interpreter would make the C1 finding host-dependent. The S044 teaching should cover both the default and the setting, so the lane pins a constant.
8. **The URL cell must carry no fragment.** The census takes the URL as the first `https?://[^ |]+` in the source cell (`sources-census.sh:247`) and requires it to equal the TSV URL (`:261`), with the identity digest at `:262`. Existing rows use fragment-free URLs (e.g. S040, `corpus/SOURCES.md:47`). A section anchor belongs in the anchor cell.

## Template: S044 (mined, tier A, recheck 180d)

Insert after `corpus/SOURCES.md:50` (S043), before the blank line at `:51`:

```
| S044 | Python integer-string conversion length limitation — <URL: TO-BE-FILLED-FROM-SCOUT; lead https://docs.python.org/3/library/stdtypes.html, unverified> | docs | A | CPython int↔str conversion digit limit (ValueError above the limit); default and runtime setting as documented | <section heading and anchor as served: TO-BE-FILLED-FROM-SCOUT>; Python 3.15.1 documentation, fetched 2026-10-21 | <teaching sentence: TO-BE-FILLED-FROM-SCOUT>. Quote: “<TO-BE-FILLED-FROM-SCOUT>” (<locator: TO-BE-FILLED-FROM-SCOUT>). | mined | 2026-10-21 | 180d | corpus/lessons/round-28.md |
```

Rules: 11 cells (NF=13 with edge pipes, `:191`); no `Fetch sha256:`; tier `A` (official documentation); `recheck` not `on-release` (finding 1); exactly one repo path in used-by (finding 2). The URL cell must equal the TSV URL column byte for byte.

## Template: S044 provenance row (`corpus/source-fetches.tsv`, 16 tab-separated columns)

```
S044<TAB>mined<TAB><IDENTITY><TAB><URL><TAB><FINAL-URL><TAB>200<TAB>curl-fsSL-compressed-v1<TAB>2026-10-21<TAB>decoded-http-body-volatile-v1<TAB><RAW-SHA256 TO-BE-FILLED><TAB><BYTES><TAB>-<TAB><QUOTE ≤25 words TO-BE-FILLED><TAB>rendered-text-v1<TAB><NORMALIZED-SHA256 TO-BE-FILLED><TAB><LOCATION ≥8 chars TO-BE-FILLED>
```

`<IDENTITY>` is `printf 'S044\tmined\t%s\n' "$URL" | sha256sum` (`:262`; the trailing newline is part of the key). Compute it only after `<URL>` is fixed. Checks: 16 columns (`:287`), URL equality (`:261`), status (`:260`), `curl-fsSL-compressed-v1` (`:266`), `decoded-http-body-v1` or `-volatile-v1`, 64-hex digests, bytes `[1-9][0-9]*`, rev `-`, quote ≤25 words, `rendered-text-v1` with a 64-hex normalized digest, location ≥8 characters.

## Option A (recommended): S042 scope extension as a new appended row S045

Finding 4 and the convention in `corpus/SOURCES.md:19-32` (S022–S026 "supersedes" rows) favour appending. Because BASE S042 locates only §11.2, the §2 teaching needs its own located quote:

```
| S045 | Semantic Versioning 2.0.0, §2 version format — https://semver.org/spec/v2.0.0.html | spec | A | Canonical X.Y.Z cores: non-negative integers with no leading zeroes (scope extension of S042 to §2 only) | §2 Version Format, as served; fetched 2026-10-21 | supersedes S042 for the leading-zero scope only; §11.2 numeric precedence stays with S042. Quote: “<TO-BE-FILLED-FROM-SCOUT>” (§2). | mined | 2026-10-21 | 180d | corpus/lessons/round-28.md |
```

Its provenance row shares S042's URL (`corpus/source-fetches.tsv:85`) but needs its own S045 row with its own quote. The census keys provenance by id (`:287`, `:328`), so two ids on one URL are legal. S042 stays `mined` with used-by `corpus/lessons/round-27.md` unchanged. Rows become 45 and the R21-02 pin moves again (finding 6).

## Option B (only if L1 rejects a new row): in-place used-by extension of S042

Change only the used-by cell at `corpus/SOURCES.md:49` to:

`corpus/lessons/round-27.md, corpus/lessons/round-28.md`

Probe v3 passes the census for this with the round-28 lesson citing `S042, S044`. Caveat: no §2 locator is added, so the leading-zero claim stays unregistered (finding 5). It also departs from the append-only supersession convention used since round 22.

## Lesson header (`corpus/lessons/round-28.md`, lines 1–3, mirroring `corpus/lessons/round-27.md:1-3`)

```
source: S044[, S045]
verified-at: 2026-10-21 — <TO-BE-FILLED-FROM-SCOUT: fetch method and rendered-text-v1 locator result>
recheck: 180d — re-open the Python documentation page and re-run the C1 measurement after any change to corpus/release-clock.py
```

The `source:` line must contain `S044` (`sources-census.sh:230-231`). A lesson file is not a knowledge entry and is not counted by `entries_sourced`.

## Paths bullet (`corpus/SOURCES.md`, after BASE `:64`)

```
- **Canonical version tokens (round 28)** — S044 (+ S045 under Option A): the CPython integer-string limit documentation bounds token length; leading-zero canonicality is a separate claim; feed rows S033–S039 stay the observed identities.
```

## Search-log entry (`corpus/SOURCES.md`, after BASE `:76`)

```
Round 28 (2026-10-21): question — which primary sources ground the canonical version-token rule (leading zeroes; component length bound) and the Python integer-string conversion limit? Where searched — <TO-BE-FILLED-FROM-SCOUT: exact URLs opened>. Identified <N>, screened <N>, included <N>, excluded <N>. Stop: <TO-BE-FILLED-FROM-SCOUT>.
```

## Commands run (sandbox only; lane checkout not written)

Sandbox: `.ufo/waves/round-28/sandboxes/ScribeSourcesRows/` (`base`, `v1`–`v4`, `build/row-S044.txt`, `build/row-S042-extension.txt`).

| command | exit | result |
|---|---|---|
| `git show 3553d…:corpus/SOURCES.md \| grep -n "S04[0-9]"` | 0 | S042 `:49`, S043 `:50`, `## Paths` `:52` |
| `git diff --quiet 3553d… -- corpus/SOURCES.md` | 0 | lane file equals BASE |
| `git archive 3553d… \| tar -x -C …/base` | 0 | sandbox base |
| `bash corpus/sources-census.sh` (sandbox base) | 0 | `CLEAN (rows=43 A=41 B=0 C=2 queued=1 mined=39 rejected=3 entries_sourced=4 legacy=21 captures=43 inrow=16 inrow_only=0 inrow_nonreproducing=12)` |
| `python3 -I -B corpus/release-clock.py` (sandbox base) | 0 | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| v1 census (row, no lesson) | 1 | `SC_USEDBY_MISSING path=corpus/lessons/round-28.md`; `SC_FETCH id=S044 missing-provenance`; rows=44 |
| v2 census (+ lesson `source: S044`) | 1 | `SC_FETCH id=S044 missing-provenance` only |
| v3 census (+ S042 used-by extension; lesson `source: S042, S044`) | 1 | same single finding |
| v4 `release-clock.py` (S044 `on-release`) | 1 | `UNBOUND S044`; `FAILED (on_release=31 bound=30 unbound=1 …)` |
| v4 census | 1 | same as v1 |
| `python3 --version` | 0 | Python 3.14.8 (sandbox interpreter) |

Probes v1–v4 are drafts, not gate passes. Each census probe exits 1 because no provenance row exists, which is expected for an unfilled template. No network fetch was made.

Tools installed or updated: none.

## Not checked

- No page was fetched; no quote, anchor, URL, date or digest for S044 or S045 was verified. The `stdtypes.html` URL is a lead from memory.
- A clean S044 result (zero findings) was not shown, because the provenance row needs real digests.
- `captures=` and `inrow=` after a valid S044 row are INFERENCE from the verdict path (`sources-census.sh:355-366`), not measured.
- `src_field` and `cred_scan` (`sources-census.sh:151`, `:155`) were read, not exercised on wrapped `source:` continuation lines.
- `--selftest` was not run; the R21-03 case count is not re-verified.
- The sibling scout `KagiR28.SrcPythonIntBuiltin-7` owns the S044 locator and quote. I did not read its output and did not message it.
- Whether frozen C1 fixtures F1–F4 depend on any row beyond S044 was not checked.
