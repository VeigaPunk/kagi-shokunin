# SCORECARD drafts for round 56 (not landed; the L1 places them)

## A. `## Round 56 — post-move` section frame and table

Draft frame sentence (house style of rounds 53–55):

> Candidate: the round-56 landing commit (recorded in the report). `.ufo/waves/round-56/controls/controls-prefreeze.txt` holds the first control readings (12 MATCH, epoch A); `.ufo/waves/round-56/controls/controls-prefreeze-epochB.txt` holds the re-freeze battery (`CONTROLS: match=16 mismatch=0`) and `K1-REF expect=10 got=10` is the claim reading on the epoch-B bytes. The candidate-tree readings of the counter and gate are in `.ufo/waves/round-56/w1/R56Scribe.d/instruments.txt`. Claim BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`; first predeclaration `42070de7770e1558adcf6aa7a7bc59309a9654d7`; epoch-B predeclaration `5d9a1571911ec38a456a40b443e19640abb9a88b` (07:44:42) commits the landing instruments — counter `6b132ea1…`, gate `2e9dfde3…` (equal to the counter's `GATE_SHA256_PIN`), controls `63cf8061…`, plan `033f2104…`; `bash plans/round-56-c1.sh 5d9a157…` reads `value=10 guard=1` (this seat, rc 0).

Draft table row (C1 freshness):

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-56-c1.sh <candidate>` (pre-commit form `--tree <landing tree>`) 0 → 10 (target 10): capability acquisition — `corpus/recheck-replay.py` replays every stated `curl … -> N` clock of `corpus/knowledge/*.md` against the committed body registered for its URL in `corpus/recheck-captures.tsv`, so 10 clocks across 8 entries in three filter forms (`grep -c` 8, `pdftotext -layout \| grep -c` 1, rendered-text `locate` 1) are re-verified true without network; per-clock MATCH/MISMATCH/NO-CAPTURE/BAD-CAPTURE/UNSUPPORTED/TOOL and `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` only when every clock matches; `--selftest` `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`; bodies are sha256- and registry-row-bound, symlink-confined, and header bytes are refused (QM72). BASE `C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1` (all ten `r2-manifest`: no manifest rows at BASE); landing tree `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` (control K1-REF, 12/12 controls MATCH). Seven bodies opened 2026-11-07 (S054/S055/S057/S067/S070/S074/S078; receipt `capture/fetch-receipt.json`, no response headers stored); S101/S113/S114 re-use their round-45/55 captures. Named ceilings: committed bytes only — a hand-written capture with a self-consistent manifest row scores (wave control witness = 10); a true but non-discriminating pattern scores; the live run remains the currency check (R56ExecLive: 0/10 live mismatches, 9/10 refetches byte-identical, S074 volatile at constant size). Observed ceiling: r5 is all-or-nothing — one damaged clock reads `value=0`, not 9. The hardened counter pins the gate digest (`GATE_SHA256_PIN (final `2e9dfde3…`)`), its `--root` rc 0, the exact `CLEAN (10/10/0/0/0/0/0)` tally and the exact 13-case `--selftest` line, so a substituted gate cannot stand (R56Critic A1, R56ReviewCounter F1/F2). | `.ufo/waves/round-56/controls/controls-prefreeze.txt` (K1-BASE 0, K1-REF 10, `CONTROLS: match=12 mismatch=0`); `.ufo/waves/round-56/capture/fetch-receipt.json`; `corpus/recheck-replay.py`; `corpus/recheck-captures.tsv`; `.ufo/waves/round-56/w1/R56Scribe.d/instruments.txt` (gate CLEAN rc 0, selftest PASS rc 0, counter 10 rc 0) |

Draft rows for the other five axes:

| calibration | 9 → 9 | No claim. | — |
| coverage | 9 → 9 | No claim. Registry 114 → 114; no row added or changed. The new manifest `corpus/recheck-captures.tsv` registers 10 capture URLs (7 bodies opened 2026-11-07, 3 re-used from rounds 45/55). | `corpus/recheck-captures.tsv` |
| depth | 9 → 9 | No claim. | — |
| operability | 9 → 9 | No claim. The new gate carries a 13-case `--selftest` and a per-clock verdict line; the gate and manifest are corpus instruments, counted under C1, not booked twice. | `corpus/recheck-replay.py` |
| adjacency | 9 → 9 | No claim. Connector sweep in the wave's connector report. | `.ufo/waves/round-56/w1/R56Connector.md` |

## B. Capabilities table row (main `## Capabilities` table)

| Capability | What it can now do | Evidence pointer | First-working round |
|---|---|---|---|
| stated-clock offline replay | replay every stated `recheck:` clock of `corpus/knowledge/*.md` against its committed body capture, so a stale expectation is distinguishable from a real change on the day it is read without network: 10 clocks across 8 entries in three filter forms (`grep -c`, `pdftotext -layout \| grep -c`, rendered-text `locate`), a per-clock MATCH/MISMATCH/NO-CAPTURE/BAD-CAPTURE/UNSUPPORTED/TOOL verdict, and `RECHECK_REPLAY: CLEAN` only when every clock MATCHes; bodies are sha256- and registry-row-bound, symlink-confined, and a body that begins `HTTP/` or carries `set-cookie:` is refused (QM72); 13-case selftest | `python3 -I -B corpus/recheck-replay.py --root .` ⇒ `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`, `--selftest` PASS 13 cases; `bash plans/round-56-c1.sh <candidate>` ⇒ `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1`; controls 12 MATCH (`.ufo/waves/round-56/controls/controls-prefreeze.txt`); `corpus/recheck-captures.tsv` | 56 |

Draft appended note after the table (house style):

> Round 56 note (appended): the latest first-working round is now 56 (lane-wide stated-clock offline replay, entered through `bash plans/round-56-c1.sh <candidate>` reading `value=10`; receipts `.ufo/waves/round-56/controls/controls-prefreeze.txt` K1-REF and the candidate reading recorded in the round report).
