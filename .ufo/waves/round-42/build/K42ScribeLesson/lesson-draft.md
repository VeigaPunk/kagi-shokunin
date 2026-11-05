source: S094 (`https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`, re-opened 2026-11-05, byte-identical to the committed round-39 capture); the frozen counters, the frozen plan and the wave receipts under `.ufo/waves/round-42/controls/` are the evidence for the rest

# Round 42 — expect-journal deletion rule (C1, calibration), pinned-revision controls receipt (C2, freshness)

Frozen plan: `plans/round-42.md` at `98dd4de` (predeclaration: plan, counters `plans/round-42-c1.sh` and `plans/round-42-c2.sh`, the controls runner `plans/round-42-controls.sh` and the measured BASE receipts under `.ufo/waves/round-42/controls/`). Amendment A1 at `fdbb83d` (predeclaration, before any candidate commit): the C2 counter derives D from the frozen counter at `5142b52`, not from the candidate's copy. Claim BASE: `e8265c0d90b01fcce0447d2f70615b0592ed145f` (the round-41 integrator spot-check commit, the lane `master` tip at round start). C1 positive control P0: `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`; C1 base ledger: `6cc8850dfc5757927699e5a53a876f47c8df21aa`. Round-41 journal: `.ufo/waves/round-41/expectation-migrations.json`; round-40 journal: `.ufo/waves/round-40/expectation-migrations.json`. Section order follows `corpus/lessons/round-41.md` (Claims before Gate).

## Claims

- **C1 calibration — `bash plans/round-42-c1.sh` 4 → 5.** BASE **4** at `e8265c0`: the round-41 gate
  (`corpus/expect-journal.sh`) refuses F1–F4 with their frozen tokens and accepts F5 (a base-ledger row
  removed from the candidate with no journal entry), so N = 4. The BASE reading is committed at
  `.ufo/waves/round-42/controls/c1-base.txt` (`4`); the blanket-refuse control
  `.ufo/waves/round-42/controls/c1-control-refuse-all.txt` reads `0` and the blanket-accept control
  `.ufo/waves/round-42/controls/c1-control-accept-all.txt` reads `0` — a do-nothing candidate, a
  blanket-refuse gate and a blanket-accept gate all read 0, so none can reach the target.
  Target **5** at the candidate.

  Frozen predicate (copied verbatim from `plans/round-42.md` §C1): *"`plans/round-42-c1.sh` prints ONE
  unsigned integer N = the number of the five forgeries F1–F5 that `corpus/expect-journal.sh` refuses
  with its frozen token (rc 1 and the exact line `EXPECT_JOURNAL: REFUSE <token>`), counted only if the
  gate accepts the positive control P0 (rc 0); if the gate is missing, P0 is refused, or P0 errors, N = 0."*

  F1–F4 are the round-41 forgeries, unchanged (`UNJOURNALED R13-01`, `OLD_MISMATCH R21-02`,
  `NOT_LITERAL R13-01`, `COMMAND_MISMATCH R24-06`); F5 is new — the P0 ledger with row `R17-02`
  deleted, the P0 journal unchanged, token `DELETED R17-02`. `R17-02` is present in the base ledger
  `6cc8850` (measured: the row is in the base ledger, in P0 `6f1588c` and at `e8265c0`) and appears in
  no round-40 or round-41 migration journal (measured: `git grep -n R17-02 e8265c0 --` over the two
  journals → no match), so no frozen class of round 41 speaks about a deletion.
  Candidate rule the gate must implement (the executor's work): every base-ledger id absent from the
  candidate ledger is refused with `DELETED <ID>`, unconditionally; the existing classes, the
  four-column ledger format and the migration schema stay unchanged; `MISSING_ROW` is kept.

  Kill rule (verbatim from `plans/round-42.md` §C1): *"C1 is not admitted if (a) the candidate gate
  refuses P0 or any of the six round-41 migrations at the round-41 landing check (`--base-ledger` = the
  5142b52 ledger, `--ledger` = the candidate's `corpus/claim-ledger.tsv`, journal = the round-41 journal,
  expected `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`); (b) N < 5 at the candidate; or (c) the
  gate's own selftest does not pass with the F5 case added."*

  Declared ceilings (verbatim from the plan, not claimed as closed): the gate does not re-run commands
  and does not judge reason text; a deleted row with a journal entry whose id survives is refused by
  `MISSING_ROW` (unchanged); the rule refuses a *legitimate* future retirement until a retirement form
  exists (an operator-visible cost, not a silent loosening); the F5 counter forges one row only.

  Population measured at the claim BASE, for the L1's ledger bookkeeping: the ledger carries **86** ids
  at `6cc8850`, at P0 `6f1588c` and at `e8265c0`, and **no id was removed** across those three
  revisions (measured: the id sets differ by 0 removed and 0 added, `comm -23` empty in both
  directions). The `DELETED <ID>` rule therefore refuses nothing the lane's own history contains.

- **C2 freshness — `bash plans/round-42-c2.sh` 0 → 1.** BASE **0** at `e8265c0`: the committed runner
  `plans/round-41-controls.sh` writes `.ufo/waves/round-41/controls/c2-base-19025d9.txt` by running the
  C2 counter in the lane *worktree*, and at the claim BASE that worktree reading is **3**, not the
  committed receipt's **1**. The BASE reading is committed at `.ufo/waves/round-42/controls/c2-base.txt`
  (`0`); the derivation D reads **1**
  (`.ufo/waves/round-42/controls/c2-derivation-D.txt`, the frozen counter at `5142b52` over a
  `git archive 19025d9` extraction); the direct worktree reading **3** is committed at
  `.ufo/waves/round-42/controls/c2-worktree-at-base.txt`, and the stale committed receipt itself reads
  `1` at `.ufo/waves/round-41/controls/c2-base-19025d9.txt`. Target **1** at the candidate.

  Frozen predicate (copied verbatim from `plans/round-42.md` §C2): *"`plans/round-42-c2.sh` prints ONE
  unsigned integer N in {0,1}. N = 1 iff, in a clean clone of the candidate commit (the argument, default
  HEAD), running that clone's `plans/round-41-controls.sh` writes
  `.ufo/waves/round-41/controls/c2-base-19025d9.txt` whose last line equals D, where D is the frozen C2
  counter (`plans/round-41-c2.sh`, copied from the candidate) run in a `git archive` of the claim BASE
  `19025d9` (its own normalizer, registry and fetch rows), AND D equals 1. Otherwise N = 0."*
  (Amendment A1 changes the *source* of D — `git show 5142b52:plans/round-41-c2.sh`, never the
  candidate's copy — and nothing else in the sentence; see §Mistakes M41-7 for the wording divergence
  this leaves between the plan body and the counter header.)

  Candidate rule the runner must implement (the executor's work): the runner's C2 BASE line is produced
  by running the C2 counter in a `git archive 19025d9` extraction, with the counter copied in from the
  lane, never in the lane worktree; the runner's other lines and its C1 controls stay unchanged.

  Kill rule (verbatim from `plans/round-42.md` §C2): *"C2 is not admitted if (a) the candidate receipt is
  not `1` in a clean clone of the candidate; (b) the runner still reads the worktree for the BASE line;
  or (c) the committed receipt in the candidate tree differs from the runner's output at the candidate."*

  Declared ceilings (verbatim from the plan): the counter checks the receipt value against D, not the
  runner's source — a runner that writes the constant `1` passes (named ceiling; the counter's own
  derivation is the control against it, and the candidate's runner is reviewed as code); the claim does
  not re-derive the round-41 C1 BASE, only the round-41 C2 receipt.

- **Base context carried to the L1 (measured at the claim BASE `e8265c0`, not re-derived here).**
  SOURCES census `kagi ok` with 98 rows (A 94, B 2, C 2, queued 1, mined 93, rejected 4) — the fleet
  command `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` exits 0
  with a final `kagi ok` line (the W04 duplicate-URL warnings on the pre-existing rows are unchanged).
  The ledger's BASE verify red set is FAIL `R11-08`, `R22-03`, `R24-15`, `R25-02`, `R36-03` and POLICY
  `R29-01`, `R29-02`, `R38-03`; none of these rows belongs to C1 or C2, so they stay named debt and no
  axis is re-scored (rounds 36–41 record moves, not new scores).

## Gate

- **S094 (re-open) — `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`**,
  tier A own-work (the registry's own append-only rule). Access: re-fetched **2026-11-05** with
  `curl -fsSL --compressed -A 'kagi-shokunin-round42/1.0 (documentation verification)'`; HTTP status
  **200**, no redirect, effective URL equal to the requested URL, downloaded 5073 compressed bytes.
  Decoded body **11296** bytes, sha256
  `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` — equal to column 10 of the
  committed fetch row S094 in `corpus/source-fetches.tsv` and to column 11's byte count 11296, and
  `cmp` against the committed capture `.ufo/waves/round-39/capture/S094.body` exits 0 with no output
  (byte-identical, no drift).
  Located quote (8 whitespace tokens, ≤ 25): *"Only `status`, `recheck` and `used-by` change in place"* —
  raw body byte offset **6172**, count **1** (`grep -b -o -F` → `6172:Only \`status\`, \`recheck\` and
  \`used-by\` change in place`, rc 0). The rule line itself is `2. **Append-only.** Only \`status\`,
  \`recheck\` and \`used-by\` change in place, and each change is logged old→new in the round lesson`
  (line 116 of the served body). The teaching grounds C1's sourced claim: the registry's append-only
  discipline — only `status`, `recheck` and `used-by` change in place — is the rule a ledger-row
  *deletion* violates, since a removed id is not an in-place edit at all.
  Re-open verdict: `<<FILL: s094 reopen verdict>>` (the L1 records the admit/reject decision; the
  measured bytes, digest, offset and quote count above are the evidence for it).
  Evidence: `.ufo/waves/round-42/build/K42ScribeLesson/gate-receipt.txt` (this seat's live re-open
  receipt, with commands, exit codes and digests); the committed row and fetch row in
  `corpus/SOURCES.md` / `corpus/source-fetches.tsv`; the committed capture
  `.ufo/waves/round-39/capture/S094.body`.
  Named limit on this Gate: the round-41 lesson's M40-1/QM42 finding still stands for S094's *teaches
  cell*, which appends the derived clause "an in-place anchor rewrite violates this rule" — that clause
  does not occur in the served body (measured: `grep -c -F` → 0). The quote located above is the
  committed fetch row's declared quote, not the teaches cell's derived clause; S094's row is append-only
  and is not edited in place.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M41-4 | controls runner wrote a worktree reading into a committed BASE receipt (a receipt that is not re-derivable from the revision it names) | `.ufo/waves/round-42/controls/c2-worktree-at-base.txt` (worktree reading **3**) and `.ufo/waves/round-42/controls/c2-base.txt` (**0**); the committed receipt `.ufo/waves/round-41/controls/c2-base-19025d9.txt` still reads **1** — three different values for one named receipt. Routing: round-41 lesson §Routed item 6 ("C2 BASE receipt is unpinned (critic defect)") and critic defect 1 | `none` | C2 of this round: the runner's C2 BASE line is produced from a `git archive 19025d9` extraction with the counter copied in from the lane, never from the worktree. The fix is shown able to fail: the unfixed runner at the claim BASE reads **0** against the frozen no-work control (its receipt is 3, D is 1), so the counter cannot reach its target without the change. The A1 counter's own derivation (D = 1 from `git show 5142b52:plans/round-41-c2.sh`) is the second half of the witness |
| M41-5 | a frozen plan sentence overstates what the old gate accepts ("accepts F1–F4 by construction" is false for F4 under the old gate's policy allowlist) | `plans/round-41.md` §C1 (existing-gate control: "accepts F1–F4 by construction") against `corpus/claim-ledger.sh:262` (`ALLOWED_RE='^(bash\|grep\|sha256sum\|wc\|test\|python3)$'`) and `corpus/claim-ledger.sh:275` (first-token refusal, `first-token:echo`): F4's construction rebinds R24-06's command to an `echo`, which the old gate's policy allowlist refuses before the command is ever run, so the old gate does not "accept" F4 by construction. Routing: round-41 lesson §Routed item 5 and round-41 verifier spot-check §6 item 7 ("Plan §C1 'accepts F1–F4 by construction' overstates F4"), and this round's plan §Routed bullet 6 | `none` | erratum in this lesson; the round-41 frozen plan is **not** rewritten. The erratum is recorded here, in `corpus/lessons/round-42.md` §Mistakes M41-5, and in the round-42 report; the frozen bytes of `plans/round-41.md` stand |
| M41-6 | journal gate blind spot (a deleted ledger row is in neither population of the frozen classes, so a base row removed from the candidate with no journal entry passes `CLEAN`) | round-41 lesson §Routed item 4; round-41 verifier spot-check §6 item 4 ("Row deletion from the candidate ledger is outside the frozen classes (attack A6) — a `MISSING_ROW` rule is instrument work"); the reviewer's attack A6 in `.ufo/waves/round-41/build/K41ReviewJournal/attacks.md` | `none` | C1 of this round: the `DELETED <ID>` refusal class, unconditional, with F5 as the fifth counter forgery and target 5. The counter shows the fix able to fail by the red reading 4: the round-41 gate at the claim BASE accepts F5, so BASE 4 < target 5 |
| M41-7 | frozen-artifact self-description drift (the plan body and the counter header no longer carry the same predicate sentence after amendment A1) | `plans/round-42.md` §C2 says the predicate sentence "appears in `plans/round-42-c2.sh`'s header", and its own wording is "(`plans/round-41-c2.sh`, copied from the candidate)"; the counter header at `plans/round-42-c2.sh` reads "(`plans/round-41-c2.sh` as frozen at predeclaration 5142b52, read with git show, never the candidate's copy)". Measured by `git show fdbb83d -- plans/round-42-c2.sh plans/round-42.md`: A1 changed the counter header and added the A1 section, and left the plan's §C2 sentence body unchanged | `none` | recorded here and in the round-42 report; the frozen plan and counter are **not** rewritten after the freeze. The governing behaviour is A1's — D is read from `5142b52` in both the counter and the controls runner — and the L1's landing measurement decides the receipt |

## Frontier

- What this round advances, on the **calibration ground**: the journal gate's class set gains the one
  refusal it was missing. Round 41's gate referees *changes* only; a base id that is simply absent from
  the candidate ledger was in neither population, so an unjournaled deletion passed `CLEAN`. The round-42
  candidate refuses every base-ledger id absent from the candidate with `DELETED <ID>`, and the frozen
  counter's fifth forgery F5 (P0 ledger with `R17-02` deleted, P0 journal unchanged) makes that
  measurable: the claim BASE reads 4, the target is 5, and the two blanket controls read 0, so no
  do-nothing candidate reaches the target.
- What this round advances, on the **freshness ground**: the controls runner's C2 BASE receipt stops
  being a worktree reading. The committed receipt at `.ufo/waves/round-41/controls/c2-base-19025d9.txt`
  reads 1 while the same runner at the same commit reads 3; the candidate runner derives the line from a
  `git archive 19025d9` extraction, so the receipt is re-derivable from the revision it names. The
  counter's derivation D is pinned to the frozen counter at `5142b52` (amendment A1), so a candidate that
  edits `plans/round-41-c2.sh` cannot move the target.
- No frontier-to-core move: this round claims no new registry row, no new `corpus/knowledge/` entry and
  no new mechanism; S094 is re-opened, not admitted anew.
- Rows added: **none**. Rows touched old → new: **none** — the registry stays at 98 rows (A 94, B 2,
  C 2) with the census reading `kagi ok`, and the S094 row is not edited in place (append-only rule:
  only `status`, `recheck` and `used-by` change in place).
- Mistakes mined this round: M41-4, M41-5, M41-6, M41-7 (table above). Captured-by: none for all four
  — the fixes are routed or claimed, not yet shown able to fail by a committed control of their own.
- Assimilation: none this round.

## Routed

Carried from `plans/round-42.md` §Routed (named, not claimed this round), item names verbatim:

1. Mutation runner anchors match 4 of 11 round-41 C1 mutants on the real gate
   (`.ufo/waves/round-41/mutants-landing.txt`) — the round-42 mutation seat re-runs the mutants on the
   candidate gate; survivors are routed unless they are the F5 rule itself.
2. `expect-journal.sh` `*.json` discovery fails closed (exit 2) on a wave directory (routed item 2) —
   frozen-interface change, round-43.
3. C3 counter defects M40-9 / M40-10 / M40-17 (stub selftests, constant counters, HTML-comment heading
   case) — round-43.
4. Gate-selftest scratch defaults `${TMPDIR:-/tmp}` at `corpus/anchor-pins.sh:37`,
   `corpus/claims-declared.sh:37`, `corpus/prefreeze-control.sh:94,274`,
   `corpus/self-description-sweep.sh:226`, `corpus/surface-census.sh:275` (round-41 routed item 2; a
   QUALITY-class defect of `/tmp` scratch, `plans/round-40` uses `HYAKU_SCRATCH`) — round-43; this round
   edits only `corpus/expect-journal.sh` and `plans/round-41-controls.sh`.
5. Round-40 report amended in place (round-41 routed item 6) — an appended erratum is owed; not
   claimed.
6. Plan §C1 of round 41 says the gate "accepts F1–F4 by construction"; F4's echo construction is
   refused by the old gate's policy allowlist (`first-token:echo`) — recorded as an erratum in the
   round-42 lesson, not by rewriting round-41's frozen plan (this lesson's M41-5).
7. Considerthese `2026-10-26.md` proposals 1 and 3 remain unimplemented (proposal 3: `KNOWN_DEFECT`
   qualifier; proposal 1: repair-only release path under HOLD). No separable claim slot this round:
   both need a new predicate, and proposal 1 is operator policy.

Additionally carried from the round-41 lesson's own §Routed list, still open and not claimed this
round: the mutation-runner anchors against the delivered gate (the round-41 battery recorded
`killed=0 survived=4` on the real gate); the `MISSING_ROW` / deletion instrument work that this round's
C1 claims; the C2 selftest case-count floor (`RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exactly at
the floor); and the round-40 report's owed appended erratum.

## considerthese

The latest file is `considerthese/2026-10-26.md`. Its self-improvement proposals **proposal 3**
("mark known-defective instrument output" — append a `KNOWN_DEFECT: D1` qualifier to a `CLEAN` verdict)
and **proposal 1** ("a repair-only release path under a HOLD") **remain unimplemented**: proposal 3's
qualifier is still absent from `corpus/release-clock.py`, and no repair-only ticket mechanism exists in
the lane, because proposal 1 is operator policy. Measured anchors: `grep -c 'KNOWN_DEFECT'
corpus/release-clock.py` → 0 at the claim BASE `e8265c0`; the lane holds no HOLD-release mechanism.
**No proposal is taken this round — reason: no separable claim slot.** The round's two claims are fixed
by the frozen plan (C1 calibration, C2 freshness), and neither proposal carries a predicate this round
could hold without widening a frozen predicate; both are named in the plan's §Routed as round-43 or
operator work.

## Assimilation

None this round. Reason: the round claims no new registry row and no new `corpus/knowledge/` entry —
the only sourced action is the re-open of S094, which re-verifies ground the lane already holds, so
there is no frontier entry to move into core and no core file to write. The two claims land as
instrument changes inside the lane (`corpus/expect-journal.sh`, `plans/round-41-controls.sh`), not as
knowledge entries.
