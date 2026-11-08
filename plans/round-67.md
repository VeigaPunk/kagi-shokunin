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

## C1 — freshness: the census reads each declared capture's bytes and quote (capability acquisition)

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

## Amendment A1 — 2026-11-08, recorded after the first C2 lane reading

No target, predicate, kill rule or population changes here. Three scope and
implementation facts the wave's critic measured (`R67Critic`, item 2 and 4):

1. **Out-of-lane routed items.** The round-66 closure's routed defects 4 (the
   report's `Landed changes` LOG pointers / uncited commits) and 5 (the
   controls-battery receipt) live in the fleet-root report
   `.ufo/reports/round-66/kagi.md`, which no lane may write. They are **not**
   C2 legs; they are named in this round's report as out-of-scope, which is
   the same reading §3's write scope gives. C2's population stays the seven
   lane-owned surfaces L1–L7.
2. **L6 content.** Leg 6 must verify the reconstructed receipt's *content*,
   not only its header: it requires the `C3_CENSUS:` line's `findings=` and
   `rows=` to equal a fresh run of the lane gate on a `d549ee6` extraction and
   the four `FINDING` ids to be present. A receipt whose verdict line says
   `CLEAN (findings=0)` therefore reads `defect` (the round-66 gate read
   `FAILED (findings=4)` at that revision).
3. **Wording.** "Seven `used-by` cells changed" (round-66 corrigendum) is
   corrected to "six changed and one row appeared"; the leg's seven ids are
   unchanged.

## Amendment A2 — 2026-11-08, from R67Reviewer's blocking findings (before the landed counter reading)

The wave's reviewer measured (receipts under `.ufo/waves/round-67/w1/R67Reviewer/receipts/`)
that three frozen terms were unreachable or underdetermined as written. The
target, the label and the population stay exactly as frozen; this amendment
records what the instrument must enforce. Every item is the reviewer's A-67-n
text applied to this plan.

**A2.1 — location shape (legalizes the landed gate's classifier).**
Capture-path-shaped location = column 16 of `corpus/source-fetches.tsv` contains
`/` and either matches `^[A-Za-z0-9._][A-Za-z0-9._/-]*$` (repo-relative) or
matches `^/[A-Za-z0-9._][A-Za-z0-9._/-]*$` (absolute). An absolute location is
always `capture-outside-root` and is counted in `path_rows`. Every
capture-path-shaped row is read: a repo-relative location must resolve
repo-relatively, realpath inside the tree, to a regular file; sha256 == col 10;
size == col 11; a row bound by those checks must locate its col-13 quote
`count>=1` under the col-14 normalization. A row may print more than one
`FINDING SC_CAPTURE id=<S-id> <reason>` when more than one check fails. Prose =
every other non-empty col-16 value (120 at BASE, 17 containing `/`), counted and
never checked; an empty col-16 stays an SC_FETCH `location` defect. Measured
why: under the strict form alone the absolute-location mutation is classified
prose (`path_rows=35 prose=121`) and a perfect gate scores at most 5/6.

**A2.2 — the C1 sentence, narrowed (Amendment 59).** The claim reads: *the
census reads the bytes and the declared locator quote of every
capture-path-shaped row (36 rows at this round).* `bound`, `located`,
`path_rows` and `prose` cover those rows only; the 120 prose locations are
counted and never opened; `located` means only that the declared locator occurs
at least once under the row's declared normalization — quote length, provenance
and evidentiary strength are not measured. Measured why: 17 slash-bearing prose
rows name files/offsets that are never opened (S008, S099, S105), and a
one-token quote `a` locates 580 times in S115's body yet satisfies `located`.
The landed S115 re-cut is a real 18-word quote by choice, not by enforcement.

**A2.3 — the `caught` construction (each leg, or SETUP, never a pass).**
M1 repoint: col 16 → an in-tree capture file of the **same byte count and a
different sha256** (fixture S143 → `.ufo/waves/round-64/capture/S143.body`, both
264946 B); expected `capture-digest-mismatch`. M2 truncate-by-1: expected
`capture-bytes-mismatch` **and** `capture-digest-mismatch`. M3 delete: expected
`capture-missing`. M4 absolute: expected `capture-outside-root`. M5 `..`:
expected `capture-outside-root`. M6 quote: col 13 → a non-empty ≤25-word string
that does not locate; expected `quote-not-located`. `defects=N` counts `FINDING
SC_CAPTURE` lines, not rows. A leg is `caught` only when the counter captured
the candidate gate's own stdout for that copy and it contains `FINDING
SC_CAPTURE id=<mutated-id> <expected reason>`; findings for other ids do not
count and the counter may not classify the copy itself. The counter's selftest
replays the six legs against a stub gate that prints the unmodified CLEAN
summary for every copy; `caught` must read `0/6`. A repoint to a byte-identical
body (S130 → S135's location, `cmp` rc 0) is not a mutation. Measured why: the
plan's names fixed no expected reason, no id and no `defects` definition, and
one natural repoint target is byte-identical.

**A2.4 — population identity (guard).** The 36-id set and each id's col-16 and
col-10 values are derived from `git show 076701a:corpus/source-fetches.tsv`
(never a literal list). For `guard=1` the candidate's capture-path-shaped id set
must be exactly that 36-id set and each id's col 16 and col 10 must be
byte-identical to BASE (the lane holds the BASE blob; a copy without history
falls back to the committed values, declared as such). Measured why: an
S115→S116 reroute of every dependent column reads `CLEAN (path_rows=36
bound=36 located=36 prose=120)` with S115's own quote still `count=0` — the
target reached while the required repair is skipped (QM92's sibling-row copy,
one level up).

**A2.5 — guard (d) venue.** Guard (d) runs
`scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
with the candidate tree deployed at the lane path; on a copy the wrapper exits 2
(no `shokunin.conf`) or prints `file ok` (`--file`), neither of which is `kagi
ok`.

**A2.6 — the "0 → 36" reading.** `bound=36` is a property of the BASE rows
already (all 36 hash at BASE); the round's gate-level before/after is
`located 35 → 36` and `caught 0/6 → 6/6`, with the BASE gate reading no capture
bytes at all. The report and SCORECARD state both readings and never the bare
milestone.

## Amendment A3 — 2026-11-08, the sourced row's place in the population

The round's sourced claim registers **S166** (RFC 9530, opened live this round)
with a registry row and one `corpus/source-fetches.tsv` row. Its location column
is **prose** (it names the section and the capture path in a sentence), because a
capture-path location would add a 37th capture-path row and move the frozen
`C1_READTHROUGH` numbers. Consequences, recorded rather than assumed:

1. `path_rows`, `bound` and `located` keep their frozen values (36/36/36); the
   capture-path id set stays exactly the BASE 36 (A2.4).
2. `prose` rises 120 → 121. Guard (a) compares the gate's `prose` to the
   candidate's derivation, not to a literal 120; the frozen target line
   `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` is unchanged.
3. S166's capture is therefore **not** gate-checked: its sha256, byte count and
   the quote's location are verified by hand (capture
   `.ufo/waves/round-67/capture/S166.body`, 67152 B,
   `544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a`, quote
   `Receivers can validate the digest for integrity purposes.`,
   `RENDERED_TEXT_V1_LOCATE: count=1`) and recorded in the lesson's Gate
   section. A path-shaped registration would be a round-68 capability move, not a
   change to this round's frozen target.

## Amendment A4 — 2026-11-08, heading form

The §C1 heading was `## C1 — freshness (capability): …`; `corpus/claims-declared.sh`
requires `## <claim> — <axis>:` with the colon directly after the axis, so the
parenthetical moved after the colon. Title form only — no predicate, counter,
kill rule, guard or target text changes.

## Amendment A5 — 2026-11-08, guard f (the counter's oracle)

`plans/round-67-c1.sh` resolved the normalizer from the tree it measures, so a
tree shipping a truthy normalizer moved both the gate's and the counter's
answer together (`R67Sentinel` V-1). Guard f binds the candidate's
`corpus/rendered-text-v1.py` to the copy at BASE (`git show <BASE>:…`, else the
`--base-tree` copy): a differing hash reads `guard=0`. The derivation itself
uses the BASE or lane normalizer, never the candidate's; the gate resolves its
own sibling (`corpus/sources-census.sh`, `R67Sentinel` V-2). The exploit tree
(every quote non-locating, stub normalizer) reads `caught=5/6 guard=0` rc 1 on
the fixed bytes; the clean lane still reads `bound=36 located=36 caught=6/6
guard=1`.
