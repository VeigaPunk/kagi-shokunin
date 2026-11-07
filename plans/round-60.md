# Round 60 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 60, attempt 1. Claim BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2` (round-59 verifier spot-check tip,
`round-59 verifier spot-check (integrator, hyaku): non-author admit/reject`, 2026-11-07 15:00:52 -03).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57, 58 and 59, so no stagnation waiver is claimed. Both claims are declared here
before any candidate work; this file is committed alone as the predeclaration, then
the instruments, then the pre-freeze control battery, then the candidate.

Motivating evidence for the round:

- `corpus/lessons/round-59-verifier-spotcheck.md` §7 (non-author closure of round 59)
  routes seven defects D1–D7 that the lane must fix. All seven are unresolved at BASE
  and no lane gate reads any of them: `LOG.md:1965` ends `dead seats __DEAD__`
  (14 results, 0 empty in `.ufo/waves/round-59/w1-results.json`);
  `corpus/lessons/round-59.md` R31 states a 32-case receipt while
  `.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt` reads
  `C1_CHECK_SELFTEST: PASS (33 cases)`; the round-59 routed table repeats the ids
  `R20`, `R21`, `R22` twice each; `SCORECARD.md:1971` states `(21 controls;` while the
  receipt `.ufo/waves/round-59/controls/controls-prefreeze.txt` holds 20 `CONTROL `
  lines; `SCORECARD.md:1976` cites `.ufo/waves/round-59/final/release-clock-candidate.txt`
  which is not in the tree (`ls .ufo/waves/round-59/final` shows six files, none of them
  a release-clock, DOC_AUDIT or SCOPE receipt); the round-59 Before → after table names
  `75165a07` as the measured commit while `.ufo/waves/round-59/final/c1-landed.txt` reads
  `measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c`; and `SKILL.md:847`
  registers the transit trial with selftest cell `none — its own five shims and the
  clean-room leg are the falsifiers`, against the Gate standard's requirement that every
  gate expose a self-invocation mode over isolated fixtures.
- `corpus/knowledge/` holds no executed OpenBao **AppRole** mechanic. The lane's trials
  cover token/lease (r49), response wrapping (r51), KV v2 versions (r52), audit devices
  (r57), ACL policies (r58) and transit (r59); `grep -rl 'approle' corpus/knowledge/`
  matches nothing. AppRole `secret_id` custody is the lane's own subject (a credential
  with a use count, a TTL, an accessor handle and a CIDR binding), not a sibling's.

## C1 — calibration: the seven round-59 routed record defects are resolved and re-checkable

Target axis: calibration (mismatch count between the lane's own statements and the
observed repository state).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_ROUTED: value = the number of UNRESOLVED items over POP = 7 fixed routed-defect
items (I1..I7 below), when GUARD = 1, else FAIL; target 0 (BASE 7).
An item is UNRESOLVED iff its named condition does not hold on the measured tree.
GUARD = 1 iff the checker evaluates all seven items (prints population=7 with
i1..i7 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
is the digit in the I1 correction line's `dead seats=<n>` field changed from 0 to 1,
prints exactly value+1, and a printer stub that always prints value=0 fails that same
challenge.
```

Every number an item compares is derived by the checker from the measured tree or from
a named revision of the lane repository; no constant in the checker carries a fact the
measured tree asserts. "Last occurrence wins" is the correction convention: a correction
is appended, never rewritten into the line it corrects.

| id | routed defect | required condition on the measured tree |
|---|---|---|
| I1 | spot-check D1 | `LOG.md` carries, AFTER its last line containing the literal `__DEAD__`, a block whose first line matches `^## Round 59 — correction`; the block contains a line matching `results=<R> dead=<D>` where R = the number of results in `.ufo/waves/round-59/w1-results.json` and D = how many of them have an empty/absent final output (14 and 0 at BASE), and the block names `w1-results.json`. |
| I2 | D2 | `corpus/lessons/round-59.md` carries, after the line in which `R31` first appears, a line that matches `supersedes R31`, names `C1_CHECK_SELFTEST`, and states the case count equal to the count the checker derives from the last `C1_CHECK_SELFTEST: PASS (N cases)` line of `.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt` (33). |
| I3 | D3 | `corpus/lessons/round-60.md` exists; the id column of its `## Routed dispositions` table (cells matching `R[0-9]+`) holds at least 3 ids and no id twice (derived: max occurrence = 1); and a line of that lesson names `R20`, `R21`, `R22` and the word `duplicate`. |
| I4 | D4 | `SCORECARD.md` carries, after the line matching `\(21 controls`, a line matching `supersedes SCORECARD.md:1971` that states `N controls` where N equals `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt` (20). |
| I5 | D5 | `SCORECARD.md` carries a line matching `supersedes the round-59 gate-evidence pointer` that names three repo-relative paths under `.ufo/waves/round-60/final/` whose file names contain `release-clock`, `doc-audit` and `scope` respectively; each named file exists and its last non-empty line begins with `RELEASE_CLOCK:`, `DOC_AUDIT:` and `SCOPE` respectively; and the line states `never written`. |
| I6 | D6 | `SCORECARD.md` carries, after the round-59 line containing `75165a07`, a line naming `c1-landed.txt` that states the 40-hex revision carried by the `c1-driver: measured=revision` line of `.ufo/waves/round-59/final/c1-landed.txt` (`160caf750dcf15892b78ec066e66bc605ba57a5c`), as `measured=revision <hash>`. |
| I7 | D7 | executing `bash <tree>/corpus/openbao-transit-trial.sh --selftest` from the measured tree exits 0 and prints `TRANSIT_SELFTEST: PASS (cases=N)` with N >= 6; and the `SKILL.md` gate-registry row whose name cell contains `openbao-transit-trial.sh` carries `--selftest` in its selftest cell and no longer carries `none — its own five shims`. |

Commands:

```
python3 -I -B plans/round-60-c1-check.py --root <tree> [--repo <lane>] [--no-challenge] [--json]
bash plans/round-60-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
```

Output line: `C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`.
Exit 0 iff guard=1 and V==0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a fix that is a wording change the item's own condition does not read is caught by
  the forgery controls C1-F1..C1-F5 (each breaks one item's substance while keeping
  satisfied-looking text) and C1-F6 (a mutated transit selftest); each must read exactly 1
  on the diagnostic leg (`--no-challenge`).
- K2: a tree byte-identical to BASE must read `value=7 population=7`; any lower reading
  means an item is vacuous and voids the claim. The BASE census is taken with
  `--no-challenge`.
- K3: a fabricated receipt (a correction citing a file the round did not write) is the
  declared ceiling of I5/I6 and is checked by the battery controls, the receipts
  themselves and the non-author re-run — not by this counter.
- K4: I7 must be able to fail — a copy of the trial whose verdict mapping is broken must
  make `--selftest` exit non-zero with a named finding id (control C1-F6).

**Population census at BASE (must be measured, not assumed):** the checker on the BASE
tree prints `value=7 population=7`; the guard-bearing line reads `value=FAIL … guard=0`
only where the challenge cannot fire (the round-58 A4 / round-59 A3 reading).

**Named ceilings:** the seven items are a closed set fixed by the spot-check; an item's
condition is a structural read, not a semantic proof that the corrected text is true;
"last occurrence wins" lets a later line restate a fact without rewriting it; the checker
trusts the receipt files it reads (fabrication class K3).

## C2 — operability: an executed OpenBao AppRole `secret_id` custody trial

Target axis: operability (a new executed capability, `SCORECARD.md` §Capabilities).

**Frozen predicate:**

```
C2_APPROLE_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two independent
runs, each of the five falsifier shims flips exactly its designated test (baseline
vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB),
a PATH with no bao reads SETUP rc2 with no HOLDS line, and the trial's own
`--selftest` exits 0 printing APPROLE_SELFTEST: PASS (cases=N) with N >= 8; else 0.
Target 5 (BASE 0: the trial does not exist at BASE).
POP: T1 bind_secret_id; T2 secret_id_num_uses single-use; T3 secret_id_ttl expiry;
T4 secret-id-accessor custody lookup and destroy; T5 secret_id_bound_cidrs.
```

The five tests, each grounded in the sources opened this round (S123
`https://openbao.org/docs/auth/approle/`, S124
`https://openbao.org/docs/api/auth/approle/`, OpenBao docs 2.7.x):

| test | mechanic | observable |
|---|---|---|
| T1 | `bind_secret_id` decides whether role_id alone authenticates | with the default `bind_secret_id=true` a login carrying only `role_id` is refused with a named error; after `bind_secret_id=false` on the same role the same body logs in (a token is issued), proving the secret_id is the binding secret half |
| T2 | `secret_id_num_uses` bounds credential reuse | with `secret_id_num_uses=1` the first login succeeds and a second login with the same secret_id is refused; a freshly generated secret_id logs in |
| T3 | `secret_id_ttl` retires an unwrapped secret_id | with `secret_id_ttl=1s` a fresh secret_id logs in immediately and the same one is refused after expiry (>=3 s later) with a named error; a newly generated secret_id logs in |
| T4 | the accessor is a non-secret custody handle | `secret-id-accessor/lookup` returns metadata (including the remaining use count and TTL) and no secret_id value; `secret-id-accessor/destroy` invalidates a still-valid, unused secret_id, after which login with it is refused |
| T5 | `secret_id_bound_cidrs` pins a credential to a source range | with the role bound to `10.0.0.0/8` a login from 127.0.0.1 is refused with a source-address error; with `127.0.0.1/32` bound the same login succeeds |

Commands:

```
bash plans/round-60-c2.sh [revision]          # BASE when omitted; --tree DIR also accepted
bash corpus/openbao-approle-trial.sh [--work DIR] [--selftest]
```

Output line: `C2_APPROLE_TRIAL: value=V tests=5 pass=P shims=K vectors=ok/5 selftest=S guard=G`.
Exit 0 iff value=5; 1 otherwise; 2 SETUP.

**Kill rules:**
- K1: a PATH with no `bao` must read SETUP rc 2 with no `HOLDS` line; a counter that
  scores it voids the claim.
- K2: the trial must resolve `bao` through PATH; an absolute-path binary with
  shape-keyed output is the declared ceiling, checked by the receipts and a non-author
  probe, not by the counter.
- K3: no token, `secret_id` value, secret-shaped string (`hvs.`/`hvb.`) or request body
  may appear on any argv or in any printed line; a secret-shaped string in any receipt
  voids the claim.
- K4: each shim must flip exactly one test; a shim that flips none, or more than one,
  reads a vector other than `ok/5` and the claim is void.
- K5: `--selftest` must be fixture-driven (no `bao`, no network) and must be able to
  fail: a mutated copy whose shim resolution or verdict mapping is broken must exit
  non-zero with a named finding id.

**Named ceilings:** a trial that shape-keys the shim vectors reads 5 without measuring
(the round-51/57/58 ceiling class); one binary (OpenBao 2.7.2), dev-server in-memory
storage, one host; the `bind_secret_id=false` leg is a deliberate unsafe configuration
made only on a throwaway dev server; the trial does not measure AppRole's
`secret_id_bound_cidrs` interaction with proxies, `token_num_uses`, or the role's
`role_id` rotation.

## Instruments created by this round

- `corpus/openbao-approle-trial.sh` — the trial (T1–T5, shims SH1–SH5, `--selftest`).
- `plans/round-60-c1-check.py`, `plans/round-60-c1.sh`, `plans/round-60-c2.sh`,
  `plans/round-60-controls.sh` — instruments.
- `corpus/openbao-transit-trial.sh` — gains `--selftest` (I7) and its `SKILL.md`
  registry row is re-registered with that selftest.

## Pre-freeze controls (`plans/round-60-controls.sh`)

Two no-work controls (both counters on the BASE tree: C1 value=7, C2 value=0), two
positive reference readings (a tree carrying the seven fixes reads 0; a tree carrying
the trial reads 5), and the forgery / fail-closed set:

- C1-F1..C1-F5 — each breaks one item's substance while keeping satisfied-looking text;
  the checker must read exactly 1 on the diagnostic leg.
- C1-F6 — a transit trial whose verdict mapping is mutated makes `--selftest` exit
  non-zero with a named finding id (I7 fails).
- C1-F7 — a printer stub that always prints `value=0 … guard=1` fails the guard
  challenge leg.
- C1-F8 — a correction line appended *before* the line it corrects does not resolve the
  item (the after-the-superseded-line rule bites).
- C2-F1 — the trial with the T5 shim removed reads < 5; C2-F2 — a no-bao PATH reads
  SETUP; C2-F3 — a trial whose `--selftest` is removed reads < 5; C2-F4 — a single-run
  trial reads < 5; C2-F5 — a trial that prints HOLDS lines without a summary reads 0;
  C2-F6 — a trial whose SH1 shim flips two tests reads < 5.
- C2-F7 — a bao binary whose sha256 is not the pinned OpenBao 2.7.2 reads SETUP.
- C2-F8 — ambient `BAO_*`/`VAULT_*` variables exported by the caller do not change the
  readings.

The battery must read `CONTROLS: match=<N> mismatch=0` before any candidate is measured,
and the receipt pins the instrument hashes.

## Shape and write scope

One v1 wave, 15 seats, under `scripts/hyaku/ufo-wave-policy.json` (band 8–16):
5 executors, 2 scouts, 2 scribes, 1 reviewer, 1 critic, 1 mutation-tester, 1 sentinel,
1 connector, 1 revenger (attack share 6/15 = 40 %, 4/15 = 27 % on the addendum's literal
reviewer/critic/mutation-tester/labrat list). The L1 holds the canonical planner seat.
Seats return findings and files; only the L1 commits, through `scripts/hyaku/jj-lane.sh`.

### A1 — 2026-11-07, before any candidate reading

The wave is 15 seats because five disjoint write sets exist (trial, C1 checker, C2
counter, record repairs I1–I6, transit selftest I7), and giving one executor two of them
serialises the wave. No predicate, item, target, POP or kill rule changes.

### A2 — 2026-11-07, before any candidate reading

The wave is 16 seats, the band maximum, not the 15 this file's §Shape first stated:
six disjoint executable write sets exist (trial, C1 checker, C2 counter, record
repairs I1/I2/I4, transit selftest I7, the pre-freeze controls battery), and the
controls battery cannot be written by the same seat that writes the instruments it
scores. Composition: 6 executors, 2 scouts, 2 scribes, 1 reviewer, 1 critic,
1 mutation-tester, 1 sentinel, 1 connector, 1 revenger; attack share 6/16 = 37 %
(4/16 = 25 % on the addendum's literal reviewer/critic/mutation-tester/labrat list).
No predicate, item, target, POP or kill rule changes.

### A3 — 2026-11-07, before any candidate reading (L1 feasibility probe)

An L1 probe on a throwaway OpenBao 2.7.2 dev server (receipt
`.ufo/waves/round-60/final/l1-probe.txt`) measured four setup facts and one test
observable that the §C2 POP did not state. Nothing in the predicate, the target, the
five-test population or any kill rule changes; T1's observables are restated to the
measured form and the setup steps become part of the trial's contract:

1. **AppRole is not mounted on a dev server.** `POST /v1/sys/auth/approle
   {"type":"approle"}` returns 204; without it every `/v1/auth/approle/*` call is
   404 `no handler for route "auth/approle/login"`. The trial mounts it as step 0.
2. **Every request carries `Content-Type: application/json`.** A form-encoded body
   parses as empty: role creation returns 204 with defaults and every login reads
   400 `invalid role or secret ID`.
3. **`POST /v1/auth/approle/role/<r>/secret-id` carries a JSON body** (`{}` is
   enough); a body-less POST does not generate a usable secret_id.
4. **T1 restated (measured).** `bind_secret_id=false` alone is refused with 500
   `at least one constraint should be enabled on the role`. T1 is therefore three
   observables: (a) a default role refuses a role_id-only login with 400 `missing
   secret_id`; (b) creating a role with `bind_secret_id=false` and no other
   constraint is refused with that 500 text; (c) creating a role with
   `bind_secret_id=false` plus `secret_id_bound_cidrs=127.0.0.1/32` makes a
   role_id-only login return 200 with a token — the secret half is optional only
   when another constraint binds the credential.
5. **Measured refusal texts** the trial may quote: T2/T3/T4 `invalid role or secret
   ID`; T5 `source address "127.0.0.1" unauthorized by CIDR restrictions on the
   role: %!w(<nil>)`; T4's lookup response keys are `cidr_list`, `creation_time`,
   `expiration_time`, `last_updated_time`, `metadata`, `secret_id_accessor`,
   `secret_id_num_uses`, `secret_id_ttl`, `token_bound_cidrs` and carry no
   `secret_id` key.

The probe printed no secret value: it reports lengths and verdicts only. The probe
script itself lives in scratch and is not citable evidence; the transcript is.

### A4 — 2026-11-07, before any candidate reading (supersedes A3 item 4 only)

The sentinel seat measured, and the L1 re-measured independently, that the **frozen T1
text is reachable unamended**: create the role with `token_bound_cidrs=127.0.0.1/32`
(`bind_secret_id` left at its default `true`) → a role_id-only login is refused 400
`missing secret_id`; then `POST auth/approle/role/<r> {"bind_secret_id":false}` on the
same role returns 204 (the `token_bound_cidrs` constraint satisfies the server's "at
least one constraint" check) → the same role_id-only body returns 200 with a token.
Receipts: `.ufo/waves/round-60/build/R60SentinelTrial/probe-groundtruth.txt` (the
sentinel's probe5/probe6) and the L1's re-measurement in
`.ufo/waves/round-60/final/l1-probe.txt` §A4.

A3 item 4 is therefore withdrawn: T1 keeps its frozen observable (bind=true refused,
bind=false accepted on the same role) and its prerequisite is a role-level constraint
(`token_bound_cidrs`) that keeps T1's fields disjoint from T5's
`secret_id_bound_cidrs` (kill rule K4). A3 items 1, 2, 3 and 5 stand. No predicate,
target, POP, item or kill rule changes.
