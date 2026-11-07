# R62ScribeRecords — round-62 record surface (scribe)

Seat: `R62ScribeRecords`, role scribe, kagi round 62 attempt 1, wave `kagi-r62-w1`.
Write scope: `SKILL.md`, `corpus/QUALITY.md`, `corpus/lessons/round-62.md`, receipts under
`.ufo/waves/round-62/build/R62ScribeRecords/`, this report. No product code, no commit,
no mutating git/jj command, no `LOG.md`/`SCORECARD.md`/`corpus/SOURCES.md` edit.

## Behavior

1. `SKILL.md` gains `## Gate registry — round-61 additions (routed D2, round 62)` with one
   row each for `plans/round-61-c1-check.py`, `plans/round-61-c2.sh`,
   `corpus/openbao-seal-trial.sh`, and `## Gate registry — round-62 additions` with one row
   each for `plans/round-62-c1.sh`, `plans/round-62-c2.sh`, `plans/round-62-controls.sh`.
   All six rows parse to eight cells in the house column order
   (`name | kind | entry command | verdict map | selftest | pinned values | write scope | owner`),
   every `kind` is `gate`, every selftest cell carries a runnable spelling and the measured
   case count, and no cell reads `none of its own` (QM76). Append-only: the round-60 table's
   last row is unchanged.
2. `corpus/QUALITY.md` gains `## Criteria from the round-62 instrument-falsifiability work`
   with QM81 (asserting-position token test; a negation or a swapped pairing keeps every
   token and must read unresolved; token presence is a declared ceiling) and QM82 (a gate's
   self-invocation must execute its own aggregation; a constant or unconditional aggregation
   mutant must fail it; a guard must read 0 on a valid-but-incomplete tree), each citing
   `corpus/lessons/round-62.md` and the measured evidence.
3. `corpus/lessons/round-62.md` (new) carries `## Gate` (seven rows S128–S134: four admits,
   three rejects, each with URL, access date 2026-11-07, a located ≤25-word quote, reason and
   flip), `## Mistakes` (six rows, every fix shown able to fail), `## Corrections`
   (D1/D2/D4/D5 plus plan Amendment A1), `## Routed dispositions` (D1–D5),
   `## Wave` (`pending results`, the L1 fills it from `w1-results.json`) and `## Bounds`.

## Gates (measured by this seat)

- `bash plans/round-62-routed.sh` ⇒ `ROUTED: resolved=3 population=5 d1=1 d2=1 d3=1 d4=0
  d5=0` (`d1:correction=yes receipt-controls=18`, `d2:rows=6/6 kind-or-selftest-bad=0`,
  `d3:derived 4/14=28.57 plan-states=yes`, `d4:no receipt`, `d5:receipts=0/3`). `d1`/`d2`
  are this seat's legs; `d3` was fixed by the L1 after this seat reported it; `d4`/`d5` are
  the L1's at integration.
- Instrument selftests, run on the final bytes (sha256, reading):
  `plans/round-61-c1-check.py` `f2afd9b8…` ⇒ `C1_CHECK_SELFTEST: PASS (75 cases)`;
  `plans/round-61-c2.sh` `20614697…` ⇒ `C2_SELFTEST: PASS (cases=21)`;
  `plans/round-62-c1.sh` `5c71947d…` ⇒ `C1_COUNTER_SELFTEST: PASS (7/7 checks)`;
  `plans/round-62-c2.sh` `59553ef4…` ⇒ `C2R62_SELFTEST: PASS (cases=16)`;
  `plans/round-62-controls.sh` `93587e6d…` ⇒ `CONTROLS_SELFTEST: PASS (cases=14)`;
  `corpus/openbao-seal-trial.sh` `a3bc8825…` ⇒ `SEAL_SELFTEST: PASS (cases=63)`.
- BASE census re-measured by this seat over an extracted `60b5b7b` tree: the five bypass
  fixtures B3–B7 each read `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0`, and the
  unmodified copy reads the same ⇒ `accepted=5 population=5`
  (`build/R62ScribeRecords/c1-bypass-base.txt`).
- M-A/M-B at BASE: `C2_SELFTEST: PASS (cases=11)` rc 0 for baseline, the constant `value=5`
  mutant and the unconditional `shims_ok=5` mutant (`m-a-m-b.txt`). On the hardened bytes:
  baseline `PASS (cases=21)` rc 0, M-A `FAIL (cases=21 failed=6)` rc 1, M-B
  `FAIL (cases=21 failed=3)` rc 1 (`hardened-m-a-m-b.txt`).
- Gate quotes re-resolved with `corpus/rendered-text-v1.py locate` against the committed
  capture bodies: S128/S129/S130/S131/S133 `count=1`; S132/S134 probe terms `count=0`
  (`gate-quotes.txt`).
- Registry effect measured: `corpus/SOURCES.md` 127 → 134 data rows
  (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'`), `corpus/source-fetches.tsv`
  170 → 177 lines (`wc -l`).

## Touched surfaces

| path | change |
|---|---|
| `SKILL.md` | two new registry sections, six rows (append; no existing line rewritten) |
| `corpus/QUALITY.md` | QM81/QM82 section appended after QM78–QM80 |
| `corpus/lessons/round-62.md` | new lesson draft, six sections |
| `.ufo/waves/round-62/build/R62ScribeRecords/{c1-bypass-base.txt,m-a-m-b.txt,hardened-m-a-m-b.txt,gate-quotes.txt}` | measured receipts |
| `.ufo/waves/round-62/w1/R62ScribeRecords.md` | this report |

## Out of scope (not done, by design)

- No product code and no instrument edit (`plans/round-62-*.sh`, `plans/round-61-*.py/sh`,
  `corpus/*.sh`): those belong to the executor seats.
- No commit, push, `git add`, or mutating `jj`; the L1 is the sole committer.
- No `LOG.md`/`SCORECARD.md`/`corpus/SOURCES.md` edit: D1's errata is the L1's
  working-tree edit; D4/D5 receipts, the `LOG.md` citations and the S130/S131 re-pin are
  the L1's at integration.
- `## Wave` stays `pending results`; the L1 fills it from `w1-results.json`.

## Findings

1. **`plans/round-62-routed.sh` leg `d3` read 0 on a correct plan** (reported to the L1):
   the frozen plan wraps its attack-share sentence between `=` and `28.57 %`
   (`plans/round-62.md:201-202`), so the leg's literal search missed although the derived
   reading is 4 of 14 = 28.57 %. The L1 flattened the plan's whitespace in the leg; it now
   reads `d3=1`. The plan text was not amended for this.
2. **`plans/round-62-controls.sh --selftest` failed on its first landed bytes** (reported to
   R62ExecControls): rc 1, 13 `FINDING R62C-CTL-ST-*` lines, `CONTROLS_SELFTEST: FAIL
   (cases=0 failed=14)`. The final bytes read `CONTROLS_SELFTEST: PASS (cases=14)` rc 0; the
   registry row carries the final reading.
3. **S130/S131 re-pin.** Both rows were first pinned over the PMC article HTML, whose bodies
   were replaced by the token-free NLM XML of the same records. The lesson's Gate rows carry
   the re-pinned URLs and digests; `corpus/source-fetches.tsv` stays stale for those two
   rows until the L1 applies `capture/notes.md` §"RE-PIN REQUIRED".
4. **PMID `11554662` is not NegEx** (Europe PMC resolves it to a 2001 rhinology case
   series); reported, not amended — the plan is frozen and names no PMID.
5. **Plan Amendment A1** (I6 clause d) was added by the L1 in the working tree after the
   predeclaration commit; the lesson records it under `## Corrections`, and the BASE census
   is unaffected.
6. **Registry case counts are landing-time measurements.** The round-61 checker moved
   52 → 75 cases and the C2 counter 11 → 21 during the wave; the rows carry the final
   readings, re-measured after the last byte change.

## Artifact paths

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/QUALITY.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-62.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-62/build/R62ScribeRecords/`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-62/w1/R62ScribeRecords.md`

SEAT-STATUS: complete
