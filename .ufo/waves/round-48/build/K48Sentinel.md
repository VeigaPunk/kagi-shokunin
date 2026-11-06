# K48Sentinel — secret-hygiene and host-safety sentinel (round 48, attempt 1)

- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`
- BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c`; predeclaration `164f0ea5`; amendment A1 `52991e5d`
- Measured revision for every run below: `52991e5da64cbacaa724b28b407cf5765fd21b41` (`git rev-parse HEAD`), working tree clean for tracked files (`git status --porcelain --untracked-files=no` → no output, rc 0)
- Tools: `sops 3.13.3`, `age-keygen v1.3.2`, `age v1.3.2`, `gitleaks 8.30.1`, `strace` (system), `curl`, `gh`
- Scratch: `/fast/scratch/hyaku/kagi-r48/K48Sentinel/` (100 MB, removed at exit). Receipts copied to `.ufo/waves/round-48/build/K48Sentinel/` (15 files, 132 KiB).
- Axes: A1 provenance, A2 secret hygiene, A3 file-access evidence, A4 report calibration.

Verdict: **no real secret, no real key, no vault contact, no host mutation.** Two hygiene defects found
(S-03 env-var leak in the reference fixture — already remediated in the candidate bytes; S-08 token-shaped
material in archived raw page bodies). Everything else is PASS evidence plus two calibrated false positives.

---

## S-01 — PASS — provenance re-derived independently, three channels each

Channel 1 (release checksum file), channel 2 (GitHub asset digest API), channel 3 (byte identity after
download/extract). Binaries were **not** replaced or touched.

```
$ curl -fsSL -o sops-v3.13.3.checksums.txt .../getsops/sops/releases/download/v3.13.3/sops-v3.13.3.checksums.txt   # rc 0
$ curl -fsSL -o sops-v3.13.3.linux.amd64  .../getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64     # rc 0
$ curl -fsSL -o age-v1.3.2-linux-amd64.tar.gz .../FiloSottile/age/releases/download/v1.3.2/age-v1.3.2-linux-amd64.tar.gz  # rc 0
$ grep 'sops-v3.13.3.linux.amd64$' sops-v3.13.3.checksums.txt
e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b  sops-v3.13.3.linux.amd64
$ sha256sum -c <(…)        → sops-v3.13.3.linux.amd64: OK                       # rc 0
$ sha256sum sops-v3.13.3.linux.amd64 → e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b
$ sha256sum ~/.local/bin/sops        → e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b
$ cmp sops-v3.13.3.linux.amd64 ~/.local/bin/sops → IDENTICAL
$ sha256sum age-v1.3.2-linux-amd64.tar.gz → cbe24006683f8eb669266162894b9a522a1af52f2665fbc63a4bb032ed26ac10
$ sha256sum age-x/age/age-keygen → 0a0009db842259d6717f7eeb30acb6b90d2a2eb924c6acd0a0db0ca1f1537899
$ sha256sum ~/.local/bin/age-keygen → 0a0009db842259d6717f7eeb30acb6b90d2a2eb924c6acd0a0db0ca1f1537899
$ cmp age-x/age/age-keygen ~/.local/bin/age-keygen → IDENTICAL
$ sha256sum age-x/age/age → eb7dd1b518f0a307c99cd97782623c5321da049154b04acd2d98d21aa7bc9b2c   (matches receipt tool-install.txt)
$ cmp age-x/age/age ~/.local/bin/age → IDENTICAL
$ gh api …/sops/releases/tags/v3.13.3 --jq '.assets[]|select(.name=="sops-v3.13.3.linux.amd64")|.digest'
sha256:e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b            # rc 0
$ gh api …/age/releases/tags/v1.3.2 --jq '.assets[]|select(.name=="age-v1.3.2-linux-amd64.tar.gz")|.digest'
sha256:cbe24006683f8eb669266162894b9a522a1af52f2665fbc63a4bb032ed26ac10            # rc 0
```

Both counter pins (`plans/round-48-c1.sh:22-23`) equal the official digests. Note the residual gap the L1
already recorded: the `.proof` sigsum transparency proof was downloaded but **not verified** (no sigsum
verifier installed) — my re-derivation does not close it, it only confirms the two published digests and the
on-disk bytes agree. Receipts: `K48Sentinel/01-sops-checksums.txt`, `02-digests.txt`.

## S-02 — INFO (calibration) — `generic-api-key` fires on *public* digests; do not use it as a kill rule

```
$ gitleaks detect --no-git -s <copies of plans/round-48*> -v     # rc 1
Finding:  PIN_AGEKEYGEN=0a0009db842259d6717f7eeb30acb6b90d2a2eb924c6acd0a0db0ca1f1537899
RuleID:   generic-api-key   Entropy: 3.835272
File:     plans/round-48-c1.sh   Line: 26
```

That is the pinned **sha256 of a public binary**, not a secret. Same class of hit appears in my own receipt
`K48Sentinel/02-digests.txt` (lines 9-10, the two age digests) **and in this report itself**
(`build/K48Sentinel.md:52`, the `PIN_AGEKEYGEN=…` line quoted above) — i.e. any artifact that records these
pins trips this rule. Measured: `gitleaks -s build/K48Sentinel → 2 hits (rc 1)` and
`gitleaks -s build/K48Sentinel.md → 1 hit (rc 1)`, all `generic-api-key` on public digests, while the
key-shaped check over the same paths stays rc 1 (no key). This corroborates amendment A1's choice of a
**key-shaped ERE** rather than a generic entropy gate, and it means a "0 gitleaks findings" requirement over
`plans/` is unattainable while the pins are recorded. No action: the frozen counter must not be edited.

## S-03 — LOW (MED if run outside the counter) — caller `SOPS_*` env leaks into the reference fixture, and two vars move the verdict

`controls/fixtures/ref-sops-age-trial.sh` unsets the documented `SOPS_AGE_*` / PGP / KMS / VAULT set but not
`SOPS_CONFIG` or `SOPS_ENABLE_LOCAL_KEYSERVICE`. Measured on the reference fixture at `52991e5`:

```
none                                 -> SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2   (rc 0)
SOPS_CONFIG=<external creation_rules> -> SOPS_AGE_TRIAL: BROKEN holds=2 broken=3 error=0 sops=3.13.3 age-keygen=v1.3.2 (rc 1)
    T1 BROKEN updatekeys-rc=0 added-recipient-rc=1 values-unchanged=yes mac-unchanged=yes
    T4 BROKEN rules-edit-only-rc=1 file-unchanged=yes updatekeys-rc=0 after-rc=1
    T5 BROKEN shamir_threshold=absent a-only-rc=1 b-only-rc=1 both-rc=1
SOPS_ENABLE_LOCAL_KEYSERVICE=false    -> SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=5 sops=3.13.3 age-keygen=v1.3.2 (rc 2)
SOPS_AGE_KEY_CMD=<script>             -> HOLDS 5        (existing unset works)
SOPS_AGE_KEY_FILE=<decoy>             -> HOLDS 5        (existing unset works)
SOPS_KEYSERVICE / SOPS_DECRYPTION_ORDER / SOPS_GPG_EXEC / SOPS_EDITOR -> HOLDS 5 each
```

Exploit path: a shell that exports `SOPS_CONFIG` (a legitimate sops setting) makes `sops` read an external
`creation_rules` and ignore the fixture's own `./.sops.yaml`; T1/T4/T5 then read BROKEN although the real
binary behaves correctly, and `SOPS_ENABLE_LOCAL_KEYSERVICE=false` turns all five into ERROR → SETUP.
Impact on the measured value: **none** — `plans/round-48-c1.sh:91` runs the trial under
`env -i HOME=… PATH=… TMPDIR=… LANG=C`, so the counter cannot inherit either variable. Impact on a human or
harness invoking `corpus/sops-age-trial.sh` directly: a false BROKEN/SETUP. Smallest remediation: a
`SOPS_`-prefix sweep instead of a name list.

Status: the candidate bytes already fix this —
`.ufo/waves/round-48/build/K48ExecTrial/sops-age-trial.sh` sha256
`09f304ecaaeba7a43626e1de433bba003daf38bd410a4a15d3e9334cb276da37` (236 lines) has
`sops_vars=$(compgen -v | grep -E '^SOPS_' || true)` + explicit `SOPS_CONFIG` in the list (lines 98-104).
I re-measured **its** bytes (copied to scratch, `--work` under scratch):

```
clean env                            -> SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2  leftovers 0
SOPS_CONFIG=<external creation_rules> -> SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2  leftovers 0
SOPS_ENABLE_LOCAL_KEYSERVICE=false    -> SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2  leftovers 0
```

The executor (`K48ExecTrial`) confirmed the sweep is deliberate, re-measured the final bytes independently
(`SOPS_CONFIG` → 5/5 rc 0, `SOPS_ENABLE_LOCAL_KEYSERVICE=false` → 5/5 rc 0, receipts in
`build/K48ExecTrial/receipts.txt`) — two seats, same result — and the L1
should re-check after the candidate is committed (the sha256 above is the revision I audited).
Receipts: `09-env-attribution.txt`, `06-…SOPS_CONFIG.out`, `07-…hostile-env.out`, `10-candidate-audit.txt`.

## S-04 — PASS — no key-shaped material anywhere in the scanned set, and the null is informative

```
$ grep -rnE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' plans/round-48-c1.sh plans/round-48-c2.sh \
      plans/round-48-controls.sh plans/round-48.md .ufo/waves/round-48/      → no output, rc 1
$ grep -rnE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' .ufo/waves/round-48/build/        → no output, rc 1
$ grep -rnE --binary-files=without-match 'AGE-SECRET-KEY-1[0-9A-Z]{58}' . --exclude-dir=.git → no output, rc 1
$ gitleaks detect --no-git -s .ufo/waves/round-48 -v                         → 548,785 bytes, rc 1 (the 2 hits are S-08)
$ gitleaks detect --no-git -s <fixture dir>                                  → no leaks, rc 0 (reference trial clean)
$ grep -rnoE '<op-ref scheme>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' .ufo/waves/round-48/ → no output, rc 1
```

Detector calibration (otherwise "0 findings" would be vacuous): a synthetic canary of the exact shape
(prefix + 58 `Q`) in scratch trips **both** detectors —
`gitleaks … RuleID: age-secret-key, rc 1` and the ERE → rc 0. So the null above is a real null, not a dead
detector. The canary was never written into any wave artifact (this report deliberately does not contain a
full-shaped string; `grep -rnE 'AGE-SECRET-KEY-1[0-9A-Z]{58}'` over this seat's output dir → rc 1).
Bare-literal occurrences are prose only: the amended rule's own ERE text in `plans/*`, the fixture's
`*AGE-SECRET-KEY*` shape guard, and the lesson scripts that build the string from two pieces
(`printf 'AGE-SECRET-KEY-1'; cat "$F/tail"`) — none is a key, none matches the ERE.
Receipts: `11-detector-calibration.txt`, `12-gitleaks-plans.txt`, `13-gitleaks-wave.txt`,
`15-gitleaks-fixture.txt` (reference trial alone: `gitleaks … no leaks found, rc 0`; key-shaped grep rc 1).

## S-05 — PASS — file-access evidence: the trial never opens the caller's key paths

`strace -f -e trace=openat` over the reference trial, caller `HOME` = a scratch decoy home containing a
throwaway `~/.config/sops/age/keys.txt` (189 B, generated in scratch, never printed):

```
$ env -i HOME=<decoy> PATH=~/.local/bin:/usr/bin:/bin TMPDIR=<work> LANG=C \
    strace -f -e trace=openat -o strace-openat.txt bash ref-sops-age-trial.sh --work <work>
trial rc 0 → SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2
openat lines: 1615
opens under /home/vgpnk: 21   — and only two distinct kinds:
     20  "/home/vgpnk/.local/bin/sops"                          O_RDONLY|O_CLOEXEC = 3
      1  "…/.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh" O_RDONLY = 3
opens under the decoy HOME: 0
keys.txt opens by path (all ENOENT, all inside the trial's own scratch HOME):
     21  "<work>/sops-age-trial.bf6Fx6/home/.config/sops/age/keys.txt"  = -1 ENOENT
/etc/sops probes: 20 × "/etc/sops/audit.yaml" = -1 ENOENT ; /etc/sops ABSENT on this host (metadata check)
$ test -e /home/vgpnk/.config/sops → ABSENT ; /home/vgpnk/.ssh → EXISTS (never opened: 0 opens of .ssh)
```

Zero opens of `.ssh`, `~/.config`, any `op`/`1Password` socket, or any vault path. A second run repeated the
whole trial with a **hostile caller env** (`SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY`, `SOPS_AGE_RECIPIENTS`,
`SOPS_CONFIG`, `SOPS_AGE_KEY_CMD` all pointing at scratch decoys): `decoyhome` opens 0, `decoy-config.yaml`
honoured only because it is the deliberately-unfixed var (S-03), and the decoy `SOPS_AGE_KEY_CMD` script was
**never exec'd** (`execve` count 0, its marker file was not created) — the existing unset works.
Write-class opens during run 1 are `/dev/null`, `/dev/tty` (ENXIO) and 5 × relative `f.yaml`; the `chdir`
trace shows every relative write lands in the trial's own `W` or `W/t1..t5` (`chdir` targets: only the trial
scratch tree). No write outside scratch. Receipts: `03-strace-openat.txt`, `04-strace-summary.txt`,
`08-ref-trial-SOPS_AGE_KEY_FILE.out`.

## S-06 — PASS — cleanup and process hygiene

```
work, work2 … work8 (9 runs, incl. the hostile-env and candidate runs): leftovers 0 each
$ test -e <work>/sops-age-trial.bf6Fx6 → REMOVED
$ pgrep -a 'sops|age-keygen' → no output
```

The candidate additionally hardens this: `chmod 700 "$W"`, `trap 'rm -rf -- "$W"' EXIT`, and
`trap '… SETUP … reason=interrupted; exit 2' INT HUP TERM`. Plaintext never touches a persistent path (the
only plaintext is the synthetic `k1:/k2:` fixture inside `W`), and `grep -c 'synthetic-trial-value'` over
stdout+stderr of both runs → 0.

## S-07 — PASS — fail-closed on hostile/hostile-ish conditions

```
$ env -i … TMPDIR=/nonexistent-k48 bash ref-sops-age-trial.sh
SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=work-parent-missing          rc 2
$ env -i … PATH=<dir with age-keygen only>:/usr/bin:/bin bash ref-sops-age-trial.sh --work …
SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=sops-not-on-PATH             rc 2
```

Both print no HOLDS line (the counter's `SETUP_OK` premise holds). No host mutation attempted: no sysctl,
no service/user/package change, no pacman invocation, no write to `~/.local/bin` or any PATH directory.

## S-08 — LOW — archived raw page bodies carry token-shaped fields (a token was copied into a wave artifact)

`gitleaks` over the live wave dir returns two hits, both in fetched raw bodies archived by the sources seat:

```
RuleID: generic-api-key   File: .ufo/waves/round-48/build/K48ExecSources/S103.body   Line: 261   (entropy 3.751)
RuleID: generic-api-key   File: .ufo/waves/round-48/build/K48ExecSources/S104.body   Line: 258   (entropy 3.852)
```

Characterised without printing values: each body carries **one `authenticity_token` form value (51 chars)**
and a **64-lowercase-hex `auth_hydro_click_hmac` value that repeats 4 times in the file** (the field name
occurs once, inside the GitHub React embedded-data blob), on a **logged-out** page
(`"logged_in":false`, `"user_id":null`). No `_gh_sess`, no `Set-Cookie` header was archived, and no account
is linked — so this is not usable material and grants no access. It is still exactly the "token-shaped
string in an artifact" class the lane's own hygiene rules (and `corpus/transcript-scan.sh`'s HIT class) are
written to reject: the values would trip any later gate that greps artifacts for material shapes.

Smallest remediation: archive `kagi-shokunin/.ufo/waves/round-48/build/K48ExecSources/*.body` as
**quote + `sha256` of the body** instead of raw bytes, or scrub the two fields before saving
(`s/"authenticity_token" value="[^"]*"/…/` and `s/"auth_hydro_click_hmac":"[0-9a-f]{64}"/…/`). Until then the
L1 should record the finding rather than let a later round's scan read it as a live secret.
Receipt: `14-archived-body-token-census.txt`.

## S-09 — INFO — bare op-ref scheme literal in prose, zero ref-shaped paths

```
$ grep -rnoE '<op-ref scheme>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' .ufo/waves/round-48/ → no output, rc 1
$ grep -rno '…' <build-spec.json|build-dispatch.json|K48ExecSources.md|K48CriticCeiling.md|K48ScribeEntry.md>
  → 1 hit each, all the bare scheme inside policy prose ("never write an <op-ref> reference path …")
```

Same class as the round-45 lesson S-04 (bare scheme, not a ref path: no vault/item/field segments). The
wave's own artifacts are clean of real refs; seed files under `corpus/` also carry only placeholders
(`corpus/op-ref-probe.sh` uses `Kagi12NoVault` fake refs by design). No action.

## S-10 — PASS — binary identity on disk (no wrapper, no shadowing)

```
-rwxr-xr-x 1 vgpnk vgpnk  52121762  ~/.local/bin/sops      (ELF 64-bit LSB, x86-64, statically linked, Go build ID)
-rwxr-xr-x 1 vgpnk vgpnk   4051278  ~/.local/bin/age-keygen
-rwxr-xr-x 1 vgpnk vgpnk   6977014  ~/.local/bin/age
$ type -a sops age-keygen → sops is /home/vgpnk/.local/bin/sops ; age-keygen is /home/vgpnk/.local/bin/age-keygen
```

Regular files, mode 755, no symlink indirection, exactly one `sops` on `PATH`, and `/usr/bin/sops` absent
(the counter's `sops-in-/usr/bin` guard is not tripped).

---

## Bounds observed (nothing crossed)

No real key was read (`~/.config/sops` does not exist here; `~/.ssh` was checked for existence by metadata
only and never opened — verified by strace). No vault, no `op`, no 1Password, no account, no form post, no
remote write. Every identity used was generated in scratch and deleted; no private key, plaintext, token or
cookie value was printed in this report or copied into a receipt. No `op`-ref path was written. No binary in
`~/.local/bin` was created, replaced or removed. No `git`/`jj` mutation; read-only `git rev-parse`,
`git status`, `git archive` only. No `pacman`. No host sysctl/service/user/package/kernel change.

## What the L1 must re-run at landing (not a pass I can claim now)

The seats were still writing at `2026-11-06T20:23:20Z`; my scans are of that instant.

1. `grep -rnE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' .ufo/waves/round-48/ corpus/ --exclude-dir=.git` → must stay rc 1.
2. `gitleaks detect --no-git -s .ufo/waves/round-48 -v` → expect exactly the two `K48ExecSources/*.body` hits
   (S-08) and nothing in `build/*.md`, `build/*/receipts*`, or the new `corpus/sops-age-trial.sh`.
3. Re-measure the candidate trial under `SOPS_CONFIG=<file>` **after** it is committed — the sha256 I audited
   (`09f304ec…`) may no longer be the landed bytes.
4. Decide S-08: scrub the two body fields or record them as accepted archived-page bytes.

## Lesson-draft material

- **A public digest is not a secret.** `generic-api-key` fires on the pinned `PIN_AGEKEYGEN` sha256 and on
  any receipt that quotes the pins (S-02) — a round that gates on gitleaks generically gates on its own
  pins. The amended key-shaped ERE is the correct instrument; this round supplies the calibration.
- **Env isolation must be structural, not a name list.** `SOPS_CONFIG` and `SOPS_ENABLE_LOCAL_KEYSERVICE`
  both move the verdict of a fixture that already unsets eleven `SOPS_*` names (S-03). A `SOPS_`-prefix
  sweep is one line and closes the class; the counter's `env -i` is the second, independent defence.
- **Archive fetched pages as quote + digest, not raw bytes.** A logged-out `github.com` HTML page carries a
  51-char `authenticity_token` and a 64-hex HMAC (S-08); harmless, and still material-shaped in an artifact.
