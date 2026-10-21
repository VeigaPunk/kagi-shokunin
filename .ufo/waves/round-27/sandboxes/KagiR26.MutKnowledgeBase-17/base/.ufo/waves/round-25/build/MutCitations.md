# Round-25 citation mutation probe

Seat: `KagiR25.MutCitations-2`.
Revision observed by `git rev-parse HEAD`: `4587c61a348e4528717404a68912c373f3ef4d03`.
Axes: calibration (selftest sensitivity), operability (citation routing), freshness (frozen-BASE replay; release clocks not tested).
Scope: three independent, single-line mutants in the private scratch clone; production code and Git index untouched.

## Commands and detector

Sandbox setup, exit 0, no stdout:
```sh
mkdir -p /fast/scratch/kagi-r25/KagiR25.MutCitations-2/home && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCitations-2/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/KagiR25.MutCitations-2/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCitations-2/home git -C /fast/scratch/kagi-r25/KagiR25.MutCitations-2/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03
```
All remaining commands used cwd `/fast/scratch/kagi-r25/KagiR25.MutCitations-2/lane`.
Initial revision/hash command, exit 0:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCitations-2/home git rev-parse HEAD && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCitations-2/home sha256sum corpus/claim-ledger.sh
```
Unchanged bounded behavioral detector, run on every state in the table:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCitations-2/home timeout -k 5s 45s bash corpus/claim-ledger.sh --selftest
```
Hash command, repeated on each mutant and each restored state, exit 0 every time:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.MutCitations-2/home sha256sum corpus/claim-ledger.sh
```
Expected detector: the existing `--selftest`; an existence/class-routing regression should make it fail, while pristine/restored bytes should pass. No detector or fixture changes were made.

## Mutants (all pointers are BASE `corpus/claim-ledger.sh`)

- **M1 — legacy UFO always resolves**, `cite_target`, line 634: replace `r=${t#ufo/}; [[ -e $ROOT/../.ufo/$r ]] && printf '%s' "$ROOT/../.ufo/$r" ;;` with `r=${t#ufo/}; printf '%s' "$ROOT/../.ufo/$r" ;;`. This bypasses existence only for `ufo/*`, not `.ufo/*`.
- **M2 — sibling resolution becomes lane-local**, `cite_target`, line 636: replace `[[ -e $ROOT/../$t ]] && printf '%s' "$ROOT/../$t" ;;` with `[[ -e $ROOT/$t ]] && printf '%s' "$ROOT/$t" ;;`.
- **M3 — sibling citations silently leave the checked population**, `cite_class`, line 614: replace `*-shokunin/*) printf 'sibling' ;;` with `*-shokunin/*) return 1 ;;`. Caller line 718 then skips those tokens.
Each mutation was applied using a surgical edit and reversed before starting the next mutant.

## Actual outputs and verdicts

| State, in execution order | Exit | Final stdout line | Verdict |
|---|---:|---|---|
| Pristine | 0 | `SELFTEST: PASS (151 cases)` | Valid baseline |
| M1 | 0 | `SELFTEST: PASS (151 cases)` | SURVIVED |
| Restored after M1 | 0 | `SELFTEST: PASS (151 cases)` | Restoration control |
| M2 | 0 | `SELFTEST: PASS (151 cases)` | SURVIVED |
| Restored after M2 | 0 | `SELFTEST: PASS (151 cases)` | Restoration control |
| M3 | 0 | `SELFTEST: PASS (151 cases)` | SURVIVED |
| Restored after M3 | 0 | `SELFTEST: PASS (151 cases)` | Restoration control |
All seven runs completed in 3.02–3.10 seconds; no timeout or baseline failure.
Every run also printed `ok-case  28 cite-shorthand                     exit=0`, `ok-case  139 cite-ufo-lane-first                exit=0`, and `ok-case  140 cite-ufo-lane-miss                 exit=1`.
Result: **3 survived, 0 killed, 0 inconclusive**. Survival is a coverage finding, not permission to change citation semantics.

## Hashes and exact restoration

SHA-256 of `corpus/claim-ledger.sh`:
- Pristine B0: `27e4e158b64074d1211301b4cd5813371bc8f558953c5c4648f2566f63bb01ce`.
- M1: `1be492b1dc0845d80bfadb8236847100f0817f7bb4c0110db92803039f292ab6`.
- M2: `06f6636f21e50e8479e36e7ad12096310b096bafa3acf7f262d431376d80e7d3`.
- M3: `73bde5449cd28a0e8a2934cc3c7597abb458de06017b911a206173af91daaa1a`.
Before each mutant and after each inverse edit the observed hash was B0; the final scratch file is byte-restored to B0.

## Coverage findings for C2

- [INFERENCE] M1 survives because the legacy `ufo/reports/x.md` fixture is present (lines 1336/1341); the negative UFO test uses `.ufo/waves/lane-only/nope.md` (1369/1631), a different resolver branch. Missing legacy-`ufo/` existence is not guarded by this probe's passing selftest.
- [INFERENCE] M2/M3 survive because the apparent cross-lane fixture is `kagi-selftest/x.md:3` (1335/1341), which does **not** match the actual sibling classifier `*-shokunin/*` (614). `cite-shorthand` (1502) asserts only CLEAN, not the expected citation count or sibling class. Thus that fixture cannot exercise either mutated sibling branch.
- C2 after implementation, real-tree `verify`/`cells`, and C1/C3 checks: **UNRUN**. This report measures only BASE selftest coverage; no gate behavior was repaired or integrated.
- Tools installed/updated: none. No credentials, vault/account/handler/CDP operations, host configuration changes, or sibling edits.
