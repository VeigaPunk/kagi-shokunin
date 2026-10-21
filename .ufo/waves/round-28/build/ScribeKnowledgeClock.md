# ScribeKnowledgeClock — does any knowledge entry document release clocks?

Scope: `plans/round-28.md` C1 (canonical version tokens) and C2 (derived-anchor binding), knowledge-entry side only.
BASE `3553d499577084a6c98d7078906017840bbf7b28`. All citations are `git show`/`git grep` at BASE. The lane working tree was not used as evidence.

## Decision

**No `corpus/knowledge/*.md` entry changes.** Reasons F1–F5 below. The append-only text belongs in QUALITY.md, a new round-28 lesson, and L1-owned pointers (draft in §Routing).

## Findings

**F1. No knowledge entry documents release clocks.** `git grep -n -i -E 'release[-_ ]?clock' 3553d499… -- corpus/knowledge` returns no hits (exit 1, no match). The only `clock` hit in that directory is a token-lifetime title, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:1` ("separate clocks"), which is not a release clock.

**F2. The mechanism is documented outside `corpus/knowledge`.** Current-tense descriptions are in:
- `corpus/README.md:181-192` (C3 entry, frontier path) and `:219-228` (round-27 active contract, REGRESSED rule)
- `SKILL.md:48` and `SKILL.md:787-795` (command table and round-26 drift section)
- `PROVINCE.md:54`
- `SCORECARD.md:688`, `:976`, `:1081-1094`
- `corpus/QUALITY.md:132` (QM25, strict X.Y.Z ordering) and `:133` (QM26, knowledge-number binding, which covers `corpus/knowledge/*.md` numbers only)
- `corpus/lessons/round-25.md:3,5`; `corpus/lessons/round-27.md:3,5` and the named debt at `:221-226`

**F3. Knowledge entries touch clocks only as prose.** Four entries carry `recheck: on-release` lines naming vendor pages, not the tool: `corpus/knowledge/onepassword-machine-credentials.md:4` (S006–S007), `feature-bound-credential-review.md:3`, `sops-age-key-rotation.md:5`, `vault-openbao-token-lease-lifecycle.md:5`. `corpus/release-clock.py` never reads `corpus/knowledge`. Its recheck inputs are the SOURCES `recheck` cell only (`release-clock.py:91`, `:511`, `:518`, `:560`, `:871`, `:938`). `git grep 'knowledge' -- corpus/release-clock.py` returns no hit.

**F4. No knowledge number is a release-clock anchor.** Versions in knowledge entries are host tool versions: `op` 2.35.0 (`corpus/knowledge/op-cli-surface.md:3`, `:15`), opencode 1.18.31 (`corpus/knowledge/config-layering.md:4`). None is a `release-clocks.tsv` anchor, so C1 or C2 cannot change any knowledge figure. QM26's `KN-*` rows in `corpus/self-counts.tsv` bind counts, not clock tokens.

**F5. A new knowledge entry would be a category error and costly bookkeeping.** `corpus/knowledge` is the host-fact surface. `corpus/claim-ledger.sh:67-75` requires every entry to carry one `Reverify:` line and a `corpus/stamps.tsv` revision pin. `doc_audit` at `claim-ledger.sh:1106-1135` enforces this, and `claim-ledger.sh:767` puts `corpus/knowledge/*.md` in the audited doc list. The frozen plan does not authorize that bookkeeping. `corpus/stamps.tsv` already has 25 `corpus/knowledge/` rows; a tooling-contract entry would add a 26th and a Reverify row for no host fact.

**F6. Calibration input (C2), BASE.** All 15 `derived:` rows in `corpus/release-clocks.tsv` currently equal their feed row's located anchor in `corpus/SOURCES.md:39-43` (anchor column, `$7` of the pipe table):

| derived rows | feed | `anchored_version` | SOURCES anchor (path:line) |
|---|---|---|---|
| S008, S009, S010, S011 | S033 | 3.13.3 | `SOURCES.md:39` "Entry titled v3.13.3" |
| S013, S022, S023, S024 | S034 | 2.2.0 | `SOURCES.md:40` "Entry titled v2.2.0" |
| S014, S015, S016, S021, S025, S026 | S035 | 2.7.1 | `SOURCES.md:41` "Entry titled v2.7.1" |
| S029 | S037 | 8.23.0 | `SOURCES.md:43` "Version and Date: 8.23.0" |

Counterexample to the current guarantee: `derived` rows bypass the anchor check (`release-clock.py:565-566`: `anchor_ok = is_derived or version_is_named(...)`). So the 15 matches are the author's coincidence, not a checked binding. Note drift on the same row: `release-clocks.tsv` S029 has `anchored_version=8.23.0`, but its note says "anchor names 8.23.1". C2 compares `anchored_version` only, so this note/anchor divergence passes unchecked.

**F7. Canonical-token counterexamples (C1), measured in sandbox copy only.** Sandbox `.ufo/waves/round-28/sandboxes/ScribeKnowledgeClock/base` is `git archive` of BASE.
- Probe (`python3 -I -B`, Python 3.14.8): `numeric_version('3.15.01')` = `(3, 15, 1)`; `is_regression('3.15.1','3.15.01')` = False; `norm_version('3.15.01') == norm_version('3.15.1')` = False. The fired test is the string compare at `release-clock.py:582`, so `3.15.01` reads as a fired release, as the plan states. Fixture F1 never reached this line (below).
- Oversize: `numeric_version('3.15.' + '1'*4301)` raises `ValueError: Exceeds the limit (4300 digits)…` from `release-clock.py:380`, reached via `is_regression` (`:387`) called at `:567`. Traceback, no typed finding.
- **Frozen fixture defect, F1:** with `S040 observed_version=3.15.01 verdict=fired`, the default command exits 1 with `RECEIPT-MISMATCH S040` and `RELEASE_CLOCK: FAILED (… observed=29 …)`, with no traceback. The pinned receipt rejects the table before the leading-zero token matters. Under the frozen predicate ("TYPED = exit 1, no traceback, names the row"), F1 is already TYPED at BASE, so the before-count "MISHANDLED k/4" cannot show F1 as a defect and the after-count cannot show the canonical check. Reported, not redefined.
- F2 (`S040 observed = "3." + 4301 × "1"`): exit 1 with `Traceback`, `ValueError` at `release-clock.py:380`. MISHANDLED by the frozen predicate.

## Routing (append-only drafts for L1; not written to production)

A knowledge entry is not required. The append-only text, for L1 to integrate:

1. **QUALITY.md, new row QM27** after `corpus/QUALITY.md:133` (QM26):
   > QM27 | Supplements QM25 (round-28 C1/C2): a version token used as a release-clock anchor, a table observation or a feed entry must be canonical: no leading zero in a multi-digit component (SemVer §2, registry row still to be opened) and within CPython's integer-string conversion limit (`sys.get_int_max_str_digits()`, 4300 on the round-28 probe). A non-canonical token is a typed finding that fails the run: never a fired release, never a traceback. A `derived:` row's `anchored_version` must equal the version named by its `feed_source_id` row's located anchor in `corpus/SOURCES.md`; a mismatch is a typed finding. | `3.15.01` read as fired (`release-clock.py:582`); `3.15.`+4301 digits raises ValueError (`:380`); a lowered derived anchor with a matching forged observation stays CLEAN

2. **Lesson, new `corpus/lessons/round-28.md`** (new file, append-only). Record "no knowledge entry changed, because F1–F5", and close round-27's named debt (`corpus/lessons/round-27.md:221-226`) by reference. Do not edit those lines.

3. **Pointers, append-only:** one bullet in `corpus/README.md` round-28 section, and one line in `SKILL.md` near `:787-795`, each naming QM27 and the new fixture results.

4. **Bookkeeping L1 must reconcile (not mine):** the R25-03 ledger pin (`corpus/claim-ledger.tsv:82`, "79 cases"), `self-counts.tsv:22` and `:38` (selftest count bindings), and `stamps.tsv:77-78` (`release-clock.py`, `release-clocks.tsv` digests). Any C1/C2 change shifts all three.

## Commands run (exit codes)
- `read plans/round-28.md` ok; `read` on working-tree paths `kagi-shokunin/corpus/README.md:178` and `kagi-shokunin/corpus/QUALITY.md:128` failed "not found" (working-tree path form); all later reads used `git show <BASE>`.
- `git grep -n -i -E 'release[-_ ]?clock' <BASE> -- ':!.ufo' ':!plans'` → 0 for corpus/knowledge; lane-wide grep exit 0.
- `git cat-file -t <BASE>` → commit, exit 0. `git cat-file -e <BASE>:corpus/lessons/round-28.md` → exit 128 (absent at BASE, expected).
- `git archive <BASE> | tar -x -C .../sandboxes/ScribeKnowledgeClock/base` → exit 0.
- `python3 -I -B corpus/release-clock.py` in sandbox base → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0 (control matches the frozen control).
- Probe script (`importlib` load of sandbox base `release-clock.py`) → exit 0; output in F7.
- Fixtures `f1`, `f2` (sandbox copies; `S040` edited) → `python3 -I -B corpus/release-clock.py` exit 1 each; f1 `RECEIPT-MISMATCH S040`, f2 Traceback (`release-clock.py:380`).
- Tools installed or upgraded: none. Python 3.14.8 used as-is.

## Not checked
- SemVer §2 text and the Python integer-limit documentation were not fetched; the registry rows in `corpus/SOURCES.md` (S042 cites §11.2 only, `SOURCES.md:49`) do not carry the §2 rule. The QM27 wording is a draft pending the scout's sourced rows.
- The C1/C2 measurement tools `.ufo/waves/round-28/tools/c1-measure.py` and `c2-measure.py` were not run (not present at BASE; build-wave artifacts). F3/F4 and G1–G4 fixtures were not run.
- No lane gate, selftest or `claim-ledger.sh` run in the lane checkout (contract). `doc_audit` behavior was read from code, not executed.
- Working-tree state of the lane was not compared with BASE; the `read` failures above were not investigated.
- No knowledge entry's recheck prose was checked against live vendor pages; this is a documentation scope, not a freshness check.
