# S016 live recapture

Registry row `S016` is at `corpus/SOURCES.md:22`; its historical in-row `Fetch sha256` pin is `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`.

Fetch used the declared profile and saved the decoded body to `/fast/scratch/kagi-r24/seats/RecapS016-2/S016.html`:

```sh
mkdir -p /fast/scratch/kagi-r24/seats/RecapS016-2 && curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' 'https://openbao.org/docs/concepts/tokens/' -o /fast/scratch/kagi-r24/seats/RecapS016-2/S016.html -w '%{url_effective} %{http_code}'
```

Exit 0; curl output: `https://openbao.org/docs/concepts/tokens/ 200` (HTTP 200). The decoded body is 47,384 bytes.

Digest command (exit 0), using `corpus/rendered-text-v1.py:90-97`:

```sh
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS016-2/S016.html
```

Output: `RENDERED_TEXT_V1: raw_sha256=5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c bytes=47384 normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608`. Pin comparison: raw match **no**; normalized match **no**.

Locate command for the row's quote (exit 0; implementation `corpus/rendered-text-v1.py:101-112`):

```sh
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS016-2/S016.html 'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'
```

Output: `RENDERED_TEXT_V1_LOCATE: count=1`.

To find the nearest heading in normalized text, I used the renderer from the isolated scratch clone (exit 0):

```sh
python3 -c 'import runpy; r=runpy.run_path("/fast/scratch/kagi-r24/seats/RecapS016-2/repo/corpus/rendered-text-v1.py"); t=r["normalize_bytes"](open("/fast/scratch/kagi-r24/seats/RecapS016-2/S016.html","rb").read()).decode(); q="When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well."; i=t.index(q); print("quote_index=%d count=%d"%(i,t.count(q))); print("CONTEXT_BEFORE:",t[max(0,i-800):i]); print("CONTEXT_AFTER:",t[i+len(q):i+len(q)+400]); print("HEADING_OCCURRENCES:",[(h,t.rfind(h,0,i)) for h in ["Token hierarchies and orphan tokens","Token Time-To-Live, periodic tokens, and explicit max TTLs"]])'
```

It reported quote offset 4921, count 1; the nearest preceding heading is `Token hierarchies and orphan tokens` (heading offset 4713; source heading `/fast/scratch/kagi-r24/seats/RecapS016-2/S016.html:77`).

**Scope/teaches: yes.** The fetched page is marked `Version: Version 2.7.x` (`S016.html:4`). Exact live evidence: “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well” (`S016.html:80-81`). It also says, “Root tokens are tokens that have the root policy attached to them” (`S016.html:53-54`), “Every non-root token has a time-to-live (TTL) associated with it, which is a current period of validity since either the token's creation time or last renewal time, whichever is more recent” (`S016.html:125-127`), and “If the token is renewable, OpenBao can be asked to extend the token validity period using bao token renew or the appropriate renewal endpoint” (`S016.html:131-132`). The legacy digest pin is stale despite the recorded scope/teaches remaining supported.