# R58ExecCounterC2 — round-58 C2 counter (C2_POLICY_TRIAL)

Seat: executor. Deliverable: `plans/round-58-c2.sh` (the C2 counter), built to the
frozen predicate in `plans/round-58.md`. Non-goals respected: no trial edits, no docs.
Counter sha256 (final bytes):
`8baaf3486f1390d99c67e5406655ae177b68ef89024c6a1a3b0b1f13a5dd11b0`.

## Readings (all receipts under `.ufo/waves/round-58/build/R58ExecCounterC2/`)

| reading | receipt | line | rc |
|---|---|---|---|
| BASE, default revision | `receipt-c2-base-absent.txt` | `C2_POLICY_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)` | 0 |
| BASE, explicit rev `1b13f5da…` | `receipt-c2-base-rev.txt` | same absent line | 0 |
| BASE via `--tree` (extract) | `receipt-c2-base-tree.txt` | same absent line | 0 |
| bad revision `deadbeef…` | `receipt-plumbing-badrev.txt` | `… guard=0 (bad-revision)` | 1 |
| bad `--tree` (nonexistent dir) | `receipt-plumbing-badtree.txt` | `… guard=0 (bad-tree)` | 1 |
| tree carrying the trial (PROVISIONAL) | `receipt-c2-candidate-worktree-PROVISIONAL.txt` | `C2_POLICY_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 wrap=1 secret=1)` | 0 |

The trial **is now present** as uncommitted work-tree bytes
(`corpus/openbao-policy-trial.sh`, R58ExecTrial's final pin
`1f1eed9d872a1a1367d737d63a45f1d8eb2c9fe6fa322d5e96a95dba934d0b4a`), so I ran the
candidate leg against the work tree: **value=5, rc 0, 166 s**. This is a *provisional*
reading over uncommitted bytes — the candidate measurement over the committed
candidate revision belongs to the L1 (one `bash plans/round-58-c2.sh <rev>` run, ~3 min).
The BASE claim reading is `value=0 (absent)`, rc 0, as the frozen plan declares.

## The counter

Same class and conventions as `plans/round-57-c2.sh`: takes a revision or `--tree DIR`
(BASE when omitted), extracts via `git archive | tar` into
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/c2-counter.$$` (self-cleaning), and
prints one `C2_POLICY_TRIAL:` line. Legs: `real`, `real2`, `none`, `sh1..sh5`, `wrap`,
executed in `shuf` order, each under `env -i` (ambient `BAO_*`/`VAULT_*` cannot reach
the trial), `timeout 900`, per-leg `--work` dirs, run-log names drawn from `rhex`
(outside every dir the trial is given — round-51 M51-2). The bao sha256 pin is read at
runtime from `plans/round-57-c2.sh` **in the counter's own checkout**
(`PIN_BAO=9c5f3628…`, exactly one match required), so a forged measured tree cannot move
it; a wrong/missing binary is `SETUP bao-pin-mismatch` rc 2; a `bao` in `/usr/bin` or
`/bin` is SETUP. Value semantics: pass=5 iff both real runs are HHHHH rc 0 with summary
`OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0`; value=5 iff pass=5 ∧ all five
shim vectors match ∧ none-leg (rc 2, no `HOLDS` anywhere) ∧ wrap leg (HHHHB rc 1) ∧ no
secret-shaped string in any receipt. Exit: 5→0, present-but-failed→1, absent→0,
bad-rev/bad-tree→1, SETUP→2.

**Exit-code note for the L1:** the seat spec says the absent leg "exits 0"; the frozen
plan's Commands line says "exit 0 iff value=5". I resolved this as r57's counter does
(its absent leg also exits 0): absent = the BASE control reading (rc 0, guard=0), while
every *present-but-failed* reading exits 1 and SETUP exits 2. Flagging so integration
is deliberate.

## The wrapper's exact lie (wrap leg)

The PATH wrapper is byte-identical delegation to the pinned real binary except one
interception: any invocation whose argv is `token capabilities` (any further arguments)
is answered with the literal line `deny` and exit 0 — regardless of the token's real
capabilities or the queried path. Source embedded in the counter:

```bash
REAL=$(cat "$(dirname "$0")/.real")
if [ "${1:-}" = token ] && [ "${2:-}" = capabilities ]; then echo deny; exit 0; fi
exec "$REAL" "$@"
```

A conforming trial measures T5 through this client-side introspection, reads
caps=`deny` ≠ expected `update`, classifies T5 BROKEN (rc 1) and keeps T1–T4
server-side HOLDS → exactly HHHHB. R58ExecTrial confirmed this reading against their
final bytes before my run (their own receipts used a different, union-shaped lie — the
counter supplies its own wrapper, so the two do not interact).

## Shim vector table (frozen predicate, measured)

| leg | env | expected vector | trial rc |
|---|---|---|---|
| real / real2 | — | HHHHH + summary HOLDS holds=5 broken=0 error=0 | 0 |
| SH1 | `KAGI_POLICY_SHIM=SH1` | BHHHH | 1 |
| SH2 | `KAGI_POLICY_SHIM=SH2` | HBHHH | 1 |
| SH3 | `KAGI_POLICY_SHIM=SH3` | HHBHH | 1 |
| SH4 | `KAGI_POLICY_SHIM=SH4` | HHHBH | 1 |
| SH5 | `KAGI_POLICY_SHIM=SH5` | HHHHB | 1 |
| none | no `bao` on PATH | SETUP, no HOLDS line anywhere | 2 |
| wrap | wrapper lies `deny` on `token capabilities` | HHHHB | 1 |

Trial interface the counter measures (also stated in the counter header, agreed with
R58ExecTrial): invocation `bash corpus/openbao-policy-trial.sh --work DIR`; `TRIAL T<n>
HOLDS|BROKEN|ERROR <detail>` ×5 exactly once each, then
`OPENBAO_POLICY_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>`;
exit 0/1/2; `KAGI_POLICY_SHIM=SH1..SH5` flips exactly its designated test; `bao`
resolved through PATH only; T5 the only client-side-introspected test.

## Counter-side plumbing validation (NOT candidate evidence)

A conforming scratch stub (no real server; labeled STUB in its header, copies kept as
`plumbing-stub-*.txt`-named siblings `plumbing-stub-trial.sh`
`577c2596…`, `plumbing-stub-noshim3.sh` `8157aae4…`, `plumbing-stub-honestwrap.sh`
`8a46dcee…`) exercised the present-branch plumbing end to end:

- honest stub tree → `value=5 … vectors=ok/5 guard=1 (real=1 none=1 wrap=1 secret=1)` rc 0
  (`receipt-plumbing-stub-value5.txt`), and identically with hostile ambient
  `BAO_ADDR`/`VAULT_ADDR`/`BAO_TOKEN=hvs.…`/`VAULT_TOKEN=r58-…` exported by the caller —
  the shaped values never surfaced (`receipt-plumbing-stub-ambientenv.txt`; C2-F8 class);
- SH3-blind stub → `value=0 pass=5 shims=4 vectors=4/5` rc 1
  (`receipt-plumbing-stub-noshim3.txt`; C2-F6 class);
- introspection-blind stub → `value=0 … wrap=0` rc 1
  (`receipt-plumbing-stub-honestwrap.txt`; C2-F3 class);
- `R58_BAO=/bin/true` → `C2_POLICY_TRIAL: SETUP bao-pin-mismatch` rc 2
  (`receipt-plumbing-baopin.txt`; C2-F7 class).

## Secret discipline

Receipt scan implements the frozen K3 shapes exactly: `r58-[0-9a-f]{24}`,
`(^|[^A-Za-z0-9])(hvs|hvb)\.` over every leg's stdout+stderr. The counter puts no token
on any argv (it passes only `--work` and the shim env). My provisional run's
`secret=1` confirms no hit. No receipts under /tmp; no pacman transactions; no tools
installed (none needed).

## Risks / handoff

1. The trial↔counter interface is a joint convention (counter header + my peer message
   to R58ExecTrial), not independently frozen text. If the trial's committed bytes change
   the summary line, shim env, or T5 introspection form, the counter reads 0 — that is
   fail-closed, but the L1 should re-run the counter once against the committed candidate.
2. K2 ceiling stands (as declared): an absolute-path, shape-keyed trial can read 5 here;
   the receipts, the wrapper leg and a non-author probe carry that check, not this counter.
3. `guard=1` on the present path means "all ten legs ran"; a hung trial hits `timeout 900`
   and fails closed (rc 124 legs → value=0). Ten sequential real legs took ~166 s total.
4. The pre-freeze controls battery (C2-F1..F8) is another seat's file; my stub runs are
   counter-side plumbing confirmation, not a substitute for it.

Blockers: none.
