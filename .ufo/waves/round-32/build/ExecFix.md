# ExecFix — round-32 frontier/tombstone repair as a patch (R1, R6)

BASE: `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`. Lane tree never written; all editing happened in
`git clone --shared` fixtures under `/fast/scratch/hyaku/kagi-r32/ExecFix/`.

## Files written

| path | what |
|---|---|
| `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/fix/fix-frontier-readme.patch` | unified diff, 2 files, 2 hunks (1 insertion, 3 deletions); sha256 `9169419b2330dae7b716019ad576a9028caf079df627a1fb7cb0c587eb1a450a` |
| `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/fix/before-after.txt` | before/after text of both edited regions (BASE via `git show`, after via patched clone); sha256 `fa4415b6f6936d63e5b9c09a6a54e631cc70996fc9325817bd7abbc9a92cf9f8` |
| `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ExecFix.md` | this report |

## Patch content

`PROVINCE.md:90` (one line changed; Core bullets are context only, unchanged):

```
-- **Frontier — explored, not held:** OIDC workload-federation trust policy; secret-scanning detection vs verification; NIST key-management draft status (`corpus/README.md` §Frontier; leads in `corpus/SOURCES.md` §Leads (unopened)).
+- **Frontier — explored, not held:** NIST key-management draft status (`corpus/README.md` §Frontier; leads in `corpus/SOURCES.md` §Leads (unopened)).
```

`corpus/README.md:117-118` (two bullets deleted; the `## Frontier` heading, the observable-release-clock
bullet, the sentence "Areas being explored, not held as lane knowledge:" and the NIST bullet are untouched):

```
-- **OIDC workload-federation trust policy** — moved to core in round 31 (…).
-- **Secret scanning: detection versus verification** — moved to core in round 30 (…).
```

No other file appears in the diff (`grep -c '^diff --git'` → 2). The three Core bullets in PROVINCE.md
keep their full history text, including "The frontier bullet below keeps its history." and "the NIST leads
stay leads."; only the Frontier list content changed.

## Commands run (all absolute; exit codes as observed)

Fixture setup:

```
S=/fast/scratch/hyaku/kagi-r32/ExecFix
git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin $S/edit                     # exit 0
git -C $S/edit checkout --detach 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b                  # exit 0
git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin $S/base                     # exit 0
git -C $S/base checkout --detach 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b                  # exit 0
git -C $S/edit rev-parse --show-toplevel → /fast/scratch/hyaku/kagi-r32/ExecFix/edit       # exit 0
git -C $S/base rev-parse --show-toplevel → /fast/scratch/hyaku/kagi-r32/ExecFix/base       # exit 0
```

Patch generation (from the edit fixture; explicit prefixes because the lane sets mnemonic prefixes):

```
git -C $S/edit -c diff.mnemonicPrefix=false diff --no-color --src-prefix=a/ --dst-prefix=b/ > …/fix/fix-frontier-readme.patch   # exit 0
```

Verification on the pristine BASE fixture (`$S/base`):

| command | exit | result |
|---|---|---|
| `git -C $S/base apply --check …/fix/fix-frontier-readme.patch` | **0** | patch applies cleanly to BASE |
| `git -C $S/base apply …/fix/fix-frontier-readme.patch` | 0 | applied for measurement |
| `git -C $S/base status --porcelain` | 0 | `M PROVINCE.md`, `M corpus/README.md` only |
| `git -C $S/base diff --stat` | 0 | `PROVINCE.md \| 2 +-`, `corpus/README.md \| 2 --`, 1 insertion, 3 deletions |
| `grep -inE 'Frontier' PROVINCE.md \| grep -icE 'OIDC workload-federation\|secret[- ]scanning'` | 0 | **2** (see proxy note) |
| `grep -inE '^- \*\*Frontier' PROVINCE.md \| grep -icE 'OIDC workload-federation\|secret[- ]scanning'` | 1 (no match) | **0** |
| `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -c 'moved to core'` | 1 (no match) | **0** |

Faithful SD1 as defined in the frozen plan ("a theme named in a `Frontier` bullet that a `Core` bullet in
the same file also names"), computed over both revisions:

```
BASE    frontier_bullets=1 core_bullets=3 SD1_hits=2  [(OIDC workload-federation), (secret-scanning)]
PATCHED frontier_bullets=1 core_bullets=3 SD1_hits=0  []
```

## Proxy-command defect (reported, not edited)

My item's SD1 proxy `grep -inE 'Frontier' PROVINCE.md | grep -iE 'OIDC workload-federation|secret[- ]scanning'`
expects 0 but returns **2** on the patched copy — and **3 at BASE**. The two residual lines are the Core
bullets themselves (PROVINCE.md:88 "Moved from the frontier list… The frontier bullet below keeps its
history." and :89 "The round-21 frontier lead is discharged"), which match on the word "frontier" in prose,
not because they sit in a Frontier bullet. The command cannot reach 0 without deleting Core-bullet history,
which the acceptance rule forbids. I did not touch the predicate or counter; the bullet-scoped form above
(`^- \*\*Frontier`, giving 0) matches the plan's SD1 definition, and a full-line scan finds no Frontier
bullet naming either theme.

## Sweep script

`/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/sweep/self-description-sweep.sh`
did not exist when this seat finished (`ls` of `build/` → no `sweep/`; `find … -maxdepth 3 -name
self-description-sweep.sh` → empty). Per the item, the sweep run was **skipped**; the grep counts above are
the substitute measurement.

## Verdicts

- **R1** — patched: PROVINCE.md Frontier bullet names only NIST; faithful SD1 count 2 → 0. Core bullets byte-identical.
- **R6** — patched: both `moved to core` tombstones removed; SD2 count 2 → 0 in the `## Frontier` section.
- **Acceptance** — `git apply --check` exit 0 on BASE (recorded above); exactly 2 files in the diff; Core history retained.
- **Lane tree** — untouched (`git status --porcelain` at seat start: only `?? .ufo/waves/round-32/`). Lane HEAD `76241c0`;
  `git diff --stat 32c35fe HEAD -- PROVINCE.md corpus/README.md` is empty, so the patch's two targets are
  unchanged since BASE and it should apply at HEAD as well; applying it is the L1's call.

## Residual risks / notes

- Patch generated with `--src-prefix=a/ --dst-prefix=b/`; the lane repo sets mnemonic `i/`/`w/` prefixes, so
  regenerate with the same flags if the L1 rebuilds it from a worktree.
- The item's literal SD1 proxy is defective as described; any downstream receipt that runs it verbatim will
  read 2 on a correct tree.
- No tools installed or upgraded (no pacman; nothing else needed). No vault contact: no `op` invocation of any
  kind was needed for this seat and none was run. Read-only git only; no commit, add, stash, reset or jj call.
- Not run here (parent gate owns them): self-description sweep, linters, full suite.
