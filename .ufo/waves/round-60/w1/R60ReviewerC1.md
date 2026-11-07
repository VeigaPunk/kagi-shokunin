# R60ReviewerC1 — C1 attack report (scoped)

Seat: reviewer/attack, leaf. Read-only on the lane. Full probe table (37 rows), the twelve
findings and the §A5 re-measurement:
`.ufo/waves/round-60/build/R60ReviewerC1/findings.md`. Reproducible fixtures and both
readers are in the same directory (`refcheck.py`, `mkfix.py`, `mkvariants.py`).

Pinned bytes: checker `63ef4304…` for the table and `268b27cb…` for the §A5
re-measurement (the checker was amended under §A5 `b662e11` while this seat ran), driver
`c11da5c6…`, C2 counter `a6fc9825…`, transit trial `bb18fba0…`. BASE `a677c78e…`; the lane
tree was moving throughout, so two repair snapshots are cited by content hash (`wt-1518`,
`wt-1540`).

## Verdict

The C1 item set is satisfiable and the guard challenge is faithful (`value+1` on zero and
nonzero trees, the constant-0 stub fails, a missing item file stays unresolved with
population 7). Before §A5 the set read resolved on several trees that were still wrong;
§A5 closed six of those findings and I re-verified each on the amended bytes. The amended
item set is satisfiable: a hand-built tree (`fix3`) reads `value=0 population=7 i1..i7=1`.

## Closed by §A5 (re-verified on checker `268b27cb…`)

| finding | before | after |
|---|---|---|
| I1 took the first matching line in its block; a later wrong restatement was ignored | `i1=1` | `i1=0` |
| I2's anchor was the first mention of `R31`; a decoy line relocated it | `i2=1` | `i2=0` |
| I5 accepted three one-line stub receipts | `i5=1` | `i5=0` |
| I6 was satisfiable by planting a `75165a07` anchor that superseded nothing | `value=0` rc 0 | `i6=0` |
| I7 accepted a PASS-printer `--selftest` (K4 violated) | `i7=1` | `i7=0` |
| a symlinked `LOG.md` passed (and the challenge wrote through it) | `value=0` rc 0 | `SETUP … symlink (refused)` rc 2 |

## Still open — declared ceilings, recorded so they are not claimed as coverage

- **Token-satisfying wrong facts**: `results=14 dead=0` beside `` `dead seats=14` ``;
  `PASS (33 cases)` beside "the checker actually runs 12 cases"; "holds 21 controls, not
  20; the receipt holds 20 controls"; `R20/- R21/- R22/-` plus "are not duplicates". The
  plan's "structural read, not a semantic proof" ceiling.
- **Receipt edits** (I2/I4/I6): rewriting `selftest.txt`, `controls-prefreeze.txt` or
  `c1-landed.txt` makes a false statement "right"; on the amended checker a tree with
  `measured=revision deadbeef…` and the new I6 line still reads `value=0`. K3 declares
  this; the non-author re-run must diff those three receipts against BASE.
- **Append-only false negatives**: a correction that quotes the literal it supersedes
  (`__DEAD__`, `(21 controls`) becomes its own anchor and reads 0 — this hit the round's
  own in-flight repair twice (`wt-1518`: `i1=0`, `i4=0`); an in-place rewrite reads 0.

## Live repair reading (snapshot `wt-1540`)

`value=3 population=7 i1=1 i2=1 i3=0 i4=1 i5=0 i6=0 i7=1` — I1 resolves (tolerant
`dead seats=` label); I3 (no round-60 lesson yet), I5 and I6 are open. The I1 line must not
quote `__DEAD__`; the I3 duplicate sentence must be one line.

## Controls battery

Before §A5 it could not read `mismatch=0`: K1-REF and C1-F2 were mismatched (the fixed
tree's I3 sentence was wrapped; fixed during the seat), C1-F1 mismatched because the
checker's I1 took the first line (now fixed by §A5), C1-F7 is inert against the checker's
I1 (it flips `dead seats=` while I1 reads the first `dead=`), and C1-F6 mutates a comment
so the mutated copy still passes. §A5 says the battery fixtures are restated — re-run it
against frozen bytes and pin the script hash.

## C2 (secondary, static only)

The counter's K3 scan is label-keyed: `sid=<uuid>` and a bare UUID in prose are not
matched, so a printed `secret_id` value escapes the only enforcement of K3. The selftest
conjunct accepts a PASS stub; K5's "must be able to fail" is only C2-F3. I did not run the
C2 real legs.

SEAT-STATUS: complete
