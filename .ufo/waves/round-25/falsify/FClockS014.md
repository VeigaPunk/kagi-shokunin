# FClockS014 — C3 release-clock falsification

Observed 2026-10-21. Sandbox: `/fast/scratch/kagi-r25/FClockS014-4/lane`.
Frozen revision: `82745e2c60e726b49499b8f309529935dc4eff2b`.
`git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FClockS014-4/lane && git -C /fast/scratch/kagi-r25/FClockS014-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C /fast/scratch/kagi-r25/FClockS014-4/lane rev-parse HEAD`
stdout: `82745e2c60e726b49499b8f309529935dc4eff2b`; exit 0.

## Verdict

**PASS — no C3 clock falsifier.** `corpus/release-clocks.tsv:11` records S014 as
`2.7.1 / 2.7.1 / 2026-10-21 / not-fired`. Reopened page and feed match the
frozen capture bytes and independently yield OpenBao's newest stable server
release `v2.7.1`, within the documented `2.7.x` line. No `api/`, `sdk/`, or
beta tag was counted. The page has `Version: Version 2.7.x` and links the
`release/2.7.x` source branch (both observed once). Feed's `v2.7.1` entry has
`updated=2026-10-01T18:32:18Z`; Atom has no `<published>` value, so this is an
updated timestamp, not a separately verified publication timestamp.

**PASS with scope limit — captured quote locates and the page backs the full
teaching across sections.** The captured quote alone supports OIDC or direct
JWT authentication, not signature verification or claim handling. Those are
separately stated under `JWT verification`, `Bound claims`, and `Claims as
metadata`. **FAIL (legacy prose only):** `SOURCES.md:20`'s uppercase, shortened
teaches-quote does not locate case-sensitively; it is not the declared capture
quote. `SOURCES.md:31` (S025) supersedes S014 with corrected quote/locators.

## Evidence and commands

- Source pointers: `corpus/release-clocks.tsv:11`; `corpus/source-fetches.tsv:67`
  (S014 page quote/profile and capture digests); `corpus/SOURCES.md:20` (S014),
  `:31` (S025 correction), `:41` (S035 feed). Quote normalizer:
  `corpus/rendered-text-v1.py:10-43,49-53`.
- Page argv: `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FClockS014-4/fetch-page.html -w 'HTTP %{http_code}\nURL %{url_effective}\n' https://openbao.org/docs/auth/jwt/` (under `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS014-4/home`). stdout: `HTTP 200`; `URL https://openbao.org/docs/auth/jwt/`; `sha256 449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9`; `63046` bytes; exit 0. Raw digest and normalized digest `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403` (15,942 bytes) match S014's receipt.
- Feed argv: `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FClockS014-4/fetch-feed.atom -w 'HTTP %{http_code}\nURL %{url_effective}\n' https://github.com/openbao/openbao/releases.atom` (same clean env). stdout: `HTTP 200`; `URL https://github.com/openbao/openbao/releases.atom`; `sha256 1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`; `506783` bytes; exit 0. Digest matches S035 receipt.
- Feed parser argv (clean env: `PATH=/usr/bin:/bin`, `HOME=/fast/scratch/kagi-r25/FClockS014-4/home`, `PYTHONDONTWRITEBYTECODE=1`):
  `python3 -B -c 'import re,xml.etree.ElementTree as E; p="/fast/scratch/kagi-r25/FClockS014-4/fetch-feed.atom"; root=E.parse(p).getroot(); ns={"a":"http://www.w3.org/2005/Atom"}; rows=[]; stable=[]`
  `for ent in root.findall("a:entry",ns):`
   t=ent.findtext("a:title",default="",namespaces=ns); pub=ent.findtext("a:published",default="",namespaces=ns); upd=ent.findtext("a:updated",default="",namespaces=ns); m=re.fullmatch(r"v?(\d+)\.(\d+)\.(\d+)",t)
  ` rows.append((t,pub,upd))`
  ` if m: stable.append((tuple(map(int,m.groups())),t,pub,upd))`
  `print("entries=%d"%len(rows)); print("titles="+" | ".join(t for t,_,_ in rows)); stable.sort(); print("stable_main_server_candidates="+str(len(stable))); print("newest_stable="+(" | ".join(stable[-1][1:]) if stable else "NONE"))'`
  stdout: `entries=10`; `stable_main_server_candidates=4`; `newest_stable=v2.7.1 |  | 2026-10-01T18:32:18Z`; exit 0. Titles also include `v2.6.4`, `v2.7.0`, `v2.6.3`, `api/v2.7.1…`, `sdk/v2.7.1…`, and `v2.7.0-beta20260909`; only full stable `vX.Y.Z` titles entered the semver sort.
  This extracted Atom `<updated>` but no `<published>`; the exact `v2.7.1` entry links to `https://github.com/openbao/openbao/releases/tag/v2.7.1`.
- Normalizer argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS014-4/home PYTHONDONTWRITEBYTECODE=1 python3 -B /fast/scratch/kagi-r25/FClockS014-4/lane/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/FClockS014-4/fetch-page.html`; stdout: `raw_sha256=449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9 bytes=63046 normalized_sha256=ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403 normalized_bytes=15942`; exit 0.
- Normalizer locate argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS014-4/home PYTHONDONTWRITEBYTECODE=1 python3 -B /fast/scratch/kagi-r25/FClockS014-4/lane/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS014-4/fetch-page.html 'The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT'`; stdout `RENDERED_TEXT_V1_LOCATE: count=1`; exit 0. Same argv with query `The JWT auth method can be used to authenticate with OpenBao using OIDC` returned `count=0`; exit 1. This is why the captured rendered quote in `source-fetches.tsv:67` (profile `rendered-text-v1`) was used, not the teaches cell.
- Current-page excerpt argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS014-4/home PYTHONDONTWRITEBYTECODE=1 python3 -B -c 'import runpy; p="/fast/scratch/kagi-r25/FClockS014-4/lane/corpus/rendered-text-v1.py"; f="/fast/scratch/kagi-r25/FClockS014-4/fetch-page.html"; norm=runpy.run_path(p)["normalize_bytes"]; t=norm(open(f,"rb").read()).decode();`
  `for q in ["Version: Version 2.7.x","JWT verification","JWT signatures will be verified","Bound claims","claim_mappings"]:`
  ` i=t.find(q); print("QUERY %r count=%d"%(q,t.count(q))); print((t[max(0,i-180):i+380] if i>=0 else "NOT FOUND"))'`; exit 0.
  stdout excerpts: `Version: Version 2.7.x` count 1; `JWT signatures will be verified against public keys from the issuer`; `Bound claims Once a JWT has been validated as being properly signed and not expired ... arbitrary claims through the bound_claims map`; `Claims as metadata Data from claims can be copied into the resulting auth token and alias metadata by configuring claim_mappings`.

## Limits / UNRUN

- **UNRUN:** historical feed snapshot from 2026-10-19 was not available/replayed; the derived-on-open date is consistent with the current feed's 2026-10-01 v2.7.1 update and current 2.7.x page, but only the 2026-10-21 live observation was independently fetched.
- No API authentication, vault/product execution, gate `verify`/`cells`, install, or production edit. Hash changes would be representation evidence only; these page/feed raw and normalized digests actually equal the frozen receipts.
