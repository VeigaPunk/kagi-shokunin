# Round 61 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 61, attempt 1. Claim BASE
`c940f51689d702f1786989d56ad4663833c1452e` (round-60 verifier spot-check tip,
`round-60 verifier spot-check (integrator, hyaku): non-author admit/reject`, 2026-11-07 16:4x -03).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57, 58, 59 and 60, so no stagnation waiver is claimed. Both claims are declared here
before any candidate work; this file is committed alone as the predeclaration, then
the instruments, then the pre-freeze control battery, then the candidate.

Motivating evidence for the round:

- `corpus/lessons/round-60-verifier-spotcheck.md` §7 (non-author closure of round 60)
  routes seven defects D1–D7 that the lane must fix. All seven are unresolved at BASE
  and no lane gate reads any of them: the round-60 lesson R37 says the mutation-tester
  "produced no artifacts and no report" while `.ufo/waves/round-60/w1-results.json`
  carries its 3824-byte output and `git ls-tree` shows `build/R60MutCounters/mutants.md`;
  `SKILL.md:855` registers `plans/round-60-c2.sh` with selftest cell
  `none of its own — it runs the trial's --selftest as a conjunct`; `plans/round-60.md`
  §A3 item 2 asserts a form-encoded-body behaviour its cited receipt does not carry;
  the round-60 report's quality-trend sentence denies the new record defects D1–D3;
  the round-60 `LOG.md` wave line was rewritten in place at `818d2a82` (1 insertion,
  1 deletion against `14a6c07d`); the report's stale-lane paragraph quotes
  `launch 15:09:28` where `.ufo/watchdog.log` reads `15:03:17`; and the report's
  attack-share sentence reads `4/16 = 25 % on the addendum's literal list` where the
  literal list has three present seats (3/16 = 18.75 %) and 4/16 counts the sentinel.
- `corpus/knowledge/` holds no executed OpenBao **seal / unseal key-share** mechanic.
  The lane's trials cover token/lease (r49), response wrapping (r51), KV v2 versions
  (r52), audit devices (r57), ACL policies (r58), transit (r59) and AppRole (r60);
  `grep -rlE 'unseal|shamir' corpus/knowledge/` matches no entry that measures the
  Shamir seal. Seal-key custody is the root of every other custody property the lane
  holds: which shares exist, how many are required, whether they are persisted, and
  how a lost root token is regenerated.

## C1 — calibration: the seven round-60 routed record defects are resolved and re-checkable

Target axis: calibration (mismatch count between the lane's own statements and the
observed repository state).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_ROUTED: value = the number of UNRESOLVED items over POP = 7 fixed routed-defect
items (I1..I7 below), when GUARD = 1, else FAIL; target 0 (BASE 7).
An item is UNRESOLVED iff its named condition does not hold on the measured tree.
GUARD = 1 iff the checker evaluates all seven items (prints population=7 with
i1..i7 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
is the digit in the I5 correction line's `deletions=1` field changed from 1 to 2,
prints exactly value+1, and a printer stub that always prints value=0 fails that same
challenge.
```

Every number an item compares is derived by the checker from the measured tree or from
a named revision of the lane repository; no constant in the checker carries a fact the
measured tree asserts. "Last occurrence wins" is the correction convention: a correction
is appended, never rewritten into the line it corrects.

| id | routed defect | required condition on the measured tree |
|---|---|---|
| I1 | spot-check D1 | `corpus/lessons/round-60.md` carries, after the line containing `R37`, a line matching `supersedes R37` that states `results=<R> output=<B>` where R = the number of result records in `.ufo/waves/round-60/w1-results.json` and B = the byte length of the `R60MutCounters` record's final output (both derived from that file), and that names `mutants.md`. |
| I2 | D2 | `bash <tree>/plans/round-60-c2.sh --selftest` exits 0 printing `C2_SELFTEST: PASS (cases=N)` with N >= 6 from isolated fixtures (no `bao`, no network); a copy of that script whose verdict mapping is broken exits non-zero printing a named `FINDING`; and the `SKILL.md` gate-registry row whose name cell contains `plans/round-60-c2.sh` carries `--selftest` in its selftest cell and no longer carries `none of its own`. |
| I3 | D3 | `plans/round-60.md` carries, after its §A6 block, an appended amendment whose heading matches `^## Amendment A7` that names `A3 item 2`, `form` and `l1-probe.txt` and states the item is withdrawn (the word `withdrawn`); and `corpus/lessons/round-60.md` carries a line naming `M60-2` and `A3 item 2` and `second instance`. |
| I4 | D4 | `corpus/lessons/round-60.md` carries a line matching `supersedes the round-60 quality-trend sentence` that quotes `no new record defect`, names `D1`, `D2` and `D3`, and states `three` new record defects. |
| I5 | D5 | `LOG.md` carries, after the round-60 wave line, a line matching `supersedes the round-60 LOG wave line` that names `818d2a82` and `14a6c07d`, states `insertions=1 deletions=1`, and states the mechanism (`rewritten in place`); when `--repo` is given the checker derives the two numbers with `git diff --numstat 14a6c07d 818d2a82 -- LOG.md`. |
| I6 | D6 | `corpus/lessons/round-60.md` carries a line matching `supersedes the round-60 stale-lane paragraph` that names the driver launch line `2026-11-07T15:03:17-03:00 launch kagi round=60` and at least three `-03:00` timestamps that each occur in `git log --format='%ci' a677c78e..818d2a82` (derived when `--repo` is given). |
| I7 | D7 | `corpus/lessons/round-60.md` carries a line matching `supersedes the round-60 attack-share arithmetic` that states `3/16` and `4/16` and both `18.75` and `25`, where 3 = the number of attack roles from `{reviewer, critic, mutation-tester, labrat}` present in `.ufo/waves/round-60/w1-results.json`, 4 = that number plus the sentinel, and 16 = the result count (all derived from that file). |

Commands:

```
python3 -I -B plans/round-61-c1-check.py --root <tree> [--repo <lane>] [--no-challenge] [--json]
bash plans/round-61-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
```

Output line: `C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`.
Exit 0 iff guard=1 and V==0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a fix that is a wording change the item's own condition does not read is caught by
  the forgery controls C1-F1..C1-F6 (each breaks one item's substance while keeping
  satisfied-looking text) and C1-F7 (a mutated `round-60-c2.sh --selftest`); each must
  read exactly 1 on the diagnostic leg (`--no-challenge`).
- K2: a tree byte-identical to BASE must read `value=7 population=7`; any lower reading
  means an item is vacuous and voids the claim. The BASE census is taken with
  `--no-challenge`.
- K3: a fabricated receipt (a correction citing a file the round did not write) is the
  declared ceiling of I1/I5/I6 and is checked by the battery controls, the receipts
  themselves and the non-author re-run — not by this counter.
- K4: I2 must be able to fail — a copy of `plans/round-60-c2.sh` whose verdict mapping is
  broken must make `--selftest` exit non-zero with a named finding id (control C1-F7).

**Population census at BASE (must be measured, not assumed):** the checker on the BASE
tree prints `value=7 population=7`; the guard-bearing line reads `value=FAIL … guard=0`
only where the challenge cannot fire (the round-58 A4 / round-59 A3 / round-60 A4 reading).

**Named ceilings:** the seven items are a closed set fixed by the spot-check; an item's
condition is a structural read, not a semantic proof that the corrected text is true;
"last occurrence wins" lets a later line restate a fact without rewriting it; the checker
trusts the receipt files it reads (fabrication class K3); I6's timestamp set is bounded
by the revision range the item names.

## C2 — operability: an executed OpenBao seal / unseal key-share custody trial

Target axis: operability (a new executed capability, `SCORECARD.md` §Capabilities).

**Frozen predicate:**

```
C2_SEAL_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two independent
runs, each of the five falsifier shims flips exactly its designated test (baseline
vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB),
a PATH with no bao reads SETUP rc2 with no HOLDS line, and the trial's own
`--selftest` exits 0 printing SEAL_SELFTEST: PASS (cases=N) with N >= 8; else 0.
Target 5 (BASE 0: the trial does not exist at BASE).
POP: T1 init share/threshold arithmetic and non-persistence; T2 unseal threshold and
duplicate-share refusal; T3 seal and the sealed-state request; T4 generate-root with
OTP decode; T5 rekey refused on this build (docs vs binary).
```

The five tests, each grounded in the sources opened this round (S125
`https://openbao.org/docs/concepts/seal/`, S126
`https://openbao.org/docs/commands/operator/rekey/`, S127
`https://openbao.org/docs/commands/operator/generate-root/`, OpenBao docs 2.7.x):

- **T1 init.** A `bao server` with `storage "raft"` in scratch, `tls_disable = 1`, bound to
  127.0.0.1: `operator init -key-shares=5 -key-threshold=3` returns 5 shares and threshold
  3; `sys/seal-status` reads `initialized=true sealed=true t=3 n=5`; and no file under the
  storage path contains any of the five base64 shares (custody: shares are held by
  operators, never by the server).
- **T2 unseal threshold.** One share ⇒ `progress 1/3`, `sealed=true`; the SAME share again
  ⇒ progress stays `1/3` (a repeated share does not count); a second distinct share ⇒
  `2/3`; a third ⇒ `sealed=false`, `t=3 n=5`.
- **T3 seal.** With the root token, `operator seal` ⇒ `sealed=true`; an authenticated
  request while sealed ⇒ HTTP 503; `sys/seal-status` without a token ⇒ HTTP 200.
- **T4 generate-root.** `operator generate-root -init` yields a nonce, an OTP and
  `required=3`; three shares progress 1,2,3 to `complete=true` with an encoded token;
  `-decode` with the OTP yields a 26-character token that authenticates (HTTP 200 on
  `sys/seal-status`); `-decode` with a wrong OTP does not yield that token.
- **T5 rekey refused.** `operator rekey -init -key-shares=3 -key-threshold=2` exits
  non-zero with HTTP 405 `unsupported operation` on both the raft server and an `inmem`
  server, while S126 documents the command — a measured docs-vs-binary divergence, not a
  citation.

The trial is `corpus/openbao-seal-trial.sh`: `[--work DIR] [--selftest]`, `bao` resolved
through PATH only, every server started under `setpriv --pdeathsig KILL` on 127.0.0.1,
throwaway storage in scratch, no real vault, account or secret touched. Shims are
`KAGI_SEAL_SHIM=SH1..SH5` client-side verdict flips; `--selftest` is fixture-driven
(no `bao`, no network) and must fail with a named finding on a mutated copy.

## Control plan (pre-freeze, committed before the candidate reading)

`plans/round-61-controls.sh` runs, on scratch copies, the cheapest controls that skip the
claimed work:

- **No-work control (C1).** The BASE tree read by the frozen checker with `--no-challenge`
  must print `value=7 population=7` — a do-nothing tree cannot reach the target.
- **No-work control (C2).** The BASE tree read by `plans/round-61-c2.sh` must print
  `value=0 … (absent)`.
- **Forgery controls C1-F1..C1-F7.** Each takes the candidate tree, breaks exactly one
  item's substance while leaving satisfied-looking text (a R37 correction with the wrong
  result count; a `--selftest` cell naming a script with no `--selftest`; an A7 amendment
  that withdraws nothing; a quality-trend correction naming two of three ids; a LOG
  correction with `deletions=2`; a stale-lane correction with an invented timestamp; a
  rekey/attack-share line with the wrong fraction; a `round-60-c2.sh` whose verdict
  mapping is inverted) and must read `value=1` on that item and 0 on the others.
- **Shim controls (C2).** Each `KAGI_SEAL_SHIM=SHn` run must read `BROKEN holds=4
  broken=1` with exactly test n moved.
- **Printer-stub control.** A stub that always prints `value=0` must fail the guard's
  challenge leg.

The battery receipt is `.ufo/waves/round-61/controls/controls-prefreeze.txt` and must read
`CONTROLS: match=<N> mismatch=0` before the candidate reading is taken.

## Wave plan — ONE v1 wave, 16 seats (run-15 band 8–16)

L1 `KagiR61` holds the canonical planner seat (the validator rejects `planner`), is the
sole integration owner and committer, and lands the records fixes it owns. Roles: 2 scout,
6 executor, 2 scribe, 1 reviewer, 1 critic, 1 mutation-tester, 1 sentinel, 1 connector,
1 revenger = 16. Attack seats: reviewer + critic + mutation-tester + sentinel = 4/16
(25 %); on the addendum's literal list (no labrat exists) 3/16 = 18.75 %, stated both ways.

## Frontier step (§2b)

- `corpus/SOURCES.md` 124 → 127 (S125 seal concepts, S126 operator rekey, S127
  generate-root), every row opened this round with a located quote in the lesson `## Gate`.
- One mistake mined into `corpus/lessons/round-61.md` `## Mistakes` with a fix shown able
  to fail.
- At least one claim is sourced: C2's T5 rests on S126 and T1/T4 on S125/S127.
- `considerthese/`: at most one still-unimplemented proposal, grounded through the lane bar.
- Assimilation: the shokuknow `merge/kagi/` package is read; `Assimilation: none` is
  written unless a theme fits this round's claims.
