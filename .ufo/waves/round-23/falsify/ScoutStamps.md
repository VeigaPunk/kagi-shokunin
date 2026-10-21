# ScoutStamps — round-23 stamp-membership falsification

Seat: `KagiR23.ScoutStamps` (read-only leaf). Measured **2026-10-21T03:56Z–04:00:15Z**.
Read revision: base `d218603b74099ddca0bd8f869516fc41db0979bf` (`git rev-parse HEAD`, exit 0)
plus the uncommitted round-23 working tree. No production edit, no host gate, no
claim-ledger `verify`, no install. Wrote only this report.

## What I attacked

1. `corpus/stamps.tsv` membership: row count, byte identity against the base stamp set,
   added/removed paths.
2. Every stamp row's `path sha256 lines bytes` tuple against the live tree, plus the
   base blob, to separate inherited staleness from round-23 drift.
3. The absent-file class (`MISSING` / `NOT-A-FILE`) and path-safety classes in the
   gate (`corpus/claim-ledger.sh:359`, `:387-391`).
4. The small hermetic fixture registry `corpus/fixtures/cells-hermetic/stamps.tsv` and
   the exact `R23-01` verdict line.

## Verdict

**Defect (freshness / provenance):** `corpus/stamps.tsv` was **not touched at all** in
round 23, while nine stamped artifacts changed and five new round-23 artifact paths
entered the tree unpinned. At base all 70 pins were exact; every one of the nine
mismatches is uncommitted round-23 drift. The plan's own integration line
(`plans/round-23.md:47-48`: "the two executable TSV snapshots (claim ledger,
stamps) are updated with old/new migration records per QM14") is false for stamps.

## 1. Membership — 70 rows, zero added, zero removed (confirmation)

```
$ awk -F'\t' '{n++} END{print "rows="n}' corpus/stamps.tsv
rows=70
$ awk -F'\t' 'NF==4 && $1!=""{n++} END{print "rows="n}' corpus/stamps.tsv
rows=70
$ git show d218603:corpus/stamps.tsv > /tmp/base-stamps.tsv        # exit 0
$ diff /tmp/base-stamps.tsv corpus/stamps.tsv; echo "diff_full_exit=$?"
diff_full_exit=0
$ git cat-file -p d218603:corpus/stamps.tsv | cmp - corpus/stamps.tsv; echo "cmp_exit=$?"
cmp_exit=0
$ sha256sum corpus/stamps.tsv
febcdf462d23a0df582f71470c93738fd9889ddb76fa4cce4084aed05281f08c  corpus/stamps.tsv
```

Added paths: **none**. Removed paths: **none**. The base and worktree registries are
byte-identical, so `R12-03` (`corpus/claim-ledger.tsv:28`) still sees the expected
count:

```
$ grep -c '[^[:space:]]' corpus/stamps.tsv
70          # expected ^70$ — passes
$ grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv
45          # expected ^45$ — passes
```

Membership hygiene, all clean: no duplicate path (`cut -f1 | sort | uniq -d` empty),
every row has exactly 4 tab fields, 70/70 paths resolve to tracked regular files
(`git ls-files --error-unmatch` per row, exit 0), 0 symlinks, 0 absolute or `..`
paths, 0 CR bytes.

## 2. Changed artifacts not re-stamped (defect)

The working tree has exactly nine modified tracked files (`git diff --name-only`,
exit 0; `count=9`) and **all nine are stamped, all nine are stale**. Generated with
the gate's own comparison formula (`sha256sum` + `wc -l` + `wc -c`,
`corpus/claim-ledger.sh:360-363`):

```
$ while IFS=$'\t' read -r p h l b; do ah=$(sha256sum "$p"|cut -d' ' -f1); \
    al=$(wc -l <"$p"|tr -d ' '); ab=$(wc -c <"$p"); \
    { [ "$ah" = "$h" ] && [ "$al" = "$l" ] && [ "$ab" = "$b" ]; } || \
    printf 'STALE %s sha=%s->%s lines=%s->%s bytes=%s->%s\n' "$p" \
      "${h:0:12}" "${ah:0:12}" "$l" "$al" "$b" "$ab"; done < corpus/stamps.tsv
```

```
STALE corpus/claim-ledger.sh sha=cf56f9ea75d5->c20c2d04a354 lines=1428->1428 bytes=88425->88480
STALE corpus/claim-ledger.tsv sha=e68069684363->6fa0c24fc696 lines=58->60 bytes=17844->19451
STALE corpus/knowledge/op-ref-consumption.md sha=4b89d3b91f41->76b46fb4df25 lines=384->385 bytes=25991->26095
STALE corpus/sources-census.sh sha=03fb300a7415->80966e208321 lines=450->613 bytes=25950->36022
STALE corpus/SOURCES.md sha=a5e1c13e95ba->06dde644801b lines=118->121 bytes=22843->24995
STALE corpus/surface-census.sh sha=275d8294a94e->1e697b017954 lines=886->887 bytes=44212->44220
STALE LOG.md sha=dfd9aa41b255->95808e54d09f lines=1178->1221 bytes=83259->85794
STALE SCORECARD.md sha=96cf354abf91->d3214edbd617 lines=822->862 bytes=96871->100130
STALE SKILL.md sha=00d6202f8b6d->dc5d9867a5f8 lines=742->742 bytes=64547->64547
```

Stamp-row line numbers in `corpus/stamps.tsv`: `claim-ledger.sh` :4,
`claim-ledger.tsv` :5, `op-ref-consumption.md` :29, `sources-census.sh` :60,
`SOURCES.md` :61, `surface-census.sh` :63, `LOG.md` :66, `SCORECARD.md` :68,
`SKILL.md` :70.

These are **not inherited debt**. For every row I hashed the committed base blob:

```
$ n=0; while IFS=$'\t' read -r p h l b; do bh=$(git show "d218603:$p" | sha256sum | cut -d' ' -f1); \
    if [ "$bh" != "$h" ]; then echo "BASE-STALE $p stamp=${h:0:12} base=${bh:0:12}"; n=$((n+1)); fi; \
    done < corpus/stamps.tsv; echo "base_stale=$n"
base_stale=0
```

All 70 pins matched `d218603` exactly; the nine mismatches are entirely the
uncommitted round-23 edit set. `corpus/stamps.tsv`'s mtime is
`2026-10-20 20:19:11 -0300`, before every round-23 artifact write
(`00:46–00:57 -0300` on 2026-10-21), so no re-stamp followed the edits.

Gate consequence, read not run: `stamp_cmp` returns 1 if **any** of the three
columns differs (`corpus/claim-ledger.sh:363`), `verify_stamps` prints those
`STALE` lines (`:383-385`), and the summary fails the run when `V_STALE > 0`
(`corpus/claim-ledger.sh:977`). A `CLAIM_LEDGER: CLEAN` statement cannot be true on
this tree; `verify` would instead print `CLAIM_LEDGER: FAIL (... stale=9 ...)`
and exit 1 (`:978-980`).

`SKILL.md` is the sharp case: sha changes while lines and bytes are identical
(`dc5d9867…`, 742/64547), i.e. same-size edit. A lines/bytes-only check would miss
it; the gate's three-column compare catches it. `corpus/sources-census.sh` is the
largest: +163 lines / +10,072 bytes, and it is the C2 implementation itself.

## 3. New round-23 artifacts outside the registry (defect)

`LOG.md:1201-1203` declares the new artifacts. None has a `stamps.tsv` row:

| path | measured now |
|---|---|
| `corpus/closure-dispositions.py` | 406 lines / 17085 bytes, sha `6cc822785d2b93c6…` |
| `corpus/closure-dispositions.json` | present, no row |
| `corpus/source-fetches.tsv` | 46 lines / 7731 bytes, sha `ccc9ae6ec1b4bfa2…` |
| `corpus/fixtures/cells-hermetic/` | 5 files (`find … -type f`, exit 0) |
| `corpus/lessons/round-23.md` | 170 lines / 12353 bytes, sha `d55209887c13825c…` |

This violates the stated contract, `corpus/README.md:65`: revision stamps cover
"every cited in-repo artifact". Each is cited in-repo:

- `corpus/claim-ledger.tsv:60` (`R23-02`) executes `python3
  corpus/closure-dispositions.py`; `corpus/claim-ledger.sh:92` and `:161`
  specifically allowlist that path for execution.
- `corpus/claim-ledger.tsv:59` (`R23-01`) names the fixture's `claims.tsv`,
  `stamps.tsv`, `SCORECARD.md`, and its `--root`.
- `corpus/SOURCES.md:30-32` (S024–S026) name `corpus/lessons/round-23.md` as
  used-by. Among all existing used-by paths in `SOURCES.md` (comma-split,
  em-dash excluded), it is the **only** one without a stamp row:
  `onepassword-machine-credentials.md`, `sops-age-key-rotation.md`,
  `vault-openbao-token-lease-lifecycle.md`, `round-22-source-errata.md` are all
  stamped.

Precedent is same-commit co-landing: round 22 added `corpus/feature-claims.json`
and `corpus/revision-audit.py` with their stamp rows in the same commit
(`git log -S'<path>' -- corpus/stamps.tsv` → `8ada17a`, both). QM5
(`corpus/QUALITY.md:43`) makes a lagging pin "a defect, not inherited debt"; QM14
(`:73`) requires old/new migration evidence for pin changes.

## 4. Absent-file attack (negative — confirmation)

`MISSING`/`NOT-A-FILE` is defined at `corpus/claim-ledger.sh:387-391` (with the
`-e` / `-L` / `-f` test at `:359`). Measured over all 70 rows: every path is an existing tracked regular file,
none a symlink; no row is absent or mis-typed. I could not produce a genuine
absent-file stamp. Fixture registry `corpus/fixtures/cells-hermetic/stamps.tsv`
(2 rows) also resolves exactly:

```
$ cd corpus/fixtures/cells-hermetic
$ while IFS=$'\t' read -r p h l b; do ah=$(sha256sum "$p"|cut -d' ' -f1); \
    al=$(wc -l <"$p"|tr -d ' '); ab=$(wc -c <"$p"); \
    printf '%s stamp=%s/%s/%s actual=%s/%s/%s %s\n' "$p" "${h:0:12}" "$l" "$b" \
      "${ah:0:12}" "$al" "$ab" "$([ "$ah" = "$h" ] && [ "$al" = "$l" ] \
      && [ "$ab" = "$b" ] && echo MATCH || echo MISMATCH)"; done < stamps.tsv
corpus/fx-ok.sh stamp=29f98fbaaa24/2/38 actual=29f98fbaaa24/2/38 MATCH
corpus/adjacency.tsv stamp=c17f7e17ff89/9/307 actual=c17f7e17ff89/9/307 MATCH
```

And the `R23-01` row reproduces byte-for-byte:

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --claims corpus/fixtures/cells-hermetic/claims.tsv \
    --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
    --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
    --docs corpus/fixtures/cells-hermetic/SCORECARD.md
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
exit=0   # exact-line grep count = 1
```

## 5. Bounds the closure claim must state

1. C1/C2/C3 are **artifact-existence and behavior** claims on a pre-integration
   tree. They must not imply revision-pin freshness: `stamps.tsv` is byte-identical
   to `d218603` and 9/70 pins are stale against the very tree that carries the
   round-23 artifacts.
2. Any `CLAIM_LEDGER: CLEAN` / `verify` verdict for this tree is unsupported; the
   stamp section would emit the nine `STALE` lines above and fail at
   `corpus/claim-ledger.sh:977`. QM12's substitute is per-row re-runs plus the
   stamp comparison, not an unrun `verify`.
3. `R12-03`'s `^70$` is a **count**, not coverage. It passes while zero round-23
   paths are covered and while every changed artifact is stale. It cannot be cited
   as evidence that provenance is current.
4. `plans/round-23.md:47-48` is unmet for stamps. The integration commit must
   either re-stamp all existing paths **plus** the new artifacts and journal the
   nine replaced triples (QM5/QM14, with old/new values), or the plan sentence must
   be corrected. A re-stamp that changes the row count must migrate `R12-03` with
   old/new evidence, not silently.
5. `LOG.md:1203`'s fixture count is wrong as written: it says "(4 files)";
   `find corpus/fixtures/cells-hermetic -type f` returns **5**
   (`claims.tsv`, `stamps.tsv`, `SCORECARD.md`, `corpus/adjacency.tsv`,
   `corpus/fx-ok.sh`). Minor, but it is a measured artifact-count claim.
6. C2's "provenance machine-checked" stops at the source captures; the artifact
   that performs the check (`sources-census.sh`) and the data it reads
   (`source-fetches.tsv`) are themselves unpinned/stale. Provenance of the
   provenance is not established by this round.

## 6. Remaining unknowns

- Whether L1 intends a post-wave re-stamp commit. The plan says yes; nothing in the
  tree does it, and the round-23 lesson/LOG record no stamp migration. If the final
  integration commit re-stamps, findings 2–3 become pre-integration debt, not a
  landed defect — but the claim as written on this tree is still false.
- Whether the five fixture files are intended to be registry members at all; the
  contract says "every cited in-repo artifact", but fixtures are a new artifact
  class with no precedent in `stamps.tsv`.
- `corpus/sources-census.sh` changed **during** this measurement (observed sha
  `4e60d5e0…` at ~03:57Z, `80966e20…` at 03:58–04:00Z, mtime
  `2026-10-21 00:57:55 -0300`); the staleness finding is invariant across both
  hashes, but any cited hash for that file must name its measurement instant.
- Not run (outside this seat / forbidden): `claim-ledger.sh verify`, any host-bound
  row, any `cells` run over the main `SCORECARD.md`.
