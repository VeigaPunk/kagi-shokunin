# ScoutInherited — inherited red/unknown rows at base d218603

Seat: ScoutInherited (leaf, read-only). Attack target: the four inherited
red/unknown items the round reports rather than fixes — R11-08 citations, the
`cells` SKIP-SELF bound, the single-backslash policy guard, and the live-count
breadth rows. No production edit, no `verify`, no host-bound row, no install.
The only file written is this report.

## Snapshot and in-flight caveat

Base `d218603b74099ddca0bd8f869516fc41db0979bf`. The working tree was being
integrated while this audit ran (2026-10-21 01:03–01:10 -03): `git status`
showed the round-23 files modified/untracked, and the lesson changed at least
three times during the read. Hashes at the last observation:

| file | sha256 |
|---|---|
| `corpus/lessons/round-23.md` | `cf79cd0c85d981a0d062eaa306bddee4de4fc31291c81c84699e135e4be535de` |
| `LOG.md` | `b7d330298e82b15cce61ace2b496d2e66911d9241adf992f9e831d603297a290` |
| `SCORECARD.md` | `488fc9940f296d47c656d425e0467fa9bfba06a731ecc9fefa01927305f75dfc` |
| `corpus/claim-ledger.tsv` | `3634eb710fc42dbe180474ece92932f7b11bbed5f3cb2eb0ee081d58249fd9c7` |
| `corpus/claim-ledger.sh` | `c20c2d04a354b54b42cf66d2d70081a581c873f139686b0c04ee8ae02e3a3b93` |

Line numbers below are the observed bytes; the invariants (the unresolved
tokens, the guard expression, the deferred rows) are stable across the churn.

Write-path disclosure: the first `write` of this report resolved against the
session cwd and landed at
`/home/vgpnk/Projects/shokunin/.ufo/waves/round-23/falsify/ScoutInherited.md`.
It was moved to this lane path at 01:10:47 and the fleet copy removed
(`test -e` → 1). No production or sibling artifact was touched.

The LOG debt sentence was added at 01:02:31 (LOG mtime moved 00:54 → 01:02);
the lesson's C3 fixture description was corrected in-flight from a four-file /
one-row / empty-stamps description to the current five-file / two-row /
two-stamp description (`corpus/lessons/round-23.md:156-160`). The earlier
description defect is therefore cured at the snapshot; the `corpus/fx-ok.sh`
citation is not.

## Commands run and exits

All commands were run from the lane root unless noted; no command was a
`verify`, a host-bound row, or a network fetch.

| command | exit | observed |
|---|---|---|
| `bash corpus/claim-ledger.sh citations` | **1** | last line `CITATION_GATE: BROKEN (cites=1258 docs=65 unresolved=3 ephemeral=0 labeled=13)`; three UNRESOLVED lines (below) |
| `bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-22-verifier-spotcheck.md` | **1** | `CITATION_GATE: BROKEN (cites=15 docs=1 unresolved=2 ephemeral=0 labeled=0)`; only lines `:53` and `:62`; line `:52` is **not** reported |
| `bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-23.md` | **1** | one UNRESOLVED: `corpus/lessons/round-23.md:159 corpus/fx-ok.sh (local)`; plus one labelled `:147` |
| `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic ...` (exact R23-01 argv) | **0** | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)` |
| `bash corpus/claim-ledger.sh --selftest` | **0** | `SELFTEST: PASS (121 cases)`; case 73 `cells-self-row-skip exit=0`; zero cases mention `backslash` |
| `grep -cE '\[substrate\]' corpus/claim-ledger.tsv` | **0** | `11` |
| `awk -F'\t' '$0 !~ /^#/ && $2 ~ /\\/ {print NR": "$1}' corpus/claim-ledger.tsv` | **0** | only `49: R18-02` |
| exact guard expression test (heredoc, below) | **0** | single backslash allowed, two adjacent refused |
| `printf '%s' 'first second' \| tr ' ' '\n' \| while IFS= read -r t; do ...; done` | **0** | prints only `tok=[first]`; the last token is dropped |
| `test -e corpus/fx-ok.sh` | **1** | absent at lane root |
| `test -e corpus/fixtures/cells-hermetic/corpus/fx-ok.sh` | **0** | the actual fixture script exists |
| `test -e "corpus/knowledge/handler-trust-boundary.md','corpus/knowledge/janitor-env-contract.md"` | **1** | the comma-joined token does not resolve |
| `git diff d218603 -- corpus/claim-ledger.tsv \| grep -cE '^[+-](R11-08\|R16-01\|R16-03\|R17-01\|R18-02)'` | **1** (no match) | none of the five inherited rows was edited |
| `git diff --stat d218603 -- corpus/scope-gate.sh corpus/adjacency.tsv corpus/lessons/round-22-verifier-spotcheck.md` | **0** | empty: the breadth engine, pins, and the spot-check source are untouched |
| `git diff d218603 -- corpus/claim-ledger.sh` | **0** | only the Python allowlist and its comment; `:184` unchanged |
| `grep -c 'R16-01\|R16-03\|R17-01\|R18-02\|backslash\|breadth' corpus/lessons/round-23.md plans/round-23.md` | **1** (no match) | `corpus/lessons/round-23.md:0` and `plans/round-23.md:0`; the lesson and plan name none of the breadth/backslash rows |

The R23-01 argv is `corpus/claim-ledger.tsv:59` verbatim:

```text
bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
  --claims corpus/fixtures/cells-hermetic/claims.tsv \
  --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
  --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
  --docs corpus/fixtures/cells-hermetic/SCORECARD.md
```

It was run twice; both runs printed the pinned CLEAN line and exited 0.

The full citations output (`/tmp/r11-08c.out`, 53.93 s):

```text
UNRESOLVED corpus/lessons/round-22-verifier-spotcheck.md:53 corpus/lessons/round-18.md','LOG.md'] (local)
UNRESOLVED corpus/lessons/round-22-verifier-spotcheck.md:62 .ufo/waves/round-22/frozen/before/ (ufo)
UNRESOLVED corpus/lessons/round-23.md:159 corpus/fx-ok.sh (local)
CITATION_GATE: BROKEN (cites=1258 docs=65 unresolved=3 ephemeral=0 labeled=13)
```

## 1. R11-08 citations

**Parent report.** `.ufo/waves/round-23/parent-build/ClaimR11X08.md` —
Finding 1 `:38-64` (three class-shaped tokens: spot-check `:52`, `:53`, `:62`;
evidence level explicitly “**derived**, not executed”, `:60-64`), Finding 2
`:66-86`, C3 retention `:114-116`, fix recommendation `:119-134`.

**Round record.** Lesson D9 `corpus/lessons/round-23.md:131-134`: “`R11-08`
… is red at the base revision because the round-22 spot-check file adds three
class-shaped tokens that do not resolve; the row is inherited evidence, not
this round's claim, and is reported unverified instead of credited.” M23-3
`:148`; `SCORECARD.md:861` (“R11-08 red at base”); `LOG.md:1218-1220`.

**What the gate actually does at the round revision.** Exit 1 with exactly
three unresolved tokens: spot-check `:53`, spot-check `:62`, and **this
round's own** `corpus/lessons/round-23.md:159` (`corpus/fx-ok.sh`). The
scoped runs isolate the split: the untouched spot-check file yields 2, the
new lesson yields 1.

Two defects follow.

1. **The “three class-shaped tokens” attribution is not the observed cause.**
   The spot-check file has three unresolvable tokens (`:52`, `:53`, `:62`),
   but the scanner drops the final whitespace token whenever the line does not
   end in whitespace (the common case): the loop is fed by
   `printf '%s' "$content" | tr ' ' '\n'`
   (`corpus/claim-ledger.sh:562`, `:593-594`), with no trailing newline, so
   `while IFS= read -r t` skips the final token at EOF. Line `:52`'s
   comma-joined token is the last token on its line and is silently skipped.
   Demonstrated: `printf '%s' 'first second' | tr ' ' '\n' | while IFS= read
   -r t; do printf 'tok=[%s]\n' "$t"; done` prints only `tok=[first]`. The
   trace confirms line `:52` never reaches `cite_target`, while `:53` does.
   The joined path is absent
   (`test -e "corpus/knowledge/handler-trust-boundary.md','corpus/knowledge/janitor-env-contract.md"` → 1).
   So at the base revision the gate is red from **two** reported tokens, not
   three; the parent's 3 is a derived count that includes an unevaluated
   token. The parent labels it derived (`ClaimR11X08.md:60`); the round
   repeats it without that caveat.
2. **The round does not merely inherit the red.** `corpus/lessons/round-23.md`
   is new this round and is part of `default_docs` (`corpus/lessons/*.md`);
   its `corpus/fx-ok.sh` citation is lane-root-relative and absent. The
   fixture-relative path is
   `corpus/fixtures/cells-hermetic/corpus/fx-ok.sh` (exists, exit 0). At the
   round revision, one of the three observed unresolved tokens is authored by
   this round, so “the row is inherited evidence, not this round's claim” is
   incomplete: the row is red for two inherited tokens plus one
   self-authored token, and it would still be red after fixing both
   spot-check lines.

**Verdict: defect (attribution and completeness), not a false claim of a
pass.** The round honestly says “reported unverified instead of credited”,
and it does not claim R11-08 is fixed. But its cause statement and its
“inherited, not this round's” framing are not accurate at the round revision.

**Bound the claim must state.** R11-08 remains red at the round revision
(exit 1; expected CLEAN/0). The observed red set is spot-check `:53`, `:62`,
and `corpus/lessons/round-23.md`'s `corpus/fx-ok.sh` citation; the spot-check
`:52` token is additionally unresolvable but hidden by the scanner's
last-token skip. Any fix must address all four tokens and the scanner bug,
and must not quote the parent's derived `unresolved=3` as an executed count.

## 2. `cells` SKIP-SELF

**Parent report.** `ClaimR11X08.md:66-86` (Finding 2: a scored freshness cell
cites R11-08, `cells` skips it, and the CLEAN predicate excludes
`CL_SELF_SKIP`), C3 retention `:114-116`, fix `:131-133`. Corroborated by
`ClaimR15X02.md:149-170` and `ClaimR11X05.md:85-87`.

**Round record.** Lesson D9 `:127-130`: “`CELL_AUDIT: CLEAN` with
`self_skipped>=1` does not verify that row.” M23-3 `:148`: “reported as
unverified; the hermetic fixture deliberately cites no self-invoking row, and
the real-tree claim is not made.” `SCORECARD.md:861`; `LOG.md:1219`.

**Measured.** The exact R23-01 argv exits 0 with the pinned CLEAN line and
`self_skipped=0 rows_run=2` (run twice). The fixture's `claims.tsv` holds
`R90-01` (script) and `R90-02` (grep count), neither containing
`claim-ledger.sh`; the fixture scorecard cites those two and
`corpus/adjacency.tsv`. The selftest passes 121 cases; case 73
`cells-self-row-skip` asserts only `SKIP-SELF R3-01`, not the CLEAN line with
`self_skipped=1`.

**Verdict: confirmation of an honest bound, with two residuals.**

- The round states the false-clean bound correctly and does not launder it.
  It also correctly keeps the fixture free of self-invoking rows and pins
  `self_skipped=0`, so the fixture cannot reproduce the false-clean.
- Residual 1: the round's own post-move operability cell
  (`SCORECARD.md:841`) cites `R23-01`, whose command contains
  `claim-ledger.sh`; by the skip predicate (`corpus/claim-ledger.sh:816-819`)
  a real `cells` run will `SKIP-SELF R23-01` and still print CLEAN, because
  the failure predicate (`:1006`) excludes `CL_SELF_SKIP`. The 9→9
  operability evidence is therefore verified by direct execution (which I
  did), **not** by the cell audit. D9's general sentence covers this, but the
  round does not apply it to its own cell. [Derived from code; no real
  `cells` run was made.]
- Residual 2: no test pins CLEAN with `self_skipped>=1`. Case 73 asserts the
  skip line only; the false-clean mechanism the round reports remains
  untested. The same last-token shape also exists in the stamp-path loop
  (`:764-774`), so a cell whose last whitespace token is a stamp path can
  evade the stamp check; the fixture's freshness cell ends with a table
  delimiter, so this run is not affected.

**Bound the claim must state.** `CELL_AUDIT: CLEAN` does not verify a
self-skipped row; the round's operability cell is itself an instance; the
fixture proves the hermetic path only, and `self_skipped` must never be read
as coverage.

## 3. Single-backslash policy guard

**Parent report.** `.ufo/waves/round-23/parent-build/ClaimR18X02.md:92-131`
— the documented “no backslash” contract (`corpus/claim-ledger.sh:93`,
`:182-183`; `corpus/knowledge/claim-ledger.md:86`, `:348`) is not
implemented: `:184` is `[[ $c == *'\\'* ]]`, which refuses only **two
adjacent** backslashes. R18-02 is the only ledger command containing a
backslash (`:112`), so tightening the guard would turn it into
`POLICY … reason=backslash` exit 2 (`:116-121`); fix at `:127-131`.

**Round record.** `SCORECARD.md:861-862` names “the single-backslash policy
guard” in the remaining-debt list; `LOG.md:1219` names it in the inherited
list. The lesson and plan contain no mention (`grep` exit 1 for `backslash`
and `R18-02`). The round did not change `:184` (`git diff` shows only the
Python allowlist/comment).

**Measured.** Exact expression test:

```text
len=4 value=g\it -> allowed
len=12 value=the-jan\itor -> allowed
len=4 value=a\\b -> refused
len=5 value=a\\\b -> refused
```

`grep -cE '\[substrate\]' corpus/claim-ledger.tsv` = 11, exit 0; only
R18-02's command column contains a backslash (`awk` scan). The selftest has
121 cases and zero mention `backslash`, so neither the single-backslash
admission nor the double-backslash refusal is pinned.

**Verdict: named, not recorded.** The round does not falsely claim the guard
works, but it does not record the parent finding either: a reader of the
three-word debt label cannot tell that the documented refusal is absent, that
only `\\` is refused, that R18-02 is the sole legitimate user, or that fixing
the guard requires rewriting R18-02 in the same change. The lesson — the
durable explanation — is silent.

**Bound the claim must state.** R18-02 green (count 11) proves only the tag
cardinality; it does not exercise the guard. Any statement that command
safety refuses backslashes must say “two adjacent backslashes only”; any fix
to `:184` must rewrite R18-02 and add a single-backslash refusal case plus
the bracket-form admission case.

## 4. Live-count breadth rows

**Rows.** `R16-01` (`corpus/claim-ledger.tsv:39`, `bash
corpus/scope-gate.sh`), `R16-03` (`:41`, `--falsify`), and `R17-01`
(`:45`, `--breadth`), all tagged `[substrate]`. `R16-02` (`:40`), `R17-02`
(`:46`) and `R17-03` are static/selftest rows, not live-count rows.

**Parent reports.**

- `ClaimR16X01.md:56-75` — R16-01 is a mixed row; deferral is too broad and
  too narrow; it parks the fleet-layout and R13 host-count obligations,
  including three roots owned by other lanes. `:77-106` gives the
  false-clean: deferral hides sibling-lane basis decay; `:194-208` records
  the stale “live” note and the missing `--pin` re-measure requirement.
- `ClaimR16X03.md:47-70` — the note's “two breadth mutations measure live
  host counts” undercounts: **four** cases are host-count-bound
  (`breadth-children-drift`, `breadth-exceeds`, `breadth-declared-drift`,
  `breadth-new-declared-child`); on the committed 2026-10-20 counts the row
  cannot PASS (`caught ≤ 16/18`). `:93-110` records the deferral proxy and
  the DEFER→FAIL flip when the handler returns.
- `ClaimR17X01.md:62-93` — deferral is refuted for R17-01: the tag parks
  non-substrate roots (`.config/opencode`, `.agents`, chrome-profile) and
  hides measured drift; `:134-162` requires C3/C1 to state that R23-01
  discharges no part of R17-01; `:164-220` gives the consumer-visible risk.

**Round record.** `LOG.md:1218-1220` names “live-count breadth rows” as
inherited debt. The lesson and plan contain no mention of R16-01, R16-03 or
R17-01 (`grep` count 0). `SCORECARD.md:844` says “inherited parent findings
are reported, not absorbed”, but the cell cites only `corpus/adjacency.tsv`
and `R17-02`; it names none of the three live-count rows or their findings.
The remaining-debt list (`SCORECARD.md:859-862`) omits live-count breadth
entirely.

**Measured.** None of the three rows was edited by the round (`git diff`
target grep: 0 matches); `scope-gate.sh` and `adjacency.tsv` are unchanged
(`git diff --stat`: empty); all three remain `[substrate]`; the R23-01
fixture claims only `R90-01`/`R90-02` and contains no `scope-gate.sh` row
(fixture `claims.tsv`), so C3 does not execute or discharge any breadth
obligation. The round's own `cells` fixture pins `row_deferred=0`.

**Verdict: class named in LOG, findings not recorded.** The round does not
claim the breadth rows passed, but the generic “inherited parent findings are
reported” sentence is not substantiated for this family. The lesson and the
debt list omit them; a reader cannot learn from the round record that the
`--falsify` note's “two” is four cases, that R17-01 parks three
non-substrate roots, or that the handler's return turns DEFER into FAIL.
This is an honesty gap in the report, not a false pass.

**Bound the claim must state.** C3/R23-01 discharges none of R16-01, R16-03,
R17-01; the live counts remain unverified since the 2026-09-29 CLEAN
(`ClaimR17X01.md:51-60`) and the 2026-10-14 DEFECT; a handler-only return
would fail the rows without a reviewed re-pin; and the breadth family's
`[substrate]` deferral is not a pass.

## Cross-cutting: the scanner's last-token skip

The citations scanner (and the `cells` stamp loop, `corpus/claim-ledger.sh:764-774`)
drops the final whitespace token whenever a line does not end in whitespace.
This is an inherited
false-clean, not reported by the parent audit (which derived statically) or
by the round. It is the mechanism that hides spot-check `:52` and makes the
round's “three tokens” count look like the gate's output. A fix to R11-08
that only edits the two reported spot-check lines would leave this bug and
the round's own `corpus/fx-ok.sh` citation in place.

## What the round's claim must state (summary)

1. R11-08 is red at the round revision for two inherited tokens plus this
   round's own `corpus/fx-ok.sh` citation; the spot-check `:52` token is
   additionally hidden by the scanner's last-token skip. “Inherited” is not
   the whole cause.
2. `CELL_AUDIT: CLEAN` does not verify a self-skipped row; the round's own
   operability cell cites such a row (R23-01), and no test pins CLEAN with
   `self_skipped>=1`.
3. R18-02 green does not prove the backslash guard; the guard refuses only
   two adjacent backslashes; R18-02 is the only row that would break on a
   correct guard.
4. R16-01, R16-03 and R17-01 remain `[substrate]`-deferred and unmeasured;
   the `--falsify` note's two live-count cases are four; C3 discharges none
   of them.

## Residual unknowns

- Exact final line numbers and the final lesson hash: the lesson was still
  being edited during the read (`cf79cd0c…` at 01:09; earlier `2f53cf69…`,
  `993e114a…`). Re-check `corpus/lessons/round-23.md` for
  `corpus/fx-ok.sh` at integration.
- Whether L1 fixes the `corpus/fx-ok.sh` citation or the scanner before the
  integration commit; at the observed snapshot neither is fixed.
- Current live host counts for the breadth rows: not observed (the parent
  reports use committed 2026-10-14/2026-10-20 receipts; no host probe was
  run here).
- The round's own operability cell being skipped by `cells` is derived from
  the code, not measured with a real `cells` run (which would execute
  host-bound rows and was out of contract).

## Limits

No `verify`, no host-bound row, no `cells` on the real tree, no network, no
production edit, no install. All observed results are from host-free gates,
selftests, and reads of the lane bytes; the live host state and the final
integration bytes are outside this report.

Report: .ufo/waves/round-23/falsify/ScoutInherited.md
