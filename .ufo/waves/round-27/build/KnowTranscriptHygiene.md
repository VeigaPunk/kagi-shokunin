# KnowTranscriptHygiene — C1 inventory: `corpus/knowledge/transcript-hygiene.md`

Target at BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`: blob
`4e041fd895b9c1d64c447d14cf66acb0beb74aad2a57bcdf2c4cc60228af7f12`
(166 lines, 9905 bytes; `git show BASE:…` hash equals the working tree, and
`corpus/stamps.tsv:50` carries the same hash). Its defining artifact
`corpus/transcript-scan.sh` is also BASE-identical:
`2d60981b198cef41b9263a1427b41f92d98b65eb26ff71c28057bea0ad823a23`
(282 lines, 14709 bytes; `corpus/stamps.tsv:90`). Round-27 edits already in the
working tree touch `corpus/self-counts.tsv` (56 rows, was 38 at BASE;
stamp `corpus/stamps.tsv:84` matches), `corpus/claim-ledger.tsv` (83 lines /
65 claim rows; stamp `:13` matches) and four `knowledge/*.md` entries — not this
entry and not the script.

Rules applied: `corpus/QUALITY.md:118` (QM21), `corpus/QUALITY.md:133` (QM26),
`corpus/lessons/round-25.md:49-58` (R25-C6). A number is current when it states
an artifact's present size and no newer value sits in the same clause; an
explicit history clause, a dated measurement section and host/substrate
observations are out. Source kinds per `corpus/self-counts.tsv:11-13`:
`rows:<file>` counts non-comment data lines, `ledger:<ID>` executes a non-host
row's own command, `expect:<ID>` reads a committed pin and executes nothing.

Method: read-only. Every proposed locator was compiled and matched against all
166 entry lines (exactly one matching line, exactly one capture group); the
script's arrays were parsed statically to obtain the live values. No gate,
selftest, falsifier, binder, ledger row or host DB read was executed.

## 1. Population judgement

Three readings decide the population; all are recorded so a non-author can
dispute them:

1. **Lines 28/34 sit under `## Schema facts the scan encodes (verified
   2026-09-28)`.** They count the shipped script's `SCAN_COLS` map and the
   derived cell surface, not the host DB. The entry's own Erratum scopes its
   historical marker to "all live database row counts, findings and WARN
   figures" (lines 153-158) — cells, tables and patterns are not in that list,
   and the erratum separately says the *shipped array inventory* is the
   authoritative one (line 155-156). Admitted as current; if L1 reads the
   whole dated section as a measurement, drop these two rows and name the
   exclusion (see §6.7).
2. **Line 123's `32`** is present tense ("the shipped revision carries 32").
   The later "round-9 run" dates the run that observed old rows, not the array
   membership; QM21 says a round tag alone does not make a number historical.
   Admitted.
3. **Line 93's `32`** is the classify key-run bound. The `--classify` bullet is
   tagged "(round 9)", but the number describes the shipped mode's current
   constant (`transcript-scan.sh:126`). Admitted (a bound, which C1 names
   explicitly).

No current number in this entry is STALE at BASE. The defect is coverage: all
four are correct and none is bound, so a one-digit edit is invisible.

## 2. Current-tense numbers (in population)

| line | exact text | defining live source | live value at BASE | status | proposed id | locator (one group) | extract |
|---:|---|---|---:|---|---|---|---|
| 28 | ``Text-bearing columns scanned (`SCAN_COLS` map, 11 tables): `part.data`,` `` | **none at BASE** — code `corpus/transcript-scan.sh:53-63` (11 `SCAN_COLS[...]` assignments) | 11 | **OK / UNBOUND** | `KN-HYGIENE-TABLES` | ``^Text-bearing columns scanned \(`SCAN_COLS` map, ([0-9]+) tables\):`` | `tables=([0-9]+)` |
| 34 | `group is what makes the shipped revision 888 cells rather than round-8's 270).` | **none at BASE** — code `corpus/transcript-scan.sh:53-63` (columns) × `:83-96` (patterns), counted at `:143-157` | 888 (24 columns × 37 patterns) | **OK / UNBOUND** | `KN-HYGIENE-CELLS` | `what makes the shipped revision ([0-9]+) cells` | `cells_full=([0-9]+)` |
| 93 | ``  fires it prints `rows`, `key_shaped` (the 32 characters after the literal`` | **none at BASE** — code `corpus/transcript-scan.sh:126` (`substr($c, instr($c,'$p') + length('$p'), 32)`) | 32 | **OK / UNBOUND** | `KN-HYGIENE-KEYRUN` | `the ([0-9]+) characters after the literal` | `key_run=([0-9]+)` |
| 123 | `  patterns; the shipped revision carries 32, so the round-9 run flagged rows` | **none at BASE** — code `corpus/transcript-scan.sh:83-95` (`PATTERNS_HIT`, 32 single-quoted tokens) | 32 | **OK / UNBOUND** | `KN-HYGIENE-PATTERNS` | `the shipped revision carries ([0-9]+), so the round-9 run` | `hit=([0-9]+)` |

Static parse backing the values (BASE blobs): 11 tables (`part message event
session session_input session_message session_context_epoch todo project
workspace permission`); 24 text columns (1+1+1+7+1+1+2+1+4+3+2); 32 HIT
tokens and 5 WARN tokens; 24 × (32+5) = 888; the classify SQL literal is 32.
All four locators were checked: one group each, exactly one matching line each
(28, 34, 93, 123).

## 3. Why no existing binding exists

- `rows:` cannot express these: `corpus/self-counts.py:340` counts non-comment
  *data lines* of a data file, and the source is executable shell whose pattern
  array packs several tokens per line.
- `R11-06` (`corpus/claim-ledger.tsv:20`) is the only row that runs the gate,
  but its note carries `[substrate]`, so `self-counts.py:260` refuses
  `ledger:R11-06`. Its committed pin is
  `^TRANSCRIPT_SCAN: HITS=2 \(cells=[1-9][0-9]*` — no numeric literal for
  `cells`, no capture group, and no `patterns=` segment. `expect:R11-06` would
  have to match an extract against that pin (`self-counts.py:344-346`) and can
  yield none of 11/888/32.
- `R11-07` (`corpus/claim-ledger.tsv:21`) is host-free and executable, but its
  pin is `^SELFTEST OK` and the script's summary line
  (`corpus/transcript-scan.sh:256`) prints no number.
- **Zero of the 56 working-table locators match any of the 166 entry lines**
  (compiled and scanned). `corpus/self-counts.py:357-359` turns a claim STALE
  only when its locator matched, so all four numbers are mutation-invisible.

## 4. Proposed bindings (for L1; nothing here is executed)

### Route A — cheapest: reuse R11-07's host-free selftest (recommended)

Extend the existing `--selftest` summary (line 256) with values derived from
the gate's own arrays, so the numbers have one definition. Introduce
`KEY_RUN=32` beside the arrays and use it at line 126 instead of the literal,
then before the final `echo`:

```sh
cols=0
for t in "${!SCAN_COLS[@]}"; do for c in ${SCAN_COLS[$t]}; do cols=$((cols+1)); done; done
echo "SELFTEST OK (seeded hit + wal-resident hit detected; clean db passed; tables=${#SCAN_COLS[@]} columns=$cols hit=${#PATTERNS_HIT[@]} warn=${#PATTERNS_WARN[@]} key_run=$KEY_RUN cells_full=$((cols * (${#PATTERNS_HIT[@]} + ${#PATTERNS_WARN[@]}))))"
```

`R11-07`'s pin `^SELFTEST OK` still matches (claim-ledger uses
`[[ $last =~ $expect ]]`, `corpus/claim-ledger.sh:616-621`, unanchored at the
end). Paste-ready rows:

```
KN-HYGIENE-TABLES	corpus/knowledge/transcript-hygiene.md	^Text-bearing columns scanned \(`SCAN_COLS` map, ([0-9]+) tables\):	ledger:R11-07	tables=([0-9]+)	SCAN_COLS table membership (11 at BASE)
KN-HYGIENE-CELLS	corpus/knowledge/transcript-hygiene.md	what makes the shipped revision ([0-9]+) cells	ledger:R11-07	cells_full=([0-9]+)	full-schema cells = columns x (hit+warn) (888 at BASE)
KN-HYGIENE-KEYRUN	corpus/knowledge/transcript-hygiene.md	the ([0-9]+) characters after the literal	ledger:R11-07	key_run=([0-9]+)	classify key-shaped run length (32 at BASE)
KN-HYGIENE-PATTERNS	corpus/knowledge/transcript-hygiene.md	the shipped revision carries ([0-9]+), so the round-9 run	ledger:R11-07	hit=([0-9]+)	PATTERNS_HIT token count (32 at BASE)
```

Expected binder lines once the script edit lands (not observed):
`OK KN-HYGIENE-TABLES …:28 claimed=11 live=11`, `…CELLS …:34 claimed=888
live=888`, `…KEYRUN …:93 claimed=32 live=32`, `…PATTERNS …:123 claimed=32
live=32`. At BASE, pasting these rows before the script edit yields
`SETUP … extract did not match ledger:R11-07 last line`
(`corpus/self-counts.py:354`).

Bookkeeping this route moves: restamp `corpus/transcript-scan.sh`
(`corpus/stamps.tsv:90`; same path, so `R12-03` stays 90 and `R24-05`'s path
digest is unchanged); `self-counts.tsv` 56 → 60 claims, so `R25-02`'s pin
`^SELF_COUNTS: CLEAN \(claims=56 stale=0\)$`
(`corpus/claim-ledger.tsv:81`) must move to 60 with an old/new note (QM14).
No change to `R21-04` (65), `R11-09` (170), `SKILL.md:46`/`PROVINCE.md:52`/
`corpus/README.md:64`.

Two caveats. (1) `--selftest` exits 2 if sqlite3 is absent
(`corpus/transcript-scan.sh:185`), so this makes the binder depend on sqlite3;
that fails closed as `SETUP`, not as a false CLEAN (QM19). (2) At BASE the
summary already overclaims: when python3 is absent the wal-resident case prints
`skipped` (line 254) and the final line still says "wal-resident hit detected"
(line 256) without a skip count — a QM3/QM4 defect on the very line being
extended. If L1 edits it, add `skipped=0|1` and count the skip.

### Route B — cleaner source, larger ripple (only if L1 wants a dedicated mode)

Add `--surface` to `transcript-scan.sh`, exiting before the sqlite3/DB checks,
printing e.g. `TRANSCRIPT_SURFACE: tables=11 columns=24 hit=32 warn=5
key_run=32 cells_full=888 sha256=<64hex>`; open a new non-host row `R27-01`
(first free id; no `^R27-` rows exist) with that pin. Because
`corpus/transcript-scan.sh` is in `HOST_SCRIPT_RE`
(`corpus/claim-ledger.sh:189`) and only `--selftest` is declared host-free
(`:190-193`), the new argument must be added to `host_free_args` **and** proven
by a claim-ledger selftest case (QM9/QM20) — moving `R11-09` 170 → 171 and the
three bound 170s. The new row also moves `R21-04` 65 → 66 and
`SKILL.md:46`/`PROVINCE.md:52`/`corpus/README.md:64`, plus `R24-14`'s
count/digest and `R25-02`. The digest is the only way to satisfy QM18
(count-preserving pattern swap), but a digest only guards the *ledger* pin;
the entry states counts, which stay true under a swap.

Recommendation: Route A. Route B is semantically tidier but touches the
host-free declaration (a security allowlist) and three more bound documents for
four counts.

## 5. Excluded numbers, by class

- **Dated measurement (2026-09-28)** — line 57 `4 WARN cells spanning 5
  distinct sessions`; lines 64-65 `0 HIT, 4 WARN, all 5 tripwires empty, 270
  cells × 30 patterns` (explicitly "an earlier revision … treat it as
  historical"); lines 70-71 `HITS=2, warns=2, 888 cells × 32+5 patterns, all 5
  tripwires empty` ("Baseline (round 9 … re-verified 2026-09-28)"). Also the
  `0600` mode observations (lines 4, 44) and line 41 `all empty` are host
  observations, not lane-artifact sizes.
- **Host DB row census** — line 125 `7 sessions / 39 messages / 55 parts / 238
  events` and line 135 `session 7 / message 39 / part 55 / event 238 / project
  1` ("the 2026-09-28 census, not invariants"). Line 125 sits inside a bounds
  bullet but is the same host census; line 135 is explicitly dated.
- **History clauses** — line 34 `round-8's 270` (older value, newer 888 beside
  it); line 122 `Round 8 measured 25 HIT patterns`; line 73 `5-character
  lowercase word` and line 75 `rows=1 key_shaped=0 prose=1` (round-9 triage
  sample); line 77 `rows=7` (round-9 defect narrative).
- **Semantics / identifiers** — exit codes 0/1/2 (lines 103-105, 142), `HITS=n`
  placeholder (142), ad-hoc query expected `0`s (146-147), `R11-06`/`R11-07`
  (12), round labels (7, 8, 9, 22) and all dates. Line 47 `Two-tier` is a
  spelled count, not a numeral, and has no lane-local pinned source; excluded
  as prose taxonomy (a reviewer could argue it, but there is nothing to bind
  without rewriting it to `2`).
- **Memberships without a numeral** — lines 39-45 list the five tripwire
  tables and lines 49-54 the pattern prose set; the erratum (155-156) declares
  the latter illustrative (it enumerates 25 HIT tokens, not the array's 32), so
  neither is a bindable count as written.

- **Selftest mentions without a count** — lines 89, 100-102 and 144 describe
  `--selftest` behaviour but state no case number, and the script's summary
  (`corpus/transcript-scan.sh:256`) prints none at BASE; there is no selftest
  case count in this entry to bind.

A mutation of an excluded duplicate is not detected: lines 65/71 carry
`270`/`30` and `888`/`32+5` a second time; only 28/34/93/123 would be bound.

## 6. Counterexamples and gaps

1. **Mutation-invisible at BASE.** No locator matches lines 28, 34, 93, 123;
   `check()` marks STALE only for matched claims (`corpus/self-counts.py:326-
   359`). A one-digit edit on any of the four passes every gate.
2. **The entry's declared reverify is blind to exactly these numbers.** Line 12
   says `Reverify: R11-06, R11-07`. R11-06's pin is
   `^TRANSCRIPT_SCAN: HITS=2 \(cells=[1-9][0-9]*` — a prefix ERE
   (`corpus/claim-ledger.sh:621`) that accepts any positive `cells` and never
   constrains `patterns=`. If the array grows, a consented run prints
   `cells=912 patterns=33+5` and still passes; R11-07's pin has no number at
   all. The reverify line therefore cannot notice a scan-surface change even
   when it is run.
3. **Line 34's causal claim is false (the number is right).** With the entry's
   own figures: `270 = 9 columns × 30 patterns`. The "last group"
   (`project` 4 + `workspace` 3 + `permission` 2) is 9 columns; adding it to
   round 8's 9 gives 18 columns, and even at the shipped 37 patterns that is
   `18 × 37 = 666`, not 888. 888 requires `888 / 37 = 24` columns, i.e. six
   further columns beyond the group. The Erratum does say "baseline changes
   included both column and pattern changes, not columns alone" (lines
   156-157), but line 34 is left standing and contradicts it. QM26 binds
   numbers, not causal prose — L1's call whether to correct the clause
   (requires restamping the entry) or accept the erratum as the correction.
4. **Silent-drift arithmetic.** One added HIT pattern: `hit=33`, 24 × 38 =
   912 (lines 34 and 123 false); one added WARN: 38 patterns, 912; one
   single-column table: 25 columns, 925 (line 28 and 34 false); `KEY_RUN`
   32 → 40: line 93 false. None is caught at BASE.
5. **Count-preserving swap is invisible and stays true.** Replacing one
   pattern with another keeps `32` and `888` correct; the entry claims counts,
   not membership, so no doc number is falsified. Route A's binding is
   therefore sufficient for QM21 but not an identity pin (QM18); Route B's
   digest would guard the ledger row only.
6. **Adjacent unbound duplicates (outside this entry, named not absorbed).**
   `corpus/README.md:54` states the same `888 cells × 32+5 patterns` for
   `transcript-scan.sh` and no `RD-*` locator covers it. Worse, the round's own
   `corpus/README.md:219` says "`corpus/self-counts.tsv` now also binds 18
   reviewed current-tense numbers in seven `knowledge/*.md` entries" — a
   current-tense count about the binder with **no** locator; if Route A lands
   it must become 22/eight (or carry a history clause), and
   `corpus/lessons/round-27.md:23` says "18 bindings over 7 entries" as well.
   These are the same class of defect QM26 targets, one file over.
7. **Population dispute, recorded.** If the dated heading at line 26 is read as
   a "dated measurement section", drop `KN-HYGIENE-TABLES` and
   `KN-HYGIENE-CELLS`; the values are still 11/888 at BASE, but the entry is
   then bound only at lines 93/123. I admit them because the erratum's
   historical scope does not name scan-surface structure and the erratum treats
   the shipped array as authoritative.

## 7. What I did NOT check

- Did not run `corpus/self-counts.py`, `corpus/claim-ledger.sh`,
  `corpus/transcript-scan.sh` (any mode), or any ledger row; 11/888/32/32 are
  static parses of the BASE script, not executed verdicts. The four proposed
  rows are therefore **unverified by execution**; specifically I did not prove
  Route A's policy pass or the binder's `extract` match against a live selftest
  output — both are [INFERENCE].
- Did not read the host transcript DB, run `sqlite3`, or re-measure R11-06's
  2026-09-28 baseline (`HITS=2`, `cells=888`); no vault/account/handler/CDP
  contact.
- Did not verify round 8's actual column set beyond the entry's own
  `270 × 30` arithmetic; which six non-group columns were added is [INFERENCE]
  from the current map (`session.permission`, `session_input.prompt`,
  `session_message.data`, `session_context_epoch` ×2, `todo.content`).
- Did not run `c1-measure.py`, the BASE/after overlay, or any mutation; the
  stale-N/exit-count control remains L1's.
- Did not audit the other knowledge entries, `corpus/README.md:54`/`:219`
  bindings, or C2/release-clock.
- No production file was modified and no tool was installed.
