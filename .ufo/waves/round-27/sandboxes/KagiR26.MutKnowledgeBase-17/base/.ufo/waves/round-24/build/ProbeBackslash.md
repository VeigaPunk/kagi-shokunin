# Round 24 C1 probe — backslash guard

## Scope and evidence

Read-only probe in the isolated clone `/fast/scratch/kagi-r24/seats/KagiR24.ProbeBackslash-2`, checked out at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (`git rev-parse HEAD`, exit 0). The cloned `corpus/claim-ledger.sh:184` has the old guard `[[ $c == *'\\'* ]]`; `policy_check` first allows only the listed first tokens (`:160-173`), rejects metacharacters (`:177`), then checks backslashes and denied names (`:181-190`).

The requested three rows were written to `probe/claims.tsv` with these exact command fields:

```text
b1  test -e corpus/a\b
b2  test -e corpus/a\\b
b3  grep -cE '\[substrate\]' corpus/claim-ledger.tsv
```

(Fields are tab-separated; `b1` contains one backslash, `b2` two, and `b3` one before each bracket.)

## Runs and results

First run used the literally zero-byte `probe/stamps-empty.tsv`:

```text
cwd=/fast/scratch/kagi-r24/seats/KagiR24.ProbeBackslash-2
bash corpus/claim-ledger.sh verify --root /fast/scratch/kagi-r24/seats/KagiR24.ProbeBackslash-2 --claims /fast/scratch/kagi-r24/seats/KagiR24.ProbeBackslash-2/probe/claims.tsv --stamps /fast/scratch/kagi-r24/seats/KagiR24.ProbeBackslash-2/probe/stamps-empty.tsv
```

Exit 2, with `claim-ledger: no stamp rows ... (refusing to report coverage with an empty stamp set)`. At BASE `load_stamps` rejects zero-row files at `corpus/claim-ledger.sh:319-321`, and `verify` calls `verify_stamps` before `verify_claims` at `:969-971`; none of the three rows ran in this attempt.

To exercise the rows without changing the clone, I reran the same command with `probe/stamps-one.tsv`, containing the one valid pin for `corpus/claim-ledger.tsv` (SHA-256 `87e0217d4eccb442cf86d324281566f5156e248bb61fa7f4ba74f2a47c8208f0`, 60 lines, 19566 bytes). Exit 2; relevant output:

```text
FAIL b1 reason=no-output exit=1
POLICY b2 reason=backslash
CLAIM_LEDGER: POLICY (claims=3 policy=1 stamped=1)
```

- **b1 (one backslash): executed, not POLICY.** `test` returned 1 and emitted no output, so the row failed the ledger's output rule (`FAIL ... no-output`); the old guard did not refuse it.
- **b2 (two adjacent backslashes): refused POLICY** as `reason=backslash`; it did not execute.
- **b3 (two separated single backslashes in the ERE): executed.** It produced no failure/policy row. The same command run directly at BASE printed `11`, exit 0. This matches `corpus/claim-ledger.tsv:49`'s R18-02 command/count.

The verify invocation also emitted unrelated `MISSING-ID` diagnostics because the custom three-row claims file was audited against the clone's full document set; these do not alter the row outcomes above.

The requested shell-semantics stand-in was run directly from the BASE clone:

```text
g\it --version
```

Output: `git version 2.56.0`; exit 0. Bash removes the backslash escape and invokes `git --version`. This direct command is not itself an allowed ledger claim first token (`ALLOWED_RE` at `:160` rejects `g\it` independently); row b1 isolates the backslash-policy defect under an allowed first token.

## Correction and regression cases

Replace the old two-consecutive-backslash pattern with this Bash pattern for one literal backslash:

```bash
[[ $c == *\\* ]] && { printf 'backslash'; return 1; }
```

This rejects both one and multiple backslashes. Under that rule the existing R18-02 ERE row (`corpus/claim-ledger.tsv:49`) will also be refused; the frozen plan explicitly says to rewrite it as a fixed-string count (`plans/round-24.md:20-21`), e.g. `grep -Fc '[substrate]' corpus/claim-ledger.tsv`.

Selftest fixture and `tcase` additions in the existing `printf`/`tcase` style (`corpus/claim-ledger.sh:1155-1165,1259-1269`):

```bash
printf 'c1\ttest -e corpus/a\\b\t.*\t1\t5\tsingle backslash\n' >"$R/claims-bs1.tsv"
tcase policy-single-backslash 2 'POLICY c1 reason=backslash' "$0" verify --root "$R" --claims "$R/claims-bs1.tsv" --stamps "$R/stamps.tsv"

printf 'c2\ttest -e corpus/a\\\\b\t.*\t1\t5\ttwo backslashes\n' >"$R/claims-bs2.tsv"
tcase policy-double-backslash 2 'POLICY c2 reason=backslash' "$0" verify --root "$R" --claims "$R/claims-bs2.tsv" --stamps "$R/stamps.tsv"
```

The single-backslash case is the old-guard killer: BASE executes it instead of emitting the expected POLICY verdict. The second case retains explicit coverage for two backslashes. No source files were changed and no tools were installed.