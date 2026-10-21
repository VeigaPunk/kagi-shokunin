# FFeedS036 — independent source reopen

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (frozen clone; no production repair).
Setup argv: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FFeedS036-4/lane && git -C /fast/scratch/kagi-r25/FFeedS036-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b`; exit 0, stdout empty.
Axes in scope: calibration, operability, freshness. Verdict: **PASS — no actionable S036 falsifier found**.

## Findings by severity

None.

## Evidence

- **PASS — identity/scope:** `corpus/SOURCES.md:42` registers the exact URL `https://www.python.org/downloads/feed.rss`, kind `docs`, tier `A`; scope is only CPython newest-stable `X.Y.Z` identity for S027/S028 clocks, excluding prereleases and install-manager items. Its capture quote is `<title>Python 3.15.0</title>` (2 whitespace-separated/ASCII words), and the row says `mined`, opened 2026-10-21, recheck `90d`.
- **PASS — committed capture record:** `corpus/source-fetches.tsv:79` records S036/mined, matching final URL, HTTP 200, `curl-fsSL-compressed-v1`, `decoded-http-body-volatile-v1`, 3389 bytes, SHA-256 `326a2dc4eb6f27937b88078cc317e0cee1df5fb527f5323229f407eb31127844`, `raw-literal-v1`, and the same quote. Independently recomputed row identity for `S036<TAB>mined<TAB>URL<LF>` equals recorded `a0d9b48021a62e13ee0e853c0d5fb974f3618e3188565612f72fd645af7766d2`.
Row-identity argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FFeedS036-4/home bash -c 'printf "S036\\tmined\\thttps://www.python.org/downloads/feed.rss\\n" | sha256sum'`; exit 0, stdout `a0d9b48021a62e13ee0e853c0d5fb974f3618e3188565612f72fd645af7766d2  -`.
- **PASS — fresh reopen and raw locator:** exact fetch used the capture script's UA and declared profile (the script's implementation is `capture-feeds.sh:10,16,23-31`):

  ```sh
  env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FFeedS036-4/home bash -c 'set -eu; mkdir -p "$HOME" /fast/scratch/kagi-r25/FFeedS036-4; body=/fast/scratch/kagi-r25/FFeedS036-4/S036-live.rss; meta=$(curl -fsSL --compressed -A "kagi-shokunin-round23/1.0 (documentation verification)" -o "$body" -w "%{http_code}\t%{url_effective}" -- "https://www.python.org/downloads/feed.rss"); printf "http_status_final_url=%s\n" "$meta"; printf "sha256="; sha256sum "$body" | cut -d " " -f1; printf "bytes="; wc -c < "$body" | tr -d "[:space:]"; printf "\n"; python3 -B -c '\''import importlib.util, pathlib, sys; p=pathlib.Path("/fast/scratch/kagi-r25/FFeedS036-4/lane/corpus/release-clock.py"); spec=importlib.util.spec_from_file_location("release_clock", p); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); body=pathlib.Path(sys.argv[1]).read_bytes(); quote=b"<title>Python 3.15.0</title>"; print("quote_ascii_words=%d raw_literal_occurrences=%d" % (len(quote.decode("ascii").split()), body.count(quote))); print("parsed_latest_stable_version=%s" % m.parse_latest_version(body))'\'' "$body"; printf "probe_exit=0\n"'
  ```

  Exit 0. Stdout: `http_status_final_url=200<TAB>https://www.python.org/downloads/feed.rss`; `sha256=326a2dc4eb6f27937b88078cc317e0cee1df5fb527f5323229f407eb31127844`; `bytes=3389`; `quote_ascii_words=2 raw_literal_occurrences=1`; `parsed_latest_stable_version=3.15.0`; `probe_exit=0`. This live digest happens to equal the committed digest; either way, the row labels it volatile and its digest is a point attestation, not a semantic-drift pin or a test of historical authenticity.
- **PASS — parser/clock boundary:** `corpus/release-clock.py:535-580` takes the maximum stable `X.Y.Z` among feed entries; the fresh body parses as `3.15.0`. `corpus/release-clocks.tsv:24-25` anchors S027/S028 at 3.15.0 on this feed. `SOURCES.md:42` sets the feed row itself to `90d`; `release-clock.py:681-699` only admits source rows with `recheck == "on-release"`, so S036 is intentionally not a self-clock. This does not remove the S027/S028 clocks.
- **PASS — Gate handshake consistency:** lesson `corpus/lessons/round-25.md:83-94` states all five feeds were opened with the declared profile, HTTP 200 and byte-located quotes; `:107-109` explains feed rows use `90d` and are not self-clocks. S036's registry row, capture row, capture script quote/profile, and independent reopen agree. The lesson's historical attribution to the L1 is a committed statement, not independently proven by this reopen.
- `corpus/sources-census.sh:255-287` checks capture-row shape/profile/status fields and quote length (<=25); it does not itself fetch the URL. The targeted reopen above separately checks the current bytes and raw literal.

## Residual risk and verification gaps

- External feed contents are mutable; a later volatile digest mismatch alone would not falsify the historical capture. This reopen does not establish Python release behavior beyond the feed identity.
- `sources-census.sh`, `release-clock.py --observe`, and full `verify`/`cells` were **UNRUN** (not needed for this source-only attack and full-lane runs are out of scope). No packages/tools were installed.
- LSP status/references/definition/diagnostics were **UNRUN**: `read xd://lsp` returned “No such tool” and listed no LSP device. No grep output is used as semantic proof.
