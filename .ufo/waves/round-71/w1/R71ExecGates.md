Author: R71ExecGates (executor-gates)

# R71ExecGates — lane-gate harm check, candidate vs BASE

Godspeed axes (named, applied): **gate harm** (no gate that was green/known at BASE
goes red because of the candidate), **verdict stability** (healthy gates stay
healthy), **completeness** (every assigned gate actually run on both revisions,
verdict classes compared). Iteration: cheap in parallel (export both revisions
to scratch, run gates in the background), keep every comparison, no gate is
dropped for slowness.

BASE `e0e9603a924d73d9621924cc507b50474d11dae7` vs candidate
`39e76bc700cf05e7772711f703bdbc3c6e7ac469`. Both revisions were exported via
`git archive` into scratch (never the lane checkout) and every gate below ran
there, in its tree's own copy. Evidence (exact gate outputs) copied to
`.ufo/waves/round-71/w1/R71ExecGates/`: `verify-base.txt`, `verify-cand.txt`,
`gates-base.txt`, `gates-cand.txt`, `c1-71-cand.txt`, `c1-70-cand.txt`.

## Gate results BASE → candidate

| gate | BASE | candidate | verdict class diff | classification |
|---|---|---|---|---|
| `bash corpus/claim-ledger.sh verify` (full) | `CLAIM_LEDGER: POLICY (claims=102 policy=5 stamped=177)` rc 2 | `CLAIM_LEDGER: POLICY (claims=102 policy=5 stamped=178)` rc 2 | **one line differs**: the summary's stamped count; `grep -c ^FAIL` = 21 both, `^STALE`=0 both, `^NOT-A-FILE`=0 both, `^POLICY`=5 both; FAIL/POLICY/SETUP/STALE/MISSING/HOST-SKIP/NOT-A-FILE line sets identical | no harm — 21 FAILs pre-existing (incl. R36-01 verdict-not-final, named in the round-70 spotcheck), POLICY host-skip set pre-existing; stamped 177→178 is the expected new knowledge-entry row |
| `bash corpus/claim-ledger.sh docs` | `DOC_AUDIT: CLEAN (entries=50 row_linked=47 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)` rc 0 | `DOC_AUDIT: CLEAN (entries=51 row_linked=48 by_hand=3 ...)` rc 0; new entry line `ENTRY corpus/knowledge/openbao-pki-issuer-revocation-channels.md row_linked=1 by_hand=-` | entries 50→51, row_linked 47→48 | expected — one new admitted entry, row-linked, pinned |
| `bash plans/round-36-c3.sh` (RELEASE_CLOCK) | `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)` rc 0 | identical counters, rc 0 | none | no harm — the new entry's `Reverify: R21-02` and on-release `recheck:` need no new clock; no unbound row |
| `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=28 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=4 SD6=23 SD7=0 SD8=1 SD9=0)` rc 1 | identical n=28, identical MISMATCH line set (diff of the 28 lines: empty) | none | pre-existing — matches the round-70 spotcheck reading of BASE; candidate adds no new mismatch |
| `python3 corpus/self-counts.py` | `SELF_COUNTS: POLICY (claims=63 stale=4 unlocated=0 ambiguous=0 policy=2 setup=0)` rc 2 | `SELF_COUNTS: POLICY (claims=63 stale=7 ...)` rc 2 | doc live counts moved: SKILL.md:46 / PROVINCE.md:73 stamps 177→178 (already stale); corpus/README.md:65 RD-STAMPS 177→178, :67 RD-DOCS-ROWLINKED 47→48, :67 RD-DOCS-ENTRIES 50→51 (OK→STALE) | **candidate-introduced staleness, expected class** (three current-tense doc counts now unbound, QM21) — plus the 4 pre-existing stale + 2 POLICY (PV-FEEDTOKEN-*, ledger rows not allowlisted) unchanged. Repairable by a corpus/README.md counts update at closure; the candidate does not touch corpus/README.md. Not hidden, not hidden by me — stated here. |
| `bash corpus/claims-declared.sh` | `CLAIMS_DECLARED: MISMATCH (claims=66 mismatch=2)` rc 1 (round-69 C1/C2 `tagged-rows-0`) | identical, rc 1 | none | pre-existing |
| `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=163 A=145 B=2 C=16 queued=3 mined=141 rejected=19 entries_sourced=29 legacy=21 captures=163 inrow=16 ...)` rc 0 | `SOURCES_CENSUS: CLEAN (rows=164 A=146 B=2 C=16 queued=3 mined=142 rejected=19 entries_sourced=30 legacy=21 captures=164 ...)` rc 0; `SOURCES_CAPTURES: CLEAN (path_rows=43→44)` | rows +1 (S173), mined +1, entries_sourced +1, captures +1 | expected — one new `mined` registry row and capture; SOURCES.md diff confirms S173 row (tier A, `mined`, URL `https://openbao.org/docs/secrets/pki/considerations/`) and the S170 used-by extension; `source-fetches.tsv` S173 row added; `stamps.tsv` +1 row (new entry) + SOURCES/source-fetches re-stamps |
| `bash plans/round-70-c1.sh 39e76bc…` (prior claim) | value=5 at BASE tip context | `C1_PKI_TRIAL: value=5 discriminating=5 ...` rc 0 | none | no harm to the round-70 claim |
| `bash plans/round-71-c1.sh 39e76bc…` (this round) | — | `C1_PKI_ISSUER_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 ... T6..T9 each art=1` rc 0 | n/a (new claim) | meets the frozen target |
| Frozen controls re-read (`.ufo/waves/round-71/controls/receipts/`) | — | F0 `value=0 absent=1` rc 1; P1 `value=4` rc 0 all `art=1`; F1 `value=0 discriminating=0` (shim=HOLDS, art=0); F2 `value=0 discriminating=0` (shim=BROKEN, art=0); F3 `value=0`; F4 `sourced=0`; F5 `noleak=0`; F6 `nosecret=0`; F7 `value=3` (T7 art=0) | — | all nine match the runner's pre-run expected verdicts (receipts re-read by me, first line each) |
| Frozen counter sha | — | `sha256sum plans/round-71-c1.sh` = `4d77f19c…504ab8117b`, matches `controls/receipts/counter.sha256` and the task brief | none | freeze intact |

## Reading the candidate diff (plain counts)

`git diff --name-only BASE..candidate` = 51 files: plan + counter + controls
runner + keeper receipts + captures (S170 re-open, S173) + `claims.json` +
frozen control fixtures + trial + knowledge entry + SOURCES/SOURCES-fetch/
stamps + L1 probe. 5988 insertions, 3 deletions. The 3 deletions are the S170
row's used-by extension and the two re-stamped rows — in-place registry edits
expected under QM14/QM40 are confined to those (S170 anchor bytes unchanged:
capture sha256 `9fa76939…` still recorded).

What stays true: the new entry follows the lane bar — `source:` names S173
(`mined`) and S170, `verified-at:` + `recheck:` present, `## Does not
establish` and falsifiers present, and `## Measured (round 71` carries the
four `- T<n> … OpenBao 2.7.2 …` lines the counter's DISCRIMINATE leg reads.
The trial is the P1 reference (byte-identical to the positive control per the
brief).

## Process notes

- `claim-ledger.sh verify` full takes >300 s per revision; first attempt hit
  the 300 s bash timeout (killed, HOST-SKIP lines only out). Re-ran both
  revisions with an explicit 1800 s timeout in parallel — both completed.
- No `bao server` processes remain (`grep -c '[b]ao server'` → 0 after all
  counter runs). No tools installed. No host mutation.
- Scratch `/fast/scratch/hyaku/kagi-r71/R71ExecGates` removed after copying
  the six evidence files into this seat's dir.

## Residual risk / blockers

- The three newly-stale doc counts (corpus/README.md:65, :67): if closure
  does not patch them, the lane carries stale=7 until some later round does.
  This is a known small frontier cost, not a FAIL anywhere; no gate reads
  corpus/README.md counts as a kill condition, and self-counts already read
  POLICY at BASE. Recommend a closure-side update (177→178, 47→48, 50→51),
  as round 70 did for its entry.
- Namesake reality: this seat re-measured, it did not re-open S173's page.
  Source grounding itself is the sentinel/connector's axis, not gated here.

SEAT-STATUS: complete all assigned gates run on both revisions; one expected-class candidate-introduced staleness (3 README doc counts) reported, no FAIL/STALE/NOT-A-FILE harm on the claim ledger, round-70 counter still 5.
