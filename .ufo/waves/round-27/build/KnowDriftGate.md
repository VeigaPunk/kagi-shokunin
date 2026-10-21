# KnowDriftGate — C1 inventory, `corpus/knowledge/drift-gate.md`

Scope: round-27 C1 only (knowledge-entry number binding). No production file written; no
gate, ledger row, selftest, release-clock case or `c1-measure.py` executed. Frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`.

Entry identity: `corpus/knowledge/drift-gate.md` sha256
`ca3702fce29c0b1ba1349c49fdfb30478a06296c0227140245cbab79b2714da2`, BASE-equal in the
working tree (compared `git show BASE:…` against the working file; identical). It has
**216 logical lines and 215 newlines** (no final newline), 14000 bytes — the
`corpus/stamps.tsv:35` row records the `wc -l` value `215` and the same sha. Line numbers
below are logical lines 1–216.

Source identities read at BASE: `corpus/drift-baseline.tsv`
`90c2d7a52360e97201b6fb766cd8f26fc653daa2a38bcefc40edcac6576c1bda` (15 data rows,
lines 1–15, no comments); `corpus/drift-symbols.tsv`
`dca651da9183e92ea74c61e687d89912e0ed38d79962fab0000331c4a36e515e` (30 lines: 10
comment lines 1–10, 20 data rows 11–30); `corpus/drift-pins.sh`
`c138d34c7f0dfe950fce0e5e6672cc788b5ad080bc388d4aef118db0e6c70feb` (451 lines, stamps row
`corpus/stamps.tsv:17`); `corpus/claim-ledger.tsv`
`3fcdab10441d18038726f15420ccc58c36c292c698a9c8ad433c3725fb7c2aa5` (65 claim rows at
BASE); `corpus/self-counts.tsv` `ceadba8964006d29b4ab2cca9256615730c3829ac7af8f8738cb55b8412d80f4`
(52 lines, **0** `KN-` rows at BASE). Row citations below use BASE line numbers.

Snapshot caveat: `corpus/self-counts.tsv` and `corpus/claim-ledger.tsv` are being edited
by other round-27 seats while this was written. The working table was observed at three
digests — `7118d9d0…` (75 lines), `8e0083f6bdaf2bd5682de8da4bcd1b26c90b9062badc31be5386276ac3a957a1`
(79 lines, 22 `KN-` rows) and `67d5d1db28f1882d4408ef215744cc5564e896223523ca89f6f459a6930ce908`
(79 lines) — and **every snapshot holds exactly one row whose `doc` is this entry**:
`KN-DRIFT-BOUND-FILES` (line 71 in the 75-line snapshot, line 69 in both 79-line ones),
matching line 143 and capturing `15`. Whichever table
L1 lands, the per-row facts below are unchanged: one row targets this entry, and twelve
of the thirteen mutations in §Counterexamples reach no row.

Axes: **calibration** (which current-tense numbers exist, their defining source, and
whether each agrees with it), **freshness** (bind a live re-observation where one exists;
name the anchors that cannot regress), **honesty** (name every exclusion and every
unbindable value rather than call it bound).

## Verdict

- **13 current-tense numbers about this lane's own artifacts, on 10 lines; 0 are STALE
  at BASE.** Each was compared to its defining source, not to another prose copy.
- **6 are bindable by a binder source kind**: four `rows:` (baseline ×3, symbols ×1) and two `ledger:R11-05` (selftest cases). The draft binds **1**
  (`KN-DRIFT-BOUND-FILES`, `corpus/self-counts.tsv:69` in the snapshot; absent at BASE,
  where the `KN-` row count is 0).
- **7 have no source kind at all**: `451` lines, the `×2` count pins, `9` hashed rows,
  `6` no-hash rows (stated twice), and two `0` content-class counts. `rows:` counts every
  data line and nothing else (`corpus/self-counts.py:142-148`, `:340`), so it cannot
  express a subset count, a column value, or an occurrence count.
- Mutation proof (simulated in-process, no gate): **1 of 13** one-digit mutations reaches
  the draft binder — only `of 15` at line 143. The five proposed `rows:`/`ledger:` rows
  take it to 6/13 with **zero new claim rows**; four claim rows take it to 11/13; the two
  `0`s need a helper or a categorical rewording (below).
- This entry is **not** one of the five STALE knowledge numbers measured at BASE
  (`corpus/lessons/round-27.md:86`, M27-2). Its defect class is coverage, not value: no
  digit here needs correcting, and no history clause is owed.

## Table A — in population and bindable (self-counts format + line/live/status)

Columns: `id  doc  line  locator  source  extract  live  status  note`. Every locator has
exactly one capture group and matches exactly one line of the BASE entry (verified
in-process against the entry text, not by the binder). `rows:` values are live counts
computed at run time; `ledger:` values are the row's live output, whose committed pin is
quoted.

```tsv
KN-DRIFT-BASE-ROWS	corpus/knowledge/drift-gate.md	4	^`corpus/drift-baseline\.tsv` \(([0-9]+) rows\)	rows:corpus/drift-baseline.tsv	-	15	OK / UNBOUND	Sources header; proposed, no claim row needed
KN-DRIFT-SYM-ROWS	corpus/knowledge/drift-gate.md	4	^`corpus/drift-baseline\.tsv` \([0-9]+ rows\), `corpus/drift-symbols\.tsv` \(([0-9]+) rows\)	rows:corpus/drift-symbols.tsv	-	20	OK / UNBOUND	Sources header; proposed
KN-DRIFT-BOUND-DENOM	corpus/knowledge/drift-gate.md	143	^- \*\*[0-9]+ of ([0-9]+) files are content-unhashed	rows:corpus/drift-baseline.tsv	-	15	OK / BOUND	= KN-DRIFT-BOUND-FILES (corpus/self-counts.tsv:69 snapshot); matches "of 15", not the numerator
KN-DRIFT-ROW-LIST	corpus/knowledge/drift-gate.md	159	^  ([0-9]+)-row list\.	rows:corpus/drift-baseline.tsv	-	15	OK / UNBOUND	Bounds: explicit list size; proposed
KN-DRIFT-SELFTEST-CASES	corpus/knowledge/drift-gate.md	189	^Selftest cases \(([0-9]+)\): clean, content drift	ledger:R11-05	^DRIFT_SELFTEST: PASS \(([0-9]+) cases\)$	13	OK / UNBOUND	R11-05 pin (corpus/claim-ledger.tsv:19) is ^DRIFT_SELFTEST: PASS \(13 cases\); source text has 13 `run` calls at corpus/drift-pins.sh:408-438; proposed
KN-DRIFT-FALSIFY-CASES	corpus/knowledge/drift-gate.md	197	^Run the commands above: clean run, ([0-9]+)-case selftest	ledger:R11-05	^DRIFT_SELFTEST: PASS \(([0-9]+) cases\)$	13	OK / UNBOUND	Same source as the row above; self-counts caches one output per source (corpus/self-counts.py:350-354); proposed
```

Pinned live values: `R11-05` = `13` (committed pin, `corpus/claim-ledger.tsv:19` at
BASE); `rows:corpus/drift-baseline.tsv` counts 15 nonblank non-`#` lines;
`rows:corpus/drift-symbols.tsv` counts 20. `R11-05` is **not** `[host]`/`[substrate]`
tagged, so `ledger:R11-05` is admissible: `bash corpus/drift-pins.sh --selftest` builds
its own `mktemp -d` tree (`corpus/drift-pins.sh:374-396`) and the policy scan of the
script finds no nested `bash`/`python3` command (grep for `^\s*(bash|python3)\s` exit 1).

Independent read: the selftest has exactly 13 `run` calls
(`corpus/drift-pins.sh:408,410,412,414,417,420,423,426,429,432,434,436,438`) and prints
`DRIFT_SELFTEST: PASS (%d cases)` at `:444`, so the `13` is not merely a copied pin.

## Table A2 — current, lane-owned, but no `rows:`/`ledger:`/`expect:` source kind exists today

All seven are **OK at BASE**; each live value was read directly. None is "stale"; each is
invisible to a one-digit mutation in the present draft (and would remain invisible even
after the Table A rows are added).

Columns: `line  exact text (fragment)  number  status  defining artifact and live value
 why not bindable`. The fragments are verbatim; the original document's table delimiters
are left in place, which is why this block is TSV rather than a markdown table.

```tsv
3	`corpus/drift-pins.sh` (round-9 v2, 451 lines,	451	OK	corpus/stamps.tsv:17 col 3 = 451; wc -l of the script = 451; the prose sha prefix c138d34c…0feb also matches that row	the only machine source is a stamps row; rows:corpus/drift-pins.sh would count 354 non-comment lines, not 451. A ledger row can print the stamps row and let extract take field 3 (proposal D4), but it anchors to the stamp, not to the file
59	| `handoff-status.json:#1` ×2 | count |	2	OK	two #1 rows, corpus/drift-symbols.tsv:28-29	subset count; rows: counts all 20 symbol rows. grep -c 'handoff-status.json' corpus/drift-symbols.tsv → 2 (proposal D3)
97	| everything else | 9 files, mode 644/755 |	9	OK	nine baseline rows carry a 64-hex hash (corpus/drift-baseline.tsv, col 4 ≠ -)	subset count; grep -cE '[[:space:]][0-9a-f]{64}$' → 9 (proposal D2). Caveat: one of the nine is mode 600 (the native-messaging manifest, drift-baseline.tsv:15), which the entry's own Erratum (:204-209) already concedes; the count is right, the class label is the corrected part
101	from its hash alone, with zero host contact. The cost is explicit: for the 6	6	OK	six baseline rows end \t- (col 4 = -): drift-baseline.tsv:4,5,11,12,13,14	subset count; grep -cE '[[:space:]]-$' → 6 (proposal D1)
143	- **6 of 15 files are content-unhashed** (policy above): their content drift is	6	OK	same six rows	as line 101; one proposal row serves both
110	Verified clean: the committed TSVs contain 0 `op://` refs	0	OK	grep -c 'op://' corpus/drift-baseline.tsv corpus/drift-symbols.tsv → 0 and 0 at BASE	aggregate of two files; a single allowlisted command cannot sum them (grep -c with two files prints per-file counts and the ledger matches only the last line). See §Counterexamples 4
110	… refs and 0 `op.env` key	0	OK	grep -cE '^[A-Z][A-Z0-9_]*=' → 0 and 0 at BASE; the only key-shaped token is the ERE ^[A-Z][A-Z0-9_]*= quoted as the op.env pin text (corpus/drift-symbols.tsv:13), which is a pattern, not a name	same aggregate problem. Rewriting the sentence as "no op:// refs and no op.env key names" removes both digits and the class from QM21 entirely (an L1 editorial choice)
```

Locators for these seven (Python, one capture group each, each verified to match exactly
one line of the entry). The first five are the locator column of the proposed rows below;
the two zero locators have no source row to attach to today.

```tsv
451	^Sources: .*\(round-9 v2, ([0-9]+) lines,	KN-DRIFT-PINS-LINES
2	^\| `handoff-status\.json:#1` ×([0-9]+) \|	KN-DRIFT-HANDOFF-PINS
9	^\| everything else \| ([0-9]+) files, mode 644/755 \|	KN-DRIFT-HASHED-FILES
6	^from its hash alone.*for the ([0-9]+)$	KN-DRIFT-NOHASH-6
6	^- \*\*([0-9]+) of [0-9]+ files are content-unhashed	KN-DRIFT-BOUND-NUMERATOR
0	^Verified clean: the committed TSVs contain ([0-9]+) `op://` refs and	(no source kind)
0	^Verified clean: the committed TSVs contain [0-9]+ `op://` refs and ([0-9]+) `op\.env` key	(no source kind)
```

Judgment call: lines 110's `0`s are present-tense ("contain 0") and describe lane-owned
committed files, so they are listed; a reviewer who classes the sentence as the round-9
scribe receipt (its parenthetical provenance) would drop both to Table C and the totals
become 11/5 instead of 13/7. The values are 0 either way.

### Proposed rows (ready to paste; ids are L1's to assign — no `R27-` id exists at this snapshot)

Self-counts additions (5 rows; no claim row, no code change, no new selftest case):

```tsv
KN-DRIFT-BASE-ROWS	corpus/knowledge/drift-gate.md	^`corpus/drift-baseline\.tsv` \(([0-9]+) rows\)	rows:corpus/drift-baseline.tsv	-	Sources header: baseline rows
KN-DRIFT-SYM-ROWS	corpus/knowledge/drift-gate.md	^`corpus/drift-baseline\.tsv` \([0-9]+ rows\), `corpus/drift-symbols\.tsv` \(([0-9]+) rows\)	rows:corpus/drift-symbols.tsv	-	Sources header: symbol rows
KN-DRIFT-ROW-LIST	corpus/knowledge/drift-gate.md	^  ([0-9]+)-row list\.	rows:corpus/drift-baseline.tsv	-	Bounds: explicit list size
KN-DRIFT-SELFTEST-CASES	corpus/knowledge/drift-gate.md	^Selftest cases \(([0-9]+)\): clean, content drift	ledger:R11-05	^DRIFT_SELFTEST: PASS \(([0-9]+) cases\)$	live scratch-tree selftest count
KN-DRIFT-FALSIFY-CASES	corpus/knowledge/drift-gate.md	^Run the commands above: clean run, ([0-9]+)-case selftest	ledger:R11-05	^DRIFT_SELFTEST: PASS \(([0-9]+) cases\)$	same source, cached
```

Claim rows for the four grep-bindable values (proposal; **each +1 to the claim-row
census** — see §Counterexamples 5):

```tsv
R27-D1	grep -cE '[[:space:]]-$' corpus/drift-baseline.tsv	^6$	0	30	no-hash baseline rows (subset pin for the drift-gate bounds prose)
R27-D2	grep -cE '[[:space:]][0-9a-f]{64}$' corpus/drift-baseline.tsv	^9$	0	30	content-hashed baseline rows (drift-gate hash-policy count)
R27-D3	grep -c 'handoff-status.json' corpus/drift-symbols.tsv	^2$	0	30	handoff count pins (the prose ×2)
R27-D4	grep -E '^corpus/drift-pins\.sh[[:space:]][0-9a-f]{64}[[:space:]][0-9]+[[:space:]][0-9]+$' corpus/stamps.tsv	^corpus/drift-pins\.sh[[:space:]][0-9a-f]{64}[[:space:]][0-9]+[[:space:]][0-9]+$	0	30	drift-pins stamp row; lines field read by extract
```

Corresponding self-counts rows:

```tsv
KN-DRIFT-PINS-LINES	corpus/knowledge/drift-gate.md	^Sources: .*\(round-9 v2, ([0-9]+) lines,	ledger:R27-D4	\t([0-9]+)\t[0-9]+$	anchored to the stamp row (see Freshness)
KN-DRIFT-NOHASH-6	corpus/knowledge/drift-gate.md	^from its hash alone.*for the ([0-9]+)$	ledger:R27-D1	^([0-9]+)$	bound inside the sentence, so one mutation point
KN-DRIFT-BOUND-NUMERATOR	corpus/knowledge/drift-gate.md	^- \*\*([0-9]+) of [0-9]+ files are content-unhashed	ledger:R27-D1	^([0-9]+)$	second occurrence of the same value
KN-DRIFT-HASHED-FILES	corpus/knowledge/drift-gate.md	^\| everything else \| ([0-9]+) files, mode 644/755 \|	ledger:R27-D2	^([0-9]+)$	hash-policy table
KN-DRIFT-HANDOFF-PINS	corpus/knowledge/drift-gate.md	^\| `handoff-status\.json:#1` ×([0-9]+) \|	ledger:R27-D3	^([0-9]+)$	count-pin table row
```

Dialect trap, executed: the ledger `expect` column is POSIX ERE and the self-counts
`locator`/`extract` columns are Python `re`. `[[:space:]]` works in the former and **not**
in the latter: `re.search(r"[[:space:]]([0-9]+)[[:space:]][0-9]+$", <stamps row>)` returns
`None` (FutureWarning "Possible nested set"), while `\t([0-9]+)\t[0-9]+$` returns `451`.
Use each dialect in its own column.

Zero-exit note: `grep -c` exits 1 when the count is 0 but still prints `0`, so a zero row
would need `exit=1` in the ledger. That is admissible but unusual; it does not solve the
two-file aggregate.

## Table C — excluded numbers and why (not silent omissions)

1. **Lines 5, 211–213 — `L292–298` (PROTOCOL line range).** Not lane-owned (`PROTOCOL.md`
   is the fleet-root document) and the entry's own Erratum declares the range a historical
   fleet revision locator, not current line numbers.
2. **Line 13 — `13 host files`, `exited 0`.** Past-tense property of the superseded v1
   printer ("v1 printed … and exited 0 unconditionally"). Not the present size of any
   committed artifact; the current equivalent is Table A's 15 rows.
3. **Line 16 — `grep -c baseline` → `0`.** Output of a past audit command; the erratum
   (`:211-214`) further fixes the revision it must be read at (`ea77bf0`). Historical.
4. **Line 18 — `2 of 13 files`.** The round-8 audit's finding, explicitly dated to that
   audit ("it found the kagi pins verifiable for only 2 of 13"). Historical finding count.
5. **Line 20 — `17→19`, line 21 — `L17`.** Explicit history clause "from round 4 to
   round 8"; the current pin line is `the-janitor:19` (`corpus/drift-symbols.tsv:12`).
   (The quoted values still agree with today's rows; they are nevertheless history.)
6. **Lines 27–28, 38–40 — example rows** (`755`, `333`, `600`, `17`, `19`, `#10`, `#1`).
   Schema examples, not claims about a present artifact. Their values happen to match the
   committed rows exactly, including `op.env` 600/17.
7. **Lines 54–59 — host file positions and pin targets** (`the-janitor:19`,
   `opencode.json:16`, `janitor.md:6,8`, `:148`, `:194`, `:196`, `:214`, `client.py:19,74`,
   `opencode.json:4,5`, `janitor_auth.ts:12`, `tac-check:63,69`, `op.env:#10`, `#1`).
   Host measurements of absent substrate — the item's explicit exclusion. Every one of
   them was compared row-by-row to `corpus/drift-symbols.tsv` at BASE and matches; the
   host files themselves were not read.
8. **Lines 63–64 — `GONE ×2`, `files_ok=2 files_bad=0 symbols_ok=0 symbols_bad=2`.**
   Receipt of an experiment on patched copies ("Verified on patched copies"), not a
   present artifact size.
9. **Lines 70–88 — verdict protocol**: exit codes `1`/`2`, `nlink>1`, `N`/`M`
   placeholders, `#N` count-pin schema. Protocol/schema constants, not counts.
10. **Line 94 — `10 assignments/17 lines/mode 600`; line 145 — `10 assignments`.**
    Host measurement of `op.env`; the host file is absent. Both numbers still match the
    committed pins (`corpus/drift-baseline.tsv:5` = 600/17; `corpus/drift-symbols.tsv:13`
    = `#10`), so the prose is internally consistent, but it is a host fact by subject.
    A prose mutation here would be silent for the same structural reason as Table A2.
11. **Lines 95–96 — `600`, `two count pins`, `644/755`.** Permission modes and a
    word-form count; the modes are schema constants, and the two pins are covered by
    Table A2's `×2`.
12. **Line 110's provenance parenthetical "(round-9 scribe independent check)"** — the
    `0`s themselves are listed in Table A2 with the judgment call stated.
13. **Line 119 — `three REPIN lines`.** The round-9 pin run's output, explicitly dated
    ("the round-9 pin printed three"). Historical receipt.
14. **Line 123 — `#10->#11`.** Hypothetical illustration of a refused count change.
15. **Lines 167–187 — the whole dated `## Reproduction (2026-09-28)` block**: `files=15
    symbols=20`, `PASS (13 cases)`, `→ 2`, fixture constants `755/333/deadbeef/600/17`,
    `files_ok=14 files_bad=1 symbols_ok=20 symbols_bad=0`, `opencode.json:16`,
    `127.0.0.1:8080/34113`. Out by QM26 (dated measurement section). Current values still
    agree (15, 20, 13), so a reader is not misled today; if the selftest grows, this block
    stays a legitimate dated receipt while Table A's undated 13s must move.
16. **Lines 198–199 — exit codes `1`, `2`; line 171 — `2`; line 84 — `2`; line 124
    — `2`.** Protocol exits.
17. **Lines 90, 111, 117, 119, 155, 204, 212, 216 — `round-9`/`round 10`/`round 22`
    tags**, and modes `644/755`/`600` at lines 97, 206, 208. Round tags alone do not
    exempt (QM21), but no number in these clauses states an artifact's present size.
18. **Word-form quantities (cannot be a self-counts integer):** line 104 "the other five"
    (= 6 no-hash − `op.env`, verified 5), line 131 "the two `mv` calls"
    (`corpus/drift-pins.sh:365-366`, verified 2), line 138 "both repo gates"
    (`drift-pins.sh`, `transcript-scan.sh`), line 149 "the two endpoint rows"
    (`the-janitor:19`, `opencode.json:16`, verified 2), line 152 "Two cited paths"
    (both are rows in `corpus/state-shape.tsv:27-38`). Each is correct; none can be
    captured by `([0-9]+)` without a text fix that an L1 must own.
19. **Line 32 `64 hex chars`, line 33 `16-char`, line 117 `sha12`, line 43 `#N`.**
    Hash-format/schema constants, not artifact sizes.
20. **Line 5 `live runs 2026-09-28`, line 9 `R11-04, R11-05`, line 167 date.** Dates and
    row identifiers, not counts.

## Counterexamples and residuals

1. **The draft binds one number and sees one mutation.** Executed in-process over the
   entry text with the rows that target it (`corpus/self-counts.tsv`; the row is identical
   under snapshots `7118d9d0…`, `8e0083f6…` and `67d5d1db…`): the single row
   `KN-DRIFT-BOUND-FILES` matches only line 143 and captures
   `15`. Of thirteen one-digit mutations —
   `451→452`, `15→14` (line 4), `20→19`, `×2→×3`, `9→8`, `6→7` (line 101),
   `0→1` (each zero on line 110), `6→7` (line 143 numerator), `15→14` (line 143
   denominator), `15→16` (line 159), `13→14` (line 189), `13→12` (line 197) — **12 are
   INVISIBLE** (the row keeps matching its own line with unchanged capture) and only the
   line-143 denominator is VISIBLE (`15->14`). Script:
   `.ufo/waves/round-27/sandboxes/KagiR26.KnowDriftGate-17/locator-check.py`.
2. **`rows:` cannot express a subset.** `corpus/self-counts.py:142-148` accepts a `rows:`
   source only with `extract == "-"`, and `:340` computes
   `sum(1 for _line in data_lines(read_text(data_path)))`. Any `rows:` row pointed at
   `drift-baseline.tsv` yields 15 — it can never yield 6 or 9, which is exactly why the
   draft captures the denominator and not the numerator.
3. **The 451 is an anchor, not an observation.** Its only machine source is
   `corpus/stamps.tsv:17`; the file itself is not readable by any allowlisted command
   (`wc` is not in `ALLOWED_COMMANDS`, `corpus/self-counts.py:54`; `bash -c` is refused as
   an inline command, `:171-181`, refusal at `:232`). A binding through the stamps row
   tracks the stamp, not the file. The stamp is compared to the worktree only by
   `claim-ledger.sh verify` → `verify_stamps` (`corpus/claim-ledger.sh:510-537`), which a
   ledger row cannot invoke: self-counts refuses that command
   (`corpus/self-counts.py:267-272`) and claim-ledger refuses a nested `verify`
   (`corpus/claim-ledger.sh:369-376`); the entry itself describes the gate as manual.
   Residual: if the script changes and the stamp is not refreshed, the prose binding stays
   OK while the artifact moved; the binding removes silent prose drift, not silent stamp
   staleness.
4. **The two `0`s are aggregate over two files and one command cannot sum them.**
   `grep -c PATTERN f1 f2` prints two lines; `last_output` takes only the last
   (`corpus/self-counts.py:287-303`), and there is no pipe/`&&` in a ledger argv
   (`shlex.split` at `:256-260`, `subprocess.run(shell=False)` at `:290-293`). A helper script
   (`python3 corpus/<helper>.py`, allowed by `ALLOWED_COMMANDS`) could emit both; that
   costs a new stamped file, a claim row, and — by lane convention — its own selftest
   case count bound in `corpus/self-counts.tsv`. Cheaper: reword the sentence
   categorically ("no `op://` refs or `op.env` key names") and remove the digits.
5. **Every claim row has a census cost.** `R21-04` pins the claim-row count at `^65$`
   (`corpus/claim-ledger.tsv:54`) and is itself the source of three document numbers
   (`corpus/self-counts.tsv:16` SC-SKILL-CLAIMS, `:35` PV-CLAIMS, `:46` RD-LEDGER-ROWS;
   the SKILL prose value at BASE is "89 stamps + 65 claims", `SKILL.md:46`). The id set
   is pinned by `R24-14` (`corpus/claim-ledger.tsv:77`). The four proposed claim rows move
   `65→69`, change `R24-14`'s sha256, and require edits to all three bound document
   numbers. Both `corpus/claim-ledger.tsv` (stamps row `corpus/stamps.tsv:13`) and
   `corpus/self-counts.tsv` (`corpus/stamps.tsv:83`) would also need re-stamping, because
   `verify_stamps` compares sha/lines/bytes for every row. Tier 1 (Table A) avoids all of
   this.
6. **Static-vs-live source for the 13.** `expect:R11-05` would compare the entry's 13 to
   the committed pin string and never execute anything (`corpus/self-counts.py:342-348`);
   a selftest that gains or loses a case would leave the document binding OK forever.
   `ledger:R11-05` re-observes and reports STALE. This is the same distinction the
   release clock's numeric ordering makes: an anchor compared to itself cannot regress.
7. **The numerator is the number a reader would notice.** `**6 of 15**` is one sentence;
   the draft binds `15`. A change that adds a seventh no-hash file turns the sentence
   false while the binder stays green (mutation 9 above), and the "other five" at line 104
   and "the 6" at line 101 go wrong with it.

## Freshness (C2 interaction)

- **No release clock names this entry.** `corpus/release-clocks.tsv` at BASE contains 0
  lines matching `drift-gate`; the entry also carries no `recheck:` line (`grep -E
  'recheck:|on-release'` exit 1). Its numbers are lane-internal, so C2's X.Y.Z ordering
  never observes them and can neither fire nor regress them. Out of C2's reach by
  construction, not by exemption.
- **The entry's only live re-observation in this checkout is the selftest count.** Its
  declared `Reverify: R11-04, R11-05` (`:9`) resolves both ids (`corpus/claim-ledger.tsv:18-19`),
  but `R11-04` is `[substrate]`: it cannot execute here, and `R18-01` (`:48`) pins the
  all-GONE state measured 2026-10-14 (`files_bad=15 symbols_bad=20`). `R11-05` is
  scratch-only and runnable. Binding 13 to `ledger:R11-05` is therefore the one freshness
  lever this entry has; binding it to `expect:R11-05` would be a static anchor (above).
- **Ordering direction.** The size-bearing quantities here are `451`, `13`, `15`, `20`,
  plus the `9`/`6` partition. "Below the anchor" (a shrunk script, a removed selftest
  case, a removed baseline row, a no-hash file that gains a hash) is the change that
  matters; with `rows:`/`ledger:` bindings it prints STALE (exit 1). With the stamps
  anchor for `451`, a file change that leaves the stamp stale prints no finding — the
  residual to declare beside that binding.
- **The entry's own stamp** (`corpus/stamps.tsv:35`: sha `ca3702fc…`, 215 lines, 14000
  bytes) is the revision pin the doc audit requires. Any correction L1 lands on this entry
  must re-stamp it; `verify_stamps` will otherwise print `STALE corpus/knowledge/drift-gate.md`.

## What I did NOT check

- No gate was run: `drift-pins.sh` (verify or `--selftest`), `claim-ledger.sh verify`,
  `self-counts.py`, `release-clock.py`, `c1-measure.py`. "OK" means the entry text agrees
  with the defining source **read** at BASE and, for `R11-05`, with its committed pin plus
  the 13 `run` calls in the script text; it is not an execution receipt. The unrun
  selftest is the one accepted gap behind the `13`.
- No host/private surface was read: no `~/.config`, no `op.env`, no `~/.local/bin/*`, no
  sockets. `op.env`'s 10/17/600 and every host line number are compared only to the
  committed TSVs; the host files are absent (R18-01).
- `PROTOCOL.md` L292–298 was not read (fleet root; the entry's erratum already declares it
  a historical revision locator).
- No other knowledge entry, and no C2/release-clock code, was audited. The proposed ledger
  rows were tested as EREs with `grep` against the current files and as Python extracts on
  the printed row, but not executed through `claim-ledger.sh verify` (that would be a gate
  verification mid-flight). The claim-census arithmetic (`65→69`) follows the pinned rows,
  not an executed ledger.
- `corpus/self-counts.tsv` changed three times while this review ran (52 lines at BASE, then
  75, then 79 at two different digests); any coverage number above is tied to the snapshots
  named in §Snapshot caveat, and the single drift-gate row was re-checked at each.
- Tool installs/upgrades: none.
