# ReopenSource19 — S019 independent reopen, S017–S020 status separation, revision accounting

Seat: `KagiR22.ReopenSource19` (leaf, read-only). Axes: **calibration**, **freshness**.
Read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (round-22 landing).
Frozen input: `.ufo/waves/round-22/integration-manifest.json` (`base_revision` `c2cab35bc92e57e39e5489bac3386db078345b3f`; purpose "Frozen integrated inputs for the fresh second wave; not admission").
No production edits. Public documentation GETs + read-only local corpus checks only. No installs, no live account/vault/host gates, no delegation. No credits to missing/dead W1 seats.

## 1. Frozen identities — observed == manifest

| path | sha256 (observed) | lines | bytes |
|---|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 | 19721 |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 | 15700 |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 43 | 4440 |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` | 10 | 1804 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | — |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 | 17770 |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | — | — |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | — | — |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` | — | — |
| `corpus/sources-census.sh` | `03fb300a74157232978525c6bc4b028d7ed9159bccbb47d32333deb48ba76b3c` | — | 25950 |

All ten match the manifest. `corpus/SOURCES.md` also matches its live pin at `stamps.tsv:60` (`3ba44518…`, 86, 19721). `feature-bound-credential-review.md`, `lessons/round-22.md` and `SOURCES.md` are therefore the same bytes this report read and the bytes the gates pin.

## 2. S019 reopen — `https://www.1password.dev/brokered-access`

**Retrieval (2026-10-20).** Raw HTML via `curl -sSL` (default UA): **sha256 `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f`, 1,199,099 bytes**. Two consecutive fetches were byte-identical, and this digest equals both `build/Source07.md` and `corpus/feature-claims.json` S019 `sha256` (`digest_observed_at: 2026-10-20`); the digest is reproducible today. Markdown alternate `https://www.1password.dev/brokered-access.md` was also opened (6,841 bytes) to read the prose without tag noise.

**Located anchor verified.** H1: “Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)”. Introduction: “…administrators can set up a supported integration in their 1Password Business account…”. Under **Add an integration → GitHub Actions** the three requirement bullets exist: GitHub.com hosting; GitHub Enterprise Server / Enterprise Cloud with data residency “aren’t currently supported”; GitHub Free organizations cannot use the integration for private-repository workflows. The lesson Gate quote (“administrators can set up a supported integration in their 1Password Business account”, 12 words) is an exact substring; the S019 row anchor and teaches field match the page.

**One concrete supported claim.** An administrator must create an integration in a **1Password Business** account before team members can connect Environments to GitHub Actions workflows, and organizations hosted on GitHub Enterprise Server / Enterprise Cloud with data residency are excluded from this integration (S019 introduction + GitHub Actions requirements).

**One scope limit.** S019 supports **setup eligibility and GitHub deployment restrictions only**. Its body does not state the custom-workflow feature’s release status, does not name EPM Business as the eligible plan (that is S020), does not state non-GitHub OIDC-provider eligibility, and does not establish credential expiry beyond the introduction’s workflow-duration sentence. The only custom-workflow status signal on S019 is shared-navigation link text “(public beta)”, which the round-22 lesson itself forbids as a status anchor.

**Status precision.** The page has no visible version or displayed date; “unversioned live docs” is accurate. Its raw HTML carries JSON-LD `dateModified: 2026-08-17T22:36:47.823Z` (machine-only; no rendered “Updated/Last updated” text). The round-22 open date is a retrieval stamp, not a content date — the lesson’s “revision stamp proves local-byte identity, not source currentness” caveat applies. Note also that, unlike S001–S016, the S017–S021 registry rows carry **no Fetch digest**; S019’s reproducible digest exists only in `feature-claims.json` and `build/Source07.md`, so the SOURCES.md row alone is a dated text claim, not a byte pin.

## 3. S017–S020 feature-specific status/eligibility, separately

| row | page/H1 status anchor | eligibility anchor | does not establish |
|---|---|---|---|
| S017 | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”; body badge “Public Preview” | “administrator has connected your GitHub organization to your 1Password Business account” | custom-OIDC status; plan-tier names beyond Business |
| S018 | H1 “…in custom workflows at runtime (public beta)”; body badge “Beta” | OIDC provider connected to Business; Step 1 “latest beta release of the 1Password desktop app”; Step 3 note “only supported in the 1Password JavaScript SDK” | GitHub Actions status; other SDKs; GA claim |
| S019 | H1 “…(public preview)” at **guide** level; body does not give custom-workflow status | Add an integration → GitHub Actions requirements (GitHub.com, Enterprise exclusions, Free/private-repo limit) | per-feature custom status; EPM Business naming |
| S020 | meta title “is now in public preview”; intro “moving Credential Broker from closed beta to public preview”; §New in this release: Actions public preview vs custom-OIDC “slowly rolling out … in beta” | “available for all Enterprise Password Manager Business customers to start using right now”; published 2026-07-28 | live per-feature status after the announce date; unlisted plan tiers |

I re-opened all four pages. The corrected active review uses them as declared: GitHub row → S017 title/introduction + S019 requirements; custom row → S018 only; custody row → S020 introduction/§New in this release + S019 setup steps; OpenBao row → S021. **No S019→custom-workflow status inference is present**; the E1/E3 errata (Actions preview + Business/exclusions; custom beta + beta app + JS SDK; no Vault↔OpenBao parity) stay inside what each page says. That is correct calibration, not a row-count proxy.

## 4. Original rows — immutable fields untouched

Registry rows `S001`–`S016` were compared line-for-line against `git show c2cab35…:corpus/SOURCES.md`: **16/16 lines byte-identical** (per-id line sha256). `S007` (the row S019 supersedes on status/eligibility only) still carries its original `opened 2026-10-19`, scope, quote and Fetch digest; no suppression, no rewrite, no reciprocal status flip. The supersession is confined to the appended round-22 lesson paragraph, the S019 row, and the active review — as stated.

## 5. C1 executable check (local, read-only)

- `python3 corpus/feature-claims.py --phase before` → **FAILED** (`false_claims=2`, `bar_failures=8`): the E1/E3-known overclaims are refused, including `BEFORE-E1-STATUS` (`reject:false-claim`), `BEFORE-E1-ELIGIBILITY` (`reject:bar-fail`), same-page-preview, cross-product and omission controls.
- `python3 corpus/feature-claims.py --phase after` → **CLEAN** (`admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0`): the four bounded controls (GitHub, custom beta, Vault lease, OpenBao TTL) are admitted.

Limit: this is a **closed-record** reviewer. Source URLs are inert metadata; no network access; “verbatim-pin” authority pins the checked-in JSON, not the live page. It demonstrates decision calibration against the recorded controls, not vendor truth.

## 6. C2 independent re-derivation

| check | observed | expectation |
|---|---|---|
| `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)` | R21-02 exact match |
| `bash corpus/sources-census.sh --selftest` | `PASS (47 cases)` | R21-03 |
| `python3 corpus/revision-audit.py --history c2cab35…` | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)` | R22-03 |
| `bash corpus/claim-ledger.sh docs` | `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0)` | R14-01 current |
| `grep -c '[^[:space:]]' corpus/stamps.tsv` | **69** | R12-03 current |
| `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | **43**, no duplicate ids | R21-04 current |

**Nine “dropped” stamps, recomputed independently** across `aea7a4301` → `e1544c194fddf1bb073b3946847b4526f326ad73`:
- first-column membership difference: **0 removed**, **7 added** (`QUALITY.md`, `SOURCES.md`, `onepassword-machine-credentials.md`, `sops-age-key-rotation.md`, `vault-openbao-token-lease-lifecycle.md`, `round-21.md`, `sources-census.sh`);
- full-row changes for existing paths: exactly **9** — `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`; each old line was replaced, not deleted;
- sorted-line diff: exactly **9** `<` lines, matching the outside reviewer’s “nine deleted diff lines”;
- `round21-migrations.json`: `removed_members=0`, `changed_stamp_records=9` with old/new hashes, `rewritten_claim_rows=5` (R12-02 29→36, R12-03 56→63, R13-01 20→23, R13-02 note only/35 retained, R14-01 21/18→24/21). Its changed-path set is **set-equal** to my measured 9.
- `historical-migrations.json` (R21-03 40→47) and `historical-correction-pins.json` (13 changed/0 removed) are separate spans ending at `e1544c1`; their old/new values verify against `git show <rev>:corpus/claim-ledger.tsv`.
- `pin-migrations-integration.json`: 63→69 stamps (6 new members, 0 removed) and 12 claim changes including R12-03 63→69, R13-01 23→25, R14-01 24/21→25/22, R21-02 16→21 rows, R21-04 39→43. Every current expectation above matches this record and the executed output.
- Historical pin integrity: `SOURCES.md` pin at `e1544c1` = `db134917…b332`, exactly the file at that revision (43 lines/14261 bytes, i.e. the pre-S017–S021 state); current pin `3ba44518…` = current file (86/19721). No hash was promoted from a fetch representation into a source fact.

## 7. Findings

**F1 — freshness, medium: S020’s recorded `sha256` is not a reproducible revision pin.** The blog page (`https://1password.com/blog/1password-credential-broker-public-preview`) recorded `55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda`. Two consecutive raw fetches today were **different from each other** (`da301051…` and `83e9fe7f…`, same 190,261 bytes, 44 differing bytes) because the HTML embeds a per-response Cloudflare email-protection token (`/cdn-cgi/l/email-protection#…`). The page content is stable: both located quotes still occur verbatim and `article:modified_time` remains `2026-07-28`. The recorded digest is therefore a single-fetch observation, not “the current bytes” and not a drift detector — exactly the “undocumented representation” caveat, but the new S020 pin is presented as an observed digest without a dynamic-representation note. By contrast S019, S017, S018 and S021 were byte-identical across two consecutive fetches and matched their recorded digests.

**F2 — calibration limit, low: S019’s JSON quotes are normalized renderings, not byte-verbatim HTML.** In `corpus/feature-claims.json`, `S019-enterprise-host` and `S019-free-private` use ASCII apostrophes and collapse link-boundary whitespace (“organizations, your team”); the live page renders “aren’t/won’t” and “organizations , your team”. The gate’s `verbatim-pin` authority is a pin to the JSON, so no reader should treat it as network-verified source text.

**F3 — anchor precision, info.** “§GitHub Actions requirements” is a descriptive anchor; the page’s actual headings are “Add an integration” with a bold “GitHub Actions” sub-label. The registry row names “Add an integration”, so the location is recoverable; no quote is misattributed.

**F4 — wording, low.** The page says Enterprise Server / Enterprise Cloud with data residency “aren’t **currently** supported”; the review row drops “currently”. The review is dated 2026-10-20 with `on-release` recheck, so this is a snapshot claim, not a permanent one — but the temporal qualifier is part of the source. Likewise the S019 row compresses the Free-plan condition into “private-repository requirements”; the active review restores “Free organizations cannot use … private-repository workflows”. No false admission follows, but the registry row alone is less precise than the review.

## 8. Proposed correction (report-only; no production edit made)

1. In `corpus/feature-claims.json` (and the build/qualifier note), classify S020’s `sha256` as a **non-reproducible single-fetch HTML digest** (or drop `sha256` for pages with per-response tokens). Keep the located quotes + `article:modified_time` as the S020 evidence. Do not let a byte change on that URL be read as semantic drift, and do not re-bless today’s digest as “the” expected value.
2. Optionally add a per-source `representation`/`stability` note for S019 and S020 (“stable raw HTML” vs “dynamic response tokens”) so a future falsifier can distinguish a content change from a token change without re-deriving it.
3. Optionally retain “currently” in the Enterprise-exclusion sentence, or mark the review row explicitly as of 2026-10-20; and state the Free-plan condition in the S019 registry `teaches` rather than compressing it to “private-repository requirements”.

## 9. Verdict

**S019 row and its round-22 usage: SUPPORTED and correctly bounded.** The page teaches exactly the Business-setup and GitHub-restriction claims the row assigns it; it is not used to determine custom-workflow status; the original S007 row is intact; the S017–S020 statuses are separately anchored; and the revision accounting reproduces the claimed zero removed members, nine replaced rows, seven added members and every current expectation. One freshness caveat remains on S020’s recorded HTML digest (F1); the S019-specific items are precision notes, not calibration failures.

## Limits / checks the parent should run after integration

- I did not run `claim-ledger.sh verify` (host-bound rows are out of scope) or any live account/vault/health/CDP probe.
- Local checks already executed: `sources-census.sh` (+`--selftest`), `revision-audit.py --history c2cab35…`, `feature-claims.py --phase before|after`, `claim-ledger.sh docs`, stamps/ledger counts, Git historical membership diffs.
- Parent re-run candidates: `bash corpus/claim-ledger.sh verify` only on non-host rows; `python3 corpus/revision-audit.py --history c2cab35…`; `bash corpus/claim-ledger.sh docs`; and a repeat two-fetch digest comparison for S017–S021 if the S020 pin is annotated.
- No installs; no host state touched. Report written read-only at the assigned scoped path.
