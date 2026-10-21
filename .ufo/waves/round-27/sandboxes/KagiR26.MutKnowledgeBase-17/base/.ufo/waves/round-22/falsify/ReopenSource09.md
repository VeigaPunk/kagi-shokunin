# ReopenSource09 — S009 registry row + S017–S020 feature-specific qualifiers

Seat: `KagiR22.ReopenSource09` (scout, axes: calibration + freshness). No production
writes; no account/vault/host probes; no launchers/package tools/loopback calls. Public
documentation GETs and read-only local fixture executions only. No installation occurred.
No prior `falsify/ReopenSource09.md` existed; this is a fresh independent attack, not a
W1 replacement.

## Frozen input actually read

- HEAD / measured landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
  (`master`, `origin/master`; committed `2026-10-20 19:13:44 -0300`).
- Frozen manifest: `.ufo/waves/round-22/integration-manifest.json`
  `sha256 31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
- `corpus/SOURCES.md` `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7`
  (19,721 B / 86 lines; 21 source rows).
- `corpus/lessons/round-22.md` `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4`
  (15,700 B / 192 lines).
- `corpus/knowledge/feature-bound-credential-review.md`
  `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` (4,440 B / 43 lines).
- `corpus/feature-claims.json` `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa`
  (47,434 B / 995 lines); `corpus/feature-claims.py`
  `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af`.
- `corpus/stamps.tsv` `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29`
  (7,213 B / 69 records); `corpus/claim-ledger.tsv`
  `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` (58 lines).
- Frozen before: `.ufo/waves/round-22/frozen/before/corpus/SOURCES.md`
  `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` (14,261 B / 43 lines;
  16 source rows). `git status --porcelain corpus/ plans/ …` was empty during the read.

## S009 — reopen, teaching, anchor, immutability

Exact URL reopened: `https://getsops.io/docs/usage/identities/age/` (2026-10-20).
Raw HTML: 29,301 B, `sha256 a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`,
**identical to the registry Fetch pin**. A plain GET and a gzip-decoded GET produced the
same bytes; this is a reproducible identity-encoded representation, not a point-only hash.

Observed page: `<h1>Age</h1>`, `<h2 id=encrypting-using-age>Encrypting using age</h2>`;
footer “Last modified May 15, 2026” with commit
`9b7b84e297bdabc9c78e571c1e6db43dcd69454a` (“Add page descriptions.”). All three anchor
fields in the row match.

- Teaching “Age recipients and identity lookup locations are documented; `updatekeys` can
  apply recipient additions/removals” is supported in the named section: recipients via
  `--age`/`SOPS_AGE_RECIPIENTS`, per-OS `keys.txt` lookup with overrides, and the
  `updatekeys` sentence/example.
- Supported claim (verbatim, 14 words): “It is also possible to use `updatekeys`, when
  adding or removing age recipients.” (§Encrypting using age,
  https://getsops.io/docs/usage/identities/age/, opened 2026-10-20).
- Scope limit: the page carries no data-key-rotation procedure (that is S011), no release
  or version status, and no Vault/OpenBao/Broker qualifier. “Last modified”/docs commit
  `9b7b84e` is a docs-site revision, not a SOPS product release pin.
- Round-22 lesson usage: **none**. `S009` appears nowhere in `corpus/lessons/round-22.md`;
  `used-by` remains only `corpus/knowledge/sops-age-key-rotation.md`. The lesson’s
  conservative sentence about unrepeatable raw Fetch hashes is qualified by “where the
  representation/build is unknown”; S009 is a known-representation case, so it neither
  contradicts nor launders that sentence.
- Immutability: the `| S009 |` line is byte-identical in frozen-before and current
  (`sha256 b97d9d7517be7431eda3f0d8eb2d20d5340c241857ed21299d42336d05f73477` both; line 15).

Observation-boundary caveat: the default reader resolved this URL to the Atom alternate
feed `…/age/index.xml` and returned only the title. A feed result is not evidence of page
absence or drift; the raw HTML above is the verified representation. Any “reopen” that
stops at the feed must be rejected as a false negative.

## S017–S020 — status and eligibility, per feature

Live pages reopened 2026-10-20; digests below are identity-encoded raw HTML. S017/S018/S019
reproduce their catalog pins exactly; S020 does not (see D1).

| row | own status anchor | eligibility on the feature page | deployment/SDK qualifiers | plan wording |
|---|---|---|---|---|
| S017 Actions | H1 “…GitHub Actions at runtime (public preview)”, “Public Preview” badge | “connected your GitHub organization to your 1Password Business account” (intro) | none: 0 occurrences of “Enterprise Server”/“GitHub Free” | “1Password Business account” only; no EPM string |
| S018 custom OIDC | H1 “…custom workflows at runtime (public beta)”, “Beta” badge | “If an administrator has connected an OIDC provider to your 1Password Business account” (intro); latest beta desktop app (Step 1) | JavaScript SDK only (Step 3 note) | “1Password Business account” only; no EPM string |
| S019 setup guide | guide H1 “…(public preview)” + badge — guide-level, not per-feature | “a supported integration in their 1Password Business account” (intro); GitHub.com org required | Enterprise Server and Enterprise Cloud with data residency unsupported; GitHub Free org private repos unsupported (3 occurrences each) | no EPM string |
| S020 announcement | dated 2026-07-28 (published and modified metadata, verified twice) | EPM Business (product-level) | feature split in §New in this release | “Enterprise Password Manager Business” / “EPM Business” |

Concrete supported claim: S018’s own H1 carries “(public beta)” and the page repeats the
beta desktop app and JavaScript-SDK limit — “Credential Broker is only supported in the
1Password JavaScript SDK at this time.” (Step 3 note, 15 words,
https://www.1password.dev/brokered-access/custom-workflow/, opened 2026-10-20).

Scope limit: the pages do not share one status. S019’s guide-level “public preview” title
sits on the same page as Related-topic links labelling custom workflow “(public beta)” and
Actions “(public preview)”. Whole-page substring scanning is therefore unsafe: raw counts
are S017 29×“public preview”/1×“public beta”, S018 9×/21×, S019 30×/1×. Status must be read
at the named H1/badge anchor, exactly as the lesson’s CriticAdmission note states.

Feature separation holds: S017/S018 carry zero Enterprise/GitHub Free exclusions and zero
EPM strings; S019 carries the three deployment exclusions and zero EPM strings. The
knowledge note’s attribution of exclusions to S019 and SDK/beta-app limits to S018 matches
the reopened pages. S019/S020 supersession text is registry curation, and the original
S006/S007 rows remain byte-identical (see below).

## Calibration decisions measured (not authored rows)

Local fixture executions against the frozen catalog:

- `python3 corpus/feature-claims.py --selftest` → `PASS cases=10`, exit 0.
- `--phase after` → `CLEAN phase=after admitted=4 false_claims=0 bar_failures=0
  false_admissions=0 misses=0 unjudgeable=0`, exit 0. Independently, all four admitted
  controls match the reopened pages on status, requirements, constraints and exclusions.
- `--phase before` → exit 1, `false_claims=2 bar_failures=8`, the two outside-authority
  records (`BEFORE-E1-STATUS`, `BEFORE-E3-VAULT-ONLY`) rejected as `false-claim`/`bar-fail`
  together with the eight construction controls. These are the known E1/E3 overclaims:
  guide-level preview applied to custom OIDC, and an OpenBao fact evidenced by Vault S013.
  Both rejections are correct against the live pages.
- `--phase boundary` → exit 2, `unjudgeable=3` (`FC-UNKNOWN-FEATURE`, `-FIELD`, `-SOURCE`),
  scored=no.

Independent calibration verdict: 2/2 known outside overclaims refused, 4/4 bounded controls
admitted, 3/3 unjudgeable records excluded — a decision measure, not a criteria/row count.

Inference boundary (D2, low): both Broker entries bind `eligibility.plans =
enterprise_password_manager_business` to `S020-epm-plan`. That quote is product-level
(“available for all Enterprise Password Manager Business customers to start using right
now”), while S017/S018/S019 say only “1Password Business account” and contain no “EPM” or
“Enterprise Password Manager” string. The feature-level plan for custom OIDC is therefore an
inherited product-scope reading, not a feature-page statement. I did not find a false status
or a false deployment/eligibility admission; this is a provenance label that should be
explicit, not silently presented as feature-specific evidence. Proposed correction: state
“plan tier inherited from the Broker announcement (S020)” in the catalog/knowledge note, or
downgrade the per-feature plan binding to product-scope evidence. Confidence: high on the
wording, medium on whether the vendor intends “1Password Business” as the same SKU.

## Freshness and revision accounting

Executed against the frozen tree:

- `python3 corpus/revision-audit.py --root . --history c2cab35…` →
  `CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0. I confirmed that the
  base-era six-stale state is historical (`before-runnable.json`), not this tree.
- `python3 corpus/revision-audit.py --selftest` → `PASS (cases=11 failed=0)`, exit 0.
- `bash corpus/sources-census.sh` → `CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19
  rejected=1 entries_sourced=4 legacy=21)`, matching ledger R21-02 exactly.
- Stamp membership: base 63 → current 69; added exactly
  `corpus/feature-claims.json`, `corpus/feature-claims.py`,
  `corpus/knowledge/feature-bound-credential-review.md`,
  `corpus/lessons/round-21-verifier-spotcheck.md`, `corpus/lessons/round-22.md`,
  `corpus/revision-audit.py`; **removed: none**. Ledger R12-03 `^69$` matches actual 69.
- All 38 `pin-migrations-integration.json` stamp tuples equal the `e1544c194…` stamp and the
  current worktree line; all 13 `historical-correction-pins.json` tuples equal
  `c41af82…`/`e1544c194…`. For `corpus/SOURCES.md`: old `db134917…` (43/14,261) equals the
  frozen-before/git base bytes; new `3ba44518…` (86/19,721) equals current.
- Nine-line claim rechecked against Git objects, not prose: in
  `aea7a4301 → e1544c194`, all nine changed records have `old == aea7a4301` and
  `new == e1544c1`; first-column sets are 56 → 63 with **zero removed members**; the seven
  additions are those listed by R12-03. `SOURCES.md` was not one of the nine replaced lines;
  it entered membership at `c41af82` as an addition. The lesson’s “replacements, not nine
  lost members” is therefore verified byte-for-byte.
- Immutable original rows: `git diff c2cab35… 8ada17a… -- corpus/SOURCES.md` has 43
  insertions and no content deletions; S001–S016 row lines are byte-identical to
  frozen-before (whole-row diff empty; 16 → 21 rows). S017–S020 are `docs`/`A`, `mined`,
  opened `2026-10-20`, recheck `on-release`; their `used-by` includes both
  `corpus/lessons/round-22.md` and the active knowledge note, as the lesson documents.
  Their status/recheck fields did not change after the used-by addition.

Freshness defect found (D1, low/documentation): S020’s catalog digest
`55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda` is not reproducible.
Five independent raw-HTML GETs (identity, gzip-decoded, browser UA) returned
`4f78b9b9…`, `2b09a02c…`, `46053503…`, `a78cb60f…`, `6d288a67…` at constant 190,261 B.
The only varying bytes (44) are a Cloudflare email-obfuscation token
(`/cdn-cgi/l/email-protection#…`); the article text, the split sentence and
`article:published_time`/`modified_time = 2026-07-28` are stable. Impact: the digest cannot
function as a drift pin, but it does not affect admission — `feature-claims.py` only
schema-checks 64-hex and pins the canonical catalog digest; quotes are stable and were
re-read live. Proposed correction: label S020’s digest a volatile point observation of an
undocumented representation, or replace it with quote pins; do **not** re-fetch and
silently repin it. This is a documentation/limit repair, not a source-truth claim.

## Remaining unknowns

- Whether “1Password Business account” (docs) and “Enterprise Password Manager Business”
  (announcement) are the same SKU; the four pages do not settle it. D2 stays an inference.
- The exact byte representation behind S020’s stored digest; no record names it, and no
  reproduced fetch matches it.
- S021 (OpenBao) was outside this seat’s row set and was not adjudicated here beyond the
  cross-product reject already present in the frozen catalog.

## Checks the parent should run after integration

1. `python3 corpus/feature-claims.py --selftest` and `--phase after|before|boundary`
   (expect 10 PASS; CLEAN 4 admits; exit 1 with 2 false-claims + 8 bar-fails; exit 2 with 3
   unjudgeable).
2. `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`
   and `--selftest` (expect CLEAN added=6; 11 PASS).
3. `bash corpus/sources-census.sh` (expect the R21-02 CLEAN line above).
4. Re-run `bash corpus/claim-ledger.sh --selftest` (108 cases) and the `docs` audit
   (R14-01) after any correction lands.
5. If D1 is repaired by editing `corpus/feature-claims.json`, restamp it and confirm the
   catalog canonical digest pin and R22-01/R22-02 still pass.

No live host-private gate was attempted; no QM12-safe-row substitute was executed.
