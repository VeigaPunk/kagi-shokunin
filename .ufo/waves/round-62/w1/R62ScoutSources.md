# R62ScoutSources — round 62 wave 1 (scout; axes freshness, coverage)

## What I did

Opened the round's candidate sources live (2026-11-07), captured the decoded bodies under
`.ufo/waves/round-62/capture/`, located a ≤25-word quote for each page under
`corpus/rendered-text-v1.py locate` (every admitted quote prints `count=1`), and wrote the
per-page evidence with an admit/reject verdict and a flip to
`.ufo/waves/round-62/capture/notes.md`.

**Deliverable:** `.ufo/waves/round-62/capture/notes.md` — 7 page blocks (≥3 required),
**4 admits**, **3 rejects** (≥2 admits, ≥1 reject required). Every admitted quote resolves
`count=1`; every capture file is under the capture dir (nothing under `/tmp`); no credential
material in any note (measured 0 token hits across all seven `.body` files).

I did not touch `corpus/SOURCES.md` — the L1 appends the rows.

## Rows (proposed registry ids; the L1 owns the append)

| id | URL | verdict | located quote (≤25 words) | count |
|---|---|---|---|---|
| S128 | https://pitest.org/ | **admit** | `If your tests fail then the mutation is killed , if your tests pass then the mutation lived .` (19 w) | 1 |
| S129 | https://stryker-mutator.io/docs/ | **admit** | `If your tests fail then the mutant is killed . If your tests passed, the mutant survived .` (18 w) | 1 |
| S130 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml | **admit** | `In the NegEx algorithm the scope of a trigger term is a priori restricted to a window of six tokens` (20 w) | 1 |
| S131 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=5863758&retmode=xml | **admit** | `A negation detection algorithm, NegEx, applies a simplistic approach that has been shown to be powerful in clinical NLP.` (19 w) | 1 |
| S132 | https://pubmed.ncbi.nlm.nih.gov/11554662/ | **reject** | — (HTTP 203 cookie wall; `negation` count=0) | — |
| S133 | https://en.wikipedia.org/wiki/Mutation_testing | **reject** | `If the test suite is able to detect the change (i.e., one of the tests fails), then the mutant is said to be killed .` (25 w) | 1 |
| S134 | https://stryker-mutator.io/docs/mutation-testing/ | **reject** | — (HTTP 404, page does not exist) | — |

### RE-PIN REQUIRED for S130 and S131

The registry rows for S130/S131 were first pinned over the **PMC article HTML** captures.
Those bodies were then replaced by the **token-free, byte-reproducible NLM XML** of the
same two records, so the pinned digests no longer match the committed files (S128, S129,
S132, S133, S134 are unchanged and stay as pinned). Exact replacement values — URL, tsv
row-identity digest, raw sha256, bytes, normalized sha256, quote, location — are in
`.ufo/waves/round-62/build/R62ScoutSources/repin-table.txt` and in the notes' §"RE-PIN
REQUIRED" section. The reason is measured, not stylistic: the PMC article HTML embeds a
live per-request `csrfmiddlewaretoken` value, and two consecutive fetches of the same URL
gave **two different digests** (`fa5c288f63b9ab92…`, `0b06abf718445345…`) — a pin over
that body was never re-fetchable. The efetch XML is reproducible: 2/2 fetches, one digest.

Second quotes (also `count=1`, in the notes and the receipt): S128
`The quality of your tests can be gauged from the percentage of mutations killed.`;
S129 `If at least one of your tests fail, we say the mutant is killed . That's what you
want!`; S130 `an algorithm called ConText for determining whether clinical conditions
mentioned in clinical reports are negated`; S131 `NegEx fails to correctly capture the
negation status of concepts in complex sentences.`; S133 `the mutation score is the number
of mutants killed / total number of mutants.`

## Why these admit (the learner benefit each grounds)

- **S128 + S129** — the C2 claim's kill contract counts *killed* mutants. Two independently
  maintained tools define the two outcomes of the same experiment: a mutant whose tests
  fail is **killed**, a mutant whose tests pass **survived**. PIT spells it *lived*, Stryker
  spells it *survived* — measured, not assumed (see the vocabulary table below). A learner
  reading the C2 counter's "killed 0→3" verdict learns what the counted thing is.
- **S130** — the C1 hardened grammar tests a negator token in the asserting position with a
  bounded look-behind window. S130 states NegEx's rule in exactly that shape (a trigger
  term whose scope is a bounded window of following tokens), so the round's polarity rule
  is grounded in a named published algorithm and not only in the round's own choice of a
  window length. It grounds the *shape*; the plan's own "5-token window is a floor" ceiling
  still stands.
- **S131** — the published failure mode of a trigger-word negation detector: it misses the
  negation status of a concept in a complex sentence. That is the reason the C1 grammar
  cannot stop at "a negator word is nearby" — a *found* negation trigger is not the same as
  the *assertion's* being negated.

## Why these reject

- **S132** (the plan's named NegEx candidate) — HTTP **203**, a 5590-byte cookie wall on
  every one of 6 fetch attempts (browser header set, cookie jar carried across two
  requests, `?format=pubmed` variant). The rendered body contains the word *negation*
  **0** times; it carries no abstract and no sentence to locate. Second, measured defect:
  **PMID 11554662 is not NegEx** — Europe PMC resolves it to *"Endoscopic transnasal
  pituitary surgery: report on 180 cases"*, Nasseri SS et al., *Am J Rhinol* 2001;15(4):281–287,
  a rhinology case series with no negation-detection content. Flip: a fetch that yields the
  real NegEx record's abstract body under a cookie-satisfying browser, or a citation of the
  record that actually carries the algorithm.
- **S133** (the designated weak lead) — tertiary, editable encyclopedia page, and
  **incomplete on the exact pair C2 rests on**: it defines the *killed* side ("the mutation
  score is the number of mutants killed / total number of mutants.") but the string
  `surviv` occurs **0** times in the captured body, so the surviving mutant — the
  complement of the count the C2 counter reports — is never named. Flip: a revision, or a
  replacement tertiary source, that names both outcomes and cites a definition for each.
- **S134** — the plan's optional third mutation-testing URL **does not exist**: HTTP 404.
  Flip: the site publishing `docs/mutation-testing/`, or the 404 shell becoming a redirect.

## Vocabulary measurements behind the verdicts

| measurement (captured body) | S128 (PIT) | S129 (Stryker) | S133 (Wikipedia) |
|---|---|---|---|
| `surviv*` | **0** (page says *lived*) | 6 (*survived*, *survive*, *survivor*) | **0** |
| `kill*` | present | present | present |

This is why S129 — not S128 — is the row that carries the *survived* side of the C2 kill
contract, and why S133 cannot ground the pair.

## Defects reported to the L1 (nothing frozen was amended)

1. **PMID 11554662 is not NegEx.** The plan text names no PMID, so no frozen predicate,
   target, POP, kill rule or item condition is touched. The registry rows should carry
   S130 and S131 as the negation-detection sources; the rejected S132 row records the
   failed candidate with its reason and flip.
2. **PubMed record pages are unfetchable from this host** (HTTP 203 cookie wall, 6/6
   attempts), so no `pubmed.ncbi.nlm.nih.gov` row can carry a located quote from here. The
   NCBI PMC XML deposit serves the same records with HTTP 200 and no session token.
3. **PIT says "lived", not "survived"** — a lesson or registry sentence reading "PIT
   defines killed/survived" would be wrong.
4. **The PMC article HTML pages embed a live per-request anti-forgery token**
   (`csrfmiddlewaretoken`) and their body digest is **not reproducible** — two consecutive
   fetches of the same URL gave two different digests. Committing those HTML bodies would
   put a live session credential in the repository and pin an unre-fetchable digest, so
   the PMC rows capture the token-free, byte-reproducible NLM XML deposit instead (2/2
   fetches, one digest). The Wikipedia HTML is different — its token fields hold the
   anonymous placeholder `+`, it carries no session-cookie value, and its body **is**
   byte-stable (3/3 fetches, one digest) — so S133's HTML body is committed as-is.
   Measured: 0 opaque token hits in all seven committed `.body` files.

## Receipts

- `.ufo/waves/round-62/capture/notes.md` — the deliverable: 7 page blocks with URL, access
  date, status, bytes, sha256, quote, location, verbatim locate output, verdict + reason +
  flip.
- `.ufo/waves/round-62/capture/S128.body` … `S134.body` — the seven captured bodies.
- `.ufo/waves/round-62/build/R62ScoutSources/locate-output.txt` — verbatim `locate` output
  for all ten quoted strings.
- `.ufo/waves/round-62/build/R62ScoutSources/headers-record.txt` — HTTP status lines with
  `Set-Cookie`/`Cookie` lines filtered out **before** writing (0 cookie-bearing lines).
- `.ufo/waves/round-62/build/R62ScoutSources/pmid-resolution.txt` — the Europe PMC evidence
  that PMID 11554662 is not NegEx.
- `.ufo/waves/round-62/build/R62ScoutSources/repin-table.txt` — the exact values the L1
  needs to re-pin S130 and S131 (URL, tsv row-identity digest, raw sha256, bytes,
  normalized sha256, quote, location, verbatim locate output).

## Scope and bounds

- Wrote only: `.ufo/waves/round-62/capture/{notes.md,S128..S134.body}`,
  `.ufo/waves/round-62/build/R62ScoutSources/*`, and this report at
  `.ufo/waves/round-62/w1/R62ScoutSources.md`. No `corpus/SOURCES.md` edit (L1 appends), no
  other lane file.
- No git/jj mutation of any kind was run anywhere; no `git add/commit/stash/push`, no
  mutating `jj`. The lane index was not touched.
- All scratch (fetches, HTML variants, Europe PMC JSON, the cookie-jar attempt) lived under
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ScoutSources/` and was deleted before
  this report was written; nothing was written under `/tmp` and no citable evidence lives
  there.
- No tool was installed or upgraded this round; nothing to record on the tooling channel.
  The only tools used were `curl`, `python3`, `sha256sum`/`stat`, already present on the
  host.
- No host path outside the lane and scratch was written or modified.

## Remaining unknowns

- **The L1's S130/S131 rows need the re-pin above.** This is the one open item on the
  capture side: until the L1 applies the re-pin table, the registry's digest cell for
  those two rows names bytes that are no longer the committed ones. The rows themselves
  (id, status, tier, teaches, verdict) are unaffected, and both quotes still resolve
  `count=1` on the committed files — verified by R62ScribeEntry independently.
- Whether the registry wants the rejected rows appended as rows (the plan says a rejected
  candidate stays as a row with reason and flip) — S132 and S134 are ready to append with
  their measured reasons; S133 is the plan's designated weak lead.

SEAT-STATUS: complete
