# CheckRearm — derived rearm path at candidate `62a33b1` (freshness / calibration)

Target: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`.
Attack: independently check the derived rearm path (successor feed row + retained old fired rows, no unrelated false positives); name the actual remaining limitations.

**Verdict: PASS (narrow) for the working rearm shapes; FAIL for one sub-shape (the round-26 successor shape applied to a `derived:` group) — inherited at BASE, not claimed by round 28.** No candidate-introduced wrong verdict in the rearm path itself: 3 substantive + 2 low findings.
Method: offline probes only. Harness `.ufo/waves/round-28/sandboxes/KagiR28.CheckRearm/probe.py` (outputs `probe-out.txt`, `probe-base-out.txt`, both kept here); the candidate/BASE trees and the nine probe trees live under `/fast/scratch/hyaku/kagi-r28/KagiR28.CheckRearm/` (scratch directive) and were deleted at completion — re-export with the command in "Commands". No network, no vault/account/CDP, no lane gate run, no lane mutation.

## Findings

**F1 (High, inherited; not fixed by round 28) — the round-26 successor shape cannot rearm a `derived:` group: the retained predecessors go `REGRESSED` and the gate exits 1.** `corpus/release-clock.py:440-460` (`feed_floors`), `:433-437` (`is_regression`), `:633-641`. P3 (new feed row `S051` naming `v3.14.0` + successor clock row `S050`; predecessors `S008–S011` untouched): `REGRESSED S008 S009 S010 S011`, `FAILED (on_release=31 bound=31 unbound=0 observed=27 fired=3 derived=12)`, exit 1 — identical at BASE. "Successor feed row + retain old rows" therefore works only for non-derived groups (P7); a derived group must be rearmed **in place, every row** (P4 → CLEAN exit 0). The lesson's Limits bullet states that requirement but no typed finding enforces it (F3).

**F2 (Medium, candidate-introduced false-positive vector) — the feed row's anchor cell must name EXACTLY ONE stable `X.Y.Z`; a successor feed row that also records the retained historical version in its anchor cell breaks every derived row bound to that feed.** `corpus/release-clock.py:349-363` (`derived_anchor_bound`), `:618-626` (`DERIVATION`). P2 (S039's anchor cell → "Python 3.15.1 item, … ; historical 3.15.0 item retained; fetched 2026-10-21"): `DERIVATION S040`, `DERIVATION S041`, `FAILED (… observed=28 fired=3 derived=15)`, exit 1; at BASE the same tree is `CLEAN`, exit 0. The frozen C2 wording (`plans/round-28.md` §C2: "must be the version named by its `feed_source_id` registry row's located anchor") does not state the exactly-one rule the implementation adds ("a cell naming two different versions binds none", `corpus/release-clock.py:355-360`). The lane keeps history in `teaches`, not the anchor cell (`corpus/SOURCES.md:46`, S039 teaches: "Historical 3.15.0 remains a valid earlier observation"), so a successor feed row written that way breaks all 15 derived rows in 4 groups (SOPS 4 / Vault 4 / OpenBao 6 / curl 1).

**F3 (Medium, limitation NOT enforced) — C2 binds the clock table to a dated registry cell, not the cell to the live feed: a derived group whose feed advanced and was never rearmed is C2-clean.** `corpus/release-clock.py:606-619` binds only against `feed_source["anchor"]`; nothing compares the anchor with the observed newest release. P5 (feed advanced to `3.14.0`; derived anchors left at `3.13.3`, observations `3.14.0`, verdict `fired`, pinned feed row `S033` unchanged): `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=7 derived=15)`, exit 0 — the declared derivation ("newest stable … when the row was opened") is false and nothing reports it. P6 (same + a successor feed row present) is also CLEAN exit 0. BASE identical, so C2 does not close this blind spot.

**F4 (Low) — a mis-pointed feed row now gets a second, unrelated typed finding.** `corpus/release-clock.py:613` (`BADFEED`) vs `:618-626` (`DERIVATION`, evaluated even when the feed row already failed). P9 (`S029.feed_source_id → S030`, a non-feed row): `BADFEED S029` **and** `DERIVATION S029`, exit 1; at BASE only `BADFEED S029`.

**F5 (Low, coverage) — neither the frozen counting command nor the selftest exercises the rearm path.** `.ufo/waves/round-28/tools/c2-measure.py` G1–G4 only *lower* derived anchors (no successor feed row, no retained predecessors/fired rows); `grep -c rearm corpus/release-clock.py` = 1 (the `--receipt` help string). The C2 claim's measured evidence does not cover the flow under attack.

## Narrow PASS evidence (candidate `62a33b1`)

- **P1** derived rearm successor on the corpus's own python.org shape (`S040`/`S041` declared `derived:`, bound to successor feed row `S039`, whose anchor cell names only `3.15.1`): `CLEAN (… fired=3 derived=17)`, exit 0; old fired rows `S027`/`S028` (`corpus/release-clocks.tsv:24-25`) retained and unaffected. BASE: same CLEAN (no C2 delta here).
- **P4** atomic in-place rearm of the SOPS derived group + new feed row naming `v3.14.0`: CLEAN, exit 0 — the only C2-clean shape for a derived group.
- **P7** python.org rearm (successor feed row `S053` naming `3.15.2` + successor clock row `S052`), retained old fired rows `S027`/`S028` re-observed at `3.15.2`: `CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=5 derived=15)`, exit 0 — retained fired rows survive as fired rows at their original `3.15.0` anchor, no unrelated finding.
- **P8** same rearm, retained rows keep their old receipts: `REGRESSED S027 S028 S040 S041`, exit 1 — a stale retained observation is a typed failure (floor semantics, `:440-460`), not a false positive; the retained rows must be re-observed.
- No probe produced a finding outside the rearmed feed family (Vault / OpenBao / curl / 1Password groups stayed clean in every tree). Pins corroborated: `python3 -I -B corpus/release-clock.py --root .` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0 (= `corpus/claim-ledger.tsv:83` R25-04); `--selftest` → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` exit 0 (= `corpus/claim-ledger.tsv:82` R25-03).

## Commands (sandbox only; exit codes as shown)

- Re-export (exit 0): `S=/fast/scratch/hyaku/kagi-r28/KagiR28.CheckRearm; mkdir -p $S/cand $S/base; git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1 | tar -x -C $S/cand; git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d49 | tar -x -C $S/base`.
- `python3 -I -B corpus/release-clock.py --root .` (in `$S/cand`) → exit 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`; `--selftest` → exit 0, PASS (106 cases).
- `python3 -I -B probe.py` (candidate tree) → P1 0, P2 1, P3 1, P4 0, P5 0, P6 0, P7 0, P8 1, P9 1. `PROBE_TREE=$S/base python3 -I -B probe.py` → P1 0, **P2 0**, P3 1, P4 0, P5 0, P6 0, P7 0, P8 1, **P9 1 (BADFEED only)**.
- No tool installed or upgraded (none needed); no network fetch.

## What I did NOT check

- No live feed fetched: `3.14.0` and `3.15.2` are synthetic versions used only to exercise the machinery; no such release is claimed, and probe receipts carry a zero digest (not a real body hash).
- The frozen `c1-measure.py` / `c2-measure.py` were read, not executed (other seats own them); C1's non-canonical paths were not re-checked except where they interact here (`NON-CANONICAL` precedes `DERIVATION` on the same row, `corpus/release-clock.py:617-632`). The `--observe` path for a rearm (network-bound) was not exercised; the selftest's observe case covers only the derived mismatch.
- No verification of the ledger/stamp/self-count migration a real rearm would need (pins read only, per the lane rule); F1's acceptability against QM24 is the L1's call, not mine.
