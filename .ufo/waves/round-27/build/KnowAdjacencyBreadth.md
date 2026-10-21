# KnowAdjacencyBreadth — C1 inventory: `corpus/knowledge/adjacency-breadth.md`

Target at BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`: blob
`e9384cca8907a95e12e22f24ac6201207f466593`, 161 lines, `git diff --quiet` clean
(working tree identical to BASE; no round-27 migration touched this entry —
`knowledge-migrations.json` contains no `breadth` record).

Rules applied: `corpus/QUALITY.md:118` (QM21), `corpus/QUALITY.md:133` (QM26),
`corpus/lessons/round-25.md:49-58` (R25-C6). A number is current when it states
an artifact's present size and no newer value sits in the same clause; dated
measurement sections, history clauses, host observations and positional indexes
are out. Sources per `corpus/self-counts.tsv:11-13`: `rows:<file>` counts
non-comment data lines, `ledger:<ID>` runs a non-host row's own command,
`expect:<ID>` reads the committed pin and runs nothing.

Method: every candidate locator below was compiled and matched against all 161
lines (exactly one matching line, exactly one capture group, captured value
compared with the committed source). No gate, selftest, falsify run, binder or
ledger row was executed; values are file counts and committed pins.

## 1. Bindable current-tense numbers (digit form)

| line | exact text | proposed id | source | pinned/live value | status | locator (one group) |
|---:|---|---|---|---|---|---|
| 5 | `(the 35-row declared universe)` | `KN-BREADTH-CENSUS-ROWS` | `rows:corpus/surface-census.tsv` | 35 — file has 35 non-comment data lines | **OK** | `^\(the ([0-9]+)-row declared universe\)` |
| 148 | `# 4 ADJACENCY_BREADTH lines;` | `KN-BREADTH-OUTPUT-LINES` | `ledger:R17-02` (`grep -cE '^# breadth…'`, expectation `^4$`) | 4 — ledger pin; file independently has 4 `# breadth` rows (`corpus/adjacency.tsv:75-78`) | **OK** | `^# ([0-9]+) ADJACENCY_BREADTH lines` |
| 152 | `# SCOPE_SELFTEST: PASS (61 cases)` | `KN-BREADTH-SCOPE-SELFTEST` — already bound, `corpus/self-counts.tsv:58` | `ledger:R16-02` (expectation `^SCOPE_SELFTEST: PASS \(61 cases\)$`) | 61 | **OK** | `^# SCOPE_SELFTEST: PASS \(([0-9]+) cases\)` |
| 155 | `# SCOPE_FALSIFY: PASS (caught=18/18 failed=0)` | `KN-BREADTH-FALSIFY` — already bound, `corpus/self-counts.tsv:59` | `expect:R16-03` (`corpus/claim-ledger.tsv:41`, pin `caught=18/18`) | 18 | **OK** | `^# SCOPE_FALSIFY: PASS \(caught=([0-9]+)/` |
| 158 | `The 18 falsifiers are the round-16 nine plus nine breadth mutations` | `KN-BREADTH-FALSIFY-COUNT` — **unbound** | `expect:R16-03` (`corpus/claim-ledger.tsv:41`) | 18 | **OK** | `^The ([0-9]+) falsifiers are` |

No current digit-form number in this entry is STALE at BASE. The entry is
under-bound, not wrong: 3 of its 5 current digit counts (lines 5, 148, 158) are
outside the working binding table, which locates only lines 152 and 155.

## 2. Current-tense counts spelled as words (cannot be bound as written)

`corpus/self-counts.py` (`integer()`, and `capture_regex()` requiring exactly
one group) accepts only a digit capture, so a spelled count has no valid
locator without a prose edit. These are current-tense, lane-artifact counts:

| line | exact text | value at BASE | would-be source | disposition |
|---:|---|---:|---|---|
| 69 | `That rule derives the four rows above.` | 4 | `expect:R17-01`, extract `required=([0-9]+)` → 4 (`corpus/claim-ledger.tsv:45`) | needs `four`→`4`, then bindable |
| 81 | `derived from the eight no-enumerate and four scan rows` | 8 | `ledger:R17-03` (expectation `^8$`, `corpus/claim-ledger.tsv:47`) | needs `eight`→`8`, then bindable |
| 81 | same line: `four scan rows` | 4 (4 `# scan` directives, `corpus/surface-census.tsv:17-20`) | **none**: `rows:` skips `#` comment lines and no ledger row counts scan directives | out of population unless a non-host row is opened (`grep -cE '^# scan[[:space:]]+.HOME/' corpus/surface-census.tsv` → 4) |
| 71 | `Four aggregate ancestors are intentionally exempt:` | 4 | **none**: the gate emits `breadth_required`/`breadth_pins`, never an exempt count | out of population |
| 135 | `The four exempt ancestors` | 4 | **none**, as line 71 | out of population |

Line 6's `four required leaf directories` is spelled *and* inside the dated
observation sentence; it is excluded in §3, not admitted here.

## 3. Excluded numbers, by class

- **Dated host observation** — `Source basis: … read-only against the live host
  on 2026-09-29` (lines 5-7): `four required leaf directories`, `182 direct
  children`, `8 census-declared child buckets`, `174 undeclared children`. The
  per-directory table (lines 20-24: 20/4/16, 105/2/103, 4/1/3, 53/1/52, totals
  182/8/174) and line 121 (`The 174 children`) repeat them. Even `8 declared`
  is host-observed: `declared` compares live child names against census rows.
  Arithmetic is internally consistent (20+105+4+53=182; 4+2+1+1=8;
  16+103+3+52=174; 182−8=174) but I did not measure any root, so these are
  unverified by me. `corpus/lessons/round-27.md` names "breadth children" as
  excluded host observation.
- **History**: line 26-27 `was 0` ("Before round 17"); line 15 `The four shared
  directory roots` and line 28 `the four ratios` (Round-16/pre-round-17
  narrative); line 158 `the round-16 nine plus nine breadth mutations`
  (round-labelled decomposition, not a present size).
- **Live output samples** (host-run lines, not size claims): line 105
  `BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 …)`,
  line 106 `ADJACENCY_SCOPE: CLEAN (… breadth_required=4 breadth_pins=4 …)`,
  lines 144-145. Line 105 is textually identical to R17-01's committed
  expectation (`corpus/claim-ledger.tsv:45`, field 3) apart from regex
  escaping/anchors; its `children`/`undeclared` fields are host measurements.
  The structural 4s are data-derived but are one line of a host sample; if L1
  admits this class, `expect:R17-01` field extracts would bind them.
- **Grammar/spec constants, not artifact sizes**: line 34 and line 89
  `four-field`; line 42 `mindepth=1,maxdepth=1`; line 48
  `0..2147483647`; lines 97-98 `exit 1`/`exit 2`/`exit 0`; line 109
  `one count-only … line per required directory` (idiom).
- **Identifiers, versions, ordinals**: `R10`, `R12a`-`R12d`, `R13a`-`R13c`,
  `R6`, `R17-01`…`R16-03` (lines 10, 88-95, 111, 132, 158-160); `v2, round 17`
  (line 3); `Round 16`/`round 17` (lines 3, 14, 26); bounds-list ordinals 1-9
  (lines 116-137).

## 4. Counterexamples and gaps

1. **Unbound current digits.** No row in the working table locates lines 5, 148
   or 158 (the only `KN-BREADTH-*` rows match 152 and 155,
   `corpus/self-counts.tsv:58-59`). Since the binder reports `STALE` only for
   locator-matched claims (`corpus/self-counts.py:326-357`), a one-digit edit
   `35`→`36` (line 5), `4`→`5` (line 148), or `18`→`19` (line 158) is
   unobserved. [INFERENCE from the binding table and `check()`; I did not run
   `c1-measure.py --mutate` — L1's red control.]
2. **`18/18` is only half-bound.** The existing locator captures the first 18;
   the second 18 and `failed=0` on line 155 are unbound, so a mutation of the
   total (`18/18`→`18/17`) would not turn the binder STALE. An optional second
   row is given in §5.
3. **Prose unit ≠ program unit.** Line 109 says one `ADJACENCY_BREADTH` line
   "per required directory", but `corpus/scope-gate.sh:527-528` iterates
   `breadth_pins` and `:603-605` prints inside that loop. At CLEAN
   pins=required=4, so the digit is right today; in a missing-pin state the gate
   prints 3 lines while `required=4`. Binding line 148 to `ledger:R17-02`
   (pins) is code-faithful; binding to R17-01 `required=4` would encode the
   prose's unit, not the program's. The sentence itself should probably say
   "per pin".
4. **Line 5's `35` sits in the dated Source-basis paragraph.** I admit it
   because it counts a committed lane file (`corpus/surface-census.tsv`), not
   the host, and the same quantity is already bound for `corpus/README.md`
   (`RD-CENSUS-ROWS`, `corpus/self-counts.tsv:42`). If L1 reads the whole
   paragraph as a dated measurement section, drop the row; the value is still
   35 at BASE (R16-01 also pins `census=35`).
5. **Decomposition is unguarded.** Binding line 158's 18 leaves "the round-16
   nine plus nine" unguarded; an added falsifier must update both the bound 18
   and the two nines, and no source counts the breadth subset.

## 5. Proposed rows (TSV, paste-ready for L1)

```
KN-BREADTH-CENSUS-ROWS	corpus/knowledge/adjacency-breadth.md	^\(the ([0-9]+)-row declared universe\)	rows:corpus/surface-census.tsv	-	Source basis: declared census rows (35 at BASE)
KN-BREADTH-OUTPUT-LINES	corpus/knowledge/adjacency-breadth.md	^# ([0-9]+) ADJACENCY_BREADTH lines	ledger:R17-02	^([0-9]+)$	--breadth prints one line per breadth pin (scope-gate.sh:527-528,603-605)
KN-BREADTH-FALSIFY-COUNT	corpus/knowledge/adjacency-breadth.md	^The ([0-9]+) falsifiers are	expect:R16-03	caught=([0-9]+)/	prose total; "nine plus nine" decomposition unguarded
```

Optional, only if the reviewer admits the class or normalizes the prose:

```
# after "eight" -> "8" on line 81:
KN-BREADTH-NOENUM	corpus/knowledge/adjacency-breadth.md	^`BREADTH-MISSING` is derived from the ([0-9]+) no-enumerate	ledger:R17-03	^([0-9]+)$	same 8 as R17-03 (8 at BASE)
# second 18 of 18/18 (redundant cardinality, closes mutation gap 2):
KN-BREADTH-FALSIFY-TOTAL	corpus/knowledge/adjacency-breadth.md	^# SCOPE_FALSIFY: PASS \(caught=[0-9]+/([0-9]+) failed=0\)	expect:R16-03	caught=[0-9]+/([0-9]+)	second 18 of 18/18
```

All five primary locators were checked: one group each, exactly one matching
line each (5, 148, 152, 155, 158). Mutating the first digit of a captured value
(`c1-measure.py --mutate`) must yield exactly one STALE id per row.

## 6. What I did NOT check

- Did not execute `corpus/scope-gate.sh` in any mode, `corpus/self-counts.py`,
  `corpus/claim-ledger.sh`, or any ledger row; 61, 18, 4 and 8 are committed
  pins/expectations, not re-executed verdicts. `scope-gate.sh` and
  `claim-ledger.tsv` are unmodified in the working tree, so the pins should
  still hold, but that is not an executed check.
- Did not enumerate `$HOME` or any breadth root; 182/8/174, the per-directory
  cells and the aggregate 94/2, 15/2, 48/1, 2/1 are unverified and out of
  population by rule.
- Did not run `c1-measure.py` or the BASE/after overlay counting command; the
  stale-N/exit counts remain L1's to execute.
- Did not audit the other 24 knowledge entries or the sibling `KN-*` rows.
- No production file was modified and no tool was installed.
