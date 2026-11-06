You are the kagi L1, round 44. Working dir: /home/vgpnk/Projects/shokunin/kagi-shokunin.

## 1. MISSION / AXES binding (SSOT)

Read MISSION.md + AXES.md at /home/vgpnk/Projects/shokunin first — they are the mission single source of
truth. Your lane axes: freshness + calibration (secrets and vault ops). Where this prompt conflicts with MISSION.md + AXES.md,
the mission files win.

## 2. Claims this round — 1 to 3, each falsifiable

This round is **1–3 declared claims**, not a batch of unrelated work:

1. Open your lane repo's SCORECARD.md (create it per AXES.md if missing).
2. Declare 1–3 claims. Each claim is one axis-move against a distinct axis, with
   its own falsifiable before→after. At least one claim works the **lowest-scoring
   non-retired axis** — unless the stagnation nudge waives it (AXES.md section
   *The stagnation nudge*).
3. Land every claimed improvement. Claims must be **causally separable**: each
   verifiable without the others having landed. Two claims on one axis = one claim.
4. Measure each: run a counting command you can paste into the report, before and
   after.
5. Record per claim in SCORECARD.md: the score delta, evidence pointer, counting
   command, and measured commit; append the motivating evidence to LOG.md.
6. A claim may be a **capability acquisition** (AXES.md section *Capabilities*): the
   new capability runs, its output verifies, and its row enters the SCORECARD
   capabilities table in the same round.
7. Saturated or wrong-fit axes may be retired or split — record the reason in
   SCORECARD.md.
8. At most one claim may be **exploratory** — taste-bound (elegance, technique
   quality, a novel resolution path): name what it improves and why the prior
   state lacked it; no counting command. It verifies only as
   `unprovable-but-better` with a named non-author reviewer on record (reasons
   included); otherwise it lands `unprovable` and the round reports that
   honestly. Its axis score need not change — the SCORECARD row carries the
   verdict and reviewer pointer instead of a number.

**Admission:** every claim verifies — measured, or exploratory with a named
non-author `unprovable-but-better` judgment — and **no axis is harmed**; a
trade anywhere is not an improvement. Report all verdicts and let the operator
rule.

## 2b. Frontier step — every child-lane round

Every child-lane round curates where the lane learns and learns from its own mistakes. This
step runs inside the 1–3 claim cap; it is not a fourth claim. Its contract is `corpus/SOURCES.md`
contract v1 in `/home/vgpnk/Projects/shokunin/CORPUS.md` section *SOURCES.md — where a shokunin learns* —
follow it, never redefine it.

1. **Curate `corpus/SOURCES.md`** (create it in the contract's shape if missing). A row is
   written only after its source is opened this round; the lesson's `## Gate` records the
   URL, access date, and a ≤25-word located quote for every new row. Rejections stay as
   rows with reason and flip. Every `status` / `recheck` / `used-by` change is logged
   old→new in the lesson.
2. **Record the census before → after.** Run this command at round start and at round
   end; paste both outputs and their exit codes. Exit 0 is required at round end for
   conformance. Exit 2 is expected at round start only when `corpus/SOURCES.md` does not
   yet exist. If it is still missing at round end, the driver logs a warning and continues;
   that is a conformance defect, not a pass. Record it in the report and create or repair
   the registry. Driver completion is not admission; the independent non-author
   verification duty remains required. The frozen manual census commands remain in
   `/home/vgpnk/Projects/shokunin/CORPUS.md` section *SOURCES.md — where a shokunin learns*; that
   section is the specification.

   ```sh
   /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
   ```

3. **Mine one mistake** — from this round or an earlier one (rejected, harmed or honest-stop
   rounds, errata, spot-check disagreements) into `corpus/lessons/round-44.md`
   `## Mistakes`: class · evidence pointer · captured-by (the criterion or rule that should
   have caught it, or `none`) · fix. A fix counts only once shown able to fail. Found none?
   Paste the sweep — command and output — that found none.
4. **At least one sourced claim** — one of the round's claims rests on a `SOURCES.md` row
   opened this round: the knowledge entry or evidence it lands cites that `S###`.

Main-repo lanes (`repo = .`) do not run this child-lane frontier step, so they need neither
a mined mistake nor a sourced claim. Their report's Sources & frontier section uses
exactly: `SOURCES: unchanged — main-repo lanes hold no corpus/`.

## 3. L2 floor — one batched swarm

Dispatch **at least 8 L2 subagents in ONE batched AgentSwarm call** this round (Kimi
surface: a single batched swarm dispatch, not serial one-at-a-time spawns). Minimum role
split:

- 1× planner, 1× connector (sibling-overlap scan)
- 3× executor, 1× scribe, 1× scout (per-surface reconnaissance)
- 1× reviewer, 1× critic (falsifies the claims the others assert)

Add sentinel / revenger / labrat / mutation-tester / simplifier / distiller as the axis
demands. Route every role through the **host route table** — the operator's role→model
assignments for this substrate. Never hardcode model aliases in the lane repo; the route
table, not this prompt, decides which model serves which role.

**Godspeed lead:** every L2 lane prompt leads with `/skill:godspeed`, followed by the
verbatim directive bytes provided by the host's Godspeed skill binding — do not
paraphrase. Resumes and nudges never re-carry it.

## 4. Report contract

Write the round report at `/home/vgpnk/Projects/shokunin/.ufo/reports/round-44/kagi.md` on the
fleet repo. Required sections, in order:

- **Work performed** — opens by naming the round's declared claims (1–3) and their
  target axes or capability; then one bullet per work item, each carrying an
  evidence pointer (path:line, command output, or commit hash).
- **Landed changes** — every change tied to a LOG.md entry and to the commit hash that
  carries it.
- **Before → after measurements** — one per claim, each with the counting command and the
  commit it was measured against.
- **Sources & frontier** — `SOURCES.md` rows before→after with the counting command, rows
  added by tier, rows touched old→new, frontier rows advanced; a lane with no `corpus/`
  writes a line beginning `SOURCES: unchanged —` that names why (main-repo lanes:
  `SOURCES: unchanged — main-repo lanes hold no corpus/`). This is a conformance item,
  not a report marker predicate.
- **Trend verdicts** — one verdict each for `expansion`, `quality`, and `discernment`
  (`improved`, `harmed`, `unchanged`, `unprovable-but-better`), with evidence; no scalar.
- **SHONEN** — one line per box of your SHONEN.md checklist: `[x]` only with a named
  non-author verifier, `[~]` with a resolvable evidence pointer, `[ ]` if untouched.

**Marker rule:** a contentless report (placeholder text, missing required sections
other than **Sources & frontier** and **Trend verdicts**, or no evidence pointers)
counts as the round **failed** — the driver relaunches the same round. A report that
names real committed work but skips those sections is `ok` plus a minimum-content
conformance defect, logged as one; neither section is a marker predicate.

The watchdog logs its Sources & frontier marker and applies its source-census gate; it
does not check trend verdicts or the full claim-admission criteria. Driver completion
is not admission; independent non-author verification remains required.

## 5. Commit, push scope, L0 side channel

- Round end: commit (`round-44`) inside your lane repo, then push. Also commit and
  push the report on the fleet repo.
- **Push scope:** only the fleet repo remote and your own kagi lane remote. Domain
  source trees are **read-only** — upstream work is documented in the report, never
  pushed.
- **L0 side channel:** if you need an operator decision, append
  `<lane> | round-<N> | <question>` to `/home/vgpnk/Projects/shokunin/.ufo/l0-questions.md`. Do not block
  the round on an answer; note the open question in the report and route around it.
## 6. Campaign addendum — hyaku (百) phases 3–7, operator directives of 2026-10-22/23/25 (binding this round; in-session)

**Run 15 (2026-11-03, binding; supersedes the run-13 routing, round-size, budget, fresh-start and hold lines below; every other run-13/11/10/9/8/7 rule — the 256 hard ceiling, ≥25 % attack share, few-connector-seats, 10-round blocks, clean commits, WAVE-DONE before report, §9 claim sizing, §10 assimilation, the inline spawn handoff and the fresh-start rule — stays binding).** Operator directive, verbatim: "ok i need you to continue the hyaku run, we will be using 32-40 concurrent workers, you are the orchestrator of each run; i want you to do 10 rounds of training per shokunin, until each reeach 100 completed rounds. our subagents for the swarms rounds (each round, a wave composed of m_flash, m_mim, m_zfl on roles you assign) on the hyaku style but using these models and conc i've assigned; remember, the essence of the shokunin runs is to learn by doing, to activelky get better and more capable, to have curated source of knowledge (corpus and their own trials)" — and: "you will be running until each shokunin reaches round 100".
- **Routing: run-15 map** (never pass `model`): task/main/planner/reviewer/security-reviewer/critic `@m_zfl` (reasoning and judgment); executor/revenger/labrat/mutation-tester/simplifier/connector/sentinel/scribe/sonic/distiller/seance `@m_flash` (code, probes, mutation, cross-linking, drafting; mid-run operator ruling 2026-11-03 "assign all m_mim to m_flash" — m_mim is on no role, backup `config.yml.pre-mim-to-flash-20261103`); scout `@m_antigravity` (google-antigravity/gemini-3.8-flash:high; mid-run operator ruling 2026-11-03). `task.agentModelOverrides` in `~/.omp/agent/config.yml` is the authority (backup `config.yml.pre-run14-20261103`); every other model is off every role. Fallback chains unchanged. Compose each wave from at least two of the three models' roles.
- **Round size: 8–16 seats per round** (fleet-wide concurrency is 32–64 workers shared by ~9 live lanes; mid-run operator ruling 2026-11-03 "increase concurrency to 32-64 instead of 32-40"). Shape: ONE v1 wave of 8–16 seats under `ufo-wave-policy.json` (band 8–16), ≥25 % attack seats (reviewer, critic, mutation-tester, labrat), at most 2 connector seats; residual ≤4 seats in one ordinary task call, counted in the round total. 8 is the protocol L2 floor. Never pad: size to the claims. Seats fill in tranches when the fleet is busy (spawns stop at 60 running jobs) — expected, not a failure.
- **Campaign: every pool lane to round 100**, in 10-round blocks, lowest `next/` first, ~9 lanes live at once. Learning by doing is the point: each round must leave the lane measurably more capable — a trial run end-to-end on real domain work, a curated `corpus/SOURCES.md` delta, and a mistake mined into a lesson. Bookkeeping-only rounds are thin claims.
- **Continuity and holds.** Run 15 continues the zcode run-14 campaign (`.scratch/goal-20261031-hyaku-zcode-run14.md`, Windows host) back on this Linux/omp host: lane state is the MANIFEST closure ledger, every lane repo is fast-forwarded to its remote tip. No holds; kagi's refusal boundary, mado's credential-material rule and mori's settings/session redaction rule stay binding. Host differences matter: this host has flock, jj and omp — a claim that failed on the Windows host for a host reason (e.g. chousa r70–72: no flock, sibling load) is re-measured here, never re-declared from the old receipts. Streak blocks are lifted at run start (chousa: fresh-start rule, §9).
- Run state, lane order, blocks: `.scratch/goal-20261103-hyaku-run15.md` under /home/vgpnk/Projects/shokunin.
- **Latest routing amendment (2026-11-03):** operator: "ok use all roles on m_flash", then "leave only executor and reviewer on m_zfl", then "use m_flash as executor". Net map: ONLY reviewer uses `@m_zfl`; every other role (task/main/planner/executor/scout/critic/security-reviewer/scribe/connector/sentinel/etc.) uses `@m_flash`. Supersedes routing and multi-model composition requirements above. Existing seats retain captured routes. Backups: `config.yml.pre-flash-zfl-executor-reviewer-20261103`, `config.yml.pre-flash-executor-20261103`.
- **Routing failover (2026-11-04, temporary).** zai `glm-5.3-flashx` (`@m_zfl`) exhausted its 5-hour quota (429, `type=1308`, reset 2026-11-04 21:14:48) and the fallback hop answered 403 `subscription permission_error` (Kimi). The five remaining zfl routes — reviewer, critic, executor, mutation-tester, sentinel — moved `@m_zfl` -> `@m_flash` (`devin/swe-2:max`); every role now uses `@m_flash`. Existing seats retain the route they captured at spawn; `m_mim` stays off every role. Temporary failover pending operator decision or restored zai quota. Backup `config.yml.pre-run15-zai-quota-20261104`.
- **Quality-pause lift (2026-11-04).** Operator, verbatim: "Resume all four" — lift only the current three-rejection pause on four lanes: souji (next r58), tabi (next r62), chousa (next r74), tsukuroi (next r77). Only their current pause markers are lifted: every failure/rejection already on the record stays there and is never retroactively admitted, and the 3-rejection pause gate applies unchanged to their new rounds. Fresh start is required — read the lane's last three rejected closures and their spot-checks first, then file claims whose before→after is re-measured on this Linux host and beats a do-nothing control (a claim that would pass unchanged with no work is rejected, never re-declared from the Windows-host receipts). This is not a new campaign or run: round counters continue, and concurrency, block size, the 8–16 wave band and routing are unchanged (all-`@m_flash` failover `180fc2b261a986166738ad1c042f831d8af30fc1`, interrupted-watch recovery `0d82ccc9bfdbd6253397249279eac796fb85c600`). The parent clears the runtime markers; this bullet records the authorization only.
- **Routing restore (2026-11-04, run 15; supersedes only the temporary all-flash failover line above).** Operator, verbatim: "you might use m_zfl again, it has reset the usage" — the balanced five-role split is restored: reviewer/critic/executor/mutation-tester/sentinel `@m_zfl` (`zai/glm-5.3-flashx:high`); every other run-15 role stays `@m_flash` (`devin/swe-2:max`). `task.agentModelOverrides` is the authority; restore backup `config.yml.pre-run15-zai-restored-20261104T105305`. Live seats keep the route they captured at spawn — no restarts, no cancellations. The four authorized fresh starts (souji r58, tabi r62, chousa r74, tsukuroi r77) and the future 3-rejection quality gate are unchanged. The zai quota is operator-reported reset, not probed.

**Run 13 (2026-10-30, binding; supersedes the run-11 routing and 64–128 band lines below; every other run-11/10/9/8/7 rule — the 256 hard ceiling, ≥25 % attack share, few-connector-seats, 10-round blocks, clean commits, WAVE-DONE before report, §9 claim sizing, §10 assimilation, the inline spawn handoff and the fresh-start rule — stays binding).** Operator directive, verbatim: "ok i want you to train our shokunins on the hyaku style, but using 16-32 lanes per round; all using m_zfl, m_mim or m_swe for the roles; assign accordingly | | choose the order to train them, do 10 rounds sequentially on each, until we reach 100 rounds trained."
- **Routing: run-13 map** (never pass `model`): task/main/planner/reviewer/security-reviewer/scout `@m_zfl`; connector/critic/mutation-tester/sentinel/labrat/seance/distiller/simplifier/sonic/scribe `@m_mim`; executor/revenger `@m_swe`. `task.agentModelOverrides` in `~/.omp/agent/config.yml` is the authority (backup `config.yml.pre-run13-20261030`); m_kfc, m_flash, m_luna, m_opus, m_sol are off every role. Fallback chains unchanged (ultimate fallback devin/swe-2:max). L1_MODEL/JUDGE_MODEL labels stay `@m_zfl`.
- **Round size: 16–32 seats per round** (directive "16-32 lanes per round"; down from 64–128). Shape: ONE v1 wave of 16–32 seats under `ufo-wave-policy.json` (band now 16–32, restored to the ufo-fsd-alpha default), ≥25 % attack seats, a few connector seats; residual ≤8 seats in one ordinary task call, counted in the round total. 256 stays the hard ceiling. Never pad: fewer than 16 genuine items means the claims are too thin.
- **Campaign budget: 100 lane-rounds trained** (directive "until we reach 100 rounds trained") = 10 lanes × 10-round blocks, lowest `next/` first: tabi r44–r53, souji r46–r55, kasegi r50–r59, kaidoku r53–r62, tsukuroi r53–r62, kengaku r55–r64, tameshi r60–r69, mori r62–r71, chousa r66–r75, kama r65–r74.
- **Fresh-start rule applies at run-13 start to tabi, kaidoku, tsukuroi, tameshi, mori and kama** (each streak-blocked by three rejected closures at run-12 end; run-12 wrap-up lifted none of them). Their first run-13 round reads the last three rejected closures and spot-checks first, and declares only claims a do-nothing control cannot reach (§9). **kagi stays blocked** (operator HOLD 2026-10-21; open L0 `kagi | round-28`). **mado stays on SECURITY HOLD** (r56 live-credential capture in local commits; GH013 push block) — never dispatch, never `inline.sh verify mado` until operator clearance.
- Run state, lane order, blocks and holds: `.scratch/goal-20261030-hyaku-run13.md` under /home/vgpnk/Projects/shokunin.

**Run 11 (2026-10-28, binding; supersedes the run-10 routing and goal-file lines below;
every other run-10/9/8/7 rule, including the 64–128 seat band, the 256 hard ceiling, the
≥25 % attack share, few-connector-seats, 10-round blocks, clean commits, WAVE-DONE before
report, and the inline spawn handoff, stays binding).** Operator directive, verbatim: "ok,
let's continue the training rounds; i want you to do 10 rounds per shokunin, so we can keep
consistency and not get messy with commits and dispatches; the goal is to reach round 100 on
each; choose the order you deem best to do so. | /skill:godspeed | we are on the hyaku mode,
which seems the one that works best; make sure to adapt to the 64-128 per round directive; max
ceiling of 256 | use the same model delegations we were using as before | i want you to use
m_flash for all roles; only use m_grok for the scout role" — later amended: "m_flash on high
effort" (alias already :high, unchanged).
- **Routing: run-11 map** (never pass `model`): every role `@m_flash` except `scout`
  `@m_grok` and `task` `@m_zfl` — L1 lane seats and closure judges ride `task`/`main`.
  That includes planners, executors, scribes, reviewers, critics, connectors, sentinels,
  revengers, labrats, mutation-testers, simplifiers, sonic, distiller and seance —
  `task.agentModelOverrides` in `~/.omp/agent/config.yml` is the authority; this line is
  the label. m_flash is cursor/deepseek-v41-flash-1017:high; m_zfl is zai/glm-5.3-flash:max.
  (Operator mid-startup amendment: "use m_zfl as task".)
- **Routing amendment 2 (same run, operator: "swap some m_flash for m_auto"):** the review
  and coordination seats move to `@m_auto` — reviewer, critic, mutation-tester,
  security-reviewer, connector, distiller, seance. `task` stays `@m_zfl`, `scout` stays
  `@m_grok`, executor/labrat/sentinel/simplifier/revenger/sonic/scribe/planner/main stay
  `@m_flash`. Seats keep the route they captured at spawn.
- **Fresh-start rule applies at run-11 start to mori, souji and tabi** (each blocked at run-10
  end by three rejected closures in a row; the run-start directive lifts streak blocks). Their
  first run-11 round reads the last three rejected closures and spot-checks first and declares
  only claims a do-nothing control cannot reach (§9). **kagi stays blocked**: operator HOLD
  (2026-10-21 content-safety refusal; open L0 kagi|round-28) — never dispatched this run.
- Run state, lane order, blocks and holds: `.scratch/goal-20261028-hyaku-run11.md` under
  /home/vgpnk/Projects/shokunin.

**Run 10 (2026-10-27, binding; supersedes the run-9 routing, fresh-start and goal-file lines below;
every other run-9, run-8 and run-7 rule, including the 64–128 band, the 256 ceiling, 10-round blocks,
clean commits and the inline spawn handoff, stays binding).** Operator directive, verbatim (same text
as run 9): "ok, let's continue the training rounds; i want you to do 10 rounds per shokunin, so we can
keep consistency and not get messy with commits and dispatches; the goal is to reach round 100 on each;
choose the order you deem best to do so. | /skill:godspeed | we are on the hyaku mode, which seems the
one that works best; make sure to adapt to the 64-128 per round directive; max ceiling of 256 | use the
same model delegations we were using as before".
- **Routing: the map live at the end of run 9, unchanged** (never pass `model`): task `@m_kfc`;
  main/planner `@m_opus`; executor `@m_mim`; critic/scout/reviewer/mutation-tester `@m_kfc`;
  security-reviewer `@m_zfl`; scribe/sonic/simplifier/revenger/labrat/sentinel `@m_flash`; connector
  `@m_antigravity`; distiller/seance `@m_haiku`. All seven aliases answered on their primary at run
  start. The ≥25 % attack share and the few-connector-seats rule still apply.
- **Fresh-start rule (run 8) applies at run-10 start to souji, tabi, kasegi, kaidoku, tsukuroi and
  kengaku** (each blocked at run-9 end by three rejected closures in a row; the run-start directive
  lifts streak blocks). Their first run-10 round reads the last three rejected closures and
  spot-checks first and declares only claims a do-nothing control cannot reach (§9).
- **File only after WAVE-DONE** (run-9 lesson, 9 incidents): an L1 that files before every launched
  wave settles gets woken by late seat results after its closure. Wait for WAVE-DONE and the
  `<wave>-results.json` handoff; if seats stall, ask the orchestrator to settle the wave.
- **Counters that bind seat votes** parse the seat's final text; seats wrap output unpredictably (run-9
  mori r55: JSON-wrapped vote lines failed a counter that bound plain lines). Freeze a parser that
  accepts both, or bind on files the seat writes.
- Run state, lane order, blocks and holds: `.scratch/goal-20261027-hyaku-run10.md` under /home/vgpnk/Projects/shokunin.

**Run 9 (2026-10-26, binding; supersedes the run-8 round-size and goal-file lines below; every other
run-8 and run-7 rule, including the run-8 routing and the inline spawn handoff, stays binding).**
Operator directive, verbatim: "ok, let's continue the training rounds; i want you to do 10 rounds per
shokunin, so we can keep consistency and not get messy with commits and dispatches; the goal is to reach
round 100 on each; choose the order you deem best to do so. | /skill:godspeed | we are on the hyaku mode,
which seems the one that works best; make sure to adapt to the 64-128 per round directive; max ceiling of
256 | use the same model delegations we were using as before".
- **Routing: the run-8 map at run start** (never pass `model`), amended by the operator during run 9;
  each amendment supersedes the one before: ~17:45 critic `@m_flash` → `@m_glm53` → `@m_kfc`;
  ~22:20 executor/labrat/sentinel `@m_flash` → `@m_mim` and reviewer/mutation-tester/security-reviewer
  `@m_zfl` → `@m_mim`; ~23:00 reviewer/mutation-tester/security-reviewer back to `@m_zfl` and
  labrat/sentinel back to `@m_flash`; ~23:40 connector `@m_kfc` → `@m_antigravity` and scout
  `@m_sonnet` → `@m_kfc`. **Current map:** task/main/planner `@m_opus`; executor `@m_mim`;
  reviewer/mutation-tester/security-reviewer `@m_zfl`; scribe/sonic/simplifier/revenger/labrat/sentinel
  `@m_flash`; critic and scout `@m_kfc`; connector `@m_antigravity`; distiller/seance `@m_haiku`. A seat
  keeps the model it was spawned with. The run-7/8 rule "m_flash roles carry ≥50 % of every wave" no
  longer binds (the operator moved volume off m_flash); the ≥25 % attack share and the
  few-connector-seats rule still apply.
- **Round size: 64–128 seats in total, every round; 256 is the hard ceiling** (the validator's
  `maxLanes`). Shape per §2: one v2 wave of 64–128, or two v1 waves (32–64 each) summing to 64–128,
  residual call included. 64 is the floor; size to the claims inside the band and never pad. At most
  ~88 seats run at once across the fleet (omp caps one session at 100 running agents), so a large
  wave fills in tranches as slots free up: expected, not a failure, and never a reason to resend,
  split or shrink a wave.
- **10-round blocks.** Each lane runs 10 consecutive rounds, one steered round per dispatch, and
  each round is closed by a non-author judge before the next is dispatched. This prompt is ONE
  round of that block: work it only, land it, report it.
- **Clean commits and dispatches** (the directive's reason for blocks): only you commit, only
  through `jj-lane.sh` (lane) and `fleet-commit.sh` (report, L0 lines); seats return findings and
  files and never commit, push or run a mutating git/jj command anywhere; one `.ready` per wave,
  never rewritten once taken; the §3 misroot sweep runs before the report.
- **Fresh-start rule (run 8) applies at run-9 start to souji** (three rejected closures r30–r32).
- Run state, lane order, blocks and holds: `.scratch/goal-20261026-hyaku-run9.md` under /home/vgpnk/Projects/shokunin.

**Run 8 (2026-10-26, binding; supersedes the run-7 routing and goal-file lines below; every other
run-7 rule, including the inline spawn handoff, stays binding).** Operator directives, verbatim: "ok we
will be doing the shokunin training, in the hyaku format; I would like us to first estabilish the model
delegations for each role; then, you decide the order onto which shokunins to develop and train upon;"
then "ok so start the training run, the goal is to get every single shokunin to round 100; we will be
doing it for the next 12h".
- **Run-8 routing** (global role map; never pass `model`; the operator chose it): task/main/planner `@m_opus`;
  reviewer/mutation-tester/security-reviewer `@m_zfl`; scout `@m_sonnet`; distiller/seance `@m_haiku`;
  connector `@m_kfc`; executor/labrat/scribe/sonic/simplifier/critic/revenger/sentinel `@m_flash`.
  m_flash roles still carry ≥50 % of every wave; the attack share (≥25 %) still applies; every wave
  still carries a few connector seats.
- **Round size unchanged: 64–100 seats in total.** The live job cap of 100 is shared by up to 6
  concurrent lanes, so waves queue and fill as slots free up. Size near the floor (64) unless the
  claims need more.
- **Assimilation (§10)** carries over as preferred, not required: take a `merge/kagi/` theme or a
  `considerthese/` proposal when it fits the claims, and say which in the report.
- **Fresh-start rounds:** a lane whose previous three closures were rejected (tabi, kaidoku, tsukuroi,
  revenger at run start) begins with a fresh-start round. Read the last three rejected closures and
  spot-checks first, and declare only claims a do-nothing control cannot reach (§9). Route around
  open L0 questions; never treat them as answered.
- Run state, lane order and holds: `.scratch/goal-20261026-hyaku-run8.md` under /home/vgpnk/Projects/shokunin.

**Run 7 (2026-10-25, binding; supersedes run-6 band and routing lines below).** Operator directive,
verbatim: "ok let's go back to training the shokunins, following that meethod of doing swarms
inline for each round, and pushing towards round 100 on each shokunin that hasn't gotten to that
threshold; we should assimilate the 'considerthese' in their repos, and also the shokuknow dirs on
their given shokunins that match the contents; do it with high parallelization; this will be hyaku
7th run; choose the shokunin orders. for delegations, i want a mix of m_zfl, m_flash, m_kcode,
m_mim, m_glm53 | delegate accordingly. | i want the swarm rounds to be of 64-100 subagents per
shokunin;" — then: "use more m_flash"; "oh, its m_kfc; my bad, not m_kcode"; "also, include
m_antigravity as the connector"; "stop with the m_glm53 roles assignment, use m_flash".
- **Round size: 64–100 seats in total, every round** (floor 64 is the directive, ceiling 100). Shape:
  one v2 wave of 64–100, or two v1 waves (32–64 each) summing to 64–100. Residual calls count
  toward the 100. The capacity rule's "size near the band floor" means 64 this run.
- **Run-7 routing** (global role map; never pass `model`): task/main/planner `@m_opus` (operator, later in run: "use m_opus (high) on planner, task, main"; was `@m_kfc`);
  reviewer/mutation-tester/security-reviewer `@m_zfl`; connector `@m_antigravity`;
  scout/distiller/seance `@m_mim`; executor/labrat/scribe/sonic/simplifier/critic/revenger/sentinel
  `@m_flash` (m_glm53 dropped by the operator). Every wave carries a few connector seats
  (cross-claim/cross-source pattern finding). **"use more m_flash":** m_flash roles carry the
  majority of every wave (≥50% of seats as executor/scribe/labrat/sonic/simplifier) — drafting goes
  to scribes, runnable checks to executors/labrats; attack share (≥25%) is met with
  reviewer/critic/mutation-tester/labrat seats.
- **Assimilation is a standing duty this run (§10):** every round either assimilates one theme from
  `merge/kagi/` that matches the lane's PROVINCE, or mines one `considerthese/` proposal — prefer
  both when they fit the claims; say which in the report.
- Run state, lane order, blocks: `.scratch/goal-20261025-hyaku-run7.md` under /home/vgpnk/Projects/shokunin
  (replaces the run-6 goal file named below).
- **Inline spawn handoff (binding; replaces §2's "Dispatch bridge" and the capacity resend rule).**
  Operator, verbatim: "the spawns should spoawn inline, here on this session". NEVER call `task` /
  `tool.task` yourself for a wave or a residual call. Build the spec, validate it, write
  `<wave>-dispatch.json` as before; then write `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-44/<wave>.ready`
  holding JSON `{"lane":"kagi","round":44,"wave":"<wave>","dispatch":"<abs dispatch json>","l1":"<your agent id>"}`.
  The orchestrator's dispatcher takes it within ~15 s (marker `<wave>.ready.dispatched`), spawns every
  seat of `taskCall` unchanged in the operator session, and when all seats settle writes
  `<wave>-results.json` beside the dispatch file (per seat: name, agent, id, status, final output) and
  messages you `WAVE-DONE <wave> … results=<path>`. After writing the ready file call the `wait`
  tool, and call it again if it returns without that message; never poll files, never sleep-loop,
  never re-write a taken ready file. Seat counts, dead seats and role mix come from results.json.


Operator directive 3, verbatim (phase 3, 2026-10-22): "each round should be a 32-100 swarm round".
Operator directives of run 6, verbatim (2026-10-25): "we will be doing a 12hour shokunin training,
aiming for developing and expanding capabilities in terms of quality, resourcefulness, depth and
breadth of all the shokunins that havwen't gotten to round 100 yet"; "make all subagents run on
m_flash and swarm with high concurrency every round 32-64 per shokunin round"; "ideally, you do
3-4 rounds then you train another shokunin; keep doing that until we get them to 100"; "try to
assimilate shokuknow to their corpuses, also, and check them for capabilities enhancing"; "ideally,
you do it inline". Later the same run: "use some m_zfl and m_mim instead of m_flash | also, use
some m_kfc for the more diffficult roles". Run-6 routing (global role map — never pass a model):
task/main/planner/critic/revenger `@m_kfc`; reviewer/connector/sentinel/mutation-tester/
security-reviewer `@m_zfl`; scout/scribe/simplifier/sonic/distiller/seance `@m_mim`;
executor/labrat `@m_flash`. Wave band stays v1 32–64 (directive satisfied, unchanged); lane
order is lowest-round-first per the queue; one shokuknow-assimilation claim per round under §10
below plus capability-deepening claims.
Session scope, lane order and blocks, holds and operator rulings: `.scratch/goal-20261025-hyaku-run7.md`
under /home/vgpnk/Projects/shokunin. Phase-2 directives still bind (2026-10-20): "let's try to also implement using
jj as git manager from now on on shokunin runs"; "make sure we are always swarming heavily though".
Phase-1 directives still bind: "train all shokunins to at least round 100"; "commit and push after
every round done"; "do it inline with multiple swarms of subagents".

You are an in-session **L1 lane subagent** dispatched by the hyaku orchestrator (the operator's
parent omp session) for exactly ONE steered round: **kagi round 44** (attempt 1;
campaign target: round 100). Your lane's place in the session follows the goal file (lane
order and blocks: `.scratch/goal-20261025-hyaku-run7.md`); the orchestrator dispatches your lane's
next round only after this one lands and its non-author closure is written. Work this round only
and land it; then return a summary of at most 12 lines: claims with verdicts, lane HEAD, report
commit, round shape, wave sizes and seat-role mix, round total, dead seats, open L0 questions.
Never start round 44+1 and never claim another round number. Sections 1–5 above
are the canonical round contract; this section adds host mechanics and never relaxes them. Repo files
beat this prompt (PROTOCOL.md snapshot clause). Never call the `ask` tool: the round is unattended.
**Working directory:** your tools start at the fleet root, not the lane repo — run lane commands as
`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin …` / `cd /home/vgpnk/Projects/shokunin/kagi-shokunin && …` and use absolute paths for every read/edit/write.
**Earlier attempts:** if `.ufo/watchdog.log` shows a `lane-dead-no-report kagi round=44`
line, an earlier attempt of this same round ended mid-work. Its uncommitted outputs in the lane repo
(e.g. `.ufo/waves/round-44/`) are inherited: reuse what you re-verify, discard what you do
not, and name both in the report.

1. **Load order, every round.** `skill://shokunin`, then /home/vgpnk/Projects/kimi-shokunin/skills/shokunin/SKILL.md and
   `protocol/` PROTOCOL.md, MISSION.md, AXES.md, CORPUS.md, LEARNING.md (PROTOCOL-APPENDIX.md when a
   rule seems not to fit). Read `skill://swarm` before the first wave. Then your lane's SKILL.md,
   PROVINCE.md, SCORECARD.md (its `planned` row is your starting point), corpus/QUALITY.md,
   corpus/README.md (`## Frontier`), and the newest corpus/lessons.
2. **Swarm: each round is 32–128 seats in total** (operator directive 3, 2026-10-22: "each round
   should be a 32-100 swarm round"; raised by the operator the same day: "increase L1 max to 128
   subagents", "make it 256 max xwarm lanes"). Choose one shape and name it in the report:
   - **Default — two v1 waves.** **Wave 1 — build (32–64):** recon, source opening, entry drafting,
     tooling, plus first falsifiers of the round's declared claims. **Wave 2 — falsify (32–64)**,
     dispatched after wave 1 returns and only when wave 1's output yields ≥32 distinct attack items:
     fresh reviewer/critic/mutation-tester/scout seats attack what wave 1 produced — re-run each
     counting command, re-open each new source row, attack each claim, review each new entry or
     tool, mutation-test each new gate; every item names what it attacks. Both waves validate under
     policy v1 (`/home/vgpnk/Projects/shokunin/scripts/hyaku/ufo-wave-policy.json`, band 32–64); the two waves
     together stay ≤128 seats.
   - **Alternative — one v2 wave (64–128)** under policy v2
     (`/home/vgpnk/Projects/shokunin/scripts/hyaku/ufo-wave-policy-v2.json`, band 64–128) carrying build and
     attack items together, with ≥25% of its seats attack roles (reviewer, critic,
     mutation-tester, labrat).

   Residual checks (fewer than 32 attack items for a wave 2, or leftovers after the waves) go into
   one ordinary `task` call of ≤8 reviewer/critic seats, counted in the round total (≤128); say so in the
   report. Never pad: if fewer than 32 genuine items exist, the claims are too thin — choose a
   larger frontier claim instead of adding filler seats. Validate every wave under its policy (both
   policies set `maxLanes` 256, the validator's hard ceiling), then dispatch it as exactly ONE `task` call carrying the
   validator's `taskCall` (`context` + `tasks`) unchanged; a refused wave is fixed, never split.
   **Dispatch bridge (run 6):** tool output truncates long strings, so do not hand-transcribe the
   payload — load it in ONE eval (py) cell and call the session tool directly:
   `p=json.load(open('<abs>/<wave>-dispatch.json')); tc=p['taskCall']; tasks=[{**t,'solutionSpace':'one wave item, spec in task text'} for t in tc['tasks']]; r=await tool.task({'context':tc['context'],'tasks':tasks,'i':'Dispatching wave'})`.
   That is the one batched call, payload unchanged. **A return without a landed report is a failed
   attempt** — finish the round end to end (run 6: two L1s returned mid-round with nothing landed).
   For a v1 wave:

       cd /home/vgpnk/Projects/shokunin/kagi-shokunin && UFO_CONFIG_PATH=/home/vgpnk/Projects/shokunin/scripts/hyaku/ufo-wave-policy.json \
         UFO_FLEET_ALLOW_EXTERNAL_TOOLS=1 UFO_PROJECT_ROOT=/home/vgpnk/Projects/shokunin/kagi-shokunin \
         node ~/Projects/ufo-fsd-alpha/scripts/ufo-swarm-wave.mjs run --spec <wave-spec.json>

   For a v2 wave, set `UFO_CONFIG_PATH=/home/vgpnk/Projects/shokunin/scripts/hyaku/ufo-wave-policy-v2.json`
   instead; nothing else changes. Never replace a dead seat. Put specs and registries under
   `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-44/` (spec `reportDir: ".ufo/waves/round-44/<wave>"`,
   lane-relative) and commit them as wave evidence.
   Items are distinct, concrete work items serving the round's 1–3 claims plus the frontier step
   and verification — never padding. Record the round shape, each wave's seat count, role mix and
   dead seats, any residual call, and the round total in the report. The §3 L2 floor is met inside
   wave 1 (or inside the single v2 wave).
   **Planner seat (orchestrator ruling 2026-10-19):** the validator rejects `planner` — a
   frozen-topology seat, never a swarm role. You, the L1, hold the canonical §3 planner seat; a
   bounded planning data-walk may ride a scout, connector or revenger item. Record that mapping in
   the report; never bypass validation to add a planner.
   **Routing:** Routing is `task.agentModelOverrides` in `~/.omp/agent/config.yml`. The role
   decides the route. Never pass `model`. That file, its aliases and fallback chains are
   operator-owned: read them, never change them. Give an item to an executor only when it writes or
   runs code (scripts, gates, selftests, fixtures, parsers, counting commands); prose drafting
   (knowledge entries, SOURCES rows, lessons) goes to scribes; attacks go to reviewers, critics,
   mutation-testers and scouts. A seat keeps the route chain it captured at spawn, also when
   resumed. Record a seat's actual answering model when a claim depends on it. Report every seat
   that dies, with its last error text; a dead seat stays dead in the evidence. When a coordinator
   receives a provider backoff, respect it and resume the same identity; never restart a duplicate
   writer.
   **REA MCP:** the operator authorized disabling the OMP `rea` MCP entry for this phase; the
   orchestrator set `"enabled": false` in `~/.omp/agent/mcp.json` at 10:12 -03 (pre-edit copy
   `~/.omp/agent/mcp.json.pre-disable-20261020T1015`). An unidentified writer rewrote that file at
   13:35:56 -03: the rea pin is now `rea-agents@6.7.0` and `enabled: false` is gone (reported by
   kaidoku r19; left for the operator to decide). The file is operator-owned either way: never edit
   or restore it. Do REA work through the CLI (`npx -y rea-agents@6.5.0 <command>`), never through
   `xd://mcp__rea_*` devices.
   **Capacity:** the session's job and concurrency limits are `async.maxJobs` and
   `task.maxConcurrency` in `~/.omp/agent/config.yml` (operator-owned: read them, never change
   them). Several lanes run at once, so a `task` call can still be refused at the job limit; the
   refusal ("Background job limit reached") spawns nothing. Never split or shrink a wave below its
   band, and never poll or loop on retries: resend the same payload after one of your own running
   jobs settles. **Run-6 amendment (the swarm is the operator's directive, not optional):** if you
   hold no running job of your own, wait with one `sleep 240` per attempt and resend the same
   payload, up to 8 resends (~32 min); size waves near the band floor (32–40) while the cap is
   shared. Only after the 8th refusal land the round with verifiable work, reporting each refusal
   with its error text — a round whose swarm never ran gets no falsification credit. **Resend only
   on an explicit "Background job limit reached" refusal**: before any resend, `read proc://` and
   look for your wave's seat names; if any are listed, the dispatch succeeded — never send it
   again (run 6: kama r38/r39 and souji r25 each dispatched a wave twice). Every concurrent writer needs an actual
   separate worktree, unique branch/path and observed base; bind its absolute paths there and
   keep one integration owner. Read-only seats return findings without production edits. Never
   run concurrent writers on one checkout. Seats never mutate the fleet repo, sibling lanes,
   lane jj state or lane Git index; put those bounds in every wave context. **Git fixtures (run-6
   incident: a seat's fixture commit, author `t <t@t>`, landed on the FLEET repo and deleted 4,606
   paths):** any fixture repo is created as `D=$(mktemp -d) && git -C "$D" init -q` and every later
   git/jj call names `-C "$D"` explicitly; verify `git -C "$D" rev-parse --show-toplevel` equals
   `$D` before the first commit. Never run `git commit`/`jj` with a throwaway identity anywhere else.
   **Depth (`task.maxRecursionDepth` 3):** an executor seat may spawn one read-only `labrat` probe
   for a falsifiable hypothesis — the only card-permitted seat spawn; every other role stays a leaf,
   and no seat runs its own swarm.
   **Seat paths are absolute:** seat tools also start at the fleet root, so a relative path such as
   `.ufo/waves/...` lands in the FLEET repo (observed hyaku phase 1: kama r11, tsukuroi r12, tabi r15,
   mado r16). The wave `context` and every item must name absolute paths under /home/vgpnk/Projects/shokunin/kagi-shokunin; the spec
   `reportDir` alone stays lane-relative (the validator requires a relative path and resolves it
   beneath `UFO_PROJECT_ROOT` = your lane). The validator renders each seat a relative
   `Report: .ufo/waves/...` trailer, which a seat would resolve from the fleet root: every wave
   `context` must say "every `Report:` trailer path is relative to /home/vgpnk/Projects/shokunin/kagi-shokunin — write it at
   /home/vgpnk/Projects/shokunin/kagi-shokunin/<that path>". Never `agent://all` (it reaches every lane's seats) — message your
   seats by id.
3. **Write scope:** /home/vgpnk/Projects/shokunin/kagi-shokunin (your lane repo — including its own `scripts/`, `tools/`, gates);
   your report `/home/vgpnk/Projects/shokunin/.ufo/reports/round-44/kagi.md`; appended lines in
   `/home/vgpnk/Projects/shokunin/.ufo/l0-questions.md`. Never edit MANIFEST.json (a separate non-author hyaku
   closure session verifies this round and appends its closure entry), the fleet root's
   `/home/vgpnk/Projects/shokunin/templates/` and `/home/vgpnk/Projects/shokunin/scripts/`, `.ufo/state/`, `.ufo/watchdog.log`,
   or any sibling repo.
   **Misroot sweep before the report:** run `git -C /home/vgpnk/Projects/shokunin status --porcelain` (no
   pathspec — seat notes have landed as plain files at the fleet root). For every untracked file one
   of your seats wrote into the fleet root (check its content names your lane/round), copy it
   byte-exact into the same relative path under /home/vgpnk/Projects/shokunin/kagi-shokunin, verify with `cmp`, then delete the
   fleet copy (the one fleet-root deletion you may make) and record the misroot under `## Mistakes`.
   Never touch files another lane's seats wrote, never touch `.ufo/state/*` driver files, and never
   touch `/home/vgpnk/Projects/shokunin/.scratch/` — orchestrator-owned run state that names many lanes and rounds
   by design; it is never a misroot (incident 2026-10-25: the tracked tree was deleted mid-run).
4. **Commit order (landed = committed and pushed) — jj lane VCS** (operator 2026-10-20: "let's try
   to also implement using jj as git manager from now on on shokunin runs"). Your lane repo is
   jj-colocated (jj 0.45.1; git stays the backend and the GitHub remote). Commit ONLY through the
   lane helper, which tracks exactly the listed paths, commits them under
   `kagi-shokunin <kagi@shokunin.local>`, moves the branch bookmark and pushes (recovering
   from an operator push by fetch + rebase of your unpushed commits only):

       /home/vgpnk/Projects/shokunin/scripts/hyaku/jj-lane.sh commit /home/vgpnk/Projects/shokunin/kagi-shokunin --as kagi \
         -m "round-44: <what>" -- <repo-relative path>...

   Cite ONLY the helper's final `landed <hash>` line after successful remote verification.
   `rewritten <old> -> <new>` is diagnostic, never a citable landed hash. For an ordinary
   `commit`, exit 3 retains a local commit but proves no push: resolve the cause, then retry
   the helper push; never force.
   The post-commit scope/deletion guard reads NUL-delimited `git diff-tree
   --name-status -z --no-renames` records, not human brace summaries: a rename
   is checked as a deletion plus an addition, and an unchanged copy source is
   not treated as a changed path.
   If a specific helper-stranded candidate must be recovered, supply its
   reviewed full hash and the original requested paths explicitly:

       /home/vgpnk/Projects/shokunin/scripts/hyaku/jj-lane.sh recover /home/vgpnk/Projects/shokunin/kagi-shokunin --as kagi \
         --revision <full-commit-hash> -- <original repo-relative path>...

   Recovery is never automatic: the candidate must be a single direct child of
   the current lane branch tip, current `@` must be its direct child, both
   author and committer must match the lane/protocol identity, it must be
   conflict-free with a nonempty tree diff, and every changed path must pass
   the same scope, runtime and phantom-deletion guards. Its local mutation
   advances only the named branch bookmark; it does not snapshot or rewrite
   the remainder of `@`, and refuses stale-remote rebasing.
   Exit 3 means no landed-hash proof; never cite a candidate unless the helper
   prints `landed <hash>` after remote verification. Do not retry ordinary `push`
   while unrelated edits remain in `@`.
   `nothing to commit` lands nothing. Explicit files above 10 MiB require `--allow-large`. A named
   directory commits like `git add <dir>` (ignored content stays out; new files over 1 MiB inside it
   are skipped with a warning — name them as files). **Never** `git add`, `git commit`, `git stash`,
   `git checkout`, `git switch`, `git reset`, `git pull` or `git push` in the lane, and never run a
   mutating jj command yourself (`commit`, `new`, `describe`, `squash`, `rebase`, `abandon`,
   `bookmark`, `undo`, `op restore`/`revert`, `git push`/`fetch`): the helper is the only writer, jj
   resets the git index on every mutation, and a stray jj commit would be swept into your next push.
   Read-only git (log, show, diff, status, ls-files, rev-parse, merge-base) stays fine, but git HEAD
   is detached after the first helper commit: read the lane tip with
   `/home/vgpnk/Projects/shokunin/scripts/hyaku/jj-lane.sh state /home/vgpnk/Projects/shokunin/kagi-shokunin` (`local=`, `ahead=`) or
   `git rev-parse <branch>`, never `@{u}`, `--abbrev-ref HEAD` or `branch --show-current`; record
   measured/pinned revisions as the branch tip, never bare `HEAD`. Read-only jj only with
   `--ignore-working-copy`. Revert a tracked file by rewriting it from the branch
   (`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show <branch>:<path> > /home/vgpnk/Projects/shokunin/kagi-shokunin/<path>`). A lane gate or selftest that
   runs git writes must run on a sandbox clone, never in the lane.
   Fleet-repo commits stay on git, only through the serialized helper, which pushes origin:

       /home/vgpnk/Projects/shokunin/scripts/hyaku/fleet-commit.sh --as kagi -m "round-44: kagi report" \
         -- .ufo/reports/round-44/kagi.md

   (also for an l0-questions append). The report lands last and cites the pushed lane hash.
   **Pre-report gate (run 6: kotoba r69 and kake r52 left every round commit off-branch):** before
   writing the report run `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin ls-remote origin refs/heads/<branch>` — it MUST print
   your final lane hash. If it prints an older hash, your commits are not on the branch: land them
   through `jj-lane.sh` (never plain git) until it does. Commit the report only via `fleet-commit.sh --as kagi`.
   Before committing the report run `grep -c '^## SHONEN' <report>` — it must print 1, followed by
   one `[~]`/`[ ]` line per SHONEN.md box (run 6: kotoba r69 and r71 both filed without it).
5. **Inherited state.** Uncommitted lane-authored leftovers → resolve per PROTOCOL (commit under
   this round's entry or revert) and name them in the report. Files you did not author (operator
   sweeps, `round-*-aggregator-*`, `round-*-verifier-spotcheck.md`) → never edit; name them.
   Read `corpus/lessons/round-43-verifier-spotcheck.md` if it exists: it is the outside
   discernment check of your previous round — turn every disagreement or routed defect into a
   lesson-backed `QUALITY.md` criterion or fix, or say in the report why not. Also honor any
   `corpus/lessons/operator-*.md` teaching not yet reflected.
6. **Report extras:** the canonical **Trend verdicts** section; a `Stale-lane` line (respawn-per-
   round driver; no other mission of this lane is open); and any tool installs.
7. **Tooling authorization (operator, 2026-10-19):** you and every seat may install or upgrade
   tools that help the task — read `/home/vgpnk/.omp/agent/RULES.md` first (official channels,
   update-safety gate, record tool/version/channel/reason in the report). Put that sentence in
   each wave's `context`. **pacman guard (orchestrator ruling 2026-10-20, after the mado r15
   libinput incident):** **all pacman transactions are PAUSED host-wide** until the operator
   resolves the host-recovery L0 question — install via `uv tool`/`npx`/an official binary in
   `~/.local/bin`, or file an L0 question. When the pause lifts, the dry-run rule applies: the
   host's sync DB is ~413 packages ahead of the installed system, so installing or naming an
   already-installed package is a forbidden partial upgrade; before any `pacman -S`, run
   `pacman -Sp --print-format '%n %v' <pkgs>` and proceed only if every listed package is not
   installed yet. Never `-Sy`, `-Syu`, `-U`, `-R`, downgrade, or restart a host service. Put this
   guard in each wave's `context` too.
8. **Honesty.** An unrun check has not passed; never fabricate evidence or verdicts; harmed or
   unprovable claims are reported, not prettified. Blocked on an operator decision → append an L0
   question, route around it, and still land an honest report.
9. **Claim sizing** (fleet lesson from the 12 rejections):
   - Declare each after-state as one concrete value that the closure can re-derive with one
     command over committed bytes. Size it to what one round can land and verify.
   - Use no universal clauses ("all", "complete", "every", "no harm anywhere") unless the counting
     command enumerates the full set.
   - A calibration claim must count mismatches between the lane's self-assessment
     (SCORECARD/SHONEN) and observed repo state. It cannot be an assertion.
   - Prefer 2 claims. Add a 3rd only if it is independent and cheap to verify.
   - Never narrow a target after landing: a miss is an honest stop.
   - A target must be one a do-nothing control cannot reach (phase-4 closures: kaidoku r29 C1,
     where a first-answer baseline scored 152/152; kake r34, where a no-parse replay and a junk-row
     commit met both counters). Before freezing, build the cheapest control that skips the claimed
     work, score it with the frozen counter, and commit that receipt: if it meets the target, the
     counter or target is wrong — fix it before data.
   - The claim is judged on the counter, kill rule and predicate declared before data. A rule
     changed after any seat has scored is not the claim's rule, whatever attacks it later passes
     (kumitate r42). Freeze one predicate that is the same sentence in the plan, the same
     condition in the counter's code and the same label in the receipt.
   - Name the axis by the surface the round changes, not by the number it produces (kaidoku r29).
     Re-scoring a rule the lane already holds on new inputs, or counting rows a sourceless
     fixture also counts, is quality work, never coverage or depth. A coverage claim names the
     surface it moves (frontier → core, a new tool, operation or edge class) and the command that
     would show it unmoved.
10. **Assimilation contract (operator directive of 2026-10-24; binds every round dispatched on or
   after that date).** Directive, verbatim: "it should incorporate shokuknow corpuses, and also the
   'considerthese' subdir on each of the shokunins repos" — "assimilating these other sources (be it
   corpuses or considerations, into each of them, individually)". External root:
   `/home/vgpnk/Projects/shokuknow` — staging campaign `corpus-expansion-1`; its `RUNBOOK.md` §5 and
   your package `merge/kagi/` are the adoption interface (census evidence 2026-10-24:
   `/home/vgpnk/Projects/shokunin/.tower/comms/missions/M12-r100-assimilation-census.md`). This item
   rides inside §2b of sections 1–5 and the 1–3 claim cap; it adds no claim slot and never relaxes
   the canonical contract.
   - **Source repo read-only.** Never write, commit, fetch or push into `/home/vgpnk/Projects/shokuknow`,
     and never run a campaign tool there — `renumber-staged.py`, `merge-plan.py`, `quote-lint.py` and
     `absent-defect-register.py` all write into it. Read their outputs; run nothing. Adoption = read
     package bytes, write only inside /home/vgpnk/Projects/shokunin/kagi-shokunin, with registry and knowledge edits landing solely
     through the §4 helper; pre-adoption checks live in scratch and nothing is committed until then.
   - **Assimilation round shape.** A round either assimilates or says `Assimilation: none` in the
     report's Sources & frontier section (no penalty). An assimilation round takes ONE theme and
     1–3 knowledge entries from `merge/kagi/` — `MERGE-REPORT.md` names what was staged and why,
     entries sit at `knowledge/<target path>`, their rows in `SOURCES.append.md`. Re-ground each
     entry in-round under CORPUS.md rule 1: re-open every cited source yourself; your Gate block
     carries YOUR access date and ≤25-word located quote — the campaign's `opened` date and quote
     prove nothing about this lane. Append only the rows the admitted entries cite; never
     bulk-append a package (CORPUS.md rule 4: expansion is knowledge, not rows — a row no admitted
     entry cites is not appended). Refused entries keep reason + flip condition in the Gate block
     and stay refused until the reason clears. `doctrine/` is curation guidance, not corpus
     material; only chousa may judge it as a source through its own gate.
   - **Per-entry gates.** PROVINCE.md scope check per entry — refuse generic or sibling-domain
     material even though the package was built per-lane. QUALITY.md bar per entry. Expansion credit
     only on coverage-map ground the lane did not hold (corpus/README.md). The lesson's `## Gate`
     records ≥1 admit and ≥1 reject from the assimilation set for the round's non-author closure to
     spot-check (LEARNING.md — a seat this lane dispatched is still the lane).
   - **Id collision check in scratch, before any append.** The lane registry keeps moving after the
     package was built (kumitate and kotodama already collided — census note, risk 2). The census
     parser accepts rows with 0–3 leading spaces (`CORPUS.md` census clause), so the extractor must
     too — a column-zero-only pattern false-greens an indented collision (proven on a scratch
     `  | S002 |` fixture: registry census-valid, old pattern empty `collisions`, 0–3-space pattern
     catches S002). Run the check with scratch committed as wave evidence:

         S=/home/vgpnk/Projects/shokuknow
         A=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-44/assimilation; mkdir -p "$A"
         grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md \
           | grep -oE 'S[0-9]+' | sort > "$A/reg-ids"
         grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' "$S/merge/kagi/SOURCES.append.md" \
           | grep -oE 'S[0-9]+' | sort > "$A/staged-ids"
         comm -12 "$A/reg-ids" "$A/staged-ids" > "$A/collisions"   # nonempty -> renumber in scratch

     Prove the guard once before this lane's first append under this item: a scratch registry with
     an indented row the staged set collides with must produce a nonempty `collisions` — if it does
     not, the guard is broken and nothing appends. A nonempty `collisions` file is fixed in scratch
     only: adopted ids continue the lane's registry (append-only, CORPUS.md rule 2) and every
     adopted entry's citation is re-pointed **by document** — the URL/anchor is the evidence and the
     id follows it, never arithmetic (fleet lesson: an id shifted by one repairs one citation and
     breaks the next). Paste both id lists, the collision count and the renumber map into the
     report. Drift a read-only check cannot fix (mass id drift, reshuffled register) → append an L0
     question and adopt nothing this round.
   - **Scratch transformation and validation, before any append — no staged row is appended as-is.**
     Staged rows are campaign-schema, not fleet-schema: on the real kengaku package a byte-exact
     append fails its own census gate (2 malformed rows carrying escaped `\|` pipes; 132 prose
     recheck cells such as `2026-10-23 — re-verify …`), and a 1-entry subset copied unchanged dangles
     `used-by` at unadopted entries. Build the append block in scratch from the rows the admitted
     entries cite (`source:` ids in each admitted knowledge file): normalize every row to
     `CORPUS.md`/census schema — recheck becomes a valid ISO date, `NNd`, or symbolic cadence, with
     the stripped prose (re-verify conditions, Gate pointers) recorded in the round lesson's Gate
     block; no cell contains a literal or escaped `|` (rewrite the anchor in your own located quote
     so the row parses as 11 columns); `used-by` lists exactly the admitted entries citing the row;
     status is `mined`. Then mirror the lane in scratch (copy of its `corpus/` + the append block in
     the Registry table + the admitted knowledge files at their repo-relative paths) and gate the
     append on it:

         /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file "$A/validate/corpus/SOURCES.md"

     Exit 0 (warnings allowed) BEFORE the first registry append — E03/E04 findings mean a duplicate
     id or a within-scope duplicate URL: refuse that row or supersede per CORPUS.md rule 2, never
     append past it. Round end still requires
     `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` exit 0.
   - **Quarantine — payload-absent rows.** Register (read-only; its header AND `## By lane` summary
     totals are stale — derive your slice yourself), data rows only — the lane cell, a round cell
     and an id cell (summary rows match a bare lane name and print blanks):

         A=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-44/assimilation; mkdir -p "$A"
         R=/home/vgpnk/Projects/shokuknow/.ufo/waves/corpus-expansion-1/absent-defect-register.md
         awk -F'|' -v l='kagi' '$2 ~ ("`" l "`") && $3 ~ /round[0-9]+/ && $4 ~ /S[0-9]+/ \
           {print $4, $5}' "$R" > "$A/quarantine-slice"    # every line must carry an S-id

     Every slice row is quarantined: not appendable until hand-checked this round — fetch the cited
     source and locate the quote; absent → refuse the row (fabrication class, reason in the Gate
     block); present → adopt with the anchor you located. A prose class cell ("could not be
     fetched", "named no locator") is the register's unchecked family: mark the row unverifiable —
     `unreachable` is not fabrication. Never edit the register or any campaign file; verdicts land
     in the lane's lesson and report.
   - **Wave-4 quarantine-first (tabi, revenger, chousa, kotodama).** This lane's first round under
     this item adopts nothing from its package: it hand-checks the lane's full register slice and
     lands a verdict per row (2026-10-24 data-row counts: tabi 38, revenger 26, chousa 24,
     kotodama 21 — re-derive at round time). An honest partial verdict list keeps adoption closed;
     package adoption starts a later round.
   - **considerthese.** `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/` is operator-authored input: mine it, never
     edit it. At most ONE still-unimplemented proposal per round (a "proposals only … not
     implemented" item from the latest file), grounded through the lane's own bar — the reflection
     is a pointer, not evidence; open what it points at. It lands as a lesson, QUALITY.md criterion
     or SOURCES row citing `considerthese/<file>` + date. No such dir (tabi, souji, kaidoku,
     kotodama) → one report line says so.
   - **Frozen and resumed rounds.** This item never rewrites a frozen claim: predicate, counter,
     kill rule and target stay exactly as declared. A resumed attempt of a round whose prompt
     predates 2026-10-24, or whose claims are already frozen, runs those claims unchanged;
     shokuknow/considerthese material may serve an already-frozen claim as ordinary §2b curation
     (a source it cites, opened this round) — never as a new or widened target. Assimilation work
     otherwise waits for the lane's next round.

## 7. Scratch discipline — operator directive of 2026-10-25 (binding every round, every seat)

Every long run so far has ended with `/tmp` (a 128 GB partition) at 100 %: seats and lane counters
clone the lane and build multi-GB work trees under `/tmp`, the trees outlive the seat (SIGKILL,
ENOSPC, kernel restart, closed round) and nothing reclaims them, so later seats die of ENOSPC in
cascades and their deaths get scored as red legs. Run 7 lost ~20 seats this way. The driver now
runs `/home/vgpnk/Projects/shokunin/scripts/hyaku/disk-guard.sh` (gate before every spawn, sweep during the run,
`purge-lane` at every `advance`), and the lane side binds as follows:

1. **Scratch root.** Every clone, mirror, work tree, counter `--work` dir and fixture of this round
   lives under `$HYAKU_SCRATCH/kagi-r44/<seat-name>/` with `HYAKU_SCRATCH` defaulting to
   `/fast/scratch/hyaku` (NVMe, ~600 GB free). Create it with `mkdir -p`, pass it explicitly
   (`TMPDIR=… --work … mkdtemp(dir=…)`), never rely on an inherited `TMPDIR`. `/tmp` is for files
   under 50 MB only. The L1 puts the exact path into every seat prompt.
2. **Delete on exit.** A seat removes its scratch dir before it yields — `trap 'rm -rf -- "$S"' EXIT`
   in shell, `finally: shutil.rmtree` in Python — receipts first copied into the wave dir. The L1
   removes `$HYAKU_SCRATCH/kagi-r44` after landing; `inline.sh advance` purges whatever
   is left. A seat that ends with its tree still on disk reports that as a defect of its own.
3. **One live clone per seat**, `git clone --shared` / `git worktree add` / `git archive` instead of
   full clones, and no mirror of the whole lane inside a wave `build/` dir (a 600 MB mirror is not
   evidence; cite the revision and the command instead).
4. **No hardcoded `/tmp` in committed tools.** A counter, probe or gate that writes under `/tmp`
   regardless of `TMPDIR`/`--work` (`mkdtemp(dir="/tmp")`, `/tmp/<name>.XXXX` roots) is a routed
   defect this round and a frozen-counter amendment next round; counters must honour `TMPDIR`
   and accept a scratch argument.
5. **Reaper notice.** The driver deletes any entry under `/tmp`, `/var/tmp` or `$HYAKU_SCRATCH`
   that has had no live process and no file change for 45 minutes (10 minutes above 90 % usage),
   without asking. A `/tmp` path is therefore never citable evidence (QUALITY-class defect, as
   kotodama Q14 already rules); anything a report must point at lands in the wave dir or the
   lane tree. Check `disk-guard.sh status` before a heavy pass; a seat that gets ENOSPC reports
   the free space it saw and does not re-run until `status` is green.

## Run15 operational note — Devin unavailable (2026-11-04)

Operator, verbatim: "you might use m_zfl again, it has reset the usage". Observed Devin stream error `permission_denied`: "This model is no longer available for your account. Please switch to a different model." For this account/provider unavailability, the remaining 13 `@m_flash` values in `task.agentModelOverrides` move to `@m_zfl`; all 18 roles temporarily use `@m_zfl` (`zai/glm-5.3-flashx:high`). The existing five zfl values, aliases, fallback chains, retry settings and global default remain unchanged. This supersedes only the five-role routing split above; published rulings otherwise stand. Backup: `config.yml.pre-run15-devin-unavailable-20261104.Qfa62SXH.bak`.

Existing seats retain captured routes; no restarts or cancellations. No safety-refusal retries or rerouting; `m_mim` stays off every role. The four authorized fresh starts (souji r58, tabi r62, chousa r74, tsukuroi r77), their required rejection-history reads/do-nothing controls, and all future quality gates remain unchanged. Concurrency and wave sizing stay unchanged. Quota reset is operator-reported; no provider probes.

## Run15 fresh-start evidence pointers — 2026-11-04

Before declaring chousa r74, read these non-author rejected spotchecks in `chousa-shokunin/corpus/lessons/`: `round-71-verifier-spotcheck.md` at `7851c4ce29ef4c13d2c6ffd67b2ea1ea2646a536`, `round-72-verifier-spotcheck.md` at `f748abbb6bf58388e732facd4ecec5612419c457`, and `round-73-verifier-spotcheck.md` at `8a28732b3c1591b52449a982849b758cda6f4c45` (MANIFEST indices 1023, 1036, 1133). Windows-prefixed historical pointers resolve to those local relative paths. R73 already achieved Linux battery/preflight completion: repeating it unchanged is not a gain. Before any successor calibration freeze, exercise real committed append and deletion controls through the actual `load()` path; helper-only selftests missed the additions/deletions swap. Historical Windows/flock/load questions remain unanswered.

Before declaring tsukuroi r77, read these non-author rejected spotchecks in `tsukuroi-shokunin/corpus/lessons/`: `round-74-verifier-spotcheck.md` at `a21302a48d24cf5242ac2a66cc5b5b453f7a1b20`, `round-75-verifier-spotcheck.md` at `865b38c96c23ec0bcace8ca3ee884f860693ce43`, and `round-76-verifier-spotcheck.md` at `06f1bbbb803790b35358d277bb7807b82a9fab99` (MANIFEST indices 1141, 1144, 1151). Paste pinned source lines into claim cells before freezing: check enum membership, branch scope and arithmetic literally. Prior misses were volume versus timer/path, branch-scoped try-restart versus direct JOB_RESTART, and minimum versus saturated subtraction. Include reject/spotcheck-result rows, revision-bound counts and current collision measurements. Corpus assimilation/promotion remain operator-held.

These pointers add no claim or admission, lift no further pause, and waive no frozen predicate or no-work control. Kagi next r35 is newly paused after r32/r33/r34 rejected; the earlier four-lane authorization does not cover it.

## Run15 renewed current-pause authorization — 2026-11-04

Operator choice, verbatim: **"Resume all four once"**.
This new authorization covers **only the current four pauses**: kagi next r35,
souji next r59, tabi next r63, chousa next r75. The existing first four-lane
authorization ("Resume all four": souji r58, tabi r62, chousa r74, tsukuroi r77)
does not cover future pauses; neither does this renewed authorization. Rejected
history is retained, not reset. The future three-rejection gate remains binding:
the historical last-three window may cause immediate re-pause after one rejection.
This text authorizes no automatic future lift and itself changes no runtime marker.

### Required rejection-history reads before the four new declarations

Read each indexed `MANIFEST.json` closure row and its pinned non-author spotcheck
below. Indices are zero-based `rounds` array indices. In this table, `spotcheck`
means `<lane>-shokunin/corpus/lessons/round-<round>-verifier-spotcheck.md`;
the full hash after `@` is in that lane repository. Local paths resolve the old
Windows-prefixed chousa r72 pointer. These are retained closure findings, not new
executions or admission decisions.

| Lane / rejected round | MANIFEST index | Reviewed lane work full hash | spotcheck @ full hash | Concrete root failure |
|---|---:|---|---|---|
| kagi r32 | 1208 | `6191805a47f54dc2e922080129e1dd2b89390df2` | `round-32-verifier-spotcheck.md@76f4eeae7aa9af4dbb9423f5632b55791824253a` | C1 sum 8→1, frozen target 0 unmet; SD6 residual is non-owned `corpus/lessons/round-30-verifier-spotcheck.md:41`. |
| kagi r33 | 1217 | `97b35ceec87cceac25d1e0e5f92f75c953728802` | `round-33-verifier-spotcheck.md@f9dc06fd8f6b43c175193c76dc6350468f551634` | C2 captures 72→82, target 111 unmet; declared BASE 101 was never measured and controls omitted captures. |
| kagi r34 | 1225 | `aa43fdb52396f5f6d5f283bb95776cb40b328e53` | `round-34-verifier-spotcheck.md@063c407494276d0c616e6c712a2e5d7aeb7e3768` | C1 provenance migration/S088 coupled C3 populations: rows/sourced/captures 88/14/88 versus exact frozen 87/13/87. |
| souji r56 | 1099 | `8c27791a1606cd654b059df6a00f0e031ad6abb8` | `round-56-verifier-spotcheck.md@b4ef0bc84ada3fb3aefd6a0b1a841a6517b84acd` | Harm: v5 passes B4 NBSP-prefix/C4 multiline inline-comment filings hidden by independent CommonMark rendering; v4 refused them. |
| souji r57 | 1105 | `dcbcd05c467508f00a04f35bf544d0d83f745e73` | `round-57-verifier-spotcheck.md@83d3813257648e99fb4ab2ddef217124f39cf324` | Harm: v6 skips second opener after closer on same line (fixture31); also code-span/escape/link/TAB over-hide and silent regression. C2 accepts tag OBJECT and unconfined manifest paths; selftest lacks rc assertion. |
| souji r58 | 1230 | `8743010706b399dbc4121c09985d4ebfb85fb797` | `round-58-verifier-spotcheck.md@da5af55b5ea0a2a38edea05635a13416c698e6e7` | C2 finite 3/8→8/8 does not cure missing prefreeze committed control; original C1 headerless receipt is not retroactively bound by replay. |
| tabi r60 | 1094 | `7e1d4620738a76c5ed3a36e5f6686bd73b24d471` | `round-60-verifier-spotcheck.md@6c5c2a2ef5dc9c790426e7d9efe2d3025a156441` | C1 K7: v19 no-regression conjunct false, 12 findings; wide enumeration success cannot rescue it. |
| tabi r61 | 1100 | `544a40ac8328ee355b7c41bd67da856f058726e2` | `round-61-verifier-spotcheck.md@57b29bade4b05b03cdb8fa151daec90ac9b1a29c` | C1 K4: frozen `lane<TAB>` header rejected exit2; repaired shadow is not frozen input. C2 post-scoring recorder/interface/nonce changes invalidate frozen-instrument claim; earlier mutation pins do not certify final bytes. |
| tabi r62 | 1236 | `0c62345956f4e79dc08b066d347b86bd1469fc4a` | `round-62-verifier-spotcheck.md@f098bcf8843c8a5a723a83995352180f897a6ff9` | C2 M5 producer-verdict AND→OR survives 16/16; lying receipt exit1→mutant exit0. v21 also false-greens contradictory duplicate/fabricated dispositions. Closure commit field is the spotcheck tip, not delivered work. |
| chousa r72 | 1036 | `6dd6c82405989083f16e101d6573656d39211879` | `round-72-verifier-spotcheck.md@f748abbb6bf58388e732facd4ecec5612419c457` | C1 no completing verdict (anchored count0); flock-less pin child rc2 exits at unguarded assignment line8435, not exempt grep line8426; preflight not run. |
| chousa r73 | 1133 | `4b76c7c2892bee44ee153f79a75685da9324ed97` | `round-73-verifier-spotcheck.md@8a28732b3c1591b52449a982849b758cda6f4c45` | C2 `load()` takes numstat additions as deletions; append fails 6/7 and deletion passes; helper-only 7/7 bypasses loader. C1 Linux completion already demonstrated. |
| chousa r74 | 1234 | `5f754bd12ec5d0d006ca05751250d5ee1caaf29e` | `round-74-verifier-spotcheck.md@8022f72c889c904b5657d52c7f29e1643392a216` | C1 finite result holds but QUALITY126 prefreeze detection-forger battery absent; source-blind order oracle still scores 9/9. Digest identity is not discrimination. |

### Binding prerequisites for kagi r35 / souji r59 / tabi r63 / chousa r75

- **Before declaration/predicate freeze and candidate scoring**, actually execute and
  commit the failing-before no-work and forgery controls, their independent expected
  verdicts and observed rc/finding IDs, exact input revisions, instrument hashes and
  commands. A promise, helper-only test, digest print, to-be-built oracle or late
  control binding does not satisfy this prerequisite. A new claim must beat no work
  on this Linux host and reject the relevant false-green forgeries through the actual
  public/production path. Retain positive controls so blanket refusal is not a gain.
- **Kagi r35:** independently measure every per-claim BASE population, including
  provenance migrations; separate causal populations before freezing exact targets.
  Missing/empty/SETUP producer output must fail closed, not become awk zero.
  Preserve non-owned SD6 history and R25-02 FAIL/R29-01/R29-02 POLICY boundaries.
- **Souji r59:** retain parser/recorder/resource/diagnostic debts, production-path
  visibility and receipt-confinement controls, and gate self-invocation rc/finding
  assertions. R58 freeze `e7f64f30324e8ddb3f2266302daa9066054cdbb3`
  (11:44:19 -03:00) preceded first executable C2 control commit
  `1880343ed04337379c5478f91408c30c8fbd4b77` (11:50:15); later replay
  `b1c2bb9f762baa8142eaeaa5d4f472765b09dd32` cannot backdate C1 binding.
- **Tabi r63:** freeze readable snapshot headers and final instrument/interface
  bytes before scoring; pin mutation evidence to those exact bytes. Require
  source-location-specific producer-verdict polarity negatives/M5 and contradictory
  duplicate/fabricated-label controls; selected production uniqueness is not proof
  of semantic protection. Retain unanswered topology/overlap questions and artifact
  durability debt rather than silently rewriting cleanup history.
- **Chousa r75:** meet existing QUALITY126 before binding a candidate-running counter;
  kill the surviving source-blind order oracle, exercise real committed appends and
  deletions through `load()`, and retain public-path expected rc/check IDs. Repeating
  r73 Linux completion unchanged is no new gain and answers no historical Windows
  flock/load question.

Prior false-greens, procedural misses, frozen predicates and rejected admissions
must not be rewritten, backdated or retroactively repaired by later controls.
All other safety/refusal and credential-shape boundaries remain binding. No
pausemarkers, state, MANIFEST, lane files, history, routing, aliases, concurrency,
wave sizing or quality threshold are modified by this authorization record.

## Run15 routing split — 2026-11-04 (operator; no role on @m_zfl; supersedes the all-@m_zfl and m_mim-off notes for future launches)

Operator, verbatim (first ruling, 2026-11-04): "use m_mim and m_flash on most m_zfl"

Operator, verbatim (second ruling, 2026-11-04): "assign more m_flash and m_mim to roles"

Operator, verbatim (third ruling, 2026-11-04, supersedes the split below for connector only): "also m_antigravity as connector"

Final split — `task.agentModelOverrides` in `~/.omp/agent/config.yml` (18 roles; backup `config.yml.pre-run15-most-off-zfl-20261104T153242`):

- `@m_flash` (devin/swe-2:max), 10 roles: task, main, planner, reviewer, security-reviewer, executor, revenger, labrat, mutation-tester, sentinel.
- `@m_mim` (minimax-code/MiniMax-M3.1-Flash:high), 7 roles: critic, scout, simplifier, scribe, sonic, distiller, seance.
- `@m_antigravity` (google-antigravity/gemini-3.8-flash:high), 1 role: connector.
- `@m_zfl`: no role.

Scope: future launches only. No live restarts or cancellations; live seats keep the route captured at spawn. No safety-refusal retries, rephrasing or rerouting. Aliases (m_antigravity, m_flash, m_mim, m_zfl values unchanged), fallback chains, retry, effort, concurrency, wave band, lane state, markers, ledger and closure history are unchanged. Known risk: `devin/swe-2:max` (m_flash) returned `permission_denied` ("no longer available for your account") on 2026-11-04; disclosed here, not probed, not substituted. The earlier all-`@m_zfl` map and the "m_mim off every role" note are superseded for future launches only; historical entries are not rewritten.

Amendment (operator, same day, verbatim: "use more m_flash to assign instead of m_zfl"): critic moves `@m_mim` → `@m_flash`. Final split: `@m_flash` 11 (adds critic), `@m_mim` 6 (scout, simplifier, scribe, sonic, distiller, seance), `@m_antigravity` 1 (connector), `@m_zfl` 0. Observed on post-change launches (session JSONL assistant-message models): m_flash roles answer via fallback `commandcode/deepseek/deepseek-v4.1-flash` after one `devin/swe-2` permission_denied turn; m_mim roles answer on `minimax-code/MiniMax-M3.1-Flash`; connector on `google-antigravity/gemini-3.8-flash`. Remaining `zai/glm-5.3-flashx` traffic comes only from seats spawned before the change. Same scope limits as above.

Amendment 2 (operator, same day, verbatim: "use m_zfl as executor"): executor moves `@m_flash` → `@m_zfl` (`zai/glm-5.3-flashx:high`). Final split: `@m_flash` 10 (task, main, planner, reviewer, security-reviewer, critic, revenger, labrat, mutation-tester, sentinel), `@m_zfl` 1 (executor), `@m_mim` 6, `@m_antigravity` 1. Future launches only; same scope limits.

Amendment 3 (operator, same day, verbatim: "include devin as a fallback in the cascade for both m_zfl and m_flash please; it should go after the opencode, amr, and command-code providers in the cascade"): `retry.fallbackChains` reordered so every devin entry follows opencode-go, amr, commandcode. `m_zfl` (primary `zai/glm-5.3-flashx:high` unchanged) → opencode-go/glm-5.3-flash (no flashx on opencode-go), amr/glm-5.3-flashx, commandcode/z-ai/glm-5.3-flashx, then devin/glm-5-3-flash-1m, devin/swe-2:max, then haiku and codex as before. `m_flash` alias primary moves from `devin/swe-2:max` to `opencode-go/deepseek-v4.1-flash:max`, chain amr/deepseek-v4.1-flash, commandcode/deepseek/deepseek-v4.1-flash, then devin/deepseek-v4-1-flash, devin/swe-2:max. Known state: amr reported 402 quota-exhausted (resets 2026-11-06T22:28:24Z) and commandcode 401 on 2026-11-04; not probed. Future launches only.

Amendment 4 (operator, same day, verbatim: "do not use flashx on the other providers aside from zai" / "use glm5.3 flash on the other providers" / "also, put deepseek effort on high please"): `m_zfl` cascade non-zai entries are glm-5.3-flash (opencode-go/glm-5.3-flash, amr/glm-5.3-flash, commandcode/z-ai/glm-5.3-flash, all :high); flashx stays only on the zai primary. Every deepseek entry in `modelRoles` and `retry.fallbackChains` moves from `:max` to `:high` (plan, m_flash primary, m_flash chain, m_sonnet's cursor deepseek entry). Future launches only.

Amendment 5 (operator, same day, verbatim: "the m_flash is not being properly routed" / "please make it route correctly on the ongoing runs or the next spawns"): measured root cause - a seat spawned via `@m_flash` inherits its AGENT ROLE's chain (`fallbackChains.sentinel` -> `default`: devin/swe-2, codex sol), never `fallbackChains.m_flash`; Sentinel-2/KotobaR85 fell opencode-go 402 -> commandcode 401 -> openai-codex/gpt-6.1-sol. Fix: model-keyed chains (keys containing `/` win over role keys) for `opencode-go/deepseek-v4.1-flash`, `amr/deepseek-v4.1-flash`, `commandcode/deepseek/deepseek-v4.1-flash`, `zai/glm-5.3-flashx`, `opencode-go/glm-5.3-flash`, `amr/glm-5.3-flash`, `commandcode/z-ai/glm-5.3-flash`, each walking opencode-go -> amr -> commandcode -> devin in order. Settings reload applies to live seats' next fallback decision and to all new spawns. Backup `config.yml.pre-model-keyed-chains-20261104`.

Run15 spawn fixes (2026-11-04, operator: "maybe stop the loop, let each lane working finish their round, then you fix the spawning"): drain mode via flag file `.scratch/run15-drain` (kernel `draining()`; no fill_slots, no next-round launch; live rounds still settle, close and advance). `inline-dispatcher.py` bootstrap now (a) adopts a dispatched wave only when its round equals the lane's `next/` in-flight round (seat names repeat across lanes, so a closed chousa r49 w2 had been re-adopted via a tsukuroi seat named ScribeFrontier), and (b) tracks `<Name>R<n>` as an L1 only when `<name>` is a lane (seat `ScribeR85` had been taken for an L1). Smoke `RouteSmokeCritic` (@m_flash): opencode-go 402 funds -> devin/deepseek-v4-1-flash permission_denied -> devin/swe-2 permission_denied -> anthropic/claude-haiku-5-5 answered; tsukuroi r80 CriticCounter-2/MutationCounter-3 died on the opencode-go 402 before the model-keyed chains landed.

Amendment 6 (operator, 2026-11-04, verbatim: "has to be the v4.1 flash" / "not the v4 flash nor v4 pro" / "it needs to be the third fallback; after opencode -> commandcode -> amr -> devin" / "i might need to login to it again to refresh the devin auth"): `m_flash` = opencode-go/deepseek-v4.1-flash:high, then commandcode/deepseek/deepseek-v4.1-flash, amr/deepseek-v4.1-flash, devin/deepseek-v4-1-flash (all :high); model-keyed chains mirror that order; devin/swe-2 removed from the m_flash cascade; only v4.1-flash ids enabled (no v4-flash/v4-pro, no opencode-zen). Smoke RouteSmokeCritic4 after the devin re-auth: opencode-go 402 -> devin/deepseek-v4-1-flash answered ROUTE_OK. Drain lifted; campaign resumes.

Amendment 7 (operator, 2026-11-04, verbatim: "assign some lanes to m_swe (devin/swe-2-flash) on max effort" / "this is a coding model, so use it as executor and reviewer"): `m_swe` = devin/swe-2-flash:max; `executor` @m_zfl -> @m_swe and `reviewer` @m_flash -> @m_swe. Smoke RouteSmokeExecutor / RouteSmokeReviewer both answered on devin/swe-2-flash. Future launches only. Backup config.yml.pre-m_swe-exec-review-20261104.

Amendment 8 (operator, 2026-11-04, verbatim: "assign the roles from m_swe to m_flash" / "ok, do that"): executor and reviewer back to @m_flash. Measured provider state (seat sessions + direct probes): opencode-go 402 insufficient funds / Go usage limit, amr 402 quota (resets 2026-11-06T22:28Z), commandcode intermittent 401; devin/deepseek-v4-1-flash answers after the operator's re-login. Five L1s (revenger r89, tsukuroi r81, mori r89, kotoba r85, kotodama r88) exhausted three attempts on the opencode-go 402 with no fallback walk. Operator-approved temporary order: `m_flash` = devin/deepseek-v4-1-flash:high, then opencode-go, commandcode, amr (all v4.1-flash :high), mirrored in the model-keyed chains; restore opencode-go first once it is funded. The five lanes' failure markers are provider failures, not quality verdicts: moved aside to `.<lane>.run15-20261104-provider-failure`, same round reruns (claims and freeze commits kept).

Amendment 9 (operator, 2026-11-04, verbatim: "change all currently assigned roles to m_mim for anthropic/opus-5.5-medium"): `m_mim` = anthropic/claude-opus-5-5:medium; all 18 `task.agentModelOverrides` roles -> @m_mim (no role on m_flash/m_zfl/m_antigravity). Smoke RouteSmokeOpusTask/Executor/Scout all answered on anthropic/claude-opus-5-5. Seats spawned before the change keep their captured routes (several died on commandcode 401 after devin/opencode-go); provider-failure attempt markers are cleared to rerun the same round. Backup config.yml.pre-all-m_mim-opus-20261104.

Amendment 10 (operator, 2026-11-04, verbatim: "swap all m_mim for m_flash (high effort) also, make command code primary provider, then amr, then devin for the deepseek v4.1 flash" / "also assign reviewer to m_zfl"): all roles @m_flash except reviewer @m_zfl; `m_flash` = commandcode/deepseek/deepseek-v4.1-flash:high -> amr/deepseek-v4.1-flash:high -> devin/deepseek-v4-1-flash:high (model-keyed chains mirror it; opencode-go off the m_flash cascade). Smoke: task/scribe walked commandcode 400 credits / 401 -> amr 402 -> devin answered; reviewer answered on zai/glm-5.3-flashx. Backup config.yml.pre-flash-cc-primary-20261104.

Amendment 11 (operator, 2026-11-04): "Devin first for now" — commandcode returned 401 invalid auth / 400 no credits and ~12 seats died on the 401 without walking the chain; `m_flash` = devin/deepseek-v4-1-flash:high -> commandcode -> amr (model-keyed chains unchanged). "Resume all eight once" — the current three-rejection pauses of kagi r36, kama r86, kengaku r86, mado r86, souji r60, tabi r64, tameshi r86, tsukuroi r82 are lifted once (markers moved to `.<lane>.run15-20261104-freshstart-3`); history preserved, fresh-start rule applies (read the last three rejected closures; new claims must beat the do-nothing control), future gate applications unchanged. Orchestrator fix: fill_slots no longer launches a lane whose L1 or closure is still running (mori r89 ran two L1s, MoriR89 and MoriR89-2; all work landed, disclosed in its report).

Amendment 12 (operator, 2026-11-04, verbatim: "also, remove opus from the m_mim alias"): `m_mim` restored to minimax-code/MiniMax-M3.1-Flash:high (its pre-amendment-9 value); no role routes to @m_mim now, so live routing is unchanged (all @m_flash devin-first, reviewer @m_zfl).

Amendment 13 (operator, 2026-11-04, verbatim: "assign executor to m_zfl"): `executor` @m_flash -> @m_zfl (zai/glm-5.3-flashx). Measured cause of the continuing seat deaths after amendment 11: devin/deepseek-v4-1-flash returns `resource_exhausted: Reached request rate limit` at ~40 concurrent seats, the fallback walks to commandcode (400 no credits / 401 invalid auth) and amr (402), all dead, so the seat ends (MoriR90, CloseKasegiR69, CloseRevengerR91-2, KotodamaR90a2, ScribeEntry-10, 20:17-20:19).

Amendment 14 (operator, 2026-11-04, verbatim: "use m_antigravity as connector"): `connector` @m_flash -> @m_antigravity (google-antigravity/gemini-3.8-flash:high). Live map: task/main/planner/security-reviewer/critic/revenger/scout/labrat/mutation-tester/simplifier/sentinel/scribe/sonic/distiller/seance @m_flash (devin-first), reviewer + executor @m_zfl, connector @m_antigravity.

Provider-failure unblock (2026-11-04, same basis as amendment 8): kotodama r90 and mori r90 exhausted three attempts on devin rate-limit -> commandcode 401; markers moved to `.<lane>.run15-20261104-provider-failure-2`, same round reruns.

Amendment 15 (operator, 2026-11-04, verbatim: "assign two roles from m_flash to m_mim"): orchestrator chose `scout` and `scribe` (@m_flash -> @m_mim, minimax-code/MiniMax-M3.1-Flash:high), the two read/draft roles m_mim carried earlier in run 15; also relieves the devin rate limit. Live map: m_flash (devin-first) task/main/planner/security-reviewer/critic/revenger/labrat/mutation-tester/simplifier/sentinel/sonic/distiller/seance; m_zfl reviewer/executor; m_mim scout/scribe; m_antigravity connector.

Provider-failure unblock (2026-11-04, amendment-8 basis): kotoba r87 (a2/a3 died on commandcode 401; attempt-1 KotobaR87 survived and landed report d752fdbe, verified + closed as attempt 1) and tsukuroi r82 (all three L1s died on 401 at wake). Markers -> `.<lane>.run15-20261104-provider-failure-3`. Ruling to tsukuroi r82 seat SentinelGate: frozen mutants-r82.json not amended; C2 recorded unmet with ceiling arithmetic, recipes routed to r83.

Amendment 16 (operator, 2026-11-04, verbatim: "put devin/swe-2-flash as the ultimate fallback for m_mim"): m_mim chain is now haiku-5-5 -> zai/glm-5.3-flash -> devin/swe-2-flash:high (last; the trailing codex sol/luna entries were removed). A model-keyed chain `minimax-code/MiniMax-M3.1-Flash` with the same order was added, because model keys win over alias/role keys.

Amendment 17 (operator, 2026-11-04, verbatim: "assign connector to devin/swe-2-flash"): connector @m_antigravity -> devin/swe-2-flash:high. Same window: devin began returning `failed_precondition: Your weekly usage quota has been exhausted` on every L1, closure and seat. With commandcode 401, amr 402 and opencode-go 402 already dead, the whole m_flash chain is down. All 17 pool lanes hit 3 failed attempts and are BLOCKED. The driver was drained (`.scratch/run15-drain`) so no more attempts are burned; provider-failure blocks are left in place until routing is fixed.

Amendment 18 (operator, 2026-11-04, verbatim: "you need to make m_flash back to the amr -> opencode-go -> command code provider, with devin/swe-2-flash as the fallback"): m_flash = amr/deepseek-v4.1-flash:high. Model-keyed chains: amr -> opencode-go -> commandcode -> devin/swe-2-flash; opencode-go -> commandcode -> swe-2-flash; commandcode -> swe-2-flash; stale devin/deepseek-v4-1-flash -> amr -> opencode-go -> commandcode -> swe-2-flash. Alias chain matches.

Amendment 19 (operator, 2026-11-04, verbatim: "remove alibaba token plan"): the three alibaba-token-plan models (deepseek-v4.1-flash, qwen3.8-flash, qwen3.8-max) were removed from enabledModels. No chain referenced them.

Amendment 20 (operator, 2026-11-04, verbatim: "also, on the m_flash, you should tell it to use amr as primary, retrying 10 times"): amr/deepseek-v4.1-flash is already the m_flash primary (Amendment 18). `retry.maxRetries` went from 5 to 10. It is global; omp has no per-model retry count.

Amendment 21 (operator, 2026-11-04, verbatim: "you are not trying the other keys i have"). Stored credentials in agent.db: amr 5 keys (0 blocked); commandcode 7 (0 blocked); opencode-go 13 (10 blocked until Nov 8-25; ids 20/21/22 unblocked); devin 4 OAuth accounts; minimax-code 2; zai 1. Cause, per omp://non-compaction-retry-policy.md: omp rotates sibling credentials only for errors it classifies as usage limits (step 5). A hard auth error (commandcode `401 Invalid Authorization`) skips rotation and walks the model chain at once. Devin's `failed_precondition ... weekly usage quota` was most likely not classified as a usage limit either [INFERENCE]. With maxRetries 5, at most 5 attempts per request were made in total, credential switches included. The new budget of 10 covers all 5 amr keys. Rotating past a 401'd commandcode key needs the dead key removed or re-entered; omp has no setting for it.

Amendment 22 (operator, 2026-11-04, verbatim: "put command code prior to opencode-go"): the m_flash chain is now amr -> commandcode -> opencode-go -> devin/swe-2-flash. Changed: model-keyed chains (amr -> cc -> ogo -> swe; cc -> ogo -> swe; ogo -> swe; stale devin deepseek -> amr -> cc -> ogo -> swe) and the m_flash alias chain.

Amendment 23 (operator, 2026-11-04, verbatim: "assign the scribe to anthropic/haiku-5.5 on high effort"): scribe @m_mim -> anthropic/claude-haiku-5-5:high. scout stays on @m_mim.

Amendment 24 (operator, 2026-11-04, verbatim: "distiller can also be anthropic/claude-haiku-5-5:high"): distiller @m_flash -> anthropic/claude-haiku-5-5:high.

Amendment 25 (operator, 2026-11-05, verbatim: "use devin/swe-2-flash as executor"): executor @m_zfl -> devin/swe-2-flash:high (backup config.yml.pre-executor-swe2-20261105). RouteSmokeExecutor was served by devin/swe-2-flash directly with no error. The earlier connector smoke, minutes before, got `permission_denied: model no longer available` on the same model and fell to openai-codex/gpt-6.1-sol, so availability is account/credential-dependent. Seats spawned earlier keep their captured routes.

Provider-block clearing (orchestrator, 2026-11-05T02:20-03:00): chousa r80, kaidoku r91, kake r93, kotoba r88 and kotodama r91 were blocked after 3 L1 deaths, all provider errors (amr 402 insufficient_balance, commandcode 401, opencode-go 402). The markers moved to `blocked/.<lane>.run15-20261105-provider-failure-N`. The rounds are unchanged. Only the devin/swe-2-flash tail of the m_flash chain is serving, intermittently. kaidoku r91 has landed claims at deb2765a/f7f5153b and an undispatched r91-w1.ready, so its relaunch must resume and not restart.

Amendment 26 (operator, 2026-11-05, answering "How should I route m_flash ... and the executor/connector roles?", verbatim choice: "zai glm-5.3-flash primary"): m_flash amr/deepseek-v4.1-flash:high -> zai/glm-5.3-flash:max. executor and connector devin/swe-2-flash:high -> "@m_flash". The m_flash alias chain and a new model-keyed chain zai/glm-5.3-flash both fall back to anthropic/claude-haiku-5-5:high. Backup: config.yml.pre-zai-primary-20261105. Cause: amr 402 (insufficient_balance), commandcode 401, opencode-go 402, and devin/swe-2-flash `permission_denied: model no longer available` all failed at the same time.

Amendment 27 (operator, 2026-11-05, answering "Do you authorize fresh starts?" for the ten quality-paused lanes, verbatim choice: "Authorize all"): the markers for chousa, kagi, kaidoku, kake, kama, kasegi, kotoba, kotodama, kumitate, mado, revenger, souji, tabi, tameshi and tsukuroi moved to `blocked/.<lane>.run15-20261105-N`. That covers the ten quality pauses plus five lanes re-blocked on provider failures. Each lane resumes at its next round.

Host incident (orchestrator, 2026-11-05): `user.max_user_namespaces` was set to 0 via sudo by wave seats. The journal shows `echo 0` at 05:14:52, transient 10000/15638 sets, and `echo 0` again at 05:22:02; the last one was ReviewerR89a "resetting" to the value it had read. With the sysctl at 0, every bwrap sandbox failed with ENOSPC; kengaku r89 C1 L6 controls and the sentinel re-runs were affected. The orchestrator restored the kernel default, 122865 (threads-max/2); nothing persistent in sysctl.d sets it. Seats must not mutate host sysctls. Name the need in the report instead.

Amendment 28 (operator, 2026-11-05, verbatim: "try using m_agy as the scout until its usage gets limited"): scout @m_mim -> "@m_agy" (google-antigravity/claude-opus-5-5:high). Added model-keyed fallback chain `google-antigravity/claude-opus-5-5` and updated `m_agy` fallback chain to `minimax-code/MiniMax-M3.1-Flash:high` -> `zai/glm-5.3-flash:max` so when `m_agy` hits its usage limit it falls back to MiniMax and zai automatically. Backup: config.yml.pre-scout-m_agy-20261105.

Amendment 29 (operator, 2026-11-05, verbatim: "use m_mim as the scribe"): scribe anthropic/claude-haiku-5-5:high -> "@m_mim" (minimax-code/MiniMax-M3.1-Flash:high; existing model-keyed chain haiku -> zai/glm-5.3-flash -> devin/swe-2-flash). Backup: config.yml.pre-scribe-m_mim-20261105. Separately, the operator chose to leave m_zfl and m_flash routing unchanged.

Amendment 30 (operator, 2026-11-05, verbatim: "use the glm 5.3 flash on m_flash on high effort, not max effort please"): m_flash zai/glm-5.3-flash:max -> zai/glm-5.3-flash:high; the five fallback-chain entries that named zai/glm-5.3-flash:max (google-antigravity/claude-opus-5-5, minimax-code/MiniMax-M3.1-Flash, m_agy, m_swe, m_mim chains) -> :high. Seats already spawned keep their captured route. Backup: config.yml.pre-m_flash-high-20261105.

Amendment 31 (operator, 2026-11-05, verbatim: "hey use m_antigravity as the connector"): connector "@m_flash" -> "@m_antigravity" (google-antigravity/gemini-3.8-flash:high; existing m_antigravity chain cursor/gemini-3.8-flash -> devin/swe-2-flash -> openai-codex/gpt-6.1-sol). Smoke seat ConnectorAgSmoke served by google-antigravity/gemini-3.8-flash, thinkingLevel high. Seats already spawned keep their captured route. Backup: config.yml.pre-connector-m_antigravity-20261105.

Amendment 32 (operator, 2026-11-05, verbatim: "assign the executor to m_cru"): executor "@m_flash" -> "@m_cru" (commandcode/stealth/crouton-alpha; m_cru has no fallback chain configured). Smoke seat ExecCruSmoke served by commandcode/stealth/crouton-alpha with 0 errors. Seats already spawned keep their captured route. Backup: config.yml.pre-executor-m_cru-20261105.
