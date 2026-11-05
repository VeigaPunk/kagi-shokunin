# K38MutInstruments — round 38 build wave: mutation test of the C1 and C2 instruments

Verdict (top line): both claims reproduce at candidate b944735 (C1 counter = 5, C2 counter = 3, do-nothing controls 0), but the instruments are not mutation-tight. Under the assignment's literal kill rule 3 of 11 mutants are killed (quote-locate 0/6, lane guard 3/5). Frozen controls plus counters kill 6 of 11. The 5 survivors (quote-locate M2, M3, M5, M6; lane guard G3) are each killed by a distinguishing input that the frozen controls do not contain. No lane file was edited; no tool was installed.

## 1. Scope and setup

- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, candidate `b944735` (verified: `git cat-file -t b944735` → commit; HEAD = b944735). The instruments were run on `git archive b944735` extracted into scratch, not on the live lane tree (the live tree has 7 dirty entries whose origin this seat did not check; untouched by this seat).
- Claim BASE `a916f4a` also extracted, with the counter and control scripts copied in (`plans/round-38-controls.sh`, `round-38-c1.sh`, `round-38-c2.sh`, `round-38-rows.py`), since those files are absent at BASE.
- Lane status before and after the seat (read-only `git status --porcelain | sha256sum`): `73aaac60f2e3be6bdf4e79e05a84c948b106ae889a340b0a14f472719d99592d` both times, 7 entries, HEAD unchanged.
- Scratch root: `/fast/scratch/hyaku/kagi-r38/K38MutInstruments`; `HYAKU_SCRATCH` set to its `hs/` subdirectory for every run. Scratch removed before yield.
- Mutants: 11 scratch copies (`m-M1..M6`, `m-G1..G5`), one change each. Each change was made with the edit tool against an exact displayed line; every copy was then checked with `diff` against base (exactly one changed line, or a replaced line pair for an in-place substitution; see `receipts/mutation-diffs.txt`). The five guard copies pass `bash -n`; the six quote-locate copies were run directly.
- Fixture tracking: the selftest and probe repositories were created with `git init` under scratch; `git -C <fixture> rev-parse --show-toplevel` checked against the fixture path before use.
- Installs or upgrades: none.

Receipts (copied into this seat directory): `receipts/main-instruments.txt`, `controls-on-mutants.txt`, `probe-quote-locate.txt`, `probe-laneguard-run.txt`, `probe-duplicate-fetch-row.txt`, `mutation-diffs.txt`.

## 2. Control runs (unmodified instruments at b944735)

| command (cwd = scratch copy of b944735) | output | exit |
|---|---|---|
| `python3 -I -B corpus/quote-locate.py --root <base>` | `QUOTE_LOCATE: CLEAN located=5 rows=5` | 0 |
| `bash plans/round-38-c1.sh` | `5` | 0 |
| `bash corpus/laneguard.sh --selftest` | `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok` | 0 |
| `bash corpus/laneguard.sh --selftest --no-mutate` | `LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok` | 1 (counter reads 0) |
| `bash plans/round-38-c2.sh` | `3` | 0 |

Frozen controls, run with `BASE=<base>` (`bash plans/round-38-controls.sh <mode>`): c1_nowork 5 (see note N1), c1_full 5, c1_forge_quote 4, c1_forge_bytes 4, c1_forge_registry 4, c2_nowork 0. `c2_positive` (`plans/round-38-c2.sh`) 3.

Claim BASE `a916f4a` (counter scripts copied in): `plans/round-38-c1.sh` → 0; `plans/round-38-c2.sh` → 0; `c1_nowork` → 0; `c2_nowork` → 0. `c1_full` cannot run at a916f4a (its capture bodies are absent); that is expected, not a result.

Reproduction: C1 counter 0 → 5 and C2 counter 0 → 3 reproduce at b944735 with the frozen controls at their frozen values.

## 3. quote-locate.py mutants

Unmodified manifest of the candidate (`corpus/quote-bodies.tsv`, 5 rows), command `python3 -I -B m-<id>/corpus/quote-locate.py --root m-<id>`.

| id | file:line | exact change | verdict line | exit | literal kill rule | frozen controls changed | distinguishing probe (not frozen) |
|---|---|---|---|---|---|---|---|
| M1 | corpus/quote-locate.py:100 | `if hashlib.sha256(data).hexdigest() != capture[9]:` → `if False:` | `QUOTE_LOCATE: CLEAN located=5 rows=5` | 0 | SURVIVED | `c1_forge_bytes` 4 → **5** (KILLED by control) | dup-row probe, bogus sha in last row: base FAIL 4, M1 CLEAN 5 |
| M2 | :102 `elif len(data) != int(capture[10]):` → `elif False:` | same | 0 | SURVIVED | none (forge_* = 4,4,4) | — | `p-bytes` (S091 col 11 3354→3355): base `FAIL located=4` (body-bytes-mismatch), M2 `CLEAN located=5` (KILLED by probe) |
| M3 | :106 `elif data[int(offset):…] != needle:` → `elif needle not in data:` | same | 0 | SURVIVED | none | — | `p-offset` (S090 offset 729→730): base `FAIL located=4` (quote-not-at-offset), M3 `CLEAN located=5` (KILLED by probe) |
| M4 | :104 `elif line is None or quote not in line:` → `elif False:` | same | 0 | SURVIVED | `c1_forge_registry` 4 → **5** (KILLED by control) | — | — |
| M5 | :94 `elif quote != capture[12]:` → `elif False:` | same | 0 | SURVIVED | none (`c1_forge_quote` stays 4) | — | `p-sub` (S092 manifest quote cut to `<title>Release v2.2.1`, same offset): base `FAIL located=4` (quote-not-capture-quote), M5 `CLEAN located=5` (KILLED by probe) |
| M6 | :88 `elif os.path.isabs(body_path) or ".." in …:` → `elif ".." in …:` | same | 0 | SURVIVED | none | — | `p-abs` (S091 body_path made absolute): base `FAIL located=4` (unsafe-body-path), M6 `CLEAN located=5` (KILLED by probe) |

Quote-locate kill count: literal rule 0/6 (by construction: each mutant changes behaviour only on an input that violates the check it removed; the candidate manifest does not contain one). Frozen controls + counters: 2/6 (M1, M4). With the distinguishing probes: 6/6.

Frozen-control matrix (BASE = each copy; `c1_nowork` / `c1_full` / `c1_forge_quote` / `c1_forge_bytes` / `c1_forge_registry`):
base 5/5/4/4/4 · M1 5/5/4/**5**/4 · M2 5/5/4/4/4 · M3 5/5/4/4/4 · M4 5/5/4/4/**5** · M5 5/5/4/4/4 · M6 5/5/4/4/4.

## 4. laneguard.sh mutants

Command: `HYAKU_SCRATCH=<scratch>/hs bash m-<id>/corpus/laneguard.sh --selftest`.

| id | file:line | exact change | selftest line | exit | literal kill rule | frozen controls changed | distinguishing probe (not frozen) |
|---|---|---|---|---|---|---|---|
| G1 | corpus/laneguard.sh:28 | `git -C "$lane" --no-optional-locks status --porcelain=v1 -z --untracked-files=all` deleted | `LANE_GUARD_SELFTEST: detected=2 mutants=3 clean=ok` | 1 | KILLED | `c2_positive` 3 → 2 | root untracked file `z.txt`: base VIOLATION rc 1, G1 CLEAN rc 0 |
| G2 | :27 `git -C "$lane" rev-parse HEAD … \|\| echo NOHEAD` deleted | `detected=2 mutants=3 clean=ok` | 1 | KILLED | `c2_positive` 3 → 2 | — |
| G3 | :28 `--untracked-files=all` removed | `detected=3 mutants=3 clean=ok` | 0 | SURVIVED | none (c2_nowork 0, c2_positive 3) | — | new file `d/y` inside a pre-existing untracked dir `d/`: base VIOLATION rc 1, G3 CLEAN rc 0 (KILLED by probe) |
| G4 | :46 `if [ "$before" != "$after" ]; then` → `if false; then` | `detected=0 mutants=3 clean=ok` | 1 | KILLED | `c2_positive` 3 → 0 | — |
| G5 | :85 `for c in "${cmds[@]}"; do` → `detected=${#cmds[@]}; mutants=$detected; for c in "${cmds[@]:0:0}"; do` (mutants never run) | `detected=3 mutants=3 clean=ok` | 0 | SURVIVED | `c2_nowork` 0 → **3** (KILLED by do-nothing control); `--no-mutate` prints `detected=3 mutants=3` | — |

Lane guard kill count: literal rule 3/5 (G1, G2, G4). Frozen controls + counters: 4/5 (adds G5). With the probe: 5/5.

Control matrix (`c2_nowork` / `c2_positive`): base 0/3 · G1 0/2 · G2 0/2 · G3 0/3 · G4 0/0 · G5 **3**/3.

## 5. Totals

| set | killed | killers |
|---|---|---|
| literal assignment rule (FAIL/SETUP on unmodified manifest; selftest line ≠ `detected=3 mutants=3 clean=ok`) | 3 / 11 | G1, G2, G4 |
| frozen controls and counters (BASE = mutant copy) | 6 / 11 | M1, M4 (quote controls); G1, G2, G4, G5 (guard) |
| frozen plus distinguishing probes (this seat's additions, outside the frozen set) | 11 / 11 | adds M2, M3, M5, M6, G3 |

Survivors under the frozen set: M2, M3, M5, M6, G3.

## 6. Survivors: reasons

- **M2 — gap in the frozen controls, not an equivalent mutant.** The sha256 check runs first and fixes the body bytes; an honest capture sha implies an honest length, so with an honest column 10 the byte-count check is unreachable. It becomes live only when column 11 is wrong, and no frozen control alters column 11. Probe `p-bytes` kills it (base FAIL 4, M2 CLEAN 5).
- **M3 — gap in the frozen controls.** No frozen control moves a declared offset, so the predicate's clause "found byte-for-byte at its declared offset" is untested. Probe `p-offset` kills it.
- **M5 — partly subsumed, residual gap.** A forged manifest quote must also be in the registry row and at the declared offset, so `c1_forge_quote` is rejected by the registry check (4 under M5 as well). Only a manifest quote that is a different span, also present in the registry row and at the offset, escapes. No frozen control does this, so the clause "declared quote equals capture column 13" is enforced only through this one check, and that is untested. Probe `p-sub` kills it.
- **M6 — gap in the frozen controls.** No control uses an absolute `body_path`. The `..` check survives in M6, so only absolute paths are admitted. Exposure is limited: the sha, byte-count and registry checks must still pass, so an attacker needs an outside body whose sha matches the capture row. Probe `p-abs` kills it.
- **G3 — gap in the frozen controls.** The planted untracked file sits at repository root, where `--untracked-files=normal` still lists it. The guard misses a new file added inside a directory that was already untracked-and-listed. This is a real calibration hole for a lane that carries untracked directories. Probe kills it.

No survivor is an exact equivalent mutant on every input. M2 is equivalent only while column 10 is honest.

## 7. Additional observations (outside the mutant list)

- **N1 — `c1_nowork` is BASE-dependent.** It reads 5 on any copy that carries the candidate manifest (every mutant copy and b944735 itself). Its "expect 0" holds only at claim BASE a916f4a, where it reads 0. The table above therefore does not read `c1_nowork` as a do-nothing value for candidate-derived copies. Recorded so the matrix is not misread.
- **N2 — duplicate capture rows are shadowed silently.** `load_fetches` assigns `fetch[id] = cols`, so the last row for a repeated id wins. Probe (`p-dup-first`: a bogus S091 row with sha `000…0` placed before the real row): base `QUOTE_LOCATE: CLEAN located=5 rows=5`. Probe (`p-dup-last`: same bogus row appended): base `QUOTE_LOCATE: FAIL located=4 rows=5`, M1 `CLEAN located=5 rows=5`. The gate does not check id uniqueness; the census must. Exit codes were not captured for this probe (pipeline); the verdict lines are the evidence.
- **N3 — documented `run` entry point rejects its own documented form.** The header and the usage message say `laneguard.sh run LANE -- CMD`. The implementation requires `laneguard.sh run -- LANE -- CMD`. Exact: `bash corpus/laneguard.sh run <fixture> -- true` → `usage: laneguard.sh run LANE -- CMD...`, exit 2. The counter and selftest call `run_guard` directly, so C2's predicate is not affected, but the documented CLI is unusable as written. Routed to the lane; not repaired (frozen instrument).
- **N4 — `--selftest --no-mutate` exits 1** while printing `detected=0 mutants=3 clean=ok`. The exit reflects the mutate-run predicate; the counter reads the printed number. Noted, not a defect of the claim.

## 8. Verdicts on the claims (from this seat's evidence only)

- **C1 (freshness, 0 → 5): reproduced at b944735.** Counter 5; quote-locate CLEAN located=5 rows=5 exit 0; frozen forgeries 4/4/4 exactly as predeclared; claim BASE 0. The gate's calibration is incomplete: 4 of 6 mutants of its checks survive the frozen controls (M2, M3, M5, M6), and the duplicate-row shadowing (N2) is unguarded.
- **C2 (calibration, 0 → 3): reproduced at b944735.** Counter 3; do-nothing control 0; claim BASE 0. The guard's calibration is incomplete: G3 survives the frozen controls, and G5 (counting without running) is caught only by the do-nothing control, not by the selftest's own printed line.

Neither claim is refuted by this evidence. Both counters measure what their frozen predicates say for the planted cases they contain; they do not measure the full predicate. These are routed findings, not repairs; the instruments and controls were not edited.

## 9. Exact commands run (abbreviated; all with `HYAKU_SCRATCH` = scratch `hs/`)

- `git cat-file -t b944735`; `git archive b944735 | tar -x -C base`; `git archive a916f4a… | tar -x -C claimbase`
- `python3 -I -B <copy>/corpus/quote-locate.py --root <copy>` (base, M1–M6, p-bytes, p-offset, p-sub, p-abs, p-dup-first/last)
- `bash <copy>/corpus/laneguard.sh --selftest` and `--selftest --no-mutate` (base, G1–G5)
- `BASE=<copy> bash <copy>/plans/round-38-controls.sh <mode>` for c1_nowork, c1_full, c1_forge_quote, c1_forge_bytes, c1_forge_registry, c2_nowork; `bash <copy>/plans/round-38-c2.sh`
- `bash <base>/corpus/laneguard.sh run -- <fixture> -- <cmd>` for the run-mode probes (G1, G2, G3, G4, G5, base)
- `diff base/<file> m-<id>/<file>` (receipts/mutation-diffs.txt)
- Read-only: `git -C <lane> status --porcelain | sha256sum`, `git rev-parse HEAD`.
