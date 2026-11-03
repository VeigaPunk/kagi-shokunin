# ExecProbe — C2 counter, BASE pin + byte probe on the installed op

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`.
Clone `/fast/scratch/hyaku/kagi-r32/ExecProbe/base` (`git clone --shared`, `checkout --detach 32c35fe`);
`git rev-parse --show-toplevel` printed that exact path, `HEAD` = BASE, `status --porcelain` = 0 lines.
Measurement-only seat: **no lane file changed**, no probe edit, no predicate change. No vault contact, no
`op` call other than `--version` (once) and the single `--dotenv-bytes` run; `~/.config/the-janitor` and
`op.env` never read. Receipts: `.ufo/waves/round-32/build/probe/`.

## Measurements

| # | what | measured | receipt |
|---|---|---|---|
| 1 | `op --version` | `2.41.1` exit 0, hex `322e34312e310a`, `/usr/bin/op` (no symlink), `OP_REF_OP_BIN` unset | `probe/op-version.txt` |
| 2 | §11 counter at BASE | **`0`** — `2.41.1` absent; §11 (heading 310, body 311–376) names only `` op `2.40.0` `` and `` op `2.41.0` `` | `probe/base-counter.txt` |
| 3 | `op-ref-probe.sh --dotenv-bytes` | **exit 0**, last line `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`; all six ids PASS | `probe/base-probe.txt` |
| 4 | red witness 1 (stub `op`: `--version`→`2.41.9`, else exit 1) | `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)` **exit 1** — non-CLEAN | `probe/red-witness-version-stub.txt` |
| 5 | red witness 2 (stub `op`: exit 0, prints nothing) | `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)` **exit 1** — non-CLEAN | `probe/red-witness-silent-stub.txt` |
| 6 | `--selftest` | `OP_REF_SELFTEST: PASS (36 cases)` **exit 0** | `probe/selftest.txt` |
| 7 | op subcommands invoked | `run` only — 14 invocation sites (10 `op_exec run`, 4 `op_run` wrapper), 0 account/vault/item/signin/inject/read | `probe/op-subcommands.txt` |

## Verdict

**C2 at BASE is half-green and honestly reported.** The probe side is already satisfied on the installed
CLI: op **2.41.1** reproduces the six newline/quote byte classes measured on 2.41.0, exit 0, CLEAN 6/6 —
no DRIFT. The pin side is not: counter `0`, because §11 carries no `` op `2.41.1` ``. Per the frozen
predicate C2 is therefore **not admitted at BASE**; the remaining work is exactly the append-only
`### 11.1` naming `` op `2.41.1` `` plus the S072 row — a documentation pin, not a behaviour change.
The probe needs no change; a DRIFT finding would have blocked C2, and there is none.

Red witnesses confirm the probe cannot be talked into CLEAN: both stubs give DRIFT, exit 1. Note witness 1
proves a limit rather than a check — the probe **never calls `op --version`** (grep: `--version` absent
from the script; `OP_REF_OP_BIN` only selects the binary). The version pin is the separate awk counter, so
the two halves of C2 are independent, and a stub that merely prints a version cannot make the byte arm
pass. A stub that *cannot run* fails all six cases; a stub that *succeeds silently* returns rc 0 with
empty bytes and fails all six. Neither is CLEAN.

## Findings

**F1 — integration constraint for the scribe (actionable).** The counter's awk resets on `^## `, not on
`###`. So `### 11.1` is counted **only if it lands before line 377** (`## Erratum (round 22 — comparator
history)`), i.e. inside the current §11 body 311–376. Appending it after the Erratum heading leaves the
counter at 0 and C2 unadmitted while looking correct in the file. §11 currently has **no** `###`
subsections and no `### 11.1`, so the slot is free.

**F2 — predicate observation (not edited).** The counter is `grep -c "op \`$V\`"`: the three dots are
unescaped regex wildcards, so `` op `2x41x1` `` would also match, and `grep -c` counts matching *lines*
(two mentions on one line count once; one mention on two lines counts twice). Both are benign for a
`≥ 1` target and the target cannot be met by accident from the current text (2.40.0/2.41.0 differ in the
third field), but the pin is a substring test, not an equality test. Reported, not changed.

**F3 — isolation of the single real run (structural, verified in code).** `--dotenv-bytes` writes its own
`$WORK/plain.env` per case and passes only that; `op_exec` runs it under
`env -i PATH=/usr/bin:/bin HOME=$WORK/home XDG_{CONFIG,CACHE,DATA}_HOME=$WORK/… OP_BIOMETRIC_UNLOCK_ENABLED=false
OP_CACHE=false timeout 10`; `guard_op_file` refuses any reference token or non-regular path before exec;
`--fixture` is refused in byte mode (`POLICY`). The observed exit 0 without a session is the evidence the
arm needs no account. `env -i` does not hide the binary because `OP_BIN` is resolved to an absolute path
first — which is also why the PATH-prefixed stubs took effect.

**F4 — bound restated (matches the plan).** Six newline/quote classes only. This says nothing about
ref-resolved values, `op item` reads, masking of plain values, or the absent `the-janitor` handler; the
handler's absence is expected on this host and was not treated as a defect.

**F5 — subcommand audit.** Every invocation is `op run --env-file=… -- <command>`; the distinct
subcommand set is `{run}` (14 sites in the script; `--dotenv-bytes` executes only the line-542 site, six
times, once per byte case). No `account`, `vault`, `item`, `signin`, `inject`, `read`, `whoami`,
`document`, or `connect` anywhere in the script. `run` executes `printenv`/`true`/`/bin/sh -c printf`
against generated plain values; no `op://` token exists in any byte-mode fixture.

## Commands run (all from the clone at BASE)

| command | exit |
|---|---|
| `git -C $S/base rev-parse --show-toplevel` → `/fast/scratch/hyaku/kagi-r32/ExecProbe/base` | 0 |
| `op --version` | 0 |
| `bash corpus/op-ref-probe.sh --dotenv-bytes` | 0 |
| `awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md \| grep -c "op \`$V\`"` → `0` | 1 (grep no-match; the counter value is 0) |
| `PATH=$S/stubs:$PATH bash corpus/op-ref-probe.sh --dotenv-bytes` | 1 |
| `PATH=$S/stubs-silent:$PATH bash corpus/op-ref-probe.sh --dotenv-bytes` | 1 |
| `bash corpus/op-ref-probe.sh --selftest` | 0 |

`TMPDIR=/fast/scratch/hyaku/kagi-r32/ExecProbe/tmp` on every run; probe scratch cleaned by its own trap
(0 entries left). No installs or upgrades, so no tooling row. Scratch deleted before yielding.

## Files written

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ExecProbe.md` (this report)
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/op-version.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/base-probe.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/base-counter.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/red-witness-version-stub.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/red-witness-silent-stub.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/selftest.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/probe/op-subcommands.txt`

## Risks

- The pin is only satisfied if `### 11.1` lands inside the §11 body (F1). A post-Erratum append is the
  single realistic way this round reads green in review and 0 on the counter.
- A future op that changes dotenv newline handling fires DRIFT by design; the receipt's bound is six
  classes, not the whole contract.
