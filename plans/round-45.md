# Round 45 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `0d0192f63eb5e49826d75af1e5293004dc691a18` (branch `master`).
Counters: `plans/round-45-c1.sh`, `plans/round-45-c2.sh` (frozen; predicate sentences below are the
same sentences as the counters' header comments). Do-nothing / BASE receipts:
`.ufo/waves/round-45/controls/` (`c1-base.txt`, `c2-base.txt`, `census-start.txt`,
`claims-declared-base.txt`, `quote-locate-base.txt`). Predeclaration commit: recorded in the report.

Stagnation check (AXES.md, SCORECARD saturation): all six axes sit at the saturation line 9; the last
capability row entered in round 39 (`declared-axis conformance`, `anchor-pin drift detection`), so the
window N=3 is exhausted and the stagnation nudge waives the lowest-axis obligation. This round is a
frontier/coverage move (C2) plus an instrument move (C1). No axis is retired or split.

## C1 — calibration: the declared-claim manifest is a bijection with landed plan headings

Problem (measured): `corpus/claims-declared.sh` walks manifest rows only. A plan heading
`## C<k> — <axis>:` with a SCORECARD post-move row and no manifest row passes CLEAN. Round-44 routed
this as M44-9 / Routed 2. Rounds 36–38 carry untagged or manifest-less claims; the round-39 scope
names them a history gap (not claimed here).

Frozen predicate: `C1_BIJECTION: value = DETECTED when POSITIVE = 1 and REAL = CLEAN, else 0; target 2.`
- DETECTED: fixtures A and B (planted omissions: a landed round-90 claim with no manifest row; a whole
  round-90 landed claim with no manifest rows) each reported MISMATCH by the gate.
- POSITIVE: fixture C (plan heading axis differs from the manifest axis) still MISMATCH (gate alive).
- REAL: the gate exits 0 on the real tree at the measured revision (no false positive; rounds 39–44
  already carry manifest rows matching their landed headings).
- Scope of the new direction (frozen): a round R ≥ 39 is checked when `plans/round-R.md` carries claim
  headings AND SCORECARD carries `## Round R — post-move`. An in-flight round (no post-move section) is
  not yet a landed claim and is not checked. Rounds < 39 stay out of scope (manifest history gap).

BASE measured: `bash plans/round-45-c1.sh LANE` → `value=0 detected=0 positive=1 real=CLEAN`
(rc A=0 B=0 C=1). Kill rules (frozen): C1 is killed if REAL is FAIL at the candidate, if POSITIVE is 0,
or if the candidate reports a MISMATCH on any real round ≥ 39 that lacks a named defect. The value is
not allowed to rise by loosening fixtures A/B after this commit.

Target: value 2 at the candidate.

## C2 — coverage: one assimilated ISO/IEC 11770-3 knowledge entry with located quotes

Problem (measured): `corpus/knowledge/` has no entry on the ISO/IEC 11770-3 key-management mechanism
standard, its edition/supersession status or its adoption by GB/T 17901.3. The lane's core holds NIST
SP 800-57 and SP 800-133 status (`PROVINCE.md` §Core round 33); the international mechanism standard
that the Chinese national adoption draws on is held nowhere (`grep -l '11770' corpus/knowledge/*.md` → 0).
The theme is staged by `corpus-expansion-1` in `shokuknow/merge/kagi/` (MERGE-REPORT rows
`iso-11770-3-2015-supersession-chain-r39.md`, `iso-11770-3-catalogue-record-and-lifecycle-r41.md`).

Frozen predicate: `C2_LOCATED: value = LOCATED when census=0, entries ≥ 1 and LOCATED ≥ 3; else 0;
target 3.` ADDED = registry ids added after BASE; LOCATED = quote-bodies rows for ADDED ids that
`corpus/quote-locate.py` does not report NOT-LOCATED, against committed capture bodies.

BASE measured: `value=0 added=0 entries=0 census=0 located=0` (`controls/c2-base.txt`).
Kill rules (frozen): C2 is killed if the census is not 0, if any admitted entry quote is NOT-LOCATED
against its committed capture, or if an admitted entry cites a staged id that was not re-opened this
round (sourced-claim duty: CORPUS.md rule 1). Refused staged rows keep reason + flip in the lesson.

Assimilation contract (plan-level): the staged rows are campaign ids; any id that collides with a
lane id (S052–S099 are held) is renumbered BY DOCUMENT to the next free lane ids (S100 onward), never by
arithmetic. The collision guard is the §6 grep pair with its own red witness. Quarantine slice (register
rows for kagi, staged ids S053, S071, S081, S090, S091, S093, S108, S113): not appended unless
hand-checked this round; the admitted entry's citation set is checked against that slice and the
verdict is recorded in the lesson.

Target: value 3 at the candidate (one entry, three or more located quotes).

## Mistake mined (lesson §Mistakes; frontier step 3)

M45-1 — class `landing` (round-44 closure D2): round 44's stamp migration reported the stamp verdict
stale because of three gate scripts and attributed four other changed rows to round 44; at BASE the
closure measured seven stamp rows out of step (`LOG.md`, `SCORECARD.md`, `corpus/QUALITY.md`,
`corpus/SOURCES.md`, three scripts). Captured-by: none. Fix: an appended, named erratum (PROTOCOL
§Evidence standard) plus a stamp-drift red witness: a scratch copy with one stamped file altered must
count DRIFT ≥ 1, the unaltered tree 0. A fix counts only once that red witness reads non-zero.
Current tree: stamp drift 0 (measured 2026-11-05 by sha256 over `corpus/stamps.tsv`); the erratum is the
remaining item.

## Routed items from round 44 (closure `corpus/lessons/round-44-verifier-spotcheck.md` §5)

1. Stamp migration undercount → M45-1 above (erratum + red witness).
2. Red-witness label `C2 clean four-line receipt at BASE (expect 0: gate absent at BASE? see note): 1` →
   restated by appended correction (the gate was present at d54109d; a valid receipt over a present gate
   reads 1 by design). Appended, not rewritten.
3. Mistake classes outside the vocabulary → lesson table maps each class to the `mistakes.md` §5
   vocabulary in the round-45 lesson; the round-44 table is not rewritten.
4. Unopened candidates → moved to `corpus/SOURCES.md` `## Leads (unopened)` as bullets (no rows).
5. Wave composition (no scribe seat in round 44) → round 45 wave includes one scribe; deviations named.
6. Carried, unchanged: B1 (battery always-refuse conjunct), round-40 report erratum, revenger SEAT-STATUS
   line, scheduling of `corpus/controls-replay.sh` (operator scope). Named, not claimed.
7. Considerthese `2026-10-26.md`: proposal 3 (mark known-defective instrument output) lands as a QUALITY
   criterion citing `considerthese/2026-10-26.md` and the S052 row (`Python 3.15.1.` is a title with
   sentence punctuation that the release clock silently drops, `corpus/release-clock.py` $-anchored
   tokens). Proposal 1 is operator policy under HOLD (lifted at run 15) and is not taken.

## Wave contract (one v1 build wave, 11 seats; policy `scripts/hyaku/ufo-wave-policy.json`, band 8–16)

Roles: connector ×1, executor ×3, scout ×1, scribe ×1, reviewer ×1, critic ×1, mutation-tester ×1,
sentinel ×1, revenger ×1. Attack seats (reviewer, critic, mutation-tester) = 3/11 = 27 %. Labrat and
planner are frozen topology and are not swarm roles; the L1 holds the planner duty. No residual call.
Seats write only under `.ufo/waves/round-45/` (absolute paths under the lane) and scratch
`$HYAKU_SCRATCH/kagi-r45/<seat>/`; they never commit, push, or run a mutating git/jj command.

## Declared ceilings (named, accepted as stated)

- C1 checks claim headings and SCORECARD tags; it does not judge axis fit (`claims-declared.sh` QM41).
- C2 checks committed capture bodies only; it does not re-fetch a live page. The live re-open is the
  sourced-claim duty, recorded in the lesson's Gate with access dates and ≤25-word located quotes.
- A standards page's withdrawal status is the page's own claim, not an independent verdict.

## Frozen

Frozen at the predeclaration commit. No predicate, counter, target or kill rule changes after any seat
has scored; a change is an L0 question and a named amendment, not a silent edit.

## Amendment A1 (predeclaration, before any candidate is measured; named by the wave's pre-freeze attacks)

Filed by the L1 after the build wave's pre-candidate attacks (reviewer `K45ReviewerPlan`, critic `K45CriticClaims`, mutation-tester `K45MutBattery`, all at 307fb50d; no candidate exists and no candidate has been scored). Each item changes an instrument or a sentence; none changes a target.

- **A1-1 (critic D-1, stagnation premise):** the last capability row in SCORECARD's table has first-working round 40 (SCORECARD table, "The latest first-working round in this table is 40"), not 39. Rounds 41–44 are capability-less; the window N=3 is exhausted; the nudge fires. The stagnation sentence above is corrected to read round 40 and window 41–44.
- **A1-2 (reviewer F-1 HIGH, critic D-5, C2):** `value` also requires `quote-locate.py` exit 0. Kill rule added: C2 is killed if the locator exits non-zero at the candidate. Reason: a SETUP exit with no NOT-LOCATED lines previously counted every ADDED row as located.
- **A1-3 (reviewer F-4):** the negative-located floor is removed; a negative value cannot be produced by correct parsing and is not floored.
- **A1-4 (reviewer F-2, MED):** fixtures carry no shared header marker (no `# fixture` line), so a gate keyed on that marker cannot satisfy the counter. Ceiling named: a gate keyed on the synthetic round numbers 90 and 91 is not refused by the fixtures; the REAL leg (real tree CLEAN) and the gate's committed `--selftest` are the remaining legs and must both pass at the candidate.
- **A1-5 (reviewer F-6, portability):** the counter runs the gate with `bash`, not `sh`; gate output is captured and its last line is printed in the receipt (reviewer F-3).
- **A1-6 (critic D-3, universal exception):** the phrase "that lacks a named defect" is removed from the C1 kill rule. C1 is killed if REAL is not CLEAN at the candidate, or if DETECTED is below 2 at the candidate (critic D-6).
- **A1-7 (critic D-4, gameable in-flight scope):** ceiling named: a plan carrying claim headings with no SCORECARD post-move section is not checked by either direction. The carve-out stays (round 45 itself is in flight at the candidate). Catch-up: once round 45's post-move section lands, round 46's and every later run audits round 45 mechanically; any round-45 MISMATCH after that is a round-46 finding.
- **A1-8 (critic D-2, C2 boundary and provenance):** C2's scope is the status and supersession of ISO/IEC 11770-3 only. KMS-managed credential lifecycle (round 34, `PROVINCE.md` core) and the lifecycle requirements that ISO excludes are not in scope and are not claimed. The admitted entry is self-contained: every factual premise it uses is cited and re-opened this round; the staged "lane frontier item — NIST" provenance is rewritten to the lane's current core status (round 33), not copied. Renumbering is by document from S100; the registry's next free id is taken after the append is composed, so no staged-reserved id is reused.
- **A1-9 (ExecISO finding, live source):** the archived ISO catalogue snapshot (S170, web.archive.org) timed out at 30 s in this round; the live catalogue page https://www.iso.org/standard/60237.html was fetched as the body for S170 quotes. The registry row for the admitted entry names the live URL it cites and the archive attempt as failed. Quotes are located only in bodies that were fetched this round.

Frozen counter text after A1: `plans/round-45-c1.sh` and `plans/round-45-c2.sh` at the amendment commit. BASE values after A1 are the same (`controls/c1-base.txt` value=0; `controls/c2-base.txt` value=0), re-run and recorded.
