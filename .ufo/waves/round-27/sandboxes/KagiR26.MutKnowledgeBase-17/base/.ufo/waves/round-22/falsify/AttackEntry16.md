# AttackEntry16 — falsification of integrated C2 for `corpus/knowledge/op-cli-surface.md`

Lane: leaf member. Axes: **freshness (C2)** primary, **calibration (C1)** secondary.
Frozen input: integration-manifest.json entry `corpus/knowledge/op-cli-surface.md`
= sha256 `9525c55ab67beda18b2fe56b8c9d0b05f4810a102a8802781c61f3601098ca87`,
129 lines, 7365 bytes. Base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Measured integration landing observed directly: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
("round-22: feature-bound review capability and audited revision repairs").
Worktree HEAD matches the landing hash; no lane tip was inferred from detached HEAD.
No live host gates, no launcher/package/loopback/CDP probes, no installs, no production edits.

## Verdict

**ADMIS — C2 holds for this entry.** Unchanged-prefix proof passes; the stamp migration is
a single-row, evidence-recorded move with zero true drops; the appended erratum marks every
false current-voice reading I could identify; no laundering found. One non-blocking
provenance gap (P1) and one residual risk (R1) below.

## 1. Bytes: proven unchanged prefix, additive-only edit

| item | value |
|---|---|
| base blob `c2cab35:corpus/knowledge/op-cli-surface.md` | sha256 `2ac8f081724c9bd8368211276472da3bdb6ed0d6ccaf4492cea92e94e35da52b`, 117 lines / 6667 bytes |
| landing blob `8ada17a:…` | sha256 `9525c55ab67beda18b2fe56b8c9d0b05f4810a102a8802781c61f3601098ca87`, 129 lines / 7365 bytes |
| manifest-pinned bytes | `9525c55a…` 129/7365 — matches landing blob exactly |
| worktree file now | `9525c55a…` — identical to landing blob (`cmp` exit 0) |
| full diff base→landing | exactly `117a118,129`, 12 added lines, 0 changed, 0 removed |

`cmp` of base vs landing bytes reports EOF after byte 6667 with no earlier differing byte:
**lines 1–117 are byte-identical**; the edit is a pure append. History: only one commit
(`8ada17a`) touches the entry since base. The file's only committed erroratum-bearing
mutation is this append; nothing was rewritten or erased.

## 2. Stamp record: one-row migration matches evidence, zero drops

Old stamp (base, also `frozen/before/corpus/stamps.tsv:24`):
`corpus/knowledge/op-cli-surface.md  2ac8f081724c9bd8…  117  6667`.
New stamp (landing, worktree `corpus/stamps.tsv:27`):
`corpus/knowledge/op-cli-surface.md  9525c55ab67beda1…  129  7365`.

- `pin-migrations-integration.json` (worktree bytes `f7543d8c53080ad7037b87edc6c18e6b5bea062e156f116affd9dc127e45cfde`)
  records exactly this old→new pair with `base_observed` = old sha/117/6667 and disposition
  "Reviewed current round-22 artifact; historical source facts remain historical." The
  migration is per-row itemized, not a wholesale restamp: the whole landing stamps diff moves
  32 old lines→32 new lines for *changed* files and leaves all unchanged rows untouched.
- Set arithmetic over the landing stamps diff (paths only, `LC_ALL=C sort -u`):
  removed set 32, added set 38, **true drops (removed−added) = ∅**, new members = 6
  (`corpus/feature-claims.json`, `corpus/feature-claims.py`,
  `corpus/knowledge/feature-bound-credential-review.md`,
  `corpus/lessons/round-21-verifier-spotcheck.md`, `corpus/lessons/round-22.md`,
  `corpus/revision-audit.py`). No stamp member was silently deleted; the nine-deletion
  story does not recur in the integrated tree at this granularity.
- `op-cli-surface.md` row present with rows=1 in all 12 reachable commits touching
  `corpus/stamps.tsv` (587fda0→8ada17a): never dropped in committed history.
- Worktree `corpus/stamps.tsv` = `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29`,
  69 lines — byte-identical to the landing tree's stamps blob and to the manifest pin
  (manifest line 347–351). No drift landed after integration.
- The new stamp's 129/7365 matches the actual appended file — the pin tracks the reviewed
  append, not a speculative future state. `wc -l` = 69 rows; no duplicate paths (uniq -d empty).

## 3. Pointer freshness vs unavailable source facts — correctly separated

The landed erratum (lines 118–129) is a **content** statement ("Source-status: historical — …
dated measurements. They are not behavior remeasured on a newer CLI, nor proof of no
network/vault contact… The handler is unavailable under the round-18 substrate-deferral
record; relevant deferred rows are not passes. Account/signin/whoami and
reference-resolution recipes were not exercised here."), which is exactly the C2
distinction: it downgrades current-voice readings to dated observations without pretending
restamping re-measured anything, and it does not claim the absent substrate makes deferred
rows pass. Independently corroborated read-only today: `~/.local/bin/the-janitor` absent,
`~/.config/the-janitor/` absent (hence its `opencode.json` overlay absent), global
`~/.config/opencode/opencode.json` present; `op --version` → `2.41.0` vs the entry's dated
2.35.0. No unavailable-source fact is laundered into a current fact anywhere in the append.

## 4. Erratum completeness against the base text (calibration check)

Base lines audited (via `git show c2cab35:…`, lines 1–117). Current-voice statements and
whether the append marks them:

| base claim (line) | marked by erratum? |
|---|---|
| `op` 2.35.0 current (3, 15) | yes — "original CLI version … dated measurements … not behavior remeasured on a newer CLI" |
| "no vault contact, no prompt" for plain-env `op run` (20) | yes — "nor proof of no network/vault contact from timing or absence of a prompt" |
| account/signin/whoami auth matrix (16–18, 55–68) | yes — "Account/signin/whoami … recipes were not exercised here" |
| `cmd_refs` redaction / reference-resolution (34–53) | yes — "reference-resolution recipes were not exercised here" |
| handler-dependent rows (`cmd_serve` L194–210, readiness, drift, stop) (17–18, 23–100) | yes — "The handler is unavailable under the round-18 substrate-deferral record; relevant deferred rows are not passes" |
| `Reverify: R11-02, R12-01` (9) | yes — via "deferred rows are not passes"; the pointer-only coverage bound is honored |

No unmarked current-voice claim remains. The erratum names its audit
(`kagi-shokunin/.ufo/waves/round-22/build/Entry16.md`) whose sha256 is
`ab141f118d6a72f2de4a33aa69e3f23ba9f03d2d6365552d2581bdb0ab1a4c1a` — byte-identical between
the committed landing tree (`git show 8ada17a:…`) and the worktree file, so the cited audit
is the same document I reviewed, not a later-in-flight variant. No legacy `source:` /
`recheck:` / `verified-at:` header was added to the entry (grep: none), consistent with the
round's no-legacy-header rule. C1 separation also holds structurally: the entry has no
`source:` registry row (absent from `corpus/SOURCES.md`) and zero mentions in
`corpus/feature-claims.json` — the feature-bound adjudication does not reach this entry,
and this entry's audit does not adjudicate vendor facts.

## 5. Findings

**F1 (MEDIUM, provenance observation, non-blocking):** `build/Entry16.md` claims HEAD ==
`c2cab35bc92e57e39e5489bac3386db078345b3f` at audit time and reports the stamp row at
`corpus/stamps.tsv:24` with ledger sha `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b`
(63 rows). That is the **before** state, not the integrated landing; the audit predates
landing. The contract permits build artifacts to document an earlier in-flight snapshot as
advisory, and `before.json` (revision `c2cab35…`, `stale_count` 6) plus
`frozen/before/corpus/stamps.tsv:24` (`2ac8f081…` 117/6667) corroborate exactly that
before-state, so the artifact's header is accurate for its own read revision. It must not be
read as a statement about the integrated tree: its D1 "stamp matches" held only for the
117-line before-state, and the landing's reviewed append is what changed both entry and row.
Parent should record Entry16's header as describing the pre-landing tree.

**F2 (LOW, wording):** the landed erratum says "Recheck only after authorized source
restoration and a separately scoped account-free fixture run" — correct — but its "Audit:"
pointer is a relative path under `kagi-shokunin/`, while the build wave wrote the file at
`kagi-shokunin/.ufo/waves/round-22/build/Entry16.md`. Verified present at that resolved
location, so the pointer resolves; noting only that the entry text embeds a
repo-relative-looking path without an explicit anchor (cosmetic).

**P1 (provenance, non-blocking):** `build/Entry16.md` is not listed in
`integration-manifest.json` "inputs" (manifest pins code/docs/data; build artifacts are
advisory), so the manifest cannot guarantee the audit text's integrity by hash. Mitigated
here because the worktree audit file is byte-identical to the copy committed in the landing
tree (`ab141f11…`), so the cited audit provably existed at landing.

## 6. Admissibility verdict

For C2 freshness accounting, `corpus/knowledge/op-cli-surface.md` as integrated at
`8ada17a` is **admissible**: unchanged 117-line prefix (proven by byte compare), additive
12-line erratum, one-row stamp migration `2ac8f081…117/6667 → 9525c55a…129/7365` matching
`pin-migrations-integration.json` byte-for-byte, zero true stamp drops, no unavailable-source
fact promoted to current, no legacy-header count claim, no depth move. The erratum correctly
separates pointer freshness (stamp matches appended bytes) from unavailable source facts
(handler/substrate absent; dated rows stay historical; deferred rows are not passes).

Residual risk (R1): the erratum's honesty is a *content* judgment on text, not a
re-execution of the entry's probes; nothing here re-measured `op` behavior or the endpoint
drift claims, and none is claimed. The `Reverify:` pointer remains a pointer; its
irrelevance for auth/endpoint rows is now stated in the append rather than fixable by
restamping.
