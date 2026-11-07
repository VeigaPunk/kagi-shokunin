# R56Critic — C1 counter/gate attack report (epoch A and epoch B)

Seat: R56Critic (critic). Lane `kagi-shokunin`, branch master. Two frozen judges were
measured, because the predeclaration moved once mid-wave (§7):

| epoch | commit | `plans/round-56-c1.sh` | `corpus/recheck-replay.py` | `corpus/recheck-captures.tsv` |
|---|---|---|---|---|
| **A** | `42070de7770e1558adcf6aa7a7bc59309a9654d7` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| **B** | `5d9a1571911ec38a456a40b443e19640abb9a88b` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | unchanged |

Both hashes were taken from the commit (`git show <rev>:<path> | sha256sum`), not from the
working tree, and the epoch-B counter's `GATE_SHA256_PIN` equals the epoch-B gate digest
(checked). Every attack tree is a 3.7 MB `git archive 42070de` subset (`corpus/knowledge`,
`corpus/SOURCES.md`, `corpus/recheck-captures.tsv`, `corpus/recheck-replay.py`,
`corpus/rendered-text-v1.py`, the round-45/55/56 capture dirs), verified to score 10 unmodified
before each attack, so each delta is the attack alone. A judge is run from one live clone
checked out at the epoch revision (`git rev-parse --show-toplevel` asserted); the epoch-A
counter is the clone's own bytes, the epoch-B counter is installed over it from the commit.
Reproducer: `.ufo/waves/round-56/w1/R56Critic.d/run-attacks.sh` (prints both epoch hashes
first and refuses to run if the pin and the gate disagree).

Observed answering model: **not observable from inside the seat** — no tool here reports the
serving model. The project context names `amr/deepseek-v4.1-flash`; that is prompt-supplied,
not an observation, so it is recorded as unobserved.

## 0. Controls

```
A positive (gate b7782f35)  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
B positive (gate 2e9dfde3)  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
A judge on BASE 832ba6a     C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:<all 10>)
B judge on BASE 832ba6a     C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:<all 10>)
B judge on epoch-A rev      C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate×10)
B gate selftest             RECHECK_REPLAY_SELFTEST: PASS (13 cases)          rc=0
```

C1 0→10 holds in both epochs. The two judges are mutually exclusive: the epoch-B judge scores
the epoch-A commit 0 (its gate digest is not the pin), so exactly one of them can be the round's
judge at a time and every C1 number must name its commit.

Population census (HEAD gate's `clocks()` over BASE `corpus/knowledge`, `git archive 832ba6a…`):
**exactly 10 clocks, identical to the counter's POP list field-for-field** (entry, URL, form, N;
8 `grep`, 1 `pdf`, 1 `locate`). POP is not truncated and PRESENT is satisfiable at BASE
(`present=10`). No population defect.

## 1. Attacks — observed values

| # | attack | setup | A `42070de` | B `5d9a157` | verdict |
|---|---|---|---|---|---|
| A1 | **gate → constant printer** (`.d/fake-gate.py`: 10 fixed MATCH lines + `CLEAN`; `--selftest` prints `PASS (0 cases)`) | real bodies, real manifest, entries untouched | **10** | **0** (`r5-gate`×10) | hole in A, closed in B |
| A2 | **gate → symlink** to `.ufo/printer.py` (nothing inside `corpus/` edited) | as A1 | **10** | **0** (`r5-gate`×10) | hole in A, closed in B |
| A3 | **one 691-byte text body for 9 clocks** (`d23ad28c…`; `grep -c` multiplicities 1/2/3/2/1/1/1/1 + the locate quote; row S078 keeps the genuine 622 785-byte NIST PDF) | 9 rows re-pointed, gate untouched | **10** | **10** | **ceiling** |
| A4 | **one 1287-byte uncompressed PDF for all 10 clocks** (`81140c69…`, `.d/forge-a2b.py`; raw `grep -c`, `pdftotext -layout \| grep -c` and `rendered-text-v1.py locate` all agree) | all 10 rows re-pointed | **10** | **10** | **ceiling** |
| A5 | symlink the body (relative component) | digest/bytes recomputed | 0 (`r3-file`) | 0 (`r3-file`) | blocked |
| A6 | drop the manifest | — | 0 (`r2-manifest`×10) | 0 (`r2-manifest`×10) | blocked |
| A7 | inline the body in `body_path` (`data:text/plain;base64,…`) | digest/bytes recomputed | 0 (`r3-file`) | 0 (`r3-file`) | blocked |
| A8 | edit the stated N **and** the body together (`-> 3`→`-> 1`, body to 1) | both sides agree; only the statement moved off BASE | `FAIL present=9 replayed=9 guard=0` (`absent:…:82709.html`) | same | blocked |
| A9 | drift one real body (delete 1 of the 3 matching lines in round-55 `S113.body`), manifest honest | — | 0 (`r4-replay2` on `…:82709.html` + `r5-gate`×9) | same | blocked |
| A10 | A9's tree **plus** the printer gate | isolates r4 | **9** (`gate=1 guard=1`; only `r4-replay2`) | n/a (pin rejects the printer) | hole in A |
| A11 | tamper a real body, leave the manifest stale | — | 0 (`r3-digest` on `…:82709.html`) | same | blocked |
| A12 | correct clocks, tree lacks `corpus/rendered-text-v1.py` | nothing else changed | 0 (`r5-gate`×10) | 0 (`r5-gate`×10) | **defect (F5)** |

`rc=0` on every row, including `value=FAIL` and `value=0` (F4).

## 2. What the capability actually detects

*Does replaying add real detection over BASE?* **Yes, for statement-vs-capture consistency**,
and each conjunct has been made to fire:

| mutation | conjunct that caught it | run |
|---|---|---|
| statement restated (N moved) | PRESENT / r1 | A8 |
| body edited after the capture | r3 digest | A11 |
| capture drifted from its statement | r4 replay | A9 |
| capture missing / unregistered | r2 | A5, A6, A7 |
| body replaced by a self-consistent forgery | **nothing** | A3, A4 |
| gate replaced by a printer | r5, in epoch B only (digest pin) | A1, A2 |
| tree missing the gate's normaliser | r5, but for the wrong reason | A12 |

*Is it freshness?* **No.** C1 proves the ten statements are true of the committed bytes; a
stale-but-true statement stays green forever. `plans/round-56.md` concedes currency to the live
run, so the frozen predicate sentence is honest — the round label ("capability claim on
freshness") overstates what `value=10` means.

Live leg I ran (public GETs, bodies only, no headers stored). Of the seven new round-56
captures, **six hash-match today's live body byte-for-byte** — S054 `7cf6efb5…eff7`,
S055 `f61c3993…73b1`, S057 `221d80fa…604b`, S067 `4d016752…5aed`, S070 `5c226c06…c0dd`,
S078 `68266cb1…8d5`. **S074 does not**: both 45 351 bytes, 582 bytes differ from offset 26 266,
inside a Cloudflare `email-protection#…` blob (live `09367a7c…`, capture `e3dc9096…`);
`grep -c 'public comment period is CLOSED'` on the live body is still **1**. The capture is
genuine and per-request volatile.

## 3. Cheapest skip-work path to value=10, and its cost

**A4 (both epochs): one 1287-byte synthesized PDF + ten `body_path`/`bytes`/`sha256` edits in
`corpus/recheck-captures.tsv`.** No entry edit, no registry edit, no fetch, gate untouched — the
real 333-line gate reports `CLEAN (clocks=10 match=10 …)` and the digest pin is satisfied
because the attacker never needed to touch the gate. **A3** is the same value with a 691-byte
text file and nine row edits if the genuine S078 PDF is kept.

Answer to "does a skip-work path reach 10": **yes, and it needs one artifact, not ten.** r3 does
not distinguish nine rows sharing a 691-byte file from nine real pages, nor a 1.3 KB synthesized
PDF from the 622 KB NIST PDF; only duplicate *URLs* are refused, not shared `body_path`s
(counter r2 `len(rows) != 1`; gate `manifest-duplicate-url`). One further degree of freedom:
a manifest row's `fetched` and `http_status` are never read by either program — A4's rows claim
`200` / `2026-11-07` for bytes that were never fetched.

## 4. Is the ceiling acceptable?

**As an impossibility statement, yes; as a safeguard, no.** Inside committed bytes a
self-consistent forgery is undetectable by construction, and the lane says so. But the ceiling
names two provenance checks and the measured artifacts enforce neither:

- **Fetch receipt — not read.** `grep -c receipt` is 1 in each of `plans/round-56-c1.sh` and
  `corpus/recheck-replay.py`, and in both epochs that one hit is the prose comment. Neither
  program opens `.ufo/waves/round-56/capture/fetch-receipt.json`.
- **Non-author live re-fetch — not implemented and not expressible as byte equality.** Neither
  epoch runs a live fetch: `grep -c curl` is 11 in the counter (the ten POP literals plus one
  comment) and 0 in the gate; and S074 shows one of ten captures cannot be byte-reproduced
  minutes later.

So the honest statement is: *the C1 measurement is forgeable at the cost of one artifact, and
the only safeguard that could catch it — a live replay of each filter on the day — is neither
shipped nor expressible as a body-digest comparison.* What makes the current 10 credible is
evidence outside C1: the six byte-identical live matches above, and the round-45/55 committed
captures behind S101/S113/S114. That is provenance by audit, not by measurement; the counter
must not be read as having checked it.

## 5. Findings and smallest safe corrections

**F1 (epoch A: real hole; epoch B: closed — keep the pin coupled to a commit).** A 15-line
constant printer, installed as `corpus/recheck-replay.py` or as a symlink to one, satisfied r5
and produced `value=10` under the epoch-A judge; with one drifted body it produced **9 where
the honest gate produced 0**, i.e. r5 could only subtract. The epoch-B `GATE_SHA256_PIN`
(`plans/round-56-c1.sh:79`) plus the per-component `-L` scan closes both variants — my runs and
the epoch-B controls (`K1-F5-printer-gate`, `K1-F5b-gate-edited`, `K1-F5c-gate-symlink`, all
`expect=0 got=0 MATCH`) agree. Residual: the pin must always be regenerated in the same commit
as the gate, and the round must cite one commit (§7).

**F2 (both epochs; declared ceiling).** Bodies are not bound to their URLs (A3, A4). Cheapest
strengthening that needs no network: add a `receipt_sha256` column and require it to equal the
sha256 recorded for that URL in `capture/fetch-receipt.json` — two-sided forgery instead of
one-sided. It does not make the forgery impossible, only dearer.

**F3 (both epochs; metric).** `RECHECK_REPLAY: CLEAN` is an aggregate inside a per-clock
predicate: one drifted capture of ten prints `replayed=0`, not 9 (A9, both epochs), which is
indistinguishable from "no work done". If partial signal is wanted, take `gate_ok` out of the
per-clock conjunct (`r4` already catches the drift).

**F4 (both epochs).** `rc=0` on `value=FAIL` (A8) and on `value=0` (A5–A7, A9, A11, A12); only
SETUP exits 2. The frozen predicate specifies output, not rc, so this is a gap rather than a
violation — but `bash plans/round-56-c1.sh … || fail` passes on FAIL. A later counter must exit
non-zero when `value != target`.

**F5 (both epochs; counterexample to the claim as worded).** The gate runs the *measured tree's*
`corpus/rendered-text-v1.py`; the counter runs BASE's pinned copy. A tree whose ten clocks all
replay correctly scores **0** if it merely lacks that file (A12: `value=0 present=10 replayed=0`,
every clock `r5-gate`). So "value=10 iff the ten clocks replay true on their captures" is false
as written. Fix: one normaliser — the gate should use the counter-pinned copy, or the counter
should stop depending on a gate whose environment differs.

**F6 (ceiling text).** Replace "non-author live re-fetch" with "live replay of the filter"
(`curl -fsSL <url> | <filter> == N` on the day, by a non-author); byte equality is refuted by
S074.

**F7 (freeze integrity).** See §7 — closed by `5d9a157`, but the wave ran for a window in which
the judge was mid-edit and, at one instant, did not parse.

Verdict on C1 as frozen at `5d9a157`: **the capability is real and honestly scoped; the number
is not evidence of currency; and in epoch A it was not evidence of the gate either.** Nothing
here rejects C1 at epoch B. The epoch-A artifacts must not be cited with the reasons they claim,
and the round must name `5d9a157` as the only judge.

## 6. Axes impacted

- **freshness / C1**: real statement-vs-capture detector (A8, A9, A11 fire in both epochs); not a
  currency detector; `value=10` reachable with one forged artifact in both epochs (A3, A4).
- **gate conjunct (r5)**: unsound in epoch A (printer, symlink, and it could only subtract);
  sound in epoch B because the pin is a digest of committed bytes.
- **named ceilings**: the receipt is unread; the live leg is unimplemented and not
  byte-comparable — restate both.
- **No C2 claim**: untouched; the counter prints one line and no substring of it reads as C2.
- Untouched by me: production files, git/jj state in the lane, fleet-root files. Only this
  report and `.d/` were written; the six live GETs stored bodies in scratch only, and scratch is
  deleted before yield.

## 7. Freeze drift observed mid-wave (F7)

The lane's judge changed under me while I was attacking the predeclaration:

```
before: plans/round-56-c1.sh 096251c9…, corpus/recheck-replay.py b7782f35…   (commit 42070de)
during: plans/round-56-c1.sh 1e57445c…, corpus/recheck-replay.py 637c8184…   (uncommitted, pin 637c8184…)
during: plans/round-56-c1.sh 6b132ea1…, corpus/recheck-replay.py 2e9dfde3…   (uncommitted, pin 2e9dfde3…)
after : 5d9a1571911ec38a456a40b443e19640abb9a88b                             (counter 6b132ea1…, gate 2e9dfde3…)
```

Two observations that matter beyond the end state:

1. **A pin on uncommitted bytes is not reproducible.** At the `1e57445c`/`637c8184` step the
   counter's `GATE_SHA256_PIN` named a blob that existed in no revision, so a judge run in that
   window could be reproduced by no receipt. `5d9a157` fixes this: `git show
   5d9a157:corpus/recheck-replay.py | sha256sum` = the pin, verified above.
2. **The judge was transiently non-executable.** One invocation in that window died with
   `plans/round-56-c1.sh: line 107: syntax error near unexpected token '('` on
   `case $last in "RECHECK_REPLAY_SELFTEST: PASS (13 cases)"*)`, i.e. the file was read mid-edit;
   later invocations of the same path parsed. Any seat that ran the counter during that window
   has a reading whose bytes cannot be named. That is why every row here carries a commit and a
   hash, and why the reproducer snapshots the judge before running anything.

Second-order consequence of the pin, which the next round should write down: the gate is now
byte-frozen, so a legitimate gate improvement fails r5 until the counter is re-frozen with it.

## 8. Adjacent observation, not my seat (controls receipt)

`.ufo/waves/round-56/controls/controls-prefreeze-epochB.txt` reads `CONTROLS: match=16
mismatch=0`, with two artefacts in the same bytes worth a controls-seat look:

- every control's tree build emits `tar: .ufo/waves/round-56/build-dispatch.json: Cannot stat`
  (and `build-spec.json`, `build.ready`, `build/swarm-registry.json`), then `tar: Exiting with
  failure status due to previous errors` — the archive pathspec names files absent from the
  revision. The extractions still complete for the C1-relevant files (my runs reproduce every
  `got=` value with an independent tree), but the receipt records a failure status per control.
- `CONTROL K1-F2-restated-N` logs a Python `AssertionError: inert edit
  corpus/knowledge/betterleaks-detection-vs-validation.md` and still records `MATCH` with
  `value=FAIL present=9`. The mutation that control is named for did not apply, so the FAIL it
  matched came from something else in that tree. A control whose mutation is asserted-but-failed
  should be a mismatch, not a match.
