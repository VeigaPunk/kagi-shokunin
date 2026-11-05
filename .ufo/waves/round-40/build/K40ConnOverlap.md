# K40ConnOverlap — sibling-overlap scan, round 40 (connector)

Seat: K40ConnOverlap. Leaf, read-only over the fleet. Full receipt: `.ufo/waves/round-40/build/K40ConnOverlap/overlap.md`.

## What I executed

- Read `plans/round-40.md` in full (frozen plan). Owned axes: freshness + calibration; C3 operability.
- Enumerated lanes: `printf '%s\n' /home/vgpnk/Projects/shokunin/*-shokunin` → 21 lanes; skipped kagi.
- Presence-checked PROVINCE.md / SKILL.md / corpus/SOURCES.md per lane (bash loop, exit 0). audio and
  game-dev-2d have no SKILL.md; every lane has PROVINCE.md and corpus/SOURCES.md.
- Ran three per-lane grep waves (grep tool, case-insensitive) over the three files of each lane:
  (a) `docs\.python\.org|Python 3\.[0-9]+\.[0-9]+ documentation|served[- ]version`;
  (b) `anchor[ -]pins?|ANCHOR_PINS|sha-?pinned|lineSha256|pin-recheck|ANCHORLINE|anchor_line|anchor cell|anchor header|anchor-pins\.tsv`;
  (c) `gate[ -]registr|SELFTEST[: ][A-Za-z]*pass|self-?test.*(pass|cases)|--selftest`;
  plus four single-file confirmation greps (tsukuroi, kengaku, game-dev-3d, kaidoku SKILL.md).
  All greps exit 0-or-"no matches"; outputs in the receipt. No clones, no fixtures, no git/jj calls.
- Tool installs: **none** (read-only scan; no pacman, no uv, no downloads).
- Scratch tree `/fast/scratch/hyaku/kagi-r40/K40ConnOverlap` was created, unused (no clone was needed),
  and deleted before this report. Nothing was written outside the seat dir and this Report path.

## Findings (per-lane verdict table in the receipt)

1. **(a) python.org documentation-currency claims: 14/20 sibling lanes carry the same surface.**
   docs.python.org rows with served-version labels and supersede/refresh chains live in
   chousa (S038/S044, 3.15.0/3.15.1), kaidoku (S266/S267/S287, "Python 3.15.2 documentation"),
   kake (S441/S442, 3.15.2), kama (S087/S088 series-vs-micro currency rows), kengaku (S046/S052
   "rechecked 2026-10-26 on Python 3.15.2 docs (R40SourcesRecheck)" — explicit refresh rows), mori
   (S231 located-quote correction; S577 sphinx footer-stamp row), revenger (S040→S044→S053 zipfile
   3.15.0→3.15.1→3.15.2 refresh chain on one URL — the same shape as kagi's S040→S095), souji
   (S229 rejected because served 3.15.2 ≠ lane interpreter), tameshi (S100/S153: "docs.python.org's
   footer clock moves within a day (the round-33/40 lesson)"), tsukuroi (S335 fetched 2026-11-05),
   plus kaidoku/kake/mado/kotoba/lore overlapping-light. Verdict: **overlapping** (same surface:
   corpus/SOURCES.md python-docs currency rows).
2. **(b) anchor-cell pinning: 7 lanes overlapping, 6 adjacent.**
   Overlapping (same surface: sha-pinned anchor/quote cells of registry rows): kasegi (every row
   "anchor pinned to the round-N capture … sha256 …, lines …"), kengaku (`anchor-line-check` gate,
   committed, `--selftest`, `ANCHORLINE rows=210 cited=64 captured=57`), revenger (receipt_sweep
   `--selftest` checks "the ANCHOR cell (column 7 of 11) of every `| S### |` row"), tameshi
   (S300 anchor-drift sweep comparing anchor-cell §heading vs snapshot heading set, with a red arm),
   mori (S349 sha256-anchor correction via superseding row; "anchor cell is immutable"), kaidoku
   (locator cells carry snapshot sha256), kama adjacent-strong (`registry/pin-recheck-rows.tsv`
   anchor headers recomputed byte-for-byte by `tools/round86-pin-origin.py`; committed
   `corpus/anchors/` extracts — same idea on kama's own registry files, not SOURCES). Adjacent:
   kake (freshness-sidecar `lineSha256`), game-dev-3d (sha256 citation stamps), tabi (pinned
   methodology scripts), chousa (fetched-byte sha in locator cells), tsukuroi (S333→S334 re-index),
   kotoba/kotodama/mado light.
3. **(c) gate-registry + committed-gate-selftest: 17/20 lanes overlapping.**
   kengaku (`## Gate/probe registry (PROTOCOL §Gate standard)`; round74-c1 registry gate with a
   `SELFTEST-UNBACKED` defect class), kaidoku (`## Local round-evidence gate registry` :886 AND
   `tools/round-86/gate-registry.py`, a counter whose G1–G5 legs re-derive one gate's row: row
   exists, exits declared, **the row's own self-test command run and its exit compared**, pinned
   blob, owner round), mori (`tools/mori-gate-registry.py` audits instruments against the
   gate-registry standard; `tools/mori-pin-check.py` "Remeasure the self-test tally pins bound in
   SKILL's gate registry"), kotoba (`## Gate registry` + `verifiers/check_gate_registry.py --rev`),
   kumitate (`## Gate registry`, 29 rows, per-row `--selftest` + 43-mutant battery), revenger
   (registry-home rows with red/green selftest evidence pairs), lore (registry rows literally
   encoding "self-test command: unavailable … conformance debt"), chousa, kama, kake, kasegi,
   kotodama, mado, souji, tabi, tameshi, tsukuroi (`### Gate registry` :1705). None: audio,
   game-dev-2d, game-dev-3d (committed gate, no registry/selftest pairing in the scanned files).
   Verdict: **overlapping** for kagi C3 — the two-row landing conforms to fleet convention; it is
   not novel, and no sibling surface is harmed by it.

**No contradiction found with any C1/C2/C3 claim.** C1 is lane-internal (claim-ledger rebind) — no
sibling surface touches it. C2's refresh-row pattern is already fleet practice, so landing S095/S096
creates no first-of-kind collision; the expected W04 duplicate-URL warnings (S095/S096 sharing URLs
with S040/S041) match the kasegi S072/S070 and kaidoku S299/S300 precedents (warnings, not findings).
C3's predicate is strictly weaker than three existing sibling programs (kaidoku G-legs, kengaku
SELFTEST-UNBACKED, mori registry/pin remeasure) but harms none of them — they are other lanes' surfaces.

## Proposed move (one bounded move)

**C3 rows: carry the selftest's pinned tally inside the registry row (kasegi/lore row convention,
kaidoku G3 leg shape).** When the two `## Gate registry` rows for `corpus/anchor-pins.sh` and
`corpus/claims-declared.sh` land in the candidate (the plan already lands them after the freeze),
write each row's pinned-values cell to include the selftest's final verdict line and case count —
e.g. `ANCHOR_PINS_SELFTEST: PASS (8 cases)` / `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` — the same
convention kasegi rows use (`--selftest -> cases=N failures=0` per row) and lore's registry encodes,
and the artifact kaidoku's G3 leg and mori's pin-remeasure gate consume. Effect: the row becomes
self-auditing — the M39-6 constant-counter/verdict-weakening class stays detectable by re-reading the
committed row against a re-run, without re-running the C3 counter, and without any new instrument.

- Affected axes: **operability improves** (the C3 artifact degrades gracefully: drift between the row
  and the selftest bytes becomes a visible diff, not a silent one). Freshness and calibration untouched:
  no C1 population row, no SOURCES row, no counter bytes change.
- Harms none: the rows land in the candidate as part of the already-planned post-freeze landing
  (plan §C3: "The registry rows … land in the candidate, after the freeze"), so this is landing-time
  authoring, not a post-data amendment; C3 kill rule 3 (weakening a selftest after data) is unaffected;
  the C3 counter's row-detection predicate (row names the script path) is unaffected by extra pinned
  cells; no S040/S041 cell is touched.

## Risks

- If the C3 counter parses the whole row line strictly (e.g. exact cell count), extra pinned text in
  the pinned-values cell could change the row's parse. Mitigation: the counter's declared predicate is
  "a row … naming the script path" — verify the counter's row matcher tolerates the cell content before
  landing (one run of `bash plans/round-40-c3.sh` on the candidate tree; it is already run at landing).
- Scope boundary: this proposal changes what the candidate writes into SKILL.md rows; it does not amend
  the frozen plan, the counter, or the controls. If the executor judges the cell edit out of scope for
  the frozen C3 wording, route it as M40 material for the round-40 lesson instead of editing anything.
- Second-order: kagi gaining pinned-tally rows invites the kengaku-style successor (a `SELFTEST-UNBACKED`
  class over kagi's own registry). That is future debt, correctly outside every round-40 population.

## Verification

- Scan is grep/read only; every quoted line above is a grep hit with lane:file:line in the receipt
  (`overlap.md`). No counter was run by this seat; the C1/C2/C3 reproduction stays with the seats
  assigned to them.
- Suggested main-agent checks: re-run the three confirmation greps on tsukuroi/kengaku/kaidoku
  SKILL.md (`gate[ -]registr`) to confirm the registry headings cited at :1705/:592/:886; read
  kaidoku `tools/round-86/gate-registry.py` G3 leg if the C3 successor move is ever considered.
- Tool installs: none. Scratch tree deleted. Writes: this file + `build/K40ConnOverlap/overlap.md` only.
