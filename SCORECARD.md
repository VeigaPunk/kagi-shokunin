# kagi-shokunin — Scorecard

Domain: secrets & vault ops (the-janitor handler, `op` credential hygiene).
Axes owned by this lane: **freshness + calibration** (`MISSION.md` fleet-2);
all six are scored here, the owned pair drives the round's axis-move.

Scoring method: a score is the strength of a *verifiable* claim about this repo,
not a feeling about the domain. Every cell carries an evidence pointer a third
party can re-run; ceilings are named in the same cell, because an unqualified
high score is the calibration failure this file exists to prevent.

## Round 9 — pre-move (repo `HEAD` `ea77bf0`, round-8 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 7 | `SKILL.md` carries a 16-row decision table, a 13-row failure table with exact texts + exits, the env-knob contract, a 15-item hygiene checklist, 25 anti-pattern bullets and a per-round falsification list; each `corpus/knowledge/*` entry opens with a `Source basis:` line (`corpus/knowledge/drift-gate.md`). Ceiling = deliberate scope: vault-side structure is unmapped, so item/field questions are unanswerable by design. | round 9 |
| coverage | 5 | `PROVINCE.md` was 6 lines and enumerated **no** surfaces (AXES names "PROVINCE.md lists every surface" as the signal); the real list lived in the `corpus/README.md` coverage map's coverage map. At HEAD the pin list held 13 paths and 4 cited host files were outside it, all present on host (`~/.agents/AGENTS.md`, the musketeer NativeMessagingHosts manifest, `xdg-data/…/opencode.log`, `opencode.db`). Round 9: `PROVINCE.md` now lists surfaces + refusals; pin list 13→15; the two `xdg-data` artifacts stay unpinned deliberately (state, and the DB has its own gate). | round 9 |
| operability | 5 | At HEAD `corpus/transcript-scan.sh` was a real gate (exit 0/1/2, counts-only, `--selftest`), while `corpus/drift-pins.sh` was a printer that exited 0 unconditionally — so the checklist item "run it first, re-read what changed" produced no verdict. Round 9 makes both gates runnable-with-verdicts (see freshness). | round 9 |
| freshness | **2** | **The drift mechanism could not detect drift.** (a) `drift-pins.sh` at HEAD stored nothing: `git show HEAD:corpus/drift-pins.sh \| grep -c baseline` → 0. (b) Only **2 of 13** pinned files had expected values in-repo (`the-janitor` `2408b0c9…57edd`, `client.py` `8179b241…ce51`), matching `PROTOCOL.md:292-298` ("pins verifiable for only 2 of 13 files"). (c) Real drift went undetected: `MODEL_ENDPOINT` L17→L19 stayed stale in 4 corpus files rounds 4→8; a README bullet stayed truncated a full round (`lessons/round-8.md` §5). (d) Overclaim on top: `SKILL.md:205`, `SKILL.md:304`, `corpus/README.md:33` said "every cited host file" while 4 cited files were unpinned. Above 0 only because rounds 7–8 re-ran live probes by hand. | round 6 (mechanism) / round 8 (last manual re-verification) |
| calibration | 4 | (a) `SHONEN.md` carried four bare `[x]` with no named non-author verifier — per `PROTOCOL.md` those count as `[~]`, so the gate was unpassed by attestation (both protocol rounds 8 and 9 named this repo). (b) No `SCORECARD.md` existed at all: six rounds of self-assessment lived only in prose. (c) The coverage map omitted 4 lesson files that exist on disk (12 lesson files vs 8 indexed rows), so unindexed entries were invisible to a reader. (d) The overclaim in (freshness d). Credit: `LOG.md` records the round-3 negative end-to-end result with exit code and names open operator decisions instead of burying them. | rounds 5–8 |
| adjacency | 8 | `PROVINCE.md` refuses out-of-domain work and names the refusal; CDP 9222 + the musketeer profile are reported to the integrator, never absorbed (`LOG.md` r5/r7, `corpus/README.md`). Round 9 adds two *documented* overlaps with named owners (`~/.agents/AGENTS.md` ↔ kotoba; the musketeer manifest ↔ kake) rather than silently pinning foreign scope. | round 9 |

## Round 9 — post-move (freshness axis-move landed, commit `round-9`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| freshness | 2 → **7** | A printer with no stored values became a gate with two committed baselines, per-symbol claim pins, and a real exit code. | `corpus/drift-baseline.tsv` (15 rows: mode/lines/sha256; 6 private files pinned by mode+lines only — hash withheld as an offline oracle per the L2 sentinel review), `corpus/drift-symbols.tsv` (19 claims: two value pins on the endpoint declarations, key-presence pins, `#10`+`shape` on `op.env`, two `#1` count pins on published handoff field names), `drift-pins.sh` verify `DRIFT_PINS: CLEAN (files=15 symbols=19)` exit 0; `--selftest` `PASS (13 cases)`; falsified-baseline copy → `DRIFT` + exit 1; malformed-`op.env`-row copy → `POLICY` + exit 1; patched-endpoint copy → `GONE` ×2 + exit 1; forced count pin → `count pin changed … refusing to pin` exit 2; hardlinked twin → `LINK … nlink 2` exit 1. Not 9 or 10: nothing runs the gate on a schedule (manual, like round 8's scan); coverage = the enumerated claims; the 6 no-hash files are content-drift-blind beyond mode/lines/count/shape; count pins are blind to a value swap at constant count; baseline freshness depends on the re-pin discipline staying a reported human act (and on the two `mv`s not being interrupted). **Same round, second finding:** re-verifying the *other* gate (`transcript-scan.sh`) showed the round-8 baseline was wrong — `LIKE` `_` is a wildcard, so `gsk_` produced 7 false HITs (now escaped; literal = 0), the shipped revision is 888 cells × 32+5 patterns not 270 × 25+5, and the two remaining HITs classify `key_shaped=0 prose=1` via the new content-free `--classify`. No material in the transcript DB. |
| operability | 5 → 7 | Both repo gates now answer with a verdict and an exit code, and each proves itself on scratch state. | `drift-pins.sh --selftest` (13 cases), `transcript-scan.sh --selftest`; checklist item 1 is now a runnable command rather than a print-out. Remaining manual: 12 of the checklist items are still operator judgement, not commands. |
| coverage | 5 → 6 | `PROVINCE.md` lists surfaces + refusals; the pin list covers 15 files, and the 2 deliberately-unpinned cited paths are named with their reason. | `PROVINCE.md` §§Surfaces/Refusals; `corpus/README.md` gaps bullet; `drift-gate.md` §Bounds. |
| calibration | 4 → 6 | `SCORECARD.md` exists (this file, graded + pointer-bearing); `SHONEN.md` regenerated to the protocol form with a named non-author verifier per box; the "every cited file" overclaim corrected in all three places; README index completed (4 missing lesson rows). | this file; `SHONEN.md`; `corpus/README.md` coverage map; round-9 overclaim sweep. |
| depth | 7 → 7 | `corpus/knowledge/drift-gate.md` adds the sourced contract (schemas, verdict table, value-vs-key-presence policy, bounds, reproduction) — depth inside the existing scope, not new scope. | `corpus/knowledge/drift-gate.md`. |
| adjacency | 8 → 8 | Contested scope now documented with owners; still reported, not ruled. | `PROVINCE.md` CDP surface; `corpus/README.md` overlap table; round-9 connector lane. |

## Round 10 — pre-move (repo `HEAD` `e64e81b`, round-9 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 7 | Unchanged from round 9: decision table, failure table, env contract, hygiene checklist, anti-patterns, falsification list; ceiling is deliberate scope (vault-side structure unmapped). | round 9 |
| coverage | **6** | `PROVINCE.md` listed surfaces but nothing verified them: no command fired on a path disappearing, changing mode, or — the round-6 vector — an *undeclared* file appearing in `$CONFIG_DIR`; the two `xdg-data` artifacts were named "mutates legitimately; not pinned". | round 9 |
| operability | 7 | Two runnable verdict gates (drift, transcript) + 12 checklist items that are still operator judgement. | round 9 |
| freshness | 7 | Drift detection real for 15 files/19 pins; surfaces and runtime state had no re-verification mechanism at all. | round 9 |
| calibration | 6 | SCORECARD exists; SHONEN carries named verifiers. Overclaims remained: SKILL's decision table implied `refs` output was redacted; `PROVINCE.md:8` attributed live census numbers to a prose pass. | rounds 5–9 |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake). | round 9 |

## Round 10 — post-move (coverage axis-move landed, commit `round-10`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| coverage | 6 → **8** | The surface claim became a gate: 35 declared rows (20 asset / 15 runtime) over the handler's config/state, the opencode layer that reaches it, evidence/custody and network-adjacent paths; 4 enumerable dirs whose undeclared children are `UNLISTED`; 21 runtime shape pins for the two `xdg-data` artifacts and the rest of the state; 10 write-side verb probes. | `bash corpus/surface-census.sh` ⇒ `SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)` exit 0; `corpus/surface-census.tsv`; `corpus/state-shape.tsv`; `corpus/knowledge/surface-census.md`. Ceilings named in that entry's §Bounds: nothing schedules the gates, enumeration is one level deep over 4 dirs, `~/.config/opencode` (20 children) / `~/.local/bin` / `~/.agents` / the chrome-profile subtree are deliberately not enumerated, and 3 of the 10 probes are `--deep` (operator present). |
| operability | 7 → **8** | A third gate with verdicts + exit codes, and the handler's write-side verbs became runnable probes instead of prose: `cdp-bridge ensure` (write + refusal path), `refs` (redaction + shape table), `run`/`refs` argument guards, `status` contract, plus `--deep` for `op run` and the `tac-register` no-replace re-run. | `--verbs` ⇒ `CLEAN (pass=7 skip=3)` exit 0, no `op` exec; `--verbs --deep` ⇒ `CLEAN (pass=10 skip=0)`, ≤25 s; `--selftest` ⇒ `SELFTEST: PASS (16 cases)`. Remaining manual: scheduling, and the 3 `--deep` probes. |
| freshness | 7 → **8** | Surfaces and runtime state are now re-verified mechanically, and the round *spent* that budget: 9 stale items the L2 reviewer found are recorded, 5 corrected in-repo (the DB-mtime bound in `handler-on-disk-state.md`, "deliberately unpinned" in `drift-gate.md` + `corpus/README.md`, the `PROVINCE.md` census caption, and this file's own coverage row). | `corpus/knowledge/handler-on-disk-state.md` §Anti-claims (content bound = log last line 2026-09-21T04:58:13Z, `max(session.time_updated)` = 2026-09-21T04:57:08Z, rows 7/39/55/238 — unchanged; file mtime 2026-09-28 is a reader effect, so shape pins use rows, not mtime); `drift-gate.md` §Bounds; `PROVINCE.md:8`. |
| calibration | 6 → **7** | Overclaims corrected and L2 attack accepted rather than absorbed: the `refs`-is-a-redactor implication became an explicit prefix-match limitation; the L2 critic's `SKIP`-fail-open (CE3) and digest-print (CE5) counterexamples were real and are fixed (`UNVERIFIED` fails the run; digest-free custody comparison); its four stale-snapshot clauses are recorded as stale with the reason; the draft data files it read are not what shipped. | `SKILL.md` decision table + anti-patterns; `corpus/lessons/round-10.md` §"The L2 critic's blockers, and what happened to each"; `SHAPE UNVERIFIED` path pinned by selftest case 10. Ceiling: the 8 cells are self-scored against third-party-published pointers, not independently scored. |
| depth | 7 → 7 | The new entry adds detail inside existing scope (schema-by-schema contract, two-pass sqlite rationale, floor policy, verdict/exit table, 11 falsifiers). | `corpus/knowledge/surface-census.md`; `corpus/knowledge/op-cli-surface.md` gains the `op run` rows and the `refs` guard analysis. |
| adjacency | 8 → 8 | The census declares only handler-reaching paths and *reports* the rest: the global `~/.config/opencode/opencode.json` ownership boundary (connector: needs an integrator ruling), `~/.agents/AGENTS.md` + its undeclared `.bak` sibling (kotoba/fleet), the musketeer profile (kake — kept presence-only, `mode = -`). | `corpus/README.md` §Known gaps (round-10 adjacency bullet); `PROVINCE.md` (the round-10 connector output was session-scoped scratch, not retained; round 11 replaced the dead citation). |

## Round 11 — pre-move (repo `HEAD` `03477c0`, round-10 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 7 | Unchanged from round 10: decision table, failure table, env contract, hygiene checklist, anti-patterns, falsification list; ceiling is deliberate scope (vault-side structure unmapped). | round 9 |
| coverage | 8 | 35 declared surface rows + 21 runtime shape pins + 10 verb probes, all with verdicts; ceilings named in `knowledge/surface-census.md` §Bounds. | round 10 |
| operability | 8 | Three runnable gates (`surface-census.sh`, `drift-pins.sh`, `transcript-scan.sh`) with verdicts + selftests; 12 checklist items still operator judgement. | round 10 |
| freshness | 8 | Host-file/symbol drift real for 15 files/19 pins; surfaces and runtime state re-verified mechanically. | round 10 |
| calibration | **7** | Round 10's 62 report claims were adjudicated **by hand** (the L2 reviewer stated 9 STALE / 4 UNCHECKABLE); two committed citations name session-scoped scratch (`SCORECARD.md:54`, `corpus/lessons/round-10.md:50`) and resolve for nobody; score cells are self-scored with prose pointers, so a reader re-derives the evidence instead of re-running it. | rounds 5–10 |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake); the round-10 connector output was session-scoped scratch and is now cited only through the README gap bullet. | round 10 |

## Round 11 — post-move (calibration axis-move landed, commit `round-11`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| calibration | 7 → **8** | A claim became a command row: 11 ledger rows (anchored expectations, exit-equality plus last-line verdict matching), revision stamps over 28 in-repo artifacts, and a citation gate that found four real defects in committed docs on first contact — then survived eight L2 lanes' counterexamples. | `bash corpus/claim-ledger.sh verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=11 stamped=28)` exit 0; `citations` ⇒ `CLEAN (cites≈505 docs=39 unresolved=0 ephemeral=0 labeled=13)` exit 0 (pre-fix: `BROKEN`, 3 unresolved + 2 ephemeral); `--selftest` ⇒ `PASS (39 cases)`; `corpus/stamps.tsv`; `corpus/knowledge/claim-ledger.md`; `corpus/lessons/round-11.md`. Ceilings: scores remain author-assigned (only the pointers are machine-checked); a stamp is a point check with no mode; `R11-06` encodes host state; nothing schedules the gate. |
| depth | 7 → 7 | The new entry adds detail inside existing scope (three schemas column by column, the last-line rule and why, five citation classes, marker rule, 10 bounds, 7 falsifiers) — detail, not new scope. | `corpus/knowledge/claim-ledger.md`. |
| coverage | 8 → 8 | Unchanged; the round's new gate covers the *docs* surface, counted under calibration, and cites the census rows for host surfaces rather than duplicating them. | `corpus/claim-ledger.sh` §Bounds item 5. |
| operability | 8 → 8 | Two more runnable subcommands (`stamp`, `citations`) and a 39-case selftest, but the checklist's 12 judgement items and the absence of scheduling are unchanged — the increment is claimed under calibration, not double-counted here. | `--selftest` 39 cases; the gate's fourth sibling verdict path (`citations`) runs in ~20 s. |
| freshness | 8 → 8 | Citations are now re-verified mechanically, which is a freshness mechanism for the corpus docs; the axis score is not re-scored because the round's *measurement* for freshness (host-file drift, surfaces, runtime shape) is unchanged. | `CITATION_GATE` on the shipped docs. |
| adjacency | 8 → 8 | The gate's checked classes *include* sibling lane repos and the main `.ufo` tree — reported as a fleet-wide citation shape (protocol D-19, 9 instances in one sibling corpus) and fixed only in kagi's own four. | `knowledge/claim-ledger.md` §Class 3; report §Adjacency. |

## Planned (next axis-move)

Post-round lowest cells are **depth (7)** and **calibration (8, capped for the
moment)**. Depth's ceiling is a deliberate scope refusal (vault-side structure
stays unmapped — mapping it would put ref paths in an artifact), so the
sharpest *reachable* move is the next calibration step named in the round-11
lesson: make each score **cell** cite the claim ids it rests on, so a reader can
re-derive the number instead of the evidence — falsifiable target: every
non-retired cell in this file carries at least one `R11-*`-style row id, and
`claim-ledger.sh verify` fails when a cited id is missing from the ledger.

## Retired

None. No axis is saturated (no cell scores 10) and none is a wrong fit for the
lane; `depth` is capped by deliberate scope rather than exhausted, so retiring
it would hide a real ceiling.
