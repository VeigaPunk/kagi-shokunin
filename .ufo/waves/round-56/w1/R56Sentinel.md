# R56Sentinel — round 56 w1 safety/scope scan

Seat: R56Sentinel. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Epoch-B predeclaration (final anchor): `5d9a1571911ec38a456a40b443e19640abb9a88b`. Epoch-A (superseded): `42070de7770e1558adcf6aa7a7bc59309a9654d7`. BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Scan window 2026-11-07T07:30–07:48-03:00. Answering model: harness-reported `amr/deepseek-v4.1-flash`; no self-introspection beyond that.
Tools installed/updated: none (no pacman transaction; `/home/vgpnk/.omp/agent/RULES.md` read first).
No production file edited, no git/jj mutation, no network fetch, no secret printed (token middles redacted).
States scanned: **A** = frozen `42070de`; **B1** = first re-freeze bytes (07:37–07:39, superseded); **B** = `5d9a157` (committed epoch-B predeclaration). L1 `KagiR56a3` confirmed the A→B edits as its re-freeze after `R56ReviewCounter` F1–F7 and accepted both sentinel items (F4 fix; selftest kept at 13 cases with the dir-symlink residual routed).

## Instrument snapshots (sha256; A from `git show 42070de:<path>`, B from `git show 5d9a157:<path>`)

| path | A (42070de) | B (5d9a157) |
|---|---|---|
| `corpus/recheck-replay.py` | blob `821da99c…`, sha256 `b7782f35…d799e8`, 14716 B | blob `850e1ba9be3a4e2f4e669328b91f7d0de331159f`, sha256 `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51`, 15684 B |
| `plans/round-56-c1.sh` | blob `35a16e6…`, sha256 `096251c9…9bde9a`, 12933 B | blob `23111d50e357b5d3f6471289c8cde073e27b3804`, sha256 `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c`, 15746 B (`GATE_SHA256_PIN=2e9dfde3…` = gate ✓) |
| `plans/round-56-controls.sh` | blob `07d0e234…`, sha256 `633326a5…48b094`, 6341 B | blob `fda549111119628e879471e3a04b1bc54a27a4e6`, sha256 `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f`, 8795 B (14 `check` lines) |
| `plans/round-56.md` | blob `106be490…`, sha256 `d1bf8d26…e0b8a07`, 5652 B | blob `ec6a50df005a9f4d4ebabf3fb21b38fc7cd23f5c`, sha256 `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679`, 6204 B |
| `corpus/recheck-captures.tsv` | blob `7c85dc4d…`, sha256 `df46be5c…b7ecc762`, 2391 B | **unchanged** |
| `.ufo/waves/round-56/capture/*` | bodies + receipt + rejection | **unchanged** (hashes below) |
| B1 (superseded) | gate `637c8184…` 15105 B, counter `d2bcb790…` 15746 B, controls `bb48db96…` 8862 B | — |

Working tree at 07:47:34 is clean for all five frozen paths (`git status --porcelain` rc 0, empty) and matches `5d9a157`; `corpus/SOURCES.md` is dirty (frontier S113 edit: worktree blob `70e0223`/sha256 `299903cf…` vs committed/42070de blob `6a25a13`/`fa69564f…`), and one untracked rejection sidecar appeared at 07:46 (`rejections/S113-default-ua.meta`, 29 B, `403 text/html; charset=UTF-8`, sha256 `7aaecbcd46924c5ced8453aa9e186aa25ba138a4b752489be9a636c0fc700cc8`). Both are landing-step items, not frozen-instrument edits; both are CLEAN (the sidecar matches the round-55 `.meta` status/type convention and stores no headers/cookies).

## Verdict matrix

| # | Check class (assignment) | A (42070de) | B (5d9a157) |
|---|---|---|---|
| A | Credential-shaped material in captures (tokens, cookies, session ids, `Set-Cookie`, `Authorization`, vault/item names) | CLEAN + F1/F2 LOW | unchanged (captures byte-identical) |
| B | Hardcoded `/tmp`; `TMPDIR`/`HYAKU_SCRATCH` honoured | CLEAN | CLEAN |
| C | Path escapes (gate, counter, manifest `body_path`) | CLEAN; F4 gap | **CLEAN — F4 closed and probe-verified** |
| D | Shell execution of fetched content | CLEAN | CLEAN |
| E | Network — gate offline | CLEAN (strace) | CLEAN (strace) |
| F | Host file reads outside the tree | CLEAN except F4 | **CLEAN — 0 outside reads across 5 probes** |
| G | Fetch receipts / QM72 (no stored headers) | CLEAN | CLEAN; new rejection sidecar also header-free |
| H | Secrets in plan / manifest / controls receipt | CLEAN | CLEAN |
| I | Frozen instruments unchanged during the wave | A→B edits (W1) | **landed as re-freeze `5d9a157`; verified** |

## W1 — A→B instrument edits (L1 re-freeze; landed as `5d9a157`)

- 07:35:34 gate +9/−2: symlinked `corpus/knowledge/*.md` entries now emit `("<rel>",0,"<symlinked-entry>",-1)` → `UNSUPPORTED reason=symlinked-entry` (A silently skipped them).
- 07:36–07:41 counter: gate sha256 pin, gate rc-0 requirement, exact `CLEAN (clocks=10 match=10 …0)` regex, exact `SELFTEST: PASS (13 cases)`, manifest arity fail-closed, `present()` right-boundary (`(?![0-9A-Za-z_.])`).
- 07:38–07:42 plan/controls: re-freeze note + r5/GUARD wording; forgery controls added (python printer gate, in-place gate edit, symlinked gate path, `-> 1x`, extra uncertified clock, gate byte drift); F11 fixture regex fixed to `(->\s*)1(?!\d)`.
- 07:41:21 gate: `confined()` extends the component-symlink rule to `KNOWLEDGE`, `REGISTRY`, `MANIFEST`, `corpus/rendered-text-v1.py`; `run()` returns `SETUP symlinked-input:<rel>`. Counter re-pinned (`6b132ea1…` ↔ gate `2e9dfde3…`).
- 07:44:40 commit `5d9a157` freezes the set; controls receipt `.ufo/waves/round-56/controls/controls-prefreeze-epochB.txt` (16375 B, sha256 `709cf29a03f5ba9cc1c2eacb60036a23d5836803e655f4f0c0c91fefc8145aea`): **16 CONTROL lines, 16 MATCH**, no token/credential patterns (`hits=0`).

Transition evidence: A counter on `42070de` → `value=10 present=10 replayed=10 gate=1 guard=1` rc 0; the B counter on `42070de` → `value=0 present=10 replayed=0 gate=0 guard=1` rc 0 (pin mismatch, every r5 fails). Kill rule now binds `5d9a157 → candidate` on `plans/*`; the gate is **not** in that pathspec but the pin couples it — a candidate with different gate bytes reads `value=0`. Impact resolved by the re-freeze; risk remaining is only mixed-epoch landing, which the pin converts to a visible `0`.

## Epoch-B verification, anchored to `5d9a157`

Committed bytes (`git show 5d9a157:<path>`) equal my pre-commit B2 snapshot for all five frozen paths and the manifest; the committed gate/counter were re-run from scratch trees:
- `corpus/recheck-replay.py --selftest` rc 0 `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`; `--root` on an archive of `5d9a157` rc 0 `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`.
- Counter on revision `5d9a157`: rc 0 `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`; strace `openat,connect`: 0 `connect`, 0 strict `"/tmp/` opens, write opens only inside `$SCR` + `/dev/null`, no lane writes.
- Counter on BASE `832ba6a`: rc 0 `value=0 present=10 replayed=0 gate=0 guard=1` (r2-manifest) — matches plan's BASE reading.
- Counter on A `42070de`: rc 0 `value=0 present=10 replayed=0 gate=0 guard=1` (r5-gate) — matches L1's value=0; see N3 on the `guard=1` field.
- Confinement probes on `git archive 5d9a157` (one copy per probe; `strace -y` resolves fds; `outside` counts references to the probe's out-of-tree path): entry symlink rc 1 `DRIFT clocks=11 unsupported=1` 0 outside; knowledge-dir symlink rc 2 `SETUP symlinked-input:corpus/knowledge` 0 outside; `SOURCES.md` symlink rc 2 SETUP 0 outside; `rendered-text-v1.py` symlink rc 2 SETUP 0 outside reads/execs; manifest symlink rc 2 SETUP 0 outside.
- Controls receipt has no secret patterns; the only noise is N1/N2 below.

## Findings

### F1 — LOW (informational, open; captures unchanged)
`S054.body` (`trufflehog` README): `AKIAYVP4…IFXG` byte 7005 (line 199, "Found verified result / Detector Type: AWS" sample naming `trufflesecurity/test_keys`) and twice at 8133/8167 (line 232 JSON expected output); `S055.body` (`betterleaks` README): `ghp_aB3d…zA5` byte 8039 (line 187, Go snippet annotated `// betterleaks:allow`). Public documentation examples, not usable credentials; no cookie/`Authorization` header/private key in any manifest body. Exploit path: none. Impact: scanner noise only. Smallest remediation: none — editing a body breaks its sha256-bound manifest row; allowlist by id/line if scanned.

### F2 — LOW (open; capture unchanged)
`rejections/S113-default-ua.body`, 5448 B, sha256 `ce3cb7f2…b3893c`, blob `48456b48…`: CSP nonce byte 401, `_cf_chl_opt` 2404, `cRay` 2614, `__cf_chl_tk=` 2710, `__cf_chl_f_tk=` 2886, `__cf_chl_rt_tk=` 5148. No `HTTP/` start, no `set-cookie:`, no `cf_clearance`/`__cf_bm`/`Cookie:` value; all manifest bodies contain 0 `cf_chl`/`nonce-<16+>` strings. Challenge-scoped, day-stamped, non-authenticating; no consumer references `rejections/` (grep over `corpus/ plans/` rc 1). The new untracked sidecar `S113-default-ua.meta` stores only status/type (no headers, no cookie). Impact: committed ephemeral artifact only. Smallest remediation: keep future rejection bodies untracked or strip `__cf_chl_*` values before commit.

### F3 — INFO (open)
`S067.body`: `client_secret=some_secret12345` byte 304422 (line 7195), `access_token=SlAV32hkKG` 131608 (3003), elided `id_token=eyJ0 …`/`code=SplxlOBe…` 149224 (3413), `access_token=jHkWEdUX…` 421885 (9824), spec text `WWW-Authenticate: Bearer error="invalid_token"` 197485 (4468, documentation). Spec examples; no action.

### F4 — CLOSED at `5d9a157` (was open in A; demonstration retained)
A followed symlinks for `corpus/knowledge` (dir), `corpus/SOURCES.md`, `corpus/rendered-text-v1.py` (executed) and the manifest; B1 demo: `corpus/knowledge -> <outside dir>` → gate rc 0 `CLEAN` with 38 resolved fds outside. B `confined()` (gate lines 207–218) rejects each with `SETUP symlinked-input:<rel>`; all five probes on the committed tree: rc 2 / DRIFT and 0 outside reads/execs. Residual: check-then-use race, not a privilege boundary; C1 was never inflatable (counter r1 `read()` rejects symlink components, r2 parses the registry itself, r4 replays with BASE's normaliser).

### F5 — INFO (open; counter/controls)
`SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/c1.$$` + `trap 'rm -rf -- "$SCR"' EXIT`. Unvalidated env override; blast radius is the leaf `…/kagi-r56/c1.<pid>`; `--` blocks option injection; no attacker-reachable path. Smallest remediation: require an absolute path matching `*/kagi-r56/*` before `mkdir`/trap.

### F6 — INFO (residual, routed by L1)
The dir-symlink refusal has no `--selftest` case (13 kept). Any future case must update gate bytes → `GATE_SHA256_PIN` → the counter's exact `PASS (13 cases)` match → the plan's "13 cases" sentence in one commit.

### F7 — INFO (fail-closed coupling)
`GATE_SHA256_PIN` must equal the committed gate blob. Any later gate edit without a pin update fails every r5 (`gate-digest`); the pinned counter intentionally refuses `42070de` (observed value=0). Fail-closed, but gate and counter must always land together.

### N1 — INFO: controls receipt carries `tar: Cannot stat` errors (non-fatal)
`controls-prefreeze-epochB.txt` contains repeated `tar: .ufo/waves/round-56/build-{dispatch.json,spec.json,ready,swarm-registry.json}: Cannot stat …` (these tracked files were deleted in the working tree when `mk_ref` ran `git ls-files -co`). The reference trees still copy every C1 input and all 16 controls MATCH, but the copy step is not fail-closed on tar errors. Future-round remediation: check the archive/copy pipeline rc and filter deleted paths (`git ls-files -co --deleted` exclusion), so a deleted C1 input cannot go silently missing.

### N2 — INFO: dead fixture lines print an `AssertionError` into the receipt
The F2 block keeps two superseded `sub` attempts (`by default` pattern; `|| true`) before the effective regex edit; the receipt for K1-F2 contains `AssertionError: inert edit corpus/knowledge/betterleaks-detection-vs-validation.md`, then the real `py` block asserts and restates `-> 1` to `-> 2` (control read `present=9`, `absent`). Cosmetic/readability only; the control is effective.

### N3 — LOW (report drift, no inflation)
On a tree that carries a gate whose digest is not the pin (`42070de`), the counter prints `guard=1` although that gate's `--selftest` is never run: `HAVE_GATE=0` skips the whole pin/selftest block and `SELF_OK` stays at its initial 1. Committed plan `5d9a157:plans/round-56.md:15` says `GUARD = 1 iff all 10 clocks are PRESENT … and the gate's --selftest exits 0 with last line RECHECK_REPLAY_SELFTEST: PASS (13 cases)`. Observed: `C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate:…)` rc 0. Value stays fail-closed (`REPLAYED` needs r5, which needs `gate_ok=1`, which needs the pin match), so no claim can be inflated; the `guard` field merely overstates on that tree. Smallest remediation (future round): set `SELF_OK=0` when a gate file is present but unpinned (or re-emit a `gate-digest` bad token as B1 did), keeping value unchanged.

## Evidence per check class

A. Patterns across the 7 round-56 bodies, the rejection, and the 3 reused manifest bodies (`S101.raw`, round-55 `S113/S114.body`): `set-cookie`, `^authorization:`, `cookie:`, `x-api-key`, `www-authenticate`, `AKIA[0-9A-Z]{16}`, `ghp_…`, `xox[baprs]-…`, `-----BEGIN … PRIVATE KEY-----`, full `eyJ….….…`, `sk-…`, `glpat-…`, `op://…`, `cf_clearance`, `__cf_bm`, `session[_-]?id`, `jsessionid`, `phpsessid`, `csrf…`, `client_secret`, `password`, `vault`, `item id`. Only F1–F3 hits; zero private keys, zero full JWTs, zero vault/item ids, zero `Set-Cookie` lines (case-insensitive, whole file), no body starts with `HTTP/`. `S057`/`S070` high-entropy strings are public assets (archbee CDN hash 1972, favicon 1437, Vercel `dpl_` 28713, Google-font subset 15921).

B. `tempfile.TemporaryDirectory` only in selftest (honours `TMPDIR`); only literal `/tmp` is the UNSUPPORTED fixture. Counter/controls export `TMPDIR` under `HYAKU_SCRATCH`. strace: A gate 0 strict `/tmp`/0 writes; A selftest 0 `/tmp`/53 writes all under `$TMPDIR`; A counter 0 `/tmp`; B counter 0 `/tmp`. No lane writes by any run.

C. Manifest 10/10: relative, no `..`, no symlink component, resolved inside repo, regular, bytes+sha256 equal the row, no header bytes (S101, S113, S114, S054, S055, S057, S067, S070, S074, S078). Gate/counter reject absolute/`..`/symlink/wrong-digest/header bodies; `git archive | tar -x -C` and `cp -a` write only inside `$SCR`. B closes the auxiliary-input gap (F4).

D. `shell=True`/`os.system`/`os.popen`/`eval(`/`exec(`/`sh -c`/`bash -c`: 0 matches in gate+counter+controls. Subprocess calls are argument lists; `grep -c -e` binds leading-dash patterns; `shlex.split` tokens must pass the whitelist. Run-mode execs observed: `grep`, `pdftotext`, `python3` only.

E. Gate imports `hashlib os re shlex subprocess sys tempfile pathlib`; no `urllib`/`requests`/`socket`/`http.client`/`ssl`; `curl` only as docstring/regex/POP data. strace `connect`/`socket` = 0 for A gate, A selftest, A counter, B counter.

F. Off-tree opens: gate run `/etc/ld.so.cache` (selftest adds `/etc/localtime`, `/etc/ssl/openssl.cnf`); counter adds git config (`~/.gitconfig`, `~/.config/git`) and `/etc/{gitattributes,nsswitch.conf,passwd,group}` — interpreter/git runtime only. B probes: 0 outside reads. No `Path.home`/`expanduser`/`os.environ` in gate logic.

G. `fetch-receipt.json` 3218 B: keys `date,author,command_template,header_policy,observed_rows`; 7 rows keyed exactly `id,url,final_url,http_status,curl_rc,body_path,decoded_bytes,sha256`; template has no `-D`/`-i`/`-H`; row hashes/bytes equal manifest and files. New rejection sidecar: `403 text/html; charset=UTF-8` only (29 B), no headers/cookies. No other receipt file under `capture/`.

H. `plans/round-56.md` / `recheck-captures.tsv` / controls receipt: URLs, dates, statuses, sizes, sha256 hex, commit id, ids only; controls-receipt credential scan `hits=0`. The sole `cookie` token in the plan is the QM72 refusal clause.

## Limits
- Capture provenance is the receipt's self-report; no live re-fetch by this seat.
- Anchor `5d9a157` verified for the five frozen paths and manifest; the working tree additionally carries the frontier `SOURCES.md` edit and an untracked rejection sidecar (both landing-step, CLEAN) that are not part of the frozen instruments.
- The counter readings are safety observations on the committed instrument, not claim adjudication.
- No offensive replication; fetched content was read as data only.

## Scratch
`/fast/scratch/hyaku/kagi-r56/R56Sentinel/` only; removed before yield. Raw stub: `.ufo/waves/round-56/w1/R56Sentinel.d/receipts.txt`.
