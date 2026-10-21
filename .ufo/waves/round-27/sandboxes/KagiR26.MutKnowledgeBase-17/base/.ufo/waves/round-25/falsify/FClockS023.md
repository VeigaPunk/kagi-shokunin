# FClockS023 — S023 feed-clock falsification (C3)

Seat KagiR25.FClockS023-4 (leaf). 2026-10-21. Lane revision 82745e2c60e726b49499b8f309529935dc4eff2b
(`git -C <sandbox>/lane rev-parse HEAD` after `clone --no-hardlinks` + `checkout -q`). Sandbox
`/fast/scratch/kagi-r25/FClockS023`; runs under `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`,
`PYTHONDONTWRITEBYTECODE=1 python3 -B`. Installs/updates: none (none needed). No REST API, no vault
execution, no lane gate verify/cells on the real tree; prior `build/ClockS023.md` treated as evidence, not authority.

## Verdict: PASS (no falsifier found)
Frozen row matches live observation on every declared axis; the derived-anchor rationale is
reproducible from today's feed; the volatile/raw hash split is confirmed, not semantic drift.

## 1. Frozen rows read (sandbox)
- `corpus/release-clocks.tsv:20`: `S023  feed  S034  https://github.com/hashicorp/vault/releases.atom  2.2.0  2.2.0  2026-10-21  not-fired  derived: anchor names the served v2.x route; newest stable Vault when opened 2026-10-20 (v2.2.0)`
- `corpus/source-fetches.tsv:50`: mined, identity sha `131e6a20…`, url=final_url=…/vault/docs/concepts/lease, 200, curl-fsSL-compressed-v1, 2026-10-21, decoded-http-body-volatile-v1, sha `de5f8836…`, 261632 bytes, pin `-`, quote "All dynamic secrets in Vault are required to have a lease.", rendered-text-v1, normalized `0e62e056…`, H1 "Lease, renew, and revoke".
- `corpus/SOURCES.md:29` (S023, opened 2026-10-20, on-release, supersedes S013) and `:40` (S034 feed, tier A, recheck 90d, excludes `sdk/` and `-rc`, quote "<title>v2.2.0</title>", fetched 2026-10-21).

## 2. Feed reopened (declared profile)
`curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o vault.atom -w '…' https://github.com/hashicorp/vault/releases.atom` → exit 0; `http=200 bytes=303995`; sha256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba` — byte-identical to the frozen receipt `.ufo/waves/round-25/observe-1.json` S023 (`"sha256": "e41bc579…", "parsed_version": "2.2.0", "verdict": "not-fired", observed_at 2026-10-21T11:31:53Z`) and to the prior author's capture.
Independent parse (own ElementTree + `^v\d+\.\d+\.\d+$`): 10 entries; newest stable **v2.2.0** updated `2026-10-15T18:50:14Z`, link `/releases/tag/v2.2.0`; excluded titles `v2.2.0-rc1`, `sdk/v0.26.0` (2/10). Matches frozen observed/anchored 2.2.0 → **not-fired confirmed**. `grep -c '<title>v2.2.0</title>' vault.atom` → 1 (S034 quote byte-locates; first entry is v2.2.0; max `updated` over all entries = 2026-10-15T18:50:14Z).

## 3. Page reopened
Same argv against `https://developer.hashicorp.com/vault/docs/concepts/lease` → exit 0; `http=200`; decoded 261632 bytes; raw sha256 `492ffb3c2ae8e65daa89aabae99e93b80b3081d46b3e2cdee2a61bffe0efafde` — third distinct raw digest for this URL (frozen `de5f8836…`, prior author `ac99140f…`) at an identical byte count.
`python3 -B corpus/rendered-text-v1.py digest lease.body` → exit 0; `normalized_sha256=0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76` = row value, 7354 normalized bytes. **Normalized attestation reproduces; raw divergence is exactly the declared volatile-v1 class** (per-response chrome), not drift.
Locates (rendered-text-v1): lease sentence count=1 (exit 0); H1 count=2 (exit 0); "The Key Value Backend which stores arbitrary secrets does not issue leases" count=1 (exit 0) — the KV note exists only in normalized text; raw HTML splits it across markup (`does not issue leases although it will sometimes return a\nlease duration`), which is why locate runs on the normalizer, not raw bytes.
Route locator: `v2.x (latest)` present; edit link `content/vault/v2.x/content/docs/concepts/lease.mdx` present. The page names only the route, never a release — the `derived:` classification is correct and necessary; a `version_is_named` anchor check against the S023 anchor cell would fail (verified by design: gate counts it in derived=15).

## 4. Derived-anchor rationale re-derivation
Note claims "newest stable Vault when opened 2026-10-20 (v2.2.0)". Today's feed shows no entry with `updated` later than v2.2.0's 2026-10-15T18:50:14Z and the feed carries the 10 most recent releases; any stable release published 2026-10-16…20 would still be present today. It is not. So v2.2.0 was newest stable on the open date — derivable from the feed itself, not just asserted. [INFERENCE on GitHub's window semantics: Atom keeps the 10 most recent; consistent with 10 entries observed.]

## 5. Tooling cross-check (isolated, sandbox tree)
`python3 -B corpus/release-clock.py` (offline bind check) → `RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)`, exit 0 — S023 counted observed+derived; the one fired is S012 per lessons. `--selftest` → `RELEASE_CLOCK_SELFTEST: PASS (48 cases)`, exit 0.

## 6. Does the surviving quote support the teaching?
Yes, all three legs re-verified today: dynamic-secret lease sentence (declared quote), static-KV no-lease note, and the version-route locator `v2.x (latest)`. The S013 supersession (withdraw the categorical no-displayed-version locator; a served v2.x route is not deployment proof) remains consistent with the served page. The declared quote alone covers only the lease leg; the KV leg is covered by the H1/second quote column and registry summary, both re-located.

## 7. Limits / falsifier surfaces (honest)
1. S023's clock sees product releases only; a docs-side rewrite of the lease page fires nothing (recheck on-release binds the registry row, the feed is 90d). Quotes are re-locatable attestations, not a fireable page-content clock.
2. Once v2.2.0 rotates out of GitHub's ~10-entry window, the 2026-10-20 derived-anchor attestation lives only in the frozen TSV (declared R25-C8, counted `derived=15`).
3. `updated` is last-update time, not publish time (prior author F1); derivation uses titles, so unaffected, but an edited old release can reorder entries without changing max-stable.
4. recheck 90d lives on source row S034, not the clock row; unbind checks (url equality, kind, not-on-release) exercised by the CLEAN run.
5. UNRUN: GitHub REST `releases/latest` and `releases.hashicorp.com/vault/index.json` cross-checks (contract: no API auth, prefer Atom; unauthenticated quota exhausted on this egress per prior author; not the declared sources). UNRUN: fresh `release-clock.py --observe` (28 clocks; scoped rows only per seat bounds — frozen receipt + byte-identical feed substitute).
