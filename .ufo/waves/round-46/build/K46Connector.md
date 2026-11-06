# K46Connector — sibling-overlap and pattern scan, round 46

**Seat:** K46Connector (connector, leaf — no subagent dispatch). **Mode:** read-only.
**Lane:** `/home/vgpnk/Projects/shokunin/kagi-shokunin`, tree untouched; no git command that writes was run;
no lane gate, counter or self-count was executed (my item names no script to run).
**Claims scanned:** C1 (operability, `corpus/claims-declared.sh` `--selftest` killing M1–M3 with E1–E4
surviving) and C2 (freshness, 29 `on-release` clocks re-observed live, release-clock gate CLEAN).
**Siblings scanned:** all 21 `*-shokunin` lanes under the fleet root (`/home/vgpnk/Projects/shokunin/*-shokunin`),
`corpus/` subtrees only, plus the fleet root `tools/` and `scripts/` (read).

---

## Verdicts, one line each

- **C2 — NO SUBJECT OVERLAP.** No sibling lane holds a release/feed clock gate, and none holds any of the five
  bound feeds (SOPS, Vault, OpenBao, Python downloads, curl release info). `release-clock.py` and
  `release-clocks.tsv` exist only in kagi. The *vocabulary* C2 works (`on-release`) is fleet-wide and unenforced
  outside kagi; three kasegi gates validate its **shape only**. See §1.
- **C1 — NO SUBJECT OVERLAP, HEAVY METHOD OVERLAP.** No sibling lane asserts a plan-to-manifest direction, but
  the mutation/equivalent-mutant method C1 needs is already built four times over: tameshi already swept three
  of kagi's *own* gates, and the survivor class it names ("reported-but-unasserted") is exactly why a fixed case
  count can be printed and never asserted. See §2.
- **PATTERN (c) — M46-1's fix shape does not exist in any sibling claim ledger.** Only kagi has a
  `claim-ledger.tsv`; kagi itself already holds five default-mode rows, so M46-1 is a *missing row inside a
  shape the lane invented*, not a shape borrowed from elsewhere. Nearest siblings are of three different
  species, listed in §3.

---

## 1. C2 — freshness: sibling overlap scan

### 1.1 Who holds a release/feed clock gate

Measured (read-only):

```
$ grep -rIl -E 'release-clock|releases\.atom|on-release|RELEASE_CLOCK' */corpus
$ find */corpus -maxdepth 2 -name '*release*'
$ grep -rIn 'RELEASE_CLOCK' */corpus | grep -v '/lessons/'
```

- `RELEASE_CLOCK` / `RELEASE_CLOCK_OBSERVE` / `RELEASE_CLOCK_SELFTEST` verdict tokens: **kagi only**
  (`corpus/release-clock.py:719, 985, 2096`; ledger expectations `corpus/claim-ledger.tsv:82`).
- Files matching `*release*` under any sibling `corpus/`: **kagi only** (`release-clock.py`,
  `release-clocks.tsv`, plus a stale `corpus/__pycache__/release-clock.cpython-314.pyc`). Every other hit is a
  lesson, a `knowledge/` note, or a game-dev live-capture directory — no clock table, no gate.
- Feed-url extraction (`releases.atom`, `/releases/tag/`, `downloads/feed`, `curl.se/releases`, `releases.json`)
  outside kagi, excluding `lessons/` and `evidence/`:
  **one hit** — `game-dev-3d-shokunin/corpus/SOURCES.md:42` (Jolt Physics
  `https://github.com/jrouwe/JoltPhysics/releases/tag/v5.6.0`, recheck cell `on-release`). A release *tag page*
  with an `on-release` recheck and no clock. Not a feed, not a gate.
- SOPS / Vault / OpenBao / `sops` in any non-kagi `corpus` file (`*.tsv`, `*.py`, `*.sh`, `*.json`):
  **zero hits**. No sibling shares a single one of C2's five bound feed rows (S033–S037) or S098.

### 1.2 The `on-release` vocabulary is fleet-wide, and only kagi enforces it

```
$ grep -h 'on-release' */corpus/SOURCES.md | wc -l                     → 2142
$ for f in */corpus/SOURCES.md; do grep -q 'on-release' "$f" && echo x; done | wc -l   → 21   (all lanes)
$ grep -rl '^recheck: on-release' */corpus/knowledge | wc -l           → 164   (15 lanes)
$ grep -rl 'on-release' */corpus/*.py */corpus/*.sh */corpus/instruments/*.py | wc -l  → 6
```

The six gate files that read the token are: `kagi-shokunin/corpus/release-clock.py` (binds it to a clock row),
`kagi-shokunin/corpus/sources-census.sh:387` (a fixture row), and **three kasegi gates that accept it by regex
shape only**:

- `kasegi-shokunin/corpus/instruments/r46-c2-gate.py:294` —
  `re.fullmatch(r"(?:\d+d|on-release|\d{4}-\d{2}-\d{2})", row[9])` → `bad.append("recheck-cell")`
- `kasegi-shokunin/corpus/instruments/r46-f29-gate.py:264` — same regex
- `kasegi-shokunin/corpus/instruments/r47-f30-gate.py:282` — same regex

**This is the most useful overlap finding in the scan, and it is a warning, not a duplicate claim.** A
shape-only `on-release` acceptance is exactly the hole that produced kagi's round-39 `ORPHAN S040/S041` and
`UNBOUND S098`: the cell is well-formed, so the gate is green, and nothing binds it to an observation. Kasegi's
three gates would pass S098 as it stands at BASE. C2 therefore has no sibling competitor *and* a sibling
adjacent shape that scores 1 on the cell and 0 on the binding.

### 1.3 A sibling gate that went silently red — same class, different surface

No sibling can go red on C2's surface (no gate). Two siblings record the *class*:

- `kasegi-shokunin/corpus/instruments/census-freshness-check.py:9-12` — the gate exists **because** of this
  exact failure: *"the committed census of record described a tree the lane no longer had … Nothing failed: the
  census was stale, and the round quoted it anyway. This gate makes that state exit 1."* Same mechanism as
  M46-1 (a held artifact drifts, no round re-runs the check, the round quotes the stale artifact), with a
  commit-compare implementation (`:19`, exit 1 `CENSUS-FRESH=stale`) rather than a clock implementation.
- `kake-shokunin/corpus/knowledge/gate-status-ledger.md:41,44,46,49,51,55` — five `historical_not_green_at_pin`
  rows and one `never-met` row, kept in a dated ledger *"so a standing red is not misread as a fresh
  regression"* (`:9-14`). This is the sibling mitigation for M46-1's second half: a red gate that is *known*
  red needs a ledger row, not silence.

**C2 overlap verdict:** no sibling holds the same feeds, the same gate, or a competing `on-release` binding;
one kasegi shape-only pattern is adjacent and would not catch the BASE defect. C2's claim is lane-local, and
its freshness idiom has two sibling precedents (`census-freshness-check.py`, `gate-status-ledger.md`) that C2
does not depend on and does not contradict.

---

## 2. C1 — operability: sibling self-test and mutation-battery scan

### 2.1 Self-tests that assert a fixed case count

Fleet-wide grep for an internal case-count predicate:

```
$ grep -rIn -E 'cases"? -eq [0-9]+|-eq [0-9]+ \] && \[' */corpus --include='*.sh'
```

Exactly **two** gates in the fleet assert a hardcoded case count inside the gate itself, and both are in kagi:

- `kagi-shokunin/corpus/claims-declared.sh:102` — `if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 8 ]; then`
  followed by `:103` `echo "CLAIMS_DECLARED_SELFTEST: PASS (8 cases)"` (the literal is **not** `$cases`).
- `kagi-shokunin/corpus/anchor-pins.sh:96` — the identical idiom (`-eq 8`, same lane, different gate).

**This is the single highest-consequence fact for C1 and it is a landmine, not a detail.** The C1 candidate
adds selftest cases 9–10 inside `--run-selftest` (allowed by the kill rule, which permits edits only in that
block). If it adds the cases without moving `-eq 8` at `:102`, the selftest exits 1 with
`CLAIMS_DECLARED_SELFTEST: FAIL (passed=10/10)` — POSITIVE = 0, and the counter scores 0 no matter how many
mutants the new cases would have killed. If it moves `:102` but leaves the literal at `:103`, the suite passes
while printing a stale count: a "reported-but-unasserted surface" (tameshi's arm class D, §2.2) inside the very
gate C1 is hardening. Both lines are inside the permitted block; both must move.

Siblings pin the count **externally** instead, and two shapes are reusable:

- `chousa-shokunin/corpus/evidence/round64/c2-mutrun.py:10,22,99,100` — the mutation matrix carries the count
  *as a versioned expectation*: matrix `v1` requires `AUDIT_SELFTEST=PASS (3 cases)`, matrix `v2` requires
  `(10 cases)`. When the audit gate grew from 3 to 10 cases the matrix gained a version rather than being
  silently re-baselined; the surviving v1 matrix stays a falsifier of the v2 gate.
- `kagi-shokunin/corpus/claim-ledger.tsv:82` (R25-03) — `^RELEASE_CLOCK_SELFTEST: PASS \(116 cases\)$`,
  anchored full line. Same lane, different gate: the count lives in the ledger, so a count change is a visible
  ledger diff. C1's gate has no such row (grep `claims-declared` over `claim-ledger.tsv` → **0 rows**), so
  nothing outside the gate would notice the count moving.

### 2.2 Mutation / equivalent-mutant batteries over their own gates

Named, with the pointer that carries the method:

| Lane | Battery | Pointer | Reusable shape |
|---|---|---|---|
| tameshi | `tools/mutate-and-run.sh --regression` — 10 legs, **three of them kagi's own gates** | `tameshi-shokunin/tools/mutate-and-run.sh:18,89,92,97,147,1244-1340` | `REGRESSION_CASE <name>: PASS/FAIL`, per-leg recorded kill rate, git-blob-materialized targets (a drifted tree cannot move a leg). kagi legs and rates: `bash-surface-census 8/10`, `bash-checklist-run 7/15`, `bash-drift-pins 2/10`. |
| tameshi | arm-class matrix — equivalent-mutant classes | `tameshi-shokunin/corpus/knowledge/arm-class-matrix.md:32,73` | Class **D "reported-but-unasserted surfaces"** is the C1 disease named generically: `B10` *"no case reads summary fields; non-equiv `ok=0` vs `ok=1`"*. Headline: 20 mutants, 16 killed, 4 survived, survivors fall in exactly two classes. |
| tameshi | harness-name false kill | `tameshi-shokunin/corpus/knowledge/mutation-case-kagi-drift-pins.md:16-17,92` | Three kill-aimed mutants survive *because the harness names its sandbox with the defect id and the selftest's verdict-word assertion is an unanchored `grep` over output that prints paths*. Direct hazard for C1: `claims-declared.sh:63-68` `chk` uses `grep -qF -- "$want_token"` over full output — a **presence** assert, never an absence and never a count. |
| chousa | `c2-mutrun.py` — 12 frozen mutants, 5–7 legs, per-leg exit + required-output matrix | `chousa-shokunin/corpus/evidence/round64/c2-mutrun.py:1-35` | `MUT <id> <killed|SURVIVED> <failing legs>`, summary `AUDIT_MUTANTS_KILLED=<k>/12`, exit 0 iff all killed. Closest structural analogue to `plans/round-46-c1.sh` (which is the same shape: mutate, run, exit-status kill). |
| kumitate | control M2 — a selftest that **fails one case while printing a self-consistent `62/62` summary and exit 0** | `kumitate-shokunin/corpus/knowledge/counter-amendment-discipline.md:28-29` | The forgery class C1's K1-F2 must refuse, already measured in a sibling and already forcing a counter amendment there. |
| kagi | `scope-gate.sh --falsify` self-attack: **16/18 caught** | `tameshi-shokunin/corpus/knowledge/fleet-kill-rate-ledger.md:96` | Lane-internal mutation mode; the README's "18/18" was contradicted by measurement — precedent for trusting the battery over the prose. |

**C1 overlap verdict:** no sibling owns a plan-to-manifest claim and none can be credited for C1. The method is
neither novel nor unwitnessed: five sibling batteries exist, three of them already pointed at kagi gates, and
the arm-class vocabulary (`reported-but-unasserted`, `unreached arm`) predicts C1's own EQUIV leg. What C1 adds
that no sibling has is a self-test that must kill mutants of *the gate it lives in* — tameshi's sweeps are
external and never modify the target's own `--selftest`.

---

## 3. Pattern (c) — lanes whose ledgers re-run each gate's default mode every round

Measured:

```
$ grep -rIl -E '^\s*python3 corpus/|^[A-Z][0-9]+-[0-9]+	' */corpus/*.tsv      → kagi-shokunin/corpus/claim-ledger.tsv only
$ find */corpus -maxdepth 2 -iname '*ledger*'                                → no second gate-command ledger
```

**No sibling lane has a claim ledger that re-runs gate defaults each round.** The nearest siblings are three
different species and none is the M46-1 shape:

1. **kumitate — `scripts/round-gate.mjs`** (`kumitate-round-gate-v1`;
   `kumitate-shokunin/corpus/knowledge/round-close-gate.md:1-30`, finding kinds at `scripts/round-gate.mjs:183`).
   It audits *records* (report lands and is a report, SCORECARD row, LOG entry, `round-<N>` commit, push) and,
   under `--tracked`, only report freshness. It **runs no lane gate** — `runGate` at `:761` re-invokes its own
   selftest, not sibling suites. So kumitate's round close cannot notice a gate that went red.
2. **kake — `corpus/knowledge/gate-status-ledger.md`** — a dated status list with dispositions
   (`:41-62`), recheck trigger *"on any row's next re-adjudication, or at the next full c66-counter re-run"*.
   It records standings; it does not re-run them per round, and its own recheck clause lets a row stand
   indefinitely.
3. **tameshi — `corpus/knowledge/fleet-kill-rate-ledger.md`** — the closest living shape: a periodic tick
   re-reads every measured gate's pin and classifies **`current` / `stale` / `drift`** (`:293-310`), re-runs the
   regression engine, and states its own incompleteness rule: *"`stale=2` is the reading — a tick that read
   `stale=0` would be as complete"* (`:352`). It is a *pin* re-read, not a default-mode *run*: it proves the
   bytes moved, not that the gate still passes.

**kagi already holds the M46-1 shape, and the defect is a hole in it.** `corpus/claim-ledger.tsv` has 86 rows
and at least five whose command is a bare default-mode gate invocation: `R11-01 bash corpus/surface-census.sh`,
`R11-04 bash corpus/drift-pins.sh`, `R12-01 bash corpus/op-ref-probe.sh`, `R15-01 bash corpus/checklist-run.sh`,
`R16-01 bash corpus/scope-gate.sh`. The release-clock gate's default mode had one such row and lost it:

- `corpus/claim-ledger.tsv:83` (R25-04) — *"this row used to assert that the clock table agreed with the
  round-26 receipt (`python3 corpus/release-clock.py` CLEAN fired=3). … the row now pins the round-26 receipt's
  BYTES instead"*.
- `corpus/claim-ledger.tsv:82` (R25-03) survives but runs `--selftest` only — the offline synthetic suite,
  never the tree.

So the class is: **a default-mode row was replaced by a byte pin**. The byte pin cannot go red when the tree
drifts; it only goes red when the receipt changes. That is precisely the round-36 migration named in `M46-1`,
and it means the fix is a one-row restoration (`python3 corpus/release-clock.py` → `^RELEASE_CLOCK: CLEAN`),
not a new mechanism. The row-shape to copy is `R11-01`/`R15-01` (bare command, anchored expectation, rc).

---

## 4. Second-order findings the counters and drafts should carry

1. **`claims-declared.sh:102` `-eq 8` (with `:103`'s hardcoded literal) is a hard gate on C1's value, not a
   cosmetic.** Adding cases without moving it makes POSITIVE = 0. Adding it without the literal leaves a stale
   count inside the gate C1 is hardening. Both lines sit inside the permitted `--run-selftest` block.
2. **`chk` (`claims-declared.sh:60-68`) is a presence assert**: `grep -qF -- "$want_token"` on rc + a token.
   A case cannot currently distinguish "the expected mismatch fired" from "the expected mismatch *and* a spurious
   one fired". Mutant M3 (post-move condition inverted, `! awk` → `awk`) turns the loop into *skip landed rounds,
   check in-flight rounds* — it prints **no** line on a fixture that expects a mismatch, and prints a **spurious**
   line only where the real gate prints none. Killing M3 therefore needs either an rc assertion on a
   section-absent fixture or an exact-count token (`CLAIMS_DECLARED: MISMATCH (claims=N mismatch=1)`), which the
   current `chk` cannot express. Naming this now is cheaper than discovering it at the candidate.
3. **The floor window is [39, 98].** M2 raises the floor to 99 (`plans/round-46-c1.sh` mutant m2), while E2
   lowers it to 38 and must survive. A no-manifest fixture at a round **≥ 39 and < 99** is checked by the real
   gate, skipped by M2, and checked identically by E2 (`-le 38` excluded) — so the same fixture satisfies both
   the kill and the equivalence leg. A fixture at round 90 (the existing `mfix` round) is skipped by M2 and
   would score M2 as surviving.
4. **Kasegi's shape-only `on-release` regex (§1.2) is the counter-example C2 should name** when it retires
   S040/S041 and binds S098: a row that merely *carries* the token is what three sibling gates accept.
5. **`corpus/__pycache__/release-clock.cpython-314.pyc` exists in the lane tree.** It is untracked-but-present
   state under `corpus/` (read-only observation; not touched). It matters only if a C2 receipt hashes a glob
   over `corpus/`, and it is worth a line in the closure if the observation walks the directory.

---

## 5. What was run (and what was not)

All commands were read-only and none wrote outside this file:

```
grep -rIl -E 'release-clock|releases\.atom|on-release|RELEASE_CLOCK' */corpus          (rc 0)
find */corpus -maxdepth 2 -name '*release*'                                            (rc 0, 19 paths)
grep -rIn 'RELEASE_CLOCK' */corpus | grep -v '/lessons/'                                (rc 0, kagi only)
grep -h 'on-release' */corpus/SOURCES.md | wc -l                                        (rc 0 → 2142)
grep -rIl -E '^\s*python3 corpus/|^[A-Z][0-9]+-[0-9]+	' */corpus/*.tsv                (rc 0 → claim-ledger.tsv only)
grep -rIn -E 'cases"? -eq [0-9]+|-eq [0-9]+ \] && \[' */corpus --include='*.sh'          (rc 0 → 20 lines, 2 kagi count asserts)
sed -n '92,112p;180,235p' kagi-shokunin/corpus/claims-declared.sh                        (rc 0)
awk -F'\t' default-mode row scan over corpus/claim-ledger.tsv                            (rc 0)
```

**Not run, deliberately:** `plans/round-46-c1.sh`, `plans/round-46-c2.sh`, `corpus/claim-ledger.sh`,
`corpus/self-counts.py`, and every sibling gate. No receipt was produced by this seat, so no exit line is
quoted as a verdict; every number above is a `grep`/`wc` count whose command is listed. No fetch was made, so
nothing here speaks to the live feed state — C2's freshness value is the observing seats' to measure, and this
report only states what the fleet already holds on that surface.

**Host note:** no package was installed, upgraded or removed; no sysctl, service, user or kernel setting was
touched; no `/home/vgpnk/.omp/agent/RULES.md` install was needed (the scan used `grep`, `find`, `sed`, `awk`,
`wc` only).

---

## 6. Addendum — audit of the landed C1 draft (seat `K46ExecSelftest`)

Read-only audit of `.ufo/waves/round-46/build/K46ExecSelftest/{claims-declared.sh,claims-declared.diff}`,
which landed after §1–§5 were written. I ran `bash -n` on the artifact (a syntax check; it does not execute the
gate) and traced each added case against the gate's two legs by reading `corpus/claims-declared.sh:186-235`.

**Kill rule (block containment) — holds.** BASE's `--run-selftest` block is lines **36–108**
(`if [ "${SELFTEST:-0}" = 1 ]` at `:36`, closing `fi` at `:108`). The diff's only hunk is `@@ -99,8 +99,24 @@`,
old 99–106 → new 99–122; every added line lands between old 101 and 102, and the patched block closes at
`:124`. Nothing outside the block moves. `bash -n claims-declared.sh` → **rc 0**.

**Both count lines moved** — `:118` `[ "$cases" -eq 11 ]` and `:119` `PASS (11 cases)`. The landmine in §2.1/§4.1
is closed in the draft.

**Static kill attribution, traced per case** (independent of the seat's receipt):

| Case | Fixture | Real gate | M1 (report→`:`) | M2 (floor 99) | M3 (`! awk`→`awk`) | E2 (`-le 38`) |
|---|---|---|---|---|---|---|
| 9 | manifest `90 C1` only; plan 90 has C1+C2 headings, SCORECARD has the 90 section | rc 1, `MISMATCH 90 C2 no-manifest-row` | rc 0, no token → **killed** | 90 < 99 → skipped, rc 0 → **killed** | heading found → `continue`, rc 0 → **killed** | 90 > 38 → identical → survives |
| 10 | plan `round-91.md` with a heading, no `## Round 91` section | CLEAN rc 0 (leg 2 `continue`) | unaffected | skipped, CLEAN → passes | 91 proceeds → spurious `MISMATCH 91 C1`, rc 1 → **killed** | identical → survives |
| 11 | plan `round-39.md` heading + appended `## Round 39 — post-move` | rc 1, `MISMATCH 39 C1 no-manifest-row` (floor inclusive) | rc 0 → **killed** | 39 < 99 → skipped → **killed** | heading found → `continue` → **killed** | 39 > 38 → checked identically → survives |

Case 9 alone kills all three, as §4.2 predicted; cases 10–11 are not redundant — case 11 is the **floor
boundary** (`-lt 39` vs `-le 38` diverge exactly at 39, so the E2 equivalence leg is anchored by a case rather
than by luck), and case 10 is the only case whose kill of M3 rests on **rc alone** rather than on a missing
token. The seat's claim "case 11 kills M2; E2 checks 39 identically" is confirmed.

**Residues named, none a kill:**

1. **The count is still duplicated** (`-eq 11` and the literal `(11 cases)`). Both moved this time, but the next
   bump is again a two-line edit that can drift — the exact `instrument-drift` class M46-1 records. Interpolating
   the literal (`printf 'CLAIMS_DECLARED_SELFTEST: PASS (%d cases)\n' "$cases"`) makes divergence impossible and
   is inside the permitted block; the frozen predicate reads the prefix `CLAIMS_DECLARED_SELFTEST: PASS`, so this
   changes no measured value.
2. **`chk` remains presence-only** (`:60-68`, rc + `grep -qF`): a mutant that prints the expected token *and* a
   spurious extra still passes all three cases. This is the plan's declared C1 ceiling (diff review is the
   remaining leg), not a defect of the draft — but it means case count ≠ coverage, and the ceiling should be
   restated at the candidate rather than left implicit.
3. **Case order is load-bearing by accident**: each new case begins with `rm -f "$s/plans/round-39.md"
   "$s/plans/round-91.md"`. The `rm` in case 11 is required (case 10 leaves `round-91.md` behind and `mfix`
   never removes it); the ones in cases 9–10 remove nothing. The ordering holds today; if a case is inserted
   between 10 and 11 the leftover plan is inherited.
4. Nothing in the draft touches the five feeds, the registry, or any C2 surface — causal separability as the plan
   states it holds on the bytes.

### 6.1 Revision 2 — all three residues closed, re-audited

The seat revised the draft (artifact sha256 `8053c85a777c533554ce4509b40d893335fe6c8586f8617fd5c8d12a4e9d66a8`,
`bash -n` rc 0). Re-audited with a **zero-context** diff rather than the hunk summary:

```
$ diff -u0 corpus/claims-declared.sh .ufo/waves/round-46/build/K46ExecSelftest/claims-declared.sh | grep '^@@'
@@ -40,0 +41 @@        # mfix gains the synthetic-plan rm
@@ -70,0 +72,2 @@      # the named-ceiling comment after chk
@@ -102,2 +105,15 @@  # the two count lines replaced; cases 9-11 added
```

- **Containment is now byte-exact, not merely claimed:** the highest old line touched is **103** and the lowest is
  **40**, both inside the `--run-selftest` block's 36–108. No line outside the block differs from BASE.
- **Residue 1 closed correctly:** `printf 'CLAIMS_DECLARED_SELFTEST: PASS (%d cases)\n' "$cases"` — the literal
  is gone, the only remaining count is the `-eq 11` assertion, so a future bump is a one-line edit that cannot
  drift from the printed value.
- **Residue 2 closed as a declared ceiling:** two comment lines after `chk` (`:72-73`) state that a mutant which
  also prints the expected token is not refused there. A comment closes nothing behaviourally — the ceiling is
  now *named at the gate*, which is what the plan's declaration asks for.
- **Residue 3 closed structurally:** `mfix` now removes `plans/round-39.md` and `plans/round-91.md` itself and
  truncates the manifest, the round-90 plan and `SCORECARD.md`, so the per-case `rm` lines are gone and case order
  is genuinely no longer load-bearing. (`$s/mutant-gate.sh` from case 8 still persists across cases; it is
  rewritten before use, so it is inert.)
- The seat re-measured `value=3 killed=3 positive=1 equiv=1 real=1` after the change; my static trace of the three
  cases is unchanged by the revision (the fixtures and expectations are byte-identical to revision 1, only their
  reset mechanism and the count print moved).
