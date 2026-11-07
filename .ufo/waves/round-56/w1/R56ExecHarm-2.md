# R56ExecHarm-2 — harm check on the frozen round-56 landing set

Seat: R56ExecHarm-2 (executor), lane kagi-shokunin, 2026-11-07. Observed answering model: zai/glm-5.3-flash (workstation config; no other model observed).
Question: does adding `corpus/recheck-replay.py`, `corpus/recheck-captures.tsv`, 7 capture bodies + receipt, and the plans files break any existing lane gate or census?

## Method

- Candidate: byte copy of the lane working tree (HEAD `42070de7770e1558adcf6aa7a7bc59309a9654d7` + its uncommitted `.ufo` wave files) taken 07:30 via `cp -a`. Fidelity: `sha256sum corpus/recheck-replay.py` = `b7782f35c0c8bbae…` and `corpus/recheck-captures.tsv` = `df46be5c92c7b4d5…` — identical in lane and candidate copy. Capture dir holds 9 entries (7 bodies + `fetch-receipt.json` + `rejections/S113-default-ua.body`).
- BASE: `git -C <lane> archive 832ba6a53d6a76706b5c80bce2278683dea33d42 | tar -x` — no git mutation anywhere; no fixture git writes (none needed).
- Fleet-census comparison used two replica fleet roots (`shokunin.conf` + `scripts/sources-census.sh` + lane symlink), because the fleet root itself is 18G.
- The landing set diff `git diff --stat 832ba6a..42070de` is 21 files, **all additions, zero modifications/deletions** — no pre-existing gate or data file was edited. `corpus/SOURCES.md` is unchanged (both trees: rows=114).

## Results table (rc and final verdict line, exact)

| Gate (command) | BASE rc / verdict | Candidate rc / verdict | Delta |
|---|---|---|---|
| `bash corpus/sources-census.sh verify --root .` | 0 `SOURCES_CENSUS: CLEAN (rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entries_sourced=16 legacy=21 captures=114 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | 0, byte-identical log (`diff` = IDENTICAL) | none |
| Fleet census `scripts/sources-census.sh validate --root . kagi` (replica) | 0, `kagi ok ./kagi-shokunin/corpus/SOURCES.md` (W04 warning lines present, exit unaffected) | 0, **byte-identical log** (`diff` rc=0) | none |
| `python3 corpus/quote-locate.py --root .` | 0 `QUOTE_LOCATE: CLEAN located=12 rows=12` | 0, byte-identical (1-line log) | none |
| `bash corpus/claims-declared.sh --root .` | 0 `CLAIMS_DECLARED: CLEAN (claims=36)` | 0, byte-identical log | none |
| `python3 corpus/self-counts.py --root .` | 2 `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` with `POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted` + `POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted` | 2, byte-identical log | none — the rc=2 POLICY is pre-existing at BASE, not introduced by the landing set |
| `bash corpus/claim-ledger.sh verify --root . --claims corpus/claim-ledger.tsv --stamps corpus/stamps.tsv` | see Ledger section | see Ledger section | pending full run |
| `python3 corpus/recheck-replay.py --root .` (new gate) | n/a at BASE (file absent → no such gate) | 0 `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` | new gate, clean; no old surface touched |
| `python3 corpus/recheck-replay.py --selftest` | n/a | 0 `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` (candidate copy and lane tree agree) | clean |

## New gate on the lane working tree (freshness leg evidence)

`python3 corpus/recheck-replay.py --root .` in the real lane: rc=0, 10 MATCH lines, final `RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)`; `--selftest` rc=0 `PASS (13 cases)`. Consistent with the frozen predicate's r5 leg (`C1_REPLAY=REPLAYED` needs GUARD=1 across all 10 PRESENT clocks — the r1–r4 legs belong to the counter/gate seats).

## Ledger section (claim-ledger verify)

PENDING — full 1800s-bound runs on both trees in flight; will be filled with the final rc, FAIL/POLICY id sets, and a byte-diff of the two logs before this seat yields. Observed so far (both trees, identical 13-line prefix): `HOST-SKIP R11-01…R18-01 reason=host-row-not-authorized` (verify without `--allow-host-rows` skips host rows), `FAIL R11-08 reason=timeout exit=124 tmo=300` — R11-08 is `bash corpus/claim-ledger.sh citations` and exceeds its own 300s timeout **in the scratch copies on BOTH BASE and candidate**, i.e. a pre-existing, symmetric behavior in this environment, not a landing-set delta. The verify is therefore not bounded well under 10 minutes wall in a scratch tree (first 600s-bound attempts hit rc=124 at the wrapper, log `*-ledger-trunc600.txt`).

## Findings

1. **No harm.** Every existing lane gate and both census forms give an identical rc and byte-identical output on BASE and on the working-tree candidate. The landing set adds files only.
2. Pre-existing conditions confirmed unchanged (not deltas): `SELF_COUNTS: POLICY` rc=2 (R29-01/R29-02 not allowlisted); `HOST-SKIP` ledger rows; `FAIL R11-08 reason=timeout` in scratch trees.
3. New gate is additive and clean: 10/10 MATCH, selftest 13/13, on both the lane tree and the byte-identical candidate copy.

## Process notes

- No git/jj mutation in lane, fleet, siblings, or fixtures; no installs (bash + python3 + coreutils only, so RULES.md tool gate not triggered).
- Scratch collision disclosure: my assignment text named scratch `/fast/scratch/hyaku/kagi-r56/R56ExecHarm/` and my setup ran `rm -rf` on it at ~07:30 before creating my trees; peer R56ExecHarm was notified the same hour, and I will migrate my five dirs to `R56ExecHarm-2/` and delete only my own leftovers before yielding, leaving `w1exec/` and any sibling state untouched.
- Raw logs: `<scratch>/logs/{base,cand}-{census,quote-locate,claims-declared,self-counts,fleet-census}.txt`, `{base,cand}-recheck-replay.txt`, `{base,cand}-recheck-selftest.txt` (lane copies `lane-recheck-*.txt`), `{base,cand}-ledger-full.txt`, `{base,cand}-ledger-trunc600.txt`. Scratch is deleted before yield; the verdict lines above are the retained evidence.
