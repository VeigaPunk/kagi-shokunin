# R57ExecGate — seat report (C1 draft gate `corpus/current-claims.py`)

Seat: R57ExecGate (executor, C1 lane) · round 57 attempt 1, wave w1 · 2026-11-07.
Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, claim BASE
`1cda9e7ae4767b4133e283bfbc08266d4c86362d` — verified ancestor of lane HEAD
`7aa1f4726e1f6bcdc8411d1a8b21828d49785173` (`git merge-base --is-ancestor`, rc0;
HEAD is the frozen predeclaration commit).

## Deliverable

`.ufo/waves/round-57/w1/R57ExecGate.d/corpus/current-claims.py`
sha256 `40ec0c644904f7374bc47bcb6ed3f669789c15f14e6d1243818e99ab2cae26df`, 22604 bytes.
Port of frozen `plans/round-57-c1-check.py` (same four statement classes, same
authorities, same population/mismatch/unbound accounting, same floor, same
printed lines and exit codes) plus a real `--selftest`. No production file
written or edited; no frozen instrument touched.

Tools observed: python3 3.14.8, git 2.56.0 (Arch x64). No package installed or
updated (none needed; no pacman transaction attempted).

Frozen instrument hashes observed unchanged during this seat:

```
5773c1a423d16ecabe31535afa45c022ae5de27656a5cdd4d5415428102b84c2  plans/round-57.md
3104b06f5bfaef77745bd0e5726d4e3ac86c471ff61eef2cc298ad21fee90601  plans/round-57-c1.sh
3de6b4dec570594b7ff47971156b9eb9f932a50a2261ba568b51314e906439a9  plans/round-57-c2.sh
6796ae7040b4956d28b9c71772c24c9ba0d4298e21e86f9f13dbff38e693ce41  plans/round-57-controls.sh
19d75337ce37259b08eaa8b960eedddac68bec70ed4eab3f55f9d621e142f72c  plans/round-57-c1-check.py
```

## Evidence (commands, rc, ids)

Scratch `/fast/scratch/hyaku/kagi-r57/R57ExecGate/` (deleted after evidence
capture; BASE tree materialized read-only via
`git -C <lane> archive 1cda9e7… | tar -x -C scratch/base`).

1. **Selftest** — `python3 -I -B <draft> --selftest` →
   `CURRENT_CLAIMS_SELFTEST: PASS (10 cases)`, rc0. Ten isolated synthetic
   roots, each its own `tempfile.mkdtemp` under the system temp dir (never the
   measured tree, never the lane), removed in `finally`:
   clean-root-zero · cases-mismatch · epochs-mismatch · missing-surface ·
   population-floor · receipt-tamper · pop-fraction-bound ·
   nearest-epoch-pairing · unbound-ambiguous · verbose-names-every-stmt.
   Each case drives the real CLI as a subprocess and asserts rc + final line +
   `--verbose` STMT lines; synthetic surfaces also carry out-of-surface
   `## Round 55 …` sections whose numeric statements must not enter the
   population.

2. **BASE reading, port vs frozen checker equal** — on the BASE tree:
   - frozen: `CURRENT_CLAIMS: value=3 population=16 mismatches=3 unbound=0
     cases=3 match=7 epochs=2 clocks=2 pop=2 guard=1`, rc1
   - draft: byte-identical final line, rc1
   - `bash plans/round-57-c1.sh --tree <scratch>/base` →
     `C1_CURRENT: value=3 population=16 gate=0 guard=1`, rc0.
   Counter value/population **3/16** = frozen checker = draft = plan BASE 3
   with population ≥ 8 (floor met).

3. **The three counted BASE statements** (`--verbose`, non-OK lines only):

   ```
   STMT SCORECARD:7 cls=cases stated=18 auth=20 via=recheck-replay-selftest MISMATCH
   STMT LOG:1 cls=epochs stated=4 auth=6 via=receipt-file-count MISMATCH
   STMT LESSON:9 cls=epochs stated=3 auth=6 via=receipt-file-count MISMATCH
   ```

   Exactly the plan's motivating evidence (18→20 cases; four→six epochs; Three→Six).

4. **Counter cross-check accepts the port (K1-REF shape)** — BASE tree with the
   draft copied to `corpus/current-claims.py`:
   `C1_CURRENT: value=3 population=16 gate=1 guard=1`, rc0 (gate=1 ⇔ the frozen
   counter read the same value/population from the port as from its own checker).

5. **Live-lane reading** (worktree already carries L1's in-flight repairs —
   `git status --porcelain`: `M LOG.md`, `M SCORECARD.md`,
   `M corpus/lessons/round-56.md`, untracked `corpus/current-claims.py`; none of
   these are my writes): `bash plans/round-57-c1.sh --tree <lane>` →
   `C1_CURRENT: value=0 population=16 gate=1 guard=1`, rc0.

## Diff table: port vs frozen checker

Full unified diff: 6 hunks, 379 lines (`diff -u plans/round-57-c1-check.py <draft>`).

| # | Location (frozen ln) | Change | Kind | Behavior-affecting |
|---|----------------------|--------|------|--------------------|
| 1 | 2–8 | module docstring header + usage lines rewritten for the landing path and `--selftest` | doc | no |
| 2 | 22–23, 33–37 | docstring EPOCHS authority sentence now states the code's actual authority (distinct `epoch-[A-F]` tokens of `plans/round-56.md`); final-line fields `pop=`/`guard=` named; SETUP wording | doc — corrects a stale frozen-docstring sentence (see observation) | no |
| 3 | 43–46 | `+ import shutil`, `+ import tempfile` | selftest support | no |
| 4 | 167–171 | argparse `+ --selftest` flag + early `return selftest()` | new flag | no — without the flag the executed path is identical |
| 5 | after 253 | + 305 lines: synthetic-root builder (`RECEIPT_MATCHES`, surface constants, `put`/`sub`/`synth`/`cli`/`fld`/`expect`), ten `case_*` functions, `SELFTEST_CASES`, `selftest()` | addition | no |
| — | 48–164, 172–253 | measurement core untouched: `WORDNUM`, `die`, `section`, `read`, `lesson_surface`, `selftest_cases`, `receipt_match`, `epoch_declared`, `manifest_rows`, all seven regexes, surface extraction, per-line class scan, `stmt()`, guard/value computation, final print, exit codes | unchanged | n/a |

**Behaviour-affecting differences: none.** With `--root`/`--verbose` the
measurement core is line-for-line the frozen checker's; confirmed by the
identical final line + rc on the same BASE tree and by the frozen counter's
gate=1 acceptance of the port's reading.

**Observation for L1 (frozen file NOT amended by this seat):** the frozen
module docstring's EPOCHS sentence — "the number of
`.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt` files" — does not
match the frozen code (`epoch_declared` counts distinct `epoch-[A-F]` tokens in
`plans/round-56.md`) nor the frozen plan §C1 POP ("the distinct `epoch-[A-F]`
tokens declared in `plans/round-56.md`"). Doc-only divergence inside the frozen
instrument; code and plan agree. The port's docstring states the code-true
authority.

## Bounds

Writes: this report, `.ufo/waves/round-57/w1/R57ExecGate.d/corpus/current-claims.py`,
scratch under `/fast/scratch/hyaku/kagi-r57/R57ExecGate/` only. Git in the lane
read-only. No subagent/task dispatch, no production edit, no secret touched.
Scratch deleted before yield (evidence preserved in this report; the draft and
its diff remain under the seat's `.d/` dir and here).

## Risks / blockers

None known. Note for integrators: `--selftest` subprocess-invokes itself via
`[sys.executable, -I, -B, abspath(__file__), --root …]`, so the file must exist
on disk where it runs (true for the landing copy and the `.d/` draft).
