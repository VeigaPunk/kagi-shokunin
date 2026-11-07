# R59MutCounters — mutation test of the round-59 C1 checker and C2 counter

Seat R59MutCounters (leaf, mutation-tester), kagi round 59 attempt 1. Read-only on the
lane: no lane file was modified. Every mutant lives in a scratch copy under
`/fast/scratch/hyaku/kagi-r59/R59MutCounters/` (deleted before yield). Claim BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`; frozen plan `plans/round-59.md`
(af7b6651 + A1/A2); final lane commit `a0c77ec`.

## 1. Pinned bytes, detector, and the three battery revisions

Instrument bytes mutated here (sha256, final):

| file | sha256 |
|---|---|
| `plans/round-59-c1-check.py` | `6844c1d46545ca0f1bd9819128830717249480dadf0a7038bcc37ffba10a7743` |
| `plans/round-59-c1.sh` | `73a2fc68693a37ec62fcff80b2d46c33e76c86570d10f0c92cc8a1c21e56f2e3` |
| `plans/round-59-c2.sh` | `454a4177dcb6ae2dedd367b9409358b45a25fbac0692b5c3c05510d1ac6c525c` |
| `corpus/openbao-transit-trial.sh` | `e11e98f6cfc924131a52713fa496481e80efb89ffcdb9b6bc47b3234d8cc3e01` |
| `plans/round-59-controls.sh` (final detector) | `b3b49291bdd3c7e1787ea55a47b0ee1e8d91f102ba0ecdff14d805ff2416fcf6` |
| `plans/round-59-c1section.sh` (extract) | `edfdf178718b57b32cba3e9777d181bb33a47c2bfe516d3097d23054b93d84d0` |
| `plans/round-59-c2section.sh` (extract) | `681b9bc78dad5e87d71fdf7239bfdba3e444ecd4183c1f96b350b89738acf4a6` |
| `fasttrial.sh` (fixture, not evidence) | `edeb5662dd6bfba21f32d5669dc74bddc2c14f4e3603f8c41e7f3b7b1e5751cd` |

The detector is the round's own `plans/round-59-controls.sh`, run inside the mutant tree
(the battery resolves `REPO` from its own path; `c1()` runs the tree's checker and `c2()`
the tree's counter). The battery was revised three times while the wave ran; the attack
seats' readings are what forced the two fixes:

| revision | when | pristine full-battery reading | defect found |
|---|---|---|---|
| `5f6c576f…fd89` | 13:57 | `CONTROLS: match=18 mismatch=2` — `C1-F7` (`expect=FAIL got=0`), `C2-F2` (`expect=SETUP got=`) | F7 ran a stub as the checker and compared it to `FAIL` (unsatisfiable); C2-F2's `sed 's/^SETUP …'` never matched the prefixed trial line |
| `bd5993c4…44ce` | 14:35 | `CONTROLS: match=19 mismatch=1` — `C1-F7` empty (`expect=FAIL got=`) | C2-F2 fixed; F7 now invoked the Python checker with `bash`, so it printed no `C1_ROUTED` line |
| `b3b49291…fcf6` | 14:36, **frozen** (commit `a0c77ec`) | `CONTROLS: match=20 mismatch=0` (committed receipt `.ufo/waves/round-59/controls/controls-prefreeze.txt`; independently reproduced in `raw/baseline5.out`) | — both fixes in place |

All mutant verdicts below are measured on the final battery `b3b49291…fcf6` (or on its
verbatim extracted sections, hashes above). The first grid was measured on
`5f6c576f…fd89`; the instruments are byte-identical across the three revisions, and the
changed controls do not read the mutated logic (`C1-F7` reads the real checker's
fail-closed path; `C2-F2` reads the trial), so no verdict changed between revisions.
Section baselines on the final bytes: C1 `match=12 mismatch=0`
(`raw/c1section-pristine3.out`), C2 `match=11 mismatch=0`
(`raw/c2section-fast-pristine2.out`).

The nine C2 mutants were measured with the battery's C2 section on a contract-conformant
fixture trial (`fasttrial.sh`) because nine mutants × eight real-trial legs at the host's
load (several seats running the same battery, load average ~120) exceeded the time budget.
The fixture emits the frozen printed contract without running bao and reproduces the real
trial's control-level C2 grid on pristine bytes exactly (`match=11 mismatch=0`, incl.
`C2-F8 got=5`); it is a fixture, not evidence about transit mechanics. Real-trial
corroboration: N01-N03's F1-F4 readings are identical, and N08's F8 measured against the
real trial is 5 (§3).

Verdict rule: **KILLED** = at least one control's reading differs from its expectation on
the final battery; **SURVIVED** = every control matches.

## 2. Mutants

`-`/`+` are the exact changed lines (full unified hunks in `diffs/<id>.diff`, copied beside
this file). C1 mutants: `plans/round-59-c1-check.py`. C2 mutants: `plans/round-59-c2.sh`
(except N08: `corpus/openbao-transit-trial.sh`).

| id | injection (exact diff) | detector reading (final battery) | verdict | what it would let a report overclaim |
|---|---|---|---|---|
| M01 | `- ok = (int(m.group(1)), int(m.group(2))) == (n_base, n_land)`<br>`+ ... != ...` | K1-BASE 4 (exp 5); K1-REF FAIL (exp 0); F1 0; F2-F5 2; F8 0 | **KILLED** | — |
| M02 | `- return (HOLD if stated == delta else FAIL), det`<br>`+ return FAIL, det` | K1-REF 1 (exp 0); F1 2; F3-F5 2; F8 2 | **KILLED** | — |
| M03 | `- guard = 1 if (population == POP and chal_ok is True and stub_fails is True) else 0`<br>`+ guard = 1` | K1-BASE-GUARD 5 (exp FAIL); C1-F6 5 (exp FAIL); C1-F7 0 (exp FAIL) | **KILLED** | — |
| M04 | `last_line()` keeps only the first match:<br>`- hit = None / hit = ln / return hit`<br>`+ return ln (first) / return None` | K1-REF FAIL (exp 0); F1 3; F2-F5 3; F8 3 | **KILLED** | — |
| M05 | `- if line is None: return FAIL, "no 'Registry N → M …' line"`<br>`+ n_base, n_land = derive_registry_counts(ctx)`<br>`+ if line is None: return HOLD, "registry line absent; defaulted to the derived pair"` | `CONTROLS: match=12 mismatch=0` | **SURVIVED** | that I1 is "resolved and re-checkable" when the `Registry N → M at the candidate` statement is **absent**; a record that drops the correction line still reads 0 (§4 P1) |
| M06 | `- copy = os.path.join(tmp, "tree")` + `shutil.copytree(...)`; `- if os.path.realpath(copy) == root_abs:`<br>`+ copy = root`; `+ if ... and False:` | `match=12 mismatch=0` | **SURVIVED** | that the guard works on an isolated copy and QM74 holds; the challenge mutates the **measured tree** in place (§4 P2) |
| M07 | `- return FAIL, "no 'Registry N → M …' line"`<br>`+ return SKIP, "... same text ..."` | `match=12 mismatch=0` | **SURVIVED** | that all five items were evaluated / `population=5`; a missing input line emits `i1=x population=4` (fail-closed value, but the frozen population clause is violated; §4 P3) |
| M08 | `- a_ok = line is not None and all(n in lesson_ints for n in (total, c1, c2))`<br>`+ ... (total,)` | `match=12 mismatch=0` | **SURVIVED** | that I3 checks **all three** counts; a D3 statement with wrong C1/C2 subcounts (20/8/8) reads 0 (§4 P4) |
| M09 | `- stub_fails = not (isinstance(sv, int) and sv == expect)`<br>`+ stub_fails = True` | `match=12 mismatch=0` | **SURVIVED** | that the guard proves the printer-stub clause; it is satisfied by construction (the internal stub prints `value=0`, expected is `count+1 ≥ 1`), so the assignment is inert — no false green |
| N01 | `- [ "$(vec ...)" = "${EXPECT[...]}" ] && [ "${RC[...]}" = 1 ] && shims_ok++`<br>`+ [ "${RC[...]}" = 1 ] && shims_ok++` | C2-F6 5 (exp <5) | **KILLED** | — |
| N02 | `- pass=0; [ "$real_ok" = 1 ] && pass=5`<br>`+ pass=$(grep -cE '^TRIAL T[1-5] ' "${OUT[real]}")` | `match=11 mismatch=0` | **SURVIVED** | the receipt's `pass=P` field read as "P tests passed": on a transcript with all five T-lines BROKEN the counter prints `pass=5` while `value=0` (§4 P5) |
| N03 | secret scan deleted:<br>`- if cat "$SCR"/log/* \| grep -qE 'r59-…\|(hvs\|hvb)\.'; then nosecret=0; fi` | `match=11 mismatch=0` | **SURVIVED** | kill rule K3: a receipt carrying `hvs.`/`r59-` still reads 5; the battery has no secret fixture (§4 P6) |
| N04 | `- real_ok = rc[real] && rc[real2] && vec[real] && vec[real2]; grep real; grep real2`<br>`+ real_ok = rc[real] && vec[real]; grep real` | `match=11 mismatch=0`; C2-F4 still 0 | **SURVIVED** (low materiality) | "two independent runs" is not tested by `real_ok`; on a single-run trial the mutant reads `real=1` but still `value=0` because `clean_ok` reads CLEANROOM in real2's output — the clause is enforced by an incidental conjunct (§4 P7). A combined mutant that also relaxes `clean_ok` is killed by C2-F4 |
| N05 | `- none_ok=0; [ "${RC[none]}" = 2 ] && ! grep -q 'HOLDS' ... && none_ok=1`<br>`+ none_ok=1` | `match=11 mismatch=0` | **SURVIVED** | kill rule K1: a trial that fakes HOLDS when no `bao` is on PATH scores 5; the battery's only no-bao check is trial-level (`C2-F2`) (§4 P8) |
| N06 | `- pass=0; [ real_ok ] && pass=5; value=0; [conjunction] && value=5`<br>`+ pass=5; value=5` | C2-F1/F3/F4/F5/F6 = 5 (exp <5 / 0) | **KILLED** | — |
| N07 | `- for m in real real2; do [ "$(verdict ... CLEANROOM)" = HOLDS ] \|\| clean_ok=0; done`<br>`+ clean_ok=1` | C2-F3 5 (exp <5) | **KILLED** | — |
| N08 | clean-room leg reuses the first server and maps a successful same-server decrypt to HOLDS:<br>`- start_server; ... decrypt on baddr; refusal -> HOLDS`<br>`+ baddr="$oa"; ... decrypt on the first server; success -> HOLDS` | no control detects it; counter on the mutant trial reads `value=5 … cleanroom=1` | **SURVIVED** | that the clean-room leg is a second, independent server; it is the declared K4 ceiling — the counter cannot see it and receipts/probes must (§4 P9) |
| N09 | `- [ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] && [ "$clean_ok" = 1 ] && value=5` (line removed; value stays 0) | C2-F8 0 (exp 5) | **KILLED** | — |

Totals: **8 killed, 10 survived** (survivors: M05-M09, N02-N05, N08).

## 3. Real-trial corroboration

The first full-battery grid on `5f6c576f` ran the C1 half for M01-M06 before the host load
made the C2 half pathological; its C1 readings equal the final grid. The C2 mutants'
real-trial sections reached C2-F4 for N01-N03 with readings identical to the fast fixture.
N08 was measured against the real trial, twice:

```
EDIT N08 corpus/openbao-transit-trial.sh e11e98f6… -> cd090cb996d6abdbcbce877cd75d6c7182b9a85b96cb0bfdbe1982c870f5f479
C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)   (rc=0)
```

## 4. Survivor materiality probes

Each probe builds a fixture and runs the pristine and mutated checker/counter; raw output
is in `raw/probe-c1.txt`, `raw/probe-c2.txt`, `raw/probe-c2-fast.txt`.

**P1 (M05) — the I1 statement line is deleted from an otherwise-fixed tree.**
`pristine: C1_ROUTED: value=1 population=5 i1=0 …` vs
`M05: value=0 population=5 i1=1` (evidence line: `i1 HOLD registry line absent; defaulted to
the derived pair`). A deleted correction line is invisible to the claim.

**P2 (M06) — the challenge copy resolves at the measured tree.**
Pristine leaves the fixture lesson sha256
`9665e1533dc1ff042fa48fc0866e38a43f3d24558c0ab3bf65bf7d38e2a984eb`; the M06 run changes it to
`b501aef12fc71ea279acfd1b64089e9b24d7028367975c044a01c105c785f821` (the last `Registry …` line
`117 → 120` became `117 → 121` in the measured tree) while both print `value=0 … guard=1`.
This is the round-58 M58-3 / QUALITY QM74 defect class; no control hashes or re-reads the
fixture.

**P3 (M07) — the lesson is absent.**
`pristine: value=FAIL population=5 i1=0 …` vs `M07: value=FAIL population=4 i1=x …`. The
pass/fail token is unchanged (fail-closed), so the survivor cannot produce a false green; it
violates the frozen "prints population=5 with i1..i5 each 0|1, none skipped" clause and
C1-F6 (which only reads the token) cannot see it.

**P4 (M08) — D3 states the wrong subcounts.**
Fixture line `… holds 20 control lines, 8 C1 and 8 C2.`:
`pristine: value=1 … i3=0` vs `M08: value=0 … i3=1`.

**P5 (N02) — pass counts printed T-lines.**
Fixture trial prints `TRIAL T1..T5 BROKEN` + `TRIAL CLEANROOM HOLDS` + a HOLDS summary:
`pristine: value=0 … pass=0` vs `N02: value=0 … pass=5`. The value is unchanged; the
printed `pass` field is not load-bearing.

**P6 (N03) — secret scan removed.**
Fixture trial writes `hvs.NOTAREALTOKENVALUE` to stderr then delegates:
`pristine: value=0 … secret=0` vs `N03: value=5 … secret=1`. K3 is enforced only by the
scan the mutant deletes.

**P7 (N04) — single real run (forced order real, real2, …).**
Wrapper refuses the second empty-shim invocation:
`pristine: value=0 … real=0 … cleanroom=0` vs `N04: value=0 … real=1 … cleanroom=0`.
The mutant accepts one real run (`real=1`) but `clean_ok` still reads CLEANROOM in real2's
output, so the value stays 0. The two-run clause is redundantly enforced; the survivor is
low materiality.

**P8 (N05) — no-bao leg dropped.**
Fixture trial fakes an all-HOLDS transcript when `bao` is absent:
`pristine: value=0 … none=0` vs `N05: value=5 … none=1`.

**P9 (N08) — clean-room leg reuses the first server.**
A PATH `bao` wrapper logs `server -dev` starts: pristine trial **2** starts, N08 trial **1**;
both print `TRIAL CLEANROOM HOLDS own-storage-refused=1`, and the pristine counter on the
N08 trial reads `value=5 … cleanroom=1`. The second server's existence is invisible to the
counter (declared K4 ceiling; receipts and a non-author probe are the check).

## 5. Findings routed (not amended here)

**Battery defects found and fixed during the wave** (the final battery is green; the values
are kept as calibration evidence):

1. `5f6c576f`: `C1-F7` was unsatisfiable (it ran a printer stub as the checker and compared
   its `value=0` to the literal `FAIL`); `C2-F2`'s sed (`^SETUP …`) never matched the
   trial's prefixed `OPENBAO_TRANSIT_TRIAL: SETUP …` line. Reported; fixed at
   `b3b49291`.
2. `bd5993c4`: the `C1-F7` fix invoked the Python checker with `bash`, so it printed no
   `C1_ROUTED` line and the control was empty. Reported; fixed at `b3b49291`
   (`python3 -I -B "$REPO/plans/round-59-c1-check.py"` with an uncreatable
   `C1_CHALLENGE_PARENT`).
3. The final battery's pristine reading is `CONTROLS: match=20 mismatch=0` (committed
   receipt; independently reproduced in `raw/baseline5.out`).

**Coverage findings that remain** (each is what a survivor walks past):

4. No control deletes only the I1 statement line (M05); C1-F6 removes the whole lesson.
5. No control changes only the I3 C1/C2 subcounts (M08); C1-F3 changes the total, which
   the reduced check still reads.
6. No control hashes or re-reads the measured fixture (M06); an in-place challenge copy is
   invisible to the battery.
7. C1-F6 reads only the value token (M07); a `SKIP`/`population=4`/`i1=x` contract
   violation is not distinguished from the valid fail-closed reading.
8. No control plants a secret-shaped string (N03); K3 rests entirely on the counter's scan.
9. No counter-level no-bao control (N05); C2-F2 is trial-level.
10. The two-independent-runs clause is enforced by `clean_ok`, not `real_ok` (N04); a
    mutant dropping `real2` from `real_ok` alone cannot overclaim `value=5` on the battery's
    F4 fixture.
11. The clean-room leg's independence cannot be read from the printed contract at all
    (N08); K4's ceiling, already named in the plan.
12. Record note: the L1's freeze message quoted a battery sha256 whose tail does not verify
    (`b3b49291…d8c0a1`); the committed blob and the receipt both carry
    `b3b49291bdd3c7e1787ea55a47b0ee1e8d91f102ba0ecdff14d805ff2416fcf6` (verified with
    `git show a0c77ec:plans/round-59-controls.sh | sha256sum`). Message-level typo only.

## 6. Evidence, provenance, restoration

- Final full battery: `raw/baseline5.out`; committed receipt
  `.ufo/waves/round-59/controls/controls-prefreeze.txt` (`match=20 mismatch=0`).
- Earlier battery revisions: `raw/baseline3.out` (`5f6c576f`, 18/2),
  `raw/baseline4.out` (`bd5993c4`, 19/1), `raw/baseline2.out` (pre-I5-fix checker, 14/6).
- Section baselines: `raw/c1section-pristine3.out` (12/0),
  `raw/c2section-fast-pristine2.out` (11/0), `raw/c2section-fast-pristine.out` (5f6c, 10/1).
- Per mutant (final battery): `runs3/<id>-c1section/{out,rc,hashes.txt,restored.txt,edit.txt}`;
  C2: `fastruns2/<id>/{out,rc,hashes.txt,restored.txt,edit.txt}`; first-grid receipts:
  `runs/<id>-c1section`, `fastruns/<id>`, `runs/N0x-c2section` (real-trial partials).
- Mutation declarations: `specs/<id>.json`; exact unified hunks: `diffs/<id>.diff`;
  injection scripts: `mutate.py`, `mkspecs.py`; fast fixture: `fasttrial.sh`.
- Restoration: every `restored.txt` ends `RESTORATION: exact` with the pristine sha256
  (`6844c1d4…` checker, `454a4177…` counter, `e11e98f6…` trial); mutant bytes exist only
  inside scratch fixture trees.
- The lane was written by this seat only under
  `.ufo/waves/round-59/build/R59MutCounters/`; the instruments were always measured from
  scratch copies. No tool installs or upgrades were made.

## Appendix A — full unified hunks

`diffs/M01.diff` … `diffs/N09.diff` are copied beside this file; each contains the complete
`diff -u` hunk for its mutant (the `-`/`+` lines in §2 are excerpted from them).

SEAT-STATUS: complete
