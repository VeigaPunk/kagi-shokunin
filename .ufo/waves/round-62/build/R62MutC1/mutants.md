# R62MutC1 — mutation battery: hardened C1 grammar and C1 counter

Seat `R62MutC1` (mutation-tester), wave `kagi-r62-w1`, kagi round 62 attempt 1.
Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`. Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin`. Scratch
`/fast/scratch/hyaku/kagi-r62/R62MutC1/` (deleted before the seat yielded).

Instruments measured (final bytes at the time of the battery, snapshotted read-only
into scratch; the lane files were never written by this seat):

| instrument | sha256 | baseline |
|---|---|---|
| `plans/round-61-c1-check.py` (hardened grammar, 1710 lines) | `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0` | `python3 -I -B … --selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0 |
| `plans/round-62-c1.sh` (C1 counter, 8-check selftest) | `efe676ebb0d016664705f17c181ecc3331963a4b09fb2f80403f8773170cf62f` | `bash … --selftest` ⇒ `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 |

Every mutant is a byte substitution in its own copy under scratch; each substitution
was asserted to occur exactly once before the copy was written (0 or >1 occurrences
aborts the mutant). The counter was revised three times during the wave
(`19ea1131…` → `d190e6e2…` → `5c71947d…` → `efe676eb…`); the table below is measured
on the final `efe676eb…` bytes, and the pre-fix defects the controls exposed are
listed in the last section.

## Detectors

- **G** (grammar): `C1_CHALLENGE_PARENT=<scratch> TMPDIR=<scratch> python3 -I -B
  <mutant>/round-61-c1-check.py --selftest` — killed iff rc ≠ 0 and the last line is
  `C1_CHECK_SELFTEST: FAIL …`.
- **G-behaviour** (grammar, corroboration): `python3 -I -B
  <mutant>/round-61-c1-check.py --root <fixture tree> --repo <lane> --no-challenge` on
  the frozen fixture the removed rule governs; the pristine hardened checker reads
  `value=1` on every B fixture and `value=0` on the unmodified tree.
- **C1** (counter selftest): `bash <mutant lane>/plans/round-62-c1.sh --selftest`
  (the fake lane carries `plans/round-61-c1-check.py`, as the real lane does).
- **C2** (counter guard, K1 census): `bash … --tree <BASE tree 60b5b7b6>` — pristine
  reads `accepted=5 population=5 guard=0` rc 1.
- **C3** (counter guard, candidate): `bash … --tree <BASE tree + hardened checker
  f2afd9b8>` — pristine reads `accepted=0 population=5 guard=1` rc 0.
- **C5** (counter guard leg d): C3 with the paraphrase table replaced by a non-benign
  P3 (`**A3 item 2 is not withdrawn**`) — pristine reads `paraphrase leg=0`,
  `guard=0` rc 1.
- **C6** (counter guard leg e, Amendment A3): a tree whose checker prints
  `C1_CHECK_SELFTEST: PASS (cases=99)` for `--selftest`, the constant
  `C1_ROUTED: value=0 …` line otherwise, and carries the `NEGATORS` needle without
  depending on it — pristine reads `chal=0`, `guard=0` rc 1.

Pristine control lines on the final bytes (receipt `counter-battery.txt`):

```
D1  C1_COUNTER_SELFTEST: PASS (8/8 checks)                                                          rc=0
D2  C1_BYPASS: accepted=5 population=5 guard=0 (real=1 selftest=0 stub=1 paraphrase=1 chal=0)        rc=1
D3  C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1 chal=1)        rc=0
D5  C1_BYPASS: accepted=0 population=5 guard=0 (real=1 selftest=1 stub=1 paraphrase=0 chal=1)        rc=1
D6  C1_BYPASS: accepted=5 population=5 guard=0 (real=1 selftest=1 stub=1 paraphrase=1 chal=0)        rc=1
```

## Grammar mutants (9)

| id | substitution (exact, one occurrence each) | command | observed | verdict |
|---|---|---|---|---|
| GM1 | in `_asserted_withdrawn`: `if (_seq_in_window(section, m.start(), ("a3", "item", "2"))\n                and not _negated_before(section, m.start())):` → `if (_seq_in_window(section, m.start(), ("a3", "item", "2"))):` (I3 negator test removed) | G | rc 1, `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=b3-negated-withdrawn-unresolved)` | **killed** |
| GM2 | in `item4`: `three_ok = any(not _negated_before(last, m.start())\n                   for m in THREE_RE.finditer(last))` → `three_ok = any(True for m in THREE_RE.finditer(last))` (I4 negator test removed) | G | rc 1, `FAIL (cases=75 failed=1 names=b4-no-three-unresolved)` | **killed** |
| GM3 | in `item5`: `neg_free = m_rp is not None and not _negated_before(last, m_rp.start())` → `neg_free = m_rp is not None` (I5 negator test removed) | G | rc 1, `FAIL (cases=75 failed=1 names=b5-not-rewritten-unresolved)` | **killed** |
| GM4 | `NEG_WINDOW = 5    # the plan's 5-token negator window (a floor, not a parser)` → `NEG_WINDOW = 0    # …` **and** `    low = low[-window:]` → `    low = low[-window:] if window > 0 else []` (window shrunk to 0 tokens; the second substitution is required because `low[-0:]` is `low[0:]`) | G | rc 1, `FAIL (cases=75 failed=6 names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,b5-not-rewritten-unresolved,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator)` | **killed** |
| GM5 | in `item6`, both branches: `ok = len(stamps) >= 3 and bool(superseded) and not denied` → `ok = len(stamps) >= 3 and not denied`; `ok = len(qualifying) >= 3 and bool(superseded) and not denied` → `ok = len(qualifying) >= 3 and not denied` (I6 clause (c), the superseded-stamp requirement, dropped) | G | rc 0, `C1_CHECK_SELFTEST: PASS (cases=75)` | **survives** |
| GM6 | in `item7`: `ok = (_pair_re(frac_a, pa).search(asserted) is not None\n          and _pair_re(frac_b, pb).search(asserted) is not None)` → four independent boundary-delimited token searches for `frac_a`, `frac_b`, `pa`, `pb` on `asserted` (the I7 pairing dropped) | G | rc 1, `FAIL (cases=75 failed=1 names=b7-swapped-pairing-unresolved)` | **killed** |
| GM7 | `_is_negator`: `return t in NEGATORS or t.endswith(NT_SUFFIX)` → `return False` (polarity predicate inverted; the executor's own K5 witness) | G | rc 1, `FAIL (cases=75 failed=8 names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,b5-not-rewritten-unresolved,negator-set-membership,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator,k5-negator-needle-unique)` | **killed** |
| GM8 | in `item6`: `denied = sorted(p for p in I6_DENY_PHRASES if p in last.lower())` → `denied = []` (Amendment A1 clause (d) dropped) | G | rc 1, `FAIL (cases=75 failed=1 names=b6-tail-denial-unresolved)` | **killed** |
| GM9 | in `evaluate`: `count = sum(1 for s, _ in res.values() if s == FAIL)` → `count = sum(1 for s, _ in res.values() if s == HOLD)` (verdict mapping inverted) | G | rc 1, `FAIL (cases=75 failed=17 names=…,only-i1-resolves,…,challenge-plus1-fires-with-unresolved)` | **killed** |

Behavioural corroboration (receipt `grammar-behavior.txt`): GM1 on B3, GM2 on B4,
GM3 on B5, GM4 on B3, GM6 on B7, GM7 on B3, GM8 on B6 each read
`C1_ROUTED: value=0 …` (the forgery is accepted) where the pristine checker reads
`value=1`; GM9 on the unmodified tree reads `value=7`. GM5 on the isolating I6 tree
`W6` (launch line and four derived committer stamps kept, the quoted superseded stamp
and the driver-complete stamp removed) reads `value=0` with `c1: i6 HOLD …
superseded-stamp=none`, where the pristine checker reads `value=1` with
`c1: i6 FAIL … superseded-stamp=none` (receipt `w6-i6-isolation.txt`).

Pristine fixture battery on the final checker (receipt `fixture-battery.txt`):
`REAL value=0`; `B3..B7 value=1` with i3/i4/i5/i6/i7 respectively 0; `P3..P5 value=0`;
`W6 value=1` with i6=0. The five frozen bypass fixtures flip and the three paraphrase
fixtures do not.

## Counter mutants (5)

| id | substitution (exact, one occurrence each) | command | observed | verdict |
|---|---|---|---|---|
| CM1 | in `measure_battery`: `    [[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED + 1))` → `    [[ "$RUN_VAL" != "0" ]] && ACCEPTED=$((ACCEPTED + 1))` (count `value>0` as accepted) | C1, C2, C3 | C1 rc 0 `PASS (8/8 checks)`; C2 `accepted=0 population=5 guard=0` rc 1 (pristine `accepted=5`); C3 `accepted=5 population=5 guard=1` rc 1 (pristine `accepted=0`) | **killed** (by the guard's K1 census and the candidate reading; **not** by `--selftest`) |
| CM2a | `  stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1` → `  stub=1` (verdict-mode stub composition forced to 1) | C1, C2, C3, C5, C6 | C1 rc 0 `PASS (8/8 checks)`; C2/C3/C5/C6 identical to the pristine lines above | **survives** |
| CM2b | in `stub_leg`: `  SL_RC=$?\n  SL_OK=1\n  grep -q '^C1_BYPASS:' "$dir/run.out" && SL_OK=0\n  [[ "$SL_RC" -ne 0 ]] || SL_OK=0` → `  SL_RC=$?\n  SL_OK=1` (the stub leg always returns 1) | C1, C2, C3, C5, C6 | C1 rc 0 `PASS (8/8 checks)` (`stub-refused` passes because both shapes are refused anyway); C2/C3/C5/C6 identical to pristine | **survives** |
| CM3 | the verdict-mode paraphrase loop `  para=1\n  for ((i = 0; i < ${#P_IDS[@]}; i++)); do … [[ "$RUN_VAL" == "0" ]] || para=0\n  done` → `  para=1` (paraphrase leg skips) | C1, C2, C3, C5 | C1 rc 0 `PASS (8/8 checks)`; C2/C3 identical to pristine; C5 `paraphrase leg=1` and `C1_BYPASS: accepted=0 population=5 guard=1` rc 0 where pristine reads `paraphrase leg=0` and `guard=0` rc 1 | **killed** (by guard leg d) |
| CM4 | the verdict-mode challenge block `  chal=0\n  NEG_OLD=…\n  NEG_NEW=…\n  if apply_fixture …; then … if [[ $chrc -ne 0 && $chrc -ne 2 ]] && grep -q 'C1_CHECK_SELFTEST: FAIL' "$WORK/chal.out"; then chal=1; fi\n  fi` → `  chal=1` (challenge composition forced to 1; Amendment A3 leg e) | C1, C2, C3, C6 | C1 rc 0 `PASS (8/8 checks)`; C2 `chal=1` vs pristine `chal=0` (guard 0 both, selftest=0 at BASE); C3 identical (chal=1 both); C6 `C1_BYPASS: accepted=5 population=5 guard=1 (… chal=1)` rc 1 where pristine reads `chal=0` and `guard=0` | **killed** (by guard leg e on the C6 tree) |

## Census

```
MUTANTS: killed=11 survives=3 population=14
```

Derivation: killed = GM1, GM2, GM3, GM4, GM6, GM7, GM8, GM9, CM1, CM3, CM4 = 11;
survives = GM5, CM2a, CM2b = 3; population = 9 grammar + 5 counter = 14.

## Survivors

Each survivor is a coverage finding — the instrument's contract is not changed by
this receipt; the fix is named for the owner.

### S1 — GM5: I6 clause (c) has no isolating selftest case

**Defect.** Removing `bool(superseded)` from both `item6` branches leaves
`--selftest` at `PASS (cases=75)`. The case named
`b6-wholeline-no-superseded-stamp-unresolved` does not isolate the clause: its
replacement line (`- Correction (I6, spot-check D6): supersedes the round-60
stale-lane paragraph — the paragraph's times are correct.`) carries no launch line,
so `item6` returns FAIL at `mlaunch is None` before clause (c) is evaluated. The
mutation is behaviourally live: on `W6` (launch line and four derived committer
stamps kept; the quoted superseded stamp and the driver-complete stamp removed) the
pristine checker prints `i6 FAIL … superseded-stamp=none` (value=1) and GM5 prints
`i6 HOLD … superseded-stamp=none` (value=0). Amendment A1 requires the I6 selftest
to carry the whole-line variant; as written it carries a launch-line case under that
name.

**Fix.** Add a selftest case built from the good fixture by deleting only the quoted
superseded stamp and the driver-complete stamp (keep the launch line and ≥3 derived
committer stamps) and assert `item6(...) == FAIL`; rename the existing whole-line
case `b6-wholeline-no-launch-line-unresolved` so the two clauses are distinct.

### S2 — CM2a: the verdict-mode stub composition is never exercised

**Defect.** `--selftest` calls `stub_leg` directly and asserts `s1=1 && SL_OK=1`; it
never evaluates the composition line `stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]]
&& stub=1`. Forcing `stub=1` changes no observable because both stub shapes are
refused on every measured tree (c1 by the selftest gate, c2 by the constant-printer
`cmp -s` defence), so `stub_c1=stub_c2=1` always.

**Fix.** Extract the composition into a helper used by both verdict mode and
`--selftest`, and add a case with `stub_c1=0` (or `stub_c2=0`) asserting the
composed value is 0.

### S3 — CM2b: `stub_leg` has no negative vector

**Defect.** The refusal predicate is tested only in the positive direction: the
selftest asserts that both stub shapes are refused, so forcing `SL_OK=1` (deleting
the `grep -q '^C1_BYPASS:'` and `[[ "$SL_RC" -ne 0 ]]` discriminators) still passes
`stub-refused`. The leg can therefore be made to report "refused" for every input
without a single case failing.

**Fix.** Run `stub_leg` on the existing reject-stub tree (`make_reject_stub_tree`:
gate-passing, `value=1` for every fixture, `measure_battery` returns 0) and assert
`SL_OK=0`; that is the missing negative vector.

## Instrument defects observed during the battery (not mutants)

These are pre-fix defects the battery's controls exposed; each was reported to the
owning executor and is fixed in the final bytes above. They are recorded because a
battery that had not run the pristine control on the candidate tree would have
reported a false "killed" verdict.

1. **`selftest_gate` case-count parse.** `ST_N="$(grep -oE '[0-9]+' <<<"$line" | head
   -1)"` read the `1` of `C1_CHECK_SELFTEST` (first digit run) instead of the
   parenthesised count: a pristine run on the BASE tree printed `cases=1`, so guard
   leg b (`N >= 57`) could never be 1 and `guard=1` was unreachable. Minimal repro
   `printf 'C1_CHECK_SELFTEST: PASS (52 cases)\n' | grep -oE '[0-9]+' | head -1` ⇒
   `1`. Fixed in `19ea1131…` (parenthesised parse).
2. **`measure_battery` rejected-tail status leak.** The loop's last command is
   `[[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED + 1))`; when the last fixture is
   rejected the `&&` list returns 1, the loop returns 1, and the function returned 1,
   so the counter aborted `c1-counter: SETUP measure leg failed` (rc 2, no verdict) on
   the hardened tree — the candidate reading was unreachable on any tree whose last
   fixture is rejected. Fixed in `d190e6e2…` (`return 0` after the loop plus selftest
   check 7 `measure-leg-rejected-tail`).
3. **Check 7's missing scratch dir.** On `d190e6e2…` the new check 7 wrote into
   `$WORK/st3.reject` before creating it, so `--selftest` read `FAIL (6/7 checks)
   failed=measure-leg-rejected-tail` on the pristine counter. Fixed in `5c71947d…`
   (`mkdir -p "$WORK/st3.reject"`).
4. **Plan fixture B6 was vacuous under the frozen I6** (the tail-only substitution
   left the quoted superseded stamp and the driver-complete time on the line), so a
   plan-faithful checker read B6 accepted and the target 0 was unreachable. Reported
   by the two C1 executors before any candidate reading; the L1's Amendment A1 added
   I6 clause (d) (the line must not assert the superseded paragraph is correct) and
   B6 now flips (`i6=0`, `value=1`) on the final checker. My battery confirms the
   flip; the frozen predicate, target, POP, fixtures and kill rules were not amended.

## Scratch

All clones, fixture trees and mutant copies live under
`/fast/scratch/hyaku/kagi-r62/R62MutC1/` and are deleted before the seat yields.
Nothing citable was written under `/tmp`; no secret value is present in any receipt.

SEAT-STATUS: complete
