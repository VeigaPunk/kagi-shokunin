# Round 47 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `252ef1cac9f41d84639c0d1f211d0e0911196112` (branch `master`; the
round-46 verifier spot-check landed at this tip and admitted round 46).
Counters: `plans/round-47-c1.sh`, `plans/round-47-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-47-controls.py`
(17 controls, each with an expected value written before it ran; receipt
`.ufo/waves/round-47/controls/controls-prefreeze.txt`, `CONTROLS: ALL-MATCH (match=17 mismatch=0)`).
BASE receipts: `.ufo/waves/round-47/controls/` (`c1-base.txt`, `c2-base.txt`, `census-start.txt`,
`instrument-sha256.txt`, `k2p-capture-times.tsv`). Predeclaration commit: recorded in the report.

Axes: C1 → **calibration**; C2 → **freshness** (the lane's two owned axes). All six axes sit at 9
(tied lowest), so each claim works a tied-lowest axis; the stagnation nudge is not invoked. No axis is
retired or split.

Causal separability: C1 touches `corpus/lessons/round-43.md` and `corpus/lessons/round-44.md` (an
appended `source:` line each), one new `S099` row in `corpus/source-fetches.tsv`, and the capture
`.ufo/waves/round-47/capture/S099.body`. C2 touches a new `corpus/fired-reverify.tsv` and the captures
`.ufo/waves/round-47/capture/S0{12..16,21..26}.body`. C1's counter reads none of C2's files except
through the census (which does not read `fired-reverify.tsv`); C2's counter reads `source-fetches.tsv`
only at the eleven F ids, which C1 does not touch. Controls K1-P (C1 change only) scores 3 with C2
absent; K2-P (C2 change only) scores 11 with C1 absent.

## C1 — calibration: the registry's self-description agrees with the bytes the lane-local census reads, 0 → 3

Problem (measured): `bash corpus/sources-census.sh` reads FAILED at BASE with three findings
(`controls/census-start.txt`): `SC_USEDBY_NOCITE S094 round-43.md`, `SC_USEDBY_NOCITE S099
round-44.md`, `SC_FETCH S099 missing-provenance`. The registry says round-43/44 lessons use S094/S099,
but neither lesson carries a `source:` field naming them, and S099 (opened round 44) never received a
fetch-provenance row. Carried since round 44 (round-46 closure routed item 5; lesson routed item 3).

Frozen predicate: `C1_CENSUS_CALIBRATION: value = CLEARED when INTACT = 1 and BOUND = 1 and NEW = 0,
else 0; target 3.`
- CLEARED: number of the three BASE findings absent from the measured tree's own census output.
- NEW: FINDING lines in that output that are not one of the three (must be 0).
- INTACT: every BASE registry id (102) is still one row with the same status; the S094/S099 `used-by`
  sets contain every BASE path (narrowing `used-by` is not a fix — control K1-F1).
- BOUND: exactly one S099 row in `source-fetches.tsv` whose sha256/bytes equal the fleet git blob
  `75dd2612:.ufo/prompts/kagi-round-44.md` (computed live from the fleet repo by the counter), whose
  quote occurs in that blob, and whose committed capture `.ufo/waves/round-47/capture/S099.body` has
  that sha256 (a hand-written provenance row is not a fix — control K1-F2).
- Fail closed: a census run with no `SOURCES_CENSUS: CLEAN|FAILED` last line is SETUP (K1-F4).

BASE measured: `value=0 cleared=0 new=0 intact=1 bound=0`. Controls (pre-freeze, all MATCH): K1-0
do-nothing 0; K1-P reference 3; K1-F1 used-by narrowing 0; K1-F2 hand-written provenance 0; K1-F3 row
deletion 0; K1-F4 silent census SETUP; K1-F5 fix plus a new finding elsewhere 0.
Kill rules (frozen): C1 is killed if value < 3 at the candidate, if the counter exits 2 at the
candidate, or if the candidate rewrites any pre-existing line of `corpus/lessons/round-43.md` or
`corpus/lessons/round-44.md` (only appended lines are allowed: `git diff BASE candidate` of those two
files shows no `-` line).
Sourced: S099 (pinned raw URL, re-opened 2026-11-06, HTTP 200, sha256 `e62e259c…1b80c`, 97077 bytes)
and S094 (re-opened 2026-11-06, sha256 `88556402…50b8`).

Target: value 3 at the candidate.

## C2 — freshness: the teaching of every fired Vault/OpenBao release clock re-verified on the served docs, 0 → 11

Problem (measured): 13 `on-release` clocks read `fired` at BASE (`python3 corpus/release-clock.py`:
`fired=13`): the release feed is past the anchored version (Vault 2.2.1, OpenBao 2.7.2). Two of them
(S027/S028, Python) already have re-verified successors (S040→S095, S041→S096). The other eleven —
S012–S016, S021–S026, the rows behind `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`,
`feature-bound-credential-review.md` and the round-22/23 lessons — have never had their teaching
re-checked after the clock fired (round-46 lesson routed item 4). A fired clock with no
re-verification is a stale claim the lane still serves.

Frozen predicate: `C2_FIRED_REVERIFIED: value = REVERIFIED when GATE = 1, else 0; target 11.`
- F: S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026.
- REVERIFIED: ids in F with exactly one `corpus/fired-reverify.tsv` row (header `id url
  observed_release fetched_at capture_path sha256 bytes quote_count verdict`) where (a) url = the
  registry URL; (b) observed_release = the id's `observed_version` in `release-clocks.tsv`;
  (c) 2026-11-06T00:00:00Z ≤ fetched_at ≤ the measured revision's committer time; (d) the capture is
  under `.ufo/waves/round-47/capture/`, exists, and matches sha256/bytes; (e) the id's
  `source-fetches.tsv` column-13 quote equals BASE's and `corpus/rendered-text-v1.py locate` finds it
  `count=K ≥ 1` with K = quote_count; (f) verdict `teaching-holds`.
- GATE: `python3 corpus/release-clock.py` exits 0 with `RELEASE_CLOCK: CLEAN`.

BASE measured: `value=0 reverified=0 gate=1`. Controls (pre-freeze, all MATCH): K2-0 do-nothing 0;
K2-P reference (L1 live captures 2026-11-06T19:29:56–59Z) 11; K2-F1 ledger without captures 0; K2-F2
round-36 dates 0; K2-F3 future dates 0; K2-F4 quote swap 0; K2-F5 verdict unset 0; K2-F6 clock gate
broken 0; K2-F7 normalizer missing SETUP. Named ceiling K2-C: hand-typed in-window times over
byte-correct bodies score 11 — the non-author live leg (independent re-fetch, sha256 compared) is the
check that catches it.
Kill rules (frozen): C2 is killed if value < 11 at the candidate, if the counter exits 2 at the
candidate, or if the candidate changes any column 1–8 cell of `corpus/release-clocks.tsv` (the
re-verification must not re-arm or re-score a clock).

Target: value 11 at the candidate.

## Non-claim work (no counter; recorded in the lesson)

- SCORECARD erratum for the round-46 operability row (closure routed 1: "8 → 11 cases" / "cases 9–11"
  vs the committed 12) — appended, never rewritten.
- Terminology: "non-author live re-observation" reserved for closure/operator checks (closure routed 2);
  this round's seat re-fetch is called the lane's independent live leg.
- S040/S041 ISO recheck `2026-11-05` is overdue at BASE; both are re-opened this round and their recheck
  cell moves to a cadence (old→new logged in the lesson).
- Frontier step: census before/after; one mistake mined; the sourced claims above.

## Erratum E48-1 (appended round 49; text from `corpus/lessons/round-48.md` §Errata, verbatim except its closing "Not yet appended …" sentence, which this append discharges; the lines above are unchanged)

- **E48-1 (round-47 C2 counter header, predicate prose only — `plans/round-47-c2.sh:4,9` and `plans/round-47.md:60`).** Read "the eleven rows with no successor row" as "the eleven fired rows (S012–S016, S021–S026), four of which have a successor row (S022 supersedes S012, S023 supersedes S013, S025 supersedes S014, S026 supersedes S016)". No predicate, target, control or value of round 47 changes: the counter's `F` set and its per-row checks are unchanged, and all eleven rows' own quotes were located (round-47 closure §2). What the sentence overstates is distinctness of *teaching*, not the count — round 47's own caveat (6 URLs / 7 quotes).
