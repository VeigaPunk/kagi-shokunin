# FFeedS037 — PASS

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (`git rev-parse HEAD`, exit 0).
Axes: freshness PASS for S037/S029; calibration and operability not sampled by this source-only assignment.

## Findings (severity order)

None. No actionable S037 falsifier found.

## Evidence

All experiments used the isolated clone `/fast/scratch/kagi-r25/FFeedS037/lane` at the frozen revision and `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FFeedS037/home`; no installs.

- PASS — `corpus/SOURCES.md:43`: S037 is `docs`, tier A, `mined`; its scope is curl's latest official release identity for S029, and `recheck=90d`. The registered quote is `Version: 8.23.0`.
- PASS — independent public re-open used the declared `curl-fsSL-compressed-v1` profile/UA from `.ufo/waves/round-25/tools/capture-feeds.sh:17,23-31`: `curl -fsSL --compressed -A "kagi-shokunin-round23/1.0 (documentation verification)" -o /fast/scratch/kagi-r25/FFeedS037/capture/S037.body -w "http_status=%{http_code}\nfinal_url=%{url_effective}\n" -- https://curl.se/info` — exit 0; stdout `http_status=200`, `final_url=https://curl.se/info`.
- PASS — `sha256sum /fast/scratch/kagi-r25/FFeedS037/capture/S037.body` — exit 0; stdout `cfa106be99126075e28cd6dbc675aa1cebf7f81b02e0a39e31efd946e765e1e8  /fast/scratch/kagi-r25/FFeedS037/capture/S037.body`; `wc -c </fast/scratch/kagi-r25/FFeedS037/capture/S037.body` — exit 0; stdout `352`. These equal the committed S037 values at `corpus/source-fetches.tsv:80` (HTTP 200, decoded-http-body-volatile-v1, same URL, same digest and byte count, quote `Version: 8.23.0`, `raw-literal-v1`). Fetched body line 1 is `Version: 8.23.0`.
- PASS — exact parser argv: `python3 -B -c 'import importlib.util, pathlib, sys; p="corpus/release-clock.py"; s=importlib.util.spec_from_file_location("release_clock", p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); b=pathlib.Path(sys.argv[1]).read_bytes(); q="Version: 8.23.0"; print("parsed_version="+m.parse_latest_version(b)); print("quote_words="+str(len(q.split()))); print("quote_raw_present="+str(q in b.decode("utf-8")))' /fast/scratch/kagi-r25/FFeedS037/capture/S037.body` — exit 0; stdout `parsed_version=8.23.0`, `quote_words=2`, `quote_raw_present=True`. This uses `corpus/release-clock.py:530-550`; quote is within the <=25-word bound and locates literally in decoded bytes.
- PASS — lesson handshake agrees: `corpus/lessons/round-25.md:81-94` records S037, exact URL, admitted tier A maintainer release file, mined status, two-word quote and line-1 location. Lines 107-110 state new feed rows use 90d so the feed itself is not an on-release row. Supporting references: `corpus/SOURCES.md:43`, `corpus/source-fetches.tsv:80`, `corpus/release-clocks.tsv:26`.
- PASS — clock behavior: candidate `release-clock.py:365-368,409-419,676-692` selects only registry rows with `recheck == on-release`; S037's 90d recheck is excluded, while S029 binds to S037. `python3 -B corpus/release-clock.py` — exit 0; stdout `RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)`. Committed `observe-1.json` contains S029 (`parsed_version=8.23.0`, `verdict=not-fired`) and no S037 observation.
- PASS — `python3 -B corpus/release-clock.py --selftest` — exit 0; stdout `RELEASE_CLOCK_SELFTEST: PASS (48 cases)`. `bash corpus/sources-census.sh` — exit 0; stdout `SOURCES_CENSUS: CLEAN (rows=37 A=35 B=0 C=2 queued=1 mined=34 rejected=2 entries_sourced=4 legacy=21 captures=37 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.

## Residual risk and verification gaps

The capture is explicitly `decoded-http-body-volatile-v1`; this same-day independent fetch matches the committed digest, but the repository does not retain the original response body, so this does not independently prove historical capture execution or future representation stability. No digest mismatch was observed and none is characterized as fabrication. `UNRUN`: full `verify`/`cells`, network `release-clock.py --observe`, and the five-feed `capture-feeds.sh` batch; none is needed to establish this scoped S037 result.

Report: .ufo/waves/round-25/falsify/FFeedS037.md
