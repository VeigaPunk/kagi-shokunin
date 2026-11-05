# K38ExecQuote — round 38 build wave — scoped findings

Seat: K38ExecQuote, 2026-11-05. Full report with all commands, exit codes and verbatim
outputs: .ufo/waves/round-38/build/K38ExecQuote/report.md

TOP-LINE VERDICT: C1 REPRODUCED.

Evidence (all executed this session, fresh `git archive b944735` extraction in scratch):
- C1 gate: `python3 -I -B corpus/quote-locate.py` -> `QUOTE_LOCATE: CLEAN located=5 rows=5`, exit 0.
- C1 counter: `bash plans/round-38-c1.sh` -> `5`, exit 0.
- Claim BASE a916f4a (counters copied in, instruments absent): c1 -> `0` rc=0, c2 -> `0` rc=0.
- Forgery/no-work controls (gate over predeclaration 8c48b7df, and direct reruns):
  c1_nowork 0 (context: no manifest at the predeclaration; a candidate-tree rerun prints 5
  because the manifest exists there — documented, not a control failure), c1_full 5,
  c1_forge_quote 4, c1_forge_bytes 4, c1_forge_registry 4, c2_nowork 0, c2_positive 3.
  All as frozen in plans/round-38.controls.tsv.
- Prefreeze gate: `bash corpus/prefreeze-control.sh run --base 8c48b7df71066b969ac078205b5ed18cf5f53286
  --controls plans/round-38.controls.tsv` (lane root, TMPDIR/HYAKU_SCRATCH in scratch)
  -> 7 OK rows, `PREFREEZE: CLEAN (controls=7 mismatch=0)`, exit 0 — verbatim match to the
  frozen receipt .ufo/waves/round-38/controls/prefreeze-gate.txt content.
- Independent recomputation (sha256/byte count/byte search, not the gate): all 5 rows
  S089-S093 — body sha256 equals source-fetches col 10, byte count equals col 11,
  manifest quote equals col 13, quote found at the declared offset (726/729/1583/21886/21886,
  first occurrence = declared offset), quote verbatim in the registry row. Zero disagreements.
- Freeze integrity: instruments, controls, plans scripts and both capture directories are
  byte-identical between the predeclaration and the candidate; candidate deltas are
  additions-only (manifest and plan file created; fetches +S092/S093 rows; SOURCES.md +2 rows).
  Kill rule "capture body changed after predeclaration" not triggered.
- C2 side-observations: counter `3` rc=0 at the candidate; BASE 0; c2_nowork 0; c2_positive 3.

Risks/notes: none new. Two instrument-run stumbles were self-caught and re-run cleanly
(a BASE/scratch self-copy collision before any measurement; c2_positive must call the counter
directly, not as a controls-runner mode). No tools installed; pacman untouched; no lane or git
mutation; scratch deleted after the report was written.
