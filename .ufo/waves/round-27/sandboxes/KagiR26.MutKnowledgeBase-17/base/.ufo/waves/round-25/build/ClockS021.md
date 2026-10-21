# ClockS021 — C3 per-row clock for S021 (round-25 build), rev 3

Seat: KagiR25.ClockS021-2 (leaf). Base 4587c61a348e4528717404a68912c373f3ef4d03. Observed 2026-10-21. Lane writes: this file only. Sandbox /fast/scratch/kagi-r25/ClockS021-2. Installs/updates: none.

## Verdict
- Governing identity: (a) versioned doc set with an official feed. Page `docs-version-2.7.x`; version menu Development / 2.7.x / 2.6.x / 2.5.x; edit link to `release/2.7.x`.
- Clock `feed`: S033 = https://github.com/openbao/openbao/releases/latest (one shared OpenBao feed row; agreed with KagiR25.ClockS015-2 rev 2).
- Exact comparator: anchored_version = v2.7.1 (the tag whose source the quote was verified at); observed_version = v2.7.1. **Verdict: not-fired.**
- S021 teaches: **holds.**

## Exact-tag evidence (rev 2)
- `website/content/docs/concepts/tokens.mdx` at tag v2.7.1 (raw.githubusercontent, HTTP 200, 15269 B): sha256 `f05ae2babff6eb97b51a7f21943c3279f50da033469540badb46c7780812ab28`.
- Same path on branch `release/2.7.x` (HTTP 200, 15269 B): identical sha256.
- `git ls-remote`: tag v2.7.1 = a5db72cef75c24b920ade02065b18dd8eb666bac (lightweight tag); branch `release/2.7.x` head = 720135eda5b60d20b0f0a251dc9d429c965b5f8f, which is ahead of the tag.
- Quote in source: the MDX is line-wrapped, so matching is on whitespace-collapsed text (the rendered-text-v1 rule). "After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked." count=1. "Token Time-To-Live, periodic tokens, and explicit max TTLs" count=1. "Service vs. batch token lease handling" count=1. "Leases created by batch tokens are constrained to the remaining TTL of the batch tokens" count=1.

## Feed S033 — independent reproduction (2026-10-21)
- `curl -sS -D -` without `-L`: HTTP/2 302, `location: https://github.com/openbao/openbao/releases/tag/v2.7.1`, no x-ratelimit headers. Sent 10:46 UTC, after api.github.com returned 403 at 10:41 UTC.
- Tag page (census profile, follows redirect): HTTP 200, 227521 B, sha256 `1965a352fe25e350f2e7d4e098e980a8a84b6cb50d611a1a481687ebeda992bd`, normalized `e31763cd5010e4e16f257165ace33790eeecf389a4e91cb28732aedcc6b72df3` (6254 B).
- Row identity: sha256("S033\tmined\thttps://github.com/openbao/openbao/releases/latest\n") = `01005e5ad4c6af83a65fa76fbd80366016baf0d018992e789aeae944dd5a5690`, matching ClockS015.md.
- Digests vary per fetch. Diffed against ClockS016's two captures and ClockS026's: the normalized text differs in one element, `Issues 264 ( 264 )` (my later capture) vs `263 ( 263 )` (earlier captures). Substituting 263 reproduces `95ba591b…` exactly. Raw bytes also differ on per-response nonces and DOM UUIDs. Tag-page digests are point attestations, never clock inputs.
- Title `Release v2.7.1 · openbao/openbao · GitHub` locates count=1. Visible date reads `01 Oct 14:03`; the year appears only in `datetime="2026-10-01T14:03:19Z"`.

## Proposed corpus/release-clocks.tsv rows (canonical 9 columns, build-spec.json:25)
id	clock	feed_source_id	feed_url	anchored_version	observed_version	observed_at	verdict	note
S021	feed	S033	https://github.com/openbao/openbao/releases/latest	v2.7.1	v2.7.1	2026-10-21	not-fired	observation 2026-10-21: redirect tag v2.7.1; quote locate count=1 on https://openbao.org/docs/concepts/tokens/; label 'Version 2.7.x' locate count=3; source quote count=1 at tag v2.7.1 (tokens.mdx); served raw sha256 5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c (point attestation)

Anchor gap (spec): build-spec.json:25 defines anchored_version as the version the row's anchor names, and S021's anchor says "Version 2.7.x". The literal comparator needs the exact tag: against "2.7.x", v2.7.1 would read as fired. L1: amend the S021 anchor to name v2.7.1, or accept the exact-verified-tag rule (the same gap as S015 and S016).

## Clock rule (adopted from ClockS015 rev 2)
- Observer: Location header of releases/latest, not followed (no API quota).
- Fired iff Location tag ≠ observed_version. Not fired: new observation receipt, same baseline.
- On fire: re-verify the quote in the new tag's mdx source; record observed_version = new tag and anchored_version = the exact tag verified; never silently re-pin.
- Caveats: a backport created later takes "latest" and fires (false positive; re-verification absorbs it). A release built from an older commit may not move "latest" (residual false negative; the git ls-remote cross-check at review catches it).
- Observation fields per run (ClockS015 rev 4, adopted): redirect tag; rendered-text-v1 quote locate count; displayed-label locate count (`Version 2.7.x`). A zero in either blocks CLEAN until a review records the new state. The literal comparator is unchanged. L1 decides the gate.

## SOURCES row S033 (shared; wording per ClockS015 rev 2)
- Kind `code`, tier A. Quote: page title `Release v2.7.1 · openbao/openbao · GitHub` (count=1). Teaches must not name one row's claim (S015's auth/kubernetes sentence is row-specific).

## S021 teaches check
- Served page: decoded sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` (47384 B) and normalized `ed949658…` (14608 B) equal the ledger (SOURCES.md:27, source-fetches.tsv:48).
- Quote locates in rendered text (count=1) and in tag-pinned source (count=1, collapsed).
- Term counts: Vault 0, KV 0, OpenBao 21. The "no Vault-token or KV-retention claim" exclusion still holds.
- Release notes v2.7.0 / v2.7.1: no TTL or service/batch lease change. Adjacent only: v2.7.1 root-token audit and auth/kubernetes renewal validation; v2.7.0 revoke-self with wrapping tokens.
- Observation 2026-10-21 (fresh, rev 3): redirect tag v2.7.1; quote locate count=1; label `Version 2.7.x` locate count=3 (navbar item, dropdown item, doc badge); raw sha256 unchanged `5229521866…`; normalized `ed949658…` unchanged.

## Counterexamples and operability
1. Branch-only commits: `release/2.7.x` head 720135ed… is ahead of tag v2.7.1 (a5db72…). The served docs follow the branch, so an untagged docs commit would not fire an on-release clock. Today tokens.mdx is identical at tag and head. Follow-up for L1: a source-blob check at the branch head for the S015/S016/S021/S025/S026 sources. Not part of the S033 design.
2. Quota: clocks must never use api.github.com. 403, 429, or a missing Location is UNOBSERVED, never not-fired.
3. Tag-page digests vary between fetches (see above); do not pin them.
4. Atom rejected: 506 KB per fetch, ordered by `updated`, 10 entries, mixed sub-module tags.
5. Rendered-quote rejected for S021 (suggested by ClockS015 rev 3 for unversioned URLs). The unversioned path is the current stable docs line; the page labels it `Version 2.7.x`, so the governing identity is the 2.7.x release line, which the feed tracks. Trigger fit: the registry declares `recheck: on-release`; rendered-quote fires on content change, not on release. [INFERENCE] When a 2.8 line becomes the default, the unversioned path serves it; if the TTL sentence survives there, rendered-quote stays silent while the feed fires on that release. Today the quote locates count=1 on the served page; record it as an observation field, not as the bound clock.

## Coordination
- ClockS015 rev 2 adopted my three changes (fire rule, shared-row quote, digests). I adopt its exact comparator: S021 moves from series `2.7.x` to exact `v2.7.1`, supported by the tag-blob check above. Both reports now agree on S033 and the rule.

## Unrun / not done
- `corpus/sources-census.sh` and `corpus/release-clock.py` on the S033 candidate: UNRUN by me. ClockS015 reports sandbox CLEAN rows=33; L1 runs the gate.
- verify/cells: not run (contract).

## Tooling
- No installs or updates. Used curl, git ls-remote, python3 stdlib, coreutils. Sandbox /fast/scratch/kagi-r25/ClockS021-2.
