# ClockS024 — round 26 C1 freshness re-verification of S024 (KV v2 API, max_versions)

Seat KagiR26.ClockS024 (leaf, no subagents). Observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`; worktree shows only untracked `.ufo/waves/round-26/` and `plans/round-26.md`). Production files read only. Writes: this report plus `.ufo/waves/round-26/build/ClockS024-artifacts/` (kv-v2.body/.headers, vault-releases.atom/.headers). No installs. No verification gate, build, lint or test run.

## Verdict (bounded)

- **Teaching: unchanged, still holds** at the declared anchor `POST /:secret-mount-path/config` → Parameters → `max_versions`.
- **Clock: not fired.** S034 Vault Atom feed still shows newest stable `v2.2.0` (updated 2026-10-15T18:50:14Z), equal to anchored/observed `2.2.0` in `corpus/release-clocks.tsv:21`.
- **Capture: normalized digest reproduces exactly** (`7c5a19e2…a715`); the raw-body digest differs, as the row's `decoded-http-body-volatile-v1` representation predicts.
- **No Python drift applies to S024.** The Python 3.15.1 / 3.15.0 comparison belongs to S027/S028. This row depends on Vault and is not bound to the CPython feed.

## Rows inspected

- `corpus/SOURCES.md:30`: S024, docs, A, mined 2026-10-21, `on-release`. Quote: “max_versions (int: 0) – The number of versions to keep per key.” (POST /:secret-mount-path/config parameters).
- `corpus/release-clocks.tsv:21`: `S024 feed S034 https://github.com/hashicorp/vault/releases.atom 2.2.0 2.2.0 2026-10-21 not-fired`. Note: “derived: served v2.x (latest) route, no version in the anchor; newest stable Vault when opened 2026-10-21 (v2.2.0)”.
- `corpus/source-fetches.tsv:51`: raw sha256 `aaf52ac2…1008`, 586146 B, `curl-fsSL-compressed-v1`, `decoded-http-body-volatile-v1`. Normalized digest under `rendered-text-v1` is `7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715`.

## Source re-open (2026-10-21T13:36:36Z)

Command (cwd `.ufo/waves/round-26/build/ClockS024-artifacts`):
`curl -fsSL --compressed -D kv-v2.headers -o kv-v2.body https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2` → exit 0

- HTTP/2 200; `date: Wed, 21 Oct 2026 13:36:37 GMT`; `etag: W/"6876f32501201253e7da34943c9c4feb"`; `age: 7497` (CDN-cached about 2.1 h); `content-type: text/html; charset=utf-8`. No `last-modified` header.
- Raw: sha256 `5ebc8281287e35b69a88b3f371320049070fcdcb5d11de5d772e1ae0dc071cda`, 586146 B. This is the same length as the recorded body, but the sha256 differs.
- `python3 corpus/rendered-text-v1.py digest …/kv-v2.body` → `normalized_sha256=7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715 normalized_bytes=24395`, exit 0. **This matches source-fetches.tsv:51 exactly.** The rendered text is therefore byte-identical to the round-23/25 capture, and the raw difference is chrome only.
- `… locate … 'max_versions (int: 0) – The number of versions to keep per key.'` → `count=3`, exit 0.
- Version marker in the rendered text: “KV version 2 v2.x (latest) Vault v2.x (latest) v1.21.x …”. The source link is `content/vault/v2.x/content/api-docs/secret/kv/kv-v2.mdx`.

Located teaching at the declared anchor (normalized offset 3270, 25 words or fewer):
> “max_versions (int: 0) – The number of versions to keep per key. This value applies to all keys, but a key's metadata setting can overwrite this value.”

The separate deletion parameter appears in the same config parameter list:
> “delete_version_after (string:"0s") – If set, specifies the length of time before a version is deleted.”

Both halves of the row's teaching are still present: `max_versions` caps retained versions per key, and `delete_version_after` is a separate parameter. The row's scope limit ("configuration only, not a deployment or KV-retention guarantee") stays correct, and the page's own override sentence supports it.

## Clock re-open (S034 feed)

`curl -fsSL --compressed -D vault-releases.headers -o vault-releases.atom https://github.com/hashicorp/vault/releases.atom` → exit 0. HTTP/2 200, `date: Wed, 21 Oct 2026 13:36:37 GMT`, `etag: W/"e41bc5793403136a07c68d7d107fe3e9"`, sha256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`, 303995 B.

First entries (title, updated):

| title | updated |
|---|---|
| v2.2.0 | 2026-10-15T18:50:14Z |
| v2.2.0-rc1 | 2026-10-08T19:26:16Z |
| v2.1.2 | 2026-10-08T19:26:01Z |
| sdk/v0.26.0 | 2026-09-24T16:09:38Z |
| v2.1.1 | 2026-09-17T00:03:12Z |

Filtering titles with `^v\d+\.\d+\.\d+$` gives the stable order `v2.2.0, v2.1.2, v2.1.1`. The newest stable tag is still 2.2.0, so the anchored version equals the observed version and the clock has not fired. (Parsed by an ad hoc Python regex over the fetched file. I did not run `corpus/release-clock.py`.)

## Counterexamples and limits (actionable)

1. **The quote alone is ambiguous.** It occurs 3 times in the rendered text:
   - offset 3270, under `POST /:secret-mount-path/config`;
   - offset 19988, under the metadata update endpoint, followed by “If not set, the backend’s configured max version is used.”;
   - offset 21911, under the metadata patch endpoint.

   A quote-presence check (`locate` count ≥ 1) cannot tell whether the config-anchor teaching survived. If the config section were removed or reworded, `locate` would still pass on the two per-key metadata copies, and those teach a different scope (per-key override). Any S024 re-verification needs the anchor-scoped context (the text following `POST /:secret-mount-path/config … Parameters`), not just the count. This round's normalized-digest equality covers it.
2. **The feed clock is derived.** The anchor names no version. The served route is “v2.x (latest)”, which spans every 2.x release, and `release-clocks.tsv:21` says so. The feed tracks release tags, not docs edits, so a docs-only change between releases would not fire this clock. Only a rendered-text re-capture detects that kind of change, as this report did by digest.
3. **The raw digest is volatile.** It has changed at least once since the recorded capture with equal byte length. It is not a usable freshness signal, so use the normalized digest.
4. **The page itself has extra precision.** It also says “When 0 is used or the value is unset, Vault will keep 10 versions.” The row does not claim a default, so no correction is needed. A future reading of "int: 0" as "unlimited" would be wrong.

## Historical receipt preservation

I did not modify the round-25 seat report `.ufo/waves/round-25/build/ClockS024.md`, which proposed a `rendered-quote` clock. The round-25 integrated binding (`release-clocks.tsv:21`, feed/S034, not-fired) is still accurate as of this fetch. I propose no registry, TSV or superseding row for S024, because no immutable registry fact changed. Round 26's freshness count for S024 is **unchanged / not-fired / teaching holds**.

## Not done

I did not run any production verification (gate, `release-clock.py`, `sources-census.sh`, selftests). I opened only the two public URLs above.
