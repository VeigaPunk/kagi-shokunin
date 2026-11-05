# Round 43 — frozen plan (kagi, attempt 1)

Claim BASE: `5f3566c4cfe65a74da4d201d74d28b403929807b` (lane `master` at round start; the round-42
verifier spot-check names it as the verified tip). Predeclaration (this plan, the three counters,
the controls runner and the BASE receipts under `.ufo/waves/round-43/controls/`) is committed alone
before any candidate work. Frozen predicates, counter names, targets, kill rules and controls below
are not amended after data. A correction is appended only before the first candidate measurement,
and is named in the lesson.

Axes: C1 → **calibration**; C2 → **freshness**; C3 → **operability**. All six axes stood at 9 at the
round-42 close (a tied lowest), so every claim works a tied-lowest non-retired axis; as in rounds
36–42 the claims are measured against the BASE readings below and no axis score is re-scored (the
rows record what moved).

Shape: ONE v1 wave of 10 seats (executor 3, scout 1, scribe 1, connector 1, reviewer 2, critic 1,
mutation-tester 1); attack seats = reviewer 2 + critic 1 + mutation-tester 1 = 4/10 (40 %, floor
25 %); connector 1 (≤ 2). The planner seat is the L1 (the validator rejects the role); the L1 holds
the §3 planner duty and records it in the report.

Frontier step (§2b): census before `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
→ `kagi ok`, exit 0, 98 rows (19 W04 duplicate-url warnings, warnings allowed). Round-start
evidence: `.ufo/waves/round-43/controls/` receipts and this plan. Mistakes mined: M42-4 and M42-5
(below). Sourced claim: C1 rests on registry row S094 (re-opened this round; the lesson's Gate
carries the URL, access date and ≤25-word located quote; the row's `used-by` cell moves
old→new per the round-42 spot-check routed item 2).

## C1 — calibration: the C1 instrument refuses the three broken-instrument shapes the round-42 instrument accepted

**Improves:** the round-42 lesson (§Routed 7, §Claims C1 ceilings) named three broken instruments
its frozen controls do not kill: a guard-drop counter mutant (`c1-M3`), a token-drop counter mutant
(`c1-M5`), and the reviewer's answer-key gate (`fakeC`, round-42 attack 3). Each scored **5 = the
round-42 target** or survived as a counter mutant. Round 43 replaces the C1 instrument:
`plans/round-43-c1.sh` grows the forgery population to six (F6 = the P0 ledger with row `R11-03`
deleted, unjournaled — the second deletion id; an id-keyed answer gate keyed on `R17-02` alone
accepts F6), and the controls matrix proves the new instrument rejects all three shapes while the
old one accepts them.

**Frozen predicate** (the same sentence appears in `plans/round-43-c1.sh`'s header): the counter
prints ONE unsigned integer N in 0..6 = the number of the six forgeries F1–F6 the gate
`${EXPECT_JOURNAL:-corpus/expect-journal.sh}` refuses with its frozen token (rc 1 and the exact
line `EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate accepts the positive control P0
(rc 0); missing gate, refused P0 or P0 error ⇒ N = 0. **Target: N = 6 at the candidate.**

**Discrimination matrix** (frozen expected values; receipts under `.ufo/waves/round-43/controls/`,
measured at the claim BASE `5f3566c`; re-measured byte-frozen under `final/` at the candidate):

| receipt | old instrument | new instrument |
|---|---|---|
| real gate | `c1-old-real.txt` = 5 | `c1-new-real.txt` = 6 |
| K1 (valid-token blanket gate, refuses P0) | `c1-old-K1.txt` = 0 | `c1-new-K1.txt` = 0 |
| m3 (guard-drop mutant) + K1 | `c1-old-m3-K1.txt` = **5 (survivor)** | `c1-new-m3-K1.txt` = **6 (exposed)** |
| K3 (constant-wrong-token gate, accepts P0) | `c1-old-K3.txt` = 0 | `c1-new-K3.txt` = 0 |
| m5 (token-drop mutant) + K3 | `c1-old-m5-K3.txt` = **5 (survivor)** | `c1-new-m5-K3.txt` = **6 (exposed)** |
| fakeC (answer-key gate, F1–F5 only) | `c1-old-fakeC.txt` = **5 (passes its target)** | `c1-new-fakeC.txt` = **5 < 6 (rejected)** |
| blanket refuse / accept | 0 / 0 | `c1-blanket-refuse.txt` = 0, `c1-blanket-accept.txt` = 0 |

The broken-instrument rejection count moves **0/3 → 3/3**: the old set passes every broken shape
(survivor receipts 5/5/5); the new set refuses all three (K1/K3 hold at 0 with the mutants exposed
at 6; fakeC 5 < target 6) while the real gate moves 5 → 6. Mutant recipes (frozen, applied by
`plans/round-43-controls.sh` to byte-copies in a scratch clone): m3 = the P0-guard block deleted;
m5 = the per-token `grep -qxF` condition dropped. K1/K3/fakeC are basename-keyed fixture gates
built by the runner (the honest shape of the answer-key class: they inspect nothing but the
fixture name).

**No-work control:** the old-instrument receipts (5/5/5 survivors, real 5) and `c1-base` absence —
the new counter does not exist at BASE (`bash plans/round-43-c1.sh` at `5f3566c` is a missing file),
so no do-nothing state reaches N = 6 with the matrix. Committed receipts are the control.

**Kill rule:** C1 is not admitted if (a) N ≠ 6 at the candidate; (b) any of `c1-new-K1`,
`c1-new-K3` ≠ 0, `c1-new-fakeC` ≠ 5, `c1-new-m3-K1` ≠ 6, `c1-new-m5-K3` ≠ 6; (c) any of
`c1-old-real` ≠ 5, `c1-old-fakeC` ≠ 5, `c1-old-m3-K1` ≠ 5, `c1-old-m5-K3` ≠ 5 (the before-state
moved); (d) `git diff --quiet 5f3566c HEAD -- corpus/expect-journal.sh` fails (the gate bytes were
to stay untouched this round); (e) the landing check `bash corpus/expect-journal.sh --base-ledger
<(git show 6cc8850:corpus/claim-ledger.tsv) --ledger corpus/claim-ledger.tsv --journals <dir with
the round-40 and round-41 journals>` is not `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)` rc 0.

**Declared ceilings (named, not closed):** the counter measures token output, not gate logic — a
gate keying all six answers plus P0 acceptance still passes (the answer-key class at population 6;
fakeC proves the 5-key fails, a 6-key is named as surviving); the counter does not re-run commands
and does not judge reason text; the mutant battery covers the guard and token drops only; F6 forges
one row only.

## C2 — freshness: a committed gate durably enforces receipt re-derivability at the revision it names

**Improves:** round-42 C2 fixed one receipt (`c2-base-19025d9.txt`) by a one-shot frozen counter;
the connector's routed item (round-42 lesson §Adjacency, kake r90→r91 prior art) asked for the
durable form: a committed gate so the property survives after the round closes. Eight of the
eleven committed receipts under `.ufo/waves/round-42/controls/` and `.ufo/waves/round-41/controls/`
re-derive byte-identically at the BASE HEAD (measured this round in a scratch clone; the other
three are historical claim-BASE readings by design — excluded and named in the counter header).
No committed instrument enforces this today: any drift in the eight receipts would go uncaught.

**Frozen manifest** (the eight re-derivable receipts, frozen values): `.ufo/waves/round-42/controls/`
`c1-control-refuse-all.txt` (0), `c1-control-accept-all.txt` (0), `c2-derivation-D.txt` (1);
`.ufo/waves/round-41/controls/` `c1-control-refuse-all.txt` (0), `c1-control-accept-all.txt` (0),
`c1-control-no-gate.txt` (0), `c2-control-decoy.txt` (2), `c2-base-19025d9.txt` (1). Excluded by
design: `round-42/controls/c1-base.txt` (committed 4, the round-42 C1 BASE reading; re-derives 5),
`round-42/controls/c2-base.txt` (committed 0, the round-42 C2 BASE reading), `c2-worktree-at-base.txt`
(a diagnostic no committed runner writes).

**Candidate rule (executor's work):** `corpus/controls-replay.sh`, interface frozen: invoked only
as `bash corpus/controls-replay.sh --clone <dir>` (no other mode; missing `--clone` is setup exit 2).
Steps: snapshot every file under the clone's two controls dirs; delete them; run the clone's
`plans/round-42-controls.sh` and `plans/round-41-controls.sh` (each must exit 0); require every
manifest file to exist again and byte-match (`cmp`) its snapshot; restore the snapshot (verification
is non-destructive); exit 0 clean / 1 refused / 2 setup. Scratch root
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/controls-replay.<pid>`, removed on exit; `set -u`;
bash + python3 stdlib only.

**Frozen predicate** (the same sentence appears in `plans/round-43-c2.sh`'s header): the counter
prints N ∈ {0,1}; N = 1 iff, in a shared clone of the candidate commit (argument, default HEAD),
the committed gate (the clone's own `corpus/controls-replay.sh`, override
`CONTROLS_REPLAY_GATE=<path>`) exits 0 on the clean clone (P1), exits 1 on a stale fixture (N1: a
copy whose `round-42/controls/c2-derivation-D.txt` reads 2), and exits 1 on a silent fixture (N2: a
copy whose `plans/round-42-controls.sh` is replaced by `exit 0`). **Target: N = 1 at the candidate.**

**No-work control:** at the claim BASE no gate exists, so `bash plans/round-43-c2.sh` reads **0**
(`controls/c2-base.txt`, measured at `5f3566c`); blanket always-0 and always-1 gates read **0**
(`c2-blanket-0.txt`, `c2-blanket-1.txt`), so neither a do-nothing gate nor a blanket gate reaches
the target.

**Kill rule:** C2 is not admitted if (a) N ≠ 1 at the candidate; (b) the gate refuses the clean
clone or accepts either fixture in a direct run (`final/c2-replay-direct.txt` not rc 0); (c) the
clone's controls dirs do not byte-match their committed state after the direct replay (the restore
duty); (d) either blanket receipt ≠ 0 re-measured at the candidate.

**Declared ceilings:** a gate that special-cases the three invocation shapes passes the counter —
the gate's default verification is reviewed as code; a runner hardcoding all eight manifest values
passes the byte comparison — the runners are reviewed as code and D is pinned to `5142b52` by
round-42 amendment A1; the counter checks the manifest set only, not files outside it.

## C3 — operability: the five gate selftests honour the lane scratch root, not `${TMPDIR:-/tmp}`

**Improves:** the round-41 routed item (carried through round 42, lesson §Routed 4): five lane
gates create their selftest fixtures under `${TMPDIR:-/tmp}` defaults — `corpus/anchor-pins.sh:37`,
`corpus/claims-declared.sh:37`, `corpus/prefreeze-control.sh:94` and `:274`,
`corpus/self-description-sweep.sh:226` (and its line-43 comment), `corpus/surface-census.sh:275` —
against the lane's scratch discipline (round-41 gates and all round-42 instruments use
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}`).

**Candidate rule (executor's work):** exactly the seven frozen replaces of
`plans/round-43-controls.sh` §C3 FIXES applied to the five gates (each `${TMPDIR:-/tmp}` default
becomes `${HYAKU_SCRATCH:-/fast/scratch/hyaku}` with a `kagi-r43-`-prefixed fixture name; the
sd-sweep comment line updated). No other byte changes; the ledger is untouched (no journal needed).

**Frozen predicate** (the same sentence appears in `plans/round-43-c3.sh`'s header): the counter
prints N in 0..5 = the number of the five gates satisfying all three legs: (1) no `TMPDIR:-/tmp`
in the gate bytes; (2) the selftest scratch default names `${HYAKU_SCRATCH:-/fast/scratch/hyaku}`;
(3) executed: `HYAKU_SCRATCH=<scratch>/probe bash <gate> --selftest` exits 0 with the frozen last
line — `ANCHOR_PINS_SELFTEST: PASS (8 cases)`, `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`,
`PREFREEZE_SELFTEST: PASS (25 cases)`, `SELFTEST: PASS (10 cases)`,
`SELFTEST: PASS (16 cases)` — all five measured passing at BASE (L1, this round, scratch probe).
**Target: N = 5 at the candidate.** The gate set is scanned under `C3_ROOT` so the controls runner
can point the counter at fixture trees.

**No-work control:** at the claim BASE all five gates carry the `TMPDIR:-/tmp` default, so leg (1)
fails for every gate: N = **0** (`controls/c3-base.txt`). Fixture controls: a tree with exactly one
gate fixed reads **1** (`c3-pos.txt`); a tree with every grep leg fixed but surface-census's selftest
PASS token sabotaged reads **4**, never 5 (`c3-blanket.txt`) — the executed leg is load-bearing.

**Kill rule:** C3 is not admitted if (a) N ≠ 5 at the candidate; (b) `c3-pos` ≠ 1 or `c3-blanket` ≠ 4
re-measured at the candidate; (c) any of the touched ledger rows re-run individually departs from
its BASE verdict: R11-03 (`bash corpus/surface-census.sh --selftest` → `SELFTEST: PASS (16 cases)`
rc 0), R33-01 and R34-02 (`PREFREEZE_SELFTEST: PASS (25 cases)` rc 0), R34-01 (`SELFTEST: PASS
(10 cases)` rc 0); (d) the landing check of C1 kill rule (e) is not CLEAN (the ledger is unchanged;
no journal is needed); (e) the landed diff touches anything beyond the seven frozen replaces.

**Declared ceilings:** a comment-only or grep-only "fix" that drops the executed leg would read 5 —
`c3-blanket` = 4 proves the executed leg discriminates; the counter does not verify where the
selftests write beyond the probe run; case counts are frozen to today's measured values.

## Controls and receipts

All committed with this plan under `.ufo/waves/round-43/controls/` (measured at `5f3566c`, recorded
in `measured-at.txt`): `c1-old-real.txt` (5), `c1-old-K1.txt` (0), `c1-old-K3.txt` (0),
`c1-old-fakeC.txt` (5), `c1-old-m3-K1.txt` (5), `c1-old-m5-K3.txt` (5), `c1-blanket-refuse.txt` (0),
`c1-blanket-accept.txt` (0), `c1-new-real.txt` (6), `c1-new-K1.txt` (0), `c1-new-K3.txt` (0),
`c1-new-fakeC.txt` (5), `c1-new-m3-K1.txt` (6), `c1-new-m5-K3.txt` (6), `c2-base.txt` (0),
`c2-blanket-0.txt` (0), `c2-blanket-1.txt` (0), `c3-base.txt` (0), `c3-pos.txt` (1),
`c3-blanket.txt` (4). Command: `bash plans/round-43-controls.sh`; counters: `bash plans/round-43-c1.sh`,
`bash plans/round-43-c2.sh`, `bash plans/round-43-c3.sh`.

## Mistakes mined this round (from the round-42 closure; lesson carries the table)

- **M42-4** — the round-42 report's diff-stat sentences (+23/−3, +7/−1) disagree with
  `git diff --numstat` (21 2, 6 1); non-verdict-bearing; captured-by none; fix = QUALITY row
  (every report diff-stat is re-derived by numstat before filing).
- **M42-5** — the round-42 `build-results.json` carried no per-seat `status` field; captured-by
  none; fix = seat liveness recorded per seat from `results.json` in this round's report.

## Routed (named, not claimed this round)

1. `expect-journal.sh` `*.json` discovery failing closed (exit 2) on a wave directory — a frozen-interface
   change needing its own predicate; no slot (three claims frozen).
2. C3 counter defects M40-9 / M40-10 / M40-17 (round-40 instruments are closed-round evidence;
   rewriting them is a re-freeze, not a patch).
3. The owed appended erratum to the round-40 report (round-41 routed item 3) — the erratum lands in
   this round's lesson naming the amended-in-place report, not by editing the round-40 report bytes
   (the L1 write scope covers `.ufo/reports/round-43/kagi.md` only).
4. Considerthese `2026-10-26.md` proposals 1 and 3 (unchanged reason: proposal 1 is operator policy
   under HOLD; proposal 3 needs its own predicate; no slot).
5. L0 open (operator-owned): `.ufo/l0-questions.md` line 368 — the retirement form for the
   unconditional `DELETED` rule; routed around, not assumed.
6. A 6-key answer-key gate passes the new C1 counter (named ceiling above) — a shape-level control
   is a later round's predicate amendment.
7. The old counter's mutants (`mut-m3-old`, `mut-m5-old`) are receipts, not committed instruments;
   a durable counter-mutation battery is later work if the fleet wants it.

## Wave contract

One v1 wave of the 10 seats above; every seat works in its own scratch sandbox at the predeclaration
commit, never edits the lane, delivers files + receipts under `.ufo/waves/round-43/build/<seat>/`,
and yields per-seat status explicitly (M42-5 fix). The L1 integrates, measures the final receipts,
and lands the round.
