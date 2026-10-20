# ReviewStamps — C2 freshness historic accounting (round 22)

Seat: ReviewStamps (read-only reviewer). Date: 2026-10-20.
Exact read revision: frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f` ("Integrate remote documentation; preserve local round log", 2026-10-19 22:05:06 -0300; parents `1e9e67ff`, `c03e12c0`), plus the live worktree state observed on top of it. Prior verifier: `.ufo/waves/kaika-w3/kagi-review.md` in the fleet repo (`/home/vgpnk/Projects/shokunin/`), head `e1544c194`, base `aea7a4301`.
Method: git plumbing with `--no-optional-locks` + in-memory `git show | sha256sum`/`wc` extracts. No lane gate executed, no jj command run (jj commands snapshot the working copy = live-state mutation), no installs, no writes except this report.

## Findings by severity

### HIGH F1 — "nine dropped rows" are in-place re-pins; nothing was dropped. Restoring them would manufacture work
`git diff --numstat aea7a4301 e1544c194 -- corpus/stamps.tsv` → `16 9`. The nine deleted lines all re-appear the same commit-pair with new hash/lines/bytes; path-set diff (`comm -3`, LC_ALL=C) over `aea7a4301` vs `e1544c194` row paths shows **7 additions, 0 removals**. Verifier wording ("stamps.tsv (9 lines deleted)", fleet `.ufo/waves/kaika-w3/kagi-review.md` §2) is diff-speak for re-stamping, which `SKILL.md:282-285` makes the documented contract: "Regeneration is a reviewed `stamp` commit — **no auto-re-pin**: a stale row is a question". The nine re-pins, fully attributed:

| # | path | old (hash-prefix l/b) | new (hash-prefix l/b) | byte cause | rewrite commit(s) |
|---|---|---|---|---|---|
| 1 | `corpus/claim-ledger.tsv` | `c8369a51` 49/13981 | `8a4019cf` 54/16986 | R21-01..04 rows added | `e1544c1`, `c41af82` |
| 2 | `corpus/knowledge/op-ref-consumption.md` | `dcd93894` 307/21164 | `b195cc69` 372/25290 | §11 DOTENV_OBS (6 ids) | `c41af82` |
| 3 | `corpus/op-ref-probe.sh` | `509f084a` 660/28660 | `0f1945e8` 788/34362 | M5 re-stamp of the arm that landed unclaimed *in* `aea7a43` (file itself predates the range — `git log aea7a43..e1544c1` on it is empty) | `c41af82` (stamps.tsv only) |
| 4 | `corpus/README.md` | `6ddda47d` 86/18689 | `6837d22b` 118/22365 | Frontier/Known gaps + count refresh | `e1544c1`, `c41af82` |
| 5 | `LOG.md` | `e6db90d2` 762/56847 | `60a8fd36` 1043/74864 | round-21 log append | `e1544c1`, `c41af82` |
| 6 | `PROVINCE.md` | `ffe644a7` 53/8172 | `4a346e2d` 62/10586 | round-21 edits | `e1544c1`, `c41af82` |
| 7 | `SCORECARD.md` | `f3e61bfe` 446/66069 | `29f9f023` 691/87010 | round-21 sections | `e1544c1`, `c41af82` |
| 8 | `SHONEN.md` | `efe81fa7` 11/4695 | `1bb89fc5` 12/1312 | `[x]`→`[~]` corrections | `c41af82` |
| 9 | `SKILL.md` | `c2b3151c` 663/57062 | `df05677f` 665/58395 | gateway/ledger section updates | `e1544c1`, `c41af82` |

Consequence: any C2 deliverable that "restores nine dropped stamps" adds nine phantom rows and moves R12-03 (63) off its measured value — row counting, the exact calibration proxy round 22 forbids. There is nothing to restore.

**Ambiguity trap:** a *different* nine exists — the base-`aea7a43` stale set (see F2/F3 below: five named-debt + `op-ref-probe.sh`, `README.md`, `LOG.md`, `SCORECARD.md`, all since re-pinned). The migration record must name both nines and their distinct referents (diff-rewrites vs hash-check mismatches) or the accounting conflates them.

### HIGH F2 — the frozen base carries a SIXTH stamp mismatch created after the verifier's head
At `e1544c1`, `LOG.md` matched its stamp exactly (`60a8fd36…` 1043 l / 74864 b = `git show e1544c194:LOG.md` measured). The round-22 base merge `c2cab35` appended +7 lines/+540 b to `LOG.md` (`git show --stat c2cab35`: LOG.md 7 insertions) **without re-stamping**: base bytes hash `51e76cf1…` vs stamp `60a8fd36…`. So at the frozen base the mismatch set is **6**, not the verifier's 5: the five named-debt rows (stale since round 16/19, deliberately unpinned — `corpus/lessons/round-21.md` §Named debt) plus `LOG.md` (stale since the base integration commit itself). A detector that reports "5 stale" at `c2cab35` is measuring the verifier's tree, not the round's; one that silently re-pins `LOG.md` launders an edit no round claimed (`SKILL.md:284-285`: the answer "belongs in the report"; the claimant here is the merge commit `c2cab35`, not a round).

### MEDIUM F3 — exact provenance of the five named-debt rows; restamp values are fully predictable
Current base bytes equal the bytes at each row's last claiming commit, measured bit-for-bit:

| path | current stamp (l/b) | base actual (l/b) | base hash | bytes = commit | that commit |
|---|---|---|---|---|---|
| `corpus/knowledge/config-layering.md` | 109/6621 | 136/8088 | `9d4ac8c2…` | **PROVENANCE-MATCH** | `f4a8dd92674e95231c50f361e8c69eb00c7e713b` (round-16 "qualify historical janitor source claims", 2026-10-15) |
| `corpus/knowledge/handler-on-disk-state.md` | 247/17609 | 277/19329 | `df6a5e5d…` | **PROVENANCE-MATCH** | `f4a8dd9…` (same) |
| `corpus/knowledge/handler-trust-boundary.md` | 285/17669 | 316/19410 | `fa17fff3…` | **PROVENANCE-MATCH** | `f4a8dd9…` (same) |
| `corpus/knowledge/janitor-env-contract.md` | 90/5111 | 113/6372 | `dac43ef9…` | **PROVENANCE-MATCH** | `f4a8dd9…` (same) |
| `corpus/lessons/round-18.md` | 73/4216 | 80/4557 | `b00b7dd8…` | **PROVENANCE-MATCH** | `bad9088f0298515b4249eee7b76ddbece6697f42` (round-19 audit corrections, 2026-10-14) |

All five edits were claimed, logged round work; only their stamp rows were left stale (round-21's deliberate choice: re-pinning "without review would bless edits no round claimed" — but the claiming commits are now identified above, so a round-22 reviewed re-pin citing them is contract-legal and launders nothing). `SKILL.md:435` ("Never re-pin inside the same round that discovers the drift") is satisfied: discovery was round 21.

### MEDIUM F4 — live lane worktree is dirty on top of the base (state observation, not base accounting)
`git status --porcelain` at review time: ` M` `corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; `??` `.ufo/waves/`, `corpus/lessons/round-22.md`, `plans/round-22.md`. Live-tree stamp scan therefore shows **10** mismatches: the six base ones + these four mid-flight round-22 files. The build wave contract says implementation seats use private clones; these live edits are either inherited lane state or an in-flight lane actor. They must NOT be absorbed into base accounting, and any pin computed from the live worktree would freeze unreviewed bytes.

### LOW F5 — detector must not be satisfied by membership-only
`docs` mode checks stamp *membership* while `verify` checks the hash — "a fabricated stamps row passes this mode and fails `verify`" (`SKILL.md:663-665`). `corpus/revision-audit.py` must classify a fabricated/absent path as `MISSING`/`NOT-A-FILE` (precedent selftest cases `stamps-missing`, `stamps-symlink-row`, `stamps-absolute-row`, `stamps-dotdot-row`, `stamps-empty-file` in `corpus/claim-ledger.sh:1215-1245,1285-1288`).

### LOW F6 — count pins that legitimately move with this round
R12-03 (stamps rows = 63), R21-04 (ledger rows = 39), R11-09/R18-03 (selftest 97 cases) all move when round 22 lands new files/rows/guards. Migration is expected; the bar (QM5/D6 precedent, fleet review §Ledger) is that each new value is the measured output at the landed tree, noted in place with the old value kept in the row's note chain — never a target-driven rewrite.

## Concrete acceptance conditions (C2 freshness)

- **A1 — exact reproduction at the frozen base.** The read-only detector on a `c2cab35` tree reports 63 rows: 57 OK, 5 STALE = {config-layering, handler-on-disk-state, handler-trust-boundary, janitor-env-contract, lessons/round-18}, 1 STALE `LOG.md` attributed to `c2cab35`, 0 MISSING. On the live worktree it additionally flags the 4 in-flight files as worktree-only drift. Collapsing to "5 stale" (parroting the verifier) or "10 stale" (ignoring the tree distinction) fails "measure actual state, distinguish later changes".
- **A2 — nine-re-pin migration table.** The round record carries the F1 table (old hash/l/b → new hash/l/b → cause → commit) and states zero path removals; it does not "restore" any row and does not move R12-03 except to the measured landed count.
- **A3 — restamp provenance for the five.** If re-pinned, each new hash must equal the claiming-commit bytes (`f4a8dd9…` ×4, `bad9088…` ×1) with the commit id + round-21 named-debt pointer in the migration note. If left stale, an append-only erratum lists them with this cause. Any other hash = fabrication.
- **A4 — LOG.md accounted separately.** The +7/+540 base-merge drift is attributed to `c2cab35` (not folded into the five, not re-pinned silently).
- **A5 — expectation migrations documented.** R12-03, R21-04, R11-09/R18-03 re-pins (if any) carry measured-at-landing values with old values preserved in the note; no other pinned expectation rewritten without a migration note.
- **A6 — detector hygiene.** Python stdlib, read-only (no writes anywhere, no jj/git state mutation), repo-relative paths only (refuse absolute/`..`), no host-private reads (unlike R18-01), no network, script-relative root (round-17 LANE_ROOT corrigendum), verdict fail-closed. Hash-checking a stamp proves revision identity only; the record must not present it as content re-verification (historic statements stay historic — plan C2 clause).
- **A7 — no forbidden claims.** No depth move, no legacy-header count claim, freshness score stays 9 absent independent evidence; C2 accounting never adjudicates vendor facts (causal separability from C1).
- **A8 — append-only surfaces.** Corrections to LOG/lessons/QUALITY land as appends; `stamps.tsv` edits are only the reviewed rows above.

## Falsifier

**C2 laundering test (must withstand).** After integration, run in the integrated clone:
1. `git --no-optional-locks diff <base>..<head> -- corpus/stamps.tsv` — for every changed row, its new hash must equal `git show <claiming-commit>:<path> | sha256sum` for a commit named in the migration note (`f4a8dd9…`/`bad9088…`/`c2cab35`/the round-22 landing commit for round-22-edited files).
2. `bash corpus/claim-ledger.sh verify` — the residual STALE set must be either empty (all six resolved per A3/A4) or exactly the five named-debt rows with the erratum on record — never a set containing `LOG.md` silently.

If `sha256sum --check` (or `verify`) goes green while any changed row's hash lacks committed-byte provenance — e.g. a stamp computed from the dirty live worktree — the round laundered unclaimed edits: REJECT. Predicted trap values to compare against (all measured at base today): `9d4ac8c2…`/136/8088, `df6a5e5d…`/277/19329, `fa17fff3…`/316/19410, `dac43ef9…`/113/6372, `b00b7dd8…`/80/4557, `51e76cf1…`/1050/75404.

**C1 variant (secondary, from the stamp seat).** The C1 qualifier gate, run against the `c41af82` bytes of the E1/E3 entries (the versions the outside spot-check failed 0/2), must REJECT citing the specific missing qualifier (E1 line-16 public-preview without EPM-Business eligibility scope; E3 "nothing expires" KV line + Vault→OpenBao label conflation). A gate that admits those bytes is calibrated to authored rows, not decisions.

## Limits

- Base comparisons used `git show` extracts, not a checked-out base tree; `verify` itself was not executed (it is a lane gate; parent runs it post-integration).
- jj was deliberately not queried (any jj command snapshots the working copy — live-state mutation). Git `--no-optional-locks` only.
- F4 live-tree edits attributed to "in-flight round-22 work" by content shape; authorship not established (KakeR22 seat overlaps on inherited lane state).
- Row 3's old value `509f084a` (660/28660) equals the `aea7a43`-era stamp; the probe file itself has no commit in the range — attribution rests on M5's record (`corpus/lessons/round-21.md` §M5), consistent with git.

## Proposed correction

Ship C2 as: F1 migration table + F3 provenance table + F2 LOG.md attribution, as append-only records (lesson/LOG), with `revision-audit.py` satisfying A1/A5/A6; re-pin the five + LOG.md only with the citing notes (or leave stale + erratum); migrate R12-03/R21-04/R11-09/R18-03 to measured values. Checks for the parent after integration: `bash corpus/claim-ledger.sh verify` (residual STALE set per falsifier step 2), `bash corpus/claim-ledger.sh --selftest`, `git --no-optional-locks diff base..head -- corpus/stamps.tsv` against the migration table, and the falsifier step 1 provenance loop.

Trailer: .ufo/waves/round-22/build/ReviewStamps.md
