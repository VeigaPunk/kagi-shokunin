## Round 41 (2026-11-05) — expect-journal gate (C1), rendered-text-v1 source grounding (C2)

- Watchdog launch line for this round, verbatim from the fleet watchdog log
  (`/home/vgpnk/Projects/shokunin/.ufo/watchdog.log`, grep `kagi round=41`; the lane tree has no
  `.ufo/watchdog.log` of its own — `ls kagi-shokunin/.ufo/watchdog.log` → no such file or directory):

  ```
  2026-11-05T12:05:41-03:00 launch kagi round=41 pgid=3037435 driver=hyaku-inline attempt=1
  ```

  No `complete kagi round=41` line exists yet at the time of drafting; the L1 appends the completion line
  from the same log when the round closes (`⟨SLOT: completion line⟩`).
- Predeclaration `5142b52` — the frozen plan (`plans/round-41.md`), the two frozen counters
  (`plans/round-41-c1.sh`, `plans/round-41-c2.sh`), the controls runner (`plans/round-41-controls.sh`) and
  the measured BASE receipts all landed in that one commit (`git log --oneline -- 'plans/round-41*'` lists
  `5142b52` only; there is no plan-alone revision this round). Claim BASE
  `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`; round-40 landed state (the positive control P0 of C1)
  `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`; round-40 claim BASE
  `6cc8850dfc5757927699e5a53a876f47c8df21aa`.
- C1 calibration, BASE **0** → target **4**: `bash plans/round-41-c1.sh` reads 0 at BASE (no gate file at
  `5142b52`; receipt `.ufo/waves/round-41/controls/c1-control-no-gate.txt` → `0`; the blanket-refuse and
  blanket-accept controls also read 0). The gate `corpus/expect-journal.sh` referees ledger-expectation
  changes against a migration journal (R1 `UNJOURNALED`, R2 `OLD_MISMATCH`/`COMMAND_MISMATCH`/
  `NEW_MISMATCH`, R3 `NOT_LITERAL`, R4 warn-only `WARN ORPHAN`), so a loosening is told apart from a
  migration. Candidate reading `⟨SLOT: c1 candidate reading⟩`.
- C2 freshness, BASE **1** → target **3**: `bash plans/round-41-c2.sh` reads 1 at BASE
  (`.ufo/waves/round-41/controls/c2-base-19025d9.txt` → `1`; the superseded-id decoy control reads 2).
  The `rendered-text-v1.py` Sources paragraph is re-grounded on S095 (re-opened 2026-11-05, byte-identical
  to the round-40 capture) and S097 (the `str.isspace()` definition, Python 3.15.2 `stdtypes`); S098
  (UTS #18 `White_Space`) is rejected — `str.isspace()` accepts U+001C–U+001F, which `White_Space` does
  not, and the served page carries no literal `\p{White_Space}`. Candidate reading
  `⟨SLOT: c2 candidate reading⟩`.
- Sources opened this round: S097 (tier A, docs) admitted; S098 (tier A, spec) rejected with its flip
  condition; S095 re-opened and unchanged. Scout receipts under
  `.ufo/waves/round-41/build/K41ScoutSources/`, capture bodies to be copied to
  `.ufo/waves/round-41/capture/`. Registry rows touched old → new: `⟨SLOT: rows-touched table⟩`.
- Wave `build` (11 seats: executor 2, scout 1, scribe 2, connector 1, reviewer 2, critic 1,
  mutation-tester 1, labrat 1; attack share 5/11 = 45 %; the planner seat is the L1, not a spawned seat).
  Seat receipts under `.ufo/waves/round-41/build/<seat>/`.
- Routed to round 42: the C3 counter defect (M40-9, M40-10, M40-17); the gate-selftest scratch default
  `${TMPDIR:-/tmp}` in `corpus/anchor-pins.sh:37`, `corpus/claims-declared.sh:37`,
  `corpus/prefreeze-control.sh:94` and `:274`, `corpus/self-description-sweep.sh:226`,
  `corpus/surface-census.sh:275`; the round-40 report amendment (must be an appended erratum); the
  journal gate's row-deletion blind spot (reviewer attack A6); and the plan §C1 existing-gate-control
  sentence that overstates F4 acceptance.
- Round 41 verdict (L1 reading, for the operator): `⟨SLOT: C1 / C2 verdict and round verdict⟩`.
