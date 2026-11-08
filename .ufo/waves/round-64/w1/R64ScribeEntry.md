# R64ScribeEntry — seat report (round 64, attempt 2, wave `kagi-r64-w1`)

Seat: R64ScribeEntry (scribe). Axes claimed: depth, calibration.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch master). Claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`. Frozen predeclaration `plans/round-64.md`
(commit `dff0929c0e084822b0fe32e0d164534c768f97fe`, Amendment A1).

## What this seat produced

| file | kind | content |
|---|---|---|
| `corpus/knowledge/claim-instrument-heldout.md` | new | the round's knowledge entry: the held-out rule, the two-sided population with its measured before→after, the bounds, the falsifiers. Opens with the provenance trio (`source:` / `verified-at:` / `recheck:`) and cites one `S###` row — **S145** (Kushigian et al., "Equivalent Mutants in the Wild", ISSTA '24). |
| `corpus/QUALITY.md` | append-only | **QM85** (a checker's fixture table cannot be its own test set) and **QM86** (a re-enterable counter's bound flag must carry a refutation leg), each citing `corpus/lessons/round-64.md`. No existing row was rewritten; the two rows were appended under a new `## Criteria from the round-64 held-out-set and bounded-delegation work` heading. |
| `SKILL.md` | append-only, registry rows only | a new `## Gate registry — round-64 additions` section with three rows — `plans/round-64-c1.sh`, `plans/round-64-c2.sh`, `plans/round-64-controls.sh` — each `kind: gate`, each with a runnable self-invocation and its measured case count, the 0/1/2 exit-code map, the pinned seal and digests, and the falsifiers. No row says `none of its own`. |

Receipts: `.ufo/waves/round-64/build/R64ScribeEntry/entry.md` (every command and output),
plus `c1-worktree-1.txt`, `c1-worktree-2.txt`, `c2-worktree.txt` beside it.

## The knowledge entry (in one paragraph)

A checker's committed fixture tables are the checker's own outputs: running them against
the checker proves only that the checker answers the way the table says it answers. The
round-63 critic's A4 vehicle — a 15-string lookup over the committed tables, a constant
`PASS (cases=91)`, a dead `NEGATORS = frozenset(())` line — read `accepted=0 rejected=0`
against every guard leg the round-63 counter carried. The literature names the shape: S145
states `An equivalent mutant is a mutant which cannot be killed by any test`, so a
memorised table is, **on that table, exactly an equivalent mutant of the grammar**, and no
test drawn from the table can separate them. The rule therefore carries three conditions —
sealed before the hardening (digest-fixed in the predeclaration), held out from the
instrument (the builder does not read it), and the instrument's own tables re-run as a
**separate guard leg** where a regression fails the guard and not the claim. The
population is two-sided (five held-out forgeries the BASE checker accepted, three held-out
benign rewrites it rejected) so a checker that rejects everything cannot pass. The entry
extends `corpus/knowledge/negation-scope-grammar.md` (what a sentence must look like) and
`corpus/knowledge/claim-instrument-falsifiability.md` (what a gate's selftest must
execute) by asking the prior question: on what evidence may a claim that an instrument
implements a rule rest?

## Measured before → after (the two-sided population)

BASE readings are the L1's committed re-measurement (`.ufo/waves/round-64/base/census-a1.md`,
slim extraction of `09cbee8`); the candidate column is this seat's own run of the frozen
counter against the working tree (the counter's `c1-heldout: per-fixture …` line).

| side | id | shape class (the plan's name; no fixture string quoted) | BASE | candidate |
|---|---|---|---|---|
| H | F2 | denial after the bound pair | `value=0` accepted | `value=1` rejected |
| H | F6 | duplicated mechanism (one mechanism asserted twice) | `value=0` accepted | `value=1` rejected |
| H | F8 | quoted denial | `value=0` accepted | `value=1` rejected |
| H | F10 | unbound duplicate pair | `value=0` accepted | `value=1` rejected |
| H | B4 | negated subject | `value=0` accepted | `value=1` rejected |
| Q | P6 | binding window widened by an em-dash aside | `value=1` rejected | `value=0` accepted |
| Q | B5 | idiom class the closed list did not carry | `value=1` rejected | `value=0` accepted |
| Q | P7 | parenthetical between subject and pair | rejected at mechanism level | `value=0` accepted |

The counter's own measure line reads `H accepted=0/5 … Q rejected=0/3`, and the unmodified
copy still reads `value=0` with all seven item bits 1; on the counter's frozen bytes the
verdict line is `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1
stub=1 vehicle=1)` rc 0. The seal was verified by digest only (`sha256sum
plans/round-64-heldout.tsv` ⇒ `b0f51e2a…`, matching the frozen seal); this seat did not
open the sealed table's rows and quotes no fixture string from it anywhere.

## What this seat measured, and where it stopped short

1. **The C1 counter's verdict line was observed**, on the counter's frozen bytes
   `e03a4d69…`: `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1
   stub=1 vehicle=1)` rc 0 in 496 s — five held-out forgeries rejected, three held-out
   benign rewrites accepted, the A4 vehicle refused on the held-out set
   (`vehicle heldout=5 r63=1`), both printer-stub shapes refused, and the round-63
   residual verdict unregressed (`accepted=0 rejected=0 population=10/6 guard=1`).
   Earlier in the wave the same counter aborted in its stub leg (`line 620: stub2_e2:
   unbound variable`) and exceeded an outer `timeout 1500` inside its `resid` leg; both
   were reported to the counter's owner with this seat's reproduction and are fixed on the
   frozen bytes. The committed candidate receipt is the L1's to land.
2. **The C2 counter's single end-to-end line** was observed twice: red
   (`guard=0`, `real=0`) on the bytes `f7cddb03…`, and green
   (`C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1
   real=1 terminates=1 bound=1)`, 625 s, rc 0) on the counter's frozen bytes `e2d8171f…`.
   The round-63 defect (rc=124 at 900 s and 1500 s, a 7-byte receipt) is closed.
3. **What is still not this seat's evidence**: the committed receipts under
   `.ufo/waves/round-64/final/`, the stamp row for the new entry, and the registry rows
   the L1 appends for S145–S148. Those are the L1's to land; this seat's artifacts name
   what they must contain.

## Measurements behind the registry rows (this seat's own runs)

| gate | command | reading | rc |
|---|---|---|---|
| `plans/round-64-c1.sh` | `--tree .` (bytes `e03a4d69…`, frozen) | `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)`, 496 s | 0 |
| `plans/round-64-c1.sh` | `--selftest` | `C1_HELDOUT_SELFTEST: PASS (cases=19)` on sha `b07bc518…` | 0 |
| `plans/round-64-c1.sh` | `--selftest` (bytes `ca6dec9b…`) | `FINDING R64-C1-ST-vehicle-leg-zero` / `C1_HELDOUT_SELFTEST: FAIL (21/22 checks) failed=vehicle-leg-zero` | 1 |
| `plans/round-64-c1.sh` | `--selftest` (bytes `e03a4d69…`, frozen) | `C1_HELDOUT_SELFTEST: PASS (cases=23)` (547.56 s; W1 reads `heldout=3 … real=0`, W2 `heldout=5 … vehicle=0`, each rc 1) | 0 |
| `plans/round-64-c2.sh` | `--selftest` | `C2R64_SELFTEST: PASS (cases=21)` on sha `e2d8171f…` (frozen) | 0 |
| `plans/round-64-c2.sh` | `--tree .` | `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` on sha `e2d8171f…`, 625 s | 0 |
| `plans/round-64-controls.sh` | `--selftest` | `CONTROLS_SELFTEST: PASS (cases=34)` on sha `7e7492af…` | 0 |

The C1 counter's bytes moved repeatedly while this seat worked and its selftest count
moved with its own witness cases (19 → a red 22 → 23), so **the registry row for that
gate pins the count by digest rather than as a bare number**, and the L1 re-reads it at
integration. A full `--tree .` run on those bytes also exceeded an outer `timeout 1500`
inside the `resid` leg (its own budget is `RESID_TIMEOUT=1500`), so a reader cannot
currently run that gate inside the plan's 1200 s budget; both findings were reported to
the counter's owner with this seat's reproduction.

The C2 counter is green on its frozen bytes: one invocation terminated end-to-end with
`guard=1`, `killed=5 population=5`, `terminates=1`, `bound=1` — the round-63 `rc=124`
defect is closed. The controls battery's bytes were stable and its count is pinned with
the digest it was measured on.

## Coordination (what other seats must do for this seat's files to go green)

- **The L1 must mint the S145 registry row** and write its `used-by` cell as
  `corpus/knowledge/claim-instrument-heldout.md`. Until then
  `bash corpus/sources-census.sh` reports
  `FINDING SC_ENTRY_CITE entry=corpus/knowledge/claim-instrument-heldout.md id=S145 not-a-registry-row`
  and `… no tier A/B support`. The id was proposed by the round's scout
  (R64ScoutSources) and the records seat (R64ScribeRecords); both name the same URL and
  the same 13-word quote, `An equivalent mutant is a mutant which cannot be killed by any
  test` (locate count=1 in the captured PDF's text layer). If the L1 allocates a
  different id, the entry's `source:` line must be updated in the same commit — the
  content does not change.
- **The L1 must add the stamp row** for the new entry in `corpus/stamps.tsv`; otherwise
  `bash corpus/claim-ledger.sh docs` reads `UNPINNED corpus/knowledge/claim-instrument-heldout.md`
  and `DOC_AUDIT: BROKEN (entries=45 … unpinned=1 …)`. At the bytes measured at write time
  the row is `corpus/knowledge/claim-instrument-heldout.md  8145f470de91ddcd99e4f32daf22c603ca0d3597930e988e93f5475bab210c06  185  16677`
  (re-measure after the final text). `corpus/stamps.tsv` is not this seat's file.
- **The records seat must land `corpus/lessons/round-64.md`** — QM85 and QM86 cite it as
  their lesson pointer and the citation gate resolves that path.

## Files this seat did NOT touch

`plans/round-64-c1.sh`, `plans/round-64-c2.sh`, `plans/round-64-controls.sh`,
`plans/round-61-c1-check.py`, `plans/round-64-heldout.tsv`, `corpus/SOURCES.md`,
`corpus/stamps.tsv`, `corpus/lessons/round-64.md`, `corpus/README.md`, `LOG.md`,
`SCORECARD.md` and every fleet-root file. No git/jj mutation of any kind was performed
(`git log`/`status`/`ls-files`/`rev-parse` only); no `git add`, `commit`, `stash` or
`push`, and no mutating `jj` command, anywhere.

## Secret discipline

No secret value, unseal key, root token, OTP, cookie, session id or vault/item/field name
appears in any artifact of this seat. The receipts name shapes and counts only; no fetch
receipt was written by this seat (no URL was fetched — the captures were read from the
committed tree).

## Tooling

No tool was installed or upgraded. `/home/vgpnk/.omp/agent/RULES.md` was read first; the
host-wide pacman pause was therefore never reached. Nothing was written to any PATH
directory.

## Scratch

All scratch lived under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ScribeEntry/`
and was deleted before this report was filed. No citable evidence was written under /tmp.

SEAT-STATUS: complete
