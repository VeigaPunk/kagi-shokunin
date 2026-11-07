# R62ScribeEntry — notes (grounding, gaps, receipts)

Seat: `R62ScribeEntry` (scribe; entry `corpus/knowledge/claim-instrument-falsifiability.md`).
Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`. Plan `plans/round-62.md`
(predeclaration `8e5463c7937dccdd97fd5a812b8091f83b708aa7`, plus the uncommitted Amendment A1
that landed during the wave).

## What is grounded, and by what

- **BASE tree.** `git archive 60b5b7b | tar -x` into
  `${HYAKU_SCRATCH}/kagi-r62/R62ScribeEntry/base` (10689 files). Checker sha256
  `d525ee28…`, counter sha256 `c7d9e272…` — both equal the round-61 spot-check's pins.
- **Eight fixture trees.** Built from the plan's anchor→replacement pairs; every anchor
  occurs exactly once (receipt `fixture-anchors.txt`; the builder fails closed otherwise).
- **C1 BASE census.** Nine trees (unmodified, B3–B7, P3–P5) each read
  `C1_ROUTED: value=0 … i1..i7=1 guard=0`, rc 1 (receipt `c1-base-census.txt`). The
  `--verbose` item lines are byte-identical on all nine trees (receipt `verbose-items.txt`,
  72 lines = 9 blocks × 7 item lines) — the forgeries are invisible to every item.
- **C1 counter BASE control.** `bash plans/round-62-c1.sh` (default BASE) reads
  `C1_BYPASS: accepted=5 population=5 guard=0 (real=1 selftest=0 stub=1 paraphrase=1)` rc 1
  (receipt `c1-counter-base.txt`).
- **C2 BASE census.** Base/M-A/M-B `--selftest` each `PASS (cases=11)` rc 0; stub-trial tree
  `value=0 … guard=1` rc 1 (receipt `c2-base-census.txt`); real trial `value=5 … shims=5
  vectors=ok/5 … cases=63` rc 0 (receipt `c2-real-base.txt`). Mutant diffs receipted as
  `mutA.diff`/`mutB.diff`.
- **C1 after (working tree).** Checker sha256 `60bffd05…` at run start; nine-tree loop reads
  unmodified `value=0`, B3 `i3=0`, B4 `i4=0`, B5 `i5=0`, B6 `i6=0`, B7 `i7=0`, P3–P5
  `value=0` (receipt `c1-hardened-census.txt`). Each forgery rejected by exactly its item.
- **C2 after (working tree).** Counter sha256 `20614697…`; unmutated `PASS (cases=21)`;
  M-A `FAIL (cases=21 failed=6)` with six `decide-*` FINDINGs; M-B `FAIL (cases=21 failed=3)`
  with three `shims-*` FINDINGs; stub tree `guard=0` (receipt `c2-hardened-census.txt`).
- **Sources.** S128/S129 (mutation-testing kill/survive) and S130/S131 (NegEx trigger scope
  and its failure mode) are the scout's admitted rows in `capture/notes.md`; every quote I
  cite re-resolves `count=1` with `corpus/rendered-text-v1.py locate` (my runs, not the
  notes'). S128/S129 digests match the capture files; S130/S131 digests do not (below).

## What I could not ground / what moved under me

1. **Capture digest drift (reported).** `corpus/source-fetches.tsv` and `corpus/SOURCES.md`
   rows 138/139 claim S130 sha256 `68dde47f…` and S131 `87c36250…`; the committed bodies
   hash to `cdbb4173…` and `80ec4326…` (S133 also drifts: row `05dbe35f…`, file
   `605ce551…`). Receipt `capture-digest-check.txt`; reported to `R62ScoutSources` and the
   L1. The entry therefore cites S130/S131 by capture path + locate count, not by digest.
   The scout may still re-fetch; the L1 must re-pin at landing.
2. **The C1 counter's case-count parse (reported, fixed mid-wave).** At BASE it printed
   `selftest rc=0 pass=1 cases=1` because `grep -oE '[0-9]+' | head -1` takes the `1` of
   `C1_CHECK_SELFTEST`. The owner confirmed and fixed it (counter sha256
   `19ea1131c50e9853ac691ecc486e196f011f1b35ae7f32fc089afcc75c1912d2`, parenthesised-count
   `sed` parse); my BASE receipt `c1-counter-base.txt` witnesses the defective bytes, and
   the regenerated BASE control is `c1-counter-base-fixed.txt` (expect `cases=52`,
   `guard=0` because 52 < 57). Without the fix the guard could never reach 1 on any tree.
3. **The hardened checker was mid-edit at my run.** Its selftest printed `PASS (52 cases)`
   (below the guard's 57-case floor); minutes later it read `FAIL (cases=75 failed=2
   names=i7-wrong-fraction,k5-negator-needle-unique)`. The candidate guard leg (b) is
   therefore not yet demonstrated; the L1's candidate receipt is the verdict.
4. **The hardened C2 counter may also move.** My readings are against sha256 `20614697…`;
   a later edit would need a re-run. The real-trial positive control reads
   `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 … cases=63`
   rc 0 (receipt `c2-real-hardened.txt`), identical to the BASE line.
5. **The plan was amended during the wave.** `plans/round-62.md` gained `## Amendment A1`
   (I6 clause (d): the correction line carries none of `times are correct`, `times are
   right`, `is correct`, `are correct`). The entry records A1 and states that the
   predicate, target, population and fixtures are unchanged. A1's own text says it was
   written before any candidate reading; I did not verify that ordering beyond the text.
6. **`Reverify:` ids are placeholders.** `R62-01`/`R62-02` are the L1's to assign; the
   claim rows and the entry's stamp row must land in the same commit (QM5/QM61), which I
   did not do.
7. **S130/S131 rows' `used-by`** already names `claim-instrument-falsifiability` (4
   occurrences in `corpus/SOURCES.md`), so QM71 is satisfied for the ids I cite.
8. **The C1 counter could not measure a candidate tree (reported, fixed).**
   `measure_battery`'s loop body ended with `[[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED
   + 1))`; on the last fixture (B7) a rejected reading — the desired candidate state — made
   the `&&` list return 1, which became the function's return status with `AF_ERR` empty,
   so the caller printed `SETUP measure leg failed` and exited 2. BASE passed only because
   every fixture is accepted there. Receipt `c1-counter-worktree.txt`; reported to
   `R62ExecC1Counter` and the L1. The owner added `return 0` (counter now sha256
   `138625b7…`), and the worktree verdict reads `C1_BYPASS: accepted=0 population=5
   guard=1 (real=1 selftest=1 stub=1 paraphrase=1)` rc 0 (receipt
   `c1-verdict-worktree.txt`).
9. **The C2 real-trial leg is host-sensitive.** One round-62 counter run on the worktree
   read `C2_HARDENED: killed=3 population=3 guard=0 (ma=1 mb=1 g=1 selftest=1 real=0)` rc 1
   (receipt `c2-verdict-worktree.txt`): the three legs fired, but the real-trial leg failed
   under contention (`real=0 real2=0 ops=0`, one shim `HBHEH`). A direct trial run on the
   same tree immediately after read `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0`
   rc 0 in 13.8 s (receipt `trial-direct-1.txt`), and a second counter run read
   `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` rc 0
   (receipt `c2-verdict-worktree-2.txt`). The candidate receipt should be taken on a quiet
   host; the entry names the sensitivity in §Bounds.

## Scratch and host discipline

- All work under `/fast/scratch/hyaku/kagi-r62/R62ScribeEntry/` (BASE extraction, fixture
  trees, mutants, counter scratch redirected with `HYAKU_SCRATCH`). Deleted before yielding.
- The C2 counter's default scratch namespace is `${HYAKU_SCRATCH}/kagi-r61/R61ExecCounterC2`;
  my first real-trial run created that parent empty and its per-run trap removed the run
  dir. The empty parent was removed at cleanup.
- No `git add/commit/stash/push`, no `jj` mutation, no writes outside the lane paths this
  seat owns (the entry, `notes.md`, the build receipts) and scratch.
- No credential material: the entry names shapes and counts only; no share, token, OTP,
  nonce or vault/item/field name appears in any receipt.

## Receipts (all under `.ufo/waves/round-62/build/R62ScribeEntry/`)

`c1-base-census.txt`, `verbose-items.txt`, `c1-counter-base.txt`, `c1-selftest-base.txt`,
`c2-base-census.txt`, `c2-real-base.txt`, `mutA.diff`, `mutB.diff`, `fixture-anchors.txt`,
`c1-hardened-census.txt`, `c1-hardened-selftest.txt`, `c2-hardened-census.txt`,
`c2-real-hardened.txt`, `capture-digest-check.txt`.
