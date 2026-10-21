# FSelfGroup1 — C1 exact-binding falsification

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (BASE `4587c61a348e4528717404a68912c373f3ef4d03`).
Axes: calibration tested; operability constrained to a lone sandbox/empty HOME; freshness not exercised by this C1 slice.
Verdict: **PASS** — no actionable finding for the four assigned bindings. Installs/updates: none.

## Setup and source semantics

- Read `corpus/lessons/round-25.md` Plan corrections first. Clone `/home/vgpnk/Projects/shokunin/kagi-shokunin` with `--no-hardlinks` to `/fast/scratch/kagi-r25/FSelfGroup1/lane`, checked out the exact revision above (`HEAD` matched; initial porcelain count 0).
- Selected table: `corpus/self-counts.selected-FSelfGroup1.tsv`, four exact data rows copied from `corpus/self-counts.tsv:15-18`; SHA-256 `d50b1a9672d81a2f2bfb3d58da7570f30cbf8a903e66d2edea67d5652314d8e3`. The complete `corpus/claim-ledger.tsv` remained in place and unchanged, SHA-256 `fd73f63d7dbe315ebbc47eb3ba61a2950a0585df5d892e8d747f4e2d2a75ec32` (R21-04 live count 65); `self-counts.py:203-204` loads that full ledger for the selected rows.
- `corpus/self-counts.tsv:15-18`: SC-SKILL-STAMPS and SC-SKILL-CLAIMS bind the two SKILL.md:46 counts to `ledger:R12-03`/`ledger:R21-04`; SC-SCOPE-ROWS binds SKILL.md:35 to `rows:corpus/surface-census.tsv`; SC-SCOPE-SELFTEST binds SKILL.md:35 to `ledger:R16-02`. No selected binding uses `expect:`.
- Numeric semantics / independently invoked source receipts: R12-03 runs `grep -c '[^[:space:]]' corpus/stamps.tsv` → stdout `88`, exit 0 (matches pin `^88$`, stamp membership); R21-04 runs `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → `65`, exit 0 (matches `^65$`, claim-ID rows); R16-02 runs `bash corpus/scope-gate.sh --selftest` → `SCOPE_SELFTEST: PASS (61 cases)`, exit 0 (matches its full declared pin regex). The rows source counts nonblank/non-`#` data lines (`self-counts.py:83-85`), yielding 35 census rows.
- All three `ledger:` IDs are runnable non-host rows; `self-counts.py:150-178` refuses `[host]`/`[substrate]`, and `:181-197` executes argv without a shell and checks the declared exit. `:233-247` distinguishes row count, committed `expect:` pin, and live ledger output. The `expect:` path is not exercised by these four IDs.
- Locator behavior is code-backed at `self-counts.py:220-230`; each selected locator returned exactly one line (SKILL.md:46 or :35). Numeric capture and stale exit behavior are at `:231-250` and `:260-265`.

## Receipts

CWD for all binder runs: `/fast/scratch/kagi-r25/FSelfGroup1/lane`. Exact argv (baseline and each mutant):
`env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FSelfGroup1/home TMPDIR=/fast/scratch/kagi-r25/FSelfGroup1/tmp PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/self-counts.py --table corpus/self-counts.selected-FSelfGroup1.tsv` (shell captured `$?` as `EXIT`). HOME was empty; TMPDIR kept selftest scratch inside the sandbox.

Original/final restored stdout: `OK SC-SKILL-STAMPS SKILL.md:46 claimed=88 live=88`; `OK SC-SKILL-CLAIMS SKILL.md:46 claimed=65 live=65`; `OK SC-SCOPE-ROWS SKILL.md:35 claimed=35 live=35`; `OK SC-SCOPE-SELFTEST SKILL.md:35 claimed=61 live=61`; `SELF_COUNTS: CLEAN (claims=4 stale=0)`. Exit 0.

Each mutant changed only the captured doc integer, then was restored before the next case. In each run, the other three IDs printed `OK` and the summary was `SELF_COUNTS: STALE (claims=4 stale=1 unlocated=0 ambiguous=0)`; exit 1:

- SC-SKILL-STAMPS: SKILL.md:46 `88→89`; stdout `STALE SC-SKILL-STAMPS SKILL.md:46 claimed=89 live=88`.
- SC-SKILL-CLAIMS: SKILL.md:46 `65→66`; stdout `STALE SC-SKILL-CLAIMS SKILL.md:46 claimed=66 live=65`.
- SC-SCOPE-ROWS: SKILL.md:35 `35→36`; stdout `STALE SC-SCOPE-ROWS SKILL.md:35 claimed=36 live=35`.
- SC-SCOPE-SELFTEST: SKILL.md:35 `61→62`; stdout `STALE SC-SCOPE-SELFTEST SKILL.md:35 claimed=62 live=61`.

Final restoration receipt: SKILL.md SHA-256 returned to its original `3d0c1f5521566dda9baa75c7b33ed23aec839e05b0efdc97ae122b944108c457`; claim-ledger hash remained unchanged; HOME and TMPDIR had zero entries. No production file was edited.

## Residual risk and verification gaps

- One initial direct R16-02 invocation omitted TMPDIR; the selftest uses `mktemp` with cleanup, and it was repeated successfully with TMPDIR under this sandbox. The repeated receipt above is the relied-on one.
- `xd://lsp` was unavailable (`No such tool`); references/definition/diagnostics could not be queried. Text search was only a literal caller/locator fallback, not semantic proof; semantics above are supported by source and executed outputs.
- UNRUN by scope: full `verify`/`cells`, the other 33 bindings/population completeness, and `expect:` behavior. No C2/C3 or freshness claim is made.