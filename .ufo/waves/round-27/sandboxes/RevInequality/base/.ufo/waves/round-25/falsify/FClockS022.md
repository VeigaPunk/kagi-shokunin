# FClockS022 — C3 S022 source check

- Candidate: `82745e2c60e726b49499b8f309529935dc4eff2b`; sandbox `/fast/scratch/kagi-r25/FClockS022/lane`; `git rev-parse HEAD` stdout matched exactly, exit 0.
- Axes: freshness (re-open feed/page), calibration (derived anchor), operability (registered feed and quote/profile).
- No tool installs; no API auth, Vault execution, account/vault/handler/CDP contact, or lane Git mutation.
- LSP unavailable: `read xd://lsp` returned “No such tool”; only static row reads/searches used, not semantic symbol/caller evidence.

## Frozen record

- `corpus/release-clocks.tsv:19`: S022 feed S034; anchored/observed `2.2.0`; `2026-10-21`; `not-fired`; note derives 2.2.0 from the newest stable Vault when opened 2026-10-20, distinguishing the 1.17 feature note from the served page.
- `corpus/source-fetches.tsv:49`: S022 page capture HTTP 200, profile `curl-fsSL-compressed-v1`, representation `decoded-http-body-volatile-v1`; quote is the exact `bound_audiences` sentence; locate profile `rendered-text-v1`; normalized digest `06d2508c…`.
- `corpus/source-fetches.tsv:77`, `corpus/SOURCES.md:40`: S034 is the Vault Atom release feed; stable product tags only, excluding `sdk/` tags and prereleases.
- `corpus/SOURCES.md:28`: S022 teaches JWT-role exact audience match when `aud` exists, separate from optional OIDC role setting; opened 2026-10-20, `on-release`.
- Reviewed prior `.ufo/waves/round-25/build/ClockS022.md` as non-authoritative pre-integration evidence; its older 1.17/fired proposal is not the frozen row.

## Re-opened evidence (2026-10-21 UTC)

- `date -u '+%Y-%m-%dT%H:%M:%SZ'` → `2026-10-21T12:10:30Z`, exit 0 (captured concurrently with the two requests).
- Page argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS022/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FClockS022/vault-jwt.html -w 'http=%{http_code} bytes=%{size_download}\n' https://developer.hashicorp.com/vault/docs/auth/jwt` → `http=200 bytes=53360`, exit 0; saved-body SHA-256 `4b4a151d5f0c92925e89a1c44a2478de602c5742568c60dab53a1b3843b2638e`.
- Feed argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS022/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FClockS022/vault-releases.atom -w 'http=%{http_code} bytes=%{size_download}\n' https://github.com/hashicorp/vault/releases.atom` → `http=200 bytes=303995`, exit 0; SHA-256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba` (303995 bytes; equals S034 capture at `source-fetches.tsv:77`).
- Independent Atom scan argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS022/home python3 -B -c 'import re,sys,xml.etree.ElementTree as E; r=E.parse(sys.argv[1]).getroot(); ts=[t.text.strip() for t in r.iter() if t.tag.endswith("title") and t.text]; vs=[(tuple(int(x) for x in m.groups()),t) for t in ts for m in [re.fullmatch(r"(?:[A-Za-z]+ )?v?(\d+)\.(\d+)\.(\d+)",t)] if m]; print("entries=%d stable_titles=%d"%(len(r.findall(".//{*}entry")),len(vs))); print("latest_stable="+repr(max(vs))); print("excluded="+repr([t for t in ts if "-rc" in t or "/" in t]))' /fast/scratch/kagi-r25/FClockS022/vault-releases.atom` → `entries=10 stable_titles=8`; `latest_stable=((2, 2, 0), 'v2.2.0')`; excluded `v2.2.0-rc1`, `sdk/v0.26.0`; exit 0. Entry updated `2026-10-15T18:50:14Z`.
- An earlier display-only version of that parser exited 1 with a Python tuple-formatting `TypeError` after printing `entries=10`/`stable_count=8`; it was not relied on. The corrected exact invocation above succeeded.
- Page `rendered-text-v1 digest` argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS022/home python3 -B corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/FClockS022/vault-jwt.html` → `raw_sha256=4b4a151d… bytes=386435 normalized_sha256=06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431 normalized_bytes=18609`, exit 0. Raw hash/size differs from S022's recorded `9a65b9d1…`/386400; normalized digest is equal, so this is volatile markup/body representation, not semantic drift.
- Quote argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS022/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS022/vault-jwt.html 'the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT.'` → `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0.

## Verdict

- **PASS (freshness):** current max stable Vault release remains `v2.2.0`; its Atom update date precedes the 2026-10-20 row open. Frozen `observed_version=2.2.0`, `observed_at=2026-10-21`, `not-fired` matches the re-opened feed. A stable server tag newer than 2.2.0 would falsify `not-fired`; none appeared in the 10 feed entries.
- **PASS (anchor rationale, with historical limit):** current page navigation shows `v2.x (latest)` twice; the 1.17 text is explicitly a “Starting in Vault 1.17” feature note. The current newest stable release is 2.2.0, consistent with the derived anchor. No 2026-10-20 feed snapshot is committed, so the exact historical feed state on open date is not independently proved.
- **PASS (quote supports JWT clause); partial if treated as sole evidence for the whole teaching:** the surviving declared quote directly says JWT-role `bound_audiences` must match an `aud` claim, in context conditioned on an `aud` claim being present. It does not itself establish OIDC optionality; the reopened page separately contains “bound_audiences is optional for OIDC roles and typically not required” once, so the broader S022 scope is supported by the page, not by that one quote alone.
- **FAIL:** none observed; no current feed-version, quote-locator, or normalized-page mismatch.
- **UNRUN:** full `release-clock.py --observe` and whole-tree gates; no historical capture from 2026-10-20 to compare.
- `corpus/release-clock.py:535-580` documents max stable X.Y.Z parsing over feed entries; no production repair or candidate mutation made.