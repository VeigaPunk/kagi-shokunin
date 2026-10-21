# ClockS007 — C3 per-row release clock for SOURCES row S007

Seat: ClockS007-2 (leaf scout, no subagents). Date: 2026-10-21.
BASE: `4587c61a348e4528717404a68912c373f3ef4d03` (sandbox clone
`/fast/scratch/kagi-r25/ClockS007/lane`, contract `git clone --no-hardlinks` +
checkout, exit 0). All commands run `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`.
No tools installed (none needed). Lane tree untouched; fetch artifacts only in sandbox.

## Row under clock

- `corpus/SOURCES.md:13` — S007: "Set up 1Password Credential Broker … —
  https://www.1password.dev/brokered-access | docs | A | Public-preview workflow
  identity verification, configured-claim matching, workflow-duration access, and
  integration-key handling | … current page has no displayed version/date, opened
  2026-10-19 | … | mined | 2026-10-19 | on-release | corpus/knowledge/onepassword-machine-credentials.md"
- `corpus/source-fetches.tsv:60` — S007: HTTP 200, fetch sha256
  `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312`, 1199447 bytes,
  body-kind `decoded-http-body-volatile-v1`, quote "only remain accessible for the
  duration of the workflow", rendered-text-v1, rendered sha
  `f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9`,
  location "introduction (public preview guide)".
- Reading superseded by S019/S032 (`corpus/SOURCES.md:19,32,48`); row preserved.

## Clock identity: (b) unversioned live docs → `rendered-quote`

Facts observed:
1. Page displays no version number or date (`corpus/SOURCES.md:13` anchor; re-confirmed
   in fresh body — no version header in rendered text).
2. Fetch row declares `decoded-http-body-volatile-v1` (`source-fetches.tsv:60`): the
   body is expected to change without any release event.
3. No changelog/release feed is linked from the page body (grep `changelog|release|version|published`
   over body.html: only feature-flag JSON and JSON-LD hits, no feed href).
4. Probe: `curl -sS --compressed -A <contract UA> -o /dev/null -w '%{http_code}' https://www.1password.dev/changelog`
   → `404 https://www.1password.dev/changelog` (exit 0). No portal changelog exists.
5. GitHub releases API probe → 403 (rate-limited; no public docs repo release feed
   applies to this page). Not pursued — no versioned identity exists to bind.
6. JSON-LD metadata in the body carries `"dateModified":"2026-08-17T22:36:47.823Z"`
   (body.html:145) — page-level metadata, not a product/doc-set version; does not
   upgrade this to a feed clock.

Verdict: no official release feed governs this page; clock = `rendered-quote`.

## Fetch evidence (fresh, 2026-10-21)

```
curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' \
  -o body.html -w 'HTTP:%{http_code} bytes:%{size_download}' \
  https://www.1password.dev/brokered-access
→ HTTP:200 bytes:166493 url:https://www.1password.dev/brokered-access  EXIT:0
sha256sum body.html
→ 67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312  body.html  (1199447 B)
```
Raw sha256 and byte size are **identical** to `source-fetches.tsv:60` — the page is
byte-for-byte the recorded fetch (same-day refetch on the volatile body).

Normalizer (`corpus/rendered-text-v1.py:16-56` definition, `:59-66` usage):
```
python3 <sandbox>/corpus/rendered-text-v1.py --selftest
→ RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)   EXIT:0
python3 <sandbox>/corpus/rendered-text-v1.py digest body.html
→ RENDERED_TEXT_V1: raw_sha256=67f690e2… bytes=1199447
  normalized_sha256=f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9
  normalized_bytes=6049                          EXIT:0
```
Rendered digest matches the row's `f3861c17…` exactly.

## Quote location (locate, steps 5-6 normalization)

| quote | result | exit |
|---|---|---|
| "only remain accessible for the duration of the workflow" (row quote, introduction) | count=1 | 0 |
| "All configured claims must match" (§Custom Workflow (OIDC)) | count=1 | 0 |
| "The token value is your integration" (S032-corrected, §GitHub Actions) | count=2 | 0 |
| "the token value is your integration key" (S007's original lowercase) | count=0 | 1 |
| "public preview" (title/introduction label) | count=7 | 0 |

The count=0/exit 1 on the lowercase variant reproduces the round-24 recovery finding
(`SOURCES.md:56`): S007's inline quote was superseded by S032's case-correct
quotation; the preserved row's fetch-table quote (workflow-duration) is the clock's
bound quote and it locates.

## Proposed release-clocks.tsv line

```
S007	rendered-quote	https://www.1password.dev/brokered-access	-	-	2026-10-21	not-fired
```
- clock `rendered-quote` (unversioned live docs; feed probes 404/403 above).
- feed_url = observed page URL (the quote's fresh fetch target).
- anchored_version `-` / observed_version `-` (no displayed version; JSON-LD
  dateModified=2026-08-17 recorded here as context only).
- verdict `not-fired`: bound quote locates count=1, exit 0, on 2026-10-21.

## Verdict on S007's teaches

**Holds.** All four taught mechanisms re-verify on the byte-identical fresh page:
public-preview label (count=7), configured-claim matching (count=1),
workflow-duration access — the bound quote (count=1), integration-key handling
(S032-corrected sentence, count=2). No content change since the recorded fetch:
raw sha256, size, and rendered digest all match exactly. Nothing fired; no
re-verification of a new release needed; the S019/S032 supersession of S007's
*reading* is unaffected.

Feed SOURCES candidate: none — no feed was opened that passes tier-A (probes
returned 404 and 403; no feed governs this page).
