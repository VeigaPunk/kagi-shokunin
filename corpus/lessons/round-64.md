# Round 64 — kagi (secrets & vault ops)

Lane: kagi. Round 64, attempt 2. Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`
(round-63 verifier spot-check tip). Frozen predeclaration `plans/round-64.md`
(`dff0929c0e084822b0fe32e0d164534c768f97fe`, including Amendment A1, which re-measured
the held-out population) before any candidate work. Wave `kagi-r64-w1`, 16 seats
(plan §Wave; `.ufo/waves/round-64/w1-dispatch.json`).

cites: S145 S146 S147 S148 — the four rows this round admits: the ISSTA '24
equivalent-mutant paper, the *Advances in Computers* survey chapter, Stryker's
tool-level equivalent-mutants page, and the re-verified BioC/ConText deposit that
supersedes `S143`.

## Claims

Both claims are declared in the frozen plan before any candidate work; this section
restates the frozen predicates and records the readings. The counters are the verdicts.

### C1 — calibration (`C1_HELDOUT`, heldout 8 → 0, population 8)

Frozen predicate (plan §C1 as amended by A1, verbatim):

```
C1_HELDOUT: heldout = the number of the round-64 held-out fixtures (H1..H5, ids
F2,F6,F8,F10,B4 in plans/round-64-heldout.tsv, Amendment A1) on which the measured
tree's checker (plans/round-61-c1-check.py, invoked
`python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --fleet <fleet-root> --no-challenge`)
prints `C1_ROUTED: value=0` (the forgery is accepted -> the checker failed to catch it)
or on which any of the three benign held-out fixtures (Q1..Q3, ids P6,B5,P7, Amendment A1) prints `value>=1`
(rejects the benign rewrite). POP = 8 (5 forgery + 3 benign); target heldout=0
(BASE 8, legs (a)-(e) below). GUARD = 1 iff, on the same measured tree: (a) the
unmodified copy prints `value=0` (the seven round-61 corrections still resolve); (b) the
checker's `--selftest` exits 0 printing
`C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 91; (c) the round-63 counter's
verdict still reads `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1`
on the candidate (no regression on the committed tables); (d) a printer-stub
checker is refused — no `C1_HELDOUT:` verdict line and a non-zero exit; (e) the
A4 lookup-table vehicle (a checker carrying a literal
`NEGATORS = frozenset(())` dead line plus a 15-string fixture lookup and a
constant `PASS (cases=91)`) is refused on the held-out set — it must NOT reach
`heldout=0` on the candidate.
```

The instrument this claim lands is the sentence-scope polarity grammar carried forward
from round 63, extended with the six mechanisms Amendment A1 names as the reachable set:
a denial predicate after the pair (F2), a single-occurrence rule for the rewritten
mechanism (F6), a `NO_NEW_RECORD_DEFECT_RE` assertion in the quoted-denial item (F8), an
every-pair-bound rule (F10), a subject-negatedness guard (B4), and a binding window that
masks parentheticals and em-dash asides (P6, P7) plus one more idiom class, "not less
than" (B5).

Readings:

- **BASE (the L1's committed census, `.ufo/waves/round-64/base/census-a1.md`):** on an
  extracted `09cbee8` tree the five held-out forgeries (F2, F6, F8, F10, B4) each read
  `C1_ROUTED: value=0` (the checker accepts the forgery) and the three benign rewrites
  (P6, B5, P7) each read `value>=1` (the checker rejects the benign rewrite) — heldout
  **8** over a population of 8. The unmodified copy reads `value=0` with all seven
  i-bits 1. The census is a **per-fixture** table (21 rows: every id with its value and
  its i-bits), not a per-class assertion; that is the shape Amendment A1 fixed.
- **Candidate (this seat's own working-tree measurement, a point observation of a moving
  tree — not the L1's receipt):** the counter's measure leg on the working tree reads
  **H accepted=0/5 and Q rejected=0/3** — every held-out forgery reads `value=1` (the
  hardened checker rejects it) and every held-out benign rewrite reads `value=0` (the
  hardened checker accepts it) — with the unmodified copy at `value=0` and all seven
  i-bits 1. The held-out **count** therefore reads 0 over the population of 8, the
  direction the claim states. **The counter did not print its verdict line on these
  bytes**: the run aborts at the guard-leg provenance echo with
  `plans/round-64-c1.sh: line 620: stub2_e2: unbound variable` (bash `set -u`), so no
  `C1_HELDOUT:` line and no exit code exist for them. The counter's own bytes changed
  again after this measurement. This seat does not own `plans/round-64-c1.sh` and did
  not edit it; the defect is reported (M64-2), not repaired.
- **Named ceilings (carried and extended).** Eight fixtures are eight fixtures, not a
  grammar proof; a lookup table carrying a *fresh* entry for each held-out fixture would
  also reach `heldout=0` — the counter cannot tell a fresh lookup from the grammar. The
  critic's attack seat measured the margin of that class directly this round: a pure
  length rule (reject when the fixture line grew by more than three tokens) closes
  **5/5** forgeries while misrejecting two benign rewrites, so `heldout=0` is two benign
  exceptions away from a rule with no polarity reasoning at all
  (`.ufo/waves/round-64/build/R64Critic/critique.md` §B/Attempt 2). The critic further
  measured that a verdict-less run — a checker that refuses every changed tree it does
  not recognise — is counted as "not heldout" by the predicate's literal counting rule,
  so `heldout=0` is reachable by a failure mode rather than by a grammar
  (critique §B/Attempt 3, §C1-2). Both are ceilings on the *reading* of the number, not
  amendments to the frozen predicate.

### C2 — operability (`C2_REFUSAL`, terminated 0 → 1, killed 0 → 5, population 5)

Frozen predicate (plan §C2, verbatim):

```
C2_TERMINATES: terminated = 1 iff a single invocation
`bash plans/round-64-c2.sh --tree <candidate>` from a clean scratch root prints
exactly one `C2_REFUSAL: killed=K population=5 guard=G (…) ` line and exits with the
counter's own exit code inside `timeout 1200`, AND that invocation's `killed` equals
the sum of the five round-63 legs as measured by the round-63 counter's own selftest
legs on the same tree. Target terminated=1 with killed=5 population=5 guard=1
(BASE terminated=0: the round-63 counter read `rc=124` at 900s and 1500s and the
committed receipt is 7 bytes).
GUARD = 1 iff, on the same measured tree: (a) the round-63 C2 counter's `--selftest`
exits 0 printing `C2R63_SELFTEST: PASS`; (b) a tree with the recursion bound removed
(`C2_RECURSION_BOUND=0`) does NOT terminate inside `timeout 240` (the bound is real,
not decorative); (c) the five legs still fire individually (L1/L2 print a named
finding, L3/L4 read mismatch, L6 reads `C1_CHECK_SELFTEST: FAIL`); (d) the round-63
controls battery's existing controls still match with 0 skips.
```

The five legs are round 63's, unchanged: L1 (CM2a), L2 (CM2b), L3 (D12), L4 (D-6), L6
(GM5). The "killed or shown equivalent" contract the legs serve is grounded in the
peer-reviewed equivalent-mutant statements this round admits — `S145` (ISSTA '24: *an
equivalent mutant is a mutant which cannot be killed by any test*), `S146` (*Advances in
Computers* survey chapter: *computing the mutation score requires the removal of
equivalent mutants*) — beside the three already mined in round 63 (S137, S139, S140) and
the tool-level companion `S147` (Stryker: *there is no definitive way for Stryker to
find and ignore them*).

Readings:

- **BASE (the L1's committed measurement):** the round-63 counter reads `rc=124` (no
  verdict line) at 900 s and 1500 s — the committed receipt
  `.ufo/waves/round-63/final/c2-refusal.txt` is 7 bytes — and the L1 re-measures it at
  BASE with `timeout 240 bash plans/round-63-c2.sh --tree .` ⇒ `rc=124`, recorded at
  `.ufo/waves/round-64/base/c2-e2e-head.txt` (7 bytes, `rc=124`). Reading: terminated 0.
- **Candidate (this seat's own working-tree measurement, a point observation of a moving
  tree — not the L1's receipt):** one bounded invocation **reached its verdict line**
  — `C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1
  real=0 terminates=1 bound=1)`, elapsed 749 s inside the 1200 s budget. So the
  end-to-end line the round-63 counter could never print now prints, and the five legs
  all fire (`l1=l2=l3=l4=l6=1`). **The guard reads 0**, and the guard's own detail line
  says which leg failed: `guard a=1 r63selftest=1 b=1 c=0 d=1 e=1` — leg (c), the real
  trial (`the tree's plans/round-62-c2.sh --tree TREE` still reading
  `value=5 shims=5 vectors=ok/5`), did not read 1 on the working tree. That leg starts
  throwaway OpenBao servers and is host-load sensitive; the counter itself says so in
  its header and retries it twice. The reading is therefore: terminated 1, killed 5, and
  **guard 0** — the claim's target (`terminated=1 … guard=1`) is not met on these bytes.
  An earlier working-tree run of the same counter, at different bytes, aborted with
  `plans/round-64-c2.sh: line 345: dir: unbound variable` before any verdict line.
  This seat does not own `plans/round-64-c2.sh` and did not edit it (M64-2).
- **Named ceilings.** `terminates=1` is a termination claim, not a correctness claim
  about the number 5: the five legs are round 63's, unchanged, and a leg that fires for
  the wrong reason still counts. The bound is an environment flag, not a proof:
  `C2_RECURSION_BOUND=0` re-enters by construction, and a caller who sets it to 0 gets
  the old behaviour. The revenger's measurement of the recursion adds the shape the
  bound must close: the only true cycle is
  `round-63-c2.sh:198 → round-63-controls.sh:460 → round-63-c2.sh`, with no depth
  counter, no re-entry guard and no narrower timeout, and a killed outer shell does not
  stop it — the chain survives, reparents and keeps recursing (6 nested levels, 20 live
  processes, 167 s after launch, one new level per ~25 s, each level leaking its `$WORK`
  directory)
  (`.ufo/waves/round-64/build/R64Revenger/recursion.md`; `w1/R64Revenger.md`).

## Gate

Twenty pages were opened live this round (access date **2026-11-08** for every page;
the scout's ledger is `.ufo/waves/round-64/capture/notes.md`, 20 page blocks; the
locate transcript is `.ufo/waves/round-64/build/R64ScoutSources/locate-output.txt`,
27 probes). The captured bodies are `.ufo/waves/round-64/capture/S143.body`,
`S145`…`S163`; the header receipts are
`.ufo/waves/round-64/build/R64ScoutSources/h<id>.hdr` (cookie-filtered; measured
`grep -ciE '^(set-cookie|cookie):'` ⇒ 0 for every receipt).

**Every quote below was re-resolved by this seat** with
`python3 corpus/rendered-text-v1.py locate .ufo/waves/round-64/capture/<file> "<quote>"`
against the committed capture bodies, not against the scout's ledger text; the outputs
are in `build/R64ScribeRecords/records.md` §R4 (L1–L30). Every admitted quote resolves
`count=1`. The registry rows are drafted in `build/R64ScribeRecords/sources-block.md`
(the L1 appends them, with fresh ids; the registry ends at `S144` today, so the next free
id is `S145`).

The capture file names below are **capture handles, not registry ids** — the scout's
ledger says so explicitly, and the id allocation is the L1's. A handle that is a
byte-identical re-open of an already-mined row mints no new row.

| handle | URL | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|
| S143 | https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode | `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)` (17 words; §3.1.2, BioC XML; capture 264946 B, sha256 `3b8d4e15…cba40`; locate `count=1`) | admit, tier A — supersedes `S143` | the round's freshness item: the ConText carrier re-opened on the current endpoint. The measured delta against the `S143` pin is **exactly one byte** — `<date>20261107</date>` → `<date>20261108</date>`, the service's own request-date stamp (`cmp -l` ⇒ one differing byte at offset 127; byte count unchanged) — and the shape holds (`<passage>` 182→182, `<text>` 180→180, the §3.1.2 heading at offset 17212). The registry must not keep presenting the stale digest as current, so the L1 supersedes the row per CORPUS.md rule 2, with representation `decoded-http-body-volatile-v1`. flip: a re-fetch that moves the article content (not the date stamp) would supersede it with different `teaches`; a service that stopped stamping the date would restore byte-reproducibility of the pin |
| S145 | https://pitest.org/quickstart/mutators/ | `Pitest will filter out equivalent mutations to methods that are already hard coded to return the empty value.` (17 words; the operator-design remarks; capture 67033 B, sha256 `a31331da…02da2`; locate `count=1`) | reject | the page mentions "equivalent mutations" 11 times, but every occurrence is about operator design and PIT's own filtering — the phrases `cannot be killed` / `can never be killed` / `never be killed` / `cannot kill` occur **0** times in the body, and the page states neither the definition nor the consequence. It is the mutators catalogue, not the rule's statement. flip: a PIT page that states the equivalent-mutant definition together with the cannot-be-killed consequence |
| S146 | https://stryker-mutator.io/docs/ | `If your tests fail then the mutant is killed . If your tests passed, the mutant survived .` (17 words; the killed/survived paragraph; capture 30253 B, sha256 `185130082d…c9e8e`; locate `count=1`) | re-open — no new row | **byte-identical** to the round-62 capture of the same URL (`cmp` ⇒ identical), so the already-mined row `S129` reproduces its pinned digest exactly; admitting it again would duplicate a URL. The distinct Stryker page that does carry the equivalent-mutant statement is S151 below. flip: n/a — the row exists and its digest did not move |
| S147 | https://pitest.org/ | `If your tests fail then the mutation is killed , if your tests pass then the mutation lived .` (19 words; the front page; capture 12023 B, sha256 `b0c7e05…bf10cc`; locate `count=1`) | re-open — no new row | byte-identical to the round-62 capture of the same URL (`cmp` ⇒ identical): the already-mined row `S128` reproduces. Measured consequence for this round: the PIT **home** page carries **0** occurrences of "equivalent" — PIT's front page does not state the rule at all. flip: n/a — the row exists and its digest did not move |
| S148 | https://arxiv.org/abs/1909.02196 | `the quantum approximate optimization algorithm` (7 words; the page's own abstract subject; capture 39750 B, sha256 `fabc74c5…9f15`; locate `count=1`) | reject | the identifier resolves to *"Effects of Quantum Noise on Quantum Approximate Optimization Algorithm"* — a quantum-noise paper, not a mutation-testing paper; the body carries 0 occurrences of "mutat". The arXiv id was a mis-derivation from a web-search snippet, recorded so the sweep is not repeated. flip: n/a — the identifier is occupied by an unrelated paper |
| S149 | https://en.wikipedia.org/wiki/Mutation_testing | `there are cases where it is not possible to find a test case that could kill this mutant` (18 words; the equivalent-mutant paragraph; capture 171636 B, sha256 `4b5a8374…92884`, page revision `oldid=1373580212`; locate `count=1`) | reject | the round's **designated weak lead**, rejected on **source class, not on content**: the page *does* carry the consequence sentence and *does* cite the primary work (measured in the body: `Jia` 5, `Harman` 8, `IEEE` 12, `citation` 24), but it is community-edited with no editorial gate, and the registry already admits peer-reviewed carriers for this rule (`S137`/`S139`/`S140`, plus this round's `S145`/`S146`). A mutable third-hand restatement beside a peer-reviewed statement of the same rule adds no ground and adds an editable source class. flip: an authoritative-publisher version of the same article with editorial sign-off (a reviewed encyclopaedia) would change the verdict |
| S150 | https://api.github.com/repos/openbao/openbao/git/trees/main?recursive=1 | `"truncated": false` (2 words; the tree listing's completeness marker; capture 1930379 B, sha256 `f996c36d…0768c`; locate `count=1`) | reject as a row / admit as sweep evidence | the sweep is the finding and it is negative: the tree listing is complete (**6363** path entries, `"truncated": false`) and **0** of those paths contain `mutat`, and the string `mutat` occurs 0 times in the whole body. The lane's own product tree carries no mutation-testing directory, mutator package or equivalent-mutant document. flip: an OpenBao file or directory that states a mutation-testing or equivalent-mutant rule would make this candidate admissible |
| S151 | https://stryker-mutator.io/docs/mutation-testing-elements/equivalent-mutants/ | `even if we change >= to <= and even < or > we will get the same output each time!` (20 words; §"Mutation Testing Elements → Equivalent mutants", the worked example; capture 38687 B, sha256 `00082805…63cd5`; locate `count=1`) | admit, tier A | the plan's **tool-level** statement of the equivalent-mutant rule, from a vendor independent of PIT and on a distinct URL from the already-mined `S129`: a mutation that leaves the output identical is an equivalent mutant, and the tool says plainly that there is no way to separate it automatically (*There is no definitive way for Stryker to find and ignore them.*, 11 words, locate `count=1`). The ground the C2 kill contract's "killed **or shown equivalent**" wording needs at the tool level. The plan prefers a peer-reviewed carrier where one is reachable (S153, S154 below); this is the companion, not a substitute. flip: a revision that removes the "same output each time" formulation, or a merge of the page into the `/docs/` home (which would duplicate `S129`'s URL) |
| S152 | https://raw.githubusercontent.com/openbao/openbao/main/CONTRIBUTING.md | `PRs should include unit tests that` (8 words; the contribution policy; capture 17760 B, sha256 `6e6bffb0…d3ca7c`; locate `count=1`) | reject / sweep evidence | the lane's own domain again: measured occurrences of `mutat` = **0** and of `equivalent mutant` = **0**. The document asks for unit tests and describes the review flow; it never states a mutation-testing or equivalent-mutant rule, so the rule this round's C2 evidence cites has no OpenBao-side counterpart. flip: an OpenBao contribution/testing document that adopts a mutation-testing or equivalent-mutant rule |
| S153 | https://mutationtesting.uni.lu/survey.pdf | `Computing the mutation score requires the removal of equivalent mutants.` (10 words; §5 "Computing the mutation score", PDF page 40; capture 1129278 B, sha256 `63b7bfca…15f023`; quote located in the committed page-scoped text layer `S153.p40.txt`, 2291 B, sha256 `56253f98…951bd`; locate `count=1`) | admit, tier A | the plan's **preferred** carrier ("if a peer-reviewed survey chapter is reachable, prefer it"): Papadakis, Kintis, Zhang, Jia, Le Traona, Harman, *Mutation Testing Advances: An Analysis and Survey*, **Advances in Computers** vol. 112, pp. 275–378, Elsevier 2019 (DOI `10.1016/bs.adcom.2018.03.015`; the venue, pages, publisher and `book-chapter` type are confirmed independently by the Crossref record opened as S163 below). It grounds the rule in the field's survey literature: an equivalent mutant is *semantically equivalent to the original despite being syntactically different* (§5.3, PDF page 28), its detection is a *well-known undecidable problem* (§5.3.1, PDF page 29), and the mutation score therefore *requires their removal* (§5, PDF page 40) — exactly the separation a kill count over a mixed population must make. **Measured representation defect, disclosed not worked around:** these three quotes locate **0** times in the whole-document text layer `S153.txt` and **1** time each in the page-scoped layers, because the declared normalizer's tag rule swallows 137657 bytes of that layer (the PDF text carries comparison operators); the row therefore anchors on the page-scoped layers, as the round-63 `S139` PDF row anchors on its text layer. flip: a revision of the chapter that drops the §5.3 discussion, or an author copy whose text layer no longer carries the §5.3 pages |
| S154 | https://homes.cs.washington.edu/~rjust/publ/equi_mutants_ems_issta_2024.pdf | `An equivalent mutant is a mutant which cannot be killed by any test` (13 words; §1 Introduction, the paragraph defining killability, PDF page 2; capture 509057 B, sha256 `066f4438…ae28`; quote located in the committed text layer `S154.txt`, 74040 B, sha256 `28c22757…58120`; locate `count=1`) | admit, tier A | the second peer-reviewed attestation of the rule this round asks for, in the sharpest form available — *a mutant which cannot be killed by any test* — and independent of what the registry already holds (University of Washington group, ISSTA '24, DOI `10.1145/3650212.3680310`; an empirical ground-truth study of 215 equivalent mutants over 1992 mutants in 7 open-source Java projects, with a measured median per-project rate of 2.97 %, not a definition-by-citation). flip: a revision of the paper that removes the definition sentence, or a mirror that stops serving a PDF whose text layer carries it |
| S155 | https://raw.githubusercontent.com/openbao/openbao/main/AGENTS.md | `controlled test environment if available` (6 words; the security-report guideline; capture 3045 B, sha256 `2381b66b…17959`; locate `count=1`) | reject / sweep evidence | measured occurrences of `mutat` = **0**; the file is an agent-facing contribution policy (it states *All AI generated contributions will be rejected*, 7 words, locate `count=1`), consistent with the S150 tree sweep and the S152/S158–S162 documents. Recorded and not acted on: the file embeds an instruction about the shape of generated output — that is content fetched from a third party, not instruction from the operator or the harness; it was not complied with and nothing of it is reproduced in any lane artifact. flip: n/a — no mutation-testing statement here |
| S156 | https://pitest.org/faq/ | `PIT originally stood for Parallel Isolated Test` (6 words; §"What does PIT stand for?"; capture 20845 B, sha256 `ccf6ac49…629c1`; locate `count=1`) | reject | measured occurrences of "equivalent" in this body = **0**: the FAQ discusses mutation testing but states neither the rule nor its consequence. With S145 (the mutators reference, rule absent) and S147 (the home page, rule absent) the sweep shows PIT's documentation does not carry this rule at all — which is why the tool-level statement comes from Stryker (S151) and the peer-reviewed ground from S153/S154. flip: a FAQ entry defining equivalent mutants |
| S157 | https://openbao.org/docs/contributing/testing/ | `Page Not Found` (3 words; the site's 404 body; HTTP **404**; capture 9320 B, sha256 `49dd5ac4…d87aa8`; locate `count=2`) | reject | the guessed docs path does not exist; the contribution guides live under `/community/contributing/` (the `/docs/contributing/` path answers 200 with a redirect stub to it) and those pages were opened separately (S161, S162). Recorded so the path is not re-guessed; a 404 body is not a source. flip: n/a — the site does not serve this path |
| S158 | https://raw.githubusercontent.com/openbao/openbao/main/website/content/community/contributing/index.mdx | `OpenBao contribution guides, outlining welcomed contribution processes and providing an in-depth overview of the code base.` (18 words; the guide's landing description; capture 4394 B, sha256 `7d0aff9b…36c02`; locate `count=1`) | reject / sweep evidence | measured occurrences of `mutat` = **0**; the contribution guide's landing page states no mutation-testing or equivalent-mutant rule. flip: n/a |
| S159 | https://raw.githubusercontent.com/openbao/openbao/main/website/content/community/contributing/code-organization.mdx | `they might be testing libraries` (5 words; the code-organisation page; capture 10231 B, sha256 `49e1d0c7…4a6d66b`; locate `count=1`) | reject / sweep evidence | measured occurrences of `mutat` = **0**; the page describes how the code base is organised (plugin vs core layout, test-cluster helpers) and says nothing about mutation testing. flip: n/a |
| S160 | https://raw.githubusercontent.com/openbao/openbao/main/.github/workflows/test-go.yml | `name: Run Go tests` (4 words; the CI workflow's step name; capture 13191 B, sha256 `303ba75d…29ffa76`; locate `count=1`) | reject / sweep evidence | measured occurrences of `mutat` = **0**; the workflow runs the project's Go test matrix (including race and FIPS configurations) and says nothing about mutation testing or equivalent mutants. flip: n/a |
| S161 | https://openbao.org/community/contributing/ | `Disable all generative AI agents while working on OpenBao!` (10 words; the contribution policy's AI clause; capture 25357 B, sha256 `c445a962…9ebf218`; locate `count=1`) | reject / sweep evidence | measured occurrences of `mutat` = **0**; the quoted line is the project's policy on AI-assisted contributions — a fact about its submission rules, not a mutation-testing rule. No equivalent-mutant statement here either. flip: n/a |
| S162 | https://openbao.org/community/contributing/code-organization/ | `five main modules` (3 words; the rendered code-organisation page; capture 32988 B, sha256 `25c57615…fccfcda`; locate `count=1`) | reject / sweep evidence | measured occurrences of `mutat` = **0**; the rendered page mirrors S159 and adds no mutation-testing content. flip: n/a |
| S163 | https://api.crossref.org/works/10.1016/bs.adcom.2018.03.015 | `"container-title"` (1 word; the Crossref record's container field; capture 88534 B, sha256 `68cee300…c4b6a40`; locate `count=1`) | not a registry row — identity evidence for S153 | the machine-readable authority for the peer-reviewed status of the S153 carrier, fetched from a different host than the PDF itself: `title` "Mutation Testing Advances: An Analysis and Survey", `container-title` ["Advances in Computers"], `page` "275-378", `publisher` "Elsevier", `type` "book-chapter", `issued` 2019, for DOI `10.1016/bs.adcom.2018.03.015`. The S153 row must not rest on the publisher's own site. Its located title string reads `count=2` in the body (the title occurs in the `title` array and in the reference list), so it could not carry a unique ≤25-word quote as a row's own anchor. flip: n/a — identity evidence |

Registry effect (the L1's append): `corpus/SOURCES.md` 143 → 153 data rows (ten new
rows: four admitted — the ISSTA '24 paper, the survey chapter, the Stryker page, the
re-verified BioC deposit — and six rejected; the two byte-identical re-opens and the
Crossref record mint no rows). The row block is
`build/R64ScribeRecords/sources-block.md`, with the matching `corpus/source-fetches.tsv`
rows in the same file (the census requires one provenance row per registry id, and the
registry-identity digest of each row is computed in `records.md` §R6). The four mined rows
are cited by this lesson's `cites:` line and, for `S145`, also by the round's knowledge
entry `corpus/knowledge/claim-instrument-heldout.md`.

## Mistakes

| id | class | evidence pointer | captured-by | fix (and how it can fail) |
|---|---|---|---|---|
| M64-1 | **census vs measurement — a population census that is asserted, not re-derived** | the pre-amendment census in `plans/round-64.md` §C1 read "F1..F10 accepted, P1..P6 rejected, B3..B5 controls" and was **wrong for 10 of 19 rows**: F1/F5/F9 (and B3) are already rejected at BASE, F3/F4 are already accepted correctly (hedge, idiom), P1/P2/P3/P5 are already accepted at BASE, P4 was an unmeasured slim-tree artifact, and B4 is accepted at BASE (so it cannot be a control) — measured by the L1's own re-measurement on an extracted `09cbee8` tree, `.ufo/waves/round-64/base/census-a1.md`, and stated in plan §Amendment A1 ("wrong for 10 of 19 rows"). **Nobody caught it**: the census was written into the frozen plan and the sealed table together, so the plan and the table agreed with each other and neither could falsify the other. It survived only because the L1 re-measured every row per fixture before freezing | the L1 (Amendment A1), before the wave; the defect is recorded here by R64ScribeRecords | the fix is that **a population census is re-derived per fixture before it is frozen** — the census is a table of one measured reading per fixture id (value plus i-bits), not a class-level assertion, and the counter re-derives it rather than trusting the plan. **Able to fail**: the amended census is re-measured by the committed counter, so a census that mis-states a row's BASE reading makes the counter's own `heldout` count disagree with the plan's and the claim's BASE reading is falsifiable; the pre-amendment shape (a class-level statement) is exactly what cannot fail, and the sealed table's sha was re-sealed (`7ed35491…` → `b0f51e2a…`) |
| M64-2 | **instrument vs claim — a counter that cannot print its verdict line** | on the working-tree bytes this seat measured, `bash plans/round-64-c1.sh --tree .` reaches the measure leg and prints its provenance lines (`H accepted=0/5 … Q rejected=0/3`, `per-fixture F2=value1 … P7=value0`, `unmodified value=0 bits=i1=1 … i7=1`) and then aborts with `plans/round-64-c1.sh: line 620: stub2_e2: unbound variable` — so **no `C1_HELDOUT:` line and no exit code exist** for those bytes; the C2 counter on the working tree aborted at its own bytes with `plans/round-64-c2.sh: line 345: dir: unbound variable` before any `C2_REFUSAL:` line (records.md §R8, §R9). Both counters' bytes changed again after the measurement (C1: `7bb321f2…` → `dabeffdb…` → `ca6dec9b…`; C2: `36e3b5fb…` → `f7cddb03…` → `b1e8429f…`), so this is a reading of a moving instrument, not a verdict | R64ScribeRecords (this seat), 2026-11-08 | a counter that aborts before its verdict line can be read as a verdict by nobody: the frozen output contract says the verdict line is the only reading. The fix is the counter's own (`set -u` plus an initialised `stub2_e2`/`dir`, so an aborted leg cannot leave the receipt without a line). **Able to fail**: a counter whose guard leg cannot complete prints no verdict line, and the plan's exit contract (0 iff `guard=1` and `heldout=0`, 1 otherwise, 2 SETUP) is then unobservable — a receipt with no line is a SETUP, not a pass. This seat does not own either counter and edited neither; the defect is reported, not repaired |
| M64-3 | **receipt vs instrument — a stated rule that the code does not implement** | the C1 counter's guard line reads `c1-heldout: selftest rc=0 pass=1 cases=91 (guard floor 109)` on the working tree, while the tree's own checker prints `C1_CHECK_SELFTEST: PASS (cases=110)` — measured directly (`python3 -I -B plans/round-61-c1-check.py --selftest` ⇒ `cases=110`, rc 0) and on the documented slim copy the counter measures (the seven checker inputs, extracted to scratch ⇒ `cases=110`, rc 0). The counter's bytes show the mechanism: `measure_heldout` sets the global `ST_PASS`/`ST_N` from whichever tree it measures, the guard legs `stub` and `vehicle` each call `measure_heldout` on their **own** tree, and the guard echo printed the live global — so the tally the receipt carried was the **stub tree's**, not the measured tree's (91 is the A4 vehicle's constant). The counter's bytes changed again after the measurement and now snapshot `MEASURED_ST_N` before those legs run, so the defect may already be repaired; it is reported as observed on the bytes named | R64ScribeRecords (this seat), 2026-11-08 | the class is the round-63 M63-4 class, one round later: a receipt whose stated rule is not the rule its code implements. The fix is that the counter's guard leg (b) reads the **measured tree's** selftest tally — a snapshot taken before any other leg measures a tree of its own — rather than a global that a later leg overwrites. **Able to fail**: a counter that reads a foreign tally reports a case count the measured tree never produced; the guard then fails (or passes) on a number its own header does not name |
| M64-4 | **record vs artifact — a lesson whose "already re-verified" claim is a point observation** | `plans/round-64.md` §Frontier step 2 requires the S143 BioC deposit to be re-verified and the row superseded if the bytes moved; the capture ledger's claim ("the shape still holds") is the scout's, and this seat re-derived the one-byte delta and the shape census itself (records.md §R3) — but the *fetch* of the deposit is a point attestation with a daily-moving digest, and the row's representation must say so (`decoded-http-body-volatile-v1`), or the next round's reader will treat the pinned digest as reproducible | R64ScribeRecords (this seat) | the fix is the row's own representation field plus the superseding row's `teaches`, which names the measured delta (one byte, the service's date stamp) and the shape census that still holds. **Able to fail**: a volatile representation is the only thing that stops the next re-verification from reading a daily digest change as a content change — the difference between "the deposit moved" and "the service stamped today's date on it" |

## Routed dispositions

| id | spot-check §6 | item / file that carries the fix | state at write |
|---|---|---|---|
| D-63-1 | §6 D-63-1 — the lookup-table guard vacuum (M63-6) | the C1 claim's guard leg (e): the A4 vehicle (a checker carrying a literal `NEGATORS = frozenset(())` dead line, a 15-string lookup over the round-63 residual/bypass tables and a constant `PASS (cases=91)`) must NOT reach `heldout=0` on the sealed held-out set, and must still read `accepted=0 rejected=0` on the round-63 tables to be the vehicle at all; `plans/round-64-c1.sh` builds and runs it (`leg_vehicle`), and `plans/round-64-routed.sh` leg `d1` re-derives it with the seal checked first | the counter exists in the working tree with a `vehicle` guard leg; this seat measured the vehicle's round-63 reading (`accepted=0 rejected=0 population=10/6 guard=0 (real=1 selftest=1 prior=1 para=1 stub=1 chal=0)`) but **not** its held-out count, because the run aborted before the vehicle line (M64-2); leg `d1` is the routed receipt's |
| D-63-2 | §6 D-63-2 — the C2 nested-battery recursion (M63-LEN) | the run-64 counter's explicit recursion bound `C2_RECURSION_BOUND` (default 1): at 1 the counter's l3/l4 battery delegation runs with `R63_CONTROLS_FIXTURE_ONLY=1` so the leg never re-enters a counter; at 0 it delegates to the full battery, which re-enters and does not terminate; `plans/round-64-c2.sh` names the bound in its header and in its verdict line (`bound=`), and `plans/round-64-routed.sh` leg `d2` requires **both** halves — one bounded run that prints exactly one `C2_REFUSAL:` line inside 1200 s, and one `C2_RECURSION_BOUND=0` run that prints no line and exits 124 inside 240 s | the counter exists in the working tree; this seat measured the bounded side (`terminates=1 bound=1`, `killed=5`, elapsed 749 s) but **not** the refutation side, so the bound is not yet shown to be load-bearing from this seat's readings; leg `d2` is the routed receipt's |
| D-63-3 | §6 D-63-3 — carried (the round-63 reviewer's D-A/D-B/D-C errata: the corrections line, the six `final/` receipts, the case enumeration) | all landed in round 63; the round-64 routed receipt carries it as leg `d3` (the six round-63 `final/` receipts exist with their label lines, and the round-63 lesson names all six) | carried; nothing open |

## considerthese

**No still-unimplemented proposal is mined this round.** The latest `considerthese/`
file is `2026-10-26.md`, and its proposal 3 ("Mark known-defective instrument output")
was mined in round 63 — landed as QM83/QM84, recorded as M63-5 there, and the round-64
lesson cites no proposal from that file. This is recorded as a sentence and nothing is
amended: `considerthese/` was read, never edited (round 64's QUALITY criteria QM85/QM86
come from the routed defects, not from a `considerthese/` proposal).

## Wave

`kagi-r64-w1`, 16 seats v1 (plan §Wave; `.ufo/waves/round-64/w1-dispatch.json`; reports
`.ufo/waves/round-64/w1/`): 2 scout, 5 executor, 2 scribe, 1 reviewer, 1 critic,
2 mutation-tester, 1 connector, 1 sentinel, 1 revenger. Attack share 4/16 = 25 % on the
addendum's literal list (reviewer, critic, mutation-tester ×2; no labrat seat exists),
5/16 = 31.25 % counting the sentinel. The L1 holds the canonical planner seat and is
the sole integration owner and committer. Settled seats (results
`.ufo/waves/round-64/w1-results.json`): 16 of 16 carry a non-empty final output — dead
seats 0 — and one (`R64ExecControls`) delivered receipts plus its final output instead of
a `R64ExecControls.md` report file.

## Bounds

- The `## Gate` quotes are the scout's located rows in `capture/notes.md`, **re-resolved
  by this seat** with `corpus/rendered-text-v1.py locate` against the committed capture
  bodies; the locate outputs are in `build/R64ScribeRecords/records.md` §R4. A `count=1`
  proves the string occurs once in the captured body, not that the page says what the
  row's `teaches` cell claims.
- The capture file handles in the `## Gate` table are the scout's fetch-ledger handles,
  **not registry ids**; the ids are the L1's to assign and the row block
  (`build/R64ScribeRecords/sources-block.md`) proposes `S145`–`S154` against the
  registry's next free id (`S145`).
- The claims' BASE readings are the L1's committed census
  (`.ufo/waves/round-64/base/census-a1.md`, `.ufo/waves/round-64/base/c2-e2e-head.txt`).
  The **candidate** readings in this section are this seat's own working-tree
  measurements at the counter bytes named beside them — point observations of a moving
  tree, not the L1's candidate receipts. Neither counter printed its verdict line on the
  bytes this seat measured (M64-2); the C2 line that *was* reached reads `guard=0` on
  guard leg (c) (the real trial), so the C2 target is not met on these bytes. Two further
  runs this seat started were **withdrawn** and are recorded in `records.md` §R12b: one
  was killed mid-measurement and one had its evidence files deleted underneath it —
  neither is a candidate reading.
- This seat did **not** read `plans/round-64-heldout.tsv`'s rows: the seal's sha256 was
  verified over the file, and the held-out readings are re-derived from the counters'
  own output lines. No fixture string from the sealed table is reproduced in any
  artifact this round wrote.
- The `## Mistakes` rows are this round's own mistakes and the measurements behind them;
  the attack seats' findings (the critic's C1-1 … C2-6 and the revenger's recursion
  analysis) are cited where they are used, and are this seat's summary of their
  receipts, not new measurements of this seat.
- The `## Wave` paragraph is the plan's wave shape; the seat verdicts are the L1's.

## Corrections (L1, integration)

- **M64-2's bytes are not the landed bytes.** The seat measured `plans/round-64-c1.sh` at
  `7bb321f2…`/`dabeffd…` and `plans/round-64-c2.sh` at the bytes that aborted in their
  stub/battery legs. On the landed instruments (`plans/round-64-c1.sh` sha256
  `e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484`;
  `plans/round-64-c2.sh` sha256 `e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b`)
  the L1 measured `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1
  stub=1 vehicle=1)` rc 0 and `C2_REFUSAL: killed=5 population=5 guard=1 (… terminates=1
  bound=1)` rc 0; the abort the seat recorded is a defect of those earlier bytes, fixed by
  the seats that owned them before settlement.
- **M64-3's `cases=91` echo is not on the landed bytes.** The counter's guard echo now
  reads `selftest rc=0 pass=1 cases=111 (guard floor 109)` — the tree's own checker count —
  and the vehicle leg prints its own reading separately (`vehicle heldout=5 r63=1`), so the
  clobbered-global mechanism the seat described is not observable at integration.
- **`ROUTED: d3=0` is the landed reading, not a defect of this round's instruments.**
  `plans/round-64-routed.sh` leg `d3` requires the six receipts the round-63 spot-check's
  D-B names; the round-63 tree holds five (`ls .ufo/waves/round-63/final/`). The leg is
  left as frozen and the missing receipt is routed to round 65 (SCORECARD §Round 64 —
  planned item 2), because a leg whose expectation no tree can meet is a defect (QM57) and
  the honest reading is the one the tree supports.
