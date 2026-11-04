# ScribeRegistry — round-34 BUILD report

## Behavior and touched surfaces

Drafted three complete single-line, eight-column registry rows and one paste-under-table paragraph, grounded in the actual lane scripts' headers, parsers, verdict implementations, data selections and selftest outputs. Source quotations and absolute path:line references are in `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/skill-registry-rows.md`.

Written artifacts only:
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/skill-registry-rows.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/ScribeRegistry.md`

No product/plan/registry code was changed or installed. Registry ownership `kagi` follows existing SKILL.md rows; it is not a code-defined owner field. Every code-derived cell has quoted source evidence; this owner convention is explicitly distinguished.

## Executed gates and outcomes

The sole authorized verification batch used cwd `/fast/scratch/hyaku/kagi-r34/ScribeRegistry`, explicitly exported `TMPDIR=/fast/scratch/hyaku/kagi-r34/ScribeRegistry/tmp`, and installed `trap 'rm -rf -- "/fast/scratch/hyaku/kagi-r34/ScribeRegistry"' EXIT` before invoking:

1. `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh --selftest` → `PREFREEZE_SELFTEST: PASS (11 cases)`, exit 0.
2. `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-description-sweep.sh --selftest` → `SELFTEST: PASS (7 cases)`, exit 0.
3. `python3 -B /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/feed-token-agree.py --selftest` → `FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)`, exit 0.

Full printed output is copied into the deliverable. All three commands ran once; no rerun, run-mode counter, lint, format, build, census or full-suite command was invoked. Fixture writes/commits were performed only by the authorized prefreeze selftest, whose inspected code asserts fixture toplevel before its first commit. No lane Git mutation was invoked.

Initial setup command (exit 0): `mkdir -p /fast/scratch/hyaku/kagi-r34/ScribeRegistry/tmp && echo OK && ls /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/ 2>/dev/null`; output `OK` and `swarm-registry.json`. This preceded the cleanup-bearing verification batch, which subsequently removed the scratch directory.

Initial registry locator command (exit 0): `cd /home/vgpnk/Projects/shokunin/kagi-shokunin && grep -n "Gate registry\\|^## \\|^### " SKILL.md | head -60 && echo "---WC---" && wc -l SKILL.md`; output located registries at 694/746 and showed 813 lines. Process deviation: this used shell grep/head and relative SKILL.md after absolute cd, rather than specialized grep and absolute file paths. The initial directory listing likewise used shell ls. Neither wrote lane-tracked files. Subsequent source reads used absolute paths and the read tool. The frozen plan was read first among lane files; scratch setup/listing ran independently in the same initial batch. Required godspeed skill was read after those initial calls rather than before them. No omitted output is represented as evidence.

## Findings and conflicts

- Authorized readings are **11 / 7 / 4**, not target **12 / 10 / 4**. Draft accurately describes inspected lane bytes; it does not attest executor changes not yet delivered/installed. Main must reconcile counts with final installed bytes using its final gates rather than silently upgrading these observations.
- Verbatim requested behavior: `reads committed bytes only`. Observed sweep uses `ROOT=.` and direct `$ROOT_ABS` filesystem reads, including citations invocation, with no Git extraction. Draft names working-tree reads instead. ExecSD independently messaged: `Delivery will retain --root working-tree reads exactly as assigned; no committed-only change (SD1–SD6 preserved). BASE extracted bytes are separate evidence. Current lane 7 cases is accurate; delivery targets 10 but not yet available.` Frozen predicates/counters were not changed.
- Assignment says `one v1 wave, 13 seats`; frozen plan says `14 seats`. No resolution claimed by this seat.
- SD6 remains the named exclusion: integrator-owned residual UNRESOLVED lines still count toward whole-sweep mismatch. They were not measured or edited here.
- Prefreeze executes caller-supplied shell commands; temporary extraction cleanup is not a command write sandbox. Feed gate imports executable `--instrument` code; no import sandbox is present. `-B` in the proposed invocation avoids Python bytecode writes without changing its parser or check semantics.
- Latest three eight-column exemplar rows are SKILL.md lines 752–754. Round-25's later three-column additions were not used as the shape.

## Out of scope and known limits

No network, vault contact, host secrets, tool install/update, another runtime, subagent dispatch, judge, commit, push, publish or deployment. No SOURCES rows, knowledge admission, C1 code, C2 relative-work case, M7 mutant, or SD6 integrator files were changed. This report is documentation evidence only, not C1/C2/C3 admission. Source line references describe inspected current lane bytes and can shift after L1 installation.

## Self-evaluation

Accuracy 4/5: observed counts and working-tree conflict are explicit; final executor bytes are unobserved. Completeness 4/5: all three rows/evidence supplied, but requested committed-only note cannot truthfully be asserted. Clarity 4/5: rows are pasteable; detailed evidence length trades concision for auditability. Actionability 4/5: install-ready shape, with counts intentionally awaiting L1's final implementation reading. Conciseness 4/5: exact source quotations and receipts make the deliverable lengthy. Overall 4.0/5. Highest-impact improvement belongs to integration: reconcile the documented final case counts and committed-only statement against installed implementation, without rewriting historical execution receipts. The user should agree these limits are material rather than omitted.
