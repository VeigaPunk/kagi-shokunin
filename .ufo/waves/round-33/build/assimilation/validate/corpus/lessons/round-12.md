# Round 12 lesson — a ceiling claim needed re-measuring

Axis moved: **depth 7 → 8**. Round 11's plan named calibration as the next move,
but the scorecard's *lowest* cell was depth (7), and its ceiling was written as a
deliberate scope refusal ("vault-side structure stays unmapped"). That ceiling is
real — and it was doing double duty: it hid a reachable, unmeasured surface
inside the domain. Depth was not capped by scope; it was capped by an unread
parser. This round read it.

## What landed

`corpus/op-ref-probe.sh` (the gate) + `corpus/knowledge/op-ref-consumption.md`
(the contract) + SKILL.md decision/failure/anti-pattern/checklist/falsification
rows + one new `drift-symbols.tsv` pin (the `cmd_run` L248 `exec op run` line —
the masking premise) + two ledger rows (`R12-01`, `R12-02`).

Measured at the shipped revision (2026-09-28, `op` 2.35.0):

```
bash corpus/op-ref-probe.sh            → OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)  exit 0
bash corpus/op-ref-probe.sh --selftest → OP_REF_SELFTEST: PASS (29 cases)                                          exit 0
bash corpus/drift-pins.sh              → DRIFT_PINS: CLEAN (files=15 symbols=20)                                   exit 0
bash corpus/surface-census.sh          → SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)  exit 0
bash corpus/transcript-scan.sh         → TRANSCRIPT_SCAN: HITS=2 (cells=888 patterns=32+5 warns=2)                  exit 1 (by design)
```

## The finding: `op.env` has two parsers, and only one of them loads it

`the-janitor refs` is an `awk` over raw lines (`cmd_refs` L234); `the-janitor
run` is `exec op run --env-file="$ENV_FILE" -- "$@"` (`cmd_run` L248). Every
claim below was measured on generated plain-valued fixtures — no vault read, no
reference resolved:

| Line shape | `op run` | `refs` | Consequence |
|---|---|---|---|
| `K = v`, `export K=v`, `k=v` | injected | **absent** | inventory undercounts what loads |
| `K="op://…"` (quoted ref) | **resolved as a reference** (one-off probe: vault-not-found, exit 1, ~2 s) | reported as a **plain value** | audit false negative on a live credential |
| `K=ab#cd` | `ab` — `#` comments an unquoted value anywhere | redacted (no signal) | silent truncation, invisible in the file's "shape" |
| `K=$X`, `${X}` | expanded (file then process env; unset → empty) | redacted | the inventory shows a literal that is not a literal |
| duplicate `K=` ×3 | last wins | listed 3× | count inflation |
| `--env-file` twice | last file wins; file beats shell | n/a | inverse of the usual dotenv default |

And the masking contract is narrower than `op run --help` reads: **only
reference-resolved values are concealed on stdout/stderr**. Plain values pass
through unmasked — measured in four shapes (`printenv`, subshell `echo`, a
substring in a longer line, a shell-env-only value), and `--no-masking` changes
nothing for them. `cmd_run` passes no masking flag, so this is the default path:
"the handler's output is masked" is false for every plain-valued key. Given
`op.env`'s observed reality (8 refs / 2 raw identifier values), the *current*
file leaks nothing material through `run` — but the convention "everything is a
ref" is unenforced, and this entry now says exactly what masking does and does
not cover.

## Two defects found in flight (both by real use, not by a lane)

1. **`stamp` silently replaced the row set.** `stamp PATH…` regenerates
   `stamps.tsv` from exactly the paths given: an in-flight 10-path invocation
   dropped 18 of 28 rows, and `verify` could not notice (it iterates the file's
   rows, so a shrunken file is *smaller coverage*, not a failure). Fixed: a
   shrink is refused (exit 2) unless `--prune` is passed; two `--selftest` cases
   (`stamp-shrink-refused`, `stamp-prune-allowed`); a count claim row pins the
   row count. This is the round-10/11 defect class recurring: a gate whose
   *coverage set* is not itself claimed.
2. **`trap` + `local` under `set -u`.** The probe's first revision re-ran its
   EXIT trap with a `local` already out of scope (`d: unbound variable`) — the
   round-11 lesson's "a subcommand only the operator path calls is untested
   until a case calls it", this time for the *cleanup* path. Fixed with global
   scratch + one `cleanup` trap; the run is now silent on exit.

Also corrected in-repo as stale numbers (the round-11 rule: a number a doc cites
is a claim): `claim-ledger` selftest case count 39 → 43 (four new cases),
`claims=11` → 14, `stamped=28` → 32, `symbols=19` → 20, and two genericized
citation-gate counts (`docs=37`).

## Bounds (named, not implied)

The masking of *ref-resolved* values, the mask token's shape, `op inject`/`op
read` execution semantics, and `--no-masking` against a ref are **not measured**
— each needs a resolved reference, i.e. the vault, which this repo does not
touch. They are listed in the entry's §Bounds with that reason rather than
implied by a table. The probe's own safety is structural (POLICY refuses any
op-side file carrying a ref token before exec), and the one-off rows that could
not be mechanised are marked as one-offs in the entry.
## L2 wave (12 lanes, one batched call, and a freeze that was not one)

Dispatched in one batched call: planner, connector, 2 executors (masking,
parsing), 2 scouts (help surface, stale sweep), reviewer, critic, sentinel,
labrat, mutation-tester, distiller — the MISSION route map, 12 lanes ≥ the
required 8. Every lane was given the artifact hashes at freeze time and told to
report which revision it read and what moved.

**The process finding first.** I declared a frozen revision and then kept
editing: the probe went v1 → v4 and the entry grew twice while the wave ran. The
reviewer's report is the receipt — *"the freeze was stale on arrival"* — and four
lanes independently recorded the same movement. That is the round-9 lesson
("gate before cite") recurring a third time, now at the wave's cost rather than
the prose's. The honest reading: a freeze is only a freeze if the author stops
writing. What the wave still delivered is real, because each lane re-ran the
gates itself and the final numbers were re-measured after the last edit; what it
cost is that the *canned* comparisons some lanes made were against a revision
that no longer exists.

| Finding (lane) | Verdict | Action |
|---|---|---|
| `--fixture DIR` could hand `op` a ref-bearing `absent.env`, a **file** named `adir`, a symlink or a FIFO env file (sentinel F1/F2/F3, CRIT) | **real, must-fix** | guard is now per-path: every `--env-file=` argument passes `guard_op_file()` inside the single `op_exec()` chokepoint; symlinks, FIFOs, sockets and devices are refused; `absent.env` must not exist and `adir` must be a real directory; four selftest cases, and I re-ran the sentinel's four poison trees by hand — all `POLICY` exit 2 with an **empty stub log** |
| header claimed "every invocation goes through `op_run()`" while four sites called the binary directly (reviewer F1, WRONG) | **real** | the claim is now true: one chokepoint (`op_exec`) guards every `--env-file=` argument it is about to pass; `grep -n '"$OP_BIN"' op-ref-probe.sh` returns the chokepoint and the `command -v` check, nothing else |
| `stamp` could still shrink silently three ways: equal-count **path swap**, missing-final-newline off-by-one, **blank-line** substitution that passes a `grep -c` count while `verify` loses a row (mutation lane, 5/12 caught overall) | **real** | the guard is per-path membership (any pinned path not named again is refused) and counts non-blank lines; a blank row is a setup error; `R12-03` counts non-blank lines; two more selftest cases |
| masking rows and the `--evaluate` path are not self-verifying: a mutated gate that reuses the default row as the `--no-masking` row is invisible, and a hand-forged observation file passes (mutation m10/m11 + forged-obs case) | **real, bounded** | recorded as §Bounds.11-12 with the mutation lane's method; the compensating control is the revision stamp plus diff review (a mutated gate in the repo is `STALE`, not green) |
| `K-BAD=v` / bare key / lone `=` / BOM abort the whole dotenv parse while `refs` exits 0 with a healthy inventory (executor B, labrat, scout-help independently) | **real, new class** | §2b + two gate signatures + a `malformedrefs` blindness check |
| `--env-file` **merges** (union) with per-key last-wins, not "only the last file" (executor B) | **real** | union check added; §4 corrected |
| `op run` trims values inherited from the parent and forces `GOTRACEBACK=none` (executor B) | **real** | §4 row added; `inh` check added |
| digit-leading and indented keys are injected but invisible to `refs`; `${K:-default}` supported; single quotes suppress expansion (executor B, labrat) | **real** | contract rows + fixtures extended (divergent 3 → 5) |
| `read <dir>: is a directory`; `--env-file=-` is a literal name; `/dev/stdin` works; FIFO env files hang without a writer (labrat) | **real** | one signature row (directory) + §2b/§8 notes; the rest stay one-off observations |
| masking scope confirmed in four shapes + stderr + full-env multiset, and `--no-masking` is a no-op for plain values (executor A) | **confirms C1** | evidence grading added to §3: two rows are gate-mechanised, three are one-off (author + this lane) |
| C3's resolver half (a quoted `op://…` is resolved) is an author one-off, never independently verified (planner, reviewer) | **real, bounded** | §Bounds.10 now says exactly that |
| 16 stale rows in live docs that quote superseded counts (`symbols=19`, `claims=11`, `stamped=28`, `39 cases`, `absent=0`, a 15-case census selftest, `refs` completeness) (scout) | **real** | all 16 corrected in place, plus the numbers this round itself changed (they moved twice: 34→44 checks, 15→21→29 cases) |
| a **foreign commit series** landed in this repo mid-round (`e0a04d8`, `7c3377c`, `4391b3b`: the round-8 aggregator box-3 cold-run lesson) citing `.ufo/reports/round-8/aggregator.md`, a pointer that no longer resolves anywhere in the main repo's history | **real, not mine** | the three dead tokens are labelled where they are cited (the repo's own rule) and reported as a foreign-artifact defect; the file is stamped because this report cites it |
| `cites≈505 docs=39`-style counts move with every doc edit; `docs` 39 → 42 this round | **expected** | the corpus's `≈`-convention and the verdict-as-claim rule already cover it; cited again in the report |
| no sibling verifier duplicates the `op.env` behaviour probe; nearest overlap is kagi's own `surface-census.sh --verbs --deep` (connector) | **confirms ownership** | reported, not absorbed; the shared-contract question stays with the integrator |
| distiller split the entry's fused prose into 24 atomic claims and flagged 3 as weaker-evidence-than-stated (masking shapes, one-offs, help-text rows) | **accepted** | §3 evidence-grading + §Bounds.10-13 |
| reviewer: 66 VERIFIED / 1 STALE / 1 WRONG / 5 UNCHECKABLE across 73 claims | — | the WRONG item is closed above; the STALE item was the in-flight revision; the 5 UNCHECKABLE are the §Bounds class |
