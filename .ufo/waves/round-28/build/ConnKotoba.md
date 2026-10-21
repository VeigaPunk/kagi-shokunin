# ConnKotoba — sibling-overlap scan: kotoba-shokunin vs round-28 C1/C2

Read-only at BASE `3553d499577084a6c98d7078906017840bbf7b28`; lane HEAD
`b9a42c0e947648ad9f3cf0245784fcb08dc1a442` (`git diff --stat BASE HEAD` = census
+ plans/round-28.md only), sibling HEAD `7ad7fadfc09354b74fb66605dfb0c1182c115a2f`.
A transient `M verifiers/verify_surfaces.py` was gone on re-read (concurrent lane); no cited kotoba file was ever modified, so all kotoba lines are HEAD 7ad7fad.

## Findings

**F1. C1's leading-zero authority is unlocated at BASE.** `plans/round-28.md:22`
cites "SemVer S042 §2"; S042 (`corpus/SOURCES.md:49`) anchors only "§11
Precedence, item 11.2" and quotes numeric comparison; S043 (`:50`) anchors
`#final-releases` for ordering and records zero-padding as unimplemented — no
syntax ground either. Kotoba's row shape is anchor+quote (`corpus/SOURCES.md:18`, S005) and
"by anchor, not by number" (`opencode-extraction-round14.md:74`). Peers
`ScribeSourcesRows.md` finding 5 / `SrcGoSemverCanon.md` finding 7 reached this;
my addition is sibling confirmation, not discovery.

**F2. C2's locator has four false-positive shapes** against `plans/round-28.md:51`:
1. S029's own row anchors the curl **8.23.1** man page (`SOURCES.md:35`) and
   S037's *teaches* also says 8.23.1 (`:43`); only S037's *anchor* says 8.23.0.
   `sources[row_id]` or a teaches scan falsely rejects `release-clocks.tsv:26`.
2. S034 teaches `v0.26.0`/`v2.2.0-rc1`; S035 teaches `api/v2.7.1`/`sdk/v2.7.1`
   (`SOURCES.md:40-41`) — anchor cell only.
3. S033/S034/S035 anchor cells repeat the same version twice (`:39-41`);
   "exactly one occurrence" false-fails — require one distinct value.
4. Keep `note.startswith("derived:")` (`release-clock.py:565-566`);
   `clock=="feed"` adds S012 (`release-clocks.tsv:9`) and S040/S041 (`:30-31`),
   excluded by C2.

**F3. Canonicality is a validity gate, not normalization.** `numeric_version`
(`release-clock.py:369-380`) returns `(3,15,1)` for `3.15.01` (reproduced outside
the lane). Canonicalizing both C2 sides before comparing launders the C1 defect
into a pass; C2 must emit a named non-canonical finding (or defer to C1), never
equality. `SimpClockParsers.md:10` wants "the same canonical string" — same
*reject*, then compare.

**F4. Ownership: neutral.** Kagi gives kotoba `shared-read` on
`$HOME/.agents/AGENTS.md` (`adjacency.tsv:84`, basis
`lane:kotoba/corpus/knowledge/alwayson-checklist-round7.md:30`) and the
instruction surface of `$HOME/.config/opencode` (`:81`). Kotoba says "report,
don't absorb" (`PROVINCE.md:24-31`; fixture craft at `:31` is tameshi's). C1/C2
touch `release-clock.py`, `release-clocks.tsv`, `SOURCES.md`, ledger/self-count
pins — none of those surfaces. Kagi `AGENTS.md` is 5 lines and `CLAUDE.md` is
absent (exit 1), matching kotoba's audited template/single-owner rule
(`alwayson-checklist-round7.md:20-23,29`); no edit due. Do not claim C2 closes
`corpus/README.md:189-192` (S029 superseding row; ClockS017/S020 locator): it
binds the clock value, not S029's source row. G1-G4 are lane-local; generalizing
fixture method would reach tameshi.

**F5. Wording risk, not mechanism.** Kotoba `SOURCES.md:28` (S015): a pin is the binary sha256, not its version string; opencode's version string moved 2.0.26 → 1.19.3 *down* across a channel change. C1 canonicalizes token grammar inside a declared feed title, not release identity; keep `SKILL.md:48`'s "not live vendor truth".

**F6. Number-binding surface C1 moves.** A new SOURCES row changes
`claim-ledger.tsv:52` (R21-02) and needs a `source-fetches.tsv` row (SC_FETCH,
`sources-census.sh:56`). New cases change the 79 at `claim-ledger.tsv:82`
(R25-03) and prose copies `SKILL.md:48`/`PROVINCE.md:54`, bound by
`self-counts.tsv:22,38`. Kotoba's lesson: consistent copies stay silent, so the
anchor must be outside the edited file (`check_assertion_floors.py:41-43,133,286`;
`floors-registry.json:2`). Kagi's R25-03 regex is that anchor — bump in step.

## Reusable prior art (kotoba HEAD)

| Mechanism | Cite | Use for round 28 |
|---|---|---|
| External anchor + BUMP-IN-STEP | `floors-registry.json:2-3`; `check_assertion_floors.py:133,286` | all count copies move in one change; half-bump fails |
| Named trust boundary | `check_assertion_floors.py:68-74` | C2 residual: a joint SOURCES+TSV edit is out of scope |
| Anchor, not number | `opencode-extraction-round14.md:74,109-115` | compare located text; vanished anchor is a named FAIL |
| Check that cannot fail | `sibling-citation-routing-round21.md:45` | assert C2 EXACT per G1-G4, not in aggregate |
| Committed count baseline | `verify_corpus_integrity.py:628,654-666`; `corpus-baseline.json:13-15` | model for R21-02/R25-03 re-pins |
| Own-work is not vendor truth | `verify_harness_claims.py:33` | C2's anchor is author-declared |

## Proposed move (one, bounded)

`locate_canonical_versions(cell)` reads **only the named anchor cell** and
returns distinct canonical X.Y.Z tokens, or names the first non-canonical token,
or empty. C1 uses it for anchored/observed/feed tokens; C2 uses it on
`sources[feed_source_id]["anchor"]` after the `derived:` gate; a non-canonical
registry anchor is a typed finding naming the registry id, never a C2 mismatch;
neither side is normalized before comparison.

- Axes: freshness (registry text enters the validity gate) and calibration
  (deterministic binding, distinct failure classes); neither harmed — no second
  equality rule, no row outside `feed_source_id`, frozen fixtures untouched.
- Risks: a series anchor (`v2.7.x`) must yield a typed "no canonical token", not
  a pass; dedupe duplicates; C2 proves declaration consistency, not currentness;
  two added rows (S044+S045) move R21-02's counts.
- Verification: frozen `c1-measure.py`/`c2-measure.py` unchanged; control
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3
  derived=15)` exit 0 before/after; G1-G4 EXACT names exactly each group's ids;
  selftest-only discriminators ("grows only by new cases"): `S033 anchor
  v3.13.03` → C1 names S033, S008-S011 not a C2 mismatch; `S037 anchor 8.23.0 +
  teaches 8.23.1` → S029 binds 8.23.0; duplicate `v2.2.0` in S034's anchor → no
  duplicate error.

## Commands run (read-only; no lane gate or selftest)

- `git -C kotoba-shokunin rev-parse HEAD` → 7ad7fad…, exit 0.
- `git -C kotoba-shokunin status --porcelain | wc -l` → 9, then 8 (concurrent), 0.
- `git -C kagi-shokunin diff --stat BASE HEAD` → 2 files, 0.
- `grep -rno '79 cases' SKILL.md PROVINCE.md corpus/knowledge/*.md corpus/README.md`
  → `SKILL.md:48`, `PROVINCE.md:54`, 0.
- `test -e CLAUDE.md` → exit 1 (absent).
- Heredoc reproducing `numeric_version`/`norm_version`: tuple equal, string
  unequal, `ValueError: Exceeds the limit (4300 digits)…`;
  `sys.get_int_max_str_digits()` 4300 (Python 3.14.8), 0.

## What I did NOT check

- No kotoba verifier or kagi gate/selftest executed; no "green" claimed.
- No page fetches; §2/int-string quotes are peer-fetched
  (`SrcGoSemverCanon.md`) or inference.
- Did not diff the transient sibling modification; no citation is in that file.
- Did not verify kotoba's 6/6 AGENTS.md table beyond reading it; kagi checked by
  line count and CLAUDE.md absence only.
- Did not inspect `c1-measure.py`/`c2-measure.py` (not on BASE) or a C2
  implementation (none exists).
- Siblings other than kotoba not scanned.
