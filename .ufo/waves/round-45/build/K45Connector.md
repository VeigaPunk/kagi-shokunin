# K45Connector — Sibling-Overlap Scan & Proposal Synthesis (Round 45)

**Role:** UFO-FSD Connector | **Lane:** `kagi-shokunin` | **Revision:** `307fb50da825d6e6f2b5c7981c71556d35611142` (BASE `0d0192f63eb5e49826d75af1e5293004dc691a18`)
**Axes:** calibration, coverage, freshness

---

## 1. Sibling-Overlap Scan Findings

### (a) Claim C1 (Plan-to-Manifest Bijection Gate)
A fleet-wide scan across all 20 sibling lanes (`/home/vgpnk/Projects/shokunin/*-shokunin/corpus` and `plans/`) for gates binding plan claim headings (`## C<k> — <axis>:`) to a manifest identified **zero overlap**. Sibling occurrences of `manifest` belong to local test-run hashes, audio fixture probes, or package descriptors. The closest adjacent mechanism is `kasegi-shokunin`'s `corpus/instruments/claim-package-check.py` (which validates external bug-bounty claim submission packages against an `evidence-manifest/v1` schema) and `kengaku-shokunin`'s `plans/battery40/a_man.py` (which checks capture SHA256SUMS manifest views). Neither inspects internal shokunin round plans or enforces plan↔manifest bijection. The `claims-declared.sh` gate in `kagi-shokunin` remains unique across the entire fleet.

### (b) Claim C2 (ISO/IEC 11770-3 / GB/T 17901 Key Management Standards)
A fleet-wide grep for `11770`, `GB/T 17901`, and `17901` across `/home/vgpnk/Projects/shokunin/*-shokunin/corpus/knowledge` and `corpus/SOURCES.md` yielded **zero hits** in sibling knowledge files or source registries. All numeric matches in sibling repositories are incidental strace timestamps, process IDs, or hexadecimal SHA/pointer substrings (e.g., in audio benchmarks, Godot PID tables, or binary reverse-engineering artifacts). In `kagi-shokunin`, the only hit is an unopened lead note in `corpus/SOURCES.md:149` recording the round-44 disposition of staged `merge/kagi/` themes. No sibling lane holds, teaches, or cites ISO/IEC 11770-3 or GB/T 17901.

### (c) Standard Family Ownership in PROVINCE.md
A sweep across `*/PROVINCE.md` across all 21 lanes found **zero sibling lanes** claiming ISO/IEC 11770, GB/T 17901, or cryptographic key-management mechanism standards. In `kagi-shokunin/PROVINCE.md:92`, the lane claims the NIST key-management family (SP 800-57, SP 800-133, SP 800-131A) as §Core round 33. The staged ISO/IEC 11770-3 entry represents the parallel international mechanism standard adopted by GB/T 17901.3-2021, falling squarely within `kagi-shokunin`'s documented secrets/cryptographic province.

---

## 2. Hit Classification Table

| Hit Class | Lane | Path:Line | Verdict | One-line Reason |
|---|---|---|---|---|
| C1-Gate | `kagi-shokunin` | `corpus/claims-declared.sh:2` | `overlap` | Own lane: declared-axis conformance gate binding `corpus/claims-declared.tsv` to plans. |
| C1-Gate | `kasegi-shokunin` | `corpus/instruments/claim-package-check.py:2` | `adjacent` | Validates bounty submission package with R-MANIFEST; checks external bounty files, not round plans. |
| C1-Gate | `kengaku-shokunin` | `plans/battery40/a_man.py:1` | `adjacent` | Validates capture SHA256SUMS manifest views; does not bind round plan headings to manifest rows. |
| C1-Gate | `kengaku-shokunin` | `plans/battery40/l_rows.py:1` | `adjacent` | Defect ledger row accounting; does not check plan claim headings. |
| C1-Gate | `kotoba-shokunin` | `corpus/lessons/round-57.md:98` | `adjacent` | Refers to `check_plugin_manifests.py` auditing plugin descriptors, not round plan claim headings. |
| C1-Gate | `audio-shokunin` | `corpus/fixtures/measure_audio.py:49659` | `none` | Audio fixture inventory manifest; does not check plan claim headings. |
| C1-Gate | `audio-shokunin` | `corpus/live/r100-boundary/mkmanifest.py:2` | `none` | File integrity hash manifest for live run directory; does not inspect plans. |
| C1-Gate | `chousa-shokunin` | `corpus/evidence/round56/c1-gate.py:2` | `none` | Quote-span generator process confinement gate; no plan claim heading checking. |
| C1-Gate | `game-dev-2d-shokunin` | `corpus/live/r100-boundary/make_manifest.sh:1` | `none` | Checksum manifest generator for engine assets; does not bind plan headings. |
| C1-Gate | `game-dev-3d-shokunin` | `corpus/knowledge/unreal-mcp/gate/run_gate.sh:1` | `none` | Unreal MCP plugin gate; no plan claim heading checking. |
| C1-Gate | `kaidoku-shokunin` | `corpus/evidence/round-25/a3/c2/filter-true/compare.py:1` | `none` | Binary disassembly comparison script; no plan claim heading checking. |
| C1-Gate | `revenger-shokunin` | `corpus/fixtures/replay_fixtures.py:1` | `none` | Replay fixture hash list unpacker; no plan claim heading binding. |
| C1-Gate | `tabi-shokunin` | `corpus/evidence/round-13/aria/manifest.json:1` | `none` | Browser automation ARIA accessibility test manifest; no plan claim heading gate. |
| C2-Standard | `kagi-shokunin` | `corpus/SOURCES.md:149` | `adjacent` | Unopened lead note in Leads section recording round-44 disposition of staged ISO 11770 / GB/T 17901. |
| C2-Standard | `kagi-shokunin` | `corpus/knowledge/*` | `none` | 0 entries held at BASE revision (`grep -l '11770'` → 0); C2 assimilates first entry in round 45. |
| C2-Standard | Siblings (all 20) | `corpus/knowledge/*` | `none` | Exactly 0 hits for ISO/IEC 11770, GB/T 17901, or 17901 across all 20 sibling knowledge corpora. |
| C2-Standard | Siblings (all 20) | `corpus/SOURCES.md` | `none` | Exactly 0 hits for ISO/IEC 11770, GB/T 17901, or 17901 across all 20 sibling source registries. |
| C2-Standard | `audio-shokunin` | `corpus/live/r70-boundary/.../strace-h0-0.txt:293` | `none` | Incidental strace timestamp substring `.117703`; no relation to standard. |
| C2-Standard | `audio-shokunin` | `corpus/live/r89-boundary/.../stdout.bin:108` | `none` | Incidental audio signal nanosecond timestamp `...17901041`; no relation to standard. |
| C2-Standard | `game-dev-2d-shokunin` | `corpus/live/r71-baseline/.../verdicts.json:3295` | `none` | Incidental Godot process ID `179012`; no relation to standard. |
| C2-Standard | `game-dev-3d-shokunin` | `corpus/live/runs/.../child.log:52` | `none` | Incidental memory pointer address `55a2c1177062`; no relation to standard. |
| C2-Standard | `kaidoku-shokunin` | `corpus/evidence/round-41/.../envelope.json:116` | `none` | Incidental hex hash substring `...6117708c`; no relation to standard. |
| C2-Standard | `kake-shokunin` | `corpus/lessons/round-25.md:186` | `none` | Incidental commit hex substring `...17901cdc...`; no relation to standard. |
| C2-Standard | `kotodama-shokunin` | `corpus/lessons/round-14.md:33` | `none` | Incidental git blob sha substring `...17901413...`; no relation to standard. |
| C2-Standard | `revenger-shokunin` | `corpus/live/runs/round-56/LEDGER.md:8` | `none` | Incidental microsecond timestamp `.911770`; no relation to standard. |
| PROVINCE | Siblings (all 20) | `*/PROVINCE.md` | `none` | 0 lanes claim ISO/IEC 11770, GB/T 17901, or asymmetric key management mechanism standards. |
| PROVINCE | `kagi-shokunin` | `PROVINCE.md:92` | `adjacent` | Claims NIST SP 800-57/SP 800-133 (§Core r33); ISO 11770-3 is the parallel international mechanism. |

---

## 3. UFO-FSD Connector Proposal

### Evidence
1. **M45-1 / D2 Root Cause:** In round 44, landing additions were made to `LOG.md`, `SCORECARD.md`, `corpus/QUALITY.md`, `corpus/SOURCES.md`, and scripts without updating their SHA-256 hashes in `corpus/stamps.tsv`, leaving seven stamp rows out of step at BASE (`plans/round-45.md:67-75`).
2. **C2 Surface Coupling:** Landing C2 requires modifying three distinct files: `corpus/SOURCES.md` (new registry row), `corpus/source-fetches.tsv` (new capture record), and `corpus/quote-bodies.tsv` (new located quote rows). All three files are actively stamped in `corpus/stamps.tsv` (`lines 94, 106, 108`).
3. **M45-1 Red Witness:** Seat `K45ExecStampRW` built `.ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py`. If C2 lands without atomically updating `corpus/stamps.tsv`, `stamp-drift.py` immediately fails with `drift=3` (`DRIFT corpus/SOURCES.md`, `DRIFT corpus/source-fetches.tsv`, `DRIFT corpus/quote-bodies.tsv`).
4. **C1 Bijection Landing Gate:** Seat `K45ExecBijection` implemented the plan-to-manifest check in `corpus/claims-declared.sh`. When `SCORECARD.md` gains `## Round 45 — post-move`, the gate requires `corpus/claims-declared.tsv` to contain matching rows for `45 C1 calibration` and `45 C2 coverage`.

### Affected Axes
- **Calibration (improved):** Guarantees that C1's plan↔manifest bijection and the quote-location manifest remain strictly synchronized with committed metadata at landing.
- **Freshness (improved):** Enforces immediate zero-drift stamping on newly landed sources and captures, preventing regression into the round-44 M45-1 stamp-drift defect.
- **Coverage (preserved):** Allows clean assimilation of ISO/IEC 11770-3 (C2) without tripping stamp-drift or manifest verification errors.

### Proposed Move: Atomic Stamping & Pre-Landing Verification Contract
Bind the landing of C2's knowledge package and C1's manifest rows into an explicit atomic verification sequence:
1. **By-Document Sequential Renumbering:** Renumber staged candidate sources to the next sequential free lane IDs starting at `S100` (`plans/round-45.md:56-62`), appending to `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, and `corpus/quote-bodies.tsv`.
2. **Atomic Stamp Re-generation:** In the same commit that lands C2's registry rows and C1's `corpus/claims-declared.tsv` rows, compute and update the SHA-256 digests in `corpus/stamps.tsv` for `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, `corpus/quote-bodies.tsv`, `LOG.md`, and `SCORECARD.md`.
3. **Pre-Landing Gate Assertion:** Run `python3 .ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py .` (expect exit 0, `drift=0`) and `bash corpus/claims-declared.sh --root .` (expect exit 0, `CLEAN`) as mandatory pre-candidate landing gates before closing the round wave.

### Risks & Mitigations
- *Risk:* A partial commit updates `SOURCES.md` before `stamps.tsv`, triggering false DRIFT in automated watchers.
  *Mitigation:* Stage all landing files in scratch and apply as a single atomic tree write.
- *Risk:* Renumbering arithmetic creates ID gaps between S099 and S159/S170.
  *Mitigation:* Renumber by document strictly to `S100` (for S159) or `S100..S103` (for S170..S173), following the plan's explicit non-arithmetic contract.

### Verification
- Run `python3 .ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py /home/vgpnk/Projects/shokunin/kagi-shokunin` → exit 0, `STAMP_DRIFT: rows=123 drift=0`.
- Run `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claims-declared.sh --root /home/vgpnk/Projects/shokunin/kagi-shokunin` → exit 0, `CLAIMS_DECLARED: CLEAN`.
- Sibling overlap verified: 0 conflicting gates, 0 conflicting knowledge entries, 0 conflicting PROVINCE claims across all 20 fleet siblings.
