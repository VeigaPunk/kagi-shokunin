# ClockS027 — per-row release clock for SOURCES S027 (Python `re` `\s`)

Scope: read-only on the lane (HEAD 4587c61a348e4528717404a68912c373f3ef4d03 = BASE, read via `git rev-parse HEAD`). Sandbox: /fast/scratch/kagi-r25/ClockS027-2. Access date 2026-10-21 (fetches ~10:3x UTC). Tools: system curl 8.23.0, /usr/bin/python3 3.14.8. Installs: none. Lane files edited: none.

## Verdict
- Governing identity: option (a). docs.python.org/3/ is a versioned set (page title "re — … — Python 3.15.0 documentation"); python.org publishes an official release API and a "Python Releases" RSS. Clock = `feed`.
- Anchored version 3.15.0 (SOURCES.md:33). Newest stable CPython 3.x = **3.15.0** (released 2026-10-09). Verdict: **not-fired**.
- Newer feed item exists: pre-release **Python 3.16.0a1** (2026-10-13). Excluded by the stable rule; /3/ still serves 3.15.0 (index: "Python 3.15 (stable)", "Python 3.16 (in development)"). A naive "newest item" clock would fire here — counterexample.
- **S027 teaches still holds**: the `\s` sentences are present and the quote locates on both the 3.15.0 page and the 3.16.0a1 page.
- Pin drift is a build timestamp only, not a release change (see Drift).

## Proposed release-clocks.tsv line (tab-separated)
```
S027	feed	https://www.python.org/api/v2/downloads/release/?is_published=true	3.15.0	3.15.0	2026-10-21	not-fired
```
Rule for release-clock.py: among entries with `is_published` true, `pre_release` false and `name` matching `^Python 3\.\d+\.\d+$`, take the max `release_date`; fired iff it differs from `anchored_version`. Any HTTP or parse failure is UNOBSERVED, never not-fired. Offline check on the fetched API: max = Python 3.15.0 (`2026-10-09T13:54:59Z`) → not-fired. The product "Python install manager 26.4" also has `is_latest` true and is excluded by the regex.

## SOURCES candidate (feed row; id and used-by are planner-assigned; used-by must exist per SC_USEDBY_MISSING)
`| S0NN | Python release API (is_published) — https://www.python.org/api/v2/downloads/release/?is_published=true | docs | A | CPython stable and pre-release identities for the Python 3.x docs on-release clock (S027): name, pre_release, is_latest, release_date | JSON object “Python 3.15.0” (is_latest true, pre_release false); accessed 2026-10-21 | Newest stable CPython 3.x is 3.15.0 (2026-10-09); pre-release 3.16.0a1 (2026-10-13) has pre_release true and does not move the stable line. Quote: "release_date":"2026-10-09T13:54:59Z" (object name "Python 3.15.0") | mined | 2026-10-21 | 90d | <existing used-by path> |`
Enum check: kind `docs` is in sources-census.sh:191; tier A = official maintainer feed.

Optional schedule anchor (next re-check date):
`| S0NN+1 | PEP 790 — Python 3.15 Release Schedule — https://peps.python.org/pep-0790/ | spec | A | next expected 3.15 bugfix date for the clock's re-check cadence | §Bugfix releases; page last modified 2026-10-19 17:51:32 UTC; accessed 2026-10-21 | 3.15.0 final 2026-10-09; next expected bugfix 3.15.1 on 2026-12-01. Quote: “3.15.1: Tuesday, 2026-12-01” (§Bugfix releases, Expected list) | mined | 2026-10-21 | on-release | <existing used-by path> |`

## Fetch evidence
Command: `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o FILE -w … URL`; no auth, no cookies. Each object was fetched twice (plain, then `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/ClockS027-2/home`) with identical sha256; all exit 0 except the GitHub probe.

| object | URL | HTTP | sha256 (decoded file) | bytes |
|---|---|---|---|---|
| S027 page | docs.python.org/3/library/re.html | 200 | 453e9e17c37426568d91472fded548ba6eddd1a4ff4f3f3a88aa3a49893ed075 | 251811 decoded (36005 transfer) |
| Releases RSS | python.org/downloads/feed.rss | 200 | 326a2dc4eb6f27937b88078cc317e0cee1df5fb527f5323229f407eb31127844 | 3389 transfer |
| Release API | python.org/api/v2/downloads/release/?is_published=true | 200 | 96ff57a6db0f33943a93cbc77cd95d9e7acc02ea592b60c4da15000918f00573 | 176673 transfer |
| PEP 790 | peps.python.org/pep-0790/ | 200 | 816dff56744d7ff91d8a839de603b019ff65b7bc00045f4a643e1a02a9673f75 | 3349 transfer |
| 3.15.0 release page | python.org/downloads/release/python-3150/ | 200 | ac32fbc541bbe2bddb0b7fd3b339de81fe3cbde815703f4d69bd03b4c32a418a | 11491 transfer |
| /3/ index | docs.python.org/3/ | 200 | 20f4ca336b7e6bafd36f6d778e9fe07da84a547d1d834e69c4986579a99f65c2 | 4041 transfer |
| 3.16 re page | docs.python.org/3.16/library/re.html | 200 | 488cb60ec312440f5a3aba4f48a0d520a4ca29f4c9fab77deeb457324d053127 | 37299 transfer |
| GitHub cpython releases/latest | api.github.com/repos/python/cpython/releases/latest | 403 | 2282f9baf641a8417b97a1785119fd62f08e3560b50fdecfae2019fff3ae259d | body: "API rate limit exceeded"; not used |

## Teaches check (lane rendered-text-v1.py, read-only)
- `digest re.html` → raw 453e9e17…; normalized bcee6611c77820855f3544716f5b036c6f518c79d3a6a193302ea8deab5f1172 (69062 bytes); exit 0.
- `locate re.html "For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() )."` → `count=1`, exit 0; same on the 3.16 page, `count=1`, exit 0.
- `locate` of `Matches [ \t\n\r\f\v] if the ASCII flag is used.` → `count=1`, exit 0 on both pages.
- `--selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0.
- Fresh `\s` entry (normalized, 3.15.0): "For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ). This includes [ \t\n\r\f\v] , and also many other characters, for example the non-breaking spaces mandated by typography rules in many languages. Matches [ \t\n\r\f\v] if the ASCII flag is used." This supports the row's Unicode, no-break-space and ASCII-flag clauses.

## Drift (calibration counterexample)
- Row pins (source-fetches.tsv:70): body d85d77e334d72e051c80fbc9fca78236477d6622ab779181bb29cb1d620ace84, rendered 37cd15c2e3a9be15407c976b8de9a19d539833ddee2c23685d848f00285d4402. Neither matches today's build.
- Footer today: "Last updated on Oct 21, 2026 (07:27 UTC)." Substituting "(05:52 UTC)" (1440 candidate times tested in the sandbox) reproduces BOTH pins exactly; no other time matches. The row was pinned from the 05:52 UTC build; the 07:27 build differs only in that timestamp. [INFERENCE: capture time, from digest equality]
- Consequence: rendered-text-v1 digests of Sphinx pages change on every rebuild with no content change. Do not use them as the on-release identity; use the feed plus quote-locate. Do not fix by silently changing the normalizer (it would invalidate S026, S028, S029 and others); a v2 is a deliberate re-pin.
- Recommend a new dated fetch row for S027 at the 07:27 build (raw 453e9e17…, rendered bcee6611…, 69062 bytes), keeping the 05:52 row as history.

## Other evidence
- RSS: 10 items; top = "Python 3.16.0a1" (pubDate Tue, 13 Oct 2026 19:02:12 +0000, pre-release); newest stable 3.x = "Python 3.15.0" (Fri, 09 Oct 2026 13:54:59 +0000). RSS is windowed, so the API (496 entries) is the binding feed.
- API object "Python 3.15.0": `is_latest` true, `pre_release` false; "Python 3.16.0a1": `pre_release` true, `is_latest` false.
- PEP 790: "3.15.0 final: Friday, 2026-10-09" and "3.15.1: Tuesday, 2026-12-01" (each count 1).
- /3/ index: `<title>3.15.0 Documentation</title>`.

## Gaps (UNRUN)
- corpus/release-clock.py, corpus/release-clocks.tsv, .ufo/waves/round-25/tools/c3-measure.py: absent from the lane at check time; no `RELEASE_CLOCK` counting run.
- corpus/sources-census.sh and verify/cells: not run (no gate on the lane tree).
- GitHub release feed: 403 from this host; not evaluated.
