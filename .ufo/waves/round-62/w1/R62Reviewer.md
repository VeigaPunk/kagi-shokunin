# R62Reviewer — attack findings (round 62, kagi)

Seat: reviewer (attack). Read-only: no production file changed by this seat; every attack
tree is a copy under the seat's scratch. Receipts: `.ufo/waves/round-62/build/R62Reviewer/`.

Measured trees and instrument pins (measured, not quoted):

- `tree0` = `git -C <lane> archive HEAD | tar -x` at `8e5463c7937dccdd97fd5a812b8091f83b708aa7`
  (10690 files). Every attack tree is `tree0` plus one byte-exact replacement.
- BASE C1 checker `plans/round-61-c1-check.py` `d525ee28…` 67905 B (17:12);
  hardened `f2afd9b8…` 81640 B (18:18), `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (75 cases)` rc 0.
- BASE C2 counter `plans/round-61-c2.sh` `c7d9e272…` 21275 B (17:20);
  hardened `20614697…` 25970 B (18:15), `--selftest` ⇒ `C2_SELFTEST: PASS (cases=21)` rc 0.
- C1 claim counter `plans/round-62-c1.sh`: `19ea1131…` 17971 B (18:17) → `5c71947d…` 19230 B (18:26).
- C2 claim counter `plans/round-62-c2.sh` `59553ef4…` 14818 B (18:17),
  `--selftest` ⇒ `C2R62_SELFTEST: PASS (cases=16)` rc 0.
- Scratch: `/fast/scratch/hyaku/kagi-r62/R62Reviewer` (removed before yield).

Command legend (all run from `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

```
C(<tree>) = python3 -I -B plans/round-61-c1-check.py \
              --root /fast/scratch/hyaku/kagi-r62/R62Reviewer/trees/<tree> \
              --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
K(<tree>) = bash plans/round-62-c1.sh --tree <tree>
W(<tree>) = bash plans/round-62-c2.sh --tree <tree>
```

The accepted line is identical on every accepted tree:
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` (rc 1).

## 1. C1 — new bypass trees beyond the frozen five

Fourteen new forgery trees (N-series) and three benign controls (P6–P8), each one
byte-exact replacement; the frozen five are re-measured on the same tree0. BASE column =
`C(<tree>)` on `d525ee28`; hardened column = `C(<tree>)` on `f2afd9b8`.

| id | attack | file · anchor → replacement | BASE | hardened | verdict |
|---|---|---|---|---|---|
| B3 | frozen: negated withdrawal | `plans/round-60.md` `**A3 item 2 is withdrawn**` → `**A3 item 2 is not withdrawn**` | accepted | rejected `i3=0` | closed |
| B4 | frozen: `no three` | `corpus/lessons/round-60.md` `the round introduced three new record defects it did not route` → `… no three …` | accepted | rejected `i4=0` | closed |
| B5 | frozen: `not rewritten` | `LOG.md` `it was rewritten in place at` → `it was not rewritten in place at` | accepted | rejected `i5=0` | closed |
| B6 | frozen: denial tail | `corpus/lessons/round-60.md` `the lane was progressing, not stale.` → `the paragraph's times are correct.` | accepted | rejected `i6=0` | closed (needs Amendment A1 clause d; the frozen I6 text alone accepts — see D-8) |
| B7 | frozen: swapped pairing | `corpus/lessons/round-60.md` `… 3/16 = 18.75 % … 4/16 = 25 %` → `… 3/16 = 25 % … 4/16 = 18.75 %` | accepted | rejected `i7=0` | closed |
| N1 | negator `never` | `plans/round-60.md` `**A3 item 2 is withdrawn**` → `**A3 item 2 is never withdrawn**` | accepted | rejected `i3=0` | closed |
| N2 | negator `hardly` (not in the closed set) | `**A3 item 2 is hardly withdrawn**` | accepted | **accepted** | open — D-5 |
| N3 | denial **after** the token | `**A3 item 2 is withdrawn — the record denies it**` | accepted | **accepted** | open — D-5 |
| N4 | negation beyond the 5-token window | `**A3 item 2 is not, as the earlier draft asserted, withdrawn**` | accepted | **accepted** | open — D-5 |
| N5 | `not merely three` | `corpus/lessons/round-60.md` `… introduced three …` → `… introduced not merely three …` | accepted | rejected `i4=0` | closed |
| N6 | `three` quoted then denied | `… introduced "three new record defects it did not route", a claim the record refutes` | accepted | **accepted** | open — D-5 |
| N7 | negator truncated at a colon | `… did not introduce: three new record defects it did not route` | accepted | **accepted** | open — D-5 |
| N14 | negation beyond the 5-token window (I4) | `… did not introduce, as the earlier claim had it, three …` | accepted | **accepted** | open — D-5 |
| N8 | negator `never` (I5) | `LOG.md` `…` → `it was never rewritten in place at` | accepted | rejected `i5=0` | closed |
| N9 | negation beyond the 5-token window (I5) | `it was not, contrary to the earlier record's claim, rewritten in place at` | accepted | **accepted** | open — D-5 |
| N10 | swapped pairing with `%` glued | `corpus/lessons/round-60.md` `… 3/16 = 18.75 % … 4/16 = 25 %` → `… 3/16 = 25% … 4/16 = 18.75%` | accepted | rejected `i7=0` | closed |
| N11 | subjects swapped, each fraction correctly paired | `… literal reading is 4/16 = 25 %, … sentinel … gives 3/16 = 18.75 %` | accepted | **accepted** | open — D-4 |
| N12 | fabricated stamp **replaces** the superseded paragraph's stamp | `corpus/lessons/round-60.md` `launch 15:09:28 −03` → `launch 16:59:59 −03` (16:59:59 is not in the derived set) | accepted | **accepted** | open — D-3 |
| N12b | fabricated stamp **added** beside the four derived stamps | `launch 15:09:28 −03 (also seen at 16:59:59 −03)` | accepted | **accepted** | open — D-3 |
| P6 | benign: `has been withdrawn` | `plans/round-60.md` `**A3 item 2 is withdrawn**` → `**A3 item 2 has been withdrawn**` | accepted | accepted | correct (no false positive) |
| P7 | benign: `not only` idiom | `corpus/lessons/round-60.md` `… introduced not only three …` | accepted | accepted | correct |
| P8 | benign: `rewritten in place, at` | `LOG.md` `it was rewritten in place, at` | accepted | accepted | correct |

Measured totals: BASE accepted 22/22; hardened rejected the frozen five **and** N1, N5, N8,
N10 (9 trees) and accepted N2, N3, N4, N6, N7, N14, N9, N11, N12, N12b plus the three benign
controls (13 trees). The claim's frozen target (the five committed fixtures, 5 → 0) holds;
the negation/swapped-pairing **class** is narrowed, not closed.

## 2. C1 counter attacks

| id | attack | command | observed | verdict |
|---|---|---|---|---|
| A1 | printer-stub checker (self-attests `value=0`) | `K(trees/stubcheck)` | `c1-counter: refuse: tree checker --selftest printed no C1_CHECK_SELFTEST: PASS line (rc=0) — no verdict`, rc 2, no `C1_BYPASS:` line | refused (guard leg c works) |
| A2 | fixture anchor occurs **0** times | `K(trees/zeromatch)` | `c1-counter: SETUP fixture B3: … anchor must occur exactly once in plans/round-60.md (0 or >1 occurrences fails closed)`, rc 2 | refused (SETUP, never accepted=0) |
| A3 | fixture anchor occurs **2** times | `K(trees/dupmatch)` | same SETUP line, rc 2 | refused |
| A4 | revision that does not exist | `bash plans/round-62-c1.sh deadbeefdeadbeefdeadbeefdeadbeefdeadbeef` | `c1-counter: SETUP bad revision: deadbeef…`, rc 2 | refused |
| A5 | case-count parse: checker prints `(57 cases)` | `K(trees/fakehard)` on the 16413 B bytes (18:08) | `c1-counter: selftest rc=0 pass=1 cases=1 (guard needs >= 57)` + `C1_BYPASS: accepted=5 population=5 guard=0`, rc 1 | **defect D-1** (fixed 18:17) |
| A6 | measure leg on a tree whose last fixture is rejected | `K(.)` on `19ea1131` (17971 B) | `c1-counter: SETUP measure leg failed`, rc 2 | **defect D-2** (fixed 18:26) |
| A7 | candidate tree, current bytes | `K(.)` on `5c71947d` (19230 B) | `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1)`, rc 0 | verifies |
| A8 | counter's own selftest | `bash plans/round-62-c1.sh --selftest --tree .` | `C1_COUNTER_SELFTEST: PASS (7/7 checks)`, rc 0 | passes; check 7 is the D-2 regression |

A1–A4 were measured on the 16413 B counter (18:08); the same refusal code paths are present in
the current bytes, whose stub leg reads `c1_counter: stub c1_rc=2 c1_ok=1 c2_rc=2 c2_ok=1`
(A7). A5 was measured on the same 16413 B bytes; A6 on the 17971 B bytes; A7/A8 on the current
19230 B bytes.

`grep -oE '[0-9]+' <<<"C1_CHECK_SELFTEST: PASS (57 cases)" | head -1` ⇒ `1` (the `1` in
`C1_CHECK_SELFTEST`), which is the D-1 mechanism; the 18:17 bytes replace it with a
parenthesised `sed` parse and the current run reads `cases=75`.

## 3. C2 attacks

| id | attack | command | observed | verdict |
|---|---|---|---|---|
| B1 | M-A at BASE (aggregation → `value=5`) | `bash <BASE copy>/plans/round-61-c2.sh --selftest` | `C2_SELFTEST: PASS (cases=11)` rc 0 | survives at BASE (killed 0) |
| B2 | M-B at BASE (shim aggregation → unconditional) | same | `C2_SELFTEST: PASS (cases=11)` rc 0 | survives at BASE |
| B3 | G at BASE: valid-sha256 stub trial, prints nothing | `bash plans/round-61-c2.sh --tree trees/stubtrial` | `C2_SEAL_TRIAL: value=0 … guard=1 …`, rc 1 | guard does not discriminate at BASE |
| B4 | M-A on hardened counter | `bash <mutant>/plans/round-61-c2.sh --selftest` | `FINDING R61-C2-ST-decide-pass` … `decide-t2w` (6), `C2_SELFTEST: FAIL (cases=21 failed=6)` rc 1 | killed |
| B5 | M-B on hardened counter | same | `FINDING R61-C2-ST-shims-ok/-bad/-summary` (3), `C2_SELFTEST: FAIL (cases=21 failed=3)` rc 1 | killed |
| B6 | G on hardened counter | `bash plans/round-61-c2.sh --tree trees/stubtrial` | `C2_SEAL_TRIAL: value=0 … guard=0 …`, rc 1 | killed |
| B7 | real trial positive control | `bash plans/round-61-c2.sh --tree trees/tree0` | `C2_SEAL_TRIAL: value=5 … shims=5 vectors=ok/5 … guard=1 … cases=63`, rc 0 | holds |
| B8 | claim counter on the candidate | `W(.)` | `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)`, rc 0 | verifies |
| B9 | constant-verdict counter (selftest → `PASS (cases=99)`, aggregation intact) | `W(trees/constverdict)` | `C2_HARDENED: killed=1 population=3 guard=0 (ma=0 mb=0 g=1 selftest=1 real=1)`, rc 1 | refused (guard leg c) |
| B10 | printer-stub **claim counter** (`plans/round-62-c2.sh` prints `killed=3 guard=1`) | `bash <stub>/plans/round-62-c2.sh` | `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=0 selftest=1 real=1)`, rc 0 | **defect D-6**: no leg refuses a stub claim counter |
| B11 | fabrication stub: never starts a server, calls `bao <op> --help`, prints the T2 markers | `bash plans/round-61-c2.sh --tree trees/fabstub` | `C2_SEAL_TRIAL: value=5 … ops=1 t2w=1 … guard=1 …`, rc 0 (BASE **and** hardened) | ceiling (named in plan §C2) |
| B12 | receipt naming a nonexistent revision | `git cat-file -e deadbeef…^{commit}`; `grep -nE 'final/\|candidate\.txt\|receipt' plans/round-62-c1.sh plans/round-62-c2.sh` | `fatal: Not a valid object name`; no hits in either counter | **defect D-7**: the counters never read the receipt; only `plans/round-62-routed.sh` d4 would (`rev-exists=0`) |

## Defects

**D-1 (HIGH, fixed in-round at 18:17) — C1 counter case-count parse read `1` for every checker.**
`plans/round-62-c1.sh` (16413 B) did `ST_N="$(grep -oE '[0-9]+' <<<"$line" | head -1)"` on
`C1_CHECK_SELFTEST: PASS (52 cases)`; the first digit is the `1` in `C1_CHECK_SELFTEST`, so
`ST_N=1` always and `selftest=0` ⇒ `guard=0` for every tree. A checker whose selftest printed
`(57 cases)` still read `cases=1` (`trees/fakehard`, observed above). Fix landed: the 18:17
bytes parse the parenthesised number (`sed -n 's/^C1_CHECK_SELFTEST: PASS (\(cases=\)\{0,1\}…`).
**Residual:** the counter's `--selftest` has no case that asserts the parsed count, so a
re-introduced parse bug would pass 7/7 again; add one.

**D-2 (HIGH, fixed in-round at 18:26) — C1 counter's measure leg returned the last fixture's status.**
`measure_battery` ended with `[[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED + 1))` inside the
fixture loop; when the last fixture (B7) is rejected — the intended hardened outcome — the
`[[ ]]` is false, the loop and the function return 1, and the caller runs
`setup_die "${AF_ERR:-measure leg failed}"` with `AF_ERR` empty. The counter could report the
claim's failure (`accepted=5`) but never its success. Evidence: `bash -x` trace, last
iteration `+ [[ 1 == 0 ]]` → `+ setup_die 'measure leg failed'`. Fix landed: `return 0` at the
end of `measure_battery` plus selftest check 7 (`measure-leg-rejected-tail`).

**D-3 (MEDIUM, open) — I6's "superseded stamp" conjunct is satisfied by any non-derived time.**
`_qualifying_times` returns every `HH:MM:SS` that is neither the launch time nor a derived
committer time; a forger who replaces the superseded paragraph's `15:09:28` with an invented
`16:59:59` (N12), or adds an invented stamp beside the real one (N12b), still satisfies it and
reads `value=0`. The QM78 intent ("the superseded paragraph's stamp must be quoted") is not
tested. Fix: derive the superseded stamp from the round-60 report bytes (the paragraph the
correction names) and require that specific time, not merely "not derived".

**D-4 (MEDIUM, open) — I7 pairs fraction↔percentage but not fraction↔subject.**
`_pair_re` accepts `4/16 = 25 %` and `3/16 = 18.75 %` anywhere in the asserted text; N11 swaps
the subjects (`the literal reading is 4/16 = 25 %, … the sentinel … gives 3/16 = 18.75 %`) and
reads `value=0`. Fix: require each fraction to sit in the same clause as its subject phrase
(e.g. `literal reading is 3/16`, `sentinel … gives 4/16`).

**D-5 (MEDIUM, open; named ceiling) — the I3/I4/I5 window is before-only and 5 tokens.**
Accepted forgeries: `hardly withdrawn` (N2, negator outside the closed set), `withdrawn — the
record denies it` (N3, denial after the token), `not, as the earlier draft asserted, withdrawn`
(N4, `not` > 5 tokens back), `"three …" a claim the record refutes` (N6, quotation then
denial), `did not introduce: three …` (N7, truncation at `:` resets the window), the I4 and I5
window-distance variants (N14, N9). The plan names the floor; the report must state that the
class is narrowed, not closed. Fix (next round): widen the negator set, scan both directions,
and do not reset the window at a colon the forger controls.

**D-6 (MEDIUM, open) — no leg refuses a stub claim counter.**
`plans/round-62-c2.sh` replaced by a four-line printer reads
`C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=0 selftest=1 real=1)` rc 0. The frozen
predicate's guard legs measure the *measured* counter (`plans/round-61-c2.sh`), not the claim
counter itself; the controls battery's C2-F5 also tests a stub *measured* counter. Fix: pin the
claim counter's sha256 in the committed receipt and have the controls battery hash it (the C1
counter has the same shape: a stub `plans/round-62-c1.sh` printing `accepted=0 guard=1` would
be equally unrefused — [INFERENCE], the C1 stub was not built).

**D-7 (LOW, open) — the claim counters never read the candidate receipt.**
Neither `plans/round-62-c1.sh` nor `plans/round-62-c2.sh` mentions `.ufo/waves/round-62/final/`
or `candidate.txt`; a receipt naming `deadbeef…` is not read. `plans/round-62-routed.sh` d4
does validate it (`git cat-file -e`, `merge-base --is-ancestor`, both verdict lines), so the
refusal exists — but only if d4 is run and its result is required before the verdict is
accepted ([INFERENCE] from the d4 code at `plans/round-62-routed.sh:113-125` plus the failing
`git cat-file -e`; the d4 leg itself was not run against a real receipt). Fix: make the claim receipt a counter output (the counter writes the revision it
measured), or make d4 a precondition of the verdict.

**D-8 (process, open) — the frozen plan carries an uncommitted `## Amendment A1` that changes I6's item condition.**
`git diff plans/round-62.md` shows +21 lines adding clause (d) (`times are correct` / `times are
right` / `is correct` / `are correct` refused) after the predeclaration commit `8e5463c`. The
amendment is *needed*: B6 keeps every token the frozen I6 text tests (the superseded `15:09:28`
and the four derived stamps survive the tail substitution), so B6 reads accepted under the
frozen text alone and C1-K2 cannot fire. But it amends a frozen item condition; it must be
committed as a disclosed amendment with its own hash, and the report must state that the
predeclaration bytes do not carry it.

**D-9 (LOW, open) — the C1 counter's `accepted` counts `value==0`, not the target item.**
[INFERENCE] A tree where an unrelated item fails on every fixture would read `accepted=0`
while the forgeries are accepted; the guard leg (a) catches only an unmodified-tree failure.
Not built: the construction needs a cross-item dependency the current checker does not have. The controls
battery's C1-F1..F5 ("exactly 1") cover it, but the counter alone does not. Fix: parse the
`i(k)` token and require it to be 0 for fixture B(k).

## Residual risk and verification gaps

- **The frozen five close; the class does not.** 10 of 14 new forgery trees still read
  `value=0` on the hardened checker (`f2afd9b8`). The plan's named ceiling ("a sixth negation
  or pairing class is a new routed defect, not a claim failure") covers this; the round report
  must not claim the class is closed.
- **C1 and C2 both verify on the current bytes** (`accepted=0 population=5 guard=1` rc 0;
  `killed=3 population=3 guard=1` rc 0), but only after D-1 and D-2 were fixed during the wave.
  A receipt taken before 18:26 would read `SETUP measure leg failed`; the committed receipt
  must name the 19230 B counter bytes.
- **The fabrication class is unchanged** (B11): a 38-line stub that never starts a server reads
  `value=5 guard=1` on the hardened C2 counter. The plan declares this ceiling; it is not
  closed by this round.
- **Not run by this seat:** `plans/round-62-controls.sh` (the L1 runs the pre-freeze battery),
  the routed script's d4 leg against a real receipt (writing the L1's `final/candidate.txt` is
  outside this seat's write scope), and any real-trial run beyond the two counter-driven ones
  above.
- **Tooling:** none installed, upgraded or removed by this seat.

SEAT-STATUS: complete
