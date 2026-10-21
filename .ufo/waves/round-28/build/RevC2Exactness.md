# RevC2Exactness — C2 exact-match predicate for `version_is_named` (BASE 3553d49)

Scored on: freshness, calibration. All paths/lines at BASE `3553d499577084a6c98d7078906017840bbf7b28`.

## F1 — HIGH: `version_is_named` is a **containment** test, not exact-match; it accepts prefixes/suffixes
`corpus/release-clock.py:341-346` builds `r"(?<![A-Za-z0-9.])v?%s(?![A-Za-z0-9.])"` — boundary class `[A-Za-z0-9.]`, `re.search` (substring), `re.IGNORECASE`. Measured
(`/tmp/probe7.py`, exit 0):

| anchor | query | result | correct? |
|---|---|---|---|
| `v3.13.30` / `v3.13.3` | `3.13.3` / `3.13` / `3.13.3.1` / `3.13.30` | False | OK digits and `.` are inside the boundary class |
| `v3.13.3-rc1` | `3.13.3` | **True** | LEAK `-` OUTSIDE class |
| `v3.13.3+build.1` | `3.13.3` | **True** | LEAK `+` outside it |
| `v3.13.3_rc1` | `3.13.3` | **True** | LEAK `_` outside it |
| `sdk/v0.26.0` | `0.26.0` | **True** | LEAK module tag, not the release |
| S037 anchor cell | `2026-12-09` | **True** | LEAK a **date**, not a version |

Answer to the assignment: **yes, it accepts prefixes/suffixes.** `3.13.3` vs `3.13.30` is safely rejected (both directions — digits/`.` are inside the class), but
`v2.2.0-rc1` binds the query `2.2.0`. It is a substring test, so it can never express "the anchored version **is** the version the feed names". **C2 must not use it.**

## F2 — HIGH: the target must be the FEED row's anchor cell, not the clock row's own anchor
`corpus/release-clock.py:566` reads `anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)` — `source_id` is the *clock* row (S008…), and the
`is_derived or` short-circuit exempts all 15 derived rows from any check. That short-circuit is the hole C2 closes. Binding to the clock row's own anchor cannot work —
measured (`/tmp/probe6.py`, exit 0) **all 15 derived rows fail** `version_is_named(own_anchor, anchored)`: S008–S011/S013–S016/S021/S023–S026 own anchors name **no
version** (`corpus/SOURCES.md:14-17,19-22,27,29-32`; S008 = `'§Documentation; upstream `main` snapshot opened 2026-10-19, no commit/version displayed'`); S022's names
`1.17` (`SOURCES.md:28`); S029's names `8.23.1` — the **unreleased DEV label** (`SOURCES.md:35`) — while the row anchors `8.23.0`. The feed row's anchor cell is correct
and **already loaded**: `corpus/release-clock.py:88` `"anchor": cells[5]` (SOURCES.md col 6), present for S033–S037 (`SOURCES.md:39-43`) — no new file or parse.
Anchor-cell token sets (all singletons): S033→{3.13.3} S034→{2.2.0} S035→{2.7.1} S036→{3.15.0} S037→{8.23.0} S039→{3.15.1}.

## F3 — HIGH: the exact-match predicate C2 needs
Whole-token equality against the feed row's anchor cell, reusing the module's own `VERSION_RE` (`corpus/release-clock.py:30-33` — whole-token capture, `[-+]` suffix group
kept, `v?` stripped). `VERSION_RE` is **dead code at BASE** (`grep -nE "VERSION_RE\\."` matches only `NUMERIC_VERSION_RE` `:378` and `TEXT_VERSION_RE` `:727`) — reuse it
rather than adding a fifth near-duplicate version regex.

```python
def anchor_versions(anchor):   # whole tokens; suffixes kept, no partials
    return {norm_version(m.group(1)) for m in VERSION_RE.finditer(anchor or "")}

def derived_anchor_is_bound(feed_anchor, anchored):
    """True iff `anchored` is exactly the version token named by the feed anchor."""
    if not anchored or anchored == "-":
        return False
    named = anchor_versions(feed_anchor)
    if len(named) != 1:          # unambiguous: exactly one version named
        return False
    return norm_version(anchored) in named
```

Four properties, each measured: **(1)** no prefix/suffix leakage — `3.13.30`, `3.13.3-rc1`, `3.13.3+build.1`, `sdk/v0.26.0`, `2026-12-09` are absent from the token set;
**(2)** string equality, never numeric — `numeric_version('3.13.03') == numeric_version('3.13.3')` is **True** (`:369-380`), so a numeric compare silently accepts a
leading-zero token and destroys C1's canonicality distinction; **(3)** no `int()`, so no traceback — `numeric_version("3.15."+"1"*4301)` raises `ValueError: Exceeds the
limit (4300 digits)` (CPython limit 4300), inheriting C1's traceback defect; **(4)** the singleton guard makes the binding unambiguous — all six current feed anchor cells
name exactly one version, so it costs nothing today and stops a future multi-version anchor cell binding arbitrarily.

**Scope: `derived:` rows only** — BASE's marker is `corpus/release-clock.py:565` `is_derived = values["note"].startswith("derived:")`. Applying the rule to *every* feed
row breaks the control: S012 (`corpus/release-clocks.tsv:9`, `fired`, non-numeric anchor `v1.21.x`) → measured `DERIVED-ANCHOR-MISMATCH S012` + `INCONSISTENT S012`, exit
1, `observed=29 fired=2`. Leave S012/S027/S028/S040/S041 on `version_is_named` against their own anchor cell. Separately, `norm_version` (`:362`) strips only a leading
`v`, so compare `norm_version(anchored)` on **both** sides: `VERSION_RE`'s capture group excludes the `v?` prefix, so tokens are bare while a row's anchored cell may
carry `v` (`corpus/release-clocks.tsv:9` anchors S012 at `v1.21.x`). All 15 derived rows are currently bare (`3.13.3`, `2.2.0`, `2.7.1`, `8.23.0`), so this is defensive
only.

## F4 — HIGH: the frozen G1–G4 fixtures need a regenerated receipt, or they measure the wrong finding
The fixture edits `release-clocks.tsv` only, but the pinned default receipt `.ufo/waves/round-26/observe-2.json` (`DEFAULT_RECEIPT_SHA256`, `corpus/release-clock.py:28`)
keeps the old `parsed_version`; `receipt_matches` (`:425-455`) compares it to the row's `observed_version`. Lowering the observation without regenerating the receipt
yields **`RECEIPT-MISMATCH`**, not the derivation finding. Measured (`/tmp/probe13.py`, exit 0), G1 with the pinned receipt: `RECEIPT-MISMATCH S008 / S009 / S010 / S011`
then `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)`. Round 27 already solved this:
`.ufo/waves/round-27/tools/c2-measure.py:64-67` rewrites `parsed_version`/`verdict` in the receipt for the edited ids before invoking the clock. **The round-28
`c2-measure.py` must do the same** or the frozen "ACCEPTED k/4 → 0/4, EXACT → 4/4" predicate is unmeasurable.

## F5 — MEDIUM: the lowered fixture token must be strictly lower than every other row's observation on that feed
`feed_floors` (`:390-411`) takes the feed's **max** numeric anchor; `is_regression` (`:383-387`) compares each observation against it. Measured at BASE
(`/tmp/probe14.py`, exit 0), G2 group: `2.1.9`/`2.1.0` → CLEAN; `0.26.0` → CLEAN (but see F6); **`2.3.0` → FAILED `REGRESSED`** (S012's observed 2.2.0 now below the
floor); **`2.2.0-rc1`/`1.21.x` → FAILED `INCONSISTENT`** (non-numeric). The installed tokens `3.13.2 / 2.1.9 / 2.7.0 / 8.22.0` (XC2Measure-7) satisfy this. "Merely lower"
is not enough.

## F6 — MEDIUM: the lowered fixture token must be absent from the whole registry row, not just the anchor cell
`0.26.0` is CLEAN at BASE (F5) because S034's **teaches** cell (`corpus/SOURCES.md:40`) names `sdk/v0.26.0`; an implementation reading the whole row would find it "named"
and the fixture would stop discriminating anchor-cell binding from row scanning. Measured (`/tmp/probe11.py`, exit 0): `version_is_named(S034 teaches,'2.2.0')=True
;('2.2.0-rc1')=True ;('0.26.0')=True` (module tag); `VERSION_RE tokens of S034 teaches cell = ['0.26.0','2.2.0','2.2.0-rc1']` vs `VERSION_RE tokens of S034 ANCHOR cell =
['2.2.0']` (binding target). Binding to `cells[5]` **only** (`:88`) is what makes `0.26.0` and `2.2.0-rc1` non-binding — and matches ConnChousa's risk note: no
`S033-S037` anchor cell carries `-rc`/`-DEV` (those live in S034's teaches cell and S029's row note), so an edge rule outside the anchor cell would false-reject.

## F7 — MEDIUM: the finding-category token is not agreed across the wave
Two incompatible tokens are already in flight for the same finding: `DERIVED-ANCHOR` (RevObserveC2 `sandbox/.../proto_c2.py:57`,
`.../work/vA/corpus/release-clock.py:593`) vs `DERIVED-ANCHOR-MISMATCH` (RevC2Fixtures `sandbox/.../draft/release-clock.py:570`). Neither exists in production at BASE
(`grep -rn "DERIVED-ANCHOR" --include="*.py"` → round-28 sandboxes only). The frozen predicate is written in terms of *which row ids* the finding names, so either
satisfies it — but L1 must pick one and `c2-measure.py` must grep it. Recommend `DERIVED-ANCHOR` (matches the `NONCANONICAL`/`OVERSIZE` style ConnChousa proposes for C1).
Note round 27's precedent (`corpus/lessons/round-27.md:176`): `REGRESSED` is also emitted by another lane's `anchor-truth.mjs`, so a fleet grep must key by lane, not
token alone.

## Verification performed
Sandbox `.ufo/waves/round-28/sandboxes/RevC2Exactness-7/`, BASE tree via `git archive`, sha256 `53823416…a136dc` = BASE blob. No lane production file written by me; no
lane git/jj state touched.

| command | exit | result |
|---|---|---|
| `git show 3553d49:corpus/release-clock.py \| grep -n …` | 0 | line citations above |
| `python3 -I -B corpus/release-clock.py` (BASE) | 0 | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| `python3 -I -B corpus/release-clock.py --selftest` (BASE) | 0 | `PASS (79 cases)` — matches ledger R25-03 |
| `python3 -I -B /tmp/probe7.py` (boundary semantics) | 0 | F1 table |
| `python3 -I -B /tmp/probe14.py` (counterexamples, fixture values) | 0 | F5/F6 data |
| `python3 -I -B /tmp/probe17.py` (BASE vs patch, 4 groups) | 0 | BASE CLEAN x4; patch `DERIVED-ANCHOR` exact x4, no other findings |
| `python3 -I -B corpus/release-clock.py` (patch2/3/4) | 0/1 | control CLEAN; patch4 (over-broad) -> `DERIVED-ANCHOR-MISMATCH S012` |

Reference drafts `patch2/` (singleton guard + `is_derived` gate + `DERIVED-ANCHOR`) and `patch3/` (also suppressing `INCONSISTENT` on derived rows) are **sandbox drafts
only** — L1 integrates. `patch4/` is the deliberately over-broad variant, kept as the control-break counterexample for F3.

## What I did NOT check

- **No network.** Feeds were evaluated from `corpus/SOURCES.md` anchor cells and the retained receipt; I did not fetch the GitHub Atom feeds, python.org RSS or `curl.se/info`, so no claim here is a statement about current vendor truth. The C2 binding is over the registry, so this does not affect the predicate.
- **No production edit.** `corpus/release-clock.py`, `corpus/SOURCES.md`, `corpus/release-clocks.tsv` and the ledger were untouched by me; the 30 on-release rows, the receipt digest and the 79-case selftest count stand at BASE. **My patch drafts carry no selftest cases, so ledger pin `R25-03` (79 cases) is not satisfied by any candidate — new selftest cases are still owed.**
- **C1 canonicality overlap not adjudicated.** I measured that `numeric_version` collapses leading zeros and `VERSION_RE` does not, but did not design C1's own canonical-token predicate nor check how C1's `NONCANONICAL`/`OVERSIZE` findings would interact with a C2 finding on the same row (a leading-zero anchor would produce both). F1–F6 constrain C2 only.
- **The `derived:` marker is note-text-based** — prose in an uncontrolled column. I did not check whether any non-derived row's note begins with that prefix, nor evaluate a structural replacement.
- **No `--observe` run.** Only `evaluate()` and the `--receipt` CLI path were measured; the live fetch path `run_observe` was not exercised.
- **Cross-axis separability not re-measured.** I did not run round-28 `separability.py` overlays; the two patches touching `corpus/release-clock.py:566` are my drafts, not the wave's candidates.
