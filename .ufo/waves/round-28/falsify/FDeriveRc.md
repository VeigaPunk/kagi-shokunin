# FDeriveRc — round-28 falsify: feed-row anchor naming only `v2.2.0-rc1` must not bind `2.2.0`

Target: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`
(candidate; BASE `3553d499577084a6c98d7078906017840bbf7b28`).
Carrier attacked: C2 derived-anchor binding only. Verdict: **PASS** (no defect found in this carrier).

## Verdict

The candidate **refuses** to bind a `derived:` anchor `2.2.0` to a feed row whose anchor
cell names only the prerelease sibling `v2.2.0-rc1`: it emits the typed category
`DERIVATION` for exactly the four Vault derived rows (S013, S022, S023, S024), exits 1,
prints no `Traceback`, and produces no generic `RECEIPT-MISMATCH` and no new `fired`
verdict. At BASE the same registry edit is silently accepted (`CLEAN`, exit 0), so the
new rule is what catches it — the receipt pin was not mistaken for the rule.

## Setup (isolated, no network)

* `git -C <lane> archive 62a33b1 | tar -x -C /fast/scratch/hyaku/kagi-r28/FDeriveRc/cand`
  (read-only git; same for BASE into `.../base`). Exported `corpus/release-clock.py` sha256
  `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86` == the committed blob
  == the lane working-tree file.
* Default receipt copied in read-only: `.ufo/waves/round-26/observe-2.json`, sha256
  `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` (== `DEFAULT_RECEIPT_SHA256`, release-clock.py:28).
* Nothing was executed in the lane checkout; no lane gate/selftest ran there; no production
  file was written. Tooling: none installed (python3 3.14.8, git 2.56.0 as shipped). Small
  retained artifacts: `.ufo/waves/round-28/sandboxes/FDeriveRc/` (patch, runs.txt, 2 probe scripts).

## Concrete counterexample (the attack input)

`corpus/SOURCES.md:40` (row S034), **anchor cell only** (column 6, `cells[5]`):

    - Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z; feed fetched 2026-10-21
    + Entry titled v2.2.0-rc1, tag link /releases/tag/v2.2.0-rc1, updated 2026-10-15T18:50:14Z; feed fetched 2026-10-21

The row's `teaches` cell still says "Newest stable Vault is v2.2.0 … v2.2.0-rc1";
`corpus/release-clocks.tsv` (S013/S022/S023/S024, anchored `2.2.0`, notes start `derived:`)
and the receipt are untouched. So the *only* change is that the feed row's located anchor
no longer names the stable version the derived rows claim.

## Commands and exit codes (isolated trees, `python3 -I -B corpus/release-clock.py`)

| tree | change | output | exit |
|---|---|---|---|
| `cand` | none (control) | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | 0 |
| `probe_rc` | S034 anchor cell → only `v2.2.0-rc1` | `DERIVATION S013/S022/S023/S024` + `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)` | 1 |
| `probe_rc` | same, `--receipt receipt-copy.json --receipt-sha 13b8540c…` | identical four `DERIVATION` lines, `FAILED` | 1 |
| `probe_both` | S034 cell names `v2.2.0` **and** mentions `v2.2.0-rc1` | `CLEAN …fired=3 derived=15` | 0 |
| `probe_base_rc` | **BASE code**, same S034 edit | `CLEAN …fired=3 derived=15` (mismatch silent) | 0 |
| `probe_nodecl` | S013 note loses the `derived:` prefix | `DERIVATION S022/S023/S024` + `INCONSISTENT S013`, `FAILED` | 1 |
| `cand` | `python3 -I -B corpus/release-clock.py --selftest` | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 |

No `Traceback` in any output; `fired` stays `3` in the failing runs (the three
pre-existing fired rows S027/S028/S012), so the bad input creates no fired verdict;
`observed` 30→26 and `derived` 15→11 are exactly the four rejected rows. The verify run
wrote nothing (receipt sha256 unchanged; `diff -rq` shows only the intentional
`corpus/SOURCES.md` edit).

## Exact candidate code (path:line at `62a33b1`)

* `corpus/release-clock.py:84` — `"anchor": cells[5]` (the anchor cell the rule reads).
* `corpus/release-clock.py:345-346` — `STABLE_TOKEN_RE` (`(?![A-Za-z0-9.+-])` excludes the
  `-rc1`/`+build` sibling and the `.1` longer component).
* `corpus/release-clock.py:349-363` — `derived_anchor_bound`: numeric anchor binds only when
  the cell's stable-token **set** equals `{norm_version(anchored)}`.
* `corpus/release-clock.py:617-627` — call site: `errors.add(("DERIVATION", source_id))`,
  `row_valid = False` (so the row never counts as observed/fired/derived).
* BASE counterpart `corpus/release-clock.py:566` — `anchor_ok = is_derived or version_is_named(...)`:
  at BASE a derived anchor is trusted and the feed cell is never consulted.

Function-level battery (candidate module, `fn_probe.py`, cell → `derived_anchor_bound("2.2.0")`):
`stable only` → True; `v2.2.0-rc1 only` → **False** (while the round-27 reading
`version_is_named` returns **True** on the same cell — the exact defect QM28 names);
`stable + same-feed rc` → True; `rc + sdk/v0.26.0` → False; `two stable versions` → False;
`v2.2.0.1` → False. `STABLE_TOKEN_RE.findall("v2.2.0-rc1") == []`.

## Residual risks / verification gaps (no new scope claimed)

1. **Observe mode writes the receipt before the DERIVATION check.** `corpus/release-clock.py:977-981`
   (`run_observe` → `write_receipt` at `:919`) runs before `evaluate()` (`:617-627`), so under a mismatched cell the
   offline harness (`observe_probe.py`, stubbed `request_body`, no network) shows the receipt
   for S013/S022/S023/S024 carrying `verdict="fired"` while the run still reports `DERIVATION`
   and exits 1. The frozen contract only requires "typed finding, exit 1" (holds); C1's
   "no verdict written" protection does not extend to C2. Not a FAIL of this carrier.
2. **The round's frozen C2 fixture set cannot reach this vector**: `.ufo/waves/round-28/tools/c2-measure.py`
   edits `corpus/release-clocks.tsv` only and pins `SOURCES.md` untouched, so the feed-row-anchor
   side is outside the measured claim; my probe is the only coverage of it that I saw.
3. C2 stays consistency-between-committed-files, not tamper evidence (editing cell+table+receipt together still passes) — the round's declared limit, not re-tested.
4. Not checked here: any live network `--observe` run; the C1 (canonical-token) carrier; the
   other feed groups (S033/S035/S037) end-to-end; the lane-owned `c1-measure.py`/`c2-measure.py`
   tools (not executed in the lane).
