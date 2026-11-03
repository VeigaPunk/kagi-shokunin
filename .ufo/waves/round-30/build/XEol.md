# XEol — scoped findings (C2 pre-integration)

Full report: `.ufo/waves/round-30/XEol-report.md`.
Receipts: `.ufo/waves/round-30/final/c2/` (`c2-01`…`c2-22`).

## What I did

Proved the routed D5 repair in scratch against BASE `f67232c`, per file, and
drafted the integration procedure plus the `.gitattributes` set. No production
file touched; no lane git/jj mutation.

## Measured results

| counter | before | after |
|---|---|---|
| fleet census (`validate --root … kagi`) | exit 1, E12 ×52 | **exit 0**, 14 × W04 |
| `checklist-run.sh --ratio` | SETUP exit 2 | **exit 0**, `runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` |
| CR files, `.ufo`-excluded | 3 | **0** |
| CR files, literal plan command | 167 (wt) / 135 (archive) | **132** |
| `claim-ledger.sh verify` | 13 FAIL, 2 POLICY | **11 FAIL, 2 POLICY**, STALE 0 |
| `self-counts.py` | POLICY, setup=1, stale=8 | POLICY, **setup=0**, stale=8 |

Cleared by the EOL repair alone: **R11-08** (citations 19 unresolved → 0) and
**R15-05** (checklist ratio). Remaining 11 FAILs are C1's rows — C2 and C1 are
causally separable as the plan claims.

Per-file: `SOURCES.md` → census; `SKILL.md` → checklist **and** citations;
`claim-ledger.tsv` → no gate flips (stamp sha/bytes only).

## Two contract defects for the L1

1. **Frozen C2 counter 2 cannot reach 0.** 132 tracked `.ufo` files carry CR
   legitimately — 127 HTTP wire captures (`HTTP/2 200 \r\n …`) and 5 round-29
   receipt JSONs. The scoped counter (`--exclude-dir=.ufo`) is 3 → 0. Reaching
   literal 0 means normalizing evidence captures; that harms an axis.
2. **R30-01 cannot be the plan's pipeline.** `claim-ledger.sh` refuses `|` and
   `$` (`META_RE`); three candidate rows returned `POLICY … reason=metachar`, and
   `!` as first token is also refused. Use a delegate script — draft at
   `c2-18-eol-gate-draft.sh`, tested passing via the real runner and tested able
   to fail (DRIFT, exit 1) with one CRLF line reintroduced.

## Orders that matter (measured, not assumed)

- `sed -i 's/\r$//'` **before** the attribute work. `.gitattributes` +
  `git add --renormalize` makes the blob LF but leaves the worktree CRLF while
  git reports clean; the gates read worktree bytes.
- `stamp` replaces the row set and refuses to shrink: name every currently
  pinned path (`cut -f1 corpus/stamps.tsv`) in the same call, plus every new
  file (`.gitattributes`, `corpus/eol-gate.sh`, C3 knowledge entries), and do it
  **last** in the round.
- `.gitattributes` as proposed by the plan (five lines, no `.ufo` rule)
  renormalizes 8 files — it trips the plan's own kill-rule probe. Adding
  `.ufo/** -text -eol` narrows it to the 3 drifted files.

## Risks

- If C1 re-stamps before C2 lands, the stamp set and the `*STAMPS` doc cells must
  be recomputed again; `stamped=95` (96 with the gate script) is the post-C2 value.
- Plan's round context says six STALE cells; BASE measures **8** (the six routed
  plus the D4 pair `RD-DOCS-ROWLINKED`/`RD-DOCS-ENTRIES`). C2 changes none of them.
- `corpus/eol-gate.sh` is a new production file I could not create in the lane
  (my contract is advisory); the draft is ready at `c2-18-eol-gate-draft.sh`.

No tool installed; no pacman; `op` untouched; no credential or `op://` value read
or written.
