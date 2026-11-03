# C2 normalization procedure (D5 LF→CRLF repair) — exact commands, order, evidence

Drafted by seat XEol against BASE `f67232c`; every step below was executed in
scratch and the stated after-state measured. The L1 is the sole integration writer.

## 0. Preconditions

- Lane clean at the fix commit except the C2 changes; nothing else staged.
- `git rev-parse --show-toplevel` prints the lane root (assert before mutating).
- No pacman, no op, no network. Nothing installed for this wave.

## 1. Normalize the three drifted files (bytes)

Ran from the lane root. `sed` is the byte operation; `eol=lf` alone does NOT
rewrite the worktree (proved: after `git add --renormalize .` + commit +
`git checkout -- .`, the worktree still held 813/193/85 CR lines while the blob
was LF — the gates read worktree bytes, so the sed is mandatory, not optional).

    cd /home/vgpnk/Projects/shokunin/kagi-shokunin
    sed -i 's/\r$//' SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv

Expected after: `grep -c $'\r'` = 0 for each of the three.

Attribution (measured per file, one file stripped at a time on BASE):

| file | gate it unblocks |
|---|---|
| `corpus/SOURCES.md` | fleet census E12 ×52 → 0 (exit 1 → 0) |
| `SKILL.md` | `checklist-run.sh --ratio` SETUP exit 2 → CHECKLIST_RATIO exit 0; **also** `claim-ledger.sh citations` BROKEN unresolved=19 → CLEAN unresolved=0 |
| `corpus/claim-ledger.tsv` | no gate flips on its own (stamp sha/bytes only) |

## 2. Add `.gitattributes` (recurrence prevention)

Write exactly (see `c2-14-gitattributes-draft.txt`):

    *.md text eol=lf
    *.tsv text eol=lf
    *.sh text eol=lf
    *.py text eol=lf
    *.json text eol=lf
    .ufo/** -text -eol

`.ufo/** -text -eol` is REQUIRED: without it `*.json text eol=lf` renormalizes
5 committed round-29 receipt JSONs (unrelated to the drift). Measured blast
radius: full5 → 8 files; full5 + `.ufo/** -text -eol` → 3 files (exactly the
drifted set). See `c2-15-gitattributes-blast-radius.txt`.

Do not use `* text=auto` or a bare `*` line — out of scope and unmeasured here.

## 3. Re-stamp (the three rows are STALE after step 1)

`stamp` REPLACES the row set and refuses to shrink it: every currently-pinned
path must be named in the same invocation. Read the pinned set from the file
itself so no path is hand-copied:

    cd /home/vgpnk/Projects/shokunin/kagi-shokunin
    mapfile -t P < <(cut -f1 corpus/stamps.tsv)
    bash corpus/claim-ledger.sh stamp "${P[@]}" .gitattributes

- `n` after = 94 (existing) + 1 (`.gitattributes`) = **95**.
- `corpus/stamps.tsv` itself must NOT be named; the command refuses it
  (`refusing to stamp the output file itself`), verified.
- If C3 or any other claim adds knowledge entries this round, their paths must
  be appended to the same invocation (one stamp call, no partial re-stamp).
- Expected: only the 3 drifted rows change sha/lines/bytes; the other 91 rows
  are byte-identical (verified by diff of the two stamps.tsv files).

## 4. Standing gate row R30-01

The plan's literal counter (`grep -rIl $'\r' … . | wc -l` prints 0) cannot be a
ledger row: `claim-ledger.sh` refuses `|` and `$` (`META_RE='[;&|<>$`]'`), and
refuses `!` as a first token. A pipeline row is POLICY `metachar` — proved with
three candidate rows. Use a delegate script (the established row form) and add
`corpus/eol-gate.sh` (draft at `c2-18-eol-gate-draft.sh`):

    R30-01  bash corpus/eol-gate.sh
            expect ^EOL_GATE: CLEAN \(cr_files=0\)$   exit 0   timeout 60

Draft script body:

    n=$(grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj --exclude-dir=.ufo . | wc -l)
    [[ $n -eq 0 ]] && { printf 'EOL_GATE: CLEAN (cr_files=0)\n'; exit 0; }
    printf 'EOL_GATE: DRIFT (cr_files=%d)\n' "$n"; exit 1

Proved able to fail: with one CRLF line reintroduced into SKILL.md it prints
`EOL_GATE: DRIFT (cr_files=1)` and exits 1.

## 5. Add to the stamp list

`corpus/eol-gate.sh` is new → include it in the same `stamp` invocation as
`.gitattributes` (step 3), so the final count becomes 96 if R30-01 ships.

## 6. Verify (the L1's own gates at the measured revision)

    /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
    bash corpus/checklist-run.sh --ratio
    bash corpus/claim-ledger.sh verify
    python3 corpus/self-counts.py
    grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj --exclude-dir=.ufo . | wc -l

## Measured end-state (scratch, fleet-shaped mirror, all steps applied)

- census: exit 0, 14 × W04 + ok (E12 52 → 0)
- checklist --ratio: exit 0, `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`
- claim-ledger verify: `CLAIM_LEDGER: POLICY (claims=67 policy=2 stamped=95)`,
  FAIL 13 → 11 (R11-08 and R15-05 cleared by the EOL repair alone), STALE 0
- self-counts: exit 2 `SELF_COUNTS: POLICY (claims=62 stale=8 … policy=2 setup=0)`
  — SETUP line gone (1 → 0); the 8 STALE cells are C1's to migrate, not C2's.
