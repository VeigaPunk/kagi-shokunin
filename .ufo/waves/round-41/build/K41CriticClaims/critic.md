# K41CriticClaims — falsification of round-41 claims C1/C2 and controls (pre-scoring)

All measurements executed at sandbox clone `/fast/scratch/hyaku/kagi-r41/K41CriticClaims/work`
(`git clone --shared` + `git checkout --detach 5142b52`, `rev-parse --show-toplevel` verified = sandbox).
Lane untouched; lane HEAD confirmed `5142b522fb905a237cb01aaa582b8e4543496bdd`; `git diff --stat
19025d9 -- corpus/rendered-text-v1.py corpus/SOURCES.md corpus/source-fetches.tsv` = empty (worktree
== BASE for every C2 input). Full command/output transcripts: `evidence.txt` (same directory).

## (a) No-work readings — VERDICT: honest; C1's is trivially reached and is not a do-nothing verify control; C2's is honest and unreached-by-no-work; one receipt defect in the controls script.

- C1 no-work: measured `0`, rc 0 at the predeclaration sandbox (`bash plans/round-41-c1.sh` → `0`).
  It is reached by the file-absence short-circuit `[ -f "$GATE" ] || { echo 0; exit 0; }` — the
  counter exits before building any fixture, so the reading proves only "no gate file exists".
  It is NOT a behavioral do-nothing control: the true do-nothing is the existing
  `corpus/claim-ledger.sh verify` in the gate's role, and that also reads 0 (it accepts all four
  forgeries — statically confirmed from its contract, claim-ledger.sh:26-28: a row passes when the
  exit code matches AND the expect ERE matches the LAST non-empty output line, so `^[0-9]+$`
  matches `54` and an `echo` rebound prints its own expect line). Hence no-work 0 == blanket-accept
  0 == existing-verify-as-gate 0 == refuse-all 0: five indistinguishable worlds. Discrimination
  rests entirely on target N=4 + P0 acceptance, both frozen. Not a defect: fail-closed by
  construction, 0 can never pass, and the plan assigns the existing-gate measurement to the
  reviewer seat (BEFORE evidence). I did not run verify (once-per-seat budget preserved).
- C2 no-work: measured `1`, rc 0 at the predeclaration sandbox; selftest rc 0 with
  `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`. Honest: a=0 (BASE paragraph names no S### id),
  b=0 (frozen quote absent), c=1. Target 3 is not reachable by doing nothing — reproduced.
- DEFECT (receipt fidelity, not counter logic): `plans/round-41-controls.sh` emits
  `C2 BASE N=…` by running `bash plans/round-41-c2.sh` in the lane working tree with no commit pin
  (contrast: its own decoy fixture is built from `git show 19025d9:…` bytes, and the C1 counter pins
  BASE/P0 via git show). It is labeled BASE but measures the checkout it happens to run in. Today it
  reads 1 only because the worktree matches 19025d9 (verified); run once post-landing, as the plan
  prescribes ("runs the frozen counters and controls once" after integration), it will print the
  candidate's N=3 into `c2-base-19025d9.txt` — a self-contradicting receipt. Smallest safe
  correction: build the control from `git archive 19025d9` into scratch and invoke
  `bash <scratch>/plans/round-41-c2.sh` there (the counter `cd $(dirname $0)/..`, so it binds to the
  scratch tree; note only `$RTV1` is overridable — `SOURCES.md`, `source-fetches.tsv` and the
  `find .ufo/waves` are cwd-relative, so a checkout is the only faithful way).

## (b) Positive control P0 — VERDICT: fair legitimate state; zero R1/R2/R3 violations.

Measured with plain python over `git show` bytes (gate not run):
- `cmp` of the journal at 6f1588c vs 5142b52: identical.
- Ledgers 6cc8850 vs 6f1588c: 104 lines each, 86 claim rows, id sets equal, no added/removed rows;
  full-file `diff` touches exactly 6 lines: R13-01, R21-02, R24-06, R31-02, R33-02, R34-03.
  For all six: command, exit, timeout and column count identical (five notes differ — prose, not a
  gate input); only the expect cell changed.
- The P0 journal has exactly 6 migrations, one per changed id — 0 R1 violations (all changed rows
  journaled), 0 R2 violations (`old_expect` == base expect literally, `command` == candidate
  command literally, `new_expect` == candidate expect literally for every entry; no orphans).
- Every literal passes the frozen R3 rule: R13-01 `^50$`→`^54$`; R21-02/R31-02/R33-02/R34-03
  SOURCES_CENSUS 93→96-row literals (parens escaped, no bare metacharacters); R24-06
  `^ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d…$`. 12/12 journal literals clean.
- Consistency cross-check: F4's frozen rebound constant (`count=54 sha256=52e7ba8d…`) equals
  R24-06's P0 expect. P0 is the honest round-40 landing.

## (c) R3 vs future expects — VERDICT: two historical legitimate migrations would be refused if replayed; all six round-40 literals pass; rule is expressible for exact-match intents; intended calibration, not a defect — but the gate author must expect it to bite.

Every changed expect across all committed journals (`.ufo/waves/*/expectation-migrations.json`,
each `git show` at 5142b52; schemas vary: round-23 `expectation_changes{old,new}`, round-24
`migrations[].expect{old,new}` + `added[].expect`, round-25 rows `[id,command,expect]`,
round-34 `assimilation` list, round-35 `changes[]`, round-38/40 `migrations[].{old_expect,new_expect}`):
- ALL literal (R3 OK): every entry of rounds 23, 34, 35, 37, 38, 40 and all round-24/25 entries
  EXCEPT the two below. Full list in `evidence.txt` §5.
- R3 WOULD REFUSE (named):
  1. round-24 journal R13-03 `new` = `^CELL_AUDIT: CLEAN \(cells=[0-9]+ row_pointed=[0-9]+ …
     orphans=[0-9]+ host_skipped=[0-9]+\)$` (21 bare `[`, `]`, `+`) — a legitimate generalized
     summary pattern, refused verbatim as a future expect.
  2. round-25 journal R11-08 `new[2]` = `^CITATION_GATE: CLEAN \(cites=[1-9][0-9]* docs=[1-9][0-9]*
     unresolved=0 ephemeral=0` — refused (no trailing `$`; bare `[`,`]`,`*`).
  (Excluded from the list: round-25 `[6]` command cells `grep -cE '^R[0-9]+-[0-9]+' …` and
  round-38 `observed_at_candidate` prose — R3 governs expect cells, not commands or prose.)
- Consequence: R3 refuses the corpus's own historical count-summary style. Any future migration of a
  CELL_AUDIT/CITATION_GATE/SOURCES_CENSUS row to a `[0-9]+` form is refused; authors must pin exact
  numbers (the literal style the six round-40 migrations and P0 already use, and literal
  CELL_AUDIT/CITATION_GATE forms exist historically). No exact-match intent becomes inexpressible —
  every literal has an escaped spelling. The kill rule protects exactly the six literal round-40
  migrations, which pass. Frozen-intent tradeoff, disclosed here; no plan change requested.

## (d) C2 degenerate paragraph — VERDICT: yes, reaches 3; measured by the frozen counter itself; disclosed ceiling, not an undisclosed defect.

Construction (built from `git show 19025d9:corpus/rendered-text-v1.py`, only the Sources paragraph
replaced, one line):
`Sources (degenerate falsification probe): S095 S097. Frozen quote: "Matches Unicode whitespace characters (as defined by`
Measured with the frozen counter (`RTV1=<degenerate> bash plans/round-41-c2.sh`, cwd=lane): **N=3, rc 0.**
Term attribution: (a) satisfied by mere citation of non-superseded ids — superseded-set membership is
the only registry link, so a name-drop passes (S095/S097 are not in any `supersedes` cell);
(b) satisfied by the frozen quote as a raw substring plus a binding that exists independently of the
paragraph (`.ufo/waves/round-40/capture/S095.body` sha256 == source-fetches.tsv col-10
`ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1`, measured; `locate` rc 0);
(c) selftest PASS (22 cases). The reviewer would not accept this paragraph as a grounding
declaration — it asserts nothing and carries the quote as decoration.
Honest ceiling (one sentence): C2 certifies only citation shape, one frozen quote substring, and a
body binding that does not depend on the paragraph, so it cannot distinguish a grounded declaration
from a name-drop — exactly the disclosed ceiling of §C2 ("it does not check that every sentence of
step 5 is grounded. That check is the round's reviewer item K41ReviewDocs").
Observation: term (b)'s `locate` invokes the hard-coded `corpus/rendered-text-v1.py`, not `$RTV1`,
so the binding tests the landed lane file — correct at landing, worth knowing when reading receipts.

## (e) File-level separability — VERDICT: disjoint read sets; C1 verifies without C2 landing (proved statically and empirically).

- C1 (`plans/round-41-c1.sh` + gate) reads: `corpus/expect-journal.sh` (via `$GATE`),
  `corpus/claim-ledger.tsv` **only at pinned commits** 6cc8850 and 6f1588c (git show),
  `.ufo/waves/round-40/expectation-migrations.json` only at 6f1588c (git show), scratch fixtures it
  writes itself. Nothing else.
- C2 (`plans/round-41-c2.sh`) reads: `$RTV1` = `corpus/rendered-text-v1.py` (+ the hard-coded lane
  copy for `locate`), `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
  `.ufo/waves/**/capture/S095.body` (find).
- Intersection: **empty**. `rendered-text-v1.py`: C2 only. `corpus/SOURCES.md`: C2 only.
  `corpus/claim-ledger.tsv`: C1 only (and only committed bytes, immune to worktree state).
- Empirical: in the sandbox, with `corpus/rendered-text-v1.py`, `corpus/SOURCES.md`,
  `corpus/source-fetches.tsv` present vs moved away, the C1 counter printed byte-identical output
  (`0`, rc 0) both with the gate absent and with an accept-all stub gate — 4/4 runs identical.
  "C1 verifies without C2 landing": confirmed at the interface level; the real candidate gate, whose
  frozen interface takes only `--base-ledger/--ledger/--journals`, cannot pull C2 files in.

## (f) Kill rules — VERDICT: two ambiguities, each settled by a named sentence; one measurement gap; nothing admission-blocking.

1. C1 "any control reads above 0": `plans/round-41-controls.sh` also emits C2 controls whose honest
   readings are nonzero (C2 BASE N=1; decoy N≤2). Settling sentence: §C2 "No-work control at BASE
   19025d9: N = 1" — controls above 0 are expected, so the clause must scope to C1's own three
   controls (blanket-refuse, blanket-accept, no-gate), each expected 0 per §C1.
2. C1 "…or any of the six round-40 migrations is refused by the gate at the round-41 landing":
   ambiguous on which `--base-ledger` the landing check uses. Against 19025d9's ledger the six rows
   are unchanged from base, so R1/R2/R3 never evaluate them and the clause is vacuous. Settling
   sentences: R1's own definition ("a row … whose command or expect differs from the base") plus the
   counter's frozen `BASE=6cc8850` — the clause is only testable with the 6cc8850 ledger as base.
   Smallest safe correction: record in the round report that the landing-time check runs
   `--base-ledger` from 6cc8850 (interpretation note; no lane edit by this seat).
3. C2 "selftest drops below 22 cases": measured `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)` at
   BASE — exactly at the floor. The counter's (c) checks only rc 0 + `PASS`, not the count, so
   admission requires a separate case-count measurement at the landing tree; the kill-rule sentence
   itself is unambiguous (threshold 22), but no seat is named to run it. Gap, not ambiguity: the
   landing verifier must record the count explicitly.
4. C2 "any binding fails at the landing tree": settled by the counter predicate itself (term (b)
   chain: quote present ∧ sha(col 10) == sha256(S095.body) ∧ locate rc 0); no ambiguity.
5. C1 "counted only if the gate accepts the positive control P0 (rc 0)" and the F1–F4 tokens:
   unambiguous; the counter's `grep -qxF` full-line token match and rc==1 requirement are
   fail-closed (a trailing-whitespace token line undercounts, in the safe direction).

## Routing

- Defect 1 (controls script): `C2 BASE N=` control measures the working tree, not 19025d9 → route to
  the L1/planner: build that control from `git archive 19025d9` into scratch, or rename the receipt.
- Gap 3 (selftest count measurement at landing) → route to the L1/landing verifier.
- Ambiguity 2 (landing gate base ledger) → record the 6cc8850-base interpretation in the report.
- C1/C2 counters and P0 otherwise survive falsification: no-work readings honest and reproduced,
  positive control clean, counter discrimination (target 4 vs three C1 controls 0; target 3 vs
  no-work 1 and decoy ≤2) intact.

Tooling installs: none. Scratch sandbox deleted before yield.
