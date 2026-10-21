# KnowOpCliSurface — C1 inventory of `corpus/knowledge/op-cli-surface.md`

Seat: `KagiR26.KnowOpCliSurface-17` (leaf; no dispatch). Frozen BASE:
`0a47dd189356ea66ec83c3891eed54526e95b89b` (`git rev-parse HEAD` in the lane
returned this revision). Target: `corpus/knowledge/op-cli-surface.md`, 129
lines, sha256 `9525c55ab67beda18b2fe56b8c9d0b05f4810a102a8802781c61f3601098ca87`;
identical at BASE and in the working tree (`git status --porcelain --
corpus/knowledge/op-cli-surface.md` is empty and
`git show BASE:corpus/knowledge/op-cli-surface.md | sha256sum` matches). No
production writes.

Working-tree caveat: `corpus/self-counts.tsv`, `corpus/claim-ledger.tsv` and
other corpus files are modified by the in-flight L1 integration
(`git status --porcelain -- corpus`). All table/ledger counts below are
labelled BASE or working tree; the target entry itself is unmodified. For the
four ledger rows cited (`R11-02`, `R11-03`, `R12-01`, `R12-02`) the BASE and
working rows are at the same lines and carry the same fields (checked with
`git show BASE:corpus/claim-ledger.tsv | grep -n`).

## 0. Rule and method

- QM21 (`corpus/QUALITY.md`), QM26 (same file, round-27 row), R25-C6
  (`corpus/lessons/round-25.md`): a number is current when it states an
  artifact's present size and no newer value sits in the same clause. A dated
  measurement section, an Erratum/Evidence history, a positional case index
  and a bare round tag used as a section label do not make a number historical
  by themselves; only an explicit history clause does. In this entry the
  Source line (line 3) and the table header (line 13) date the observations to
  2026-09-28, and the trailing Erratum (lines 119-129) explicitly declares the
  CLI version, host authorization states, caller/handler comparisons and
  timing observations "dated measurements" and records the handler as
  unavailable under the round-18 substrate deferral.
- Allowed sources are exactly `rows:<repo file>` (nonblank, non-comment line
  count; `corpus/self-counts.py:340`), `ledger:<ID>` (executes a NON-host row;
  `[host]`/`[substrate]` rows are refused at `corpus/self-counts.py:260`), and
  `expect:<ID>` (searches the committed pin text, never executes;
  `corpus/self-counts.py:344`).
- Population at BASE: `corpus/self-counts.tsv` has 38 data rows and **0** rows
  whose doc is under `corpus/knowledge/` (`git show BASE:corpus/self-counts.tsv`
  counted with the table's own data-line rule). The working tree has 56 rows
  (38 + 18 `KN-*`), 18 with a knowledge doc, and still **0** naming
  `op-cli-surface.md`. The round-27 instrument's knowledge population is
  `rows` whose doc starts with `corpus/knowledge/`
  (`.ufo/waves/round-27/tools/c1-measure.py:45-46`), and its mutation control
  requires an existing row id (`next(r for r in rows if r[0] == mutate)`,
  `c1-measure.py:51`), so this document has no id the mutator can target.
- Completeness scope: this entry only. Every line carrying a digit or a number
  word was enumerated mechanically: **56 of 129** lines; 3 are current-tense
  lane-artifact cardinals (section 3), 53 are excluded by class (section 4).
  No claim of a complete digit census over `corpus/knowledge/*.md`.

## 1. Verdict

- In-population current-tense numbers with a `rows:`/`ledger:`/`expect:`
  source: **0**.
- In-population numbers STALE: **0**.
- Current-tense lane-artifact cardinal claims with **no** lane-local machine
  source: **3** (lines 52, 57, 113). Each currently reads 2 and is true by
  named membership; each is **UNBOUND**, not STALE. They are listed as
  out-of-population per the ticket's instruction for numbers with no
  lane-local source.
- The entry is outside the binder's red control: a one-word edit on any of the
  three (`two`→`three`, `both`→`three`, `pair`→`triple`) cannot turn any
  self-counts id STALE, because no row names this document at BASE or after.
  This is the same class as M27-2, in an entry the round-27 C1 population did
  not include.

## 2. In-population bindings (self-counts.tsv format)

```text
id	doc	locator	source	extract	note
# (0 rows) — no current-tense number in this entry has a rows:/ledger:/expect: source at BASE.
```

A valid row would need (a) a doc line whose cardinal is written as a digit (the
binder extracts a nonnegative integer, `corpus/self-counts.tsv:2`), (b) a
`rows:` file whose non-comment data-line count equals that cardinal, or a
`ledger:`/`expect:` pin whose text literally contains it, and (c) a locator
that matches exactly one doc line with exactly one capture group. Sections 3
and 4 show why none of the entry's cardinals satisfies all three today.

## 3. Current-tense lane-artifact cardinals with no bindable source

Exact text (BASE line numbers; line 52 is inside the sentence that starts at
line 50, line 113 continues on line 114):

```text
50-53: So the defensible claim is "keys and ref-shaped values are echoed; other values
       are replaced by `<redacted-non-op-value>`" — **not** "`refs` output is safe to
       paste". `bash corpus/surface-census.sh --verbs` pins both behaviours
       (`refs-shape-table`, `refs-redaction-prefix-only`).
57:    `cmd_serve` offers exactly two auth paths (credential-isolation.md §1):
113:   the argument guards; `--deep` covers the `op run` pair and the
```

| id | line | quantity | live membership observed at BASE | why there is no `rows:`/`ledger:`/`expect:` source | verdict |
|---|---|---|---|---|---|
| C1 | 52 | 2 pinned census behaviours | `corpus/surface-census.sh:536` `probe_open refs-shape-table`; `:569` `probe_open refs-redaction-prefix-only`; both are before the `--deep` gate at `:585`, so they are in the default `--verbs` set | `rows:corpus/surface-census.tsv` counts **35** data lines, not 2 (the TSV declares host surfaces, not verb cases; `grep -c 'refs'` on it is 0). `ledger:R11-02` is refused because the row is `[substrate]` (`self-counts.py:260`). `expect:R11-02` searches the pin text `^SURFACE_CENSUS_VERBS: CLEAN \(pass=[1-9][0-9]* skip=[0-9]+\)` (`self-counts.py:344`), which contains no literal 2; `re.search(r'pass=([0-9]+)', pin)` is `None` | OK (membership); UNBOUND |
| C2 | 57 | 2 auth paths | `corpus/knowledge/credential-isolation.md:11-16` lists exactly two branches: `OP_SERVICE_ACCOUNT_TOKEN` used as-is, otherwise `op signin --raw` → `OP_SESSION_<domain>` → verified by `op whoami`; the rest of §1 contains no third auth branch (`grep` on that entry for `OP_SESSION`, `SERVICE_ACCOUNT`, `signin`, `auth`) | `rows:corpus/knowledge/credential-isolation.md` counts **54** data lines, not 2; the file is prose, not a data table. No ledger row mentions `credential-isolation` (grep count 0). The code the sentence describes is absent: `~/.local/bin/the-janitor` does not exist (`ls` → `No such file or directory`), so the two-path shape cannot be measured live | OK against the cited doc; code UNVERIFIED; UNBOUND |
| C3 | 113 | 2 deep `op run` probes | `corpus/surface-census.sh:584` `probe_open run-plain-env`; `:604` `probe_open run-ref-signed-out`; both are `--deep`-gated (`:585-586`, `:605-606`) | No `rows:` source lists probe cases (`surface-census.tsv` has 0 verb/refs rows); `expect:R11-02`'s pin is the same regex with no literal 2; `ledger:R11-02` is refused as `[substrate]`; `R11-03`'s pin is `16 cases`, not the deep pair | OK (membership); UNBOUND |

The word "OK" above means the named members still exist at BASE; it is not a
self-counts PASS and does not re-verify runtime behaviour (the handler is
absent).

### 3.1 Locator traps (why a mechanically valid row would bind the wrong quantity)

Line 57 is the only one of the three with any digit, and it is the section
number, not the count:

```python
re.compile(r'^`cmd_serve` offers exactly two auth paths \(credential-isolation\.md §([0-9]+)\):$')
# exactly one match: line 57; group(1) == "1" (the § number), while the
# unhooked cardinal is the word "two".
```

Lines 52 and 113 contain no digit at all, so any `([0-9]+)` locator would have
to capture a neighbouring line's number — it cannot be a binding for these
cardinals. The failed `expect:` extraction is reproducible without running the
gate:

```python
import re
pin = r'^SURFACE_CENSUS_VERBS: CLEAN \(pass=[1-9][0-9]* skip=[0-9]+\)'
assert re.search(r'pass=([0-9]+)', pin) is None
```

## 4. Excluded numbers and why (53 numeral-bearing lines)

Class legend: **V** vendor fact (explicitly out per the ticket); **M** dated
host/substrate measurement (Source line 3, table header 13, Erratum 119-129);
**X** exit or HTTP status code (a measurement, not a lane-artifact size);
**R** reference/identifier/round tag/date/ordinal/line span/regex token (not a
stated count); **C** command constant or advice (not an artifact size);
**D** discourse count (counts bullets, outcomes or repetitions, not an
artifact's present size).

| line | number(s) as written | class | why excluded |
|---|---|---|---|
| 3 | `2026-09-28`, `2.35.0` | M, V | Source-line date; vendor CLI version, declared historical by Erratum line 121. |
| 4 | `L194–210` | R | Line span in the absent `~/.local/bin/the-janitor`; a reference, not a stated count. |
| 9 | `R11-02`, `R12-01` | R | Two recheck row ids (an enumeration, not a cardinal); both resolve at `corpus/claim-ledger.tsv:16,26`. |
| 13 | `2026-09-28` | M | Table-header observation date. |
| 15 | `2.35.0`, `0` | V, X | Vendor version; exit code. |
| 16 | `one`, `four`, `0` | M, V, X | 2026-09-28 account element count (host state); vendor JSON field count; exit code. |
| 17 | `1` | X | Exit code. |
| 18 | `~60 s`, `1` | M, X | Timing; wrapper exit code. |
| 20 | `round 10`, `0`, `~0.02 s` | R, X, M | Round tag; exit; timing. |
| 21 | `round 10`, `~4 s`, `25 s`, `1 / 124`, `round 3`, `~60 s` | M, X, R | Dated timing/exit observations; round-3 history. |
| 23 | `round 10` | R | Section tag. |
| 27 | `round 10`, `both`, `one session`, `4 s/exit 1` | M, D | Round-10 probes; "both" counts the two observed outcomes in that history. |
| 28 | `25 s`, `124`, `timeout 30` | M, X, C | Measurement; exit; advice constant. |
| 29 | `one shape` | D | Qualitative "the one shape"; not an artifact size. |
| 31 | `2` | X | Guard exit code (handler behaviour; dated). |
| 32 | `2` | X | Same guard exit code. |
| 34 | `round 10` | R | Section tag. |
| 36 | `L228–235` | R | Line span in the absent handler. |
| 37 | `both` | D | The two consequence bullets (Leak, Silent omission), not an artifact quantity. |
| 40 | `first five bytes` | V | Length of the vendor ref scheme (`op://`), not a lane artifact size. |
| 43 | `0`, `9` in the regex | R | Regex character-class text. |
| 59 | `1.` | R | List ordinal. |
| 60 | `2.` | R | List ordinal. |
| 63 | `Path 2` | R | Ordinal reference. |
| 64 | `2026-09-28` | M | Observation date. |
| 65 | `1` | X | Exit code. |
| 67 | `1` | X | Exit code. |
| 70 | `second` | D | Ordinal in prose. |
| 72 | `127.0.0.1:8080`, `/v1` | M, V | Host endpoint; vendor API path. |
| 73 | `2026-09-28`, `8080` | M | Date; host port. |
| 74 | `404`, `/v1/models` | M, V | Observed HTTP status; vendor API path. |
| 76 | `34113`, `/v1` | M, V | Host port; vendor API path. |
| 77 | digits in the model filename | V | Vendor model file name. |
| 80 | `40961` | M | Host port. |
| 82 | `404` | M | Observed HTTP status. |
| 87 | `--max-time 2`, `$2` | C, R | Command constant; awk field reference. |
| 88 | `v1` | V | API path. |
| 91 | `404s` | M | Observed HTTP status. |
| 96 | `Sep 21` | M | Dated session-file observation. |
| 97 | `0` | X | Exit code. |
| 98 | `L183` | R | Line reference in the absent handler. |
| 104 | `1` | X | Exit code. |
| 106 | `four` | V | Vendor JSON field count (restated). |
| 108 | `8080`, `127.0.0.1` | M | Host endpoint. |
| 109 | `34113`, `127.0.0.1` | M | Host endpoint. |
| 110 | `twice`, `second`, `0` | D, X | Recipe repetition/ordinal; exit code. |
| 111 | `Round-10` | R | Round tag. R25-C6: a tag alone does not make a number historical; this is why the "pair" on line 113 is listed as a candidate, not excluded. |
| 114 | `0` | X | Expected exit code. |
| 115 | `1` | X | Expected exit code. |
| 116 | `124`, `0` | X | Expected exit codes. |
| 119 | `round 22` | R | Erratum heading. |
| 125 | `round-18` | R | Deferral record. |
| 129 | `round-22`, `Entry16` | R | Audit path token. |

Not present in the excluded set and not omitted silently: lines 52, 57 and 113
are the three candidates in section 3; the other 53 lines above plus those 3
account for all 56 numeral-bearing lines of the 129.

### 4.1 Count-adjacent prose with no stated numeral (not in the 56-line inventory)

- Lines 79-80, "Neither `status` nor `ensure_started` probes the model
  endpoint", is a 0-of-two claim about two named handler verbs. It states no
  numeral, the handler is absent, and the sentence is a host/caller
  measurement; out.
- Lines 100-101, "no janitor tmux session and no session-id remained", is a
  zero-valued observation of dated host state; out.
- Line 42, "those keys are absent from the output entirely", is an absence
  claim, not a count; out.

## 5. Counterexamples

### 5.1 A one-word mutation is invisible to the binder

At BASE, `corpus/self-counts.tsv` has 38 data rows and 0 with a
`corpus/knowledge/` doc; the working table has 56 rows (38 + 18 `KN-*`), 18
with a knowledge doc, and 0 naming `op-cli-surface.md`. The round-27 mutator
selects an existing row (`c1-measure.py:51`), so `--mutate` cannot target this
document at all. Changing line 57 from `two` to `three` (or line 52 `both` to
`three`, line 113 `pair` to `triple`) leaves every self-counts binding green:
no row's locator matches any line of this entry.

### 5.2 Count-preserving member swap (QM18)

`refs-shape-table` (`surface-census.sh:536`) and
`refs-redaction-prefix-only` (`:569`) are named in this entry, the probe
source, `knowledge/surface-census.md`, `SKILL.md` and two lessons, but no
ledger row or data table pins the pair (`grep` counts on
`corpus/claim-ledger.tsv` and `corpus/surface-census.tsv` are 0 for all four
probe names). `R11-02`'s committed pin extracts `pass`/`skip` counts only
(`corpus/claim-ledger.tsv:16`), `R11-03` pins `16 cases` (`:17`), and
`corpus/surface-census.tsv` carries no verb/refs rows. Replacing one named
probe with a different case while keeping the count at two would leave
"both"/"pair" true and no ledger row would fail — the exact count-preserving
swap QM18 says must fail some row. The same holds for the deep pair
`run-plain-env` / `run-ref-signed-out` (`:584`, `:604`). This is a membership
identity gap in a knowledge entry, not a stale cardinal: the cardinal (2) is
correct today.

### 5.3 Freshness: the version is historical, and the recheck path is deferred

- `op 2.35.0` (lines 3, 15) is a vendor version dated 2026-09-28, not a release
  anchor. `corpus/claim-ledger.tsv:27` (`R12-02`'s note, BASE) records a newer
  measured `op 2.41.0` in round 21, so the entry's version cannot be read as
  current; the Erratum is what keeps it historical. The ledger's 2.41.0 is
  itself a round-21 host measurement, not live today.
- The entry has no `recheck:` line; its trigger is `Reverify: R11-02, R12-01`
  (line 9). Both rows are `[substrate]` (`corpus/claim-ledger.tsv:16,26`).
  `R12-01`'s note requires `op` on PATH and `$HOME/.local/bin/the-janitor`,
  otherwise SETUP exit 2; `R11-03`'s note says the two verb cases SKIP when
  the handler is absent. The handler is absent (`ls
  ~/.local/bin/the-janitor` → no such file). The entry's own Erratum says
  "relevant deferred rows are not passes" (lines 125-126). The freshness
  disposition is therefore **DEFERRED**, not CLEAN and not re-verified this
  round.
- C2's numeric-regression rule has nothing to order here: there is no
  `on-release` clock and no numeric anchor in this entry. Fabricating one from
  `2.35.0` would be a category error; the only valid statement is that the
  version is a dated vendor observation.

### 5.4 QM1-adjacent observation (not a C1 number)

The body states present-tense properties of the absent handler at line 4
(`L194–210`), line 36 (`L228–235`) and line 98 (`L183`). The only history
marker is the trailing Erratum, which does say the handler is unavailable and
that caller/handler comparisons are dated. Whether a global Erratum satisfies
QM1's "explicit historical marker" for each line reference, or whether each
site needs its own marker, is not adjudicated here; it is not a count and is
outside C1. Flagged for the L1 because the `cmd_refs` section reads as current
until the Erratum 60 lines later.

## 6. What I did NOT check (unrun is not a pass)

- Did not run `python3 corpus/self-counts.py`, the round-27 `c1-measure.py`, or
  any binder/gate/selftest/formatter. The "0 in-population" result is the
  static row-set fact (0 rows name the doc at BASE and in the working table),
  not an executed CLEAN receipt; the L1's final run remains the executed check.
- Did not run `bash corpus/surface-census.sh --verbs`, `--deep`, or
  `--selftest`, and did not run `corpus/op-ref-probe.sh`. `R11-02`,
  `R11-03` and `R12-01` are substrate rows; running them here would be a gate
  verification and the handler/substrate is absent anyway.
- Did not execute `op` at all (no vault/account/handler/CDP contact), so
  `2.35.0`, the account state, `signin`, `whoami` and every exit code in the
  entry are not re-measured. `op --version` was not run.
- Did not read `~/.local/bin/the-janitor` (it does not exist; only an `ls`
  existence check was made), so the line references `L194–210`, `L228–235`
  and `L183` are unverified.
- Did not inspect `opencode.json`, host ports (`8080`, `34113`, `40961`) or the
  `llama-server` state; those are host measurements, out of the C1 population.
- Did not read the round-22 audit `kagi-shokunin/.ufo/waves/round-22/build/Entry16.md`,
  other knowledge entries, other C1 bindings, or the C2 release-clock code and
  selftest.
- Did not open vendor documentation to confirm `op`'s JSON field set or
  version; vendor facts are out of population by the ticket.
- Did not execute a mutation through the binder (the invisibility claim is
  static: 0 rows targeting the doc). No sandbox clone was needed.
- No host-private reads (no `~/.config`, `op.env`, tokens, sessions). No
  installs or updates were made, so there is no tool/version/channel record to
  report.

## 7. Limits and recommendation

- Population reviewed: this entry only. The classification of "both" (line 52)
  and "pair" (line 113) as lane-artifact cardinals rather than prose is a
  judgment call; I list them as candidates because both name concrete lane
  gate cases. If the L1 classifies them as prose, the in-population count is
  still 0, and the QM18 identity gap in 5.2 remains. Line 57 is present tense,
  but the trailing Erratum may cover it as a caller/handler comparison; I list
  it as a candidate because the Erratum does not mark the sentence itself. If
  the L1 treats it as Erratum history, the candidate count is 2 and the
  in-population count is still 0.
- The entry is correctly outside the round-27 `KN-*` set in the sense that it
  has no bindable in-population number today. That is not the same as saying
  its three cardinals are covered: they are named-membership prose with no
  machine source, and a count-preserving rename would not be noticed.
- Recommendation, for the L1 only (production is read-only for this seat):
  1. Record lines 52, 57 and 113 in the round-27 lesson's excluded list as
     "member counts, identity carried by named ids, no machine source"
     (QM26 names the excluded candidates rather than silently dropping them).
  2. If binding is wanted, add one non-host ledger row that pins the exact
     identifiers — `grep -F` both probe names in `surface-census.sh`
     (`refs-shape-table`, `refs-redaction-prefix-only`; `run-plain-env`,
     `run-ref-signed-out`) and both auth tokens in
     `credential-isolation.md` (`OP_SERVICE_ACCOUNT_TOKEN`, `op signin --raw`)
     — and write the cardinals as digits so the binder's integer extract can
     bind them. Do not add `rows:` bindings: they would count 35 data lines
     (`surface-census.tsv`) or 54 (`credential-isolation.md`), binding a
     different quantity (QM18).
  3. Keep the Erratum as the history clause and do not re-pin `2.35.0` as a
     current version or as a release anchor.
- Confidence: high for the static inventory (all 56 numeral-bearing lines
  enumerated and classified; binder source semantics read at
  `corpus/self-counts.py:260,340,344` and `c1-measure.py:45-54`). Low for any
  runtime claim in the entry itself: the handler and `op` were not measured.
