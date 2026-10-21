# RQualityCriteria — round-25 build: criteria review of C1/C2/C3

Seat: KagiR25.RQualityCriteria-2 (leaf, read-only). Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03 = lane HEAD (`git rev-list --count BASE..HEAD` → 0). Host: linux 7.2.11-arch1-1 x64. Sandbox: /fast/scratch/kagi-r25/RQualityCriteria/lane (lone clone at BASE; runs `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/RQualityCriteria/home`). Installs/updates: none. Lane files written: this report only (sandbox edits and planted docs are sandbox-only).
Criteria source: corpus/QUALITY.md at BASE (QA1–QA10, QM1–QM20). Sibling draft QM21–23 (build/ScribeQuality.md) is not on disk (`grep -n 'QM2[1-3]' corpus/QUALITY.md` → no match); cited below only as [draft].

## 1. Criteria per claim and the evidence each requires
C1 self-count binding (plan:20-37)
- QA3, QM13: "the corpus's … are bound" is universal; authored table rows are not calibration. Need named decisions, expectations not produced by the same tool, a known-bad admit that must fail (SKILL.md:46 at BASE), a bounded valid control.
- QA6, QM14: each count carries its command; the SKILL.md:46 change (63→83, 39→61) needs a committed old/new migration record.
- QM1, QM3, QM9, QM19: STALE/UNLOCATED/AMBIGUOUS each have a proving case; CLEAN requires unlocated=0 and ambiguous=0 in the verdict; receipts complete.
- QM15, QM20: `ledger:` runs ledger commands, so `[host]` and `[substrate]` rows must be default-deny.
- QM18 (analogue): `rows:` binds cardinality only, while SKILL.md:46 says "claim ids"; a swap of ids keeps it green.
C2 lone-clone layout (plan:38-55)
- QM3, QM19: LAYOUT-SKIP, fleet_absent and the new INCOMPLETE verdict must reach the verdict line and a non-zero exit (plan:52-53 states no verdict or exit for `layout_skipped=1`).
- QM10, QA6: "all layout" and "lane-local misses stay UNRESOLVED" are negative claims; they need a sweep that can return the claimed miss (§3).
- QM2: exit/host attribution; plan:50 names no host (this seat: §4).
- QM9, QM4: CITATION_LAYOUT, LAYOUT-SKIP, FLEET-ABSENT, layout_skipped each need a proving case; marker unspecified (plan:39).
- QM15, QM11: `[fleet]` must not admit host-reading rows; documented layout must name the real path (§4).
C3 release clocks (plan:56-71, 82-86)
- QA1, QA9, QM11: tier A for the feed's own scope; each feed row names its product and version; one generic feed bound to many rows fails.
- QA2, QA10: release status anchored to the feature's own H1/status region, not shared navigation.
- QA4: each new row names a falsifier and recheck trigger (mined rows carry no enforced falsifier, §4).
- QM14, QM16: old→new recheck migration; one normalizer (corpus/rendered-text-v1.py); SC_FETCH 16-column provenance row per new registry row.
- QM19, QM13, QM17: a failed fetch is UNOBSERVED, not observed; lane-written tools are not "independent"; rejected feed candidates recorded.
- QA5: no secret or token material in quotes or feed URLs.

## 2. Wording that violates a criterion (axes: calibration W1–W5, W8–W10; operability W6–W11, §3, W19; freshness W12–W18)
W1 plan:20-21 "the corpus's current-tense numeric self-descriptions are bound": QA3. The population is the table, not the corpus. SKILL.md alone has ≥15 numeric self-descriptions (e.g. :35 "35 census rows", :36 "16 cases", :181 "13 cases", :426 "9 items").
W2 plan:20 "C1 calibration" with `claims=N`: QM13. Authored row counts are not calibration.
W3 plan:29-30 verdict strings omit `ambiguous=`; the CLEAN form as written can print with AMBIGUOUS rows present. QM3.
W4 plan:32-33 exempts "explicitly round-dated, in LOG/lessons/SCORECARD history". SKILL.md:604-607 ("Round-9 … files=15 symbols=19") and :626-631 ("Round-11 … claims=11 stamped=28 … SELFTEST: PASS (39 cases)") are round-dated but live in SKILL.md, so the literal rule puts them in population and they read STALE. Name an exemption list by location, or migrate the bullets (QM14); a "round N" token must not exempt.
W5 plan:25 `rows:<path>` vs plan:26-28 "the ledger stays the single definition": stamps=83 is already pinned by R12-03 (claim-ledger.tsv:28 `^83$`) and claims=61 by R21-04 (:54 `^61$`). `rows:` creates a second definition; bind `ledger:` instead.
W6 plan:25-27 "non-host ledger row": `[substrate]` rows (11) and untagged R21-01 (tsv:51, runs op-ref-probe.sh, which executes `op`) must also be refused. QM15, QM20.
W7 plan:45-46 "[fleet] … any other row the wave proves layout-bound": fleet-layout rows run with no consent flag, so a host row tagged [fleet] runs by default. Forbid [fleet] together with [host]/[substrate]; state that [fleet] is existence-only. QM15.
W8 plan:41-42 vs plan:53-54: `.ufo/` tokens are class `ufo` (claim-ledger.sh:613) and resolve lane-first (:627-632). A lane-local `.ufo/` miss would become FLEET-ABSENT under plan:41-42, so the planned control cannot be a `.ufo/` token. BASE measured: `UNRESOLVED corpus/docs/planted2.md:1 .ufo/waves/round-25/build/nope-planted.md (ufo)`. QM10.
W9 plan:51 "unresolved=88 (57 sibling + 31 ufo, all layout)": 88 reproduces (§4) but is a lower bound (§3). "All layout" is a cause claim the lone clone cannot establish for the 31 `.ufo/` tokens. QA6, QM10.
W10 plan:52-53: the `verify` result after `LAYOUT-SKIP R11-08` names no verdict line or exit code. QM3 requires non-CLEAN and non-zero. The new `CITATION_GATE: INCOMPLETE` word needs a selftest case (QM9).
W11 plan:39 "marker fixed by the implementation": undefined; QM9 needs a documented, reachable, proven mode.
W12 plan:56-57 "every on-release recheck clock is bound and fired today": population is 38 occurrences, not 28 (§4): 28 registry rows, 9 prose `recheck:` lines, 1 census fixture. "Fired" also names a baseline observation. QA4, QM23 [draft].
W13 plan:61-63 "the row's quote must still locate in a fresh fetch": a quote can locate in nav or a sidebar while the status changed. Bind to the feature's own H1/status region and keep a sidebar-rejection control. QA10; SOURCES.md:98-99.
W14 plan:59-60 "official release feed … tier A": the tier contract is not in this tree. QUALITY.md:5-6 points to SOURCES.md, which has no contract text (grep: no match); sources-census.sh:4-5 names an out-of-lane file. QA1 is uncheckable here. The kind enum (sources-census.sh:191) has no feed kind; use `docs` or migrate the enum (QM14).
W15 plan:67-68 "independent `.ufo/waves/round-25/tools/c3-measure.py`": lane-written, not independent (QM13). Same for c1-measure.sh.
W16 plan:65-66 "`--observe` records a dated observation receipt": no failure path. Timeouts and non-200 responses must be UNOBSERVED and non-CLEAN; "observed" must mean compared, not dated (QM16, QM19).
W17 plan:69-70 "2026-10-21 observation for every row": omits SC_FETCH provenance per new row (sources-census.sh:56-61; missing-provenance at :328).
W18 plan:82-83 "Gate quotes in corpus/lessons/round-25.md": file absent (`ls corpus/lessons | grep -c 25` → 0). Rejected feed candidates must be listed (QM17).
W19 plan:75-78 separability: no landing protocol. claim-ledger.sh (stamps.tsv:4 pins 1646 lines / 105964 B), QUALITY.md (stamps.tsv:66 pins 112 / 17508) and new scripts each need restamp, a per-row re-run list and `sha256sum --check` (QM5, QM12).

## 3. Counterexample: citations drops a cite that ends its line (blocks C2)
Cause: claim-ledger.sh:748 `printf '%s' "$content"` emits no trailing newline, so `read -r` hits EOF on the final token and the loop body never runs for it.
BASE, sandbox, `citations --docs <file>`:
- `lane-local miss, ufo class: \`.ufo/waves/round-25/build/nope-planted.md\`` (corpus/docs/va.md, vb, vc, vd) → `CITATION_GATE: CLEAN (cites=0 docs=1 unresolved=0 ephemeral=0 labeled=0)` exit 0.
- same cite followed by a word (planted2.md, planted4.md) → `UNRESOLVED … (ufo)` exit 1.
Sandbox-only patch (`printf '%s\n'` at claim-ledger.sh:748; lane untouched): va–vd → 4× UNRESOLVED (ufo), exit 1. Full run → `CITATION_GATE: BROKEN (cites=1546 docs=67 unresolved=129 ephemeral=0 labeled=28)` exit 1, versus BASE 88: sibling 57→95, ufo 31→33, local 0→1. The local hit is a tokenizer artifact: LOG.md:1202 `` `corpus/closure-dispositions.py`/`.json` `` (both files exist, 18315 B and 4392 B).
Consequence: the plan's 88 is a lower bound; the fix alone turns fleet-layout R11-08 red; the fix needs a joined-pair tokenizer case and a selftest case (QM9, QM4). Every CLEAN verdict is an absence claim that this defect can falsify (QM10).

## 4. Measured facts (sandbox unless stated; exit codes shown)
- `citations` (lone clone, BASE): `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`, exit 1; split sibling=57, ufo=31, other=0. plan:51 reproduces.
- `grep -cv '^\s*\(#\|$\)'`: corpus/stamps.tsv = 83; corpus/claim-ledger.tsv = 61. SKILL.md:46 "63 stamps + 39 claims" reads STALE by hand (the C1 tool is absent).
- `sources-census.sh --selftest` → `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` exit 0 (SKILL.md:47 is current). `sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=32 … inrow_nonreproducing=12)` exit 0. `rendered-text-v1.py --selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)` exit 0.
- on-release: `grep -c '| on-release |' SOURCES.md` = 28 (rows :11–:38); `| 90d |` = 4; literal `recheck: on-release` lines = 8; all `on-release` lines under corpus = 38 (`grep -rn … | grep -c .`). `flip:` = 2 (SOURCES.md:14 S008, :36 S030, both REJECTED). SC_REJECT_SHAPE (sources-census.sh:219-220) checks rejected rows only, so mined rows have no enforced falsifier.
- Tags in claim-ledger.tsv: `[host]`=1 (R18-01, :48), `[substrate]`=11, `[fleet]`=0.
- Layout: `git ls-files .ufo | wc -l` = 575. R11-08 note (tsv:22) names `~/projects/shokunin/<lane>-shokunin`; `/home/vgpnk/projects` is absent (`ls -ld` → No such file); the real path is /home/vgpnk/Projects/shokunin/. claim-ledger.sh:603-604 header says `.ufo/` → `../.ufo/` only; the code is lane-first at :627-632.
- Real lane (read-only ls): .ufo/waves/round-25/tools/ = c1-measure.sh, c2-measure.sh, c3-measure.py; patches/ = XCiteLayout.patch, XSelfCounts.patch; corpus/self-counts.* and corpus/release-clock* absent (ls exit 2).

## 5. UNRUN and open
- `verify`: not run; it executes R21-01 (op-ref-probe.sh, runs `op`), which the seat contract forbids. `cells`: not run (real tree).
- Fleet-layout `citations` and fleet planted controls: not run (no fleet-root reads). "All layout" is UNVERIFIED.
- c1-measure.sh, c2-measure.sh, c3-measure.py: existence only, not executed.
- S033+ feed candidates: none opened; no network; tier A not checkable in-tree.

## 6. Planner actions (ordered)
1. Fix the last-token defect with a selftest case, or scope every CLEAN claim to it; record 88→129 before/after.
2. Replace the class-based FLEET-ABSENT rule with a stated lane-local vs fleet-root test; control with a non-class token.
3. C1: population list, explicit location-based exemption list, SKILL.md:604-631 migrated with old/new values (QM14); bind via `ledger:` (R12-03, R21-04).
4. C3: state the population (38, or an explicit rule); bindings for the 9 prose triggers (sops-age-key-rotation.md:5 "page footer", op-ref-consumption.md:371 "every op upgrade" name no identity); SC_FETCH rows; falsifier fields; feed kind `docs`.
5. Landing: stamps for claim-ledger.sh, QUALITY.md and each new script; per-row re-run list; `sha256sum --check`; a selftest case for every new mode.
6. Tree note (final check, `git status --short`): untracked `corpus/__pycache__/rendered-text-v1.cpython-314.pyc` (mtime 07:38) and untracked `plans/round-25.md`. This seat did not create the .pyc (script runs write no cache for the main script; every Python run here used the sandbox cwd); the planner clears or ignores it before landing.
