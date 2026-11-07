# R57ScribeLesson — round-57 lesson draft, source gate, mistake mining

Seat R57ScribeLesson (scribe, leaf; axes calibration + operability as drafted). Answering model observed: the runtime context reports `Model: amr/deepseek-v4.1-flash`; no other model identity is observable in this session. All lane reads were read-only; no production file was edited by this seat.

## Behavior

1. Read `~/.omp/agent/RULES.md`, `plans/round-57.md`, the four frozen instruments (`plans/round-57-c1-check.py`, `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`), `plans/round-56.md` evidence via `git show`, `corpus/lessons/round-56.md`, `corpus/lessons/round-56-verifier-spotcheck.md`, and `considerthese/2026-10-26.md`.
2. Opened S115 `https://openbao.org/docs/audit/` and S116 `https://openbao.org/docs/commands/audit/` live on 2026-11-07 with both curl 8.23.0's default UA and a Chrome/124.0 UA; bodies byte-identical per page. Opened and refused `https://developer.hashicorp.com/vault/docs/audit` (sibling product, different exempted list); opened `https://openbao.org/docs/api/system/audit/` and did not admit it as a row (duplicates the salt warning, no HMAC mechanism/non-audited list, trial drives the CLI).
3. Drafted `.ufo/waves/round-57/w1/R57ScribeLesson.d/round-57.md` with `## Claims`, `## Gate`, `## Mistakes`, `## Routed`, `## Considerthese`, `## Sources`, `## Status at draft time`.
4. Did not rerun the C2 trial or compute the C2 landing-tip counter value; read the landed receipts and marked the C2 value as the L1's integration reading.

## Gates and measurements (observed)

| Gate | Command | Result | rc | When |
|---|---|---|---|---|
| C1 counter at BASE | `TMPDIR=… bash plans/round-57-c1.sh` | `C1_CURRENT: value=3 population=16 gate=0 guard=1` | 0 | 11:14 |
| Frozen checker at BASE | `python3 -I -B plans/round-57-c1-check.py --root <archive>` | `CURRENT_CLAIMS: value=3 population=16 mismatches=3 unbound=0` | 0 | 11:14 |
| Draft gate at BASE | same, with `corpus/current-claims.py` (sha256 `e36472b3…`) copied in | identical value/population to the checker | 0 | 11:14 |
| Draft gate on live tree | `python3 -I -B corpus/current-claims.py --root .` | `value=0 population=16` (repairs in flight; not revision-bound) | 0 | 11:14 |
| C2 at BASE | `bash plans/round-57-c2.sh` | `C2_AUDIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)` | 0 | 11:14 |
| Epoch-B battery | `cat .ufo/waves/round-57/controls/controls-prefreeze-epochB.txt` | 20 lines; K1-BASE 3, K1-F1..F7 as expected, K2-BASE 0, K2-STUB 0, K2-MOCK 0; `CONTROLS: match=11 mismatch=0` | — | 11:19 |
| Recheck selftest | `python3 -I -B corpus/recheck-replay.py --selftest` | `RECHECK_REPLAY_SELFTEST: PASS (20 cases)` | 0 | 11:14 |
| Epoch-F receipt | `grep 'CONTROLS:' …controls-prefreeze-epochF.txt` | `CONTROLS: match=23 mismatch=0` | — | 11:14 |
| C2 trial receipts | read-only | real `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` rc0 and `OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0` rc0 twice; SH1..SH5 each rc1 with its designated test BROKEN; no-bao `SETUP` rc2; wrapper flips T1 | — | 11:19–11:22 |
| Epoch B commit | `git log --oneline -1` | `03cbf65` (commit date 11:20:44; ref read `7aa1f47` at 11:28 and `03cbf65` at 11:33) | — | 11:33 |

`bash plans/round-57-c1.sh` exits 0 at `value=3` against target 0; the script's last line is its `printf` and it emits no `exit` (M57-4 in the draft).

## Touched surfaces

Written by this seat only (production untouched):

- `.ufo/waves/round-57/w1/R57ScribeLesson.d/round-57.md` — sha256 `a78dde5d5bc3a65d90ce4205fb68f998c3362135d7f6d8d5ab4de04c80f4d69c`, 22976 B.
- `.ufo/waves/round-57/w1/R57ScribeLesson.d/receipts.txt` — sha256 `03057aa20ed4105a7a5073eb63c8b514ac9c19c9335853e8dbb1571575219537`.
- `.ufo/waves/round-57/w1/R57ScribeLesson.d/fetch-receipts.txt` — sha256 `64b709302b9e27470728b1184364687cfe120490b8561ff106348e87574ca5be`.
- `.ufo/waves/round-57/w1/R57ScribeLesson.d/capture/` — S115 `76339ff7…d79090c6` 41787 B; S116 `3dc88732…0d9905ce` 33338 B; rejected Vault page `62123b2a…acf02e1` 293262 B; API page `1693a4db…d853f0` 43161 B.
- `.ufo/waves/round-57/w1/R57ScribeLesson.md` (this report).

Observed but not authored by this seat: `M LOG.md`, `M SCORECARD.md`, `M corpus/lessons/round-56.md`, `M corpus/SOURCES.md`, `M corpus/README.md`, `M corpus/claim-ledger.tsv`; `?? corpus/current-claims.py`, `?? corpus/openbao-audit-trial.sh` (untracked; 10922 B, sha256 `7e645194…`, mtime 11:25:22), `?? corpus/knowledge/openbao-audit-device-custody.md`, `?? corpus/lessons/round-57.md`, `?? .ufo/waves/round-57/…` (including `final/`).

## Findings

1. **C1 BASE is 3/16 and the draft gate agrees.** `bash plans/round-57-c1.sh` → `value=3 population=16 gate=0 guard=1` rc 0; the frozen checker and the draft `corpus/current-claims.py` on a `git archive 1cda9e7` tree both read the same value/population; the three mismatches are the stale statements at `SCORECARD.md:1850`, `LOG.md:1924`, `corpus/lessons/round-56.md:9`. Target 0 is unobserved in this draft because the repairs are uncommitted.
2. **Epoch B is a disclosed freeze-epoch move with a residual contradiction.** Epoch A `plans/round-57-c2.sh` sha256 `3de6b4de…439a9`; epoch B `140a8f2b…aea28`, plan `b130bb83…c6dc`, controls `09f334cb…e618`, committed at `03cbf65` with `controls-prefreeze-epochB.txt`. The committed plan still says K2-MOCK “reads 5 — the declared ceiling” at lines 97-99 and still lists the shape-keyed-mock ceiling at line 133, while line 106 and A1 say 0 and the receipt reads `K2-MOCK expect=0 got=0 MATCH`. Reported to `agent://KagiR57` at 11:19; the L1 ruled the epoch disclosed (recorded as M57-3, not a silent drift).
3. **C2 receipts satisfy the epoch-B predicate's evidence shape but the counter value is the L1's.** Real run 5/5 twice (`HOLDS holds=5 broken=0`), five shims flip exactly T1..T5 (`BHHHH`, `HBHHH`, `HHBHH`, `HHHBH`, `HHHHB`), no-bao `SETUP` rc2, wrapper flips T1. I did not run the counter to a landing value.
4. **The trial receipts predate the current trial script.** The receipts in `.ufo/waves/round-57/w1/R57ExecTrial.d/` were written 11:19–11:22 and do not name the script hash they ran; the untracked `corpus/openbao-audit-trial.sh` was 10674 B / sha256 `41fd8096…` at 11:18:04 and 10922 B / sha256 `7e645194…` at 11:25:22. The landing C2 counter's re-run of the committed bytes is therefore the binding evidence; the stored receipts are supporting only. Recorded in the draft's C2 claim, Gate and Routed item 6.
5. **The audit entry was admitted on the integrated version, not the early draft.** Integrated `corpus/knowledge/openbao-audit-device-custody.md` 7699 B, sha256 `a5d2d5bb…a1650`, mtime 11:22:19, with `## Measured (round 57 …)` bound to the receipts; the `.d` draft's 11:16 past-tense sentence was ahead of its receipts (M57-5, resolved by integration).
6. **Rejection recorded.** HashiCorp Vault audit docs (19-word located quote, §Exempted API endpoints) refused because its exempted list differs from OpenBao's and it carries no salt/log_raw ground; the OpenBao API page was opened and not admitted as a row (duplicate, not the trial's transport).
7. **C1 counter exit code does not encode its reading.** `bash plans/round-57-c1.sh` rc 0 at `value=3`; an rc-based admission would pass the do-nothing control. Inherited from R56 routed item 3; recorded as M57-4.
8. **A live-tree gate reading was not revision-bound.** `--root .` read `value=0` at 11:14 while the same gate on the BASE archive read `value=3`; recorded as M57-6.
9. **Considerthese: none of the four 2026-10-26 proposals is both unimplemented and still applicable.** Proposal 1's HOLD is gone (`SCORECARD.md:14` lane-status open); proposal 2 was adopted in round 31 (`corpus/lessons/round-31.md:145`) and is cited as C1's precedent; proposal 3's D1 premise is fixed (`corpus/release-clock.py:789`, commit `fc65112`; `Python 3.15.1.` matches `3.15.1`); proposal 4 was rejected in round 32 (`corpus/lessons/round-32.md:14`).
10. **Sources rows are 11 cells each, both carry URL, 2026-11-07, a ≤25-word located quote, status mined, used-by the entry.** The worktree `corpus/SOURCES.md` already carries S115/S116 rows (`on-release`, used-by entry + lesson); the draft notes the L1 must reconcile rather than insert both.
11. **No credential material.** Only public documentation GETs; bodies only; no headers/cookies stored; no token-shaped string captured or printed (entry token scan is empty).

## Out of scope

- Running the C2 trial or the C2 counter to a landing value; computing the C1 landing-tip reading.
- Editing `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, the registry, the entry, or the trial script (L1 integration).
- Git/jj mutation, commit, push, judgment, or another runtime.

## Tools and provenance

`read`/`bash` tools; `curl 8.23.0` (system, `/usr/bin/curl`); `python3 3.14.8`; `GNU bash 5.3.20`. No installs or upgrades; pacman transactions paused; no PATH writes. Scratch `/fast/scratch/hyaku/kagi-r57/R57ScribeLesson/` was used only for fetches, the BASE archive, and instrument runs; deleted before yield. No large `/tmp` trees.

## Artifacts

- Draft lesson: `.ufo/waves/round-57/w1/R57ScribeLesson.d/round-57.md`
- Receipts: `.ufo/waves/round-57/w1/R57ScribeLesson.d/receipts.txt`, `.ufo/waves/round-57/w1/R57ScribeLesson.d/fetch-receipts.txt`
- Captures: `.ufo/waves/round-57/w1/R57ScribeLesson.d/capture/{S115,S116,reject-vault-audit,openbao-api-audit}.body`
- Report: `.ufo/waves/round-57/w1/R57ScribeLesson.md`

Report: .ufo/waves/round-57/w1/R57ScribeLesson.md
