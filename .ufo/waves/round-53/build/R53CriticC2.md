# R53CriticC2 — C2 forgery attack (round 53, seat R53CriticC2)

Scope: attack `plans/round-53-c2.sh` (frozen C2 calibration counter) with fixture trees grown from
BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`, looking for `value=0` while at least one of the
five BASE statements is still false. Everything ran under
`/fast/scratch/hyaku/kagi-r53/R53CriticC2/` (`base-tree` = BASE archive, `fx-f*/` = one fixture per
attack, `build.py` = the fixture builder, `out-f*.txt` / `raw-f2.txt` = counter/checker receipts).
No lane file, registry row, plan or scorecard was touched; nothing outside the scratch tree and this
report (plus `R53CriticC2-receipts/`) was written. No secret, token, key or vault field was read or
printed.

Every counter run below is exactly
`HYAKU_SCRATCH=<scratch>/hyaku bash plans/round-53-c2.sh --tree <fixture>`
(with `HYAKU_SCRATCH` inside my scratch, so the counter's own `rm -rf "$SCR"` is confined).
A single run costs ~50–70 s wall; three in parallel ~190–210 s (the checker is internally parallel
and saturates the box).

---

## 0. BASE measurement (own receipt, not the plan's claim)

```
$ cd base-tree && python3 base-b/corpus/self-counts.py --root base-tree --table base-b/corpus/self-counts.tsv
rc=2  (59.0 s, 63 finding lines)
STALE SC-SKILL-STAMPS     SKILL.md:46          claimed=124 live=125
STALE PV-STAMPS           PROVINCE.md:73       claimed=124 live=125
STALE RD-STAMPS           corpus/README.md:65  claimed=124 live=125
STALE RD-DOCS-ROWLINKED   corpus/README.md:67  claimed=33  live=34
STALE RD-DOCS-ENTRIES     corpus/README.md:67  claimed=36  live=37
POLICY PV-FEEDTOKEN-SHAPES   ledger:R29-02 command not allowlisted
POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted
SELF_COUNTS: POLICY (claims=63 stale=5 unlocated=0 ambiguous=0 policy=2 setup=0)
```

Reproduces the plan's five. The two POLICY findings are not measurements at all: `R29-01`/`R29-02`
start with `python`, absent from `ALLOWED_COMMANDS = {bash, grep, python3}`, so those two claim ids
are refused **before** any command runs — and the counter's g5 *requires* exactly that pair.

## 1. What the GUARD actually pins (read from the counter's bytes)

| conjunct | pins | does **not** pin |
|---|---|---|
| g1 | per bound id: exactly one row; **column 2** (command) equal to BASE; **column 3** (expect) equal only for `expect:` sources | **column 4 (expected exit)** — the checker's own acceptance criterion; column 5 (timeout); column 6 (note); every unbound row and the whole row population |
| g2 | `corpus/claim-ledger.sh` bytes | every other script a pinned command runs (`self-counts.py`, `scope-gate.sh`, `sources-census.sh`, `checklist-run.sh`, `release-clock.py`, `feed-token-agree.py`, …) |
| g3 | `stamps.tsv` **path column** (sorted) | sha/lines/bytes columns |
| g4 | `corpus/knowledge/*.md` **names** (sorted) | entry contents, `Reverify:` classes, which entries are row-linked |
| g5 | the POLICY finding ids are exactly the BASE pair | anything about those two claims — g5 makes their unmeasurability mandatory |

## 2. Forgery table

`value` is the counter's own line; `class` uses `counter defect` / `declared ceiling` for attacks
that reached `value=0`, and `guard holds` for attacks the counter stopped (reported honestly: those
are not forgeries).

| id | edit (fixture) | counter output | class |
|---|---|---|---|
| **F1** | `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:65,67`: insert a decoy number **earlier on the same line** (`(125 stamps + 86 claims, observed live 2026-11-07)`, `verify` (125 revision stamps …`, `\| 125 rows (…)`, `34 row-linked / 3 by-hand / 37 pinned (…)`). Every operative sentence keeps its false number (`124 stamps`, `124 rows`, `33 row-linked`, `36 pinned`). | `C2_SELF_COUNTS: value=0 (bad=; … stale=0 …)`, rc 0 | **declared ceiling** — "the checker binds numbers, not the prose around them". Five BASE statements stay false and the counter certifies 0. |
| **F2** | F1's four other decoys + `SKILL.md`: the decoy is placed **after a bare CR inside physical line 46**, so Python's `splitlines()` sees it as line 47. | `value=0`, rc 0. Raw BASE checker on the same tree: `OK SC-SKILL-STAMPS SKILL.md:47 claimed=125 live=125`, `OK SC-SKILL-CLAIMS SKILL.md:47`. But `grep -n '^\| Re-run a claim' SKILL.md` → `46:`, and `sed -n 47p` prints the **next** table row ("Check a number the corpus states about itself …"). | **counter defect** — private line model. `Path.read_text().splitlines()` splits on CR/VT/FF/NEL/U+2028/U+2029 and universal-newline `\r`; `grep`, `sed`, `awk` and the lane's own citation gate split on `\n` only. "exactly one line must match" and every reported `doc:line` are computed on a line model no other instrument shares, and the CR keeps the stale sentence visible on the same physical line. |
| **F3** | F1's decoys + `corpus/claim-ledger.tsv` R14-01 **column 4: 0 → 1** + `corpus/knowledge/claim-ledger.md` `Reverify:` → `Reverify: R99-99` (fabricated id). The docs audit is BROKEN: `DOC_AUDIT: BROKEN (entries=37 row_linked=33 by_hand=3 … missing_ids=1 …)`, rc 1. | `value=0`, rc 0 | **counter defect** — g1 does not pin column 4, which the checker uses as its acceptance criterion (`if result.returncode != expected_exit: SETUP`). The tree makes the audit *fail*, flips the demanded exit code, and the checker then mines the BROKEN line for `entries=`/`row_linked=`/`by_hand=`. |
| **F3b** | F3 **without** the column-4 edit (identical tree otherwise) | `C2_SELF_COUNTS: SETUP setup=3`, rc 2 | **guard holds** — the exit column is the only thing standing between F3 and SETUP, and the checker already knows the run failed. |
| **F4** | F1's decoys (with `4 by-hand`) + `corpus/knowledge/claim-ledger.md` demoted to `Reverify: by-hand: interactive-only — …` (unique ≥24-char reason). Docs audit now **CLEAN**: `DOC_AUDIT: CLEAN (entries=37 row_linked=33 by_hand=4 …)`. | `value=0`, rc 0 | **counter defect** — g4 pins filenames only, so the live quantity `row_linked` is bendable: the measured tree *loses* a row-linked declaration (silently, same 37 files) instead of correcting the prose. The plan's ceiling says "the claim fixes the population present at BASE"; it fixes the population's **names**, not what each entry declares. |
| **F5** | `corpus/stamps.tsv`: flip the sha256 of the first three rows (paths untouched). Count still 125, sorted path column equals BASE. | `value=5` (the same five), rc 0 | **guard holds** (and scope note): the stamp count is unforgeable from content — a line-counting `grep` plus g3's path pin. C2 is correctly blind to *hash* forgery (that is `verify`/R24-05's axis, not calibration), so `value=0` must not be read as "the stamps are true". |
| **F6** | `corpus/stamps.tsv`: replace one path (`corpus/adjacency.tsv` → `corpus/QUOTE-does-not-exist.md`), count kept at 125. | `C2_SELF_COUNTS: SETUP guard:g3`, rc 2 | **guard holds** — count-preserving path swap caught. |
| **F7** | `corpus/claim-ledger.tsv` R12-03 **column 3: `^125$` → `^124$`** (a `ledger:` source, so g1 does not compare column 3). The command still prints 125. | `value=5` (unchanged), rc 0 | **counter defect (scope, not exploited)** — the counter cannot see a bent ledger pin: `value` is unmoved because the checker ignores `expect` for `ledger:` rows, so the tree would ship a row whose own pin contradicts its output and `claim-ledger.sh verify` would fail it. g1's guarantee is "the command cell equals BASE", much narrower than "the row is BASE's". |
| **F8** | F1's decoys + `corpus/feed-token-agree.py`: add a 13th entry to `SHAPES`. `PROVINCE.md` still says "fixed shape corpus of **12** shapes"; no other doc change. | `value=0`, rc 0 | **counter defect** — g5 *requires* `PV-FEEDTOKEN-SHAPES`/`PV-FEEDTOKEN-SELFTEST` to stay POLICY, so two of the 63 bindings are unmeasurable by construction and `claims=63` certifies 61. The false "12 shapes" statement is unreachable by any `bad=` list. |
| **F9** | F1's decoys + `SKILL.md` replaced by an **absolute symlink** to a copy outside the measured tree. | `C2_SELF_COUNTS: SETUP guard:g5:PV-FEEDTOKEN-SELFTEST PV-FEEDTOKEN-SHAPES SC-CENSUS-SELFTEST … SC-SKILL-STAMPS SC-SOURCES-SELFTEST`, rc 2 | **guard holds** — `repo_path(...).resolve()` + `is_relative_to(root)` refuses a doc escaping the root (13 POLICY findings vs the mandated pair). |
| **F10** | F1's decoys + `corpus/self-counts.py` replaced by a 6-line stub that prints `SELF_COUNTS_SELFTEST: PASS (48 cases)` (the tree's copy is what pinned command `R25-01` executes; the counter's own instrument is BASE's). | `value=0`, rc 0 | **declared ceiling** — "a forged script called by a pinned ledger command other than claim-ledger.sh is not detected beyond g3/g4". Sharpest instance: the shipped binder no longer binds anything, the docs' "`--selftest` proves 48 cases" is now a claim about a stub, and C2 reads 0. |
| **F11** | F1's decoys + **count-preserving row swap**: ledger row `R24-05` (the stamp-identity pin, `row-identity.sh stamps`) renamed `R99-01`. Row count stays 86; every bound row untouched. | `value=0`, rc 0 | **counter defect** — the claim-row population/identity has no guard at all (unlike stamps g3 and knowledge g4). The ledger can lose its stamp-identity pin while `86 claim rows` and every binding stay green. A *deletion* alone would move the count and show +3 STALE; a swap does not. |
| **F12** | F1 + duplicate the whole decoyed `SKILL.md` row (two matching lines). | `value=2` with `bad=AMBIGUOUS:SC-SKILL-STAMPS AMBIGUOUS:SC-SKILL-CLAIMS` (accounting: summary `ambiguous=2`, `s+u+a = M`) | **guard holds** — AMBIGUOUS is counted, so duplicating a line cannot hide a claim; the summary/per-line accounting is consistent. |

Footnotes on evidence honesty:

* **F1/F2/F4/F8/F10/F11 all sit on top of F1's decoy text.** A same-line decoy necessarily leaves
  the true number *visible* on the same physical line, so the contradiction is catchable by a human
  reading the line; what the decoy defeats is the counter, i.e. a reviewer who reads `value=0` and
  the `bad=` list instead of the sentence. That cost is exactly why F1/F10 are classified as the
  plan's own ceilings rather than as new defects.
* **F11's "a deletion would show +3 STALE"** is read off the three bindings of `R21-04`
  (`SC-SKILL-CLAIMS`, `PV-CLAIMS`, `RD-LEDGER-ROWS`); I did not build that fixture, so it is an
  inference from the table, not a receipt. The swap itself is a receipt (`out-f11.txt`).
* The F3/F4 numbers were also confirmed directly against the docs mode:
  `R53CriticC2-receipts/docs-audit-f3-f4.txt` — `DOC_AUDIT: BROKEN (entries=37 row_linked=33
  by_hand=3 … missing_ids=1 …)` rc 1 and `DOC_AUDIT: CLEAN (entries=37 row_linked=33 by_hand=4 …)`
  rc 0.

## 3. Verdict

* C2's `value=0` is **not** evidence that "the counts the lane's documents state about itself match
  the live quantities". It is evidence that 61 BASE-checker locators captured a number equal to a
  pinned live number, on file bytes whose line model is the checker's own. Thirteen fixtures
  (12 attack ids + the F3b control variant): **seven reached 0**, of which
  **five are counter defects the plan does not declare**
  (F2 line model, F3 unpinned exit column, F4 content-bendable `row_linked`, F8 mandatory
  unmeasured pair, F11 unguarded claim-row identity) and **two are declared ceilings**
  (F1 locator decoys, F10 forged pinned-script).
* The five attacks the GUARD stops cleanly (F3b, F5, F6, F9, F12) show where the design is strong:
  `claim-ledger.sh` byte pin, stamp-path set, knowledge filename set, doc-path containment,
  AMBIGUOUS accounting, and the one-`SELF_COUNTS:`-line rule (the checker pipes every child's stdout,
  so a commanded script cannot inject a summary — F10's stub line stayed inside `last_output`).
* **The landed candidate does not exploit any of this**: my own read-only diff of
  BASE→`36d0a86` shows `stamps.tsv` path population identical (12 rows re-stamped, 0 added/removed),
  knowledge filenames identical, and all 20 bound ledger rows identical in columns 2–5. So the
  *candidate's* 0 is honest for the class of defects above except the two consequences the plan
  itself declares (the `python` pair stays unmeasured, and g3 forbids the round's own lesson from
  joining the stamp set).
* Transience worth recording in the lesson: because g3 freezes the stamp population at BASE, the
  eventual `corpus/lessons/round-53.md` stamp commit (the lane's precedent for every round lesson)
  moves the live count to 126 and turns the three corrected stamp sentences STALE again. C2's zero
  is a snapshot, not an invariant.

## 4. Smallest safe corrections (in order of teeth per line changed)

1. **g1: pin the whole ledger row, not column 2.** Compare `cut -f2-6` (command, expect, exit,
   timeout, note) for every bound id. This closes F3 and F7 in one line of the g1 loop; F3's
   BROKEN-line mining is the only defect here that reaches 0 with a *failed* pinned command.
2. **Make the two unmeasured claims measurable, then empty g5's expected pair.** Change the first
   token of `R29-01`/`R29-02` from `python` to `python3` (the round-29 Windows note is obsolete) and
   let g5 compare the (now empty) POLICY set. F8 then cannot hide a changed shape corpus.
3. **g4: pin `Reverify:` lines, not only filenames.** Compare the sorted `^Reverify: ` lines of
   `corpus/knowledge/*.md` with BASE's (or the per-entry sha256). One `cmp` line; closes F4.
4. **Checker line model.** Read docs with `text.split("\n")` and `SETUP` on `\r`, `\v`, `\f`,
   `\x1c`–`\x1e`, `\u0085`, `\u2028`, `\u2029`. Closes F2's false provenance and restores the
   "one line, one statement" premise the ceiling relies on.
5. **Add a claim-row identity conjunct (g6).** Compare the sorted id column of
   `corpus/claim-ledger.tsv` with BASE's, except for the ids the round is licensed to add. Closes
   F11 and makes the "population present at BASE" sentence true for the ledger as it already is for
   stamps and knowledge names.
6. **Declare the decoy ceiling in the counter header** (not only in the plan): `value=0` speaks
   about captured numbers; add a `--show-bindings` mode that prints each claim's captured line so a
   reviewer diffs the sentence, not the number. F1 is otherwise unavoidable.

## 5. Receipts

`R53CriticC2-receipts/` (copied before exit): `out-f1..f12.txt` (one counter run each),
`raw-f2.txt` (BASE checker's full 63-line output on F2), `line-model-f2.txt` (grep/sed/python
divergence on F2's line 46), `docs-audit-f3-f4.txt` (the docs-mode verdicts behind F3/F4),
`fingerprint-fx-*.txt` (the `sed -n` view of every edited line), `build.py`, `base-raw.txt`
(the 63-line BASE checker output). Scratch keeps the fixture trees themselves; no file here
exceeds 132 KB total.
