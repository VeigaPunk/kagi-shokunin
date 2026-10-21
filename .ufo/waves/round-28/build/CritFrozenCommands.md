# CritFrozenCommands — round 28: ambiguities in the frozen counting commands (F1–F4, G1–G4)

Seat KagiR28.CritFrozenCommands-7 (critic; advice, not closure). `plan:N` = `plans/round-28.md` at claims commit
`bdf90f5` (absent at BASE `3553d49`; lines 1–91 identical at `b9a42c0`, which appends lines 92–101). `clock:N` =
`corpus/release-clock.py` at BASE. All runs: offline, on a `git archive` BASE tree in my sandbox; evidence in
`.ufo/waves/round-28/sandboxes/CritFrozenCommands/probe-*.json`.

## Findings: each ambiguity, the only faithful reading, and the evidence

**A1. What the MISHANDLED parenthetical covers (plan:38-39).** Two parses: (A) `(exit0 ∧ CLEAN) ∨ fired-written ∨
Traceback`, or (B) `exit0 ∧ (CLEAN ∨ fired-written) ∨ Traceback`. Counterexample: BASE on F3 exits 1, writes all four
python.org receipts (S027, S028, S040, S041) as `fired` with parsed version `3.15.01`, and prints `RECEIPT-MISMATCH`
for those rows. Under B, BASE's own observer is TYPED and not MISHANDLED, so a candidate can reach "0/4 and 4/4" while
`--observe` still records a release event from `3.15.01`. Faithful reading: **A**, because plan:23-24 says "never a
release event". TYPED also requires not-MISHANDLED; otherwise F3 at BASE counts under both labels.

**A2. Which F3 feed copy, and what "newest stable item" means (plan:34-36).** BASE's outcome depends on where the
token goes, because `max()` at clock:760 keeps the first of two equal keys. Inserted as the first item, or replacing
the title in place, it reads `fired 3.15.01`. Appended as the last item, it reads `3.15.1`, `not-fired`, with no
python-row finding. The unedited copy also legitimately writes `fired` for S027 and S028 (anchor 3.15.0).
Faithful reading:
- The copy is `.ufo/waves/round-26/captures/S039.body` (sha256 `11c86a34…`, the S027/S028/S040/S041 `sha256` in the
  default receipt `observe-2.json`; six byte-identical copies exist; present at every revision).
- Replace the unique `<title>Python 3.15.1</title>` in place and change nothing else. F4 is "the same" edit with
  `Python 3.15.` + 4301 × `1` (F2's digits).
- After replacement no canonical 3.15.1 remains, so a "written fired observation" is any S027/S028/S040/S041 receipt
  with `verdict: fired`. It is not "parsed_version equals the token": a normalizing observer can rewrite it to `3.15.1`.

**A3. "`--observe` over a local copy" has no command-line path (plan:33-34).** `main` (clock:1707-1713) has no feed
override, `request_body` accepts only public HTTPS (clock:669-670), and `run_observe` (clock:862) fetches all 30 rows.
The tool must import the module and stub `request_body`, as the selftest does (clock:919). The plan says nothing about
the other 26 rows or the date. Evidence: an offline harness exits 1 at every revision, and the unedited copy observed
with the clock pinned to 2026-10-22 gives `RECEIPT-MISMATCH` on all four python rows (date check clock:435 against the
table's 2026-10-21). Faithful reading:
- No live network. The stub serves the edited copy only for `https://www.python.org/downloads/feed.rss`; every other
  URL gets a deterministic fetch failure, identical at both revisions. `utc_timestamp` is pinned to 2026-10-21 UTC.
- The out.json records one uncounted diagnostic: the unedited copy through the same harness, which must show zero
  python-row findings. Without it, F3/F4's TYPED leg is satisfied by the date alone.
- Consequence: exit 0 is unreachable for F3/F4, so MISHANDLED there means a fired receipt or a Traceback. Hence A1 = A.

**A4. Traceback channel (plan:39-40).** F2 at BASE exits **1**, empty stdout, Traceback on stderr only (clock:380;
`main` catches only `SetupError`, clock:1749). Round 27's `c2-measure.py:71-77` read stdout only, which would score F2
as neither label. Faithful: grep stdout and stderr; exit 1 alone never proves TYPED.

**A5. "Typed finding" names no category (plan:22-23, 40-41).** Faithful (literal) reading: any `CATEGORY Sxxx` line
before `RELEASE_CLOCK:` naming the row (F1/F2: S040) or the feed (F3/F4: S027, S028, S040, S041, or feed ids
S036/S039). Narrowing it to a new category after seeing the code would repeat round 27's defect. Consequences to
report, not to redefine:
- **F4 is already TYPED at BASE and cannot fail there.** `observe_one` catches the error (clock:822); the receipts
  carry CPython's "Exceeds the limit (4300 digits)…" message; the run prints `RECEIPT-MISMATCH` on the four rows,
  exits 1, no Traceback.
- Draft `mskip.py` (canonical-only regexes; silently drops the token) scores TYPED 4/4, MISHANDLED 0/4. Its F3/F4
  "typing" is only `REGRESSED`, a fallback to the copy's `Python 3.15.0` item; nothing names the token.
- Draft `mnorm.py` (PEP 440-style removal of leading zeros) passes F1 as `INCONSISTENT S040` (verdict fired but
  "equal"), so F1 cannot tell normalization from refusal. Only F3 under A1 and A2 catches it (S027/S028 fired with
  `3.15.01`, no python-row finding).
- Expected BASE counts under the faithful reading: MISHANDLED 3/4 (F1 CLEAN fired=4; F2 Traceback on stderr; F3 fired
  receipt) and TYPED 1/4 (F4). Under reading B: MISHANDLED 2/4, TYPED 2/4.

**A6. Child interpreter.** F2/F4 depend on CPython's integer-string limit (host `python3` 3.14.8, limit 4300, also
under `-I`). Faithful: children run `python3 -I -B` with no `-X int_max_str_digits`; out.json records version and limit.

**A7. Controls (plan:42-43; plan:68 "CLEAN30").** Faithful: both are the exact `R25-04` line
(`corpus/claim-ledger.tsv:83`), incl. `fired=3 derived=15`. A row opened this round with `on-release` (e.g. a
version-named Python doc for C1's source) makes `on_release` 31 and fails both; use non-on-release, as S042/S043 did.

**A8. G: "the same lower canonical version" picks no value (plan:63-65).** Faithful reading: one literal per group,
hard-coded before the tool's first run, strict canonical `X.Y.Z` (two components is already `INCONSISTENT` at BASE,
clock:577; a leading zero lets C1's rule fire before C2's), numerically below the feed row's version. With mirrored
receipts and 3.13.2 / 2.1.0 / 2.7.0 / 8.22.0, BASE is ACCEPTED 4/4, `CLEAN … fired=3 derived=15`. Table-only edits
give `RECEIPT-MISMATCH` on exactly each group's rows, so correction `b9a42c0` is what makes BASE ACCEPTED, matching
plan:49-50 ("matching forged observation"). [INFERENCE] Other admissible literals give the same result: the anchors
of S033–S035 and S037 each name exactly one version.

**A9. EXACT: "the typed derivation findings" (plan:66-67).** Faithful reading: filter by the derivation category (the
definite noun in the text) and require set equality with the group's ids; record other findings, do not count them.
The category must be a literal fixed in the tool and distinct from BASE's seven (ORPHAN, UNBOUND, INCONSISTENT,
BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED); otherwise the tool author picks it afterwards. Draft `mc2eq.py`
prints exactly `DERIVATION` for each group's rows and nothing else.

**A10. "located anchor" (plan:52).** Faithful: SOURCES.md `anchor` cell of the feed row; its one `VERSION_RE` token.

**A11. G cannot tell equality from a floor check (plan:51-53).** Every fixture lowers. Draft `mc2ge.py` (anchor ≥
feed version) scores EXACT 4/4; a raised G1 (3.13.4 ×4, mirrored) is CLEAN at BASE and under `mc2ge`, `DERIVATION` ×4
under `mc2eq`. Gap in the frozen set; correction: a *new* selftest case.

**A12. "Clock selftest count grows only by new cases" (plan:43-44).** Both C2 drafts make `--selftest` exit 1 on three
BASE cases: `derived anchor counted` (clock:1052), `non-numeric anchor keeps inequality` (clock:1073) and `feed floor
lifts non-numeric anchor` (clock:1084). Cause: the synthetic feed row S002's anchor is "Latest release", which names no
version (clock:987, again at clock:1564), and two cases use the series anchor `1.2.x`. Only 40 of the 79 cases pass
through a named `run_case`; 39 are unnamed inline counter bumps. Faithful reading: count after = 79 + added cases, and
no BASE case removed. The words do not forbid rewriting a BASE case's expectation, but C2 forces that (or an S002
harness edit), so it must be declared under Plan corrections with case names and old → new expectations. Doing it
silently is the round-27 pattern.

**A13. "Written this round, then never changed" (plan:27, 57).** Round 27's tool grew fixtures mid-round
(`round-27/tools/c2-measure.py:7-8`); `tools/` is empty now. Faithful: every out.json records the tool's sha256, equal
for before and after; it runs from the working tree against a clone at the full 40-hex `<rev>`.

**A14. Correction `b9a42c0` (plan:93-101).** Necessary (without it F1 at BASE is `RECEIPT-MISMATCH S040`, exit 1,
already TYPED) but under-specified: mirror exactly `parsed_version` and `verdict` (round-27 `c2-measure.py:61-64`),
leave `observed_at`/`sha256`/`url`/`http_status` untouched. It does not address A3.

**A15. Uncovered.** plan:21 covers *anchors*, but no fixture has a non-canonical one: derived `3.13.03` on S008
(mirrored) is CLEAN at BASE and under `mnorm`; only a string-comparing C2 catches it (`DERIVATION S008`).

**Axes:** freshness (A1–A6, A15), calibration (A8–A12). Correction: append A1–A4, A9, A12 to Plan corrections as
*readings*; the tool encodes exactly those and records A3's diagnostics. No command, fixture, value or predicate changes.

## Commands run (exit 0 unless stated)
- `git show bdf90f5:plans/round-28.md`; same at `3553d49` (exit 128); plan `diff` vs working tree (exit 1: lines 92–101).
- `git archive 3553d49 | tar -x` into the sandbox; `python3 -I -B probe.py {base,mnorm,mskip,mc2eq,mc2ge}` (exit 0;
  the four drafts are sandbox copies of the BASE clock). `--selftest`: BASE, `mnorm`, `mskip` PASS (79); `mc2eq`,
  `mc2ge` exit 1. BASE default control: `CLEAN (on_release=30 … fired=3 derived=15)`, exit 0.
  sha256: `probe.py` ff653d97…, `probe-base.json` 5e105df3….

## What I did NOT check
Nothing ran in the lane checkout; no network. Untested: a harness serving retained bytes for all 30 rows (F3/F4 could
then reach exit 0); round-28 candidate code (none exists; drafts are mutants); separability overlays; ledger/stamp
bookkeeping; C1 source-row content; A8 beyond one literal per group. No tools installed.
