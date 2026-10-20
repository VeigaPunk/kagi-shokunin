# Entry15 — freshness/calibration audit: `knowledge/onepassword-machine-credentials.md` + its stamp row

- **Seat:** KagiR22.Entry15, scout, read-only, leaf (no dispatch).
- **Axes:** C1 calibration; C2 freshness. No depth move, no legacy-header proposal, no gate execution.
- **Repo root for all paths:** `kagi-shokunin` (frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`).
- **Exact read revision (authoritative):** `c2cab35` (HEAD) blob `d69e058d0c002aeddb9d71d2b6edb8f943138c83` =
  `sha256 7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb`, 35 lines, 6240 bytes.
  `corpus/stamps.tsv` line 23 pins the identical triple. **No stale-byte mismatch at the frozen base.**
- **Working tree moved mid-audit (another live seat):** at `2026-10-20T18:34:10-03:00` the file was
  uncommitted-modified to `sha256 e885081e4d56…`, 68 lines, 8328 bytes (a round-22 erratum appended;
  `git diff` = 33 insertions, 0 deletions). That is an in-flight delta, **not** the audited base and
  **not** a ledger defect. Every base statement below is against the blob above.

## 1. Verdict in one paragraph

At the frozen base this entry's stamp row is **byte-exact**; the entry is **not** one of the five named
stale pins, **not** the unnamed sixth committed stale pin (`LOG.md`), and **not** a dropped row in any
committed revision of `corpus/stamps.tsv`. Substantive freshness holds on 2026-10-20: every quoted
teaching sentence the entry relies on is still present at its cited anchor on the live pages. The open
problems are calibration-shaped, not staleness-shaped: (a) the round-21 erratum mis-anchors the
eligibility quote; (b) the entry and that erratum treat Broker release status as a single uniform
"public preview" while the cited announcement itself splits GitHub Actions (preview) from custom OIDC
(beta); (c) `recheck: … on-release for S006–S007` names no observable release surface, unlike the
sibling convention; and (d) the recorded source fetch digests are not reproducible — and for the S006
blog are unstable across consecutive fetches — so they cannot function as the drift detector the
`verified-at:` parenthetical implies. An appended, append-only erratum is warranted for (a)–(d); no
in-place rewrite and no restamp today.

## 2. Stamp-row audit (C2, byte level)

| item | value |
|---|---|
| pin (stamps.tsv:23) | `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb` / 35 lines / 6240 bytes |
| frozen-base blob | `d69e058d…` / `7635be81…` / 35 / 6240 → **exact match** |
| first pin | `c41af82` (round-21 admission): `2cc5cfae86777f913298ba3bce4bdf22e30584244767f46f4bc034192ec65db8` / 30 / 5364 |
| re-pin | `e1544c1` (post-landing errata on the three new entries): `7635be81…` / 35 / 6240 |
| drop history | none. Path first appears at `c41af82`, persists through `e1544c1`; row-set counts across all nine commits touching `stamps.tsv` are monotonic 28→33→44→48→52→54→56→63→63 |
| stale-pin membership | not among the five named stale pins (`corpus/lessons/round-21.md:85`: `config-layering`, `handler-on-disk-state`, `handler-trust-boundary`, `janitor-env-contract`, `round-18`), nor the sixth committed stale pin `LOG.md` |

- The wave phrase "nine previously dropped stamps" does not describe a drop of this path. The only
  nine-row figure in the corpus is `LOG.md:983`: "Stamp drift at `aea7a43`: 9 rows mismatched" —
  **mismatched**, i.e. stale pins, not deleted rows. For this entry: no deletion, no reordering, no
  laundering.
- `e1544c1` did the correct thing: it appended the round-21 erratum (5 lines) and re-pinned the row in
  the same reviewed commit. Historic pin values are preserved in git; the TSV is a mutable snapshot,
  not an append-only log, so the old value's home is the commit history, not the current file.
- At base the ledger would be clean for this path. With the live 68-line delta and no re-pin,
  `claim-ledger.sh verify` would print `STALE` for this path — expected, and resolved by a reviewed
  re-pin after that delta lands (see §7), never by editing the old pin.

## 3. Substantive freshness audit (C2, content level)

Retrieval: 2026-10-20, `curl -sL --max-time 30 <url>` (the recipe recorded at `LOG.md:1004`), HTML
tag-stripped, case-sensitive phrase search; S002 additionally checked in `alt` attributes. Each quote
is ≤25 words. PASS = cited sentence still present.

| id | URL + anchor (as cited) | quote checked | 2026-10-20 |
|---|---|---|---|
| S001 | https://www.1password.dev/cli/secrets-scripts — §Use `op run` to pass environment variables from a 1Password Environment | "provisioned for the duration of the process." | **PASS** |
| S002 | https://www.1password.dev/connect — Connect-server diagram caption | "The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API." | **PASS in image alt text only** (see §4) |
| S003 | https://www.1password.dev/connect/get-started — §Deployment, Steps 1 and 3 | "credentials necessary to deploy 1Password Connect Server"; "Create a new token for each application or service you use." | **PASS** (both) |
| S004 | https://www.1password.dev/service-accounts/security — §Access control; §Token rotation and revocation | "you choose the vaults it can access and its level of access."; "You can rotate or revoke service account tokens." | **PASS** (both) |
| S006 | https://1password.com/blog/1password-credential-broker-public-preview — introduction; §How 1Password Credential Broker works | "available for all Enterprise Password Manager Business customers"; "unlike a service account token that carries standing access, the organization-wide integration key is an encryption key" | **PASS**; publication date "July 28, 2026" still displayed |
| S007 | https://www.1password.dev/brokered-access — introduction; §GitHub Actions; §Custom Workflow (OIDC) | "only remain accessible for the duration of the workflow"; "All configured claims must match"; "The token value is your integration key" | **PASS** (all) |

Negative check that matters for C1: the base's strongest Broker sentence is **supported verbatim** on
S006, not an inference — "The workload can retrieve only the approved credential during the authorized
job, without receiving standing access to the vault." So item 4's "without standing vault access" must
**not** be softened or erased by any correction. The two known E1 overclaims are already refused in
`## Does not establish` (lines 24–26): `op run` process delivery does not shorten the Service Account
token, and Broker does not remove every CI-held key.

Conclusion: the base's substantive claims remain fresh under their own anchors. Today's evidence does
not justify a re-verification restamp, and it does not justify rewriting the dated `verified-at:` value.

## 4. Absent-source limits (what cannot be concluded)

1. **No source snapshot exists in-repo.** `corpus/SOURCES.md` stores a single `Fetch sha256` per row;
   nothing stores the fetched bytes. Source drift therefore cannot be re-measured offline, and the
   recorded digest cannot be re-derived from the repo.
2. **The recorded digests are not reproducible.** On 2026-10-20, all six cited rows refetch to a
   different digest than recorded (S001 `9f9d7283…`→`24d1aecd…`; S002 `68017d4c…`→`9e00e86d…`;
   S003 `7f6d3b49…`→`0daffd88…`; S004 `19bcf13e…`→`7e6f0408…`; S006 `39a869df…`→ three different
   values; S007 `e4aef238…`→`896c780b…`). Five pages are byte-stable across two consecutive fetches;
   the S006 blog returned **three different digests in three consecutive fetches** (per-response
   nonces/build data). Consequence: a digest mismatch cannot distinguish vendor content change from
   fetch-environment/nonce variance; for S006 the digest is structurally unusable as a pin.
3. **No displayed dating hook on the docs pages.** S001–S004 and S007 show no version/date and no
   "Last updated"; the blog shows only its publication date. There is no page-local release marker an
   "on-release" clause could observe.
4. **S002 is alt-text-level evidence.** The quoted sentence lives in the Connect diagram's `alt`
   attribute; a tag-stripped text pipeline (the round-21 method recorded in the erratum) does not see
   it. The claim is supported, but only at diagram-metadata strength.
5. **No product behavior was exercised.** Nothing here proves Broker/CLI behavior; the entry itself
   scopes to vendor documentation (PROVINCE). No credential, vault, account or workflow was touched.

## 5. Calibration findings (C1), all against the base blob

- **K1 (high) — round-21 erratum anchor is wrong.** Line 34 attributes the eligibility sentence to
  "S006 (introduction and §Try 1Password Credential Broker today)". In the fetched page the sentence
  "available for all Enterprise Password Manager Business customers" sits immediately before the H2
  "How 1Password Credential Broker works" — i.e. in the **introduction**. "Try 1Password Credential
  Broker today" is a later, separate H2. The eligibility claim is true; only its locator is false.
  This is exactly the source-bound citation defect C1 is meant to catch.
- **K2 (high) — uniform status vs feature split.** Base line 16 heads the item "Credential Broker
  public preview" and the round-21 erratum concludes the custom-OIDC path's status is "unverified".
  But the entry's own cited announcement already separates them: "Alongside GitHub Actions support in
  public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows."
  (§New in this release: Custom OIDC workflows, S006). Independently, the live feature pages title
  GitHub Actions "(public preview)" and custom workflows "(public beta)". A bounded correction must
  state per-path status; a blanket "preview" (or a blanket "unverified") is the E1 overclaim shape.
  Limit: because S006 bytes are non-deterministic, I cannot prove the split sentence existed in the
  2026-10-19 fetch; the live S017/S018 titles stand on their own.
- **K3 (medium) — claim-matching is attributed to no path.** Line 16 says the guide "requires every
  configured OIDC claim to match" for "the workflow integration". On S007 that requirement appears in
  the custom-workflow path (after "Define the identity requirements (claims)…"), not in the GitHub
  Actions requirements, which are hosting/plan prerequisites (S019: GitHub.com hosting; Enterprise
  Server/Cloud-with-data-residency unsupported; GitHub Free private-repo workflows excluded —
  verified live). Correction: attribute claim matching to the custom-OIDC path.
- **K4 (low) — page-class wording.** Line 3 says "reopened the six cited public documentation pages";
  S006 is a vendor blog announcement, and the registry itself types it `docs`. Reword as "six cited
  pages (five documentation pages and one announcement post)" if the erratum touches this line's
  semantics; the digest claim also needs K5's qualification.
- **K5 (medium) — digest semantics overstate verification power.** `verified-at:` implies the
  recorded digests support later drift checks. They do not (§4.2). If kept, the erratum must say the
  digest is a one-shot fetch observation tied to an unrecorded environment, and that the operative
  recheck is quote/anchor presence, not digest equality.
- **Confirmed non-defect (negative evidence).** Item 4's "without standing vault access" and the
  `## Does not establish` refusals are correctly bounded (see §3). Do not "correct" them.

## 6. Is an appended correction needed?

**Yes — one appended erratum section, additive only.** Minimum content, in the entry's existing
erratum style, after the base text and the round-21 erratum:

1. Eligibility locator correction: the S006 eligibility sentence is in the announcement introduction
   (immediately before §How 1Password Credential Broker works), not §Try 1Password Credential Broker
   today; the round-21 bullet's claim stands, its anchor does not.
2. Per-path status: GitHub Actions public preview; custom OIDC public beta at page-title level, while
   the product/navigation label "Credential Broker (public preview)" persists on the same pages. State
   both scopes instead of replacing one blanket label with another.
3. Path attribution: claim matching belongs to §Custom Workflow (OIDC); GitHub Actions requirements
   are GitHub.com hosting plus Business connection (and the guide's Enterprise Server/Cloud/GitHub
   Free exclusions).
4. Pin semantics: the registry's `Fetch sha256` values are point observations, not reproducible drift
   pins (evidence: six rows differ on 2026-10-20; S006 non-deterministic across three fetches); the
   operative recheck is anchor/quote presence.
5. Recheck trigger: restate the S006–S007 clock as an observable one (see §7) because "on-release" has
   no surface to fire on.

Append-only preservation requirement (non-negotiable):
- Do **not** edit lines 1–36 of the base file; do not delete or reword the round-21 erratum; do not
  move the stamp row; do not rewrite the historic pin value in `stamps.tsv`.
- If the recheck clock must change in the header, that is a separate reviewed migration with recorded
  before→after; until then the erratum bullet governs. (No header-redraft proposal is made here.)
- If the live round-22 draft lands, fold items 1–5 into it rather than appending a second round-22
  erratum; the draft already covers item 2's substance but not its locator caveat, and it states
  "public beta, not public preview" without the surviving product-level nav label.

## 7. Exact proposed recheck scope (from 2026-10-20)

Keep `90d for S001–S004`: due **2027-01-17** (2026-10-19 + 90d). Reopen exactly:

- S001 `https://www.1password.dev/cli/secrets-scripts` → §Use `op run` to pass environment variables
  from a 1Password Environment: the process-duration sentence.
- S002 `https://www.1password.dev/connect` → Connect-server diagram caption: the access-token/REST-API
  sentence (check `alt` text, not only stripped text).
- S003 `https://www.1password.dev/connect/get-started` → §Deployment, Steps 1 and 3: deployment
  credentials vs per-application token.
- S004 `https://www.1password.dev/service-accounts/security` → §Access control and §Token rotation and
  revocation: vault-scope and rotate/revoke sentences.
- S006 `https://1password.com/blog/1password-credential-broker-public-preview` → introduction
  eligibility and §New in this release: Custom OIDC workflows: Enterprise Password Manager Business
  eligibility, Actions-preview vs custom-OIDC-beta split, integration-key-as-encryption-key sentence.
- S007 `https://www.1password.dev/brokered-access` → introduction (workflow-duration), §GitHub Actions
  (organization secret / token value is the integration key), §Custom Workflow (OIDC) (claims must
  match, OIDC-provider connection), plus the guide's GitHub hosting/plan exclusions.

Observable trigger to replace "on-release for S006–S007": revisit when either (i) the feature pages'
title labels change status ("public preview"/"public beta"/GA), or (ii) the guide's introduction or
GitHub Actions requirements change; check at the same 90d cadence as a floor. Record the fetch date and
whether the check was label-level or sentence-level — never record a digest as the verdict.

## 8. Ledger expectation migration (C2)

- **Expectation to retire:** "a recorded fetch digest is a reusable staleness pin." Replace with "a
  digest is a dated observation; content checks are anchor-level and must name the page, anchor,
  sentence, and access date."
- **Expectation to keep:** `stamps.tsv` pins in-repo bytes only. It is a snapshot row set; history is
  git. This entry's §2 table is the exact migration evidence.
- **Expected post-integration edit:** after the live 68-line/8328-byte delta (or its successor) lands,
  re-measure sha256/lines/bytes and re-pin this path in one reviewed `stamp` commit; record the
  before→after (35/6240 → measured) in LOG/lesson. Do not re-pin the five named stale debt rows or
  `LOG.md` as a side effect.
- **Expected historic evidence:** `c41af82` pin `2cc5cfae…`/30/5364; `e1544c1` pin `7635be81…`/35/6240;
  base blob `d69e058d…`. These three values make the evolution auditable without any file rewrite.

## 9. Live in-flight delta (observed, not audited as landed)

- Entry at 18:34:10: appended "Erratum (round 22 — feature-specific status and eligibility)" citing
  S017–S020. Its claims I could independently check are sound: S017 title "(public preview)";
  S018 title "(public beta)"; S019 contains the Enterprise Server/Cloud residency exclusion and the
  GitHub Free private-repository exclusion verbatim; S018 states the latest beta desktop app and that
  Broker is "only supported in the 1Password JavaScript SDK at this time".
- Pre-integration notes for the parent:
  1. `corpus/SOURCES.md` (live) binds S017–S020 `used-by` to `corpus/lessons/round-22.md`, which is
     currently **untracked** (exists at 18:35, `source: S017, S018, S019, S020`). If the lesson does not
     land with the SOURCES rows, `sources-census.sh` reports `SC_USEDBY_MISSING`. The entry's body
     citations of S017–S020 do **not** affect the census (it reads only the `source:` line), so no
     entry `source:` change is required.
  2. S018's page carries both labels: title "(public beta)" and navigation "Credential Broker (public
     preview)". Do not let "public beta, not public preview" erase the product-level label; scope each.
  3. Do not delete S006/S007 rows or their entry `source:` ids when "superseding"; supersession is a
     reading instruction in the new row, not a status flip (both remain `mined`, unchanged fields).
- I take no position on the rest of the live wave state (other modified files belong to other seats).

## 10. Scope discipline / limits of this audit

- No host gates were run (`claim-ledger.sh`, `sources-census.sh`, `drift-pins.sh`, checklist, probes):
  explicitly excluded. All hash/line/byte comparisons here were computed read-only (git blobs +
  sha256sum/python), not by executing the gates.
- No writes other than this report; no installs (none needed); no network writes, no account/vault
  operations. Web reads were unauthenticated public GETs of the six cited URLs plus S017/S018/S019.
- Confidence: byte audit **high** (deterministic); quote presence **high** (direct fetch + text
  extraction, 2026-10-20); digest mismatch attribution **low/unresolved** (recipe/environment or
  content change both possible; S006 proven unstable).
- Remaining unknowns: (1) whether the 2026-10-19 digests used the documented recipe or another
  environment; (2) whether S006's custom-OIDC beta sentence existed on 2026-10-19 (no snapshot);
  (3) rendered appearance of the S002 diagram (only alt text checked); (4) product behavior, out of
  scope by contract.
