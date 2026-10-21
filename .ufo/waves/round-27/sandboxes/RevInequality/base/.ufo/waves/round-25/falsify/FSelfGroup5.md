# FSelfGroup5 — C1 selected-binding falsification
- Candidate: `82745e2c60e726b49499b8f309529935dc4eff2b` (sandbox `git rev-parse HEAD` matched exactly); BASE: `4587c61a348e4528717404a68912c373f3ef4d03`.
- Axes: calibration (attacked); operability and freshness not evaluated by this assignment.
- Sandbox: `/fast/scratch/kagi-r25/KagiR25.FSelfGroup5-4/lane`; experiment table `corpus/FSelfGroup5-selected.tsv` selects only the four requested bindings. Full `corpus/claim-ledger.tsv` was left intact; `env -i ... grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → `65`, exit 0; selected source IDs resolve in that full ledger.
- Gate argv for baseline, all mutants and final restored run: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FSelfGroup5-4/home python3 -B corpus/self-counts.py --table corpus/FSelfGroup5-selected.tsv` (cwd = sandbox lane; no ambient env).
- Locator/object check: all four returned one `OK` or `STALE` row at unique PROVINCE lines 49–52, with no `UNLOCATED`/`AMBIGUOUS`; cases counts are selftest case totals, while `PV-STAMPS` counts nonblank `corpus/stamps.tsv` records.
## Original receipt — PASS
```text
OK PV-OPREF-SELFTEST PROVINCE.md:49 claimed=36 live=36
OK PV-CHECKLIST-SELFTEST PROVINCE.md:50 claimed=34 live=34
OK PV-SCOPE-SELFTEST PROVINCE.md:51 claimed=61 live=61
OK PV-STAMPS PROVINCE.md:52 claimed=88 live=88
SELF_COUNTS: CLEAN (claims=4 stale=0)
EXIT=0
```
## Mutant receipts — PASS (each captured integer changed by +1; restored before next case)
`PV-OPREF-SELFTEST` 36→37:
```text
STALE PV-OPREF-SELFTEST PROVINCE.md:49 claimed=37 live=36
OK PV-CHECKLIST-SELFTEST PROVINCE.md:50 claimed=34 live=34
OK PV-SCOPE-SELFTEST PROVINCE.md:51 claimed=61 live=61
OK PV-STAMPS PROVINCE.md:52 claimed=88 live=88
SELF_COUNTS: STALE (claims=4 stale=1 unlocated=0 ambiguous=0)
EXIT=1
```
`PV-CHECKLIST-SELFTEST` 34→35:
```text
OK PV-OPREF-SELFTEST PROVINCE.md:49 claimed=36 live=36
STALE PV-CHECKLIST-SELFTEST PROVINCE.md:50 claimed=35 live=34
OK PV-SCOPE-SELFTEST PROVINCE.md:51 claimed=61 live=61
OK PV-STAMPS PROVINCE.md:52 claimed=88 live=88
SELF_COUNTS: STALE (claims=4 stale=1 unlocated=0 ambiguous=0)
EXIT=1
```
`PV-SCOPE-SELFTEST` 61→62:
```text
OK PV-OPREF-SELFTEST PROVINCE.md:49 claimed=36 live=36
OK PV-CHECKLIST-SELFTEST PROVINCE.md:50 claimed=34 live=34
STALE PV-SCOPE-SELFTEST PROVINCE.md:51 claimed=62 live=61
OK PV-STAMPS PROVINCE.md:52 claimed=88 live=88
SELF_COUNTS: STALE (claims=4 stale=1 unlocated=0 ambiguous=0)
EXIT=1
```
`PV-STAMPS` 88→89:
```text
OK PV-OPREF-SELFTEST PROVINCE.md:49 claimed=36 live=36
OK PV-CHECKLIST-SELFTEST PROVINCE.md:50 claimed=34 live=34
OK PV-SCOPE-SELFTEST PROVINCE.md:51 claimed=61 live=61
STALE PV-STAMPS PROVINCE.md:52 claimed=89 live=88
SELF_COUNTS: STALE (claims=4 stale=1 unlocated=0 ambiguous=0)
EXIT=1
```
Final restored gate rerun matched the original four `OK` lines and `SELF_COUNTS: CLEAN (claims=4 stale=0)`, exit 0.

## Literal source receipts — PASS

- `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FSelfGroup5-4/home bash corpus/op-ref-probe.sh --selftest` → `OP_REF_SELFTEST: PASS (36 cases)`, exit 0.
- Same env, `bash corpus/checklist-run.sh --selftest` → `CHECKLIST_SELFTEST: PASS (34 cases)`, exit 0.
- Same env, `bash corpus/scope-gate.sh --selftest` → `SCOPE_SELFTEST: PASS (61 cases)`, exit 0.
- Same env, `grep -c '[^[:space:]]' corpus/stamps.tsv` → `88`, exit 0.

## Finding — FAIL, medium (calibration)

`corpus/self-counts.tsv:31` binds `PV-OPREF-SELFTEST` using `expect:R12-02` and says “R12-02 executes op.” But `corpus/claim-ledger.tsv:27` runs `bash corpus/op-ref-probe.sh --selftest` and has no `[host]`/`[substrate]` note; `corpus/claim-ledger.sh:189-199` explicitly classifies this exact selftest invocation as host-free. Its implementation (`corpus/op-ref-probe.sh:595-749`) tests canned observations and uses a stub for refusal cases; the direct empty-env run above reproduced 36 without running a real `op`. `corpus/self-counts.py:235-240` treats `expect:` as the committed pin, never executes it, while its `ledger:` path can run this untagged safe row (`:150-178, 241-247`). Thus the current count is correct and the +1 document mutation is caught, but this binding does not compare against the runnable live selftest; an output-count change can be invisible to `self-counts.py` until R12-02's pin is separately updated. The binding's source classification/note is false for this command; use of `ledger:R12-02` is the live-source form this contract requires.

## Residual risk and gaps

- UNRUN: full 37-row population; full `verify`/`cells` (prohibited by lane bounds); C2/C3. Scope is the four selected bindings plus direct source receipts.
- UNRUN LSP references/definition/diagnostics: attempted `read xd://lsp`; it returned “No such tool” and the mounted list had no LSP device. Literal code reads/grep were fallback discovery, not semantic proof beyond cited implementation and executed receipts.
- No tools installed or updated.
