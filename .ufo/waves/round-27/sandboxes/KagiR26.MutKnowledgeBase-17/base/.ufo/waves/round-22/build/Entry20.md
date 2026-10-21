# Entry20 — `substrate-deferral` freshness/calibration audit (read-only)

**Axes:** calibration, freshness.
**Read revision:** `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD, frozen base).
**Entry blob:** `f8f7e5bd6598f217cc7bd5227ddc7e5103a3f4d0`; content `sha256 168890519978a96095bba797cfe0fb1a5d4ae94a23a71df23f81e193b8963c98`; 93 lines / 5338 bytes; read 2026-10-20.
**Scope:** `corpus/knowledge/substrate-deferral.md` and its `corpus/stamps.tsv` row. No production writes; no host gate executed; one report written.

## 1. Verdict

1. **No stale-byte mismatch.** The stamp row (stamps.tsv line 28) is exact against both the worktree file and the HEAD blob. The entry has one commit (`fecee87`, 2026-10-14); its stamp row exists at every stamps-touching commit since and never changed. It is **not** one of the "nine dropped"/"five stale" rows and needs no restoration.
2. **Substantive freshness: the contract and absence claims hold; two live-evidence counters have drifted.** All six named substrate paths are still absent on 2026-10-20. The 2026-10-14 census excerpt (`gone=23`) and scope-gate excerpt (`breadth_drift=6`) statically reproduce today as `diverged=2 gone=22 … absent=37` and `breadth_drift=5`; both gates still fail closed. Cause: `~/.agents/AGENTS.md` (shared with kotoba) is now present and mode-diverged.
3. **Append needed: yes, but only as a narrow append-only recheck/erratum.** No contract/bound/falsifier changes; no depth claim; no legacy-header count. The two counter quotes are dated evidence, not the mechanism, so the historical line must be preserved, not rewritten.
4. **Integration caveat:** the live worktree is dirty (21 tracked files). Its `corpus/claim-ledger.sh` is a different revision from the stamped HEAD and changes the selftest count 97→108. The entry's line 85 (`cases 95-97`) and R11-09/R18-03 (`97 cases`) are correct only for the stamped revision; if the worktree revision lands they must migrate with it.

## 2. Byte/stamp audit (observed)

- stamps.tsv line 28: `corpus/knowledge/substrate-deferral.md<TAB>168890519978a96095bba797cfe0fb1a5d4ae94a23a71df23f81e193b8963c98<TAB>93<TAB>5338`.
- Worktree `sha256sum` = `1688905…c98`; `wc -lc` = `93 5338`; `git hash-object` = HEAD blob = fecee87 blob = `f8f7e5b…`.
- History: added at `fecee8743e52eb8fb5fbb40782934cb619a1a96e`; the file is touched by no later commit; stamps.tsv commits `fecee87`, `c41af82`, `e1544c1` all carry the identical row. No stale bytes, no dropped row, no migration for this row.
- Docs grammar: exactly one `^Reverify: ` line (line 13, `Reverify: R18-01, R11-09`); both ids resolve (R18-01 is claim row 48; R11-09 row 23); the entry is pinned. A second `Reverify:` line would die at `corpus/claim-ledger.sh:878` (exit 2), so any append must not add one.

## 3. Substantive freshness (observed / inference)

Observed 2026-10-20 (read-only probes):
- All six paths in lines 4–7 are absent; `the-janitor` is not on PATH.
- `~/.config/opencode/opencode.json` present, mode 0600; `~/.agents/AGENTS.md` present, mode 0644.
- Drift baseline: 13/15 rows absent; the two present rows are both mode-diverged (`opencode.json` 0600 vs declared 0644; `AGENTS.md` 0644 vs declared 0600). Static result remains `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20)` — the quoted fragment is still exact.
- Census static reproduction: 18/20 assets missing + 4/4 scan dirs missing ⇒ `gone=22`; 2 present assets both mode-diverged ⇒ `diverged=2`; 15/15 runtime rows missing + 22/22 `state-shape.tsv` assertions on absent paths ⇒ `absent=37`; `ok=0`. Predicted line: `SURFACE_CENSUS: DRIFT (diverged=2 gone=22 link=0 unlisted=0 crosscheck=0 shape=0 unverified=0 ok=0 absent=37 skipped=0)`, exit 1. *(Static reproduction from the shipped TSV/script; not a gate run.)*
- Scope breadth static reproduction: `~/.config/opencode` 3 children/1 declared vs pin 20/4 ⇒ 2 drifts; `~/.local/bin` 50/0 vs 105/2 ⇒ 2; `~/.agents` 3/1 vs 4/1 ⇒ 1; `~/.local/share/the-musketeer/chrome-profile` missing ⇒ unverified 1. Totals `breadth_drift=5 breadth_unverified=1` vs the quoted 6/1. Gate still `DEFECT`. *(Static.)*
- Checklist static evaluation: 6 expected failures (E1 census→drift, E5 SETUP, E8 handoff absent, H1 handler absent, H3 overlay absent, H4 agent md absent); H7 accepts exit 2 + `db not found`; E4/H8 pass. Quoted `failed=6` still exact. *(Static reasoning over `corpus/checklist.tsv`; not run.)*
- Transcript: DB absent ⇒ `db not found`, exit 2 (consistent).
- op-ref-probe: janitor binary absent ⇒ `SETUP`, exit 2 (consistent in kind; `op` is now on PATH, so the SETUP reason differs).

Delta cause — **[INFERENCE, high confidence]**:
- The 2026-10-14 line had `gone=23`, `ok=0`, `diverged=1` (`corpus/lessons/round-18.md:22-23`). `corpus/lessons/round-18.md:18-20` records `opencode.json` among the three surviving `~/.config/opencode` children at round 18 (`LOG.md:733` carries the verdict), so it was the one diverged asset and 19/20 assets were missing. Therefore `~/.agents/AGENTS.md` was absent then and is present now. Its appearance explains both deltas: census `gone −1`, `diverged +1`; scope breadth agents declared 0→1, drift −1 (a 2-child or 3-child, 0-declared round-18 state both yield 2 drifts; today's 3/1 yields 1).

**Freshness gap:** the declared recheck (`R18-01`, `R11-09`) does not re-measure census counters or scope breadth. The drift is therefore invisible to the entry's own `Reverify:` declaration. R18-01 remains a valid absence pin: its exact all-GONE drift line still statically reproduces.

## 4. Calibration findings

**C1 — predicate overclaim (lines 31–32 and 62).** The text says “executable file” / “presence+exec-bit of ONE file”, but the implementation is `[[ -x "$HOME/.local/bin/the-janitor" ]]` (`corpus/claim-ledger.sh:138-143`), which is true for a searchable directory (verified: `[[ -x /tmp ]]` is true). Either narrow the prose to “executable path” or tighten code to `[[ -f … && -x … ]]`. Bound 2's poisoned-stub outcome still holds; a directory at the pinned path would also un-defer rows. Low severity, but a feature-specific spec/code mismatch.

**C2 — absolute overclaim (lines 21–22).** “0 code changes could make them pass” is falsified by the round's own fix: R11-03 (claim row 17) is one of the eleven tagged rows, and its command `bash corpus/surface-census.sh --selftest` now statically prints `SELFTEST: PASS (16 cases)` on an absent-handler host via `skip-case` 15/16 (`corpus/surface-census.sh:816-823,846-847`; 12 `run_case` + 4 manual increments = 16). R16-03's own note says “partially runs — deferred instead” (claim row 41). Correct bound: no change to the absent substrate's facts could make the live gate readings pass; code could hermeticize/skip (and the round did so for the census selftest) while keeping the rows deferred by declared dependence. This is a wording calibration correction, not a demand to untag R11-03.

**C3 — excerpt presented as verbatim (line 8).** The actual 2026-10-14 line carried the nonzero `diverged=1` (`corpus/lessons/round-18.md:22-23`; `LOG.md:733`), which the backticked fragment omits without an ellipsis. Mark it as an excerpt (`diverged=1 gone=23 … absent=37`) in the append; do not rewrite the historical line.

**C4 — adjacent ledger calibration (not this entry).** R18-02 (`corpus/claim-ledger.tsv:49`) says “10 tagged rows plus this row's own pattern”, but the command does **not** self-match: the row text is `\[substrate\]` (backslash before the closing bracket), so the contiguous literal `[substrate]` is absent; both GNU grep and Python give 0 matches on that line. The count 11 is exactly the 11 tagged data rows (verified at `fecee87` and HEAD). Pin value correct, explanatory note wrong. Related: `SCORECARD.md:322-324` says “10 rows are carried”/“10 claims are parked” against the actual 11, and describes R18-01 as `sha256sum` on the handler path while the row is `bash corpus/drift-pins.sh` (row 48; the entry describes it correctly). Fix the note/scorecard text only; do not change the pinned 11.

**C5 — wave-level pin debt (independent confirmation).**
- At HEAD, 6/63 stamp rows are stale: the five named in `corpus/lessons/round-21.md:85` (`config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md`, `lessons/round-18.md`) plus `LOG.md`. Historic causes: `f4a8dd9` (round-16) staled the five; `bad9088` (round-19) staled the lesson; `c2cab35` staled LOG. This entry's row is clean.
- Row-set history across the nine stamps.tsv commits is monotonic additions only (`28→33→44→48→52→54→56→63`, 0 removals). “Nine previously dropped stamps” is not supported as a membership deletion by reachable history; it is the nine stale rows at `aea7a43` recorded in `LOG.md:982-984`, of which five remain stale. This matches `.ufo/waves/round-22/build/ReviewStamps.md:9-26` and `AuditPinHistory.md:13-33`.
  - Exact `aea7a43` stale set (9/56): `config-layering` 848b8e50→9d4ac8c2; `handler-on-disk-state` 811572dc→df6a5e5d; `handler-trust-boundary` 263c7b0e→fa17fff3; `janitor-env-contract` 88dca63a→dac43ef9; `lessons/round-18` 614335f2→b00b7dd8; `op-ref-probe.sh` 509f084a→0f1945e8; `README.md` 6ddda47d→d669dfbf; `LOG.md` e6db90d2→904e71e9; `SCORECARD.md` f3e61bfe→fa452bc3.
  - Exact HEAD stale set (6/63): the first five above with the same new values, plus `LOG.md` 60a8fd36→51e76cf1 (the `c2cab35` wiki-link edit). `op-ref-probe.sh`, `README.md`, `SCORECARD.md` were re-pinned at round 21 (`e1544c1`); row sets grew 56→63 with 0 removals and the 7 documented additions.
- Live worktree (not the frozen base): 21 tracked files are dirty, all 21 have stamp rows, and every one of those rows still matches the HEAD blob rather than its worktree file. Do not re-pin until reviewed/landed. Specifically `corpus/claim-ledger.sh` worktree `2dd83f8c…` (1371 lines/83655 bytes) vs stamp `93c58272…` (1319/79301); +11 `tcase` calls, 0 removed ⇒ 105 + 3 = **108 cases**; defer cases move **95-97 → 106-108**. If that revision lands, R11-09/R18-03 (`97 cases`) and entry line 85 must migrate in the same integration, with the old→new count recorded.

## 5. Append decision and exact content scope

**Recommendation: append-only after line 93, no second `Reverify:` line.** Content (described; not drafted as production prose):

1. **Recheck 2026-10-20 (freshness):** six substrate paths still absent; handler not on PATH; the 2026-10-14 numbers are historical, not current.
2. **Counter delta:** current static census line `diverged=2 gone=22 … absent=37`; cause `~/.agents/AGENTS.md` present (0644 vs declared 0600, shared with kotoba); scope-gate `breadth_drift=5 breadth_unverified=1`; drift-pins still `files_bad=15 symbols_bad=20`; checklist still `failed=6`; transcript/op-ref consistent in kind.
3. **Calibration errata:** `-x` accepts a directory (or code tightens to `-f && -x`); correct the “0 code changes” bound per C2; mark line 8 as an excerpt including `diverged=1`.
4. **No change** to the tag grammar, DEFER contract, `deferred=`/`row_deferred=` shapes, bounds 1–5, or falsifiers.

Do **not**: restore substrate, re-pin baselines to an empty host, add a second `Reverify:` line, claim depth, or delete/replace the old stamp.

If the wave prefers zero body change: keep the same content in this report and open a new claim row for the census/selftest check; then no stamp migration occurs, but the entry's live-evidence counters remain un-reconciled in the artifact.

## 6. Exact recheck scope

Read-only, repeatable (already exercised for this report):

```sh
sha256sum corpus/knowledge/substrate-deferral.md              # 1688905…c98
wc -lc corpus/knowledge/substrate-deferral.md                 # 93 5338
git rev-parse HEAD:corpus/knowledge/substrate-deferral.md     # f8f7e5b…
git show fecee87:corpus/knowledge/substrate-deferral.md | sha256sum   # 1688905…c98
/usr/bin/grep -c '^corpus/knowledge/substrate-deferral.md' corpus/stamps.tsv   # 1
test -e "$HOME/.local/bin/the-janitor" … (six paths)          # all absent
/usr/bin/grep -c '^Reverify: ' corpus/knowledge/substrate-deferral.md          # 1
```

Host gates (parent, after integration; **not** run here):

```sh
bash corpus/claim-ledger.sh verify        # 11 DEFER expected; runs R18-01/R18-02/R18-03
bash corpus/drift-pins.sh                 # exact R18-01 pin: files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20, exit 1
bash corpus/surface-census.sh             # expect diverged=2 gone=22 … absent=37, exit 1
bash corpus/scope-gate.sh                 # expect breadth_drift=5 breadth_unverified=1, DEFECT exit 1
bash corpus/surface-census.sh --selftest  # expect PASS (16 cases), skip-case 15/16
bash corpus/claim-ledger.sh --selftest    # 97 cases at HEAD; 108 if the worktree revision lands
bash corpus/claim-ledger.sh docs          # CLEAN entries=24 row_linked=21 by_hand=3 at HEAD; recount after other entries land
```

Run `docs` once after **all** round-22 doc edits, not per seat: additional entries move the `entries=` / `row_linked=` counts and R14-01's expectation.

## 7. Append-only / stamp migration requirement

- Preserve lines 1–93 byte-for-byte (5338 bytes); append only.
- Record the old triplet verbatim in the append and the round report:
  `corpus/knowledge/substrate-deferral.md<TAB>168890519978a96095bba797cfe0fb1a5d4ae94a23a71df23f81e193b8963c98<TAB>93<TAB>5338`.
- After the append, update **exactly one** stamps.tsv row. `stamp` refuses to shrink unless every existing path is named (`corpus/claim-ledger.sh:232-255`); `--prune` is forbidden. Prefer a targeted one-row update, or name all 63 paths and diff-review that only this row changed; abort if any other row moves (that would launder in-flight edits or stale rows).
- Do not regenerate stamps.tsv wholesale, do not delete the old value, and do not re-pin the six stale HEAD rows or the 21 dirty-worktree rows as part of this entry's correction.
- No second `Reverify:` line (`corpus/claim-ledger.sh:878`).
- If R11-09/R18-03 migrate to the worktree script, record `97→108` as an expectation migration in the same integration, not a silent count edit.

## 8. Absent-source limits / unresolved

- No host gate was executed. Census/scope/checklist/drift/op-ref/transcript values are **static reproductions** against shipped TSV/scripts and live file metadata, except the six path-absence probes (observed).
- The 2026-10-14 gate outputs are same-round narrative evidence (`corpus/lessons/round-18.md`, `LOG.md`), not independent captures.
- The in-flight whole-word-regex claim in lines 46–48 has no committed artifact; the shipped code has only the bracket test. Narrative, unverified — do not build on it.
- The live worktree (21 dirty tracked files, 74 untracked files) is external to this audit and not attested; only the frozen-base blobs and the entry file were audited.
- `docs`/`verify`/`--selftest` were not run; docs-audit grammar was checked statically. The 2026-10-20 census/breadth counters are predictions from the gate's own logic, not observed gate output.

## 9. Installs

None.

**Read revision:** `c2cab35bc92e57e39e5489bac3386db078345b3f`; entry blob `f8f7e5bd6598f217cc7bd5227ddc7e5103a3f4d0`; file `sha256 168890519978a96095bba797cfe0fb1a5d4ae94a23a71df23f81e193b8963c98`, 93 lines/5338 bytes; substrate probes 2026-10-20.
