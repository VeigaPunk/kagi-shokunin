# K41CriticClaims — report (round-41 pre-scoring falsification)

Verdicts on the frozen claims and controls of plans/round-41.md. Full detail:
`build/K41CriticClaims/critic.md` (verdicts), `evidence.txt` (commands+outputs), `notes.md`.
Executed at sandbox clone of 5142b52 (`rev-parse --show-toplevel` asserted); lane untouched;
HEAD confirmed 5142b52; C2 worktree inputs verified byte-identical to 19025d9. Tooling installs: none.

- (a) No-work readings honest and reproduced: C1=0 (rc 0; file-absence short-circuit — trivially
  reached, NOT a do-nothing verify control: the existing verify in the gate role also reads 0 since
  it accepts all four forgeries per its own ERE/last-line contract, claim-ledger.sh:26-28;
  discrimination rests on target 4 + P0, fail-closed), C2=1 (rc 0; selftest PASS cases=22).
  DEFECT found: `plans/round-41-controls.sh` "C2 BASE N=" runs in the working tree with no commit
  pin — post-landing it will print the candidate's N=3 into a receipt labeled BASE(1).
  Route: build that control from `git archive 19025d9` into scratch (only $RTV1 is overridable;
  SOURCES.md/source-fetches.tsv/find are cwd-relative).
- (b) P0 (6f1588c) fair legitimate state: ledger diff vs 6cc8850 is exactly six expect-cell changes
  (R13-01, R21-02, R24-06, R31-02, R33-02, R34-03; commands/exit/timeout equal), journal (identical
  at 6f1588c and 5142b52) has exactly those six migrations, R1/R2 violations = 0, all 12 literals
  pass frozen R3 (plain python over git-show bytes; gate not run). F4's rebound constant matches
  R24-06's P0 expect.
- (c) R3 refuses two historical legitimate migrations if replayed as future expects (named):
  round-24 R13-03 CELL_AUDIT `cells=[0-9]+ … host_skipped=[0-9]+` (21 bare metacharacters) and
  round-25 R11-08 CITATION_GATE `cites=[1-9][0-9]* … ephemeral=0` (no trailing $). All other changed
  expects across all twelve committed journals are literal and R3-clean, including all six round-40
  migrations the kill rule protects. Calibration intent, expressible for exact-match intents — not
  admission-blocking; gate author must expect it to bite on count-summary patterns.
- (d) Degenerate paragraph reaches 3 — measured with the frozen counter itself (rc 0):
  `Sources (degenerate falsification probe): S095 S097. Frozen quote: "Matches Unicode whitespace
  characters (as defined by` — (a) by name-drop (superseded-set membership is the only registry
  link), (b) quote substring + binding independent of the paragraph (.ufo/waves/round-40/capture/
  S095.body sha == col-10 ef2d8abe…, locate rc 0), (c) PASS. Honest ceiling: C2 certifies citation
  shape, one frozen quote substring and a body binding, not grounding — the disclosed §C2 ceiling
  (sentence-level grounding = K41ReviewDocs). Note: (b)'s locate is hard-coded to the lane copy,
  not $RTV1.
- (e) Separable: C1 reads only the gate + claim-ledger.tsv/journal at pinned commits (6cc8850,
  6f1588c) + scratch; C2 reads rendered-text-v1.py, SOURCES.md, source-fetches.tsv, S095.body.
  Intersection ∅ (claim-ledger.tsv is C1-only). Empirical: C1 counter output byte-identical with
  the three C2 files present vs moved away (gate absent and accept-all stub, 4/4 → `0` rc 0).
  C1 verifies without C2 landing: confirmed.
- (f) Kill rules: (1) C1 "any control reads above 0" scopes to C1's three controls only — settled by
  §C2's "No-work control at BASE 19025d9: N = 1" (controls above 0 are expected elsewhere).
  (2) C1 "six migrations refused at landing" is vacuous unless the landing gate runs with
  --base-ledger from 6cc8850 — settled by R1's "differs from the base" + the counter's frozen BASE;
  record this interpretation in the round report. (3) C2's "below 22 cases" is a real threshold the
  counter does not measure (BASE sits exactly at 22) — landing verifier must record the count.
  (4) C2 "any binding fails" is settled by the counter predicate itself. Nothing admission-blocking.

Checks for the main agent: no builds/tests to run for this seat; the three routed items above go to
the L1/planner and landing verifier. Scratch sandbox /fast/scratch/hyaku/kagi-r41/K41CriticClaims
deleted before yield.
