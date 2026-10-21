# ReopenSource20 — S020, with S017–S019 examined separately

Seat: `KagiR22.ReopenSource20` (independent leaf attack; axes: calibration and freshness).
No W1 credit is claimed or implied, and no W1 seat is replaced. No depth move and no
legacy-header-count claim.

## Read revision and frozen inputs

- Integrated landing under attack: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`.
  The cited `c2cab35bc92e57e39e5489bac3386db078345b3f` is treated as historical BEFORE only.
- Freeze record: `.ufo/waves/round-22/integration-manifest.json`,
  sha256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
- Observed file hashes (re-measured, all matching the manifest where listed):
  - `corpus/SOURCES.md` — `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` (19,721 B, 86 lines)
  - `corpus/lessons/round-22.md` — `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4`
  - `corpus/knowledge/feature-bound-credential-review.md` — `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe`
  - `corpus/feature-claims.json` — `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa`
  - `corpus/feature-claims.py` — `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af`
  - `corpus/stamps.tsv` — `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29`
  - `corpus/claim-ledger.tsv` — `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a`
  - `corpus/sources-census.sh` — `03fb300a74157232978525c6bc4b028d7ed9159bccbb47d32333deb48ba76b3c`
  - `corpus/revision-audit.py` — `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977`
- Frozen BEFORE `corpus/SOURCES.md` (`c2cab35:corpus/SOURCES.md`) — `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332`,
  matching `.ufo/waves/round-22/frozen/before/expected.json`; the frozen snapshot is
  byte-identical to the base blob (same digest).

Method: exact-URL public documentation GETs (`curl`, and the read tool's markdown
alternate for the `.dev` pages), plus locally owned fixture executions of the shipped
gates. No launchers, version managers, npm/npx, package managers, loopback/health/CDP
probes, account, vault or host-private gate was used. No install was needed or performed.
Nothing in production was written; this report is the only artifact.

## S020 — reopen and anchor verification

URL reopened: `https://1password.com/blog/1password-credential-broker-public-preview`
(raw HTML GET, 190,261 B), 2026-10-20.

| Check | Observed (live, 2026-10-20) | Confidence |
|---|---|---|
| Page identity / date | `meta-article:published_time` and `modified_time` both `2026-07-28`; byline "July 28, 2026"; H1 matches the row title | high |
| Named anchor exists | `## New in this release: Custom OIDC workflows` is present at that heading | high |
| Status-split quote | "Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows." (§New in this release; 19 words) | high |
| EPM eligibility quote | "available for all Enterprise Password Manager Business customers to start using right now" (introduction; 13 words) | high |
| Row `scope`/`teaches` support | Row says "announcement-time Actions preview versus custom-OIDC beta" and "EPM Business eligibility applies" — both supported at the named sentences | high |
| Row revision fields | `opened 2026-10-20`, `recheck on-release`, `used-by` both files that cite it | high |
| Recorded digest | `55bf23fe…ebfe3eda` does **not** reproduce; see freshness below | high (mismatch), unknown (cause of the author's fetch) |

The row is a point-in-time announcement record and is correctly labelled that way: the
page's own title says the *product* is "now in public preview", while the body splits
Actions preview from custom-OIDC beta. The row does not inherit the title across
features, and the active review repeats the split with per-product limits.

## S017–S019 — feature-specific status and eligibility, examined separately

Each exact row URL was reopened; status was read only at the feature's own title/H1 and
badge, eligibility only from the named introduction/setup/requirements text.

| Row | Status anchor | Eligibility anchor | Verdict |
|---|---|---|---|
| S017 `…/github-actions/` | H1 "…GitHub Actions at runtime (public preview)"; badge "Public Preview" | introduction: "If an administrator has connected your GitHub organization to your 1Password Business account" | supported |
| S018 `…/custom-workflow/` | H1 "…custom workflows at runtime (public beta)"; badge "Beta" | introduction: OIDC provider connected to the Business account; Step 1 "latest beta release of the 1Password desktop app"; Step 3 note "Credential Broker is only supported in the 1Password JavaScript SDK at this time." (13 words) | supported |
| S019 `…/brokered-access` | H1/guide badge "(public preview)" — the row explicitly refuses a uniform per-feature label | introduction: "a supported integration in their 1Password Business account"; §GitHub Actions requirements: GitHub.com hosting required, Enterprise Server / Enterprise Cloud with data residency unsupported, GitHub Free organizations cannot use private-repository workflows | supported as written |

Whole-page scanning would misread S018: the same page's "Related topics" chrome carries
"(public preview)" links for the setup guide and the Actions page, while the feature's own
H1 says public beta. The anchor rule in `corpus/lessons/round-22.md` §Mistakes is therefore
load-bearing, and the S020 split is the independent vendor sentence that settles it.

### Calibration execution (local fixtures only)

| Command | Observed | Matches frozen expectation |
|---|---|---|
| `python3 corpus/feature-claims.py --selftest` | `FEATURE_CLAIMS_SELFTEST: PASS cases=10`, exit 0 | yes (10) |
| `python3 corpus/feature-claims.py --phase before` | exit 1; 10 decisions all at expected; `false_claims=2 bar_failures=8 false_admissions=0 misses=0` | yes (10 rejected: 2 false-claim classes — status-conflation and same-page-status-anchor — plus 8 bar-fails) |
| `python3 corpus/feature-claims.py --phase after` | exit 0; `admitted=4 false_admissions=0` | yes (4) |
| `python3 corpus/feature-claims.py --phase boundary` | exit 2; `unjudgeable=3` | yes (3, excluded) |

This is a decision-count demonstration (not an authored-criteria count): the ten bad
records are rejected for the stated defect classes, the four bounded controls are
admitted, and the three out-of-scope records are returned as cannot-evaluate rather than
scored. The source census reproduces its pinned string exactly:
`SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`.

## Original-row immutability

- Every S001–S016 row is byte-identical between the frozen BEFORE snapshot and the
  integrated tree (`diff` of the extracted rows: no output). No original status, anchor,
  recheck or `used-by` field moved.
- S006 and S007 specifically are byte-identical to the base blob
  (`git show c2cab35:corpus/SOURCES.md` vs HEAD), so the supersession is recorded only in
  the new S019/S020 rows and the appended lesson/erratum prose, not by rewriting history.

## Freshness measurements (pointer integrity, not vendor currentness)

| Check | Observed | Result |
|---|---|---|
| `corpus/SOURCES.md` stamp | `3ba44518…` / 86 lines / 19,721 B equals the live file | OK |
| `python3 corpus/revision-audit.py --selftest` | `PASS (cases=11 failed=0)` | OK |
| `python3 corpus/revision-audit.py --history c2cab35…` | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)` | matches manifest |
| `bash corpus/claim-ledger.sh` (default `verify`; the observed argv's extra token `revision` is not a mode) | `CLAIM_LEDGER: CLEAN (claims=43 deferred=11 stamped=69 ids=43 cited=42 labeled_ids=17 orphans=1)`, exit 0; zero `STALE`/`MISSING` lines from `verify_stamps` | OK (stamp audit ran inside `verify`) |
| Nine deleted diff lines | `git diff aea7a4301 e1544c19 -- corpus/stamps.tsv`: 9 removed / 16 added lines; first-column sets: **0 removed**, 7 new members, **9 same-path replacements** — exactly the nine paths in the lesson table | reproduces the claim |
| Migration evidence | `.ufo/waves/round-22/round21-migrations.json` preserves each old and new line for those nine paths plus five rewritten claim rows (`R12-02`, `R12-03`, `R13-01`, `R13-02`, `R14-01`), `removed_members: []` | preserved |
| Later span | `.ufo/waves/round-22/historical-correction-pins.json` records 13 pin changes `c41af82d…→e1544c19…`, including `corpus/SOURCES.md 1cd6d240…(41/13863) → db134917…(43/14261)` | present |

**Command-attribution correction (parent review; no rerun).** The original table attributed
the `CLAIM_LEDGER: CLEAN` line to a `bash corpus/claim-ledger.sh revision` mode. Static
inspection of the frozen script shows the parser accepts only `verify|citations|cells|docs`,
`--selftest`, and `stamp` (`corpus/claim-ledger.sh:195-198`); an unmatched positional such as
`revision` is appended to `POS` and ignored, leaving the default `verify` mode selected. The
retained output on disk (`/tmp/cl-rev`: `DEFER …`, `LABELED-ID …`, then the CLEAN summary) is
therefore the `verify` result, and `verify` calls `verify_stamps` first; it emitted zero
`STALE`/`MISSING` rows over 69 stamped paths. The substantive stamp result is unchanged —
only the mode name was wrong — and no re-run was performed to manufacture a matching receipt.

### S020 digest finding (bounded)

The `sha256` recorded for S020 in `feature-claims.json`
(`55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda`,
`digest_observed_at 2026-10-20`) is not reproducible. Three successive raw GETs returned
`7a52cc1d…`, `0483f8a6…` and `f2f97a68…`, all 190,261 B. Pairwise diff is exactly one
44-byte region: the Cloudflare obfuscation token inside
`/cdn-cgi/l/email-protection#<token>`; `buildId` and all article prose were identical. Both
quoted sentences are present in every fetch. By contrast, the S017, S018 and S019 recorded
digests reproduce byte-identically from the raw HTML GET (1,215,155 B / 1,282,825 B /
1,199,099 B respectively).

So the S020 digest is a historical point observation of a render that rotates an
anti-scrape token per response. It is not a drift pin, and it must not be compared across
fetches. The gate never fetches: `feature-claims.py` only shape-checks the hex and pins the
canonical digest of the whole `sources` array (`PINNED_SOURCES_SHA256`), so nothing
load-bearing depends on the value; but a future reviewer seeing a mismatch must not call it
content drift. **Proposed correction (post-freeze):** annotate S020's digest as
representation-unstable, or record a normalized digest with the `cdn-cgi` token masked. Do
not restamp it to "current"; digest identity never proves vendor currentness.

## Observations that remain (limits, not observed false admissions)

1. **`supersedes` wording in the registry row is broader than the lesson's scope.**
   `corpus/SOURCES.md:26` says "supersedes S006 — EPM Business eligibility applies; …".
   The lesson qualifies this as superseding S006's "incomplete qualifier coverage", while
   S006's integration-key-versus-standing-token distinction is still supported and is not
   superseded. The row's own `scope` cell bounds the row to eligibility/status, so I do not
   read a false vendor claim; a tighter wording ("supersedes S006's eligibility/status
   reading") would remove the ambiguity. Same shape applies to S019/S007.
2. **The product-level EPM sentence is the required plan evidence for the custom-OIDC
   feature.** `corpus/feature-claims.json` binds `eligibility.plans =
   enterprise_password_manager_business` for `op_cb_custom_oidc` to `S020-epm-plan`, whose
   sentence describes the public-preview release and says "to start using right now". That
   is an inference at the feature boundary; it is independently corroborated by S018's
   "1Password Business account" prerequisite, and the recorded claim is the plan tier rather
   than universal availability. The gate's binding check compares declared values, not quote
   text, so it cannot detect a product-level quote used for a feature-level field. No false
   admission observed; flag as a calibration precision limit, not an overclaim.
3. **`used-by` is not an exhaustive consumer index.** `corpus/knowledge/onepassword-machine-credentials.md`
   (round-22 erratum, lines 41–63) cites S017–S020 in its body, but their `used-by` cells
   list only `corpus/lessons/round-22.md` and `corpus/knowledge/feature-bound-credential-review.md`.
   The census checks only IDs declared on an entry's `source:` header (the erratum header is
   intentionally unchanged), so this passes cleanly and is consistent with the lesson's
   stated bound. Readers must not treat `used-by` as a complete citation graph.
4. **Registry rows are not distinct URLs.** 21 rows resolve to 18 distinct URLs: S006/S020,
   S007/S019 and S016/S021 are supersession pairs on the same page. Row-count accounting is
   therefore not source breadth; no round-22 text claims otherwise.

## One concrete supported claim and one scope limit

**Supported claim (S020, §New in this release: Custom OIDC workflows,
`https://1password.com/blog/1password-credential-broker-public-preview`, published
2026-07-28):** "Alongside GitHub Actions support in public preview, we're slowly rolling out
a new capability in beta: custom OIDC workflows." This is present verbatim today and
directly supports the row's feature split; combined with S017's and S018's own H1s, the
uniform "Broker is public preview" reading is falsified at the feature anchors.

**Scope limit (S020, introduction):** the EPM Business sentence describes availability of
the public-preview release ("to start using right now"), not a guarantee that every EPM
Business customer can use every Broker capability during staged rollout, and the page is a
dated announcement rather than a live status oracle. S020 cannot support a current status
for either feature, nor any claim about deployment hosts, SDKs, or credential custody
beyond the two sentences quoted above.

## Remaining unknowns

- The representation behind S020's recorded digest is unrecoverable (the `cdn-cgi` token
  rotates); I cannot tell whether the page changed content since the author's fetch, only
  that today's prose contains both quoted sentences.
- I did not execute the ledger selftest (`108` cases) or reopen S021/OpenBao pages; no such
  result is claimed. S006/S007 were checked only for byte-unchangedness, not re-adjudicated.
- Static-page digest stability is measured only within this session; no longer-horizon drift
  claim is made. No production file was modified and no install occurred.
