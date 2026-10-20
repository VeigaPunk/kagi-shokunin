# SentinelHistoryInput — round 22 falsification

Axes: **calibration** and **freshness**. Scope: `corpus/revision-audit.py` history input, stamp-path handling, and read-only behavior. Read anchor: measured integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (provided by the wave); the freeze was checked by input hashes, not inferred from detached `HEAD`. The historical base `c2cab35bc92e57e39e5489bac3386db078345b3f` was not treated as this wave's tree.

Observed hashes (the first four match their entries in the integration manifest):

- `corpus/revision-audit.py`: `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977`
- `corpus/stamps.tsv`: `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29`
- `corpus/lessons/round-22.md`: `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4`
- `plans/round-22.md`: `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06`
- `.ufo/waves/round-22/integration-manifest.json`: `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`
- `.ufo/waves/round-22/falsify-spec.json`: `72cea81e618423b2530f5af3197cf458754b791a8af747ba7a485fcf32d50a5a`
- `.ufo/waves/round-22/build/SafetyPaths.md`: `bdd7772dfd91fedb83a6c11d2a340a098292e4feadc7ed815097a4cd047c1395`

## Finding — Low: stamp rows can fingerprint root-local Git metadata

**Exploit path:** A party able to change the current stamps table can add a root-relative record for a regular file in the selected repository's Git administrative metadata. In a temporary fixture, the exact expected fingerprint produced exit 0 with one `ADDED` member; a wrong digest produced exit 1 with `STALE`. The auditor did not return file bytes. No literal fixture payload or path is retained here.

**Evidence:** `parse_path()` (`revision-audit.py:67–81`) rejects traversal, absolute, drive-prefixed, and backslash forms. `open_regular_at()` (`:142–204`) opens descriptor-relative with no-follow checks and rejects symlink components and cross-device paths. Those protections prevent the tested out-of-root paths. However, `audit()` checks historical rows against the historical regular-file inventory (`:350–354`) but fingerprints every current row (`:363–377`); it does not exclude repository administrative metadata or otherwise require a current row to name a worktree file. A fixture probe showed the status difference above, with no change to the metadata file.

**Impact:** Root confinement holds, and no raw content is emitted. Nevertheless, a caller able to supply rows and observe audit results gets a digest-equality oracle for files inside the selected root, including local Git metadata (and potentially other untracked files). Exploitation requires control of the current stamp input and access to the resulting status; no real secret or host file was accessed.

**Smallest remediation:** Reject stamp paths whose first component names Git administrative metadata. If the intended contract is strictly “worktree files,” validate current rows against an explicit worktree-file inventory instead of opening any regular file under the root. Add the fixture probe as a regression if this boundary is tightened.

## Finding — Low: a SHA-256 commit prefix passes full-ID validation

**Exploit path:** In a SHA-256 repository, pass `--history` a 40-hex prefix of an existing 64-hex commit ID. The frozen auditor accepts it as a full ID, although it is only a Git abbreviation.

**Evidence:** `FULL_OID` (`revision-audit.py:18–20`) allows both 40 and 64 hex characters without knowing the repository's storage format. `parse_history()` (`:255–260`) checks that Git resolves the argument to a commit, but does not compare it with the canonical full object ID. Against the same frozen auditor hash listed above in a fresh SHA-256 fixture, both `--history <64-hex commit id>` and `--history <first 40 hex of that ID>` exited 0 with `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=0 invalid=0)`. The prefix value is omitted; no production repository was queried.

**Impact:** The accepted value does not fulfill the explicit full-object-ID contract. A prefix is not a stable full identifier as the object database changes; at minimum, this admits noncanonical freshness evidence and can later make the same audit input ambiguous/unavailable.

**Smallest remediation:** Determine the repository's storage object format and require exactly 40 hex digits for SHA-1 or 64 for SHA-256 before lookup, or resolve to the canonical full commit ID and require exact case-normalized equality with the supplied argument.

## Exercised defenses and limits

- `python3 corpus/revision-audit.py --selftest`: **exit 0**, `REVISION_AUDIT_SELFTEST: PASS (cases=11 failed=0)`. This exercised clean, duplicate historical/current IDs, dropped member, stale/missing, malformed row, traversal, symlink-parent, FIFO, and option-history cases.
- Earlier temporary-repository probes: **17/17 assertions passed**. Full 40-character IDs in a SHA-1 repository (including uppercase) were accepted; an 8-character abbreviation and revision expression returned exit 2 with `HISTORY-INVALID`; missing IDs and full IDs naming tree/blob/tag objects returned exit 2 with `HISTORY-UNAVAILABLE`. A valid SHA-256 repository accepted full 64-character IDs in lowercase and uppercase. **Supplemental correction:** a 40-hex prefix of a SHA-256 commit was also accepted; see the finding below. Option-looking `--history` values returned exit 2 (`HISTORY-INVALID` for the assigned value; argparse rejected the separated option form); the pre-existing output sentinel stayed byte-identical.
- Relative traversal, absolute, drive-prefixed, and backslash path forms returned exit 2 with `PATH-ESCAPE`; parent- and final-component symlinks returned exit 2 with `PATH-ESCAPE`. These were fixture-only paths; no outside-root data was read.
- Before/after fixture snapshots included `.git/index`, `.git/config`, file bytes, sizes, modes, and write timestamps. They remained unchanged through the audit calls. Synthetic global/system-config and alternate-index decoys also remained unchanged; the `GIT_TRACE` decoy was not created. The probe process used a temporary `HOME`; the implementation strips inherited `GIT_*` environment and sets `GIT_CONFIG_NOSYSTEM`, `GIT_CONFIG_GLOBAL=/dev/null`, `GIT_OPTIONAL_LOCKS=0`, and `GIT_NO_LAZY_FETCH=1`. No host-private paths, services, accounts, or credentials were touched.
- The embedded selftest's option-history check calls `audit()` directly; the separate fixture CLI probes above covered argument parsing. No race stress was run; descriptor traversal and fixed argv were reviewed statically.

No implementation edits or installations. No builds, lint, or formatters run. If the root-local metadata boundary is remediated, rerun the revision-audit selftest and the new isolated boundary regression after integration; no other verification is requested by this read-only subtask.

Report: `.ufo/waves/round-22/falsify/SentinelHistoryInput.md`