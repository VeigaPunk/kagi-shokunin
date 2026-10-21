# FClockS024 — C3 S024

## Verdict

**PASS for the frozen S024 clock as observed 2026-10-21; no current falsifier.** Candidate revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (frozen sandbox clone `/fast/scratch/kagi-r25/FClockS024/lane`; `git rev-parse HEAD` exit 0, stdout exactly that revision). `date -u` immediately before the fetches: `2026-10-21T12:08:09Z`.

- `corpus/release-clocks.tsv:21`: `S024 feed S034`, anchor `2.2.0`, observed `2.2.0`, `2026-10-21`, `not-fired`; note says the anchor is derived from the newest stable Vault release on the row's opened date.
- `corpus/SOURCES.md:30`: S024 is the served live KV v2 API docs, opened `2026-10-21`; teaches `max_versions` retention and separate `delete_version_after` config, not deployed KV state. `SOURCES.md:40` scopes S034 to stable Vault `X.Y.Z`, excluding SDK and prerelease entries.
- `corpus/lessons/round-25.md:71-79` (R25-C8) explicitly defines unnamed feed anchors as derived from the newest stable feed release when the row was opened. The S024 derivation follows that rule: the served page labels its route `v2.x (latest)` (fresh normalized page text; count 2), not an exact release, and the row-open date is the same date as the feed observation.

## Fresh observations

Exact fetch argv (both under `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS024/home`; exit 0):

```text
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS024/home /bin/bash -c 'curl -fsSL --compressed -A "kagi-shokunin-round25/1.0 (documentation verification)" -o /fast/scratch/kagi-r25/FClockS024/fetch/S024-page.html -w "http=%{http_code} final=%{url_effective} bytes=%{size_download}\n" https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2; rc=$?; printf "curl_exit=%s\n" "$rc"; exit "$rc"' && sha256sum /fast/scratch/kagi-r25/FClockS024/fetch/S024-page.html && wc -c /fast/scratch/kagi-r25/FClockS024/fetch/S024-page.html
stdout: http=200 final=https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 bytes=43085; curl_exit=0; sha256=5ebc8281287e35b69a88b3f371320049070fcdcb5d11de5d772e1ae0dc071cda; file bytes=586146

env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS024/home /bin/bash -c 'curl -fsSL --compressed -A "kagi-shokunin-round25/1.0 (documentation verification)" -o /fast/scratch/kagi-r25/FClockS024/fetch/S034.atom -w "http=%{http_code} final=%{url_effective} bytes=%{size_download}\n" https://github.com/hashicorp/vault/releases.atom; rc=$?; printf "curl_exit=%s\n" "$rc"; exit "$rc"' && sha256sum /fast/scratch/kagi-r25/FClockS024/fetch/S034.atom && wc -c /fast/scratch/kagi-r25/FClockS024/fetch/S034.atom
stdout: http=200 final=https://github.com/hashicorp/vault/releases.atom bytes=303995; curl_exit=0; sha256=e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba; file bytes=303995
```

- Current feed SHA/size exactly match `corpus/source-fetches.tsv:77` (S034, fetched 2026-10-21, HTTP 200, `decoded-http-body-volatile-v1`). Feed quote `<title>v2.2.0</title>` count 1 under its declared `raw-literal-v1` profile.
- Independent all-entry stable parse of the saved Atom body (10 entries): `stable_X.Y.Z=8`; semver maximum `v2.2.0`, updated `2026-10-15T18:50:14Z`, link `https://github.com/hashicorp/vault/releases/tag/v2.2.0`. Next stable tags are `v2.1.2`, `v2.1.1`, `v2.1.0`, `v2.0.4`. The same feed contains `v2.2.0-rc1` and `sdk/v0.26.0`; neither passes the exact stable `vX.Y.Z` filter. Thus current stable `v2.2.0` matches TSV `observed_version=2.2.0`, its date, and `not-fired` (observed equals derived anchor).
- S024 fetch evidence is `source-fetches.tsv:51`: quote `max_versions (int: 0) – The number of versions to keep per key.`, `rendered-text-v1`, volatile decoded-body representation. Exact recheck: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS024/home PYTHONDONTWRITEBYTECODE=1 python3 -B /fast/scratch/kagi-r25/FClockS024/lane/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/FClockS024/fetch/S024-page.html` → exit 0, `raw_sha256=5ebc8281287e35b69a88b3f371320049070fcdcb5d11de5d772e1ae0dc071cda bytes=586146 normalized_sha256=7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715 normalized_bytes=24395`.
- Exact declared quote check: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS024/home PYTHONDONTWRITEBYTECODE=1 python3 -B /fast/scratch/kagi-r25/FClockS024/lane/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS024/fetch/S024-page.html 'max_versions (int: 0) – The number of versions to keep per key.'` → exit 0, `RENDERED_TEXT_V1_LOCATE: count=3`.
- The raw page SHA differs from the prior capture SHA in `source-fetches.tsv:51` (`aaf52ac25695b1bb8ac6cba4f5e67abe27a35700619c9fa88b7bb292571c1008`), but the byte count is the same and normalized SHA exactly matches its pin (`7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715`). With the declared volatile raw representation, raw-hash inequality alone is not semantic drift.

## Calibration / limits

The surviving declared quote directly supports only the `max_versions` part. The freshly normalized page also states `delete_version_after (string:"0s") – If set, specifies the length of time before a version is deleted` and shows it separately alongside `max_versions` in the config sample; therefore the broader S024 teaching is supported by the page today. A quote-only test would not establish that second clause: a concrete quote-clock counterexample would be `delete_version_after` removed while the max_versions quote remains. S024 is a **feed** clock, so page-only edits between Vault releases are not observed by the bound feed; today's independent page check found no such counterexample. This does not establish runtime behavior or any deployment's configuration.

**Falsifier tested:** any newer stable Vault `X.Y.Z` in the bound feed would contradict frozen `observed_version=2.2.0` / `not-fired`; none occurs in the 8 stable entries. **UNRUN:** `corpus/release-clock.py --observe` (not run from the ledger, per bounds); full `verify`/`cells`, API-authenticated endpoints, and Vault runtime/deployment checks. No tools installed.