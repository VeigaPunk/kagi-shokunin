# R17-03 — Fresh C3 identity falsification

Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (clone HEAD verified). Axis: C3 calibration. No production files changed; no installs.

## Verdict

**Assigned mutant: KILLED by identity; not a survivor and not an invalid mutant.** The old R17-03 count remains 8; the selected membership changes; R24-11 rejects its digest after the adjacency stamp is refreshed.

## Bounded reproduction

- Created `/fast/scratch/kagi-r24-recovery/KagiR24-2.FIdentityR1703-9/tree` with `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin ...`, then checked out the frozen OID. All execution used `env -i PATH=/usr/bin:/bin`, with `HOME` set to the empty seat `home/`.
- Used only six relevant rows in a scratch claims file: R16-04/05/06, R17-02/03 and R24-11; did not invoke the 15-row harness. Pristine `bash corpus/row-identity.sh adjacency-noenum` printed `count=8 sha256=c52c1027bd87e4ea71dfa63f9e222d36fdc302a17a12fcc23ec05aab91d5a6b1`.
- Pristine `bash corpus/claim-ledger.sh verify --claims <scratch>/claims.tsv --stamps corpus/stamps.tsv`: `failed=0 stale=0`; **process exit 1**, summary `unresolved_ids=500 labeled_ids=56` (full output also emitted MISSING-ID/LABELED-ID diagnostics). Thus target-row control is clean, but this narrowed verify invocation is not a clean process-level control.
- Applied only the `R17-03` function from the frozen `.ufo/waves/round-24/tools/identity-swap.py` via `python3 -c`/`runpy`; it changed `adjacency.tsv:68` from `# no-enumerate\t$HOME/.config/opencode` to `# no-enumerate\t$HOME/yy-.config/opencode` and returned 0.
- Mutant selector printed `count=8 sha256=f05bf9b9617c2d440c976690ddd288ca0519cbd292b5a386d567a7d372878131`. The literal R17-03 count command still printed `8`. Mutant verify emitted exactly `FAIL R24-11 reason=verdict-not-final exit=0`; summary `claims=6 failed=1 ... stale=0`, process exit 1. No R17-03 failure was emitted.
- Stamp-drift control: actual `corpus/adjacency.tsv` SHA-256 was `fc672d4e7aae6881509238e8ff0cbe8123f9cf91723635f7ba44e3c4e845b074`, 83 lines / 5663 bytes; `corpus/stamps.tsv` recorded the identical digest and sizes. The R24-11 mismatch is therefore membership identity, not stale stamping.

## Population / evidence limits

R17-03's note says eight non-enumeration boundaries: four leaves and four aggregate ancestors. In `row-identity.sh:103-105`, `adjacency-noenum` projects all eight full `# no-enumerate` lines (file order); that is the same eight-member population, and the changed line alters the digest. The breadth-pin identities are a separate `adjacency-breadth` selector / R24-12; this bounded run does not independently prove leaf-to-breadth semantics or run host-tagged scope checks.

Historical receipts are not revision-identical to this run: `identity-before-v2.txt` is BASE `4f94b52…` (15/15 survive); `identity-after.txt` says `6c23a56…` (15/15 killed, R17-03 by R24-11). Discovered `.ufo/waves/round-24/build/IdentR1703.md` is also BASE-oriented and describes a different older mutation (`.local/state` → `.local/state/the-janitor`). They are context, not proof for frozen `c5ef9e9`; the reproduction above is.

## Finding / residual risk

**Low — control status is row-level, not process-level.** `identity-swap.py:evaluate` ignores `subprocess.returncode` and classifies controls from `FAIL`/`POLICY` rows only (lines 180–228). The observed control had zero failed rows but exit 1 with unresolved/labeled-ID diagnostics. Do not interpret `control_failing=-` as a successful whole-ledger process. This does not explain the mutant kill: the mutant emitted the explicit R24-11 failure with `stale=0`. Falsifier: the same pristine subset verify exits 0, or the helper records and explicitly scopes its nonzero process result.

LSP device/status was unavailable (`xd://lsp` returned “No such tool”); no LSP semantic checks were possible. No full harness, host-row gate, or real-lane execution was run.