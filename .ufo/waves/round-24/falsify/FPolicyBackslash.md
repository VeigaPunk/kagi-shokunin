# Round 24 — FPolicyBackslash

## Verdict

- **Finding:** none in assigned attack. On frozen lane revision `c5ef9e92201b6c36396301f12b23740565bf86a0`, the ledger refuses a single literal backslash with stable `reason=backslash` before launching the claim command. Severity: none for this attack.
- **Axes:** C1 operability only. C2 freshness and C3 calibration were not tested here; this result is not an axis score or a broader C1 admission.
- **Falsifier:** on the same revision, the negative fixture must instead execute its marker script, omit `POLICY b1 reason=backslash`, or produce a different policy reason; a failing no-backslash control would also invalidate this probe.

## Frozen-source evidence

- Lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- `corpus/claim-ledger.sh:260-265` documents the single-backslash defect and checks `[[ $c == *\\* ]]`, returning `backslash`; `:509-515` runs `policy_check` and continues on refusal, before `:536-539` increments `C_RUN` and launches the timeout-wrapped command.
- The fixture and regression expectation are at `corpus/claim-ledger.sh:1335,1577` (one-backslash input; expected `POLICY c1 reason=backslash`). R18-02 now uses a no-backslash ERE at `corpus/claim-ledger.tsv:49`, consistent with the documented restriction.
- Historical baseline is from committed `.ufo/waves/round-24/build/ProbeBackslash.md:28-38`: on BASE, its one-backslash row was executed (then failed the output rule), while its two-backslash row was refused. I did not rerun BASE; the probe below tested only the frozen lane revision.

## Isolated probe

- Created `/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyBackslash-9` using `git clone --no-hardlinks`, checked out the frozen revision there, and observed `git rev-parse HEAD` → `c5ef9e92201b6c36396301f12b23740565bf86a0` (exit 0). All execution used `env -i PATH=/usr/bin:/bin` and the sandbox's empty HOME.
- Scratch fixture control command: `bash /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyBackslash-9/corpus/claim-ledger.sh verify --root /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyBackslash-9/fixture --claims /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyBackslash-9/fixture/control.tsv --stamps /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyBackslash-9/fixture/stamps.tsv --docs /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyBackslash-9/fixture/doc.md` → exit 0; stdout: `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`. Row `bash corpus/control.sh` emitted the expected `CONTROL_OK` verdict.
- Negative fixture row was exactly `bash corpus/back\slash-control.sh` (one literal backslash in the command); its scratch script would emit `BACKSLASH_RAN` and create `$HOME/backslash-ran` if launched. Same verify invocation with `backslash.tsv` → exit 2; stdout:

  ```text
  POLICY b1 reason=backslash
  CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=1)
  NEGATIVE_MARKER=absent
  ```

  The control passed, the refusal was stable, and the sentinel stayed absent. No host/private gate or production file was run or changed; no `--allow-host-rows` use and no tool installation. The full selftest was not run.

## Residual bounds / gaps

- The guard intentionally refuses every backslash in a command string; rows needing escaped regex syntax must be rewritten. The current R18-02 uses `[[]substrate[]]`; this probe did not validate every command position or all other policy-evasion classes.
- Host-tripwire receipts are separate evidence: `.ufo/waves/round-24/tripwire-before.txt` records `total=35`; `tripwire-after.txt` records `total=0` and `complete=4/4`. They measure host-row execution, not the backslash policy. No host tripwire was run in this review.
- LSP unavailable: `read xd://lsp` returned `No such tool: xd://lsp`; no references/definition/diagnostics results exist. Source evidence above is from direct reads of the frozen file, not grep treated as semantic proof.
