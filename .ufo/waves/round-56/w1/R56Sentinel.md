# R56Sentinel — round 56 w1 safety/scope scan

Seat: R56Sentinel. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
HEAD at final snapshot: `42070de7770e1558adcf6aa7a7bc59309a9654d7` (epoch-A predeclaration; the epoch-B predeclaration commit was still pending at 2026-11-07T07:43:05-03:00). BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Scan window 2026-11-07T07:30–07:43-03:00. Answering model: harness-reported `amr/deepseek-v4.1-flash`; no self-introspection beyond that.
Tools installed/updated: none (no pacman transaction; `/home/vgpnk/.omp/agent/RULES.md` read first).
No production file edited, no git/jj mutation, no network fetch, no secret printed (token middles redacted).

Three instrument states were scanned: **A** = frozen `42070de`; **B1** = the first L1 re-freeze bytes (07:37–07:39, superseded); **B2** = the confinement-fixed re-freeze bytes (07:41:21–07:42:02, current at snapshot). L1 `KagiR56a3` confirmed the edits are its re-freeze in response to `R56ReviewCounter` F1–F7 and accepted both sentinel items (F4 fix; selftest stays 13 cases with the dir-symlink residual routed as a named gap).

## Instrument snapshots (sha256; A from `git show 42070de:<path>`, B from the working file)

| path | A (42070de) | B2 (current, 07:41–07:42) |
|---|---|---|
| `corpus/recheck-replay.py` | blob `821da99c…`, sha256 `b7782f35…d799e8`, 14716 B | blob `850e1ba9…`, sha256 `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51`, 15684 B |
| `plans/round-56-c1.sh` | blob `35a16e6…`, sha256 `096251c9…9bde9a`, 12933 B | blob `23111d50…`, sha256 `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c`, 15746 B (`GATE_SHA256_PIN=2e9dfde3…` = gate ✓) |
| `plans/round-56-controls.sh` | blob `07d0e234…`, sha256 `633326a5…48b094`, 6341 B | blob `fda54911…`, sha256 `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f`, 8795 B (14 `check` lines) |
| `plans/round-56.md` | blob `106be490…`, sha256 `d1bf8d26…e0b8a07`, 5652 B | blob `ec6a50df…`, sha256 `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679`, 6204 B |
| `corpus/recheck-captures.tsv` | blob `7c85dc4d…`, sha256 `df46be5c…b7ecc762`, 2391 B | **unchanged** |
| `.ufo/waves/round-56/capture/*` | 7 bodies + receipt + rejection, hashes below | **unchanged** |
| B1 (superseded) | gate `637c8184…` 15105 B, counter `d2bcb790…` 15746 B, controls `bb48db96…` 8862 B | — |

## Verdict matrix

| # | Check class (assignment) | A (frozen) | B2 (current) |
|---|---|---|---|
| A | Credential-shaped material in captures (tokens, cookies, session ids, `Set-Cookie`, `Authorization`, vault/item names) | CLEAN + F1/F2 LOW | unchanged (manifest/captures byte-identical) |
| B | Hardcoded `/tmp`; `TMPDIR`/`HYAKU_SCRATCH` honoured | CLEAN | CLEAN |
| C | Path escapes (gate, counter, manifest `body_path`) | CLEAN; F4 gap | **CLEAN — F4 fixed in B2, verified** |
| D | Shell execution of fetched content | CLEAN | CLEAN |
| E | Network — gate offline | CLEAN (strace) | CLEAN (strace) |
| F | Host file reads outside the tree | CLEAN except F4 | **CLEAN — 0 outside reads across 5 probes** |
| G | 7 fetch receipts, no response headers (QM72) | CLEAN | unchanged |
| H | Secrets in plan / manifest | CLEAN | CLEAN |
| I | Frozen instruments unchanged during the wave | **A→B edits (W1)** | B2 is the re-freeze set; commit pending |

## W1 — instrument edits after `42070de` (L1 re-freeze; confirmed)

- 07:35:34 gate +9/−2: symlinked `corpus/knowledge/*.md` entries now emit `("<rel>",0,"<symlinked-entry>",-1)` → `UNSUPPORTED reason=symlinked-entry` (A silently skipped them).
- 07:36–07:39 counter: gate sha256 pin, gate rc-0 requirement, exact `CLEAN (clocks=10 match=10 …0)` regex, exact `SELFTEST: PASS (13 cases)`, manifest fail-closed, `present()` right-boundary.
- 07:38–07:42 plan/controls: re-freeze note + r5/GUARD wording; five new forgery controls (python printer gate, in-place gate edit, symlinked gate path, `-> 1x`, extra uncertified clock); F11 fixture regex fixed (`(->\s*)1(?!\d)`).
- 07:41:21 gate B2: `confined()` extends the component-symlink rule to `KNOWLEDGE`, `REGISTRY`, `MANIFEST`, and `corpus/rendered-text-v1.py`; `run()` returns `SETUP symlinked-input:<rel>`. Counter re-pinned to the B2 gate (`6b132ea1…` ↔ `2e9dfde3…`).

Transition evidence: frozen A counter on `42070de` → `value=10 present=10 replayed=10 gate=1 guard=1` rc 0; the first pinned counter on the same revision → `value=FAIL … gate-digest` rc 0 (by design, the pin binds the candidate gate). Impact: none if B2 lands as one commit (the kill rule binds the new predeclaration); a mixed-epoch candidate reads `FAIL (gate-digest)` or trips the kill rule. A is byte-intact in git and no longer describes the working tree. I made no git mutation; L1 owns the commit.

## Epoch-B2 verification (current bytes, scratch-only harness)

Harness: `verify-epochB.sh` in my scratch — snapshots hashes, static-scans, runs `bash -n`, `--selftest`, `--root .`, feeds a preview candidate (`git archive 42070de` + current gate + current `SOURCES.md`) through the current counter under `strace`, then five confinement probes on tree copies.

- `bash -n` rc 0. Unsafe-pattern scan: only the selftest fixture string `-o /tmp/x` (UNSUPPORTED data, never run); no `urllib`/`requests`/`socket`/`os.system`/`shell=True`/`eval(`/`exec(`.
- `--selftest` rc 0 `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`; `--root .` rc 0 `CLEAN (clocks=10 match=10 …)`.
- Counter `--tree` on the preview candidate: rc 0 `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`; strace `openat,connect`: **0** `connect`, **0** strict `"/tmp/` opens, write opens only under `$SCR` + `/dev/null`; outer reads only git config and `/etc/{ld.so.cache,localtime,nsswitch.conf,passwd,ssl/openssl.cnf}`.
- Confinement probes (each on its own copy; `strace -y` resolves fds; `outside_reads` counts any reference to the probe's outside path):
  - symlinked knowledge **entry** → rc 1, `DRIFT (clocks=11 … unsupported=1)`, 0 outside reads (correct: entry is not read).
  - symlinked **knowledge dir** → rc 2, `SETUP symlinked-input:corpus/knowledge`, 0 outside reads (A: CLEAN while opening 38 resolved fds outside — gap closed).
  - symlinked **SOURCES.md** → rc 2 `SETUP symlinked-input:corpus/SOURCES.md`, 0 outside reads.
  - symlinked **rendered-text-v1.py** → rc 2, `SETUP symlinked-input:corpus/rendered-text-v1.py`, 0 outside reads/execs.
  - symlinked **manifest** → rc 2 `SETUP symlinked-input:corpus/recheck-captures.tsv`, 0 outside reads.
- Controls (B2): no `/tmp`, network, shell-exec or absolute host paths; the only `set-cookie` and `/tmp` strings are fixture data. The new checks are 14 vs A's 12 (commit message will change).

## Findings

### F1 — LOW (informational, open in A and B2; captures unchanged)
`S054.body` (`trufflehog` README): `AKIAYVP4…IFXG` at byte 7005 (line 199, "Found verified result / Detector Type: AWS" sample naming `trufflesecurity/test_keys`) and twice at 8133/8167 (line 232 JSON expected output); `S055.body` (`betterleaks` README): `ghp_aB3d…zA5` at byte 8039 (line 187, Go snippet annotated `// betterleaks:allow`). Public documentation examples, not usable credentials; no cookie/`Authorization` header/private key in any manifest body. Exploit path: none. Impact: scanner noise only. Smallest remediation: none — editing a body breaks its sha256-bound manifest row; allowlist by id/line if scanned.

### F2 — LOW (open; capture unchanged)
`.ufo/waves/round-56/capture/rejections/S113-default-ua.body`, 5448 B, sha256 `ce3cb7f2eb0efeba38faff1ded3186218ad9df51e4b22b795d0688fa2eb3893c`, blob `48456b48…`: CSP nonce byte 401, `_cf_chl_opt` 2404, `cRay` 2614, `__cf_chl_tk=` 2710, `__cf_chl_f_tk=` 2886, `__cf_chl_rt_tk=` 5148. No `HTTP/` start, no `set-cookie:`, no `cf_clearance`/`__cf_bm`/`Cookie:` value; all 10 manifest bodies contain 0 `cf_chl`/`nonce-<16+>` strings. Challenge-scoped, day-stamped, non-authenticating; no consumer references `rejections/` (grep over `corpus/ plans/` rc 1). Impact: committed ephemeral artifact only. Smallest remediation: keep future rejection bodies untracked or strip `__cf_chl_*` values before commit.

### F3 — INFO (open)
`S067.body`: `client_secret=some_secret12345` byte 304422 (line 7195), `access_token=SlAV32hkKG` 131608 (3003), elided `id_token=eyJ0 …`/`code=SplxlOBe…` 149224 (3413), `access_token=jHkWEdUX…` 421885 (9824), spec text `WWW-Authenticate: Bearer error="invalid_token"` 197485 (4468, documentation, not a stored header). Spec examples; no action.

### F4 — CLOSED in B2 (open in A; demonstration retained)
A followed symlinks for `corpus/knowledge` (dir), `corpus/SOURCES.md`, `corpus/rendered-text-v1.py` (executed) and the manifest; demonstrated on B1: `corpus/knowledge -> <outside dir>` → gate rc 0 `CLEAN` while 38 resolved fds pointed outside. B2 `confined()` (gate lines 207–218) rejects these with `SETUP symlinked-input:<rel>`; all five probes: rc 2 / DRIFT, 0 outside reads/execs. Residual: `confined()` is check-then-use, not atomic — a concurrent writer inside the measured tree could swap a component after the check; the tree author already controls the bytes, so this is not a privilege boundary. C1 was never inflatable (counter r1 `read()` rejects symlink components, r2 parses the registry itself, r4 replays with BASE's normaliser).

### F5 — INFO (open in A and B2)
`SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/c1.$$` + `trap 'rm -rf -- "$SCR"' EXIT` (counter; controls same shape). Unvalidated env override; blast radius is the leaf `…/kagi-r56/c1.<pid>`; `--` blocks option injection; no attacker-reachable path. Smallest remediation: require an absolute path matching `*/kagi-r56/*` before `mkdir`/trap.

### F6 — INFO (residual, routed by L1)
B2's dir-symlink refusal has no `--selftest` case (still 13); L1 keeps 13 to avoid a pin+case-count lockstep change and routes "gate lacks selftest case for dir-symlink" as a named residual. Coupling to remember: any future selftest case must update gate bytes → `GATE_SHA256_PIN` → the counter's exact `PASS (13 cases)` match → the plan's "13 cases" sentence in one commit.

### F7 — INFO (fail-closed coupling)
`GATE_SHA256_PIN` must equal the gate blob committed in the new predeclaration. Any later gate edit without a pin update fails r5 for every clock (`gate-digest`), and the pinned counter intentionally refuses `42070de` (observed `value=FAIL … gate-digest` rc 0). Fail-closed, but gate and counter must always land together.

## Evidence per check class

A. Patterns across the 7 round-56 bodies, the rejection, and the 3 reused manifest bodies (`S101.raw`, round-55 `S113/S114.body`): `set-cookie`, `^authorization:`, `cookie:`, `x-api-key`, `www-authenticate`, `AKIA[0-9A-Z]{16}`, `ghp_…`, `xox[baprs]-…`, `-----BEGIN … PRIVATE KEY-----`, full `eyJ….….…`, `sk-…`, `glpat-…`, `op://…`, `cf_clearance`, `__cf_bm`, `session[_-]?id`, `jsessionid`, `phpsessid`, `csrf…`, `client_secret`, `password`, `vault`, `item id`. Only F1–F3 hits; zero private keys, zero full JWTs, zero vault/item ids, zero `Set-Cookie` lines (case-insensitive, whole file), no body starts with `HTTP/`. `S057`/`S070` high-entropy strings are public assets (archbee CDN hash 1972, favicon 1437, Vercel `dpl_` 28713, Google-font subset 15921).

B. `tempfile.TemporaryDirectory` only in selftest (honours `TMPDIR`); only literal `/tmp` is the UNSUPPORTED fixture. Counter/controls export `TMPDIR` under `HYAKU_SCRATCH`. strace: A gate 0 strict `/tmp`/0 writes; A selftest 0 `/tmp`/53 writes all under `$TMPDIR`; A counter 0 `/tmp`; B2 counter 0 `/tmp`. No lane writes by any run.

C. Manifest 10/10: relative, no `..`, no symlink component, resolved inside repo, regular, bytes+sha256 equal the row, no header bytes (S101, S113, S114, S054, S055, S057, S067, S070, S074, S078). Gate rejects absolute/`..`/symlink/wrong-digest/header bodies; `git archive | tar -x -C` and `cp -a` write only inside `$SCR`. B2 closes the auxiliary-input gap (F4).

D. `shell=True`/`os.system`/`os.popen`/`eval(`/`exec(`/`sh -c`/`bash -c`: 0 matches in gate+counter+controls. Subprocess calls are argument lists; `grep -c -e` binds leading-dash patterns; `shlex.split` tokens must pass the whitelist. Run-mode execs observed: `grep`, `pdftotext`, `python3` only.

E. Gate imports `hashlib os re shlex subprocess sys tempfile pathlib`; no `urllib`/`requests`/`socket`/`http.client`/`ssl`; `curl` only as docstring/regex/POP data. strace `connect`/`socket` = 0 for A gate, A selftest, A counter, B2 counter.

F. Off-tree opens: gate run `/etc/ld.so.cache` (selftest adds `/etc/localtime`, `/etc/ssl/openssl.cnf`); counter adds git config (`~/.gitconfig`, `~/.config/git`) and `/etc/{gitattributes,nsswitch.conf,passwd,group}` — interpreter/git runtime only. B2 probes: 0 outside reads. No `Path.home`/`expanduser`/`os.environ` in gate logic.

G. `fetch-receipt.json` 3218 B: keys `date,author,command_template,header_policy,observed_rows`; 7 rows keyed exactly `id,url,final_url,http_status,curl_rc,body_path,decoded_bytes,sha256`; template has no `-D`/`-i`/`-H`; row hashes/bytes equal manifest and files. No other receipt file under `capture/`.

H. `plans/round-56.md` / `recheck-captures.tsv`: URLs, dates, statuses, sizes, sha256 hex, commit id, ids only. The sole `cookie` token in the plan is the QM72 refusal clause.

## Limits
- Capture provenance is the receipt's self-report; no live re-fetch by this seat.
- Epoch-B2 was uncommitted at the final snapshot (HEAD `42070de`, 07:43:05); its hashes are bound to 07:41:21–07:42:02. A byte-rescan of the committed epoch-B predeclaration is advisable once it lands (same harness, same classes).
- The B2 `--tree` reading (`value=10 … guard=1`) is a safety/sanity observation on a preview tree, not a claim adjudication.
- No offensive replication; fetched content was read as data only.

## Scratch
`/fast/scratch/hyaku/kagi-r56/R56Sentinel/` only; removed before yield. Raw stub: `.ufo/waves/round-56/w1/R56Sentinel.d/receipts.txt`.
