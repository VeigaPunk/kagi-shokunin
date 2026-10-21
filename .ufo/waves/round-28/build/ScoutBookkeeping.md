# ScoutBookkeeping — rows that move when `corpus/release-clock.py` changes and its selftest grows

BASE `3553d499577084a6c98d7078906017840bbf7b28`, read from a `git archive` extract under
`.ufo/waves/round-28/sandboxes/KagiR28.ScoutBookkeeping-7/base`. Line numbers are BASE.

## Findings

**F1 — No `KN-*` row cites the clock; that part of the premise is empty.**
`grep -rn 'RELEASE_CLOCK\|release-clock' corpus/knowledge/*.md` → no match, exit 1. The 22
`KN-*` rows (`corpus/self-counts.tsv:58-79`) bind other gates. Outside `.ufo/` wave evidence,
the clock case count lives in exactly four lane files: `SKILL.md:48`, `PROVINCE.md:54`,
`corpus/claim-ledger.tsv:82`, and `corpus/lessons/round-27.md:242` (measured history — never
edit). The plan requires the round-28 *lesson* to cite the new registry row, not a knowledge
entry.

**F2 — README "Round-27 active contracts" is appended to, not retitled.** `corpus/README.md:217`
stays; the Round-26 heading `:194` survives beside it, so round 28 appends
`## Round-28 active contracts` after `:228` (file is 228 lines). README's live numbers are the
index rows `:64` ("65 rows" = `RD-LEDGER-ROWS`, self-counts:46) and `:65` ("90 rows" =
`RD-STAMPS`, self-counts:47), plus `:67` (25/22/3, self-counts:48-50). Counterexample:
`:219-220` "now also binds 22 … eight `knowledge/*.md` entries" is a current-tense number with
**no** binding row (all 60 rows checked; none locates it). If the KN population changes it
falsifies silently — use round-27's pointer convention (`corpus/lessons/round-27.md:53-60`) or
add a row (R25-02 `claims=60`→`61`).

**F3 — The clock table must not move; the token rule must keep `v1.21.x`.** 15/15 `derived:`
rows already satisfy C2 against their feed row's anchor cell (cells[5]), verified with the
shipped `version_is_named`: S033→3.13.3 4×, S034→2.2.0 4×, S035→2.7.1 6×, S037→8.23.0 1×.
So `corpus/stamps.tsv:78` (`99a9b4bc…`, 31 lines / 5944 B) and R25-04's expectation stay
byte-identical, which is what preserves the frozen `CLEAN (… fired=3 derived=15)` control.
C1 traps: `corpus/release-clocks.tsv:9` (S012) `anchored_version=v1.21.x` is legal, named by
its own SOURCES row, and declared a limit at `release-clock.py:369-380` — a strict-X.Y.Z
token grammar types it and breaks `fired=3`. S037's *teaches* prose names `8.23.1` while its
*anchor* names `8.23.0` (`corpus/SOURCES.md:43`): bind the anchor cell, never the note text.

**F4 — `corpus/stamps.tsv` has no self-row** (`:25` is the hermetic fixture's stamp file), so
do not add one. Membership grows only by new tracked paths; the plan's only new path is
`corpus/lessons/round-28.md`, inserted at **line 70** (C-order: after round-27, before round-4;
`LC_ALL=C sort -c` on the path column passes at BASE). `.ufo/**` is outside stamps (0 `.ufo`
rows at BASE), so the frozen `.ufo/waves/round-28/tools/*-measure.py` need no stamp row.

**F5 — Keep the ledger command text verbatim** `python3 corpus/release-clock.py [--selftest]`:
`corpus/claim-ledger.sh:263` refuses `python3 -I -B corpus/…` and `:281` refuses `--observe`.

## Rows to move (BASE path:line → field → change)

| path:line | field | now → change |
|---|---|---|
| `corpus/stamps.tsv:77` | sha/lines/bytes | `53823416…` / 1758 / 75422 → new clock digest + `wc -lc` |
| `corpus/stamps.tsv:70` (new) | full row | insert `corpus/lessons/round-28.md` + digest + `wc -lc` |
| `corpus/stamps.tsv:5,2,7,8` | sha/lines/bytes | SKILL.md, PROVINCE.md, corpus/README.md, corpus/SOURCES.md |
| `corpus/stamps.tsv:13,84,85` | sha/lines/bytes | claim-ledger.tsv, self-counts.tsv (if a row is added), source-fetches.tsv |
| `corpus/stamps.tsv:3,1` | sha/lines/bytes | SCORECARD.md (new heading), LOG.md (append) |
| `corpus/stamps.tsv:6` | sha/lines/bytes | QUALITY.md only if a QM27 row follows `:133` (QM25/26 precedent) |
| `corpus/stamps.tsv:78,83` | — | **unchanged** unless release-clocks.tsv / self-counts.py are edited |
| `corpus/claim-ledger.tsv:82` (R25-03) | `expect`, `note` | `PASS \(79 cases\)` → `(N cases)`; note append "Round 28 (C1/C2): +k -> N (migration .ufo/waves/round-28/expectation-migrations.json)" |
| `corpus/claim-ledger.tsv:83` (R25-04) | `note` only | expect **unchanged** (`on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15`); note append the C2 anchor binding and the unmoved table |
| `corpus/claim-ledger.tsv:28` (R12-03) | `expect`, `note` | `^90$` → `^91$`; "+ corpus/lessons/round-28.md -> 91" |
| `corpus/claim-ledger.tsv:68` (R24-05) | `expect` | `count=90 sha256=b88b27f4…` → `count=91 sha256=14663dcd2ee9f3528c6c233cf426f13b6db93ca9767eda0758fd7a2196d4b264` (measured; sole new path) |
| `corpus/claim-ledger.tsv:29,69` (R13-01/R24-06) | `expect` | `^33$`→`^34$`; `count=33`→`count=34` + measured sha |
| `corpus/claim-ledger.tsv:52` (R21-02) | `expect` | one tier-A mined row: `rows 43→44 A 41→42 mined 39→40 captures 43→44`; `queued=1 rejected=3 entries_sourced=4 legacy=21 inrow*` unchanged — measure |
| `corpus/claim-ledger.tsv:57,78` (R22-03/R24-15) | `expect` | `added=27`→`28`; `count=27`→`28` + measured sha (needs a git root) |
| `corpus/claim-ledger.tsv:54,77` (R21-04/R24-14) | `expect` | unchanged `65` unless new `R28-*` rows; then +N + sha |
| `corpus/claim-ledger.tsv:81` (R25-02) | `expect` | unchanged `claims=60` unless a self-counts row is added |
| `corpus/claim-ledger.tsv:80,23,50` | `expect` | unchanged 48 / 170 / 170 unless binder or ledger gain cases |
| `SKILL.md:48` | decision-table row | "`--selftest` 79 cases" → N; add canonical-token and derived-binding clauses to the command/avoid cells |
| `SKILL.md:787` | registry row | no count; add S0xx + `corpus/lessons/round-28.md` to Evidence |
| `PROVINCE.md:54` | final sentence | "`--selftest` proves 79 cases" → N; add the canonical-token/derived-binding sentence |
| `corpus/self-counts.tsv:22,38` | — | SC-/PV-CLOCK-SELFTEST rows are unchanged text; they read `ledger:R25-03`, so both doc numbers must equal the live output (declared C1↔C2 edge, `SCORECARD.md:1107`) |
| `corpus/SOURCES.md:51` (new S0xx) | row | `used-by` must name an existing file containing the literal id (`sources-census.sh:228-231`): the lesson must cite it |
| `corpus/source-fetches.tsv:87` (new) | row | one capture row per registry id (43 ids / 43 rows at BASE) |
| `SCORECARD.md:1108+` | new section | `## Round 28 …` + measured outcome; do **not** edit `:1091`, `:1094`, `:1100-1107` (round-27 history, append-only) |
| `LOG.md:1529+` | append | round-28 entries; no count bound to LOG |
| `corpus/lessons/round-28.md` (new) | header | `source:` names the new id; `recheck:` names the clock selftest as round-27 did |

Adjacent conditional: `R14-01` (`claim-ledger.tsv:32`) and `RD-DOCS-*` (`self-counts.tsv:48-50`)
move only if a **knowledge** entry is added (25 entries / 22 row-linked / 3 by-hand).

## QM5 and QM14

- **QM5** (`corpus/QUALITY.md:43`): bytes + every stamp row + claim-row edits in one commit;
  `verify` before commit, or the QM12 (`:60`) substitute lists skipped host rows by id.
- **QM14** (`corpus/QUALITY.md:73`): write `.ufo/waves/round-28/expectation-migrations.json`
  in the round-27 shape (`.ufo/waves/round-27/expectation-migrations.json`): `format`
  (`kagi-round28-expectation-migration-v1`), `base`, `ledger_rows{ID:{old,new}}` with **full
  TSV lines**, `stamp_membership{before:90, after:91, added:["corpus/lessons/round-28.md"],
  dropped:[]}`.
- **QM18** (`:100`): count rows are membership rows — re-pin R12-03↔R24-05, R13-01↔R24-06,
  R21-04↔R24-14, R22-03↔R24-15 together.
- **QM21/QM26** (`:118`, `:133`): any new current-tense number in SKILL/PROVINCE/README needs a
  `self-counts.tsv` locator; R25-02 and the docs counts move with it.

## Commands run (sandbox extract only; never the lane checkout)

- `python3 -I -B corpus/release-clock.py --selftest` → `PASS (79 cases)`, exit 0;
  default → `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0.
- `python3 -I -B corpus/self-counts.py --selftest` → `PASS (48 cases)`, exit 0;
  `python3 -I -B corpus/self-counts.py` → `CLEAN (claims=60 stale=0)`, exit 0 (17.6 s).
- Derived probe (import `release-clock.py`; `version_is_named(src[feed]["anchor"], anchored)`
  over the 15 `derived:` rows) → 15/15 True, exit 0.
- `bash corpus/row-identity.sh stamps` → `count=90 sha256=b88b27f4…`, exit 0; on a probe copy
  with the round-28 lesson added → `count=91 sha256=14663dcd…`, exit 0.
- `python3 -c 'sys.version; sys.get_int_max_str_digits()'` → 3.14.8, 4300 (grounds the 4301-digit fixture).
- `grep -rn 'RELEASE_CLOCK\|release-clock' corpus/knowledge/*.md` → no match, exit 1.
- `python3 -I -B corpus/revision-audit.py --history c2cab…` → `ROOT-NOT-REPOSITORY`, exit 2
  (no `.git` in the archive), so `added=28` and the R24-06/R24-15 digests were **not** measured.

## What I did NOT check

- No frozen `c1-measure.py`/`c2-measure.py` run and no fixture execution; no lane-checkout
  command; no `claim-ledger.sh verify|cells|docs`.
- Did not derive N (new selftest count), post-landing R21-02 values, or R24-06/R24-15 digests.
- Did not decide whether a QM27 row, a knowledge entry, or `R28-*` ledger rows will be added;
  each conditional row above names its trigger.
- No tool installs or upgrades were needed.
