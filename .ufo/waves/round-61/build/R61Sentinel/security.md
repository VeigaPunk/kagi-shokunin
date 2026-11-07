# R61Sentinel — security review (round 61, kagi)

Seat: sentinel (attack). Read-only: no production file changed by this seat; every
mutated copy lives under `/fast/scratch/hyaku/kagi-r61/R61Sentinel/` and is deleted
before yield. Values are never printed: every scan below reports shapes, counts and
`file:line`, never a matched string.

Measured tree: lane `kagi-shokunin` at BASE `c940f51` plus the wave's uncommitted
corrections as they landed. The wave was live during this review; each row records the
bytes it measured.

Instrument digests at this reading:

| file | sha256 (first 16) |
|---|---|
| `corpus/openbao-seal-trial.sh` | `a9c80c7a3eea2aed` (posture run on `6f4b43d0…`, stable) |
| `plans/round-61-c1.sh` | `e6c853236181d8a5` |
| `plans/round-61-c1-check.py` | `fe4491d4c027953d` (later `d525ee28…`; exec surface unchanged) |
| `plans/round-61-c2.sh` | `def7b737d0333b0a` |
| `plans/round-61-controls.sh` | `70c977cf396b940b` |

Method: a shape-based scanner (10 patterns, redacted context) over the round delta and
every receipt; `strace -f` of the trial and of both counters; `ss -ltn` before/after
each trial run; a recording listener for the ambient-env leg; host-side journal,
pacman-log and mtime checks. Probe material that contained generated key shares was
deleted immediately after measurement and never copied out of scratch.

## Checks

| # | check | command | observed | verdict |
|---|---|---|---|---|
| 1 | no secret-shaped material in committed artifacts or receipts | `python3 scan-detail.py <delta>` where delta = `git diff --name-only c940f51..HEAD` + `git diff --name-only` + `git ls-files --others` + `find .ufo/waves/round-61 -type f` (71 files) | 0 hits for `hvs.`/`hvb.` tokens, `s.` 26-char tokens, 44-char base64 shares, UUID nonces, 26-char OTPs, `Cookie`/`Set-Cookie` values, `Authorization: Bearer`, PEM private-key blocks. 450 `hex64` hits, every one a sha256 digest (source digests, the bao pin, the trial's `trial=<sha>`). Capture bodies S125–S127: 0 cookie/authorization shapes; the scout's `cookie-hygiene.txt` states 0 matches. | pass |
| 2 | trial servers bind 127.0.0.1 only, run under `setpriv --pdeathsig KILL`, throwaway storage in scratch, no listener left | `bash posture.sh corpus/openbao-seal-trial.sh <scratch>` (ss -ltn before/after, `pgrep -af 'bao server'`, `strace -f -e openat,connect,bind`), plus source read | Source: 2 listener blocks both `127.0.0.1`, 0 `0.0.0.0`/`[::]` listener strings, `tls_disable = 1`, `storage "raft"` (path under `$D`) and `storage "inmem"`, `setpriv --pdeathsig KILL` at `corpus/openbao-seal-trial.sh:243`, `umask 077` at `:84`. strace: 20 `bind()` calls, all loopback (`127.0.0.1`, `::1`, `::ffff:127.0.0.1`), 0 non-loopback connects. Listener delta after the run: empty; no `bao` process from this seat's runs remained. Write-mode opens outside scratch: only `/dev/null` and `/dev/tty`. Functional state on these bytes: `BROKEN holds=4` (T4 `dec=0`, `token/lookup-self` reads 404) — a correctness defect for the trial seat, not a posture defect. | pass (posture) |
| 3 | no artifact writes outside the lane repo and scratch; no `/tmp` citable evidence; scratch deleted | `grep -rl '/tmp/' .ufo/waves/round-61 plans/round-61-c2.sh plans/round-61-controls.sh corpus/openbao-seal-trial.sh`; `ls /tmp \| grep -iE 'r61\|round-61\|kagi-r61'`; `find <instrument scratch>` | 0 `/tmp/` references in any round-61 artifact. 13 `/tmp` entries match the name pattern: 11 are tabi's (2026-11-03), 1 is kasegi's, and **1 is kagi round-61** — `/tmp/r61-trace.txt` (3001 B, 17:06:39), a `bash -x` trace of `plans/round-61-controls.sh`, no secret shape, cited nowhere (finding F4). Instruments remove their per-run scratch (verified: counter/selftest/checker legs leave only empty parents); the C1 driver leaves `run-<ts>-<pid>/` (finding F5). | pass with F4, F5 |
| 4 | no host mutation: no sysctl, service restart, package manager, or write to /boot, /etc, /usr, /var, another lane, the fleet repo | `grep -c '2026-11-07T' /var/log/pacman.log`; `journalctl --since '2026-11-07 16:45:00' \| grep -ciE 'sudo\|pkexec\|doas'`; `journalctl … \| grep 'systemd\[1\]'`; `stat /etc/sysctl.d`; `find /etc /boot /usr/bin -newermt '2026-11-07 16:45:00' -type f`; `git -C <fleet> status --porcelain` | 0 pacman transactions today; 0 sudo/pkexec/doas; 5 `systemd[1]` lines, all the `snapper-timeline` timer at 17:00:00 (scheduled, not attributable); `/etc/sysctl.d` mtime 2026-10-20; exactly 1 file newer than round start — `/etc/anydesk/service.conf` (root:root 0644, rewritten by the running `anydesk --service`; no round artifact references anydesk or `/etc`, and no privilege event exists to attribute it to the round). Fleet repo: 4 pre-existing orchestrator status lines; the only round-61 fleet commit is the dispatch prompt. | pass |
| 5 | the trial refuses/ignores ambient `BAO_ADDR`/`VAULT_ADDR`/`BAO_TOKEN`/`VAULT_TOKEN` and never reads a real `~/.vault-token` | run the trial with all six ambient vars exported and `BAO_ADDR`/`VAULT_ADDR` pointing at a recording listener on `127.0.0.1:18999`; `strace -f -e openat` for `.vault-token`; source read | Recorder log: **0 hits** — no request reached the ambient address; the trial's output was identical to the clean run. strace: exactly one `.vault-token` `openat`, on `$D/home/.vault-token` (the isolated scratch HOME) → `ENOENT`; the host's real `~/.vault-token` exists and is never opened. Source scrubs every `BAO_*`/`VAULT_*` at `corpus/openbao-seal-trial.sh:1104` and sets `HOME="$D/home"` at `:1106`. Hazard demonstrated for the record: with the caller's HOME, `bao token lookup` sends the real token as `X-Vault-Token` to an ambient `BAO_ADDR` (recorder `token_header=yes`); with an isolated HOME it does not (`token_header=no`). | pass |
| 6 | counters execute no arbitrary lane scripts beyond the named `--selftest` invocations, and do not follow symlinks out of the tree | `strace -f -s 300 -e execve` on `plans/round-61-c2.sh --tree <fixture>` and on `python3 -I -B plans/round-61-c1-check.py --root <lane> --repo <lane> --no-challenge`; symlink fixtures for the statement file, the results file and the I2 script | C2 counter: the only lane script exec'd is `bash <tree>/corpus/openbao-seal-trial.sh --work …` (9 legs), plus coreutils/python/git; a symlinked trial is refused (`[ -L "$TRIAL" ]` → `(absent)` rc 1). C1 checker: execs only `git`, `python3`, and `bash <its own scratch copy>/plans/round-60-c2.sh --selftest` (which in turn runs the round-60 approle trial's fixture-driven `--selftest`); a symlinked `corpus/lessons/round-60.md` and a symlinked `.ufo/waves/round-60/w1-results.json` each read `C1_ROUTED: SETUP … is a symlink (refused)` rc 2; a symlinked `plans/round-60-c2.sh` is not executed and I2 reads 0; the challenge copy uses `copytree(symlinks=False)`. | pass |

## Findings

Ordered by severity. Each is a defect in the round's artifacts, not in the frozen
predicate; none of the frozen predicates, targets, POPs or kill rules is amended here.

### F1 — HIGH — the C2 counter's secret scan cannot match a real unseal share

`plans/round-61-c2.sh:133` (`SECRET_PCRE`). The share alternative is
`(?![0-9a-f]{43,}([^0-9a-f]|$))(?![-_]{43})[A-Za-z0-9_-]{43,}`: its character class
excludes `+`, `/` and `=`. Measured on this host with the pinned binary
(`bao v2.7.2`, sha256 `9c5f3628…`): `bao operator init -key-shares=5
-key-threshold=3` emits 5 shares of **44 chars, standard base64, unpadded**, and
**4 of 5 contained `+` or `/`** (`lengths={44:5}`, `shares_ending_pad=0/5`). Probe of
the counter's own PCRE (values masked): a 44-char share carrying `+`/`/` → **not
caught**; an alphanumeric-only 44-char run → caught; a sha256 → correctly not caught.

Consequence: K3 is the backstop that must catch a share printed into a captured stream
or left in a work-dir file. A trial regression that printed a share would still read
`secret=1`, and the counter's own `--selftest` cannot see it because its share fixture
(`plans/round-61-c2.sh:161`) is alphanumeric-only. The trial itself does not print
shares (verified: `TRIAL T1 HOLDS … nopersist=1`, and no share shape in any captured
output), so this is a detection gap, not an observed leak.

Smallest remediation: widen the share class to `[A-Za-z0-9+/=_-]{43,}` (keeping the
sha256 exclusion and the `(?![-_]{43})` hyphen guard), and add a selftest fixture whose
share carries `+` and `/`.

### F2 — MEDIUM — the same scan misses lowercase and JSON-shaped OTP/nonce values

`plans/round-61-c2.sh:133`. The OTP alternative is case-sensitive (`\bOTP`) and
requires `=`, `:` or whitespace immediately after the label; the nonce alternative
allows an optional quote but not a JSON key. Probe of the counter's own PCRE
(values masked): `otp=<26 chars>` → **not caught**; `{"otp":"<26 chars>"}` → **not
caught**; `{"nonce":"<uuid>"}` → **not caught**; `OTP: <26 chars>` and
`nonce=<uuid>` → caught. T4's nonce and OTP are exactly the values this round
introduces, and a JSON dump of the `-init` response is the natural way they would leak.

Smallest remediation: `(?i)\botp["']?\s*[:=]\s*["']?[A-Za-z0-9+/=_-]{20,}` and the
analogous nonce form, plus one JSON-shaped selftest fixture.

### F3 — MEDIUM (accepted exposure) — the generate-root OTP and encoded token travel on argv

`corpus/openbao-seal-trial.sh:304` — `bao operator generate-root -decode="$2"
-otp="$1"`. The header names this as the documented 2.7.2 contract, and the trial
never prints either value. While the call runs, both are readable from
`/proc/<pid>/cmdline` by any process of the same user. Impact is bounded: the server is
throwaway, unsealed only for the run, and the decoded token dies with it; the trial
already keeps unseal shares off argv by driving `/v1/sys/unseal` with a body file
(`api_unseal`). No change required if the lane declares it a ceiling; if argv-free
custody is wanted, drive `/v1/sys/generate-root/update` with the OTP in a body file the
same way.

### F4 — LOW — a round-61 artifact was written under `/tmp`

`/tmp/r61-trace.txt` (3001 B, mtime 2026-11-07 17:06:39) is a `bash -x` trace of
`plans/round-61-controls.sh` (first line `+ set -u -o pipefail`,
`+++ dirname plans/round-61-controls.sh`). It carries no secret shape (one sha256, the
bao pin) and is cited nowhere in the wave, but it is a round artifact outside the lane
repo and scratch, and `/tmp` is never citable evidence. Smallest remediation: delete
it; redirect any future trace under `${HYAKU_SCRATCH}`.

### F5 — LOW — the C1 driver leaves its materialised tree behind

`plans/round-61-c1.sh:35` (`WORK="$SCRATCH_ROOT/$TAG"`) has no `EXIT` trap and no
`rm -rf`, so every run leaves `run-<ts>-<pid>/` (the materialised tree plus
`checker.out`/`checker.err`) under `${HYAKU_SCRATCH}/kagi-r61/R61ExecCounterC1/`. The
same is true of `plans/round-60-c1.sh` (inherited, not a round-61 regression). Not a
frozen-predicate violation; scratch hygiene. Smallest remediation:
`trap 'rm -rf -- "$WORK"' EXIT` after `WORK` is set, or state the retention as
deliberate evidence.

### F6 — LOW — the C1 checker's leg environment is not scrubbed

`plans/round-61-c1-check.py:238` (`_isolated_env`) copies `os.environ` and sets
`TMPDIR`/`HYAKU_SCRATCH` but inherits `HOME` and any ambient `BAO_*`/`VAULT_*`. The I2
leg it wraps runs only `plans/round-60-c2.sh --selftest` (fixture-driven: no `bao`, no
network), so no credential is reachable on the current tree; the isolation is simply
weaker than the C2 counter's `env -i` (`plans/round-61-c2.sh:210`). Smallest
remediation: scrub `BAO_*`/`VAULT_*` and set `HOME` to the leg scratch, as the C2
counter does.

## Positive controls that held

- The trial's T1 custody assertion (`nopersist=1`) held in every real run: no file
  under the raft storage path carried a share.
- The trial's real-run receipts are honest: both record `T4 BROKEN … dec=0` and
  `rc=1`; no receipt claims a hold the bytes do not produce.
- The C2 counter refuses a symlinked trial and writes nothing inside the measured tree
  (fixture tree hash unchanged before/after a full run).
- The C1 checker refuses symlinked statements, results and the I2 script, and its
  challenge copy materialises symlinks rather than following them.
- No secret value was found in any committed artifact, receipt, capture body or
  captured stream at this reading.

SEAT-STATUS: complete
