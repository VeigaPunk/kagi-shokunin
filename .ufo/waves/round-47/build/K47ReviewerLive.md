# K47ReviewerLive — independent live leg (C2 freshness + C1 S099 binding), round 47

Lane-dispatched seat (not a non-author reviewer). Independent re-fetch of every claimed
source, before the candidate exists, for later sha256 comparison by L1.

- Method: `curl -fsSL --compressed` (decoded HTTP body saved, UA
  `Mozilla/5.0 (X11; Linux x86_64) kagi-r47-live-leg/1.0`), sha256+bytes of the decoded
  body. Quotes located with `python3 corpus/rendered-text-v1.py locate <body> <quote>`.
- Fetch window: 2026-11-06T19:34:42Z – 2026-11-06T19:34:44Z. Scratch
  `/fast/scratch/hyaku/kagi-r47/K47ReviewerLive`, `trap rm -rf` on exit (bodies not kept;
  sha256 list is the receipt).
- URLs: column 4 of `corpus/source-fetches.tsv` for S012–S016/S021–S026; S099 from its
  `corpus/SOURCES.md` row (pinned raw URL at fleet commit 75dd2612).
- Every fetch: HTTP 200, no failures. Every quote located, rc=0.

## Table — one row per id

| id | URL (host-shortened) | UTC time | HTTP | sha256 | bytes | quote count | served version marker |
|----|----------------------|----------|------|--------|-------|-------------|-----------------------|
| S012 | developer.hashicorp.com/vault/docs/auth/jwt | 2026-11-06T19:34:43Z | 200 | 0ccb802db1b1667838b2afcbd62e047079b4426bb24012299bc3691cec9912fa | 386833 | 1 | no v2 marker; selector JSON `v1.4.x`–`v1.21.x`, `latest`, literal `1.9.3` |
| S013 | developer.hashicorp.com/vault/docs/concepts/lease | 2026-11-06T19:34:43Z | 200 | f4c70f9fed8dcb4fa63adf2830fb0c3aa7b87307ba5c7929e35d19e158e77972 | 261663 | 1 | same selector JSON; text links `vault/docs/v1.5.x`–`v1.9.x` |
| S014 | openbao.org/docs/auth/jwt/ | 2026-11-06T19:34:43Z | 200 | 893f33e403cabe4b61294e27b678f7088c5789342cd778abd56a8e8c27ae4be7 | 63046 | 1 | `Version 2.7.x` ×3, `version-2.7.x` ×1, `2.6.x`/`2.5.x` selectors |
| S015 | openbao.org/docs/auth/jwt/oidc-providers/kubernetes/ | 2026-11-06T19:34:43Z | 200 | 7007e9e437b24fc5fa47ba2675ef0d27512e036bac2f971131568058f0803b48 | 55824 | 1 | `Version 2.7.x` ×3, `version-2.7.x` ×1, `2.6.x`/`2.5.x` selectors |
| S016 | openbao.org/docs/concepts/tokens/ | 2026-11-06T19:34:43Z | 200 | ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef | 47384 | 1 | `Version 2.7.x` ×3, `version-2.7.x` ×1, `2.6.x`/`2.5.x` selectors |
| S021 | openbao.org/docs/concepts/tokens/ | 2026-11-06T19:34:42Z | 200 | ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef | 47384 | 1 | same as S016 |
| S022 | developer.hashicorp.com/vault/docs/auth/jwt | 2026-11-06T19:34:42Z | 200 | 0ccb802db1b1667838b2afcbd62e047079b4426bb24012299bc3691cec9912fa | 386833 | 1 | same as S012 |
| S023 | developer.hashicorp.com/vault/docs/concepts/lease | 2026-11-06T19:34:42Z | 200 | f4c70f9fed8dcb4fa63adf2830fb0c3aa7b87307ba5c7929e35d19e158e77972 | 261663 | 1 | same as S013 |
| S024 | developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 | 2026-11-06T19:34:43Z | 200 | 08ad557bfee03351fcfb99b7b1f447bc106a9a1e48036067c8e374668b77b3d8 | 586212 | 3 | no text marker; selector JSON only (`v1.4.x`–`v1.21.x`, `latest`, `1.9.3`) |
| S025 | openbao.org/docs/auth/jwt/ | 2026-11-06T19:34:43Z | 200 | 893f33e403cabe4b61294e27b678f7088c5789342cd778abd56a8e8c27ae4be7 | 63046 | 1 | same as S014 |
| S026 | openbao.org/docs/concepts/tokens/ | 2026-11-06T19:34:43Z | 200 | ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef | 47384 | 1 | same as S016 |
| S099 | raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md | 2026-11-06T19:34:43Z | 200 | e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c | 97077 | 1 | n/a (fleet prompt file) |

Duplicate-URL consistency: S012≡S022, S013≡S023, S014≡S025, S016≡S021≡S026 served
byte-identical bodies on repeat fetch seconds apart — no CDN drift observed.

## C1 — S099 binding check (independent)

- Live fetch of the pinned raw URL: sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`,
  97077 bytes — matches the SOURCES.md pin (`e62e259c…1b80c`, 97077 bytes) exactly.
- Fleet git blob `75dd26121698f10cf111120f6cbcd2b2125598f1:.ufo/prompts/kagi-round-44.md`
  (`git cat-file blob`): same sha256, same 97077 bytes — byte-identical to the live fetch.
- Quote «The claim is judged on the counter, kill rule and predicate declared before data. A rule»
  located in both the live body and the blob: `RENDERED_TEXT_V1_LOCATE: count=1`, rc=0 each.

## C2 — release feeds (fetched 2026-11-06T19:34:43–44Z, both HTTP 200)

- https://github.com/hashicorp/vault/releases.atom — newest titles in feed order:
  `v2.2.1`, `v2.2.0`, `v2.2.0-rc1`, `v2.1.2`, `sdk/v0.26.0`, … **newest stable tag: `v2.2.1`**.
- https://github.com/openbao/openbao/releases.atom — newest titles in feed order:
  `v2.7.2`, `v2.6.5`, `v2.7.1`, `v2.6.4`, `v2.7.0`, `v2.7.0-beta20260909`, …
  **newest stable tag: `v2.7.2`** (v2.6.5 appears above v2.7.1 — feed is date-ordered; 2.7.2
  is the newest semver stable). OpenBao docs pages serve `Version 2.7.x`, consistent.

## Observations (data, not verdicts)

- OpenBao pages: expected `Version 2.7.x` marker present on every openbao.org body.
- Vault docs pages: no `v2.2`/`2.2` product-version marker anywhere in the served bodies
  (targeted re-scan: the only `2.x` literals are CSS/JS metrics like `2.393`; version
  selector JSON lists `v1.4.x`–`v1.21.x` + `latest` + literal `1.9.3`). The v2.x evidence
  for Vault comes solely from the releases feed, not the docs pages.

sha256 list: `K47ReviewerLive-sha256.txt` (same directory). All 12 rows: time + HTTP +
sha256 + bytes + quote count recorded; zero fetch failures; zero quote-location failures.
