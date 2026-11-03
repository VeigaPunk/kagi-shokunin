# ExecSweep — round-32 C1 counter (SD1–SD6)

Seat: ExecSweep (leaf, one v1 wave). Claim: C1 calibration.
Target file: `corpus/self-description-sweep.sh` (frozen counter, `plans/round-32.md`
SD1–SD6 table). Predicates were **not** changed or reinterpreted; the two points where
a literal reading of the table would not reproduce its own BASE column are recorded in
§4, not edited.

## 1. Files written

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/sweep/self-description-sweep.sh`
  (389 lines, mode 755, sha256 `61f83578583b35028bb841b6c54ef8a532b2d3fa1db3c069534ff501f5bbad26`)
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/sweep/selftest.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/sweep/base-run.txt`
- this report

Scratch: `/fast/scratch/hyaku/kagi-r32/ExecSweep/` (work copy, BASE clone, `tmp/`;
removed after the receipts landed). Nothing written under `/tmp`, the lane, the fleet
root or PATH. No tool installed (no `op`, no `pacman`, no network).

**Integration note:** the plan's C1 command is `bash corpus/self-description-sweep.sh`,
but this seat's write scope is the wave dir only. The script must be copied to
`corpus/self-description-sweep.sh` and committed by the landing seat, or the plan's
counter command does not exist at the target revision.

## 2. Implementation (frozen semantics)

`bash`, `set -u`; `--root DIR` (default `.`), `--selftest`; reads only files under the
root; SD6 runs `bash corpus/claim-ledger.sh citations` with cwd = root. All paths are
resolved from the measured root (no cwd dependence), so the script can be run from
anywhere.

Output: one `MISMATCH <SDk> <file>:<line> <detail>` per hit, then exactly
`SELF_DESCRIPTION: CLEAN n=0` (exit 0) or
`SELF_DESCRIPTION: MISMATCH n=N (SD1=a SD2=b SD3=c SD4=d SD5=e SD6=f)` (exit 1).
Setup failures (root missing/not a directory, a target file missing, no `lane-status:`
line, no `## Round` section, no calibration row, citations producing no `CITATION_GATE:`
line) print `SELF_DESCRIPTION: SETUP <reason>` and exit 2 — a missing input is never
reported as CLEAN.

- SD1: per theme (case-insensitive ERE `OIDC workload-federation`, `secret[- ]scanning`),
  a bullet line (`^[[:space:]]*[-*+][[:space:]]`) containing the case-sensitive marker
  `Frontier` that names the theme, when any line of the same file containing `Core`
  names it. Counted per (frontier line, theme) — the plan's BASE `2` for one line naming
  two held themes requires this, not a per-line count.
- SD2: lines from `## Frontier` to the next `## ` in `corpus/README.md` containing the
  literal `moved to core`.
- SD3: tokens from `corpus/[A-Za-z0-9_./-]+` and bare `LOG.md`/`SKILL.md`/`PROVINCE.md`
  in `SHONEN.md`, resolved root-relative with `-e`; trailing `.,;:` stripped (see §4).
- SD4: distinct `M31-<n>` in `corpus/lessons/round-31.md` with no `^| M31-<n> ` row in
  the same file; the mismatch points at the id's first occurrence.
- SD5: red ids of the parenthesised routed-red list on the `lane-status:` line, tested
  for presence anywhere in the first `| calibration |` row of the **latest** `^## Round`
  section (row = first cell exactly `calibration`).
- SD6: count of output lines beginning `UNRESOLVED` from the citations gate; the
  `file:line` of each hit is the gate's own location token.

Selftest (`--selftest`, 7 cases): a shared clean fixture plus one fixture per SD id with
one planted defect. A planted fixture must exit 1, print `MISMATCH SDk`, and end with
`n=1`; the clean fixture must exit 0 with exactly the CLEAN line. Fixtures live under
`${TMPDIR:-/tmp}/sd-sweep-selftest.XXXXXX` and are removed on exit.

## 3. Commands run (exact, with exits)

```
mkdir -p /fast/scratch/hyaku/kagi-r32/ExecSweep/tmp                          exit 0
git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin \
  /fast/scratch/hyaku/kagi-r32/ExecSweep/base                                exit 0
git -C /fast/scratch/hyaku/kagi-r32/ExecSweep/base rev-parse --show-toplevel exit 0
  -> /fast/scratch/hyaku/kagi-r32/ExecSweep/base
git -C /fast/scratch/hyaku/kagi-r32/ExecSweep/base checkout --detach \
  32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b                                   exit 0
git -C .../base rev-parse HEAD -> 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b    exit 0
bash -n .ufo/waves/round-32/build/sweep/self-description-sweep.sh            exit 0
TMPDIR=/fast/scratch/hyaku/kagi-r32/ExecSweep/tmp \
  bash .ufo/waves/round-32/build/sweep/self-description-sweep.sh --selftest   exit 0
  SELFTEST: PASS (7 cases) -> selftest.txt
TMPDIR=... bash .ufo/waves/round-32/build/sweep/self-description-sweep.sh \
  --root /fast/scratch/hyaku/kagi-r32/ExecSweep/base                          exit 1
  -> base-run.txt
bash <script> --help                                   exit 0 (usage)
bash <script> --root /nonexistent-root-xyz             exit 2 (SETUP root is not a directory)
bash <script> --bogus                                  exit 2 (SETUP unknown argument)
bash <script> --root                                   exit 2 (SETUP missing value for --root)
```

`base-run.txt` (verbatim, per-check counts on its last line):

```
MISMATCH SD1 PROVINCE.md:90 theme 'OIDC workload-federation' named in a Frontier bullet while a Core bullet of the same file names it
MISMATCH SD1 PROVINCE.md:90 theme 'secret[- ]scanning' named in a Frontier bullet while a Core bullet of the same file names it
MISMATCH SD2 corpus/README.md:117 line inside ## Frontier still says 'moved to core'
MISMATCH SD2 corpus/README.md:118 line inside ## Frontier still says 'moved to core'
MISMATCH SD4 corpus/lessons/round-31.md:214 id 'M31-6' is named in the file with no '| M31-6 ' table row
MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest calibration row (SCORECARD.md:1285)
MISMATCH SD6 corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-31.md:121 corpus/README.md`:64/65/67 (local)
SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)
exit=1
```

Direct citations run at BASE (layout check for SD6, not part of the sweep):
`bash corpus/claim-ledger.sh citations` exit 1, last lines
`CITATION_LAYOUT: lone-clone fleet_absent=65 (...)`,
`CITATION_GATE: BROKEN (cites=1988 docs=84 unresolved=2 ephemeral=0 labeled=20)`.
`unresolved=2` matches the plan's BASE reading; only the lone-clone `fleet_absent` /
`labeled` accounting differs, so SD6's counted number is layout-independent at BASE.

## 4. BASE measured vs the plan's BASE table

| check | plan BASE | measured BASE | delta | reason |
|---|---|---|---|---|
| SD1 | 2 | 2 | 0 | line 90 names both held themes; counted per (line, theme) |
| SD2 | 2 | 2 | 0 | lines 117, 118 |
| SD3 | 0 | 0 | 0 | — |
| SD4 | 1 | 1 | 0 | M31-6, first named at line 214 (corrigendum, no table row) |
| SD5 | 3 | **1** | **−2** | see below |
| SD6 | 2 | 2 | 0 | gate summary `unresolved=2` |
| **sum** | **10** | **8** | **−2** | |

**SD5 divergence (do not change the table).** The predicate is "red ids in the
`lane-status:` line absent from the calibration row of the latest `## Round` section".
At BASE the latest section is `SCORECARD.md:1281` (Round 31 — post-move) and its
calibration row is `SCORECARD.md:1285`; that row names `R29-01` and `R29-02` in its
evidence cell ("the summary stays `POLICY` while R29-01/R29-02 are operator-blocked")
and `R31-01`, but never `R25-02`. Literal count = 1 (only `R25-02`). The table's 3 is
reproduced only by the **pre-move** Round-31 calibration row (`SCORECARD.md:1278`),
which names none of the three; i.e. the table value appears to have been taken from the
score-shaped row rather than the last section's row. The counter follows the frozen
predicate, so BASE is 8, not 10. This is a table/predicate inconsistency, not an edit;
the target is unaffected because the round-32 calibration row must name all three reds,
which drives SD5 to 0 under either reading.

**Two readings that a literal table would get wrong (implementation follows the plan's
BASE column, not the raw regex):**

1. SD1: "count the frontier lines" would give 1 at BASE; the plan's 2 forces counting
   per (line, theme).
2. SD3: the raw token regex `corpus/[A-Za-z0-9_./-]+` captures the sentence-final dot in
   `corpus/op-ref-probe.sh.` (SHONEN.md), which does not exist as a path and would make
   SD3=1 at BASE. The counter strips trailing `.,;:` before the existence test, which
   reproduces the plan's 0. Directory tokens (`corpus/`) pass `-e` and are not hits.

## 5. False-positive / false-negative risk found

- **SD1 (false positive):** naming only, no semantics. A `Frontier` bullet that names a
  held theme while *retiring* it ("OIDC workload-federation — discharged") still counts.
  Also, a bullet line that merely contains the word `Frontier` in prose (and starts with
  `-`/`*`/`+`) counts as a frontier line. At BASE this does not fire (`PROVINCE.md:106`
  is a paragraph continuation, not a bullet). Marker matching is case-sensitive for
  `Frontier`/`Core`, so a lower-case frontier bullet is a false negative; a theme split
  across a line wrap is also a false negative.
- **SD5 (false negative relative to intent, the BASE −2):** presence is tested anywhere
  in the calibration row, including ceiling/evidence cells, so a red named only as
  "operator-blocked" satisfies the check; the row need not attribute the id to the score.
  This is the plan's own named ceiling ("SD5 counts naming, not the score's honesty").
  Conversely, a red id mentioned in the row for an unrelated reason would also pass.
- SD2: only the literal lower-case phrase `moved to core` counts; a reworded tombstone
  ("moved to the core", "now held") is a false negative by construction.
- SD4: the row pattern needs `| M31-n ` with spaces; a re-formatted row (`|M31-n|`) would
  read as missing (false positive). BASE rows use the spaced form.
- SD6: a citations run that exits non-zero but prints `CITATION_GATE:` is measured (the
  BASE gate exits 1); output without any gate line is SETUP, so a broken ledger cannot
  read as CLEAN.

## 6. Risks / blockers

- No blocker for the seat. The SD5 table value is inconsistent with the frozen predicate
  at BASE (measured 1, table 3); reported, table left untouched.
- The landed counter must reach `corpus/self-description-sweep.sh` (lane-tracked) for the
  plan's C1 command to resolve; this seat could only write the wave-dir copy.
- Selftest fixtures share one minimal tree (all six inputs), not six one-file trees: a
  missing input is SETUP by design, so a per-check tree without the other inputs could
  never produce the required exit 1. Each planted tree still carries exactly one defect
  (`n=1` asserted).
- No build/lint/test/formatter was run beyond the counting commands above.
