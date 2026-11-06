# Round 47 — seat K47ExecC1 — C1 candidate material (calibration)

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE (claim tip): `252ef1cac9f41d84639c0d1f211d0e0911196112`. Predeclaration: `b020d978bac91284a431710148ebb7a7950eaab8`.
Seat scope: build the C1 candidate material in scratch only; the lane tree was **not** edited (the only
lane paths written are `.ufo/waves/round-47/build/K47ExecC1*`).

## Result

C1 at the candidate — measured, not projected:

```
C1_CENSUS_CALIBRATION: value=3 cleared=3 new=0 intact=1 bound=1 (census=SOURCES_CENSUS: CLEAN (rows=102 A=98 B=2 C=2 queued=1 mined=97 rejected=4 entries_sourced=15 legacy=21 captures=102 inrow=16 inrow_only=0 inrow_nonreproducing=12); why=)
```
rc=0. Target 3.

Census of the candidate tree, verbatim last line (rc=0):
```
SOURCES_CENSUS: CLEAN (rows=102 A=98 B=2 C=2 queued=1 mined=97 rejected=4 entries_sourced=15 legacy=21 captures=102 inrow=16 inrow_only=0 inrow_nonreproducing=12)
```
BASE through the same counter (`252ef1ca`): `value=0 cleared=0 new=0 intact=1 bound=0` — the do-nothing
control still reads 0.

## The three additions (exact material in this directory)

1. `corpus/lessons/round-43.md` — one `source:` line naming **S094** (+ one blank line), inserted as the
   file's first two lines. Exact bytes: `K47ExecC1/round-43.append.txt` (207 B).
2. `corpus/lessons/round-44.md` — one `source:` line naming **S099** (+ one blank line), same position.
   Exact bytes: `K47ExecC1/round-44.append.txt` (353 B).
3. `corpus/source-fetches.tsv` — one 16-column **S099** row appended (673 B):
   `K47ExecC1/S099.fetch-row.tsv`; plus the committed capture
   `.ufo/waves/round-47/capture/S099.body` (`K47ExecC1/S099.body`, sha256
   `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`, 97077 B).

Registry untouched: `INTACT=1` (all 102 BASE rows, same statuses) and the S094/S099 `used-by` sets were
not narrowed — the fix is the lessons citing the ids, not the registry forgetting them.

### Why the `source:` lines are the files' first lines, not the last

`corpus/lessons/round-39.md` line 1 (the model named in the assignment) and `corpus/lessons/round-42.md`
line 1 both carry the `source:` field above the H1. `corpus/lessons/round-44.md` has **no trailing
newline** (last byte `.`, verified on both the working file and the `b020d978` blob), so an EOF append
necessarily rewrites that last line: `git diff` then emits a `-` line, which fires C1's frozen kill rule
("only appended lines are allowed: `git diff BASE candidate` of those two files shows no `-` line").
Measured in a probe fixture (`a\nb` → `a\nb\nsource: X\n`): the diff contains `-b`
(`\ No newline at end of file`). Prepending gives a pure `+` diff. Measured on the candidate:
`git diff --no-index --unified=0 base/<f> tree/<f> | grep -cE '^-[^-]'` → **0** for
`round-43.md`, `round-44.md` and `source-fetches.tsv`. (For `round-43.md` alone an EOF append would also
be kill-safe; the line-1 form is used for both lessons for uniformity with r39/r42.)

## S099 live leg (independent fetch, 2026-11-06)

- command: `curl -fsSL --compressed -o S099.body -w '%{http_code} %{url_effective}\n' https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md`
- rc=0, `200 https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md`
- fetched_at `2026-11-06T19:34:00Z`; sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`; **97077 bytes**
- fleet blob `75dd2612:.ufo/prompts/kagi-round-44.md` (`git show … | sha256sum`, `| wc -c`):
  same sha256, same 97077 bytes — the served body is the committed blob.
- quote `The claim is judged on the counter, kill rule and predicate declared before data. A rule`:
  **byte offset 52924**, **line 561** (line-start byte 52919), **1 occurrence** — reproduces the S099
  registry anchor ("line 561 (byte offset 52924)") exactly, so the registry `anchor` cell needs no edit.
- provenance row column 3 (row identity, `sha256("S099\tmined\t<url>\n")`):
  `28481f3e91f371c9e8e3174922f4f27a204243e9ac05dba2a3fcf43c45b4bb42`; the same method reproduces
  S094's committed column 3 (`2b8fec43…7ea7`) as a control. Columns 4 and 5 are the registry URL,
  column 12 the 40-hex fleet commit, columns 14/15 `raw-literal-v1`/`-` (as the S094 row), column 16
  `§6 item 9, line 561 (byte offset 52924)`.

## Controls measured this seat (beyond the pre-freeze 17)

| probe | value | line |
|---|---|---|
| BASE `252ef1ca` through the counter | 0 | `cleared=0 new=0 intact=1 bound=0` |
| P1: base + provenance row + capture only | 1 | `findings=2` left (both `SC_USEDBY_NOCITE`) |
| P2: base + both lesson `source:` lines only | 0 | `cleared=2 new=0 intact=1 bound=0`, `s099-rows=0` |
| candidate (all three) | 3 | census `CLEAN` |

P1/P2 show each finding is closed by its own material and that `value` is not reachable by a shortcut;
the `CLEAN` verdict also proves `NEW=0` independently of the counter's three-finding filter.

Other gates run on the candidate tree: `bash corpus/sources-census.sh --selftest` → rc=0,
`SOURCES_CENSUS_SELFTEST: PASS (70 cases)`; `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh
validate --file <tree>/corpus/SOURCES.md` → rc=0, last line `file	ok	…/corpus/SOURCES.md` (three
pre-existing W04 duplicate-URL warnings on S089/S090/S091, warnings do not change status).

Scope: `diff -r --brief base tree` lists exactly the three files plus the new
`.ufo/waves/round-47/capture` directory in a 6732-file tree.

## Material round-trip

`K47ExecC1/reproduce.sh <scratch>` rebuilds the candidate from `b020d978` plus this directory's four
artefacts and runs the counter: it printed the same `value=3` line, and `diff -r --brief` against the
measured tree returned rc=0 (byte-identical). The L1 can therefore take the material, not the tree.

## What the L1 must do to land it

Apply the three additions to the lane worktree exactly as `reproduce.sh` does (prepend the two
append files, append the row, copy the capture), then measure `bash plans/round-47-c1.sh <candidate>`.
No registry cell, no `corpus/knowledge/` file, no instrument and no counter changes are involved.

## Risks / ceilings

- **Named ceiling, unchanged:** the counter reads the census output, the registry cells and the fleet
  blob; it does not judge whether S094/S099 are the right sources. That judgement is the lesson's.
- The `source:` line is prose; the census only requires the id token. The lines above name the registry
  row, the fleet commit, the sha256 and the capture, so a later round can re-verify them.
- `corpus/lessons/round-44.md` has no EOF newline at BASE; whoever lands this must not "tidy" that.
- Two upstream files were only read: `plans/round-47-c1.sh` and `corpus/sources-census.sh`. No tool was
  installed or upgraded this seat.

## Files handed over

`.ufo/waves/round-47/build/K47ExecC1/`: `round-43.append.txt`, `round-44.append.txt`,
`S099.fetch-row.tsv`, `S099.body`, `reproduce.sh`, `receipts.txt` (every command with rc and last line).
