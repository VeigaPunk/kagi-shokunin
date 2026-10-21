# RSpotcheckDebt — round-21..24 routed debt, status at BASE

Answer: C1 closes R24-D1 (once SKILL.md:46 is re-bound); C1 closes the new SKILL.md:243 finding only if the planner adds that row (see I). C2 closes R24-D2 (makes the lone-clone outcome explicit, exit stays 1); C3 closes P1 only. Every other item below is open, operator/process-owned, or a declared bound, and C1–C3 do not close it.
Seat KagiR25.RSpotcheckDebt-2 (leaf, read-only). BASE 4587c61a348e4528717404a68912c373f3ef4d03. Evidence = sandbox clone `/fast/scratch/kagi-r25/RSpotcheckDebt-2/lane` at BASE; gates run `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`. Axes: calibration (C1), operability (C2), freshness (C3).
Live tree: HEAD=BASE; untracked `.ufo/waves/round-25/`, `plans/round-25.md`, `corpus/__pycache__/`; ` M corpus/README.md` = one added line :167 (another seat's probe; BASE bytes used, live tree not edited). Installs: none. Host: existence checks only. Key: OPEN · CLOSED (checked at BASE) · OP operator-owned · PROC process · BOUND declared bound.

## A. Round-24 closure (MANIFEST `rounds[399]`, kagi lane_round 24, admitted)
| ID | Source | BASE status and evidence | C |
|---|---|---|---|
| R24-D1 | SKILL.md:46 | OPEN: says "63 stamps + 39 claims, round 21"; verify `claims=61 … stamped=83` (R12-03 expects `^83$`, claim-ledger.tsv:28) | C1 |
| R24-D2 | R11-08, claim-ledger.tsv:22 | OPEN: lone clone `citations` exit 1 `BROKEN … unresolved=88` (ufo 31, sibling 57); `verify` exit 1 `FAIL R11-08 exit-mismatch`; layout markers in code: none (case-insensitive grep layout/fleet/lone) | C2 |
| R24-P | closure notes | PROC, disclosed, not credited: watchdog "no complete line at closure"; M24-4 late census; M24-16 repairs before read-only reports; IdentR1111 live-census write (restored, re-stamped); 11 dead seats, M24-13 no replacement | none |
| R24-B | closure notes, round-24.md:191–228 | BOUND: tripwire counts invocations, not reads; gate-regression fixtures identical by construction; S005/S006 volatile request identity unproven | none |

## B. Round-23 spot-check D1–D8 (lessons/round-23-verifier-spotcheck.md:183–205; dispositions round-24.md:95–129)
| ID | Status and evidence | C |
|---|---|---|
| D1–D6, D8 | CLOSED: D1 SCORECARD.md:852; D2 SKILL.md:749, :752; D3 claim-ledger.tsv:65 R24-02 selftest PASS(14) exit 0; D4 claim-ledger.sh:110, :113, :305 + verify `HOST-SKIP R18-01` (M23-5 cured); D5 inrow-pins.tsv 16 rows, census `captures=32 inrow=16 inrow_only=0 inrow_nonreproducing=12` exit 0; D6 rendered-text-v1.py `--selftest` PASS(cases=22); D8 QUALITY.md:99 QM17 | – |
| D7 | PROC OPEN: commit wave evidence before report; no mechanical binding; round-25 wave untracked at BASE+live | none |

## C. Round-22 spot-check D1–D9 (lessons/round-22-verifier-spotcheck.md:163–184; registry corpus/closure-dispositions.json:49–105)
| ID | Status and evidence | C |
|---|---|---|
| D1, D4, D5, D6, D9 | CLOSED: fleet `.ufo/reports/round-23/kagi.md` has 14 `W04` lines; round-23.md contains `f4a8dd9` and "130 spawn"; final-verification.json `measured_commit` ×2; R23-01 at claim-ledger.tsv:59 | – |
| D2 | OP OPEN: fleet report names the global mise write (1 hit); `~/.config/mise/config.toml` exists (existence check only) | none |
| D3 | OPEN, unbound: verify/citations/cells refuse any positional (exit 2); docs/stamp take it as a path; no selftest case passes an id argv (claim-ledger.sh:341–343, :1476–1477); lane keeps ClaimR11X09 open (round-23.md:87–94) | none |
| D7 | PARTIAL: digests CLOSED (source-fetches.tsv 32 rows, SC_FETCH); prose OPEN: round-22.md:23 "S017–S020 added" vs :89, :124 "S017–S021"; no erratum | none (lesson outside C1) |
| D8 | OP OPEN: `/tmp/kagi-shokunin` present (`drwxr-xr-x`, Oct 20 18:30) | none |

## D. Round-21 debts (lessons/round-21-verifier-spotcheck.md:17): all CLOSED
- QA10/QM13/QM14 (QUALITY.md:71–73); E1 erratum (round-22.md:25; knowledge/feature-bound-credential-review.md present).
- 9 stamp rows justified append-only (.ufo/waves/round-22/round21-migrations.json present); five stale stamps repaired (verify `stale=0`).

## E. SCORECARD carried debt (SCORECARD.md:329–343, :860–863)
| ID | Status and evidence | C |
|---|---|---|
| host substrate (11 `[substrate]` + R18-01 `[host]`); live-gate verdicts; breadth pin `~/.config/opencode` 20→3 | OPEN, host-dependent, not re-measured (verify `host_skipped=12`; R17-01 skipped) | none |
| machine-readable supersession edges | OPEN: no tsv/json holds `supersed*`; prose only | none |
| R11-08 red at base | fleet CLOSED; lone clone OPEN (= R24-D2) | C2 |
| 16 in-row digests (12 non-reproducing, named in inrow-pins.tsv); SKIP-SELF (claim-ledger.sh:569); single-backslash (:1618); R13-01 (R24-06, claim-ledger.tsv:69 `count=29`) | CLOSED | – |

## F. Unrouted bounds and plan-identified debt
| ID | Status and evidence | C |
|---|---|---|
| U1 PATH unpinned in gates | BOUND/OPEN: 0 `PATH=` assignments in claim-ledger.sh (round-23-verifier-spotcheck.md:80–81) | none |
| U2 falsify accounting 64 items vs report 20/10/20 | OPEN, no disposition (round-23-verifier-spotcheck.md:135–138) | none |
| U3 SC_FETCH content-blind; closure digest lives in lane-writable JSON | BOUND, declared (round-23-verifier-spotcheck.md:52–54, :67–68) | none |
| U4 SHONEN `[~]` boxes; promotion | OP (round-22-verifier-spotcheck.md:160–161) | none |
| U5 round-22 four dead Haiku-429 scribes, replacement_seats 0 | PROC, no disposition (round-22-verifier-spotcheck.md:148–150) | none |
| P1 on-release rows with no release identity (plan) | OPEN: 28 rows (SOURCES.md:11–38, S005–S032); corpus/release-clock.py and .tsv ABSENT; S001–S004 carry `90d` | C3 |

## G. C1 population (calibration) and closure map
- Plan's literal rule (only LOG/lessons/SCORECARD exempt) gives before-count 5, not "≥1": SKILL.md:46; SKILL.md:243 (`97 scratch cases`; live `SELFTEST: PASS (151 cases)`; NEW, unlisted); corpus/README.md:64 (`39 rows at round 21`, live 61) and :65 (`63 rows at round 21`, live 83); SKILL.md:626–631 (Round-11 bullet: `claims=11 stamped=28`, `39 cases`). Exempt by location only: a "round N" exemption would also exempt SKILL.md:46.
- Current and matching (no action): PROVINCE.md:52 (83/61 at round 24); corpus/README.md:36–38, :41–43 (13/15/20/35/22/61); SKILL.md:36, :47, :138, :181, :619, :749, :750 (16/70/16/13/16/14/22).
- C2 makes the lone-clone outcome explicit (`INCOMPLETE … fleet_absent=88`, exit 1 stays); plan counts verified: 88 = 57 sibling + 31 ufo.
- NOT closed by C1–C3: D2, D3, D7, D8 (round-22); D7 (round-23); E host rows and supersession; U1–U5; R24-P, R24-B.

## H. Commands and exit codes (sandbox, env -i, BASE)
- `git -C <sandbox> rev-parse HEAD` → `4587c61a348e…` (0). `claim-ledger.sh citations` → `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)` (1).
- `claim-ledger.sh verify` → `CLAIM_LEDGER: FAIL (claims=61 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)` (1); `FAIL R11-08 reason=exit-mismatch exit=1 want=0`.
- `--selftest` (all exit 0): ledger PASS(151); sources-census PASS(70); closure PASS(14); rendered-text-v1 PASS(22); feature-claims PASS(12); revision-audit PASS(17); surface-census PASS(16); drift-pins PASS(13); scope-gate PASS(61).
- `sources-census.sh` (0) `SOURCES_CENSUS: CLEAN (rows=32 … captures=32 inrow=16 inrow_only=0 inrow_nonreproducing=12)`; `closure-dispositions.py` (0) `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)`.
- D3 probes (exit 2): `verify|citations|cells R18-01` → `unexpected positional argument for <mode>`; `docs R18-01` → `entries dir not found`; `stamp R18-01` → `refusing to shrink corpus/stamps.tsv` (sandbox tree unchanged, git status clean).
- UNRUN: op-ref-probe `--selftest` (SKILL.md:643, 36; op-side); surface-census and drift-pins verify (host-reading); scope-gate `--falsify`; host substrate re-measure (host-private gate forbidden).

## I. Routed to L1 (decisions; not executed here)
- C1: add SKILL.md:243 to the table; define population by location; decide corpus/README.md:64–65 and SKILL.md:626–631 (re-date or re-bind). Exempting by "round N" text would hide D1 itself.
- C3: binds 28 rows only; the 4 `90d` rows are outside C3. Round 26 candidates (not C1–C3): D3 per-mode selftest for id-shaped argv; D7 prose erratum (round-22.md:23); supersession edges; PATH pin.
