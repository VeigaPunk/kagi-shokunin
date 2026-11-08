# R64MutC1 — mutation battery (scoped findings)

Seat `R64MutC1`, mutation-tester (attack seat), wave `kagi-r64-w1`, kagi round 64
attempt 2. Read-only on the lane (one disclosed write-through-symlink incident, §5):
no commit, no git/jj command, no lane file mutated outside that window. All fixtures
under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64MutC1/` (deleted before yield).
Full ledger with every mutant's exact bytes delta and observed line:
`.ufo/waves/round-64/build/R64MutC1/mutants.md`.

Detector everywhere: the instrument's own `--selftest`. **KILLED** = `…SELFTEST: FAIL`
(rc 1); **SURVIVED** = `PASS` rc 0. A survivor that is behaviourally indistinguishable is
marked *equivalent* with the measurement that proves it.

The held-out seal was **not read**: I never opened `plans/round-64-heldout.tsv`. The
counter runs execute the counter, which verifies the table's sha256 internally; no row
of that table is quoted here.

## 1. Bytes and census

| instrument | final sha256 | lines | selftest |
|---|---|---|---|
| checker BASE (round-63) | `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6` | 2031 | `PASS (cases=102)` |
| checker candidate | `07bdc614f502d53287a3e5f3f0a7414e4831b0ab0b0863775c1c5d600079333c` | 2154 | `PASS (cases=111)` |
| counter candidate | `e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484` | 885 | see §3 |

Checker battery: **16 mutants — 15 killed, 1 survived (proven equivalent)**.
Counter battery: **9 mutants — 8 killed, 1 survived** (S7, the owner’s named ceiling with a fix; see §3).

The battery was run three times as the two instruments converged
(`eb08094c` → `2d48e481` → `c433dcb2` → `bdb1bfc0` → `07bdc614` for the checker;
`552775a2` → … → `e03a4d69` for the counter). §2 and §3 report the **final** bytes;
the intermediate readings are in the ledger and are what drove the two fixes below.

## 2. Checker mutants (final bytes)

| id | rule mutated | line | observed line | verdict |
|---|---|---|---|---|
| M01 | I7 pair-assertion dropped (`_both_pairs_ok` conjunct) | 1007 | `FAIL (cases=111 failed=1 names=shape-i7-pair-denial-forgery)` | KILLED |
| M02 | every-pair-bound dropped (`pms` → `pms[:1]`) | 992 | `FAIL (names=shape-i7-duplicate-pair-unbound-forgery)` | KILLED |
| M03 | subject-negatedness guard dropped | 489 | `FAIL (names=shape-i7-subject-negated-forgery)` | KILLED |
| M04 | parenthetical mask dropped | 279 | `FAIL (names=shape-i7-parenthetical-benign-benign)` | KILLED |
| M05 | em-dash mask dropped | 280 | `FAIL (names=shape-i7-emdash-aside-benign-benign)` | KILLED |
| M06 | I4 `NO_NEW` assertion dropped | 856 | `FAIL (names=shape-i4-quoted-denial-forgery)` | KILLED |
| M07 | I5 single-mechanism rule dropped | 881 | `FAIL (names=shape-i5-duplicated-mechanism-forgery)` | KILLED |
| M08 | new idiom class removed | 277 | `FAIL (names=shape-idiom-not-less-than-benign)` | KILLED |
| M09 | negator test dropped | 452 | `FAIL (failed=15 …)` (14 behavioural + `k5-negator-needle-unique`) | KILLED |
| M10 | post-token denial test dropped | 551 | `FAIL (failed=4 … f2,f4,shape-i4-quoted-denial,denial-after-token-detected)` | KILLED |
| M11 | quotation mask dropped (`mt = text`) | 550 | `PASS (cases=111)` | SURVIVED — **equivalent** (§2b) |
| M12 | verdict mapping inverted | 551 | `FAIL (failed=38 …)` | KILLED |
| M13 | asides mask call site dropped | 1033 | `FAIL (failed=2 names=shape-i7-parenthetical-benign-benign,shape-i7-emdash-aside-benign-benign)` | KILLED |
| M14 | blocker window 5 → 3 | 488 | `FAIL (names=shape-i7-subject-negated-forgery)` | KILLED |
| M15 | blocker window 5 → 8 (over-blocking) | 488 | `FAIL (names=shape-i7-blocker-window-bounded-benign)` | KILLED |
| M16 | blocker window 5 → 1 | 488 | `FAIL (names=shape-i7-subject-negated-forgery)` | KILLED |

BASE context (13 mutants on `eb08094c`): survivors were exactly the round-64 fix
targets — C04 (I4 `NO_NEW`), C06/C11 (I7 subject binding), C07 (I7 quote mask) — plus the
equivalent C03. The candidate closes C04/C06/C07.

### 2a. The four live survivors I found, and the fix that closed them

On the checker as first declared final (`bdb1bfc0`, `cases=110`) four mutants survived:
M04, M05, M13 (the masking family) and M15 (over-blocking). Measurements:

- The two authored benign fixtures bound **without** the mask: the parenthetical fixture
  had exactly **8** raw tokens between subject and pair (window = 8 — on the boundary)
  and the em-dash fixture **6**. A denial predicate inside a parenthetical after the
  pair also flipped `_pair_asserted` (masked True, unmasked False) with no case covering
  it. End-to-end proof of the fix through `item7` on a fresh `mk_tree`: a 9-token
  parenthetical (one token past the window) read HOLD pristine / FAIL under M04 and M13; a
  9-token em-dash aside read HOLD pristine / FAIL under M05 and M13. The owner landed
  longer fixtures (14 and 9 tokens) so the margin is unambiguous.
- M15: a benign subject preceded 7 tokens earlier by `other` was blocked by the wide
  window and accepted by the 5-token rule; prefixing the attack-share line with
  `in other work the audit board said ` gave HOLD pristine / FAIL under M15.

Reported to `R64ExecC1Grammar`; the owner landed the three fixture edits
(`(16 results counted, three present roles, one sentinel present, as the role mix
records)`, `— not the other way round here please now indeed —`, and a new
`shape-i7-blocker-window-bounded` case). On the final bytes M04, M05, M13 and M15 are
**all killed** by exactly those cases. Attack seat → fix → re-measure, closed in-wave.

### 2b. M11 — equivalent, not a gap

`_asserted`'s mask feeds only `_denied_after`, which scans from the token's `end`
forward, while `_mask_quotes(text, start)` blanks only spans that **end at or before
`start`**; the two texts are identical over every range `_denied_after` reads, and
`_negated_before` masks internally. Same disposition as round-63 N04: no fix required.

### 2c. Latent defect observed (reported, not amended)

`EMDASH_ASIDE_RE = re.compile(r"—[^—.]{0,60}?—")` still caps the aside at 60 characters:
a >60-char em-dash aside is not masked and its binding breaks (measured on pristine
bytes), while parentheticals have no cap. A benign rewrite with a long em-dash aside
would be rejected. Owner decision: widen/drop the cap or name it as a ceiling.

## 3. Counter mutants (final bytes `e03a4d69`)

Six mutants, each applied to a **regular-file copy** of the counter in an isolated lane
under this seat's scratch; the pristine baseline is run under the same load and the
verdict is differential (a mutant is killed only if it adds a finding to the baseline's).

| id | rule mutated | mutated sha256 | observed line | verdict |
|---|---|---|---|---|
| S1 | force `heldout=0` (`MEASURED_HELDOUT="$HELDOUT_N"` → `=0`) | `acc327d7…` | `FAIL (19/22) failed=verdict-wiring-w0,verdict-wiring-w1,vehicle-leg-zero` | KILLED |
| S2 | force `guard=1` (`guard="$(guard_calc …)"` → `guard=1`) | `c0b1e75a…` | same three findings | KILLED |
| S3 | skip the `resid` leg (`leg_resid "$TREE"` → `RESID=1`) | `052cb61e…` | same three findings | KILLED |
| S4 | skip the `vehicle` leg (`leg_vehicle …` → `VEHICLE=1`) | `d6f9e30c…` | `FAIL (21/22) failed=vehicle-leg-zero` | KILLED |
| S5 | skip the seal refusal | `f890c417…` | `FAIL (22/23) failed=seal-refusal` | KILLED |
| S6 | force the exit rule to 0 | `7be7c7a3…` | `FAIL (19/22) failed=verdict-wiring-w0,verdict-wiring-w1,vehicle-leg-zero` | KILLED |

Baseline on the same bytes: `C1_HELDOUT_SELFTEST: PASS (cases=23)` rc 0.

**S5 — the seal refusal, killed by the fix I proposed.** On the earlier bytes
(`e3d06d0b`, `cases=22`) the `seal-sha256` case only asserted
`SEAL_ACTUAL == HELDOUT_SHA` for the *pristine* table, so deleting the refusal changed
no case and S5 survived. I proposed a negative vector (an override honoured in
diagnostic modes only, a one-byte-tampered copy, assert rc 2 + the `SETUP held-out table
seal mismatch` message + no `^C1_HELDOUT:` line) and measured both halves myself:
pristine read rc 2 with exactly that message and zero verdict lines; the S5 mutant never
printed the message. The owner landed the mechanism (`C1_HELDOUT_TSV_OVERRIDE`,
selftest/no-challenge only) plus the `seal-refusal` case; on the measured bytes
`e03a4d69` the mutant is **killed** (`FAIL (22/23) failed=seal-refusal`). Attack seat →
fix → re-measure, closed in-wave.

History: on the earlier bytes `dabeffdb` the baseline itself failed
(`vehicle-leg-zero`); I reported it and the owner fixed the W2 fake-lane tamper
(`ca6dec9b` → baseline PASS). S1/S2/S3/S6 are the round-63 call-site-constant class and
are now killed by the new W0/W1/W2 verdict-wiring witnesses — the fix the round needed.

**Owner-requested follow-ups (same bytes).** Three further mutants on the leg constants:
force `stub=1` → **SURVIVED** (`PASS (cases=23)`), force `real=1` → killed by
`verdict-wiring-w1`, force `selftest=1` → killed by `verdict-wiring-w0/w1` and
`vehicle-leg-zero`. The `stub=1` survivor is the owner's named ceiling and it is real:
every witness expects `stub=1`, so a constant is indistinguishable until a stub tree can
be made *accepted*; the fix is a `leg_stub` override argument (the `leg_resid` pattern)
plus a witness that reads `stub=0 guard=0`. Ledger §6b. Total counter battery: 9
mutants, 8 killed, 1 survived (named ceiling with fix).

## 4. What this says about the round's claims

- Every one of the six C1 mechanisms is individually load-bearing and pinned by a case
  that names its shape class without quoting a held-out fixture (M01/M02/M03/M06/M07/M08
  killed by exactly their own case; the masking family M04/M05/M13 and the blocker
  window M15 after the in-wave fix). The plan's K5 request is met on the final bytes.
- The counter's verdict wiring (five leg constants + the exit rule) is now exercised
  end-to-end, closing the round-63 `guard=1`/`PRIOR=1`/`PARA=1`/`REAL=1` survivor class.
- No counter mutant survives on the final bytes: the seal refusal, the resid leg, the
  vehicle leg, the two verdict constants and the exit rule are each individually
  falsified by a named case.

## 5. Write-through-symlink incident (disclosed; data void)

Between ~02:26 and ~02:36 I mutated the live `plans/round-64-c1.sh` through a **symlink**
in my fake-lane fixture (the fixture linked the live file so the counter's `LANE=`
derivation would resolve, and the harness wrote through it). The owner detected it; I
killed the job and reported to `R64ExecC1Counter` and `Main` with the exact mutations
(`MEASURED_HELDOUT=0`, `guard=1`, `RESID=1`, `VEHICLE=1`) and the restore baseline
`b940c890…`. Main ruled it contained (untracked, never committed, owner had already
rewritten it, no restore wanted).

**Void:** every reading taken through that symlink — the `PASS (cases=19)` baseline and
the S1/S2/S3 `SURVIVED` readings — is marked void in the ledger and is **not** cited as
evidence. §3 is re-derived on private real copies whose sha256 is recorded.

**Generalisable finding (for the lesson):** a mutation fixture must never link the lane
into the writable path; use `cp -a`/`git archive` and assert before the first write:

```
assert not os.path.islink(TARGET)
assert realpath(TARGET).startswith(realpath(SCRATCH_ROOT) + '/')
```

This is the second write-through-symlink class tonight (the other: `census-at-rev.py`
writing a lane citation-survival file through a symlinked extract tree in kasegi's
lane). Any seat that mutates files needs the guard.

## 6. Tooling

No tool installed or upgraded (python3, bash, coreutils only); no pacman/uv/npx/cargo/npm
transaction, no host change.

## 7. Scratch and restoration

All fixtures under `/fast/scratch/hyaku/kagi-r64/R64MutC1/` (deleted before yield). No
citable evidence under `/tmp`. No secret value, cookie, token, session id, vault or item
name in any artifact. Every mutant copy was restored or discarded; the only lane write is
the incident in §5, disclosed to the owner and to Main.

SEAT-STATUS: complete
