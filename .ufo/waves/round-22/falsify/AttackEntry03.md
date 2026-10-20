# AttackEntry03 — falsification of integrated C2 for `corpus/knowledge/cdp-bridge-1password.md`

Seat: `KagiR22.AttackEntry03` (leaf, read-only; no delegation). Date 2026-10-20.
Axes: **calibration, freshness**. No tools installed; no host gate, no loopback/CDP/launcher/package probe, no vault/account operation, no revision-audit rerun (parent's global duty). All git usage read-only (`show`, `diff-tree`, `log`).

## 0. Verdict (one)

**ADMIT.** The integrated C2 state of this entry is admissible: the round-22 change is a provably pure append, every prior reading is marked historical without rewrite or laundering, the old stamp row survives as exact historic evidence, and the re-pin is coupled to the append in the single landing commit. Admission covers the *freshness accounting only* — it does not establish source-fact currentness; the entry remains historically sourced with both `Reverify` rows deferred.

## 1. Byte evidence — frozen-before vs current

| Snapshot | Where | sha256 | lines | bytes |
|---|---|---|---|---|
| Frozen-before (base `c2cab35`) | git blob `30b48fd3a4321a66afc485ee76a594c7c1095927`; `git show c2cab35bc92e57e39e5489bac3386db078345b3f:corpus/knowledge/cdp-bridge-1password.md` | `62020ad1ea4f879f84a9a50be921777ea43f4fe9308ccbf1434d45c7304fe1bb` | 88 | 4320 |
| Current (landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` = worktree) | `corpus/knowledge/cdp-bridge-1password.md` | `d6833b54e8658a93dca5dbc51299ad82f50d33ae28fedeb6d85f305632528db3` | 100 | 5023 |

- Freeze integrity: the manifest `integration-manifest.json` inputs record for this path is exactly `d6833b54… / 100 / 5023` — current bytes equal the frozen integrated input equal the landing-commit bytes. No mid-wave drift.
- **Unchanged prefix proven**: `head -c 4320` of the current file hashes to `62020ad1…`, identical to blob `30b48fd3` and base `c2cab35`. Delta is purely additive: +12 lines / +703 bytes (blank separator, `## Erratum (round 22 — historical source boundary)` heading, 9 content lines). Lines 1–88 are byte-identical; no in-place edit, no rewrite, no deletion.

## 2. Stamp record and migration accounting (this path only)

| Item | Evidence | State |
|---|---|---|
| Old row preserved as exact historic evidence | `.ufo/waves/round-22/frozen/before/corpus/stamps.tsv:11` = `62020ad1… / 88 / 4320` | present, exact |
| Current row | `corpus/stamps.tsv:13` = `d6833b54… / 100 / 5023` | equals measured current bytes → pointer fresh; was `:11` at base (two rows inserted above by other entries; membership intact) |
| Same-commit coupling | `git diff-tree -r 8ada17a` lists `corpus/knowledge/cdp-bridge-1password.md`, `corpus/stamps.tsv`, `corpus/claim-ledger.tsv` (plus the two frozen-before TSVs) in the one landing commit | no silent re-pin, no row-only restamp |
| Nine dropped stamps | path absent from `round21-migrations.json` (grep count 0; `removed_members: []`) and from `historical-correction-pins.json` changed records | this row was never a dropped/replaced member |
| Before measurement | `before.json` stale list = config-layering, handler-on-disk-state, handler-trust-boundary, janitor-env-contract, lessons/round-18, LOG | this path fresh at before, not among the six stale |
| Row provenance | added by `2486643` (2026-09-28, round-14), value unchanged until this round's coupled update | single-history, no laundering |
| Index | `corpus/README.md:23` still points at `knowledge/cdp-bridge-1password.md` | no rename/re-point |

## 3. Pointer freshness vs unavailable source facts (required distinction)

- **Pointer freshness: PROVEN.** Row `13` pins exactly the shipped bytes; sha/lines/bytes all measured by me this wave.
- **Source facts: UNAVAILABLE.** The entry's evidence basis (`~/.local/bin/the-janitor`, ranges L22–27, L109–111, L251–271, L273–291, L325–328, quoted JSON and refusal text) is not re-readable: the substrate-absence record `corpus/knowledge/substrate-deferral.md` names `the-janitor` and its config/state trees absent (I verified that file's content; it also now carries its own round-22 erratum dating its counters). The internal `L22–26` vs table `L27` discrepancy is honestly left open in-corpus ("do not resolve it by guessing"). No copy of the handler exists in the repo.
- **Host facts: SUPERSEDED per recorded audit.** Build-wave `build/Entry03.md` §3 records `op` 2.41.0 (entry says 2.35.0), the `the-musketeer` NMH manifest absent (entry says "is present"), BrowserSupport still present. Per the wave contract these build artifacts are advisory; I did not independently re-probe host state (observation boundary) — the erratum's admissibility does not depend on them.

## 4. Erratum quality — marks every false reading, no laundering

Checked against the build-wave plan (Entry03.md §6) and the corpus's historical-source convention:

- Marks `Source-status: historical` over handler, old profile/manifest, version, line ranges, behavior — every pre-append sentence class is covered; the remaining live claim (existence of the scoped audit file, the substrate-deferral record) was verified by me to exist.
- Reverify line untouched (inside the proven-unchanged prefix); no second declaration; no header block added; no rename.
- Range disagreement flagged unverified rather than silently "fixed" — matches plan item D9.
- No replacement browser profile asserted ("No replacement browser profile is adopted") — rejects the re-point overclaim.
- "A deferred row is not a pass" matches `substrate-deferral.md` Bounds 1; `claim-ledger.tsv:15-16` confirms R11-01/R11-02 both carry `[substrate]`, so `docs`/`verify` report this entry declared+pinned with deferred rows — the pin-fresh≠content-fresh distinction is enforced by the ledger, and the erratum says so in prose.
- Nothing false remains unmarked; nothing new is asserted beyond pointer/disposition facts.

## 5. Findings by severity

- **Critical/high: none** in this entry's slice.
- **Low-1 (durability):** the in-corpus erratum genericizes the measured drift ("version", "old profile/manifest") and delegates the exact values (op 2.35.0→2.41.0, NMH absent, BrowserSupport present) to the wave artifact `build/Entry03.md`. Not laundering — but if `.ufo` evidence were pruned, the drift numbers lose their in-corpus target while the historical marking itself remains valid.
- **Low-2 (documentation):** `corpus/lessons/round-22.md` does not itemize this entry's old row (`62020ad1…/88/4320`); the exact historic evidence lives in `frozen/before/corpus/stamps.tsv:11` and `build/Entry03.md` §1/§8. Acceptable under "or the commit message"/frozen-snapshot routing, noted for completeness.

## 6. Residual risk and verification gaps

1. Host-state values cited in §3 come from the build-wave audit (advisory per contract); independent re-measurement was out of bounds this wave. When the substrate returns, the erratum's own recheck trigger governs.
2. Whether the two `allowed_origins` IDs and the `the-musketeer` default remain correct for the installed 1Password beta is vendor-side, unmeasured, and unasserted by the erratum.
3. The parent's single global revision-audit rerun must confirm the fleet-wide `stale:0 / added:6 / dropped:0` expectation; this report covers only this path's slice (row updated, membership preserved, contributes stale:0 for this path).

## Provenance

- Manifest: `kagi-shokunin/.ufo/waves/round-22/integration-manifest.json` (base `c2cab35bc92e57e39e5489bac3386db078345b3f`; entry input `d6833b54…/100/5023`).
- Landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` "round-22: feature-bound review capability and audited revision repairs" — worktree file equals this commit's blob (`d6833b54…`).
- Checks parent should run after integration (not mine to run): `bash corpus/claim-ledger.sh verify` (expect R11-01/R11-02 deferred), `bash corpus/claim-ledger.sh docs` (this entry declared+pinned), global revision audit once, `git diff c2cab35..8ada17a -- corpus/knowledge/cdp-bridge-1password.md` to re-see the pure append.
