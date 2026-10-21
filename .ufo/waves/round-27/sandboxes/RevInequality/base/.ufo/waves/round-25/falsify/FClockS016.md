# FClockS016 — C3 freshness recheck

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (clone in `/fast/scratch/kagi-r25/FClockS016-4/lane`; exact frozen candidate).
Observed: 2026-10-21. No installs; no API authentication, Vault/OpenBao execution, or product probe.

## Verdict

- **PASS — current C3 observation:** S016 remains `not-fired`; independently parsed bound OpenBao Atom feed's newest stable server tag is `v2.7.1`, matching `observed_version=2.7.1`. Excluded module tags (`api/`, `sdk/`) and prerelease `v2.7.0-beta20260909`.
- **PASS — page/quote:** page is HTTP 200 under the registered fetch profile; exact quote locates once under “Token hierarchies and orphan tokens”. Live raw and normalized hashes match the same-day S016 `source-fetches.tsv` capture.
- **Qualification — derived, not named:** live docs identify the `2.7.x` series, not patch `v2.7.1`. `release-clocks.tsv` explicitly marks this as `derived:`; R25-C8 (`corpus/lessons/round-25.md:71-79`) defines the derivation as newest stable release on the feed when opened. Today's feed is consistent with the 2026-10-19 note (its latest stable entry is updated 2026-10-01), but I did not independently retrieve a frozen 10/19 feed snapshot. If the contract requires the documentation anchor itself to name an exact patch, that remains unsupported; it is not a mismatch under R25-C8.
- The located quote supports the specific parent-token → child-token/lease revocation claim. It does not alone evidence the full S016 summary about policies and TTL/renewal; those appear elsewhere on the same live page (policy explanation and §Token Time-To-Live text). Keep product scope OpenBao-only; the knowledge entry withdraws unqualified “periodic tokens renew indefinitely” (`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:150-156`).
- **No current freshness falsifier found.** S016's old in-row digest `c083fdca…` is separately classified `non-reproducing` (`corpus/inrow-pins.tsv:22`) and S026 supersedes the old locator (`corpus/SOURCES.md:32`). Do not treat that legacy hash mismatch as semantic drift: both current HTTP bodies are declared `decoded-http-body-volatile-v1` point captures, not drift pins (`corpus/source-fetches.tsv:17-23,37-42`).

## Commands and evidence

Clone argv: `mkdir -p /fast/scratch/kagi-r25/FClockS016-4 && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FClockS016-4/lane && git -C /fast/scratch/kagi-r25/FClockS016-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C /fast/scratch/kagi-r25/FClockS016-4/lane rev-parse HEAD` → stdout `82745e2c60e726b49499b8f309529935dc4eff2b`; exit 0.

Registered profile from `corpus/source-fetches.tsv:14-15`: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`.

Docs argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS016-4/home curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' --output /fast/scratch/kagi-r25/FClockS016-4/s016-profile.html --write-out 'http_code=%{http_code}\nurl_effective=%{url_effective}\nsize_download=%{size_download}\ncontent_type=%{content_type}\n' https://openbao.org/docs/concepts/tokens/` → stdout `http_code=200`, `url_effective=https://openbao.org/docs/concepts/tokens/`, `size_download=12527`, `content_type=text/html; charset=utf-8`, `curl_exit=0`; fetched 2026-10-21. `rendered-text-v1.py digest` stdout: `raw_sha256=5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c bytes=47384 normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608`; exit 0 (matches `source-fetches.tsv:69`).

Quote argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS016-4/home PYTHONDONTWRITEBYTECODE=1 python3 -B /fast/scratch/kagi-r25/FClockS016-4/lane/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS016-4/s016-profile.html 'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'` → stdout `RENDERED_TEXT_V1_LOCATE: count=1`, `python_exit=0`.

Feed argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS016-4/home curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' --output /fast/scratch/kagi-r25/FClockS016-4/s035-profile.atom --write-out 'http_code=%{http_code}\nurl_effective=%{url_effective}\nsize_download=%{size_download}\ncontent_type=%{content_type}\n' https://github.com/openbao/openbao/releases.atom` → stdout `http_code=200`, `url_effective=https://github.com/openbao/openbao/releases.atom`, `size_download=506783`, `content_type=application/atom+xml; charset=utf-8`, `curl_exit=0`; fetched 2026-10-21. Feed SHA-256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`, equal to S035 `source-fetches.tsv:78`.

Offline Atom parse argv: Python `xml.etree.ElementTree` over that file; retain release-tag paths matching exact `^v[0-9]+\\.[0-9]+\\.[0-9]+$`, then sort numeric semver (exclude slash tags/prereleases). Exit 0; stdout: `feed_entries=10`; stable server tags `v2.7.1` (`updated=2026-10-01T18:32:18Z`), `v2.7.0` (`2026-09-23T17:39:54Z`), `v2.6.4` (`2026-10-01T13:59:14Z`), `v2.6.3` (`2026-09-23T17:06:02Z`). The Atom `updated` value is not asserted as a publication timestamp.

Clock row: `corpus/release-clocks.tsv:13` records `S016 feed S035 … anchored=2.7.1 observed=2.7.1 observed_at=2026-10-21 not-fired derived: … 2026-10-19 (v2.7.1)`. S035's scope and feed quote are `corpus/SOURCES.md:41`; S016's registered quote/profile are `corpus/source-fetches.tsv:69`.

**UNRUN:** `release-clock.py`, gate `verify`/`cells`, and any product/runtime behavior test (not needed for this source recheck; no production-tree gate run).