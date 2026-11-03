# Round 30 — claims plan (FROZEN; QM29)

Frozen BASE: `f67232cd3ae682ea1fb14d447667016f2b6ed336` (round-29 verifier spot-check commit;
branch `master`, local=remote at round start). This plan and the START census receipt
(`.ufo/waves/round-30/census-start.txt`) commit ALONE, before any work commit. Corrections,
if any, are appended before the first work commit; after that the lesson carries them.

Host declaration (this round runs on the Linux/omp host again): Arch Linux; `python3` 3.14.8
(real; POSIX conventions apply); `sqlite3` present; the-janitor substrate ABSENT
(no `~/.local/bin/the-janitor`, no `~/.config/the-janitor`, no `~/.local/state/the-janitor`);
`op` 2.41.1 at `/usr/bin/op` (pacman-managed, observed read-only via `op --version` only —
no sign-in, no vault/account contact, nothing installed or provisioned). The round-29
cross-host debt (sqlite3-less selftests, `ln -s`, per-row spawn cost) is retired on this
host by observation; receipts land in the wave dir.

Round context: the round-29 verifier spot-check (`corpus/lessons/round-29-verifier-spotcheck.md`,
committed by the integrator in `f67232c`) routed defects D1–D5 to this round. The START
census (fleet `sources-census.sh validate --root … kagi`) exits 1 with E12 ×52: the fleet
parser no longer sees the Registry section because `corpus/SOURCES.md` (and `SKILL.md`,
`corpus/claim-ledger.tsv`) were silently converted LF→CRLF on the round-29 Windows host
(D5). Red-before receipts captured at BASE (committed with the instruments):
`claim-ledger.sh verify` ⇒ 13 FAIL rows + 2 POLICY rows (`first-token:python`), verdict
`CLAIM_LEDGER: POLICY`; `self-counts.py` ⇒ exit 2, six STALE cells; `checklist-run.sh
--ratio` ⇒ SETUP exit 2 (CRLF hides the checklist section); `citations` ⇒ BROKEN
unresolved=19; `revision-audit --history c2cab35` ⇒ CLEAN added=31 vs pinned 28;
`docs` ⇒ CLEAN entries=26 row_linked=23 vs pinned 25/22.

All six axes stand at 9; the last capability entered round 29 (`feed-token-agree.py`),
inside the stagnation window (3), so the nudge does NOT fire: the lowest-axis obligation
applies. All six axes are tied at 9, so any distinct axis satisfies it. The 2026-10-21
refusal boundary is binding: no claim touches feed-token derivation, token totality, or
the release-clock tokenizers. No vault/credential material anywhere.

## Claims

### C1 — calibration (owned axis; 9 → 9): self-assessment pins match observed state

The lane's committed self-assessment (ledger expectation pins, scorecard/doc number cells)
has drifted from observed repo state on this host; every drifted pin is migrated with an
old→new record and a stated reason, never by relaxing a gate to force green.

- **Scope:** migrate the count/identity expectations that moved by committed bookkeeping —
  R12-03 (stamps 91→current), R13-01 (round headings 34→current), R14-01 (docs
  entries=25/row_linked=22→current), R21-02 (registry rows=51→current numbers),
  R21-04 (ledger rows 65→current), R22-03 (revision-added 28→current), R24-05 (stamps
  identity count+sha), R24-06 (scorecard-rounds identity count+sha), R24-14 (ledger-ids
  count+sha), R24-15 (revision-added identity count+sha) — and re-host the two round-29
  policy rows R29-01/R29-02 (`python -I -B …` → `python3 -I -B …`, POSIX first-token,
  old→new recorded); correct the six routed doc cells (SC-SKILL-STAMPS, SC-SKILL-CLAIMS,
  PV-STAMPS, PV-CLAIMS, RD-STAMPS, RD-LEDGER-ROWS); record the D3 correcting note and the
  D4 deviation record in `corpus/lessons/round-30.md`. Final values are measured at the
  measured revision, not asserted now.
- **Counting command (frozen):** `python3 corpus/self-counts.py` must exit 0 with last
  line `SELF_COUNTS: CLEAN (claims=N stale=0)`, zero STALE lines; and each of the twelve
  enumerated rows re-run individually (via the ledger's own row runner semantics: the
  row's command executed, exit equality + last-line match) must pass. Before-receipts at
  BASE are the committed control (six STALE cells; FAIL/POLICY rows) — a do-nothing round
  cannot reach the after-state because the migrations are the delta.
- **Kill rule:** if any migrated expectation still fails at the measured revision, or a
  migration would require changing a gate's semantics (not its recorded value), that row
  is reported honestly as not migrated and C1 is not claimed CLEAN; no expectation is
  edited to match a broken gate.
- **Causally separable:** none of the twelve rows depends on C2's bytes (the lane census
  R21-02 runs exit 0 over CRLF today — number-only mismatch; verified at BASE).

### C2 — freshness (owned axis; 9 → 9): routed D5 byte-drift repaired and gated

Three lane files were silently converted LF→CRLF on the round-29 host; the drift was
caught by an outside verifier and by the fleet census (E12 ×52), and a round-29 gate
(R15-05) fails SETUP because its SKILL.md anchors no longer match. Repair: restore LF
byte shape, add a repo-level EOL convention (`.gitattributes`, text files `eol=lf`) so
the conversion cannot recur silently, re-stamp through the ledger's own `stamp` command.

- **Counting commands (frozen):**
  1. `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
     exits 0 (warnings allowed) — before: exit 1, E12 ×52 (committed START receipt).
  2. `grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l` (run at lane root)
     prints `0` — before: 3 files. This becomes standing ledger row R30-01.
  3. `bash corpus/checklist-run.sh --ratio` exits 0 with `CHECKLIST_RATIO: runnable=9/16
     floor=8 by_hand=7 delegated=3 direct=6` — before: SETUP exit 2.
- **Kill rule:** if the fleet census still exits non-zero after CR removal (E12 persists
  for a non-EOL reason), the EOL hypothesis is falsified — C2 honest-stops, the census
  defect is routed with the receipt, and no E12-adjacent claim is made. If `.gitattributes`
  renormalizes unrelated tracked files (labrat probe), the attribute set is narrowed to
  the converted classes or dropped and the gate row alone carries the mechanism.
- **Causally separable:** none of the three counters reads a C1-migrated value.

### C3 — coverage (9 → 9): frontier lead moved to admitted knowledge (assimilation, §10)

Theme (ONE): **secret scanning — detection versus verification**, the lane's frontier
lead since round 21 (`corpus/README.md` §Frontier; registry lead S048). Adopt 1–3
knowledge entries from the staged campaign package `merge/kagi/` (read-only source):
`secret-scanning-detection-vs-validation.md`, `betterleaks-detection-vs-validation.md`,
`trufflehog-verification-lifecycle.md`, re-grounded in-round (every cited source re-opened
this round with the declared fetch profile; Gate carries this lane's access dates and
≤25-word located quotes — the campaign's 2026-10-23 dates prove nothing here). Append only
the rows the admitted entries cite (8 staged rows S066–S073), normalized to fleet schema
(prose `recheck` cells stripped to cadences, prose preserved in the lesson Gate; no `|`
in any cell; `used-by` = exactly the admitted entries). Id collision is expected (package
built from the 51-row registry; lane now holds S052): the collision is proven nonempty in
scratch, adopted ids continue the lane S-space by document — S066→S053, S067→S054,
S068→S055, S069→S056, S070→S057, S071→S058, S072→S059, S073→S060 (map verified per
document, never arithmetic). Scratch mirror gated by `sources-census.sh validate --file`
exit 0 BEFORE any append (E03/E04 ⇒ refuse or supersede, never append past). Wave-4
quarantine-first does not bind kagi (not in the quarantine list).

- **Counting commands (frozen):**
  1. `grep -cE '^ {0,3}\|[[:space:]]*S(05[3-9]|060)[[:space:]]*\|' corpus/SOURCES.md`
     prints `8` — before: `0`.
  2. `ls corpus/knowledge/secret-scanning-detection-vs-validation.md corpus/knowledge/betterleaks-detection-vs-validation.md corpus/knowledge/trufflehog-verification-lifecycle.md`
     lists 3 files — before: none exist.
  3. `bash corpus/sources-census.sh` exits 0 `SOURCES_CENSUS: CLEAN (rows=60 …)`.
- **Kill rule:** any entry failing its per-entry gate (PROVINCE scope, QUALITY bar, or a
  re-opened source contradicting the staged quote) is refused with the reason in the
  lesson Gate; C3 measures only what actually admits. If all three refuse, C3 is rejected
  and reported `harmed`/unproven — never substituted with a thinner entry.
- **Causally separable:** touches only SOURCES.md rows, three new knowledge files, and
  their index/coverage-map rows; no C1 expectation and no C2 byte is part of its delta
  (registry row count moves are C3's own counted surface; C1's R21-02 migration is
  computed at the measured revision and is independent of whether C3 landed).

## Frontier step (§2b, not a claim)

- Census before: exit 1, E12 ×52 (receipt committed with this plan). Census after: must be
  exit 0 (C2's counter 1); the round reports both.
- Mistake mining: the D5 silent-EOL-conversion class (an outside verifier caught what no
  lane gate watched; captured-by analysis lands in `corpus/lessons/round-30.md`
  `## Mistakes` with the red-before receipts), plus any integration-time mistakes.
- Sourced claim: C3 cites only S-rows opened this round.
- SOURCES.md cell changes (used-by back-references for adopted rows) are logged old→new in
  the lesson.

## Round shape

ONE v1 wave of 15 seats under `ufo-wave-policy.json` (band 8–16): 5 executor, 2 scribe,
1 scout, 1 connector, 2 reviewer, 1 critic, 1 mutation-tester, 1 labrat, 1 sentinel —
attack share 6/15 = 40 % (≥25 %), connectors 1 (≤2). The L1 holds the canonical planner
seat (validator rejects `planner`; no bypass). Routing: the operator's run-15 map decides
role→model; never passed per-seat. Residual: none planned; any post-wave leftover check
goes into one ordinary reviewer/critic task call ≤4 seats and is counted.

## Honesty constraints

An unrun check has not passed; every after-number in the report is measured at the
committed measured revision. The full `claim-ledger.sh verify` verdict at the measured
revision is REPORTED (C1+C2's combined end-state), not claimed in advance: R11-08
(citations BROKEN unresolved=19) is triaged during integration and its fix lands under
the claim its cause requires, with the unresolved list as evidence; if a cause requires
editing a file this lane did not author (the integrator spot-check), it is routed, never
edited. No axis may be harmed; a trade is reported, never admitted.
