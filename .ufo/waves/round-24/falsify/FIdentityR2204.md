# FIdentityR2204 — fresh scoped review

Axes: operability (sandbox/host safety), freshness (frozen-tree remeasurement), calibration (count versus declared membership).
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Sandbox: `/fast/scratch/kagi-r24-recovery/FIdentityR2204-9`, with checkout in `repo`, empty `home`, and isolated `tmp`.

## Findings by severity

**Medium — the assigned mutation does not replace a control in the OLD note's behavioral population.**
`corpus/claim-ledger.tsv:58` describes eleven H1 controls, three metadata/hardlink refusals, a valid gitignore control, and two SHA256 controls.
The instrument at `.ufo/waves/round-24/tools/identity-swap.py:152` merely renames `gitignore-valid` to `gitignore-valid-x`.
At `corpus/revision-audit.py:545`, `check(..., 0, "ADDED .gitignore", audit(root, history))` still executes unchanged.
The fresh probe found 17 calls before/after and identical assertion arguments for every call; the gitignore control still prints `exit=0 finding=ADDED .gitignore`.
Thus this is **KILLED and valid for the explicitly declared case-NAME projection**, but **INVALID as evidence that replacement/removal of an OLD-note behavioral control is caught**.
This distinction bounds C3's `0/15` claim: R22-04 contributes an output-label identity trial, not an assertion-membership trial. No output-name survivor was observed.
Falsifier: the original gitignore-valid behavioral member remains present after the purported member swap; only its label changes.

## Fresh bounded experiment

Setup command (all processes used `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`):
`mkdir -p <sandbox>/home <sandbox>/tmp && git clone --quiet --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin <sandbox>/repo && git -c advice.detachedHead=false -C <sandbox>/repo checkout --quiet c5ef9e92201b6c36396301f12b23740565bf86a0`
Observed setup exit: **0**; stdout empty. Here `<sandbox>` is the exact path stated above.
Actual bounded check, cwd `<sandbox>/repo`:
`/usr/bin/env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FIdentityR2204-9/home TMPDIR=/fast/scratch/kagi-r24-recovery/FIdentityR2204-9/tmp /usr/bin/timeout -k 2s 40s /usr/bin/python3 /fast/scratch/kagi-r24-recovery/FIdentityR2204-9/probe.py`
Observed driver exit: **0**. Its `git rev-parse HEAD` exited **0** and printed the full frozen revision above.
The driver imports instrument definitions without calling `main`, selects ONLY its `R22-04` mutant, and applies that function exactly once.
It runs the following two commands once per phase, comparing exit and stdout with the frozen TSV expectations:

| Phase | Command | Exit | Observed stdout / pin result |
|---|---|---:|---|
| Pristine | `python3 corpus/revision-audit.py --selftest` | 0 | `REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)`; R22-04 matches |
| Pristine | `bash corpus/row-identity.sh revision-cases` | 0 | `ROW_IDENTITY: revision-cases count=17 sha256=75c82770356fa358458b1c84a171d9c139fc4bbcea6d0ed0a356f63d4d549d16`; R24-16 matches |
| Mutant | `python3 corpus/revision-audit.py --selftest` | 0 | `REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)`; R22-04 still matches |
| Mutant | `bash corpus/row-identity.sh revision-cases` | 0 | `ROW_IDENTITY: revision-cases count=17 sha256=f69fc8494a6b2f8ae4c2267341a8653a4f0652da52d51d70a28cb8cbe36056cd`; R24-16 mismatches |

Each selftest emitted 17 PASS case lines. Independent LF-joined name hashing reproduced both selector digests.
Observed removed/added names: `['gitignore-valid']` / `['gitignore-valid-x']`; OLD count preserved **17 → 17**.
Pristine controls for these two rows: **PASS**, not inferred from an absence of FAIL lines.
Instrument `sub_once`/`restamp` (`:54-77`) refreshed the target stamp: fresh SHA256/LF/bytes matched the actual mutant bytes.
Observed stamp path set unchanged, and only the `corpus/revision-audit.py` stamp row changed.
Identity causality is direct: `row-identity.sh:116-120` runs only the fixture selftest and hashes PASS-line names, without reading stamps.
The selector exits 0 in both phases; the kill is its R24-16 pinned-digest mismatch, not a selftest crash or stale stamp.

## Residual risk and verification gaps

- `row-identity.sh:119` projects names only, in OUTPUT ORDER; it does not hash exit/finding assertions or fixture behavior. `claim-ledger.tsv:79` honestly declares that narrower projection.
- `build/IdentR2204.md:24-29,44-46` used a different rename (`clean-control`) and proposed SORTED names. Those historical digests are not the implemented output-order contract and were not substituted for fresh evidence.
- `identity-before-v2.txt:15-16` records the BASE survivor; `identity-after.txt:15-16` records R24-16 as sole killer at `6c23a56dea0f`, not at the frozen revision. The fresh experiment above covers the frozen two-row projection only.
- Instrument `evaluate` (`identity-swap.py:180-187`) discards the verifier exit status and identifies failure only through printed FAIL/POLICY lines. [INFERENCE] An abnormal exit without those lines can be classified as a clean control; the archived `control_failing=-` is not by itself exit/PASS evidence. Fresh direct controls avoid that gap for the two assigned commands.
- Full subset ledger verification, R22-03 history mode, the other 14 mutants, host gates, and general saturation were not run or independently certified. No universal semantic-membership pass is claimed.
- LSP unavailable: `read xd://lsp` returned `No such tool`; definitions/callers were reviewed through exact source ranges and the assigned BASE-to-frozen diff. Text search was navigation, not semantic proof; no LSP diagnostics were available.
- No delegates, background jobs, host package/config/service changes, or tools installed. Production stayed read-only; the only lane write is this report.

Recommendation: accept the observed R22-04 count-preserving NAME-swap kill, but do not admit it as proof of behavioral-population binding.
