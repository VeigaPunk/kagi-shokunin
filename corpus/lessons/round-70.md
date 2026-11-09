# Round 70 — kagi (secrets & vault ops)

Lane: kagi. Round 70, attempt 1 (L1 `KagiR70`). Claim BASE `7bd34832c94b81d4cf9bf34113c4952a7f6d9b04`
(round-69 spot-check tip). Frozen predeclaration `plans/round-70.md` + counter `plans/round-70-c1.sh`
(sha256 `8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed`) + eight executed
prefreeze controls, landed together in `430cee23eeb81ecf663015851e66332bf16f2a74` before any
candidate byte. Candidate landed `0d225553c22f686df24454040102d0502eda5c42`. Wave `kagi-r70-w1`
(12 seats).

## Claims

- **C1 coverage (capability acquisition) — `C1_PKI_TRIAL: value=5`** (plan §C1). BASE reading
  (control F0 at `7bd34832`): `C1_PKI_TRIAL: value=0 absent=1 pins=1`, rc 1. Candidate reading at
  `0d225553`: `C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1
  sourced=1 real_rc=0 none_rc=2` with every test `real=HOLDS,shim=BROKEN,spec=1,entry=1`, rc 0
  (`.ufo/waves/round-70/final/c1-candidate.txt`).

## Prefreeze controls

Runner `plans/round-70-controls.sh`, receipts `.ufo/waves/round-70/controls/receipts/`, expected
verdicts written into the runner header before the first run. All eight matched:

| control | observed | expected |
|---|---|---|
| F0 BASE `7bd34832` (no work) | `value=0 absent=1`, rc 1 | same |
| P1 positive reference trial | `value=5`, rc 0 | same |
| F1 echo forgery | `value=0`, every test `shim=HOLDS`, rc 1 | same |
| F2 shim-sniffing forgery | `value=0`, every test `spec=0`, rc 1 | same |
| F3 no-teeth trial | `value=0`, every test `shim=HOLDS`, rc 1 | same |
| F4 no entry / no S170 row | `value=0 sourced=0`, every test `entry=0`, rc 1 | same |
| F5 leaking dev server | `value=0 discriminating=5 noleak=0`, rc 1 (six leaked servers reaped) | same |
| F6 prints the dev root token | `value=0 discriminating=5 nosecret=0`, rc 1 | same |

The candidate trial's bytes equal P1's (`sha256 200efcb2…8023d` for both files): the positive
control proved the target reachable before the freeze, and the claim's work is landing the trial,
the entry and the S170 row into the lane, which BASE (F0) lacks.

## Gate

Three sources opened by hand on 2026-11-08 (local date; UTC 2026-11-09) with `curl -fsSL
--compressed` and a browser user agent. Captures `.ufo/waves/round-70/capture/S170.body`, `S171.body` and `S172.body`, fetch
receipts `S170.fetch.txt`, `S171.fetch.txt` and `S172.fetch.txt`, quotes located with `corpus/rendered-text-v1.py locate`.

| id | decision | source | located quote (≤25 words) | reason |
|---|---|---|---|---|
| S170 | admit, tier A, `mined` | https://openbao.org/docs/api/secret/pki/ (620683 B, sha256 `9fa76939…5c1123`) | “if it is internal the private key will not be returned and cannot be retrieved later” (16 words, count=2) | the primary API reference of the product the trial runs; every T1–T5 mechanic is stated in it (§Generate key, §Create/Update role, §Generate certificate and key, §Revoke certificate) |
| S171 | admit, tier A, `mined` | https://openbao.org/docs/secrets/pki/ (27950 B, sha256 `c0ec7fbc…ab695`) | “By keeping TTLs relatively short, revocations are less likely to be needed, keeping CRLs short” (15 words, count=1) | the vendor's own design rationale for short leaf lifetimes; grounds the entry's "why it matters" table |
| S172 | reject, tier A, `rejected` | https://developer.hashicorp.com/vault/api-docs/secret/pki (2518415 B, sha256 `65104f6b…061ddd`) | “Cannot be greater than the role's max_ttl value” (8 words, count=2) | a different product line (HashiCorp Vault) since the 2023 fork; not evidence for OpenBao behaviour, and S170 already states the same parameter. flip: a claim about Vault itself, measured on a Vault binary |

First fetch of `https://openbao.org/api-docs/secret/pki/` returned a 328 B meta-refresh stub to
`/docs/api/secret/pki/`; the stub was discarded and the canonical URL fetched (S170's row records
both). Measured divergence worth keeping: S170 says a requested `ttl` "Cannot be greater than the
role's max_ttl value"; OpenBao 2.7.2 does not refuse such a request — it issues the certificate
clamped to `max_ttl` with a warning (T2). Read as a refusal, the sentence would mislead a caller
that checks only the exit status.

Registry changes this round (old → new): S170 new (`mined`, used-by the new entry), S171 new
(`mined`, used-by the new entry), S172 new (`rejected`, used-by this lesson). No existing row's
`status`, `recheck` or `used-by` changed.

Assimilation: none (no `merge/kagi/` theme taken; considerthese not mined this round — the latest
file `considerthese/2026-10-26.md` is untouched).

Correction to the Gate table above (supersedes, does not rewrite — QM97): S170 is not the first
registry row for its URL. S105 (round 49) registers `https://openbao.org/docs/api/secret/pki/` for
the `generate_lease` role parameter, and its capture `.ufo/waves/round-49/capture/S105.body` is
byte-identical to S170's (sha256 `9fa76939…5c1123`, 620683 B; R70Connector CN-1, R70ScribeLesson
SL-5). S170 is a second row on the same URL with a different scope (the T1–T5 lifecycle
mechanics); the census reads it as one more cross-scope W04 (25 → 26, R70ReviewerSrc SR-2), not an
error. S105 is unchanged. Mined as M70-1.

## Mistakes

- **M70-1 — appended a registry row without searching the registry for its URL.** class: record
  (registry hygiene). evidence: `corpus/SOURCES.md` rows S105 and S170 carry the same URL;
  `.ufo/waves/round-70/w1/R70Connector.md` CN-1; the plan's pre-move sentence "the lane holds no …
  source row … for the OpenBao PKI secrets engine" (`plans/round-70.md` §C1, corrected by
  Amendment A1). captured-by: the census's W04 duplicate-url warning — warning class, exit 0, so
  it cannot stop an append; `none` as a blocking rule. fix: QM101's last sentence — before
  appending, search the registry for the URL and either reuse the row (extend `used-by`) or name the
  first row and why it is not reused. shown able to fail: the search, run on BASE
  (`git show 7bd34832:corpus/SOURCES.md | grep -F 'https://openbao.org/docs/api/secret/pki/'`),
  prints `| S105` — had it been run before the append, the duplicate was visible; on the landed
  tree it prints `| S105 | S170`. For the two other URLs opened this round it prints nothing at
  BASE (they were new).
- **M70-2 — a report's per-class count taken over the wrong population (round-69 routed defect
  §5.1).** class: record. evidence: fleet `.ufo/reports/round-69/kagi.md:65` says "eight
  `falsifies-wording` rows"; `.ufo/waves/round-69/claim-falsification.tsv` column 3 holds 6
  `falsifies-wording` + 2 `falsifies-number` + 5 `neutral` (`awk -F'\t' '$1 !~ /^#/ && NF>0 {print
  $3}' … | sort | uniq -c`); eight is the falsifying total under one class name. captured-by: none
  (QM62 binds verdict-line counts, not ledger per-class counts). fix: QM101 (class in the needle,
  classes sum to the total). shown able to fail:
  `.ufo/waves/round-70/w1/R70ScribeLesson/check-report-counts.py` reads `REPORT_COUNTS: FAIL`
  rc 1 on the filed report and CLEAN rc 0 on the corrected wording (receipt beside it).
  Correction filed in the round-70 report.
- **M70-3 — a warning count read off the tail of a receipt (round-69 routed defect §5.2).** class:
  record. evidence: the round-69 report's "two pre-existing W04 warnings on S156/S164" against
  `.ufo/waves/round-69/final/census-round-end.txt`, which holds 25 W04 lines whose last two are
  S156/S164; this round measured that the W04 lines go to **stdout** (stderr empty, rc 0:
  `.ufo/waves/round-70/base/census-round-start.{stdout,stderr}.txt`, `.rc`). captured-by: none.
  fix: QM101 (count the population, name its span; capture stdout/stderr/rc separately — done for
  both census receipts this round). shown able to fail:
  `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04.py` → `CENSUS_W04: FAIL` rc 1 on the
  filed report, CLEAN on "25 … S019…S164", FAIL on a relabelled control.
- **M70-4 — a round-start warning count would have been carried to the landed revision.** class:
  record (revision binding). evidence: round-start 25 W04, candidate `0d225553` 26 (S170 added);
  every gate stays green. captured-by: none. fix: QM101 (state the count at the revision named; this
  round's report states round-start 25 and round-end 26). shown able to fail:
  `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04-drift.py` → CLEAN against BASE, `FAIL
  (base=25 rev=26 added=['S170'])` against the candidate.
- **M70-5 — the freeze named one forgery ceiling where the counter has three.** class: instrument.
  evidence: `plans/round-70.md` named only the shim-byte-reading ceiling; R70Revenger built
  forgeries A (shim-byte map), C (transport bypass) and D (wrong observable) that each reach
  `value=5` (`.ufo/waves/round-70/w1/R70Revenger.md` RE-1; receipts in `R70Revenger/`); R70MutTester
  MT-1 showed T5's conjunction is a disjunction at the counter. captured-by: the prefreeze control
  set (F1–F6) — it covered echo, sniff-all, no-teeth, unsourced, leak and secret classes but no
  forgery that fakes discrimination per test. fix: claim wording narrowed (plan Amendment A1); a
  successor counter that wants to count execution needs a server-side observable the trial cannot
  forge without issuing (e.g. the counter itself reads `pki/certs` / the CRL from a server it
  starts, or audit-log read-back — R70Revenger §Forgery designs). shown able to fail: forgery A's
  receipt reads `value=5` on the frozen counter — the gap is demonstrated, the fix is routed.

- **M70-6 — the new trial did not reuse the lane's own hardened dev-server launch.** class:
  instrument / custody. evidence: candidate `0d225553:corpus/openbao-pki-trial.sh` passed the dev
  root token on the server argv (`-dev-root-token-id=`), wrote the server log (holding the token)
  into scratch, probed the port with a connect test that accepts a squatting process, and ran the
  server without a parent-death signal (`.ufo/waves/round-70/w1/R70Sentinel.md` SE-1, SE-2, SE-4).
  The lane had already fixed exactly these classes in round 52
  (`corpus/openbao-kv-versions-trial.sh:16-26`, round-51 sentinel findings S-1…S-3).
  captured-by: none at freeze — the C1 NOSECRET leg reads output streams only and the controls
  covered printed secrets and leaks, not argv exposure or a substituted server (SE-1, SE-3).
  fix: integration commit rewrites the launch to the round-52 pattern (token by
  `BAO_DEV_ROOT_TOKEN_ID`/`BAO_TOKEN`, `-dev-no-store-token`, server output to /dev/null,
  kernel-chosen port checked with `ss -Hltnp` to be held by the started pid, `setpriv
  --pdeathsig KILL`, `umask 077`); the frozen counter re-run on the landed revision. shown able to
  fail: `grep -c -- '-dev-root-token-id=' corpus/openbao-pki-trial.sh` reads 1 on `0d225553` and
  0 on the landed tree; R70Sentinel's squatter fixture (`R70Sentinel/fake_bao3.py`) is the
  falsifier for the pid check.

- **M70-7 — the integration harm diff read only FAIL/POLICY/SETUP lines of `claim-ledger.sh
  verify` and missed eight STALE stamp lines.** class: verification scope. evidence: the first
  comparison (`.ufo/waves/round-70/final/claim-ledger-verify-vs-base.txt`, empty diff) filtered
  `^(FAIL|POLICY|SETUP)`; the same landed-tree receipt
  (`.ufo/waves/round-70/final/claim-ledger-verify-landed.txt`) carries eight `STALE` lines
  (QUALITY.md, README.md, source-fetches.tsv, SOURCES.md, LOG.md, PROVINCE.md, SCORECARD.md,
  SKILL.md) that BASE does not; R70ScribeSkill SS-10 named them. captured-by: SS-10 (a late seat
  finding), not the L1's own check. fix: the eight rows re-pinned in `corpus/stamps.tsv` before the
  receipts commit, and the harm diff now compares every verdict class
  (`grep -E '^(FAIL|POLICY|SETUP|STALE|MISSING|NOT-A-FILE)'`, receipt
  `.ufo/waves/round-70/final/stamps-recheck.txt`). shown able to fail: the widened grep over the
  landed-tree receipt prints the eight STALE lines; over the re-pinned tree the stamp recompute
  prints none.

## Wave findings — dispositions

| seat | findings | disposition |
|---|---|---|
| R70Reviewer | RV-1…RV-5 neutral | predicate identical, freeze precedes candidate, value=5/BASE 0 reproduced, controls match, landed trial reads no `bao` bytes |
| R70ReviewerSrc | SR-1 falsifies-wording, SR-2 falsifies-number | SR-1: this lesson now exists (S172 used-by resolves). SR-2: W04 25 → 26 stated in the report (M70-4) |
| R70Critic | CR-1…CR-11 falsifies-wording; CR-12…CR-15 neutral | wording narrowed (Amendment A1); entry title scoped, Measured split into enforced/observed with a receipt, consequence column sourced or `[INFERENCE]` |
| R70MutTester | MT-1 falsifies-wording (6/8 killed; M6/M7 survived) | Amendment A1; entry T5 line names the disjunction |
| R70Revenger | RE-1 falsifies-wording; RE-2 neutral | Amendment A1; entry Does-not-establish; M70-5 |
| R70Connector | CN-1 falsifies-wording; CN-2…CN-5 neutral | CN-1: Amendment A1 + Gate correction + M70-1; CN-3: PROVINCE core line names kake's TLS consumer side; CN-4: README pinned count re-derived by `claim-ledger.sh docs` (50 entries, 47/3) and the entry pinned in `corpus/stamps.tsv`; CN-5: Amendment A1 |
| R70ExecReplica | RX-1…RX-5 neutral | an independent from-source trial also reads `value=5`; the counter does not reject a correct implementation |
| R70Scout | SC-1…SC-10 neutral | frontier leads kept at `.ufo/waves/round-70/w1/R70Scout/frontier.md`; SC-1 added to the entry's Does-not-establish |
| R70ScribeLesson | SL-1…SL-7 neutral | M70-2…M70-4 and QM101 landed from the draft |
| R70ExecGates | GX-1, GX-2, GX-3 falsifies-number; GX-4, GX-5 neutral | GX-1: entry, trial, counter and runner pinned in `corpus/stamps.tsv` (README count 173 → 177); `claim-ledger.sh docs` CLEAN (entries=50 row_linked=47 by_hand=3). GX-2: S170/S171 registry `recheck` `on-release` → `180d` (the same cadence as S115–S117; the entry's own `recheck:` line stays on-release) — `plans/round-36-c3.sh` CLEAN (on_release=32 bound=32). GX-3: R36-01 re-measured at BASE and on the landed tree (report). GX-4: this lesson now exists |
| R70Sentinel | SE-1 falsifies-number; SE-2, SE-3 falsifies-wording; SE-4…SE-6 neutral | SE-1/SE-2/SE-4: trial launch hardened (M70-6). SE-3: NOSECRET reads output streams only — stated as such in the report; the trial's scratch is `umask 077` and removed on exit. SE-5: the f5 receipt masking stays disclosed (`controls/receipts/README.txt`). SE-6: a rare port collision is now retried by the kernel-chosen port + pid check |
| R70ScribeSkill | SS-1…SS-15 neutral (final report rewritten after settlement; SS-10 = eight STALE stamps, M70-7) | SS-1/SS-2/SS-10: stamps + README re-pin (above; SS-10 is M70-7). SS-4: S170/S171 recheck `180d` (as GX-2). SS-3: the SKILL/PROVINCE "164 stamps" figures are inherited staleness (self-counts stale=4 at BASE and after) — carried, not claimed. SS-5/SS-6: plan Amendment A2 + `[C1]` row; `claims-declared.sh` adds no mismatch for round 70. SS-9: placeholder capture paths replaced. SS-13: four SKILL.md decision rows landed, measured facts only |

Registry change after the candidate (logged old → new): S170 `recheck` `on-release` → `180d`;
S171 `recheck` `on-release` → `180d` (GX-2: an `on-release` row must carry a bound clock in
`corpus/release-clocks.tsv`; the lane's other OpenBao docs rows use `180d`). No `status` or
`used-by` cell changed.
