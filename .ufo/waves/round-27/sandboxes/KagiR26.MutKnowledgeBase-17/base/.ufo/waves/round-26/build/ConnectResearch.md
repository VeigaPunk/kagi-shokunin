# ConnectResearch — round 26, C1 sibling-overlap scan (chousa research method vs kagi source maintenance)

Seat: `KagiR26.ConnectResearch` (connector, leaf). Lane-authored advice, not non-author closure.
Axes judged: freshness, calibration. Writes: this file only. No production, sibling, git/jj, host-private, network or install action. No gate, selftest, build or lint was run.

## Bounded result

**C1 is in-lane.** Re-opening kagi's own S027/S028 rows (Python `re`/`html` docs that ground kagi's own `corpus/rendered-text-v1.py`), recording a new kagi receipt, and appending superseding kagi rows is application of chousa's method through the fleet SOURCES contract. It is not a second method, provided the three boundary conditions under Counterexamples hold. There is no conflicting ownership claim in any of the 21 sibling `PROVINCE.md` files.

## Observed identities

| item | observed |
|---|---|
| kagi HEAD | `1bf3eec48d3761580ffd375c88143232485ae814` (= frozen BASE); `git status --porcelain` shows only `?? .ufo/waves/round-26/` and `?? plans/round-26.md` |
| kagi production vs BASE | `git diff --quiet 1bf3eec -- PROVINCE.md corpus/SOURCES.md corpus/release-clocks.tsv SKILL.md` exited 0 |
| kagi `PROVINCE.md` sha256 | `22ed8900afaef06610dfc112fdb7e09d32c152cbdc4385129607424b8ba2cdaa` |
| chousa HEAD | `0e9784bd52eca456b24d0bc40921480a47f91a2b` (2026-10-21 09:48:28 -0300, "round-26: bound metadata allocation and add scheduling and registry screens"). Chousa's round 26 is in flight: dirty `.ufo/waves/round-26/**` and `corpus/lessons/round-26.md`. The cited files below are clean at that HEAD (`git status --porcelain -- <cited files>` printed nothing). |
| chousa `PROVINCE.md` / `SKILL.md` | `cf7826a4…ec` / `ee217975…8f` |
| chousa `corpus/knowledge/recheck-due-r26.md` | `a0995b78…7d5e` |
| chousa `corpus/QUALITY.md` / `corpus/SOURCES.md` | `2428baaf…dce6` / `8308e629…a5aa9` |
| fleet root HEAD / `CORPUS.md` | `fbceeceb30b9a0f9888c2187c3888da9633b0a2d` / `88556402…50b8` |

Freshness caveat: chousa's anchors may move before L1 integrates. Re-check the digests above before relying on the quoted line numbers.

## Boundary evidence (exact anchors)

1. **Chousa owns the method.** `chousa-shokunin/PROVINCE.md:3-8` lists question framing, source hierarchy, citation chaining, claim-vs-source verification and search-strategy taxonomy. Lines 10-15 route secret values to kagi ("→ kagi for custody; shape-only here").
2. **The fleet contract already separates application from method.** `CORPUS.md:119-122`, rule 3 "No second method": admission stays in each lane's `corpus/QUALITY.md`, and the research method stays chousa's. `CORPUS.md:115-117`, rule 2: only `status`/`recheck`/`used-by` change in place, and a correction is a new row whose `teaches` opens `supersedes S0NN —`. `CORPUS.md:105-106` defines the `recheck` tokens (`90d`, `180d`, `on-release`).
   - Plan alignment: `plans/round-26.md:5` says changed immutable facts "receive new superseding rows". That is exactly rule 2. Updating the S027/S028 anchor text in place would breach rule 2.
3. **Kagi's self-declaration matches.** `kagi-shokunin/PROVINCE.md:67`: "chousa owns the research method (`SOURCES.md` restates neither method nor admission bar)". `PROVINCE.md:80-82`: kagi's fixtures "do not absorb research method".
   - Kagi's `corpus/QUALITY.md:1` ("kagi's admission bar") is not a contradiction. Rule 3 places admission in the lane's own `QUALITY.md`.
4. **Per-lane freshness tooling is an established fleet pattern, not method ownership.**
   - Kake: `kake-shokunin/PROVINCE.md:17` owns `scripts/freshness-sweep.mjs` while lines 32-33 defer "research method and source hierarchy" to chousa.
   - Souji: `souji-shokunin/PROVINCE.md:82-83`, "souji's `corpus/SOURCES.md` applies it and does not restate it".
   - Kagi's `corpus/release-clock.py` (SKILL.md:48, 787; `corpus/release-clocks.tsv:24-25` for S027/S028 → feed S036) is the same pattern.
5. **Chousa's new round-26 recheck semantics are adjacent to kagi's clock, and compatible with it.** In `chousa-shokunin/corpus/knowledge/recheck-due-r26.md:22-28`, the decision table maps `on-release` to `event; no inferred calendar deadline`. Lines 33-35 say "`event` does not certify that releases were monitored". Lines 39-42 say "A date alone is not the re-verification … Do not change a cadence solely to turn an overdue report green". The same option is described at `chousa-shokunin/SKILL.md:480-481` (`--as-of`, `META_RECHECK_OVERDUE`). Chousa labels this "this lane's policy" (`recheck-due-r26.md:15`), so it is not a fleet rule.
   - Kagi's plan says "No assertion of continuous monitoring … not rewritten to green" (`plans/round-26.md:5`). That agrees with chousa's limits.
6. **Sibling sweep: no competing claim.** `grep -nEi 'release|freshness|python|upstream|package|research|source' */PROVINCE.md` (output observed above) found:
   - Mori's "freshness" is watchdog/log liveness, not source currency.
   - Tsukuroi owns host package state (`tsukuroi-shokunin/PROVINCE.md:4,27`). It is relevant only if C1 claimed an installed-Python upgrade, which the plan already excludes.
   - Kumitate's `sources-check.mjs` is its own lane gate (`tameshi-shokunin/PROVINCE.md:76-80`).
   - No sibling claims kagi's S027/S028 rows, `release-clock.py`, or Python-docs source maintenance.

## Counterexamples (actionable)

**CE1: source IDs collide across lanes.** Running `awk` over both `corpus/SOURCES.md` files shows the same IDs naming different sources:

| ID | kagi | chousa |
|---|---|---|
| S036 | Python downloads RSS feed (kagi `SOURCES.md:42`) | registry-link contract (chousa `SOURCES.md:46`) |
| S037 | curl info | Cochrane LSR guidance |
| S038 | WHATWG empty feed, rejected (kagi `SOURCES.md:45`) | **Python datetime docs, "Python3.15.0 documentation served 2026-10-21", `on-release`, mined** (chousa `SOURCES.md:48`) |

IDs are lane-local by contract, so this is not a defect. However, a C1 receipt or a fleet-visible report that says "S036" or "S038 Python 3.15.0" without a lane qualifier is ambiguous, because the chousa S038 row really is a Python 3.15.0 documentation row. **Action:** the C1 receipt should cite `kagi-shokunin/corpus/SOURCES.md` S027/S028/S036 by lane and path, not bare IDs.

**CE2: the same drift touches a chousa row, and kagi must not absorb it.** Chousa S038 (`chousa-shokunin/corpus/SOURCES.md:48`, used by `corpus/knowledge/recheck-due-r26.md:1`) anchors on Python 3.15.0 docs with `recheck: on-release`.
- [INFERENCE] If the routed Python 3.15.1 drift is real, chousa's row faces the same on-release event. Chousa has no feed binding, and by its own table (`recheck-due-r26.md:26`) it would only ever report `event`.
- I did not fetch the feed; this seat does not confirm the drift.
- **Action:** kagi's C1 MUST NOT re-verify, supersede, or comment on chousa S038 in kagi production. L1 MAY carry a one-line cross-lane pointer to the orchestrator, as kagi `PROVINCE.md:67` says ("report, don't absorb").

**CE3: two instruments with different verdict words.** A kagi clock moving `not-fired → fired` (or a new receipt) and chousa's `verify-metadata --as-of` reporting `freshness=event` for the same `on-release` token are not in contradiction. They are different instruments:
- Kagi's clock answers "did a release happen?"
- Chousa's screen answers "can a deadline be computed?"

**Action:** C1 text must not cite chousa's gate as confirming kagi freshness, and must not describe `fired` as "freshness current". This screen is also unreachable for S027/S028 anyway: they are used only by `corpus/lessons/round-24.md` and are cited by no kagi `corpus/knowledge/*.md` entry (Grep count S027/S028: `SKILL.md` 1, `lessons/round-24.md` 3, `lessons/round-25.md` 2, `knowledge/` 0). So chousa's QUALITY6 header screen (`chousa-shokunin/corpus/QUALITY.md:17-23`) never covers them.

**Exit-lane conditions.** C1 leaves kagi's lane if it does any of the following:
- defines fleet-wide `on-release` or due-date semantics;
- edits or claims chousa S038;
- asserts an installed-Python upgrade (that is tsukuroi's host package state);
- writes a general recheck-method note into kagi `knowledge/` instead of citing chousa.

**PROVINCE freshness note (no C1 edit needed).** Kagi `PROVINCE.md:67`'s round-21 sweep predates chousa's round-25/26 recheck screens (`SKILL.md:76`, `:480-481`). The adjacency declaration is still true but does not record the `event`-versus-`fired` distinction. Recording that belongs in the round-26 lesson or receipt, not a PROVINCE rewrite: the plan claims no new coverage surface.

## Proposed move (one, bounded)

The C1 receipt or lesson carries a three-line **adjacency block**:
1. Lane-qualified source identities (`kagi corpus/SOURCES.md S027/S028 ← S036 feed`), which closes CE1.
2. "Chousa `SOURCES.md` S038 shares the Python 3.15.x docs anchor; reported to the orchestrator, not re-verified here", which closes CE2.
3. "Clock `fired` ≠ chousa `freshness`; re-verification is reopened anchor plus compared quote, per chousa `recheck-due-r26.md:39-42`", which closes CE3 and cites the method instead of restating it.

Effect on axes:
- **Calibration improves:** no ambiguous IDs, no implied cross-lane confirmation, no absorbed sibling row.
- **Freshness is unharmed:** no clock, receipt or row semantics change, and the round-25 receipt and the INCOMPLETE/48 lone-clone result are untouched.

Risks:
- Chousa's round 26 is uncommitted in its `.ufo/` and lessons, so its anchors may move. Re-check the pinned digests first.
- CE2 depends on the routed 3.15.1 drift, which is unverified here.
- The block adds prose to a receipt; keep it to a pointer, not a restatement of chousa's table.

## Verification

Exercised (outputs observed in this seat):
- `git rev-parse HEAD` for kagi, chousa and the fleet root, plus `git status --porcelain` for kagi and the cited chousa files;
- `git diff --quiet 1bf3eec -- …` for kagi, which exited 0;
- `sha256sum` of the cited files;
- the `awk` ID extraction over both `SOURCES.md` files;
- the province `grep` sweep;
- the Grep count of S027/S028 citations.

Not run, and not claimed as passing: `corpus/release-clock.py` (offline or `--observe`), any `--selftest`, chousa `research-gate.sh verify-metadata --as-of/--registry`, `sources-census.sh`, `claim-ledger.sh`. L1 should run after integration: `python3 corpus/release-clock.py`, `bash corpus/sources-census.sh`, and `bash corpus/claim-ledger.sh citations`, expecting the honest lone-clone `INCOMPLETE` exit 3.

Inspected scope: kagi `plans/round-26.md`, `PROVINCE.md`, `SKILL.md` (grep), `corpus/SOURCES.md:1-79`, `corpus/release-clocks.tsv`, `corpus/release-clock.py` (grep), `corpus/knowledge/` headers; chousa `PROVINCE.md`, `SKILL.md:60-99,470-498`, `corpus/QUALITY.md:1-35`, `corpus/SOURCES.md` (grep), `corpus/knowledge/recheck-due-r26.md`; fleet `CORPUS.md:60-134`; kake `PROVINCE.md:10-44`; souji `PROVINCE.md:80-84`; the grep sweep of all 21 `*/PROVINCE.md`.

Tooling installs: none.
