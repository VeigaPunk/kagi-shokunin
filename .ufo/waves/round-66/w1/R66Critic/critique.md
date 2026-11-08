# R66Critic — falsification of round-66 predicates C1/C2/C3 (pre-counter)

Seat: R66Critic (critic). Scope: attack the frozen predicates in
`plans/round-66.md` before any counter exists. Read-only on lane source;
this file + `R66Critic.md` are the only writes. BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`; HEAD under test
`ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca` (plan freeze) plus untracked
`claims.json` + base censuses. No `plans/round-66-c*.sh` exists yet.

Methods: predicate-to-observation trace; BASE `git archive` reads;
do-nothing / path-only / stale controls simulated against measured
tree facts. Nothing below was executed against a candidate counter
(no counter to run). Each finding names the smallest safe correction.

## Axes under test

- C1 freshness: S148 carrier binds by digest (0 → 1). Predicate
  `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=G`.
- C2 operability: round-66 `claims.json` matches frozen plan
  (exact 0 → 1). Predicate `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3`.
- C3 calibration: registry self-reference literals resolve
  (failures 1 → 0). Predicate `C3_SELFREF: resolved=1 checks=3 failures=0`.

Mutual reading: C1 and C3 bind the same citation (S148 → round-64
capture). All three predicates claim to be separately falsifiable;
the evidence below says each has a do-nothing, vacuity, or population
hole as currently worded.

## C1 — five independent falsifiers

### F1 (do-nothing / K2 self-contradiction; strongest counterexample)

The plan's own carrier repair (§C1 "Carrier repair") is: point SOURCES
anchor, fetch col16, and volatile-shape `DEFAULT_CAPTURE` at the
committed `.ufo/waves/round-64/capture/S143.body` whose bytes already
equal the S148 pin `3b8d4e159a…cba40` (measured:
`sha256sum …/round-64/capture/S143.body` = `3b8d4e15…`, 264946 B).
No bytes change. But kill rule K2 says "a path-only edit
(carrier-path string repointed, no bytes changed) reads `drift=0
match=0` — the do-nothing control cannot reach the target." By the
plan's own definition the planned repair IS a path-only edit, so the
candidate reads drift=0 by K2. K2 as written voids the repair it is
supposed to bless. The intended distinction ("digest binding refuses
the wrong-id file") requires a header-ID mechanism that is not
defined anywhere in the plan or tree: fetch columns are
id/status/row_identity/url/final_url/http_status/request_profile/
fetched/representation/sha256/bytes/revision/quote/normalization/
normalized_sha256/location. `row_identity_sha256` binds
id+status+URL, not body bytes; it is invariant under the path-only
edit, so "header-ID digest still resolves" (match=1) is trivially
satisfied by the very edit K2 must refuse. Without naming which
column is the header-ID, hex/match are unmeasurable.

Smallest safe correction: define the binding explicitly as
"fetch-row sha256 (col10) equals the cited file's sha256" and
restate K2 as "a repoint to a path whose bytes digest differs from
col10 reads drift=0" (e.g. repoint to `S148.body` = `fabc74c5…`
arXiv body). Under that restatement the planned repair passes
because the bytes already match, and the mutation legs (wrong bytes)
fail. Freshness-vs-novelty consequence: the claim then measures a
registry citation that was already true in the bytes (volatile-shape
already pointed there at BASE; see F4) — legitimate as a binding
claim, but it must be named as citation-repair, not new
re-verification.

### F2 (population vacuity: mutated bodies have no pins; S148 not mutated)

`paths=3`: mutated copies hold round-64 bodies S143/S156/S157 "at a
wrong id", `hex=3`: each mutated sha differs from the candidate
body's sha. Measured facts: S156 has a registry row (rejected, pin
`037c2dbe…` 899 B 429 body) but the round-64 `S156.body` file is
20845 B FAQ HTML sha `ccf6ac49…` — file and pin are already
disjoint; S157 has NO registry row at all (`grep -c S157
corpus/SOURCES.md` = 0) and no fetch row (fetch table: 153 rows,
S156/S157 absent). Their "expected digests" do not exist, so K3
("each mutated copy prints a named digest-mismatch line") has
nothing to name a mismatch against. Worse, the claim binds S148,
yet S148's own body (`S148.body` = `fabc74c5…`, measured) is not
among the mutated bodies. The strongest counterexample available:
copy round-64 `S143.body` bytes (sha = S148 pin) to a wrong-id path
e.g. `S148.body` — hex≠candidate only if candidate body means
"bytes at the S148-named path", which is the arXiv body, not the
pin. A wrong filename holding exactly the right bytes reads
hex=3+match=1 under any filename-blind digest check; digest binding
by construction cannot detect a wrong filename. The predicate
measures the opposite of what it claims.

Smallest safe correction: mutate S148 itself (arXiv body vs BioC
body) and mutate citing S143's round-63/round-64 pair; drop S156/S157
or ground them in committed pins (S155 captured xml). Require the
counter to compare against fetch-row col10 AND SOURCES pin, not
against "candidate body sha" alone.

### F3 (separability: C1 guard(a) ≡ C3 facts; N-1 anchors pre-satisfied)

Guard (a): on the unmutated candidate "the counter resolves the
S148 body's capture path by digest from the registry row and reads
drift=1 on all three anchors". The three anchors are SOURCES row,
fetch col16, volatile-shape `DEFAULT_CAPTURE`. But volatile-shape
`DEFAULT_CAPTURE = ".ufo/waves/round-64/capture/S143.body"` with
`PIN_SHA = 3b8d4e15…` already holds at BASE (verify:
`git show d549ee6:corpus/volatile-shape.py` lines 50/53; `VOLATILE_SHAPE:
match=1` read live). So 1/3 of C1's "repair" is already landed at
BASE (round-65 M65-4 fix). C1 as scored measures 2 changed strings
+ 1 pre-existing binding, while C3 with `checks=3` over the same
three stands measures the identical citation delta. Freshness and
calibration are then not distinct claims: landing C3's registry
repair implies C1 guard (a), and C1's repair is C3's pass condition.
At minimum the admitted novelty is 2 anchors, not 3, and the axis
split is bookkeeping, not measurement.

Smallest safe correction: either merge C1/C3 into one citation
claim on one axis, or give C1 a freshness-only leg the calibration
claim cannot imply (e.g. live re-open digest quoted with access
date, scored as `live_status`-reported, never decisive — the plan
already concedes this in "Named ceilings", so the executable core of
C1 is citation again).

### F4 (stale content / BASE already half-true; guard(c) dependency)

Guard (c) requires `VOLATILE_SHAPE: match=1` on the candidate —
already true at BASE and independent of the repair. Guard (d)
requires `SOURCES_CENSUS: CLEAN` — already true at BASE (census-start
`kagi ok`). So 2/4 guard legs are pre-satisfied; C1's delta is
narrower than the predicate suggests. This is not itself fatal,
but reviewers must not count pre-satisfied guards as repair evidence.
Census-c1.md itself says the cited-set check "passes vacuously" for
S148 at BASE and "a do-nothing control (row edited to cite a
different carrier path) reads 155 still and no lane gate reads the
delta" — i.e. the current census cannot detect the drift the claim
exists to close. The census is the wrong instrument to cite as
baseline; the counter must replace it, and the plan should say so.

### F5 (arbitrary binding of a drifted name; QM88)

The repair pins the registry to the draft-id filename `S143.body`
(under round-64) while `S143.body` also exists under round-63 with
different bytes (`8522a79e…`, S143's true pin) and S143's fetch
col16 names the round-63 path. "The binding changes, not the
filename" freezes the M65-4 drift as the canonical citation. A
future reader following S148 lands on a file named for S143 that
round-63 named for S143 with different content. The digest makes it
locally unambiguous (3b8d… vs 8522…), but the predicate rewards
preserving the exact confusing property (id-named file ≠ registry
id) that motivated the claim. This is defensible only if the
counter also asserts the round-63/round-64 S143.body pair are
disjoint by digest and the round-64 file is named as a supersession
artifact. The plan names this only in prose, not in the predicate.

Smallest safe correction: add to guard a digest-disjointness check
(round-63 vs round-64 S143.body differ) so the binding is not
accidentally re-pointed at the same-named earlier bytes.

## C2 — falsifiers

### F6 (do-nothing control reaches the target; BASE misdefined)

"BASE 0" is "measured over the round-65 claims.json against
plans/round-65.md". The scored artifact is round-66 `claims.json`
vs round-66 plan. The current untracked round-66 `claims.json`
(read live) already matches the frozen headings exactly:
C1 freshness "the S148 carrier binds by digest on the registry
row's own terms" vs plan heading `## C1 — freshness: the S148
carrier binds by digest on the registry row's own terms`, likewise
C2/C3 (titles in claims.json carry the frozen `C1_CARRIER:`/
`C2_CLAIMS:`/`C3_SELFREF:` prefixes). At BASE `d549ee6` the path
`.ufo/waves/round-66/claims.json` does not exist at all (BASE
archive: round-63/64/65 claims.json only). A counter run over
BASE + plan + the already-written claims.json reads exact=1 with
zero candidate work. C2 therefore lacks a BASE-side counter reading
on the same artifact pair — exactly the M65-1 vacuity class (target
a do-nothing control already reaches). The round-65 measurement is
irrelevant to whether round-66 work moves anything.

Smallest safe correction: re-define BASE 0 as "claims.json absent or
pre-amendment" on the round-66 pair (e.g. strip the `C1_CARRIER:`
prefixes, or pair round-66 claims vs round-65 plan) and score the
counter on the round-66 pair from that start. The candidate work is
"write claims.json exactly" — honest but trivially small; the
predicate should admit it measures operability of the pre-file gate's
input only (which its ceiling already says).

### F7 (guard(c)+(d) unsatisfiable as a pre-file check)

Guard (c): pre-file gate reads PASS including this round's
claims.json. Live measurement:
`prefile-falsification.py --lane kagi --round 66` ⇒ `SETUP
findings=3` (wave-missing, ledger-missing, report-missing), rc=2.
PASS is unreachable until w1-results, the ledger, and the fleet
report exist — i.e. after the round is over. Guard (d): claims-
declared reads CLEAN with `claims=59` (56+3). Live: CLEAN claims=56;
manifest `corpus/claims-declared.tsv` has NO round-66 rows
(`grep -c '^66'` = 0) and `SCORECARD.md` has NO `## Round 66 —
post-move` section. Adding rows requires landing the round — circular
for a pre-file guard. Guards (c) and (d) cannot co-hold at the time
the predicate is read; the counter must either schedule its reading
post-landing (admitting C2 measures a post-mortem, not a pre-file
input) or relax them to "claims.json present + selftest PASS".

Also the plan's "any Amendments" clause makes exact=1 a moving
target: as amended, the frozen text is whatever the latest
amendment says, so in the absence of a locked amendment the counter
must implement "latest amendment wins" — a policy the predicate does
not pin down. Cap amendments for C2 to a sealed appendix hash, or
the counter grades its own homework.

Smallest safe correction: move guard(c)/(d) out of the executable
predicate (consequences the closure checks at score time) and make
the scored predicate claims.json-parseable exactness + pre-file
gate's existence-check (K4 covers missing → SETUP 2).

### F8 (K1 as written misattributes the failure)

K1 expects exact=0 at BASE from round-65 claims vs round-65 plan.
Census-c2.md already documents the divergence in detail (2/3 titles
stale, C1 target stale on guard). A C2 counter that hard-codes
round-65 BASE would reward keeping round-66 claims frozen to the
pre-amendment wording; the census proves the mutation engine (K2
stale-wording swap) is sufficient. No further action than F6.

## C3 — falsifiers

### F9 (hard-coded checks=3 vs 30+ live citations; population vacuity)

`checks=3` names only the repair stands. A real registry scan finds
30 fetch rows with `capture/` paths + 22 SOURCES rows mentioning
`capture/` (BASE counts). The counter must ignore the other 27
citations to report checks=3. A "registry whose anchor cells cite
captures" claim that only checks the one family it repairs is
sampling disguised as census — the exact vacuity class the round-63
M65-2 lesson warns against except drifted around a counter, and the
"population bound, not assumed" guard(c) (rows=155) then binds only
the row count, not the citation population.

Smallest safe correction: checks = count of rows citing a
`round-64/capture/` path on the candidate tree, printed and
asserted = 3 (S148 family), with the full-population citation count
printed alongside; failures=0 on the family, and non-family rows
reported (not counted) so a drift elsewhere is visible, not hidden.

### F10 (rows=155 population bound contradicts C1's own repair)

C1 repair: "a corrected anchor is written as a new registry row
superseding S148, and `source-fetches.tsv` carries the new id's
row". That adds a row: 155 → 156. C3 guard(c)/K3 assert `rows=155`
from the committed tree at each run (a shrinking registry is SETUP).
C1's execution breaks C3's guard on the candidates that most fully
execute C1. Disjointness cannot be claimed ("each verifiable without
the others landed" is false for C1+C3).

Smallest safe correction: assert rows ≥155 with S148-row preserved,
or land the new row as a replacement (modify in place, count stays
155) and update the prose. Record the choice before counters land.

### F11 (S156/S157 precedent: filename ≠ pin already widespread)

The tree already holds a filename≠pin case C3's scan would meet if
it were general: registry S156 pins `037c2dbe…` (429 body) while
round-64 `S156.body` is `ccf6ac49…` FAQ HTML; S157 has a capture
file and no row. C3 K2 ("a tree holding the arXiv body at the carrier
path reads failures≥1 naming the digest mismatch") is satisfiable
(the counter can fail — good), but K1's BASE story ("a do-nothing
tree reads failures=1 at BASE" because S148 cites no path) quietly
assumes the scan considers S148's anchor a failure rather than
legible "uncited" (the plan's own ceiling: "Rows that cite no path are
legible as 'uncited' only for rows whose anchor names one; the S148
row is cited by the repair and therefore must resolve" — circular
outside the repair: S148 must resolve because it is repaired, and
the repair proves it by resolving). The ceiling must be tightened: a
mined row carrying an in-row sha pin (S148's anchor has one) but no
capture path is exactly the uncited-but-pinned case; failure should
be defined as "pinned row names no capture path" rather than assumed
from the decision to repair this one row.

Smallest safe correction: define failures over the set of pinned
mined rows naming no capture path (count printed); at BASE =1 (S148),
at candidate =0. This makes K1 a measurement, not a restatement.

## Cross-cutting: do-nothing reachability matrix

| Predicate | BASE tree | Path-only edit of planned repair | Stale-wording swap |
|---|---|---|---|
| C1 drift=1 | 0 only if counter requires registry-row resolution; volatile-shape leg already 1 | planned repair = path-only edit ⇒ reads 0 under K2 as written (F1) | n/a |
| C2 exact=1 | round-66 pair already 1 (F6) | n/a | 0 (counter can fail — K2 ok) |
| C3 failures=0 | failures≥1 (S148 uncited) | repair itself | counter can fail on arXiv swap (K2 ok) |

## What the smallest safe corrections are (summary)

1. C1: XREF — name the digest field (fetch col10 vs SOURCES pin);
   restate K2 as wrong-bytes, not wrong-string; mutate S148 itself
   and the round-63/round-64 S143.body pair; add the digest-
   disjointness guard; admit novelty = 2 anchors, axis split shared
   with C3.
2. C2: XREF — re-base exact=0 on the round-66 pair (absent/stripped
   claims.json); move guards (c),(d) out of the pre-file predicate;
   seal amendments for the exact-match target.
3. C3: XREF — checks counted over the round-64/capture citation
   population, not hard-coded; fix rows=155 vs C1's new-row 156;
   define failure as pinned-but-uncited population.

## Bottom line for the main agent

Do not land counters against the plan as written without fixing F1
(C1 repair contradicts K2 — the candidate cannot pass its own kill
rule), F6 (C2 passes with no work on the round-66 pair), F7
(C2 guards unsatisfiable pre-landing), F10 (C1 breaks C3's
population assert), and F9 (C3 checks=3 hides the 30+ citation
population). F2/F3/F5/F8/F11 are scope/truth-in-labeling defects that
narrow what each claim actually proves. None of the five requires a
new claim; all are corrections the coordinator can freeze as
pre-reading amendments with the measurements above as the forcing
evidence.
