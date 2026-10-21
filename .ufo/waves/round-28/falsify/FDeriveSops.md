# FDeriveSops — G1 falsification (SOPS derived rows S008–S011 lowered)

Target: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`
(pinned candidate). BASE compared: `3553d499577084a6c98d7078906017840bbf7b28`.
Carrier attacked: **G1 only** (plan §C2 fixture: feed `S033`, rows `S008 S009 S010 S011`,
anchored+observed lowered `3.13.3 → 3.13.2`, verdict `not-fired`).

## Verdict

**PASS** — G1 is refused by the candidate with the exact typed category `DERIVATION`,
naming exactly `S008 S009 S010 S011`; exit 1; no traceback; no fired verdict written;
nothing written to the tree. BASE accepts the same fixture CLEAN (exit 0), so the
candidate closes a real hole rather than restating a generic receipt complaint.
No counterexample found for G1. (G2/G3/G4, C1, ledger/stamps/lessons NOT assessed — out of item scope.)

## Commands run (all from my sandbox, no network)

| # | command | exit |
|---|---|---|
| 1 | `git archive 3553d49 \| tar -x -C sandboxes/FDeriveSops/base`; `git archive 62a33b1 \| tar -x -C .../cand` | 0 |
| 2 | `python3 -I -B g1_probe.py cand work-cand` (my own fixture builder, independent of the frozen tool) | 0 |
| 3 | `python3 -I -B g1_probe2.py base work-base2` / `… cand work-cand2` (BASE vs candidate, partial-group variant) | 0 / 0 |
| 4 | `python3 -I -B g1_probe3.py cand work-cand3` (sensitivity + marker-escape variants) | 0 |
| 5 | `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1… FDeriveSops-cand cand-c2-measure.json` (frozen command) | 0 |
| 6 | `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d49… FDeriveSops-base base-c2-measure.json` | 0 |
| 7 | `python3 -I -B corpus/release-clock.py --selftest` (in sandbox candidate tree, offline) | 0 → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` |

Frozen command output: candidate `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0`; BASE `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0`. My independent probe and the frozen tool agree on G1.

## Exact candidate code under test

- Rule site: `corpus/release-clock.py:616-625` — `if (is_derived and not non_canonical and feed_source is not None and not derived_anchor_bound(feed_source["anchor"], anchored)): errors.add(("DERIVATION", source_id)); row_valid = False`
- Helper: `corpus/release-clock.py:349-363` (`derived_anchor_bound`: the feed row's **anchor cell** must name exactly the one stable X.Y.Z).
- Finding printer: `corpus/release-clock.py:713-720` → `"%s %s" % (category, row_id)`; final `RELEASE_CLOCK: FAILED …`.
- Fixture data (candidate tree): `corpus/release-clocks.tsv:5-8` (S008–S011, `feed_source_id=S033`, `note` starts `derived:`), `corpus/SOURCES.md:39` (S033 anchor cell names only `v3.13.3`).

## G1 measured behaviour

Candidate, G1 fixture (table + mirrored receipt copy, `--receipt/--receipt-sha`):

```
DERIVATION S008
DERIVATION S009
DERIVATION S010
DERIVATION S011
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)
```
exit **1**; stderr empty; no `Traceback`; named ids = {S008,S009,S010,S011} exactly
(no S033, no other row, no other category). **No `RECEIPT-MISMATCH` line at all** — the
typed category is the new `DERIVATION`, not a generic receipt mismatch.

Independence from the receipt (extra probe): same table edit with the receipt **not**
mirrored → `DERIVATION S008…S011` **plus** `RECEIPT-MISMATCH S008…S011`, exit 1. The
derivation finding is therefore produced by the anchor-binding rule itself, not by the
receipt comparison.

BASE, identical fixture → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit **0** (no findings): BASE accepted the four forged lowered anchors. BASE only catches a *partial* lowering (`S008` alone) via the generic `REGRESSED S008` — a different category; the uniform four-row group is the hole G1 targets, and it is closed.

Control (candidate, unmodified tree): `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0, no findings — no false positive on the 15 legitimate `derived:` rows.

## No fired verdict written

- Fixture tree digest and candidate tree digest (sha256 manifest of every file) identical before/after the run → the verify path wrote nothing.
- `fired=3` in the G1 run equals the control's `fired=3`; those three rows are `S012`, `S027`, `S028` (`corpus/release-clocks.tsv`, verdict `fired`) — none is a SOPS row, so the four lowered SOPS rows contribute zero fired verdicts, and the receipt copy still reads `verdict=not-fired`, `parsed_version=3.13.2` for S008–S011 (unchanged by the run).

## Escape attempts (all refused, none reaches CLEAN)

| variant (G1 rows) | exit | findings |
|---|---|---|
| anchored left at `3.13.3` (no real lowering) | 0 | none — CLEAN, no false positive |
| lowered to `3.14.0` (different unbound version) | 1 | `DERIVATION S008…S011` |
| note marker `derived:` → `Derived:` | 1 | `INCONSISTENT S008…S011` (own-anchor check, typed) |
| note marker `derived:` → `xderived:` | 1 | `INCONSISTENT S008…S011` |
| lowered to `3.13.02` (leading zero) | 1 | `NON-CANONICAL S008…S011`, no traceback |
| lowered to `3.13.` + 4301×`1` | 1 | `NON-CANONICAL S008…S011`, no traceback |

## Residual risk / verification gaps

- **Not checked (out of item scope):** G2/G3/G4 fixtures; the C1 table/observe fixtures; ledger pins, stamps, lessons, README claims; the live `--observe` path against the real GitHub feeds (no network used). The candidate's observe path is exercised only by its offline selftest block (`corpus/release-clock.py:1982-2022`), which I ran: PASS (106 cases), exit 0.
- `derived_anchor_bound` (`corpus/release-clock.py:363`) requires the feed cell's X.Y.Z token set to equal `{anchored}` exactly; a cell naming two versions flags the row even when one matches. Conservative, intended (candidate selftest case "derived anchor needs one version in cell"), and not triggered by S033 (single token `v3.13.3`).
- The `DERIVATION` check is skipped when anchored/observed is non-canonical (`corpus/release-clock.py:618`), but such a row then gets the typed `NON-CANONICAL` finding — verified above, no silent CLEAN.
- Fixture semantics: the clock reads `corpus/SOURCES.md` and `corpus/release-clocks.tsv` from `--root` (candidate `corpus/release-clock.py:54-56`, `95-97`), so the registry was the candidate's unmodified SOURCES.md, as the plan requires. My fixture builder is my own code (not the frozen tool's), yet reproduces the frozen tool's G1 verdict exactly. No tools installed or upgraded for this item (none needed).

## Artifacts retained

`.ufo/waves/round-28/sandboxes/FDeriveSops/`: `g1_probe.py`, `g1_probe2.py`, `g1_probe3.py`,
`cand-G1.json`, `cand-G1b.json`, `cand-G1c.json`, `base-G1.json`, `cand-c2-measure.json`,
`base-c2-measure.json`. Extracted BASE/candidate trees deleted at completion (scratch directive).
Nothing outside my sandbox was written; lane checkout `git status` unchanged by me.
