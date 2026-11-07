# R61ScoutRouted — report

Seat: `R61ScoutRouted` (scout). Round 61, attempt 1, lane kagi.
Scope: independently re-derive every number `plans/round-61.md` §C1 compares for items
I1–I7 from the lane repository at BASE `c940f51689d702f1786989d56ad4663833c1452e`, and
report any number the plan states wrongly. No lane file was edited; no git/jj mutating
command was run in the lane or any index.

Receipt: `.ufo/waves/round-61/build/R61ScoutRouted/rederive.md` (full commands, raw
outputs, per-item table, ambiguities A1–A7, residuals).

Scratch: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ScoutRouted/` (BASE tree
exported read-only with `git archive`), deleted before yield. Tools: no install;
`git 2.56.0`, `python3 3.14.8`, `grep (pi-uu-grep) 0.2.0` as shipped.

## Verdict

**Every value the plan states for I1–I7 re-derives exactly.** One *format* defect is
reported (I6), plus five ambiguities that make a byte-only checker non-deterministic, and
two residuals the frozen item set does not cover.

| id | plan's number | re-derived | agree |
|---|---|---|---|
| I1 | R = result records; B = byte length of `R60MutCounters` output | **R = 16**, **B = 3824** | yes |
| I2 | the `SKILL.md` row naming `plans/round-60-c2.sh` | exactly one row: **855**; selftest cell = `none of its own — it runs the trial's \`--selftest\` as a conjunct` | yes (see A2) |
| I2 | the counter must accept `--selftest` | **it does not**: the parser's `*) REV=$1` branch treats it as a revision ⇒ `(bad-revision)` rc=1 | yes (defect premise confirmed) |
| I3 | §A6 block, `^## Amendment A7`, `A3 item 2`/`form`/`l1-probe.txt`/`withdrawn`; lesson `M60-2`+`A3 item 2`+`second instance` | all currently false; `l1-probe.txt` has **no** `form`/`content-type` match (rc=1) | yes (see A4) |
| I4 | lesson quotes `no new record defect`, names D1–D3, states `three` | report line 166 carries `no new record defect` verbatim; no such lesson line yet | yes |
| I5 | `insertions=1 deletions=1`; `git diff --numstat 14a6c07d 818d2a82 -- LOG.md` | **`1  1  LOG.md`** ⇒ 1 insertion, 1 deletion, a rewrite in place of the wave line (`dead seats 1` → `dead seats 0`) | yes |
| I6 | driver launch line + ≥3 `-03:00` timestamps occurring in `git log --format='%ci' a677c78e..818d2a82` | launch `2026-11-07T15:03:17-03:00 launch kagi round=60` confirmed (watchdog `:3217`); range holds **9** committer times, but `%ci` prints `-0300`/space and **0** literal `-03:00` | **format defect — A1** |
| I7 | 3 attack roles present, 4 with the sentinel, 16 results, 18.75 / 25 | literal list present = **reviewer, critic, mutation-tester = 3** (no `labrat`); 3+1 sentinel = **4**; **16** results; **18.75 %** / **25 %** | yes |

BASE is correct: `c940f51` is the round-60 verifier spot-check tip
(`round-60 verifier spot-check (integrator, hyaku): non-author admit/reject`,
2026-11-07 16:43:53 -0300) and is the parent of the frozen plan commit `8595018`, which
contains `plans/round-61.md` alone (193 insertions). The plan's "BASE 7" is consistent:
all seven item conditions are false at BASE (hand-checked, 7/7 unresolved), so the
`value=7 population=7` census holds.

## Defect to report (do not amend the frozen predicate)

**I6 — the `-03:00` timestamps cannot literally occur in `%ci` output.**
Plan sentence: *"…and at least three `-03:00` timestamps that each occur in
`git log --format='%ci' a677c78e..818d2a82` (derived when `--repo` is given)."*
`%ci` emits `2026-11-07 16:33:44 -0300` — space separator, offset `-0300`; measured
literal `-03:00` matches in that output: **0**. The `-03:00`/`T` form is `%cI`. A checker
that matches the lesson's timestamps literally against `%ci` lines finds nothing, I6 can
never hold, and the item becomes vacuous — which K2 forbids. The fix belongs in the
checker's comparison (compare instants, normalising the offset) and in the §C1 wording
(`%cI`, or an explicit normalisation rule). Nine candidate instants exist, so "at least
three" is satisfiable once normalised.

## Ambiguities a byte-only checker must be told about

- **A2 (I2)** — the "`--selftest` in the selftest cell" conjunct is *already true* at BASE
  (row 855's cell contains `--selftest` twice). Only the removal of `none of its own`
  discriminates; the condition should require the cell to name the counter's **own**
  invocation (`bash plans/round-60-c2.sh --selftest`).
- **A3 (I2/K4)** — `C2_SELFTEST:` and a "named `FINDING`" do not exist in the lane today
  (`grep -c FINDING plans/round-60-c2.sh` ⇒ 0); the finding-id namespace is unspecified and
  must not collide with round 61's own C2 counter or the seal trial's `SEAL_SELFTEST:`.
- **A4 (I3)** — the plan mandates `^## Amendment A7` while every amendment in
  `plans/round-60.md` is `### A<n> — …` (h3). §A6 is the file's last block, so the
  amendment goes at EOF.
- **A5 (I1)** — "the record's final output" has two byte readings: the `output` field
  (**3824**) vs its last line (`}` = 1) vs the whole record (4097). The plan and the
  spot-check both mean the `output` field; say so explicitly.
- **A6** — the population-census sentence prints `value=7 population=7` but omits that it
  is taken with `--no-challenge` (a challenge-enabled BASE run prints `value=FAIL … guard=0`,
  since the challenge needs an I5 correction line that does not exist yet).

## Residuals the frozen seven items do not cover

1. The report's **sibling** attack-share number is also wrong: `.ufo/reports/round-60/kagi.md:10-12`
   says *"and 6/16 = 38 % counting sentinel and revenger"*; the seats are reviewer + critic +
   mutation-tester + sentinel + revenger = **5**, so it is **5/16 = 31.25 %**. D7 and I7 quote
   only the `4/16 = 25 %` half, so the wrong `6/16` survives the fix; the next report must not
   repeat it. (Fleet-owned file; the correction belongs in the lane lesson and the next report.)
2. The plan's motivating claim *"`grep -rlE 'unseal|shamir' corpus/knowledge/` matches no entry
   that measures the Shamir seal"* — the grep matches **6** entries, and
   `corpus/knowledge/sops-age-key-rotation.md` does measure a Shamir threshold (SOPS's age
   key-group split, `shamir_threshold=2`), though not an OpenBao seal. §Motivating evidence
   only, outside the seven items.

## Scope note

Read-only seat: no lane edit, no fix, no counter code, no subagent dispatch. All findings
are in the receipt; the L1 lands whatever it decides to land and owns the commit.

SEAT-STATUS: complete
