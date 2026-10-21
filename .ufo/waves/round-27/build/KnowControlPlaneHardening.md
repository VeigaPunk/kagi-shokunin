# KnowControlPlaneHardening — C1 inventory, `corpus/knowledge/control-plane-hardening.md`

**Seat:** `KagiR26.KnowControlPlaneHardening-17` (leaf; no dispatch, no production edits)
**BASE:** `0a47dd189356ea66ec83c3891eed54526e95b89b` (`git rev-parse HEAD` == BASE)
**Target:** 200 lines, 11,558 bytes, sha256 `a259b7d266d9e8930b8b7ff5466d25e6fe4261ccd92e50f6dbe707007b116907`.
Worktree file == `git show 0a47dd18:corpus/knowledge/control-plane-hardening.md` (same sha256);
`git status --porcelain` for the file empty; stamp row `corpus/stamps.tsv:33` carries the same
sha/lines/bytes.
**Method:** reads, `grep`/`sed`/`wc`/`sha256sum`, and committed pins only. No gate, selftest,
ledger row, build, linter, formatter or host probe was executed. No host file was read:
`test -e ~/.local/bin/the-janitor` and `test -e ~/.config/the-janitor/client.py` are both false
on this host (matching `PROVINCE.md:10-11`, the round-18 substrate-absence erratum). No tool
installs.

**Working-tree vs BASE.** The four knowledge files cited for content
(`control-plane-hardening.md`, `credential-isolation.md`, `janitor-lifecycle.md`,
`config-layering.md`) are byte-identical to BASE (sha256 checked). Two control files are not:
`corpus/QUALITY.md` is modified by this wave's live integration (QM26 was extended; `:133` cites
the current text), `corpus/self-counts.tsv` is being extended live (`M`; the `KN-*` total moved
18→22 while this seat read it), and `plans/round-27.md` is untracked (this round's plan).
`corpus/stamps.tsv` is modified elsewhere, but row 33 for this entry is unchanged.

## Verdict

1. **Zero bindable current-tense numbers.** No `KN-*` row for this entry can be written with the
   binder's three source kinds. I did not invent one. The `KN-*` block was 18 rows over 7 entries
   at my first read and 22 over 8 at my last read — the integration is extending `self-counts.tsv`
   live (`git status --porcelain` shows `M corpus/self-counts.tsv`) — but it has **0** rows for
   this file in every read (`grep -c control-plane-hardening` → `0`).
2. **Six lane-repo section-span citations are current-voice numbers** (line citations about three
   lane-owned knowledge files), and **four of the six sites are wrong at BASE** — three distinct
   spans:
   `credential-isolation.md L37–51` is stale by +2; `janitor-lifecycle.md L18–21` never covered the
   non-purge clause; `config-layering.md L66–73` is cited twice for evidence that sits at L24–46
   (and the agent-selection qualifier at L77–80). `L14–44` and `L16–44` are OK.
3. The credential-isolation and lifecycle pointers were found in round 22
   (`Entry08.md:130-145`, `Entry14.md:96-104`) and are **still present at BASE**, with only a
   generic erratum more than 160 lines below (`control-plane-hardening.md:186-198`). That is
   exactly QM26's named weak signal — "a correction note elsewhere instead of a history clause
   beside the number" (`corpus/QUALITY.md:133`) — and the reason "no bindable source" must not be
   read as "no stale number". A binder that reports this entry CLEAN would be reporting the
   absence of a source kind, not the absence of drift.
4. **Two host-code bounds (`120 × 0.5`, `3600`) are current-voice** properties of absent host
   bytes (lines 66, 69). They are outside the population by source kind and by the assignment's
   host/substrate exclusion, but the entry's erratum covers "handler and client line citations",
   not code constants; a strict QM1 reader can call them unmarked current assertions. No committed
   pin holds either value.
5. **A freshness attribution is false at BASE.** Line 11 says the retention block is re-measured
   by `R11-01`. `R11-01` is `bash corpus/surface-census.sh` `[substrate]`
   (`corpus/claim-ledger.tsv:15`); its DB rows assert *floors* `session:2`, `message:13`,
   `part:18`, `event:79` (`corpus/state-shape.tsv:32-35`), not the entry's `7/39/55`. The entry's
   own erratum says the opposite at line 190 ("neither a byte pin nor a deferred R11-01 checks the
   exact retention counts"), but the parenthetical remains.

OBSERVED for file content and pins; INFERENCE for the population ruling and proposed fixes.

## Population rule applied

- Current = present tense, states a lane artifact's size/position, no newer value in the same
  clause; an explicit history clause ("N at round K", a dated measurement) is out
  (`corpus/QUALITY.md:118` QM21; `corpus/lessons/round-25.md:49-58` R25-C6).
- The round-27 build population is "current-tense numbers in `corpus/knowledge/*.md` about this
  lane's own artifacts … that have a lane-local source", excluding dated measurement sections,
  Evidence/Erratum/Round-N history, host/substrate observations, positional case indexes and
  numbers with no lane-local pinned source (`corpus/self-counts.tsv:53-57`;
  `corpus/lessons/round-27.md:37-47`; QM26 `corpus/QUALITY.md:133`).
- **Section-span citations.** I treat `L14–44` and the like as current-voice numbers about a
  lane-owned file for three reasons: the assignment names "file/line counts of lane-owned files"
  as population; this entry's own erratum treats `L37–51` as a numeric span needing correction
  (`:194-196`); and the stale spans misdirect a reader today. A span has no *admissible* source
  kind (`rows:` counts nonblank/non-comment lines, it cannot select a section endpoint;
  `ledger:`/`expect:` are whole-row totals), so under a literal source-kind reading these fall
  out of the population. I record that gap explicitly rather than letting it hide the drift. The
  exclusion "numbers with no lane-local pinned source" is aimed at values no committed artifact
  defines (the `OP_REF_PROBE checks=44` example); a section span *is* defined by the lane file's
  own bytes, just not by a scalar column. If the L1 reads the exclusion literally, these six
  citations leave scope — and the two stale ones become unfixable by C1, which is itself the
  finding rather than a resolution.
- **Erratum-conceded numbers stay in scope.** The live QM26 row (working tree
  `corpus/QUALITY.md:133`, extended by this wave's integration) states: "A number an erratum
  concedes stays in scope where the body states it: a once-true value keeps its history clause
  beside the current one; a never-true value is marked misstated." This is the rule applied
  below: the credential span is **once-true** (correct at authoring, shifted +2), the lifecycle
  span is **never-true** (`Entry14.md` F2), and the `config-layering.md L66–73` span is
  **misstated** (the cited evidence was never there per that entry's own erratum map).
- Host line spans (`the-janitor`, `client.py`) are excluded per the assignment ("host measurements
  of absent substrate") and by the entry's erratum (`:186-188`). They are listed anyway in §5 so
  the digit census is complete.

## 1. In-population candidates

### 1a. Lane-repo section spans (current-voice, lane-owned files)

Locators were tested with a private Python check: exactly one capture group, exactly one matching
line each, on the file at BASE. They are proposals for a span-capable binder, not existing rows.

| id | line | exact text (fragment) | defining live source | live value at BASE | verdict | locator |
|---|---|---|---|---|---|---|
| S1 | 29 | ``loaded global agents/plugins: `corpus/knowledge/config-layering.md` L14–44,`` | none of `rows:`/`ledger:`/`expect:` (section span); live source is the cited file's layout | `config-layering.md:14` `## The layers`, `:16` table header, `:24-44` leak bullets, `:44` end of the plugin bullet. The sentence's subject is covered; the merge mechanics (`:8-12`) sit outside the span | **OK** | ``^loaded global agents/plugins: `corpus/knowledge/config-layering\.md` L14–(\d+),`` |
| S2 | 30 | `L66–73; current prompt boundary:` | none (section span) | `config-layering.md:66-67` end of the inert-decoy section, `:68` `## Isolation is the permission ceiling, not the config boundary`, `:70-75` sharpened form + env scrub. It does **not** carry "loaded global agents/plugins" (that is `:24-46`) | **STALE (misstated)** | `^L66–(\d+); current prompt boundary:` |
| S3 | 31 | `L37–51.)` | none (section span) | Intended 15 lines are now `credential-isolation.md:39-53` (`:39` heading `## Agent permissions are deny-all + one tool`, through `:53` "no unrelated work"); `:37` is the `status`/fallback bullet, `:51` is mid-invariant. Shift is +2 from `2486643` inserting the `Reverify` block at `:7` (recorded at `.ufo/waves/round-22/build/Entry08.md:130-145`) | **STALE (+2, once-true)** | `^L37–(\d+)\.\)$` |
| S4 | 91 | `` `corpus/knowledge/janitor-lifecycle.md` L18–21)`` | none (section span) | `janitor-lifecycle.md:18` header, `:19` separator, `:20` `client.lock`, `:21` `session-id`; the non-purge DB row is `:24`. The range never included it even at authoring (`51c9d30`), per `.ufo/waves/round-22/build/Entry14.md:96-104`; correct range `L18–24` or `L24` | **STALE (never-true)** | ``^`corpus/knowledge/janitor-lifecycle\.md` L18–(\d+)\)\.$`` |
| S5 | 115 | `L16–44, L66–73). Put only the handler's required configuration in the` | none (section span) | `config-layering.md:16-44` runs table header through the plugin bullet and covers "inherits global agents and plugins" | **OK** | `^L16–(\d+), L66–73\)\. Put only` |
| S6 | 115 | same line, second span `L66–73` | none (section span) | Same misalignment as S2. The sentence's own support is the round-7 qualifier at `config-layering.md:77-80` ("a local process posting `agent: <permissive-global>` runs tools in the daemon env"); the cited span stops at 73, four lines before it | **STALE (misstated)** | `^L16–44, L66–(\d+)\)\. Put only` |

Note S2/S6 cite the same span at two sites; `config-layering.md`'s own erratum maps original
`:24-46` to "resolved dump" and `:68-81` to "permission ceiling"
(`corpus/knowledge/config-layering.md:116-118`), so `L66–73` was not the leak evidence under
either numbering. The two sites also use different starts for the same section (`L14–44` vs
`L16–44`), an inconsistency in hand-selection even though both cover the table. Line 115 carries
two *different* spans, so QM26's "repeated copies … tied with a backreference" rule does not
apply; S5 and S6 each anchor their own copy by the following literal (`L16–44,` vs
`L16–44, L66–`).

### 1b. Host-code bounds (boundary cases: named by "bounds", OUT by source kind)

| id | line | exact text (fragment) | defining live source | live value | verdict | locator |
|---|---|---|---|---|---|---|
| B1 | 66 | `retries for up to 120 × 0.5 seconds and then reports its misleading` | absent `~/.local/bin/the-janitor`; `corpus/drift-baseline.tsv:1` pins 333 lines + sha, `corpus/drift-symbols.tsv` has no retry-window row | not observable (host absent) | **OUT (host/substrate)**; erratum covers "line citations", not code constants | `retries for up to (\d+) × 0\.5 seconds` |
| B2 | 69 | `3600 seconds). Long/hung requests therefore delay` | absent `~/.config/the-janitor/client.py`; `corpus/drift-symbols.tsv:18` pins `client.py:74 THE_JANITOR_REQUEST_TIMEOUT` (corroborates the L74 pointer, not the value); `drift-baseline.tsv:2` pins 117 lines | not observable (host absent) | **OUT (host/substrate)** | `^(\d+) seconds\)\. Long/hung requests therefore delay` |

No committed pin holds `120` or `3600`; `expect:R11-04` captures only `files=`/`symbols=`
(`corpus/claim-ledger.tsv:18`). The nearest lane-local facts are the file line counts (333/117)
and one symbol line, none of which is the bound.

## 2. Binding rows (`corpus/self-counts.tsv` format) — none

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| _(no rows: empty bindable population)_ | | | | | |

Why an id would be padding, not calibration:

- `rows:<repo>` counts nonblank, non-comment lines (`corpus/self-counts.py:10`, `:88-90`). The
  cited files' data-line counts at BASE are `config-layering.md` 102, `credential-isolation.md`
  54, `janitor-lifecycle.md` 60 — none equals any cited endpoint (44, 73, 51, 21, 16, 14).
- `ledger:R11-01` (`corpus/claim-ledger.tsv:15`) returns a `SURFACE_CENSUS` summary
  (`assets=`, `runtime=`, `scanned=`, `ok=`), and `R11-04` (`:18`) returns `files=`/`symbols=`.
  Neither is a span or a bound.
- `expect:` reads the committed expect column of those same host rows; both are `[substrate]` and
  carry no retention/span value.
- A span row would need a new source kind (for example `lines:<repo file>` with a heading or
  endpoint extract) or a new ledger row. The cheaper and drift-proof fix is to cite headings and
  leave this entry with no numeric spans at all (§6).

The stale spans are therefore outside the binder *by representation*, not because their
values are correct.

Counting commands used (read-only, at BASE):

```bash
wc -l < corpus/knowledge/control-plane-hardening.md                      # 200
grep -c '^KN-' corpus/self-counts.tsv                                    # 18 first read / 22 last read
awk -F'\t' '/^KN-/{print $2}' corpus/self-counts.tsv | sort -u | wc -l   # 7 first read / 8 last read
grep -c 'control-plane-hardening' corpus/self-counts.tsv                 # 0
python3 -c 'import sys
for f in sys.argv[1:]:
    print(f, sum(1 for l in open(f) if l.strip() and not l.lstrip().startswith("#")))' \
  corpus/knowledge/config-layering.md corpus/knowledge/credential-isolation.md \
  corpus/knowledge/janitor-lifecycle.md                                  # 102 54 60
grep -c 'corpus/knowledge' corpus/release-clocks.tsv                     # 0
```

## 3. Stale citation detail

### 3a. `credential-isolation.md L37–51` (entry line 31) — once-true, stale by +2

`credential-isolation.md:7` now carries `Reverify: R11-01, R11-04`; `2486643` inserted that block
plus a blank line, shifting content below by +2 (recorded with the exact old/new and a hash
migration at `.ufo/waves/round-22/build/Entry08.md:133-145`). At BASE:

- `:37` is the status/`fallback disabled` bullet, not the heading.
- `:39` is the heading `Agent permissions are deny-all + one tool`.
- `:49-53` the agent invariants; `:51` is mid-list.
Thus the cited span starts two lines above the heading and stops two lines before the section
ends. The entry's erratum (`:194-196`) names the defect generically and says "use its **Agent
permissions** heading instead", but the number is still printed as current at line 31 and no new
value appears anywhere in the entry. This is QM26's weak signal verbatim; the entry's own erratum
is 163 lines away. Under the live QM26, a once-true value keeps its history clause *beside the
current one*; this one has neither a current value beside it nor a corrected number.
`Entry08.md:142-145` already proposed `L37–51 → L39–53` or the heading.

### 3b. `janitor-lifecycle.md L18–21` (entry line 91) — never-true for the second clause

The sentence has two clauses: `stop` removes `session-id`, and `stop` does not remove the
transcript DB/log. At BASE `janitor-lifecycle.md:18-21` is header/separator/`client.lock`/
`session-id`; the non-purge row is `:24`. `Entry14.md:99-104` measured that the range never
included the DB row even at `51c9d30` (where the DB row was L22) and gives the correct range
`L18–24` or `L24`. `AttackEntry14.md:79-90` records that the round-22 erratum acknowledged this
only generically and "the stale numeric pointer itself is left in place". The entry's erratum
`:196-197` says only "spans more lines than the old helper range alone" — no value, no new range.
Under QM26 a never-true value is marked misstated; this one is not marked, and the stale number
remains.

### 3c. `config-layering.md L66–73` (entry lines 30 and 115) — misstated at both sites

At BASE `:66-67` is the tail of the inert `config.json` decoy, `:68` is
`## Isolation is the permission ceiling, not the config boundary`, `:70-75` is the sharpened
"containment comes from `enabled_providers` + the last-match permission deny + `tools` map" and
the env-scrub paragraph. The sentence at line 29 cites it for "Config merge and loaded global
agents/plugins"; the sentence at line 114 cites it for "inherits global agents and plugins".
Neither claim lives there. The evidence is `:24-46` ("What leaked in": 9 providers, 23 agents,
56 permission rules, plugin load). The *opposite* clause — that the ceiling does not prevent
selecting another loaded agent — is supported only at `:77-80`, which the span does not reach.
`config-layering.md`'s own erratum qualification (`:116-118`) assigns `24-46` to the resolved
dump and `68-81` to the permission ceiling, confirming `66–73` was never the leak evidence. No
round-22 audit covers this span (`grep` over `.ufo/waves/round-22/build` and `falsify` for
`66–73`/`L16–44`/`L14–44` → no hits), so it is an unrecorded calibration defect as well. Under
QM26 it is misstated rather than once-true: the repair is a corrected pointer or a heading, not a
history clause.

## 4. Freshness (C2 and recheck)

- **No release clock.** `corpus/release-clocks.tsv` has zero rows whose subject is a knowledge
  entry (`grep -c 'corpus/knowledge'` → `0`) and no row mentions this entry. There is no numeric
  anchor, so the C2 `REGRESSED` rule has nothing to order here; this entry cannot fire a release
  event and cannot be rearmed without a new source row. That is not a defect, but it means the
  entry's only freshness mechanism is the by-hand recheck.
- **The by-hand recheck cannot fire.** Line 11 declares
  `Reverify: by-hand: control-plane-scratch`; the measurement needs scratch `serve` replicas,
  which require the absent substrate. `Entry07.md:60-66` already measured the host absence
  (`the-janitor`, `client.py`, state dir all ENOENT). The declaration is honest deferral, not a
  pass, and it cannot update the entry. This is the mechanism by which two known-stale spans
  survived four rounds.
- **C2 analogue (informational).** The credential span moved from valid (L37–51) to invalid
  (the content is now L39–53) after a two-line insertion: a numeric observation that no longer
  equals its anchor. The binder has no source kind that can type this as a finding, and the entry
  has no release clock that would order it. Citing headings removes the anchor entirely, the
  pointer equivalent of a check that cannot silently regress. I did not execute or modify
  `corpus/release-clock.py`; the C2 implementation itself is outside this seat.
- **`R11-01` overclaim persists.** Line 11's "retention block is re-measured by R11-01" is false
  as scoped: `R11-01` is `bash corpus/surface-census.sh` `[substrate]`
  (`corpus/claim-ledger.tsv:15`); the DB assertions are shape floors
  (`corpus/state-shape.tsv:27-35`): `mode 600`, `size_min 1`, `tables_min 12`,
  `rows_min session:2 message:13 part:18 event:79`. The notes record "observed 7/39/55", but the
  assertions are floors, not the values. `Entry07.md:99-109` routed this as a pointer overclaim;
  the erratum at `:190` states the correction, yet line 11 still asserts the opposite. Two
  sentences in one entry now contradict each other.
- **Erratum coverage is narrower than the numbers.** `:186-188` marks "host inspection, OpenCode
  version, handler and client line citations, retention quantities and scratch-server outcomes"
  historical. The retry window (`:66`) and request timeout (`:69`) are code constants, not listed;
  a strict QM1 reading treats them as unmarked current-voice assertions about an absent file.
  Because the substrate is absent, widening the erratum is the only honest repair — the values
  cannot be re-measured here.

## 5. Excluded numbers — complete digit census

Every line of the entry carrying a digit token is accounted for. Lines 29–31, 66, 69, 91 and
115 are inventoried in §1 (the in-population candidates); this table covers the excluded
remainder. "OUT" means excluded by the stated rule, not judged correct.

| line(s) | token(s) | class | ruling |
|---|---|---|---|
| 3 | `2026-09-28` | date of the source basis | OUT: dated measurement (R25-C6; assignment excludes a dated source basis) |
| 4 | `72–75`, `92–118`, `121–135` | host line spans (`the-janitor`) | OUT: property of absent host substrate; erratum `:186-188`; `test -e` false |
| 5 | `173–184`, `186–226` | host line spans (`the-janitor`) | OUT, same |
| 6 | `22–38`, `67–95`, `98–100` | host line spans (`client.py`) | OUT, same |
| 8, 16 | `1.18.31` | OpenCode vendor version | OUT: vendor fact |
| 11 | `R11-01` | claim-ledger id | OUT: identifier, not a count; the pointer overclaim is reported in §4 |
| 15, 124, 161 | `127.0.0.1` | address literal | OUT: not a count |
| 21, 58, 65, 75 | `401` | HTTP status observed/expected on scratch | OUT: dated observation, not a count |
| 35, 78, 107, 122 | `1.`, `2.`, `3.`, `4.` | section ordinals | OUT: headings, not counts |
| 39 | `0600` | proposed password-file mode | OUT: mode, not a count |
| 42 | `L7`, `L228–249` | host line span + single line | OUT: absent host. Near-miss: `L248` is pinned by `corpus/drift-symbols.tsv:30` (`exec op run --env-file=…`), corroborating the `op run` claim; endpoints unpinned |
| 53, 155, 172 | `base64` | code identifier | OUT |
| 60 | `L92–118`, `L41–64`, `L98–100` | host line spans | OUT: absent host |
| 70 | `L103–118`, `L129–134`, `L74` | host line spans | OUT: absent host. Near-miss: `L74` pinned by `drift-symbols.tsv:18` |
| 82 | `9,240,576`, `0600` | host DB size + mode; past tense ("was") | OUT: host measurement of absent substrate; explicit assignment exclusion; erratum `:186-192` |
| 83 | `7`, `39`, `55` | host DB row counts; past tense | OUT: same. `state-shape.tsv:32-34` records "observed 7/39/55" as notes but asserts floors 2/13/18 |
| 90 | `L173–184`, `L190–225` | host line spans | OUT: absent host |
| 102 | `L28–43` | host usage span | OUT: absent host |
| 109 | `round-6` | round id | OUT: round label, not a count |
| 110 | `OPENCODE_DISABLE_PROJECT_CONFIG=1` | env literal | OUT |
| 129 | `0600` | hypothetical password-file mode | OUT |
| 142, 144, 145 | `sqlite3` | binary name | OUT |
| 146 | `GROUP BY 1` | SQL literal | OUT |
| 150 | `200` | observed status, dated scratch | OUT |
| 151 | `401`, `200` | expected statuses | OUT |
| 154 | `python3` | interpreter name | OUT |
| 161 | `127.0.0.1` | address literal | OUT |
| 184 | `round 22` | round id | OUT |
| 190 | `R11-01` | claim-ledger id | OUT; the contradiction with `:11` is reported in §4 |
| 199–200 | `round-22`, `Entry07`, `Entry08` | round id + audit filenames | OUT |

Lines not listed carry no digit token. Line 11's `R11-01` is the only identifier whose *claim*
(not its number) is a live defect.

## 6. Proposed corrections (advisory to the L1 integrator)

No production edit was made. The cheapest fix removes the unbindable numbers rather than adding a
source kind for spans.

- **P1 — credential span.** Replace `L37–51` at line 31 with the heading
  `§Agent permissions are deny-all + one tool` (the entry's own erratum already instructs this).
  If a number is preferred, `L39–53` plus a beside-the-number history clause
  (L37–51 before the round-22 +2 insertion; see `Entry08.md` §4b). The heading is drift-proof and
  leaves nothing for a future binder to miss.
- **P2 — lifecycle span.** Replace `L18–21` at line 91 with the heading
  `§The state objects and what revoking them means` (`janitor-lifecycle.md:16`), or cite `L24`
  for the non-purge row (`Entry14.md:104` gives `L18–24`). The heading covers both clauses; record
  the old span as misstated (it never covered the DB row).
- **P3 — config-layering spans.** Replace `L14–44, L66–73` (line 29) and
  `L16–44, L66–73` (line 115) with headings `§The layers`, `§What leaked in (proven, resolved
  dump)`, and — for the agent-selection clause — `§Isolation is the permission ceiling, not the
  config boundary`
  (whose `:77-80` carries the qualifier). If numbers are kept, `L24–46` + `L77–80` is the
  corrected pair; headings avoid the next shift. Either way mark the old `L66–73` span misstated,
  not a history clause.
- **P4 — erratum coverage.** If the code constants stay, add "code constants (readiness retry
  window, request timeout)" to the `Source-status: historical` enumeration at `:186-188`, or add
  an inline `(read 2026-09-28)` at `:66`/`:69`. Do not add a binder row: the values cannot be
  measured on this host.
- **P5 — R11-01 pointer.** Replace line 11's "though the retention block is re-measured by R11-01"
  with "R11-01 asserts shape floors only; the exact retention counts are unmeasured" (or delete
  the clause). Keep the erratum's `:190` statement as the authority.
- **P6 — landing duties.** Any edit changes the stamp: re-pin `corpus/stamps.tsv:33` in the same
  commit and record old/new in `.ufo/waves/round-27/knowledge-migrations.json` (QM5/QM14). Current
  row: `a259b7d2…b116907`, 200 lines, 11,558 bytes. If P1–P3 land, this entry's numeric-span
  population becomes structurally empty, which is a stronger result than a CLEAN binder over an
  empty source set.

## 7. What I did NOT check

- **No gate or binder run.** `corpus/self-counts.py` and every ledger row were read, not executed.
  "STALE"/"OK" here is a direct file read plus committed-pin comparison, not a `self-counts`
  verdict. The locators were tested for one-group/one-line uniqueness with a private Python check,
  not by the binder.
- **No host bytes.** `the-janitor`/`client.py` were not read; only `test -e` (both false). The host
  line spans' contents, the `120 × 0.5` loop and the `3600` default are unverified. No
  `op`/handler/tmux/vault/CDP contact and no service start.
- **Round-22 audit conclusions are cited, not reproduced.** I did not re-run the `git show`/`sed`
  commands in `Entry08.md`/`Entry14.md`; I independently confirmed their key claims against BASE
  (`credential-isolation.md:37-53`, `janitor-lifecycle.md:18-24`).
- **Other entries.** I did not review the remaining knowledge entries (the lane declares 25,
  `corpus/claim-ledger.tsv:32`; I read this one plus the three it cites), so I make no claim about
  whether section-span drift is typical or isolated.
- **Host span bounds only.** I checked that the cited host line numbers are within the committed
  line counts (`333` and `117`, `drift-baseline.tsv:1-2`) and that two key lines match
  `drift-symbols.tsv` (`:18`, `:30`); I did not verify the rest.
- **Domain/vendor claims.** I did not evaluate the entry's OpenCode behavior, auth outcomes,
  alternate-agent repro, retention conclusion or rollout advice; no `recheck:`/QA4 schema audit
  beyond noting that there is no release clock.
- **Audit-file currentness.** `Entry07.md`/`Entry08.md`/`Entry14.md` are history and were read as
  such; I did not re-pin or re-stamp them.

## 8. Evidence index (BASE)

- `corpus/knowledge/control-plane-hardening.md:3-11` (source basis, recheck), `:29-31`
  (config/credential citations), `:66`, `:69` (bounds), `:82-83` (retention), `:91` (lifecycle
  citation), `:115` (config citation), `:186-198` (erratum).
- `corpus/knowledge/credential-isolation.md:7` (`Reverify` insertion), `:37-53` (span vs intended
  section).
- `corpus/knowledge/janitor-lifecycle.md:16-24` (table and DB row).
- `corpus/knowledge/config-layering.md:8-12`, `:14-46`, `:66-75`, `:77-80`, `:111-120`.
- `corpus/stamps.tsv:33`; `corpus/claim-ledger.tsv:15`, `:18`; `corpus/state-shape.tsv:27-35`;
  `corpus/drift-baseline.tsv:1-2`; `corpus/drift-symbols.tsv:18`, `:30`;
  `corpus/self-counts.tsv:53-57`; `corpus/self-counts.py:10`, `:88-90`;
  `corpus/QUALITY.md:118`, `:133`; `corpus/lessons/round-25.md:49-58`;
  `corpus/lessons/round-27.md:37-47`, `:86`; `plans/round-27.md:9-22`.
- `.ufo/waves/round-22/build/Entry07.md:60-66`, `:99-109`; `Entry08.md:130-145`;
  `Entry14.md:96-104`; `.ufo/waves/round-22/falsify/AttackEntry14.md:79-90`.
