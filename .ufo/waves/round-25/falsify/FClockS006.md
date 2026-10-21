# FClockS006 — C3 falsify, row S006 (seat KagiR25.FClockS006-4, 2026-10-21)

Frozen candidate 82745e2c60e726b49499b8f309529935dc4eff2b (rev-parse verified after checkout).
Sandbox /fast/scratch/kagi-r25/FClockS006-4/lane (lone clone --no-hardlinks); every command under
`env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS006-4/home`; python3 -B +
PYTHONDONTWRITEBYTECODE=1 (no pycache written). No tools installed (none needed); pacman
untouched. Public feeds/pages only; no credentials, vault/op/handler/CDP contact.

Axes: 1 calibration (frozen TSV cells vs live observation), 2 operability (declared
quote/profile reproduce from the committed tooling), 3 freshness (anchor rationale: dated
unversioned announcement, no feed governs it; drift hunt).

## Frozen rows read
- corpus/release-clocks.tsv:3 (S006): `rendered-quote - - - - 2026-10-21 quote-located`, note
  "dated vendor announcement (published 2026-07-28); no release feed governs it". Not a feed
  clock, so R25-C8's derived-anchor counting does not apply; counted in the clone: 15
  `derived:` rows of 18 `feed` rows — matches the round-25 lesson claim; S006 is neither.
- corpus/source-fetches.tsv:59 (S006): mined; fetch sha256 0324a9f5…6d5f1; URL
  https://1password.com/blog/1password-credential-broker-public-preview; HTTP 200; profile
  curl-fsSL-compressed-v1; 2026-10-21; decoded-http-body-volatile-v1; normalized digest
  fe37e1f3…4901e7; 190261 B; capture quote (field 13) "unlike a service account token that
  carries standing access, the organization-wide integration key is an encryption key";
  rendered-text-v1; normalized quote digest 20b4fd86…1804f; anchor §How 1Password Credential
  Broker works.
- corpus/SOURCES.md:12: tier A docs row; quotes "…is an encryption key" (§How it works) and
  "is in public preview" (§Try Credential Broker today); fetch sha256
  39a869df…14c1f opened 2026-10-19 (older capture of the same volatile body — see below);
  on-release; S020 supersedes S006's scope (SOURCES.md:26, supersession paragraph at 96-99).

## Re-open (independent, 2026-10-21)
`curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o blog.html <url>`
→ exit 0, HTTP 200, wire 39037 B; decoded body 190261 B, sha256
fd9413a948bf03fa03fcec2f83e9cffde80dc1f5fdf3c74f081498f5390ba327.
- `python3 -B corpus/rendered-text-v1.py digest blog.html` → exit 0,
  `normalized_sha256=20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f
  normalized_bytes=9530` — IDENTICAL to the frozen TSV normalized digest; page text unchanged.
- locate exit 0 (count=1) for: the declared capture quote, "is in public preview", and both
  anchor headings. Normalized-text offsets: How-heading@1411 < capture-quote@2429 <
  Try-heading@7317 < preview-quote@7383 → each quote sits under its declared anchor.
- Volatile-vs-semantic: four distinct decoded-body sha256 across captures (0324a9f5 tsv,
  2960a5fc frozen observe receipt, 97aa35bc prior ClockS006 seat, fd9413a9 mine), same
  190261 B length, one normalized digest → byte volatility only, no semantic drift.

## Semantic status (drift a quote-clock cannot see)
- article:published_time == article:modified_time == 2026-07-28T00:00:00.000Z (unmodified).
- "public preview" ×13; "generally available" ×0; the single /\bGA\b|general availability/
  hit is a GA4 cookie form label — irrelevant.
- `grep -cE 'Credential Broker v?[0-9]+\.[0-9]+' blog.html` → 0: the product is unversioned;
  independently confirms no version anchor exists to bind.
- releases.1password.com → exit 0, HTTP 200, `<title>1Password Releases</title>`,
  `grep -ci 'credential broker'` → 0 → independently re-confirms the note's
  "no release feed governs it" (binding the app-release hub would be a scope mismatch).
- Live setup docs https://www.1password.dev/brokered-access → exit 0, HTTP 200, still
  "public preview" ×34 and links this exact post ×2 — external status corroboration.

## Clock-semantics cross-check
corpus/release-clock.py:126-151 `parse_captures` reads quote+profile from source-fetches.tsv
fields[12]/[13] — the registry `teaches` markup is never located (R25-C7, as claimed);
:356 LOCATE_PROFILES = ("rendered-text-v1", "raw-literal-v1"); :617-629 normalizes the page
and substring-locates collapse_quote(quote) — exactly what I reproduced with the committed
normalizer. Frozen receipt .ufo/waves/round-25/observe-1.json (28 observations, failed=0):
S006 verdict quote-located, http 200, located true, observed_at 2026-10-21T11:31:48Z.
My independent run reproduces the verdict.

## Does the surviving quote support the teaching? YES
corpus/knowledge/onepassword-machine-credentials.md:16,25 cites S006 for exactly the quote's
claim: the integration key is an encryption key, not a standing Service Account token, plus
public-preview status. The quote locates inside §How 1Password Credential Broker works on the
served page today, and the status text still appears 13×.

## Verdict: PASS
Current observation matches the frozen TSV (normalized digest byte-equal, verdict reproducible
from the committed tool); the rendered-quote/no-feed anchor rationale is verified by probes;
the teaching is supported; no production file touched; no install performed.

## Falsifier attempt and limits
- Falsifier sought: a preview→GA page flip that spares the capture quote (the one edit class a
  single-quote rendered clock cannot fire on). Not found: 0 GA strings, 13 preview strings,
  modified_time == publish date.
- Scope limit, by design rather than row defect: rendered-quote binds no version and exactly
  ONE declared quote; if the vendor flipped to GA while leaving the capture quote intact,
  S006's clock stays quote-located and the status half of SOURCES.md:12 goes stale unobserved.
  The registry already routes around this: S020 supersedes S006's scope (SOURCES.md:26) and
  the live status oracle duty sits with S019/S017/S020 (SOURCES.md:96-99); "is in public
  preview" is deliberately not the capture quote.
- UNRUN: exhaustive enumeration of every possible 1Password feed URL — my probes plus the
  prior seat's 8 remain probe-bounded, not exhaustive; no authenticated API used (none needed;
  unauthenticated GitHub REST is quota-dead on this egress per round-25 lesson).

Report: .ufo/waves/round-25/falsify/FClockS006.md
