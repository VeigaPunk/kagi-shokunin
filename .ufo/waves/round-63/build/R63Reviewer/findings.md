# R63Reviewer — round-63 attack findings (kagi, C1/C2 instruments)

Seat: reviewer (attack), round 63 attempt 1. Read-only on lane source: no lane
instrument, fixture or record was edited by this seat. Every attack tree is a
copy under `/fast/scratch/hyaku/kagi-r63/R63Reviewer/` (removed before yield).
Receipts: this directory; raw per-tree stdout in `receipts/measure-*.json`.

## 0. Pins, method, command legend

Measured trees and pins (measured, not quoted):

- `base` = `git -C <lane> archive 0c07aab8df64b673a54a5113aebd7f34b622adbc | tar -x`
  (10883 files). Every attack tree is `base` plus **one** byte-exact replacement;
  the anchor must occur exactly once (the driver refuses otherwise).
- BASE checker `plans/round-61-c1-check.py` sha256
  `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0` (81640 B,
  the round-62 hardened bytes). `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=75)`.
- Candidate checker measured: sha256
  `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`
  (snapshot 2026-11-07 20:09; the executor was still writing — §6). `--selftest`
  ⇒ `C1_CHECK_SELFTEST: PASS (cases=102)` (guard leg b needs N >= 91: passes).
- Lane repo (for `--repo` derivations): `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
  Fleet root (I6 derivation): `/home/vgpnk/Projects/shokunin` (the checker's
  `DEFAULT_FLEET`, equal to the value the counter passes with `--fleet`).

Command legend:

```
C_base(<tree>) = python3 -I -B base/plans/round-61-c1-check.py \
                   --root <tree> --repo <lane> --no-challenge
C_cand(<tree>) = python3 -I -B checkers/c1-cand-2009.py \
                   --root <tree> --repo <lane> --no-challenge
```

Harness control: the frozen ten forgeries (F1..F10) and six benign rewrites
(P1..P6) were rebuilt from the plan's tables and measured on the same trees.
BASE: F1..F10 each `C1_ROUTED: value=0` (accepted), P1..P6 each `value=1`
(rejected) — the plan's census reproduces exactly (accepted 10 / rejected 6).
Candidate: F1..F10 each `value=1` with the designated item 0 (`i3=0` F1..F3,
`i4=0` F4..F6, `i5=0` F7, `i7=0` F8, `i6=0` F9/F10); P1..P6 each `value=0`;
unmodified `base` `value=0`. The frozen population closes on both sides at this
snapshot.

The accepted line is identical on every accepted tree:

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
```

## 1. C1 — new forgery trees the frozen set does not name

19 trees (X1..X19). BASE column = `C_base`; candidate column = `C_cand`
(sha256 `eb08094c…`). `accepted` = `value=0`.

| id | attack (plan class) | file · anchor → replacement | BASE | candidate | verdict |
|---|---|---|---|---|---|
| X1 | hedge negator outside the closed set | `plans/round-60.md` `**A3 item 2 is withdrawn**` → `**A3 item 2 is ostensibly withdrawn**` | accepted | **accepted** `value=0 i3=1` | **open — F-9** |
| X2 | hedge negator outside the closed set | same anchor → `**A3 item 2 is purportedly withdrawn**` | accepted | **accepted** `value=0 i3=1` | **open — F-9** |
| X3 | denial verb outside the closed set | same anchor → `**A3 item 2 is withdrawn — the record contradicts it**` | accepted | **accepted** `value=0 i3=1` | **open — F-9** |
| X4 | denial verb outside the closed set | same anchor → `**A3 item 2 is withdrawn — a claim the record rejects**` | accepted | **accepted** `value=0 i3=1` | **open — F-9** |
| X5 | negation in a previous sentence (+ attribution) | same anchor → `**The draft's claim does not stand. A3 item 2 is withdrawn, as the draft had it**` | accepted | **accepted** `value=0 i3=1` | **open — F-8** |
| X6 | token inside a quotation, denial outside | same anchor → `**The draft's wording was "A3 item 2 is withdrawn", which the record does not support**` | accepted | **accepted** `value=0 i3=1` | **open — F-8** |
| X7 | token inside a quotation, denial outside | same anchor → `**The draft's wording was "A3 item 2 is withdrawn", a claim the record disputes**` | accepted | **accepted** `value=0 i3=1` | **open — F-8** |
| X8 | I7 subject swap with a third subject | `corpus/lessons/round-60.md` `so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %` → `so the sentinel's literal reading is 3/16 = 18.75 %, and the literal sentinel gives 4/16 = 25 %` | accepted | **accepted** `value=0 i7=1` | **open — F-7** |
| X9 | fraction paired with a percentage from a different denominator | same anchor → `… gives 4/16 = 25 %, i.e. 3/15 = 20 %` (both required pairs kept, a bogus third pair appended) | accepted | **accepted** `value=0 i7=1` | **open — F-7** |
| X10 | fabricated stamp that **is** a derived committer time | `corpus/lessons/round-60.md` `launch 15:09:28 −03` → `launch 15:06:58 −03` (15:06:58 is in the derived set) | accepted | **rejected** `value=1 i6=0` | closed (I6 conjunct works) |
| X11 | fabricated derived-time stamp added beside the real one | same anchor → `launch 15:09:28 −03 (also seen at 15:06:58 −03)` | accepted | **rejected** `value=1 i6=0` | closed (I6 conjunct works) |
| X12 | token form the grammar does not list (`cannot`) | `plans/round-60.md` anchor → `**A3 item 2 cannot be said to be withdrawn**` | accepted | **accepted** `value=0 i3=1` | **open — F-9** |
| X13 | prefix-negation token form (`un-withdrawn`) | same anchor → `**A3 item 2 is un-withdrawn**` | accepted | **accepted** `value=0 i3=1` | **open — F-9** |
| X14 | contrastive-exception abuse | same anchor → `**A3 item 2 is not, but the record says otherwise, withdrawn**` | accepted | **accepted** `value=0 i3=1` | **open — F-6** |
| X15 | quotation-mask abuse (scare-quoted negator) | same anchor → `**A3 item 2 is "not" withdrawn**` | **rejected** `value=1 i3=0` | **accepted** `value=0 i3=1` | **open — F-5 (hardening regression)** |
| X16 | negator beyond the 24-token window | same anchor → `**It is not the case, for the reasons the earlier draft gave in its third paragraph and in the appendix and after the record's own re-reading, that A3 item 2 is withdrawn**` | accepted | **accepted** `value=0 i3=1` | **open — F-9 (ceiling)** |
| X17 | I4 post-token denial outside the set | `corpus/lessons/round-60.md` `the round introduced three new record defects it did not route` → `… it did not route, a claim the record contradicts` | accepted | **accepted** `value=0 i4=1` | **open — F-9** |
| X18 | I5 post-token denial outside the set | `LOG.md` `it was rewritten in place at` → `it was rewritten in place at — the record contradicts this` | accepted | **accepted** `value=0 i5=1` | **open — F-9** |
| X19 | I6 post-token denial outside the set | `corpus/lessons/round-60.md` `launch 15:09:28 −03` → `launch 15:09:28 −03, a time the record disputes` | accepted | **accepted** `value=0 i6=1` | **open — F-10** |

Measured totals: BASE accepted 19/19 (X15 is the one BASE rejects: `value=1 i3=0`);
candidate accepted 17/19, rejected 2/19 (X10, X11). **The hardened grammar narrows
the class; it does not close it.** Two of the 17 are hardening-induced or
hardening-widened (X14, X15): X15 is *rejected* at BASE and *accepted* by the
candidate, so the round-63 quote mask creates a bypass the round-62 checker did not
have.

## 2. C1 — new benign rewrites the hardened grammar must still accept

8 trees (Y1..Y8); all must read `value=0` on the candidate.

| id | benign class | file · anchor → replacement | BASE | candidate | verdict |
|---|---|---|---|---|---|
| Y1 | appositive | `plans/round-60.md` `**A3 item 2 is withdrawn**` → `**A3 item 2, the every-request claim, is withdrawn**` | accepted | accepted `value=0` | correct |
| Y2 | passive with agent | same anchor → `**A3 item 2 has been withdrawn by the lane**` | accepted | accepted `value=0` | correct |
| Y3 | numeric form | `corpus/lessons/round-60.md` `the round introduced three new record defects it did not route` → `the round introduced 3 (three) new record defects it did not route` | accepted | accepted `value=0` | correct |
| Y4 | hyphenated anchor | `plans/round-60.md` anchor → `**A3-item-2 is withdrawn**` | accepted | accepted `value=0` | correct |
| Y5 | contrastive form | same anchor → `**A3 item 2 is withdrawn, not merely restated**` | accepted | accepted `value=0` | correct |
| Y6 | quoted-but-asserted | same anchor → `**A3 item 2 is withdrawn — the draft's phrase "A3 item 2 is withdrawn" now holds**` | accepted | accepted `value=0` | correct |
| Y7 | I6 benign parenthetical | `corpus/lessons/round-60.md` `launch 15:09:28 −03` → `launch 15:09:28 −03 (the superseded record's own stamp)` | accepted | accepted `value=0` | correct |
| Y8 | I7 appositive | `… 3/16 = 18.75 %, …` → `so the literal reading is 3/16 = 18.75 % (three of sixteen), and counting the sentinel as an attack seat gives 4/16 = 25 %` | accepted | accepted `value=0` | correct |

No false positive was found in this set: the hardening's precision holds on all
eight. (The six frozen benign fixtures also read `value=0`; §0.)

## 3. Counter attacks (C1_RESIDUAL / C2_REFUSAL / controls battery)

### A — a stub that prints the target line plus the leg fields

Artifact `attacks/stub-c1-full.sh` (prints
`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1)`
and `C1_RESIDUAL_SELFTEST: PASS (7/7 checks)`, exit 0). Two placements:

1. **As a tree's `plans/round-63-c1.sh`** (`trees/stubc1`, a copy of the candidate
   tree with the counter replaced by a stub printing the **BASE census + guard=1**;
   `plans/round-62-controls.sh` replaced by a one-match fixture so the C1 controls
   are measured in isolation). Battery (`attacks/r63ctl-snapshot.sh`, sha256
   `098de8cd…`) measured:

```
CONTROL C1-F8 expect=accepted=10 rejected=6 mismatch observed=accepted=0 rejected=0 population=10/6 verdict=mismatch
CONTROL C1-NOWORK expect=accepted=10 rejected=6 population=10/6 observed=accepted=10 rejected=6 population=10/6 rc=0 verdict=match
CONTROL C1-REAL expect=verdict-line;guard=1 observed=guard=1 accepted=10 rejected=6 rc=0 verdict=match
SKIPS: 4
CONTROLS: match=3 mismatch=1
```

   The stub is caught only by `C1-F8`. `C1-NOWORK` and `C1-REAL` both **match** a
   constant stub that prints the BASE census with `guard=1` — the two controls are
   jointly satisfiable by a constant. Finding **F-4**. Re-measured on the final
   battery bytes (`e90d5cfc`): identical lines (`match=3 mismatch=1`).
2. **As the checker inside a tree** (the counter's guard leg e): the counter's
   three stub shapes are refused (e1 no PASS line; e2 PASS line but no value; e3
   both lines but gate output == measurement output → constant-printer defence).
   A stub that prints the PASS line only for `--selftest` and `value=0` for
   measurement produces `accepted=10 rejected=0` — not a pass; the counter's
   target is `accepted=0 rejected=0`, so no printer stub can forge it. Closed.

### B — a counter whose `--selftest` prints PASS without executing a case

Artifact `attacks/selftest-stub-c1.sh`: a copy of `plans/round-63-c1.sh` (sha256
`a78a7c47…`) with an early dispatch inserted after argument parsing:

```
if [[ "$MODE" == "selftest" ]]; then
  printf '%s\n' 'C1_RESIDUAL_SELFTEST: PASS (7/7 checks)'
  exit 0
fi
```

Measured: `C1_RESIDUAL_SELFTEST: PASS (7/7 checks)` rc 0 — with **no** lane TSV
readable (the copy lives outside the lane) and no case executed. Nothing refuses
it: the battery never runs the counter's `--selftest`, and the C1 counter has no
self-challenge. Finding **F-3**.

### C — a battery whose control list is empty

Artifact `attacks/round-63-controls-empty.sh`: a copy of `plans/round-63-controls.sh`
(sha256 `098de8cd…`) with the seven `ctrl_*` calls replaced by `:`. Measured on
`trees/cand`:

```
SKIPS: 0
CONTROLS: match=0 mismatch=0
SEAT-STATUS: complete
rc=0
```

An empty control list reads a clean battery with zero skips. Any consumer that
gates on `mismatch=0` and `skips=0` (the C2 predicate's guard leg d) is therefore
satisfied vacuously. Finding **F-2**.

### D — the C1 counter's verdict guard (transient, fixed in-round)

The 20:04 bytes of `plans/round-63-c1.sh` (sha256 `a78a7c47…`) reference `$stub`
in the guard line and `$stub` in the verdict echo, but `stub` is never assigned
(`stub_leg` sets `SL_RC`/`SL_OK`; the verdict block sets `stub_rc`/`stub_e1`/…).
Under `set -uo pipefail` the reference is an unbound-variable error before the
`C1_RESIDUAL:` line. Mechanism reproduced in isolation:

```
$ bash -c 'set -u; [[ 1 -eq 1 && $stub -eq 1 ]] && echo yes'
bash: line 1: stub: unbound variable   rc=127
```

The 20:13 bytes (`9d37e5f9`) fixed the verdict path to `$STUB` but `stub_calc`
still assigned lowercase `stub` (`:312`) while the guard (`:463`) and the
selftest (`:527`) read `$STUB` — the same class, renamed. The current bytes
(`46dd1f21`) are consistent (`stub_calc` sets `stub`; guard `:513`, echo `:524`,
selftest `:578-582` all read `stub`; `leg_chal` sets `CHAL`). Finding **F-1**
(recurred twice; verify the final bytes).

### E — tampered fleet report (I6 trust boundary)

`derive_fleet_stamp` reads `{fleet}/.ufo/reports/round-60/kagi.md` §Stale-lane and
does not pin its bytes. With `--fleet` pointing at a scratch copy whose line reads
`launch 16:59:59` (instead of `15:09:28`):

```
F9  : c1: i6 HOLD … quoted-stamp=16:59:59 fleet-stamp=16:59:59
      C1_ROUTED: value=0 … i6=1 …            (the F9 forgery is accepted)
base: c1: i6 FAIL … quoted-stamp=15:09:28 fleet-stamp=16:59:59
      C1_ROUTED: value=1 … i6=0 …            (the unmodified tree now fails)
```

The counter's `real` leg (a) catches the tamper because it also breaks the
unmodified tree, so this is a residual risk, not a claim bypass: the I6 conjunct
is only as trustworthy as the fleet report's committed bytes. Fix: pin the fleet
report's sha256 in the receipt (or the counter) and read SETUP on a mismatch.

### F — PRIOR delegation

A tree whose `plans/round-62-controls.sh` is a two-line stub reads
`PRIOR-K1-BASE-C1 verdict=match` and `PRIOR-K1-BASE-C2 verdict=skip` — the PRIOR
rows are the tree's own battery output. Finding **F-12**.

## 4. Open findings, severity and fix

**F-1 (HIGH, C1 counter; recurred twice, fixed in the current bytes `46dd1f21`) —
the verdict guard referenced an unbound stub variable.** The 20:04 bytes
(`a78a7c47`) read `$stub` in the guard line and the verdict echo but assigned
neither. The 20:13 bytes (`9d37e5f9`) fixed the verdict path to `$STUB` but
`stub_calc` still assigned lowercase `stub` (`:312 stub=0; … stub=1`) while the
guard read `"$STUB"` (`:463`) and the selftest read `c1=$STUB` (`:527`) — the
same class, renamed. Under `set -uo pipefail` either form is an unbound-variable
error before the `C1_RESIDUAL:` line. The current bytes (`46dd1f21`, still `652665ec` at 20:26) are
consistent: `stub_calc` sets `stub`, the guard reads `"$stub"` (`:513`), the echo
reads `$stub` (`:524`), and `leg_chal` sets `CHAL` (`:361/:369`). **Able to fail:**
the counter's own selftest must run the verdict-mode guard composition
(`stub_calc 0 1 1` etc., present at `:578-582`) and the verdict path must be
exercised once before the claim; a case-mismatched name must fail `bash -u`
before any verdict. The class recurred because the selftest is not run by any
gate (see F-3).

**F-2 (HIGH, C2 guard) — an empty control list reads a clean battery.** Measured:
`CONTROLS: match=0 mismatch=0`, `SKIPS: 0`, rc 0. If the C2 counter's guard leg d
accepts `mismatch=0`/`skips=0` without a minimum population, the guard is vacuous.
Fix: require `match >= 6` **and** the six named control ids (`C1-F8`, `C2-F6`,
`C1-NOWORK`, `C2-NOWORK`, `C1-REAL`, `C2-REAL`) to appear with a non-skip verdict;
fail closed (`SETUP controls-empty`) otherwise. **Able to fail:** the empty-list
copy must read `guard=0` / exit 2.

**F-3 (MEDIUM, C1 counter) — a `--selftest` printer is unrefused.** Measured:
`C1_RESIDUAL_SELFTEST: PASS (7/7 checks)` rc 0 from a copy that executes no case.
The battery never runs the counter's selftest; the C1 counter has no
self-challenge. Fix: add a self-challenge case to the counter's selftest (mutate
`stub_calc`/`leg_selftest` in a copy and require `FAIL`), or add a
`C1-SELFTEST-MUT` control to the battery that runs the counter's `--selftest`
under the CM2a/CM2b mutations and requires a named `FINDING`. **Able to fail:** the
selftest-stub copy must read `FAIL` under the challenge.

**F-4 (MEDIUM, controls battery) — `C1-F8`/`C2-F6` are constant controls.**
`mk_stub_counter` prepends a dispatch that intercepts **every** non-selftest run
and prints the constant target line, so the control reads `mismatch` whenever the
counter file exists and is `bash -n`-valid — it tests the battery's stub machinery,
not the measured counter. Measured: a stub counter printing the BASE census with
`guard=1` reads `C1-NOWORK match`, `C1-REAL match` (only `C1-F8` mismatches, and
`C1-F8` mismatches for *any* counter). The C2 predicate's L3/L4 ("a constant-verdict
copy … makes the battery read mismatch for its control") is therefore satisfied by
construction. Fix: make the control run the **measured** counter on a mutated tree
(e.g. a tree whose checker is a printer stub) and require the counter to read
`accepted=10`/no verdict; or drop L3/L4 and rely on the counter's own challenge.
**Able to fail:** the BASE-census stub must read `mismatch` on `C1-NOWORK` or
`C1-REAL`.

**F-5 (MEDIUM, grammar; hardening regression) — the quote mask deletes a
scare-quoted negator.** X15 `**A3 item 2 is "not" withdrawn**` reads `value=0` on
the candidate and `value=1 i3=0` at BASE. `_mask_quotes` blanks every double-quoted
span ending at/before the token, so a negator the author quoted for emphasis is
deleted. Fix: mask only spans introduced by an attribution ("the draft's wording
was", "the record said") or spans that quote the superseded text; alternatively
treat a quoted negator immediately before the token as a negator. **Able to fail:**
X15 must read `value>=1`.

**F-6 (MEDIUM, grammar) — the contrastive exception is over-broad.** X14
`**A3 item 2 is not, but the record says otherwise, withdrawn**` reads `value=0`:
`_negated_before` exempts any negator with a `but` token anywhere between it and
the token, including a `but` in an unrelated parenthetical. Fix: require the `but`
to head the token's own coordination (`not X but <token>` with no intervening
comma-bounded clause), or drop the exception and keep only the idiom list.
**Able to fail:** X14 must read `value>=1`.

**F-7 (MEDIUM, grammar) — I7 binds by string proximity, not by subject.** X8
(`the sentinel's literal reading is 3/16 = 18.75 %, and the literal sentinel gives
4/16 = 25 %`) and X9 (required pairs kept, `3/15 = 20 %` appended) both read
`value=0`. `_pair_bound_to_subject` accepts any occurrence of the subject regex
within 8 tokens before the pair, so a third subject that contains the subject
string satisfies it, and extra non-derived pairs are never rejected. Fix: require
the subject occurrence to be the nearest subject and the pair to be the clause's
only fraction/percentage pair; reject any pair whose percentage is not the derived
value for its own fraction. **Able to fail:** X8 and X9 must read `value>=1`.

**F-8 (MEDIUM, grammar) — attribution and quotation classes stay open.** X5
(previous-sentence negation + "as the draft had it"), X6 (`"A3 item 2 is withdrawn",
which the record does not support`) and X7 (`… a claim the record disputes`) all
read `value=0`. The denial scan stops at the next `.`/`;` and only knows the closed
predicate set; the mask only covers spans ending before the token. Fix: scan for
denials through the whole sentence after the closing quote, and treat
`as the draft had it` / `the draft's wording` as an attribution that removes the
assertion. **Able to fail:** X5..X7 must read `value>=1`.

**F-9 (LOW–MEDIUM, grammar; plan ceiling) — the closed-list classes stay open.**
X1/X2 (hedges `ostensibly`, `purportedly`), X3/X4 (denial verbs `contradicts`,
`rejects`), X12 (`cannot`), X13 (`un-withdrawn`), X16 (negator 30 tokens back),
X17/X18 (I4/I5 post-token denial verbs). The plan's ceiling names the negator set,
the denial set and the 24-token window as a floor, so these are routed defects, not
claim failures. Fix (next round): widen the negator/denial sets with the measured
forms, add a prefix-negation rule (`un-`, `non-`, `cannot`), and make the window a
sentence-scoped scan rather than a 24-token cap. **Able to fail:** each tree must
read `value>=1`.

**F-10 (LOW, grammar) — I6 accepts a post-token denial verb on the stamp line.**
X19 `launch 15:09:28 −03, a time the record disputes` reads `value=0`; I6's denial
list is only the four Amendment-A1 phrases. Fix: run the same `_denied_after` test
on the I6 line, or add `disputes`/`disputed`/`contradicts` to `I6_DENY_PHRASES`.
**Able to fail:** X19 must read `value>=1`.

**F-11 (LOW, plan conformance) — the C1 counter's guard has six legs and its
verdict line carries a `chal=` field.** The frozen §C1 guard is five legs
(a)–(e) and the frozen output line is
`C1_RESIDUAL: accepted=A rejected=R population=10/6 guard=G (real=… selftest=…
prior=… para=… stub=…)`. The current counter (`46dd1f21`) adds guard leg (f), the
checker challenge (`leg_chal`, `:357-369`, `:509-513`), and prints
`(real=… selftest=… prior=… para=… stub=… chal=…)` (`:524`). The extra leg is a
strengthening, but it changes the frozen guard's truth table and the output shape;
a tree that satisfies (a)–(e) and fails (f) reads `guard=0`, which no frozen kill
rule names. Fix: either drop the challenge from the guard composition (keep it as
a diagnostic line) or land it as a disclosed amendment before the candidate
reading. **Able to fail:** the verdict line must match the frozen field list.

**F-12 (LOW, controls battery) — the PRIOR rows are the tree's own battery
output.** `ctrl_prior` copies the candidate tree and re-emits each `CONTROL` line
from the tree's `plans/round-62-controls.sh` without an independent check
(`:330-369`). Measured: a tree whose `plans/round-62-controls.sh` is a two-line
stub printing `CONTROL K1-BASE-C1 … verdict=match` and `SKIPS: 1` reads
`PRIOR-K1-BASE-C1 verdict=match` and `PRIOR-K1-BASE-C2 verdict=skip` — the PRIOR
half of the battery is satisfiable by a stub. Fix: pin the round-62 battery's
sha256 in the receipt and require it before re-emitting, or run the round-62
battery from the lane rather than the measured tree. **Able to fail:** a stub
`round-62-controls.sh` must read `mismatch` or `SETUP`.

## 5. Verified closed

- The frozen ten forgeries are rejected by their designated item and the six
  frozen benign rewrites are accepted (§0) — the claim's population closes at the
  measured snapshot.
- X10/X11: a fabricated stamp that is a derived committer time, whether it
  replaces or is added beside the superseded stamp, reads `value=1 i6=0` — the new
  I6 quoted-set-equals-derived-stamp conjunct works.
- The counter's three checker-stub shapes (e1/e2/e3) are refused; a printer stub
  cannot forge `accepted=0 rejected=0` because it cannot distinguish the fixtures.
- The eight new benign rewrites are all accepted — no false positive in this set.
- The candidate checker's selftest reads `C1_CHECK_SELFTEST: PASS (cases=102)`
  (>= 91), so guard leg b passes at this snapshot.

## 6. Residual risk and verification gaps

- **The candidate checker was still being written during the measurement.** The
  executor changed `plans/round-61-c1-check.py` at least three times between
  20:04 and 20:13 (`53acc21d` → `cc92d8a9` → `eb08094c`). The table above is
  measured on `eb08094c` (20:09), which was still the lane's bytes at 20:22. A
  20:04 snapshot (`53acc21d`) was mid-edit and read every tree
  `value=3 i3=0 i4=0 i5=0` including the unmodified BASE tree — a transient, not
  a finding. The L1 must re-run `C1_RESIDUAL` on the final bytes; the X-tree
  measurements must be repeated if the grammar code changes.
- **The C1 counter and controls battery also changed during the wave**
  (`a78a7c47` → `9d37e5f9` → `46dd1f21` → `652665ec`; battery `d489600a` →
  `098de8cd` → `74ed1624`). F-1's second form is fixed in `46dd1f21`/`652665ec`; F-2/F-4 were re-measured
  on `74ed1624` and `e90d5cfc` with identical lines; F-3 was measured on `a78a7c47` and the
  early-dispatch shape is unchanged in `46dd1f21` (the selftest block still has
  no self-challenge).
- **The C1 counter's verdict run did not complete under wave load.** Two runs
  (20:07 on `a78a7c47`, 20:13 on `9d37e5f9`) were cancelled after the run
  directories showed the fixture and prior legs complete but the process starved
  behind four concurrent counter runs (the L1's `3222566`, the mutation-tester's
  two, and a fourth). No `C1_RESIDUAL:` line was captured by this seat; the
  plan's BASE census (accepted=10 rejected=6) and the L1's own run are the
  authority. F-1 is therefore a source-level finding with an isolated mechanism
  reproduction, not a measured verdict line.
- **`plans/round-63-c2.sh` did not exist at measurement time**, so the C2
  predicate's guard leg d could not be exercised end-to-end; F-2's impact on
  `C2_REFUSAL` is therefore a source-level inference from the battery's exit
  contract plus the measured empty-list reading, not a measured `C2_REFUSAL`
  line. If the C2 counter lands before the L1's candidate reading, run
  `bash plans/round-63-c2.sh --tree <tree-with-the-empty-battery>` and require
  `guard=0` or `SETUP`.
- **Not run by this seat:** the real seal trial (`bao`), the round-62 controls
  battery's own 14 controls, and any lane gate. No lane file was written; no
  git/jj mutation was run anywhere.
- **Tooling:** none installed, upgraded or removed by this seat.

## Appendix — exact measured lines per tree

`C_base` = BASE checker `f2afd9b8…`; `C_cand` = candidate `eb08094c…`.

- **X1** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X2** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X3** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X4** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X5** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X6** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X7** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X8** (forgery) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X9** (forgery) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X10** (forgery) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`
- **X11** (forgery) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`
- **X12** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X13** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X14** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X15** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X16** (forgery) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X17** (forgery) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X18** (forgery) `LOG.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **X19** (forgery) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y1** (benign) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y2** (benign) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y3** (benign) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y4** (benign) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y5** (benign) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y6** (benign) `plans/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y7** (benign) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **Y8** (benign) `corpus/lessons/round-60.md`
  - BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
  - CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`

Frozen controls (same harness):
- **F1** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
- **F2** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
- **F3** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
- **F4** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`
- **F5** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`
- **F6** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`
- **F7** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0`
- **F8** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0`
- **F9** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`
- **F10** BASE rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`
- **P1** BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **P2** BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **P3** BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **P4** BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **P5** BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- **P6** BASE rc=1 `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0` / CAND rc=1 `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`

SEAT-STATUS: complete
