# ClockS006 — C3 per-row clock for SOURCES row S006 (seat KagiR25.ClockS006-2, 2026-10-21)

BASE 4587c61a348e4528717404a68912c373f3ef4d03. Sandbox: /fast/scratch/kagi-r25/ClockS006
(lone clone of the lane, checked out at BASE). All fetches:
`curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)'`, run under
`env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`. Normalizer: committed
`corpus/rendered-text-v1.py` (header read first; digest+locate modes per its Usage).
No tools installed this wave (none needed); pacman untouched.

## Row read
- corpus/SOURCES.md:12 — S006: 1Password Credential Broker public-preview announcement,
  https://1password.com/blog/1password-credential-broker-public-preview, docs, tier A,
  anchor "§How 1Password Credential Broker works and §Try 1Password Credential Broker today;
  published 2026-07-28", recheck `on-release`. Note: SOURCES.md:26 S020 supersedes S006's
  scope (same URL), and SOURCES.md:77-78 states supersession keeps S006's row intact as
  dated context.
- corpus/source-fetches.tsv:59 — status 200, fetched 2026-10-21, decoded body
  fe37e1f3ef4465fe2aa420b4c4bfbc278c7f6747887ddc272fa9ea246e4901e7, 190261 bytes, marked
  `decoded-http-body-volatile-v1`, rendered digest 20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f,
  quote anchored §How 1Password Credential Broker works.

## Re-open (2026-10-21)
Command: `curl -fsSL --compressed -A ... -w 'HTTP_STATUS=%{http_code} SIZE=%{size_download}' -o blog.html <url>`
→ `HTTP_STATUS=200 SIZE=38971 URL=https://1password.com/blog/1password-credential-broker-public-preview`, curl exit 0.
Decoded body: 190261 bytes (same as tsv), sha256 97aa35bcdbf98913635f88cc669e9be28af7756c4063ac2fc45ebb94733af578
(≠ tsv fe37e1f3… — consistent with the row's `decoded-http-body-volatile-v1` marker; same length,
different volatile bytes).
Normalizer: `python3 corpus/rendered-text-v1.py digest blog.html` →
`raw_sha256=97aa35bc… bytes=190261 normalized_sha256=20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f normalized_bytes=9530`
— rendered digest IDENTICAL to the round fetch. Visible page text is unchanged today.

## Release-identity decision
The page is a dated vendor blog announcement, not a versioned product/doc set:
- `article:published_time` = `article:modified_time` = `2026-07-28T00:00:00.000Z` (grep of
  blog.html) — the article itself is unmodified since publication; no version string exists.
- Official-feed probes (all `curl -sSL`, status shown):
  - 200 https://releases.1password.com/ — title `1Password Releases`; `grep -ci 'credential broker'` → 0.
    No Credential Broker product on the official release hub; it tracks app releases only.
  - 404 https://www.1password.dev/changelog (curl exit 22)
  - 404 https://developer.1password.com/changelog; 404 https://www.1password.dev/release-notes
  - 404 https://blog.1password.com/rss/; 404 https://1password.com/blog/feed;
    blog.1password.com root 200 but contains no rss/atom link element.
  No official release feed governs this announcement. Binding it to releases.1password.com
  would be a scope mismatch (unrelated app versions could "fire" the clock).
- Cross-evidence that no release has moved past the anchored state: live docs
  https://www.1password.dev/brokered-access (S019's row; fetched 200, 166493 bytes wire) still
  carries "public preview" 34× and still links this exact post as Learn-more:
  "1Password Blog: 1Password Credential Broker is now in public preview" (both "no longer"
  matches on that page are integration-deletion text, not status changes).

→ Clock: `rendered-quote` (unversioned dated publication; quotes must still locate in a fresh
fetch under rendered-text-v1). Anchored identity: publication date 2026-07-28, not a version.

## Quote observations (rendered-text-v1, exit 0 = located)
- `locate blog.html "unlike a service account token that carries standing access, the organization-wide integration key is an encryption key"` → `count=1`
- `locate blog.html "is in public preview"` → `count=1`
- Anchor headings still present: `locate blog.html "How 1Password Credential Broker works"` → `count=1`;
  `locate blog.html "Try 1Password Credential Broker today"` → `count=1`

## Proposed release-clocks.tsv line (9 fields: id, clock, feed_source_id, feed_url, anchored_version, observed_version, observed_at, verdict, note — schema per XReleaseClock executor)
```
S006	rendered-quote	-	-	-	-	2026-10-21	quote-located	article unchanged: article:modified_time=article:published_time=2026-07-28; rendered digest 20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f identical to round fetch; both quotes locate count=1; no official release feed exists (probes above)
```
feed_source_id/feed_url `-` because no official release feed exists for this content (probes
above); anchored_version/observed_version `-` because `rendered-quote` is the unversioned-docs
clock (`not-fired` is feed-only and a date-as-version binding would fail offline validation —
executor correction, 2026-10-21). The anchored publication date (2026-07-28) and its
unchanged-today observation live in the note and in this report.

## SOURCES-row-ready line for the opened feed (candidate — recommend NOT binding to S006)
1Password Releases — https://releases.1password.com/, release notes, A (official vendor hub),
scope: 1Password app/client release notes index, NOT Credential Broker or its docs; anchor:
none for this row (zero "credential broker" mentions on page, opened 2026-10-21); quote: none
available — page carries product links, no quotable Credential Broker text. Rejected as S006's
feed because scope does not cover the row's claim; a vendor blog announcement has no machine-
readable release feed (probes above). L1 may still want it as a generic A-tier row for
app-version rows elsewhere in the registry.

## Verdict on S006's teaches
HOLDS. "Credential Broker public-preview status and integration-key versus standing Service
Account access distinction" is taught by an announcement dated 2026-07-28 that is byte-stable
today (identical rendered digest), unmodified since publication (modified_time = publish date),
still located by both row quotes and both anchor headings, still branded "public preview" by the
live docs, and still the vendor's own Learn-more link from those docs. No release observed today
moves past the anchored state → not-fired. Consistent with SOURCES.md:96-99: S006 remains dated
announcement context; live status oracle duty sits with S019/S017/S020, not here.

UNRUN: exhaustive enumeration of every possible 1Password feed URL (negative result is from 8
probes); GitHub releases API deliberately not opened — Credential Broker is not a repo-published
artifact, no org/repo is named by the row or page.
