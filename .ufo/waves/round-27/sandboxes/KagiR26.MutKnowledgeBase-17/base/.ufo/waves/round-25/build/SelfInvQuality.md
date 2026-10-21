# SelfInvQuality — round-25 C1 inventory: QUALITY.md numeric self-claims

Target: `corpus/QUALITY.md`, 112 lines, sha256 `95a45d87…3bd3c410`, equal to `corpus/stamps.tsv:66`. Revision: BASE `4587c61a348e4528717404a68912c373f3ef4d03`, read in sandbox clone `/fast/scratch/kagi-r25/SelfInvQuality/lane` (`git clone` + `checkout` exit 0; `rev-parse HEAD` = BASE). Read-only: grep, sed, sha256sum, wc, test. No gate, `verify`, `cells` or `--selftest` run (no QUALITY claim names a selftest count). No ledger row binds QUALITY.md (`grep -c QUALITY corpus/claim-ledger.tsv` → 0, exit 1), so every live value cites the command that produced it. No tools installed or updated. Nothing edited except this report.

CURRENT = present tense or unqualified pin. HISTORICAL = explicitly dated to a round or revision. Line numbers are QUALITY.md's unless a file is named. `<lane>` = the sandbox clone above.

## CURRENT (19 claims)

| file:line | phrase | class | claimed | live | source (command, exit) | STALE? |
|---|---|---|---|---|---|---|
| QUALITY.md:6 | "Tier definitions live in `corpus/SOURCES.md` (contract v1)" | CURRENT | SOURCES contract v1 | no `contract` word in SOURCES.md; `contract v<N>` only in historical LOG.md:973 and plans/round-21.md:14; "tier" only at SOURCES.md:5 (column header) and :136 (command reference), no definitions | `grep -c -i contract corpus/SOURCES.md` → 0 (exit 1); `grep -rln -i 'contract v[0-9]' --include=*.md --exclude-dir=.git --exclude-dir=.ufo <lane>` → LOG.md, corpus/QUALITY.md, plans/round-21.md; `grep -n -i tier corpus/SOURCES.md` → 5, 136 | **YES (unlocated)** |
| QUALITY.md:24 | "the pre-commit sweep stays empty" (QA5) | CURRENT (absence) | 0 matches | 0 lane-local matches for `op:/{2}`; the sweep itself is fleet-level (`corpus/sources-census.sh:98` names "the fleet pre-commit sweep"), outside the lane tree | `grep -cE 'op:/{2}' corpus/QUALITY.md` → 0 (exit 1) | no (lane-local); fleet sweep UNBOUND |
| QUALITY.md:31 | "One row per mistake class … that no row of the admission bar … captured" | CURRENT (count) | 11 rows (QM1–QM11) | round-21 §Mistakes has 12 classes M1–M12, all before-cells `none`; M8 excluded ⇒ 11; QM1–QM11 map 1:1 to M1–M7 and M9–M12 | `grep -cE '^\| M[0-9]+ ' corpus/lessons/round-21.md` → 12; QM count → 11 (command log) | no |
| QUALITY.md:33–34 | "`M8` — the honest stop … takes no criterion" | CURRENT (count 0) | 0 rows cite M8 | whole-word M8 occurs only at line 33 (the note itself) | `grep -n -w 'M8' corpus/QUALITY.md` → 33 (exit 0) | no |
| QUALITY.md:39 | "`SCORECARD.md` §Round-19 correction (line 454)" | CURRENT (pin) | line 454 | line 454 is a table row `\| 21 \| depth (C1) …`; the heading is at 458 | `sed -n '454p;468p' SCORECARD.md`; `grep -n -E 'Round-19 correction\|Current baseline' SCORECARD.md` → 458, 472 | **YES (+4)** |
| QUALITY.md:40 | "`round-15.md` §Corrigendum (line 112)" | CURRENT (pin) | line 112 | line 112 = `## Corrigendum (round 16, measured)` | `grep -n 'Corrigendum' corpus/lessons/round-15.md` → 112 (and 123, not a heading) | no |
| QUALITY.md:41 | "`round-10.md` (lines 44, 63)" | CURRENT (pin) | 44, 63 | 44 = "fail-open, so an unread shape class could still print `CLEAN`" (item 3); 63 = CE3 row "`SKIP` is fail-open" | `sed -n '44p;63p' corpus/lessons/round-10.md` | no |
| QUALITY.md:41 | "`round-16.md` (line 68)" | CURRENT (pin) | line 68 | line 68 = defect 8: summary `PASS (caught=7/7)` over a `FALSIFY FAIL` line | `sed -n 68p corpus/lessons/round-16.md` | no |
| QUALITY.md:42 | "`round-18.md` §The defect worth fixing, item 1" | CURRENT (pin) | item 1 | heading line 31 `## The defect worth fixing (class d)` (`_grep` of round-18 headings); item `1.` at line 35 | `sed -n 35p corpus/lessons/round-18.md` | no |
| QUALITY.md:44 | "`SCORECARD.md` §Current baseline — round-16 re-dispatch (line 468)" | CURRENT (pin) | line 468 | line 468 is prose inside the Round-19 correction block; the heading is at 472 | `sed -n '454p;468p' SCORECARD.md`; `grep -n -E 'Round-19 correction\|Current baseline' SCORECARD.md` → 472 | **YES (+4)** |
| QUALITY.md:45 | "`round-19-recensus.md` §Named debt (line 40)" | CURRENT (pin) | line 40 | line 40 = `<FILL ON STAMP>` debt row; §Named debt heading at 30 | `sed -n '30p;40p;47p;49p' corpus/lessons/round-19-recensus.md` | no |
| QUALITY.md:46 | "`round-12.md` §L2 wave (lines 84-98)" | CURRENT (pin) | 84–98 | heading at 84; "the freeze was stale on arrival" at 94 | `grep -n -E '^## L2 wave\|^## ' corpus/lessons/round-12.md` → 84; `sed -n 94p corpus/lessons/round-12.md` | no |
| QUALITY.md:47 | "`round-16.md` §Defects found while landing, items 6–7" | CURRENT (pin) | section name + items 6–7 | name absent from round-16.md; items 6–7 are rows at lines 66–67 under `## 3. Defects found by execution before commit` (line 54); the name exists only at round-17.md:87 | `grep -c 'while landing' corpus/lessons/round-16.md` → 0 (exit 1); `sed -n '66,67p' corpus/lessons/round-16.md`; `grep -n 'while landing' corpus/lessons/round-17.md` → 87 | **YES (name)** |
| QUALITY.md:48 | "`round-14.md` (line 139)" | CURRENT (pin) | line 139 | line 139 = PreStateScout "unreachable" reading row | `sed -n '40p;49p;139p' corpus/lessons/round-14.md` | no |
| QUALITY.md:48 | "`round-19-recensus.md` §Audit detail (line 49)" | CURRENT (pin) | line 49 | line 49 = dead-path sweep ("empty-grep sentences false"); heading at 47 | `sed -n '30p;40p;47p;49p' corpus/lessons/round-19-recensus.md` | no |
| QUALITY.md:49 | "`round-17.md` §4 (lines 100-103)" | CURRENT (pin) | 100–103 | §4 heading at 87; 100–103 = D-96 false attribution and "ownership ruling remains honestly unassigned" | `sed -n '100,103p' corpus/lessons/round-17.md`; `grep -n 'while landing' corpus/lessons/round-17.md` → 87 | no |
| QUALITY.md:26 | "`round-16.md` §1–§2 (ownership partition)" | CURRENT (pin) | §1–§2 | `## 1.` at line 10, `## 2. What landed` at 26 | `grep -n -E '^## [12]\.' corpus/lessons/round-16.md` → 10, 26 | no |
| QUALITY.md:62 | Locator note: "QM1 and QM6 cite `SCORECARD.md` lines 454 and 468" | CURRENT (pin) | lines 454, 468 | anchors at 458 and 472 (same drift as rows 39 and 44) | as rows 39 and 44 | **YES (+4)** |
| QUALITY.md:91 | "Each row turns one routed defect of `…round-23-verifier-spotcheck.md` §Routed defects" | CURRENT (cardinality) | 1 defect per row (QM15–QM18) | QM15→D4; QM16→D5 and D6 (2); QM17→D8; QM18→none (cites round-24 M24-3); round-23 list has 8 defects and QM rows cover 4 | `grep -cE '^- D[0-9]+ ' corpus/lessons/round-23-verifier-spotcheck.md` → 8; cells QUALITY.md:97–100 (`_grep`) | **YES** |

## HISTORICAL (not compared to live; recorded for completeness)

| file:line | phrase | class | claimed | live (where cheap) | source | STALE? |
|---|---|---|---|---|---|---|
| QUALITY.md:4, 12, 29, 51, 67, 89, 102 | "Created round 21"; headers "(round 21)", "(round 22)", "(round 24)", "fresh round-24" | HISTORICAL | round labels | n/a | `grep -n -o -E '^## .{0,60}' corpus/QUALITY.md` | n/a |
| QUALITY.md:5 | "`test -e corpus/QUALITY.md` → exit 1 at `aea7a43`" | HISTORICAL (revision) | exit 1 at aea7a43 | exit 0 at BASE (file exists; consistent with round-21 creation) | `test -e corpus/QUALITY.md` → exit 0 | n/a |
| QUALITY.md:21 | "observations scoped to op 2.40.0" | HISTORICAL (round 20) | op 2.40.0 | ledger R21-01 note: CLEAN on 2.40.0 (round 20) and 2.41.0 (2026-10-19); not re-run | ledger R21-01 note text (not executed) | n/a |
| QUALITY.md:22 | "six PASS rows refused" | HISTORICAL (round-20 gate) | 6 | not recomputed; round-21.md:37 repeats the six-row claim | `sed -n 37p corpus/lessons/round-21.md` | n/a |
| QUALITY.md:23 | "0 of 21 legacy entries carried a `recheck:` line at `aea7a43`" | HISTORICAL (revision) | 0 of 21 | population 21 is the expectation pinned by ledger R21-02 (`legacy=21`, not re-run: non-selftest gate); the 0-count not recomputed | ledger R21-02 expect text (not executed) | n/a |
| QUALITY.md:32–33 | "both surfaces were checked" | HISTORICAL (round 21) | 2 surfaces | round-21.md:4 names SKILL.md §Anti-patterns and QUALITY QA1–QA8 | `sed -n 4p corpus/lessons/round-21.md` | n/a |
| QUALITY.md:53 | "failed two admitted entries on scope after `c41af82`" | HISTORICAL (round 21) | 2 | round-21.md:106 (E3) and :107 (E1) are the two scope failures | `sed -n '20p;106p;107p;111p' corpus/lessons/round-21.md` | n/a |
| QUALITY.md:63 | "moved those sections by four lines" | HISTORICAL (round-21 move) | +4 | observed +4 for both anchors (454→458, 468→472) | as rows 39 and 44 | n/a (consistent) |

**CURRENT stale claims: 6 of 19** (QUALITY.md:6, :39, :44, :47, :62, :91).

## Notes

1. The stamp passes while six claims are stale: `sha256sum` and `wc -lc` on QUALITY.md match `corpus/stamps.tsv:66`, but the drifted anchors are in SCORECARD.md and lesson files, which the QUALITY.md stamp does not cover. C1 needs a locator binding (anchor plus expected text), not a byte stamp.
2. The round-21 critic flagged the QM1/QM6 locators (round-21.md:111). The fix was a locator note (QUALITY.md:62–65) that restates the stale numbers, so the note is now part of defect row 18. Anchor names are the stable pin; line numbers drift on every SCORECARD edit.
3. The QM9 section name is inherited: round-21.md:20 (M10 row) already cites "round-16.md:66-67 §Defects found while landing, items 6–7". The items are right; the section name is not.
4. Non-numeric, same sentence as row 1: "Tier definitions live in `corpus/SOURCES.md`" has no definition text there. `grep -l -i 'tier [ABC]\b'` over `corpus/*.md`, SKILL.md and README.md matches QUALITY.md only.
5. Excluded as non-numeric: QUALITY.md:14 "every row below holds", :79 "not a new countable criterion", :98 "ONE … normalizer" (a requirement, not a claim about lane state).

## Command log (`<lane>` = /fast/scratch/kagi-r25/SelfInvQuality/lane, BASE)

- `git clone -q --no-hardlinks <lane-src> <lane> && git -C <lane> checkout -q 4587c61a…` → exit 0; `rev-parse HEAD` = 4587c61a348e4528717404a68912c373f3ef4d03.
- `grep -c -i contract corpus/SOURCES.md` → 0 (exit 1). `grep -n -i tier corpus/SOURCES.md` → 5, 136.
- `grep -cE 'op:/{2}' corpus/QUALITY.md` → 0 (exit 1). `grep -c QUALITY corpus/claim-ledger.tsv` → 0 (exit 1). `grep -n 'QUALITY' corpus/stamps.tsv` → 66.
- `sha256sum corpus/QUALITY.md && wc -lc corpus/QUALITY.md` → `95a45d870e49…3bd3c410`; `112 17508` (exit 0).
- `grep -cE '^\| M[0-9]+ ' corpus/lessons/round-21.md` → 12. `grep -cE '^\| QM([1-9]|1[01]) ' corpus/QUALITY.md` → 11.
- `grep -n -w 'M8' corpus/QUALITY.md` → 33 (exit 0). `test -e corpus/QUALITY.md` → exit 0.
- `sed -n '454p;468p' SCORECARD.md` → table row / prose line. `grep -n -E 'Round-19 correction|Current baseline' SCORECARD.md` → 458, 472.
- `grep -cE '^- D[0-9]+ ' corpus/lessons/round-23-verifier-spotcheck.md` → 8.
- `grep -n 'Corrigendum' corpus/lessons/round-15.md` → 112, 123. `sed -n '44p;63p' corpus/lessons/round-10.md`. `sed -n 68p corpus/lessons/round-16.md`.
- `grep -c 'while landing' corpus/lessons/round-16.md` → 0 (exit 1). `grep -n 'while landing' corpus/lessons/round-17.md` → 87. `sed -n '100,103p' corpus/lessons/round-17.md`.
- `grep -n -E '^## [12]\.' corpus/lessons/round-16.md` → 10, 26. `grep -n -E '^## L2 wave|^## ' corpus/lessons/round-12.md` → 84. `sed -n 94p corpus/lessons/round-12.md`.
- `sed -n '40p;49p;139p' corpus/lessons/round-14.md`. `sed -n '30p;40p;47p;49p' corpus/lessons/round-19-recensus.md`. `sed -n '20p;106p;107p;111p' corpus/lessons/round-21.md`. `sed -n '4p' corpus/lessons/round-21.md`. `sed -n 37p corpus/lessons/round-21.md`. `sed -n 35p corpus/lessons/round-18.md`.
- `grep -rn -i 'pre-commit' corpus/` → QUALITY.md:24, sources-census.sh:98. `grep -rln -i 'contract v[0-9]' …` (above). `grep -l -i 'tier [ABC]\b' corpus/*.md SKILL.md README.md` → QUALITY.md only.

UNRUN: fleet pre-commit sweep (outside the lane tree). Ledger R21-01, R21-02 cited from their recorded text, not executed (non-selftest gate mode). No `--selftest` run (none required). No tool installs.
