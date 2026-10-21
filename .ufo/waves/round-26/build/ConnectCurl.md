# ConnectCurl — curl decoded-body maintenance vs kake web operation (round 26, C1)

Seat: `KagiR26.ConnectCurl` (connector, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814`
(`git log -1`: 2026-10-21 "round-25: immutable measurements, separability and honest final outcomes").
`git status --short`: only `?? .ufo/waves/round-26/` and `?? plans/round-26.md` (no production drift).

## Bounded result

**There is no overlap between kagi's curl decoded-body maintenance and kake's web operation. C1 stays in kagi's lane.**
Kagi's curl material falls into two groups:

- The capture representation for kagi's own `corpus/SOURCES.md` rows: request profile `curl-fsSL-compressed-v1` and hash domain `decoded-http-body-v1` / `decoded-http-body-volatile-v1`.
- The S029 → S037 release clock.

Every one of these targets third-party vendor documentation or release files. None targets a kake-owned property. Kake owns publisher-side work on its own properties, and no sibling `PROVINCE.md` claims curl, decoded bodies, or content-encoding.

## Evidence (exact anchors)

Kake scope, from `kake-shokunin/PROVINCE.md` (sha256 `f71df98e…19917`):
- L3: "web properties & publishing — scopes ds4cc.com, kimi.page/pro mirrors, Pages deploys".
- L12–18: Core is audits, drift checks, Pages semantics and its own gates (`scripts/freshness-sweep.mjs`, `scripts/probe-delta.mjs`).
- L62–64 (round-23 live use): `scripts/live_snapshot.py` consumes "saved GET-response HTML from owned public properties". This is the closest overlap point. Its scope is owned properties only.
- L30–37 Adjacent: kake names kagi only for "secrets and credential custody" and the contested musketeer profile lease. It makes no fetch, decoded-body or source-capture claim against kagi.

Kagi scope, from `kagi-shokunin/PROVINCE.md` (sha256 `22ed8900…cdaa`):
- L43: the CDP 9222 / musketeer profile is "contested with kake".
- L58: "the CDP lease/profile ownership question is reported to the integrator, never adjudicated here".
- L66: "kake holds the musketeer profile lease (contested, above)"; "chousa owns the research method (`SOURCES.md` restates neither method nor admission bar)".
- L54–55: `corpus/release-clock.py` / `corpus/release-clocks.tsv` and `corpus/sources-census.sh` (SC_FETCH) are kagi's own gates over its own registry.

Kagi curl surface:
- `corpus/lessons/round-23.md:45-46`: "`decoded-http-body-v1` is the HTTP entity body after curl removes `Content-Encoding`".
- `corpus/SOURCES.md:35`: S029 is the curl man page and grounds that representation.
- `corpus/SOURCES.md:43`: S037 is `https://curl.se/info`, the release clock for S029.
- `corpus/release-clocks.tsv:26`: `S029 feed S037 https://curl.se/info 8.23.0 8.23.0 2026-10-21 not-fired`.
- `corpus/sources-census.sh:266,268`: SC_FETCH requires profile `curl-fsSL-compressed-v1` and representation `decoded-http-body-v1|decoded-http-body-volatile-v1`.

Host partition of `corpus/source-fetches.tsv`:
- Fetch-host counts: 1password.com 3, curl.se 2, developer.hashicorp.com 5, docs.python.org 2, getsops.io 3, github.com 4, html.spec.whatwg.org 1, infra.spec.whatwg.org 1, openbao.org 6, raw.githubusercontent.com 1, www.1password.dev 9, www.python.org 1.
- Profiles: 38 rows, all `curl-fsSL-compressed-v1`.
- Domains: 4 `decoded-http-body-v1` and 34 `decoded-http-body-volatile-v1`.
- `rg -i -c 'ds4cc|kimi\.page|kimi\.pro|veigapunk|github\.io'` over `corpus/SOURCES.md`, `source-fetches.tsv`, `release-clocks.tsv` and `self-counts.tsv` returned no matches (exit 1). No kagi capture targets a kake-owned host.

Sibling sweep:
- I scanned the 20 non-kagi `*/PROVINCE.md` files with this pattern: `curl|decod|compress|content-encoding|http body|response body|GET-response|GET-only|digest|sha-?256|fetch|capture|source hierarch|research method|release feed|release clock|on-release|python`.
- **No sibling mentions curl.** `rg -l -i curl */PROVINCE.md` listed no files.
- Hits on "decod…" are about audio, pixel, APK or crash decoding (audio, game-dev-3d, kaidoku). None is HTTP-body decoding.
- `chousa-shokunin/PROVINCE.md:5-8` owns "source hierarchy … claim-vs-source verification … external-target approval table". This is the only method-adjacent ownership, and kagi L66 already defers to it.
- `tabi-shokunin/PROVINCE.md:1-19` owns browser/CDP interaction and refuses "web *publishing* (→ kake), secrets (→ kagi)". It makes no curl or body-hash claim.

Freshness evidence, from the peer artifact `.ufo/waves/round-26/build/ClockS029-evidence/` (read-only, fetched 2026-10-21 13:36 UTC by another seat; I did not refetch):
- `info.body` is "Version: 8.23.0 / Date: 2026-10-14 / Next release: 2026-12-09". Its sha256 `cfa106be…e1e8` and 352 B equal the committed S037 row. The S029 clock is **still not fired**.
- `manpage.headers` shows `content-encoding: br` and `content-length: 80924`. The decoded `manpage.body` is 465399 B with sha256 `9d2b36d0…e5ca`, equal to the committed S029 row's digest and byte count.
- So the decoded-body convention holds as an observation: the stored digest is over the decompressed body, not over the 80,924 transferred bytes. The quote "automatically decompress the content" occurs once (`grep -c` → 1). The page still labels itself "curl 8.23.1." (the development label, as in round 25).

## Affected axes

- **Freshness (C1): helped, not harmed.** C1's Python 3.15.1 response is a kagi-registry action (S027/S028 → S036 feed). The curl rows ride the same receipt with no change: the S029 clock is still `not-fired` and both curl digests are byte-stable, so no superseding curl row is warranted.
- **Calibration: no harm**, provided the receipt records "not fired / byte-equal" and not "re-verified current".

## Proposed move (one, bounded)

In the new round-26 receipt, give the curl rows (S029/S037) a provenance column with the value **"third-party documentation; no kake-owned host"**. Base it on the empty host-partition grep above, and record the observed result: `not-fired`, digests equal to `source-fetches.tsv`. Do not add a curl supersession row. Do not add any kake, tabi or chousa ownership language: kagi L58/L66 already route the profile lease and research method to the integrator and chousa.

The move answers sibling-overlap questions inside the receipt itself, at no cost to C1. It does not touch historical receipts, the binding TSV or R25-04.

## Risks and counterexamples (actionable)

1. **Method creep into chousa.** If the C1 integration changes the *meaning* of `decoded-http-body-v1`, the admission bar, or the source hierarchy, it crosses `chousa-shokunin/PROVINCE.md:5-8`. Adding, removing or renaming a domain at `sources-census.sh:268` would count. Recording new observations under the existing names stays in-lane.
2. **Host creep into kake.** A future kagi row capturing ds4cc.com, *.kimi.page/pro or veigapunk.github.io would overlap `live_snapshot.py` (kake L62). The falsifier is the same host grep returning a match. At BASE it returns none.
3. **Overclaiming the curl clock.** `not-fired` is one observation at 13:36 UTC on 2026-10-21. It does not show continuous monitoring. The next scheduled curl release is 2026-12-09.
4. **Profile-lease drift.** The CDP 9222 / musketeer lease is still contested (kagi L43/L58, kake L35–36). C1 must not touch it, and this report does not arbitrate it.

## Verification for L1 (not run by this seat)

- Re-run `rg -n -i -c 'ds4cc|kimi\.page|kimi\.pro|veigapunk|github\.io' corpus/SOURCES.md corpus/source-fetches.tsv corpus/release-clocks.tsv`. Expect no matches after integration.
- `bash corpus/sources-census.sh` and `python3 corpus/release-clock.py` after integration. These are **not run** here. I am not reporting them as passing.

## Inspected scope and limits

Inspected:
- kagi: `PROVINCE.md`, `plans/round-26.md`, `SKILL.md`/`corpus/README.md` curl lines, `corpus/lessons/round-23.md:40-50`, the `round-24`/`round-25` curl lines, `corpus/SOURCES.md` (S029/S037), `corpus/source-fetches.tsv`, `corpus/release-clocks.tsv`, and the `sources-census.sh`/`release-clock.py` grep hits.
- The 20 sibling `PROVINCE.md` files, by pattern scan plus a full read of kake and of the chousa/tabi headers.
- The peer's `ClockS029-evidence`.

Not inspected:
- Sibling corpora and scripts. I did not read kake's `live_snapshot.py` source, so whether it uses curl or decodes bodies is unverified.

Other notes:
- No network fetch, host-private read, install or sibling write.
- Tooling note: Glob `*/PROVINCE.md` under `/home/vgpnk/Projects/shokunin` returned 0 files although `ls` lists 21. I fell back to `ls`/`rg`.
- Exact sibling hashes come from the `sha256sum` run recorded in this seat's transcript. Kake: `f71df98e6ae9e86f96ec0fa1343afd013daf16656bca70fd4c4790fe73119917`. Chousa: `cf7826a43aaab7c00708ab54bb46577217e7a67ab44a43a33e17ee2a58c1bbec`. Tabi: `16c27b12a60dbbcc43903d40334c314f6587bd8703d1e890e076398eac1a946a`.
