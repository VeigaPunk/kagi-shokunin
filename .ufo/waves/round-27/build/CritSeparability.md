# CritSeparability — round 27 build, C1 × C2 causal separability

Seat: KagiR26.CritSeparability-17 (critic, read-only, no gate executed).
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. Lane HEAD observed = BASE;
L1's integration was uncommitted in the working tree (WT) and changed while
I read (`corpus/claim-ledger.tsv` and `corpus/stamps.tsv` went from unmodified
to migrated mid-review). WT line numbers are labelled "WT" and are a snapshot
from 2026-10-21 ~12:16 local; BASE line numbers come from `git show BASE:`.
Axes: calibration, freshness. No tools were installed or updated.

## Verdict

The overclaim is rejected. C1 and C2 are **not** file-disjoint, and they are
not causally separable at the layer the plan measures. One concrete
counterexample is live in the WT now (CE1). One C2→C1 causal edge is
structural (CE2). The plan's separation mechanism ("executed claim-only
overlays") has no artifact (CE3).

## CE1 (live in WT): the round's joint stamp bump left a new C1 binding stale

- C1 adds `KN-LEDGER-REPRO-STAMPS` (WT `corpus/self-counts.tsv:69`). It binds
  the `stamped=N` number in `corpus/knowledge/claim-ledger.md` to
  `ledger:R12-03`.
- WT `corpus/knowledge/claim-ledger.md:301` reads
  `CLAIM_LEDGER: CLEAN (claims=65 … stamped=89 …; round-10 output read …)`.
  The lazy locator `^bash corpus/claim-ledger\.sh verify .*? stamped=([0-9]+)`
  captures the first ` stamped=`, which is **89**.
- Joint round bookkeeping (not C1, not C2) added the stamp for
  `corpus/lessons/round-27.md` and migrated R12-03 `^89$` → `^90$`. The old
  value is at BASE `corpus/claim-ledger.tsv:28`; the new one is in WT
  `corpus/claim-ledger.tsv:28` and in `.ufo/waves/round-27/expectation-migrations.json`
  under `stamp_membership` 89→90. A non-blank line count of WT
  `corpus/stamps.tsv` gives 90. This was a plain `grep -c` on the file, the
  same expression as R12-03; the ledger row itself was not run.
- The same bump was applied to the three older bindings of this quantity:
  WT `SKILL.md:46` "(90 stamps", WT `PROVINCE.md:52` "(90 revision stamps",
  and WT `corpus/README.md:65` "90 rows". Those are SC-SKILL-STAMPS,
  PV-STAMPS and RD-STAMPS (BASE `corpus/self-counts.tsv:15,34,47`). The new
  knowledge binding was missed.
- Predicted outcome [INFERENCE, not executed]:
  `STALE KN-LEDGER-REPRO-STAMPS corpus/knowledge/claim-ledger.md:301 claimed=89 live=90`
  then `SELF_COUNTS: STALE (claims=56 stale=1 …)`, exit 1 (BASE
  `corpus/self-counts.py:357-372`). R25-02 (WT `corpus/claim-ledger.tsv:81`,
  expecting `CLEAN (claims=56 stale=0)`) then FAILs. C1's after-arm counting
  command (`plans/round-27.md:20-21`, "after docs (stale0, exit0)") fails for a
  cause owned by neither claim.
- Structural point: this binding ties a knowledge entry to stamp membership,
  which grows by one lesson stamp every round (R12-03 note: 63→…→88→89→90). So
  `corpus/knowledge/claim-ledger.md` becomes per-round bookkeeping. The binder
  will catch the drift correctly, but every future round has to edit and
  re-stamp that entry.
- Smallest safe correction: change `:301` to `stamped=90 …` with a history
  clause ("89 at round 26"), matching QM21/QM26. The alternative is to restate
  the line as `(…)`, the way `:302-303` already treat cites and cells, and
  retire KN-LEDGER-REPRO-STAMPS, since SKILL/PROVINCE/README already bind the
  same quantity. That alternative is a population decision for L1. It is not
  "dropping a binding to go green" only if the number leaves the text as well.
  `KN-LEDGER-REPRO-CLAIMS` (`ledger:R21-04`, 65) has the same latent coupling
  to any round that adds ledger rows; it is currently consistent (WT count 65).

## CE2 (structural): C2 failures surface as C1 calibration failures

- Path, BASE `corpus/self-counts.tsv:22` (SC-CLOCK-SELFTEST, SKILL.md) and
  `:38` (PV-CLOCK-SELFTEST, PROVINCE.md): both use source `ledger:R25-03`,
  which is `python3 corpus/release-clock.py --selftest` (BASE
  `corpus/claim-ledger.tsv:82`).
- `self-counts.py` executes that row live and requires the ledger's expected
  exit code; it ignores the expect regex (BASE `corpus/self-counts.py:11-14`,
  `:298-299`). A failing release-clock selftest therefore becomes SETUP on both
  rows (`:351`, `:361`), and the whole run ends `SELF_COUNTS: SETUP` exit 2
  (`:363-368`).
- Mutation counterexamples [INFERENCE from a static path trace, not executed]:
  - (a) Any C2 selftest case that regresses makes R25-03 FAIL **and** R25-02
    FAIL (exit 2). Two red ledger rows result from one freshness cause, and one
    of them is labelled as C1 calibration.
  - (b) If C2 adds a case without editing WT `SKILL.md:48` / `PROVINCE.md:54`
    (73), R25-03 FAILs on its pin and R25-02 FAILs with stale=2.
  - (c) After docs (73) paired with BASE `release-clock.py` (67) gives stale=2,
    exit 1. C1's "after: stale0 exit0" is therefore a joint C1∧C2 receipt. Two
    of its 56 OK lines are C2 facts.
- What does hold:
  - The **BASE arm** is C2-free. `tools/c1-measure.py:41-44` clones the whole
    DOCS_REV and overlays only `corpus/self-counts.tsv`, so DOCS_REV=BASE runs
    BASE `release-clock.py` (67) against BASE docs (67).
  - No KN-* row sources R25-03 or R25-04. The KN sources are R16-02, R16-03,
    R15-02, R15-04, R21-04, R12-03, R11-09, R12-02 and `rows:`
    (WT `corpus/self-counts.tsv:58-75`).
  - No knowledge entry mentions `release-clock` at BASE (`git grep` over
    `corpus/knowledge/*.md` returned nothing).
  - C2 does not change release-clock's argparse surface (WT
    `corpus/release-clock.py:1627-1631`: --root/--selftest/--observe/--receipt/--receipt-sha),
    so the observe-prefix refusal (BASE `corpus/self-counts.py:160-168`) is
    unaffected.
  - In the other direction, C1 edits cannot reach C2's instrument: it clones a
    whole REV and runs only `release-clock.py` against the clock tables and
    receipts (`tools/c2-measure.py:42-77`) [INFERENCE, not executed].
- Smallest safe correction (wording plus acceptance, no code): state C1's
  acceptance on `c1-measure`'s `stale_knowledge == []` with no SETUP/POLICY on
  KN-* ids (`tools/c1-measure.py:64-69` already computes `stale_knowledge`),
  rather than on the global exit. Name SC/PV-CLOCK-SELFTEST and R25-02 as a
  declared C2→C1 edge, so that a red R25-02 next to a red R25-03 is read as a
  single freshness cause. `corpus/lessons/round-27.md:95-96` partly does this
  already ("SC/PV clock selftest bindings").

## CE3 (rejected overclaims)

- **`plans/round-27.md:38-40`** says "C1 and C2 touch disjoint production
  files". This is false at the file level, and in places at the hunk level:
  - SKILL.md has one hunk `@@ -46,3` mixing `:46` (joint stamps 90), `:47` (C1
    wording) and `:48` (C2 73 + REGRESSED).
  - PROVINCE.md has one hunk `@@ -52,3` with the same three-way mix
    (`:52/:53/:54`).
  - `corpus/README.md` has one new "Round-27 active contracts" section with a
    C1 bullet and a C2 bullet, plus the joint `:65`.
  - `corpus/QUALITY.md` adds QM25 (C2) and QM26 (C1) in one table.
  - `corpus/claim-ledger.tsv`: R25-02 (C1), R25-03 and R21-02 (C2), and
    R12-03/R24-05/R22-03/R24-15/R13-01/R24-06 (joint).
  - `corpus/stamps.tsv` has one hash per mixed file.
  - `corpus/lessons/round-27.md`, `LOG.md` and `SCORECARD.md` are also shared.
- **`plans/round-27.md:40-41` and `corpus/lessons/round-27.md:95-97`** say
  "separated by executed claim-only overlays, not asserted". No claim-only
  overlay artifact exists under `.ufo/waves/round-27/`. The directory listing
  shows `c2-before.json`, `expectation-migrations.json`,
  `knowledge-migrations.json`, `tools/{c1,c2}-measure.py` and sandboxes, and no
  C1-only or C2-only receipt. Neither instrument can build one: both take
  40-hex revisions (`tools/c1-measure.py:32-33`; c2-measure clones REV), and no
  C1-only or C2-only commit exists.
- These overlays also cannot be executed through `claim-ledger.sh verify`
  without a per-overlay re-stamp. Every mixed file's single hash in WT
  `corpus/stamps.tsv` is wrong for a half-applied tree, so a verify-level
  claim-only overlay is STALE by construction or requires a reviewed re-stamp,
  which destroys its evidential value. Separability can only be shown at the
  gate layer (self-counts, release-clock), and there it holds except for CE1
  and CE2.
- Correction: either run the gate-layer ablations and cite them, or reword the
  plan and lesson to "file-shared; gate-layer independence argued from source
  bindings (no KN-* row on R25-03/R25-04; C2 instrument reads no
  knowledge/self-counts), with the CE2 edge declared."
- Side observation: `corpus/lessons/round-27.md:86` (M27-2) cites
  `.ufo/waves/round-27/c1-before.json`, and at read time `ls` reported "No
  such file or directory". It would be an unresolved citation if it is not
  produced before final checks.

## Impacted axes

- **Calibration:** CE1 is a live stale knowledge number in the new population.
  CE2 means a red calibration row (R25-02) can be caused by freshness work.
- **Freshness:** CE2 means a C2 regression is double-reported and partly
  misattributed. The C2 counting arm itself (`c2-before.json`, BASE clone) is
  isolated.

## Not checked (unrun ≠ pass)

- I did not run `self-counts.py`, `claim-ledger.sh verify/citations/--selftest`,
  `release-clock.py` (default or `--selftest`), `c1-measure.py` or
  `c2-measure.py`. The CE1 and CE2 outcomes above are predictions from code and
  data.
- I did not count WT release-clock selftest cases. The 73 is taken from WT
  docs and the R25-03 migration, not measured. I also did not check whether the
  67→73 delta is "only the new cases", which needs a case-name diff, not a
  count.
- I did not verify stamp hashes, or that every KN-* locator is unique or
  correct beyond the KN-LEDGER-REPRO rows.
- I did not prove that `claim-ledger.sh --selftest` (R11-09) never executes
  `release-clock.py`. I inferred it from the policy refusal at BASE
  `corpus/claim-ledger.sh:279-281` and the `--observe` fixture at `:1791`.
- I did not read the full knowledge-entry diffs for the other five C1
  corrections.
- The WT was mid-integration, so any WT line may have moved after this
  snapshot.
