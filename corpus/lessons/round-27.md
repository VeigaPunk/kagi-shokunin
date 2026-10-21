source: S042, S043
verified-at: 2026-10-21 — SemVer 2.0.0 and PyPA version-specifiers pages fetched with the declared curl profile; quotes located under rendered-text-v1; no vault/account/handler/CDP contact
recheck: 180d — re-open both specifications; re-run `.ufo/waves/round-27/tools/c2-measure.py` and the release-clock selftest after any change to `corpus/release-clock.py`

# Round 27 — knowledge-entry numbers bound; release clocks refuse silent regression

Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (round26 admitted,
fleet MANIFEST rounds[419], CloseTabi21; its outside spot-check agreed on all
four sampled admits/rejects and routed no defect). Claims are declared in
`plans/round-27.md`: C1 calibration (knowledge-entry numbers, round-25 named
debt D2) and C2 freshness (numeric regression is a finding, not a release;
the inherited limit round-26 FinalRearm named). All six axes sit at 9; the
last capability entered round25, so no stagnation waiver is used. C2's lone
clone remains INCOMPLETE/48 in a lone layout; it is not a round-27 target.

## Gate — sources opened and decided this round

Both pages were fetched by the L1 on 2026-10-21T15:13:51Z with
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`
(HTTP 200, no redirect); bodies, digests and locate counts are in
`.ufo/waves/round-27/captures/metadata.json` and `corpus/source-fetches.tsv`.

| Candidate | Decision and basis | URL, access date, located quote |
|---|---|---|
| S042 SemVer 2.0.0 §11.2 | ADMIT tier A for numeric precedence of strict X.Y.Z cores (QA1 primary spec). Scope excludes API-compatibility semantics: vendors are not asserted to follow SemVer. | https://semver.org/spec/v2.0.0.html ; 2026-10-21; “Major, minor, and patch versions are always compared numerically.” (§11 Precedence, 11.2; 9 words; located once) |
| S043 PyPA version specifiers, Final releases | ADMIT tier A for CPython-style release-segment ordering; its zero-padding rule for X.Y is explicitly NOT implemented (QA3 limit). | https://packaging.python.org/en/latest/specifications/version-specifiers/ ; 2026-10-21 (page last updated Oct 12, 2026); “Comparison and ordering of release segments considers the numeric value of each component of the release segment in turn.” (19 words; located once) |
| A release-ordering spec proves a vendor's feed is complete or monotonic | REJECT (QA3/QA9): ordering says which of two versions is older; it does not say a feed lists every release, nor that a vendor never yanks one. A REGRESSED finding is therefore a typed stop for re-verification, not a claim that the vendor rolled back. Flip: a vendor statement of feed completeness, scoped to that feed. | Same two pages; neither discusses feeds. |
| Lexical/date ordering of feed entries | REJECT (QM23 already; S042 §11.2 numeric): `1.10.0` > `1.9.0` numerically, and round26's first item 3.14.9 is newest-dated but not newest. Flip: none — numeric order is the spec. | S042 §11.2; `.ufo/waves/round-26/captures/S039.body` |

**Existing registry cells (status/recheck/used-by), old → new:** none.
Sources 41 → 43, both new rows tier A/mined, used-by this lesson; no
coverage-map ground added (expansion unchanged).

**Outside admit/reject spot-check:** pending parent closure; dispatched
children are lane authors and cannot supply it.

## C1 — what was bound, what was excluded

Population rule (`corpus/self-counts.tsv` header; QM26): current-tense
numbers in `corpus/knowledge/*.md` about this lane's own artifacts (selftest
case counts, ledger/stamp/claim rows, data-file rows, mutation counts) that
have a lane-local pinned source. Excluded by rule, not omission: sections
dated as measurements or source bases (`Reproduction (2026-09-28)`,
`Reproduction (2026-09-29)`, `Source basis: … run on/measured …`), Evidence /
Erratum / Round-N findings history, host/substrate observations (DB rows,
agent counts, breadth children, handler line spans), positional case indexes,
spelled numbers, numbers with no lane-local pinned source (e.g.
`OP_REF_PROBE` checks=44, transcript-scan's 11 tables/888 cells/32 patterns),
and per-round counts that move every round (written as a pointer instead).
All 25 entries were inventoried by one BUILD scout each
(`.ufo/waves/round-27/build/Know*.md`); 17 entries hold no in-population number.

Bound: 22 bindings over 8 entries (`KN-*`). Stale at BASE and corrected with
the old value beside the new one (QM21): `knowledge/claim-ledger.md:304`
selftest 72→170 ("72 at round-13 close"); `knowledge/op-ref-consumption.md:276`
29→36 and `:296` 21→36 (both "when §9/§10 was written"); 
`knowledge/surface-census.md:32` symbol pins 19→20. The per-round
`claims=17 stamped=33` on `claim-ledger.md:301` now reads `claims=N … stamped=M`
pointing at R21-04/R12-03 (they move every round; binding them would force a
knowledge edit each round — CritC1AppendOnly), with the round-13-close values
kept as history; its `cites/cells` outputs are labelled round-13-close output.
The first draft's "round-10 output" label was wrong (the gate shipped in round
11; the values first appear in round 13 — CritC1Population) and is corrected
before landing. Misstated (never-true) values the round-22 erratum conceded
but left in the body are marked where stated: `surface-census.md:5`
"9 json" (8) and `:76` "16 published hashes" (9 of 15). Positional indexes
are named, not bound: `claim-ledger.md:81` case `verdict-not-final` (16th when
written), `substrate-deferral.md:85` cases `defer-substrate-*` (95-97 when
written). Locators tie repeated copies with backreferences (CritCounting).
Old/new text: `.ufo/waves/round-27/knowledge-migrations.json`.

Named debt, not fixed: the dated negative sweeps in
`sops-age-key-rotation.md:68-70` / `vault-openbao-token-lease-lifecycle.md:76-78`
(the grep exits 0 since round 22 — a QM10 absence claim, not a count);
`surface-census.md:226` "selftest case 14" and `:280` "selftest 10" (off by
one per KnowSurfaceCensus), `:119` "Floors are one third"; transcript-hygiene's
unbound 11/888/32 (no pinned source; needs a script summary change);
`checklist-execution.md:80` "Seven" (spelled); stale SCORECARD line pointers in
`handler-trust-boundary.md:306` and `config-layering.md:125-126` (+4, spans, not
counts); the round-25 pointer `credential-isolation.md:120-122` (file has 78
lines). Each names its scout report.

## C2 — regression is a finding

`numeric_version`/`is_regression`/`feed_floors` in `corpus/release-clock.py`
order strict X.Y.Z cores numerically (S042 §11.2; S043 supporting). A row is
`REGRESSED` (exit 1, not observed) when its observation is below its own
numeric anchor or below the highest numeric anchor of any row on the same feed
URL; `--observe` also floors on the row's previously recorded observation and
types such an observation `regressed`. The feed floor closes the un-fire that
the first draft only claimed (CritC2Rollback, CritC2NonNumeric: the fired
3.15.0 rows re-reading 3.15.0 while 3.15.1 is anchored) and gives S012's
non-numeric `v1.21.x` the Vault feed's numeric floor. Nine new selftest cases
(67→76): fired lie, below-anchor not-fired (already INCONSISTENT at BASE, so
not a red-before witness), numeric-not-lexical, an honest non-numeric control
(1.3.0 above the series), two feed-floor cases, a regressed receipt, a live
downgraded feed with an `-rc` entry above it, and a return-to-anchor
observation after a newer one was recorded.

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M27-1 | survivor (inequality accepted as a release) | `.ufo/waves/round-27/c2-before.json`: at BASE `0a47dd18` all four downgrade fixtures end `RELEASE_CLOCK: CLEAN`, exit 0 — single-row lie (fired=4), whole-feed rollback (fired stays 3), predecessor-only un-fire (fired=1), S012 non-numeric downgrade; round26 FinalRearm named the limit, round25 R25-C7/C8 chose `observed != anchor` | none — QM23 asks for an observable identity, not an ordered one | REGRESSED rule + feed floor + nine selftest cases; the same fixtures at the measured revision must end exit1 with exactly the expected REGRESSED ids (final Gate below); QM25 |
| M27-2 | number-drift (knowledge entries outside the binder) | `.ufo/waves/round-27/c1-before.json`: the final binding table over BASE docs reports the stale knowledge numbers; round25 named them as debt for two rounds | QM21 (scope was SKILL/PROVINCE/README only) | KN-* bindings + corrections; `c1-measure.py --mutate <id>` for every KN id must turn exactly that id STALE (final Gate below); QM26 |
| M27-3 | overclaim in the L1's own first draft | first C2 draft and QM25 said "never an un-fire" while the code compared each row only with its own anchor; the first C1 draft labelled round-13 values "round 10" and left `stamped=89` stale after its own stamp moved to 90 | none — caught by the round's own critics (CritC2Rollback, CritC2NonNumeric, CritC1Population, CritCounting, CritNoHarm) before landing | feed floor + `unfire`/`nonnumeric` fixtures; history labels corrected; per-round counts written as pointers |
| M27-4 | scope (seat misroot) | KagiR26.ScribeLesson-17 wrote its report at the fleet root `.ufo/waves/round-27/build/ScribeLesson.md`; reported by KengakuR28 and Main; relocated byte-exact, `.ufo/waves/round-27/misroot-sweep.txt` | the wave context's absolute-path rule (not enforced) | relocated; the report keeps the seat-scope debt visible |

## Limits

- C1 binds a reviewed population, not every digit in 25 entries; the
  exclusion classes above are judgment calls a non-author may dispute.
- C2 orders numbers only. An observation EQUAL to the feed's highest anchor
  is indistinguishable from a legitimate state on offline replay; two-component
  and prerelease anchors are not ordered; the feed floor assumes every row on a
  feed observes that feed's global max-stable (a future branch-scoped row,
  e.g. a 3.11 security release on python.org, would be wrongly REGRESSED —
  SrcPythonVersions). GitHub documents no Atom window/order/completeness
  (SrcGithubAtom, absence sweep of github/docs at `cca0c9d7`); a REGRESSED
  finding needs human re-verification and is not a claim that a vendor
  withdrew anything.
- C1 and C2 share bookkeeping files (stamps, ledger pins, SKILL/PROVINCE
  lines) and one causal edge: SC/PV-CLOCK-SELFTEST bind the clock selftest
  count, so a C2 selftest change turns C1's binder STALE until the doc moves
  (CritSeparability). Separability is executed by claim-only overlays
  (`tools/separability.py`), not asserted.
