# ClockS020 — round 26 C1 freshness re-verification of S020

Seat `KagiR26.ClockS020` · observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`, exit 0; commit time 2026-10-21T10:16:34-03:00) · observed 2026-10-21 13:36:41–13:36:42 UTC · sandbox `.ufo/waves/round-26/sandboxes/ClockS020/` (`body-{1,2}.html`, `headers-{1,2}.txt`). Production files were read only. No tools were installed and no build, lint, test or formatter was run.

## Verdict (bounded)
- **The S020 clock did not fire.** `corpus/release-clocks.tsv:17` (`S020 rendered-quote - - - - 2026-10-21 quote-located`) still holds for its one clocked quote. Today's capture reproduces the registered normalized digest byte for byte.
- **The teaching still holds as an announcement-time reading.** Both feature-claim quotes (`S020-epm-plan` and `S020-status-split`, `corpus/feature-claims.json:181-182`) locate exactly once. The article's publication and modification metadata still say 2026-07-28, and no update note was observed. This confirms the dated announcement text only. It is not a live-status check of Credential Broker features (that belongs to S017/S018).
- **There is no Python involvement.** S020 is a 1Password blog post, so the Python 3.15.1 drift (S027/S028) is out of scope for this row. No Python documentation was fetched.
- **The source is docs-only and has no feed.** The clock is `rendered-quote` with `feed_source_id`/`feed_url` = `-`. A release feed could not move this clock, and an in-place page edit is caught only if it alters the one clocked sentence (see counterexample 1).

## Source anchors and located quotes (each ≤25 words)
URL `https://1password.com/blog/1password-credential-broker-public-preview`, accessed 2026-10-21.

| quote id | anchor in rendered text | quote | `rendered-text-v1 locate` |
|---|---|---|---|
| S020-status-split (the clocked quote, `source-fetches.tsv:47` col 13) | "New in this release: Custom OIDC workflows" heading | "Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows." | count=1 |
| S020-epm-plan | unheaded introduction, just before "How 1Password Credential Broker works" | "available for all Enterprise Password Manager Business customers to start using right now" | count=1 |

The surrounding introduction text reads "Today, we're moving Credential Broker from closed beta to public preview, …", with byline "by Jeff Malnick July 28, 2026". Neither "generally available" nor "general availability" occurs on the page (both count=0), so the page does not announce a status change to GA.

## Fetch and digest evidence
Command (the declared `curl-fsSL-compressed-v1` profile, run twice):
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D headers-N.txt -o body-N.html <url>`

| capture | HTTP | final URL | decoded B | raw sha256 | rendered-text-v1 normalized sha256 (bytes) |
|---|---|---|---|---|---|
| registered (`source-fetches.tsv:47`) | 200 | same | 190261 | `53dfeac5…` | `20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f` |
| GET1, Date 13:36:41 GMT | 200 | same | 190261 | `e9ccc40340b47e737f69efdb6151eb0b68b377c0dfcc8e4dcacf63fd606cc556` | `20b4fd86…` (9530) |
| GET2, Date 13:36:42 GMT | 200 | same | 190261 | `9772a94ff89ea77e35eaf754f2472a94a6e431ce1a2bd6c65c83f0fa41651166` | `20b4fd86…` (9530) |

- Digests come from `python3 corpus/rendered-text-v1.py digest body-N.html`, run against BASE's normalizer as a read-only probe on sandbox bytes.
- Headers on both GETs: `content-type: text/html; charset=utf-8`, `cache-control: public, max-age=0, must-revalidate`, `cf-cache-status: DYNAMIC`, `server: cloudflare`, `age: 62`. Neither ETag nor Last-Modified was observed.
- Page metadata: `article:published_time` = `article:modified_time` = `2026-07-28T00:00:00.000Z`.
- The raw bodies differ in 44 bytes (offsets 68525–68568), all inside the footer link `/cdn-cgi/l/email-protection#<hex>` ("Privacy support"). This is the per-response Cloudflare token already documented as `decoded-http-body-volatile-v1` (round 23 lesson; round 25 `ClockS020.md`). Raw digests are therefore never cross-capture comparable.

## Receipt continuity (no historical receipt was rewritten)
- Round 25 receipt `.ufo/waves/round-25/observe-1.json` (sha256 `b74c8ee3…`), S020 record: `located: true`, `verdict: quote-located`, `observed_at 2026-10-21T11:31:52Z`, raw sha256 `6a6bace8…`. Read only.
- Round 26 receipt `.ufo/waves/round-26/observe-1.json` (sha256 `9a1cefec…`), S020 record: `located: true`, `verdict: quote-located`, `observed_at 2026-10-21T13:36:35Z`, raw sha256 `c701c602…`.
- `observe-run.json` lists RECEIPT-MISMATCH only for S027 and S028. That is consistent with S020 passing `receipt_matches` (`corpus/release-clock.py:400-406`). The receipt `sha256` field hashes the raw body (`release-clock.py:724`), so its differences across the three captures are expected volatility, not drift.

## Actionable counterexamples and limits
1. **Single-locator blind spot (open, already named in `corpus/README.md:192`).** The `rendered-quote` path reads only column 13 of `source-fetches.tsv` (`release-clock.py:533-543`), which is the status-split sentence. `S020-epm-plan` backs `eligibility.plans` for both `op_cb_github_actions` and `op_cb_custom_oidc` (`feature-claims.json:193-194`, :242, :269, :458), but no clock observes it. If the vendor edited the eligibility sentence (for example, widening it beyond EPM Business) and left the split sentence intact, the clock would stay `quote-located`. I checked it by hand this round (count=1), but that is a one-off observation, not a binding. The fix belongs to L1: a second declared locator for S020, or a superseding row.
2. **A quote-located verdict does not mean the feature status is unchanged.** The page is a dated announcement. A later change of Actions or custom OIDC to GA would leave this text as it is, and that change must be caught by the S017/S018 clocks. S020 teaches announcement-time status only.
3. **The normalized digest is chrome-sensitive.** It matched today, but a site-wide header or footer change would change `20b4fd86…` without any teaching change. Treat a future mismatch as "re-locate", not as drift.

## Inspected scope
I inspected only S020: its `SOURCES.md` row (line 26), `release-clocks.tsv:17`, `source-fetches.tsv:47`, `feature-claims.json` S020 quotes and claim bindings, the S020 records in the round 25 and round 26 receipts, the `rendered-quote` logic in `release-clock.py`, and two live GETs of the single registered URL. I did not fetch the 1Password blog feed (`/blog/index.xml`), because the row declares no feed clock; round 25 `ClockS020.md` holds the last feed scan. I did not cover the whole page beyond the two quotes and the absence of GA wording.
