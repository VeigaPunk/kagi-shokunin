# R58ReviewerCounters — false-green attack on the round-58 counters

Seat: `R58ReviewerCounters` (reviewer). Round 58, attempt 1, one v1 wave.
Read-only on the lane instruments; every tree below was built in
`${HYAKU_SCRATCH}/kagi-r58/R58ReviewerCounters/` and deleted at the end. No lane file was
edited, no git/jj command was run. No tool was installed.

## 1. Instruments and timebase

All paths relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

| instrument | bytes | sha256 at review | state |
|---|---|---|---|
| `plans/round-58.md` | — | `8b60ccb7e090e3f5a90b0826b2d190490b2328c84c17e91fedcb40b9d355601f` | modified, uncommitted (`0085a5f` + A1–A4) |
| `plans/round-58-c1-check.py` | 42,792 | `d37829c017aabe789336c853bb09604d0c30978c84914a20a2d4de185040c77f` | untracked |
| `plans/round-58-c1.sh` | 8,986 | `48eab526ff9bb8c10a7ed9462addafe9f035223f835c7540c0b044e958df0d15` | untracked |
| `plans/round-58-c2.sh` | 7,639 | `8baaf3486f1390d99c67e5406655ae177b68ef89024c6a1a3b0b1f13a5dd11b0` | untracked |
| `plans/round-58-controls.sh` | 9,499 | `19dd68998520b7244244a9548f89b8ecfa3f0b46eeda198b6dac870c994acba3` | untracked |
| `corpus/openbao-policy-trial.sh` | 13,620 | `1f1eed9d872a1a1367d737d63a45f1d8eb2c9fe6fa322d5e96a95dba934d0b4a` | untracked |

The instruments moved during the review (checker 12:12 → 12:19; plan A3 12:17, A4 ~12:28;
controls 12:25). Every reading below is against the shas above; a later edit may
supersede it. Mtimes and shas are receipts in this directory (`instrument-shas.txt`).

Method: read the checker and both drivers line by line; ran the counters on the claim
BASE (`1b13f5d`), on the live worktree, and on purpose-built trees; each item was also
exercised alone with `--no-challenge`. Evidence files are listed in §8.

## 2. Verdicts

| counter | verdict | basis |
|---|---|---|
| **C1** | **EXPLOITABLE — false greens reach `value=0 guard=1` exit 0** | E1 (in-tree decoy coverage row: the real row says 999, the counter reads 0/guard=1) and E2 (all checked files are symlinks to a host directory outside the measured tree: 0/guard=1). Per-item wording shapes E3–E6 and the declared-forgery shapes E7–E8 also read resolved. The counter cannot distinguish the earned candidate reading from these trees. |
| **C2** | **EXPLOITABLE within the declared K2 ceiling; one confinement hole outside it** | E9: a 1.3 KB mock trial that measures nothing (reads `KAGI_POLICY_SHIM`, detects the regular-file `bao` wrapper) reads `value=5`. E10: a tree whose `corpus` directory is a symlink to a host directory reads `value=5`; the trial is not in the tree. QM56 is satisfied: every leg's rc is read. |

The C1 counter *does* bite the shapes it names: a printer stub fails the challenge leg,
the I4 wrong-count challenge fires on an all-hold tree, and the BASE diagnostic count is
8; `C1_CHECK_SELFTEST: PASS (18 cases)`. The defects are in the per-item structural
reads and in path confinement, not in the aggregate arithmetic.

**Population deletion.** No direct false green: each item returns `SKIP` when its input
file is absent (LOG/SKILL/lesson/SOURCES/scope-gate), `evaluate()` turns any SKIP into
`value=FAIL` with `population<8`, and the driver requires population=8 with every `iN` in
`{0,1}` (`ALL8`). The effective population deletion is E1: the real statement stays in
the file but is shadowed out of the read population by a duplicate row.

## 3. C1 exploit rows

All readings are the counter's final `C1_ROUTED` line. "Truthful" is the reading the
item's routed-defect substance requires. Receipts in `receipt-c1-*.txt`.

| id | tree / command | observed | truthful | fault | minimal patch |
|---|---|---|---|---|---|
| **E1** | `bash plans/round-58-c1.sh --tree decoytree` — one fabricated `| coverage |` row inserted directly after `## Round 57 — post-move` with correct counts; the real coverage row carries `Registry 114 → 999` and `tip count = 999` | `C1_ROUTED: value=0 population=8 i1=1 … i8=1 guard=1`, rc 0 (`receipt-c1-decoy-row.txt`) | i4=0, no green: the round-57 coverage statement still lies | **implementation**: `coverage_row()` (`round-58-c1-check.py:221`) returns the **first** line starting `| coverage` in the section; a second row shadows the real one | require exactly one coverage row in the post-move section; read every `| coverage` row and fail on a duplicate. Expected after: i4=0, `value=FAIL/≥1` |
| **E2** | `bash plans/round-58-c1.sh --tree symfull` — 14 checked inputs are absolute symlinks to `/fast/scratch/.../hostfixed` (LOG, SCORECARD, SKILL, lesson-57, SOURCES, current-claims, five plans, receipt, gates.txt, S117.body); only `corpus/scope-gate.sh` is in-tree | `C1_ROUTED: value=0 … guard=1`, rc 0; driver reports `copied 2 files` (`receipt-c1-symlink-tree.txt`) | the measured tree does not contain the bytes it is credited with; a revision would carry only symlinks | **implementation**: `rd()`/`sha_of()` (`:139`,`:147`) and the driver's `tar` copy (`round-58-c1.sh:68`) follow symlinks; `item6`/`item8` execute them; no `realpath` containment | resolve every read path with `realpath` and require it under `realpath(root)`; refuse a symlinked component (or `-L` on each) → SETUP/FAIL. Expected after: `value=FAIL` or SETUP, exit 1/2 |
| **E3** | `checker --root symv1` — LOG correction reads `No freeze epoch C was recorded; the missing receipt would be .ufo/.../controls-prefreeze-epochC-never.txt` | `i1=1` (`receipt-c1-exploit-v1.txt`) | i1=0: the record negates what it must name | **predicate**: `EPOCH_C_RE` (`:118`) and `EPOCH_C_RECEIPT_RE` match a negation and a non-existent path | I1 must require a positive statement, same bullet as the path, and the path must exist. Exact text in §6 |
| **E4** | `checker --root symv3` — S117 Gate row keeps URL/date/used-by/source but the quote is the single word `“hash”` (occurs in S117.body) | `i3=1` (`receipt-c1-exploit-v3.txt`) | i3=0: no located sentence | **predicate**: I3 says “a quote of at most 25 words that occurs”; `1 <= len(qc.split())` (`:309`) admits one word | require 6–25 words and the row's anchor term; exact text §6 |
| **E5** | `checker --root symv5` — the real gate-registry row is deleted; a fake row in an unrelated table carries `corpus/current-claims.py`, `python3`, `--selftest`, `SETUP`, codes 0/1/2 | `i5=1` (`receipt-c1-exploit-v5.txt`) | i5=0: `SKILL.md`'s gate registry has no row | **implementation**: `item5` (`:370`) scans every `|` line in the file, any table | require the row inside a `## Gate registry` section; exact text §6 |
| **E6** | `checker --root t6` — BASE `current-claims.py` plus a dead `add_argument("--round")`, a `%`-built round-56 surface, an EPOCHS sentence, and `--selftest` rc 0; `--round 57` and `--round 56` audit the same round-56 surface | `i6=1` (`receipt-c1-exploit-v6.txt`) | i6=0: `--round N` does not move the audited surface | **implementation**: `item6` (`:415`) checks an AST precondition, not behavior; a dead argument and a constant `% 56` satisfy it | run the gate on synthetic two-round roots and require `--round 57` (clean) ≠ `--round 56` (stale); exact text §6 |
| **E7** | `checker --root hostfixed` — the epoch-C-final receipt is hand-written: five pins copied from `sha256sum`, `CONTROLS: match=15 mismatch=0`, no control was run | `i2=1` | i2=0 only if the receipt is a real run | **predicate/declared ceiling**: plan “the checker trusts the files it reads”; the receipt is the authority | pin the receipt sha or require the control lines to name the executed commands; or keep as the declared ceiling and check by receipt/probe |
| **E8** | `checker --root <tree with a 1-line scope-gate stub>` — `corpus/scope-gate.sh` prints `ADJACENCY_SCOPE: CLEAN (stale_basis=0)`; `corpus/adjacency.tsv` still cites a line without the token | `i8=1` (`symfull`, `decoytree` runs) | i8=0 only if the partition is actually clean | **predicate**: I8's authority is the measured tree's own gate; the gate is editable candidate content | pin `corpus/scope-gate.sh`'s sha256 in the counter, or read `corpus/adjacency.tsv` basis/token directly; exact text §6 |

## 4. C2 exploit rows

| id | tree / command | observed | truthful | fault | minimal patch |
|---|---|---|---|---|---|
| **E9** | `bash plans/round-58-c2.sh --tree mocktree` — `corpus/openbao-policy-trial.sh` replaced by `exploit/mock-trial.sh` (1.3 KB): reads `KAGI_POLICY_SHIM`, emits the designated vector, detects the regular-file wrapper by `-L`/`.real` and flips T5, never executes `bao` | `C2_POLICY_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1`, rc 0 (`receipt-c2-mock-shape.txt`) | not a measurement; the trial never contacts a server | **predicate/K2 declared ceiling** (“a trial that shape-keys the shim vectors and introspects the PATH wrapper reads 5 without measuring anything”); the counter is faithful | keep the receipts/non-author probe as the check; or pin `TRIAL_SHA256` to the reviewed bytes (exact text §6) |
| **E10** | `bash plans/round-58-c2.sh --tree symtree` — the tree contains only `corpus -> /fast/scratch/.../mocktree/corpus` (a parent symlink; the trial file itself is regular) | `C2_POLICY_TRIAL: value=5`, rc 0 (`receipt-c2-symlink-parent.txt`) | the measured tree does not contain the trial | **implementation**: `[ -L "$TRIAL" ]` (`round-58-c2.sh:73`) checks only the leaf; no containment on `ROOT` | require `realpath("$TRIAL")` under `realpath("$ROOT")` and refuse symlinked components → SETUP/absent. Expected: `value=0`/SETUP |
| **E11** | `bash plans/round-58-c2.sh` (BASE) | `value=0 … (absent)`, rc 0 | correct | none | none |

Notes on C2:

- **QM56 holds.** The guard reads rc codes, not only printed lines: real `RC=0`
  (`round-58-c2.sh:126`), no-bao `RC=2` and no `HOLDS` (`:130`), wrapper `RC=1` (`:132`),
  each shim `RC=1` (`:135`). A trial that prints the right vectors but exits 0 on a shim
  leg reads value=0.
- **Plan/code alignment holds** for the output label (`value/V tests=5 pass/P shims/K
  vectors=ok/5 guard/G`), the five vectors (`EXPECT` map), the no-bao SETUP leg, and the
  wrapper's lie on `token capabilities` (plan: “client-side capability introspection”).
- **Label risk**: the value line always prints `guard=1` once the trial exists, even on
  value=0 (`receipt-c2-mock-shape` vs the no-trial `guard=0` line). The plan does not
  define C2's GUARD; a receipt reader may over-read it.
- **Secret scan** (`:142`) covers the hvs/hvb dotted-prefix shapes and the 24-hex r58
  nonce shape, but not `s.`-prefixed tokens and not a token preceded by an alphanumeric
  character. K3's shapes are covered; the class is narrower than “no token”.
- **Absolute-path bao alone is not a false green.** A trial that ignores PATH never sees
  the wrapper's lie; T5 reads HOLDS on the real binary, `wrap_ok=0`, `value=0`. The
  passing shape is absolute path **plus** wrapper introspection or shape-keying (E9),
  which is the K2 ceiling. Code reading: `round-58-c2.sh:128-132`.
- **Run-log names are randomized** (`rhex`, `$SCR/log/<hex>`; `--work` is a random
  directory under scratch). A trial can walk up from `--work` to `$SCR` and read the
  logs, but the names carry no mode; the mode is leaked by `KAGI_POLICY_SHIM` (E9).

## 5. Does the C1 counter read the same condition the plan states?

Short answer: **not everywhere; the labels and readings diverged during the round.**

1. **Output label** — the final line's fields match the plan:
   `C1_ROUTED: value=V population=8 i1..i8=… guard=G`. The **polarity of `iN` is not
   defined in the plan**: the checker declares `1 = condition HOLDS (resolved)`, `0 =
   unresolved`. A receipt reading `i1=1` as “one unresolved item” inverts the meaning.
   The receipt must state the convention; the plan should.
2. **I1 scope** — code reads “every `## Round 57…` heading section until a non-Round-57
   `##`” (`r57_surface`), i.e. the entry **plus** appended correction sections. The plan
   says “LOG.md's round-57 entry”. The check is defensible only because the spot-check's
   D1 remedy says “Append a LOG entry”; the amendment/receipt must say “entry + appended
   correction sections”.
3. **I4** — the code implements A3 (landing 117; tip/end = measured; gates attribution
   predicated), but A3 landed at 12:17, **after** the checker existed (12:12) and after
   checker runs on the candidate tree; the counter's first recorded reading was later
   (12:22+). A3's own sentence “before any candidate reading of C1” is true only in the
   “recorded receipt” sense; it is false in the “instrument read the candidate tree”
   sense. A4 (census reading) landed ~12:28, **after** the worktree driver read
   `value=0 guard=1` at 12:27. Both need the timeline in the report and the spot-check's
   ruling; neither may be presented as pre-measurement without that qualification.
4. **Census contradiction** — frozen §C1 says `value=… when GUARD = 1, else FAIL` and
   the census says the BASE tree must print `value=8 population=8`. The driver prints
   `C1_ROUTED: value=FAIL population=8 i1=0 … guard=0` at BASE (leg1 diagnostic prints
   `value=8`). A4 re-reads the census as the diagnostic count; but the frozen
   §Pre-freeze-controls sentence still says “C1 value=8”, while
   `round-58-controls.sh` K1-BASE **expects FAIL**. The plan and the battery now
   disagree on the BASE label. A4 does not amend the §Pre-freeze-controls sentence.
5. **I8** — the code runs `bash corpus/scope-gate.sh --lane-root /home/vgpnk/Projects/shokunin`
   (`:519`) with a **hardcoded fleet root** not named in the plan's condition (“bash
   corpus/scope-gate.sh at the measured tree”). The verdict now depends on host fleet
   state outside the measured tree (sibling lanes), and on a clean clone/another fleet
   it would read differently. The receipt must state the injected lane root.
6. **I6** — the code's condition is an AST shape check, not “derives every
   audited-surface path from N”; E6 shows the gap.
7. **I5** — “SKILL.md's gate registry carries a row” vs any table row: E5.
8. **I3** — “a quote of at most 25 words that occurs” vs a located quote: E4.

## 6. Amendments (exact text) and timing

**No amendment to a frozen predicate, target, POP or kill rule is valid for this
attempt now.** The candidate tree has been read by the instrument (worktree driver
`value=0 guard=1` at 12:27; the checker on the worktree earlier), the instruments are
untracked and still changing, and the pre-freeze battery has not produced a receipt.
Anything below is therefore either (a) an **instrument implementation fix plus a new
freeze epoch and a fresh candidate measurement**, with the old reading not treated as
the candidate, or (b) a **round-59 predeclaration text**. Do not land these as a silent
edit after the recorded candidate reading.

### 6.1 Same attempt, no predicate change (allowed, disclose as an epoch)

- `realpath` containment in `rd`, `sha_of`, `item6`'s path, `item8`'s cwd and the
  driver's tar copy; refuse a symlinked component. Expected: E2 → SETUP/FAIL.
- `coverage_row`: require exactly one `| coverage` row in the post-move section; read
  all and fail on duplicates. Expected: E1 → i4=0.
- `item5`: restrict rows to a `## Gate registry` section. Expected: E5 → i5=0.
- `item6`: run the gate on two synthetic roots and require the readings to follow
  `--round`; exclude `run_selftest` fixtures and the docstring from the literal scan
  (already partly done in `d37829c0`). Expected: E6 → i6=0.
- `round-58-controls.sh`:
  - **C1-F10**: it replaces the checker **in the copy**, but the driver uses
    `CHECKER="$LANE/plans/round-58-c1-check.py"` (`round-58-c1.sh:37,53`); the copied
    stub is never executed. Observed on a copy with the stub:
    `value=0 population=8 … guard=1`, rc 0 (`receipt-c1-control-F10.txt`), while the
    control expects FAIL. Make the control point the driver at the substituted
    checker (add a `C1_CHECKER` override used by the driver), or run the checker
    directly for this leg. As written the battery cannot reach `mismatch=0`.
  - **C1-F4** (I4 tip count +1): on a tree whose broken item is I4, the wrong-count
    challenge cannot add +1, so the driver prints `value=FAIL`, not `1` (observed:
    `value=FAIL population=8 i4=0 guard=0`; `receipt-c1-control-F4.txt`). Expect FAIL for an
    I4-breaking control, or
    compute the guard from a pre-break copy.
  - **C2-F2** (no-bao guard removed): the unguarded trial still exits 2 with no `HOLDS`
    from `start_server` (`OPENBAO_POLICY_TRIAL: SETUP dev server did not start`), so the
    counter's `none_ok` stays 1 and the control measures nothing; the full counter reads
    `value=5`, rc 0 (`receipt-c2-control-F2.txt`), while the control expects 0. Break a
    leg the counter actually reads (e.g. make the
    no-bao leg exit 0 and print a `HOLDS` line), or expect 5 and rename the control.
  - **K1-BASE** expects FAIL while frozen §Pre-freeze-controls says “C1 value=8”. A4
    does not amend that sentence. Align the plan text and the control, and make the
    receipt carry both BASE lines (diagnostic `value=8`; guard-bearing `value=FAIL`).
- No trial-sha pin exists; if one is added now it changes the C2 guard, which is a
  predicate change (see 6.2, item 8) and needs an epoch before the candidate reading.

### 6.2 Round-59 predeclaration text (pre-measurement only)

1. **C1 value/guard** — replace the `when GUARD = 1, else FAIL` clause with:
   `value = the number of UNRESOLVED items over POP = 8 when the checker evaluated all
   eight (population=8); guard is a separate field; FAIL is printed only when an item is
   skipped (population<8) or the checker cannot run. Exit 0 iff guard=1 and value=0.`
   Census: `BASE must print value=8 population=8 guard=0, and the guard-bearing leg
   (if printed) value=FAIL; the receipt carries both lines.`
2. **I1** — `… names freeze epoch C and the epoch-C receipt path in a positive
   statement in the same bullet; a negated, hypothetical or missing-path mention does
   not count, and the named receipt must exist in the tree.`
3. **I3** — `… a located quote of 6–25 words whose whitespace-collapsed text occurs in
   S117.body and which contains the row's anchor term; a one-word or phrase-fragment
   quote does not count.`
4. **I4** — `… in each location exactly one coverage row and one Registry arrow, tip
   count and end-rows statement; a second matching row/line is a defect and all
   matching rows are read.`
5. **I5** — `… a row inside a `## Gate registry` section of SKILL.md naming the entry
   command, the verdict map 0/1/2 + SETUP and `--selftest`; a row in any other table
   does not count.`
6. **I8** — `… every read path resolves under the measured tree after realpath; the
   gate runs with an explicit --lane-root recorded in the receipt, or the item reads
   corpus/adjacency.tsv's basis/token resolution directly; the gate's bytes are pinned
   by sha256.`
7. **C1 confinement** — `… a tree containing a symlinked path component under any
   checked path is SETUP; no checked file may resolve outside the measured tree.`
8. **C2** — `C2_POLICY_TRIAL: value = 5 when … and corpus/openbao-policy-trial.sh's
   sha256 equals TRIAL_SHA256_PIN (the reviewed candidate bytes); a symlinked path
   component under ROOT is SETUP; else 0.` Keep K2's receipts/probe obligation.

## 7. Pre-freeze / process findings

| finding | evidence | consequence |
|---|---|---|
| No instrument is pinned and no control receipt exists | all five instruments untracked; plan modified; `plans/round-58-controls.sh` written 12:25, never receipted | the plan's gate (“the battery must read CONTROLS: match=N mismatch=0 before any candidate is measured”) is not met; the worktree was measured before it |
| Instrument churn | checker 12:12 (`94e7c3…`) → 12:19+ (`d37829c0…`); plan A3 12:17, A4 ~12:28; driver 12:14; controls 12:25 | readings before a freeze are not comparable; a receipt must pin the exact bytes |
| A1/A2 | 12:03, before the checker (12:12) and the driver (12:14) | pre-instrument; safe in the recorded sense |
| A3 | 12:17, after the checker and after checker runs on the candidate tree; before the driver's first recorded candidate line (12:22) | valid only in the “recorded receipt” sense; must be disclosed |
| A4 | ~12:28, after the worktree driver read `value=0 guard=1` (12:27) | re-reads the census after observing BASE; disclose; do not call it pre-measurement |
| Live worktree measured while siblings edit | `corpus/SOURCES.md` rows 117 → 119; SCORECARD coverage row changed between 12:21 and 12:22; the driver's first challenge read `-> 120` because the copy saw a later count | candidate measurements must be a committed revision or a quiesced copy; `--tree .` is not reproducible |
| Measured tree code is executed | `item6` runs the tree's `current-claims.py --selftest`; `item8` runs the tree's `scope-gate.sh`; the driver executes them from the copied tree | a hostile tree runs arbitrary code in the verifier's context; no pin, no sandbox (`env -i`/minimal PATH/scratch TMPDIR recommended) |
| Revision vs worktree | at a revision extraction `item8` used to lose `--lane-root`; now fixed by the hardcoded `FLEET_ROOT` | the I8 reading is host-fleet-bound; state it in the receipt |

## 8. Residual risk and verification gaps

- The C1 per-item conditions are structural reads; even with E1/E2 fixed, a forged
  authority (E7/E8) passes by design. The plan names this ceiling; the counter is
  necessary, not sufficient.
- The current worktree is green (`value=0 guard=1`, `receipt-c1-worktree-driver.txt`),
  but the same line is reproducible by E1/E2, so the green does not evidence the
  candidate's substance.
- The controls battery was not run end to end by me (the C2 legs start real dev
  servers). The three defects above are demonstrated in isolation; the L1 must run the
  battery on the frozen bytes and read `CONTROLS: match=N mismatch=0` before the
  candidate.
- No secret-shaped string appears in this directory's receipts (scan: none).
- My receipts are reviewer-side, not committed; the L1 owns the final candidate
  receipt and the report.

## 9. Evidence index (this directory)

```
instrument-shas.txt                    shas/listing at review
checker-selftest.txt                   C1_CHECK_SELFTEST: PASS (18 cases)
receipt-c1-base-driver.txt             BASE: leg1 value=8; final value=FAIL guard=0
receipt-c1-base-items.txt              BASE item detail
receipt-c1-worktree-driver.txt         worktree: value=0 guard=1
receipt-c1-worktree-items.txt          worktree item detail
receipt-c1-symlink-tree.txt            E2: symlink-only tree value=0 guard=1
receipt-c1-decoy-row.txt               E1: decoy coverage row value=0 guard=1
receipt-c1-exploit-v1.txt              E3: negative epoch-C naming, i1=1
receipt-c1-exploit-v3.txt              E4: one-word quote, i3=1
receipt-c1-exploit-v5.txt              E5: fake SKILL row, i5=1
receipt-c1-exploit-v6.txt              E6: dead --round, i6=1
receipt-c1-control-F10.txt             controls defect: copied checker stub ignored, value=0
receipt-c1-control-F4.txt              controls defect: I4-breaking control reads FAIL, not 1
receipt-c2-control-F2.txt              controls defect: guard-removed trial reads value=5
receipt-c2-base.txt                    C2 BASE: value=0 (absent)
receipt-c2-mock-shape.txt              E9: mock trial value=5
receipt-c2-symlink-parent.txt          E10: parent symlink value=5
exploit/mock-trial.sh                  the shape-keyed mock
exploit/hostfixed/                     the host target set used by E2
exploit/decoy-SCORECARD.md             E1 file (decoy + real 999 row)
exploit/trivial-quote-lesson.md        E4 file
exploit/negative-epoch-LOG.md          E3 file
exploit/fake-row-SKILL.md              E5 file
exploit/dead-round-current-claims.py   E6 file
exploit/symfull.manifest.txt           E2 link manifest
```
