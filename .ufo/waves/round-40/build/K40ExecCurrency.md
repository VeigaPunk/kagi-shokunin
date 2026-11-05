# K40ExecCurrency — round 40 C2 freshness re-run at the candidate (read-only)

Candidate: `cb3f642479a09644a03874909bb7e44b52697a8d` (HEAD of lane `master`, confirmed with `git rev-parse HEAD`).
BASE: `6cc8850dfc5757927699e5a53a876f47c8df21aa`. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Working tree: no modifications under `corpus/` or `plans/` (`git status --short -- corpus/ plans/` empty).

## Result

C2 is **reproduced at the candidate**: the counter prints `3`, the anchor pins are CLEAN (pins=4), the census is CLEAN with the expected line, both capture hashes equal their registry rows, both quotes locate exactly in the committed bodies, and the SOURCES.md diff adds only the S095/S096 rows. No defect was found in the assigned checks.

## Executed steps (exact commands, exit codes, outputs)

1. `bash plans/round-40-c2.sh` (cwd lane root) — EXIT=0, stdout `3`. Receipt: `c2-counter.txt`.
2. `bash corpus/anchor-pins.sh` — EXIT=0, stdout `ANCHOR_PINS: CLEAN (pins=4)`. Receipt: `gate.txt`.
3. `bash corpus/sources-census.sh` — EXIT=0, stdout `SOURCES_CENSUS: CLEAN (rows=96 A=92 B=2 C=2 queued=1 mined=92 rejected=3 entries_sourced=14 legacy=21 captures=96 inrow=16 inrow_only=0 inrow_nonreproducing=12)`. Receipt: `census.txt`. Matches the expected line exactly.
4. `sha256sum .ufo/waves/round-40/capture/S095.body .ufo/waves/round-40/capture/S096.body`:
   - S095.body `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1` (257722 bytes)
   - S096.body `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5` (20100 bytes)
   - `awk -F'\t' '$1=="S095"||$1=="S096"{print $1"\t"$10}' corpus/source-fetches.tsv` →
     `S095 ef2d8abe…469b1` and `S096 570d72c3…bab5`. Both equal the file hashes. Receipt: `sha.txt`.
5. Quote locate (`quotes.py`, Python byte/regex search; receipt `quotes.py`, `quotes.txt`, `offsets.txt`):
   - S095 "Matches Unicode whitespace characters (as defined by": exact byte matches `[75897]`; whitespace-flexible regex match is unique and identical text. Character offset 75731 (UTF-8 decoding; 269 non-ASCII bytes precede it).
   - S096 "This function uses the rules defined by the HTML 5 standard": exact byte matches `[13521]`; whitespace-flexible regex match is unique and identical text. Character offset 13492 (45 non-ASCII bytes precede it).
   - `grep -boa` confirms the byte offsets 75897 and 13521 — the registry's citations are byte offsets and are correct as cited. The quotes are located, unaltered, inside the committed bodies. The quote sits in the raw HTML body; the match is not interrupted by markup.
6. `git diff 6cc8850dfc5757927699e5a53a876f47c8df21aa cb3f642479a09644a03874909bb7e44b52697a8d -- corpus/SOURCES.md` — EXIT=0.
   - `git diff --numstat` → `2	0	corpus/SOURCES.md` (2 insertions, 0 deletions).
   - `git diff -U0 ... | grep -c '^-[^-]'` → `0` removed lines.
   - Added lines are exactly the two rows `| S095 | re — Regular expression operations (Python 3.15.2 docs) …` and `| S096 | html — HyperText Markup Language support (Python 3.15.2 docs) …`.
   - S040 line (sha256 `24059a91…521262b`) and S041 line (sha256 `76ab74f6…a9efc`) are byte-identical base vs candidate (`grep -E '^\| S04[01] \|' | sha256sum`). Each appears once in both trees.
   - Receipt: `sources-diff.txt`.

## Defects

- None surviving in the assigned checks. No registry row, pin, capture, or quote mismatch was found.
- Observation only (not a defect, not counter-relevant): the two offsets cited in the S095/S096 rows are byte offsets; a character-indexed reader gets 75731/13492. A future reader should use bytes.
- Observation: the candidate tree has untracked files under `.ufo/waves/round-40/` written by other seats (build dispatch, `K40ScoutDocs.md`, `c1-at-candidate.txt`, `swarm-registry.json`, `controls/prefreeze-gate.txt`). These are not part of the candidate commit and were not read or modified by this seat.

## Tool installs

None. Used only the existing `bash`, `git`, `sha256sum`, `awk`, `grep`, and `python3`. Nothing installed or upgraded.

## Hygiene

- No git/jj mutation performed. Only `git rev-parse`, `git status`, `git show`, `git diff`, and `git diff --numstat`.
- No delegation, background jobs, commits, or pushes.
- Writes limited to `.ufo/waves/round-40/build/K40ExecCurrency/` (receipts: `c2-counter.txt`, `gate.txt`, `census.txt`, `sha.txt`, `quotes.txt`, `quotes.py`, `offsets.txt`, `sources-diff.txt`) and this report.
- Scratch `/fast/scratch/hyaku/kagi-r40/K40ExecCurrency/` created for `quotes.py`/offsets and deleted before finish (verified absent).

## Checks the main agent should run

None required from this seat. The C1 and C3 counters, the claim ledger, and the selftests are outside this assignment and are not re-run here.
