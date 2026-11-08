# R66MutC2 — mutation test: C2 claims counter and C3 self-reference counter

Seat: mutation-tester (attack). Read-only on lane source; inputs mutated only on
disposable reflink copies under `/fast/scratch/hyaku/kagi-r66/R66MutC2/`.
Detailed report and receipts: `.ufo/waves/round-66/w1/R66MutC2/mutants.md`,
`.ufo/waves/round-66/w1/R66MutC2/receipts/`.

Counters under test (final bytes, as declared by their executors):

| counter | sha256 | bytes |
|---|---|---|
| `plans/round-66-c2.sh` | `82ed8b991f3e07c65375f964a599f153c71762d431826ea925b54b82afef1f18` | 20260 |
| `plans/round-66-c3.sh` | `bbf69b5168d7d239a7a84133c01e647b55d0f087fc599d58c3a623730b18f470` | 22866 |

Measured tree: `git archive ddcd46b` (frozen plan) + untracked round-66 inputs
(`claims.json` sha `f54cc0ac9d79c252…`), with the plan-faithful append-only
carrier repair applied in scratch (new `S157` row: anchor cell cites
`.ufo/waves/round-64/capture/S143.body` + S148 pin; fetch col16 same path/col10
pin; `claims-declared.tsv` 66 rows ⇒ claims=59; `SCORECARD.md` Round 66
post-move section; S148 row and volatile `DEFAULT_CAPTURE` untouched).

## Baselines (required before mutant verdicts)

- **C2 target fixture:** `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3 guard=0`
  rc 1. exact leg at target; `guard-a=1` (selftest PASS cases=11), `guard-b=1`
  named C2, `guard-d=1` claims=59, `guard-c=0 rc=2` — the fleet pre-file gate
  reads SETUP while wave-results/ledger/report are absent. Exit-code verdicts are
  inconclusive while guard-c=0; exact-leg verdicts are attributable.
- **C2 BASE image + round-66 claims.json (no repair):** `exact=1 … guard=0`.
  The default reading reaches target with zero candidate work. K1 is reachable
  only through the added `--plan/--claims` interface: round-65 pair ⇒
  `exact=0 titles=0 targets=0`.
- **C3 target fixture:** `C3_SELFREF: resolved=0 checks=3 failures=0 guard=0`
  rc 1. Carrier legs at target (`checks=3` = registry anchor 1 + fetch col16 1 +
  volatile 1; `failures=0`; `designated=S157`). `guard-d=0` because the lane
  census reads `SOURCES_CENSUS: FAILED (findings=6 rows=156)`. Verdicts below
  are on `checks`/`failures` + named lines; the printed `resolved=`/exit cannot
  move while guard-d=0.
- **C3 BASE (no repair):** `checks=1 failures=1`, `designated S148
  cites-no-carrier-path` — K1 reads the failing value.

## Named mutants — killed

C2 (baseline `exact=1 titles=3 targets=3`): stale-title swap (C2 titled
`C2_ROUTED…` ⇒ `exact=0 titles=2 mismatch C2 title`); trailing-space title
(C1 named); flat fourth claim `C4` (`population extra=C4`); dropped claim
(`population missing=C2`); added entry key (`C1 entry-shape`); target swap
(`C3 target`); axis swap (`C3 axis`); plan §C2 with the printed + Output lines
removed (tier-3 label ⇒ `exact=0 mismatch C2 target`); amendment restating a
different printed body (`exact=0 mismatch C2 target`). Benign controls:
amendment restating the same body ⇒ exact=1; key order reversed ⇒ exact=1;
no-op claims rewrite ⇒ exact=1; missing claims/bad JSON ⇒ SETUP rc 2.

C3 (baseline `checks=3 failures=0`): path-missing (`registry S157
missing-path:…S999.body`, failures=2); digest-mismatch by repointed anchor
(`registry S157 digest-mismatch:…S148.body`); digest-mismatch by one flipped
capture byte (4 named failures: registry/fetches/volatile/designated); wrong-dir
citation (`checks=2` + designated line); uncited carrier (`checks=2`, designated
cites-no-carrier-path); second bad round-64 citation (`checks=4` + named
digest-mismatch); fetch col16 `-`/missing file/wrong file/col10 tamper (checks
drop or named lines); volatile repoint to the arXiv body (named volatile
digest-mismatch). Benign controls: an uncited extra row and a non-round-64
citation with a wrong in-row pin both leave `checks=3 failures=0` (correct
round-64 filter).

## Surviving mutants (with fixes)

1. **C2 wrapper hides a sibling top-level key/claim — SURVIVED.**
   `claims.json` = `{"claims": {C1,C2,C3}, "note": …}` reads
   `exact=1 claims=3 titles=3 targets=3`; the stronger probe
   `{"claims": {C1,C2,C3}, "C4": {axis,title,target}}` also reads exact=1.
   `as_claims()` unwraps and `compare()` inspects only the inner map, so the
   frozen "no extra key exists" never sees the sibling. Fix: when unwrapping,
   reject any sibling top-level key (`set(obj) - {"claims"}` ⇒ exact=0
   `population extra-top-level=…`), or drop wrapper tolerance and require the
   flat `{C1,C2,C3}` map.
2. **C3 anchor-cell scan is whole-line — SURVIVED.**
   Moving the carrier path from `S157`'s anchor cell into its teaches cell
   leaves the row line carrying the path; the counter still reads
   `checks=3 failures=0` (target) though the anchor cell cites no carrier.
   `parse_sources()` uses `PATH_RE.findall(line)` instead of the anchor cell.
   Fix: `cites = [scrape_path(p) for p in PATH_RE.findall(anchor)]`; keep the
   whole-line scan for the population report only.
3. **C3 fetch stand not bound to the carrier row — SURVIVED.**
   Setting `S157` fetch col16 to `-` and repointing the unrelated `S143` fetch
   row's col10/col16 to the carrier pin/path still reads
   `checks=3 failures=0`. The fetch surface counts any row citing a round-64
   path. Fix: count a fetch stand only when its id is a pin-carrying
   (`vpin in anchor`) row id, and emit `fetches <id>
   col16-not-a-round-64-citation` when the carrier row's own 16th column does
   not name the capture.
4. **C2 K1/do-nothing control not in the default verdict — coverage gap.**
   A byte-identical BASE image + round-66 `claims.json` reads `exact=1` on the
   documented command; a true BASE extract reads SETUP. The K1 `exact=0` value
   exists only via the added `--plan/--claims` flags and is not a guard/exit
   leg. Fix: make the round-65-pair cross-reading a guard leg (`exact=0`) or
   re-base `exact=0` on a sealed pre-round claims snapshot (L1 decision; the
   counter change needs no plan amendment since K1 already names the pair).
5. **C3 `resolved` conflates guard — frozen-shape deviation.** The frozen line
   is `resolved=1 checks=3 failures=0 guard=G`; the counter computes
   `resolved = checks==3 and not failures and guard`, so a plan-faithful
   candidate with a dirty census prints `resolved=0`. Fix:
   `resolved = 1 if (checks == 3 and not failures) else 0`, exit 0 iff
   `resolved and guard`.

## Non-blocking gaps observed while killing mutants

- C3 path-missing is reported by the designated leg as
  `digest-mismatch-carrier`; wrong-dir has no line naming the outside-dir
  citation; a missing fetch stand yields `failures=0` (only `checks=2`
  refuses). Fix: name `missing-path` / `digest-mismatch` / `outside-round-64`
  distinctly and print which row supplied each counted stand.
- C2 `guard-b` takes the stale wording from the live claims (`base=live`), so
  on a tree whose live claims already contain the stale wording the leg reads 0
  (`stale-phrase-not-found`). Fix: derive the literal from the committed
  round-65 claims file.
- C3 `guard-d` correctly requires `SOURCES_CENSUS: CLEAN`; the plan-faithful
  candidate's lane census reads `FAILED findings=6` (four pre-existing round-65
  S155/S156 findings + two from the new row). This is integration state the
  frozen carrier repair does not cover, not a counter defect.

## Restoration / write scope

No lane source was written: both counter hashes are identical before and after
the battery (`82ed8b99…`, `bbf69b51…`); every mutant lived in
`/fast/scratch/hyaku/kagi-r66/R66MutC2/fix/` (reflink copies of the
`git archive ddcd46b` image); per-mutant input hashes are recorded in
`R66MutC2/receipts/hashes.txt`; the scratch tree is disposable and removed on
exit. No tools installed.

Counters/survivors summary: 11 C2 input mutants (9 killed, 2 benign/control)
+ 2 survivors; 15 C3 input mutants (11 killed, 2 benign, 2 survivors).

## Post-test plan amendment (observed after the battery)

At 06:32:25 the L1's working-tree `plans/round-66.md` changed
(`sha256 42b88af415a4bbfc9bcb86c9a7d07c71dcc515aa480a14b1a62a0ff0d82d84c2`)
with Amendments A1–A3. A2 replaces §C2's claims-exactness predicate with
`C2_PREFILE` (pre-file gate + `claims-declared`); A3 replaces §C3's
registry-anchor predicate with `C3_CENSUS` (lane census findings count). The
readings above were taken against the freeze-time blocks (`ddcd46b`, fixture
plan `e2416557…`) and the counter hashes quoted at the top; they are not
readings against A2/A3, and the counters as landed no longer implement the
plan's current §C2/§C3. The C2 vacuity measured here is the one A2 cites; A3
withdraws the hard-coded anchor sample C3 measured.

## Second battery — the amended instruments (A2/A4, A3/A4)

Current plan sha `6841fcde7bbf099ab49cac4b065e46b51c6fbbbc0481af1e7ce9719cda82a1d5`
(22774 B, A4 added). Current counters: `plans/round-66-c2.sh`
`2a9101f14a4c5237787badf8b37963d841b2e5d3935c3eea245d1eef2aefe4e1`
(C2_PREFILE, 11598 B) and `plans/round-66-c3.sh`
`a6c36b87a4ae22f95b3f8cbc7369dfba8f588a20d308fbf0a8eede3fcef85683`
(C3_CENSUS, 8015 B).

**C3_CENSUS — target reachable, all 10 mutants killed.** Lane baseline:
`C3_CENSUS: findings=0 rows=156 guard=1`, rc 0; corpus-fixture baseline
identical. Killed inputs: `cites:` removal (findings=4), S155-provenance
removal (findings=1), and eight gate-stub mutants: constant CLEAN (guard-b
refuses the forgery), FAILED findings=2/3 with rc 0 (findings read, exit not
trusted), FAILED findings=0 (guard-b refuses), no verdict line (guard-a=0),
CLEAN with rc 1 (guard-b refuses), CLEAN rows=999 (rows read from the line,
guard-b refuses), and a failing fleet wrapper (guard-d=0). No survivor.
Ceilings: guard-d measures `$FLEET/kagi-shokunin`, not `--tree` when they
differ (coincide on the default run); a tree-owned gate that lies consistently
on the tree and the stripped copy is the inherent gate-forgery ceiling; `rows`
is read but not asserted (A4 item 3).

**C2_PREFILE — target unreachable as landed; two surviving defects.**
A conforming fixture fleet (repaired tree + claims/results/9-row ledger/report
+ gate copy) reads with `--fleet`: `PREFILE-FALSIFICATION: pass claims=3
rows=9 attack_seats=3 findings=0` rc 0, and `CLAIMS_DECLARED: CLEAN
(claims=59)`. The counter on the same `--tree`/`--fleet` reads
`gate-out … SETUP findings=2`, `gate=0 claims=0 rows=0 attack_seats=0
guard a=1 b=0 c=0 d=1`, rc 1.

1. **`--fleet` never reaches the gate.** `run_gate()` and all three guard
   invocations call `prefile-falsification.py --lane kagi --round 66` without
   `--fleet`; the tool defaults to `/home/vgpnk/Projects/shokunin`. The
   counter therefore measures the default fleet, not the measured tree
   (`--tree` is only a cwd). Measured: gate with `--fleet` fixture ⇒ pass;
   without ⇒ SETUP findings=2; counter ⇒ SETUP.
2. **Guard-b cannot be satisfied.** It leaves `rfleet/kagi-shokunin` empty
   (only guard-c populates its copy) and both guards invoke the gate without
   `--fleet`; on a PASS ledger there is no `claim-uncovered` /
   `attack-seat-unread` finding, and SETUP exits 2 — so b=c=0, guard=0, exit 1
   on a perfect integration.

Input mutants demonstrate the invisibility: a ledger with all C3 rows removed
reads at the gate `FINDING claim-uncovered claim C3 has no ledger row` /
`FAIL … findings=1` rc 1; an all-`R66Critic`-rows-removed ledger reads
`FINDING attack-seat-unread … R66Critic …` / `FAIL … findings=1` rc 1. The
counter reads the same `SETUP findings=2`, gate=0 for both.

Fix: add `"--fleet", FLEET` to `run_gate()`, pass `--fleet rfleet` from
guard-b/c, populate guard-b's `rfleet/kagi-shokunin` wave dir and report as
guard-c does, and optionally assert
`realpath(TREE) == realpath(FLEET + "/kagi-shokunin")`. The lowercase `pass`
trap (A4 item 1) is handled by `re.I` + `status.lower()`; the
`claims-declared` leg is correctly tree-scoped (59 ⇒ cd_ok=1, 56 ⇒ 0).

Receipts: `R66MutC2/receipts/{a2-prefile-scoping.txt, a2-a2-mut-claim.txt,
a2-a2-mut-seat.txt, c3a3-lane-baseline.txt, c3a3-*.txt,
c3a3-summary.json}`. Both lane counters were byte-identical before and after
the second battery; no lane source was written by this seat.


