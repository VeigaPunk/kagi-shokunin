# FAnchorHuge — round-28 falsify: derived S008 anchor, 4301-digit patch

**Verdict on the assigned carrier** (pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`): **PASS** — a derived-S008 anchor whose patch component is 4301 digits becomes a typed finding, exit 1, no traceback, no fired verdict written, and the finding is the specific `NON-CANONICAL` category (not a generic `RECEIPT-MISMATCH`).
Two adjacent-path defects (F1, F2) are recorded; neither changes this carrier's verdict. Repair `5e847472` (ancestor of 62a33b1 confirmed: `git merge-base --is-ancestor 62a33b1 5e847472` → exit 0) already changes both.

## Setup (isolated, no network)

- Exported trees via read-only `git archive 62a33b1` / `git archive 3553d499` → `/fast/scratch/hyaku/kagi-r28/FAnchorHuge/{cand,base}`; fixture roots staged per case under `<scratch>/work/`. Lane checkout untouched.
- `--observe` cases drove the module's own `request_body`/`utc_timestamp` stubs (the substitution `release-clock.py`'s own selftest uses) → no network.
- Receipts: pinned default `.ufo/waves/round-26/observe-2.json` (sha `13b8540c…a169` = `DEFAULT_RECEIPT_SHA256`) copied verbatim into each fixture root; cases needing a changed receipt used `--receipt <copy> --receipt-sha`.

## Commands run

1. `python3 harness.py` (scratch) — exit 0; BASE vs candidate, 6 cases each.
2. `python3 harness2.py` (scratch) — exit 0; candidate-only variants (G1–G6, H1–H3, I1–I2).
3. `python3 harness3.py` (scratch) — exit 0; bound-precision probes (P1–P7).
4. `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0 FAnchorHuge-cand <scratch>/c1-cand.json` — exit 0 → `C1_MEASURE FAnchorHuge-cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True`.
5. same with `3553d499577084a6c98d7078906017840bbf7b28` → exit 0 → `mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True`.
6. `python3 harness4.py` — **written but NOT executed** (lane message interrupted the run); nothing rests on it.

## Primary carrier — candidate vs BASE (exact outputs)

Case A = derived S008 `anchored_version` := `3.13.` + 4301×`1`; observation, verdict, note and the pinned receipt untouched.

- Candidate `62a33b1`: exit **1**, stdout `NON-CANONICAL S008` — the **only** finding line (no `RECEIPT-MISMATCH` appears, so the category is the new rule's, not generic receipt drift) — last line `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=14)`; no `Traceback` in stdout+stderr. Produced by `corpus/release-clock.py:617` (`non_canonical = non_canonical_version(anchored) or …`) and `:627-632` (`errors.add(("NON-CANONICAL", source_id))`).
- BASE `3553d499`: exit 1, **traceback**, no finding line: `ValueError: Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits` at `corpus/release-clock.py:380` (`return tuple(int(part) for part in value.split("."))`) via `corpus/release-clock.py:440` (`feed_floors`).

Category isolation (assignment requirement): in case A the receipt is the untouched pinned file and the row's observation is untouched, so `RECEIPT-MISMATCH` was impossible — the single `NON-CANONICAL S008` line can only come from the new rule.

No fired verdict: control `fired=3`; every candidate case `fired=3` (observed 30→29, derived 15→14 — the row is refused, not counted). Forcing the row's verdict to `fired` with the receipt mirrored (H1) still yields only `NON-CANONICAL S008`, `fired=3`.
Observe path (E): receipt record for S008 = `{"verdict": null, "parsed_version": null, "error": "non-canonical version token: row anchor or observation; no verdict written"}` (`corpus/release-clock.py:872`), `fired_written=False`, exit 1, `NON-CANONICAL S008`. Feed-side oversize entry (I1): `"non-canonical version token: feed newest stable entry"` (`:797`), `verdict: null`.
Whole-group variant (C: S008–S011 all lowered to the same huge token): exactly four `NON-CANONICAL` lines (S008–S011), `fired=3`, exit 1 — the group-forgery shape is refused, not silently CLEAN.

## Findings (severity order)

**F1 — medium — a non-canonical OBSERVATION hides a derived-anchor DERIVATION mismatch.** `corpus/release-clock.py:617-619` (candidate) computes `non_canonical = non_canonical_version(anchored) or non_canonical_version(observed_version)` and gates the C2 branch on `not non_canonical`. A derived row whose anchor no longer matches its feed row's anchor cell, but whose *observation* is non-canonical, therefore reports only `NON-CANONICAL`; the `DERIVATION` finding for that row is suppressed. Exit is still 1 (no false CLEAN), so this is category completeness, not soundness. Read from the candidate source and corroborated by the repair diff (`5e847472` changes the guard to `not non_canonical_version(anchored)` and adds the selftest case "bad observation does not hide derived mismatch"). **Not independently executed on 62a33b1** — the masking case is absent from my fixture set.

**F2 — medium — a non-canonical feed entry BELOW the newest canonical entry is silently ignored, not typed.** `corpus/release-clock.py:784-800` (`newest_stable`) keeps only canonical tokens and raises only when a non-canonical token orders at-or-above the newest canonical one; `version_order` (`:409`) compares `(len, digits)` per component, so `3.14.<4301 digits>` orders below `3.15.0` and is dropped with no finding. The candidate's own selftest pins this as expected (`corpus/release-clock.py:1383-1388`, "older oversize entry was not ignored"). A plain reading of plan C1 ("a version token used for … a feed entry must be canonical … otherwise the row or feed gets a typed finding") is not met for that case. Repair `5e847472` replaces `newest_stable` with total feed validation (any non-canonical token → typed refusal) and inverts that selftest. **Source-read, not executed by me**: my case I2 used a *newer* oversize entry (correctly refused with `feed newest stable entry`); the older-entry case was never run.

**F3 — low — a 4301-digit component behind a prerelease suffix is typed, but under other categories.** Anchor `3.13.<4301>-rc1` → `DERIVATION S008` + `INCONSISTENT S008`, not `NON-CANONICAL`, because `non_canonical_version` (`:395`) recognises only strict `X.Y.Z` (`NUMERIC_VERSION_RE`, `:392`) and a suffixed token is "never flagged". Still exit 1, no traceback, no fired verdict — the carrier's requirement holds; only the category label differs from the plain 4301-digit case.

## Not checked / residual risk

- No network: every feed case used a locally stubbed transport, so real-feed behaviour is unexercised.
- Repair `5e847472` was not re-run (lane instruction: keep original candidate results, no broad re-runs); F1/F2 are read from its diff, not measured.
- `harness4.py` (two-/four-component and leading-zero-padded derived anchors, BASE vs candidate) written but never executed.
- C2's canonical whole-feed lowering fixtures G1–G4 and the other seats' carriers were not attacked; my group variant (C) covers only the oversized shape.
- The registry's own canonicality (SOURCES.md anchor cells) was only edited as a fixture (H3); not audited.
- Retained small receipts: `<scratch>/work/{c1-cand,c1-base,results,results2,results3}.json` + the three harnesses; the two exported trees (~214 MB) deleted after the runs. No production file modified; no git/jj mutation, no commits, no lane gates run in the lane checkout.
