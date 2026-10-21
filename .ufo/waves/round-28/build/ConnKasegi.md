# Connector — kagi round 28 × kasegi-shokunin (secret/credential hygiene, version/recheck clocks)

Lane BASE `3553d499577084a6c98d7078906017840bbf7b28`, extracted per contract to `.ufo/waves/round-28/sandboxes/ConnKasegi/base` (kagi paths below are relative to it). Sibling read:
`git -C /home/vgpnk/Projects/shokunin/kasegi-shokunin rev-parse HEAD` → `8bf980721554d2d24bcc83e2e0996e0c27684a06` (2026-10-20, `checkpoint(r23)`); `git status --porcelain` empty
(exit 0). Read-only: nothing written in the sibling.

## Findings (kagi BASE)

1. **C1's F1 fixture does not discriminate BASE from fixed under the default receipt.** `corpus/release-clock.py:444` compares the pinned receipt's `parsed_version` with the row's
   `observed_version` (`:28` pins the default bundle; `:495-499` selects it). Editing only `corpus/release-clocks.tsv:30` (S040 observed `3.15.01`, verdict `fired`) gives
   `RECEIPT-MISMATCH S040`, exit 1 — already TYPED by the plan's predicate. BASE reaches the token logic (`:582`) only with an aligned receipt (`--receipt` + `--receipt-sha`),
   where it prints `CLEAN ... fired=4`, exit 0. F1 is MISHANDLED only in a receipt-aligned construction the frozen text does not state. F2 is unaffected: `:567`→`:386` calls
   `numeric_version` on the raw token *before* receipt matching, so the 4301-digit row tracebacks table-only too.
2. **C2's frozen G fixtures, as written, cannot reach the state their predicate names.** "release-clocks.tsv edits only" — but lowering a derived anchor also changes
   `verdict`/`parsed_version`, so the row fails `:444` first. Measured: G1 (S008–S011) → four `RECEIPT-MISMATCH`, exit 1; G4 (S029) → one, exit 1. "EXACT ... typed derivation
   findings" is unreachable (`RECEIPT-MISMATCH` is not a derivation finding). Receipt-aligned, BASE is `CLEAN`, exit 0 for both: the vulnerability is real, but the harness must
   patch receipts for before `ACCEPTED k/4` and after `EXACT k/4` to be attainable. [INFERENCE] G2/G3 identical.
3. **C1's anchor clause is untested and the derived branch is a live CLEAN-fired path.** Receipt-aligned, derived S013 anchored `2.2.00`, observed `2.2.0`, verdict `fired` →
   `RELEASE_CLOCK: CLEAN ... fired=4`, exit 0. Cause: `:565-566` sets `anchor_ok = is_derived or ...`, so a derived anchor is compared to nothing, and `:582`/`:585` compare strings
   (`2.2.0` ≠ `2.2.00`). Control: the same malformation on non-derived S040 is already typed `INCONSISTENT`, exit 1, via `:566`. No frozen C1 fixture exercises an anchor, so
   C1-alone's "a version token used for an anchor ... typed" is undemonstrated for the derived class.
4. **C1 findings must avoid the one arbitrary-text sink.** Errors print as `(category, id)` only (`:644-646`); `setup()` exits 2, failing the exit-1 predicate. But `:823`
   `receipt["error"] = str(exc)` is the only durable sink for arbitrary text, so an oversize token must be rejected by a length check *before* `int()` and never formatted there.
5. **C2's binding is table-only; a registry edit is invisible to the clock.** Editing `corpus/SOURCES.md:39` (S033 `v3.13.3`→`v3.13.2`) with G1 leaves `CLEAN`, exit 0, even under a
   correct C2. The whole-file pin `corpus/stamps.tsv:8` (`daa3af5e…`) diverges (`8f027bbb…`), so `claim-ledger.sh verify` is the immutability control, not `c2-measure`. "Bound to
   its pinned source" holds inside the gate suite, not for the frozen command alone.
6. **The comparator already exists and passes all 15 derived rows.** `version_is_named` (`:341-346`) is true for 15/15 against their feed row's `anchor` cell (`:88`, `cells[5]`);
   every feed anchor names exactly one strict X.Y.Z (S033/S034/S035 twice; S037/S039 once). Trap: S037's *teaches* cell (`corpus/SOURCES.md:43`) also names `8.23.1` once (vs
   `8.23.0` four times), so a whole-row last-match extractor would false-flag S029; `cells[5]` only.

## Sibling ground and overlap (kasegi `8bf9807`)

- **Registry schema shared; `recheck` semantics are not.** kasegi `corpus/SOURCES.md:5` uses the same 11-column header, `recheck` ∈ {`on-release` 14, `90d` 10, `180d` 6} (kagi:
  30/11/2). kagi *enforces* `on-release` (`release-clock.py:511,518,565-566,871`; QM23 at `corpus/QUALITY.md:120`); kasegi uses it as cadence prose for sources with no feed (S010
  blog, S019 NIST, S022/S030 CNA PDFs, S024 CRA, S025 arXiv — `corpus/SOURCES.md:16,25,28,30,31,36`). Same word, incompatible contracts. C1/C2 neither absorb nor contradict sibling
  ground: C2 introduces `derived:` (kasegi has no such token) and reads only kagi's feed rows. Keep QM23 lane-scoped; a fleet-wide reading would flag 8–14 kasegi rows.
- **Anchor-binding prior art.** kasegi `corpus/instruments/anchorcheck.py:102` (pin regex), `:118-126` `git_show` → `MISSING | RANGE | OK`, `:158-163` verdicts
  `PIN-BROKEN`/`PAST-EOF`/`IN-RANGE(PIN)`: three-valued, revision-pinned anchors — the model for splitting "anchor unreadable" from "value contradicts anchor".
- **Immutability prior art.** kasegi `corpus/QUALITY.md:50` (R8): a corrected anchor is a new `supersedes S### —` row, never an in-place edit. kagi has the practice
  (`SOURCES.md:62`, S036→S039) and a stronger whole-file stamp (`stamps.tsv:8`) but no per-row digest; nothing needs importing, and the round should cite the stamp as its control.
- **Recheck prior art.** kasegi `corpus/instruments/source-recheck.py:22-23` closed-shape `fullmatch` admission, `:70-150` per-id `OK`/`MISMATCH`/`UNAVAILABLE`, exit 2 uncheckable
  vs 1 failed — the separation kagi already has (`SetupError` exit 2 vs `errors` exit 1).
- **Secret/credential hygiene.** Sibling ground is documentation only: regex at `corpus/knowledge/claim-gates.md:43-48` over package text, receipts at
  `corpus/knowledge/claim-package-contract.md:13`; no executable exists in `corpus/instruments/` (grep: 0 hits). kagi's live guard is another layer: `path_carries_secret`
  (`:155-172`) and `valid_public_https_url` refusing any query string (`:176-211`). C1/C2 add no outbound fetch (F3/F4 local feed copy; C2 local files), so no absorption or
  contradiction — consistent with both PROVINCE Adjacent clauses (kagi: kasegi's tripwires are hygiene filters, not vault ops; kasegi: kagi owns secrets and vault handling).

## Proposed move (one, bounded)

**Judge derived anchors with the existing comparator, and run C1's canonicality on `anchored_version` before the `is_derived` branch.**

1. One shape predicate, no new column: canonical iff `^v?[0-9]+(\.[0-9]+)*$` (numeric-shaped), no multi-digit component has a leading zero, components are ≤ a fixed digit bound
   checked by length *before* `int()`; non-numeric shapes (`v1.21.x`) stay QM25's declared limit, never typed.
2. Apply it to `anchored_version` for every feed row at `:565` before `is_derived`, and at the observation guard `:577` and parsed feed entry `:760`.
3. In the derived branch, replace the unconditional `true` at `:566` with `version_is_named(feed_source["anchor"], anchored)` on `cells[5]` (`:88`), new category carrying row id +
   feed row id; split that from "anchor names no strict X.Y.Z" (unlocatable, names the feed row), mirroring kasegi's three-valued anchor verdict.

Non-obvious because it turns the existing "derived ⇒ skip" bypass into the comparison that already has the needed boundary/v-prefix semantics (measured 15/15), closes the measured
CLEAN `fired=4` path *neither* frozen fixture set reaches, and avoids a second naming rule that would disagree with `:566` on the first series anchor.

## Axes, risks, verification

- **Axes.** Freshness ↑: the anchor clause becomes executable; a malformed derived anchor can no longer produce a release event. Calibration ↑: C2's exactness gets a defined
  comparator and a distinct "unlocatable" outcome, so `EXACT` measures value contradiction, not source absence. Contract neutral (no new column; `cells[5]` fixed by `:88`).
  Verification unchanged.
- **Risks.** (i) Blanket "anchor must be strict X.Y.Z" would type S012's legitimate `v1.21.x` (`release-clocks.tsv:9`, currently `fired`) and break the control `CLEAN ... fired=3
  derived=15` — hence numeric-shaped tokens only. (ii) Re-pinning after a new release now also needs a new/superseding feed row; document it (S036→S039 is the precedent) or re-pins
  look like calibration regressions. (iii) Selftest growth stays bound by SC/PV-CLOCK-SELFTEST.
- **Verification (to run, not run here).** Receipt-aligned frozen fixtures: F1 before CLEAN fired=4 → after typed, no traceback; G1–G4 before CLEAN → after exactly their ids;
  control still `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0. Local probes: derived anchor `2.2.00` + observed `2.2.0` + fired; feed anchor
  `2.7.x`. Mutation: placing canonicality after the `is_derived` branch reproduces this round's CLEAN fired=4.

## Commands run (sandbox copies only; lane checkout and sibling untouched)

| command | exit | result |
|---|---|---|
| `python3 -I -B corpus/release-clock.py` (BASE) | 0 | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| F1 table-only `3.15.01`, default receipt | 1 | `RECEIPT-MISMATCH S040` |
| F1 receipt-aligned | 0 | `CLEAN ... fired=4` |
| F2 table-only, 4301-digit observed | 1 | `ValueError` traceback at `:380` via `:567`/`:386` |
| `parse_latest_version` on round-26 captured feed | 0 | baseline `3.15.1`; `Python 3.15.01` → parsed `3.15.01`, fires; 4301-digit → `ValueError` |
| malformed anchor, non-derived S040 | 1 | `INCONSISTENT S040` |
| malformed anchor, derived S013 `2.2.00` | 0 | `CLEAN ... fired=4` |
| G1 table-only; G1/G4 receipt-aligned | 1; 0 | `RECEIPT-MISMATCH S008 S009 S010 S011`; `CLEAN` each |
| V1 registry anchor lowered + G1 | 0 | `CLEAN`; `SOURCES.md` sha `8f027bbb…` vs pin `daa3af5e…` |
| 15-row comparator probe; sibling reads | 0 | 15/15 `version_is_named`; HEAD `8bf9807…`, clean tree |

## What I did NOT check

No lane gate/selftest in the lane checkout; no `claim-ledger.sh verify` or `sources-census.sh`, so STALE is inferred from the digest; no feed fetched (F3/F4 used the committed
round-26 body); no kasegi history beyond HEAD (`.jj` unread); redaction-receipt semantics not verified against kasegi's lost `ops/claim-check.mjs`; G2/G3 inferred; `--observe` not
run end-to-end (`run_observe` has no local-file hook; F3/F4 measured at `parse_latest_version`); no installs.
