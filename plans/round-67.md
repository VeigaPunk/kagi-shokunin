# Round 67 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 67, attempt 1. Claim BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179` (round-66 verifier spot-check tip,
`corpus/lessons/round-66-verifier-spotcheck.md`). This file is the
predeclaration: committed alone before any candidate work. The candidate
moves; this file does not.

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3. The last capability
row entered round 61 (bypass-resistant record grading, self-witnessing gate
counter); rounds 64, 65 and 66 landed claims but no capability row. The
**stagnation nudge therefore fires** (`AXES.md` §The stagnation nudge): the
lowest-axis obligation is waived and this round is a **capability move** (C1)
plus the repair the round-66 closure graded `harmed` (C2). No retirement, no
split.

Motivating evidence, measured at BASE this round:

- The round-66 closure's §6 routed defects 1–8 (record fidelity) and the
  round-66 lesson's M66-13 (QM94: the lane's own census gate reads `CLEAN`
  on a tree whose declared capture holds another row's body — re-measured
  here, receipt `.ufo/waves/round-67/base/blind-gate.txt`).
- `corpus/source-fetches.tsv` holds 36 rows whose location column (col 16) is
  a repo-relative capture path; all 36 hash to their declared col-10 sha256
  and col-11 byte count today, and 35 of their 36 declared quotes locate in
  the named body (S115 does not). The gate checks none of this: its only
  capture test is the location string's length (`${#floc} -ge 8`).
- The registry holds no row grounding *why* a digest over the named bytes is
  the binding (as opposed to a path string). RFC 9530 §1.2 is opened this
  round as S166 and is the sourced claim's row.

## C1 — freshness (capability): the census reads each declared capture's bytes and quote

Target axis: freshness (a re-verification mechanism for the registry's own
evidence). Capability row: **capture read-through in the source census**.

**Frozen predicate (this sentence is the plan's, the counter's code and the
receipt's label):**

```
C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1
```

where `bash plans/round-67-c1.sh --tree <candidate>` computes:

- `bound` — `corpus/source-fetches.tsv` rows whose location column is
  capture-path-shaped (`/` present, `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`) and
  whose named repo-relative file exists with sha256 equal to the row's col-10
  digest and byte count equal to col 11. Population derived, never listed.
- `located` — those rows whose declared quote (col 13) locates `count >= 1`
  in that file under the declared normalization (col 14): `rendered-text-v1`
  through `corpus/rendered-text-v1.py locate`, `raw-literal-v1` by literal
  substring.
- `caught` — of six mutated copies of the candidate tree (one defect each:
  repoint, truncate-by-1, delete, absolute location, `..` location, quote
  replaced by a non-locating string), the number on which the candidate gate
  prints `SOURCES_CENSUS: FAILED` **and** a `FINDING SC_CAPTURE` line whose
  reason is the expected one.
- `guard = 1` iff (a) the unmodified candidate tree prints
  `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)`;
  (b) `bash corpus/sources-census.sh --selftest` exits 0 with `cases >= 84`
  and fails closed on a mutated copy; (c) the BASE gate on the repointed copy
  prints `SOURCES_CENSUS: CLEAN` (the blindness witness: the target is not
  reachable by doing nothing); (d) the fleet wrapper reads `kagi ok` on the
  candidate; (e) the 120 prose-location rows produce no `SC_CAPTURE` finding.

Kill rules: the target is missed if `bound < 36`, `located < 36`, `caught < 6`
or `guard = 0`. A `SETUP` line is never a pass. A count produced by a
constant printer (a gate that prints the CLEAN line without reading a byte)
must be refused by guard (c) and by the mutation legs: the counter may not
hard-code any of the three numbers.

Landing surface: `corpus/sources-census.sh` (new `SC_CAPTURE` class, new
`SOURCES_CAPTURES:` summary line, new selftest cases); S115's declared quote
re-cut in `corpus/source-fetches.tsv` to a locating quote; `PROVINCE.md` /
`SKILL.md` selftest-count pins updated to the measured count.

## C2 — calibration: the lane's record surfaces match the state they describe

Target axis: calibration (`AXES.md`: "SHONEN.md/SCORECARD entries match
observed repo state"). `bash plans/round-67-c2.sh --tree <candidate>` runs
seven legs, each a mismatch the round-66 non-author closure measured:

| leg | defect at BASE (measured) | repair |
|---|---|---|
| L1 | `SCORECARD.md:2339` states `C2_PREFILE: gate=A … attack_seats=K … reads pass` while the receipt it cites reads `gate=0` / `SETUP findings=1` | replace the cell with the measured honest-stop reading |
| L2 | `SKILL.md` pins the round-66 C1 counter at `cases=14`; the instrument's `--selftest` prints `cases=45` | pin the measured tally |
| L3 | the coverage map (`corpus/README.md`) has no row for `corpus/knowledge/claim-instrument-carrier-binding.md` | add the row |
| L4 | `.ufo/waves/round-66/claim-falsification.tsv` carries no row for the attack seat `R66Sentinel` (Amendment 59's `attack-seat-unread`) | add the neutral row naming what it confirms |
| L5 | `.ufo/waves/round-66/claims.json` carries the pre-amendment ids `C2_CLAIMS` / `C3_SELFREF` while the landed counters measure `C2_PREFILE` / `C3_CENSUS` | re-derive the file from the amended plan |
| L6 | `.ufo/waves/round-66/final/c3-base.txt` is cited by the round-66 report and exists in no commit | commit a reconstructed receipt whose header names its provenance |
| L7 | the round-66 lesson logs no `used-by` old→new changes and never names S113 (SOURCES contract v1 rule 2) | append a corrigendum with the seven old→new pairs |

**Frozen predicate:**

```
C2_FIDELITY: mismatches=0 population=7 guard=1
```

where `mismatches` is the number of legs still reading `defect`, `population`
is the fixed leg count, each leg prints `LEG L<n> verdict=ok|defect <detail>`,
and `guard = 1` iff (a) `--tree <BASE>` prints `mismatches=7` (the do-nothing
control), (b) `--selftest` passes with one planted defect per leg and a clean
fixture reading 0, (c) no leg is satisfied by a constant — each re-derives
from committed bytes (a gate output, a file's contents or a referenced path).

Kill rules: any leg reading `defect` misses the target; a leg that reads `ok`
on the BASE tree is a vacuous leg and misses it too.

## Wave (one v1 wave, run-15 band 8–16)

One v1 wave of 13 seats under `ufo-wave-policy.json`: scout 1, executor 4,
scribe 2, reviewer 1, critic 1, mutation-tester 1, sentinel 1, connector 1,
revenger 1. Attack roles 6/13 (46 %). One connector. The L1 holds the
canonical planner seat (fully-specified interfaces above) and is the sole
integration owner and committer. Residual: none planned.

Sole writers, to avoid two writers on one file: `corpus/sources-census.sh` —
R67ExecGate only; `plans/round-67-c1.sh` — R67ExecCounterC1; `plans/round-67-c2.sh`
— R67ExecCounterC2; `corpus/source-fetches.tsv` — L1 only (R67ExecQuoteFix
reports the re-cut row, L1 applies); `corpus/knowledge/source-capture-binding.md`
— R67ScribeEntry; `corpus/lessons/round-67.md` + `corpus/QUALITY.md` —
R67ScribeLesson. Seats never commit.

## Frontier step

- Census before/after: `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`, run at round start (receipt `.ufo/waves/round-67/base/census-start.txt`) and at round end.
- Sourced claim: C1's entry `corpus/knowledge/source-capture-binding.md` cites S166 (RFC 9530 §1.2, opened this round with a located quote).
- One mistake mined from this round into `corpus/lessons/round-67.md` §Mistakes, with the rule that should have caught it.

## Pre-file falsification ledger

`.ufo/waves/round-67/claim-falsification.tsv`, one row per claim id (C1, C2),
artifact paths under `.ufo/waves/round-67/`, every attack seat (R67Reviewer,
R67Critic, R67MutGate, R67Sentinel, R67Connector, R67Revenger) present in the
artifact column. Gate: `python3 scripts/hyaku/prefile-falsification.py --lane
kagi --round 67`.

## Amendments

(none at freeze)
