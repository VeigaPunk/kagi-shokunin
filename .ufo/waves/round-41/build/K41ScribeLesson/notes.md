# K41ScribeLesson — notes for the L1 (what each slot needs)

Deliverables in this directory:
`lesson-round-41.md`, `scorecard-round-41-pre.md`, `scorecard-erratum-round-40.md`,
`log-entry-round-41.md`, `notes.md` (this file). Seat report:
`.ufo/waves/round-41/build/K41ScribeLesson.md`.

No lane tree file was edited. Scratch `/fast/scratch/hyaku/kagi-r41/K41ScribeLesson` was created, used
for live re-opens and fixture measurements, and removed before this yield. Tool installs: **none**.

## Slots — the L1 fills these with exact measured values

| # | File | Slot | What the L1 measures and with which command |
|---|---|---|---|
| 1 | lesson, Claims | `c1 candidate reading` | `bash plans/round-41-c1.sh` at the landing tree → one unsigned integer, exit code, last output line. Target 4. |
| 2 | lesson, Claims | `c2 candidate reading` | `bash plans/round-41-c2.sh` at the landing tree → one unsigned integer, exit code, last output line. Target 3. |
| 3 | lesson, Claims | `control re-reads` | `bash plans/round-41-controls.sh` at the landing tree → each `CONTROL … N=` line, and the five receipt files under `.ufo/waves/round-41/controls/`. Expect C1 0/0/0, C2 decoy ≤ 2. |
| 4 | lesson, Claims | `migration old→new values and journal path` | The census-summary ledger rows that move when S097/S098 are appended (R21-02, R31-02, R33-02, R34-03): their old and new `expect` values, and the path of the round-41 migration journal the gate reads. Without these entries the C1 gate refuses them. |
| 5 | lesson, Claims | `F1–F4 refusal lines` | The four exact `EXPECT_JOURNAL: REFUSE <token>` lines the counter's forgeries produce, with rc 1, from the counter's own run at the landing tree. |
| 6 | lesson, Gate | `S097 row id / quote cell / anchor cell` | From the committed `corpus/SOURCES.md` diff: the row id, the verbatim quote cell, the anchor cell, plus the fetch row (the URL 301-redirects, so `url` and `final_url` must both be recorded and `http_status` taken from the final hop). |
| 7 | lesson, Gate | `S098 row id / status cell / rejection text` | From the committed diff: the row id, `status` = rejected, and the rejection cell carrying the reason and the flip condition. |
| 8 | lesson, Gate | `rows-touched table` | Every row the round changes, old → new, from the committed `corpus/SOURCES.md` diff. |
| 9 | lesson, Gate | `committed capture path` | Where the L1 copies the scout's staged bodies: `.ufo/waves/round-41/capture/S095.body`, `S096.body`, `S097.body`, `S098.body`, with their sha256s (S095 `ef2d8abe…469b1`, S096 `570d72c3…d3fbab5`, S097 `e2992e17…62e2b3`, S098 `68e34b8b…8c70d`). The C2 counter's (b) term searches `.ufo/waves/*/capture/S095.body`, so the committed path matters. |
| 10 | lesson, Gate | `round-37 eight-row slice restated?` | Whether the round-41 Gate restates the round-37 absent-defect-register slice. The register file is not present on this host, so nothing was re-read. |
| 11 | scorecard-pre | `round-41 post-move table` | The post-move rows the L1 writes after the landing run (the pre-move file states the axes hold at 9). |
| 12 | log-entry | `completion line` | The `complete kagi round=41` line from `/home/vgpnk/Projects/shokunin/.ufo/watchdog.log` once the round closes. |
| 13 | log-entry | `C1 / C2 verdict and round verdict` | The L1's reading of the landing run, in the round-40 lesson's style ("C1 not admitted / C2 verified as declared / …"), for the operator. |
| 14 | lesson, Claims | `c1 landing-check base ledger` | The landing-time gate run must use the round-40 claim BASE ledger `6cc8850` as `--base-ledger` for the kill-rule clause about the six round-40 migrations to be testable at all (critic ambiguity 2). Record the interpretation. |
| 15 | lesson, Claims | `c2 selftest case count at the landing` | `python3 corpus/rendered-text-v1.py --selftest` at the landing tree → the `cases=<n>` number. The kill rule's floor is 22; BASE measures exactly 22. The counter does not read the count (critic gap 3). |
| 16 | lesson, Claims | `F1–F4 refusal lines / degenerate-paragraph reading` | If the L1 wants the C2 ceiling quantified in the lesson's own words: the critic's degenerate-paragraph reading is 3 (name-drop + quote as decoration). Already cited in the lesson's C2 ceiling paragraph. |

## What I measured (read-only; no lane file touched)

Commands run, all from the lane root or from the scratch dir, all exit 0 unless stated:

- `git ls-tree 5142b52 corpus/expect-journal.sh` → empty (no gate at the predeclaration).
- `git show 5142b52:corpus/rendered-text-v1.py` → Sources paragraph at lines 45–46:
  `Sources (opened round 24, see corpus/SOURCES.md): Python `re` \\s for str` / `patterns and Python
  `html.unescape`.` — no `S###` id.
- `sha256sum` of the docstring at `19025d9` and at `5142b52` → identical
  (`7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf`).
- `git diff 19025d9 5142b52 -- corpus/rendered-text-v1.py` → empty (the BASE docstring is the
  predeclaration docstring).
- `git show 19025d9:corpus/SOURCES.md | grep -cE '^\| S[0-9]{3} '` → 96; same at `5142b52` → 96;
  `grep -cE '^\| S09[78] '` → 0 (neither new id exists yet).
- Superseded-id set from `corpus/SOURCES.md`: S006 S007 S012 S013 S014 S016 S027 S028 S034 S035 S036
  S039 S040 S041 S047 S049 (S027 is superseded — the reason the C2 decoy control reads (a)=0).
- Control receipts, read from the committed files: `c1-control-refuse-all.txt` → 0,
  `c1-control-accept-all.txt` → 0, `c1-control-no-gate.txt` → 0, `c2-base-19025d9.txt` → 1,
  `c2-control-decoy.txt` → 2.
- `comm -12` id-collision guard: lane registry ids (96) vs {S097, S098} → empty (rc 0); {S097, S098} vs
  the eight round-37 quarantined ids → empty (rc 0); lane ids vs those eight names → S053 S071 S081 S090
  S091 S093 (the known spelling collision).
- Live re-opens (scratch): `re.html` → 257722 bytes, sha256 `ef2d8abe…469b1`, `cmp` against the committed
  round-40 capture → identical (rc 0), quote at raw offset 75897, `locate` count=1.
  `stdtypes.html` → 815447 bytes, sha256 `e2992e17…62e2b3`, `locate` on the isspace sentence → count=1
  (rc 0); raw offsets 295179 (the whitespace sentence, markup-split), 296702 (`its general category is`),
  296299 (`IDEOGRAPHIC SPACE`); no raw U+3000 byte in the body.
  `tr18/` → 199607 bytes, sha256 `68e34b8b…8c70d`; `locate` for `\p{White_Space}` → count=0 (rc 1, the
  quote is absent); `White_Space` present at raw offset 45641.
  `PropList.txt` → 149040 bytes, sha256 `f438f532…55d6`; `White_Space` = 25 code points, `str.isspace()`
  = 29, difference exactly {U+001C, U+001D, U+001E, U+001F}, reverse difference empty.
- `grep -n 'TMPDIR' corpus/{anchor-pins,claims-declared,prefreeze-control,self-description-sweep,surface-census}.sh`
  → the five scratch-default lines cited in the Routed section.
- `grep -n 'not amended after data' SCORECARD.md` → the round-40 post-move sentence is at `SCORECARD.md:1516`.
- `grep -n 'kagi round=41' /home/vgpnk/Projects/shokunin/.ufo/watchdog.log` → the launch line quoted in
  the LOG entry draft; no completion line yet.
- `grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → 0 (considerthese proposal 3 unimplemented);
  `grep -n 'lane-status:' SCORECARD.md` → 3 (proposal 2 landed in round 31).

## Limits of this draft

- The seat wrote drafts, not measurements: every number the L1 must own is a slot above; no landing
  value is asserted.
- The absent-defect register file is absent on this host, so the eight quarantined ids come from the
  committed round-37 lesson table, not from the register itself.
- `plans/round-41.md` is the only plan-side artifact read in full; the C1/C2 counters and the controls
  runner were read but not executed by this seat (the executor seats own those runs).
