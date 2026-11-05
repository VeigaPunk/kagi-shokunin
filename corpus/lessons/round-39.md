source: S094 (CORPUS.md §SOURCES.md rule 2, own-work, opened 2026-11-05 at fleet revision f47ad6ba); the instruments' committed bytes are the evidence for the rest

# Round 39 — anchor-pin gate (C1, freshness) and declared-axis gate (C2, calibration)

Frozen plan: `plans/round-39.md` at `7c11e769cd7c2450cf46faabcd3b43fca993f388` (plan alone). Predeclaration (instruments, pins, frozen counters, controls, declared-axis manifest): `1909e3876341cc90246516886def37a7c9ea92f9`. Pre-freeze gate over the predeclaration: `PREFREEZE: CLEAN (controls=4 mismatch=0)` (`plans/round-39.controls.tsv`, rows `c1_nowork 0`, `c1_positive_three 3`, `c2_nowork 0`, `c2_positive_three 3`). Claim BASE: `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`.

Fresh-start check: not a fresh-start round. Rounds 36, 37 and 38 closed `ok` (`MANIFEST.json` rounds 1321, 1328 and the round-36 entry); the last-three window holds no rejected closure.

## Claims and verdicts (measured at the candidate; see §Verdicts for the landing revision)

- **C1 freshness — anchor-pin gate, 0 → 3.** `bash plans/round-39-c1.sh` → `3` (M1 S034 `v2.2.0`→`v2.2.1`, M2 S035 `v2.7.1`→`v2.7.2`, M3 S039 `Python 3.15.1`→`3.15.2`: each reported `DRIFT` by `corpus/anchor-pins.sh`). Do-nothing (instrument absent, `c1_nowork`) → 0. `bash corpus/anchor-pins.sh --root .` → `ANCHOR_PINS: CLEAN (pins=3)`, exit 0 on the real tree. Round-37 counter `bash plans/round-37-c2.sh` still reads 0 (its own semantics unchanged). Ceiling: pin and row rewritten together pass (QM40).
- **C2 calibration — declared-axis gate, 0 → 3.** `bash plans/round-39-c2.sh` → `3` (X1 SCORECARD row relabelled calibration→operability; X2 plan heading relabelled; X3 tag removed → each `MISMATCH`). Do-nothing (instrument absent, `c2_nowork`) → 0. `bash corpus/claims-declared.sh --root .` → `CLAIMS_DECLARED: CLEAN (claims=2)` on the real tree. Ceiling: the gate reads the lane's own text and does not judge whether the axis is right (QM41).
- **Exploratory claims:** none. **Capability rows entered:** two (`anchor-pin drift detection`, `declared-axis conformance`), each with its running demonstration above.

## Gate — new registry row and re-opened source

- **ADMIT S094** — `CORPUS.md` §SOURCES.md, rule 2 (own-work, the registry contract itself). Access: local read of `/home/vgpnk/Projects/shokunin/CORPUS.md` at fleet revision `f47ad6ba` on 2026-11-05; line 116 reads `2. **Append-only.** Only \`status\`, \`recheck\` and \`used-by\` change in place, and each change` (located quote, 9 words: “Only `status`, `recheck` and `used-by` change in place”). Grounds `teaches`: an in-place rewrite of any other registry cell, including the anchor, is outside the contract and must be caught by a gate. The row is own-work tier A because the file is the specification of the registry it governs.
- **Re-opened, no row change:** S034, S035, S039 — their anchor cells were hashed at the claim BASE and the pins were committed in the predeclaration; the pins match the BASE cells (`bash corpus/anchor-pins.sh` at BASE via the controls runner: `c1_nowork` → 0 because the instrument is absent; the positive control's clean run is `ANCHOR_PINS: CLEAN (pins=3)` at the predeclaration).
- **Refused candidate, not appended:** none this round.

## Sweep of the round-38 closure's routed items

Read `corpus/lessons/round-38-verifier-spotcheck.md` (non-author, integrator). Dispositions:

| routed item | disposition this round |
|---|---|
| R38-D1 (C2 axis relabelled after data) | **C2 claim** (declared-axis gate). |
| R38-D2 (report wording "not amended after data"; self-verdict on C2) | Report for this round names no self-verdict on any claim beyond the measured counters, and states the relabel of round 38 as an unrecorded mismatch (below). |
| R38-D3 (`observe-r38.json` not a pin) | Not claimed. Named in the plan §Routed. |
| R38-D4 (frozen-counter gaps V1, V2, V4, V5, V6; mutants M2, M3, M5, M6, G3) | Routed to round 40 as frozen-counter amendments with their red witnesses (`.ufo/waves/round-38/build/`). Not claimed. |
| R38-D5 (`R38-03` POLICY) | Operator-owned; L0 question open. |
| R38-D6 / R37-V2 (release-clock re-point, 15 fired clocks) | Not claimed. Measured again at BASE: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`. The fired clocks sit on Vault, OpenBao and Python; the derivation dependence measured in round 38 still stands. |
| R37-V4 (anchor immutability for S034/S035/S039) | **C1 claim** (anchor-pin gate). |

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M39-1 | attribution (axis relabelled after the counter read) | `corpus/lessons/round-38-verifier-spotcheck.md` §2 C2 and CD-1/CD-2: `plans/round-38.md` declares C2 as calibration; `SCORECARD.md` round-38 post-move row carries C2's move under `operability`. Round-38 SCORECARD: the calibration row reads `No calibration move is claimed`. | `none` (no gate compared the frozen axis with the reporting row) | **C2**: `corpus/claims-declared.sh` + `corpus/claims-declared.tsv`; shown able to fail: `bash plans/round-39-c2.sh` → 3 of 3 planted relabels detected; clean fixture CLEAN; do-nothing 0. The round-38 relabel itself is not re-scored: it is outside the manifest and reported as unrecorded history (named ceiling). |
| M39-2 | reference-drift (documented usage differs from the form the code accepts) | `corpus/laneguard.sh` header and line 101 documented `run LANE -- CMD`; the code requires `run -- LANE [--] CMD`. Probe, BASE: `bash corpus/laneguard.sh run <dir> -- true` → rc 2 with the documented-form usage (`/fast/scratch/hyaku/kagi-r39/l1/gdbg` run, round-39 build). | `none` (the selftest calls `run_guard` directly, so no test reached the CLI) | the header, line 101 and the usage line corrected to `run -- LANE [--] CMD`. Shown able to fail: the documented form still prints usage and exits 2 (`bash corpus/laneguard.sh run kagi-lane-dummy -- true` → `usage: laneguard.sh run -- LANE [--] CMD...`); the implemented form returns `LANE_GUARD: CLEAN lane=. rc=0`. The selftest stays `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`. |
| M39-3 | landing (edit drift, own plan) | while writing `plans/round-39.md` a hashline `PUT 3.=3` aimed at the claim-BASE line replaced the round header; a second edit then duplicated a line. Caught by read-back before the plan was committed; repaired. Plan committed at `7c11e76` only after the read-back (the header line 3 and the claim-BASE line 5 are verified there). | `none` | read the exact range back after every hashline edit, before the next edit (the M38-4 rule, applied again) |

## Census

- Before (START, `/fast/scratch/hyaku/kagi-r39/l1/census/start-lane.txt`): `SOURCES_CENSUS: CLEAN (rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0. Fleet `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, exit 0 (one W04 duplicate-URL warning, S091).
- After (candidate, S094 appended, this lesson written): see §Census result at the landing revision (filled from the measured commands in the round report).

## Assimilation and considerthese

- Assimilation: none. The eight `kagi` rows of the absent-defect register remain quarantined; none is appended.
- considerthese: no proposal taken this round; not claimed.

## Trial on real domain work

Vault, OpenBao and Python are the three vendors whose release clocks fired against the BASE registry. The trial reads the lane's knowledge entries that name these vendors and records, read-only, whether each version statement still matches the newest committed release identity (S089–S093). Results: §Wave settlement (trial seat K39ScribeTrial and scout K39ScoutFired).

## Routed to round 40 (not claimed)

- R38-D4 frozen-counter amendments (V1, V2, V4, V5, V6; M2, M3, M5, M6, G3) with their red witnesses.
- Ledger rows for the round-39 counters (`plans/round-39-c1.sh`, `plans/round-39-c2.sh`). They are not appended in round 39: adding rows moves the `claims=` count and the prose counts that bind to it (SKILL.md, PROVINCE.md, corpus/README.md), and that rebinding is its own round-38-style migration. The counters are re-run here by the frozen controls and the wave seats; the ledger rows are the named gap.
- The R38 untagged SCORECARD relabel: history outside the manifest, unclaimed.
- R37-V2 release-clock re-point (15 fired clocks).

## Non-author spot-check

Pending outside closure (the non-author integrator spot-check, LEARNING.md discernment rule). This lesson's Gate, the wave's verdicts and the corrections above are lane-authored and seat-authored; dispatched seats are lane evidence, not outside agreement.
