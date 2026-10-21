# KnowJanitorEnvContract — C1 inventory of `corpus/knowledge/janitor-env-contract.md`

Target: `corpus/knowledge/janitor-env-contract.md` at frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`. Working file is byte-identical to
BASE (`git status --porcelain` lists no entry for it) and its stamp is exact:
`sha256sum` = `c0a9008eecb4ee74f41daaf23a04fd6a5a75b0dc79ec869b3e9a101de5dc7cb8`,
122 lines, 6829 bytes, equal to `corpus/stamps.tsv:40`. No production file was
written; this report is advice for the L1 integrator.

Population rule applied: `plans/round-27.md` §C1, `corpus/QUALITY.md` QM21 and
QM26, and this ticket's exclusion clause — **not** vendor facts and **not**
host measurements of absent substrate.

## Verdict

| quantity | value |
|---|---|
| current-tense numbers about this lane's own artifacts | **0** |
| rows to add to `corpus/self-counts.tsv` | **0** |
| STALE | 0 |
| OK | 0 |

Every quantity the entry states is one of: (a) a dated 2026-09-28 measurement
of the **host** handler (`~/.local/bin/the-janitor`, recorded absent at its
cited path on 2026-10-15 by the entry's own erratum and not re-checked here),
(b) a line/span address inside the entry's own `Source-status: historical`
erratum, or (c) a config literal / exit code / inequality, not a size. There is
no current-tense number about a lane-owned artifact to bind, so this entry
contributes **zero** to the KN-* population and cannot supply a red-control id
for `c1-measure.py --mutate`.

Consequence that must not be papered over: `grep -c janitor-env-contract
corpus/self-counts.tsv` is `0` at BASE **and** in the round-27 working table,
so a one-digit change anywhere in this entry leaves `SELF_COUNTS: CLEAN`.
That is correct under QM26 only if the result is reported as *reviewed, zero
in population* — never as "bound" or "calibrated".

## Population table (`corpus/self-counts.tsv` format)

Header for reference: `id<TAB>doc<TAB>locator<TAB>source<TAB>extract<TAB>note`.

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| — | — | — | — | — | *(no rows: no current-tense lane-artifact number exists in this entry)* |

Evidence for the empty table:

```
$ grep -c janitor-env-contract corpus/self-counts.tsv            # 0
$ git show BASE:corpus/self-counts.tsv | grep -c janitor-env-contract   # 0
```

## Every quantity statement, and why it is out

Nine statements carry a size/quantity (five with digits, two spelled counts,
two exit codes). None states a lane artifact's present size.

| # | line | exact text | value | class | why out (rule) | lane-local counterpart |
|---|---|---|---|---|---|---|
| 1 | 4 | `` `2408b0c9…57edd`, 333 lines)`` | 333 | host source line count | host measurement of absent substrate; date 2026-09-28 on line 3; erratum line 99-100: "The original abbreviated hash and source line count are preserved, not re-asserted as current" (QM1) | `corpus/drift-baseline.tsv:1` col 3 = `333` (agrees) |
| 2 | 67 | `` `_serve` unsets 20 model/API credential vars (L214–219)`` | 20 | count inside the host script | inside qualified span 65-77; host file; no lane-owned live source reads it | none |
| 3 | 73 | ``Observed env-file reality (2026-09-28 `refs`, 10 keys)`` | 10 | host-private env-file measurement | dated measurement section ("Observed … 2026-09-28"); reading `op.env` is prohibited here | none |
| 4 | 73 | ``: 8 keys hold`` | 8 | same observation | same | none |
| 5 | 74 | `` `op://` refs, 2 hold **raw values**`` | 2 | same observation | same | none |
| 6 | 89 | ``missing /nonexistent`, exit 2`` | 2 | behavior / exit code | QM2: command-and-host attribution; qualified historical by span 79-90 | none |
| 7 | 90 | ``missing command`, exit 2`` | 2 | behavior / exit code | same | none |
| 8 | 61 | `` `baseURL` (one field)`` | one | count of config fields to edit | inside qualified span 53-63; not an artifact size | none |
| 9 | 84 | `shows the two endpoint strings` | two | count in a reproduction recipe | inside qualified span 79-90 | none |

Boundary note for #1: `333` is the closest thing to a bindable number, and it
would still be refused three ways. First, the target is a host file, not a
lane-owned one. Second, the only lane-local record is a **column** of
`corpus/drift-baseline.tsv:1`, and `rows:` counts nonblank non-comment lines —
it cannot extract a column (`corpus/self-counts.py:8-10`). Third, no ledger row
pins it: R11-04 (`corpus/claim-ledger.tsv:18`) prints
`DRIFT_PINS: CLEAN (files=N symbols=N)` and never the line count. Binding it
would re-assert an absent substrate property, which QM1 forbids.

## All 48 digit-bearing lines, by class

The entry has 48 lines carrying a digit (the title and all blank/structural
lines are clean). 12 of them are inside the erratum body; 36 precede it. The
classes below account for all 48, with overlaps; six lines are the quantity
statements already listed above and appear here only for completeness.

| class | lines | example / note |
|---|---|---|
| dates (historical) | 3, 47, 73, 92, 95, 102 | `read 2026-09-28`; `observed live 2026-09-28`; `(2026-10-15)` |
| claim ids (not counts) | 8 | `Reverify: R11-02, R11-04` — ids, resolved and shape-checked by `claim-ledger.sh docs` |
| product name, not a number | 20, 50 | `1Password`, `1Password-BrowserSupport` |
| path labels | 39, 41 | `Path 2`, `Path 1` |
| source line addresses (`L<n>`) | 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 28, 32, 33, 34, 36, 55, 63, 67, 82 | positions in the absent handler / `client.py`; all ≤ 219 < the baseline's 333 |
| config literals | 17 (`40961`), 18 (`3600`), 21 (`9222`), 55 (`127.0.0.1`, `8080`, `/v1`), 59 (`34113`, `8080`) | defaults and endpoint strings, not sizes |
| modes | 71 (`077`, `700`, `600`), 75 (`0600`) | host-file modes; `0600` agrees with `drift-baseline.tsv:5` |
| hash digits | 4 (`2408`, `57`) | abbreviated sha256, not a count |
| quantity statements already listed | 4, 67, 73, 74, 89, 90 | `333`; `20`; `10`/`8`; `2`; `exit 2`; `exit 2` |
| erratum labels/spans | 40 (`round-3`), 92 (`round-16`), 97-99 (`3-6`, `10-23`, `25-51`, `53-63`, `65-77`, `79-90`), 105-106 (`454-466`, `496-506`), 115 (`Round-22`), 118 (`Round-19`), 119 (`round-16`), 122 (`round-22`) | history, explicitly excluded by QM26 |
| inequality | 23 (`>1 account`) | threshold, not a count |

## Structural check: the erratum's six spans still cover the current lines

The erratum (lines 94-100) qualifies "original lines 3-6, 10-23, 25-51,
53-63, 65-77, 79-90". At BASE those spans land exactly on the current
sections — no insertion above line 90 since round 16:

| span | first line | last line |
|---|---|---|
| 3-6 | `Source: … read 2026-09-28 …` | `… this table is the only complete inventory.` |
| 10-23 | `## Knob table` | `| OP_ACCOUNT …` |
| 25-51 | `## Auth selector semantics (cmd_serve L194–210)` | `… builds the var name dynamically …` |
| 53-63 | `## The endpoint is *not* a knob` | `… the overlay is truth.` |
| 65-77 | `## Leak-surface notes` | `… aspirational, not enforced.` |
| 79-90 | `## Falsification` | `… missing command, exit 2).` |

Coverage result (Python, `re` only):

```
numeric lines: 48   before erratum: 36   inside the six spans: 35
outside the spans and before the erratum: [8]   # "Reverify: R11-02, R11-04"
```

So exactly one digit-bearing line escapes the qualification, and it carries no
quantity — only two claim ids. The historical qualification is therefore
line-complete for the *current* text, not merely for the round-16 revision.

## Appendix — locators for the excluded quantities (verified, do not add)

Each regex has exactly one capture group and matches exactly one line at BASE
(verified with `re.search` line by line). They are listed so a reviewer can
re-locate every excluded number without re-deriving the census — **not** as
proposed `corpus/self-counts.tsv` rows. Every one of them would bind a host
fact as current (QM1).

| value | line | locator | hits | source it would need |
|---|---|---|---|---|
| 333 | 4 | ``^`2408b0c9…57edd`, ([0-9]+) lines\)`` | 1 | a row pinning `drift-baseline.tsv` col 3 — none exists; `rows:` cannot read a column |
| 20 | 67 | `unsets ([0-9]+) model/API credential vars` | 1 | a host read of the handler — refused |
| 10 | 73 | ``\(2026-09-28 `refs`, ([0-9]+) keys\)`` | 1 | a host-private `op.env` read — prohibited |
| 8 | 73 | ``\(2026-09-28 `refs`, [0-9]+ keys\): ([0-9]+) keys hold`` | 1 | same |
| 2 | 74 | `` `op://` refs, ([0-9]+) hold `` | 1 | same |
| 2 | 89 | ``missing /nonexistent`, exit ([0-9]+)`` | 1 | re-execution of the absent handler (QM2) |
| 2 | 90 | ``missing command`, exit ([0-9]+)`` | 1 | same |

## Freshness findings

1. **No release identity; C2's REGRESSED rule cannot bind this entry.**
   `\b\d+\.\d+\.\d+\b` matches only `127.0.0` inside the endpoint literal
   `http://127.0.0.1:8080/v1` (line 55) — no version. `corpus/release-clocks.tsv`
   has `0` rows mentioning `janitor` (`grep -c` → 0, exit 1). A downgraded feed
   or a numeric regression changes nothing here; that is not coverage, it is
   inapplicability (QM23: an `on-release` clock needs an observable release
   identity, and this source has none).

2. **The only freshness hook is substrate-only.** Line 8 declares
   `Reverify: R11-02, R11-04`; both rows exist (`corpus/claim-ledger.tsv:16`
   and `:18`) and both notes end `[substrate]`. `verify` prints
   `HOST-SKIP <id> reason=host-row-not-authorized` for them
   (`corpus/claim-ledger.sh:575`) unless `--allow-host-rows` is passed, and the
   binder refuses them as a source (`corpus/self-counts.py:259-260`); if
   `--allow-host-rows` is passed on a substrate-absent host, the row still ends
   `DEFER reason=substrate-absent` (`corpus/claim-ledger.sh:578-580`), and
   `verbs()` itself refuses at `corpus/surface-census.sh:470`
   (`die "handler not on PATH"`). On a substrate-absent host, nothing
   re-measures this entry's source facts.
   Relevance is also partial and unchecked by design (the ledger header at
   `corpus/claim-ledger.sh:77`: "The declaration is a POINTER, not
   relevance"): R11-02 exercises only `THE_JANITOR_ENV`
   (`corpus/surface-census.sh:524,549,574,591,613,657,662,667`), the first knob
   row, and never the port/timeout/auth selectors; R11-04 does measure the
   handler's mode/lines/hash (`corpus/drift-baseline.tsv:1`).

3. **The marker that excludes this entry from C1 is not gate-enforced.**
   `grep -rn "Source-status" --include=*.py --include=*.sh --include=*.tsv .`
   returns 0 hits (including `.ufo`); the round-16 `node` one-liner at
   `SCORECARD.md:505` was a one-off measurement, not a retained gate.
   `corpus/self-counts.tsv` holds no row for the doc. So no gate asserts the
   marker's presence: removing or rewording line 94 (`Source-status:
   historical — …`) in a reviewed edit leaves `docs`, `citations` and
   `self-counts` green; the only detector is the generic revision stamp
   (`verify_stamps`), which fires on any byte change and is satisfied by an
   intentional restamp. This is a static argument about gate inputs, not an
   executed pass (I did not run gates).

4. **The revision pin is current.** `corpus/stamps.tsv:40` matches the working
   file exactly (sha256, 122 lines, 6829 bytes), so an edit to this entry is
   detectable by `verify_stamps` even though its numbers are unbound.

5. **Concrete counterexample to "numeric spans are current addresses":** the
   erratum cites `SCORECARD.md:454-466` and `SCORECARD.md:496-506`
   (lines 105-106). At BASE, `454-466` begins four lines early — the
   `## Round-19 correction` heading is at `SCORECARD.md:458`, though the
   paragraph it points at (including the `janitor-env-contract.md:3-4`
   sentence) is inside 460-466. `496-506` contains the Target and the *before*
   command block, but the `Observed:` line is at `:508`; the after-observation
   and the `janitor-env-contract.md:92-113` citation sit in
   `## Outcome — round-16 re-dispatch` at `:512-525`. The entry's Round-22 note
   (lines 115-122) already declares these spans historical addresses and
   redirects to the named sections; both named headings exist
   (`## Round-19 correction` at 458, `## Outcome — round-16 re-dispatch` at
   512, with `## Current baseline — round-16 re-dispatch` at 472 between them),
   so the note resolves the drift. No edit is recommended: the erratum is
   append-only history, and the spans are excluded by QM26.
   By contrast, the *entry's* own cited erratum span, `SCORECARD.md:525`
   `janitor-env-contract.md:92-113`, is still exact at BASE (the Round-22 note
   begins at 115) — the historical record of the erratum is accurate even
   though the entry's SCORECARD locators are not current addresses.

## Integration advice for L1 (no production file touched)

1. **Name the exclusion (QM26 requires it).** Suggested census sentence for the
   round-27 lesson / `corpus/self-counts.tsv` header:
   > `knowledge/janitor-env-contract.md` — reviewed, 0 current numbers: every
   > quantity is a dated host/substrate measurement (2026-09-28) or a
   > line/span reference inside the `Source-status: historical` erratum
   > (lines 92-113); the one digit-line outside the six qualified spans
   > (line 8) is a `Reverify:` id list, not a count.

2. **Do not add binder rows for `333`, `20`, `10`, `8`, `2`, or the two
   `exit 2` codes.** All five size statements are host facts; adding a row
   would assert an absent substrate property as current (QM1) and would bind a
   quantity no non-host lane artifact defines.

3. **Optional structural guard, with its real cost.** The only way to make the
   exclusion fail-loud is a one-line ledger row pinning the marker's presence:
   `grep -cE '^Source-status: historical' corpus/knowledge/janitor-env-contract.md`
   with expect `^1$` (precedent: R16-04 at `corpus/claim-ledger.tsv:42`; `grep`
   is allowlisted, the argument is relative, no metacharacters). Cost: the new
   row moves R21-04 (`corpus/claim-ledger.tsv:54`) from `65` to `66`, restamps
   `corpus/claim-ledger.tsv` (`corpus/stamps.tsv:13`) and turns every R21-04
   binding STALE — SC-SKILL-CLAIMS, PV-CLAIMS, RD-LEDGER-ROWS,
   KN-LEDGER-REPRO-CLAIMS (`corpus/self-counts.tsv`). That is a six-file
   bookkeeping move (`corpus/claim-ledger.tsv`, `corpus/stamps.tsv`, `SKILL.md`,
   `PROVINCE.md`, `corpus/README.md`, `corpus/knowledge/claim-ledger.md`); if it
   is not done in the same commit with old/new values (QM14), it is worse than
   the prose limit. Recommended: defer unless L1 wants the guard this round.

4. **Rule for any future number here.** If a later round adds a current-tense
   number to this entry, bind it with `expect:<ID>` (host rows never execute)
   or a non-host `ledger:<ID>` — never `rows:` for a drift-baseline column.
   And keep line 94's marker: without it, a reader (and every gate) sees the
   top half as current-tense prose with no binder row watching it.

## What I did NOT check

- **Host path presence and any handler bytes.** `~/.local/bin/the-janitor`,
  `~/.config/the-janitor/{client.py,config.json,op.env}` were not stat'd or
  read (host-private surfaces are prohibited for this seat). The erratum's
  2026-10-15 absence finding, any restoration, the 333-line count, every
  `L<n>` address, the `20` unset vars, the env-file key split, the modes and
  both `exit 2` codes remain source-derived history, not re-verified.
- **No gate, selftest, linter or counting run.** `corpus/self-counts.py`,
  `claim-ledger.sh docs|citations|verify`, and `c1-measure.py` were not
  executed (L1 runs final checks once). The "no row" statements come from
  reading the table (`grep -c` = 0), not from a CLEAN receipt.
- **The other 24 knowledge entries** (25 parallel scouts) and any corpus-wide
  digit census. The `48/36/35` counts are for this file only.
- **`op account get` field list, the PII shape claim, and the `op://` key
  contents** — no account, vault, handler or CDP contact of any kind.
- **SCORECARD history outside the cited spans** (458-525) and whether the
  round-16 measured revision still contains the cited bytes; only current
  addresses and text were read.

## Tooling and installs

None. Every check above used `read`, `grep`, `git show`/`ls-tree`, `sha256sum`,
`wc`, `awk` and a local `python3 - <<PY` `re` census; no package, binary or
service was installed, upgraded or restarted, and no pacman transaction ran.
