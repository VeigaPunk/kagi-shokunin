# KnowAdjacencyScope — C1 inventory of `corpus/knowledge/adjacency-scope.md`

Lane `kagi-shokunin`, frozen BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Target: `corpus/knowledge/adjacency-scope.md` (326 lines). The entry, `corpus/adjacency.tsv`
(84 lines), `corpus/surface-census.tsv` (55 lines), `corpus/scope-gate.sh` (1130 lines) and
the R16/R17/R11-11 rows of `corpus/claim-ledger.tsv` are byte-identical to BASE (checked with
`git show BASE:<path> | sha256sum`). `corpus/self-counts.tsv` and `corpus/claim-ledger.tsv` are
dirty in the working tree (in-flight round-27 C1/C2 work): BASE has **0** `KN-` rows; the
working tree has 18, five of them for this entry (`corpus/self-counts.tsv:60-64`). All pins
quoted below are the **BASE** pins; "bound" means bound by those in-flight rows.

Population rule applied: QM21 (`corpus/QUALITY.md:118`), R25-C6
(`corpus/lessons/round-25.md:49-58`), QM26 (`corpus/QUALITY.md:133`), plan C1
(`plans/round-27.md:9-19`). A number is current when it states an artifact's present size and
no newer value sits in the same clause. Out by rule: explicit history clauses, dated
measurement sections, Evidence/Erratum text, host/substrate observations, positional indexes,
schema/exit codes, and numbers with no lane-local source.

## Result

- **56 current-tense in-population number occurrences**, all **OK** at BASE (value equals the
  defining source).
- **5 covered** by in-flight rows (`corpus/self-counts.tsv:60-64`), **51 uncovered**.
- **0 STALE** in this entry: the round-25 stale numbers are in other entries
  (`corpus/lessons/round-27.md:49-53`), not here.
- **18 further numeric occurrences are out of population** with the causes named below.
- No C2 item: this entry states no release/version anchor. The only version-like token,
  `v2` at `:3`, is a schema generation, not a vendor release.

Caveat on "OK": values were compared to data-file counts, non-host ledger pins or committed
`expect:` pins. `--selftest`/`--falsify`/the gate were **not executed** (lane contract), so
the selftest/mutation counts are corroborated statically only (below).

## A. Already covered (in-flight rows), all OK

| line | exact text | source | pinned value | verdict | locator |
|---|---|---|---|---|---|
| 16 | `SCOPE_SELFTEST: PASS (61 cases)` | `ledger:R16-02` | 61 | OK | `^breadth_unverified=0\)`; `SCOPE_SELFTEST: PASS \(([0-9]+) cases\)` |
| 17 | `caught=18/18` (caught) | `expect:R16-03` | 18 | OK | ``^`SCOPE_FALSIFY: PASS \(caught=([0-9]+)/`` |
| 155 | `SCOPE_SELFTEST: PASS (61 cases)` | `ledger:R16-02` | 61 | OK | ``^\| `SCOPE_SELFTEST: PASS \(([0-9]+) cases\)` /`` |
| 155 | `caught=18/18` (caught) | `expect:R16-03` | 18 | OK | ``^\| `SCOPE_SELFTEST: PASS \([0-9]+ cases\)` / `SCOPE_FALSIFY: PASS \(caught=([0-9]+)/`` |
| 269 | ``--falsify`` runs 18 mutations | `expect:R16-03` | 18 | OK | ``^Every listed defect turns the gate red; `--falsify` runs ([0-9]+) mutations`` |

Source kinds are legal under `corpus/self-counts.py`: `R16-02` is a scratch-tree selftest
(non-host, `ledger:`); `R16-03` carries `[substrate]` (`corpus/claim-ledger.tsv:41`), so it must
be `expect:` and is never executed.

## B. Uncovered current numbers — proposed bindings (51)

Doc column is constant: `corpus/knowledge/adjacency-scope.md`. Every locator below was
verified against BASE text: exactly one matching line, line number as stated, capture equals
the pin. Extract is applied to live stdout for `ledger:` rows, to the committed pin for
`expect:` rows, and is `-` for `rows:`. One table; rows at `:13-16`/`:17`/`:147`/`:155`
annotated with `V` are verdict/finding counters (a strict "artifact size" reading may drop
them, but then a one-digit edit to those fields is unguarded).

```
id	line	exact text	source	extract	pin	verdict	locator
KN-SCOPE-SRC-OWN	4	5 `# own` prefixes	ledger:R16-04	^([0-9]+)$	5	OK	^`corpus/adjacency\.tsv` \(([0-9]+) `# own` prefixes
KN-SCOPE-SRC-GROUPS	4	4 group rows	rows:corpus/adjacency.tsv	-	4	OK	^`corpus/adjacency\.tsv` \([0-9]+ `# own` prefixes, ([0-9]+) group rows
KN-SCOPE-SRC-SHARED	4	the 8 census rows outside them	expect:R16-01	shared=([0-9]+)	8	OK	group rows covering the ([0-9]+) census$
KN-SCOPE-SRC-OWNERS	5	4 `# owner`	expect:R16-01	owners=([0-9]+)	4	OK	rows outside them, ([0-9]+) `# owner`
KN-SCOPE-SRC-NOENUM	5	8 `# no-enumerate` (digit at :5, word at :6)	ledger:R16-06	^([0-9]+)$	8	OK	`# claim` / ([0-9]+)$
KN-SCOPE-SRC-BREADTH	6	4 `# breadth` directives	ledger:R17-02	^([0-9]+)$	4	OK	^`# no-enumerate` / ([0-9]+) `# breadth` directives
KN-SCOPE-SRC-CENSUS	7	35 rows	rows:corpus/surface-census.tsv	-	35	OK	^`corpus/surface-census\.tsv` \(([0-9]+) rows
KN-SCOPE-GATE-CENSUS	12	census=35	rows:corpus/surface-census.tsv	-	35	OK	^\(census=([0-9]+) owned=27
KN-SCOPE-GATE-OWNED	12	owned=27	expect:R16-01	owned=([0-9]+)	27	OK	^\(census=[0-9]+ owned=([0-9]+)
KN-SCOPE-GATE-SHARED	12	shared=8	expect:R16-01	shared=([0-9]+)	8	OK	^\(census=35 owned=27 shared=([0-9]+)
KN-SCOPE-GATE-GROUPS	12	groups=4	rows:corpus/adjacency.tsv	-	4	OK	^\(census=.* shared=[0-9]+ groups=([0-9]+)
KN-SCOPE-GATE-OWNERS	12	owners=4	expect:R16-01	owners=([0-9]+)	4	OK	^\(census=.* groups=[0-9]+ owners=([0-9]+)
KN-SCOPE-GATE-UNRES	12	unresolved=1	expect:R16-01	unresolved=([0-9]+)	1	OK	^\(census=.* owners=[0-9]+ unresolved=([0-9]+)
KN-SCOPE-GATE-CONTEST	12	contested=1	expect:R16-01	contested=([0-9]+)	1	OK	^\(census=.* unresolved=[0-9]+ contested=([0-9]+)
KN-SCOPE-GATE-ESCAPES	13	escapes=0 V	expect:R16-01	escapes=([0-9]+)	0	OK	^escapes=([0-9]+) inbound=0
KN-SCOPE-GATE-INBOUND	13	inbound=0 V	expect:R16-01	inbound=([0-9]+)	0	OK	^escapes=[0-9]+ inbound=([0-9]+)
KN-SCOPE-GATE-FOREIGN	13	foreign=0 V	expect:R16-01	foreign=([0-9]+)	0	OK	inbound=[0-9]+ foreign=([0-9]+)
KN-SCOPE-GATE-ORPHANS	13	orphans=0 V	expect:R16-01	orphans=([0-9]+)	0	OK	foreign=[0-9]+ orphans=([0-9]+)
KN-SCOPE-GATE-STALEBASIS	13	stale_basis=0 V	expect:R16-01	stale_basis=([0-9]+)	0	OK	orphans=[0-9]+ stale_basis=([0-9]+)
KN-SCOPE-GATE-BASISESC	13	basis_escape=0 V	expect:R16-01	basis_escape=([0-9]+)	0	OK	stale_basis=[0-9]+ basis_escape=([0-9]+)
KN-SCOPE-GATE-OWNUNLISTED	14	own_unlisted=0 V	expect:R16-01	own_unlisted=([0-9]+)	0	OK	^own_unlisted=([0-9]+) breadth_required=4
KN-SCOPE-GATE-BREQ	14	breadth_required=4	expect:R16-01	breadth_required=([0-9]+)	4	OK	^own_unlisted=[0-9]+ breadth_required=([0-9]+)
KN-SCOPE-GATE-BPINS	14	breadth_pins=4	ledger:R17-02	^([0-9]+)$	4	OK	breadth_required=[0-9]+ breadth_pins=([0-9]+)
KN-SCOPE-GATE-BCHECK	14	breadth_checked=4 V	expect:R16-01	breadth_checked=([0-9]+)	4	OK	breadth_pins=[0-9]+ breadth_checked=([0-9]+)
KN-SCOPE-GATE-BOK	14	breadth_ok=4 V	expect:R16-01	breadth_ok=([0-9]+)	4	OK	breadth_checked=[0-9]+ breadth_ok=([0-9]+)
KN-SCOPE-GATE-BMISS	15	breadth_missing=0 V	expect:R16-01	breadth_missing=([0-9]+)	0	OK	^breadth_missing=([0-9]+) breadth_invalid=0
KN-SCOPE-GATE-BINVALID	15	breadth_invalid=0 V	expect:R16-01	breadth_invalid=([0-9]+)	0	OK	^breadth_missing=[0-9]+ breadth_invalid=([0-9]+)
KN-SCOPE-GATE-BDRIFT	15	breadth_drift=0 V	expect:R16-01	breadth_drift=([0-9]+)	0	OK	breadth_invalid=[0-9]+ breadth_drift=([0-9]+)
KN-SCOPE-GATE-BEXCEEDS	15	breadth_exceeds=0 V	expect:R16-01	breadth_exceeds=([0-9]+)	0	OK	breadth_drift=[0-9]+ breadth_exceeds=([0-9]+)
KN-SCOPE-GATE-BUNVER	16	breadth_unverified=0 V	expect:R16-01	breadth_unverified=([0-9]+)	0	OK	^breadth_unverified=([0-9]+)\)`
KN-SCOPE-CURRENT-FALSIFY-TOTAL	17	caught=18/18 total V	expect:R16-03	caught=[0-9]+/([0-9]+)	18	OK	^`SCOPE_FALSIFY: PASS \(caught=[0-9]+/([0-9]+) failed
KN-SCOPE-CURRENT-FALSIFY-FAILED	17	failed=0 V	expect:R16-03	failed=([0-9]+)	0	OK	^`SCOPE_FALSIFY: PASS \(caught=[0-9]+/[0-9]+ failed=([0-9]+)\)`
KN-SCOPE-TABLE-CENSUS	46	census rows | 35	rows:corpus/surface-census.tsv	-	35	OK	^\| census rows \| ([0-9]+) \|
KN-SCOPE-TABLE-OWN	47	owned by the 5 prefixes	ledger:R16-04	^([0-9]+)$	5	OK	^\| owned by the ([0-9]+) `# own` prefixes
KN-SCOPE-TABLE-OWNED	47	table row 27	expect:R16-01	owned=([0-9]+)	27	OK	^\| owned by the [0-9]+ `# own` prefixes \| ([0-9]+) \|
KN-SCOPE-TABLE-SHARED	48	table row 8	expect:R16-01	shared=([0-9]+)	8	OK	^\| shared \(covered by a group row\) \| ([0-9]+) \|
KN-SCOPE-TABLE-GROUPS	49	group rows | 4	rows:corpus/adjacency.tsv	-	4	OK	^\| group rows \| ([0-9]+) \|
KN-SCOPE-TABLE-OWNERS	50	owner directives | 4	expect:R16-01	owners=([0-9]+)	4	OK	^\| owner directives \| ([0-9]+) \(
KN-SCOPE-TABLE-NOENUM	52	no-enumerate | 8	ledger:R16-06	^([0-9]+)$	8	OK	^\| `# no-enumerate` directives \| ([0-9]+) \|
KN-SCOPE-COVERAGE-TOTAL	55	coverage = 27	expect:R16-01	owned=([0-9]+)	27	OK	state/tac\) = ([0-9]+)\.
KN-SCOPE-PROSE-GROUPS	58	The 4 group rows	rows:corpus/adjacency.tsv	-	4	OK	launcher symlink\)\. The ([0-9]+) group rows
KN-SCOPE-SUM8	68	8 = 4 + 1 + 2 + 1	expect:R16-01	shared=([0-9]+)	8	OK	^([0-9]+) = 4 \+ 1 \+ 2 \+ 1
KN-SCOPE-R2-PIN	121	R11-11 pins 35	ledger:R11-11	^([0-9]+)$	35	OK	\(`R11-11` pins ([0-9]+)\)
KN-SCOPE-BREADTH-REQ	147	required=4	expect:R17-01	required=([0-9]+)	4	OK	^\| `BREADTH_AUDIT: CLEAN \(required=([0-9]+) pins=4
KN-SCOPE-BREADTH-PINS	147	pins=4	expect:R17-01	pins=([0-9]+)	4	OK	^\| `BREADTH_AUDIT: CLEAN \(required=4 pins=([0-9]+)
KN-SCOPE-BREADTH-CHECKED	147	checked=4 V	expect:R17-01	checked=([0-9]+)	4	OK	^\| `BREADTH_AUDIT: CLEAN \(required=4 pins=4 checked=([0-9]+)
KN-SCOPE-BREADTH-OK	147	ok=4 V	expect:R17-01	ok=([0-9]+)	4	OK	^\| `BREADTH_AUDIT: CLEAN \(required=4 pins=4 checked=4 ok=([0-9]+)
KN-SCOPE-BREADTH-DECL	147	declared=8	expect:R17-01	declared=([0-9]+)	8	OK	^\| `BREADTH_AUDIT: CLEAN \(.*children=182 declared=([0-9]+)
KN-SCOPE-TABLE-FALSIFY-TOTAL	155	table caught total V	expect:R16-03	caught=[0-9]+/([0-9]+)	18	OK	^\| `SCOPE_SELFTEST: PASS \([0-9]+ cases\)` / `SCOPE_FALSIFY: PASS \(caught=[0-9]+/([0-9]+)
KN-SCOPE-TABLE-FALSIFY-FAILED	155	table failed=0 V	expect:R16-03	failed=([0-9]+)	0	OK	^\| `SCOPE_SELFTEST: PASS \([0-9]+ cases\)` / `SCOPE_FALSIFY: PASS \(caught=[0-9]+/[0-9]+ failed=([0-9]+)\)`
KN-SCOPE-ERRATUM35	247	R11-11 (35)	ledger:R11-11	^([0-9]+)$	35	OK	outside by `R11-11` \(([0-9]+)\)
```

The five in-flight rows plus these 51 give 56 current-tense occurrences covered. If all 51
land, `corpus/claim-ledger.tsv:81` (`R25-02`, `claims=56`) must be re-pinned to **claims=107**
(38 SC/PV/RD + 18 KN + 51 KN) and its note needs a second round-27 clause; no new ledger row
is added by the 51 themselves. No new host contact is introduced: the sources are repo data
(`rows:`), non-host greps/selftest (`ledger:R16-02/R16-04/R16-06/R17-02/R11-11`) and
`[substrate]` pins (`expect:R16-01/R16-03/R17-01`, never executed).

## C. Out of population (18 numeric occurrences)

| line | exact text | value | class | locator | why no binding |
|---|---|---|---|---|---|
| 5 | ``4 `# status` `` | 4 | no lane-local source | `` `# owner` / ([0-9]+) `# status` `` | `rows:` counts non-comment data lines only (`corpus/self-counts.py:10,88,142-148`); no ledger row greps `# status`; the CLEAN line prints no statuses. |
| 5 | ``2 `# claim` `` | 2 | no lane-local source | `` `# status` / ([0-9]+) `# claim` `` | same. |
| 7 | ``4 `# scan` `` | 4 | no lane-local source | `` rows, ([0-9]+) `# scan` `` | same; no row counts census `# scan` directives. |
| 54 | `5` `/1/1/17/3` | 5 | per-prefix coverage, unpinned component | `^Prefix coverage is \*\*([0-9]+) / 1 / 1 / 17 / 3\*\*` | only the total 27 is pinned (`R16-01 owned`); no row pins components. Optional rows below. |
| 54 | `1` (bin/the-janitor) | 1 | same | `^Prefix coverage is \*\*5 / ([0-9]+) / 1 / 17 / 3\*\*` | same. |
| 54 | `1` (bin/tac-check) | 1 | same | `^Prefix coverage is \*\*5 / 1 / ([0-9]+) / 17 / 3\*\*` | same. |
| 54 | `17` | 17 | same | `^Prefix coverage is \*\*5 / 1 / 1 / ([0-9]+) / 3\*\*` | same. |
| 54 | `3` | 3 | same | `^Prefix coverage is \*\*5 / 1 / 1 / 17 / ([0-9]+)\*\*` | same. |
| 56 | `holds 105` | 105 | host measurement | `` `\$HOME/\.local/bin` holds ([0-9]+)$ `` | host child count (pinned at `corpus/adjacency.tsv:76`); excluded by the population rule. |
| 57 | `the other 103` | 103 | host-derived | `the other ([0-9]+) are not` | 105−2; host. |
| 63 | opencode `4` | 4 | per-group coverage, unpinned | `` ^\| `\$HOME/\.config/opencode` .*\| ([0-9]+) \|$ `` | only the total 8 is pinned (`R16-01 shared`). Optional rows below. |
| 64 | profile `1` | 1 | same | `` ^\| `\$HOME/\.local/share/the-musketeer/chrome-profile` \| kake \| contested \| presence-only \| ([0-9]+) `` | same. |
| 65 | NMH `2` | 2 | same | `` ^\| `…/chrome-profile/NativeMessagingHosts` \| kagi \| writer \| declared \| ([0-9]+) `` | same. |
| 66 | AGENTS `1` | 1 | same | `` ^\| `\$HOME/\.agents/AGENTS\.md` \| kotoba \| shared-read \| declared \| ([0-9]+) `` | same. |
| 82 | `7 columns` | 7 | schema constant | ``^### `corpus/adjacency\.tsv` — ([0-9]+) columns`` | no row-count source; enforced by `corpus/scope-gate.sh:227`. |
| 93 | `{1,60}` | 60 (and lower bound 1) | schema bound | `\{1,([0-9]+)\}` (lower: `\{([0-9]+),60\}`) | enforced by `corpus/scope-gate.sh:330`; no pinned source. |
| 147 | `children=182` | 182 | host observation | `` ^\| `BREADTH_AUDIT: CLEAN \(.*children=([0-9]+) declared=8 `` | live child count (equals the sum of `corpus/adjacency.tsv:75-78` pins); host. |
| 147 | `undeclared=174` | 174 | host-derived | `` ^\| `BREADTH_AUDIT: CLEAN \(.*children=182 declared=8 undeclared=([0-9]+) `` | 182−8; host. |

Also out, by the same causes: the four group counts repeated on the right of `:68`
(`8 = 4 + 1 + 2 + 1`, duplicate occurrences, not new values), and the word **two** at `:57`
(`this domain's two tools`) — a word, not a digit, so a one-group integer locator cannot
capture it (the two `# own $HOME/.local/bin/*` prefixes at `corpus/adjacency.tsv:49-50` are the
fact it names).

If L1 wants the 9 coverage components bound, these non-host rows reproduce the values exactly
(the field boundary matters: the path is column 1 followed by a TAB, so `$`-anchored patterns
undercount — verified, a naive `^path$` returns 0):

```
R16-A  grep -cE '^\$HOME/\.config/the-janitor(/|[[:space:]])'  corpus/surface-census.tsv  -> ^5$
R16-B  grep -cE '^\$HOME/\.local/bin/the-janitor([[:space:]]|$)' corpus/surface-census.tsv -> ^1$
R16-C  grep -cE '^\$HOME/\.local/bin/tac-check([[:space:]]|$)' corpus/surface-census.tsv   -> ^1$
R16-D  grep -cE '^\$HOME/\.local/state/the-janitor(/|[[:space:]])' corpus/surface-census.tsv -> ^17$
R16-E  grep -cE '^\$HOME/\.local/state/tac(/|[[:space:]])' corpus/surface-census.tsv       -> ^3$
R16-F  grep -cE '^\$HOME/\.config/opencode(/|[[:space:]])' corpus/surface-census.tsv       -> ^4$
R16-G  grep -cE '^\$HOME/\.local/share/the-musketeer/chrome-profile([[:space:]]|$)' corpus/surface-census.tsv -> ^1$
R16-H  grep -cE '^\$HOME/\.local/share/the-musketeer/chrome-profile/NativeMessagingHosts(/|[[:space:]])' corpus/surface-census.tsv -> ^2$
R16-I  grep -cE '^\$HOME/\.agents/AGENTS\.md([[:space:]]|$)' corpus/surface-census.tsv      -> ^1$
```

The three directive counts need new rows too (proposed, not added; all non-host):

```
R16-J  grep -cE '^# status[[:space:]]' corpus/adjacency.tsv          -> ^4$
R16-K  grep -cE '^# claim[[:space:]]'  corpus/adjacency.tsv          -> ^2$
R16-L  grep -cE '^# scan[[:space:]]'   corpus/surface-census.tsv     -> ^4$
```

## D. Excluded by rule (not "missing")

- **Dates / version / round tags:** `:3` `v2, round 17`; `:8` `2026-09-29`; `:9` `round 16`;
  `:10` `Round 17`; `:23` `Rounds 1–15`; `:71` `round-8 …:64`; `:219` `round-8`;
  `:237` `round-10/…:86-88`; `:315` `round 22`. Tags are not counts; QM21/R25-C6.
- **Positional indexes and cross-references:** `:27-38` `README.md:76`,
  `kake-shokunin/SKILL.md:104-107`, `:161`; `:77` `D-96`; `:94` `bound 13`; `:106` `R8`,
  `R11`; `:120` `6-field row`, `8th column`; `:129-132` rule ids; `:168` `700 / 600` (mode
  values, and `corpus/surface-census.tsv:22` dates modes to 2026-09-28); `:178-179` `105
  foreign children`, `three lanes`, `M13`; `:192` `R16-01 … R16-06`; `:211` `R11`;
  `:216-219` `:48`; `:239` `bound 2`; `:244` `bound 6`; `:269-291` mutation indexes `1`–`12`
  and `rows=1`; `:304-306` `104,107`, `161`; `:323-325` round pointers.
- **Dated measurement sections:** `:249-264` `Reproduction (2026-09-29)` (contains 35/5/4/8/4/
  61/18 and `182/8/174`); `:134-140` `Measured before the gate ran` (4/4, 35, 0, 3, 16,
  4/5/5/2, 20, 4, 19, 4, 1 — host/substrate observations; the same lane counts are bound at
  `:7`, `:46-52`).
- **Evidence / Erratum history:** `:295-312` (61, 18/18, 182/8/174, 35/27/8, 4/1/2/1,
  `0`/`1`, 20/105/4/15/2 — the Erratum at `:315-320` declares the recorded 2026-09-29
  observation historical); `:315-326` (Erratum, `round 22`).
- **Hypothetical / counterfactual:** `:200-201` `census=36 owned=27 shared=9` is critic CE-A1's
  invented row set, not a claim about the landed data.
- **Exit codes / output schema:** `:146-155` `0`/`1`/`2` are process exits; `…`/`N` are
  symbolic, not measurements.

## E. Findings and counterexamples

1. **This entry has no stale number, but 51 current numbers are invisible to the binder.**
   Only `:16`, `:17`, `:155` (×2) and `:269` are located today. Example: editing `:46`
   `| census rows | 35 |` to `34` matches no locator in the working-tree table, so the binder
   cannot report it (mechanism: per-line locator matching, `corpus/self-counts.py:315-357`; I
   did not execute the binder — see §G). The entry is therefore *calibrated*, not *bound*.

2. **`rows:` cannot bind directive counts — and the coincidence is a trap.** `rows:` counts
   non-blank, non-comment lines (`corpus/self-counts.py:10,88,142-148`). Four group data rows
   (`corpus/adjacency.tsv:81-84`) and four `# status` directives (`:59-62`) are both `4`.
   Binding `:51`'s first `4` to `rows:corpus/adjacency.tsv` would pass today while measuring
   the wrong artifact. No ledger row counts `# status`/`# claim`/`# scan`; `owners=4` in the
   CLEAN line is defined (it counts `# owner` directives, `corpus/scope-gate.sh:203,643`),
   which is why `:50`'s 4 *is* bindable via `expect:R16-01`.

3. **Per-prefix/per-group components are unguarded, and a re-partition keeps every total.**
   Move one census row from `$HOME/.local/state/the-janitor/...` to
   `$HOME/.local/state/tac/...` (e.g. edit `corpus/surface-census.tsv:51`,
   `xdg-state/opencode/locks` to `locks` under `state/tac`). Coverage `:54` becomes
   `5 / 1 / 1 / 16 / 4`; census stays 35, owned 27, shared 8, groups 4, pins 4. The gate's CLEAN
   fields and every proposed binding above stay green, because only the total `27` (and `8`) is
   pinned. (Static reasoning; the gate was not run — §G.) The optional R16-A…R16-I rows close
   this class; otherwise name it debt.

4. **Naive digit censuses fail on this file three ways.**
   - `grep -oE 'run_case [a-z0-9-]+' corpus/scope-gate.sh | wc -l` = **56**, but the selftest is
     **61** cases: 56 `run_case` invocations plus 5 manual `cases=$((cases+1))` at
     `corpus/scope-gate.sh:902,1076,1087,1103,1112` (the sixth `cases=` at `:883` is inside
     `run_case`). The entry's own erratum warns of this (`:323-325`). A source built on the
     helper-call count would bind 56 against a doc 61 and report a false STALE; `ledger:R16-02`
     runs the selftest instead.
   - `--falsify` has 17 `mutate_case` calls plus one manual check
     (`corpus/scope-gate.sh:752-763`) = **18**; `total=18` is hardcoded at `:677`. Counting only
     `mutate_case` gives 17, another false STALE; `expect:R16-03` is the correct source.
   - The numbers `61`, `18`, `182`, `8`, `174` recur in the dated Reproduction block and in
     Evidence (`:256-257`, `:295-299`). Unanchored locators are `AMBIGUOUS` (exit 1,
     `corpus/self-counts.py:332-335`); every locator above is line-anchored and was tested
     1:1 against BASE.

5. **Tense and hypothetical traps.** `:178-179` `105 foreign children` is past tense and has
   the same value as today's `children=105` pin (`corpus/adjacency.tsv:76`); a tense-blind
   census double-counts it. `:200-201` `census=36 owned=27 shared=9` is a counterfactual
   failing input; binding it would invent two phantom stale values.

6. **Textual defect in the falsification map (advice, outside the number table).**
   `:284-285` says “Symlink an owned path out (or `# own $HOME/.local/bin` …) → `ESCAPE` /
   `ENUM-CLASH` (mutations 5 and 6)”. `--falsify` has **no** symlink-owned-path-out mutation
   at all: its mutation 5 is `prefix-creep-over-no-enumerate` (`ENUM-CLASH`,
   `corpus/scope-gate.sh:726`) and its next is `prefix-creep-over-declared-ancestry`
   (`ENUM-CLASH`, `:734`, labelled `5b` in the code comments), so neither entry-mutation 5 nor
   entry-mutation 6 can be `ESCAPE` (they are code 5 and 5b); code-comment mutation 6 is
   `own-prefix-over-ungated-tree` (`OWN-UNLISTED`, `:742`). The entry renumbers after `5b` (its
   own `mutation 7` at `:285-286` is the code's 6, its `mutations 8 and 9` at `:278-279` are the
   code's 7 and 7b), so the parenthetical is positionally ambiguous as well as wrong about the
   token. `ESCAPE` is proved only by `--selftest` (`run_case escape`, `:985`). Recommend
   replacing the `:284-285` parenthetical with `ENUM-CLASH (mutations 5 and 5b)` and citing
   `--selftest escape` for `ESCAPE`.

7. **C2 has nothing to refuse here.** No `on-release` or version-anchor claim appears in the
   entry; `v2` at `:3` is the gate's schema generation. The release-clock regression rule does
   not apply to this artifact.

## F. Integration note for the integrator

- Adding the 51 rows is a pure table change: no production code, no new commands, no host
  contact (`expect:` never executes; `ledger:` sources are the same greps/selftest already
  used). The binder caches per-source output (`corpus/self-counts.py:351-355`), so the five
  distinct ledger IDs run once.
- Re-pin `R25-02` (`corpus/claim-ledger.tsv:81`) `claims=56 → 107` and extend its note; the
  `SELF_COUNTS` summary line is itself a current-tense number that must track the table.
- If the 18 out-of-population items stay out, record them as named debt in the round-27
  lesson's limit (the lesson already claims "not every digit", `corpus/lessons/round-27.md:90-92`).
- The five in-flight rows are not at BASE. If the before/after measurement overlays the
  *after* table on BASE docs, this entry alone already yields 5 OK / 0 STALE — the five stale
  knowledge numbers in the lesson are elsewhere; do not expect a stale hit here.

## G. What I did NOT check

- Did not execute `corpus/scope-gate.sh` in any mode, `--selftest`, `--falsify`, or
  `corpus/self-counts.py`. All pins are read, not re-earned. The 61-case and 18-mutation values
  are statically corroborated (56+5 increments; 17+1 checks) but unrun.
- Did not read host directories, so no live breadth parity (105/20/4/53 children, `182/8/174`)
  and no `breadth_checked/ok` re-measurement. Those are host numbers and are excluded.
- Did not run a mutation to watch the binder turn STALE (unrun checks are not passes); the
  locator/pin comparisons above are static and exact.
- Did not verify sibling-lane citations (`kake-shokunin/SKILL.md:161`,
  `kotoba/.../alwayson-checklist-round7.md:30`) or the round-8 lesson note; they affect
  ownership evidence, not number calibration.
- Did not cover the other 24 knowledge entries; `corpus/lessons/round-27.md:49-53` says five
  stale numbers live in `claim-ledger.md`, `op-ref-consumption.md` and `surface-census.md`.
- No tool was installed or upgraded; nothing needed.

## Artifacts

- `.ufo/waves/round-27/sandboxes/KnowAdjacencyScope-17/t1-inventory.tsv` — the 51 proposed
  rows (line, text, source, extract, pin, verdict, locator), machine-readable; the five
  covered rows are quoted from `corpus/self-counts.tsv:60-64` in §A.
- `.ufo/waves/round-27/sandboxes/KnowAdjacencyScope-17/proposed-rows.tsv` — early draft; the
  report's §B block supersedes it (the draft's extract column is a placeholder).
