# Round 45 — closure errata (draft for the L1 to place)

source: {ADMITTED_ENTRY_PATH} (the round-45 ISO/IEC 11770-3 knowledge entry) — the entries below are corrections to **existing** held ground, not new coverage claims; they restate two round-44 statements that the round-44 verifier spot-check (`corpus/lessons/round-44-verifier-spotcheck.md` §5, items 1 and 2) found defective, and they are **appended, never rewritten** (PROTOCOL §Evidence standard: "A falsified claim in an append-only file gets a named correction entry").
verified-at: 2026-11-05 (every measurement below was taken in this round, from the lane tree at the predeclaration commit `307fb50da825d6e6f2b5c7981c71556d35611142` and from the round-44 claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a`; no historical file was edited)
recheck: on-release — the stamp-drift reading is re-run whenever `corpus/stamps.tsv` changes; the red-witness label is a historical reading and is not re-run.

# Round 45 — late corrections to round-44 evidence statements

Both entries correct statements made in round 44. The superseded text stays in place, byte-identical; this file is the correction entry.

## E45-1 — stamp migration undercount (class: `landing`)

**Superseded text (round 44, `.ufo/waves/round-44/controls/stamp-migration.txt` and lesson `corpus/lessons/round-44.md` §Mistakes M44-10):** the stamp verdict was stale because of the three round-43 gate scripts (`corpus/prefreeze-control.sh`, `corpus/self-description-sweep.sh`, `corpus/surface-census.sh`, commit `542885e`), and four other changed rows are attributed to round 44.

**Corrected statement.** The round-44 migration undercounted the drifted set. The correct statement is that at the round-44 claim BASE `d54109d`, **seven stamp rows out of step** — `LOG.md` (recorded 1783/148801 vs actual 1794/151649), `SCORECARD.md` (1595/196478 vs 1629/202119), `corpus/QUALITY.md` (218/38737 vs 227/40705), `corpus/SOURCES.md` (258/92005 vs 258/92061), **plus the three round-43 scripts**. The round-44 text named three of the seven as the cause and attributed the remaining four to round 44; the correct reading is that seven stamp rows out of step at that BASE, and the three scripts are three of them, not the whole set.

**Current state (measured 2026-11-05).** Stamp drift at the round-45 predeclaration commit `307fb50` is **0**: `python3 .ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py <BASE archive>` → `STAMP_DRIFT: rows=123 drift=0`, exit 0.

**Red witness (the fix is shown able to fail).** The same scratch copy with one byte appended to the stamped root `LOG.md` reads `STAMP_DRIFT: rows=123 drift=1` / `DRIFT LOG.md`, exit 1. A fix of this class counts only once that red witness reads non-zero.

**Not claimed.** This entry does not re-derive the round-44 migration, does not rewrite `stamp-migration.txt` or lesson M44-10, and makes no claim about which round last edited each of the seven files beyond what the closure measured.

## E45-2 — red-witness label restated (class: `self-description`)

**Superseded label (round 44, `.ufo/waves/round-44/controls/amend-a1-redwitness.txt`, line 16):** `C2 clean four-line receipt at BASE (expect 0: gate absent at BASE? see note): 1`.

**Restated label.** `C2 clean four-line receipt at BASE (gate present at BASE; a valid receipt over a present gate reads 1 by design): 1`.

**Why.** The gate is **present** at BASE: `git cat-file -e d54109d:corpus/controls-replay.sh` exits 0. The superseded label's parenthetical carried an expectation ("expect 0") and a question ("gate absent at BASE? see note") that the round-44 record never answered — no such note exists in the file. The reading **1** is correct under the counter's design; the expectation in the label was the wrong part. This entry names the true reason and **appends** it; the round-44 line is not rewritten.

**Not claimed.** The reading itself is unchanged and is not re-asserted as a new measurement: the four-line receipt, the counter and its revision are round-44 evidence, and this entry corrects only the label's stated expectation.

## Placement note for the L1

- Both entries are corrections to append-only files, so they are placed as this file plus a pointer from `corpus/lessons/round-45.md` §Errata. Nothing in `corpus/lessons/round-44.md`, `.ufo/waves/round-44/controls/stamp-migration.txt` or `.ufo/waves/round-44/controls/amend-a1-redwitness.txt` is edited.
- The stamp-migration erratum (E45-1) is the remaining item of the round-45 mined mistake M45-1; it lands only together with the red witness above, so the fix is not counted before the witness reads non-zero.
- {ERRATA_PLACEMENT_PATH} (the path the L1 places this file at), {ERRATA_LANDED} (status), {ERRATA_COMMIT} (the landing commit that carries it).
