# FSelfGroup8 — C1 falsification: RD-STATE-ROWS / RD-SCOPE-SELFTEST / RD-LEDGER-SELFTEST / RD-LEDGER-ROWS

Revision: frozen `82745e2c60e726b49499b8f309529935dc4eff2b` (verified `git rev-parse HEAD` after all runs; `git status --porcelain` = 0 between/after cases). Axes attacked: calibration (doc↔live binding), operability (empty-HOME runnability), freshness (live source re-measured each run). No installs were needed; no tool added.

## Setup (sandbox only)

```
git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FSelfGroup8-4/lane
git -C <lane> checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b
awk -F'\t' '<select 4 IDs>' <lane>/corpus/self-counts.tsv > /fast/scratch/kagi-r25/FSelfGroup8-4/home/selected.tsv   # 4 rows; full claim-ledger.tsv left complete (65 ^R-rows, ID universe intact)
```
Every run: `env -i PATH=/usr/bin:/bin HOME=<sb>/home PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/self-counts.py --table <sb>/home/selected.tsv` (cwd=`<sb>/lane`). No verify/cells; no `--observe`; no network; no host contact.

## Baseline — PASS (exit 0, 8.4s; ledger commands really executed)

```
OK RD-STATE-ROWS corpus/README.md:42 claimed=22 live=22
OK RD-SCOPE-SELFTEST corpus/README.md:43 claimed=61 live=61
OK RD-LEDGER-SELFTEST corpus/README.md:63 claimed=166 live=166
OK RD-LEDGER-ROWS corpus/README.md:64 claimed=65 live=65
SELF_COUNTS: CLEAN (claims=4 stale=0)  EXIT=0
```
Unique locators: my own regex recount independently found exactly 1 match each at README lines 42/43/63/64 (gate's AMBIGUOUS/UNLOCATED paths stayed silent — corroborating, not duplicating).

## Doc mutants (+1 on the captured integer; restore `git checkout -- corpus/README.md` after each) — ALL PASS

| binding | doc mutation | key stdout | exit |
|---|---|---|---|
| RD-STATE-ROWS | L42 `22 rows (`→`23` | `STALE RD-STATE-ROWS corpus/README.md:42 claimed=23 live=22` + `SELF_COUNTS: STALE (…stale=1…)` | 1 |
| RD-SCOPE-SELFTEST | L43 `` `--selftest` (61 cases) ``→`62` | `STALE RD-SCOPE-SELFTEST corpus/README.md:43 claimed=62 live=61` | 1 |
| RD-LEDGER-SELFTEST | L63 `` `--selftest` 166 cases ``→`167` | `STALE RD-LEDGER-SELFTEST corpus/README.md:63 claimed=167 live=166` | 1 |
| RD-LEDGER-ROWS | L64 `65 rows (`→`66` | `STALE RD-LEDGER-ROWS corpus/README.md:64 claimed=66 live=65` | 1 |

In every mutant run the three untouched bindings stayed `OK` — per-binding, not whole-table, detection.

## Live-side falsifier probes (prove live source, never self-certified) — BOTH PASS

- Appended sandbox row `R99-99 …` to `corpus/claim-ledger.tsv` (66 rows): `STALE RD-LEDGER-ROWS corpus/README.md:64 claimed=65 live=66`, exit 1. Binding re-counts the actual row universe; it does not read the row's expect pin (`^65$`) nor the doc.
- Appended one data line to `corpus/state-shape.tsv` (23 data lines): `STALE RD-STATE-ROWS corpus/README.md:42 claimed=22 live=23`, exit 1. Both restored, tree clean.

## Runnable-source receipts (literal expectations vs source; clean tree, env -i)

- `bash corpus/scope-gate.sh --selftest` → exit 0, last line `SCOPE_SELFTEST: PASS (61 cases)` — matches extract and doc 61.
- `bash corpus/claim-ledger.sh --selftest` → exit 0, last line `SELFTEST: PASS (166 cases)` — matches extract and doc 166.
- `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → 65 (my recount: 65). `state-shape.tsv` data lines → 22 (my recount: 22).
- Source-row honesty: R16-02/R11-09/R21-04 notes carry no `[host]`/`[substrate]`; commands are allowlisted (`bash`/`grep`); R11-09 uses `--selftest` mode so the recursion guard admits it; none of the four bindings needs `expect:` (all sources non-host), and self-counts compares doc against executed output, not against any pin.

## Numeric-object semantics (each number is what it claims)

- RD-STATE-ROWS 22 = non-empty non-`#` data lines of `corpus/state-shape.tsv` (R11-10 pins the same count; file has no blank lines).
- RD-SCOPE-SELFTEST 61 = cases proven by scope-gate `--selftest` (43 partition + 18 breadth per R16-02 note).
- RD-LEDGER-SELFTEST 166 = isolated ledger selftest cases (R11-09: 151 + 14 layout + 1 observe-refusal, round 25).
- RD-LEDGER-ROWS 65 = ledger rows matching `^R[0-9]+-[0-9]+` (39 original + R22–R25 additions; R24-14 pins the id set).

## Findings

No falsifier found for these four bindings at `82745e2c`. Fails-closed directions observed: doc drift → STALE exit 1; live count drift → STALE exit 1; extract-mismatch → SETUP exit 2 (design, selftest-covered `last-line-not-extracted`). Minor non-defect observations: `rows:` live count accepts any non-`#` non-blank line (unvalidated columns) — inflations fail STALE, i.e. safe direction; STALE is only reachable when the live last line still parses to an integer — if a source's verdict format changed entirely the gate reports SETUP exit 2, which still fails closed.

## Limits / UNRUN

- UNRUN: the other 33 of the 37 `self-counts.tsv` rows (seat scope is the 4 named IDs); full-table completeness over all docs is C1's own non-claim (R25-C6).
- UNRUN: live-side mutation of the two selftest programs themselves (would require editing gate code; doc-side mutants + direct execution receipts cover both STALE directions only for the two `rows:`/`grep` bindings).
- Full `verify`/`cells`, `--observe`, and any network feed fetch were not run (contract).
- No production file touched; all mutations were in `/fast/scratch/kagi-r25/FSelfGroup8-4`, restored to `82745e2c` clean after each case.
