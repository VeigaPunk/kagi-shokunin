# R61Critic — wave report (round 61, kagi)

Seat: R61Critic (critic). Read-only. Full receipt with commands and raw output:
`.ufo/waves/round-61/build/R61Critic/falsify.md`. Measured tree: lane working tree at
HEAD `8595018` plus the round-61 instruments (hashes in the receipt).

## What was attacked

**C1 (calibration, `C1_ROUTED` 7→0).** The do-nothing control, a records-only tree, the
checker's derivations against invented numbers, the position rules, the guard, and the
checker's own selftest.

**C2 (operability, `C2_SEAL_TRIAL` 0→5).** A stub `bao` on PATH, a do-nothing trial, the
five mechanic-removal variants, the 405-vs-403 and 503-vs-403 distinctions, the
duplicate-share refusal, the custody sweep, the OTP leg, and the secret transport.

## Findings

### C1 — the claim holds, with three calibration defects

- **Do-nothing control passes**: BASE `--no-challenge` ⇒
  `C1_ROUTED: value=7 population=7 i1=0 … i7=0 guard=0`. No item is vacuous at BASE.
- **Candidate reading**: `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=1`;
  checker selftest `C1_CHECK_SELFTEST: PASS (52 cases)`.
- **Invented numbers are caught**: wrong result count (`results=15`), wrong byte length
  (`output=9999`), wrong fraction (`2/16`), wrong percentage (`19`), and three invented
  timestamps each read their item 0. Position rules are enforced (a correction before
  R37, an A7 before A6, each read 0).
- **Defect 1 (I3 polarity)**: `A3 item 2 is not withdrawn` reads `i3=1`. The item's prose
  says "states the item is withdrawn"; the checker's token test accepts the negation.
- **Defect 2 (I4 polarity)**: `the round did not introduce three new record defects`
  reads `i4=1`.
- **Defect 3 (I6 retained timestamp)**: the honest correction plus the superseded wrong
  stamp `15:09:28` reads `i6=1`; the D6 defect can remain in the correction of record.
  The "timestamp in range on another commit" class (`15:06:58` → `16:33:16`) also passes
  — a named ceiling (set membership), but it means the correction need not attribute a
  stamp to the commit it describes.
- **Strength note**: a records-only tree (BASE + the six text corrections + the SKILL.md
  row, no code) reads `value=1`; six of seven items are appended text. Only I2 requires
  behaviour. That is the plan's declared convention, not a defect.
- **Guard**: the `deletions=1→2` challenge fires (`guard=1` on the candidate and on the
  records-only tree); the printer-stub clause is the round-60 R40 non-discriminating
  clause repeated verbatim (report only; frozen).

Smallest safe corrections: require the affirmative phrases (`is withdrawn`,
`introduced three new record defects`) and reject a preceding `not `; for I6, require
every `-03:00` timestamp in the correction line to be a driver line or a member of the
derived commit set.

### C2 — the claim holds, with three residual defects

- **Real run**: `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0` rc 0 on the real
  2.7.2 binary; `T4 HOLDS … dec=1 wrong=1` (the right OTP authenticates, the wrong OTP is
  a different 26-char token that gets 403).
- **Counter**: `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1
  guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 …)`. The `ops` witness
  and `stubctl` control were added after this seat's first finding and now reject a
  text-only trial (the same fixture read `value=5` before the upgrade, `value=0` after).
- **Discrimination measured** (stub mechanic-removal): duplicate-share counting ⇒
  `T2 BROKEN`; rekey 403 ⇒ `T5 BROKEN`; sealed 403 ⇒ `T3 BROKEN`; 3-share init ⇒
  `T1 BROKEN`. T5's 405 is distinguishable from a permission error; T3's 503 from 403.
- **Defect 4 (T1 custody vacuous)**: with a server that writes no file under the raft
  path, `T1 HOLDS … nopersist=1` — the negative grep passes on an empty directory. The
  custody claim is not tested unless the storage path is non-empty. Fix: require at least
  one file under `$D/raft` before the sweep.
- **Defect 5 (trial is stub-satisfiable)**: a stub `bao` on PATH (no real server, no
  Shamir) now reads **`OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0`** — every test
  passes, including T4's `wrong=1`. The trial checks only `bao version`
  (`grep -c sha256 corpus/openbao-seal-trial.sh` ⇒ 0), never the binary's sha256. The
  counter's pin + ops witness is the only provenance; the trial's own receipts are not
  provenance-checked. Fix: pin the binary in the trial (the round-57 `PIN_BAO` pattern)
  or require a server-log build hash.
- **Defect 6 (secret on argv captured by the ops witness)**: `unseal_share` passes the
  share as an argv positional (a measured 2.7.2 necessity: piped unseal is refused with
  "file descriptor 0 is not a terminal"). The counter's `mkshim` logs the full argv to
  `$SCR/log/<leg>.ops`, and the secret scan excludes `*.ops`; 8 ops lines carry a 43+
  char base64 share. The trial's "never printed or captured" is false for the
  counter-mediated run. Fix: log only the subcommand words (or redact 43+ base64 runs)
  and include `*.ops` in the scan.

### Instrument defects (control battery)

The pre-freeze battery at its first landing (17:13 receipt) read `CONTROLS: match=4
mismatch=13`; the current bytes (`plans/round-61-controls.sh` sha256 `8d100756…`) read
**`CONTROLS: match=17 mismatch=0`** rc 0, and the receipt
`.ufo/waves/round-61/controls/controls-prefreeze.txt` carries it. The defects below were
real at the first landing and are recorded because the claim's reading depends on the
battery's bytes; four were fixed, one is a residual design issue.

- `body` used `exit 1`/`exit 0`, terminating the script before `cat "$OUT"` (the receipt
  was written and then deleted with the scratch). The current bytes use `( body )`.
- `ctrl_c2_sh` used `local n=$1 id="C2-SH$n" …`, which expands `$n` before the `local`
  assigns it; under `set -u` it is `n: unbound variable` and kills the battery before
  C2-SH1..5, C2-STUB and C2-FIXTURE-TRUTH. Fixed in the current bytes.
- `gen_stub_trial` put the `command -v bao` guard before the `--selftest` branch, so the
  C2-STUB fixture failed the selftest leg for an unrelated reason and the control passed
  vacuously; with the branch moved first, the same control read `value=5` against the
  pre-upgrade counter. Fixed.
- The C1-F1..F6 expectations in the 17:13 receipt were shifted (`value=1 i1=1 i2=0 …` vs
  the observed `value=2 i1=0 i2=0 …`) because the synthesized fixed tree left I2
  unresolved; C1-F7 read `mutation-failed(rc3)`. The current battery reads 17/17 match.
- **Residual**: `C2-FIXTURE-TRUTH` expects `value=0` when the caller's PATH `bao` is a
  stub, but the counter overrides the caller's PATH with the pinned binary (`mkshim`
  execs `$BAO_BIN`), so a working trial under the pin reads `value=5`. The control
  currently matches only because the counter's real legs are pinned; it tests a path the
  counter does not use. The counter's actual defence is the pin + ops witness, which
  `C2-STUB` and the `ops` leg cover.

### Trade check

No axis lowered: `SCORECARD.md` adds the pre-move table with no `9 → [0-8]` line; the
`SKILL.md` row for `plans/round-60-c2.sh` is upgraded from `none of its own` to a
runnable `--selftest` (cases=36); `plans/round-60-c2.sh` gains +251/−11 with the
deletions being the argument-parsing refactor, not a removed check; the records files are
additions only (`1 0`, `15 0`, `14 0`); `SOURCES.md`/`source-fetches.tsv`/`README.md` are
additions only.

## Verdict

- C1: **predicate met by the checker** (`value=0 guard=1`, BASE `value=7`, selftest
  PASS 52 cases); three calibration defects (I3/I4 polarity, I6 retained timestamp)
  remain and are fixable checker-side.
- C2: **predicate met by the counter** (`value=5`, real run HOLDS 5/5, ops=1, stubctl=1);
  three residual defects (T1 custody vacuity, the trial alone reads HOLDS 5/5 with a stub
  `bao`, argv shares in the ops log).
- Trade: no axis lowered; the control battery reads `CONTROLS: match=17 mismatch=0` on
  the current bytes (it was red at the first landing; the defects are recorded above).

SEAT-STATUS: complete
