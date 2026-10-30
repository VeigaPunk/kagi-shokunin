# Round 29 — feed-token right boundary: no silent drops; differential agreement gate

Frozen BASE: `c49023b773b69de983f0e6eb7e5867ceb5c2c634` (lane tip after the
round-28 documentary close and two `considerthese` reflections; local=remote,
ahead=0). START census ran first and is retained at
`.ufo/waves/round-29/census-start.txt` (exit 0, 14 `W04` duplicate-url
warnings — the registry is unchanged since round 28's end census).

All six axes sit at 9; the saturation line is 9 with stagnation window N=3
(rounds 26, 27, 28 completed with no capability entering the table; the last
capability entered round 25). The stagnation nudge (AXES.md) therefore fires
this round and waives the lowest-axis obligation: **C2 is the
frontier/capability move**, a new runnable artifact entering the SCORECARD
capabilities table. C1 closes the defect routed from round 28
(report §Work performed item 1; `corpus/lessons/round-28.md` §Attempt-3
corrigenda 1), whose BASE behavior this plan verified by direct probe:

- title `Python 3.15.01.` beside older `Python 3.15.0` → parse returns
  `3.15.0` (newer non-canonical token silently dropped, run can print CLEAN);
- title `Python 3.15.1.` alone → `feed has no stable X.Y.Z release entry`
  (canonical release invisible);
- text `Version: 8.23.01.` → `text release file has no Version: X.Y.Z line`
  (wrong typed error, token unnamed);
- href `/releases/tag/v3.15.1.` beside `v3.14.0` → returns `3.14.0`;
- exact-title control `Python 3.15.1` → `3.15.1`.

## C1 — freshness, 9 → 9 (routed D1 closure; sourced)

`corpus/release-clock.py`: the three feed extractors
(`STABLE_TITLE_RE`, `STABLE_TAG_HREF_RE`, `TEXT_VERSION_RE`) are
right-anchored with `$`/`[ \t]*$`, so a version token carrying sentence
punctuation is silently dropped by the extractor that should surface it to
`newest_stable` — the refusal path (typed `NON-CANONICAL`, exit 1) never runs,
and a canonical period-suffixed release is invisible. After: all three
extractors take their right boundary from the one `STABLE_TOKEN_RE` already
uses — `(?![A-Za-z0-9+-]|\.[0-9])` — exactly as routed
(`corpus/lessons/round-28.md` §Attempt-3 corrigenda 1); the two selftest
pairings the recipe names land with it (one positive: canonical
period-suffixed feed entry is observed; one negative: non-canonical
period-suffixed feed entry is typed `NON-CANONICAL`). Sourced: registry row
S052 (RFC 4287 §4.2.14, opened this round — an Atom entry title is a text
construct, so a trailing period is content, not a token boundary) cited by the
new knowledge entry; S045 (SemVer §2) grounds canonicality, unchanged.

Frozen counting command (written this round, then never changed):

    python3 -I -B .ufo/waves/round-29/tools/c1-measure.py <rev> <label> <out.json>

Frozen fixture set, built on `<rev>`'s own tree (offline bodies, no network):
- NF1 title-period-noncanonical: Atom feed, titles `Python 3.15.0` and
  `Python 3.15.01.`. Correct behaviour: typed `NON-CANONICAL` naming the
  token, exit 1.
- NF2 title-period-canonical: Atom feed, single title `Python 3.15.1.`.
  Correct behaviour: observes `3.15.1` (receipt written, no finding).
- NF3 href-period-noncanonical: Atom feed, links
  `/releases/tag/v3.14.0` and `/releases/tag/v3.15.01.`. Correct: typed
  `NON-CANONICAL`, exit 1.
- NF4 text-period-noncanonical: plain-text body `Version: 8.23.01.\n`.
  Correct: typed `NON-CANONICAL` naming the token, exit 1.
- NF5 title-comma-prose: Atom feed, titles `Python 3.15.0` and
  `Python 3.15.1, out now`. Correct: observes `3.15.1`.
- NF6 title-prerelease-sibling (control): single title `Python 3.15.1rc1`.
  Correct: refused by every extractor — `feed has no stable X.Y.Z release
  entry` (unchanged at both revisions).
- NF7 four-component-sibling (control): single title `Python 3.15.1.2`.
  Correct: refused by every extractor (unchanged at both revisions).

Predicate: a fixture is MISHANDLED when it exits 0 with a newest-stable
result that ignores a present canonical-or-non-canonical token of the fixture,
when its output contains `Traceback`, when a canonical token is invisible
(NF2/NF5 read as no-release), or when a non-canonical token is not named
(NF4's wrong-typed error). It is CORRECT when NF1/NF3/NF4 exit 1 typing
`NON-CANONICAL` and NF2/NF5 observe the canonical token, with NF6/NF7 refused
identically at both revisions. Regression: the round-28 counter replayed at
`<rev>` keeps `MISHANDLED 0/4`, `TYPED 4/4`, and the instrument selftest
count grows only by the recipe's two cases (114 → 116).

Before (BASE `c49023b`) → after (measured rev): MISHANDLED 5/7 → 0/7
(NF1–NF5; NF6/NF7 refused-controls at both), CORRECT 2/7 → 7/7, regression
green. Do-nothing control (unmodified tree through the frozen counter) fails
the after-target by construction — the receipt is committed before any
candidate code (§9).

## C2 — capability acquisition: differential feed-token agreement gate

New runnable artifact `corpus/feed-token-agree.py` (grounds
`considerthese/2026-10-25.md` proposal 1: run one corpus of token shapes
through every feed extractor and assert they agree on extracted-vs-refused —
"one scanner trusting a token shape another scanner never extracts" becomes a
standing check instead of a one-off fix). The gate imports the live
`corpus/release-clock.py` extractors (never copies them — reference-drift
class), runs a fixed shape corpus (trailing period, comma-prose, `)`,
leading zeros, 19-digit component, prerelease, build metadata, 4-component,
`v`-prefix, two-component, series-`x`, plain) through all three feed
extractors in their natural wrappers (Atom title, tag href, text `Version:`
line), and fails (exit 1, naming shape and extractors) when any extractor
surfaces a different token or a different extracted-vs-refused decision than
the others for one shape. Exit 0 prints `FEED_TOKEN_AGREE: AGREE (shapes=N
disagreements=0)`; exit 2 is SETUP; `--selftest` runs the corpus against a
deliberately divergent in-memory extractor and requires DISAGREE ≥ 1 (the gate
is shown able to fail). Hermetic: no network, no host-private reads; failures
counted in the verdict line (QM3); no substrate contact (QM4).

Frozen counting command:

    python3 -I -B .ufo/waves/round-29/tools/c2-measure.py <rev> <label> <out.json>

Frozen measures (each a boolean, all four required):
- M1 gate present at `<rev>` and runnable (`--help` exit 0);
- M2 `--selftest` PASS with the seeded divergence caught;
- M3 live run over `<rev>`'s instrument: `AGREE`, exit 0, disagreements=0;
- M4 red-before witness: the same gate run against a scratch copy of the BASE
  instrument exits 1 `DISAGREE` naming a suffix shape (the round-28 D1 class).

Before (BASE): M1 false (no artifact), M4 true-by-demonstration (a gate built
to the frozen contract DISAGREEs on the BASE extractors — the D1 witness).
After (measured rev): M1–M4 all true. The capability row enters the SCORECARD
capabilities table only on the measured after-state. Do-nothing control: a
tree that adds the gate file but not the C1 boundary change fails M3/M4 —
committed as receipt (§9).

## Frontier step (inside the cap, not a claim)

- Curate `corpus/SOURCES.md`; new row S052 only after opening RFC 4287 this
  round; Gate in `corpus/lessons/round-29.md` (URL, access date, ≤25-word
  located quote). Re-opened rows' used-by changes are logged old→new.
- Mine a mistake: the D1 scanner-extractor disagreement class
  (`corpus/lessons/round-29.md` §Mistakes, fix = the C2 gate, shown able to
  fail by M4/M2).
- START census retained at `.ufo/waves/round-29/census-start.txt`; END census
  exit 0 required.

## Boundaries

C1 changes `corpus/release-clock.py` (three regex lines + two selftest cases,
nothing else — simplifier seat enforces minimality). C2 adds
`corpus/feed-token-agree.py` plus wave tools under `.ufo/waves/round-29/`.
Shared bookkeeping (selftest count 114→116, stamps, ledger pins, lesson,
scorecard, knowledge entry, SOURCES row) is integrated atomically by the L1;
claim-only overlays demonstrate separability (C1 verifies without the gate
file; the gate verifies against BASE, red, as M4 shows). Seats write only
under `.ufo/waves/round-29/` and their own scratch; the L1 is the sole
production integrator and the only committer. No vault/account/handler/CDP
action, no network writes, no Git/jj mutation by seats.

## Wave shape and policy note

Run-13 snapshot band in this round's prompt: 16–32 seats, one v1 wave. The
live policy file was amended mid-run (2026-10-30 15:22 −03, 34 s after this
round's dispatch) to band 32–48 with a grandfather clause for pre-amendment
dispatches. This round sizes **one v1 wave of 32 seats** — the intersection:
top of the snapshot band, floor of the live band, valid under both readings.
≥25 % attack seats (16/32 = 50 %), two connector seats, residual none. The
§3 floor rides inside the wave: planner = L1 (canonical), connector 2,
executor 5, scribe 2, scout 5, reviewer 7, critic 4, mutation-tester 3,
sentinel 2, revenger 1, simplifier 1. `labrat` is frozen topology (swarm
skill) and is not spawned; its probe work rides scout items.

## Assimilation

`Assimilation: none` this round — the round is fully committed to the routed
D1 closure and the nudge capability move; `merge/kagi/` rows remain staged
for a later round. `considerthese/2026-10-25.md` proposal 1 is mined (C2);
2026-10-26 suggestions 2–3 (machine-readable lane status, KNOWN_DEFECT
marker) are noted for the operator/HOLD path, not implemented here.

Plan corrections, if any, are appended below this line and never rewrite the
frozen text, the fixtures, the predicates or the counting commands.
