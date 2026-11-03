# ScoutSelf — Self-Description Surfaces Audit (Round 32)

- **Seat:** `ScoutSelf` (scout)
- **BASE:** `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`
- **Frozen Plan:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-32.md` (`507dd9f`)
- **Scope:** Read-only data-walk over self-description surfaces (`PROVINCE.md`, `corpus/README.md`, `SHONEN.md`, `SCORECARD.md`, `corpus/lessons/round-31.md`, `corpus/QUALITY.md`, `SKILL.md`).
- **Lane Tree:** Read-only; no lane-tracked files modified.

---

## 1. Candidate Mismatches Table

Every statement across the 7 self-description surfaces evaluated against live repo state:

| file:line | quote (≤15 words) | command | observed | covered-by |
|---|---|---|---|---|
| `PROVINCE.md:90` | `Frontier — explored, not held: OIDC workload-federation trust policy; secret-scanning detection vs verification;` | `grep -nE -i 'OIDC workload-federation\|secret[- ]scanning' PROVINCE.md` | Lines 88/89 define themes as Core; line 90 still lists both in Frontier | Yes (SD1) |
| `corpus/README.md:117` | `OIDC workload-federation trust policy — moved to core in round 31` | `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -n 'moved to core'` | Line 117 inside `## Frontier` contains `moved to core` | Yes (SD2) |
| `corpus/README.md:118` | `Secret scanning: detection versus verification — moved to core in round 30` | `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -n 'moved to core'` | Line 118 inside `## Frontier` contains `moved to core` | Yes (SD2) |
| `SHONEN.md:6,8,10,12` | `SKILL.md ... LOG.md:758 ... corpus/lessons/round-19-recensus.md ... corpus/claim-ledger.sh ... PROVINCE.md` | `grep -oE '(corpus/[A-Za-z0-9_./-]+|LOG\.md\|SKILL\.md\|PROVINCE\.md)' SHONEN.md \| sed -E 's/[.,;:]$//' \| sort -u \| while read -r p; do test -e "$p" \|\| echo "$p"; done` | All 7 distinct cited file paths exist on disk (0 missing) | Yes (SD3) |
| `corpus/lessons/round-31.md:214` | `M31-6 (new mistake): an absence sweep is language-blind unless its needles cover` | `diff <(grep -oE '\bM31-[0-9]+\b' corpus/lessons/round-31.md \| sort -u) <(grep -E '^\|[[:space:]]*M31-[0-9]+' corpus/lessons/round-31.md \| awk -F'\|' '{print $2}' \| tr -d ' ' \| sort -u)` | `M31-6` named in lesson text but lacks row in `## Mistakes` table | Yes (SD4) |
| `SCORECARD.md:14` vs `:1285` | `3 operator-routed reds (R25-02,R29-01,R29-02) stay red` vs `summary whose only non-clean rows are the three operator-routed ids.` | `sed -n '1285p' SCORECARD.md \| grep -oE '\bR(25-02\|29-01\|29-02)\b'` | None of the 3 red IDs are cited as distinct claim IDs in calibration row | Yes (SD5) |
| `corpus/lessons/round-30-verifier-spotcheck.md:41` | `` `corpus/README.md:64/65/67` now state 99/68/29 ✓. `` | `bash corpus/claim-ledger.sh citations` | Emits `UNRESOLVED ... corpus/README.md:64/65/67 (local)` | Yes (SD6) |
| `corpus/lessons/round-31.md:121` | `` (SKILL.md:46, PROVINCE.md:73, `corpus/README.md`:64/65/67) — re-corrected `` | `bash corpus/claim-ledger.sh citations` | Emits `UNRESOLVED ... corpus/README.md`:64/65/67 (local)` | Yes (SD6) |
| `corpus/lessons/round-31.md:44` | `Audience occurs twice, both in the response section` | `grep -n 'Audience' <(grep -v '^#' corpus/source-fetches.tsv \| awk -F'\t' '$1=="S063"{print $NF}')` | `Audience` occurs on line 343 (Response Elements) and line 593 (sample XML response) | No (R3 routed item) |
| `corpus/QUALITY.md:154` | `corpus/lessons/round-31.md §Mistakes M31-1 (landed here, with the round-30 plan` | `grep -n 'QM32' corpus/QUALITY.md; grep -n 'QM32' corpus/lessons/round-31.md` | QM32 cites `M31-1`; in round-31.md:185 QM32's witness row is actually `M31-5` | No (extra class) |
| `SCORECARD.md:1285` | `| calibration | 9 → 9 | ... The audit completes to a CELL_AUDIT:` | `bash corpus/claim-ledger.sh cells` | Exits 2 (`CELL_AUDIT: POLICY`, FAIL R25-02, POLICY R29-01, R29-02); score remains 9 | No (R5 routed item) |
| `SKILL.md:619-620` | `SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)` | `bash corpus/surface-census.sh` | Exits 1 `SURFACE_CENSUS: DRIFT` (the-janitor handler absent on host; historical repro) | No (expected substrate) |
| `SHONEN.md:6` | `citation run CITATION_GATE: CLEAN (cites=891 docs=53 ...) at LOG.md:758` | `bash corpus/claim-ledger.sh citations` | Live gate at BASE is BROKEN (unresolved=2); LOG.md:758 holds historical round-18 record | No (historical pointer) |

---

## 2. SD1–SD6 Confirmation Table

Each BASE count declared in `plans/round-32.md` was independently measured:

| Check | Scope / Plan Definition | BASE Expected | Measurement Command | Observed | Verdict |
|---|---|---|---|---|---|
| **SD1** | `PROVINCE.md` lines naming a theme in `Frontier` while `Core` names the same (`OIDC workload-federation`, `secret[- ]scanning`) | **2** | `grep -nE -i 'OIDC workload-federation\|secret[- ]scanning' PROVINCE.md` (line 90 names both themes) | 2 | **Confirmed** |
| **SD2** | `corpus/README.md` lines inside `## Frontier` containing `moved to core` | **2** | `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -c 'moved to core'` (lines 117, 118) | 2 | **Confirmed** |
| **SD3** | `SHONEN.md` evidence tokens (`corpus/…`, `LOG.md`, `SKILL.md`, `PROVINCE.md`) whose file does not exist | **0** | `grep -oE '(corpus/[A-Za-z0-9_./-]+|LOG\.md\|SKILL\.md\|PROVINCE\.md)' SHONEN.md \| sed -E 's/[.,;:]$//' \| sort -u \| while read -r p; do test -e "$p" \|\| echo "$p"; done \| wc -l` | 0 | **Confirmed** |
| **SD4** | Distinct `M31-n` ids named in `corpus/lessons/round-31.md` with no row `^\| M31-n ` in that file | **1** | `diff <(grep -oE '\bM31-[0-9]+\b' corpus/lessons/round-31.md \| sort -u) <(grep -E '^\|[[:space:]]*M31-[0-9]+' corpus/lessons/round-31.md \| awk -F'\|' '{print $2}' \| tr -d ' ' \| sort -u) \| grep '^<' \| wc -l` (`M31-6`) | 1 | **Confirmed** |
| **SD5** | Red ids in SCORECARD `lane-status:` (`R25-02,R29-01,R29-02`) absent from latest `calibration` row of latest `## Round` | **3** | `for id in R25-02 R29-01 R29-02; do sed -n '1285p' SCORECARD.md \| grep -q "\b$id\b" \|\| echo "$id absent"; done \| wc -l` | 3 | **Confirmed** |
| **SD6** | `UNRESOLVED` lines printed by `bash corpus/claim-ledger.sh citations` | **2** | `bash corpus/claim-ledger.sh citations` (redirected to scratch; `grep -c '^UNRESOLVED' citations.txt`) | 2 | **Confirmed** |

**BASE Sum:** 2 + 2 + 0 + 1 + 3 + 2 = **10** (exact match to `plans/round-32.md` line 34).

---

## 3. SD6 UNRESOLVED Paths and Minimal Correct Repairs

`bash corpus/claim-ledger.sh citations` emitted exactly two UNRESOLVED lines:

### Unresolved Citation 1
- **File and line:** `corpus/lessons/round-30-verifier-spotcheck.md:41`
- **Line text:** `` doc cells `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64/65/67` now state 99/68/29 ✓. ``
- **Unresolved token:** `corpus/README.md:64/65/67` (`local`)
- **Root cause:** In `corpus/claim-ledger.sh:742`, `norm_tok` uses regex `^(.*)[,:][0-9]+([-,][0-9]+)*$` to strip line references. Slashes `/` in `:64/65/67` are not recognized as delimiters, so the trailing `:64/65/67` is not stripped. The gate searches for a literal path `corpus/README.md:64/65/67` which does not exist.
- **Minimal Correct Repair (Syntax to existing lane path):**
  Change `:64/65/67` to comma-separated `:64,65,67` or range `:64-67` or bare path:
  ```markdown
  `corpus/README.md:64,65,67`
  ```
  `norm_tok` strips `:64,65,67`, resolving cleanly to existing file `corpus/README.md`.
- **Alternative Gate-Accepted Repair:** Add an accepted marker matching `MARK_RE` (`scratch|ephemeral|relocat|formerly|no longer|removed|renamed|historical`) on the line, e.g. `(formerly)` or `(relocated)`, classifying it as `LABELED`.

### Unresolved Citation 2
- **File and line:** `corpus/lessons/round-31.md:121`
- **Line text:** `` had corrected (SKILL.md:46, PROVINCE.md:73, `corpus/README.md`:64/65/67) — re-corrected ``
- **Unresolved token:** `corpus/README.md`:64/65/67` (`local`)
- **Root cause:** Two defects:
  1. The closing backtick was placed immediately after `corpus/README.md` before `:64/65/67` without spacing: `` `corpus/README.md`:64/65/67 ``. `norm_tok` strips only leading backtick `t=${t#\`}`, leaving a trailing backtick inside the token.
  2. The slashes `:64/65/67` prevent `norm_tok` from stripping the line reference.
- **Minimal Correct Repair (Syntax to existing lane path):**
  Change `` `corpus/README.md`:64/65/67 `` to:
  ```markdown
  `corpus/README.md:64,65,67`
  ```
  (or `` `corpus/README.md:64-67` `` or `` `corpus/README.md` ``). This strips cleanly and resolves to `corpus/README.md`.
- **Alternative Gate-Accepted Repair:** Add an accepted marker matching `MARK_RE` (`scratch|ephemeral|relocat|formerly|no longer|removed|renamed|historical`) on the line, classifying it as `LABELED`.

---

## 4. Extra Mismatch Classes Not Covered by SD1–SD6

1. **Lesson Pointer to Wrong Mistakes Table Row (`corpus/QUALITY.md:154`):**
   - Line 154 states QM32 was produced by: `corpus/lessons/round-31.md §Mistakes M31-1 (landed here, with the round-30 plan as the red witness it fails)`.
   - In `corpus/lessons/round-31.md:185`, row `M31-1` is "unreachable counter nearly frozen". QM32's witness row is actually `M31-5` ("QM32's own red witness").
2. **S063 Occurrence Count Precision (`corpus/lessons/round-31.md:44`):**
   - States: "`Audience` occurs twice, both in the response section".
   - Observed: `Audience` occurs on line 343 (Response Elements) and line 593 (example XML response). Covered by routed item R3 (appended corrigendum), not SD1–SD6.
3. **Scorecard Calibration Score 9 Beside Non-Clean Audit Row (`SCORECARD.md:1285`):**
   - Calibration score is 9 while `bash corpus/claim-ledger.sh cells` exits 2 with non-clean rows (`R25-02` FAIL, `R29-01`/`R29-02` POLICY). SD5 checks naming of the 3 red IDs in the calibration row; the score 9 itself is routed as R5 with operator ownership.

---

## 5. Artifacts and Commands Executed

### Files Written
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ScoutSelf.md` (this report)
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ScoutSelf-citations.txt` (receipt of `bash corpus/claim-ledger.sh citations`)
- Scratch: `/fast/scratch/hyaku/kagi-r32/ScoutSelf/citations.txt`

### Commands Run (with observed exit codes)
1. `mkdir -p /fast/scratch/hyaku/kagi-r32/ScoutSelf/tmp /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build` → exit 0
2. `cd /home/vgpnk/Projects/shokunin/kagi-shokunin && bash corpus/claim-ledger.sh citations > /fast/scratch/hyaku/kagi-r32/ScoutSelf/citations.txt 2>&1` → exit 1 (89.08s, expected BROKEN unresolved=2)
3. `grep -nE -i 'OIDC workload-federation|secret[- ]scanning' PROVINCE.md` → exit 0 (SD1: 2 themes in line 90)
4. `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md | grep -n "moved to core"` → exit 0 (SD2: 2 lines)
5. `grep -oE '(corpus/[A-Za-z0-9_./-]+|LOG\.md|SKILL\.md|PROVINCE\.md)' SHONEN.md | sed -E 's/[.,;:]$//' | sort -u | while read -r p; do test -e "$p" || echo "$p"; done | wc -l` → exit 0 (SD3: 0 missing)
6. `diff <(grep -oE '\bM31-[0-9]+\b' corpus/lessons/round-31.md | sort -u) <(grep -E '^\|[[:space:]]*M31-[0-9]+' corpus/lessons/round-31.md | awk -F'|' '{print $2}' | tr -d ' ' | sort -u) | grep '^<' | awk '{print $2}'` → exit 0 (SD4: `M31-6`)
7. `for id in R25-02 R29-01 R29-02; do sed -n '1285p' SCORECARD.md | grep -o "\b$id\b" || echo "$id absent"; done` → exit 0 (SD5: 3 absent)
8. `grep -c '^UNRESOLVED' /fast/scratch/hyaku/kagi-r32/ScoutSelf/citations.txt` → exit 0 (SD6: 2)
9. `python3 corpus/self-counts.py` → exit 2 (claims=62 stale=0 policy=2)
10. `bash corpus/claim-ledger.sh cells` → exit 2 (cells=222 row_pointed=162 policy=2)
11. `bash corpus/surface-census.sh` → exit 1 (the-janitor absent on host)
12. `cp /fast/scratch/hyaku/kagi-r32/ScoutSelf/citations.txt /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ScoutSelf-citations.txt` → exit 0
