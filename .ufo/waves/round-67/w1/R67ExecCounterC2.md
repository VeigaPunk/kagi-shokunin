# R67ExecCounterC2 — C2_FIDELITY counter (kagi round 67, wave w1)

**Status: complete, uncommitted.** No commit, push, `git add`, `git commit`,
`git stash`, jj mutation, sysctl or sibling-lane write was run by this seat.
The only implementation file written is `plans/round-67-c2.sh` (sha256
`d4deb7356aa6fd99d3b5c8df524393fca97166501bbeb080e4b7ca4e8ce0d9e4`, 1091
lines); the seat report and receipts are under `.ufo/waves/round-67/w1/`.

Frozen predicate (`plans/round-67.md` §C2, never amended by this seat;
**Amendment A1 item 2** hardens leg 6's content check with no target,
predicate, kill-rule or population change):

```
C2_FIDELITY: mismatches=0 population=7 guard=1
```

Modes: `--tree DIR` (default: this lane) and `--selftest`; optional
`--base-tree DIR` and `--scratch DIR` (round-66-c1 precedent). Exit 0 iff
`mismatches=0` and `guard=1`; 1 otherwise; 2 SETUP with
`C2_FIDELITY: SETUP <reason>`.

## What each leg re-derives (none is a constant)

| leg | surface read | the fact it re-derives |
|---|---|---|
| L1 | `SCORECARD.md` round-66 operability row (`\| operability \|` + `[C2]` + `C2_PREFILE`, exactly one) and the receipt that row cites (`.ufo/waves/round-66/final/c2-candidate.txt`) | the row's **first** `C2_PREFILE:` token equals the receipt's last `C2_PREFILE:` line, and the row carries the receipt's `PREFILE-FALSIFICATION: …` gate-out line |
| L2 | `SKILL.md` row for `plans/round-66-c1.sh`; runs `bash <tree>/plans/round-66-c1.sh --selftest` | that row contains `cases=<n> failed=<f>` with the instrument's own tally, rc 0 and failed=0 (45/0) |
| L3 | `corpus/knowledge/claim-instrument-carrier-binding.md` exists; `corpus/README.md` | a `\|`-starting map row naming `claim-instrument-carrier-binding.md` with ≥3 cells (line 119, 3 cells) |
| L4 | `.ufo/waves/round-66/claim-falsification.tsv`, `.ufo/waves/round-66/w1/R66Sentinel.md` | exactly one row for the sentinel artifact, class `neutral`, claim id one of the ledger's own ids, detail ≥40 chars, referenced report on disk (detail 293 chars, claim C1) |
| L5 | `plans/round-66.md`, `.ufo/waves/round-66/claims.json` | per claim id, the **last** `C<n>_…` token in the amended plan (`C1_CARRIER`, `C2_PREFILE`, `C3_CENSUS`) is in that claim's title/target, and no claim carries a superseded earlier token (`C2_CLAIMS`, `C3_SELFREF`) |
| L6 | `.ufo/waves/round-66/final/c3-base.txt`; a fresh `git archive d549ee6` extraction's `bash corpus/sources-census.sh` | header names the round-66 claim BASE parsed from `plans/round-66.md` and contains `provenance`/`reconstruct`; the receipt's `findings=`/`rows=` equal the **fresh run's**; the four `FINDING` ids (SC_FETCH S155/S156 missing-provenance, SC_BODY_CITE S148/S156 unrecorded) are present and the receipt's finding set equals the fresh run's |
| L7 | `corpus/lessons/round-66.md` §Corrigendum; `git show d549ee6:corpus/SOURCES.md` vs `git show 076701a:corpus/SOURCES.md` | the seven `used-by` old→new pairs (incl. S113) expand to the historical new cells; without history the seven pinned round-66 additions are removed from the working cells |

`population=7` is the fixed leg count. Guard: (a) the do-nothing control —
`076701a`, the sha `plans/round-67.md` names, `git archive`d from a repo that
holds the object (measured tree or this lane) — must read `mismatches=7`;
(b) `--selftest` must pass; (c) the anti-constant battery must pass. A missing
prerequisite for the L6 fresh run (no repo holding `d549ee6`) is a SETUP, never
a pass.

## Verbatim runs (2026-11-08, hardened leg 6)

`bash plans/round-67-c2.sh --selftest --scratch <scratch>/scratch` (rc 0):

```
C2_FIDELITY_SELFTEST: PASS (cases=24 failed=0 guard_b=1 guard_c=1)
```

`bash plans/round-67-c2.sh` — the candidate lane, rc 0:

```
LEG L1 verdict=ok scorecard:2339 receipt:.ufo/waves/round-66/final/c2-candidate.txt verdict="C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0" gate_out="PREFILE-FALSIFICATION: SETUP findings=1"
LEG L2 verdict=ok instrument cases=45 failed=0 rc=0 skill=cases=45 failed=0
LEG L3 verdict=ok map-row:119 cells=3 entry=present
LEG L4 verdict=ok row=present claim=C1 class=neutral detail_len=293 referenced=present
LEG L5 verdict=ok expected=C1=C1_CARRIER,C2=C2_PREFILE,C3=C3_CENSUS superseded=C2_CLAIMS,C3_SELFREF
LEG L6 verdict=ok receipt=present header_lines=8 base=d549ee6eb877 gate='SOURCES_CENSUS: FAILED (findings=4 rows=155)' findings=4 rows=155 fresh_run=ok
LEG L7 verdict=ok corrigendum ids=7 pairs=7 source=git:d549ee6eb877..076701a11a58
c2-fidelity: tree=/home/vgpnk/Projects/shokunin/kagi-shokunin population=7 mismatches=0
c2-fidelity: guard a=1 b=1 c=1 base_defects=7 selftest_cases=24
C2_FIDELITY: mismatches=0 population=7 guard=1
```

`bash plans/round-67-c2.sh --tree <git archive 076701a extraction>` — the
do-nothing control, rc 1:

```
LEG L1 verdict=defect first-verdict="C2_PREFILE: gate=A claims=3 rows=R attack_seats=K guard=G" receipt="C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0"
LEG L2 verdict=defect skill-lacks-output:cases=45 failed=0 measured-cases=45
LEG L3 verdict=defect no-map-row
LEG L4 verdict=defect no-sentinel-row
LEG L5 verdict=defect C2-lacks-token:C2_PREFILE
LEG L6 verdict=defect receipt-missing
LEG L7 verdict=defect no-corrigendum-section
c2-fidelity: tree=/fast/scratch/hyaku/kagi-r67/R67ExecCounterC2-h6/base0767 population=7 mismatches=7
c2-fidelity: guard a=1 b=1 c=1 base_defects=7 selftest_cases=24
C2_FIDELITY: mismatches=7 population=7 guard=1
```

`bash plans/round-67-c2.sh --tree <scratch fixture>` — a `git archive HEAD`
extraction with the lane's uncommitted repaired record files overlaid and no
`.git` (L7 takes its fallback; the L6 fresh run archives `d549ee6` from the
lane), rc 0:

```
LEG L1 verdict=ok scorecard:2339 receipt:.ufo/waves/round-66/final/c2-candidate.txt verdict="C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0" gate_out="PREFILE-FALSIFICATION: SETUP findings=1"
LEG L2 verdict=ok instrument cases=45 failed=0 rc=0 skill=cases=45 failed=0
LEG L3 verdict=ok map-row:119 cells=3 entry=present
LEG L4 verdict=ok row=present claim=C1 class=neutral detail_len=293 referenced=present
LEG L5 verdict=ok expected=C1=C1_CARRIER,C2=C2_PREFILE,C3=C3_CENSUS superseded=C2_CLAIMS,C3_SELFREF
LEG L6 verdict=ok receipt=present header_lines=8 base=d549ee6eb877 gate='SOURCES_CENSUS: FAILED (findings=4 rows=155)' findings=4 rows=155 fresh_run=ok
LEG L7 verdict=ok corrigendum ids=7 pairs=7 source=fallback
c2-fidelity: tree=/fast/scratch/hyaku/kagi-r67/R67ExecCounterC2-h6/lane-copy population=7 mismatches=0
c2-fidelity: guard a=1 b=1 c=1 base_defects=7 selftest_cases=24
C2_FIDELITY: mismatches=0 population=7 guard=1
```

### The two forged receipts (critic's measured class)

Forge 1 — the receipt's verdict line rewritten to `CLEAN (findings=0 rows=155)`
while the header is intact. Only L6 flips, rc 1:

```
LEG L1 verdict=ok scorecard:2339 receipt:.ufo/waves/round-66/final/c2-candidate.txt verdict="C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0" gate_out="PREFILE-FALSIFICATION: SETUP findings=1"
LEG L2 verdict=ok instrument cases=45 failed=0 rc=0 skill=cases=45 failed=0
LEG L3 verdict=ok map-row:119 cells=3 entry=present
LEG L4 verdict=ok row=present claim=C1 class=neutral detail_len=293 referenced=present
LEG L5 verdict=ok expected=C1=C1_CARRIER,C2=C2_PREFILE,C3=C3_CENSUS superseded=C2_CLAIMS,C3_SELFREF
LEG L6 verdict=defect gate-mismatch:receipt=findings=0,rows=155 fresh=findings=4,rows=155
LEG L7 verdict=ok corrigendum ids=7 pairs=7 source=fallback
c2-fidelity: tree=/fast/scratch/hyaku/kagi-r67/R67ExecCounterC2-h6/forge-clean population=7 mismatches=1
c2-fidelity: guard a=1 b=1 c=1 base_defects=7 selftest_cases=24
C2_FIDELITY: mismatches=1 population=7 guard=1
```

Forge 2 — the `FINDING SC_BODY_CITE … id=S148 unrecorded` line deleted. Only
L6 flips, rc 1:

```
LEG L1 verdict=ok scorecard:2339 receipt:.ufo/waves/round-66/final/c2-candidate.txt verdict="C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0" gate_out="PREFILE-FALSIFICATION: SETUP findings=1"
LEG L2 verdict=ok instrument cases=45 failed=0 rc=0 skill=cases=45 failed=0
LEG L3 verdict=ok map-row:119 cells=3 entry=present
LEG L4 verdict=ok row=present claim=C1 class=neutral detail_len=293 referenced=present
LEG L5 verdict=ok expected=C1=C1_CARRIER,C2=C2_PREFILE,C3=C3_CENSUS superseded=C2_CLAIMS,C3_SELFREF
LEG L6 verdict=defect findings-missing:SC_BODY_CITE/S148/unrecorded
LEG L7 verdict=ok corrigendum ids=7 pairs=7 source=fallback
c2-fidelity: tree=/fast/scratch/hyaku/kagi-r67/R67ExecCounterC2-h6/forge-missing population=7 mismatches=1
c2-fidelity: guard a=1 b=1 c=1 base_defects=7 selftest_cases=24
C2_FIDELITY: mismatches=1 population=7 guard=1
```

`bash plans/round-67-c2.sh --base-tree <extraction>` reads the same control
without re-extracting: `C2_FIDELITY: mismatches=0 population=7 guard=1`, rc 0.

SETUP paths exercised: `--tree /nonexistent` ⇒ `C2_FIDELITY: SETUP bad-tree
/nonexistent` (rc 2); a directory without `corpus/SOURCES.md` ⇒ `SETUP
tree-lacks-corpus/SOURCES.md` (rc 2); `--scratch` inside the measured tree ⇒
`SETUP scratch-inside-tree` (rc 2, nothing created).

## Fixture battery (24 cases, `--selftest`)

One clean fixture must read `mismatches=0` with all seven legs ok. Per leg,
one planted defect (the BASE-shaped defect) plus anti-constant fixtures whose
checked surface stays syntactically present while the source the leg must
re-derive from moves; only the targeted leg may read defect.

| case | mutation | expected |
|---|---|---|
| clean | none | all 7 ok, mismatches=0 |
| L1 planted | SCORECARD verdict token reverted to `gate=A … attack_seats=K` | L1 defect |
| L1 cell-constant | SCORECARD verdict token `gate=9` (receipt still 0) | L1 defect |
| L1 receipt-drift | receipt verdict `gate=9` (cell still 0) | L1 defect |
| L2 planted | instrument prints `cases=14` | L2 defect |
| L2 pin-constant | instrument prints `cases=44` (SKILL still 45) | L2 defect |
| L2 pin-failed | instrument prints `cases=45 failed=1` | L2 defect |
| L3 planted | README row removed | L3 defect |
| L3 row-wrong-entry | row names another entry | L3 defect |
| L3 row-absent | row removed (second shape) | L3 defect |
| L4 planted | sentinel TSV row removed | L4 defect |
| L4 referenced-absent | row intact, `R66Sentinel.md` deleted | L4 defect |
| L4 row-short-detail | detail shortened below 40 chars | L4 defect |
| L5 planted | C2 title reverted to `C2_CLAIMS` | L5 defect |
| L5 token-both | C2 title carries `C2_PREFILE (was C2_CLAIMS)` | L5 defect |
| L5 token-superseded | C2 title `C2_CLAIMS` | L5 defect |
| L6 planted | `c3-base.txt` deleted | L6 defect |
| L6 header-sha-drift | header sha replaced by zeros | L6 defect |
| L6 gate-line-absent | `SOURCES_CENSUS:` line removed | L6 defect |
| **L6 false-clean** | **verdict line `CLEAN (findings=0 rows=155)`, header intact** | **L6 defect** |
| **L6 missing-finding** | **`FINDING SC_BODY_CITE … id=S148` line deleted** | **L6 defect** |
| L7 planted | S113 corrigendum row removed | L7 defect |
| L7 new-cell-drift | S113 `new` points at a wrong path | L7 defect |
| L7 row-absent | S113 row removed (second shape) | L7 defect |

## Pinned wordings (where a leg could not be fully mechanical)

| leg | machine-checked | pinned, not machine-decidable |
|---|---|---|
| L1 | first backticked `C2_PREFILE:` token == receipt's last `C2_PREFILE:` line; receipt's `PREFILE-FALSIFICATION:` gate-out line appears in the row; exactly one matching operability row; the cited path is the unique non-glob backticked `.txt` under `round-66/final/` whose name contains `c2` | the prose after the asserting token. The repaired row still quotes the old `gate=A … attack_seats=K` and "reads `pass`" **as history** ("This cell previously stated …"); a pure substring ban would fail the honest repair, so the check is on the asserting position plus the required measured lines. The "honest stop" characterisation itself is the reviewer's call |
| L2 | rc 0, `failed=0`, and the SKILL row contains exactly `cases=<n> failed=<f>` from the instrument | that the row's prose attributes the tally to `--selftest` (the row must contain the flag and the instrument path) |
| L3 | entry file exists; a README row names the entry with ≥3 cells | what the map row *says* the entry covers |
| L4 | one row, class `neutral`, ledger-own claim id, referenced file exists | "names what it confirms" is proxied by detail length ≥40 chars (the landed detail is 293) |
| L5 | expected token is the **last** `C<n>_…` occurrence per claim id in the plan; superseded = earlier distinct tokens; each claim's title+target must hold the expected and no superseded token; `_provenance` may name the superseded ones | the axes/targets' content beyond the counter id |
| L6 | presence; leading `#` header holding the BASE sha parsed from `plans/round-66.md` plus `provenance` and `reconstruct`; the receipt's `findings=`/`rows=` equal a **fresh run** of `bash <d549ee6-extraction>/corpus/sources-census.sh`; the four Amendment-A1 `FINDING` ids are present; the receipt's finding set equals the fresh run's | that the bytes really are a reconstruction rather than the lost original (unknowable); only the header's provenance claim is checked. The four ids are pinned by Amendment A1 item 2; the `findings`/`rows` counts are derived, never hard-coded |
| L7 | `## Corrigendum` section; table rows `\| <id> \| <old> → <new> \|` with old backticked full cell (or `(new row)`), new backticked and allowed to abbreviate the old prefix with `…`; ids exactly the seven derived rows; each old equals the derived old and each new expands to the derived new | the seven pinned round-66 additions per row, used only when the tree has no history (`S113/S143/S145/S148/S152/S164` gained `claim-instrument-carrier-binding.md`, `S148/S156` gained `claim-instrument-class-matrix.md`, `S164` is a new row) |

The L7 table shape is the format the L1's corrigendum already uses; a future
edit must keep the `→`, the backticks and the `…` abbreviation rule.

## Risks and ceilings

1. **L2 executes the measured tree's instrument** (`plans/round-66-c1.sh
   --selftest`, 43 ms here, cached per (script sha256, tree)). The measured
   tree must carry a runnable instrument; an absent one reads `defect`, a
   failing one reads `defect` with rc.
2. **L6 runs the lane gate now.** It archives `d549ee6` (the sha
   `plans/round-66.md` names) from the measured tree or this lane, runs its
   `corpus/sources-census.sh` (3.3 s, ~9 s user+sys, cached once per
   invocation), and compares the receipt's counts and finding set to that
   run. A repo without the `d549ee6` object is SETUP. The four FINDING ids are
   pinned by Amendment A1; a future gate that prints different ids will make
   the leg defect, which is the intended signal (the receipt would no longer
   describe the revision).
3. **Scratch isolation.** Each invocation gets its own run directory under
   `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r67-c2/` (mkdtemp, removed at
   exit; the root is removed when empty). This was a hardening fix: the first
   implementation used the shared root directly, and one measured run read a
   bogus `findings=18` from a half-removed extraction and then failed on a
   vanished scratch path (the shared root was the only shared mutable surface;
   the exact remover was not isolated). The per-run directory removes that
   class; no reading above came from a shared mutable path.
4. **L7's expectation is scoped** to `d549ee6…076701a` (two immutable
   commits). A later round's edit to one of the seven `used-by` cells does not
   move the expectation. Without history the fallback pins the seven additions
   listed above.
5. **Guard (a) needs a repo that holds `076701a`'s objects** (the measured
   tree or the lane). A copy of the script placed outside any repo exits 2
   `SETUP object-absent…` — honest, not a pass. `--base-tree` overrides.
6. **L1 prose** is the one place a dishonest sentence could ride alongside the
   measured lines; the asserting token is checked, the narration is not.
7. Dead ends recorded during construction: the first L1 selector found two
   receipts because the repaired row also cites the glob
   `.ufo/waves/round-66/final/c2-*.txt` (glob tokens are now excluded); the
   first L1 check accepted the measured line anywhere in the row (the
   first-token check replaced it); the clean fixture's receipt initially
   carried only one of the four FINDING lines (fixed in the fixture, not the
   check).
8. Lane state at measurement: the L1's repairs and R67ScribeLesson's README
   row were in the working tree, and `corpus/source-fetches.tsv` col 13 for
   S115 had been re-cut (sha256 `60fa5d10…`); no C2 leg reads that file, so the
   readings stand. A sibling edit to SCORECARD/SKILL/README/the round-66
   lesson/TSV/claims/c3-base changes the reading; re-run after integration.

## For the L1 (exact commands)

```
bash plans/round-67-c2.sh --selftest
bash plans/round-67-c2.sh                     # candidate lane → mismatches=0 guard=1 rc 0
D=$(mktemp -d /fast/scratch/hyaku/kagi-r67/c2-base.XXXXXX)
git archive 076701a11a58e3eb58d996b4c76c5e18071fb179 | tar -x -C "$D"
bash plans/round-67-c2.sh --tree "$D"          # control → mismatches=7 guard=1 rc 1
rm -rf "$D"
```

The hardened instrument's sha256 is
`d4deb7356aa6fd99d3b5c8df524393fca97166501bbeb080e4b7ca4e8ce0d9e4` (1091
lines); receipts `R67ExecCounterC2/{selftest,lane,base,scratch,forge-clean,
forge-missing,sha,commands}.txt`.
