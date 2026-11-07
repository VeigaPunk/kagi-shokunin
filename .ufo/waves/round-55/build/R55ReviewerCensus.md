# R55ReviewerCensus — census gate change (`corpus/sources-census.sh`)

Measured revision: `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`
(`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`)
BASE: `ebe095857a734caf5efdd7bd776feb22b4e23972`
Receipts: `.ufo/waves/round-55/build/R55ReviewerCensus.d/`. Scratch: `/fast/scratch/hyaku/kagi-r55/R55ReviewerCensus/`.

Scope: the diff `ebe0958..348aa3b -- corpus/sources-census.sh` — `SC_BODY_CITE`
(`body_ids`, `cites_field`, `[[ -v ST[...] ]]`, legacy handling, multiple `cites:`
lines), `SC_USEDBY_NOCITE` via `cites:`, the eight new selftest cases, and the
`cite-no-id` 3 → 5 literal; plus the counter values the change is calibrated by.

## Verdict

The gate change is sound where it lands and the three numbers it is judged by
reproduce exactly: **C1 25 → 0** (`guard=1`), **C2 0 → 2** (`guard=1`), **selftest
70 → 78** (`PASS`). The 25 used-by cells added by the candidate are a 1:1 match for
the 25 BASE GAP pairs (no padding, none unfilled), and the `SC_BODY_CITE` body
tokenizer and the C1 counter's `TOK` yield identical token sets on **37 of 37**
entries (0 files differ).

Nine findings follow; none invalidates C1 or C2. Two touch candidate bytes: the
census header still states a bound that round 55 made false (**F2**), and the
round's own lesson sits outside the new check while breaking exactly the rule it
introduces (**F1**).

## What I could not fault (positive evidence)

1. **Mention shapes the assignment asked about are all caught.** Fixtures built
   from the selftest's `base_fixture` shape, each verified with
   `bash corpus/sources-census.sh verify --root <fx>` (receipt `probes.txt`):

   | fixture body text appended to `corpus/knowledge/e1.md` | exit | finding |
   |---|---|---|
   | ``The lead `S003` is thin.`` (code span) | 1 | `SC_BODY_CITE entry=corpus/knowledge/e1.md id=S003 unrecorded` |
   | `S003 leads here.` (line start) | 1 | same |
   | `As recorded (S003).` (punctuation) | 1 | same |
   | `Rows S001–S003 and S001-S003 were merged.` (range, en dash + hyphen) | 1 | same, exactly 1 finding |
   | `; S003 (… )` added as a `source:` continuation line | 1 | no `SC_BODY_CITE`; only `SC_ENTRY_CITE entry=… id=S003 status=queued` (correct: recorded, not mined) |
   | `cites: S001` + `  and S003` (cites continuation) | 0 | CLEAN |
   | `cites:` as the last bytes with no final newline | 0 | CLEAN |
   | CRLF-rewritten entry | 0 | CLEAN |
   | `cites:` line placed *before* `source:` | 0 | CLEAN |

   The last four show the `$`-anchored `[[ $field =~ …([^0-9]|$) ]]` and
   `cites_field`'s continuation rule behave at the edges (EOF without newline, CRLF,
   order).

2. **The tokenizer equals the counter's.** For all 37 `corpus/knowledge/*.md`,
   `body_ids`'s `grep -oE '(^|[^A-Za-z0-9_])S[0-9]{3,}' | grep -oE 'S[0-9]+$'`
   and `plans/round-55-c1.sh`'s `(?<![A-Za-z0-9_])S\d{3,}(?!\d)` produce identical
   token sets (`0 files-with-diff`). So the `S001S003` "overlap" hypothesis is not
   a gate defect: `S003` there is *preceded by a digit* and therefore not a token
   under the documented rule, for both tools (`Rows S001S003 merged.` → only
   `S001`; fixture `overlap` → CLEAN, correctly).

3. **`cite-no-id` 3 → 5 is the right literal.** The mutated fixture emits exactly:
   ```
   FINDING SC_USEDBY_NOCITE id=S001 path=corpus/knowledge/e1.md
   FINDING SC_USEDBY_NOCITE id=S002 path=corpus/knowledge/e1.md
   FINDING SC_BODY_CITE entry=corpus/knowledge/e1.md id=S001 unrecorded
   FINDING SC_BODY_CITE entry=corpus/knowledge/e1.md id=S002 unrecorded
   FINDING SC_ENTRY_CITE entry=corpus/knowledge/e1.md no-registry-id
   SOURCES_CENSUS: FAILED (findings=5 rows=4)
   ```
   The +2 are the S001/S002 mentions left in the fixture's `recheck:` line once
   `m_cite_noid` strips the `source:` line. The case still asserts the
   `SC_ENTRY_CITE` id *and* the total, so it got stricter, not vacuous. Caveat: it
   is now a three-id case (NOCITE + BODY_CITE + ENTRY_CITE), no longer the
   one-mutation-one-id isolation the table's other rows have — the migration
   journal (`.ufo/waves/round-55/expectation-migrations.json` row `R21-03`) states
   the reason correctly.

4. **Selftest coverage of the new code.** All eight cases are non-inert (the
   harness diffs against the base fixture) and each of the five failing cases
   asserts `findings=1`, so no case passes by coincidence of another check. Branches
   exercised: multiple-`cites:` line, legacy body mention, `cites:` recording,
   `cites:`-used-by omission, `cites:` non-row, `SC_USEDBY_NOCITE` via `cites:`,
   and the token-suffix control. Uncovered: nothing material.

5. **Calibration arithmetic.** 20 registry rows change, and the only cell that
   changes in any of them is `used-by` (`cells touched: ['used-by']`); 25 used-by
   entries were added in total, and the set `{(path, id)}` of added cells is
   **identical** to the 25 BASE `GAP` pairs. Two rows are added (S113, S114). Ten
   knowledge entries carry a column-1 `cites:` line, matching "one column-1
   `cites:` line in ten entries".

6. **The migration journal's census rows are measured, not restated.**
   `expectation-migrations.json` `R21-02`'s `old_expect` is BASE's actual last line
   (`$ git archive ebe09585… | tar -x -C <scratch>; bash <scratch>/corpus/sources-census.sh`
   → `SOURCES_CENSUS: CLEAN (rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4
   entries_sourced=16 legacy=21 captures=112 inrow=16 inrow_only=0
   inrow_nonreproducing=12)` `exit=0`, receipt `verify-base.txt`) and its
   `new_expect` is the candidate's (receipt `verify-candidate.txt`). `R21-03`'s
   70 → 78 and "`cite-no-id` 3 → 5" both hold, and its "five failing, three
   positive controls" matches the case table (three controls:
   `body-cites-control`, `usedby-via-cites-control`, `body-digit-suffix-control`).

7. **C2's recheck counts read true on the committed captures.** Independent
   re-run of the two commands the entry states:
   `grep -c 'Withdrawal of International Standard' .ufo/waves/round-45/controls/capture-r45/S101.raw`
   → `2` (BASE stated 1: `C2_ISO_CURRENT: value=0 amd=0 recheck=0 guard=1
   (bad=amd:a-rows=0,recheck:S101-count-2-stated-1)`);
   `grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025' .ufo/waves/round-55/capture/S113.body`
   → `3`. `S114.body` carries the quoted title at the declared offset 541
   (`dd … skip=541` → `ISO/IEC 11770-3:2021/Amd 1:2025 - Inform`), and both bodies'
   sha256 match `source-fetches.tsv` (S113 `d8dfe354…a64357`, S114 `8bb88d88…449bdf`).

## Findings

### F1 — MEDIUM — `SC_BODY_CITE` silently excludes `corpus/lessons/*.md`, and the round's own lesson breaks the rule it introduces

`corpus/sources-census.sh:352` iterates `for f in "$kdir"/*.md` with
`kdir="$ROOT/corpus/knowledge"` (`:180`). Lessons are only ever checked in the
*used-by → file* direction (`SC_USEDBY_NOCITE`, which admits them by
`usedby_re='^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\.md$'` at `:232`), never
for body mentions — yet the header's
`ENTRIES` paragraph defines an entry solely by "a line [that] starts with
`source:`", with no path restriction, and `SC_BODY_CITE`'s own text
(`sources-census.sh:55`) says "an entry — sourced or legacy — whose text names a
registry id…". A reader is entitled to expect a lesson with a `source:` line to be
covered.

The candidate's own tree is the counter-example. `corpus/lessons/round-55.md` is
listed in S113's and S114's used-by cells and carries
`source: S113 …; S114 …`, and its body names **21** further registry ids that are on
neither its `source:` nor a `cites:` line; **21 of those rows' used-by cells omit
the lesson**. `bash corpus/sources-census.sh` reports CLEAN anyway.

Reproduction (same bytes, two paths; receipt `probes.txt`, cases
`lesson-knowledge` / `lesson-lessons`):
```
$ cp -R fx-base d && sed -i '/^| S003 /s#| — |$#| corpus/<dir>/l2.md |#' d/corpus/SOURCES.md
$ printf 'notes\nsource: S001 (…, §1, rev 1)\nbody mentions S003\n' > d/corpus/<dir>/l2.md
$ bash corpus/sources-census.sh verify --root d     # <dir> = knowledge
FINDING SC_BODY_CITE entry=corpus/knowledge/l2.md id=S003 unrecorded      exit 1
$ bash corpus/sources-census.sh verify --root d     # <dir> = lessons
SOURCES_CENSUS: CLEAN (…)                                                 exit 0
```
Live-tree evidence (receipt `lesson-audit.txt`):
`rows listing round-55 lesson: ['S113','S114']`;
`registry ids named but NOT on source:/cites:: 21 ['S012','S017','S018','S019','S020','S021','S022','S023','S024','S047','S048','S049','S050','S055','S056','S072','S101','S103','S104','S105','S112']`;
`of those, rows whose used-by omits the lesson: 21 (same list)`.

Honest framing: `plans/round-55-c1.sh`'s frozen predicate names the population
("the regular, non-symlink files `corpus/knowledge/*.md` (top level)"; "lessons are
outside the population"), and `QUALITY.md` QM71 says "knowledge entry". So C1's
**value** is not overstated. What is overstated is the *gate's* documented reach,
and the lane now ships a lesson that would be 21 findings if it lived one directory
over — the exact self-description QM71 declares invisible ("an entry that names the
row while the cell omits it is a self-description the census cannot see").

Cheapest honest resolutions: state the knowledge-only population in the
`SC_BODY_CITE` header text and in QM71, or give `corpus/lessons/round-55.md` a
`cites:` line (21 ids) plus the 21 used-by cells; or extend the loop to
`corpus/lessons/*.md` in a later round.

### F2 — MEDIUM-LOW — the header's `STATED BOUND` was not updated and is now false; `-h` prints it

`sources-census.sh:105-107` still reads:
```
# STATED BOUND: legacy entries are outside every check of this gate — header,
# cite, tier and the credential scan included — until they gain a column-1
# `source:` line; the lane's own transcript/claim gates own them.
```
Round 55 makes this false: `SC_BODY_CITE` deliberately covers legacy entries
(`sources-census.sh:55` "an entry — sourced or legacy —"), and the selftest asserts
it (`body-cite-legacy` expects `SC_BODY_CITE … 1`, and my `cites-indented`,
`cites-capital`, `legacy-cites-no-usedby` fixtures fire on `corpus/knowledge/legacy.md`).
`sources-census.sh -h` prints the header verbatim (`sed -n '2,/^set -uo pipefail$/p'`),
so the stale bound is user-facing (receipt `header-lines.txt` shows `bash
corpus/sources-census.sh -h | sed -n '95,115p'`). Fix: amend the bound to "outside
the header/cite/tier/credential checks; `SC_BODY_CITE` reaches them".

This one does affect candidate bytes (header text of the measured file).

### F3 — LOW — a `cites:` line inside a fenced code sample counts as a second `cites:` line

`[[ $(grep -c '^cites:' "$f") -le 1 ]]` (`sources-census.sh:356`) counts fenced
samples; the census's sibling registry-row parsing in `plans/round-55-c1.sh`
deliberately skips ``` fences. An entry that documents the format is refused.
Reproduction (receipt `probes.txt`, case `cites-fenced-sample`):
```
e1.md += "cites: S003\n```\ncites: S099\n```\n"     (S003 used-by cell set)
$ bash corpus/sources-census.sh verify --root d
FINDING SC_BODY_CITE entry=corpus/knowledge/e1.md multiple-cites-lines   exit 1
```
Not present in the candidate tree (no entry carries a fenced `cites:` sample), but
a plausible future entry. Workaround is to indent the sample; the check does not say so.

### F4 — LOW — one NUL byte in an entry disables the whole body scan for that file, silently

`body_ids` is two `grep -o` stages. The second stage reads the first stage's output;
if any NUL byte reached the stream, GNU grep treats it as binary and emits **nothing
at all** — not even the clean matches. Measured (receipt `nul-trace.txt`):
```
stage1: " S001\n S002\n S001\n S002\n\0S003\n"      (matches ARE found)
stage1|stage2: (empty)                              → body_ids = ""
```
Fixture `nul-byte` (`e1.md` + `\nLead \0S003 here.\n`) → `SOURCES_CENSUS: CLEAN`,
exit 0, with S003 unrecorded. Fix: `grep -a -oE …` (or `LC_ALL=C grep -a`).
Reachability is low (a markdown entry with a NUL), and fail-closed elsewhere covers
it: `plans/round-55-c1.sh` guard `g4` re-reads the file in python and would read
`nocite>0` → `value=FAIL`. Still, the *gate* reports CLEAN, which is the thing
`SC_BODY_CITE` is now claimed to be.

### F5 — LOW — a mention of a `rejected` row has no honest recording path

Recording a mention of a rejected row in `cites:` makes the row's used-by have to
list the entry (`SC_BODY_CITE … cites-used-by-omits-entry`), and putting it on
`source:` is refused (`SC_ENTRY_CITE … status=rejected`). So the only path asserts
that the rejected row *supports* the entry. Reproduction (receipt `probes.txt`,
cases `rejected-mention-no-usedby` / `rejected-mention`):
```
e1.md += "S004 was rejected.\ncites: S004\n"
$ bash corpus/sources-census.sh verify --root d
FINDING SC_BODY_CITE entry=corpus/knowledge/e1.md id=S004 cites-used-by-omits-entry  exit 1
# with S004's used-by cell set to corpus/knowledge/e1.md:
SOURCES_CENSUS: CLEAN                                                               exit 0
```
No check forbids a `rejected` row from carrying a used-by cell, so the workaround
is available and silent — which is the problem: the registry then claims support
from a row whose `teaches` starts `REJECTED:`. Cheap fix: exempt `rejected` rows
from the used-by reciprocity in the `cites:` loop (a mention of a rejected row is a
disclaimer, not support). No candidate entry currently mentions a rejected row, so
this does not change today's bytes.

### F6 — LOW — `cites:` is trusted, never checked against a body mention; used-by padding gets cheap

The gate verifies *cites id → registry row → used-by lists entry*, but never that
the entry actually names the id. A bare `cites:` line therefore adds an entry to a
mined row's used-by with no mention anywhere in the file. My fixture
`cites-no-final-newline` is exactly that shape (`Body.` only, `cites: S003`,
S003's used-by = `e1.md`) → `SOURCES_CENSUS: CLEAN`. `plans/round-55-c1.sh` guard
`g4` reads `field(txt,'source:') + '\n' + field(txt,'cites:')`, so it too is
satisfied by a lone `cites:` line — g4's stated purpose ("a used-by cell cannot be
padded with an entry that does not record the row") is now satisfiable by writing
one line. C1's **GAP** is not fooled (it counts mention pairs, not records), so no
claim value moves; this is an honesty surface, not a calibration one.

### F7 — INFO — column-1 lower-case only, with a misleading diagnostic

An indented `  cites:` or a capitalised `Cites:` is not a `cites:` line, so the
body mention stays unrecorded **and** the used-by cell the author just added fails
`SC_USEDBY_NOCITE`, producing two findings where one line is wrong (fixtures
`cites-indented`, `cites-capital`):
```
FINDING SC_USEDBY_NOCITE id=S002 path=corpus/knowledge/legacy.md
FINDING SC_BODY_CITE entry=corpus/knowledge/legacy.md id=S002 unrecorded
```
Contract-conforming (column 1, lower case is documented), but the message points at
the row, not at the malformed line. A `cites:`-line-shaped line that is not at
column 1 could be reported as such instead.

### F8 — INFO — asymmetry between body ids and `cites:` ids for non-registry tokens

A body token that is not a registry row is skipped (`[[ -v ST[$bid] ]] || continue`);
the same token on `cites:` is a finding (`cites-not-a-registry-row`). Fixture
`non-row-body-id` (`Lead S099 unverified.`) → CLEAN; fixture `body-cites-not-a-row`
→ finding. Documented ("a registry id that is on neither…"), and it is what keeps a
prose `S999` from failing the gate — noting it so the asymmetry is not mistaken for
an oversight.

### F9 — INFO — symlinked knowledge entries: the gate scans them, the C1 counter excludes them

`"$kdir"/*.md` follows a symlink; `plans/round-55-c1.sh` requires
`not os.path.islink(p)`. Fixture `symlink-entry` (`corpus/knowledge/link.md` →
`../../out.md`, body `body names S003`) → `FINDING SC_BODY_CITE entry=corpus/knowledge/link.md
id=S003 unrecorded`, while the counter would drop the file from its population. The
divergence is in the strict direction (gate fails, counter is blind), which is the
safe way round; no symlink exists in the candidate tree.

## Residual risk

- The new check is only as good as `grep`'s per-line token shape. Anything that
  keeps a token from being a token (a NUL byte, per F4; a lower-case `s003`; `S 003`;
  an id preceded by `_`) is invisible to both the gate and the C1 counter, so a
  future edit that introduces such a form silently lowers the population.
- `SC_BODY_CITE` is an *existence* check on records, not a *truth* check on
  mentions: `cites:` may over-declare (F6) and a mention may be recorded on the
  wrong file of a used-by list as long as the row lists it.
- Lessons are outside the scan (F1) while being inside the used-by vocabulary; a
  lesson can accumulate unrecorded mentions without any automated signal.
- The gate's `SC_USEDBY_NOCITE` now accepts `cites:` in `corpus/lessons/*.md`,
  which means a mined row's used-by cell can be satisfied by a lesson that carries
  the id *only* in its `cites:` line; no check ties that back to a body mention (F6).

## Verification gaps

- I did not run `claim-ledger.sh verify` (item scope forbids the full run) and did
  not re-run the frozen pre-freeze controls; the assignment's C1/C2 guards already
  encode the census and selftest outcomes, and both read `guard=1` on the candidate.
- I did not fetch the ISO pages myself (refusal boundary: public GET only, and the
  pages 403 a default agent). Currency of S113/S114 rests on the committed captures
  and their declared provenance, which I checked for self-consistency (sha256,
  offset, quoted counts), not against the live 2026-11-07 pages.
- F4's NUL path is demonstrated on a fixture; the live corpus is clean (receipt
  `nul-trace.txt`: 37 entries, 0 contain a NUL byte), so it does not move today's
  numbers. Fail-closed elsewhere covers the case: `plans/round-55-c1.sh` guard `g4`
  re-reads each file in python and would count `nocite>0` → `value=FAIL`.
- No lsp server answers bash in this lane; caller/definition checks were made by
  reading the candidate script and the counter sources directly, and every
  behavioural claim above was executed, not inferred.
