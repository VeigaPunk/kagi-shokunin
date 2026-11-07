# R56Critic — C1 counter/gate attack report (epoch A and epoch B)

Seat: R56Critic (critic). Lane `kagi-shokunin`, branch master. Two artifact epochs were
measured, because the frozen pair moved under me mid-wave (see §7):

| epoch | `plans/round-56-c1.sh` sha256 | `corpus/recheck-replay.py` sha256 | manifest sha256 |
|---|---|---|---|
| **A** (predeclaration `42070de`, committed) | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| **B** (working tree at 2026-11-07, uncommitted) | `1e57445cabe2598cc7a500f18b9bf248b0a84b8b348d0c078e27f1bbb61442c2` | `637c8184bd6ea8635fe582ea5641ea490033405658259c1a78c63899611aa585` | unchanged |

Epoch A was run from a clean clone checked out at `42070de7770e1558adcf6aa7a7bc59309a9654d7`
(`git rev-parse --show-toplevel` = the clone, verified; clone removed with scratch). Epoch B
was run from the lane working tree. Every attack tree is a 3.7 MB `git archive 42070de` subset
(`corpus/knowledge`, `corpus/SOURCES.md`, `corpus/recheck-captures.tsv`,
`corpus/recheck-replay.py`, `corpus/rendered-text-v1.py`, the three capture dirs) and was
verified to score 10 unmodified before each attack, so each delta is the attack alone.
Reproducer: `.ufo/waves/round-56/w1/R56Critic.d/run-attacks.sh`.

Observed answering model: **not observable from inside the seat** — no tool here reports the
serving model. The project context names `amr/deepseek-v4.1-flash`; that is prompt-supplied,
not an observation, so it is recorded as unobserved.

## 0. Controls

```
epoch A, positive control (clean clone, --tree working tree of the clone)
  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)          rc=0
epoch B, positive control (--tree = frozen corpus subset + epoch-B gate)
  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)          rc=0
epoch A, BASE 832ba6a53d6a76706b5c80bce2278683dea33d42
  C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:<all 10>)  rc=0
epoch A, gate selftest
  RECHECK_REPLAY_SELFTEST: PASS (13 cases)                                     rc=0
```

C1 0→10 is confirmed in both epochs. Population census (HEAD gate's `clocks()` over BASE
`corpus/knowledge`, `git archive 832ba6a…`): **exactly 10 clocks, identical to the counter's
POP list field-for-field** (entry, URL, form, N; 8 `grep`, 1 `pdf`, 1 `locate`). POP is not
truncated; PRESENT is satisfiable at BASE (`present=10`). No population defect.

## 1. Attacks — observed values

`value` is the counter's reported `C1_REPLAY: value=…`; epoch-B rows install the epoch-B gate
bytes in the tree (otherwise the digest pin fails r5 for every clock and the attack is not
isolated).

| # | attack | setup | epoch A | epoch B | verdict |
|---|---|---|---|---|---|
| A1 | **gate → constant printer** (`.d/fake-gate.py`: 10 fixed MATCH lines + `CLEAN`, `--selftest` prints `PASS (0 cases)`) | real bodies, real manifest, entries untouched | **10** | 0 (`r5-gate`×10) | **hole in A, closed in B** |
| A2 | **gate → symlink** to `.ufo/printer.py` (no edit inside `corpus/`) | as A1 | **10** | 0 (`r5-gate`×10) | **hole in A, closed in B** |
| A3 | **one 691-byte text body serving 9 clocks** (`d23ad28c…`, `grep -c` multiplicities 1/2/3/2/1/1/1/1 + the locate quote; row S078 keeps the genuine NIST PDF) | 9 manifest rows re-pointed, real gate | **10** | **10** | **ceiling** |
| A4 | **one 1287-byte uncompressed PDF serving all 10 clocks** (`81140c69…`, `.d/forge-a2b.py`; raw `grep -c`, `pdftotext -layout\|grep -c` and `rendered-text-v1.py locate` all agree) | all 10 rows re-pointed | **10** | **10** | **ceiling** |
| A5 | symlink every row to one body | relative symlink component | 0 (`r3-file`) | 0 (`r3-file`) | blocked |
| A6 | drop the manifest | inline bodies impossible anyway | 0 (`r2-manifest`×10) | 0 (`r2-manifest`×10) | blocked |
| A7 | inline the body in `body_path` (`data:text/plain;base64,…`) | digest/bytes recomputed | 0 (`r3-file`) | 0 (`r3-file`) | blocked |
| A8 | edit the stated N **and** the body together (`-> 3`→`-> 1`, body to 1) | both sides agree, only the statement moved off BASE | `FAIL present=9 replayed=9 guard=0` (`absent:…:82709.html`) | `FAIL present=9 replayed=9 guard=0` | blocked |
| A9 | drift one real body (delete 1 of 3 matching lines in round-55 `S113.body`), manifest honest | — | 0 (`r4-replay2` + `r5-gate`×9) | 0 (`r4-replay2` + `r5-gate`×9) | blocked |
| A10 | same drifted tree **plus** the printer gate | isolates r4 | **9** (`r4-replay2`, gate=1, guard=1) | n/a — pin rejects the printer | **hole in A** |
| A11 | tamper a real body, leave the manifest stale | — | 0 (`r3-digest`) | 0 (`r3-digest`) | blocked |
| A12 | correct clocks, tree lacks `corpus/rendered-text-v1.py` | nothing else changed | 0 (`r5-gate`×10) | 0 (`r5-gate`×10) | **defect (F5)** |

All runs `rc=0`, including `value=FAIL` and `value=0` (F4).

## 2. What the capability actually detects

*Does replaying add real detection over BASE?* **Yes, for statement-vs-capture consistency**,
and every new conjunct has been shown to fire:

| mutation | conjunct that caught it | run |
|---|---|---|
| statement restated (N moved) | PRESENT / r1 | A8 |
| body edited after the capture | r3 digest | A11 |
| capture drifted from its statement | r4 replay | A9 |
| capture missing / unregistered | r2 | A5, A6, A7 |
| body replaced by a self-consistent forgery | **nothing** | A3, A4 |
| gate replaced by a printer | r5 only in epoch B (digest pin) | A1, A2 |

*Is it freshness?* **No.** C1 proves the ten statements are true of the committed bytes; a
stale-but-true statement stays green forever. `plans/round-56.md:19` concedes currency to the
live run, so the frozen predicate sentence is honest — the round label ("capability claim on
freshness") overstates what `value=10` means.

Live leg I ran (public GETs, bodies only, no headers stored). Of the seven new round-56
captures, **six hash-match today's live body byte-for-byte** — S054 `7cf6efb5…eff7`,
S055 `f61c3993…73b1`, S057 `221d80fa…604b`, S067 `4d016752…5aed`, S070 `5c226c06…c0dd`,
S078 `68266cb1…8d5`. **S074 does not**: both 45 351 bytes, 582 bytes differ from offset 26 266,
inside a Cloudflare `email-protection#…` blob (live `09367a7c…`, capture `e3dc9096…`);
`grep -c 'public comment period is CLOSED'` on the live body is still **1**. The capture is
genuine and per-request volatile.

## 3. Cheapest skip-work path to value=10, and its cost

**A4 (epoch A and epoch B): one 1287-byte synthesized PDF + ten `body_path`/`bytes`/`sha256`
edits in `corpus/recheck-captures.tsv`.** No entry edit, no registry edit, no fetch, gate
untouched — the real 333-line gate reports `CLEAN (clocks=10 match=10 …)`. **A3** is the same
value with a 691-byte text file and nine row edits if the genuine S078 PDF is kept.

Answer to "does a skip-work path reach 10": **yes, and it needs one artifact, not ten.** The
counter's r3 does not distinguish nine rows sharing a 691-byte file from nine real pages, nor a
1.3 KB synthesized PDF from the 622 KB NIST PDF; only duplicate *URLs* are refused, not shared
`body_path`s (`plans/round-56-c1.sh` r2 `len(rows) != 1`; gate `manifest-duplicate-url`).

## 4. Is the ceiling acceptable?

**As an impossibility statement, yes; as a safeguard, no.** Inside committed bytes a
self-consistent forgery is undetectable by construction, and the lane says so. But the ceiling
names two provenance checks and the measured artifacts enforce neither:

- **Fetch receipt — not read.** `grep -c receipt` is 1 in each of
  `plans/round-56-c1.sh` and `corpus/recheck-replay.py`, and that one hit is the prose comment
  (`plans/round-56-c1.sh:38-40` in epoch A, same text in epoch B). Neither the counter nor the
  gate opens `.ufo/waves/round-56/capture/fetch-receipt.json`. A4's rows carry
  `http_status 200 fetched 2026-11-07` for a file never fetched, and nothing looks: `fetched`
  and `http_status` are dead columns (r2 reads `url`; r3 reads `body_path`, `bytes`, `sha256`).
- **Non-author live re-fetch — not implemented and not expressible as byte equality.** No live
  leg exists in either epoch (no `curl` outside the POP literals), and S074 shows one of ten
  captures cannot be byte-reproduced minutes later.

So the honest statement is: *the C1 measurement is forgeable at a cost of one artifact, and the
only safeguard that could catch it — a live replay of each filter on the day — is neither
shipped nor expressible as a body-digest comparison.* What makes the current 10 credible is
evidence outside C1: the six byte-identical live matches above and the round-45/55 committed
captures behind S101/S113/S114. That is provenance by audit, not by measurement, and the
counter must not be read as having checked it. Cost of adding the live leg: one `curl` + the
existing filter per clock, run once per round by a non-author; it cannot be a frozen-bytes
conjunct, so it belongs beside C1, not inside it.

## 5. Findings and smallest safe corrections

**F1 (epoch A, fixed in B — confirm the fix landed in a commit).** A 15-line constant printer,
installed as `corpus/recheck-replay.py` **or as a symlink to one**, satisfies r5 and yields
`value=10`; with one drifted body it yields **9 where the honest gate yields 0** — under epoch A
r5 could only subtract. Epoch B's `GATE_SHA256_PIN` (line 74) plus the per-component `-L`
scan closes both variants (A1/A2 now `value=0`, `r5-gate`×10). Smallest residual: the pin must
name a **committed** blob and be regenerated in the same commit as the gate, else the judge
reproduces against no revision (§7).

**F2 (both epochs, declared ceiling).** Bodies are not bound to their URLs (A3, A4). Cheapest
real strengthening that does not need the network: add a `receipt_sha256` column and require it
to equal the sha256 recorded for that URL in `capture/fetch-receipt.json` — two-sided forgery
instead of one-sided. It does not make the forgery impossible, only dearer.

**F3 (both epochs, metric).** `RECHECK_REPLAY: CLEAN` is an aggregate inside a per-clock
predicate: one drifted capture of ten prints `replayed=0`, not 9 (A9: `present=10 replayed=0`),
indistinguishable from "no work done". The frozen sentence is literally satisfied, but the
number cannot show partial progress. If partial signal is wanted, drop `gate_ok` from the
per-clock conjunct (r4 already catches the drift) or score the gate's per-clock MATCH lines
independently.

**F4 (both epochs).** `rc=0` on `value=FAIL` (A8) and on `value=0` (A5–A7, A9, A11, A12); only
SETUP exits 2. The frozen predicate specifies output, not rc, so this is a gap rather than a
violation — but `bash plans/round-56-c1.sh … || fail` passes on FAIL. A future counter must exit
non-zero when `value != target`.

**F5 (both epochs, counterexample to the claim as worded).** The gate runs the *measured tree's*
`corpus/rendered-text-v1.py`; the counter runs BASE's pinned copy. A tree whose ten clocks all
replay correctly scores **0** if it merely lacks that file (A12: `value=0 present=10 replayed=0`,
every clock `r5-gate`). So "value=10 iff the ten clocks replay true on their captures" is false
as written: correct statements plus correct captures do not imply 10. Fix: one normaliser — the
gate should use the counter-pinned copy (or the counter should stop depending on a gate whose
environment differs).

**F6 (ceiling text).** Replace "non-author live re-fetch" with "live replay of the filter"
(`curl -fsSL <url> | <filter> == N` on the day, by a non-author); byte equality is refuted by
S074.

**F7 (freeze integrity, epoch A→B).** See §7.

Verdict on the C1 claim as frozen: **the capability is real and honestly scoped, the *number*
is not evidence of currency, and in epoch A it was not evidence of the gate either.** No reason
here to reject C1 at epoch B provided the pin and the re-freeze land in one commit; the epoch-A
artifacts must not be cited as the ones that scored 10 for the reasons they claim.

## 6. Axes impacted

- **freshness / C1**: real statement-vs-capture detector (A8, A9, A11 all fire); not a currency
  detector; `value=10` reachable with one forged artifact in both epochs (A3, A4).
- **gate conjunct (r5)**: epoch A unsound (printer, symlink, and it could only subtract);
  epoch B sound only if the pin names committed bytes.
- **named ceilings**: the receipt is unread and the live leg is unimplemented and not
  byte-comparable — restate both.
- **No C2 claim**: untouched; the counter emits one line and no substring of it reads as C2.
- Untouched by me: production files, git/jj state in the lane, fleet-root files. Only this
  report and `.d/` were written; the six live GETs stored bodies in scratch only, scratch
  deleted before yield.

## 7. Freeze drift observed mid-wave (F7)

While I was attacking the predeclaration, the lane's working tree changed under me:

```
git status --short plans/ corpus/
 M corpus/SOURCES.md          (S113 row: adds the default-UA 403 receipt; id/url/status unchanged)
 M corpus/recheck-replay.py   b7782f35… -> 637c8184…   (+11/-1)
 M plans/round-56-c1.sh       096251c9… -> 1e57445c…   (+95/-23)
```

The epoch-B counter adds `GATE_SHA256_PIN=637c8184bd6ea8635fe582ea5641ea490033405658259c1a78c63899611aa585`
at line 74 and a `GATE_RC`/exact-`CLEAN(10/10/0…0)` check. **At the moment I measured it, the
pinned digest existed in no revision** — `git show 42070de:corpus/recheck-replay.py` hashes to
`b7782f35…`, and the epoch-B gate was uncommitted. A judge whose pin names uncommitted bytes
cannot be reproduced by any receipt or re-run, so its 10 is not citable until the pin and the
gate land in one commit (L1 states this is the epoch-B re-freeze and will be committed as a new
predeclaration; my numbers above follow that split).

Second-order effect of the same edit: the gate is now byte-frozen, so an *improvement* to the
gate fails r5 until the counter is re-frozen with it. That is acceptable inside a frozen round
but must be written down, otherwise the next round will read a legitimate gate fix as drift.
