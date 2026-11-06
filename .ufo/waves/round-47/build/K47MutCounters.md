# K47MutCounters — round-47 counter mutation report (C1 + C2)

Seat: `K47MutCounters` (leaf, no dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`
(BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`, predeclaration `b020d97`). Axes probed:
**calibration (C1)** and **freshness (C2)**.

Everything ran in scratch `$HYAKU_SCRATCH/kagi-r47/K47MutCounters` (default
`/fast/scratch/hyaku`). The lane was read-only: `plans/round-47-c1.sh`, `plans/round-47-c2.sh` and
`plans/round-47-controls.py` were copied, never edited (`git status --porcelain -- plans` is empty;
sha256 of the three lane files recorded in `K47MutCounters-receipts/lane-plan-sha256-after.txt`).

## Method

1. Pristine copies of both counters in scratch, changed in exactly one place: `REPO=$(cd …)` →
   `REPO=/home/vgpnk/Projects/shokunin/kagi-shokunin`, because a copy under `$S/mut/` would otherwise
   resolve `REPO=$S` and fail its `git -C "$REPO" show BASE:…` reads. That one relocation is applied
   identically to the baseline and to **every** mutant, so it cannot manufacture or hide a kill.
2. `plans/round-47-controls.py` was copied verbatim as `ctl/controls-harness.py` (only `REPO`/`SCRATCH`
   relocated) and its 17 frozen controls are the detector. `ctl/mutdrive.py` runs all 17 controls per
   mutant in parallel (10 workers), each control in its own tree.
3. Fixture inputs, built by this seat, not borrowed from the L1:
   - `cap/S099.body` = fleet blob `75dd2612:.ufo/prompts/kagi-round-44.md` (97077 B,
     sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`), i.e. the same bytes
     the counter computes live from the fleet repo.
   - `cap/S0{12..16,21..26}.body` = live fetches made 2026-11-06T19:34:14Z with
     `curl -fsSL --compressed` of the six registry URLs behind F; all eleven teaching quotes locate
     (`count=1` for ten ids, `count=3` for S024) — `cap/locate-live.txt`, shas in
     `cap/captures.sha256`. `cap/capture-times.tsv` carries that single real fetch time.
4. Baseline first: the 17 frozen controls against the pristine copies. `runs/baseline.txt` is
   **content-identical** to the pre-freeze receipt `.ufo/waves/round-47/controls/controls-prefreeze.txt`
   after stripping the `MATCH ` prefix (17/17, same `value=`/`SETUP` and same census last lines;
   `diff` exit 0). A baseline failure would have been inconclusive; there was none.
5. 31 mutants, each produced by one exact-string replacement on a pristine copy; a pattern that
   matches ≠ 1 aborts (`gen_mutants.py` prints `SETUP`), so there is no silent no-op mutant.
   Every mutant was scored by all 17 controls (C1 mutants also run the C2 controls, which must stay
   untouched — they did).

**Kill = the frozen control's printed value (or `SETUP`) changes versus the declared expectation.**
Because baseline is 17/17, "changes" and "differs from expectation" are the same thing.

## C1 — `C1_CENSUS_CALIBRATION` (14 mutants)

`−`/`+` are the exact diff (full hunks in `*-receipts/C1-*.diff`). "Frozen kill" is the 17-control
outcome; "probe kill" is the follow-up probe defined in the survivor section.

| mutant | diff (pristine → mutant) | frozen kill | probe kill |
|---|---|---|---|
| C1-M1-drop-new-conjunct | `− [ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared` → `+ [ "$bound" -eq 1 ] && value=$cleared` | **K1-F5** (0→3) | — |
| C1-M2-no-new-scan | `− new=$(… grep '^FINDING ' … \| wc -l)` → `+ new=0` | **K1-F5** (0→3) | — |
| C1-M3-drop-bound-conjunct | `− [ "$intact" -eq 1 ] && [ "$bound" -eq 1 ] && …` → `+ [ "$intact" -eq 1 ] && …` | **K1-F2** (0→3) | — |
| C1-M4-drop-intact-conjunct | `− [ "$intact" -eq 1 ] && …` → `+ [ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared` | none | **P1b** (0→3) |
| C1-M5-ignore-status-cell | `− [ "$mst" = "$st" ] \|\| { intact=0; why="$why status:$id"; }` (deleted) | none | **P1b** (0→3) |
| C1-M6-accept-dup-registry-rows | `− … \| wc -l)" -eq 1 ]` → `+ … \| wc -l)" -ge 1 ]` | none | **SURVIVES** |
| C1-M7-drop-capture-sha | capture compared by existence only (sha line deleted) | none | **P3** (0→3) |
| C1-M8-drop-row-sha | `− [ "${R[9]:-}" = "$bsha" ] \|\| { bound=0; why="$why sha"; }` (deleted) | none | **P4** (0→3) |
| C1-M9-accept-non-census-output | fail-closed `case $last in … esac` → `+ :` | **K1-F4** (SETUP→3) | — |
| C1-M10-drop-single-s099-row | `− if [ "$n99" -ne 1 ]` → `+ if [ "$n99" -lt 0 ]` | none | **P5b** (0→3) |
| C1-M11-invert-cleared | `− … grep -qxF … \|\| cleared=…` → `+ … && cleared=…` | **K1-P** (3→0) | — |
| C1-M12-loose-cleared-match | `− grep -qxF -- "$f"` → `+ grep -qF -- "$f"` | none | **P6** (3→2) |
| C1-M13-relax-base-102-guard | `− [ "$nb" -eq 102 ]` → `+ [ "$nb" -ge 1 ]` | none | **R1** (SETUP→3) |
| C1-M14-drop-blob-quote-check | `− if [ -z "$q" ] \|\| ! grep -qF -- "$q" "$blob"; then bound=0; fi` (deleted) | none | **P7** (0→3) |

Frozen-set score: **5 / 14 killed** (M1, M2, M3, M9, M11). With the probes: **13 / 14**, one survivor.

C1 survivors are not one class. M3's kill is narrow: only K1-F2 fires, because K1-F3's tree also
carries `new=1`, so the NEW conjunct masks BOUND there.

## C2 — `C2_FIRED_REVERIFIED` (17 mutants)

| mutant | diff (pristine → mutant) | frozen kill | probe kill |
|---|---|---|---|
| C2-M1-drop-date-window | `− [ "$fe" -ge "$FLOOR" ] && [ "$fe" -le "$ASOF" ] \|\| { … fetched-window … }` (deleted) | **K2-F2, K2-F3** (0→11) | — |
| C2-M2-invert-upper-window | `− [ "$fe" -le "$ASOF" ]` → `+ [ "$fe" -ge "$ASOF" ]` | **K2-P** (11→0), **K2-F3** (0→11), **K2-C** (11→0) | — |
| C2-M3-drop-gate-conjunct | `− [ "$gate" -eq 1 ] && value=$n` → `+ value=$n` | **K2-F6** (0→11) | — |
| C2-M4-gate-rc-ignored | `− [ "$grc" -eq 0 ] && [[ $glast == "RELEASE_CLOCK: CLEAN"* ]]` → `+ [[ $glast == *"RELEASE_CLOCK:"* ]]` | **K2-F6** (0→11) | — |
| C2-M5-drop-quote-swap | `− [ "$mq" = "$bq" ] \|\| { … quote-swapped … }` (deleted) | none | **Q1** (10→11) |
| C2-M6-drop-quote-count | `− [ "$k" = "$qc" ] \|\| { … quote-count … }` (deleted) | none | **Q2** (10→11) |
| C2-M7-accept-zero-count | `− [ "$k" -ge 1 ]` → `+ [ "$k" -ge 0 ]` | none | **SURVIVES** |
| C2-M8-drop-verdict | `− [ "$verdict" = teaching-holds ] \|\| { … verdict … }` (deleted) | **K2-F5** (0→11) | — |
| C2-M9-drop-capture-bytes | `− [ "$(wc -c < "$T/$cap")" = "$bytes" ] \|\| { … capture-bytes … }` (deleted) | none | **Q10** (10→11) |
| C2-M10-drop-dotdot | `− case "/$cap/" in */../*) … capture-dotdot …` (deleted) | none | **Q4** (10→11) |
| C2-M11-drop-capture-prefix | `− case $cap in .ufo/waves/round-47/capture/*) ;; *) … capture-path …` (deleted) | none | **Q5** (10→11) |
| C2-M12-accept-dup-ledger-rows | `− [ "$c" -eq 1 ]` → `+ [ "$c" -ge 1 ]` | none | **Q6** (10→11) |
| C2-M13-drop-url-check | `− [ -n "$rurl" ] && [ "$url" = "$rurl" ] \|\| { … url … }` (deleted) | none | **Q7** (10→11) |
| C2-M14-drop-release-check | `− [ -n "$ov" ] && [ "$rel" = "$ov" ] \|\| { … release … }` (deleted) | none | **Q8** (10→11) |
| C2-M15-drop-normalizer-setup | `− [ -f "$T/corpus/rendered-text-v1.py" ] \|\| setup missing-normalizer` (deleted) | **K2-F7** (SETUP→0) | — |
| C2-M16-drop-capture-sha | `− [ "$(sha256sum < "$T/$cap" …)" = "$sha" ] \|\| { … capture-sha … }` (deleted) | none | **Q9** (10→11) |
| C2-X1-swap-and-count-off | M5 + M6 together (two changes) | **K2-F4** (0→11) | — |

Frozen-set score: **7 / 17 killed** (M1, M2, M3, M4, M8, M15, X1). With the probes: **16 / 17**,
one survivor.

## Probes that kill the frozen-set survivors

Each probe is a fixture tree the **pristine** counter must reject with the named reason (verified:
declared expectation met *and* the reason string present in the printed line) and that the named
mutant accepts. C1 probes expect `0` except P6 (`3`); C2 probes tamper **one** of the eleven ids, so the correct
score is `10`, not `0` (the eleven get 11 only when all pass) — printed values are quoted exactly.
`P1/P2/P5` (honest census) and `P1b/P2b/P5b` (census replaced by a `SOURCES_CENSUS: CLEAN` printer,
the same vocabulary K1-F4 already uses) differ only in the census.

| probe | tree | pristine | mutant → verdict |
|---|---|---|---|
| P1-status-flip | C1 fix + S014 status `mined`→`queued` | 0 (`status:S014`, but `new=3`) | M4 0→0, M5 0→0 — **not killed**, census reports it first |
| **P1b**-status-flip-silent-census | same, census prints only `CLEAN` | 0 (`why=status:S014`) | **M4 0→3**, **M5 0→3 → KILLED** |
| P2-dup-registry-row | C1 fix + duplicated `S010` row | 0 (`row-count:S010`, `new=1`) | M6 0→0 — not killed |
| P2b-dup-registry-silent-census | same, census silent | 0 (`why=row-count:S010`) | M6 0→0 — **not killed** (see F1) |
| P3-capture-tamper | C1 fix + capture body byte appended | 0 (`why=capture-sha`) | **M7 0→3 → KILLED** |
| P4-row-sha-wrong | C1 fix with row sha `0…0`, capture correct | 0 (`why=sha`) | **M8 0→3 → KILLED** |
| P5-two-s099-rows | C1 fix + duplicated S099 fetch row | 0 (`s099-rows=2`, `new=1`) | M10 0→0 — not killed |
| **P5b**-two-s099-rows-silent-census | same, census silent | 0 (`why=s099-rows=2`) | **M10 0→3 → KILLED** |
| P6-prefixed-finding | census prints `NOTE: FINDING SC_USEDBY_NOCITE id=S094 …` | 3 (`new=0`; the line is not `^FINDING `) | **M12 3→2 → KILLED** |
| P7-quote-absent-from-blob | S099 row quote replaced by a sentence absent from the blob | 0 (`why=quote`) | **M14 0→3 → KILLED** |
| **R1**-base-101-rows (repo fixture) | scratch repo whose BASE registry has 101 rows; counter copies re-pointed at it (`REPO=`, `BASE=`), tree = C1 fix | `SETUP base-rows=101` (rc 2) | **M13 SETUP→3 → KILLED** |
| Q1-swap-same-count | S012 column-13 quote → another phrase from the same capture that also occurs `quote_count` times | 10 (`S012:quote-swapped`) | **M5 10→11 → KILLED** |
| Q2-wrong-quote-count | S012 `quote_count` +1 | 10 (`S012:quote-count`) | **M6 10→11 → KILLED** |
| Q3-quote-absent-body | S012 capture replaced by a body without the quote, sha/bytes/quote_count re-bound (0) | 10 (`S012:not-located`) | M7 10→10 — **not killed** (see F2) |
| Q4-dotdot-same-file | S012 `capture_path` = `.ufo/waves/round-47/capture/../capture/S012.body` | 10 (`S012:capture-dotdot`) | **M10 10→11 → KILLED** |
| Q5-capture-outside | S012 `capture_path` = `corpus/S012.body` (file present there) | 10 (`S012:capture-path`) | **M11 10→11 → KILLED** |
| Q6-dup-ledger-row | S012 ledger row duplicated | 10 (`S012:rows=2`) | **M12 10→11 → KILLED** |
| Q7-wrong-url | S012 ledger url → `https://example.invalid/…` | 10 (`S012:url`) | **M13 10→11 → KILLED** |
| Q8-wrong-release | S012 `observed_release` → `9.9.9` | 10 (`S012:release`) | **M14 10→11 → KILLED** |
| Q9-capture-same-len | S012 capture: one byte changed, length kept | 10 (`S012:capture-sha`) | **M16 10→11 → KILLED** |
| Q10-wrong-declared-bytes | S012 ledger `bytes` +1, capture byte-correct | 10 (`S012:capture-bytes`) | **M9 10→11 → KILLED** |

## Survivors — named, with the control that would kill them

**C1-M6 `accept-dup-registry-rows` (SURVIVES).** No fixture I can build kills it while the status
compare stands: with two rows for one id, `awk '$1==i {print $2}'` emits *two* statuses, so `"$mst"`
≠ `"$st"` and INTACT is still 0. Measured on the P2b tree: pristine `why=row-count:S010`, mutant
`why=status:S010`, both `value=0` (`receipts/m6-why.txt`). The control that would kill it is
"P2b **plus** the C1-M5 mutation" — i.e. a tree that duplicates a row *and* a counter without the
status compare; the frozen set has no such single-change control. Under the real census it is doubly
shadowed: the duplicate makes the census print a FINDING (`new=1`), so the whole-tree verdict is 0
before INTACT is consulted. Redundant guard, not a scoring hole.

**C2-M7 `accept-zero-count` (SURVIVES, equivalent mutant).** `corpus/rendered-text-v1.py locate`
exits **1** when `n == 0`, so `[ "$lrc" -eq 0 ]` already implies `count ≥ 1`; `-ge 0` can never be
reached with `k=0`. Measured on the Q3 tree both counters print `bad=S012:not-located` with
`k=0` (reproduced directly, `probe/q3-repro`). No control can kill it; the mutant is behaviourally
identical to the frozen counter on every input, so the correct report is "equivalent code", not a
coverage gap. It is still a readability trap: the line reads as if `count=0` were tolerated.

## Findings (all measured, no contract change proposed)

1. **INTACT is shadowed by NEW for every honest census.** All five INTACT-violation classes I built
   (missing row K1-F3, duplicate row P2, status flip P1, used-by narrowing K1-F1, duplicate fetch row
   P5) also make the measured census emit ≥ 1 FINDING, i.e. `new ≥ 1` → `value=0` regardless of
   INTACT. Only P1b (census rewritten to suppress the finding) isolates INTACT. So on any tree whose
   census behaves, dropping INTACT loses nothing; the conjunct's real purpose is defence against a
   candidate census that hides its own findings.
2. **C2 (e) is two conjuncts that each shadow the other for K2-F4.** Dropping the quote-swap compare
   alone (M5) or the count equality alone (M6) still scores 0 on K2-F4, because `"the"` both differs
   from the BASE quote *and* locates a count ≠ `quote_count`. Only the pair (X1) is killed by the
   frozen set. Q1/Q2 are the controls that discriminate each conjunct separately.
3. **C2 capture-sha and capture-bytes are individually reachable but mutually shadowing for whole-file
   tampering** (a length-preserving edit is caught only by sha — Q9; a wrong *declared* byte count is
   caught only by bytes — Q10). The frozen set has neither control: K2-F1 removes the capture
   entirely.
4. **C1 BOUND's three conjuncts have no individual frozen control.** K1-F2 (`body_sha=0…0`,
   `with_capture=False`) trips row-sha *and* capture-missing at once, so M7 (capture sha) and M8 (row
   sha) survive the frozen set; P3/P4/P7 isolate them. K1-F2 is the only control that would flag a
   hand-written provenance row and it does so through two independent reasons — fine for scoring,
   blind for mutation analysis.
5. **C2's per-id checks (url, release, capture prefix, dotdot, exactly-one row, capture bytes) have
   no frozen controls at all.** Seven of the seventeen C2 mutants (M9–M14, M16) survived the frozen
   set purely for that reason; Q4–Q10 kill them and their reason strings confirm the intended branch,
   not an accidental one.
6. **C1's whole-line match matters**: with `-qF` instead of `-qxF` a finding prefixed by any text
   counts as "cleared" (P6: pristine 3, mutant 2). The census never emits such a line today, so this
   is latent, not live.
7. **Frozen-control blind spots that remain after the probes**: none of the 17 controls exercises
   `capture_path` traversal or an out-of-root path, a wrong declared byte count, a same-count quote
   swap, a wrong `observed_release`/url in the ledger, or an unusable BASE registry. If the frozen
   control set is meant to be the *only* evidence of counter quality, it under-specifies C2 by eight
   branches (url, release, capture prefix, dotdot, exactly-one row, declared bytes, quote swap, quote
   count) and C1 by seven (INTACT status, duplicate registry rows, S099 row count, capture sha, row
   sha, whole-line match, BASE guard, blob quote).

## Receipts (in `.ufo/waves/round-47/build/K47MutCounters-receipts/`)

| file | content | command | exit | last line |
|---|---|---|---|---|
| `runs/baseline.txt` | 17 frozen controls, pristine | `python3 ctl/mutdrive.py baseline` | 0 | `K2-C-handtyped-times-ceiling expect=11 got=11 rc=0 :: …` |
| `lane-plan-sha256-after.txt` | lane plan hashes after the run | `sha256sum plans/round-47-c1.sh round-47-c2.sh round-47-controls.py` | 0 | 3 hashes |
| `*.diff`, `manifest.json` | the 31 exact diffs + change descriptions | `python3 ctl/gen_mutants.py` | 0 | `MUTANTS: 31` |
| `runs/<mutant>.txt` | all 17 control verdicts per mutant | `python3 ctl/mutdrive.py <id>` ×31 | 0 each | `MUTANT <id> killed_by=… survivors=…` |
| `probes.py`, `runs/probes.txt`, `probe-table.md` | the 20 probes | `python3 ctl/probes.py` | 0 | `  KILLED C2-M9-drop-capture-bytes pristine=10 mutant=11` |
| `m13-repo-probe.txt`, `repo-probe/{pristine,m13}.sh` | R1 repo fixture | `bash pristine.sh` / `bash m13.sh` with `C1_TREE` | 2 / 0 | `SETUP base-rows=101` / `value=3 …` |
| `m6-why.txt` | why P2b cannot kill M6 | two counter runs on one tree | 0 | `… value=0 … why=status:S010` |
| `cap/` | capture times, S099 body, locate log, sha256 manifest | `curl …` + `rendered-text-v1.py locate` | 0 | 11 × `RENDERED_TEXT_V1_LOCATE: count=…` |
| `controls-harness.py`, `mutdrive.py`, `gen_mutants.py` | the harness as run | — | — | — |

Raw captures (six pages, ~1.4 MB) are **not** copied into the lane; `cap/captures.sha256` plus the
public URLs and fetch time are the reproduction key.

## Restoration evidence

- Lane plans untouched: `git -C lane status --porcelain -- plans` → empty; `git status --porcelain
  -- plans corpus` shows only sibling seats' corpus edits (this seat wrote nothing under `corpus/`).
- The pristine scratch copies differ from the lane files by exactly the one documented `REPO=` line
  each (`diff -u` in the run log); no mutant touched a lane file.
- All 31 mutants exist only under `$HYAKU_SCRATCH/kagi-r47/K47MutCounters/mut/`; the scratch dir is
  disposable and was removed after the receipts were copied.
