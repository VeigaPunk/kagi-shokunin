Author: R72Critic (critic)

# R72 critic — round 72, C1/C2 wording vs frozen counters

Axes named: **freshness** (C1) and **calibration** (C2), per AXES.md. All probe
runs below executed `plans/round-72-c1.sh --tree` / `plans/round-72-c2.sh --tree`
on `b2f3dd66` (BASE) and `a947a42` (candidate) extractions in scratch
`/fast/scratch/hyaku/kagi-r72/R72Critic` (removed after); verbatim receipt lines
copied to `w1/R72Critic/probe-receipts.txt`.

## 1. C1 sentence-by-sentence enforcement (§C1 of round-72.md vs c1.sh)

Surface (24-31: "the ten derived clocks are anchored at the currently observed
releases through two new feed rows opened this round (S174 supersedes S034,
S175 supersedes S035), each re-arm backed by a round-72 page re-fetch with the
id's declared quote located, and the gate's default receipt is a live
observation of 2026-11-09"):
- "two new feed rows opened this round" — ENFORCED: SOURCED leg
  (c1.sh:172-175) requires the feed row absent from BASE registry,
  `fr[7]=="mined"`, `fr[8]>="2026-11-09"`. BASE S034/S035 carry `opened 2026-10-21`
  and are in the BASE registry, so the leg cannot pass on them.
- "(S174 supersedes S034, S175 supersedes S035)" — NOT ENFORCED. Probe B
  (strip "supersedes S034"/"supersedes S035" from S174/S175 teaches cells) →
  `value=10 rc 0`. c1.sh never reads the teaches/supersession cell; SOURCED
  checks only status/opened/URL. The supersession sentence in the plan is
  carried in SOURCES.md at the candidate but has no counter teeth.
- "each re-arm backed by a round-72 page re-fetch with the declared quote
  located" — ENFORCED: VERIFIED (c1.sh:178-199) requires exactly one
  clock-rearm.tsv row, capture under `.ufo/waves/round-72/` with matching
  sha256/bytes, `fetched_at` in `[2026-11-09T00:00Z, run time]`, and the
  BASE-pinned rendered-text locate count == `quote_count` (F4/F5 controls 9).
- "the gate's default receipt is a live observation of 2026-11-09" —
  ENFORCED: GATE (c1.sh:118-135) requires the round-72 path + sha match and
  both gates CLEAN; FRESH (c1.sh:136-143) requires every `observed_at >=
  FLOOR`. F3/F10 controls → 0.

Doctrine fit (QM23, QM24, QM28): "re-arm" is the right word under the lane's
own doctrine and the counter matches it. QM28 binds a `derived:` anchor to the
feed row's anchor cell, and QM24's "successor bound at its named current
release" reads, for a derived clock, as a successor FEED row — exactly what
SOURCED enforces via the anchor==observed==receipt-parsed conjunction
(c1.sh:164-165) plus DERIVATION in the BASE-pinned gate. QM23 "never silently
re-pinned" is satisfied at the candidate: each release-clocks.tsv note retains
the full prior fire history (`so the clock FIRED; re-observed by ...`) before
the "round 72: re-armed at ..." clause, so the re-pin is explicit, not silent.
Probe G (strip `v` from the S174 anchor cell, `v2.2.1`→`2.2.1`) → `value=10`;
that is correct per `norm_version` in the gate's `derived_anchor_bound` — the
prefix is cosmetic, not a hole.

"fire again on the next stable tag" (S174/S175 teaches cells, SOURCES.md:174-175):
NOT shown anywhere in-round. No later-release fixture exists under
`.ufo/waves/round-72/` (only captures + controls + final). QM24's last sentence
("a later-release fixture must fire the successor") is named in the plan only
as an uncounted integration duty ("wave labrat item", §C1 line 49) and the
counter contains no such test (no `2.2.2`/`2.7.3` observation in c1.sh or
controls). The candidate therefore presents as landed fact a firing behaviour
nothing in-round demonstrates.

Uncounted conjuncts U1-U4: U1 (semantic teaching) is the sharpest wording gap:
the plan's surface says the re-arm is "backed by the round-47 semantic
re-verification", and fired-reverify.tsv says `teaching-holds` for all ten at
2.2.1/2.7.2, but c1.sh never opens `corpus/fired-reverify.tsv` (no reference
in the script). Probe H (flip every `teaching-holds`→`teaching-FAILS`) →
`value=10 rc 0`. The plan discloses this as U1 ("judged by non-author
reading"), so it is an honest, declared ceiling — but the candidate's
per-row notes ("after the round-47 teaching re-verification
(corpus/fired-reverify.tsv)") read as if the counter saw it. U2-U4 are
correctly scoped (receipt shape via gates, LIVE re-reads only F, BASE-pinned
gate trusted) and c1.sh implements exactly that split.

Integration duty gap (plan §C1 line 47: "an expectation-migration journal for
every ledger row the move changes (at least R36-03, whose pinned line reads
fired=14)"): the candidate does NOT change it. `diff BASE candidate
corpus/claim-ledger.tsv` is empty (verified twice); R36-03 still pins
`fired=14` while the re-armed table fires 4 (candidate gate reads
`fired=4`: the ten F rows now `not-fired`). The candidate landed the count
without the journal the plan names as its own duty — the value=10 line is
true, the integration sentence is not yet done.

## 2. Do-nothing / cheap forgery — cheapest change reaching target?

None found without doing the work. BASE → `value=0 rc 1` (F0 do-nothing holds).
Every shortcut tried in scratch:
- supersedes stripped → 10 (not a shortcut: supersession was never a leg)
- teaches/anchor cell garbage → gate=0 → 0; feed identity swapped → census=0 → 0
- feed captures deleted → census=0 → 0 (SOURCED alone never opens S174.body,
  but CENSUS/SC_CAPTURE transitively protects it)
- anchor numeric bump with everything else BASE (F1) → 0, reproduced
- C2-only text onto BASE → C1 0 (E)
No tree reaches C1 value=10 without SOURCED+VERIFIED+LIVE+GATE+FRESH+CENSUS
all true, and none reaches C2 value=0 by shrinking stamps.tsv/claim-ledger.tsv
to the prose numbers (K: prune 181→164/102→101 → `SETUP (shape=0 ... setup=3)`
because the pinned self-counts.tsv's `expect:`/ledger bindings no longer agree;
the prune path fails closed rather than passing). G5-style policy-boundary
move and G1/G2 pin drops → SETUP, as frozen.

## 3. Separability

Holds both ways, and C1's integration does not threaten C2's final value:
Q1 (BASE + C2 only) → C2 `value=0` (controls receipt) and probe I (candidate
with SKILL/PROVINCE reverted to BASE) → C1 `value=10`. C1's counter reads
neither SKILL.md nor PROVINCE.md (grep: zero hits) and C2's counter reads
only self-counts.py/tsv + the two stamped lines, so the stamp-count binding
is the sole coupling, as the plan says. Candidate C2 measured as landed →
`value=0 pins=1 shape=1 ok=61` (probe J).

## 4. Axis honesty

Freshness for C1 is honest: the move is drift detection against the live
vendor feeds (re-anchoring ten dead clocks to the newest stable tags and
re-observing them live), which is AXES.md's freshness definition ("skill
claims re-verified against live surfaces; stale items flagged or fixed").
Calibration for C2 is honest: the four stamped numbers now match the measured
ledger, i.e. the lane's self-description equals the repo state (AXES.md
calibration).

## Candidate verdict (C1/C2 vs frozen counters)

C1 `value=10 rc 0` and C2 `value=0 rc 0` re-measured on the candidate tree.
The numbers hold; the attack surface is wording, not counting: supersession,
"fire again on the next stable tag", the U1 semantic leg, and the R36-03
journal are claimed/presented without counter teeth (B, H, + ledger diff).

FINDING CR-1 falsifies-wording SOURCED never enforces "supersedes" (probe B value=10 with supersession stripped)
FINDING CR-2 falsifies-wording "fire again on the next stable tag" has no in-round fixture (QM24 last sentence deferred to labrat)
FINDING CR-3 falsifies-wording U1 semantic leg presented as backing but counter never reads fired-reverify.tsv (probe H value=10)
FINDING CR-4 falsifies-wording R36-03 journal absent: claim-ledger.tsv unchanged, fired=14 pin vs re-armed fired=4
FINDING CR-5 neutral re-anchor + QM23 explicit-not-silent + anchor v-prefix all correctly enforced (probe G)
FINDING CR-6 neutral no cheap forgery reaches C1 10 or C2 0 (probes E, K all fail closed); separability holds (probes I, J)
FINDING CR-7 neutral freshness (C1) and calibration (C2) are the honest axes
SEAT-STATUS: complete all four probes run, both counter legs re-measured, report written
