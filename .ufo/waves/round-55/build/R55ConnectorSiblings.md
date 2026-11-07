# R55ConnectorSiblings — Sibling-lane overlap scan and cross-lane synthesis (round 55)

Measured revision (BASE): `ebe095857a734caf5efdd7bd776feb22b4e23972`  
Measured revision (CANDIDATE, = lane HEAD): `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`  
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch master)  
Fleet root: `/home/vgpnk/Projects/shokunin`  
Receipts: `.ufo/waves/round-55/build/R55ConnectorSiblings.d/` (`c1-base.txt`, `c1-candidate.txt`, `c2-base.txt`, `c2-candidate.txt`, `scan.sh`, `scan-out.txt`)  
Scratch: `$HYAKU_SCRATCH/kagi-r55/R55ConnectorSiblings/` (`/fast/scratch/hyaku/...`)  

Both commit hashes above were verified with:
`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse ebe095857a734caf5efdd7bd776feb22b4e23972 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`
and are written literally without unexpanded subshells.

Receipts in `.ufo/waves/round-55/build/R55ConnectorSiblings.d/`:
- `c1-base.txt`: `C1_USEDBY_GAP: value=25 gap=25 citations=88 entries=37 guard=1 (bad=none)`
- `c1-candidate.txt`: `C1_USEDBY_GAP: value=0 gap=0 citations=90 entries=37 guard=1 (bad=none)`
- `c2-base.txt`: `C2_ISO_CURRENT: value=0 amd=0 recheck=0 guard=1 (bad=amd:a-rows=0,recheck:S101-count-2-stated-1)`
- `c2-candidate.txt`: `C2_ISO_CURRENT: value=2 amd=1 recheck=1 guard=1 (bad=none)`
- `scan.sh` and `scan-out.txt`: reproducible fleet-wide sweep across all 20 sibling repositories.

---

## 1. Findings table: sibling-lane evidence

A systematic scan was executed across all 20 sibling repositories (`/home/vgpnk/Projects/shokunin/*-shokunin`) covering `corpus/SOURCES.md`, `corpus/*.sh`, `corpus/knowledge/*.md`, `tools/`, `quality/`, and `PROVINCE.md`.

| Target Area | Repo | Path & Line | Nature of Match / Citation | Ground / Evidence Summary |
|---|---|---|---|---|
| (a) ISO/IEC 11770-3 / key-management ground | `tsukuroi-shokunin` | `corpus/knowledge/kernel-taint-r27.md:33` | Explicit route to `kagi` under `ADJ-02` | Line 33 states: *"Trusting it is a key-management decision for the operator; the private key is credential material and is never read (ConnSiblingOverlap: kagi's ground, route under ADJ-02)."* Explicit acknowledgment that cryptographic key management belongs to `kagi`. |
| (a) ISO/IEC 11770-3 / key-management ground | `kengaku-shokunin` | `corpus/SOURCES.md:233` | Non-overlapping evaluation benchmark | Row S218 names Terminal-Bench 2.0 OpenSSL self-signed certificate task definition (`task.toml`). Evaluates tool command execution in evaluation harness; does not hold or track cryptographic key-management standard status. |
| (a) ISO/IEC 11770-3 / key-management ground | `kagi-shokunin` | `PROVINCE.md:92` | Core lane ground (§Core r33 / r45) | `kagi` claims NIST key-management standards (SP 800-57, SP 800-133, SP 800-131A) as Core round 33, and assimilated ISO/IEC 11770-3 in round 45 as the parallel international mechanism standard. |
| (a) ISO/IEC 11770-3 / key-management ground | Sibling corpora (all 20) | `*/corpus/SOURCES.md`, `*/corpus/knowledge/*` | Zero hits | Exactly 0 matches for `11770` across all sibling registries and knowledge files. (Numeric hits in audio traces, git hashes, or mori index segments are incidental substrings). |
| (b) Body citation scanning vs used-by gates | `mado-shokunin` | `quality/counters/c3-r56-used-by.py:167-171, 217-223, 271-285` | Full AST-style body token scan with allowlist | Scans prose outside code fences (`outside_fence_lines`) for `(?<![A-Za-z0-9])S[0-9]{3}(?![0-9])`. Checks `missing` = entries citing `S` where `entry` is not in `usedby[S]`. Uses an external frozen allowlist (`frozen-tables-v2.json`) with `line_sha` verification to exempt 24 legacy name-only mentions without modifying knowledge files. |
| (b) Body citation scanning vs used-by gates | `kagi-shokunin` | `corpus/sources-census.sh:130-175`, `plans/round-55-c1.sh:7-19` | In-file `cites:` header with `SC_BODY_CITE` gate | Checks every token outside fences against row IDs. Detects any unlisted citation as `SC_BODY_CITE` unless recorded on either `source:` or `cites:`. Requires `cites:` rows to list the entry in their `used-by` cell, eliminating all 25 base gaps. |
| (b) Body citation scanning vs used-by gates | `chousa-shokunin` | `tools/research-gate.sh:3529-3575, 3763` | `source:`-line-only verification | `metadata_registry_check_source` inspects only `source_value` (lines starting with `source:`). Emits `META_SOURCE_USEDBY_MISSING` if `used-by` omits entry, but completely ignores body citations. |
| (b) Body citation scanning vs used-by gates | `tameshi-shokunin` | `.ufo/evidence/kaika-round-1/sources-census.sh:8` | Forward-only check | Checks only `H4: mined rows whose used-by file does not contain the row id`. Does not check reverse reciprocity (whether knowledge bodies mention unrecorded rows). |
| (b) Body citation scanning vs used-by gates | `kengaku-shokunin` | `.ufo/waves/round-68/w2/SiblingOverlap.md:226-248` | Analysis of kagi vs fleet census | Notes that running `kagi`'s local validator against `kengaku`'s registry triggers 443 findings (including 163 `SC_USEDBY_NOCITE` errors), because the fleet `scripts/sources-census.sh` only enforces `E11` (file existence) rather than citation reciprocity. |
| (c) Entry `recheck:` replayed against captures | `mori-shokunin` | `corpus/knowledge/journal-reach-r49.md:8`, `.ufo/waves/round-49/w1/Mo49ScoutS351.md:45` | Unenforced command syntax | Entry carries `recheck: 180d — curl -s <URL> \| grep -c SystemMaxUse → 5`. Sibling scout `Mo49ScoutS351.md:45` explicitly observes: *"the counter does not check the entry's `recheck:` contents, so the 'no MESSAGE grep' element is enforced by nothing mechanical. It rests on the reviewers."* |
| (c) Entry `recheck:` replayed against captures | `kagi-shokunin` | `plans/round-55-c2.sh:25-33, 86-145` | Executable parse and capture replay | Parses backticked pipeline `` `curl <args> '<URL>' \| grep -c '<Q>'` -> <N> ``, resolves `URL` to source row in `quote-bodies.tsv`, validates capture digest against `source-fetches.tsv`, and executes line-counting logic (`grep -c Q body == N`) directly on committed capture bytes. |
| (c) Entry `recheck:` replayed against captures | `revenger-shokunin` | `reports/round-100/c1_k_admit_counter9.py:851-857` | Syntax regex check only | `check_recheck_cmd` checks that `recheck:` matches `RECHECK_CMD_RE` or `RECHECK_VERB_RE`. Does not parse arguments or replay against captures. |
| (c) Entry `recheck:` replayed against captures | `chousa-shokunin` | `.ufo/waves/round-44/w2/W2ScribeRow.md:115`, `tools/research-gate.sh:3782-3838` | Command stripped; cadence-only gate | Rejects embedded curl commands as violating `NF=13` / census `E09`. Strips recheck to bare interval (`365d`). `research-gate.sh` only checks scheduling dates (`scheduled`, `unscheduled`, `overdue`). |
| (c) Entry `recheck:` replayed against captures | `kama-shokunin` | `tools/round83-pin-rechecks.py:26-36` | Register-driven quote verification | Re-derives verdicts by verifying quote occurrences in newest extracts from TSV registers (`pin-recheck-rows.tsv`). Does not parse or execute shell pipelines from markdown entry headers. |

---

## 2. Overlap verdict for C2 ground (ISO/IEC 11770-3)

**Verdict:** `owned` (exclusively owned by `kagi-shokunin`).

### Justification
1. **Zero sibling claims or citations:** A fleet-wide audit across all 20 sibling repositories confirmed that no other lane defines, teaches, cites, or captures ISO/IEC 11770-3 or GB/T 17901. All matches for `11770` in sibling directories are incidental noise (e.g. audio microsecond timestamps in `audio-shokunin`, git pack indices in `mori-shokunin`, or scratch directories).
2. **Explicit sibling boundary routing:** In `tsukuroi-shokunin/corpus/knowledge/kernel-taint-r27.md:33`, when discussing DKMS module signing keys, tsukuroi explicitly routes key-management decisions away from itself: `(ConnSiblingOverlap: kagi's ground, route under ADJ-02)`.
3. **Formal province grounding:** In `kagi-shokunin/PROVINCE.md:92`, the lane formally established cryptographic key-management standards as Core in round 33 (NIST SP 800-57, SP 800-133, SP 800-131A) and round 45 (ISO/IEC 11770-3). Round 55's C2 advancement (naming ISO/IEC 11770-3:2021/Amd 1:2025 and validating S113/S114) deepens kagi's existing exclusive custody without touching any sibling domain.

---

## 3. Two cross-lane proposals / patterns

### Pattern 1: Dual-tier citation registry contract (synthesized from Mado and Kagi)
- **Sibling Evidence:** `mado-shokunin/quality/counters/c3-r56-used-by.py:167-285` vs `kagi-shokunin/corpus/sources-census.sh:130-175`.
- **Pattern:** Reconciles body citation discovery with dependency purity. Knowledge entries often mention historical, deprecated, or neighbouring source IDs in comparative prose (e.g., "supersedes S049", "unlike S012").
  - Kagi's approach adds an in-file `cites:` line to the entry frontmatter and demands every mentioned ID list the entry in `used-by`. While clean within a single repository, when tested against other lanes (`kengaku-shokunin/.ufo/waves/round-68/w2/SiblingOverlap.md:231`), it caused 163 `SC_USEDBY_NOCITE` errors.
  - Mado's approach scans body tokens outside code fences (`outside_fence_lines`) but maintains an external pinned allowlist (`frozen-tables-v2.json`) with line SHA-256 hashes for legacy/incidental mentions, keeping `used-by` strictly reserved for primary consumers.
- **Synthesis:** An ideal fleet standard combines both:
  1. Primary support cited on `source:` -> listed in `used-by`.
  2. Substantive cross-references cited on `cites:` -> listed in `used-by`.
  3. Incidental/historical mentions exempted via a hash-pinned allowlist table, avoiding registry bloat and false dependency coupling.

### Pattern 2: Hermetic offline `recheck:` command replay against committed captures (synthesized from Mori and Kagi)
- **Sibling Evidence:** `mori-shokunin/corpus/knowledge/journal-reach-r49.md:8`, `mori-shokunin/.ufo/waves/round-49/w1/Mo49ScoutS351.md:45`, and `kagi-shokunin/plans/round-55-c2.sh:25-33, 86-145`.
- **Pattern:** Knowledge entries frequently declare observation and recheck commands with expected counts (e.g., `curl ... | grep -c <PATTERN> -> <N>`). In Mori round 49, this syntax was documented in entry headers but admitted as unverified review-only prose (`Mo49ScoutS351.md:45`).
- **Synthesis:** Adopt Kagi's C2 verification harness as an architectural pattern across the fleet. Instead of treating recheck pipelines as unexecutable comments or stripping them due to network restrictions (`chousa-shokunin/w2/W2ScribeRow.md:115`), gates can deterministically execute the pipeline against the committed capture bytes recorded in `quote-bodies.tsv`. This provides mechanical verification of stated counting predicates without triggering network access, flakiness, or HTTP 403 blocks during gate runs.

---

## 4. Single non-obvious move (UFO-FSD connector synthesis)

### Evidence
1. `mado-shokunin/quality/counters/c3-r56-used-by.py:150-172, 271-285` establishes that scanning raw markdown bodies without AST-like code fence awareness generates false positives, and that unlisted mentions can be controlled without altering entry bodies via hash-pinned exemptions.
2. `kagi-shokunin/corpus/sources-census.sh:130-175` demonstrated that adding `cites:` to markdown frontmatter cleanly eliminates used-by gaps (25 -> 0) while keeping `source:` reserved for evidentiary support.
3. `kengaku-shokunin/.ufo/waves/round-68/w2/SiblingOverlap.md:230-248` proves that enforcing Kagi's strict reciprocity gate across the fleet causes massive breakage (443 findings, 163 reciprocity failures) because the fleet validator `scripts/sources-census.sh` enforces only `E11` (path existence on disk).
4. `kagi-shokunin/plans/round-55-c2.sh:25-33` demonstrates that entry `recheck:` commands can be verified hermetically against committed captures rather than discarded or left unverified.

### Stated contradiction
There is an unresolved contradiction across fleet lanes regarding the semantic boundary of a "citation":
- In **Kagi**, every occurrence of an `S\d{3}` token in a markdown file is treated as a dependency requiring explicit two-way registration (`cites:` + `used-by`).
- In **Mado**, incidental name mentions are structurally separated from true dependencies using an external exemption table.
- In **Chousa** and **Fleet Root (`scripts/sources-census.sh`)**, only the `source:` line is considered a citation; body mentions are completely unconstrained, and `used-by` paths are only validated for filesystem existence.

### Affected axes
- **Calibration (improved):** Eliminates silent registry drift and undocumented citations without contaminating `source:` semantics.
- **Freshness & Operability (improved):** Enables automated offline verification of `recheck:` counts without introducing external network dependencies or breaking fleet builds.
- **No harm to other axes:** Does not destabilize existing fleet validations or force immediate cross-lane migration churn.

### Proposed move
**Implement a tiered Citation-and-Recheck Adapter in `scripts/sources-census.sh` with non-fatal advisory reporting (`W05_BODY_MENTION_UNLINKED`) and offline capture verification.**

Specifically:
1. **Fence-aware token scanner:** Incorporate Mado's `outside_fence_lines` logic into `scripts/sources-census.sh` so code blocks, URLs, and diffs never trigger false citation warnings.
2. **Standardize `cites:` frontmatter:** Formally adopt Kagi's column-1 `cites:` line specification across `SOURCES-CONTRACT-v1` as the standard mechanism for secondary references.
3. **Advisory graduation:** Emit body-mention gaps as advisory warning `W05` at the fleet level, allowing lanes with strict counters (Kagi, Mado) to enforce fail-closed behavior locally while allowing other lanes (Kengaku, Chousa) to remain clean (exit 0) until ready to backfill.
4. **Hermetic recheck evaluator:** Provide an optional verification mode that resolves `curl ... | grep -c <pattern> -> <N>` commands against local capture files, bridging Mori's unenforced syntax into Kagi's verified state.

### Risks and second-order effects
- *Runtime/Execution surface:* Zero risk during standard runs since `W05` is an advisory code that does not alter exit status for clean lanes.
- *Contract surface:* Requires documenting `cites:` in `SOURCES-CONTRACT-v1` as a permitted metadata key alongside `source:`, `verified-at:`, and `recheck:`.
- *Substrate surface:* Avoids network calls entirely by evaluating pipelines strictly against committed captures.
- *Verification surface:* Prevents false positive drift and eliminates discrepancies between lane-local validators and the fleet validator.

### Verification
- Tested locally on Kagi BASE (`ebe09585...`, 25 gaps) and CANDIDATE (`348aa3b8...`, 0 gaps), reproducing exact expected values.
- Re-run via `.ufo/waves/round-55/build/R55ConnectorSiblings.d/scan.sh` yielding identical counts across all 20 sibling directories.
