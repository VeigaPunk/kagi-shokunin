# Round 64 — source capture notes (R64ScoutSources)

Seat: `R64ScoutSources` (scout; axes freshness, coverage). Plan `plans/round-64.md`
§Frontier step. Access date for every page below: **2026-11-08**.

Fetch method (every page, without exception):

```
curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed
```

The captured bytes are curl's **decoded** body (`--compressed` decompressed the
`content-encoding: gzip` / `zstd` transfer), so every `sha256sum` here is over the
decoded body — the lane's `decoded-http-body-v1` convention
(`corpus/source-fetches.tsv` column 8).

Byte counts and digests below are `stat -c%s` and `sha256sum` of the committed capture
file in this directory (`.ufo/waves/round-64/capture/`). Response headers are in
`.ufo/waves/round-64/build/R64ScoutSources/h<id>.hdr`.

> **Capture handle ≠ registry id.** The capture file names below (`S145…S163`) are
> *handles for this seat's fetch ledger*, not registry row ids. `corpus/SOURCES.md`
> currently ends at `S144`; the rows this round admits will be appended by the L1 with
> **fresh** ids. A "proposed registry id" is named per block below so the L1 has an
> unambiguous mapping, but the L1 owns the ids and may renumber. Nothing in this file
> may be read as an id allocation.

## Secret discipline

* No `Set-Cookie` / `Cookie` header value was written to any capture, note or receipt.
  The NCBI response carried a `set-cookie:` line (S143); it was filtered out **before**
  writing the header receipt (`grep -viE '^(set-cookie|cookie):'`). Measured:
  `grep -ciE '^(set-cookie|cookie):' build/R64ScoutSources/h*.hdr` ⇒ **0 for all 21
  header receipts**.
* Token scan over every capture body and text layer
  (`csrfmiddlewaretoken" value="[A-Za-z0-9]{20,}"`, `"csrfToken":"[A-Za-z0-9]{20,}"`,
  `ncbi_sid=`, `api_key`, `Authorization: Bearer`): **0 hits in all 26 files** (20 bodies
  + 6 text layers).
* Raw (unfiltered) header scratch was written only under `/tmp` and **deleted** after
  filtering; no citable evidence lives under `/tmp`.

## Quote resolution

Every quote below was resolved with

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-64/capture/<file> "<quote>"
```

and the printed output is reproduced verbatim. Full transcript (27 probes):
`.ufo/waves/round-64/build/R64ScoutSources/locate-output.txt`.

**Text layers.** Two captures are PDFs, whose bytes are not strict UTF-8, so
`rendered-text-v1` exits 2 (`SETUP (not strict UTF-8)`) on the PDF itself. Following the
round-63 precedent (`S139.body` + committed `S139.txt`), the quotes are located in the
`pdftotext` **text layer** of the same committed PDF:

* `S154.txt` — `pdftotext S154.body S154.txt` — 74040 B,
  sha256 `28c22757733c1e4dd02503849b52e5bb25e8b75b6acc359816ab4d2012958120`.
* `S153.txt` — `pdftotext S153.body S153.txt` — 294184 B,
  sha256 `051e5a6537944be5886a8a9407a2844bacdbfe38298651fc79827c684df8776d` — **plus**
  page-scoped layers `S153.p17.txt` / `S153.p28.txt` / `S153.p29.txt` / `S153.p40.txt`
  (`pdftotext -f N -l N S153.body …`), digests recorded per block below. The page-scoped
  layers are needed for a **measured** reason, stated in the S153 block.

**S144 note:** no `S144` capture exists in this directory — that id was not fetched by
this seat in round 64.

---

## S143 — BioC/ConText deposit re-opened on the current endpoint (freshness item 3) — https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **264946**
- sha256: `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`
- Capture: `.ufo/waves/round-64/capture/S143.body`
- Committed pin it is re-verified against (round-63 registry row `S143`):
  sha256 `8522a79eba84604f4dbb37e0b46fa7a28c80eec69d00eaf5efecceef543c7208`, **264946 B**.
- **Measured delta vs the pin: the byte count is unchanged (264946 → 264946) and exactly
  ONE byte of the body differs.** Measured with
  `cmp -l round-63/capture/S143.body round-64/capture/S143.body` ⇒ a single differing
  byte at offset 127; the surrounding text is
  `<source>BioC-API</source><date>20261107</date>` → `<source>BioC-API</source><date>20261108</date>`
  — i.e. the BioC service stamps the deposit with the **request date**. The sha256
  therefore differs from the pin even though the served article content is unchanged.
- **Does the shape still hold? YES — measured.** Structure census of the two bodies:
  `<passage>` elements 182 → 182, `<text>` elements 180 → 180, `<document>` 1 → 1;
  the §3.1.2 heading `3.1.2 Trigger Terms, Pseudo-Trigger Terms, and Termination Terms`
  is present at byte offset 17212; the pseudo-trigger sentence at offset 19029 and the
  termination-term sentence at offset 19652 — all unchanged.
- Located quote (≤25 words, **17 words**) — the pseudo-trigger class:
  `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**19 words**) — the termination-term class:
  `Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — the peer-reviewed ConText paper served as a
  BioC XML deposit) — **and the L1 must supersede `S143`** per `CORPUS.md` rule 2: the
  re-fetched body does **not** reproduce the committed pin's sha256. The change is
  measured to be the service's own request-date stamp, not an editorial change; the
  re-verified shape and both quotes hold.
- Proposed registry id: next free id (L1 assigns), `supersedes S143 —`.
- Reason: this is the round's freshness item 3 — the S143 carrier re-opened on the
  current endpoint. It re-verifies, on 2026-11-08, that the served deposit still carries
  §3.1.2's pseudo-trigger class (`no increase`, `not cause`) and the termination-term
  class with the same shape as the 2026-11-07 pin, and it measures exactly what moved
  (one byte, the date stamp) so the registry can say so rather than leave a stale digest
  presented as current.
- Flip: a re-fetch that changes the article content (not only the date stamp) would
  supersede the row with different teaches; a service that stops stamping the date
  would restore byte-reproducibility of the pinned digest.

---

## S145 — PIT mutation-testing docs, mutators reference — https://pitest.org/quickstart/mutators/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **67033**
- sha256: `a31331daf89f246f3e02c0da92578d4ad2163c53741c3700437e75b9a1602da2`
- Capture: `.ufo/waves/round-64/capture/S145.body`
- Located quote (≤25 words, **17 words**) — the operator-design remark:
  `Pitest will filter out equivalent mutations to methods that are already hard coded to return the empty value.`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**9 words**): `minimise the number of equivalent mutations that they generate`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT** (as a carrier of the equivalent-mutant *rule*).
- Reason (measured, not stylistic): the page mentions "equivalent mutations" **11
  times**, but every occurrence is about *operator design and PIT's own filtering* —
  "minimise the number of equivalent mutations that they generate", "Pitest will filter
  out equivalent mutations to methods that are already hard coded to return the empty
  value". Measured: the phrases `cannot be killed` / `can never be killed` /
  `never be killed` / `cannot kill` occur **0** times in this body, and the page never
  states the *definition* of an equivalent mutant nor the *consequence* that no test can
  kill one. It is the mutators catalogue, not the rule's statement. The tool-level
  statement of the rule belongs to Stryker's own equivalent-mutants page (S151) and,
  better, to the peer-reviewed sources (S153, S154).
- Flip: a PIT documentation page that states the equivalent-mutant definition together
  with the cannot-be-killed consequence would turn this handle into an admissible row.

---

## S146 — Stryker Mutator docs home (re-open of the round-62 `S129` carrier) — https://stryker-mutator.io/docs/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **30253**
- sha256: `185130082d9961cb4cb0d9527f2281e58b2e2126ee2372551193b0decd6c9e8e`
- Capture: `.ufo/waves/round-64/capture/S146.body`
- **Identity: byte-identical to the round-62 capture of the same URL**
  (`cmp round-62/capture/S129.body round-64/capture/S146.body` ⇒ identical). The
  registry row `S129` already carries this URL and digest.
- Located quote (**2 words**, the section heading the row anchors): `An example`
  → `RENDERED_TEXT_V1_LOCATE: count=5`
- **Verdict: RE-OPEN / NOT A NEW ROW.** The existing row `S129` still reproduces
  byte-for-byte on 2026-11-08 — a freshness confirmation, not a new registry row. The
  killed/survived pair it grounds is already mined.
- Reason: it was opened as the plan's named tool-level candidate; the measurement shows
  it is the *same* bytes as a row already in the registry, so admitting it again would
  duplicate a URL. The distinct Stryker page that does carry the equivalent-mutant
  statement is S151 below.
- Flip: n/a — the row already exists and its digest is unchanged.

---

## S147 — PIT home (re-open of the round-62 `S128` carrier) — https://pitest.org/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **12023**
- sha256: `b0c7e0505c51c95b596060ef27babbce08e72d5aaf4557eb002c2637d2bf10cc`
- Capture: `.ufo/waves/round-64/capture/S147.body`
- **Identity: byte-identical to the round-62 capture of the same URL**
  (`cmp round-62/capture/S128.body round-64/capture/S147.body` ⇒ identical). Registry
  row `S128` already carries it.
- Located quote (≤25 words, **19 words**): `If your tests fail then the mutation is killed , if your tests pass then the mutation lived .`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: RE-OPEN / NOT A NEW ROW** — the existing row `S128` reproduces
  byte-for-byte on 2026-11-08. Note the measured consequence for this round: the PIT
  *home* page carries **0** occurrences of "equivalent", so PIT's own front page does
  not state the equivalent-mutant rule at all (see S145 for the mutators reference and
  S156 for the FAQ).
- Flip: n/a — the row already exists and its digest is unchanged.

---

## S148 — arXiv 1909.02196 (candidate lead that resolved to a different paper) — https://arxiv.org/abs/1909.02196

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **39750**
- sha256: `fabc74c534e42232d4bbcd46a638a926b4c6250cd13113fbe5cc51c940ba9f15`
- Capture: `.ufo/waves/round-64/capture/S148.body`
- Located quote (≤25 words, **6 words**): `the quantum approximate optimization algorithm`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT** — dead end, recorded so the sweep is not repeated.
- Reason (measured): the identifier resolves to *"Effects of Quantum Noise on Quantum
  Approximate Optimization Algorithm"* (a quantum-noise QAOA paper), not to any
  mutation-testing paper. The arXiv id was a mis-derivation from a web-search snippet;
  the page's own abstract names QAOA and "quantum approximate optimization algorithm"
  and carries **0** occurrences of "mutat". No registry row.
- Flip: n/a — the identifier is occupied by an unrelated paper.

---

## S149 — Wikipedia, "Mutation testing" (the designated weak lead) — https://en.wikipedia.org/wiki/Mutation_testing

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **171636**
- sha256: `4b5a837439ad81d587eb29bdefbbd4ad0d75232a6ba606f8fff74c6d13092884`
- Capture: `.ufo/waves/round-64/capture/S149.body`
- Revision pinned by the page itself: `oldid=1373580212` (`"wgRevisionId":1373580212`),
  so this capture is a point observation of that revision.
- Located quote (≤25 words, **18 words**) — the consequence, in the wiki's own words:
  `there are cases where it is not possible to find a test case that could kill this mutant`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**13 words**): `Equivalent mutants detection is one of the biggest obstacles to practical usage of mutation testing.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT** (tier C, community-edited tertiary source).
- Reason (measured, not stylistic): the article *does* carry the consequence sentence and
  does cite primary work — measured counts in this body: `Jia` 5, `Harman` 8, `IEEE` 12,
  `citation` 24 — but it is a **wiki page**: editable by anyone, with no editorial or
  peer-review gate, and its authority is derivative of the papers it cites. The lane's
  registry admits a primary/peer-reviewed carrier for the rule (S153, S154 below, and the
  already-mined S137/S139/S140); a wiki duplicate of the same teaching would put a
  mutable third-hand restatement beside a peer-reviewed statement of the same rule. This
  is the round's designated weak lead (§Frontier step 3), and the reject is on source
  class, not on content.
- Flip: an authoritative-publisher version of the same article (a reviewed encyclopaedia
  with editorial sign-off) would change the verdict.

---

## S150 — OpenBao repository tree, `main` (the lane's own domain sweep) — https://api.github.com/repos/openbao/openbao/git/trees/main?recursive=1

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`), `content-type: application/json`
- Bytes: **1930379**
- sha256: `f996c36df16b387281b1d45f2840ba92dfe2141a739450d972bf0d9c4500768c`
- Capture: `.ufo/waves/round-64/capture/S150.body`
- Located quote (**1 word**, the file the sweep keys on): `CONTRIBUTING.md`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT as a registry row / ADMIT as sweep evidence.** The sweep is the
  finding, and it is negative.
- Reason (measured): the tree is complete, not truncated (`"truncated": false`), and
  carries **6363** path entries. Measured over it: **0** paths contain `mutat`
  (`grep -oiE '"path": *"[^"]*mutat[^"]*"'` ⇒ 0) and **0** occurrences of the string
  `mutat` anywhere in the body. There is no mutation-testing directory, mutator
  package, or equivalent-mutant document in the OpenBao tree. The repository's
  *contributing / testing* documents were opened individually as well (S152, S155,
  S158, S159, S160, S161, S162) and none of them mentions mutation testing.
- Flip: an OpenBao file, directory or documentation page that states a
  mutation-testing or equivalent-mutant rule would make this candidate admissible.

---

## S151 — Stryker Mutator, "Mutation Testing Elements → Equivalent mutants" (tool-level statement) — https://stryker-mutator.io/docs/mutation-testing-elements/equivalent-mutants/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **38687**
- sha256: `00082805328e2b5e4ca90d4b990074531dad0d4a9ea16be8fe4271fdf6e63cd5`
- Capture: `.ufo/waves/round-64/capture/S151.body`
- Location: §"Mutation Testing Elements → Equivalent mutants", the worked example and the
  paragraph that names the class.
- Located quote (≤25 words, **20 words**) — the same-output consequence, in the tool's
  own words:
  `even if we change >= to <= and even < or > we will get the same output each time!`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**11 words**) — the consequence for a suite:
  `There is no definitive way for Stryker to find and ignore them.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `docs` — the tool's own documentation, a distinct URL
  from the already-mined `S129`).
- Reason: this is the plan's named *tool-level* statement of the equivalent-mutant rule
  (Stryker is a second, independently maintained vendor from PIT). It states the
  consequence in operational terms — a mutation that leaves the output identical is an
  equivalent mutant and no tool can separate it automatically — which is the ground the
  C2 kill contract's "killed **or shown equivalent**" wording needs at the tool level.
  The plan prefers a peer-reviewed carrier where one is reachable (S153/S154 below);
  this row is the tool-level companion, not a substitute.
- Flip: a revision of the page that removes the "same output each time" formulation, or
  a merge of the page into the `/docs/` home (which would duplicate `S129`'s URL), would
  change the verdict.

---

## S152 — OpenBao `CONTRIBUTING.md` (the lane's own domain sweep) — https://raw.githubusercontent.com/openbao/openbao/main/CONTRIBUTING.md

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **17760**
- sha256: `6e6bffb06505648f564c042b5b52e932019a3c909ddf4b704fd3979504d3ca7c`
- Capture: `.ufo/waves/round-64/capture/S152.body`
- Located quote (≤25 words, **8 words**): `PRs should include unit tests that`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT / sweep evidence — the lane's own domain has no such statement.**
- Reason (measured): `CONTRIBUTING.md` is the project's contribution policy; measured
  occurrences of `mutat` = **0**, and of `equivalent mutant` = **0**. The document asks
  for unit tests and describes the review flow; it never states a mutation-testing or
  equivalent-mutant rule, so the "equivalent mutant" ground the C2 kill contract cites
  has **no** OpenBao-side counterpart. That absence is the finding, and it is why the
  round's C2 evidence is anchored on external peer-reviewed rows rather than on the
  lane's own product documentation.
- Flip: an OpenBao contribution/testing document that adopts a mutation-testing or
  equivalent-mutant rule would make this handle admissible.

---

## S153 — Papadakis et al., "Mutation Testing Advances: An Analysis and Survey" (peer-reviewed survey chapter) — https://mutationtesting.uni.lu/survey.pdf

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/1.1 200 OK`), `content-type: application/pdf`
- Bytes (PDF): **1129278**
- sha256 (PDF): `63b7bfca877cd4661cb24e93fbfe1757a2740b39fb65ee3a79eb17e36215f023`
- Capture (PDF): `.ufo/waves/round-64/capture/S153.body`
- Text layers of the same committed PDF, with digests:
  | layer | command | bytes | sha256 |
  |---|---|---|---|
  | `S153.txt` | `pdftotext S153.body S153.txt` | 294184 | `051e5a6537944be5886a8a9407a2844bacdbfe38298651fc79827c684df8776d` |
  | `S153.p17.txt` | `pdftotext -f 17 -l 17 S153.body S153.p17.txt` | 2128 | `83fed7ac104463a33ea55d85862ab0edbd2f387a51e929a79b3b007d779e2a02` |
  | `S153.p28.txt` | `pdftotext -f 28 -l 28 S153.body S153.p28.txt` | 2202 | `8eae275a3d0c290b987cbf4df30bbae48fa7967e08d4435cda5b2d0e5953aa15` |
  | `S153.p29.txt` | `pdftotext -f 29 -l 29 S153.body S153.p29.txt` | 2174 | `b33728ab3301f3820ba968774be590dbd071f128cabbb200b784372aacefb5b8` |
  | `S153.p40.txt` | `pdftotext -f 40 -l 40 S153.body S153.p40.txt` | 2291 | `56253f98ae79c911b1c711fbaa0c0f504daff5165495786c0f45779951d951bd` |
- Venue, verified independently of the PDF by Crossref (S163 below) and by the PDF's own
  front matter: **Papadakis, Kintis, Zhang, Jia, Le Traon, Harman, "Mutation Testing
  Advances: An Analysis and Survey", *Advances in Computers* vol. 112, pp. 275–378,
  Elsevier, 2019**, DOI `10.1016/bs.adcom.2018.03.015` — a **peer-reviewed survey book
  chapter** (Crossref `type: book-chapter`), the form the plan's §Frontier step 1 names
  as preferred ("if a peer-reviewed survey chapter is reachable, prefer it").
- Located quote (≤25 words, **10 words**) — the consequence, stated as the score rule:
  `Computing the mutation score requires the removal of equivalent mutants.`
  (§5, "Computing the mutation score" discussion; PDF page 40)
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1` (in `S153.p40.txt`)
- Second located quote (**13 words**) — the definition:
  `mutants that are semantically equivalent to the original program despite being syntactically different`
  (§5.3, PDF page 28) → `RENDERED_TEXT_V1_LOCATE: count=1` (in `S153.p28.txt`)
- Third located quote (**8 words**): `Detecting equivalent mutants is a well-known undecidable problem`
  (§5.3.1, PDF page 29) → `RENDERED_TEXT_V1_LOCATE: count=1` (in `S153.p29.txt`)
- **Measured representation defect (disclosed, not worked around silently):** in the
  **whole-document** text layer `S153.txt` these three quotes locate **0** times, while
  the page-scoped layers locate them **1** time each. Cause, measured: the PDF's text
  layer contains comparison-operator characters (`<`, `<=`, `==`, `!=`, `>`) inside its
  mutation-operator tables and bibliography, and `rendered-text-v1`'s declared tag rule
  (`<[^>]+>` → one space) therefore swallows **137657 bytes** of the 292885-byte layer
  in four spans (47934, 89691, 17, 15 bytes), taking with it the pages carrying the
  §5.3 passages. The page-scoped layers are produced from the **same committed PDF** by
  a deterministic command (`pdftotext -f N -l N`), and their digests are recorded above
  so every quote is reproducible from the one fetch. This is a property of the declared
  normalizer applied to a PDF text layer, not a change to it; it is reported for the L1
  rather than papered over.
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed survey book chapter).
- Reason: this is the plan's preferred carrier — a second peer-reviewed attestation of
  the equivalent-mutant rule behind the C2 kill contract, from an Elsevier
  *Advances in Computers* survey chapter (and from a different author set, with Jia &
  Harman as co-authors) rather than from the three sources already mined in round 63
  (S137/S139/S140). It grounds the rule in the field's survey literature: an equivalent
  mutant is *semantically equivalent to the original despite being syntactically
  different*, its detection is a *well-known undecidable problem*, and the mutation
  score therefore *requires the removal of equivalent mutants* — the exact separation a
  kill-count over a mixed population must make.
- Flip: a revision of the chapter that drops the §5.3 equivalent-mutant discussion, or
  an author copy whose text layer no longer carries the §5.3 pages, would change the
  row; so would a decision to mint the quote from the whole-document layer only (the
  tag-swallow measurement above says that is not possible for these passages).

---

## S154 — Kushigian et al., "Equivalent Mutants in the Wild" (peer-reviewed, ISSTA '24) — https://homes.cs.washington.edu/~rjust/publ/equi_mutants_ems_issta_2024.pdf

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/1.1 200 OK`), `content-type: application/pdf`
- Bytes (PDF): **509057**
- sha256 (PDF): `066f44388d042384987edcb61c1938472970f89af68a3ba887edea19e232ae28`
- Capture (PDF): `.ufo/waves/round-64/capture/S154.body`
- Text layer of the same committed PDF: `pdftotext S154.body S154.txt` — **74040 B**,
  sha256 `28c22757733c1e4dd02503849b52e5bb25e8b75b6acc359816ab4d2012958120`.
- Venue, from the paper's own ACM Reference Format block: **Kushigian, Kaufman,
  Featherman, Potter, Madadi, Just, "Equivalent Mutants in the Wild: Identifying and
  Efficiently Suppressing Equivalent Mutants for Java Programs", ISSTA '24 (33rd ACM
  SIGSOFT International Symposium on Software Testing and Analysis), Vienna, Austria,
  12 pages, DOI `10.1145/3650212.3680310`** — peer-reviewed conference paper, read from
  the authors' own University of Washington publication page.
- Located quote (≤25 words, **13 words**) — the cannot-be-killed consequence, verbatim:
  `An equivalent mutant is a mutant which cannot be killed by any test`
  (§1 Introduction, the paragraph defining killability; PDF page 2)
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**19 words**) — the premise, from the abstract:
  `The presence of equivalent mutants has long been considered a major obstacle to the widespread adoption of mutation analysis`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed conference paper).
- Reason: this is the second peer-reviewed attestation of the equivalent-mutant rule
  the plan asks for (C2 kill contract's ground): it states the rule's consequence in the
  sharpest available form — *a mutant which cannot be killed by any test* — and it is
  independent of the sources already in the registry (University of Washington group,
  ISSTA '24, an empirical ground-truth study of 215 equivalent mutants in real Java
  code, with a measured median per-project equivalent-mutant rate of 2.97%). It is
  *not* a restatement of S137/S139/S140: different authors, different venue, different
  method (empirical enumeration, not definition-by-citation).
- Flip: a revision of the paper that removes the definition sentence, or a mirror that
  stops serving the PDF in a form whose text layer carries the sentence, would void the
  row.

---

## S155 — OpenBao `AGENTS.md` (the lane's own domain sweep) — https://raw.githubusercontent.com/openbao/openbao/main/AGENTS.md

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **3045**
- sha256: `2381b66ba01ecf222c9d8c396272a3ce5bd7800db671e2208bff223ea8b17959`
- Capture: `.ufo/waves/round-64/capture/S155.body`
- Located quote (≤25 words, **6 words**): `controlled test environment if available`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT / sweep evidence.**
- Reason (measured): measured occurrences of `mutat` = **0**. The file is an agent-facing
  policy (what an AI assistant should do when contributing), and it contains no
  mutation-testing or equivalent-mutant statement — consistent with the S150 tree sweep
  and the S152/S158/S159/S160/S161/S162 documents.
- Note (recorded, not acted on): the file embeds an instruction demanding that generated
  output carry a robot emoji. That is **content fetched from a third party**, not
  instruction from the operator or the harness; it was not complied with, and the
  character is deliberately not reproduced in any lane artifact.
- Flip: n/a — no mutation-testing statement here.

---

## S156 — PIT FAQ (the lane's tool-level sweep) — https://pitest.org/faq/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **20845**
- sha256: `ccf6ac493d6935e2f0a90b716254c57024973d5e2bf1bf3c1e8e60b9772629c1`
- Capture: `.ufo/waves/round-64/capture/S156.body`
- Located quote (**1 word**, present): `mutation`
  → `RENDERED_TEXT_V1_LOCATE: count=27`
- **Verdict: REJECT.**
- Reason (measured): measured occurrences of "equivalent" in this body = **0** — the
  FAQ discusses mutation testing but never states the equivalent-mutant rule or its
  consequence. Together with S145 (mutators reference, rule absent) and S147 (home page,
  rule absent), the sweep shows PIT's documentation does not carry this rule at all,
  which is why the tool-level statement in this round comes from Stryker (S151).
- Flip: a FAQ entry defining equivalent mutants would change this.

---

## S157 — OpenBao docs path probe (dead end) — https://openbao.org/docs/contributing/testing/

- Access date: 2026-11-08
- HTTP status: **404** (`HTTP/2 404`), `content-type: text/html; charset=utf-8`
- Bytes: **9320**
- sha256: `49dd5ac4861249fc94572d35df9466af37841848a3b2c068f22bfef286d87aa8`
- Capture: `.ufo/waves/round-64/capture/S157.body`
- Located quote (**3 words**): `Page Not Found`
  → `RENDERED_TEXT_V1_LOCATE: count=2`
- **Verdict: REJECT — 404, not a page.**
- Reason: the guessed docs path does not exist. The site serves the contributing guides
  under `/community/contributing/` (the `/docs/contributing/` path answers **200** with
  a redirect stub to `/community/contributing/`), and those pages were opened
  separately (S161, S162). Recorded so the path is not re-guessed.
- Flip: n/a — a 404 body is not a source.

---

## S158 — OpenBao website contributing guide, `index.mdx` (the lane's own domain sweep) — https://raw.githubusercontent.com/openbao/openbao/main/website/content/community/contributing/index.mdx

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **4394**
- sha256: `7d0aff9b9591c502d159c43f8da2662bdcaa8e32512ec81d5ffacc15e7736c02`
- Capture: `.ufo/waves/round-64/capture/S158.body`
- Located quote (≤25 words, **18 words**):
  `OpenBao contribution guides, outlining welcomed contribution processes and providing an in-depth overview of the code base.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT / sweep evidence.**
- Reason (measured): measured occurrences of `mutat` = **0**. It is the contribution
  guide landing page; no mutation-testing or equivalent-mutant statement.
- Flip: n/a.

---

## S159 — OpenBao website contributing guide, `code-organization.mdx` (the lane's own domain sweep) — https://raw.githubusercontent.com/openbao/openbao/main/website/content/community/contributing/code-organization.mdx

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **10231**
- sha256: `49e1d0c7fb59c0b94c8f2f7a5703a8863ca1369f550d2b07c3c11d31b4a6d66b`
- Capture: `.ufo/waves/round-64/capture/S159.body`
- Located quote (≤25 words, **6 words**): `they might be testing libraries`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT / sweep evidence.**
- Reason (measured): measured occurrences of `mutat` = **0**; the page describes how the
  code base is organised (plugin vs core layout, test-cluster helpers), with no
  mutation-testing or equivalent-mutant statement.
- Flip: n/a.

---

## S160 — OpenBao CI workflow `test-go.yml` (the lane's own domain sweep) — https://raw.githubusercontent.com/openbao/openbao/main/.github/workflows/test-go.yml

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **13191**
- sha256: `303ba75d48f91388fc328b08839c869a4b6463c02b8f7c4667cda523729ffa76`
- Capture: `.ufo/waves/round-64/capture/S160.body`
- Located quote (**3 words**): `Run Go tests`
  → `RENDERED_TEXT_V1_LOCATE: count=4`
- **Verdict: REJECT / sweep evidence.**
- Reason (measured): measured occurrences of `mutat` = **0**. The workflow runs the
  project's Go test matrix (including race and FIPS configurations) and says nothing
  about mutation testing or equivalent mutants.
- Flip: n/a.

---

## S161 — OpenBao docs, "Contributing" (rendered) (the lane's own domain sweep) — https://openbao.org/community/contributing/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **25357**
- sha256: `c445a9621fb443fa955393a782d734c0df796b3ce54cef9fa283d4eeb9ebf218`
- Capture: `.ufo/waves/round-64/capture/S161.body`
- Located quote (≤25 words, **10 words**): `Disable all generative AI agents while working on OpenBao!`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT / sweep evidence.**
- Reason (measured): measured occurrences of `mutat` = **0**. The page is OpenBao's
  contribution policy; the quoted line is its policy on AI-assisted contributions
  (a fact about the project's submission rules, not a mutation-testing rule). No
  equivalent-mutant statement exists on this page either.
- Flip: n/a.

---

## S162 — OpenBao docs, "Code organization" (rendered) (the lane's own domain sweep) — https://openbao.org/community/contributing/code-organization/

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **32988**
- sha256: `25c576155c4f80907a7c455d28bb0c570b93aea25de09dd70a161e639fccfcda`
- Capture: `.ufo/waves/round-64/capture/S162.body`
- Located quote (**2 words**, the page title): `Code organization`
  → `RENDERED_TEXT_V1_LOCATE: count=4`
- **Verdict: REJECT / sweep evidence.**
- Reason (measured): measured occurrences of `mutat` = **0**; the rendered page mirrors
  S159 and adds no mutation-testing content.
- Flip: n/a.

---

## S163 — Crossref record for the Papadakis survey chapter (identity evidence for S153) — https://api.crossref.org/works/10.1016/bs.adcom.2018.03.015

- Access date: 2026-11-08
- HTTP status: **200** (`HTTP/2 200`), `content-type: application/json`
- Bytes: **88534**
- sha256: `68cee300e35a882723718057cbc02944bdaa281d50c06d37dbc3add99c4b6a40`
- Capture: `.ufo/waves/round-64/capture/S163.body`
- Located quote (**8 words**): `Mutation Testing Advances: An Analysis and Survey`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: NOT A REGISTRY ROW — identity evidence for S153.**
- Reason: the Crossref metadata independently confirms the identity the plan's
  preferred carrier depends on: `title` "Mutation Testing Advances: An Analysis and
  Survey", `container-title` ["Advances in Computers"], `page` "275-378", `publisher`
  "Elsevier", `type` "book-chapter", `issued` 2019, for DOI `10.1016/bs.adcom.2018.03.015`.
  It is the machine-readable authority for the peer-reviewed status of the S153
  carrier, fetched from a different host than the PDF itself, so the S153 row does not
  rest on the publisher's own site.
- Flip: n/a — identity evidence.

---

## Proposed registry id allocation (for the L1 — the ids are the L1's to mint)

`corpus/SOURCES.md` currently holds **143 data rows ending at `S144`**, so the next
free id is `S145`. This seat does not edit `corpus/SOURCES.md`; it proposes the
allocation below so the drafting scribe and the L1 land one consistent mapping (the
capture-handle column is this seat's ledger handle, the id column is the proposal).

| proposed id | capture handle | source | status | teaches (one line) |
|---|---|---|---|---|
| S145 | S154 | Kushigian et al., "Equivalent Mutants in the Wild", ISSTA '24 | mined | an equivalent mutant is a mutant which cannot be killed by any test — the "killed **or shown equivalent**" ground |
| S146 | S153 | Papadakis et al., "Mutation Testing Advances: An Analysis and Survey", Adv. Comput. 112 (Elsevier 2019) | mined | the mutation score requires the removal of equivalent mutants — a peer-reviewed survey chapter behind the same rule |
| S147 | S151 | Stryker Mutator, "Mutation Testing Elements → Equivalent mutants" | mined | the tool-level statement: a mutation that leaves the output identical is equivalent and no tool separates it automatically |
| S148 | S143 | NCBI BioC/ConText deposit, re-opened 2026-11-08 | mined | **supersedes S143 —** the served deposit still carries §3.1.2's pseudo-trigger and termination-term classes; the only change is the service's own date stamp |
| S149 | S149 | Wikipedia, "Mutation testing" | rejected | REJECT: community-edited wiki; a third-hand restatement beside a peer-reviewed statement of the same rule |
| S150 | S145 | PIT mutators reference | rejected | REJECT: the page names "equivalent mutations" only as operator design; the rule's consequence is absent |
| S151 | S156 | PIT FAQ | rejected | REJECT: 0 occurrences of "equivalent" — PIT's FAQ never states the rule |
| S152 | S148 | arXiv 1909.02196 | rejected | REJECT: the id resolves to an unrelated quantum-noise paper |
| S153 | S157 | openbao.org/docs/contributing/testing/ | rejected | REJECT: HTTP 404 (the live path is /community/contributing/) |
| S154 | S150 | OpenBao repository tree (`main`, recursive) | rejected | REJECT as a row / admitted as sweep evidence: 0 of 6363 paths mention mutation testing |
| S155 | S152 | OpenBao `CONTRIBUTING.md` | rejected | REJECT: 0 occurrences of "mutat" — the lane's own domain states no equivalent-mutant rule |
| S156 | S158 | OpenBao contributing guide `index.mdx` | rejected | REJECT: 0 occurrences of "mutat" |
| S157 | S159 | OpenBao contributing guide `code-organization.mdx` | rejected | REJECT: 0 occurrences of "mutat" |
| S158 | S160 | OpenBao CI workflow `test-go.yml` | rejected | REJECT: 0 occurrences of "mutat" |
| S159 | S161 | openbao.org/community/contributing/ | rejected | REJECT: 0 occurrences of "mutat" |
| S160 | S162 | openbao.org/community/contributing/code-organization/ | rejected | REJECT: 0 occurrences of "mutat" |

Not rows: **S146 handle = Stryker `/docs/` home** (byte-identical re-open of the
already-mined `S129`; `cmp` confirms — a freshness confirmation, not a new row) and
**S163 handle = Crossref record** (identity evidence for the Papadakis row, not a
source of its own).

If the L1 prefers a different order, the mapping is a one-line edit in this table — the
capture ledger above is unaffected.



| handle | URL | status | verdict |
|---|---|---|---|
| S143 | NCBI BioC deposit (S143 re-open) | 200 | **ADMIT** (supersedes S143 — one byte changed: the service's date stamp) |
| S145 | pitest.org/quickstart/mutators/ | 200 | REJECT (operator design only; no rule) |
| S146 | stryker-mutator.io/docs/ | 200 | RE-OPEN of S129 (byte-identical; not a new row) |
| S147 | pitest.org/ | 200 | RE-OPEN of S128 (byte-identical; not a new row) |
| S148 | arxiv.org/abs/1909.02196 | 200 | REJECT (unrelated quantum paper) |
| S149 | en.wikipedia.org/wiki/Mutation_testing | 200 | REJECT (designated weak lead; wiki) |
| S150 | api.github.com openbao tree | 200 | REJECT row / **sweep evidence: 0 of 6363 paths mention mutat** |
| S151 | stryker-mutator.io equivalent-mutants | 200 | **ADMIT** (tool-level statement) |
| S152 | OpenBao CONTRIBUTING.md | 200 | REJECT / sweep evidence (0 `mutat`) |
| S153 | mutationtesting.uni.lu/survey.pdf | 200 | **ADMIT** (peer-reviewed survey chapter) |
| S154 | homes.cs.washington.edu EMS PDF | 200 | **ADMIT** (peer-reviewed, ISSTA '24) |
| S155 | OpenBao AGENTS.md | 200 | REJECT / sweep evidence (0 `mutat`) |
| S156 | pitest.org/faq/ | 200 | REJECT (0 "equivalent") |
| S157 | openbao.org/docs/contributing/testing/ | 404 | REJECT (404) |
| S158 | OpenBao contributing index.mdx | 200 | REJECT / sweep evidence (0 `mutat`) |
| S159 | OpenBao code-organization.mdx | 200 | REJECT / sweep evidence (0 `mutat`) |
| S160 | OpenBao .github/workflows/test-go.yml | 200 | REJECT / sweep evidence (0 `mutat`) |
| S161 | openbao.org/community/contributing/ | 200 | REJECT / sweep evidence (0 `mutat`) |
| S162 | openbao.org/community/contributing/code-organization/ | 200 | REJECT / sweep evidence (0 `mutat`) |
| S163 | api.crossref.org 10.1016/bs.adcom.2018.03.015 | 200 | identity evidence for S153 (not a row) |

20 page blocks (≥4 required). **4 admits** (S143, S151, S153, S154) — every admitted
quote resolves `count=1` — **13 rejects** (of which the designated weak lead is S149,
Wikipedia; S150 is a reject as a registry row but is admitted as sweep evidence), and
**2 not-new-rows** (S146, a byte-identical re-open of the existing `S129`; S163,
identity evidence for S153 rather than a source of its own). The S143 block states the
measured byte count, the measured sha256, the one-byte delta against the committed pin,
and that the shape still holds.
