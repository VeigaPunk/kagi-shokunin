# KnowSubstrateDeferral — C1 inventory of `corpus/knowledge/substrate-deferral.md`

Seat: `KagiR26.KnowSubstrateDeferral-17`. Frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`. Target is 115 lines. Its bytes are
identical at BASE and in the working tree
(`sha256 607ed9f4e512283ac72a1254011047ce1cfe54d71566591af515dc53a592eb94`; empty
`git diff HEAD -- corpus/knowledge/substrate-deferral.md`), so every line number
below is a BASE citation. No production file was edited; this report and its
sandbox are the only writes.

Axes: **calibration** (does each current number have a live definition and does
the doc agree with it), **freshness** (can the defining source move without the
doc noticing), **non-harm** (no source invented to make a number bindable).

## Verdict

- **3** current-tense numbers about lane artifacts are in population and all
  **3 are OK** at BASE. No stale *digit* is present in this entry, so there is
  no QM21 correction to make here.
- **1 stale positional index** is out of population by rule but should be
  replaced by case names: `cases 95-97` at line 85 now address three unrelated
  cells/docs cases; the defer cases are 119-121 (F1).
- **0** release-clock anchors in this entry, so the C2 `REGRESSED` rule has no
  target here. The entry's recheck surface is `Reverify: R18-01, R11-09`
  (line 13), not an `on-release` clock.
- Every excluded number is named with its class below. This is a census of the
  entry's numeric tokens (digits and number words, every line scanned), not a
  semantic claim that no other quantity is implied by prose.

## In-population bindings (format of `corpus/self-counts.tsv`)

| id | line | exact text | source | extract | doc | pinned live | verdict |
|---|---|---|---|---|---|---|---|
| `KN-SUBSTRATE-CENSUS-SELFTEST` | 44 | ``rather than `bad-case`. The case count is unchanged (16), the line shape is`` | `expect:R11-03` | `\(([0-9]+) cases\)` | 16 | 16 | **OK** |
| `KN-SUBSTRATE-ABSENCE-FILES-BAD` | 50 | ``all-GONE `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 …)` verdict at exit 1.`` | `expect:R18-01` | `files_bad=([0-9]+)` | 15 | 15 | **OK** |
| `KN-SUBSTRATE-ABSENCE-FILES-OK` | 50 | same line, `files_ok=0` component | `expect:R18-01` | `files_ok=([0-9]+)` | 0 | 0 | **OK** |

Locators (each has exactly one capture group and was tested with stdlib `re`
against the BASE file — exactly one matching line each):

```
case count is unchanged \(([0-9]+)\)
\(files_ok=[0-9]+ files_bad=([0-9]+) 
\(files_ok=([0-9]+) files_bad=[0-9]+ 
```

Ready-to-paste rows (six tab-separated columns; place after
`KN-CENSUS-DRIFT-SYMBOLS`):

```
KN-SUBSTRATE-CENSUS-SELFTEST	corpus/knowledge/substrate-deferral.md	case count is unchanged \(([0-9]+)\)	expect:R11-03	\(([0-9]+) cases\)	contract bullet: census selftest total; R11-03 is [substrate], bound to its committed pin, never executed
KN-SUBSTRATE-ABSENCE-FILES-BAD	corpus/knowledge/substrate-deferral.md	\(files_ok=[0-9]+ files_bad=([0-9]+) 	expect:R18-01	files_bad=([0-9]+)	contract bullet: R18-01 all-GONE pin; [host] row, committed pin, never executed
KN-SUBSTRATE-ABSENCE-FILES-OK	corpus/knowledge/substrate-deferral.md	\(files_ok=([0-9]+) files_bad=[0-9]+ 	expect:R18-01	files_ok=([0-9]+)	zero-valued component of the same pin; catches a 0->1 doc mutation
```

### Why `expect:` and not `rows:` (both rows cannot be observed here)

- `R11-03` (`corpus/claim-ledger.tsv`, `bash corpus/surface-census.sh --selftest`,
  pin ``^SELFTEST: PASS \(16 cases\)``) carries `[substrate]`; `self-counts.py`
  refuses `ledger:` on it by design (`corpus/self-counts.py:255-261`) and
  `expect:` binds the doc to the committed pin without executing anything
  (`corpus/self-counts.py:342-350`). This is the same source already used for
  this exact number at `corpus/self-counts.tsv` `SC-CENSUS-SELFTEST` and
  `PV-SURFACE-SELFTEST`. The entry's own Erratum (lines 106-107) says current
  selftest totals are read from executed output and their migrated ledger pins,
  not the old sample count; `expect:` follows that instruction without claiming
  an execution.
- `R18-01` pins
  ``^DRIFT_PINS: DRIFT \(files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20\)$``
  at exit 1 and carries `[host]` (HOST-SKIP by default). The doc's number is the
  pin's verdict, not the raw baseline cardinality: `rows:corpus/drift-baseline.tsv`
  would read 15 today but would be the wrong quantity if the substrate ever
  returned partially (baseline stays 15, `files_bad` falls).

### Static corroboration (read, not executed)

- `corpus/surface-census.sh` builds exactly **16** counted case executions:
  12 `run_case` calls, 2 manual `sqlite-unavailable`/`fused-shape-row`
  increments, and the 2 verb increments in either branch (lines 768-847,
  `SELFTEST: PASS (%s cases)` at line 847). So line 44's 16 matches the code at
  BASE, not only the pin.
- `corpus/drift-baseline.tsv` has **15** data lines and
  `corpus/drift-symbols.tsv` has **20**; the all-GONE pin's
  `files_bad=15 symbols_bad=20` is arithmetically the whole baseline, which
  corroborates line 50 without observing the host.
- `R11-03`'s pin was already `16 cases` at the round-18 landing commit
  `fecee87` (`git show fecee87:corpus/claim-ledger.tsv`), so the sentence's
  "unchanged (16)" is true across the entry's own history. The count includes
  the two verb cases whether they execute or `skip-case`
  (`corpus/surface-census.sh:816-824`), which is why the pin is substrate-invariant.

## Excluded numbers, by rule (QM21 / R25-C6 / QM26)

| line(s) | number(s) | text fragment | class | why excluded |
|---|---|---|---|---|
| 3 | `2026-10-14` | "Source basis: host census re-run 2026-10-14" | date | dates the observation section; host measurement |
| 8 | `gone=23 absent=37`, `exit 1` | census DRIFT summary | host measurement | absent-substrate host reading; demoted by the Erratum (97-100); no lane-local source pins it |
| 9 | `files_bad=15 symbols_bad=20`, `exit 1` | drift-pins DRIFT summary | host measurement | same; the *value* coincides with R18-01's pin, but the sentence is a round-18 reading (F3) |
| 10 | `exit 2` x2, `failed=6`, `exit 1` | transcript/op-ref/checklist summaries | host measurement | same |
| 11 | `breadth_drift=6`, `exit 1` | scope-gate summary | host measurement | same |
| 21 | `Eleven` | "Eleven rows fell into that class on 2026-10-14" | dated finding count | explicit date in the same clause; not the current tag membership (F2) |
| 22 | `0`, `one` | "0 code changes could make them pass, because every one reads …" | dated, retracted | same date; the Erratum (104-105) calls the claim overbroad |
| 33, 77 | `both arms` | selftest proves/pins both arms | mechanism | no integer captured; no artifact-size source |
| 42, 93 | `two verb cases` | census selftest verb cases | mechanism count, unbindable | true (exactly `verbs-sandboxed`, `verbs-break-injection` at `corpus/surface-census.sh:822,824`), but no `rows:`/`ledger:`/`expect:` source pins the cardinality: R11-02's pin does not fix `skip=`, R11-03 fixes only the total 16 |
| 50 | `exit 1` | R18-01 verdict exit | verdict code | bound by the ledger's exit column, not a self-count; not an artifact size |
| 59, 65, 70, 74 | `1.`-`5.` | Bounds list markers | enumeration | not quantities |
| 61 | `one run` | "un-defers the rows in one run" | mechanism | no artifact size |
| 62 | `ONE file` | "presence+exec-bit of ONE file" | mechanism bound, word numeral | the detection contract; no count to bind |
| 67 | `round-18` | in-flight defect label | round label | history |
| 85, 111 | `95-97` / `95–97` | "cases 95-97 prove both arms"; Erratum quote | positional case index | out of population by rule, named by the round-22 clarification; stale as a *position* at BASE (F1) — replace with names |
| 13, 49 | `R18-01`, `R11-09` | reverify / pin references | row identifiers | ids, not counts |
| 95, 97, 108, 110, 112 | `round 22`, `round-18`, `round-22` path | Erratum headings/audit path | round labels | history |

Symbolic placeholders `deferred=N` (34-35, 59, 82) and `row_deferred=N`
(40-41) are not numbers.

## Findings and counterexamples

**F1 — the positional index is stale by position, and the entry's own demotion
does not replace it.** At the round-18 landing commit `fecee87` the three defer
cases were exactly cases 95/96/97 (97 counted calls total; script count over
`git show fecee87:corpus/claim-ledger.sh`). At BASE the same cases are
**119** `defer-substrate-absent`, **120** `defer-substrate-present`,
**121** `defer-substrate-line` (`corpus/claim-ledger.sh:1715-1717`), out of 170
counted calls — the same 170 in R11-09's pin, which validates the counting
model. At BASE, cases 95/96/97 are
`cells-lowercase-round-refused` (`:1689`), `cells-pre-movement-refused`
(`:1690`) and `docs-clean` (`:1693`). The count is deterministic: between the
counter reset (`:1551`) and the defer cases there are no `for`/`while`/`case`
constructs wrapping `tcase`, and the 170 call sites equal the pin exactly
(the loops at `:1760` and `:1763` are after the defer cases). The round-22
clarification (lines 110-113) correctly labels 95-97 historical, but it is a
separate paragraph with **no newer value beside the number**, so it is not a
QM21 history clause; and the number sits in the undated Reproduction block,
which the round-27 precedent treats as current (`claim-ledger.md:301-304`
"72" was corrected, not exempted). QM26's disposition for a positional index is
"excluded by rule and **named**", and QM26's own precedent renamed
`claim-ledger.md:81` "case 16" to `verdict-not-final`. The entry's own line 112
already says "Use named `defer-substrate-*` cases", so replacing the ordinals
completes an instruction the entry itself gives. Recommendation for the
Reproduction comment at line 85:
``bash corpus/claim-ledger.sh --selftest   # cases defer-substrate-absent|present|line prove both arms``.
This is a naming fix, not a new binding: an ordinal is not an artifact size and
cannot be captured by `self-counts.tsv`.

**F2 — "Eleven rows" must not be repaired to the current 11.** The sentence is
a dated class count (round 18). The class "rows measurable only on the
substrate" is now **12** rows by tag partition: 11 `[substrate]` rows plus the
single `[host]` row `R18-01` — the very absence pin the sentence's section is
about, which carries no substrate tag so that it must run
(`corpus/claim-ledger.tsv:48`; `rg -F -c '[substrate]'` = 11,
`rg -F -c '[host]'` = 1; `R18-02` pins `^11$`, `R24-13` pins the identity of the
eleven). Binding 11 to `R18-02` would equate two different memberships
(QM18/QM21). Leave the sentence dated and unbound.

**F3 — a naive locator would be ambiguous.** `files_bad=15` occurs on line 9
(host reading) and line 50 (pin text). `files_bad=([0-9]+)` alone is
`AMBIGUOUS` under `corpus/self-counts.py:332-336`; the proposed locator carries
the `(files_ok=` prefix so only line 50 matches (verified: one hit). Line 9
must stay unbound.

**F4 — `expect:` binds the doc to the ledger, never to the host.** Neither
`R11-03` (`[substrate]`) nor `R18-01` (`[host]`) was executed: the contract
forbids gate/selftest runs and both rows are default-deny. I closed the *code*
gap statically for 16 (16 case executions at BASE) and the *arithmetic* gap for
15/0 (15 baseline files, all-GONE pin). I did **not** observe a host verdict, so
these bindings are "Pinned=OK", not "live host measured". If the substrate
returns, `R11-03`/`R18-01` fail loudly by design and the pins move under QM14;
until the pins are migrated, the binder will keep reporting these doc numbers
`OK` against the old pins — a declared limit of `expect:`, not a pass.

**F5 — the zero component is worth its own row.** `files_ok=0` is bound
separately so a `0 -> 1` doc mutation is caught. If L1 prefers nonzero counts
only, dropping `KN-SUBSTRATE-ABSENCE-FILES-OK` leaves that digit unbound —
record it as a gap rather than deleting it silently.

**F6 — citation check (not a number).** The Erratum's audit pointer resolves at
BASE: `.ufo/waves/round-22/build/Entry20.md` exists (15 468 bytes). Unlike the
round-27 `credential-isolation.md:120-122` pointer, this one is not dangling.

## Integration notes for L1

1. Adding these 3 rows moves the table from 56 to **59** data rows at the
   current candidate. `R25-02` is already migrated `38 -> 56` (working-tree
   `corpus/claim-ledger.tsv`); it must move again to
   ``^SELF_COUNTS: CLEAN \(claims=59 stale=0\)$`` and its note "+ 18 KN-* …
   -> 56" to "+ 21 KN-* … -> 59".
2. Suggested header-comment addition beside the round-27 block in
   `corpus/self-counts.tsv`:
   `# corpus/knowledge/substrate-deferral.md: 3 bound. Excluded by rule, named:`
   `# dated 2026-10-14 host census/gate figures (3-11, 21-22), positional`
   `# "cases 95-97" (85; current 119-121 — use case names), word numerals`
   `# ("two verb cases", "ONE file", "both arms"), exit codes, deferred=N symbols.`
3. Red control after integration: `c1-measure.py --mutate` on either
   `KN-SUBSTRATE-CENSUS-SELFTEST` (16->17) or
   `KN-SUBSTRATE-ABSENCE-FILES-BAD` (15->16) must turn exactly that id STALE;
   the locators are unique per line, which `--mutate` requires.

## What I did NOT check (unrun is not a pass)

- I did not run `corpus/self-counts.py`, `c1-measure.py`, any selftest, gate,
  or ledger row. Locator uniqueness was tested with stdlib `re` in a scratch
  harness; binder `STALE`/`AMBIGUOUS` behaviour is read from
  `corpus/self-counts.py:306-358`, not observed.
- I did not execute `R11-03` or `R18-01`, and made no measurement of this host's
  substrate. The six "(absent)" paths and the six gate summaries at lines 8-11
  were not re-read from the host (out of population and out of contract bounds).
- I did not verify the round-18 figures' original accuracy beyond the commit
  that landed them; I did not reconstruct the round-18 selftest output.
- I did not check other knowledge entries, `SKILL.md`, `PROVINCE.md` or
  `corpus/README.md`; other seats own those populations.
- I did not review the C2 release-clock change. Noted only in passing: the
  working tree carries the round-27 candidate (`release-clock.py`,
  `R25-03` 67->73, `R12-03` 89->90, `R21-02` 41->43, an untracked
  `corpus/__pycache__/rendered-text-v1.cpython-314.pyc`); none of it is
  adjudicated here.
