# R67ExecGate — census capture read-through (round 67, w1)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179`, frozen predeclaration
`plans/round-67.md` @ `aa8807e443166f45485e1aada2989f646efc707c` (now carrying
Amendments A1–A3 recorded by the L1 during the wave). Leaf seat: nothing committed,
nothing `git add`ed, no sibling file edited. Sole writer of `corpus/sources-census.sh`;
`corpus/source-fetches.tsv` was **not** touched by this seat (the L1 applied the S115
re-cut and the A3 S166 row).

Axes named: **freshness** (the census now re-verifies the registry's own declared
evidence against the bytes it names) and **calibration** (one finding per violated
predicate, a summary line whose counts are measured row-by-row, selftest literals that
refuse a constant printer).

## 1. What landed

`corpus/sources-census.sh` only — working tree, uncommitted.

- sha256 `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`, 966 lines.
- `git diff --numstat`: **233 insertions, 4 deletions** (the 4 deletions are the two
  header lines the ceiling paragraph replaced and the two selftest-runner lines that
  gained the capture fields; no existing finding id, verdict printf or check was
  removed).

Added, keeping every existing finding id and both `SOURCES_CENSUS:` printfs byte-identical:

1. **`SC_CAPTURE` finding class**, printed exactly as
   `FINDING SC_CAPTURE id=<S-id> <reason>` with `reason` in
   {`capture-outside-root`, `capture-missing`, `capture-digest-mismatch`,
   `capture-bytes-mismatch`, `quote-not-located`}, one finding per violated predicate
   (A2.1/A2.3).
2. **`SOURCES_CAPTURES:` summary line** immediately before the verdict, in the two frozen
   forms (`CLEAN (path_rows=… bound=… located=… prose=…)` /
   `FAILED (defects=… path_rows=… bound=… located=… prose=…)`; `defects` counts
   `FINDING SC_CAPTURE` lines).
3. **Capture read-through** for every 16-column fetch row whose col 16 is
   capture-path-shaped — contains `/` and is repo-relative
   (`^[A-Za-z0-9._][A-Za-z0-9._/-]*$`) or absolute (`^/` + that shape, always a
   violation; A2.1). Checks in this order: absolute → `capture-outside-root`;
   `realpath -m` containment (symlinks followed, missing components allowed so a `..`
   escape is classified before existence) → outside root = `capture-outside-root`;
   non-existent or non-regular file = `capture-missing`; size vs col 11 and raw sha256
   vs col 10 checked independently (`capture-bytes-mismatch` / `capture-digest-mismatch`,
   both emitted when both are false); a row **bound** by bytes+digest must locate its
   col-13 quote `count >= 1` under col 14 (`rendered-text-v1` via
   `python3 corpus/rendered-text-v1.py locate FILE QUOTE`; `raw-literal-v1` by literal
   substring; undeclared normalization and an empty quote fail closed as
   `quote-not-located`). Size and digest both measure the **resolved** object
   (`stat -Lc %s`, `sha256sum` follows links), so an in-tree symlink to an in-tree
   regular file binds; only a link whose realpath leaves the tree is
   `capture-outside-root`. Bound rows that locate increment `located`; quoting is never
   performed on unbound rows. Prose rows are counted and never read.
4. **11 new selftest cases** (78 pre-existing + 11 = **89**, `PASS (89 cases)`), one per
   reason and guard: bound control, repoint (digest; same-size sibling), missing,
   truncate-by-1 (bytes+digest), absolute (outside-root), `..` (outside-root),
   quote-garbage (quote-not-located), prose-skip (clean), declared-bytes (bytes),
   symlink escape (outside-root), and in-tree symlink control (clean, pins the
   `stat -L` resolution). The runner also asserts, for every case: the summary line is
   the second-to-last line, `defects` equals the number of `SC_CAPTURE` findings,
   `path_rows + prose` equals the count of 16-column data rows, and
   `located <= bound <= path_rows`. Existing clean-case expectations are unchanged
   byte-for-byte.
5. **Header comment** rewritten to state what is measured, the five reasons, the summary
   line, the counting unit, and the **ceiling**: a body rewritten together with its row
   (bytes replaced and cols 10/11/13 updated coherently) still passes; there is no
   network and no second witness, so the gate catches a row drifting from its declared
   body, not a body drifting from the page it once held.

## 2. Evidence (all retained under `.ufo/waves/round-67/w1/R67ExecGate/`)

### Selftest

```
SOURCES_CENSUS_SELFTEST: PASS (89 cases)          exit 0
```

`selftest-final.txt` (89 `case …: ok` lines, no FAIL), run on the final gate bytes
(sha256 above).

### Real-tree candidate (the current lane)

`30-lane-integrated.txt` — pristine `bash corpus/sources-census.sh` in the lane:

```
SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)
SOURCES_CENSUS: CLEAN (rows=157 A=140 B=2 C=15 queued=3 mined=137 rejected=17 entries_sourced=27 legacy=21 captures=157 inrow=16 inrow_only=0 inrow_nonreproducing=12)
```

`prose=121` (not the plan's BASE 120) because Amendment A3 registers S166 with a **prose**
location; A3 fixes that the frozen target keeps `bound=36 located=36` and guard (a)
compares `prose` to the candidate's derivation, never to a literal. The capture-path
population is 36 and is derived from `git show 076701a:corpus/source-fetches.tsv`.

### Six mutation legs (real lane copies; expected reason always present)

`repoint-integrity.txt`, `truncate-by-1.txt`, `delete-body.txt`,
`absolute-location.txt`, `dotdot-location.txt`, `quote-not-located.txt`,
`prose-skip.txt`, `08-base-gate-on-repoint.txt`:

| leg | mutation | gate | reasons printed |
|---|---|---|---|
| repoint S116 → S117.body (row's digest/bytes kept) | exit 1, FAILED | `capture-bytes-mismatch`, `capture-digest-mismatch` |
| truncate S116.body by 1 byte | exit 1, FAILED | `capture-bytes-mismatch`, `capture-digest-mismatch` |
| delete S116.body | exit 1, FAILED | `capture-missing` |
| absolute col-16 (inside the copy, still absolute) | exit 1, FAILED | `capture-outside-root` |
| `../base/...` col-16 (exists, outside root) | exit 1, FAILED | `capture-outside-root` |
| quote replaced by non-locating text (bytes intact) | exit 1, FAILED | `quote-not-located` |
| prose col-16 "page title/H1" + garbage quote + wrong declarations | exit 0, CLEAN | none (`path_rows=35 … prose=121`) |
| BASE gate (`git show BASE`) on the repointed copy | exit 0, **CLEAN** | blindness witness: the old gate cannot see the defect |

### In-tree symlink false positive, found by R67Revenger, fixed here

`stat -c %s` lstat's a link (9 B for the target string) while `sha256sum` follows it, so
an in-tree symlink to an in-tree body read `capture-bytes-mismatch` — a false positive
under the frozen interface, which permits a symlink whose realpath is an in-tree regular
file. Fixed with `stat -Lc %s`; receipts `symlink-size-lstat-vs-stat.txt`
(`lstat_size=9`, `stat_size=33338`) and `symlink-intree-real-tree.txt` (a full-tree copy
with `S116-alias.body -> S116.body` reads `CLEAN (path_rows=36 bound=36 located=36 …)`,
rc 0), plus selftest case `capture-symlink-intree-control`.

### Frozen C1 counter, run on the current lane with the final bytes

`23-counter-current-lane.txt` (`plans/round-67-c1.sh` as amended by A2, unmodified by
this seat):

```
c1-readthrough: derived path_rows=36 bound=36 located=36 prose=121 malformed=0
c1-readthrough: population base_ids=36 source=tree-history git show 076701a… candidate=36
c1-readthrough: guard a=1 b=1 c=1 d=1 e=1 f=1 pop=1
C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1        (exit 0)
```

All six mutated copies are caught with the amended counter's expected reasons and ids
(M1 S143→round-64/S143.body same-size different-sha → `capture-digest-mismatch`, defects=1;
M2 truncate → both content reasons, defects=2; M3 delete → `capture-missing`; M4 absolute
and M5 `..` → `capture-outside-root`; M6 quote → `quote-not-located`). Guard (b)
`cases=89`; guard (c) BASE gate CLEAN on the repointed copy; guard (d) fleet wrapper
`kagi ok`; guard (e) no prose id in a finding, `prose_findings=none`; guard (f) and guard
(pop) pass with the BASE-derived 36-id set.

Earlier receipts, kept as history only: `20-counter-on-lane.txt` is the pre-recut lane
(`C1_READTHROUGH: bound=36 located=35 caught=6/6 guard=0`, guards a=0 b=1 c=1 d=1 e=1,
gate printing `FINDING SC_CAPTURE id=S115 quote-not-located`); `21-`/`22-` are the
88-case / 156-row registry states before the A3 row and the symlink fix.

## 3. Where the frozen wording could not be enforced exactly

1. **Absolute locations are not capture-path-shaped under the plan's original regex**
   (a leading `/` fails `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`). The gate classifies a leading
   `/` of the same shape as capture-intent and emits `capture-outside-root`; Amendment
   A2.1 (recorded after the reviewer's findings) legalizes exactly this and sets
   `path_rows` to count it. Measured: no prose row begins with `/`, so nothing is
   reclassified; an absolute-mutated tree still reads `path_rows=36`.
2. **No reason exists for "not a regular file".** A directory, FIFO or device at a
   capture path is classified `capture-missing` (the frozen reason set has no
   non-regular member). Documented in the header.
3. **`defects` has no frozen counting unit in the original text.** The gate counts
   `SC_CAPTURE` findings; A2.3 now states the same (`defects=N` counts finding lines),
   so a one-byte truncation reads `defects=2` for one row.
4. **An unreadable/undecodable rendered capture is a SETUP, not a reason.** If
   `rendered-text-v1.py locate` exits 2 (e.g. strict-UTF-8 failure) the gate fails closed
   with `SOURCES_CENSUS: SETUP (rendered-text-v1 locate failed …)`, exit 2 — the frozen
   reason set cannot express "could not read", and a SETUP is never a pass. A consequence
   the revenger named: a coherent row with an undecodable body aborts the whole verify to
   SETUP and prints no summary line (fail-closed, by design).
5. **An undeclared col-14 normalization** yields `quote-not-located` (fail closed) in
   addition to the pre-existing `SC_FETCH normalization` finding.
6. **Rows outside the 16-column shape** (NF!=16) are outside the capture summary — the
   pre-existing `SC_FETCH` shape finding owns them; the header states this. Consequence:
   such a row can leave `SOURCES_CAPTURES: CLEAN` beside `SOURCES_CENSUS: FAILED`.
7. **S166's location is prose** by A3, so its capture is not gate-read this round
   (hand-verified: 67152 B, sha256 `544dbb7d…`, locate count=1). Extracting shaped
   tokens from prose cells, or requiring cited mined rows to be capture-shaped, is a
   round-68 rule change, not a classifier bug.

Ceiling (also in the gate header): a coherent rewrite of body + row passes. `located`
means the declared passage exists in the named bytes under the declared normalization —
not that it supports the row's teaching.

## 4. Risks / observations

- External mutation run (R67MutGate, against sha256 `e7aacecd…` — retested after the
  symlink-size fix — receipts `.ufo/waves/round-67/w1/R67MutGate/`): **no survivor**
  among 7 mutants (length-only, size-only, quote-nonempty, constant
  `bound=36/located=36`, prose-as-paths, exit-0-with-SC_CAPTURE, no-containment).
  M2 and M7 specifically re-run and killed: no regression from the `stat -Lc`
  change, and the new `capture-symlink-intree-control` is undisturbed by every
  mutant. Load-bearing residual: the constant `bound=36/located=36` printer is killed
  **only** by this gate's selftest (per-case `SOURCES_CAPTURES` literals plus
  `path_rows+prose == 16-column rows` and `located <= bound <= path_rows`); on the
  real tree the true values are 36/36 and 36, so the counter's guard (a) and its six
  caught legs cannot separate a printer that matches the true data from a
  measurement. That is a property of the frozen interface, not of this
  implementation; the selftest invariants are the sole defence and were kept for
  that reason.
- Revenger-named unpinned behaviours, not repaired (each either the frozen rule itself or
  a ceiling): a col-16 with trailing/leading whitespace or a stray CR is prose by the
  exact shape rule (the counter derives with the same exact shape; a whole-file CRLF tree
  would diverge from Python `splitlines` — no committed file is CRLF); a hardlink to an
  out-of-tree body binds exactly like a copied body (hardlinks are indistinguishable);
  a borrowed col-15 normalized digest binds because the field is format-checked only
  (`SC_INROW` recomputes digests only for in-history pins); a tampered in-tree
  `rendered-text-v1.py` would move `located` — the gate has no internal witness of its
  own tool, but the amended counter's guard (f) is the sentinel's normalizer-identity
  check (`R67ExecCounterC1` confirms it derives against the trusted BASE/lane normalizer),
  so the witness exists at the measurement layer. These are named so the axis is not
  overclaimed.
- The lane gate is FAILED-on-drift by design: any capture row that stops binding to its
  declared bytes, or any quote that stops locating, fails the census. It was demonstrated
  on the live lane pre-recut (S115) and reads CLEAN on the integrated lane.
- Runtime: ~7–13 s for a lane verify (31 `rendered-text-v1.py locate` subprocesses; 5
  raw-literal rows are in-process). The amended C1 counter runs the gate nine times per
  measure; a counter measure is ~30–60 s on this host.
- Concurrent-wave observation, not a gate defect: one `plans/round-67-c1.sh` run (receipt
  21) aborted inside its own `clone_tree` with
  `FileNotFoundError: corpus/lessons/round-31.md` while another seat was replacing files
  in the lane; the immediate rerun was clean (receipt 23). External tree-racing tools
  should retry that race.
- `PROVINCE.md` / `SKILL.md` selftest-count pins still carry pre-round-67 tallies; the L1
  owns those files. Measured count to pin: **89 cases**.

## 5. Files written

```
corpus/sources-census.sh                                  (sole-writer gate; uncommitted)
.ufo/waves/round-67/w1/R67ExecGate.md                     (this report)
.ufo/waves/round-67/w1/R67ExecGate/metadata.txt
.ufo/waves/round-67/w1/R67ExecGate/selftest-final.txt      PASS (89 cases)
.ufo/waves/round-67/w1/R67ExecGate/00-candidate-clean.txt        (historical pre-A3, prose=120)
.ufo/waves/round-67/w1/R67ExecGate/09-lane-unmodified.txt         (historical pre-A3, prose=120)
.ufo/waves/round-67/w1/R67ExecGate/30-lane-integrated.txt  final lane reading
.ufo/waves/round-67/w1/R67ExecGate/repoint-integrity.txt
.ufo/waves/round-67/w1/R67ExecGate/truncate-by-1.txt
.ufo/waves/round-67/w1/R67ExecGate/delete-body.txt
.ufo/waves/round-67/w1/R67ExecGate/absolute-location.txt
.ufo/waves/round-67/w1/R67ExecGate/dotdot-location.txt
.ufo/waves/round-67/w1/R67ExecGate/quote-not-located.txt
.ufo/waves/round-67/w1/R67ExecGate/prose-skip.txt
.ufo/waves/round-67/w1/R67ExecGate/08-base-gate-on-repoint.txt
.ufo/waves/round-67/w1/R67ExecGate/10-base-gate-on-lane.txt
.ufo/waves/round-67/w1/R67ExecGate/symlink-size-lstat-vs-stat.txt
.ufo/waves/round-67/w1/R67ExecGate/symlink-intree-real-tree.txt
.ufo/waves/round-67/w1/R67ExecGate/20-counter-on-lane.txt   (historical pre-recut, located=35 / guard=0)
.ufo/waves/round-67/w1/R67ExecGate/21-counter-on-integrated-lane.txt (historical 88-case state; clone race)
.ufo/waves/round-67/w1/R67ExecGate/22-counter-on-integrated-lane.txt (historical 88-case / 156-row state)
.ufo/waves/round-67/w1/R67ExecGate/23-counter-current-lane.txt  final: bound=36 located=36 caught=6/6 guard=1, exit 0
.ufo/waves/round-67/w1/R67ExecGate/summary.tsv            (historical pre-A3 driver table)
.ufo/waves/round-67/w1/R67ExecGate/prove-run.log          (historical pre-A3 driver log)
.ufo/waves/round-67/w1/R67ExecGate/gate-diff.patch
```

Scratch `/fast/scratch/hyaku/kagi-r67/R67ExecGate/` deleted after copying. No commits, no
`git add`, no `git stash`, no jj mutation; no edits to `corpus/source-fetches.tsv`,
`corpus/SOURCES.md`, `plans/`, sibling lanes, `scripts/`, `.ufo/state`, `MANIFEST.json`
or `templates`. No `agent://all` message, no `ask`.
