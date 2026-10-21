# Entry06 — `config-layering.md` revision/calibration audit (read-only)

Axes: **calibration** (accept/reject bounded decisions, not row counts) and
**freshness** (pointer integrity at the frozen base, not source currentness).
Scope: `corpus/knowledge/config-layering.md` and its single pin row. Read-only;
no production file, ledger, log, or host state was written. No subagents.

## Read revision (exact)

- Base commit: `c2cab35bc92e57e39e5489bac3386db078345b3f`
  (`Integrate remote documentation; preserve local round log`).
- Target blob at base: `808614ffa1b8adb305505fefb0b845633a27b39f`;
  sha256 `9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0`,
  **136 lines, 8088 bytes**.
- Stamp row: `corpus/stamps.tsv:14` (base blob
  `aef5db6501082655ee4c3cb8155189c0961e4277`, 63 non-blank rows):
  `848b8e502ea2046aacd3f8ae1717d6a4882b07c9317d13d012eb5bae6c88fe83` /
  **109 / 6621**.
- `git diff c2cab35 -- corpus/knowledge/config-layering.md corpus/stamps.tsv`
  is empty; the file's mtime is 2026-10-15 01:58 and no commit after
  `f4a8dd9` touches it (`git log f4a8dd9..c2cab35 -- <path>` → 0 lines).
- No second pin: no row in `corpus/drift-baseline.tsv`, `drift-pins.sh`, or
  `drift-symbols.tsv` names this path. `stamps.tsv` is the sole pin.

## Observed: stale bytes, and exactly why

Comparator (same columns and 12-char prefix format as `verify_stamps`,
`corpus/claim-ledger.sh:334-366`):

```
STALE corpus/knowledge/config-layering.md sha=848b8e502ea2->9d4ac8c24981 lines=109->136 bytes=6621->8088
```

The mismatch is **revision lag from one pure append**, not content drift:

- `f4a8dd92674e95231c50f361e8c69eb00c7e713b` ("round-16: qualify historical
  janitor source claims") changed this file `+27 −0` (hunk
  `@@ -107,3 +107,30 @@`). No other commit touched it afterwards.
- The pinned tuple is exactly the **pre-erratum blob**:
  `git show f4a8dd9^:<path>` → sha256 `848b8e50…`, 109 lines, 6621 bytes.
- Append-only proof: `git show c2cab35:<path> | head -c 6621 | sha256sum`
  → `848b8e50…`, 109 lines. Byte 6621 is the newline ending line 109; the
  erratum begins at line 111.
- Therefore every pinned byte is preserved as a strict prefix; zero original
  bytes were rewritten or deleted.

## Observed: substantive freshness (what the append already settles)

- The file carries a document-level `Source-status: historical` marker
  (lines 113-114) and an enumerated qualification of original lines
  3-6, 8-22, 24-46, 48-54, 56-66, 68-81, 83-101 (lines 116-120). Checked
  against the 109-line original numbering: each boundary is exact.
- Line 58's `af8873ca…` is inside the qualified 56-66 range; the erratum
  states the abbreviated hash is "preserved, not re-asserted as current
  properties" (lines 119-120). The QM1 requirement (absent-source property
  only under a historical marker) is met.
- Minor, non-defect observation: the enumerated ranges stop at 101 and omit
  the anti-claims at 103-109. Those are already self-bounded ("this-version
  semantics (1.18.31)"), and the document-level `Source-status` sentence
  covers "this entry's source-derived claims and recipes" as a whole.
- SCORECARD's Round-19 correction block (`SCORECARD.md:458-470`) is dated
  2026-10-14 and its unblock ("mark those lines historical in an append-only
  erratum") was executed the next day; `SCORECARD.md:512-548` records the
  outcome. No current-voice assertion that the line-58 defect is open remains.

## Observed: absent-source limits (metadata only, 2026-10-20)

No source bytes, resolver output, or janitor state were read.

| path cited by the entry | state today |
|---|---|
| `~/.local/bin/the-janitor` | absent |
| `~/.config/the-janitor/client.py` | absent |
| `~/.config/the-janitor/config.json` | absent |
| `~/.config/the-janitor/opencode.json` (overlay layer) | absent |
| `~/.config/opencode/agents/janitor.md` (agent layer) | absent |
| `~/.config/opencode/opencode.json` (global layer) | present, 0600, **95 bytes** (entry describes 455 lines) |
| `opencode` binary | present at `~/.local/bin/opencode`, **1.19.3** (entry measured 1.18.31) |

Consequences, bounded:

1. The entry's three enumerated absent sources are still absent 3/3, so its
   own limit statement remains true.
2. The global layer and the resolver binary no longer match the 2026-09-28
   inputs. Any future `opencode debug` probe on this host measures **1.19.3**
   semantics, i.e. a new observation, not a restoration of the pinned one.
   "Exact `_serve` environment" therefore also requires the 1.18.31 binary;
   restored handler sources alone are insufficient.
3. Nothing above is a reason to edit the entry: reuse is already blocked and
   the drift is a host fact, not an entry assertion.

## Decision: is an appended correction needed?

**No new append to `config-layering.md`.** The needed correction is on the
ledger side only.

- QM1 is already satisfied by the round-16 append; a second prose append for
  the 1.19.3/95-byte host drift would add a dated claim that itself needs a
  stamp and would not change the reuse decision (still blocked).
- C2 is defined as "revision mismatch/deletion accounting, not source
  currentness by restamping" (`corpus/lessons/round-22.md:8`); a prose append
  here would read as currentness work and risks a depth implication.
- Falsifier for this decision: if the parent requires the version drift to live
  in the entry, it must be a new dated append, and the stamp must be regenerated
  in the same commit (QM5), never silently restamped.

**The stale pin itself is a defect under the current bar.** QM5 (`QUALITY.md:43`)
states "a pin that lags the artifact's bytes is a defect, not inherited debt";
QM12 (`QUALITY.md:60`) supersedes only the `verify`-invocation clause, not the
pin update. Round-21's "stale stamps left unpinned on purpose" note
(`round-21.md:85`) precedes the post-landing review that added QM5/QM12
(`round-21.md:93`), and its stated reason — "re-pinning would bless edits no
round claimed" — does not apply here: `f4a8dd9` and `SCORECARD.md:512-548`
claim and record the edit.

## Exact proposed recheck scope

Run against the **commit tree**, never the mutable working tree (see the
method note below).

```bash
p=corpus/knowledge/config-layering.md
git show c2cab35:$p | sha256sum                       # 9d4ac8c24981…
git show c2cab35:$p | wc -lc                          # 136 8088
git show c2cab35:corpus/stamps.tsv | grep -F "$p"     # 848b8e50… 109 6621
git show c2cab35:$p | head -c 6621 | sha256sum        # 848b8e50… (prefix proof)
git diff f4a8dd9^ f4a8dd9 -- "$p"                     # +27 −0 append
```

Expected row after an in-place re-pin (preserve column order, tabs, and row
position; do not add or delete rows):

```
corpus/knowledge/config-layering.md	9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0	136	8088
```

Do **not** use `bash corpus/claim-ledger.sh stamp` for this: it replaces the
whole row set and requires all 63 paths; `--prune` could drop a path. Do **not**
run `bash corpus/claim-ledger.sh verify` (its untagged `R18-01` reads
host-private surfaces — `round-21.md:84`). The base-object comparison above is
the QM12-style per-row substitute and touches no host-private file.

## Provenance chain

| fact | evidence |
|---|---|
| pinned tuple = pre-erratum blob | `f4a8dd9^:corpus/knowledge/config-layering.md` → sha256 `848b8e50…`, 109/6621 |
| shipped tuple = post-erratum blob | `c2cab35:corpus/knowledge/config-layering.md` → sha256 `9d4ac8c2…`, 136/8088 |
| append, not rewrite | `git diff f4a8dd9^ f4a8dd9 -- <path>` → `+27 −0`; `head -c 6621` matches old pin |
| the edit is claimed | commit `f4a8dd9`; `SCORECARD.md:512-548` (round-16 outcome, `SOURCE_PRESERVATION: preserved=4/4`); `LOG.md:789-793` |
| no later edit | `git log f4a8dd9..c2cab35 -- <path>` → empty |
| pin still present (not a deleted stamp) | `corpus/stamps.tsv:14` at base; `.ufo/waves/round-22/historical-migrations.json` has `deleted_stamps: []` |

Required migration record if re-pinned (append to
`.ufo/waves/round-22/historical-migrations.json`; do not edit its
`deleted_stamps` or `snapshot_semantics` fields):

```json
{
  "path": "corpus/knowledge/config-layering.md",
  "from": {"sha256": "848b8e502ea2046aacd3f8ae1717d6a4882b07c9317d13d012eb5bae6c88fe83", "lines": 109, "bytes": 6621},
  "to": {"sha256": "9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0", "lines": 136, "bytes": 8088},
  "cause_commit": "f4a8dd92674e95231c50f361e8c69eb00c7e713b",
  "change": "append-only: +27 lines, 0 deletions",
  "prefix_proof": "head -c 6621 of the new blob hashes to the old sha256",
  "membership": "retained; row present at base, not a deleted stamp",
  "currentness": "none claimed; cited sources 3/3 absent 2026-10-20"
}
```

## Expectation migrations

- `R12-03` pins `grep -c '[^[:space:]]' corpus/stamps.tsv` → `^63$`
  (`corpus/claim-ledger.tsv:28`). An **in-place replacement keeps 63**, so
  `R12-03` needs no migration for this file. If dropped rows are restored
  elsewhere, the count changes and `R12-03` must be updated with old/new
  evidence, not rewritten silently.
- No claim row pins this file's hash; `corpus/stamps.tsv` is not self-pinned
  (only `corpus/drift-baseline.tsv` is), so replacing row 14 adds no
  second-order stamp update.
- `docs` mode checks stamp **membership only** (`stamp_index`), so the current
  stale row passes `docs` and fails only the hash arm of `verify`; re-pinning
  does not change the `DOC_AUDIT` counts.

## Append-only preservation requirement

1. `config-layering.md` must not be edited at all for this move; 136/8088 is
   the final byte state. Any future correction is appended after byte 8088.
2. The pre-erratum tuple (`848b8e50…`, 109/6621) must remain reproducible via
   `head -c 6621` and must be recorded in the migration journal before the row
   is replaced. Never delete or "correct" the old tuple.
3. The round-16 erratum (lines 111-136) and the original text (lines 1-109) are
   both preserved; no legacy `source:`/`verified-at:`/`recheck:` header is to be
   drafted for this entry in this round.
4. If any tool ever shrinks `stamps.tsv`, the row-set guard
   (`claim-ledger.sh:245-255`) must be allowed to refuse, not bypassed with
   `--prune`.

## Calibration decisions (bounded)

| decision | verdict | basis |
|---|---|---|
| line-58 `af8873ca…` is a current property of `config.json` today | **REJECT** | path absent 2026-10-20; erratum says not re-asserted as current |
| the 2026-09-28 observations are usable as historical, deterministic observations | **ADMIT** | append-only erratum; no model call/vault in the original method |
| the line-58 debt is still open in the prose | **REJECT** | erratum qualifies 56-66; `SCORECARD.md:512-548` records the move |
| restoring the three handler sources alone suffices to re-verify | **REJECT** | cited resolver is 1.18.31; host binary is 1.19.3; global layer is 95 B, not 455 lines |
| the stale pin may remain as inherited debt | **REJECT** | QM5 as amended by QM12; the edit is claimed by `f4a8dd9` |
| an appended prose correction to this entry is required | **REJECT** | QM1 already met; no reuse decision changes |

## Method caveat (important for the C2 owner)

Measured on the **live working tree**, the same comparator first returned
**eight** stale rows, because four production files were concurrently modified
in the live tree (`QUALITY.md`, `SOURCES.md`,
`onepassword-machine-credentials.md`, `vault-openbao-token-lease-lifecycle.md`;
`git status` shows them modified vs base). Those four are exactly the C1/E1/E3
surfaces, but this seat did not identify the writers; the attribution to
concurrent author seats is **[INFERENCE]**, the `git status` fact is observed.

`SOURCES.md` changed hash twice during this audit (`d4dcea90…` → `a4edd52c…`
→ `e4afe6d0…`). Re-measured from
`c2cab35` git objects, the result is exactly **six**, matching
`.ufo/waves/round-22/before.json` and `corpus/lessons/round-22.md:38`: the four
round-16 errata entries, `lessons/round-18.md`, `LOG.md`. The two extra
live-tree mismatches are uncommitted C1 work and must not be counted as base
debt or as dropped stamps. A freshness detector that reads the working tree
will be contaminated by any concurrent author seat.

## Remaining unknowns

- Whether the parent intends to re-pin all six at integration or only record
  them; this audit establishes config-layering's tuple and provenance only.
- The nine deleted-stamp restorations are outside this seat (row 14 was never
  deleted; `.ufo/waves/round-22/historical-migrations.json` currently records
  `deleted_stamps: []`).
- No current resolver behaviour is known: the 1.18.31 binary is unavailable and
  no probe was run.

## Checks the parent should run after integration

1. Recompute all six stale rows against the integrated revision (commit tree):
   each replaced tuple must equal `sha256sum` and `wc -lc` of its blob.
2. `grep -c '[^[:space:]]' corpus/stamps.tsv` → `63` unless membership
   restoration changes it; if changed, update `R12-03` with old/new values.
3. `bash corpus/claim-ledger.sh docs` → `DOC_AUDIT: CLEAN (… unpinned=0 …)`
   (membership retained).
4. `bash corpus/claim-ledger.sh citations --docs corpus/knowledge/config-layering.md`
   → `CITATION_GATE: CLEAN` (corpus-only; not run by this seat).
5. `git diff c2cab35 -- corpus/knowledge/config-layering.md` must stay empty;
   the correction is ledger-only.

No host gate was run. No source bytes were read. No installs or updates were
made. No depth claim is made.
