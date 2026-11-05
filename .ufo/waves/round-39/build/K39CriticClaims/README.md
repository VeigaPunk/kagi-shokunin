# K39CriticClaims — receipt index (2026-11-05)

Seat: K39CriticClaims (critic, falsification of claims/prose in plans/round-39.md).
Candidate 6742fdef0e261dd06a38a0fb0b66b1bc027d1bee (lane HEAD, tracked tree clean);
BASE 06144518d3b3745e7fdf82d4207b4a3b5532a7a7; predeclaration
1909e3876341cc90246516886def37a7c9ea92f9; frozen plan 7c11e769cd7c2450cf46faabcd3b43fca993f388.
Extractions: git archive of candidate and predeclaration (and BASE, for baseline runs) into
/fast/scratch/hyaku/kagi-r39/K39CriticClaims/ — deleted after receipt preservation.
No tools installed (existing bash/git/python3 only). No lane/fleet/sibling mutations; all
fixtures lived in seat scratch; every git call used explicit -C; no commits made.

| receipt | content |
|---|---|
| 01-prefreeze-gate.txt | prefreeze gate re-run at predeclaration: PREFREEZE CLEAN 4/4; BASE0 structural absence |
| 02-counters-gates-candidate.txt | c1=3, c2=3, anchor-pins CLEAN pins=3, claims-declared CLEAN claims=2, census rows=94, r37-counter 0, release clock unchanged counts |
| 03-pins-vs-base.txt | the three pins == sha256 of BASE registry anchor cells; anchor cells unchanged BASE->candidate |
| 04-s094-provenance.txt | S094 capture digest == fetch row == fleet blob at f47ad6ba; line 116 quote located |
| 05-laneguard.txt | implemented form works, old documented form refuses rc=2, selftest detected=3 mutants=3 clean=ok |
| 06-sweeps.txt | self-description sweep: BASE n=3 (SD6=3) reproduced; HEAD n=9 (SD5=3 SD6=6); full hit lists |
| 07-citations-diff.txt | UNRESOLVED citations: BASE 3 vs HEAD 6, exact lines |
| 08-fleet-layout-base.txt | layout-dependence: same BASE bytes read 3 (lone) vs 100 (fleet-sim upper bound); attribution triage |
| 09-ceiling-forgery.txt | QM40 coordinated pin+row rewrite -> CLEAN (ceiling confirmed); single-sided tamper -> DRIFT; forged gate -> counter 0 |
| 10-manifest-freshstart.txt | fleet MANIFEST.json: kagi rounds 36/38 rejected-honest-stop; ids 1321/1328 absent; round-37 plan counted round-36 as rejected |
| 11-s036-gap.txt | S036 = fourth superseded feed anchor; rewrite invisible to R37 counter, unpinned by C1; round-37 lesson listed it |
| 12-census-receipts.txt | census/ dir empty vs plan "copied to the wave dir"; 19 W04 warnings vs lesson "one (S091)"; migration file missing; four census ledger rows stale |
| 13-seat-receipts-crosscheck.txt | K39ExecDeclared / K39ConnOverlap / K39ReviewDeclared receipts consistent with my runs |

Report: .ufo/waves/round-39/build/K39CriticClaims.md
