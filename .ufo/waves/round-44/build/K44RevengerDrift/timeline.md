# Round-42-era receipt drift — reconstruction (seat K44RevengerDrift, round 44)

Read-only reconstruction at the round-44 predeclaration `ae9e9eb` (sandbox shared clone of the lane,
`git rev-parse --show-toplevel` asserted before any write). Every claim below is commit-level evidence
(`evidence/e9-provenance.txt`) or an executed re-measurement (`evidence/e1..e8`). All times 2026-11-05
UTC-3. Confidence: **high** for every dated row (command + receipt shown); the single inference is
marked and is Q4's "who typed the command".

## Answer summary (the four questions)

1. **Which commit wrote/committed each receipt.** All three — `.ufo/waves/round-42/controls/c1-base.txt`,
   `c2-base.txt`, `c2-worktree-at-base.txt` — were created and committed by the round-42 predeclaration
   commit **`98dd4de`** (13:23:22, same second as its parent `e8265c0`, the r41 verifier spot-check):
   measured by the L1 premeasurement, committed alone, and never touched again (`git log --diff-filter=A`
   = full history = one commit for each path; log `98dd4de..5f3566c` on the controls dir is empty).
   The amendments `fdbb83d` (A1) and `ca0c6a9` (A2) and the candidate `d00a543` changed **counters and
   runners, never the receipts** (commit stats in e9).
2. **Why `plans/round-42-c1.sh` reads 4 at `e8265c0` but 5 at `5f3566c`.** The counter's only variable
   across that window is the gate bytes it loads from cwd (`corpus/expect-journal.sh`); its inputs are
   pinned (`BASE=6cc8850` ledger, `P0=6f1588c` ledger, journal `.ufo/waves/round-40/expectation-migrations.json`).
   **`d00a543`** (the r42 candidate) is the *only* commit touching the gate in `e8265c0..5f3566c`; it adds
   the unconditional `DELETED <ID>` refusal class and the F5 selftest case. F5 is the P0 ledger with row
   **`R17-02`** deleted (unjournaled). The r41 gate accepts F5 → N=4; the d00a543 gate refuses
   `DELETED R17-02` → N=5. Row id that moved the reading: **R17-02**. The round-41 landing's
   `expectation-migrations.json` is *not* the cause: it is already in the tree at `e8265c0` (it is an
   ancestor), and it touches R13-01/R21-02/R24-06/R31-02/R33-02/R34-03 — none of which enters the
   counter's pinned fixtures. Executed proof: e1 (birth bytes at `98dd4de`, gate identical to
   `e8265c0`) → **4** rc 0; e2 (committed bytes at `5f3566c`) → **5** rc 0.
3. **Why the r42 runner's `c2-base` line reads 1 at `5f3566c` while the committed receipt reads 0.**
   The committed 0 was measured at the claim BASE: birth counter bytes (pre-A1/A2, at `98dd4de`),
   `CAND=e8265c0` — the clone's committed `plans/round-41-controls.sh` still measured the **worktree**,
   its C2 BASE leg wrote **3**, the frozen derivation D=1, so N=0 (e3: **0** rc 0). At `5f3566c` the same
   command reads the candidate-fixed tree: `d00a543` switched the runner's C2 BASE leg to
   `git archive 19025d9` + the counter frozen at `5142b52`, so it now writes R=1=D → N=1 (e5: **1** rc 0;
   e6: D=1 rc 0; e8: runner leg receipt tail **1** rc 0). The one commit that moves the reading is
   **`d00a543`**. Amendment A2 (`ca0c6a9`) did *not* change this reading — it closed a different hole:
   pre-A2, the counter read the clone's receipt *after* running the runner without deleting it, so a
   do-nothing runner (writes nothing, exit 0) left the committed r41 receipt `1` in the clone and read
   N=1 with zero work — the critic's stale-receipt attack F1
   (`.ufo/waves/round-42/build/K42CriticClaims/receipt-stale-receipt-attack.txt`, committed at
   `d00a543`). A2 deletes the receipt first and requires runner rc 0; the plan's "committed receipts
   re-measure identically" claim verified: post-A2 bytes at `ca0c6a9`, `CAND=e8265c0` → **0** (e4).
4. **`c2-worktree-at-base.txt` — who wrote it, what it measured.** Content **3** = the *worktree*
   reading of the round-41 C2 counter at the claim BASE `e8265c0` (the tree contains the landed r41
   normalizer work, so a=1,b=1,c=1), against the committed r41 receipt's **1** (written at `5142b52`,
   the r41 predeclaration, from the then-worktree at `19025d9`, where a=0,b=0,c=1). That gap —
   "the receipt is not re-derivable from the revision it names" — is **M41-4** (r41 verifier spot-check
   routed item 3 in the committed text, cited as item 6/critic defect 1 in `plans/round-42.md` §C2;
   the r42 lesson mines it as M41-4 with the three-values-for-one-named-receipt table row). Writer:
   **no committed runner writes this path** — sweep of `plans/*.sh corpus/*.sh` is empty at
   `98dd4de`, `e8265c0`, `5f3566c`, `d54109d`, `ae9e9eb` and across all history (`git log -S` hits are
   docs/plan/receipt commits only). `plans/round-42-controls.sh` writes exactly five receipts, not this
   one. [INFERENCE] It was written manually by the round-42 L1 premeasurement — the natural command is
   the committed r41 runner's C2 BASE leg (or the direct counter) in the lane worktree at `e8265c0`;
   both reproduce the value exactly (e7: direct counter **3** rc 0; committed r41 runner leg rc 0,
   receipt tail **3**). The physical command itself is not reconstructible from committed bytes —
   which is precisely why the register's row-3 disposition token is
   `not-written-by-any-committed-runner`, not a runner name.

## Timeline for the round-44 lesson's register narrative

| # | commit | time | what moved |
|---|--------|------|-----------|
| 1 | `6cc8850` | 09:46:50 | r39 verifier spot-check; r40 claim BASE. `corpus/expect-journal.sh` **absent** here (gate born round 41); the r42 C1 counter run at this rev prints `0` exit 0 (missing-gate leg) — a naive at-BASE re-derivation trap, not a drift reading. `6cc8850` is the C1 counter's *ledger* pin (fixture base), never a measurement BASE of `c1-base.txt`. |
| 2 | `6f1588c` | 11:58:09 | r40 landing receipts: the P0 ledger + round-40 journal — the counter's pinned inputs (fixed for all readings). |
| 3 | `5142b52` | 12:04:25 | r41 predeclaration. **Birth of the drift:** commits `.ufo/waves/round-41/controls/c2-base-19025d9.txt` = `1`, a *worktree* product (counter run at the `19025d9` worktree). Also births the r41 gate (`corpus/expect-journal.sh`, no `DELETED` class). |
| 4 | `19025d9` | 12:04:25 | r40 verifier spot-check = r41 claim BASE. |
| 5 | `e8265c0` | 13:23:22 | r41 verifier spot-check = **r42 claim BASE**. Tree now contains the r41 landing; the worktree counter reads **3** at this tree (M41-4 gap vs the committed 1). |
| 6 | `98dd4de` | 13:23:22 | **r42 predeclaration — writes and commits all three drifted receipts** (only commit to ever touch them): `c1-base`=4 (r41 gate accepts F5/R17-02), `c2-base`=0 (worktree-legacy runner writes R=3 ≠ D=1), `c2-worktree-at-base`=3 (manual worktree reading, no committed producer). |
| 7 | `fdbb83d` | 13:52:45 | **A1**: D's counter source pinned to `5142b52` (counter-copied-from-candidate hole, critic F2). Receipts re-measure identically. |
| 8 | `ca0c6a9` | 14:10:30 | **A2**: delete the clone's receipt + require runner rc 0 — closes the do-nothing hole (critic F1: pre-A2 a no-op runner read N=1 from the stale committed receipt). BASE reading stays 0 (e4). |
| 9 | `d00a543` | 14:11:21 | **r42 candidate — the commit that moves both drifted readings**: gate gains `DELETED <ID>` (F5/R17-02 now refused → c1 4→5) and the r41 runner's C2 BASE leg becomes pinned (`git archive 19025d9` + `5142b52` counter → writes 1=D → c2 0→1). |
| 10 | `6d6b486` | 14:15:38 | r42 lesson/SCORECARD/LOG: mines M41-4 (three values for one named receipt), M42-1 (A2 hole), M42-2 (A1); C1 4→5, C2 0→1 recorded. |
| 11 | `0cb78144` / `b266c5f9` | 14:17–14:18 | adjacency correction; post-round census (`kagi ok`, 98 rows). |
| 12 | `5f3566c` | 14:28:06 | r42 verifier spot-check = r43 claim BASE = **the register's pinned re-derive-at**. At this tip: `c1-base` re-derives 5 (committed 4), `c2-base` re-derives 1 (committed 0), `c2-worktree-at-base` written by no committed runner (sweep empty). |
| 13 | `f2b4ec76` | 15:17:35 | r43 amendment A2 + `.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` — the eight-receipt manifest re-derives 8/8 byte-identically (both modes); the three excluded receipts are disclosed by name with committed/re-derived values. |
| 14 | `65f66e17` | 15:18:11 | r43 landing: `plans/round-43-c2.sh` header names the three as excluded-by-design ("historical claim-BASE readings"). |
| 15 | `d54109d` | 15:33:30 | r43 verifier spot-check = **r44 claim BASE**; routed item 3: a round-44 correction entry should name and supersede or re-derive them. |
| 16 | `ae9e9eb` | 15:33:30 | r44 predeclaration: the C3 register (`.ufo/waves/round-44/controls/receipt-corrections.md`) with the three frozen rows and `re-derive-at 5f3566c` in every row. |

## Q5 — do the `superseded-by` dispositions lose information by not re-deriving at the ORIGINAL claim BASEs (`6cc8850` / `e8265c0`)?

**No decision-relevant information is lost — and re-deriving there is not even possible with committed
bytes — but two facts the register cannot carry must go into the lesson's narrative.** Concretely:

- **Faithfulness at the original BASE (the fact the register loses).** Both drifted receipts were
  *accurate when written*: executed at the claim BASE with birth bytes, `c1-base` re-derives **4** =
  committed 4 (e1), `c2-base` re-derives **0** = committed 0 (e3; also 0 under post-A2 bytes, e4 —
  A1/A2 changed no BASE reading). The drift is therefore *temporal and admitted*: the readings moved
  because the round-42 candidate `d00a543` landed the very fixes the receipts were the no-work controls
  for. The register's rows (committed 4 / re-derived 5; committed 0 / re-derived 1, superseded) record
  the movement but not its cause or the at-BASE equality; without this reconstruction a reader could
  misread "committed 4, re-derives 5" as a receipt that was wrong at birth. The lesson should carry the
  sentence: *both r42 BASE receipts re-derive byte-identically at their own claim BASE `e8265c0`; the
  mismatch appears only when re-run at `5f3566c`, where the admitted candidate's gate/runner fixes moved
  the readings.*
- **The `6cc8850` trap (why "re-derive at the original BASE" fails closed-misleadingly).** At `6cc8850`
  the gate does not exist (`git cat-file -e` fails) and neither counter nor runner does (all born at
  `98dd4de`, whose parent is `e8265c0`). The C1 counter's missing-gate leg prints **`0` exit 0** there —
  a naive at-BASE re-derivation would read `0` and falsely suggest a four-unit drift. `6cc8850` is the
  counter's ledger pin, not a measurement BASE of either receipt; the only faithful at-BASE re-derivation
  is birth-counter bytes over the `e8265c0` tree (what e1/e3 do). Pinning `re-derive-at 5f3566c` in
  every register row is the only self-consistent choice: it is the earliest revision at which every
  invoked runner exists and is byte-committed.
- **Row 3 loses nothing by pinning its sweep at `5f3566c`** — the sweep is empty at every revision
  including the creation commit `98dd4de` (e9), so the token `not-written-by-any-committed-runner` is
  true at all pinned revisions simultaneously.
- **Surfacing observation (surviving, by design):** at the current tips the r42 C2 no-work control no
  longer reads 0 — the do-nothing tree at `5f3566c` *is* the landed fix and reads 1. That is the claim
  working, not a defect; the register's supersession of `c2-base.txt` by the re-derivable r41 receipt
  (`.ufo/waves/round-41/controls/c2-base-19025d9.txt`, in the r43 manifest, 8/8 MATCH) is the correct
  disposition.

## Surviving defects / observations named (all status-neutral)

- **D-obs-1 (`--follow` artifact).** `git log --follow` on these 2-byte receipts surfaces unrelated
  round-36/round-33 commits (identical single-digit content drives rename detection; `--raw` shows those
  commits touched no `controls/c[12]-base` path). Provenance queries on tiny receipts must use
  `--diff-filter=A` / no-follow, or they misattribute authorship (e9 carries both queries).
- **D-obs-2 (uncommitted producer).** `c2-worktree-at-base.txt` has no committed producer at any
  revision; the physical writer command is inferable only (e7 reproduces the value two ways). The
  register's token disposition is the honest bound; no committed runner can ever re-derive row 3's
  `—` cell, and the register correctly leaves it empty rather than forging a `via`.
- **D-obs-3 (register ceiling, already declared).** The register pins `committed` values to `5f3566c`
  bytes and re-derives only there; the at-BASE faithfulness facts above live outside it. This seat's
  deliverable is that missing historical record (round-44 plan §C3 declared ceiling, revenger duty).
- **D-obs-4 (A2 scope).** A2's delete-before-run semantics mean the committed `c2-base.txt` (measured
  pre-A2) and the current counter semantics agree at the BASE by coincidence of the R=3 path, not by
  re-measurement at commit time of the amended bytes — verified equal here (e4), but the plan's
  "re-measure identically" was asserted for the BASE set and only now executed for `c2-base` at
  `e8265c0` under A2 bytes (rc 0, reading 0).

## Method note

Sandbox `$S=/fast/scratch/hyaku/kagi-r44/K44RevengerDrift`, shared clone `work` detached at `ae9e9eb`,
toplevel asserted. Re-measurements run committed counter/runner bytes in fresh shared clones detached at
`98dd4de` / `ca0c6a9` / `5f3566c` / `e8265c0` (and one `git archive 19025d9` extraction for D); no lane
tree touched; no pacman/host service touched; no tool installed or upgraded (none needed). Scratch
deleted before yield.
