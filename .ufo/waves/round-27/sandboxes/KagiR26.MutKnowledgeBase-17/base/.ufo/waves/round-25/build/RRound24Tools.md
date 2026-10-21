# RRound24Tools — round-24 tools against round-25 measurement (C1 self-counts · C2 layout · C3 clocks)

Seat KagiR25.RRound24Tools-2 (leaf). Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03 = lane HEAD; the six tools are tracked and unchanged at BASE. All runs in sandbox `/fast/scratch/kagi-r25/RRound24Tools-2/lane` (clone @BASE). Sandbox copies `*-r25sandbox.*` retarget only the hard-coded lane, scratch root, TMPDIR or User-Agent; each is named below. No lane writes. Installs: none (present: curl 8.23.0, Python 3.14.8).

**Bottom line:** no round-24 tool is a drop-in for C1/C2/C3. `identity-swap.py` needs a patch before C2 lands; `gate-regression.py` pins the 151-case count and must migrate with the selftest; `host-tripwire.sh` is compatible with appended summary fields.

## 1. Inventory — `.ufo/waves/round-24/tools/` (6 files)
| file (added) | purpose / CLI / last line | round-25 reuse |
|---|---|---|
| host-tripwire.sh (a3eb6c7) | counts host-row executions of default verify/cells, stubbing 6 host scripts (L41); `LABEL REV [SRC FILE…]`; `HOST_TRIPWIRE: … total= complete=k/4 host_skip_lines=` | harness pattern for C2 lone-clone runs; not C1/C3 |
| claim-separability.py (e621051) | one round-24 claim on BASE + digest-pinned overlay; `c1-only\|c2-only\|c3-only`; `CLAIM_SEPARABILITY:` line | no (round-24 labels; manifests pinned to base 4f94b52, L18–19) |
| gate-regression.py (277a0d4) | same selftest fixtures on frozen vs repaired claim-ledger.sh; `BEFORE AFTER OUT.json`; `GATE_REGRESSION: PASS\|FAIL` | no as-is (count pinned, L29) |
| recovery-count.py (277a0d4) | SOURCES/fetch/stamp populations and stamp hashes from Git objects at REV; `REV` → JSON | yes: read-only C1 cross-check |
| normalizer-replay.py (31c8421) | live refetch of S017–S026, rendered-text-v1 whole-page sha256 vs pin; `OUT.json`; `NORMALIZER_REPLAY: rows= v1_matches= ascii_matches=` | freshness probe only (C3 needs quote-locate) |
| identity-swap.py (a3eb6c7) | 15 count-preserving mutants vs ledger verify subsets; `LABEL REV [SRC FILE…]` or `--selftest`; `IDENTITY_SWAP: … survived= killed= invalid=` | yes for calibration, after the §3.1 patch |

## 2. Exact runs (sandbox @BASE; exit codes)
- `claim-ledger.sh --selftest` (env -i, TMPDIR sandboxed) → 0 `SELFTEST: PASS (151 cases)` (= R11-09 pin, claim-ledger.tsv:23).
- `claim-ledger.sh verify` (lone clone, KAGI_SUBSTRATE unset) → 1 `FAIL R11-08 reason=exit-mismatch exit=1 want=0`; `CLAIM_LEDGER: FAIL (claims=61 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)`; 12× `HOST-SKIP` (claim-ledger.sh:555).
- `claim-ledger.sh citations` → 1 `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`; UNRESOLVED by class: sibling=57, ufo=31.
- `recovery-count.py 4587c61a…` → 0 `{"captures": 32, "inrow": 16, "inrow_only": 0, "revision": "4587c61a348e…", "rows": 32, "stamp_mismatches": [], "stamp_rows": 83}`.
- `identity-swap.py --selftest` → 0 `IDENTITY_INSTRUMENT_SELFTEST: PASS (cases=12 failed=0)`.
- identity-swap main (copy: LANE, scratch root, TMPDIR retargeted) `r25base 4587c61a…` → 0 `IDENTITY_SWAP: label=r25base rev=4587c61a348e population=15 survived=0 killed=15 invalid=0`; all 16 R24-* rows evaluated in every mutant.
- gate-regression (copy: temp root, TMPDIR) `e1884c6 4587c61a…` → 0 `GATE_REGRESSION: PASS before_exit=1 after_exit=0 fixtures_identical=True`.
- normalizer-replay (copy: UA round23→round25, temp root) → 0 `NORMALIZER_REPLAY: rows=10 v1_matches=10 ascii_matches=7`; HTTP 200 ×10; ASCII-alt misses S022–S024.
- host-tripwire (copy: lane, base retargeted) `r25base 4587c61a…` → 0 `HOST_TRIPWIRE: … verify_absent=0 verify_present=0 cells_absent=0 cells_present=0 total=0 complete=4/4 host_skip_lines=48`; every RUN `host_rows_executed=0 population_skipped=12/12`; verify tree shows `failed=11 stale=6` from its six stubs.
- separability digests (python replica of claim-separability.py:18–21): c1-only 2/2, c2-only 6/6, c3-only 3/3 match.
- `sources-census.sh --selftest` → 0 `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`; `rendered-text-v1.py --selftest` → 0 `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`.

## 3. Conflicts with round-25 behaviour (ranked)
1. **identity-swap.py — HIGH, silent false SURVIVES.** `assess()` (L182–209) rejects HOST-SKIP/POLICY/DEFER (L188) and `host_skipped` (L198) but has no LAYOUT-SKIP rule. Replay: CLEAN + `layout_skipped=1` → `bad=[] invalid=''` (accepted); HOST-SKIP → `invalid='policy-or-skip'`; INCOMPLETE header → `invalid='missing-terminal-summary'`. Derived from L285 (`pop_passes = prow in ids and prow not in bad`) and L295 (SURVIVES): an accepted, unexecuted row yields SURVIVES. Patch: LAYOUT-SKIP in L188, `layout_skipped` in L198.
2. **C2 header — plan gap.** Precedent claim-ledger.sh:1611: host-skipped rows keep `CLAIM_LEDGER: CLEAN (… host_skipped=1)` exit 0. The same pattern for layout skips contradicts "never credited as passing" (plan §C2) and is exactly what item 1 accepts. Recommend `CLAIM_LEDGER: INCOMPLETE (… layout_skipped=N)` exit 1, mirroring `CITATION_GATE: INCOMPLETE`.
3. **host-tripwire.sh — the field-append worry does not apply.** It reads only the summary prefix (L73–74) and `^HOST-SKIP ` lines (L62, L75); it never parses `key=value`. Replay of L73–75 on `LAYOUT-SKIP R11-08` + `CLAIM_LEDGER: CLEAN (… layout_skipped=1)`: `complete=1 host_skip_lines=0 layout_skip_lines_uncounted=1`. Compatible, but blind to layout skips; add a counter if reused.
4. **gate-regression.py — count pinned.** L29 requires last line `SELFTEST: PASS (151 cases)` and case `cells-invalid-self-policy`; L15/L17 split on the exact marker (claim-ledger.sh:1178). Any new selftest case fails it; R11-09 (claim-ledger.tsv:23) pins 151 as well. Passes today.
5. **normalizer-replay.py — wrong UA and wrong predicate for C3.** L24 sends `kagi-shokunin-round23/1.0`; L17 hard-codes S017–S026; L29/L35 compare whole-page sha256, not quote-locate. Use `rendered-text-v1.py locate FILE QUOTE` (main L186–187) for rendered-quote clocks. Today 10/10 whole-page matches, so pinned quotes still normalize identically [INFERENCE: quotes were located in that text].
6. **identity-swap mutants — crash path and stale docstring.** `sub_once` raises RuntimeError (L77) if a target pattern vanishes; all targets exist at BASE (SCORECARD.md:12, claim-ledger.tsv `^R17-03\t`, revision-audit.py:545, checklist `^E1\t`). Docstring L17 "none exist at BASE" is stale: `grep -cP '^R24-' corpus/claim-ledger.tsv` = 16.
7. **claim-separability.py — label collision, lane writes.** c1/c2/c3 name round-24 claims, not round-25 C1–C3. c1-only and c3-only run host-tripwire/identity-swap with `cwd=lane` and write `<label>-run.json` into the lane (L35–40).
8. **recovery-count.py — compatible.** `stamp_rows=83` uses C1's `rows:corpus/stamps.tsv` definition (non-blank, non-#), so it independently corroborates that SKILL.md:46 "63 stamps + 39 claims" is stale (live stamped=83, claims=61).

## 4. Isolation (hard-coded paths)
- host-tripwire.sh: lane L32 = real lane; scratch L33 `/fast/scratch/kagi-r24/tripwire`; stubs L41; population L45–47, L59.
- identity-swap.py: LANE L36 = real lane; scratch L262 `/fast/scratch/kagi-r24/identity`.
- gate-regression.py: lane from `__file__` (L11); temp L19 `kagi-r24-recovery`; child env without TMPDIR (L26).
- normalizer-replay.py: lane from `__file__` (L13); temp L19; live GET ×10 with round-23 UA (L24).
- claim-separability.py: lane from `__file__` (L12); temp L22; writes lane `<label>-run.json` (L40).
- recovery-count.py: lane from `__file__` (L10); `git show` only (safe).

## 5. Verdicts
- C1 self-counts: no round-24 tool measures prose counts; use recovery-count `stamp_rows` and verify `claims=`/`stamped=` as cross-checks. The population must include SKILL.md:243 ("97 scratch cases"; live 151), not only SKILL.md:46. SKILL.md:47 "70 cases" is current (live 70).
- C2 layout: host-tripwire is a usable harness; identity-swap needs §3.1–3.2 before C2 lands. BASE "before" values reproduce: verify FAIL R11-08 exit 1; citations unresolved=88 (57 sibling + 31 ufo).
- C3 clocks: no reusable binder. normalizer-replay is a freshness probe after the UA/row fix; `rendered-text-v1.py locate` is the primitive. `grep -c on-release corpus/SOURCES.md` = 28 (matches plan).

## 6. UNRUN, limits, drift
- UNRUN: claim-separability.py full runs (would write lane `*-run.json` and use kagi-r24 scratch); only its digest precheck ran. Unpatched host-tripwire, identity-swap, gate-regression and normalizer-replay: not run (hard-coded lane/scratch/UA); copies only.
- Lane drift seen during the run (read-only status): ` M corpus/README.md` (07:46:39), `?? corpus/__pycache__/rendered-text-v1.cpython-314.pyc` (07:38:17), `?? plans/round-25.md`. Not from this seat: no lane writes by me; sandbox has no pycache; the pyc timestamp matches a peer's `round-25/tools/c3-measure.py` write (07:38:17).
