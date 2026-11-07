# R59ReviewerCounters — counters and control battery, attacked (kagi r59)

Seat: reviewer (counters). Read-only on the lane; every attack ran against a scratch
tree under `/fast/scratch/hyaku/kagi-r59/R59ReviewerCounters/` (deleted before yield).
Full table with exact commands, observations and fixes:
`.ufo/waves/round-59/build/R59ReviewerCounters/attacks.md`. Builder scripts and the two
battery transcripts sit beside it as receipts.

Measured instruments (sha256): checker `6844c1d4…` (an earlier `e6c079f6…` was also
measured), wrapper `73a2fc68…`, C2 counter `454a4177…`, trial `e11e98f6…`, battery
`5f6c576f…`. Re-hash before quoting.

## Verdict in one paragraph

Both counters' **scale anchors hold**: BASE reads `value=5 population=5` (diagnostic) and
`value=FAIL guard=0` (full); the battery's own synthetic fixed tree reads `value=0 guard=1`;
the real trial reads C2 `value=5`; the wrapper's QM74 and bad-revision refusals are rc 2;
the C2 no-bao, clean-room, shim-vector, duplicate-line and secret legs all refuse. But the
C1 counter is **evadable at its reading granularity**: every item selects one physical
line, so a normal Markdown-wrapped continuation can restate the defect while the counter
prints `value=0 guard=1` (A01–A05), and at 14:12 the live correction block was wrapped
exactly that way, so the counter read `value=3` on a fix whose bullets a human reads as
correct (reflowed by 14:17; D03). Two further item readers are role-blind or notation-blind
(A06–A11). The challenge can **write outside its copy** through a symlinked lesson
(A12). The C2 counter has two line-parsing holes (B09/B10) but its five shims, none leg,
clean-room line, duplicate rules and secret scan all bite; the two named ceilings (K2
shape-keyed/absolute-path, K4 clean-room from printed output) are real, and a single
"two independent real runs" ceiling is not named (B12). The **control battery has not read
`mismatch=0`**: the 14:07 revision failed on C1-F7's unreachable expectation and C2-F2's
`sed` (two independent bugs, C01/C02); the 14:16 revision fixed C2-F2 but its rewritten
C1-F7 runs the Python checker with `bash` (C01) — one token from passing. Its `INSTRUMENT`
pins also hash the lane while `c1()` executes the REF tree's copies (C05).

## Findings by severity

**High**

1. **Line-granular last-occurrence read (all five C1 items).** A01–A05: a bullet whose
   first physical line satisfies the item and whose continuation restates the defect
   reads `value=0 … guard=1`, exit 0 (five reproducers, five items). The real fix hit the
   same defect from the other side: at 14:12 its D3/D4/D5 bullets were wrapped and the
   counter read `value=3` (now reflowed; the 14:17 state is `value=1`, i4 only — D03), so
   the reading depends on where an author breaks a line. Fix: join indented continuation
   lines into their parent bullet before selection (and add one wrapped-form control per
   item).
2. **Challenge write-escape via a symlinked lesson (A12).** `copytree(..., symlinks=True)`
   + `_wr_mut` follows a `corpus/lessons/round-58.md` symlink and rewrites a file outside
   the copy (canary `Registry 117 → 120` became `… 121`; counter still `value=0 guard=1`).
   This is the M58-3/QM74 class. Fix: `symlinks=False`, or refuse a symlinked lesson,
   or check each written realpath is under the copy.
3. **Pre-freeze battery cannot pass (C01, C02).** Two revisions were measured. The
   14:07 revision (`5f6c576f`) could not pass: C1-F7 expected FAIL but `c1()` prefers the
   tree's checker, so the planted printer stub printed `0` (`expect=FAIL got=0 MISMATCH`),
   and C2-F2's `sed 's/^SETUP .*/SETUP/'` matched nothing against the trial's
   `OPENBAO_TRANSIT_TRIAL: SETUP …` line (`expect=SETUP got= MISMATCH`) — run B read
   `CONTROLS: match=17 mismatch=3`. The 14:16 revision (`0d8647a0`) fixed C2-F2 but its
   rewritten C1-F7 invokes the **Python** checker with `bash`, so it emits shell errors and
   no `C1_ROUTED:` line (`expect=FAIL got= MISMATCH`, run E); its new C1-F7b merely runs
   the planted stub and expects the stub's own `0` (vacuous). Run E's final line is
   `CONTROLS: match=20 mismatch=1`, rc 1 — the gate `mismatch=0` is still not reachable,
   now by a one-token bug (`bash` → `python3 -I -B`).
   Separately, the battery's `INSTRUMENT` pins hash `$REPO` while `c1()` executes the
   `[REFTREE]` copy (C05) — with a REF different from the lane the receipt names bytes it
   did not measure.
4. **Live candidate is red at measurement time (D03):** at 14:24Z-03 the checker reads
   `C1_ROUTED: value=1 population=5 i1=1 i2=1 i3=1 i4=0 i5=1 guard=1` on the lane. i3 and
   i5 hold (supplement receipt landed; D3/D5 single-line), but i4 fails: the regenerated
   `.ufo/waves/round-59/final/citation-gate-r59.txt` (1129 B, 8 lines) carries **no**
   `CITATION_GATE:` line — its first line is a scope caveat and its last line a `LABELED …`
   detail — while the lesson's D4 line states `unresolved=13`. Make the ledger's
   `CITATION_GATE: … unresolved=<U> …` line the receipt's last line (U = 13) or name the
   ceiling in D4 instead of claiming a gate reading.

**Medium**

5. **A06 — `item3` is role-blind.** It requires only that the three derived numbers appear
   *somewhere* on the line (`all(n in ints)`), so `9 total, 20 C1 and 7 C2` (roles swapped,
   self-contradictory) reads `i3=1`, `value=0 guard=1`. Fix: parse labelled roles.
6. **A07–A11 — selector alphabets narrower than the claim.** Lower-case `registry`, ASCII
   `->`, `at candidate` (no `the`), and the bare basename `source-fetches.tsv` all evade
   I1/I2 (`value=0 guard=1`). Fix: `re.I`, both arrows, optional `the`, basename select.
   (These are predicate-form gaps; if the L1 keeps the frozen per-line reading, name them
   as ceilings and do not bank the green.)
7. **B09/B10 — C2 summary line read with `grep -q`.** `… holds=5 broken=0 error=0 error=1`
   and two summary lines (HOLDS + BROKEN) both read `value=5`. Fix: exactly one summary
   line, exact/field-parsed counts (the T-line DUP rule already does this).

**Low / hygiene**

8. **D01 — default challenge parent is a fixed shared path that is not created**
   (`$HYAKU_SCRATCH/kagi-r59/R59ExecCounterC1`, else `$TMPDIR`): when absent, every direct
   checker invocation reads `value=FAIL guard=0` on a resolved tree (fail-closed, but the
   battery's K1-REF/C1 controls call the checker directly, and the R59ExecCounterC1 seat
   deletes that dir at yield). Fix: `os.makedirs(..., exist_ok=True)` or a per-call
   `mkdtemp()`.
9. **C04 — battery provenance.** With a `[REFTREE]` argument the `INSTRUMENT` pins hash
   `$REPO` while `c1()` executes `$REF`'s copied checker (`c2()` runs `$REPO`'s counter on
   `$REF`'s trial). Run C shows pins `6844…` with executed `e6c0…` and a consequent
   C1-F5 misread. Fix: pin the executed bytes or make `c1()` always use `$CHECKER`.
10. **C06/C09** — C2-F5 only rejects a shim-*blind* fabricated transcript (a shim-aware
    stub scores 5, B01), so its text overstates coverage; `wrap_trial` is still defined
    twice in `0d8647a0` (dead first copy).

## Named ceilings (confirmed, not defects)

- **K2** — a trial that shape-keys the shim vectors, gates the no-bao leg with
  `command -v bao` and then executes an absolute-path binary, and prints
  `TRIAL CLEANROOM HOLDS` without a second server reads `value=5` (B01). K2's wording
  should name the `command -v`-then-absolute bypass explicitly; the plain absolute-path
  variant is caught by the none leg (B02).
- **K4** — the clean-room line is read from the trial's output; no counter-side check can
  prove a second server (B01).
- The guard's printer-stub leg is a tautology for any constant stub (A23) — the frozen
  predicate asks for it; the +1 challenge is the only biting leg.
- **B12 (unnamed)** — "two independent real runs" is not observable: a trial that measures
  once and replays (or not at all) reads 5. Extend K2's wording to cover it.

## What the L1 should do before claiming

- The lesson's D3/D5 are single-line; the remaining C1 blocker is the citation receipt.
  `.ufo/waves/round-59/final/citation-gate-r59.txt` (1129 B, 8 lines) carries no
  `CITATION_GATE:` line; make the ledger's `CITATION_GATE: … unresolved=<U> …` line its
  **last** line with U equal to the lesson's D4 number (13), or name the ceiling in D4
  instead of claiming a gate reading. `supplement-receipt.txt` already reads
  `SUPPLEMENT: match=2 mismatch=0`. Even with i4 green, A01–A05 remain false greens unless
  the reader joins wrapped continuations (or the record stays single-line forever).
- Battery: the current revision (`0d8647a0`) reads `CONTROLS: match=20 mismatch=1`, rc 1 —
  C1-F7 only, because it runs the Python checker with `bash`; change that invocation to
  `python3 -I -B` and re-run. Also make the `INSTRUMENT` pins hash the bytes actually
  executed (C05) and drop the dead first `wrap_trial` (C09).
- Do not treat the current `guard=1` as evidence of measurement: the challenge compares a
  printed number read from a copy whose only intended delta is one digit.

## Verification gaps

- The mutant class (a checker that prints `count+1` for any delta, a guard hardcoded 1,
  first-occurrence reads) is the mutation seat's; I did not build mutants — my rows are
  attacks on the shipped bytes and the shipped control set.
- One host, one `bao` (2.7.2, counter-pinned sha256); no non-Linux/cross-version reading.
- The battery and the checker were edited while I measured; every line above is pinned to
  the sha256 in the header and to the receipt copies in the build dir.
- C2's real-trial legs run ~50 s per counter invocation; I did not attack the trial's
  mechanics (the executors/sentinel own that) — only the counter's reading of them.

SEAT-STATUS: complete
