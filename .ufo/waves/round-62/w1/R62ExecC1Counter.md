# R62ExecC1Counter — C1 counter seat report (kagi round 62, attempt 1)

Seat: R62ExecC1Counter (executor). Lane repo `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`. Frozen plan `plans/round-62.md`
§C1 (+ Amendment A1, appended before any candidate reading). No git/jj mutation anywhere;
all tree materialisation via `git archive` / `tar` into `${HYAKU_SCRATCH}/kagi-r62/R62ExecC1Counter/`.

## Deliverables (write scope: exactly these + receipts)

| file | sha256 |
|---|---|
| `plans/round-62-c1.sh` | `5c71947dcafa9d88f49454f12b9ed39b7fbcefb89d7570728aae6b608c2882bd` |
| `plans/round-62-bypass.tsv` | `16fc5ba6d8b4b32db23ee91d27d72531377a608b11aacdc35d073962bd707ad8` |
| `plans/round-62-paraphrase.tsv` | `de5982b716c5bf14b509bb62af9a852faa7206204ea0d7305c699a24a7fb41d1` |

The TSVs carry the plan's §C1 fixture tables verbatim (header `id<TAB>file<TAB>anchor<TAB>replacement`,
B3..B7 / P3..P5, no tabs inside cells; all five anchors measured exactly once at BASE).

## Counter behavior

Modes: `bash plans/round-62-c1.sh [revision]` (default BASE), `--tree DIR`,
`--selftest [revision|--tree DIR]`, `--no-challenge [revision|--tree DIR]`.

Verdict run: resolves the tree (revision → `git archive`; `--tree` → tar copy excluding
`.git`/`.jj`, QM74 refusal if scratch resolves inside the measured tree), exports
`TMPDIR` and `C1_CHALLENGE_PARENT` into run scratch, then:

1. **Selftest gate before any verdict** — the tree's `plans/round-61-c1-check.py --selftest`
   must exit 0 with a `C1_CHECK_SELFTEST: PASS` line (both `(N cases)` and the frozen
   `(cases=N)` spellings parsed; the parenthesised count is extracted, never a bare
   digit run). No PASS line → refuse: `c1-counter: refuse: …` + exit 2, no `C1_BYPASS:` line.
   A checker whose `--selftest` output equals its measurement output byte-for-byte is
   refused as a constant line printer (`cmp -s`, checked on fixture B3 before the
   value-token parse).
2. **Measure leg** — each B3..B7 fixture applied to a fresh tree copy (anchor must occur
   exactly once, else SETUP; 0 or >1 fails closed), measured with
   `python3 -I -B <copy>/plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge`;
   `accepted++` iff the parsed `value=` token is `0`. `FAIL`/missing token → SETUP.
3. **Guard legs** — (a) `real`: unmodified copy reads `value=0`; (b) `selftest`: PASS
   line carries N ≥ 57; (c) `stub`: two printer-stub trees refused — c1 the frozen C1-1
   constant `C1_ROUTED: value=0 …` line (gate-refused) and c2 a constant printer
   self-attesting `C1_CHECK_SELFTEST: PASS (cases=99)` (gate-cleared, then refused by the
   constant-printer defence); each must yield non-zero rc and no `C1_BYPASS:` line;
   (d) `paraphrase`: P3/P4/P5 each read `value=0`.
4. **Verdict** — exactly one line
   `C1_BYPASS: accepted=A population=5 guard=G (real=… selftest=… stub=… paraphrase=…)`;
   exit 0 iff guard=1 and accepted=0; 1 otherwise; 2 SETUP. Refusals/SETUP print only
   `c1-counter:` lines — never a line matching `^C1_BYPASS:`.

`--selftest` runs 7 checks (bypass-tsv-shape, paraphrase-tsv-shape,
fixture-apply-exactly-once, checker-selftest-pass, value-parse-unmodified, stub-refused
[both shapes], measure-leg-rejected-tail [synthetic gate-passing checker that prints
value=1 for every fixture]) → `C1_COUNTER_SELFTEST: PASS (7/7 checks)` rc 0,
`FAIL (k/7 checks) failed=…` rc 1.

`--no-challenge` runs the tree's checker diagnostically on the unmodified copy and
prints its output verbatim plus `c1-counter: no-challenge value=V rc=R`; exit 0 iff V=0.

## Evidence (receipts: `.ufo/waves/round-62/build/R62ExecC1Counter/`)

| receipt | command | result |
|---|---|---|
| `base-run.txt` | `bash plans/round-62-c1.sh 60b5b7b60b76629633110a5b4adac883193c8b2a` | `C1_BYPASS: accepted=5 population=5 guard=0 (real=1 selftest=0 stub=1 paraphrase=1)` rc 1 — K1 census holds (selftest=0: BASE checker's 52 cases < 57) |
| `candidate-run.txt` | `bash plans/round-62-c1.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin` | `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1)` rc 0 — target met (hardened checker `f2afd9b8…`, `PASS (cases=75)`) |
| `stub-tree.txt` | `bash plans/round-62-c1.sh --tree <scratch stub tree>` | `c1-counter: refuse: tree checker --selftest printed no C1_CHECK_SELFTEST: PASS line (rc=0) — no verdict`, rc 2, no `C1_BYPASS:` line |
| `selftest-base.txt` | `bash plans/round-62-c1.sh --selftest` | `C1_COUNTER_SELFTEST: PASS (7/7 checks)` rc 0 |
| `selftest-candidate.txt` | `bash plans/round-62-c1.sh --selftest --tree <lane>` | `C1_COUNTER_SELFTEST: PASS (7/7 checks)` rc 0 |
| `paraphrase-run.txt` | per-fixture checker runs on P3/P4/P5 copies of the candidate tree | each `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0` rc 1 — benign rewording holds on the hardened checker |
| `sha256sums.txt` | `sha256sum` of the three files | hashes above |

Supplementary: the pre-fix candidate run's per-fixture artifacts
(`run-20261107T182130Z-3143022/meas.B*.out`) show B3..B7 each `value=1` on the
hardened checker — every forgery rejected, B6 via Amendment A1 clause (d).

## Defects found and fixed in-wave (all in my own file, found by peers)

1. **Selftest case-count parse** (R62ScribeEntry + R62MutC1, independently):
   `grep -oE '[0-9]+' | head -1` grabbed the `1` in `C1_CHECK_SELFTEST`, so
   `cases=1` and leg (b) could never hold. Fixed by extracting the parenthesised
   count; unit-checked on `(52 cases)`, `(cases=65)` and FAIL lines.
2. **Rejected-tail return path** (R62ScribeEntry + R62MutC1, independently):
   `measure_battery`'s loop ended with `[[ "$RUN_VAL" == "0" ]] && ACCEPTED+=…`,
   returning 1 whenever the LAST fixture was rejected — invisible at BASE
   (all accepted), fatal on the candidate (`SETUP measure leg failed`, rc 2,
   no verdict; reproduced live by the first candidate run). Fixed with
   `return 0`; `--selftest` check 7 (`measure-leg-rejected-tail`) now exercises
   exactly this path with a synthetic gate-passing checker that rejects every
   fixture.
3. **Stub-leg coverage** (R62MutC1, CM2): the verdict-mode stub leg's two
   discriminators were unobservable for the frozen stub shape (the gate refuses
   first). Added stub shape c2 (constant printer self-attesting a passing
   selftest) so the constant-printer `cmp -s` defence and the value-token
   SETUP path are live; `stub=1` iff BOTH shapes are refused. The mutation
   tester's proposed alternative (fake PASS + value line per argv) was rejected:
   it is argv-aware fabrication — the named ceiling class — and would have made
   the candidate run read guard=0.
4. **Selftest check-7 setup bug** (self-found on first `--selftest` run): the
   reject-leg redirect target directory was never created → `FAIL
   (6/7) failed=measure-leg-rejected-tail`. Fixed with `mkdir -p`; both
   `--selftest` receipts now read `PASS (7/7 checks)`.

## Plan defect reported (not amended by me)

**B6 × I6 conflict** — frozen fixture B6's tail-only substitution keeps every
token the frozen I6 clause tests, so a plan-faithful hardened checker reads B6
accepted; target 0 unreachable, K2 unfireable for B6. Reported to L1 KagiR62
before any candidate reading; resolved by **Amendment A1** (I6 gains clause (d):
the correction line carries none of `times are correct`, `times are right`,
`is correct`, `are correct`, case-insensitive). The counter is unchanged by A1 —
it applies the frozen tables verbatim; the grammar seat's checker
(`f2afd9b8…`) implements clause (d) and B6 now reads rejected. Both BASE and
candidate receipts name A1.

## Risks / ceilings

- The candidate reading is bound to the grammar seat's checker bytes
  (`f2afd9b8…`, `PASS (cases=75)`) present in the lane working tree at measure
  time; if the L1 integrates different checker bytes, the candidate receipt must
  be re-taken (the counter itself is checker-agnostic — it measures whatever the
  tree carries).
- `--tree` mode tar-copies the working tree including uncommitted sibling edits;
  the candidate receipt therefore measures the integration-time working tree,
  not a commit. Named, not hidden.
- Fabrication ceiling (inherited, unchanged): a checker that fabricates per-argv
  selftest PASS lines plus tree-accurate value lines defeats any printed-
  observable counter; the constant-printer and gate-refusal classes are closed,
  the argv-aware imitation class is the round-61 K2 ceiling.
- The counter trusts the TSVs' frozen ids/order (B3..B7, P3..P5); a malformed
  table is SETUP, never a partial population.
- No tool installs this seat (bash/python3/grep/sed/cmp/tar/git-archive only).

## Scratch

`/fast/scratch/hyaku/kagi-r62/R62ExecC1Counter/` (run dirs, stub trees, paraphrase
work, throwaway driver `paraphrase-receipt.sh`) — deleted before yield; no citable
evidence lived under `/tmp`; no credentials touched.

SEAT-STATUS: complete
