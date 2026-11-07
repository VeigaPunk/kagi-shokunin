# R56ReviewGate — adversarial correctness review, round 56 C1 gate and counter

Seat: `R56ReviewGate` (leaf, no dispatch). Lane `kagi-shokunin`, branch `master`. BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Answered model: `amr/deepseek-v4.1-flash` (observed from the runtime model field of this session, not inferred from the prompt).

Evidence is anchored to the **frozen epoch-B predeclaration commit `5d9a1571911ec38a456a40b443e19640abb9a88b`**. The working tree equals that commit for all five instrument paths (`git status --porcelain` empty), and the independent reference tree used below was built from those bytes.

| path at `5d9a157` | sha256 |
|---|---|
| `corpus/recheck-replay.py` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` |
| `plans/round-56-c1.sh` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` |
| `plans/round-56-controls.sh` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` |
| `plans/round-56.md` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| `corpus/rendered-text-v1.py` (same at BASE) | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` |
| `GATE_SHA256_PIN` (`plans/round-56-c1.sh:79`) | `2e9dfde3…` — equals the gate |

Epoch-A (`42070de`) evidence is kept only where it shows what epoch-B closed: gate `b7782f35…`, counter `096251c9…`, controls `633326a5…`, plan blob `106be49…`, receipt `3cc3e977…`.

## 1. Verified on the frozen bytes (independent re-run)

Scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewGate`; reference tree = `git ls-files -co --exclude-standard` of the frozen worktree. Deleted before yield; evidence copied to `R56ReviewGate.d/`.

| check | command | rc / observed |
|---|---|---|
| gate, identity | `python3 -I -B corpus/recheck-replay.py --root <ref>` | 0, `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` |
| gate selftest | `--selftest` | 0, `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` |
| counter, identity | `bash plans/round-56-c1.sh --tree <ref>` | 0, `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| counter, BASE | `bash plans/round-56-c1.sh 832ba6a5…` | 0, `value=0 present=10 replayed=0 gate=0 guard=1` — matches the plan's stated BASE reading |
| counter, epoch-A tree | `bash plans/round-56-c1.sh 42070de` | 0, `value=0` (gate digest) — as reported by the L1 |
| controls | `bash plans/round-56-controls.sh <lane>`, 16 controls | `CONTROLS: match=16 mismatch=0`; frozen receipt `.ufo/waves/round-56/controls/controls-prefreeze-epochB.txt` sha256 `709cf29a03f5ba9cc1c2eacb60036a23d5836803e655f4f0c0c91fefc8145aea`, same line |
| manifest digests | recompute bytes+sha256 of all 10 rows | 10/10 equal; all `http_status=200`; ISO dates |
| committed capture hygiene | `head -c 5` + `grep -ci set-cookie` on all 10 bodies; `grep -ci 'set-cookie\|cookie\|authorization'` on `fetch-receipt.json` (counts only; contents not printed) | 0 / 0 / 0 |
| symlink confinement | readable same-dir link; symlinked directory component; symlinked entry | `BAD-CAPTURE … symlink:` / `UNSUPPORTED … symlinked-entry`; sound |
| `pdftotext` rc | pdf form on an HTML body | `TOOL … pdftotext-rc1` → DRIFT; rc honoured |
| locale | `grep -c` under `LC_ALL=C` and `C.UTF-8`, 8 grep-form clocks | identical: S054 1, S055 1, S057 1, S067 1, S074 1, S101 2, S113 3, S114 2 |
| parser | `parse()` over 16 forms | `--max-time=30`, `grep -c -i`, `grep -Fc`, `…|grep`, two URLs, `./corpus/…`, `locate -` refused with a named reason; none silently mis-parsed |

## 2. Findings on `5d9a157`

### F1 — HIGH — the r3 header refusal is narrower than the frozen predicate; a `curl -v`-shaped capture scores `value=10`
Predicate (`plans/round-56.md`, r3): the body "**carries** no HTTP status line or `set-cookie:` line".
Implementation:
- gate `corpus/recheck-replay.py:174` — `if re.match(rb"HTTP/\d", data) or re.search(rb"(?im)^set-cookie:", data):`
- counter `plans/round-56-c1.sh:262` — `if data.startswith(b"HTTP/") or re.search(rb"(?im)^set-cookie:", data):`

Both anchors require column 0, and the gate additionally requires a digit after `HTTP/`. `curl -v` prefixes response lines with `< `; `curl -i` is caught, `curl -v` is not — the most common way to save headers by accident.

Reproduction on the frozen bytes (reference tree + S054 body replaced by six trace lines + the genuine 38524-byte body; manifest row rewritten to the true bytes/sha):
```
S054 body bytes 38730, sha256 2030fd595bee75fbb0f985238d84892d5dab7a76cb7d9de077ca3efba6dc2115
prefix: "* Connected to raw.githubusercontent.com\n* using HTTP/1.1\n> GET /x HTTP/1.1\n< HTTP/1.1 200 OK\n< set-cookie: session=demo-not-a-real-value\n< content-type: text/plain\n\n"
gate  -> rc 0, "RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 …)"
counter (sha 6b132ea1, stable across the run) -> "C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)"
```
The same body with headers at offset 0 is refused (`BAD-CAPTURE … header-bytes:…`, DRIFT) — the only shape control K1-F7 (`plans/round-56-controls.sh:115`) and the gate selftest (`corpus/recheck-replay.py:307`) exercise. The guard passes its tests while the property it names is false for a realistic capture, and the header bytes (with a cookie value) sit sha-bound in the committed manifest. This is the QM72 path reopened; it is **not** covered by the "committed bytes only" ceiling, because the plan's r3 independently refuses header-bearing bodies.

Surgical fix (one line each):
- gate `:174` → `if re.search(rb"(?im)^[ \t]*(?:< )?HTTP/\d", data) or re.search(rb"(?im)^[ \t]*(?:< )?set-cookie\s*:", data):`
- counter `:262` → the same expression (also removes the `startswith(b"HTTP/")` vs `re.match(HTTP/\d)` asymmetry: the counter refuses `HTTP/x`, the gate does not).
- add control `K1-F7b-header-v` (expect 0) and a selftest case with headers at a non-zero offset. No plan-text change: it already says "carries".

### F2 — MEDIUM — `http_status` and `fetched` are recorded, printed in the header, and never read
No reference except the header list (`corpus/recheck-replay.py:52`, `plans/round-56-c1.sh:186`) and one prose mention. Reproduced on the frozen bytes, counter stable per run:
```
S054 http_status 200 -> 404           : value=10 present=10 replayed=10 gate=1 guard=1
S054 fetched 2026-11-07 -> not-a-date : value=10 present=10 replayed=10 gate=1 guard=1
```
A 403/404/500 body registered with a consistent sha is admitted as evidence. The frozen r3 does not require a status, so this is a predicate gap rather than a divergence; all 10 rows are `200`/ISO today, so tightening costs nothing. Amend r3 to "…and whose `http_status` is `2xx` and `fetched` matches `YYYY-MM-DD`", enforce in both instruments, add a 404 control.

### F3 — MEDIUM (gate only) — the `locate` stage ignores the producer's exit code
`corpus/recheck-replay.py:195-200` runs `<root>/corpus/rendered-text-v1.py locate <body> <quote>` and returns the first `count=` on stdout; rc is discarded. Reproduction (frozen tree; normaliser replaced by a printer emitting `RENDERED_TEXT_V1_LOCATE: count=1` then `sys.exit(2)`):
```
gate  -> "MATCH … S070 form=locate stated=1 replayed=1", "RECHECK_REPLAY: CLEAN (clocks=10 …)", rc 0
counter -> value=10   (r4 uses BASE's normaliser and is independent, so the claim is safe)
```
The real normaliser legitimately exits 1 for `count=0` (`locate <S070.body> 'no such quote anywhere'` → `count=0`, rc 1), so the guard must be `rc in (0,1)`: `if res.returncode not in (0, 1): return None, "locate-rc%d" % res.returncode`. Also print `normaliser_sha256=<sha>` in the CLEAN summary and bind it in r5 — the gate runs the **measured tree's** normaliser (epoch-A evidence: a forged normaliser plus a restated N produced gate CLEAN while the counter correctly read `value=FAIL present=9`).

### F4 — LOW (latent) — the gate's registry check is weaker than r2
`corpus/recheck-replay.py:118` scans every line for `^ {0,3}\|\s*(S\d{3,})\s*\|` with no ``` fence exclusion, no cell-count check, no `status` check; `check_capture` (`:152`) accepts the URL anywhere on the row. r2 (`plans/round-56-c1.sh:239-241`) requires outside-fence, exactly 11 cells, `cells[7]=="mined"`, URL as a token in cell 1. Demonstrated on epoch-A (code unchanged in the frozen bytes):
- S054 row inside a ``` fence: gate `CLEAN`, counter `value=9 … bad=r2-registry:…`
- S054 URL moved from the source cell to the teaches cell: gate `CLEAN`, counter `value=9 … bad=r2-registry:…`
Latent: `corpus/SOURCES.md` has 114 outside-fence rows, 0 inside-fence rows, each manifest id exactly once. The counter is authoritative, so no claim forgery. Fix: reuse the counter's `registry()` in the gate.

### F5 — LOW — the gate raises where it documents `SETUP` (exit 2)
`corpus/recheck-replay.py:63-72`, `:118`, `:130`, `:152-176` are unprotected. Appending `\xff\xfe` to `corpus/knowledge/trufflehog-verification-lifecycle.md` yields `UnicodeDecodeError: 'utf-8' codec can't decode byte 0xff in position 6441`, rc 1, no `RECHECK_REPLAY:` token, while the documented contract is exit 2 `RECHECK_REPLAY: SETUP <reason>`. The counter degrades safely (gate_clean 0), but wrappers distinguishing DRIFT (1) from SETUP (2) are misled. Same class: unreadable entry, directory named `*.md`, embedded NUL in `body_path`. Wrap in `try/except (OSError, UnicodeDecodeError, ValueError)` → `setup(...)`.

### F6 — LOW — control K1-F6's symlink fixture is dangling
`plans/round-56-controls.sh:101` moves the body to the tree root (`$SCR/f6/s055.body`) but links to `../../../s055.body` from `.ufo/waves/round-56/capture/`, which resolves to `.ufo/s055.body` — absent (`readlink -f` confirms). The control passes only because any symlink is refused; I verified the guard separately against a readable same-dir link and a symlinked directory component (both `BAD-CAPTURE … symlink:`). Fix the target to `../../../../s055.body` so the control proves refusal of a readable symlink.

### F7 — LOW — `mk_ref` ignores archive failure
`plans/round-56-controls.sh:21`, no `pipefail`, no rc check. One of my runs emitted four `tar: … Cannot stat` errors (the L1 had just moved wave receipts to `attempt1-build/`) and still produced a `CONTROLS:` line. Only receipts were missing then; a missing capture would silently make `K1-REF` read 0. Fix: `set -o pipefail` plus `|| { echo "mk_ref $1 failed" >&2; exit 2; }`, or build the reference from `git archive <candidate>`.

### F8 — LOW — `present()`'s right-bound is narrower than the predicate
Predicate: the `-> N` token is "right-bounded by a non-digit non-letter". Counter `plans/round-56-c1.sh:153`: `(?![0-9A-Za-z_.])` — `.` and `_` are non-digit non-letter, so the predicate accepts `-> 1.` / `-> 1_` and the counter does not. Probe: `-> 1.` in the S057 clock ⇒ `value=FAIL present=9 replayed=9 … bad=absent:trufflehog-verification-lifecycle.md:verification-caching`. Fail-closed, but a formatting variant reads as absent. Fix: `(?![0-9A-Za-z])`.

### F9 — INFO — the pinned digest couples the gate to the counter commit
`GATE_SHA256_PIN` (`plans/round-56-c1.sh:79`) means any gate edit after the pin makes every reading 0. The kill rule's pathspec covers only `plans/*`, so the gate's freeze rests entirely on this pin: the candidate must carry byte-identical gate bytes, and any pre-candidate gate change requires a re-pin in the same commit (observed live during this review: pin `637c8184…` against gate `a1b6270e…`, then re-pin to `2e9dfde3…`).

### F10 — INFO — never run the controls while the lane is being edited
`bash` reads a script incrementally, so a controls run overlapping an edit mixes old and new expectations. My first run, started against an earlier `plans/round-56-controls.sh`, printed `CONTROLS: match=11 mismatch=5` with `expect=FAIL got=0` for F5/F5b/F5c — not the frozen expectations (`check K1-F5-printer-gate 0 f5`). That reading is an artefact and is discarded; the frozen receipt and my second run both read 16/16. Freeze-time controls should run on a quiescent tree with the instrument hashes recorded before and after.

### F11 — Fixed in epoch B (recorded so the epoch boundary is auditable)
Epoch A had four refusals that `5d9a157` closes; each was reproduced on `42070de` before the amendment:
- a failing gate ending `RECHECK_REPLAY: CLEANUP failed, population truncated` and exiting 3 read `value=10 present=10 replayed=10 gate=1 guard=1` (prefix match on `CLEAN`, exit code ignored). Now: digest pin + `GATE_RC=0` + exact `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`; same tree now reads `value=0`.
- deleting a clock line or its `-> N` left the gate `CLEAN (clocks=9 …)`; r5 now requires `clocks=10` and the counter reads `value=FAIL present=9`. The gate **alone** still prints `CLEAN (clocks=9 …)` — its population is unbound — but the counter bounds it.
- an 8-column manifest row was silently skipped; now `bad=r2-manifest-malformed`.
- a symlinked entry or symlinked `corpus/knowledge` was skipped/followed; now `UNSUPPORTED … reason=symlinked-entry` and `SETUP symlinked-input:…`.

## 3. Pre-freeze position and L1 disposition

The epoch-B predeclaration was committed at `5d9a157` before this report. The L1 (KagiR56a3) accepted the change set in reply, to land as an **epoch-C re-freeze** batched with any further wave findings:

| item | disposition |
|---|---|
| **F1** header refusal | **accepted** — extend both instruments to indented / `< `-prefixed trace lines; add control `K1-F7b` (expect 0) and a gate selftest case (13→14 cases) |
| **F2** `http_status`/`fetched` | **declared non-binding** in the plan's named-ceilings sentence (provenance columns only) |
| **F3** locate rc | **accepted** — producer rc must be in `(0,1)` |
| **F6** dangling symlink control | **accepted** — target depth fixed to `../../../../` |
| **F7** `mk_ref` tar swallow | **accepted** — fail loudly |
| **F8** `present()` lookahead | not yet dispositioned; `(?![0-9A-Za-z])` is the one-character fix |

What epoch-C must update **in lockstep**, or the reading zeroes:
1. `GATE_SHA256_PIN` (`plans/round-56-c1.sh:79`) = the new gate digest; the gate bytes are otherwise unconstrained by the kill rule's pathspec.
2. The counter's selftest literal `"RECHECK_REPLAY_SELFTEST: PASS (13 cases)"` (`plans/round-56-c1.sh:73-76` region) and the plan's GUARD sentence ("PASS (13 cases)") → `(14 cases)`; the gate prints `PASS (%d cases)`, so 14 is the emitted string.
3. A new controls receipt (the frozen one `709cf29a…` is epoch-B); re-run on a quiescent tree.
4. The gate selftest header case must use a **non-zero offset** (`b"\n< HTTP/1.1 200 OK\n< set-cookie: …"`), else it passes under both the old and new regexes.

One consequence to state in the plan text: the widened pattern (`^[ \t]*(?:< )?HTTP/\d`, `^[ \t]*(?:< )?set-cookie\s*:`) classifies a *quoted* header line in a documentation body as header bytes. That is fail-closed and acceptable, but it means a legitimate capture of a page that itself shows an HTTP trace can be refused; the named-ceilings sentence should say the refusal covers any line whose first non-blank token is `HTTP/`, `< HTTP/`, `set-cookie:` or `< set-cookie:`.

Evidence in this report is anchored to `5d9a157`; epoch-C bytes are unreviewed here and need a fresh run of `R56ReviewGate.d/repro.sh` plus the control suite. At review close the gate was modified but uncommitted (`corpus/recheck-replay.py` sha256 `f5bf52300f55f9289e3f4bf4ad1eafc7b667536a8022c47e3193ae1fdfd33421`, `git status` ` M`); counter/plan/controls were still at the `5d9a157` bytes, so no epoch-C reading exists yet. An independent pre-check for the planned `body_path` confinement was sent: S101 is six components (`.ufo/waves/round-45/controls/capture-r45/S101.raw`) and fails a per-component `.ufo/waves/*/capture*/*` glob, so the matcher-independent predicate `parts[:2]==(".ufo","waves") and len(parts)>=5 and any(p.startswith("capture") for p in parts[2:-1])` is the form that keeps all ten clocks.

## 4. Residual risk

- **The reading is not a currency check.** `value=10` says the 10 statements are true of the committed bodies; a stale body with a matching digest is indistinguishable (named ceiling, correctly stated in the plan). I did not perform the non-author live re-fetch.
- A committed body with a consistent manifest row scores; F1 and F2 are the extra hygiene guards that do not bind.
- TOCTOU between `is_symlink()`/`is_file()` and `read_bytes()` in both instruments (local attacker only).
- The counter runs the gate and `--selftest` without a subprocess deadline; a hung gate yields no reading rather than a false one.

## 5. Verification gaps

- `en_US.UTF-8` (the ambient `LANG`) is not installed on this host; counts were reproducible only under `C`/`C.UTF-8`. They agree with the stated N and all patterns are ASCII, so no locale defect is recorded, but the author's exact locale was not reproducible.
- I did not run the 10 live `curl` commands; live re-fetch is the wave's currency check, not the gate's.
- `fetch-receipt.json` was read only through case-insensitive counts (`set-cookie`/`cookie`/`authorization` = 0/0/0); contents were not printed.

## Trailer

- Report: `.ufo/waves/round-56/build/R56ReviewGate.md`
- Evidence: `.ufo/waves/round-56/build/R56ReviewGate.d/repro.sh`, `…/R56ReviewGate.d/probe-output.txt`, `…/R56ReviewGate.d/hashes.txt`
- No production file was modified; no git/jj mutation in the lane, fleet or siblings; scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewGate` deleted after evidence copy.
- Tool installs: none.
