# R62ScribeEntry — entry draft: instrument falsifiability

Seat `R62ScribeEntry` (scribe, w1, kagi round 62 attempt 1). Deliverable:
`corpus/knowledge/claim-instrument-falsifiability.md` (the instrument contract entry for the
round's two claims), plus this report and the receipts under
`.ufo/waves/round-62/build/R62ScribeEntry/`.

Scope: the one entry file and the build receipts. No product code, no instrument, no judge,
no commit. Scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ScribeEntry/`, deleted
before yielding. No tool installed or upgraded.

## What the entry contains

Seven sections as the assignment names them, with the four header lines
(`source:`, `verified-at:`, `recheck: 180d`, `Reverify: R62-01, R62-02` — the two ids are
placeholders for the L1):

- **The bypass class** — the token-presence defect, the five forged trees B3–B7 with their
  BASE readings, the three shapes (negation, vacuous restatement, swapped pairing), and the
  stronger observation that the seven per-item detail lines are byte-identical on all nine
  trees.
- **The polarity rule** — the closed negator set, the 5-token look-behind truncated at
  `.`/`;`/`:`, the `not only` idiom, I3's 12-token `A3 item 2` subject window, and the
  published NegEx trigger-scope shape (S130) with its stated failure mode (S131).
- **The pairing rule** — fraction and percentage derived from the same pair and adjacent in
  one expression, with the derived pairs printed by the checker.
- **The mutation-kill contract** — `--selftest` must execute its own aggregation; the
  constant `decide` mutant (M-A), the unconditional shim mutant (M-B), the guard challenge
  leg (G), and the expected-observable requirement; grounded in S128/S129's kill/survive
  definition.
- **Measured** — before→after for both claims, every number with its command and receipt.
- **Bounds** — nine named ceilings.
- **Falsifiers** — twelve observations that would make the entry wrong.

## Measured (this seat's own runs)

**C1 before, BASE `60b5b7b`.** Nine trees (unmodified, B3–B7, P3–P5) built from the plan's
anchor→replacement pairs (each anchor occurs exactly once); every tree reads
`C1_ROUTED: value=0 population=7 i1..i7=1 guard=0`, rc 1 ⇒ accepted = 5 of 5. The
`--verbose` item lines are byte-identical across all nine trees (72-line receipt). The
frozen counter's BASE control reads
`C1_BYPASS: accepted=5 population=5 guard=0 (real=1 selftest=0 stub=1 paraphrase=1)` rc 1.

**C2 before, BASE.** Base/M-A/M-B `--selftest` each `C2_SELFTEST: PASS (cases=11)` rc 0
(both mutants survive); the stub-trial tree `C2_SEAL_TRIAL: value=0 … guard=1` rc 1 (the
guard does not discriminate); the real trial `value=5 tests=5 pass=5 shims=5 vectors=ok/5
selftest=1 guard=1 … cases=63` rc 0. killed = 0 of 3.

**C1 after, working tree.** Checker sha256 `60bffd05…` at the first run and `f2afd9b8…`
(75 cases) at the second: unmodified `value=0`; B3 `value=1 … i3=0`; B4 `i4=0`; B5 `i5=0`;
B6 `i6=0`; B7 `i7=0`; P3–P5 `value=0`. Each forgery is rejected by exactly the item it
targets; accepted = 0 of 5. The counter verdict on the same tree (counter sha256
`138625b7…`) is `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1
paraphrase=1)` rc 0 — the frozen target line.

**C2 after, working tree.** Counter sha256 `20614697…`: unmutated `PASS (cases=21)` rc 0;
M-A `FAIL (cases=21 failed=6)` with six `decide-*` FINDINGs; M-B `FAIL (cases=21 failed=3)`
with three `shims-*` FINDINGs; stub tree `guard=0` rc 1. killed = 3 of 3. The real-trial
positive control reads `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5
selftest=1 guard=1 … cases=63` rc 0 (receipt `c2-real-hardened.txt`) — identical to the
BASE line, so the hardening did not weaken the gate. The round-62 counter on the same tree
reads `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` rc 0
(receipt `c2-verdict-worktree-2.txt`) — the frozen target line. An earlier run of the same
counter read `guard=0` because the real-trial leg failed under host contention (`real=0
real2=0 ops=0`, one shim `HBHEH`, receipt `c2-verdict-worktree.txt`); the trial run
directly on the same tree immediately after read `HOLDS holds=5` rc 0 (receipt
`trial-direct-1.txt`), so that failure is host load, not a counter defect.

## Findings (reported to owners; nothing edited outside this seat's files)

1. **C1 counter case-count parse (claim-blocking, reported to `R62ExecC1Counter` and the
   L1; fixed mid-wave).** `plans/round-62-c1.sh` parsed the checker's
   `C1_CHECK_SELFTEST: PASS (52 cases)` with `grep -oE '[0-9]+' | head -1`, taking the `1`
   of `C1`; at BASE it printed `cases=1`, so the guard's N ≥ 57 leg could never pass. The
   owner confirmed and fixed it (counter sha256 `19ea1131…`, parenthesised-count `sed`
   parse); the corrected BASE control reads `cases=52` and the same
   `accepted=5 population=5 guard=0` (receipt `c1-counter-base-fixed.txt`). My original
   receipt `c1-counter-base.txt` witnesses the defective bytes.
2. **Capture digest drift (reported to `R62ScoutSources` and the L1; resolved with one
   re-pin).** S130/S131/S133 rows and fetch rows claimed digests the committed bodies did
   not hash to. The scout restored S133 to the row's rendered HTML (digest now matches) and
   replaced S130/S131 with the token-free PMC efetch XML of the same records (the HTML
   embedded a live per-request token, so its digest was not re-fetchable); the new raw
   digests are `cdbb4173…` (S130, 189603 B) and `80ec4326…` (S131, 101800 B), which match
   the files I measured. The registry rows still need the L1's re-pin to the XML URL and
   digests. The entry cites S130/S131 by capture path + digest + locate count.
3. **The hardened checker moved during the wave.** At my fixture run it printed
   `PASS (52 cases)` (below the guard's 57-case floor); it then read `FAIL (cases=75
   failed=2 names=i7-wrong-fraction,k5-negator-needle-unique)` and now reads
   `PASS (cases=75)`. The candidate guard leg (b) is therefore satisfiable on the current
   bytes; the L1's candidate receipt is the verdict.
4. **The plan gained Amendment A1 during the wave** (I6 denial clause, credited to the C1
   executor and grammar seats, dated before any candidate reading). The entry records A1 and
   states that the predicate, target, population and fixtures are unchanged. I did not
   verify the ordering beyond A1's own text.
5. **The entry still needs its landing duties** (L1): a `corpus/stamps.tsv` row, the two
   claim rows (`R62-01`/`R62-02`) in `corpus/claim-ledger.tsv`, and
   `bash corpus/claim-ledger.sh docs` on the candidate tree (QM5/QM61). I did none of these.
6. **The C1 counter could not measure a candidate tree (claim-blocking, reported and
   fixed).** `bash plans/round-62-c1.sh --tree <worktree>` printed only
   `c1-counter: SETUP measure leg failed` rc 2 (receipt `c1-counter-worktree.txt`).
   `measure_battery`'s loop ended with `[[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED+1))`;
   on the last fixture a rejected reading (the desired candidate state) made that `&&` list
   return 1, which became the function's status with `AF_ERR` empty, so the caller's
   `setup_die "${AF_ERR:-measure leg failed}"` fired. BASE passed only because every fixture
   is accepted there. The owner added `return 0`; the worktree verdict then read
   `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1)` rc 0
   (receipt `c1-verdict-worktree.txt`, counter sha256 `138625b7…` at that run; the file
   moved again later in the wave).

## Bounds

- The after readings are **working-tree** observations at the instrument digests named
  above, not the committed candidate; the instruments moved again during the wave. The
  entry labels them as such and keeps the frozen target as the claim's reading.
- The C2 real-trial leg is host-sensitive: one round-62 counter run read `real=0` under
  contention while the trial direct read `HOLDS holds=5` immediately after. The candidate
  receipt should be taken on a quiet host.
- The C1 counter's BASE line in the entry is the receipt from before the parse fix; the
  entry states the defect and that the candidate must read `cases` ≥ 57.
- No frozen predicate, target, POP, kill rule or item condition was amended by this seat.
- No credential material: the entry and receipts name shapes and counts only. No
  share/token/OTP/nonce/vault/item/field name is printed.
- Scratch deleted; the empty `kagi-r61/R61ExecCounterC2` parent created by my first real
  trial run was removed.

## Artifacts

- `corpus/knowledge/claim-instrument-falsifiability.md` (the deliverable)
- `.ufo/waves/round-62/build/R62ScribeEntry/notes.md` (grounding + gaps)
- `.ufo/waves/round-62/build/R62ScribeEntry/` receipts: `c1-base-census.txt`,
  `verbose-items.txt`, `c1-counter-base.txt`, `c1-counter-base-fixed.txt`,
  `c1-selftest-base.txt`, `c2-base-census.txt`, `c2-real-base.txt`, `mutA.diff`,
  `mutB.diff`, `fixture-anchors.txt`, `c1-hardened-census.txt`,
  `c1-hardened-census-2.txt`, `c1-hardened-selftest.txt`, `c2-hardened-census.txt`,
  `c2-real-hardened.txt`, `c1-counter-worktree.txt`, `c1-verdict-worktree.txt`,
  `c2-verdict-worktree.txt`, `c2-real-worktree-direct.txt`, `trial-direct-1.txt`,
  `capture-digest-check.txt`

SEAT-STATUS: complete
