# ExecReplay — round 35 C1 calibration replay report (seat ExecReplay-2)

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (all paths below are relative to it).
BASE `063c407494276d0c616e6c712a2e5d7aeb7e3768`; lane HEAD `83ba8d1aac70f0f04a2357471def9b19b2bdc794`
("round-35: freeze producer integrity claim"); controls commit `63ba87afce53842007ec27c09e3469132d149abd`
("round-35: execute predeclaration public-path controls") is a descendant of BASE and ancestor of HEAD
(verified with `git merge-base --is-ancestor` both directions). No clone was made (0 of max 1); all runs used
`git show`/`git archive` against the lane repo, read-only. No git/jj mutation anywhere. No production edits.
Scratch /fast/scratch/hyaku/kagi-r35/ExecReplay/ was used and removed before yield (all receipts durable in the
seat dir). Tools: preinstalled python3/bash/git only — no install performed (pacman transactions paused per
dispatch; nothing was needed beyond the base system).

## A. Frozen-controls replay through the BASE public gate (before state)

Command (from lane root, frozen instrument unmodified, gate = BASE bytes):

```
python3 .ufo/waves/round-35/controls/measure.py \
  --script /fast/scratch/hyaku/kagi-r35/ExecReplay/base-prefreeze-control.sh \
  --base 063c407494276d0c616e6c712a2e5d7aeb7e3768 \
  --out .ufo/waves/round-35/build/ExecReplay/receipts/replay.json \
  --work /fast/scratch/hyaku/kagi-r35/ExecReplay/work
```

Raw stdout: `MEASUREMENT_RESULT mismatches=5 invalid_false_clean=5 positive_matches=2 cases=9`, rc=1.
The gate script was extracted with `git show 063c4074…:corpus/prefreeze-control.sh`; sha256
`ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a` = `script_sha256` in the frozen
`before.json` and `producer_sha256` in `input-identity.json`. Instrument sha256 (working tree) =
`e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17` = `input-identity.json` value, and
`git show 63ba87af:…/measure.py` hashes identically (instrument unchanged since predeclaration).

Case-by-case equality against the frozen predeclaration receipt (receipts/comparison-vs-before.txt):
for all nine cases rc, full stdout and stderr are byte-identical to `.ufo/waves/round-35/controls/before.json`;
totals 5/5/2 on both sides. Five false-CLEAN witnesses reproduced exactly: setup-number, failed-number,
diagnostic-number, stderr-number, clean-forgery each printed `OK <id> expect=0 measured=0` +
`PREFREEZE: CLEAN (controls=1 mismatch=0)` exit 0 at BASE; empty-output refused (SETUP noresult, exit 2);
wrong-count refused (MISMATCH, exit 1); valid-zero and grep-empty accepted (exit 0).

## B. BASE prefreeze --selftest

`TMPDIR=<scratch>/tmp bash <BASE gate copy> --selftest` → raw stdout in receipts/selftest.stdout, rc in
receipts/selftest.rc: `PREFREEZE_SELFTEST: PASS (12 cases)`, rc=0, empty stderr. All twelve CASE lines "ok".

## C. Independent direct replay (own driver, instrument untouched)

receipts/direct-replay.sh (listed in report appendix) rebuilt each one-row TSV exactly as the frozen instrument
does (`id<TAB>0<TAB>command`) and invoked the BASE gate per case. Per-case raw stdout/stderr/rc:
receipts/direct/{case}.{stdout,stderr,rc} (27 files). Result identical to the instrument run on all nine cases
(rc, stdout, stderr byte-equal). Honesty note: the first driver revision set the TSV expect column to the
gate-expected rc instead of 0 (instrument writes expect=0 always); its outputs were deleted and the corrected
driver rerun; final receipts are the corrected ones, verified equal to receipts/replay.json.

## D. Candidate observation (installed mid-wave by L1; read-only)

At dispatch start the working-tree `corpus/prefreeze-control.sh` still hashed `ca338da7…` (BASE bytes). During
this seat's run the lane tree gained the candidate: working-tree sha256 became
`2a0986d4e0bce5e2383ef60afe68b84036960045e7177870333b5de5424edeea` (15971 bytes, mtime
2026-11-04 15:30:48 -0300, `git status`: ` M corpus/prefreeze-control.sh`). The same frozen instrument run
verbatim (`--script corpus/prefreeze-control.sh`, out to scratch) then printed
`MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`, rc=0 — the exact C1
predicate — with all nine `match=true`. Raw JSON: receipts/candidate-observation.json (its `script_sha256`
field is the 2a0986d4 bytes). This is my independent observation of the installed candidate, NOT the official
counter; L1 owns `.ufo/waves/round-35/final/after.json`.

Per-case candidate verdicts (last stdout line): the five invalid cases and empty-output →
`PREFREEZE: SETUP noresult` rc2; valid-zero and grep-empty → `PREFREEZE: CLEAN (controls=1 mismatch=0)` rc0;
wrong-count → `PREFREEZE: MISMATCH (controls=1 mismatch=1)` rc1. Positive and refusal controls retained;
five false-CLEAN → zero.

## E. Exact BASE populations (git show / archive; receipts/base-populations.txt)

1. registry — corpus/SOURCES.md `## Registry` rows (`^\| S[0-9]{3} `): **88**
2. sourced — corpus/knowledge/*.md with `^source:` header: **14**
3. legacy — corpus/knowledge/*.md lacking `^source:` (README's exact command): **21** — adjacency-breadth,
   adjacency-scope, cdp-bridge-1password, checklist-execution, claim-ledger, config-layering,
   control-plane-hardening, credential-isolation, drift-gate, handler-on-disk-state, handler-trust-boundary,
   janitor-command-surface, janitor-env-contract, janitor-lifecycle, op-cli-surface, op-env-refs,
   op-ref-consumption, substrate-deferral, surface-census, tac-evidence-integrity, transcript-hygiene
   (prefreeze-controls.md is NOT in the bucket at BASE: its `source:` header exists)
4. capture — corpus/source-fetches.tsv data rows: **88**; knowledge entries total **35**
5. Context: claim-ledger.tsv data rows **79**, stamps.tsv **111**, self-counts.tsv **62**;
   `claim-ledger.sh docs` on the BASE extraction: `DOC_AUDIT: CLEAN (entries=35 row_linked=32 by_hand=3 …)` exit 0
   (receipts/claim-ledger-docs-base.stdout). A sibling seat's untracked
   controls/populations-independent.json (read as data) states 88/14/21/88 + 35 — all equal my executed counts.

## F. Nine-case contract coherence (independent derivation from the plan's contract sentence)

Plan contract: accept only a single nonempty integer stdout line with no stderr and rc0, or rc1 with zero
(grep count); empty output, diagnostics, SETUP/POLICY-shaped lines and other rc fail closed with NORESULT and
final SETUP exit2. Derived expectation per frozen case, checked against the frozen instrument literals:

| case | producer behavior | derived under new contract | frozen expected | coherent |
|---|---|---|---|---|
| setup-number | "PREFREEZE: SETUP producer 0", exit 2 | non-integer-shaped line, rc∉{0,1} → NORESULT, SETUP 2 | rc2 NORESULT | yes |
| failed-number | "0", exit 127 | rc∉{0,1} → fail closed NORESULT, SETUP 2 | rc2 NORESULT | yes |
| diagnostic-number | "FAIL rows=0", rc0 | not a bare integer line → NORESULT, SETUP 2 | rc2 NORESULT | yes |
| stderr-number | "0" + stderr text | stderr nonempty → NORESULT, SETUP 2 | rc2 NORESULT | yes |
| valid-zero | "0", rc0, clean | accepted integer, 0==expect → OK rc0 | rc0 OK | yes |
| grep-empty | grep -c prints 0, exit 1 | rc1-with-zero exception → OK rc0 | rc0 OK | yes |
| empty-output | no output | empty → NORESULT, SETUP 2 | rc2 NORESULT | yes |
| wrong-count | "1", rc0 | valid integer, 1≠0 → MISMATCH rc1 | rc1 MISMATCH | yes |
| clean-forgery | "PREFREEZE: CLEAN (controls=0 mismatch=0)", rc0 | non-integer-shaped line → NORESULT, SETUP 2 | rc2 NORESULT | yes |

All nine frozen expectations are coherent with the declared contract; the two valid controls are retained as
acceptances, the two refusal controls stay refusals, and the five witnesses flip from false CLEAN to refused
NORESULT — observed, not inferred, on the installed candidate (§D). The plan's named residual unsoundness (a
dishonest producer emitting a bare integer with rc0, e.g. via failure-masking pipeline, passes) is consistent
with the contract sentence; no universal soundness is claimed.

## Verdict-relevant findings

1. Before-state reproduced byte-identically (§A): the five false-CLEAN certification at BASE is real and
   exactly the predeclared receipt.
2. The exact C1 predicate was observed green on candidate bytes 2a0986d4 through the unmodified frozen
   instrument, all nine cases matched (§D) — supporting, not replacing, L1's official counter.
3. BASE selftest green (12 cases) at BASE bytes (§B).
4. Populations measured exactly at BASE (§E); reporting invariants only — no claim targets asserted by this seat.
5. Instrument and producer identity match input-identity.json; instrument unchanged since 63ba87af.
6. Non-owned surfaces untouched: R25-02 FAIL / R29-01 / R29-02 POLICY boundaries not exercised or altered;
   SD6 bytes, lessons, history untouched; sibling files (working-tree QUALITY.md/SOURCES.md modifications,
   lessons/round-35.md, build-dispatch artifacts) left alone.

## Receipts (all under .ufo/waves/round-35/build/ExecReplay/receipts/)

replay.json (instrument --out, BASE gate) · comparison-vs-before.txt · candidate-observation.json ·
selftest.stdout · selftest.rc · direct/ (27 per-case files) · claim-ledger-docs-base.{stdout,stderr} ·
base-populations.txt · input-hashes.txt (BASE gate copy, replay.json, candidate bytes, working-tree producer,
measure.py, before.json, input-identity.json, plan, nine TSVs). selftest.stderr was empty (scratch-only).

Report trailer paths (lane-relative): .ufo/waves/round-35/build/ExecReplay/receipts/replay.json;
.ufo/waves/round-35/build/ExecReplay/receipts/comparison-vs-before.txt;
.ufo/waves/round-35/build/ExecReplay/receipts/candidate-observation.json;
.ufo/waves/round-35/build/ExecReplay/receipts/selftest.stdout;
.ufo/waves/round-35/build/ExecReplay/receipts/direct/;
.ufo/waves/round-35/build/ExecReplay/receipts/claim-ledger-docs-base.stdout;
.ufo/waves/round-35/build/ExecReplay/receipts/base-populations.txt;
.ufo/waves/round-35/build/ExecReplay/receipts/input-hashes.txt
