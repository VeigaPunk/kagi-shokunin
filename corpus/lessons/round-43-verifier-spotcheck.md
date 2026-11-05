# Round 43 — verifier spot-check (non-author closure)

author: hyaku closure (non-author integrator, @m_zfl)

Round: kagi 43. Claim BASE `5f3566c4cfe65a74da4d201d74d28b403929807b`; lane tip (branch `master`) `65f66e17a313efd839db2a77e7156a313a1e363d`; candidate `542885ed1514fd01d4e949caa5fab58eb000fffc`. Report: `.ufo/reports/round-43/kagi.md` (fleet commit `b5a185fc`, author `kagi-shokunin <kagi@shokunin.local>`). This file is written by the non-author closure judge; nothing here edits lane-authored round files.

## 1. Conformance (PROTOCOL §Round-robin step 1)

| check | command | observed |
|---|---|---|
| report committed by lane identity | `git log --format='%an %ae %H' -- .ufo/reports/round-43/kagi.md` | `kagi-shokunin kagi@shokunin.local b5a185fc23dde9d2fed75e778268bea53ee9e28a` |
| report committed in fleet repo | `git merge-base --is-ancestor b5a185fc HEAD` (fleet) | rc 0 (ancestor) |
| `## SHONEN` heading, one line per box | `grep -c '^## SHONEN' <report>`; `grep -c '^- \[' SHONEN.md` | 1 heading; 4 boxes, 4 `[~]` lines in the report, one per box; lane `SHONEN.md` unchanged this round (`git diff --quiet 5f3566c 65f66e17 -- SHONEN.md` rc 0) |
| prompt carries the template contract | read `.ufo/prompts/kagi-round-43.md` against `templates/round-prompt.md` | mission/axes binding, ≥8 batched L2 floor, report path `.ufo/reports/round-43/kagi.md`, land-last with hash citation, SHONEN rule, write scope, push scope, L0 side channel — all present (hyaku addendum §6 embedded) |
| cited lane commits exist and are ancestors of the branch ref | `git cat-file -e <h>^{commit}`; `git merge-base --is-ancestor <h> refs/heads/master` for `a9180250`, `dd6ccb92`, `f2b4ec76`, `542885ed`, `65f66e17`, and BASE `5f3566c` | all exist; all rc 0. Ancestry tested against `refs/heads/master`, not `@{u}` (jj-colocated; git HEAD detached — expected) |
| no uncommitted round work, pushed | `git status --porcelain`; `jj-lane.sh state` | status empty; `ahead=0 behind=0 tracked=0 untracked=0`; `git ls-remote origin refs/heads/master` = `65f66e17a313efd839db2a77e7156a313a1e363d` |
| dispatch/completion digest (watchdog, mutable) | copied verbatim into the closure notes | `2026-11-05T14:30:04-03:00 launch kagi round=43 pgid=305617 driver=hyaku-inline attempt=1` / `2026-11-05T15:27:57-03:00 complete kagi round=43; hyaku-inline attempt=1` |

Real report, not a marker: named claims, evidence pointers, LOG-tied landed changes, `SHONEN` heading. No conformance defect found. Note (status-neutral, historical, disclosed by the lane itself): `controls/c2-manifest-rederive-base.txt` records that three *round-42-era* BASE receipts (`round-42/controls/c1-base.txt` committed 4 vs re-derived 5, `c2-base.txt` committed 0 vs re-derived 1, `c2-worktree-at-base.txt` written by no committed runner) do not re-derive — excluded from the eight-file manifest, pre-existing at round-42 close, and disclosed in the receipt, but worth a round-44 look.

## 2. Per-claim re-check

Method: plain byte re-measurement over committed bytes wherever possible; executed gate readings evidence-verified from committed receipts per §Gate standard (Closure consequence — a sibling's gate is not executed at closure).

**C1 calibration — verdict: improved (verified).** Byte re-measurement: `git show 542885ed:plans/round-43-c1.sh` declares F1–F6 (range `0..6`, target 6) with F1–F5 byte-unchanged from the round-42 counter (side-by-side header diff) and F6 new: base row `R11-03` deleted, unjournaled, class `DELETED R11-03`; the round-42 counter contains zero `R11-03` mentions vs 5 in the round-43 counter; F6's fixture guard refuses a journal that already references `R11-03` (setup guard read at lines 116–122). Gate bytes unchanged: `git diff --quiet 5f3566c 65f66e17 -- corpus/expect-journal.sh` rc 0. Executed readings evidence-verified from committed receipts: `final/c1-old-real` 5 (round-42 instrument at BASE), `final/c1-new-real` 6, `final/c1-new-m3-K1` 6, `final/c1-new-m5-K3` 6, `final/c1-new-fakeC` 5 (< target 6 — the F1–F5-keyed answer-key gate rejected), `final/c1-blanket-accept`/`-refuse` 0/0; all at candidate `542885ed` per `final/measured-at.txt`. Broken-shape rejection 0/3 → 3/3 reproduced by receipt values.

**C2 freshness — verdict: improved (verified).** Byte re-measurement: `git cat-file -e 5f3566c:corpus/controls-replay.sh` rc 128 (gate absent at BASE) and present at the candidate; `git show 542885ed:corpus/controls-replay.sh | sha256sum` = `fab42e1d0a6b06b3608bb6a0543fad0da37a3c4e40ad85fd9c208cfb0d9e740f`, matching the seat's committed `gate-sha256.txt` and the report. Mechanism read from the committed bytes: snapshot → delete both controls dirs → re-run both committed runners → `cmp` the 8 manifest files → restore on every path → exit 0 clean / 1 refused / 2 setup; invocation pinned to `--clone <dir>` (anything else exits 2). Executed readings evidence-verified: `final/c2-base` 1, `final/c2-blanket-0` 0, `final/c2-blanket-1` 0; BASE eight-receipt re-derivation `controls/c2-manifest-rederive-base.txt` 8/8 MATCH in both modes (plain re-run and delete-then-re-run) at `5f3566c`; refusing fixtures restore (`measured-at.txt`: stale REFUSED rc 1 with controls dirs equal to pre-run; silent REFUSED rc 1 with controls dirs clean).

**C3 operability — verdict: improved (re-measured by the closure judge, plus evidence-verified executed leg).** Own byte measurement over both revisions, five gates `anchor-pins.sh`, `claims-declared.sh`, `prefreeze-control.sh`, `self-description-sweep.sh`, `surface-census.sh`:

| revision | gates with literal `TMPDIR:-/tmp` | gates with selftest default `-d "${HYAKU_SCRATCH:-/fast/scratch/hyaku…` |
|---|---|---|
| BASE `5f3566c` | **5** (leg 1 fails for all ⇒ counter 0) | 0 |
| tip `65f66e17` | **0** | **5** |

(The only residual `/tmp` mentions at the tip are `prefreeze-control.sh`'s own `"$tmp/tmp"` test-local path and `TMPDIR=$tmp/tmp` invocation env — not a scratch default; the counter's leg (1) greps the literal default.) Diff shape: `git diff --numstat 5f3566c 65f66e17 -- <five gates>` = 1/1, 1/1, 2/2, 2/2, 1/1 = 7 changed lines in 5 files, matching the report and QM46. Executed leg evidence-verified from `final/measured-at.txt`: the three selftests re-ran at the candidate with frozen PASS tokens (`SELFTEST: PASS (16 cases)`, `PREFREEZE_SELFTEST: PASS (25 cases)`, `SELFTEST: PASS (10 cases)`); fixture controls are the predeclaration receipts `controls/c3-pos` 1 and `controls/c3-blanket` 4 (committed at `a918025`, per A2-7 after M43-2).

**Harm check.** `git diff 5f3566c 65f66e17 -- SCORECARD.md` is append-only (one hunk `@@ -1593,3 +1593,37 @@`, 0 deletions); all six axes stay 9 → 9; no owned surface regressed. `corpus/knowledge/` unchanged; `SHONEN.md` unchanged; `expect-journal.sh` unchanged.

## 3. Discernment spot-check (LEARNING.md)

The round's `## Gate` records one decision: the S094 re-open (**admit** as sourced basis). No reject decision exists to sample — rows added: none, no candidate source rejected; the not-taken `considerthese` proposals 1 and 3 carry recorded reasons (work proposals, not source rejections). The reject half of the sample is therefore vacuous this round; noted, not graded down.

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S094 re-open (gate admit; registry row touched: `used-by` extended to round-42/43 lessons) | admit | `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md` — re-fetched by the closure judge: HTTP 200, 11296 bytes, sha256 `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`, `cmp` vs `.ufo/waves/round-39/capture/S094.body` exit 0 | **agree** | quote verified at the cited location: line 116 reads "2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change…"; raw offset 6172 starts at "Only `status`, `recheck` and `used-by`"; row's `teaches` (15 words) is grounded by the 8-token located quote; tier A `own-work` with pinned revision `f47ad6ba` is honest; the in-place `used-by` extension is exactly what the quoted rule permits, and all three `used-by` paths exist |
| S094 registry row (≤25-word quote check) | in-place touch | same fetch; `corpus/SOURCES.md` line 101 | **agree** | `status` `mined`, `recheck` `90d` unchanged; only `used-by` changed old→new, logged in the lesson's Gate; census `validate` exit 0, 98 rows, 19 W04 warnings (allowed duplicates) |

`scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → final line `kagi ok`, rc 0.

## 4. Trend verdicts (closure reading; evidence above)

- **expansion: unchanged.** Registry 98 → 98 rows (census count grep rc 98), no new rows by tier, no `knowledge/` entry (diff empty), only registry change is the one-line S094 `used-by` extension (`git diff --numstat` = 1/1). Report's verdict concurs.
- **quality: improved.** Freshness (C2) and operability (C3) moved to frozen targets with committed evidence the closure re-verified; QUALITY gained QM46–QM49, each citing the lesson that produced it; no admitted entry failed a re-check; no entry found false/stale-unmarked.
- **discernment: improved.** Calibration instrument discrimination 0/3 → 3/3 (C1); gate decisions spot-checked from outside: the single admit verified byte-level (agree), no disagreement left unlearned; mistakes M43-1…M43-7 mined with captured-by and fix columns, two routed (M43-7 negative fixtures; scheduling).

## 5. Routed defects for the lane's next round

1. Negative fixture gates for the C2 counter's N1/N2 legs (M43-7; `K43MutCounters` y1/y2 survive) — already routed by the lane; stands.
2. No schedule/runner runs `corpus/controls-replay.sh` yet — already routed; stands.
3. Historical BASE-receipt drift: `round-42/controls/c1-base.txt` (committed 4, re-derives 5), `round-42/controls/c2-base.txt` (committed 0, re-derives 1), `round-42/controls/c2-worktree-at-base.txt` (written by no committed runner) — disclosed in `c2-manifest-rederive-base.txt`; a round-44 correction entry should name and supersede or re-derive them.
4. The owed appended erratum to the round-40 report (round-41 routed item 3) remains unclaimed — carried, not new.
5. Six-key answer-key ceiling of C1 (already routed); C3 counter defects M40-9/10/17 (already routed).

SHONEN boxes: all four remain `[~]` and are checkable by a non-author from committed evidence (SKILL.md gate registry, LOG round-3 vault task, plan/gate runnability, PROVINCE scope-gate) — flagged for the operator's promotion review, which is operator-owned.
