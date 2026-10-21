# KnowJanitorLifecycle — C1 inventory: `corpus/knowledge/janitor-lifecycle.md`

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`.

## Target identity (observed)

- `git rev-parse BASE:corpus/knowledge/janitor-lifecycle.md` =
  `850a544552207f08d3c35cfabf4a66392ebf28c0`; worktree sha256 =
  `13c53ed256e6604e5df739c505d7cbd0d7dee865caa3c653502d47bd49dd3fb8`
  (= the pin at `corpus/stamps.tsv:41`), 81 lines / 5598 bytes (`wc -l -c`
  agrees); `git status --porcelain -- <target>` is empty. The entry is
  unchanged since BASE.
- Revision provenance of the other files cited here: L1's round-27 integration
  is uncommitted. `corpus/self-counts.tsv` is 75 lines in the worktree vs 52 at
  BASE; `corpus/QUALITY.md` gains QM25/QM26 (QM26 is absent at BASE);
  `corpus/claim-ledger.tsv` moved its R12-03/R13-01/R21-02/R22-03 pins;
  `plans/round-27.md` and `corpus/lessons/round-27.md` are untracked.
  Citations to those name the working revision. `PROVINCE.md:10-17,40-42`,
  `corpus/state-shape.tsv:39-40`, `corpus/surface-census.tsv:36-37`,
  `corpus/claim-ledger.tsv:15,18` and `corpus/stamps.tsv:41` are unchanged at
  BASE (the PROVINCE and ledger diffs start below those lines).

## Verdict

**0 in-population numbers. 0 binding rows for this doc.**

The complete digit census is 17 lines: 3, 4, 5, 6, 14, 20, 21, 22, 23, 24, 31,
36, 48, 53, 64, 69, 80. Every one is classified in the exclusion table below;
none states a lane artifact's present size (case count, row/stamp/claim/pin
count, bound, lane-file line count, finding count).

This is **not** "measured clean". `c1-measure.py` derives its knowledge
population from table rows (`c1-measure.py:45-46`,
`knowledge = [r[0] for r in rows if r[1].startswith("corpus/knowledge/")]`);
no row names this doc, so the binder never reads it. No row means unmeasured,
not OK.

## Why the entry is outside the population (rule facts)

- Population rule: current-tense numbers in `corpus/knowledge/*.md` about this
  lane's own artifacts **with a lane-local source** (`plans/round-27.md:9-18`;
  `corpus/self-counts.tsv:53-57`, round-27 working table).
- Named exclusions: "sections dated as measurements (`Reproduction
  (2026-09-28)`, `Source basis: measured …`), Evidence/Erratum/Round-N
  findings history, host/substrate observations and positional case indexes"
  (`corpus/self-counts.tsv:55-56`); QM26 (`corpus/QUALITY.md:133`, landed this
  round, absent at BASE); R25-C6 (`corpus/lessons/round-25.md:49-58`).
- The entry's entire source basis is a dated measurement: L3-7 —
  "`Source basis: … live probes 2026-09-28`" and "Line numbers date to this
  read — re-grep before citing."
- Its substrate is declared HISTORICAL/absent: `PROVINCE.md:10-17`
  (Round-18 erratum: "the janitor substrate was measured absent on this
  host"), `corpus/knowledge/substrate-deferral.md:3-8` ("The entire janitor
  substrate is gone from this host"). I did not re-probe the host; this is the
  committed declaration at BASE, not a live measurement by me.
- Its only claim links are substrate rows: `Reverify: R11-01, R11-04` (L14),
  and both are `[substrate]` (`corpus/claim-ledger.tsv:15,18`).

Boundary call for L1: if a reviewer applies QM21 strictly (a history clause
needs a newer value beside it), the 13 `L…` source offsets would read as
"current but unbindable" instead of "excluded by QM26". Either reading gives
zero rows, because no lane-local source defines an intra-file offset. I
recommend the QM26 dated-measurement exclusion: L3-7 is exactly a
`Source basis:` block, and the substrate no longer exists to re-grep.

## Binding table (format of `corpus/self-counts.tsv`)

```tsv
id	doc	locator	source	extract	note
```

No rows. A locator without a source would be a false binding: `rows:` compares
a file's data-line count, not a field value (`corpus/self-counts.tsv:1-14`), so
e.g. `rows:corpus/state-shape.tsv` would compare 22 rows (pinned by
`corpus/claim-ledger.tsv:24`, R11-10) against this entry's `0 bytes`.

Optional commented note for L1 (not applied; `#` lines are skipped by the
binder):

```tsv
# corpus/knowledge/janitor-lifecycle.md — reviewed round 27: 0 in-population
# numbers (substrate-facing; host offsets/modes/sizes/ports excluded by QM26)
```

## Complete exclusion census (all 17 digit-bearing lines)

| Line | Token(s) | Exact text (excerpt) | Class | Why out |
|---|---|---|---|---|
| 3 | `L121–135`, `L138–143` | "`cmd_request` L121–135, `cmd_start`" / "L138–143" | host source offset | Offsets into `~/.local/bin/the-janitor`, declared absent (`PROVINCE.md:10-17`); block dated at L5/L7; no lane-local source. |
| 4 | `L173–184`, `L237–249`, `L41–95` | "`cmd_stop` L173–184, `cmd_run` L237–249), `client.py` L41–95" | host source offset | Same; `client.py` is `~/.config/the-janitor/client.py`, absent (`substrate-deferral.md:3-8`). |
| 5 | `2026-09-28` | "live probes 2026-09-28" | measurement date | QM26 dated-measurement exclusion (`corpus/self-counts.tsv:55`). |
| 6 | `34113`, `8080` | "curl 34113/8080" | host ports | Host network surface, historical (`PROVINCE.md:40-42`); not a count. |
| 14 | `R11-01`, `R11-04` | "Reverify: R11-01, R11-04" | claim identifiers | IDs, not counts; both rows are `[substrate]` (`corpus/claim-ledger.tsv:15,18`). |
| 20 | `0600`, `0 bytes`, `L66`, `9` | "`client.lock` (0600) … 0 bytes … `prepare_state` (L66) … `flock 9`" | host mode / size / offset / fd | Host state facts. `corpus/state-shape.tsv:39` asserts mode 600 and "0-byte" in a prose note, but `rows:` would count its 22 lines, not read the field; `9` is the shell fd in the lock idiom. |
| 21 | `0600`, `L57–63`, `L41–46`, `L183`, `L92–97` | "`session-id` (0600) … `get_session_id` (L57–63) … (L41–46) … (L183) … (L92–97)" | host mode + offsets | Mode and offsets are host facts of the absent client/CLI; dated at L5/L7. |
| 22 | `L170` | "`status` L170" | host source offset | Same. |
| 23 | `L194` | "`_serve` (L194)" | host source offset | Same. |
| 24 | `0600`, `round-7` | "(0600) … (round-7 finding …)" | host mode + history ref | Mode is host; "round-7 finding" is measurement history (QM26 Round-N history). |
| 31 | `1Password` | "rotate in the vault item (1Password side)" | product name | Digit inside a proper noun; not a count. |
| 36 | `0600` | "edit `op.env` directly (0600 …)" | host mode | Mode of a host file; no lane-local numeric source. |
| 48 | `L179–181`, `exit 0` | "(L179–181) — both exit 0" | host offset + exit status | Behavior text of the absent CLI; not an artifact size. |
| 53 | `exit 0` | "spawned `op vault list`, exit 0 → `AUTH_OK`" | exit status | Protocol outcome, not a count. |
| 64 | `exit 1` | "# handler process liveness (exit 1 if absent)" | exit status | Probe semantics, not a count. |
| 69 | `round 7` | "round 7 showed the server itself is vault-capable" | round index | Historical measurement reference; not a present size. |
| 80 | `1Password` | "1Password-side rotation" | product name | Digit inside a proper noun; not a count. |

Word-quantifier exclusions (no numeral, not artifact sizes): L6 "on **both**
state dirs" (config + state dirs) and L48 "**both** exit 0, **both** `rm -f
session-id`" (the two stop paths). Host-scoped quantifiers, QM26 host
observation.

## Near-miss candidates examined and rejected

1. **`0 bytes` (L20).** Lane data does assert it: `corpus/state-shape.tsv:39`
   (`$STATE/client.lock  lock  600  0-byte flock file; prepare_state recreates
   it`) and `corpus/surface-census.tsv:36` (runtime file, mode 600). Rejected:
   both are committed declarations about an absent host, and neither exposes a
   value the binder can read — `rows:` counts data lines (R11-10 pins 22 rows,
   `claim-ledger.tsv:24`), and no ledger row pins the size. Binding through
   `expect:` would require a substrate-tagged row that measures the file; none
   exists. This would need a new ledger row (L1 call), and it would pin a host
   fact that defers on this host (`substrate-deferral.md` contract), not a
   lane-artifact size. Also outside C1's population by the host-observation
   exclusion.
2. **`0600` modes (L20, 21, 24, 36).** Same lane sources (`state-shape.tsv:39-40`,
   `surface-census.tsv:36-37`). Modes are not counts, and the only machine pin
   is row membership, not field content.
3. **`exit 0` / `exit 1` (L48, 53, 64).** Protocol/probe semantics; not sizes
   and not lane data.
4. **Intra-file `L…` offsets (L3, 4, 20-23, 48).** The lane does pin host file
   totals — `corpus/drift-baseline.tsv:1-2` pins `the-janitor` at 333 lines and
   `client.py` at 117 lines with sha256 — but the entry states neither total,
   and the baseline cannot define offsets inside those files. Sibling entries
   repeat the offsets as prose (`control-plane-hardening.md:4-5`,
   `janitor-command-surface.md:14,17`), which is a copy, not a measurement.

## Freshness checks (C2 surface, and sibling consistency)

- **No release clock applies.** `grep -n 'janitor-lifecycle'
  corpus/release-clocks.tsv` returns nothing (registry header at
  `corpus/release-clocks.tsv:1`; no `knowledge/` row appears in it). The entry
  has no `anchored_version`/`observed_version` pair and no numeric release
  observation, so QM25's REGRESSED rule has no surface here. Not a pass — an
  inapplicable clock.
- Excluded numbers do agree with the lane's committed host pins:
  `state-shape.tsv:39` (lock mode 600, "0-byte"), `:40` (session-id mode 600;
  cites `client.py chmod 0600 L61-63`, a sub-range inside L57-63);
  `surface-census.tsv:36-37` (both runtime files, mode 600; "stop removes it").
- `cmd_request` L121–135 and `cmd_stop` L173–184 agree with
  `control-plane-hardening.md:4-5` and `janitor-command-surface.md:14,17`;
  `cmd_run` L248 (`SKILL.md:32`) sits inside L237–249; the L92–97 session-id
  branch agrees with `handler-on-disk-state.md:146` ("`ensure_started` also
  `rm -f session-id` (L97)").
- Qualitative current-tense claims are not contradicted by newer entries: the
  "no rotation verb" and "no purge verb" findings are also asserted at
  `control-plane-hardening.md:101-102` and `handler-on-disk-state.md:162-167`.
  I did not test the claims (substrate absent); this is corpus agreement, not
  execution.
- Concrete counterexample against treating these offsets as bindable:
  `get_session_id` is L57–63 here but L49–65 in `handler-on-disk-state.md:4`;
  `ensure_started` is L92–118 in `control-plane-hardening.md:4` but L77–120 in
  `handler-trust-boundary.md:4`. Both sibling entries and this one date their
  reads to 2026-09-28, and no source exists on this host to settle function
  extent vs sub-block. Unresolved by me — not asserted as a defect.
- Freshness gap worth naming: this entry predates the Round-18 absence erratum
  and does not point at it. It stays in the QM26 dated-measurement class via
  L3-7, but a reader has no in-entry signal that the source is gone. Optional
  non-numeric edit for L1 near L7: "Substrate absent — see `PROVINCE.md`
  §Surfaces erratum and `substrate-deferral.md`; the line refs below are
  historical." Adds no digits, so it cannot move the population.

## Advice to L1

1. Do not add a `KN-*` row for this entry at this revision; there is no
   current-tense lane-artifact number to bind.
2. Record the reviewed-zero result in the round-27 limit (the lesson currently
   says 18 bindings over 7 entries; this is an eighth reviewed entry with zero
   bindings) so absence-of-row is not read as "measured OK".
3. Do not mechanically bind `0 bytes`/`0600` through `rows:` — that would
   compare unrelated integers. A future field-lookup source would be a new
   mechanism, not a C1 row.
4. The optional absence pointer above is a freshness improvement, not a number
   correction; I did not edit production.

## What I did NOT check

- Did not read or execute `~/.local/bin/the-janitor`, `client.py` or
  `opencode`; no host, vault, handler or CDP contact. Substrate absence is a
  committed declaration, not re-measured.
- Did not run `self-counts.py`, `c1-measure.py`, any gate, selftest, linter or
  formatter. Unrun checks are not passes.
- Did not verify the 2026-09-28 probes, the modes, the `0 bytes` size, the
  ports, or any cited offset against source bytes.
- Did not read the other knowledge entries in full; sibling statements above
  are targeted greps, not full reviews.
- Did not inspect git history before BASE beyond blob equality, and did not
  check whether L1 later adds a binding row for this doc (if so, re-run
  `c1-measure.py`).
- The strict-QM21 alternative reading (offsets "current but unbindable") is a
  judgment call for L1; I did not pick it silently.

## Files written

Only this report and `KnowJanitorLifecycle.exclusions.json` (same directory).
No production file was modified. No tools installed or upgraded.
