# Round 63 — source capture notes (R63ScoutSources)

Seat: `R63ScoutSources` (scout; axes freshness, coverage). Plan `plans/round-63.md`
§Frontier step. Access date for every page below: **2026-11-07**.

Fetch method (all pages):

```
curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed
```

The captured bytes are curl's **decoded** body (every host served `content-encoding: gzip`
or `zstd`; `--compressed` decompressed it), so `sha256sum` is over the decoded body,
matching the registry's existing "decoded body" convention (`corpus/source-fetches.tsv`
column 9, `decoded-http-body-v1`).

Byte counts and digests below are `stat -c%s` and `sha256sum` of the committed capture
file `<id>.body` in this directory (`.ufo/waves/round-63/capture/`). Per-page response
headers are in `.ufo/waves/round-63/build/R63ScoutSources/h<id>.hdr`.

## Secret discipline

No `Set-Cookie`/`Cookie` header value was written to any capture, note or receipt. The
NCBI responses carried a `set-cookie: ncbi_sid=…` line (h135, h141); those lines were
**filtered out before writing** (`grep -viE '^(set-cookie|cookie):'`), and the recorded
header files now carry zero cookie-bearing lines (measured: `grep -ciE
'^(set-cookie|cookie):' h*.hdr` ⇒ 0 for all nine).

Token scan on every committed capture body and text file (measured):
`grep -ciE 'csrfmiddlewaretoken" value="[A-Za-z0-9]{20,}"|"csrfToken":"[A-Za-z0-9]{20,}"'`
⇒ **0 for every file**. No opaque token value of length ≥ 20 appears in any body. The
only per-request values seen at all were the NCBI `ncbi_sid` cookie (stripped) and one
transient HTTP 429 shell (fetched into scratch, never committed — see S143's stability
note).

## Quote resolution

Every quoted string below was resolved with

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/<id>.body "<quote>"
```

and the printed output is reproduced verbatim. The full transcript is
`.ufo/waves/round-63/build/R63ScoutSources/locate-output.txt`. All admitted quotes print
`RENDERED_TEXT_V1_LOCATE: count=1`.

**Note on S139.** `S139.body` is a PDF: `rendered-text-v1` on it exits 2 with
`RENDERED_TEXT_V1: SETUP (not strict UTF-8)` — a PDF byte stream is not decodable text.
The quote from the Jia & Harman paper is therefore located in `S139.txt`, the text layer
of the *same* committed PDF (`pdftotext jh.pdf S139.txt`, 175555 bytes, sha256
`0debc82d0b86ecf43b05a687cdf34c60eedfc16b0b536f28c54fc2b80b7cd15c`), which is committed
beside the PDF in this same capture directory. Both digests are recorded below so the
pair is reproducible from the one fetch. The lane's own precedent for a PDF-sourced row
is `S078`/`S079` (NIST PDFs), whose registry rows carry a `raw-literal-v1` representation
and a "PDF page 1 … wrapper" anchor (`corpus/source-fetches.tsv` column 14) — the same
shape as here.

---

## S135 — ConText (Harkema et al., J Biomed Inform 2009) — the NLM PMC deposit — https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/xml; charset=UTF-8`, `content-encoding: gzip`
- Bytes: **189603**
- sha256: `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`
- Capture: `.ufo/waves/round-63/capture/S135.body`
- Capture form: the NLM canonical **PMC XML deposit** of the record (PMCID PMC2757457,
  PMID 19435614), fetched with `efetch.fcgi?db=pmc&id=2757457&retmode=xml`, as the plan's
  §Frontier step 1 names ("via the NLM PMC deposit"). The article's HTML rendering was
  **not** used: PMC's HTML page embeds a per-request `csrfmiddlewaretoken` value (a
  session credential), and its body digest is not reproducible. The XML deposit is
  token-free and byte-stable (3/3 consecutive fetches on 2026-11-07, one digest — the
  three fetches returned `cdbb4173…` each time).
- **Identity note (measured, load-bearing):** this is the **same body** as the lane's
  existing row `S130` — same URL, same bytes (189603), same digest
  `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b` that
  `corpus/source-fetches.tsv` already records for `S130`. So this page is **not** a new
  registry row: it re-derives `S130`'s pin. What it adds is a **new lesson** on a
  section `S130` did not quote: `S130`'s quote is NegEx's six-token window (§3.1.4),
  whereas the quotes below are ConText's own **pseudo-trigger and termination-term
  classes** (§3.1.2) — the ground the C1 idiom/contrastive exception list needs. The
  plan's §Frontier step 1 asks for exactly this class. The L1 should decide whether to
  extend `S130`'s `teaches` (append-only discipline forbids rewriting a cell other than
  `status`/`recheck`/`used-by`, so per CORPUS.md rule 2 this is **a new row** whose
  `teaches` opens `supersedes S130 —`) or to carry the same lesson on the distinct
  deposit `S143` below, whose URL is not already in the registry.
- Location: §3.1.2 "Trigger Terms, Pseudo-Trigger Terms, and Termination Terms"
  (PMC XML `sec id="S6"`), paragraph `P19` for the first quote and `P20` for the second;
  XML byte offsets 23611 and 24214.
- Located quote (≤25 words, **17 words**) — the pseudo-negation class:
  `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**19 words**) — the termination-term class:
  `Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed journal article) — for the
  **class quote only**; the row's URL/digest overlap with `S130` is stated above.
- Reason: the two quotes name the classes the C1 grammar's exception list is built from,
  in ConText's own words: a *pseudo-trigger* is a phrase that contains a trigger term
  but does **not** act as one (the paper's own examples, “no increase” and “not cause”,
  are exactly the shape of the C1 idiom exceptions `not only` / `no fewer than`), and a
  *termination term* is a word that ends a trigger term's scope. That is the published
  grounding for "a negator-looking word that does not negate" and for a scope that can
  be closed early — the two mechanisms the C1 hardened grammar's items (iii) and (ii)
  encode. It grounds the **shape** of the rule, not the lane's specific 24-token window,
  which the plan itself names as a closed-list floor.
- Flip: a ConText revision that drops the §3.1.2 pseudo-trigger/termination-term
  taxonomy (or removes the negated pseudo-trigger list) would void this row's grounding.

---

## S136 — IEEE Xplore document 5661753 (the plan's named Jia & Harman lead) — https://ieeexplore.ieee.org/document/5661753

- Access date: 2026-11-07
- HTTP status: **202** (`HTTP/2 202`) — IEEE Xplore's interstitial/robot challenge
- Bytes: **0**
- sha256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
  (the digest of the empty string — the body is empty)
- Capture: `.ufo/waves/round-63/capture/S136.body`
- Location: there is no location — the body is zero bytes. `locate` on any probe term
  returns `count=0`.
- Locate output (probe): `RENDERED_TEXT_V1_LOCATE: count=0`
- **Verdict: REJECT** — with **two** measured reasons.
  1. **Measured, primary:** the URL returns HTTP **202** and a **0-byte** body, so the
     page carries no abstract text at all (no "equivalent mutant", no title, nothing).
     The sibling `/abstract/document/5661753` path (captured as `S142`) *does* return
     HTTP 200 with a 46994-byte body, and its rendered title locates as
     `Address Translation Aware Memory Consistency` — **not** "An Analysis and Survey of
     the Development of Mutation Testing". So document id 5661753 is a **different
     paper** (a memory-consistency paper), not Jia & Harman 2011 at all.
  2. **Measured, and a defect in the plan's candidate list:** the Jia & Harman TSE 2011
     article ("An Analysis and Survey of the Development of Mutation Testing", IEEE TSE
     37(5):649–678) has IEEE Xplore document id **5487526**, not 5661753 —
     `https://ieeexplore.ieee.org/abstract/document/5487526` (captured as `S144`)
     returns HTTP 200 with a 49289-byte body whose rendered title locates as
     `An Analysis and Survey of the Development of Mutation Testing`. Crossref confirms
     the identity independently: `https://api.crossref.org/works/10.1109/TSE.2010.62`
     ⇒ title "An Analysis and Survey of the Development of Mutation Testing",
     volume 37, issue 5, pages 649-678, authors Yue Jia and Mark Harman (fetched
     2026-11-07, HTTP 200, 6692 bytes).
- **Reported, not amended.** The plan is frozen and names the paper (Jia & Harman
  2011) but not this URL; the URL came from the seat's candidate list, which is not
  frozen text. The L1 should record the corrected document id and use the university
  PDF (`S139`) as the admit candidate, per the seat spec's own instruction.
- Flip: an IEEE Xplore URL for the Jia & Harman article that serves the abstract as
  retrievable text would turn this row from rejected to admitted.

---

## S137 — "Large Language Models for Equivalent Mutant Detection: How Far Are We?" (Tian et al., ISSTA 2024) — https://arxiv.org/html/2408.01760v1

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=utf-8`
- Bytes: **286109**
- sha256: `21893b049e06bf0f6e019808a5b47e3cdf2c0a9c56927bb0c7b2644b907d1849`
- Capture: `.ufo/waves/round-63/capture/S137.body`
- Capture form: the arXiv HTML full text of the ISSTA 2024 paper (arXiv:2408.01760,
  submitted 2024-08-03; the peer-reviewed version is ACM SIGSOFT ISSTA 2024,
  DOI 10.1145/3650212.3680395, pp. 1733–1745, ACM Distinguished Paper). Byte-stable:
  2/2 consecutive fetches returned the same digest.
- Location: §1 Introduction — the paragraph that introduces the equivalent-mutant
  problem; the second quote is the following sentence of the same paragraph.
- Located quote (≤25 words, **20 words**) — the equivalent-mutant definition, cited to
  Jia & Harman:
  `An equivalent mutant is redundant because it exhibits the same behavior as the original program for all possible test cases`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**18 words**) — the prevalence that makes the class matter:
  `Recent research indicates that the rate of equivalent mutants in real-world development scenarios ranges from 4% to 39%`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed conference paper; the arXiv
  HTML is the author's own openly-posted full text of it).
- Reason: this is the peer-reviewed literature's own statement of the definition the C2
  claim rests on — a mutant that behaves identically to the original for **all** inputs
  is *redundant*, i.e. it can never be killed by any test — and it attributes that
  definition to Jia & Harman, the survey the plan's §Frontier step 3 names. It grounds
  the **necessity** side of C2: a "surviving mutant" counter that counts every survivor
  as a test-suite failure is wrong unless equivalent mutants are separated out, and this
  paper measures that class at 4–39% of real-world mutants, so the separation is not a
  corner case. It does not replace `S139` (the survey itself) — it is the independent
  peer-reviewed statement that the survey's definition is the field's working one.
- Flip: a revision of the paper that removes the equivalent-mutant definition sentence
  or its Jia & Harman attribution would void this row's grounding.

---

## S138 — Codecov blog, "Mutation Testing: How to Ensure Code Coverage Isn't a Vanity Metric" — https://www.codecov.io/blog/mutation-testing/ (redirects to https://about.codecov.io/blog/mutation-testing-how-to-ensure-code-coverage-isnt-a-vanity-metric/)

- Access date: 2026-11-07
- HTTP status: **301** (redirect chain: 301 → 301 → 200), final `content-type: text/html; charset=UTF-8`, `content-encoding: gzip`
- Bytes: **67821**
- sha256: `dfa774baecae1b2dc149e86467ae8425f1c156d447a6e505b637cf51a19d9661`
- Capture: `.ufo/waves/round-63/capture/S138.body`
- Location: the bulleted definition list in the article body — the "Equivalent mutants:"
  item of the "Key mutation testing concepts" list.
- Located quote (≤25 words, **20 words**):
  `These mutants occur when the mutation causes the code to have the same meaning or interpretation, albeit with different syntax.`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT** — the designated **weak lead** (a vendor blog).
- Reason (measured, not stylistic): it is a **vendor marketing blog**, not a primary or
  standards document, and it carries no citation to any primary source: the strings
  `Jia`, `Harman`, `IEEE`, `citation` and `peer-reviewed` occur **0** times in the
  captured body. Its "equivalent mutants" definition is a plain-language paraphrase
  ("same meaning or interpretation") that never states the load-bearing consequence —
  that such a mutant can never be killed by any test — and it says nothing about the
  *surviving* side of the dichotomy, so a row admitted from it would ground half of the
  kill/survive pair, exactly the defect that got round 62's `S133` rejected. The page's
  own publication stamp is 2022-05-27 (the body's `datePublished`), which is also the
  weakest freshness of the round.
- Flip: the blog citing a primary definition for equivalent mutants (with the
  "cannot be killed by any test" consequence and the surviving-side counterpart) would
  make it citable as a vendor restatement; the primary sources `S137`/`S139`/`S140`
  already carry that ground, so this row is better left rejected.

---

## S139 — Jia & Harman, "An Analysis and Survey of the Development of Mutation Testing" (IEEE TSE 37(5):649–678, 2011) — university-hosted PDF — https://web.eecs.umich.edu/~weimerw/2022-481F/readings/mutation-testing.pdf

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/1.1 200 OK`), `content-type: application/pdf`
- Bytes (PDF): **1181976**, sha256 (PDF): `056ac9b99410321c7cb80a29284c4ca106456e1a0cf64b6f4d633ba83edff342`
- Capture (PDF): `.ufo/waves/round-63/capture/S139.body`
- Capture (text layer, of the same PDF): `.ufo/waves/round-63/capture/S139.txt` —
  **175555** bytes, sha256 `0debc82d0b86ecf43b05a687cdf34c60eedfc16b0b536f28c54fc2b80b7cd15c`,
  produced by `pdftotext S139.body S139.txt`. The quote is located in this text file
  (`rendered-text-v1` on the PDF bytes themselves exits 2, `SETUP (not strict UTF-8)`).
- PDF metadata (measured, `pdfinfo`): 31 pages, A4, TeX output 2010-04-11, producer
  dvipdfmx, file size 1181976 bytes; the first page is the IEEE TSE article header
  "An Analysis and Survey of the Development of Mutation Testing / Yue Jia, Mark Harman".
- Location: **PDF page 4**, §II "The Problems of Mutation Analysis" area — the
  paragraph on mutants that can never be killed; the second quote is in the same
  paragraph.
- Located quote (≤25 words, **17 words**) — the equivalent-mutant definition:
  `These mutants are called Equivalent Mutants. They are syntactically different but functionally equivalent to the original program.`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**21 words**) — the consequence C2 turns on:
  `there are some mutants that can never be killed, because they always produce the same output as the original program`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed IEEE Transactions paper).
- Reason: this is the paper the plan's §Frontier step 3 names, obtained from a
  **university course mirror** (University of Michigan EECS reading list) rather than
  behind IEEE's paywall — the seat spec's own admit candidate. Its definition sentence
  is the survey's own: an equivalent mutant is *syntactically different but functionally
  equivalent*, so no test can kill it, and the paper adds the consequence that some
  mutants "can never be killed". That is precisely the "a surviving mutant must be
  killed **or shown equivalent**" contract the C2 predicate's leg L5 (a tree whose
  counter carries no M-A marker reads SETUP rather than counting a surviving mutant)
  and the C2 kill count depend on: a killed-count over a mutant population that mixes
  equivalent mutants with genuine survivors is not the field's mutation score, and the
  survey's own score definition divides by the **non-equivalent** mutants.
- Flip: a copy of the PDF whose page-4 passage is edited, or a mirror that serves the
  article only in a form where the definition cannot be located, would void this row's
  grounding; likewise if the university mirror withdrew the file (the row would then
  need the ACM/IEEE version of record or `S137`/`S140` as its carrier).

---

## S140 — "Is the Stack Distance Between Test Case and Method Correlated With Test Effectiveness?" (Niedermayr & Wagner, EASE 2019) — https://arxiv.org/html/1903.05432v1

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=utf-8`
- Bytes: **295941**
- sha256: `4af403012d716ef13be8f3c134fa4a3a8af2b62951ade07f7961ff81f067c5`
- Capture: `.ufo/waves/round-63/capture/S140.body`
- Venue (measured from the arXiv abs page's own metadata): 2019 ACM 23rd International
  Conference on Evaluation and Assessment in Software Engineering (EASE), DOI
  10.1145/3319008.3319021, arXiv:1903.05432 (2019-03-13). Byte-stable: 2/2 consecutive
  fetches, one digest.
- Location: §3 "Definitions" — the sentence introducing the mutation-testing vocabulary,
  immediately followed by the three definitions it borrows from the literature.
- Located quote (≤25 words, **17 words**) — the equivalent-mutant definition as the
  survey's:
  `An equivalent mutant is—despite syntactical changes—semantically equivalent to the original program and can therefore not be killed.`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**17 words**) — the attribution that makes the borrowing
  explicit:
  `We further use common mutation testing terms as defined in literature ( Jia and Harman, 2011 )`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed ACM conference paper).
- Reason: it states the equivalent-mutant rule **and** its provenance in one place —
  "as defined in literature (Jia and Harman, 2011)" — so the row is not merely a
  restatement: it shows the field's terminology, including that an equivalent mutant
  "can therefore not be killed", is Jia & Harman's, and that a peer-reviewed 2019 paper
  still borrows it unchanged. That is the independent attestation the C2 claim's
  "must be killed **or shown equivalent**" wording needs: the distinction is a
  peer-reviewed convention, not one paper's private gloss.
- Flip: a revision of the paper that drops the equivalent-mutant definition or its
  Jia & Harman attribution would void this row's grounding.

---

## S141 — Chapman et al., "A simple algorithm for identifying negated findings and diseases in discharge summaries" (J Biomed Inform 2001;34(5):301–310) — the NLM PubMed XML deposit — https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=12123149&retmode=xml

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/xml; charset=UTF-8`
- Bytes: **5714**
- sha256: `009eedaa06c2ea8f0d2bace3987ba9aa90951ea2652dd1015cc49b2708e7d919`
- Capture: `.ufo/waves/round-63/capture/S141.body`
- Capture form: the NLM **PubMed** XML deposit of the record (PMID 12123149), fetched
  with `efetch.fcgi?db=pubmed&id=12123149&retmode=xml`. Token-free and byte-stable
  (3/3 consecutive fetches, one digest).
- **Identity note (measured):** PMID 12123149 is the paper the plan's §Frontier step 2
  names. The `pubmed.ncbi.nlm.nih.gov/11554662/` page that round 62 rejected as `S132`
  is **not** this paper — `esummary.fcgi?db=pubmed&id=11554662` returns "Endoscopic
  transnasal pituitary surgery: report on 180 cases." (measured 2026-11-07, HTTP 200,
  821 bytes), while `esummary.fcgi?db=pubmed&id=12123149` returns "A simple algorithm
  for identifying negated findings and diseases in discharge summaries." with journal
  `J Biomed Inform`, volume 34, issue 5, pages 301-310, 2001 Oct. The PubMed **HTML**
  page for 12123149 is behind the same cookie wall as 11554662's was, so the XML
  deposit is the usable form.
- Location: the record's `<Abstract>` element (the third abstract sentence and the
  fourth).
- Located quote (≤25 words, **20 words**):
  `filters out sentences containing phrases that falsely appear to be negation phrases, and limits the scope of the negation phrases`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**9 words**) — the algorithm's own name:
  `a simple regular expression algorithm called NegEx`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed journal article; the plan's
  own §Frontier step 2 candidate).
- Reason: the NegEx paper's own abstract states the two rules the C1 grammar's items
  (i), (ii) and (iii) exist to handle, in the primary source rather than in a later
  paper's paraphrase: NegEx (a) applies a closed list of negation phrases, (b) **filters
  out phrases that falsely appear to be negation phrases** — the exception list the C1
  idiom/contrastive exclusions implement — and (c) **limits the scope** of those
  phrases, i.e. the window. Round 62 already holds `S130`/`S131`, which quote ConText's
  *description* of NegEx; this row is the NegEx paper itself, and its lesson ("a
  false-negation phrase is filtered out, and a negation phrase's scope is bounded") is
  the primary grounding for the round's window-and-exception design rather than a
  secondary one. The plan's §Frontier step 2 says a new row is written only if a page
  opened this round grounds a new lesson; this quote does (the filter sentence, not
  NegEx's window number, which `S130` already carries).
- Flip: a PubMed/NLM deposit revision that drops the abstract's filter-and-scope
  sentence would void this row's grounding; likewise a correction of the PMID if
  12123149 were ever shown not to be this paper.

---

## S142 — IEEE Xplore `/abstract/document/5661753` — the paywall lead's readable sibling — https://ieeexplore.ieee.org/abstract/document/5661753

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=UTF-8`
- Bytes: **46994**
- sha256: `03ce1bd82b7b0abcb8faf3a3f3dc97528d3a05396388cc9804d238e830a4407d`
- Capture: `.ufo/waves/round-63/capture/S142.body`
- Location: the document's `<title>` element; the page's rendered abstract area.
- Located quote (≤25 words, **5 words**) — the title that identifies the record:
  `Address Translation Aware Memory Consistency`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Locate output (probe for the topic): `RENDERED_TEXT_V1_LOCATE: count=0` for
  `equivalent mutant` — the page carries no equivalent-mutant content.
- **Verdict: REJECT** — the evidence row for `S136`'s second reason: document id
  5661753 is a **memory-consistency** paper, not Jia & Harman. It is recorded because
  the plan asks that a rejected candidate stay as a row with its measured reason, and
  this is the measured proof of the misidentification.
- Reason: the only sentence this page grounds is the title of an unrelated paper; its
  own topic (address translation and memory consistency) carries no lesson for the
  lane.
- Flip: not applicable in the usual sense — this page's content is what it is; the
  flip for the *candidate* (Jia & Harman 2011) is recorded on `S136` and `S144`.

---

## S143 — ConText (Harkema et al., J Biomed Inform 2009) — the NCBI BioC XML deposit — https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`)
- Bytes: **264946**
- sha256: `8522a79eba84604f4dbb37e0b46fa7a28c80eec69d00eaf5efecceef543c7208`
- Capture: `.ufo/waves/round-63/capture/S143.body`
- Capture form: the NCBI BioC RESTful service's XML rendering of the same PMC record
  (PMCID PMC2757457) — a **different URL and a different body** from `S135`'s
  `efetch` deposit, so it does not collide with the registry's existing `S130` row.
  Token-free (no `csrfmiddlewaretoken`, no `csrfToken` in the body — measured 0 hits).
- **Stability note (measured):** 2 of 3 consecutive fetches returned byte-identical
  bodies with this digest; the third returned an HTTP **429** "Too Many Requests" shell
  (899 bytes). So this deposit is byte-stable but **rate-limited**: the registry should
  treat its digest as volatile-ish (`decoded-http-body-volatile-v1` is the lane's
  existing vocabulary for that), and the 429 shell was fetched into scratch and never
  committed.
- Location: the same passages as `S135` — §3.1.2 "Trigger Terms, Pseudo-Trigger Terms,
  and Termination Terms".
- Located quote (≤25 words, **17 words**):
  `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**19 words**):
  `Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec`) — the **distinct-URL carrier** for the same
  ConText lesson `S135` grounds, offered so the L1 can carry the pseudo-negation /
  termination-term class without adding a duplicate URL against `S130`.
- Reason: identical source content to `S135` (both are the PMC2757457 deposit), but a
  distinct URL and digest, so the row is additive to the registry rather than a
  duplicate of `S130`. The lesson is the one the plan's §Frontier step 1 asks for: the
  published **pseudo-negation class** and **termination-term class** that ground the
  C1 idiom/contrastive exception list.
- Flip: the NCBI BioC service changing its XML shape or withdrawing the record (the
  endpoint already rate-limits) would void this row's URL as a stable carrier; the
  `S135`/`S130` `efetch` deposit is the more durable copy of the same content.

---

## S144 — IEEE Xplore `/abstract/document/5487526` — the Jia & Harman paper's real IEEE record — https://ieeexplore.ieee.org/abstract/document/5487526

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=UTF-8`
- Bytes: **49289**
- sha256: `b93834ae6b20bd7a89fd60c53f51416b78adc009132f261dbd3135333b854103`
- Capture: `.ufo/waves/round-63/capture/S144.body`
- Location: the document's `<title>` element (the abstract body is client-rendered and
  absent from the served HTML).
- Located quote (≤25 words, **9 words**):
  `An Analysis and Survey of the Development of Mutation Testing`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Locate output (probe for the topic): `RENDERED_TEXT_V1_LOCATE: count=0` for
  `equivalent mutant` — the served HTML carries the title but not the abstract text.
- **Verdict: REJECT** — measured: the served page contains the Jia & Harman **title**
  and nothing about equivalent mutants (no abstract text in the response body), so it
  cannot ground the equivalent-mutant lesson; it is the record-identity evidence for
  `S136`'s second reason (this is the document id for the paper the plan names).
- Reason: the IEEE landing page for the right paper is not a citable *text* source from
  this host — the abstract is rendered client-side. The university PDF (`S139`) is the
  citable carrier, exactly as the seat spec anticipated ("a university PDF … that
  carries the definition is the admit candidate").
- Flip: IEEE serving the abstract as static HTML would turn this into an admitted
  row.

---

## Summary

| id | URL | status | bytes | verdict | one-line reason |
|---|---|---|---|---|---|
| S135 | eutils … efetch pmc 2757457 | 200 | 189603 | **admit** (class quote) | same body as `S130`; grounds the pseudo-negation/termination-term classes |
| S136 | ieeexplore …/document/5661753 | 202 | 0 | **reject** | 0-byte challenge body; and 5661753 is a different paper |
| S137 | arxiv.org/html/2408.01760v1 | 200 | 286109 | **admit** | peer-reviewed equivalent-mutant definition, citing Jia & Harman, plus 4–39% prevalence |
| S138 | codecov.io/blog/mutation-testing/ | 301→200 | 67821 | **reject** | vendor blog; 0 occurrences of Jia/Harman/IEEE/citation; no "cannot be killed" |
| S139 | web.eecs.umich.edu …/mutation-testing.pdf (+ S139.txt) | 200 | 1181976 | **admit** | the survey's own equivalent-mutant definition and its "can never be killed" consequence |
| S140 | arxiv.org/html/1903.05432v1 | 200 | 295941 | **admit** | peer-reviewed statement of the rule with explicit "(Jia and Harman, 2011)" attribution |
| S141 | eutils … efetch pubmed 12123149 | 200 | 5714 | **admit** | NegEx's own abstract: filters false-negation phrases, limits scope |
| S142 | ieeexplore …/abstract/document/5661753 | 200 | 46994 | **reject** | evidence row: 5661753 = "Address Translation Aware Memory Consistency" |
| S143 | ncbi BioC XML PMC2757457 | 200 | 264946 | **admit** | distinct-URL carrier of the ConText pseudo-negation/termination-term lesson |
| S144 | ieeexplore …/abstract/document/5487526 | 200 | 49289 | **reject** | title only; no abstract text in the served body |

Ten pages opened; **six admits**, **four rejects**. Every admitted quote resolves
`count=1` under `rendered-text-v1` (`build/R63ScoutSources/locate-output.txt`).

### Defects reported to the L1 (not amended here)

1. **The plan's frontier candidate 1 URL is already a registry row.** `S135`'s
   efetch deposit is byte-identical to the existing `S130` (same URL, same 189603 bytes,
   same digest `cdbb4173…`). A new row on that URL would be a duplicate-URL row; the
   distinct deposit `S143` is offered as the alternative carrier for the same lesson.
2. **The seat's candidate list named the wrong IEEE document for Jia & Harman 2011.**
   5661753 is "Address Translation Aware Memory Consistency"; the survey's IEEE id is
   5487526 (Crossref DOI 10.1109/TSE.2010.62 confirms volume/pages/authors).
3. **Round 62's `S132` PMID lead was the wrong record.** NegEx is PMID **12123149**;
   11554662 is "Endoscopic transnasal pituitary surgery: report on 180 cases." The
   correct record is captured at `S141` via the NLM PubMed XML deposit (the PubMed HTML
   page is behind the same cookie wall).
4. **A PDF body cannot carry a `rendered-text-v1` quote** (`SETUP (not strict UTF-8)`).
   The Jia & Harman quote is located in `S139.txt`, the text layer of the same committed
   PDF, and both digests are recorded — the shape `S078`/`S079` already use for
   PDF-sourced rows.

### Search log (round 63, kagi scout)

Question: which sources ground (a) the negation **pseudo-negation / termination-term**
class the C1 grammar's exception list needs, (b) mutation testing's **equivalent-mutant**
problem behind "a surviving mutant must be killed or shown equivalent", and (c) one weak
lead to reject? Where searched: NLM eutils `esearch` over `db=pmc` (terms:
`ConText negation experiencer temporal` → 270 hits, `ConText[Title]` → many;
`"A simple algorithm for identifying negated findings…"[Title]` → 0 hits in PMC, so the
NegEx record was resolved in `db=pubmed` instead), NLM `efetch`/`esummary`/`elink`
(PMC + PubMed), Europe PMC REST (500 on `fullTextXML` for PMC2757457 — not usable),
IEEE Xplore (document and `/abstract/` paths), Crossref REST, Semantic Scholar Graph
API (429 / 404 for the DOI — not usable), dblp (202), arXiv (abs + HTML), the
Mutation Testing Repository at `mutationtesting.uni.lu` (HTML), ACL Anthology-style
course mirrors, MDPI (403), Europe PMC `textMinedTerms` (404). Identified: 12 distinct
candidate records; screened: 10 (all opened and captured); included: 6; excluded: 4
(`S136`, `S138`, `S142`, `S144`). Stop: the three plan-named classes (pseudo-negation /
termination-term; equivalent-mutant definition and its kill consequence; the NegEx
scope-and-filter rule) each have at least one peer-reviewed, locatable carrier, and one
vendor blog was measured as the reject.
