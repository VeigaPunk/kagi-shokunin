# CritPromotion — SHONEN / non-author / discernment boundary (round 26, C1 freshness)

Seat: `KagiR26.CritPromotion` (critic, leaf, lane-dispatched). This is lane-authored advice, not
non-author closure. A subagent the lane dispatched is still the lane (PROTOCOL.md:64, LEARNING.md:45).

## Observed state

- Lane BASE: `git -C kagi-shokunin rev-parse HEAD` printed `1bf3eec48d3761580ffd375c88143232485ae814`, which equals the frozen BASE.
- Fleet HEAD: `fbceeceb30b9a0f9888c2187c3888da9633b0a2d`. The round-25 closure was committed at
  `ff47be96994cfb99d7f6305c009c0c867eae64d8` by protocol-shokunin at 2026-10-21T10:33:09-03:00, with the subject "rounds ledger: kagi r25 closure (admitted) — hyaku, non-author".
- Inspected bytes, from `sha256sum`:
  - `plans/round-26.md`: `bb763f89…154c`. It is **untracked** (`git status --porcelain` printed `?? plans/round-26.md`), so it was not committed at BASE.
  - `corpus/lessons/round-25.md`: `ee9eac48…4d76`. It is unchanged from BASE (`git diff --stat 1bf3eec` printed nothing).
  - `SHONEN.md`: `1bb89fc5…4277`. Its last change was `c41af82` (round 21). All four boxes are `[~]`.

## Inspected scope

- `plans/round-26.md`, all 15 lines, and `corpus/lessons/round-25.md`, all 278 lines.
- `SHONEN.md`.
- `PROTOCOL.md:55-78` and `:425-451`.
- `LEARNING.md:40-48`.
- `scripts/hyaku/closure-prompt.md`.
- `templates/round-prompt.md:110-120`.
- `.ufo/prompts/kagi-round-26.md:20-69` and `:370-389`.
- `.ufo/reports/round-25/kagi.md:80-105`.
- In `MANIFEST.json`, the `.rounds[]` rows with lane kagi and lane_round 21 through 25.
- In `.ufo/waves/round-26/`, `build-assignments.json` and `build-spec.json`, grepped for SHONEN, spot-check, discernment, `[x]` and non-author.

Nothing was executed beyond read-only `git`, `jq`, `rg`, `sha256sum` and `ls`. No gate, selftest or census was run, and none is called passing here.

## Bounded result

There is no overclaim in the two target files on the SHONEN or non-author boundary. Specifically:

- **No promotion claimed.** `plans/round-26.md:13` says "No new repertoire, coverage surface, retirement or promotion is claimed".
- **No child supplies discernment.** `plans/round-26.md:15` says "Non-author closure remains outside this lane and no child supplies promotion or outside discernment".
- **Seats are not called non-author.** `corpus/lessons/round-25.md:247-248` says "the lane's own dispatched seats cannot supply it. SHONEN stays [~]", and `:276-278` says "no dispatched child is called non-author. All four SHONEN boxes intentionally remain [~]".
- **SHONEN.md is consistent with this.** It has four `[~]` and no `[x]`. The closure row records `"promotions": []`, and its conformance check counted "4 author-assertion SHONEN lines".
- **The round-25 report does not self-grade discernment.** `.ufo/reports/round-25/kagi.md:86` reads "discernment — unchanged pending outside review".
- **No round-26 seat holds SHONEN or discernment duty.** The only matches in `build-spec.json` are this seat's own assignment text and the shared phrase "lane-authored advice, not non-author closure".

## Attack: an unanchored outside record invites laundering a non-author ID into SHONEN or discernment

**Counterexample.** Round 25's only outside discernment record lives outside the lane, as prose in `MANIFEST.json`. The specific location is `.rounds[]` where `lane=="kagi"` and `lane_round==25`, in the fields `verification.spotcheck` and `notes`, at fleet commit `ff47be9`.

The closure row says so itself: `"scope": "… Independent verification and routed residuals retained in this closure row; no verifier lesson written into lane."` There is no `corpus/lessons/round-25-verifier-spotcheck.md`, and the round-24 spot-check file is missing the same way. In the lessons directory listing, the newest spot-check file is `round-23-verifier-spotcheck.md`.

The round-26 prompt's hook depends on that file existing. At `.ufo/prompts/kagi-round-26.md:376-378` it says: "Read `corpus/lessons/round-25-verifier-spotcheck.md` if it exists: it is the outside discernment check of your previous round — turn every disagreement or routed defect into a lesson-backed `QUALITY.md` criterion or fix". Because the file is absent, the hook silently does nothing.

Neither target file anchors the outside record. Running `rg -n 'verifier-spotcheck|ff47be9|CloseKagi25'` over both files returned exit 1, meaning no match. This has three effects:

1. **Two unsourced statements.** `plans/round-26.md:9` asserts "round25 admitted", and `:11` asserts "routed Python3.15.1 feed drift". Both are true, because the closure notes contain "Routed D1: independent refetch https://www.python.org/downloads/feed.rss now has Python3.15.1 pubDate Wed21Oct2026 09:59:50+0000 … next round append a dated correction/superseding source row and refetch/reobserve S027/S028 with a new receipt". But neither statement has a resolvable pointer in the lane, so on the freshness axis the claim's own trigger is unsourced.
2. **A stale "pending" with no successor.** `corpus/lessons/round-25.md:247` ("remains pending the parent's closure") and `:277` ("pending parent closure") were overtaken by `ff47be9` at 13:32:29Z. These lines are historical and MUST NOT be rewritten. However, nothing in round 26 appends the dated supersession.
3. **Laundering path (calibration).** A non-author verifier ID, `CloseKagi25.FreshnessReview`, is now available. PROTOCOL.md:432 checks SHONEN marks only for form: "`[x] <verifier-id>` or `[~]` with a resolvable pointer". Suppose a round-26 author writes `[x] CloseKagi25.FreshnessReview` on box 1, or grades round-26 `discernment: improved` because the closure "agreed". That line would be well-formed, yet false:
   - The reviewer adjudicated round-25 source-gate admits and rejects: S033, S034, S035 and S037 agree-admit, and S038 agree-reject. It assessed no SHONEN box.
   - Closure seats are forbidden to write `[x]` (`closure-prompt.md:88-90`: "never write `[x]` into SHONEN.md, never promote … promotion is operator-owned").
   - Round 26's own gate has had no outside check yet.

   No mechanical gate distinguishes "the verifier judged this box" from "the verifier exists". [INFERENCE] I did not check whether `scripts/sources-census.sh` or the closure step-1 conformance check inspects verifier semantics. I read only the format rule.

**Impacted axes.**

- **Freshness (C1):** the routing trigger and the "admitted" status are unsourced inside the lane.
- **Calibration:** a stale "pending" with no dated successor, plus an open path to a format-valid but semantically false `[x]` or discernment upgrade.

There is no harm to depth, coverage or adjacency.

**Classification.** The citation gap is a fixable lane defect. The missing verifier lesson for rounds 24 and 25, and the prompt hook that keys only on a lesson file, are fleet or closure-side defects that the lane cannot fix. The lane MUST NOT author a `round-25-verifier-spotcheck.md` itself (prompt `:374`). This should be routed to L0 or the protocol lane, not repaired in-lane.

## Smallest safe correction (for L1 to integrate; production untouched by this seat)

In the round-26 lesson, or as an append-only plan correction, add one dated line along these lines:

> 2026-10-21: round-25 outside closure landed in fleet `MANIFEST.json@ff47be96994cfb99d7f6305c009c0c867eae64d8`, `.rounds[lane=kagi,lane_round=25]` (`verdict: admitted`, `promotions: []`; reviewer `CloseKagi25`; spot-check `CloseKagi25.FreshnessReview`: agree admit S033/S034/S035/S037, agree reject S038). It supersedes, without rewriting, the "pending parent closure" lines at `corpus/lessons/round-25.md:247,277`. C1's trigger is that row's routed D1. That review judged round-25 gate decisions only, verified no `SHONEN.md` box, and is not round-26 discernment. All four boxes stay `[~]`, and the round-26 discernment trend stays "unchanged pending outside review".

There are three further adjustments:

- **Say "author-side" instead of "independent".** In `plans/round-26.md:13`, "independent source/parser/receipt/gate attacks" should read "lane-dispatched (author-side) … attacks". This matches the lesson's own wording at `:220` ("not an independent pass") and avoids "independent" being read as "non-author".
- **Mark the fleet citation as expected-absent.** In a lone clone the fleet citation is expected to be `FLEET-ABSENT`, and the honest INCOMPLETE/48 count would shift. Quote the commit hash and JSON path as plain text, or note the expected one-token delta. Do not add a resolvable-looking path that turns INCOMPLETE/48 into 49 unannounced. [INFERENCE] I did not inspect the tokenizer's treatment of `MANIFEST.json@<hash>`.
- **Route the hook defect out of the lane.** Route to L0 or the protocol lane: the closure records for rounds 24 and 25 wrote no lane verifier lesson, so the prompt's `round-N-verifier-spotcheck.md` hook is a no-op. The hook should also key on the `MANIFEST` closure row.

## Rejected overclaim

None observed in the target files. Shown above as able to fail if a round-26 artifact adds any of the following:

- any `SHONEN.md` `[x]`;
- a `discernment: improved` justified by CloseKagi25 or by lane seats;
- a lane-authored `round-25-verifier-spotcheck.md`.

## Installs

None.
