# RFleetRows: C2 static scan of corpus/claim-ledger.tsv (round-25 build)

Seat KagiR25.RFleetRows-2 (leaf reviewer). Base 4587c61a348e4528717404a68912c373f3ef4d03; real lane HEAD identical (`git rev-parse HEAD`, read-only). No lane file edited, no git index or jj mutation, no op/handler/vault/CDP call, no credential or host read, no `verify`/`cells` on the real tree (one read-only `citations` control only). Tools: none installed or updated (existing git, bash, python3, sqlite3, timeout).
Sandbox (kept for re-run): /fast/scratch/kagi-r25/RFleetRows-2/lane (`git clone -q --no-hardlinks` + `checkout -q 4587c61…`; `status --porcelain` = 0 after all runs) and …/home (empty). Lone-clone runs: `env -i PATH=/usr/bin:/bin HOME=…/home bash -o pipefail -c '<row command>'`, cwd = sandbox lane. Ledger line numbers below are `grep -n` positions in corpus/claim-ledger.tsv.

## 1. Summary
- 61 rows: 49 untagged, 12 host-tagged. Host-tagged = 11 `[substrate]` (L15 L16 L17 L18 L20 L26 L33 L38 L39 L41 L45) and 1 `[host]` (L48). Double-tagged: 0. `[fleet]` present today: 0.
- Proposed `[fleet]`: R11-08 only (claim-ledger.tsv:22). No other untagged row reads ../.ufo, ../MANIFEST.json, a sibling repo or a $HOME path at run time (46 verified in the lone clone; 2 not executed, see §2E).
- Fleet-also but host-tagged, so NOT re-tagged: R13-03, R16-01, R16-03, R17-01.
- C2 numbers in plan §C2 are wrong as stated: 42 of the 57 "sibling" misses are lane-local self-citations (F1).

## 2. Per-row dependency
A. Fleet-bound, untagged → propose `[fleet]`: R11-08 (L22). `citations` maps `*-shokunin/…` to `$ROOT/../…` and `ufo/…`, `.ufo/…` to `$ROOT/../.ufo/…` (claim-ledger.sh:613-636, mode at :684-708). Lone clone: `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`, exit 1. Fleet control (real tree, read-only): `CITATION_GATE: CLEAN (cites=1371 docs=67 unresolved=0 ephemeral=0 labeled=13)`, exit 0.
B. Fleet-also, host-tagged (no `[fleet]`):
  - R16-01 (L39) default verify: `lane:` basis resolves under `$LANE_ROOT/<lane>-shokunin` (scope-gate.sh:91, :338-343). Rows adjacency.tsv:82 (`lane:kake/SKILL.md:161`) and :84 (`lane:kotoba/corpus/knowledge/alwayson-checklist-round7.md:30`). Lone clone: `SCOPE NOT-A-FILE` for both.
  - R17-01 (L45) `--breadth`: falls through to gate() (scope-gate.sh:1125-1129); its exit includes basis defects (:652-661). Lone clone: exit 1.
  - R16-03 (L41) `--falsify`: LANE_ROOT default (:683-684), stale-basis mutation on `lane:kake` (:704-705), `ln -s "$LANE_ROOT/kotoba-shokunin"` (:756). Lone clone: `caught=13/18 failed=5`.
  - R13-03 (L38) `cells`: re-runs every cited untagged row (cells_evidence claim-ledger.sh:957-978, verify_claims :971). SCORECARD.md:871 and :882 cite R11-08, so it inherits the fleet dependence.
C. Host-only, tagged: R11-01/02/03/04 (surface-census.sh:79 `ROOT=${HOME}`; drift-pins.sh:46-74 `$HOME` FILES/NOHASH); R11-06 and R12-01 (transcript-scan.sh:34-35; op-ref-probe.sh:69-70 `JAN_BIN=$HOME/.local/bin/the-janitor`); R15-01 (checklist.tsv rows E1, E5, E8, H1, H3, H4, H7, H8: `$HOME`/`~`, op, `ss`; E4 scans the whole working tree, in-lane but working-tree sensitive); R18-01 (drift-pins.sh, `[host]`).
D. Untagged, no fleet or host reads, lone-clone PASS (46): R11-05 R11-07 R11-09 R11-10 R11-11 R12-03 R13-01 R13-02 R14-01 R15-02 R15-03 R15-04 R15-05 R16-02 R16-04 R16-05 R16-06 R17-02 R17-03 R18-02 R18-03 R21-02 R21-03 R21-04 R22-01 R22-02 R22-03 R22-04 R23-01 R23-02 R24-01 … R24-16. Empty HOME and no sibling repos, so PASS shows they are self-contained.
E. Untagged, not executed. R21-01 (L51) runs `op` from PATH (host observation `/usr/bin/op`, corpus/knowledge/cdp-bridge-1password.md:28), HOME/XDG scratch, not fleet; contract bars op, so UNRUN. R12-02 (L27) static only: every tcase is `--evaluate`, `--fixture`, a `--dotenv-bytes` POLICY refusal, or a stub `OP_REF_OP_BIN` (op-ref-probe.sh:595-751).
Expectations: only R11-08 (`unresolved=0`) and the four §2B rows depend on outside state in their expect or exit. The other 46 expectations are in-lane counts.

## 3. Findings
F1 (calibration; corrects C2 counts). Lone-clone token classes, parsed from output: 88 unlabelled UNRESOLVED = 57 sibling + 31 ufo; 15 labelled unresolved (claim-ledger.sh:739) = 7 self + 8 ufo.
- 42 of the 57 sibling tokens (7 of 15 labelled) are `kagi-shokunin/…` self-citations. Their targets exist and are tracked in the BASE clone (spot-checked: `git ls-files -- .ufo/round-20/inspection.json corpus/lessons/round-22-verifier-spotcheck.md`; os.path.exists 42/42 and 7/7). They fail only because cite_class sends any `*-shokunin/…` to `$ROOT/../…` (claim-ledger.sh:635-636). They pass in the fleet only because the lane directory is literally named kagi-shokunin.
- Other sibling misses: kake-shokunin 11, kotoba-shokunin 3, kama-shokunin 1. All 31 `.ufo/` misses (20 distinct) are absent from the lane tree: true fleet-only.
- [INFERENCE] With lane-first resolution for the lane's own name, lone-clone fleet-absent becomes 54 occurrences (15 + 31 unlabelled, 8 labelled ufo), not 88. Plan wording "after fleet_absent=88" would be wrong.
F2 (operability). Fleet presence is necessary, not sufficient. SCORECARD.md:871 records R11-08 red at the round-24 pre-move (`unresolved=2`), cause not recorded. Today's fleet control is clean: labelled=13 = 10 session URIs (claim-ledger.sh:701) + 3 labelled path tokens still unresolved (:739).
F3 (migration). `layout_skipped=N` changes the summary strings at claim-ledger.sh:1127, :1131, :1156, :1160 (all end `host_skipped=N)`). Pinned by ledger R13-03 (L38, `host_skipped=[0-9]+\)$`), R23-01 (L59, `host_skipped=0\)$`) and selftest substrings at claim-ledger.sh:1475, :1513, :1542, :1611, :1613, :1624, :1626, :1634. Needs a QM14 migration, or the count goes on its own line.
F4 (stamps). claim-ledger.tsv (stamps.tsv:5), claim-ledger.sh (:4), SCORECARD.md (:81), adjacency.tsv (:1), checklist.tsv (:3) are revision-pinned. Any `[fleet]` edit or C2 code change needs a reviewed re-stamp or R22-03 goes STALE. A note-only tag leaves the R24 identity digests unchanged (they hash ids and substrate membership).
F5 (not a `[fleet]` matter). `cells` runs any cited untagged row. SCORECARD.md:641 (Round 21 post-move, section at :633) cites R21-01 (op) and R12-02, so default `cells` executes `op` (claim-ledger.sh:870-937, :957-978). Planner decision: keep or tag.
F6 (design note for `[fleet]`). `cells` must count LAYOUT-SKIP as neither run nor failed, so R11-08's pointer earns no credit (cf. executed-only `rows_run`, claim-ledger.sh:975-977).
F7 (cwd default, not fleet). closure-dispositions.py:377-378 sets `--root` to `Path(".")`; correct only under the runner's `cd "$ROOT"` (claim-ledger.sh:574). R23-02 passes because the runner does that.
F8 (no hidden fleet reads). No gate reads ../MANIFEST.json or a /home path. The only MANIFEST hits in code are feature-claims.py FC-*-MANIFEST error codes (:327, :402, :515, :535, :578). `.ufo/` is tracked (575 files; .gitignore:1 ignores only `.ufo/interactive-sessions/`), so lane-first `.ufo/` lookups are durable in-lane.

## 4. Tag proposal and cross-check
- Add `[fleet]` to the R11-08 note (claim-ledger.tsv:22), keeping its text. Add nothing else.
- R13-03, R16-01, R16-03, R17-01: keep the single host tag. They reach fleet paths only under `--allow-host-rows`, which runs on the fleet checkout by definition. No row is double-tagged today; recommend POLICY exit 2 for any row carrying `[fleet]` with `[host]` or `[substrate]`.
- Before the C2 count enters the plan: resolve `<own-lane>-shokunin/…` lane-first, then re-count (F1).

## 5. Commands and outputs
- `git -C <lane> rev-parse HEAD` → 4587c61a348e4528717404a68912c373f3ef4d03. `ls-files | wc -l` → 684; `ls-files .ufo | wc -l` → 575; `cat-file -t c2cab35…` → commit; `rev-list --count HEAD` → 84.
- Lone clone, exit 0 and expected last line: R11-05 `DRIFT_SELFTEST: PASS (13 cases)`; R11-07 `SELFTEST OK (…)`; R11-09 and R18-03 `SELFTEST: PASS (151 cases)`; R16-02 `SCOPE_SELFTEST: PASS (61 cases)`; R21-03 `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`; R22-04 `REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)`; R24-01 `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`; R14-01 `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 …)`; R23-01 `CELL_AUDIT: CLEAN (cells=6 … host_skipped=0)`; R24-03…R24-16 `ROW_IDENTITY: <sel> count=… sha256=…` (14 PASS).
- Lone `bash corpus/scope-gate.sh --falsify`, exit 1: `SCOPE_FALSIFY: FAIL (caught=13/18 failed=5)`; failing: stale-basis, breadth-children-drift, breadth-exceeds, breadth-declared-drift, breadth-new-declared-child.
- Lone `bash corpus/scope-gate.sh --breadth`, exit 1: `SCOPE NOT-A-FILE $HOME/.local/share/the-musketeer/chrome-profile basis=lane:kake/SKILL.md:161 (resolved …/kake-shokunin/SKILL.md)`; `SCOPE NOT-A-FILE $HOME/.agents/AGENTS.md basis=lane:kotoba/…:30`; `SCOPE BREADTH-HOST-MISSING` ×4; `BREADTH_AUDIT: DEFECT (required=4 pins=4 checked=0 … unverified=4)`.
- UNRUN: R21-01 and R12-02 (static only, §2E); R13-03 (its `cells` would run op through R21-01); the 8 host-only rows and R18-01 (host state, not run by design).
