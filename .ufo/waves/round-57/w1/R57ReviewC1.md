# R57ReviewC1 — C1 falsification (kagi round 57, wave 1)

Seat: reviewer / attack share (C1). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch master, claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`.
Answering model observed (harness-declared, no independent attestation):
`amr/deepseek-v4.1-flash`. No tool installs or updates were made (no pacman, uv, npx,
cargo, or binary downloads); tools used are preinstalled: bash 5.3.20, python3 3.14.8,
git 2.56.0, sha256sum 0.8.0. No `lsp` device exists in this seat's tool set, so caller/
definition/diagnostic checks were text-based only (recorded as unavailable, not as
absence). No production file, frozen instrument, or git/jj state was modified.

## 1. Inputs, revisions, and instrument identity

| item | value |
|---|---|
| claim BASE | `1cda9e7ae4767b4133e283bfbc08266d4c86362d` |
| lane HEAD when review started (11:13) | `7aa1f4726e1f6bcdc8411d1a8b21828d49785173` (epoch A) |
| lane HEAD when review ended (11:22) | `03cbf656943b33bf93607f607bbbeb55d500b0f9` (epoch B) |
| `plans/round-57-c1-check.py` | `19d75337ce37259b08eaa8b960eedddac68bec70ed4eab3f55f9d621e142f72c` (identical in both epochs) |
| `plans/round-57-c1.sh` | `3104b06f5bfaef77745bd0e5726d4e3ac86c471ff61eef2cc298ad21fee90601` (identical in both epochs) |
| `plans/round-57.md` epoch A / epoch B | `5773c1a423d16ecabe31535afa45c022ae5de27656a5cdd4d5415428102b84c2` / `b130bb83b3dd4bdb52b84aeb4c6d3459477188b66406adab429392049698c6dc` |
| `plans/round-57-c2.sh` epoch A / epoch B | `3de6b4dec570594b7ff47971156b9eb9f932a50a2261ba568b51314e906439a9` / `140a8f2b204af9a0e45e1b596d1c09c4b12f84a70bd42abd18e888d82bbaea28` |
| `plans/round-57-controls.sh` epoch A / epoch B | `6796ae7040b4956d28b9c71772c24c9ba0d4298e21e86f9f13dbff38e693ce41` / `09f334cbf727667a0212729942386d78441dbc5ea7f0c553d316bbb7c613e618` |
| base surfaces (BASE archive) | `SCORECARD.md` `990254ae…9e0910`, `LOG.md` `dfb38c5e…154683`, `corpus/lessons/round-56.md` `566e5dfc…2d709fd` |
| base authorities (BASE archive) | `plans/round-56.md` `d0a8e402…dc025b`, `corpus/recheck-captures.tsv` `df46be5c…ecc762`, `corpus/recheck-replay.py` `b6959d6c…0bb5a3` |

Epoch B (`03cbf65`, "C2 counter adopts the lane TRIAL convention…") landed at
11:16–11:19, after `w1.ready` (11:10) and `w1.ready.dispatched` (11:12). Its diff
changes only the C2 predicate/POP/control expectations and the amendment block; the
C1 section text and both C1 instrument blobs are unchanged (verified with
`git diff --stat 7aa1f47 03cbf65 -- plans/round-57-c1.sh plans/round-57-c1-check.py`
→ empty, and `git diff -U0 7aa1f47 03cbf65 -- plans/round-57.md` changes only the C2
region and the controls/amendment paragraphs). Every C1 verdict below is therefore
epoch-invariant. The re-freeze is recorded here, not contested: it is the lane's
declared epoch convention, but it did supersede the plan mid-wave (`K2-MOCK` expected
5 in epoch A, 0 in epoch B).

### Frozen predicate audited (verbatim from `plans/round-57.md` §C1 and the counter header)

    C1_CURRENT: value = MISMATCH+UNBOUND over POP when GUARD = 1, else FAIL;
    target 0 (BASE 3), population floor 8.

POP = the four classes (`N cases` naming `recheck-replay`; `N MATCH` bound to a receipt
path or to the nearest preceding `A`–`F` backticked revision; `W freeze epochs`; `N clocks`
and `N/N MATCH`) inside `SCORECARD.md ## Round 56 — post-move`, `LOG.md ## Round 56 (`,
and `corpus/lessons/round-56.md` header + `## Claims`.

All forgeries were built in scratch from `git archive 1cda9e7a | tar -x -C base` and
scored with the frozen working-tree instruments:
`bash plans/round-57-c1.sh --tree <dir>` and
`python3 -I -B plans/round-57-c1-check.py --root <dir> --verbose`.

## 2. BASE and the required K1 re-runs (independent rebuild, not just the battery)

Method: each tree is a fresh `git archive` of BASE plus exactly the named control edit;
`k1.py` reproduces the frozen control edits. `driver rc` is the exit code of
`plans/round-57-c1.sh`; `checker rc` is the exit code of the frozen checker.

| id | command | reading | driver rc | checker rc |
|---|---|---|---|---|
| K1-BASE | `bash plans/round-57-c1.sh --tree k1x/base` | `value=3 population=16 gate=0 guard=1` | 0 | 1 |
| K1-F4 | same, three repairs applied | `value=0 population=16 gate=0 guard=1` | 0 | 0 |
| K1-F5 | same, all three surfaces removed | `value=FAIL population=1 gate=0 guard=0` | 0 | 1 |
| K1-F6 | same, epoch-F receipt `23`→`19` | `value=6 population=16 gate=0 guard=1` | 0 | 1 |
| controls battery | `HYAKU_SCRATCH=… bash plans/round-57-controls.sh` | `CONTROLS: match=11 mismatch=0` | 0 | — |

All four readings reproduce the frozen expectations. K1-F6's 6 is explained by its
statement composition: the three epoch-F-bound statements flip
(`SCORECARD:3 23/19`, `LOG:3 23/19`, `LESSON:5 23/19`) on top of the three pre-existing
stales. **The C1 driver exits 0 on every non-admitted reading** (`value=3`, `value=6`,
`value=FAIL`); only the checker exits non-zero. Any harness that trusts the counter's
`rc` instead of parsing the line admits everything. (The C2 counter does not have this
defect: `plans/round-57-c2.sh` ends with `[ "$VALUE" = 5 ] && exit 0; exit 1`.)

BASE statement census (from `--verbose`, 16 statements): `cases=3 match=7 epochs=2
clocks=2 pop=2`, value 3 (SCORECARD:7 cases 18 vs 20; LOG:1 epochs 4 vs 6; LESSON:9
epochs 3 vs 6). Population 16 is stable under the legitimate repair K1-F4
(`cases=3 match=7 epochs=2 clocks=2 pop=2`).

## 3. Forgery matrix

`dir` is under `/fast/scratch/hyaku/kagi-r57/R57ReviewC1/forges/` (deleted before yield;
the per-tree `driver.txt`/`verbose.txt` are copied to `R57ReviewC1.d/logs/`). "Reading"
is the frozen driver line; `rc` is its exit code (always 0 unless SETUP). "Admitted"
means the broken shape is not punished: the tree reads `value=0 population>=8 guard=1`,
or the forged statement is scored OK / not in POP.

| # | forgery | dir | reading | admitted |
|---|---|---|---|---|
| a1 | authority only: gate stub prints `PASS (18 cases)`; plan folded to 4 epochs | `A-authority-4epochs` | `value=3 population=16 gate=0 guard=1` | no (target unreached) |
| a2 | authority only: gate stub 18 cases; plan folded to 3 epochs | `A2-authority-3epochs` | `value=3 population=16` | no |
| a3 | authority only: `plans/round-56.md` removed | `A3-authority-missing` | `value=3 population=16` | no |
| a4 | landing shape (three repairs) + printer as the cases authority | `A4-landing-answerkey` | `value=0 population=16` | **yes** (declared ceiling) |
| b1 | delete the three stale statements instead of repairing | `B1-delete-stale` | `value=0 population=13` | **yes** |
| b2 | b1 + delete five historical MATCH statements (pop exactly 8) | `B2-floor8` | `value=0 population=8` | **yes** |
| b3 | one byte: SCORECARD heading em dash → en dash | `B3-endash-heading` | `value=2 population=11` | no (target), surface dark |
| c | four false numbers in near-miss shapes inside the surface | `C-class-evasion` | `value=3 population=16` | **yes** (uncounted) |
| d0 | new false round-56 statement one line above the heading | `D0-new-false-outside` | `value=3 population=16` | **yes** (uncounted) |
| d1 | the stale cases statement moved one line above the heading | `D1-boundary-move` | `value=2 population=15` | no (target); relocation = repair |
| d2 | all three stales relocated out of audit; 9 true statements rebuilt | `D2-relocate-all` | `value=0 population=9` | **yes** |
| e1 | printer `corpus/current-claims.py` on BASE, `rc 1` | `E1-printer-gate-base` | `value=3 population=16 gate=1 guard=1` | **yes** (guard) |
| e2 | e1's printer on the d2 tree | `E2-printer-gate-admit` | `value=0 population=9 gate=1 guard=1` | **yes** |
| e3 | a *stricter* gate (counts one more claim) on the d2 tree | `E3-stricter-gate` | `value=FAIL population=9 gate=0 guard=0` | no (punished) |
| f1 | false epoch-F claim, number bound to a parenthetical epoch-E citation | `F1-wrong-epoch-letter` | `value=3 population=17` | **yes** (STMT OK) |
| f2 | same false claim through the receipt-path form | `F2-wrong-epoch-receipt` | `value=4 population=17` | no (caught) |
| g | ordinary prose `12 cases` in the surface | `G-unbound-diagnostic` | `value=4 population=17`, prints `unbound=0` | no (caught) but diagnostic false |
| h | `1,018 cases` in the surface | `H-number-anchor` | `value=4 population=17` | no (caught by accident: read as 018) |
| i | decoy `## Round 56 — post-move` inserted before the genuine section | `I-decoy-section` | `value=2 population=15` | no (target); genuine section shadowed |

## 4. Per-forgery verdicts and evidence

### (a) Answer-key — rewrite only the authorities — REFUSED at BASE, ADMITTED at the landing

At BASE the surface is internally contradictory per class, so **no single authority value
satisfies every statement**:

- cases are stated `18` (SCORECARD.md:1850) and `20`, `20` (corpus/lessons/round-56.md:9,
  file line 9). Forging the gate's `--selftest` to `18` fixes one statement and breaks two:
  `STMT LESSON:9 cls=cases stated=20 auth=18 … MISMATCH` ×2, `STMT SCORECARD:7 … stated=18
  auth=18 … OK`. Net value stays 3 (`mismatches=3`: two cases + the lesson epoch).
- epochs are stated `four` (LOG.md:1924) and `Three` (lesson:9). Folding the plan to 4
  distinct tokens fixes `four` and leaves `Three` (3≠4); folding to 3 does the converse
  (forged `plans/round-56.md` sha256 `4460f1da…3af1e5` for 4 epochs, `65610649…f19001b`
  for 3; base `d0a8e402…dc025b`). Net value stays 3.
- removing the epoch authority (`plans/round-56.md` absent) turns both epoch statements
  UNBOUND → still 3 (`STMT LOG:1 … auth=none … UNBOUND`, `STMT LESSON:9 … UNBOUND`).

Best authority-only result is therefore **3 = BASE**; the cheapest *text* repair is better
(2). Authority forging is strictly dominated at BASE.

At the **repaired landing** the contradiction is gone, and the answer-key works:
`A4` applies the plan's three repairs plus a 3-line `corpus/recheck-replay.py`
(`print('PASS (20 cases)')`, forged sha256 `296b03f9…5c1a32` replacing the real gate
`b6959d6c…0bb5a3`) and reads `value=0 population=16 gate=0 guard=1`. This is the plan's
declared ceiling ("an authority file forged to agree with its statement passes"), but it
means the landing's C1 reading is only as strong as the *pinned bytes* of
`corpus/recheck-replay.py`: the cases authority is a program inside the measured tree,
so a printer is a complete answer key. Nothing in the frozen driver or checker pins that
gate's hash (round 56 itself used `GATE_SHA256_PIN` `b6959d6c…`).

### (b) Floor evasion — ADMITTED, twice

- `B1`: replace `--selftest` 18 cases (SCORECARD.md:1850) with `--selftest verified`;
  `four freeze epochs land` (LOG.md:1924) with `all freeze epochs land`; `Three freeze
  epochs:` (lesson:9) with `Freeze epochs:`. Three phrase deletions, no authority touched,
  no line removed. Reading: `C1_CURRENT: value=0 population=13 gate=0 guard=1`, `rc 0`
  (`cases=2 match=7 epochs=0 clocks=2 pop=2`). **Repair-by-deletion is indistinguishable
  from repair**.
- `B2`: `B1` plus rewriting the five historical MATCH tokens in LOG:3
  (`16/20/21/22/23 MATCH` → `N controls`). Reading: `value=0 population=8 gate=0 guard=1`
  — exactly the declared floor, `cases=2 match=2 epochs=0 clocks=2 pop=2`. The predicate
  admits a surface with zero epoch statements and two MATCH statements carrying the whole
  audit.
- `B3` (selection by heading byte): em dash `—` → en dash `–` in the SCORECARD round-56
  heading. The section regex `^## Round 56 [—-] post-move` no longer matches; the entire
  SCORECARD surface (5 statements, including the stale cases claim) silently leaves POP:
  `value=2 population=11`. Target not reached only because LOG/LESSON still hold two stales;
  it demonstrates that a one-byte title change hides a stale statement with no FAIL.

### (c) Class evasion — ADMITTED (uncounted)

Inserted inside the SCORECARD section, immediately under the heading
(line sha256 `fe2b18e4…2d96`):

> Close notes: the gate reports `--selftest` 18 test cases; the epoch-F receipt shows
> 31 matches; SEVEN epochs were declared; the close took 7 stated clocks.

All four numbers are false (gate 20; F receipt 23; six epochs; ten clocks) and all four
are warm current-tense self-descriptions about the audited round. The predicate emits
**zero** STMT lines for the line: `value=3 population=16` — identical to BASE
(`grep -c '^STMT'` = 16). The shapes evade the regexes (`([0-9]+) cases` needs adjacency;
`MATCH` is uppercase-only; `freeze epochs` is required verbatim; `N clocks` needs
adjacency). This is the plan's declared closed-class ceiling, but the ceiling text says
"a numeric statement of *another shape*", while these are the same claims in another
surface form; the false claim is admitted, and the class surface is one word wide.

### (d) Surface misselection — ADMITTED at target by relocation; false statement outside the boundary uncounted

- `D0`: a *new* false statement about round 56 (`…--selftest reads 18 cases; the epoch
  count is four freeze epochs`, line sha256 `be5c4da8…3cf0e`) placed one line *above*
  the audited heading (last line of the round-55 section). Zero STMT lines; reading
  identical to BASE (`value=3 population=16`). The predicate audits a heading span, not a
  subject: a false round-56 self-description one line above the span is not POP.
- `D1`: the *stale* cases statement moved to the same position. Reading `value=2
  population=15`: the mismatch disappeared, i.e. moving a false statement out of the
  section is scored exactly like repairing it.
- `D2`: all three stales put outside the audited spans (the SCORECARD cases phrase is
  deleted in place; the LOG heading is retitled `## Round 56 — 2026-11-07` so the
  `(`-anchored section is empty; the lesson `## Claims` heading is removed so the claims
  body is not POP), then four true statements added inside SCORECARD (receipt `23 MATCH`
  epoch F, `10 clocks`, `10/10 MATCH`). Reading: `C1_CURRENT: value=0 population=9 gate=0 guard=1`,
  `rc 0`, `cases=0 match=3 epochs=0 clocks=2 pop=4`. **The frozen kill rule (a)
  (`value=0` with `population>=8`) is satisfied by a tree in which every stale statement
  still exists, merely outside the audited spans.**
- `I` (decoy): a `## Round 56 — post-move` decoy heading inserted immediately before the
  genuine `## Round 56 — post-move (claim C1 freshness)`. `section()` takes the first
  match; the decoy's span ends at the genuine heading, so the genuine 5 statements are
  shadowed by 4 true decoy statements (`value=2 population=15`; the stale cases statement
  is gone from POP). First-match-wins is exploitable without any false text.

### (e) Guard bypass — ADMITTED (bytes differ, reading matches)

The driver's GUARD leg compares two integers parsed from an arbitrary program:
`GATE=1` iff `value` and `population` from `corpus/current-claims.py --root` equal the
frozen checker's. Nothing pins the file's bytes, exit code, per-class counts, or even its
existence (`[ ! -f ]` → gate leg passes).

- `E1`: `corpus/current-claims.py` is a 4-line printer
  (`print('CURRENT_CLAIMS: value=3 population=16 …'); sys.exit(1)`,
  sha256 `dc6db633…71696cf`). At BASE: `C1_CURRENT: value=3 population=16 gate=1
  guard=1`, `rc 0`. The gate's non-zero exit is ignored; the two echoed numbers suffice.
- `E2`: same attack on `D2` (`value=0 population=9`; printer sha256 `a111c96f…0bb9f`,
  `rc 1`): `C1_CURRENT: value=0 population=9 gate=1 guard=1`, `rc 0`. The landing claim
  plus its kill rule (c) are satisfied by two lines of code with no audit logic.
- `E3`: a gate that is *stricter* than the frozen checker (adds one claim, prints
  `value=1 population=10`, `rc 0`, sha256 `13ac4098…7455c`) is rejected:
  `C1_CURRENT: value=FAIL population=9 gate=0 guard=0`. The equality leg rewards
  *agreement* with the frozen arithmetic over truth, so a landing gate that fixes the
  class weaknesses (c)/(g)/(h) would fail the claim.
- Absence: at BASE (no gate in the archive) the driver prints `gate=0 guard=1`; the gate
  leg is vacuous whenever the file is untracked or deleted. Note the lane worktree at
  11:25 carries `?? corpus/current-claims.py`; a landing measured by `git archive <tip>`
  will not see an uncommitted gate and will read `gate=0 guard=1`.

### (f) Wrong-epoch subject — ADMITTED by the letter form, REFUSED by the receipt form

- `F1`: `Close: epoch F \`9cbe9d5f\` (epoch E \`dd31b786\` recheck) totalled 22 MATCH.`
  (line sha256 `814dc897…f9e879`). The sentence's subject is epoch F (receipt `23`), but
  the nearest preceding letter-rev is E inside a closed parenthetical: the checker emits
  `STMT SCORECARD:3 cls=match stated=22 auth=22 via=nearest-epochE OK`. Reading
  `value=3 population=17` — the false claim is counted and passes.
- `F2`: `Close: the epoch-F receipt \`controls-prefreeze-epochF.txt\` totalled 22 MATCH.`
  (`113d2d3f…c1660a`). Receipt-path pairing binds F: `stated=22 auth=23 via=receipt-
  epochF MISMATCH`; reading `value=4 population=17`. The receipt form is the safe one;
  the letter form resolves by position and a parenthetical citation hijacks it.

The plan's ceiling says "a statement's subject is resolved by the line's own text" — this
is that ceiling made concrete. It is still a hole in the predicate's claim to measure
"reference" defects: the plan explicitly repairs the epoch-reference defect by hand and
does not count it, yet a forged reference of exactly that kind passes.

### Extras (diagnostics and number shape)

- `G`: `The wave ran 12 cases in three lanes.` No line names `recheck-replay`, so the
  statement is UNBOUND and `bad` rises: `value=4 population=17`, but the summary prints
  `mismatches=4 unbound=0`. The frozen predicate is `value = MISMATCH+UNBOUND`; the
  checker prints `unbound=0` unconditionally and conflates both into `mismatches`. Two
  ordinary-English false positives follow: any `N cases` prose in the surface is dragged
  into POP, and its verdict is invisible in the summary. (Prototype `chk_fix.py` prints
  `mismatches=3 unbound=1 value=4`.)
- `H`: `The captures span 1,018 cases.` `([0-9]+) cases` anchors mid-number and reads
  `018` → `stated=18 auth=20 MISMATCH`; `value=4`. Here the accident is caught, but the
  same anchoring would *pass* a false claim if the authority were 18 (`1,018`), and a
  legitimate `1,020 cases` would read 20 and pass/fail by coincidence.

## 5. Surviving holes, ranked, with the smallest frozen-rule fix

1. **Statement census / selection (B1, B2, B3, D1, D2, I).** The predicate measures what
   remains in a heading span, not whether the declared statements are present. Deleting
   the three stale phrases gives `value=0 population=13`; deleting five more gives
   `value=0 population=8`; relocating all three out of the spans and rebuilding true
   statements gives `value=0 population=9`; a one-byte heading change drops a whole
   surface. **Smallest fix:** replace "population floor 8" in the frozen predicate with
   the declared census and compare the counts the checker already prints —
   `population == 16 and cases==3 and match==7 and epochs==2 and clocks==2 and pop==2`,
   with any shortfall counted as MISSING (a mismatch). The legitimate repair K1-F4 keeps
   exactly `16/3/7/2/2/2`, so the census is invariant under the landing. Additionally
   require exactly one heading match per surface (`section()` should FAIL on 0 or >1),
   which kills B3 and I without content heuristics. One driver-level `[ ]` chain plus
   four lines in `section()`; no change to the authorities.
2. **Guard is a number-echo (E1, E2, E3, absence).** `GATE` compares two self-declared
   integers from an arbitrary executable; `rc`, per-class counts, and bytes are ignored;
   absence passes; a stricter gate fails. **Smallest fix:** require
   `corpus/current-claims.py` to exist as a tracked file at the measured revision, run
   with `rc=0`, and compare its **full** summary line (value, population, mismatches,
   unbound, per-class counts) to the frozen checker's; and pin its sha256 in the frozen
   plan (round 56's `GATE_SHA256_PIN` convention). The pin cannot be predeclared for
   this round's landing (the gate is new), so at minimum the landing must record the
   executed gate's sha256 in its receipt and commit the file — otherwise `git archive`
   measurement reads `gate=0 guard=1` and kill rule (c) is vacuous.
3. **Parenthetical citation hijacks the subject (F1).** Nearest-preceding letter-rev
   binding picks a citation inside a closed parenthetical over the sentence's subject.
   **Smallest fix:** ignore letter-rev tokens inside parentheticals that close before the
   number. Prototype (`R57ReviewC1.d/chk_fix.py`, a scratch copy, not the frozen file):
   BASE stays `value=3 population=16`; F1 becomes `value=4` (caught); L-repaired stays 0.
4. **Diagnostics lie and a control is vacuous (G, driver rc, K1-F7).** `unbound` is
   hardcoded 0 while `mismatches` carries the sum; the driver always exits 0 on a
   non-admitted reading; the checker docstring says the EPOCHS authority is the receipt
   file count (5 files exist: B–F) while the code counts distinct plan tokens (6) and the
   `via=` label repeats the docstring's wrong name; K1-F7 (`epoch-A`→`epoch-Z`) cannot
   distinguish "authority read" from "authority ignored" because both epoch statements
   are already mismatched at BASE (K1-F4 is the discriminating epoch control).
   **Smallest fix:** count/print `mism` and `unb` separately (`value=mism+unb`), end the
   driver with `[ "$GUARD" = 1 ] && [ "$V" = 0 ]` as the exit status, correct the
   docstring/`via` label, and retarget K1-F7 at the repaired tree (drop one epoch token →
   expect a rise) or drop it.
5. **Number shape / class width (C, H).** `18 test cases`, `31 matches`, `SEVEN epochs`,
   `7 stated clocks` are uncounted; `1,018 cases` is read as 18. **Smallest fix:** a
   left boundary `(?<![\d,])` on every numeric class, and tolerate the demonstrated
   intermediate words (`N (?:test |selftest )?cases`, `N matches?` case-insensitive,
   `W [a-z-]*epochs?`, `N [a-z-]*clocks`) — still shape-based, but it closes the four
   demonstrated near-misses. This is a declared ceiling; it ranks last because the
   remaining evasion space is open-ended by construction, but the demonstrated shapes
   are exactly the claims the class claims to measure.

## 6. What the predicate is good for (calibration reading)

- It is a faithful **one-shot hand measurement** of the three named stales at BASE: the
  K1 battery reproduces 3/16, each single repair 2, the full repair 0, the receipt edit 6,
  the surface removal FAIL(1). The authorities are read, the statement lines are located
  correctly, and the receipt-path form is genuinely binding (F2).
- It is **not sound as a standing gate**: the four independently admitted broken shapes
  (B2 at pop 8, D2 at pop 9, E2 with a printer gate, A4 with a printer authority) each
  satisfy the plan's kill rule (a)/(c) without repairing or even containing the audited
  claims. The plan's declared ceilings cover A4 and (partly) C/F1; they do **not** cover
  census/selection (B/D/I) or the guard's self-attestation (E). Those two should be
  closed before the C1 claim is admitted, or the claim should be recorded as "the three
  named stales were repaired and a hand measurement reads 0", not as a reusable gate.

## 7. Residual risk and verification gaps

- No live OpenBao work was needed or run; the C2 trial is out of this seat's target.
- No `lsp` server was available in this seat, so no semantic caller/definition proof is
  claimed; all evidence is byte-level (line text, sha256, STMT lines) from the frozen
  instruments.
- The repaired landing tree `L` is my reconstruction of the plan's three repairs, not the
  L1's candidate (the worktree candidate was not read or scored).
- The forgeries were scored against the frozen driver/checker read from the lane
  worktree; both C1 blobs are byte-identical in epoch A and epoch B receipts, and the C1
  section text is unchanged across the two commits. The only drift observed is the C2
  instrument and the plan's C2/controls text (section 1).
- I did not attempt to defeat the *surface content* by rewriting an authority to make a
  *specific false statement* true while keeping the census (the declared answer-key
  ceiling); A4 is the landing-shaped demonstration of it.
- One forgery class was deliberately not run: editing `corpus/recheck-captures.tsv`
  (clocks) and the epoch receipts (MATCH) to make *false* statements true. Both are the
  same declared ceiling as A4 and are already exercised by K1-F6 in the refusing
  direction; the census fix does not address them, the pin fix does (captures/receipts
  are authorities, and their hashes are not pinned either).

## 8. Verification record (commands, rc, artifacts)

All under `/fast/scratch/hyaku/kagi-r57/R57ReviewC1/` (deleted before yield; selected
outputs copied to `.ufo/waves/round-57/w1/R57ReviewC1.d/`):

```
git -C <lane> archive 1cda9e7ae4767b4133e283bfbc08266d4c86362d | tar -x -C base   # rc 0
python3 forge.py      # 19 trees; results.json; rc 0
python3 k1.py         # K1-BASE/F4/F5/F6 rebuild; rc 0
HYAKU_SCRATCH=… bash plans/round-57-controls.sh   # 11 MATCH, 0 MISMATCH; rc 0
python3 -I -B chk_fix.py --root <tree> --verbose  # scratch prototype of fixes 3+4; rc 0
```

Per-tree driver/verbose logs: `R57ReviewC1.d/logs/<tree>.{driver,verbose}.txt`.
Harness and receipt: `R57ReviewC1.d/{forge.py,k1.py,chk_fix.py,results.json,controls.pre.txt}`.
The `results.json` records each forged tree's changed-file sha256 pairs (base vs forged);
key values are quoted in sections 3–4.
