# AttackEntry13 — falsify `corpus/knowledge/janitor-env-contract.md` (C2 freshness / C1 calibration)

Fresh attack of the integrated round-22 tree, 2026-10-20. Frozen inputs per
`.ufo/waves/round-22/integration-manifest.json` (base `c2cab35bc92e57e39e5489bac3386db078345b3f`,
landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`). Leaf seat: no subagents, no gates run, no
installs, no writes except this report. Git use was read-only plumbing (`show`, `log`, `ls-files`).
`build/Entry13.md` was read and is treated as advisory; every number below was re-derived.

## 1. Measured tree state (recorded because lane edits are frozen this wave)

| artifact | observed sha256 | lines | bytes |
|---|---|---|---|
| `corpus/knowledge/janitor-env-contract.md` (worktree) | `dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4` | 113 | 6372 |
| same, base blob `c2cab35:` | `dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4` | — | — |
| same, landing blob `8ada17a:` | `dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4` | — | — |
| `corpus/stamps.tsv` (worktree) | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | — |
| same, landing blob | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | — |
| same, base blob | (63 rows; digest in `frozen/before/expected.json` = `0ce7fa4f…`) | 63 | — |

Manifest input for the entry (`integration-manifest.json`) = `dac43ef9…/113/6372` — worktree, base
blob, landing blob, and manifest all identical. **The entry file has zero round-22 edits**
(`git log c2cab35..8ada17a -- <path>` is empty). Advisory `build/Entry13.md` matches these bytes.

## 2. Frozen-before vs current bytes — unchanged prefix proven, edits identified

- Frozen-before tree has no file copy of this entry; the before state is carried by
  `frozen/before/corpus/stamps.tsv` row: `corpus/knowledge/janitor-env-contract.md⇥88dca63ac7e6137f6a737439f18e99b9f602f57a065c63c478c364b46d873c1f⇥90⇥5111`.
- The identical row is in the base `c2cab35` stamps blob and the `aea7a43` stamps blob — the row
  existed continuously; **this path was never a dropped stamp member**.
- Prefix proof, re-derived: `git show c2cab35:<entry> | head -c 5111 | sha256sum` = `88dca63a…`;
  `head -90` = `88dca63a…`. The stamped bytes are a verbatim prefix of the current file.
- Pin provenance: pin created at `2486643` (2026-09-28); blob at `2486643:` = `88dca63a…/90/5111`
  exactly. Sole post-pin edit `f4a8dd9` (2026-10-15, round-16 re-dispatch): numstat **23 insertions,
  0 deletions**; blob at `f4a8dd9:` = `dac43ef9…` = current; that commit did not touch
  `corpus/stamps.tsv` (hence the stale row at base). Delta `+23` lines / `+1261` bytes = exactly the
  appended `## Historical-source erratum` block (lines 92–113). Nothing was rewritten in place.

## 3. Stamp record reconciliation (freshness)

- Before (base): row stale — `88dca63a…/90/5111` vs actual `dac43ef9…/113/6372`. This entry is one
  of the **six** stale rows in `before.json` / `before-runnable.json` (`REVISION_AUDIT: DRIFT
  (stale=6 missing=0 dropped=0 added=0 invalid=0)`, exit 1) — the round-22 lesson's "four
  historical-source errata entries, round-18 lesson and LOG" includes it.
- After (landing/worktree): row = `corpus/knowledge/janitor-env-contract.md⇥dac43ef9…⇥113⇥6372`,
  byte-equal to the recomputed file facts (§1).
- Migration journaled, not silent: committed (git-tracked) `.ufo/waves/round-22/pin-migrations-integration.json`
  carries this path with `old_stamp` verbatim (E0 row), `base_observed {dac43ef9…,113,6372}`,
  `new_stamp` verbatim, disposition "Reviewed current round-22 artifact; historical source facts
  remain historical. See round-22 lesson and named per-entry audit." QM14 old/new evidence shape
  satisfied for this row; the disposition claims pointer integrity only.
- Membership / no laundering: `old_members 63 → new_members 69`, `removed_members: []`;
  base→landing stamps diff = 32 removed / 38 added lines = in-place re-pins plus exactly 6 new
  members (`feature-claims.json`, `feature-claims.py`, `feature-bound-credential-review.md`,
  `round-21-verifier-spotcheck.md`, `round-22.md`, `revision-audit.py`); zero path deletions.
  `integration-pin-check.json` records `STAMPED: n=69` and `REVISION_AUDIT: CLEAN (stale=0
  missing=0 dropped=0 added=6 invalid=0)` exit 0 — equal to the manifest's frozen
  `revision_audit` expectation. Global rerun of the revision-audit is parent duty; not executed here.
- "Nine previously dropped stamps" vs this entry: the row is byte-identical at `aea7a43` and base
  (`88dca63a…`, stale in both) and was replaced, never removed, at landing — the nine-line
  replacement span in `round21-migrations.json` does not include this path, correctly so.

## 4. Pointer freshness vs unavailable source facts

- Restamp proves file-pointer integrity only. The entry's source remains unavailable: metadata-only
  existence checks today (no content read, no credential/vault action) show **all four cited paths
  ABSENT**: `~/.local/bin/the-janitor`, `~/.config/the-janitor/client.py`,
  `~/.config/the-janitor/config.json`, `~/.config/the-janitor/op.env`. The erratum's 2026-10-15
  absence finding still holds; no current hash, line count, auth behavior, endpoint value or handler
  behavior is asserted anywhere in the round-22 record for this entry.
- `Reverify: R11-02, R11-04` (entry line 8) still points at ledger rows tagged `[substrate]`
  (`corpus/claim-ledger.tsv` rows 16, 18, textually unchanged, expectations intact) — they defer,
  not pass, while the substrate is absent. No round-22 record promotes them.

## 5. Erratum coverage — every false reading marked, none laundered

Enumerated qualified spans `3-6, 10-23, 25-51, 53-63, 65-77, 79-90` anchor exactly at observed
headings (10 Knob table, 25 Auth selector semantics, 53 endpoint, 65 Leak-surface, 79 Falsification)
and cover every substantive source-derived line of the 90-line pre-erratum file. Uncovered lines are
only the title, blank lines, and the `Reverify:` navigation pointer (§4) — no source-derived factual
claim escapes qualification. The append is pure (23/0, prefix-verified); original observations,
abbreviated source hash (`2408b0c9…57edd`) and "333 lines" are preserved as history, never expanded
or re-asserted. No laundering.

## Findings by severity

| severity | finding | evidence |
|---|---|---|
| blocking | none | — |
| minor | The erratum's internal evidence pointers into `SCORECARD.md` have drifted and are unmarked: cited `454-466` now begins with four unrelated round-21 move-log rows (the round-19 correction block it means is `458-470`), and cited `command/result … 496-506` ends before the `Observed:` line, which sits at `508`. Inherited from pre-base SCORECARD appends; gate-clean (path resolves), does not falsify the erratum's claims. Entry bytes are frozen this wave, so record for the parent: an append-only pointer note (`454-466 → 458-470`, `496-506 → 504-508`) would have to precede any future stamp computation. | `SCORECARD.md:450-512` observed 2026-10-20; entry lines 99-101 |
| informational | `Reverify: R11-02, R11-04` sits outside the erratum's enumerated spans; both target rows are `[substrate]` deferrals, so the pointer is honest but can only defer. | `corpus/claim-ledger.tsv:16,18` |
| informational | No per-entry record of this re-pin in `LOG.md` (hits only round-4 landing and round-16 errata records); QM14 evidence lives in the committed journal + advisory `build/Entry13.md` §7 — acceptable, the journal is git-tracked. | grep of `LOG.md` for `janitor-env-contract\|88dca63a\|dac43ef9` |

## Admissibility verdict

**ADMIT.** For this exact entry the integrated C2 decision is correct and calibrated: bytes
base→landing→worktree identical (`dac43ef9…/113/6372` = manifest input); the stale stamp row was
re-pinned to the recomputed file facts with verbatim old/new migration evidence in a committed
journal; membership preserved (63→69, zero removals, six journaled additions); the historic erratum
remains historic with complete span coverage and no in-place rewrite; pointer freshness is never
conflated with the still-absent source facts. `build/Entry13.md`'s measurements reproduce; its
optional §8 pointer-note recommendation was not taken — recorded above as the only minor residual.

## Method / limits

Reads: entry, `stamps.tsv` (worktree/base/`aea7a43`/landing blobs), `claim-ledger.tsv`,
`integration-manifest.json`, `frozen/before/{expected.json,stamps.tsv}`, `before.json`,
`before-runnable.json`, `pin-migrations-integration.json`, `integration-pin-check.json`,
`historical-correction-pins.json` (covers `c41af82→e1544c194`, correctly excludes this path),
`plans/round-22.md`, `corpus/lessons/round-22.md`, `SCORECARD.md:450-512,700-771`, `LOG.md` grep,
`build/Entry13.md`. Did not independently recount the nine stale rows at `aea7a43` (corroborated via
committed `round21-migrations.json` + build report; my row's membership there verified directly).
Did not rerun the revision-audit or any host gate (parent duty / prohibited). No installs; nothing to
record. Read revision: frozen round-22 integrated tree as of 2026-10-20.

Checks the parent should run after this wave: global `python3 corpus/revision-audit.py --history
c2cab35…` (expect `CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`), and the two-line pointer
note above if entry-local SCORECARD accuracy is wanted (append-only, before any restamp).

Report: .ufo/waves/round-22/falsify/AttackEntry13.md
