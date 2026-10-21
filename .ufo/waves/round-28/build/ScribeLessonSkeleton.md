# ScribeLessonSkeleton — round-28 lesson skeleton and findings

Author: KagiR28.ScribeLessonSkeleton-7 (scribe, leaf). Lane writes: this file only.
Frozen BASE `3553d499577084a6c98d7078906017840bbf7b28`; BASE trees extracted read-only to
`.ufo/waves/round-28/sandboxes/ScribeLessonSkeleton/base`. Plan read from the lane working
copy at `b9a42c0` (plan first at `bdf90f5`; `plans/round-28.md` is absent at BASE itself).

## Findings (first)

1. **Frozen C1/C2 fixtures are unmeasurable table-only** (plan §C1 `plans/round-28.md:31-37`,
   §C2 `:61-68`). Probe: S040 table-only edit → `RECEIPT-MISMATCH S040`, exit 1
   (`release-clock.py:425-445`, verdict/`parsed_version` pinned by receipt; reached before any
   version-token logic). Same for G1 (S008–S011 lowered to 3.13.0): `RECEIPT-MISMATCH S008..S011`,
   exit 1, `derived=11`. L1's append `b9a42c0` ("receipt mirroring") already states this; the
   probes confirm it is required. Without mirroring the BEFORE counts would read TYPED/0, not
   MISHANDLED k/4 or ACCEPTED 4/4.
2. **With receipt mirroring, both BASE defects reproduce.** F1 (`3.15.01`, fired, receipt
   mirrored): `RELEASE_CLOCK: CLEAN (... fired=4 ...)`, exit 0 — MISHANDLED (string compare
   at `release-clock.py:582`; `norm_version` `:362`). G1 (derived SOPS anchors lowered + receipt
   mirrored): `RELEASE_CLOCK: CLEAN (observed=30 fired=3 derived=15)`, exit 0 — ACCEPTED.
3. **F2 (4301-digit table component) is an untyped traceback at BASE.** `release-clock.py:380`
   `int(part)` via `is_regression` at `:567`; stderr ends `ValueError: Exceeds the limit (4300
   digits) ...`; exit 1; no catch in `main` (`:1749` catches only `SetupError`).
4. **Observe path (F3/F4), code-read + direct parse probe, no network.** `parse_latest_version`
   (`:715-760`) returns `'3.15.01'` for a `Python 3.15.01` title (F3 → written `fired`
   observation at `observe_one` `:798-804`, i.e. MISHANDLED). A 4301-digit patch raises
   `ValueError` at `:760`, caught at `:822` → typed receipt error (F4 TYPED-shaped; not run
   end-to-end).
5. **Derived binding (C2) is currently consistent.** All 15 `derived:` rows in
   `corpus/release-clocks.tsv` (lines 5–8, 10–13, 18–23, 26) equal the first version token of
   their `feed_source_id` anchor in `corpus/SOURCES.md:39–43` (S033 `3.13.3`, S034 `2.2.0`,
   S035 `2.7.1`, S037 `8.23.0`). So the after-state control must stay CLEAN 30/15. Mismatch
   list: none. (`derived:` rows bypass `anchor_ok`, `release-clock.py:565-566`.)
6. **Frozen counting commands do not exist yet.** `.ufo/waves/round-28/tools/` is empty
   (`ls`, this run). Nothing below is a measured pass.

## Gate — sources opened and decided this round

| Candidate | Decision and basis | URL, access date, located quote |
|---|---|---|
| Python `sys.set_int_max_str_digits` / integer-string conversion limit (the C1 citation) | PENDING — not opened by this scribe; L1 must open, decide and assign the id (next free after S043). Probe only: Python 3.14.8 default `sys.get_int_max_str_digits()` = 4300; `int("1"*4301)` raises ValueError. | [INFERENCE] until the registry row exists. |
| S033–S037 feed rows | Reused from BASE `SOURCES.md:39–43`; not "opened this round" by this skeleton. | — |

Existing registry cells: none changed by this skeleton.

## C1 — freshness (skeleton; measurements UNRUN)

Bind: non-canonical version tokens (leading zero in a multi-digit component, or a component
over the conversion limit) become typed findings, never a fired release, never a traceback.
Cite the Gate row above once L1 registers it. Probe evidence at BASE (sandbox copies):

| Fixture (plan `:31-37`) | BASE, table + receipt mirrored | Expected after |
|---|---|---|
| F1 `3.15.01` fired | exit 0 `CLEAN (... fired=4 ...)` — MISHANDLED | exit 1, typed, no fired |
| F2 4301-digit table | exit 1 `ValueError` traceback — MISHANDLED | exit 1, typed, no traceback |
| F3 observe `3.15.01` | `parse_latest_version` returns `3.15.01` (code-read, probe) — MISHANDLED | typed finding |
| F4 observe 4301 digits | ValueError caught `:822` (typed) — UNRUN end-to-end | typed finding |
| Control | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0 | same |

## C2 — calibration (skeleton; measurements UNRUN)

Bind: a `derived:` row's anchor must equal its `feed_source_id` registry anchor
(`corpus/SOURCES.md:39–43`). BASE: consistent for all 15 rows (finding 5), but the lowered
group G1 is ACCEPTED only with a mirrored receipt (finding 2). G2–G4 not probed by this scribe.

| Group (plan `:61-65`) | BASE, table + receipt mirrored | Expected after |
|---|---|---|
| G1 SOPS S008–S011 → 3.13.0 | exit 0 CLEAN — ACCEPTED | exit 1, EXACT ids S008–S011 |
| G2 Vault S013, S022–S024 | UNRUN | same |
| G3 OpenBao S014–S016, S021, S025, S026 | UNRUN | same |
| G4 curl S029 | UNRUN | same |

## Mistakes (class · evidence · captured-by · fix)

| id | class | evidence | captured-by | fix |
|---|---|---|---|---|
| M28-1 | frozen fixture cannot measure its target (table-only edit caught by receipt) | finding 1; `release-clock.py:425-445`; plan `:61-68`; probe `g1t` exit 1 | L1 append `b9a42c0` + this scribe's probe | receipt-mirrored fixtures (plan correction) |
| M27-1 (carried) | survivor: string/inequality accepted as release | round-27 lesson `corpus/lessons/round-27.md:100-107` | round-27 | REGRESSED rule (round-27) |
| M27-plan (round-27 conformance) | plan landed with candidate code | `git log -- plans/round-27.md`: first is `144babc` ("(candidate)") | round-28 plan landed at `bdf90f5` before tools | none needed this round; verify END census |
| M27-census (round-27 conformance) | no START census | `corpus/lessons/round-27.md:262-267` (correction) | round-28 `census-start.txt` at `bdf90f5` | retained |
| M27-C2scope (round-27 conformance) | frozen C2 scope widened mid-round | `plans/round-27.md:50-56` | frozen round-28 text; plan corrections appended only | frozen text not rewritten |

## Limits

- No frozen counting command has been run; all numbers above are probes in sandbox copies.
- F3/F4 and G2–G4 unexercised; F3 path is code-read plus parse probe; no network used.
- The S044-class registry row for the integer limit is absent until L1 opens it.
- Receipt-mirrored probes use a re-serialized receipt (sha pinned by my probe, not the
  frozen sha); the frozen commands must compute their own.

## Measurement placeholders (UNRUN — L1 fills with exit codes)

- `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>` — UNRUN, exit: —
- `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py <rev> <label> <out.json>` — UNRUN, exit: —
- START census `.ufo/waves/round-28/census-start.txt` — present (exit 0, 11 W04 lines).
- END census — UNRUN, exit: —
- Clock selftest count (79 at round-27's measured revision `3fb7727`, per its final gate; BASE count not run here) — UNRUN.

## Commands run (this scribe; all sandbox copies, cwd noted)

- `git archive 3553d49… | tar -x` → sandbox `base`; exit 0.
- `python3 -I -B` ad-hoc probe of `norm_version`/`numeric_version`: exit 0.
- `release-clock.py` in `probe/control`, `probe/f1`, `probe/f2` (default command): exit 0 / 1 / 1.
- `release-clock.py --receipt ../f1-receipt.json --receipt-sha <sha>` (F1 mirrored): exit 0.
- `release-clock.py` G1 `g1t` (table-only): exit 1; `g1r` (mirrored, `--receipt`): exit 0.
- `parse_latest_version` direct import from `base`: exit 0.
- `git log`, `git show --stat`, `git merge-base`: read-only; exit 0.

## Did NOT check

- The frozen counting tools (absent), the selftest suite, mutation controls, separability overlays.
- BASE SOURCES rows S001–S032 beyond the feed block; ledger pins; census script output.
- Whether the sibling scouts' SrcIntMaxStrDigits output is correct (not read, by design).
- Any network fetch, vault, account, CDP or host-private path.
