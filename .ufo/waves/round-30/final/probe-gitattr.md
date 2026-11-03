# Probe — does `.gitattributes` renormalize unexpected classes? (C2 mechanism)

Seat: `LProbeGitattr` · Lane: `kagi-shokunin` · Base: `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c`
(plan commit on frozen BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336`)
Scratch: `/fast/scratch/hyaku/kagi-r30/LProbeGitattr/` (removed on exit; receipts copied to
`.ufo/waves/round-30/final/probe-gitattr-artifacts/`)
`git --version` → **git version 2.56.0**
Toplevel assertion made before every mutation: `git rev-parse --show-toplevel` == the scratch
clone. No mutation ran in the lane or the fleet root. No tool installed.

Drafted attribute set had NOT been written to `.ufo/waves/round-30/final/c2/` (empty dir), so
the set in the assignment was used verbatim:

```
*.md    text eol=lf
*.tsv   text eol=lf
*.sh    text eol=lf
*.py    text eol=lf
*.json  text eol=lf
```

## 1. Changed-path list — exactly 4 (as predicted)

Sequence: clone → write `.gitattributes` → `git add -A` → commit → `tr -d '\r'` on the three
routed files → `git add -A` → commit. Total delta vs BASE:

```
A	.gitattributes
M	SKILL.md
M	corpus/SOURCES.md
M	corpus/claim-ledger.tsv
```

`git diff --stat BASE..NEW` → `4 files changed, 1096 insertions(+), 1091 deletions(-)`
(`.gitattributes` +5; SKILL.md 1626 lines; SOURCES.md 386; claim-ledger.tsv 170).

- **(a) `git status --porcelain` after commit → empty** (0 lines). No residual dirt.
- **(b) second worktree** (`git worktree add --detach` at the new commit) compared byte-for-byte
  against `git archive BASE | tar -x`:
  `diff -r --brief` reported **only** `.gitattributes` (A), `SKILL.md`, `corpus/SOURCES.md`,
  `corpus/claim-ledger.tsv` (M). All **4116** other tracked files byte-identical. No unexpected class.
- Also verified: **all 3 files are `i/crlf` in the index at BASE** — the CRLF was *committed*,
  not a working-tree-only artifact. A clone alone does not repair it; explicit normalization is
  required. After repair: `i/lf w/lf attr/text eol=lf` for all three.

### 1a. Hazard: `git add --renormalize .` is NOT equivalent — it touches 5 more files

Git does not renormalize on a plain `add`. If the integrator runs `--renormalize`, the drafted
`*.json` glob sweeps up five **round-29 receipt files** that hold CRLF in the index:

```
M .ufo/waves/round-29/final/c1-after.json       433 CR lines
M .ufo/waves/round-29/final/c1-before.json      437
M .ufo/waves/round-29/final/c2-after.json        94
M .ufo/waves/round-29/final/c2-base-gate.json   101
M .ufo/waves/round-29/final/c2-base-plain.json   56
```

Total delta becomes **9 paths, not 4**. Those are committed evidence receipts; rewriting their
bytes mutates round-29 proof artifacts. **Recommendation: plain `git add -A` (4 paths), never
`--renormalize`.** If `--renormalize` is used, `.ufo/waves/round-29/final/` must be excluded
first.

This is exactly the plan's stated kill-rule trigger ("if `.gitattributes` renormalizes unrelated
tracked files"). It fires only under `--renormalize`, not under the plain-add path.

## 2. Attribute rulings — (c) `git check-attr text eol`

```
SKILL.md:            text: set   eol: lf
corpus/stamps.tsv:   text: set   eol: lf
corpus/SOURCES.md:   text: set   eol: lf
```

Intended rulings confirmed. `corpus/stamps.tsv` is not modified (already LF, `i/lf`), and only
*receives* the attribute. Post-commit `git ls-files --eol` shows `attr/text eol=lf` on all four.

## 3. Mechanism verification

- **Recurrence prevention works.** Rewriting a committed-LF `SKILL.md` to CRLF in the working
  tree (813 lines converted, 74697→75510 bytes) produced `i/lf w/crlf attr/text eol=lf`,
  `git diff --quiet` = **CONTENT-IDENTICAL**, and `git add` staged **nothing**. Git strips the CR
  on the way into the index, so the drift **cannot be committed** any more — the C2 mechanism is
  sound. It does NOT clean the working tree: the file stays CRLF until re-checkout (`git checkout
  -- .`); the warning is `CRLF will be replaced by LF the next time Git touches it`.
- **The glob set is not over-broad in practice** at plain-add: 3384/3389 files matching the five
  globs are already `i/lf`; only the 5 round-29 json are latent mismatches. 48 matching files are
  `i/none` (binary-ish) and are correctly left alone.
- **`* text=auto` is destructive and must not be used.** With that wildcard, `--renormalize`
  rewrote **135 files** (70 `.headers`, 41 `.txt`, 12 `.hdr`, 5 `.json`, 2 `.md`, 2 `.html`,
  2 `.body`, 1 `.tsv`) → 136 changed paths vs BASE, and a fresh clone checked out **0** CR files.
  Those CRLF bytes are authentic HTTP protocol captures; converting them to LF corrupts the
  evidence. **Reject `* text=auto`.**

## 4. CRLF is the proven cause of E12 (supports C2 counter 1)

- Lane census at BASE: `sources-census.sh validate --root … kagi` → **exit 1, E12 ×52**
  (S001–S052), matching the committed START receipt.
- Code cause located in `scripts/sources-census.sh:581`:
  `function trim(s) { gsub(/^[ \t]+|[ \t]+$/,"",s); return s }` — strips spaces/tabs but **not
  `\r`**. `## Registry` is matched as `trim(substr(line,3))=="Registry"`; with CRLF the trimmed
  value is `"Registry\r"`, so `in_registry` never becomes true and every `| S0NN |` row is
  reported E12 "row outside Registry section".
- Minimal repro confirmed: identical input with `\r\n` → `match_Registry=0`; with `\n` → `1`.
- End-to-end: a copy with only `corpus/SOURCES.md` converted to LF →
  **census exit 0, E12 = 0** (warnings W04 ×14 remain, allowed by the claim).

## 5. Separability: C2 does not perturb C1 pins

`corpus/row-identity.sh` hashes for all 14 identity kinds are **byte-identical** before and after
normalization (stamps `94df9364…`, scorecard-rounds `92016a58…`, ledger-ids `917ef251…`,
revision-cases `75c82770…`, etc.). Normalizing CRLF is invisible to C1's identity machinery.

`python3 corpus/self-counts.py`: base = `POLICY (claims=62 stale=8 … policy=2 setup=1)`;
after = `POLICY (claims=62 stale=8 … policy=2 setup=0)`. Exactly **one SETUP cell clears**
(`KN-CHECKLIST-FALSIFY-FLOOR ledger:R15-05 exit=2`), and the 8 STALE cells are unchanged — C1's
work is untouched by C2. Counter 3 (`checklist-run.sh --ratio`) → exit 0,
`CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`, as claimed.

## 6. BLOCKER for the L1: the frozen counter-2 command cannot reach `0`

The plan's counter 2 is written without `.ufo` exclusion:

```
grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l
```

| tree | as written | `--exclude-dir=.ufo` |
|---|---|---|
| BASE | **135** | **3** |
| after the 4-path repair | **132** | **0** |

The plan states "before: 3 files". That number is only reproducible **with `--exclude-dir=.ufo`**.
As literally written the command reads 135/132, because 130 tracked files under `.ufo/waves/`
hold CRLF **in the index** (70 `.headers`, 40 `.txt`, 12 `.hdr` and the 5 json above) — authentic
protocol captures that must not be converted.

Consequence: the frozen counter can **never** print `0` without destroying capture evidence, so
C2 as frozen would fail its own counting command while the actual repair is correct and complete.
**Recommend the L1 amend counter 2 to add `--exclude-dir=.ufo`** (or scope to the five text
classes) and record the 3→0 old→new honestly, with the 132/135 figures stated as the
out-of-scope capture population. Do not convert the captures to make the literal command pass.

## Verdict

- **`.gitattributes` with the drafted per-class set renormalizes NOTHING unexpected under plain
  `git add -A`: exactly 4 paths, byte-exact, status clean.** The plan's kill-rule does not fire on
  this path.
- **It fires under `git add --renormalize .`** (5 extra round-29 `.json` receipts → 9 paths).
  Integrator must use plain add, or exclude `.ufo/waves/round-29/final/`.
- **Never use `* text=auto`** — 135 files/136 paths, destroys CRLF capture evidence.
- Mechanism is sound and drift can no longer be committed; it does not clean the working tree.
- C2 is separable from C1 (all identity hashes identical; one SETUP cell clears).
- **Counter 2 as frozen is unsatisfiable (132 ≠ 0). Must be scoped with `--exclude-dir=.ufo`
  (or to tracked text classes) before being used as an exit-0 gate.**
