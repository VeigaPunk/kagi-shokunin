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
| depth | 7 | `SKILL.md` carries a 16-row decision table, a 13-row failure table with exact texts + exits, the env-knob contract, a 13-item hygiene checklist (the count `ea77bf0` actually held — this cell said 15 until round 15 corrected it; the list holds 16 now), 25 anti-pattern bullets and a per-round falsification list; each `corpus/knowledge/*` entry opens with a `Source basis:` line (`corpus/knowledge/drift-gate.md`). Ceiling = deliberate scope: vault-side structure is unmapped, so item/field questions are unanswerable by design. | round 9 |
| coverage | 5 | `PROVINCE.md` was 6 lines and enumerated **no** surfaces (AXES names "PROVINCE.md lists every surface" as the signal); the real list lived in the `corpus/README.md` coverage map's coverage map. At HEAD the pin list held 13 paths and 4 cited host files were outside it, all present on host (`~/.agents/AGENTS.md`, the musketeer NativeMessagingHosts manifest, `xdg-data/…/opencode.log`, `opencode.db`). Round 9: `PROVINCE.md` now lists surfaces + refusals; pin list 13→15; the two `xdg-data` artifacts stay unpinned deliberately (state, and the DB has its own gate). | round 9 |
| operability | 5 | At HEAD `corpus/transcript-scan.sh` was a real gate (exit 0/1/2, counts-only, `--selftest`), while `corpus/drift-pins.sh` was a printer that exited 0 unconditionally — so the checklist item "run it first, re-read what changed" produced no verdict. Round 9 makes both gates runnable-with-verdicts (see freshness). | round 9 |
| freshness | **2** | **The drift mechanism could not detect drift.** (a) `drift-pins.sh` at HEAD stored nothing: `git show HEAD:corpus/drift-pins.sh \| grep -c baseline` → 0. (b) Only **2 of 13** pinned files had expected values in-repo (`the-janitor` `2408b0c9…57edd`, `client.py` `8179b241…ce51`), matching `PROTOCOL.md:292-298` ("pins verifiable for only 2 of 13 files"). (c) Real drift went undetected: `MODEL_ENDPOINT` L17→L19 stayed stale in 4 corpus files rounds 4→8; a README bullet stayed truncated a full round (`lessons/round-8.md` §5). (d) Overclaim on top: `SKILL.md:205`, `SKILL.md:304`, `corpus/README.md:33` said "every cited host file" while 4 cited files were unpinned. Above 0 only because rounds 7–8 re-ran live probes by hand. | round 6 (mechanism) / round 8 (last manual re-verification) |
| calibration | 4 | (a) `SHONEN.md` carried four bare `[x]` with no named non-author verifier — per `PROTOCOL.md` those count as `[~]`, so the gate was unpassed by attestation (both protocol rounds 8 and 9 named this repo). (b) No `SCORECARD.md` existed at all: six rounds of self-assessment lived only in prose. (c) The coverage map omitted 4 lesson files that exist on disk (12 lesson files vs 8 indexed rows), so unindexed entries were invisible to a reader. (d) The overclaim in (freshness d). Credit: `LOG.md` records the round-3 negative end-to-end result with exit code and names open operator decisions instead of burying them. | rounds 5–8 |
| adjacency | 8 | `PROVINCE.md` refuses out-of-domain work and names the refusal; CDP 9222 + the musketeer profile are reported to the integrator, never absorbed (`LOG.md` r5/r7, `corpus/README.md`). Round 9 adds two *documented* overlaps with named owners (`~/.agents/AGENTS.md` ↔ kotoba; the musketeer manifest ↔ kake) rather than silently pinning foreign scope. | round 9 |

## Round 9 — post-move (freshness axis-move landed, commit `round-9`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| freshness | 2 → **7** | A printer with no stored values became a gate with two committed baselines, per-symbol claim pins, and a real exit code. | `corpus/drift-baseline.tsv` (15 rows: mode/lines/sha256; 6 private files pinned by mode+lines only — hash withheld as an offline oracle per the L2 sentinel review), `corpus/drift-symbols.tsv` (19 claims: two value pins on the endpoint declarations, key-presence pins, `#10`+`shape` on `op.env`, two `#1` count pins on published handoff field names), `drift-pins.sh` verify `DRIFT_PINS: CLEAN (files=15 symbols=19)` exit 0; `--selftest` `PASS (13 cases)`; falsified-baseline copy → `DRIFT` + exit 1; malformed-`op.env`-row copy → `POLICY` + exit 1; patched-endpoint copy → `GONE` ×2 + exit 1; forced count pin → `count pin changed … refusing to pin` exit 2; hardlinked twin → `LINK … nlink 2` exit 1. Not 9 or 10: nothing runs the gate on a schedule (manual, like round 8's scan); coverage = the enumerated claims; the 6 no-hash files are content-drift-blind beyond mode/lines/count/shape; count pins are blind to a value swap at constant count; baseline freshness depends on the re-pin discipline staying a reported human act (and on the two `mv`s not being interrupted). **Same round, second finding:** re-verifying the *other* gate (`transcript-scan.sh`) showed the round-8 baseline was wrong — `LIKE` `_` is a wildcard, so `gsk_` produced 7 false HITs (now escaped; literal = 0), the shipped revision is 888 cells × 32+5 patterns not 270 × 25+5, and the two remaining HITs classify `key_shaped=0 prose=1` via the new content-free `--classify`. No material in the transcript DB. |
| operability | 5 → 7 | Both repo gates now answer with a verdict and an exit code, and each proves itself on scratch state. | `drift-pins.sh --selftest` (13 cases), `transcript-scan.sh --selftest`; checklist item 1 is now a runnable command rather than a print-out. Remaining manual: 12 of the checklist items are still operator judgement, not commands. Pinned by `R11-05` + `R11-07` (the two selftests re-run today) and by `corpus/drift-pins.sh`. |
| coverage | 5 → 6 | `PROVINCE.md` lists surfaces + refusals; the pin list covers 15 files, and the 2 deliberately-unpinned cited paths are named with their reason. | `PROVINCE.md` §§Surfaces/Refusals; `corpus/README.md` gaps bullet; `drift-gate.md` §Bounds. |
| calibration | 4 → 6 | `SCORECARD.md` exists (this file, graded + pointer-bearing); `SHONEN.md` regenerated to the protocol form with a named non-author verifier per box; the "every cited file" overclaim corrected in all three places; README index completed (4 missing lesson rows). | this file; `SHONEN.md`; `corpus/README.md` coverage map; round-9 overclaim sweep. |
| depth | 7 → 7 | `corpus/knowledge/drift-gate.md` adds the sourced contract (schemas, verdict table, value-vs-key-presence policy, bounds, reproduction) — depth inside the existing scope, not new scope. | `corpus/knowledge/drift-gate.md`. |
| adjacency | 8 → 8 | Contested scope now documented with owners; still reported, not ruled. | `PROVINCE.md` CDP surface; `corpus/README.md` overlap table; round-9 connector lane. |

## Round 10 — pre-move (repo `HEAD` `e64e81b`, round-9 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 7 | Unchanged from round 9: decision table, failure table, env contract, hygiene checklist, anti-patterns, falsification list; ceiling is deliberate scope (vault-side structure unmapped). Pointer: the tables live in the stamped `SKILL.md`, the refusal in the stamped `PROVINCE.md` — no command counts them. | round 9 |
| coverage | **6** | `PROVINCE.md` listed surfaces but nothing verified them: no command fired on a path disappearing, changing mode, or — the round-6 vector — an *undeclared* file appearing in `$CONFIG_DIR`; the two `xdg-data` artifacts were named "mutates legitimately; not pinned". | round 9 |
| operability | 7 | Two runnable verdict gates (drift, transcript) + the checklist's judgement items then unmeasured (this cell said 12; at that revision the list held 14 items and ≥3 of them already named a live gate — corrected in round 15). Pinned by `R11-04` (drift verify) + `R11-07` (transcript selftest). | round 9 |
| freshness | 7 | Drift detection real for 15 files/19 pins; surfaces and runtime state had no re-verification mechanism at all. Pinned by `R11-04` (drift) + `R11-01` (the surface re-verification this cell says was missing). | round 9 |
| calibration | 6 | SCORECARD exists; SHONEN carries named verifiers. Overclaims remained: SKILL's decision table implied `refs` output was redacted; `PROVINCE.md:8` attributed live census numbers to a prose pass. | rounds 5–9 |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake). Pointer: the overlap table is in the stamped `corpus/README.md` + `PROVINCE.md` (the host file itself is not a repo artifact). | round 9 |

## Round 10 — post-move (coverage axis-move landed, commit `round-10`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| coverage | 6 → **8** | The surface claim became a gate: 35 declared rows (20 asset / 15 runtime) over the handler's config/state, the opencode layer that reaches it, evidence/custody and network-adjacent paths; 4 enumerable dirs whose undeclared children are `UNLISTED`; 21 runtime shape pins for the two `xdg-data` artifacts and the rest of the state; 10 write-side verb probes. | `bash corpus/surface-census.sh` ⇒ `SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)` exit 0; `corpus/surface-census.tsv`; `corpus/state-shape.tsv`; `corpus/knowledge/surface-census.md`. Ceilings named in that entry's §Bounds: nothing schedules the gates, enumeration is one level deep over 4 dirs, `~/.config/opencode` (20 children) / `~/.local/bin` / `~/.agents` / the chrome-profile subtree are deliberately not enumerated, and 3 of the 10 probes are `--deep` (operator present). Cell pointer added in round 14: `R11-01`, the row that re-runs the command this cell already quotes. |
| operability | 7 → **8** | A third gate with verdicts + exit codes, and the handler's write-side verbs became runnable probes instead of prose: `cdp-bridge ensure` (write + refusal path), `refs` (redaction + shape table), `run`/`refs` argument guards, `status` contract, plus `--deep` for `op run` and the `tac-register` no-replace re-run. | `--verbs` ⇒ `CLEAN (pass=7 skip=3)` exit 0, no `op` exec; `--verbs --deep` ⇒ `CLEAN (pass=10 skip=0)`, ≤25 s; `--selftest` ⇒ `SELFTEST: PASS (16 cases)`. Remaining manual: scheduling, and the 3 `--deep` probes. Pinned by `R11-02` + `R11-03`. |
| freshness | 7 → **8** | Surfaces and runtime state are now re-verified mechanically, and the round *spent* that budget: 9 stale items the L2 reviewer found are recorded, 5 corrected in-repo (the DB-mtime bound in `handler-on-disk-state.md`, "deliberately unpinned" in `drift-gate.md` + `corpus/README.md`, the `PROVINCE.md` census caption, and this file's own coverage row). | `corpus/knowledge/handler-on-disk-state.md` §Anti-claims (content bound = log last line 2026-09-21T04:58:13Z, `max(session.time_updated)` = 2026-09-21T04:57:08Z, rows 7/39/55/238 — unchanged; file mtime 2026-09-28 is a reader effect, so shape pins use rows, not mtime); `drift-gate.md` §Bounds; `PROVINCE.md:8`. |
| calibration | 6 → **7** | Overclaims corrected and L2 attack accepted rather than absorbed: the `refs`-is-a-redactor implication became an explicit prefix-match limitation; the L2 critic's `SKIP`-fail-open (CE3) and digest-print (CE5) counterexamples were real and are fixed (`UNVERIFIED` fails the run; digest-free custody comparison); its four stale-snapshot clauses are recorded as stale with the reason; the draft data files it read are not what shipped. | `SKILL.md` decision table + anti-patterns; `corpus/lessons/round-10.md` §"The L2 critic's blockers, and what happened to each"; `SHAPE UNVERIFIED` path pinned by selftest case 10. Ceiling: the 8 cells are self-scored against third-party-published pointers, not independently scored. Cell pointer added in round 14: `R11-03`, the case-count row for the selftest that contains case 10. |
| depth | 7 → 7 | The new entry adds detail inside existing scope (schema-by-schema contract, two-pass sqlite rationale, floor policy, verdict/exit table, 11 falsifiers). | `corpus/knowledge/surface-census.md`; `corpus/knowledge/op-cli-surface.md` gains the `op run` rows and the `refs` guard analysis. |
| adjacency | 8 → 8 | The census declares only handler-reaching paths and *reports* the rest: the global `~/.config/opencode/opencode.json` ownership boundary (connector: needs an integrator ruling), `~/.agents/AGENTS.md` + its undeclared `.bak` sibling (kotoba/fleet), the musketeer profile (kake — kept presence-only, `mode = -`). | `corpus/README.md` §Known gaps (round-10 adjacency bullet); `PROVINCE.md` (the round-10 connector output was session-scoped scratch, not retained; round 11 replaced the dead citation). |

## Round 11 — pre-move (repo `HEAD` `03477c0`, round-10 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 7 | Unchanged from round 10: decision table, failure table, env contract, hygiene checklist, anti-patterns, falsification list; ceiling is deliberate scope (vault-side structure unmapped). Pointer: stamped `SKILL.md` + `PROVINCE.md`, no counting command. | round 9 |
| coverage | 8 | 35 declared surface rows + 22 runtime shape pins + 10 verb probes, all with verdicts; ceilings named in `knowledge/surface-census.md` §Bounds. (This cell said 21 shape pins when written — the pin count was already 22, per `R11-10`; corrected in round 13.) Pinned by `R11-01`, `R11-10`, `R11-11`. | round 10 |
| operability | 8 | Three runnable gates (`surface-census.sh`, `drift-pins.sh`, `transcript-scan.sh`) with verdicts + selftests; the checklist's judgement items still unmeasured (this cell said 12 — corrected in round 15). Pinned by `R11-04`, `R11-06`, `R11-07`. | round 10 |
| freshness | 8 | Host-file/symbol drift real for 15 files/19 pins; surfaces and runtime state re-verified mechanically. Pinned by `R11-04`. | round 10 |
| calibration | **7** | Round 10's 62 report claims were adjudicated **by hand** (the L2 reviewer stated 9 STALE / 4 UNCHECKABLE); two committed citations name session-scoped scratch (`SCORECARD.md:54`, `corpus/lessons/round-10.md:50`) and resolve for nobody; score cells are self-scored with prose pointers, so a reader re-derives the evidence instead of re-running it. | rounds 5–10 |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake); the round-10 connector output was session-scoped scratch and is now cited only through the README gap bullet. Pointer: stamped `corpus/README.md` + `PROVINCE.md`. | round 10 |

## Round 11 — post-move (calibration axis-move landed, commit `round-11`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| calibration | 7 → **8** | A claim became a command row: 11 ledger rows (anchored expectations, exit-equality plus last-line verdict matching), revision stamps over 28 in-repo artifacts, and a citation gate that found four real defects in committed docs on first contact — then survived eight L2 lanes' counterexamples. | `bash corpus/claim-ledger.sh verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=11 stamped=28)` exit 0; `citations` ⇒ `CLEAN (cites≈505 docs=39 unresolved=0 ephemeral=0 labeled=13)` exit 0 (pre-fix: `BROKEN`, 3 unresolved + 2 ephemeral); `--selftest` ⇒ `PASS (39 cases)`; `corpus/stamps.tsv`; `corpus/knowledge/claim-ledger.md`; `corpus/lessons/round-11.md`. Ceilings: scores remain author-assigned (only the pointers are machine-checked); a stamp is a point check with no mode; `R11-06` encodes host state; nothing schedules the gate. |
| depth | 7 → 7 | The new entry adds detail inside existing scope (three schemas column by column, the last-line rule and why, five citation classes, marker rule, 10 bounds, 7 falsifiers) — detail, not new scope. | `corpus/knowledge/claim-ledger.md`. |
| coverage | 8 → 8 | Unchanged; the round's new gate covers the *docs* surface, counted under calibration, and cites the census rows for host surfaces rather than duplicating them. | `corpus/claim-ledger.sh` §Bounds item 5. |
| operability | 8 → 8 | Two more runnable subcommands (`stamp`, `citations`) and a 39-case selftest, but the checklist's 12 judgement items and the absence of scheduling are unchanged — the increment is claimed under calibration, not double-counted here. | `--selftest` was 39 cases at landing; `R11-09` pins the current count. The gate's fourth sibling verdict path (`citations`) runs in ~20 s. |
| freshness | 8 → 8 | Citations are now re-verified mechanically, which is a freshness mechanism for the corpus docs; the axis score is not re-scored because the round's *measurement* for freshness (host-file drift, surfaces, runtime shape) is unchanged. | `CITATION_GATE` on the shipped docs, re-run by `R11-08`. |
| adjacency | 8 → 8 | The gate's checked classes *include* sibling lane repos and the main `.ufo` tree — reported as a fleet-wide citation shape (protocol D-19, 9 instances in one sibling corpus) and fixed only in kagi's own four. | `corpus/knowledge/claim-ledger.md` §Class 3; `corpus/lessons/round-11.md`; report §Adjacency. |

## Round 12 — pre-move (repo `HEAD` `301b9ec`, round-11 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | **7** | Unchanged from round 11: decision table, failure table, env contract, hygiene checklist, anti-patterns, falsification list. The recorded ceiling was "vault-side structure stays unmapped — a deliberate scope refusal". **That reading was wrong, and this round falsified it** (see post-move): the unmapped surface was not vault-side structure but the *other half of `op.env` consumption* — the dotenv parser `cmd_run` execs, its divergence from `cmd_refs`'s awk, and the true scope of `op run`'s masking. All reachable with zero vault contact. Pointer: stamped `SKILL.md` + `PROVINCE.md` (no command counts the tables). | round 9 |
| coverage | 8 | 35 declared surface rows + 22 runtime shape pins + 10 verb probes; ceilings named in `knowledge/surface-census.md` §Bounds. Nothing in this round moves a *path* surface. Pinned by `R11-01`, `R11-10`, `R11-11`. | round 10 |
| operability | 8 | Three runnable gates with verdicts + selftests; the checklist's judgement items still unmeasured (this cell said 12 — corrected in round 15); nothing schedules them. Pinned by `R11-01`, `R11-04`, `R11-06`. | round 10 |
| freshness | 8 | Host-file/symbol drift real for 15 files/19 pins; surfaces and runtime state re-verified mechanically. Pinned by `R11-04`. | round 10 |
| calibration | **8** | Round 11's gate is green, but round 11's own plan (each score cell names the claim ids it rests on) was not landed, and the depth ceiling sentence in this file was a self-assessment error — a scope refusal where the truth was "not measured yet". Two committed numbers were also stale on contact (`symbols=19`, `claims=11`). Pointer: counts re-pinned by `R12-03` and `R13-02`. | round 11 |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake). Pointer: stamped `corpus/README.md` + `PROVINCE.md` overlap tables. | round 10 |

## Round 12 — post-move (depth axis-move landed, commit `round-12`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| depth | 7 → **8** | The `op.env` contract became measured: two parsers over one file (`cmd_refs` awk vs the dotenv parser inside `op run --env-file`, which is what `cmd_run` L248 execs), the masking scope, dotenv edge semantics, precedence/union, the hard-failure class (a malformed line makes the resolver refuse the whole file while `refs` clears it) and six named error signatures — all with verdicts, zero vault contact. | `bash corpus/op-ref-probe.sh` ⇒ `OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)` exit 0 (`R12-01`); `--selftest` ⇒ `OP_REF_SELFTEST: PASS (29 cases)` (`R12-02`); `corpus/knowledge/op-ref-consumption.md` (divergence table line-shape by line-shape, §2b hard failures, masking table, §Bounds with the unmeasurable rows named); `SKILL.md` gains 3 decision rows, 3 failure rows, 4 anti-patterns, 2 checklist items and a §`op.env` consumption; the v2 revision (hard-failure class) landed after the wave's first four lanes read v1 — recorded in the report's §L2 wave. Ceiling: the vault-side refusal is *unchanged and still deliberate*; what the round proves is that it was not the binding constraint on this axis. |
| calibration | 8 → **8** (increment recorded, not re-scored) | An author self-assessment error was caught and corrected with evidence (the "depth is scope-capped" reading); four stale numbers were swept in live docs (`symbols=19→20`, `claims=11→13/14`, `stamped=28→31`, claim-ledger selftest `39→41`, genericized `docs=37`); the round's claims entered the ledger as rows (`R12-01..03`) rather than prose, per the round-11 rule. Not raised because round 11's stated next step — *every* cell naming the claim ids it rests on — is still only partially landed (this file cites `R12-*` in the depth row only). | `SCORECARD.md` §Round 12 pre-move (the wrong ceiling, quoted); `corpus/claim-ledger.tsv` (14 rows); `bash corpus/claim-ledger.sh verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=14 stamped=31)` exit 0. |
| operability | 8 → 8 | A fourth gate landed (`op-ref-probe.sh` with `--evaluate`/`--fixture`/`--selftest`), and `claim-ledger.sh` gained a real guard (`stamp` shrink refused unless `--prune`, +4 selftest cases: 43). Not re-scored: the named ceilings are unchanged — nothing schedules any gate and the checklist's judgement items remain judgement. | `bash corpus/claim-ledger.sh stamp corpus/op-ref-probe.sh` ⇒ `refusing to shrink … 'corpus/op-ref-probe.sh' is pinned and would be dropped`, exit 2 (live); `--selftest` ⇒ `PASS (43 cases)`. Cell pointer added in round 14: `R11-09`, the row that re-runs the selftest carrying the shrink-refusal cases. |
| freshness | 8 → 8 | One new symbol pin (`$HOME/.local/bin/the-janitor` L248 `exec op run --env-file="$ENV_FILE" -- "$@"`) monitors the masking premise, and the probe turns the whole `op`-behaviour contract into a drift verdict. Not re-scored: the round's freshness *measurement* (host-file drift, surfaces, runtime shape) is unchanged and no new drift was found. | `bash corpus/drift-pins.sh` ⇒ `DRIFT_PINS: CLEAN (files=15 symbols=20)` exit 0. Cell pointer added in round 14: `R11-04`. |
| coverage | 8 → 8 | The entry maps a *behaviour* surface (parse classes, error paths), not a path surface; the census declaration is untouched and nothing new is claimed about which files exist. | `bash corpus/surface-census.sh` ⇒ `CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)` exit 0. Cell pointer added in round 14: `R11-01`. |
| adjacency | 8 → 8 | The `op`-surface overlap question is reported, not absorbed: the connector lane maps sibling verifiers (kumitate `cite-check.mjs`, kotoba `verifiers/*.py`, kengaku `grader.py`, kasegi `ops/claim-check.mjs`) and the shared-contract question stays with the integrator. | round-12 report §Adjacency; `corpus/README.md` overlap table unchanged. |

## Round 13 — pre-move (repo `HEAD` `4391b3b` + the uncommitted round-12 set; script stamped `1efb8b6d…`)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | The `op.env` two-parser contract, masking scope and hard-failure class measured with verdicts; ceiling unchanged (masking of *ref-resolved* values is unmeasurable without a resolved reference, i.e. the vault). | `R12-01` |
| coverage | 8 | 35 declared surface rows + 22 runtime shape pins + 10 verb probes, all with verdicts; ceilings named in `knowledge/surface-census.md` §Bounds. | `R11-01`, `R11-11` |
| operability | 8 | Four runnable gates with verdicts + selftests; nothing schedules them, and the checklist's judgement items remain judgement. | `R11-04`, `R11-06`, `R12-01` |
| freshness | 8 | Host-file/symbol drift real for 15 files/20 pins; surfaces and runtime state re-verified mechanically. | `R11-04`, `R12-01` |
| calibration | 8 | Round 11's gate is green but round 11's own plan was never landed: the ledger iterated rows **forward only**, so a doc citing an id that no row defines passed (`citations --docs <doc citing the fabricated R13-99>` ⇒ `CLEAN`, exit 0), and a first audit of this file found cells=48, row_pointed=3, stamp_pointed=28, **uncited=20** — reproduced independently by an L2 replica, an L2 python census, and an L2 implementation of the same rule. | `corpus/lessons/round-13.md`; `R12-03` |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake). | `corpus/README.md` |

## Round 13 — post-move (calibration axis-move landed, commit `round-13`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| calibration | 8 → **9** | A citation became a resolvable object, and a score became a re-verified pointer: `verify` now fails on an id that no row defines, and a new `cells` mode requires every Round pre/post cell to carry a pointer that resolves **and still holds** — the cited claim rows are re-run through the ordinary claims machinery, the cited pinned artifacts are re-compared, and a section that lost an axis is a setup error rather than a smaller checked set. The 20 uncited cells are repaired. Ceilings are named in this same cell (below). | `CELL_AUDIT: CLEAN (cells=60 row_pointed=25 stamp_pointed=41 uncited=0 missing_ids=0 rows_run=14 row_failures=0 stale_pointers=0 self_skipped=3 orphans=0)` (`R13-03`); the 10 round sections that the audit walks are counted from outside by `R13-01`; pre-move `CELL_AUDIT: BROKEN (cells=48 row_pointed=3 stamp_pointed=28 uncited=20 …)` exit 1 (reproduced three ways); `bash corpus/claim-ledger.sh verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=17 stamped=33 ids=17 cited=17 labeled_ids=13 orphans=0)` exit 0; `--selftest` ⇒ `PASS (72 cases)` (`R11-09`, updated); `corpus/knowledge/claim-ledger.md` §§Class 4/Class 5; `corpus/lessons/round-13.md`. **Ceilings:** a pointer can be *irrelevant* to the score it sits next to (semantic relevance is not machine-checkable — the L2 critic's executed counterexample); `row_pointed` = cells resting on a re-run command, `stamp_pointed` = cells resting on a hash-pinned revision; the ledger cannot pin its own `verify` summary (nested-audit refusal, `R13-03` is the exception that proves the shape); scores remain author-assigned. |
| depth | 8 → 8 | Unchanged; the new entry adds detail *inside* existing scope (id vocabulary and word boundaries, the cell schema, the two teeth, the vacuity and completeness guards, the nesting bound, falsifiers). | `corpus/knowledge/claim-ledger.md` |
| coverage | 8 → 8 | The round moves a *documents* surface, not a path surface: the census declaration is untouched and nothing new is claimed about which files exist. | `R11-01`, `R11-11` |
| operability | 8 → 8 | A fifth mode (`cells`) with verdicts, and 16 more selftest cases (56 → 72), but the ceilings are unchanged — nothing schedules any gate and the checklist's judgement items remain judgement; the increment is claimed under calibration, not double-counted here. | `R13-03`; `R11-09` |
| freshness | 8 → 8 | Scorecard evidence is re-verified now (cited stamps are re-compared; a moved revision prints `STALE-POINTER`), which is a freshness mechanism for this file. Not re-scored: the round's freshness *measurement* (host-file drift, surfaces, runtime shape) is unchanged and found no new drift. | `R11-04`; selftest case `cells-stale-pointer` ⇒ `STALE-POINTER` + exit 1 |
| adjacency | 8 → 8 | Sibling verifiers mapped and reported: kumitate `round-gate.mjs` and kotoba `verify_corpus_integrity.py` resolve **commit** ids, kengaku `grader.py` scores predictions in a table, kasegi's checker source lives outside the sibling checkout. None implements an `R…-…` row-id or score-cell contract, so nothing is duplicated; the shared-contract question stays with the integrator. | `corpus/lessons/round-13.md`; `corpus/README.md` overlap table |

## Planned (next axis-move)

**Round-14 outcome: the target was split into its reachable and its refused half, and both were handled.**
Round 13 asked for `row_pointed` ≥ half the checked cells by adding rows for the
quantities the historical cells assert. The measurements: the critic found **0 of
the 35 row-less cells** where a *newly written* row would honestly support the
score beside it, and the pre-state scout's own census split them H/N/R =
11/19/5 (+2 borderline) — a `pre-move` cell is a snapshot of a past revision
whose only honest evidence is a revision stamp, and a narrative or ownership cell
has no command shape at all. **But 5 of those cells already quoted a live command
in their own Evidence column** at `4b8c018` (the round-10 coverage/calibration/
operability cells and two round-12 cells), so the *ratio* half was reachable
exactly at the boundary: citing the matching row ids lifts `row_pointed` 25 → 30
of 60. Round 14 cited them — `R11-01`, `R11-03`, `R11-09`, `R11-04`, `R11-01` —
and `cells` re-runs those rows now. The other half — writing rows that re-derive
*historical* numbers — stays refused as pointer inventory. That is the whole
difference between the two lane readings: 0 rows **writable**, 5 rows **already
written**. The plan's replacement floor sits where the distance is real: the
**knowledge-entry surface** (`docs`), where "declared" vs "undeclared" is 0 → 17.

Falsifiable target for the next round:

- push `by_hand` down from 3 to ≤1 without weakening the class rule — i.e. find a
  row-shaped re-verification for one of `config-layering`, `control-plane-hardening`
  or `handler-trust-boundary` (a committed script for the `opencode debug`
  resolver, or a scratch-serve matrix that exits with a verdict), and the
  `DOC_AUDIT_RATIO` line is the number that has to move.

Ceilings are named so they are not mistaken for saturations:

- **calibration** — a pointer's *relevance* to the score beside it is not
  machine-checkable (round-13 critic, executed). Round 14 extends the same
  ceiling to entries: `Reverify:` proves a link exists and the row is live, not
  that the row measures the sentences beside it, and the by-hand class is an
  explicit unverifiable set rather than proof of effort.
- **freshness** — the entry declarations are shape-checked: 17 entries carry
  exactly one valid declaration, 14 name a live row, the 3 by-hand entries carry
  a class, a unique ≥24-char reason and a revision pin. It does **not** follow
  that every sentence in an entry is re-computed — most sentences still rest on
  numbers no command re-derives, and the floor counts entries, not evidence.
- **operability** — nothing schedules the six gates; the checklist still holds
  judgement items. Reachable, but it needs a scheduling decision that touches
  host state (systemd/cron), i.e. operator scope, so it is not a lane-only move.
- **depth** — the remaining increments are the ones the entry's §Bounds refuses
  (masking of *ref-resolved* values, the mask token, `op inject`/`op read`
  execution), each of which needs a resolved reference, i.e. the vault. Depth is
  capped by refusal, not by exhaustion — round 12 showed that this exact sentence
  is worth re-measuring before trusting it.

**Round-15 note (added at the round-15 close):** this block's target — push
`by_hand` down from 3 to ≤1 and move `DOC_AUDIT_RATIO` — was **not taken** in
round 15, because the lane rule is "pick the lowest-scoring axis" and freshness
stood at 9 while operability stood at 8 with a lane-reachable ceiling. The
target stays open and unclaimed; `DOC_AUDIT_RATIO: … by_hand=3` is its number
today (row `R14-01`). See §Round 15 for the move that was taken and the reason.

## Round 14 — pre-move (repo `HEAD` `4b8c018`, round-13 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | The `op.env` two-parser contract, masking scope and hard-failure class measured with verdicts; ceiling unchanged (masking of *ref-resolved* values is unmeasurable without a resolved reference, i.e. the vault). | `R12-01` |
| coverage | 8 | 35 declared surface rows + 22 runtime shape pins + 10 verb probes, all with verdicts; ceilings named in `knowledge/surface-census.md` §Bounds. | `R11-01`, `R11-11` |
| operability | 8 | Five modes with verdicts + selftests; nothing schedules them, and the checklist's judgement items remain judgement. | `R11-04`, `R11-06` |
| freshness | **8** | **The knowledge surface had no re-verification link.** At `4b8c018`: 1 of 17 `corpus/knowledge/*.md` entries named any claim row (`claim-ledger.md`), **0 declared one**, and **10 of 17 were not in `corpus/stamps.tsv`** — an entry could carry any host-fact base and no command could tell. Reproduced three ways at the frozen revision (L1 census; the pre-state scout's python census; the drafter's `grep -c '^Reverify:'` ⇒ 0). | `corpus/lessons/round-14.md` |
| calibration | 9 | The round-13 plan (`row_pointed` ≥ half the cells) was the declared next move and was never measured; the pre-state summary is `cells=60 row_pointed=25 stamp_pointed=41 uncited=0`. | `R13-03` |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake); the connector lane maps sibling doc-linkage verifiers (kotoba checklist + corpus index, kumitate `proxy-check.mjs` coverage score, kasegi `anchorcheck.py` anchors) as *adjacent*, none duplicate. | `corpus/README.md` |

## Round 14 — post-move (freshness axis-move landed, commit `round-14`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| freshness | 8 → **9** | Every knowledge entry declares how its host-fact base is re-verified, and every one is revision-pinned: **14 row-linked / 3 by-hand / 17 pinned** (from 0 declared / 1 naming any row / 7 pinned), audited by a sixth mode that `verify` runs, so the link cannot silently disappear. The 3 by-hand entries are the explicit unverifiable set (`control-plane-scratch` ×2, `opencode-internal` ×1) with unique ≥24-char reasons. | `R14-01`; `R11-09` (94 cases); `corpus/knowledge/claim-ledger.md` §Class 6, bounds 17–23 |
| calibration | 9 → 9 (increment recorded, not re-scored) | The round-13 target was **split by measurement**: the ratio half was boundary-reachable — 5 row-less cells already quoted a live command in their own Evidence, so citing the matching row ids (landed here) lifts `row_pointed` 25 → 30 of 60 — while the half that asked for rows re-deriving *historical* numbers stays refused (critic: 0 writable; scout census: 11 H / 19 N / 5 R + 2 borderline = pointer inventory). The replacement floor landed on the entry surface, where the gap is real (0 → 17 declared; floor `ceil(17/2)=9`). Three of my draft entry→row links were **rejected with evidence** and replaced rather than shipped. Not raised because pointer *relevance* remains unverifiable — the same ceiling round 13 named. | `R14-01`; the H/N/R census, the five cited cells and the rejected links in `corpus/lessons/round-14.md` |
| operability | 8 → 8 | A sixth mode (`docs`) with verdicts, exit codes and 22 more selftest cases (72 → 94); the ceilings are unchanged — nothing schedules any gate and the checklist's judgement items remain judgement. The increment is claimed under freshness, not double-counted here. | `R11-09` |
| depth | 8 → 8 | §Class 6 adds detail inside existing scope (grammar by form, the closed class set, the floor expression, membership-vs-freshness split, seven bounds). | `corpus/knowledge/claim-ledger.md` |
| coverage | 8 → 8 | The round moves a *documents* surface, not a path surface: the census declaration is untouched and nothing new is claimed about which files exist. What it adds is that the 17 entries are now counted at all. | `R11-01`, `R11-11` |
| adjacency | 8 → 8 | Sibling overlap reported, not absorbed: kotoba's `verify_skill_checklist.py` links checklist boxes to dispositions, kumitate `proxy-check.mjs` computes a documentation-coverage score, kasegi `anchorcheck.py` resolves `path:line` anchors — all *adjacent* (different unit, no claim-row binding); the shared-contract question stays with the integrator. | `corpus/README.md`; `corpus/lessons/round-14.md` |

## Round 15 — pre-move (repo `HEAD` `2486643`, round-14 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | Unchanged from round 12: the `op.env` two-parser contract, masking scope and hard-failure class measured with verdicts; ceiling unchanged (masking of *ref-resolved* values needs a resolved reference, i.e. the vault). | `R12-01` |
| coverage | 8 | 35 declared surface rows + 22 runtime shape pins + 10 verb probes, all with verdicts; ceilings named in `knowledge/surface-census.md` §Bounds. | `R11-01`, `R11-11` |
| operability | **8** | **The checklist was prose and its judgement count was an assertion.** At `2486643`: 16 `- [ ]` items in `SKILL.md` §Credential-hygiene checklist and **0** verdicts (`ls corpus/checklist*` ⇒ nothing; `grep -rl 'hygiene checklist' corpus/*.sh` ⇒ nothing); 5 items named a command, none produced an outcome; the "12 items are still operator judgement" figure in this file (rounds 9–11 cells) was wrong at every revision it appears in (the list held 14 items then, and ≥3 items already named a live gate). Reproduced by two lanes (item census; `bash corpus/checklist-run.sh` did not exist). | `corpus/lessons/round-15.md` (stamped) |
| freshness | 9 | Every knowledge entry declares its re-verification and is revision-pinned; the round-14 link cannot silently disappear (`docs` mode inside `verify`). | `R14-01` |
| calibration | 9 | The scorecard audit is green and every checked cell points at something that still holds; the `verify` summary itself remains unpinnable (stated bound). | `R13-03` |
| adjacency | 8 | Contested scope documented with owners (`~/.agents/AGENTS.md` ↔ kotoba; musketeer profile ↔ kake). | `corpus/README.md` (stamped) |

## Round 15 — post-move (operability axis-move landed, commit `round-15`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| operability | 8 → **9** | The checklist became an executed declaration: 16 rows (9 runnable / 7 by-hand), a gate-enforced `lead` bijection over the items, a `by-hand` class with a unique reason, a ratio line split into `delegated`/`direct`, a policy deny-list, and 34 selftest cases. The "run the checklist" instruction now produces a verdict, and adding an item without a row fails closed. | `R15-01` (`CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7 failed=0)`), `R15-02` (34 cases), `R15-03` (`rows=16 runnable=9 by_hand=7`), `R15-04` (16 declaration rows vs the 16 items), `R15-05` (`runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`); `corpus/knowledge/checklist-execution.md`. Ceilings, named in the same cell: **nothing schedules this gate or any other** (`systemctl --user list-timers`, `crontab -l`, cron dirs/spools: no entry for any `corpus/*.sh` — labrat lane, read-only), and 7 duties stay by-hand (4 authoring-duty, 1 each runtime-behavior, manual-change, cross-lane). The increment claimed is "each item produces a verdict or a declared gap", not scheduling. |
| calibration | 9 → 9 (increment recorded, not re-scored) | Three stale or wrong figures in this file were corrected with measurement (`SCORECARD.md:16` said "15-item" where `ea77bf0` held 13 and the list holds 16; the three rounds-9–11 operability cells' "12 items are still operator judgement"), and the round's claims entered the ledger as five rows rather than prose. The wave's counterexamples are recorded rather than smoothed: a 16-row constant-`printf` TSV passes `CLEAN (runnable=16/16)` (so the ratio measures declaration shape, not semantic strength — bound 11), a `check` grepping an unanchored pattern can be satisfied by a comment (H1 is now line-anchored), `E5`'s delegated probe execs `op run` (declared on the row; the stricter reading is `8/8`, exactly the floor), and the planner lane's duty-vs-premise criterion yields `3/13`. Not raised because a pointer's *relevance* stays unverifiable and the `note` column that makes the 9 honest is not gate-enforceable. | `R13-03`; `R15-01`; `corpus/lessons/round-15.md` §3–§4. |
| depth | 8 → 8 | The new entry adds detail inside existing scope (8-column schema, verdict/exit table, delegation map, 12 bounds, 10 falsifiers) — detail, not new scope. | `corpus/knowledge/checklist-execution.md` |
| coverage | 8 → 8 | The round moves a *documents/behaviour* surface, not a path surface: the census declaration is untouched and nothing new is claimed about which host files exist. What it adds is that the checklist's own items are counted and executed. | `R11-01`, `R11-11` |
| freshness | 9 → 9 | A drift-detectable surface for the checklist's premises now exists (16 rows re-run on demand, with pinned verdict lines and counts), and the gate spent that budget on first contact: 5 placeholder literals found, 2 host facts unpinned, 1 false-defect class fixed. Not re-scored: the lane's freshness *measurement* (host-file drift, surfaces, runtime shape) is unchanged and `DRIFT_PINS: CLEAN (files=15 symbols=20)` still holds. | `R11-04`; `R15-01` |
| adjacency | 8 → 8 | Sibling verifiers mapped and reported, not absorbed: kotoba's `verify_skill_checklist.py` (checklist box → disposition, predicates inspect the file rather than execute the item's command), kumitate's doc-coverage score, kasegi's `anchorcheck.py` (prints findings but exits 0). None implements an item → command → verdict contract, so this is adjacent; the shared shape (a stable-ID outcome ledger) is reported to the integrator. | `corpus/README.md` (stamped); `corpus/lessons/round-15.md` §4 |

## Round 16 — pre-move (repo `HEAD` `587fda0`, round-15 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | Unchanged from round 12: the `op.env` two-parser contract, masking scope and hard-failure class measured with verdicts; ceiling unchanged (masking of *ref-resolved* values needs a resolved reference, i.e. the vault). | `R12-01` |
| coverage | 8 | 35 declared surface rows + 22 runtime shape pins + 10 verb probes, all with verdicts; ceilings named in `knowledge/surface-census.md` §Bounds. | `R11-01`, `R11-11` |
| operability | 9 | The checklist is an executed declaration (16 rows, 9 runnable / 7 by-hand, bijection over the items); nothing schedules any gate and the 7 by-hand duties remain by-hand. | `R15-01`, `R15-05` |
| freshness | 9 | Every knowledge entry declares its re-verification and is revision-pinned; the round-14 link cannot silently disappear (`docs` mode inside `verify`). | `R14-01` |
| calibration | 9 | The scorecard audit is green and every checked cell points at something that still holds; the `verify` summary itself remains unpinnable (stated bound). One committed mechanism claim was wrong and is corrected this round. | `R13-03` |
| adjacency | **8** | **Ownership was prose.** Three places only — the `corpus/README.md` overlap table, `PROVINCE.md:34`/`:44`, one `mode = -` census row — and nothing could falsify any of them: no gate read an owner, a claim or a basis. One of the three was **stale on the live host**: `README.md:76` cited `kake-shokunin/SKILL.md:104-107` for the musketeer lease, and that slice matches `musketeer` 0 times (the claim is at `:161`). Adjacency was also the only 8 with **no** mechanical support — every other axis has a gate. | round 10 |

## Round 16 — post-move (adjacency axis-move landed, commit `round-16`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| adjacency | 8 → **9** | The census got an ownership partition with a gate: 5 `# own` prefixes (27 of 35 rows), 4 group rows covering the other 8 with owner / status / claim / basis+token, 8 `# no-enumerate` declarations — and R1–R11 fail closed on an uncovered shared row, a group covering nothing, a vocabulary outside the **literal** sets, an owner/basis lane mismatch, a basis that does not resolve, escapes its root or matches no token (the `README.md:76` decay, now a verdict), a contested row drifted to a mode claim, a `# scan` outside the ownership, an owned row resolving out of the set, a shared row resolving in, an unresolvable path, a meaningless `# no-enumerate`, and an `# own` prefix that names no declared surface. The prose places are now rows a command re-reads. | `R16-01` (`ADJACENCY_SCOPE: CLEAN (census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0)`, exit 0, ~0.5 s), `R16-02` (43 selftest cases), `R16-03` (9/9 mutations on the shipped pair), `R16-04`/`R16-05`/`R16-06` (outside counts: 5 prefixes, 4 groups, 8 no-enumerate); `corpus/knowledge/adjacency-scope.md`. Ceilings, named in the same entry's §Bounds: ownership truth is a governance fact (an *invented* foreign row + group with a token-matching basis still passes — critic CE-A1), `token` is a floor not a relevance proof (the NMH row's first basis matched a launcher line), the grammar cannot cite the integrator tree, the `note` column is checked by nobody, and nothing schedules any gate |
| calibration | 9 → 9 (increment recorded, not re-scored) | A committed **mechanism** claim from round 15 was falsified and corrected in place (`uniq -d` on empty input exits 0 on this host, not 1 — the round-15 lesson's attribution pointed a future fix at the wrong line), and the round's claims entered the ledger as six rows rather than prose. Not raised because pointer *relevance* remains unverifiable (round-13 ceiling) and every cell here is still self-scored | `corpus/lessons/round-15.md` §Corrigendum; `corpus/lessons/round-16.md` §6; `corpus/claim-ledger.tsv` (29 rows) |
| depth | 8 → 8 | The new entry adds detail inside existing scope (7-column schema, the 11-rule table with a failing input each, verdict/exit table, 14 bounds, reproduction, 11 falsifiers) — detail, not new scope. | `corpus/knowledge/adjacency-scope.md` |
| coverage | 8 → 8 | The round moves a *documents/ownership* surface, not a path surface: the census declaration is untouched and nothing new is claimed about which host files exist. What it adds is that every census row now has a declared role. The row count stays pinned by `R11-11`. | `R11-01`, `R11-11` |
| operability | 9 → 9 | An eighth gate with four modes (`verify`/`--map`/`--selftest`/`--falsify`) and 43 selftest cases, but the ceilings are unchanged — nothing schedules any gate and the by-hand duties remain by-hand; the increment is claimed under adjacency, not double-counted here. | `R16-01`, `R16-02`, `R16-03` |
| freshness | 9 → 9 | The ownership declarations are now re-verified mechanically (every basis resolves *and* matches its token; a stale one is a verdict), which is a freshness mechanism for the overlap table. Not re-scored: the lane's freshness *measurement* (host-file drift, surfaces, runtime shape) is unchanged, and `DRIFT_PINS: CLEAN (files=15 symbols=20)` still holds. | `R11-04`, `R16-01` |

## Planned (next axis-move — round 16 close)

The round-16 close leaves **depth 8** and **coverage 8** as the lowest cells
(operability 9, freshness 9, calibration 9, adjacency 9). The lane rule is "pick
the lowest-scoring axis", so the next round chooses between the two — and the
tie should be broken by measurement, not preference, exactly as this round's was:

- **coverage candidate — the shared surfaces' breadth, counted.** The census
  declares 4 of `~/.config/opencode`'s 20 children, 2 of `~/.local/bin`'s 105, 1
  of `~/.agents`'s 4; the profile subtree's 53 children are declared only as a
  presence-only dir. Those ratios are *measured in prose* (round-16 wave) and
  nothing re-checks them. Falsifiable target: a per-group breadth declaration in
  `corpus/adjacency.tsv` re-checked on demand, printing
  `ADJACENCY_BREADTH: children=N declared=M undeclared=K` per group, with the
  four ratios pinned in a ledger row; the number that has to move is `declared`
  where a surface genuinely reaches this domain's handler, and `undeclared` must
  stay a declared, counted number rather than an assumption.
- **depth candidate — re-measure the refusal, as round 12 taught.** The standing
  sentence is "masking of *ref-resolved* values, the mask token, `op
  inject`/`op read` execution each need a resolved reference". Falsifiable
  target: find one `op.env` consumption behaviour that is measurable with **zero**
  vault contact and is not yet in `knowledge/op-ref-consumption.md` (the
  candidates are the resolver's behaviour on a *property-path-shaped* value and
  its treatment of a value that is a ref to a non-existent item — the former may
  be decidable from `op run`'s error taxonomy alone), or record the sentence as
  re-measured and unchanged with the specific probe that failed to move it.

Ceilings are named so they are not mistaken for saturations:

- **adjacency** — the gate checks that an ownership claim is *declared,
  consistent and cited*, never that it is *true* (an invented foreign row plus an
  invented group row with a token-matching basis passes: critic CE-A1); `token`
  is a floor, not a relevance proof (the first NMH basis matched a launcher
  line); the `note` column is checked by nobody; the basis grammar cannot cite
  the integrator tree (`.ufo/reports/…`); and nothing schedules the gate.
- **calibration** — pointer relevance is not machine-checkable, and both new
  scorecard sections are self-scored against third-party-runnable pointers.
- **operability / freshness** — unchanged ceilings (no scheduling; the
  freshness measurement set is the same).
- **depth / coverage** — as above; neither is exhausted, they are simply the
  cells that have not moved since round 12 / round 10.

## Round 17 — pre-move (repo `HEAD` `8a6ec16`, round-16 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | The `op.env` two-parser contract, masking scope and hard-failure class have executable evidence; ref-resolved masking and item-level reads remain deliberately unmeasured. | `R12-01` |
| coverage | **8** | The 35 census rows are partitioned, but four shared leaf directories contain 182 direct children while only 8 are represented by census rows. The observed ratios `20/4`, `105/2`, `4/1`, `53/1` exist only in round-16 prose: deleting an unknown child or adding one leaves every gate green. | round-16 plan; `R11-11` |
| operability | 9 | Eight gates run on demand; none is scheduled and seven checklist duties remain by-hand. | `R15-01`, `R15-05` |
| freshness | 9 | Host files, surfaces, runtime shape, claims, docs and ownership citations have drift verdicts; unknown shared-directory children do not. | `R11-04`, `R14-01`, `R16-01` |
| calibration | 9 | Score cells are audited and gaps are explicit; pointer relevance and score assignment remain review judgments. | `R13-03` |
| adjacency | 9 | Every census row has an owned/shared role with closed vocabularies and resolving evidence; the gate checks consistency, not truth. | `R16-01`, `corpus/knowledge/adjacency-scope.md` |

## Round 17 — post-move (coverage axis-move landed, commit `round-17`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| coverage | 8 → **9** | Four count-only `# breadth` declarations now cover every derived leaf `# no-enumerate` boundary. The gate independently derives the required set, counts direct children without emitting names, derives declared children from the census, and fails on missing/extra/aggregate/out-of-scope pins, malformed counts, live or declared drift, declared > children, unreadable dirs, whole-HOME widening, or a newly declared child beyond the pin. Live result: `required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174`. | `R17-01`, `R17-02`, `R17-03`; `corpus/knowledge/adjacency-breadth.md` |
| operability | 9 → 9 | `--breadth` is a ninth runnable gate mode; selftest grew 43 → 61 and falsification 9 → 18. Not raised: nothing schedules the gates and seven checklist rows remain by-hand. | `R16-02`, `R16-03`; `corpus/lessons/round-17.md` |
| freshness | 9 → 9 | Unknown-child cardinality now has a drift verdict, and the four live ratios were re-measured on 2026-09-29. Not raised: count-only pins cannot detect a same-cardinality identity swap. | `R17-01`; `corpus/knowledge/adjacency-breadth.md` §Bounds |
| calibration | 9 → 9 | The pre-state counterexample is closed without claiming identity coverage: the durable contract states that 174 children are undeclared/unnamed and that ownership truth, recursion, contents and same-cardinality swaps remain outside the measurement. | `corpus/knowledge/adjacency-breadth.md`; `corpus/lessons/round-17.md` |
| adjacency | 9 → 9 | Breadth strengthens the ownership map but does not adjudicate `$HOME/.config/opencode` ownership or prove a foreign owner's claim. The prior D-96 attribution was false: that ledger row concerns sibling skill discovery roots. | `corpus/knowledge/adjacency-scope.md` §The partition |
| depth | 8 → 8 | A new contract records the derivation, verdicts, privacy tradeoff, 13 bounds and 18 mutation classes. This is detail about the coverage mechanism, not a deeper vault behavior. | `corpus/knowledge/adjacency-breadth.md` |
## Round 18 — pre-move (repo `HEAD` `4e48b77`, round-17 close + HOURS.md revert)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | Unchanged from round 12: the `op.env` two-parser contract, masking scope and hard-failure class have executable evidence; ref-resolved masking and item-level reads remain deliberately unmeasured — and are now unmeasurable, the substrate being absent. | `R12-01` |
| coverage | 9 | The four breadth pins cover every derived leaf `# no-enumerate` boundary; count-only semantics are unchanged — but on the round-18 host three of the four pinned dirs are absent and the fourth (`~/.config/opencode`) shrank 20→3 children, so the live claim is carried debt, not current evidence. | `R17-01`, `R17-02` |
| operability | 9 | Eight gates run on demand; none is scheduled, seven checklist duties remain by-hand. All seven gates still execute and exit with verdicts — but six verdicts are fail-closed readings of an absent substrate, and the census selftest's verb cases could not prove themselves hermetically. | `R15-01`, `R15-05` |
| freshness | **9** | **Host-fact drift detection works — and fired correctly everywhere — but the ledger could not tell "claim failed" from "claim unmeasurable".** 11 claim rows FAILed `exit-mismatch` with zero lane-defect behind them; the census selftest failed 2/16 on a substrate-absent host despite advertising scratch-tree proof. The OMP/ufo-fsd re-census order also verified: **zero** `origin-work`/`ufo-fsd` citations exist anywhere in this repo — the stale-`--src` and deleted-file classes that block sibling lanes are vacuous here. | `corpus/lessons/round-18.md` |
| calibration | 9 | Score cells audited; the audit itself was polluted by the unmeasurable-claim class (CELL_AUDIT BROKEN row_failures=10, all substrate). | `R13-03` |
| adjacency | 9 | Partition and vocabularies still check out (the gate logic passes its 61-case selftest); the live partition verdict DEFECTs on missing surfaces and a 6-fold breadth drift — correct behavior, carried as debt. | `R16-01`, `corpus/knowledge/adjacency-scope.md` |

## Round 18 — post-move (re-census landed; substrate-deferral mechanism, commit `round-18`)

| Axis | Score | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 (mechanism landed, axis held) | An unmeasurable claim became a first-class verdict rather than a disguised failure: `substrate`-tagged claim rows `DEFER … reason=substrate-absent` (counted, never run) when `substrate_present()` fails, the summaries carry `deferred=`/`row_deferred=`, and `KAGI_SUBSTRATE=` forces either arm so the selftest proves both (cases 95–97). The census selftest's two handler-executing cases print `skip-case` instead of `bad-case`. Not raised: deferral records absence, it does not re-verify a single pinned fact — 10 rows are *carried*, not *passed*. | `knowledge/substrate-deferral.md` (entry, `Reverify: R18-01, R11-09`); `R18-01` (absence pin: `sha256sum` on the handler path, exit 1 "No such file"); `R18-02` (tag surface count); `R11-09` re-pinned 94→97 cases |
| calibration | 9 → 9 | The ledger's failure taxonomy gained a third honest outcome (deferred) so `CLAIM_LEDGER: CLEAN (claims=35 deferred=11 …)` now distinguishes "every checkable claim holds" from "10 claims are parked on an absent substrate". Superseded-revision claims keep their verbatim quotes with the round-18 errata (PROVINCE.md surfaces caption, lessons/round-18.md) — describe-don't-pin satisfied: no content hash of a missing file is asserted anywhere, the handler's last *measured* sha lives only in `drift-baseline.tsv` as the preserved record. | `R13-03`; `corpus/claim-ledger.tsv` (35 rows) |
| operability | 9 → 9 | All seven gates run bare and exit 0/1/2 with verdicts; the two hermeticity defects found by the re-census were fixed. Not raised: six live verdicts are fail-closed readings of the absent substrate, and nothing schedules any gate. | `R11-03`, `R18-03` |
| coverage | 9 → 9 | The re-census itself was the coverage act: every repo surface re-scanned for origin-tree references (zero found — a negative result that had to be measured, not assumed). The live breadth pins' substrate dependence is now declared in the ledger rather than implicit. | `R17-02`; `corpus/lessons/round-18.md` |
| adjacency | 9 → 9 | The `$HOME/.config/opencode` breadth drift (20→3 children) is measured and reported, not adjudicated; the contested surfaces' absence makes the unresolved rulings moot until substrate return. | `corpus/README.md` overlap table; `corpus/lessons/round-18.md` |
| depth | 8 → 8 | `corpus/knowledge/substrate-deferral.md` adds a named, bounded contract inside existing scope (tag grammar, detection predicate, bounds 1–5, falsifiers). | `corpus/knowledge/substrate-deferral.md` |

## Carried debt (round 18 — named, each with its unblock action)

- **Substrate absence (the debt).** Every `substrate`-tagged row
  (`R11-01/02/03/04/06`, `R12-01`, `R13-03`, `R15-01`, `R16-01/03`, `R17-01` —
  11 rows) is DEFERred, not verified. Unblock: reinstall the-janitor handler
  and its state/config tree; `substrate_present()` then un-defers all rows in
  one `verify` run and every baseline re-derives against the live surface.
- **Live-gate verdicts.** `SURFACE_CENSUS: DRIFT`, `DRIFT_PINS: DRIFT`,
  `CHECKLIST_RUN: BROKEN`, `ADJACENCY_SCOPE: DEFECT`, `transcript-scan` and
  `op-ref-probe` SETUP are *correct outputs on this host* — recorded as the
  re-census measurement, not repaired (re-pinning baselines to an empty host
  would falsify the preserved record of what the substrate was).
- **Breadth pin `~/.config/opencode` 20→3.** The one surviving shared dir
  shrank; the pin is substrate-adjacent host state. Unblock: same as above, or
  a reviewed re-pin if the shrink proves permanent.

## Planned (next axis-move — round 17 close)

Depth is now the sole lowest cell at 8; every other axis stands at 9. Re-measure
the standing vault-refusal ceiling without touching the vault: find one
`op.env` consumption behavior that a generated plain-value fixture or
error-classification probe can decide and that
`corpus/knowledge/op-ref-consumption.md` does not already cover. If no such
behavior exists, record the exact probe and unchanged ceiling rather than
claiming an increment. Ref-resolved masking, `op read`, `op inject`, item paths
and secret values remain refused.

Coverage's new ceiling is specific: count-only pins detect cardinality drift but
not same-cardinality swaps; naming all 174 foreign children would violate the
privacy posture, and recursive subtree coverage is intentionally not claimed.

## Planned (round-15 target recorded — not taken, and why)

This file's previous plan (round 14) set the next falsifiable target as
"push `by_hand` down from 3 to ≤1 ... and the `DOC_AUDIT_RATIO` line is the
number that has to move". **Round 15 did not take it.** The lane rule is
"pick the lowest-scoring axis", and at the round-14 close freshness and
calibration both stood at 9 while operability, depth, coverage and adjacency
stood at 8 — and operability's named ceiling had a lane-reachable half: the
prose checklist. `DOC_AUDIT_RATIO` still reads `by_hand=3` today (row
`R14-01`), so that target **stays open** and unclaimed.

## Planned (next axis-move — round 15 close)

Round 15 leaves the honest next target inside the same axis, because the
counterexample that limits this round is specific: the gate measures whether a
row is *well-formed and executes*, not whether its assertion is *meaningful*.
A 16-row TSV of constant `printf`s passes `CLEAN (runnable=16/16)`.

Falsifiable target for the next round:

- add a mutation mode (`--mutate`) in which every runnable row declares a
  negative fixture — a perturbation of the surface it reads — that MUST make the
  row fail; the number that has to move is a new `MUTATION: caught=K/K` line,
  and a row whose declared mutation still passes is a defect. If a row has no
  cheap perturbation, it must say so in the row (a `mutation: by-hand` cell with
  a reason), which is the same declared-gap pattern the by-hand class uses.

Ceilings are named so they are not mistaken for saturations:

- **operability** — nothing schedules the seven gates (labrat lane re-confirmed
  no cron/systemd entry touches any `corpus/*.sh`); scheduling touches host
  state, i.e. operator scope. The 7 by-hand rows are the other half, and for
  `H2`/`E6`/`H6` the contract *forbids* the only mechanisation.
- **calibration** — a pointer's relevance is not machine-checkable, and neither
  is the semantic strength of a `check` (bound 11). The `note` column carries
  the honest half and is review-only.
- **freshness** — `E4`'s ref-path sweep exempts three placeholder vault names by
  name (counted and pinned as `excluded=5 raw=5`), and `H7` accepts exactly two
  states, one of which is "the DB is legitimately gone".
- **depth** — still capped by refusal (masking of *ref-resolved* values, the
  mask token, `op inject`/`op read` execution each need a resolved reference).

## Planned (falsified in round 14 — kept as the record)

Round 13 leaves calibration at 9 — the highest cell in this file, and the move is
what makes the *other* cells auditable rather than prose. The round-11/12 target
is landed in its **enforced** form and only that form: every checked cell must
carry a pointer that resolves, and a pointer is only accepted if the thing it
points at still holds. It is **not** landed in the stronger form round 11 wrote
("*every* cell names the claim **ids** it rests on, so a reader re-derives the
number") — the audit's own summary says how far short: `row_pointed` counts cells
resting on a re-run command, `stamp_pointed` counts cells resting on a
hash-pinned revision, and the gap between them is the next move.

Falsifiable target for the next round:

- raise `row_pointed` to at least half the checked cells by adding ledger rows
  that measure the quantities the **historical** cells assert (table row counts
  in `SKILL.md`, the checklist item count, the drift/symbol counts as of their
  round), so a reader re-runs the number instead of reading a stamp — and the
  `cells` summary reports the ratio, which is what keeps this honest.

Three ceilings are named so they are not mistaken for saturations:

- **calibration** — a pointer's *relevance* to the score beside it is not
  machine-checkable; that is the L2 critic's executed counterexample, recorded
  in `corpus/lessons/round-13.md` and in this file rather than papered over. The
  ledger also cannot pin its own `verify` summary (a row that runs `verify` would
  recurse; `verify` refuses a nested self-audit).
- **operability** — nothing schedules the five gates; the checklist still holds
  judgement items. Reachable, but it needs a scheduling decision that touches
  host state (systemd/cron), i.e. operator scope, so it is not a lane-only move.
- **depth** — the remaining increments are the ones the entry's §Bounds refuses
  (masking of *ref-resolved* values, the mask token, `op inject`/`op read`
  execution), each of which needs a resolved reference, i.e. the vault. Depth is
  capped by refusal, not by exhaustion — round 12 showed that this exact sentence
  is worth re-measuring before trusting it.

## Retired

None. No axis is saturated (no cell scores 10) and none is a wrong fit for the
lane. Round 12 **corrected** the standing justification for depth's ceiling: it
was written as "vault-side structure stays unmapped — a deliberate scope
refusal", but the axis was actually held at 7 by an unmeasured, vault-free
surface (`op.env` consumption). The refusal is real and unchanged; it was simply
not what was binding. Retirement still would be wrong — a capped axis with a
*specific, falsifiable* cap is the honest record.

## Move log

| Round | Axis | Before | After | Evidence |
|---|---|---|---|---|
| 19 | freshness | measured at HEAD (see lesson) | verdicts recorded per gate, no scalar | `corpus/lessons/round-19-recensus.md` |
| 20 | depth (attempt) | 8 | 8 — blocked, increment 0 | `corpus/lessons/round-20.md` |
| 21 | depth (C1) | 8 | 9 | `R21-01`; `SCORECARD.md` §Round 21 — post-move |
| 21 | calibration (C2) | 9 | 9 — mistakes→criteria, author `[x]` 4→0 | `corpus/lessons/round-21.md` §Mistakes |
| 21 | coverage + capability (C3) | 9 | 9 — 3 entries, source-registry capability | `R21-02` |

## Round-19 correction (appended 2026-10-14) — the describe-don't-pin claim was too strong

The round-18 sentence above (":323" region) states that no content hash of a
missing file is asserted anywhere. The round-19 independent audit falsifies
that as written: `corpus/knowledge/config-layering.md:58` still states
`af8873ca…` as a current property of the absent `~/.config/the-janitor/config.json`
(the baseline deliberately withholds that hash), and the source-basis lines of
`handler-on-disk-state.md:3`, `handler-trust-boundary.md:3-6` and
`janitor-env-contract.md:3-4` still name the handler/`client.py` prefixes
`2408b0c9…` / `8179b241…`. Full 64-char hashes remain confined to
`corpus/drift-baseline.tsv`; the defect is the *current-voice assertion* in the
notes, not a leaked full hash. Named debt, owner kagi, unblock: mark those lines
historical in an append-only erratum (do not expand `af8873ca…`).

## Current baseline — round-16 re-dispatch (2026-10-15)

The driver requested round 16 after this checkout already recorded rounds
17–19. Those records are preserved; this is a new, explicitly dated execution
of the requested round, not a renumbering of their history.

The last freshness score of 9 overstates the current corpus: the round-19
correction above identifies four knowledge entries whose absent janitor
sources still lack entry-local historical status. Baseline freshness is
therefore **8**, tied with depth. Choose freshness: qualifying these four
entries is directly falsifiable without vault access; depth's remaining
ref-resolved behavior is deliberately refused.

| Axis | Current score | Evidence | Last change |
|---|---|---|---|
| depth | 8 | `corpus/knowledge/op-ref-consumption.md`; ref-resolved behavior remains refused, not newly measured. | round 12 |
| coverage | 9 | `corpus/knowledge/adjacency-breadth.md`; historical breadth evidence, not a current host-coverage pass. | round 17 |
| operability | 9 | `corpus/knowledge/checklist-execution.md`; no scheduling or live-handler success claimed. | round 15 |
| freshness | **8** | `corpus/knowledge/config-layering.md:58`, `corpus/knowledge/handler-on-disk-state.md:3`, `corpus/knowledge/handler-trust-boundary.md:3-6`, `corpus/knowledge/janitor-env-contract.md:3-4`: four unqualified historical source entries; counting command below. | round-16 re-dispatch baseline |
| calibration | 9 | `corpus/knowledge/claim-ledger.md`; pointer relevance and author-assigned scores remain review judgments. | round 13 |
| adjacency | 9 | `corpus/knowledge/adjacency-scope.md`; contested ownership remains unresolved. | round 16 historical |

**One planned move:** append scoped historical-source errata to those four
entries, preserving their original observations and abbreviated hashes.
Target: `unqualified=4 → 0`, `historical=0 → 4`, while absent sources remain
`3/3`. This flags stale claims; it does not re-verify the missing substrate.
No axis is retired or split.

Before measurement: commit `15ea78c767ec1730ff19144e5cf62c9adf54e483`,
2026-10-15; the pre-existing working-tree edit to `corpus/op-ref-probe.sh`
does not participate in this command or this move.

```bash
node -e 'const fs=require("node:fs"),os=require("node:os"),p=require("node:path");const files=["config-layering","handler-on-disk-state","handler-trust-boundary","janitor-env-contract"];const sources=[".local/bin/the-janitor",".config/the-janitor/client.py",".config/the-janitor/config.json"];const missing=sources.filter(f=>!fs.existsSync(p.join(os.homedir(),f))).length;let historical=0;for(const f of files){const text=fs.readFileSync("corpus/knowledge/"+f+".md","utf8");const qualified=/^Source-status: historical — /m.test(text);historical+=Number(qualified);console.log(f+"="+(qualified?"historical":"unqualified"));}console.log("SOURCE_FRESHNESS: entries="+files.length+" historical="+historical+" unqualified="+(files.length-historical)+" absent_sources="+missing+"/"+sources.length);'
```

Observed: `SOURCE_FRESHNESS: entries=4 historical=0 unqualified=4 absent_sources=3/3`.
The count checks explicit qualification, not the truth of the old hashes or
every sentence in the entries; scoped errata require human review as well.

## Outcome — round-16 re-dispatch (2026-10-15)

Measured revision: `f4a8dd92674e95231c50f361e8c69eb00c7e713b`
(`round-16: qualify historical janitor source claims`). The exact counting
command at line 501 was run unchanged before and after:

| Revision | Observed counting output | Exit |
|---|---|---|
| `15ea78c767ec1730ff19144e5cf62c9adf54e483` | `SOURCE_FRESHNESS: entries=4 historical=0 unqualified=4 absent_sources=3/3` | 0 |
| `f4a8dd92674e95231c50f361e8c69eb00c7e713b` | `SOURCE_FRESHNESS: entries=4 historical=4 unqualified=0 absent_sources=3/3` | 0 |

| Axis | Before → after | Verdict | Evidence / ceiling |
|---|---|---|---|
| freshness | **8 → 9** | improved | Four stale source entries now explicitly qualify original source lines, derived behavior and recipes: `corpus/knowledge/config-layering.md:111-136`, `corpus/knowledge/handler-on-disk-state.md:250-278`, `corpus/knowledge/handler-trust-boundary.md:288-317`, `corpus/knowledge/janitor-env-contract.md:92-113`. Count above plus semantic review; no missing source was re-verified. |
| depth | 8 → 8 | unchanged | No new domain behavior measured; original source bytes in all four entries are preserved. |
| coverage | 9 → 9 | unchanged | Same four existing entries; no new host/vault surface mapped. |
| operability | 9 → 9 | unchanged | No executable path or host state changed; old recipes are historical, not newly run. |
| calibration | 9 → 9 | unchanged | Scores remain author-assigned; marker coverage is not semantic truth or external promotion evidence. |
| adjacency | 9 → 9 | unchanged | No ownership ruling or sibling change; `PROVINCE.md` refusals remain in force. |

The numeric restoration to 9 is an author judgment about the corrected
four-entry debt, not a formula derived from four markers and not a claim
of corpus-wide currentness. The stronger claim is refused: three sources
remain absent, abbreviated prefixes prove no identity, and an excerpt that
omits the appended erratum can still present the old wording without its
qualification. Restoration requires authorized source/revision review and
separate re-measurement before any current-tense reuse.

Checks at the measured revision (all exit 0):

- Original byte-prefix comparison against the before revision:
  `SOURCE_PRESERVATION: preserved=4/4`.
- `bash corpus/claim-ledger.sh citations --docs 'corpus/knowledge/config-layering.md corpus/knowledge/handler-on-disk-state.md corpus/knowledge/handler-trust-boundary.md corpus/knowledge/janitor-env-contract.md'`
  → `CITATION_GATE: CLEAN (cites=10 docs=4 unresolved=0 ephemeral=0 labeled=0)`.
- `bash corpus/claim-ledger.sh docs`
  → `DOC_AUDIT: CLEAN (entries=21 row_linked=18 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`.

No live private-file gate, handler, account, vault, resolver or service was
exercised. Whole-ledger cleanliness is not claimed: inherited stamp debt
for `corpus/lessons/round-18.md` and the user-owned `corpus/op-ref-probe.sh`
edit is left untouched, not re-pinned to manufacture a clean run.

**Planned next move:** depth remains the lowest score at 8. Revisit its
standing vault-free falsifier only under a fresh steer; this round does not
absorb the inherited probe edit. No axis is retired or split.

## Round 20 — interactive attempt; blocked, not completed (2026-10-15)

The lowest LIVE axis is **depth (8)**, from the immediately preceding
dated outcome; all other axes remain 9. Choose its vault-free byte frontier,
not a repeated four-entry historical-source correction. The interrupted
launch counter 16 is not a verified-round count. Existing rounds and the
inherited round-16 outcome remain records, not renumbered executions.

Claim proposed, not admitted: byte-faithful observations can separate
trailing/newline-only/escaped/literal/multiline dotenv values that the old
line-oriented collector cannot faithfully represent. Parent ran the inherited
dirty probe against generated plain-value fixtures with op 2.40.0:
`OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0; comparator/safety selftest
`OP_REF_SELFTEST: PASS (36 cases)`, exit 0. A separate shell substitution
of `alpha` followed by two LFs emitted only hex `61 6c 70 68 61`, exit 0.
These are bounded investigation measurements, not authorship of the inherited
implementation, live-handler evidence or a completed craft round.

Measurement base: `f4a8dd92674e95231c50f361e8c69eb00c7e713b` plus the inherited
uncommitted probe SHA-256
`0f1945e8d8a8fc56aaee256180cd7badde466bc8ac91503aa1e1853e79044f4c`.
Exact commands and full outputs:
`kagi-shokunin/.ufo/round-20/inspection.json`,
`kagi-shokunin/.ufo/round-20/local-checks.json`.
The probe is intentionally excluded from this attempt's commits.

Canonical shape validation: 32 distinct scopes, spawn=32/resume=0,
exit 0; rendered but **not submitted**. Route gate:
`KAGI_ROUTE_ADMISSION: BLOCKED (roles=7 mismatched=7 missing_aliases=0 connector_fallback=missing dispatched=0)`,
exit 2. The effective global roles still select mid/fast/strong, not the
required composer/grok/antigravity aliases; the antigravity fallback is empty.
No route mutation, per-task model selector, shortened batch or substitute
dispatch is allowed. Saved plan: `kagi-shokunin/plans/wwkd-round-20-interactive.md`.

| Axis | Before → after | Verdict | Observable / limit |
|---|---|---|---|
| depth | 8 → 8 | unchanged | Byte observations retained, but authorized specialist wave unavailable; no new knowledge or implementation admitted. |
| coverage | 9 → 9 | unchanged | No new host/vault surface mapped or restored. |
| operability | 9 → 9 | unchanged | Inherited probe not landed; no handler or scheduling change. |
| freshness | 9 → 9 | unchanged | No existing host claim re-verified; no stale fact silently upgraded. |
| calibration | 9 → 9 | unchanged | Shape validation is not authorized dispatch, native judgment, promotion or completion. |
| adjacency | 9 → 9 | unchanged | No ownership ruling or sibling/source edit. |

| Learning trend | Verdict | Evidence / limit |
|---|---|---|
| expansion | unchanged | No knowledge entry admitted. |
| quality | unchanged | Bounded investigation only; prior missing-substrate and stamp debt retained. |
| discernment | unchanged | No non-author admit/reject spot-check; no agreement fabricated. |

No axis is retired or split. Verified-round increment: **0**. Prior verified
total is not reconstructed from driver launches or historical report count.
One blocked attempt does not establish three consecutive blocked rounds.
Next action is operator/integrator restoration of the required effective
role bindings and connector fallback; a fresh authorized session must recheck
them before any 32-seat submission. Missing authentic receipt bindings also
remain a blocker; Sighting completion and automatic continuation are not claimed.

## Round 21 — pre-move (repo `HEAD` `aea7a43`, round-20 attempt close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 8 | The byte arm landed unclaimed in `aea7a43`: no ledger row (`grep -c 'DOTENV_BYTES' corpus/claim-ledger.tsv` → 0), `R12-02` pinned 29 cases while the probe printed 36, no observation id in the entry (`grep -c 'DOTENV_OBS' corpus/knowledge/op-ref-consumption.md` → 0). | `R12-01`, `R12-02` |
| coverage | 9 | 21 knowledge entries (`ls corpus/knowledge/*.md` lists 21), no source registry (`test -e corpus/SOURCES.md` → 1), no `## Frontier` in the index (`grep -c '^## Frontier' corpus/README.md` → 0). | `R17-01` |
| operability | 9 | Seven gate scripts under `corpus/`, none for sources; the capabilities table held only its header and a placeholder row. | `R15-01`, `R15-05` |
| freshness | 9 | `op --version` → 2.41.0 while the only byte evidence was op 2.40.0; 0 of 21 entries carry `recheck:`. | `R11-04`, `R14-01` |
| calibration | 9 | No `corpus/QUALITY.md` (`test -e` → 1); 0 mistake classes captured by a criterion; `SHONEN.md` carried 4 author-attested `[x]` (`grep -c '^- \[x\]' SHONEN.md` → 4); `cells` refuses the scorecard since `93ab9a5`. | `R13-03` |
| adjacency | 9 | Ownership partition gated; no sibling sweep for vault-ops ground outside the host surfaces. | `R16-01` |

Declared claims (1–3, distinct axes; plan `plans/round-21.md`): **C1 depth**
(lowest of the six scores, 8; also the declared open claim of the round-20
attempt), **C2 calibration** (owned axis; freshness and calibration tie at 9,
so C2 carries the lowest-owned-axis duty), **C3 capability + coverage**.
`corpus/QUALITY.md` §Admission bar is a prerequisite contract repair written
before dispatch, not a claim: C2 appends below it and C3 reads only it.

## Round 21 — post-move (three claims, commit `round-21`)

Before numbers at `aea7a43`; after numbers at the round-21 lane commit (its
hash is cited in `LOG.md` §Round 21 close and the fleet report, since a commit
cannot carry its own hash).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| depth | 8 → **9** | C1. Byte fidelity of `op run --env-file` admitted: re-measured on op 2.41.0, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0; six `DOTENV_OBS` ids (0 → 6) with the downstream command-substitution loss measured and a decision row; `R12-02` re-pinned 29 → 36; probe stamp re-pinned to its bytes. Not 10: masking of resolved values, item reads and the absent handler stay unmeasured; reviewer limits on the instrument are carried in the entry. | `R21-01`, `R12-02`; `corpus/knowledge/op-ref-consumption.md` §11 |
| calibration | 9 → 9 | C2. Twelve own mistakes mined (M1–M12), 11 uncaptured classes each now captured by a criterion citing its lesson (captured-by `none` 12 → 1, the honest stop); admission bar QA1–QA8 created; `SHONEN.md` regenerated canonical, author `[x]` 4 → 0. Score held: these are audit facts; the outside admit/reject spot-check is pending, so discernment is not yet shown from outside. | `R14-01`; `corpus/lessons/round-21.md` §Mistakes; `corpus/QUALITY.md` |
| coverage | 9 → 9 | C3. Three entries on ground no coverage-map row held (machine-credential custody, SOPS/age rotation, Vault/OpenBao clocks; 21 → 24 entries), each citing `mined` rows; README `## Frontier` 0 → 1 and `## Known gaps` 0 → 1. Score held: documented vendor knowledge, not governed host surfaces. | `R21-02`, `R14-01`; `corpus/README.md` §Coverage map |
| operability | 9 → 9 | Capability (C3): `corpus/sources-census.sh` runs clean with a 47-case selftest (40 at `c41af82`; seven fail-open cases closed after the post-landing review). Not booked as an axis move (counted once, under C3). | `R21-02`, `R21-03` |
| freshness | 9 → 9 | The byte contract re-verified on the new op release; new entries carry `verified-at:`/`recheck:`. Not claimed: 21 legacy entries still have no `recheck:` (census `legacy=21`). | `R21-01`, `R21-02` |
| adjacency | 9 → 9 | Connector sweep over every sibling lane found no claim on the new ground; `PROVINCE.md` §Core / Frontier / Adjacent appended. Not claimed. | `R16-01`; `PROVINCE.md` |

Counting commands (run from the lane root; before at `aea7a43`, after at the round-21 commit):

- C1: `grep -c 'DOTENV_OBS' corpus/knowledge/op-ref-consumption.md` (0 → 6); `bash corpus/op-ref-probe.sh --dotenv-bytes` (last line `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0, op 2.41.0); `awk -F'\t' '$1=="R12-02"{print $3}' corpus/claim-ledger.tsv` (29 → 36 cases).
- C2: `awk -F'|' '/^\| M[0-9]/ && $6 ~ /QM/' corpus/lessons/round-21.md | wc -l` (0 → 11); `awk -F'|' '/^\| Q[AM][0-9]/' corpus/QUALITY.md | wc -l` (0 → 19); `grep -c '^- \[x\]' SHONEN.md` (4 → 0).
- C3: `bash corpus/sources-census.sh` (absent → `SOURCES_CENSUS: CLEAN (rows=16 A=14 B=0 C=2 queued=1 mined=14 rejected=1 entries_sourced=3 legacy=21)`); `ls corpus/knowledge/*.md | wc -l` (21 → 24); capability rows below 0 → 2 (the source registry under C3; the byte probe enters with C1's admission).

Trend verdicts (self-assessed, pending non-author spot-check): expansion
**improved** (three admitted entries on uncovered ground, a capability
admitted); quality **improved** (a stale count pin and an unclaimed landing
re-verified and pinned; no admitted entry failed a re-check); discernment
**unchanged** pending the outside admit/reject spot-check (criteria were added
with lessons behind each, but agreement is not self-certifiable).

No axis is retired or split.

## Round-21 correction (post-landing review of `c41af82`)

The round's reviewer and critic L2s re-opened the landed commit
(`corpus/lessons/round-21.md` §Post-landing review). Effects on the rows above,
landed in the round-21 correction commit (cited in `LOG.md`):

- **C3**: two of the three entries (machine-credential custody; Vault/OpenBao clocks) failed a re-read of their own sources on scope (eligibility omitted; product/path merged; KV "nothing expires"), and the census gate had four fail-open paths. Errata appended to all three entries; gate fixed (selftest 40 → 47, ledger `R21-03`); criterion QA9 added. The coverage verdict stands only with the errata: read the entries with them.
- **C2**: QM5 ("`verify` before commit") was unmet as written at `c41af82`; QM12 appended as the documented substitute. The C2 counting command `awk -F'|' '/^\| Q[AM][0-9]/' corpus/QUALITY.md | wc -l` reads 21 after the correction (19 at `c41af82`).
- **C1**: unchanged (reviewer and critic both `holds` / `holds-with-limits`).
- The critic's report that S007 marks custom OIDC as "public beta" was not reproduced; recorded as unverified, not adopted.

## Planned (next — round 21 close)

1. **freshness** — give the 21 legacy entries a re-verification clock as appended header lines (`source:` naming the lane's own evidence as `own-work` rows, `verified-at:`, `recheck:`). Before: `bash corpus/sources-census.sh` → `legacy=21`. After: `legacy=0`, census CLEAN.
2. **calibration** — make `cells` evaluate the scorecard again (the round-20 attempt heading stops it with exit 2 since `93ab9a5`) without rewriting a filed heading; then run the outside admit/reject spot-check record into the round lesson. Before: `bash corpus/claim-ledger.sh cells` → exit 2.
3. **operability** — the probe's byte arm reports op-side failure as `SETUP` exit 2, not `DRIFT`, and prints observed hex for failing rows (round-21 reviewer M1/M2). Before: a stub op exiting 1 yields `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)`, exit 1.

## Capabilities

| Capability | What it can now do | Evidence pointer | First-working round |
|---|---|---|---|
| op-only dotenv byte probe | run six generated plain-value dotenv classes through `op run --env-file` under `env -i` with scratch HOME/XDG and compare the child's bytes (hex) to literal expectations; no ref, account or handler involved | `bash corpus/op-ref-probe.sh --dotenv-bytes` (ledger `R21-01`; `knowledge/op-ref-consumption.md` §11) | 21 (first run in the round-20 attempt, unadmitted there) |
| source registry + census gate | curate opened, scope-tiered sources with anchors, rejections and study paths, and machine-check the registry plus the entry ↔ source citation chain both ways | `bash corpus/sources-census.sh` (ledger `R21-02`), `--selftest` 47 cases (`R21-03`); `corpus/SOURCES.md` | 21 |
| feature-bound typed credential review | adjudicate one caller-supplied typed claim against pinned product/feature/status/eligibility/anchor evidence; reject known false/bar-failing claims, keep unjudgeable inputs separate, accept bounded controls | measured code/data landing `4be5da3cac11a1db64c3e0a77246fd7f2bdee413`: selftest PASS cases=12, before rejects10/after admits4/boundary3 excluded; R22-01/R22-02; `kagi-shokunin/.ufo/waves/round-22/final-verification.json` (initial H1 demonstration retained separately) | 22 |

Rows enter only through demonstrated execution (`AXES.md` §Capabilities): the two round-21 capabilities entered through that round's runs; feature-bound typed credential review first worked in round 22 through R22-01/R22-02. The 2026-10-16 rollout added none.

## Saturation

Declared round 21: **saturation line 9, stagnation window N = 3 completed rounds** (a blocked attempt such as round 20 does not count as a completed round). The owned axes (freshness 9, calibration 9) sit at the line, so the nudge fires only when no capability has entered in the last three completed rounds; two entered in round 21, so the earliest round it can fire is round 25 (after rounds 22–24 with none). Justification: the move log shows single-point moves through round 17, a re-census with no scalar move in round 19, and a blocked attempt in round 20 — a shorter window would read one blocked attempt as stagnation.

## Round 22 — pre-move (master `c2cab35bc92e57e39e5489bac3386db078345b3f`)

The prior round remains REJECTED-HONEST-STOP. Its verified depth move and
source-census capability are retained; its authored-row C2 claim is not
rebranded as calibration. All latest scalar scores are 9; freshness and
calibration tie for lowest owned axis, and both are worked. No depth move,
retirement or stagnation waiver is claimed.

| Axis | Score | Before evidence / limit |
|---|---|---|
| depth | 9 | R21-01's admitted account-free byte behavior remains the verified depth evidence; no new domain-byte contract is proposed. |
| coverage | 9 | R11-11 still declares the same host-surface set; the active feature review corrects already-held ground, not new coverage. |
| operability | 9 | R15-05's declared checklist ratio is unchanged; no unavailable handler behavior is made runnable by prose. |
| freshness | 9 | `corpus/lessons/round-22.md` records the frozen-base six stale stamps (the previous five plus later LOG drift), zero missing files and the distinct nine historical row replacements; no host currentness inferred. |
| calibration | 9 | `corpus/lessons/round-21-verifier-spotcheck.md` rejects prior E1/E3 admits and authored-row calibration; executable feature-bound adjudication capability absent at base. Scalar is held, not a current outside agreement score. |
| adjacency | 9 | `PROVINCE.md` retains sibling ownership and operator terminal-action boundaries; no browser lease, research-method or secret-scanner ownership is acquired. |

Declared claims (frozen `plans/round-22.md`): **C1 calibration capability**
(typed, feature-bound review with bad-admit and bounded-control executions,
not author-written-row accuracy); **C2 freshness** (current revision
pointers reconciled with explicit old/new migration evidence). The previous
plan's legacy-header migration and dotenv SETUP-classification change are
not absorbed: header counting is not re-verification, and this round's
selected, causally separate pin-repair work addresses the outside debt.

Historical-locator corrections: the old “13 bounds” index claim refers to
failure tokens, not the adjacency-breadth Bounds list (Entry01 audit).
The earliest PROTOCOL line-range citation and printer-era `HEAD` command
belong to the named historical revisions in the Entry09 audit, not mutable
current line numbers. These old score cells remain filed history.

## Round 22 — post-move (integration candidate; execution evidence follows)

This table freezes the scope and pointer contract for falsification, not
an unrun pass. Scalar scores remain held. Claim verdicts and the measured
commit are recorded in the appended execution outcome after the tools run.

| Axis | Score | Candidate evidence / limit |
|---|---|---|
| depth | 9 → 9 | R21-01 unchanged; no header count, pointer repair or historical marker is booked as depth. |
| coverage | 9 → 9 | `corpus/knowledge/feature-bound-credential-review.md` corrects already-held ground; no new governed host/vault surface. |
| operability | 9 → 9 | R15-05's checklist ratio unchanged; parser and Python dispatch changes are supporting contracts, not a second claim. |
| freshness | 9 → 9 | C2 candidate: R22-03 and `corpus/lessons/round-22.md` must show six inherited stamp mismatches reconciled, all original members retained and every changed tuple journaled; no host currentness claim. |
| calibration | 9 → 9 | C1 candidate capability: R22-01/R22-02 must demonstrate false-admit refusal and bounded-control acceptance. Arbitrary typed input uses trusted source bindings; authored labels and schema checks are not outside agreement. |
| adjacency | 9 → 9 | `PROVINCE.md` keeps neighboring ownership, operator-only terminal actions and local fixture scope. |

The capability table gains no row until a working demonstration is
recorded. C1's adjudication command is independent of stamp state; C2's
revision comparison never adjudicates vendor claims. Their bookkeeping is
integrated atomically, since the ledger/stamp snapshot must track every
changed artifact whether or not that artifact is an independent claim.

### Executed build evidence (round 22, before falsification)

`kagi-shokunin/.ufo/waves/round-22/initial-checks.json` preserves the real
first red invocations: feature-catalog setup failed and the revision
selftest failed. `repaired-checks.json` in the same evidence directory
records the scoped repairs: unasserted status carries no source-evidence
obligation; the Git-root prefix check accepts its normal trailing newline.
Only failed gate paths were re-run. Observed results:

- feature selftest PASS, 10 self-invocations; before phase rejects ten bad
  records (two false-claim, eight bar-fail), after admits four controls;
  three unjudgeable boundary records return 2 and are not scored;
- revision selftest PASS, 11 cases; `before-runnable.json` executes the new
  auditor over the frozen-base clone and finds six stale pointers, zero
  missing/dropped/added/invalid;
- `pin-only-ablation.json` changes only the isolated base's stamp snapshot
  and returns zero stale, zero dropped, zero added. No C1 source correction
  was copied into that clone; C1 itself ran while live pins were still stale.
- ledger selftest PASS (108 cases); sources census CLEAN (21 rows, 4 sourced
  entries, 21 legacy); source selftest PASS (47 cases).

The new capability row records a working execution, not the count of prose
criteria. Its scope is the closed reviewed source vocabulary and typed
records, not arbitrary prose, vendor truth or outside agreement. Final
falsification findings, measured revision and lane verdict are appended
before filing the fleet report.

### Current saturation and next intended claims

The round-21 “earliest round 25” note was conditional on no later
capability. The new round-22 capability resets that condition: saturation
line 9 and window N=3 stay unchanged, with no stagnation waiver applied
this round. No axis is retired or split.

Planned, not executed here: (1) freshness — give legacy entries a truthful
recheck clock without weakening the credential detector or calling headers
depth; (2) calibration — consume the independent closure's admit/reject
decisions and scope-breach ruling rather than self-certifying agreement;
(3) operability — revisit the byte probe's documented op-failure
SETUP-versus-DRIFT classification under plain local fixtures. Only the
operator's next steer chooses a future round; this assignment remains r22.

### Final measured outcome — round 22

Measured code/data commit:
`4be5da3cac11a1db64c3e0a77246fd7f2bdee413` (helper `landed` line, pushed).
The tested input hashes are in
`kagi-shokunin/.ufo/waves/round-22/final-verification-inputs.json`;
actual commands/stdout/exit values are in
`kagi-shokunin/.ufo/waves/round-22/final-verification.json`.
Only outcome/provenance metadata and their pins follow this measured state.

| Claim | Axis/type and score delta | Falsifiable before → after | Engineering verdict / counting command |
|---|---|---|---|
| C1 | calibration capability; **9 → 9**, no statistical calibration score claim | missing executable reviewer at BASE → one demonstrated capability; ten known-bad records refused, four bounded controls admitted, three unjudgeable boundaries excluded | **demonstrated** — `test -f corpus/feature-claims.py` on the before/current trees; `python3 corpus/feature-claims.py --selftest` (12 cases); `--phase before`, `--phase after`, `--phase boundary`; independent `--input` mutations and positive controls |
| C2 | freshness/pointer integrity; **9 → 9**, no host-currentness claim | six stale BASE pins → zero stale/missing/dropped; original63 retained, seven reviewed pin additions (70 total) | **demonstrated** — `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` on exact before/current states; after `CLEAN (stale=0 missing=0 dropped=0 added=7 invalid=0)`, exit0 |

Final authorized verification: **31/31 safe ledger rows pass**, with **12
host/transitive rows explicitly skipped by ID**. No full verify/cells
invocation is credited. Selftests actually report ledger121,
feature12, revision17, source47 (plus the unchanged hermetic gate rows).
The identical retained heading fixtures now match **17/17** expected
outcomes; the nine former silent-clean attacks no longer pass silently.
The exact blocked control and completeness/vacuity controls remain valid.

Source conformance: before `rows=16 A=14 C=2 mined=14 queued=1 rejected=1`,
after `rows=23 A=21 C=2 mined=21 queued=1 rejected=1`; both lane and fleet
census checks exit0. Only two distinct URLs are newly registered; the other
new IDs correct/reopen registered pages. Counts and executable counter:
`kagi-shokunin/.ufo/waves/round-22/registry-census-details.json`.

All remaining axis scores stay9 with their prior ceilings. No depth move,
promotion, retirement, deployed workflow or vault/account capability is
claimed. **This lane does not admit the round:** disclosed scope breaches,
withdrawn review claims, indirect installation and scratch collision remain
for the parent's independent non-author closure; a clean whole-round
secret-access/conformance attestation is unavailable.
