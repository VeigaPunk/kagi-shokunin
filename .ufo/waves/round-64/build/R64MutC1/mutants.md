# R64MutC1 — mutation ledger (kagi round 64, wave w1)

Seat `R64MutC1`, mutation-tester (attack seat). Read-only on the lane outside the
incident in §7. All fixtures under `/fast/scratch/hyaku/kagi-r64/R64MutC1/` (deleted
before yield).

Detector: each instrument's own `--selftest`. **KILLED** = `…SELFTEST: FAIL` (rc 1);
**SURVIVED** = `PASS` rc 0 (counter: differential against the pristine baseline's
finding set, §6). A kill that comes only from a self-scan needle case is marked
*cosmetic*; a behaviourally indistinguishable mutant is marked *equivalent* with the
measurement that proves it.

**Held-out seal: not read.** I never opened `plans/round-64-heldout.tsv`; the counter
runs execute the counter, which verifies the table's sha256 internally. No row of that
table is quoted anywhere here.

## 0. Bytes under test (final)

| instrument | sha256 | lines | baseline |
|---|---|---|---|
| checker BASE (round-63) | `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6` | 2031 | `C1_CHECK_SELFTEST: PASS (cases=102)` rc 0 |
| checker candidate, FINAL | `07bdc614f502d53287a3e5f3f0a7414e4831b0ab0b0863775c1c5d600079333c` | 2154 | `PASS (cases=111)` rc 0 |
| counter candidate, FINAL | `e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484` | 885 | `C1_HELDOUT_SELFTEST: PASS (cases=23)` rc 0 |

The checker moved five times during the seat (`dc76a20f` → `2d48e481` → `c433dcb2` →
`bdb1bfc0` → `07bdc614`); the counter four times (`552775a2` → `b940c890` →
`dabeffdb` → `ca6dec9b` → `e3d06d0b` → `e03a4d69`). Both owners confirmed their final
sha; the tables below are the final-bytes readings. Intermediate rounds are recorded in
§1 (BASE) and in the survivors' history (§3).

## 1. Checker on BASE bytes (context, 13 mutants)

`plans/round-61-c1-check.py` sha `eb08094c…`, `PASS (cases=102)`.

| id | rule mutated | line | observed | verdict |
|---|---|---|---|---|
| C01 | `_is_negator`: `return t in NEGATORS or t.endswith(NT_SUFFIX)` → `return False` | 430 | `FAIL (cases=102 failed=15 …)` | KILLED (14 behavioural + `k5-negator-needle-unique`) |
| C02 | `_asserted`: drop `and not _denied_after(mt, end)` | 500 | `FAIL (failed=3 names=f2-…,f4-…,denial-after-token-detected)` | KILLED |
| C03 | `_asserted`: `mt = _mask_quotes(text, start)` → `mt = text` | 499 | `PASS (cases=102)` | SURVIVED (equivalent, §3c) |
| C04 | `item4`: `NO_NEW_RECORD_DEFECT_RE.search(last) is not None` → `True` | 806 | `PASS (cases=102)` | **SURVIVED** |
| C05 | `item5`: drop `_asserted(...)` from `asserted` | 836 | `FAIL (failed=2 names=b5-…,f7-…)` | KILLED |
| C06 | `_pair_bound_to_subject`: `<= SUBJECT_WINDOW` → `if True:` | 926 | `PASS (cases=102)` | **SURVIVED** |
| C07 | `item7`: `asserted = re.sub(r'"[^"]*"', " ", last)` → `asserted = last` | 947 | `PASS (cases=102)` | **SURVIVED** |
| C08 | `_asserted` return inverted | 500 | `FAIL (failed=40 …)` | KILLED |
| C09 | `_negated_before`: `if i in rescued: continue` → `if False:` | 456 | `FAIL (failed=4 …)` | KILLED |
| C10 | `_negated_before`: contrastive `but` rescue dropped | 461 | `FAIL (failed=2 names=p5b-…,contrastive-but-rescues)` | KILLED |
| C11 | `_pair_bound_to_subject`: window `<= 1000` | 926 | `PASS (cases=102)` | **SURVIVED** |
| C12 | `item6`: `and superseded_ok` dropped (round-63 GM5) | 897 | `FAIL (failed=3 names=f9-…,f10-…,i6-superseded-stamp-conjunct-isolated)` | KILLED (GM5 closed) |
| C13 | `_negated_before`: `low[-window:]` → `low[-1000:]` | 452 | `FAIL (failed=1 names=window-negator-at-31-tokens-ignored)` | KILLED |

BASE survivors are exactly the round-64 fix targets (C04, C06/C11, C07) plus the
equivalent C03.

## 2. Checker on FINAL bytes (16 mutants)

| id | rule mutated (exact delta) | line | observed line | verdict |
|---|---|---|---|---|
| M01 | `_both_pairs_ok`: `if not _pair_asserted(masked, pair):\n   return False` → `if False:` — **I7 pair-assertion dropped** | 1007 | `C1_CHECK_SELFTEST: FAIL (cases=111 failed=1 names=shape-i7-pair-denial-forgery)` | KILLED |
| M02 | `_every_pair_own_subject`: `for pm in pms:` → `for pm in pms[:1]:` — **every-pair-bound dropped** | 992 | `FAIL (failed=1 names=shape-i7-duplicate-pair-unbound-forgery)` | KILLED |
| M03 | `_subject_blocked`: `return any(t in SUBJECT_BLOCKERS for t in toks)` → `return False` — **subject-negatedness dropped** | 489 | `FAIL (failed=1 names=shape-i7-subject-negated-forgery)` | KILLED |
| M04 | `PAREN_SPAN_RE` → `re.compile(r"(?!)")` — **parenthetical mask dropped** | 279 | `FAIL (failed=1 names=shape-i7-parenthetical-benign-benign)` | KILLED |
| M05 | `EMDASH_ASIDE_RE` → `re.compile(r"(?!)")` — **em-dash mask dropped** | 280 | `FAIL (failed=1 names=shape-i7-emdash-aside-benign-benign)` | KILLED |
| M06 | `item4`: delete `and _asserted(last, m_no_new.start(), m_no_new.end())` — **I4 `NO_NEW` assertion dropped** | 856 | `FAIL (failed=1 names=shape-i4-quoted-denial-forgery)` | KILLED (closes C04) |
| M07 | `rp_all = list(REWRITTEN_IN_PLACE_RE.finditer(last))[:1]` — **I5 single-mechanism dropped** | 881 | `FAIL (failed=1 names=shape-i5-duplicated-mechanism-forgery)` | KILLED |
| M08 | `IDIOMS`: drop `("not", "less", "than")` — **new idiom class removed** | 277 | `FAIL (failed=1 names=shape-idiom-not-less-than-benign)` | KILLED |
| M09 | `_is_negator` → `return False` — **negator test dropped** | 452 | `FAIL (failed=15 names=b3…,b4…,b5…,f1…,f3…,f5…,f6…,f7…,negator-round63-membership,negator-set-membership,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator,window-negator-at-10-tokens,k5-negator-needle-unique)` | KILLED (14 behavioural names; the 15th is the cosmetic self-scan) |
| M10 | `_asserted`: drop `and not _denied_after(...)` — **post-token denial dropped** | 551 | `FAIL (failed=4 names=f2-…,f4-…,shape-i4-quoted-denial-forgery,denial-after-token-detected)` | KILLED |
| M11 | `_asserted`: `mt = _mask_quotes(text, start)` → `mt = text` — **quotation mask dropped** | 550 | `PASS (cases=111)` | SURVIVED — **equivalent** (§3c) |
| M12 | `_asserted` return inverted — **verdict mapping inverted** | 551 | `FAIL (failed=38 names=aggregate-good-all-hold,…)` | KILLED |
| M13 | `item7`: `asserted = _mask_asides(asserted)` → `asserted = asserted` — **asides call site dropped** | 1033 | `FAIL (failed=2 names=shape-i7-parenthetical-benign-benign,shape-i7-emdash-aside-benign-benign)` | KILLED |
| M14 | `_subject_blocked`: `[-5:]` → `[-3:]` | 488 | `FAIL (failed=1 names=shape-i7-subject-negated-forgery)` | KILLED |
| M15 | `_subject_blocked`: `[-5:]` → `[-8:]` (over-blocking) | 488 | `FAIL (failed=1 names=shape-i7-blocker-window-bounded-benign)` | KILLED |
| M16 | `_subject_blocked`: `[-5:]` → `[-1:]` | 488 | `FAIL (failed=1 names=shape-i7-subject-negated-forgery)` | KILLED |

Census: **16 mutants, 15 killed, 1 survived (equivalent). No live survivor.**

Note on M09: one of the 15 names is the cosmetic `k5-negator-needle-unique` self-scan;
the kill is nonetheless behavioural (14 names).

## 3. Survivors: measurements, the fix cycle, and the one equivalent

### 3a. M04 / M05 / M13 — found live, then closed in-wave

On the bytes as first declared final (`bdb1bfc0`, `cases=110`) these three survived: the
aside masks were not load-bearing in any case. Measured token distance from subject to
pair inside the two authored benign fixtures:

| fixture (as then authored) | raw tokens between | masked tokens between | window |
|---|---|---|---|
| `shape-i7-parenthetical-benign` | **8** (`16 counted three present one sentinel present is`) | 1 | 8 |
| `shape-i7-emdash-aside-benign` | **6** (`not the other way round is`) | 1 | 8 |

Both bound *without* the mask — the parenthetical sat exactly on the window boundary —
and a denial predicate inside a parenthetical after the pair flipped `_pair_asserted`
(masked True, unmasked False) with no case covering it.

End-to-end proof of the fix through `item7` on a fresh `mk_tree` (my proposed fixtures,
9 tokens between subject and pair — one past the window):

| proposed fixture | pristine | M04 | M05 | M13 |
|---|---|---|---|---|
| `(16 counted, three present, one sentinel present here)` | HOLD | **FAIL** | HOLD | **FAIL** |
| `— not the other way round here please now —` (41 chars) | HOLD | HOLD | **FAIL** | **FAIL** |

Reported to `R64ExecC1Grammar`. The owner landed longer fixtures (14 and 9 tokens between
subject and pair: `(16 results counted, three present roles, one sentinel present, as the
role mix records)` and `— not the other way round here please now indeed —`). On the
final bytes all three mutants are **killed** by exactly those two cases (M13 by both).

### 3b. M15 — found live, then closed in-wave

On `bdb1bfc0`, `_subject_blocked` with `[-8:]` instead of `[-5:]` survived: no
over-blocking vector. A benign subject preceded 7 tokens earlier by `other` was blocked
by the wide window and accepted by the 5-token rule (measured window-5 `False` /
window-8 `True`); end-to-end, prefixing the attack-share line with
`in other work the audit board said ` read HOLD pristine and FAIL under the mutant.
The owner added `shape-i7-blocker-window-bounded-benign`
(`so in other work the audit board said the literal reading is 3/16 = 18.75 %`), and on
the final bytes M15 is **killed** by it.

### 3c. M11 — equivalent (same class as round-63 N04)

`_asserted`'s mask feeds only `_denied_after`, which scans from the token's `end`
forward; `_mask_quotes(text, start)` blanks only spans that **end at or before `start`**,
so the two texts are identical over every range `_denied_after` reads, and
`_negated_before` masks internally. No fixture can distinguish the mutant (same result
on every probe). **Fix:** none required; optionally delete the redundant mask or record
it as equivalent.

## 4. Latent defect observed (reported, not amended)

`EMDASH_ASIDE_RE = re.compile(r"—[^—.]{0,60}?—")` caps the aside at 60 characters: a
70-character aside is not masked and the subject→pair binding breaks (measured
`hits=False`, `bound=False` on pristine bytes), while a 23-character aside is masked;
parentheticals have no cap. A benign rewrite with a long em-dash aside would be
rejected. Owner decision: widen/drop the cap or name it as a ceiling.

## 5. Counter control battery: the pre-final defect I reported

On `dabeffdb` the counter's own baseline FAILED: `FAIL (21/22 checks)
failed=vehicle-leg-zero` — the W2 fake-lane tamper replaced the wrong table cell, so the
`vehicle-leg-zero` witness could not fire and could not kill S4. I reported it with the
differential reading (S1/S2/S3/S6 added findings; S4/S5 did not); the owner rewrote W2
(`row F2` replacement `the `, plus an explicit `w2_tamper` guard). Baseline then read
`PASS (cases=22)` on `ca6dec9b`/`e3d06d0b` and `PASS (cases=23)` on the final bytes.

### 5b. S5 — the seal refusal, found live, then closed in-wave

On `ca6dec9b`/`e3d06d0b` S5 (skip the seal refusal) survived: the `seal-sha256` case
only asserted `SEAL_ACTUAL == HELDOUT_SHA` for the pristine table, so no case could see
the refusal removed. I proposed and half-measured a negative vector: an override honoured
in diagnostic modes only, a one-byte-tampered copy, and the assertion
`rc == 2 && grep 'SETUP held-out table seal mismatch' && ! grep '^C1_HELDOUT:'`
(measured: pristine rc 2 with that message and zero verdict lines; the mutant never
printed the message — and a bare `rc == 2` assertion would NOT discriminate). The owner
landed `C1_HELDOUT_TSV_OVERRIDE` (selftest/no-challenge only) plus the `seal-refusal`
case; on the measured bytes S5 is **killed**.

## 6. Counter mutants on FINAL bytes (`e03a4d69`)

Six mutants, each a **regular-file** copy in an isolated lane under this seat's scratch
(the lane is symlinked only for read-only inputs). Baseline: `PASS (cases=23)` rc 0. A
mutant is killed only if it adds a finding to the baseline's set.

**Every `sha256` in the `mutated sha256` column of §6 and §6b is the hash of the mutated
copy, not of the instrument.** The pristine/frozen baseline for the whole battery is
`e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484`; none of the mutant
hashes is, or ever was, a candidate byte.

| id | rule mutated | mutated sha256 | observed line | verdict |
|---|---|---|---|---|
| S1 | force `heldout=0` (`MEASURED_HELDOUT="$HELDOUT_N"` → `=0`) | `acc327d7f39a9e573ba47a1220f27a3f72d1ec22d1297b9f74dca37cf5a0b127` | `FAIL (20/23) failed=verdict-wiring-w0,verdict-wiring-w1,vehicle-leg-zero` | KILLED |
| S2 | force `guard=1` (`guard="$(guard_calc …)"` → `guard=1`) | `c0b1e75a06748454129ad83fc50bc27f65fce57ad22317315c4a41722c8aff7c` | same three findings | KILLED |
| S3 | skip the `resid` leg (`leg_resid "$TREE"` → `RESID=1`) | `052cb61e8eb66ec2f5bdb1bba5af7eed25547d4e08d4054a1afa83f424a6e976` | same three findings | KILLED |
| S4 | skip the `vehicle` leg (`leg_vehicle …` → `VEHICLE=1`) | `d6f9e30c839e1f1005c89160257f30bb85be0274caf81b4a97e04773b71ed732` | `FAIL (22/23) failed=vehicle-leg-zero` | KILLED |
| S5 | skip the seal refusal | `f890c4178fb5d6bdfcdb196ceb6ed82e8ce73c073100a25f887fafa257228ae0` | `FAIL (22/23) failed=seal-refusal` | KILLED |
| S6 | force the exit rule to 0 (`[[ $guard -eq 1 && heldout -eq 0 ]] && exit 0` → `exit 0`) | `7be7c7a39c4f7728e1459fb7ce80cad4ef589a354df0be9af32a9a5892a0eb0d` | `FAIL (20/23) failed=verdict-wiring-w0,verdict-wiring-w1,vehicle-leg-zero` | KILLED |

Census: **6 mutants, 6 killed, 0 survived.** The verdict-wiring witnesses (W0/W1/W2)
are what kill S1/S2/S3/S6 — the round-63 call-site-constant survivor class.

### 6b. Follow-up mutants requested by the owner (same bytes `e03a4d69`)

| id | rule mutated | mutated sha256 | observed line | verdict |
|---|---|---|---|---|
| S7 | force `stub=1` (`leg_stub "$TREE" …` → `STUB=1`) | `e1c7d4a9b1740759704fc8ebe42d92e1bfb20b0cd76c05982e45bb675648ab85` | `PASS (cases=23)` | **SURVIVED** |
| S8 | force `real=1` (`leg_real "$TREE" "$WORK/unmod"` → `REAL=1`) | `384326df98c7049ba47e86279ea04f3942f46ac3cb5f798a1696374ade45fae6` | `FAIL (22/23) failed=verdict-wiring-w1` | KILLED |
| S9 | force `selftest=1` (`leg_selftest` → `SELFTEST=1`) | `4d48f37b7984f1e2bb02efbe36d2d2a739e10ae091f7fa059be94ee0efc9f4e2` | `FAIL (20/23) failed=verdict-wiring-w0,verdict-wiring-w1,vehicle-leg-zero` | KILLED |

Baseline on the same bytes: `PASS (cases=23)` rc 0.

**S7 is the owner's named ceiling and it is real.** Every witness expects `stub=1`
(both stub shapes are refused by construction), so a call-site constant is
indistinguishable: the 0-path of `leg_stub` is only reachable when a stub tree stops
being refused, which the selftest cannot build today. **Fix:** give `leg_stub` an
override argument (the pattern `leg_resid` already uses) and add a witness whose
"stub" tree carries a real checker, so both shapes are accepted (`STUB==0`); assert a
verdict line carrying `stub=0 guard=0`. The call-site constant then reads 1 and dies.
Without that override the ceiling stands and should be named as one.

Total counter battery on the final bytes: **9 mutants — 8 killed, 1 survived (S7, named
ceiling with the fix above).**

## 7. Write-through-symlink incident (disclosed; data void)

Between ~02:26 and ~02:36 the live `plans/round-64-c1.sh` was mutated through a **symlink**
in this seat's fake-lane fixture (the fixture linked the live file so the counter's
`LANE=` derivation would resolve, and the harness wrote through it). The owner detected
it; I killed the job and reported to `R64ExecC1Counter` and `Main` with the exact
mutations (`MEASURED_HELDOUT=0`, `guard=1`, `RESID=1`, `VEHICLE=1`) and the restore
baseline `b940c890…`. Main ruled it contained: untracked file, never committed, owner
had already rewritten it, no restore wanted; I have not written that path since.

**Void readings.** `BASELINE PASS (cases=19)` and the S1/S2/S3 `SURVIVED` readings taken
in that window are void and are not cited as evidence anywhere; they are recorded only as
the incident's record. Everything in §6 was re-derived on private real copies whose
sha256 is recorded.

**Generalisable finding (for the lesson):** a mutation fixture must never link the lane
into the writable path. Use `cp -a`/`git archive` and assert before the first write:

```
assert not os.path.islink(TARGET)
assert os.path.realpath(TARGET).startswith(os.path.realpath(SCRATCH_ROOT) + '/')
```

This is the second write-through-symlink class observed tonight (the other:
`census-at-rev.py` writing a lane citation-survival file through a symlinked extract
tree in kasegi's lane). Every seat that mutates files needs the guard.

## 8. Artifacts

Harness: `mut2.py` (checker: byte-exact mutant + `--selftest`), `counter_battery.py`
(counter: isolated real-file lanes, differential verdict against the pristine baseline,
with the symlink assertion). Raw runs: `mut-cand*/<id>/run.txt`, `out-<tag>.txt`,
`counter-battery.json` (scratch, deleted before yield; every observed line is
transcribed above).
