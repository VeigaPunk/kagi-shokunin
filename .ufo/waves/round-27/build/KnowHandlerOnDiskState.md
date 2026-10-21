# KnowHandlerOnDiskState — C1 number inventory (round 27 build)

Target: `corpus/knowledge/handler-on-disk-state.md`, BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`.

**Verdict: 0 in-population current-tense numbers about this lane's own
artifacts. No `KN-*` row is proposed. The entry is a reviewed
zero-population control, not an unbound entry.**

Identity at BASE: blob sha256
`556fe70b681af58b35ac55a562f77ca089994a4d67260578e9db93d6d4f2869c`,
287 newline-terminated lines, 288 logical lines; the last byte is `.`, so the
final line has no trailing newline. `git show BASE:corpus/knowledge/
handler-on-disk-state.md | sha256sum` equals the worktree hash: the entry is
byte-identical at BASE and at my read, and I did not modify it. Because the
population is empty there is no STALE/OK verdict to report and nothing was
corrected; no history clause was added.

No tooling was installed or upgraded.

## Population rule applied

Two conditions, both from the round-27 criteria: QM21 at BASE
`corpus/QUALITY.md:118`, and QM26, added in the round-27 worktree at
`corpus/QUALITY.md:133` (not present at BASE), plus the round-27 plan:

1. **Current** means a present-size statement about a lane artifact with no
   newer value in the same clause; an explicit history clause, an Erratum /
   Evidence / Round-N findings section, or a dated measurement section is out.
2. **Bound** means a lane-local live source: `rows:<repo file>`, a non-host
   `ledger:<ID>` verdict, or a host/substrate row's committed `expect:<ID>`
   pin (`corpus/self-counts.py:1-34`). A number with no such source is out of
   population even if current.

Both conditions must hold. This entry fails every candidate on at least one,
and most on both.

**Stronger currency rule tested (round-27 critic).**
`.ufo/waves/round-27/build/CritC1Population.md` (CE1-CE4) argues that an
erratum's *text* is excluded but a body number the erratum concedes stays
current-tense, and proposes a `self-counts.tsv` header amendment to that
effect. I applied that stronger rule here: it does not change the result.
Every body number in this entry (C1-C4) is a host/substrate measurement — line
counts of absent files, DB/log sizes and row counts — and the population is
limited to lane artifacts with a lane-local source. The only lane-artifact
numbers are the erratum's own positional locators (C5-C7), which live in the
erratum text and have no defining source. No body number states a lane
artifact's size.

## Method and completeness

Command: Python tokenizer
`(?<![\w.])[0-9][0-9,._]*` applied to `splitlines()`, followed by manual
classification of every line that matched. Result: **125 of 288 logical lines
carry numeric tokens** (301 tokens including date groups, hashes, modes, line
refs and code literals). Every one of the 125 is classified; there were no
unclassified lines. The full per-line census is
`.ufo/waves/round-27/build/KnowHandlerOnDiskState.numbers.tsv` (columns
`line`, `numbers`, `class`, `ruling`, `text`).

Disjoint group totals (each line assigned once, by the order used in the TSV):
lane-file locators 4, reproduction-block host measurements 23, host DB 24,
host source refs/line counts 19, host behaviour/timings 17, host log 6,
host file properties 5, modes 6, vendor facts 6, dates 5, round ids 5,
headings 4, ledger ids 1. Sum 125. None is an in-population lane-artifact
count.

## In-population table (format: corpus/self-counts.tsv)

Empty. There is no row to write with six non-empty columns:

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| — | — | — | — | — | no current number has a lane-local defining source |

This is not an omission: the table's own header at `corpus/self-counts.tsv:8-9`
already excludes "host measurements (breadth, handler/DB counts)", and every
number here is a host measurement, a vendor fact, a date, a round id, a code
literal, or a line span inside the historical erratum. Because the table is
empty, no one-group regex locator is supplied: a locator would imply a binding
that does not exist. The 125-line census below is the evidence that the
population was searched, not merely assumed empty.

## Candidates and rulings

All quotes are from BASE; line numbers are the entry's own.

| # | line(s) | exact text | class | lane-local source | ruling |
|---|---|---|---|---|---|
| C1 | 3, 5 | "333 lines" / "117 lines" | line counts of `~/.local/bin/the-janitor` and `~/.config/the-janitor/client.py` | none — host paths, not repo files | OUT: host file line counts, not lane artifacts; erratum `:252-257` also qualifies lines 3-9 historical |
| C2 | 31, 33, 35 | "9,240,576 B", "33,687 B, 84 lines", "4,709,964 B" | host file sizes / log line count | none | OUT: host file/log measurements, not lane artifacts; the probes are dated `:7` (2026-09-28) and the erratum covers the body |
| C3 | 54-59 | "session \| 7", "message \| 39", "part \| 55", "event \| 238", "0" | host SQLite row census | none | OUT: host DB counts, named out of population in `self-counts.tsv:8-9`; no ledger pin carries them |
| C4 | 184 | "7/39/55/238 — all unchanged rounds 6→10" | host DB bound | none | OUT: host measurement, and it already carries the explicit history clause "rounds 6→10" |
| C5 | 255 | "original lines 3-9 (handler/client source basis), 13-14" | positional spans into this entry | none | OUT: Erratum history (QM26); spans still resolve at BASE |
| C6 | 257 | "through line 248" | content boundary of the pre-erratum body, not a present size | none | OUT: Erratum history; and binding it to `wc -l` (288) would falsify its meaning. Still true at BASE (see below) |
| C7 | 265-266 | "`SCORECARD.md:454-466` names the" / "`SCORECARD.md:496-506` records the three-path count" | line spans of a lane-owned file | none — no `rows:`/`ledger:`/`expect:` source pins a span | OUT: recorded in the filed Erratum, superseded by the Round-22 locator note (`:280-288`); a span is not a count any allowed source can extract |
| C8 | 18, 39, 103 | "three roots", "Two consequences", "three flock verbs" | spelled-out enumerations of host objects | none | OUT: host layout/verb prose, not lane artifacts |

C1 and C2 also fail the first condition independently of the substrate: the
erratum at `:250-259` marks all source-derived lines 3-248 historical, and the
DB section is explicitly dated 2026-09-28.

## Why no row can be manufactured

The most tempting candidate is C4 (`7/39/55/238`), which the round-25 wave
already classified as host DB rows
(`.ufo/waves/round-25/build/RHistoricalVsCurrent.md:47`, "OUT … host DB row
count"). Three independent mechanical checks show no legal binding exists:

1. **`rows:` cannot express it.** `corpus/state-shape.tsv:32-35` records the
   census only in free-text notes ("observed 7 (rounds 6–10)", "observed 39",
   "observed 55", "observed 238"), while the machine-readable values are the
   *floors* `session:2`, `message:13`, `part:18`, `event:79`. `rows:` counts
   non-comment data lines — 22 for that file (`claim-ledger.tsv:24`, R11-10) —
   not cell text, so it cannot capture 238.
2. **`ledger:R11-01` / `ledger:R11-04` is refused by policy.** Both ledger
   rows carry `[substrate]` (`corpus/claim-ledger.tsv:15,18`), and
   `corpus/self-counts.py:258-260` fails `POLICY: ledger:<id> host/substrate
   row refused`. They are also the exact two ids this entry names at `:16`
   ("Reverify: R11-01, R11-04").
3. **`expect:R11-01` / `expect:R11-04` carries no literal count.** Their
   committed expect strings are count-*patterns*, not counts:
   `^SURFACE_CENSUS: CLEAN \(assets=[1-9][0-9]* runtime=[1-9][0-9]*
   scanned=[0-9]+ ok=[1-9][0-9]*` and
   `^DRIFT_PINS: CLEAN \(files=[1-9][0-9]* symbols=[1-9][0-9]*\)`. An extract
   such as `scanned=([0-9]+)` applied to that text matches nothing (the next
   byte is `[`), and the binder would report `UNLOCATED`, not 238.

A synthetic row would therefore look like the line below and fail at the first
run — it is shown as a rejected candidate, not proposed for
`corpus/self-counts.tsv`:

```
KN-HODS-CENSUS  corpus/knowledge/handler-on-disk-state.md  ^\s+([0-9]+)/39/55/238 — all unchanged rounds 6→10  expect:R11-01  \(([0-9]+) cases  REJECTED: extract cannot read a census the pin does not contain
```

Making it pass would require a new `[host]`-tagged ledger row pinning
`7/39/55/238` (or editing the R11-01 substrate pin), plus a QM14 migration
record. That is a host measurement by construction and remains outside the
round-27 population rule.

## Excluded numbers, grouped (full list in the census TSV)

- **Host source basis, 19 lines (`3-7`, `21-26`, `105-106`, `110-113`,
  `128`, `221`)**: `333`, `117`, `186-226`, `77-120`, `145-171`,
  `130/139/175`, `303-330`, `L190-191`, `L222-224`, `L225`, `umask 077`,
  `L62-70`, `L130-131`, `L139-140`, `L175-176`, `L31`, `L32-33`, `L34-35`.
  Host source refs and wrapper properties for files the host does not carry,
  inside the erratum's qualified range. Out by QM1/QM26.
- **Host modes, 6 lines (`77-78`, `100`, `168`, `193`, `195`)**: `0600`,
  `0700`, `0644`, `077`. Host file properties, not lane counts.
- **Host DB census and timestamps, 24 lines (`54-59`, `61-62`, `64`, `66`,
  `68`, `72-73`, `92-95`, `181-186`, `191`)**: `7`, `39`, `55`, `238`,
  `16/23`, `22/7/13/13`, `104/75/52/7`, `7/1/38/38`, `11,175`,
  `1788026642930`, `1789966628471`, "all 7 sessions". Named out of population
  in `self-counts.tsv:8-9`; no ledger pin carries them.
- **Reproduction block, 23 lines (`205-208`, `210`, `213-214`, `216-219`,
  `226-233`, `238`, `241-242`, `244`)**: `84`, `8`, `33 KB`, `70`, `10`, `7`,
  `2`, `0`, `sleep 5`, `timeout 2`, exits `124`/`0`, `<1 s`, `sleep 90`,
  `64 s`. Host log/DB/lock measurements and their shell literals.
- **Host behaviour and exit codes, 17 lines (`89-90`, `98`, `116-118`,
  `120-121`, `138`, `142`, `144-149`, `264`)**: backoff `2.3 → 4.7 → 8.9 →
  19 → 30 s`, `60 s`, `3600 s`, `2 s`, exits `0/1/124/401`, `0.01 s`. Host
  runtime measurements on absent substrate; `:264` is the `stat` exit 1.
- **Host log, 6 lines (`46-47`, `83-84`, `86`, `170`)**: `8` run ids, `10`
  plugin lines, `33 KB`, `0` matches. Host log measurements.
- **Host file sizes and modes, 5 lines (`31-33`, `35-36`)**: `9,240,576 B`,
  `33,687 B`, `84 lines`, `4,709,964 B`, `4096 × 2256`, `0600`. Host file
  properties.
- **Vendor/product facts, 6 lines (`157-158`, `173-174`, `176-177`)**:
  `222 providers / 7865 models` (`:173`), `4.7 MB` (`:173`, `:176`),
  `1Password` (`:157-158`); `opencode 1.18.31` sits on `:7` in the
  host-source group. Explicitly not lane artifacts.
- **Dates, 5 lines (`13`, `50`, `250`, `253`, `261`)**: 2026-09-28 and
  2026-10-15 measurement/erratum dates. Not counts.
- **Round ids, 5 lines (`81`, `280`, `283-284`, `288`)**: round-6/10/16/19/22.
  Not counts.
- **Headings and ledger ids, 5 lines (`16`, `18`, `103`, `133`, `155`)**:
  section numbers and the `R11-01`/`R11-04` identifiers.
- **Lane-file locators, 4 lines (`255`, `257`, `265-266`)**: `3-9`, `13-14`,
  `248`, `SCORECARD.md:454-466`, `SCORECARD.md:496-506`. Closest to the
  assignment's "bounds, file/line counts of lane-owned files"; all sit inside
  the historical erratum and none has a defining live source.

Hash prefixes (`2408b0c9…57edd`) are not counts; they are historical
source-property assertions covered by the erratum (QM1).

## Counterexamples and cross-checks (concrete)

- **The entry's own baseline says these are not pinned.**
  `corpus/knowledge/claim-ledger.md:407-408` (round-14 entry review) lists
  "`handler-on-disk-state`'s row counts (re-printed by `R11-01`, not pinned by
  it)". That is the lane's prior admission of exactly the C4 exclusion. The
  "re-printed" half is only true of the runtime `SHAPE OK … rows <got> >=
  <floor>` lines, not of the pinned receipt.
- **State-shape floors differ from the census.** `corpus/state-shape.tsv:32-35`
  pins the floors `2/13/18/79`, not `7/39/55/238`; the same notes restate
  "observed 7/39/55/238", but `rows:` counts lines and cannot read a note, and
  no committed machine-readable lane value equals the prose census.
- **`through line 248` is still literally true, but only positionally.**
  At round-16 filing (`f4a8dd9`) the file was 277 lines and the erratum began
  at 250; the round-22 diff is a single hunk `@@ -278 +278,11 @@`, i.e. an
  append after line 277. Base line 248 is the closing repro fence. The
  statement is accurate at BASE but would silently change meaning if anything
  were inserted above line 248; no gate watches it. Debt, not a defect.
- **The SCORECARD spans have drifted.** At BASE, `SCORECARD.md:454-456` are
  round-21 axis-table rows unrelated to the debt, `:458` is the "Round-19
  correction" heading, and `:466` stops mid-sentence before the hash prefixes
  on `:467`. For the second span, `:496-497` is the target prose and `:505` is
  the measuring command, but the observed `3/3` line is `:508`, outside
  `496-506`. The Round-22 locator note (`entry:280-288`) already tells readers
  to use the named sections instead of these mutable numbers, which is why
  they are out of the C1 population rather than a correction target.
- **`Reverify: R11-01, R11-04` cannot bind a number.** Both are `[substrate]`,
  and both expect patterns contain no literal count; see the three checks
  above. The "re-printed" half of `claim-ledger.md:407` is the runtime
  `SHAPE OK … rows <got> >= <floor>` output (`corpus/surface-census.sh:431-437`),
  not a pinned receipt.

## Freshness (C2) relevance

This entry carries **no `recheck:` line and no `on-release` clock**; its only
recheck anchor is the substrate pair at `:16`. The new QM25 `REGRESSED` rule in
`corpus/release-clock.py` therefore has nothing to order here, and the C2
downgrade fixture cannot be sourced from this entry. That is an absence of a
release clock, not a pass of C2. The declared recheck is the substrate pair at
`:16`; both rows are `[substrate]`, so QM15's default-deny `verify` skips them
without an explicit consent flag, and the entry's freshness trigger is a
deferred host measurement even before any release question. The only trigger
the entry states is operator-authorized substrate restoration plus separately
authorized re-measurement (`:274-276`); it carries no `recheck:` line, so QA4
is at best satisfied by that erratum prose, not by an observable release
identity. I did not test whether the substrate is still absent — that is a host
measurement and is outside both this item and the C1 population.

## What I did NOT check

- I did not run `corpus/self-counts.py`, `c1-measure.py`, `surface-census.sh`,
  `drift-pins.sh`, `claim-ledger.sh`, any selftest, linter or build. Unrun
  checks are not passes.
- I did not read host-private paths or absent substrate: no
  `~/.local/bin/the-janitor`, no `~/.config/the-janitor/*`, no state tree, no
  DB, no log, no vault/account/handler/CDP contact. The `ENOENT` claim at
  `:261-265` is taken as filed, not re-executed.
- I did not verify the historical line counts, hash prefix, DB census, log
  counts or timings against any source; they remain the entry's 2026-09-28
  observations under its erratum.
- I did not review the other 24 knowledge entries, the `KN-*` rows in the
  binding table (18 at my first read, 22 over 8 entries at my final check; none
  for this entry), or whether the round-27 knowledge corrections landed
  correctly (the lesson draft says five stale; `CritC1Population.md` disputes
  that count).
- `.ufo/waves/round-27/c1-before.json`, cited by `corpus/lessons/round-27.md`
  M27-2, was not present in the wave directory at my read (only
  `.ufo/waves/round-27/c2-before.json` was). I used neither artifact as
  evidence; if the lesson lands without it, that citation is unbacked.

## Recommendation to L1

1. **Add no `KN-*` row for this entry.** The population is empty; adding a row
   would require reinterpreting a historical locator or pinning a host
   measurement, both against the round-27 rule.
2. If the lesson wants to show the population was reviewed rather than
   complete, name this entry as a zero-population control with the exclusion
   classes above. The draft's binding population (18 over 7 entries at my
   first read, 22 over 8 at my final check) covers only those entries and does
   not claim the rest; this entry is not a missed binding. If a count is
   written into the lesson, re-read the table rather than copying this
   snapshot.
3. Optional, separate from C1: replace `through line 248` with a named-section
   anchor (e.g. "through the repro/falsification block") so the erratum's
   scope stops depending on line positions. That is a production edit to a
   knowledge entry and belongs to the L1, not to this report.

Report is lane-authored advice, not non-author closure; no SHONEN marks were
written.
