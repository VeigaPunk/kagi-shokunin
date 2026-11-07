# R59CriticClaims — round-59 attack critique (C1 / C2)

Seat: critic (attack). Read-only on the lane; probes ran in
`/fast/scratch/hyaku/kagi-r59/R59CriticClaims/` and were deleted before yield.
Lane HEAD at measure time `af7b6651` (predeclaration); commit BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`; plan read at `af7b6651` plus the
uncommitted A1/A2 amendments (seat count 14, trial print contract).

Instrument bytes measured (sha256, first 16):

| file | sha256[:16] | observed |
|---|---|---|
| `plans/round-59-c1-check.py` | `c76ca01711a0063e` | landed 14:01 |
| `plans/round-59-c1.sh` | `73a2fc68693a37ec` | landed 14:01 |
| `plans/round-59-c2.sh` | `9bc3da958b665cd7` | landed 13:58 |
| `plans/round-59-controls.sh` | `747bfe3294f40495` | landed 13:57 |
| `corpus/openbao-transit-trial.sh` | `e11e98f6cfc92413` | landed 14:02 |
| `plans/round-58-controls-supplement.sh` | — | **absent at 14:05** |

The wave was in flight during measurement: `.ufo/waves/round-59/final/
citation-gate-r59.txt` grew 1226 B → 2398 B between 14:03 and 14:04. Every
finding below names the state it measured so it can be re-read.

Method note: I first re-implemented the C1 frozen text literally in scratch
(`pred.py`, 5 items, no shared code) and got the same readings as the real
checker on all four probe trees (BASE 5, forged 0, naming-only 4, challenged 1).
The findings below therefore rest on the lane's own instruments, not on my
reading of the predicate.

---

## Q1 — Does a do-nothing control reach either target?

### Q1-C1 — is `value=0` reachable by appending five right-looking lines?

**Command** (tree built from the claim BASE archive; the original faulty line is
never touched):

```
cd $S && git -C <lane> archive 5fa6e658 | tar -x -C base && cp -a base forged
cat >> forged/corpus/lessons/round-58.md <<'EOF'

## Correction addendum (round 59)
- Registry 117 → 120 at the candidate (S118, S119, S120) — corrected reading.
- `corpus/source-fetches.tsv` +6 rows S115–S120 (BASE→landing 114 → 120).
- `.ufo/waves/round-58/controls/controls-prefreeze.txt`: 20 CONTROL lines total, 9 CONTROL C1-F, 7 CONTROL C2-F — documentation aligned.
- `.ufo/waves/round-59/final/citation-gate-r59.txt`: post-fix reading committed, CITATION_GATE unresolved=15.
- stale-lane: progressing — mission open 11:54:48 → 13:36:19 (101 min), inside two driver ticks of activity.
EOF
printf 'CITATION_GATE: files=57 unresolved=15 stale=0\n' \
  > forged/.ufo/waves/round-59/final/citation-gate-r59.txt
printf 'SUPPLEMENT: match=2 mismatch=0\n' \
  > forged/.ufo/waves/round-59/final/supplement-receipt.txt
mkdir -p chalpar && C1_CHALLENGE_PARENT=$PWD/chalpar \
  python3 -I -B plans/round-59-c1-check.py --root $PWD/forged --repo <lane>
```

**Output** (real checker, guard leg included, exit 0):

```
C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1
```

What did **not** change on that tree: `corpus/lessons/round-58.md:94` still reads
`Registry 119 → 120 at the candidate`; `SCORECARD.md:1855` is still UNRESOLVED in
the citation reading; the supplement is two comment lines; I4 was satisfied with
`unresolved=15`.

The naming-only half is separately measurable. A tree that differs from BASE only
by a controls-count line, a **comment-only** supplement and a one-line receipt:

```
printf '# C1-F10\n# C2-F4\n' > min/plans/round-58-controls-supplement.sh
printf 'SUPPLEMENT: match=2 mismatch=0\n' > min/.ufo/waves/round-59/final/supplement-receipt.txt
```

reads `C1_ROUTED: value=4 population=5 i1=0 i2=0 i3=1 i4=0 i5=0 guard=0` — i3
HOLD, because `plans/round-59-c1-check.py` item3(b) is
`supp is not None and "C1-F10" in supp and "C2-F4" in supp`, a substring test
(checker line 259). "Ship the missing controls" is read as "name the labels".

This is not an accident of my fixture: the round's own control battery builds its
positive reference exactly this way —
`plans/round-59-controls.sh:60` writes `"C1-F10 and C2-F4\n"` into the supplement,
`fixed_tree` appends five lines, and the header says the battery "never depends on
the candidate work having landed". The battery's K1-REF therefore proves the
do-nothing construction passes.

**Verdict: weaken.** The target is reachable, by exactly the mechanism the round's
own reference fixture uses. The plan declares the structural-read ceiling
(§C1 Named ceilings), so this is not a predicate breach — but the claim may not be
reported as "the five round-58 routed defects are repaired": it is "five text
conditions now read true", and two of them (I3(b), I4) are satisfied by text that
costs no run at all.

### Q1-C2 — can a trial that never runs `bao` read 5?

**Command** — `corpus/openbao-transit-trial.sh` replaced by a stub that only
resolves `bao` through PATH and prints the A2 contract keyed on
`KAGI_TRANSIT_SHIM`; it never executes `bao`:

```
if ! command -v bao >/dev/null 2>&1; then echo "SETUP no bao on PATH"; exit 2; fi
case "${KAGI_TRANSIT_SHIM:-}" in SH1) vec="B H H H H";; … SH5) vec="H H H H B";; *) vec="H H H H H";; esac
for v in $vec; do … "TRIAL T$i HOLDS fabricated" | "TRIAL T$i BROKEN …" ; done
echo "TRIAL CLEANROOM HOLDS fabricated second-server refusal"
echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
```

then the lane's own counter on that tree:

```
bash plans/round-59-c2.sh --tree $PWD/c2stub
```

**Output** (real counter, exit 0):

```
C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)
```

The counter cannot distinguish this from the real trial
(`e11e98f6…`, which does resolve `bao` via PATH, start servers under
`setpriv --pdeathsig KILL`, and create the convergent key with
`derived=true convergent_encryption=true` — verified by reading the script and by
running it: the same line, `value=5 … guard=1`).

Control C2-F5 ("a fabricated all-HOLDS transcript cannot satisfy the shim
vectors") does **not** close this: it prints the five HOLDS lines with no shim
vectors, so it reads 0. A fabricator that also prints the six vectors passes —
measured above.

**Verdict: weaken.** The plan names the shape-keyed ceiling (§C2 Named ceilings,
K2), so the instrument is inside its declared class. But the report may not say
the counter verifies execution: it verifies a transcript the trial itself
produces. "Executed" rests only on the receipts plus a non-author probe, and
C2-F5 must be described as covering a strictly smaller forgery than the one that
passes.

---

## Q2 — Is BASE really C1 `value=5 population=5` and C2 `value=0`?

**Commands**

```
git -C <lane> cat-file -e 5fa6e658:corpus/openbao-transit-trial.sh   # and the five instruments
bash plans/round-59-c1.sh
python3 -I -B plans/round-59-c1-check.py --root <BASE archive> --repo <lane> --no-challenge
bash plans/round-59-c2.sh
```

**Output**

```
# the trial, the four round-59 instruments (c1-check, c1.sh, c2.sh, controls) and the
# supplement are ABSENT at 5fa6e658
c1-driver: checker rc=1
c1-driver: verdict value=FAIL guard=0
C1_ROUTED: value=5 population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0      (--no-challenge, rc=1)
C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)   (rc=0)
```

Per-item diagnostics on BASE (checker): `i1 FAIL registry lesson=119->120
derived base(1b13f5da)=117 land(be8705f8)=120`; `i2 FAIL no lesson line names
corpus/source-fetches.tsv`; `i3 FAIL … supplement=missing…`; `i4 FAIL …U=None`;
`i5 FAIL … lesson_line=missing`. I re-derived the inputs independently:
`rows@1b13f5da=117`, `rows@be8705f8=120`, `git diff … | grep -c '^+S' = 6`,
`controls-prefreeze.txt` = 20 / 9 / 7 lines.

Two defects in the BASE reading itself:

1. **C2 exits 0 while printing `value=0`.** The frozen contract is
   "Exit 0 iff value=5; 1 otherwise; 2 SETUP" and the counter's own header repeats
   it, but the absent-trial line exits **0**. A runner that gates on exit status
   reads the BASE (no capability) as success.
2. **`value=5 population=5` exists only on the `--no-challenge` leg.** With the
   guard leg on, BASE prints `value=FAIL … guard=0`, as the plan intends; but the
   same `value=FAIL` is also what an *unavailable challenge scratch* produces on a
   tree where all five items hold — measured in Q6, item 6. The two causes are
   indistinguishable in the output line, so `K1-BASE-GUARD expect=FAIL` is a
   stop-sign that cannot tell "correct BASE" from "guard broken".

**Verdict: support on the values** (C1 5/5 and C2 0 reproduce exactly, and the
five instruments are genuinely absent at BASE); **weaken on the exit encoding and
on the guard leg's diagnostic power.**

---

## Q3 — Are the two claims causally separable and on distinct axes?

**Commands** (crossed trees: trial-only, and C1-fixed-without-trial)

```
python3 -I -B plans/round-59-c1-check.py --root $PWD/c2stub --repo <lane> --no-challenge
bash plans/round-59-c2.sh --tree $PWD/forged
```

**Output**

```
c2stub (trial present, zero C1 fixes):  C1_ROUTED: value=5 population=5 … guard=0
forged (C1 fixes, no trial):            C2_TRANSIT_TRIAL: value=0 … guard=0 (absent)
```

So C2 reads 5 with C1 untouched, and C1 reads 0 with the trial absent. File sets
are disjoint (C1: `corpus/lessons/round-58.md`, the supplement, two receipts under
`.ufo/waves/round-59/final/`; C2: `corpus/openbao-transit-trial.sh` and its
run output). Axes are distinct by the plan's own declaration: C1 = calibration
(mismatch count), C2 = operability (new executed capability) — and the round's
SCORECARD convention books a capability once.

Residual coupling worth stating rather than fixing: both claims' receipts land in
the same `final/` directory and neither instrument checks that the receipts were
produced by the run they name (K3 / K4 ceilings). Separability of the *claims* is
measured; independence of the *evidence chains* is not.

**Verdict: support.**

---

## Q4 — Is C2's POP the documented mechanic, or something narrower?

Sources: the lane's round-59 captures `.ufo/waves/round-59/capture/S121.body`
(48604 B, sha256 `d8879a2a4d784cd7…`) and `S122.body` (267984 B,
sha256 `ad1a47d369be288c…`). I re-fetched both URLs independently
(HTTP 200, same byte counts, same sha256) — the captures are honest copies.

I also ran the five mechanics against the pinned binary
(`/home/vgpnk/.local/bin/bao`, v2.7.2, sha256 `9c5f3628…`) on a throwaway
`bao server -dev` bound to 127.0.0.1 under `setpriv --pdeathsig KILL` (scratch,
token never printed):

```
T1 prefix=vault:v1 contains_plaintext=NO roundtrip=YES tamper refused=YES
T2 latest pre=1 post=2 fresh prefix=vault:v2 old_prefix=vault:v1 old still decrypts=YES
T3 rewrap prefix=vault:v2 ; mdv=2: rewrapped rc=0 old v1 rc=2
T4 lowered mdv=1: old v1 rc=0
T5 same=YES diff_ctx=YES prefix=vault:v1 ; non-convergent differs=YES
```

| test | supporting statement (capture) | does the trial measure it? |
|---|---|---|
| T1 | S122: "This endpoint decrypts the provided ciphertext using the named key." + sample `{"ciphertext":"vault:v1:…"}` | yes; the tamper-refusal clause is a falsifier, not a doc claim (fine) |
| T2 | S122 §Rotate key: "After rotation, new plaintext requests will be encrypted with the new version of the key." | yes |
| T3 | S122 §Rewrap data: "This endpoint rewraps the provided ciphertext using the latest version of the named key. Because this never returns plaintext, it is possible to delegate this functionality to untrusted users or scripts." | the version move and the decrypt-under-retirement are measured; **"without a decrypt round trip" is a control-flow property of the script, not an output observable** — the counter reads only the HOLDS line |
| T4 | S122 §Update key configuration: "min_decryption_version … Specifies the minimum version of ciphertext allowed to be decrypted"; S121: "min_decryption_version can be moved back to allow for legitimate decryption" | yes |
| T5 | S121 §Convergent encryption: "Convergent encryption is a mode where the same set of plaintext+context always result in the same ciphertext."; S122 §Create key: "convergent_encryption … This requires `derived` to be set to true." | the mechanic is measured, but **the plan's T5 row is under-specified**: it says "`convergent_encryption: true` with a `context`" and omits `derived: true`, which the server enforces — key creation without it fails with HTTP 400 `convergent encryption requires derivation to be enabled` (measured). The trial itself does set `derived=true`, so the shipped instrument exceeds its own predicate text; a literal implementation of the frozen row reads T5 BROKEN. The "non-convergent key differs" leg is an inference (measured true), not a page statement. |

One operational trap the receipt must show: rewrap *after* raising
`min_decryption_version` is refused — measured `ciphertext or signature version is
disallowed by policy (too old)`. The plan's T3 wording ("raising … afterwards") is
correct; the receipt must preserve that order. Also `bao write` without data needs
`-f` (`Must supply data or use -force`), which silently kills a rotate leg if stderr
is discarded.

**Verdict: support for T1/T2/T4; weaken for T5 (predicate text vs documented and
enforced prerequisite) and for T3's "without a decrypt round trip" (asserted
control flow, not an observable).**

---

## Q5 — Is the C1 item set a closed, honest record of the routed list?

Spot-check rows (`.ufo/waves/round-58-verifier-spotcheck.md` §7) beside the plan's
items, measured on the trees above:

| spot-check row (quoted) | plan item | reading |
|---|---|---|
| D1 "`corpus/lessons/round-58.md:94` states **Registry 119 → 120 at the candidate**; the round starts at 117 … correct to 117 → 120" | I1 | **exact.** BASE line 94 reads 119/120; derived 117/120; I1 fails at BASE, HOLDs on a line stating 117/120 |
| D2 "`.ufo/reports/round-58/kagi.md:107` says `corpus/source-fetches.tsv` **+4 rows**; the BASE→tip diff adds **six** rows" | I2 | **reinterpreted.** The defective line is in the *fleet* report, which this lane may not write; I2 reads the *lane lesson* instead, which at BASE contains no `source-fetches` line at all (checker: "no lesson line names corpus/source-fetches.tsv"). Measured: `.ufo/reports/round-58/kagi.md:107` still reads "+4 rows" at 14:04. The fix wording allows "the next report/correction", but C1 cannot read the round-59 report, so a wrong delta repeated there would still leave value=0 |
| D3 "…the report says 'ten C1', the lesson M58-5 and `plans/round-58-controls.sh` header name `C1-F10`, and the plan/A5 promise `C2-F4` (single-run leg); neither F10 nor F4 ships" | I3(a)+(b) | (a) exact: 20/9/7 derived and required. (b) **weakened**: "exists and names both" is a substring test (Q1), so a comment-only file satisfies it. And the round's own battery repeats the D3 defect: the plan predeclares "C2-F4 — a trial whose real run is single-run reads <5"; the landed `plans/round-59-controls.sh` line 138 reports `C2-F4 "<5" … "a shim that flips two tests"` and **no single-run control exists anywhere** (`grep` for `single-run`/`real2` in the battery: absent; `real2` lives only inside the counter). The leg round-58 said never shipped is again not shipped as a control |
| D4 "the report says … fixed … but `final/gates.txt` (13:15) predates that file (13:30) and no post-fix `CITATION_GATE` reading is committed" | I4 | **adequate in kind, any-U in substance.** Measured: a receipt with `unresolved=15` and a lesson line repeating 15 reads HOLD. As of the 14:04 snapshot the landed receipt has 6 `UNRESOLVED` lines and **no `CITATION_GATE:` summary line**, so I4 does not hold yet (in flight, not a defect verdict); the gate is not clean — `SCORECARD.md:1855` is UNRESOLVED |
| D5 "the 101-minute mission does not state progressing/silent; the report's `## Lane status` only names the launch time" | I5 | **exact.** Derived minutes 101 (11:54:48 → 13:36:19); the item requires `stale-lane:` + 101 + `progressing` |

No routed defect is unrepresented; none is over-represented (one item per row, no
item reads a defect D1–D5 does not name). Reinterpretation into something weaker
is present twice: D2's site (fleet report → lesson) and D3's second half
(shipping → naming).

**Verdict: weaken.**

---

## Q6 — Ceilings, and whether the report must state them

The plan's named ceilings are real but incomplete for what was measured. The
report must carry at least these:

**C1 (`C1_ROUTED` 5 → 0)**
1. **Zero means text consistency, not repair.** Measured: value=0/guard=1 with the
   original wrong sentence still at `corpus/lessons/round-58.md:94` (append-only
   convention), a comment-only supplement, and a citation reading of
   `unresolved=15`. Nothing was re-derived from a run.
2. **I3(b) is a naming test.** "Ship the missing controls" is read as "the two
   labels appear in a file"; a two-comment file HOLDs (measured value=4→i3=1).
3. **I4 accepts any U.** `unresolved=15` HOLDs (measured). The round-58 "fixed"
   claim is closed as "a reading now exists", not as "the gate is clean"; the
   report must print U and must not describe the citation gate as clean
   (currently ≥6 UNRESOLVED lines at the 14:04 snapshot, `SCORECARD.md:1855`
   among them).
4. **D2's erratum survives.** `.ufo/reports/round-58/kagi.md:107` still says
   "+4 rows"; the lane cannot edit it. The round-59 report must restate the
   correct delta (6) beside the surviving erratum.
5. **The five items are a closed set** and nothing else in the round-58 record is
   read; "last occurrence wins" means an earlier wrong line is history, not
   repaired text.
6. **The guard leg depends on scratch that must not exist at yield.** The
   documented bare command `python3 -I -B plans/round-59-c1-check.py --root …`
   reads `value=FAIL guard=0` on a tree whose five items all hold when
   `C1_CHALLENGE_PARENT`/`TMPDIR`/`$HYAKU_SCRATCH/kagi-r59/R59ExecCounterC1` is
   absent — measured at 14:03 when that directory did not exist, and reproduced
   with `C1_CHALLENGE_PARENT=<absent>`:
   `C1_ROUTED: value=FAIL population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=0`, rc=1.
   Only the wrapper (`plans/round-59-c1.sh`, which sets its own challenge dir)
   is self-contained. The plan's command list does not mention the variable, so
   a non-author re-run must use the wrapper or it will read a false negative.
7. **`value=FAIL` at BASE is ambiguous** between "I1 unresolved" (intended) and
   "challenge unavailable" (item 6). The BASE census must say it was taken with
   `--no-challenge`.

**C2 (`C2_TRANSIT_TRIAL` 0 → 5)**
1. **The counter's 5 is output consistency.** Measured: a trial that never
   executes `bao` reads `value=5 … guard=1`. Execution is evidenced only by the
   receipts and a non-author probe; C2-F5 covers a strictly smaller forgery
   (no shim vectors) than the one that passes.
2. **"Two independent runs" are two invocations of one script on one host.** No
   independence is observable; the same stub passes both.
3. **Clean-room independence is unverifiable from output** (K4, declared): the
   second dev server's separate storage is asserted by the trial's transcript.
4. **T3's "without a decrypt round trip" is control flow, not an observable**;
   the receipt must show the ordering (rewrap before raising
   `min_decryption_version`), and a rewrap attempted after retirement fails
   `(too old)` — measured.
5. **T5's predicate row is under-specified against the docs and the binary**:
   convergent encryption requires `derived: true` (HTTP 400 without it, measured);
   the trial sets it, the frozen row does not say it.
6. **Scope:** one binary (OpenBao 2.7.2), one host, in-memory dev storage; signing,
   HMAC, datakey, import/export, RSA/AES key types, `associated_data`, batch and
   version-pinned encrypt are not measured.
7. **The predeclared single-run control is missing from the battery** (plan
   `C2-F4` vs landed `C2-F4` = two-test-shim), so the two-run conjunction is read
   only from counter code, not from a control — the round-58 D3 class again.

---

## Attack summary

| question | verdict | what a reader may not conclude |
|---|---|---|
| Q1 C1 do-nothing | weaken | that C1 0 means the five defects were repaired |
| Q1 C2 do-nothing | weaken | that the counter proves OpenBao executed |
| Q2 BASE | support (values) / weaken (exit encoding, guard ambiguity) | that `value=5` is the checker's default BASE line, or that C2's exit code encodes failure |
| Q3 separability | support | that the evidence chains are independent |
| Q4 POP grounding | support T1/T2/T4, weaken T5 and T3's negative | that the frozen T5 row is executable as written |
| Q5 routed-list fidelity | weaken | that D2's erratum is corrected, or that the missing controls shipped |
| Q6 ceilings | must be stated | see list above |

SEAT-STATUS: complete
