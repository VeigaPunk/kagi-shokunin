# CritC1AppendOnly — round 27 BUILD critic (C1 calibration)

Seat: `KagiR26.CritC1AppendOnly-17`. Lane-authored advice only; no judgment, no closure, no SHONEN mark.
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b` (lane); fleet root `CORPUS.md` read at fleet HEAD `7f48c5ed`, clean (`git status --short CORPUS.md` empty).
`plans/round-27.md`, `corpus/lessons/round-27.md`, `.ufo/waves/round-27/knowledge-migrations.json`, QM25/QM26 and the knowledge/self-counts edits are **not in BASE** (`git show BASE:plans/round-27.md` → "exists on disk, but not in"). Those are cited as working tree (`wt:`) as observed 2026-10-21 ~15:15 UTC. Every other `path:line` is at BASE.

Axes: **calibration** (primary), freshness (only where the history clause dates a value).

## Verdict

The attack named in the assignment, that in-place correction breaks CORPUS.md's "corrections are new entries", is an **overclaim. I reject it.** The defect is in the *content* of the in-place correction: one history clause gives a false date, and one current value is already stale under L1's own binder. Both are fixable before the commit. Once the round-27 lesson is committed, the lesson's copy becomes append-only and could only be fixed by an erratum.

## Attack 1 (primary): the "round-10 output" history clause is false provenance

Claim (wt `corpus/knowledge/claim-ledger.md:301-304`): "round-10 output read claims=17 stamped=33 ids=17 cited=17 labeled_ids=13 orphans=0", "round-10 output read cites=700 docs=43 …", "round-10 output read cells=60 …", "SELFTEST: PASS (170 cases); 72 at round 10".

Counterexample evidence:
- `corpus/claim-ledger.sh` and `corpus/knowledge/claim-ledger.md` were both created in `301b9ec` ("round-11: … claim ledger"), per `git log --diff-filter=A`. BASE `corpus/knowledge/claim-ledger.md:3` says "written 2026-09-28 (round 11)". **No round-10 output of this gate can exist.**
- `git log -S'claims=17 stamped=33'`, `-S'cites=700 docs=43'`, `-S'cells=60 row_pointed=25'` and `-S'# 72 scratch cases'` all first land in `4b8c018` ("round-13: calibration axis-move"). In `4b8c018^` the same block read `claims=11 stamped=28`, `cites≈505 docs=39`, `39 scratch cases`, and had no `cells` line at all.
- BASE `corpus/knowledge/claim-ledger.md:6-7` corroborates this inside the same entry: "14 at round-12 close, 17 at round-13 close".
- The false date is repeated in wt `.ufo/waves/round-27/knowledge-migrations.json:4` ("unbindable round-10 outputs labelled") and wt `corpus/lessons/round-27.md:53-55`. Draft QM26 (wt `corpus/QUALITY.md:133`) turns the practice into a rule: "labelled with its round".

Why it matters:
- QM21 (BASE `corpus/QUALITY.md:118`) makes the history clause the *only* thing that moves a number out of current tense, so that clause is itself a claim. Here it is a false one.
- No gate notices. The `KN-LEDGER-REPRO-*` rows (wt `corpus/self-counts.tsv:68-70`) capture only the current half (`claims=([0-9]+)`, `stamped=([0-9]+)`, `# ([0-9]+) scratch cases`). Mutating "round-10" to "round-9", or "72" to "73", stays CLEAN. The plan's promise that "a one-digit knowledge mutation turns the binder STALE" (wt `plans/round-27.md:19-20`) does **not** cover history-clause digits. [INFERENCE from the regexes; binder not run.]
- The contrast: wt `op-ref-consumption.md:276` ("29 when §9 was written") and wt `surface-census.md:32` ("19 when this entry was written") are true. The op-ref §9 line has said 29 since its creating commit `4b8c018`, and surface-census has said 19 symbol pins since `03477c0`, the commit that created it. The relative wording would be **false** for claim-ledger.md, because that block said claims=11 when it was written.

Smallest safe correction: in all four lines, replace "round-10 output read" with "round-13 output read" and "72 at round 10" with "72 at round 13". Make the same replacement in `knowledge-migrations.json` "reason" and in `lessons/round-27.md:53-55`. Reproduce with `git log --format='%h %s' -S'<old string>' 0a47dd18 -- corpus/knowledge/claim-ledger.md`, and record that command in the migration record as the observed check (see finding 4 below).

## Attack 2 (concrete, checkable): `stamped=89` is stale on the after-docs

- wt `corpus/knowledge/claim-ledger.md:301` states the current `stamped=89`.
- Binding wt `corpus/self-counts.tsv:69` `KN-LEDGER-REPRO-STAMPS` is `ledger:R12-03`. `corpus/self-counts.py:11` (unchanged from BASE): "ledger:<ID> executes that row's command, not its pinned expected number".
- The R12-03 pin was migrated from `^89$` to `^90$` in wt `.ufo/waves/round-27/expectation-migrations.json` (`stamp_membership` 89→90, adding `corpus/lessons/round-27.md`). wt `corpus/claim-ledger.tsv` R12-03 now reads `^90$`.
- Counting the non-blank rows of wt `corpus/stamps.tsv` gives 90. This is R12-03's own `grep -c`, a read-only count, run once and disclosed here.
- Result: on the after-docs the binder should report `STALE … claimed=89`. That breaks the plan's acceptance condition "on after docs (stale0, exit0)" (wt `plans/round-27.md:20-21`). The lesson copy (wt `lessons/round-27.md:51`, "stamped 33→89") and `knowledge-migrations.json` "new" carry the same 89. [INFERENCE: binder not run; L1 runs final checks.]

Structural point: R12-03 grows by one every round, because each round stamps its new lesson. Binding that count inside a *knowledge* entry therefore forces an in-place rewrite of `claim-ledger.md` every round, purely for bookkeeping. That is the real tension with append-only discipline, and the C1 design creates it.

Smallest safe correction: change 89 to 90 in the doc, the lesson and the migration record. Better, and still minimal: for counts that change every round (`claims=`, `stamped=`), write the symbolic form the entry already uses at `corpus/knowledge/claim-ledger.md:47` (`claims=N stamped=M`), point to R21-04/R12-03, keep "round-13 output read 17/33" as history, and drop `KN-LEDGER-REPRO-CLAIMS`/`-STAMPS`. Keep `KN-LEDGER-REPRO-SELFTEST` (170 changes only when cases are added).

## Rejected overclaim: "in-place correction violates CORPUS.md / QM14"

- The operative text of `CORPUS.md:53-60` binds the **aggregator**: it "does not edit lane-authored corpus files in place", motivated by the round-1 lesson collision. It does not forbid a lane correcting its own knowledge entry.
- `CORPUS.md:116-118` (append-only, `supersedes S0NN —`) is the SOURCES **registry** rule only. `corpus/QUALITY.md:8-10` makes **criteria** append-only, not knowledge.
- QM21 (`corpus/QUALITY.md:118`) *requires* "a newer value beside it", which is necessarily an in-place edit. The lane already has precedent: `corpus/knowledge/claim-ledger.md:364` ("six commands … — "five" until the round-25 count correction").
- QM14 (`corpus/QUALITY.md:73`) covers revision-pin and expectation changes. Its requirement is satisfied in form by `knowledge-migrations.json` (old/new text) plus `expectation-migrations.json`.

So the minimal honest correction form is **in place, with the old value beside the new one, a true date for the old value, and an in-entry marker naming the correcting round**. It is not "a new entry" in place of the edit.

## Secondary findings (smaller)

1. **QM26 quietly loosens QM21.** QM21 says "A 'round N' tag does not make a number historical". Draft QM26 (wt `QUALITY.md:133`) lets "an unbindable stale output [be] labelled with its round", and wt `claim-ledger.md:302-303` does exactly that, with `(…)` where a newer value should stand. `QUALITY.md:8` says a superseding criterion must name the row it replaces, but QM26 only says "Supplements QM21". Fix: QM26 names the QM21 clause it narrows (unbindable outputs), or the lines say "round-13 output; not re-measured, fleet-layout dependent, unbound".
2. **Positional index rewritten, old value dropped.** wt `claim-ledger.md:81` replaces "case 16" with "case `verdict-not-final`" and leaves no beside-value. Yet wt `self-counts.tsv` (header comment) and QM26 say positional case indexes are excluded by rule, and `surface-census.md:226` is left as named debt. "16" was true when written: `verdict-not-final` is the 16th `tcase` at `301b9ec:corpus/claim-ledger.sh:513` and the 27th at BASE `corpus/claim-ledger.sh:1610`, matching round-25's "case 16 vs 27". Fix: keep the name and add "(16th case when written, round 11)", or leave as written and list it as debt beside `surface-census.md:226`. Low severity: the name is more durable.
3. **The correction is only discoverable in one of the three entries.** op-ref gets an appended Erratum (wt `op-ref-consumption.md:388-396`). claim-ledger.md and surface-census.md get only inline edits that name no correcting round, although surface-census.md already has an Erratum section (BASE `:290`). Fix: inline "(round-27 correction)", following the `:364` precedent. No new section is needed.
4. **QM14's "observed checks" is missing from the migration record.** `knowledge-migrations.json` has format/base/reason/changes but no command or verdict backing 65/89/170/36/20, and no binding ids. Fix: add per-change `bound_by` (KN-* id) and the observed binder or pickaxe check once L1 runs it. Restamping of the three knowledge files is recorded only as membership (89→90). That matches round-26's convention (`stamp_membership` only); round-22 recorded `changed_stamp_records`. Old hashes can be recovered from BASE. I classify this as a tradeoff, not a defect.

## What I did NOT check (unrun ≠ pass)

- I did not run `self-counts.py`, `claim-ledger.sh` (any mode), any selftest, or the plan's overlay counting command. Attack 2's STALE is inferred from the binder's documented semantics plus the pin and count.
- I did not verify the other 15 `KN-*` rows' regexes or locations, or whether the excluded-candidate list in `lessons/round-27.md` is complete.
- I checked nothing on C2 (release-clock REGRESSED).
- I did not re-verify the live values 65/170/36/20; I read pins only (R21-04 `^65$`, R11-09 `170`, R12-02 `36`).
- I did not check whether other knowledge entries carry history clauses with similar misdating; only the three edited entries were audited.

## Process disclosures

- Writes: this report only. One scratch diff was written to `/tmp/critc1ao-diff.txt` and deleted in the same session. That was outside the allowed write set, and I disclose it here.
- Executed: read-only `git show/log/diff/status`, `rg`, `python3 -c` JSON reads, and the single `grep -c` noted under Attack 2.
- Tools installed or updated: none.
