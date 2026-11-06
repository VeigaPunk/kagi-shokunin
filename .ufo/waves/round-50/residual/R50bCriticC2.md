# R50bCriticC2 — residual attack on round-50 C2 (calibration)

Seat: R50bCriticC2 (critic, leaf). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master.
BASE `565c43a874b59cd216f4a55c8742db48fa854f16`. Predeclaration `7d3b2c01b375d5459abd7da79bb4063b7d728fc7`.
Landed candidate under attack: **C2 `e4abab1d23b731c0c042be9bc50b19c9f9313dcb`** (journal
`.ufo/waves/round-50/expectation-migrations.json`, ten ledger expects migrated, stamps restamped).
Scratch `$HYAKU_SCRATCH/kagi-r50/R50bCriticC2/` (all clones, fixtures, receipts there).
Instruments `plans/round-50*.sh`, `plans/round-50-controls.sh` and the controls fixtures were **not edited**;
every forgery was built in a `git clone --shared` of the lane under scratch, each asserted
`git rev-parse --show-toplevel` = the fixture dir before any commit. No `bao` process was started; no tool installed.

**Verdict: C2 is NOT falsified.** The frozen predicate reads 0 at the candidate and 10 at BASE, all six
guards fire on every direct forgery, the ten journal reasons re-derive from git, and the kill rules hold.
Four weaker forgeries still score 0 — recorded below as ceiling findings (F1, F2), not as falsifications;
the landed candidate does not exhibit them (each was verified against the landed bytes).

Receipts: `.ufo/waves/round-50/residual/R50bCriticC2-receipts/{c2-base.txt,c2-cand.txt,walk.tsv,forgeries.txt,verify-cand.txt}`.

---

## (a) Counter, both revisions — PASS

| run | command | rc | last output line |
|---|---|---|---|
| candidate | `bash /home/…/kagi-shokunin/plans/round-50-c2.sh e4abab1d23b731c0c042be9bc50b19c9f9313dcb` | 0 | `C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK R21-02=OK R22-03=OK R24-05=OK R24-06=OK R24-15=OK R31-02=OK R33-02=OK R34-03=OK R38-01=OK` |
| BASE | same script, `565c43a874b59cd216f4a55c8742db48fa854f16` | 0 | `C2_LEDGER_DRIFT: value=10 ids=10 changed=0 verify_rc=1 R13-01=FAIL … R38-01=FAIL` |

Second line of each run: candidate `CLAIM_LEDGER: FAIL (claims=10 failed=0 deferred=0 stamped=124 stale=0 missing=0 unresolved_ids=1102 labeled_ids=121 host_skipped=0)`;
BASE `CLAIM_LEDGER: FAIL (claims=10 failed=10 deferred=0 stamped=124 stale=0 missing=0 unresolved_ids=1090 …)`.
Matches the predeclared BASE 10 → target 0. Copy of both runs: `receipts/c2-base.txt`, `receipts/c2-cand.txt`.

Every migrated expect was also re-measured directly in a clone checked out at the candidate
(`git checkout --detach e4abab1`, `receipts/` not needed — lines below are the live output):

```
R13-01  grep -c '^## Round ' SCORECARD.md                         -> 68
R21-02  SOURCES_CENSUS: CLEAN (rows=107 A=103 B=2 C=2 queued=1 mined=102 rejected=4 entries_sourced=15 legacy=21 captures=107 inrow=16 inrow_only=0 inrow_nonreproducing=12)
R22-03  REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=61 invalid=0)
R24-05  ROW_IDENTITY: stamps count=124 sha256=c7673d14599c6ebde1a5b1f608ccc541f396fe6f24d5c00fdeee3bee35c06534
R24-06  ROW_IDENTITY: scorecard-rounds count=68 sha256=7a6a21953d7d641ca2a2416eac36324b777fd4493f972ec530341dc7ff08c40e
R24-15  ROW_IDENTITY: revision-added count=61 sha256=9b7e9b8c9b4bb5526fc8093ff81679db1494083dafbcc0b6d42f65eaa8604e48
R38-01  bash plans/round-38-c1.sh                                 -> 8
```

## (b) Journal re-derivation against git history — PASS (every named commit moves the population as stated; no growth commit omitted; no population fell)

Method: clone of the lane at scratch, `git checkout --detach <c>` per commit, then the ledger's own
population measures — `grep -c '^## Round ' SCORECARD.md`, `grep -c '[^[:space:]]' corpus/stamps.tsv`,
`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`, `grep -c '^S[0-9]' corpus/quote-bodies.tsv`,
`python3 corpus/revision-audit.py --history c2cab35…`, `bash corpus/sources-census.sh`,
`python3 -I -B corpus/quote-locate.py`. Full table: `receipts/walk.tsv` (21 lines: header + 20 commits; headings, stamps, SOURCES rows, quote rows,
located, census CLEAN flag, revision-added, full census line).

| id | journal claim | re-derived | verdict |
|---|---|---|---|
| R13-01 | 56 at `209147c`; +11 across `6d6b486`(2) `65f66e1`(2) `c70bfb0` `92c394c` `072bb0b` `0bd8888` `412efc7` `8775582` `a74ae53` = 67 at BASE; +1 at `6963a35` | 56 → 58 → 60 → 61 → 62 → 63 → 64 → 65 → 66 → 67 → 68; the two unnamed SCORECARD-touching commits (`0cb7814`, `7ce3fe7`) add **0** headings | exact |
| R21-02 / R31-02 / R33-02 / R34-03 | rows 98 at `209147c`; `0ad617a` +S099; `072bb0b` +S100-S102; `8775582` +S103-S104; `a74ae53` +S105 (105 at BASE); `6963a35` +S106/S107; census FAILED at the three SOURCES-touching commits `65f66e1`/`0ad617a`/`072bb0b`, CLEAN from `412efc7`, `entries_sourced` first 15 at `412efc7`; B/C/queued/rejected/legacy/inrow unchanged | 98 (CLEAN, entries_sourced=14) → 99 → 102 → 104 → 105 → 107; FAILED at `65f66e1` `c70bfb0` `0ad617a` `92c394c` `072bb0b` `0bd8888`, CLEAN from `412efc7` (entries_sourced 15); B=2 C=2 queued=1 rejected=4 legacy=21 inrow=16 at both ends | exact under the reason's own scope (the three named are precisely the SOURCES-touching failing commits; `c70bfb0`/`92c394c`/`0bd8888` touch neither SOURCES.md nor knowledge) |
| R22-03 | added=49 at `f8413db`; +10 `b944735`; +1 `6d6b486`; +1 `a74ae53`; round 50 adds no stamped path | 49 → 59 (`b944735`) → 60 (`6d6b486`) → 61 (`a74ae53`) → 61 (`6963a35`) → 61 (candidate). Stamp path set: `289e808→b944735` adds exactly 10 paths, removes 0; `d00a543→6d6b486` adds `corpus/lessons/round-42.md`; `7ce3fe7→a74ae53` adds `corpus/knowledge/iso-11770-3-edition-status.md`; `6963a35→e4abab1` path-set diff empty | exact |
| R24-05 | 122 at `88374f9`; +`round-42.md` at `6d6b486`; +ISO entry at `a74ae53`; membership unchanged in round 50 | 112(`f8413db`) → 122(`88374f9`,`b944735`) → 123(`6d6b486`…`7ce3fe7`) → 124(`a74ae53`…); membership diff 0 in the C2 commit (only the `corpus/claim-ledger.tsv` digest/byte row was restamped: `104 50612` → `104 51668`) | exact |
| R24-06 | 56 → 68 by the same commits, "every round-41 heading line retained" | count 56 (`209147c`) → 68 (candidate); `comm -23` of heading lines at `209147c` vs candidate is **empty** (no heading line lost) | exact |
| R24-15 | 49 → 61 by `b944735`(+10) `6d6b486`(+1) `a74ae53`(+1); no original path dropped | revision-audit `dropped=0` at every commit walked; added 49→59→60→61 | exact |
| R38-01 | expect set at `b944735` with 5 located; `072bb0b` added three quote-manifest rows | quote-bodies rows 5 at `b944735`, 8 at `072bb0b`; located 5 → 8; no other commit touches the manifest | exact |

No population fell at any commit in the window: headings 56→68, stamps 122→124, SOURCES rows 98→107,
quote rows 5→8, revision-added 49→61, entries_sourced 14→15 — all monotone. Nothing was migrated that a
regression should have fixed.

## (c) Kill rules — PASS

| rule | command | result |
|---|---|---|
| R25-02, R29-01, R29-02, R38-03 byte-identical BASE↔candidate | `git show 565c43a:corpus/claim-ledger.tsv \| grep -P '^<id>\t'` vs the candidate row | all four `IDENTICAL` |
| no ledger row lost | id sets from both revisions, `sort` + `diff` | `86` vs `86`, `diff` empty, `uniq -d` empty |
| every new expect anchored `^…$` | per-entry check on the journal's 10 `new_expect` | 10/10 `startswith('^') and endswith('$')` True |
| only the frozen ten rows' expects moved | per-row field diff BASE↔candidate | changed fields are exactly `[3,6]` for the ten ids; `changed but not frozen: []`; journal ids == frozen ids set; 10 entries, 10 unique ids |
| G2 columns (1,2,4,5) | field comparison | identical for all ten |
| note provenance | BASE note vs candidate note | append-only for 10/10 (each note is a strict prefix of its successor; the appended sentence is `…migrated to the measured live line (journal .ufo/waves/round-50/expectation-migrations.json).`) |

## (d) Forgery battery — the six guards fire; four weaker forgeries still score 0

Every forgery is a separate `git clone --shared` of the lane at `e4abab1`, one commit, toplevel asserted,
measured with `bash plans/round-50-c2.sh --tree <fixture>`. All lines in `receipts/forgeries.txt`.

Refused (exit 2, `SETUP`, never a zero):

| forgery | mutation | counter line |
|---|---|---|
| F1b digit-class expect | R13-01 expect `^68$` → `^6[0-9]$`, journal made self-consistent so G5 passes and G6 is reached | `C2_LEDGER_DRIFT: SETUP reason=G6-not-discriminating-R13-01` |
| F8b wildcard expect | R24-05 expect → `^.*$`, journal consistent | `C2_LEDGER_DRIFT: SETUP reason=G6-not-discriminating-R24-05` |
| F2 repointed command | R24-05 command → `bash corpus/row-identity.sh ledger-r1` | `C2_LEDGER_DRIFT: SETUP reason=G2-columns-R24-05` |
| F3 empty reason | R13-01 journal reason → `""` | `C2_LEDGER_DRIFT: SETUP reason=G5-journal-R13-01` |
| F4 boundary row | R38-03 expect `located=5` → `located=8` | `C2_LEDGER_DRIFT: SETUP reason=G3-boundary-R38-03` |
| F5 producer edit | `corpus/row-identity.sh` + 1 appended comment line | `C2_LEDGER_DRIFT: SETUP reason=G1-changed-corpus/row-identity.sh` |
| F6 row dropped | R31-02 row deleted | `C2_LEDGER_DRIFT: SETUP reason=G4-row-count-R31-02` |

Control (must not score 0): F5-stale R13-01 expect `^67$` (a plausible but stale value) →
`C2_LEDGER_DRIFT: value=1 … R13-01=FAIL …` — the counter distinguishes stale from measured.

Accepted (score 0 — **ceiling findings**):

| forgery | mutation (journal updated to match, stamps restamped via `corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)`) | counter line |
|---|---|---|
| P1 unanchored | R24-06 expect → `ROW_IDENTITY: scorecard-rounds count=68 sha256=7a6a…` (no `^`/`$`) | `C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 … R24-06=OK …` |
| **P2 count-only** | R24-06 expect → `count=68` — the identity digest **deleted** | `C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 … R24-06=OK …` |
| P3 alternation | R13-01 expect → `^(67\|68)$` | `C2_LEDGER_DRIFT: value=0 … R13-01=OK …` |
| P4 note erased | R24-15 note (field 6) → `x`, expects untouched | `C2_LEDGER_DRIFT: value=0 … R24-15=OK …` |

---

## Findings

### R50bC2-F1 — defect (ceiling; does NOT falsify the candidate): G6 tests discrimination only, never anchoring or identity retention
- Command: `bash plans/round-50-c2.sh --tree <clone of e4abab1 with R24-06 expect = 'count=68' and the journal's new_expect matching>`, rc 0.
- Last output line: `C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK … R24-06=OK …`
- Impacted axis: calibration. G6 rejects an expect that cannot tell 67 from 68, but accepts a *prefix* expect
  that drops the sha256 that R24-06 exists to pin (`row-identity.sh` header: "a count-preserving identity swap
  passed every one of them at round-24 BASE"). An unanchored expect passes G6 for the same reason: G6 never
  looks for `^…$`.
- Frozen-predicate status: **names a ceiling, not a falsification.** The predicate text lists G1–G6 and none of
  them requires anchoring; the landed R24-06 keeps the full digest (`count=68 sha256=7a6a2195…`), verified live.
- Smallest safe correction: route a G7 for the next predeclaration — every changed expect MUST match `^\^.*\$$`,
  and for a measured line carrying `sha256=`/`count=`, the expect MUST contain the same count **and** the full
  64-hex digest. Instruments stay frozen; the candidate is not edited.

### R50bC2-F2 — note (ceiling): field 6 (note) may move freely, so the ledger's provenance prose is unprotected
- Command: `bash plans/round-50-c2.sh --tree <clone of e4abab1 with R24-15's note replaced by 'x'>`, rc 0.
- Last output line: `C2_LEDGER_DRIFT: value=0 … R24-15=OK …`
- Impacted axis: calibration honesty (a review trail that can be erased silently still scores 0). G2 permits
  "only the expect (3) and note (6) columns may move"; nothing checks that the note only *grows*. The landed
  notes are append-only (verified: 10/10 BASE note is a prefix of the candidate note), so this is a ceiling, not
  a defect in the landed candidate.
- Smallest safe correction: a G8 asserting the candidate note starts with the BASE note (append-only), which the
  landed commit already satisfies.

### R50bC2-F3 — note: R38-03 keeps `located=5` while its twin R38-01 migrates to 8; the stale expect is unreachable behind a policy refusal
- Command: `printf 'R38-03\tpython3 -I -B corpus/quote-locate.py\t^QUOTE_LOCATE: CLEAN located=5 rows=5$…' > r38.tsv; bash corpus/claim-ledger.sh verify --root <clone of e4abab1> --claims r38.tsv --stamps corpus/stamps.tsv`, rc 0.
- Last output lines: `POLICY R38-03 reason=python-script` / `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=124)`.
  The raw measurement at both BASE and candidate is `QUOTE_LOCATE: CLEAN located=8 rows=8`.
- Impacted axis: calibration (two rows assert the same measurement at 5 and 8; only the first is migrated).
  `claim-ledger.sh:276` refuses `python3` unless the row matches `PYTHON_SCRIPT_RE`, so R38-03 never runs.
- Frozen-predicate status: **names a ceiling.** G3 requires R38-03 byte-identical, so the counter cannot see the
  divergence and cannot be satisfied by fixing the twin. The lane already declares it: `corpus/lessons/round-50.md:55`
  "R25-02 FAIL and R29-01/R29-02/R38-03 POLICY stay operator-routed and byte-identical (C2 guard G3)".
- Smallest safe correction: operator decision only — either exempt R38-03's expect from the freeze in a future
  predeclaration (migrate 5→8 with the same journal form), or retire the twin row and let R38-01 carry the value.

### R50bC2-F4 — note: C2's zero is a ten-row counter, not a ledger verdict; the revision's gate still reads FAIL
- Command: the two (a) runs. Last output line of the verify leg at the candidate:
  `CLAIM_LEDGER: FAIL (claims=10 failed=0 deferred=0 stamped=124 stale=0 missing=0 unresolved_ids=1102 labeled_ids=121 host_skipped=0)` (`verify_rc=1`).
- `failed=0` yet `FAIL`: the verdict is driven by `unresolved_ids` (prose ids that name no ledger row), which grew
  1090 → 1102 across the two round-50 content commits (round-49/round-50 lesson texts carry `R12-03`, `R25-02`,
  `R38-03`, … in prose). The frozen predicate only requires the final line to carry `claims=10`, so this is
  in-predicate; BASE is FAIL in the same way (`failed=10`, `unresolved_ids=1090`). No regression introduced.
- Smallest safe correction: none to C2. If the lane wants `CLAIM_LEDGER: CLEAN` as a gate, the prose-id class needs
  its own routed decision (tagging or an ignore list), not a ledger-expect migration.

### R50bC2-F5 — note: the SCORECARD status line names three routed reds, the round-50 lesson names four
- Command: `grep -n '^lane-status: ' SCORECARD.md`, rc 0. Last line:
  `lane-status: open — as-of:2026-11-04 — dispatch unblocked; 3 operator-routed reds (R25-02,R29-01,R29-02) stay red`
  vs `corpus/lessons/round-50.md:55` listing `R25-02 FAIL and R29-01/R29-02/R38-03 POLICY`.
- Impacted axis: provenance only. Pre-existing (R38-03 arrived in round 38; `R31-06` pins the three-id string and
  is not in C2's population), so C2 neither introduces nor fixes it.
- Smallest safe correction: route to the lane's status authority; do not move R31-06 inside C2.

---

## What was not done
- The lane's full `bash corpus/claim-ledger.sh verify` (341 s) was **not** run; only the ten-row subset the frozen
  counter runs (`--claims sub.tsv`), a two-row probe (`R38-03`,`R22-03`) and a one-row probe (`R38-03`).
- No instrument, corpus, plan, SCORECARD, LOG, manifest or registry file was edited; all mutations live in
  scratch clones. No token, key or vault material was read, printed or written.
