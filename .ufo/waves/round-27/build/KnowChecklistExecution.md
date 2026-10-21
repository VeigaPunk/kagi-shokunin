# KnowChecklistExecution — C1 inventory, `corpus/knowledge/checklist-execution.md`

Scope: round-27 C1 only (knowledge-entry number binding). No production file written;
no gate, ledger row, selftest, release-clock case or `c1-measure.py` executed. Frozen
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. The entry is BASE-equal in the working
tree (`git diff --quiet BASE -- corpus/knowledge/checklist-execution.md` exit 0),
207 lines, blob sha256 `485e219a06c5b92f964620e6c2cab3ef35e1aef024aa7b0ce3bb89affba81fd6`.
Source-file digests read at BASE: `corpus/checklist.tsv`
`28bd238e549c579d92b9818a9a2e98c0e8153957a18bc89384b1cc5c39972f04`
(41 lines, no trailing newline, 16 data rows at `26-41`, 8 fields, 25 comment/blank
lines), `corpus/checklist-run.sh`
`7e5ec98b9e1d0afaa4d4d0f0d91f897236e8a8b4c7912ccad94d86492fd576bf` (506 lines).

Axes: **calibration** (which current-tense numbers exist, which are bound, which can be
bound without executing host rows), **freshness** (bind to a live-executable non-host
row where one exists; refuse prose pins that cannot move), **honesty** (name every
exclusion and every unbindable value instead of promoting a label to a binding).

## Verdict

- **5 current-tense numbers in this entry are lane-local scope; 0 are STALE at BASE.**
  Four are bindable by a binder source kind (3 bound, 1 proposed), one is blocked only
  by its word form (below).
- 3 are already bound by the round-27 `KN-CHECKLIST-*` rows (`corpus/self-counts.tsv:65-67`
  in the working tree; these rows are round-27 additions and absent at BASE:
  `git show BASE:corpus/self-counts.tsv | grep -c KN-CHECKLIST` = 0).
  Their locators each match exactly one entry line, capture the pinned value, and a
  simulated one-digit mutation of the captured digit turns each one STALE.
- 1 more is cleanly bindable today and **unbound**: `floor=8` at line 179
  (`ledger:R15-05`).
- 1 more is current and **unbindable in its present wording**: `Seven rows are by-hand`
  at line 80. The binder captures only digits (source validation
  `corpus/self-counts.py:140-148`, integer parse `:120`); the nearest digit on that
  line is `E2`'s id, so any
  `([0-9]+)` locator captures `2`, not `7` (counterexample below).
- The remaining current-tense numbers describe row fields, script constants and
  declaration pins that no `rows:` / `ledger:` / `expect:` source exposes (Table B).
  They are out of population by source kind, not by doubt; each live value was read
  from its defining artifact and is listed.
- The entry's headline `runnable=9` appears only inside the round-15 history clause
  (line 82). Falsifier 5's `runnable=6` is `9 - 3`, so that derived expectation rests
  on an unbound historical value (residual, below).

## Table A — in population and bindable (self-counts format + line/live/status)

Columns: `id  doc  line  locator  source  extract  live  status  note`.
Every locator has exactly one capture group and was run against the BASE entry text;
`unique=1` for each (verified in-process, not by the binder).

```tsv
KN-CHECKLIST-SELFTEST	corpus/knowledge/checklist-execution.md	63	`--selftest` proves ([0-9]+) cases on scratch	ledger:R15-02	^CHECKLIST_SELFTEST: PASS \(([0-9]+) cases\)$	34	OK	already bound (corpus/self-counts.tsv:65); R15-02 is non-host (tag check: claim-ledger.tsv R15-02 note has no [host]/[substrate])
KN-CHECKLIST-FALSIFY-ROWS	corpus/knowledge/checklist-execution.md	173	^1\. Add a 17th .*?\(items=17 rows=([0-9]+)\)	ledger:R15-04	^([0-9]+)$	16	OK	already bound (corpus/self-counts.tsv:66); R15-04 command is a grep over checklist.tsv, non-host
KN-CHECKLIST-FALSIFY-ITEMS	corpus/knowledge/checklist-execution.md	179	^5\. Convert three runnable rows .*?items=([0-9]+)\)	ledger:R15-04	^([0-9]+)$	16	OK	already bound (corpus/self-counts.tsv:67)
KN-CHECKLIST-FALSIFY-FLOOR	corpus/knowledge/checklist-execution.md	179	^5\. Convert three runnable rows .*?floor=([0-9]+)	ledger:R15-05	floor=([0-9]+)	8	OK / UNBOUND	proposed; floor is live arithmetic (checklist-run.sh:73 FLOOR_DEN=2, :174 floor_of, :246 defect line); R15-05 runs `--ratio`, which executes no row (claim-ledger.tsv R15-05 note), so it is a safe ledger: binding
```

Pinned live values read from `corpus/claim-ledger.tsv`:
`R15-02 ^CHECKLIST_SELFTEST: PASS \(34 cases\)$`, `R15-04 ^16$`,
`R15-05 ^CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6$`,
`R15-03 ^CHECKLIST_LIST: rows=16 runnable=9 by_hand=7$`. Independent reads:
`corpus/checklist.tsv` has 16 data rows (`rows:corpus/checklist.tsv` semantics: nonblank,
non-`#`), 7 `by-hand`, 8 fields; `corpus/checklist-run.sh` has 34 selftest cases
(33 lines matching `^  run "` plus `CT=1 run "row timeout"` at :439; the counter
increments once per `run` at :414) — so the `34` is not merely a stale pin copy.

`R15-01` is **`[substrate]`**-tagged (note field), so `ledger:R15-01` is refused by
`corpus/self-counts.py:259-260`. The headline pin
`^CHECKLIST_RUN: CLEAN \(items=16 runnable=9 by_hand=7 failed=0\)$` is therefore
reachable only as `expect:R15-01` (pin read, nothing executed). `R15-03` is an
untagged, row-skipping alternative that carries `rows=16 runnable=9 by_hand=7`.

### A2 — current and live-sourced but not bindable as written

| line | text | live source | live | why not bindable |
|---|---|---|---|---|
| 80 | ``Seven rows are `by-hand` `` | `corpus/checklist.tsv:26-41` (7 `by-hand`), pin `ledger:R15-03` `by_hand=([0-9]+)` = 7 | 7 | the number is a word. `([0-9]+)` cannot capture it; the first digit on the line is `E2`'s `2` (verified: `^Seven rows are .*?([0-9]+)` → `2`, one line). A text fix `Seven`→`7` (L1 production edit) makes locator ``^7 rows are `by-hand` `` unique and bindable to `ledger:R15-03` |

Proposed row after that text fix:

```tsv
KN-CHECKLIST-BYHAND	corpus/knowledge/checklist-execution.md	^7 rows are `by-hand`	ledger:R15-03	by_hand=([0-9]+)	§4 current by-hand count (existing text says "Seven"; binder captures digits only)
```

This is the only current-tense statement of the by-hand count in the entry. Its value
is 7 today (`corpus/checklist.tsv`; `R15-03`), so the miss is coverage, not drift.

## Table B — current-tense, lane-local-definable, but no binder source kind exposes it

Each value below was read from the defining artifact at BASE and is correct; none can
be written as `rows:` (that kind counts data lines only, `corpus/self-counts.py:10,88`),
and no committed ledger row's last line carries it. They are **out of population** by
source kind; a new ledger row is a production decision for L1, not a report edit.

| entry line | text | defining artifact (BASE) | live | note |
|---|---|---|---|---|
| 23 | `The execution layer is now two files:` | the table at `27-28` (`corpus/checklist.tsv`, `corpus/checklist-run.sh`) | 2 | no source kind counts table rows; word form, no pin |
| 30 | `## 2. The declaration — eight columns` | `corpus/checklist.tsv:26-41` (8 tab fields), `corpus/checklist-run.sh:132` (`want 8`) | 8 | no source kind counts columns; would need a shape probe row |
| 39 | `timeout ${CHECKLIST_TIMEOUT:-240}` | `corpus/checklist-run.sh:72` | 240 | default constant, no pin |
| 40 | `H7 uses three` accepted alternatives | `corpus/checklist.tsv:40` field 5 = `0\|1\|2` | 3 | alternatives are inside one TSV field; no pin exposes them |
| 42 | `<text ≥ 24 chars>` | `corpus/checklist-run.sh:156` (`.{24,}` after `<class>: `) | 24 | threshold constant, no pin |
| 50 | `floor = ceil(items/2)` | `corpus/checklist-run.sh:73` (`FLOOR_DEN=2`), `:174` (`floor_of`) | 2 | divisor constant; R15-05 pins the resulting floor (8), not the divisor |
| 51, 150 | `up to 6 lines` / `≤6 lines` | `corpus/checklist-run.sh:266,271,276` (`tail -n 6`) | 6 | output cap, no pin |
| 59 | `≥20 non-space characters` | `corpus/checklist-run.sh:160` (`ns >= 20`) | 20 | threshold constant, no pin; complements the 24-char rule, not a contradiction |
| 74 | `the two receipt keys` | `corpus/checklist.tsv:33` (E8 check keys `access_receipt`, `receipt_sha256`) | 2 | no pin; host path is read by the row, so a live binding would also be host-dependent |
| 76 | `the overlay's four knobs` | `corpus/checklist.tsv:36` (H3 keys: enabled_providers, share, autoupdate, default_agent) | 4 | no pin; row reads host config |
| 77, 183 | `steps: 4` | `corpus/checklist.tsv:37` (H4 requires `^steps: 4$`) | 4 | no pin; row reads host agent front-matter |
| 120 | `pins hits=0 excluded=5 raw=5` | `corpus/checklist.tsv:29` (E4 `expect_last`); repo sweep at BASE | 0 / 5 / 5 | E4's last line is not any ledger row's last line; R15-01 is `[substrate]`, and `--only E4` does not expose it either — on success `verify` discards the row's stdout and prints `CHECKLIST_ROW: CLEAN (id=E4 …)` (`corpus/checklist-run.sh:292`). Binding it needs a dedicated ledger command (production decision). Independent count at BASE: 5 raw hits (3 `vault`-named, 1 `FakeVault`, 1 `wal`), 0 outside the allowlist |
| 120-121 | `The three exempt ... names` | `corpus/checklist.tsv:29` allowlist alternation | 3 | no pin |
| 121 | `on the three documented example lines` | `corpus/knowledge/op-env-refs.md:14`, `corpus/lessons/round-5-aggregator-audit.md:19`, `corpus/transcript-scan.sh:202` | 3 `vault`-named lines | no pin; the erratum at 198-204 already qualifies that one is a synthetic fixture, not prose documentation |
| 122 | `inside the two gate scripts` | `corpus/surface-census.sh:609`, `corpus/transcript-scan.sh:242` | 2 | no pin |
| 127 | `names exactly two states` | `corpus/checklist.tsv:40` `expect_last` two-branch alternation | 2 | no pin; note the exit set has three accepted exits (`0\|1\|2`), so "two states" counts outcome shapes, not exits |
| 137, 166 | `password_refs=0`, `non_loopback=0`, `established=0` | `corpus/checklist.tsv:41` (H8 `expect_last`) | 0/0/0 | host-dependent row; R15-01 is `[substrate]`; not executed here |

## Table C — excluded numbers and why (not silent omissions)

1. **Dated source basis, lines 3-5** — `2026-09-28 (round 15)`, `16 items`,
   `L420–447 at the round-15 revision`, `16 rows`. Excluded by the round-27 class
   "sections dated as measurements (`Source basis: measured …`)"
   (`corpus/lessons/round-27.md` §C1). Both counts still agree with live sources
   (`SKILL.md` §Credential-hygiene checklist has 16 `- [ ]` bullets at BASE;
   `rows:corpus/checklist.tsv` = 16), so the exclusion hides no drift. If L1 waives the
   class, line 4's `16` binds via `expect:R15-01` `items=([0-9]+)` (substrate pin) and
   line 5's `16` via `rows:corpus/checklist.tsv`; locators
   `§Credential-hygiene checklist \(([0-9]+) items` and
   `` ^revision\), `corpus/checklist\.tsv` \(([0-9]+) rows`` are unique.
   The `L420–447` span is not the BASE span (heading is `SKILL.md:425`); the erratum at
   196-200 already says to use the named section.
2. **Line 11 `R15-01 … R15-05`** — row ids, not counts.
3. **Line 15 `16` bullets "Before round 15"** — explicit history clause.
4. **Lines 18-21 `12`, `≥3`, `14`, round 15** — quoted scorecard claim and round-15
   census about earlier revisions; history.
5. **Lines 82-83 `runnable=9/16 floor=8 by_hand=7`, "one row of margin"** — explicit
   "Baseline at the round-15 revision" clause. It happens to agree with live values
   (`R15-03`, `R15-05`), but `runnable=9` is stated nowhere current.
6. **Lines 94-96 `runnable=3 by_hand=13`, `8/8`** — past lane measurements of
   alternative criteria; history.
7. **Line 101 `all nine`** — past review activity ("a lane … by reading all nine").
8. **Line 106 `two reasons`** — narrative split of the by-hand rationale; no committed
   artifact size or pin defines it (the TSV has four distinct reason classes:
   manual-change, authoring-duty, runtime-behavior, cross-lane).
9. **Line 128 `HITS=2`** — explicitly the 2026-09-28 baseline and a host DB
   observation; host/substrate class. The declaration's `expect_last`
   (`corpus/checklist.tsv:40`) still carries `HITS=2`, but reading the DB is host work
   not done here.
10. **Exit codes (lines 37, 49-60, 128, 133, 173-191) and section ordinals** — mechanism
    constants, not artifact sizes.
11. **Lines 160-161 `16-row`, `runnable=16/16`** — a lane's constructed counterexample
    fixture, not an existing artifact's size.
12. **Line 173 `17th` / `items=17`** — mutation input (hypothetical); `rows=16` is
    Table A.
13. **Line 175 `item 15`** — positional case index; excluded by rule
    (`corpus/lessons/round-27.md` §C1).
14. **Line 179 `three`, `runnable=6`** — mutation input and its arithmetic (`9 - 3`),
    not live values.
15. **Line 183 `entries=3`** — the widened state after adding a grant (current
    declaration implies 2 entries, not stated); `steps=4` is Table B.
16. **Line 188 `two` silent-death bugs** — round-15 build history.
17. **Lines 193-206 Erratum** — explicitly historical block.
18. **`E1–E8` / `H1–H8` (line 36), port `40961` (78, 135), `R15-xx` ids, round numbers**
    — identifiers, not counts. Enumerated lists with no numeric token (the five
    reason classes at line 42) and generic pair rules ("two by-hand rows share one
    reason", line 56; "text that appears twice", line 176) are likewise not artifact
    sizes; the two-files count (line 23) and the floor divisor (line 50) are Table B.

## Counterexamples and residuals

1. **Word-form count defeats the digit binder (executed in-memory).**
   `^Seven rows are .*?([0-9]+)` matches line 80 once and captures `2` (from `E2`), not
   `7`. A row written this way would be green regardless of the real by-hand count and
   would pass `c1-measure.py --mutate` while mutating a row id. The current three
   bindings avoid this because their numbers are digits.
2. **`ledger:R15-01` is refused, not measured.**
   `corpus/claim-ledger.tsv` R15-01 carries `[substrate]`; `corpus/self-counts.py:260`
   fails `POLICY`. Any future binding of `items=16` or the headline `runnable=9/...`
   must use `expect:R15-01` or the non-host `R15-03`/`R15-05`, not `ledger:R15-01`.
3. **Falsifier 5's `runnable=6` has no current anchor.**
   It is `9 - 3`; `9` occurs only in the round-15 baseline clause (line 82) and in
   pinned gate output. If a row changes class, the falsifier's expected `runnable=6`
   goes wrong while every existing/proposed binding stays green (`items=16`,
   `floor=8`, `rows=16` are unaffected). Named residual; remedy is a current-tense
   `runnable` statement bound to `ledger:R15-03` `runnable=([0-9]+)`, an L1 choice.
4. **E4's pin is the closest unbindable lane-local number.**
   `hits=0 excluded=5 raw=5` is current, repo-measured and allowlist-dependent, yet no
   ledger row exposes it. `--only E4` is not a workaround: `only_row`
   (`corpus/checklist-run.sh:320-333`) calls `verify`, which prints a row's output
   only on failure and ends a passing single row with
   `CHECKLIST_ROW: CLEAN (id=E4 …)` (`:292`). A binder
   for this triple needs a dedicated non-host ledger command that reproduces the sweep;
   the H7/H8 pins cannot be bound the same way without host execution.
5. **Freshness / C2 boundary.** This entry has **no `recheck:` line** (`grep -E
   'recheck:|on-release'` exit 1) and no release clock; its declared reverify is the
   five ledger rows at line 11. Freshness here is ledger re-execution, and the three
   existing bindings use non-host rows. The release-clock regression rule
   (`corpus/release-clock.py`) is C2's file and was not read or run by this seat.
6. **Mutation sensitivity (simulated, not a gate run).** Bumping the first captured
   digit in memory (`c1-measure.py`'s rule) gives 34→44, 16→26, 16→26, 8→9; each
   differs from its pin, so each binding would report STALE. No `self-counts.py`,
   `checklist-run.sh`, `c1-measure.py` or ledger row was executed.

## What I did NOT check

- No execution of `corpus/checklist-run.sh` in any mode, `corpus/self-counts.py`,
  `c1-measure.py`, or any `R15-*` ledger row. "OK" means the entry text agrees with
  the committed pin **and** with the defining source file read at BASE; it is not a
  fresh execution receipt.
- No host/private surfaces read: transcript DB (H7 `HITS=2`), `~/.config/...`
  (H3/H4), `~/.local/bin/the-janitor` and sockets (H1/H8). Those numbers are excluded
  as host/substrate observations, not verified.
- Did not verify the SKILL checklist section's end line or the round-15 revision's
  `L420–447`; only the BASE heading (`SKILL.md:425`) and the 16-bullet count.
- Did not audit any other knowledge entry, the C2 release-clock change, or the
  `c1-measure.py` after-run; scope is this entry only.
- Tool installs/upgrades: none.
