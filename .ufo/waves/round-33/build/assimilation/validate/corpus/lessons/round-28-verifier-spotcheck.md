author: hyaku closure (non-author integrator, @m_flash)

# round-28 — non-author verification and spot-check (hyaku closure)

Written by the integrator, not the lane (outside reviews are new files; the lane owns
`round-28.md`). Inputs: fleet report `.ufo/reports/round-28/kagi.md` (fleet commit
`7fb73d02d2efd25388e8d6a51245d96a438b9375`, author `kagi-shokunin <kagi@shokunin.local>`), prompt
`.ufo/prompts/kagi-round-28.md`, lane BASE `899c50b42634a3a4ad0b28ab7509786315e2fc2b` → lane tip
`fdbe306c55df1aef226d8909ca183379ec376c2a`, frozen BASE `3553d499577084a6c98d7078906017840bbf7b28`,
measured revision `5e847472a66fe0b41bfc4c374a3659eace3bd4f8`.

**Round posture: documentary close under a fleet policy HOLD.** The 2026-10-21 attempt ended at a
provider content-safety refusal (`.ufo/l0-questions.md:90`) and the fleet card holds the round
(`.tower/comms/inbox/20261024-r100-recovery-census-tower-survey-summary.md:37` — `kagi | 28 | HOLD —
policy | Never dispatch (content-safety/cyber refusal …)`). Attempt 3 added no claim, measurement,
source row, knowledge entry or capability and retried/rephrased/rerouted nothing. This closure graded
what landed; it neither retried refused work nor ruled the HOLD (operator-owned; also the open
question at `.ufo/l0-questions.md:158`). Watchdog digest (copied, mutable source): `2026-10-21T13:38:04-03:00
launch kagi round=28 pgid=1454889 driver=hyaku-inline attempt=1` / `2026-10-23T20:41:45-03:00 launch
kagi round=28 pgid=3507413 …` / `2026-10-25T03:31:22-03:00 launch kagi round=28 pgid=1837239 …` /
`2026-10-25T04:05:19-03:00 complete kagi round=28; hyaku-inline attempt=1`.

## Step-1 conformance

| check | command | observed |
|---|---|---|
| report author | `git log --format='%an %ae %H' -- .ufo/reports/round-28/kagi.md` | one commit, `kagi-shokunin <kagi@shokunin.local>` `7fb73d02`; fleet `HEAD` = `origin/master` = `e072b1cd` (pushed) |
| SHONEN heading | report §SHONEN vs `SHONEN.md` | heading present, 4 `[~]` lines, 4 boxes in `SHONEN.md` — one line per box, no `[x]` |
| cited lane commits | `git cat-file -e <h>^{commit}` + `git merge-base --is-ancestor <h> master` for `bdf90f58`, `b9a42c0e`, `2dfb534b`, `62a33b1b`, `5e847472`, `899c50b4`, `4839d3f1`, `fdbe306c`, `3553d499` | all exist, all ancestors of `master` (= `fdbe306c`; the jj-colocated repo is on a detached HEAD equal to it) |
| uncommitted work / push | `scripts/hyaku/jj-lane.sh state kagi-shokunin`; `git -C … status --porcelain` | `ahead=0 behind=0 tracked=0 untracked=0`; status empty |
| prompt contract | `diff templates/round-prompt.md .ufo/prompts/kagi-round-28.md` | diffs are substitution sites only (`{{LANE}}`, `{{ROUND}}`, `{{FLEET_ROOT}}`, `{{AXES}}`) plus the §6 hyaku addendum; nothing removed |
| marker vs report | report body | real work, 8 resolvable commit hashes, commands with outputs — not a marker: **status `ok`** |

## Claims — re-check

**Re-measured by the closure** (plain commands I ran myself over `git archive`d trees; the lane
checkout was never touched):

| # | command (frozen, unchanged since `bdf90f58`) | observed by the closure |
|---|---|---|
| C1 before | `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d499… before /tmp/clsr28/c1-before.json` | `C1_MEASURE before: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True` |
| C1 after | `… 5e847472… after /tmp/clsr28/c1-after.json` | `C1_MEASURE after: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` |
| C2 before | `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d499… before …` | `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0` |
| C2 after | `… 5e847472… after …` | `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0` |
| registry | `git show 3553d49:corpus/SOURCES.md \| grep -c '^\| S0'`; `grep -c` at HEAD; `git diff --numstat 144babc HEAD -- corpus/SOURCES.md` | 43 → 51; `29 0` (additions only, zero deleted `^-` lines) |
| census | `scripts/sources-census.sh validate --root . kagi` | exit 0 today, same W04 set as `final/census-end.json`; lane receipt exit 0 |

**Evidence-verified, not executed** (lane-owned gates/probes, §Gate standard Closure consequence):
`RELEASE_CLOCK_SELFTEST: PASS (114 cases)` and the default `RELEASE_CLOCK: CLEAN (on_release=30
bound=30 unbound=0 observed=30 fired=3 derived=15)` from `final/invocations.json`;
`CLAIM_LEDGER: CLEAN (claims=65 deferred=0 stamped=91 ids=65 cited=55 labeled_ids=20 orphans=10
host_skipped=12)` exit 0 from `final/bookkeeping-ledger.txt`; `VERDICT FAIL`/`PASS` from
`final/conformance27.txt`/`final/conformance28.txt`; `final/strict-audit.json` (`passed: true`, four
adversarial controls rejected).

**C1 — freshness: `unprovable`.** The bounded counter reproduces exactly (above), but the claim as
frozen in `plans/round-28.md` ("version tokens are canonical and **total** … never a release event
and never a traceback") is falsified by a token shape the round itself found. Re-derived by the
closure, not accepted on the seat's word: at `fdbe306c`, `parse_latest_version` collects only
`STABLE_TITLE_RE`/`STABLE_TAG_HREF_RE`/`TEXT_VERSION_RE` matches (`corpus/release-clock.py:781-783`,
`$`-anchored) and `non_canonical_version` runs only over the collected tokens (`:786-800`). Probe
over `git archive fdbe306c` in `/tmp/k28probe`: feed with `Python 3.15.1` + `Python 3.15.01.` →
`HEAD newest = 3.15.1` (the non-canonical entry is invisible, not refused); feed with only
`Python 3.15.01.` → `ValueError feed has no stable X.Y.Z release entry`. So a non-canonical newest
entry can be silently skipped and an older canonical entry can read as newest and fire CLEAN — the
declared "otherwise a typed finding" does not hold. No axis is harmed by this: BASE `710-712` carry
the same `$` anchors, so the drop is BASE-identical, a pre-existing gap in an unclaimed shape rather
than a regression. Fix is policy-blocked (the HOLD forbids new craft work) and routed below.

**C2 (same claim, second command): measured, delta partly construction-dependent.** `derivation_exact
0/4 → 4/4` holds under **both** constructions: `final/literal-after.json` shows G1–G4 exit 1 with
`DERIVATION` on exactly the group ids under the literal TSV-only fixture, `final/literal-before.json`
shows G1–G4 exit 1 `RECEIPT-MISMATCH` (accepted 0/4). The headline `accepted 4/4 → 0/4` exists only
under the pre-tool receipt-mirroring amendment (`b9a42c0`, before any tool commit); the literal
reading is `0/4 → 0/4`. The lane states both readings and does not claim frozen-fixture conformance
met — the closure agrees that it is contested and that the substantive direction still verifies.

## Per-axis verdicts (six axes, no scalar)

| axis | verdict | basis |
|---|---|---|
| freshness | `unprovable` | bounded counter re-measured and reproduced (C1 3/4→0/4, 0/4→4/4; C2 derivation 0/4→4/4); the frozen claim's totality falsified by the period-suffixed feed token, fix deferred under the HOLD |
| calibration | `unchanged` | re-booked in-round (`build/CritC2Axis.md`); no claim; SCORECARD 9 → 9 |
| depth | `unchanged` | SCORECARD 9 → 9; no new mechanism |
| coverage | `unchanged` | registry 43 → 51 (8 tier-A rows, append-only, verified); no knowledge entry or governed surface — the lane's own reading, and the rows are claim-grounding/frontier-lead, so agreed |
| operability | `unchanged` | default run `CLEAN30` identical both sides; selftest 79 → 114 (count only, receipt above) |
| adjacency | `unchanged` | SCORECARD 9 → 9; eight connector scans, no absorbed ground |

No axis harmed: `git diff 899c50b… fdbe306c -- SCORECARD.md` shows `9 → 9` on every axis plus two
corrected cells (registry 43 → 51, selftest 79 → 114); `SHONEN.md`, `SKILL.md`, `PROVINCE.md` are
untouched in the round range.

## Discernment spot-check (non-author)

| item | decision | source re-opened by the closure | agree? | reason |
|---|---|---|---|---|
| S045 SemVer 2.0.0 §2 | ADMIT tier A | `https://semver.org/spec/v2.0.0.html`, HTTP 200 (9 108 B), 2026-10-25 | agree | quote FOUND verbatim at item 2, 23 words (cap 25); it grounds the leading-zero half and the same-URL/different-scope W04 is disclosed |
| PyPA version specifiers (S043 URL) | REJECT for C1 | `https://packaging.python.org/en/latest/specifications/version-specifiers/`, HTTP 200 (23 965 B), 2026-10-25 | agree | quote FOUND ("an integer version of 00 would normalize to 0 while 09000 would normalize to 9000"): PEP 440 normalization would erase the finding the lane wants, so the flip (a feed declaring PEP 440 versions) is the right guard |
| S048 new `SOURCES.md` row | ADMIT tier A, frontier lead | `https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning`, HTTP 200 (34 776 B), 2026-10-25 | agree | registered quote FOUND at §About validity checks, 19 words; detection-versus-verification is stated as concept-level with the GitHub-only bound respected |
| gate-quote cap (all eight new rows) | ≤25 words | counted from committed `corpus/SOURCES.md` | agree | S044 11, S045 23, S046 17, S047 21, S048 19, S049 19, S050 21, S051 19 — max 23 |

## Trend verdicts

- **expansion — `unchanged`.** No knowledge entry, governed surface or capability entered; the last
  capability is round 25 (`SCORECARD.md` §Round 28, verified against its capabilities table). The
  three frontier rows S047/S048/S049 are opened leads, explicitly not turned into lane knowledge.
- **quality — `unchanged`.** The two counters and the registry delta reproduce independently, and
  the overstated "refuses any such token" sentence is corrected in-place with a superseding
  corrigendum (swept: the superseded wording survives only in `corpus/lessons/round-28.md` itself,
  nowhere in `SKILL.md`/`PROVINCE.md`/`knowledge/`). But the C1 fail-open is open, so no gain is
  booked; correcting a false sentence is not an improvement.
- **discernment — `unchanged`.** Three self-assessment errors (token totality, the C2 "binds none"
  absolute, an evidence pointer at a superseded draft) were caught only by outside seats,
  after the round's own 64-seat falsify wave, and are on the record with pointers. The lane's
  self-assessment was over-optimistic until checked; disclosing that is not discernment movement.

## Routed defects (lane-owned; fix next round)

- **D1 — C1 fail-open, open.** The three feed tokenizers (`corpus/release-clock.py:781-783`) are
  `$`-anchored while `STABLE_TOKEN_RE` (`:345`) tolerates a sentence period, so `Python 3.15.01.` is
  dropped and `Python 3.15.1.` is invisible (closure probe above). Recipe in the lesson
  §Attempt-3 corrigenda 1 (right boundary `(?![A-Za-z0-9+-]|\.[0-9])` + one positive/one negative
  selftest on the feed path). Deferred under the HOLD, not waived.
- **D2 — attempt-3 gate outputs not committed.** `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0
  added=28 invalid=0)` and `CITATION_GATE: CLEAN (cites=1748 docs=71 …)` are quoted in the report with
  no receipt under `.ufo/waves/round-28/final/` (`bookkeeping-ledger.txt` covers only the ledger).
  Commit both outputs; the commands are reproducible, so this is an evidence-completeness gap.
- **D3 — round shape.** BUILD 73 seats is outside the v1 band (validator:
  `{"code":"wave_too_wide","message":"a wave carries at most 64 lanes (got 73)"}`) and 137 + 8 = 145
  seats exceeds the ≤128 round cap; the round is neither sanctioned shape. Reported by the lane.
- **D4 — dead-seat record contradicted.** `wave-outcomes.json` says `"dead": 0`,
  `"provider_deaths": []`, while the L0 record names a Codex content-safety refusal and a Devin
  weekly-quota failure. The lane reports both and treats `0` as unverified; keep it that way, do not
  retro-polish the wave record.
- **D5 — C2 breadth beyond its named limit.** Marker flip + own-source-cell edit passes with
  `derived=0` (corrigendum 3), and a derived anchor outside the canonical core can register
  `fired=1` against an unrelated observation (corrigendum 4). Both recorded, neither fixed.
- **D6 — misroot witness.** The relocated seat report has only the lane copy's sha256
  `bf25d726…1fe4647` as witness (fleet copy never committed); record hash+`cmp` at relocation time
  next occurrence.
- **D7 — stale SHONEN evidence line.** `SHONEN.md` box 1 still cites `cites=891 docs=53` (`LOG.md:758`)
  while the report cites `cites=1748 docs=71`; both are lane-owned and unchanged this round. Not
  promotion-blocking, but refresh on the next edit.

**Promotion:** not touched. All four boxes are `[~]`; the closure did not check a box, did not promote
and did not mint (operator-owned). Two boxes (2, 4) have pointers a non-author could inspect; box 3's
support was partly re-demonstrated here (both counters reproduced from committed artifacts with no
oral context); box 2's cited task predates the round.
