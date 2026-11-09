# Round 71 — kagi (secrets & vault ops)

Lane: kagi. Round 71, attempt 1 (L1 `KagiR71`). Claim BASE `e0e9603a924d73d9621924cc507b50474d11dae7`
(round-70 spot-check tip). Frozen predeclaration `plans/round-71.md` + counter `plans/round-71-c1.sh`
(sha256 `4d77f19c47c159768f648338f3fe59472301618e2ef1f679ef1b9f504ab8117b`) + runner
`plans/round-71-controls.sh` + nine executed prefreeze controls, landed together in
`1199295573a4eb1791e965178c8643213312943d` before any candidate byte. Candidate landed
`39e76bc700cf05e7772711f703bdbc3c6e7ac469`. Wave `w1` (12 seats).

## Claims

- **C1 depth — `C1_PKI_ISSUER_TRIAL: value=4`** (plan §C1, wording narrowed by Amendment A1).
  BASE reading (control F0 at `e0e9603a`): `C1_PKI_ISSUER_TRIAL: value=0 absent=1 pins=1`, rc 1.
  Candidate reading at `39e76bc7`: `value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 noleak=1
  sourced=1 real_rc=0 none_rc=2`, every test `real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1`, rc 0
  (`.ufo/waves/round-71/final/c1-candidate.txt`).

## Prefreeze controls

Runner `plans/round-71-controls.sh`, receipts `.ufo/waves/round-71/controls/receipts/`, expected
verdicts written into the runner header before the first run. All nine matched (table in
`plans/round-71.md`). The two that carry this round's new teeth: F2 (a shim-byte-map trial that
runs nothing) passes DISCRIMINATE on all four tests and reads `value=0` only because every
ARTIFACT check fails; F7 (T7 evidence CRLs swapped, verdict lines unchanged) reads `value=3`. The
round-70 counter had neither leg: its F2 analogue died on specificity only because it sniffed
"is a script", and a swapped observable was R70Revenger's forgery D. The candidate trial's bytes
equal P1's (`cmp` before the candidate commit).

## Gate

Sources opened by hand on 2026-11-08 (local date; UTC 2026-11-09) with `curl -fsSL --compressed`
and a browser user agent. Captures `.ufo/waves/round-71/capture/S173.body`, `S170.body`, fetch
receipts `S173.fetch.txt`, `S170.fetch.txt` (their `size=` field is the compressed transfer size,
not the decoded byte count — R71Connector CN-5, R71ReviewerSrc SR-3), quotes located with
`corpus/rendered-text-v1.py locate`.

| id | decision | source | located quote (≤25 words) | reason |
|---|---|---|---|---|
| S173 | admit, tier A, `mined` | https://openbao.org/docs/secrets/pki/considerations/ (96207 B, sha256 `42ef7582…5047a`, byte-identical to the round-70 scout capture) | “For backwards compatibility, the default issuer is used to service PKI endpoints without an explicit issuer (either via path selection or role-based selection).” (23 words, count=1) | the vendor's own operating guidance for multi-issuer mounts; it is the only source that states which issuer serves a request and where a departed issuer's revocations land (T7's ground). Registry searched for the URL before the append (M70-1 rule): `git show e0e9603a:corpus/SOURCES.md \| grep -cF 'pki/considerations'` → 0 |
| S170 | re-opened, no new row | https://openbao.org/docs/api/secret/pki/ (620683 B, sha256 `9fa76939…5c1123`, byte-identical to its round-70 capture) | “It does not update only the provided fields.” (8 words, count=2) | already `mined` (round 70); T6/T8/T9 cite its §Update issuer, §Set revocation configuration, §OCSP request and §Revoke certificate with private key |
| rotation-primitives (https://openbao.org/docs/secrets/pki/rotation-primitives/) | not admitted this round, no row (R71ReviewerSrc: defer to a rotation entry) | opened by R71ReviewerSrc (seat capture in `.ufo/waves/round-71/w1/R71ReviewerSrc/`) | see the seat report | scope: rotation primitives (cross-signing, reissuance) are not any T6–T9 mechanic; flip: a round that measures issuer rotation (R71Scout M1/M3) re-opens it |

Registry changes this round (old → new): S173 new (`mined`, used-by the new entry). S170 `used-by`
`corpus/knowledge/openbao-pki-certificate-lifecycle.md` → `corpus/knowledge/openbao-pki-certificate-lifecycle.md, corpus/knowledge/openbao-pki-issuer-revocation-channels.md`
(candidate). S170 anchor cell: appended "; round 71 adds §Update issuer (`leaf_not_after_behavior`,
the POST-overwrite note), §Set revocation configuration (`ocsp_disable`), §OCSP request, §Revoke
certificate with private key" after "§Revoke certificate" (integration; M71-2). No `status` or
`recheck` changed.

Assimilation: none (no `merge/kagi/` theme taken). considerthese: `considerthese/2026-10-26.md`
proposal 3 ("Mark known-defective instrument output", lines 60–62) mined by R71ScribeLesson and
refused as written: its premise no longer reproduces (the `release-clock.py:789` regex matches
`Python 3.15.1.`, the same finding round 48 recorded at `corpus/lessons/round-48.md:80`) and its
quoting rule is already QM55; flip: a reproduced D1 regex failure re-opens it
(`.ufo/waves/round-71/w1/R71ScribeLesson/considerthese.md`).

## Mistakes

- **M71-1 — a trial wrote one field of an existing issuer with a POST and reset the others.**
  class: domain mechanics unread before the write. evidence: the L1's first reference-trial run read
  `TRIAL T6 BROKEN long-leaf-refused`; the probe receipt
  `.ufo/waves/round-71/final/l1-probe-observations.txt` shows `bao write pki/issuer/r71short
  leaf_not_after_behavior=truncate` leave `issuer_name: ''` and the name lookup fail
  (`unable to find PKI issuer for reference: r71short`); S170 states it: "It does not update only
  the provided fields." and "Note that bao write uses POST" (count 2 each in the round-70 capture).
  captured-by: none — no QUALITY row names the write semantics of a mutating call
  (R71ScribeLesson M71-1). fix: the landed trial re-sends `issuer_name` (`corpus/openbao-pki-issuer-trial.sh`
  T6 block) and QM102 enters the bar. shown able to fail:
  `.ufo/waves/round-71/w1/R71ScribeLesson/sweep.sh` reads CLEAN rc 0 on the landed trial and FLAG
  rc 1 on the pre-fix line (receipts `R71ScribeLesson/receipts.txt`); its ceiling (one field name)
  is stated there.
- **M71-2 — the S170 row's anchor cell did not name four sections the new entry cites.** class:
  record (registry anchor coverage, QA1). evidence: `corpus/SOURCES.md` S170 at the candidate named
  §Generate key … §Revoke certificate only; the entry's `source:` line cites §Update issuer, §Set
  revocation configuration, §OCSP request, §Revoke certificate with private key (R71ScribeLesson
  M71-2, R71Connector CN-3). captured-by: none (no gate compares anchors with citing entries).
  fix: the anchor cell extended at integration (Gate, above). shown able to fail:
  `.ufo/waves/round-71/w1/R71ScribeLesson/anchors.sh corpus/knowledge/openbao-pki-issuer-revocation-channels.md corpus/SOURCES.md S170`
  reads `FLAG missing=4` rc 1 on the candidate tree and `CLEAN row=S170` on the integration tree.
- **M71-3 — two frozen plan sentences were false against the BASE tree.** class: record
  (pre-move claims about BASE). evidence: "None is executed, entered or counted at BASE"
  (`plans/round-71.md` §C1) — R70Scout had measured all four observables, receipts in BASE
  (`.ufo/waves/round-70/w1/R70Scout/receipts/probe-frontier-final.txt`); "S170 re-opened … without a
  row change" — the candidate extended S170's `used-by` (R71Connector CN-1/CN-2). captured-by: the
  M70-1 rule searched the registry for the URL, not the BASE tree for the mechanics. fix: plan
  Amendment A1 corrects both (supersedes, QM97); before a freeze states "not at BASE", search the BASE
  tree for the mechanic's own identifiers. shown able to fail:
  `git grep -l -e leaf_not_after_behavior -e revoke-with-key e0e9603a -- .ufo/waves/round-70` lists
  14 files at BASE, among them `R70Scout/probe-frontier-final.sh`, `probe-frontier-focused.sh` and
  `receipts/probe-frontier-final.txt` (non-empty — the sentence would have been caught);
  `git grep -l openbao-pki-issuer-trial e0e9603a` prints nothing (the narrowed sentence holds).
- **M71-4 — the freeze named two forgery classes of three, again.** class: instrument (repeat of
  M70-5). evidence: `plans/round-71.md` named wrapper reads + local minting (forgery A, RE-2);
  R71Revenger's forgery C reads config read-backs and call statuses for verdicts while its
  artifacts are real and reaches `value=4` (`.ufo/waves/round-71/w1/R71Revenger/counter-c.txt`,
  RE-1). captured-by: the prefreeze control set — F7 swapped an artifact under true verdicts, but no
  control kept the artifacts true and the verdicts unbound. fix: wording narrowed (Amendment A1);
  a successor counter binds each verdict line to its artifact (the trial prints the serial or
  NotAfter its verdict rests on and the counter compares it with the artifact), with a forgery-C
  fixture as its red case before freezing. shown able to fail: `counter-c.txt` reads `value=4` on
  the frozen counter — the gap is demonstrated, the fix is routed.
- **M71-5 — a seat killed sibling seats' dev servers with a pattern-based cleanup.** class: process
  hygiene. evidence: `.ufo/waves/round-71/w1/R71Sentinel.md` SE-11 (three `bao server -dev`
  processes of other seats SIGKILLed). captured-by: the wave context said "every `bao server -dev`
  you start must be killed" but did not forbid killing others' processes. fix: the next kagi wave
  context forbids pattern kills (`pkill -f`, `killall`, kill by `pgrep` match) and allows only PIDs
  the seat itself started. shown able to fail: `grep -c 'pkill' .ufo/waves/round-71/w1-dispatch.json`
  reads 0 — the round-71 context carries no such prohibition.

## Wave findings — dispositions

| seat | findings | disposition |
|---|---|---|
| R71Reviewer | RV-1…RV-5 neutral | predicate identical, freeze precedes candidate, value=4/BASE 0 and F2/F7 reproduced, landed trial reads no wrapper bytes and mints nothing |
| R71ReviewerSrc | SR-1, SR-2 falsifies-wording; SR-3 neutral | SR-1: trial, counter, runner pinned in `corpus/stamps.tsv`. SR-2: OCSP consequence marked `[INFERENCE]`. SR-3: fetch-receipt `size=` labelled here |
| R71Critic | CR-1…CR-3 neutral | CR-1: T6 table cell narrowed to what the counter checks; CR-2/CR-3 in Amendment A1 |
| R71Revenger | RE-1 falsifies-wording; RE-2…RE-4 neutral | Amendment A1; entry Does-not-establish; M71-4 |
| R71Sentinel | SE-7 falsifies-wording; SE-1…SE-6, SE-8…SE-11 neutral | SE-7: Amendment A1 + entry; SE-1: entry Does-not-establish; SE-11: M71-5 |
| R71Connector | CN-1, CN-2 falsifies-wording; CN-3…CN-6 neutral | CN-1/CN-2: Amendment A1 + M71-3; CN-3: M71-2; CN-4: PROVINCE core line; CN-5: Gate note; CN-6: stamps |
| R71MutTester | MT-1 falsifies-wording; MT-2…MT-6 neutral (SEAT-STATUS partial: mutant M10 not built) | MT-1: plan Amendment A2, entry T9 line and SKILL row say the serial refusal is not counted; MT-3/MT-4: the artifact and NOSECRET/SOURCED/specificity legs are killed by forged-evidence fixtures and F6 (receipts `R71MutTester/matrix/`) |
| R71ExecGates | none (gate table; SEAT-STATUS complete) | candidate vs BASE: claim-ledger verdict classes unchanged except `stamped=`; DOC_AUDIT, RELEASE_CLOCK unchanged-clean; sweep n=28 identical; self-counts stale 4 → 7 from three README counts the candidate moved — repaired at integration (README :65/:67) and re-measured in the report; round-70 counter still `value=5` |
| R71ExecReplica | none | an independent trial written from the plan and entry reads `value=4` on the frozen counter |
| R71Scout | none | frontier leads M1 (issuer left the mount → default CRL), M2 (`permit`), M3 (issuer revocation) kept at `.ufo/waves/round-71/w1/R71Scout.md` |
| R71ScribeSkill | none | SKILL rows, PROVINCE line, README row, SCORECARD rows landed from the drafts |
| R71ScribeLesson | none | M71-1, M71-2, QM102 and the considerthese verdict landed from the drafts |

Round 72 correction (appended; routed by the round-71 closure §5 item 2): the §Gate reason for
rotation-primitives ("not any T6–T9 mechanic") is too strong. The page also states that
`leaf_not_after_behavior` is maintained per issuer at `/pki/issuer/:issuer_ref` (the T6 mechanic).
S170 §Update issuer already covers that mechanic, so the deferral stands; only the reason is corrected.
