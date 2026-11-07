# Round 51 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `214d8bf530a0c87c00686493f21af15396284793` (branch `master`; the
round-50 verifier spot-check landed at this tip and admitted round 50).
Counters: `plans/round-51-c1.sh`, `plans/round-51-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-51-controls.sh`
(fixtures `.ufo/waves/round-51/controls/fixtures/`; receipt
`.ufo/waves/round-51/controls/controls-prefreeze.txt`; run 1 of the C2 half, with two fixture-side
expectation errors and their correction, kept as `controls-prefreeze-run1.txt`). Census at round start:
`.ufo/waves/round-51/controls/census-start.txt` (`kagi ok`, rc 0, rows 107). Predeclaration commit:
recorded in the report. No earlier attempt of this round exists (`.ufo/watchdog.log`: one launch line
for round 51).

## Axes and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation: line 9, window N = 3).
Capabilities entered in rounds 48 and 49 (round 50 added none), so within the window of rounds 48–50 the
nudge does not fire. Every axis is tied lowest at 9, so each claim works a lowest-scoring non-retired
axis. C1 is a capability acquisition booked under operability; C2 works the owned calibration axis. No
axis is retired or split.

Causal separability: C1 adds `corpus/openbao-wrap-trial.sh`, one registry row (the response-wrapping
page, expected id S108) with its fetch row, and a `## Measured (round 51` section in
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; its counter reads no manifest, plan heading or
SCORECARD row. C2 adds manifest rows to `corpus/claims-declared.tsv`, this round's SCORECARD post-move
section and one current-readings line in `SCORECARD.md` §Capabilities; its counter runs no trial. Control
K1-P (C1 change only, BASE manifest) reads 5, and K2-P (C2 change only, no trial) reads 0.

## C1 — operability: the lane executes the OpenBao response-wrapping mechanics its source documents, 0 → 5

Capability acquisition (`AXES.md` §Capabilities). Ground the lane did not hold: at BASE no corpus file
names `sys/wrapping` (`grep -rl 'sys/wrapping' corpus/` prints nothing) and no registry row cites the
OpenBao response-wrapping page. Source (opened this round, 2026-11-07, capture
`.ufo/waves/round-51/capture/S108.body`, decoded body sha256 `a555301e8f61a407130515449309b05c4e2c7a936f8f1bdf1921e2f9cc32ed55`,
37186 B, OpenBao docs Version 2.7.x): https://openbao.org/docs/concepts/response-wrapping/.

Change: `corpus/openbao-wrap-trial.sh` (reference fixture
`.ufo/waves/round-51/controls/fixtures/ref/corpus/openbao-wrap-trial.sh`) runs five tests against a
throwaway `bao server -dev` on 127.0.0.1 (random root token kept in scratch, `setpriv --pdeathsig KILL`,
values are random `r51-` nonces, nothing token-shaped printed): T1 single use, T2 wrap TTL separate from
the secret, T3 unauthenticated lookup reports the creation path and does not consume, T4 rewrap moves the
data to a new token and spends the old one, T5 a read-and-rewrap carries creation path
`sys/wrapping/wrap`. The knowledge entry gains `## Measured (round 51 …)` with one `- T<n> ` line per
test; the registry gains the source row (tier A, `mined`, `recheck 180d`).

Frozen predicate:
`C1_OPENBAO_WRAP: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and SRC = 1, else 0; target 5 (BASE 0, trial absent).`
DISCRIMINATE(T): the measured tree's trial prints exactly one `TRIAL T HOLDS` line in the real run and
exactly one `TRIAL T BROKEN` line under T's designated falsifier (SH1 unwrap replays its first answer,
SH2 `kv get` wrap TTL forced to 600s, SH3 lookup also unwraps, SH4 rewrap echoes the old token, SH5
lookup replays its first answer), and the entry's round-51 Measured section holds a `- T<n> ` line naming
`OpenBao 2.7.2`. Runs are path-blind (round-50 closure D3): each of the seven runs (real, none, SH1–SH5)
gets a fresh random hex bin dir holding a byte-identical dispatcher `bao` plus a `.mode` sidecar, its own
HOME/TMPDIR/--work, and the runs execute in random order. SRC: exactly one registry row whose source cell
holds the page URL, status `mined`, and the trial's first 20 lines name its id. Details in the counter
header.

Controls (expected values written before the run; `plans/round-51-controls.sh`): K1-0 BASE 0; K1-P
reference 5; K1-F1 constant-HOLDS printer 0; K1-F2 PATH reader (`*real*`) 0; K1-F3 bin-dir-name reader
(`sh<n>`) 0; K1-F4 dispatcher-content reader 0; K1-F5 `.mode` reader 5 (the named ceiling, expected to
pass); K1-F6 registry row absent 0; K1-F7 Measured section absent 0; K1-F8 trial leaks one nonce 0;
K1-F9 registry row `queued` 0.

Kill rules (any fires ⇒ C1 not admitted): `plans/round-51-c1.sh`, `plans/round-51-c2.sh`,
`plans/round-51-controls.sh` or the fixtures differ between the predeclaration and the candidate; the
candidate's `corpus/openbao-wrap-trial.sh` differs from the reference fixture in any line that does not
start with `#`; any committed file at the candidate matches `r51-[0-9a-f]{24}`; `~/.local/bin/bao` is
replaced (the pin).

Named ceilings: a trial that reads the `.mode` file beside its bao (K1-F5 reads 5), or keeps state
outside its own HOME/TMPDIR/--work across runs, still tells the runs apart; the shims are client-side, so
a test discriminates against a lying CLI, not against a misbehaving server; one OpenBao version (2.7.2)
and the KV v2 mount only; T2's 2 s/4 s timing can read BROKEN on a host stalled past the wrap TTL in the
other direction (never observed; the token cannot outlive its TTL).

## C2 — calibration: the declared-claim manifest and the capabilities readings agree with the repo, 3 → 0

Problem (measured at BASE, `bash plans/round-51-c2.sh 214d8bf5` → `value=3 M=2 V=1`): round 50 landed two
claims (`plans/round-50.md` headings `## C1 — operability:`, `## C2 — calibration:`; SCORECARD
`## Round 50 — post-move` rows `[C1]`, `[C2]`) but never added them to `corpus/claims-declared.tsv`, so the
lane's declared-axis gate reads `CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)` (`MISMATCH 50 C1
no-manifest-row`, `MISMATCH 50 C2 no-manifest-row`); and the §Capabilities current-readings line states
that gate as `CLAIMS_DECLARED: CLEAN (claims=23)` (round-48 key K07 DIFF). The lane's own description of its
claims and its repertoire disagree with what the commands print.

Change: append the manifest rows `50 C1 operability`, `50 C2 calibration`, `51 C1 operability`,
`51 C2 calibration`; land this round's `## Round 51 — post-move` section with tagged rows; append one
current-readings line to §Capabilities that states the executed claims-declared reading and names the
revision it measured. No gate byte changes; the round-48 counter and the gate are pinned.

Frozen predicate:
`C2_SELF_ASSESSMENT: value = M + V, where M = the number of MISMATCH lines that the measured revision's bash corpus/claims-declared.sh --root <checkout> prints and V = the value= that the frozen round-48 counter bash plans/round-48-c2.sh <rev> prints for the measured revision, when GUARD = 1, else SETUP; target 0 (BASE 3).`
GUARD: the gate and the round-48 counter carry their BASE sha256; every `plans/round-*.md` present at
BASE is byte-identical at the measured revision; every BASE manifest data row is present unchanged; both
producers print their verdict lines (else SETUP, never zero).

Controls: K2-0 BASE 3; K2-P positive fixture 0; K2-F1 readings line only 3; K2-F2 round-50 axes swapped 5;
K2-F3 round-50 plan headings deleted SETUP; K2-F4 gate replaced by a constant CLEAN printer SETUP; K2-F5 a
BASE manifest row deleted SETUP; K2-F6 manifest and section without the readings line 1; K2-F7 readings
line states a wrong count 1.

Kill rules: the instruments differ between predeclaration and candidate; any BASE manifest row or BASE
plan file changes; `grep -c 'R25-02,R29-01,R29-02' SCORECARD.md` (ledger R31-06) stops reading 1.

Named ceilings: the gate reads the lane's own text, not axis fitness (QM41); the claims count in a
readings line is revision-bound and is correct only at the revision it names; M and V share one
population (the gate's verdict line), so a round that lands claims without manifest rows re-opens both.

## Frontier step and non-claim work (no counter; recorded in the lesson)

- Sourced claim: C1 rests on the response-wrapping row (S108), opened this round; its quotes are located
  with `corpus/rendered-text-v1.py locate` against the committed capture.
- Mined mistake: round 50's claims never entered the manifest (captured-by: none — the gate is not a
  ledger row and the round-50 landing did not run it); the C2 counter is the fix shown able to fail.
- Round-50 closure defects D1–D5: D3 → C1's path-blind runs and a connector scan in the wave; D4 → a seat
  names the non-row finding behind `verify_rc=1`; D5/F5 → the lane-status line names the fourth routed
  row (R38-03) while keeping the R31-06 substring; D1, D2 → measured or routed in the report.
- Harm check: full `claim-ledger.sh verify` on a clean clone of BASE and of the landing tip, FAIL counts
  compared row by row.
