Author: R72MutLater (mutation-tester)
Seat: falsifiable-hypothesis QM24 later-release probe, round 72 attempt 1, wave w1.
Claim BASE: b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9
Candidate: a947a42c52dc5b64cc9be1eef98207712fca7c42
Spare off-ramp per seat spec: "if H is false by the letter, do not stall — file a
one-line clarification, keep the probe going."

# Hypothesis H (seat spec, QM24 last sentence)

H: "on the candidate table, an observation of a newer stable release (Vault 2.2.2,
OpenBao 2.7.3) makes the re-armed derived clocks read `fired`, while on the BASE
table the same observation produces no new verdict for those ten rows (they
already read fired)."

# Probe design (offline; zero network fetches this seat)

- Extracted `b2f3dd66` and `a947a42c` with `git archive` into scratch
  ($S/base, $S/cand). 0 network calls: every observation below comes from the
  committed `.ufo/waves/round-72/final/observe-r72.json` plus a synthetic
  later-release copy (same format, `parsed_version` 2.2.2 / 2.7.3, `verdict`
  `fired` on the four Vault F ids S013/S022/S023/S024 and the six OpenBao F ids
  S014/S015/S016/S021/S025/S026). No network, no counter runs, no secrets.
- Called the gate's own `evaluate()` (`corpus/release-clock.py:552`) directly on
  each extracted tree with every receipt variant, recording its own
  `print_result` summary, fired/derived/observed counts, and per-F-id table vs
  receipt verdicts. Three receipt/table variants:
  1. `r72-current` (committed receipt: 2.2.1/2.7.2, all `not-fired` on F).
  2. `r72-later` (synthetic 2.2.2/2.7.3 `fired` on F; dates unchanged).
  3. `table-updated + later` (the table's own observed/verdict cells updated to
     `fired` at 2.2.2/2.7.3, receipt dates aligned) — the "fixture must fire the
     successor" state QM24 actually names.
- Selftest control: `python3 corpus/release-clock.py --selftest` on BASE:
  `RELEASE_CLOCK_SELFTEST: PASS (121 cases)` — the detector is live, not vacuous.

# Actual outputs

Pristine trees, current committed receipt:

- BASE table + round-54 default receipt (the shipped gate run):
  `python3 corpus/release-clock.py --root <base>` ->
  `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)` rc 0.
  The 14 fired include the ten F rows (S013 S014 S015 S016 S021 S022 S023 S024
  S025 S026 at 2.2.0/2.7.1 -> observed 2.2.1/2.7.2), plus S012, S027, S028, S072.
- CAND table + round-72 default receipt:
  `python3 corpus/release-clock.py --root <cand>` ->
  `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=4 derived=17)` rc 0.
  The ten F rows now read `not-fired` at 2.2.1/2.7.2 through S174/S175; the
  remaining 4 fired are exactly S012, S027, S028, S072 (per plan: "S012 stays
  on S034 and stays fired; S027/S028 and S072 stay fired — none is in F").
- BASE table + cand r72 receipt (control): every one of the 32 rows is
  `RECEIPT-MISMATCH` (table `observed_at` is 2026-11-07, receipt dates are
  2026-11-09); `RELEASE_CLOCK: FAILED (… observed=0 …)` rc 1. Inconclusive by
  the seat rule — a baseline failure proves nothing about verdict logic — so
  the BASE-vs-CAND comparison below is drawn only from date-aligned runs.

Later-release observation, NO table update (variant 2):

- CAND gate x r72-later:
  `RELEASE_CLOCK: FAILED (… observed=22 fired=4 derived=7)` with exactly ten
  `RECEIPT-MISMATCH` errors — one per F id. Per-F detail: CAND table says
  `not-fired/2.2.1->2.2.1` (or 2.7.2), synthetic receipt says `fired/2.2.2`
  (or 2.7.3). The gate refuses to count the observation as a fired clock until
  the table cell moves; `fired` stays at 4 (the non-F four).
- BASE gate x r72-later: `RELEASE_CLOCK: FAILED (… observed=0 …)`, all 32 rows
  `RECEIPT-MISMATCH` (date skew). Table cells stay `fired/2.2.0->2.2.1` /
  `fired/2.7.1->2.7.2` regardless of the later receipt, because
  `evaluate()` never reads a verdict out of a receipt it cannot match
  (`receipt_matches`: receipt verdict/parsed_version/date/url must equal the
  table cell). So the second half of H ("no new verdict on BASE") holds, but
  for the wrong reason in the letter: BASE produces no new verdict because it
  cannot match ANY later receipt, not because the rows were already fired.

Table-updated + later receipt (variant 3, QM24's actual "fixture must fire"):

- CAND table-updated + later receipt:
  `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)` rc 0.
  All ten F rows read `fired` with no per-row errors; fired total returned to 14.
- BASE table-updated + later receipt (the same table edit applied to BASE bytes):
  `RELEASE_CLOCK: FAILED (… observed=10 fired=10 derived=10)` — the only
  observed rows are the ten F rows, which DO read `fired` with no errors; the
  other 22 are `RECEIPT-MISMATCH` on date, not on verdict. I.e. the identical
  table update fires the successor on BASE bytes too. The only things that could
  discriminate are the feed binding (S034/S035 vs S174/S175) and the DERIVATION
  rule — and on a table that still anchors 2.2.0/2.7.1 the later observation
  reads fired on either feed.

Why the letter of H is false (mechanism, with committed lines):

- `evaluate()` treats the TABLE cell as the verdict and the receipt as a
  consistency check. A receipt whose `verdict`/`parsed_version` differs from the
  table is a `RECEIPT-MISMATCH`, never a "new verdict" (release-clock.py
  `receipt_matches`, lines 475-513; `evaluate` receipt block, lines ~678-694).
  Observation alone cannot transition any row.
- The live observe path (`observe_one`, lines ~880-922) does compute
  `verdict = fired` from `parsed_version != anchored` at observation time, and
  the candidate's receipts were produced that way — but QM24's fixture compares
  the COMMITTED table against a RETAINED receipt, and `evaluate()` only credits
  `fired` when the table cell itself says `fired` with a matching receipt. A
  "later-release fixture" that reaches the gate therefore requires a table edit
  first (which is exactly the round-72 re-arm the candidate performs for the
  2.2.1/2.7.2 transition, and what a future round would do again for 2.2.2/2.7.3).
- Counter-evidence the candidate still satisfies QM24's intent: the round-37
  successor feeds S089/S090 (Vault/OpenBao at 2.2.1/2.7.2, opened 2026-11-05)
  are `recheck = 90d`, NOT `on-release`, so `evaluate()` never binds them and
  they could never fire — the re-arm had to be a table re-pin through new
  `on-release`-compatible feed rows S174/S175, which the candidate does. The
  re-armed rows are live in the sense that, once the table is updated for the
  next release (variant 3, CAND), the gate grades them `fired` and CLEAN;
  pre-update, a later observation is loudly `RECEIPT-MISMATCH` ×10, not
  silently not-fired.

# Clarification (one line, spared per spec)

The gate has no observation-driven verdict transition: a later-release receipt alone yields RECEIPT-MISMATCH on CAND (not `fired`), and the same table update fires on BASE bytes too — H is false as written; QM24's intent ("the successor must be able to fire") holds only after the table cell moves, not from the observation itself.

# Killed/survived/inconclusive

- Detector liveness: killed (killed mutant = the probe detects verdict logic;
  selftest 121 PASS, pristine BASE/CAND runs CLEAN with the expected fired
  counts, the `fired feed`/`derived fired anchor remains bound` selftest cases
  pass on both trees).
- H as stated: KILLED (falsified) — variant 2 shows an observation of 2.2.2/2.7.3
  does NOT make the re-armed clocks read `fired` on the candidate table; it
  reads `RECEIPT-MISMATCH` ×10 with fired unchanged at 4. The BASE half is
  uninformative (date/date-skew `RECEIPT-MISMATCH` everywhere).
- Executed-before hashes: BASE and CAND `corpus/release-clocks.tsv` and
  `corpus/release-clock.py` were extracted read-only via `git archive`;
  the only bytes changed were in scratch copies. Restoration evidence: scratch
  `$S` (`/fast/scratch/hyaku/kagi-r72/R72MutLater`) was removed before yield;
  no lane or fleet file was modified by this seat (probe scripts and the
  synthetic receipt live only in the wave dir); no commit/push was run.

# Negative control

`late-supersede-check.py` (wave dir) records the S089/S090 control: the
round-37 2.2.1/2.7.2 feed successors were `90d`, so no table edit could fire
them — a later feed row without a table re-pin is invisible to `evaluate()`.
That asymmetry is exactly the defect the candidate fixes and the reason H's
"observation" framing misses: the re-arm is a table action.

Tooling: no installs (probe uses system `python3` + stdlib only; the probe
spec explicitly allows offline `git archive` extraction, which is how the two
trees were produced). Nothing to record under the operator tooling directive.

FINDING LB-1 falsifies-wording The later-release fixture fires only after a table edit, not from the observation alone, so H as written is false even though the re-armed clocks grade fired once the table moves.
FINDING LB-2 neutral BASE and CAND both read fired for the same updated table, so the probe does not separate the re-arm from the table edit - the discriminator is the feed binding S174/S175 vs the 90d S089/S090 pattern, not the observation.
SEAT-STATUS: complete QM24 probe executed offline against git-archive extractions; H falsified by the letter, transition mechanism and restoration recorded.
