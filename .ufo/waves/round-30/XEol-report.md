# XEol — C2 pre-integration (routed D5 LF→CRLF drift)

Seat: executor, round-30 BUILD wave, lane `kagi-shokunin`.
BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336`; lane HEAD at read time
`b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (plan commit, BASE's child).
All experiments in `/fast/scratch/hyaku/kagi-r30/XEol/`; production files untouched.
Receipts: `.ufo/waves/round-30/final/c2/` (22 files, `c2-01`…`c2-22`).

## Verdict

The EOL hypothesis holds, and the repair is fully proven in scratch: stripping CR
from the three named files takes the fleet census from **exit 1 / E12 ×52** to
**exit 0** (14 × W04 warning only) and the checklist gate from **SETUP exit 2** to
**exit 0** with exactly `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`.

Two contract-level defects found, both measured, both affecting C2's wording
rather than its mechanism. **Flagged for the L1 before it integrates:**

1. **Frozen counter 2 cannot reach 0.** The literal command
   `grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l` reads **167**
   in the working tree and **135** in a clean `git archive` of BASE — not 3. After
   stripping the three files it reads **132**, because 132 tracked `.ufo` files
   legitimately carry CR (127 HTTP wire captures whose CRLF *is* the captured
   byte, plus the 5 round-29 receipt JSONs). Reaching 0 requires normalizing
   evidence captures, which harms the evidence axis. The scoped form
   (`--exclude-dir=.ufo`) is **3 before → 0 after**. Details: `c2-21-counter-defect.md`.
2. **R30-01 cannot be the plan's pipeline row.** `claim-ledger.sh` refuses `|`
   and `$` (`META_RE='[;&|<>$`]'`) and refuses `!` as a first token; three
   candidate row forms all came back `POLICY … reason=metachar`. The row must
   delegate to a script, as the lane's existing gates do. Draft:
   `c2-18-eol-gate-draft.sh`, tested able to fail and able to pass through the
   real ledger runner.

Bonus finding worth more than the claimed surface: the same SKILL.md CR repair
also clears **R11-08** (`citations BROKEN unresolved=19 → CLEAN unresolved=0`).
The plan routed R11-08 to integration triage; it is EOL-caused, and the fix is
already inside C2's delta.

## 1. CR inventory

Tracked at BASE (`git grep -Il $'\r' f67232c`): **135 files**, of which
**3 are authored** and **132 are under `.ufo/`**.

Authored (all three fully converted — every line carries CR):

| path | lines | CR lines |
|---|---|---|
| `SKILL.md` | 813 | 813 |
| `corpus/SOURCES.md` | 193 | 193 |
| `corpus/claim-ledger.tsv` | 85 | 85 |

`.ufo/` (132) — classified, not drift:

- **127 wire captures** (`*.headers`, `*.hdr`, `*.txt`, `*.body`, `*.html`).
  First bytes of one: `HTTP/2 200 \r\n date: Wed, 21 Oct 2026 …`. The CRLF is the
  recorded wire byte; normalizing destroys the evidence.
- **5 round-29 receipt JSONs** — `.ufo/waves/round-29/final/{c1-after,c1-before,c2-after,c2-base-gate,c2-base-plain}.json`,
  CR on every line (433/433 … 101/101). Also Windows-host artifacts, but
  committed evidence of a prior round, outside this claim's delta.
- No `node_modules` files are *tracked* (`git ls-files | grep -c node_modules` = 0).

Working tree at HEAD exceeds the tracked set: **167** literal matches, of which
31 are untracked vendored CR files under
`.ufo/waves/round-28/retained-probes/SrcNodeSemver/node_modules/` (gitignored by
`.ufo/waves/round-28/.gitignore`) plus wave receipts. A gate counted over the raw
working tree is unstable across checkouts; the scoped form is stable at 0.

## 2. Stripped-tree receipts

Extraction: `git -C <lane> archive f67232c | tar -x -C $S/tree`; mirror root
`$S/mirror/kagi-shokunin` with the fleet `shokunin.conf` beside it.

Census (`scripts/sources-census.sh validate --root $S/mirror kagi`):

- before (unstripped mirror): **exit 1**, 52 lines, all `kagi <TAB> E12 <TAB> S0xx row outside Registry section`
- after (three files stripped): **exit 0**, 15 lines — 14 × `W04 … duplicate url … across scopes` + one `kagi ok …/corpus/SOURCES.md`

Checklist (`bash corpus/checklist-run.sh --ratio`, cwd = stripped tree root):

- before (raw BASE extract): **exit 2**, `SETUP no \`## Credential-hygiene checklist\` section with \`- [ ] \` items in …/SKILL.md`
- after: **exit 0**, `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` — exactly the plan's expected line.

Per-file attribution (`c2-20-attribution.txt`) — one file stripped at a time:

| stripped file | census | checklist | citations |
|---|---|---|---|
| `corpus/SOURCES.md` | E12 ×52 → 0 | unchanged (SETUP) | — |
| `SKILL.md` | unchanged | SETUP → CLEAN ratio | BROKEN 19 → CLEAN 0 |
| `corpus/claim-ledger.tsv` | unchanged | unchanged | — (stamp sha/bytes only) |

Full ledger after strip + re-stamp (`c2-16`, `c2-17`): `CLAIM_LEDGER: POLICY
(claims=67 policy=2 stamped=95)`, STALE 0, FAIL 13 → 11. Cleared by the EOL
repair alone: **R11-08, R15-05**. Remaining 11 (`R12-03 R13-01 R14-01 R21-02
R21-04 R22-03 R24-05 R24-06 R24-14 R24-15 R25-02`) are C1's calibration rows and
are untouched by C2 — the plan's causal-separability claim is confirmed, and it
is a *stronger* separation than stated, since two rows move.

`self-counts.py`: BASE `SELF_COUNTS: POLICY (… stale=8 … setup=1)` with
`SETUP KN-CHECKLIST-FALSIFY-FLOOR ledger:R15-05 exit=2 expected=0`; after repair
`setup=0`, the same 8 STALE cells byte-for-byte. Note for C1: the plan's round
context says "six STALE cells"; BASE measures **8** — the six routed cells plus
`RD-DOCS-ROWLINKED` and `RD-DOCS-ENTRIES` (the D4 pair). `c2-22-selfcounts-note.md`.

## 3. Normalization procedure (exact commands, order)

Full text: `c2-19-procedure.md`. Executive form:

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git rev-parse --show-toplevel                      # assert = lane root
sed -i 's/\r$//' SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv
# write .gitattributes (step 3 draft below)
git add .gitattributes
mapfile -t P < <(cut -f1 corpus/stamps.tsv)        # 94 pinned paths, read from the file
bash corpus/claim-ledger.sh stamp "${P[@]}" .gitattributes   # (+ corpus/eol-gate.sh once it exists)
```

Order matters, measured:

- **`sed` first is mandatory.** `.gitattributes` + `git add --renormalize` makes
  the *blob* LF but leaves the **worktree** at 813/193/85 CR lines while git
  reports clean; the gates read worktree bytes. `git checkout -- .` alone does
  **not** rewrite them (git believes the file is up to date) — deleting and
  re-checking out does, but `sed` is the direct operation.
- **`stamp` replaces the whole row set and refuses to shrink.** Every currently
  pinned path must be named in the same invocation. Verified: 94 paths →
  `STAMPED: n=94`; 94 + `.gitattributes` → `n=95`. Naming `corpus/stamps.tsv`
  itself is refused (`refusing to stamp the output file itself`).
- Only the three drifted rows change; the other 91 are byte-identical (diffed).
- Do the `stamp` **last**, after every content change of the round (C1 doc-cell
  edits, C3 SOURCES rows, new knowledge entries and `corpus/eol-gate.sh`), or
  those become STALE immediately.

## 4. `.gitattributes` draft

```
*.md text eol=lf
*.tsv text eol=lf
*.sh text eol=lf
*.py text eol=lf
*.json text eol=lf
.ufo/** -text -eol
```

Measured blast radius on BASE (`git add --renormalize .`, `c2-15`):

| variant | files changed |
|---|---|
| full five + no `.ufo` rule | **8** (3 drifted + 5 round-29 receipt JSONs) |
| `*.md *.tsv *.sh *.py` | **3** |
| full five + `.ufo/** -text -eol` | **3** |

So the plan's proposed five-line set, integrated verbatim, **fails the plan's own
kill-rule probe** (it renormalizes unrelated tracked files). Add the `.ufo` line
(the evidence tree never converts; `git diff` still renders normal hunks on
`-text` paths) or drop `*.json`. Recommended: keep `*.json` (authored JSON is
text) plus the `.ufo/** -text -eol` guard.

Recurrence check, simulated with `git -c core.autocrlf=true clone` on a synthetic
repo: without `eol=lf` a Windows checkout yields CRLF (2/2 lines); with it, LF
(0/2). The attribute is what stops D5 recurring; the gate row is the detector.

## 5. Gaps / what C2 does not do

- It does not fix EOL in the 132 `.ufo` files and should not: 127 are wire
  captures. If the L1 keeps the literal counter, the honest report is "132
  legitimate, 0 authored", not "0".
- It does not touch the 11 C1 rows, the 2 POLICY rows (`R29-01/02` first-token
  `python`), or the C3 SOURCES append. C1's stamp migration must be recomputed
  after C2's re-stamp, since `stamped=95` (and 96 if `corpus/eol-gate.sh` ships)
  is the post-C2 membership that `R12-03` and the `*STAMPS` doc cells must read.
- No tool was installed or upgraded; no pacman transaction attempted; `op` was
  not invoked at all. No vault/credential material read or written; no `op://`
  reference appears in any artifact here.
