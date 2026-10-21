# ClockS029 — S029 freshness re-verification (round 26, C1)

Seat KagiR26.ClockS029 · observed 2026-10-21T13:36:44Z · BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`, read-only; worktree has only untracked `.ufo/waves/round-26/` and `plans/round-26.md`) · production files read-only, none edited · installs: none (curl 8.23.0, Python 3.14.8, sha256sum used as found) · supporting captures: `.ufo/waves/round-26/build/ClockS029-evidence/{manpage,info}.{body,headers}`.

Lane-authored advice, not non-author closure.

## 1. Bounded result
- **Teaching: STILL HOLDS, unchanged.** The S029 page body today is byte-identical to the round-24 capture, and the declared quote locates once under the `--compressed` anchor.
- **Clock: not-fired, unchanged.** curl.se/info still says `Version: 8.23.0`, and its body is byte-identical to the round-25 receipt observation.
- **Python 3.15.1 drift: not applicable to S029.** S029 is a curl source; its teaching and clock do not depend on the Python docs. The only Python dependency is the local interpreter that runs `rendered-text-v1.py` (see §5, limit iii).
- Scope: one quote, one anchor (`#--compressed`) and one feed field (`Version:`). This is not whole-page coverage of the curl man page.

## 2. Source teaching — S029 https://curl.se/docs/manpage.html (accessed 2026-10-21)
- Request profile `curl-fsSL-compressed-v1` (UA `kagi-shokunin-round23/1.0 (documentation verification)`). HTTP/2 200, no redirect (final URL identical), `content-encoding: br` with 80924 B on the wire, `last-modified: Mon, 19 Oct 2026 06:25:03 GMT`, `etag: "719f7-65e2b930bafca"`, `age: 86`, `x-cache: HIT, HIT`.
- Decoded body: 465399 B, sha256 `9d2b36d00af7240f77480e911ce28346113419dd3eb5ebca1d8cc50284cfe5ca`. This equals `corpus/source-fetches.tsv:72` columns 10 and 11.
- `rendered-text-v1.py digest`: normalized sha256 `fb3a488935980d005f962ef24e159e64700aed6a74bd33116357ad607ab18c27`, 264660 B. This equals column 15.
- Row identity: `printf 'S029\tmined\thttps://curl.se/docs/manpage.html\n' | sha256sum` gives `be4509c1…6948a9`, which equals column 3.
- Anchor: `<a name="--compressed">` at body line 705. The quote is on line 706.
- Located quote (18 words, `locate` count=1): “(HTTP) Request a compressed response using one of the algorithms curl supports, and automatically decompress the content.”
- Verdict: the teaching (digests cover curl's decoded body, not transfer-encoded bytes) still holds. The wire is brotli-encoded, while the digested 465399 B is the decoded output.

## 3. Declared clock — `corpus/release-clocks.tsv:26` (feed, S037, https://curl.se/info, accessed 2026-10-21)
- HTTP/2 200, 352 B, identity encoding, `last-modified: Wed, 21 Oct 2026 10:10:59 GMT`, `etag: "160-65e56f6b7b594"`.
- sha256 `cfa106be99126075e28cd6dbc675aa1cebf7f81b02e0a39e31efd946e765e1e8`. This equals `source-fetches.tsv:80` column 10, and also the round-25 receipt (`.ufo/waves/round-25/observe-1.json`, file sha256 `b74c8ee3…349f92` = `DEFAULT_RECEIPT_SHA256`): S029 entry `observed_at 2026-10-21T11:31:53Z`, `parsed_version 8.23.0`, `verdict not-fired`.
- Feed lines 1–2: `Version: 8.23.0`, `Date: 2026-10-14`. Also `Next release: 2026-12-09`. The byte search for `Version: 8.23.0` counts 1 (raw-literal-v1).
- S037 row identity: `printf 'S037\tmined\thttps://curl.se/info\n' | sha256sum` gives `04215fe0…daece7`, which equals column 3.
- Verdict: anchored 8.23.0 equals observed 8.23.0, so **not-fired**. The round-25 receipt is reproduced exactly and does not need rewriting.

## 4. Actionable counterexamples (open, not regressions)
1. **Development-label anchor is still standing.** The page still says “This man page describes curl 8.23.1.” (body line 572). The `SOURCES.md:35` location cell says "curl 8.23.1 man page", while the clock anchors on released 8.23.0 (`release-clocks.tsv:26` note). `corpus/README.md:191` already lists a superseding row for this label as a next step. At BASE it is still unaddressed.
2. **The feed clock cannot detect docs-only drift.** The man page is rebuilt between releases: Last-Modified 2026-10-19 is after the 8.23.0 release on 2026-10-14. [INFERENCE: it is built from master, per round-25 ClockS029 §1.] Its content can change while curl.se/info stays at 8.23.0. Today that drift is zero, because the raw digest is identical. That is a point observation, not monitoring.
3. **A qualifier is still omitted (calibration, not breaking).** Line 708 says “This is a request, not an order; the server may or may not deliver data compressed.” The S029 teaching does not carry it.

## 5. Limits and unrun checks
- (i) Fetched only the two assigned URLs. I did not re-verify the `curlver.h 8.23.1-DEV` claim in the clock note (it is GitHub-hosted, outside the allowed URLs); it is carried from round-25 evidence.
- (ii) I did not run `release-clock.py --observe`, the census, the gates, or any tests. The verdict comes from comparing the observed `Version:` field to the anchored version.
- (iii) The normalized-digest reproduction ran under local Python 3.14.8. It does not attest behavior under Python 3.15.x `re`/`html.unescape`.
- (iv) Same-day re-observation about 2 h after the receipt. Next feed-declared release is 2026-12-09 (a schedule, not a guarantee).

## 6. Command log (all exit 0)
- `git rev-parse HEAD; git status --short` → BASE above.
- `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D <h> -o <b> -w '… http=%{http_code} final=%{url_effective} size=%{size_download}'` for both URLs → `manpage http=200 … size=80924`, `info http=200 … size=352`.
- `sha256sum`, `wc -c` on both bodies → values above.
- `python3 corpus/rendered-text-v1.py digest …/manpage.body` → `RENDERED_TEXT_V1: raw_sha256=9d2b36d0… bytes=465399 normalized_sha256=fb3a4889… normalized_bytes=264660`.
- `python3 corpus/rendered-text-v1.py locate …/manpage.body '<quote>'` → `RENDERED_TEXT_V1_LOCATE: count=1`.
- `grep -c -F 'Version: 8.23.0' …/info.body` → 1.
- `sha256sum .ufo/waves/round-25/observe-1.json` → `b74c8ee3…`; read its S029 entry with `python3 -c json`.
