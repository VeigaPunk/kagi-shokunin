# AttackEntry10 — falsification of integrated C2 for `corpus/knowledge/handler-on-disk-state.md`

Seat: read-only reviewer (falsify wave). Lane bounds honored: no subagent dispatch, no production writes, no host gates, no installs (none needed).
Exact read revision: integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (resolved by full hash, never inferred from detached HEAD); frozen-input hashes taken from `.ufo/waves/round-22/integration-manifest.json` (file sha256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`).
Axes: **calibration, freshness** (milestone: falsify integrated feature decisions and revision accounting).

## Frozen-input hashes named (integration-manifest.json)

| Input | Manifest sha256 (bytes / lines) | Observed worktree sha256 | Match |
|---|---|---|---|
| `corpus/knowledge/handler-on-disk-state.md` | `556fe70b681af58b35ac55a562f77ca089994a4d67260578e9db93d6d4f2869c` (19837 / 287) | `556fe70b…` (19837 B, 287 newlines, 288 logical lines; `git status --porcelain` on the path is empty) | **exact** |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (7213 / 69) | `88bbe15b…` | **exact** |
| `SCORECARD.md` | `748790b416547fbbc66dcdc33907c7a2aa3fcb01badb1dd99965398a82bf132d` (93172 / 771) | `748790b4…` | **exact** |
| `.ufo/waves/round-22/before-runnable.json` | — (wave artifact) | `159fd685f3959e29259839ffe631a3401560afa759e25d4390c7005b185a0f44` | recorded |

## Finding 1 — the entry DID change between frozen-before bytes and integrated bytes; the delta is exactly one appended block (LOW, expected)

Byte chain, all verified by hashing, not inferred:

| Checkpoint | sha256 | bytes |
|---|---|---|
| Round-14 blob (what the stale pin named) = `git show 2486643:<path>` | `811572dcf630efc89e9222ed6c9e545a9b755f05be2908a6e0487a0fa8862be2` | 17609, 247 newlines |
| `head -c 17609` of the integrated file | `811572dcf630efc89e9222ed6c9e545a9b755f05be2908a6e0487a0fa8862be2` | identical |
| Round-16/base blob (`f4a8dd9`, identical blob at `c2cab35`) | `df6a5e5d05f4fa06cdcf2114c3a212e48c6b697d56cca1ced63342133e649c38` | 19329, 277 newlines |
| `head -c 19329` of the integrated file | `df6a5e5d05f4fa06cdcf2114c3a212e48c6b697d56cca1ced63342133e649c38` | identical |
| Integrated bytes (`8ada17a` blob `fcf5358e3603e79e4469323611fa7addcae7abf1`, and worktree) | `556fe70b681af58b35ac55a562f77ca089994a4d67260578e9db93d6d4f2869c` | 19837, 287 newlines |

The only edit vs the round-16/base blob is an appended `### Round-22 locator note` block: `git diff f4a8dd9 8ada17a -- <path>` shows 11 insertions / 1 deletion, and the sole deletion is the final unterminated line re-emitted with content preserved plus the new block (the `\ No newline at end of file` marker appears on both sides; the no-trailing-newline convention Entry10 prescribed is kept — `wc -l` 287 = logical 288 − 1). **Unchanged-prefix proof holds at both checkpoints: no pre-existing byte was rewritten, no erratum text was edited, nothing laundered.**

## Finding 2 — the pin migration is journaled with exact historic evidence, and my row is not among the "nine dropped" (LOW, correct)

- `corpus/stamps.tsv` row (now line 21) went `811572dc…/247/17609 → 556fe70b…/287/19837`, and it was re-stamped in intermediate commit `0b07548` (which carried the entry append and the reviewed full-set `stamp`, 38 insertions / 32 deletions, membership 63 → 69) before landing in `8ada17a`.
- `.ufo/waves/round-22/pin-migrations-integration.json` (sha256 `f7543d8c53080ad7037b87edc6c18e6b5bea062e156f116affd9dc127e45cfde`) journals this row exactly: `old_stamp` = the stale round-14 tuple, `base_observed` = `df6a5e5d…/277/19329`, `new_stamp` = `556fe70b…/287/19837`, `removed_members: []`, `old_members: 63`, `new_members: 69`. All three transition states are preserved, so the round-16 append (`811572dc → df6a5e5d`, unrecorded at the time) and the round-22 append (`df6a5e5d → 556fe70b`) are both recoverable from the journal — exactly the two-transition journaling Entry10 required.
- Cross-check of journal honesty: of 38 non-null `stamp_changes`, exactly 6 rows have `old_stamp != base_observed` — LOG.md, config-layering, **handler-on-disk-state**, handler-trust-boundary, janitor-env-contract, lessons/round-18 — precisely the six stale rows in `before.json` / `before-runnable.json` (`REVISION_AUDIT: DRIFT (stale=6 missing=0 dropped=0 added=0 invalid=0)`). No fourth row was silently re-pinned without a stale reason; no stale row was skipped.
- Membership: path-set diff of `c2cab35:corpus/stamps.tsv` vs current shows 6 additions (`feature-claims.json/.py`, `feature-bound-credential-review.md`, `lessons/round-21-verifier-spotcheck.md`, `lessons/round-22.md`, `revision-audit.py`) and **0 removals**. The "nine previously dropped stamps" are the nine replaced *values* of `aea7a43→e1544c1` (ReviewStamps F1; `round21-migrations.json`); this entry's row is not among them — it stayed stale through round 21 and is now re-pinned with provenance. No silent deletion anywhere in this row's lineage (`git log --follow` shows only `8ada17a`, `f4a8dd9`, `2486643`, `03477c0`, `51c9d30`).
- The disposition string in the migration record ("historical source facts remain historical… named per-entry audit") claims re-verification of nothing; restamping is presented as pointer repair only.

## Finding 3 — the appended locator note fixes the one live false reading without carrying mutable numbers forward (LOW, correct)

The known false reading in this entry's appended text was the erratum's scorecard line pointers. Verified against the integrated `SCORECARD.md` (sha256 `748790b4…`, clean):

- `SCORECARD.md:458` = `## Round-19 correction (appended 2026-10-14) — the describe-don't-pin claim was too strong`; `:512` = `## Outcome — round-16 re-dispatch (2026-10-15)` — both heading names the locator note points to exist in the current tree.
- At `f4a8dd9` the same sections sit at 454 and 496–506 respectively (checked via `git show f4a8dd9:SCORECARD.md`), confirming the note's statement that the numeric spans "belong to its filed round-16 revision" is accurate, and that preferring named sections over line numbers is the right stable anchor (the numbers already moved once, `c41af82` +4).
- The note ends: "refreshing this document's revision pin does not discharge a deferred host measurement" — it explicitly blocks the classic laundering move (restamp read as currentness). It cites `build/Entry10.md`, which exists and contains the audit this note summarizes.
- Absence bounds are unchanged and re-confirmed by me (metadata-only `test -e`, no content read, no gate): `~/.local/bin/the-janitor`, `~/.config/the-janitor/client.py`, `~/.config/the-janitor/config.json` → all `ENOENT` on 2026-10-20. Pointer freshness (the pin now matches current bytes) is thereby correctly distinguished from unavailable source facts (nothing source-derived can be re-measured; the round-16 `Source-status: historical` qualification is byte-identical and still carries the bound).

## Admissibility verdict

**ADMIT — the integrated C2 decision for this entry is correct and non-laundering.** The stale round-14 pin was a genuine pointer defect (not a substantive-freshness defect: all source-derived claims were already historically qualified at the base); the fix was append-only (prefix-unchanged proven verified at both `17609` and `19329` checkpoints), the old→new tuple is journaled with the base-observed intermediate state, membership never shrank, the sole live false reading (mutable scorecard line spans) is corrected via stable named anchors, and the note explicitly disclaims that re-pinning ≠ re-verification. No false reading survives unmarked; no historic statement was rewritten to look current.

## Residual risk / verification gaps

1. **Global rerun not performed by this seat (by design).** `expected.revision_audit = {added: 6, dropped: 0, invalid: 0, missing: 0, stale: 0}` in the manifest predicts a clean rerun, and my independent row-level analysis is consistent with it, but the single global `revision-audit.py` rerun is the parent's duty. If the parent reruns, this row should report OK with the `556fe70b…/287/19837` tuple.
2. **`wc -l` vs logical-line convention:** the migration journal records 287/19837 (newline-count convention); logical lines are 288 (file ends without trailing newline). Entry10 asked the journal to "state both numbers"; it states only the `wc` convention. Cosmetic; the detector uses the same convention, so no functional risk.
3. **Rest of the stamp set:** this seat verified only its own row plus membership invariants. The other five previously-stale rows' disposition strings were not independently adjudicated here (Entry01/Entry12 etc. lanes own those).
4. `8ada17a` squashes the intermediate `0b07548` (empty commit subject in the lane history) into the landing commit; attribution of the append+restamp to Entry10's recommendation rests on the journaled disposition text, not a per-seat commit message. Evidence trail is still complete via `pin-migrations-integration.json`.

## Method / limits

Read-only git plumbing (`git show/rev-parse/diff/log --follow`), `sha256sum`/`wc` on frozen inputs and worktree, one metadata-only absence probe (`test -e`, no content read). Manifest, stamps, migrations, before-runnable, build/Entry10.md, ReviewStamps.md, lessons/round-22.md and plans/round-22.md read; no `revision-audit.py` execution, no `claim-ledger.sh` invocation, no live gates, no jj state, no installs (nothing to record).

Exact read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (frozen-before reference: `c2cab35bc92e57e39e5489bac3386db078345b3f`).
