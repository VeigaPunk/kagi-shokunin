# SentLayoutSkip — C2 `[fleet]` / layout-skip security and integrity review

Seat KagiR25.SentLayoutSkip-2 (sentinel, leaf). Base `4587c61a348e4528717404a68912c373f3ef4d03`. Lane tree read-only and untouched. Experiments only in `/fast/scratch/kagi-r25/SentLayoutSkip-2`: a BASE clone plus a sandbox-only prototype (`C2_MODE=strict|naive`; diff `SentLayoutSkip-2/c2-proto.diff`). `naive` = plan as written, verdict left at the BASE host-skip precedent. Verify runs used a scratch stamps file re-pinning the prototype only. No verify/cells on the real tree. No installs (bash 5.3.20, python3, jq, shellcheck 0.11.0 already present).

## Bottom line
C2 as planned (`plans/round-25.md:38-55`) lets a tag skip a row and still credit CLEAN, hides lane-local defects inside the same skipped row, and its "all 88 misses are layout" premise is false (42 are self-references). Smallest safe shape: no row-level skip; per-token classification; any layout-absent result non-CLEAN everywhere; marker-gated, containment-checked resolution; no free-text tags.

## Findings (severity · exploit · evidence · fix)

**F1 HIGH — a layout skip can end CLEAN.**
- Exploit: add `[fleet]` to any row; in a lone clone that row never runs.
- Evidence: naive, `[fleet]` on `grep -c 'SCRIPT_DIR' corpus/claim-ledger.sh` → `LAYOUT-SKIP G1`, `CLAIM_LEDGER: CLEAN (... layout_skipped=1)` exit 0 (T1). Cells citing R11-08 → `CELL_AUDIT: CLEAN (... rows_run=0)` exit 0 (T15n).
- Precedent: BASE `verify`, one `[host]` row → `CLAIM_LEDGER: CLEAN (... host_skipped=1)` exit 0 (A4); pinned at `claim-ledger.sh:1626`, `:1634`.
- Fix: layout_skipped>0 ⇒ `INCOMPLETE` exit 1 in verify and cells (T3, T15s exit 1).

**F2 HIGH — a row-level skip hides non-layout checks.**
- Exploit: `[fleet]` on R11-08 (`claim-ledger.tsv:22`) also hides every lane-local citation in that run.
- Evidence: BASE lone `citations` = 1371 cites, 67 docs; only 46 are layout-bound (F4). With `corpus/nope-r25-planted.md` planted in a lane lessons file: naive verify → `CLAIM_LEDGER: CLEAN ... layout_skipped=1` exit 0 (G1); strict verify → `INCOMPLETE` exit 1, miss never printed (G2); direct `citations` → `UNRESOLVED corpus/lessons/zz-planted.md:1 corpus/nope-r25-planted.md (local)`, `CITATION_GATE: BROKEN (... unresolved=1)` exit 1 (G3).
- Fix: never skip the row. Run citations in every layout and classify per token; the prototype's per-token branch already does.

**F3 MEDIUM — `[fleet]` is a free label; policy must gate it.**
- Exploit: any committer tags any row (T1).
- Evidence: allowlist refusal works: `[fleet]` on a non-fleet grep → `POLICY G1 reason=fleet-tag-unjustified` exit 2 (T2); untagged R11-08 → `POLICY R11-08 reason=untagged-fleet` exit 2 (T4).
- Answer: yes, refuse `[fleet]` on any row whose command is not an exact fleet-reading invocation, same mechanism as `HOST_SCRIPT_RE`/`host_free_args` (`claim-ledger.sh:174-187`). Preferred: drop tags; the row's own final line decides.
- Host/secret rows are not launderable as built: `[fleet][host]` → HOST-SKIP in both layouts (T12); `[fleet] bash corpus/drift-pins.sh` → `POLICY ... reason=untagged-host` exit 2 in both layouts (T13); `[fleet] op account list`, bash-option, metachar → POLICY exit 2 (T16–T18). The risk is ordering: a layout check ahead of host/policy, or "fleet present ⇒ run", lets host rows run.

**F4 MEDIUM — shape-based layout classing is wrong for 42 of 88 misses.**
- Evidence (A1): 88 = 31 `ufo` + 57 `sibling`. Existence-only checks against the real checkout: the 31 `.ufo/…` exist only in the fleet `.ufo`; 15 `*-shokunin/…` only in the fleet; 42 `kagi-shokunin/…` are self-references, all 42 present in the BASE lane tree (4 are dirs).
- Name dependence: lone clone named `lane/` → 88 misses (A1 BASE: UNRESOLVED 88; strict prototype: FLEET-ABSENT 88). Same-named sibling dir present, or ROOT named `kagi-shokunin/` → naive gives 46. Strict gives 88 even when ROOT is named `kagi-shokunin/`, because the marker gate also refuses self-references.
- A lane-local `.ufo/waves/lane-only/nope.md` in a lone clone → `FLEET-ABSENT` (T9b); fleet present → UNRESOLVED (T9a). The plan's "lane-local misses stay UNRESOLVED" cannot hold by shape. Selftest pin `:1631` passes only because `:1189` plants `$S/.ufo/reports`.
- Fix: resolve `<basename ROOT>/…` against ROOT in every layout. FLEET-ABSENT only for `ufo/` and `*-shokunin/` misses that still fail. Lone `.ufo/` misses get `UNVERIFIED-IN-LONE`: non-pass, never called fleet.

**F5 MEDIUM — `../.ufo` spoofing turns fleet tokens CLEAN.**
- Exploit: whoever writes the lone clone's parent creates `../.ufo` as a symlink to forged content.
- Evidence: BASE, no marker → BROKEN ×2 exit 1 (A3a); `../.ufo -> forged` → `CITATION_GATE: CLEAN (cites=2 ... unresolved=0)` exit 0 (A3b). Naive: same CLEAN (T7). Strict (`-d && ! -L`, resolution gated by it) → INCOMPLETE exit 1 (T6).
- Residual: a real forged `../.ufo` directory → `CITATION_LAYOUT: fleet`, CLEAN exit 0 (T8). Only parent-dir writers can forge it (the marker sits outside the repo). Print the resolved root in the layout line.
- Marker: never `$ROOT/.ufo`. BASE tracks 575 `.ufo` files, so `test -d` is true in every clone. The fleet root has `.ufo` (dir), `MANIFEST.json`, `shokunin.conf` (regular files): use a conjunction (existence only).

**F6 MEDIUM — resolver containment.**
- `corpus/../../../../../../etc/hostname` → BASE `CITATION_GATE: CLEAN (cites=1 ... unresolved=0)` exit 0 (A2; control exit 1). Strict: `ESCAPE ... (.. component refused)`, BROKEN exit 1 (T11).
- Committed symlink: lane `.ufo -> fake-fleet` makes a `.ufo/`-only doc (`.ufo/waves/round-25/x.md`) CLEAN in a lone clone, exit 0 in strict and naive, with `CITATION_LAYOUT: lone-clone`. The layout label does not describe what was resolved. Fix: realpath containment; refuse symlink components under ROOT and the fleet root.

**F7 LOW — pre-existing skip-as-CLEAN class; planner decision.** Host and deferred skips already yield CLEAN (A4; pins 1626/1634). C2 must fail-close all skip classes or justify the split. Selftest: lone-root cases must remove `$S/.ufo` (`:1189`). The selftest matches summaries literally (8 `CLAIM_LEDGER: CLEAN (` and 9 `CELL_AUDIT: CLEAN (` lines); a field appended before `)` breaks them.

**F8 INFO — no environment override.** A `KAGI_LAYOUT`-style knob would let a parent shell skip rows. R24 already refused env consent for host rows (`claim-ledger.sh` header); keep that rule.

## Policy checks (falsifier → what kills the mutant)
- P1 Layout verdict only from exact `bash corpus/claim-ledger.sh citations`. Falsifiers T2, T4 (exit 2).
- P2 Layout-absent ⇒ non-CLEAN everywhere. Falsifiers T3, T15s (exit 1); kill mutants T1, T15n.
- P3 No row skip; planted lane miss must print `UNRESOLVED` and exit 1 (G3 shape). UNRUN on a real implementation.
- P4 Order: policy → untagged-host → symlink → host → substrate → layout → run. Falsifiers T12, T13, T16–T18.
- P5 Marker `-d ../.ufo && ! -L ../.ufo` (+ `../MANIFEST.json` regular, non-symlink), gating resolution. Falsifier T6 (exit 1); kill mutant T7 (CLEAN).
- P6 Containment: refuse `..` (T11 exit 1) and symlink components. Mutant: the `.ufo`-only symlink doc must not be CLEAN (exit 0 today, strict and naive). Prototype fails this, so UNRUN as fixed.
- P7 Self-reference: same lone count (46) for lane-with-sibling, `kagi-shokunin/`, and strict. Prototype fails strict (88).
- P8 Fleet-present control: fleet dir present, siblings absent → R11-08 runs and FAILs, never skips (T14 exit 1, ~60 s).

## Measured (sandbox; exit codes)
- A1 BASE lone `citations` → 1 (`BROKEN cites=1371 docs=67 unresolved=88`). A2/A2b escape → 0/1. A3a/A3b spoof → 1/0. A4 host-skip verify → 0. A5 R11-08 alone, lone → 1 (`FAIL R11-08 reason=exit-mismatch exit=1 want=0`).
- Prototype, strict unless noted: T1 0(naive) · T2 2 · T3 1 · T4 2 · T5 1 · T6 1 · T7 0(naive) · T8 0 · T9a 1 · T9b 1 · T10a 1 · T10b 1 · T11 1 · T11n 0 · T12 0 · T13 2 · T14 1 · T15n 0 · T15s 1 · T16–T18 2.
- shellcheck on BASE `claim-ledger.sh`: exit 1, 100× SC2016 only.

## UNRUN
- Real-checkout fleet control (plan counting): not run; verify/cells banned there, and I did not run citations there.
- The real C2 implementation (XCiteLayout) is not in BASE; all results above are on my sandbox prototype.
- R11-09 selftest and full `verify` on the prototype: not run.
