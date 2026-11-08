# R63MutC1 — mutation battery over the hardened C1 checker and the C1_RESIDUAL counter

Seat `R63MutC1`, role mutation-tester (attack seat), wave `kagi-r63-w1`, kagi round 63
attempt 1. Read-only over the lane: no lane file was written, no git/jj command was run,
no lane index touched. Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc` (extracted
with `git archive` into scratch). Every mutant is a copy under
`/fast/scratch/hyaku/kagi-r63/R63MutC1/`; the lane instruments were never edited.

Detector for every checker mutant: the mutated copy's own `--selftest` (killed iff exit
non-zero or no `C1_CHECK_SELFTEST: PASS` line). Detector for every counter mutant: the
mutated counter's own `--selftest` (killed iff exit non-zero or no
`C1_RESIDUAL_SELFTEST: PASS` line). A mutant is `survived` only when the mutated bytes
print the same PASS line as the pristine bytes; every survivor is then probed
behaviourally (a purpose-built tree or a direct unit call) and classified `live` or
`equivalent`. A baseline failure is reported as inconclusive, never as a kill.

## Instruments measured

| instrument | bytes measured | sha256 | baseline |
|---|---|---|---|
| `plans/round-61-c1-check.py` at BASE `0c07aab8` | 1710 lines | `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0` | `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0 |
| `plans/round-61-c1-check.py` candidate (working tree) | 2031 lines | `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6` | `C1_CHECK_SELFTEST: PASS (cases=102)` rc 0 |
| `plans/round-62-c1.sh` at BASE `0c07aab8` | 451 lines | `efe676ebb0d016664705f17c181ecc3331963a4b09fb2f80403f8773170cf62f` | `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 |
| `plans/round-63-c1.sh` snapshot `a78a7c47` | 466 lines | `a78a7c47dcd737469878a3beab8513ca1bb3436de2bd12ac376dd3ecba407d50` | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` rc 0 |
| `plans/round-63-c1.sh` snapshot `9d37e5f9` | 601 lines | `9d37e5f9c185c01d710b28381e78845c3970dbb334c1c4d00f5d14e8126f36c3` | **baseline failure** (`STUB: unbound variable`, rc 1) — all mutants inconclusive |
| `plans/round-63-c1.sh` snapshot `92b5a82e` | 601 lines | `92b5a82ecf451090b79bff70828c527b7046d156844d10e2c3d834982e731b5d` | `C1_RESIDUAL_SELFTEST: PASS (27/27 checks)` rc 0 |
| `plans/round-63-c1.sh` final bytes `652665ec` | 660 lines | `652665ecbb1f3a4a810c6ef478bdccd6f8a08c2d35d29bb9512380f3f411e298` | `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` rc 0; verdict line prints |

The candidate checker and the round-63 counter were still being revised during the wave;
each census below names the exact bytes it measured. The final re-run on the last bytes
seen by this seat is marked "final bytes" (see §Findings 1 and 2 for the two defects the
battery exposed before those bytes).

## Census

| battery | bytes | population | killed | survived | inconclusive |
|---|---|---|---|---|---|
| checker, BASE | `f2afd9b8` | 25 | 21 | 4 | 0 |
| checker, candidate | `eb08094c` | 23 | 20 | 3 | 0 |
| counter | `a78a7c47` | 12 | 2 | 10 | 0 |
| counter | `9d37e5f9` | 16 | 0 | 0 | 16 (baseline `STUB: unbound variable`) |
| counter | `92b5a82e` | 16 | 12 | 4 | 0 |
| counter, final bytes | `652665ec` | 16 | 12 | 4 | 0 |

## Survivors and fixes

### BASE checker (`f2afd9b8`)

1. **M07 `i6-superseded-conjunct-dropped` — survived; behaviourally LIVE (the round-62
   GM5 replay).** Dropping `bool(superseded)` from both I6 branches leaves
   `PASS (cases=75)`. Probe: a tree whose I6 correction line keeps the launch line and
   the four derived committer stamps but drops the quoted superseded span and the
   driver-complete stamp reads pristine `value=1 … i6=0` and mutant `value=0 … i6=1`.
   **Fix:** one isolating case (the round-63 candidate now carries
   `i6-superseded-stamp-conjunct-isolated`, which kills the same mutant on `eb08094c`).
2. **M11 `i3-anchor-test-dropped` — survived; LIVE.** Dropping the 12-token
   `A3 item 2` anchor test leaves `PASS (cases=75)`. Probe: the A7 section's
   `**A3 item 2 is withdrawn**` replaced by `**the item is withdrawn**` (the section still
   names `A3 item 2` in prose) reads pristine `value=1 … i3=0` and mutant `value=0 … i3=1`.
   **Fix:** a case whose section names the anchor only in prose and whose bold sentence
   asserts `withdrawn` without the anchor; assert FAIL (the round-63 candidate's
   `_asserted_withdrawn` keeps the anchor test, and `p1-benign-resolved` pins the
   alternative form).
3. **M22 `i1-first-row-wins` — survived; LIVE.** Taking the first `| R37 |` row instead
   of the last leaves `PASS (cases=75)`. Probe: the lesson plus a second `| R37 |` row
   appended after the correction reads pristine `value=1 … i1=0` (no supersedes line
   after the last row) and mutant `value=0 … i1=1`. **Fix:** a two-row case with the
   `supersedes R37` line between the rows; assert FAIL (last row wins).
4. **M18 `qm74-refusal-dropped` — survived; EQUIVALENT.** `evaluate()`'s
   `_refuse_inside_root` is duplicated in `run_guard()`; the mutant still raises
   `SetupError: challenge scratch … resolves at/inside the measured root (refused, QM74)`.
   Not a coverage defect: the duplicate is defence in depth. **Fix (optional):** delete
   the duplicate in `evaluate()` so the refusal has one home, or keep both and accept the
   equivalent mutant.

### Candidate checker (`eb08094c`, cases=102)

1. **N16 `i7-subject-window-widened` (8 -> 1000) — survived; LIVE.** Probe: the I7 line
   with `sentinel as an attack seat and also the literal list and the addendum and the
   record gives 4/16 = 25 %` (the pair sits >8 tokens after its subject) reads pristine
   `value=1 … i7=0` and mutant `value=0 … i7=1` — the mutant accepts an unbound pair.
   **Fix:** one case with the pair 9..12 tokens after the subject asserting FAIL; the
   existing `f8` only exercises a swapped pair.
2. **N04 `asserted-mask-dropped` — survived; EQUIVALENT at tree level.** `_asserted`'s
   `_mask_quotes(text, start)` masks only spans ending at/before the token, and
   `_negated_before` re-masks internally, while `_denied_after` scans only after the
   token: the mask is redundant. Probe (quoted denial after the token) reads the same
   `value=1 … i3=0` for pristine and mutant. **Fix:** delete the redundant mask in
   `_asserted` (one home for the mask) or note it as defence in depth; no case can
   distinguish it.
3. **N05 `negated-before-mask-dropped` — survived; LIVE at unit level, equivalent
   through `_asserted`.** Direct call `_negated_before('the record says "A3 item 2 is not
   withdrawn" — A3 item 2 is withdrawn', index of the last withdrawn)` reads pristine
   `False`, mutant `True`; through `_asserted` the pre-mask hides it. **Fix:** one unit
   case calling `_negated_before` directly with a quoted negator (assert False), or drop
   the internal mask and rely on `_asserted` (then the mutant target disappears).

Every other named construct is killed on `eb08094c`: post-token denial
(`denial-after-token-detected`, f2, f4), idiom list (`p2`, `p3b`, `not-merely-…`),
contrastive (`p5b`, `contrastive-but-rescues`), pre-token quote mask via
`_negated_before` (`quoted-span-masked`), window 24 -> 5 (`f3`, `f4`, `f6`, …) and
24 -> 48 (`window-negator-at-31-tokens-ignored`), I3 `item 2 of A3` (`p1`), I4 digit `3`
(`p4b`), I5 hyphen form (`p6`), I6 superseded-stamp conjunct (`f9`, `f10`,
`i6-superseded-stamp-conjunct-isolated`), I7 subject binding (`f8`), verdict inversion
(5 aggregate cases), item HOLD-unconditional (item3: 6 cases; item6: 6 cases), POP,
symlink refusal, anchor window, I4 negator, I7 first pair, the negator test (15 cases),
and the fleet-stamp SETUP (`i6-missing-fleet-report-is-setup`).

### Counter

Snapshot `a78a7c47` (`total=10`): killed 2 (V04-equivalent `stub_leg` forced `SL_OK=1`,
by the new `stub-leg-negative-vector`; gutted `selftest_gate`, by `stub-refused`),
survived 10. The ten survivors are the finding: the selftest never ran the verdict
path, so `accepted=0`, `guard=1`, a skipped stub leg, a skipped prior leg, a skipped
paraphrase leg, `real=1`, `selftest=1`, a dropped constant-printer defence,
`parse_value` always 0 and an uncounted `REJECTED` all read `PASS (10/10)`.

Per-survivor closure on the final bytes: `C01` -> `count-witness-zero`; `C08` ->
`selftest-leg`; `C09` -> `stub-refused` (the third stub shape); `C11` -> the four
`*-leg-one`/`count-witness-one` cases; `C12` -> `count-witness-one`. `C02`, `C03`
(the `leg_stub` call site), `C05`, `C06`, `C07` are the call-site class and still need
the self-invocation verdict case named below.

Snapshot `9d37e5f9` (`total=27`): **baseline failure**, all 16 mutants inconclusive —
`bash plans/round-63-c1.sh --selftest --tree <tree>` dies at `line 527: STUB: unbound
variable` (the composition case read `$STUB` while `stub_calc` set `stub`), and the
verdict run died the same way at `line 473`. Reported to `R63ExecC1Counter` with the
repro; fixed in the next bytes (`c1=$stub`).

Snapshot `92b5a82e` (`total=27`) and the final bytes `652665ec` (`total=28`, the new
`leg_chal` guard leg f): **killed 12, survived 4** (`V02`, `V05`, `V06`, `V07`). The
twelve kills are the counting class (`V01` `count-witness-zero`, `V12`
`count-witness-one`, `V11` four witness legs), the composition class (`V03`
`stub-composition`, `V04` `stub-leg-negative-vector`), the gate and stub defences
(`V09`/`V10` `stub-refused`), the selftest leg (`V08`, `V16` `selftest-leg`), and the
three leg units (`V13` `prior-leg-zero`, `V14` `para-leg-one`, `V15` `real-leg-one`).
The four survivors are the verdict run's **call sites**: `guard=1` for the
`guard_calc` call (`V02`), and `PRIOR=1` / `PARA=1` / `REAL=1` substituted for the
`leg_prior` / `leg_para` / `leg_real` calls (`V05`, `V06`, `V07`). Each reads
`C1_RESIDUAL_SELFTEST: PASS (28/28 checks)`: the selftest pins the helper units but never
runs the verdict path, so a counter that prints `guard=1` and skips three legs passes its
own selftest. **Fix:** one self-invocation verdict case — run the counter's own verdict
mode on a witness tree where one leg must read 0 (the existing `make_value_tree` trees
are exactly that shape) and assert exit 1 plus `guard=0` in the printed
`C1_RESIDUAL:` line; that single case kills all four call-site constants. Per
survivor: `V02` — the case must read `guard=0` when `guard_calc` is bypassed at the call
site (assert the printed `guard=` token, not the helper's return); `V05` — the case must
read `prior=0` when `leg_prior` is bypassed (the witness tree with a value=0 checker is
exactly the input whose `PRIOR` must be 0); `V06` — the case must read `para=0` when
`leg_para` is bypassed (the value=1 witness tree); `V07` — the case must read `real=0`
when `leg_real` is bypassed (the value=1 witness tree).

## Tables (exact bytes delta, observed line, verdict)

The tables below are generated from the drivers' mutant definitions and the recorded
runs; `<code>` cells hold the exact old/new bytes with `\n` for newlines.

### BASE checker mutants (plans/round-61-c1-check.py @ 0c07aab8, sha256 f2afd9b8..., `--selftest` cases=75)

| id | mutation | exact bytes delta | observed line | verdict |
|---|---|---|---|---|
| `M01-negator-test-dropped` | drop the negator test (_is_negator always False) | <code>return t in NEGATORS or t.endswith(NT_SUFFIX)</code> -&gt; <code>return False</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=8 names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,b5-not-rewritten-unresolved,negator-set-membership,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator,k5-negator-needle-unique)` | **killed** |
| `M02-negator-set-emptied` | empty the closed negator set | <code>NEGATORS = frozenset(("not", "no", "never", "neither", "nor", "without", "none"))</code> -&gt; <code>NEGATORS = frozenset(())</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=7 names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,b5-not-rewritten-unresolved,negator-set-membership,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator)` | **killed** |
| `M03-idiom-exception-dropped` | drop the `not only` idiom exception | <code>        if (t == "not" and i + 2 == len(low) and low[i + 1] == "only"):\n            continue  # `not only` immediately before the match\n</code> -&gt; <code>        pass  # idiom exception dropped\n</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=not-only-idiom-not-negator)` | **killed** |
| `M04-window-widened-24` | widen the negator window 5 -> 24 tokens | <code>NEG_WINDOW = 5    # the plan's 5-token negator window (a floor, not a parser)</code> -&gt; <code>NEG_WINDOW = 24   # widened</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=13 names=aggregate-good-all-hold,evaluate-no-challenge-good,evaluate-guard-good-tree,no-repo-good-shape-only,only-i1-resolves,only-i3-resolves,only-i4-resolves,only-i6-resolves,only-i7-resolves,p4-did-introduce-resolved,full-p3-value0,full-p4-value0,full-p5-value0)` | **killed** |
| `M05-window-narrowed-1` | narrow the negator window 5 -> 1 token | <code>NEG_WINDOW = 5    # the plan's 5-token negator window (a floor, not a parser)</code> -&gt; <code>NEG_WINDOW = 1    # narrowed</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=mid-window-not-only-still-negator)` | **killed** |
| `M06-window-zero` | negator window 5 -> 0 tokens | <code>NEG_WINDOW = 5    # the plan's 5-token negator window (a floor, not a parser)</code> -&gt; <code>NEG_WINDOW = 0    # zeroed</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=13 names=aggregate-good-all-hold,evaluate-no-challenge-good,evaluate-guard-good-tree,no-repo-good-shape-only,only-i1-resolves,only-i3-resolves,only-i4-resolves,only-i6-resolves,only-i7-resolves,p4-did-introduce-resolved,full-p3-value0,full-p4-value0,full-p5-value0)` | **killed** |
| `M07-i6-superseded-conjunct-dropped` | drop the I6 superseded-stamp conjunct (both branches) [GM5 replay] | <code>ok = len(stamps) &gt;= 3 and bool(superseded) and not denied</code> -&gt; <code>ok = len(stamps) &gt;= 3 and not denied</code>; <code>ok = len(qualifying) &gt;= 3 and bool(superseded) and not denied</code> -&gt; <code>ok = len(qualifying) &gt;= 3 and not denied</code> | `C1_CHECK_SELFTEST: PASS (cases=75)` | **survived** |
| `M08-i6-denial-clause-dropped` | drop the I6 post-token denial clause (both branches) | <code>ok = len(stamps) &gt;= 3 and bool(superseded) and not denied</code> -&gt; <code>ok = len(stamps) &gt;= 3 and bool(superseded) and True</code>; <code>ok = len(qualifying) &gt;= 3 and bool(superseded) and not denied</code> -&gt; <code>ok = len(qualifying) &gt;= 3 and bool(superseded) and True</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=b6-tail-denial-unresolved)` | **killed** |
| `M09-i7-quotation-mask-dropped` | drop the I7 double-quoted-span mask | <code>asserted = re.sub(r'"[^"]*"', " ", last)</code> -&gt; <code>asserted = last</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=i7-wrong-fraction)` | **killed** |
| `M10-i7-second-pair-dropped` | drop the I7 second fraction/percentage pair conjunct | <code>and _pair_re(frac_b, pb).search(asserted) is not None)</code> -&gt; <code>and True)</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=i7-wrong-fraction)` | **killed** |
| `M11-i3-anchor-test-dropped` | drop the I3 12-token `A3 item 2` anchor test | <code>if (_seq_in_window(section, m.start(), ("a3", "item", "2"))\n                and not _negated_before(section, m.start())):</code> -&gt; <code>if (True\n                and not _negated_before(section, m.start())):</code> | `C1_CHECK_SELFTEST: PASS (cases=75)` | **survived** |
| `M12-i5-negator-test-dropped` | drop the I5 negator test (b5 class) | <code>neg_free = m_rp is not None and not _negated_before(last, m_rp.start())</code> -&gt; <code>neg_free = m_rp is not None</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=b5-not-rewritten-unresolved)` | **killed** |
| `M13-verdict-mapping-inverted` | invert the per-item verdict token mapping (1<->0) | <code>toks = {k: ("1" if s == HOLD else "0") for k, (s, _) in res.items()}</code> -&gt; <code>toks = {k: ("0" if s == HOLD else "1") for k, (s, _) in res.items()}</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=5 names=evaluate-no-challenge-good,no-repo-good-shape-only,evaluate-all-unresolved-7,i2-absent-script-unresolved-not-setup,k5-negator-removed-accepts-b3)` | **killed** |
| `M14-item3-hold-unconditional` | make item3 return HOLD unconditionally | <code>return (HOLD if (a_ok and b_ok) else FAIL), det</code> -&gt; <code>return HOLD, det</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=3 names=i3-a7-withdraws-nothing,i3-lesson-second-instance-missing,b3-negated-withdrawn-unresolved)` | **killed** |
| `M15-item6-hold-unconditional` | make item6 return HOLD unconditionally | <code>    return (HOLD if ok else FAIL), det\n\n\ndef _fmt_pct(</code> -&gt; <code>    return HOLD, det\n\n\ndef _fmt_pct(</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=3 names=i6-foreign-timestamp,i6-only-two-stamps,b6-tail-denial-unresolved)` | **killed** |
| `M16-i2-case-floor-dropped` | drop item2's N >= 6 selftest case floor | <code>a_ok = r.returncode == 0 and n is not None and n &gt;= 6</code> -&gt; <code>a_ok = r.returncode == 0 and n is not None</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=i2-selftest-cases-below-6)` | **killed** |
| `M17-pop-6` | POP 7 -> 6 | <code>POP = 7\nSELFTEST_TIMEOUT = 90</code> -&gt; <code>POP = 6\nSELFTEST_TIMEOUT = 90</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=3 names=aggregate-good-all-hold,evaluate-guard-good-tree,challenge-plus1-fires-with-unresolved)` | **killed** |
| `M18-qm74-refusal-dropped` | drop the QM74 challenge-inside-root refusal | <code>    _refuse_inside_root(root)  # QM74 (I2's mutation leg and the GUARD share it)</code> -&gt; <code>    pass  # QM74 refusal dropped</code> | `C1_CHECK_SELFTEST: PASS (cases=75)` | **survived** |
| `M19-symlink-refusal-dropped` | drop the symlinked-statement refusal | <code>    _refuse_symlinks(root)  # refuse to measure symlinked statements/derivations</code> -&gt; <code>    pass  # symlink refusal dropped</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=symlinked-log-refused-setup)` | **killed** |
| `M20-valid-hms-always-true` | _valid_hms always True (09:99:99 accepted) | <code>return h &lt;= 23 and m &lt;= 59 and s &lt;= 59</code> -&gt; <code>return True</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=qualifying-times-validate-and-exclude)` | **killed** |
| `M21-qualifying-times-exclusions-dropped` | drop the launch/derived exclusions in _qualifying_times | <code>            if _valid_hms(t.group(0)) and t.group(0) != launch_time\n            and t.group(0) not in derived_times}</code> -&gt; <code>            if _valid_hms(t.group(0))}</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=qualifying-times-validate-and-exclude)` | **killed** |
| `M22-i1-first-row-wins` | item1 takes the FIRST routed R37 row instead of the last | <code>            anchor = i  # the LAST routed `R37` row wins (see docstring reading)</code> -&gt; <code>            anchor = i if anchor is None else anchor  # FIRST row wins</code> | `C1_CHECK_SELFTEST: PASS (cases=75)` | **survived** |
| `M23-anchor-window-1` | I3 anchor window 12 -> 1 token | <code>ANCHOR_WINDOW = 12  # I3's 12-token `A3 item 2` anchor window</code> -&gt; <code>ANCHOR_WINDOW = 1   # narrowed</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=11 names=aggregate-good-all-hold,evaluate-no-challenge-good,evaluate-guard-good-tree,no-repo-good-shape-only,only-i3-resolves,p3-hereby-resolved,full-p3-value0,full-p4-value0,full-p5-value0,window-truncated-at-boundary,k5-negator-removed-accepts-b3)` | **killed** |
| `M24-i4-three-negator-dropped` | drop the I4 negator test on `three` | <code>    three_ok = any(not _negated_before(last, m.start())\n                   for m in THREE_RE.finditer(last))</code> -&gt; <code>    three_ok = bool(THREE_RE.search(last))</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=b4-no-three-unresolved)` | **killed** |
| `M25-i7-first-pair-dropped` | drop the I7 first fraction/percentage pair conjunct | <code>ok = (_pair_re(frac_a, pa).search(asserted) is not None</code> -&gt; <code>ok = (True</code> | `C1_CHECK_SELFTEST: FAIL (cases=75 failed=1 names=i7-wrong-pct)` | **killed** |

### Candidate checker mutants (plans/round-61-c1-check.py @ working tree eb08094c..., `--selftest` cases=102)

| id | mutation | exact bytes delta | observed line | verdict |
|---|---|---|---|---|
| `N01-post-token-denial-dropped` | drop the post-token denial test from _asserted | <code>    return not _negated_before(mt, start) and not _denied_after(mt, end)</code> -&gt; <code>    return not _negated_before(mt, start)</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=3 names=f2-forgery-unresolved,f4-forgery-unresolved,denial-after-token-detected)` | **killed** |
| `N02-idiom-exception-dropped` | drop the idiom exception list (not only / not merely / no fewer than) | <code>    rescued = set()\n    for idi in IDIOMS:\n        k = len(idi)\n        if len(low) &gt;= k and tuple(low[-k:]) == idi:\n            rescued.add(len(low) - k)  # the idiom's head negator index\n</code> -&gt; <code>    rescued = set()  # idiom exception dropped\n</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=4 names=p2-benign-resolved,p3b-benign-resolved,not-merely-idiom-rescues,not-only-idiom-not-negator)` | **killed** |
| `N03-contrastive-exception-dropped` | drop the contrastive `not X but Y` exception | <code>        if "but" in low[i + 1:]:\n            continue  # contrastive: `not … but &lt;token&gt;` asserts the token\n</code> -&gt; <code>        pass  # contrastive dropped\n</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=2 names=p5b-benign-resolved,contrastive-but-rescues)` | **killed** |
| `N04-quote-mask-pretoken-dropped` | drop the quotation mask in _negated_before | <code>    mt = _mask_quotes(text, start)\n    return not _negated_before(mt, start)</code> -&gt; <code>    mt = text\n    return not _negated_before(mt, start)</code> | `C1_CHECK_SELFTEST: PASS (cases=102)` | **survived** |
| `N05-quote-mask-posttoken-dropped` | drop the quotation mask in _denied_after | <code>    text = _mask_quotes(text, start)\n    cut = 0</code> -&gt; <code>    text = text  # mask dropped\n    cut = 0</code> | `C1_CHECK_SELFTEST: PASS (cases=102)` | **survived** |
| `N06-window-widened-48` | widen the polarity window 24 -> 48 tokens | <code>NEG_WINDOW = 24   # the plan's 24-token polarity window (a floor, not a parser)</code> -&gt; <code>NEG_WINDOW = 48   # widened</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=window-negator-at-31-tokens-ignored)` | **killed** |
| `N07-window-narrowed-5` | narrow the polarity window 24 -> 5 tokens (the round-62 window) | <code>NEG_WINDOW = 24   # the plan's 24-token polarity window (a floor, not a parser)</code> -&gt; <code>NEG_WINDOW = 5    # narrowed</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=5 names=f3-forgery-unresolved,f4-forgery-unresolved,f6-forgery-unresolved,f7-forgery-unresolved,window-negator-at-10-tokens)` | **killed** |
| `N08-i3-subject-alternative-dropped` | drop the `item 2 of A3` alternative in I3 | <code>A3_ITEM2_SEQS = (("a3", "item", "2"), ("item", "2", "of", "a3"))</code> -&gt; <code>A3_ITEM2_SEQS = (("a3", "item", "2"),)</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=p1-benign-resolved)` | **killed** |
| `N09-i4-digit-form-dropped` | drop the digit `3` token form in I4 | <code>    count_tokens = list(THREE_RE.finditer(last)) + list(\n        COUNT3_RE.finditer(last))</code> -&gt; <code>    count_tokens = list(THREE_RE.finditer(last))</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=p4b-benign-resolved)` | **killed** |
| `N10-i5-hyphen-form-dropped` | drop the `rewritten in-place` hyphen form in I5 | <code>REWITTEN_IN_PLACE_RE = re.compile(r"rewritten\s+in(?:\s+\|-)place")</code> -&gt; <code>REWITTEN_IN_PLACE_RE = re.compile(r"rewritten\s+in\s+place")</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=p6-benign-resolved)` | **killed** |
| `N11-i6-superseded-stamp-conjunct-dropped` | drop the I6 fleet-stamp conjunct (both branches) [GM5 replay] | <code>        ok = len(stamps) &gt;= 3 and bool(superseded) and not denied \\n            and superseded_ok</code> -&gt; <code>        ok = len(stamps) &gt;= 3 and bool(superseded) and not denied</code>; <code>    ok = len(qualifying) &gt;= 3 and not denied and superseded_ok</code> -&gt; <code>    ok = len(qualifying) &gt;= 3 and not denied</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=3 names=f9-forgery-unresolved,f10-forgery-unresolved,i6-superseded-stamp-conjunct-isolated)` | **killed** |
| `N12-i7-subject-binding-dropped` | drop the I7 subject binding (pair anywhere on the line) | <code>    for sm in subj_re.finditer(masked):\n        pm = pair.search(masked, sm.end())\n        if pm is None:\n            continue\n        between = TOKEN_RE.findall(masked, sm.end(), pm.start())\n        if len(between) &lt;= SUBJECT_WINDOW:\n            return True\n    return False</code> -&gt; <code>    return pair.search(masked) is not None</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=f8-forgery-unresolved)` | **killed** |
| `N13-verdict-mapping-inverted` | invert the per-item verdict token mapping (1<->0) | <code>toks = {k: ("1" if s == HOLD else "0") for k, (s, _) in res.items()}</code> -&gt; <code>toks = {k: ("0" if s == HOLD else "1") for k, (s, _) in res.items()}</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=5 names=evaluate-no-challenge-good,no-repo-good-shape-only,evaluate-all-unresolved-7,i2-absent-script-unresolved-not-setup,k5-negator-removed-accepts-b3)` | **killed** |
| `N14-item3-hold-unconditional` | make item3 return HOLD unconditionally | <code>return (HOLD if (a_ok and b_ok) else FAIL), det</code> -&gt; <code>return HOLD, det</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=6 names=i3-a7-withdraws-nothing,i3-lesson-second-instance-missing,b3-negated-withdrawn-unresolved,f1-forgery-unresolved,f2-forgery-unresolved,f3-forgery-unresolved)` | **killed** |
| `N15-i6-fleet-stamp-constant` | replace the fleet-report derivation with a constant stamp | <code>    fleet_stamp = derive_fleet_stamp(fleet_dir)  # SetupError -&gt; exit 2</code> -&gt; <code>    fleet_stamp = "15:09:28"  # constant, no derivation</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=i6-missing-fleet-report-is-setup)` | **killed** |
| `N16-i7-subject-window-widened` | widen the I7 subject window 8 -> 1000 tokens | <code>SUBJECT_WINDOW = 8   # I7's 8-token subject-&gt;pair binding window</code> -&gt; <code>SUBJECT_WINDOW = 1000  # widened</code> | `C1_CHECK_SELFTEST: PASS (cases=102)` | **survived** |
| `N17-negator-test-dropped` | drop the negator test (_is_negator always False) | <code>return t in NEGATORS or t.endswith(NT_SUFFIX)</code> -&gt; <code>return False</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=15 names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,b5-not-rewritten-unresolved,f1-forgery-unresolved,f3-forgery-unresolved,f5-forgery-unresolved,f6-forgery-unresolved,f7-forgery-unresolved,negator-round63-membership,negator-set-membership,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator,window-negator-at-10-tokens,k5-negator-needle-unique)` | **killed** |
| `N18-item6-hold-unconditional` | make item6 return HOLD unconditionally | <code>    return (HOLD if ok else FAIL), det\n\n\ndef _fmt_pct(</code> -&gt; <code>    return HOLD, det\n\n\ndef _fmt_pct(</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=6 names=i6-foreign-timestamp,i6-only-two-stamps,b6-tail-denial-unresolved,f9-forgery-unresolved,f10-forgery-unresolved,i6-superseded-stamp-conjunct-isolated)` | **killed** |
| `N19-pop-6` | POP 7 -> 6 | <code>POP = 7\nSELFTEST_TIMEOUT</code> -&gt; <code>POP = 6\nSELFTEST_TIMEOUT</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=3 names=aggregate-good-all-hold,evaluate-guard-good-tree,challenge-plus1-fires-with-unresolved)` | **killed** |
| `N20-symlink-refusal-dropped` | drop the symlinked-statement refusal | <code>    _refuse_symlinks(root)  # refuse to measure symlinked statements/derivations</code> -&gt; <code>    pass  # symlink refusal dropped</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=symlinked-log-refused-setup)` | **killed** |
| `N21-i3-anchor-window-1` | I3 anchor window 12 -> 1 token | <code>ANCHOR_WINDOW = 12  # I3's anchor window (`A3 item 2` / `item 2 of A3`)</code> -&gt; <code>ANCHOR_WINDOW = 1   # narrowed</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=13 names=aggregate-good-all-hold,evaluate-no-challenge-good,evaluate-guard-good-tree,no-repo-good-shape-only,only-i3-resolves,p3-hereby-resolved,full-p3-value0,full-p4-value0,full-p5-value0,p1-benign-resolved,p2-benign-resolved,window-truncated-at-boundary,k5-negator-removed-accepts-b3)` | **killed** |
| `N22-i4-negator-test-dropped` | drop the I4 asserted-position test on the count token | <code>    three_ok = any(_asserted(last, m.start(), m.end())\n                   for m in count_tokens)</code> -&gt; <code>    three_ok = bool(count_tokens)</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=4 names=b4-no-three-unresolved,f4-forgery-unresolved,f5-forgery-unresolved,f6-forgery-unresolved)` | **killed** |
| `N23-i7-first-pair-dropped` | drop the I7 literal-reading pair conjunct | <code>    ok = (_pair_bound_to_subject(asserted, LITERAL_READING_RE,\n                                 _pair_re(frac_a, pa))</code> -&gt; <code>    ok = (True</code> | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=1 names=i7-wrong-pct)` | **killed** |

### Counter mutants, snapshot a78a7c47 (`--selftest` total=10)

| id | mutation | exact bytes delta | observed line | verdict |
|---|---|---|---|---|
| `C01-accepted-forced-0` | force accepted=0 (never count an accepted forgery) | <code>[[ "$RUN_VAL" == "0" ]] &amp;&amp; ACCEPTED=$((ACCEPTED + 1))</code> -&gt; <code>: # accepted never counted</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C02-guard-forced-1` | force guard=1 (composition replaced by a constant) | <code>guard=0\n  [[ $real -eq 1 &amp;&amp; $selftest -eq 1 &amp;&amp; $prior -eq 1 &amp;&amp; $para -eq 1 &amp;&amp; $stub -eq 1 ]] &amp;&amp; guard=1</code> -&gt; <code>guard=1</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C03-stub-leg-skipped` | skip the stub leg (both stub results forced to 1) | <code>stub_leg "$STUB_TREE" "$WORK/stub" \|\| setup_die "cannot create stub run dir"\n  stub_rc=$SL_RC; stub_e1=$SL_OK</code> -&gt; <code>stub_rc=0; stub_e1=1  # stub leg skipped</code>; <code>stub_leg "$STUB2_TREE" "$WORK/stub2" \|\| setup_die "cannot create stub2 run dir"\n  stub2_rc=$SL_RC; stub_e2=$SL_OK</code> -&gt; <code>stub2_rc=0; stub2_e2=1  # stub leg skipped</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C04-stub-leg-always-ok` | stub_leg forced to read SL_OK=1 (CM2b replay) | <code>  [[ "$SL_RC" -ne 0 ]] \|\| SL_OK=0\n}</code> -&gt; <code>  SL_OK=1  # forced\n}</code> | `C1_RESIDUAL_SELFTEST: FAIL (9/10 checks) failed=stub-leg-negative-vector` | **killed** |
| `C05-prior-guard-skipped` | skip the prior (round-62 bypass) guard loop | <code>prior=1\n  for ((i = 0; i &lt; ${#B_IDS[@]}; i++)); do</code> -&gt; <code>prior=1\n  for ((i = 0; i &lt; 0; i++)); do</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C06-para-guard-skipped` | skip the paraphrase guard loop | <code>para=1\n  for ((i = 0; i &lt; ${#Q_IDS[@]}; i++)); do</code> -&gt; <code>para=1\n  for ((i = 0; i &lt; 0; i++)); do</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C07-real-forced-1` | force guard leg a (real=1) | <code>real=0; [[ "$RUN_VAL" == "0" ]] &amp;&amp; real=1</code> -&gt; <code>real=1</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C08-selftest-leg-forced-1` | force guard leg b (selftest=1, N>=91 floor dropped) | <code>selftest=0\n  [[ "$ST_PASS" -eq 1 &amp;&amp; -n "$ST_N" &amp;&amp; "$ST_N" -ge 91 ]] &amp;&amp; selftest=1</code> -&gt; <code>selftest=1</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C09-constant-printer-defence-dropped` | drop the selftest-output==measurement-output refusal | <code>    if [[ "$i" -eq 0 ]] &amp;&amp; cmp -s "$pfx.gate.out" "$pfx.$id.out"; then\n      echo "c1-residual: refuse: constant line printer (selftest output == measurement output) — no verdict"\n      exit 2\n    fi\n</code> -&gt; <code></code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C10-selftest-gate-gutted` | gut selftest_gate (always PASS, N=99) | <code>  python3 -I -B "$tree/$CHECKER_REL" --selftest &gt;"$pfx.out" 2&gt;"$pfx.err"\n  ST_RC=$?</code> -&gt; <code>  : &gt;"$pfx.out" 2&gt;"$pfx.err"\n  ST_RC=0</code>; <code>  ST_PASS=0; ST_N=""</code> -&gt; <code>  ST_PASS=1; ST_N=99</code> | `C1_RESIDUAL_SELFTEST: FAIL (9/10 checks) failed=stub-refused` | **killed** |
| `C11-parse-value-always-0` | parse_value always prints 0 | <code>  sed -n 's/^C1_ROUTED:.*[[:space:]]value=\([0-9A-Za-z]*\).*/\1/p' &lt;&lt;&lt;"$1"</code> -&gt; <code>  echo 0</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |
| `C12-rejected-never-counted` | force rejected=0 (benign rejections never counted) | <code>    if [[ "$RUN_VAL" =~ ^[0-9]+$ &amp;&amp; "$RUN_VAL" -ge 1 ]]; then\n      REJECTED=$((REJECTED + 1))\n    fi</code> -&gt; <code>    : # rejections never counted</code> | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` | **survived** |

### Counter mutants, final bytes 652665ec (`--selftest` total=28)

| id | mutation | exact bytes delta | observed line | verdict |
|---|---|---|---|---|
| `V01-accepted-forced-0` | counting | <code>[[ "$RUN_VAL" == "0" ]] &amp;&amp; ACCEPTED=$((ACCEPTED + 1))</code> -&gt; <code>: # accepted never counted</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=count-witness-zero` | **killed** |
| `V02-guard-callsite-forced-1` | call-site | <code>guard="$(guard_calc "$REAL" "$SELFTEST" "$PRIOR" "$PARA" "$stub" "$CHAL")"</code> -&gt; <code>guard=1</code> | `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` | **survived** |
| `V03-stub-composition-forced-1` | unit (CM2a) | <code>stub=0; [[ $stub_e1 -eq 1 &amp;&amp; $stub_e2 -eq 1 &amp;&amp; $stub_e3 -eq 1 ]] &amp;&amp; stub=1</code> -&gt; <code>stub=1  # composition forced</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=stub-composition` | **killed** |
| `V04-stub-leg-always-ok` | unit (CM2b) | <code>  [[ "$SL_RC" -ne 0 ]] \|\| SL_OK=0</code> -&gt; <code>  SL_OK=1  # forced</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=stub-leg-negative-vector` | **killed** |
| `V05-prior-callsite-skipped` | call-site | <code>leg_prior "$TREE" "$WORK/prior" \|\| setup_die "${AF_ERR:-prior leg failed}"</code> -&gt; <code>PRIOR=1  # prior leg skipped</code> | `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` | **survived** |
| `V06-para-callsite-skipped` | call-site | <code>leg_para "$TREE" "$WORK/para" \|\| setup_die "${AF_ERR:-paraphrase leg failed}"</code> -&gt; <code>PARA=1  # paraphrase leg skipped</code> | `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` | **survived** |
| `V07-real-callsite-forced-1` | call-site | <code>leg_real "$TREE" "$WORK/unmod"</code> -&gt; <code>REAL=1  # real leg forced</code> | `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` | **survived** |
| `V08-selftest-leg-forced-1` | unit | <code>SELFTEST=0\n  [[ "$ST_PASS" -eq 1 &amp;&amp; -n "$ST_N" &amp;&amp; "$ST_N" -ge 91 ]] &amp;&amp; SELFTEST=1</code> -&gt; <code>SELFTEST=1</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=selftest-leg` | **killed** |
| `V09-constant-printer-defence-dropped` | defence | <code>    if [[ "$i" -eq 0 ]] &amp;&amp; cmp -s "$pfx.gate.out" "$pfx.$id.out"; then</code> -&gt; <code>    if false; then  # constant-printer defence dropped</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=stub-refused` | **killed** |
| `V10-selftest-gate-gutted` | gate | <code>  python3 -I -B "$tree/$CHECKER_REL" --selftest &gt;"$pfx.out" 2&gt;"$pfx.err"\n  ST_RC=$?</code> -&gt; <code>  : &gt;"$pfx.out" 2&gt;"$pfx.err"\n  ST_RC=0</code>; <code>  ST_PASS=0; ST_N=""</code> -&gt; <code>  ST_PASS=1; ST_N=99</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=stub-refused` | **killed** |
| `V11-parse-value-always-0` | parse | <code>  sed -n 's/^C1_ROUTED:.*[[:space:]]value=\([0-9A-Za-z]*\).*/\1/p' &lt;&lt;&lt;"$1"</code> -&gt; <code>  echo 0</code> | `C1_RESIDUAL_SELFTEST: FAIL (24/28 checks) failed=count-witness-one,real-leg-one,prior-leg-one,para-leg-one` | **killed** |
| `V12-rejected-never-counted` | counting | <code>    if [[ "$RUN_VAL" =~ ^[0-9]+$ &amp;&amp; "$RUN_VAL" -ge 1 ]]; then\n      REJECTED=$((REJECTED + 1))\n    fi</code> -&gt; <code>    : # rejections never counted</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=count-witness-one` | **killed** |
| `V13-prior-unit-forced-1` | unit | <code>    [[ "$RUN_VAL" =~ ^[0-9]+$ &amp;&amp; "$RUN_VAL" -ge 1 ]] \|\| PRIOR=0</code> -&gt; <code>    : # prior never cleared</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=prior-leg-zero` | **killed** |
| `V14-para-unit-forced-1` | unit | <code>    [[ "$RUN_VAL" == "0" ]] \|\| PARA=0</code> -&gt; <code>    : # para never cleared</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=para-leg-one` | **killed** |
| `V15-real-unit-forced-1` | unit | <code>  [[ "$RUN_VAL" == "0" ]] &amp;&amp; REAL=1</code> -&gt; <code>  REAL=1</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=real-leg-one` | **killed** |
| `V16-selftest-floor-dropped` | unit | <code>"$ST_N" -ge 91</code> -&gt; <code>"$ST_N" -ge 0</code> | `C1_RESIDUAL_SELFTEST: FAIL (27/28 checks) failed=selftest-leg` | **killed** |

## Supporting transcripts (same directory)

`checker-battery.txt` (25 BASE checker mutants), `cand-battery.txt` (23 candidate
checker mutants), `counter-battery-v2.txt` (12 mutants on `a78a7c47`),
`counter-battery-final.txt` (16 mutants on `652665ec`), `probes.txt` (the four survivor
probes with both readings). Each line is the detector's exact verdict line.

## Findings for the L1

1. **The counter's verdict run was unreachable twice during the wave** (`stub: unbound
   variable` at `a78a7c47:395`, then `STUB: unbound variable` at `9d37e5f9:473`). Both
   were reported to the counter's owner with a minimal repro and fixed. C2's guard leg
   (a) and the C1 verdict line both depend on the counter printing a line at all; the
   final bytes must be re-run end-to-end (`--selftest` and a verdict run) before the
   candidate reading.
2. **The candidate checker's `--selftest` reached `cases=102` (floor 91) only late in the
   wave.** At `f0409a45` it read `PASS (cases=76)` and at `3ebe0885` it aborted with
   `NameError: name 'mk_fleet' is not defined`; both were reported. The guard leg (b)
   floor is met on `eb08094c`.
3. **Two live survivors remain on the candidate checker**: the I7 subject-window bound
   (`N16`) and the unit-level `_negated_before` mask (`N05`); one equivalent (`N04`).
   None of the three can make the checker accept a committed forgery on the frozen
   fixture set (all F1..F10 and P1..P6 cases pass), but `N16` is a real forgery-side
   gap: a pair placed >8 tokens after its subject is accepted.
4. **The round-62 GM5 survivor is closed on the candidate bytes** (N11 killed by three
   cases), and the round-62 CM2a/CM2b survivors are closed on the counter bytes
   (`stub_calc` composition case; `stub-leg-negative-vector`).
5. **The counter's selftest now tests units, not the verdict wiring.** On `a78a7c47` the
   call-site constants survived; on `92b5a82e` the counting witnesses and composition
   cases close the counting and composition classes, but the verdict run's call sites
   (`leg_real`/`leg_prior`/`leg_para`/`guard_calc`) are still only exercised through the
   helpers. A self-invocation verdict case (run the counter's own verdict mode on a
   witness tree where one leg must read 0; assert exit 1 and `guard=0`) is the fix that
   closes the call-site class.
6. **A cosmetic latent defect in the candidate checker**: the I5 mechanism regex is
   bound to `REWITTEN_IN_PLACE_RE` (missing `R`) at both its definition and its use. It
   works today because both occurrences share the typo; a later edit that spells one of
   them correctly raises `NameError` in `item5`. Rename both to
   `REWRITTEN_IN_PLACE_RE`.

## Scratch and restoration

All clones, fixture trees, mutant copies and counter scratch were under
`/fast/scratch/hyaku/kagi-r63/R63MutC1/` (`HYAKU_SCRATCH` was pointed inside it so the
counter's own `kagi-r63/R63ExecC1Counter` scratch landed there too) and are deleted
before this seat yields. No citable evidence was written under `/tmp`. No secret value,
cookie, token, session id or vault/item/field name appears in this receipt. The lane
instruments were read-only throughout: the hashes this seat measured are the executors'
bytes, and this seat wrote none of them.

SEAT-STATUS: complete
