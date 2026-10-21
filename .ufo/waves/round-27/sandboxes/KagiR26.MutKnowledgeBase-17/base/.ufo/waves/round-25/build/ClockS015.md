# ClockS015 — C3 release clock for S015 (OpenBao Kubernetes JWT provider)

Revision 4, 2026-10-21. Final S015 binding: feed, as in rev 2, with the quote and version-label locates recorded on every observation. Rev 3's rendered-quote binding is withdrawn after peer review (KagiR25.ClockS021-2, KagiR25.ClockS016-2).
Seat KagiR25.ClockS015-2 (leaf scout). Base 4587c61a348e4528717404a68912c373f3ef4d03. Lane untouched; experiments in /fast/scratch/kagi-r25/ClockS015/lane. No installs or upgrades. No gate verify/cells.

## Verdict
- S015 teaches: HOLDS. The served quote locates (count=1, fresh fetch 2026-10-21). kubernetes.mdx is the same git blob (1731f80c…) at tag v2.7.1 and at the release/2.7.x head (720135ed…).
- Feed: NOT FIRED. Redirect tag v2.7.1 = observed_version = anchored exact tag v2.7.1.
- Why feed: S015's recheck is on-release (SOURCES.md:21). The documented behavior changes with a release, and only the feed fires on that release. The URL is unversioned, so a new default line arrives as a release.
- Latent gap: a docs-only commit on release/2.7.x would not fire the feed. None so far: website/content/docs tag→head has 448 paths and 0 differences. The observation fields below cover it.
- Anchor gap (spec): the spec takes anchored_version from the version the anchor names. S015's anchor names "2.7.x", not v2.7.1. The planner decides: amend the anchor to name v2.7.1, or accept the exact-verified-tag rule (ClockS016 §4 raises the same gap).

## Proposed corpus/release-clocks.tsv line (canonical 9 columns, build-spec.json:25)
```
S015	feed	S033	https://github.com/openbao/openbao/releases/latest	v2.7.1	v2.7.1	2026-10-21	not-fired	observation 2026-10-21: redirect tag v2.7.1; quote locate count=1 on https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/; label 'Version 2.7.x' locate count=3; served sha256 4e3fdb7d… (point attestation)
```
- Literal comparator: observed == anchored, so not-fired.
- If fired later (observed != anchored): re-verify the quote at the new tag, then record observed := new tag and anchored := new tag. Never silently re-pin.

## Observation fields (every --observe; ClockS021 item 5, ClockS016 §4)
- Redirect tag T (Location, not followed; no API quota).
- Quote locate count (rendered-text-v1, fresh fetch of the row URL).
- Displayed label locate count, "Version 2.7.x".
- Negative control on the same page: "Version 2.8.x" locate count=0, exit 1. The label check discriminates.
- Proposal for L1 (not implemented here): a zero in either locate blocks CLEAN until a review records the new state. The feed comparator is unchanged.

## One rule for all OpenBao on-release rows (for L1)
- S014, S015, S016, S021, S025, S026: feed clock, feed_source_id S033, exact anchored tag (the tag whose source verifies the quote), both locates recorded.
- ClockS025's report uses releases.atom and a max-semver comparator. To share this rule it must move to S033 and the exact comparator.
- Rendered-quote stays for non-release products. OpenBao rows do not use it.

## Branch-head check
- `git ls-remote https://github.com/openbao/openbao.git refs/heads/release/2.7.x` → 720135eda5b60d20b0f0a251dc9d429c965b5f8f (exit 0). Tag v2.7.1 → a5db72cef75c24b920ade02065b18dd8eb666bac. The head is untagged and ahead. Commit count not extracted (UNRUN).
- kubernetes.mdx: raw commit URL → 200, sha256 ca1129c20ff8dbb7bf3ff93917a976d8f48f828c0f5ee12dd75aed27728b73e1; diff vs the tag file 0 lines. Git blob 1731f80caf8dbf89c0bf54f5b302c8b2c98de148 at head and at v2.7.1 (`git clone --filter=blob:none --depth 1 --branch <ref>`, then `git rev-parse HEAD:<path>`).
- website/content/docs, tag vs head: 448 paths; 0 added, changed or removed (`git ls-tree -r HEAD`, awk).
- ClockS016-2 (11:02Z) reports the same head and tokens.mdx identity.

## Feed SOURCES candidate S033 (census-tested; L1 renumbers)
Registry row, insert after corpus/SOURCES.md:38:
```
| S033 | OpenBao GitHub latest-release feed — https://github.com/openbao/openbao/releases/latest | code | A | OpenBao latest stable release identity (redirect tag, publish date, target commit) for feed-bound OpenBao clocks; not a docs-content clock | Redirect Location tag v2.7.1; tag page datetime="2026-10-01T14:03:19Z" (visible date omits the year); git ls-remote refs/tags/v2.7.1 = a5db72cef75c24b920ade02065b18dd8eb666bac; opened 2026-10-21 | Latest stable OpenBao release is v2.7.1, published 2026-10-01 (observed 2026-10-21). This tag does not move for untagged release/2.7.x docs commits, so each feed-bound row also records a quote-locate and displayed-version-label observation. A feed-bound clock fires when the redirect tag differs from its recorded observed_version. Quote: “Release v2.7.1 · openbao/openbao · GitHub” (page title, rendered text). | mined | 2026-10-21 | 90d | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```
Fetch-ledger row, insert after corpus/source-fetches.tsv:75 (16 tab-separated fields; row_identity = sha256 of `S033<TAB>mined<TAB>URL<LF>` = 01005e5ad4c6af83a65fa76fbd80366016baf0d018992e789aeae944dd5a5690):
```
S033	mined	01005e5ad4c6af83a65fa76fbd80366016baf0d018992e789aeae944dd5a5690	https://github.com/openbao/openbao/releases/latest	https://github.com/openbao/openbao/releases/tag/v2.7.1	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	30cfbfe58f1b276223269b1f182f15779e99f8863451b22cf35886e011a56a32	227520	a5db72cef75c24b920ade02065b18dd8eb666bac	Release v2.7.1 · openbao/openbao · GitHub	rendered-text-v1	95ba591b745624a7ae00b49fcb68dce0ab9a4aa17b5f0de55575f3c56a0b318d	<title> element of the release tag page
```
Census (sandbox, `env -i PATH=/usr/bin:/bin HOME=… bash corpus/sources-census.sh`, exit codes): BASE `SOURCES_CENSUS: CLEAN (rows=32 A=30 … captures=32 …)` exit 0. Candidate with this text: `SOURCES_CENSUS: CLEAN (rows=33 A=31 B=0 C=2 queued=1 mined=30 rejected=2 … captures=33 …)` exit 0.

## Integration for L1 (lane not edited by me)
1. corpus/knowledge/vault-openbao-token-lease-lifecycle.md line 3 (source:): append `; S033 (https://github.com/openbao/openbao/releases/latest, releases/tag/v2.7.1 published 2026-10-01, opened 2026-10-21)`. Census-tested in the sandbox.
2. Same file line 5 (recheck:) already says "compare the docs 'Version' label to 2.7.x". Add "and locate the S015 quote" (prose, UNRUN).

## Fetch evidence (sandbox; exit codes)
- F1 served page: `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/` → exit 0, HTTP 200, decoded 55824 B, sha256 4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f = ledger (corpus/source-fetches.tsv:68).
- F2 normalizer (BASE copy, corpus/rendered-text-v1.py): `--selftest` PASS (cases=22), exit 0. Digest normalized 2732189767e6663d9994b7d7f5d20cab6c4d5b28ede6f73c5f2cfb4707a2aab8 (8724 B) = ledger col 15. Locate quote count=1; locate 'Version 2.7.x' count=3; negative control 'Version 2.8.x' count=0, exit 1.
- F3 redirect: `curl -sS -o /dev/null -w '%{http_code} %{redirect_url}' https://github.com/openbao/openbao/releases/latest` → 302 …/releases/tag/v2.7.1, exit 0.
- F4 tag page: title "Release v2.7.1 · openbao/openbao · GitHub" locates count=1, exit 0.
- F5 revision: `git ls-remote --tags https://github.com/openbao/openbao.git refs/tags/v2.7.1` → a5db72cef75c24b920ade02065b18dd8eb666bac, exit 0.
- F6 source: kubernetes.mdx line 12 "**Note:** The JWT auth engine does **not** use Kubernetes' `TokenReview` API"; line 17 names Kubernetes auth as using TokenReview.
- F7 GitHub docs (docs.github.com/en/rest/releases/releases, HTTP 200): latest release "sorted by the created_at attribute".

## Other findings
- O1 corpus/SOURCES.md:21 in-row pin a0a2b227… is the 2026-10-19 capture; non-reproducing (corpus/inrow-pins.tsv:21). Not changed.
- O2 Quote shape: the census counts words only (sources-census.sh:277-278); the source-fetches.tsv header says "≤25 ASCII words". The ASCII part is unenforced.
- O3 UA: round-25 UA used; the ledger profile name documents round-23. Digests match the ledger.
- O4 Freshness: all observations dated 2026-10-21.

## Blocked / unrun
- B1 api.github.com quota exhausted (403; reset 2026-10-21T11:25:01Z). The 302 redirect is used.
- B2 Commit count tag→head not extracted.
- U1 corpus/release-clock.py and corpus/release-clocks.tsv are absent at BASE: UNRUN. The binding check was manual.
- U2 Gates verify/cells: not run (forbidden on the lane).
- Installs: none. Lane writes: none; this report is the only file written in the lane.
