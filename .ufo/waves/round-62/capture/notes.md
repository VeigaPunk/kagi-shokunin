# Round 62 — source capture notes (R62ScoutSources)

Seat: `R62ScoutSources` (scout; axes freshness, coverage). Plan `plans/round-62.md`
§Frontier step. Access date for every page below: **2026-11-07**.

Fetch method (all pages): `curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36
(KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed`, with an `Accept` /
`Accept-Language` header pair on the NCBI hosts. The captured bytes are curl's **decoded**
body (every host served `content-encoding: gzip` or `zstd`; `--compressed` decompressed it),
so `sha256sum` is over the decoded body, matching the registry's existing "decoded body"
convention.

Byte counts and digests below are `stat -c%s` and `sha256sum` of the committed capture file
`<id>.body` in this directory.

## Secret discipline

No `Set-Cookie`/`Cookie` header value was written to any capture, note or receipt. The
recorded headers under `.ufo/waves/round-62/build/R62ScoutSources/headers-record.txt` were
produced by filtering `^(set-cookie|cookie):` out of the curl headers *before* writing;
the filtered files carry zero cookie-bearing lines (measured, `grep -ciE
'set-cookie|^cookie'` ⇒ 0).

The NCBI PMC **article HTML** pages were deliberately **not** used as the capture bodies
for S130/S131, because their markup embeds a live per-request anti-forgery token
(`<input type="hidden" name="csrfmiddlewaretoken" value="…">`) whose value differs on
every fetch — it is a session credential, and committing it would put a live token value
in the repository. Their body digest is also not reproducible (two consecutive fetches of
the same URL gave two different digests). The PMC rows therefore capture the **NLM
canonical XML** for the same records
(`eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=…&retmode=xml`, the same
records NLM serves as PMC's XML deposit), which is token-free and byte-stable (2/2
consecutive fetches, one digest).

The Wikipedia article HTML (S133) is different: its MediaWiki token fields hold the
anonymous placeholder value `+`, no opaque token value of length ≥ 12 appears anywhere in
the body, no session-cookie value appears in the body, and the body **is** byte-stable
(3/3 consecutive fetches, one digest) — so that HTML body is committed as-is and the
registry row's pinned digest still holds.

Measured on the committed files:
`grep -ciE 'csrfmiddlewaretoken" value="[A-Za-z0-9]{20,}"|"csrfToken":"[A-Za-z0-9]{20,}"'`
⇒ **0 for every one of the seven `.body` files**. The PMC HTML variants were fetched and
inspected in scratch only; their token values never reached a committed artifact.

## Quote resolution

Every quoted string below was resolved with

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-62/capture/<id>.body "<quote>"
```

and the printed output is reproduced verbatim. All ten quoted strings print
`RENDERED_TEXT_V1_LOCATE: count=1` (raw output:
`.ufo/waves/round-62/build/R62ScoutSources/locate-output.txt`).

---

## S128 — Pitest, "Real world mutation testing" — https://pitest.org/

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=utf-8`, `content-encoding: gzip`
- Bytes: **12023**
- sha256: `b0c7e0505c51c95b596060ef27babbce08e72d5aaf4557eb002c2637d2bf10cc`
- Capture: `.ufo/waves/round-62/capture/S128.body`
- Location: page heading `h1 "What is mutation testing?"` (the site's own byline for the
  passage is "How it works in 51 words"), raw byte offset ~4256–4471; the sentence sits
  between the site's `h1 "Real world mutation testing"` and the next `h1 "What?"`.
- Located quote (≤25 words, **19 words**):
  `If your tests fail then the mutation is killed , if your tests pass then the mutation lived .`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**14 words**, the metric sentence):
  `The quality of your tests can be gauged from the percentage of mutations killed.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `docs`).
- Reason: this is the tool's own definition of the two mutant outcomes, not marketing copy:
  a mutation that fails the suite is *killed*, a mutation the suite passes *lived* (the
  site's word for survived), and the kill count is the score. That is the definition the
  C2 predicate's kill contract rests on — "killed" is the count of mutants the test suite
  detects. Two independently maintained implementations (this row and S129) agree on the
  same kill/survive dichotomy, so the term is not one vendor's coinage.
- Note on the rendered spacing: the body carries `killed ,` / `lived .` with a space before
  the comma and the period because the words are wrapped in `<strong>` tags and
  `rendered-text-v1` step 3 replaces every tag with one space. The quote above is the
  collapsed rendered string and is the string that resolves `count=1` — a quote written
  without those spaces will not locate.
- Flip: a PIT revision that redefines or removes the killed/lived terminology (for example
  a copy change that drops the "How it works in 51 words" passage) would void this row's
  grounding; a revision that adds an explicit "survived" spelling would strengthen it (this
  page currently uses *lived*, not *survived* — measured below).

---

## S129 — Stryker Mutator, "What is mutation testing?" — https://stryker-mutator.io/docs/

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=utf-8`, `content-encoding: zstd`
- Bytes: **30253**
- sha256: `185130082d9961cb4cb0d9527f2281e58b2e2126ee2372551193b0decd6c9e8e`
- Capture: `.ufo/waves/round-62/capture/S129.body`
- Location: `h1 "What is mutation testing?"` → the paragraph immediately after the "TL;DR"
  block, raw byte offset ~17472; the second quote is under `h2 "An example"`, raw byte
  offset ~23884.
- Located quote (≤25 words, **18 words**):
  `If your tests fail then the mutant is killed . If your tests passed, the mutant survived .`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**16 words**):
  `If at least one of your tests fail, we say the mutant is killed . That's what we want!`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `docs`).
- Reason: this is the second, independently maintained tool's statement of the same
  dichotomy, and it uses the word the C2 predicate names — *survived* — which PIT does not.
  The kill/survive pair C2's kill contract counts is therefore attested by two vendors
  that use different prose for the same rule, and the "killed" side is defined by the
  test-suite outcome, which is the observable the C2 counter's mutant legs must make
  falsifiable. It also states the direction of the metric ("the higher the percentage of
  mutants killed, the more effective your tests are"), which is what makes "killed" a
  countable and not merely a label.
- Note on the rendered spacing: as on S128, `<em>`-wrapped words leave a space before the
  following punctuation in the rendered text; the quoted strings are the collapsed rendered
  form and are the ones that resolve.
- Flip: a Stryker docs revision that renames the reporter statuses away from
  "Mutant killed"/"Mutant survived" would void this row's grounding.

---

## S130 — ConText: an algorithm for determining negation, experiencer, and temporal status from clinical reports (Harkema et al., J Biomed Inform 2009;46(5):708–718) — https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/xml; charset=UTF-8`
- Bytes: **189603**
- sha256: `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`
- Capture: `.ufo/waves/round-62/capture/S130.body`
- Capture form: the NLM canonical **PMC XML deposit** of the record (PMID 19435614,
  PMCID PMC2757457), fetched with `efetch.fcgi?db=pmc&id=2757457&retmode=xml`. The
  article's HTML rendering was fetched and read in scratch but is **not** the committed
  body, because the PMC HTML page embeds a per-request `csrfmiddlewaretoken` value (a
  session credential). The XML deposit is the same record in NLM's own machine-readable
  form and carries no token (measured: 0 token hits in the committed file).
- Location: `<abstract>` → `<p id="P1">` (the Abstract, XML byte offset ~4377–4424);
  the NegEx-scope quote is in `<sec id="S9">` → `<title>3.1.4 ConText and NegEx</title>`,
  XML byte offset ~31021.
- Located quote (≤25 words, **20 words**) — the NegEx trigger-scope rule:
  `In the NegEx algorithm the scope of a trigger term is a priori restricted to a window of six tokens`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**15 words**) — the Abstract's negated-condition statement:
  `an algorithm called ConText for determining whether clinical conditions mentioned in clinical reports are negated`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed journal article).
- Reason: this is the peer-reviewed successor to NegEx by the NegEx author group
  (Chapman is a co-author), and it is the one openly retrievable negation-detection
  primary source that states NegEx's *rule* rather than only its name: a negated finding is
  identified by a trigger term whose scope is a bounded window of following tokens. That
  is exactly the shape of the C1 hardened grammar's negator rule — a negator token with a
  bounded look-behind window — so the round's polarity rule is grounded in a named
  published algorithm, not only in the round's own choice of a window length. It grounds
  the *shape* of the rule; it does not validate the round's specific 5-token window, which
  the plan itself names as a floor.
- Flip: a revision that removes the "3.1.4 ConText and NegEx" comparison (or the Abstract's
  negated-condition sentence) would void this row's grounding; a NegEx-family primary that
  states the trigger-scope rule more directly would supersede it.

---

## S131 — DEEPEN: a negation detection system for clinical text incorporating dependency relation into NegEx (Mehrabi et al., J Biomed Inform 2015;54:213–219) — https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=5863758&retmode=xml

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/xml; charset=UTF-8`
- Bytes: **101800**
- sha256: `80ec43266cc9bf39e6cf05fc45cb2c3ccf58ce9802d023cd820dbe999998cc38`
- Capture: `.ufo/waves/round-62/capture/S131.body`
- Capture form: the NLM canonical **PMC XML deposit** of the record (PMID 25791500,
  PMCID PMC5863758), fetched with `efetch.fcgi?db=pmc&id=5863758&retmode=xml`. Same
  token-free rationale as S130.
- Location: `<abstract>` → `<p id="P13">` (the Abstract, XML byte offset ~7270–7663).
- Located quote (≤25 words, **19 words**):
  `A negation detection algorithm, NegEx, applies a simplistic approach that has been shown to be powerful in clinical NLP.`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**13 words**) — the failure mode the C1 grammar must not reproduce:
  `NegEx fails to correctly capture the negation status of concepts in complex sentences.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: ADMIT** (tier A, kind `spec` — peer-reviewed journal article).
- Reason: it names NegEx as *the* negation-detection algorithm of the clinical NLP
  literature and, in the same Abstract, states its known failure mode — a trigger-word
  algorithm misses the negation status of a concept in a complex sentence. That is the
  published reason a negation-detection rule needs a scope/dependency refinement, and it
  is the published reason the C1 hardened grammar cannot stop at "the negator word is
  somewhere nearby": a *found* negation trigger is not the same as the *assertion's* being
  negated. The row therefore grounds the polarity rule's purpose (the class of error the
  round's grammar narrows) alongside S130's rule shape.
- Flip: a revision that drops the Abstract's NegEx characterisation or its failure-mode
  sentence would void this row's grounding.

---

## S132 — PubMed record 11554662 (the seat's named NegEx candidate) — https://pubmed.ncbi.nlm.nih.gov/11554662/

- Access date: 2026-11-07
- HTTP status: **203** (`HTTP/2 203`), `content-type: text/html; charset=utf-8`, `content-encoding: gzip`
- Bytes: **5590**
- sha256: `1c7cd57eeb20dcd72062670ee2d1ff736b8350031fd37b404bcc89f7a834704c`
- Capture: `.ufo/waves/round-62/capture/S132.body`
- Location: the whole body is a cookie-wall shell; the visible text is
  `pubmed.ncbi.nlm.nih.gov Cookies must be enabled Enable cookies for pubmed.ncbi.nlm.nih.gov and reload this page to continue.`
  There is no abstract, no title, and no negation sentence anywhere in the body.
- Locate output (probe for the term itself):
  `python3 corpus/rendered-text-v1.py locate S132.body "negation"` ⇒ `RENDERED_TEXT_V1_LOCATE: count=0`
- **Verdict: REJECT** — with **two** measured reasons.
  1. **Measured, primary:** the page returns HTTP **203** and a 5590-byte cookie wall, not
     the record. The term "negation" occurs **0** times in the rendered body, so the page
     carries no sentence about identifying negated findings to locate. Retries with a
     browser `Accept`/`Accept-Language`/`Sec-Fetch-*` header set, with a `?format=pubmed`
     variant, and with a cookie jar carried across two consecutive requests, all returned
     the same 203 / 5590-byte body (6 fetch attempts, all 203).
  2. **Measured, and a defect in the round's candidate list:** the PMID in the seat's
     candidate list, **11554662**, does not point at Chapman et al.'s NegEx at all.
     Europe PMC's `EXT_ID:11554662` record resolves it to *"Endoscopic transnasal
     pituitary surgery: report on 180 cases"*, Nasseri SS, Kasperbauer JL, Strome SE,
     McCaffrey TV, Atkinson JL, Meyer FB, *American Journal of Rhinology* 2001;15(4):281–287
     — a rhinology case series with **no** negation-detection content (fetched 2026-11-07,
     `https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=EXT_ID:11554662&resultType=core&format=json`,
     HTTP 200, body sha256 `140a425d574f41e2a708abc34f077ae5810d8f7dbd37d5a7862714fabc06a4ad`,
     5579 bytes; full receipt
     `.ufo/waves/round-62/build/R62ScoutSources/pmid-resolution.txt`). The genuinely
     NegEx-attributed work is elsewhere, and its follow-on papers (S130 ConText, S131
     DEEPEN) are what carry the negation-detection content this round needed.
  - **Reported, not amended.** The plan is frozen and names no PMID, so no frozen text is
    touched; the defect is in the seat's candidate list, not in the plan's predicate. The
    L1 should record the corrected candidate and the two admitted negation rows (S130,
    S131) that replace it in the registry.
  - Flip: a PubMed record page that renders the NegEx abstract's own text under a browser
    that satisfies NCBI's cookie check — the record's PMID and a fetch that yields the
    abstract body rather than the 203 shell — would turn this row from rejected to
    admitted; equivalently, the row flips if the cited record is the NegEx paper rather
    than the 2001 rhinology case series.

---

## S133 — Wikipedia, "Mutation testing" — https://en.wikipedia.org/wiki/Mutation_testing

- Access date: 2026-11-07
- HTTP status: **200** (`HTTP/2 200`), `content-type: text/html; charset=UTF-8`, `content-encoding: gzip`
- Bytes: **171636**
- sha256: `05dbe35feafc565a4e791a27453e4ffc08efcfccdf12357d2db3c6808b47c548`
- Capture: `.ufo/waves/round-62/capture/S133.body`
- Capture form: the rendered article HTML, fetched from the canonical article URL. This
  body is **byte-stable** — three consecutive fetches on 2026-11-07 returned the same
  digest (`05dbe35f…`) — and the MediaWiki token fields it carries
  (`"csrfToken":"+\\"`, `"patrolToken":"+\\"`, `"watchToken":"+\\"`) hold the anonymous
  placeholder value `+`, not a session credential (measured: no opaque token value of
  length ≥ 12 appears in the body, and no `WMF-DP` / `ncbi_sid` / `GeoIP=` value appears
  in it). So the HTML body is safe to commit and is the form the registry row pins.
- Location: §"Mutation testing overview" — the paragraph beginning "The result of applying
  one mutation operator to the program is called a mutant ."
- Located quote (≤25 words, **25 words**):
  `If the test suite is able to detect the change (i.e., one of the tests fails), then the mutant is said to be killed .`
- Locate output: `RENDERED_TEXT_V1_LOCATE: count=1`
- Second located quote (**14 words**), from the "Goals" section:
  `the mutation score is the number of mutants killed / total number of mutants.`
  → `RENDERED_TEXT_V1_LOCATE: count=1`
- **Verdict: REJECT** — the designated weak lead.
- Reason (measured, not stylistic): the article is **tertiary** — an editable
  encyclopedia page, not a vendor, standards or peer-reviewed document, so it cannot be
  the authority for a term a counter's verdict depends on. More concretely it is
  **incomplete on the exact pair the C2 claim rests on**: the page defines the *killed*
  side ("Rejection is called ''killing'' the mutant.", "the mutation score is the number of
  mutants killed / total number of mutants.") but the string `surviv` occurs **0** times in
  the captured body — it never names the surviving mutant, the outcome the C2 counter's
  "killed" count is the complement of. A row admitted from it would ground half of the
  kill/survive dichotomy and leave the other half unsupported. (The same measurement
  applies to S128: PIT says *lived*, not *survived* — which is why S129 is the row that
  carries the *survived* side, and why both are admitted.)
- Flip: a Wikipedia revision, or a replacement tertiary source, that states both outcomes
  by name (killed **and** survived) and cites a peer-reviewed or vendor definition for
  each; or the row is superseded by the two vendor rows it merely restates.

---

## S134 — Stryker Mutator, "Mutation testing" (the plan's optional third mutation-testing URL) — https://stryker-mutator.io/docs/mutation-testing/

- Access date: 2026-11-07
- HTTP status: **404** (`HTTP/2 404`), `content-type: text/html; charset=utf-8`, `content-encoding: zstd`
- Bytes: **14498**
- sha256: `f5a45b48e6aa53c2b2e1815c4f0ea0db1342ac9718dc1bd62b491a3020251b67`
- Capture: `.ufo/waves/round-62/capture/S134.body`
- Location: the body is the site's own "Page Not Found | Stryker Mutator" 404 shell
  (navigation chrome plus a not-found notice); it carries no mutation-testing definition.
- Locate output (probe for the term):
  `python3 corpus/rendered-text-v1.py locate S134.body "mutation testing"` ⇒ `RENDERED_TEXT_V1_LOCATE: count=0`
- **Verdict: REJECT** — measured: the plan's optional third candidate URL **does not
  exist** (HTTP 404). It is recorded as a row because the plan asks that a rejected
  candidate stay as a row with a reason and a flip.
- Reason: the URL the plan offers as a fallback for the mutation-testing definition returns
  404; the definition was therefore taken from the site's live index page (S129), which is
  the page the 404 shell's own navigation points at ("Mutation Testing" in the site menu).
- Flip: the site publishing a `docs/mutation-testing/` page — or the 404 shell changing to
  a redirect — would turn this row into an admitted candidate.

---

## Coverage summary for the L1

| id | URL | verdict | what it grounds |
|---|---|---|---|
| S128 | https://pitest.org/ | admit | killed/lived definition (kill side), mutation score |
| S129 | https://stryker-mutator.io/docs/ | admit | killed/survived definition (both sides), from a second vendor |
| S130 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml | admit | NegEx trigger-scope rule — the *shape* of a bounded negator window |
| S131 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=5863758&retmode=xml | admit | NegEx named as the negation-detection algorithm + its published failure mode |
| S132 | https://pubmed.ncbi.nlm.nih.gov/11554662/ | reject | 203 cookie wall, 0 negation content; PMID resolves to a rhinology paper (defect reported) |
| S133 | https://en.wikipedia.org/wiki/Mutation_testing | reject | tertiary; `surviv` occurs 0 times, so half the kill/survive pair is unnamed |
| S134 | https://stryker-mutator.io/docs/mutation-testing/ | reject | HTTP 404, page does not exist |

- Pages opened: **7**. Admitted: **4** (S128, S129, S130, S131). Rejected: **3** (S132, S133, S134).
- Every admitted quote resolves `count=1` under `corpus/rendered-text-v1.py locate`.
- Every capture file is under `.ufo/waves/round-62/capture/`; nothing under `/tmp`.
- No credential, cookie, session or token value appears in any capture, note or receipt:
  measured 0 token hits across all seven `.body` files, and the recorded headers carry 0
  cookie-bearing lines.

### Vocabulary measurements behind the verdicts

| measurement | S128 (PIT) | S129 (Stryker) | S133 (Wikipedia) |
|---|---|---|---|
| `surviv*` occurrences in the captured body | **0** (the page says *lived*) | present (*survived*, *survive*) | **0** |
| `killed` / `kill*` | present | present | present |

This is why S129 (not S128) is the row that carries the *survived* side of the C2 kill
contract, and why S133 cannot ground the pair.

### Defects reported to the L1 (not amended — the plan is frozen)

1. **PMID 11554662 in the seat's candidate list is not NegEx.** It resolves (Europe PMC,
   `EXT_ID:11554662`, HTTP 200, fetched 2026-11-07) to *"Endoscopic transnasal pituitary
   surgery: report on 180 cases"*, Nasseri SS et al., *Am J Rhinol* 2001;15(4):281–287 —
   a rhinology case series with no negation-detection content. The plan text names no
   PMID, so no frozen predicate is touched. The registry rows should carry S130 and S131
   as the negation-detection sources; the rejected S132 row records the failed candidate
   with its reason and flip.
2. **PubMed record pages are not fetchable from this host** — HTTP 203 cookie wall on
   every attempt (6 fetches, the same 5590-byte shell each time), so no
   `pubmed.ncbi.nlm.nih.gov` row can carry a located quote from here. The NCBI PMC XML
   deposit (`eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=…&retmode=xml`)
   serves the same records with HTTP 200 and carries no session token, which is where the
   two admitted negation rows come from.
3. **PIT spells the surviving outcome "lived", not "survived"** (measured: `surviv` occurs
   0 times in S128's captured body, while "lived" occurs once). A registry row or a lesson
   sentence that says "PIT defines killed/survived" would be wrong; the wording must be
   "killed/lived" for PIT and "killed/survived" for Stryker.
4. **The PMC article HTML pages embed a live per-request anti-forgery token** in their
   markup (`<input type="hidden" name="csrfmiddlewaretoken" value="…">`), and their body
   digest is **not reproducible** — two consecutive fetches of the same URL on 2026-11-07
   gave two different digests (`fa5c288f63b9ab92…` and `0b06abf718445345…`) because the
   token value differs each time. Any future row that captures that HTML must either
   strip the token value or use the token-free XML form these rows use. (The Wikipedia
   HTML is different: its token fields hold the anonymous placeholder `+` and its body
   **is** byte-stable — 3/3 fetches gave one digest — so S133's HTML body is committed
   as-is.)

## RE-PIN REQUIRED for S130 and S131 (action for the L1)

The registry rows for S130 and S131 were first pinned over the **PMC article HTML**
captures. Those bodies were subsequently replaced by the **token-free, byte-reproducible
NLM XML** of the same two records, so the pinned digests no longer match the committed
files. S128, S129, S132, S133 and S134 are unchanged and stay as pinned.

Exact values for the two re-pinned rows (receipt:
`.ufo/waves/round-62/build/R62ScoutSources/repin-table.txt`):

### S130 — ConText (Harkema et al., J Biomed Inform 2009)

- URL (new): `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml`
- tsv row-identity digest (sha256 of `S130<TAB>mined<TAB><url><LF>`):
  `c65298f1b8fc798d606799916cc6e9da8b1f10de5e529d0f5e0a1e550ca6e36a`
- raw sha256: `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`
- bytes: `189603`
- normalized sha256 (rendered-text-v1): `5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801`
- quote: `In the NegEx algorithm the scope of a trigger term is a priori restricted to a window of six tokens`
- location (≥8 chars): `§3.1.4 ConText and NegEx (PMC XML sec id=S9)`
- locate: `RENDERED_TEXT_V1_LOCATE: count=1`

### S131 — DEEPEN (Mehrabi et al., J Biomed Inform 2015)

- URL (new): `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=5863758&retmode=xml`
- tsv row-identity digest (sha256 of `S131<TAB>mined<TAB><url><LF>`):
  `b6338e6c472745a0c0acc466906ba89ac927553afb0072d9c68390ed8264327d`
- raw sha256: `80ec43266cc9bf39e6cf05fc45cb2c3ccf58ce9802d023cd820dbe999998cc38`
- bytes: `101800`
- normalized sha256 (rendered-text-v1): `8a12b87d5143f3d097c6a22555ad86d1a0b241aca79f441a1d745223f53bb30b`
- quote: `NegEx fails to correctly capture the negation status of concepts in complex sentences.`
- location (≥8 chars): `§Abstract (PMC XML p id=P13)`
- locate: `RENDERED_TEXT_V1_LOCATE: count=1`

Both rows' `decoded-http-body-v1` representation and `2026-11-07` fetch date are unchanged;
only the URL and the four digest/byte fields move. The capture path
(`.ufo/waves/round-62/capture/S130.body`, `…/S131.body`) is unchanged.
