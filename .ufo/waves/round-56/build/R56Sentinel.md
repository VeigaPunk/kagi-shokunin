# R56Sentinel — round 56 attempt 1: safety / scope scan

Seat: `R56Sentinel` (sentinel, leaf — no dispatch). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Observed answering model: `amr/deepseek-v4.1-flash` (runtime project context; not inferred from the prompt).
BASE: `832ba6a53d6a76706b5c80bce2278683dea33d42`. Scanned tree: frozen predeclaration HEAD
`42070de7770e1558adcf6aa7a7bc59309a9654d7` (the ticket's "PROPOSED, NOT FROZEN" set was committed
mid-scan; every scan below was re-measured against the committed blobs, and working-tree files were
checked byte-identical to their `42070de` blobs). Scan window 2026-11-07 ~07:05–07:40 -0300.
No production file was edited. One report + receipts written (this file and `R56Sentinel.d/`).

## Verdict (scoped to the landing set)

| bar | verdict | evidence |
|---|---|---|
| public documentation GET only | PASS | receipt template `curl -fsSL --compressed --max-time 60 -o <id>.body -w …`; no `-D`/`-i`/`-H`/`-d`/`-X`, no auth; every stored body starts with document bytes (`<html`, `<p`, `#`, `%PDF-1.6`) |
| bodies carry no cookie/session/credential **response** material | PASS | 0 `Set-Cookie`, 0 `^Cookie:`, 0 `cf_clearance|__cf_bm|JSESSIONID|PHPSESSID|_session_id|sessionid=`, 0 `HTTP/` prefixes across the 11 manifest/adjacent bodies |
| scripts read no host/secret surface | PASS | 0 matches for `.ssh`, `.netrc`, `op read/run/inject`, `keychain`, `/etc/`, `secret-tool` in gate/counter/controls; all reads are under the tested tree + git `show/archive` |
| no shell execution of document text | PASS (claim scripts) | parsed `curl` text is only reshaped into argv lists for fixed binaries (`grep`, `pdftotext`, `sys.executable`); 0 `shell=True`, `os.system`, `os.popen`, `eval(`; only `eval`/`bash -c` in the wave is the sibling live driver, see F6 |
| no path escapes | PASS | absolute path, `..`, and any symlink component in `body_path` refused (`BAD-CAPTURE`); empirically re-proved on a scratch tree; selftest case `escape-path`/`symlink-component` PASS |
| no hardcoded `/tmp` trees | PASS | scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/{c1,controls}.$$` + `trap rm -rf`; counter exports `TMPDIR=$SCR/tmp`; the only `/tmp` in the set is a selftest fixture string that asserts UNSUPPORTED and is never executed |
| QM72 header scrub | PASS with two literal-pattern gaps (F1) | gate refuses status-line prefixes and `set-cookie:` lines (empirical BAD-CAPTURE control); capture step cannot emit them; no git hook enforces it — it is gate-time, exactly as `plans/round-56.md` names it ("header-bytes refusal") |

Instrument readings I ran: gate `--selftest` 13/13 PASS rc0; gate on the lane rc0
`RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)`; counter on `42070de` rc0
`value=10 present=10 replayed=10 gate=1 guard=1`; counter on BASE rc0
`value=0 present=10 replayed=0 gate=0 guard=1`.

## Instruments (sha256 / git blob at 42070de — report these, not the working copy)

| path | sha256 | blob |
|---|---|---|
| `corpus/recheck-replay.py` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `821da99ce83e7b3adbea80ad9e1441d8e0fe9a79` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | `7c85dc4da34bc79931e01906b91e4c3fda91b2c5` |
| `plans/round-56-c1.sh` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `35a16e682a8a508976498727e337c40d6f1f86c1` |
| `plans/round-56-controls.sh` | `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094` | `07d0e234fc455b01f00a665b3ac8b648ac4dc013` |
| `plans/round-56.md` | `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07` | `106be490947ce3a5141da24c3b356cbd0679d99f` |
| `corpus/rendered-text-v1.py` (BASE-pinned normalizer) | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` | `30baa6092981d2cff1581c1fbfbd43a06f05cfe1` |
| `capture/fetch-receipt.json` | see `R56Sentinel.d/hashes.txt` | `22c735bc582479dcdf17b1d056f7ecc241fbfa90` |
| `controls/controls-prefreeze.txt` | see `R56Sentinel.d/hashes.txt` | `50e082c767942bea03ea2353351776fd9191b4ce` |

All 7 round-56 body digests re-measured and equal to the manifest rows (10/10 rows, including the
three prior-round bodies S101/S113/S114, `bytes_ok=1 sha_ok=1`).

## Findings

### F1 (Low) QM72 refusal is a literal prefix test, not a header parser
Evidence: `corpus/recheck-replay.py:167` = `re.match(rb"HTTP/\d", data) or re.search(rb"(?im)^set-cookie:", data)`.
Scratch trees under `/fast/scratch/hyaku/kagi-r56/R56Sentinel/mut/<case>` (one clock, self-consistent
manifest row, run `python3 -I -B corpus/recheck-replay.py --root <case>`):

| injected body first lines | rc | verdict |
|---|---|---|
| ` Set-Cookie: sid=…` (leading space) | 0 | MATCH / CLEAN — **not refused** |
| `Set-Cookie2: a=b` | 0 | MATCH / CLEAN — **not refused** |
| `HTTP/2 200\r\n\r\n` | 1 | BAD-CAPTURE `header-bytes` (control, refused) |
| BOM + `HTTP/2 200` | 0 | MATCH / CLEAN — **not refused** |

Impact: none on this capture set — the capture step stores no headers (`-o` only, no `-D`/`-i`) and all
11 stored bodies have 0 header lines, so a real `curl -o` body cannot hit these shapes. It matters only
as a bound on the QM72 sentence: the refusal is a byte-prefix test, and a body that *begins* with header
bytes past a BOM or an indented cookie line scores. There is also **no commit-time enforcement**: `git
config core.hooksPath` is empty and `.git/hooks` has 0 non-sample files; the plan correctly calls this a
gate-time refusal, not a precommit hook.
Smallest remediation (not applied; one line each): `re.search(rb"(?im)^[ \t]*set-cookie2?:", data)` and
test the status line on `data.lstrip(b"\xef\xbb\xbf")`.

### F2 (Low) Controls K1-F2 leaves an AssertionError traceback in the pre-freeze receipt
Evidence: `plans/round-56-controls.sh` blob `07d0e234…` lines 49–50. Line 49
`sub "$SCR/f2" "$ENTRY" "by default\` -> 1" "by default\` -> 2" || true` is inert (the literal is absent —
the entry ends ``…by default' | grep -c '…'` -> 1 (ran 2026-11-04)``), the assert fires, and
`controls-prefreeze.txt` (blob `50e082c7…`) carries
`Traceback … AssertionError: inert edit corpus/knowledge/betterleaks-detection-vs-validation.md`
between the K1-F1 and K1-F2 lines. Line 50 is a same-old/same-new no-op. The control still reads
`FAIL` and `MATCH` (12/12) only because the regex edit at lines 51–54 performs the restatement.
Impact: receipt noise and two dead edits; a reader cannot tell which edit produced the forgery. The
reading itself is correct. Remediation: delete lines 49–50 (or fix the literal to the real line tail).
I did not edit the frozen controls.

### F3 (Info) Three bodies carry published documentation example tokens (not response credentials)
Masked counts only — no values reproduced here:

- `S054.body` sha256 `7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7` (38524 B):
  TruffleHog's own README canary demo. One unique 20-char `AKIA`-shaped canary key ID at offsets
  6965/8093/8127, with the canary account id and ARN in the same block. It is the vendor's published
  canary-token output; a key ID without the secret key cannot authenticate (and exercising a canary
  would alert its owner — do not).
- `S055.body` sha256 `f61c3993fd48dfb973652b9676697f4d37404fad9f30748c2003127eb81a73b1` (13252 B):
  one 40-char `ghp_`-shaped synthetic test vector at offset 8035 inside
  `const token = "…" // betterleaks:allow` — the project's own suppression-marked fixture.
- `S067.body` sha256 `4d016752a645e8a3c259baa4173b5a90cb6c82898ce868fc8444adde262a5aed` (437508 B):
  RFC 6749 / OpenID Core example `access_token` / `refresh_token` / `id_token` values
  (offsets 110204/110264/110321 and the spec's example blocks; 10 `eyJ`-prefixed literals, 5 decoding
  to JWT headers, `alg` RS256/None) — spec examples.

Verdict: document text, not credential *response* material from our GET. Quarantine is neither needed
nor safe (rewriting a body breaks its sha256-bound manifest row and the claim); flag for the lane's
secret-scanner policy instead.

### F4 (Info) Non-author provenance spot check — captures genuine
Public GETs from scratch (`/fast/scratch/hyaku/kagi-r56/R56Sentinel/live/`), receipt template, headers
not stored, files deleted after measurement:

- S055 URL → HTTP 200, sha256 `f61c3993…` = manifest row, 13252 decoded bytes → **byte-identical**.
- S074 URL → HTTP 200, 45351 B, same title and `public comment period is CLOSED` count (1); digest
  `e16254f6…` differs from the manifest `df32e64b…` in **583/45351 bytes across 7 clusters**, every
  cluster inside Cloudflare email-obfuscation ciphertext (`__cf_email__` / `data-cfemail`), plus one
  per-request timestamp token and one script nonce. Same size/title/quote and only per-request volatile
  tokens changed ⇒ the committed capture is a genuine page snapshot, and a byte-exact later re-fetch is
  not achievable for this URL.

Measurement caveat in the receipt (informational): under the receipt's own `--compressed` template,
curl's `%{size_download}` is the *compressed* transfer size (observed 5483 for S055) while
`fetch-receipt.json`'s `decoded_bytes` is the stored body size (13252). The body digest matches, so this
is a label/method imprecision in provenance evidence; wording should say `wc -c` of the stored body (or
drop `--compressed` for the sample).

### F5 (Info) Gate trust boundary: the gate executes code from the tree under test
`replay()` locate form runs `sys.executable -I -B <root>/corpus/rendered-text-v1.py` (`recheck-replay.py:190-193`),
and counter r5 runs the measured tree's own `recheck-replay.py`. A candidate tree could ship doctored
code and print its own MATCH/CLEAN. Admission is not exposed: counter r4 replays independently with
BASE's normalizer (`git show BASE:corpus/rendered-text-v1.py`) and the pinned body. Ceiling only for
"gate alone as oracle". Minor, same class: `clocks()` / `registry_rows()` follow a *directory* symlink at
`corpus/knowledge` / `corpus/SOURCES.md` (file-level symlinks are refused); irrelevant for the lane tree,
relevant only for an untrusted `--tree`.

### F6 (Info) Sibling live driver is the only shell-exec surface in the wave
`attempt1-build/R56ExecLive.d/live.sh:22,28` runs the entry's own command text via `bash -c "$2"` and
`eval "$3"`. Scratch-only (`/fast/scratch/hyaku/kagi-r56/R56ExecLive`), lane-authored commands, 0
secret/host reads. Out of the claim instruments; noted because the gate deliberately never executes
`recheck:` text and this leg does.

### F7 (Info) Main-repo misroot review — nothing attributable to this wave; nothing deleted
`git -C /home/vgpnk/Projects/shokunin status --porcelain` untracked at the fleet root:

| path | size | mtime (-0300) | content |
|---|---|---|---|
| `f.txt` | 2 B | 2026-11-07 04:40:38 | `x\n` |
| `trail-ids.txt` | 1 B | 2026-11-06 20:36:24 | `,` |
| `.scratch/run15-wrapup/misroot-cff0b4cb/` | dir | 2026-11-06 16:36:21 | `versions.html`, `w4lines.txt` |

Wave start evidence: captures 2026-11-07 07:04:52, dispatch 07:09 — all three predate the wave by ≥2 h,
so none is attributable to round 56. No path named `round-56` exists outside the lane except
orchestrator-owned `.ufo/reports/round-56/` and `.ufo/prompts/closure/*-round-56.md` (other lanes'
prompts); other-lane files modified after 06:55 belong to their own seats. No deletion, no move.

## Quarantine
No new suspect. `.ufo/waves/round-56/capture/rejections/S113-default-ua.body` (sha256
`ce3cb7f2eb0efeba38faff1ded3186218ad9df51e4b22b795d0688fa2eb3893c`, 5448 B) is a Cloudflare
"Just a moment…" interstitial taken with the default UA; it is already isolated outside the manifest
(0 manifest references; the gate never reads it) and carries 0 header/cookie bytes. It should not be
added to any manifest row.

## Not run (unrun is not passed)
- Full 10-URL live recheck: not run here (R56ExecLive's leg). My live sample covers 2 of 10 (S055 exact,
  S074 quote-equal); live currency of the other 8 is unverified by this seat.
- Gate/counter mutation campaign: not run here (R56MutGate/R56MutCounter). I ran only the built-in
  `--selftest`, the two counter readings, and the four QM72 edge trees in F1.
- No host/substrate probes (out of PROVINCE; the-janitor substrate absent).
- No git/jj mutation in the lane, fleet or siblings; no fixture clone needed.

## Observation on the tree
The working tree is dirty against `42070de` (L1 moved the dispatch files to `attempt1-build/` and `w1/`
and deleted `build-spec.json`, `build-dispatch.json`, `build.ready`, `build/swarm-registry.json` from the
working tree). Not my edit; the frozen commit still contains them. Instrument blobs and working files
were identical at scan time.

## Receipts
- `.ufo/waves/round-56/build/R56Sentinel.d/scan-commands.txt` — verbatim commands, rc, counts.
- `.ufo/waves/round-56/build/R56Sentinel.d/findings.tsv` — id, severity, artifact, sha256, command, rc, verdict.
- `.ufo/waves/round-56/build/R56Sentinel.d/hashes.txt` — all instrument, body, receipt hashes + git blobs.
Scratch `/fast/scratch/hyaku/kagi-r56/R56Sentinel/` deleted before yield. No live clone created.
