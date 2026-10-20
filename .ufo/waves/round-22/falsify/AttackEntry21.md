# AttackEntry21 — falsification of integrated C2 for `corpus/knowledge/surface-census.md`

Seat: reviewer, leaf member (no subagent dispatch). Date 2026-10-20.
Axes: **calibration** (does the integrated correction mark every false reading without laundering?) and
**freshness** (pointer integrity vs substantive source facts).
Read revision: lane tip `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (verified `git rev-parse HEAD` = this hash;
worktree clean except `.ufo` falsify-wave files: `falsify-spec.json` modified, `falsify-dispatch.json`,
`falsify-start.json`, `falsify/`, `safe-row-plan.json` untracked — no production input touched since landing).
Historical BEFORE base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
No host gate run (`surface-census.sh`, `drift-pins.sh`, `claim-ledger.sh` never executed). No installs. No live
vault/account/loopback/package operation. Writes: this report only.

## Admissibility verdict (single)

**ADMIT** — the integrated round-22 change to this entry is an append-only erratum that marks every identified
false reading, keeps all historical prose verbatim, updates the stamp record in the same commit with the old/new
tuple preserved in a committed journal, and never promotes pointer integrity to source currentness.

## 1. Identity chain (observed, byte-level)

| item | value |
|---|---|
| frozen-before blob (git `c2cab35:corpus/knowledge/surface-census.md`) | `e07750f1c61e793344816d95a8ba9269975b71292c28a0644c70bf18ba64247f`, 287 wc-lines, 19435 bytes |
| frozen-before stamp row (`frozen/before/corpus/stamps.tsv:29`) | `corpus/knowledge/surface-census.md  e07750f1…647f  287  19435` |
| frozen-before `stamps.tsv` sha | `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b` — `diff` vs base blob: **identical** |
| frozen-before `claim-ledger.tsv` sha | `8a4019cfc1eec916f30a8958fbc3ca2d30e59632e0f1d5d843cea6d1c24faa97` — `diff` vs base blob: **identical** (both also match `frozen/before/expected.json` digests) |
| current file | `2b41318543977eb1c1fd1f185bba0c28e27bff321f18644e83c9a51a46d04afc`, 305 wc-lines, 20533 bytes |
| current stamp row (`corpus/stamps.tsv:32`) | `corpus/knowledge/surface-census.md  2b413185…4afc  305  20533` |
| current `stamps.tsv` sha | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (69 rows) — matches `integration-manifest.json` entry |
| integration landing snapshot | `8ada17a` blobs of the doc and `stamps.tsv` hash identically to the worktree (`git show 8ada17a:… \| sha256sum`), and `git diff 8ada17a..HEAD` is empty — falsification input = landing, not a mid-build state |

**Unchanged-prefix proof:** `cmp -n 19435` base-blob vs current file → **exit 0** (first 19435 bytes identical).
The edit is exactly `+1098 bytes` appended after the base end; base file lacked trailing newline (`.` last byte),
current erratum also ends without one ("…this round.", `od` verified). Current file has 306 grep-lines / 305
wc-lines; base 288/287 — consistent with one mid-file newline gain (the `\ No newline at end of file` fix on the
final base line) plus 18 added content lines. The `stamps.tsv` line/byte fields (305/20533) were computed with the
gate's own `wc -l`/`wc -c` convention (`claim-ledger.sh:282-283,1177`), so they are reproducible, not invented.

## 2. What changed (git diff base..HEAD, this file only)

`+19/−1` on the last hunk (base 285–288 → current 285–305). One deletion = the pre-existing final line's missing
newline; additions = one blank-line pair plus an appended block only:

```
## Erratum (round 22 — static declarations versus historical host results)
Source-status: historical — the original host CLEAN summaries, child counts,
file modes/lines and runtime observations above were not remeasured here. …
```

Appended-region sha256 (`tail -c +19436`): `103c22b5d3053f55828434057cb880f153be705a24e934b368b309f820478ef8`.
Nothing else in the 287-line base body moved — the round-10 header, `Gates observed this round`, `Why this gate
exists`, §Bounds, the Falsification list and the `Reverify:` line are all inside the proven-identical prefix.

## 3. Stamp-record reconciliation

| aspect | observation |
|---|---|
| path present at base | yes (`frozen/before/corpus/stamps.tsv:29`); also at `e1544c194fddf1bb073b3946847b4526f326ad73:29` — the path was **not** among the nine replaced lines of the round-21 span |
| membership set base→current | **63 → 69 members; added exactly 6** (`feature-claims.json`, `feature-claims.py`, `knowledge/feature-bound-credential-review.md`, `lessons/round-21-verifier-spotcheck.md`, `lessons/round-22.md`, `revision-audit.py`); **removed 0; duplicates 0** |
| this entry's tuple change | `e07750f1/287/19435` → `2b413185/305/20533`, recorded in `pin-migrations-integration.json` (path at line 315) with `base_observed {sha256,287,19435}` matching the base blob and disposition "Reviewed current round-22 artifact; historical source facts remain historical" — migration evidence is exact, not laundered |
| same-commit coupling | `git log c2cab35..HEAD -- surface-census.md stamps.tsv` shows exactly one commit, `8ada17a` — doc bytes and stamp row moved together, no orphan stamp or unpinned doc state |
| count expectation | `R12-03` migrated `^63$` → `^69$` with old/new preserved in the same journal — the observed 69-row file is the documented expectation, not a silent rewrite |
| stale-state check | the six stale base rows (`config-layering`, `handler-on-disk-state`, `handler-trust-boundary`, `janitor-env-contract`, `lessons/round-18`, `LOG.md`) were restamped in the same journal; **this entry was never in the stale set** — restamping it would have been laundering; it was restamped only because its bytes genuinely changed |

## 4. Correction coverage vs build/Entry21.md (advisory snapshot; re-proven here)

Entry21 reported eight substantive findings B1–B8. I re-verified the source values myself at the integrated tip:

| # | Entry21 finding | integrated-state proof | erratum coverage |
|---|---|---|---|
| B1 | L5 state-shape split `9 sqlite / 9 json /…` self-contradictory; actual 9/8/3/1/1 | current `state-shape.tsv`: 22 rows, kinds 9 sqlite/8 json/3 log/1 lock/1 marker | "state-shape introduction's JSON subtotal … superseded by the actual committed TSVs; the first subtotal was internally inconsistent" |
| B2 | L32 `19 symbol pins` → 20 | current `drift-symbols.tsv` non-comment rows = **20** (sha `dca651da…` unchanged since base — same value Entry21 measured) | "old symbol-pin total … superseded" |
| B3 | L76 `16 published hashes` → 9 of 15 | current `drift-baseline.tsv` = 15 rows, **9** sha256 fields (two independent count methods; sha `90c2d7a5…` unchanged since base) | ""16 published hashes" phrase … unsupported" |
| B4 | verbs vocabulary gained `DEGRADED`, exit 1 | `surface-census.sh:880` prints `SURFACE_CENSUS_VERBS: DEGRADED (pass=0 skip=%s)` (sha `275d8294…` unchanged) | "The verbs interface also has DEGRADED (exit 1)" |
| B5 | selftest omits r18 substrate-absent skip of verb cases | `surface-census.sh:821,823` `skip-case … substrate-absent (handler not on PATH)` | "its absent-substrate selftest branches explicitly skip the unavailable verb cases" |
| B6 | dropped-required-table falsifier is case 11, not "selftest 10" | L280 original sentence left verbatim; `claim-ledger` R11-03 note carries "since round 18" anchor | "The dropped-required-table falsifier is the named required-table case, not the unavailable-SQLite case. Do not use a helper ordinal as its contract." |
| B7 | blanket "one third" floor derivation false (12/20=0.60, 16384/33687≈0.49) | base `state-shape.tsv:14-16` sentence retained as history; **owning file also corrected**: 5 comment lines appended (`abf9ca14…`), "No active assertion/value changed" — data rows untouched | "The blanket "one third" floor policy is withdrawn: per-row declared floors are authoritative and some table/size floors use different bounds" |
| B8 | `~/.config/opencode` 20 children → 3 at base; host-state, unverifiable now | no host probe performed (boundary) | "the original host … child counts … were not remeasured here. Substrate deferral is an explicit unavailable check, not a current pass." — marks the class without asserting a new host count |

Entry21's C-list "checked and correct" items (`Reverify:` ids R11-01/02/03/10/11 resolving in the ledger; case-10
`UNVERIFIED` description; 16-case selftest total) required **no** edit — verified: all five R11 rows are byte-identical
base→current, and the erratum adds no `Reverify` id, so no citation-chain hazard was introduced.

**Pointer freshness vs unavailable source facts:** the erratum correctly treats the doc's 2026-09-28 host CLEAN
summaries, live line/byte counts, child counts and runtime observations as *historical facts that are unavailable
for re-measurement* (substrate deferred), not as facts contradicted by a hash. It never claims any of them is
currently true or currently false — only unremeasured. Conversely the three static-declaration errors (B1/B2/B3)
are adjudicated against committed TSVs, which are available facts. That is the required split, correctly drawn.

**No laundering:** zero historical sentences rewritten; zero stamp members deleted (63→69, added-only, all six
additions are this round's own new artifacts); the superseding values are the *base-observed* TSV facts Entry21
measured (not newly invented numbers); the stamp update is journaled with both tuples; no live gate output was
fabricated (the erratum states "No live census or private-state read occurred in this round").

## 5. Limits and residual risk

- The false sentences remain in the body by design (append-only round contract); a reader stopping before L290
  still reads superseded numbers. Mitigated by the erratum's explicit "superseded" wording and by the
  `state-shape.tsv` header comment pointing back to this erratum. Accepted residual, not a defect under the plan.
- Erratum wording "some table/size floors use different bounds" is qualitative; per-row floors remain the
  authority, so no numeric restatement was needed.
- B8's live count stays unverifiable on this host; the erratum deliberately asserts nothing about it. Correct.
- Build-wave artifact (Entry21.md) was treated as advisory; every value it claims that this report uses was
  independently re-derived at the integrated tip (hashes, counts, script lines). No mid-build snapshot was trusted.
- `git status` shows five uncommitted `.ufo` falsify-wave paths; no production input is modified relative to
  `8ada17a` — the freeze held during this seat's window.
- Per contract, the global single rerun of `revision-audit` is the parent's duty; this seat did not run it.

## 6. Parent checks after integration (unchanged from build wave, plus this audit)

- `sha256sum corpus/knowledge/surface-census.md` → expect `2b413185…`; `wc -l -c` → 305/20533; compare `corpus/stamps.tsv:32`.
- `bash corpus/claim-ledger.sh stamps` (row must match new bytes), `bash corpus/claim-ledger.sh docs` (R14-01 expects 25/22/3).
- `grep -c '[^[:space:]]' corpus/stamps.tsv` → 69 (R12-03).
- Do **not** run `corpus/surface-census.sh` / `drift-pins.sh` on this host (substrate deferred; only `GONE`/`FAILURES` producible).
- Parent-only: run `corpus/revision-audit.py` once globally and compare to manifest `expected.revision_audit {added 6, dropped 0, invalid 0, missing 0, stale 0}`.

— AttackEntry21 (reviewer, Kagi round 22 falsify wave)
