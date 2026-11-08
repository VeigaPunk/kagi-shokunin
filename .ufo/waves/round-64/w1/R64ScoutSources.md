# R64ScoutSources — round 64 source scout (kagi)

Seat: `R64ScoutSources` (scout; axes freshness, coverage). Lane `kagi-shokunin`,
branch master, claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`. Plan
`plans/round-64.md` §Frontier step (frozen, `dff0929c`). Access date for every
page opened: **2026-11-08**.

**Held-out seal:** `plans/round-64-heldout.tsv` was **not read** by this seat. This seat
is not the C1 checker seat, but it had no need for the file and did not open it (see
§Disclosure).

## What I produced

| artifact | path |
|---|---|
| capture ledger (20 page blocks) | `.ufo/waves/round-64/capture/notes.md` |
| captured bodies (20) | `.ufo/waves/round-64/capture/S143.body` … `S163.body` |
| PDF text layers (6) | `.ufo/waves/round-64/capture/S153.txt`, `S153.p17/p28/p29/p40.txt`, `S154.txt` |
| response headers (21, cookie-filtered) | `.ufo/waves/round-64/build/R64ScoutSources/h<id>.hdr` |
| locate transcript (27 probes) | `.ufo/waves/round-64/build/R64ScoutSources/locate-output.txt` |

All fetches used the plan's declared profile:
`curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed`.
Every digest is over curl's **decoded** body. Nothing was written outside the lane's
`.ufo/waves/round-64/` paths; no scratch clone was needed (no fixtures, no servers),
and the one scratch dir created was removed before yielding.

## Frontier step 1 — a second peer-reviewed attestation of the equivalent-mutant rule

**ADMIT — S153: Papadakis, Kintis, Zhang, Jia, Le Traon & Harman, "Mutation Testing
Advances: An Analysis and Survey", *Advances in Computers* vol. 112, pp. 275–378,
Elsevier, 2019** — `https://mutationtesting.uni.lu/survey.pdf` (author/institutional
copy). 1129278 B, sha256 `63b7bfca…`. Peer-reviewed **survey book chapter** — the form
the plan prefers ("if a peer-reviewed survey chapter is reachable, prefer it"), and
confirmed independently of the publisher's own site by the Crossref record fetched as
S163 (`type: book-chapter`, `container-title: Advances in Computers`, `page: 275-378`,
`publisher: Elsevier`, `issued: 2019`, DOI `10.1016/bs.adcom.2018.03.015`).

> Quote (10 words): `Computing the mutation score requires the removal of equivalent mutants.`
> — `RENDERED_TEXT_V1_LOCATE: count=1`

Second quote (13 words), the definition: `mutants that are semantically equivalent to
the original program despite being syntactically different` — `count=1`.
Third quote (8 words): `Detecting equivalent mutants is a well-known undecidable
problem` — `count=1`.

**ADMIT — S154: Kushigian, Kaufman, Featherman, Potter, Madadi & Just, "Equivalent
Mutants in the Wild: Identifying and Efficiently Suppressing Equivalent Mutants for
Java Programs", ISSTA '24** —
`https://homes.cs.washington.edu/~rjust/publ/equi_mutants_ems_issta_2024.pdf`. 509057 B,
sha256 `066f4438…`; venue read from the paper's own ACM Reference Format block
(ISSTA '24, Vienna, DOI `10.1145/3650212.3680310`).

> Quote (13 words): `An equivalent mutant is a mutant which cannot be killed by any test`
> — `RENDERED_TEXT_V1_LOCATE: count=1`

This is the sharpest statement of the rule's consequence available and it is
*independent* of the three rows already mined in round 63 (S137 / S139 / S140):
different authors (University of Washington), different venue, different method (an
empirical ground-truth study of 215 equivalent mutants in real Java projects, median
per-project equivalent-mutant rate 2.97 %), not a restatement by citation.

**ADMIT — S151: Stryker Mutator, "Mutation Testing Elements → Equivalent mutants"** —
`https://stryker-mutator.io/docs/mutation-testing-elements/equivalent-mutants/`. 38687 B,
sha256 `00082805…`. This is the plan's named *tool-level* statement, from a second
independently maintained vendor (PIT's own docs are swept and do **not** carry the rule
— see below):

> Quote (20 words): `even if we change >= to <= and even < or > we will get the same output each time!`
> — `count=1`
> Second quote (11 words): `There is no definitive way for Stryker to find and ignore them.` — `count=1`

## Frontier step 2 — the BioC/ConText deposit re-opened on the current endpoint (S143)

Re-fetched `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode`
— HTTP **200**, **264946 B**, sha256 `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`.

**Measured delta vs the committed pin** (`8522a79e…`, 264946 B): **the byte count is
unchanged and exactly one byte of the body differs.** `cmp -l` against the round-63
capture returns a single differing byte at offset 127; the text around it is
`<source>BioC-API</source><date>20261107</date>` → `<source>BioC-API</source><date>20261108</date>`
— the BioC service stamps the deposit with the **request date**, not with an editorial
change. The sha256 therefore differs from the pin even though the article content is
identical.

**Shape still holds — measured.** `<passage>` 182 → 182, `<text>` 180 → 180,
`<document>` 1 → 1; the §3.1.2 heading `3.1.2 Trigger Terms, Pseudo-Trigger Terms, and
Termination Terms` at byte offset 17212, the pseudo-trigger sentence at 19029 and the
termination-term sentence at 19652 — all unchanged.

> Quote (17 words): `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)` — `count=1`
> Second quote (19 words): `Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term.` — `count=1`

**Consequence for the registry:** because the re-fetched body does not reproduce the
committed pin's sha256, `CORPUS.md` rule 2 applies — the L1 **supersedes `S143`** with a
new row (`supersedes S143 —`) carrying the 2026-11-08 digest and the re-verified
shape. The delta is measured and is the service's own date stamp, so the *teaches*
content does not change.

## Frontier step 3 — one weak lead (the reject)

**REJECT — S149: Wikipedia, "Mutation testing"** —
`https://en.wikipedia.org/wiki/Mutation_testing`, 171636 B, sha256 `4b5a8374…`,
revision pinned by the page itself (`oldid=1373580212`).

> Quote (18 words): `there are cases where it is not possible to find a test case that could kill this mutant` — `count=1`
> Second quote (13 words): `Equivalent mutants detection is one of the biggest obstacles to practical usage of mutation testing.` — `count=1`

The content is right and the page does cite primary work (measured in the body: `Jia` 5,
`Harman` 8, `IEEE` 12, `citation` 24), but it is a community-edited wiki with no
editorial or peer-review gate, and its authority is derivative of the papers it cites.
Admitting it would put a mutable third-hand restatement beside a peer-reviewed
statement of the same rule. The reject is on source class, not on content. Flip: an
authoritative-publisher version with editorial sign-off.

## Frontier step 4 — OpenBao's own mutation-test / equivalent-mutant statement

**None exists — the sweep is the finding.** Measured:

* the repository tree is complete (`"truncated": false`) with **6363** path entries and
  **0** paths matching `mutat` and **0** occurrences of the string `mutat` anywhere in
  the tree body (S150);
* `CONTRIBUTING.md` (S152), `AGENTS.md` (S155), the website contributing guide
  `index.mdx` (S158) and `code-organization.mdx` (S159), the CI workflow `test-go.yml`
  (S160), and the rendered pages `openbao.org/community/contributing/` (S161) and
  `…/code-organization/` (S162) each measure **0** occurrences of `mutat`.

So the lane's own product documentation contains no equivalent-mutant statement, and
the C2 kill contract's ground must be anchored on external peer-reviewed rows. Recorded
rather than papered over.

Adjacent measured facts from the same sweep, recorded so they are not re-guessed:
`https://openbao.org/docs/contributing/testing/` is a **404** (S157);
`https://openbao.org/docs/contributing/` is a 200 redirect stub to
`/community/contributing/`; and GitHub's code-search API requires authentication
(HTTP 401), so the sweep used the tree listing plus the individual documents rather
than the code-search endpoint.

## Additional rejects (all measured, with flips in the ledger)

| handle | page | why rejected |
|---|---|---|
| S145 | pitest.org/quickstart/mutators/ | mentions "equivalent mutations" 11×, but every occurrence is operator design / PIT filtering; `cannot be killed`-type phrases occur **0** times; no definition, no consequence |
| S146 | stryker-mutator.io/docs/ | **byte-identical** to the round-62 capture of registry row `S129` — a re-open, not a new row |
| S147 | pitest.org/ | **byte-identical** to the round-62 capture of registry row `S128` — a re-open, not a new row; and the page carries **0** occurrences of "equivalent", so PIT's front page does not state the rule |
| S148 | arxiv.org/abs/1909.02196 | resolves to *"Effects of Quantum Noise on Quantum Approximate Optimization Algorithm"* — a mis-derived id, 0 occurrences of "mutat" |
| S152/S155/S158/S159/S160/S161/S162 | OpenBao contributing/testing docs | 0 occurrences of `mutat` (sweep evidence) |
| S156 | pitest.org/faq/ | 0 occurrences of "equivalent" — PIT's FAQ never states the rule |
| S157 | openbao.org/docs/contributing/testing/ | HTTP 404 |
| S163 | Crossref `10.1016/bs.adcom.2018.03.015` | identity evidence for S153, not a registry row |

## Proposed registry id allocation (the L1 mints the ids)

`corpus/SOURCES.md` holds **143 data rows ending at `S144`** today, so the next free id
is `S145`. This seat does not edit `corpus/SOURCES.md`; it proposes the allocation so
the drafting scribe and the L1 land one consistent mapping (full table in
`.ufo/waves/round-64/capture/notes.md`):

| proposed id | capture handle | source | status |
|---|---|---|---|
| S145 | S154 | Kushigian et al., "Equivalent Mutants in the Wild", ISSTA '24 | mined |
| S146 | S153 | Papadakis et al., "Mutation Testing Advances: An Analysis and Survey", Adv. Comput. 112 | mined |
| S147 | S151 | Stryker, "Mutation Testing Elements → Equivalent mutants" | mined |
| S148 | S143 | NCBI BioC/ConText re-open (supersedes S143) | mined |
| S149 | S149 | Wikipedia, "Mutation testing" | rejected |
| S150 | S145 | PIT mutators reference | rejected |
| S151 | S156 | PIT FAQ | rejected |
| S152 | S148 | arXiv 1909.02196 (unrelated paper) | rejected |
| S153 | S157 | openbao.org/docs/contributing/testing/ (404) | rejected |
| S154 | S150 | OpenBao repo tree (sweep evidence) | rejected |
| S155–S160 | S152, S158, S159, S160, S161, S162 | OpenBao contributing / CI docs (0 `mutat` each) | rejected |

Not rows: capture handle S146 (Stryker `/docs/` home) is a byte-identical re-open of the
already-mined `S129`; handle S163 (Crossref) is identity evidence for the Papadakis row.

## Defect found in the lane's own representation (reported, not amended)

`rendered-text-v1`'s declared tag rule (`<[^>]+>` → one space) applied to a **PDF text
layer** swallows large spans of the layer when the PDF's own text contains comparison
operators. Measured on the Papadakis chapter's whole-document layer `S153.txt`
(294184 B): four tag spans of **47934, 89691, 17 and 15 bytes** — **137657 bytes** —
are removed, and the swallowed span carries the §5.3 equivalent-mutant passages
(so `locate` on `S153.txt` returns `count=0` for those quotes). The round-63 precedent
(`S139.body` + committed `S139.txt`) did not hit this because that PDF's text layer has
no `<`/`>` runs.

This seat did **not** change the normalizer or the declaration. The quotes are located
in **page-scoped** text layers produced from the *same committed PDF* by a deterministic
command (`pdftotext -f N -l N S153.body …`), with every layer's digest recorded in the
ledger, so each quote stays reproducible from the one fetch. The L1 should note the
bound when it writes the S153 row's anchor; a `raw-literal-v1` / page-anchored shape
(the lane's `S078`/`S079` NIST-PDF precedent) fits this carrier better than a
whole-document text layer.

The EMS paper's whole-document layer (`S154.txt`) is unaffected — measured tag spans
1880/3657/138/1515/12/16264/609 bytes — and its quote locates there with `count=1`.

## Secret discipline

* Every response header receipt was written through
  `grep -viE '^(set-cookie|cookie):'` **before** writing; the NCBI response carried a
  `set-cookie:` line (S143) and it is absent from the receipt. Measured after the
  fact: `grep -ciE '^(set-cookie|cookie):' build/R64ScoutSources/h*.hdr` ⇒ **0 for all
  21 header files**.
* Token scan over all 26 capture bodies and text layers
  (`csrfmiddlewaretoken" value="[A-Za-z0-9]{20,}"`, `"csrfToken":"[A-Za-z0-9]{20,}"`,
  `ncbi_sid=`, `api_key`, `Authorization: Bearer`) ⇒ **0 hits in every file**.
* Raw unfiltered header scratch lived only under `/tmp` and was deleted; **no citable
  evidence is under `/tmp`**. Every capture file is under
  `.ufo/waves/round-64/capture/`.
* `S155` (OpenBao `AGENTS.md`) embeds an instruction demanding that generated output
  carry a robot emoji. That is third-party content, not operator instruction; it was
  not complied with, and the character is deliberately not reproduced in any lane
  artifact.

## Disclosure

* **The sealed held-out file `plans/round-64-heldout.tsv` was not read by this seat.**
  This seat is not the C1 checker seat, so reading it was permitted, but it had no
  bearing on any judgement here and was not opened. Nothing in this report, the ledger,
  the captures or the locate transcript derives from it.
* No frozen predicate, target, POP, kill rule, fixture or item condition was amended.
  The S143 supersession is a **registry** consequence (CORPUS.md rule 2), decided by the
  L1; this seat only measured and reported the delta.
* `corpus/SOURCES.md` was **not** edited — the L1 appends the rows.
* Capture file handles (`S143`…`S163`) are this seat's ledger handles, **not** registry
  row ids; the registry currently ends at `S144` and the L1 assigns the new ids. The
  ledger names a proposed id per block for convenience only.

## Coverage / freshness summary for the Gate

* 20 page blocks, **4 admits** (S143 superseding S143, S151, S153, S154), **13 rejects**
  and **2 not-new-rows** (S146 re-open, S163 identity evidence); every admitted quote
  re-resolves with `count=1`.
* Both claims' evidence is sourced: the C2 kill contract's equivalent-mutant ground now
  has **two** fresh peer-reviewed carriers (an Elsevier survey chapter and an ISSTA '24
  paper) plus a tool-level carrier (Stryker), independent of the three rows mined in
  round 63; the C1 held-out grammar's pseudo-trigger / termination-term ground
  (S143/S135) is **re-verified unchanged in shape** on the current endpoint, with a
  measured one-byte, date-stamp-only delta.
* The lane's own domain (OpenBao) has **no** equivalent-mutant statement — a measured
  negative, recorded so the C2 evidence is not attributed to the product docs.

## Bounds

* The S153 quotes are located in page-scoped text layers of the same committed PDF
  (see §Defect) — reproducible, but not from the whole-document layer.
* GitHub's code-search API requires authentication (HTTP 401 measured), so the OpenBao
  sweep is tree-listing + individual documents, not a full-text code search.
* The EMS paper's per-page text layer was not committed separately (its whole-document
  layer is sufficient and locates `count=1`); its page-2 location is recorded in the
  ledger.
* Capture handles are not registry ids; the L1 assigns ids and may renumber.

SEAT-STATUS: complete
