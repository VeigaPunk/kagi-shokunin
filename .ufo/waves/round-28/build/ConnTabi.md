# ConnTabi — tabi-shokunin overlap scan for kagi round 28 (C1 canonical tokens, C2 derived-anchor binding)

Read revision: tabi `e3cf4e0d30bb835532ff44b118c5ad52e09eb76d` (`git -C tabi-shokunin rev-parse HEAD`, exit 0;
`git status --porcelain | grep -v '^??' | wc -l` → `0`). Kagi facts at frozen BASE
`3553d499577084a6c98d7078906017840bbf7b28`. tabi paths are relative to `tabi-shokunin/`, kagi paths to the lane.
No sibling write, no sibling gate run, no feed contacted.

## Findings

**F1 — tabi has no release-clock mechanism; its "freshness" is content-pin freshness.**
`scripts/check-freshness.mjs:79-93` parses `corpus/evidence/fleet-round-1-freshness/pins.tsv` rows of eight columns
(`status target sha256 newlines prefix source baseline_sha256 revision`), comparing SHA-256 + newline counts;
`:62-70` gates a witness *git epoch*, not a release date. No feed URL, version token or fired/not-fired verdict
exists in the file. C1/C2 neither absorb nor contradict it, and the round must not claim to cover tabi-style
freshness (vocabulary collision, not ground). `git grep -lE "release[-_ ]?clock|anchored_version|observed_version"`
over tabi non-.ufo files → no hit.

**F2 — the SOURCES registry is a shared contract, and kagi's parser reads tabi's file unchanged.**
Kagi `corpus/release-clock.py:58-96` parses 11-cell `|` rows (anchor = `cells[5]`, `:88`); tabi
`corpus/SOURCES.md:13-14` has the identical 11-column header and `scripts/check-sources.mjs:312-325` validates the
same physical columns (its `fields[6]` counts a leading empty split, not an off-by-one). Probe: BASE
`parse_sources` against tabi's registry → `rows=101`, exit 0. But tabi never binds a value into that column:
`corpus/SOURCES.md:8` says the structural check "cannot see whether a source was opened". C2 is **new semantics
over a shared format** — document it as kagi-local, never as "fleet anchors are bound".

**F3 — the same version-token defect class exists in tabi, with a different failure mode.**
`scripts/check-aria-metadata.mjs:198` `SEMVER = /^(\d+)\.(\d+)\.(\d+)$/`; `:228-233` `parseVersion` converts with
`Number()`; `:535` `exactMatch = observed.text === recorded.text` (string equality); `:536` compares only numeric
major; `:568-569` marks the recorded pin descriptive. Probe (`node probe2.mjs`, exit 0): `3.15.01` and `3.15.1` give
identical `{major:3,minor:15,patch:1}` but `exactTextMatch=false` — a leading-zero token reads as a mismatch, the
C1 misread class, producing a finding instead of a release event. A 4301-digit patch gives `patch=Infinity`,
`Number.isInteger=false`, no throw (`Number` degrades where Python's `int()` raises). tabi's own Chromium pin
`156.0.8078.4` (`:174-175`) does not parse under SEMVER, while `:802-804` only type-checks it as a string — a
three-component canonicality rule **must not be generalized** beyond release-clock fields.

**F4 — BASE failure shapes differ by surface (affects C1's F2 vs F4 fixtures).** `release-clock.py:369-380`
`tuple(int(part)...)`; probe (`python3 -I -B probe.py`, exit 0): `numeric_version("3.15.01")==(3,15,1)`,
`norm_version` equality `False`, a 4301-digit component raises `ValueError: Exceeds the limit (4300 digits)`;
`sys.get_int_max_str_digits()` = 4300. Table path: `numeric_version(observed_version)` at `:577` under `main`'s
`except SetupError` only (`:1749-1751`) → traceback. Observe path: `parse_latest_version:760` does the same
`int(part)`, but `observe_one:818-823` catches `(OSError, ValueError)` → an untyped `receipt["error"]` string, and
`run_observe:886-897` counts `failed=1`. F4 at BASE exits 1 **without** a typed per-feed finding; the fixture
predicate must distinguish a typed finding from a generic receipt error, and neither BASE shape satisfies it.

**F5 — the intended C2 rule holds on unmodified BASE (positive calibration result).** Dry-ran the literal rule —
anchor-cell tokens via BASE `VERSION_RE:30-33`, normalized — over all 15 `derived:` rows
(`corpus/release-clocks.tsv:5-26`): every anchor cell names exactly one distinct version equal to
`anchored_version` (`S033→['3.13.3']`, `S034→['2.2.0']`, `S035→['2.7.1']`, `S037→['8.23.0']`); 0 failures, exit 0
(`probe4.py`). Caveat: each feed row states the version twice (title + tag link, `corpus/SOURCES.md:39-43`), so the
predicate is "the anchor names this version", not "exactly one token" — the uniqueness rule in tabi
`scripts/check-measurement-binding.mjs:300-315` (`anchorRows !== 1` → fail) **does not transfer**.

**F6 — counterexample to a permissive C2: hyphen suffixes.** `version_is_named:341-346` excludes only
`[A-Za-z0-9.]` in its lookahead. Probe (exit 0): `True` for `2.2.0` against a bare `v2.2.0-rc1` string, and `True`
for `2.7.1` inside `api/v2.7.1`. At BASE those tokens live in the *teaches* cell (`corpus/SOURCES.md:40-41`), so
binding over `cells[5]` is safe today; but a lowered derived anchor equal to a tag the row's own scope excludes
(`-rc1`, `sdk/` module tag) would be **accepted** if the anchor cell ever mentions it — a false-accept path G1–G4
do not exercise. Boundary direction is otherwise right: `False` for `154.0.8037` vs `154.0.8037.97` and for
`24.21.0` vs `recorded24.21.0`. Related precedence trap: `2.2.00` and `2.2.0` are numerically equal
(`numeric_version` same tuple) but string-unequal (`norm_version`), so C1 must **reject**, not rewrite, a
non-canonical token — rewriting would make a forged derived anchor "equal" to its feed anchor and destroy C2's
evidence; C2 compares raw tokens.

**F8 — no PROVINCE/adjacency row binds release clocks to tabi.** tabi `corpus/adjacency.tsv:2-11` names kagi only as
`secrets-vault-ops` (refused-route, line 9) and `musketeer-cdp-9222-profile-lease` (contested-open, line 8); tabi
`PROVINCE.md:15-16` refuses secrets → kagi. Kagi `PROVINCE.md` names no tabi (`grep -c -i tabi` → `0`, exit 1); kagi
`corpus/adjacency.tsv:54-57` owners are integrator/kagi/kake/kotoba, `:82-83` makes kagi a writer in kake's lease —
C1/C2 touch no tabi-owned surface; a tabi owner row or shared "freshness" surface would be scope change.

## Reusable prior art

- **P1 exit taxonomy** — `check-freshness.mjs:28-30` `fail(finding, detail, exit=1)`; `:237-260` emits
  `verdict=failed` (exit 1) vs `verdict=could-not-evaluate` (exit 2). Kagi has the same split
  (`release-clock.py:1749-1751` → 2, `:1754` → 1): non-canonical tokens go to exit 1 with a typed name, never exit 2.
- **P2 self-test as `{name, exit, finding}` table** — `check-freshness.mjs:211-217` + `:230-250` spawns the script
  per case, asserting exit code and finding substring; `check-sources.mjs:60-80` adds exit-2 poisoned-input cases
  with detail. Fixtures in temp trees, never the lane tree.
- **P3 witness defenses** — `check-freshness.mjs:62-70` (witness epoch ≥ threshold, baseline ancestry);
  `freshness-witness.mjs:15-20,26-45` (`GIT_NO_REPLACE_OBJECTS`, `GIT_GRAFT_FILE=/dev/null`, literal pathspecs) — for
  the END census reading a revision; the clock reads worktree files only.
- **P4 row-curation checklist** — `check-sources.mjs:318-327` enforces kind/tier/status/opened/recheck vocabularies,
  non-bare anchor, `REJECTED:`+`flip:`. Kagi `parse_sources:78-80` enforces only 11 fields, so the new
  Python-int-limit row can pass the clock while failing the shared contract (mined with no `used-by`); apply manually.

## Proposed move (one, bounded)

Tighten C2 to a **stable-token** binding and pin the cross-lane boundary in the lesson: (i) accept a derived anchor
only when the feed row's anchor cell names `norm_version(anchored)` with no `-`/`+` suffix attached (lookahead
`[-+0-9A-Za-z.]`, or strip the suffix before matching), leading boundary intact; (ii) add one clock selftest case
whose feed anchor mentions only `vX.Y.Z-rc1` while a derived row anchors `X.Y.Z` — expected exit 1 naming that row;
(iii) record that `corpus/SOURCES.md` is a shared 11-column contract (kagi's parser reads tabi's registry: 101 rows)
whose anchor cells are prose elsewhere, so anchor-binding is kagi-local, citing tabi `check-aria-metadata.mjs:535`
as corroboration of the string-equality defect class, not as a request.

Affected axes: calibration (closes a false-accept the G1–G4 set misses); freshness unchanged. No runtime/contract/substrate harm: one predicate + one selftest case, no new dependency or datastore.

Risks: (a) over-tightening could reject a punctuation-adjacent mention — current anchors already pass the tight
boundary (F6 probes), so the delta is only hyphen suffixes; (b) substring "naming" would let `2.2.0` match
`12.2.0` — keep the leading boundary; (c) rewrite-style canonicality bypasses the predicate (F6/F7) — order rejection first.

Verification (L1, not run by me): frozen `c2-measure` before/after → ACCEPTED 4/4 → 0/4, EXACT 4/4, control
`RELEASE_CLOCK: CLEAN (… derived=15)` exit 0; the rc1 selftest case exits 1 naming its row; `c1-measure` control
(fired=3 bound=30) unchanged.

## Commands run (read-only; no installs)

`git -C tabi-shokunin rev-parse HEAD` → `e3cf4e0d…`, exit 0; `status --porcelain | grep -v '^??' | wc -l` → `0`.
kagi `git archive BASE | tar -x` into `.ufo/waves/round-28/sandboxes/ConnTabi/base` → exit 0. `python3 -I -B probe.py
base/corpus/release-clock.py` → exit 0 (F4/F6 values); `probe3.py … tabi-shokunin` → `rows=101`, exit 0;
`probe4.py … base` → 15 derived rows, 0 failures, exit 0; `node probe.mjs`, `node probe2.mjs` → exit 0 (F3).
`git grep`/`grep -n` reads over tabi `scripts/ corpus/ PROVINCE.md` → citations above; the kagi-mention grep in
tabi `PROVINCE.md` exits 1.

## What I did NOT check

- Did not run any tabi gate or selftest (`node scripts/*.mjs`) — lane bounds; tabi evidence is source reading plus
  the line-pinned probes above. Did not read all 3,460 lines of `check-aria-metadata.mjs`, only its version path.
- Did not read tabi `.ufo/waves/round-22+`, `LOG.md` past ~line 1500, or `corpus/knowledge/`.
- Did not contact any feed or run `--observe` (F3/F4 is BASE source plus probes, not live fetches), re-verify tabi
  `pins.tsv` digests, test `freshness-witness.mjs`, or run kagi's frozen `c1-measure`/`c2-measure` (L1 integrates).
