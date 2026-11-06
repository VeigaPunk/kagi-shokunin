# Round 50 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `565c43a874b59cd216f4a55c8742db48fa854f16` (branch `master`; the
round-49 verifier spot-check landed at this tip and admitted round 49).
Counters: `plans/round-50-c1.sh`, `plans/round-50-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-50-controls.sh`
(every expected value written in the script before it ran; fixtures `.ufo/waves/round-50/controls/fixtures/`;
receipt `.ufo/waves/round-50/controls/controls-prefreeze.txt`). BASE receipts: `.ufo/waves/round-50/controls/`
(`verify-base.txt`, `c2-base-live.txt`, `census-start.txt`). Predeclaration commit: recorded in the
report. No earlier attempt of this round exists (`.ufo/watchdog.log`: one launch line for round 50).

## Axes and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation: line 9, window N = 3).
Capabilities entered in rounds 48 and 49, so the nudge does not fire. Every axis is tied lowest at 9,
so each claim works a lowest-scoring non-retired axis. C1 works operability, C2 the owned calibration
axis. No axis is retired or split.

Causal separability: C1 changes only `corpus/openbao-token-trial.sh` (one launch line and one setup
check); C2 changes only expect/note columns of ten `corpus/claim-ledger.tsv` rows plus the journal
`.ufo/waves/round-50/expectation-migrations.json`. C1's counter reads no ledger; C2's counter does not
run the trial (no frozen row invokes it). Controls K1-P (C1 change only) = 3 with C2 absent, and K2-P
(C2 change only) = 0 with the BASE trial.

## C1 — operability: the OpenBao trial leaves no dev server behind when its shell is SIGKILLed, 0 → 3

Problem (round-49 closure D4; lesson round-49 §Landing addendum): the trial's only cleanup is an
EXIT/INT/TERM/HUP trap. A SIGKILLed shell runs no trap, so its `bao server -dev` child is re-parented
and lives on; the L1 found 8 such servers after the round-49 wave. The routed wording ("start the server
in its own process group and kill the group") does not survive SIGKILL either: control K1-F1 (setsid
only) is expected to read 0.

Change: start the dev server under `setpriv --pdeathsig KILL` (util-linux 2.42.4, `/usr/bin/setpriv`),
which sets the Linux parent-death signal before exec'ing `bao`, so the kernel SIGKILLs the server when
the trial shell dies (source row to be opened in-round: prctl(2) `PR_SET_PDEATHSIG`, and setpriv(1)).
The five tests, the output grammar and the exit codes are unchanged.

Frozen predicate:
`C1_ORPHAN_SAFE: value = number of kill points K in {K1,K2,K3} at which no captured OpenBao dev-server process is alive 5 s after the measured tree's corpus/openbao-token-trial.sh is SIGKILLed, when POSITIVE = 1 and OBSERVED(K) = 1 for all three, else SETUP; target 3.`
K1 = first moment a captured server exists; K2 = stdout holds `TRIAL T1 `; K3 = stdout holds
`TRIAL T3 `. Captured = descendants of the trial shell or carriers of the run's `R50_NONCE`, whose
argv is `bao server …`; identity pid + starttime. POSITIVE = the frozen round-49 counter
(`plans/round-49-c1.sh --tree`) prints `value=5` on the measured tree (no harm to round-49 C1).

Controls (expected values in `plans/round-50-controls.sh` before the first run): K1-0 do-nothing 0;
K1-P reference (`fixtures/openbao-token-trial.ref.sh`) 3; K1-F1 setsid only 0; K1-F2 server detached
with `setsid nohup` and the nonce stripped 0; K1-F3 constant-HOLDS printer, no server, SETUP; K1-F4
pdeathsig server with constant HOLDS and no tests SETUP.

Kill rules (any fires ⇒ C1 not admitted): the frozen instruments (`plans/round-50-c1.sh`,
`plans/round-50-c2.sh`, `plans/round-50-controls.sh`, `plans/round-49-c1.sh`, the fixtures) differ
between predeclaration and candidate; the candidate trial changes any `TRIAL`/`OPENBAO_TRIAL` grammar
line or a test body (`git diff BASE <candidate> -- corpus/openbao-token-trial.sh` touches lines other
than the header comment, the setup checks and the server launch line); any committed file at the
candidate matches `r49-[0-9a-f]{24}`.

Named ceilings: Linux-only (prctl); the parent-death signal follows the thread that forked the server
(bash is single-threaded); a parent that dies between fork and prctl leaves the window prctl(2) names;
the counter cannot see a server that is neither a descendant nor a nonce carrier (a trial that
double-forks before exec and strips the environment) — K1-F2 covers the detached+stripped case only
while the server is still a descendant at the kill moment.

## C2 — calibration: the claim ledger agrees with the observed repo state on ten drifted rows, 10 → 0

Problem (measured at BASE, `controls/verify-base.txt`, clean clone): `claim-ledger.sh verify` reads
`CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=124)` with 12 FAIL. Ten FAILs are population
expectations the lane stopped migrating (`reason=verdict-not-final`): R13-01 and R24-06 (SCORECARD round
headings, stated 56, live 67), R21-02/R31-02/R33-02/R34-03 (census, stated rows=98, live 105), R22-03 and
R24-15 (revision-audit additions, stated 49, live 61), R24-05 (stamp identity, stated 122, live 124),
R38-01 (round-38 located-quote count, stated 5, live 8). The other two FAILs are out of scope: R25-02
(operator-routed) and R11-08 (citation gate; layout-bound — a lone clone can never read CLEAN; its
3 lane-owned unresolved citations are non-claim work).

Pre-freeze control history (all receipts committed): run 1 (`controls-prefreeze-run1.txt`, C2 controls
in parallel) and run 2 (`controls-prefreeze-run2.txt`, serial) both read K2-P `SETUP G6-no-digit-R24-15`,
14/15 MATCH. Cause: the reference rewrote `corpus/claim-ledger.tsv` without restamping it, so
`revision-audit.py --history` read `DRIFT stale=1` and R24-15's producer printed
`ROW_IDENTITY: SETUP (revision-audit --history failed)` — the counter failed closed as designed. Run 3
(`controls-prefreeze.txt`) adds the ledger restamp to `fixtures/migrate.py`; the counters and predicates
did not change between runs. The candidate therefore restamps `corpus/claim-ledger.tsv` in
`corpus/stamps.tsv` (path column unchanged, so R24-05's identity is unaffected).

Frozen predicate:
`C2_LEDGER_DRIFT: value = number of the ten frozen ids {R13-01, R21-02, R22-03, R24-05, R24-06, R24-15, R31-02, R33-02, R34-03, R38-01} named on a FAIL, POLICY or LAYOUT-INCOMPLETE line of bash corpus/claim-ledger.sh verify run on exactly those ten rows of the measured revision, when GUARD = 1, else SETUP; target 0 (BASE 10).`
GUARD (SETUP on any failure): G1 producers byte-identical to BASE (`claim-ledger.sh`, `sources-census.sh`,
`revision-audit.py`, `row-identity.sh`, `quote-locate.py`, `plans/round-38-c1.sh`); G2 id/command/exit/
timeout columns of the ten rows byte-identical to BASE (round-49 closure D2 folded in); G3 R25-02,
R29-01, R29-02, R38-03 byte-identical (operator boundary); G4 every BASE id present once; G5 every
changed expect journaled (`old_expect` = BASE, `new_expect` = measured, non-empty `reason`); G6 every
changed expect refuses the live last line with every digit run incremented by one.

Controls: K2-0 do-nothing 10; K2-P reference (expects = BASE live lines, journaled) 0; K2-F1 `.*`
expects SETUP; K2-F2 R13-01 command repointed to `echo 67` SETUP; K2-F3 migrated without journal SETUP;
K2-F4 R25-02 exit column edited SETUP; K2-F5 five of ten migrated 5; K2-F6 digit-class expects SETUP;
K2-F7 `row-identity.sh` edited SETUP.

Each migration's `reason` names the commit range and the content that moved the population (no
"re-measured" without a cause); a row whose drift is a regression rather than growth is fixed, not
migrated. Kill rules: R25-02, R29-01, R29-02 or R38-03 changes; any ledger row is lost; a candidate
expect is not fully anchored (`^…$`).

Named ceiling: these ten rows are revision-bound populations — every later round that adds a lesson,
a SCORECARD heading, a stamp row or a source row re-opens some of them until their expects move with it.
The candidate's expects are measured on the candidate's own content (this round's lesson, rows and
headings included).

## Frontier step and non-claim work (no counter; recorded in the lesson)

SOURCES rows for prctl(2) PR_SET_PDEATHSIG and setpriv(1), opened this round, cited by C1 (the sourced
claim). Mistake mining: round-49 report FAIL count 13 vs 12 (closure D1) and the orphan-server miss.
R11-08's three lone-clone UNRESOLVED citations; round-49 closure D5 (gpg/sigstore ceiling statement).
Each lands only if a seat delivers it checked; none is a claim.
