# Round 53 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `c1953d4afc19a5a336a58685c00ab5260bcfea1c` (branch `master`; the
round-52 verifier spot-check landed at this tip and admitted round 52).
Counters: `plans/round-53-c1.sh`, `plans/round-53-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-53-controls.sh`
(C1 reference overlay `.ufo/waves/round-53/controls/fixtures/ref/c1/`; C2 reference edit inside the
runner; receipt `.ufo/waves/round-53/controls/controls-prefreeze.txt`). Census at round start:
`.ufo/waves/round-53/controls/census-start.txt` (`kagi ok`, rc 0). Predeclaration commit: recorded in
the report. No earlier attempt of this round exists (`.ufo/watchdog.log`: one launch line for round 53).

## Axes and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation). Capabilities entered in
rounds 49, 51 and 52, inside the window of rounds 50–52, so the nudge does not fire. Every axis is tied
lowest at 9, so each claim works a lowest-scoring non-retired axis. This round works the lane's two
owned axes: C1 freshness, C2 calibration. No axis is retired or split.

Causal separability: C1 changes `corpus/SOURCES.md` (S103/S104 recheck cells, new row S111),
`corpus/source-fetches.tsv`, `corpus/quote-bodies.tsv`, `corpus/release-clocks.tsv`, three lines of
`corpus/release-clock.py` and adds the round-53 receipt and the S111 capture; its counter reads none of
the four statements C2 changes. C2 changes four stated counts in `SKILL.md`, `PROVINCE.md` and
`corpus/README.md`; its counter reads no file C1 changes except through the BASE checker's bindings,
which bind none of C1's lines. Controls: K1-C2ONLY reads C1 = 0, K2-C1ONLY reads C2 = 5, K12 reads
C1 = 2 and C2 = 0.

## C1 — freshness: the lane's two "current stable release" pins are watched by a live release clock, 0 → 2

Problem (measured at BASE): S103 (SOPS v3.13.3 tag page) and S104 (age v1.3.2 tag page) teach that
the tag "is the project's current stable release, pinned as the version an installed sops / age-keygen
must report" (`corpus/lessons/round-48.md`), yet both sit on a fixed `90d` recheck, so a new SOPS or age
release would leave both statements false for up to 90 days with every gate green. The release-clock
gate (`corpus/release-clock.py`) watches only `on-release` rows; neither row is one, and the lane holds
no feed row for age at all (`grep -c 'FiloSottile/age/releases.atom' corpus/SOURCES.md` ⇒ 0).

Source (opened this round, 2026-11-07): https://github.com/FiloSottile/age/releases.atom — HTTP 200,
decoded body 40379 B, sha256 `32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d`,
capture `.ufo/waves/round-53/capture/S111.body`; newest stable entry title `<title>age v1.3.2</title>`
(byte offset 725, count 1); the gate's own feed parser reads `1.3.2`.

Change: S103 and S104 recheck `90d` → `on-release` (old→new logged in the lesson); new registry row S111
(age releases Atom feed, kind `code`, tier A, `mined`, recheck `90d`) with its fetch row and quote-body
row; two clock rows in `corpus/release-clocks.tsv` (S103 → feed S033, anchored 3.13.3; S104 → feed
S111, anchored 1.3.2; both `derived:` from the feed rows' anchors, since the tag-page anchors carry no
version token); a live observation of all 31 clocks at 2026-11-07 written to the new receipt
`.ufo/waves/round-53/final/observe-r53.json` (31 records, 0 failures; verdicts unchanged for the 29 old
clocks: fired 13, as before) and the gate's default receipt moved to it (three lines of
`corpus/release-clock.py`: digest, path, help text). The 29 old clock rows' `observed_at` move
2026-11-06 → 2026-11-07 with an appended note, no verdict changed.

Frozen predicate:
`C1_CURRENCY_CLOCKS: value = number of ids in F that are WATCHED, when GATE = 1, else 0; target 2 (BASE 0).`
F = {S103 (sops feed, pin 3.13.3), S104 (age feed, pin 1.3.2)}. WATCHED: registry row unchanged in URL,
`mined`, `on-release`; exactly one `feed` clock row on the expected feed URL with the pin as anchor; the
feed row is `code`, `mined`, not itself on-release; the default receipt (named by the gate, digest
checked) holds one HTTP-200 observation for the id at the feed URL with parsed version = pin, verdict
`not-fired`, observed on or after 2026-11-07T00:00:00Z and no later than the measured commit. GATE: the
gate differs from BASE only on its three receipt lines and reads `RELEASE_CLOCK: CLEAN`. Details in the
counter header.

Controls (expected values written before the run; `plans/round-53-controls.sh`): K1-0 BASE 0; K1-P
reference 2; K1-F1 recheck flipped without clocks 0; K1-F2 gate replaced by a CLEAN printer 0; K1-F3
default receipt left at round 46 0; K1-F4 S104 anchored to an unreleased 1.3.3 0; K1-F5 S111 left
`queued` 1; K1-F6 S104 half undone 0; K1-F7 S104 bound to the SOPS feed 0; K1-F8 S104 observation
relabelled 2026-11-06 in table, receipt and digest 1; K1-F9 S104 registry URL swapped 1; K1-C2ONLY 0.

Kill rules (any fires ⇒ C1 not admitted): `plans/round-53-c1.sh`, `plans/round-53-c2.sh`,
`plans/round-53-controls.sh`, this plan or the C1 reference overlay differ between the predeclaration
and the candidate; the candidate's `corpus/release-clocks.tsv`, `corpus/release-clock.py` or
`.ufo/waves/round-53/final/observe-r53.json` differ from the reference overlay.

Named ceilings: the counter checks committed bytes; a self-consistent forged receipt whose digest is
written into the gate scores (the non-author live re-fetch of both feeds is the check that catches it);
a clock watches the newest stable tag only — a re-tagged or yanked release, or a SOPS/age behaviour change
inside the same version, is not seen; the installed binaries are not part of this claim (the trials
already compare them with the pins).

## C2 — calibration: the counts the lane's documents state about itself match the live quantities, 5 → 0

Problem (measured at BASE, `bash plans/round-53-c2.sh c1953d4a` ⇒ `value=5`): `python3
corpus/self-counts.py` reads five STALE bindings — `SKILL.md:46` and `PROVINCE.md:73` say 124 revision
stamps (live 125), `corpus/README.md:65` says 124 stamp rows (live 125), `corpus/README.md:67` says 33
row-linked / 36 pinned knowledge entries (live 34 / 37). All five came from the round-52 landing (new
entry pinned and stamped; the ledger expectations R12-03/R14-01 were migrated, the prose was not). The
checker's summary reads `SELF_COUNTS: POLICY (… stale=5 …)`: the two operator-routed POLICY rows set
the verdict word, so a STALE does not show in the summary verdict.

Change: the four statements carry the live numbers, each with a round-53 parenthetical naming the
correction; no binding row, ledger row or tool changes.

Frozen predicate:
`C2_SELF_COUNTS: value = M, the number of claim ids in the BASE binding table that the BASE checker reads STALE, UNLOCATED or AMBIGUOUS on the measured tree, when GUARD = 1, else SETUP; target 0 (BASE 5).`
GUARD: the ledger command (and, for `expect:` sources, expect) cells the table binds equal BASE;
`corpus/claim-ledger.sh` equals BASE; the stamp path population and the knowledge-entry file list equal
BASE; the POLICY findings are exactly the BASE pair. Details in the counter header.

Controls: K2-0 BASE 5; K2-P reference 0; K2-F1 only SKILL.md corrected 4; K2-F2 ledger R12-03 command
forged to `echo 125` SETUP; K2-F3 measured binding table emptied 5; K2-F4 stamp population pruned to
124 SETUP; K2-F5 the five numbers blanked 7 (run 1 wrote 5 and read 7: two of the blanked lines also carry
the SC-SKILL-CLAIMS and RD-DOCS-BYHAND bindings, whose locators need the same number; the expectation was
corrected before the freeze, run 1 kept as `controls-prefreeze-run1.txt`); K2-C1ONLY 5; K12 C1 2 / C2 0.
Run 1 also printed a Python traceback for K1-F2 (a one-line gate file); the counter's receipt reader now
reports `receipt-unnamed` for a gate shorter than 547 lines (value unchanged, 0).

Kill rules: the instruments differ between predeclaration and candidate; the candidate changes
`corpus/self-counts.py`, `corpus/self-counts.tsv` or a GUARD input (the counter reads SETUP).

Named ceilings: the checker binds numbers, not the prose around them; a forged script called by a
pinned ledger command other than `claim-ledger.sh` is not detected beyond the population guards;
the claim fixes the population present at BASE, and a STALE binding the candidate itself creates would
read in this counter as well (the candidate adds no stamped path and no knowledge entry).

## Frontier step and non-claim work (no counter; recorded in the lesson)

- Sourced claim: C1 rests on S111, opened this round (capture, fetch row, quote located `count=1`).
- Mined mistake: the round-52 landing left five self-count statements stale although the checker
  existed (class `masked-stale`: the summary verdict word is POLICY whenever the two operator-routed
  rows are present, so the landing check read no STALE); the C2 counter is the fix shown able to fail
  (K2-0 reads 5); a landing criterion goes into `corpus/QUALITY.md`.
- Round-52 closure defects: D1 → the round-53 candidate cites only receipts that land in or before it
  (the census-end receipt is cited from the receipts commit only); D3 → the full ledger verify runs on
  the candidate tree before the candidate commit; D2/D4 stay routed (named in the lesson).
- Harm check: full `claim-ledger.sh verify` on a clean clone of BASE and of the landing tip, FAIL/POLICY
  ids compared; expected migration R36-03 (it pins the old default-receipt verdict line
  `on_release=29 … derived=15`) with a journal entry.
