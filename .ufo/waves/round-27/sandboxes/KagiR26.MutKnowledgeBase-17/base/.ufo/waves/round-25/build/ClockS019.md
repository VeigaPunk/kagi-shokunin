# ClockS019 — C3 per-row clock for S019 (Credential Broker integration eligibility)

Seat: KagiR25.ClockS019-2 (leaf scout). Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03. Sandbox clone `/fast/scratch/kagi-r25/ClockS019-2/lane` at BASE; lane tree not modified. Access date 2026-10-21. The only lane write is this file.

## Verdict
- Governing clock: `rendered-quote`. The page is an unversioned guide with no displayed version. S019's anchor names no version, and the official feed opened below does not carry S019's eligibility claims.
- Row quote locates in the fresh fetch (count=1). Clock verdict: **not-fired**.
- S019 teaches ("guide-level preview label does not determine custom-workflow status; Business setup and GitHub.com/private-repository requirements remain separate qualifiers"): **still holds**.

## Proposed release-clocks.tsv line (tab-separated)
```
id	clock	feed_url	anchored_version	observed_version	observed_at	verdict
S019	rendered-quote	https://www.1password.dev/brokered-access	unversioned	unversioned	2026-10-21	not-fired
```
Quote source: `corpus/source-fetches.tsv:46` col 13, "administrators can set up a supported integration in their 1Password Business account" (rendered-text-v1, case-sensitive).
`feed_url` on a rendered-quote row carries the checked page URL (no feed exists). `anchored_version` and `observed_version` are `unversioned`; the JSON-LD `dateModified` (E7) is a receipt field, not the clock.

## Fetch evidence
E1. `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://www.1password.dev/brokered-access`: http_code=200, wire 166493 B, decoded 1199447 B, sha256 `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312`. This equals `source-fetches.tsv:46` col 10 and col 11. A second fetch is byte-identical. Default-UA raw (`curl -sSL -A 'curl/8.13.0'`) gives the same sha; ETag `W/"z6d2q9klrgppcp"`, server Vercel.
E2. `python3 -B <sandbox>/lane/corpus/rendered-text-v1.py --selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0. Script sha256 7d6bfe81…, identical to the lane copy.
E3. `… digest <body>` → raw_sha256=67f690e2… bytes=1199447 normalized_sha256=`f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9` normalized_bytes=6049. This equals `source-fetches.tsv:46` col 15. Exit 0.
E4. `… locate <body> "administrators can set up a supported integration in their 1Password Business account"` → count=1, exit 0. Uppercase "Administrators can …" → count=0, exit 1 (case-sensitivity control).
E5. Sibling S018 (`/brokered-access/custom-workflow/`): HTTP 200, sha256 a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450 (= `source-fetches.tsv` S018 col 10). Title "(public beta)".
E6. Markdown alternate `/brokered-access.md`: HTTP 200, 6841 B, sha256 b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3. This equals the 2026-10-20 record at `.ufo/waves/round-23/parent-build/SourceS007.md:65`.
E7. JSON-LD `dateModified` on the S019 page: 2026-08-17T22:36:47.823Z. Same value as the 2026-10-20 record (`.ufo/waves/round-23/parent-build/SourceS007.md:66`).
E8. Raw-byte movement, not a fire. `corpus/feature-claims.json:149` S019 sha256 896c780b… (1,199,099 B, 2026-10-20; `.ufo/waves/round-22/falsify/ReopenSource19.md:27`; ETag `W/"11vu9hu72scpp31"`, `.ufo/waves/round-23/parent-build/SourceS007.md:64`) versus today's 67f690e… (1,199,447 B, ETag `W/"z6d2q9klrgppcp"`). [INFERENCE] Build-coupled markup changed; visible prose did not (E6, E7). The 2026-10-20 normalized digest was never recorded, so "normalized unchanged" is inferred, not measured.

## Release-identity decision (why not a feed clock)
- The guide declares no version. "(public preview)" appears as a guide-level label in the title, og:title, nav, and Learn-more link. The only machine stamp is E7.
- Official feed opened: https://releases.1password.com/ (1Password Releases). Index page 1: HTTP 200, 11730 B, sha256 0f06cb1f…. Pages 2–6 also returned HTTP 200 (sha256 fd55690f…, 015f3ed4…, b2642f47…, ec04baf1…, 82d59d5f…). Latest indexed entry: "Updated to 8.12.42 on October 20 2026" (page 1).
- "Credential Broker" occurs once in the whole index (`grep -oi 'credential broker'` count 1, page 5): "1Password JavaScript SDK 0.5.0 is now available", "Updated to 0.5.0 on July 31 2026". CLI 2.41.0 (Oct 12 2026) mentions Environments, not the Broker.
- Rejected as S019's clock: the row names no version to move past. Any feed binding would fire on every client release (8.12.42 alone) and could not say whether S019's eligibility text changed. The footer "Blog RSS" is a general blog feed; not used.

## Teaches check (SOURCES.md:25; S032 at :38)
- Guide label still "(public preview)", while the custom-workflow page says "(public beta)" (E5). The guide label does not determine custom-workflow status. Holds.
- Business setup: "administrators can set up a supported integration in their 1Password Business account" (E4). Holds.
- GitHub requirements remain a separate block under "Before you connect your 1Password Business account to your GitHub organization, review the following requirements." Holds.

## Calibration defect (pre-existing; for L1, not a release change)
`corpus/feature-claims.json:156` (S019-enterprise-host) and `:157` (S019-free-private) are verbatim to the markdown alternate (ASCII apostrophes at `.md:36-37`). They do NOT locate in the HTML under rendered-text-v1:
- ASCII "…aren't currently supported." → count=0, exit 1. The HTML uses U+2019 (10 occurrences, zero ASCII apostrophes).
- ASCII "If you use GitHub Free for organizations, your team won't …" → count=0, exit 1. Rendered text has a space before the comma ("organizations ,") because link tags become one space (`rendered-text-v1.py:27-31`).
- Located forms (count=1, exit 0): "GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren’t currently supported." and "your team won’t be able to use this integration for workflows in private repositories."
- Also located: feature-claims `:154` "a supported integration in their 1Password Business account" (count=1); `:155` "Your GitHub organization must be hosted on GitHub.com." (count=1).
- Recommendation: a row quote alone cannot fire on a new exclusion, so S019's clock should also locate the exclusion quotes, in the located forms. I did not edit feature-claims.json.

## SOURCES candidate (feed opened; not bound to S019)
```
| S0NN | 1Password Releases — https://releases.1password.com/ | docs | A | Vendor release index for 1Password client and developer-tool products; the only Broker-named entry is the JavaScript SDK 0.5.0 release, not S019 eligibility text | §1Password JavaScript SDK 0.5.0 is now available (index page 5, "Updated to 0.5.0 on July 31 2026"); latest indexed entry "Updated to 8.12.42 on October 20 2026" (page 1); opened 2026-10-21 | SDK 0.5.0 describes Credential Broker as "currently available in public preview for GitHub Actions". Quote: "Version 0.5.0 introduces support for workload identity authentication through 1Password Credential Broker, currently available in public preview for GitHub Actions." (index page 5) | mined | 2026-10-21 | on-release | — |
```
S0NN = next free id (plan reserves S033+; check at integration). Quote is 20 words.

## Other checks
- Row identity: `printf 'S019\tmined\thttps://www.1password.dev/brokered-access\n' | sha256sum` → 6b60cca671eb812e3c63332a17262231a9b8d7dff6f5f53465232aba16567f9c, equal to `source-fetches.tsv:46` col 3.
- Dating: `SOURCES.md:25` says opened 2026-10-20; `source-fetches.tsv:46` col 8 says capture 2026-10-21. Not a clock issue.
- UNRUN: `corpus/release-clock.py` and `corpus/release-clocks.tsv` do not exist at BASE (glob `corpus/release*` empty), so the C3 counting command was not run. Gate `verify`/`cells` not run (forbidden on the lane tree; not needed for this row).
- Installs/updates: none. Tools used: curl, python3, git clone (read-only), grep, one web_search (aggregator text not relied on; all facts above come from direct fetches).
