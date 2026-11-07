# R56ReviewCounter — predicate/code equivalence and false-green audit of the C1 counter

Seat: R56ReviewCounter (leaf, no subagent dispatch). Round 56, attempt-1 wave, lane kagi.
Scope: audit `plans/round-56-c1.sh` (the counter) against the frozen predicate, the real
production return code, the printer-gate defence, symlink/metadata setup, and no-work /
strict-population semantics. Scratch execution only; no production file was edited.
Observed answering model (harness context string, not inferred from the prompt):
`amr/deepseek-v4.1-flash`. No language-server device was mounted for this seat, so
caller/definition checks were done on exact bytes plus executed behaviour, not LSP.

## Instruments (exact bytes I audited)

| path | sha256 | bytes | revision |
|---|---|---|---|
| `plans/round-56-c1.sh` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | 12933 | `42070de` (working bytes equal: `git diff 42070de -- plans/round-56-c1.sh` empty) |
| `corpus/recheck-replay.py` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | 333 lines | `42070de` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | 16 lines | `42070de` |
| `plans/round-56-controls.sh` | `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094` | 104 lines | `42070de` |
| `plans/round-56.md` | `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07` | — | `42070de` |

BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`; predeclaration/freeze commit
`42070de7770e1558adcf6aa7a7bc59309a9654d7`; HEAD at audit time `42070de` (the working tree
matches the frozen blobs above; `git diff --stat 42070de -- <the five files>` empty, rc 0).
Frozen predicate text: `plans/round-56.md:15`; instrument header: `plans/round-56-c1.sh:4-43`.

**Revision note.** This audit applies to the five sha256s above at `42070de`. The planner seat
(`KagiR56a3`) was observed hardening the counter (digest pin, rc check, N boundary, symlink
gate) after this report's blocker message; if a new predeclaration commit lands, the counter
hash changes and every reading below must be re-run against the new bytes before it is used
as admission evidence.

## Verdict in one line

r1–r4 are a faithful implementation of the frozen predicate and the counts are real
(independent replay of all 10 clocks reproduces the stated N byte-for-byte);
**r5 is not a check of the gate — it is a check of ten strings on stdout**, so the
claim's landing artifact can be a 1.3 KB printer that reads nothing and still reads
`value=10 … guard=1`, and the control that was supposed to kill that class
(`K1-F5`) is vacuous because it hands a *bash* script to `python3`.

## Findings by severity

### F1 — HIGH — false-green printer gate: a gate that replays nothing scores `value=10 guard=1`

`plans/round-56-c1.sh:71` runs the measured tree's gate and **discards its exit status**
(`(cd "$SCR" && python3 -I -B "$T/corpus/recheck-replay.py" --root "$T" > "$GATE_OUT" 2>&1)`);
`:180-183` reduce the gate's output to "last non-empty line starts `RECHECK_REPLAY: CLEAN`";
`:220` accepts any earlier line matching the per-clock MATCH regex. Nothing binds the gate to
the tree, to the bodies, or to an off-tree read.

Scratch forgery (tree = reference tree with `corpus/recheck-replay.py` replaced by a printer
that reads no file and replays nothing; printer sha256
`11a79bc2718195684469cb998b3c64cd902ab248de2aa07db03d0d722a9b306b`, 1322 bytes):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../printer
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
rc=0
```

The same tree with the gate exiting 1 from its `--root` run (selftest rc 0; sha256
`ce970e0ae475af089e9f3c8dd79cee854198881e17f47f3d966d1cab6617b269`):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../printer_rc1
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
rc=0
```

And a printer that prints the ten MATCH lines and the CLEAN line and then raises
`ZeroDivisionError` (internal rc 1; traceback lands in `GATE_OUT` *before* the block-buffered
stdout flush, so CLEAN is still the last line; sha256
`a2279bb3b0aa8212d4eefda9e45fd1dbe460d5f66a2da8bfddce392cb3241185`):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../printercrash
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
rc=0
```

Consequence: REPLAYED's *counts* remain honest because r4 is the counter's own host replay
(`:160-176`), but the C1 sentence this round claims to demonstrate — "a lane gate that replays
every stated clock" — is not established by C1. The capability can land as a printer.
Fix before any re-freeze: bind the gate, not its text — (a) pin `corpus/recheck-replay.py`'s
sha256 in the predicate and require the measured file to match, **and** require the `--root`
run to exit 0 with the summary `clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0
unsupported=0 tool=0` cross-checked against POP; or (b) drop r5 from REPLAYED and score the
counter's own r4 replay as the capability, testing the gate separately.

### F2 — HIGH — the `K1-F5` "printer gate" control never executes a printer

`plans/round-56-controls.sh` F5 writes a **bash** script into `corpus/recheck-replay.py`, but
the counter runs that path with `python3` (`plans/round-56-c1.sh:71,73`). Reproduced with the
exact F5 construction (sha256 `578805c698cc4ccf6d99c872cdfad05938a65dcb6435185995d5bad3479e5dff`):

```
$ cd $scratch && python3 -I -B f5bash/corpus/recheck-replay.py --root f5bash
  File "…/corpus/recheck-replay.py", line 2
    case "${1:-}" in --selftest) echo …
SyntaxError: unmatched ')'
gate_run_rc=1
$ … --selftest        # same SyntaxError
selftest_rc=1
```

so the counter's `K1-F5` reading (`value=FAIL … gate=0 guard=0`,
`bad=…,r5-gate:<all ten>,selftest`, receipt `.ufo/waves/round-56/controls/controls-prefreeze.txt`
line `CONTROL K1-F5-printer-gate`) is produced by a parse error, not by a printer. The receipt's
`CONTROLS: match=12 mismatch=0` therefore overstates the battery: eleven controls test what
they name; F5 tests "a non-Python file at the gate path". A Python printer passes (F1).
Fix: express F5 as a `python3` printer; under the current predicate that control's correct
expectation is `got=10`, which is the defect F1 describes — so F1 must be fixed first, then
F5 should expect FAIL for a printer that does not match the pinned digest.

### F3 — MEDIUM — `present()` accepts a restated N with a trailing non-digit (`-> 1x`)

Predicate (`plans/round-56.md:15`, r1): the line must carry the BASE command "followed by
`-> N` / `-> count=N` with c's BASE N". Code (`plans/round-56-c1.sh:123`) uses
`… \s*->\s*(?:count=)?%d(?!\d)`; `(?!\d)` only blocks a further digit. Scratch tree `nx` with
`corpus/knowledge/betterleaks-detection-vs-validation.md:4` edited to end
``… by default'` -> 1x (ran 2026-10-23)`` (exact bytes, one character added):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../nx
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
rc=0
```

The gate's own `CLOCK_RE` (`corpus/recheck-replay.py:53`) also reads `1x` as 1, so both
instruments agree on a restatement that is not `-> N`. Low practical exploitability (a restated
clock is written to be read by humans), but it is a real predicate/code divergence.
Fix: right-boundary the number (`(?![0-9A-Za-z_.])`).

### F4 — MEDIUM — one added uncaptured clock anywhere in `corpus/knowledge/*.md` zeroes all ten

r5's CLEAN is a whole-tree property (`:183`), so a clock that is not in POP vetoes every POP
clock. Scratch tree `extra` adds to `corpus/knowledge/prefreeze-controls.md:3`
``recheck: on-change — `curl -fsSL https://example.invalid/x | grep -c needle` -> 1; bash …``:

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../extra
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate:<all ten>)
rc=0
```

Same mechanism in the receipt's `K1-F8` (`value=0`) and, with a capture-side defect, in
`K1-F4`/`K1-F3`. This is consistent with the frozen sentence but it is a sharp scoring cliff:
if the candidate edits any knowledge clock without adding its capture row, the claim reads 0
although all ten POP clocks replay, and the failure message blames `r5-gate` for every clock
rather than naming the offending clock. Note also that the frozen commit itself already reads
the target (`bash plans/round-56-c1.sh 42070de…` ⇒ `value=10 … guard=1`, rc 0), so the only
way the candidate can move the reading is by touching the five files or a knowledge clock.
Fix (needs re-freeze): make r5 per-clock and add a separate whole-tree conjunct with an
explicit `clocks=` equality, so a new clock is reported as population drift, not as ten
r5 failures.

### F5 — MEDIUM — GUARD's selftest conjunct is self-attested by the candidate and case count is unchecked

`:73-76` accept any `--selftest` that exits 0 and whose last line starts
`RECHECK_REPLAY_SELFTEST: PASS`; the plan claims "a `--selftest` of 13 cases" (`plans/round-56.md:13`).
Scratch tree `selfstub` = the real gate with `selftest()` replaced by
`print("RECHECK_REPLAY_SELFTEST: PASS (0 cases)"); return 0`
(sha256 `36726257e8fac3a0c01293ce4235bbf1fc17bdd7ebc1c23f8c6c7eeae921a5c7`):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../selfstub
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
rc=0
```

A 0-case selftest and the real 13-case one are indistinguishable to the counter. Combined with
F1 this is why the guard cannot vouch for the gate.
Fix: same digest pin as F1, or require the literal `(13 cases)` token in the selftest line.

### F6 — MEDIUM — the gate's population is fail-open on symlinked knowledge entries

`corpus/recheck-replay.py:67` (`if path.is_symlink(): continue`) drops a symlinked
`corpus/knowledge/*.md` from the population with no diagnostic. Scratch tree `symentry`
(trufflehog entry replaced by a symlink; the counter already rejects this shape, receipt
`K1-F10`):

```
$ python3 -I -B symentry/corpus/recheck-replay.py --root symentry | tail -1
RECHECK_REPLAY: CLEAN (clocks=9 match=9 mismatch=0 no_capture=0 unsupported=0 tool=0)
rc=0
```

C1 is safe (r1's `read()` at `:100-112` rejects any symlinked component, so `present` drops and
the counter reads `value=FAIL present=9`), but the landing artifact's stated contract —
"Population: every backticked command on a column-1 `recheck:` line of `corpus/knowledge/*.md`"
(`corpus/recheck-replay.py:9-11`) — is violated by its own code, and the summary reports CLEAN.
Fix: count a symlinked entry as BAD/UNSUPPORTED (fail the gate), never skip silently.

### F7 — MEDIUM — the gate path is not symlink-confined, and "offline" is never tested

`plans/round-56-c1.sh:69` uses `[ -e … ]` (follows symlinks) and then executes the path; the
counter's own confinement check (`:105`, `:206`) covers entries/bodies, not the gate. Scratch
tree `symgate` (`corpus/recheck-replay.py` → the external printer file):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../symgate
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
rc=0
```

So the "measured tree's own" gate can be an arbitrary off-tree file, and the counter cannot
distinguish an offline gate from one that re-fetches the URL live (no network isolation, no
syscall/`strace` check). The counts are still bound by r4, but the *offline* half of the claim
is code-review-only.
Fix: reject a symlinked gate component; state explicitly that offline-ness is a reviewed
property, not a counter-tested one.

### F8 — LOW — counter and gate disagree on a malformed manifest (counter drops the row)

`plans/round-56-c1.sh:156` (`if len(cols) == 7`) silently drops a manifest data row that does
not have 7 columns, while `corpus/recheck-replay.py:131-133` treats the same tree as
`SETUP manifest-columns:…`. Scratch `m8` (the S054 row plus one extra column):

```
$ bash plans/round-56-c1.sh --tree /fast/scratch/.../m8
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=…,r2-rows0:secret-scanning-…,r5-gate:…)
rc=0
```

The predicate says the manifest "has exactly one data row whose url column equals c's URL";
a row with the wrong arity is not "no row". The reading is fail-closed, but the counter's
diagnosis is wrong and the two instruments disagree on the same tree. Fix: treat a non-7-column
data row as a manifest-invalid (all r2 conjuncts 0) with a named reason.

### F9 — LOW — the counter's own exit code does not encode the reading

`plans/round-56-c1.sh` exits 0 for `value=FAIL` and for `value=0`; only SETUP exits 2
(measured: BASE rc 0 with `value=0`; empty tree rc 0 with `value=FAIL`; bad revision rc 2;
no revision rc 2). The controls compare the value token (`pick()`), so the battery is
unaffected, but any admission harness that tests rc alone would read a miss as a pass.
No code change required by the frozen predicate; the admission must parse
`C1_REPLAY: value=<tok>` and require `value=10`, `guard=1` (and, for hygiene, `present=10`).

### F10 — LOW — the counter is not relocatable; it reads BASE's normaliser from the repo that contains it

`:65` (`git -C "$REPO" show "$BASE:corpus/rendered-text-v1.py"`, `REPO=$(cd "$(dirname "$0")/.." …)`)
means the instrument needs a git repo containing BASE regardless of `--tree`. A lone copy —
`/fast/scratch/.../notree/plans/round-56-c1.sh --tree ref` — reads
`C1_REPLAY: SETUP base-normaliser`, rc 2. This is declared in the predicate ("taken from BASE,
not from the measured tree"), so it is a dependency to state for closure re-runs, not a defect;
but it is a hidden read of the lane repo that a clean-clone verifier must satisfy.

### F11 — LOW — remaining lenience and PATH trust

* `registry()` (`:136-138`) accepts up to three leading spaces on a registry row
  (`^ {0,3}\|\s*(S\d{3,})\s*\|`) — a superset of "registry row" for `corpus/SOURCES.md`, whose
  rows are column 1. No current data exploits it.
* r4's replay trusts PATH-resolved `grep`, `pdftotext`, `python3` and `sys.executable`
  (`:160-176`); a PATH shim can forge counts. The predicate says "host grep/pdftotext", so this
  is a declared ceiling, not a divergence — but it is the weakest link in r4.
* The manifest `http_status` and `fetched` columns are never checked by the predicate or the
  code; a row with `http_status=404` and a matching body would score (named-ceiling territory;
  all ten current bodies are real content — see below).

## What is sound (verified, not asserted)

Independent of the gate and of the counter's POP literal, I re-derived the population from
BASE and replayed every clock on the manifest body (script run from scratch, host `grep`,
`pdftotext -layout`, BASE's `rendered-text-v1.py locate`):

* Population at BASE: exactly **10 clocks in 8 entries**, forms grep 8 / pdf 1 / locate 1 —
  `aliyun`, `feature-bound`, `feed-token`, `onepassword`, `openbao`, `prefreeze`, `sops`,
  `vault-openbao` carry recheck lines with no curl clock and are correctly outside POP. The
  POP literal in `plans/round-56-c1.sh:88-99` matches BASE byte-for-byte (commands, URLs,
  patterns, N) and lists the same ten.
* Replayed counts (stated == measured): 1,1,2,3,2,1,1,1,1,1 for
  S055,S070,S101,S113,S114,S074,S078,S067,S054,S057. Every manifest row's `bytes` and
  `sha256` equal the file on disk; no body begins `HTTP/`; no body carries a `set-cookie:` line.
* r2's registry layout is right: `corpus/SOURCES.md:5` header has 11 columns, status is
  index 7 (`mined`), URL is a whitespace token in the source cell (index 1).
* Readings: BASE `value=0 present=10 replayed=0 gate=0 guard=1` rc 0 (matches receipt
  `K1-BASE`); reference tree `value=10 present=10 replayed=10 gate=1 guard=1` rc 0 (matches
  `K1-REF`); frozen commit `42070de…` `value=10 … guard=1` rc 0.
* Fail-closed shapes behave: no args / bad revision / missing tree ⇒ SETUP rc 2; empty tree ⇒
  `value=FAIL present=0 guard=0` rc 0; gate without manifest ⇒ `value=0 … guard=1`; no
  knowledge ⇒ `value=FAIL … guard=0`; duplicate manifest URL ⇒ `r2-rows2` plus gate veto;
  symlinked body/entry ⇒ `r3-file`/`absent` (receipt `K1-F6`, `K1-F10`).

## Residual risk

1. Named ceilings stand: a hand-written capture with a self-consistent manifest row scores;
   a true but non-discriminating pattern scores; the live run is the currency check. C1 is an
   offline replay, not a freshness proof.
2. F1's printer false green does not let a wrong count score (r4 is real), but it does let the
   claimed gate land as a stub; the round's capability sentence is therefore only as strong as
   the digest pin it does not have.
3. F4 is the main candidate-side hazard: any knowledge-clock edit without a capture row turns
   `value=10` into `value=0`, and the reading cannot distinguish that from ten real
   regressions.
4. PATH shims (F11) and the unconfined gate (F7) are outside the counter's trust boundary.

## Verification gaps

* I did not run `plans/round-56-controls.sh` end-to-end; I reproduced `K1-BASE`/`K1-REF`
  independently and reproduced the `K1-F5` mechanism exactly (bash script executed by
  `python3` ⇒ SyntaxError). The receipt itself is intact (18 lines, `CONTROLS: match=12
  mismatch=0`).
* No live re-fetch (separate seat R56ExecLive); no network used by this seat.
* I did not audit `corpus/recheck-replay.py` line-by-line beyond its interaction with r5
  (population, manifest, capture, replay, summary); that is the separate gate-audit seat.
* Scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewCounter/` — my artifacts (reference tree,
  printer, printer_rc1, printercrash, selfstub, symgate, nx, extra, nomani, noknow, dup, m8,
  empty, notree, scratch/) were deleted before this report; the forged bytes and raw outputs
  are preserved in `R56ReviewCounter.d/evidence.txt`. Two live directories remain under that
  path — `kagi-r56/controls.2641942/` and `kagi-r56/c1.2846297/` (07:35) — created by the
  concurrently running duplicate seat `R56ReviewCounter-2`, which derives the same scratch
  path; I did not delete another seat's live temp.

## Report trailer

- report: `.ufo/waves/round-56/build/R56ReviewCounter.md`
- evidence: `.ufo/waves/round-56/build/R56ReviewCounter.d/evidence.txt`
- no production file edited; no git/jj mutation; no tool installed (none needed).
