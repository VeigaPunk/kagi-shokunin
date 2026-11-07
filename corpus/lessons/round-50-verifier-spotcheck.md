author: hyaku closure (non-author integrator, @m_zfl)

# Round 50 — verifier spot-check (non-author closure)

Lane-round: kagi r50. BASE `565c43a874b59cd216f4a55c8742db48fa854f16` → lane HEAD `23de560402260a6062b9ee834b46bc9fd4344152`.
Report: fleet `.ufo/reports/round-50/kagi.md`. Dispatched prompt: fleet `.ufo/prompts/kagi-round-50.md`.
Driver digest (copied from the mutable `.ufo/watchdog.log`):
`2026-11-06T18:59:15-03:00 launch kagi round=50 pgid=3787793 driver=hyaku-inline attempt=1`;
`2026-11-06T20:22:55-03:00 lane-dead-no-report kagi round=50; retry same round (hyaku-inline attempt=1: L1 ended without a landed report: FAIL report_of (missing, unchanged, no SHONEN heading, or < 400B): .ufo/reports/round-50/kagi.md)`;
`2026-11-06T20:22:56-03:00 launch kagi round=50 pgid=1593614 driver=hyaku-inline attempt=2`;
`2026-11-06T21:05:18-03:00 complete kagi round=50; hyaku-inline attempt=2`.
Closure measurements: 2026-11-07, about 00:05–00:15Z (host load average 28–61).
Scratch for all re-measurements: `/fast/scratch/hyaku/close-kagi-r50/` (`git archive` of BASE and TIP into `base/` and `tip/`).

## 1. Step-1 conformance

| check | command | observed | result |
|---|---|---|---|
| report committed by lane identity | `git log --format='%an %ae %H %ci' -- .ufo/reports/round-50/kagi.md` (fleet) | `kagi-shokunin kagi@shokunin.local ef722b16803fc8f1536b262538b0031de2ab956b 2026-11-06 21:04:32 -0300`; the commit is on `origin/main` | pass. Filed after the final lane commit (21:03:11) and before the driver complete line (21:05:18). |
| cited commits exist + ancestors of `master` | `git cat-file -e <h>^{commit}`; `git merge-base --is-ancestor <h> master` for 565c43a8, 7d3b2c01, 9e4dcbcc, 6963a350, e4abab1d, d4994e3d, 23de5604 | all exist, all ancestors | pass |
| lane commits by lane identity | `git log --format='%h %an %ci %s' 565c43a..23de560` | 6 commits (7d3b2c0 19:20:41, 9e4dcbc 20:24:47, 6963a35 20:28:41, e4abab1 20:30:13, d4994e3 20:49:42, 23de560 21:03:11), all `kagi-shokunin` | pass |
| lane pushed, clean | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin`; `git status --porcelain`; `git ls-remote origin refs/heads/master` | `state branch=master local=23de5604… remote=23de5604… ahead=0 behind=0 head=detached tracked=0 untracked=0`; porcelain empty; ls-remote `23de5604…` | pass |
| `SHONEN` heading, one line per box | `grep -cE '^\s*- \[' SHONEN.md` → 4; report `## SHONEN` has 4 `[~]` lines | 4 = 4 | pass |
| prompt carries template contract | `diff <(sed -n 1,140p templates/round-prompt.md) <(sed -n 1,140p .ufo/prompts/kagi-round-50.md)` | 10 hunks, every removed template line holds only `{{LANE}}`/`{{ROUND}}`/`{{FLEET_ROOT}}`/`{{AXES}}`; §1, §2, §2b, §3, §4, §5 at lines 3/9/42/80/99/131; hyaku addendum §6 at line 141 | pass |
| append-only files | `git diff BASE TIP -- LOG.md corpus/QUALITY.md corpus/SOURCES.md corpus/lessons/ \| grep -cE '^-[^-]'` | `0`. Whole-tree removals (`git diff --numstat BASE TIP \| awk '$2>0'`): `PROVINCE.md` 1 (round-49 bullet rewritten to state the gpg/sigstore ceiling, closure D5), `corpus/claim-ledger.tsv` 10 (the ten journaled C2 expects), `corpus/openbao-token-trial.sh` 1 (the launch line), `corpus/stamps.tsv` 16 (restamp) | pass |
| freeze ordering | `git log` times; `ls --full-time .ufo/waves/round-50/`; `git diff --name-status 7d3b2c0 23de560 -- plans/round-50*.{sh,md} .ufo/waves/round-50/controls` | predeclaration 19:20:41 → `build-dispatch.json` 19:20:48 → `build.ready.dispatched` 19:21:34 → C1 candidate 20:24:47; diff since predeclaration empty; no amendment | pass |
| wave settled | `jq '.results\|length' build-results.json` → 12; `ls .ufo/waves/round-50/residual/` | build wave 12 results, 10 seats with no output (M50-3, as the report states); residual call 4 reports + receipts | pass, with defect D3 below |

Status: **ok**. A real report with checkable commits, not a marker. The round ran in two attempts (attempt 1 died at 20:22:55 without a report); attempt 2 inherited and landed the work, which the report records.

## 2. Claims — re-check

Gate standard binds: `corpus/claim-ledger.sh`, `corpus/sources-census.sh`, `plans/round-36-c3.sh` (release clock) and the frozen round-50 counters are lane-owned, so I did not execute them. Each claim is split into legs I **re-measured** (plain commands over committed bytes, my own SIGKILL probe of the committed trial bytes, live public GETs) and legs I only **evidence-verified** from committed receipts. I ran the committed trial script itself (domain artifact, not a gate) and the frozen counter `plans/round-36-c1.sh` (unregistered, read-only over its own archive copy) once each.

### C1 operability — SIGKILL leaves no OpenBao dev server behind, 0 → 3 (target 3)

Re-measured:
- The change: `git diff BASE TIP -- corpus/openbao-token-trial.sh` → header comment (3 lines), `command -v setpriv … SETUP no setpriv`, and the launch line `bao server -dev …` → `setpriv --pdeathsig KILL bao server -dev …`. Nothing else in the trial moved.
- My own probe (`/fast/scratch/hyaku/close-kagi-r50/kdemo.sh`, not the lane counter): run the measured tree's trial under `env -i PATH=~/.local/bin:/usr/bin:/bin` with a per-run nonce in its environment; capture every `bao server` process carrying that nonce (pid + starttime); SIGKILL the trial shell at K1 (first server seen) or K2 (stdout holds `TRIAL T1 `); after 5 s count captured processes still alive (same starttime, state not Z/X). Output:
  - BASE K1 `captured=1 alive_after_5s=1`; BASE K2 `captured=1 alive_after_5s=1` (orphans; I killed them afterwards).
  - TIP K1 `captured=1 alive_after_5s=0`; TIP K2 `captured=1 alive_after_5s=0`.
- Positive leg: a full TIP trial run `env -i PATH=… bash tip/corpus/openbao-token-trial.sh --work …` → `TRIAL T1..T5 HOLDS`, `OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc 0, 19 s; no `bao server -dev` from my runs left (`pgrep -fa 'bao server -dev' | grep -c close-kagi` → 0). The change does not stop the trial from testing.
- `command -v setpriv` → `/usr/bin/setpriv` on this host.

Evidence-verified: `final/c1-base.txt` `value=0 positive=1 reaped=3`; `final/c1-candidate.txt` and `final/c1-final.txt` (at `d4994e3d`) `C1_ORPHAN_SAFE: value=3 positive=1 reaped=0 K1/K2/K3 survivors=0`, rc 0; residual R50bReviewerC1 instruments diffstat empty and independent demo (`residual/R50bReviewerC1-receipts/demo-base.txt`, `demo-cand.txt`). K3 was not re-measured by me.

Verdict: **verifies** (K1, K2 re-measured; K3 evidence-verified). Axis grade **operability: improved** (score stays 9).

### C2 calibration — ten drifted ledger rows, 10 → 0 (target 0)

Re-measured (plain counts over `git archive` of each revision; `LC_ALL=C` as `corpus/row-identity.sh:39` sets):

| row | new expect at TIP | my reading at TIP | my reading at BASE (old expect) |
|---|---|---|---|
| R13-01 | `^68$` | `grep -c '^## Round ' SCORECARD.md` → 68 | 67 (`^56$`, drift) |
| R24-06 | `count=68 sha256=7a6a2195…` | `grep '^## Round ' SCORECARD.md \| sha256sum` → `7a6a21953d7d641c…`, n=68 | 67, `922413334dda7555…` |
| R24-05 | `count=124 sha256=c7673d14…` | stamps first field, `LC_ALL=C sort \| sha256sum` → `c7673d14599c6ebd…`, n=124 | same set, n=124 (`count=122`, drift) |
| R21-02/R31-02/R33-02/R34-03 | `rows=107 A=103 B=2 C=2 queued=1 mined=102 rejected=4 …` | `corpus/SOURCES.md` registry rows 107; tier A 103, B 2, C 2; status mined 102, queued 1, rejected 4 | rows 105 (`rows=98`, drift) |
| R38-01 | `^8$` | `corpus/quote-bodies.tsv` data rows 8 (S089–S093, S100–S102); file unchanged since BASE | 8 (`^5$`, drift) |

- Guards G2/G3, re-measured: fields 1, 2, 4, 5 of the ten ids plus the whole rows R25-02, R29-01, R29-02, R38-03 hash the same at BASE and TIP (`awk -F'\t' … \| sha256sum` → `74c163f6…` both). Row-id count 86 at both.
- Journal: `.ufo/waves/round-50/expectation-migrations.json` holds 10 migrations, one per id, each with old/new expect and a commit-range reason.
- Evidence-verified: R22-03/R24-15 (`added=61`, identity digest) and the census's `entries_sourced=15 captures=107` from `final/c2-candidate.txt` and `final/c2-final.txt` (`C2_LEDGER_DRIFT: value=0 ids=10 changed=10`, every id OK); BASE `final/c2-base.txt` `value=10`. Residual R50bCriticC2 re-derived every journal commit.

Verdict: **verifies**. The migrations are measured rebindings, journaled, with commands frozen; they are revision-bound and will drift again whenever a round adds a heading, row or stamp (the lane's own named ceiling). Axis grade **calibration: improved**.

### No owned axis harmed

- `git diff BASE TIP -- SCORECARD.md`: additions only — `## Round 50 — post-move` table, all six axes 9 → 9 (C1 operability, C2 calibration, four no-claim rows).
- Full-ledger harm check, `grep -c '^FAIL'` on the committed receipts: `controls/verify-base.txt` 12 FAIL + 3 POLICY → `final/verify-candidate.txt` 4 FAIL (R11-08 R25-02 R36-01 R36-03) → `final/verify-final.txt` 3 FAIL (R11-08 R25-02 R36-01) + 3 POLICY. No row entered FAIL at TIP that was green at BASE except R36-01, a timeout:
  - R36-01 re-measured by me at TIP: `nice bash plans/round-36-c1.sh` in a `git archive` of `23de560` → `0` (= expect `^0$`), rc 0, **330 s** (ledger timeout 300 s). Not a content regression. The lane's timing receipt covers BASE and `e4abab1d` only.
  - The R36-03 harm (S106/S107 `on-release` with no bound clock) was introduced in `6963a35` and repaired in `d4994e3`. Re-measured: S106 and S107 `recheck` = `180d` at TIP; `on-release` rows 29 at BASE and 29 at TIP (= `on_release=29 bound=29` in `final/r36-03-repair.txt`).
  - R11-08 FAIL at BASE too; its TIP value is unmeasured (timeout).
- `PROVINCE.md`: one bullet rewritten to add the signature-verification ceiling (closure D5); scope unchanged.
- Census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → rc 0, `kagi ok …/corpus/SOURCES.md`, 19 pre-existing W04 duplicate-URL warnings, none on S106/S107.

| axis | verdict | basis |
|---|---|---|
| operability | improved | C1: SIGKILL probe re-measured, BASE orphans at K1/K2 → TIP none; full trial still 5 HOLDS |
| calibration | improved | C2: ten expects re-derived from committed bytes; frozen columns and boundary rows byte-identical |
| depth | unchanged | no claim |
| coverage | unchanged | no claim; registry 105 → 107 |
| freshness | unchanged | no claim; S106/S107 opened live, re-fetched byte-identical by me |
| adjacency | unchanged | no claim; no sibling-overlap scan this round (connector seat left no output) |

## 3. Discernment spot-check (LEARNING.md)

| item | lane decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S106 PR_SET_PDEATHSIG(2const) | admit (tier A, mined, 180d) | `curl -fsSL --compressed https://man7.org/linux/man-pages/man2/PR_SET_PDEATHSIG.2const.html` → 10684 B, sha256 `5e72367e…49144fc82` (= lesson and `source-fetches.tsv`); tag-stripped text holds "The parent-death signal is sent upon subsequent termination of the parent thread" | agree | The bytes match the capture and the quote locates. It states the exact kernel mechanism C1 rests on, from the primary source. |
| S107 setpriv(1) | admit (tier A, mined, 180d) | `curl … https://man7.org/linux/man-pages/man1/setpriv.1.html` → 20601 B, sha256 `3bc0de99…7437770fd` (= lesson); "Keep, clear or set the parent death signal." locates | agree | The tool the trial calls; the page is a util-linux dev snapshot, and the lesson says so and checks the host binary's `--help`. |
| prctl(2) as a row | reject (only cross-references PR_SET_PDEATHSIG) | `curl … https://man7.org/linux/man-pages/man2/prctl.2.html` → 26266 B, sha256 `ef698f6c…` (= lesson); `PDEATHSIG` appears only in the list of `PR_*(2const)` operation pages and SEE ALSO | agree | It carries none of the semantics C1 needs, so it would add a row with no teaching beyond S106. The flip condition is stated. |

SOURCES.md row re-opened: S106 (and S107). Quotes counted with `printf '%s' "<quote>" | wc -w`: 12 and 8 words (≤ 25), matching the lesson. Census rc 0, `kagi ok`.

## 4. Trend verdicts

- **expansion: improved.** Two new tier-A rows on new ground (the Linux process-lifetime mechanism under the trial), each re-opened by me live and byte-identical; a new measured operational property of the lane's trial; QUALITY QM62/QM63, each citing a round-50 lesson mistake.
- **quality: improved.** Ten stale ledger expectations now agree with the repo (re-derived by me); ledger FAIL rows 12 → 3, and the one new red at TIP (R36-01) reads its expected `0` when run without the timeout. The harm the round introduced (R36-03) was repaired before landing; no admitted entry failed my re-check.
- **discernment: improved.** My spot-check agrees with the gate on two admits and one reject. The lane's own discernment miss (M50-4, cadence on new rows) became a lesson with a grounded criterion (QM63), and closure D1 became M50-1/E50-1/QM62 — the LEARNING.md "disagreement becomes a lesson" path. The report self-grades `unchanged`; I grade higher for those reasons.

## 5. Defects routed to the lane (next round; status-neutral)

- D1: `final/r36-01-timing.txt` times R36-01 at BASE and `e4abab1d` but not at the tip `d4994e3d`, where verify-final shows it as a timeout. This closure measured it at `23de560`: `0`, 330 s. Put the ledger timeout budget under fleet load (R36-01, R11-08) on the queue, as the report routes.
- D2: R38-01 now expects `8` located quotes while the operator-routed row R38-03 still expects `located=5 rows=5` (F3). The ledger contradicts itself until the operator boundary moves; keep it named in the lane-status line.
- D3: attempt 1's build wave lost 10 of 12 seats' outputs (M50-3), including every attack seat, and none was replaced; the 4-seat residual call covered C1, C2, the counters and the lesson, but no sentinel or connector scan was re-run. The SCORECARD adjacency row records the missing sibling scan. Re-run the connector next round.
- D4: `final/c2-final.txt` ends `CLAIM_LEDGER: FAIL (claims=10 failed=0 …)` with `verify_rc=1`. The counter's predicate (ids named on FAIL lines) reads 0 correctly, but the report does not say which non-row finding makes the subset verify exit 1. Name it.
- D5 (carried from the report): F5 lane-status line names three routed reds where there are four; the four counter mutation survivors (M3, M4, M6b, M8); G6 anchoring (F1); unprotected note column (F2); round-49 D3 shims/PATH-reader control.

SHONEN, for the operator: all four boxes are `[~]`. A non-author can check box 2: this closure re-executed the OpenBao trial from committed bytes (5 HOLDS) and its SIGKILL safety (no survivor at K1/K2). Boxes 1 and 3 cite runnable evidence. Box 4 rests on a scan that did not run this round. Promotion is operator-owned; this closure writes no `[x]`.
