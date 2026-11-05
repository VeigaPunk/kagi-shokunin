# K41ScribeRegistry - notes (round 41, kagi, attempt 1)

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Predeclaration commit (frozen plan + counters + BASE controls): `5142b52`.
Claim BASE: `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`.
Round-40 landed state (positive control P0 of C1): `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`.
Round-40 claim BASE: `6cc8850dfc5757927699e5a53a876f47c8df21aa`.

Scratch (created, used, removed on yield): `/fast/scratch/hyaku/kagi-r41/K41ScribeRegistry`
(`$S`), clone at `$S/work`. Sandbox write guard: `git -C "$S/work" rev-parse --show-toplevel`
printed `$S/work` before every write; asserted equal to `$S/work` before the fixture apply.
No lane file was edited except the two capture bodies under `.ufo/waves/round-41/capture/`
and this seat's own deliverable directory. No `git add/commit/stash/checkout/switch/reset/
pull/push` in the lane; no mutating `jj`; no `corpus/SOURCES.md` or
`corpus/source-fetches.tsv` edit in the lane; no `claim-ledger.sh verify` run (the one-run
allowance was not needed: the census and row-identity selectors were run directly);
no pacman/uv/cargo install (tooling: **none** needed - `curl`, `python3`, `git`, `sha256sum`,
`wc`, `cmp`, `grep`, `awk`, `sed` were all present).

Deliverables (this directory):
- `rows.md` - the two registry rows (S097, S098), in the exact 11-column schema
- `fetch-rows.tsv` - the two `corpus/source-fetches.tsv` rows, 16 tab-separated columns
- `census-sandbox.txt` - full `sources-census.sh` summary + exit code, with the baseline
- `rowidentity-sandbox.txt` - `grep -c '^## Round '` and `row-identity.sh scorecard-rounds`
- `expectation-migrations.draft.json` - the round-41 migration journal draft
- `opens.txt` - title, HTTP status, sha256, byte count and locate counts for S097 and S098
- `capture/S097.body`, `capture/S098.body` - the two capture bodies (also at
  `.ufo/waves/round-41/capture/` in the lane)
- Report: `.ufo/waves/round-41/build/K41ScribeRegistry.md`

---

## 1. Live opens (CORPUS.md rule 1 satisfied by this seat)

Both sources opened live on 2026-11-05 by this seat. Full receipts in `opens.txt`.

| id | url | http | title | raw sha256 | bytes | locate exit |
|---|---|---|---|---|---|---|
| S097 | https://docs.python.org/3/library/stdtypes.html | 200 | `<title>Built-in Types &#8212; Python 3.15.2 documentation</title>` | `e2992e17d9b8f15f09b2971e356d06c5e0f1572fefa6ce733eb6d7d48466e2b3` | 815447 | 0 (count=1) |
| S098 | https://www.unicode.org/reports/tr18/ | 200 | `<title>UTS #18: Unicode Regular Expressions</title>` | `68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d` | 199607 | 0 (count=1) |

Both bodies are byte-identical to the scout seat's staged copies
(`.ufo/waves/round-41/build/K41ScoutSources/capture/`, `cmp` exit 0 for both) and to a second
fetch under the declared request profile `curl-fsSL --compressed -A 'kagi-shokunin-round23/1.0
(documentation verification)'` (identical sha256 and byte count). The capture bodies written
by this seat therefore bind the same bytes the scout measured.

S097 redirect: `https://docs.python.org/3/library/stdtypes.html` -> HTTP/2 301 ->
`https://docs.python.org/3/builtins/stdtypes.html`. The registered URL in the registry row and
the fetch row is the library path (the URL that was opened); the effective URL is recorded in
the fetch row's `final_url` column, as the header of `corpus/source-fetches.tsv` requires.

Collision guard, run BEFORE drafting: the duplicate-id scan printed nothing and
`grep -c 'S097\|S098' corpus/SOURCES.md` printed `0`.

## 2. Quotes (both located, exit 0)

S097 - the `str.isspace()` whitespace definition, rendered-text-v1 normalized body:

> either its general category is Zs (“Separator, space”), or its bidirectional class is one of WS , B , or S .

22 whitespace tokens (the census shape-checks a fetch-row quote at <=25 words). Raw body byte
offset of the sentence: 296695. Rendered-text-v1 normalized byte offset of the quote: 71263.

S098 - UTS #18 Annex C "Compatibility Properties", the `space (\s)` entry, rendered-text-v1
normalized body:

> space (\s) \p{Whitespace} See PropList for the definition of Whitespace.

10 words. Raw body byte offset of the entry: 160860. Rendered-text-v1 normalized byte offset
of the quote: 90651.

Both quotes locate in the rendered text; neither is a raw-byte substring of the served HTML
(the served bodies carry HTML tags inside the sentence, so the raw byte search finds nothing -
measured `False` for both). This is why the fetch rows declare `raw-literal-v1` on the
`<title>` quote (which IS a raw byte substring) and carry the located teaching quote in the
`location` column, exactly the split the S095/S096 rows use.

## 3. Registry rows

Schema: the exact 11 columns of `corpus/SOURCES.md` `## Registry`
(`id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by`).
Both rows parse as 11 columns (`awk -F'|'` NF == 13); no cell contains a literal or escaped
pipe; no cell contains a newline. Both asserted programmatically before the sandbox apply.

- **S097** - `docs` / tier `A` / scope `rendered-text-v1 whitespace class grounding
  (str.isspace)` / status `mined` / opened `2026-11-05` / recheck `90d`.
  The `teaches` cell carries the located quote verbatim (marked "Quote (verbatim)") and the
  derivation separately (marked "Derivation (paraphrase, outside the quote)"), per QM42.
- **S098** - `spec` / tier `A` / scope `Unicode White_Space as a candidate rendered-text-v1
  whitespace class` / status `rejected` / opened `2026-11-05` / recheck `on-release`.
  The `teaches` cell opens `REJECTED:` and carries `flip:` (both are hard requirements of the
  census `SC_REJECT_SHAPE` check). The `recheck` value `on-release` is the recheck form of the
  existing rejected row S030; the `used-by` cell is the em dash, also the S030 form.

## 4. Defects and deviations found (routed, not fixed in the lane)

**(a) The seat brief's `used-by` value for S097 is census-incompatible.** The brief proposed
`corpus/rendered-text-v1.py (round 41 C2)`. Measured in the sandbox with that exact cell value:

```
FINDING SC_USEDBY_MISSING path=corpus/rendered-text-v1.py (round 41 C2)
FINDING SC_USEDBY_MISSING S097: corpus/rendered-text-v1.py (round 41 C2) not a repo corpus path
SOURCES_CENSUS: FAILED (findings=2 rows=98)
exit=1
```

The census accepts only `corpus/(knowledge|lessons)/<name>.md` as a used-by path, requires the
file to exist, and requires the file's `source:` line to carry the row id. A `.py` path fails
all three. The rows opened in round 40 (S095, S096) use the round lesson file
(`corpus/lessons/round-40.md`) for exactly this reason. The draft therefore uses
`corpus/lessons/round-41.md` for S097 and says so in `rows.md`. This is a deviation from the
brief's literal text, taken because the brief's value makes the census fail; the alternative
(leaving the census red) would break the C1 migration.

**(b) The S097 row's census-CLEAN landing depends on K41ScribeLesson's lesson file.** Measured
in the sandbox with the S097/S098 rows present but the lesson file absent:

```
FINDING SC_USEDBY_MISSING path=corpus/lessons/round-41.md
SOURCES_CENSUS: FAILED (findings=1 rows=98)
exit=1
```

and with the lesson file present but its `source:` line NOT citing S097:

```
FINDING SC_USEDBY_NOCITE id=S097 path=corpus/lessons/round-41.md
SOURCES_CENSUS: FAILED (findings=1 rows=98)
exit=1
```

So the round-41 lesson file must exist AND its column-1 `source:` line must cite S097. This is
the single cross-seat coupling this seat's rows create.

**RESOLVED as of the end of this seat's run.** K41ScribeLesson's real draft
(`.ufo/waves/round-41/build/K41ScribeLesson/lesson-round-41.md`) landed after this seat's first
sandbox pass and its `source:` line does cite S097 (and S098):

```
source: S095 (docs.python.org/3/library/re.html, re-opened 2026-11-05, byte-identical to the
round-40 capture); S097 (docs.python.org/3/library/stdtypes.html -> /3/builtins/stdtypes.html,
opened 2026-11-05); S098 (unicode.org/reports/tr18/, opened 2026-11-05, REJECTED); ...
```

Re-measured in a FRESH sandbox with that real file copied verbatim as `corpus/lessons/round-41.md`
together with these rows: `bash corpus/sources-census.sh` -> `SOURCES_CENSUS: CLEAN (rows=98
A=94 B=2 C=2 queued=1 mined=93 rejected=4 entries_sourced=14 legacy=21 captures=98 inrow=16
inrow_only=0 inrow_nonreproducing=12)`, exit 0. The coupling is satisfied as drafted; the
recorded readings in `census-sandbox.txt` are from that real-file run.

**(c) The S097 `teaches` cell cannot claim `supersedes S095`.** The corpus contract (rule 2)
allows a correction row to supersede an earlier row; S097 is a NEW row, not a correction of
S095 (S095 grounds the `re` `\s` entry, S097 grounds the `str.isspace()` definition; the
C2 counter's own sub-term (a) reads "no cited id is superseded" from every `supersedes S###`
cell). A `supersedes S095` claim would have made the C2 counter's term (a) read 0. The draft
therefore states S097 as an additional grounding, not a supersession. Verified: with the
S095/S096/S097 paragraphs in place, `bash plans/round-41-c2.sh` in the sandbox prints `3`
(exit 0).

**(d) The census summary in the migration draft still depends on the SCORECARD heading pair.**
The measured `rows=98 ... captures=98` summary was taken with the REAL
K41ScribeLesson lesson file (see (b)) and a stand-in round-41 pre/post heading pair. The
census summary is insensitive to the heading text - only the two SCORECARD rows R13-01 and
R24-06 are - so the recorded summary should hold at the landing tree provided the two rows
land. The L1 must still re-measure it at the landing tree; the stand-in is named in
`expectation-migrations.draft.json` (`measured_at`) and in `census-sandbox.txt`.

**(e) R24-06's `new_expect` sha256 is heading-text sensitive - STILL OPEN.** `row-identity.sh
scorecard-rounds` hashes the SCORECARD `## Round ` heading LINES, so the digest depends on the
exact heading text the L1 writes, not only on the count 54 -> 56. The draft's digest
`230992d3...c77ab` was measured against a stand-in heading pair and WILL change when the real
headings land. The count (56) is stable; the digest is not. The L1 must re-measure it.

K41ScribeLesson's delivered draft does not fix the heading text: its `scorecard-round-41-pre.md`
carries an H1 `# SCORECARD - round 41 pre-move (draft for the L1; repo HEAD 5142b52, round-40
close)` and no `## Round ` heading at all; its notes leave the post-move table to the L1
(slot 11). So there is no delivered heading pair to measure against, and the stand-in remains
the only available basis for the count. The prior rounds' pairs read
`## Round 40 - pre-move (repo HEAD 6cc8850, round-39 close)` and
`## Round 40 - post-move (claims C1 calibration, C2 freshness, C3 operability)`, so a count of
56 (one pre-move plus one post-move) is the expected shape - the DIGEST is not derivable from
what has been delivered.

**(f) The lesson seat's S097 quote differs from this seat's - both locate.** K41ScribeLesson's
Gate records the S097 quote as "Return True if there are only whitespace characters in the
string and there is at least one character, False otherwise." (the `str.isspace()` result
sentence); this seat's draft uses the class-defining clause "either its general category is Zs
("Separator, space"), or its bidirectional class is one of WS , B , or S .". Both are in the
same body and both locate: `python3 corpus/rendered-text-v1.py locate` returns count=1, exit 0,
for each (measured from the lane path against
`.ufo/waves/round-41/capture/S097.body`). This seat's choice is the class-defining clause
because the row's `teaches` cell has to ground the WHITESPACE CLASS (the C2 claim is about the
step-5 class), while the result sentence states only what the method returns. The lesson's
Gate records the class-defining clause separately at raw offset 296702 ("its general category
is"), so the two drafts agree on the content. The L1 picks one; the lesson's `source:` line
cites the row id either way, which is what the census checks.

The lesson's Gate also records a second, independent ground for the S098 rejection: the literal
`\p{White_Space}` does not occur in the served body (`locate` -> count 0, exit 1; a raw `grep`
for it returns 0 matches). Verified from the lane path against
`.ufo/waves/round-41/capture/S098.body`: `grep -c 'p{White_Space}'` -> `0`, exit 1. This seat's
S098 row quotes the form the served body DOES carry (the Annex C `space (\s)` entry), which is
why its quote locates and the lesson's `\p{White_Space}` form does not. Both readings agree on
the verdict.

**(g) The rejection arithmetic is independently confirmed.** The labrat seat's probe
(`.ufo/waves/round-41/build/K41LabRejectProbe/probe.txt`) measured `A_minus_B_count: 4` with
members U+001C U+001D U+001E U+001F and `B_minus_A_count: 0` against PropList.txt at sha256
`f438f532...55d6`, VERDICT "H0 holds". This seat's own sweep over the full code-point range
found the same four code points and no others (recorded in `opens.txt`), so the rejection
reason in the S098 `teaches` cell rests on two independent measurements, not on one.

## 5. Fetch rows

16 tab-separated columns in the layout of the S095/S096 rows:
`id, status, row_identity_sha256, url, final_url, http_status, request_profile, fetched,
representation, sha256, bytes, revision, quote, normalization, normalized_sha256, location`.

- `row_identity_sha256` is the sha256 of `id<TAB>status<TAB>url<LF>`, the census's own rule
  (`corpus/source-fetches.tsv` header, lines 9-10). The method was verified against the two
  existing rows first: S097 -> `5685ae53ea35c9b9e8464dec135f19de839d64fcbf9f7eda473798960d37a015`,
  S098 -> `79783db8783bab1a07c746f072b28131d3f94c8c5b436d1e6484978b139a8d07`.
- `quote` = the served `<title>` element (a raw byte substring of each body, so
  `raw-literal-v1` is the truthful normalization and `normalized_sha256` is `-`, as the census
  requires); `location` names the located teaching quote and its rendered-text-v1 byte offset.
- S097 `status` is `mined`; S098 `status` is `rejected` (the S030 form), and the census checks
  that the fetch status equals the registry status.

## 6. Sandbox validation

Two sandbox clones were used, both created the same way and both with the toplevel asserted
before any write:

```
git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin "$S/<clone>"    exit 0
git -C "$S/<clone>" checkout --detach 5142b52                                   exit 0
git -C "$S/<clone>" rev-parse --show-toplevel  ==  "$S/<clone>"                (asserted)
```

`$S/work` was the first pass (stand-in lesson file). `$S/verify` was the final pass: a FRESH
clone into which the DELIVERED `rows.md` (its two row lines were extracted programmatically
from the fenced block) and the DELIVERED `fetch-rows.tsv` were applied, plus the two capture
bodies, plus the REAL K41ScribeLesson lesson draft copied verbatim as
`corpus/lessons/round-41.md`, plus a stand-in round-41 SCORECARD pre/post heading pair.

```
$ bash corpus/sources-census.sh          (cwd=$S/verify)
SOURCES_CENSUS: CLEAN (rows=98 A=94 B=2 C=2 queued=1 mined=93 rejected=4 entries_sourced=14 legacy=21 captures=98 inrow=16 inrow_only=0 inrow_nonreproducing=12)
exit=0

$ grep -c '^## Round ' SCORECARD.md      (cwd=$S/verify)
56
exit=0

$ bash corpus/row-identity.sh scorecard-rounds   (cwd=$S/verify)
ROW_IDENTITY: scorecard-rounds count=56 sha256=230992d31dbbc54f30ff0b1e530ba4816355f20bab167bcda85aadd3dc8c77ab
exit=0

$ bash plans/round-41-c2.sh              (cwd=$S/verify, with the K41ExecDocs Sources paragraph)
3
exit=0
```

The `$S/work` first pass, with the stand-in lesson file, produced the SAME three readings
(census CLEAN rows=98, headings 56, row-identity count=56 sha256 230992d3...), so the two
passes agree and the delivered artifacts reproduce the readings from the delivered files
themselves.

Baseline for comparison, measured on the pristine 5142b52 tree in the same sandbox:
`SOURCES_CENSUS: CLEAN (rows=96 ... captures=96 ...)`, exit 0; heading count 54; row-identity
`count=54 sha256=52e7ba8d...`. The deltas are exactly the two new rows, the two new captures,
and the two new SCORECARD headings.

## 7. Migration journal draft

`expectation-migrations.draft.json` follows the shape of
`.ufo/waves/round-40/expectation-migrations.json`: `round`, `measured_at`, `kind`,
`population`, `migrations[]`, `outside_population_untouched`. It covers exactly the six frozen
C1 debt rows R13-01, R24-06, R21-02, R31-02, R33-02, R34-03 - no more, no fewer.

- `old_expect` for each row is the literal value at 5142b52 (`git show
  5142b52:corpus/claim-ledger.tsv`), verified programmatically: for all six rows the draft's
  `old_expect` and `command` compare EQUAL to the base ledger cell (byte-for-byte string
  equality, not a reconstruction).
- `new_expect` is the measured value as a fully literal anchored expression: every regex
  metacharacter in the interior (`. [ ] ( ) * + ? { } | ^ $`) is backslash-escaped, the string
  starts with `^` and ends with `$`. This is the shape the round-41 C1 gate's R3 rule
  (`corpus/expect-journal.sh`, to be built by K41ExecJournal) requires. Escaping matches the
  round-40 precedent exactly (`\\(` and `\\)` in the JSON source for the census rows).
- `outside_population_untouched` lists the inherited rows outside the frozen set, carried from
  the round-40 journal; all eight ids were confirmed present in the 5142b52 ledger
  (`grep -c "^<id>\t" corpus/claim-ledger.tsv` = 1 for each).

## 8. What this seat did NOT do

- Did not edit `corpus/SOURCES.md` or `corpus/source-fetches.tsv` in the lane; the rows are
  drafts for the L1 to copy.
- Did not write `corpus/lessons/round-41.md` (K41ScribeLesson owns it) and did not add the
  round-41 SCORECARD headings (same owner). The sandbox stand-ins are named as stand-ins
  everywhere they are used.
- Did not run `bash corpus/claim-ledger.sh verify` (the one-run allowance was not needed).
- Did not build or run the C1 gate `corpus/expect-journal.sh` (K41ExecJournal owns it); the
  draft journal is written to its frozen R3 shape but is not gate-verified by this seat.
