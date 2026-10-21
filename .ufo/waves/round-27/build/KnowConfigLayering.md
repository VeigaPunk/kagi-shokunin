# KnowConfigLayering — C1 number inventory for `corpus/knowledge/config-layering.md`

Seat: KagiR26.KnowConfigLayering-17 (leaf; no subagents). Frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`. The entry is unchanged at BASE in
this checkout: `git diff --stat 0a47dd18 -- corpus/knowledge/config-layering.md`
is empty; the BASE blob is 136 lines / 8088 bytes / sha256
`9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0`, identical to
the pin at `corpus/stamps.tsv:32`. Rules applied: `corpus/QUALITY.md:118` (QM21)
and `corpus/QUALITY.md:133` (QM26), with the round-25 lesson rule R25-C6
(`corpus/lessons/round-25.md` §Plan corrections) and the round-27 exclusions
(`corpus/lessons/round-27.md` §C1).

## Result

**In-population current-tense numbers about this lane's own artifacts: 0.**
No selftest case count, row/stamp/claim/pin count, bound, lane-file line count,
or finding count about lane artifacts is stated in current voice. The entry is
a host-substrate observation whose own erratum marks it historical
(`corpus/knowledge/config-layering.md:111-136`), so nothing in it can be bound
as a live self-count and no row can be added to `corpus/self-counts.tsv` from
this entry under the current `rows:` / `ledger:` / `expect:` source model.

Every line of the entry carrying a digit (33 lines; census run over the BASE
blob) is accounted for below: 16 host/substrate observation lines, 3 vendor
lines, 7 date/round/ID/section-pointer lines, 4 erratum self-range lines, and
3 lane-file line locators. The locators are checked by hand; two are stale.

## Table A — lane-file line locators (only present-tense candidates)

These are the only numbers that name a lane-owned file's lines in the present
tense. They are *out of population by source*: `corpus/self-counts.tsv` can
bind a file's total row count (`rows:<file>`) or a row's live verdict
(`ledger:`/`expect:`), but it has no source that defines "section X starts at
line N". Status was therefore established by reading the files at BASE, not by
a gate. Each locator matches exactly one line with exactly one capture group
(validated against the BASE blob).

| id | line | exact text | locator (one group) | source | live value at BASE | status | population |
|---|---|---|---|---|---|---|---|
| KN-CONF-SCORECARD-DEBT | 125 | ``Evidence: `SCORECARD.md:454-466` names the debt and`` | ``^Evidence: `SCORECARD\.md:([0-9]+)-466` names the debt and$`` | none — unbindable | heading `## Round-19 correction` is at `SCORECARD.md:458`; the "Named debt, owner kagi, unblock" sentence is `SCORECARD.md:469-470`; `454-456` are round-21 move-log rows | **STALE** (+4 lines) | out: no lane-local pin; `stamps.tsv` pins this entry's bytes, not SCORECARD positions |
| KN-CONF-SCORECARD-CMD | 126 | `` `SCORECARD.md:496-506` records the local counting command and its boundary.`` | ``^`SCORECARD\.md:([0-9]+)-506` records the local counting command and its boundary\.$`` | none — unbindable | `496` is "Target: `unqualified=4 → 0`…"; the counting command block is `SCORECARD.md:504-506`; the observed output and boundary are `SCORECARD.md:508-510` | **STALE** (+4 lines) | out: same reason |
| KN-CONF-HTB-POINTER | 131 | `` `corpus/knowledge/handler-trust-boundary.md:152-160` records plugin load`` | ``^`corpus/knowledge/handler-trust-boundary\.md:([0-9]+)-160` records plugin load$`` | none — unbindable | `152` = "`fnm-nudge.js` is **inert because it does not load**"; `160` = "non-fatal — the server continues without the plugin."; exactly the stated correction | **OK** | out: no lane-local pin |
| KN-CONF-ORIGINAL-RANGES | 116-118 | `This qualifies original lines 3-6 … 8-22 … 24-46 … 48-54 … 56-66 … 68-81 … and 83-101` | ``^This qualifies original lines ([0-9]+)-6 \(source basis\)`` | none | every range lands exactly on its labeled section at BASE (3-6 source basis, 8-22 merge+layers, 24-46 resolved dump, 48-54 steps, 56-66 decoy, 68-81 ceiling, 83-101 reproduce) | **OK** | out: explicit history clause, `:119-120` ("original text … preserved, not re-asserted as current properties"); QM26 Erratum class |
| KN-CONF-ORIGINAL-39 | 130 | `Original lines 39-44 also have an existing historical correction:` | ``^Original lines ([0-9]+)-44 also have an existing historical correction:$`` | none | `39-44` is exactly the `plugin` bullet | **OK** | out: history clause |

A line-range statement carries two numbers, while a self-counts locator is
allowed exactly one capture group. Even if the L1 decides to bind these, one
row per endpoint is required; a single `rows:SCORECARD.md` row would pin the
file total (1098 lines) and cannot detect this drift.

Same six-field shape as `corpus/self-counts.tsv` (none of these is addable
today; `source` is empty because no live binding exists):

```tsv
KN-CONF-SCORECARD-DEBT	corpus/knowledge/config-layering.md	^Evidence: `SCORECARD\.md:([0-9]+)-466` names the debt and	-	-	L125; current-tense Section start; observed 458 vs stated 454 at BASE — STALE (+4 since c41af82); out of population (no rows/ledger/expect source)
KN-CONF-SCORECARD-CMD	corpus/knowledge/config-layering.md	^`SCORECARD\.md:([0-9]+)-506` records the local counting command and its boundary\.$	-	-	L126; observed 504-506 command / 508-510 boundary vs stated 496-506 — STALE (+4); out of population
KN-CONF-HTB-POINTER	corpus/knowledge/config-layering.md	^`corpus/knowledge/handler-trust-boundary\.md:([0-9]+)-160` records plugin load$	-	-	L131; observed 152-160 exact — OK; out of population
KN-CONF-ORIGINAL-RANGES	corpus/knowledge/config-layering.md	^This qualifies original lines ([0-9]+)-6 \(source basis\)	-	-	L116-118; all seven ranges exact at BASE — OK; out of population (history clause :119-120)
KN-CONF-ORIGINAL-39	corpus/knowledge/config-layering.md	^Original lines ([0-9]+)-44 also have an existing historical correction:$	-	-	L130; 39-44 exact — OK; out of population (history clause)
```

## Table B — excluded numbers and why

Census method: every line matching `\d` in
`git show 0a47dd18:corpus/knowledge/config-layering.md` (33 lines). Grouped
here by exclusion class, with the exact line numbers at BASE.

| # | class | lines | numbers | why excluded |
|---|---|---|---|---|
| 1 | host/substrate measurement of the absent janitor/opencode substrate | 3, 18, 22, 26, 27, 32, 35, 50, 51, 52, 53, 58, 63, 73, 74, 78 | `186–226` (the-janitor `cmd_serve` range); `455` lines; `8` provider defs; `406` B; `9` providers and `×3`/`×3`; `23` agents; `56`-entry ruleset; `steps: 4` (three times); `steps: 8` (twice); `0600`; `af8873ca…`; `20` cloud-key vars; `214–219` (the-janitor range); port `40961` | QM26 excludes host/substrate observations; the cited paths are declared absent at `:122-124`; the round-27 lesson §C1 names agent counts as excluded; no lane-local source defines them. The ledger row the entry cites for layer revisions, `R11-04` (`corpus/claim-ledger.tsv:18`), is a host `[substrate]` drift-pins row and pins no count stated here. |
| 2 | vendor fact | 4, 100, 106 | opencode `1.18.31` (twice); `debug agent` "exits 0" | Vendor behavior/version, not a lane artifact. |
| 3 | date, round label, row ID, section pointer | 5, 12, 20, 77, 111, 114, 122 | `2026-09-28` (twice), `R11-04`, `§4`, `Round-7`, `round-16`, `2026-10-15` (twice) | Not counts. `2026-09-28` is inside the dated source-basis and historical-status clauses; `2026-10-15` is the erratum/host-metadata date; the rest are labels. `§4` is additionally dangling (the entry has no numbered §4) — an adjacent defect, not a C1 number. |
| 4 | erratum self-ranges | 116, 117, 118, 130 | `3-6`, `8-22`, `24-46`, `48-54`, `56-66`, `68-81`, `83-101`, `39-44` | Explicit history clause (`:119-120`) and QM26's Erratum-history exclusion. Verified accurate anyway (Table A). |
| 5 | lane-file locators | 125, 126, 131 | `SCORECARD.md:454-466`, `SCORECARD.md:496-506`, `handler-trust-boundary.md:152-160` | Present-tense, but no `rows:`/`ledger:`/`expect:` source can define them; see Table A. Two are stale. |

No other numeric statement exists. There is no selftest count, ledger/stamp/
claim/pin count, witness-count, bound, or finding count in this entry.

## Finding — the erratum's own SCORECARD pointers are stale by four lines

This is the concrete counterexample to the assumption that the Erratum-history
exclusion class is safe.

At the erratum's authoring revision `f4a8dd92674e95231c50f361e8c69eb00c7e713b`
(round 16), both pointers were exact:

- `SCORECARD.md:454` = `## Round-19 correction (appended 2026-10-14) — …`;
  `:465-466` = "Named debt, owner kagi, unblock: mark those lines historical in
  an append-only erratum…" — so `454-466` bracketed the heading through the
  named debt.
- `SCORECARD.md:496` = "Before measurement: commit `15ea78c7…`"; `:500-502` the
  `node -e` counting command; `:504-506` the `Observed: SOURCE_FRESHNESS…`
  line plus its boundary — so `496-506` bracketed command and boundary.

Commit `c41af82` (round 21, "admit dotenv byte contract …") inserted four
move-log rows at `SCORECARD.md:450` (hunk `@@ -450,6 +450,10 @@`), shifting
every later line by +4. At BASE:

- `SCORECARD.md:454-456` are round-21 move-log rows; the correction
  heading is at `:458`; the named-debt sentence is at `:469-470` — outside the
  cited range. The entry's sentence therefore points at the wrong span.
- `SCORECARD.md:496` is the "Target: `unqualified=4 → 0`…" line; the command is
  at `:504-506`; the observed output and its boundary are at `:508-510` — the
  cited range no longer records the boundary it claims.

The neighbour pointer is fine: `handler-trust-boundary.md:152-160` still
resolves exactly, so this is not a wholesale shift of every pointer in the
erratum — only the two SCORECARD refs moved. The defect has been present since
round 21, i.e. through six reviewed rounds (21-26), and no gate notices it:
`corpus/self-counts.tsv` has no row for this entry, QM26 excludes Erratum
history, `R13-01` (`corpus/claim-ledger.tsv:29`) counts `^## Round ` headings
but not their positions, and `corpus/stamps.tsv` pins the entry's bytes rather
than the file it cites. This is the same class as the round-27 lesson's
`credential-isolation.md:120-122` pointer, which the lesson records as stale
because the target is shorter than the range.

Advice for L1 (not applied — production is read-only for this seat):

1. Prefer a stable citation: `SCORECARD.md` §"Round-19 correction" and
   §"Current baseline — round-16 re-dispatch" instead of bare line ranges.
2. If numbers are kept, make them checkable via a new non-host ledger row, e.g.
   `grep -n '^## Round-19 correction' SCORECARD.md` → `458` and
   `grep -n '^Observed: `SOURCE_FRESHNESS' SCORECARD.md` → `508`, then bind the
   two endpoints with `ledger:<ID>` rows (one per endpoint; one group each).
3. If the ranges stay in the text, correct them with the old value retained
   (QM21): "454-466 as of `f4a8dd9` / 458-470 at round 27" and
   "496-506 as of `f4a8dd9` / 500-510 at round 27". Do not add
   `rows:SCORECARD.md`; it pins 1098 total lines and would miss this.

## Freshness / release-clock status

The entry has no `source:` / `verified-at:` / `recheck:` header; line 1 is the
title and line 3 is prose "Source basis". It declares
`Source-status: historical` (`:113-114`) and blocks current-tense reuse until
an authorized resolver review under the exact `_serve` environment
(`:134-136`). It therefore carries no `on-release` row and no numeric anchor;
C2's REGRESSED rule has nothing to fire on for this entry. None of the host
numbers above is claimed current, so none is a pass. The SCORECARD drift is a
calibration defect, not a freshness one.

## What I did NOT check

- No gate or check was executed: not `corpus/self-counts.py`, not
  `c1-measure.py`, not `corpus/claim-ledger.sh`, not `corpus/drift-pins.sh`,
  not `corpus/release-clock.py`, not stamps verification, no selftests, no
  build/lint/formatter. Statuses above are manual reads of the BASE blobs.
- No host/substrate access: no `~/.config`, no `~/.local/bin/the-janitor`, no
  opencode, vault, handler, CDP, `op`, or token read; the entry's 2026-10-15
  absence record was not re-measured.
- Did not verify the entry's factual claims about opencode layering or the
  resolved dump; the erratum already withholds current status for them.
- Did not audit other entries' pointers into this entry (e.g.
  `corpus/knowledge/control-plane-hardening.md:29` cites `config-layering.md`
  L14–44) or the `corpus/README.md:32` index row; outside this item.
- Did not inspect SCORECARD revisions other than `f4a8dd9`, `c41af82` and BASE
  for these two ranges, and did not re-derive the round-27 lesson's
  18-binding/7-entry count.

Tooling: nothing installed or upgraded.

## Bottom line

- In-population current-tense lane-artifact numbers in
  `corpus/knowledge/config-layering.md` at BASE: **0**; no self-counts row is
  possible for this entry under the current source model.
- The only present-tense lane-file locators are two `SCORECARD.md` ranges and
  one `handler-trust-boundary.md` range; both SCORECARD ranges are **STALE by
  +4 lines** (correct content now at 458-470 and 500-510), the third is OK.
- Root cause observed: `c41af82` (round 21) inserted four move-log rows above
  the cited region; the erratum's pointers were exact at `f4a8dd9`.
- The Erratum-history exclusion (QM26) hides exactly this drift; a bound
  section-heading row or a section-name citation removes the exposure.
