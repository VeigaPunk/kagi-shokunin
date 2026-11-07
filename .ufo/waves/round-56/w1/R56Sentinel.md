# R56Sentinel — round 56 w1 safety/scope scan

Seat: R56Sentinel. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Final anchor: **epoch-E predeclaration `dd31b7867723f89fc8f83e88cc7d98e17de26cf2`** (landed 08:08). Superseded: epoch-D `d36231871c864c930d3e7e33f9c5345b30ab4f98`, C `711e6393`, B `5d9a157`, A `42070de`. BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Scan window 2026-11-07T07:30–08:10-03:00. Answering model: harness-reported `amr/deepseek-v4.1-flash`; no self-introspection beyond that.
Tools installed/updated: none (no pacman transaction; `/home/vgpnk/.omp/agent/RULES.md` read first).
No production file edited, no git/jj mutation, no network fetch, no secret printed (token middles redacted).

## Instrument snapshots (sha256; A=`42070de`, B=`5d9a157`, C=`711e6393`, D=`d3623187`, E=`dd31b786`)

| path | A | B | C | D | E (final) |
|---|---|---|---|---|---|
| `corpus/recheck-replay.py` | `b7782f35…` 14716 | `2e9dfde3…` 15684 | `e9b7e4b7…` 21038 | `5165da2a…` 21543 | blob `79fb022b…`, **`5165da2a…e77b14f`**, 21543 B (unchanged) |
| `plans/round-56-c1.sh` | `096251c9…` 12933 | `6b132ea1…` 15746 | `7992ee6a…` 17174 | `82acbb20…` 17195 | blob `cc27f350…`, **`d468533fbf593c4b2a3a97dc513b9feb2cff765892c126c02d7c6ef40273a954`**, 17499 B, `GATE_SHA256_PIN=5165da2a…`, `PASS (20 cases)`, tool guards |
| `plans/round-56-controls.sh` | `633326a5…` 6341 | `63cf8061…` 8795 | `b675baa5…` 11255 | `9445a1ec…` 11856 | blob `7bd6e725…`, **`01060f254b2ecfdb23f341a5cf0937aec32243230560809403ed67ea38b196e7`**, 12241 B |
| `plans/round-56.md` | `d1bf8d26…` 5652 | `033f2104…` 6204 | `8beb24e9…` 7124 | `4d837eb2…` 7558 | blob `a4303acf…`, **`212e2dd7ae71e3f056111e1a2c59d33151a3c51fee9f932bf2209ad2cb3d805d`**, 7558 B |
| `corpus/recheck-captures.tsv` | `df46be5c…` 2391 | unchanged | unchanged | unchanged | **unchanged** |
| `corpus/rendered-text-v1.py` | — | — | `14f6ca6a…` | `14f6ca6a…` | **`14f6ca6a…` = `NORMALIZER_SHA256_PIN` = BASE** |
| `capture/*` | bodies+receipt+rejection | unchanged | unchanged | unchanged | **unchanged** |

Worktree at 08:09: the six frozen paths are clean vs `dd31b786`; landing edits remain dirty (`corpus/SOURCES.md`, `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`, `corpus/source-fetches.tsv`, untracked `corpus/lessons/round-56.md`) plus other seats' `.ufo` receipts. Candidate content, not instruments.

## Verdict matrix

| # | Check class | A | C | E |
|---|---|---|---|---|
| A | Credential-shaped material in captures | CLEAN + F1/F2 LOW | unchanged | unchanged |
| B | Hardcoded `/tmp`; `TMPDIR`/`HYAKU_SCRATCH` honoured | CLEAN | CLEAN | CLEAN |
| C | Path escapes (gate, counter, manifest `body_path`) | CLEAN; F4 gap | CLEAN | CLEAN |
| D | Shell execution of fetched content | CLEAN | CLEAN | CLEAN |
| E | Network — gate offline | CLEAN | CLEAN | CLEAN (strace) |
| F | Host file reads outside the tree | CLEAN except F4 | CLEAN | CLEAN |
| G | QM72 / receipts | CLEAN | **N5 gap** | CLEAN (`(?im)`, case variants refused) |
| H | Secrets in plan / manifest / controls receipt | CLEAN | CLEAN | CLEAN |
| I | Frozen instruments / re-freeze integrity | A→B edits | B→C edits | **landed as E; 22/22 controls; INSTRUMENT lines match** |

## W1 — re-freeze chain (L1-confirmed), landed as `dd31b786`

- A→B (`5d9a157`): gate pin, gate rc-0 + exact `CLEAN(10/10/0…)`, `-> N` right-boundary, symlink confinement, manifest arity fail-closed, selftest 13; controls 16 MATCH.
- B→C (`711e6393`): capture-confined `body_path`, column-0 header refusal, manifest fetched-ISO/2xx/bijection, `NORMALIZER_SHA256_PIN=14f6ca6a…`, locate-producer rc ∈ {0,1}, non-regular entries, selftest 18; counter `SELF_OK=0`/`gate-digest`/fifo; controls pipefail, race-tolerant `mk_ref`, INSTRUMENT lines; 20 MATCH.
- C→D (`d3623187`): header refusal made case-insensitive `(?im)` in gate and counter (C shipped `(?m)` — N5), `-> N` boundary `(?![0-9A-Za-z_.])` (C allowed `1.0`/`1_0` — N6), two new header-case selftest cases → 20; controls +F7c → 21 MATCH.
- D→E (`dd31b786`): counter tool guards (`sha256sum`, `cut`, `tail`, `timeout`, `git`, `tar` → `SETUP no-<tool>`), plan selftest token 18→20 fixed, control F11b (`-> 1.0` boundary witness) → controls 22 MATCH. E is guard/doc hardening, not verdict tightening: **epoch D also reads `value=10` (disclosed)**.
- Receipt `.ufo/waves/round-56/controls/controls-prefreeze-epochE.txt` (14983 B, sha256 `b4ab59c5498272a7fe97d28f72bc06a1de66f06f2ef86783bbd09c8211fc711e`): **22 CONTROL / 22 MATCH**, **0** `tar: Cannot stat`, 0 credential-pattern hits. Six `INSTRUMENT` lines equal the committed sha256 above (plan `212e2dd7`, counter `d468533f`, controls `01060f25`, gate `5165da2a`, manifest `df46be5c`, normaliser `14f6ca6a`).
- Kill rule binds `dd31b786 → candidate` on `plans/round-56.{md,-c1.sh,-controls.sh}`; gate and normaliser are outside that pathspec but pinned, so mixed-epoch candidates read `FAIL`.

## Epoch-E verification, anchored to `dd31b786`

- Committed bytes equal my snapshot for all six frozen paths; worktree clean for them.
- Gate: `--selftest` rc 0 `PASS (20 cases)`; `--root .` rc 0 `CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`.
- Counter on `dd31b786`: rc 0 `value=10 present=10 replayed=10 gate=1 guard=1`; strace: 0 `connect`, 0 strict `"/tmp/` opens, write opens only `$SCR` + `/dev/null`.
- Readings: `d3623187` → `value=10 … guard=1` (disclosed; no verdict change); `711e6393` → `FAIL … guard=0`; `42070de`/`5d9a157` → `FAIL`; BASE → `value=0 … guard=1`.
- Tool guards (fail-closed): `env -i PATH=/nonexistent /bin/bash plans/round-56-c1.sh …` → `C1_REPLAY: SETUP no-python3` rc 2; PATH with all guarded tools except `cut` → `SETUP no-cut` rc 2; no partial reading.
- Boundary witness: crafted trees restating the betterleaks clock as `-> 1.0` and `-> 1_0` (with the BASE command otherwise intact) → both `value=FAIL present=9 replayed=9 gate=1 guard=0 (bad=absent:betterleaks-detection-vs-validation.md:README.md)` — N6/N6b closed end-to-end (control F11b + this independent `1_0` witness).
- Header-case (D, unchanged gate): crafted `Set-Cookie: sid=dummy` / `http/2 200` at column 0 → C gate CLEAN, D/E gate `BAD-CAPTURE`; indented `  HTTP/1.1 200 OK` (S067 shape) → CLEAN. Frozen captures contain zero case-insensitive header lines (only S067's 18 indented examples), so C's gap was a refusal bypass, not stored-header exposure.
- Confinement/aux-input probes (re-verified; D→E gate bytes unchanged): entry symlink DRIFT; knowledge-dir/SOURCES/normaliser/manifest symlinks `SETUP symlinked-input` rc 2; non-capture `body_path` `BAD-CAPTURE body-not-capture`; fifo entry `UNSUPPORTED non-regular-entry` in 1 s; all 0 outside reads/execs.
- Normaliser: committed `14f6ca6a…` == pin == BASE; gate checks confinement → existence → sha256 before locate; locate rc ∉ {0,1} → `TOOL locate-rcN`.

## Findings

### N5 — MEDIUM for epoch C, CLOSED in D (caught by R56MutCounter F9 / R56ReviewCounter G1)
Epoch-C gate and counter used `(?m)`, so canonical `Set-Cookie:` / `Http/2` at column 0 passed the QM72 refusal. Reproduced with a dummy value: C gate CLEAN, D/E gate BAD-CAPTURE. Impact in C: refusal bypass only — no frozen capture carried such bytes; a forged row still needs a registry URL, hash-bound body and clock match. D fixes with `(?im)` in both files + two selftest cases. **Sentinel self-note: this seat did not test case variants during C; mutation/review seats caught it.**

### N6 — LOW for epoch C, CLOSED in D/E (caught by G2; N6b witness added in E)
C `present()` boundary `1(?![0-9A-Za-z])` accepted `-> 1.0`/`-> 1_0`; numeric capture stayed BASE N (no 10-inflation). D rejects both with `(?![0-9A-Za-z_.])`; E adds control F11b; this seat additionally witnessed `-> 1_0` → absent/FAIL. **N6b closed.**

### F1 — LOW (informational, open; captures unchanged)
`S054.body` (`trufflehog` README): `AKIAYVP4…IFXG` byte 7005 (line 199, sample naming `trufflesecurity/test_keys`) and twice at 8133/8167 (line 232 JSON expected output); `S055.body` (`betterleaks` README): `ghp_aB3d…zA5` byte 8039 (line 187, `// betterleaks:allow`). Public documentation examples, not usable credentials; no cookie/`Authorization` header/private key in any manifest body. Exploit path: none. Impact: scanner noise only. Smallest remediation: none — editing a body breaks its sha256-bound manifest row; allowlist by id/line if scanned.

### F2 — LOW (open; capture unchanged)
`rejections/S113-default-ua.body`, 5448 B, sha256 `ce3cb7f2…b3893c`: CSP nonce 401, `_cf_chl_opt` 2404, `cRay` 2614, `__cf_chl_tk=` 2710, `__cf_chl_f_tk=` 2886, `__cf_chl_rt_tk=` 5148. No `HTTP/` start, no `set-cookie:`, no `cf_clearance`/`__cf_bm`/`Cookie:` value; manifest bodies contain 0 `cf_chl`/`nonce-<16+>` strings. Challenge-scoped, day-stamped, non-authenticating; no consumer references `rejections/`. Sidecar `.meta` (29 B, `403 text/html; charset=UTF-8`) stores status/type only. Smallest remediation: keep future rejection bodies untracked or strip `__cf_chl_*` values.

### F3 — INFO (open)
`S067.body`: `client_secret=some_secret12345` byte 304422 (line 7195), `access_token=SlAV32hkKG` 131608 (3003), elided `id_token=eyJ0…`/`code=SplxlOBe…` 149224 (3413), `access_token=jHkWEdUX…` 421885 (9824), spec text `WWW-Authenticate: Bearer error="invalid_token"` 197485 (4468). Spec examples; no action.

### F4 — CLOSED (B input confinement, C capture confinement)
A followed symlinks for `corpus/knowledge` dir, `SOURCES.md`, `rendered-text-v1.py` (executed) and the manifest; B1 demo read 38 resolved fds outside while CLEAN. B `confined()` + C `capture_confined()` close it; probes show SETUP/BAD-CAPTURE/UNSUPPORTED with 0 outside reads. Residual check-then-use race is not a privilege boundary; C1 was never inflatable.

### F5 — INFO (open; counter/controls)
`SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/c1.$$` + `trap 'rm -rf -- "$SCR"' EXIT`. Unvalidated env override; blast radius is the leaf `…/kagi-r56/c1.<pid>`; `--` blocks option injection; no attacker-reachable path. Suggest absolute + `*/kagi-r56/*` guard.

### F6 — INFO (residual, routed by L1)
The dir-symlink refusal still has no `--selftest` case (20 now); L1 keeps it as a named residual. Any case-count change must update gate bytes → `GATE_SHA256_PIN` → counter `PASS (N cases)` → plan text in one commit.

### F7 — INFO (fail-closed, two pins)
`GATE_SHA256_PIN=5165da2a…` and `NORMALIZER_SHA256_PIN=14f6ca6a…` must equal the committed gate/normaliser bytes; old epochs read `FAIL` (verified `711e6393`, `5d9a157`, `42070de`). Gate, normaliser and counter must land together.

### N1/N2/N3/N4 — status at E
- N1 CLOSED (C/E): `set -u -o pipefail`, presence-filtered `mk_ref`, INSTRUMENT re-hash; epoch-E receipt 22/22 with 0 tar errors. Residual: a vanished non-instrument C1 input is filtered from control trees (visible on K1-REF; potentially invisible to a 0-expectation forgery control) — LOW.
- N2 OPEN (cosmetic): superseded F2 `sub` lines still print one `AssertionError: inert edit` line into the receipt before the effective regex edit; control effective.
- N3 CLOSED (C): unpinned-but-present gate → `SELF_OK=0`, `guard=0`, `gate-digest`.
- N4 CLOSED (C): `gate-digest` token emitted.

## Evidence per check class

A. Patterns across the 7 round-56 bodies, the rejection, and the 3 reused manifest bodies: `set-cookie`, `^authorization:`, `cookie:`, `x-api-key`, `www-authenticate`, `AKIA[0-9A-Z]{16}`, `ghp_…`, `xox[baprs]-…`, `-----BEGIN … PRIVATE KEY-----`, full `eyJ….….…`, `sk-…`, `glpat-…`, `op://…`, `cf_clearance`, `__cf_bm`, `session[_-]?id`, `jsessionid`, `phpsessid`, `csrf…`, `client_secret`, `password`, `vault`, `item id`. Only F1–F3 hits; zero private keys, zero full JWTs, zero vault/item ids, zero `Set-Cookie` lines (case-insensitive whole file), no body starts with `HTTP/`. High-entropy strings in `S057`/`S070` are public assets (archbee CDN hash, favicon, Vercel `dpl_`, Google-font subset).

B. `tempfile.TemporaryDirectory` only in selftest (honours `TMPDIR`); only literal `/tmp` is the UNSUPPORTED fixture. Counter/controls export `TMPDIR` under `HYAKU_SCRATCH`, and E guards the tools it invokes. strace: 0 strict `/tmp` opens, 0 writes outside scratch across gate/selftest/counter runs.

C. Manifest 10/10: relative, no `..`, no symlink component, resolved inside repo, regular, bytes+sha256 equal the row, no header bytes, under a `capture*` path (S101, S113, S114, S054, S055, S057, S067, S070, S074, S078). Gate rejects absolute/`..`/symlink/wrong-digest/header bodies and non-capture paths.

D. `shell=True`/`os.system`/`os.popen`/`eval(`/`exec(`/`sh -c`/`bash -c`: 0 matches in gate+counter+controls. Subprocess calls are argument lists; `grep -c -e` binds leading-dash patterns; `shlex.split` tokens must pass the whitelist; locate producer rc checked. Run-mode execs: `grep`, `pdftotext`, `python3` only.

E. Gate imports `hashlib os re shlex subprocess sys tempfile pathlib`; no `urllib`/`requests`/`socket`/`http.client`/`ssl`; `curl` only as docstring/regex/POP data. strace `connect`/`socket` = 0.

F. Off-tree opens: gate run `/etc/ld.so.cache` (selftest adds `/etc/localtime`, `/etc/ssl/openssl.cnf`); counter adds git config and `/etc/{gitattributes,nsswitch.conf,passwd,group}` — interpreter/git runtime only. Probes: 0 outside reads/execs.

G. `fetch-receipt.json` 3218 B: keys `date,author,command_template,header_policy,observed_rows`; 7 rows keyed exactly `id,url,final_url,http_status,curl_rc,body_path,decoded_bytes,sha256`; template has no `-D`/`-i`/`-H`; row hashes/bytes equal manifest and files. Rejection sidecar status/type only. Header refusal is case-insensitive at column 0 (`(?im)`), including `< ` trace prefixes, while indented spec examples pass.

H. `plans/round-56.md` / `recheck-captures.tsv` / `source-fetches.tsv` (S057/S070/S074 rows) / epoch-E controls receipt: URLs, dates, statuses, sizes, sha256 hex, commit id, ids; credential-pattern hits 0.

## Candidate landing verification (`bcf07e7d`)

The C1 landing commit `bcf07e7daf797e5ad2c6bf64306738199a333f64` ("round-56: C1 freshness — stated-clock offline replay capability …") landed after epoch E. Verified:
- `git diff dd31b786 bcf07e7d -- <kill paths> <captures>` is empty; the six frozen blobs in the candidate equal epoch E exactly (gate `79fb022b/5165da2a`, counter `cc27f350/d468533f`, controls `7bd6e725/01060f25`, plan `a4303acf/212e2dd7`, manifest `7c85dc4d/df46be5c`, normaliser `30baa609/14f6ca6a`).
- Counter on `bcf07e7d`: rc 0 `value=10 present=10 replayed=10 gate=1 guard=1`; strace 0 `connect`, 0 strict `"/tmp/` opens. BASE on the candidate: `value=0 … guard=1`.
- Landing diff secret scan (`git diff dd31b786 bcf07e7d`): the only `Set-Cookie`/`HTTP` hits are dummy fixtures in reviewer/control text (`Set-Cookie: x=1`, `k=v`, `y=2`); no real credentials, no new production files outside reports/build receipts/landing docs.

## Limits
- Capture provenance is the receipt's self-report; no live re-fetch by this seat.
- Anchor `dd31b786` verified for the six frozen paths; landing edits remain candidate content.
- Epoch D also reads `value=10` (disclosed by L1); E is guard/doc hardening, not verdict tightening.
- Counter readings are safety observations on the committed instrument, not claim adjudication.
- No offensive replication; fetched content was read as data only. The N5 reproduction used a dummy `sid=dummy` value, no real secret.

## Scratch
`/fast/scratch/hyaku/kagi-r56/R56Sentinel/` only; removed before yield. Raw stub: `.ufo/waves/round-56/w1/R56Sentinel.d/receipts.txt`.
