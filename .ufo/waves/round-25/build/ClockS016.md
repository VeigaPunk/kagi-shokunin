# ClockS016 — C3 release clock, S016 (OpenBao tokens)

Seat KagiR25.ClockS016-2 · lane BASE 4587c61a348e4528717404a68912c373f3ef4d03 · observed 2026-10-21 (~10:42Z)
Sandbox `/fast/scratch/kagi-r25/ClockS016-2` (lane clone at BASE; `rendered-text-v1.py` run from it). Lane not written. Installs: none. Gate `verify`/`cells`: not run. No credentials, vault, CDP, or op use.
Rev 3: canonical 9-column schema (build-spec.json:25), exact anchor v2.7.1 (verified at source), ClockS015 rev 4 binding (feed for all OpenBao on-release rows). S033 is provisional: L1 renumbers, and column 3 of both lines follows.

## 1. Verdict
- Governing identity = (a): versioned docs with an official release feed. The page is the OpenBao 2.7.x docs series: `docs-version-2.7.x`, badge `Version: Version 2.7.x`, switcher 2.7.x / 2.6.x / 2.5.x (no 2.8.x), source link `blob/release/2.7.x/website/content/docs/concepts/tokens.mdx`.
- Feed `https://github.com/openbao/openbao/releases/latest` → 302 → `.../releases/tag/v2.7.1`: latest GA v2.7.1, published 2026-10-01T14:03:19Z.
- Clock S016 = **not-fired**. Location tag v2.7.1 equals observed_version v2.7.1 (last reviewed). anchored_version v2.7.1 is the tag whose source verifies the quote. No GA was published after the row's mined date (2026-10-19).
- Teaches S016 = **still holds** on the current 2.7.x page (caveats in §5). Cross-check (b) rendered-quote also passes: the quote locates once.

## 2. Fetch evidence — S016 URL
```
curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o tokens.html -w '%{http_code} %{url_effective} %{size_download}' https://openbao.org/docs/concepts/tokens/
→ 200 https://openbao.org/docs/concepts/tokens/ 12527 (wire bytes); exit 0
sha256(decoded body) 5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c  bytes 47384
```
- Exact match to `corpus/source-fetches.tsv` S016 sha256 and bytes. A second fetch (bg_370, ~10:42Z) gave the identical sha256.
- `rendered-text-v1.py digest` → normalized_sha256 `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`, normalized_bytes 14608 (equals the fetch row). Exit 0. `--selftest` → PASS (cases=22), exit 0.
- `locate` of the S016 quote → count=1, exit 0. It sits under H2 "Token hierarchies and orphan tokens" (normalized offset 4921).
- UA: the fetch-row profile text names a round-23 UA; this run used the round-25 UA from the contract. Body identical.

## 3. Feed evidence — OpenBao latest GA
- `curl -sS -D h.txt -o /dev/null https://github.com/openbao/openbao/releases/latest` → HTTP/2 302, `location: https://github.com/openbao/openbao/releases/tag/v2.7.1`; exit 0; no API quota used.
- Tag page (curl -fsSL --compressed): 200, 227521 bytes, sha256 `ca8dfbcf4d7a16a157d2c4d552f9cd141cab7f052f7dda99f575e497fc3fcd69`. Located: "released this 01 Oct 14:03" (1), "Immutable release. Only release title and notes can be modified." (1), "v2.7.1 Latest" (1).
- Tag page second fetch sha256 `ad306b39244229e4f3c8099994f6adbc4087e2a78936f2658a8367187f6ffb10`; normalized digest `95ba591b745624a7ae00b49fcb68dce0ab9a4aa17b5f0de55575f3c56a0b318d` (6254 bytes) in both.
- Revision: `git ls-remote --tags https://github.com/openbao/openbao 'refs/tags/v2.7.1'` → `a5db72cef75c24b920ade02065b18dd8eb666bac refs/tags/v2.7.1` (no peeled line: lightweight tag); exit 0.
- API cross-check, fetched before the quota ran out: `/releases/latest` → v2.7.1, published_at 2026-10-01T14:03:19Z, target_commitish a5db72ce… (body sha256 `0a133ef12c16a4286a6c761b86d5927153e8dc8f6f58d0aeef51261c7a20b684`). `/releases?per_page=40` → 36 releases, newest v2.7.1 (sha256 `d3d34d5f92f425a62da0337d8b1ebcd26d9a6be88794b8427b92edc701e12624`). Newest prerelease v2.7.0-beta20260909 (older). Nothing published after 2026-10-01.
- `releases.atom`: 200, 506783 bytes, sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`. Its v2.7.1 `<updated>` (2026-10-01T18:32:18Z) is not the publish time; it also lists module tags such as `api/v2.7.1`.

## 4. Proposed clock lines (not written; `corpus/release-clocks.tsv` absent at BASE)
Canonical columns (build-spec.json:25): id, clock, feed_source_id, feed_url, anchored_version, observed_version, observed_at, verdict, note.
```
id	clock	feed_source_id	feed_url	anchored_version	observed_version	observed_at	verdict	note
S016	feed	S033	https://github.com/openbao/openbao/releases/latest	v2.7.1	v2.7.1	2026-10-21	not-fired	quote verified at v2.7.1 source (tokens.mdx, count=1) and live 2.7.x page; S026 supersedes the locator
S026	feed	S033	https://github.com/openbao/openbao/releases/latest	v2.7.1	v2.7.1	2026-10-21	not-fired	same URL and quote as S016; verified at v2.7.1 source and live 2.7.x page
```
- The literal checker rule (fired iff observed_version != anchored_version) gives not-fired for both lines.
- Source check for anchored v2.7.1: `raw.githubusercontent.com/openbao/openbao/v2.7.1/website/content/docs/concepts/tokens.mdx` → 200, 15269 B, sha256 `f05ae2babff6eb97b51a7f21943c3279f50da033469540badb46c7780812ab28`, quote count=1 (whitespace-normalized). The `release/2.7.x` file is byte-identical.
- Protocol with the checker: an observation writes observed_version := Location tag T; the checker reports fired until review sets anchored_version := T and records quote-located or quote-missing [INFERENCE on the post-review verdict].
- Anchor gap for L1: the spec defines anchored_version as "the version the row's anchor names". S016 and S026 name only `2.7.x`. Amend both anchors to name v2.7.1, or accept the exact-verified-tag rule. Date-rule cross-check (ClockS010's definition: the page's stated content date, else the capture date): the tokens page states no date (empty lastUpdated element; no dateModified or modified_time meta), so the capture date 2026-10-21 applies. The newest release on or before it is v2.7.1 (published 2026-10-01), so the rules agree. Decision for L1.
- Agreed with ClockS015 rev 4: one rule for all OpenBao on-release rows. S015, S016 and S026 bind to feed S033 with the exact anchored tag v2.7.1 and the literal comparator; rendered-quote is withdrawn for OpenBao rows. The S016/S026 URL is the unversioned default alias of the 2.7.x series; the docs-only blind spot is covered by the review-time locate. Each observation records the quote locate and a displayed-label locate: docs badge `Version: Version 2.7.x` (count=1, live page today) and tag page `v2.7.1 Latest` (count=1). A zero blocks CLEAN until review (ClockS015's proposal to L1).

## 5. S016 teaches — holds, with caveats
- Still present on the fresh page: the quote under §Token hierarchies and orphan tokens; "attached policies" (count 1) for token policy; "last renewal time" (count 2) and `bao token renew` under §Token Time-To-Live for TTL/renewal.
- Caveat A (locator): S016's anchor lists §Tokens and §Token Time-To-Live, not the section holding the quote. S026 (opened 2026-10-21) supersedes S016 with the corrected locator. The claim is unaffected.
- Caveat B (pin): S016's in-row `Fetch sha256` c083fdca8645… matches neither the raw (5229521866…) nor the normalized (ed949658…) digest of today's page (`corpus/inrow-pins.tsv:22`, non-reproducing). Stale; the fetch row is the live pin.
- Caveat C (release notes): v2.7.0 (2026-09-23) and v2.7.1 (2026-10-01) notes contain no change to parent→child or lease revocation. Adjacent only: v2.7.0 "core: Add support for `revoke-self` with wrapping tokens"; v2.7.1 "auth/kubernetes: Ensure Service Account JWT is validated on renewal, preventing post-revoke usage" (Kubernetes auth JWT, not the token tree).

## 6. Feed SOURCES row S033 (provisional) — adopt ClockS015 rev 4's row; my candidate withdrawn
- My candidate named `corpus/release-clocks.tsv` as used-by. The census accepts only `corpus/(knowledge|lessons)/*.md` (`sources-census.sh:215`). ClockS015 and ClockS010 both recorded SC_USEDBY_MISSING for that path.
- Adopt ClockS015 rev 4's S033 registry row (`ClockS015.md` rev 4, S033 line: kind `code`, tier A, scope "feed-bound OpenBao clocks; not a docs-content clock"; used-by `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; recheck 90d). Their sandbox census is CLEAN (rows=33). L1 adds S033 to that file's `source:` line (SC_USEDBY_NOCITE, `sources-census.sh:229-231`).
- Adopt ClockS015 rev 4's fetch row, unchanged since rev 2 (quote = page `<title>`; sha256 30cfbfe5…, 227520 B). Its revision a5db72ce… matches mine.
- row_identity = sha256("S033\tmined\thttps://github.com/openbao/openbao/releases/latest\n") = 01005e5ad4c6af83a65fa76fbd80366016baf0d018992e789aeae944dd5a5690. Recompute if L1 renumbers.

## 7. Operability and calibration (for L1)
1. api.github.com is unusable on this host: quota 60/h per IP, now 0 (HTTP 403, reset 2026-10-21T11:25:01Z). Every seat shares the IP, so release clocks must not call the REST API. Use the `/releases/latest` 302 `Location` parse.
2. `releases.atom` mixes module tags and prereleases, and its `<updated>` is not the publish time (openbao v2.7.1: +16139 s; SOPS, per ClockS010: +57 s to +42969 s). Use the redirect, or filter `^v\d+\.\d+\.\d+$`.
3. Digests are point attestations, not pins. Raw tag-page bytes change per response (per-response nonces and DOM UUIDs). The normalized text changes with the repo-nav open-issues counter: `Issues 263 ( 263 )` in my two captures; ClockS021's later capture reads `Issues 264 ( 264 )` and normalizes to `e31763cd…`. Substituting 263 reproduces `95ba591b…` (ClockS021's diff; my captures confirm the 263 text). The title quote is the clock input, not the digest.
4. Match rule, adopted from ClockS015 rev 4: fired iff the Location tag differs from observed_version; anchored_version is the exact tag whose source verifies the quote. The series-only rule missed in-series patches (a v2.7.2 would have been recorded not-fired). Today's verdict is the same under both.
5. A release feed sees releases, not docs edits within a series, so a docs-only edit would not fire it. The quote locate is the complementary check. `round-25.md:59-62` allows one clock per row, so L1 decides.
6. `corpus/release-clock.py` and `corpus/release-clocks.tsv` are absent at BASE; the spec says L1 fills rows. Nothing written in the lane.

## 8. Commands and exit codes
- `git clone -q --no-hardlinks <lane> <sandbox>/lane && git checkout -q 4587c61a…` → 0; HEAD 4587c61a348e4528717404a68912c373f3ef4d03.
- curl tokens page → 0 (×2). curl github.com `releases/latest` → 0 (302). curl tag page → 0 (×2). curl `releases.atom` → 0. curl raw `tokens.mdx` at v2.7.1 and at `release/2.7.x` → 0 (×2), identical sha256.
- Freshness recheck 2026-10-21 11:02Z: latest redirect → v2.7.1 (302, exit 0); `git ls-remote --heads` for `release/2.7.x` → `720135eda5b60d20b0f0a251dc9d429c965b5f8f` (exit 0); raw `tokens.mdx` at the branch head → 200, sha256 `f05ae2ba…` (identical to the tag).
- curl `api.github.com .../releases/latest` → 0, and `.../releases?per_page=40` → 0, both before the quota ran out. `.../git/ref/tags/v2.7.1` → curl exit 22 (HTTP 403).
- `git ls-remote --tags` → 0. `rendered-text-v1.py digest | locate | --selftest` → 0. Python whitespace-normalized locate on the mdx → count=1.
- Census: not run by me. ClockS015's run is CLEAN (rows=33). My used-by reasoning rests on reading `sources-census.sh:215, 229-231`.
- Installs: none. Tools: curl, git, python3, sha256sum (preinstalled).
- UNRUN: `release-clock.py` (absent). Gate `verify`/`cells` (forbidden on the lane tree).
