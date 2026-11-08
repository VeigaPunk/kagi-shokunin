# R66ExecC3SelfRef — C3 instrument: superseded form + measured registry-selfref evidence

Seat: R66ExecC3SelfRef (executor). Lane: kagi-shokunin (branch master,
Claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`).

**Status: the seat's assigned predicate was withdrawn mid-round by the L1's
Amendment A3 (`plans/round-66.md:383`, uncommitted working-tree diff this seat
read).** A3 states: "§C3 as frozen asked a counter to bind *registry anchors*
to capture paths and hard-coded `checks=3` … Withdrawn in that form", and
re-freezes C3 as `C3_CENSUS: findings=` read from the lane's own gate. The
lane file `plans/round-66-c3.sh` therefore now carries the L1's integrated
`C3_CENSUS` counter (sha256 `a6c36b87…`), not this seat's counter; this seat
did not write to that path after the L1's integration (one writer per
checkout). The `C3_SELFREF` instrument is preserved as an artifact and its
readings are recorded below as corroborating evidence; the L1 owns the
verdict.

Artifacts (this seat's writes only):
- `.ufo/waves/round-66/w1/R66ExecC3SelfRef/round-66-c3-selfref.sh`
  (sha256 `aa6c8246…`) — the withdrawn `C3_SELFREF` instrument, including the
  two fixes R66MutC2's mutation test forced (S1 anchor-cell scan, S2
  carrier-row fetch binding) and `resolved` read independently of `guard`.
- readings: `base-selfref.txt`, `candidate-selfref.txt`,
  `selftest-selfref.txt`, `artifact-sha.txt`, plus the earlier BASE receipts
  (`base-counter.txt`, `base-census.txt`, `fleet-census.txt`,
  `population.txt`, `kill-rules.md`) measured before the S164 repair landed.
- this report.

## Measured evidence (archived instrument, exact commands)

`bash round-66-c3-selfref.sh --tree <tree>`:

- BASE `d549ee6` (extracted with `git archive d549ee6 | tar -x`, receipt
  `base-selfref.txt`): `C3_SELFREF: resolved=0 checks=1 failures=2 guard=0`,
  exit 1, with named failures
  `designated S148 cites-no-carrier-path pin=3b8d4e159a0b` and
  `fetches S148 col16-not-a-round-64-citation:§3.1.2 …`. The S148 row pins
  3b8d4e15… and names no capture path (`grep -cF 'S143.body'
  corpus/SOURCES.md` = 0). K1 holds: a do-nothing tree cannot read 0.
- Candidate (current working tree, L1's S164 row landed, receipt
  `candidate-selfref.txt`): `C3_SELFREF: resolved=1 checks=3 failures=0
  guard=1`, exit 0. The three counted stands, printed with their supplier:
  `registry S164 .ufo/waves/round-64/capture/S143.body`,
  `fetches S164 .ufo/waves/round-64/capture/S143.body`,
  `volatile DEFAULT_CAPTURE .ufo/waves/round-64/capture/S143.body`.
  Designated carrier = S164 (last pin-carrying row); the preserved S148 text
  is not required to cite — the append-only rule.
- `--selftest`: `C3_SELFREF_SELFTEST: PASS (cases=25)`, exit 0 (parser,
  anchor-cell/whole-line split, fetch-carrier binding, punctuation
  scratch-off, pin extraction, verify() refusal on missing and wrong-byte
  files).
- K2 (mutant): arXiv body `fabc74c5…` at the carrier path reads
  `failures>=1 naming digest-mismatch` on both trees (3 at BASE, 4 on the
  candidate). K3: rows re-derived per run (155 BASE, 156 candidate; <155 is
  SETUP). K4: lane census verdict printed; BASE FAILED findings=4, candidate
  CLEAN rows=156.
- Pin facts: `sha256(.ufo/waves/round-64/capture/S143.body)` =
  `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`
  (264946 B) = S148 pin = volatile `PIN_SHA`; `S148.body` = `fabc74c5…`
  (39750 B, the arXiv body), disjoint.

## What this establishes for the amended round

Independent of the withdrawn predicate, the milestone observable "registry
anchors resolve" is measured: at BASE the pin-carrying row cites no carrier
path (failure), at the candidate the anchor cell + fetch col16 + volatile
stand all resolve to one path carrying the pin (checks=3, failures=0). The
integrated `C3_CENSUS` counter on the same tree reads
`C3_CENSUS: findings=0 rows=156 guard=1` (this seat's run of
`plans/round-66-c3.sh` at sha `a6c36b87…`, exit 0); its lane-gate line is
`SOURCES_CENSUS: CLEAN (rows=156 …)`. R66MutC2's battery on those bytes
(their receipt `c3a3-summary.json`, attributed) reports ten input mutants
all killed and no survivor: `cites:` removal → findings=4; S155 provenance
row removal → findings=1; constant-CLEAN / findings=0 / rows=999 /
CLEAN-rc1 stubs refused by guard-b; FAILED findings=2/3 with rc=0 read the
findings (exit not trusted); no verdict line → guard a=0; fake fleet wrapper
→ guard d=0. Their named caveat: guard-d measures `$FLEET/kagi-shokunin`
rather than `--tree` when the two differ — they coincide on the default run,
and a tree-owned gate that lies consistently on both measurements is the
inherent forgery ceiling.

## Findings routed, not fixed (L1 owns the lane file)

1. **A3's population statement is corroborated, not exercised**: the counter
   form A3 withdrew could not bind the 21+ citation population; the archived
   instrument reports the population (BASE: registry 22 / fetches 30; candidate
   registry 24 / fetches 33) but still votes only the round-64 family. Under
   A3 this is history; recorded so the L1 can cite the measurement.
2. **R66MutC2's two survivors (S1/S2) are fixed in the archived instrument**
   and selftested (cases `s1-anchor-only`, `s2-fetch-carrier-only`,
   `s2-fetch-counted`, `s2-carrier-gap`, `s2-carrier-ok`). Their fix is not in
   the integrated `C3_CENSUS` because that counter reads the lane gate's
   verdict rather than registry anchors; the class is covered there by
   `SC_BODY_CITE`/`SC_FETCH`, which the gate itself computes.
3. **An earlier revision of the integrated counter crashed** at its
   self-reinvocation (`FileNotFoundError: …/<stdin>` from the guard path) when
   run mid-write at 06:2x; the current revision (sha `a6c36b87…`) reads exit 0
   as above. Reported only as history; the current bytes verify.
4. **`rows=155` vs 156**: the committed BASE census is 155 rows; the candidate
   carries 156 (the S164 superseding row). A3's C3_CENSUS reads `rows=` from
   the gate's line rather than asserting a literal, which is the correct fix
   (R66Critic F10); the archived instrument asserts ≥155 with shrinkage as
   SETUP for the same reason.
5. **The amended C3_CENSUS is blind to the borrowed-identity class; C1's
   counter is the instrument that sees it (measured by R66ScoutSources, their
   M4, on a scratch copy of the current tree — lane untouched).** The probe
   repointed S164's fetch col16 to `.ufo/waves/round-66/capture/S164.body` and
   planted S152's arXiv body (`fabc74c5…`, 39750 B) there while the row still
   declares `3b8d4e15…` (264946 B): the lane gate reads
   `SOURCES_CENSUS: CLEAN (rows=156 …)` and the fleet wrapper reads
   `kagi ok` — both BLIND. `plans/round-66-c1.sh --tree <t> --base-tree <b>`
   reads `fetches:digest-mismatch:…/S164.body`, `match=0 drift=0 guard=0`,
   exit 1 — it CATCHES it. Mechanism, from the gate's own source: its only
   capture-related check is the location string's length
   (`[[ ${#floc} -ge 8 ]]`) and it never hashes the named file; the only
   declared-digest-vs-bytes leg is the in-row-pin classification, bounded to
   S001–S016. Deleting the cited capture entirely also reads CLEAN/file ok.
   Consequence: A3's C3_CENSUS measures citation *declaration*, not carrier
   *bytes*; the byte binding lives in C1's two independent anchors (registry
   anchor stays clean while the fetch anchor names the mismatch). Cheapest
   correct future leg: hash the file at fetch col16 and compare with col10 —
   the digest is already declared. Routed to the L1; round-67 lead.

## Residual risk & verification gaps

- The archived instrument is not the lane's scoring path; it is evidence. Its
  guard leg (d) requires `SOURCES_CENSUS: CLEAN` and happens to hold now only
  because the L1's S164 landing also repaired the four round-65 findings
  (captured in `candidate-selfref.txt`). At BASE it reads 0, as recorded.
- checks=3 remains a round-64-family sample (A3's point). Rows outside the
  family are printed, never voted.
- No mutation-testing was re-run by this seat; R66MutC2's report
  (`.ufo/waves/round-66/w1/R66MutC2.md`) is the attack record for the
  withdrawn form and this seat's archive answers its two survivors.

## Tooling

No installs. python3, bash, awk, sha256sum, git archive/tar from the host.

Report: .ufo/waves/round-66/w1/R66ExecC3SelfRef.md
