# KnowJanitorCommandSurface — C1 inventory of `corpus/knowledge/janitor-command-surface.md`

**Question.** Which current-tense numbers does this entry state about this lane's own
artifacts, what live source defines each, and is each STALE or OK?

**Answer.** **None. Zero numbers are in population; no `corpus/self-counts.tsv` row is
proposed.** The entry is a reviewed exclusion: every numeral in it is a host-source
measurement, a host-source line citation, a host runtime constant, an identifier or code
literal, or a date/round. The entry itself is explicitly historical (`:90-99`), and its
cited substrate has been recorded absent since round 18. This is a calibration finding,
not a gate pass: the C1 binder cannot see the difference between "no current number" and
"not reviewed".

BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`. All paths below are lane-relative and
refer to that BASE; the entry is byte-identical in the working tree (checked below).

## BASE identity and method

- `corpus/knowledge/janitor-command-surface.md` at BASE: **99 lines / 6386 bytes /
  sha256 `69cb9c8859c35b92dea656254eeb7a670e69d20ea2c5cf1327ae7f7ad7d61456`**.
  `git hash-object` of the working-tree file equals
  `git rev-parse 0a47dd18:corpus/knowledge/janitor-command-surface.md`; the stamp row
  `corpus/stamps.tsv:39` pins the same triple. Last commit touching it:
  `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (round-22 erratum), so the text read is the
  committed text and there is no byte/stamp drift.
- Read-only seat. **No host path was read** (`~/.local/bin/the-janitor`,
  `~/.config/the-janitor/…`), no `the-janitor` command, no vault/op/account/CDP call, and
  no gate/selftest/`self-counts.py`/`claim-ledger.sh verify` was executed. Ledger
  expectations were read from `corpus/claim-ledger.tsv`; no row was run.
- Numeral census over the 99 lines with Python regex `[0-9]+(?:\.[0-9]+)*`:
  **50 digit-bearing lines, 114 maximal numeral tokens**. That is a digit census, not 114
  distinct facts: dates, line-range endpoints, claim IDs, product names and a model string
  supply many tokens.

## Rule applied

- `corpus/QUALITY.md:118` (QM21): a current-tense number about this lane's own artifacts
  is bound to the live source that defines it; a round tag alone does not make a number
  historical.
- `corpus/lessons/round-25.md:49-57` (R25-C6): a number is CURRENT when it states an
  artifact's present size and **no newer value sits in the same clause**; an explicit
  history clause, including a **dated measurement**, is out.
- `corpus/QUALITY.md:133` (QM26, working tree only — `git show BASE:corpus/QUALITY.md`
  has zero QM26 occurrences): dated measurement sections and Evidence/Erratum history in
  `corpus/knowledge/*.md` are excluded by rule and named.
- `corpus/lessons/round-27.md:39-46` (working tree, round-27) names the same exclusion
  classes: dated measurement sections, Evidence/Erratum/Round-N history, host/substrate
  observations, positional case indexes, and numbers with no lane-local pinned source.
- The assignment's extra filters: vendor facts and **host measurements of absent
  substrate** are not lane-artifact numbers.

Under those rules the entry's `333`/`117` are excluded three times over: the referent is a
host file, the read is dated 2026-09-28 in the same sentence, and the entry's Erratum
declares the source historical. The remaining numerals are host behavior constants,
identifiers, or dates. The spelled-out cardinalities (`ONE`, `one`, `once`) are not
numeral tokens and are not artifact sizes.

## Population test by the requested category

| Requested category | What the entry contains | Result |
|---|---|---|
| Selftest case counts | None: the entry quotes no selftest output | out — no lane selftest number |
| Row/stamp/claim/pin counts | No numeral. `:8` enumerates `R11-02, R11-04`; the entry's own stamp row is in `corpus/stamps.tsv:39`, not quoted in the entry | out — an enumeration is not a stated count; an unquoted stamp is not a number the entry states |
| Bounds | `3600 s` (`:63`), `2 s` (`:53`), `120 × 0.5 s = 60 s` (`:50`), `40961` (`:48,52`), modes `0700`/`0600` (`:61`), exits `0`/`1`/`2` | out — host runtime constants of the absent tool, not lane-artifact bounds |
| File/line counts of lane-owned files | None. The only file/line counts are `333`/`117` for `~/.local/bin/the-janitor` and `~/.config/the-janitor/client.py` (`:3-4`) | out — host files, dated read, absent substrate |
| Finding counts | None stated | out — no lane finding number |

No category yields an in-population number. The next table therefore has zero rows.

## Current-number table (empty by rule)

The requested table would have the six `corpus/self-counts.tsv` columns. It has **no
rows**:

```
id	doc	locator	source	extract	note
(no rows: 0 in-population numbers, 0 proposed bindings)
```

No locator is supplied for a binding because no number qualified. Supplying a locator
without a live source would assert that a host/dated number is current — the defect QM21
exists to prevent. Candidate locators in the next section are **negative controls only**.

## Near-miss candidates — why each fails

These are the numbers a digit-only scan would try to bind. None has a live, allowed
source. `rows:` counts data lines (`corpus/self-counts.tsv:11-14`); `ledger:` executes a
**non-host** row and refuses `[host]`/`[substrate]`
(`corpus/self-counts.py:259-260`); `expect:` applies the extract to the row's committed
`expect` regex and runs nothing (`corpus/self-counts.py:342-346`). The failure modes in
the table are **static reads of the binder/ledger code**, not executed results.

| Line | Exact text (BASE) | Tempting source | What that source actually yields | STALE/OK | Why excluded | Candidate locator (negative control only) |
|---|---|---|---|---|---|---|
| 3 | `Source: ~/.local/bin/the-janitor (333 lines, bash, …` | `expect:R11-04`; `rows:corpus/drift-baseline.tsv`; `ledger:R11-04` | `expect`: the pin is the regex `^DRIFT_PINS: CLEAN \(files=[1-9][0-9]* symbols=[1-9][0-9]*\)` (`claim-ledger.tsv:18`); it has no literal 333, so the natural `files=([0-9]+)` extract fails SETUP, and a generic `([0-9]+)` would capture the `1` in `[1-9]`, not 333. `rows`: 15 data lines. `ledger`: POLICY `host/substrate row refused`. | n/a — out of population | Host measurement; dated `2026-09-28` (`:5`); Erratum `:92-93`; source absent | `^Source: .*\(([0-9]+) lines, bash` |
| 4 | `…and ~/.config/the-janitor/client.py (117 lines), both read` | same three | same: no literal 117 in the pin, 15 rows, ledger refused | n/a — out of population | same | `\(([0-9]+) lines\), both read` |
| 10 | `…dispatcher, L293–333)` | none | — | n/a — out of population | Positional range into the absent host file; dated by `:5`; not a size | `^## Verb table .*dispatcher, L[0-9]+–([0-9]+)\)` |
| 50 | `readiness loop exhausted (120 × 0.5 s = 60 s)` | none | — | n/a — out of population | Host readiness-loop geometry | `readiness loop exhausted \(([0-9]+) ` |
| 53 | `with a 2 s timeout` | none | — | n/a — out of population | Host health-probe timeout | `^with a ([0-9]+) s timeout` |
| 63 | `default **3600 s**` | none | — | n/a — out of population | Host request-timeout default | `default \*\*([0-9]+) s\*\*` |
| 48 | `port 40961 already healthy` | none | — | n/a — out of population | Host service port | `^\| port ([0-9]+) already healthy` |
| 5 | `2026-09-28` | none | — | n/a — out of population | Date, not an artifact size | — |
| 8 | `Reverify: R11-02, R11-04` | `ledger:R11-02`, `ledger:R11-04` | both rows carry `[substrate]` (`claim-ledger.tsv:16,18`); `ledger:` refuses them; on an absent substrate they would DEFER, not pass | n/a — out of population | Claim IDs, not a stated count; two IDs are an enumeration, not the numeral `2` | — |
| 14, 36 | `reads ONE request`; `one janitor request at a time` | none | — | n/a — out of population | Spelled-out cardinalities describing host protocol, not artifact sizes | — |
| 19 | `^[A-Z][A-Z0-9_]*=` | none | — | n/a — out of population | Regex character class, not a count | — |
| 62 | `Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS` | none | — | n/a — out of population | Model identifier, not a count or version | — |

The three tempting sources fail in three different ways, and none is a correct binding:
`rows:` gives a real but **wrong** value (15 baseline rows), `expect:` with the natural
`files=` extract fails because the pin is a regex with no literal count, and `ledger:` is
refused because the row is `[substrate]`. Binding `333` to `rows:corpus/drift-baseline.tsv` would print
`STALE … claimed=333 live=15` and invite the false "correction" `333 → 15`; binding it to
`expect:R11-04` would print `SETUP … extract did not match`; binding it to `ledger:R11-04`
would print `POLICY … host/substrate row refused`. All three are wrong; the correct
disposition is **exclusion**.

## Complete exclusion census

The entry's tables enumerate verbs, startup gates, status fields and error texts, but the
entry states no count for any of them; an enumeration is not a numeral claim. Classes (a
line may hold more than one class):

| Class | Lines | Exact examples | Why excluded |
|---|---|---|---|
| A — host source size + dated read | 3, 4, 5 | `333 lines`; `117 lines`; `both read 2026-09-28` | Host measurements of the absent substrate; dated measurement (R25-C6/QM26) |
| B — host source line citations | 10, 14-24, 26, 32, 34, 36, 39, 41, 54, 60-64, 66, 71, 73, 84 | `L293–333`; `L121–135`; `L98–100`; `L146–170` | Positional ranges into the absent host files; `:5` dates them; Erratum `:92-93` marks them historical |
| C — host runtime constants | 26, 30, 38, 45-50, 52-53, 61, 63, 66, 71, 85-88 | `exit 2`; `exit 1`; `exit 0`; `port 40961`; `2 s`; `3600 s`; `120 × 0.5 s = 60 s`; `0700`; `0600`; `THE_JANITOR_PORT=1` | Behavior/modes/port/timeouts of the absent host tool; not counts of lane artifacts |
| D — identifiers and code literals | 8, 10, 19, 23, 30, 45, 49, 50, 62, 79 | `R11-02, R11-04`; `${1:-help}`; `[A-Z0-9_]`; `1Password`; `python3`; `Qwen3-…`; `$# -eq 0` | Claim IDs, product/model names, regex classes, positional parameters — not counts |
| E — dates and rounds | 5, 90, 94, 99 | `2026-09-28`; `round 22`; `round 18`; `round-22` in the audit path | History markers; QM26 excludes Erratum/round history by rule |
| F — spelled-out cardinalities (not numeral tokens) | 14, 19, 20, 36 | `ONE request`; `listed once per line`; `one-shot`; `one janitor request at a time` | Not numerals; host protocol/behavior, not artifact sizes |

Compact line → class audit trail (all 50 digit-bearing lines; overlapping classes shown):

```
3 A | 4 A,C | 5 A,E | 8 D | 10 B,D | 14 B,F | 15 B | 16 B | 17 B | 18 B | 19 B,D,F |
20 B,F | 21 B | 22 B | 23 B,D | 24 B | 26 B,C | 30 C,D | 32 B | 34 B | 36 B,F |
38 C | 39 B | 41 B | 45 B,C,D | 46 C | 47 C | 48 C | 49 C,D | 50 C,D | 52 C |
53 C | 54 B | 60 B | 61 B,C | 62 B,D | 63 B,C | 64 B | 66 B,C | 71 B,C | 73 B |
79 D | 84 B | 85 C | 86 C | 87 C | 88 C | 90 E | 94 E | 99 E
```

This is the complete set: re-running the census regex over the BASE file yields exactly
these 50 lines and 114 tokens; no digit-bearing line is unclassified.

Token census per line (maximal `[0-9]+(?:\.[0-9]+)*` tokens, verbatim; lexical tokens,
not distinct facts — each is classified above):

```
3 333 | 4 077,117 | 5 2026,09,28 | 8 11,02,11,04 | 10 1,293,333 | 14 121,135 |
15 137,143 | 16 145,171 | 17 173,184 | 18 311,314 | 19 0,9,228,235 | 20 237,249 |
21 295,298 | 22 299,302 | 23 1,320,331 | 24 186,226 | 26 2,332 | 30 0,2 |
32 122,125 | 34 126,128 | 36 130,134 | 38 2 | 39 69,71 | 41 77,119 | 45 3,52,56,2 |
46 2 | 47 2 | 48 40961,40961,1 | 49 1,1,1 | 50 120,0.5,60,1,1,1 |
52 127.0.0.1,40961 | 53 2 | 54 98,100,72,75 | 60 41,55 | 61 57,0700,0600,61,63 |
62 3,30,3,2,75,84 | 63 3600,74 | 64 87,92 | 66 1,111,113 | 71 0,93,95 | 73 145,171 |
79 1 | 84 146,170 | 85 2 | 86 2 | 87 1 | 88 2 | 90 22 | 94 18 | 99 22,12
```

## Freshness assessment (C2 and substrate)

- **The entry is explicitly historical.** `:92-93`: “Source-status: historical — all
  handler/client line citations, failure texts, modes and behavior above retain their
  original observation date.” `:94-98` records the substrate absent since round 18 and
  says to restore and inspect before quoting current behavior.
- **The recheck rows are substrate rows.** `:8` declares `R11-02` and `R11-04`; both notes
  end in `[substrate]` (`corpus/claim-ledger.tsv:16,18`). `substrate_present()` tests an
  executable `$HOME/.local/bin/the-janitor`
  (`corpus/knowledge/substrate-deferral.md:31-33`); absent plus tag ⇒
  `DEFER <id> reason=substrate-absent`, never a FAIL and never a pass
  (`substrate-deferral.md:34-37`). I did not execute `verify`; this is the pinned policy
  read, not an observed verdict.
- **No release clock exists for this entry.** `corpus/release-clocks.tsv` has 31 lines
  (header + 30 data rows: S005–S032, S040, S041) and zero `janitor` matches;
  `corpus/source-fetches.tsv` and `corpus/SOURCES.md` also have zero `janitor` matches.
  The 1Password quote clocks (S006, S019, S020) are bound to other source pages, not to
  this entry.
  The entry has no registry-style `source:` row (the `Source:` at `:3` is the dated prose
  citation) and contains no version token: the only dotted numerics are the IPv4 address
  `127.0.0.1` and the duration `0.5`. C2's numeric-regression rule therefore has **no
  candidate here**. The correct freshness disposition is **historical/unverifiable**,
  never `CLEAN`; an absent source cannot produce a numeric observation.
- **On substrate return, do not manufacture an anchor.** `333`/`117` are pre-loss values
  recorded in `corpus/drift-baseline.tsv:1-2` (mode 755, lines 333/117, sha256s), not live
  observations. Any difference is a host drift event for `drift-pins.sh` (row `R11-04`),
  requiring a symbol re-grep of every line range before any edit
  (Erratum `:97-98`); it is not a release event and not a license to silently re-pin the
  entry to the new host. The line counts are not `X.Y.Z`, so C2's typed `REGRESSED` rule
  does not apply to them; the drift gate is the guard. Do not repurpose
  `release-clock.py` for them either: a line count has no release identity (QM23,
  `corpus/QUALITY.md:120`), and the inequality arm would call a 300-line restoration
  “fired” — the same false release C2 is fixing for `X.Y.Z`.
- **Absence is not a pass.** Treating `DEFER` as OK, or binding `333` to a pre-loss
  baseline and calling it “live”, would convert an honest absence into a false freshness
  claim — the same class C2 refuses for version clocks.

## What I did NOT check

- I did **not** read `~/.local/bin/the-janitor` or `~/.config/the-janitor/client.py`, and
  did **not** probe their existence. The absence is taken from
  `corpus/knowledge/substrate-deferral.md:3-11` and the entry's Erratum `:94-98`
  (documented observations), not re-measured here.
- I did **not** execute `the-janitor`, `corpus/drift-pins.sh`,
  `corpus/surface-census.sh --verbs`, `corpus/claim-ledger.sh verify`,
  `corpus/self-counts.py`, any selftest, or the C1 overlay/mutation. The two `Reverify`
  rows' deferral is a code/pin read, not an observed run.
- I did **not** verify the 2026-09-28 host bytes or behavior, and cannot say whether the
  handler changed before it vanished.
- I did **not** re-audit the round-22 erratum's append-only provenance. (The entry's old
  self-stamp triple does not appear in the landed erratum; whether the landed text meets
  the round-22 append-only requirement is round-22 history, outside this question.)
- I did **not** audit sibling entries `corpus/knowledge/janitor-env-contract.md` or
  `corpus/knowledge/janitor-lifecycle.md`, or any other knowledge entry.
- I did **not** run a full digit census of the corpus; no claim is made beyond this file.

## Checks L1 should run after integration (all unrun here)

1. `bash corpus/self-counts.py` → expect exit 0; then
   `grep -c 'corpus/knowledge/janitor-command-surface.md' corpus/self-counts.tsv` → 0.
   At this seat's read, the after table has 18 `KN-*` rows over 7 entries, none this doc;
   the BASE table has 38 rows, none for any knowledge entry. Zero is the intended
   exclusion, not an omission.
2. **Negative control (scratch table only, do not commit):** add a row with locator
   `^Source: .*\(([0-9]+) lines, bash` and source `rows:corpus/drift-baseline.tsv`; the
   binder should print `STALE … claimed=333 live=15`. This demonstrates why the binding
   must not land; it is not evidence that `333` is stale.
3. `bash corpus/claim-ledger.sh docs corpus/knowledge` → confirm the single `Reverify:`
   line still parses and both ids resolve. A later `verify` (not an acceptance check for
   this entry) would DEFER both rows; do not treat that as a pass.
4. Do **not** run `drift-pins.sh`, `surface-census.sh --verbs`, or a full `verify` as an
   acceptance check while the substrate is absent: they defer or fail by design
   (`substrate-deferral.md:34-37`; round-22 `Entry12.md` made the same point).

## Integration note

The round-27 C1 after-state says a one-digit knowledge mutation turns the binder STALE.
That claim is true for the bound numbers only. This entry has no binding, so a mutation
`333 → 334` would leave the binder's verdict unchanged *by construction*. The plan already
limits C1 to a reviewed population (“No claim of complete digit census”), but a reader can
still mistake “no row” for “reviewed and clean”. If the wave keeps an exclusion register,
record `corpus/knowledge/janitor-command-surface.md` there as **reviewed, 0 bindings,
host/substrate + dated measurement + Erratum history**, so the exclusion is auditable and
distinct from an unreviewed entry. I did not edit the lesson or the table.

## Installs

None. No package, tool, service, or host configuration was changed.

## Report

`.ufo/waves/round-27/build/KnowJanitorCommandSurface.md` (this file), written under
`/home/vgpnk/Projects/shokunin/kagi-shokunin` at BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`. Read-only seat; no production file was
modified.
