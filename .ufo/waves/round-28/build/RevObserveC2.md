# RevObserveC2 — does C2 conflict with a legitimately fired derived row?

Reviewer seat, round-28 build. BASE `3553d499577084a6c98d7078906017840bbf7b28` (frozen). BASE lines cited `release-clock.py:NNN`; working-tree
(in-flight) `wt:NNN`. Sandbox (BASE copy + drafts only): `.ufo/waves/round-28/sandboxes/RevObserveC2/` — harnesses `probe.py`,
`proto_c2{,_hazards,_matrix,_isolated,_vacuity,_precision}.py`, `proto_observe_fired.py`, `proto_inflight_check.py`, `proto_rearm{,2}.py`,
`proto_dotted.py`, `proto_c1c2.py`, `proto_mutant.py`, `proto_witness.py`; trees under `work*/`, `lanelab*/`, `mutant/`, `witness/`, `infl/`. No lane
gate, no network, no vault/account/CDP, no lane Git mutation, no tool install; only this report was written outside it.

## Answer

**No — C2 does not conflict with a legitimately fired derived row, provided the rule binds the row's ANCHOR to its feed row's located anchor and
leaves the OBSERVATION free.** The plan's C2 sentence (`plans/round-28.md:51-53`) already says this: *"a `derived:` row's **anchored version** must be
the version named by its `feed_source_id` registry row's located anchor"*. The conflict is real only for a rule that binds the *observation*. The
in-flight implementation binds the anchor (`wt:619`: `derived_anchor_bound(feed_source["anchor"], anchored)`), and my end-to-end run of the real
`--observe` path with the SOPS feed advanced to v3.14.0 keeps all four legitimately fired derived rows CLEAN.

**The rule, stated so fired derived rows stay valid (anchor binds to the feed row; observation free):** (1) resolve `F` = the registry row named by
the derived row's `feed_source_id` — by that id only, never by "newest row for this feed URL", never by the clock row's own source row; (2) let `A` =
the strict `X.Y.Z` tokens in **`F`'s anchor cell** (`release-clock.py:88`, `cells[5]`) — the cell, not the whole registry row (not `teaches`); (3) the
derived row's **`anchored_version`** must equal `A` exactly (`A == {norm_version(anchored)}`; a cell naming zero or two versions binds nothing); (4)
**`observed_version` and `verdict` are unconstrained by C2** — a derived row whose observation moved past its anchor is `fired` and stays valid.
Clause 4 is the whole answer; 1–3 make the binding identifiable rather than vacuous. [INFERENCE] clauses 1–3 are my reading of the plan's sentence,
not its words.

## Findings by severity

**F1 — High. The plan's frozen C2 fixture set cannot discriminate the anchor-binding from the observation-binding; a rule that refuses every
legitimately fired derived row passes the frozen gate 4/4 EXACT with a CLEAN control.** The frozen fixtures (`plans/round-28.md:64-66`; tool
`.ufo/waves/round-28/tools/c2-measure.py:161-165`) set `fields[4] = fields[5] = lower` and `fields[7] = "not-fired"` — anchored **and** observed are
the *same* lowered token, so a rule reading either column sees the same value. Measured, three rule shapes, one frozen instrument
(`proto_c2_matrix.py`; the frozen tool on three local sandbox repos `lanelab*`):

| rule | frozen `derivation_exact` | control | a legitimately fired derived row |
|---|---|---|---|
| anchor-bound (correct) | 4/4 | CLEAN | CLEAN, exit 0 |
| **observation-bound** | **4/4** | **CLEAN** | **4 findings, exit 1** |
| whole-registry-row scan | **4/4** | **CLEAN** | CLEAN, exit 0 |

All three give the same frozen output (`groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0`), but the observation-bound
variant breaks the fired case (`proto_c2_isolated.py` CE2: exit 1, `DERIVED-ANCHOR S008 S009 S010 S011`, on rows whose receipt says `fired` and whose
observation is a genuine newer release). **The frozen fixture set is a weak witness for C2's own claim**; the frozen commands are never changed, so
this is a defect *report* — the discriminating witness must live in the clock's own selftest (F2).

**F2 — High. The in-flight selftest has no case where a derived row is legitimately FIRED with a BOUND anchor, so the observation-binding mutant is
killed only incidentally.** The in-flight derived cases are `wt:1176-1221`. The one whose name mentions "fired" (`wt:1191-1195`, *"derived fired
anchor bound to feed"*) uses `anchored="1.2.0"` against `feed_anchor="Latest release v1.2.9"` — a **mismatch** expecting `DERIVATION`, not a valid
fired row. No case pairs a numeric anchor *equal to* the feed's token with a newer observation and `verdict="fired"`. Mutating the single binding site
(`..., anchored)` → `..., observed_version)`) therefore dies only on the **series-anchor** cases (`wt:1169-1172`, `wt:1228-1233`) (`proto_mutant.py`,
`proto_witness.py`): mutant on the current selftest → exit 1, 6 findings, **all** naming a series anchor, none naming a numeric fired-and-bound row;
mutant + the missing witness → also fails `derived fired anchor still bound to feed`; correct + witness → `PASS (107 cases)` exit 0. The same shape on
the real corpus (four SOPS rows, feed at v3.14.0, receipt `fired`) is CLEAN under the correct rule (`proto_inflight_check.py` FIRED: exit 0,
`clean=True findings=[]`). **The one concrete addition that closes this question inside the codebase: a case with `anchored` = the feed cell's single
token, `observed` = a newer version, `verdict="fired"`, note starting `derived:` → expected `[]` errors, `{"observed": 1, "fired": 1, "derived":
1}`.**

**F3 — High. The plan's C2 wording leaves the binding's *identity* underdetermined, and the wrong readings each break a class of truthful rows.**
`plans/round-28.md:51-53` says "the version named by its `feed_source_id` registry row's located anchor … (the feed row S033–S037 …)". Three readings,
measured on BASE (`proto_c2_matrix.py`, `proto_c2_hazards.py`): (a) *bind the clock row's own source row* → control fails `DERIVATION S029` exit 1 —
S029's own row names curl's unreleased **8.23.1** (`SOURCES.md:35`) while the *feed* row S037 names **8.23.0** (`SOURCES.md:43`) and the derived
anchor is 8.23.0; (b) *bind every feed row, not just `derived:` ones* → control fails `DERIVATION S012` exit 1 — S012 is not derived
(`release-clocks.tsv:9`, note "anchor names the newest pinned version v1.21.x"), its anchor is a series, not the feed's release; (c) *bind the newest
registry row for the same feed URL* → control passes, but a legitimately fired derived row is refused the moment a new feed registry row is appended
(variant F: `fired + new feed row` → 4 findings, exit 1). The corpus already has that shape twice: S036 and S039 are both python.org feed rows
(`SOURCES.md:42`, `:46`), S027/S028 name S036, S040/S041 name S039 (`release-clocks.tsv:30-31`). **Resolve by the `feed_source_id` value, full stop.**

**F4 — Medium. The `derived:` marker is the rule's only scope selector, and it is a free-text note prefix — a rearm that rewords the note silently
drops the row out of scope.** `release-clock.py:565` (BASE) / `wt:615` detect derived rows by `values["note"].startswith("derived:")`. A rearm must
keep that prefix or the row stops being checked and a lowered anchor is accepted again; all 15 derived rows' notes carry it today
(`release-clocks.tsv:5-8,10-13,18-23,26`). Recommend the rearm procedure state the prefix as required. [INFERENCE] No current rearm edits the prefix —
procedural risk, not observed.

**F5 — Medium. C2 binds a *dated* snapshot, so it is a provenance binding and cannot see a stale anchor.** S033–S037 are `recheck=90d`
(`SOURCES.md:39-43`) with a fetch date in the cell, while the clocks they bind are `on-release`; a derived row's note dates the derivation to the
*clock row's* opening ("when the row was opened 2026-10-19", `release-clocks.tsv:5-8`) — a different date from the feed row's fetch, so 11 of 15
derived notes carry a date the pinned source does not support. Version-equality is the only satisfiable reading today (a date-reading C2 fails 11/15),
but **C2 proves the derived anchor equals what the pinned feed row said on its fetch date; it does not prove either is current** (sibling
`RevRearmFlow.md` F4, from the rearm side).

**F6 — Low. Four precision gaps, each measured, none live today but each a rearm hazard.** (a) *No date guard on the token regex* (`wt:345`,
`wt:363`): the rule needs the cell's token *set* to equal `{anchored}`, so a second token breaks the binding — a cell rewritten with a dotted fetch
date ("…fetched 2026.10.21") → tokens `['2026.10.21','3.13.3']` → `DERIVATION S008 S009 S010 S011` exit 1, where today's dashed date → `['3.13.3']` →
exit 0 CLEAN (`proto_dotted.py`). (b) *Membership is vacuous/ambiguous*: a cell naming no version or two versions makes a membership test accept a
forged anchor (exit 0, `proto_c2_vacuity.py`); the in-flight set-equality closes both (`proto_inflight_check.py` VAC and TWO → 4 findings, exit 1) but
the plan text requires only "the version named by". (c) *Numeric ≠ string comparison*: `"3.13.03"` is numerically equal to `"3.13.3"`, so a
numeric-equality implementation accepts a forged leading-zero anchor (exit 0) where string-equality refuses it (`DERIVED-ANCHOR S008`, exit 1)
(`proto_c2_precision.py`); C1's canonicality check reads the *table* only (`wt:617`, `wt:627-631`), so a leading zero written into the registry cell
is reported as a derivation mismatch rather than as the canonicality defect it is (`proto_c1c2.py`: Q1 `['DERIVATION']`, Q2 `['NON-CANONICAL']`, Q3
`[]`; both wrong states are typed, exit 1 — mis-attribution, not a hole). (d) *Scope wording*: the plan's "the feed row S033–S037" under-counts the
feed rows the clock loads — feed-kind, non-`on-release` registry rows are S001–S004 and S033–S039, and the `feed_source_id`s actually named are
S033–S037 **and S039** (`release-clocks.tsv:30-31`); no `derived:` row names S039 today, so behaviour is equal, but the wording should read "every
feed registry row a `derived:` row names". (b)–(d) overlap sibling `RevRearmFlow.md` F5/F7 and C1's owner; (a) and the attribution half of (c) are
new.

## Commands run (sandbox only; exit codes as shown)

All under `.ufo/waves/round-28/sandboxes/RevObserveC2/`, `python3 -I -B <script>`.
- `corpus/release-clock.py` (BASE tree) → exit 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`; `--selftest` → exit 0, `PASS (79 cases)`.
- `.ufo/waves/round-28/tools/c2-measure.py 3553d499…b28 BASE c2-before.json` → exit 0, `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0` (frozen "before", reproduced).
- `probe.py` → feed rows' located-anchor token sets: S033 `['3.13.3']`, S034 `['2.2.0']`, S035 `['2.7.1']`, S036 `['3.15.0']`, S037 `['8.23.0']`, S039 `['3.15.1']`; all 15 derived rows bind; S012 (`v1.21.x`) and S029 (own row 8.23.1) do not.
- `proto_c2.py` → A: control CLEAN, G1–G4 EXACT, FIRED CLEAN; B: FIRED → 4 findings; C: control → `DERIVED-ANCHOR S029`; D: control → `DERIVED-ANCHOR S012`. `proto_c2_hazards.py` → E: forged `8.23.1` accepted (exit 0); F: fired + new feed row → 4 findings (exit 1); R: fired + in-place anchor rewrite → 4 findings.
- `proto_c2_matrix.py` → the six-variant table above; `proto_c2_isolated.py` → CE1 (forged 8.23.1): A `DERIVED-ANCHOR S029` exit 1, E exit 0 CLEAN; CE2 (fired rows): A exit 0 CLEAN, B exit 1 with 4 findings. `proto_c2_vacuity.py` → cell emptied of versions → exit 0 (vacuous under membership); cell naming two versions → exit 0 (membership accepts either).
- `proto_c2_precision.py` → `"3.13.03"` numerically equal to `"3.13.3"` but string-unequal; numeric-equality implementation accepts the forged leading-zero anchor (exit 0), string-equality refuses it (`DERIVED-ANCHOR S008`, exit 1). `proto_c1c2.py` → Q1 `['DERIVATION']`; Q2 `['NON-CANONICAL']`; Q3 `[]`.
- `proto_observe_fired.py` → the **real** `run_observe` path, SOPS feed stubbed at v3.14.0 (the script's own `request_body` substitution): receipts `S008–S011 parsed=3.14.0 verdict=fired`; anchor-bound → `CLEAN (… fired=7 derived=15)` exit 0; observation-bound → `DERIVATION S008 S009 S010 S011` exit 1. `proto_inflight_check.py` (in-flight tree) → control CLEAN exit 0; G1–G4 EXACT 4/4; FIRED `exit=0 clean=True findings=[]`; NEWROW `exit=0 clean=True`; CURL (forged 8.23.1) `DERIVATION S029` exit 1; VAC 4 findings exit 1; TWO 4 findings exit 1; selftest `PASS (106 cases)` exit 0.
- `proto_rearm2.py` → R0 (rearm pending, rows legitimately fired) exit 0 CLEAN; R1 (corpus-precedent rearm: new registry row S044 + re-point + re-anchor) exit 0 CLEAN; R2 (forbidden in-place rewrite of S033's cell, rows still 3.13.3) exit 1, 4 findings; R3 (in-place rewrite + re-anchored) exit 0 CLEAN. `proto_dotted.py` → dashed fetch date exit 0 CLEAN; dotted fetch date exit 1, `DERIVATION S008 S009 S010 S011`.
- `proto_mutant.py` → observation-binding mutant: in-flight selftest exit 1, 6 findings, all series-anchor; frozen c2-measure `derivation_exact=4/4 control_clean=True` (**the mutant passes the frozen instrument**); on the real corpus it yields `DERIVATION S008 S009 S010 S011` on the four legitimately fired rows, `passed=False`. `proto_witness.py` → correct + missing witness `PASS (107 cases)` exit 0; mutant + witness exit 1 with `derived fired anchor still bound to feed` failing.
- Frozen tool on three local sandbox repos (each `git init` + commit; lane untouched): `c2-measure.py <rev> VAR-A|VAR-B|VAR-E <out>` → exit 0, all three `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0`.

## Residual risk and verification gaps

- **The in-flight working tree was moving under me.** I copied `corpus/release-clock.py` from the lane at one moment (`wt:345/363/615/617/619/1176-1221`) and tested that copy; a later edit shifts those numbers. BASE numbers (`:88`, `:341`, `:390`, `:565-566`, `:582-586`, `:798`) come from the frozen sandbox copy and are stable. Every in-flight claim was re-verified against the copy I tested, not the live file.
- **No network fetch.** "SOPS v3.14.0" is a **synthetic** version used only to exercise the machinery (a stubbed `request_body` serving Atom bytes, the substitution the clock's own selftest uses). No such release is claimed; no feed was re-observed; no lane receipt was read or written beyond the BASE copy.
- **The rearm shapes R0–R3 are constructed, not executed.** No rearm was performed in the lane, no `SOURCES.md` row added, no default receipt migrated, no stamp/ledger/self-count regenerated. The rearm *coupling* is `RevRearmFlow`'s scope; I measured only whether each shape leaves a *fired derived row* valid.
- **I did not run the lane gates** (forbidden for this seat): `bash corpus/sources-census.sh`, `bash corpus/claim-ledger.sh verify`, and `python3 corpus/release-clock.py --selftest` **in the lane checkout** were not run; I read `corpus/claim-ledger.tsv` and the BASE tree instead.
- **I did not judge C1's completeness** (XC1Patch/XC1Measure own it), the ledger/stamp bookkeeping, the lesson text, or the `SC/PV-CLOCK-SELFTEST` pin (in-flight selftest count is 106 at the copy I tested; the F2 witness would make it 107 and move the pin — L1's bookkeeping).
- **I did not check `resume_continuity_v1`** (no such artifact in this lane's tree), and did not verify git/jj state, remote parity, or the round-28 END census.
