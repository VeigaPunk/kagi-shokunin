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

**Revision note.** The audit below is anchored to epoch A (`42070de`, counter
`096251c9…`); the planner seat re-froze as **epoch B** at
`5d9a1571911ec38a456a40b443e19640abb9a88b`, **epoch C** at
`711e6393e68658f396918c07de253e5a5c74d1b4`, **epoch D** at
`d36231871c864c930d3e7e33f9c5345b30ab4f98`, and **epoch E** at
`dd31b7867723f89fc8f83e88cc7d98e17de26cf2`, after blocker messages from this seat. Each
re-audit re-runs every forgery against the hardened bytes: the four `## Epoch … re-audit`
sections at the end of this report. Epoch-A findings F1, F2, F3, F5, F6, F7 and F8 are closed
in epoch B; epoch-B residuals E1, E2, E5 and E6 in epoch C; epoch-C items G1 and G2 in epoch D;
epoch-D H1 in epoch E. F4/E3 (population hard-closed at 10), F9 (rc 0 on FAIL), F10
(relocatability), F11 (PATH trust), H2 (the gate alone reads `-> 1.0` as `-> 1`) and epoch-E
I1 (control F15 does not exercise the bijection) stand.

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
- evidence epoch A: `.ufo/waves/round-56/build/R56ReviewCounter.d/evidence.txt`
- evidence epoch B: `.ufo/waves/round-56/build/R56ReviewCounter.d/evidence-epochB.txt`
- no production file edited; no git/jj mutation; no tool installed (none needed).

## Epoch B re-audit (5d9a157)

Anchored to `5d9a1571911ec38a456a40b443e19640abb9a88b` (HEAD at the re-audit; kill-rule
predeclaration). Instruments:

| path | sha256 at 5d9a157 |
|---|---|
| `plans/round-56-c1.sh` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` |
| `corpus/recheck-replay.py` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` (= `GATE_SHA256_PIN` in the counter) |
| `plans/round-56-controls.sh` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` |
| `plans/round-56.md` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` (unchanged) |

Every run is `bash plans/round-56-c1.sh …` from the lane; raw output in
`R56ReviewCounter.d/evidence-epochB.txt`.

| tree | reading | rc |
|---|---|---|
| BASE `832ba6a` | `value=0 present=10 replayed=0 gate=0 guard=1` (r2-manifest ×10) | 0 |
| epoch-A `42070de` | `value=0 … gate=0` (r5-gate ×10 — gate digest) | 0 |
| epoch-B `5d9a157` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| reference overlay (lane `git ls-files -co`) | `value=10 … guard=1` | 0 |
| python printer gate (reads nothing; 10 MATCH + CLEAN + `PASS (13 cases)`) | `value=0 … gate=0` (r5-gate ×10) | 0 |
| pinned gate + 0-case selftest | `value=0 … gate=0` (digest, not selftest) | 0 |
| `-> 1x` restatement | `value=FAIL present=9 replayed=9 guard=0` (absent) | 0 |
| added uncaptured clock | `value=0 … gate=0` | 0 |
| added **captured** clock (gate `CLEAN (clocks=11 match=11 …)`) | `value=0 … gate=0` | 0 |
| gate path symlinked to an off-tree printer | `value=0 … gate=0` | 0 |
| 8-column manifest row | `value=0 … r2-manifest-malformed ×10` | 0 |
| duplicate URL row | `value=0 … r2-rows2 + r5-gate` | 0 |
| no manifest | `value=0 … r2-manifest ×10` | 0 |
| empty tree | `value=FAIL present=0 guard=0` | 0 |
| symlinked knowledge entry | `value=FAIL present=9 replayed=0 guard=0`; gate: `UNSUPPORTED … reason=symlinked-entry`, `DRIFT (clocks=10 match=9 … unsupported=1)` | 0 |
| no args / bad revision / missing tree / lone copy | `SETUP no-revision` / `bad-revision` / `tree` / `base-normaliser` | 2 |

Controls battery end-to-end (`bash plans/round-56-controls.sh <lane>`, REF = lane working
tree): `CONTROLS: match=16 mismatch=0`, rc 0 — reproduces the epoch-B 16/16 receipt.

Closed against epoch A: **F1** (digest pin: printer → 0), **F2** (F5 is now a real `python3`
printer; F5b/F5c added), **F3** (`-> 1x` → `FAIL present=9`), **F5** (digest subsumes the
selftest; exact `PASS (13 cases)`), **F6** (symlinked entry → `UNSUPPORTED`, gate DRIFT),
**F7** (gate symlink → `GATE_SHA=SYMLINK`, 0), **F8** (manifest arity → `r2-manifest-malformed`).
Still standing: F4 (now explicit, E3), F9, F10, F11.

### E1 — MEDIUM — the frozen predicate sentence, the counter header and the code state three different GUARD conditions

`plans/round-56.md:15` says: "GUARD = 1 iff all 10 clocks are PRESENT … **and the gate's
`--selftest` exits 0 with last line `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`**" — no
condition on the gate's presence or digest. The counter header (`plans/round-56-c1.sh:38-41`)
conditions it on the file's *presence* ("when the measured tree carries
corpus/recheck-replay.py"). The code conditions it on the *digest match*
(`GATE_SHA = GATE_SHA256_PIN`): `SELF_OK` is only computed inside that branch, and stays 1
otherwise. Measured consequences:
* BASE (no gate): code `guard=1` → `value=0`; the plan-literal sentence would require a
  selftest that does not exist → `guard=0` → `value=FAIL`, contradicting the plan's own
  BASE-0 target.
* printer gate (present, unpinned): code `guard=1` → `value=0`; the header-literal sentence
  (presence) would run the printer's selftest → `guard=0` → `value=FAIL`.

The plan claims "Definitions verbatim in `plans/round-56-c1.sh`'s header", which is not the
case for this conjunct. Admission is unaffected (all readings are misses), but for a lane
whose protocol is text-equals-code this is a real divergence. Fix: write the same condition in
all three places — "when the tree's `corpus/recheck-replay.py` bytes equal `GATE_SHA256_PIN`,
its `--selftest` exits 0 with last line `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`".

### E2 — LOW — the F5 control comment contradicts its own expectation

`plans/round-56-controls.sh` F5's comment says "…this must read FAIL (digest mismatch ->
gate_ok=0 -> every r5 fails)"; the table line is `check K1-F5-printer-gate 0 f5` and the
measured reading is `value=0 guard=1`. "Every r5 fails" with `guard=1` yields `0`, not `FAIL`.
The comment's word FAIL is wrong; the expectation is right for the code.

### E3 — MEDIUM (design ceiling, now explicit) — the population is hard-closed at 10 clocks

An added clock that is fully captured and MATCHing produces `RECHECK_REPLAY: CLEAN
(clocks=11 match=11 mismatch=0 …)` and the counter's exact regex requires `clocks=10`, so the
reading is `value=0` (measured `extracap`). Any future round that legitimately grows
`corpus/knowledge`'s stated-clock population must re-freeze the counter (POP literal, clock
count, pin) — the reading cannot represent growth, and a correct extra clock is indistinguishable
from a regression by the value alone. This is intended by the epoch-B predicate; it should be
listed in the plan's named ceilings.

### E4 — LOW — `sha256sum` joins the PATH trust set

`GATE_SHA=$(sha256sum "$T/$GATE_REL" | cut -d' ' -f1)` resolves `sha256sum` from PATH, so the
pin is only as good as that binary (r4 already trusts PATH `grep`/`pdftotext`/`python3`). Same
declared host-trust ceiling; no new exposure by itself.

### E5 — LOW — the gate's locate replay reads the tree's normaliser, not the pinned BASE copy

The gate now confines `corpus/rendered-text-v1.py` for symlinks but does not pin its bytes,
while the counter's r4 uses BASE's copy. A candidate editing the tree normaliser can make the
gate's locate line wrong; r4 (BASE) then fails that clock, so the value can only fall — no
false green observed, but the gate's own evidence for the locate form is not bound to the
counter's.

### E6 — LOW — the controls' `mk_ref` silently tolerates a partial reference tree

`mk_ref` pipes `git ls-files -co --exclude-standard | tar -cf -` into `tar -x` with `set -u`
only — no `pipefail`, no rc check. In this re-audit a concurrently moving sibling file made
`tar` fail twice ("Cannot stat … Exiting with failure status due to previous errors") and the
battery continued on the partial tree; because the vanished files were sibling reports the
16/16 result is still valid, but a capture or the gate vanishing the same way would yield a
spurious reading with no diagnostic. Add `|| exit 2` / `set -o pipefail` on the copy.

### Verified good in epoch B (new)

* Python 3.14.8 `-I` removes the script directory from `sys.path` (probe: a sibling module is
  importable without `-I` and `ModuleNotFoundError` with it; `sys.path[0]` is the stdlib zip),
  so a tree-local stdlib shadow (e.g. `corpus/subprocess.py`) cannot influence the pinned
  gate's replay.
* The digest pin, the `--root` rc check, the exact CLEAN summary and the exact selftest line
  all fire together: a one-byte gate edit (control F9), a symlinked gate (F5c), a printer (F5)
  and an edited body all read 0, not 10.

## Epoch B trailer

- report: `.ufo/waves/round-56/build/R56ReviewCounter.md`
- evidence epoch A: `.ufo/waves/round-56/build/R56ReviewCounter.d/evidence.txt`
- evidence epoch B: `.ufo/waves/round-56/build/R56ReviewCounter.d/evidence-epochB.txt`
- epoch-B scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewCounter/epochB/` deleted after this
  report; no production file edited; no git/jj mutation; no tool installed.

## Epoch C re-audit (711e6393)

Anchored to `711e6393e68658f396918c07de253e5a5c74d1b4` (HEAD; epoch-C kill-rule
predeclaration). Instruments:

| path | sha256 at 711e6393 |
|---|---|
| `plans/round-56-c1.sh` | `7992ee6a97c9f1cfaf627c61322ecaf6aa0c31126a65f591567d7b6f7ee2802c` |
| `corpus/recheck-replay.py` | `e9b7e4b7aa1e8173c4bfc2e536ce6d1ed29c4c0d6ee5f46bfa1e63d3692a62b4` (= `GATE_SHA256_PIN`) |
| `plans/round-56-controls.sh` | `b675baa5fad95bc663f49ca76ea13be84627db457af443f3b957144cd8ddd16c` |
| `plans/round-56.md` | `8beb24e94a08c3961f5217a3b4b98aadc46d56561fe3ec2254f13185d4cf6c9f` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` (= `NORMALIZER_SHA256_PIN`, and equal to BASE's copy) |

Raw output: `R56ReviewCounter.d/evidence-epochC.txt`.

| tree / forgery | reading | rc |
|---|---|---|
| BASE `832ba6a` | `value=0 present=10 replayed=0 gate=0 guard=1` | 0 |
| epoch-A `42070de` | `value=FAIL … guard=0 (…selftest,gate-digest)` | 0 |
| epoch-B `5d9a157` | `value=FAIL … guard=0 (…selftest,gate-digest)` | 0 |
| epoch-C `711e6393` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| reference overlay | `value=10 … guard=1` | 0 |
| printer gate (pinned-selftest text, reads nothing) | `value=FAIL … guard=0 (…selftest,gate-digest)` | 0 |
| pinned gate + 0-case selftest | `value=FAIL … guard=0 (…selftest,gate-digest)` | 0 |
| `-> 1x` restatement | `value=FAIL present=9 replayed=9 guard=0` | 0 |
| `-> 1.0` restatement | **`value=10 … guard=1`** | 0 |
| added uncaptured clock | `value=0 … guard=1` | 0 |
| added captured clock (gate `CLEAN (clocks=11 match=11 …)`) | `value=0 … guard=1` | 0 |
| gate path symlink | `value=FAIL … guard=0 (…selftest)` | 0 |
| gate path FIFO | `value=FAIL … guard=0 (…selftest)`; returns, no block | 0 |
| 8-column manifest row | `value=0 … r2-manifest-malformed ×10` | 0 |
| `fetched=2026-11-7` | `value=0 … r2-manifest-malformed ×10` | 0 |
| `http_status=404` | `value=0 … r2-manifest-malformed ×10` | 0 |
| two rows sharing body_path+sha256 | `value=0 … r2-manifest-malformed ×10` | 0 |
| duplicate URL row | `value=0 … r2-manifest-malformed ×10` | 0 |
| body_path `corpus/S054.body` (not `capture*`) | `value=0 … r3-notcapture:…` | 0 |
| `set-cookie: x=1` at column 0 | `value=0 … r3-headers:…`; gate `BAD-CAPTURE` | 0 |
| **`Set-Cookie: session=abc` at column 0** | **`value=10 … guard=1`; gate `CLEAN (clocks=10 match=10 …)`** | 0 |
| `< HTTP/1.1 200 OK` at column 0 | `value=0 … r3-headers:…`; gate `BAD-CAPTURE` | 0 |
| normaliser bytes edited (comment appended) | `value=FAIL … guard=0 (…selftest)` (gate `SETUP normalizer-digest`) | 0 |
| symlinked knowledge entry | `value=FAIL present=9 guard=0` | 0 |
| no manifest / empty tree / SETUP shapes | `value=0` / `value=FAIL present=0` / `SETUP …` | 0/0/2 |

Controls battery end-to-end (`bash plans/round-56-controls.sh <lane>`, REF = lane): six
`INSTRUMENT <sha256> <path>` lines including the normaliser pin, `CONTROLS: match=20
mismatch=0`, rc 0, **0 tar errors**. Gate `--selftest`: `PASS (18 cases)`.

Closed against epoch B: **E1** (a present-but-unpinned gate now sets `SELF_OK=0`, so the
printer reads `FAIL guard=0` — plan:15, header and code now state the same condition),
**E2** (F5/F5b/F5c/F9 expect FAIL and read FAIL), **E5** (normaliser pinned; an edited
normaliser reads FAIL), **E6** (controls `set -o pipefail`, race-tolerant `mk_ref`, INSTRUMENT
lines; 0 tar errors). F9 (counter rc 0 on FAIL), F10 (BASE normaliser read from the script's
repo) and F11 (PATH-trusted `grep`/`pdftotext`/`python3`, now also `sha256sum`) stand.

### G1 — MEDIUM — the QM72 header refusal is case-sensitive; `Set-Cookie:` at column 0 scores 10

Both the gate (`corpus/recheck-replay.py`, `re.search(rb"(?m)^(?:HTTP/\d|< HTTP/\d|…|set-cookie\s*:)", data)`) and the counter's r3 use `(?m)` without `(?i)`. Measured: a body prefixed
with `Set-Cookie: session=abc\n` (bytes+sha updated in the manifest) gives
`C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` and the gate itself
prints `RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)`, while the lowercase form is refused
(`value=0 … r3-headers:…`, gate `BAD-CAPTURE`). The gate's own docstring names the capitalised
form — "carries a `Set-Cookie:` header line is refused (QM72)" (`corpus/recheck-replay.py:26-27`)
— so code and docstring disagree; the epoch-B predicate said "(any case)" and the epoch-C plan
text dropped that qualifier. HTTP header names are case-insensitive (RFC 9110 §5.1), so a
server's real `Set-Cookie:` output is exactly the casing that now passes. Realistic coverage is
partial (a `curl -i` transcript still starts with an `HTTP/` status line, which is refused), but
a header block without the status line — or a header line lifted into a body — is no longer
refused as documented.
Fix: add `(?i)` to the `set-cookie` alternatives (the column-0 anchor already keeps S067's
indented examples safe), in both the gate and the counter's r3, and restore "(any case)" to the
plan sentence.

### G2 — LOW — `-> 1.0` satisfies PRESENT and scores 10

The boundary `%d(?![0-9A-Za-z])` (counter `present()`) and the plan's "right-bounded by a
non-digit non-letter" both accept `-> 1.0`, because `.` is neither a digit nor a letter; the
gate's `CLOCK_RE` then reads N = 1 and MATCHes. Measured: `value=10 present=10 replayed=10
gate=1 guard=1` with the betterleaks clock restated as ``… -> 1.0 (ran 2026-10-23)``. The code
matches the epoch-C text, so this is a wording looseness rather than a code/predicate
divergence; the epoch-B code's `(?![0-9A-Za-z_.])` would have refused it. A restated N that is
still numerically stale cannot gain (r4 still compares counts), so the impact is limited to
malformed restatements reading as PRESENT.
Fix: "followed by `-> N` where N is not followed by a digit, letter, `_` or `.`" in the plan
and `(?![0-9A-Za-z_.])` in the code.

### Epoch C trailer

- report: `.ufo/waves/round-56/build/R56ReviewCounter.md`
- evidence A/B/C: `R56ReviewCounter.d/evidence{,-epochB,-epochC}.txt`
- epoch-C scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewCounter/epochC/` deleted after this
  report; no production file edited; no git/jj mutation; no tool installed.
- The C1 reading on an unchanged `711e6393` tree is **`value=10 present=10 replayed=10
  gate=1 guard=1`, rc 0**; the candidate must not add a stated knowledge clock (E3), must not
  edit the gate/normaliser (pin), and the reading is the printed value, not the exit code (F9).

## Epoch D re-audit (d362318)

Anchored to `d36231871c864c930d3e7e33f9c5345b30ab4f98` (HEAD; epoch-D kill-rule
predeclaration). Instruments:

| path | sha256 at d362318 |
|---|---|
| `plans/round-56-c1.sh` | `82acbb2056aac6055a79f223a0e0abbb2cb24f11f01ca5ed12a230c8338bdc6a` |
| `corpus/recheck-replay.py` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` (= `GATE_SHA256_PIN`) |
| `plans/round-56-controls.sh` | `9445a1ec208f2b8dad55da2694f4b7ebd2554e3ecd4196f15c5d5da4958882ce` |
| `plans/round-56.md` | `4d837eb2d467064efedb9e25173c5bde82830e88c31754d7af1ac253c87b8b74` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` (= `NORMALIZER_SHA256_PIN`) |

Raw output: `R56ReviewCounter.d/evidence-epochD.txt`.

| tree / forgery | reading | rc |
|---|---|---|
| BASE `832ba6a` | `value=0 present=10 replayed=0 gate=0 guard=1` | 0 |
| `42070de` / `5d9a157` / `711e6393` | `value=FAIL … guard=0 (…selftest,gate-digest)` | 0 |
| epoch-D `d362318` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| reference overlay | `value=10 … guard=1` | 0 |
| printer gate (pinned-selftest text, reads nothing) | `value=FAIL … guard=0` | 0 |
| `-> 1x` / `-> 1.0` / `-> 1_0` restatements | `value=FAIL present=9 replayed=9 guard=0` each | 0 |
| added uncaptured clock / added captured clock (`clocks=11`) | `value=0 … guard=1` each | 0 |
| gate symlink / gate FIFO | `value=FAIL … guard=0 (…selftest)` | 0 |
| 8-column / `fetched=2026-11-7` / `http_status=404` / shared body_path+sha / duplicate URL | `value=0 … r2-manifest-malformed ×10` | 0 |
| body_path `corpus/S054.body` | `value=0 … r3-notcapture:…` | 0 |
| `set-cookie:` / `Set-Cookie:` / `Http/2 302` / `< Set-Cookie:` / `< HTTP/1.1` at column 0 | `value=0 … r3-headers:…` each (gate: `DRIFT … bad_capture=1`) | 0 |
| normaliser edited / symlinked entry / empty tree | `value=FAIL … guard=0` | 0 |
| no manifest / SETUP shapes | `value=0` / `SETUP …` | 0 / 2 |

Controls end-to-end (`bash plans/round-56-controls.sh <lane>`, REF = lane): six `INSTRUMENT`
lines including the normaliser pin, `CONTROLS: match=21 mismatch=0`, rc 0, 0 tar errors. Gate
`--selftest`: `PASS (20 cases)`.

Closed against epoch C: **G1** (all four canonical casings/prefixes now refused by gate and
counter; the gate's selftest adds `header-case-cookie` and `header-case-status`), **G2**
(`-> 1.0` and `-> 1_0` fail PRESENT). All epoch-A/B residuals remain closed; F9, F10, F11 and
E3 (population hard-closed at 10) stand.

### H1 — MEDIUM — the frozen predicate still says `PASS (18 cases)`; the instrument requires 20

`plans/round-56.md:15` ends "…its `--selftest` exits 0 with last line `RECHECK_REPLAY_SELFTEST:
PASS (18 cases)`. Definitions verbatim in `plans/round-56-c1.sh`'s header." The counter header
(`:44`, `:83`) and the code (`:110`) require **`PASS (20 cases)`**, and the same plan's Landing
sentence (`plans/round-56.md:13`) says "a `--selftest` of 20 cases". So the frozen predicate
contradicts both the instrument and its own landing text, and the "verbatim" claim is false for
this token. No reading impact (the code is authoritative and the unchanged tree reads 10), but
a closure that checks the predicate text would look for an 18-case line the instrument can
never emit.
Fix: one-line plan amendment (line 15: 18 → 20). That touches `plans/round-56.md`, which is in
the kill-rule pathspec, so it needs a new predeclaration commit (epoch E) — no instrument hash
changes, since the counter/gate/controls/normaliser are unaffected.

### H2 — LOW — the gate alone still reads `-> 1.0` as `-> 1` (counter refuses, gate says CLEAN)

The gate's `CLOCK_RE` (`corpus/recheck-replay.py:53`) captures the digit prefix, so a clock
restated as ``… -> 1.0 (ran …)`` yields `RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)` from the
gate on its own, while the counter's r1 boundary (`(?![0-9A-Za-z_.])`) refuses it and the
reading is `value=FAIL present=9`. The counter dominates, so no false green; the asymmetry is
that the landing artifact's own replay does not apply the boundary its predicate states.
Fix (optional): give `CLOCK_RE` the same right boundary so the gate's population matches r1's.

### Epoch D trailer

- report: `.ufo/waves/round-56/build/R56ReviewCounter.md`
- evidence A/B/C/D: `R56ReviewCounter.d/evidence{,-epochB,-epochC,-epochD}.txt`
- epoch-D scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewCounter/epochD/` deleted after this
  report; no production file edited; no git/jj mutation; no tool installed.
- C1 on an unchanged `d362318` tree: **`value=10 present=10 replayed=10 gate=1 guard=1`, rc 0**.
  The admission harness must read that token (rc is 0 even on FAIL), the candidate must not add
  a stated knowledge clock (E3), and it must not edit the gate or the normaliser (pins).

## Epoch E re-audit (dd31b786)

Anchored to `dd31b7867723f89fc8f83e88cc7d98e17de26cf2` (HEAD; epoch-E kill-rule
predeclaration). Instruments:

| path | sha256 at dd31b786 |
|---|---|
| `plans/round-56-c1.sh` | `d468533fbf593c4b2a3a97dc513b9feb2cff765892c126c02d7c6ef40273a954` |
| `corpus/recheck-replay.py` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` (= `GATE_SHA256_PIN`, unchanged from D) |
| `plans/round-56-controls.sh` | `01060f254b2ecfdb23f341a5cf0937aec32243230560809403ed67ea38b196e7` |
| `plans/round-56.md` | `212e2dd7ae71e3f056111e1a2c59d33151a3c51fee9f932bf2209ad2cb3d805d` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` (= `NORMALIZER_SHA256_PIN`) |

Raw output: `R56ReviewCounter.d/evidence-epochE.txt`.

| tree / forgery | reading | rc |
|---|---|---|
| BASE `832ba6a` | `value=0 present=10 replayed=0 gate=0 guard=1` | 0 |
| `42070de` / `5d9a157` / `711e6393` | `value=FAIL … guard=0 (…selftest,gate-digest)` | 0 |
| epoch-D `d362318` | `value=10 … guard=1` (disclosed: E did not change the gate) | 0 |
| epoch-E `dd31b786` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| reference overlay | `value=10 … guard=1` | 0 |
| printer gate | `value=FAIL … guard=0` | 0 |
| `-> 1x` / `-> 1.0` / `-> 1_0` | `value=FAIL present=9 replayed=9 guard=0` each | 0 |
| added uncaptured / added captured clock | `value=0 … guard=1` each | 0 |
| gate symlink / gate FIFO | `value=FAIL … guard=0` | 0 |
| 8-column / `fetched=2026-11-7` / `http_status=404` / shared actual body_path / duplicate URL | `value=0 … r2-manifest-malformed ×10` | 0 |
| body_path outside `capture*` | `value=0 … r3-notcapture:…` | 0 |
| `set-cookie:` / `Set-Cookie:` / `Http/2 302` / `< Set-Cookie:` / `< HTTP/1.1` at column 0 | `value=0 … r3-headers:…` each | 0 |
| normaliser edited / symlinked entry / empty tree | `value=FAIL … guard=0` | 0 |
| no manifest / SETUP shapes | `value=0` / `SETUP …` | 0 / 2 |
| restricted PATH, all tools present (control) | `value=10 … guard=1` | 0 |
| restricted PATH minus `sha256sum` / `cut` / `tail` / `timeout` / `git` / `tar` | `SETUP no-sha256sum` / `no-cut` / `no-tail` / `no-timeout` / `no-git` / `no-tar` | 2 each |

Controls end-to-end (`bash plans/round-56-controls.sh <lane>`, REF = lane): six `INSTRUMENT`
lines, `CONTROLS: match=22 mismatch=0`, rc 0, 0 tar errors. Gate `--selftest: PASS (20 cases)`.

Closed against epoch D: **H1** (`plans/round-56.md:15` and the counter header/code now both say
`PASS (20 cases)`; the plan's Landing sentence agrees). The six tool guards are real: each
missing tool yields `SETUP …` rc 2 and no value line, and a restricted PATH carrying all six
still reads 10. `d362318` reading 10 under the epoch-E counter is consistent with the
disclosure (the gate bytes and pin are unchanged; E is guard/doc hardening, not verdict
tightening).

### I1 — MEDIUM — control `K1-F15-shared-body-path` does not exercise the manifest bijection

`plans/round-56-controls.sh` F15 re-points S114's `body_path` at
`.ufo/waves/round-56/capture/S113.body`, but S113's capture lives in **round-55**
(`.ufo/waves/round-55/capture/S113.body`); round-56 carries only
S054/S055/S057/S067/S070/S074/S078. The named target does not exist, so no two rows share a
path and the counter stops at the missing file. The receipt proves it: the only non-r5 badge in
that control is `r3-file:iso-11770-3-edition-status.md:85929.html`, with no
`r2-manifest-malformed` anywhere — a shared-path collision would badge malformed for every
clock. Corrected construction (S114 → the existing `.ufo/waves/round-55/capture/S113.body`):

```
$ bash plans/round-56-c1.sh --tree f15fix
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest-malformed:<all ten>)
rc=0
$ python3 -I -B f15fix/corpus/recheck-replay.py --root f15fix | tail -1
RECHECK_REPLAY: SETUP manifest-shared-body_path:S113+S114
```

So the bijection *check* is real in both instruments; only the control that claims to witness it
is vacuous — the same class as epoch-A's F5 (a control passing for the wrong reason). The 22/22
receipt therefore has 21 controls testing what they name.
Fix: point F15 at `.ufo/waves/round-55/capture/S113.body` (or share S055→S054, both in
round-56). This changes `plans/round-56-controls.sh`, so it needs a new predeclaration commit
(epoch F) but no counter/gate/normaliser hash changes.

### I2 — LOW — cosmetic: the manifest conditions are owned by r3 in the plan, r2 in the counter

`plans/round-56.md:15` folds the manifest arity/`fetched`/2xx/bijection conditions into its r3
sentence; the counter header (`plans/round-56-c1.sh:17-22`) folds them into r2; the code badges
them `r2-manifest-malformed`. The conditions are identical and enforced by both instruments; only
the conjunct label differs, so no reading changes — noted because this lane treats the predicate
text as the contract.

### H2 (carried) — the gate alone still reads `-> 1.0` as `-> 1`

Re-measured on epoch E: `python3 -I -B nxdot/corpus/recheck-replay.py --root nxdot` ⇒
`RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)`, while the counter's r1 boundary refuses
(`value=FAIL present=9`). The new `K1-F11b-restated-Ndot` control witnesses the counter side
only. Counter dominates; optional to give `CLOCK_RE` the same right boundary.

### Epoch E trailer

- report: `.ufo/waves/round-56/build/R56ReviewCounter.md`
- evidence A–E: `R56ReviewCounter.d/evidence{,-epochB,-epochC,-epochD,-epochE}.txt`
- epoch-E scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewCounter/epochE/` deleted after this
  report; no production file edited; no git/jj mutation; no tool installed.
- C1 on an unchanged `dd31b786` tree: **`value=10 present=10 replayed=10 gate=1 guard=1`, rc 0**;
  the admission harness must read that token, the candidate must not add a stated knowledge
  clock (E3), and it must not edit the gate or the normaliser (pins).
