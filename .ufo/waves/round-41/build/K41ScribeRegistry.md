# K41ScribeRegistry - round 41 (kagi, attempt 1)

Seat: ScribeRegistry. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Predeclaration commit (frozen plan + counters + BASE controls): `5142b52`.
Claim BASE: `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`.
Round-40 landed state (positive control P0 of C1): `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`.
Round-40 claim BASE: `6cc8850dfc5757927699e5a53a876f47c8df21aa`.
Tooling installs: **none** (no pacman/uv/cargo install; `curl`, `python3`, `git`, `sha256sum`,
`wc`, `cmp`, `grep`, `awk` were all present).

## Deliverables

All under `.ufo/waves/round-41/build/K41ScribeRegistry/` (lane-relative):
`rows.md`, `fetch-rows.tsv`, `census-sandbox.txt`, `rowidentity-sandbox.txt`,
`expectation-migrations.draft.json`, `opens.txt`, `notes.md`, `capture/S097.body`,
`capture/S098.body`. The two capture bodies are also at `.ufo/waves/round-41/capture/`.

## What was executed

**Live opens (2026-11-05, this seat, CORPUS.md rule 1).** `curl -fsSL --compressed`, exit 0 both:

| id | url | http | title | sha256 | bytes | locate |
|---|---|---|---|---|---|---|
| S097 | docs.python.org/3/library/stdtypes.html | 200 | `<title>Built-in Types &#8212; Python 3.15.2 documentation</title>` | `e2992e17…48466e2b3` | 815447 | exit 0, count=1 |
| S098 | unicode.org/reports/tr18/ | 200 | `<title>UTS #18: Unicode Regular Expressions</title>` | `68e34b8b…8c70d` | 199607 | exit 0, count=1 |

Both bodies are byte-identical to the scout's staged copies (`cmp` exit 0) and to a second
fetch under the declared profile `-A 'kagi-shokunin-round23/1.0 (documentation verification)'`.
Collision guard before drafting: duplicate-id scan empty; `grep -c 'S097\|S098'` -> `0`.

**Rows.** S097 (docs/A/mined/2026-11-05/90d) with the located `str.isspace()` quote; S098
(spec/A/rejected/2026-11-05/on-release, the S030 recheck form) with `REJECTED:` and `flip:`.
Both parse as 11 columns, no literal or escaped pipe, no newline (asserted programmatically).
Fetch rows for both in the 16-column S095/S096 layout with the census's own
`row_identity_sha256` rule (verified against S095/S096 first).

**Sandbox validation** (two clones, `git clone --shared` + `checkout --detach 5142b52`,
toplevel asserted before every write). The FINAL pass applied the DELIVERED `rows.md` and
`fetch-rows.tsv` (extracted programmatically from the delivered files), the two capture bodies,
and the REAL K41ScribeLesson lesson draft, to a fresh clone:

```
bash corpus/sources-census.sh          -> SOURCES_CENSUS: CLEAN (rows=98 A=94 B=2 C=2 queued=1 mined=93 rejected=4 entries_sourced=14 legacy=21 captures=98 inrow=16 inrow_only=0 inrow_nonreproducing=12)   exit 0
grep -c '^## Round ' SCORECARD.md      -> 56   exit 0
bash corpus/row-identity.sh scorecard-rounds -> ROW_IDENTITY: scorecard-rounds count=56 sha256=230992d31dbbc54f30ff0b1e530ba4816355f20bab167bcda85aadd3dc8c77ab   exit 0
bash plans/round-41-c2.sh              -> 3   exit 0   (with the K41ExecDocs Sources paragraph)
```

Baseline at 5142b52: `CLEAN (rows=96 … captures=96 …)` exit 0; headings 54;
`count=54 sha256=52e7ba8d…`. The delivered artifacts reproduce these readings from the
delivered files themselves; the first pass with a stand-in lesson file gave the same three.

The S097 row does not break the counter's "no cited id is superseded" term.

## Routed defects (not fixed in the lane)

1. **The brief's `used-by` for S097 fails the census.** `corpus/rendered-text-v1.py (round 41 C2)`
   yields `FINDING SC_USEDBY_MISSING path=…` + `FINDING SC_USEDBY_MISSING S097: … not a repo
   corpus path`, census exit 1. Draft uses `corpus/lessons/round-41.md` (the S095/S096 form).
2. **RESOLVED - the S097 row needs K41ScribeLesson's lesson file to cite it, and it does.**
   Without the file: `FINDING SC_USEDBY_MISSING path=corpus/lessons/round-41.md`; with the file
   but no S097 on its `source:` line: `FINDING SC_USEDBY_NOCITE id=S097 path=corpus/lessons/round-41.md`
   (both census exit 1). K41ScribeLesson's landed draft's `source:` line cites S097 and S098;
   re-measured with that real file: census CLEAN rows=98, exit 0.
3. **R24-06's `new_expect` digest is heading-text sensitive - STILL OPEN.** `scorecard-rounds`
   hashes the heading lines, so the draft digest `230992d3…` (measured against a stand-in
   heading pair) will change when the real round-41 headings land. The count 56 is stable; the
   digest is not. No delivered draft fixes the heading text: K41ScribeLesson's
   `scorecard-round-41-pre.md` carries an H1 `# SCORECARD — round 41 pre-move …` and no
   `## Round ` heading, and its notes leave the post-move table to the L1 (slot 11). The L1
   must re-measure R13-01 and R24-06.
4. **The census summary in the migration draft is stand-in-conditioned.** `rows=98 … captures=98`
   was measured with a stand-in lesson file and stand-in SCORECARD headings; re-measure at the
   landing tree.
5. S097 is a new grounding, not a `supersedes S095` correction - a supersession claim would have
   made the C2 counter's term (a) read 0.
6. **The lesson seat's S097 quote differs from this seat's - both locate.** The lesson uses the
   `str.isspace()` result sentence ("Return True if there are only whitespace characters in the
   string and there is at least one character, False otherwise."); this seat uses the
   class-defining clause ("either its general category is Zs (“Separator, space”), or its
   bidirectional class is one of WS , B , or S ."). Both locate count=1, exit 0 against
   `.ufo/waves/round-41/capture/S097.body`. This seat's choice is the clause that grounds the
   step-5 whitespace CLASS, which is what the C2 claim is about; the lesson's Gate records the
   same class-defining clause separately at raw offset 296702. The L1 picks one.
7. **The lesson's second S098 ground is confirmed.** The literal `\p{White_Space}` does not occur
   in the served body (`grep -c 'p{White_Space}'` -> 0, exit 1) - which is why this seat's S098
   row quotes the Annex C `space (\s)` entry the body DOES carry. Both drafts agree on the
   verdict. The rejection arithmetic is independently confirmed by the labrat probe
   (`probe.txt`: `A_minus_B_count: 4`, members U+001C..U+001F, `B_minus_A_count: 0`).

## Migration journal draft

`expectation-migrations.draft.json` mirrors `.ufo/waves/round-40/expectation-migrations.json`
(`round`, `measured_at`, `kind`, `population`, `migrations[]`, `outside_population_untouched`),
covering exactly R13-01, R24-06, R21-02, R31-02, R33-02, R34-03. `old_expect`/`command` for
all six compare EQUAL (byte-for-byte) to `git show 5142b52:corpus/claim-ledger.tsv`.
`new_expect` is the measured value as a fully literal anchored expression (every interior
metacharacter escaped, `^`…`$`), matching the round-40 escaping. Not gate-verified here: the
C1 gate `corpus/expect-journal.sh` is K41ExecJournal's to build.

## Not done (out of scope for this seat)

No lane edit to `corpus/SOURCES.md` or `corpus/source-fetches.tsv` (drafts only); no
`corpus/lessons/round-41.md` and no SCORECORD headings written in the lane (K41ScribeLesson
owns both); no `claim-ledger.sh verify` run; no C1 gate built or run.

Report: `.ufo/waves/round-41/build/K41ScribeRegistry.md`
