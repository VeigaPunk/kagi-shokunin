# K43ReviewC2 — §C2 pre-measurement attacks (kagi round 43, attempt 1)

Clone: `/fast/scratch/hyaku/kagi-r43/K43ReviewC2/work`, `git clone --shared` of the lane, detached at
`dd6ccb92bf04a061e9f1e66913d15f097397b1b3` (= lane `master` tip; `git rev-parse --show-toplevel` verified equal
to the clone before any write; initial `git status --porcelain` = 0 lines). Scratch receipt snapshots taken from
`git show dd6ccb92:<path>`. Gate sources and the counter receipt are in `receipts/` next to this file.
Lane master == dd6ccb92 confirmed (`git log --oneline -3 master`: dd6ccb9, a918025, 5f3566c).

## Attack 1 — BASE premise: the 8 manifest receipts re-derive byte-identically

- **Claim** (plan §C2): the eight frozen manifest receipts (3 under `.ufo/waves/round-42/controls/`, 5 under
  `.ufo/waves/round-41/controls/`) re-derive byte-identically from the clone's committed runners; a plain re-run
  AND a re-run after deleting every file under the two controls dirs both reproduce them byte-identically.
- **Command**: in clone root —
  `HYAKU_SCRATCH=$S bash plans/round-42-controls.sh; echo R42-RC=$?; HYAKU_SCRATCH=$S bash plans/round-41-controls.sh; echo R41-RC=$?`
  run (1) with nothing deleted, then (2) after `find .ufo/waves/round-42/controls .ufo/waves/round-41/controls -type f -delete`
  (11 files → 0), then `cmp -s` per file against the committed-byte snapshots.
- **Output run 1**: r42 last line `C2 BASE N=1`, `R42-RC=0`; r41 last line `C2 BASE N=1`, `R41-RC=0`.
  r42 full stdout: `CONTROL c1-blanket-refuse N=0 / CONTROL c1-blanket-accept N=0 / C1 BASE N=5 / C2 derivation D=1 / C2 BASE N=1`;
  r41: `CONTROL c1-blanket-refuse N=0 / CONTROL c1-blanket-accept N=0 / CONTROL c1-no-gate N=0 / CONTROL c2-decoy-superseded N=2 / C2 BASE N=1`.
  cmp: **8/8 MATCH**; DIFF only on the excluded `c1-base.txt` (4→5) and `c2-base.txt` (0→1); `c2-worktree-at-base.txt` MATCH (no runner writes it).
- **Output run 2**: `files-after-delete=0`; identical runner stdout, `R42-RC=0`, `R41-RC=0`; cmp **8/8 MATCH**;
  `c1-base rederived=5`, `c2-base rederived=1`, `c2-worktree-at-base absent (no runner writes it)`.
- **Verdict**: BASE premise **HOLDS at dd6ccb92** — zero deviations in the manifest set in both modes; the
  exclusions behave exactly as the counter header declares. (Prose caveat, see Attack 5b: this verified the
  revision the receipts live at, i.e. dd6ccb92, not claim BASE 5f3566c.)

## Attack 2 — the excluded receipts are a real exclusion, not cosmetic

- **Claim**: `.ufo/waves/round-42/controls/c1-base.txt` committed 4, re-derives 5 at HEAD; `c2-base.txt` committed 0, re-derives 1.
- **Command**: `git -C $W show dd6ccb92:.ufo/waves/round-42/controls/c1-base.txt` (and `c2-base.txt`); after run 2, `cat` of the re-derived files; `git -C $W status --porcelain -- <two dirs>` after run 1.
- **Output**: `c1-base committed=4 rederived=5`; `c2-base committed=0 rederived=1`. Porcelain after run 1:
  ` M .ufo/waves/round-42/controls/c1-base.txt`, ` M .ufo/waves/round-42/controls/c2-base.txt` — exactly the two exclusions.
- **Verdict**: exclusion is **REAL**. Including either excluded file in the manifest would make P1 impossible;
  the 8-file manifest is the maximal honestly re-derivable set. Side observation: the committed runners rewrite
  the excluded receipts in place, so any bare re-run of `plans/round-42-controls.sh` dirties two committed files —
  the gate's restore duty is load-bearing, not decorative.

## Attack 3 — shape-keyed gate passes the counter (named ceiling)

- **Claim** (§C2 Declared ceilings): "a gate that special-cases the three invocation shapes passes the counter."
- **Gate** (`receipts/shape-keyed.sh`): parses `--clone <dir>`; exits 1 iff
  `cmp -s <(git -C "$C" show HEAD:plans/round-42-controls.sh) "$C/plans/round-42-controls.sh"` fails OR
  `c2-derivation-D.txt` does not read exactly `1`; otherwise **replays nothing** and exits 0.
- **Command**: `CONTROLS_REPLAY_GATE=$S/gates/shape-keyed.sh HYAKU_SCRATCH=$S bash plans/round-43-c2.sh` (run in the dd6ccb92 clone).
- **Output**: counter printed `1`, rc 0 (receipt: `receipts/c2-shape-keyed.txt`: `... 1 RC=0`).
  Direct run on the clean clone: `SHAPE-KEYED-DIRECT-RC=0` with zero verification performed.
  Negative controls: `blanket-0.sh` override → counter `0`; `blanket-1.sh` override → counter `0`
  (matches committed predeclaration receipts `c2-blanket-0`=0, `c2-blanket-1`=0).
- **Verdict**: ceiling **CONFIRMED**. The counter refuses blanket gates but accepts a gate that replays nothing
  and merely shape-matches clean/stale/silent. The candidate `corpus/controls-replay.sh`'s default verification
  remains reviewed-as-code, exactly as declared. Fresh nuance worth naming: a shape-keyed gate needs only TWO
  probes (r42 runner bytes vs HEAD; D==1), not three — the stale shape is detected by the D probe and the silent
  shape by the runner-bytes probe; the clean shape needs no probe at all (default exit 0).

## Attack 4 — restore duty on direct runs

- **Claim**: after a direct `bash <gate> --clone <clone>` run, `git status --porcelain -- .ufo/waves/round-42/controls .ufo/waves/round-41/controls` is empty.
- **Gate** (`receipts/min-correct.sh`): snapshot every file under both controls dirs → delete them → run both
  committed runners (each must exit 0) → require the 8 manifest files to byte-match their snapshots → restore the
  snapshot → exit 0 clean / 1 refused / 2 setup.
- **Commands + output** (clean clone first restored to committed bytes; pre-restore porcelain `[]`):
  - clean: `MINCORRECT-CLEAN-RC=0`; post porcelain `[]` ✔
  - stale copy (D:=`2`): stderr `refused: byte-diff .ufo/waves/round-42/controls/c2-derivation-D.txt`, `MINCORRECT-STALE-RC=1`;
    porcelain after: ` M c1-base.txt`, ` M c2-base.txt`, ` D c2-worktree-at-base.txt` ✘
  - silent copy (r42 runner := `exit 0`): stderr `refused: missing .ufo/waves/round-42/controls/c1-control-refuse-all.txt`,
    `MINCORRECT-SILENT-RC=1`; porcelain after: six ` D` entries (all r42-dir receipts) ✘
- **Verdict**: **DEFECT (fresh, survives frozen checks, fix belongs in the candidate gate)**. The plan's
  candidate-rule step order — "require every manifest file to exist again and byte-match (cmp) its snapshot;
  restore the snapshot" — puts restore *after* the compare, so a literal implementation leaves a REFUSED fixture
  tree stripped/dirty (shown above). Frozen kill rule (c) pins only the clean-clone direct run
  (`final/c2-replay-direct.txt`), which does restore cleanly, so the frozen checks are not violated — but kill
  rule (c)'s named duty ("the restore duty") is only honestly met if the candidate
  `corpus/controls-replay.sh` restores on ALL exit paths (restore in an EXIT trap or before every `exit 1`).
  Routed to the executor implementing the candidate gate; no plan text change needed for the frozen checks to pass.

## Attack 5 — predicate wording: plan §C2 sentence vs counter header

- **(a) Receipt-name mismatch (fresh, cosmetic)**: plan §Controls and the counter header cite
  `.ufo/waves/round-43/controls/c2-base.txt` and every round-43 receipt with a `.txt` suffix; the committed
  predeclaration files are **extensionless** — `git ls-tree -r --name-only dd6ccb92 -- .ufo/waves/round-43/`
  lists `c2-base`, `c2-blanket-0`, `c1-old-real`, … with only `measured-at.txt` carrying an extension (identical
  listing at a918025). Values match the frozen table (`c2-base`=0, `c2-blanket-0`=0, `c2-blanket-1`=0,
  `c3-base`=0, `c3-pos`=1, `c3-blanket`=4; `measured-at.txt` = 5f3566c…). Non-verdict-bearing traceability break;
  a reader following the header's citation finds no such file.
- **(b) "at the BASE HEAD" ambiguity**: §C2 prose says the eight receipts "re-derive byte-identically at the BASE
  HEAD"; the counter header says "from the clone's committed runners" at "the revision they live at". Claim BASE
  5f3566c ≠ receipts' commit dd6ccb92. The header reading is operative and is what Attack 1 verified (8/8 at
  dd6ccb92). Verdict: wording gap only; the round report should name dd6ccb92 as the re-derivation revision.
- **(c) Exit-code exactness**: the sentence "exits 0 … exits 1 … exits 1" is enforced as exact rc equality in
  `plans/round-43-c2.sh` (`[ "$P1" = "0" ] && [ "$N1" = "1" ] && [ "$N2" = "1" ]`); a gate exiting 2 on a fixture
  reads N=0 (fail-closed, matches the header's fail-closed note). No defect.
- **(d) "default HEAD"**: the counter's no-arg candidate is `git -C "$REPO" rev-parse HEAD` of the repo holding
  the counter script, so "at the candidate" requires the L1 to run it at the candidate commit or pass `$1`
  explicitly; the receipt should record which was used. Minor wording gap; no functional defect.

## Verification record (honesty)

- Every command above was run in the sandbox clone at dd6ccb92; exit codes and last lines quoted verbatim.
- NOT run: any candidate measurement (`corpus/controls-replay.sh` does not exist at dd6ccb92 — verified via
  `git ls-tree dd6ccb92 -- corpus/controls-replay.sh` → empty), any C1/C3 counter, the lane's full claim-ledger
  verify, and re-derivation at 5f3566c (out of item scope; the receipts live at dd6ccb92).
- Tooling: no packages installed or upgraded this seat (pacman paused per orchestrator ruling; nothing needed).
- Scratch dir deleted before yield: `rm -rf -- /fast/scratch/hyaku/kagi-r43/K43ReviewC2`.
