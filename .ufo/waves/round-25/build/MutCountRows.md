# MutCountRows — frozen-BASE mutation probe

Seat: `KagiR25.MutCountRows-2`. Axes: calibration, operability, freshness.
Revision: `4587c61a348e4528717404a68912c373f3ef4d03` (observed `rev-parse HEAD`, exit 0).
Sandbox/cwd: `/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/lane`; empty HOME: sibling `home`.
Production files were read-only; only this report was written in the real lane.

## Exact setup and bounded detectors

Setup commands, each exit 0 (dependent `&&` sequence):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home mkdir -p /fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/KagiR25.MutCountRows-2/lane
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home git -C /fast/scratch/kagi-r25/KagiR25.MutCountRows-2/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03
```
C and S below are the exact commands run from sandbox/cwd; neither ran on the real lane:
```sh
# C
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home timeout -k 5 300 bash corpus/claim-ledger.sh citations
# S
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home timeout -k 5 300 bash corpus/claim-ledger.sh --selftest
# H: exit 0 at pristine and after every mutation/restoration
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCountRows-2/home sha256sum SKILL.md corpus/README.md corpus/claim-ledger.tsv corpus/claim-ledger.sh
```
Expected detector: a doc/live-number invariant must reject a false stated count. A kill requires a passing pristine detector, mutant failure, and restored pass; baseline failure is inconclusive.
P = shared pristine baseline; M = independently applied one-digit mutation; R = exact restoration before the next mutation. Both C and S ran at P, every M, and every R: 18 detector executions total.

## Per-mutation outputs and verdicts

| Mutant (hash-anchored edit, frozen file:line) | Commands | C exits P/M/R | S exits P/M/R | Verdict |
|---|---|---|---|---|
| M1 `SKILL.md:46`: `63 stamps` → `64 stamps` | C and S | 1/1/1 | 0/0/0 | S: SURVIVED; C: INCONCLUSIVE |
| M2 `SKILL.md:47`: `--selftest` 70 cases → 71 cases | C and S | 1/1/1 | 0/0/0 | S: SURVIVED; C: INCONCLUSIVE |
| M3 `corpus/README.md:41`: surface declaration 35 rows → 36 rows | C and S | 1/1/1 | 0/0/0 | S: SURVIVED; C: INCONCLUSIVE |
| M4 `corpus/README.md:42`: runtime shape pins 22 rows → 23 rows | C and S | 1/1/1 | 0/0/0 | S: SURVIVED; C: INCONCLUSIVE |

Every phase produced exactly these last stdout lines; stderr was empty throughout:
```text
CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)
SELFTEST: PASS (151 cases)
```
C stdout included `UNRESOLVED LOG.md:210 .ufo/l0-questions.md (ufo)` and `UNRESOLVED LOG.md:366 .ufo/reports/round-8/aggregator.md (ufo)` already at P.
All nine C outputs were byte-identical: SHA-256 `fec9c3116bf4c424ff78fef06fa4b01fdfea1f7198605e42fac86c18a17fdb3b`.
All nine S outputs were byte-identical: SHA-256 `765d14ae859b438d8efc07c180f1a0924812780c35117cdfda38b285cc6e8189`.

## Before/mutant/restored SHA-256 evidence

| File | Pristine and every restored hash |
|---|---|
| `SKILL.md` | `26c1fda02b9e0af6d98c83509575774591afa9b420ed454ecbdcaa25539cbbaf` |
| `corpus/README.md` | `67ff6a13607dec1819c7aac62a1e3f9dc79883fcb828d4ceef1e8a763538658f` |
| `corpus/claim-ledger.tsv` (unchanged throughout) | `98e70b0ee9fe86d909d1eaac4d87e8836857885677e3ce1fce2d8e333aec8432` |
| `corpus/claim-ledger.sh` (unchanged throughout) | `27e4e158b64074d1211301b4cd5813371bc8f558953c5c4648f2566f63bb01ce` |

Mutant file hashes; all non-mutated targets retained their pristine hashes:
- M1 `SKILL.md`: `06c1477106dfccc923ad44b9938aed06b08c35a30e19dc9dfdaee1725ef3d85a`.
- M2 `SKILL.md`: `3c5b13efdc6cd62f90f060ddcc3e0f282e8461190b12bdf53715f73c5b8b3f9a`.
- M3 `corpus/README.md`: `1033d65f8680435e19f24b3e3320de897af691e7087b8d05f2ad965ec3cb38ae`.
- M4 `corpus/README.md`: `4c07d42574f441c1171184ffa3666d785440604d061713fabd58e0134fb5842f`.
Each mutation was reversed by an anchored edit; H confirmed exact original bytes after each reversal, including the final state.

## C1 evidence boundary

No mutation-specific failure occurred: four mutants survived S; C was already red and provides zero kills, not four passing controls. Thus these exercised checks do not demonstrate a doc-number/live-value binding. This supports a scoped `captured-by: none` finding, not a claim that every existing gate was green or that no byte-freshness gate could notice a doc edit.
Static pointers: `corpus/claim-ledger.sh:667-679,709-743` scans document citations; `:1178-1206` builds selftest fixtures. Live quantities are pinned independently in `corpus/claim-ledger.tsv:24-25,28,53-54`; those rows are not executed by S against the mutated corpus. `:22` explicitly documents the lone-clone citation failure.
M1 retains the existing `round 21` qualifier; whether that statement belongs to C1's current-tense population remains a separate contract decision. README historical ledger/stamp totals at `:64-65` were not mutated.
UNRUN: full `verify`, `cells`, new round-25 self-count/release-clock gates, and all host/vault/account/handler/CDP/op operations. No `--allow-host-rows`, installs, background jobs, subagents, commits, or real-lane index changes.
