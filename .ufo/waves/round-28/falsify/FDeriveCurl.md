# FDeriveCurl — round-28 C2 carrier G4 (curl feed S037, row S029) — falsification

**Verdict: PASS** (candidate 62a33b1 refuses the single lowered curl derived row with a typed
`DERIVATION S029` finding; BASE accepts the same forgery silently). No counterexample found.

## Carrier and method
- Carrier: §C2 fixture **G4** — feed `S037` (curl), the single author-declared `derived:` row
  `S029` (`corpus/release-clocks.tsv:26` at the candidate commit), lowered to a lower canonical
  version with `observed_version` equal and `verdict=not-fired`.
- Isolation: exported trees only — `git archive 62a33b1…` → `<sb>/cand`, `git archive 3553d49…`
  → `<sb>/base` (read-only git; the lane checkout was never executed in). Heavy trees (229 MB) were
  moved to `/fast/scratch/hyaku/kagi-r28/FDeriveCurl/` and deleted after the runs; only the small
  scripts/JSON receipts remain under `.ufo/waves/round-28/sandboxes/FDeriveCurl/`.
- **No network.** Every run used `--receipt <copy> --receipt-sha <sha256>`; `--observe` was never
  used. My fixture was built independently of `.ufo/waves/round-28/tools/c2-measure.py`; the lane's
  frozen instrument was run afterwards only as corroboration.

## Exact candidate code under test
- `corpus/release-clock.py:618-625` — C2 gate; `:625` `errors.add(("DERIVATION", source_id))`.
  Condition: `is_derived and not non_canonical and feed_source is not None and not
  derived_anchor_bound(feed_source["anchor"], anchored)`.
- `corpus/release-clock.py:345-346` `STABLE_TOKEN_RE`; `:349-363` `derived_anchor_bound`
  (`:363` `set(STABLE_TOKEN_RE.findall(feed_anchor)) == {norm_version(anchored)}`).
- `corpus/release-clock.py:712-719` `print_result` prints `"%s %s" % (category, row_id)`.
- `corpus/release-clock.py:475-505` `receipt_matches` — the receipt's `parsed_version` must equal the
  row's `observed_version`, which is why a table-only edit degenerates to `RECEIPT-MISMATCH`
  (generic, and *not* proof of the new rule).
- Data: `corpus/SOURCES.md:43` — S037's located anchor cell names exactly one stable token
  (`8.23.0`); `corpus/release-clocks.tsv:26` — S029 (`feed_source_id=S037`, note `derived: …`).

## Commands and exit codes (all in the exported trees, offline)
1. `python3 harness.py` (my own G4 fixture builder + runner) → **exit 0**; inner runs:
   - candidate, G4 lowered to `8.22.0`, receipt mirrored → **exit 1**, stdout exactly
     `DERIVATION S029` + `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29
     fired=3 derived=14)`; no `Traceback` in stdout/stderr; **no file written** (fired count stays
     3, `derived` 15→14, `observed` 30→29).
   - candidate, G4 lowered to `8.10.0` (independent value), receipt mirrored → **exit 1**, same
     single finding `DERIVATION S029`.
   - **BASE 3553d49**, same fixture → **exit 0**, `RELEASE_CLOCK: CLEAN (… observed=30 fired=3
     derived=15)` → the forgery is silently accepted at BASE; the new rule is what refuses it.
   - candidate, G4 lowered **without** receipt mirroring → **exit 1**, `DERIVATION S029` **and**
     `RECEIPT-MISMATCH S029`; BASE in the same shape → **exit 1** with only `RECEIPT-MISMATCH
     S029`. Confirms the typed line is not the generic receipt mismatch.
   - control (unmodified tree, default receipt): candidate **exit 0** CLEAN, BASE **exit 0** CLEAN.
2. `python3 probes.py` → **exit 0**; probes P1–P5 (below).
3. Frozen instrument (corroboration, not sole evidence):
   `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0
   FDeriveCurl-cand <sb>/c2-cand.json` → **exit 0**, `groups_accepted_clean=0/4
   derivation_exact=4/4 control_clean=True`; its `G4` record: `exit 1`, findings `["DERIVATION
   S029"]`, category `DERIVATION`, `named_ids ["S029"]`, `edited_rows ["S029"]`.
   Same tool on BASE → **exit 0**, `groups_accepted_clean=4/4 derivation_exact=0/4`.
4. Selftests in the exported trees: candidate `python3 -I -B corpus/release-clock.py --selftest` →
   **exit 0**, `PASS (106 cases)`; BASE → **exit 0**, `PASS (79 cases)` (27 new cases).

## Falsification attempts that failed to break the rule
- **P1 — is it really bound to the pinned cell, or hardcoded?** Rewrote S037's anchor cell to name
  `8.99.0` and lowered S029 to `8.99.0` → candidate **exit 0** CLEAN. The rule reads the registry
  cell (QM21-style binding), not a constant; BASE behaves identically here (CLEAN).
- **P2 — bypass by dropping the `derived:` prefix** (note `provenance: …`, row lowered to 8.22.0):
  → candidate **exit 1**, typed `INCONSISTENT S029` (S029's own cell names 8.23.1) — no silence.
- **P3 — cell naming two stable tokens** (`8.23.0` + prior `8.22.0`), row untouched → candidate
  **exit 1**, `DERIVATION S029` (a cell naming two versions binds none). See R1 below.
- **P4 — lower to 8.23.1** (curl's man-page/dev label) → **exit 1**, `DERIVATION S029`.
- **P5 — false-positive check**: legitimate fired row (anchored `8.23.0` still bound to the cell,
  observed `8.24.0`, `verdict=fired`) → **exit 0** CLEAN, `fired=4`. The new rule does not block a
  real release event.

## Findings (severity ordered)
1. **LOW / residual risk — trip-wire on corpus edits.** `corpus/release-clock.py:363` requires S037's
   anchor cell to name exactly **one** stable X.Y.Z. If a future round adds a second version to
   that cell (P3), the *untouched* S029 row flips to `DERIVATION` and the whole clock fails with no
   forgery present. Fail-closed and safe, but it couples clock health to registry-cell wording.
2. **LOW / workflow coupling.** A genuine new curl release is only accepted while S037's anchor cell
   still names the row's anchored version (P5); the registry row must be refreshed in the same
   change, or the clock reports `DERIVATION` instead of `fired`.
3. **INFO — the frozen instrument's mirroring is load-bearing.** Without mirroring the edited row
   into the receipt copy, BASE already fails with `RECEIPT-MISMATCH`; that generic signal must not
   be read as evidence of the C2 rule (my mirrored run is the discriminating one).

## What I did NOT check
- No network, no `--observe` path (out of scope); no C1 (non-canonical token) carriers — other seats.
- G1–G3 fixtures (SOPS/Vault/OpenBao) not rebuilt independently; the frozen instrument's aggregate
  `4/4 exact` was read, not re-derived. Lane gates other than the clock selftest (`round-conformance.py`,
  `separability.py`, `c1-measure.py`), the ledger pins and the round-28 bookkeeping were not audited.
- No production file was modified; nothing was committed; the lane Git index/jj state untouched.

## Receipts
`harness.py`, `probes.py`, `results.json`, `probe-results.json`, `c2-cand.json`, `c2-base.json`,
`harness-rerun.log`, `probes-rerun.log` under `.ufo/waves/round-28/sandboxes/FDeriveCurl/`
(scripts re-extract the trees read-only via `git archive`; heavy trees deleted at completion).
