# Round 66 — verifier spot-check (non-author)

author: hyaku closure (non-author integrator, @m_zfl)

Lane: kagi (secrets & vault ops). Claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`; lane HEAD under review
`d1e127ac5b363522ee5a2804ad57c72af7a32953`.
Dispatch/complete digest (from `.ufo/watchdog.log`, copied verbatim; the log is
mutable, this digest is the pointer):

```
2026-11-08T05:47:43-03:00 launch kagi round=66 pgid=2306145 driver=hyaku-inline attempt=1
2026-11-08T07:17:32-03:00 complete kagi round=66; hyaku-inline attempt=1
```

## 1. Step-1 conformance

- **Report identity.** `git -C /home/vgpnk/Projects/shokunin log --format='%an %H' -- .ufo/reports/round-66/kagi.md`
  ⇒ `kagi-shokunin 5d33f7746f3f8a9583341feeb3dc332402749cdc` (erratum)
  and `kagi-shokunin 6c24614994297a882f6ed879a1f47a814fb9c3d8` (report);
  both are `kagi-shokunin <kagi@shokunin.local>`. The erratum (07:16:51) lands
  after the lane's close correction `d1e127ac` (07:16:42) and names it, so the
  report-as-corrected lands last and cites the final lane tip. The original
  filed bytes' placeholder ("Final lane tip: `git ls-remote …`") is superseded
  by that erratum, which is the permitted correction form (new commit, appended
  after the filed bytes).
- **SHONEN.** `## SHONEN` at report line 277, four `[~]` lines — one per box of
  `SHONEN.md`, each with a pointer; no `[x]`. Required sections present in
  order: `## Work performed`, `## Landed changes`,
  `## Before → after measurements`, `## Sources & frontier`,
  `## Trend verdicts`, `## SHONEN`.
- **Ancestry.** `git -C kagi-shokunin merge-base --is-ancestor <h> refs/heads/master`
  holds for every cited lane hash: `ddcd46bb`, `dcd78c2e`, `cfafdb11`,
  `f2d58687`, `567f50c3`, `967afd49`, plus BASE `d549ee6` and tip `d1e127ac`;
  all nine commits in `d549ee6..refs/heads/master` carry the lane identity.
- **Push / cleanliness.** `scripts/hyaku/jj-lane.sh state kagi-shokunin` ⇒
  `state branch=master local=d1e127ac5b363522ee5a2804ad57c72af7a32953 remote=d1e127ac5b363522ee5a2804ad57c72af7a32953 ahead=0 behind=0 head=detached tracked=0 untracked=0`;
  `git -C kagi-shokunin status --porcelain` is empty;
  `git -C kagi-shokunin ls-remote origin refs/heads/master` prints
  `d1e127ac5b363522ee5a2804ad57c72af7a32953`.
- **Prompt.** `.ufo/prompts/kagi-round-66.md` (committed `66d5c89`, 989 lines)
  carries the rendering contract: §1 mission/axes binding, §2 the 1–3 claims
  rule with the lowest-axis obligation, §2b the frontier step, §3 the L2 floor
  (≥8 subagents in one batched call, role split, host route table), §4 the
  report contract (report path, required sections, SHONEN rule, marker rule),
  §5 commit-then-push ordering, push scope and the L0 side channel, and the
  five child-lane items (report path/filename; report-lands-last; `## SHONEN`
  grep; landed-hash citation rule; lane write scope in §3). The addendum §6
  carries the run-15 round-size/attack-share lines and §8 the pre-file
  falsification ledger. No L2 bucket contradiction with `MISSION.md` §L2
  concurrency was found (the prompt defers routing to the host route table).
- **Marker check.** Real committed work with resolvable hashes, counters,
  receipts and per-claim counting commands; not a marker. Status: **ok**.
- **Conformance defects, all status-neutral and named** (see §6 for routing):
  1. The `## Landed changes` table's "Round 66, bullet 1…16" pointers do not
     resolve: the `LOG.md` round-66 entry has **10** top-level bullets
     (`sed -n '/^## Round 66 (2026-11-08)/,/^## Round 66 — correction/p' LOG.md`),
     bullets 11–16 do not exist, and the 1–10 mapping does not match the listed
     changes. Every change→LOG tie in that table fails as written.
  2. The report cites `.ufo/waves/round-66/final/c3-base.txt` as the C3 BASE
     receipt; that path is absent from the tree and from every commit
     (`git log --all -- .ufo/waves/round-66/final/c3-base.txt` prints nothing;
     `git ls-tree -r --name-only d1e127ac -- .ufo/waves/round-66/final/` lists
     ten files and not it). The BASE reading is independently corroborated
     (`R66Reviewer` F3; `R66ScoutPreState/census.md:181`;
     `R66MutC2/receipts/cites-removed.txt`) and re-derived in §2.
  3. Two round commits are uncited by the report: `8bd920d` (counter
     receipts/selftests for the filed report) and `d89e01d` (sentinel report
     + audit); the wave bullet's "across the four commits" undercounts —
     nine commits separate BASE from the tip.
  4. The wave section's "the falsification ledger reconciles the seats that
     filed" is false: `R66Sentinel` filed `.ufo/waves/round-66/w1/R66Sentinel.md`
     and has no ledger row (§2b).
  5. The round-shape note's "the L1 re-ran the battery after integration" has no
     committed receipt: the only battery outputs in the lane read
     `CONTROLS: match=8 mismatch=1` (`w1/R66ExecControls/controls-live.txt`,
     header pins the pre-hardening counter `221a2cd7…`) and
     `match=8 mismatch=2` (`controls-last.txt`); the build-dir copy is a
     mid-flight `match=4 mismatch=14`. The battery selftest is 29 cases.
  6. §Sources & frontier says the touched `used-by` cells are logged old→new in
     the lesson's Gate addendum; the lesson logs only S148/S156 and not
     old→new (`grep -n used-by corpus/lessons/round-66.md` ⇒ line 28 only).
     `CORPUS.md` SOURCES contract v1 rule 2 requires each in-place change
     logged old→new.
  7. §Sources & frontier names six touched rows; the diff touches seven —
     S113 also gained the new entry in `used-by`.
  8. The coverage map `corpus/README.md` has no row for the new entry
     (`grep -c carrier corpus/README.md` ⇒ 0); the index should hold a row once
     the file exists.
  9. `.ufo/waves/round-66/claims.json` still carries the pre-amendment
     `C2_CLAIMS` / `C3_SELFREF` pairs while the landed counters measure
     `C2_PREFILE` / `C3_CENSUS` (sentinel I-2); the ledger reconciles the
     amended plan but the claim file was not re-derived or explained. This
     recurs the round-65 spot-check's routed item 5.

## 2. Claim re-checks

Method: C1 and C3 were **re-measured by plain measurement over committed
bytes** (grep/wc/sha256/git, plus the lane's committed normalizer for digests
and quote locations); their committed receipts were evidence-verified
(counter sha256, self-test tally, revision). C2 was **measured by this
closure's own run** of the fleet pre-file gate — the surface the claim rests
on. No sibling-owned gate was executed (PROTOCOL §Gate standard, Closure
consequence).

### C1 — freshness (`C1_CARRIER`, drift 0 → 1) — **MET**

```
$ grep -P '^\| S164 \|' corpus/SOURCES.md          # anchor cell (col 7)
… carrier capture `.ufo/waves/round-64/capture/S143.body` (264946 B,
sha256 `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`) …
$ sha256sum .ufo/waves/round-64/capture/S143.body
3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
$ wc -c < .ufo/waves/round-64/capture/S143.body
264946
$ grep -P '^S164\t' corpus/source-fetches.tsv   # col10 = pin, col11 = 264946, col16 = the same path
$ grep -n DEFAULT_CAPTURE corpus/volatile-shape.py
50:DEFAULT_CAPTURE = ".ufo/waves/round-64/capture/S143.body"
```

BASE, by contrast:

```
$ git show d549ee6:corpus/SOURCES.md | grep -c 'round-64/capture/'      ⇒ 0
$ git show d549ee6:corpus/SOURCES.md | grep -c '3b8d4e15…'             ⇒ 1 (the S148 row; names no path)
$ git show d549ee6:corpus/source-fetches.tsv | grep -P '^S148\t' | cut -f16
§3.1.2 Trigger Terms, Pseudo-Trigger Terms, and Termination Terms (BioC XML body)
```

So at BASE no registry row carries the pin *and* names a capture path, and the
fetch column is prose; on the candidate all three anchors resolve to one path
whose sha256 and byte count equal the pin. Drift 0 → 1 holds.
Receipts evidence-verified: `.ufo/waves/round-66/final/c1-base.txt`
(`C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0`, rc 1),
`…/c1-candidate.txt` (`drift=1 paths=3 hex=3 match=1 guard=1`, guard
`a=1 b=1 c=1 d=1`), `…/c1-selftest.txt` (`cases=45 failed=0`); the counter
sha256 `d72f9712…` equals the landed `plans/round-66-c1.sh` and the `SKILL.md`
registry row. The ledger's `R66MutC1` row describes the pre-hardening bytes
(`killed=24/32`, 29 cases); the landed counter's own tally is 45 — history,
not the landed claim's evidence. **Verified.**

### C2 — operability (`C2_PREFILE`, gate 0 → 1) — **NOT MET (honest stop)**

This closure ran the same surface the claim rests on:

```
$ python3 scripts/hyaku/prefile-falsification.py --lane kagi --round 66
FINDING wave-missing /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-66/w1-results.json
PREFILE-FALSIFICATION: SETUP findings=1
$ echo $?   ⇒ 2
```

The lane's receipt agrees exactly: `.ufo/waves/round-66/final/c2-candidate.txt`
⇒ `C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0`, guards
`a=1 b=0 c=0 d=1`, `claims-declared=1` (`CLAIMS_DECLARED: CLEAN (claims=59)`).
Witnesses: 14 seats are declared in `w1-spec.json`/`w1/swarm-registry.json`;
13 `*.md` seat reports exist in `w1/`; `R66ScribeEntry` has receipts but no
report; `w1-results.json` is absent at the tip
(`git ls-tree -r --name-only d1e127ac -- .ufo/waves/round-66/ | grep -c w1-results.json` ⇒ 0).
The predicate is reachable on a fixture fleet (`R66MutC2`: `gate=1 …
guard=1`, ten gate-side mutants killed; `c2-selftest.txt` `cases=4 failed=0`),
but this round's tree did not carry the driver artifact. **Not verified;
honest stop as the lane declares.** A second, lane-owned reason the gate could
not have passed even with the driver file is named in §2b (the ledger omits
`R66Sentinel`), so the report's "reconciles the seats that filed" is false.

### C3 — calibration (`C3_CENSUS`, findings 4 → 0) — **MET**

Candidate, evidence-verified receipt `.ufo/waves/round-66/final/c3-candidate.txt`:

```
c3-census: line SOURCES_CENSUS: CLEAN (rows=156
c3-census: guard a=1 b=1 c=1 d=1
C3_CENSUS: findings=0 rows=156 guard=1
```

and `c3-selftest.txt` ⇒ `cases=4 failed=0`; counter sha256 `a6c36b87…` equals
the landed `plans/round-66-c3.sh`. BASE re-derived by plain measurement (the
cited `final/c3-base.txt` is absent, defect §1.2):

```
$ git show d549ee6:corpus/source-fetches.tsv | grep -cP '^S(155|156)\t'   ⇒ 0
      # two SC_FETCH missing-provenance findings
$ git show d549ee6:corpus/knowledge/claim-instrument-class-matrix.md | grep -c '^cites:'   ⇒ 0
$ git show d549ee6:corpus/knowledge/claim-instrument-class-matrix.md | grep -o 'S1[0-9][0-9]' | sort | uniq -c
      2 S148
      1 S155
      1 S156
      # two SC_BODY_CITE unrecorded findings (S148, S156)
$ git show d549ee6:corpus/SOURCES.md | grep -P '^\| S(148|156) \|' | cut -d'|' -f12
 corpus/lessons/round-64.md / corpus/lessons/round-65.md   # the entry is not in either
```

Candidate repairs re-measured: `git diff d549ee6 d1e127ac -- corpus/source-fetches.tsv`
adds S155/S156/S164; the class-matrix entry now carries
`cites: S148, S156, S164`; S148/S156/S164 `used-by` cells list
`corpus/knowledge/claim-instrument-class-matrix.md`. The four BASE findings and
the zero candidate findings therefore re-derive. Corroboration for the missing
BASE receipt: `R66Reviewer` F3 quotes the lane gate's
`SOURCES_CENSUS: FAILED (findings=4 rows=155)` with the same four names;
`R66ScoutPreState/census.md:181` independently reproduces it (`exit 1`); the
guard-b receipt (`R66MutC2/receipts/cites-removed.txt`) reads
`C3_CENSUS: findings=4 rows=156 guard=1` with the `cites:` line stripped.
**Claim verified** (the axis-level record defect is graded in §4, not the
census).

## 2b. Pre-file falsification ledger (Amendment 59)

Command and observed result:

```
$ python3 /home/vgpnk/Projects/shokunin/scripts/hyaku/prefile-falsification.py --lane kagi --round 66
FINDING wave-missing …/.ufo/waves/round-66/w1-results.json
PREFILE-FALSIFICATION: SETUP findings=1
EXIT=2
$ python3 scripts/hyaku/prefile-falsification.py --selftest
PREFILE-FALSIFICATION-SELFTEST: PASS        EXIT=0
```

The ledger exists (`.ufo/waves/round-66/claim-falsification.tsv`): 9 rows,
5 TAB-separated columns each, every artifact path resolves from the lane root,
every `falsifies-wording` row names `plans/round-66.md` (which resolves), and
C1/C2/C3 all appear. The gate cannot evaluate it because the driver never wrote
`w1-results.json` — the same honest-stop surface C2 reports.

Because the gate stops at SETUP, this closure derived the attack-seat inventory
from `w1/swarm-registry.json` (the wave's own role record) and applied the
gate's rule manually:

| attack seat | role | in ledger artifact column |
|---|---|---|
| R66Reviewer | reviewer | yes (`R66Reviewer.md`) |
| R66Critic | critic | yes (`R66Critic.md`) |
| R66MutC1 | mutation-tester | yes (`R66MutC1/mutants.md`) |
| R66MutC2 | mutation-tester | yes (`R66MutC2/mutants.md`) |
| R66Connector | connector | yes (`R66Connector.md`) |
| R66Sentinel | sentinel | **no** |

**Adjudication.** The missing `R66Sentinel` row is real and unreconciled: the
seat filed `.ufo/waves/round-66/w1/R66Sentinel.md` (+ `R66Sentinel/audit.md`)
and the ledger does not read it, so with `w1-results.json` present the gate
would print `FINDING attack-seat-unread`. Its content does **not** falsify any
claim's stated wording: V-1 (write scope) was closed on the landed bytes; V-2
(read confinement) was closed in `567f50c3` (`resolve_volatile` now refuses a
non-repo-relative `DEFAULT_CAPTURE` with `DEFAULT_CAPTURE-not-repo-relative:`
and two selftest cases; `grep -n 'DEFAULT_CAPTURE-not-repo-relative' plans/round-66-c1.sh`
⇒ line 193); V-3 is the operator-side fleet `__pycache__`; V-4/V-5 are
process receipts; I-2 is the stale `claims.json` (§1.9). It is therefore a
ledger-completeness defect to route (§6), not a claim falsification by itself.
The four `falsifies-wording` rows do name their narrowing (A1/A2/A3 in
`plans/round-66.md`) and the artifacts forcing them exist. No `falsifies-number`
row is unreconciled; the one such row (`R66MutC1`) is marked history against the
pre-hardening bytes.

## 3. Discernment spot-check (LEARNING.md)

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S164 (new registry row) | admit, tier A, `mined` | live re-open `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode` with a Chrome UA: HTTP 200, 264946 B, sha256 `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`; `cmp` byte-identical to `.ufo/waves/round-64/capture/S143.body` | **agree** | The row's ≤25-word Gate quote — “In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)” (17 words) — locates once in the live body (`RENDERED_TEXT_V1_LOCATE: count=1`) and falls under §3.1.2 (`heading_at=17218 < quote_at=19029`). The declared byte count and sha256 equal the served body; the live re-open ground truth is reproduced, not re-asserted. |
| S165 (refused second row) | reject, no row written | same URL, same live re-open | **agree** with the rejection; **disagree** with the Gate cell's measurement sentence (already corrected) | The rejection reason is sound: one URL with no new lesson; the row count and W04 census flag (`S148/S156/S164 duplicate url`) show the duplicate. But the Gate cell says the served body "differs from the pin by one byte"; this closure's fetch is byte-identical (`cmp` 0, same sha256). The appended Gate addendum already corrects it ("the served BioC body is byte-identical to the pin (`cmp` 0), not one byte off; the one-byte delta belongs to the round-63→64 pair") — the correction is in-file and append-only, so the decision stands and the record is repaired. |

New-row quote check (S164, ≤25 words): located, 17 words, count=1 in both the
committed capture and the live body. The recorded normalizer digests also
reproduce (`corpus/rendered-text-v1.py digest`): S155 `5f509414…` (raw
`cdbb4173…`, 189603 B), S156-429 `5a044661…` (raw `037c2dbe…`, 899 B), S164
`4d966ff9…` (raw `3b8d4e15…`, 264946 B); the S155/S156 quotes locate
`count=1`. Pre-existing S115 still does not locate
(`RENDERED_TEXT_V1_LOCATE: count=0`, rc 1) and is routed (§6.8).

Census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
⇒ `kagi ok /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`,
exit 0, W04 duplicate-url warnings only (156 data rows; the same W04 set names
S148/S156/S164). Gate spot-check agrees on both sampled decisions (S164 admit,
S165 reject → 2 of 2 on the decision; the S165 cell's measurement is corrected
in-file).

## 4. Axis verdicts (agrees with the MANIFEST entry)

| axis | verdict |
|---|---|
| freshness | improved |
| operability | unprovable |
| calibration | harmed |
| depth | unchanged |
| coverage | unchanged |
| adjacency | unchanged |

- **freshness — improved** (C1 verified: three anchors → one path, digest and
  byte count equal; BASE reads no row with pin+path).
- **operability — unprovable** (C2 honest stop: the pre-file gate reads
  `SETUP findings=1`, exit 2; the predicated reading was not produced on this
  round's tree. The instruments themselves run; no regression is measured.)
- **calibration — harmed.** The C3 claim verifies (lane census 4 → 0), but the
  round's self-assessment records do not match observed repo state, which is
  this axis's signal (`AXES.md`: “SHONEN.md/SCORECARD entries match observed
  repo state”): (i) the `SCORECARD.md` round-66 operability row asserts “the
  pre-file falsification ledger reads `pass` with the wave's attack seats
  reconciled” with placeholders `gate=A claims=3 rows=R attack_seats=K guard=G`,
  while the receipt it cites (`final/c2-candidate.txt`) reads
  `C2_PREFILE: gate=0 …` and `SETUP findings=1`; (ii) the `SKILL.md` C1 gate
  registry row pins `selftest cases=14 failed=0` while the committed instrument
  has 45 cases (`grep -c 'cases.append' plans/round-66-c1.sh` ⇒ 45;
  `c1-selftest.txt` ⇒ `cases=45`). This is the class prior closures graded
  `harmed` (mori r45: registry cells pinning tallies the instruments lack;
  kaidoku r48: a false record), and it is a trade against the verified C3 move:
  reported, not netted out. The report's own prose on C2 is honest and is not
  what is graded here; the record surfaces are.
- **depth / coverage / adjacency — unchanged** (no claim; the 156-row registry
  and the connector sweep are side effects; the carried
  `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed).

Scores stay 9 → 9 on all six axes (L1 reading in `SCORECARD.md`); the closure
grades the claim axes on verified evidence, not on the numerals, and grades
calibration `harmed` on record fidelity as above.

## 5. Trend verdicts (with evidence)

- **expansion: unchanged** — one registry row admitted (S164, tier A, `mined`)
  and one knowledge entry landed on ground the coverage map did not hold
  (`corpus/knowledge/claim-instrument-carrier-binding.md`), but the coverage map
  received no row for it and no frontier area moved into core and no capability
  entered the SCORECARD table; nothing admitted failed its bar. Not `improved`
  on the coverage-map observable, not `harmed` — agrees with the lane. The
  missing map row is routed (§6.6).
- **quality: improved** — three instruments moved from claimed to measured
  properties (carrier binding, pre-file reachability, lane census), each with a
  falsifier that fires, and six criteria (QM89–QM94) entered the bar from
  measured mistakes; the round-65 landing defect (an undeclared, unstamped
  entry) was found and repaired by running the gate round 65 skipped
  (`DOC_AUDIT: CLEAN (entries=47 … undeclared=0 … unpinned=0)`). The new entry
  passes the provenance trio and the audit. Agrees with the lane. Caveat: the
  SOURCES `used-by` old→new logging is incomplete (§1.6), a corpus contract
  defect routed next round.
- **discernment: improved** — fourteen mistakes mined (M66-1…M66-14), six
  caught by the wave's attack seats before any candidate reading, and this
  closure's spot-check agrees with the gate on both sampled decisions (§3).
  Agrees with the lane. Named caveat: the ledger's attack-seat population is
  incomplete (R66Sentinel unreconciled) and the report's sentence about it is
  false; that is a reconciliation gap to route, not a gate-decision
  disagreement.

## 6. Routed defects (next round)

1. **SCORECARD round-66 operability row** — replace/annotate the row with the
   measured reading (`C2_PREFILE: gate=0`, `SETUP findings=1`) or mark the
   claim an honest stop; the present sentence and its `A/R/K/G` placeholders
   contradict the receipt they cite. Owner: kagi. (Axis-level: calibration.)
2. **SKILL.md C1 gate-registry self-test pin** — `cases=14` vs the landed
   instrument's 45 cases (`grep -c 'cases.append' plans/round-66-c1.sh` ⇒ 45;
   `c1-selftest.txt` ⇒ `cases=45`). Correct the pin or drop the number.
3. **Pre-file ledger attack-seat coverage** — add an `R66Sentinel` row
   (neutral, naming what it confirms: V-1/V-2 closed; V-3/I-2 noted) so the
   gate's `attack-seat-unread` rule is satisfied once `w1-results.json` exists.
   Also re-derive `.ufo/waves/round-66/claims.json` from the amended plan
   (`C2_PREFILE`/`C3_CENSUS`) or record which pairs are the round's claims
   (recurrence of the round-65 spot-check's routed item 5; sentinel I-2).
4. **Report `Landed changes` LOG pointers** — re-point each change at an actual
   `LOG.md` round-66 bullet (the entry has 10) and cite `8bd920d`/`d89e01d`;
   correct the wave bullet's "across the four commits".
5. **Controls-battery receipt** — commit the post-integration battery run (with
   the landed counter's sha) or correct the "the L1 re-ran the battery after
   integration" sentence; the committed battery outputs read `mismatch=1`/`2`
   and pin the pre-hardening counter.
6. **Coverage map** — add the `corpus/README.md` row for
   `corpus/knowledge/claim-instrument-carrier-binding.md` (file exists, map has
   no row).
7. **Sources & frontier / corpus logging** — list S113 among the touched rows,
   and log the seven `used-by` old→new changes in the lesson (SOURCES contract
   v1 rule 2); commit the missing `.ufo/waves/round-66/final/c3-base.txt` or
   cite the surviving corroboration in the report.
8. **Pre-existing S115 quote** — `python3 corpus/rendered-text-v1.py locate
   .ufo/waves/round-57/capture/S115.body 'Audit devices must be enabled by a
   root user using bao audit enable or using the audit stanza.'` ⇒ `count=0`,
   rc 1; re-cut the quote or mark the row's ceiling.
9. **Operator-side (not performed)** — `scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc`
   in the fleet root (staged) remains; the lane named it as D-66-2 and
   `scripts/` is not a lane write path.

## 7. Closure recommendation

- **status: ok**; **admitted: false**; verdict **`rejected-honest-stop`** —
  C2 (operability) is a measured honest stop; C1 (freshness) and C3
  (calibration claim) verify; the calibration axis is `harmed` by the round's
  record fidelity (§4), so the round is a trade and not admitted.
- Verification type: C1/C3 **re-measured** by plain measurement over committed
  bytes (BASE via `git show d549ee6:<path>`); C2 measured by this closure's own
  run of the fleet pre-file gate; all lane receipts evidence-verified (counter
  sha256, self-test tallies, revisions). Sibling gates were not executed.
- `capabilities_added`: none (no new capability row entered the SCORECARD
  table).
- Promotion note for the operator (operator-owned): SHONEN boxes 1–3 are
  checkable by a non-author from committed artifacts (SKILL.md tables/registry
  rows, the receipts, the self-tests); box 4 is checkable but carries the
  `ADJACENCY_SCOPE: DEFECT` breadth debt, so promotion is not supportable on
  this round's evidence.
