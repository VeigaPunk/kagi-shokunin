# ScribeSkillRows — round-25 SKILL.md draft (C1 calibration, C3 freshness)

Scope: draft text only. No lane production file was edited. Only this report was written.
Base named by the wave: 4587c61a348e4528717404a68912c373f3ef4d03. Revision of the lane working tree read: UNRUN (not established).

## Reads and counts (read-only)

- `read SKILL.md:20-50` — table header line 21, separator 22, rows 23-48. Line 46 holds the stale count phrase `(63 stamps + 39 claims + claim ids, round 21)`.
- `read plans/round-25.md` — D1 (SKILL.md:46 stale), C1 table `corpus/self-counts.tsv`, C3 `corpus/release-clocks.tsv` / `corpus/release-clock.py`.
- `grep -c '[^[:space:]]' corpus/stamps.tsv` → 83 (identical to ledger row R12-03 command, `expect ^83$`).
- `grep -c '^[^#[:space:]]' corpus/claim-ledger.tsv` → 61 (non-blank, non-`#` rows; matches plan "measures 83/61").
- `grep -rln on-release` → 28 registry rows in `corpus/SOURCES.md` carry `on-release` (matches plan's 28).
- Not run: `claim-ledger.sh verify`, `cells`, `self-counts.py`, `release-clock.py` (not yet existing; forbidden on lane tree for verify/cells).
- Tool installs: none. Pacman paused; none needed.

## Insertion points (apply bottom-up or anchor on row text; line numbers shift)

1. SKILL.md:46 — replace only the parenthesized count phrase, nothing else in the row.
2. Insert row A (Check a number) after SKILL.md:46 — before the `Learn from` row.
3. Insert row B (on-release clock) after the `Learn from` row (current line 47) — before the `Judge a "short-lived"` row. Keeps the `recheck:` clock row beside the source row that names it.

No blank lines, no new columns. Cells use no bare `|` (escape-free).

## 1. Line 46, count phrase replacement

Old (verbatim, inside the row):
```
(63 stamps + 39 claims + claim ids, round 21)
```
New draft (paste as written):
```
(<STAMPS> stamps + <CLAIMS> claims + claim ids)
```

Integration obligation (must do before paste goes live): `<STAMPS>` and `<CLAIMS>` are placeholders. self-counts locates exactly one number per row, so the integrated doc must carry the live numbers. Fill with the values the integrated tree produces (read-only measure today: stamps 83, claims 61). Do not type them by hand in the TSV — the TSV's source column is what binds them. Precedent: `ReviewLedger.md:48` (round-22) took values from actual run output at the integrated tree.

Filled form the integrator pastes (same shape, live values):
```
(83 stamps + 61 claims + claim ids)
```

Dropping `round 21`: the count is now current-tense and bound; round-dated history stays out of population by rule.

## 2. Row A — insert after SKILL.md:46

```
| Check a number the corpus states about itself | `python3 corpus/self-counts.py` (table `corpus/self-counts.tsv`; each row locates one current-tense number in a committed doc and binds it to its live `rows:<path>` or `ledger:<ID>` source); `python3 corpus/self-counts.py --root DIR` for a scratch tree; `--selftest` for the gate itself | editing the doc number or its TSV row to go green; hand-typing the live value instead of letting the source produce it; widening the scan to round-dated history (LOG, lessons, SCORECARD history are out of population by rule); treating `UNLOCATED` or `AMBIGUOUS` as clean | exit 0 `SELF_COUNTS: CLEAN (claims=N stale=0)`; 1 `SELF_COUNTS: STALE (claims=N stale=K unlocated=J)` preceded by `STALE`/`UNLOCATED`/`AMBIGUOUS` lines naming row and path; 2 `POLICY`/`SETUP` |
```

## 3. Row B — insert after the `Learn from` row (current line 47)

```
| Judge whether a source's on-release clock fired | `python3 corpus/release-clock.py --root <tree>` (offline: each `recheck: on-release` registry row must bind to one clock in `corpus/release-clocks.tsv` — `feed` = an official release feed opened this round as its own SOURCES row plus the version its anchor names, or `rendered-quote` = unversioned live docs whose quote must still locate in a fresh fetch under `rendered-text-v1`); `--observe` only after a fired clock is re-verified, to write a dated receipt | reading an unbound or unobserved `on-release` row as checked; re-pinning a version or quote to silence a fired clock; judging a feed from memory or a cached copy when no SOURCES row was opened this round; fetching with auth headers or cookies | `RELEASE_CLOCK: CLEAN (on_release=N bound=N unbound=0 observed=N fired=K)` exit 0; any other exit names the failing row on its own line — the non-zero exit codes are NOT specified in round-25.md, so the C3 owner must record them before this row is treated as final |
```

## Proposed `corpus/self-counts.tsv` rows (for the C1 owner; column order to match C1's header)

These bind the two SKILL.md:46 placeholders above to the live sources. They are not written to any lane file by this report.

```
SKILL-46-STAMPS	SKILL.md	\(([0-9]+) stamps	ledger:R12-03
SKILL-46-CLAIMS	SKILL.md	\+ ([0-9]+) claims	rows:corpus/claim-ledger.tsv
```

Checks for the C1 owner before adopting:
- Each regex must match exactly one line in SKILL.md (`grep -c` the regex; `\(([0-9]+) stamps` should be unique — `grep -n` shows row 46 only today, not run).
- `ledger:R12-03` extracts from the last non-empty line `83`; its declared regex is `^([0-9]+)$`.
- `rows:corpus/claim-ledger.tsv` counts non-blank, non-`#` lines = 61 (measured read-only).

## Findings

- F1 (calibration): `SKILL.md:46` says 63/39; live read-only measures are 83/61. Stale today, as the plan states.
- F2 (ambiguity to resolve, not hidden): placeholders in the draft cannot be bound by self-counts until filled with live values; a literal `<STAMPS>` in the doc makes the row UNLOCATED. Integrator must fill and then run `self-counts.py` once.
- F3 (freshness gap): the `release-clock.py` non-zero exit codes are unspecified in the plan; Row B says so instead of inventing them.
- F4: `R12-03` pins `^83$`; any future stamp change turns R12-03 red as well as the new row. That is a design coupling, noted for the C1 owner, not changed here.

## Out of scope

- No edit to SKILL.md, corpus/*, plans/*, or the ledger.
- No `verify`/`cells` run on the lane tree; no network fetch; no credential or vault action.
- Not run: `--selftest` for self-counts/release-clock (scripts do not exist yet).
