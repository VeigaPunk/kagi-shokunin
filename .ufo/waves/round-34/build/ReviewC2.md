# ReviewC2 — round 34

## Scope and verdict

Axes: calibration, operability, coverage. Read the frozen `plans/round-34.md` first; its C2 predicate/counters remain unchanged. LSP status was attempted through `xd://lsp`; the device is unavailable (`No such tool`). This is textual inspection plus executed falsifiers, not semantic-reference proof. No tools installed, network/vault contact, lane-tracked edits, or subagents.

**C2 defect: M7 is not an isolated base-isolation witness: it fails relative-work too.** This fails this review seat's explicit “base-isolation and nowhere else” acceptance, not the narrower frozen plan's grep predicate. Delivered code genuinely adds and passes the relative-work case and catches reverted canonicalization. Frozen C2 can still be met after L1 generates the final shipped-byte receipt; this review does not claim admission.

## Findings, by severity

### Medium — M7 cross-fails the new case

`build/prefreeze-control.sh:170-189` changes live `a.txt` to four lines, retains the first commit as `rev`, and subsequently tests relative-work against three lines of the same file. Independent M7 therefore fails both cases:

```text
CASE base-isolation             FAIL rc=0 last=PREFREEZE: CLEAN (controls=1 mismatch=0)
CASE relative-work              FAIL rc=1 last=PREFREEZE: MISMATCH (controls=1 mismatch=1)
PREFREEZE_SELFTEST: FAIL (12 cases)
exit=1
```

The frozen plan only requires a receipt naming base-isolation and counts its normalized line. It does not count other failures. ExecGate confirmed the coupling and kept its assigned literal a.txt row (expect 3 at the first commit), rather than silently changing that requirement. Thus the frozen predicate and this seat's exclusivity test are different strengths. Do not report that M7 fails nowhere else.

### Low / frozen-counter limitation — wrong bytes and forged evidence count

`plans/round-34.md:83-85` counts a substring, not an executed result or source identity. An actual independently generated BASE M7 receipt (11 cases, source SHA b634a8d1a1a161debf6069c5ea033a220550efa61c3271313257f8a8f9cd9098) gives the frozen receipt counter 1, despite not testing the delivered 12-case script. A file containing only `CASE base-isolation FAIL` also gives 1. These are demonstrated counter limitations; predicates were not changed.

ExecMut amended `build/mut/m7-run.sh:79-81` to emit source and mutant SHA-256. This supports independent byte comparison but the frozen grep does not enforce that comparison, and text hashes alone do not authenticate execution. Its normalization line is explained: raw `ck` output pads the case name, so the literal frozen substring would otherwise miss a real failure.

## Availability and byte identity

Checked for `build/prefreeze-control.sh` and `build/mut/` every 30 seconds: checks 0–6 absent, check 7 present. Reviewed delivered bytes, not BASE fallback. BASE was independently extracted using:

```sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show f9dc06fd8f6b43c175193c76dc6350468f551634:corpus/prefreeze-control.sh
```

Delivered script SHA-256: `ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a`.

Scratch: `/fast/scratch/hyaku/kagi-r34/ReviewC2`; explicitly exported TMPDIR to its `tmp` child in the Python subprocess environment. Every test subprocess used that scratch as cwd. The script's fixture asserts repository toplevel before its first commit; no mutation occurred in the lane repository. Scratch is removed with Python `finally: shutil.rmtree` after embedding receipts here.

## Attack commands and observed lines

All scratch script copies below were derived from the delivered text, except the explicitly labeled BASE attack. Commands ran through Python `subprocess.run(..., cwd=scratch, env=os.environ.copy(), capture_output=True, text=True)` with the TMPDIR above. These are the assigned measurements, not a full-suite run.

### 1. Delivered selftest and actual relative argument

Command:

```sh
bash /fast/scratch/hyaku/kagi-r34/ReviewC2/shipped.sh --selftest
```

Observed exit 0:

```text
CASE equal-values               ok
CASE one-differs                ok
CASE two-differ                 ok
CASE no-integer                 ok
CASE malformed-row              ok
CASE missing-controls-file      ok
CASE grep-c-exit1-is-zero       ok
CASE empty-controls             ok
CASE bad-rev                    ok
CASE timeout                    ok
CASE base-isolation             ok
CASE relative-work              ok
PREFREEZE_SELFTEST: PASS (12 cases)
```

At delivered lines 184–189, the script changes cwd to `$tmp/rel`, passes literal `--work ./w`, and requires both CLEAN and `OK lines expect=3 measured=3`. It is genuinely relative, not merely an absolute pathname containing a relative-looking segment.

### 2. Canonicalization reverted

Transformation in a scratch copy only: replace the unique line

```sh
WORK_ROOT=$(cd -- "$WORK_ROOT" && pwd -P) || { note "cannot resolve: $WORK_ROOT"; die work-unwritable; }
```

with `: # ReviewC2: canonicalization reverted`.

Command: `bash /fast/scratch/hyaku/kagi-r34/ReviewC2/no-canonical.sh --selftest`.

Observed exit 1; the other eleven cases remained ok:

```text
CASE relative-work              FAIL rc=2 last=PREFREEZE: SETUP noresult
PREFREEZE_SELFTEST: FAIL (12 cases)
```

The new case detects the real relative-root regression.

### 3. Independently rebuilt M7

Scratch-only transformation: replace unique `BASE_DIR=$EXTRACT/tree` with `BASE_DIR=$REPO`; remove the archive pipeline plus its following PIPESTATUS assignment and success check, replacing that block with a no-op. No selftest assertions changed. This is the round-33 escape: controls execute in the live repository, ignoring the selected BASE. Removing the dead pipeline status check avoids manufacturing an unrelated setup failure.

Command: `bash /fast/scratch/hyaku/kagi-r34/ReviewC2/m7.sh --selftest`.

Observed exit 1, ten cases ok and the two FAIL lines recorded in the medium finding. This reproduces the escape with real execution, not a handwritten marker.

### 4. Single-commit false confidence attack

In another scratch M7 copy, remove only the second fixture commit's block (four-line a.txt write, add, commit); retain both case assertions. Command:

```sh
bash /fast/scratch/hyaku/kagi-r34/ReviewC2/single-commit-m7.sh --selftest
```

Observed exit 0:

```text
CASE base-isolation             ok
CASE relative-work              ok
PREFREEZE_SELFTEST: PASS (12 cases)
```

All twelve cases pass despite M7 ignoring BASE, because live equals BASE. Actual delivered bytes retain the second commit and reject this escape. Relative-work alone cannot prove BASE isolation; its task is canonicalization.

### 5. Wrong-SHA real receipt attack

Apply the same M7 mutation to the frozen BASE script, run `bash /fast/scratch/hyaku/kagi-r34/ReviewC2/wrong-sha-m7.sh --selftest`, and record stdout plus exit and a single-space normalized verdict exactly as the receipt generator does.

Observed:

```text
script_sha256=b634a8d1a1a161debf6069c5ea033a220550efa61c3271313257f8a8f9cd9098
CASE base-isolation             FAIL rc=0 last=PREFREEZE: CLEAN (controls=1 mismatch=0)
PREFREEZE_SELFTEST: FAIL (11 cases)
exit=1
m7: verdict: CASE base-isolation FAIL
```

Command: `grep -c 'CASE base-isolation FAIL' /fast/scratch/hyaku/kagi-r34/ReviewC2/wrong-sha-real.txt` → stdout `1`, exit 0. This is real failure evidence, but against the wrong bytes for final C2.

### 6. Handwritten marker attack

Write exactly `CASE base-isolation FAIL\n` into scratch `handwritten.txt` without running a mutant. Command:

```sh
grep -c 'CASE base-isolation FAIL' /fast/scratch/hyaku/kagi-r34/ReviewC2/handwritten.txt
```

Observed stdout `1`, exit 0. The counter alone cannot establish the work was done.

### 7. Case count and names

Commands:

```sh
grep -c '^  ck ' /fast/scratch/hyaku/kagi-r34/ReviewC2/base.sh
grep -c '^  ck ' /fast/scratch/hyaku/kagi-r34/ReviewC2/shipped.sh
```

Observed `11`, `12`, both exit 0. Extracted the `^  ck (\S+)` names and produced this unified diff:

```diff
--- BASE
+++ delivered
@@ -9,3 +9,4 @@
 bad-rev
 timeout
 base-isolation
+relative-work
```

The complete source diff changed only the header's eleven→twelve description and inserted the relative-work block. No old `try`/`ck` case was dropped, weakened, reordered, or rewritten; run-mode logic is unchanged.

## Residual risk and verification gaps

The delivered `build/mut/m7-shipped-11.txt` is explicitly historical BASE evidence (11 cases), not a final shipped-12 receipt. ExecMut's assigned scope intentionally delegates the final12 execution to L1 after installation. L1 must run the delivered generator against the installed `corpus/prefreeze-control.sh`, preserve its source/mutant SHA binding, and write `.ufo/waves/round-34/mut/m7-shipped.txt` before evaluating frozen C2. This review independently executed the 12-case mutation but did not install anything or create another seat's receipt.

No admission, integration, shipping, saturation score, or unrelated resume-continuity assertion is made. The applicable canonical runtime here is the delivered Bash script and the same script's --selftest; scratch mutants deliberately change only the tested mechanism.

Self-evaluation: accuracy 4 (executed evidence, final installed receipt still L1-owned); completeness 4 (all seven assigned attacks covered, installed landing revision not reviewed); clarity 4 (explicitly separates frozen predicate from stronger seat test); actionability 4 (names required final generator run); conciseness 4 (full observed lines retained for reproducibility). Overall 4.0. Highest-impact improvement is the L1 final-byte receipt, not re-scoping the counter. User agreement check: no claim of C2 admission is made from historical bytes.

**C2 defect: the independent M7 fails both base-isolation and relative-work; frozen C2's narrower predicate can nevertheless pass once the final byte-bound receipt is generated.**
