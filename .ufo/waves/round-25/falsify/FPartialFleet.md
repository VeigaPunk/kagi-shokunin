# FPartialFleet — C2 partial-layout falsification

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (sandbox `git rev-parse HEAD` returned this exact hash; base `4587c61a348e4528717404a68912c373f3ef4d03`). No tools installed.

Axes: operability (fleet-layout recognition); calibration (missing fleet targets remain unresolved); freshness (UNRUN, outside this C2 probe).

## Findings

- **No actionable defect found in the scoped partial-layout behavior — PASS.** The reviewed diff adds the layout classifier and lone-only classification at `corpus/claim-ledger.sh:680-721,767-772,823-832`; citations verdicts at `:1261-1276`; verify's incomplete-row aggregation at `:600-609,1222-1225`. Marker detection uses `-e || -L` for `.ufo`, `MANIFEST.json`, `MISSION.md`, `AXES.md` and excludes the lane itself from sibling matches; it checks physical and logical parents. Runtime probes below falsify the unsafe case (partial fleet incorrectly marked absent).

## Isolated runtime probes

Checkout command: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FPartialFleet-4/lane && git -C /fast/scratch/kagi-r25/FPartialFleet-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b` (exit 0, no stdout); `git -C /fast/scratch/kagi-r25/FPartialFleet-4/lane rev-parse HEAD` (stdout: exact revision above).

For each matrix run: cwd `/fast/scratch/kagi-r25/FPartialFleet-4/lane`; environment `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FPartialFleet-4/home`; argv prefix `bash corpus/claim-ledger.sh citations --root`; `--docs` was `<root>/corpus/missing.md`. Each fixture contained exactly the stated parent marker and the same three missing fleet refs (`ufo/nope.md`, `.ufo/reports/nope.md`, `kake-shokunin/nope.md`).

| Case | Exact `--root` / `--docs` root | Result |
|---|---|---|
| only MANIFEST file | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/manifest/lane` | PASS, exit 1 |
| only MISSION file | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/mission/lane` | PASS, exit 1 |
| only AXES file | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/axes/lane` | PASS, exit 1 |
| only `.ufo` regular file | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/ufo-file/lane` | PASS, exit 1 |
| only `.ufo` directory | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/ufo-dir/lane` | PASS, exit 1 |
| only broken `.ufo` symlink | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/ufo-broken-link/lane` | PASS, exit 1 |
| one `kake-shokunin/` sibling directory | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/one-sibling/lane` | PASS, exit 1 |
| symlink root, marker only in logical parent (`MISSION.md`) | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/logical-parent-marker/logical/lane` | PASS, exit 1 |
| symlink root, marker only in physical parent (`AXES.md`) | `/fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/physical-parent-marker/logical/lane` | PASS, exit 1 |

Exact argv per matrix row: `bash corpus/claim-ledger.sh citations --root <root-above> --docs <root-above>/corpus/missing.md` (run with the cwd/environment specified above). All nine stdout results were identical:
```text
UNRESOLVED corpus/missing.md:1 ufo/nope.md (ufo)
UNRESOLVED corpus/missing.md:1 .ufo/reports/nope.md (ufo)
UNRESOLVED corpus/missing.md:1 kake-shokunin/nope.md (sibling)
CITATION_GATE: BROKEN (cites=3 docs=1 unresolved=3 ephemeral=0 labeled=0)
```

True lone control argv: `bash corpus/claim-ledger.sh citations --root /fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/lone-control/lane --docs /fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/lone-control/lane/corpus/missing.md` (same cwd/environment); **PASS, exit 3**, stdout:
```text
FLEET-ABSENT corpus/missing.md:1 ufo/nope.md (ufo)
FLEET-ABSENT corpus/missing.md:1 .ufo/reports/nope.md (ufo)
FLEET-ABSENT corpus/missing.md:1 kake-shokunin/nope.md (sibling)
CITATION_LAYOUT: lone-clone fleet_absent=3 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: INCOMPLETE (cites=3 docs=1 unresolved=0 ephemeral=0 labeled=0 fleet_absent=3)
```

Isolated true-lone `verify` row (synthetic root only; no full verify/cells on the lane tree): argv `bash corpus/claim-ledger.sh verify --root /fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/lone-control/lane --claims /fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/lone-control/lane/claims-layout.tsv --stamps /fast/scratch/kagi-r25/FPartialFleet-4/partial-layout-matrix/lone-control/lane/stamps.tsv`, same cwd/environment; **PASS, exit 1**, stdout:
```text
LAYOUT-INCOMPLETE L1 exit=3 (fleet layout absent: the row could not check fleet-only evidence)
CLAIM_LEDGER: INCOMPLETE (claims=1 layout_incomplete=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)
```

Isolated candidate selftests: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FPartialFleet-4/home bash corpus/claim-ledger.sh --selftest`; **PASS, exit 0**, final stdout line: `SELFTEST: PASS (166 cases)`.

## Residual risk and verification gaps

- LSP status/references/definition/diagnostics: **UNRUN**; no `lsp` device is mounted (`read xd://lsp` returned “No such tool”). Grep was used only to locate candidate lines; runtime outputs are the behavioral evidence.
- C1 self-count and C3 release-clock freshness, public feed re-observation, and non-C2 runtime/rerouting/saturation/resume contracts: **UNRUN / out of scope**.
- These probes establish behavior for the listed one-level markers and synthetic missing citations; they do not prove that every marker-positive parent is a complete or canonical fleet. No production fleet files or gates were mutated or run.