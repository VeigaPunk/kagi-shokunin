# Round 31 — claims plan (FROZEN; QM29)

Frozen BASE: `655e620651808ac04bb59bfa35b81227f62a031b` (branch `master`, local=remote at
round start via `jj-lane.sh state`; carries the round-29/30 verifier spot-check lessons).
This plan and the START census receipt (`.ufo/waves/round-31/census-start.txt`) plus the
BASE control receipts (`.ufo/waves/round-31/controls/`) commit ALONE, before any work
commit. Corrections, if any, are appended before the first work commit; after that the
lesson carries them.

Host declaration: Arch Linux (the omp host); `python3` 3.14.8; `op` 2.41.1 at `/usr/bin/op`
(observed read-only via `op --version` only — no sign-in, no vault/account contact, nothing
installed or provisioned); the-janitor substrate ABSENT (`controls/host.txt`), so live
gates' fail-closed outputs stay correct outputs. Scratch root for every clone/fixture:
`/fast/scratch/hyaku/kagi-r31/<seat-name>/` (scratch discipline §7; `/tmp` only for files
< 50 MB).

START census (round start, exit 0 required at round end): fleet
`sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ **exit 0**
(14 `W04 duplicate-url` warnings, allowed; receipt `census-start.txt`). Lane
`bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1
mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 …)` exit 0
(`controls/c2-base.txt`).

Round context: the round-30 verifier spot-check routed four items to this round —
D1 uncommitted round-30 wave evidence (11 paths, cited as report pointers but not
durable), D2 a report receipt pointer whose file holds the before-state
(`final/receipts/selfcounts-at-tip.txt` holds `stale=8`), D3 the carried operator items
(`feed-token-agree` registration in `PYTHON_SCRIPT_RE`, L0 `kagi | round-30`; fleet parser
`sources-census.sh:581` CR trim, L0 `kagi | round-30`), D4 a promotion note (operator-owned).
The round-28 documentary HOLD is lifted by the run-15 directive (no holds); the 2026-10-21
content-safety refusal boundary stays binding and is honored by construction: **no claim
touches feed-token derivation, token totality, or the release-clock tokenizers, and no
refused work is retried, rephrased or rerouted.** Routed-around operator items: R25-02
(FAIL), R29-01, R29-02 (POLICY) stay red and named; no gate is relaxed to force them green.

All six axes stand at 9; the last capability entered round 29, inside the stagnation
window (3), so the nudge does NOT fire: the lowest-axis obligation applies. All six axes
are tied at 9, so any distinct axis satisfies it (round-30 close used the same reading).
Claims: **C1 calibration, C2 coverage** — two distinct axes, causally separable (C1
touches only `SCORECARD.md` headings, the claim-ledger pins/stamps and its own gate;
C2 appends registry rows, capture rows and two knowledge entries; either verifies without
the other).

## Claims

### C1 — calibration (owned axis; 9 → 9): the scorecard cell audit is setup-clean again

The lane's self-assessment audit (`claim-ledger.sh cells`) has been unable to run since
round 26: five round sections carry headings outside the parser's
`## Round <N> — pre-move|post-move` shape, so the audit dies with a setup error before
auditing anything. This is the `RevScorecardShape` debt the round-28 verifier routed and
rounds 28–30 each declined to claim. At BASE (`655e620`):
`bash corpus/claim-ledger.sh cells` ⇒ `claim-ledger: unrecognised round heading in
…/SCORECARD.md: '## Round 26 — bounded release-drift response' (expected '## Round <N> —
pre-move|post-move')`, **exit 2, no CELL_AUDIT summary line**
(`controls/cells-base.txt` — the do-nothing control: a round that skips this work cannot
reach the after-state).

- **Scope (content-preserving heading reshape, five headings, old→new recorded in
  `corpus/lessons/round-31.md` §Migrations per QM14):**
  1. `## Round 26 — bounded release-drift response` → `## Round 26 — post-move (bounded
     release-drift response)`
  2. `## Round 27 — knowledge numbers bound; release clocks refuse silent regression` →
     `## Round 27 — post-move (knowledge numbers bound; release clocks refuse silent
     regression)`
  3. `## Round 28 — post-move: canonical version tokens; derived anchors bound to feed
     rows` → `## Round 28 — post-move (canonical version tokens; derived anchors bound to
     feed rows)`
  4. `## Round 29 — post-move: feed-token right boundary; differential agreement gate
     (new host)` → `## Round 29 — post-move (feed-token right boundary; differential
     agreement gate on the new host)`
  5. `## Round 30 — post-move: routed-defect closure (D1–D5), EOL repair, secret-scanning
     adoption` → `## Round 30 — post-move (routed-defect closure D1–D5, EOL repair,
     secret-scanning adoption)`
  No table cell, score or evidence line inside those sections changes. Because the reshape
  changes `SCORECARD.md` bytes and five `## Round` heading lines, the same landing re-pins
  the SCORECARD revision stamp (QM5/QM14, old→new in the record) and re-migrates the three
  heading/revision identity rows to the measured round-31-tip values: R24-06
  (`row-identity.sh scorecard-rounds`, count 36→current, digest old→new), R24-15 and
  R22-03 (`revision-audit.py --history c2cab35…`, added 36→current). These rows re-run
  green in the lane at BASE (`added=36` CLEAN; `scorecard-rounds count=36` exact line) and
  move only because the round legitimately adds files/sections; the migration reason chain
  is in each row note.
- **Predicate (frozen, one sentence):** at the round-31 measured revision, run in the lane
  repo, `bash corpus/claim-ledger.sh cells` prints no `unrecognised round heading` setup
  error, completes to a `CELL_AUDIT:` summary line over the full round population
  (cells ≥ 210, the 30-round population at BASE), and every `FAIL`/`POLICY` row line it
  prints is exactly one of the three operator-routed ids — R25-02 (FAIL), R29-01 (POLICY),
  R29-02 (POLICY) — with zero `STALE-POINTER` lines.
- **Counting command (frozen):**
  `bash corpus/claim-ledger.sh cells` executed in
  `/home/vgpnk/Projects/shokunin/kagi-shokunin`; the receipt (`final/receipts/cells-at-tip.txt`)
  is graded by: `grep -c 'unrecognised round heading' receipt` = 0; `grep -c '^CELL_AUDIT:'`
  = 1; `grep -E '^(FAIL|POLICY) ' receipt | awk '{print $2}' | sort -u` = `R25-02 R29-01
  R29-02`; `grep -c '^STALE-POINTER' receipt` = 0. Before-receipt at BASE is the committed
  control.
- **Kill rule:** if the completed audit exposes any lane-owned red beyond the three routed
  ids (a FAIL row, a STALE-POINTER, or an uncited/missing-id class), that finding is either
  repaired in-round with a QM14 record (if it is a bookkeeping drift the round itself caused)
  or the claim honest-stops with the finding named. No gate semantics change; expectation
  values migrate only with old→new records. If the round-31 sections themselves cannot be
  made audit-clean, the claim stops.

### C2 — coverage (9 → 9): the OIDC workload-federation theme moves from frontier lead to admitted knowledge

The lane's frontier has held "OIDC workload-federation trust policy — issuer, audience,
identity-claim binding, and resulting permissions" as an unopened lead since round 21
(`corpus/README.md` §Frontier; `SOURCES.md` §Leads (unopened)). The assimilation package
`/home/vgpnk/Projects/shokuknow/merge/kagi/` (§10; read-only source) stages the theme as
two entries + their sources. Round 30 took the secret-scanning theme; this round takes the
OIDC theme. No sibling claims workload-identity ground (round-21 and round-30 connector
sweeps; re-swept this round).

- **Scope:** adopt exactly two staged entries —
  `corpus/knowledge/oidc-federation-trust-policy.md` (staged sources: AWS
  create-oidc IAM guide, AWS IAM condition-key reference, AWS STS
  AssumeRoleWithWebIdentity API, GCP workload-identity best practices, GCP
  workload-identity-federation ja, Alibaba RAM trusted-IdP guide, OpenID Connect Core 1.0
  §3.1.3.6, RFC 9700 §4.10.2) and
  `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` (staged sources:
  1password.dev brokered-access, 1password.dev brokered-access/custom-workflow,
  1password.com/jp credential-broker product page) — and register exactly the distinct
  sources the adopted entries cite: **11 staged rows renumbered into the lane's S-space
  (next free id S061; staged ids S052–S057/S064–S065/S092–S093/S095 collide with lane
  ids and are re-pointed per document — the URL/anchor is the evidence, the id follows
  it, never arithmetic), 11 capture rows appended to `corpus/source-fetches.tsv`
  (16-column schema, `curl-fsSL-compressed-v1` profile), and the collision-check artifacts
  (`reg-ids`, `staged-ids`, `collisions`, renumber map) committed under the wave dir.**
  Every staged source is re-opened in-round by this lane (fetch profile
  `curl -fsSL --max-time 30`, capture receipts in the wave dir, `verified-at: 2026-11-03`
  naming them); each entry carries ONE column-1 `source:` line, `verified-at:`,
  `recheck:` (campaign prose cells stripped to the round lesson's Gate block per §10),
  `ground:` and a `Reverify:` ledger row link; `used-by` of every adopted row lists exactly
  the entries citing it. Staged text is never appended as-is: QA1–QA10 and the census are
  the bar, and per-entry gates (≥1 admit, ≥1 reject-or-flip across the set) land in the
  round lesson's `## Gate`.
- **Predicate (frozen, one sentence):** at the round-31 measured revision,
  `bash corpus/sources-census.sh` in the lane repo prints
  `SOURCES_CENSUS: CLEAN (… rows=71 … entries_sourced=10 legacy=21 captures=71 …)` exit 0
  — rows 60→71 (the 11 adopted OIDC rows), entries_sourced 8→10 (the two adopted
  entries), legacy unchanged at 21 (the deliberately-unclaimed gap, named in
  `corpus/README.md` §Known gaps), captures 60→71 — and both new entry files exist at
  `corpus/knowledge/` citing only adopted `mined` tier-A rows whose `opened` is
  `2026-11-03`.
- **Counting command (frozen):** `bash corpus/sources-census.sh` executed in
  `/home/vgpnk/Projects/shokunin/kagi-shokunin` (receipt
  `final/receipts/census-c2-at-tip.txt`), plus
  `grep -cE '^\|[[:space:]]*S(06[1-9]|07[01])[[:space:]]*\|' corpus/SOURCES.md` = 11.
  Before-receipt at BASE is the committed control (`controls/c2-base.txt`: rows=60,
  entries_sourced=8 — a do-nothing round cannot reach the after-state).
- **Kill rule:** if any staged source cannot be re-opened in-round (fetch failure or the
  located quote absent), that row is refused (reason in the Gate block) and the predicate's
  counts move to the refused shape (rows/entries_sourced/captures reduced accordingly,
  re-frozen by a plan correction BEFORE the first work commit if the shape changes); if a
  per-entry gate rejects an entry outright, C2 honest-stops for that entry and the round
  reports it. A nonempty `collisions` file is fixed in scratch only (renumber map), never
  by overwriting a live lane id. Drift a read-only check cannot fix → L0 question, adopt
  nothing from that source.

## Frontier step (not a claim)

- Census before→after recorded (both outputs + exit codes pasted in the report; exit 0
  required at round end).
- ≥1 mistake mined into `corpus/lessons/round-31.md` `## Mistakes`
  (class · evidence · captured-by · fix shown able to fail); if none, the sweep that found
  none is pasted.
- The sourced-claim duty is carried by C2 (every adopted row is opened in-round).
- `considerthese/` mining: at most one still-unimplemented proposal from the latest file
  (`considerthese/2026-10-26.md`), grounded through the lane's bar; lands as a lesson
  snippet or QUALITY.md criterion citing `considerthese/<file>` + date. The candidate is
  proposal 2 ("machine-readable lane status"): verified still-unimplemented before landing.
- D1/D2 hygiene (routed by the round-30 verifier, not a claim): the 11 inherited
  `.ufo/waves/round-30/` paths are committed under this round's entry; a correctly-produced
  self-counts receipt at the round-31 tip is committed and the round-30 pointer defect is
  superseded by name in this round's report (filed bytes are never rewritten).
- QM32 candidate from M30-4 (every red row of a touched gate claimed or routed before the
  plan freezes) lands as a QUALITY.md criterion with a fix shown able to fail (the round-30
  plan as committed is the red witness).

## Round shape (declared)

ONE v1 wave `kagi-r31-build` under `ufo-wave-policy.json` (band 8–16): **15 seats** —
1 scout, 1 labrat, 3 executors, 4 scribes, 1 connector, 1 critic, 3 reviewers,
1 mutation-tester. Attack share = critic + 3 reviewers + mutation-tester + labrat =
6/15 = 40 % (≥25 %). Connectors = 1 (≤2). Roles route through
`task.agentModelOverrides` (run-15 map: executor/labrat/scout/mutation-tester `@m_flash`,
scribe/connector `@m_mim`, critic/reviewer `@m_zfl`); no `model` is ever passed. The
canonical planner seat is held by the L1 (validator refuses `planner`); the bounded
planning data-walk rode the L1's BASE probes and the `CensusBase`/`CellsRed` seats.
Residual checks after the wave, if any, go into ONE ordinary task call of ≤4 seats.
Every seat: absolute paths under `/home/vgpnk/Projects/shokunin/kagi-shokunin`, writes
ONLY under `.ufo/waves/round-31/<seat-name>/` plus its scratch dir, never commits, never
mutates git/jj state, never edits fleet/sibling files, no `agent://all`.
