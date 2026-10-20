# CriticFreshness — byte pins are not re-verification

Axes attacked: **freshness** (primary), **calibration** (secondary — a laundered pin
inflates `stamp_pointed` score-card support). Read revision: frozen base
`c2cab35bc92e57e39e5489bac3386db078345b3f`, working tree at that commit except two
uncommitted verifier-scope files (`corpus/SOURCES.md`,
`corpus/knowledge/onepassword-machine-credentials.md` — wave edits, not my concern
here). All facts below re-derived from `git show`/`sha256sum` on the frozen tree.

## The laundering channel

`stamps.tsv` is a point pin: `path <TAB> sha256 <TAB> lines <TAB> bytes` means
"the reviewer read *these bytes*". It carries **no provenance** — no commit, no
reviewer, no measurement basis (`corpus/knowledge/claim-ledger.md` §Class 1,
bound 4: "the stamp says 'this is the revision I read', not 'this file never
changed'"). `verify` compares bytes only. That is exactly what makes restamping a
laundering operation:

- A drifted stamp is a question: *was this edit intended, and does the content
  still say what earlier claims believed it said?* A fresh `stamp` row answers
  neither — it only re-adopts the bytes. `sha256sum --check` then reports the
  same verdict for "the file was re-read and the new content was adjudicated"
  and for "the hash was copied forward sight-unseen". Debt is laundered from
  *named* to *invisible*.
- A restored dropped row inherits the same trap: a row's authority is the read
  event that produced it. A row produced by copying bytes from a *different*
  revision (e.g. the remote branch's `stamps.tsv`) asserts a read that never
  happened here.

## What the frozen corpus actually contains (evidence)

- `corpus/stamps.tsv`: 63 rows. `sha256sum --check` → **7 mismatches** (I
  measured all 7; the "5 named debt" rows plus two wave-scope additions):

  | path | stamped sha | actual sha | drifted by |
  |---|---|---|---|
  | `corpus/knowledge/config-layering.md` | `848b8e50…` | `9d4ac8c2…` | `f4a8dd9` round-16 errata (2026-10-15), stamp never moved |
  | `corpus/knowledge/handler-on-disk-state.md` | `811572dc…` | `df6a5e5d…` | same |
  | `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e…` | `fa17fff3…` | same |
  | `corpus/knowledge/janitor-env-contract.md` | `88dca63a…` | `dac43ef9…` | same |
  | `corpus/lessons/round-18.md` | `614335f2…` | `b00b7dd8…` | `bad9088` round-19 erratum appended, stamp never moved |
  | `corpus/SOURCES.md` | `db134917…` | `d4dcea90…` | uncommitted wave working-tree edit |
  | `corpus/knowledge/onepassword-machine-credentials.md` | `7635be81…` | `e885081e…` | uncommitted wave working-tree edit |
  | `LOG.md` | `60a8fd36…` | `51e76cf1…` | merge `c2cab35` itself (+7 lines) — an 8th row if counted |

  The five named debt rows were deliberately left stale: `SCORECARD.md:549-552`
  — "inherited stamp debt … left untouched, **not re-pinned to manufacture a
  clean run**".

- The **nine deleted lines** the outside verifier counted
  (`.ufo/waves/kaika-w3/kagi-review.md:19`) are real: `git diff aea7a43 e1544c1
  -- corpus/stamps.tsv` removes 9 lines — `claim-ledger.tsv`,
  `knowledge/op-ref-consumption.md`, `op-ref-probe.sh`, `corpus/README.md`,
  `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md` — each
  replaced by a fresh reviewed restamp line in the same commit. These are
  *replaced* rows, not *dropped* coverage: the `stamp` verb rewrites whole rows
  (`claim-ledger.sh:236`, "replaces the row set"). Calling them "dropped" and
  "restoring" them is the first laundering trap (below).

- A second, older "dropped" set exists on the **remote** side of the merge:
  `c03e12c:corpus/stamps.tsv` is byte-identical to `fecee87` (round 18) — it
  lacks all 7 round-21 additions (`QUALITY.md`, `SOURCES.md`,
  `sources-census.sh`, `knowledge/onepassword-machine-credentials.md`,
  `knowledge/sops-age-key-rotation.md`,
  `knowledge/vault-openbao-token-lease-lifecycle.md`, `lessons/round-21.md`) and
  pins `LOG.md` at `e6db90d2…` (762 lines, the remote revision) instead of the
  local `60a8fd36…`. The merge correctly kept local rows, but any "restore
  missing pins" step that treats the remote file as history could adopt a
  `LOG.md` row asserting bytes never held in this checkout — false provenance.

## One concrete counterexample

Take `corpus/knowledge/handler-on-disk-state.md`. Its `Reverify:` line
(`:16`) declares `R11-01, R11-04` — both substrate-dependent rows that now
`DEFER` (the janitor handler is absent; `corpus/claim-ledger.tsv` row
`R18-01`..`03` named debt). Its `f4a8dd9` erratum is *itself* the thing that
demoted the entry's claims to "historical — observations from 2026-09-28, not
current handler guarantees" (`config-layering.md:111+`, mirrored in the other
three entries; `SCORECARD.md:514-538` records `absent_sources=3/3` as the
residual state).

**Attack:** a C2 implementation that closes freshness by `stamp`-ing the five
stale rows (or by restoring the nine `aea7a43` stamp lines byte-for-byte)
produces `CLAIM_LEDGER` stamp section fully green — `stale_pointers=0`,
`stamped` count unchanged or restored — while the corpus's *own* measurement
(the `SOURCE_FRESHNESS` counter in `SCORECARD.md:505`) still reads
`absent_sources=3/3` and every `Reverify:` row still defers.

**Expected failure:** score-card cells citing `handler-on-disk-state.md`
increment `stamp_pointed` (`claim-ledger.sh` §cells), which the contract
defines as "a score resting on a frozen document" — and the summary prints as
if the document's revision were adjudicated. The verifier's round-21 check
(`kagi-review.md:66`: "9 mismatches → 5 mismatches … only the 5 named-debt
rows") becomes **0 mismatches** with zero of the underlying questions answered:
(a) was `f4a8dd9`'s errata content adjudicated? (b) is `bad9088`'s round-18
correction accepted? (c) do the two wave-scope working-tree files belong in the
round-22 commit? A future critic reading a green stamps set loses the only
in-repo signal that these questions exist. The drift *stayed real* — the
debt's *name* was deleted. That is laundering.

The symmetric trap on the restore side: a "restore the nine dropped stamps"
implementation that re-appends the `aea7a43` row for `corpus/claim-ledger.tsv`
(`8a4019cf…`, 54 rows / 16986 bytes at `aea7a43`) plants a **false** pin —
the file is the post-`1e9e67f` ledger (`c8369a51…`). `verify` would then print
`STALE` on a row that was never live at this revision, or worse, an operator
"fixes" the file to match the stamp and *deletes* the R21 rows. Silent
deletion in reverse.

## Smallest safe correction (bounded fix)

1. **Audit before stamp, and keep the audit output as the artifact.** The
   `revision-audit.py` contract (stale / missing / dropped vs `--history`) is
   the right shape; require its findings list in the round report next to every
   restamp. A `stamp` invocation without the audit output attached is refused
   as evidence — restamping must name the old sha, the new sha, and the
   drifting commit (`f4a8dd9`, `bad9088`, `c2cab35`, uncommitted) per row.
2. **Pin restoration is byte restoration, not row restoration.** A re-added
   stamp row must be generated by hashing the current file, never copied from
   another revision's `stamps.tsv` (remote `c03e12c` `LOG.md`/`claim-ledger.tsv`
   rows are provably wrong for this tree). Row count changes must migrate the
   `R12-03` expectation (`^63$`) with the history cell updated — the
   "28→33→44→48→52→54→56→63" chain is precedent that expectation edits
   carrying counts are *documented migrations*, and a silently changed
   `^N$` ERE is laundering by expectation.
3. **Stamps and `Reverify:` stay split.** A restamped entry's `Reverify:`
   rows (`R11-01`/`R11-04`/`R21-02`/`by-hand:` classes) keep their own clocks;
   no stamp may be cited as satisfying them. If a C2 claim reads "entries
   re-verified", the evidence is re-run rows or re-opened sources, not
   `stale_pointers=0`.
4. **Historic statements stay historic.** The `aea7a43` stamped values
   (`8a4019cf…` etc.) are historic evidence of what was read then — they are
   never rewritten to current bytes in a narrative cell, never "corrected" in
   place. Migration entries append the new expectation; the old sentence stands
   superseded (the `SCORECARD.md` round-19-correction pattern is the precedent).

## Impacted axes

- **freshness**: a green stamps set is a byte claim only; C2 must demonstrate
  *named-debt disposition* (each stale row either re-adjudicated or carried as
  named debt) and *byte-verified restoration*, not `0 mismatches`.
- **calibration**: `stamp_pointed` is a proxy a laundered restamp inflates
  without any re-read; the verifier's own check (mismatch count) is a
  necessary-but-not-sufficient signal and must not be presented as the axis
  measurement.
- **no-harm**: restoring remote-side stamp rows, or re-pinning the two
  uncommitted wave files without flagging them as in-flight, writes false
  provenance into the ledger — the same defect class this milestone exists to
  fix.

## Limits

- The two `SOURCES.md`/`onepassword-machine-credentials.md` stale rows are
  uncommitted working-tree edits, presumably this wave's; their disposition
  belongs to the integrator, not to this finding.
- I did not execute `claim-ledger.sh verify` (its `R18-01` row reads host
  files); the 7-row mismatch count above is an independent `sha256sum`
  comparison, agreeing in shape with the verifier's `aea7a43`→`e1544c1`
  9→5 measurement.
- Whether `LOG.md`'s merge-drift counts as a sixth named-debt row or an
  intended post-stamp append is an L1 adjudication question; I report it as an
  eighth observed mismatch at HEAD.

Checks the parent should run after integration: `corpus/revision-audit.py`
against `--history aea7a4301034aa9160ada69457a6427f77064169` and
`--history c03e12c` (remote side), `sha256sum --check` over `corpus/stamps.tsv`,
`bash corpus/claim-ledger.sh docs`, and the `R12-03`/`R14-01` row re-runs.

No installs performed; no tools installed (read-only seat).
