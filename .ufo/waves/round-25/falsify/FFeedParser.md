# FFeedParser — bounded local fixtures and one selection mutant
Frozen revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (observed HEAD).
Axes: calibration (scope of parser claims), operability (offline detector), freshness (newest stable selection).
Pointers at that revision: `corpus/lessons/round-25.md:59-70`; `corpus/release-clock.py:530-580,829-855,1184-1189`.
Production remained read-only except this report; all execution/imports/mutation used the uniquely named scratch clone.
## Exact commands and environment
```sh
S=/fast/scratch/kagi-r25/KagiR25.FFeedParser-4
L="$S/lane"
E0=(env -i PATH=/usr/bin:/bin HOME="$S/home")
mkdir -p "$S/home" && "${E0[@]}" git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin "$L" && "${E0[@]}" git -C "$L" checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b
mkdir -p "$S/tmp"
"${E0[@]}" git -C "$L" rev-parse HEAD; "${E0[@]}" python3 -B --version
E=(/usr/bin/env -i PATH=/usr/bin:/bin HOME="$S/home" TMPDIR="$S/tmp" PYTHONDONTWRITEBYTECODE=1)
# cwd=$L; each argv below ran unchanged on pristine, mutated, restored bytes; 20s timeout each.
"${E[@]}" /usr/bin/python3 -B corpus/release-clock.py --selftest
"${E[@]}" /usr/bin/python3 -B -                   # stdin below
"${E[@]}" /usr/bin/python3 -B - --numeric-product # identical stdin below
"${E[@]}" /usr/bin/sha256sum corpus/release-clock.py
```
Setup commands: exit 0, stdout empty. `rev-parse`: exit 0, stdout exact frozen hash above. Version: exit 0, stdout `Python 3.14.8`. Independent phase subprocesses were joined before editing; none detached.
## Exact fixture stdin
```python
import importlib.util, json, sys
s = importlib.util.spec_from_file_location("clock", "corpus/release-clock.py")
m = importlib.util.module_from_spec(s); s.loader.exec_module(m)
def e(t, tag=None, stamp="2026-10-20T00:00:00Z"):
    return f'<entry><title>{t}</title><updated>{stamp}</updated>' + (f'<link href="https://github.com/o/r/releases/tag/{tag}"/>' if tag else "") + '</entry>'
def a(*entries): return ('<feed xmlns="http://www.w3.org/2005/Atom">' + ''.join(entries) + '</feed>').encode()
def r(*titles): return ('<rss><channel>' + ''.join('<item><title>' + t + '</title></item>' for t in titles) + '</channel></rss>').encode()
F = [
    ("prerelease-first", a(e("v3.16.0-rc1", "v3.16.0-rc1"), e("v3.15.0", "v3.15.0")), "3.15.0"),
    ("sdk-first", a(e("sdk/v99.0.0", "sdk%2Fv99.0.0"), e("v2.2.0", "v2.2.0")), "2.2.0"),
    ("api-first", a(e("api/v99.0.0", "api%2Fv99.0.0"), e("v2.7.1", "v2.7.1")), "2.7.1"),
    ("backport-updated-last", a(e("v1.9.99", "v1.9.99"), e("v2.2.0", "v2.2.0", "2026-10-10T00:00:00Z")), "2.2.0"),
    ("numeric-product-titles", r("Python install manager 26.4.1", "Python 3.9.99", "Python 3.15.0"), "3.15.0"),
    ("rss-no-namespace", r("Python 3.16.0a1", "Python 3.14.8", "Python 3.15.0"), "3.15.0"),
    ("plain-curl", b"Version: 8.23.0\nDate: 2026-10-14\nNext release: 2026-12-09\n", "8.23.0"),
]
if len(sys.argv) > 1: F = [("numeric-product-name", r("1Password 8.12.0"), "8.12.0")]
bad = 0
for name, body, want in F:
    try: got = m.parse_latest_version(body)
    except Exception as exc: got = f"{type(exc).__name__}: {exc}"
    ok = got == want; bad += not ok
    print(json.dumps(dict(fixture=name, expect=want, got=got, status="PASS" if ok else "FAIL"), sort_keys=True))
sys.exit(bool(bad))
```
## Actual outcomes (P=pristine, M=mutated, R=restored)
| Detector | P | M | R | Mutation verdict |
|---|---|---|---|---|
| Committed `--selftest` | PASS, exit 0 (48 cases) | FAIL, exit 1 | PASS, exit 0 (48 cases) | KILLED |
| Seven scoped local fixtures | PASS 7/7, exit 0 | FAIL 3/7, exit 1 | PASS 7/7, exit 0 | KILLED |
| Broader numeric product-name expectation | FAIL, exit 1 | FAIL, exit 1 | FAIL, exit 1 | INCONCLUSIVE: baseline failure |
All detector stderr was empty; all three SHA commands exited 0.
Exact selftest stdout P/R: `RELEASE_CLOCK_SELFTEST: PASS (48 cases)`.
Exact selftest stdout M: `RELEASE_CLOCK_SELFTEST: FAIL version parser module tag and rc skipped: '2.1.2' != '2.2.0'`.
Fixture stdout `got` fields in source order P/R: `3.15.0, 2.2.0, 2.7.1, 2.2.0, 3.15.0, 3.15.0, 8.23.0`; M: `3.15.0, 2.2.0, 2.7.1, 1.9.99, 3.9.99, 3.14.8, 8.23.0`.
Exact boundary stdout in every phase: `{"expect": "8.12.0", "fixture": "numeric-product-name", "got": "ValueError: feed has no stable X.Y.Z release entry", "status": "FAIL"}`.
Single scratch mutation at line 580: `return max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))` → `return stable[0]`; expected detector: committed selftest exit 1 with its version-parser finding. Restored that exact original line before the R runs.
SHA-256 P: `a3c5c5b92152ed87bb4713e4c66821e0d3f82193f8da19b809b7eeb569f76671`.
SHA-256 M: `4fd58c1647b4cd3fe0a8fbd1064d7d32a3416d1838aeaed31c765ec363e70172`.
SHA-256 R: `a3c5c5b92152ed87bb4713e4c66821e0d3f82193f8da19b809b7eeb569f76671` — exact file-byte restoration PASS.
Concrete selection falsifier: a backport `v1.9.99` updated October 20 precedes `v2.2.0` updated October 10; mutant reports `1.9.99`, while pristine/restored correctly report `2.2.0`.
Calibration limit: arbitrary digit-bearing product prefixes are NOT supported (`[A-Za-z]+` at line 530 rejects `1Password 8.12.0`). This falsifies a broader arbitrary-product-title claim, not the documented one-word alphabetic grammar or the currently selected Python title; no current-feed regression established.
UNRUN: network/public-feed freshness, receipt/ledger integration, C1 counts, C2 layout, full verify/cells. No account/vault/handler/CDP/op operations, other runtime, production repair, package/config changes, or additional mutation.
Tools: existing `/usr/bin/python3` 3.14.8; no installs/updates. This is probe evidence, not admission or integration judgment.
