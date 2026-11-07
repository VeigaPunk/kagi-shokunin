# R61Critic — falsification receipt (round 61, kagi)

Seat: R61Critic (critic). Read-only: no lane file was written by this seat except this
receipt and the wave report. Measured tree: lane working tree at HEAD
`8595018164f7421864254c6c5ca762b8f201e8be` (claim BASE `c940f51689d702f1786989d56ad4663833c1452e`)
plus the round-61 instruments as they stood at measurement:

| instrument | sha256 at measurement |
|---|---|
| `corpus/openbao-seal-trial.sh` | `a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535` |
| `plans/round-61-c2.sh` | `def7b737d0333b0a3002c6ac766d09799aecc0bea09142b6f3eb6e39c72ac4b4` |
| `plans/round-61-c1-check.py` | `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812` |
| `plans/round-61-controls.sh` | `8d100756cfb0863ea97955865a92da939fa5f6a961d5b503ea0fd46164e55b97` |
| `plans/round-60-c2.sh` (I2 fix) | `135fc46f1a39036d0129a317d82caa79ff3ccdab6ee2562d3d6892f70b87fe95` |

Scratch used for every fixture: `/fast/scratch/hyaku/kagi-r61/R61Critic/` (removed before
yield). No `/tmp` citable evidence; no host path written.

**Drift note.** The counter was edited again after these readings (`plans/round-61-c2.sh`
now `c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6`); every C2
counter reading below is for the pinned `def7b737…` bytes. The trial
(`a3bc8825…`), the C1 checker (`d525ee28…`) and the battery (`8d100756…`) were unchanged
between the readings and this receipt.

## Method

Two independent implementations of the C1 conditions were used: the lane's checker
(`plans/round-61-c1-check.py`) and a second reader written by this seat
(`ref61.py`, scratch) that derives every number from the measured tree. The C2 attacks
used (a) a stub `bao` that implements the CLI/HTTP surface the trial calls, (b) a
do-nothing trial that prints the verdict contract, and (c) mechanic-removal flags on the
stub (`STUB_DUP_SHARES`, `STUB_REKEY_CODE`, `STUB_SEALED_CODE`, `STUB_NO_STORAGE`,
`STUB_INIT_SHARES`). The trial's own syntax and its real run were measured directly.

---

## C1 — attack 1: the do-nothing control (BASE)

Command:

```
python3 -I -B plans/round-61-c1-check.py --root <BASE tree> \
  --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

Observed:

```
c1: i1 FAIL no 'supersedes R37' line after the routed R37 row
c1: i2 FAIL selftest[rc=1 cases=None no-PASS-line] registry[...] mutation[mutated rc=2 finding=no]
c1: i3 FAIL no '## Amendment A7' heading
c1: i4 FAIL no 'supersedes the round-60 quality-trend sentence' line
c1: i5 FAIL no 'supersedes the round-60 LOG wave line' line after it
c1: i6 FAIL no 'supersedes the round-60 stale-lane paragraph' line
c1: i7 FAIL no 'supersedes the round-60 attack-share arithmetic' line
C1_ROUTED: value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0
```

Verdict: **the do-nothing tree cannot reach the target** — every item is unresolved at
BASE, value=7. The BASE full run (with the challenge) reads
`C1_ROUTED: value=FAIL population=7 ... guard=0`, as the plan says for a tree where the
challenge cannot fire. No item is vacuous at BASE.

Candidate reading (same checker, full challenge):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1
```

Checker selftest: `C1_CHECK_SELFTEST: PASS (52 cases)` rc 0.
Records-only tree (BASE + the six text corrections with correct numbers + the SKILL.md
row, no `--selftest` in `plans/round-60-c2.sh`): `C1_ROUTED: value=1 population=7 ...
i2=0 ... guard=1` — six of the seven items are satisfiable by appended text alone; only
I2 requires code. That is the plan's declared "last occurrence wins" convention, not a
defect, but it fixes the claim's strength: the calibration gain is six appended
corrections plus one behavioural fix.

## C1 — attack 2: a records-only tree with invented numbers

Fixture: a copy of the candidate tree with one number changed. Command per variant:

```
python3 -I -B plans/round-61-c1-check.py --root <variant> \
  --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

| variant | change | observed | verdict |
|---|---|---|---|
| `i1count` | `results=16` → `results=15` | `value=2 ... i1=0 ...` | caught |
| `i1bytes` | `output=3824` → `output=9999` | `value=2 ... i1=0 ...` | caught |
| `i5del` | `insertions=1 deletions=1` → `deletions=2` | `value=2 ... i5=0 ...` | caught (also the guard's challenge delta) |
| `i7frac` | `3/16` → `2/16` | `value=2 ... i7=0 ...` | caught |
| `i7pct` | `18.75` → `19` | `value=2 ... i7=0 ...` | caught |
| `i6allinv` | three in-range stamps replaced by invented ones | `value=2 ... i6=0 ...` | caught |
| `i1pos` | I1 correction moved before the R37 row | `value=2 ... i1=0 ...` | caught (position enforced) |
| `i3pos` | A7 moved before A6 | `value=2 ... i3=0 ...` | caught (position enforced) |

The checker's derivations are real: it recomputes R=16, B=3824 from
`.ufo/waves/round-60/w1-results.json`, the numstat from `git diff --numstat 14a6c07d
818d2a82 -- LOG.md`, the timestamp set from `git log --format='%ci' a677c78e..818d2a82`,
and the 3/4/16 role mix from the results' `agent` fields. It rejects every invented number
above.

## C1 — attack 3: the three named invented-number classes and two polarity classes

The assignment named three: a wrong result count, a wrong byte length, and a timestamp
that exists in the range but on a different commit. The first two are caught (table
above). The third is **not** caught, because the frozen condition is set membership:

| variant | change | observed | verdict |
|---|---|---|---|
| `i6diff` | `15:06:58` → `16:33:16` (a real stamp on another commit) | `value=1 ... i6=1 ...` | **passes** — named ceiling: the item requires only that three stamps occur in the range, not that each is attributed to the commit it describes |
| `i6retain` | the honest line **plus** the superseded wrong stamp `15:09:28` | `value=1 ... i6=1 ...` | **passes** — the D6 defect (the wrong 15:09:28) can remain in the correction of record |
| `i3neg` | `A3 item 2 is withdrawn` → `A3 item 2 is not withdrawn` | `value=1 ... i3=1 ...` | **passes** — the word `withdrawn` is present; the checker cannot distinguish withdrawal from refusal |
| `i4neg` | `the round introduced three new record defects` → `... did not introduce ...` | `value=1 ... i4=1 ...` | **passes** — same polarity class |

Impacted axis: calibration. The four passing variants are statements the item's prose
does not license ("states the item is withdrawn", "states `three` new record defects").
The named ceiling says an item is "a structural read, not a semantic proof that the
corrected text is true"; a polarity flip is a structural difference, not a truth
question, so the ceiling does not cover it.

Smallest safe correction (checker-side, no frozen-predicate change):
- I3: require the affirmative phrase `A3 item 2 is withdrawn` (or `is withdrawn` with no
  `not ` immediately before it); reject a correction block carrying `not withdrawn`.
- I4: require `introduced three new record defects` and reject `did not introduce`.
- I6: require every `-03:00` timestamp in the correction line to be either a driver line
  (`15:03:17` launch / `16:34:37` complete) or a member of the derived commit set; that
  rejects `15:09:28` and `i6diff` while keeping the honest line (which names the driver
  complete line, a legitimate driver stamp).

## C1 — attack 4: the guard

- Challenge: the candidate full run reads `guard=1`; the records-only full run reads
  `value=1 ... guard=1` (the `deletions=2` copy reads value+1). The challenge fires.
- Printer stub: the checker's selftest includes the stub case and passes
  (`C1_CHECK_SELFTEST: PASS (52 cases)`). The stub prints `value=0` and the challenge
  expects `value+1`, so it fails the leg. **Calibration note**: round 60's R40 already
  routed this clause as non-discriminating (any always-0 printer fails a `value+1`
  expectation); round 61's frozen GUARD repeats it verbatim. It is not vacuous in the
  "always passes" sense, but it discriminates nothing a plausible stub would not already
  fail. Report only; the predicate is frozen.

## C2 — attack 1: a stub `bao` on PATH

A stub `bao` (scratch `stub2/`, ~350 lines) implements `version`, `server` (a local HTTP
thread), `operator init/unseal/seal/generate-root/rekey`, and the endpoints the trial
calls. It performs no Shamir split, starts no real server, writes no raft data.

Command:

```
PATH=<stub2>:$PATH KAGI_STUB_STATE=<scratch> \
  bash corpus/openbao-seal-trial.sh --work <scratch>
```

Observed (stub baseline, against the current trial sha256 `a3bc8825…`):

```
TRIAL T1 HOLDS shares=1 status=1 nopersist=1
TRIAL T2 HOLDS progress=1/3 same-share-again=progress=1/3 progress=2/3 sealed=false t=3 n=5
TRIAL T3 HOLDS seal=1 auth503=1 status200=1
TRIAL T4 HOLDS req3=1 prog=1 dec=1 wrong=1 tlen=26 ls=200 ss=200 wl=26 wls=200 wdrc=0
TRIAL T5 HOLDS raft405=1 mem405=1
OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2
```

Verdict: **the trial reads HOLDS 5/5 with no real OpenBao server** — the stub starts a
local HTTP thread, performs no Shamir split, writes no raft data, and answers every
assertion from a JSON state file. The trial resolves `bao` through PATH and checks only
`bao version` (`grep -c sha256 corpus/openbao-seal-trial.sh` ⇒ 0), never the binary's
sha256 or a server-side artifact. The counter's pin + ops witness is the only defence for
the counter-mediated claim; the trial's own direct-run receipts are not
provenance-checked.

Smallest safe correction: the trial should pin the binary it resolves (the round-57
`PIN_BAO` sha256, already used by `plans/round-60-c2.sh`) or require a server-log line
carrying the binary's build hash; the counter's ops witness already covers the
counter-mediated path.

## C2 — attack 2: value=5 without a real server

Before the counter's ops/stubctl upgrade, a 20-line trial that printed the verdict
contract (five HOLDS lines, the summary, the five shim flips, `SEAL_SELFTEST: PASS
(cases=8)`, the no-bao SETUP) and called no `bao` read:

```
C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 \
  (real=1 real2=1 none=1 secret=1 sh1=BHHHH ... trial=627f622d... cases=8) rc 0
```

After the upgrade (counter sha256 `def7b737...`), the same fixture reads:

```
C2_SEAL_TRIAL: value=0 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 \
  (real=1 real2=1 none=1 ops=0 stubctl=1 secret=1 sh1=BHHHH ... trial=627f622d... cases=8)
```

Verdict: **fixed**. The `ops=0` leg (a logging exec shim first on PATH, requiring
`server`, `operator init`, `operator unseal`, `operator seal`, `operator generate-root`,
`operator rekey`) and the `stubctl=1` control now reject a text-only trial. The
counter-mediated claim is no longer vacuous on this axis.

## C2 — attack 3: T5's 405 versus a permission error

Stub variant `STUB_REKEY_CODE=403` returns HTTP 403 `permission denied` instead of 405
`unsupported operation`. Observed:

```
TRIAL T5 BROKEN raft405=0 mem405=0
```

The trial's `rekey_refused` requires `Code: 405` and a named `unsupported operation`
(`named_refusal`), so a 403 is rejected. **T5 discriminates 405 from a permission
error.** On the real binary, both backends return 405 (measured: raft and inmem,
`Code: 405 ... * unsupported operation`, rc 2), so the frozen expectation holds on both
storage backends.

## C2 — attack 4: T3's 503 versus a permission error

Stub variant `STUB_SEALED_CODE=403` returns 403 for an authenticated request while
sealed. Observed:

```
TRIAL T3 BROKEN seal=1 auth503=0 status200=1
```

The trial uses `/v1/sys/mounts` (not `sys/seal-status`) for the 503 leg and requires the
literal code 503; `sys/seal-status` without a token must be 200. **T3 discriminates 503
from 403**, and it does not make the mistake of asking `sys/seal-status` for a 503 (the
real binary returns 200 there even with a token).

## C2 — attack 5: T2's duplicate-share refusal

Stub variant `STUB_DUP_SHARES=1` counts a repeated share. Observed:

```
TRIAL T2 BROKEN progress=1/3 same-share-again=progress=2/3 progress=0/3 sealed=false t=3 n=5
```

The trial requires the same share twice to leave progress at 1/3. **T2 discriminates the
duplicate-share mechanic.**

## C2 — attack 6: T1's custody leg is vacuous on an empty storage path

Stub variant `STUB_NO_STORAGE=1` starts a server that writes **no file** under the raft
storage path. Observed:

```
TRIAL T1 HOLDS shares=1 status=1 nopersist=1
```

The custody leg is `m=$(grep -rlF -f shares.pat "$D/raft" | wc -l); [ "$m" = 0 ] &&
nopersist=1`. With no files, the grep finds nothing and the leg passes. **T1's custody
claim is vacuous when the server writes nothing** — the mechanic (the server storing the
encrypted root key in raft) can be absent and the test still passes. The share/threshold
legs do discriminate (`STUB_INIT_SHARES=3` ⇒ `T1 BROKEN shares=0 status=0 ... n=3`).

Smallest safe correction: require at least one file under `$D/raft` before the negative
grep (`[ -n "$(find "$D/raft" -type f -print -quit)" ] || nopersist=0`), so the sweep
runs against a server that actually wrote its state.

## C2 — attack 7: T4's OTP leg

The trial's current T4 (after the executor's fixes) HOLDS on the real binary:
`T4 HOLDS req3=1 prog=1 dec=1 wrong=1 tlen=26 ls=200 ss=200 wl=26 wls=403 wdrc=0`. It
authenticates the right-OTP token (200 on `token/lookup-self` and `sys/seal-status`) and
requires the wrong-OTP token to be a different 26-character string that gets 403. A
decode that ignored the OTP would return the same token and fail `wrong`. **T4
discriminates the OTP.** (Two earlier defects were measured and are now fixed: the
deprecated `/v1/sys/generate-root` endpoint returned 403 on 2.7.2 — the working endpoint
is `PUT /v1/sys/generate-root-token/update` with the root token, confirmed by a proxy
capture of the CLI; and the `-format=json` decode output is `{"token": "..."}`, which
must be parsed, not read raw.)

## C2 — attack 8: secret transport (argv)

The trial's `unseal_share` passes the unseal share as an **argv** positional:
`bao operator unseal -format=json "$1" </dev/null`. The trial discloses this ("the 2.7.2
CLI refuses piped unseal material ... ephemeral argv, same user, never printed"), and the
refusal is real (measured: `printf '%s' "$share" | bao operator unseal -format=json` ⇒
"file descriptor 0 is not a terminal", rc 1). But the counter's ops witness logs the
**full argv** to `$SCR/log/<leg>.ops`, and the counter's secret scan excludes `*.ops`
(`find ... ! -name '*.ops'`). Measured: 8 ops-log lines carry a 43+ character base64
share. The trial's claim "never printed or captured" is false for the counter-mediated
run.

Smallest safe correction: the ops shim should log only the subcommand words it needs
(`server`, `operator init`, ...), not the share positional, or redact 43+ character
base64 runs before writing; the scan should then include `*.ops`. Impacted axis:
calibration (the trial's stated custody property) and operability (a same-user
`/proc/<pid>/cmdline` window during every unseal).

## Vacuity table — the five C2 tests

For each test, the condition that would still pass if the mechanic were absent, measured
with the mechanic-removal stub variants:

| test | mechanic | condition that passes without the mechanic | measured |
|---|---|---|---|
| T1 | init splits the key; the server never persists the shares | the custody sweep passes on an **empty** storage path (`grep` finds no file, so no file contains a share); only the share/threshold legs fail when the split is wrong | `STUB_NO_STORAGE=1` ⇒ T1 **HOLDS** (vacuous); `STUB_INIT_SHARES=3` ⇒ T1 BROKEN |
| T2 | unseal counts distinct shares | none found: a server that counts a repeated share fails `dup`; a server that reports progress without state would fail `p1/p2/p3` | `STUB_DUP_SHARES=1` ⇒ T2 BROKEN |
| T3 | sealed state refuses work but answers status | none found: the leg requires the literal 503 on `/v1/sys/mounts` and 200 on `sys/seal-status` without a token; a 403 fails | `STUB_SEALED_CODE=403` ⇒ T3 BROKEN |
| T4 | the OTP is the second factor | a decode that ignores the OTP would return the same token; `wrong` requires a different 26-char token that gets 403. A stub that returns a different token but authenticates it would pass `wrong` only if the server accepts it — the real server does not | real run `wrong=1`; stub bookkeeping `wls=200` shows the leg depends on the server's token table, which the trial does not control |
| T5 | this build refuses rekey | a trial that checks only `rc != 0` would pass on a 403 or a typo; this trial requires `Code: 405` + `unsupported operation` | `STUB_REKEY_CODE=403` ⇒ T5 BROKEN |

## Instrument defects measured (not claims)

The pre-freeze battery at the first landing (17:13 receipt) read `CONTROLS: match=4
mismatch=13`; the current bytes (`plans/round-61-controls.sh` sha256 `8d100756…`) read
**`CONTROLS: match=17 mismatch=0` rc 0**, and the receipt
`.ufo/waves/round-61/controls/controls-prefreeze.txt` carries it. The defects below were
real at the first landing and are recorded because the claim's reading depends on the
battery's bytes; four were fixed by the executor, one is a residual design issue.

1. **`body` exit (fixed)**: `body > "$OUT"` then `[ "$K" -gt 0 ] && exit 1; exit 0`
   terminated the script before `cat "$OUT"`, so the battery printed nothing and never
   installed the receipt. Measured: empty stdout, rc 1. The current bytes run `( body ) >
   "$OUT"`.
2. **`ctrl_c2_sh` local expansion (fixed)**: `local n=$1 id="C2-SH$n" …` expanded `$n`
   before the `local` assigned it; under `set -u` this was `n: unbound variable` and
   killed the battery before C2-SH1..5, C2-STUB and C2-FIXTURE-TRUTH. Measured in a
   scratch clone: `line 523: n: unbound variable`, `CONTROLS: match=1 mismatch=14`.
3. **C2-STUB stub ordering (fixed)**: `gen_stub_trial` put the `command -v bao` guard
   before the `--selftest` branch, so the stub trial failed the selftest leg for an
   unrelated reason and `C2-STUB` passed vacuously. With the branch moved first, the same
   control read `observed=value=5` against the pre-upgrade counter.
4. **C1-F1..F6 expectations (fixed)**: the 17:13 receipt's expectations were shifted
   (`value=1 i1=1 i2=0 …` vs the observed `value=2 i1=0 i2=0 …`) because the synthesized
   fixed tree left I2 unresolved; C1-F7 read `mutation-failed(rc3)` (the checker-defined
   needle was not found in the checker bytes). The current battery reads 17/17 match.
5. **C2-FIXTURE-TRUTH expectation (residual)**: the counter overrides the caller's PATH
   with the pinned binary (`mkshim` execs `$BAO_BIN`), so a fake caller PATH cannot
   change the reading; the control expects `value=0`, but a working trial under the
   pinned binary reads `value=5`. The control currently matches only because the
   counter's real legs are pinned; it tests a path the counter does not use. The
   counter's actual defence is the pin + ops witness, which `C2-STUB` and the `ops` leg
   cover.

## Trade check (diffs, not summaries)

- `git diff SCORECARD.md` ⇒ 21 added lines (the round-61 pre-move table); no line matches
  `9 → [0-8]`; all six axes remain 9.
- `git diff SKILL.md` ⇒ one row changed: the `plans/round-60-c2.sh` selftest cell goes
  from `none of its own — it runs the trial's --selftest as a conjunct` to
  `bash plans/round-60-c2.sh --selftest ⇒ C2_SELFTEST: PASS (cases=36)`, with the red
  witness described. **Upgrade, not degradation.**
- `git diff plans/round-60-c2.sh` ⇒ +251/−11; the deletions are the old argument-parsing
  `case` block moved/rewritten, not a removed check; the added block is the
  fixture-driven `--selftest`. No counter leg was weakened.
- `git diff LOG.md corpus/lessons/round-60.md plans/round-60.md` ⇒ additions only
  (`1 0`, `15 0`, `14 0`); the superseded statements stand unrewritten.
- `git diff corpus/SOURCES.md corpus/source-fetches.tsv corpus/README.md` ⇒ additions
  only; no row's tier or clock changed.
- No selftest case was removed from any instrument; no gate was weakened to make a claim
  pass. The C1 checker's I3/I4/I6 weaknesses and the C2 trial's argv transport are
  defects, not trade-downs.

## Verdicts

- **C1**: the do-nothing control holds (BASE value=7), the candidate reads value=0
  guard=1, the checker's selftest is green, and the invented numbers named in the
  assignment (wrong result count, wrong byte length, wrong fraction/percentage) are
  caught. Three weaknesses remain: I3 and I4 accept a negated correction, and I6 accepts
  a correction that retains the superseded wrong timestamp. These are calibration
  defects in the checker's implementation of the frozen conditions; the smallest safe
  corrections are above.
- **C2**: the trial HOLDS 5/5 on the real binary and the counter reads value=5 with the
  ops witness and the stub control. The counter-mediated claim is no longer vacuous on
  the text-trust axis. Remaining defects: the trial alone reads HOLDS 5/5 with a stub
  `bao` on PATH (no binary pin), T1's custody leg is vacuous on an empty storage path,
  and the counter's ops log captures unseal shares on argv while the secret scan
  excludes `*.ops`.
- **Trade**: no axis lowered; the SKILL.md row is upgraded; the round-60 counter gains a
  selftest without losing a check. The pre-freeze battery reads `CONTROLS: match=17
  mismatch=0` on the current bytes (it was red at the first landing; the defects are
  recorded above).

SEAT-STATUS: complete
