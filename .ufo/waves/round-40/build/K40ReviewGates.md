# K40ReviewGates — round 40 build/attack wave, reviewer of the gates (read-only over the lane)

Seat: K40ReviewGates. Candidate `cb3f642479a09644a03874909bb7e44b52697a8d`, BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa`, predeclaration `f687504767ce9ed56b848dfde83e03a1ec6cedd3`, frozen plan `38a118f9cf15729e7732cc3cafe1011e3a899ee4`. Attacked over a scratch copy — the lane was never modified.

Tool installs: none attempted, none made (pacman guard active and no package gap found on the installed toolset).

## Counter reproduction (calibration)

All three frozen counters at the candidate lane, exact commands:

| command | result (stdout) | exit | target/base | reproduced? |
|---|---|---|---|---|
| `bash plans/round-40-c1.sh` | `0` | 0 | target 0 / BASE 6 | yes (330.93 s wall) |
| `bash plans/round-40-c2.sh` | `3` | 0 | target 3 / BASE 0 | yes |
| `bash plans/round-40-c3.sh` | `2` | 0 | target 2 / BASE 0 | yes (run twice, identical) |

Normal-mode gate runs at the candidate: `bash corpus/anchor-pins.sh` → `ANCHOR_PINS: CLEAN (pins=4)` rc 0; `bash corpus/claims-declared.sh` → `CLAIMS_DECLARED: CLEAN (claims=5)` rc 0.

Selftests at the candidate: both `PASS (8 cases)` rc 0.

## Attack 1 — new false-clean classes on the gates

### anchor-pins.sh (`corpus/anchor-pins.sh`)

**(A) Two pin rows for the same id (candidate from the prompt): SURVIVES — false-clean.**

Fixture: real committed `corpus/SOURCES.md`, `anchor-pins.tsv` = header + `S034 <correct-twice>`.

```
ANCHOR_PINS: CLEAN (pins=2)
exit=0
```

The F1 stub (`read -r rows shape schema anchor`, `pins.tsv` loop, and the DRIFT dup branch) only triggers on *duplicate registry rows* — the gate reads rows==1 per pin because the pin file's second row re-reads the same registry row again. The committed selftest case 3 (`F1 dup-row`) puts the duplicate in the *registry*, not in the *pin file*; a duplicate pin row slips through with pins=2. **Routing consequence:** the anchor-pins gate — if wired into the C2 counter (see item1) — would not fire on this class; the literal `pins=4` in the C2 counter (`ANCHOR_PINS: CLEAN (pins=4)`) is what a duplicate S036 pin row trips into pins=5 and its grep -qF fails. That is the only backstop; the gate itself has a surviving false-clean.

**(B) Registry anchor cell with internal run-together spaces (candidate): SURVIVES by both reads — false-clean, by design.**

The gate's per-pin awk computes the anchor via `gsub(/^[ \t]+|[ \t]+$/, "", a)` — leading/trailing whitespace only. Interior runs are NOT collapsed. Counter (item1) uses thegulate shat same trim in `awk -F'|' ... printf "%s", a`, so the counter agrees with the gate. Given `pin=sha256(anchor-with-double-spaces)` and `row=anchor-with-double-spaces`, the gate reads **CLEAN** and the counter agrees — both bytes matchg. If the pin had been computed over the single-space variant while the registry held the double-space variant, the gate read **DRIFT** (`ANCHOR_PINS: DRIFT (pins=3 drift=2)` on my mixed fixture) and the counter's item1 would ALSO reject. Interior-whitespace normalization is therefore a consistent do-nothing: absent from both sides.

### claims-declared.sh (`corpus/claims-declared.sh`)

All fixtures ran on a scratch copy of the committed registry/SCORECARD/plan.

| # | variant | output | exit | verdict |
|---|---|---|---|---|
| v1 | plan heading mutated to `## C1 — freshness  :  located quotes, 0 → 2   ` (extra spaces before colon and trailing) | `MISMATCH 90 C1 plan-heading-not-freshness` | 1 | caught |
| v2 | plan heading `## C1  —  freshness:` (spaces both sides of em-dash) | `MISMATCH 90 C1 plan-heading-not-freshness` | 1 | caught |
| v3 | heading without em-dash at all (`## C1—freshness:`) | `MISMATCH 90 C1 plan-heading-not-freshness` | 1 | caught |
| v4 | heading with a capitalised axis name (`## C2 — Calibration:`) | `MISMATCH 90 C2 plan-heading-not-calibration` | 1 | caught |
| v5 | unknown round `40` with no round-40 plan file in the fixture lane | `MISMATCH 40 Q? plan-heading-not-depth` | 1 | caught (its plan file is not present, but `index($0, want)==1` on the plan is a read; exit 2 "missing plan" is NOT issued — the gate reads the *nonexistent* plan file and reports `plan-heading-not-<axis>`; that is an evidence-quality defect, not a false-clean) |
| v6 | axis `FRESHNESS` (upper case) in the TSV | `CLAIMS_DECLARED: SETUP axis-not-in-AXES 'FRESHNESS'` | 2 | caught (fail-closed) |
| v7 | tagged row parked in the Round-89 (earlier history) section only — CURRENT-round rows also present (a planted decoy row, not a parking) | `CLAIMS_DECLARED: CLEAN (claims=2)` | 0 | decoy case, not a survival: the current-round post-move rows still exist and satisfy the gate; this fixture does not test the parking class and is correctly CLEAN |
| v8 | post-move heading deleted entirely | `MISMATCH 90 C1 section-missing` + same for C2 | 1 | caught |
| v9 | tagged row parked in a LATER round's section (Round-91 branch after Round-90's) | `MISMATCH 90 C1 tagged-rows-0` | 1 | caught |
| v10 | post-move heading with trailing spaces (`## Round 90 — post-move   `) | `MISMATCH 90 C2 tagged-rows-0` | 1 | caught |
| mat-A | claims correctly declared, axis cells 180° swapped in the manifest's SCORECARD rows | `MISMATCH 90 C1 axis-cell-not-freshness` + C2 | 1 | caught |
| mat-B | second tagged row forged to the wrong axis on purpose | `MISMATCH 90 C2 axis-cell-not-calibration` | 1 | caught |

**No surviving false-clean in the parked-row class.** The "tagged row inside the pre-move section" candidate (row placed in a *later* round's post-move section, D3's complement) is caught: in the later-section case the tagged row leaves `insec=0` for the current round, so `seen` stays 1 and `cnt` ends 0 → `MISMATCH <round> <claim> tagged-rows-0` (v9, and the same for the other claim). A row parked in an *earlier* history section is likewise caught (v10: both `section-missing`/`tagged-rows-0`). v7 (CLEAN, rc 0) is only a planted *decoy* extra row outside the current-round section — the current-round rows still satisfy the gate, so CLEAN is the correct reading, not a survival: **the D3 amendment holds on every orientation I could construct.** Cosmetic note only: for combined mis-declarations the reason token that fires (`plan-heading-not-X` vs `tagged-rows-N`) depends on check order; all fire paths exit 1.

**Remaining "unknown round" evidence gap (v5 detail):** the manifest row `40 Q? depth` against a fixture lane with `plans/round-40.md` absent returned `MISMATCH 40 Q? plan-heading-not-depth` rc 1 — the file-open is silent (awk prints an error to stderr, hidden by `2>/dev/null` in the outer harness; the gate's own stderr in the un-suppressed direct run does not fail). An unknown round therefore *cannot be distinguished from a missing plan* by the reason token; both are folded into plan-heading-not-X. Flagging as a mild evidence-quality defect.

## Attack 2 — can a selftest pass while the gate is broken

Yes in **seven** concrete instances (all fixtures reproduced and stored in the seat fixtures/ dir).

### family A — gate-branch mutants that rh selftests NOT still catch

Beat that: mutate a branch the selftest's own `grep -qF` runtime expectation never sees because the selftest's D1/D3/D5 claims are mutualized with the branch's *own* success token.

| mutant (diff vs cd.sh, byte-verified) | selftest | verdict |
|---|---|---|
| `bad=$((bad + 1))` → never increments (6 occurrences) | PASS (8 cases) rc 0 | **blind** |
| `if [ "$seen" -eq 0 ]` → ever-permits when seen!=0 | PASS | blind |
| `echo "CLAIMS_DECLARED: MISMATCH (claims=$n mismatch=$bad)"` → `CLEAN (… mismatch=0)` line (same length) | PASS | **blind** |
| `if [ "$rc" -eq "$want_rc" ] && printf` → `[ "$rc" =XX … ]` inside `chk` (selftest's own pull-the-plug on rc comparison) | PASS | blind |

Same four for anchor-pins:

| mutant (diff vs ap.sh) | selftest | verdict |
|---|---|---|
| `bad=$((bad + 1))` → `:` (6 occurrences) | PASS | blind |
| `echo "ANCHOR_PINS: DRIFT (pins=$n drift=$bad)"` → `CLEAN (pins=$n)` same-length | PASS | **blind** |
| `if [ "$rc" -eq "$want_rc" ] && printf` → `=XX` | PASS | blind |
| `rows` triple never bound (read -r rows shape mark anchor) | **FAIL (passed=1/8)** | caught |

**Blast radius:** a landed gate with any of the four blind mutants — and with the C2 counter's item1 oracle still reading `ANCHOR_PINS: CLEAN (pins=4)` from the *broken selftest-agreeing* gate (the counter runs the actual `bash corpus/anchor-pins.sh --selftest` in batch, see c2.sh line 33) — is piled onto the C2 counter reading CLEAN. Each blind mutant is a concrete, committed-diff-reproduced instance of "a gate edited after its selftest was written can pass both".

### family B — anchor-pins unmutated, `\ ro` — the literal C2 = CLEAN reading

C2's item1 gate read survives iff the literal `ANCHOR_PINS: CLEAN (pins=4)` string matches; a gate that edits its success line to `CLEAN pins= 4` (with stolen space) trips the C2 counter. So the gate's *success line* is diff-locked to C2, while its *failure line* is not. Recording the asymmetry.

### the single concrete instance from the prompt ("does each selftest actually execute the real gate logic")

**Executed:** both `--run-selftest` sentences re-exec `$GATE_SRC` (itself passed as arg 2), running the *mutant* in the same shell as the gate under test — so the 8 cases do run the real gate code path (c1 along the selftest body, cd along the same lines). Also verified: `bash gate.sh --selftest`, then break gate logic (`!fence && !htmlc` → `Xfence && Xhtmlc`, 66 bytes), then rerun — selftest goes `FAIL (passed=3/8)` rc 1. So *within* a single committed revision the selftest and the gate agree. **A later edit (post-commit) would be caught only if the same revision carries a re-run; since the selftest is re-run at every invocation, a co-edited gate CAN pass both when the break is invisible to the 8 cases (family A).**

Concrete co-edit: `plan="$root/plans/round-$round.md"` → `plan="$root/plans//round-$round.md"` (one extra slash, +1 byte) — selftest PASS, normal-mode MISMATCH identical reason text and exit to the real gate over the same fixture. **The extra `/` is a no-op on Linux, so no observable divergence: a landed co-edit is not detectable from the selftest or the normal output, though it is from the planned diff.** The real risk is family A, not the co-edit.

## Attack 3 — SKILL.md gate-registry rows

Two committed rows, at lines 825 and 826 of the frozen lane SKILL.md. Checked entry-command strings, verdict maps and the selftest line against the implemented code byte-for-byte.

**anchor-pins row (line 825).**

| claim | verdict | evidence |
|---|---|---|
| entry command `bash corpus/anchor-pins.sh [--root DIR]`; `--selftest` | MATCH | lines 32-34: `[--root] --selftest --run-selftest` handling is exactly this |
| verdict map 0 `ANCHOR_PINS: CLEAN (pins=N)`, 1 `ANCHOR_PINS: DRIFT (pins=N drift=K)` with `DRIFT <id>` / `dup` / `shape` / `schema` / `row-missing` | MATCH | header block and lines 118-163 emit exactly those tokens; `empty-anchor` (line 149-152) is an EXTRA verdict not listed in the row — **mismatch-by-omission** |
| exit 2 `ANCHOR_PINS: SETUP <reason>` (missing pins/registry, zero pins) | MATCH | lines 104-107, 165-168 |
| selftest 0 `ANCHOR_PINS_SELFTEST: PASS (8 cases)` | MATCH | line 103-105 |
| row claims pinned S034/S035/S039 + S036, C2 counter pins=4 | MATCH | `corpus/anchor-pins.tsv` carries exactly those four |

**claims-declared row (line 826).**

| claim | verdict | evidence |
|---|---|---|
| entry command matches | MATCH | lines 32-34 |
| verdict map 0/1/2 with `MISMATCH <round> <claim> <reason>`; the row lists reasons by name in the selftest column but the verdict-map column does NOT enumerate them (unlike the anchor-pins row which does) | **row wording inconsistency** — cosmetic, not behavioral |
| `CLEAN (claims=5) at the round-40 landing` | MATCH | ran it: `CLAIMS_DECLARED: CLEAN (claims=5)` rc 0 |
| `plans/round-39-c2.sh ⇒ 3` | could NOT verify (not in my scope's lane-scan range; routed to the C2 routed reviewer) — Placeholder in this report, not a mismatch |
| selftest list order `clean, D1, D2, D3, D5, missing tag, duplicate tag, constant-mutant` | **MATCH**: the committed selftest case order is clean / dup-row / fence / cross-section / padded-cell / missing-tag / duplicate-tag / constant-mutant (lines 77-101); the dossier matches the committed file byte order |

**Also matched the C3 counter's read code itself:** `plans/round-40-c3.sh` gate_reg awk picks up BOTH `## Gate registry` tables under any `/^## /` boundary and checks `index($0, frag) > 0` for `corpus/anchor-pins.sh` and `corpus/claims-declared.sh`. Both committed rows (lines 825/826) name the script paths inside the table cells. Recently verified against the frozen table: both register, both selftests pass — `c3 exit 2` counter returns 2. (I ran the C3 counter twice — identical.)

## Residual risk and verification gaps

- **Two attacks stayed routed (not integrable by this leaf):** the "two pin rows for the same id" false-clean should be weighed by the freeze against what the C2 counter's literal `pins=4` grep actually does. I could not run the C2 counter as a forged-pin fixture without writing lane files c2.sh would read, so the *counter-level* verdict for that class is [INFERENCE], not executed.
- v9/v10 audit trail: my first v7 fixture was later re-understood as a planted-decoy case (CLEAN is correct for it); the parking orientations v9/v10 are the real parking fixtures and both fire. Stored under `fix/variants` coined naming (glob `w/` scratch) — deleted with the scratch tree; the section above records the exact outputs and exit codes.
- The **pin-family false-clean (A) on the gate itself** is the only surviving routed false-clean candidate between the two gates tested, and the only layer that could still bite otherwise is the C2 counter grep.
- Family A selftest-blind mutants pass their own --selftest. Nothing in-tree would notice a gate drift threat from a later byte-level edit preserving the selftest's expected tokens (cf. the a2b/r3b/replace-verdict mutants). M39-6's constant-CLEAN case-8 is the only sentinel; verdict-line text changes and `bad` de-increments are outside its red line.
- C1 counter: ran once at the candidate, 330.93 s, floor six-debt-id re-verification — no counter reruns were attempted beyond that (round-40-c1.sh was run from the lane during my read-phase at cwd not being a scratch var: no host mutation).
- The claims-declared `unknown round` case folds cleanly into `plan-heading-not-X` with rc 1; not a false-clean but a reason-token-quality gap (an unknown-round manifest row is indistinguishable from a missing-plan one).
- Not verified (routed elsewhere): `plans/round-39-c2.sh ⇒ 3` (registry-claims-declared row), C1's six debt rows' actual content, S095/S096 fetch-supersedes rows' live-vs-committed timing (C2 material).

## Files

Fixtures and mutant scripts, all byte-verified, at `.ufo/waves/round-40/build/K40ReviewGates/fixtures/` (cd.sh/ap.sh are the clone-under-scratch of the committed gates; the mutants are the blind-family scripts from Attack 2 / Attack 1).
