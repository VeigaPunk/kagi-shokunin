# XCiteLayout — round-25 C2 build report

Revision: `4587c61a348e4528717404a68912c373f3ef4d03` (frozen BASE).

Patch: `.ufo/waves/round-25/patches/XCiteLayout.patch`; it changes only `corpus/claim-ledger.sh` and `corpus/claim-ledger.tsv`.

## Behavior and design

- Fleet layout is snapshotted after `--root` validation: `$ROOT/../.ufo` must be a directory **and** `$ROOT/../MANIFEST.json` a file. This follows the round-25 marker exactly; the manifest prevents a lane-local `.ufo` alone from implying the fleet checkout. The citation header names whichever marker is absent.
- Lone-layout unresolved `ufo` (including `.ufo`) and `sibling` citations print `FLEET-ABSENT` and count `fleet_absent`; only those misses yield `CITATION_GATE: INCOMPLETE`/exit 1. Any unresolved local citation or ephemeral URI retains `BROKEN` precedence; fleet-layout fleet misses remain `UNRESOLVED`. Clean citations append `fleet_absent=0`.
- `[fleet]` rows pass existing static policy checks, then lone-layout `verify`/`cells` skip them before execution and append `layout_skipped` after the existing summary fields. Fleet-layout rows use the normal claim path.
- Selftest fixtures are synthetic roots under its temporary directory: the lone parent lacks both markers; the fleet parent has both. Fourteen new cases cover headers, ufo/sibling and local misses in both layouts, incomplete/broken/clean verdicts, and `[fleet]` skip/run in verify and cells. R11-09 is updated to 165 (`151 + 14`); that is a static count, not an executed result.

## Evidence and commands

- Clone command: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/XCiteLayout/lane && git -C /fast/scratch/kagi-r25/XCiteLayout/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03` — completed, exit 0, empty stdout.
- Diff command: `git -C /fast/scratch/kagi-r25/XCiteLayout/lane -c diff.mnemonicPrefix=false diff -- corpus/claim-ledger.sh corpus/claim-ledger.tsv` — exit 0; stdout excerpt: `2 files changed, 106 insertions(+), 32 deletions(-)`. This generated the attached patch; it is not an apply check.
- Selftest command (cwd: `/fast/scratch/kagi-r25/XCiteLayout/lane`): `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XCiteLayout/home bash corpus/claim-ledger.sh --selftest` — **UNRUN** (seat contract prohibits tests during the editing wave); no PASS line or exit code observed.
- Intended baseline commands (cwd: fresh BASE clone at `/fast/scratch/kagi-r25/XCiteLayout/before/lane`): `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XCiteLayout/before/home bash corpus/claim-ledger.sh citations` and `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XCiteLayout/before/home bash corpus/claim-ledger.sh verify` — **UNRUN**, no output/exit codes.
- Intended post-patch commands (cwd: `/fast/scratch/kagi-r25/XCiteLayout/lane`): `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XCiteLayout/home bash corpus/claim-ledger.sh citations` and `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XCiteLayout/home bash corpus/claim-ledger.sh verify` — **UNRUN**, no output/exit codes.
- Round-25 plan `plans/round-25.md:50-53` records the expected baseline (`unresolved=88`, `FAIL R11-08`) and target (`unresolved=0 fleet_absent=88`, `LAYOUT-SKIP R11-08`, `layout_skipped=1`); those are plan values, not measurements from this seat.
- LSP: unavailable in the mounted tool inventory; no LSP response was treated as evidence. No tools/packages installed.

## Pointers and risks

- `corpus/claim-ledger.sh:348-352` layout marker; `:558-562` fleet-row skip; `:696-704` citation layout header; `:760-763` FLEET-ABSENT classification; `:1155-1160`, `:1183-1189`, `:1193-1204` summaries/verdict precedence.
- Selftest fixtures/cases: `corpus/claim-ledger.sh:1223-1234`, `:1411-1429`, `:1692-1705`. Ledger expectations: `corpus/claim-ledger.tsv:22-23`.
- Risk/blocker: all requested acceptance checks remain unrun by wave policy, including patch application and the 165-case selftest. Main must run its post-integration gate before treating the new expected count or summaries as exercised evidence.