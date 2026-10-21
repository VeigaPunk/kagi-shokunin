# FClockS009 — C3 SOPS age-doc clock

**Verdict: PASS** for the frozen S009 observation as of 2026-10-21. I found no current release-clock mismatch or quote loss. **Qualification:** the baseline is explicitly derived, not an upstream page version pin; see anchor ambiguity below.

## Frozen inputs and observations

- Frozen checkout: `82745e2c60e726b49499b8f309529935dc4eff2b` (isolated clone; `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/clean/home git -C /fast/scratch/kagi-r25/FClockS009/clean/lane rev-parse HEAD` exit 0; stdout exactly this hash). No installs; no production edits.
- `corpus/release-clocks.tsv:6`: S009 uses S033 `https://github.com/getsops/sops/releases.atom`; expected/observed stable version `3.13.3`, checked `2026-10-21`, status `not-fired`. Its note says the release baseline is derived from newest stable SOPS tag when S009 was opened 2026-10-19.
- `corpus/SOURCES.md:15` anchors S009 to the page footer dated 2026-05-15, docs commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a`; it names no SOPS release. `corpus/SOURCES.md:39` describes S033 as a stable-tag release identity feed.

## Exact fetch and parser evidence

Commands used the declared public-only request profile; no credentials/cookies/API calls:

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/home /usr/bin/curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FClockS009/capture/s009-page.html -w 'http_code=%{http_code} effective_url=%{url_effective} downloaded=%{size_download}\n' https://getsops.io/docs/usage/identities/age/
```
Exit 0; stdout: `http_code=200 effective_url=https://getsops.io/docs/usage/identities/age/ downloaded=8475`; decoded file `wc -c` = 29301; `sha256sum` = `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76` (matches `source-fetches.tsv:62`).

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/home /usr/bin/curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FClockS009/capture/s033-feed.atom -w 'http_code=%{http_code} effective_url=%{url_effective} downloaded=%{size_download}\n' https://github.com/getsops/sops/releases.atom
```
Exit 0; stdout: `http_code=200 effective_url=https://github.com/getsops/sops/releases.atom downloaded=253037`; decoded file `wc -c` = 253037; `sha256sum` = `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6` (matches volatile S033 capture in `source-fetches.tsv:76`).

Independent extraction parsed every Atom `<entry>`, accepted only titles matching exact `vX.Y.Z`, and selected the maximum numeric tuple (thus excluding suffixes/module names if present). Exact argv:

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/home python3 -B -c 'import re,sys,xml.etree.ElementTree as ET; ns={"a":"http://www.w3.org/2005/Atom"}; es=ET.parse(sys.argv[1]).getroot().findall("a:entry",ns); stable=[(tuple(map(int,m.groups())),"v"+".".join(m.groups()),e.findtext("a:updated",namespaces=ns)) for e in es if (m:=re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)",(e.findtext("a:title",namespaces=ns) or "").strip()))]; top=max(stable); print("entries=%d exact-stable=%d excluded=%d"%(len(es),len(stable),len(es)-len(stable))); print("latest=%s updated=%s"%(top[1],top[2]))' /fast/scratch/kagi-r25/FClockS009/capture/s033-feed.atom
```
Exit 0; stdout: `entries=10 exact-stable=10 excluded=0` / `latest=v3.13.3 updated=2026-07-23T05:29:11Z`. The feed's first entry independently shows `<title>v3.13.3</title>` and the same timestamp. Current stable version and checked date match the frozen TSV; hence `not-fired` is correct for the row-opened `v3.13.3` baseline. Feed-body digest equality is a point observation, not by itself semantic-drift evidence.

Chronology parser (same exact-title filter, sorting every feed entry by numeric version):

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/home python3 -B -c 'import re,sys,xml.etree.ElementTree as ET; ns={"a":"http://www.w3.org/2005/Atom"}; es=ET.parse(sys.argv[1]).getroot().findall("a:entry",ns); xs=sorted([(tuple(map(int,m.groups())),"v"+".".join(m.groups()),e.findtext("a:updated",namespaces=ns)) for e in es if (m:=re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)",(e.findtext("a:title",namespaces=ns) or "").strip()))]); print("\n".join("%s %s"%(v[1],v[2]) for v in xs))' /fast/scratch/kagi-r25/FClockS009/capture/s033-feed.atom
```
Exit 0; relevant stdout excerpts: `v3.13.0 2026-05-08T18:11:59Z`, `v3.13.1 2026-05-16T14:33:57Z`, `v3.13.3 2026-07-23T05:29:11Z`.

The docs footer instead says 2026-05-15; feed chronology places v3.13.0 on 2026-05-08 and v3.13.1 on 2026-05-16, so a docs-date-derived baseline would be v3.13.0 and would now read fired. The round-25 note records that alternative (`corpus/lessons/round-25.md:75-79`); the page itself does not bind its text to v3.13.3. Treat `3.13.3` as the documented derived clock baseline, **not proof that the page was authored/tested against that product release**.

## Quote/profile and teaching

Using the candidate's `corpus/rendered-text-v1.py` from the isolated clone:

- `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/clean/home PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/FClockS009/capture/s009-page.html` — exit 0; stdout `RENDERED_TEXT_V1: raw_sha256=a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76 bytes=29301 normalized_sha256=189d5ba9145e71f4a41dae10a42b9176fa660c58f3df5cb2774a145d11728d95 normalized_bytes=3570`. The normalized digest exactly matches `source-fetches.tsv:62`.
- `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/clean/home PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS009/capture/s009-page.html 'It is also possible to use updatekeys , when adding or removing age recipients.'` (cwd `/fast/scratch/kagi-r25/FClockS009/clean/lane`) — exit 0; stdout `RENDERED_TEXT_V1_LOCATE: count=1`.
- Negative control, with the `SOURCES.md:15` Markdown-formatted quote: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockS009/clean/home PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/FClockS009/capture/s009-page.html 'It is also possible to use \`updatekeys\`, when adding or removing age recipients.'` (same cwd) — exit 1; stdout `RENDERED_TEXT_V1_LOCATE: count=0` (expected negative result).

Thus the capture's `decoded-http-body-v1` + `rendered-text-v1` quote/profile is reproducible; using the registry's backticked teaching-cell text as the quote would not locate. The reopened page renders the cited `updatekeys` sentence in §Encrypting using age and also documents recipient setup and private identity lookup (HTML capture, body content; registry scope at `SOURCES.md:15`). **The one-sentence quote alone supports only the recipient-add/remove via `updatekeys` clause**, not all identity-location details; those details are present elsewhere on the same page. Neither a surviving quote nor page text verifies SOPS runtime behavior.

## Anchor assessment, falsifier, limits


Concrete falsifier for this observation: an exact stable feed title numerically newer than `v3.13.3`, loss of the captured rendered quote, or changed page-footer anchor would invalidate the frozen `not-fired` / content observation. None was observed: current page/feed fetches both returned HTTP 200, hashes match the captures, and the quote locates under the declared profile. `corpus/knowledge/sops-age-key-rotation.md:5-7,20-37` carries the on-release recheck and S009 teaching scope.

- **PASS:** frozen revision, live feed result and `not-fired` comparison; page capture, quote location and normalized digest.
- **UNRUN:** SOPS binaries or product-behavior tests (out of scope; no product execution). This is a public-source observation only, not evidence of runtime semantics.