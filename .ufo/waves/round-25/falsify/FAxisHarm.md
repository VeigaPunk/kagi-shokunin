# Round 25 falsification — FAxisHarm

Candidate: `82745e2c60e726b49499b8f309529935dc4eff2b`; BASE: `4587c61a348e4528717404a68912c373f3ef4d03`. Exact candidate was checked out in `/fast/scratch/kagi-r25/FAxisHarm-4/lane`. No tool installs.

## Findings

- **FAIL — C1 completeness/calibration scope is narrower than its declared population.** `corpus/README.md:33` states the current `checklist-run.sh --selftest` count, `34 cases`. This is a self-description of a lane artifact in a named C1 target document with a live non-host source: `corpus/claim-ledger.tsv:34` (`R15-02`) runs that selftest and expects `CHECKLIST_SELFTEST: PASS (34 cases)`. `corpus/self-counts.tsv:32` binds the analogous PROVINCE.md count, but rows 42–51 contain no README checklist binding. Nevertheless, the C1 gate prints `SELF_COUNTS: CLEAN (claims=37 stale=0)`. `self-counts.py:200-265` iterates only table rows; it has no completeness check for unlisted document numbers. Thus at least one eligible current value inside the three claimed target docs is outside the 37 bindings. This falsifies “every” such number is bound, not the individual bindings that do pass.
- **Smallest safe correction:** add a README binding for the checklist count (e.g. `ledger:R15-02`) and update dependent counts/pins; before claiming completeness, also enforce inventory closure or narrow the contract to “these 37 reviewed bindings.” The lesson’s explicit “completeness over all docs is NOT claimed” (`corpus/lessons/round-25.md:55-57`) is a good ceiling, but does not cover this omission inside the stated three-document population. Keep the named knowledge-entry debts at `:158-170`; do not infer corpus-wide currentness or a statistical calibration gain from 37 curated bindings.
- **PASS, bounded — routed D1/SKILL.md:46 is corrected.** BASE evidence `.ufo/waves/round-25/c1-before.txt:1-2` shows the old 63/39 values stale against 83/61. Candidate `SKILL.md:46` says 88 stamps / 65 claims; bindings `SC-SKILL-STAMPS` and `SC-SKILL-CLAIMS` (`self-counts.tsv:15-16`) use `R12-03`/`R21-04`.
- **PASS, bounded — C2 mechanics.** The 166-case hermetic selftest passed, including lone `INCOMPLETE`, `LAYOUT-INCOMPLETE`, fleet-clean, partial-fleet and lane-owned-miss controls. The committed lone citation sample ends `CITATION_LAYOUT: lone-clone … fleet_absent=48` / `CITATION_GATE: INCOMPLETE … unresolved=0` (`c2-lone-citations-after.txt:68-69`). No row skip/tag is used. This supports the stated layout outcome, not a full real-fleet integration rerun.
- **PASS, point-in-time — C3 offline binding check.** 28 bindings, 28 observed, 1 fired, 15 derived; 48-case selftest passed. The 2026-10-21 receipt is a dated observation, not continuous freshness: offline evaluation validates an ISO date (`release-clock.py:407`) but does not enforce age or schedule observation. Do not claim these observations remain current without a new explicit `--observe`.

## Six axes and ceilings

`SCORECARD.md:964-969` holds all six at 9→9; this round claims no score increase. Depth: no vault/item-level reads (`PROVINCE.md:59`). Coverage: feeds add no governed host surface (`SCORECARD.md:965`). Operability: no scheduler and by-hand duties remain (`SCORECARD.md:215,966`). Freshness: on-demand, dated observation only (`SCORECARD.md:967,975`; age/schedule limit above). Calibration: 37 selected bindings do not establish completeness or score validity (`SCORECARD.md:968`; relevance remains review judgment at `:279-280`). Adjacency: ownership is reported, not adjudicated (`PROVINCE.md:67`). Saturation remains 9; no 10/retirement claim (`SCORECARD.md:977-979`).

## Reproduction and provenance

Commands below ran in the isolated candidate clone with `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FAxisHarm-4/home`; exit codes are the wrapped child status.

- `python3 -B corpus/self-counts.py` — **exit 0**, stdout `SELF_COUNTS: CLEAN (claims=37 stale=0)`. Counterexample above shows this CLEAN is not a completeness verdict.
- `bash corpus/checklist-run.sh --selftest` — **exit 0**, stdout `CHECKLIST_SELFTEST: PASS (34 cases)`; live value behind the omitted README number.
- `python3 -B corpus/self-counts.py --selftest` — **exit 0**, stdout `SELF_COUNTS_SELFTEST: PASS (33 cases)`.
- `bash corpus/claim-ledger.sh --selftest` — **exit 0**, stdout `SELFTEST: PASS (166 cases)`.
- `python3 -B corpus/release-clock.py` — **exit 0**, stdout `RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)`.
- `python3 -B corpus/release-clock.py --selftest` — **exit 0**, stdout `RELEASE_CLOCK_SELFTEST: PASS (48 cases)`.
- `git diff --numstat BASE CAND -- corpus/SOURCES.md corpus/source-fetches.tsv corpus/inrow-pins.tsv` — **exit 0**: `5 0 corpus/SOURCES.md`; `5 0 corpus/source-fetches.tsv`; no `inrow-pins.tsv` delta. Only S033–S037 source rows and matching captures are added; existing source rows are untouched.
- Read-only ID set comparison BASE→CAND — **exit 0**: dropped IDs `0` in `stamps.tsv`, `claim-ledger.tsv`, and `source-fetches.tsv`; added respectively 5 stamp paths, R25-01..04, and S033..037.

**UNRUN:** full `verify`/`cells`, C2 whole-layout measurement, and network `--observe` (per-seat limits). No full-tree or real-lane gate was run; no production file except this report was written.
