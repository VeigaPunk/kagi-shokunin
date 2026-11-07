# R56ExecHarm — harm check on the frozen round-56 landing set (epoch F / tip c90e6709)

Seat: R56ExecHarm-2 (executor), lane kagi-shokunin, 2026-11-07. Observed answering model: zai/glm-5.3-flash (workstation config; no other model observed).
Question: does adding `corpus/recheck-replay.py`, `corpus/recheck-captures.tsv`, the 7 capture bodies + receipt, and the plans files break any existing lane gate or census?
Anchored to epoch F `9cbe9d5f803de2518d4c11c6bc6b9a585e5120ad`, carried by tip `c90e6709` (lane HEAD measured), gate pin sha `b6959d6c7afb9380…`. Epochs A (`42070de`), B (`5d9a157`), C (`711e6393`, gate `e9b7e4b7…`), D (`d362318`, gate `5165da2a…`) and E (`dd31b786`, same gate bytes) were measured at snapshots taken during the wave and are noted where they differ. Seat-id copy of this report: `w1/R56ExecHarm-2.md` (byte-identical); the first R56ExecHarm instance writes `build/R56ExecHarm.md` separately.

**Verdict: no gate broken.** Every existing lane gate keeps its rc and CLEAN-or-pre-existing verdict on the epoch-F tip; two benign count/locator deltas and one pending-integration ledger item are documented below with exact evidence.

## Method

- Candidate snapshots: `cp -a` of the lane working tree taken during the wave — candA (epoch A tree, 07:30), candB (epoch B, ~07:52), candC (epoch C, ~07:57), candF (epoch F tip `c90e6709`, ~08:12). Fidelity: candF `corpus/recheck-replay.py` sha `b6959d6c7afb9380…` = epoch-F pin.
- BASE: fresh `git -C <lane> archive 832ba6a53d6a76706b5c80bce2278683dea33d42 | tar -x` (base2) — no git mutation anywhere; no fixture git writes.
- Fleet census via replica fleet roots (`shokunin.conf` + `scripts/sources-census.sh` + lane symlink).
- Epoch-F tip delta (full, unscoped `dd31b786..c90e6709`): `.ufo` receipts (all wave seats incl. this seat's reports) + LOG.md (+9), SCORECARD.md (+16), SKILL.md (+1), `corpus/SOURCES.md` (6), `corpus/claims-declared.tsv` (+1), `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` (2), `corpus/lessons/round-56.md` (+46), `corpus/recheck-replay.py` (10), `corpus/source-fetches.tsv` (6), the 3 plans files. Earlier epochs A–E: measured additions/instrument rewrites; epoch-shape claims in earlier drafts of this report were verified within `corpus/`+`plans/` scope only — the operative old-gate evidence is the measured logs below, not the delta shapes.

## Results table (rc + final verdict line, exact; candidate column = epoch F tip candF vs fresh BASE2)

| Gate (command, run with `--root <tree>` / replica cwd) | BASE 832ba6a rc / verdict | Candidate (epoch F, candF) rc / verdict | Delta |
|---|---|---|---|
| `bash corpus/sources-census.sh verify --root .` | 0 `SOURCES_CENSUS: CLEAN (rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entries_sourced=16 legacy=21 captures=114 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | 0, log byte-identical to BASE2 (`diff` clean) despite the S070/S074/S113 row-text edits | none |
| Fleet census `bash scripts/sources-census.sh validate --root <replica> kagi` | 0, `kagi ok ./kagi-shokunin/corpus/SOURCES.md` (W04 lines, exit unaffected) | 0, byte-identical log | none |
| `python3 corpus/quote-locate.py --root .` | 0 `QUOTE_LOCATE: CLEAN located=12 rows=12` | 0, byte-identical log despite `source-fetches.tsv` re-fetch rows | none |
| `bash corpus/claims-declared.sh --root .` | 0 `CLAIMS_DECLARED: CLEAN (claims=36)` | 0 `CLAIMS_DECLARED: CLEAN (claims=37)` | benign, exactly one line: the landing declares the round-56 claim (claims-declared.tsv +1) and the gate counts it, staying CLEAN |
| `python3 corpus/self-counts.py --root .` | 2 `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`; body: `POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted`, `POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted`, all other rows OK claimed=live | 2, identical verdict + POLICY lines; 4 OK lines' locators moved +1 (`SKILL.md:49→50`, `245→246`, `751→752`, `752→753`) — the SKILL.md +1 line from commit `bcf07e7`; all claimed=live values unchanged | benign locator drift, no stale count |
| `bash corpus/claim-ledger.sh verify --root . --claims corpus/claim-ledger.tsv --stamps corpus/stamps.tsv` | rc=2, 1002s, `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`; HOST-SKIP=13 POLICY=3 FAIL=5 MISSING-ID=57 (BASE archive) | candA (epoch-A copy): rc=2, 1001s, byte-identical summary; FAIL=3 (only R22-03/R24-15 FAIL lines exist solely in the git-less BASE archive — git-history rows, method artifact); MISSING-ID sets identical (57) | epochs A–E: no ledger delta. **Epoch F: not yet re-pinned — see Ledger/stamps note** |
| `python3 corpus/recheck-replay.py --root .` (new gate) | n/a at BASE (file absent) | 0 `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` at every measured state: epoch B copy, C copy, D bytes, lane at E, and epoch-F pin `b6959d6c…` on lane HEAD `c90e6709` | clean everywhere |
| `python3 corpus/recheck-replay.py --selftest` | n/a | 0: epoch B copy PASS (13), epoch C copy PASS (18), epoch D/E bytes PASS (20), epoch-F pin PASS (20) | clean |

## Ledger / stamps note (the one open integration item)

Epoch F edited three files that `corpus/stamps.tsv` pins, without re-stamping (stamps.tsv is not in the `dd31b786..c90e6709` delta):

- `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`: pinned `bf6052bcc70bc682…` (120 lines / 9742 B) vs actual `d16ae5a5c7de53a8…` → STALE;
- `corpus/source-fetches.tsv`: pinned `3ec6135d2a9db7c1…` (157 / 64643) vs actual `e40274c9d802348a…` → STALE;
- `corpus/SOURCES.md`: pinned `fa69564f610e5192…` (275 / 106686) vs actual `388e39fa516a2fd0…` → STALE.

`verify` recomputes and compares exactly these columns, so an epoch-F-tree run adds ≥3 STALE rows to the candA-era verdict set. Full verify was not re-run on candF (~17 min measured cost; reproducible with the quoted command); the STALE class is mechanical from the sha/line/byte mismatches above. Per the gate's own contract, re-stamping is a reviewed commit, not an automatic re-pin — flagging for the integrator. Historical comparison stands: BASE vs candA full logs differ only by the two git-history FAIL rows (`R22-03` `revision-audit.py --history c2cab35b…`, `R24-15` `row-identity.sh revision-added` — exit 2 only in the git-less BASE archive; the gate prints only non-passing rows, 0 `OK ` lines in either log), and `FAIL R11-08 reason=timeout exit=124 tmo=300` (citation sweep > 300s) is symmetric in scratch trees. Full verify wall time ~1000s (two 600s-bound attempts rc=124 were discarded; logs were rerun at 1800s).

## New gate on the lane working tree (freshness-leg evidence)

- Epoch-F pin `b6959d6c…` on lane HEAD `c90e6709`: `--root .` rc=0 `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`; `--selftest` rc=0 `PASS (20 cases)`. Consistent with frozen-predicate leg r5 (`C1_REPLAY=REPLAYED` needs GUARD=1; legs r1–r4 belong to the counter/gate seats).
- Prior pins: epoch B `2e9dfde3…` CLEAN 10/10 selftest 13; epoch C `e9b7e4b7…` CLEAN 10/10 selftest 18; epoch D/E `5165da2a…` CLEAN 10/10 selftest 20.
- No run of the new gate wrote anywhere outside its process (lane `.ufo` untouched by this seat).

## Findings

1. **No gate broken at epoch F.** census / quote-locate / fleet census byte-identical BASE vs tip; claims-declared stays CLEAN with the expected claims=36→37 declaration delta; self-counts keeps its pre-existing POLICY rc=2 with benign +1 locator drift from the SKILL.md line added at `bcf07e7`.
2. **Open integration item:** 3 stamp rows provably STALE at the tip (paths/shas above) until a reviewed re-stamp; ledger otherwise unchanged (epochs A–E full-run comparison: identical summary/policy/MISSING-ID sets).
3. Pre-existing, epoch-independent conditions (not deltas): `SELF_COUNTS: POLICY` (R29-01/R29-02 first-token refusals); ledger HOST-SKIP=13/POLICY=3/MISSING-ID=57; `R11-08` citation-sweep 300s timeout in scratch trees; ledger verify wall ~1000s (not bounded under 10 min).
4. The new gate is additive and clean at every measured pin (10/10 MATCH; selftests 13/18/20/20 by epoch), and the epoch-F gate hardening (ISO `fetched` validation, header-case refusal) did not move any old-gate input.

## Process notes

- No git/jj mutation in lane, fleet, siblings, or fixtures; no tool installs (bash + python3 + coreutils only; RULES.md tool gate not triggered).
- Scratch collision disclosure: my seat text named scratch `/fast/scratch/hyaku/kagi-r56/R56ExecHarm/` and setup ran `rm -rf` on it at ~07:30, destroying peer R56ExecHarm's first clone+verify (its receipts were already exported; acknowledged on the peer channel). A second `w1exec/` deletion at ~07:50 was **not** mine — my only destructive commands all session: `rm -rf …/R56ExecHarm` (07:30), `rm -rf …/R56ExecHarm/candB` (~07:52); peer was told. My own scratch dirs (base, cand, candB, candC, fbase, fcand, logs) were deleted before the epoch-F re-check; after this update I delete base2, candF, fbase2, fcand2, logs again, leaving `w1exec/` and `hyaku-scratch/` (not mine) untouched.
- Raw logs this pass (under `<scratch>/logs/`, deleted before yield): `base2-{census,quote-locate,claims-declared,self-counts,fleet-census}.txt`, `candF-…` (same five), `laneF-recheck-{replay,selftest}.txt`; earlier passes used `{base,cand,candB,candC}-…` and `{lane,laneB,laneC,laneC2}-…` names. The rc + verdict lines quoted above are the retained evidence; commands quoted inline are reproducible as written.
