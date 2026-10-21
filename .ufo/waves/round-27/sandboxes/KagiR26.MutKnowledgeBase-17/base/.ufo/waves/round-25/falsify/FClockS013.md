# FClockS013 — C3 release-clock falsification

Revision: frozen candidate `82745e2c60e726b49499b8f309529935dc4eff2b`; isolated clone HEAD matched exactly; worktree clean. Observation: `2026-10-21T12:10:29Z`. No install, API authentication, Vault execution, or production edit.

## Findings

- **Freshness — PASS for the current observation.** `corpus/release-clocks.tsv:10` binds S013 to S034 and records `2.2.0 → 2.2.0`, observed `2026-10-21`, `not-fired`. Reopened S034 Atom feed (HTTP 200) has 10 entries. Numeric stable `X.Y.Z` extraction gives latest Vault `v2.2.0`, updated `2026-10-15T18:50:14Z`; `v2.2.0-rc1` and `sdk/v0.26.0` are excluded. Current result matches the frozen version/date/verdict. S034 fetch capture row 77 has the same body SHA as this fetch.
- **Derived anchor — PARTLY SUPPORTED / historical premise UNVERIFIED.** `SOURCES.md:19` says current docs have “no displayed version/date”; the reopened page displays the selector `v2.x (latest)` and lists version routes (`v1.21.x`, etc.). This falsifies the literal no-displayed-version claim for the current serving, though the selector is a series, not a numbered patch. The feed supports `2.2.0` as latest stable on 2026-10-21 and dates it before the row's 2026-10-19 opening. No S013 page or S034 feed capture from 2026-10-19 is recorded here (both `source-fetches.tsv:66,77` captures are dated 2026-10-21), so “newest stable when opened” is plausible but not independently proven for that date. Historical selector state is likewise unknown.
- **Quote / teaching — PARTIAL (calibration gap).** S013's captured quote is still present once under `rendered-text-v1`: “All dynamic secrets in Vault are required to have a lease.” That directly supports the dynamic-secret requirement. The `teaches` cell in `SOURCES.md:19` additionally says Vault “distinguishes static KV values from leased data”; the quoted sentence alone does not establish that distinction. The current page separately says the Key Value Backend “does not issue leases although it will sometimes return a lease duration,” which supports that bounded no-lease note, not any inference about KV retention, expiry, or deletion.
- **Representation — no demonstrated semantic drift.** Current page body is 261,632 bytes, SHA-256 `492ffb3c2ae8e65daa89aabae99e93b80b3081d46b3e2cdee2a61bffe0efafde`; capture row 66 records a different volatile body digest (`ac99140f…`) at the same size. Re-normalization yields `0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76`, exactly the capture's rendered-text digest, and quote location count is 1. Treat the raw mismatch as volatile representation, not proof of content drift. S013 current fetch profile is `curl-fsSL-compressed-v1`; quote profile is `rendered-text-v1`.
- **Operability — PASS for this binding/parser only.** S013→S034 resolves to the same HTTPS feed URL in the clock, registry, and capture rows; the committed parser and independent Atom extraction agree. Full `release-clock.py --observe` and full gate: **UNRUN** (would observe unrelated rows; not needed for this two-source recheck).

## Reproduction (isolated clone; excerpts are stdout)

- Checkout: `git -C /fast/scratch/kagi-r25/FClockS013-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && printf 'rev=' && git -C /fast/scratch/kagi-r25/FClockS013-4/lane rev-parse HEAD && printf 'status=' && git -C /fast/scratch/kagi-r25/FClockS013-4/lane status --short` — exit 0; `rev=82745e2c60e726b49499b8f309529935dc4eff2b`, `status=`.
- Fetches ran under `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS013-4/home /bin/bash --noprofile --norc -c`. Exact page curl argv: `curl -fsSL --compressed -A "kagi-shokunin-round25/1.0 (documentation verification)" -w "HTTP_STATUS=%{http_code}\n" -o /fast/scratch/kagi-r25/FClockS013-4/vault-lease.html https://developer.hashicorp.com/vault/docs/concepts/lease`; exact feed curl argv: `curl -fsSL --compressed -A "kagi-shokunin-round25/1.0 (documentation verification)" -w "HTTP_STATUS=%{http_code}\n" -o /fast/scratch/kagi-r25/FClockS013-4/vault-releases.atom https://github.com/hashicorp/vault/releases.atom`. Each: HTTP 200, curl exit 0; page SHA/size above, feed SHA-256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`, 303995 bytes. `date -u +OBSERVED_AT=%Y-%m-%dT%H:%M:%SZ` stdout: `OBSERVED_AT=2026-10-21T12:10:29Z`.
- Independent Atom parse argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS013-4/home PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B -c 'import re,sys,xml.etree.ElementTree as E; root=E.parse(sys.argv[1]).getroot(); ns={"a":"http://www.w3.org/2005/Atom"}; es=root.findall("a:entry",ns); pairs=[(e.findtext("a:title",default="",namespaces=ns).strip(),e.findtext("a:updated",default="",namespaces=ns)) for e in es]; stable=[(tuple(map(int,m.groups())),t,u) for t,u in pairs if (m:=re.fullmatch(r"v?([0-9]+)\.([0-9]+)\.([0-9]+)",t))]; print("ENTRY_COUNT="+str(len(es))); [print("ENTRY="+t+" UPDATED="+u) for t,u in pairs]; print("LATEST_STABLE="+max(stable)[1]+" UPDATED="+max(stable)[2])' /fast/scratch/kagi-r25/FClockS013-4/vault-releases.atom` — exit 0; stdout: `ENTRY_COUNT=10`, entries include `v2.2.0`, `v2.2.0-rc1`, `sdk/v0.26.0`; `LATEST_STABLE=v2.2.0 UPDATED=2026-10-15T18:50:14Z`.
- Committed parser argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS013-4/home PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B -c 'import importlib.util; p="/fast/scratch/kagi-r25/FClockS013-4/lane/corpus/release-clock.py"; s=importlib.util.spec_from_file_location("release_clock",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); b=open("/fast/scratch/kagi-r25/FClockS013-4/vault-releases.atom","rb").read(); print("PARSED_LATEST="+m.parse_latest_version(b))'` — exit 0; stdout `PARSED_LATEST=2.2.0`.
- Normalizer argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS013-4/home PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B /fast/scratch/kagi-r25/FClockS013-4/lane/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/FClockS013-4/vault-lease.html` — exit 0; stdout `raw_sha256=492ffb3c2ae8e65daa89aabae99e93b80b3081d46b3e2cdee2a61bffe0efafde bytes=261632 normalized_sha256=0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 normalized_bytes=7354`.
- Quote argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS013-4/home PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B /fast/scratch/kagi-r25/FClockS013-4/lane/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS013-4/vault-lease.html 'All dynamic secrets in Vault are required to have a lease.'` — exit 0; stdout `RENDERED_TEXT_V1_LOCATE: count=1`.
- Page text extraction argv was the `python3 -B -c` HTMLParser program below, executed as `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS013-4/home /bin/bash --noprofile --norc -c` with the saved page as its argv; exit 0.
  ```sh
  python3 -B -c '
  import sys,re
  from html.parser import HTMLParser
  class T(HTMLParser):
   def __init__(self): super().__init__(convert_charrefs=True); self.skip=0; self.parts=[]
   def handle_starttag(self,t,a):
    if t in ("script","style"): self.skip+=1
    if t in ("p","h1","h2","h3","li","div"): self.parts.append(" ")
   def handle_endtag(self,t):
    if t in ("script","style") and self.skip: self.skip-=1
    if t in ("p","h1","h2","h3","li","div"): self.parts.append(" ")
   def handle_data(self,d):
    if not self.skip: self.parts.append(d)
  p=T(); p.feed(open(sys.argv[1],encoding="utf-8",errors="replace").read()); text=re.sub(r"\s+"," "," ".join(p.parts)).strip(); print("VISIBLE_TEXT_CHARS="+str(len(text)))
  for q in ("v2.x (latest)","All dynamic secrets in Vault are required to have a lease.","Key Value Backend", "does not issue leases"):
   i=text.lower().find(q.lower()); print("MATCH="+q+" FOUND="+str(i>=0))
   if i>=0: print("CONTEXT="+text[max(0,i-170):i+len(q)+280])
  ' /fast/scratch/kagi-r25/FClockS013-4/vault-lease.html
  ```
  Stdout excerpts: `v2.x (latest) v1.21.x v1.20.x ...`; `All dynamic secrets in Vault are required to have a lease.`; `The Key Value Backend ... does not issue leases although it will sometimes return a lease duration`.

Limits: the only concrete present-time falsifier is the displayed version-series selector; no historical 2026-10-19 page/feed snapshot was available in this probe. No tool installed or updated.