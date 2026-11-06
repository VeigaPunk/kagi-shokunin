# K49CriticCeiling — round-49 counter attacks (C1 operability, C2 calibration)

Seat: critic (leaf). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `082bfb3f` (predeclaration).
BASE `89afe91878f10805921d3caa67d28d21b33226da`. Instruments read, never edited:
`plans/round-49-c1.sh`, `plans/round-49-c2.sh`, `plans/round-49-controls.sh` (19/19 MATCH receipt read).
Scratch: `/fast/scratch/hyaku/kagi-r49/K49CriticCeiling` (removed at exit).

## Return (axes)

- **C1 operability: forged.** A 13-line trial that executes nothing reads `value=5` because the frozen
  falsifiers are byte-distinguishable wrappers while the real run is a symlink to the pinned binary.
  This sits inside the plan's **named ceiling** ("a trial that detects the counter's shims (reads its PATH
  or the shim bytes) passes"), so it is a recorded tradeoff, not a hidden regression — but the ceiling is
  cheap (a one-line `[ -L "$(command -v bao)" ]` also reads 5), and `5` is therefore not evidence of
  operability on its own. The seat supplies a leg that separates the two at L1 time.
- **C2 calibration: forged, and NOT inside any named ceiling.** The six frozen keys take their live
  values from ledger rows `R12-03`/`R14-01`, i.e. from `corpus/claim-ledger.tsv` — a file none of
  G1–G6 protects. Repointing those two rows at a stub that prints the numbers the documents already
  state reads `value=0` while `stamps.tsv` still holds 123 rows (stated 122) and the round-45 entry still
  carries no `Reverify:` line and no stamp row (`DOC_AUDIT: BROKEN (entries=36 row_linked=32 by_hand=3
  undeclared=1 … unpinned=1 …)`). This is a hidden regression: the predicate says "agree with the
  observed repo state", but the observation is candidate-defined.
- The assignment's suggested C2 route (move the stated line so its locator stops matching) **does not
  forge**: a missing match reads `UNLOCATED` and counts as not-OK (`value=6`). Receipt below.

## C1 forgery — identity detection, no mechanics

Files (in `.ufo/waves/round-49/build/K49CriticCeiling/`): `forgery-c1-trial-sha.sh` (primary),
`forgery-c1-trial-link.sh` (one-line variant), receipts `c1-t.out`, `c1-t-link.out`.

Primary body: `command -v bao` → `sha256sum` the file → equal to the pinned OpenBao 2.7.2 digest ⇒ print
five `TRIAL T<n> HOLDS …`, else five `BROKEN …`; final `OPENBAO_TRIAL:` line; with no `bao` on PATH
prints `SETUP` and exits 2. It never starts a server and never runs a `bao` subcommand.

Fixture: `git -C <lane> archive 89afe9… | tar -x -C $S/t`, trial placed at
`corpus/openbao-token-trial.sh`, `controls/fixtures/entry-measured.ref.md` appended to
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`.

Verbatim counter output (rc 0):

```
C1_OPENBAO_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```

One-line variant (`[ -L "$(command -v bao)" ]` instead of the hash) — same output:

```
C1_OPENBAO_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```

Why it works: `run real` puts `ln -s "$BAO_BIN" "$W/bin/real/bao"` on PATH (pinned bytes, a symlink);
`mkshim` writes a `#!/bin/bash` wrapper (different bytes, a regular file). Both signals are readable by
the trial before it decides anything; `nosecret` and `setup_ok` are untouched by it.

### Leg that tells forgery from genuine work — `leg-c1-transparency.sh`

(a) static: the trial must not resolve the identity of the binary it runs (sha/readlink/realpath/stat/
file/xxd/od/head -c/`type -P`); (b) dynamic: run it with a **transparent** wrapper on PATH — a shell
script that records `argv[1] argv[2]` only (never a token-bearing argument) and `exec`s the pinned
binary, so behaviour is identical. Genuine work keeps five HOLDS and the log shows the dev-server and
token/lease mechanics; identity-detecting work prints BROKEN (wrapper bytes differ) and calls nothing.

```
LEG_C1: PASS trial=openbao-token-trial.ref.sh rc=0 identity_reads=0 holds=5 calls=32
LEG_C1: FAIL trial=openbao-token-trial.sh rc=0 identity_reads=1 holds=0 calls=0 identity-reads=1 holds-missing: T1(0) T2(0) T3(0) T4(0) T5(0) holds=0 mechanics-not-executed: [server ]=0 [token create]=0 [token lookup]=0 [token renew]=0 [token revoke]=0 [login ]=0 [lease lookup]=0 [secrets enable]=0 [write -format=json]=0
LEG_C1: FAIL trial=openbao-token-trial.sh rc=0 identity_reads=1 holds=0 calls=0 identity-reads=1 … mechanics-not-executed: …   (the -L variant; full text in leg1-link.out)
```

PASS receipt is on the frozen reference fixture (`controls/fixtures/openbao-token-trial.ref.sh`,
32 `bao` invocations); FAIL receipts are on both forgeries. **FAIL on the forgery, PASS on the genuine
trial** — the leg discriminates.

## C2 forgery — redefining the live source

Files: `forgery-c2-reading-stub.sh`, `forgery-c2-claim-ledger-rows.diff` (fixture commit `770097f`).

Change: two command columns only, in a scratch `git clone --shared` checkout of BASE (toplevel asserted):

```
-R12-03	grep -c '[^[:space:]]' corpus/stamps.tsv	^122$	…
+R12-03	bash corpus/reading-stub.sh stamps	^122$	…
-R14-01	bash corpus/claim-ledger.sh docs	^DOC_AUDIT: CLEAN \(entries=35 row_linked=32 by_hand=3 …
+R14-01	bash corpus/reading-stub.sh docs	^DOC_AUDIT: CLEAN \(entries=35 row_linked=32 by_hand=3 …
```

plus a 12-line stub that prints `122` and the already-declared `DOC_AUDIT: CLEAN (entries=35 row_linked=32
by_hand=3 …)` line. Both stub outputs match the two rows' pinned expectation strings byte for byte
(checked with `grep -qE`), so a reviewer diffing expectations sees nothing.

Verbatim counter output (rc 0):

```
C2_SELF_COUNTS: value=0 keys=6 lines=63 self_counts_rc=2 SC-SKILL-STAMPS=OK PV-STAMPS=OK RD-STAMPS=OK RD-DOCS-ROWLINKED=OK RD-DOCS-BYHAND=OK RD-DOCS-ENTRIES=OK
SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)
```

Real state of the same commit (`c2f-realstate.txt`; captured from a fresh `git archive BASE` tree — the
forgery edits only the two ledger command columns and adds the stub, so the artifact state is identical):

```
DOC_AUDIT: BROKEN (entries=36 row_linked=32 by_hand=3 undeclared=1 missing_ids=0 unpinned=1 duplicate_reasons=0 floor=18)
stamps=123 rows; SKILL/PROVINCE/README state 122
```

Guard-by-guard: G1 (scripts) untouched; G2 (the six TSV rows) untouched; G3 (35 knowledge paths) intact;
G4 (122 BASE stamps paths) intact — the row was added, never removed; G5 (POLICY lines) still exactly the
two feed-token rows; G6 (63 lines) intact. Nothing in G1–G6 binds the **definition** of a live source,
although the predicate's sentence ("observed repo state") presumes it. The plan's kill rule "any ledger
row loses its row" does not fire: both rows keep their ids, expectations, exit codes and timeouts.

### Hypothesis test — "move the stated line so it no longer matches"

Fixture `c2u`: SKILL.md's `(122 stamps + 86 claims` → `(122 stamp records + 86 claims`, committed in a
scratch clone. Verbatim counter output (rc 0):

```
C2_SELF_COUNTS: value=6 keys=6 lines=63 self_counts_rc=2 SC-SKILL-STAMPS=UNLOCATED PV-STAMPS=STALE RD-STAMPS=STALE RD-DOCS-ROWLINKED=SETUP RD-DOCS-BYHAND=SETUP RD-DOCS-ENTRIES=SETUP
SELF_COUNTS: POLICY (claims=63 stale=2 unlocated=2 ambiguous=0 policy=2 setup=3)
```

A missing match reads `UNLOCATED`, which the counter counts as not-OK. **This route cannot forge a 0** —
it only raises the value. The counter holds on this axis.

### Leg that tells forgery from genuine work — `leg-c2-live-sources.sh`

(1) the two source rows (`R12-03`, `R14-01`) must be byte-identical to BASE; (2) all six quantities are
re-derived directly from artifacts, bypassing the ledger-row indirection: stamps data lines vs the three
stated counts, and `bash corpus/claim-ledger.sh docs` run in a scratch clone vs the README's three stated
declaration counts.

```
LEG_C2: FAIL rev=770097f source-redefined: R12-03 R14-01 SC-SKILL-STAMPS stated=122 live=123 PV-STAMPS stated=122 live=123 RD-STAMPS stated=122 live=123 RD-DOCS-ENTRIES stated=35 live=36
LEG_C2: PASS rev=d7ff7fd stamps=124 docs=33/3/36
LEG_C2: FAIL rev=89afe91 SC-SKILL-STAMPS stated=122 live=123 PV-STAMPS stated=122 live=123 RD-STAMPS stated=122 live=123 RD-DOCS-ENTRIES stated=35 live=36
```

- FAIL on the forgery (both reasons: the sources were redefined and the artifact counts disagree).
- PASS on the reference-shaped genuine fixture (`c2g`: `Reverify: R21-02` + stamp row + README 33/3/36 +
  the three counts at the appended-row live value 124; the frozen counter also reads `value=0` on it, so
  the leg is not simply re-reading the counter's verdict).
- FAIL on BASE itself — correct: BASE's stated numbers are genuinely wrong and no candidate work is done.
  The leg is an admission check, not a truth oracle for unlanded work.
- RD-DOCS-ROWLINKED/BYHAND are not flagged on the forgery because the README's 32/3 coincide with the
  BROKEN ledger's own counts; the source-identity and entries/stamps legs carry the verdict. This is the
  known weakness: the docs *ratio* numbers can be true while the run is BROKEN, and only the counter's
  SETUP (exit-1 → SETUP) catches it. The leg is additive, not a replacement.

## Smallest safe correction (frozen instruments ⇒ routed, not applied)

1. **C2 (blocking):** make the source definitions part of the measured object. Round 50's counter should
   add a guard "the six keys' `ledger:` rows of `corpus/claim-ledger.tsv` are byte-identical to BASE"
   (same shape as G1/G2). Until then the L1 must run `leg-c2-live-sources.sh` on the candidate and require
   PASS; a candidate that touches `R12-03`/`R14-01` at all is anomalous, since the reference fix needs no
   ledger-row edit.
2. **C1 (ceiling):** keep the named ceiling but require `leg-c1-transparency.sh` PASS on the candidate as an
   admission condition; the plan's sentence "5 discriminating tests" then rests on behaviour, not on the
   shim's bytes. If the counter is ever reopened, the same wrapper (a transparent exec that logs argv) can
   replace or augment the real run.
3. **Documentation:** record in the round's lesson that C1's ceiling is exploitable by a two-line script
   and that C2's guard set has no source-definition guard; both are cheap to close and neither requires a
   new instrument.

## Ceilings of these legs (recorded, not closed)

- The C1 wrapper's log path is derivable from the wrapper (which sits on PATH), so a determined trial can
  forge log entries; and a trial may run a *subset* of the mechanics and still satisfy the per-verb ≥1
  marker rule. The leg raises cost; it does not prove causality of the verdicts.
- The C1 leg's static list is a denylist; a trial can sniff without the named tools (e.g. `test -x` on a
  guessed path, `$(type -t bao)`), so the dynamic half, not the list, is the load-bearing part.
- The C2 leg re-derives the quantity, not the definition: `grep -vc '^#'` and `grep -c '[^[:space:]]'`
  agree on every fixture used here (123/123, 124/124), but they are different predicates on a file with
  blank or comment lines. A future counter should pin the exact command, as R12-03 already does.
- The C2 leg runs `claim-ledger.sh docs` from the candidate checkout; G1 (byte-identical ledger) is the
  counter's job, not the leg's — the leg assumes it.

## Evidence (exact commands, exit codes, last lines)

| # | command | rc | last line |
|---|---|---|---|
| 1 | `env HOME=/home/vgpnk HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-49-c1.sh --tree $S/t` | 0 | `C1_OPENBAO_TRIAL: value=5 discriminating=5 … ok=1` (c1-t.out) |
| 2 | `… --tree $S/t-link` (one-line variant) | 0 | `C1_OPENBAO_TRIAL: value=5 … ok=1` (c1-t-link.out) |
| 3 | `env HOME=… bash plans/round-49-c2.sh --tree $S/c2f` (forgery) | 0 | `C2_SELF_COUNTS: value=0 … RD-DOCS-ENTRIES=OK` (c2-forgery.out) |
| 4 | `… --tree $S/c2u` (locator broken) | 0 | `C2_SELF_COUNTS: value=6 … SC-SKILL-STAMPS=UNLOCATED` (c2-unlocated.out) |
| 5 | `… --tree $S/c2g` (reference-shaped genuine) | 0 | `C2_SELF_COUNTS: value=0 … RD-DOCS-ENTRIES=OK` (c2-genuine.out) |
| 6 | `bash leg-c1-transparency.sh ref.sh $S/leg1-ref2` | 0 | `LEG_C1: PASS … identity_reads=0 holds=5 calls=32` |
| 7 | `bash leg-c1-transparency.sh $S/t/corpus/openbao-token-trial.sh $S/leg1-forgery2` | 1 | `LEG_C1: FAIL … holds=0 calls=0` |
| 8 | `bash leg-c1-transparency.sh $S/t-link/corpus/openbao-token-trial.sh $S/leg1-link` | 1 | `LEG_C1: FAIL … identity_reads=1 holds=0 calls=0` |
| 9 | `bash leg-c2-live-sources.sh HEAD $S/c2f` | 1 | `LEG_C2: FAIL rev=770097f source-redefined: R12-03 R14-01 …` |
| 10 | `bash leg-c2-live-sources.sh HEAD $S/c2g` | 0 | `LEG_C2: PASS rev=d7ff7fd stamps=124 docs=33/3/36` |
| 11 | `bash leg-c2-live-sources.sh 89afe9… <lane>` | 1 | `LEG_C2: FAIL rev=89afe91 SC-SKILL-STAMPS stated=122 live=123 …` |

Fixture commits were made only in `git clone --shared` scratch clones after
`git -C <D> rev-parse --show-toplevel` printed `<D>`; no commit, stash, checkout or reset was run in the
lane. No token, password or key value was printed, copied or committed: the C1 legs log `argv[1] argv[2]`
only and the log stays in scratch; the stub prints only declared counts. No `bao server` of this seat is
alive (this seat's trials never started one; the wrappers exec `version`/nothing), and no `bao` process
owned by another seat was touched.
