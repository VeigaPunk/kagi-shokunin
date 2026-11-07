# Round 63 — kagi (secrets & vault ops)

Lane: kagi. Round 63, attempt 1. Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc`
(round-62 verifier spot-check tip). Frozen predeclaration `plans/round-63.md`
(`12c9e4284d6de52ba61fcc656165cd24e8b74480`), amended A1 (wave shape, `4fe6c0d`) and A2
(C2 population 5, `81bd56c`) before any candidate reading. Wave `kagi-r63-w1`, 15 seats
(plan Amendment A1; `.ufo/waves/round-63/w1-dispatch.json`).

cites: S135 S137 S139 S140 S141 S143 — the six admitted rows (ConText's pseudo-trigger/termination-term classes on two deposits, NegEx's own filter-and-scope rule, and three peer-reviewed statements of the equivalent-mutant rule); the Gate below carries S135–S144 with their flips.

## Claims

Both claims are declared in the frozen plan before any candidate work; this section
restates the frozen predicates and records the readings measured at BASE and at the
candidate. The counters are the verdicts.

### C1 — calibration (`C1_RESIDUAL`, accepted 10 → 0 and rejected 6 → 0, population 10/6)

Frozen predicate (plan §C1, verbatim):

```
C1_RESIDUAL: accepted = the number of the ten committed forgery fixtures (F1..F10) on
which the measured tree's checker (plans/round-61-c1-check.py, invoked
`python3 -I -B … --root <copy> --repo <lane> --fleet <fleet-root> --no-challenge`)
prints `C1_ROUTED: value=0` — i.e. accepts the forgery; rejected = the number of the
six committed benign fixtures (P1..P6) on which it prints `value>=1` — i.e. rejects a
sentence that keeps the assertion. POP = 10 / 6; target accepted=0 AND rejected=0
(BASE 10 / 6).
```

The instrument this claim lands is the sentence-scope polarity grammar (plan §C1 "The
hardened grammar"): a token is asserted only when no negator sits between the nearest
`.`/`;` before it and the token (24-token cap), no denial predicate sits between the
token and the nearest `.`/`;` after it, no idiom immediately precedes it, and no negator
before it is followed by `but` before the token; double-quoted spans that end before the
token are masked. I3 accepts `A3 item 2` or `item 2 of A3`; I4 accepts `three` or the
digit `3`; I5 accepts `rewritten in place` or `rewritten in-place`; I6 derives the
superseded stamp from the fleet report's §Stale-lane line and requires the quoted span's
`HH:MM:SS` set to equal it; I7 binds each fraction to its subject within 8 tokens. The idiom/contrastive
exception list is grounded in the admitted rows: ConText's pseudo-trigger class
(`not increase`, `not cause`) and termination-term class (S135, S143) and NegEx's own
false-negation filter and scope limit (S141).

Readings:

- **BASE (committed census, `.ufo/waves/round-63/base/census.md`, L1 at `966c469`):**
  F1..F10 each `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0` rc 1; P1..P6 each
  `C1_ROUTED: value=1 …` rc 1 (P1/P2 `i3=0`, P3/P4 `i4=0`, P5/P6 `i5=0`); the unmodified
  copy `value=0` rc 1. Reading: `accepted=10 rejected=6`.
- **Candidate (instrument state at this seat's write time):** the hardened checker is
  `plans/round-61-c1-check.py` sha256
  `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`, 2031 lines, and its
  own `--selftest` prints `C1_CHECK_SELFTEST: PASS (cases=102)` rc 0; the counter's
  `--selftest` prints `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` rc 0 (this seat,
  `records.md` R9). The verdict lines on the candidate are the frozen counter's to print
  and the L1's to land (`.ufo/waves/round-63/final/c1-residual.txt`); this seat does not
  run the 16-fixture verdict.
- **Named ceiling (measured by the attack seat):** the five guard legs do not distinguish
  a fixture-lookup checker from a grammar — a 15-string lookup table with a constant
  `PASS (cases=91)` selftest satisfies every leg and reaches `accepted=0 rejected=0`
  (`build/R63Critic/critique.md` §A4; M63-6). The round-62 counter refused the same tree
  only through its `chal` leg, which this guard does not carry.

### C2 — operability (`C2_REFUSAL`, killed 0 → 5, population 5)

Frozen predicate (plan §C2 as corrected by Amendment A2, verbatim):

```
C2_REFUSAL: killed = the number of the six falsifier legs that fire over POP = 6:
  L1 (CM2a) … L2 (CM2b) … L3 (D12) … L4 (D-6) … L5 (S3) … L6 (GM5)
  — when GUARD = 1, else FAIL. Target 6 (BASE 0).
```

Amendment A2 (measured, committed `81bd56c`) drops L5: `plans/round-62-c2.sh:279`
already carries `[ "$ma_applied" = 1 ] || setup needle-ma`, so the S3 tree reads
`C2_HARDENED: SETUP needle-ma` rc 2 at BASE — a leg that already fires at BASE is
vacuous under kill rule K1. **Population 5, target killed=5**: L1 (CM2a), L2 (CM2b),
L3 (D12), L4 (D-6), L6 (GM5).
The "killed or shown equivalent" contract the legs serve is grounded in three
peer-reviewed statements of the equivalent-mutant rule: S137 (redundant for all test
cases, 4–39 % of real-world mutants), S139 (syntactically different but functionally
equivalent, can never be killed) and S140 (cannot be killed, attributed to Jia &
Harman 2011).

Readings:

- **BASE (committed census, same file):** L1/L2 `C1_COUNTER_SELFTEST: PASS (8/8 checks)`
  rc 0; L3/L4 stub counters print their target verdict lines rc 0; L6
  `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0; L5 `C2_HARDENED: SETUP needle-ma` rc 2;
  `grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ `0`. Reading: `killed=0` over the
  five non-vacuous legs.
- **Candidate:** the frozen counter's line is the L1's candidate receipt
  (`.ufo/waves/round-63/final/c2-refusal.txt`); this seat's measured instrument reading is
  the C1 counter's `--selftest` (above) and the controls battery's own selftest, both
  point observations of a moving tree.
- **Named ceiling:** six legs are not a complete mutation set, and a stub that prints
  exactly the independently expected line is indistinguishable by output alone (plan
  §C2); the cross-file needle ownership (M63-7) and the needle/replacement conflation
  (M63-8) are the attack seat's measured ceilings on the legs themselves.


## Gate

Ten pages were opened live this round (S135–S144; access date 2026-11-07 for every page; S136 is opened but not registered — see the Gate table).
The scout's capture ledger is `.ufo/waves/round-63/capture/notes.md` (10 page blocks, per
page URL, status, bytes, sha256, quote, location, locate output, verdict and flip; secret
discipline: 0 cookie lines in the nine header receipts, 0 token hits across the bodies).
The captured bodies are `.ufo/waves/round-63/capture/S135.body` … `S144.body` (S136.body is the committed 0-byte record of the empty challenge response); S139's quote
is located in `S139.txt`, the committed text layer of the same PDF (the PDF bytes are not
strict UTF-8). Every quote below was re-resolved by this seat with
`python3 corpus/rendered-text-v1.py locate <capture> "<quote>"` and prints
`RENDERED_TEXT_V1_LOCATE: count=1` (`build/R63ScribeRecords/records.md` R15). Nine rows are
admitted (six `mined`) and three rejected; S136 was opened but is not a registry row —
see its row. Each rejected candidate stays as a row with its measured reason and flip
(plan §Frontier).

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S135 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml | 2026-11-07 | `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)` (17 words; §3.1.2 Trigger Terms, Pseudo-Trigger Terms, and Termination Terms, PMC XML `sec id="S6"` P19; capture 189603 B, sha256 `cdbb4173…`) | admit, tier A | the pseudo-trigger class is the published ground for "a negator-looking phrase that does not negate" — the paper's own examples (“no increase”, “not cause”) have the shape of the C1 idiom exceptions; the same section's termination-term sentence (19 words, `count=1`) grounds a scope that can close early. The body is byte-identical to S130's (same URL and digest), so this row re-derives S130's pin and adds the §3.1.2 lesson S130 did not quote. Flip: a revision that drops the §3.1.2 pseudo-trigger/termination-term taxonomy |
| S136 (opened, not registered) | https://ieeexplore.ieee.org/document/5661753 | 2026-11-07 | none — HTTP 202 challenge, 0-byte body (capture 0 B, sha256 `e3b0c442…`); the readable sibling (S142) renders an unrelated title | reject | two measured reasons: the URL serves an IEEE Xplore interstitial with no body, and document id 5661753 is "Address Translation Aware Memory Consistency", not Jia & Harman 2011 (whose IEEE id is 5487526, S144; Crossref DOI 10.1109/TSE.2010.62 confirms the survey's volume/pages/authors). Flip: an IEEE Xplore URL for the survey that serves the abstract as retrievable text. **Not a registry row**: a 0-byte body can never carry the ≤25-word located quote the frontier row shape requires, and the census's `SC_FETCH` needs `bytes >= 1`; the measurement stays in `capture/notes.md` and the misidentification evidence is carried by rows S142/S144 |
| S137 | https://arxiv.org/html/2408.01760v1 | 2026-11-07 | `An equivalent mutant is redundant because it exhibits the same behavior as the original program for all possible test cases` (20 words; §1 Introduction; capture 286109 B, sha256 `21893b04…`) | admit, tier A | the peer-reviewed statement of the definition the C2 kill contract rests on, attributed to Jia & Harman, plus the prevalence that makes the class material — `Recent research indicates that the rate of equivalent mutants in real-world development scenarios ranges from 4% to 39%` (18 words, `count=1`). ISSTA 2024, DOI 10.1145/3650212.3680395. Flip: a revision that removes the definition sentence or its attribution |
| S138 | https://www.codecov.io/blog/mutation-testing/ (301 chain to `about.codecov.io/blog/mutation-testing-how-to-ensure-code-coverage-isnt-a-vanity-metric/`) | 2026-11-07 | `These mutants occur when the mutation causes the code to have the same meaning or interpretation, albeit with different syntax.` (20 words; the “Equivalent mutants:” item of the “Key mutation testing concepts” list; capture 67821 B, sha256 `dfa774ba…`) | reject | the round's designated weak lead: a vendor marketing blog with 0 occurrences of `Jia`, `Harman`, `IEEE` or `citation`, no cannot-be-killed consequence, and no surviving-side counterpart — the same half-pair defect that got round 62's S133 rejected; publication stamp 2022-05-27 is also the round's weakest freshness. Flip: the blog citing a primary definition with the cannot-be-killed consequence and the surviving-side counterpart |
| S139 | https://web.eecs.umich.edu/~weimerw/2022-481F/readings/mutation-testing.pdf | 2026-11-07 | `These mutants are called Equivalent Mutants. They are syntactically different but functionally equivalent to the original program.` (17 words; PDF page 4, §II The Problems of Mutation Analysis; located in the committed text layer `S139.txt`, sha256 `0debc82d…`, 175555 B; PDF 1181976 B, sha256 `056ac9b9…`) | admit, tier A | the survey the plan's §Frontier step 3 names, from a university course mirror rather than the paywall: the definition plus the consequence C2 turns on — `there are some mutants that can never be killed, because they always produce the same output as the original program` (21 words, `count=1`). The PDF bytes themselves are not locatable (`SETUP (not strict UTF-8)`); the text layer is committed beside them and both digests are recorded, the shape S078/S079 already use. Flip: a mirror that serves the article only in a form where the definition cannot be located |
| S140 | https://arxiv.org/html/1903.05432v1 | 2026-11-07 | `An equivalent mutant is—despite syntactical changes—semantically equivalent to the original program and can therefore not be killed.` (17 words; §3 Definitions; capture 295941 B, sha256 `4af40301…`) | admit, tier A | states the rule and its provenance in one place — `We further use common mutation testing terms as defined in literature ( Jia and Harman, 2011 )` (17 words, `count=1`) — so it is a second independent attestation, not a paraphrase; EASE 2019, DOI 10.1145/3319008.3319021. Flip: a revision that drops the definition or its attribution |
| S141 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=12123149&retmode=xml | 2026-11-07 | `filters out sentences containing phrases that falsely appear to be negation phrases, and limits the scope of the negation phrases` (20 words; Abstract; capture 5714 B, sha256 `009eedaa…`) | admit, tier A | NegEx's own abstract states the two rules the C1 grammar implements — a closed list of negation phrases, a filter for phrases that falsely appear to negate (the idiom/contrastive exclusions), and a bounded scope (the window) — in the primary source rather than a later paper's description (S130/S131). PMID 12123149 is the NegEx record; round 62's S132 PMID 11554662 is a different paper. Flip: a deposit revision that drops the filter-and-scope sentence |
| S142 | https://ieeexplore.ieee.org/abstract/document/5661753 | 2026-11-07 | `Address Translation Aware Memory Consistency` (5 words; the document `<title>`; capture 46994 B, sha256 `03ce1bd8…`) | reject | the evidence row for S136's misidentification: the readable sibling of document 5661753 is an unrelated memory-consistency paper, and `equivalent mutant` locates `count=0`; it grounds no lesson. Flip: none for this page — the candidate's flip is on S136/S144 |
| S143 | https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode | 2026-11-07 | `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)` (17 words; §3.1.2; capture 264946 B, sha256 `8522a79e…`; 2/3 fetches byte-identical, one HTTP 429 shell not committed) | admit, tier A | the distinct-URL carrier of the same ConText lesson as S135, so the registry can hold the pseudo-trigger/termination-term ground without a duplicate URL against S130; the termination-term quote also locates `count=1`. The BioC endpoint rate-limits, so its digest is recorded as volatile. Flip: the BioC service changing its XML shape or withdrawing the record (the `efetch` deposit S135/S130 is the durable copy) |
| S144 | https://ieeexplore.ieee.org/abstract/document/5487526 | 2026-11-07 | `An Analysis and Survey of the Development of Mutation Testing` (9 words; the document `<title>`; capture 49289 B, sha256 `b93834ae…`) | reject | the record-identity evidence for S136's correction: the served HTML carries the survey's title but 0 occurrences of `equivalent mutant` (the abstract is client-rendered), so it cannot ground the lesson; the university PDF (S139) is the citable carrier. Flip: IEEE serving the abstract as static HTML |

Registry effect: `corpus/SOURCES.md` 134 → 143 data rows (nine new rows S135, S137–S144
except S136; six `mined` — S135, S137, S139, S140, S141, S143 — and three `rejected` —
S138, S142, S144). `corpus/source-fetches.tsv` 177 → 186 lines (nine new fetch rows; the
opened-but-unregistered S136 has none: a 0-byte body fails the census's `bytes` check and
the row shape's located-quote requirement, so it is documented in `capture/notes.md` and
the Gate table above but is not a registry row). The row block is
`build/R63ScribeRecords/sources-block.md` (its S136 row is superseded by this correction);
the L1 appends it. The mined rows are cited by
`corpus/knowledge/negation-scope-grammar.md` (S135, S137) and by this lesson's `cites:`
line (all six).

## Mistakes

| id | class | evidence pointer | captured-by | fix (and how it can fail) |
|---|---|---|---|---|
| M63-1 | dispatch vs frozen plan — the wave spec's C2 seat prompt and the wave `milestone` string carry the pre-amendment population | `.ufo/waves/round-63/w1-spec.json` `milestone` reads `C2_REFUSAL killed 0 -> 6` and the `R63ExecC2Counter` prompt requires `C2_REFUSAL: killed=K population=6 … exit 0 iff … K=6`; `plans/round-63.md` §Amendment A2 (committed `81bd56c`, 35 s after the spec at `4fe6c0d`) reads `C2 population is therefore 5, target killed=5` | R63ScribeRecords (this seat), reading both committed files | the lesson states the frozen population is 5 and names the stale dispatch text; the frozen counter prints `population=5`. **Able to fail**: the counter's own `--selftest` asserts its verdict-line shape including `population=5`; a build printing `population=6` fails that case (and a candidate receipt carrying `population=6` contradicts the plan's output-line spec) |
| M63-2 | record vs artifact — a report count that does not re-derive from committed bytes | the round-62 report (`/home/vgpnk/Projects/shokunin/.ufo/reports/round-62/kagi.md:42,58`) says the checker is `1454 → 1822` lines and the counter `389 → 520`; `git show 60b5b7b:plans/round-61-c1-check.py \| wc -l` ⇒ `1454` and `git show c840739:plans/round-61-c1-check.py \| wc -l` ⇒ `1710`; the same pair for `plans/round-61-c2.sh` ⇒ `389` / `478` | round-62 verifier spot-check §6 D-A; re-derived by this seat (records.md R6) | the §Corrections line below carries both measured pairs and the command; `plans/round-63-routed.sh` leg `da` requires it. **Able to fail**: a correction restating `1822`/`520` reads `da=0` (the executor's `da-stale` fixture, `build/R63ExecRouted/routed.md`) |
| M63-3 | frozen-plan defect — a frozen leg already fires at BASE, so it cannot count as a kill | plan §C2 L5 (S3) is vacuous: on a tree whose `plans/round-61-c2.sh` carries neither the `# BEGIN-DECIDE` marker nor the BASE aggregation text, `bash plans/round-62-c2.sh --tree <tree>` prints `C2_HARDENED: SETUP needle-ma` rc 2 (`plans/round-62-c2.sh:279` already carries the guard); the L1's census records it at `.ufo/waves/round-63/base/census.md` §C2 | R63MutC2 S3 (round 62, predating the guard); re-measured by the L1 before the wave | plan §Amendment A2 drops L5 and sets population 5; the counter prints `population=5`. **Able to fail**: kill rule K1 — a tree byte-identical to BASE must read `killed=0`; a leg that fires at BASE would read `killed>=1` on the no-work control |
| M63-4 | receipt vs code — a routed leg's stated rule is not the rule its code implements | `build/R63ExecRouted/routed.md` §Risks says "Prose mentions of `cases=` on non-selftest lines do not set the floor"; the code (`plans/round-63-routed.sh` leg `dc`) scans every line for `cases=(\d+)`. Measured probe (records.md R7): a fixture lesson with a prose `cases=` token carrying a four-digit figure and two case items reads `dc:max_cases=<that figure> enum_items=2` ⇒ `dc=0`, on a lesson that satisfies the receipt's stated rule | R63ScribeRecords (this seat) | the leg should parse only selftest-shaped lines, or the receipt should state the code's actual rule. **Able to fail**: the probe tree reads `dc=0` while satisfying the prose rule; the executor's own `dc-short` fixture reads `dc=0` for a different reason, so the two are distinguishable by `max_cases` |
| M63-6 | guard vacuity — a checker that implements no grammar passes every frozen C1 guard leg | `build/R63Critic/critique.md` §A4: a 15-string lookup-table checker (the ten F replacements plus the five B replacements, a constant `C1_CHECK_SELFTEST: PASS (cases=91)`) reads F1..F10 `value=1`, P1..P6 `value=0`, B3..B7 `value=1`, P3..P5 `value=0`, unmodified `value=0` — every guard leg (a)–(e) passes and `accepted=0 rejected=0` is reachable with no grammar; the round-62 counter refuses the same tree only through its `chal` leg (`chal=0 guard=0`), and the round-63 guard has no `chal` leg | R63Critic (attack seat), A4 | add the round-62 `chal` leg (a mutated copy with an emptied negator set must fail the checker's selftest) to the C1 guard, or pin a held-out fixture outside the committed TSVs. **Able to fail**: the lookup-table checker reads `chal=0` on the round-62 counter, so a guard carrying the leg reads `guard=0` for it while the frozen guard reads 1 |
| M63-7 | cross-seat instrument dependency — a leg mutates a file another seat owns and refactors | `build/R63Critic/critique.md` C2-3: C2's L1/L2 mutate `plans/round-62-c1.sh`, owned by the C1 counter seat, which is told to refactor the exact L1 needle line into `stub_calc`; a byte-changing refactor makes the L1 mutation match 0 times → SETUP, and the L1/L2 legs require a `FINDING` line the C1 counter's selftest does not print | R63Critic (attack seat), C2-3 | freeze the post-refactor needle (or forbid changing the line) and name the required `FINDING` prefix in the C1 seat's prompt. **Able to fail**: the needle match count reads SETUP on 0 or >1 occurrences |
| M63-8 | frozen-plan wording — the plan prints the replacement as if it were the needle | plan §C2 L6 prints `ok = len(qualifying) >= 3 and not denied` as the mutation; the BASE line is `ok = len(qualifying) >= 3 and bool(superseded) and not denied` (`plans/round-61-c1-check.py:756`), so a literal needle of the parenthetical matches 0 times | R63Critic (attack seat), C2-6 | state the needle and the replacement separately (the seat prompt does; the plan does not). **Able to fail**: a zero-match needle reads `SETUP needle-*` (exit 2), never a surviving mutant |
| M63-9 | frozen command line — the predicate's invocation cannot run on the measured tree | plan §C1's command line passes `--fleet <fleet-root>` to `plans/round-61-c1-check.py`; the BASE checker's argparse has no `--fleet` (`git show 0c07aab:plans/round-61-c1-check.py` ⇒ `--root --repo --no-challenge --json --verbose --selftest --work`), so the frozen line exits 2 on BASE; the L1 census omits the flag | R63Critic (attack seat), C1-2; re-read by this seat | the counter probes the checker source for the literal `--fleet` and passes it only when accepted (`plans/round-63-c1.sh` header). **Able to fail**: passing `--fleet` unconditionally on BASE reads SETUP instead of the census line |
| M63-5 | plan-internal conflict — a §considerthese landing contradicts the frozen output-line spec | plan §considerthese says the `C1_RESIDUAL`/`C2_REFUSAL` verdict lines carry their ceilings "in the same line (`ceiling=` field)"; plan §C1/§C2 fix the lines as `C1_RESIDUAL: accepted=A rejected=R population=10/6 guard=G (real=… selftest=… prior=… para=… stub=…)` and `C2_REFUSAL: killed=K population=5 guard=G (l1=… …)`, and `grep -c 'ceiling=' plans/round-63-c1.sh` ⇒ `0` | R63ScribeRecords (this seat) | the lesson records the gap and the QUALITY criterion (QM83/QM84) carries the ceilings; the frozen line shape is not amended. **Able to fail**: a counter printing a `ceiling=` field violates the frozen "prints exactly" line and the controls' full-line comparison |

## Corrections

- **D-A correction (round-62 report counts).** The round-62 report's two instrument counts do not re-derive: the checker is `1454 -> 1710` lines and the C2 counter `389 -> 478` lines, measured with `git show 60b5b7b:<path> | wc -l` and `git show c840739:<path> | wc -l` (the report's `1822` and `520` are stale). Re-derived by this seat; leg `da` of `plans/round-63-routed.sh` requires this line to carry both measured pairs and the command.

## Routed dispositions

| id | spot-check §6 | item / file that carries the fix | state at write |
|---|---|---|---|
| D-A | §6 D-A report counts that do not re-derive | the §Corrections line above (single line, both measured pairs and the command) and `plans/round-63-routed.sh` leg `da` | landed in the working tree; leg `da` |
| D-B | §6 D-B gate verdict lines without a committed receipt | six receipts under `.ufo/waves/round-63/final/` (`c1-residual`, `c2-refusal`, `controls`, `release-clock`, `doc-audit`, `claims-declared`), each cited from `LOG.md`; leg `db` | the L1/executor seats write them at integration; leg `db` |
| D-C | §6 D-C undercounted case enumeration | `## Case enumeration` below lists every case the round-63 instruments' selftest counts claim (the checker's full case list, the two counters' checks); leg `dc` | landed in the lesson; leg `dc` |

## considerthese

One still-unimplemented proposal is mined this round (read-only; never edited):
`considerthese/2026-10-26.md` proposal 3, "Mark known-defective instrument output" — a
gate that knows a defect class in its own instrument appends a `KNOWN_DEFECT: <id>`
qualifier to a `CLEAN` verdict instead of printing a bare CLEAN. The plan lands it as the
verdict lines' `ceiling=` field and as the round's QUALITY criterion. Measured at write
time: the QUALITY criterion lands (QM83/QM84, `corpus/QUALITY.md`), the `ceiling=` field
does not — `grep -c 'ceiling=' plans/round-63-c1.sh` ⇒ `0`, and the frozen §C1/§C2
output-line specs carry no such field, so a counter that printed one would violate the
"prints exactly" clause and the controls' full-line comparison. Reported as M63-5, not
amended: the frozen line shape governs, and the ceilings live in this lesson and in the
QUALITY criterion instead.

## Wave

`kagi-r63-w1`, 15 seats v1 (plan Amendment A1; `.ufo/waves/round-63/w1-dispatch.json`;
reports `.ufo/waves/round-63/w1/`): 2 scout, 5 executor, 2 scribe, 1 reviewer, 1 critic,
2 mutation-tester, 1 connector, 1 sentinel. Attack share 4/15 = 26.67 % on the addendum's
literal list (reviewer, critic, mutation-tester ×2; no labrat seat exists), 5/15 = 33.33 %
counting the sentinel. The L1 holds the canonical planner seat and is the sole
integration owner and committer; the settled counts and seat verdicts are the L1's append.

## Case enumeration

The checker's own selftest case list (`plans/round-61-c1-check.py`, sha256
`eb08094c…`, `C1_CHECK_SELFTEST: PASS (cases=102)`), extracted by this seat from a scratch
copy whose `case()` prints every name (`records.md` R12). One item per case:

- `fleet-stamp-derived`
- `derive-results-16-3-4`
- `derive-mut-bytes-3824`
- `fixture-repo-toplevel`
- `derive-numstat-1-1`
- `derive-ci-set-4-stamps`
- `norm-ci-format`
- `mutate-deletions-digit-only`
- `registry-row-found`
- `registry-none-own-detected`
- `aggregate-good-all-hold`
- `evaluate-no-challenge-good`
- `evaluate-guard-good-tree`
- `no-repo-good-shape-only`
- `no-repo-guard-cannot-fire`
- `evaluate-all-unresolved-7`
- `evaluate-all-unresolved-guard-fails-closed`
- `only-i1-resolves`
- `only-i2-resolves`
- `only-i3-resolves`
- `only-i4-resolves`
- `only-i5-resolves`
- `only-i6-resolves`
- `only-i7-resolves`
- `i1-wrong-bytes`
- `i1-no-mutants-md`
- `i1-later-restatement-wins`
- `i1-decoy-mention-no-relocate`
- `i1-correction-before-row`
- `i2-selftest-cases-below-6`
- `i2-selftest-exit1`
- `i2-no-needle-fails-closed`
- `i2-mutation-undetected`
- `i2-registry-none-own`
- `i2-absent-script-unresolved-not-setup`
- `i3-a7-before-a6`
- `i3-a7-withdraws-nothing`
- `i3-lesson-second-instance-missing`
- `i4-missing-d3`
- `i4-wrong-count`
- `i5-stated-dels-vs-derived`
- `i5-mechanism-missing`
- `i5-shape-only-without-repo`
- `i5-shape-derived-with-repo`
- `i6-foreign-timestamp`
- `i6-only-two-stamps`
- `i7-wrong-pct`
- `i7-wrong-fraction`
- `b3-negated-withdrawn-unresolved`
- `b4-no-three-unresolved`
- `b5-not-rewritten-unresolved`
- `b6-tail-denial-unresolved`
- `b7-swapped-pairing-unresolved`
- `b6-wholeline-no-superseded-stamp-unresolved`
- `i6-benign-conclusion-resolved`
- `p3-hereby-resolved`
- `p4-did-introduce-resolved`
- `p5-comma-resolved`
- `full-p3-value0`
- `full-p4-value0`
- `full-p5-value0`
- `f1-forgery-unresolved`
- `f2-forgery-unresolved`
- `f3-forgery-unresolved`
- `f4-forgery-unresolved`
- `f5-forgery-unresolved`
- `f6-forgery-unresolved`
- `f7-forgery-unresolved`
- `f8-forgery-unresolved`
- `f9-forgery-unresolved`
- `f10-forgery-unresolved`
- `p1-benign-resolved`
- `p2-benign-resolved`
- `p3b-benign-resolved`
- `p4b-benign-resolved`
- `p5b-benign-resolved`
- `p6-benign-resolved`
- `i6-superseded-stamp-conjunct-isolated`
- `i6-missing-fleet-report-is-setup`
- `negator-round63-membership`
- `denial-after-token-detected`
- `post-token-not-route-not-denial`
- `not-merely-idiom-rescues`
- `contrastive-but-rescues`
- `quoted-span-masked`
- `negator-set-membership`
- `window-truncated-at-boundary`
- `window-negator-detected`
- `window-no-three-negated`
- `not-only-idiom-not-negator`
- `mid-window-not-only-still-negator`
- `window-negator-at-10-tokens`
- `window-negator-at-31-tokens-ignored`
- `pair-regex-whitespace-tolerant`
- `qualifying-times-validate-and-exclude`
- `k5-negator-needle-unique`
- `k5-negator-removed-accepts-b3`
- `challenge-plus1-fires-with-unresolved`
- `qm74-refusal-inside-root`
- `parse-value-tokens`
- `symlinked-log-refused-setup`
- `setup-missing-root-rc2`

## Bounds

- The `## Gate` quotes are the scout's located rows in `capture/notes.md`, re-resolved by
  this seat with `corpus/rendered-text-v1.py locate`; the locate outputs are in
  `build/R63ScribeRecords/records.md`. A `count=1` proves the string occurs once in the
  captured body, not that the page says what the row's `teaches` cell claims.
- The claims' BASE readings are the L1's committed census (`.ufo/waves/round-63/base/
  census.md`); the candidate readings are the frozen counters' own lines. A reading this
  seat took on the working tree is a point observation of a moving tree, not the L1's
  candidate receipt.
- `## Case enumeration` is the instrument's own case list extracted from the measured
  checker; a later edit to the checker changes the list and makes this one stale.
- The `## Routed dispositions` state column is a working-tree read at write time; it is
  not the frozen counters' verdict.
- The `ceiling=` gap (M63-5) is a plan-internal conflict, reported not amended; the
  frozen line shape governs.
