# ClaimR12X01: critic audit of claim-ledger row R12-01 (round 23 parent build)

Seat: critic. Axes: calibration, freshness, operability. Read-only and advisory; no judgment or admission.
No gate, handler, `op`, vault or claim command was executed (see §Limits).

## 1. Observed revision

- Repo `HEAD`: `d218603b74099ddca0bd8f869516fc41db0979bf` (detached, read from `.git/HEAD`).
  The working tree changed during the audit while L1 integrated round 23 (mtimes 00:46–00:54 -03:00,
  2026-10-21). Every finding is tied to one of the hashes below.
- The audited row is the frozen object. `corpus/claim-ledger.tsv:26` is byte-identical (`cmp`) to
  `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:26`. I checked this twice, the second time
  at 00:54:47, after the in-flight ledger edit (current ledger sha `6fa0c24f…`).
- `corpus/op-ref-probe.sh` has sha256 `0f1945e8d8a8fc56aaee256180cd7badde466bc8ac91503aa1e1853e79044f4c`, 788 lines and 34362 bytes. This equals
  its `corpus/stamps.tsv` pin and the digest recorded at round 20 (`corpus/lessons/round-20.md:11`).
  The probe is unchanged since 2026-10-15.
- `corpus/claim-ledger.sh` was read at its stamp `cf56f9ea…` (1428 lines / 88425 bytes). It is now
  `c20c2d04…` in-flight, 55 bytes larger. The change I found by grep is the closure-dispositions
  allowlist at L92 and L161; I did not diff the whole file. These cited lines are unchanged:
  - substrate_present L140-146;
  - DEFER L416-419;
  - the run step L425-444;
  - SKIP-SELF L816-820;
  - the CELL_AUDIT summary L1006-1012.
- Host metadata only (stat and `command -v`, nothing executed): `$HOME/.local/bin/the-janitor` is absent
  and `/usr/bin/op` is present. So on this host R12-01 resolves to `DEFER R12-01 reason=substrate-absent`.

## 2. Row and per-field verdict

R12-01 fields:
- command: `bash corpus/op-ref-probe.sh`;
- expected ERE: `^OP_REF_PROBE: CLEAN \(checks=[1-9][0-9]* oprun=[1-9][0-9]* refs=[1-9][0-9]* divergent=[1-9][0-9]*`;
- exit: 0;
- timeout: 300;
- note: "the summary counts ARE the claim (oprun=12 refs=7 divergent=5 sig=6 at v2 …) … else SETUP exit 2 … [substrate]".

| Field / mechanism | Status | Evidence |
|---|---|---|
| CLEAN verdict, exit 0, final line | **Supported by code; historical evidence only** | `evaluate` prints CLEAN only when `C_FAILED==0` and returns 0 (`op-ref-probe.sh:462-469`). Nothing prints after the summary; the cleanup trap is silent (L146-151). Executed CLEAN `checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6`, exit 0: round 12 (2026-09-28, op 2.35.0, `lessons/round-12.md:17-20`) and round 14 (`lessons/round-14.md:168-173`). Round 18 (2026-10-14) gave `OP_REF_PROBE: SETUP` exit 2 (`lessons/round-18.md:25`). Round 22 did not execute it (`.ufo/waves/round-22/final-verification.json:542-546`). **The live contract has never run on op 2.41.0.** |
| ERE vs the note's "counts ARE the claim" | **Refuted (calibration defect)** | My regex-only test (bash `=~`, no gate run) accepts all of these: the v2 line; the v1 line `checks=34 oprun=10 refs=7 divergent=3 edge=8 sig=4`; shrunk-contract lines `43/11/7/4` and `41/9/7/2`; `edge=0 sig=0`; and a line with no `edge`/`sig`. The ERE pins positivity only and has no `\)$`. |
| What the counts mean | **The counts are contract constants, not measurements** | Under CLEAN every count is fixed by the contract arrays:<br>• `oprun` counts rows written per contract entry, including `absent` rows (L322-330).<br>• `divergent` is `${#DIVERGENT_CONTRACT[@]}`, printed even on DRIFT (L463-468).<br>• `refs` must equal the contract exactly (L383).<br>• `edge=10` counts the single-file `KAGI12_P8` row (L340-341), which is never compared (the loop at L392-397 covers E1-E9 only).<br>So the counts identify the contract revision. They become a claim only if the ERE pins them. |
| timeout 300 | **Supported as headroom, with no per-call bound** | A plain `op run` takes ~0.02 s (`knowledge/op-cli-surface.md:20`); the whole checklist takes ~2.3 s (R15-01 note). The verify arm execs op without a timeout (`op-ref-probe.sh:264`), unlike the byte arm's `timeout 10` (L262). One blocked call costs the full 300 s and ends as `FAIL … reason=timeout` (`claim-ledger.sh:428-431`). |
| `[substrate]` deferral | **Partial** | The predicate checks only that the handler is executable (`claim-ledger.sh:140-146`; `knowledge/substrate-deferral.md:27-33`), but the row needs op as well. Two gaps:<br>• op absent, handler present: SETUP exit 2, so the row is a **FAIL, not a DEFER**.<br>• A directory at the handler path passes both `-x` checks (`substrate-deferral.md:102-103`; probe L485). The probe then execs real op 31 times and the handler exec fails, giving DRIFT exit 1.<br>Deferral itself is correctly not counted as a pass (`substrate-deferral.md:59-61`). |
| SKIP-SELF | **Correctly not applicable** | The command has no `claim-ledger.sh` (L816). As a result, a single substrate-present `verify` runs the same obligation up to three times:<br>• directly;<br>• nested in R13-03 `cells`, because 11 cells cite R12-01;<br>• through R15-01 → checklist E5 (`corpus/checklist.tsv:30`), which uses a *different* ERE: anchored and including edge/sig, but accepting zeros.<br>This is one measurement, not three corroborations. All three paths defer on this host. |
| Hermetic synthetic mode | **Does not carry R12-01 at all** | The round-22 hermetic cells run used only synthetic `grep` rows ("no substrate-tagged rows", `.ufo/waves/round-22/falsify/RunCellsMalformed.md:34`, env at :53). The in-flight C3 row R23-01 (`claim-ledger.tsv:59`) runs a fixture with only R90-01/R90-02 and pins `row_deferred=0`, which structurally excludes all 11 substrate rows, R12-01 included. It runs no live substrate command (good), but it is evidence about the parser, not about any real command-row obligation. |

## 3. Main counterexample (F1): an inherited reference makes `op run` contact the vault and the probe report false DRIFT

**Safety claim under test.** The probe header says the gate is safe by construction:
"cannot resolve a reference — no vault contact, no approval prompt, no sign-in dependency"
(`corpus/op-ref-probe.sh:29-43`). The same claim appears in two other places:
- "zero vault contact" (`SCORECARD.md:93`);
- the E5 note (`corpus/checklist.tsv:30`).

**Why the claim does not hold.**
- The guards inspect only env-file paths:
  - `guard_op_side` L209-223;
  - `guard_op_file` L228-241;
  - the `--env-file=` loop in `op_exec` L250-257.
- The verify arm execs op with the caller's whole environment (L263-265). Only the byte arm isolates
  with `env -i`, a scratch HOME/XDG and biometric unlock off (L258-262).
- The ledger passes the runner's environment through unchanged (`claim-ledger.sh:426-427`).
- The probe already proves op processes inherited variables: its inherited-trim check (L346) and
  `knowledge/op-ref-consumption.md:157-161`.
- The vendor documents that `op run` resolves references found in environment variables (§6).
- Local evidence shows what happens when a reference must resolve while signed out: either a fast
  fail (~4 s, exit 1) or a silent block for the whole bound (`knowledge/op-cli-surface.md:21`).

**What a consumer sees.** Suppose any inherited variable holds a reference value. Each of the 31 op
calls in `collect` (oprun 12, mask 2, edge 9, P8 1, prec/union/inh 3, signatures 4) then tries to
resolve it. There are two outcomes:
- `OP_REF_PROBE: DRIFT`, exit 1. The probe defines this class as "a measured behaviour changed"
  (L45-46). The ledger reports `FAIL R12-01 reason=exit-mismatch exit=1 want=0`.
- The call blocks until the 300 s ledger timeout.

On a substrate-present host the same failure repeats under R13-03 and R15-01. The row note promises
SETUP exit 2 for host-state dependence, so the actual result contradicts it. This is a fixable defect,
not a tradeoff.

**Minimal synthetic failing fixture for L1.** Not executed by me. It uses stubs only and never runs the
real op or handler. The reference needle is built at runtime so no reference-scheme literal lands in a
tracked file.

```bash
d=$(mktemp -d); n=$(printf '%s:%s' op //)
printf '#!/bin/sh\nenv | grep -q "=%s" && echo envref >>"%s/op.log"\necho "[ERROR] account is not signed in" >&2\nexit 1\n' "$n" "$d" >"$d/op"
printf '#!/bin/sh\nexit 0\n' >"$d/jan"; chmod +x "$d/op" "$d/jan"
env KAGI12_ENVREF="${n}Kagi12NoVault/I/F" OP_REF_OP_BIN="$d/op" OP_REF_JANITOR_BIN="$d/jan" \
  bash corpus/op-ref-probe.sh; echo "exit=$?"; wc -l <"$d/op.log"
```

- **Expected under the header's safety claim:** refusal before exec (POLICY exit 2) and an empty log.
- **Expected from code reading (not executed):** no POLICY. 31 `envref` log lines. Final line
  `OP_REF_PROBE: DRIFT (checks=38 failed=36 oprun=12 refs=0 divergent=5 edge=10 sig=6)`, exit 1.
  Note that this line shows `oprun=12 divergent=5` while zero keys were injected, which confirms F2.
- **Ledger form:** use a scratch `--root` holding a probe copy and a `--claims` file holding the exact
  row-26 bytes, with `KAGI_SUBSTRATE=present` and the same environment, set up the way the
  `defer-substrate-*` selftest cases do (`claim-ledger.sh:1422-1424`). Expected:
  `FAIL R12-01 reason=exit-mismatch exit=1 want=0`.

**Smallest safe correction.**
1. Send verify-arm op calls through the byte arm's existing isolation pattern (L258-262): `env -i`,
   scratch HOME/XDG, `OP_BIOMETRIC_UNLOCK_ENABLED=false`, and a per-call `timeout`. Pass `KAGI12_T`
   explicitly so the inherited-trim check still works.
2. Add a canary before measuring: one `op run` over a one-line plain file that runs `true`. If the
   canary fails, or any call exits 124, stop with SETUP instead of reporting DRIFT.
3. Add the fixture above as a selftest case. It passes when the call is refused (POLICY) or when the stub
   log stays empty.
4. Until this lands, the R12-01 note should say that op-side or environment failures appear as DRIFT
   exit 1 or as a timeout, not as SETUP.

Isolation also removes another false DRIFT: an inherited `KAGI12_E8_UNSET` would change edge E8.

## 4. Secondary findings

**F2: counts not pinned (calibration; false-clean).**
- Falsifier:
  1. Delete the digit-leading shape from three places: the fixture (L175), `OPRUN_CONTRACT` (L87) and
     `DIVERGENT_CONTRACT` (L92).
  2. Run `--selftest`. It stays `PASS (36 cases)`, because the only divergent keys any case mutates are
     `KAGI12_B` (L611-613) and `kagi12_lower` (L652-654).
  3. A CLEAN run now prints `checks=43 oprun=11 refs=7 divergent=4 edge=10 sig=6`. R12-01's ERE accepts
     it (regex-tested).
  4. The docs still promise five divergent shapes:
     - `knowledge/op-ref-consumption.md:54-55`;
     - `knowledge/op-ref-consumption.md:60-63`;
     - `SKILL.md:33`.
- Only the stamp or revision audit notices the byte change, and only until someone re-stamps it in a
  reviewed commit.
- Fix, part 1: set the ERE to `^OP_REF_PROBE: CLEAN \(checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6\)$`.
  This is derived statically from the unchanged v4 arrays and matches the last executed (round 14)
  line. Label it as unexecuted since round 14.
- Fix, part 2: assert the same exact line in the selftest's `canned-faithful` case (L603). It currently
  checks only `^OP_REF_PROBE: CLEAN `. With that change R12-02, which runs on every host, pins the
  contract size hermetically.

**F3: cells over-assurance (what C1 and C3 must keep for R12-01).**
- Eleven SCORECARD cells cite R12-01: L93, L94 (the `R12-01..03` range head), L104, L106, L107, L182,
  L204, L226, L290, L311, L619.
- Eight of them (L104, L106, L107, L182, L204, L226, L290, L311) have no runnable row pointer and no
  stamp pointer. I computed this with the `cells` token rules. Six are depth cells resting only on
  R12-01.
- While the handler is absent, the `cells` code still counts those eight as `row_pointed`. It can print
  CLEAN with only an aggregate `row_deferred` (`claim-ledger.sh:1011-1012`); there is no per-cell
  disposition. I did not run `cells`.
- Knowledge entries with the same problem:
  - `op-cli-surface.md:9` and `op-env-refs.md:8` declare Reverify sets made only of substrate rows.
    That means zero re-runnable verification here, yet the docs audit counts them as row-linked.
  - `op-ref-consumption.md:23` does have runnable co-pointers (R12-02, R21-01), but neither re-verifies
    the handler half.
- The in-flight round-23 sections (L824-844) no longer cite R12-01; depth now points at R21-01. So
  R12-01 backs only historical cells.

C1 must retain:
- R12-01's disposition as *deferred*, never closed;
- provenance: last executed CLEAN at round 14, measured on op 2.35.0 against the handler revision whose
  `refs` awk and `run` exec it cited (`cmd_refs` L228-236, `cmd_run` L248);
- the eight deferred-only cells and the two deferred-only Reverify sets;
- E5 (via R15-01) and the R13-03 nesting recorded as the same measurement.

The in-flight D9 disposition, "fixed" (`corpus/closure-dispositions.json:105`), points at the whole file
`corpus/claim-ledger.tsv`. That pointer resolves just because the file exists. A row-causal pointer would
name `R23-01`. Its note ("R13-03 keeps its explicit host skip") is accurate.

C3 must retain:
- Never un-defer R12-01 against real op:
  - no handler stub at the pinned path, and no `OP_REF_JANITOR_BIN` stub, while `/usr/bin/op` is
    reachable;
  - forcing `KAGI_SUBSTRATE=present` alone does not run op, but it turns the DEFER into a SETUP FAIL;
  - no `OP_REF_*` stub run counted as `rows_run`. The probe's output names no binary, so the ledger
    cannot tell a stub pass from a real one.
- If the hermetic proof must carry this obligation, add a selftest case that byte-copies row 26 and
  asserts `DEFER R12-01 reason=substrate-absent` under `KAGI_SUBSTRATE=absent`. A ledger row cannot set
  that variable, because policy rejects `$` and environment prefixes.
- **The judge should reject any claim that R23-01 "preserves all command-row obligations".** Its
  fixture preserves none of the 43 real rows. It is evidence about the parser only.

**F4: freshness and identity.**
- The note says "at v2", but the probe is `VERSION=v4` (L64), and `VERSION` is never printed.
- The CLEAN line carries no op version and no handler digest. The docs bind it to op 2.35.0 and handler
  L228-236/L248 (`op-ref-consumption.md:3-6`). If a different handler revision were restored, it would
  produce a CLEAN with false provenance unless R11-04 is CLEAN in the same run.
- 31 of the 44 checks need only op: oprun 12+1, edge 9, prec/union/inh 3, masking 2, op signatures 4.
  They could be re-measured on the op 2.41.0 already present, under `env -i`, the way R21-01 does.
  Coupling them to the absent handler has kept all of them unmeasured since round 18. This is optional,
  not the smallest correction.

## 5. Cross-row contradiction (also sent to KagiR23)

This concerns R21-01, which is not my row. In the working tree, two texts now say that "sign-in,
timeout, missing binary" all end as SETUP exit 2, citing `op-ref-probe.sh:525-526`:
- the R21-01 note (`corpus/claim-ledger.tsv:51`);
- `knowledge/op-ref-consumption.md:362-365` (sha `76b46fb4…`).

In the unchanged probe, only a missing binary is SETUP (L525-526). A sign-in failure or the `timeout 10`
exit code (L262) is written to the observation file (L545, L549). `evaluate_bytes` then marks the case
FAIL, giving `OP_DOTENV_BYTES: DRIFT` exit 1 (L503-516). The new text is false for two of the three
failure kinds.

## 6. Public sources (fetched 2026-10-21; neither page shows a date)

- 1Password Developer, "run" (https://developer.1password.com/docs/cli/reference/commands/run/, served at
  https://www.1password.dev/cli/reference/commands/run), heading "Load secrets using secret references":
  - "`op run` can scan environment variables and files for secret references". This supports F1.
  - "Secrets printed to stdout or stderr are concealed by default." This still matches the entry's
    2.35.0 help-text quote (`op-ref-consumption.md:100-101`). It is active public evidence, but not
    pinned to a version.
- 1Password Developer, "Load secrets into the environment"
  (https://developer.1password.com/docs/cli/secrets-environment-variables/), heading "Command line":
  "You can individually export environment variables as secret references from the command line."
  So the inherited-reference setup in F1 is a vendor-documented workflow, not an exotic one.

## 7. Limits

- Not executed: R12-01, any sibling gate, op, the handler, and the fixtures above. Every derived output
  in this report comes from reading code and is labelled as such.
- Executed, all read-only:
  - `sha256sum`, `wc`, `cmp`, `stat`, and a `command -v` lookup;
  - bash `=~` tests of the R12-01 and E5 EREs against synthetic strings;
  - Python parsing of SCORECARD, stamps and in-flight JSON;
  - two public page fetches.
  - A mistyped `awk` job looped without output and was cancelled.
- Process deviation: at the start I ran `git log -1` and `git status --short | wc -l` once. `git status`
  may refresh the index stat cache. I used no Git after that.
- F3 line numbers come from the in-flight SCORECARD (sha `683c9069…`; it kept changing). The cited lines
  (93-619) come before the appended round-23 sections and did not move.
- Tools installed: none.
