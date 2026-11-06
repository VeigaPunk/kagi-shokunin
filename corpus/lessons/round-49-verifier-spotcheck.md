author: hyaku closure (non-author integrator, @m_zfl)

# Round 49 — verifier spot-check (non-author closure)

Lane-round: kagi r49. BASE `89afe91878f10805921d3caa67d28d21b33226da` → lane HEAD `6c624dc54708afadf77bd13b58263f6c2195b71c`.
Report: fleet `.ufo/reports/round-49/kagi.md`. Dispatched prompt: fleet `.ufo/prompts/kagi-round-49.md`.
Driver digest (copied from the mutable `.ufo/watchdog.log`, lines 3049 and 3062):
`2026-11-06T17:52:05-03:00 launch kagi round=49 pgid=628824 driver=hyaku-inline attempt=1`;
`2026-11-06T18:54:26-03:00 complete kagi round=49; hyaku-inline attempt=1`.
Closure measurements: 2026-11-06, about 21:45–21:57Z.

## 1. Step-1 conformance

| check | command | observed | result |
|---|---|---|---|
| report committed by lane identity | `git log --format='%an %ae %H %ci' -- .ufo/reports/round-49/kagi.md` (fleet) | `kagi-shokunin kagi@shokunin.local d3a737c6698019aa837f92a082def1a12163becf 2026-11-06 18:53:40 -0300` | pass. Filed after the final lane commit (18:52:19) and before the driver complete line (18:54:26). |
| cited commits exist + ancestors of `master` | `git cat-file -e <h>^{commit}`; `git merge-base --is-ancestor <h> master` for 89afe918, 082bfb3f, a74ae538, 318458a7, 6c624dc5 | all exist, all ancestors | pass |
| lane commits by lane identity | `git log --format='%h %an %ci %s' 89afe918..6c624dc5` | 4 commits (082bfb3 18:07:28, a74ae53 18:30:18, 318458a 18:48:34, 6c624dc 18:52:19), all `kagi-shokunin` | pass |
| lane pushed, clean | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin`; `git status --porcelain`; `git ls-remote origin refs/heads/master` | `state branch=master local=6c624dc5… remote=6c624dc5… ahead=0 behind=0 head=detached tracked=0 untracked=0`; porcelain empty; ls-remote `6c624dc5…` | pass |
| `SHONEN` heading, one line per box | `grep -cE '^\s*- \[' SHONEN.md` → 4; report `## SHONEN` has 4 `[~]` lines | 4 = 4 | pass |
| prompt carries template contract | python `difflib` of `.ufo/prompts/kagi-round-49.md` lines 1–140 against canonical `templates/round-prompt.md` (140 lines) | 22 changed lines (11 template lines), every removed template line holds only `{{LANE}}`/`{{ROUND}}`/`{{FLEET_ROOT}}`/`{{AXES}}`; §1, §2, §2b, §3, §4, §5 at lines 3/9/42/80/99/131; hyaku addendum §6 at line 141 | pass |
| append-only files | `git diff BASE TIP -- LOG.md corpus/QUALITY.md corpus/SOURCES.md 'corpus/lessons/round-4[0-8]*.md' \| grep -cE '^-[^-]'` | `0`. Whole-tree removals (`git diff --numstat BASE TIP \| awk '$2>0'`): `PROVINCE.md` 1, `SKILL.md` 1, `corpus/README.md` 2, `corpus/claim-ledger.tsv` 2, `corpus/stamps.tsv` 10 — the C2 stated-count lines, the two journaled expect migrations and the restamp | pass |
| freeze ordering | `git log` times; `ls --full-time .ufo/waves/round-49/build-dispatch.json`; controls receipt header | controls 21:04:10Z (18:04:10-03) → predeclaration 18:07:28 → dispatch 18:07:41 → candidate 18:30:18. `git diff --name-status 082bfb3f 6c624dc5 -- plans/round-49-c1.sh plans/round-49-c2.sh plans/round-49-controls.sh .ufo/waves/round-49/controls/fixtures` is empty; no amendment | pass |
| wave settled | `jq '.results\|length' build-results.json`; literal `SEAT-STATUS: complete` per output | `13`; literal in 5/13 outputs, as the report states (M49-2 form) | pass |

Status: **ok**. This is a real report with checkable commits, not a marker.

## 2. Claims — re-check

Gate standard binds here: the frozen counters `plans/round-49-c1.sh`/`-c2.sh`, `corpus/claim-ledger.sh`, `corpus/self-counts.py` and `corpus/self-description-sweep.sh` are lane-owned, so I did not execute them. Each claim is split into legs I **re-measured** (plain commands over committed bytes, one re-execution of the committed trial bytes from scratch, live public GETs) and legs I only **evidence-verified** from committed receipts.

Shared leg (re-measured): instruments frozen (row above). `git diff --stat 318458a7 6c624dc5` → only `final/measured-at-landing.txt` and `final/sweep-landing.txt`, so the landing receipts describe the TIP's content bytes.

### C1 operability (capability acquisition) — OpenBao token/lease trial 0 → 5 (target 5)

Re-measured:
- Presence BASE vs TIP (`git cat-file -e <rev>:corpus/openbao-token-trial.sh`; `git show <rev>:corpus/knowledge/vault-openbao-token-lease-lifecycle.md | grep -c '^## Measured (round 49'`; SCORECARD capability row): BASE `trial=no measured=0 caprow=0` → TIP `trial=yes measured=1`, row `| OpenBao token/lease lifecycle trial |` added.
- Re-execution of the committed trial bytes (blob `f5778b51…`), not the counter: `git show 6c624dc5:corpus/openbao-token-trial.sh > $d/t.sh; timeout 300 bash $d/t.sh --work $d/w` (`$d` a fresh dir under fleet `.scratch/`, removed after) with `~/.local/bin/bao` (sha256 `9c5f3628…41b788` = the install receipt; `bao version` → `OpenBao v2.7.2 (9e0a0d3c…)`) → `TRIAL T1..T5 HOLDS` (T2 `granted=5`, T4 `login-orphan=true`, T5 `lease-before=1 lease-after-5s=0`), `OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc 0, 18 s. `pgrep -fc 'bao server -dev'` afterwards → `0` (no orphan from my run).
- Identity-read ceiling (K49CriticClaims "falsified as measured"; K49CriticCeiling forgery): `git show 6c624dc5:corpus/openbao-token-trial.sh | grep -nE 'PATH|SH[1-5]|shim|readlink|command -v|type -P|which|sha256'` → only line 12 (comment) and lines 29–30 (`command -v bao`/`python3` setup checks). This trial does not read the shim directories or binary identity; it drives the real CLI, which my direct run confirms. The counter's PATH-reading hole is real but not exploited by this candidate.
- Kill rules: entry removed lines `git diff BASE TIP -- corpus/knowledge/vault-openbao-token-lease-lifecycle.md corpus/knowledge/iso-11770-3-edition-status.md | grep -cE '^-[^-]'` → `0`. Token shape `git grep -cE '(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}' TIP -- corpus plans .ufo/waves/round-49` → 2 files, `build/K49ExecSources/S016.body` and `build/K49ScoutSources/openbao-tokens-20261106.body`; the matches are `<span class="token plain">s.raPGTZd…</span>`-style example tokens inside the public OpenBao docs page HTML, as the report states.

Evidence-verified (committed receipts): `controls/c1-base.txt` → `value=0 absent=1 pins=1`; `final/measured-at-candidate.txt`, `final/measured-at-landing.txt`, `final/c1-repeat-candidate.txt` → `value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2`, T1..T5 `real=HOLDS,shim=BROKEN,entry=1,ok=1`; `controls/controls-prefreeze.txt` → `CONTROLS: ALL-MATCH (match=19 mismatch=0)` incl. constant-HOLDS 0, real-bao-forced 0, prints-token 0; `final/candidate-legs.txt` → `LEG_C1: PASS … identity_reads=0 holds=5 calls=33`.

Verdict: **verifies**. Reported 0 → 5 matches; the capability runs on this host from committed bytes. Axis grade **operability: improved** (capability acquisition; score stays 9).

### C2 calibration — self-count mismatches 6 → 0 (target 0)

Re-measured: I derived both sides from committed bytes with the frozen key regexes of `corpus/self-counts.tsv` (python `re` over `git show <rev>:<file>`) and plain counts:

| key | stated BASE | stated TIP | live TIP (my count) |
|---|---|---|---|
| SC-SKILL-STAMPS / PV-STAMPS / RD-STAMPS | 122 / 122 / 122 | 124 / 124 / 124 | `git show <rev>:corpus/stamps.tsv \| grep -c '[^[:space:]]'` (the R12-03 command) → BASE 123, TIP 124 |
| RD-DOCS-ENTRIES | 35 | 36 | `git ls-tree --name-only TIP corpus/knowledge/ \| grep -c '\.md$'` → 36 (BASE 36) |
| RD-DOCS-ROWLINKED | 32 | 33 | `git grep -l '^Reverify:'` → 36 declared at TIP (35 at BASE: the ISO entry was undeclared), 3 `by-hand` → 33 row-linked |
| RD-DOCS-BYHAND | 3 | 3 | 3 |

At BASE the three stamp statements were stale (122 vs 123) and the docs triple had no CLEAN gate reading (the undeclared ISO entry; `final/gates-base.txt` `DOC_AUDIT: BROKEN (… undeclared=1 unpinned=1 …)`). At TIP all six stated values equal my live counts.
- Seat-leg contradiction, ruled: `leg-c2-live-sources.sh` FAILs on whole-row comparison. I compared the command column (field 2) of R12-03 and R14-01 BASE vs TIP with `awk -F'\t'` + `diff` → **identical** for both (`grep -c '[^[:space:]]' corpus/stamps.tsv`; `bash corpus/claim-ledger.sh docs`); only the expect column moved (`^122$`→`^124$`; `entries=35 row_linked=32`→`entries=36 row_linked=33 … duplicate_reasons=0\)$`), each recorded in `.ufo/waves/round-49/expectation-migrations.json` with old/new and reason. The header rule ("command column byte-identical") binds; a journaled measured rebinding of an expectation is the lane's standing migration form, and the CriticCeiling forgery (repointed commands) is a command-column change the L1 leg refuses (`final/leg-c2-source-commands.txt` negative: `command-redefined ×2`). Not forged.
- Ledger effect, evidence-verified: `final/verify-base.txt` 15 `FAIL` lines → `final/verify-candidate.txt` **12** `FAIL` lines (R12-03, R14-01, R36-01 left; no row entered). The report says 13 (defect D1). The candidate verify carries no STALE stamp line; its MISSING lines are `MISSING-ID` idref findings in older lessons, pre-existing.

Evidence-verified: `controls/c2-base.txt` → `value=6` (3 STALE, 3 SETUP); `final/measured-at-landing.txt` → `value=0 keys=6 lines=63`, six OK. K49CriticClaims' "weakened" (3 keys are revision-bound counts) is accepted as a scope note, not a falsifier: the frozen target was met with the instruments unchanged.

Verdict: **verifies**. Axis grade **calibration: improved**.

### No owned axis harmed

`git diff 89afe918 6c624dc5 -- SCORECARD.md`: additions only (capability row, round-49 note, `## Round 49 — post-move` table with all six axes 9 → 9; C1 operability, C2 calibration, four no-claim rows). Self-description sweep, evidence-verified: `final/sweep-base.txt` and `final/sweep-landing.txt` both `SELF_DESCRIPTION: MISMATCH n=4 (… SD6=3 … SD8=1 …)`. `PROVINCE.md` +1 core bullet scoped to dev mode, one host, one release. Lane gates at BASE (`final/gates-base.txt`): census, claims-declared, quote-locate, anchor-pins, release-clock CLEAN, `DOC_AUDIT` BROKEN; C2 is its repair. I re-ran `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → rc 0, `kagi ok`, with 19 pre-existing W04 duplicate-URL warnings and none on S105/S016/S093. Registry `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` → BASE 104, TIP 105.

| axis | verdict | basis |
|---|---|---|
| operability | improved | C1 capability acquisition, re-executed from committed bytes |
| calibration | improved | C2 6 → 0, stated and live counts re-derived from committed bytes |
| depth | unchanged | no claim; entry gained a measured section (score 9 → 9) |
| coverage | unchanged | no claim; registry 104 → 105 |
| freshness | unchanged | no claim; S016 re-opened by the lane (and by me) |
| adjacency | unchanged | no claim; connector found no sibling OpenBao/Vault token ground |

## 3. Discernment spot-check (LEARNING.md)

| item | lane decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S105 OpenBao PKI API docs | admit (tier A, used by the lesson; T5's `generate_lease`) | `curl -sSL https://openbao.org/docs/api/secret/pki/` → 200, 620683 B, sha256 `9fa76939…` (= the lesson's digest); tag-stripped text holds "Specifies if certificates issued/signed against this role will have OpenBao leases attached to them" count 1 | agree | Live bytes equal the capture; the quote locates once and supports exactly the T5 lease mechanism it is cited for. |
| OpenBao v2.7.2 release page as a new row | reject (duplicates S093) | `corpus/SOURCES.md:100` S093 = `https://github.com/openbao/openbao/releases/tag/v2.7.2`; `curl -sSI` that URL → `HTTP/2 200` | agree | Same URL and release already registered; a second row adds no identity. The flip condition (S093 capture lost) is sound. |
| S016 fetch-row refresh | reject (coupled to `inrow-pins.tsv` and quote manifest) | `curl -sSL https://openbao.org/docs/concepts/tokens/` → 200, 47384 B (= the lesson's byte count); the four teaching quotes each locate count 1 | agree | The source is unchanged, so a refresh would only move a fetch date while risking drift in two coupled pins; deferring until all three move together is correct. |

SOURCES.md row re-opened: S105 (row line 112). Its quote is 14 words by `printf '%s' "<quote>" | wc -w` (≤ 25), matching the lesson's stated 14 under its E49-1 counting rule. Census `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → rc 0, `kagi ok`.

## 4. Trend verdicts

- **expansion: improved.** A new capability (OpenBao token/lease lifecycle trial) entered `SCORECARD.md` §Capabilities and was re-executed by me (5 HOLDS); documented-only OpenBao token ground moved to `PROVINCE.md` core; one new tier-A row S105, re-opened live.
- **quality: improved.** The entry gained a measured section append-only (0 removed lines) with review narrowings; the round-45 ISO entry is now declared and pinned, so `DOC_AUDIT` BROKEN → CLEAN; ledger FAIL lines 15 → 12 with journaled migrations; no admitted entry failed my re-check.
- **discernment: improved.** Stated self-counts agree with the repo (6 → 0, re-derived by me). The spot-check agrees on 1 admit and 2 rejects, each with a flip condition. Both closure-routed r48 defects were mined as grounded mistakes with errata (M49-2 completion form, stated exactly and matching my `jq`; M49-3/E49-1 counting rule, which S105's count obeys).

## 5. Defects routed to the lane (next round; status-neutral)

- D1: the report (§Harm checks, §Trend verdicts) says the candidate ledger has 13 FAIL rows ("15 → 13"). `final/verify-candidate.txt` has 12 `FAIL` lines (R11-08 R13-01 R21-02 R22-03 R24-05 R24-06 R24-15 R25-02 R31-02 R33-02 R34-03 R38-01), which the report's own routed list also enumerates (11 + R25-02). Append an erratum; count FAIL lines with a stated command.
- D2: C2 seat leg `build/K49CriticCeiling/leg-c2-live-sources.sh` code (whole-row compare) contradicts its header (command column). Closure ruled the header binds. Fold the command-column check and the journal check into the C2 counter itself (the lane's routed "freeze the source-row commands" amendment), so the next counter cannot be forged by an unfrozen `claim-ledger.tsv`.
- D3: the C1 counter's PATH/identity-reading ceiling is answered only by a seat leg for this candidate. The next C-side trial counter should carry non-identifying shim directories plus a PATH-reader control (lane routed).
- D4: 8 orphaned `bao server -dev` processes from seat attack runs (SIGKILL bypasses the EXIT trap). Process-group kill of the dev server is routed by the lane; keep it on the queue until it lands.
- D5: the OpenBao install verified checksums and asset digests but not `.gpgsig`/`.sigstore.json`; state this ceiling wherever the binary pin is cited as provenance.
- Carried forward: the lane's routed list (ledger reds outside C2, R25-02/R29-01/R29-02/R38-03 operator-routed, the five mutation survivors, NOSECRET batch-token shapes S-03, SD10, S098, the Vault-lease MDX normalizer gap, the capture redaction convention).

SHONEN, for the operator: all four boxes are `[~]`. A non-author can check box 2 (an end-to-end task logged): this closure re-executed the OpenBao trial from committed bytes and saw 5 HOLDS on OpenBao 2.7.2. Boxes 1, 3 and 4 cite runnable evidence. Promotion is operator-owned; this closure writes no `[x]`.
