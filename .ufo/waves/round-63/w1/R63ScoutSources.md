# R63ScoutSources — round 63 scout (freshness, coverage)

Lane: kagi (secrets & vault ops). Round 63, attempt 1. Plan `plans/round-63.md`
§Frontier step. Access date for every page: **2026-11-07**.

## 1. What this seat produced

Ten candidate pages opened live and captured; **six admitted, four rejected**; every
admitted quote resolves `RENDERED_TEXT_V1_LOCATE: count=1`.

- Capture ledger: `.ufo/waves/round-63/capture/notes.md` (per-page URL, status, bytes,
  sha256, quote, location, locate output, verdict, reason, flip condition).
- Capture bodies: `.ufo/waves/round-63/capture/S135.body` … `S144.body` plus
  `S139.txt` (the text layer of `S139.body`).
- Receipts: `.ufo/waves/round-63/build/R63ScoutSources/` — `h<id>.hdr` (response
  headers, cookie lines stripped) and `locate-output.txt` (the full locate transcript).

| id | source | verdict | the one thing it grounds |
|---|---|---|---|
| S135 | ConText (Harkema et al. 2009), NLM PMC XML deposit | admit | the pseudo-negation and termination-term classes |
| S136 | IEEE Xplore document 5661753 (the named Jia & Harman lead) | reject | 0-byte 202 challenge body; and the id is a different paper |
| S137 | Tian et al., ISSTA 2024 (arXiv HTML) | admit | the equivalent-mutant definition, citing Jia & Harman; 4–39 % prevalence |
| S138 | Codecov vendor blog | reject | the designated weak lead: vendor marketing copy, no primary citation |
| S139 | Jia & Harman TSE 2011, university-hosted PDF (+ text layer) | admit | "syntactically different but functionally equivalent" ⇒ can never be killed |
| S140 | Niedermayr & Wagner, EASE 2019 (arXiv HTML) | admit | the same rule, with the explicit "(Jia and Harman, 2011)" attribution |
| S141 | Chapman et al. NegEx 2001, NLM PubMed XML deposit | admit | NegEx filters false-negation phrases and limits their scope |
| S142 | IEEE Xplore `/abstract/document/5661753` | reject | evidence row: 5661753 = "Address Translation Aware Memory Consistency" |
| S143 | ConText, NCBI BioC XML deposit | admit | distinct-URL carrier of the same ConText class lesson |
| S144 | IEEE Xplore `/abstract/document/5487526` | reject | the right paper's IEEE id, but the served body carries no abstract text |

## 2. Coverage against the plan's frontier step

**Candidate 1 — the ConText pseudo-negation / termination-term classes (the C1 idiom
and contrastive exception list's ground).** Admitted twice, on two distinct URLs.
`S135` locates, in §3.1.2 "Trigger Terms, Pseudo-Trigger Terms, and Termination Terms"
(PMC XML `sec id="S6"`, paragraphs `P19`/`P20`):

- `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)` (17 words, count=1)
- `Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term.` (19 words, count=1)

The first names the **pseudo-negation class** — a phrase that contains a negation
trigger but does not act as one — and the paper's own examples (“no increase”, “not
cause”) are exactly the shape of the C1 idiom exceptions (`not only`, `no fewer than`).
The second names the **termination-term class**, the mechanism that closes a trigger's
scope early. Together they are the published grounding for C1 items (ii) and (iii).
Both quotes ground the *shape* of the rule, not the lane's 24-token window, which the
plan itself names as a closed-list floor.

**Candidate 2 — Chapman et al. NegEx, the sentence scope the C1 window narrows.** Admitted
at `S141`, the **NegEx paper itself** (PMID 12123149) via the NLM PubMed XML deposit:

- `filters out sentences containing phrases that falsely appear to be negation phrases, and limits the scope of the negation phrases` (20 words, count=1)
- `a simple regular expression algorithm called NegEx` (9 words, count=1)

This is the primary source for the two mechanisms the C1 grammar encodes — a closed
list of negation phrases, a **filter for phrases that falsely look like negation**, and
a **bounded scope** — where `S130`/`S131` carry only later papers' description of
NegEx. The plan's §Frontier step 2 permits a new row only if a page opened this round
grounds a new lesson; the filter-and-scope sentence is that lesson (`S130` already
carries NegEx's window number).

**Candidate 3 — Jia & Harman, the equivalent-mutant problem.** The plan's candidate URL
is a paywall lead and, as measured, the **wrong paper**; the admit candidate is the
survey's own text, obtained from a university mirror:

- `S139` (University of Michigan EECS mirror of the IEEE TSE 37(5):649–678 article):
  `These mutants are called Equivalent Mutants. They are syntactically different but functionally equivalent to the original program.` (17 words, count=1) and
  `there are some mutants that can never be killed, because they always produce the same output as the original program` (21 words, count=1).
  This is the C2 predicate's "killed **or shown equivalent**" contract in the survey's
  own words, and it grounds the score definition (killed ÷ **non-equivalent** mutants).
- `S137` (peer-reviewed ISSTA 2024): the same definition, cited to Jia & Harman, plus
  the measured prevalence — `Recent research indicates that the rate of equivalent mutants in real-world development scenarios ranges from 4% to 39%` (18 words, count=1).
- `S140` (peer-reviewed EASE 2019): the same rule with the provenance attached —
  `We further use common mutation testing terms as defined in literature ( Jia and Harman, 2011 )` (17 words, count=1).

**Candidate 4 — one weak lead, rejected.** `S138`, the Codecov blog: a vendor
marketing page. Measured in its captured body: `Jia`, `Harman`, `IEEE`, `citation` and
`peer-reviewed` occur **0** times each; its "equivalent mutants" paraphrase never states
the load-bearing consequence (that such a mutant can never be killed) and says nothing
about the surviving side, so it would ground half of the kill/survive pair — the same
defect that got round 62's `S133` rejected. Page stamp 2022-05-27.

## 3. Defects reported to the L1 (nothing amended here)

1. **The frontier candidate 1 URL is already a registry row.** `S135`'s efetch deposit is
   byte-identical to the existing `S130` — same URL, 189603 bytes, digest
   `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`, the digest
   `corpus/source-fetches.tsv` already records for `S130`. A new row on that URL is a
   duplicate-URL row. Because only `status`/`recheck`/`used-by` change in place
   (CORPUS.md rule 2), the new lesson needs a **new** row — and `S143` (the NCBI BioC
   XML deposit of the same PMC record: distinct URL, distinct digest
   `8522a79eba84604f4dbb37e0b46fa7a28c80eec69d00eaf5efecceef543c7208`) is offered as
   the collision-free carrier for the same two quotes. Both bodies locate count=1.
2. **The candidate list named the wrong IEEE document for Jia & Harman 2011.** Document
   5661753 is "Address Translation Aware Memory Consistency" (title locates count=1 on
   `S142`); the survey's IEEE id is 5487526 (`S144`'s title locates as "An Analysis and
   Survey of the Development of Mutation Testing"). Crossref independently confirms the
   identity (`api.crossref.org/works/10.1109/TSE.2010.62` ⇒ title, volume 37, issue 5,
   pages 649-678, authors Yue Jia and Mark Harman). The plan names the *paper*, not the
   URL, so no frozen text is touched.
3. **Round 62's `S132` PMID lead was the wrong record.** NegEx is PMID **12123149**;
   `esummary` for 11554662 returns "Endoscopic transnasal pituitary surgery: report on
   180 cases." The correct record is captured at `S141`. The PubMed *HTML* page is
   behind the same cookie wall, so the XML deposit is the usable form.
4. **A PDF body cannot carry a `rendered-text-v1` quote** (`SETUP (not strict UTF-8)`).
   The Jia & Harman quote is located in `S139.txt`, the text layer of the *same*
   committed PDF, with both digests recorded — the shape `S078`/`S079` already use for
   PDF-sourced rows.

## 3a. Registry-census check of the drafted row block (read-only, measured)

The lane's own registry gate (`bash corpus/sources-census.sh verify --root <tree>`) was
run read-only against scratch copies of the corpus — the lane tree was never modified.
Receipt: `.ufo/waves/round-63/build/R63ScoutSources/census-receipt.txt`.

| tree | census result |
|---|---|
| BASE `aeafc0e` corpus | `FAILED (findings=2 rows=134)` — two pre-existing `SC_BODY_CITE … id=S090 unrecorded` findings, unrelated to this round |
| BASE + the 10 drafted rows + the 9 drafted fetch rows, **verbatim** | `FAILED (findings=4 rows=144)` — **one finding the drafted block introduces**: `SC_FETCH id=S136 missing-provenance` |
| BASE + drafted rows, S136 dropped | `FAILED (findings=3 rows=143)` — the S136 finding clears, but the draft's `S130` gap remains |
| BASE + drafted rows + S136 re-pointed to its readable sibling + S130 `used-by` extended | `FAILED (findings=2 rows=144)` — **exactly the pre-existing BASE findings; nothing added** |

Two actionable items for the L1, both measured:

**(a) `S136` cannot carry a registry row as drafted.** The lane census requires every
registry row to have a capture row (`corpus/sources-census.sh:352` — a row with no
`source-fetches.tsv` entry raises `SC_FETCH id=… missing-provenance`), and a capture row
requires `bytes` to match `^[1-9][0-9]*$` (`:290`). `S136`'s body is **0 bytes**, so no
fetch row can describe it and the row cannot exist as drafted — the scribe's note "S136
has no fetch row" is the correct reading of the bytes rule but does not clear the
capture-row requirement. Two ways out, both measured above:
- **drop the `S136` registry row** and carry its rejection in the lesson's Gate and in
  `capture/notes.md` only (the plan's Frontier step 4 asks for *one* reject row; `S138`
  already is one, with a non-empty body and a valid capture row); or
- **re-point the `S136` row at its readable sibling** `https://ieeexplore.ieee.org/abstract/document/5661753`
  (the body that proves the misidentification) and give it a capture row on that fetch —
  this is the variant measured in row 4 of the table, which adds **no** finding.

**(b) `S130`'s `used-by` must gain `corpus/knowledge/negation-scope-grammar.md`.** The
round-63 knowledge entry names `S130` in its prose (`negation-scope-grammar.md:21`, "a
trigger's scope to a window of six tokens (S130)"), and the census requires every id an
entry names to be listed in that row's `used-by` (`corpus/sources-census.sh:390` —
`SC_ENTRY_CITE … id=S130 used-by-omits-entry`). This is an **in-place `used-by` change**,
which CORPUS.md rule 2 permits, and it clears the finding (measured). Note the lesson
path `corpus/lessons/round-63.md` cannot be added to `S130`'s `used-by`: the lesson
carries `S130` in prose but not on its `cites:` line, so the census raises
`SC_USEDBY_NOCITE` for it — only the knowledge-entry path is correct.

The two remaining findings (`id=S090 unrecorded` in `openbao-approle-secret-id-custody.md`
and `openbao-seal-key-custody.md`) are **pre-existing at BASE** and belong to another
seat's scope; they are recorded here so the L1 does not mistake them for round-63 fallout.

## 3b. Escalation: the L1 cannot wake

After this seat's findings were delivered to the L1, its wake turn failed with
`402 Insufficient account funds` (provider-side, `[opencode-go/deepseek-v4.1-flash]`).
The message itself **was** delivered — it is the last entry in `history://KagiR63` — so
nothing is lost; the L1 simply has not run to act on it. No lane file was touched by any
seat for ~7 minutes afterwards (checked 20:29–20:30 −03:00). This seat is a leaf and
did **not** re-dispatch, integrate, commit, or touch the L1's lane or index; the blocker
was escalated to `Main` instead.

Everything this seat produced is already in the canonical paths (above), so a resumed L1
needs nothing further from this seat — in particular the two census defects in §3a, which
the L1 has not yet read and which affect its `corpus/SOURCES.md` append step.

## 3c. Ready-to-run applier for the two census defects

Because both the L1 and the scribe became unable to wake (provider-side errors, see
§3b), the fix for the two census defects in §3a is packaged as a script the L1 can run
itself after appending the rows:

```
bash .ufo/waves/round-63/build/R63ScoutSources/apply-census-fix.sh [--dry-run]
```

It is **not** run by this seat — it is the L1's to apply, because the L1 owns every
write to `corpus/SOURCES.md`, `corpus/source-fetches.tsv` and the lane's git/jj index.
The script re-points the `S136` row at its readable sibling and adds the matching
capture row, and extends `S130`'s `used-by` with the round-63 knowledge entry; it
then re-runs the lane's own gate and prints the result.

Verified on a scratch copy of the corpus carrying the drafted rows **verbatim** (the
live lane was never touched):

| state | census |
|---|---|
| drafted rows + drafted fetch rows, before the fix | `FAILED (findings=4 rows=144)` — `SC_FETCH id=S136 missing-provenance`, `SC_ENTRY_CITE … id=S130 used-by-omits-entry`, and the two pre-existing `id=S090` findings |
| after the applier | `FAILED (findings=2 rows=144)` — **exactly the two pre-existing BASE findings; both defects cleared** |
| applier run a second time | no change (`re-pointed=False capture-row-added=False used-by-extended=False`) — idempotent |
| `--dry-run` | reports the intended changes and writes nothing (both files byte-identical afterwards) |

## 4. Secret discipline

No credential material in any artifact. The NCBI responses carried a `set-cookie:
ncbi_sid=…` line (`h135`, `h141`); those lines were filtered **before** writing, and
every recorded header file now measures 0 cookie-bearing lines. Token scan over all
committed bodies and the notes: 0 hits for a `csrfmiddlewaretoken`/`csrfToken` value of
length ≥ 20. The one per-request artifact seen and discarded is an HTTP 429 shell
(fetched into scratch, never committed — recorded in `S143`'s stability note).

## 5. Bounds

- The quotes ground the **shape** of the C1/C2 rules, not the lane's specific numeric
  windows or token lists; the plan names those as closed-list floors.
- `S139`'s text layer is derived from the committed PDF, not a separate fetch; both
  digests are in the notes so the pair reproduces from one fetch.
- `S143`'s endpoint is rate-limited (2/3 byte-identical fetches; one HTTP 429), so its
  digest should be treated as volatile-ish in `corpus/source-fetches.tsv`.
- The registry rows themselves are the L1's to write; this seat appended nothing to
  `corpus/SOURCES.md` and ran no mutating git or jj command anywhere.

SEAT-STATUS: complete
