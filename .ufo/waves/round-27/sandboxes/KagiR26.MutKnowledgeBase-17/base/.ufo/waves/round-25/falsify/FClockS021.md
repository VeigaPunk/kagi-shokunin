# FClockS021 — C3 S021 falsification

**Result: PASS — no clock falsifier found, observed 2026-10-21.** S021's frozen `2.7.1 / not-fired` remains consistent with the current page and bound feed.

## Frozen evidence and findings
- Frozen revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (`git rev-parse HEAD`, exit 0).
- `corpus/release-clocks.tsv:18`: S021 is feed-bound to S035, anchored/observed `2.7.1`, `2026-10-21`, `not-fired`; note says derived from the latest stable server release when opened `2026-10-20`.
- `corpus/SOURCES.md:27`: S021 anchor says `Version 2.7.x, opened 2026-10-20`; `:41` identifies S035 as the OpenBao server-release feed and excludes module releases/betas.
- `corpus/source-fetches.tsv:48,78`: S021 page capture profile `curl-fsSL-compressed-v1`, quote profile `rendered-text-v1`; S035 feed capture uses the same request profile and `raw-literal-v1` quote `<title>v2.7.1</title>`.
- **PASS — feed:** at `2026-10-21T12:13:34Z`, current feed is HTTP 200. Independent exact-title parser (only `vN.N.N`, excluding `api/`, `sdk/`, prereleases) finds 10 entries, 4 stable server tags; newest `v2.7.1`, entry updated `2026-10-01T18:32:18Z`; next stable titles `v2.7.0`, `v2.6.4`, `v2.6.3`. Frozen observed version matches; `not-fired` is correct.
- **PASS — derived rationale:** current feed places v2.7.1 before the opening date, with no newer stable server tag; the live normalized page contains `Version 2.7.x` (3 occurrences, repeated navigation text). This is consistent with the derived anchor. **[INFERENCE]** A feed fetched 2026-10-21 cannot independently prove its exact historical state on 2026-10-20.
- **PASS, scoped — page/quote:** page HTTP 200 and rendered quote count is 1: “After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked.” This supports TTL expiry and associated-lease revocation. It does **not by itself** establish service-versus-batch differences; the page separately has a `Token type comparison` chart (`Can have Explicit Max TTL Yes No (always uses a fixed TTL)`). The quote locator `Token Time-To-Live` matches twice, so that locator is non-unique; the recorded quote is unique.
- Live S021 body is 47,384 bytes, SHA-256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`; rendered digest `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` (14,608 bytes). Both equal the frozen capture. S035 body is 506,783 bytes, SHA-256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`, also equal to its capture. Hash equality is representation identity; the no-drift result is based on release semantics and quote location, not hash alone.

## Exact commands and results
```sh
mkdir -p /fast/scratch/kagi-r25/FClockS021 && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FClockS021/lane && git -C /fast/scratch/kagi-r25/FClockS021/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C /fast/scratch/kagi-r25/FClockS021/lane rev-parse HEAD
```
stdout `82745e2c60e726b49499b8f309529935dc4eff2b`; exit 0.

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -w 'HTTP_STATUS:%{http_code} FINAL_URL:%{url_effective}\n' https://openbao.org/docs/concepts/tokens/ -o /fast/scratch/kagi-r25/FClockS021/fetch/s021.html && wc -c /fast/scratch/kagi-r25/FClockS021/fetch/s021.html && sha256sum /fast/scratch/kagi-r25/FClockS021/fetch/s021.html
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -w 'HTTP_STATUS:%{http_code} FINAL_URL:%{url_effective}\n' https://github.com/openbao/openbao/releases.atom -o /fast/scratch/kagi-r25/FClockS021/fetch/s035.atom && wc -c /fast/scratch/kagi-r25/FClockS021/fetch/s035.atom && sha256sum /fast/scratch/kagi-r25/FClockS021/fetch/s035.atom
```
Both exit 0. Page stdout: `HTTP_STATUS:200 FINAL_URL:https://openbao.org/docs/concepts/tokens/`, `47384 .../s021.html`, `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c .../s021.html`. Feed stdout: `HTTP_STATUS:200 FINAL_URL:https://github.com/openbao/openbao/releases.atom`, `506783 .../s035.atom`, `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f .../s035.atom`.

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B -c 'import re,xml.etree.ElementTree as E; p="/fast/scratch/kagi-r25/FClockS021/fetch/s035.atom"; ns={"a":"http://www.w3.org/2005/Atom"}; es=E.parse(p).getroot().findall("a:entry",ns); rows=[]
for e in es:
 t=e.findtext("a:title",default="",namespaces=ns).strip(); m=re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)",t)
 if m: rows.append((tuple(map(int,m.groups())),t,e.findtext("a:updated",default="",namespaces=ns)))
rows.sort(reverse=True); print("entries=%d stable_exact_server_tags=%d newest=%s updated=%s"%(len(es),len(rows),rows[0][1],rows[0][2])); print("stable_titles="+", ".join(x[1] for x in rows))'
```
stdout `entries=10 stable_exact_server_tags=4 newest=v2.7.1 updated=2026-10-01T18:32:18Z` / `stable_titles=v2.7.1, v2.7.0, v2.6.4, v2.6.3`; exit 0. Exact full-title semver matching excludes `api/`, `sdk/`, and prereleases.

`env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B -c 'from pathlib import Path; b=Path("/fast/scratch/kagi-r25/FClockS021/fetch/s035.atom").read_bytes(); q=b"<title>v2.7.1</title>"; print("RAW_LITERAL_COUNT",b.count(q))'` → `RAW_LITERAL_COUNT 1`; exit 0.

```sh
cd /fast/scratch/kagi-r25/FClockS021/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS021/fetch/s021.html 'After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked.'; printf 'EXIT:%s\n' "$?"
cd /fast/scratch/kagi-r25/FClockS021/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/FClockS021/fetch/s021.html; printf 'EXIT:%s\n' "$?"
```
stdout: `RENDERED_TEXT_V1_LOCATE: count=1` / `EXIT:0`; digest `raw_sha256=5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c bytes=47384 normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608` / `EXIT:0`.

`cd /fast/scratch/kagi-r25/FClockS021/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS021/fetch/s021.html 'Version 2.7.x'; printf 'EXIT:%s\n' "$?"; env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS021/fetch/s021.html 'Every non-root token has a time-to-live (TTL) associated with it'; printf 'EXIT:%s\n' "$?"; env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS021/fetch/s021.html 'Can have Explicit Max TTL Yes No (always uses a fixed TTL)'; printf 'EXIT:%s\n' "$?"; env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS021/fetch/s021.html 'Token type comparison'; printf 'EXIT:%s\n' "$?"` → stdout counts `3`, `1`, `1`, `2`, each exit 0.

`cd /fast/scratch/kagi-r25/FClockS021/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS021/fetch/s021.html 'Token Time-To-Live'; printf 'EXIT:%s\n' "$?"` → `RENDERED_TEXT_V1_LOCATE: count=2` / `EXIT:0`.

`env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS021/home date -u +%FT%TZ` → `2026-10-21T12:13:34Z`; exit 0.

## Falsifier and limits
A stable server tag numerically newer than 2.7.1, a zero rendered-quote match, or a current page anchor no longer in the 2.7.x series would falsify the corresponding frozen observation. None observed. **UNRUN:** full `release-clock.py --observe`, lane `verify`/`cells`, and product operations (per per-seat restrictions). No tools installed.