# ConnectClock — sibling-overlap scan: release-observation vs kumitate generic tooling (round 26, C1)

Seat: `KagiR26.ConnectClock` (connector, leaf). Lane-authored advice, not non-author closure.

## Observed revisions

| repo | HEAD observed 2026-10-21 | note |
|---|---|---|
| kagi-shokunin | `1bf3eec48d3761580ffd375c88143232485ae814` | = frozen BASE; working tree carries L1's uncommitted round-26 integration (`M PROVINCE.md SCORECARD.md SKILL.md corpus/README.md corpus/SOURCES.md corpus/claim-ledger.tsv corpus/source-fetches.tsv`, `?? .ufo/waves/round-26/ corpus/lessons/round-26.md corpus/__pycache__/`) |
| kumitate-shokunin | `2fa28e5761220ee5b1c625bbb81ed5677c4522d6` | identical to round-25 `ConnSiblings6.md:6` — no kumitate drift since round 25 |
| kake-shokunin | `9f62cda0a6b71a9c0c86d2088f01673f25787715` | moved since round-25 `ConnSiblings6.md:5` (`f7de3ab…`) |
| tsukuroi-shokunin | `e99303c7ca75363b99a3d1937e65329b815c50f2` | — |
| kotoba-shokunin | `c61a973b2e02e1ded169703ddcb06466f4edd8bd` | — |

Commands: `git rev-parse HEAD` in each repo; `git status --short` in kagi.

## Inspected scope (exact)

- All 21 `*-shokunin/PROVINCE.md` (located with `ls */PROVINCE.md` from the fleet root, because the Glob and Grep tools returned 0 files under `/home/vgpnk/Projects/shokunin`; fallback was `rg -uu`). Scanned for `release|feed|clock|freshness|python|on-release|upstream|receipt|observe`.
- kumitate: `PROVINCE.md` (whole), `SKILL.md` + `corpus/SOURCES.md` (term grep), `scripts/` listing, `scripts/sources-check.mjs:300-340`.
- Fleet root: `scripts/sources-census.sh:1-70`; `scripts/`, `templates/` term grep.
- kake `scripts/`, tsukuroi `tools/` term grep for `on-release|feed.rss|release.?clock|rss|atom|pubDate`.
- S027/S028/S036 id rows across every sibling `corpus/SOURCES.md`; `3.15.0` rows across every sibling `corpus/SOURCES.md`.
- kagi: `PROVINCE.md` (whole + `git diff 1bf3eec -- PROVINCE.md`), `corpus/release-clocks.tsv`, `corpus/SOURCES.md` rows S027/S028/S036–S041, `corpus/release-clock.py` argparse/root lines, `corpus/claim-ledger.sh` `.ufo` resolution lines, `.ufo/waves/round-26/tools/replay-current.sh`, `.ufo/waves/round-26/frozen/{before,after}/corpus/release-clocks.tsv`, `frozen/expected.json` (S027/S028 lines).
- Nothing host-private or config read. No network. No build/lint/test/selftest run. No installs.

## Overlap boundary evidence

1. **kumitate owns orchestration tooling, not release observation.** `kumitate-shokunin/PROVINCE.md:3` "orchestration & tooling — scopes OMP task/hub, ufo-fsd scripts & runtime"; `:12-15` Core = `ufo-fsd-alpha/scripts/`, `crates/ufo-core-runtime/src/` + `crates/ufo-cli/src/`, `~/.kimi-code/`, and the lane's own `scripts/*.mjs` (`anchor-truth cite-check claims-check kimi-census proxy-check round-gate sources-check surface-probe`). None is a release-feed clock.
2. **kumitate's only `on-release` handling is syntactic acceptance.** `kumitate-shokunin/scripts/sources-check.mjs:308` accepts `on-release` as a valid recheck; overdue judgment at `:330-337` covers only ISO dates and `Nd` cadences, so an `on-release` row never fires there. kumitate has 14 `on-release` rows (S001–S006, S010, S012–S014, S022, S024, S026, S027, S031 per `corpus/SOURCES.md:14-44`) with no feed binding. That gap belongs to kumitate; it is not kagi's to absorb.
3. **The fleet-root census also leaves symbolic cadences unjudged.** `scripts/sources-census.sh:36-37`: "symbolic cadences (e.g. on-release) are reported, never judged overdue."
4. **The other freshness and feed neighbours use different mechanisms.** kake `scripts/freshness-sweep.mjs` covers absolute-path citations (`ConnSiblings6.md:17`). kumitate `SKILL.md:387-388` `freshness_ping` is a heartbeat-file mtime check. kotoba `PROVINCE.md:21` "Loader-rule freshness" concerns omp substrate drift. tsukuroi `PROVINCE.md:20` Arch News is "a public feed read is not host state, and upgrade actions remain operator-owned", and `tools/check-recheck-commands.py:972,1158` binds `on-release` to per-entry shell procedures, not feeds.
5. **The new production wording stays in-lane.** It reads "No installed-runtime or system-package management is claimed" (`git diff 1bf3eec -- PROVINCE.md`, release-clock bullet). That keeps the host-Python and package ground with tsukuroi, which matters because pacman is paused host-wide.
6. **kagi's instrument is lane-local by construction.** `corpus/release-clock.py:59` reads `root/corpus/SOURCES.md` and `:100` reads `root/corpus/release-clocks.tsv`. `:1583` sets root to `--root` or the script's own checkout. `replay-current.sh` calls it with `--root "$frozen/$mode"`. Neither path reads a sibling registry.

**Verdict: C1 remains in-lane.** No sibling holds a feed-bound release-clock instrument, so kagi's `release-clock.py` / `--observe` / frozen replay overlaps no sibling's gated ground. The wave tool lives under kagi's own `.ufo/` (753 `.ufo` files are tracked at BASE; `claim-ledger.sh:661-665` resolves `.ufo/` lane-first). It is not ufo-fsd-alpha script or runtime ground, which is what kumitate owns.

## Actionable counterexamples

- **CX1 — S-id collisions across the fleet.** S027 and S028 exist in 20 sibling registries. Two are near-collisions with kagi's Python-docs rows. `kake-shokunin/corpus/SOURCES.md:35` S027 is `https://docs.python.org/3/library/urllib.parse.html` (`on-release`, mined), the same doc set that moved 3.15.0 → 3.15.1. `kumitate-shokunin/corpus/SOURCES.md:41` S028 has a `/oss/python/` URL, and `:40` S027 is a git release-notes row with `on-release`. The round-26 counting instrument "compares exact S027/S028 identities" (plan §Declared claim). Any count keyed on a bare id, or on id plus "python", over fleet paths would mix in kake or kumitate rows. The frozen instrument is safe (`frozen/expected.json:20-31` holds bare ids, but `release-clock.py` reads only `--root`). L1 should key any report-side or ledger-side S027/S028 count on `(kagi, id)` or the full row URL, never on a fleet-wide bare-id grep.
- **CX2 — sibling rows that kagi's 3.15.1 observation fires but kagi must not absorb.** 18 sibling rows carry a `3.15.0` anchor with `recheck=on-release`:
  - chousa S038 (`corpus/SOURCES.md:48`); kaidoku S050 (`:56`); kengaku S046 (`:68`), S052 (`:74`); lore S003 (`:11`)
  - mori S065 (`:71`), S068 (`:74`), S069 (`:75`), S073 (`:79`)
  - revenger S011 (`:25`)
  - souji S040 (`:60`), S050 (`:70`), S061 (`:81`), S067 (`:87`)
  - tameshi S049 (`:58`), S055 (`:64`), S065 (`:74`), S073 (`:82`)

  Command: per-lane `awk -F'|' '/3\.15\.0/ && /^\| S[0-9]/'` over each sibling's `corpus/SOURCES.md`. A separate fleet-wide `rg -uu` pass finished later and matched the same 18 rows at the line numbers above. Its only extra match, `souji-shokunin/corpus/SOURCES.md:140`, is a prose round-14 log line ("Python 3.15.0 pathlib documentation"), not a registry row, and is excluded. Under the kagi province rule ("report cross-domain evidence back to the orchestrator rather than absorbing it"), this list goes to L0 as a routing note only. Adding kagi rows, clocks or claims for it would be scope absorption and would harm the calibration axis.
- **CX3 — the production pointer depends on uncommitted wave files.** The new `PROVINCE.md` release-clock bullet cites `.ufo/waves/round-26/tools/replay-current.sh`, which runs against `frozen/` (`inputs.sha256`, `observe-1.json`, `before/`, `after/`, `release-clock.py`). All of it is currently untracked (`?? .ufo/waves/round-26/`; `git check-ignore` exit 1, so it is not ignored). If L1 integrates `PROVINCE.md` without also tracking `tools/` and `frozen/`, the pointer dangles in any fresh clone. Once tracked, it resolves lane-first and does not add to the FLEET-ABSENT/48 count.
- **CX4 (in-lane, adjacent) — the successor rows lose the release trigger.** The `on-release` set and the clock table are still exactly equal (28 = 28, S005–S032), and S039/S040/S041 use `recheck=90d`. Production `release-clocks.tsv:24-25` still binds S027/S028 to S036 at `not-fired`, the historical binding, as the plan intends. The frozen after-profile fires them: `frozen/after/corpus/release-clocks.tsv` S027/S028 show `S036 3.15.0 3.15.1 fired` against `before` `3.15.0 3.15.0 not-fired`. So the next CPython release fires the superseded S027/S028 clocks, while the successor teachings S040/S041 sit on a 90-day timer (due 2027-01-19) with no release trigger. Whether that is right is L1's call. If it stays, it should be named as a limit, not implied as continuous coverage.

## Proposed move (one, bounded)

Keep C1 in-lane by integrating two things together:

1. Track `.ufo/waves/round-26/tools/` and `.ufo/waves/round-26/frozen/` in the same integration as the `PROVINCE.md` replay pointer (closes CX3).
2. Record CX2's 18 sibling `(lane, id)` pairs only as a report-to-L0 routing note in the round-26 report or lesson. Add no kagi registry row, clock or ledger claim for them. Key every S027/S028 count on `(kagi, id)` (closes CX1).

**Affected axes:** freshness is preserved, and drift evidence is routed fleet-visible without absorbing it. Calibration improves: no dangling production pointer and no bare-id over-count. **Harm:** none identified. The round-25 receipt, the binding TSV, the R25-04 default and C2 INCOMPLETE/48 are untouched.

## Risks

- The sibling list is a snapshot at the HEADs above. Siblings may commit again, so L0 should re-read before routing.
- The `3.15.0` match is textual. Some sibling rows may mention 3.15.0 without depending on it (not checked row by row).
- CX4 is a design question for L1, not a defect.

## Verification L1 should run after integration

- `git status --short .ufo/waves/round-26/tools .ufo/waves/round-26/frozen`, confirming they are tracked.
- `corpus/claim-ledger.sh citations`: the new PROVINCE pointer should resolve and the count should stay INCOMPLETE/48 FLEET-ABSENT in a lone clone.
- `.ufo/waves/round-26/tools/replay-current.sh before|after` against `frozen/expected.json`.
- `corpus/release-clock.py --selftest` (67 cases).

None of these were run by this seat.

## Tooling

No installs or updates. The Grep and Glob tools returned 0 matches under the fleet root, where `rg -uu` found 21 PROVINCE files, likely because of ignore rules. I used `rg -uu` via the shell as the fallback. A fleet-wide `rg -uu --glob '*-shokunin/corpus/SOURCES.md'` took 60–164 s. One run was backgrounded, and a per-lane loop that finished in 0.17 s replaced it. The backgrounded run later completed in 65 s and agreed with the loop.
