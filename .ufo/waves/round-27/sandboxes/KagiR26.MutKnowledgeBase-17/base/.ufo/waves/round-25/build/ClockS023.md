# ClockS023 — S023 release clock (C3)

Seat KagiR25.ClockS023-2 (leaf). Access 2026-10-21. Lane revision 4587c61a348e4528717404a68912c373f3ef4d03 (`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse HEAD`, read-only; equals frozen BASE). Scratch: /fast/scratch/kagi-r25/ClockS023-2/. Installs/updates: none.

## Verdict
- Identity: (a) feed. The page is a versioned Vault doc set: its version switcher reads `v2.x (latest)` (lease.normalized.txt:1) and its edit link is `content/vault/v2.x/content/docs/concepts/lease.mdx` (lease.body:43). Lease behaviour changes at product release, so the clock is the official hashicorp/vault release feed.
- Anchored (derived): v2.2.0 = newest product release at the row's open date 2026-10-20 (SOURCES.md:29). The row names only the route `v2.x`; see §5.
- Observed 2026-10-21: v2.2.0 in all four feeds. No product release published or updated after 2026-10-15 in any feed.
- **not-fired.** Nothing changed; no re-verification triggered.
- S023 teaches still hold (§4).

## 1. Page fetch
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o lease.body -w 'http=%{http_code} size_download=%{size_download} url_effective=%{url_effective}\n' https://developer.hashicorp.com/vault/docs/concepts/lease` → exit 0; `http=200 size_download=40415 url_effective=` same URL, no redirect.
- sha256 of decoded body `ac99140f11acbae6debf592f08fffaaadecb67d6b406a4044a3254e30d4dcdeb`, 261632 bytes. Three fetches today, identical.
- Row raw digest `de5f8836…` (source-fetches.tsv:50), same byte count: NOT reproduced. Same-URL row S013 (source-fetches.tsv:66) records `ac99140f…`, which equals today's value. Declared `decoded-http-body-volatile-v1` (source-fetches.tsv:19-23) makes it a point attestation with no equality enforced, so it is not a drift input.
- `python3 corpus/rendered-text-v1.py digest lease.body` → `RENDERED_TEXT_V1: raw_sha256=ac99140f… bytes=261632 normalized_sha256=0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 normalized_bytes=7354`, digest_exit=0. Normalized digest equals the row's: reproduced.
- Row identity: sha256(`S023\tmined\t<url>\n`) = 131e6a2015a202cebc9305a0943b4d62d66de343bfc97e2211ad7fc66cfed5b2 = row identity column: intact.
- One digest attempt raced the download (exit 2, FileNotFoundError, my ordering error); reruns succeeded.

## 2. Feeds opened (2026-10-21)
- F1 GitHub Atom `https://github.com/hashicorp/vault/releases.atom` → http=200, 303995 bytes, sha256 e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba. Newest product entry v2.2.0: `<updated>2026-10-15T18:50:14Z</updated>`. Entries also include `sdk/v0.26.0` (2026-09-24) and `v2.2.0-rc1`, so filter to stable product tags. `updated` is last-update time, not publish time (v2.1.2: updated 2026-10-08T19:26:01Z; REST published 2026-10-07T13:31:18Z).
- F2 GitHub REST `https://api.github.com/repos/hashicorp/vault/releases/latest` → http=200, 37844 bytes: tag v2.2.0, `published_at` 2026-10-15T16:17:18Z. `…/releases?per_page=12` → http=200, 101614 bytes; newest non-prerelease 2026-10-15T16:17:18Z.
  - Operability: the shared egress has exhausted the unauthenticated quota: `x-ratelimit-limit: 60`, `x-ratelimit-remaining: 0`, `x-ratelimit-used: 60` at Wed, 21 Oct 2026 10:41:17 GMT. Re-check → `http=403`. A REST-based clock fails for the whole fleet while the quota is spent.
- F3 `https://github.com/hashicorp/vault/releases/latest` → http=302 → `https://github.com/hashicorp/vault/releases/tag/v2.2.0` (no REST quota used).
- F4 `https://releases.hashicorp.com/vault/index.json` → http=200, 2691686 bytes; 1374 version keys, 246 plain X.Y.Z, maximum `2.2.0`; no dates.

## 3. Corroboration (rendered-quote, clock b; not the governing clock)
- `All dynamic secrets in Vault are required to have a lease.` → `RENDERED_TEXT_V1_LOCATE: count=1`, locate_exit=0.
- `The Key Value Backend which stores arbitrary secrets does not issue leases` → count=1 (KV no-lease note).
- H1 `Lease, renew, and revoke` → count=2.
- JSON-LD (lease.body:1): datePublished and dateModified 2026-04-15T00:14:52.000Z; no later page edit recorded.

## 4. S023 teaches
Still hold. The lease mechanism and KV no-lease note are present; the served route is displayed as `v2.x (latest)`, matching the row's version-route locator; the S013 supersession stands. The release identity has not moved since the open date.

## 5. Proposed release-clocks.tsv line
(tab-separated: id, clock, feed_url, anchored_version, observed_version, observed_at, verdict)

```
S023	feed	https://github.com/hashicorp/vault/releases.atom	v2.2.0	v2.2.0	2026-10-21	not-fired
```

Rules for release-clock.py on this line:
- Stable product tags only: `^v\d+\.\d+\.\d+$` (excludes `sdk/…` and `-rc` tags).
- Fired iff a stable product tag newer than the anchored one appears in the feed; not-fired otherwise.
- The Atom feed is proposed over the REST endpoint because the plan's example endpoint returns 403 on this egress.
- Concrete pin required: the literal route `v2.x` would stay silent on a v2.3.0 release. `releases/latest` can also point at a non-product tag if one is marked latest.
- Clocks on the same repo should share one fetch.

## 6. SOURCES candidates
Allocation: the planner assigns IDs from S033+; this seat claims none (siblings may propose S033+ too). All three are vendor-repository feeds, tier A.

| <S033+> | HashiCorp Vault GitHub release feed (Atom) — https://github.com/hashicorp/vault/releases.atom | feed | A | Product release identity for the Vault v2.x docs (S023 on-release clock); stable tags only | Atom entry v2.2.0, updated 2026-10-15T18:50:14Z; opened 2026-10-21 | Quote: “<updated>2026-10-15T18:50:14Z</updated>” (entry v2.2.0; feed line 10, byte 575); last-update time, not publish time. | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv (S023) |
| <S033+> | GitHub REST releases API, latest — https://api.github.com/repos/hashicorp/vault/releases/latest | feed | A | Publish-date cross-check for the same release; unauthenticated quota 60/h, shared (403 seen 2026-10-21) | tag v2.2.0, published_at 2026-10-15T16:17:18Z; opened 2026-10-21 | Quote: “"published_at":"2026-10-15T16:17:18Z"” (top-level field; line 1, byte 1889). | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv (S023) |
| <S033+> | HashiCorp release host, Vault index — https://releases.hashicorp.com/vault/index.json | feed | A | Official Vault version index; version cross-check only, no publish dates | 246 stable X.Y.Z keys, maximum 2.2.0; opened 2026-10-21 | Quote: “"version":"2.2.0"” (build entry under 2.2.0; line 1, byte 2677568). | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv (S023) |

## 7. Caveats and handoff
- A feed clock sees product releases only; a docs-only edit to the lease page would not fire it. The rendered-quote check (§3) covers quote loss if the planner wants a second clock.
- source-fetches.tsv:50 raw digest is stale relative to today's bytes; the clock does not read it. Not edited; the planner may refresh or annotate.
- Open date 2026-10-20 (SOURCES.md:29) vs fetch date 2026-10-21 (source-fetches.tsv:50); the clock uses the open date.
- release-clock.py and release-clocks.tsv are absent at BASE (corpus/ listing); not created here. UNRUN: any release-clock.py run (file absent). No lane gate `verify`/`cells` run.
- Main agent check once the planner lands the TSV line: `python3 corpus/release-clock.py --root .`
