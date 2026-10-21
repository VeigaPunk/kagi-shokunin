# FCrossAxis Report: Cross-Axis Contract Synthesis and Alignment

## Evidence
- Frozen plan `plans/round-24.md:15-18` specifies host-row opt-in via env var `KAGI_HOST_ROWS=run`, but `corpus/claim-ledger.sh:110-111` strictly rejects environment variables in favor of `--allow-host-rows`, proven by selftest case `host-env-not-consent` (`:1571`). `corpus/lessons/round-24.md:16-36` documents plan corrections R24-C1..R24-C4 but silently omits this contract divergence.
- Repertoire mismatch: `SKILL.md:748-752` cleanly classifies `rendered-text-v1.py` and `row-identity.sh` as helpers, and `closure-dispositions.py` as a gate. However, `PROVINCE.md:45-55` lists both helpers under "Gates in this repo" (`:54`) while omitting `closure-dispositions.py` (a formal gate with 14 selftest cases, R23-02/R24-02; capability in `SCORECARD.md:687`).
- Sibling boundaries remain strictly read-only: `corpus/claim-ledger.sh:599-601` restricts sibling `*-shokunin/*` path checks to existence (`[[ -e ]]`), never reading content.
- Tool claims do not imply credential capability: R21-01 (`corpus/op-ref-probe.sh --dotenv-bytes`) executes synthetic fixtures under `env -i` with scratch `HOME`/`XDG` without account, session, or ref resolution (`SCORECARD.md:684`, `SKILL.md:760-763`).

## Affected Axes
- **operability**: Callers relying on the plan's `KAGI_HOST_ROWS=run` contract have host checks silently skipped; correcting the documented caller interface restores safe invocation semantics.
- **calibration**: Reconciles gate vs helper boundaries across `SKILL.md`, `PROVINCE.md`, and `SCORECARD.md` without perturbing pinned membership digests.
- **freshness**: Preserved; normalizer regexes, TSV capture digests, and inrow classifications remain untouched.

## Proposed Move
One bounded synthesis:
1. Append plan correction `R24-C5` to `corpus/lessons/round-24.md` documenting the deliberate switch from ambient `KAGI_HOST_ROWS=run` to the explicit `--allow-host-rows` CLI switch (preventing ambient parent shell leakage into subshells).
2. Align `PROVINCE.md:45-55` with `SKILL.md:748-752` by reclassifying `rendered-text-v1.py` and `row-identity.sh` as helper scripts and adding `corpus/closure-dispositions.py` to the gate list.

## Risks
- Tool consumers reading `PROVINCE.md` for gate enumeration will see `closure-dispositions.py` added, which requires maintaining its 14-case selftest pin (R24-02).
- Does not weaken host isolation: `--allow-host-rows` remains the sole opt-in flag.

## Verification
- Target: `/home/vgpnk/Projects/shokunin/kagi-shokunin`
- Revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (frozen lane revision)
- Command: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse HEAD`
  - Exit: `0`
  - Stdout: `c5ef9e92201b6c36396301f12b23740565bf86a0`
- Command: `grep -n 'KAGI_HOST_ROWS' /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-24.md`
  - Exit: `0`
  - Stdout: `17:   KAGI_HOST_ROWS=run. An untagged row that invokes a declared host-reading`
- Command: `grep -n 'host-env-not-consent' /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh`
  - Exit: `0`
  - Stdout: `1571:  tcase host-env-not-consent    0 'HOST-SKIP c1' env KAGI_HOST_ROWS=run ALLOW_HOST=1 "$0" verify --root "$R" --claims "$R/claims-hosttag.tsv" --stamps "$R/stamps.tsv"`
- Status: `pass`
- Severity: `medium` (contract contradiction between frozen plan and code; unlisted gate in province)
- Falsifier: Invoking `env KAGI_HOST_ROWS=run bash corpus/claim-ledger.sh verify` fails to run host rows (they are `HOST-SKIP`ped), proving the plan's stated opt-in mechanism is inactive.
