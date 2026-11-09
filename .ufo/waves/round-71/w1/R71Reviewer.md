Author: R71Reviewer (reviewer)
Seat dir: .ufo/waves/round-71/w1/R71Reviewer/
Scratch: /fast/scratch/hyaku/kagi-r71/R71Reviewer (removed before yield)

## 1. Predicate identity and conjunct coverage

**Predicate byte-identity: CONFIRMED (modulo line wrap).**
- `plans/round-71.md:28-30` (inside backticks, lines 28–30): `C1_PKI_ISSUER_TRIAL: value = number of tests T in {T6..T9} that DISCRIMINATE and whose ARTIFACT check passes, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and SOURCED = 1, else 0; target 4 (BASE 0).`
- `plans/round-71-c1.sh:8-10` (comment header lines 8–10): identical sentence (confirmed by Python string compare `identical: True`, modulo the leading `#` and continuation).
- No wording divergence found.

**Conjunct-to-code trace (counter `plans/round-71-c1.sh`):**
- **PINS (L57, L80-82):** `PIN_BAO=9c5f3628…b788` pinned, `sha256sum` checked against `$BAO_BIN` (`~/.local/bin/bao` by default), `pins=1` set only after, plus `/usr/bin/bao` and `/bin/bao` existence refusal (L83). `setup()` exits 2 = SETUP. SHA matches header claim (plan L5-6, counter L11-12).
- **Wrapper-script real run (L92-108):** `mkshim real 'exec "$REAL" "$@"'` — real wrapper *only* execs the pinned binary; SH6–SH9 each pass through to `"$REAL"` except for their one falsifier edit. Every run (real/none/sh6–sh9) executes via `run()` (L111-122) with `PATH=$W/bin/$1:/usr/bin:/bin` and `env -i`. So "bao is a script" cannot distinguish real from shim (r70 F2 class closed at this layer).
- **DISCRIMINATE incl. specificity (L124-128, L195-203):** `verdict()` counts exactly one `^TRIAL $id (HOLDS|BROKEN|ERROR)` line (0→NONE, >1→DUP). For each T∈{T6..T9}: `rv=HOLDS` (real), `sv=BROKEN` (own shim), and `spec=1` requires `HOLDS` under *each* of the other three shims (L198-199). Entry leg `entry_line()` (L180-186) requires a `## Measured (round 71` section with a line starting `- T<n> ` containing `OpenBao 2.7.2`. All four are conjuncts for `ok` (L200). Fail-closed detail recorded per-Test in `$detail`.
- **ARTIFACT T6 (L155-159):** Leaf+issuer files exist and are non-symlinks (`f`), `openssl verify -CAfile issuer leaf`, leaf enddate == issuer enddate, issuer lifetime `end−start < 36000s` (10h). Matches plan L40-41 and counter header L27-28.
- **ARTIFACT T7 (L160-167):** All five files present; leaf verifies against second issuer and *NOT* against default; issuer fingerprints differ; both CRLs verify (`crlok` = `openssl crl -CAfile` prints `verify OK`); leaf serial listed in second CRL and *not* in default CRL. Matches plan L41-42 and header L29-31.
- **ARTIFACT T8 (L168-173):** All five files present; both leaves verify against issuer; serials differ; `ocsp_is()` (L151-154) runs `openssl ocsp -respin ... -issuer -VAfile -cert -no_nonce` and requires `Response verify OK` and `<leafpath>: revoked` / `: good`. Matches plan L42-43 and header L32-34.
- **ARTIFACT T9 (L174-177):** All three files present; leaf verifies against issuer; CRL verifies against issuer and lists leaf serial. Matches plan L43-44 and header L35-36.
- **SETUP_OK (L134-136):** A fifth `run none` with `PATH=$W/bin/none:/usr/bin:/bin` (no bao shim) must exit 2 and print no `^TRIAL T[6-9] HOLDS`.
- **NOSECRET incl. evidence scan (L204-206):** Regex `PRIVATE KEY|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r71-[0-9a-f]{24}` applied to all `*.out`/`*.out.err` (L205) *and* recursively via `grep -rlaE` over every `ev-*` evidence file (L206). Header L38-40 confirms intentional closure of round-70 "no evidence scan" gap.
- **NOLEAK (L111-121, L207):** Per-run nonce `r71c1n…` in `R71_C1_NONCE`; after each run, `/proc/*/environ` scanned for exact `grep -qx`; `leak=1` → `noleak=0`. Header L41-42.
- **SOURCED incl. URL (L179-192):** Entry `source:` must name `S173` (ERE `^source:.*S173([^0-9]|$)`); `corpus/SOURCES.md` must have an `| S173 |` row (with 0-3 leading spaces) containing the exact URL `https://openbao.org/docs/secrets/pki/considerations/` (`$S173_URL`, L59) and its 9th `|`-field (status) must be exactly `mined`. Matches plan L44-47 and header L43-44.
- **Exit codes (L209-213):** `final = value` then forced to 0 if any of `setup_ok/nosecret/noleak/sourced/pins` ≠ 1. `value=4 → exit 0`, any other value `exit 1`, environment faults `exit 2` via `setup()` (L61) / `bao-pin-mismatch` / `tree-missing` / `archive` etc. Absent trial → single line `value=0 absent=1 pins=1` exit 1 (L87-89), matching BASE expectation.

No conjunct in the predicate sentence lacks a code implementation; no code limb exceeds the predicate.

## 2. Commit order

- `git merge-base --is-ancestor 1199295573a4eb1791e965178c8643213312943d 39e76bc700cf05e7772711f703bdbc3c6e7ac469` → rc 0. **Freeze is an ancestor of candidate.**
- Freeze commit `1199295` ("round-71: freeze C1 (depth, PKI issuer/revocation channels) — plan, counter, nine executed prefreeze controls"): `git show --stat` lists 44 files — `plans/round-71.md`, `plans/round-71-c1.sh`, `plans/round-71-controls.sh`, `capture/S170.*`, `capture/S173.*`, `claims.json`, controls fixtures under `.ufo/waves/round-71/controls/{p1,f1..f7}/` and receipts. **It adds no `corpus/openbao-pki-issuer-trial.sh`, no `corpus/knowledge/openbao-pki-issuer-revocation-channels.md`, and no S173 registry row** — verified by:
  - `git cat-file -e 1199295:corpus/openbao-pki-issuer-trial.sh` → fatal, rc 128 (absent at freeze).
  - `git cat-file -e 1199295:corpus/knowledge/openbao-pki-issuer-revocation-channels.md` → fatal, rc 128 (absent at freeze).
  - `git show 1199295:corpus/SOURCES.md | grep -c S173` → 0 (also 0 at BASE; S173 first appears in candidate).
- Candidate `39e76bc`: 8 files including the trial, entry, SOURCES S173 row, source-fetches S173, stamps, captures, and the L1 probe. No freeze file (plan/counter/controls) is modified in the candidate (only `claims.json` 1-line change counted in stat vs freeze tree).
- BASE `e0e9603` is a single-file commit (round-70 spot-check lesson) — does not contain the trial or S173.

## 3. Independent re-runs (frozen counter, this seat)

Outputs+rc saved to `.ufo/waves/round-71/w1/R71Reviewer/`:

| rev/tree | command output | rc | vs expected |
|---|---|---|---|
| candidate `39e76bc…` | `C1_PKI_ISSUER_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2 T6:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1 T7:… T8:… T9:…` | 0 | identical to `.ufo/waves/round-71/final/c1-candidate.txt` (`value=4` rc 0, all `art=1`, all `spec=1`) |
| BASE `e0e9603…` | `C1_PKI_ISSUER_TRIAL: value=0 absent=1 pins=1` | 1 | matches F0 receipt exactly |
| F2 tree (`controls/f2`) | `value=0 discriminating=0 … T6:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=0,ok=0` ×4 | 1 | matches `receipts/f2.txt` exactly (spec=1, shim=BROKEN, art=0) |
| F7 tree (`controls/f7`) | `value=3 discriminating=3 … T7:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=0,ok=0` (T6/T8/T9 ok=1) | 1 | matches `receipts/f7.txt` exactly (T7 art=0) |

`c1-candidate-rerun.txt` (= `.ufo/waves/round-71/final/c1-candidate.txt` line + rc), `c1-base-rerun.txt`, `c1-f2-rerun.txt`, `c1-f7-rerun.txt` in the seat dir. No deviation.

## 4. Controls vs runner header

Runner header (`plans/round-71-controls.sh:8-12`) expected verdicts (written before first run per README):
- F0 `value=0 absent=1 rc1` → receipt `f0-base.txt`: matches.
- P1 `value=4 rc0` → `p1.txt`: `value=4 … all_ok=1` rc 0, matches (all `art=1`).
- F1 `value=0 discriminating=0 rc1` → `f1.txt`: shim=HOLDS ×4, art=0, matches.
- F2 `value=0 discriminating=0 rc1 (spec=1 shim=BROKEN art=0)` → `f2.txt`: `T#:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=0,ok=0` ×4, matches. **Re-run at §3 reproduces this.**
- F3 `value=0 discriminating=0 rc1` → `f3.txt`: `shim=HOLDS, art=1` ×4, matches.
- F4 `value=0 sourced=0 rc1` → `f4.txt`: `sourced=0, entry=0, shim=BROKEN, art=1`, matches.
- F5 `value=0 noleak=0 rc1` → `f5.txt`: `discriminating=4, noleak=0`, 5 servers reaped and named, matches.
- F6 `value=0 nosecret=0 rc1` → `f6.txt`: `discriminating=4, nosecret=0`, matches.
- F7 `value=3 rc1 (T7 art=0)` → `f7.txt`: `value=3 discriminating=3`, T7 `art=0`, matches. **Re-run at §3 reproduces this.**

Counter sha256 in `receipts/counter.sha256` = `4d77f19c…504ab8117b` matches `sha256sum plans/round-71-c1.sh` at the working tree and matches the freeze (candidate did not modify plans/). **All nine receipts match the runner's pre-declared expectations; F2 and F7 were independently re-run by this seat and reproduce.**

## 5. Trial bypass audit (task 5 + named ceiling)

Read `corpus/openbao-pki-issuer-trial.sh` lines 1–208 and diffed `controls/p1/corpus/openbao-pki-issuer-trial.sh` against the candidate — **byte-identical** (the plan's claim that candidate bytes = P1 bytes holds; `diff` empty). F7 vs P1 differs only at line 163 (CRL filenames swapped), as described.

- **No wrapper-bytes read:** No `cat/command -v/which/$0/BASH_SOURCE//proc` against the `bao` at PATH. The only absolute reads are `command -v bao` presence checks (L68) and `bao version | awk` (L71). `env -i` PATH is fixed by the counter; the trial never introspects the wrapper. This is the F2 class — **the landed trial does NOT do what F2 does** (contrast `controls/f2/...:8` `x=$(cat "$b")`).
- **No local CA/CRL/OCSP minting:** `openssl` invocations are: `openssl version` (L71), `openssl crl -in -noout -text` for serial grep (L124, and validity parse via `openssl crl -in -noout` L130), `openssl x509 -enddate` (L126), and `openssl ocsp -no_nonce -issuer -VAfile -cert -url … -respout` (L178). **No `openssl req/ca/x509 -req/genpkey/ocsp -index` minting path; grep for `openssl (ca|req|x509 -req|…)` → NONE.** Evidence copying is `cp` of files already produced by `bao` JSON outputs (`jget … certificate` → `.pem`, `crl_of` via `bao read pki/issuer/<ref>/crl` → pem, OCSP DER via `openssl ocsp -respout` against the live dev-server URL). Private-key material (`private_key` JSON field → `$S/t9.key`) is passed to `bao` by `@file` only (L196) and removed (L203); it is not placed in evidence (header L35-38, `ev` calls list only `.pem`/`.der`).
- **Every state-changing operation goes through `bao`:** `q()` (L112) wraps `bao "$@"`; explicit `bao read/write` for root gen (`pki/root/generate/internal`, L135, usable issue, CRL fetch, status). The trial launches a real `bao server -dev` under `setpriv --pdeathsig KILL` (L93) with the port verified via `ss … pid=$SP` (L98), kills it in `cleanup EXIT` (L83-84). No direct HTTP to OpenBao bypassing the CLI except the OCSP GET via `openssl ocsp -url $BAO_ADDR/v1/pki/ocsp` — which is the documented client mechanism for T8, not a state mutation.
- **Residual ceiling (as named in `plans/round-71.md:81-85` and counter header L49-51):** a same-uid trial *could* in principle read `$(command -v bao)` bytes and mint look-alike artifacts in a future revision. This inspection finds **no such read or mint in the landed bytes**. The claim "executes through bao" is a reviewed property, not a counted one — the counter does not (and by its own header cannot) enforce it.
- **QUALITY.md fit:** The entry names falsifiers (§Falsifiers 1-4), a `recheck:` trigger (on-release, line 5 of the entry header), what it does not establish (§Does not establish incl. Vault, permit, intermediates, the S173 default-CRL case, metering, that any relying party fetches correctly, OCSP nonces/GET/unknown-serial), and separate custody (OCSP vs CRL channels, `no_store` vs serial). QA1/QA3/QA4 present in form; QA5 (no credential) holds in the files inspected (no token-shaped strings or private key in entry or trial outputs). No quality-bar defect found in this lane's new round-71 material.

## Residual risk / verification gaps

- Text-level "no mint" is a partial result: I verified absence of minting *verbs* and of wrapper reads in the landed bytes; a steganographic mint (e.g. via embedded `python3 -c` cryptography) would be visible as a `python3` interpolation — the only Python present parses JSON (`json.load`) and extracts fields; no `cryptography` import, ASN.1 construction, or PEM assembly occurs. That bars the natural class, not an arbitrary adversarial encoding.
- NOLEAK depends on a per-run nonce scan of `/proc/*/environ`; a process that scrubs its own environment before the scan would be invisible — but that would also require the trial to know the env var name, and the trial's env is only `HOME/PATH/TMPDIR/LANG/R71_C1_NONCE` (counter-controlled). Not a finding against the frozen freeze; a named limit.
- I did not re-run all six F1/F3/F4/F5/F6 receipts live (time budget — 2–3 min each). The six are structurally uniform with P1/F2/F7, whose verdict patterns were reproduced, and their receipts' detail strings are self-consistent (e.g. F5's reaped-PID list is non-empty). This gap is noted, not a disagreement.

Tooling: no installs; pacman paused per seat spec and not used (official-channel rule in `~/.omp/agent/RULES.md` read; none needed). No bao server left running by this seat (one transient `bao server -dev` seen at 23:52 was already exited by the time `/proc/3501430` was probed; final `ps` shows no `bao server`).

FINDING neutral RV-1 predicate sentence is byte-identical between plan §C1 and counter header
FINDING neutral RV-2 every predicate conjunct has a matching code limb with correct exit codes
FINDING neutral RV-3 freeze is an ancestor of candidate and adds no trial entry or S173 row
FINDING neutral RV-4 independent re-runs of candidate (=4 rc0), BASE (=0 rc1), F2 and F7 reproduce frozen receipts exactly
FINDING neutral RV-5 landed trial reads no wrapper bytes and mints no CA/CRL/OCSP locally; all mechanics execute through bao
SEAT-STATUS: complete reviewed predicate, ancestry, re-runs, controls, and trial bypass audit; no falsifying finding
