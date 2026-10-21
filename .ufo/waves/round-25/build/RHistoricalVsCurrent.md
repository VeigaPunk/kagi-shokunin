# RHistoricalVsCurrent — C1 population-rule attack (round-25 BUILD)
Seat KagiR25.RHistoricalVsCurrent-2 (leaf, read-only lane). BASE `4587c61a348e4528717404a68912c373f3ef4d03` (sandbox `git rev-parse HEAD` = same). Experiments: `/fast/scratch/kagi-r25/RHistoricalVsCurrent-2/` (`c1_population.py`, `c1_truth_sample.tsv`). Tools: system python3 only; no installs.

## Verdict
1. "explicitly round-dated, in LOG/lessons/SCORECARD history" is undecidable as written. Disjunctive reading (round-dated ⇒ historical) lets SKILL.md:46, the plan's own named defect, escape. Conjunctive reading classifies all 203 population tokens as current on BASE.
2. Proposed RF5 (below) is tense-first and segment-scoped. Observed FN 0 (0/19 current sample tokens classed historical; 0/12 historical-class tokens current). Observed FP is high (6/7 historical sample tokens stay current): an authoring cost, not a freshness risk.
3. The larger FN channel is completeness: the plan's outputs check rows only, so an unlisted stale number passes silently.

## Rule RF5 (order matters; scope = the number's segment: text between `|` `;` `—` `–` `(` `)` `,` `→` `. ` in its cell or line)
- A. file in {LOG.md, SCORECARD.md, corpus/lessons/**, .ufo/**} ⇒ HIST.
- B. segment has a present word {is,are,holds,has,have,carries,lists,measures,counts,contains,covers,partitions,runs,requires,proves,verifies,checks,declares,expects,now,currently,today,current,live,latest} ⇒ CUR.
- C. nearest heading has erratum | historical | superseded | `before →` ⇒ HIST. Round-named headings do not count (FN-5).
- D. segment has a past word {was,were,had,held,lost,matched,found,made,reported,reproduced,produced,caught,measured,observed,recorded,seeded,added,landed,superseded,originally,previously,earlier,old,former,formerly,previous}, or until|prior to|before|through|up to|previously|earlier + round N|date ⇒ HIST.
- D′. physical line starts with a dated label (`Round-N:` bullet; `Baseline (round N…|date…):`) and the number follows its colon ⇒ HIST.
- E. otherwise CUR (fail-closed). A bare round or date anchor never makes HIST.
- Population P: 1–6-digit tokens (not in dates, Rnn-nn/Snnn/Lnnn ids, paths, versions, ports, 0-leading modes) in SKILL.md, corpus/README.md, corpus/knowledge/*.md, whose nearest word (1 before / 2 after, same cell or line) is a corpus count noun, minus E1 identifiers (count noun right after case/bound/item/line/column/exit/step/port/status/round…), E2 units, E3 coefficients (`*` `×`), E4 list indices, E5 exit codes. Exact sets: `c1_population.py` (IDENT_PREV, TIME_NEXT, VERDICT_NEXT).
- Gate: every CUR token needs a binding row or an explicit UNBOUND-HOST/OUT entry; a CUR token with neither is red.

## 30-sample (`random.Random(25).sample` over P=203; truth = hand adjudication, `c1_truth_sample.tsv`)
Key = file:line:tok (SKILL = SKILL.md, README = corpus/README.md, K:name = corpus/knowledge/name.md). Columns: truth | N1 naive (round/date anywhere on line) | N2 plan-literal conjunctive | RF5.
| # | key | truth | N1 | N2 | RF5 | basis |
|---|---|---|---|---|---|---|
| S01 | SKILL:35:4 | CUR | CUR | CUR | CUR | verdict spec; host children=182 |
| S02 | SKILL:41:7 | CUR | CUR | CUR | CUR | checklist by_hand=7 |
| S03 | SKILL:41:9 | CUR | CUR | CUR | CUR | checklist runnable=9/16 |
| S04 | SKILL:196:13 | HIST | CUR | CUR | HIST | "round-8 audit found … 2 of 13" |
| S05 | SKILL:243:97 | CUR | HIST | CUR | CUR | "97 scratch cases"; peer live 151 |
| S06 | SKILL:426:9 | CUR | CUR | CUR | CUR | "9 items carry a …" |
| S07 | SKILL:654:9 | HIST | CUR | CUR | CUR | continuation of "Round-14:" bullet |
| S08 | README:33:16 | CUR | CUR | CUR | CUR | "the 16 items" |
| S09 | README:34:12 | CUR | CUR | CUR | CUR | "12 bounds" |
| S10 | README:43:18 | CUR | CUR | CUR | CUR | "18/18 mutations" |
| S11 | README:64:39 | CUR | HIST | CUR | CUR | "39 rows at round 21"; live 61 |
| S12 | README:66:30 | CUR | HIST | CUR | CUR | "30 bounds" |
| S13 | K:adjacency-breadth:152:61 | CUR | CUR | CUR | CUR | fenced verdict, 61 cases |
| S14 | K:adjacency-scope:6:4 | CUR | CUR | CUR | CUR | "4 # breadth" (adjacency.tsv: 4) |
| S15 | K:adjacency-scope:155:61 | CUR | CUR | CUR | CUR | verdict-table selftest count |
| S16 | K:checklist-execution:18:12 | HIST | HIST | CUR | CUR | quoted round-9/10/11 scorecard |
| S17 | K:checklist-execution:20:3 | CUR | CUR | CUR | CUR | "≥3 items name a live gate" |
| S18 | K:claim-ledger:6:9 | HIST | HIST | CUR | CUR | "9 rows at that revision" |
| S19 | K:claim-ledger:206:5 | OUT | CUR | CUR | CUR | "Class 5" (referent = verb "checks") |
| S20 | K:claim-ledger:301:17 | CUR | CUR | CUR | CUR | CLAIM_LEDGER verdict specimen |
| S21 | K:claim-ledger:339:39 | CUR | CUR | CUR | CUR | "PASS (39 cases)" |
| S22 | K:claim-ledger:408:24 | OUT | CUR | CUR | CUR | policy threshold "floor (24)" |
| S23 | K:control-plane-hardening:83:55 | OUT | CUR | CUR | CUR | host DB row count |
| S24 | K:drift-gate:169:20 | CUR | CUR | CUR | CUR | symbols=20 (live 20) |
| S25 | K:handler-on-disk-state:92:238 | OUT | CUR | CUR | CUR | host DB row count |
| S26 | K:surface-census:4:35 | CUR | CUR | CUR | CUR | "35 rows" (live 35) |
| S27 | K:surface-census:32:15 | CUR | CUR | CUR | CUR | "15 files"; sibling "19 symbol pins" (live 20) |
| S28 | K:transcript-hygiene:57:4 | HIST | HIST | CUR | CUR | "Baseline 2026-09-28 has 4 WARN" |
| S29 | K:transcript-hygiene:65:30 | HIST | CUR | CUR | CUR | round-8 baseline; label on line 64 |
| S30 | K:transcript-hygiene:71:888 | HIST | CUR | CUR | CUR | round-9 re-verification record |

Scores (OUT excluded): N1 FN 3/19 (S05, S11, S12), FP 4/7 · N2 FN 0/19, FP 7/7 · RF5 FN 0/19, FP 6/7 (S07, S16, S18, S28, S29, S30). Superseded draw A (P=202, before the fence-aware fix; `c1_truth_sample_drawA_P202.tsv`): N1 FN 4/18, RF5 FN 0/18, FP 4/9.

## Counterexamples (where a naive rule misclassifies)
- FN-1 SKILL.md:46 "(63 stamps + 39 claims + claim ids, round 21)": N1 HIST for both. Live: `wc -l < corpus/stamps.tsv` = 83; `grep -cvE '^(#|[[:space:]]*$)' corpus/claim-ledger.tsv` = 61. A round tag is not a historical marker.
- FN-2 SKILL.md:243 "# 97 scratch cases … — 94 until round 18" and README:63 "`--selftest` 97 cases": N1 HIST for 97 (same-line anchor covers a current count). RF5 splits: 97 CUR, 94 HIST. Live 151 is peer-reported (XSelfCounts-2), UNRUN here.
- FN-3 README:64 "39 rows at round 21", README:65 "63 rows at round 21", README:67 "21 row-linked … 24 pinned at round 21": N1 HIST; RF5 CUR. Live: 61, 83, 25 knowledge entries (`ls corpus/knowledge/*.md | wc -l`). "24 pinned" is not in P (participle, not a count noun): referent escape.
- FN-4 corpus/knowledge/adjacency-breadth.md:158 "The 18 falsifiers are the round-16 nine plus nine …": N1 HIST (round-16 on the line); truth CUR; RF5 CUR (`are`).
- FN-5 SKILL.md:749–750 under "## Gate registry — round-23/24 contracts" (line 744): "(R24-02, 14 cases)", "(R24-01, 22 cases)" are live rows; a round-named-heading rule marks them HIST.
- FN-6 corpus/knowledge/adjacency-scope.md:58 "The 4 group rows" under "The partition (measured, not asserted)": a `measured`-heading rule marks it HIST (found in draft v3, removed; live adjacency.tsv has 4 group rows).
- FN-7 SKILL.md:36 "`--selftest` proves 16 cases" (peer case): RF5 CUR (`proves`). SKILL.md:689–690: "old sample case counts are history, not the current executed selftest tally". Its binding R11-03 is tagged `[substrate]`: UNBOUND, not HIST (replied to XSelfCounts-2).
- FP-1 transcript-hygiene.md:70–71 "Baseline (round 9, … re-verified 2026-09-28): HITS=2 … 888 cells": label on line 70, numbers on 71 ⇒ CUR (fail-closed). FP-2 checklist-execution.md:18: quoted past claim with `are` ⇒ CUR.

## False-negative risk (RF5)
- A stale current number escapes only through HIST: (i) a past word in the same segment as a current count: none on BASE (7/7 D-past historical or host); (ii) heading or label scope over a current line: C-heading 4/4 and D′ 1/1 historical; (iii) referent escape (README:67): a population FN, not a classifier FN; (iv) multi-line labels cause FP, not FN.
- Measured: 0/12 HIST-class tokens current (11 historical, 1 host measure SKILL.md:147); 0/19 current sample tokens escaped. Exact one-sided 95% upper bounds: 22% (n=12), 15% (n=19). BASE does not establish a small FN rate; FN control is structural (fail-closed default plus completeness), not measured. N1 escapes 3/19 (16%).

## Consequences for the plan (C1)
- Disjunctive reading is refuted by FN-1. Conjunctive reading makes 203/203 current and forces bindings for historical numbers (FP 7/7).
- "after stale=0" fails on BASE unless fixed in-round: SKILL.md:46 (63, 39), SKILL.md:243 (97), README.md:63 (97), README.md:64 (39), README.md:65 (63), surface-census.md:32 (19 vs 20). Five verified here, two peer-reported (151).
- Add a completeness check (every CUR token has a row or an OUT/UNBOUND entry); otherwise unlisted stale numbers pass.
- Operability: 191 CUR tokens (110 of 118 that directly precede an artifact noun). One row per token is infeasible: bind per cell or line, or narrow P (not measured). Host-dependent CUR (SKILL.md:35; SKILL.md:36 via R11-03) needs UNBOUND-HOST, never HIST.

## Commands and outputs
- `python3 c1_population.py <sandbox>/lane 25 30` → exit 0: `DOCS=27 numeric_tokens=1972 population=203 excluded=710 [E1 418, E2 64, E3 23, E4 144, E5 61]`; `rule N1: CUR=169 HIST=34`; `rule N2: CUR=203 HIST=0`; `rule RF: CUR=191 HIST=12`; `SCORE N1: truthCUR=19 truthHIST=7 FN=3 FP=4`; `SCORE N2: FN=0 FP=7`; `SCORE RF: FN=0 FP=6`.
- Live: stamps.tsv 83 lines (no header); claim-ledger.tsv 61; surface-census.tsv 35; state-shape.tsv 22; checklist.tsv 16; drift-symbols.tsv 20; drift-baseline.tsv 15; adjacency.tsv 4 group rows; knowledge entries 25.
- sha256 (16): c1_population.py 6fc185ea95bd53df; c1_candidates.tsv db6c4fc28a00c80a; c1_run.out 4f77d9ce48482dcf; c1_truth_sample.tsv f084159f78e2778f.
- UNRUN: `claim-ledger.sh --selftest` (151 peer-reported); `verify`/`cells` on the real tree (not run, by contract). Lane files untouched except this report.
