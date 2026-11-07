source: S135 — Harkema et al., "ConText: an algorithm for determining negation, experiencer, and temporal status from clinical reports", J Biomed Inform 2009, PMC2757457 (https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml; §"3.1.2 Trigger Terms, Pseudo-Trigger Terms, and Termination Terms" — the termination-term class (a word that ends a trigger term's scope) that grounds the sentence boundary, and the pseudo-trigger class (terms that contain a trigger term but do not act as one) that grounds the idiom list; capture `.ufo/waves/round-63/capture/S135.body`, sha256 `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`, 189603 B, opened 2026-11-07; `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/S135.body 'Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term.'` ⇒ `count=1`); S137 — "Large Language Models for Equivalent Mutant Detection" (arXiv 2408.01760v1, https://arxiv.org/html/2408.01760v1; §2.2 Equivalent Mutants — the equivalent-mutant definition behind the counter's kill contract: a mutant that behaves identically to the original cannot be killed, so a surviving mutant must be killed or shown equivalent; capture `.ufo/waves/round-63/capture/S137.body`, sha256 `21893b049e06bf0f6e019808a5b47e3cdf2c0a9c56927bb0c7b2644b907d1849`, 286109 B, opened 2026-11-07; `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/S137.body 'A mutant is deemed equivalent if, for all possible test cases, it exhibits the same behavior as the original program under test.'` ⇒ `count=1`); S130 — the same PMC deposit's §"3.1.4 ConText and NegEx" (the negator trigger's scope is a bounded token window, the rule this entry's sentence scope narrows; capture `.ufo/waves/round-62/capture/S130.body`, sha256 `cdbb4173…`, 189603 B, opened 2026-11-07; locate `count=1`)
verified-at: 2026-11-07 — BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc` extracted with `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 0c07aab8 | tar -x -C <scratch>/base`; the sixteen fixture trees built from the frozen tables `plans/round-63-residual.tsv` (F1..F10) and `plans/round-63-benign.tsv` (P1..P6), every anchor asserted to occur exactly once before substitution; every BASE reading below is a `C1_ROUTED:` line this seat's own run printed, receipt `.ufo/waves/round-63/build/R63ScribeEntry/census-base.txt` (17 lines: the unmodified copy, F1..F10, P1..P6) and `census-base.json`; the candidate reading is the round-63 counter's to print and the L1's to land
recheck: 180d — re-extract the claim BASE, rebuild the sixteen fixture trees from the two frozen TSVs, run `bash plans/round-63-c1.sh [revision]` and require `accepted=10 rejected=6 population=10/6 guard=0` at BASE and `accepted=0 rejected=0 guard=1` on the then-current candidate; re-open S130 if the ConText/NegEx comparison is re-quoted, and re-open the round-63 pseudo-negation row if the idiom/contrastive list is re-quoted
Reverify: R21-02

# Negation scope: a structural item reads the sentence, not the token

Scope: the round-63 C1 claim of the kagi lane, measured on `kagi-shokunin` at BASE
`0c07aab8` — the C1 checker's residual polarity classes close on both sides
(`C1_RESIDUAL` accepted 10 → 0 **and** rejected 6 → 0, population 10/6). The entry is
written in two voices and keeps them apart: the *rule* below is grounded in the sourced
negation-scope literature, while every instrument reading is a line a lane command
printed on a named tree. The entry is about record grading, not about OpenBao: it makes
no claim about a vault, a server or a secret.

## The rule

A record item that names a token (`withdrawn`, `three`, `rewritten in place`, a derived
fraction, a stamp) is satisfied only when the sentence **asserts** the token, not when
the token occurs. The unit of the test is the sentence, not a fixed window: the round-62
grammar's five-token, before-only window is the defect this entry replaces. NegEx bounds
a trigger's scope to a window of six tokens (S130) — a floor for *finding* a negator,
never a licence to stop reading at the window's edge: a negation nine tokens away still
negates, and a denial that follows the token negates it just as surely as one that
precedes it. ConText names the other half: *termination terms* — words in a sentence that
signal the end of a trigger's scope (S135) — so the scope ends at a word class, and this
entry reads the sentence boundary (`.` or `;`) as the termination term's job rather than
the window's.

A token is asserted iff all four conditions hold:

1. **No negator before it in the sentence.** No member of the closed negator set sits
   between the nearest `.` or `;` before the token and the token (the scan takes the
   last 24 tokens before the token and never crosses the boundary; a negator further
   back than the cap is not seen).
2. **No denial predicate after it in the sentence.** No member of the closed denial set
   sits between the token and the nearest `.` or `;` after it (also capped at 24 tokens).
   This is the clause that closes the "denial after the token" forgery: `is withdrawn —
   the record denies it` keeps every token the old item read.
3. **No idiom immediately before it.** A pseudo-negation that contains a negator word but
   asserts (`not only`, `not merely`, `not just`, `no fewer than`, `no less than`) is
   removed from the negator scan before condition 1 is evaluated.
4. **No contrastive `but` between a negator and the token.** `not X but Y` asserts Y; a
   negator earlier in the sentence that is followed by `but` before the token does not
   deny the token. This is the contrastive exception, and it is the clause that keeps the
   benign rewrite `it was not appended but rewritten in place` resolved.

**Closed lists** (case-insensitive, word-boundary; declared where the check lives, so a
reader can test them):

| list | members |
|---|---|
| negators (14) | `not`, `no`, `never`, `neither`, `nor`, `without`, `none`, `n't`, `hardly`, `barely`, `scarcely`, `rarely`, `seldom`, `no longer` |
| denial predicates (13) | `denies`, `denied`, `deny`, `refutes`, `refuted`, `refute`, `is false`, `are false`, `not true`, `untrue`, `not the case`, `no such` |
| idioms (5, not negators) | `not only`, `not merely`, `not just`, `no fewer than`, `no less than` |

**The quotation mask.** A double-quoted span that **ends before** the token is masked
before any of the four conditions is evaluated: a quotation of the superseded text is not
the correction's own assertion, and counting it as one lets a forger quote the defect and
then deny it. Round 62 applied the same mask to I7 (the fraction pairing); round 63
extends it to every item. The mask is one-directional: a quotation that *contains* the
token is still the sentence's assertion only if the sentence asserts it, and a span that
opens before the token and closes after it is not a mask.

The four conditions are cheap and structural, which is the point: they can be evaluated
on committed bytes, with no model, no network and no judgement about what the sentence
means.

## The two-sided test

The grammar is graded on two sides, because a hardening that only adds negators moves
recall and breaks precision. **Recall** is ten forgery fixtures: each is the BASE tree
with one anchor replaced by a sentence that keeps every token the item names and denies
the assertion. **Precision** is six benign rewrites: each keeps the assertion and must
stay resolved. Every fixture is applied to a fresh copy of the tree, and the anchor must
occur exactly once (0 or more than one fails closed).

### Recall — F1..F10 (each must read `C1_ROUTED: value>=1` after the hardening)

| id | reviewer id | file | the forgery's shape | BASE reading |
|---|---|---|---|---|
| F1 | N2 | `plans/round-60.md` | `hardly` before the token | `C1_ROUTED: value=0 … i3=1` |
| F2 | N3 | `plans/round-60.md` | denial after the token (`the record denies it`) | `value=0 … i3=1` |
| F3 | N4 | `plans/round-60.md` | negation beyond the five-token window | `value=0 … i3=1` |
| F4 | N6 | `corpus/lessons/round-60.md` | `three` quoted, then the quotation denied | `value=0 … i4=1` |
| F5 | N7 | `corpus/lessons/round-60.md` | negator truncated at a colon (`did not introduce:`) | `value=0 … i4=1` |
| F6 | N14 | `corpus/lessons/round-60.md` | negation beyond the window, with a parenthetical | `value=0 … i4=1` |
| F7 | N9 | `LOG.md` | negation beyond the window on the rewrite claim | `value=0 … i5=1` |
| F8 | N11 | `corpus/lessons/round-60.md` | subjects swapped, each fraction correctly paired | `value=0 … i7=1` |
| F9 | N12 | `corpus/lessons/round-60.md` | a fabricated stamp | `value=0 … i6=1` |
| F10 | N12b | `corpus/lessons/round-60.md` | the genuine stamp plus a fabricated second one | `value=0 … i6=1` |

### Precision — P1..P6 (each must read `C1_ROUTED: value=0` after the hardening)

| id | file | the benign rewrite | BASE reading |
|---|---|---|---|
| P1 | `plans/round-60.md` | `Item 2 of A3 is withdrawn` (subject order) | `value=1 … i3=0` |
| P2 | `plans/round-60.md` | `not merely withdrawn` (idiom) | `value=1 … i3=0` |
| P3 | `corpus/lessons/round-60.md` | `no fewer than three` (idiom) | `value=1 … i4=0` |
| P4 | `corpus/lessons/round-60.md` | the digit `3` for `three` | `value=1 … i4=0` |
| P5 | `LOG.md` | `not appended but rewritten in place` (contrastive) | `value=1 … i5=0` |
| P6 | `LOG.md` | `rewritten in-place` (hyphen) | `value=1 … i5=0` |

### The measured before → after

```
BASE       0c07aab8  accepted=10 rejected=6 population=10/6
CANDIDATE  checker sha256 eb08094c… (2031 lines)
           F1..F10 value=1 (i3=0 F1..F3, i4=0 F4..F6, i5=0 F7, i7=0 F8, i6=0 F9/F10)
           P1..P6 value=0; unmodified value=0
           B3..B7 value=1; round-62 paraphrases value=0
```

The candidate-side lines are the checker's own `C1_ROUTED:` readings on copies of the
extracted BASE tree, recorded by the checker's owner in
`.ufo/waves/round-63/build/R63ExecC1Grammar/grammar.md`; the BASE column is this seat's
own run (`census-base.txt`). The counter-level line
(`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 …`) is the counter's to
print and the L1's to land; the entry does not put a counter verdict in its place.

The unmodified copy reads `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0` rc 1, so
the population is not vacuous: the ten forgeries are accepted because the item cannot see
the denial, not because the checker is broken everywhere. The six benign rewrites read
`value=1` with the item that owns them at 0 (`i3=0` for P1/P2, `i4=0` for P3/P4, `i5=0`
for P5/P6) — the precision side is a real rejection, not a coincidence. All sixteen
readings and the unmodified copy are in `census-base.txt` (17 lines), every line printed
by `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge`
on a copy of the extracted BASE tree.

The hardened checker must move both sides at once: the ten forgeries to `value>=1` and
the six benign rewrites to `value=0`, with the unmodified copy still `value=0` and the
round-62 bypass fixtures (B3..B7) still rejected and the three round-62 paraphrase
fixtures still resolved — those carry their own `P3..P5` ids in
`plans/round-62-paraphrase.tsv` and are not the precision fixtures P3..P5 above. The
guard also carries a checker challenge (Amendment A3, leg f): a copy of the measured
checker with its negator set emptied must fail its own `--selftest` with a named
`C1_CHECK_SELFTEST: FAIL`; a checker with no negator set to empty matches the needle zero
times and reads 0, never a silent pass. The counter's verdict line names each leg:

```
C1_RESIDUAL: accepted=A rejected=R population=10/6 guard=G (real=… selftest=… prior=… para=… stub=… chal=…)
```

A hardening that rejects a paraphrase fails the guard, not the claim — the guard is what
stops a blanket refusal from reading as a gain.

## Bounds

- **A closed-list floor.** The negator, denial and idiom sets are closed lists, and a
  forger who writes a false assertion with none of them still passes. The lists are a
  floor under the class the reviewer found, not a semantics of assertion.
- **A structural read cannot prove the sentence true.** The checker proves the sentence
  *asserts* the correction; it cannot prove the correction is factually right. QM79 and
  QM81 narrow this gap and never close it.
- **The 24-token sentence cap.** A negator 25 tokens away, past the cap, reads as no
  negator. The cap is declared so a reader can construct the sentence that beats it.
- **Six benign rewrites are six rewrites, not a grammar.** Precision is measured on the
  critic's six; a seventh benign shape the grammar rejects is a new routed defect, not a
  claim failure.
- **I6 reads one fleet path.** The superseded-stamp derivation reads
  `.ufo/reports/round-60/kagi.md` §Stale-lane; a moved or unreadable report is SETUP
  (fail closed), never a silent pass.
- **A kill is only a kill if the mutant is not equivalent.** S137 defines the equivalent
  mutant — syntactically different, semantically identical, killable by no test case — so
  a guard can witness that a named mutant *was* refused, never that every surviving
  mutant is non-equivalent. The round's legs are named mutations, not a complete mutation
  set.
- **The sixteen fixtures are a regression set, not a proof of the grammar.** The
  round-63 critic built a fifteen-string lookup-table checker with a constant PASS
  selftest and read `accepted=0 rejected=0 guard=1` against the pre-A3 guard; Amendment
  A3's leg (f) refuses it (a checker with no negator set to empty matches the challenge
  needle zero times and reads 0). The narrower ceiling that remains: a checker that
  memorizes the fixtures **and** carries a negator-dependent selftest still passes — the
  challenge proves the negator set is load-bearing, not that the grammar is implemented.
  The claim is that the named class closes on the named fixtures.
- **The measured open classes (round-63 reviewer, candidate checker `eb08094c…`).** Of
  the reviewer's nineteen new forgery trees the hardened checker accepts seventeen: hedge
  negators outside the set (`ostensibly`, `purportedly`, `cannot`, `un-`), denial verbs
  outside the set (`contradicts`, `rejects`, `disputes`), a negation in the previous
  sentence, a token quoted while the denial sits outside the quotation, a third-subject
  I7 swap, a bogus appended fraction, a negator beyond the 24-token cap, and the
  contrastive abuse `not, but the record says otherwise, withdrawn`. One is a hardening
  regression: `**A3 item 2 is "not" withdrawn**` is rejected at BASE and accepted by the
  hardened checker, because the scare-quoted negator is masked as a quotation. Two
  fabricated-stamp trees are closed. Receipt
  `.ufo/waves/round-63/build/R63Reviewer/findings.md` §1.
- **The ten fixtures are the reviewer's ten.** A further negation or pairing class is a
  new routed defect.

## Falsifiers

Two sentences the grammar cannot get right, each stated so a reader can run it:

1. **A forgery that keeps every token and uses none of the lists.** Replace
   `**A3 item 2 is withdrawn**` with `**A3 item 2 is withdrawn in the abandoned draft
   alone**`. No negator, denial predicate or idiom occurs; the token is asserted; the
   item reads `i3=1` and the checker accepts — while the sentence no longer says the item
   was withdrawn, it says a draft was. Measured: `C1_ROUTED: value=0 … i3=1` rc 1 on the
   BASE checker and `value=0 … i3=1` rc 1 on the round-63 hardened checker (sha256
   `cc92d8a9…`, 97564 B, a working-tree read at 2026-11-07 20:09). This is the closed-list
   floor made concrete, and it is why the entry claims a class closed, not a language
   understood.
2. **A benign rewrite the grammar rejects.** `**Without objection, A3 item 2 is
   withdrawn**` asserts the withdrawal, but `without` is a listed negator inside the
   sentence scope before the token and is not an idiom, so the sentence-scope rule reads
   the token denied and rejects a true sentence. Measured on both sides: the BASE checker
   **accepts** it (`C1_ROUTED: value=0 … i3=1` rc 1 — `without` sits six tokens before
   the token, outside the five-token window, so the old rule misses the negator and the
   sentence passes), while the round-63 hardened checker **rejects** it (`value=1 … i3=0`
   rc 1, same digest as above). The over-read is the price of the sentence scope, and the
   repair is an idiom or adverbial entry in the closed list, never a longer window: a
   window wide enough to catch `without` here would also catch a genuine negation nine
   tokens away, which is the defect F3/F6/F7 name.

Both sentences are the falsifiers the entry's own rule names: the first shows the rule
under-reads, the second shows it over-reads, and neither is repaired by a longer window.
The readings are receipts `.ufo/waves/round-63/build/R63ScribeEntry/falsifiers-base.txt`
(2 lines, the BASE checker) and `falsifiers-hardened.txt` (3 lines: the checker digest and
the two hardened readings).
