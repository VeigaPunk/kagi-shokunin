# K43CriticClaims — pre-measurement attack on plans/round-43.md §C1/§C2/§C3

Sandbox: `/fast/scratch/hyaku/kagi-r43/K43CriticClaims/work`, clone of the lane at `dd6ccb92bf04a061e9f1e66913d15f097397b1b3`
(amendment A1), `git rev-parse --show-toplevel` = the work dir, verified before any write. Lane untouched.
Committed BASE receipts re-read from `.ufo/waves/round-43/controls/` (measured-at.txt = 5f3566c4cfe65a74da4d201d74d28b403929807b).

## Finding 1 — §9 no-work reachability — NOT-DEFECT

Cheapest do-nothing candidate per claim, and its committed BASE reading:

- **C1** — do nothing; keep the round-42 instrument `plans/round-42-c1.sh`, gate bytes untouched.
  Receipts: `c1-old-real.txt` = **5**, `c1-old-m3-K1.txt` = **5** (guard-drop survivor), `c1-old-m5-K3.txt` = **5**
  (token-drop survivor), `c1-old-fakeC.txt` = **5** (answer-key passes) — the three broken shapes all read 5/5/5
  and the real gate reads 5 < 6; the matrix cells (m3-K1 = 6, m5-K3 = 6, fakeC < 6) are unreachable. The new
  counter does not exist at BASE: `git show 5f3566c…:plans/round-43-c1.sh` → rc 128 `fatal: path … does not exist`,
  so `bash plans/round-43-c1.sh` at BASE is a missing file (no N). Kill clauses C1(a) and C1(b) both fire.
- **C2** — do nothing; no gate. `c2-base.txt` = **0** < target 1; `corpus/controls-replay.sh` absent at BASE
  (`git cat-file -e 5f3566c…:corpus/controls-replay.sh` → rc 128). Kill clause C2(a) fires.
- **C3** — do nothing; gates untouched. `c3-base.txt` = **0** < target 5 (leg (1) fails for every gate;
  `TMPDIR:-/tmp` confirmed present at `anchor-pins.sh:37`, `claims-declared.sh:37`, `prefreeze-control.sh:94` and
  `:274`, `self-description-sweep.sh:43` and `:226`, `surface-census.sh:275` at dd6ccb92). Kill clause C3(a) fires.

Sandbox confirmation (assignment item 1 duty) — re-ran all three counters at dd6ccb92:

| command | stdout | rc |
|---|---|---|
| `bash plans/round-43-c1.sh` | `6` | 0 (= committed `c1-new-real`) |
| `bash plans/round-42-c1.sh` | `5` | 0 (= committed `c1-old-real`) |
| `bash plans/round-43-c2.sh` | `0` | 0 (= committed `c2-base`) |
| `bash plans/round-43-c3.sh` | `0` | 0 (= committed `c3-base`) |

Verdict: **NOT-DEFECT** — no do-nothing state reaches any target; every claim's clause (a) kills it.

## Finding 2 — kill-rule testability — DEFECT (two hard defects, three minors)

Per-clause commands and runnability (clause = "C1 is not admitted if …"):

- **C1(a)** `bash plans/round-43-c1.sh` ≠ 6 — runnable; re-run rc 0 → `6`. At BASE rc 128 → fires. OK.
- **C1(b)** `c1-new-K1`/`c1-new-K3` ≠ 0, `c1-new-fakeC` ≠ 5, `c1-new-m3-K1`/`c1-new-m5-K3` ≠ 6 — receipts are
  produced only by `bash plans/round-43-controls.sh` (fixture gates K1/K3/fakeC + counter mutants in scratch);
  the clause names receipts, §Controls names the command. Runnable by reference. Minor (house style), OK.
- **C1(c)** old receipts ≠ 5/0/0/5/5/5 — same runner; runnable; verified values still reproduce (finding 1). OK.
- **C1(d)** `git diff --quiet 5f3566c… HEAD -- corpus/expect-journal.sh` fails — runnable as written; rc 0 at
  dd6ccb92 (bytes unchanged: gate-bytes rc=0). OK.
- **C1(e)** landing check — **DEFECT D1**: the written form `--base-ledger <(git show 6cc8850…:…)` / A1's corrected
  `<(git show 5142b52:…)` is **unrunnable against this gate**: `corpus/expect-journal.sh:223` requires
  `[ -f "$base_ledger" ]` (regular file), and process substitution yields a pipe; measured:
  `expect-journal: setup error: base ledger not readable: /dev/fd/63`, rc 2 (all three forms). The clause is
  testable only in its two-step form (`git show … > file`). Verdicts below (finding 6) reproduce A1 exactly with
  materialized files, so A1's *claims* are true; its *command text* cannot be executed verbatim.
- **C2(a)** `bash plans/round-43-c2.sh` ≠ 1 — runnable; reads `0`. OK.
- **C2(b)** `final/c2-replay-direct.txt` not rc 0 — **DEFECT D3**: `final/` is anchored nowhere (C1's matrix header
  says "re-measured byte-frozen under `final/`" — under which directory? `.ufo/waves/round-43/controls/final/` vs
  `build/<L1>/final/` are both admissible readings), and the producing command (`bash corpus/controls-replay.sh
  --clone <dir>`, rc must be 0) lives only in the candidate rule, not the clause. Runnable once the gate lands;
  ambiguous as written.
- **C2(c)** restore duty — runnable but command-unstated. Enumerating command: `git -C <clone> status --porcelain
  -- .ufo/waves/round-42/controls .ufo/waves/round-41/controls` (empty = match). Minor.
- **C2(d)** blankets ≠ 0 re-measured — runnable via `CONTROLS_REPLAY_GATE=<always0|always1> bash
  plans/round-43-c2.sh`; runner bytes settle that "always-1" = `exit 1` (rc 1, no output). OK.
- **C3(a)** `bash plans/round-43-c3.sh` ≠ 5 — runnable; reads `0`. OK.
- **C3(b)** `c3-pos` ≠ 1 / `c3-blanket` ≠ 4 — runnable via the runner's fixture trees. OK.
- **C3(c)** four rows re-run individually — exact commands are in the clause (`bash corpus/surface-census.sh
  --selftest` → `SELFTEST: PASS (16 cases)` rc 0; `bash corpus/prefreeze-control.sh --selftest` →
  `PREFREEZE_SELFTEST: PASS (25 cases)` rc 0, twice; `bash corpus/self-description-sweep.sh --selftest` →
  `SELFTEST: PASS (10 cases)` rc 0). Runnable as written. OK.
- **C3(d)** = C1(e) — **DEFECT D1** (same unrunnable literal form).
- **C3(e)** diff beyond the seven frozen replaces — judgment clause with no command. Narrowing: `git diff --numstat
  5f3566c… HEAD -- corpus/` must be exactly {anchor-pins.sh 1/1, claims-declared.sh 1/1, prefreeze-control.sh 2/2,
  self-description-sweep.sh 2/2, surface-census.sh 1/1} = 7 changed lines across 5 files. Runnable after naming.
  Minor.

- **DEFECT D2 — coverage gap**: no clause pins the round-43 instrument bytes (`plans/round-43-c1.sh`, `-c2.sh`,
  `-c3.sh`, `controls.sh`) between the amendment commit `dd6ccb92…` and the landing commit. The matrix clauses
  (b)/(c) constrain the counter only through fixture *gates*; a counter edit that conditions on the real gate's
  path (print 6 only when the GATE basename matches `expect-journal`, honest counting otherwise) reproduces every
  committed matrix cell (K1 → 0, K3 → 0, fakeC → 5, mutants inherit the honest branch under K1/K3 → 6/6) and
  survives (a)–(e). This is not in the declared ceilings (which name only the 6-key gate, token-output scope,
  mutant-battery coverage, F6 one-row). Smallest fix, house tool: extend C1(d)'s form —
  `git diff --quiet dd6ccb92… HEAD -- plans/round-43-c1.sh plans/round-43-c2.sh plans/round-43-c3.sh plans/round-43-controls.sh`.

No clause is already-satisfied-in-a-killing-sense at BASE: each claim's clause (a) fires at BASE (finding 1);
C1(d) passes trivially for a no-op candidate but can fail — a live guard, not a dead clause.

## Finding 3 — predicate ambiguity — DEFECT (two), rest resolved by bytes

1. §C3 "The gate set is scanned under `C3_ROOT`" — reading A: C3_ROOT substitutes the repo root for the relative
   gate paths (grep legs AND executed leg); reading B: C3_ROOT only scopes a scan, execution stays in the lane.
   Counter bytes implement **A**: `check` greps and executes `$ROOT/$1` with `ROOT=${C3_ROOT:-$HERE}`; the counter
   comment adds the consequence — fixture trees must be git work trees (selftests resolve the toplevel). Resolved.
2. §C2 Improves "eight of the eleven committed receipts … re-derive byte-identically at the BASE HEAD (measured
   this round in a scratch clone)" — **DEFECT D4**: no committed receipt captures that measurement (round-43
   controls carries only `c2-base`, `c2-blanket-0/1`); the property is witnessed only by the candidate gate's P1 at
   landing. If P1 fails, no BASE-side receipt arbitrates whether the before-state was green. The eleven/8+3 split
   itself checks out (round-41/controls = 5 files, round-42/controls = 6 files, manifest = 8, excluded = 3, named
   in the counter header).
3. §C1 matrix header "re-measured byte-frozen under `final/` at the candidate" — **DEFECT D3** (path unanchored;
   see finding 2, C2(b)).
4. §C2 "blanket always-0 and always-1 gates" — "always-1" could read as "always prints 1"; runner bytes settle it
   (`exit 1`). Resolved, no defect.
5. §C1 "P0 error ⇒ N = 0" — implemented as any P0 rc ≠ 0 → 0 (counter bytes). Resolved, no defect.

## Finding 4 — universal clauses — NOT-DEFECT (one narrowing named)

- §C1 "the six forgeries F1–F6" — enumerated: six literal `check` calls with pinned ids and exact
  `EXPECT_JOURNAL: REFUSE <token>` lines (`grep -qxF`). Command: the counter. OK.
- §C2 "every manifest file must exist again and byte-match" — manifest enumerated (8 paths + frozen values in plan
  §C2 and the counter header). Gate-side command: per-file `cmp` against the snapshot. OK.
- §C2(c) "the clone's controls dirs do not byte-match their committed state" — universal over *all* files in the
  two dirs, not just the manifest eight. Enumerating command (see finding 2, C2(c)):
  `git -C <clone> status --porcelain -- .ufo/waves/round-42/controls .ufo/waves/round-41/controls`. Narrowing named.
- §C3 "the five gates" — enumerated (paths, tokens, case counts). §C3(e) "seven frozen replaces" — enumerated by
  path:line in the candidate rule; enumerating command named in finding 2. OK.
- §C1 ceiling "a gate keying all six answers …" — declared ceiling, not a predicate; no command required. OK.

## Finding 5 — axis fit — verdicts

- **C1 → calibration**: the claim replaces an instrument three broken gate shapes pass (old 5/5/5) with one that
  refuses them (new 6/6/5<6, blankets 0/0) — instrument discrimination quality, i.e. calibration proper. The
  against-fit argument (F6 is a new forgery class → freshness-flavored) fails: F6's role is to break the
  answer-key class, a discrimination act. Fit holds.
- **C2 → freshness**: durable enforcement that committed receipts re-derive at the revision they live at —
  freshness is exactly "committed evidence still true at HEAD" (round-42 C2 was the one-shot form; this is the
  connector's routed durable form). Against-fit (the gate is also an operability artifact) fails: the measured
  property is re-derivability. Fit holds.
- **C3 → operability**: weakest fit of the three. **DEFECT D5 (narrative)**: the improve-text says "five lane gates
  create their selftest fixtures under `${TMPDIR:-/tmp}` defaults", but `anchor-pins.sh:37` and
  `claims-declared.sh:37` read `"${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}/…"` — they **already** honour the lane scratch
  root as primary default whenever `HYAKU_SCRATCH` is set; only the nested fallback literal changes. Also nothing
  is inoperable today: the plan freezes all five executed legs as passing at BASE. The claim hardens a policy
  default, it does not repair an operation. The counter legs themselves are unambiguous and the
  executed-leg-is-load-bearing control (`c3-blanket` = 4) is sound, so the fit survives at grep-leg level —
  misdescription only.

## Finding 6 — A1 soundness — NOT-DEFECT on substance, D1 on command form

Measured in the sandbox at dd6ccb92 (gate bytes unchanged since BASE: `git diff --quiet 5f3566c… dd6ccb92… -- corpus/expect-journal.sh` → rc 0; `corpus/claim-ledger.tsv` likewise rc 0):

- **(a) combined-journal form refuses** — materialized base ledger from `6cc8850dfc5757927699e5a53a876f47c8df21aa`,
  journals dir with copies of both committed journals (`round-40/expectation-migrations.json`, `round-41/…`):
  last line `EXPECT_JOURNAL: REFUSED (violations=12)`, rc 1 — six NEW_MISMATCH + six OLD_MISMATCH over exactly
  {R13-01, R21-02, R24-06, R31-02, R33-02, R34-03}, matching A1's text. The round-40-journal-alone variant also
  refuses: `EXPECT_JOURNAL: REFUSED (violations=6)`, rc 1 — matching A1's aside.
- **(b) corrected form reads CLEAN** — base ledger from `5142b52` (round-41 predeclaration, `git log` confirms:
  "round-41: frozen plan (predeclaration) — C1 calibration journal gate, C2 freshness …"), journals dir holding a
  copy of `.ufo/waves/round-41/expectation-migrations.json`: last line `EXPECT_JOURNAL: CLEAN (changed=6
  journaled=6)`, rc 0. Exactly A1's claim.
- **A1 scope**: `git diff a9180250955ad44530b565fa5b131b540c849199 dd6ccb92…` = 16 added lines — the amendment
  section only, in `plans/round-43.md`; nothing else changed; appended before any candidate measurement (no
  candidate work exists in the lane). Sound.
- **Carried defect D1**: A1's quoted command uses `<(git show …)`; the gate refuses that at setup (rc 2,
  `/dev/fd/63` fails `-f` at `corpus/expect-journal.sh:223`). A1's verdicts are reproducible only with
  materialized files. The kill-rule text should carry the two-step form.

## Surviving defects (named)

- **D1** — C1(e)/C3(d): literal `<(…)` form unrunnable (gate `[ -f ]` rejects `/dev/fd/63`, rc 2); use materialized files in the kill-rule text.
- **D2** — no kill clause pins the round-43 instrument bytes between `dd6ccb92…` and landing; a path-conditioned counter edit survives (a)–(e). Fix: `git diff --quiet dd6ccb92… HEAD -- plans/round-43-c1.sh plans/round-43-c2.sh plans/round-43-c3.sh plans/round-43-controls.sh`.
- **D3** — `final/` receipt location unanchored (C1 matrix header, C2(b)).
- **D4** — §C2 Improves "measured this round" eight-receipt re-derivation has no committed receipt.
- **D5** — §C3 improve-text misdescribes `anchor-pins.sh` / `claims-declared.sh` current behavior (already HYAKU_SCRATCH-primary).

Not defects: all three no-work readings hold (finding 1); every claim's clause (a) fires at BASE; no dead kill
clause found; C3_ROOT and always-1 ambiguities resolved by counter/runner bytes; A1 substance confirmed.
