# Round-28 review — SOURCES.md contract boundary for C1's new row and C2's derived-anchor binding

Axes: **freshness**, **calibration**. Lane paths cited at BASE `3553d499577084a6c98d7078906017840bbf7b28`; the registry
contract is fleet-root `CORPUS.md` §"SOURCES.md — where a shokunin learns" (contract v1, kaika 2026-10-19, frozen) at
fleet HEAD `c2e2913`. No lane file was modified; all mutations ran on copies under `.ufo/waves/round-28/sandboxes/RevSourcesContract-7/`.

## F1 HIGH — C1's authority "SemVer S042 §2" is not carried by S042, and §2 is not the leading-zero rule
- `plans/round-28.md:21-22` grounds canonical tokens ("no leading zero in a multi-digit component") on "SemVer S042 §2".
- `corpus/SOURCES.md:49` (S042): scope = "Precedence of strict MAJOR.MINOR.PATCH version cores: numeric, left-to-right
  comparison; prerelease/build suffixes excluded from the core"; anchor = "§11 Precedence, item 11.2"; teaches = numeric
  ordering only ("only the numeric core ordering is used"). `corpus/source-fetches.tsv:85` locates its quote at "§11.2
  (…precedence item 11.2)". **S042 carries no leading-zero prohibition and its anchor is not §2.**
- `corpus/SOURCES.md:50` (S043) does not close the gap: scope = "numeric per-component comparison; shorter segments
  zero-padded (supporting ordering evidence only)"; its teaches records the zero-padding rule as **not** implemented
  (`corpus/source-fetches.tsv:86`). Zero-padding of *shorter segments* is not a ban on a leading zero inside a component.
- Contract v1 rule 2 (`CORPUS.md:116-118`): only `status`/`recheck`/`used-by` change in place; **a correction is a new row
  whose `teaches` opens `supersedes S0NN —`.** S042's anchor/scope cannot be widened in place → C1 needs a new row (own Gate
  row + capture row) or a plan correction. S042/S043 `used-by` may still gain `corpus/lessons/round-28.md`.

## F2 HIGH — C2 must bind to the feed row's **anchor cell** only; the `derived:` scope is load-bearing
Measured (`derived-binding.py`): all 15 derived rows' `anchored_version` equals the single X.Y.Z token of their feed
row's anchor cell — S033→3.13.3 (S008–S011), S034→2.2.0 (S013, S022–S024), S035→2.7.1 (S014–S016, S021, S025, S026), S037→8.23.0 (S029). Counterexamples the implementation must not walk into:
- **teaches-cell scanning is wrong**: `corpus/SOURCES.md:40` (S034 teaches) names `sdk/v0.26.0`; `:43` (S037 teaches) names curl's development label `8.23.1`. Only column 6 (`anchor`, `CORPUS.md:99`) is the located anchor.
- **unscoped rule breaks S012**: `corpus/release-clocks.tsv:9` anchors `v1.21.x` against feed S034, whose anchor names
  2.2.0. Only rows whose note starts `derived:` may be bound (QM23, `corpus/QUALITY.md:120`; prefix test
  `corpus/release-clock.py:565`); `:566` `anchor_ok = is_derived or version_is_named(...)` is the hole C2 closes.
- **containment ≠ equality**: `version_is_named` (`corpus/release-clock.py:341-346`) asks "does the anchor contain the
  version"; C2 asks "is the version the anchor names". Every feed anchor cell names exactly one X.Y.Z token at BASE.

## F3 HIGH — what a **new row** must carry
1. **Columns** (11, `CORPUS.md:86-107`): `id` (`S`+3+ digits, next unused, never reused, no `|` in any cell — `CORPUS.md:89`),
   `source` (title — canonical URL), `kind`, `tier`, `scope`, `anchor` (exact section + revision, never a bare homepage),
   `teaches`, `status`, `opened` (ISO), `recheck` (ISO or `90d`/`180d`/`on-release`), `used-by` (repo-relative paths or `—`).
2. **Gate row** (rule 1, `CORPUS.md:112-115`): the round lesson's `## Gate` records, per new row, **URL + access date + a
   ≤25-word quote with its location**, grounding `teaches`; the row is written only after the source was opened in the
   writing round (precedent `corpus/lessons/round-27.md:16,25-26`). A rejected row's teaches reads `REJECTED: …; flip: …`.
3. **Provenance row** (lane `SC_FETCH`, `corpus/sources-census.sh:236-289`): one `corpus/source-fetches.tsv` row, 16 columns,
   `row_identity_sha256` = sha256 of `id<TAB>status<TAB>url<LF>`, exact registered URL, final URL, 3-digit status, profile
   `curl-fsSL-compressed-v1`, ISO fetched date, representation, sha256 + byte count, ≤25-word quote, normalization profile,
   normalized sha256 (rendered-text-v1 only), location ≥8 chars. **No in-row `Fetch sha256:`** — that exemption is S001–S016
   only (`corpus/sources-census.sh:295,322-326`).
4. **used-by**: the path must exist (fleet `E11`) and carry the row id on the file's `source:` line (lane `SC_USEDBY_NOCITE`,
   `corpus/sources-census.sh:151,230-231`); shape exactly `corpus/(knowledge|lessons)/<name>.md` (`:215,227`). Plus a
   `## Search log` note (rule 5, `CORPUS.md:126-128`), a `## Paths` line, and `## Mistakes` + "a fix able to fail" if the lesson mines mistakes (`CORPUS.md:171-181`).

## F4 HIGH — census codes a new row trips (measured; fleet `scripts/sources-census.sh`, lane `corpus/sources-census.sh`)
| mutation (new row S044 unless noted) | fleet | lane | clock |
|---|---|---|---|
| compliant new row (new URL, `90d`, capture row, citing lesson) | rc=0, **W04 still 11** | rc=0 CLEAN rows=44 | CLEAN `on_release=30` |
| same URL + **same scope** as S042, no `supersedes` | **rc=1 `E04`** duplicate url within scope | rc=1 | CLEAN |
| same URL + new scope, teaches opens "supersedes S042 —" | rc=0, **W04 12** | rc=1 | CLEAN |
| used-by a not-yet-existing file | **rc=1 `E11`** | rc=1 `SC_USEDBY_MISSING` | CLEAN |
| row-shaped line outside `## Registry` | **rc=1 `E12`** | rc=0 (lane blind here) | CLEAN |
| a `|` inside a cell | **rc=1 `E01`** | rc=1 `SC_MALFORMED` | **rc=2 SETUP** ("12 fields, expected 11") |
| no capture row | rc=0 | rc=1 `SC_FETCH missing-provenance` | CLEAN |
| in-row `Fetch sha256:` on a post-S016 row | rc=0 | rc=1 `SC_FETCH`+`SC_INROW` | CLEAN |
| `opened` 2026-10-22 | **rc=1 `E08`** | rc=1 | CLEAN |
| `kind community` + `tier A` | **rc=1 `E10`** | rc=1 `SC_INFLATION` | CLEAN |
| `tier C` + `mined` + used-by | rc=0 **`W01`** | rc=1 | CLEAN |
| `recheck 18-10-21` | **rc=1 `E09`** | rc=1 | CLEAN |
Codes: fleet `scripts/sources-census.sh:24-33` (E01–E12, W01–W04; W04 `:645`, E04 `:649`, E11 `:566-567`, E12 `:620-621`);
lane `corpus/sources-census.sh:25-70`. **`E04` is the error a same-page correction row trips**; E01/E08/E09/E10/E11/E12 are
errors (exit 1); W01–W04 are warnings (exit 0). Fleet `E11` tests path existence only; the lane also requires the exact `corpus/(knowledge|lessons)/<name>.md` shape (`corpus/sources-census.sh:215,227`).

## F5 MED — the W04 count moves; the two censuses are not equivalent
BASE fleet validate = **exactly 11 `W04` lines + `kagi ok`, exit 0** (S019, S020, S021, S022, S023, S025, S026, S032, S039,
S040, S041) — matching `plans/round-28.md:9`'s "11 W04" and `corpus/lessons/round-27.md:252,262`. A new row reusing a
registered URL **with a different scope** adds a 12th W04 line (measured); the lane already carries the undercounted-W04
counterexample (round-23: seven vs five). The END census must quote every W04 line verbatim and state the count — and it
must run the **fleet** validator, because a row-shaped line outside `## Registry` passes the lane gate (rc=0) and fails
the fleet gate (`E12`, rc=1).

## F6 MED — a new `on-release` row breaks the plan's frozen control
Measured: a registry row with `recheck: on-release` and no clock row → `UNBOUND S045`, `RELEASE_CLOCK: FAILED
(on_release=31 bound=30 unbound=1 observed=30 fired=3 derived=15)`, **exit 1**; the frozen control (`plans/round-28.md:43`)
expects `on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15` exit 0. C1's new row must take `90d`/`180d` and
must **not** be added to `corpus/release-clocks.tsv`; if it is added as a clock row the frozen control changes (30→31).

## F7 MED — the lesson's `source:` line must name every id whose used-by cites it
`SC_USEDBY_NOCITE` reads the used-by file's first `source:` line (`corpus/sources-census.sh:151,230`). Measured: adding `corpus/lessons/round-28.md` to a row's used-by while the lesson's `source:` line omits that id → `FINDING SC_USEDBY_NOCITE id=S1000 path=…`, exit 1. The lesson must open `source: S042, S043, <new ids>`.

## F8 LOW — id space: contract `S[0-9]{3,}` vs the clock's `S[0-9]{3}`
`CORPUS.md:89` allows 3 **or more** digits; `corpus/release-clock.py:29,76` matches exactly three. Measured: a 4-digit id
row is counted by the census (rows=44) but is **silently invisible to the clock** (`on_release=30`, exit 0). Named debt at
`corpus/lessons/round-27.md:173` ("ids stop at S043"); a feed row past S999 would silently lose its C2 binding.

## The asked deliverable — a used-by change vs a scope change of S042/S043
- **`used-by` change (in place, allowed)**: edit only that cell; log it **old→new** in the round lesson
  (`CORPUS.md:116-118`) in the Gate's registry-cell line — precedent `corpus/lessons/round-27.md:30` ("**Existing registry
  cells (status/recheck/used-by), old → new:** none."). The new path must exist (fleet `E11`) and the cited file must carry
  the id on its `source:` line (lane `SC_USEDBY_NOCITE`). `status`/`recheck` may change in place the same way; `scope`,
  `anchor`, `teaches`, `kind`, `tier` may **not**.
- **`scope`/anchor change (NOT in place)**: a new row whose `teaches` opens `supersedes S0NN —` (`CORPUS.md:117-118`), with
  its own tier-A anchor for the new scope (QA1, `corpus/QUALITY.md:20`), Gate row and capture row; the old row stays as
  history (round-22/23 precedent: S019/S020/S022/S023/S025/S026 each supersede rather than edit).

## Commands run (exits)
| command (cwd) | exit | result |
|---|---|---|
| `git archive 3553d49 \| tar -x -C …/sandboxes/RevSourcesContract-7/base` | 0 | BASE tree (all lane runs below are in that copy) |
| `python3 -I -B corpus/release-clock.py --root .` ; `bash corpus/sources-census.sh` (sandbox BASE) | 0 ; 0 | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` ; `CLEAN (rows=43 … captures=43 …)` |
| `bash …/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | 11 `W04` + `kagi ok` |
| `python3 -I -B battery.py` (15 mutated copies; fleet `--file` + lane + clock per case) | 0 | the F4 table |
| `python3 -I -B derived-binding.py` | 0 | 15/15 derived rows bind to one anchor-cell token; only S012 out of scope |

## What I did NOT check
- **No source was opened and no network fetch was made** (no semver.org / packaging.python.org / docs.python.org read):
  F1's claim that S042/S043 carry no leading-zero prohibition is read from the registry rows and their recorded capture
  quotes, not from a re-read of the pages. The SemVer item number stating that rule is **[INFERENCE]**.
- I did not run the round-28 tools (`c1-measure.py`, `c2-measure.py`), the claim-ledger/self-counts/stamps gates, the
  `overdue`/`shared` fleet census modes, or the clock `--observe` path (network); and I wrote no round-28 lesson text,
  Gate row, used-by log line or `corpus/knowledge/` entry (the `corpus/lessons/round-28.md` in my battery is a throwaway
  fixture inside my sandbox).
- No LSP device is mounted (`xd://lsp` → "No such tool"), so caller/definition/diagnostics were done by reading and grep —
  text evidence, not semantic proof. The only consumer of registry rows in the clock is `parse_sources`
  (`corpus/release-clock.py:58-97`) → `evaluate` (`:502-641`), read in full.
- No tools installed or upgraded (no pacman/uv/cargo); python3 from PATH only. I did not check sibling lanes' registries
  (fleet `shared` mode) nor the round-28 START census file's contents (only that the validator prints 11 W04 at BASE).
- Observed, not mine: an untracked `corpus/__pycache__/release-clock.cpython-314.pyc` appeared in the lane checkout at
  14:14 (my runs were `python3 -I -B` inside my sandbox); whoever created it should remove it from the read-only tree.
