# LProbeGitattr — gitattributes probe (C2 mechanism falsification)

**Result: C2's mechanism is sound under plain `git add -A` (exactly 4 changed paths), but the
plan's frozen counter 2 is unsatisfiable as written.** Full evidence:
`.ufo/waves/round-30/final/probe-gitattr.md`; receipts in
`.ufo/waves/round-30/final/probe-gitattr-artifacts/`.

## Changed-path list — exactly 4 (prediction held)

```
A	.gitattributes
M	SKILL.md
M	corpus/SOURCES.md
M	corpus/claim-ledger.tsv
```

`diff --stat BASE..NEW` = 4 files, +1096/−1091. `git status --porcelain` after commit = empty.
Second worktree byte-compared to `git archive BASE`: only those 4 differ; **4116 others
identical**. All three routed files were `i/crlf` **in the index** at BASE → CRLF was committed,
so a clone alone does not repair it; explicit normalization is required (verified `i/lf` after).

## Attr rulings (c) — intended

`SKILL.md`, `corpus/stamps.tsv`, `corpus/SOURCES.md` → `text: set`, `eol: lf`. Post-commit
`ls-files --eol` = `i/lf w/lf attr/text eol=lf` on all four paths.

## git version

`git version 2.56.0`

## Two real hazards found

1. **`git add --renormalize .` ≠ plain add.** It additionally rewrites 5 round-29 **receipt**
   files holding CRLF in the index (`c1-after.json`, `c1-before.json`, `c2-after.json`,
   `c2-base-gate.json`, `c2-base-plain.json`; 433/437/94/101/56 CR lines) → **9 paths, not 4**.
   This *is* the plan's kill-rule trigger, but it fires only on the renormalize path. Use plain
   `git add -A`, or exclude `.ufo/waves/round-29/final/`.
2. **Never use `* text=auto`.** With that wildcard + `--renormalize`: 135 files rewritten
   (70 `.headers`, 41 `.txt`, 12 `.hdr`, …), 136 paths vs BASE, fresh clone checks out 0 CR —
   it destroys authentic CRLF protocol captures. Reject it.

## C2 counter 1 cause — proven, not assumed

E12 root cause is `scripts/sources-census.sh:581` `trim()` stripping only `[ \t]`, not `\r`:
`## Registry\r` never equals `"Registry"`, so `in_registry` stays false and every row is E12.
Minimal awk repro: CRLF → 0, LF → 1. End-to-end: LF-only `corpus/SOURCES.md` copy → census
**exit 0, E12 = 0** (W04 ×14 warnings remain, allowed). Lane at BASE: exit 1, E12 ×52 (S001–S052).

Counter 3 confirmed: `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`, exit 0.

## Separability — C2 does not touch C1

All 14 `corpus/row-identity.sh` hashes identical before/after normalization (stamps `94df9364…`,
scorecard-rounds `92016a58…`, ledger-ids `917ef251…`, revision-cases `75c82770…`, …).
`self-counts.py`: base `POLICY claims=62 stale=8 policy=2 setup=1` → after `setup=0`; exactly one
SETUP cell clears (`KN-CHECKLIST-FALSIFY-FLOOR ledger:R15-05`), 8 STALE cells unchanged.

## BLOCKER for L1 — counter 2 as frozen cannot reach 0

| tree | `grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj .` | + `--exclude-dir=.ufo` |
|---|---|---|
| BASE | 135 | **3** |
| after 4-path repair | 132 | **0** |

The plan's "before: 3" is only reproducible **with `--exclude-dir=.ufo`**. As written the command
reads 135/132 because 130 tracked `.ufo/waves/` files carry CRLF in the index — authentic capture
evidence that must not be converted. **Recommend amending counter 2 to
`grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj --exclude-dir=.ufo . | wc -l`**, recording
3→0 old→new and stating the 132/135 capture population as out of scope. Do not convert captures
to force the literal command green.

## Housekeeping

Scratch `/fast/scratch/hyaku/kagi-r30/LProbeGitattr/` removed on cleanup; receipts copied to the
wave dir first. Lane untouched (`git status` shows only pre-existing sibling wave artifacts; no
`.gitattributes` in the lane). No installs, no pacman, no credential/vault access, no lane git
mutation.
