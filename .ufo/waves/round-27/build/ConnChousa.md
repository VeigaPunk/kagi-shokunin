# ConnChousa — kagi C1/C2 vs chousa research-method boundary

Lane: kagi-shokunin. BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Paths are lane-relative unless prefixed `chousa-shokunin/` (sibling lane under
the fleet root). Working-tree round-27 lines are labelled **candidate**; they
are absent at BASE. No production file was written; no gate, selftest, build,
linter or formatter was run (contract). Every count below is either an `awk`
fact over committed files, a committed ledger pin, or a `git show` of a
named revision.

## 1. Axes

- C1 calibration: bind current-tense knowledge numbers; one-digit mutation must
  go STALE; stale values corrected with a history clause.
- C2 freshness: numeric observation below numeric anchor is `REGRESSED`, never
  fired/CLEAN, never a release event.
- Secondary surfaces traced: contract (registry/QUALITY conventions), substrate
  (which gate owns a number), verification (before/after overlay).

## 2. Boundary evidence — the convention is already shared, not duplicated

The kagi source registry is the chousa contract v1 shape, and kagi already
enforces it mechanically:

- `chousa-shokunin/PROVINCE.md:5-8` owns question framing, source hierarchy,
  citation chaining and claim-vs-source verification; `:10-15` refuses secret
  values in any record "→ kagi for custody". `PROVINCE.md:67` (kagi) declares
  the reciprocal boundary: "chousa owns the research method (`SOURCES.md`
  restates neither method nor admission bar)".
- Registry column set `id|source|kind|tier|scope|anchor|teaches|status|opened|
  recheck|used-by` is identical in `corpus/SOURCES.md:5-7` (kagi) and
  `chousa-shokunin/corpus/SOURCES.md:10-12`; section contract enforced at
  `corpus/sources-census.sh:205-207` (Registry / Paths / Search log / Leads).
- Tier vocabulary `A|B|C`, status `queued|mined|rejected`, kind enum including
  `spec` and `community`: `corpus/sources-census.sh:191`; tier-A-on-community
  inflation refused at `:34,196`; chousa's "tier C is a lead, never sole
  support" (`chousa-shokunin/corpus/QUALITY.md:24-27`) is the same rule kagi
  enforces at `corpus/sources-census.sh:356`.
- "Tier definitions live in `corpus/SOURCES.md` (contract v1); this file does
  not restate them" — kagi `corpus/QUALITY.md:5-6`; chousa states the same
  delegation at `chousa-shokunin/corpus/QUALITY.md:12-13`.

Conclusion: a second convention would be the regression. C2's new rows reuse
the existing one (below), and C1's history clause is the same append-only
discipline as `chousa-shokunin/corpus/QUALITY.md:6-7` (errata append-only,
rejection kept).

## 3. C1 stays in-lane — with one declared blind spot and one live counterexample

In-lane: C1 edits `corpus/knowledge/*.md`, `corpus/self-counts.tsv`, the
lesson and bookkeeping. chousa's criterion 9 "one home per number and finding"
(`chousa-shokunin/corpus/QUALITY.md:33-40`) binds chousa's own restated counts;
it does not reach kagi artifacts. kagi's QM26 (`corpus/QUALITY.md:133`)
supplements QM21 (`:118`) rather than restating chousa's rule.

Declared blind spot (not a defect, must not be read as source admission): all
seven knowledge files carrying round-27 `KN-*` bindings have zero column-1
`source:`, `verified-at:` or `recheck:` lines (checked by
`grep -c '^source:'` etc. over `adjacency-breadth`, `adjacency-scope`,
`checklist-execution`, `claim-ledger`, `drift-gate`, `op-ref-consumption`,
`surface-census`). They are LEGACY under `corpus/sources-census.sh:91-95` and
`:337`: outside the header/cite/tier/credential checks. So C1's population is
number-bound but not source-chain-checked; the round lesson should not let
"bound" imply "admitted".

Counterexample (stale, unbound, in the round-25 reviewed population):

- `corpus/README.md:182` says "the 28 `on-release` registry rows bound to
  S033–S037 release feeds or to their declared capture quote". Live value is
  **30**: `awk` over the registry `recheck` column = 30, and
  `corpus/release-clocks.tsv` has 30 data rows, one-to-one by id, at BASE and
  in the working tree. The committed gate pin agrees:
  `corpus/claim-ledger.tsv:83` (R25-04) expects
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3
  derived=15)`.
- It was correct at round 25: `git show 1bf3eec:corpus/release-clocks.tsv` =
  28 data rows. It went stale when round 26 added S040/S041
  (`git show d30c989:corpus/release-clocks.tsv` = 30); `corpus/README.md:182`
  is unchanged at BASE.
- It is not bound: `corpus/self-counts.tsv` has no `RD-*` row for the clock
  population (rows cover census/state/scope/ledger/stamps/docs/opref/
  checklist only), so a one-digit edit `28`→`29` passes the binder. That is
  the exact defect class C1 exists to close, one line outside its declared
  knowledge-only before/after.
- Counter-argument, stated rather than smoothed: the same sentence ends "This
  is historical evidence" (`:184`), which a reviewer may read as a history
  marker. QM21 (`corpus/QUALITY.md:118`) requires "an explicit history clause
  with a newer value beside it"; no newer value is present, so under the
  letter of the lane's own criterion it is current-tense. It is a judgment
  call, not a clean catch.

## 4. C2 stays in-lane — source rows conform; vocabulary is the boundary

- C2 touches `corpus/release-clock.py` (`:369-390` `numeric_version`/
  `is_regression`; `:543-546` REGRESSED typing; `:1027-1043` six round-27
  selftest cases), its table/receipt and the two new spec rows. It does not
  touch chousa's method; the method owner defines `on-release` as
  `event; no inferred calendar deadline` and says event freshness "does not
  certify that releases were monitored" (`chousa-shokunin/corpus/knowledge/
  recheck-due-r26.md:27,34`). kagi's rule is an executor inside kagi's own
  gate for kagi's own registry rows — a compatible strengthening, not an
  absorption of the method.
- New rows conform to the shared contract: `corpus/SOURCES.md:49-50`
  (**candidate**; S041 is the last row at BASE, `git show
  0a47dd1:corpus/SOURCES.md` line 48) — 11 columns, `spec|A|mined`, scope limited to
  numeric core ordering, vendor SemVer semantics explicitly disclaimed;
  capture provenance at `corpus/source-fetches.tsv:85-86` (candidate);
  citation back-link `corpus/lessons/round-27.md:1` `source: S042, S043`.
  The stronger claim ("an ordering spec proves a feed is complete or
  monotonic") is *rejected* in the round lesson Gate, so the transfer to
  curl/Vault/SOPS tags stays a declared inference, not an absorbed method.
- Vocabulary hazard (report, not defect): chousa's freshness states are
  `current|overdue|event|unknown` (`recheck-due-r26.md:25-28,34`). `REGRESSED`
  is a fourth state. Any future cross-lane mapping must not collapse it into
  `overdue` (a calendar claim) or `event` (unmonitored); it needs its own
  name. Today no sibling consumes it: a bounded `grep -rl 'REGRESSED'` outside
  kagi returned no sibling gate/corpus hit.
- Cadence boundary: S042/S043 carry `recheck: 180d`, not `on-release`, so the
  release clock does not observe them (`release-clock.py:485-491` enumerates
  only `recheck == "on-release"`). Their calendar cadence has no kagi
  executor; kagi's census only checks that a `recheck:` line exists
  (`corpus/sources-census.sh:339-340`). Do not import chousa's
  `verify-metadata` to close that: it is chousa's method for chousa's entries.

## 5. Proposed move (one, bounded)

Close the counterexample by binding the number to the clock gate's own
population identity, reusing the existing `ledger:` source — no new gate, no
new format:

1. `corpus/README.md:182` — "the 30 `on-release` registry rows (28 until
   round 26 added S040/S041) bound to S033–S037 and S039 release feeds or to
   their declared capture quote". The feed range is also stale: S040/S041 are
   bound to S039, not to S033–S037, so `S033–S037` alone is incomplete.
2. `corpus/self-counts.tsv` — one row (six columns):
   `RD-CLOCK-ONRELEASE` | `corpus/README.md` |
   ``the ([0-9]+) `on-release` registry rows`` | `ledger:R25-04` |
   `on_release=([0-9]+)` | `clock population; R25-04 enumerates registry
   on-release rows (release-clock.py:485-491), ORPHAN/UNBOUND fail the gate`.
   `ledger:` is the existing re-derive source (`corpus/self-counts.py:12-13`,
   execution/refusal at `:258-299`); R25-04 is untagged, so the binder's
   host/substrate refusal (`self-counts.py:258-260`) does not apply.
3. `corpus/claim-ledger.tsv:81` — R25-02 expect `claims=56` → `claims=57`.
4. `corpus/lessons/round-27.md` §C1 — say "18 knowledge bindings + 1
   non-knowledge clock-population binding" and keep "five were stale" scoped
   to knowledge; this is a sixth stale number outside that population.

Why this and not a scalar fix: the number names a population that C2 iterates.
Binding it makes the before/after overlay report one more STALE on BASE docs
and clean on after docs, and makes a future population change (new on-release
row, or an orphan clock row) fail loudly through the gate's own verdict rather
than through prose drift.

Affected axes: calibration improves (stale unbound number closed, mutation
detected); freshness neutral-to-positive (population identity of the clock
table checked; no verdict semantics change); contract reuses chousa/kagi shared
conventions; verification adds exactly one measurable pair to the C1 overlay.

## 6. Risks

- Scope: the plan's C1 before/after is knowledge-only. This row widens the
  claimed population by one README binding; it must be declared as
  non-knowledge or deferred with a named-debt line. "No complete digit census"
  still holds.
- Failure mode: if a clock row ever exists for a non-on-release registry row,
  `release-clock.py:517-519` adds ORPHAN, R25-04 exits nonzero, and
  `self-counts.py:298-299` fails **SETUP (exit 2)**, not STALE. Loud, not
  silent — acceptable, but the note must not promise a STALE here.
- History wording: 28 was correct at round 25; the clause must name round 26
  (S040/S041), not "stale since round 25".
- If L1 rejects the binding, the prose correction and history clause are still
  required; the number is stale regardless.

## 7. Verification for L1 (unrun here — unrun is not a pass)

- `python3 corpus/self-counts.py` → expect `claims=57 stale=0` (exit 0).
- Plan's after-table overlay on BASE docs → one additional STALE at
  `corpus/README.md:182` (28 vs 30); on after docs → `stale=0`.
- `bash corpus/claim-ledger.sh` R25-02 → `claims=57`; R25-03 selftest stays 73
  (no new selftest case); R25-04 default → `on_release=30` unchanged.
- `corpus/sources-census.sh` → S042/S043 rows still pass `SC_ENUM`/`SC_FETCH`
  and `SC_USEDBY_NOCITE` against `corpus/lessons/round-27.md:1`.

## 8. What I did NOT check

- Ran no gate, selftest, overlay, build or formatter; the 30/30 counts are
  `awk`/`git show` facts plus the committed R25-04 pin, not an execution.
- Did not open every sibling corpus. Bounded sweep: all `*/PROVINCE.md` for
  `SemVer|release clock|release-clock|version precedence|on-release`
  (only kagi matched), plus the five named chousa files
  (`PROVINCE.md`, `SKILL.md:14-45`, `corpus/QUALITY.md:1-63`,
  `corpus/SOURCES.md:1-40`, `corpus/knowledge/recheck-due-r26.md`).
- Did not inspect sibling `SKILL.md`/`SOURCES.md` outside chousa; did not
  check parked or omitted lanes beyond the directory listing.
- Did not fetch or verify any vendor feed; did not validate that chousa's
  research-gate actually behaves as its prose says (read-only, unexecuted).
- Did not decide whether README:182's "This is historical evidence" sentence
  satisfies QM21 — that is an explicit non-author judgment call, stated as a
  contradiction above, not resolved here.

## 9. Tooling

No install or upgrade performed; no host-private read; no vault/account/
handler/CDP contact; no sibling write.
