# R56ReviewGate — adversarial correctness review, round 56 C1 gate and counter

Seat: `R56ReviewGate` (leaf, no dispatch). Lane `kagi-shokunin`, branch `master`. BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Answered model: `amr/deepseek-v4.1-flash` (observed from the runtime model field of this session, not inferred from the prompt).

The lane moved under this review. Two snapshots are named below; **every final citation is against S1**, the working-tree epoch-B bytes present at review close. S0 is the committed predeclaration; evidence produced against S0 is kept because it shows what epoch-B fixed.

| snapshot | gate `corpus/recheck-replay.py` | counter `plans/round-56-c1.sh` | controls | plan |
|---|---|---|---|---|
| **S0** commit `42070de` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094` | blob `106be490947ce3a5141da24c3b356cbd0679d99f` |
| **S1** working tree | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `bb48db9605ede5770582178d6962a5a75acfb9d1086e1f0d3098954685958b3e` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` |

Stable throughout S1: manifest `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` (10 rows, unchanged since S0).
Counter pin at S1: `GATE_SHA256_PIN=2e9dfde3…` (`plans/round-56-c1.sh:79`), equal to the S1 gate.

Observed churn during the review (minutes apart, same working tree): counter `096251c9 → 0153f876 → d2bcb790 → 6b132ea1`; gate `b7782f35 → 637c8184 → a1b6270e → 2e9dfde3`; controls `633326a5 → bb48db96`; plan `d1bf8d26 → 033f2104`; at one instant the pin was `637c8184` while the gate was `a1b6270e` (every reading would have been 0), and at another the counter was mid-write and `bash -n` failed at line 109. Findings below are keyed to the bytes named, not to the path.

## 1. Verified on S1 (independent re-run)

Scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewGate`; reference tree built from `git ls-files -co --exclude-standard` of the S1 worktree (copy is byte-identical to the reviewed paths). Deleted before yield; evidence copied to `R56ReviewGate.d/`.

| check | command | rc / observed |
|---|---|---|
| gate, identity | `python3 -I -B corpus/recheck-replay.py --root <ref>` | 0, `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` |
| gate selftest | `--selftest` | 0, `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` |
| counter, identity | `bash plans/round-56-c1.sh --tree <ref>` | 0, `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| counter, BASE | `bash plans/round-56-c1.sh 832ba6a5…` | 0, `value=0 present=10 replayed=0 gate=0 guard=1` — matches the plan's stated BASE reading |
| manifest digests | recompute bytes+sha256 of all 10 rows | 10/10 equal; all `http_status=200`; ISO dates |
| committed capture hygiene | `head -c 5` and `grep -ci set-cookie` on all 10 bodies; `grep -ci 'set-cookie\|cookie\|authorization'` on `fetch-receipt.json` (counts only, contents not printed) | 0 / 0 / 0 |
| symlink confinement | readable same-dir link, symlinked directory component | `BAD-CAPTURE … symlink:` both; sound |
| `pdftotext` rc | pdf form on an HTML body | `TOOL … pdftotext-rc1` → DRIFT; rc honoured |
| locale | `grep -c` under `LC_ALL=C` and `C.UTF-8`, 8 grep-form clocks | identical: S054 1, S055 1, S057 1, S067 1, S074 1, S101 2, S113 3, S114 2 |
| parser | `parse()` over 16 forms | `--max-time=30`, `grep -c -i`, `grep -Fc`, `…|grep`, two URLs, `./corpus/…`, `locate -` all refused with a named reason |

## 2. Findings

### F1 — HIGH — the r3 header refusal is narrower than the frozen predicate; a `curl -v`-shaped capture scores `value=10` on S1
Predicate (`plans/round-56.md`, r3): the body "**carries** no HTTP status line or `set-cookie:` line".
Implementation, byte-identical in S0 and S1:
- gate `corpus/recheck-replay.py:174` — `if re.match(rb"HTTP/\d", data) or re.search(rb"(?im)^set-cookie:", data):`
- counter `plans/round-56-c1.sh:262` — `if data.startswith(b"HTTP/") or re.search(rb"(?im)^set-cookie:", data):`

Both anchors require column 0, and the gate requires a digit after `HTTP/`. `curl -v` output prefixes response lines with `< `; `curl -i` is caught, `curl -v` is not — the most common way to save headers by accident.

Reproduction (S1 snapshot; S054 body = 6 trace lines + the genuine 38524-byte body; manifest row rewritten to the true bytes/sha; counter hashes stable across the run):
```
S054 body bytes 38730, sha256 2030fd595bee75fbb0f985238d84892d5dab7a76cb7d9de077ca3efba6dc2115
prefix: "* Connected to raw.githubusercontent.com\n* using HTTP/1.1\n> GET /x HTTP/1.1\n< HTTP/1.1 200 OK\n< set-cookie: session=demo-not-a-real-value\n< content-type: text/plain\n\n"
gate  -> rc 0, "RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)"
counter (S1, sha 6b132ea1…, stable) -> "C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)"
```
The same body with the headers at offset 0 is refused (`BAD-CAPTURE … header-bytes:…`, DRIFT) — which is the only shape control K1-F7 (`plans/round-56-controls.sh:115`) and the gate selftest (`corpus/recheck-replay.py:307`) exercise. So the guard passes its tests while the property it names is false for a realistic capture, and the header bytes (including a cookie value) sit sha-bound in the committed manifest. This is the QM72 path reopened.

Surgical fix (one line each, no structure change):
- gate `:174` → `if re.search(rb"(?im)^[ \t]*(?:< )?HTTP/\d", data) or re.search(rb"(?im)^[ \t]*(?:< )?set-cookie\s*:", data):`
- counter `:262` → the same expression (this also removes the `startswith(b"HTTP/")` vs `re.match(HTTP/\d)` asymmetry: the counter refuses `HTTP/x`, the gate does not).
- add control `K1-F7b-header-v` (expect 0) built by prefixing a capture with the trace above, and a selftest case with headers at a non-zero offset. The plan text needs no change — it already says "carries".

### F2 — MEDIUM — `http_status` and `fetched` are recorded, printed in the header, and never read
No reference anywhere except the header list (`plans/round-56-c1.sh:186`, `corpus/recheck-replay.py:52`) and a prose mention. Reproduced on S1, counter stable across each run:
```
S054 http_status 200 -> 404        : value=10 present=10 replayed=10 gate=1 guard=1
S054 fetched 2026-11-07 -> not-a-date : value=10 present=10 replayed=10 gate=1 guard=1
```
A 403/404/500 body registered with a consistent sha is admitted as evidence. The frozen r3 does not require a status, so this is a predicate gap; all 10 rows are `200`/ISO today, so tightening costs nothing. Amend r3 to "…and whose `http_status` is `2xx` and `fetched` matches `YYYY-MM-DD`", enforce in both, add a 404 control.

### F3 — MEDIUM (gate only) — the `locate` stage ignores the producer's exit code
`corpus/recheck-replay.py:195-200` runs `<root>/corpus/rendered-text-v1.py locate <body> <quote>` and returns the first `count=` on stdout; rc is discarded. Reproduction (S1; normaliser replaced by a printer that emits `RENDERED_TEXT_V1_LOCATE: count=1` then `sys.exit(2)`):
```
gate  -> "MATCH … S070 form=locate stated=1 replayed=1", "RECHECK_REPLAY: CLEAN (clocks=10 …)", rc 0
counter -> value=10 (r4 uses BASE's normaliser and is independent, so the claim is safe)
```
The real normaliser legitimately exits 1 for `count=0` (`locate <S070.body> 'no such quote anywhere'` → `count=0`, rc 1), so the guard must be `rc in (0,1)`, not `rc == 0`: `if res.returncode not in (0, 1): return None, "locate-rc%d" % res.returncode`. Also consider printing `normaliser_sha256=<sha>` in the CLEAN summary so r5 can bind the normaliser to the BASE digest — the gate runs the **measured tree's** copy (S0 evidence: a forged normaliser plus a restated N produced gate CLEAN while the counter correctly read `value=FAIL present=9`).

### F4 — LOW (latent) — the gate's registry check is weaker than r2
`corpus/recheck-replay.py:118` scans every line for `^ {0,3}\|\s*(S\d{3,})\s*\|` with no ``` fence exclusion, no cell-count check and no `status` check; `check_capture` (`:152`) accepts the URL anywhere on the row. r2 (`plans/round-56-c1.sh:239-241`) requires outside-fence, exactly 11 cells, `cells[7]=="mined"` and the URL as a token in cell 1. Demonstrated on S0 and unchanged in S1 by inspection:
- S054 row moved inside a ``` fence: gate `CLEAN`, counter `value=9 … bad=r2-registry:…`
- S054 URL moved from the source cell to the teaches cell: gate `CLEAN`, counter `value=9 … bad=r2-registry:…`
Latent today: `corpus/SOURCES.md` has 114 outside-fence rows, 0 inside-fence rows, each manifest id exactly once. Counter authoritative → no claim forgery. Fix: reuse the counter's `registry()` in the gate.

### F5 — LOW — the gate raises where it documents `SETUP` (exit 2)
`corpus/recheck-replay.py:63-72` (`path.read_text(encoding="utf-8")`), `:118`, `:130`, `:152-176` are unprotected. Appending `\xff\xfe` to `corpus/knowledge/trufflehog-verification-lifecycle.md` yields `UnicodeDecodeError: 'utf-8' codec can't decode byte 0xff in position 6441`, rc 1, no `RECHECK_REPLAY:` token — but the documented contract is exit 2 `RECHECK_REPLAY: SETUP <reason>`. The counter degrades safely (gate_clean 0), but wrappers that distinguish DRIFT (1) from SETUP (2) are misled. Same class: unreadable entry, directory named `*.md`, embedded NUL in `body_path`. Wrap in `try/except (OSError, UnicodeDecodeError, ValueError)` → `setup(...)`.

### F6 — LOW — control K1-F6's symlink fixture is dangling
`plans/round-56-controls.sh:101` moves the body to the tree root (`$SCR/f6/s055.body`) but links to `../../../s055.body` from `.ufo/waves/round-56/capture/`, which resolves to `.ufo/s055.body` — absent (`readlink -f` confirms). The control passes only because any symlink is refused; I verified the guard separately against a readable same-dir link and a symlinked directory component (both `BAD-CAPTURE … symlink:`). Fix the target to `../../../../s055.body` so the control proves refusal of a readable symlink.

### F7 — LOW — `mk_ref` ignores archive failure
`plans/round-56-controls.sh:21`, no `pipefail`, no rc check. My first run emitted four `tar: … Cannot stat` errors (the L1 had just moved `build-dispatch.json`, `build-spec.json`, `build.ready`, `build/swarm-registry.json` to `attempt1-build/`) and still produced a `CONTROLS:` line. Only wave receipts were missing then; a missing capture would silently make `K1-REF` read 0. Fix: `set -o pipefail` plus `|| { echo "mk_ref $1 failed" >&2; exit 2; }`, or build the reference from `git archive <candidate>` once the candidate is committed.

### F8 — LOW — `present()`'s right-bound is narrower than the predicate
Predicate: the `-> N` token is "right-bounded by a non-digit non-letter". Counter `plans/round-56-c1.sh:153`: `(?![0-9A-Za-z_.])` — `.` and `_` are non-digit non-letter, so the predicate accepts `-> 1.` / `-> 1_` and the counter does not. Probe: `-> 1.` in the S057 clock ⇒ `value=FAIL present=9 replayed=9 … bad=absent:trufflehog-verification-lifecycle.md:verification-caching`. Fail-closed, but a stated-clock formatting variant would read as absent. Fix: `(?![0-9A-Za-z])`.

### F9 — INFO — the pinned-digest scheme couples the gate to the counter commit
`GATE_SHA256_PIN` (`plans/round-56-c1.sh:79`) means **any** gate edit after the pin makes every reading 0. I observed the inconsistent instant (pin `637c8184…`, gate `a1b6270e…`) and the subsequent re-pin to `2e9dfde3…`. Operationally: F1/F3 change the gate, so they must land **together with** a re-pin of `GATE_SHA256_PIN`, in the same commit, before the freeze; and the counter/plan/controls kill rule (`git diff --quiet <predeclaration> <candidate> -- …`) then forbids touching the gate in the candidate.

### F10 — INFO — never run the controls while the lane is being edited
`bash` reads a script incrementally, so a controls run overlapping an edit mixes old and new expectations. My first run (started against an earlier `plans/round-56-controls.sh`) produced `CONTROLS: match=11 mismatch=5` including `expect=FAIL got=0` for F5/F5b/F5c, which are **not** the S1 expectations (`check K1-F5-printer-gate 0 f5`, `:78`). That reading is an artefact and is discarded; the S1 run is in §3. Freeze-time controls should run on a quiescent tree (or from a committed candidate) with the four hashes recorded before and after.

### F11 — Fixed in S1 (recorded so the epoch boundary is auditable)
S0 (`096251c9`) had four refusals that S1 closes; each was reproduced on S0 before the amendment:
- a failing gate ending `RECHECK_REPLAY: CLEANUP failed, population truncated` and exiting 3 read `value=10 present=10 replayed=10 gate=1 guard=1` (prefix match on `CLEAN`, exit code ignored). S1 pins the digest, requires `GATE_RC=0` and an exact `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`.
- deleting a clock line or its `-> N` left the gate `CLEAN (clocks=9 …)`; S1's r5 requires `clocks=10`. The gate alone still prints `CLEAN (clocks=9 …)` — its population is unbound — but the counter now reads `value=FAIL present=9`.
- an 8-column manifest row was silently skipped; S1 reads `bad=r2-manifest-malformed`.
- a symlinked entry or a symlinked `corpus/knowledge` was followed/skipped; S1 prints `UNSUPPORTED … reason=symlinked-entry` and refuses `symlinked-input`.

## 3. Pre-freeze checklist (ordered, minimal)

1. **F1** — widen both header checks (gate `:174`, counter `:262`), add `K1-F7b-header-v` and a non-zero-offset selftest case. *This is the only finding that forges `value=10` from a plausible capture mistake on S1.*
2. **F2** — amend r3 to require `http_status` 2xx and an ISO `fetched`; enforce in gate and counter; add the 404 control. Plan text changes, so it must be in the freeze commit.
3. **F3** — `locate` rc in `(0,1)`; print and bind `normaliser_sha256`.
4. **F8** — `(?![0-9A-Za-z])`.
5. **F6/F7** — control-fixture fixes; consider `git archive <candidate>` as the reference tree.
6. After 1–5: **re-pin `GATE_SHA256_PIN`** to the frozen gate digest, then run the controls on a quiescent tree and record `CONTROLS: match=N mismatch=0` with the four instrument hashes. The committed receipt `controls/controls-prefreeze.txt` (sha256 `3cc3e977eef7832f048a319bfd449cd0b6ecc575160b4905720285edabd65f42`) predates epoch-B and is stale.
7. Optional hardening: F4 (registry check), F5 (SETUP on malformed input).

## 4. Residual risk

- **The reading is not a currency check.** `value=10` says the 10 statements are true of the committed bodies. A stale body with a matching digest is indistinguishable; the named ceiling says so and is correctly stated in the plan. I did not perform the non-author live re-fetch.
- **A committed body with a consistent manifest row scores** (named ceiling); F1 and F2 are precisely the extra hygiene guards that do not bind.
- TOCTOU between `is_symlink()`/`is_file()` and `read_bytes()` in both instruments (local attacker only).
- The counter still runs the gate and `--selftest` without a subprocess deadline; a hung gate yields no reading rather than a false one.

## 5. Verification gaps

- `en_US.UTF-8` (the ambient `LANG`) is not installed on this host; counts were reproducible only under `C`/`C.UTF-8`. They agree with the stated N and all patterns are ASCII, so I record no locale defect, but the author's exact locale was not reproducible.
- I did not run the 10 live `curl` commands; live re-fetch is the wave's currency check, not the gate's.
- The S1 controls reading in §3 is from a run launched on the S1 bytes with a before/after hash guard; if the lane moved during it, the line is marked unstable in `R56ReviewGate.d/probe-output.txt`.
- `fetch-receipt.json` was read only through case-insensitive counts (`set-cookie`/`cookie`/`authorization` = 0/0/0); contents were not printed.

## Trailer

- Report: `.ufo/waves/round-56/build/R56ReviewGate.md`
- Evidence: `.ufo/waves/round-56/build/R56ReviewGate.d/repro.sh`, `.ufo/waves/round-56/build/R56ReviewGate.d/probe-output.txt`, `.ufo/waves/round-56/build/R56ReviewGate.d/hashes.txt`
- No production file was modified; no git/jj mutation in the lane, fleet or siblings; scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewGate` deleted after evidence copy.
- Tool installs: none.
