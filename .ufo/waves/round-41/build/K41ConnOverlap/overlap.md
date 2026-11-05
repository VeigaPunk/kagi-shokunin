# K41ConnOverlap — sibling overlap scan (round 41, read-only)

Scope: `/home/vgpnk/Projects/shokunin/*-shokunin` except `kagi-shokunin`; `corpus/` trees, `SKILL.md` and `PROVINCE.md` of each sibling (20 lanes). `.ufo/` wave receipts are outside the declared scope and appear only where a sweep hit them (marked *out of scope*). Lane HEAD read: `kagi-shokunin` `5142b52`. No file was edited; no git mutation.

Claims: **C1** = expectation-journal gate (`corpus/expect-journal.sh`, frozen rules R1–R4). **C2** = rendered-text-v1 Sources paragraph citing S095/S097 (whitespace class; S098 rejected).

## Bottom line

- **Expectation-journal ground (C1): no sibling holds one.** No `expect-journal`, `expectation-migration`, `expect_journal`, or migration journal exists in any sibling corpus, SKILL or PROVINCE. The ledger-expectation ground is kagi's (`corpus/claim-ledger.sh`), as kengaku's round-11 connector record describes it. Nothing in a sibling collides with C1.
- **Rendered-text normalizer (C2): no sibling owns it.** No sibling declares a `rendered-text` normalizer, and no sibling cites `UTS #18`, `tr18`, `str.isspace`, or `rendered-text-v1`. The nearest sibling grounds are listed below; none is a normalizer for the rendered text of a sibling's quotes.
- **Whitespace class citing Python `re` `\s`: one sibling.** kengaku cites the `re.html` special sequence `\s` (S046) for a grader fence normalizer. Same URL and same concept class as kagi's S095; a different claim. Adjacency, not collision.
- **White_Space property class: one sibling.** kumitate keys an invisible-prefix class on UCD `White_Space` and `Cf` (S260, S261). That is the property family S098 is rejected against. It does not cite UTS #18 itself. C2 must not cite S261 as the normalizer class.

## Table A — (a) expectation journals and literal-anchored expectation gates

| Lane | File (line) | What it is | Overlaps C1 or C2? | Owner / ground |
|---|---|---|---|---|
| kengaku | `corpus/evidence/round11-fleet/r11-connector.md:21` | Describes kagi `corpus/claim-ledger.sh`: checks revision stamps, requires expected exit status plus matching final output line; notes its self-test does not run `verify` against real files. | **C1 adjacency** — describes the exact ledger C1 gates on, and its stated ceiling. | kagi (`claim-ledger.sh`), as recorded by kengaku. |
| kasegi | `corpus/instruments/r46-mutant-equivalents/README.md:53-55`; `…/f29-H1b-H7a-H7c-proofs.md:19` | "loosening the anchor" of a census ok-line tab anchor classified *equivalent-on-battery*. | **C1 concept adjacency** — a loosened anchored check accepted by battery equivalence. Not a journal; not literal-anchored expectation. | kasegi (census gates; fleet census at fleet root). |
| kake | `corpus/QUALITY.md:899`; `corpus/lessons/round-36-verifier-spotcheck.md:64,161-163`; `corpus/lessons/round-36.md:100` | Round-36 key v2 loosened the casefold class (24 → 26) after control seats scored; routed; rule "do not loosen a counter in a version bump". | **C1 concept adjacency** — unjournaled counter loosening, the M40-6 class in another lane. No journal exists; the defect was routed and rule-recorded in prose. | kake (QUALITY round-36 rule). |
| mado | `corpus/knowledge/bar-footprint-identity-causes-r85.md:44-47` | "the negative-allocation mutant's literal anchor". | None — mutant anchor, not an expectation gate. Near-miss on the word. | mado. |
| mori | `corpus/evidence/sources-r59/w1-results-r55.json:310` (F5) | "D6 citation is not a literal anchor fragment". | None — citation-label finding. Near-miss on the word. | mori. |
| tameshi | *out of scope* `.ufo/evidence/round-57/c1/measure.py:365,397-398,662,993`; `.ufo/waves/round-57/w1/T57W1ExecC1Counter-receipts/`; round-58 `measure.py:369,401-402` | `old_expect` is a parameter: expected number of BASE-ledger rows (`old_expect=2`), a frozen-set guard. Not an expectation journal, not a per-row expect gate. | **Name collision only.** A grep on `old_expect` alone false-hits; C1's R2 field uses the same spelling. Do not key the C1 gate or its counter on the bare token. | tameshi (round-57/58 C1 counter). |
| kasegi | *out of scope* `.ufo/waves/round-37/…/kasegi-r37-build-results.json:88` (`new_expected_line`) | Receipt field name. | None. | kasegi. |
| tsukuroi | *out of scope* `.ufo/waves/round-39/w1/C1ExecR38Counters/summary.json:249` (`new_expected`) | Receipt field name. | None. | tsukuroi. |

Noise, excluded: `libspa-journal.so` in audio `corpus/live/**` strace logs (systemd journal library path, not a gate). Audio `.ufo`-adjacent `live/` trees were in the broad sweep and are not expectation gates.

## Table B — (b) whitespace or normalizer declarations (Python `re` `\s`, `str.isspace`, UTS #18, White_Space, rendered-text)

| Lane | File (line) | What it is | Overlaps C1 or C2? | Owner / ground |
|---|---|---|---|---|
| kengaku | `corpus/SOURCES.md:68` (S046) | Row: Python `re` docs, "documented Unicode regex whitespace matching"; special sequence backslash-s; mined; used by grader-perturbation-audit and round-26. | **C2 ground-class adjacency.** Same URL as C2's S095 family and same `\s` concept. Different claim (grader fence CRLF). C2 must cite kagi's own row, not reuse S046. | kengaku (S046 row). |
| kengaku | `corpus/knowledge/grader-perturbation-audit.md:1` | Source line: "S046 … special sequence `\s` (Unicode whitespace including CR)". Declares the grader's fence pattern whitespace class. | **C2 adjacency** (declares a whitespace class from `re.html`). Not a rendered-text normalizer. | kengaku (`plans/grader_perturb.py`). |
| kengaku | `corpus/lessons/round-26.md:50`; `corpus/evidence/round26-sources/gate.md:8`; `corpus/evidence/round26-calibration/recovery-start.txt:17-19` | Quote: "This includes `[ \t\n\r\f\v]`". The located quote is an ASCII subset of the class; the lane itself scoped it to CR. | **C2 calibration note.** If C2 quotes `re.html` for the whitespace class, the quote must be located against the 3.15.2 page, not against this kengaku quote. | kengaku. |
| kumitate | `corpus/QUALITY.md:1447-1450` | Rule: a parser's prefix set is "one named class, cites the UCD row (general category or White_Space) each member comes from", with positive and negative twins. | **C2 adjacency (White_Space family).** Precedent that a White_Space-keyed class is enumerated, not inferred from a property. No UTS #18 citation. | kumitate (receipt-prefix parser, round 90). |
| kumitate | `corpus/SOURCES.md:215` (S260) and `:216` (S261) | S260: UAX #44 §2.3.1, U+200B reclassified Zs→Cf. S261: `PropList.txt` line 15, `00A0 ; White_Space # Zs NO-BREAK SPACE`. | **C2 adjacency.** Same UCD source family as the S098 reject reasoning (`White_Space` vs `str.isspace`). S261 is data, not UTS #18. C2 must not cite S261 for the normalizer class. | kumitate. |
| kumitate | `corpus/knowledge/receipt-invisible-prefix-fields.md:1,13-21` | Table of six-member Cf/White_Space class. States: "No single predicate gives the class: 'strip Cf' misses NBSP (Zs, White_Space); 'strip what JavaScript `\s` strips' misses ZWSP, ZWNJ, ZWJ and LRM." | **C2 adjacency.** Documented disagreement between `\s`-style and property-style classes on invisible prefixes. Supports the frozen reject reasoning in kind; not the same class (receipts, not rendered text). | kumitate. |
| kumitate | `corpus/README.md:265-266`; `corpus/lessons/round-90-verifier-spotcheck.md:70-71` | Index row for the knowledge entry; non-author spot-check admitted S260 and S261 (both "agree"). | Adjacency only. | kumitate. |
| kake | `corpus/knowledge/http-date-grammar.md:41-43` | "whitespace normalization that collapses runs would corrupt it" (asctime double space); explicit no-collapse declaration citing S453. | None — HTTP grammar, not Python `re` or rendered text. | kake. |
| kake | `corpus/knowledge/referrer-policy-effective.md:11` | Quote method: "HTML markup removed and line whitespace normalized". | None — quote method for an HTTP spec. | kake. |
| kake | `corpus/knowledge/crawler-identity.md:12-14,87-89`; `corpus/knowledge/baidu-friendly-crawl-guidance.md:63-64`; `corpus/knowledge/baidu-spider-identification.md:163-166` | Term "rendered-text quotes" / "rendered-text reconstruction" / "rendered-text reading": quote-method vocabulary for HTML-derived quotes. | **Term collision only** with "rendered-text". Not a normalizer. kake owns this quote method for its own entries. | kake. |
| kama | `PROVINCE.md:406-410` | `tools/round86-rendered-cells.py` grades self-assessment cells "as a renderer shows them" (HTML comments, fences, `round-N correction` blocks removed). | **C2 adjacency (rendered-text ground).** The nearest sibling "rendered" normalizer. The excerpt names no Python `re`, `isspace`, or UTS #18. **[INFERENCE]** it may apply its own whitespace rules; the tool was not opened. | kama. |
| kama | `corpus/QUALITY.md:274` | "applied no extra case or whitespace normalization". Negative declaration. | None. | kama. |
| chousa | `corpus/lessons/round-27.md:112-113` | "Unicode whitespace differences retain their disclosed grammar limits." Limitation statement, no citation. | None. | chousa. |
| chousa | `corpus/evidence/round29/claims.md:94` | Quote normalized to whitespace-separated words, count 25. | None — word-count tokenizer. | chousa. |
| chousa | `corpus/lessons/round-66-verifier-spotcheck.md:59`; `round-67-verifier-spotcheck.md:66` | Quote re-open "with normalized whitespace". Verifier method. | None. | chousa. |
| kaidoku | `corpus/lessons/round-25.md:61-62` | "explicitly a whitespace-normalized transcription, not raw producer bytes." | None. | kaidoku. |
| kengaku | `PROVINCE.md:683-684` (round-55 chess grader) | "no case or unicode normalization exists" in the scored grader; whitespace-split tokens. Declares absence of normalization; cites no re/isspace. | None. | kengaku. |

Code-only hits excluded by design: `str.isspace()` / `isspace()` appear in the Python and C sources of audio (`corpus/fixtures/measure_audio.py`, `corpus/live/**`) and in other lanes' fixtures. These are code, not declarations.

## Table C — (c) registry rows citing the three frozen URLs

Scope: `corpus/SOURCES.md`, `corpus/knowledge/`, `corpus/lessons/`, `SKILL.md` per lane. Duplicate URLs across lanes are adjacency facts.

| Lane | File (line) | Row or use | URL | Overlaps C1 or C2? | Owner |
|---|---|---|---|---|---|
| kaidoku | `corpus/SOURCES.md:149` | S143 `re.fullmatch` (equality, not `\s`); `SKILL.md:709` cites it. | `re.html` | Adjacency. Whole-string equality ground, not whitespace. | kaidoku |
| kaidoku | `corpus/SOURCES.md:214` | S298 `re` §`\b` word boundary. | `re.html` | Adjacency. | kaidoku |
| kaidoku | `corpus/SOURCES.md:209` | S292 `stdtypes` Numeric Types (bool subtype). Used by `knowledge/2026-11-04-r78-attack-gate.md:1`; lessons round-78 (`:18`, `:22-25`, `:43`) and round-78-verifier-spotcheck (`:122`). | `stdtypes.html` | Adjacency. | kaidoku |
| kaidoku | lessons `round-47-verifier-spotcheck.md:80`, `round-47.md:80`, `round-75.md:24`, `round-80-verifier-spotcheck.md:122`, `round-80.md:33` | Re-uses of S143 / S298. | `re.html` | Adjacency. | kaidoku |
| kake | `corpus/SOURCES.md:131`, `:134` (S123, S126 possessive quantifiers, supersedes S123) | Python `re` syntax (`*+`, `(?>…)`), not whitespace. Used by `lessons/round-42.md:19,22` and `round-42-verifier-spotcheck.md:60`. | `re.html` | Adjacency. | kake |
| kengaku | `corpus/SOURCES.md:68` (S046) | `re` special sequence `\s`. See Table B. | `re.html` | **C2 adjacency** (same class, different claim). | kengaku |
| mori | `corpus/SOURCES.md:406` (S625, rejected, kept as row) | `re` lookbehind `(?<!…)`; `lessons/round-94-verifier-spotcheck.md:104`; `round-94.md:58`. | `re.html` | Adjacency. | mori |
| mori | `corpus/SOURCES.md:405` (S624 `str.startswith`); lessons `round-94-verifier-spotcheck.md:103`, `round-94.md:57` | Prefix test, not `isspace`. | `stdtypes.html` | Adjacency. | mori |
| souji | `corpus/SOURCES.md:96` (S061 `str.lstrip` / `str.removeprefix`); `lessons/round-17-verifier-spotcheck.md:133` | `lstrip` is a character-set strip, not a whitespace class. | `stdtypes.html` | Adjacency. Note: `lstrip` semantics are the same family of confusion C2 must not repeat (`str.isspace` ≠ `str.strip()`'s default set; not verified here). | souji |
| tameshi | `corpus/SOURCES.md:187` (S311 `re.fullmatch`, whole-string identity); `lessons/round-84-verifier-spotcheck.md:103,106`; `round-84.md:11` | Whole-string verdict identity. | `re.html` | Adjacency. Same `fullmatch` page as S143. | tameshi |
| — | — | `unicode.org/reports/tr18/`: **zero hits** in any sibling corpus, SKILL or PROVINCE. | `tr18` | — | — |

Adjacent-URL summary: `re.html` held by kaidoku (S143, S298), kake (S123, S126), kengaku (S046), mori (S625), tameshi (S311). `stdtypes.html` held by kaidoku (S292), mori (S624), souji (S061). `tr18` held by no lane. Consistent with the census W04 duplicate-URL warnings kaidoku reports.

## Owner statements (explicit)

1. **Rendered-text normalizer (C2 ground):** no sibling owns it. Kagi owns `rendered-text-v1.py` (not scanned here). Nearest sibling constructs: kama `round86-rendered-cells` (rendered-cell grading, kama), kake's `rendered-text` quote method (kake, quote vocabulary only).
2. **Expectation-journal ground (C1):** no sibling owns it. Ledger expectation checks belong to kagi `corpus/claim-ledger.sh` (described by kengaku, round-11 connector evidence).
3. **Whitespace class from Python `re` `\s`:** kengaku (S046, grader fence). **White_Space property class:** kumitate (S260, S261, receipt-prefix parser). Neither cites UTS #18 or `str.isspace`.

## Stated limits

- Scope: `corpus/`, `SKILL.md`, `PROVINCE.md` only. `.ufo/` waves were out of scope; they appear above only where a sweep hit them.
- Broad whitespace sweep (terms including `rendered-text`, `normaliz`, `\s`) was paged to 20 of 78 files and was not finished. The precise sweep for `UTS #18|tr18|White_Space|str\.isspace|rendered-text-v1` returned one page with no continuation footer (kumitate only); that result supersedes the broad sweep for documented citations. `isspace` code hits were excluded.
- Expectation sweep (`expectation-migration|expect-journal|expect_journal|expectation journal|expect journal|old_expect|new_expect|migration journal|expect-gate|literal-anchored|literal anchor`) returned one page with no footer.
- URL sweep (c) returned 26 files over two pages; both pages read.
- Kagi's own rows S095, S097, S098 were not read (out of scope for this scan).
- The kama `round86-rendered-cells.py` tool was not opened; its normalizer claim is **[INFERENCE]**.
