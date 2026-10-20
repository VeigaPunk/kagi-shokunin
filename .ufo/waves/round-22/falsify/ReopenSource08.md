# Falsify — ReopenSource08: S008 and S017–S020 (calibration and freshness)

Axes: **calibration (C1)** and **freshness (C2)**. Read-only seat; no production,
code, docs-index, git-state, host, vault/account, launcher, package-manager or
loopback/CDP operation. Public documentation GETs and the authorized local fixture
executions below only. Production files under attack were not modified; the only
worktree changes are other seats' `.ufo/waves/round-22/falsify*` artifacts.

Read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (HEAD, the measured
integration landing). Base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Frozen input manifest: `.ufo/waves/round-22/integration-manifest.json`,
sha256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
Every attacked file below matches its manifest tuple; `frozen/before/corpus/SOURCES.md`
equals the base blob `db134917…b332`, not a doctored snapshot.

## Frozen identity observed this wave

| path | sha256 | lines / bytes | manifest |
|---|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 / 19721 | match |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | 995 / 47434 | match |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | 1040 / 83655 | match |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 43 / 4440 | match |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 / 15700 | match |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | match |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 / 17770 | match |
| `corpus/lessons/round-21-verifier-spotcheck.md` | `6e4fa622ae953f343c294e3ce401303b6b6fa377e8800f9164047b08711f1ffb` | 17 / 2468 | match |

## S008 — exact URL reopened; rejection stands

- URL exactly as registered: `https://raw.githubusercontent.com/getsops/sops/main/README.rst`.
  Fetched 2026-10-20: HTTP 200, 1909 bytes, sha256
  `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440` — **exactly**
  the recorded Fetch hash, not merely a same-looking revision.
- Anchor and quote verified at the literal `Documentation` heading: “You can find the
  SOPS documentation on getsops.io” (§Documentation, URL above, opened 2026-10-20).
  The README's `Documentation` section contains only that pointer. Its one descriptive
  sentence lists formats (YAML, JSON, ENV, INI, BINARY) and backends (AWS KMS, GCP KMS,
  Azure Key Vault, HuaweiCloud KMS, age, PGP); it contains no age-recipient, key-group,
  or data-key rotation procedure. It names `age` only as a backend; no recipient
  procedure follows.
- Freshness of the rejection: the public GitHub commits API for `path=README.rst`
  returns the newest path commit `50c790bf3e03` dated 2026-05-15T12:53:29Z
  (“Fix minimum Go version in contributor docs.”), after `2905020350cc`
  (“Redirect documentation to getsops.io.”). No README revision exists between that
  state and the row's 2026-10-19 opening or this reopen; the row's flip condition
  (“an upstream README revision that restores lifecycle mechanics”) is unmet.
- Immutable row: the S008 line has sha256
  `771e4306309f71ce4a2e2d5469b3bfa2b9f4a1dff8f2e838933279422bab321b` at base,
  frozen-before and live. A full diff of frozen-before `SOURCES.md` -> live shows only
  additions: rows S017–S021, one Paths bullet, the Round-22 lead disposition, and the
  Search-log erratum. **All S001–S016 rows are byte-identical**; S006/S007 were
  superseded by new rows, not rewritten.
- Round-22 lesson usage: the erratum withdraws the space-sensitive counting expression.
  I reproduced both sides against the cited dossier: the withdrawn expression returns
  **0**; the reviewer's `grep -cE '^\|[[:space:]]*S[0-9]{3}'` returns **29**; S008 occurs
  in the dossier. “Inside the sixteen opened sources” is arithmetically correct
  (15 usable + S008; S008 remains recorded as rejected). `sops-age-key-rotation.md`
  (E2) still says the raw README “was also opened and is not cited”, and no admitted
  mechanism there rests on S008.

**Supported claim:** the upstream README contains no SOPS lifecycle procedure and only
delegates to the docs site. **Scope limit:** this rejects S008 as support for E2's
mechanics; it does not and cannot show that the docs site lacks them — S009–S011 carry
those mechanisms, and S008 was never promoted to evidence for them.

## S017–S020 — status and eligibility, each at its own feature anchor

Each page was fetched on 2026-10-20; status readings use the feature page's own
title/H1, never the shared navigation or CSS status words.

| row | exact URL | observed status anchor | observed eligibility / constraints | registry + lesson + active-review match |
|---|---|---|---|---|
| S017 | `https://www.1password.dev/brokered-access/github-actions/` | H1: “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | introduction conditions use on an administrator having “connected your GitHub organization to your 1Password Business account”; runtime delivery to GitHub Actions workflows | yes; raw HTML sha256 `937f6828…0849` reproduced twice = catalog pin |
| S018 | `https://www.1password.dev/brokered-access/custom-workflow/` | H1: “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | introduction requires a connected OIDC provider in the Business account; Step 1 requires the “latest beta release of the 1Password desktop app”; Step 3 body: “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | yes; raw HTML `d0890c11…76e5` reproduced twice = catalog pin; the page's shared nav says “public preview” three times, correctly ignored |
| S019 | `https://www.1password.dev/brokered-access` | setup guide H1 says public preview; the row deliberately admits only setup/eligibility, not a uniform status | intro: “administrators can set up a supported integration in their 1Password Business account”; Add an integration requires GitHub.com and currently does not support Enterprise Server/data residency; GitHub Free organizations won't be able to use the integration for private-repository workflows | yes; raw HTML `896c780b…4a9f` reproduced twice = catalog pin |
| S020 | `https://1password.com/blog/1password-credential-broker-public-preview` | dated announcement, 2026-07-28; not a live oracle | intro: “available for all Enterprise Password Manager Business customers to start using right now”; §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | yes as announcement-time split/eligibility; page-title/H1 “1Password Credential Broker is now in public preview” |

The two feature pages are genuinely separate: S018's own H1 is `public beta` while its
shared chrome says `public preview`; S017's own H1 is `public preview`. This is the
exact distinction the round's QA10/feature-anchor rule was written for, and the
integrated artifact applies it correctly.

## C1 decisions actually executed

Commands run from the lane root (read-only fixture form; no network):

- `python3 corpus/feature-claims.py --phase before` -> exit 1:
  10/10 bad records rejected; `false_claims=2` (BEFORE-E1-STATUS `FC-STATUS-MISMATCH`,
  BEFORE-SAME-PAGE-PREVIEW `FC-STATUS-MISMATCH`), `bar_failures=8`, `false_admissions=0`,
  `misses=0`. The two outside-verifier E1/E3 labels are among the rejects; the other
  eight are construction-rule controls: seven bar-fail (eligibility omission,
  deployment exclusions, beta-app condition, SDK scope, under-citation, unstated
  status, reverse cross-product) and one same-page status false-claim.
- `python3 corpus/feature-claims.py --phase after` -> exit 0:
  `admitted=4`, `false_claims=0`, `bar_failures=0`, `false_admissions=0`, `misses=0`
  (GitHub bounded, custom-OIDC beta bounded, Vault lease, OpenBao TTL).
- `python3 corpus/feature-claims.py --phase boundary` -> exit 2:
  `unjudgeable=3`, all `cannot-evaluate` (unknown feature/field/source), `scored=no`.
- `python3 corpus/feature-claims.py --selftest` -> `PASS cases=10`, including input
  valid/eligibility-omission/same-page-status/cross-product/under-cited/permuted-set
  and path-escape refusal.
- `bash corpus/sources-census.sh` -> `CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`,
  exactly the R21-02 ledger expectation.

**Calibration judgment:** the E1 overclaim is refused for the right reason — a
guide-level preview label cannot set custom-OIDC status, which the feature H1 fixes at
beta. The E3 overclaim is refused as `FC-CROSS-PRODUCT`: the Vault fact is cited to
S021 (OpenBao). The four admitted bounds are independently supported by the reopened
pages above, including S018's beta app and JavaScript-SDK limit. This is a closed-record
consistency/adjudication result, not an independent vendor-truth accuracy scalar; the
catalog labels are author/construction except the two outside-verifier E1/E3 findings.
No score increase is claimed or supported by this seat.

## C2 freshness — revision and migration accounting

- **Every current stamp matches current bytes**: all 69 rows of `corpus/stamps.tsv`
  were recomputed (sha256, newline count, byte count) against the worktree; 69/69
  match, 0 stale/missing.
- **Membership**: base `c2cab35` has 63 stamp members; live has 69. Exact first-column
  set difference: **0 removed**, **6 added** (`feature-claims.json`, `feature-claims.py`,
  `feature-bound-credential-review.md`, `round-21-verifier-spotcheck.md`,
  `round-22.md`, `revision-audit.py`). `python3 corpus/revision-audit.py --history
  c2cab35…` -> `CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0;
  `--selftest` -> `PASS (cases=11 failed=0)`.
- **The nine “dropped” lines are replacements, reproduced exactly**: over
  `aea7a4301` -> `e1544c194fddf1bb073b3946847b4526f326ad73`, exact path sets give
  **0 removed**, 7 added, **9 changed**. The nine changed paths are LOG, PROVINCE,
  SCORECARD, SHONEN, SKILL, `corpus/README.md`, `corpus/claim-ledger.tsv`,
  `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`.
  `round21-migrations.json` records `removed_members: []`, and each of its nine
  old/new tuples matches `git show` byte-for-byte. The five changed ledger ids are
  R12-02 (29->36 cases), R12-03 (56->63 stamps), R13-01 (20->23 round headings),
  R13-02 (note-only; expectation 35 unchanged), R14-01 (21/18->24/21 declarations):
  all five old/new full lines match git.
- **Round-22 expectation migrations are documented and current**:
  `pin-migrations-integration.json` carries R11-09 97->108, R12-03 63->69,
  R13-01 23->25, R14-01 24/21->25/22, R18-02 note-only (11), R18-03 97->108,
  R21-02 16-row->21-row, R21-04 39->43, plus new R22-01..04. The live
  `claim-ledger.tsv` values agree, and the executed R22-01/R22-02/R22-03 outputs above
  match their pinned expectations. No expectation was silently rewritten; historic
  tuples remain in `round21-migrations.json`, `historical-migrations.json`,
  `pin-migrations-integration.json` and the two round lessons.
- **No silent deletion in `SOURCES.md`**: the full frozen-before -> live diff adds only
  the five rows, one Paths bullet, lead disposition and erratum heading; no original
  row byte changed. S006/S007 supersession is stated by new rows and prose, not by
  editing the old teaching.

## One concrete supported claim / one scope limit

- **Supported:** S018's own title/H1 is `public beta`, and its Step 3 body limits
  Credential Broker to the JavaScript SDK “at this time”; the page's shared nav
  `public preview` is not the feature anchor. Verified on the live page, 2026-10-20.
- **Scope limit:** S020 is a 2026-07-28 announcement and supports only the
  announcement-time Actions-preview/custom-beta split and EPM Business eligibility.
  Its stored page digest is **not reproducible** (see F2); the anchored text is the
  verifiable object, and the row must not be used as a live status oracle or drift pin.

## Findings and proposed corrections

**F1 (low, calibration — qualifier loss in the active prose).** The live page says:
“GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud
with data residency aren’t currently supported.” (§Add an integration, GitHub Actions
requirements, `https://www.1password.dev/brokered-access`, 2026-10-20). The active
review's GitHub row drops “currently”: “Enterprise Server and Enterprise Cloud with data
residency are unsupported”. The typed catalog quote (`S019-enterprise-host`) preserves
“currently”, so no admitted decision changes. Proposed correction:
restore “currently” (or date the statement) in
`feature-bound-credential-review.md`'s GitHub row on the next editable pass; this is a
one-word calibration repair, not a new status. It changes the active-review stamp and
the docs expectation only if the file is edited.

**F2 (low, freshness — S020 digest is a one-shot capture, not a reproducible pin).**
The catalog pins S020 at `55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda`
(`feature-claims.json`; also `build/BuildQualifierGate.md`). Two plain public GETs on
2026-10-20 produced raw-HTML sha256 `36470d58a6599be15db0a83c7785560822ef83a60cf2b2494db7ba5417a3b456`
and `d7abbb464263a7aba80bdc8e29869726ac82a835cc61de1957df612c144c6a22`, both 190261
bytes; the byte difference isolates to the Cloudflare `/cdn-cgi/l/email-protection#…`
token (one varying obfuscation payload), not to article text. Both anchored S020
quotes are present. By contrast, S017/S018/S019 raw HTML reproduced the pinned digests
exactly, twice each. This does **not** prove semantic drift and must not be recorded as
such; it proves the S020 digest cannot serve as a reproducibility/drift pin. Proposed
annotation in the round lesson/falsify record: the S020 hash is a one-shot capture of a
nondeterministic representation; use the anchored text. If the JSON digest is edited,
`PINNED_SOURCES_SHA256` must be repinned and the feature gate rerun; otherwise no
production edit is needed.

**F3 (limit, not a decision defect — normalized quotes).** The S017 runtime and S019
exclusion strings use ASCII apostrophes in the typed pins where the pages render
U+2019 (`organization’s`, `aren’t`, `won’t`). This is typographic normalization, not a
semantic change; the corpus already documents the same class for S014. If “verbatim”
is meant byte-literally, annotate it; otherwise leave it.

## Limits of this attack

- The feature gate is a closed-record exact-binding reviewer: it never fetches a URL
  and cannot admit prose outside its catalog. This seat's independent page reopens are
  the source-truth check; no claim of an external calibration scalar is made.
- S021 was not independently reopened as a content source here; the E3 decision was
  checked only for product separation (S021 is OpenBao, S013 is Vault), which is what
  `FC-CROSS-PRODUCT` asserts. No Vault/OpenBao token or KV conclusion is drawn.
- I did not run `corpus/claim-ledger.sh verify` or its 108-case selftest: some ledger
  rows are host-bound and this wave forbids host-private gates. Ledger rows were read
  and their migrations matched against git; the parent may execute the isolated
  selftest if policy permits. I did not execute the 69-case census selftest.
- No W1 scribe credit is assigned: `build/Source17.md`–`Source20.md` do not exist, and
  this report rests only on its own reopens, the cited historical files and the local
  fixtures above. No depth move and no legacy-header count claim is made; `legacy=21`
  is quoted only as the census output, not as freshness or coverage evidence.
- No account, vault, deployment, live endpoint, CDP or loopback probe; no package
  manager or launcher was invoked. No installation occurred, so no install record is
  owed.

## Checks the parent should run once on the final tree

`python3 corpus/feature-claims.py --selftest && python3 corpus/feature-claims.py
--phase before; python3 corpus/feature-claims.py --phase after; python3
corpus/feature-claims.py --phase boundary` (expect 10, 4 and 3 respectively);
`python3 corpus/revision-audit.py --history c2cab35… && python3
corpus/revision-audit.py --selftest` (expect CLEAN added=6, 11 cases); `bash
corpus/sources-census.sh` and `--selftest`; optionally `bash corpus/claim-ledger.sh
--selftest` only if its fixture isolation is confirmed.

## Revision trailer

Read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
(`.ufo/waves/round-22/falsify-start.json` landing). Base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Frozen manifest: `.ufo/waves/round-22/integration-manifest.json` sha256
`31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
All attacked inputs are byte-identical to their manifest entries. Report is written at
`.ufo/waves/round-22/falsify/ReopenSource08.md` relative to
`/home/vgpnk/Projects/shokunin/kagi-shokunin`.
