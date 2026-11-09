source: S174, S175

# Round 72 — kagi (secrets & vault ops)

Lane: kagi. Round 72, attempt 1 (L1 `KagiR72`). Claim BASE `b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9`
(round-71 spot-check tip). Frozen predeclaration `plans/round-72.md` + counters `plans/round-72-c1.sh`
(sha256 `cc83b638…0b9c`) and `plans/round-72-c2.sh` (sha256 `6ac7c51b…da89`) + runner
`plans/round-72-controls.sh` + 20 executed prefreeze controls, landed together in
`f07aba037006d3edc45acd48e6b3e206e45cae28` before any candidate byte. Candidate landed
`a947a42c52dc5b64cc9be1eef98207712fca7c42`. Wave `w1` (12 seats).

## Claims

- **C1 freshness — `C1_CLOCK_REARM: value=10`** (plan §C1, wording narrowed by Amendment A1).
  BASE (control F0): `value=0 rows_passing=0 gate=0 fresh=0 census=1 live=1`, rc 1. Candidate
  `a947a42c`: `value=10 rows_passing=10 gate=1 fresh=1 census=1 live=1`, rc 0
  (`.ufo/waves/round-72/final/c1-candidate.txt`). The ten derived Vault/OpenBao clocks
  S013–S016, S021–S026 are anchored at 2.2.1 / 2.7.2 (not-fired) through S174/S175, and the
  gate's default receipt is the live observation of 2026-11-09; `fired` 14 → 4.
- **C2 calibration — `C2_SELF_COUNTS: value=0`** (plan §C2). BASE (G0): `value=4` (SC-SKILL-STAMPS,
  SC-SKILL-CLAIMS, PV-STAMPS, PV-CLAIMS), rc 1. Candidate: `value=0 … policy=2 ok=61`, rc 0
  (`.ufo/waves/round-72/final/c2-candidate.txt`). The R29-01/R29-02 POLICY pair is retained.

## Prefreeze controls

Runner `plans/round-72-controls.sh`, receipts `.ufo/waves/round-72/controls/receipts/`
(`summary.txt`: `CONTROLS: 20/20 match`). Expected verdicts were written into the runner's EXPECT
table before the first run (R72Reviewer RV-5: same commit as the plan, so "before" is not
git-provable; all 20 reproduce on a non-author re-run). The forgery classes were enumerated before
the wave (round-71 closure §5 item 3): do-nothing, anchor-bump-only, no ledger, stale receipt pin,
forged digest, verdict without evidence (quote absent), fabricated self-consistent future release
(killed only by LIVE), in-place anchor edit of a BASE row (killed only by SOURCED), weakened
shipped gate (killed only by the BASE-pinned gate run), swapped census, deleted receipt; for C2,
binding dropped, gate replaced by an echo, line deleted, off-by-one, POLICY boundary moved.

## Gate

Sources opened by hand on 2026-11-09 (UTC) with `curl -fsSL --compressed` and the lane's request
profile (`kagi-shokunin-round23/1.0`). Captures `.ufo/waves/round-72/capture/S174.body`,
`S175.body` (feeds) and `<id>.page.body` (ten teaching pages).

| id | decision | source | located quote (≤25 words) | reason |
|---|---|---|---|---|
| S174 | admit, tier A, `mined` | https://github.com/hashicorp/vault/releases.atom — 297455 B, sha256 `3ead3d0f…2e6ffc`, accessed 2026-11-09 (the capture's fetch time is not committed; the committed time-bearing evidence is `observe-r72.json`'s S013 feed observation at 2026-11-09T04:01:39Z, same sha256 — R72Scribe R72-S3) | “<title>v2.2.1</title>” (raw-literal, count 1 at byte offset 726, the offset S089 records; entry updated 2026-10-23T17:34:44Z, tag link /releases/tag/v2.2.1) | newest stable Vault server tag; sdk/ and -rc entries excluded by the gate's parser. Same identity S089 recorded on 2026-11-05 (M72-1): admitted as the re-open that carries the derived-clock binding, `supersedes S089` |
| S175 | admit, tier A, `mined` | https://github.com/openbao/openbao/releases.atom — 543805 B, sha256 `a54d1a53…f2e0e`, accessed 2026-11-09 (committed time-bearing evidence: `observe-r72.json`'s S014 feed observation at 2026-11-09T04:01:40Z, same sha256) | “<title>v2.7.2</title>” (raw-literal, count 1 at byte offset 729; entry updated 2026-10-26T20:24:37Z, tag link /releases/tag/v2.7.2) | newest stable OpenBao server tag; api/ and sdk/ module releases excluded. Same identity S090 recorded on 2026-11-05 (M72-1): admitted as the re-open, `supersedes S090` |
| a third Vault/OpenBao identity row naming v2.2.1 / v2.7.2 as NEW release identities | reject (no row) | the same two feeds | — | S089/S090 already hold both identities since round 37; a row claiming a new identity would be false. Flip: a newer stable tag on either feed |

Re-opened, no new row: the six teaching pages behind the ten re-armed ids (S013/S023 Vault lease,
S022 Vault JWT, S024 Vault KV v2 API, S014/S025 OpenBao JWT, S015 OpenBao Kubernetes JWT provider,
S016/S021/S026 OpenBao tokens), each id's declared fetch quote located with
`corpus/rendered-text-v1.py locate` (count 1, S024 count 3); rows in `corpus/clock-rearm.tsv`.
The OpenBao pages are byte-identical to their round-47 captures; the Vault pages changed bytes
(S022 386833 → 386868 B) with the quotes still located.

Registry changes this round (old → new): S174, S175 new (`mined`, `90d`, used-by this lesson).
At integration their `teaches` cells changed `supersedes S034` → `supersedes S089` and
`supersedes S035` → `supersedes S090` (M72-1). No other row's `status`, `recheck` or `used-by`
changed. Release-clock rows (not registry rows): ten `feed_source_id` S034/S035 → S174/S175,
`anchored_version` 2.2.0/2.7.1 → 2.2.1/2.7.2, `verdict` fired → not-fired; all 32 `observed_at`
2026-11-07 → 2026-11-09 with a round-72 note appended.

Census before → after: fleet `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
exit 0 at round start (26 W04) and at the candidate (28 W04: S174/S175 across scopes; R72Connector
CN-1). Lane `bash corpus/sources-census.sh`: `rows=164` → `rows=166`, CLEAN.

Assimilation: none (no `merge/kagi/` theme taken). considerthese: none mined this round.

## Mistakes

- **M72-1 — two feed rows appended without searching the registry for their URL.**
  class: registry curation, duplicate identity. evidence: R72Connector CN-2 and R72ReviewerSrc
  SR-4 — S089 and S090 (round 37) already carry v2.2.1 / v2.7.2 at the same URLs and already
  supersede S034/S035; the candidate added S174/S175 superseding S034/S035 again.
  captured-by: QM101 (round 70: "Before appending a registry row, the URL is searched in the
  registry"), which the L1 did not run. fix: S174/S175 now supersede S089/S090 (re-opens carrying the binding),
  SKILL.md's release-clock row names the failure mode, QM103 enters the bar. shown able to fail:
  `.ufo/waves/round-72/final/dup-supersede.sh` lists ids superseded by more than one row:
  BASE `DUP_SUPERSEDE: 1` (S007: S019 S032, pre-existing and carried), candidate `a947a42c`
  `DUP_SUPERSEDE: 3` (adds S034: S089 S174 and S035: S090 S175), integration `DUP_SUPERSEDE: 1`
  (receipts `dup-supersede-*.txt`).
- **M72-2 — a frozen pre-move sentence was false against the gate's mechanics (repeat of M71-3).**
  class: frozen wording not checked against the instrument. evidence: plans/round-72.md
  "the lane cannot see Vault 2.2.2 or OpenBao 2.7.3"; R72MutLater LB-1/LB-2 — on BASE a newer
  observation also reads `RECEIPT-MISMATCH`, and the same table edit fires on BASE bytes.
  captured-by: none — no control exercised a later-release observation before the freeze.
  fix: Amendment A1.3 narrows the sentence; the next freeze that asserts what an instrument can or
  cannot see runs that observation as a control first. Not yet shown able to fail (the rule is a
  freeze habit, not a check); recorded honestly as a repeat class.
- **M72-3 — the candidate omitted integration duties its own plan named.** evidence: R72Revenger
  RE-1/RE-2, R72Critic CR-4, R72ReviewerSrc SR-1 — no migration journal for R36-02/R36-03 and four
  sentences still naming the round-54 default receipt at `a947a42c`. captured-by: the plan's
  duty list (read by four seats). fix: journal `.ufo/waves/round-72/expectation-migrations.json`
  and the ledger rows migrated; the four sentences updated. Shown able to fail: `bash
  plans/round-36-c3.sh` at the candidate prints `fired=4` against the ledger's `fired=14`
  (R72Revenger, both revisions measured).
- **M72-4 — the plan under-specified the re-arm for a replica.** evidence: R72ExecReplica 2/3
  (non-F `observed_at` refresh, census identity rules). captured-by: none. fix: Amendment A1.7;
  `.ufo/waves/round-72/controls/tools/build_cand.py` is the L1's own builder, committed as the
  reproducible recipe.
- **M72-5 — the enumerated forgery classes again missed some (repeat of M70-5 / M71-4).**
  class: freeze design. evidence: R72Sentinel SE-2 (the BASE-pinned gate imports the tree's own
  normalizer, so editing `corpus/rendered-text-v1.py` forges LIVE), SE-3 (a symlinked capture
  passes the lexical containment test), SE-6 (an authored quote-only capture passes VERIFIED), each
  executed by the seat to `value=10`; R72MutTester MT-1/2/3/5/6/7 (six legs no control proves).
  captured-by: the round-71 closure §5 item 3 (enumerate forgery classes before the wave) — this
  freeze enumerated twelve C1 classes, but not instrument supply chain, path indirection or
  authored captures. fix: Amendment A1.8/A1.9 narrow the wording; the landed revision is shown
  not to use any of the three (`.ufo/waves/round-72/final/se-ceiling-receipts.txt`); the next
  clock counter pins every module the gate imports, resolves capture paths with `realpath`, and
  carries a control per surviving mutant. Not yet shown able to fail (no repaired counter exists).

## Wave findings — dispositions

| seat | findings | disposition |
|---|---|---|
| R72Reviewer | RV-1, RV-2 falsifies-wording; RV-3…RV-5 neutral | RV-1/RV-2: Amendment A1.5 (LIVE binds the row's own feed URL; the fetch is self-declared); RV-5: lesson §Prefreeze controls; reproduced C1 10 / BASE 0, C2 0 / BASE 4 and 20/20 controls |
| R72ReviewerSrc | SR-1 falsifies-wording; SR-2…SR-5 neutral | SR-1: journal + migration at integration (A1.6, M72-3); SR-4: A1.1, M72-1, S174/S175 now supersede S089/S090; SR-5: the non-author semantic leg — ten of ten `teaching-holds` on 2026-11-09, both feeds byte-identical |
| R72Critic | CR-1…CR-4 falsifies-wording; CR-5…CR-7 neutral | CR-1: A1.2; CR-2: A1.3; CR-3: A1.4; CR-4: A1.6; CR-6: no cheap forgery reaches either target; CR-7: axes honest |
| R72MutTester | MT-1/2/3/5/6/7 falsifies-wording; MT-4, MT-8 neutral (SEAT-STATUS partial: full sweep for one mutant) | A1.8 and M72-5: six legs no control proves, routed to the next counter |
| R72MutLater | LB-1 falsifies-wording; LB-2 neutral | A1.3 and M72-2: a newer release already showed as `RECEIPT-MISMATCH` on BASE; the re-armed row reads `fired` once the table records it, and the same table edit fires on BASE bytes |
| R72Sentinel | SE-2, SE-3 falsifies-number (seat label); SE-6 falsifies-wording; SE-1, SE-4, SE-5 neutral | SE-2/SE-3/SE-6: A1.9 and M72-5 — forgeries the counter accepts; the landed revision uses none of them (`.ufo/waves/round-72/final/se-ceiling-receipts.txt`), so the measured number stands while the wording is narrowed; SE-1: no secret material |
| R72Revenger | RE-1 falsifies-number (seat label); RE-2 falsifies-wording; RE-3 neutral | RE-1: the ledger rows, not the claim's number — R36-02/R36-03 migrated with the journal (A1.6, M72-3); RE-2: four default-receipt sentences updated |
| R72Connector | CN-2 falsifies-wording; CN-1, CN-3, CN-4 neutral | CN-2: A1.1, M72-1, QM103; CN-3: C2 numbers re-set after stamping (185/102) and re-measured on the final revision; CN-4: the 35-round lag between S089/S090 and the clocks is now closed for these ten rows |
| R72ExecReplica | 1 neutral; 2, 3 falsifies-wording (plan gaps) | an independent replica from the plan reaches value=10; gaps: A1.7, M72-4 |
| R72ExecHarm | H1, H2 labelled falsifies-number by the seat but confirming the claimed moves; H3 neutral | no harm: sweep n=28, claims-declared MISMATCH 2, DOC_AUDIT CLEAN identical BASE vs candidate; release-clock `fired` 14 → 4 and self-counts `stale` 4 → 0 are the claimed moves |
| R72Scout | none (reconnaissance) | Vault v2.2.1 and OpenBao v2.7.2 release notes change none of the five taught mechanics (0 hits for aud/bound_audiences/TokenReview/max_versions/revoke/child token) — the second non-author semantic leg; Vault's CHANGELOG.md at v2.2.1 has no 2.2.x section, so the release page is the only changelog surface |
| R72Scribe | R72-S1, R72-S2, R72-S3 (prose defects) | R72-S1: the ten clock-row notes now say "re-open of S089/S090, which superseded S034/S035" (the integration had changed the registry but not the table); R72-S2: SOURCES §Paths bullet annotated; R72-S3: Gate access times bound to the committed receipt; drafts for SKILL/PROVINCE/README already matched the landed text; recommends no capability row (none entered) |

Settlement note: `w1-results.json` carries 12 seats with empty `output` (orchestrator kernel restarted mid-wave); every seat's report file exists in `.ufo/waves/round-72/w1/` and is the evidence used above. No seat died.
