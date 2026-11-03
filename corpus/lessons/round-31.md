source: S061, S062, S063, S064, S065, S066, S067, S068, S069, S070, S071
verified-at: 2026-11-03 — the eleven rows re-opened in-round with the declared fetch profile (`curl -fsSL --max-time 30`); receipts `.ufo/waves/round-31/src-open/` and the capture rows in `corpus/source-fetches.tsv` (lines 104–114); the C1 evidence is the committed BASE controls (`.ufo/waves/round-31/controls/`) and the landing receipts (`.ufo/waves/round-31/final/receipts/`). No vault, account, handler or CDP contact; `op --version` read only; nothing installed or provisioned.
recheck: 180d — re-run `bash corpus/claim-ledger.sh cells` (C1), `bash corpus/sources-census.sh` (C2, expect the CLEAN line with rows=71 entries_sourced=10 captures=71) and `python3 corpus/self-counts.py` (expect the POLICY state named below) after any registry, entry, scorecard-heading or ledger-row change

# Round 31 — scorecard cell-audit re-arm; OIDC workload-federation adoption

Frozen BASE `655e620651808ac04bb59bfa35b81227f62a031b` (round-30 close + verifier
spot-checks). Plan committed alone in `4767b04` (QM29); plan correction 1 in `2d46e57`
(migration set widened 3 → 10; R11-08 predicate exception); plan correction 2 in
`91f7752` (predicate tightened to the POLICY-summary shape with cells ≥ 222, landing
procedure frozen, C2 fallbacks named) — both before any work commit, from the wave's
pre-data attack seats. Host: Linux (python3 3.14.8, sqlite3 present; the-janitor
substrate absent — fail-closed outputs are correct; `op` 2.41.1 observed read-only).

## Round shape

One v1 wave `kagi-r31-build`, 15 seats under `ufo-wave-policy.json` (band 8–16):
1 scout, 4 executors (incl. the re-roled labrat probe — the validator refuses `labrat`
as a swarm role, so the bounded empirical probe rode an executor seat; recorded, no
bypass), 4 scribes, 1 connector, 1 critic, 3 reviewers, 1 mutation-tester. Attack
share 5/15 = 33 % (≥ 25 %); connectors 1 (≤ 2). The canonical planner seat is held by
the L1; the bounded planning data-walk rode the L1's BASE probes and the
CensusBase/CellsRed seats. Routing through `task.agentModelOverrides` (run-15 map);
no `model` passed. 13 seats delivered; **OidcEntry2 and RowsDraft stalled** (no
wave-dir output ~2 h after dispatch; their scratch dirs show fetch/experiment work
stopping at 17:38/17:08) — the L1 integrated C2 from the other seats' verified
artifacts; their status is recorded from results.json at WAVE-DONE and this lesson
names the stall as M31-4.

## Gate — sources opened and decided this round

Theme: OIDC workload-federation trust policy (the lane's frontier lead since round 21),
adopted from `/home/vgpnk/Projects/shokuknow/merge/kagi/` (§10; read-only source). Two
entries, eleven registry rows (S061–S071), eleven capture rows. Every staged source was
re-opened in-round by this lane (fetch profile `curl -fsSL --max-time 30`; the seats'
receipts cross-checked: OidcEntry1's independent re-fetch digests match SrcOpenA/B's
byte-for-byte; AttackOidc re-fetched all eleven and located every needle). Per-entry
verdicts from the AttackOidc seat, applied by the L1 at integration:

| Staged → adopted | Decision and basis | URL, access date, located quote |
|---|---|---|
| S052 → S061 AWS IAM create-oidc | ADMIT, tier A docs, 180d | https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html ; 2026-11-03; in-round raw `141dd4819db34dc2` (campaign `c69aea104f5fb072` non-reproducing, recorded); quote "The aud claim must match the Audience value" located once |
| S053 → S062 AWS IAM condition keys | ADMIT, tier A docs, 180d | https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html ; 2026-11-03; in-round raw `fb5b2e35ec37c18b`; quote "the OIDC condition context key can only be used in a role trust policy for the initial AssumeRoleWithWebIdentity authentication" located |
| S054 → S063 AWS STS AssumeRoleWithWebIdentity | **REFUSE AS STAGED → ADMIT AFTER FLIP (F-A, load-bearing)** | https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html ; 2026-11-03; in-round raw `a08888ce4d86adf2`; the staged anchor "§Request Parameters, entry `Audience`" does not exist on the re-opened page (the L1 re-verified: request parameters are DurationSeconds, MinimumSessionTokenSize, ProviderId, RoleArn, RoleSessionName, WebIdentityToken; `Audience` occurs twice, both in the response section) — the row re-derived from the response-side echo + the no-ProviderId-for-OIDC rule |
| S055 → S064 GCP WIF best practices | ADMIT, tier A docs, 180d | https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation ; 2026-11-03; in-round raw `116398b3807c1016` (volatile; rendered `92c7db2c25ab9766`); the three best-practice bullets located (page-wide — they appear twice on the page) |
| S056 → S065 GCP WIF ja | ADMIT, tier A docs (ja terminology scope, self-bounded flip-to-C), 180d | https://docs.cloud.google.com/iam/docs/workload-identity-federation?hl=ja ; 2026-11-03; in-round raw `0179cc57506a632e` (volatile; rendered `7a5a1c571fc5cef4`); §属性条件 + the `google.subject=assertion.sub` sample located |
| S057 → S066 Alibaba RAM trusted-IdP | ADMIT, tier A docs, 180d | https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp ; 2026-11-03; in-round raw `0e2d9afdfda461bd` (volatile; rendered `8b21f8346902b086`); the 限制条件表 located under §创建OIDC身份提供商的RAM角色 → 操作步骤 (the staged 信任策略 heading does not exist — corrected); the 是否必选 flags located (oidc:iss 是, oidc:aud 是, oidc:sub 否 ≤10) |
| S064 → S067 OpenID Connect Core 1.0 | ADMIT, tier A spec, 730d | https://openid.net/specs/openid-connect-core-1_0.html ; 2026-11-03; campaign fetch sha256 `4d016752a645e8a3` reproduces in-round; the aud entry located verbatim — at §3.1.3.6 (the staged line-locator 923-933 was wrong at staging, corrected) |
| S065 → S068 RFC 9700 | ADMIT, tier A spec, 730d | https://www.rfc-editor.org/rfc/rfc9700.txt ; 2026-11-03; campaign fetch sha256 `9919d061d40a9788` reproduces in-round; §4.10.2 quote located verbatim |
| S092 → S069 1password.dev brokered-access | ADMIT, tier A docs, 180d | https://www.1password.dev/brokered-access ; 2026-11-03; in-round raw `6179e9c140851529` (volatile; rendered `232239dd8ae8e792`); "All configured claims must match to verify the workload’s identity" located (curly apostrophe — the locating form); the URL is already held by S007/S019/S032 (different scopes) — the row's scope cell records the added aspect (configuration mechanics only) |
| S093 → S070 1password.dev custom-workflow | ADMIT, tier A docs, 180d | https://www.1password.dev/brokered-access/custom-workflow ; 2026-11-03; in-round raw `a34902cc251b9d9c` (volatile; rendered `20fbc423c4faea78`); the runtime triple sentence located; the page title carries "(public beta)" — the feature-level status (the URL is already held by S018, trailing-slash variant — different scope: runtime mechanics vs feature status) |
| S095 → S071 1password.com/jp credential-broker | ADMIT, tier A docs (ja rendering scope, self-bounded flip-to-C), 180d | https://1password.com/jp/product/credential-broker ; 2026-11-03; in-round raw `a5d4a10132d672c4` (UA-sensitive: raw bytes differ without the profile UA; rendered stable `0c2d13e54cc059d0`); the JP lead sentence located; the page carries NO release status (0 status hits) — no status claim rests on it |

**Per-entry verdicts: both entries ADMIT-AFTER-FLIP** — no outright REFUSE; the flips
are the round's rejected readings, named:

- **F-A (entry 1, load-bearing):** the staged AWS STS row asserted a request parameter
  `Audience` that the re-opened page does not carry (the quote is the response
  element's description) and a subject cell ("caller asserts `ProviderId`") the page
  contradicts twice ("Do not specify this value for an OpenID Connect identity
  provider"). Refused as staged; the row and the entry's synthesis re-derived from the
  in-round evidence (audience enforcement lives in the role trust policy's
  `provider:aud` condition).
- **F-G (entry 2, load-bearing):** the staged "the product page describes Credential
  Broker as in public preview" bullet is the round-22-rejected uniform-preview reading
  (QA10; the cited JP page carries no status at all; the runtime page's own title says
  "(public beta)"). Refused as staged; the bullet now states the per-feature split and
  cites the lane's status rows S017/S018/S020 as existing ground.
- **F-B:** "AWS, GCP and Alibaba all ship changes without a version stamp" refuted for
  GCP (both GCP pages carry stamps) — the bound now restricts the no-stamp claim to AWS
  and states the GCP/Alibaba stamp facts per page.
- **F-C:** S067's staged line-locator (923-933) was wrong at staging (the pin
  reproduces; the aud entry is at §3.1.3.6) — corrected.
- **F-D:** "Four claims do that work" mislabeled the policy's output as a fourth claim —
  re-worded.
- **F-E/F-N:** neither staged entry named a falsifier (QA4) — one falsifier sentence
  added per entry.
- **F-H:** `OP_INTEGRATION_KEY` attributed to the runtime page's SDK sample (S070), not
  to the setup tab (F-QA9).
- **F-I:** the staged 44-word claims quote exceeded the ≤25-word capture bar — the
  capture row carries the 10-word locating fragment; the rest is paraphrase.
- **F-J:** capture quotes recorded in the locating (curly-apostrophe) form.
- **F-K:** the staged ground line cited "Round-2 ledger item 4" — a foreign artifact
  (the merge package's internal round numbering; no such lane record exists) —
  re-grounded to the lane's own records (SOURCES §Leads; S018's round-22 opening).
- **F-L:** "Those entries already record…" attributed to
  `onepassword-machine-credentials.md` only (the CDP-bridge entry carries no
  identity/policy content — verified by grep).
- **F-M:** "a third factor that the cloud-provider dialects do not have" bound to its
  sweep (0 workload-ID-credential hits across the six provider pages, verified by the
  attack seat).
- **F-O:** "every workflow fail closed" scoped to "every workflow requesting under that
  integration".
- **F-P:** S070's Step-2 anchor corrected to the page's period form.

**Existing registry cells, old → new: none.** No pre-existing row's
status/recheck/used-by changed (the entries cite only the new rows; the bounds
sections' S012/S022/S047/S050/S017/S018/S020 mentions are prose, and the house
precedent is that prose mentions do not enter used-by — verified by OidcEntry1 F5b's
scratch reproduction of the SC_USEDBY_NOCITE failure mode). Id collision check:
`comm -12` of the lane's 60 ids against the staged 172 = **9** (S052–S060 — the staged
package's ids for OTHER documents; the adopted eleven are renumbered S061–S071 by
document, verified by URL; artifacts `build/assimilation/{reg-ids,staged-ids,collisions}`).
Campaign anchors kept, not rewritten (the round-30 pattern): the anchor cells keep the
campaign-era digests with their fetch dates; nine of eleven do not reproduce against
today's bytes (recorded in the cells); the in-round captures (2026-11-03) in
`corpus/source-fetches.tsv` lines 104–114 are the evidence the census checks.

## Migrations (C1's QM14 record)

The landing re-pins the full stamp set under `LC_ALL=C` (ambient UTF-8 re-collates 22
rows; LC_ALL=C moves exactly the changed rows — measured by AttackCells F2) and
migrates ten count/identity rows to the measured round-31-tip values. The counts:
stamps 99 → 102 (the two adopted entries + this lesson join the stamp set); scorecard
round headings 36 → 38 (the round's own two sections); ledger rows 68 → 74 (the six
new rows: R31-01, R31-02, R31-03..06); census rows 60 → 71, entries_sourced 8 → 10,
captures 60 → 71; docs entries 29 → 31, row_linked 26 → 28; revision-audit added
36 → 39 (stamps membership 102 − the immutable 63). The digest values are in each
migrated row's note (`corpus/claim-ledger.tsv`) — old→new per row, reasons chained.
The round's own bookkeeping also moved the eight self-description cells round 30
had corrected (historical line numbers: SKILL.md:46, PROVINCE.md:73, `corpus/README.md`:64/65/67) — re-corrected
to the measured values (102 stamps / 74 ledger rows / 28 row-linked / 31 pinned
entries; `python3 corpus/self-counts.py` ⇒ `stale=0`, the two PV-FEEDTOKEN policy
bindings stay the operator-routed reds).
The six never-audited round-29/30 scorecard cells received pointer-only Evidence
additions (row ids / stamped paths; no score or claim text changed) — the old→new
Evidence text is recorded here:

- Round-29 freshness cell: `… POSIX-scoped per Correction 1.` → `… Correction 1. Row `R29-01``
- Round-29 calibration cell: appended `; rows `R29-01`, `R29-02``
- Round-29 coverage cell: appended `; row `R21-02``
- Round-29 operability cell: appended `; rows `R29-01`, `R29-02``
- Round-30 depth cell: `… declared frontier area.` → `… frontier area. Stamped `corpus/knowledge/secret-scanning-detection-vs-validation.md``
- Round-30 adjacency cell: appended `; stamped `corpus/lessons/round-30.md``

The five heading reshapes (old → new, content-preserving; diff-stat 5/5/5, +30 bytes,
line count unchanged; canonical rewrite `.ufo/waves/round-31/build/AttackCells-reshape.sed`):

1. `## Round 26 — bounded release-drift response` → `## Round 26 — post-move (bounded release-drift response)`
2. `## Round 27 — knowledge numbers bound; release clocks refuse silent regression` → `## Round 27 — post-move (knowledge numbers bound; release clocks refuse silent regression)`
3. `## Round 28 — post-move: canonical version tokens; derived anchors bound to feed rows` → `## Round 28 — post-move (canonical version tokens; derived anchors bound to feed rows)`
4. `## Round 29 — post-move: feed-token right boundary; differential agreement gate (new host)` → `## Round 29 — post-move (feed-token right boundary; differential agreement gate on the new host)`
5. `## Round 30 — post-move: routed-defect closure (D1–D5), EOL repair, secret-scanning adoption` → `## Round 30 — post-move (routed-defect closure D1–D5, EOL repair, secret-scanning adoption)`

## Considerthese — proposal 2, machine-readable lane status

Source: `considerthese/2026-10-26.md` §"Self-improvement suggestions" proposal 2
(mined 2026-11-03; verified still-unimplemented — receipt
`build/ConsiderStatus-receipts-unimplemented.txt`). The proposal's premise is
confirmed: the lane's dispatch state was reconstructed from prose across `LOG.md` and
the fleet's records. Its example is stale — the round-28 HOLD was lifted by the
run-15 directive ("No holds") and rounds 29–31 were dispatched — so the value lands as
`open` with the 2026-10-21 refusal boundary still binding, and "open" is scoped to
dispatch (round 30's closure verdict `rejected-honest-stop` is a different fact, not
conflated). Convention landed: one `lane-status:` line in `SCORECARD.md`, in a
`## Lane status` section placed BEFORE the first `## Round` heading (a section after
the last round section makes `cells` close that section and enforce its six-axis
check — measured exit 2 by the seat); fields separated by em-dash, never `;` (the
ledger's META_RE refuses `;` and `|` in a row command, so a `;`-separated value is
un-bindable); the key is `lane-status:` (not `status:` — `Source-status:` in 14
entries and self-counts' OK/STALE verdict already occupy that word). The line is a
lane-authored self-declaration, never a control: no driver reads `SCORECARD.md`, and
the operator's holds live in the fleet root. Falsifier split: lane-locally the line is
one line, shape-valid, fleet-path-free (a fleet path would drag `citations` to
INCOMPLETE/exit 3 in a lone clone — measured; the watchdog log carries no hold
vocabulary at all); cross-boundary, the state word is reconciled against the
operator's records by the operator/closure judge. Recheck: on-release, with the
mandatory `as-of:` date as the staleness signal. Bound by rows R31-03..R31-06 (count,
shape, the `held` negative control with expected exit 1, and the routed-red set).
Two traps recorded: an unresolvable `R<n>-<n>` token on the line is a hard
`MISSING-ID` audit failure (the line cannot go stale in silence); a MARK_RE word
("no longer", "historical", …) on the line would downgrade its ids/paths to
`LABELED` and appear to satisfy checks it does not — the landed value avoids every
MARK_RE word. Proposal 3 was NOT mined: its premise (the D1 fail-open live) is stale
since round 29 (`STABLE_TITLE_RE` takes the right boundary; selftest 116).

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M31-1 | unreachable counter nearly frozen | the L1's initial plan draft sourced the 21 legacy entries' trios from NEW own-work registry rows; the census's SC_FETCH rule (`corpus/sources-census.sh:328` — every registry row needs an http capture row; `ffinal` must be an http URL) makes URL-less own-work rows unlandable, so that claim shape would have frozen unreachable and honest-stopped | the §9 rule-9 duty (probe the counter at BASE before freezing) — the probe ran pre-freeze and the claim was re-scoped to the cells-audit re-arm | both frozen counters were probe-run at BASE before the plan froze (`controls/`), and MutGates proved all three killable (pristine/mutant/restored receipts in `build/mut-*.txt`); the legacy-header gap stays named in `corpus/README.md` §Known gaps, not claimed |
| M31-2 | wrong-interpreter invocation | the L1 ran `python3 corpus/sources-census.sh` (a bash script) and read a SyntaxError as gate output; caught on inspection (the script is bash; the fleet-level path is `scripts/sources-census.sh validate`) | QM2 (an attribution carries the command and host) | the round's counting commands name the interpreter explicitly (`bash` for `.sh`); the wrong invocation is recorded here, not silently dropped |
| M31-3 | layout-artifact misread risk | the scratch-clone cells probe printed FAIL R22-03/R24-06/R24-15 (rows that pass in the lane) — lone-clone layout degradation, not lane defects | QM22 (a layout-dependent outcome prints a typed INCOMPLETE, never CLEAN — and a lone-clone FAIL is classified before it is believed) | CellsRed's classification step (routed vs layout-artifact vs unexpected) ran the rows in-lane before the L1 believed the probe; the classification receipt is `build/cells-red-inlane-rows.txt` |
| M31-4 | seat stall | OidcEntry2 and RowsDraft produced no wave-dir output ~2 h after dispatch (scratch activity stopped 17:38/17:08); the L1 integrated C2 from the other 13 seats' verified artifacts rather than blocking the round | none — no rule set a stall deadline | recorded here and in the report; the L1 integrated from verified artifacts (SrcOpenA/B/C captures + AttackOidc's independent re-fetches + OidcEntry1's re-grounding + RowsDraft's collision artifacts); their results.json status is recorded at WAVE-DONE; if they deliver before the report files, their outputs are reconciled and this row is superseded by a correction entry, never rewritten |
| M31-5 | QM32's own red witness | the round-30 plan (`plans/round-30.md` at `b7482b4`) froze C1 with R25-02 already FAIL at BASE and named in no claim — applying QM32 to that plan fires | M30-4's own routing (the criterion is the fix); the demonstration is the red witness QM32 requires | QM32 landed in `corpus/QUALITY.md` citing this row; the round-31 plan carries the measured BASE controls and names every red row of every gate it touches |

## Limits

- The campaign digests for nine of eleven registry anchors no longer reproduce; the
  in-round captures replace them as evidence, and the anchor cells keep the campaign
  pins as labelled history (the round-30 pattern).
- The fleet census's W04 duplicate-url warning count is predicted to move 14 → 16
  (S069's URL is held by S007/S019/S032; S070's by S018, trailing-slash variant) —
  warnings only, exit 0 unaffected; the after-receipt records the real count.
- R25-02, R29-01 and R29-02 stay red (operator-routed; L0 `kagi | round-30`); the
  cells summary stays `POLICY` while they are — that is the honest end state, named in
  the predicate, not a defect of this round.
- The 21 legacy entries stay outside the census's entry checks (deliberately
  unclaimed; `corpus/README.md` §Known gaps) — this round did not touch them.
- The `docs` audit's UNPINNED/MISSING-ID states for the new entries are closed by the
  same landing (stamps + rows), not by this lesson alone.

## Corrigenda (appended before the round report filed; the round-30 corrigenda pattern)

1. **M31-4 resolved — the stalled seat delivered and was adopted.** OidcEntry2 landed its draft
   and receipts at ~19:00 (its scratch shows fetch work through 18:43; the wave-dispatch-to-
   delivery latency was ~2 h 20 m). Its draft is BETTER than the L1's integration on one
   load-bearing point and was adopted wholesale (with `Reverify: R31-02` substituted and the
   draft placeholder removed): the L1's landed entry 2 had repeated the attack seat's
   "the JP product page carries no release status" bound — the late seat's Japanese-language
   needles found the status the English sweep missed (below). RowsDraft never delivered; its
   collision artifacts (reg-ids/staged-ids/collisions) were used; the registry rows were built
   by the L1 from the staged rows + the three SrcOpen capture sets.
2. **M31-6 (new mistake): an absence sweep is language-blind unless its needles cover the
   source's languages.** Class: absence-sweep-language-blindness. Evidence: the round's gate
   (AttackOidc, then the L1's landed entry 2 and the S071 registry row) asserted "the JP product
   page carries no release status (0 status hits)" from an English-needle sweep
   (`パブリックプレビュー`/`public preview`/`ベータ` → 0); the late seat's Japanese needles
   (`一般提供されていません`, `プレビュー版`, `カスタムOIDC構成`) locate the page's
   product-level status — 「まだ一般提供されていません。Credential Brokerは現在、すべての
   Enterprise Password Managerのお客様向けにプレビュー版が公開されています。これにはGitHub
   ActionとカスタムOIDC構成が含まれます。」 — a product-level label naming both paths, quoted
   in the entry and explicitly not used as a per-feature status (the round-22 uniform-preview
   rejection still governs). Captured-by: QA6/QM10 (a negative claim carries its sweep — the
   sweep's needles must cover the source's own languages, not only the entry's). Fix: the
   landed entry quotes the JP status with its sweep limitation; the S071 row's scope cell
   records it; a future absence sweep over a non-English source runs needles in that source's
   language (shown able to fail: the English-needle sweep IS the red witness — it reported the
   absence the page contradicts).
3. **The S066 locator was wrong twice.** The staged anchor (§信任策略 → 限制条件表) located 0;
   the first in-round correction (SrcOpenB/OidcEntry1/AttackOidc: §创建OIDC身份提供商的RAM角色
   → 操作步骤 → 服务级限制条件表) ALSO locates 0 on the rendered page; the late seat's locate
   counts found the real headings (创建可信实体为身份提供商的RAM角色 → 3; 限制条件关键字 → 2;
   是否必选 → 2). The entry 1 source line, the S066 registry anchor and the S066 capture
   location are corrected to the counted form. Class: locator-by-narrative (a location named
   from reading, not counted). Captured-by: the locate-count discipline the late seat applied
   (every location should carry its count — SrcOpenC's receipts already do). Fix: the corrected
   anchors carry the counted headings; the lesson records that a location asserted without a
   count is a claim, not a measurement.

## Corrigenda 2 (post-WAVE-DONE, pre-report; the RowsDraft seat's independent verification of the landed state)

RowsDraft delivered last (its report + `build/assimilation/{registry-append.md,renumber-map.md}`
landed with the wave results; the orchestrator kernel restarted mid-wave, so the seats' final
outputs were re-read from their wave-dir files). It independently re-fetched all eleven sources
and audited the LANDED bytes; four material findings, all fixed in this corrigenda commit:

- **F-1 (S067's section anchor was wrong twice):** the aud (REQUIRED) claim-list entry sits
  under the heading "2. ID Token" (measured offset 51700); the §3.1.3.6 block contains ZERO
  `aud` occurrences. AttackOidc's F-C flip ("use the stable §3.1.3.6 anchor") corrected the
  staged line numbers but kept a wrong section; the committed capture row (SrcOpenB: "§2 ID
  Token") was right. The registry anchor and entry 1's source line now say §2; the L1
  re-measured independently (the enclosing-heading walk + the §3.1.3.6 block scan) before
  adopting. Class: an attack seat's correction adopted without an independent measurement —
  captured-by: QM2/the two-evidences gate standard; fix: every locator correction is re-measured
  by the L1 before landing (done here).
- **F-2 (the S063 capture location carried the staged defect's section label):** the capture
  row said "Request Parameters, Audience parameter description (line 347)"; line 347 sits under
  the Response Elements h2. Fixed to the counted form. The census cannot see it (location is
  length-checked only) — a verifier re-running the capture would have chased the wrong section.
- **F-5 (locator labels not verbatim on the page):** S068's "BCP 240" locates 0 (the RFC header
  reads "SPRIND BCP: 240") — anchor corrected; S064's "the three bullets appear twice" was
  imprecise (bullets 1-2 twice each; bullet 3 once + a heading variant) — anchor corrected;
  S066's table is named by its header row (限制条件关键字 ×2), the lead-in being 支持的服务级
  限制条件.
- **F-6 (S065's premise and flip condition):** the ja page's html lang is `ja-x-mtfrom-en` (a
  Google machine-translation marker) — recorded in the row; the row is never cited beyond
  terminology and the language-invariant code sample; the flip condition (ja lags en) has no
  en-twin capture in-round (the en WIF path is unopened) and stays open — recorded as an open
  condition, not silently dropped.
- **F-4 (the S071 tier decision, recorded):** RowsDraft recommended tier B (the pre-reconciliation
  entry had no in-text [S071] citation; the EN twin S005 sits at tier C). The reconciliation
  landed the late seat's JP section WITH in-text [S071] citations (the JP renderings are the
  claim), so the tier-A-for-Japanese-terminology scope now has a primary claim and tier A
  stands; the seat's counter-argument (a native ja page under a ja-scoped tier A) is on record,
  and both censuses were verified green at tier B on a scratch clone should a later round
  re-grade.
- **F-7 (recorded, not scored):** entry-body quotes use straight apostrophes where the pages use
  curly (the lane-wide convention; the capture rows preserve the pages' exact forms and locate);
  the census does not gate entry-body quotes.
- **Collision-count correction:** the measured collision set is S052–S060 (9 ids — lane
  S058–S060 also collide with staged ids), not the 6 the plan's parenthetical named; the
  renumber map resolves all nine; no live id overwritten.

## Corrigenda 3 (round 32 — verifier routed items R3 and R4; the SD6 label)

- **R3 (S063 `Audience` count, Gate table line 44).** The row states `Audience` "occurs twice, both in the response section". Measured by the non-author integrator (round-31 verifier spot-check §2, R3) on the saved page: two lines, 343 (Response Elements) and 593 (an example XML response, not the response section's element list). The request-parameter list has no `Audience`. The Gate text above is kept as written; this corrigendum supersedes its count.
- **R4 (M31-6 row).** M31-6 was named in Limits (line 214) and in Corrigenda 1 but had no row in the Mistakes table. Its row, appended here:

| id | class | evidence | captured-by | fix |
|---|---|---|---|---|
| M31-6 | absence-sweep-language-blindness | Corrigenda 1, item 2 (line 214): the English-needle sweep reported "no release status" for the JP credential-broker page; the Japanese needles locate a product-level status | QA6/QM10: a negative claim carries a sweep whose needles cover the source's languages | Japanese needles added; the status claim re-derived from the page and quoted as product-level, not per-feature |

- **SD6 label (round-32 edit, line 121).** The citation `corpus/README.md`:64/65/67 on line 121 did not resolve under `corpus/claim-ledger.sh citations` (UNRESOLVED). The gate's documented remedy is a labelled citation: the word `historical` was added on that line; no other text changed.
