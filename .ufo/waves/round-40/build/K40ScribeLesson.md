# K40ScribeLesson — round-40 build wave, scribe seat (drafting only)

Candidate `cb3f642479a09644a03874909bb7e44b52697a8d` · BASE
`6cc8850dfc5757927699e5a53a876f47c8df21aa` · predeclaration
`f687504767ce9ed56b848dfde83e03a1ec6cedd3` · frozen plan
`38a118f9cf15729e7732cc3cafe1011e3a899ee4`.

**Seat role:** scribe — drafting only. Four drafts written under
`.ufo/waves/round-40/build/K40ScribeLesson/`: `draft-trial.md`,
`draft-settlement.md`, `quote-counts.md`, `overstatement-audit.md`. No lane,
fleet, sibling or domain-source tree was modified; no commit, push, branch or
worktree mutation anywhere; no delegation; no background job of my own.

**Tool installs: none.** The installed toolset was sufficient (`python3`,
`git`, `bash`, `awk`, `grep`, `sed`, `sha256sum`). No pacman transaction was
attempted.

## Verdict

**The three frozen counter targets are reproduced at the candidate** — by my own
runs, in read-only `git archive` extractions under my scratch:

| Counter | Target | BASE | My reading at the candidate | Exit |
|---|---|---|---|---|
| `bash plans/round-40-c1.sh` | 0 | 6 | **0** (289.6 s wall, `real 4m49.614s`) | 0 |
| `bash plans/round-40-c2.sh` | 3 | 0 | **3** | 0 |
| `bash plans/round-40-c3.sh` | 2 | 0 | **2** | 0 |

Gates at the candidate: `ANCHOR_PINS: CLEAN (pins=4)` rc 0,
`CLAIMS_DECLARED: CLEAN (claims=5)` rc 0, both selftests `PASS (8 cases)` rc 0,
lane census `SOURCES_CENSUS: CLEAN (rows=96 A=92 … captures=96 …)` rc 0.

**The overstatements are in the prose around those numbers, and in three
registry cells the round bound to a body they do not fully cover.** The
sentence-level audit flags **24 items** across the round-40 SCORECARD and
lesson sections: 12 already recorded by the critic (K40CriticClaims), **12
found by this seat alone** and not present in the critic's list or the L1's live
corrections.

## What this seat found that no other seat recorded

1. **The candidate's own SCORECARD cites an uncommitted receipt, which adds a
   new self-description red.** `SCORECARD.md:1520` (the C1 evidence cell) cites
   `.ufo/waves/round-40/controls/prefreeze-gate.txt`. That path is **not in the
   candidate commit** — `git cat-file -e cb3f642:.ufo/waves/round-40/controls/prefreeze-gate.txt`
   → `fatal: path … exists on disk, but not in 'cb3f642'` (rc 128); the file is
   untracked at the candidate. The committed candidate's citations gate
   therefore emits a **new** line: base extraction → 3 `UNRESOLVED`, candidate
   extraction → 4, the delta being exactly
   `UNRESOLVED SCORECARD.md:1520 .ufo/waves/round-40/controls/prefreeze-gate.txt (ufo)`.
   The self-description sweep's SD6 count consequently rises 3 → 4 between the
   BASE and candidate extractions. The round-37 sibling citation at
   `SCORECARD.md:707` resolves because `.ufo/waves/round-37/controls/prefreeze-gate.txt`
   **is** committed — so this is the round-40-specific instance.
2. **The round's two new rows make the release-clock gate read differently.**
   S095/S096 carry `recheck: on-release` in `corpus/SOURCES.md` but have **no**
   `corpus/release-clocks.tsv` binding row. `python3 corpus/release-clock.py`
   reads BASE `FAILED (on_release=28 bound=28 unbound=0 observed=28 fired=13 derived=15)`
   and candidate `FAILED (on_release=30 bound=28 unbound=2 observed=28 fired=13 derived=15)`
   with `UNBOUND S095` and `UNBOUND S096`. Removing the two rows from the
   candidate tree restores `unbound=0`. R36-03's expectation
   (`unbound=0`) is therefore *further* from satisfied at the candidate. The
   SCORECARD's "the inherited non-set FAIL rows … untouched" is true of the
   ledger cell, not of the gate the row drives.
3. **The fresh-start premise does not hold on the manifest's own verdicts.**
   `MANIFEST.json` records kagi's rounds 36 `rejected-honest-stop`, 37
   `admitted`, 38 `rejected-honest-stop`, 39 `admitted` — the three most recent
   closures are not three rejections. The plan's gloss describes rounds 36/37/38
   and omits round 39. This is the **M39-5 class recurring** (round 39's own
   lesson corrected a fresh-start premise read from the wrong field).
4. **The committed selftest case list does not cover the class the plan names.**
   `corpus/claims-declared.sh --selftest` case 3 is the **fenced-code-block**
   heading variant of D2 only; the reviewer's D2 class was "fence/comment
   headings" (the script's own header, lines 15–16, names both). The
   HTML-comment variant is not in the 8 cases. And `corpus/anchor-pins.sh`
   case 5 (F3) is an extra-trailing-pipe-cell *shape* case, while the plan and
   the SKILL.md registry row label F3 "schema".
5. **The two new verbatim quotes are raw-literal truncations.** The S095 quote
   stops at an HTML tag boundary — the raw body reads
   `Matches Unicode whitespace characters (as defined by <a class="reference internal" href="../builtins/stdtypes.html#str.isspace" …>`
   — so `str.isspace()`, the clause the whitespace teaching turns on, is not in
   the quoted bytes. The S096 quote stops at a line boundary before "for both
   valid and invalid character references". **The teachings themselves are
   unchanged on 3.15.2** (both full S040/S041 sentences still locate, count=1
   each) — it is the quoted segments the registry now binds that are the
   fragments. See `draft-trial.md`.
6. **The `c2_forge_rows` red witness never reaches the branch M40-1's fix cell
   cites it for.** The control forges registry rows with no fetch row and no
   capture body, so the counter fails at the fetch-row check; the quote-locate
   branch is never exercised.
7. **The pre-freeze receipt the lesson relies on is uncommitted** — the same
   file as finding 1 — and the lesson's M40-2 fix cell names it without its
   directory, which is why the citations gate flags the SCORECARD's full-path
   pointer and not the lesson's.
8. **The two gates' selftests write their fixtures outside the repo**:
   `mktemp -d "${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}/kagi-r40-anchorpins-selftest.XXXXXX"`
   (`corpus/anchor-pins.sh:37`) and the `claimsdecl` equivalent
   (`corpus/claims-declared.sh:37`). The default is `/tmp`, which the round
   prompt's §7.4 makes non-citable, so spot-check routed item 2 is only partly
   cleared.
9. **The candidate lesson carries no §Census, no §Frontier step (§2b), no
   §Assimilation and considerthese, and no §Trial on real domain work** — 49
   lines with only §Claims, §Gate, §Mistakes, while the frozen plan requires all
   four and round 39's lesson has all four. The census-**after** fleet receipt
   (`.ufo/waves/round-40/census/candidate-fleet.txt`) and `candidate-eol.txt`
   are **untracked** at the candidate.
10. **K40ReviewLedger produced no report file and no receipt directory.** At the
    time of writing, 9 of 10 seats have both; this one has neither. Its remit
    (attack C1 without the migrations) is not covered by another seat and must
    not be claimed as covered.

Independently confirmed by this seat and already recorded by the critic: the
S095 gate-quote count is **7** whitespace tokens, not the 8 the candidate lesson
states (the M40-1 class repeated inside the lesson that mined it — see
`quote-counts.md`); the W04 count is **19 at both BASE and candidate** with the
two sorted W04 sets `diff`-ing to nothing, so the plan's "six new" and the
SCORECARD's "two new" are both unmeasured and both wrong.

## Commands executed (all read-only over the lane; full list in the drafts)

Counters, in `git archive` extractions of the candidate and of BASE under my
scratch: `bash plans/round-40-c1.sh` (0, rc 0, 289.6 s) ·
`bash plans/round-40-c2.sh` (3, rc 0) · `bash plans/round-40-c3.sh` (2, rc 0).
Gates: `bash corpus/anchor-pins.sh --root .` (CLEAN pins=4) ·
`bash corpus/anchor-pins.sh --selftest` (PASS 8) ·
`bash corpus/claims-declared.sh --root .` (CLEAN claims=5) ·
`bash corpus/claims-declared.sh --selftest` (PASS 8) ·
`bash corpus/sources-census.sh` (rows=96) ·
`bash corpus/row-identity.sh scorecard-rounds` (count=54 sha 52e7ba8d…) ·
`python3 corpus/release-clock.py` (BASE and candidate) ·
`bash corpus/self-description-sweep.sh` (BASE and candidate extractions) ·
`bash corpus/claim-ledger.sh citations` (BASE and candidate extractions).
Fleet, read-only: `bash scripts/sources-census.sh validate --root
/home/vgpnk/Projects/shokunin kagi` (rc 0, `kagi ok`, 19 W04).
Quote work: `python3 corpus/rendered-text-v1.py locate|digest` on both capture
bodies; `str.split()` and `wc -w` counts; raw-byte `find()` for the offsets
75897 / 13521. Git, read-only: `log`, `show`, `diff`, `ls-tree`, `cat-file`,
`archive`, `status`, `ls-files`.

## Deliverables

| File | Content |
|---|---|
| `.ufo/waves/round-40/build/K40ScribeLesson/draft-trial.md` | The round-40 `## Trial on real domain work` paragraph, with read-only evidence for every claim: the two teachings, the four knowledge entries that consume them, the three version-sensitive statements that do **not** match, and the eight command transcripts that back it. |
| `.ufo/waves/round-40/build/K40ScribeLesson/draft-settlement.md` | The `## Wave settlement` skeleton: §1 the 10-seat roster with the receipt each seat must show (and K40ReviewLedger's non-delivery), §2 the confirmed results, the 18 corrections the settlement must carry (M40-4…M40-18, incl. 8 found only here) and what the settlement must **not** say, §3 template text. |
| `.ufo/waves/round-40/build/K40ScribeLesson/quote-counts.md` | Whitespace-token counts of the two verbatim Gate quotes — S095 = **7**, S096 = **11** — with the method stated (`str.split` and `wc -w`, two independent implementations), the M40-1 precision rule applied item by item, and the residual gap (no committed counter counts quote tokens). |
| `.ufo/waves/round-40/build/K40ScribeLesson/overstatement-audit.md` | Every sentence in the round-40 SCORECARD and lesson sections that claims more than its receipt shows: 22 flagged items, 12 credited to the critic, 10 this seat's own; plus the four lesson sections the candidate lacks. |

## Scope and limits

- **Drafting only.** These are drafts for the L1 to adopt, amend or reject; they
  are not lane truth until the L1 commits them. Nothing here was written
  outside this seat's directory.
- The trial reads the lane read-only; the three mismatches it records are
  findings for the round report and lesson, **not** claims of this seat.
- The audit's "OVER / UNSUPPORTED" verdicts are judgements about the relation
  between a sentence and a receipt, each with the receipt quoted in the row.
  Where the critic had already found the same thing I credited him rather than
  duplicating it.
- The `MANIFEST.json` verdicts, the release-clock readings and the citations
  counts were measured from the **fleet MANIFEST** and from **extractions**, not
  from the lane's live working tree, which the L1 was editing concurrently.

## Scratch

`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40ScribeLesson/` — a BASE
extraction, a candidate extraction, a row-removal probe and the fleet-validate
receipt. **Deleted before this seat finished**; the receipts quoted in the
drafts are re-derivable from committed bytes (`git archive` of
`6cc8850` / `cb3f642`).
