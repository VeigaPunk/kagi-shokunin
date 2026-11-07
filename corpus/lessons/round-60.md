# Round 60 — kagi (secrets & vault ops)

Lane: kagi. Round 60, attempt 1. Claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`
(round-59 verifier spot-check tip). Frozen plan `plans/round-60.md` (predeclaration
`cd631737`, amendments §A1–§A6, all landed before the recorded candidate reading).
Wave `kagi-r60-w1`, 16 seats (v1 band 8–16).

Claims: **C1 calibration** — the seven round-59 routed record defects are resolved and
re-checkable (`C1_ROUTED` 7 → 0, population 7). **C2 operability** — an executed OpenBao
AppRole `secret_id` custody trial with its own fixture-driven `--selftest`
(`C2_APPROLE_TRIAL` 0 → 5).

## What the round measured

- C1, BASE: `bash plans/round-60-c1.sh a677c78e` ⇒ diagnostic
  `C1_ROUTED: value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0`, rc 1
  (the guard-bearing line reads `value=FAIL … guard=0` because the +1 challenge cannot
  fire on a tree where I1 is already unresolved — the round-58 A4 / round-59 A3 reading).
- C1, candidate: `bash plans/round-60-c1.sh <candidate>` ⇒
  `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=1`, rc 0.
- C2, BASE: `bash plans/round-60-c2.sh a677c78e` ⇒
  `C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (absent)`,
  rc 1.
- C2, candidate: `C2_APPROLE_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1
  guard=1`, rc 0.
- Pre-freeze battery `plans/round-60-controls.sh`: `CONTROLS: match=<N> mismatch=0`
  (receipt `.ufo/waves/round-60/controls/controls-prefreeze.txt`).

## Gate (rows written this round)

Two rows were opened live this round and admitted; both were re-opened by the scout with
a desktop browser user agent and the decoded body kept as a capture. No third page was
opened, so the round records no rejected row — the one rejection class it does record is
the pages' *silence* (below), which is a documented gap, not a rejected source.

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S123 | https://openbao.org/docs/auth/approle/ | 2026-11-07 | "The bind_secret_id constraint requires secret_id to be presented at the login endpoint." (§Further constraints, 12 words, byte 44813 line 119) | admit, tier A | the page states the RoleID/SecretID split and the constraints the trial varies; flip: a page revision that drops the constraint prose |
| S123 (second quote grounding the row's `secret_id_bound_cidrs` scope) | same | 2026-11-07 | "secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole." (§Further constraints, 17 words) | admit | the T5 mechanic's documented rule; flip: the parameter removed from §Further constraints |
| S124 | https://openbao.org/docs/api/auth/approle/ | 2026-11-07 | "secret_id_num_uses (integer: 0) - Number of times any particular SecretID can be used to fetch a token" (§Create/Update AppRole › Parameters, 17 words, byte 23092 line 44) | admit, tier A | the API parameter table is the trial's request contract; flip: the parameter's default or meaning changing |
| S124 (second quote grounding the login contract) | same | 2026-11-07 | "role_id is always required; if bind_secret_id is enabled (the default) on the AppRole, secret_id is required too." (§Login with AppRole, 17 words, byte 117685 line 293) | admit | the login endpoint's required fields, and the only place either page states the `bind_secret_id` default; flip: the sentence removed |

Rejected class (recorded, no row): both pages document **no refused-login shape** — the
scout measured `grep -cE '\b4[0-9][0-9]\b'` ⇒ 0 on both captured bodies, no `"errors"`
key, and the only refusal-shaped sentence anywhere is S123 §User lockout ("instead
returning immediately with a permission denied error"), which is the lockout path, not an
ordinary wrong-`secret_id` refusal. Consequence, and the reason the entry marks it: every
refusal text the trial quotes is **measured**, never cited from S123/S124. Flip: a page
revision that documents the login error body.

Registry effect: `corpus/SOURCES.md` 122 → 124 data rows (S123, S124; both tier A,
`mined`, `180d`), and `corpus/source-fetches.tsv` gains 2 rows. No existing row's
`status`, `recheck` or `used-by` cell changed. The entry's `recheck:` is `180d`, not
`on-release`: the lane has no bound on-release clock for these pages (S090 is a `90d`
feed row), so QM70's on-release rule does not apply and a cadence is the honest clock.

## Mistakes

### M60-1 — a gate registered with no self-invocation mode

- **class**: self-description vs instrument — a registry row says `kind: gate` while its
  `selftest` cell says `none`.
- **evidence**: `SKILL.md:847` at BASE registers `corpus/openbao-transit-trial.sh` as
  `kind: gate` with `selftest: none — its own five shims and the clean-room leg are the
  falsifiers`; the round-59 spot-check routed it as D7. The five shims prove the trial
  discriminates a broken *trial*; they say nothing about whether the instrument's own
  assertions can fail.
- **captured-by**: none. No lane gate read the registry's `selftest` cell against `kind`,
  and the round-59 reviewer and sentinel passed the row. The Gate standard was written
  prose, not a check.
- **fix**: `corpus/openbao-transit-trial.sh` gains a fixture-driven `--selftest`
  (`TRANSIT_SELFTEST: PASS (cases=9)`, no `bao`, no network) and its row is re-registered
  with that selftest; item I7 additionally requires the selftest to fail on a mutated
  copy; `corpus/QUALITY.md` QM76 makes the rule a criterion for every future landing.
- **shown able to fail**: `.ufo/waves/round-60/build/R60ExecTransitSelftest/selftest-mutant.txt`
  ⇒ `TRANSIT_SELFTEST: FAIL (cases=9 failed=5)` with named `FINDING TRANSIT-ST-SHIM-SH4`
  / `-SH5` ids; the same mutation is item I7's third leg, so a PASS printer cannot
  satisfy it.

### M60-2 — an amendment grounded on a receipt that did not carry its observables

- **class**: provenance overreach in a plan amendment — a restatement of a frozen item
  citing a probe that measured a different configuration.
- **evidence**: §A3 item 4 restated T1's observables while saying "nothing changes", and
  its cited probe (`.ufo/waves/round-60/final/l1-probe.txt`) carried neither the
  `bind_secret_id=false` acceptance nor the constraint refusal, and contradicted the
  third observable (critic C2.7, sentinel D-S1).
- **captured-by**: none — no rule required an amendment to cite a receipt containing
  every observable it restates.
- **fix**: §A4 withdrew A3 item 4 after the sentinel and the L1 both measured the frozen
  T1 text reachable unamended (a `token_bound_cidrs` constraint makes the `bind_secret_id`
  update acceptable); `corpus/QUALITY.md` QM77 makes the rule a criterion.
- **shown able to fail**: the A4 re-measurement block in
  `.ufo/waves/round-60/final/l1-probe.txt` carries all three T1 observables (refusal,
  accepted update, accepted role_id-only login) — the receipt A3 should have cited.

## Routed dispositions

Ids are unique in this table (the lane continues its plain-integer convention). The round-59 lesson reused `R20`, `R21` and `R22` twice each in its own routed table (spot-check D3); those duplicate ids are superseded here by `R32`…`R39` and are not reissued.

| id | finding | source | disposition |
|---|---|---|---|
| R32 | the C2 counter reads the trial's `--selftest` PASS line, so a PASS printer that ignores its fixtures would satisfy the conjunct | critic C2.4 | **named ceiling** in the C2 row and the report: the trial's own mutation receipt and the sentinel's five selftest mutations are the falsifiers; a counter-side mutation leg is routed to round 61 |
| R33 | K3's argv clause has no lane instrument: the trial's stdin-only credential path is proven by the sentinel's `strace`/`/proc` sampler for this round only | critic C2.5 | **routed**: a committed argv sampler is a round-61 candidate; the round cites the sentinel receipt `.ufo/waves/round-60/build/R60SentinelTrial/dynamic-run.txt` |
| R34 | T3's 1 s `secret_id_ttl` races the CLI round trip under fleet load; the trial carries ≤3 freshly generated retries per leg | sentinel D-S2 | **routed**: raise the TTL to 2 s or make the expiry leg deterministic next round; the retries are inside the frozen POP and are stated in the entry's §Bounds |
| R35 | the trial's in-file documentation does not state that the `bind_secret_id=false` leg is an unsafe configuration made only on a throwaway server | sentinel D-S4 | **routed**: a comment-only fix next round; the review's check 6 records scope PASS / documentation FAIL |
| R36 | attack-share arithmetic: 4/16 = 25 % on the addendum's literal list (reviewer, critic, mutation-tester, labrat) — the wave has no labrat (the validator refuses the role), so the literal reading is 3/16 = 19 %; counting sentinel and revenger gives 6/16 = 38 % | critic H5 | **recorded, not resolved**: the round reports both readings; the validator enforces the band only, so the lane states which definition it uses (this round: reviewer + critic + mutation-tester + sentinel as attack seats = 4/16) |
| R37 | the mutation-tester seat produced no artifacts and no report: the round's independent mutant battery is missing | wave `w1-results.json` | **routed**: the reviewer's 35-probe table and the sentinel's five selftest mutations cover part of the ground; a fresh mutation seat is a round-61 item |
| R38 | `.ufo/waves/round-60/final/` also holds pre-candidate L1 artifacts (the feasibility probe) beside the candidate gate receipts | critic H6 | **named**: the probe is dated and labelled; the three gate receipts carry their own readings |
| R39 | the C2 counter's `candidate.txt` first pinned the trial's pre-final bytes (`bd2d6647`), then the final bytes (`a228e312`) | sentinel D-S3 | **resolved in-round**: the receipt header names the superseded reading; the final reading is re-run at the candidate and cited by the report |
| R40 | the GUARD's third clause (a printer stub must fail) discriminates nothing: the stub prints `value=0` while the expected value is `count+1 >= 1`, so the clause is true for every stub | mutation-tester C1-M4b | **routed to the frozen predicate's owner**: the kill is to make the stub print the expected value (or inject `--expect`) and require it to fail; a frozen-predicate change is the operator's, not this round's |
| R41 | a checker that falls back to the lesson's stated case count when the receipt is missing survives the 46-case selftest | mutation-tester C1-M5s | **routed**: add selftest case `i2-selftest-receipt-missing` and battery control C1-F9 (remove the receipt → diagnostic 1); the shipped derivation is already fail-closed |
| R42 | a counter that ORs the two real runs survives the battery: `C2-F4`'s wrapper also refuses the `none` and `ambient` legs, so the `real2` conjunct is never isolated | mutation-tester C2-M2 | **routed**: `C2-F4` must count only the two real runs (exclude the no-bao leg by `command -v bao`, the ambient leg by `BAO_ADDR`) and assert each run's vector and summary |
| R43 | a counter that accepts a summary reading `HOLDS holds=5 broken=0 error=1` survives the battery | mutation-tester C2-M4 | **routed**: add control `C2-F9` (an `error=1` summary must read 0); the shipped counter already requires `error=0` on both real runs and the ambient leg |

## Bounds

- One binary (OpenBao 2.7.2), one host, dev-server in-memory storage, one AppRole mount
  per trial run. The trial does not measure `secret_id_bound_cidrs` behind a proxy,
  `token_num_uses`, `role_id` rotation, or the lockout path S123 documents.
- C1's seven items are a closed set fixed by the round-59 spot-check; each item is a
  structural read, not a semantic proof that the corrected text is true. The checker
  trusts the receipt files it reads (fabrication class K3), and the guard's +1 challenge
  cannot fire on a tree where I1 is already unresolved.
- The T3 retry window is a robustness measure inside the POP, not a reinterpretation: the
  shipped receipts come from the retry-enabled script, and the superseded single-attempt
  receipt was overwritten in place (named in the seat report).
- The wave's 16th seat (mutation-tester) produced nothing; the round's attack evidence is
  the reviewer, critic, sentinel and revenger outputs.

## Sources & frontier

Census, round start (2026-11-07, before any edit):

```
$ /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
kagi ok /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
rc=0   (122 data rows, 19 standing W04 duplicate-URL warnings)
```

Census, round end (after the two appends):

```
$ /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
kagi ok /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
rc=0   (124 data rows, the same 19 W04 warnings)
```

Rows added by tier: 2 tier A (`S123`, `S124`), 0 tier B, 0 tier C, 0 rejected rows.
Rows touched old→new: none (`status`, `recheck` and `used-by` cells unchanged for every
existing row). Frontier rows advanced: none — the two new rows are core ground for the
AppRole entry, not frontier leads; the round's frontier step is the curated pair plus the
recorded rejection class (the pages' silence on refusal shapes).

Assimilation: none. The shokuknow `merge/kagi/` package stages no AppRole material (the
connector sweep found none), and the round's claim cap is spent on C1 + C2.

## Adjacency

The connector sweep found no sibling lane holding AppRole, `secret_id` or the
trial+shim+counter-with-selftest pattern; the `C1_ROUTED` routed-record idiom is kagi's
own. Contested scope reported, not absorbed: the trial's `strace`/argv evidence is
round-scoped (R33), and the carried `ADJACENCY_SCOPE: DEFECT`
(`breadth_drift=5 breadth_unverified=1`, `stale_basis=0`) is unchanged and named in
`.ufo/waves/round-60/final/scope-candidate.txt`, not absorbed.
