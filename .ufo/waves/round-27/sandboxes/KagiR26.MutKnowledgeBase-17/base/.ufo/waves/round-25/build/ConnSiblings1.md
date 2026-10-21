# Sibling-overlap scan — kagi round-25 claims

Seat: `KagiR25.ConnSiblings1-2` | Base: `4587c61a348e4528717404a68912c373f3ef4d03`
Judged axes: calibration, operability, freshness | Read-only scan (no lane/sibling edits)
Sibling revisions: audio `0462a544`, kama `a29bb84a`, lore `01306d51`, tameshi `08175c62`

## 1. Per-lane findings

`audio-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/fixtures/measure_audio.py:33209` `channel_count == 2`, `corpus/knowledge/2026-10-12-fixture-battery.md:77` `failure_kind: "section count"`).
- (b) Lone-clone / fleet citations: none found. No citation gates (manual audit in `corpus/lessons/round-101.md:12,19`).
- (c) Release clocks: none found. 10 `recheck: on-release` rows in `corpus/SOURCES.md:9-24` (S001-S002, S005-S006, S008, S011-S015), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

`kama-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/SOURCES.md:37` `token counts`, `corpus/knowledge/serving-metrics-crosswalk.md:5`).
- (b) Lone-clone / fleet citations: none found. Gate `tools/citation-provenance.py` (`SKILL.md:396`) checks `registry/required-citations.json` via `git -C <lane> cat-file blob <rev>:<path>` (:38-50) strictly lane-local; no lone-clone or fleet-layout logic.
- (c) Release clocks: none found. 19 `recheck: on-release` rows in `corpus/SOURCES.md:13-37` (S001-S010, S013-S015, S019-S025), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

`lore-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/tools/boundary_doc_check.py:388` checks H1 heading count `h1_count != 1`, not doc numbers).
- (b) Lone-clone / fleet citations: none found. No citation gate (`support_check.py` checks intra-cluster support).
- (c) Release clocks: none found. 12 `recheck: on-release` rows in `corpus/SOURCES.md:9-38` (S001-S003, S008, S015, S018-S020, S022, S028, S030, S038), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

`tameshi-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/SOURCES.md:24,65` S013 Jest / S056 PIT).
- (b) Lone-clone / fleet citations: none found in citation gates (no citation gate). Non-citation gates `tools/registry-check.py:754-780` and `tools/mutate-and-run.sh:1110-1117,1287` implement explicit fleet-mirror and super-repo git-toplevel detection.
- (c) Release clocks: none found. 14 `recheck: on-release` rows in `corpus/SOURCES.md:13-77` (S002, S004, S005, S013, S014, S017, S018, S049-S051, S055, S060, S064, S065), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

## 2. Contested scope & reusable conventions

- Contested scope: none found. Sibling lanes explicitly yield secret/vault/credential scope to kagi (`kama-shokunin/PROVINCE.md:40,45-49,106`, `tameshi-shokunin/PROVINCE.md:18,45`, `tameshi-shokunin/tools/trace-inputs.py:308-310` dropping non-fleet `/home` reads; `audio` and `lore` refuse external domains).
- Reusable conventions to copy:
  1. Super-repo vs lane git toplevel boundary check (`tameshi-shokunin/tools/mutate-and-run.sh:1110-1117`, `pin-disposition.py:248-251`): prevents `git -C` from escaping to parent repos when classifying layout.
  2. Fleet-mirror isolation pattern (`tameshi-shokunin/tools/registry-check.py:754-780`): synthetic `fleet/` mkdtemp with symlinked sibling repos for testing layout-dependent gates.
  3. Structured citation provenance tallies (`kama-shokunin/tools/citation-provenance.py:115-124`): explicit count breakdown (`verified`, `missing`, `mismatch`, `off_ref`).

## 3. Connector synthesis proposal

- Evidence: kagi C2 operability requires layout detection for lone-clone vs fleet. Tameshi (`mutate-and-run.sh:1110-1117`) proved that walking `../` without checking `git rev-parse --show-toplevel` on sibling candidates falsely discovers super-repos or misidentifies non-repo siblings.
- Affected axes: improves operability (C2 layout classification robustness) and calibration (eliminates false fleet-present readings); zero harm to freshness.
- Proposed move: in `kagi-shokunin/corpus/claim-ledger.sh` (C2), define fleet-presence marker check: verify each expected sibling directory exists AND contains an independent git root (`git -C "$p" rev-parse --show-toplevel` equals realpath of that sibling). If any sibling fails or `../` is missing, classify as `lone-clone`.
- Risks: minimal; slight overhead of 1 git call if checking sibling toplevels.
- Verification: run `claim-ledger.sh --selftest` in isolated lone-clone scratch and fleet scratch; verify exact `CITATION_LAYOUT: lone-clone` vs `fleet` outputs.
