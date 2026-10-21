# KnowFeatureBoundCredentialRe — C1 inventory: `corpus/knowledge/feature-bound-credential-review.md`

Seat: `KagiR26.KnowFeatureBoundCredentialRe-17`. BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Target: `corpus/knowledge/feature-bound-credential-review.md`, 60 lines / 5386 bytes, sha256
`53a24710f9b3f5c7355bbb0f7af622fbed6783dc7954234114d0c6c9ab2b42d8` — byte-identical to BASE
(`git diff --stat BASE -- <path>` empty) and to `corpus/stamps.tsv:36`.

Citation convention: BASE-identical line numbers are used for the entry, `corpus/stamps.tsv:36`,
`corpus/SOURCES.md:24`, `corpus/claim-ledger.tsv:52`, `corpus/QUALITY.md:118` (QM21),
`corpus/release-clocks.tsv:18`, and BASE `corpus/release-clock.py`. Round-27-only artifacts do
not exist at BASE and are marked: `plans/round-27.md` and `corpus/lessons/round-27.md` are
untracked; `corpus/QUALITY.md:132-133` (QM25/QM26) and the `KN-*` block plus `REGRESSED` code are
working-tree additions (BASE `QUALITY.md` is 126 lines; BASE `self-counts.tsv` is 52 lines with no
`KN-*` row).

## Result

**0 in-population current-tense numbers about this lane's own artifacts.**
33 numeric lexemes over 9 classes; every digit character in the file (93 of 93) lies inside one
classified lexeme, and every class is excluded by the QM21/QM26 population rule. There is no
STALE/OK row to report and no value to correct, so no history clause is owed. This is not an
omission: the entry states no selftest case count, row/stamp/claim/pin count, bound, file/line
count, or finding count.

Corroboration that this entry is outside the C1 bound set:
- `corpus/self-counts.tsv:53-75` (round-27 `KN-*` block of L1's uncommitted after table; BASE's
  table is 52 lines with 0 `KN-*` rows) has **0** rows whose doc column is this
  file (`awk` command below); `corpus/lessons/round-27.md:49` (round-27 lesson, untracked at
  BASE) says "18 bindings over 7 entries", and this is not one of the seven.
- `.ufo/waves/round-27/knowledge-migrations.json` mentions this file **0** times (no correction,
  no history clause).
- `corpus/lessons/round-25.md:158-168` (§Named debt) did not name this entry among the stale ones.

## 1. Binding table (format of `corpus/self-counts.tsv:1-5`)

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| *(no rows)* | — | — | — | — | 0 in-population numbers in this entry |

Because there are no rows, no number here has a defining `rows:` / `ledger:` / `expect:` source,
no pinned live value exists to compare, and no per-number regex locator is proposed. Proposing one
would require a number the entry does not state.

Rejected shape, for the record: `^source: .*?Version ([0-9]+)\.[0-9]+\.x\)` matches line 1 once
and captures `2`, the vendor major version. It is an integer the binder could compare, but its
referent is the vendor docs series, not a lane artifact; binding it would manufacture a
calibration row and fail QM21's "about this lane's own artifacts". The same objection applies to
`^recheck: on-release — open (both) Broker`: the group is not an integer, so `integer()` would
raise SETUP before any comparison.

**Why a one-digit mutation in this entry cannot turn the binder STALE.** `check()` loads the claim
list from the table first and opens a document only for a claim that names it
(`corpus/self-counts.py:306-332`; loop at `:315`, per-claim doc read at `:323-325`). With no claim
whose doc is this file, the file is never read and the summary's `claims=` is unchanged.
Counterexample: mutate line 19 `In OpenBao 2.7.x's service-token context` to `2.8.x`; the binder
prints no line for this doc and cannot fail. The only lane-local detector of that byte change is
the stamp assertion in `corpus/stamps.tsv:36` (sha256 / 60 lines / 5386 bytes) — a different gate.
This is a named coverage limit of "the reviewed knowledge population" (`plans/round-27.md:12-22`,
which also
disclaims a complete digit census), not a defect in this entry.

## 2. Excluded numbers — complete census

Method: a Python class scan merged identifier/date/version fragments into lexemes; result
`{SOURCE_ID: 11, LEDGER_ID: 2, QUALITY_ID: 2, DATE: 4, STEP_LOCATOR: 2, VENDOR_VERSION: 2,
BRAND: 7, ROUND_TAG: 1, WORD_QUANT: 2}` = 33 lexemes, with 93/93 digit characters covered and 0
uncovered. A second sweep for count-bearing prose (`selftest|cases|rows=|stamps=|claims=|pins=`)
returns 0; the only `rows` tokens are ordinary phrases at lines 9 and 11 ("token rows", "merged
rows").

| line(s) | exact text / lexeme | class | lane-local source? | why out of population |
|---|---|---|---|---|
| 1, 16, 17, 18, 19 | `S017` … `S021` (11 occurrences) | source-row ids | registry defines them (`corpus/claim-ledger.tsv:52`, R21-02), but no id is a quantity | identifier, not an artifact size; QM21 binds stated integer quantities |
| 4, 30 | `R21-02` (2) | ledger row id | its own pin | identifier; the entry only names it as the citation-chain checker |
| 20 | `QA9`, `QA10` (2) | QUALITY criterion ids | `corpus/QUALITY.md` | identifiers |
| 1, 49 | `2026-07-28` (2) | vendor publication date (S020) | none lane-local | dated observation; QM21/QM26 date exclusion |
| 2, 48 | `2026-10-20` (2) | verification/capture date | none lane-local | dated measurement; exactly the QM26 exclusion |
| 1, 17 | `Steps 1/3` (2) | positional locator (Step 1 and Step 3 of S018) | registry anchor `corpus/SOURCES.md:24` | positional index, QM26 exclusion; it is not "three steps" counted |
| 1, 19 | `Version 2.7.x` / `2.7.x` (2) | vendor docs version | none lane-local; vendor page S021 | vendor fact, and non-numeric (`x`) — QM25 inequality-only limit |
| 1, 16, 50 | `1password` / `1Password` (7) | product brand inside URLs and prose | none | brand numeral, not a quantity |
| 45 | `round-22` (1) | section/history round tag | none | round tag on a labeled historical section |
| 3 | `both` (1) | word quantifier over the two Broker feature pages (S017, S018) | none | no digit (binder extracts `([0-9]+)`); it counts two **vendor** pages, not a lane artifact size |
| 52 | `two` (1) | "two commercial labels" (EPM Business / 1Password Business) | none | vendor-label count, not a lane artifact; word, not digit |

Near-miss worth naming so it is not mistaken for a missed binding: the table has five decision
rows (lines 16-20), and `corpus/claim-ledger.sh` prints a per-entry `ENTRY <rel> row_linked=N`
counter (`corpus/claim-ledger.sh:1201`). The entry never states that count, and the binder binds
only stated integers; writing one in to bind it would be padding, not calibration.

## 3. Freshness (C2) — no numeric pair in the entry; the ordered guard is in the clock row

- The entry's only version-bearing token is `Version 2.7.x` (line 1) / `2.7.x` (line 19). It is
  non-numeric, so QM25 cannot order it; it keeps inequality only as a declared limit
  (`corpus/QUALITY.md:132`, working tree; QM25 is added this round and is absent at BASE).
- The ordered guard for this entry's OpenBao row is `corpus/release-clocks.tsv:18` (S021):
  `feed S035, anchored 2.7.1, observed 2.7.1, observed_at 2026-10-21, not-fired`, note
  `derived: anchor names Version 2.7.x; newest stable server release when opened 2026-10-20 (v2.7.1)`.
- Concrete downgrade shape at BASE: `observe_one`'s feed branch writes `not-fired` only on
  equality and `fired` otherwise (`BASE corpus/release-clock.py:727-734`), and `evaluate` accepts
  any `fired` row with `observed != anchor` as a release event (`BASE ...:524-526`) → `CLEAN`.
  So a cropped feed serving OpenBao 2.7.0 against the 2.7.1 anchor is recorded and accepted as a
  release, and (conditional on that feed state) the OpenBao reading in this entry would rest on a
  stale feed with no failure.
  The round-27 change (working tree, not BASE; `plans/round-27.md:24-35`, `corpus/QUALITY.md:132`
  QM25) makes that observation a typed `REGRESSED` finding (exit 1), never fired and never CLEAN.
- Limit: the clock identity is the server-release feed S035, not the docs-page version. A
  docs-only version change that publishes no server release is not observable by this row; the
  other four sources this entry uses are `rendered-quote` clocks
  (`corpus/release-clocks.tsv:14-17`), whose declared identity is the capture quote, not a
  version number.

## 4. Reproduce

```bash
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git show 0a47dd189356ea66ec83c3891eed54526e95b89b:corpus/knowledge/feature-bound-credential-review.md | sha256sum
# 53a24710f9b3f5c7355bbb0f7af622fbed6783dc7954234114d0c6c9ab2b42d8  -
git diff --stat 0a47dd189356ea66ec83c3891eed54526e95b89b -- corpus/knowledge/feature-bound-credential-review.md
# (empty)
awk -F'\t' '!/^#/ && $2=="corpus/knowledge/feature-bound-credential-review.md"' corpus/self-counts.tsv | wc -l
# 0
grep -c 'feature-bound' .ufo/waves/round-27/knowledge-migrations.json .ufo/waves/round-27/expectation-migrations.json
# 0 and 0
# lexeme census: 11 source ids + 2 ledger ids + 2 quality ids + 4 dates + 2 step locators
#               + 2 vendor versions + 7 brand tokens + 1 round tag + 2 word quantifiers = 33;
#               all 93 digit characters covered by those spans, 0 uncovered.
```

## 5. What I did NOT check

- No vendor page or feed was opened or fetched (no network); the entry's vendor claims are not
  re-verified, and neither are S017-S021's served bytes.
- I did not run `corpus/self-counts.py`, `corpus/release-clock.py`, `claim-ledger.sh`, or any
  selftest/gate — L1 runs final checks once. Ledger pins were read from
  `corpus/claim-ledger.tsv`, not re-executed (R21-02 row).
- I did not audit the entry's content against the cited page text, nor the superseded
  machine-credentials / Vault-OpenBao entries it replaces.
- I did not check cross-file numbers that point at this entry (e.g. `corpus/README.md:126`) beyond
  confirming that no number is stated **in** the entry.
- I did not evaluate a docs-version-only freshness trigger for S021 (§3 limit).
- The post-C2 behaviour is read from the uncommitted working tree and `plans/round-27.md`; it was
  not executed here, and it is not present at BASE.

## 6. Advisory for L1 integration

- Record this entry as **reviewed with zero in-population numbers** in the C1 exclusion accounting
  (`corpus/lessons/round-27.md` §C1 or the `KN-*` comment block), so a later reader does not read
  absence as omission. No table row is owed.
- Do not invent a `KN-*` row for `2.7.x`: it is a vendor version with no lane-local source and no
  integer capture; a binding would be a false population member.
- Keep S021's `derived` 2.7.1 anchor in `corpus/release-clocks.tsv:18`; it is the only ordered
  freshness guard for this entry's OpenBao row.

Confidence: high on the zero-population census (digit-complete classification over the exact BASE
bytes) and on binder non-coverage (static code path, no claim row); high on the BASE accept shape
(code read at BASE, not executed); the after-state framing is the round plan/QM25 plus L1's
uncommitted working tree, not a measurement by this seat.
