# K43ScribeDocs — round-43 lesson / SCORECARD / LOG / QUALITY drafts (scribe)

Seat: K43ScribeDocs (scribe). Scope: draft the round-43 lesson, the SCORECARD blocks, the LOG entry
and the QUALITY rows as text files for the L1 to integrate. Prose only; no lane tree edit, no
`corpus/` write, no `SCORECARD.md`/`LOG.md`/`QUALITY.md` edit, no registry row edit.

**Sandbox:** `/fast/scratch/hyaku/kagi-r43/K43ScribeDocs` (only the generator script lived there;
removed before yield). Every git call below names `-C` explicitly and every one is read-only
(`git show`, `git diff --numstat`, `git cat-file`, `git log`, `git branch --contains`).
No `git add/commit/stash/checkout/switch/reset/pull/push`, no mutating `jj` command, in the lane or
anywhere. No tooling installed or upgraded this seat (python3 + coreutils already present; the
pacman guard was not touched).

## Deliverables (the four files the L1 integrates)

| file | sha256 | bytes |
|---|---|---|
| `.ufo/waves/round-43/build/K43ScribeDocs/lesson-draft.md` | see `sha256sums.txt` in this deliverable dir | 18175 |
| `.ufo/waves/round-43/build/K43ScribeDocs/scorecard-block.md` | see `sha256sums.txt` | 7199 |
| `.ufo/waves/round-43/build/K43ScribeDocs/log-entry.md` | see `sha256sums.txt` | 4329 |
| `.ufo/waves/round-43/build/K43ScribeDocs/quality-rows.md` | see `sha256sums.txt` | 1210 |

Where each lands, per the assignment: `lesson-draft.md` → `corpus/lessons/round-43.md` (sections in
the mandated order: Claims, Gate, Mistakes, Frontier, Routed, considerthese, Assimilation, Adjacency);
`scorecard-block.md` → the two `## Round 43` blocks of `SCORECARD.md`; `log-entry.md` → one
`## Round 43 (2026-11-05)` entry of `LOG.md`; `quality-rows.md` → the `## Criteria from the
round-43 closures` table of `corpus/QUALITY.md` (rows QM46, QM47).

## How the frozen text was carried

Every frozen sentence — the three predicates, the three kill rules, the three ceiling lists, the
three no-work controls, amendment A1 and the seven §Routed items — was **extracted programmatically
from `plans/round-43.md` by line range**, not re-typed, so the lesson's verbatim blocks are
byte-identical to the plan. Verification (a script run over the written files) re-extracted each
block from the plan and asserted its presence in `lesson-draft.md`:

```
C1 predicate     verbatim-in-lesson: True
C1 kill          verbatim-in-lesson: True
C1 ceil          verbatim-in-lesson: True
C1 nowork        verbatim-in-lesson: True
C2 predicate     verbatim-in-lesson: True
C2 kill          verbatim-in-lesson: True
C2 ceil          verbatim-in-lesson: True
C2 nowork        verbatim-in-lesson: True
C3 predicate     verbatim-in-lesson: True
C3 kill          verbatim-in-lesson: True
C3 ceil          verbatim-in-lesson: True
C3 nowork        verbatim-in-lesson: True
A1               verbatim-in-lesson: True
routed block present: True
```

The A1 quote is the plan's own lines 218–223, so it carries the corrected landing form
(`5142b52` + the round-41 journal copy) and not the plan's wrong combined two-journal form.

## Values used (all measured at the claim BASE `5f3566c4cfe65a74da4d201d74d28b403929807b`)

Taken from the committed receipts under `.ufo/waves/round-43/controls/` (`measured-at.txt` = the
claim BASE; command `bash plans/round-43-controls.sh`):

- C1 old instrument: real 5 (`c1-old-real.txt`), K1 0, K3 0, fakeC 5, m3+K1 5, m5+K3 5, blankets 0/0.
- C1 new instrument: real 6 (`c1-new-real.txt`), K1 0, K3 0, fakeC 5, m3+K1 6, m5+K3 6, blankets 0/0.
- C2: base 0 (`c2-base.txt`), blanket-0 0, blanket-1 0.
- C3: base 0 (`c3-base.txt`), pos 1 (`c3-pos.txt`), blanket 4 (`c3-blanket.txt`).
- Census before: `kagi ok`, exit 0, 98 rows (19 W04 duplicate-url warnings); SOURCES row count 98.

Re-derived by this seat from the committed tree (read-only, exit codes below):

```
$ git -C <lane> show 5f3566c:plans/round-43-c1.sh
exit 128   # the C1 counter does not exist at the claim BASE (plan's c1-base absence)
$ git -C <lane> show 5f3566c:corpus/controls-replay.sh
exit 128   # no committed C2 gate at the claim BASE
$ for f in anchor-pins claims-declared prefreeze-control self-description-sweep surface-census; do
    git -C <lane> show 5f3566c:corpus/$f.sh | grep -c 'TMPDIR:-/tmp'; done
1 1 2 2 1   # leg (1) fails for every gate at BASE -> C3 reads 0
$ git -C <lane> show 5f3566c:corpus/claim-ledger.tsv | grep -c '^R[0-9]'
86
$ grep -c '^| S[0-9]' <lane>/corpus/SOURCES.md
98
```

M42-4 re-derivation (the numstat the round-42 report should have carried):

```
$ git -C <lane> diff --numstat e8265c0d90b01fcce0447d2f70615b0592ed145f d00a543 \
    -- corpus/expect-journal.sh plans/round-41-controls.sh
21	2	corpus/expect-journal.sh
6	1	plans/round-41-controls.sh
exit 0
```

against the fleet-root report sentence `/home/vgpnk/Projects/shokunin/.ufo/reports/round-42/kagi.md`
line 20 (item 6): "`corpus/expect-journal.sh`, +23/−3 lines; `plans/round-41-controls.sh`, +7/−1".

S094 re-open (over the scout seat's committed capture `.ufo/waves/round-43/build/K43ScoutS094/CORPUS-live.md`):

```
$ python3 -c "…read bytes, hash, locate quote…"
bytes 11296
count 1
offset 6172
sha256 88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8
$ cmp .ufo/waves/round-43/build/K43ScoutS094/CORPUS-live.md .ufo/waves/round-39/capture/S094.body
IDENTICAL   (cmp exit 0)
```

Quote (8 whitespace tokens, ≤ 25): *"Only `status`, `recheck` and `used-by` change in place"*, served
line 116. HTTP 200 / 0 redirects is the scout's measurement
(`.ufo/waves/round-43/build/K43ScoutS094/notes.md`), not re-fetched by this seat.

M42-5 evidence: `.ufo/waves/round-42/build-results.json` — every entry in `results` carries
`name`, `agent`, `note`, `output` and **no** `status` key (read with python3; the key list was
printed, not assumed).

## FILLs (the L1 replaces every one before commit; QM7 forbids placeholders in committed files)

- candidate commit; final receipts; C1/C2/C3 candidate readings, candidate receipts and kill-clause
  outcomes; the S094 re-open verdict; the S094 `used-by` old→new line; the adjacency scan; the
  per-seat status list; the M43 mistake ids/fixes; the L1 verdict.
- The two round-43 mistake rows already drafted (M43-1 restore-on-refusal gap, M43-2 receipt-file
  naming) are sourced from the reviewer's committed findings
  `.ufo/waves/round-43/build/K43ReviewC2/attacks.md` (defects D1 and D2); their ids and fixes are
  FILLs because the L1 owns the numbering and the fix choice.

## Boundaries honoured

- No file outside `.ufo/waves/round-43/build/K43ScribeDocs/` (plus this seat report and its
  `sha256sums.txt`) was written; the lane tree, `SOURCES.md`, `SOURCES.md` rows, `SCORECARD.md`,
  `LOG.md`, `QUALITY.md`, `MANIFEST.json`, `.ufo/state`, `.ufo/watchdog.log`, `templates/`,
  `scripts/` and `.scratch/` were read only.
- The lane's full claim-ledger verify and the self-counts were **not** run (host-heavy; outside the
  seat bounds). Only the counters' committed receipts and read-only `git show` / `git diff --numstat`
  / `grep` / `cmp` / `sha256sum` were used.
- `considerthese/2026-10-26.md` was read, not edited.

## Checks run by this seat (exact commands and last output lines)

| command | exit | last output line |
|---|---|---|
| `git -C <lane> cat-file -t 5f3566c…` / `a918025…` / `dd6ccb9…` | 0 / 0 / 0 | `commit` (all three revisions exist; `dd6ccb9` is on `master`) |
| `git -C <lane> diff --numstat e8265c0… d00a543 -- corpus/expect-journal.sh plans/round-41-controls.sh` | 0 | `6	1	plans/round-41-controls.sh` |
| `git -C <lane> show 5f3566c:plans/round-43-c1.sh` | 128 | (absent at the claim BASE) |
| `git -C <lane> show 5f3566c:corpus/controls-replay.sh` | 128 | (absent at the claim BASE) |
| `git -C <lane> show 5f3566c:corpus/claim-ledger.tsv \| grep -c '^R[0-9]'` | 0 | `86` |
| `grep -c '^| S[0-9]' corpus/SOURCES.md` | 0 | `98` |
| `cmp` scout capture vs `.ufo/waves/round-39/capture/S094.body` | 0 | `IDENTICAL` |
| verbatim-block re-extraction assertion (13 blocks + routed) | 0 | all `True` |

No unrun check is reported as passed.

## Out of scope for this seat (owned by others)

The candidate commit, the final `final/` receipts, the S094 verdict and `used-by` cell landing, the
adjacency scan, the M43 mistake numbering and the per-seat status list are the L1's (and the
connector/reviewer/critic/mutation-tester seats') to supply; every such value is a FILL in these
drafts.

SEAT-STATUS: complete
