# K49ScribeLesson — round-49 lesson draft (scribe seat)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE
`89afe91878f10805921d3caa67d28d21b33226da`; predeclaration
`082bfb3f6baa2407df2a23c0489043495b4dce4d` (`git cat-file -e` → exit 0; its parent is the BASE; the lane
HEAD at draft time is the predeclaration itself, and no amendment commit exists after it). Scratch
`/fast/scratch/hyaku/kagi-r49/K49ScribeLesson` (`$HYAKU_SCRATCH` default), created with `mkdir -p`; every
fixture is a `git archive` copy or a copy of one. Read-only everywhere outside the seat's build dir.

## Behavior

Wrote the round-49 lesson as a draft for the L1 to integrate into `corpus/lessons/round-49.md` (that file does
not exist yet: `ls corpus/lessons/round-49*` → exit 2, "No such file or directory"). Mined the three assigned
mistakes, measured each from committed bytes, and shipped one check per mistake that reads FLAG on the bad input
and CLEAN on the good. The `## Claims`, `## Gate` and `## Frontier` sections are headed stubs naming what the
L1 fills; the other round-48 sections (`What the trial taught`, `Amendment notes`, `Routed`, `Assimilation`,
`considerthese`) are stubs too, because this seat measured none of them.

No product code, counter, control, predicate, target, kill rule, plan, registry row, SCORECARD line, LOG line,
stamp row or sibling file was edited. No git mutation, no network, no account or vault contact, no OpenBao
server started, no token read or printed, no tool installed. The only `plans/` change in the working tree
(`M plans/round-47.md`, +4 lines at `:99-101`) was present when this seat first inspected the tree and was
not made here; it is recorded, not claimed.

## Artifacts (all under `.ufo/waves/round-49/build/` unless stated)

| path | what it is | bytes |
|---|---|---|
| `K49ScribeLesson.md` | this report | — |
| `K49ScribeLesson/round-49-draft.md` | the lesson draft: 60 lines, 10 `##` sections, the `## Mistakes` table (3 rows) and the `## Errata` text; `Claims`/`Gate`/`Frontier` stubs | 13989 |
| `K49ScribeLesson/mistake-receipts.txt` | all eight receipts below, verbatim, with exit codes | 191 lines |
| `K49ScribeLesson/m49-1-docs-gate.sh` | M49-1 check: docs declaration audit over a tree | 1314 |
| `K49ScribeLesson/m49-1-receipt.txt` | FLAG on the round-45 candidate (rc 1), CLEAN on the repaired copy (rc 0) | — |
| `K49ScribeLesson/m49-1-first-broken.txt` | CLEAN at `072bb0b^` → BROKEN at `072bb0b`, with the diff that isolates the entry | — |
| `K49ScribeLesson/m49-1-earlier-tips.txt` | five earlier tips (`0d0192f`, `92c394c`, `0ad617a`, `65f66e1`, `6d6b486`) all CLEAN | — |
| `K49ScribeLesson/m49-1-captured-by.txt` | which gate existed and why rounds 45–48 did not run it | — |
| `K49ScribeLesson/m49-1-artifacts.txt` | 36 entries, 35 with `Reverify:`, 0 stamp rows for the ISO entry | — |
| `K49ScribeLesson/m49-1-ledger-expect.sh` | routed check: R14-01's expectation vs the observed docs line | 1080 |
| `K49ScribeLesson/m49-1-ledger-expect.txt` | FLAG on the repaired tree, CLEAN after the row's counts move | — |
| `K49ScribeLesson/m49-2-seat-status.py` | M49-2 check: "every report ends `SEAT-STATUS: complete`" | 1858 |
| `K49ScribeLesson/m49-2-receipt.txt` | FLAG on round-48 (5/13 reports, 4/13 outputs), CLEAN on the patched fixture | — |
| `K49ScribeLesson/m49-3-quote-counts.py` | M49-3 check: stated quote count vs `wc -w` | 1391 |
| `K49ScribeLesson/m49-3-receipt.txt` | FLAG on `corpus/lessons/round-48.md`, CLEAN on the corrected copy | — |

## Gates

Each mistake row in the draft carries class, evidence pointer, captured-by and a fix shown able to fail:

- **M49-1 `landing`** — `corpus/knowledge/iso-11770-3-edition-status.md:1-4` has no `Reverify:` line;
  `corpus/stamps.tsv` has no row for it (35 of 36 entries declared, 0 stamp rows at BASE and at `072bb0b`).
  `bash corpus/claim-ledger.sh docs` reads CLEAN at `c74ca51` (`072bb0b^`, entries=35, rc 0) and BROKEN at
  `072bb0b` (`entries=36 … undeclared=1 … unpinned=1`, rc 1); the only knowledge-tree change between them is
  `A corpus/knowledge/iso-11770-3-edition-status.md`, and five earlier tips read CLEAN.
  Captured-by: QUALITY QM35 and ledger row R14-01 should have caught it at the round-45 landing; no
  `plans/*.sh` of rounds 45–48 runs `claim-ledger.sh docs`, the only pre-round-49 self-counts counter is
  `plans/round-36-c1.sh`, rounds 45–48 receipts carry no executed `DOC_AUDIT` verdict (round-46 quotes
  R14-01's expectation statically) and no `SELF_COUNTS` line,
  round-45's two `claim-ledger.sh verify` attempts timed out (RC 124, last line `FAIL R34-03`), so neither
  produced a docs verdict; round-46's read-only seat diagnosed the missing declaration and stamp
  statically but its spec forbade the verify; and none of rounds 45–48's eight lesson files reports a
  `DOC_AUDIT` verdict.
  Fix = round-49 C2 plus the K2-P landing repair, shown FLAG→CLEAN on the same docs command with the repair
  as the only delta (`m49-1-receipt.txt`), and non-vacuous by K2-F4 / K2-F5.
- **M49-2 `number-drift`** — the round-48 fleet report says "every report ends `SEAT-STATUS: complete`"; the
  literal ends 5 of 13 seat reports and occurs in 4 of 13 JSON outputs, while 13 of 13 seats settled.
  Captured-by none (no gate reads that sentence against `build-results.json`; the non-author closure caught it,
  round-48 spot-check §5 D1). Fix = the accurate wording, shown FLAG→CLEAN (`m49-2-receipt.txt`).
- **M49-3 `number-drift`** — `corpus/lessons/round-48.md:25,26` state 8 and 12 words; `wc -w` gives 6 and 13.
  Captured-by none (`quote-locate.py` locates, it does not count; the closure caught it, §5 D2).
  Fix = erratum E49-1 with the counting rule, shown FLAG→CLEAN (`m49-3-receipt.txt`).

Supplementary routed check (not a mistake row): ledger row R14-01 still expects `entries=35 row_linked=32`,
so the lane's full `claim-ledger.sh verify` would stay red even after the C2 repair until the row moves to
`entries=36 row_linked=33` (`m49-1-ledger-expect.txt`, FLAG on the repaired tree, CLEAN after the move).

## Commands run (exact; rc and last output line)

| # | command | rc | last line |
|---|---|---|---|
| 1 | `git -C <lane> log --format='%h %ci %s' -- corpus/knowledge/iso-11770-3-edition-status.md` | 0 | `072bb0b 2026-11-05 18:11:15 -0300 round-45: candidate (…)` |
| 2 | `git -C <lane> diff --name-status 072bb0b^ 072bb0b -- corpus/knowledge/` | 0 | `A → corpus/knowledge/iso-11770-3-edition-status.md` |
| 3 | `bash corpus/claim-ledger.sh docs` in `git archive 072bb0b^` | 0 | `DOC_AUDIT: CLEAN (entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)` |
| 4 | `bash corpus/claim-ledger.sh docs` in `git archive 072bb0b` | 1 | `DOC_AUDIT: BROKEN (entries=36 row_linked=32 by_hand=3 undeclared=1 missing_ids=0 unpinned=1 duplicate_reasons=0 floor=18)` |
| 5 | same command on `0d0192f`, `92c394c`, `0ad617a`, `65f66e1`, `6d6b486` | 0 each | `DOC_AUDIT: CLEAN (entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)` |
| 6 | `bash m49-1-docs-gate.sh <arc-072bb0b>` | 1 | `VERDICT: FLAG (docs rc=1 reverify=0 stamp=0)` |
| 7 | `bash m49-1-docs-gate.sh <tree-fixed>` | 0 | `VERDICT: CLEAN (entry declared, pinned, docs CLEAN)` |
| 8 | `bash m49-1-ledger-expect.sh <tree-fixed>` | 1 | `VERDICT: FLAG (R14-01 expectation does not match the observed docs line)` |
| 9 | `bash m49-1-ledger-expect.sh <tree-fixed-ledger>` | 0 | `VERDICT: CLEAN (R14-01 expectation matches the observed docs line)` |
| 10 | `python3 m49-2-seat-status.py --results .ufo/waves/round-48/build-results.json --reports .ufo/waves/round-48/build` | 1 | `VERDICT: FLAG (claim 'every report ends SEAT-STATUS: complete' is false: 5/13 reports end with the literal; 4/13 outputs contain it)` |
| 10a | `jq '.results \| length' .ufo/waves/round-48/build-results.json` | 0 | `13` |
| 10b | `jq '[.results[] \| select((.output\|tostring\|contains("SEAT-STATUS: complete")))] \| length' …` | 0 | `4` |
| 10c | `jq -r '.results[].name' … \| wc -l`; `ls .ufo/waves/round-48/build/*.md \| wc -l` | 0; 0 | `13`; `13` |
| 11 | `python3 m49-2-seat-status.py --results <same> --reports <fixture>` | 0 | `VERDICT: CLEAN (every report ends with the literal)` |
| 12 | `python3 m49-3-quote-counts.py corpus/lessons/round-48.md` | 1 | `VERDICT: FLAG (stated count != wc -w)` |
| 13 | `python3 m49-3-quote-counts.py <corrected copy>` | 0 | `VERDICT: CLEAN (every stated count equals wc -w)` |
| 14 | `ls corpus/lessons/round-49*` | 2 | `ls: cannot access 'corpus/lessons/round-49*': No such file or directory` |
| 15 | `git -C <lane> cat-file -e 082bfb3f…^{commit}`; `git -C <lane> rev-parse --short HEAD` | 0; 0 | `082bfb3` |
| 16 | `git -C <lane> diff --stat 082bfb3f -- plans/` | 0 | `plans/round-47.md \| 4 ++++` (the pre-existing E48-1 append; the four round-49 instruments are unchanged) |
| 17 | `git -C <lane> diff -- plans/round-47.md` | 0 | `+## Erratum E48-1 (appended round 49; …)` at `:99-101` (observed, not made by this seat) |
| 18 | `grep -c '^## Measured (round 49' corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | 1 | `0` (no measured section yet; the C1 landing adds it) |

Not run, deliberately: `plans/round-49-c1.sh`, `plans/round-49-c2.sh`, `corpus/self-counts.py`,
`corpus/claim-ledger.sh verify` (host-heavy, and this seat's item names none of them); no network fetch; no
OpenBao server; no tool install.

## Touched surfaces

- Written (all inside the seat's write scope): `.ufo/waves/round-49/build/K49ScribeLesson.md` and the fourteen
  files listed under `K49ScribeLesson/` above.
- Read-only: `corpus/knowledge/iso-11770-3-edition-status.md`,
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, `corpus/lessons/round-4[5-8]*.md`,
  `corpus/QUALITY.md`, `corpus/claim-ledger.sh`, `corpus/claim-ledger.tsv`, `corpus/stamps.tsv`,
  `corpus/SOURCES.md`, `plans/round-49.md`, `plans/round-47.md`, `.ufo/waves/round-45..48/…`,
  `.ufo/waves/round-49/{controls,plan,dispatch}`, the fleet report `.ufo/reports/round-48/kagi.md`, and
  read-only `git` (`log`, `show`, `diff`, `archive`, `cat-file`, `rev-parse`, `merge-base`).
- Not modified: `corpus/` (including `corpus/lessons/round-49.md`, which does not exist), `plans/`
  (`M plans/round-47.md` pre-dates this seat), `SCORECARD.md`, `LOG.md`, `SHONEN.md`, `SKILL.md`,
  `PROVINCE.md`, `README.md`, `corpus/QUALITY.md`, `corpus/SOURCES.md`, any registry row, `MANIFEST.json`,
  the fleet root `templates/` and `scripts/`, `.ufo/state`, `.ufo/watchdog.log`, and any sibling repo.

## Out of scope (left as found)

- The draft is not applied; the L1 writes `corpus/lessons/round-49.md`.
- C1 and C2 candidate values are not measured or claimed here; their stubs carry no candidate number.
- `R14-01` is not edited (out of this seat's write scope); it is routed with a receipt.
- The E48-1 append at `plans/round-47.md:99-101` is left exactly as found (uncommitted, not this seat's).
- No OpenBao server was started and no token was created, so nothing of that kind was printed, copied or
  stored; no real key file was read.

## Findings

1. **M49-1 first BROKEN revision is `072bb0b` (round-45 candidate), and the cause is isolated.** Parent
   `c74ca51` reads CLEAN (entries=35); the step adds exactly one knowledge entry and the audit moves to
   entries=36/undeclared=1/unpinned=1 at rc 1. Five earlier tips (`0d0192f`, `92c394c`, `0ad617a`, `65f66e1`,
   `6d6b486`) all read CLEAN (entries=35), so the defect starts at round 45 and is not inherited.
2. **The gate existed but nothing ran it.** R14-01 is a claim row; no round-45–48 plan executes
   `claim-ledger.sh docs` or `self-counts.py`; round-45's two verify attempts timed out at RC 124; round-46's
   read-only seat named the defect statically and was forbidden the verify; no round-45–48 lesson reports a
   `DOC_AUDIT` verdict.
3. **A survivor sits behind the fix:** R14-01's expectation is pinned to `entries=35 row_linked=32`, while the
   repaired tree prints `entries=36 row_linked=33`. The docs gate can be CLEAN and the full ledger verify still
   fail; routed.
4. **D1 measured:** 5/13 seat reports end with the literal, 4/13 JSON outputs contain it, 13/13 settled. The
   wave record is correct; only the "every report" sentence is not.
5. **D2 measured:** S103 6 tokens (stated 8), S104 13 tokens (stated 12), by `wc -w`; the counting rule is
   stated in E49-1 and applied by `m49-3-quote-counts.py`.
6. **D3 is answered by the round-49 plan:** G1/G2 pin instrument files by name and the kill rules enumerate the
   four plan files and the fixtures, so no erratum is owed (recorded in the draft's Errata note).
7. **E48-1 state:** the working tree already carries an uncommitted append at `plans/round-47.md:99-101` with
   the closing "Not yet appended" sentence dropped; the L1 decides whether to land or replace it.

## Limits

- `docs` was run in `git archive` copies of the lane (no `.git`); the audit reads the archive's own
  `claim-ledger.sh`, `claim-ledger.tsv`, `stamps.tsv` and `corpus/knowledge/` files, which is the surface it
  judges.
- The repaired fixture's stamp row is written by hand (path, sha256, lines, bytes) because
  `claim-ledger.sh stamp` replaces the whole row set; the row is a fixture only and the audit reads it as a row.
- The three `RD-DOCS-*` SETUP readings come from the frozen `controls/c2-base.txt`; `self-counts.py` was not
  re-executed by this seat.
- Scratch `/fast/scratch/hyaku/kagi-r49/K49ScribeLesson` was removed before this seat yielded (`rm -rf`);
  every receipt cited here lives in the build dir.

SEAT-STATUS: complete
