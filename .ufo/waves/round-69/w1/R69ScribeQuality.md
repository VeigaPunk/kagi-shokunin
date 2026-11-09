# R69ScribeQuality — QUALITY bar, new knowledge entry, README coverage/Frontier rows

Seat: `R69ScribeQuality` (scribe, axis: depth). Wave `kagi-r69-w1`, round 69 attempt 2.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, jj-colocated.
Claim BASE `264917aa8fc9e71b6595d0d5166c4b615120fb8b`. Frozen predeclaration
`plans/round-69.md` at `adb6972668d176768a0f1d9ffecd25d32f1070f0` — read, never amended.
No commit, no jj mutation, no subagent dispatch (leaf member).

## Behavior — what landed

Three surfaces, all mine, all written this wave:

1. `corpus/QUALITY.md` — four criteria appended after QM96 in the file's existing
   table shape (`| id | criterion | weak signal | lesson |`, new block
   `## Criteria from the round-68 record-repair review (scribe seat)`, lines 333–338):

   | id | criterion | weak signal | lesson |
   |---|---|---|---|
   | QM97 | append-only supersession — the superseded sentence stays, the correction names it verbatim plus the superseding receipt | deleted-in-place record surface; a `## Correction` block naming a receipt absent from the tree | `corpus/lessons/round-68.md` §Correction (round 69); `corpus/lessons/round-68-verifier-spotcheck.md` §7 item 3 |
   | QM98 | instrument floors — the predicate compares every frozen floor, and the selftest carries a sub-floor case | a predicate true below the plan's floor; a case table exercising only the pass-count legs | `corpus/lessons/round-68.md` §Mistakes M68-1 and M68-9; spot-check §7 item 8 |
   | QM99 | ledger-row production — a row pins a line the tree produces; a changed command journals its old expectation | an expect the instrument never emits; a row measuring its own invocation; a changed row with no journal entry | `corpus/lessons/round-68.md` §Mistakes M68-6 and M68-8; spot-check §7 item 9 |
   | QM100 | trend observable — `expansion` moves only when a new admitted entry lands on uncovered ground with its coverage-map row | expansion resting on a widened entry or a source row alone, with the file count and the coverage-map both unchanged | `corpus/lessons/round-68.md` §Gate and §Mistakes M68-7; spot-check §6 and §7 item 13 |

   Each row carries the route `corpus/lessons/round-68.md` in **both** the weak-signal
   column and the lesson column (the counter's `derived_criterion_ids` at
   `plans/round-69-c1.sh:345` matches the literal anywhere in the row, so both
   readings of "source column" resolve to the same set), and each row carries a
   `check able to fail:` clause naming a runnable command and the reading that
   holds — the mutation tester's M3 mutant (route string present, no falsifier text)
   is killed by that clause, not by the route string.

2. `corpus/knowledge/record-supersession.md` (new, 199 lines) — opens `source: S168`,
   states the append-only rule and the consistency-proof mechanism (RFC 9162 §2.1.4),
   the transposition to a lane record (a correction supersedes and never rewrites; the
   superseded bytes remain and the correction names them; a committed receipt, not a
   memory, is the superseding authority; a changed expectation keeps its old value in
   a migration journal), the bounds (existence and value, never authorship; a named
   superseded reading is a dated reading, not a falsehood), and six runnable falsifiers
   (F1–F6). Access date named: 2026-11-08. Located quote (10 words, ≤ 25):
   "Merkle consistency proofs prove the append-only property of the tree."

3. `corpus/README.md` — coverage-map row 121 (Record supersession, entry, round 69) and
   a `## Frontier` bullet at line 148 (`**Record supersession** — entered in round69 …`),
   both in the file's existing shapes. The knowledge-entry index row (line 67) was
   updated `45 row-linked / 3 by-hand / 48 pinned` → `46 / 3 / 49`, because the entry
   I landed moves those counts; the ledger rows and stamps rows (64, 65) were left
   untouched — they are stale for reasons owned by the ledger seat, not by my landing.

## Gates — what was actually run, and what it read

| check | command | reading |
|---|---|---|
| RFC 9162 open | `curl -A <browser UA>` on `https://www.rfc-editor.org/rfc/rfc9162.txt` | HTTP 200, 128266 B, sha256 `a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f`, byte-identical to `.ufo/waves/round-69/capture/S168.body` |
| quote located | `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-69/capture/S168.body 'Merkle consistency proofs prove the append-only property of the tree.'` | `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0 |
| quote position | body line 475, raw byte offset 19819 | §2.1.4 Merkle Consistency Proofs |
| falsifiers F1–F6 | the six commands printed in §4 of the entry | F1 count=1; F2 digest matches over 128266 B; F3 `grep -c 'mismatches 3 → 0'`=2 and `grep -c '^## Correction (round 69)'`=1 (line 228); F4 receipt line 6 reads `# (no C2_RECORD line; the process was killed at the budget)`; F5 old expectation 0 in `corpus/claim-ledger.tsv`, 1 in the round-69 journal; F6 BASE knowledge count 48 = tip count 48, live count 49 |
| citations gate (my docs) | `bash corpus/claim-ledger.sh citations --docs "corpus/README.md corpus/knowledge/record-supersession.md corpus/QUALITY.md"` | `CITATION_GATE: CLEAN (cites=428 docs=3 unresolved=0 ephemeral=0 labeled=0)` |
| census gate | `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=160 …)` and `SOURCES_CAPTURES: CLEAN (path_rows=40 bound=40 located=40 prose=120)` |
| docs audit | `bash corpus/claim-ledger.sh docs` | `DOC_AUDIT: BROKEN (entries=49 row_linked=46 by_hand=3 undeclared=0 missing_ids=0 unpinned=1 …)` — **BROKEN, not a pass**; `unpinned=1` is the new entry, which has no stamp row yet. It reads CLEAN once `corpus/stamps.tsv` carries a row for the entry and re-pins for the two changed files. At BASE the same command reads `DOC_AUDIT: CLEAN (entries=48 row_linked=45 by_hand=3 …)` (measured on a `git archive 264917aa` extraction under scratch). |
| full citations gate | `bash corpus/claim-ledger.sh citations` | `CITATION_GATE: BROKEN (cites=5448 docs=177 unresolved=32 ephemeral=1 labeled=26)` — pre-existing at BASE; none of the 32 unresolved tokens is in a file I wrote (they are in `corpus/lessons/round-54…66` and the round-68 spot-check). My scoped run over my three files is CLEAN. |
| self-counts | `python3 corpus/self-counts.py` | `SELF_COUNTS: POLICY (claims=63 stale=6 unlocated=0 ambiguous=0 policy=2 setup=3)`. The 6 stale are SKILL.md:46, PROVINCE.md:73 (×2), README.md:64, README.md:65 — all ledger/stamps counts owned by the ledger seat; the 3 SETUP are `ledger:R14-01` (its expect names entries=38/row_linked=35, which the tree does not produce). I did not touch any of those rows. |
| table shape | `awk` pipe count over lines 333–338 | 5 pipes on every row (a literal `\|` inside the QM100 falsifier would have split the cell — I replaced `ls … \| wc -l` with `bash -c 'set -- corpus/knowledge/*.md; echo $#'`, which reads 49) |
| derived criterion set | `plans/round-69-c1.sh` `derived_criterion_ids` rule applied by hand | exactly `QM97, QM98, QM99, QM100`; `grep -c 'corpus/lessons/round-68.md' corpus/QUALITY.md` = 4, no earlier row names it |

Dead ends and non-verdicts, stated plainly:

- `bash corpus/claim-ledger.sh verify` was launched and **did not finish** inside a
  300 s budget (twice; it was killed). I therefore have **no** full-ledger verdict and
  report none. The per-class gates above are the evidence I do have.
- `DOC_AUDIT` currently reads BROKEN. That is a real reading of the tree as it stands,
  not a pass and not a SETUP.
- No `w1-results.json` was waited for; the driver writes it after every seat settles.

## Touched surfaces

- `corpus/QUALITY.md` — lines 331–338 appended (four criteria + block heading). No
  existing row renumbered, reformatted, or reworded.
- `corpus/knowledge/record-supersession.md` — new file.
- `corpus/README.md` — line 121 added (coverage-map row), line 148 added (Frontier
  bullet), line 67 index counts updated 45/3/48 → 46/3/49. No other row touched.
- `.ufo/waves/round-69/w1/R69ScribeQuality/rfc9162-open.txt`, `quality-tail.txt`,
  `readme-diff.txt` — the three required receipts.

## Out of scope — deliberately not done

- `corpus/claim-ledger.tsv` (ledger seat's file): R14-01's stale expectation and the
  R12-03/R24-05 stamps pins are reported to `R69ExecLedger`, not fixed here.
- `corpus/stamps.tsv`: no seat in the wave spec owns it; I did not write it. The three
  measured digest/line/byte tuples my landing needs are in the message to
  `R69ExecLedger` and in the report below.
- `corpus/lessons/round-69.md`: `new knowledge entries=` is the lesson seat's line
  (R69ScribeLesson); it must read 1, not 0, now that the 49th file exists.
- `SCORECARD.md` (record seat's file): the round-68 depth row must name QM97–QM100
  and must not carry "enter the bar"; reported to `R69ExecRecord`.
- No plan predicate, population, kill rule or target was rewritten. No commit, no jj
  command, no stamp row, no scratch left behind.

## Findings

1. **A row that pins a line the tree never produces is still live in the ledger.**
   `R14-01` expects `^DOC_AUDIT: CLEAN \(entries=38 row_linked=35 by_hand=3 …\)$`.
   The live tree reads 48/45 at BASE and 49/46 with my entry landed; entries=38 /
   row_linked=35 matches no reading I could find in this lane. The row is the source of
   three SETUP self-count rows (`RD-DOCS-ROWLINKED`, `RD-DOCS-BYHAND`,
   `RD-DOCS-ENTRIES`). This is QM99's class, live in the tree, and it is why the
   README index row it feeds cannot be checked automatically. Reported to the ledger
   seat with the repoint target.
2. **The stamps membership pins are three generations behind the file.**
   `R12-03` expects `^125$` stamps rows and `R24-05` expects `count=125
   sha256=369e92e5…`; live is 168 rows, sha256 `24186f370630bc6331a117596926dcff54aeef94e5447f5009e52e5f1c7593ff`.
   `README.md:65` says 164 and `SKILL.md:46`/`PROVINCE.md:73` say the same, so four
   self-count rows read STALE. This is a pre-existing debt, not caused by my landing.
3. **The knowledge-entry index row was itself a live defect.**
   `README.md:67` claimed 45/3/48 while the tree held 48 entries (45 row-linked at
   BASE) — correct only by coincidence of the last landing. My landing moves it to
   46/3/49 and the row now states the counts it describes. `README.md:64` (ledger rows)
   and `:65` (stamps) remain stale and are the ledger seat's to repoint.
4. **`expansion` was the one trend claim that had no ground under it.**
   Round 68 admitted S167 into an existing entry and `corpus/knowledge/` gained no
   file; BASE 48 = tip 48. With the record-supersession entry the count is 48 → 49,
   so the round-69 lesson's `new knowledge entries=` line must read 1. QM100 is written
   to make that the bar rather than a claim.
5. **A single literal pipe in a Markdown cell silently corrupts the row.**
   The QM100 falsifier first read `ls corpus/knowledge/*.md | wc -l`; the pipe split
   the table cell (6 pipes on that row against 5 on every other). It is now
   `bash -c 'set -- corpus/knowledge/*.md; echo $#'`, pipe-free, and reads 49. Any
   future criterion with a shell pipe in a cell needs the same treatment.

## Artifacts

- `corpus/QUALITY.md` (lines 331–338)
- `corpus/knowledge/record-supersession.md`
- `corpus/README.md` (lines 67, 121, 148)
- `.ufo/waves/round-69/w1/R69ScribeQuality/rfc9162-open.txt`
- `.ufo/waves/round-69/w1/R69ScribeQuality/quality-tail.txt`
- `.ufo/waves/round-69/w1/R69ScribeQuality/readme-diff.txt`
- `.ufo/waves/round-69/w1/R69ScribeQuality.md` (this report)

**Tooling:** no tool was installed or upgraded this seat. `curl`, `python3`, `git`,
`awk`, `grep` and the lane's own `corpus/` instruments were already present and
were used as-is.

**Scratch:** `/fast/scratch/hyaku/kagi-r69/R69ScribeQuality/` held the raw RFC fetch
(`rfc9162.body`, `rfc9162.headers`) and a `git archive 264917aa` BASE extraction;
the directory was removed before this report was written. No /tmp path is cited
anywhere above — every receipt is a lane-relative path inside the tree.
