# K42CriticClaims — pre-freeze attack on round-42 C1 (calibration) and C2 (freshness)

Scope: `plans/round-42.md`, `plans/round-42-c1.sh`, `plans/round-42-c2.sh`, `plans/round-42-controls.sh`, amendment A1 (`fdbb83d`), receipts under `.ufo/waves/round-42/controls/`. No lane edits. All work in `/fast/scratch/hyaku/kagi-r42/K42CriticClaims` (clone of `kagi-shokunin` detached at `98dd4de`; `git -C work rev-parse --show-toplevel` = `.../work`). Reference patches were applied to uncommitted sandbox clones (`refc1`, `refc2`); no commit was made. Scratch is deleted at yield; copies below.

Verdict key: DEFECT = survives local evidence; NOT-DEFECT = checked and holds.

## Measured readings (sandbox, clean clone of 98dd4de)

Command: `cd work && HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-42-controls.sh; echo rc=$?` → exit 0, 1.18 s:
```
CONTROL c1-blanket-refuse N=0
CONTROL c1-blanket-accept N=0
C1 BASE N=4
C2 derivation D=1
C2 BASE N=0
```
`diff -r` of the sandbox receipts against the committed ones: identical except `c2-base.txt` (see F-note N2).

## Findings

### N1 — NOT-DEFECT: C1 target is not reachable by do-nothing
`bash plans/round-42-c1.sh` at 98dd4de → `4` (target 5). Blanket-refuse `0`, blanket-accept `0`. Do-nothing cannot reach 5.

### N2 — NOT-DEFECT (hygiene noted): controls runner re-runs from a clean clone
Clean-clone run reproduces `4 / 0 / 0 / D=1 / 0`, rc 0. `c2-base.txt` in the sandbox is 18 lines, not 1: git prints a 17-line detached-HEAD note on stderr (`git clone` of a detached lane) and the runner captures stderr with `2>&1`. Tail reading is `0`, so the predicate holds; a byte-compare of receipts is not a valid check. Receipt: `receipt-controls-runner.txt`.

### N3 — NOT-DEFECT: amendment A1 keeps D and the BASE receipts
- `git show 5142b52:plans/round-41-c2.sh | sha256sum` = `98dd4de:plans/round-41-c2.sh` = `2e9f8de5…a72a42` (identical; `cmp` silent).
- Re-run derivation: `git archive 19025d9` → copy 5142b52 counter → `bash plans/round-41-c2.sh | tail -1` = `1` (= D).
- Worktree reading at 98dd4de: `bash plans/round-41-c2.sh | tail -1` = `3` (matches `c2-worktree-at-base.txt`).
- A1 protects D only. It does not protect the runner's R (F2).

### N4 — NOT-DEFECT: causal separability (C1 ↔ C2)
Reference C1 patch touches only `corpus/expect-journal.sh` (`reference-c1-deleted-rule.patch`, one file). Reference C2 patch touches only `plans/round-41-controls.sh` (`reference-c2-runner-archive.patch`, one file). C2's counter reads only the last line of the C2 receipt, so the C1 control lines in the runner do not feed C2.

### N5 — NOT-DEFECT: frontier census
`bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → rc 0, final line `kagi ok ...kagi-shokunin/corpus/SOURCES.md`, with W04 duplicate-URL warnings (not failures). `census` → `kagi rows 98; tier.A 94; tier.B 2; tier.C 2; status.mined 93; status.queued 1; status.rejected 4`, matching the plan. Receipt: `receipt-census-validate.txt`.

### N6 — NOT-DEFECT: C1 deletion rule does not refute landed history
Ledger ids across 40 ledger commits (`git log -- corpus/claim-ledger.tsv`): consecutive-commit `comm -23` of ids → no deletions in any step. `comm -23 ids-6cc8850 ids-6f1588c` and `comm -23 ids-5142b52 ids-e8265c0` → empty. Reference gate landing check `--base-ledger <5142b52> --ledger <candidate> --journals <round-41 journal dir>` → `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, rc 0. Selftest with reference patch → `EXPECT_JOURNAL_SELFTEST: PASS (cases=7)`.

### N7 — NOT-DEFECT: reference C1 deletion rule meets the frozen F5 token
Reference patch (`reference-c1-deleted-rule.patch`, 5 added lines: loop over `base_order`, `refuses.add(("DELETED", rid))` when absent from candidate). `EXPECT_JOURNAL=<refc1>/corpus/expect-journal.sh bash refc1/plans/round-42-c1.sh` → `5`, rc 0. Single-id deletion of `R17-02` from `work/corpus/claim-ledger.tsv` → `EXPECT_JOURNAL: REFUSE DELETED R17-02`, `REFUSED (violations=1)`, rc 1. Receipt: `receipt-reference-c1.txt`. Counter target is reachable by a one-rule change, so the plan's C1 target is attainable.

### F1 — DEFECT (C2, high): a no-op runner reads 1 from the committed round-41 receipt
Counter logic: `(cd clone && bash plans/round-41-controls.sh >/dev/null 2>&1)`, then `R=$(tail -1 "$RCPT")` with the rc ignored and the file not removed first. `c2-base-19025d9.txt` is tracked at `98dd4de` and reads `1`.
Command (clone of 98dd4de with runner replaced by `exit 0`):
```
$ printf '#!/usr/bin/env bash\nexit 0\n' > stale/plans/round-41-controls.sh && (cd stale && bash plans/round-41-controls.sh; echo runner-rc=$?)
runner-rc=0
$ tail -1 stale/.ufo/waves/round-41/controls/c2-base-19025d9.txt
1
$ D = 1  →  counter prints 1
```
So the C2 target (1) is reachable by a do-nothing edit, which breaks the plan's "not reachable by do-nothing" premise. Kill rules (a)–(c) do not catch it: (a) passes (receipt is 1), (b) needs the runner to read the worktree (a `exit 0` runner does not), (c) is equal by construction. Fix (testable): the counter deletes `$RCPT` in the clone before running the runner, requires the runner's exit status 0, and requires the receipt's mtime/hash to differ from the committed one. Receipt: `receipt-stale-receipt-attack.txt`.

### F2 — DEFECT (C2, high): counter copy is taken from the lane, so a one-line edit to `plans/round-41-c2.sh` passes
A1 freezes D to `5142b52`. The runner's R line runs the lane's copy of `plans/round-41-c2.sh` (the frozen predicate: the runner copies "the counter from the lane"). Nothing compares that copy with `5142b52`.
Command (reference C2 runner, sandbox): replace lane `plans/round-41-c2.sh` with `printf '#!/usr/bin/env bash\necho 1\n'`, rerun `bash plans/round-41-controls.sh`, read the receipt tail → `1`. D = 1 → N = 1. Also: the committed file at `98dd4de` is byte-identical to `5142b52` (cmp), so a candidate must actually edit it; the plan does not forbid it.
Fix: the runner must take the C2 counter from `git show 5142b52:plans/round-41-c2.sh` (the same source as D), or the counter must `cmp` the copy against `5142b52` and print 0 on mismatch. Receipt: `receipt-tamper-attack.txt`.

### F3 — DEFECT (both, medium): frozen counters and runner are read from the candidate tree
Nothing in the kill rules pins `plans/round-42-c1.sh`, `plans/round-42-c2.sh`, `plans/round-42-controls.sh` to `98dd4de`. The C1 counter's last line is `echo "$n"`; a candidate that changes it to `echo 5` reads 5 at BASE. Verified only that the current files equal the committed ones (`git show 98dd4de:plans/round-42-c1.sh | cmp - plans/round-42-c1.sh` → identical). Fix: the L1 runs each counter from `git show 98dd4de:<path>`, and a kill rule `git diff --quiet 98dd4de HEAD -- plans/round-42-c1.sh plans/round-42-c2.sh plans/round-42-controls.sh` (or equivalent) is added.

### F4 — DEFECT (C1, medium): universal claim wording vs one-row counter
Header and §Improves: "an unjournaled ledger-row deletion is refused" (universal). Counter F5 deletes one row (`R17-02`). The ceiling line says "the F5 counter forges one row only", so the limit is disclosed, but the claim wording is not narrowed. Fix: reword the claim to "the deletion of `R17-02` is refused, and the rule is unconditional over ids" or add a second deletion fixture (a deleted row with its id journaled → `MISSING_ROW` is already refused; a deleted row with no journal → `DELETED`). Either is a plan edit that must land before the first candidate commit.

### F5 — DEFECT (C1 ceiling wording): self-contradictory sentence
Plan §C1 ceilings: "a deleted row with a journal entry whose id survives is refused by `MISSING_ROW`". A deleted row's id does not survive; the intended sentence is "a deleted row whose id has a journal entry is refused by `MISSING_ROW`". Fix: correct the sentence in the plan before freeze (the plan may take a correction only before the first candidate commit).

### F6 — DEFECT (C1 kill rule (c) untestable as written)
Kill (c): "the gate's own selftest does not pass with the F5 case added." No command or file names the case or who adds it. The reference patch adds no F5 case, and `bash corpus/expect-journal.sh --selftest` still prints `PASS (cases=7)`. Fix: name the selftest change (the selftest gains a case `f5` = P0 ledger minus `R17-02`, expects `REFUSE DELETED R17-02`, rc 1 → `cases=8`) and make `--selftest` the test command.

### F7 — DEFECT (frontier, sourced claim): S094 locator is wrong and the rule does not cover the ledger
- `corpus/SOURCES.md:101` (S094) cites "SOURCES.md Rules item 2, line 116". `corpus/SOURCES.md` has no Rules section. Re-opened the pinned `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md` (curl rc 0, 184 lines): rule 2 "Append-only" is at **CORPUS.md line 116** and is titled `CORPUS.md` rule 2.
- Its scope is registry rows: "Only `status`, `recheck` and `used-by` change in place … A correction is a new row". It does not mention the claim ledger. C1's "rests on the append-only rule" is an analogy, not a sourced rule.
- The in-lane rule that matches C1 is `corpus/QUALITY.md:73` (QM14): "expectation rewrites with no old/new record … silent deletion of stamp rows" are forbidden. Recommend: plan §C1 cites QM14 as the sourced rule and S094 as the registry analogy with the corrected locator "CORPUS.md rule 2, line 116 at f47ad6b".

### F8 — DEFECT (frontier obligation): "Mistake mined: M41-4 (below)" points to nothing
`grep -rhoE 'M41-[0-9]+'` over `corpus/`, `plans/`, `LOG.md`, `SCORECARD.md`, `.ufo/waves/round-41` → M41-1 ×8, M41-2 ×8, M41-3 ×8, M41-4 ×1 (the plan line 9 itself). `corpus/lessons/round-41.md:164–166` mines M41-1..M41-3 only. Routed item 4 of `corpus/lessons/round-41-verifier-spotcheck.md:77` ("Row deletion … outside the frozen classes") is the source. Fix: add the M41-4 row to the round-42 lesson (fails red: C1 blanket-refuse reads 0, the fix must read 4→5) and remove "(below)" or point it to the row.

### F9 — DEFECT (C2 ceilings incomplete): F1 and F2 are not declared
Declared ceiling: "a runner that writes the constant 1 passes". Undeclared, both demonstrated above: stale committed receipt (F1) and tampered lane counter (F2). Fix: fix them (F1, F2) or declare them as named ceilings with the honest scope.

### F10 — DEFECT (wording, minor): "claim BASE" used for two commits
Plan header: claim BASE `e8265c0`. §C2 predicate: "a git archive of the claim BASE `19025d9`". Both are called "claim BASE". The `19025d9` reading is the round-41 receipt's name. Fix: write "the round-41 BASE `19025d9` (receipt name)". Also a stray token in §Routed: "Considerthese `2026-10-26.md`" (cosmetic).

### N8 — NOT-DEFECT (C1 blanket controls): both controls read 0; a blanket-refuse gate loses P0 and a blanket-accept gate loses every forgery. Receipts `c1-control-refuse-all.txt`, `c1-control-accept-all.txt`.

## Reference deliverables (implemented in sandbox, not committed)
- `reference-c1-deleted-rule.patch` — DELETED rule. Gate landing check CLEAN (6/6); selftest PASS (7); counter 5. Missing: F5 selftest case (F6).
- `reference-c2-runner-archive.patch` — C2 BASE line from `git archive 19025d9` with the lane's counter copied in. Runner output 1 (counter D 1). Still open to F2 (tamper) and F1 must be fixed in the counter.

## Receipts (this directory)
`receipt-controls-runner.txt`, `receipt-census-validate.txt`, `receipt-stale-receipt-attack.txt`, `receipt-tamper-attack.txt`, `receipt-reference-c1.txt`, `receipt-reference-c2.txt`, `reference-c1-deleted-rule.patch`, `reference-c2-runner-archive.patch`.

## Draft lesson rows (not written to the lane)
- M41-4 | a ledger row deletion passes CLEAN (routed round-41 item 4; no journal form) | `receipt-reference-c1.txt` | red reading 0 (blanket-refuse), BASE 4 | C1 `DELETED <ID>` rule.
- S094 locator: "CORPUS.md rule 2 (line 116, rev f47ad6b), registry rows only; claim-ledger rule = QM14 (`corpus/QUALITY.md:73`)".
