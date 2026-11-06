# Round 50 — the OpenBao trial survives a SIGKILLed shell without leaving its dev server behind (C1, operability); the claim ledger agrees with the observed repo state on ten drifted rows (C2, calibration)

source: S106 (https://man7.org/linux/man-pages/man2/PR_SET_PDEATHSIG.2const.html, §DESCRIPTION, opened 2026-11-06); S107 (https://man7.org/linux/man-pages/man1/setpriv.1.html, §OPTIONS `--pdeathsig`, opened 2026-11-06)

Frozen plan: `plans/round-50.md` (predeclaration `7d3b2c01b375d5459abd7da79bb4063b7d728fc7`; BASE `565c43a874b59cd216f4a55c8742db48fa854f16`; no amendment). Counters `plans/round-50-c1.sh`, `plans/round-50-c2.sh`; pre-freeze controls `plans/round-50-controls.sh` (15 controls, all MATCH, `.ufo/waves/round-50/controls/controls-prefreeze.txt`; runs 1–2 kept as history). BASE receipts `.ufo/waves/round-50/controls/` and `.ufo/waves/round-50/final/c1-base.txt`, `c2-base.txt`. Candidate receipts `.ufo/waves/round-50/final/`.

Attempts: attempt 1 (L1 `KagiR50`) froze the plan, ran the controls, dispatched one v1 build wave of 12 seats and died before landing (`.ufo/watchdog.log`: `lane-dead-no-report kagi round=50`, 20:22:55 -03). Attempt 2 (L1 `KagiR50a2`) inherited and re-verified its uncommitted outputs: the C1 working-tree change (identical to the frozen reference fixture except one header comment naming S107), the two drafted registry rows S106/S107 with their fetch rows and captures (both captures re-fetched live by attempt 2 at 2026-11-06T23:25Z: byte-identical, sha256 `5e72367e…49144fc82` and `3bc0de99…7437770fd`), and the wave evidence. Nothing inherited was discarded.

## Claims

- **C1 operability — the OpenBao trial leaves no dev server behind when its shell is SIGKILLed, 0 → 3.** Problem (round-49 closure D4; `.ufo/waves/round-49/final/orphan-servers.txt`): the trial's only cleanup was an EXIT/INT/TERM/HUP trap; a SIGKILLed shell runs no trap, so its `bao server -dev` child was re-parented and lived on (8 such servers after the round-49 wave).
  - Change: `corpus/openbao-token-trial.sh` starts the dev server as `setpriv --pdeathsig KILL bao server -dev …` (util-linux 2.42.4 `/usr/bin/setpriv`) and refuses with `OPENBAO_TRIAL: SETUP no setpriv` when setpriv is absent. setpriv sets the parent-death signal and then execs the program (S107); the kernel sends that signal when the parent thread terminates, and the setting survives the exec of an ordinary binary (S106). Tests, output grammar and exit codes are unchanged.
  - Frozen predicate (verbatim, plan §C1 and counter header): `C1_ORPHAN_SAFE: value = number of kill points K in {K1,K2,K3} at which no captured OpenBao dev-server process is alive 5 s after the measured tree's corpus/openbao-token-trial.sh is SIGKILLed, when POSITIVE = 1 and OBSERVED(K) = 1 for all three, else SETUP; target 3.`
  - Controls: K1-0 do-nothing 0; K1-P reference 3; K1-F1 `setsid` only (the round-49 routed wording) 0; K1-F2 detached `setsid nohup` with the nonce stripped 0; K1-F3 constant-HOLDS printer SETUP; K1-F4 pdeathsig server, no tests SETUP — all MATCH.
  - Named ceilings (plan): Linux only; the signal follows the thread that forked the server (bash is single-threaded); a parent that dies between fork and prctl leaves the window prctl names; a server that double-forks and strips the environment is invisible to the counter.
- **C2 calibration — the claim ledger agrees with the observed repo state on ten drifted rows, 10 → 0.** Problem (BASE, `controls/verify-base.txt`): ten population expectations had not moved with the content the lane added in rounds 38–49 (`reason=verdict-not-final`).
  - Frozen predicate (verbatim): `C2_LEDGER_DRIFT: value = number of the ten frozen ids {R13-01, R21-02, R22-03, R24-05, R24-06, R24-15, R31-02, R33-02, R34-03, R38-01} named on a FAIL, POLICY or LAYOUT-INCOMPLETE line of bash corpus/claim-ledger.sh verify run on exactly those ten rows of the measured revision, when GUARD = 1, else SETUP; target 0 (BASE 10).`
  - Controls: K2-0 10; K2-P 0; K2-F1 `.*` SETUP; K2-F2 command repointed SETUP; K2-F3 no journal SETUP; K2-F4 boundary row edited SETUP; K2-F5 half migrated 5; K2-F6 digit-class SETUP; K2-F7 producer edited SETUP — all MATCH.
  - Migration causes (journal `.ufo/waves/round-50/expectation-migrations.json`, one `reason` per row naming the commit range and the content that moved it, walked commit by commit with `git show <c>:<path>`): SCORECARD round headings 56 → 67 at BASE across `209147c..565c43a` (rounds 42–49, one heading per post-move/pre-move section) plus this round's `## Round 50 — post-move` heading; registry rows 98 → 105 across `0ad617a` (S099), `072bb0b` (S100–S102), `8775582` (S103–S104), `a74ae53` (S105) plus S106/S107 this round; stamp rows 122 → 124 across `6d6b486` (round-42 lesson) and `a74ae53` (round-45 ISO entry stamped in round 49); revision-audit additions 49 → 61 across `b944735` (+10, round-38 quote gate files), `6d6b486` (+1), `a74ae53` (+1); round-38 located quotes 5 → 8 at `072bb0b` (round-45 quote manifest rows). Every drift is growth, none a regression: no row's population fell.

## Gate

- **S106 — new, opened 2026-11-06** (seat R50ScoutSources fetch, `build/R50ScoutSources/fetch-receipt.txt`; re-fetched live by the L1 at 23:25Z, byte-identical): `https://man7.org/linux/man-pages/man2/PR_SET_PDEATHSIG.2const.html`, HTTP 200, decoded body sha256 `5e72367e…49144fc82`, 10684 B (capture `.ufo/waves/round-50/capture/S106.body`), Linux man-pages 6.19 dated 2026-02-08. Located quote (12 words): "The parent-death signal is sent upon subsequent termination of the parent thread" (`python3 corpus/rendered-text-v1.py locate capture/S106.body "<quote>"` → `count=1`). Admit: tier A, `mined`, `recheck on-release`, used-by this lesson (the census admits only corpus documents in `used-by`; the trial cites S106/S107 in its header comment).
- **S107 — new, opened 2026-11-06** (same seat, same re-fetch): `https://man7.org/linux/man-pages/man1/setpriv.1.html`, HTTP 200, decoded body sha256 `3bc0de99…7437770fd`, 20601 B (capture `capture/S107.body`); page from util-linux 2.43.devel dated 2026-08-03 — a development snapshot; the host binary is util-linux 2.42.4, whose `setpriv --help` lists the same `--pdeathsig` option. Located quote (8 words): "Keep, clear or set the parent death signal." (`count=1`). Admit: tier A, `mined`, `recheck on-release`, used-by as S106.
- **Rejected — `prctl(2)` (`https://man7.org/linux/man-pages/man2/prctl.2.html`) as a row** (fetched, HTTP 200, 26266 B, sha256 `ef698f6c…97866810`): the page lists `PR_SET_PDEATHSIG` only as a cross-reference to `PR_SET_PDEATHSIG(2const)`; it carries none of the semantics C1 rests on, so it adds no teaching beyond S106 (flip: a man-pages release that moves the semantics back into prctl(2)).
- **Rows added:** 2 (S106, S107; tier A 2). **Rows touched:** none. Registry 105 → 107.
- **Discernment sample (LEARNING.md):** admit — S106 (the semantics the change rests on, located quote, capture committed). Reject — prctl(2) (above).
- **Counting rule (E49-1):** every word count stated in this `## Gate` is `printf '%s' "<quote>" | wc -w`.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M50-1 | `number-drift` (a stated count of verdict lines differs from the cited receipt) | The round-49 report says the candidate ledger has 13 FAIL rows ("15 → 13", report lines 111, 112, 170, 244); `grep -c '^FAIL' .ufo/waves/round-49/final/verify-candidate.txt` prints 12 (round-49 closure D1). Receipt: `.ufo/waves/round-50/build/R50ScribeLesson/mistake-receipts.txt` §S1. | none — no gate compares a report's stated FAIL count with the receipt it cites; the non-author closure caught it. | `build/R50ScribeLesson/m50-1-fail-count.py TEXT RECEIPT` reads every "with N FAIL" / "from A to B" / "went A → B" assertion and compares it with `grep -c '^FAIL' RECEIPT`: **shown able to fail** — FLAG rc 1 on the filed round-49 report (4 assertions, 4 mismatches), OK rc 0 on the corrected sentences (`m50-1-corrected.txt`), and FLAG rc 1 again when pointed at the BASE receipt (receipt-sensitive). Criterion QM62. |
| M50-2 | `cleanup` (a trap is not a cleanup guarantee) | `.ufo/waves/round-49/final/orphan-servers.txt`: 8 re-parented `bao server -dev` processes after the round-49 wave; the BASE trial's cleanup is `trap cleanup EXIT` plus INT/TERM/HUP (`git show 565c43a:corpus/openbao-token-trial.sh`, lines 48–51), which SIGKILL bypasses. | none at round 49 — the round-49 counter killed the trial politely; the L1 found the servers by `ps`. | C1: `setpriv --pdeathsig KILL`. **Shown able to fail:** the frozen counter reads 0 on BASE (K1-0, `controls-prefreeze.txt`) and on the `setsid`-only fixture (K1-F1), 3 on the reference (K1-P). |
| M50-3 | `evidence durability` (seat findings held only in the dispatching process) | Attempt 1's wave: 12 seats dispatched at 19:21 -03; the orchestrator kernel restarted mid-wave and `build-results.json` records `output: null` for all 12; only R50ScoutSources wrote its report file and R50ScribeLesson its receipts before the restart (`ls .ufo/waves/round-50/build/`). Ten seats' findings, including every attack seat (2 reviewers, 2 critics, 1 mutation-tester, 1 sentinel), are lost. | none — the wave context asks for the report file "then yield", so a seat that is cut off before its last step leaves nothing. | Routed (not shown able to fail, so not counted): the attempt-2 residual call asks each seat to write its report file first and append to it as it goes. |

Misroot sweep (§3): `git -C /home/vgpnk/Projects/shokunin status --porcelain` lists only `.scratch/run15-wrapup/misroot-cff0b4cb/` (orchestrator-owned, another lane's incident) — no file of this lane's seats at the fleet root.

## Errata (append-only)

- **E50-1 (round-49 report FAIL count; closure D1).** The round-49 report's "13 FAIL" / "15 → 13" reads **12** / **15 → 12** (`grep -c '^FAIL' .ufo/waves/round-49/final/verify-candidate.txt` → 12; the three ids that left are R12-03, R14-01, R36-01). The fleet report is not edited (filed and closed); this erratum is the lane's correction.

## Closure defects of round 49 (spot-check `corpus/lessons/round-49-verifier-spotcheck.md:96-100`)

- D1 → M50-1, E50-1, QM62.
- D2 → folded into this round's C2 counter as guards G2 (id/command/exit/timeout columns frozen) and G5 (journal).
- D3 → routed again: the round-49 counter's PATH/identity-reading ceiling needs non-identifying shim directories and a PATH-reader control in the next C-side trial counter; round 50's C1 counter does not use shims.
- D4 → C1.
- D5 → `PROVINCE.md` core round-49 bullet now states that the binary is pinned against `checksums.txt` and the asset digests and that `.gpgsig`/`.sigstore.json` were not verified (the knowledge entry already said so at `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:190-192`; the frozen counters `plans/round-49-c1.sh:28` and `plans/round-50-c1.sh:31` carry the pin as a value, not as provenance, and stay byte-frozen).

## Routed (named, not claimed this round)

1. R11-08 (`claim-ledger.sh citations`): layout-bound in a lone clone; three lane-owned unresolved citations remain (attempt-1 seat R50ExecCitations left no output).
2. R25-02 FAIL and R29-01/R29-02/R38-03 POLICY stay operator-routed and byte-identical (C2 guard G3).
3. The ten C2 rows are revision-bound populations: every later round that adds a lesson, heading, stamp or source row re-opens some of them (plan §C2 named ceiling).

## Frontier

Census at round start (attempt 1, `controls/census-start.txt`): `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rc 0, rows 105. Census at round end: `.ufo/waves/round-50/final/census-end.txt`. Frontier move: the OpenBao trial is now safe to run under the lane's own attack seats (a killed run no longer leaks a server), which round-49's waves were not.

## Assimilation

None: no staged `merge/kagi/` theme covers process lifetime or the parent-death signal (`find /home/vgpnk/Projects/shokuknow/merge/kagi -type f | grep -iE 'pdeath|prctl|process|orphan|bao|vault|lease|token'` prints nothing, 2026-11-06).

## considerthese

Newest file `considerthese/2026-10-26.md`; none taken (its four proposals were weighed in round 49 and none fits a process-lifetime or ledger-calibration claim).
