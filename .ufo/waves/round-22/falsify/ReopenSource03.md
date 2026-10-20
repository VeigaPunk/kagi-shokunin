# ReopenSource03 — S003 and S017–S020 source re-open (fresh falsify wave)

Axes: **calibration (C1)** and **freshness (C2)**.

Read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (measured integration landing; `git rev-parse HEAD`). Historical before: `c2cab35bc92e57e39e5489bac3386db078345b3f` (not the falsification input). Frozen input hashes named from `.ufo/waves/round-22/integration-manifest.json` and re-measured locally:

| input | manifest sha256 | observed |
|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` (86 / 19721) | matches |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` (192 / 15700) | matches |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` (43 / 4440) | matches |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` (995 / 47434) | matches |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (69 / 7213) | matches |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` (58 / 17770) | matches |

Method: public documentation GETs only (two representations per docs page), local fixture executions explicitly authorized for this wave. No account, vault, CLI, SDK, workflow, integration or live endpoint was used. No production file, lane/jj state, config or host gate was touched. No installs were performed.

W1 `build/Source03.md` was read as advisory only (missing/dead W1 seats stay uncredited); every finding below comes from my own re-open and executions.

## Verdict summary

- **S003 survives**: both located quotes and both `§Deployment` anchors re-resolve; the row is byte-identical to the frozen base and frozen-before rows. Its historic `Fetch sha256` does **not** reproduce against either current representation — the already-documented method/representation gap, not evidence of content change.
- **S017–S020 survive as feature-separated readings**: each status is anchored at its own page title, and eligibility is anchored separately; the setup guide's own "public preview" label is **not** bound as a status source. The typed gate rejects a status swap, an eligibility omission and a cross-product attribution built independently by me, and admits the bounded and reordered controls.
- **One new freshness defect**: S020's new catalog digest (`55bf23fe…`) is not reproducible because the blog HTML rotates per response; it is a point observation presented indistinguishably from reproducible pins. S017/S018/S019/S021 pins reproduce today's raw HTML byte-for-byte.
- **Revision accounting holds on this span**: 69 stamp rows, no duplicate paths; the nine "dropped" lines are replacements (zero removed first-column members, verified by git set difference); round-22 claim-row migrations carry exact old/new values.

## S003 — independent re-open

URL: `https://www.1password.dev/connect/get-started` (public docs, no account). Both fetches HTTP 200 on 2026-10-20 ~22:15Z.

| representation | bytes | sha256 | notes |
|---|---|---|---|
| markdown alternate `/connect/get-started.md` | 14,652 | `66831901561602872d7dba73a4a0ed52fd374d6a6f62fb823ae4a78be17092c6` | byte-identical across two fetches; `last-modified` equals request time (not a content stamp) |
| raw HTML | 1,369,361 | `0daffd88fb69359d0fe6947f6521c45f0a11224ec16edbdc72ad5a9dad44a451` | weak ETag `W/"97ausnh5grtcet"`, `no-store`; no content `Last-Modified` |

Anchors (markdown-alternate line numbers): `## Deployment` line 33; `### Step 1: Create a Secrets Automation workflow` line 37; `### Step 3: Set up applications and services to get information from 1Password` line 211.

Located quotes (each ≤25 words):

| heading | line | quote | verdict |
|---|---|---|---|
| §Deployment → Step 1 | 41 | “credentials necessary to deploy 1Password Connect Server” | verbatim |
| §Deployment → Step 3 | 213 | “Create a new token for each application or service you use.” | matches rendered text; link markup sits mid-sentence, so a raw-bytes grep for the whole sentence fails |

Teaching: ACCEPT. Step 1 creates `1password-credentials.json` for deployment plus an access token for applications/services; Step 3 instructs a new token per application or service. The row's scope “Connect deployment credentials versus client API tokens” is supported.

Immutability: `git show c2cab35…:corpus/SOURCES.md` line 9 and current `corpus/SOURCES.md` line 9 are byte-identical (`diff` empty); the frozen-before row is also identical. The base→current `SOURCES.md` diff has **0 deletions** and only added lines. S003's `used-by` remains exactly `corpus/knowledge/onepassword-machine-credentials.md`; `corpus/lessons/round-22.md` does not cite S003.

Round-22 usage: the only S003-dependent prose is E1 item 3. Its final sentence (“…therefore occupy different custody boundaries [S003]”) is now explicitly labeled `[INFERENCE]` in the appended round-22 bounds of `onepassword-machine-credentials.md`, with S003 credited only for different artifact roles and the per-application recommendation. That is correct: S003 does not state a custody boundary. The historical body is preserved, not rewritten — consistent with the append-only rule.

Freshness of the row's embedded pin: claimed `7f6d3b49ac3019073c37360c4771ebad2bad43a0f87ce314eb94bb0e0debe7ff` matches neither representation above. The HTML carries machine-readable `WebPage` `dateModified: 2026-10-19T21:23:28.013Z` (observed; not displayed, and its status as a batch-build rather than editorial date is `[INFERENCE]` from the sitemap clustering reported ad hoc in W1, not independently remeasured here). The row's “current page has no displayed version/date” is literally true. The corpus's own global statement — existing Fetch hashes are historic point observations with unrecorded representation, not drift pins — explains the mismatch; it does not make the pin reproducible. No basis exists to call the teaching changed.

### Concrete supported claim (S003)

“S003 §Deployment Step 1 states the credentials file ‘contains the credentials necessary to deploy 1Password Connect Server’, and Step 3 instructs ‘Create a new token for each application or service you use’.” Both verified at lines 41 and 213 on 2026-10-20.

### Scope limit (S003)

Step 3 is a recommendation, not an enforcement or isolation statement: the page does not define per-token permission scope, cannot establish per-application identity, and does not state automatic expiry. “Per-application API tokens” must not be upgraded into enforced separation; the E1 custody-boundary sentence correctly stays `[INFERENCE]`.

## S017–S020 — feature-specific status and eligibility, separately

Each status anchor is the feature page's own title/H1; eligibility is a separate span. All quotes below ≤25 words. Raw-HTML digests equal `corpus/feature-claims.json` `sources[].sha256` exactly for S017/S018/S019 (verified today).

| source | status anchor and verified text | eligibility anchor and verified text | catalog binding check |
|---|---|---|---|
| S017 | H1 `…GitHub Actions at runtime (public preview)`; body label `Public Preview` | introduction: “connected your GitHub organization to your 1Password Business account”; runtime in same paragraph | binds `release_status=public_preview` to `S017-title`; requirement to `S017-business` |
| S018 | H1 `…custom workflows at runtime (public beta)`; body label `Beta` | introduction OIDC provider connected to the Business account; Step 1 “latest beta release of the 1Password desktop app”; Step 3 note “only supported in the 1Password JavaScript SDK at this time.” | binds `release_status=public_beta` to `S018-title`; beta app / JS SDK to their own anchors |
| S019 | H1 carries `(public preview)` and a `Public Preview` label, but **no status binding exists in the catalog for S019** | introduction “a supported integration in their 1Password Business account”; GitHub requirements: GitHub.com only, Enterprise Server / Enterprise Cloud with data residency unsupported, Free orgs cannot use private-repository workflows | S019 binds only product/feature/path/eligibility, never release status — the guide label cannot leak into custom-OIDC status |
| S020 | §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | introduction “available for all Enterprise Password Manager Business customers to start using right now”; `published_time` meta 2026-07-28 | binds both statuses to the split sentence, plans to the EPM sentence; headline “now in public preview” is not used as a uniform status |

The E1 conflation class is therefore handled structurally: custom OIDC status comes from `S018-title`, never from S019's guide-level label or S020's headline. The E1 eligibility omission is handled by `eligibility.plans`/`requirements`/`documented_exclusions` with per-facet evidence sets.

### Independent gate probes (not authored fixtures)

I executed the integrated gate, then built my own typed inputs under a private clone (`/tmp/kagi-r22-ReopenSource03/root`, unchanged catalog):

| probe | result |
|---|---|
| `feature-claims.py --selftest` | exit 0, `PASS cases=10` |
| `--phase before` | exit 1, 10 decisions: `false_claims=2 bar_failures=8 false_admissions=0 misses=0` |
| `--phase after` | exit 0, `admitted=4`, all error counters 0 |
| `--phase boundary` | exit 2, `unjudgeable=3` |
| my input: custom OIDC `public_preview` against `S018-title` (beta) | exit 1, `reject:false-claim`, `FC-STATUS-MISMATCH` |
| my input: same bounded claim with plans/requirements and their evidence removed | exit 1, `reject:bar-fail`, `FC-ELIGIBILITY-QUALIFIER` |
| my input: OpenBao TTL claim with Vault `S013` evidence | exit 1, `reject:bar-fail`, `FC-CROSS-PRODUCT` |
| my input: unknown quote id | exit 2, `CANNOT_EVALUATE`, `FC-UNKNOWN-QUOTE` (fail-closed) |
| my input: exact bounded control | exit 0, `ADMIT` |
| my input: bounded control with evidence sets reordered | exit 0, `ADMIT` |

QM13 caveat: these are typed-record outcomes against pinned anchors, not vendor truth; the four admits are not an accuracy scalar.

### Concrete supported claim (S017–S020)

“S017's title says GitHub Actions is public preview and its introduction conditions use on an administrator having connected the GitHub organization to a 1Password Business account; S018's title says custom workflows are public beta and its Step 3 note limits Broker to the JavaScript SDK.” Verified 2026-10-20; status and eligibility are carried by separate anchors.

### Scope limit (S017–S020)

The plan token `enterprise_password_manager_business` comes from S020's “Enterprise Password Manager Business customers”; S017–S019 say “1Password Business account”. No opened page states those two commercial names are the same plan. The catalog keeps them mechanically separate (plan evidence only from S020; “business account connected” is a requirement from S017/S018/S019), so the reading is bounded — but the plan identity is a curation inference and should be labeled `[INFERENCE]`, not presented as quoted vendor text.

## Freshness and revision accounting

### Pins and membership

- `corpus/stamps.tsv`: 69 non-blank rows, no duplicate first-column paths. Exact match for every file named in this report: `SOURCES.md` `3ba44518…`/86/19721; `onepassword-machine-credentials.md` `95d5b58d…`/80/9048; `feature-bound-credential-review.md` `0d186f58…`/43/4440; `lessons/round-22.md` `f88d0d7e…`/192/15700; `vault-openbao-token-lease-lifecycle.md` `f633d004…`/158/11319.
- `bash corpus/sources-census.sh`: exit 0, `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`.
- `python3 corpus/revision-audit.py --history c2cab35…`: exit 0, `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`; the six additions are the five new round-22 artifacts plus the outside-verifier lesson.
- Round-22 claim-row migrations are preserved with exact old/new values in `.ufo/waves/round-22/pin-migrations-integration.json` (`claim_changes`, 12 entries), including `R21-02` `rows=16 … entries_sourced=3` → `rows=21 … entries_sourced=4`, `R11-09`/`R18-03` 97→108, `R12-03` 63→69, `R13-01` 23→25, `R14-01` 24/21→25/22, `R21-04` 39→43, and note-only `R18-02` (expectation 11 unchanged). No silent expectation rewrite was found on this span.

### Nine previously reported "dropped" lines

Independent git comparison, `aea7a4301` → `e1544c194fddf1bb073b3946847b4526f326ad73`:

- 9 removed lines and 16 added lines in `corpus/stamps.tsv`;
- first-column **set** difference: 0 removed members, 7 added members (`onepassword-machine-credentials.md`, `sops-age-key-rotation.md`, `vault-openbao-token-lease-lifecycle.md`, `lessons/round-21.md`, `QUALITY.md`, `sources-census.sh`, `SOURCES.md`);
- row counts 56 → 63; the nine old lines are same-path replacements, matching `round21-migrations.json` (`removed_members: []`, 9 changed records);
- `e1544c194` stamp bytes are identical to the round-22 base `c2cab35` (0 changed lines), then current membership is 69 with `removed_members: []`.

So the "nine dropped stamps" reading is a changed-line count, not nine lost members. The migration artifact's zero-removed claim is accurate; no silent deletion or laundering found.

### New source pins: reproducible except S020

| source | catalog sha256 | today's raw HTML | match |
|---|---|---|---|
| S017 | `937f6828883599d23c736ae8df57daaa60fd30295c3a300b226caa4ceed10849` | same | yes |
| S018 | `d0890c11edaa85d3ec68680d8d9bc867db502229fb3c815ee6b1b62ac62b76e5` | same | yes |
| S019 | `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` | same | yes |
| S021 | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` | same | yes |
| S020 | `55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda` | differs every fetch | **no** |

S020 detail: five fetches across default, research and Chrome user agents all returned 190,261 B but five different digests (`acfb247d…`, `0917235…`, `962ad94…`, `ac25a10…`, `157bd8b0…`). First differing bytes between two fetches are Cloudflare email-protection href tokens (offset 68,525), while byte length and all three quoted content spans stay present in every response. The catalog digest is therefore a one-shot observation of rotating edge HTML — not a reproducible byte pin, and not evidence the article changed.

## Findings

| id | axis | severity | finding | proposed correction |
|---|---|---|---|---|
| F-RS03-1 | freshness | low | S003's inline `Fetch sha256` (`7f6d3b49…`) matches neither current markdown nor HTML; representation unrecorded. The corpus explains this globally; it does not make the pin reproducible, and it must not be read as drift. | Append a registry-level representation note (or mark the inline digest “historic, non-reproducible”) at the next non-frozen edit. Do not restamp and call the source current. |
| F-RS03-2 | freshness | medium | S020's **new** catalog digest `55bf23fe…` is unverifiable because the blog HTML rotates per response; it is indistinguishable in `feature-claims.json` from reproducible HTML pins. The corpus's “earlier Fetch hashes” caveat does not name this new pin. | Add a source-level `digest_stability`/note for S020: point observation of rotating edge HTML (Cloudflare email-protection tokens), anchors/quotes are the stable evidence; do not use it as a drift detector. Optionally pin a normalized-text digest instead. |
| F-RS03-3 | calibration | low | `enterprise_password_manager_business` (S020) vs “1Password Business account” (S017–S019) is a plan-identity inference not stated by any opened page. Mechanically separated in evidence sets, so bounded. | Label the identity `[INFERENCE]` in the feature-review limits or the active review header. |
| F-RS03-4 | calibration | positive | Independent inputs confirm the gate rejects status swap (`FC-STATUS-MISMATCH`), eligibility omission (`FC-ELIGIBILITY-QUALIFIER`) and cross-product attribution (`FC-CROSS-PRODUCT`), admits bounded/reordered controls, and fails closed on unknown quote ids. S019 carries no release-status binding. | None. Do not count the four admits as an accuracy scalar (QM13). |
| F-RS03-5 | calibration | informational | S003's Step 3 quote is rendering-normalized across link markup; the rendered sentence matches, but raw-byte sentence greps fail. | No row change needed; any byte-level citation checker must normalize link markup. |

## Limits

- Opened: S003 (two representations), S017/S018/S019 (markdown + raw HTML), S020 (raw HTML, five fetches), S021 (raw HTML) plus their in-page anchors. No account, vault, workflow, SDK, integration, CLI or API call; no live host gate.
- S020's rotation is observed from this host across default, research and Chrome user agents; a different edge could serve the author's exact bytes, but reproducibility is not demonstrated and the per-response token change is observed.
- S003's historic digest method is unknown; content change and method change cannot be distinguished from today's bytes. No drift conclusion is drawn.
- Typed-gate outcomes are representation/anchor matches, not vendor-truth verification; the `before`/`after`/`boundary` counts are not calibration by themselves.
- No build/lint/test run beyond the explicitly authorized local fixture gates recorded above. Parent should re-run `bash corpus/sources-census.sh`, `python3 corpus/revision-audit.py --history c2cab35…`, `python3 corpus/feature-claims.py --selftest`, and the three phases after any further integration; the observed values here are from read revision `8ada17a5…`.
- No installs; no production files written. Scratch clone: `/tmp/kagi-r22-ReopenSource03`.

Report: `.ufo/waves/round-22/falsify/ReopenSource03.md`
