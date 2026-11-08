# kagi-shokunin — Scorecard

Domain: secrets & vault ops (the-janitor handler, `op` credential hygiene).
Axes owned by this lane: **freshness + calibration** (`MISSION.md` fleet-2);
all six are scored here, the owned pair drives the round's axis-move.

Scoring method: a score is the strength of a *verifiable* claim about this repo,
not a feeling about the domain. Every cell carries an evidence pointer a third
party can re-run; ceilings are named in the same cell, because an unqualified
high score is the calibration failure this file exists to prevent.

## Lane status

lane-status: open — as-of:2026-11-07 — dispatch unblocked; 4 operator-routed reds (R25-02,R29-01,R29-02,R38-03) stay red

One `lane-status:` line per the round-31 convention (mined from
`considerthese/2026-10-26.md` proposal 2; the lesson carries the contract): a
lane-authored self-declaration about dispatch posture, never a control — the
operator's holds live in the fleet root's `.ufo/l0-questions.md` and
`MANIFEST.json`, and no driver reads this file. "Open" is a dispatch fact
(rounds 29-31 were dispatched and ran); round 30's closure verdict
(`rejected-honest-stop`, `admitted: false`) is a different fact and is not
conflated here. The three routed reds are named so the line cannot read as
"everything is fine". Recheck: on-release — the line is re-asserted whenever
the dispatch state changes, and the `as-of:` date is the staleness signal.


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
| source registry + census gate | curate opened, scope-tiered sources with anchors, rejections and study paths, and machine-check the registry plus the entry ↔ source citation chain both ways | `bash corpus/sources-census.sh` (ledger `R21-02`), `--selftest` 98 cases (`R21-03`; the round-21 record said 59, measured stale by round 36 C1; 70 → 78 in round 55; 78 → 89 in round 67 with eleven SC_CAPTURE cases); `corpus/SOURCES.md` | 21 |
| feature-bound typed credential review | adjudicate one caller-supplied typed claim against pinned product/feature/status/eligibility/anchor evidence; reject known false/bar-failing claims, keep unjudgeable inputs separate, accept bounded controls | measured code/data landing `4be5da3cac11a1db64c3e0a77246fd7f2bdee413`: selftest PASS cases=12, before rejects10/after admits4/boundary3 excluded; R22-01/R22-02; `kagi-shokunin/.ufo/waves/round-22/final-verification.json` (initial H1 demonstration retained separately) | 22 |
| closure disposition review | turn a non-author closure's obligation ids into exactly one typed, pointer-resolving disposition each (fixed/reported/operator-owned/no-action/rejected); checks shape, id coverage and pointer presence in the working tree, not fix quality | `python3 corpus/closure-dispositions.py` (ledger `R23-02`), `--selftest` 14 cases (ledger `R24-02`, bound round 24); `corpus/closure-dispositions.json` | 23 |
| release-clock observation | observe every on-release registry clock against its declared official release feed or capture quote and retain a dated receipt | `python3 corpus/release-clock.py --observe <receipt>`; R25-03/R25-04; `.ufo/waves/round-25/observe-1.json` | 25 |
| differential feed-token agreement gate | import the live feed extractors and the shared token grammar and prove, over a fixed shape corpus in the three natural wrappers, that every shape the grammar adjudicates is extracted identically (and every shape it refuses is refused by all) — the D1 "one scanner trusting a token shape another never extracts" class becomes a standing check | `python -I -B corpus/feed-token-agree.py` ⇒ `FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)` (ledger `R29-02`); `--selftest` PASS 4 cases (ledger `R29-01`); red witness `corpus/feed-token-agree.py --instrument <BASE tree>` ⇒ DISAGREE naming `trailing-period` (`.ufo/waves/round-29/final/c2-after.json` M4); `corpus/knowledge/feed-token-boundaries.md` | 29 |
| pre-freeze BASE control execution | extract a named revision into scratch, run caller-declared commands with BASE/LANE exported and compare the measured integer to expect. Since round35, accept only one nonempty unsigned-integer stdout line, no stderr, rc0 or rc1-zero; invalid producer results are NORESULT/SETUP exit2. This validates an envelope, not command truth or a masked pipeline's upstream status. Historical last-integer behavior remains in round33/34 receipts. | `bash corpus/prefreeze-control.sh run --base <rev> --controls <file>`; `R33-01`, `R34-02`; frozen public-path battery `.ufo/waves/round-35/controls/measure.py`; original red witness `.ufo/waves/round-33/final/c1-red-witness.txt`; `corpus/knowledge/prefreeze-controls.md` | 33 |
| release-feed anchor currency counter | counts release-feed surfaces (vault releases.atom, openbao releases.atom, python.org feed.rss) with no registry row naming the feed URL and the observed version, against a committed observation receipt; fails closed on a missing, sha-mismatched or malformed receipt | `bash plans/round-37-c2.sh` (frozen counter; `plans/round-37-controls.sh`, `plans/round-37.controls.tsv` — `PREFREEZE: CLEAN (controls=6 mismatch=0)`, `.ufo/waves/round-37/controls/prefreeze-gate.txt`); `.ufo/waves/round-37/controls/observe-r37.json` | 37 |
| located-quote gate over committed capture bodies | locate each declared quote byte-for-byte at its declared offset in its committed capture body, with the body sha256 and byte count bound to the capture row and the quote bound to the registry row; manifest-side forged quotes, bytes and registry rows each fail (a body rewritten together with its capture row passes: a stated ceiling) | `python3 -I -B corpus/quote-locate.py` ⇒ `QUOTE_LOCATE: CLEAN located=5 rows=5`; frozen controls `plans/round-38.controls.tsv` (forgeries read 4, `PREFREEZE: CLEAN (controls=7 mismatch=0)`); counter `plans/round-38-c1.sh` (ledger `R38-01`; the `R38-03` verdict row is POLICY pending operator registration); `corpus/quote-bodies.tsv` | 38 |
| lane-tree write guard | snapshot a lane's HEAD, staged and unstaged diff and untracked files around a command, and report any change as VIOLATION with exit 1; the selftest plants three writes in scratch fixtures and passes a clean control | `bash corpus/laneguard.sh --selftest` ⇒ `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok` (ledger `R38-04`); `--no-mutate` ⇒ `detected=0`; counter `plans/round-38-c2.sh` (ledger `R38-02`) | 38 |
| anchor-pin drift detection | flag an in-place rewrite of a pinned superseded feed anchor cell (S034, S035, S039; S036 pinned in round 40, M39-7) as DRIFT against committed sha256 pins; a pin rewritten together with its row passes (ceiling QM40) | `bash corpus/anchor-pins.sh --root .` ⇒ `ANCHOR_PINS: CLEAN (pins=4)`; frozen counter `plans/round-39-c1.sh` ⇒ `3` (controls `plans/round-39.controls.tsv`, `PREFREEZE: CLEAN (controls=4 mismatch=0)`); `corpus/anchor-pins.tsv` | 39 |
| declared-axis conformance | check that each round claim's plan heading and tagged SCORECARD row carry the axis frozen in `corpus/claims-declared.tsv`, reporting MISMATCH on planted relabels; does not judge axis fit (ceiling QM41) | `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=2)`; frozen counter `plans/round-39-c2.sh` ⇒ `3`; `corpus/claims-declared.tsv` | 39 |
| gate self-testing with committed expected findings | prove a gate fails on its committed false-clean fixture classes (F1 dup, F2 shape, F3 schema, F6 no-final-newline; D1 dup-row, D2 fence heading, D3 section-missing, D5 padded cell) and that a constant-CLEAN mutant of the gate diverges from the real gate, 8 cases each | `bash corpus/anchor-pins.sh --selftest` ⇒ `ANCHOR_PINS_SELFTEST: PASS (8 cases)`; `bash corpus/claims-declared.sh --selftest` ⇒ `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`; counter `bash plans/round-40-c3.sh` | 40 |
| SOPS/age access-vs-rotation trial | execute the documented SOPS/age mechanics end to end with throwaway identities in scratch: add a recipient with `updatekeys` leaving value ciphertexts and the MAC byte-identical, `rotate` re-encrypting every value with the plaintext unchanged (the new data key measured separately by a hashed-key probe), removal revoking only the synced file while a pre-removal copy stays decryptable by the removed recipient, a creation-rule edit alone changing nothing until `updatekeys`, and two key groups defaulting to `shamir_threshold: 2` with either group alone refused and a threshold of 1 rejected outright; five designated falsifier shims (SH1..SH5) each flip one test to BROKEN, and a missing tool exits 2 without a HOLDS line | `bash corpus/sops-age-trial.sh --work <dir>` ⇒ `SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2`; frozen counter `plans/round-48-c1.sh` (target 5, BASE 0 absent); `corpus/knowledge/sops-age-key-rotation.md` §Measured (round 48) | 48 |
| OpenBao token/lease lifecycle trial | execute the documented OpenBao token and lease mechanics end to end against a throwaway `bao server -dev` on 127.0.0.1 with in-memory storage and a random root token kept only in scratch: a non-root token stops at its TTL, a 3600 s renewal request past an explicit max TTL is granted no more than the cap and the token is then refused, a batch token is neither renewable nor manually revocable, a userpass login token is an orphan so revoking its creator leaves it alive while the creator's child token dies, and a token's lapse revokes the PKI lease it issued; five designated falsifier shims (SH1..SH5) each flip one test to BROKEN, and a missing tool exits 2 without a HOLDS line | `bash corpus/openbao-token-trial.sh --work <dir>` ⇒ `OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` (rc 0, 2026-11-06); frozen counter `plans/round-49-c1.sh` (target 5, BASE 0 absent); `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` §Measured (round 49) | 49 |
| OpenBao response-wrapping trial | execute the documented OpenBao response-wrapping mechanics against a throwaway `bao server -dev` on 127.0.0.1 (random root token in scratch, `setpriv --pdeathsig KILL`, random `r51-` values, nothing token-shaped printed): a wrapping token unwraps once and is then refused, a 2 s wrap TTL lapses while the wrapped secret stays readable, an unauthenticated `sys/wrapping/lookup` reports the creation path without consuming the token and is refused after the unwrap, `sys/wrapping/rewrap` moves the value to a new token and spends the old one, and a read-and-rewrap carries creation path `sys/wrapping/wrap`; each test flips to BROKEN under its falsifier shim in path-blind runs (byte-identical dispatcher, random bin dirs, random run order) | `bash corpus/openbao-wrap-trial.sh --work <scratch>`; frozen counter `bash plans/round-51-c1.sh <rev>` (controls `plans/round-51-controls.sh`, receipts `.ufo/waves/round-51/final/`); source S108 | 51 |
| OpenBao KV v2 version-lifecycle trial | execute the documented OpenBao KV v2 version operations against a throwaway `bao server -dev` on 127.0.0.1 with no secret on any argv (root token by environment, values on stdin, no server log, probed port checked against the server pid): a `-cas` write is accepted only at the current version, `kv delete` is a soft delete that `kv undelete` reverses, `kv destroy` is not reversed by an undelete, a key limited to 2 versions drops version 1 on the third write, and `kv metadata delete` removes every version; a refusal needs a non-zero exit and the server's refusal text; each test flips to BROKEN under its falsifier shim with the full verdict vector checked, in path-blind runs with the real run twice at random positions | `bash corpus/openbao-kv-versions-trial.sh --work <scratch>`; frozen counter `bash plans/round-52-c1.sh <rev>` (controls `plans/round-52-controls.sh`, receipts `.ufo/waves/round-52/final/`); source S110 | 52 |

| stated-clock offline replay | replay every `recheck:` clock of `corpus/knowledge/*.md` (grep/pdf/locate filter forms) against committed body captures bound by URL→sha256→registry row in `corpus/recheck-captures.tsv`, offline and fail-closed: a stale expectation reads MISMATCH/DRIFT instead of passing silently; gate `python3 -I -B corpus/recheck-replay.py` (`--selftest` 20 cases), frozen counter `bash plans/round-56-c1.sh <rev>` (r1–r5 + GUARD), 10 clocks across 8 entries | `corpus/recheck-replay.py`; `corpus/recheck-captures.tsv`; `.ufo/waves/round-56/controls/controls-prefreeze-epochF.txt` (23 MATCH); `corpus/lessons/round-56.md` | 56 |

| OpenBao audit-device custody trial | execute five audit-device mechanics against throwaway OpenBao 2.7.2 dev servers: the documented API enable path is refused by default and accepted with `unsafe_allow_api_audit_creation`, the default device HMACs values with a per-instance salt (request/response echo, plaintext absent), a `log_raw=true` device writes the value and the client token in cleartext, disable + re-enable rotates the salt, and `sys/seal-status` is non-audited; five shims plus a no-bao and a PATH-wrapper leg | `bash plans/round-57-c2.sh <candidate>` `value=5`; `corpus/openbao-audit-trial.sh`; `corpus/knowledge/openbao-audit-device-custody.md`; S115/S116; `.ufo/waves/round-57/` | 57 |
| OpenBao ACL-policy semantics trial | execute five ACL-policy mechanics against throwaway OpenBao 2.7.2 dev servers: deny-by-default with exact-path reach, `*` only as the last path character (sibling refused), a narrower `deny` outranking a broader allow, `+` bounded to one segment, and same-pattern capability union vs the highest-priority match across patterns; five shims, a no-bao leg and a PATH wrapper that lies on the client-side introspection (flips T5) | `bash plans/round-58-c2.sh <candidate>` `value=5`; `corpus/openbao-policy-trial.sh`; `corpus/knowledge/openbao-acl-policy-semantics.md`; S118/S119; `.ufo/waves/round-58/` | 58 |
| OpenBao transit-engine trial | execute five transit encryption-as-a-service mechanics against throwaway OpenBao 2.7.2 dev servers: `vault:v1:` round trip with a tamper refusal, rotate advancing the version while the old ciphertext still decrypts, rewrap migrating ciphertext with no client-side plaintext, `min_decryption_version` retiring a version (and re-enabling it), and convergent determinism for equal plaintext+context vs a different context and a non-convergent key; five shims, a no-bao SETUP leg and a clean-room leg where a second dev server refuses the first server's ciphertext | `bash plans/round-59-c2.sh <candidate>` `value=5`; `corpus/openbao-transit-trial.sh`; `corpus/knowledge/openbao-transit-engine.md`; S121/S122; `.ufo/waves/round-59/build/R59ExecTrial/` | 59 |
| OpenBao AppRole `secret_id` custody trial | execute five AppRole credential-custody mechanics against a throwaway OpenBao 2.7.2 dev server: `bind_secret_id` deciding whether `role_id` alone authenticates (refused by default, accepted after the update on a role carrying a `token_bound_cidrs` constraint), `secret_id_num_uses` bounding reuse, `secret_id_ttl` retiring an unwrapped secret, the accessor as a non-secret lookup/destroy handle, and `secret_id_bound_cidrs` pinning a login to a source range; the trial carries its own fixture-driven `--selftest` (45 cases, no `bao`, no network) | `bash corpus/openbao-approle-trial.sh` ⇒ `OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`; `bash plans/round-60-c2.sh` ⇒ `value=5 … selftest=1 guard=1`; `--selftest` ⇒ `APPROLE_SELFTEST: PASS (cases=45)`; `corpus/knowledge/openbao-approle-secret-id-custody.md` | 60 |
| OpenBao seal / unseal key-share custody trial | execute five Shamir-seal custody mechanics against throwaway OpenBao 2.7.2 servers (raft and inmem, 127.0.0.1, default config): `operator init -key-shares=5 -key-threshold=3` produces five shares and a threshold the server reports as `t=3 n=5` with no share material under the storage path; unseal needs three distinct shares (a repeated share does not advance progress); `operator seal` returns the server to sealed, an authenticated request then answers 503 while `sys/seal-status` stays readable; `operator generate-root` needs the share quorum plus an OTP the token is XORed with, and `-decode` recovers a 26-char token that authenticates; `operator rekey` answers HTTP 405 `unsupported operation` under the default config on both backends while the documented `rotate-keys` completes a full rotation — the trial carries its own fixture-driven `--selftest` (63 cases, no `bao`, no network) | `bash corpus/openbao-seal-trial.sh` ⇒ `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`; `bash plans/round-61-c2.sh --tree .` ⇒ `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (… ops=1 t2w=1 stubctl=1 secret=1 … cases=63)`; `--selftest` ⇒ `SEAL_SELFTEST: PASS (cases=63)`; `corpus/knowledge/openbao-seal-key-custody.md` | 61 |
| capture read-through in the source census | open every capture-path-shaped row's declared body, bind sha256 and byte count to the row, locate the declared quote under the declared normalization, and refuse six one-defect mutations with a named finding; prose locations counted, never opened | `bash corpus/sources-census.sh` ⇒ `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)`; `bash plans/round-67-c1.sh --tree .` ⇒ `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1`; `corpus/knowledge/source-capture-binding.md` | 67 |
| bypass-resistant record grading | grade a record repair and reject a negation or a swapped pairing that keeps every token (the five round-61 bypass trees: `not withdrawn`, `no three`, `not rewritten in place`, a denial tail, `3/16 = 25 %`), while the true corrections still resolve and benign rewording is not flagged | `bash plans/round-62-c1.sh --tree .` ⇒ `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1 chal=1)` (ledger `R62-01`); BASE `60b5b7b6` reads `accepted=5 guard=0`; `plans/round-61-c1-check.py --selftest` ⇒ `PASS (75 cases)` (`R62-04`); `corpus/knowledge/claim-instrument-falsifiability.md` | 62 |
| self-witnessing gate counter | a counter whose `--selftest` executes its own aggregation (a constant-aggregation mutant and an unconditional-shim mutant each fail with a named `FINDING`) and whose guard reads 0 on a valid-sha256 tree that prints no expected observable | `bash plans/round-62-c2.sh --tree .` ⇒ `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` (ledger `R62-02`); BASE `60b5b7b6` reads `killed=0 guard=0`; the measured counter's `--selftest` ⇒ `C2_SELFTEST: PASS (cases=21)` (`R62-05`); `corpus/knowledge/claim-instrument-falsifiability.md` | 62 |
Rows enter only through demonstrated execution (`AXES.md` §Capabilities): the two round-21 capabilities entered through that round's runs; feature-bound typed credential review first worked in round 22 through R22-01/R22-02; closure disposition review first worked in round 23 through R23-02 (row added to this main table in round 24, routed D1 — it had sat only in the round-23 section). The 2026-10-16 rollout added none. The latest first-working round in this table is 62 (bypass-resistant record grading and the self-witnessing gate counter, rows above).

Round 49 note (appended; the paragraph above keeps its round-40 sentence as history): the latest first-working rounds are now 48 (SOPS/age trial) and 49 (OpenBao token/lease lifecycle trial, entered through `bash plans/round-49-c1.sh <candidate>` reading `value=5`, receipts `.ufo/waves/round-49/final/`).

Current readings at round 48 (revision-bound counts are true at the revision that carries this line; the rows above keep their first-working readings as history): `python3 -I -B corpus/quote-locate.py` ⇒ `QUOTE_LOCATE: CLEAN located=8 rows=8`; `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=23)`; `bash corpus/claims-declared.sh --selftest` ⇒ `CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`. The row "gate self-testing with committed expected findings" says "8 cases each": `corpus/anchor-pins.sh --selftest` still runs 8, `corpus/claims-declared.sh --selftest` runs 12 since round 46. Counter `plans/round-48-c2.sh` compares every `cmd` ⇒ `out` pair of this section with the command's output (round-48 C2).

Round 51 note (appended): the latest first-working round is now 51 (OpenBao response-wrapping trial, entered through `bash plans/round-51-c1.sh <candidate>` reading `value=5`, receipts `.ufo/waves/round-51/final/`).

Current readings at round 51 (revision-bound: true at the round-51 landing commit that carries this line, measured with `bash plans/round-51-c2.sh <rev>`; the round-48 line above keeps its readings as history): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.

Round 52 note (appended): the latest first-working round is now 52 (OpenBao KV v2 version-lifecycle trial, entered through `bash plans/round-52-c1.sh <candidate>` reading `value=5`, receipts `.ufo/waves/round-52/final/`).

Round 56 note (appended): the latest first-working round is now 56 (stated-clock offline replay, entered through `bash plans/round-56-c1.sh <candidate>` reading `value=10`, receipts `.ufo/waves/round-56/controls/controls-prefreeze-epochF.txt`).

Round 57 note (appended): the latest first-working round is now 57 (OpenBao audit-device custody trial, entered through `bash plans/round-57-c2.sh <candidate>` reading `value=5`; receipts `.ufo/waves/round-57/final/`). The current-tense numbers this note does not carry are bound by `corpus/current-claims.py`, which audits the previous round's landing surface.

Current readings at round 52 (revision-bound: true at the round-52 landing commit that carries this line; the round-51 line above keeps its readings as history): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=31)`; `bash corpus/claims-declared.sh --selftest` ⇒ `CLAIMS_DECLARED_SELFTEST: PASS (13 cases)` (case 13 added this round, M52-2: a `<!--` inside an inline code span no longer opens an HTML comment for the gate).

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

## Round 23 — pre-move (repo HEAD `d218603`, round-22 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | R21-01: account-free dotenv byte behavior remains the verified depth evidence; no new domain-byte contract is proposed. | round 21 |
| coverage | 9 | R11-11: the declared host-surface set is unchanged; S024-S026 do not exist at base, and the round adds no governed surface. | round 11 |
| operability | 9 | R15-05: the checklist ratio is unchanged; `cells` has no host-free ledger row at base (R13-03 is skipped for host rows). | round 15 |
| freshness | 9 | R21-02 measured 23 rows, of which 16 carried only historical in-row pins and 7 carried no provenance at all; `sources-census.sh` had no fetch check. | round 22 |
| calibration | 9 | R22-02: the outside closure's D1-D9 and decisions were prose only; no machine disposition resolved at base (`test -e corpus/closure-dispositions.py` fails). | round 22 |
| adjacency | 9 | R16-02: the ownership partition and PROVINCE boundaries are unchanged. | round 16 |

## Round 23 — post-move (claims C1/C2/C3; measured candidate, falsification follows)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 → 9 | R21-01 unchanged; no depth claim is booked. | round 23 |
| coverage | 9 → 9 | R21-02 now counts 26 rows; S024 is a new frontier row and S025/S026 are correction rows; the 10 captures cover nine distinct URLs and no new governed ground. | round 23 |
| operability | 9 → 9 | R23-01 runs `cells` host-free over committed fixtures with the exact CLEAN line (`rows_run=2 row_deferred=0 self_skipped=0`). | round 23 |
| freshness | 9 → 9 | C2: R21-03's 12 new `SC_FETCH` cases and 10 declared provenance rows in `corpus/source-fetches.tsv`; historical in-row pins stay bounded and uncompared. | round 23 |
| calibration | 9 → 9 | C1 capability: R23-02 resolves 15 outside obligation ids (not reviewer verdicts) with 6 fixed / 3 reported / 1 operator-owned / 5 no-action dispositions; D3 is reported, not fixed, because id-shaped positionals remain debt. | round 23 |
| adjacency | 9 → 9 | stamp-pinned `corpus/adjacency.tsv` and R17-02: the four declared breadth pins are unchanged; inherited parent findings are reported, not absorbed. | round 23 |

### Capabilities

| capability | what it can now do | evidence pointer | first working round |
|---|---|---|---|
| typed feature-bounded credential review | adjudicate typed credential records against pinned source bindings, refusing known-bad admits | `corpus/feature-claims.py`; R22-01/R22-02 | round 22 |
| closure disposition review | turn a non-author closure into exactly one typed, pointer-resolving disposition per obligation | `corpus/closure-dispositions.py`; R23-02; `--selftest` (14 cases) | round 23 |

### Saturation and next intended claims

Saturation line 9 and stagnation window N=3 stay unchanged. A capability entered
this round (closure disposition review), so the stagnation nudge is not applied
and the lowest-axis obligation is moot at a uniform 9: claims C1-C3 are distinct
axes at 9→9 with new executable evidence, not scalar inflation. No axis is
retired or split. Remaining named debt for a future round: the 16 historical
in-row digests with undocumented representation; machine-readable supersession
edges; the `SKIP-SELF` cells bound (R11-08 red at base); the single-backslash
policy guard; and `R13-01`'s identity-free round-heading count.

## Round 24 — pre-move (repo HEAD `4f94b52`, round-23 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | R21-01: account-free dotenv byte behavior remains the verified depth evidence; no depth claim this round. | round 21 |
| coverage | 9 | R21-02: 26 registry rows; no governed host/vault surface is added this round. | round 23 |
| operability | 9 | R11-08 is red at base (`unresolved=2`); the default real-tree `verify`/`cells` executes host rows (tripwire total 35 at base, `.ufo/waves/round-24/tools/host-tripwire.sh`); R11-09 pins 121 cases. | round 23 |
| freshness | 9 | R21-02: 16 of 26 registry rows (S001-S016) have only a historical in-row pin; the normalizer is declared three divergent ways. | round 23 |
| calibration | 9 | R12-03, R21-04 and the other count rows pin a number while their notes claim a membership: 15/15 count-preserving identity swaps survive at base (`.ufo/waves/round-24/tools/identity-swap.py`). | round 23 |
| adjacency | 9 | R17-02: the four declared breadth pins and PROVINCE boundaries are unchanged. | round 16 |

## Round 24 — post-move (claims C1/C2/C3; measured candidate, falsification follows)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 → 9 | R21-01 unchanged; no depth claim is booked. | round 24 |
| coverage | 9 → 9 | R21-02 now counts 31 rows; S027-S031 ground the normalizer (tooling sources, one rejected) and add no governed surface. | round 24 |
| operability | 9 → 9 | C1: R11-09 (host-row default-skip, untagged-host/host-path/bash-option/symlink refusals, invocation-only SKIP-SELF, executed-only rows_run) and R11-08 CLEAN; tripwire total 35 → 0 with all 12 host IDs HOST-SKIPped. | round 24 |
| freshness | 9 → 9 | C2: R21-02 (`captures=31 inrow=16 inrow_only=0 inrow_nonreproducing=12`) and R24-01 (the one declared normalizer); rows whose only provenance is a historical in-row pin 16 → 0. | round 24 |
| calibration | 9 → 9 | C3: R24-03 to R24-16 pin count plus membership digest for the 15 count rows; identity swaps surviving the ledger 15/15 → 0/15; R24-02 binds the closure selftest (D3). | round 24 |
| adjacency | 9 → 9 | R17-02 and R24-12 (breadth identity) unchanged; sibling conventions were read, not absorbed. | round 24 |

### Round-24 recovery — measured outcome and corrections

Measured code/data revision:
`017cc4c5eb87f7942fa41ff8893e8737fd14cfb4`; paired gate logic regression
uses `277a0d4f1d9bc6c5cea9b1d0ab92e33e5c17bb56` (the later fix only adds
the S032 provenance continuation and its pins). Actual commands, exits and
stdout: `.ufo/waves/round-24/recovery-checks.json`.

- **C1 operability, 9 → 9; measured:** `bash .ufo/waves/round-24/tools/host-tripwire.sh <label> <rev>` on BASE
  `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` and the measured revision:
  host executions35 → 0, complete4/4 in both, all four after runs emit
  population_skipped12/12. These stubbed runs intentionally return
  FAIL/BROKEN; they measure exclusion, not clean gate operation. Separately,
  real-tree safe `bash corpus/claim-ledger.sh verify` exits0 CLEAN
  (claims61, stamped83, host_skipped12). Paired identical151-case fixtures
  fail the inherited logic and pass repaired logic; original guard/self-skip
  false admissions are retained as red evidence, not called passing.
- **C2 freshness, 9 → 9; measured:** `python3 .ufo/waves/round-24/tools/recovery-count.py <rev>` on the same revisions
  gives inrow_only16 → 0, registry26 → 32, captures10 → 32, and zero stamp
  mismatches (79 → 83 pins). R21-02 now measures32 rows / A30 / C2 /
  mined29 / queued1 / rejected2, inrow16 / nonreproducing12. S032 repairs
  an exact quote on held ground; v1 transformation functions are unchanged,
  with22 selftest cases including the explicit malformed-tag bounds.
- **C3 calibration, 9 → 9; measured projected identity only:** the repaired
  `python3 .ufo/waves/round-24/tools/identity-swap.py <label> <rev>` gives
  BASE15 survivors → after0 survivors /15 kills, invalid0 in BOTH runs.
  All pristine processes exit0; after mutants exit1 with complete receipts.
  The old lack-of-FAIL inference is withdrawn, and the twelve-case
  instrument selftest passes. R22-04 is case-NAME identity, not behavioral
  assertion identity; path-key checks do not establish an asset/runtime
  partition. The broader semantic reading is **rejected**, not silently
  counted as coverage. Independent admission remains the integrator's.

Depth, coverage and adjacency remain9 with their earlier evidence/ceilings;
no new knowledge entry, governed host surface, vault capability, retirement,
promotion or repertoire row is claimed. The latest capability remains
round23; saturation9/window3 and the tied-lowest-axis reasoning are unchanged.
This append supersedes the inherited candidate's31-row current count and
its incomplete cells HOST-SKIP/whole-process-control implications; filed
historical measurements remain intact.

Separability was also executed, not assumed. At frozen input commit
`e6210511a25ddd98ce54be346367f991ce9ff3ed`, run
`python3 .ufo/waves/round-24/tools/claim-separability.py c1-only`
(then c2-only and c3-only). Each overlay applies to the original BASE and
checks every input digest first: C1 alone records zero host executions
with four complete cases and 48 skip lines; C2 alone returns CLEAN with
32 captures and inrow_only=0; C3 alone kills the same 15 projected-identity
mutants with zero survivors/invalids and clean controls. C3's isolated
bookkeeping is baseline-shaped (80 pins / 59 rows), not the combined tree's
83 / 61. Receipts: `.ufo/waves/round-24/separability/c1-only-run.json`,
`.ufo/waves/round-24/separability/c2-only-run.json` and
`.ufo/waves/round-24/separability/c3-only-run.json`; all outer exits are 0.

Fresh public-byte replay at
`31c8421407ec2c1776d52c49be85c2d4f0d40167` also verifies C2's retained
normalization claim: `python3 .ufo/waves/round-24/tools/normalizer-replay.py .ufo/waves/round-24/recovery-normalizer-replay.json`
exits 0 with rows=10 / v1_matches=10 / ascii_matches=7. The alternative
changes only the collapse class in step 5; trim and all other v1 steps
stay fixed. Exact requests/digests are committed in that receipt; no page
body or semantic-drift guarantee is inferred.

## Round 25 — pre-move (repo HEAD `4587c61`, round-24 close)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | R21-01: account-free dotenv byte behavior remains the verified depth evidence; no depth claim this round. | round 21 |
| coverage | 9 | R21-02: 32 registry rows; no governed host/vault surface is added this round. | round 24 |
| operability | 9 | R11-08 in a lone clone: `FAIL R11-08 reason=exit-mismatch`, `citations` BROKEN unresolved=88 (57 sibling + 31 ufo, 42 of them committed self-references); the layout rule lived only in the row note (`.ufo/waves/round-25/build/RLoneVerify.md`). | round 24 |
| freshness | 9 | R21-02: 28 registry rows carry `recheck: on-release` with no release identity, so no clock could be observed to fire (`python3 .ufo/waves/round-25/tools/c3-measure.py 4587c61a…` → bound=0 unbound=28). | round 24 |
| calibration | 9 | R12-03/R21-04 pinned 83/61 while SKILL.md:46 said 63/39 (routed D1); the first candidate binder over BASE reported STALE=6 plus2 unlocatable and4 absent-new-ID errors; repaired identical common-population measurement has34 bindings and8 stale values (no missing or policy errors) (`.ufo/waves/round-25/c1-before.txt`). | round 24 |
| adjacency | 9 | R17-02: the four declared breadth pins and PROVINCE boundaries are unchanged; wave-1 connectors found no sibling claiming the new ground. | round 16 |

## Round 25 — post-move (claims C1/C2/C3; measured, falsification follows)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 → 9 | R21-01 unchanged; no depth claim is booked. | round 25 |
| coverage | 9 → 9 | R21-02 now counts 38 rows; S033–S037 are admitted release-feed rows and S038 is an empty-feed reject; these that ground C3 and add no governed surface. | round 25 |
| operability | 9 → 9 | C2: R11-08/R11-09 — a lone clone runs the row and ends `CITATION_GATE: INCOMPLETE` exit 3 (FLEET-ABSENT, unresolved=0) and `CLAIM_LEDGER: INCOMPLETE` with `LAYOUT-INCOMPLETE R11-08`; lane-owned misses stay UNRESOLVED; the fleet layout stays CLEAN; the end-of-line token is now checked. | round 25 |
| freshness | 9 → 9 | C3: R25-04 binds all 28 on-release rows (18 feed, 10 rendered-quote; 15 derived anchors declared) and the 2026-10-21 receipt observes every one; S012 fired and was re-verified; R25-03 selftest. | round 25 |
| calibration | 9 → 9 | C1: R25-02 binds 38 reviewed current-tense numbers in SKILL.md/PROVINCE.md/corpus/README.md to their live source; common-population stale bound numbers 8 → 0 (34 before-existing bindings; full after population 38); R25-01 selftest. | round 25 |
| adjacency | 9 → 9 | R17-02 unchanged; sibling conventions (kumitate FLEET_MISSING, souji fleet classification, kengaku doc-number binding) were read, not absorbed. | round 25 |

### Capabilities (round 25)

| capability | what it can now do | evidence pointer | first working round |
|---|---|---|---|
| release-clock observation | bind every `on-release` source to an official release feed or its declared capture quote and observe, in one dated receipt, which clocks fired | `python3 corpus/release-clock.py --observe <receipt>` (offline check R25-04, selftest R25-03); `.ufo/waves/round-25/observe-1.json` | 25 |

Saturation line 9 and window N=3 unchanged; a capability entered this round, so
the nudge cannot fire before round 28. No axis is retired or split. Claim
verdicts, the measured commit and the falsify wave are appended below once run.

### Final executed outcome — round 25

Measured code/data commit: `9b755f5b44ace949fc4d71c9d6d8f125a560e9cf`
(helper landed, pushed). Exact argv/stdout/exits and pinned revisions:
`.ufo/waves/round-25/final-verification.json` (15/15 checks pass). All axes
remain9; no scalar inflation, retirement or promotion.

| Claim | Score delta and bounded verdict | Counting command and before → after |
|---|---|---|
| C1 calibration | 9 → 9, measured doc-to-source agreement (not a statistical accuracy/completeness score) | `bash .ufo/waves/round-25/tools/c1-measure.sh --common 9b755f5b <docs-rev> <label>`: IDENTICAL34 before-existing bindings, BASE8 STALE → after0 (before exit1, unlocated0/ambiguous0; after exit0). Full after38 CLEAN. `--mutate SC-SKILL-STAMPS` returns STALE/exit1. Selftest48 passes. |
| C2 operability | 9 → 9, explicit incomplete layout, never false CLEAN | `bash .ufo/waves/round-25/tools/c2-measure.sh <rev> <label>`: lone BASE BROKEN unresolved88/exit1 → after INCOMPLETE unresolved0/fleet_absent48/exit3. Fleet CLEAN in both (1371→1639 citations). All after local/self/nested-owned negative controls UNRESOLVED exit1; legacy/mixed controls and ledger selftest170 pass. |
| C3 freshness | 9 → 9, dated observation/capability, not continuous vendor truth | `python3 .ufo/waves/round-25/tools/c3-measure.py <rev>`: on_release28 bound0/unbound28 → bound28/unbound0/observed28/fired1, orphan0. Receipt-bound offline gate CLEAN; clock selftest67 passes; retained-receipt contradiction on S008 yields RECEIPT-MISMATCH/exit1. |

Full safe ledger (empty HOME, default host exclusion) at measured commit:
`CLAIM_LEDGER: CLEAN (claims=65 deferred=0 stamped=88 ids=65 cited=55 labeled_ids=20 orphans=10 host_skipped=12)` exit0. No host row credited.
Source census38 rows/captures38, fleet source census exit0 (start32/end38,
receipts `census-start.txt` / `census-end.txt` in the wave directory).

Executed causal separability: `.ufo/waves/round-25/separability-final.json`.
Each constructed overlay starts on BASE and extracts code/data from the
measured revision, with SHA256 per overlaid blob: C1-only common34 is CLEAN
with BASE membership83/61 and selftest151 (C2/C3 code absent); C2-only gives
INCOMPLETE/absent48/unresolved0 (C1/C3 code absent); C3-only gives CLEAN28
and uses its byte-pinned receipt (C1/C2 code absent). These are constructed
claim-only trees, NOT asserted full-ledger-clean commits.

Trends (author engineering assessment; independent closure still required):
expansion improved by demonstrated release-clock observation capability;
quality improved by bound self-descriptions, classified layout limits and
observed sources; discernment unchanged pending the non-author admit/reject
spot-check. All original source rows, stamp paths and ledger IDs retained.

Planned next (not executed): work the named knowledge-entry numeric drift and
multi-claim quote coverage; no next-round claim or driver action here.

## Round 26 — post-move (bounded release-drift response)

Frozen BASE: `1bf3eec48d3761580ffd375c88143232485ae814`; one declared
claim C1, freshness (a tied-lowest non-retired axis), `plans/round-26.md`.
The last capability entered round25; saturation9/window3 remains unchanged,
so no stagnation waiver, capability, retirement or promotion is claimed.

| Axis | Before → after | Evidence and bounded interpretation |
|---|---|---|
| freshness | 9 → 9 | C1: S039/S040/S041, `corpus/lessons/round-26.md`; fresh Python3.15.1 observation and clause-level source re-opening, original3.15.0 anchors retained fired, named3.15.1 successors rearmed on-release. `bash .ufo/waves/round-26/tools/replay-current.sh before` → `after`: controlled current-registry profile observed26→30 / bound28→30 / unbound2→0, fired1→3, derived15 unchanged. Active default/table/R25-04 migrate explicitly; original round25 receipt/code/tables remain separately replayable. No semantic-change, installed-runtime or continuous-truth inference. |
| calibration | 9 → 9 | R25-02 remains bounded self-description agreement, no independent calibration claim. Historical CLEAN is not current vendor truth; R11-08/C2's original lone-clone INCOMPLETE/48 scope remains unclosed. |
| depth | 9 → 9 | R21-01 unchanged; no new mechanism or normalizer behavior claim. |
| coverage | 9 → 9 | R21-02: registry38→41 adds three correction rows on held ground, not governed surfaces or new admitted knowledge ground. |
| operability | 9 → 9 | R25-03/R25-04 retain the existing CLI/evaluator; only pinned default selection and active bindings migrate explicitly. Historical/current replays are evidence for that gate, not a new gate or monitor. |
| adjacency | 9 → 9 | R17-02 unchanged; connectors keep source-method ownership with chousa and system/runtime management outside this claim; shared Python drift is routed, not absorbed. |

Before/after commands, exact exits and the pushed revision measured are
recorded in the final outcome append below. Rejection of feed-as-semantics,
installed-runtime and historical-CLEAN-as-live readings is in the lesson
Gate. Expansion unchanged (same ground/no capability); quality improved
only if the bounded re-verification passes; discernment unchanged pending
outside admit/reject review, never supplied by dispatched children.

Planned next (not executed): the named multi-claim quote coverage and
knowledge-entry numeric debt remain, as do S029/S031 locator qualifiers;
no next-round dispatch or round claim is made.

### Final executed outcome — round 26

Measured pushed revision:
`d109c752797ecdcaf0e23ce0fbe56079e9c69797`.
`python3 -I -B .ufo/waves/round-26/tools/final-measure.py d109c752797ecdcaf0e23ce0fbe56079e9c69797 .ufo/waves/round-26/final-verification.json`
returned exit0, **29/29 checks**. Exact argv/exits/stdout and final verdict
lines are in that receipt; its invocation receipt is beside it.

- C1 freshness, 9→9, measured: original BASE source rows38/clock bindings28
  → current41/30, all original IDs retained; rearmed3.15.1 successor
  bindings0→2. The first28-record receipt has exactly S027/S028 changed
  on the declared identity/observation projection (timestamps and volatile
  digests excluded), not28 changed sources or two independent feed events.
- Controlled rearm-only profile: same current registry/new receipt,
  before bound28/unbound2/observed26 exit1 → after bound30/unbound0/
  observed30/fired3/derived15 exit0. Separate historical28-record
  demonstration observed26→28 (exit1→0); original round25 receipt
  replays CLEAN28/fired1 and remains byte-identical.
- Future3.15.2 synthetic feed fixture fires both successors; each missing
  successor binding fails UNBOUND; input-only/input-plus-manifest/missing
  manifest controls fail typed exit2. All per-clause source checks pass;
  first-item3.14.9 is rejected by the existing max-stable3.15.1 parser.
- Full safe ledger: CLEAN65 claims/89 stamps/host_skipped12, exit0.
  Lone citations: INCOMPLETE, unresolved0/fleet_absent48, exit3;
  lone verify: INCOMPLETE/layout_incomplete1, exit1. The slash-prose
  negative becomes BROKEN/unresolved1 with only that phrase changed.
  These limits are not declared fixed or CLEAN. Self-counts CLEAN38,
  clock selftest67, source census CLEAN41 all execute successfully.

One64-seat validated BUILD plus one ordinary8-seat residual review
(fewer than64 distinct residual integration attacks, no padding):
72 seats total,49 reports,23 terminal provider deaths, none replaced.
L1 held the canonical planner seat. Expansion unchanged; quality improved
by the bounded source/rearm response; discernment unchanged pending fresh
outside admit/reject review. All axes remain9; no new capability, coverage
ground, retirement, promotion or next-round work is credited.

## Round 27 — post-move (knowledge numbers bound; release clocks refuse silent regression)

Frozen BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`; claims C1 calibration
and C2 freshness (`plans/round-27.md`), both on tied-lowest axes at 9. The last
capability entered round25 (window3), so no stagnation waiver; no capability,
retirement or promotion is claimed.

| Axis | Before → after | Evidence and bounded interpretation |
|---|---|---|
| calibration | 9 → 9 | C1: R25-02 population extended to 18 reviewed `knowledge/*.md` numbers (`KN-*`); `python3 .ufo/waves/round-27/tools/c1-measure.py <docs-rev> <table-rev> <label> <out>` with the after table: BASE docs stale knowledge numbers → after 0, plus a one-digit knowledge mutation that must turn STALE. Reviewed population, not a digit census. |
| freshness | 9 → 9 | C2: `python3 .ufo/waves/round-27/tools/c2-measure.py <rev> <label> <out>`: numeric downgrade fixtures accepted CLEAN at BASE 2/2 → after 0/2 (REGRESSED, exit1), control and default stay CLEAN30; R25-03 selftest 67 → 73. Sourced S042/S043. |
| depth | 9 → 9 | R21-01 unchanged; no new mechanism claim. |
| coverage | 9 → 9 | R21-02 registry 41 → 43 adds two ordering-spec rows; no governed surface or knowledge ground. |
| operability | 9 → 9 | Default release-clock and self-counts commands unchanged in shape; R25-04 stays CLEAN30. |
| adjacency | 9 → 9 | R17-02 unchanged; version-tracking and doc-binding siblings read, not absorbed. |

Measured revision, exact exits and separability overlays are appended below
after the measured revision lands; no unrun result is stated here.

**Round-27 measured outcome (appended; supersedes the pre-critic numbers in
the table above — 18 bindings, 2/2 fixtures and selftest 73 were candidate-
time figures).** Measured revision `3fb77271eeee797047c37871038b1db1247fa236`, receipts
`.ufo/waves/round-27/final/`: C1 22 `KN-*` bindings over eight entries, BASE
docs stale 4 → 0, 22/22 mutation controls red (18 STALE, 4 UNLOCATED); C2
downgrade fixtures accepted CLEAN 4/4 → 0/4, REGRESSED exact 0/4 → 4/4,
control/default CLEAN30, clock selftest 67 → 79; separability holds except the
declared SC/PV-CLOCK-SELFTEST edge. Axis scores stay as stated (9 → 9).

## Round 28 — post-move (canonical version tokens; derived anchors bound to feed rows)

Frozen BASE `3553d499577084a6c98d7078906017840bbf7b28`; claims file and START census committed alone
first (`bdf90f58e43fdcae6291224197afe17812a16b55`). Declared C1 freshness and C2 calibration
(`plans/round-28.md`); CritC2Axis showed C2 is freshness by this lane's own
precedent, so the round counts as ONE freshness claim measured by two frozen
commands, and calibration carries no claim. The last capability entered
round25 (window3: rounds 26–28 without one), so the stagnation nudge cannot
fire before round29; no capability, retirement or promotion is claimed.

| Axis | Before → after | Evidence and bounded interpretation |
|---|---|---|
| freshness | 9 → 9 | C1+C2 (one claim). `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out>`: non-canonical fixtures MISHANDLED at BASE 3/4 (F1 fired lie, F2 traceback, F3 written fired receipt; F4 already caught by the observer) → measured revision below. `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py <rev> <label> <out>`: whole-feed derived-anchor lowerings accepted CLEAN at BASE 4/4 → measured revision below. Sourced S044/S045/S046; stamped `corpus/release-clock.py`. |
| calibration | 9 → 9 | No claim (re-booked; see above). QM27–QM29 learn M28-1..M28-4 (`corpus/QUALITY.md`). |
| depth | 9 → 9 | R21-01 unchanged; no new mechanism claim beyond the clock. |
| coverage | 9 → 9 | Registry 43 → 51 (candidate-time 49): three claim-grounding rows (S044–S046), three frontier-lead rows (S047–S049) and two falsify correction rows (S050 supersedes S047, S051 supersedes S049 — old rows kept); no knowledge entry or governed surface (`corpus/SOURCES.md`; `bash corpus/sources-census.sh` ⇒ `rows=51 A=49`). |
| operability | 9 → 9 | Default release-clock output unchanged (R25-04 CLEAN30); selftest 79 → 114 measured (candidate-time 106; count only, no behaviour claim). |
| adjacency | 9 → 9 | R17-02 unchanged; eight connector scans found vocabulary and mechanism analogy (tsukuroi/kumitate have the same defect class), no absorbed ground. |

Measured revision, exact exits and separability overlays are appended below
after the measured revision lands; no unrun result is stated here.


**Round-28 measured outcome (appended):** repaired revision
`5e847472a66fe0b41bfc4c374a3659eace3bd4f8`; receipts `.ufo/waves/round-28/final/`.
Frozen commands (verbatim):

    python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>
    python3 -I -B .ufo/waves/round-28/tools/c2-measure.py <rev> <label> <out.json>

C1 BASE3/4 MISHANDLED → 0/4; TYPED0/4 → 4/4 (all NON-CANONICAL S040).
C2 corrected construction BASE4/4 accepted → 0/4, exact0/4 → 4/4 (DERIVATION
exactly the group ids). Both commands exit0; their controls exit0 CLEAN30.
Strict category/id audit independently agrees (four adversarial classifier
controls rejected). Selftest79 → 114; ledger CLEAN65/stamped91/host_skipped12;
self-counts CLEAN60; sources census CLEAN51. MutDeriveGE now killed by the
raised-anchor case (pristine0 / mutant1 / restored0).

**Verdict distinction:** behaviour improvement measured, all axes remain9.
The original literal TSV-only C2 fixture was already rejected by the receipt
pin, so its ACCEPTED count is0/4 → 0/4; the4/4 → 0/4 result depends on the
pre-tool receipt-mirroring amendment. This is a contested frozen-fixture
conformance defect, NOT claimed fully met; outside admission is the operator's.
Neither classifier is a general correctness oracle (lesson FALSIFY dispositions).
The full freshness claim cannot be self-admitted solely from corrected counts.
Inherited `cells` heading debt in round26/27 remains (RevScorecardShape);
no green cell-audit claim is made. Planned next (not executed): the saturation
nudge points toward a frontier capability, rather than more scalar inflation;
OIDC claim-condition or detection-versus-validity evidence are opened leads,
not acquired capabilities.

### Round-28 attempt-3 documentary close (2026-10-25, policy HOLD)

The fleet card holds this round (`HOLD — policy`, content-safety refusal
2026-10-21; L0 line in `.ufo/l0-questions.md`). Attempt 3
added **no claim, measurement, source row or capability**: it landed the
pre-refusal authored evidence, re-stamped the ledger, and had eight read-only
seats re-run the committed counters. Two consequences for this section:

- The registry delta is **43 → 51** (the candidate-time 49 in the coverage cell
  below was corrected); both censuses exit 0.
- A verification critic found a real **C1 fail-open**: a period-suffixed feed
  token (`Python 3.15.01.`) is dropped by the `$`-anchored feed tokenizers
  instead of being refused, so an older canonical entry can read as newest and
  a canonical `3.15.1.` reads not-fired (`corpus/lessons/round-28.md`
  §Attempt-3 corrigenda 1). It is **not fixed** and token totality is not
  claimed: the bounded verdict rests on the frozen fixture set only
  (MISHANDLED 3/4→0/4, TYPED 0/4→4/4). Fix recipe is routed to round 29.

No axis score changes. Outside admission remains the operator`s.

## Round 29 — post-move (feed-token right boundary; differential agreement gate on the new host)

Frozen BASE `c49023b773b69de983f0e6eb7e5867ceb5c2c634`; plan+START census
`66d1a2c`; corrections `47a46d1` (alone, before work, QM29); instruments/gate/
before-receipts `0229375` (BASE instrument bytes). The round executes on a NEW
Windows host (plans/round-29.md Correction 1): the-janitor substrate and the
op.env fixtures are ABSENT (receipt `substrate-absence.txt`), an `op` CLI
2.39.0 is present and was left untouched — no install, sign-in, provisioning
or vault contact. All six axes stood at the saturation line 9 with rounds
26–28 capability-less, so the stagnation nudge fires and waives the
lowest-axis obligation; C2 is the frontier/capability move. Declared claims
(plans/round-29.md, frozen): C1 freshness (routed D1 closure, frozen round-28
recipe, sourced S052) and C2 capability acquisition. Two claims, distinct
types, causally separable: C1 verifies without the gate file (its fixtures
touch only `corpus/release-clock.py`); C2's gate verified red against BASE
(`c2-base-gate.json`: m1=1 m2=1 m3=0 m4=1) before the C1 fix landed.

| Axis | Before → after | Evidence and bounded interpretation |
|---|---|---|
| freshness | 9 → 9 | C1: the three feed extractors take the `STABLE_TOKEN_RE` right boundary (S052: a title's trailing period is content), so a period-suffixed token is extracted then judged — the round-28 D1 fail-open (silent drop to CLEAN / canonical release invisible) is closed by the frozen recipe plus its two feed-path selftest cases (114 → 116). Frozen instrument `.ufo/waves/round-29/tools/c1-measure.py`: NF MISHANDLED 5/7 → 0/7, CORRECT 2/7 → 7/7; round-28 counter replay stays MISHANDLED 0/4, TYPED 4/4; default control CLEAN30. `receipt mode or fields` at BASE on this host was a pre-existing POSIX-only assertion (M29-1), POSIX-scoped per Correction 1. Row `R29-01` |
| calibration | 9 → 9 | No scalar move claimed. Three mistakes mined with fixes shown able to fail (M29-1 host-property assertion, M29-2 host environment: python3 Store stub + NTFS case collision, M29-3 unmeasurable-in-time full verify); QM30 enters QUALITY.md; new self-counts bindings verified individually (12/12, 4/4, 116) with the QM12 substitute because full `verify`/`self-counts` exceed 300 s/240 s here (M29-3). Scores remain author-assigned; outside admission stays the operator's.; rows `R29-01`, `R29-02` |
| depth | 9 → 9 | `corpus/knowledge/feed-token-boundaries.md` adds the extraction contract, the agreement invariant, six bounds and four falsifiers — detail on the release-clock surface, not new domain scope; no vault/ref-resolved ground touched. |
| coverage | 9 → 9 | Registry 51 → 52 (S052, one tier A spec row on an opened URL); the new gate covers the lane's own token-extraction surface, not a host surface; census CLEAN (rows=52) at the measured revision.; row `R21-02` |
| operability | 9 → 9 | A ninth runnable gate mode-set (`feed-token-agree.py` verify + `--selftest`, exit 0/1/2, counts in the verdict line); nothing schedules any gate and the by-hand duties remain by-hand — the increment is claimed under C2/capability, not double-counted here.; rows `R29-01`, `R29-02` |
| adjacency | 9 → 9 | R17-02 unchanged; the gate imports this lane's own instrument and adjudicates nothing owned by siblings (chousa keeps the research method; no sibling claims workload-identity or scanner ground — round-21 sweep). The new host itself is reported (PROVINCE round-29 erratum), not absorbed into any other lane's surface list. |

Measured revision, exact exits and receipts are appended below after the
measured revision lands; no unrun result is stated here.

**Round-29 measured outcome (appended):** measured revision
`fc6511263a233f3db018fd7355568f4cf239727f`; receipts
`.ufo/waves/round-29/final/`. Frozen commands (verbatim, Correction-1 host
interpreter):

    python -I -B .ufo/waves/round-29/tools/c1-measure.py <rev> <label> <out.json>
    python -I -B .ufo/waves/round-29/tools/c2-measure.py <rev> <label> <out.json>

C1 (`c1-before.json` at `c49023b`, exit 1 → `c1-after.json` at `fc65112`,
exit 0): NF MISHANDLED **5/7 → 0/7**, CORRECT **2/7 → 7/7**; round-28
counter replay stays MISHANDLED **0/4**, TYPED **4/4**; default control
CLEAN exit 0 at both. C2 (`c2-base-plain.json` at `c49023b`: 0/4 booleans;
`c2-base-gate.json` at `0229375` with the gate present over BASE instrument
bytes: m1=1 m2=1 m3=0 m4=1 — the red witness; `c2-after.json` at
`fc65112`: **m1=1 m2=1 m3=1 m4=1**). Separability holds: C1's frozen
receipts are rev-pinned to trees without the gate; the gate's selftest
passed on a red tree. Regression battery at `fc65112`: selftest
`PASS (116 cases)` exit 0 (count grew only by the recipe's two cases; one
explicit SKIP line on nt is M29-1's declared limit); default CLEAN30 exit 0
(R25-04 unchanged); checklist-run 34 / op-ref-probe 36 selftests PASS;
census CLEAN rows=52 A=50 captures=52 exit 0 (one SC_ENTRY_CITE on first
contact closed by the S045 used-by back-reference, logged in the lesson).
Touched/added ledger rows re-run individually (QM12 substitute, M29-3):
R25-03 (migrated 114→116) exit 0, R25-04 exit 0, R29-01 exit 0, R29-02
exit 0; full verify/self-counts unmeasurable in time on this host (>300 s/
>240 s). Stamps 91 → 94, verified 94/94 against tree bytes. All axes
remain 9; the capability row for `feed-token-agree.py` entered the
capabilities table this round. Outside admission is the operator's.

## Round 30 — post-move (routed-defect closure D1–D5, EOL repair, secret-scanning adoption)

Frozen BASE `f67232c`; plan `b7482b4`; plan correction 1 `d163290` (before any work commit; `plans/round-30.md` §Correction 1). Claims: C1 calibration (owned), C2 freshness (owned), C3 coverage. No axis is scored up: the round's measured moves are recorded under each claim, and the lowest-axis obligation is met by C1 (all six axes stand at 9; last capability round 29, window 3, so the nudge does not fire).

| Axis | Before → after | Evidence and bounded interpretation |
|---|---|---|
| calibration | 9 → 9 | C1 partial: `self-counts.py` stale 8 → 0 (eight doc cells corrected), but the counter exits 2 (`POLICY`) on two round-29 feed-token bindings the ledger policy refuses. Ledger rows migrated to measured values: R12-03, R13-01, R14-01, R21-02, R21-04, R22-03, R24-05, R24-06, R24-14, R24-15. Not migrated and routed: R25-02 (blocked by the same policy bindings), R29-01 and R29-02 (gate-policy registration). Pointers: `R30-01`, `R14-01`, `R21-02`. |
| freshness | 9 → 9 | C2: CR files 3 → 0 outside `.ufo/`, `.gitattributes` with eol=lf (`.ufo/**` excluded), standing gate `R30-01` with a red witness (exit 1 on a planted CRLF); fleet census E12 ×52 exit 1 → exit 0; checklist ratio SETUP → CLEAN. Pointers: `R30-01`, `R21-02`. |
| depth | 9 → 9 | No new mechanism claim; the three entries add vendor-documented detail inside the declared frontier area. Stamped `corpus/knowledge/secret-scanning-detection-vs-validation.md` |
| coverage | 9 → 9 | C3: registry 52 → 60 (eight tier-A/B rows opened 2026-11-03), three knowledge entries admitted with per-entry gates (one refused as staged and admitted after a logged flip), lane census CLEAN `entries_sourced=8 captures=60`. Pointers: `R21-02`. |
| operability | 9 → 9 | `corpus/eol-sweep.sh` is a new runnable gate; every counter the round used runs on this host again. Nothing schedules any gate. |
| adjacency | 9 → 9 | Connector sweep found no sibling claim on scanner, NIST or OIDC ground; the shokuknow package was read, never written.; stamped `corpus/lessons/round-30.md` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 31 — pre-move (repo `HEAD` `655e620`, round-30 close + verifier spot-checks)

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock surface carries the extraction contract, agreement invariant and falsifiers; the refusal bounds (masking of ref-resolved values, item-level reads) stand; no new mechanism claim this round. Row `R29-01`. | round 29 |
| coverage | 9 | Registry 60 rows, census CLEAN `entries_sourced=8 legacy=21 captures=60` at BASE (row `R21-02`); the OIDC workload-federation lead is unopened ground (`corpus/README.md` §Frontier since round 21). | round 30 |
| operability | 9 | Nine gate mode-sets with verdicts + selftests; `eol-sweep.sh` re-runs green at BASE (row `R30-01`); nothing schedules any gate and the by-hand duties remain by-hand. | round 30 |
| freshness | 9 | Every declared entry's re-verification link is gate-checked (`docs` mode inside `verify`, row `R14-01`); the 21 legacy entries stay the named gap (`corpus/README.md` §Known gaps). | round 29 |
| calibration | 9 | Round-30 gates are green, but the scorecard cell audit has been unable to run since round 26: `bash corpus/claim-ledger.sh cells` at BASE dies with `unrecognised round heading` (five sections, rounds 26–30), exit 2, no CELL_AUDIT summary — the `RevScorecardShape` debt routed by the round-28 verifier. Control receipt `.ufo/waves/round-31/controls/cells-base.txt`. | round 30 |
| adjacency | 9 | Ownership partition gate green (row `R17-02`); OIDC/workload-identity ground unclaimed by siblings (round-21/30 sweeps; re-swept this round, 0 hits over 20 lanes). | round 30 |

## Round 31 — post-move (calibration + coverage axis-moves; C1 cell-audit re-arm, C2 OIDC adoption)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | The scorecard cell audit is setup-clean again: the five round-26–30 headings reshaped into the parser's `pre-move|post-move` shape (content-preserving, +30 bytes, 1252→1264 lines), six never-audited round-29/30 cells given resolvable pointers, the full stamp set re-pinned under `LC_ALL=C`, and ten count/identity rows migrated to measured values with old→new records. The audit completes to a `CELL_AUDIT:` summary whose only non-clean rows are the three operator-routed ids. | Row `R31-01`; receipt `.ufo/waves/round-31/final/receipts/cells-at-tip.txt`; `corpus/lessons/round-31.md` §Migrations. Ceilings: the summary stays `POLICY` while R29-01/R29-02 are operator-blocked; pointer relevance remains unverifiable (round-13 ceiling). |
| coverage | 9 → 9 | The OIDC workload-federation trust-policy theme moved from frontier lead to admitted knowledge: two entries (provider/protocol layer; 1Password custom-OIDC consuming side), 11 registry rows S061–S071 renumbered by document, 11 capture rows, every source re-opened 2026-11-03; census CLEAN rows=71 entries_sourced=10 captures=71. | Row `R31-02`; receipt `.ufo/waves/round-31/final/receipts/census-c2-at-tip.txt`; `corpus/lessons/round-31.md` §Gate. Ceilings: the census checks citation shape, not vendor truth; campaign-era anchor pins are kept as labelled history. |
| depth | 9 → 9 | The new entry adds the federation-trust contract (three claims + permission output, four provider dialects, the session-boundary rule, bounds and falsifier) — detail on newly-held ground, not a new mechanism claim on held surfaces. | `corpus/knowledge/oidc-federation-trust-policy.md` (stamped); row `R31-02`. |
| operability | 9 → 9 | No new gate; the round's counters are the existing census and cells modes re-run at the tip. Nothing schedules any gate; the by-hand duties remain by-hand. | Rows `R31-01`, `R31-02`. |
| freshness | 9 → 9 | The two adopted entries carry provenance trios + `Reverify:` rows and enter every census/docs check; 9 of 11 campaign fetch pins recorded non-reproducing with in-round captures as the evidence. Not re-scored: the lane's freshness measurement set (host-file drift, surfaces, runtime shape) is unchanged. | Row `R31-02`; `corpus/source-fetches.tsv` lines 104–114. |
| adjacency | 9 → 9 | Connector sweep over all 20 sibling lanes: 0 registry rows and 0 citations for the 11 adopted URLs; no sibling claims workload-identity ground — reported, not absorbed. The scorecard heading-shape class is kagi-local (0 of 20 siblings run a cells-equivalent gate). | `.ufo/waves/round-31/build/ConnOverlap.md`; row `R17-02`. |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 32 — pre-move (repo HEAD 32c35fe, round-31 close)

Frozen BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; plan and frozen claims `507dd9f`, committed alone before any round-32 data (`plans/round-32.md`). Every axis stood at 9 at the round-31 close, so this table is the reference line the round's two claims are measured against; no value in it is a round-32 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract and agreement invariant, and the refusal bounds (masking of ref-resolved values, item-level reads, the absent handler). Row `R29-01`. | round 29 |
| coverage | 9 | Unchanged: 71 registry rows with the census green at BASE (row `R31-02`); the NIST SP 800-57 family candidate in `merge/kagi/` is not selected this round (`plans/round-32.md` §Frontier step). | round 31 |
| operability | 9 | Unchanged: nine gate mode-sets with verdicts and selftests; `bash corpus/eol-sweep.sh` green at BASE (row `R30-01`); nothing schedules any gate. | round 30 |
| freshness | 9 | Unchanged as a score. Measured BASE gap, not re-scored: §11 of `corpus/knowledge/op-ref-consumption.md` names op 2.41.0 as its measured release while `op --version` reads 2.41.1 (observed 2026-11-03; `plans/round-32.md` §C2, BASE counter 0). The 21 legacy entries remain the named gap (`corpus/README.md` §Known gaps). | round 29 |
| calibration | 9 | Kept at 9 with the reason stated. The cell audit (`bash corpus/claim-ledger.sh cells`, row `R31-01`) completes to `CELL_AUDIT: POLICY` with one FAIL and two POLICY rows, all operator-owned: `R25-02` (FAIL, self-count binding blocked by the gate policy), `R29-01` (RED, operator-owned `PYTHON_SCRIPT_RE` registration), `R29-02` (RED, operator-owned, same registration). The instrument reports reds this lane cannot clear without an operator policy decision; the score is neither raised nor lowered to hide them. Receipt `.ufo/waves/round-31/final/receipts/cells-at-tip.txt`. | round 31 |
| adjacency | 9 | Unchanged: the ownership partition gate is green (row `R17-02`); OIDC and workload-identity ground is unclaimed by siblings (round-31 sweep over 20 lanes, 0 hits). | round 31 |

## Round 32 — post-move (self-description sweep and byte-evidence recheck)

Measured commands and receipts: `.ufo/waves/round-32/final/`. The report records the pushed measured revision. The frozen predicate is not amended after data; BASE expectations SD5=3/total10 were wrong (actual 1/8), recorded in `corpus/lessons/round-32.md`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1 not admitted if the frozen n=0 target retains its integrator-owned SD6 residual. Frontier conflicts, tombstones, missing M31-6 row and red-id naming repaired. R25-02 (FAIL), R29-01 and R29-02 (POLICY) remain operator-owned; 9 is retained as the bounded instrument-strength score, not a green-state score. | `corpus/self-description-sweep.sh` (stamped); BASE receipt n=8, final receipt `.ufo/waves/round-32/final/sweep-after.txt`; row `R31-01`. |
| freshness | 9 → 9 | C2 frozen version occurrence count 0 → 1; byte probe CLEAN six classes on installed op 2.41.1. S072 proves published release identity only. | `corpus/knowledge/op-ref-consumption.md` §11.1; `.ufo/waves/round-32/final/c2-after.txt`; row `R21-01`. |
| depth | 9 → 9 | No new byte class or vault behaviour; historical observations retained. | `corpus/knowledge/op-ref-consumption.md` (stamped). |
| coverage | 9 → 9 | Registry 71 → 72, S072 only; existing entry gains scoped provenance, not a new knowledge entry or host surface. | Row `R21-02`; `corpus/SOURCES.md` (stamped). |
| operability | 9 → 9 | New sweep counter, seven-case selftest; no scheduler added. | `corpus/self-description-sweep.sh` (stamped); `.ufo/waves/round-32/build/sweep/selftest.txt`. |
| adjacency | 9 → 9 | Integrator-owned citation is not edited; no sibling ownership absorbed. | Row `R17-02`; `.ufo/waves/round-32/build/ConnOverlap.md`. |

Next move: pre-freeze controls must be actually executed, not estimated. Any correction to the author-inaccessible SD6 token belongs to its integrator; this round does not narrow the counter to hide it.

## Round 33 — pre-move (repo HEAD 76f4eea, round-32 close)

Frozen BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`; plan and frozen claims `880824b1d3da5f70b2fe489a34fe866a47314672`, committed alone before any round-33 data (`plans/round-33.md`). All six axes stood at 9 at the round-32 close; this table is the reference line the round's two claims are measured against, and no value in it is a round-33 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract and the feed-token agreement invariant, and the refusal bounds (masking of ref-resolved values, item-level reads, the absent handler). Row `R29-01`. | round 29 |
| coverage | 9 | 72 registry rows with the census green at BASE (`entries_sourced=10 legacy=21 captures=72`, row `R21-02`; this cell said `captures=101` until the plan's own §C2 was audited — M33-3); the NIST key-management lead is unopened ground (`corpus/README.md` §Frontier since round 21). | round 32 |
| operability | 9 | Nine gate mode-sets with verdicts and selftests; `bash corpus/eol-sweep.sh` green at BASE (row `R30-01`); `corpus/self-description-sweep.sh` at BASE reads `n=2` with both SD6 lines integrator-owned; nothing schedules any gate. | round 32 |
| freshness | 9 | Every declared entry's re-verification link is gate-checked (`docs` mode inside `verify`, row `R14-01`); §11 of `op-ref-consumption.md` names op 2.41.1 (round-32 C2); the 21 legacy entries remain the named gap (`corpus/README.md` §Known gaps). | round 32 |
| calibration | 9 | Kept at 9 with the reason stated: the cell audit completes to `CELL_AUDIT: POLICY` with one FAIL and two POLICY rows, all operator-owned (`R25-02` FAIL; `R29-01`/`R29-02` policy-blocked). Round 32 closed with C1 not admitted (frozen `n=0` unmet at `n=1`; SD6 residual integrator-owned); `R32-2` leaves the mistakes-row shape open at this line and QM34 is owed. | round 32 |
| adjacency | 9 | Ownership partition gate green (row `R17-02`); OIDC, secret-scanning and workload-identity ground unclaimed by siblings (round-31 sweep over 20 lanes, 0 hits). | round 31 |

## Round 33 — post-move (claims C1 capability, C2 coverage)

Measured commands and receipts: `.ufo/waves/round-33/final/`. The frozen predicates and kill rules are `plans/round-33.md` §C1/§C2 and are not amended after data. Scores stay 9 → 9: a claim move adds no new score, so the rows record what moved and which reds remain.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1: the pre-freeze control gate enters as a capability. It extracts a frozen revision with `git archive`, runs every declared counting command in that extraction and compares the last integer with the frozen `expect`; the round-32 declared values are replayed as the red witness (SD5 3 vs measured 1; total 10 vs measured 8 → `MISMATCH 2/2`), and the class gains QM34. The three operator reds (`R25-02` FAIL, `R29-01`/`R29-02` POLICY) are unchanged. | Claim C1; `plans/round-33.controls.tsv`; `plans/round-32.controls.tsv`; `.ufo/waves/round-33/final/c1-red-witness.txt`; `corpus/knowledge/prefreeze-controls.md`; row `R31-01` |
| coverage | 9 → 9 | C2: the NIST key-management frontier theme moves to core — two entries, ten registry rows S073–S082 renumbered by document, ten captures, and the discharged Frontier bullet removed from both `PROVINCE.md` and `corpus/README.md`. **C2 is not admitted**: its fourth frozen reading names `captures=111`, a number no tree produces (the plan's BASE `captures=101` was never measured; the trees measure 72 → 82 — M33-3). The measured values are entries=2, rows=82, `entries_sourced=12`, `captures=82`, Frontier NIST lines=0; they are recorded as measurements, never substituted for the frozen reading. | Claim C2; `.ufo/waves/round-33/final/census-c2-at-tip.txt`; `corpus/lessons/round-33.md` §Gate |
| depth | 9 → 9 | Two entries on newly held ground: publication-status and currency signals, and the Part 2/Part 3 withdrawal-and-successor contract. No new mechanism claim on a held host surface. | `corpus/knowledge/nist-key-management-guidance-status.md`, `corpus/knowledge/nist-key-management-parts-withdrawal.md` (stamped) |
| operability | 9 → 9 | One new gate mode-set with a selftest (≥8 cases) and the `CLEAN`/`MISMATCH`/`NORESULT` verdicts; no scheduler added. | `corpus/prefreeze-control.sh` (stamped) |
| freshness | 9 → 9 | Ten sources re-opened 2026-11-04 with located quotes; the two legacy PDFs reproduce their campaign pins byte-for-byte; the two entries carry `verified-at`/`recheck` and enter the census/docs checks. | `corpus/source-fetches.tsv`; `.ufo/waves/round-33/build/nist-captures.tsv` |
| adjacency | 9 → 9 | The round-33 connector sweep over the sibling lanes is the sole-ground check for the ten NIST URLs (receipt `.ufo/waves/round-33/build/ConnOverlap.md`); the ownership partition is unchanged and green. | Row `R17-02`; `.ufo/waves/round-33/build/ConnOverlap.md` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here. If a C1/C2 kill rule fires, that row records a partial move and the capability row is withheld — no re-scope after data.

## Round 34 — post-move (bounded checks and executed evidence)

Frozen BASE `f9dc06fd8f6b43c175193c76dc6350468f551634`; plan frozen alone at `5a2f145ee80b6879a833c2e70d16f2671d103367`. Counting commands, targets and kill rules remain `plans/round-34.md`; receipts and the measured landed commit are named by the round-34 report. No scalar increase and no stagnation waiver are claimed.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1: SD7–SD9 sum is measured against BASE by the shipped sweep and compared at landing; BASE freeze-time equivalent counts are 3+1+1=5. Three registry rows, the corrected lesson range and prefreeze provenance address those observed mismatches. Bounded presence checks do not prove semantic completeness. R25-02 FAIL and R29-01/R29-02 POLICY remain operator-owned; three SD6 citations remain integrator-owned. | `corpus/self-description-sweep.sh`; `.ufo/waves/round-34/controls/prefreeze-base.txt`; row `R34-01` |
| operability | 9 → 9 | C2: relative-work becomes the twelfth prefreeze selftest case; M7 and the unfixed work-root mutation have actual failure receipts rather than inferred failure. | `corpus/prefreeze-control.sh`; `.ufo/waves/round-34/build/receipts/gate-unfixed-relative-work.txt`; row `R34-02` |
| coverage | 9 → 9 | C3 NOT ADMITTED: one AccessKey entry and five external rows land, but the frozen census target is wrong and coupled to C1. Migrating the prefreeze entry requires own-work S088; sourced entries become14, not13, and rows/captures88, not87. No target is rewritten after data. | `corpus/knowledge/aliyun-accesskey-credential-custody.md`; S083–S088; row `R34-03`; `corpus/lessons/round-34.md` M34-3 |
| freshness | 9 → 9 | Six sources opened in-round and the prefreeze provenance trio migrated; no separately claimed freshness axis-move. | `corpus/source-fetches.tsv`; `corpus/lessons/round-34.md` Gate |
| depth | 9 → 9 | Documentation distinguishes RAM key retirement, recycle-bin recovery and KMS credential deletion; no live account behaviour is claimed. | `corpus/knowledge/aliyun-accesskey-credential-custody.md` (S083–S087, stamped) |
| adjacency | 9 → 9 | Connector scan is recorded; cloud-IAM custody does not absorb sibling security research or cloud application deployment. Existing CDP/profile contested scope is unchanged. | Row `R17-02`; `.ufo/waves/round-34/build/ConnOverlap.md` |

Planned next move: measure per-claim target populations independently before freeze, including provenance migrations; widen a bounded self-description check only under a new explicit predicate, never retrospectively strengthen this round's claim. No new capability-table entry is claimed in round34.

Measured record: C1 is 5→0 at `c5e0ecef2843dc8fded337780c579102ef8c9ee8` using the exact `bash corpus/self-description-sweep.sh` → awk SD7–SD9 sum command in `plans/round-34.md`; full producer outputs and statuses are `final/c1-base-final-producer.txt`, `final/c1-tip-final-producer.txt` under `.ufo/waves/round-34/`. Both producer exits are1 because the three SD6 residuals remain; all three claimed components are present, not a SETUP false-zero. Selftest is PASS10. C2 is PASS11→PASS12 (`bash corpus/prefreeze-control.sh --selftest`, executed at `b4e9fd9a474583db69b9601d162c6eb9e54ce0d6`, identical shipped SHA ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a) and receipt-line0→1 (`grep -c 'CASE base-isolation FAIL' .ufo/waves/round-34/mut/m7-shipped.txt`, measured at c5e0ece). C1/C2 verified only to their bounded frozen predicates; reviewer counter-strength objections remain recorded. C3 is NOT ADMITTED: the same c5e0ece counting commands read entry1, rows88; census executed at b4e9fd9 with unchanged registry/entry population reads sourced14/legacy21/captures88. Every score delta is9→9, not a numeric expertise gain. The overall round cannot be admitted while C3 misses.

## Round 35 — post-move (producer-result integrity; calibration admission withheld)

Frozen BASE `063c407494276d0c616e6c712a2e5d7aeb7e3768`; executed predeclaration controls `63ba87afce53842007ec27c09e3469132d149abd`; frozen plan alone `83ba8d1aac70f0f04a2357471def9b19b2bdc794`. One claim C1 calibration; no target, counter or axis is rebooked after freeze. Reviewer ReviewGate distinguishes nine gate-decision errors from SCORECARD/SHONEN self-assessment discrepancies: the numeric result is a gate-integrity gain, not by itself the declared calibration move. Admission is withheld, not manufactured from a different axis.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1 axis admission withheld. Fixed expected public-path decisions are compared to observed producer results; before mismatch5/false-CLEAN5, positive2 of case9. Candidate receipts give mismatch0/false-CLEAN0/positive2/case9, but this is not a self-assessment mismatch census. | `R33-01`, `R34-02`; `.ufo/waves/round-35/controls/before.json`; `.ufo/waves/round-35/build/ExecGate/measurement.json` |
| operability | 9 → 9 | Producer-result validity tightened; not retroactively claimed on this axis. No new capability or scheduler. | `R33-01`, `R34-02`; `corpus/prefreeze-control.sh` |
| freshness | 9 → 9 | S088 reopened as immutable historical own-work source, not current implementation evidence; no separately claimed move. | `corpus/lessons/round-35.md`; `R21-02` |
| coverage | 9 → 9 | No row append, provenance migration, new entry or frontier-to-core claim. | `R34-03`; `.ufo/waves/round-35/controls/populations-independent.json` |
| depth | 9 → 9 | Envelope validation does not prove command truth, confinement or masked upstream status. | `corpus/knowledge/prefreeze-controls.md`; `R33-01` |
| adjacency | 9 → 9 | Scope remains lane-local calibration tooling; CDP/profile ownership remains contested and operator-owned. | `R17-02`; `PROVINCE.md` |

R25-02 FAIL and R29-01/R29-02 POLICY remain routed; non-owned SD6 history is preserved. Current capability description is corrected, but that correction does not change the frozen counter population. No capability acquisition, retirement or promotion is asserted. Final committed-tree measurement is appended after execution; candidate receipts above are not represented as that later run.

Measured outcome: at committed `f8413db121da2203532d10f55bb76d79fa26f56f`, the frozen command prints `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`, exit0 (`.ufo/waves/round-35/final/frozen-counter.json`). This is the measured 5→0 gate-decision error result, not calibration-axis admission. Selftest PASS25 exit0; complete canonical final verdicts checked independently for all9 saved cases (`final/whole-receipt-review.json`). C1 remains not admitted on axis fit; all six scores remain9→9. Lane census CLEAN88/sourced14/legacy21/captures88; docs CLEAN35/32/3; fleet census exit0. Overall verify/cells/self-counts remain POLICY2 with the disclosed inherited reds and missing-id history. Final report names the pushed evidence-carrying tip; no whole-ledger clean claim is made.

## Round 36 — pre-move (repo HEAD cb8cb65, round-35 close)

Frozen BASE `cb8cb659e84240a8db12e4f7b4a0def5068baf7e` (frozen counters and executed predeclaration controls); frozen plan and claims `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d`, committed before any round-36 candidate scoring (`plans/round-36.md`). Every axis stood at 9 at the round-35 close; this table is the reference line the round's two claims are measured against, and no value in it is a round-36 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | Unchanged: 88 registry rows, lane census green at BASE (row `R21-02`). | round 35 |
| operability | 9 | Unchanged: nine gate mode-sets with verdicts and selftests; nothing schedules any gate. | round 35 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-36-c2.sh` reads 15 — 15 of the 20 `clock=feed` rows disagree with the committed 2026-11-04 observation receipt `.ufo/waves/round-36/controls/observe-live.json`. | round 35 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-36-c1.sh` reads 4 — the three routed reds named on this file's `lane-status:` line are absent from the last round's calibration row, plus one stale capability-table count. | round 35 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`). | round 35 |

## Round 36 — post-move (claims C1 calibration, C2 freshness)

Measured commands, raw outputs and exits: `.ufo/waves/round-36/`. The frozen predicates, counters, kill rules and targets are `plans/round-36.md` §C1/§C2 and are not amended after data. Scores stay 9 → 9: a claim move adds no new score, so the rows record what moved and which reds remain.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1 `bash plans/round-36-c1.sh` 4 → 0: this round's calibration row names the three routed reds with their state, and the capability-table census count was corrected to the live 70. The routed reds are unchanged and stay operator-owned: R25-02 (FAIL, self-count binding blocked by the gate policy), R29-01 (RED, operator-owned `PYTHON_SCRIPT_RE` registration) and R29-02 (RED, same registration). | Rows `R36-01`, `R21-03`; receipts `.ufo/waves/round-36/final/` |
| freshness | 9 → 9 | C2 `bash plans/round-36-c2.sh` 15 → 0: the fifteen drifting `clock=feed` rows take the 2026-11-04 receipt's observed version, date and verdict, all thirty bound rows are re-dated to that observation, and the round-36 receipt becomes the gate's default pin. | Rows `R36-02`, `R36-03` |
| operability | 9 → 9 | `bash plans/round-36-c3.sh` prints `RELEASE_CLOCK: CLEAN` against the repointed default receipt; the three selftests re-run green. No scheduler added. | Row `R36-03` |
| depth | 9 → 9 | No new mechanism claim: the round re-observes declared clocks and re-binds a self-assessment population. | Rows `R36-01`, `R36-02` |
| coverage | 9 → 9 | No registry row appended, no new entry, no frontier-to-core move; the four cited rows' recheck dates move 2026-10-21 → 2026-11-04. | `R21-02`; `corpus/SOURCES.md` |
| adjacency | 9 → 9 | The connector sweep over the sibling lanes is the sole-ground check for the four cited feeds; ownership partition unchanged. | Row `R17-02`; `.ufo/waves/round-36/build/ConnScope/ConnOverlap.md` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 37 — pre-move

Frozen BASE `911ab519b6b07694c3cb9f7d9a7c56e142ad957c`; predeclaration `04489d4184edb25a01ec8983b3ccedb45c683564`; frozen plan alone `e2030d2` (`plans/round-37.md`). One claim, C2 freshness; no calibration claim (`corpus/lessons/round-37.md` §Calibration hold: `bash plans/round-36-c1.sh` already reads 0 at HEAD). Every axis stood at 9 at the round-36 close; this table is the reference line the claim is measured against, and no value in it is a round-37 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged: release-clock extraction contract and feed-token agreement invariant (rows `R29-01`, `R29-02`). No depth claim this round. | round 29 |
| coverage | 9 | Unchanged as a score: 88 registry rows and 88 captures at BASE, lane census `SOURCES_CENSUS: CLEAN (rows=88 …)` (`corpus/lessons/round-37.md` §Census). | round 35 |
| operability | 9 | Unchanged: nine gate mode-sets, nothing schedules any gate; the new counter runs on demand. | round 35 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-37-c2.sh` reads 3 at `04489d4` and at `911ab51`'s tree with the frozen counter (`plans/round-37.md` §C2; `corpus/lessons/round-37.md` §Before → after). | round 36 |
| calibration | 9 | Unchanged as a score. `bash plans/round-36-c1.sh` reads 0 at HEAD, so no calibration claim is admitted this round. | round 36 |
| adjacency | 9 | Unchanged: ownership partition gate (row `R17-02`). | round 35 |

## Round 37 — post-move (claim C2 freshness)

Measured commands and receipts: `.ufo/waves/round-37/controls/` and `corpus/lessons/round-37.md` §Before → after. The frozen predicate and kill rules are `plans/round-37.md` §C2 and are not amended after data. Scores stay 9 → 9: a claim move adds no new score; the rows record what moved and what did not.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | C2 `bash plans/round-37-c2.sh` 3 → 0 at candidate `9efcea7`. Vault S034 (`v2.2.0`), openbao S035 (`v2.7.1`) and python S039 (`Python 3.15.1`) are superseded by rows S089, S090 and S091, each naming its feed URL and the receipt version (`2.2.1`, `2.7.2`, `3.15.2`). No mutable cell of S034, S035 or S039 changed. Commits: predeclaration `04489d4`, plan `e2030d2`, candidate `9efcea7`. Admission: see the lesson's verdict and the report; the counter's ceilings (quote authenticity, append-only, looseness) are named in `corpus/lessons/round-37.md` §Ceilings and are not claimed as closed. | Rows `S089`, `S090`, `S091` (`corpus/SOURCES.md`); captures `corpus/source-fetches.tsv`; receipt `.ufo/waves/round-37/controls/observe-r37.json` (sha256 `cb96cfb2…`); `.ufo/waves/round-37/controls/prefreeze-gate.txt` (`CLEAN (controls=6 mismatch=0)`); seat verdicts `.ufo/waves/round-37/build/` |
| calibration | 9 → 9 | No calibration move. Round-36 errata are routed in the round-37 lesson and not counted: `R36-1` (the `M36-4` pointer does not exist) and `R36-2` (the round-36 report says "five" W04 lines; the live count is 16). | `corpus/lessons/round-37.md` §Corrigenda, §Calibration hold |
| operability | 9 → 9 | The release-feed anchor counter is added as a capability row, with six executed controls and two setup refusals (exit 2). Nothing schedules it. Known coverage gap, routed: the frozen set does not exercise the `2.2.10` boundary (mutant M5). | `plans/round-37-c2.sh`; `plans/round-37-controls.sh`; `plans/round-37.controls.tsv`; `.ufo/waves/round-37/build/K37MutCounter/` |
| depth | 9 → 9 | No mechanism change. | `plans/round-37.md` |
| coverage | 9 → 9 | Registry rows 88 → 91 and captures 88 → 91: three supersession rows, no new entry, no frontier-to-core move. Fleet W04 duplicate-URL warnings 16 → 19 (the three cross-scope duplicates; no E-finding). | `corpus/lessons/round-37.md` §Census |
| adjacency | 9 → 9 | No change; connector sweep found no sibling claiming the same feed surfaces. | `.ufo/waves/round-37/build/K37ConnFeeds/` |

## Round 38 — pre-move (repo HEAD a916f4a, round-37 close)

Claim BASE `a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c`; predeclaration `8c48b7df71066b969ac078205b5ed18cf5f53286` (instruments, frozen controls, capture bodies, live re-observation receipt); frozen plan alone at `289e8082ef80e9e14694fcf68f1296bfff26ad9d` (`plans/round-38.md`). Every axis stood at 9 at the round-37 close, so this table is the reference line the round's two claims are measured against; no value in it is a round-38 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | 91 registry rows at BASE, census CLEAN (row `R21-02`). | round 37 |
| operability | 9 | Unchanged: nine gate mode-sets with verdicts and selftests; nothing schedules any gate. | round 35 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-38-c1.sh` reads 0 at `a916f4a` (no quote gate): no committed gate locates the round-37 quotes against committed bytes (`corpus/lessons/round-37.md` §Ceilings). | round 37 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-38-c2.sh` reads 0 at `a916f4a` (no lane-tree guard, while `corpus/lessons/round-37.md` describes one). `bash plans/round-36-c1.sh` reads 3 at `a916f4a` (SD5=3: the round-37 calibration row omits the three routed reds; stale 0). | round 37 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`). | round 35 |

## Round 38 — post-move (claims C1 freshness, C2 operability as measured)

Measured commands and receipts: `.ufo/waves/round-38/` (`controls/`, `capture/`). The frozen predicates, controls and kill rules are `plans/round-38.md` and are not amended after data. Scores stay 9 → 9: a claim move adds no new score, and the capability rows enter the main table in this round.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | C1 `bash plans/round-38-c1.sh` 0 → 5 at the candidate: the located-quote count of `corpus/quote-bodies.tsv` (S089–S093) by `corpus/quote-locate.py`, reproduced by K38ExecQuote and K38CriticClaims. Manifest-side forgeries (quote, bytes, registry) each read 4 at the predeclaration (`plans/round-38.controls.tsv`, `PREFREEZE: CLEAN (controls=7 mismatch=0)`); a body rewritten together with its capture row passes (ceiling, `corpus/lessons/round-38.md`). Two tier-A registry rows S092 and S093 (opened 2026-11-05) corroborate S089 and S090 from the release tag pages. The live re-observation of all 30 clocks matches the pinned round-36 receipt on 30 of 30 records; the new receipt is not a usable pin (`RECEIPT-MISMATCH`, date binding), and the pin is unchanged. R37-V2 (release-clock re-point) is not re-pointed: a full re-point gives 10 DERIVATION findings and FAILED, an anchor re-point un-fires a clock (`corpus/lessons/round-38.md` §R37-V2). Quality trend for the round: unchanged, R37-V2 open. | Rows `R38-01`; `R38-03` (POLICY, operator-owned allowlist; see below); `corpus/SOURCES.md` S092–S093; `corpus/source-fetches.tsv`; `.ufo/waves/round-38/controls/observe-r38.json` |
| calibration | 9 → 9 | No calibration move is claimed. The round-37 self-description defect (M38-2: a `LANE-GUARD` battery line described but not committed) is recorded with its erratum in `corpus/lessons/round-38.md` and QM38; the calibration reading of C2 is withdrawn (critic F8). The round-36 counter `bash plans/round-36-c1.sh` reads 0 at the candidate: its calibration row names the three routed reds R25-02 (FAIL), R29-01 and R29-02 (POLICY), and the claim-row count is rebound to 86 in SKILL.md, PROVINCE.md and `corpus/README.md`. Its pre-move reading (3) and the round's own intermediate reading (6) are recorded as M38-5. | `corpus/lessons/round-38.md` §Mistakes M38-2, M38-5; `R36-01`, `R21-04` |
| depth | 9 → 9 | No mechanism change. The release-clock gate is re-run on the live observation only as evidence; its pinned receipt is unchanged. | `corpus/lessons/round-38.md` §R37-V2 |
| operability | 9 → 9 | C2 `bash plans/round-38-c2.sh` 0 → 3 is the operability move: `corpus/laneguard.sh` runs a command in a lane and reports any change in HEAD, staged or unstaged diff, or untracked files as VIOLATION; its selftest plants three writes in scratch fixtures and passes a clean control (`LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, row `R38-04`), and the do-nothing control reads 0. The wave's reviewer holds it against its attacks; the limits are recorded in the lesson. Two gates added (`quote-locate.py`, `laneguard.sh`), run on demand; nothing schedules any gate. | `R38-02`, `R38-04`; `plans/round-38-c2.sh`; `corpus/laneguard.sh`; `corpus/lessons/round-38.md` §Mutation survivors |
| coverage | 9 → 9 | Registry 91 → 93 and captures 91 → 93 (two tag pages, no new surface, no new knowledge entry; `entries_sourced` stays 14). | `R21-02`, `R33-02`, `R34-03` (migrated, `.ufo/waves/round-38/expectation-migrations.json`) |
| adjacency | 9 → 9 | No sibling surface is claimed or absorbed; the release tag pages are the same vendor surfaces the feed rows already hold. Connector sweep: see the round-38 lesson's Wave settlement. | `R17-02`; `corpus/lessons/round-38.md` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 39 — pre-move (repo HEAD 0614451, round-38 close)

Claim BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`; predeclaration `1909e3876341cc90246516886def37a7c9ea92f9` (instruments, pins, frozen counters, controls, declared-axis manifest); frozen plan alone at `7c11e769cd7c2450cf46faabcd3b43fca993f388` (`plans/round-39.md`). Every axis stood at 9 at the round-38 close, so this table is the reference line the round's two claims are measured against; no value in it is a round-39 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | 93 registry rows at BASE, census CLEAN (row `R21-02`). | round 38 |
| operability | 9 | Unchanged: nine gate mode-sets with verdicts and selftests, plus two round-38 gates run on demand; nothing schedules any gate. | round 38 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: the round-37 counter `bash plans/round-37-c2.sh` cannot see an in-place rewrite of a superseded feed anchor (S034, S035, S039): no committed gate pins those cells (`plans/round-39.md` §C1; R37-V4). | round 38 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: no committed gate compares a claim's frozen axis with the SCORECARD row that reports it; round 38's C2 relabel passed unseen (R38-D1; `plans/round-39.md` §C2). | round 38 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`). | round 35 |

## Round 39 — post-move (claims C1 freshness, C2 calibration)

Measured commands and receipts: `.ufo/waves/round-39/`. The frozen predicates, counters, kill rules and targets are `plans/round-39.md` §C1/§C2 and are not amended after data. Scores stay 9 → 9: a claim move adds no new score; the capability rows record what the instruments do.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] Anchor-pin gate `corpus/anchor-pins.sh` binds the anchor cells of the three superseded feed rows (S034, S035, S039) to committed sha256 pins; the frozen counter `plans/round-39-c1.sh` reads 0 → 3 (the three in-place anchor rewrites M1–M3 each reported DRIFT). Capability row `anchor-pin drift detection`. | `plans/round-39-c1.sh`; `corpus/anchor-pins.sh`; `corpus/anchor-pins.tsv`; `corpus/lessons/round-39.md` §Gate, §Claims |
| calibration | 9 → 9 | [C2] Declared-axis gate `corpus/claims-declared.sh` compares each round-39 claim's plan heading and its tagged SCORECARD row with the frozen manifest `corpus/claims-declared.tsv`; the frozen counter `plans/round-39-c2.sh` reads 0 → 3 (planted relabels X1–X3 each reported MISMATCH). Capability row `declared-axis conformance`. Round 38 is not in the manifest: its untagged row is a named, unclaimed history gap. Lane-status reds `R25-02`, `R29-01`, `R29-02` stay named in this row, as in round 38 (self-description sweep SD5). | `plans/round-39-c2.sh`; `corpus/claims-declared.sh`; `corpus/claims-declared.tsv`; `corpus/lessons/round-39.md` §Mistakes M39-1 |
| operability | 9 → 9 | The guard's usage text now matches the form it accepts (`run -- LANE [--] CMD`, R38-EG-1; M39-2). No new scheduler; the two new gates run on demand. | `corpus/laneguard.sh`; `corpus/lessons/round-39.md` §Mistakes M39-2 |
| depth | 9 → 9 | No mechanism change. | `plans/round-39.md` |
| coverage | 9 → 9 | Registry 93 → 94: one own-work row S094 (`CORPUS.md` rule 2), no new entry, no frontier-to-core move; `entries_sourced` stays 14. | `R21-02`, `R31-02`, `R33-02`, `R34-03`, `R13-01`, `R24-06` are NOT migrated this round: they read the pre-round values and FAIL at the landing revision (named debt, `corpus/lessons/round-39.md` §Routed). No round-39 `expectation-migrations.json` exists. |
| adjacency | 9 → 9 | No sibling surface is claimed or absorbed; the connector sweep is in `.ufo/waves/round-39/build/`. | `R17-02`; `corpus/lessons/round-39.md` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 40 — pre-move (repo HEAD 6cc8850, round-39 close)

Claim BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa`; predeclaration `f687504767ce9ed56b848dfde83e03a1ec6cedd3`; frozen plan alone `38a118f9cf15729e7732cc3cafe1011e3a899ee4` (`plans/round-40.md`). Fresh-start round (operator "Authorize all", 2026-11-05). Every axis stood at 9 at the round-39 close; this table is the reference line the round's three claims are measured against; no value in it is a round-40 measurement except the named BASE readings.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | 94 registry rows at BASE, census CLEAN (row `R21-02`, failing at BASE as named debt). | round 39 |
| operability | 9 | Nine gate mode-sets with verdicts and selftests, plus the round-38/39 gates run on demand; nothing schedules any gate; the two round-39 gates carry no selftest and no registry row (routed defect, measured at BASE: `bash plans/round-40-c3.sh` → 0, `.ufo/waves/round-40/controls/c3-base.txt`). | round 39 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: S036 is an unpinned fourth superseded feed anchor (M39-7) and S040/S041 name the served-3.15.1 documentation while docs.python.org serves 3.15.2 (recheck due, marked in round 39; the refresh is this round's C2). | round 39 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-40-c1.sh` reads 6 at BASE (`.ufo/waves/round-40/controls/base-verify-at-tip.txt`): the six routed debt rows R13-01, R21-02, R24-06, R31-02, R33-02, R34-03 fail verify against the committed tree. | round 39 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`). | round 35 |

## Round 40 — post-move (claims C1 calibration, C2 freshness, C3 operability)

Measured commands and receipts: `.ufo/waves/round-40/`. The frozen predicates, counters, kill rules and targets are `plans/round-40.md` and are not amended after data. Scores stay 9 → 9: a claim move adds no new score; the rows record what moved and which reds remain.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-40-c1.sh` 6 → 0 at the candidate (`.ufo/waves/round-40/build/K40ExecLedger/c1-counter.txt`): the six routed debt rows re-run green after round-38-style measured migrations (R13-01 headings 50→54; R24-06 identity count 50→54 with the new sha; R21-02, R31-02, R33-02, R34-03 census summary rows=93→96), every old→new pair in `.ufo/waves/round-40/expectation-migrations.json`. **C1 is not admitted:** it is not causally separable from C2 (four migrated census rows move with the two C2 registry rows; with those rows removed the counter reads 4, critic F-C1-b), and the counter is forgeable by loosening the expect cells with no journal check (F-C1-a; routed to round 41). The fail-closed branches for a deleted row or a missing verify summary are code-only and were not executed; a constant-6 counter passes `c1_nowork` (M40-10). The routed reds stay operator-owned: R25-02 (FAIL), R29-01, R29-02, R38-03 (POLICY); the inherited FAIL rows R11-08, R22-03, R24-15, R36-03 are outside the frozen set and untouched. | `plans/round-40-c1.sh`; `.ufo/waves/round-40/expectation-migrations.json`; `corpus/lessons/round-40.md` §Wave settlement M40-5, M40-6, M40-10 |
| freshness | 9 → 9 | [C2] `bash plans/round-40-c2.sh` 0 → 3 at the candidate: S036's anchor cell is bound to a committed sha256 pin (`ANCHOR_PINS: CLEAN (pins=4)`, M39-7); S095 and S096 are tier-A documentation refresh rows opened 2026-11-05 on the served Python 3.15.2 pages (live re-fetch by scout seat K40ScoutDocs: no drift, captures byte-identical), each with a committed capture body, a fetch row whose sha binds the body, a verbatim quote located in the body, and the superseded row named; S040/S041 are not edited in place (CORPUS.md rule 2). **Ceiling, corrected:** the counter binds a row to its body by sha and locates the quote in that body, so a manifest-side forgery with fabricated bodies reads 3 (critic F-C2-a); 'forgeries cannot count' is withdrawn and only registry-only forgeries are controlled (`c2_forge_rows` → 1). Item 1 runs `corpus/anchor-pins.sh`, a file C3 amended (M40-8). | `plans/round-40-c2.sh`; `corpus/anchor-pins.tsv`; `corpus/SOURCES.md` (S095, S096); `corpus/source-fetches.tsv`; `.ufo/waves/round-40/capture/`; `.ufo/waves/round-40/build/K40ScoutDocs.md`; `.ufo/waves/round-40/build/K40CriticClaims/falsify.md` §2 |
| operability | 9 → 9 | [C3] `bash plans/round-40-c3.sh` 0 → 2 at the candidate: both round-39 gates are registered in SKILL.md's gate registry and carry committed `--selftest` modes (8 cases each; K40ExecGates reproduces both and shows each gate's constant-CLEAN mutant diverges). **Ceiling, corrected:** the counter reads the verdict token and the exit code, so a stub selftest that prints the PASS token plus forged registry rows reads 2 (critic F-C3-a); the claim is verified on its frozen predicate, not on case execution (M40-9). The candidate reading `0` taken before the one-line repair stays in `.ufo/waves/round-40/build/candidate-fast-gates.txt` (M40-3). Nothing schedules any gate. | `plans/round-40-c3.sh`; SKILL.md gate registry; `corpus/anchor-pins.sh --selftest`; `corpus/claims-declared.sh --selftest`; `.ufo/waves/round-40/build/K40ExecGates.md` |
| depth | 9 → 9 | No new mechanism claim; the gate amendments add detection detail on held instruments. | `plans/round-40.md` |
| coverage | 9 → 9 | Registry 94 → 96 and captures 94 → 96 (two tier-A documentation rows on already-held render-normalizer ground; no new entry, no frontier-to-core move; `entries_sourced` stays 14). The fleet W04 duplicate-URL count stays 19 (start and candidate, `.ufo/waves/round-40/census/`); the plan's 'six new W04 warnings' sentence is a plan-prose error with no claim effect (M40 wave settlement). | `R21-02` (migrated); `corpus/SOURCES.md`; `corpus/source-fetches.tsv`; `.ufo/waves/round-40/census/candidate-fleet.txt` |
| adjacency | 9 → 9 | No sibling surface is claimed or absorbed; the connector sweep is in `.ufo/waves/round-40/build/`. | `R17-02` |

**Round-40 verdicts (L1 reading, for the operator's ruling):** C1 not admitted (causal separability fails, M40-5); C2 verified as declared, with the forgery ceiling disclosed (M40-7); C3 verified on its frozen predicate, with the stub ceiling disclosed (M40-9). Under AXES.md a round is admitted only when every claim verifies and is causally separable, so the round is not admitted. No axis is harmed: all six stay 9 → 9.

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 41 — pre-move (repo HEAD 5142b52, round-40 close)

Claim BASE `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`; predeclaration `5142b52` (frozen plan `plans/round-41.md`, counters `plans/round-41-c1.sh` and `plans/round-41-c2.sh`, controls `plans/round-41-controls.sh`, measured BASE receipts `.ufo/waves/round-41/controls/`). Round-40 landed state (the positive control P0 of C1): `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`. Every axis stood at 9 at the round-40 close; this table is the reference line the two claims are measured against.

- **C1 calibration — BASE 0.** `bash plans/round-41-c1.sh` reads 0 at `5142b52`: no gate file exists (`git ls-tree 5142b52 corpus/expect-journal.sh` is empty). Controls `c1-control-{refuse-all,accept-all,no-gate}.txt` read 0, 0, 0. Target 4.
- **C2 freshness — BASE 1.** `.ufo/waves/round-41/controls/c2-base-19025d9.txt` reads 1 (a = 0, b = 0, c = 1). The decoy control `c2-control-decoy.txt` reads 2. Target 3.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract and the feed-token agreement invariant. Row `R29-01`. | round 29 |
| coverage | 9 | 96 registry rows at BASE, census CLEAN (row `R21-02`). The two rows this round appends are on already-held normalizer ground. | round 40 |
| operability | 9 | Nine gate mode-sets with verdicts and selftests; no committed journal gate at BASE (`corpus/expect-journal.sh` absent from `5142b52`). | round 40 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `plans/round-41-c2.sh` reads 1; the `rendered-text-v1.py` Sources paragraph cites no `S###` id and carries no bound quote (round-40 spot-check §5, §7.5). | round 40 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: the counter reads 0 and cannot tell a migration from a loosening (M40-6, M40-16). | round 40 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`). | round 35 |

## Round 41 — post-move (claims C1 calibration, C2 freshness)

Measured commands and receipts: `.ufo/waves/round-41/`. The frozen predicates, counters, kill rules and targets are `plans/round-41.md` and were not amended after data. Scores stay 9 → 9: a claim move adds no new score; the rows record what moved.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-41-c1.sh` 0 → 4 at the candidate: `corpus/expect-journal.sh` refuses the four frozen forgeries F1–F4 with their frozen tokens (`UNJOURNALED R13-01`, `OLD_MISMATCH R21-02`, `NOT_LITERAL R13-01`, `COMMAND_MISMATCH R24-06`) and accepts the round-40 positive control P0 (`EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`). Blanket-refuse and blanket-accept controls read 0. The six round-40 debt rows are migrated to the committed tree at landing (`.ufo/waves/round-41/expectation-migrations.json`). Ceilings: the gate does not re-run commands and does not judge reason text; a row deletion is outside the frozen classes (routed to round 42). Lane-status reds `R25-02`, `R29-01`, `R29-02` stay named in this row, as in rounds 39 and 40. | `plans/round-41-c1.sh`; `corpus/expect-journal.sh`; `.ufo/waves/round-41/controls/`; `corpus/lessons/round-41.md` §Claims |
| freshness | 9 → 9 | [C2] `bash plans/round-41-c2.sh` 1 → 3 at the candidate: the `rendered-text-v1.py` Sources paragraph cites S095, S096 and S097 (none superseded), carries the frozen quote on one line, and S095's capture body binds to its fetch row (sha `ef2d8abe…`, locate exit 0); `--selftest` PASS (cases=22). S097 admitted (`str.isspace()` whitespace definition, opened 2026-11-05); S098 rejected (UTS #18 `\s` = White_Space excludes U+001C–U+001F). Ceiling: the counter certifies citation shape, one quote and a body binding, not sentence-level grounding (reviewer attack TA4/TA6 green by design). | `plans/round-41-c2.sh`; `corpus/rendered-text-v1.py`; `corpus/SOURCES.md` rows S097, S098; `corpus/source-fetches.tsv`; `.ufo/waves/round-41/capture/` |
| depth | 9 → 9 | No mechanism claim. | `plans/round-41.md` |
| coverage | 9 → 9 | Registry 96 → 98 (S097 mined, S098 rejected) on already-held normalizer ground; `entries_sourced` stays 14. | `R21-02` (migrated) |
| operability | 9 → 9 | The C1 gate carries a committed `--selftest` (cases=7). Nothing schedules it. | `corpus/expect-journal.sh --selftest` |
| adjacency | 9 → 9 | No sibling surface claimed or absorbed; connector sweep in `.ufo/waves/round-41/build/K41ConnOverlap.md`. | `R17-02` |

**Round-41 verdicts (L1 reading, for the operator's ruling):** C1 and C2 measured at their frozen targets (4 and 3) with the controls at their predicted readings. Admission is reserved to the non-author closure (`corpus/lessons/round-41.md` §Claims, §Routed). No axis is harmed: all six stay 9 → 9.

## Erratum to the Round 40 post-move block (appended; the filed bytes are not rewritten)

The round-40 post-move section (line 1516 at the round-40 close) states: "The frozen predicates, counters, kill rules and targets are `plans/round-40.md` and are not amended after data." That sentence is contradicted by round 40's own lesson, which records **M40-3**: the C3 counter's verdict grep doubled `_SELFTEST`, so it read `0` at one candidate measurement, was repaired to read `2`, and that pre-repair reading is kept in `.ufo/waves/round-40/build/candidate-fast-gates.txt`. The correction is this appended erratum, not a rewrite of the filed bytes (routed by `corpus/lessons/round-40-verifier-spotcheck.md` §7 item 3).

## Round 42 — pre-move (repo HEAD e8265c0, round-41 close)

Claim BASE `e8265c0d90b01fcce0447d2f70615b0592ed145f`; predeclaration `98dd4de` (frozen plan `plans/round-42.md`, counters `plans/round-42-c1.sh` and `plans/round-42-c2.sh`, controls runner `plans/round-42-controls.sh`, BASE receipts under `.ufo/waves/round-42/controls/`); amendment A1 `fdbb83d` and amendment A2 `ca0c6a9` (both before any candidate). Every axis stood at 9 at the round-41 close; this table is the reference line the two claims are measured against.

- **C1 calibration — BASE 4.** `bash plans/round-42-c1.sh` reads 4 at the claim BASE (`.ufo/waves/round-42/controls/c1-base.txt`): the round-41 gate refuses F1–F4 and accepts F5, an unjournaled deletion of `R17-02`. Blanket-refuse 0 and blanket-accept 0 (`c1-control-refuse-all.txt`, `c1-control-accept-all.txt`). Target 5.
- **C2 freshness — BASE 0.** `bash plans/round-42-c2.sh` reads 0 at the claim BASE (`.ufo/waves/round-42/controls/c2-base.txt`): the committed runner writes a worktree reading, 3 (`c2-worktree-at-base.txt`), where the frozen derivation D reads 1 (`c2-derivation-D.txt`), and the committed receipt reads 1. Target 1.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | 98 registry rows at BASE, census `kagi ok` (row `R21-02`); this round re-opens S094 and adds no row. | round 41 |
| operability | 9 | Gate mode-sets with verdicts and selftests green; the controls runner's C2 BASE line is a worktree reading (receipt 1, worktree 3). | round 41 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-42-c2.sh` reads 0; the committed receipt `.ufo/waves/round-41/controls/c2-base-19025d9.txt` reads 1 while the same runner at the same commit reads 3. | round 41 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-42-c1.sh` reads 4; a deleted base row is in neither population of the journal gate's frozen classes and passes `CLEAN` (round-41 spot-check, routed item 4). | round 41 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`); 86 ledger ids at the base ledger, at P0 and at BASE, none removed. | round 35 |

## Round 42 — post-move (claims C1 calibration, C2 freshness)

Measured commands and receipts: `.ufo/waves/round-42/`. The frozen predicates, counters, kill rules and targets are `plans/round-42.md` (with amendments A1 and A2) and were not amended after data. Axis scores stay 9 → 9: a claim move adds no new score; the rows record what moved, as in rounds 36–41. Candidate: `d00a543`; the landed measurements are `.ufo/waves/round-42/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 4 → 5 (score 9 → 9) | [C1] `bash plans/round-42-c1.sh` at `d00a543` reads 5 (target 5): the journal gate refuses F1–F5 with their frozen tokens and accepts P0; `DELETED <ID>` is unconditional for every base id absent from the candidate. Blanket controls 0 and 0. Kill clauses (a) landing `CLEAN (changed=6 journaled=6)`, (b) N = 5, (c) selftest `PASS (cases=8)`: none fired. Declared ceilings: reason text not judged; a legitimate retirement is refused until a retirement form exists; F5 forges one row. Named ceilings found by attack seats: an answer-key gate reaches 5 with the blanket controls at 0; two counter-level mutants survive the frozen controls (`c1-M3`, `c1-M5`). | `plans/round-42-c1.sh`; `corpus/expect-journal.sh`; `.ufo/waves/round-42/final/c1-final.txt` (5), `final/c1-blanket-refuse.txt` (0), `final/c1-blanket-accept.txt` (0), `final/landing-r41.txt`, `final/gate-selftest.txt`; `corpus/lessons/round-42.md` §Claims, §Mistakes M41-6, M42-3 |
| freshness | 0 → 1 (score 9 → 9) | [C2] `bash plans/round-42-c2.sh` at `d00a543` reads 1 (target 1): the controls runner's C2 BASE line is produced from a `git archive 19025d9` extraction with the frozen counter from `5142b52`, so the receipt is re-derivable from the revision it names. A2 closes a do-nothing hole (a runner that writes nothing read 1; after A2 it reads 0). Ceiling (named): the counter checks the receipt value, not the runner's source; a constant-1 runner passes, and a receipt copied from a later commit passes. | `plans/round-42-c2.sh`; `plans/round-41-controls.sh`; `.ufo/waves/round-42/final/c2-final.txt` (1); `.ufo/waves/round-42/controls/c2-base.txt` (0); `corpus/lessons/round-42.md` §Claims, §Mistakes M41-4, M42-1, M42-2 |
| depth | 9 → 9 | No mechanism claim. | `plans/round-42.md` |
| coverage | 9 → 9 | No registry row added or changed; S094 re-opened as an existing row. Census `kagi ok`, 98 rows. | `R21-02`; `corpus/SOURCES.md` |
| operability | 9 → 9 | The gate's selftest gains a case (7 → 8) and the controls runner's C2 BASE line is re-derivable; nothing schedules either. | `corpus/expect-journal.sh --selftest`; `plans/round-41-controls.sh` |
| adjacency | 9 → 9 | Connector sweep over 20 sibling lanes: no sibling implements a ledger-deletion refusal (`REFUSE DELETED <ID>`: 0 hits). Overlap, recorded: kake r91 implements a revision-pinned controls replay with an enforcing counter, the same defect class as C2 (fleet prior art, not claimed as kagi's); lore r96–r98 and kasegi r42 J12 hold the C1 rationale. Lineage in `corpus/lessons/round-42.md` §Adjacency. | `R17-02`; `.ufo/waves/round-42/build/K42ConnOverlap/ConnOverlap.md` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here.

## Round 43 — pre-move (repo HEAD 5f3566c, round-42 close)

Claim BASE `5f3566c4cfe65a74da4d201d74d28b403929807b`; predeclaration `a9180250955ad44530b565fa5b131b540c849199` (frozen plan `plans/round-43.md`, counters `plans/round-43-c1.sh`, `-c2.sh`, `-c3.sh`, controls runner `plans/round-43-controls.sh`, BASE receipts under `.ufo/waves/round-43/controls/`); amendments A1 `dd6ccb92` and A2 `f2b4ec76`, both before any candidate measurement. All six axes stood at 9 at the round-42 close; this table is the reference line the three claims are measured against.

- **C1 calibration — BASE 5 (round-42 instrument).** The round-43 counter does not exist at BASE. The round-42 counter reads 5 at BASE, and its three broken shapes (guard-drop, token-drop, answer-key) all read 5. Target 6, with broken-shape rejection 3/3.
- **C2 freshness — BASE 0.** No committed gate re-derives the controls receipts; `bash plans/round-43-c2.sh` reads 0 at BASE (`controls/c2-base`). The eight-receipt manifest re-derives 8/8 at 5f3566c (`controls/c2-manifest-rederive-base.txt`). Target 1.
- **C3 operability — BASE 0.** Five gate selftests carry `TMPDIR`/`/tmp` scratch defaults; `bash plans/round-43-c3.sh` reads 0 (`controls/c3-base`). Target 5.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`). | round 29 |
| coverage | 9 | 98 registry rows at BASE, census `kagi ok` (`R21-02`). | round 41 |
| operability | 9 | Unchanged as a score; measured BASE gap: `c3-base` 0 (five `/tmp` defaults). | round 41 |
| freshness | 9 | Unchanged as a score; measured BASE gap: `c2-base` 0 (no gate). | round 41 |
| calibration | 9 | Unchanged as a score; measured BASE gap: round-42 counter 5 with three broken shapes passing. | round 41 |
| adjacency | 9 | Unchanged: ownership partition gate green (`R17-02`); 86 ledger ids at BASE, none removed. | round 35 |

## Round 43 — post-move (claims C1 calibration, C2 freshness, C3 operability)

Measured commands and receipts: `.ufo/waves/round-43/final/` (candidate `542885ed1514fd01d4e949caa5fab58eb000fffc`, measured in a clone of that commit). The frozen predicates, counters, kill rules and targets are `plans/round-43.md` with amendments A1 and A2; none was amended after data. Axis scores stay 9 → 9: a claim move adds no new score; the rows record what moved, as in rounds 36–42.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 5 → 6 (score 9 → 9) | [C1] `bash plans/round-43-c1.sh` reads 6 at the candidate (target 6): six forgeries F1–F6 refused with their tokens; F6 is the deletion of `R11-03`. The instrument now rejects the three broken shapes it used to accept: `c1-new-m3-K1` 6 (was 5), `c1-new-m5-K3` 6 (was 5), `c1-new-fakeC` 5 against target 6 (was 5 against 5). Broken-shape rejection 0/3 → 3/3. Blankets 0 and 0. Journal-gate bytes unchanged. Named ceilings: a six-key answer-key gate still reaches 6; the missing-gate branch and the grep-q token form survive counter mutation (`K43ReviewC1` x5, x9). | `plans/round-43-c1.sh`; `.ufo/waves/round-43/final/c1-new-real`, `c1-new-m3-K1`, `c1-new-m5-K3`, `c1-new-fakeC`, `c1-blanket-*`; `corpus/lessons/round-43.md` §Claims, §Mistakes M43-1, M43-6 |
| freshness | 0 → 1 (score 9 → 9) | [C2] `bash plans/round-43-c2.sh` reads 1 at the candidate (target 1): the committed gate `corpus/controls-replay.sh` verifies the clean clone (P1), refuses the stale and silent fixtures (N1, N2), and restores the controls directories on every path. Blankets 0 and 0. Named ceilings: the gate's default verification is reviewed as code, not by the counter (a shape-keyed gate reads 1, `K43ReviewC2` item 3); the counter's N1 and N2 legs have no negative fixture in the frozen battery (`K43MutCounters` y1, y2). | `corpus/controls-replay.sh`; `.ufo/waves/round-43/final/c2-base` (1), `c2-blanket-0` (0), `c2-blanket-1` (0); `controls/c2-manifest-rederive-base.txt` (8/8); `corpus/lessons/round-43.md` §Claims, §Mistakes M43-5, M43-7 |
| operability | 0 → 5 (score 9 → 9) | [C3] `bash plans/round-43-c3.sh` reads 5 at the candidate (target 5): `anchor-pins.sh`, `claims-declared.sh`, `prefreeze-control.sh`, `self-description-sweep.sh` and `surface-census.sh` carry no `TMPDIR`/`/tmp` default, and each selftest prints its frozen PASS line. Fixture controls: `c3-pos` 1 and `c3-blanket` 4 (predeclaration receipts, A2-7); 7 changed lines in 5 files. | `corpus/anchor-pins.sh`; `corpus/claims-declared.sh`; `corpus/prefreeze-control.sh`; `corpus/self-description-sweep.sh`; `corpus/surface-census.sh`; `.ufo/waves/round-43/controls/c3-base`, `c3-pos`, `c3-blanket`; `corpus/lessons/round-43.md` §Claims, §Mistakes M43-2, M43-3 |
| depth | 9 → 9 | No mechanism claim. | `plans/round-43.md` |
| coverage | 9 → 9 | No registry row added; S094 `used-by` extended (round-42 routed item 2); census `kagi ok`, 98 rows. | `R21-02`; `corpus/SOURCES.md` S094 |
| adjacency | 9 → 9 | Connector sweep recorded in `corpus/lessons/round-43.md` §Adjacency; nothing absorbed. | `R17-02` |

**Round-43 verdicts (L1 reading, for the operator's ruling):** C1, C2 and C3 each measured at its frozen target (6, 1, 5), with their no-work readings at their predicted values (5 for the round-42 instrument, 0, 0). No axis is harmed: all six stay 9 → 9. The named ceilings above are not closed.

**Planned (next — round 43 close):** a round-44 claim against the C2 counter's N1/N2 negative fixtures (`K43MutCounters` y1, y2; routed item 2) and scheduling for `corpus/controls-replay.sh` (routed item 3), both by counter amendment before data.

## Round 44 — pre-move (repo HEAD d54109d, round-43 close)

Claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a` (the round-43 verifier spot-check's verified
tip); predeclaration `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae` (frozen plan `plans/round-44.md`,
counters `plans/round-44-c1.sh` / `-c2.sh` / `-c3.sh`, controls runner `plans/round-44-controls.sh`,
prefreeze controls `plans/round-44.controls.tsv`, BASE receipts and fixtures under
`.ufo/waves/round-44/controls/`, and the claims-declared repair rows for rounds 41/43 — all
committed alone before any candidate work). All six axes stood at 9 at the round-43 close; this
table is the reference line the three claims are measured against; no value in it is a round-44
measurement.

- **C1 calibration — BASE 0.** The counter-mutation battery does not exist at the BASE
  (`bash plans/round-44-c1.sh d54109d` → `controls/c1-base` = 0): the round-43 C2 counter's two
  mutation survivors (`K43MutCounters` y1 = N1-stale-leg drop, y2 = N2-silent-leg drop, M43-7) are
  discriminated by no committed instrument. Target 2.
- **C2 operability — BASE 0.** No receipt of the round-43 replay gate's own run exists at the BASE
  (`bash plans/round-44-c2.sh d54109d` → `controls/c2-base` = 0; prefreeze row `receipt_absent` 0);
  `corpus/controls-replay.sh` is run by nothing (round-43 routed item 3). Target 1.
- **C3 freshness — BASE 0.** No corrections register exists at the BASE
  (`bash plans/round-44-c3.sh d54109d` → `controls/c3-base` = 0; prefreeze row `register_absent`
  0): the three drifted round-42-era receipts (c1-base 4→5, c2-base 0→1, c2-worktree-at-base
  written by no committed runner) are disclosed only inside receipts. Target 3.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | 98 registry rows at the BASE, census `kagi ok`, exit 0 (`.ufo/waves/round-44/controls/census-start.txt`). Row `R21-02`. | round 41 |
| operability | 9 | Unchanged as a score. Measured BASE gap: `c2-base` = 0 — the round-43 replay gate's own run is receipted nowhere; forged fixtures `c2-forged-sha`/`c2-forged-rev` read 0. | round 43 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `c3-base` = 0 — no committed record supersedes the three drifted round-42-era control receipts. | round 43 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `c1-base` = 0 with the two C2-counter mutation survivors undiscriminated (M43-7); the round-43 instrument's named answer-key ceiling stands. | round 43 |
| adjacency | 9 | Ownership partition gate green (row `R17-02`); 86 ledger ids at the BASE, none removed. | round 35 |

## Round 44 — post-move (claims C1 calibration, C2 operability, C3 freshness)

Candidate `0ad617a0c255a2141df8a9fa46bd6114be0bf75e` (landed); content revision `c70bfb0b6db5c2df090034d63f9c38e935a1a786` (amendment A1, pin re-anchored); claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a`. Measured receipts: `.ufo/waves/round-44/final/` (`c1-real` 2, `c2-real` 1, `c3-real` 3, the controls `c1-skipfix` 0, `c1-partial` 1; kill-rule receipts `killrules-at-L.txt`). The frozen predicates, counters, kill rules and targets are `plans/round-44.md` (with amendment A1, before any candidate measurement); none was amended after data. Axis scores stay 9 → 9: a claim move adds no new score; the rows record what moved.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-44-c1.sh 0ad617a0…` 0 → 2 (target 2): the battery discriminates both round-43 counter survivors (y1 and y2, M43-7) with its paired negative fixture gates and refuses the blanket shapes. Controls: no-fixture battery (`R44_SKIP_FIXTURES=1`) 0; one-fixture battery 1; BASE (battery absent) 0. Ceilings named: the always-refuse conjunct is not discriminated by any frozen receipt (B1, routed to round 45); a six-key answer-key gate is outside the battery. | `plans/round-44-c1.sh`; `.ufo/waves/round-44/final/c1-real`, `c1-skipfix`, `c1-partial`; `corpus/lessons/round-44.md` §Claims, §Routed 1 |
| operability | 9 → 9 | [C2] `bash plans/round-44-c2.sh 0ad617a0…` 0 → 1 (target 1): the replay gate's own run is receipted at its content revision with the gate's sha256 bound, and the counter re-executes the gate in a fresh clone. Forged receipts read 0 (wrong sha 0, wrong revision 0). Ceilings named: a fabricated receipt naming a real green revision with the same gate bytes passes; scheduling the gate is refused (host state). | `plans/round-44-c2.sh`; `.ufo/waves/round-44/final/c2-real`, `killrules-at-L.txt`; `.ufo/waves/round-44/final/replay-at-tip.txt` |
| freshness | 9 → 9 | [C3] `bash plans/round-44-c3.sh 0ad617a0…` 0 → 3 (target 3): the three drifted round-42-era receipts are superseded by a register whose committed and re-derived values are re-executed at the pinned revision `5f3566c`, with the `via` runner and the disposition blob checked. Fixtures: full register 3, wrong-values register 1, no register at BASE 0. Ceilings named: the re-derivation runs the hardcoded runner `plans/round-42-controls.sh` (the `via` cell is checked as text); the Basis line is checked as text, not as S099's truth. | `plans/round-44-c3.sh`; `.ufo/waves/round-44/final/c3-real`; `.ufo/waves/round-44/controls/receipt-corrections.md`; `corpus/lessons/round-44.md` §Claims, §Mistakes M44-1..M44-3 |
| depth | 9 → 9 | No mechanism claim this round. | `plans/round-44.md` |
| coverage | 9 → 9 | Registry 98 → 99: one own-work row S099 (tier A, mined), no new knowledge entry, no frontier-to-core move; census `kagi ok`, rc 0, 99 rows. | `corpus/SOURCES.md` S099; `corpus/lessons/round-44.md` §Gate |
| adjacency | 9 → 9 | Connector sweep: 46 hit-classes, overlap 4 (kake r91 for C2, tameshi r14 for C3 — fleet prior art, recorded, not claimed); the ownership partition is unchanged. | `R17-02`; `.ufo/waves/round-44/build/K44ConnOverlap.md` |

## Round 45 — post-move (claims C1 calibration, C2 coverage)

Candidate: the round-45 landing commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `0d0192f63eb5e49826d75af1e5293004dc691a18`; predeclaration `307fb50da825d6e6f2b5c7981c71556d35611142`; amendment A1 `c74ca51b9e867ac2d18e92664662f2115705c099` (pre-candidate, `plans/round-45.md` §Amendment A1). Frozen counters `plans/round-45-c1.sh`, `plans/round-45-c2.sh`. Measured receipts: `.ufo/waves/round-45/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-45-c1.sh <candidate>` 0 → 2 (target 2): the claims-declared gate now reports a landed plan claim that has no manifest row. Fixtures A and B (planted omissions) each MISMATCH; fixture C (axis relabel) still MISMATCH; the real tree stays CLEAN (claims=15 at the BASE, 17 with rows 45 C1 and C2 once the post-move section exists). Ceiling named: rounds below 39 are out of scope; a plan with headings and no post-move section is not checked (round 46 audits round 45). | `plans/round-45-c1.sh`; `corpus/claims-declared.sh`; `corpus/claims-declared.tsv` rows 45 C1, 45 C2; `.ufo/waves/round-45/controls/c1-base.txt` (value 0); `corpus/lessons/round-45.md` §Claims |
| coverage | 9 → 9 | [C2] `bash plans/round-45-c2.sh <candidate>` 0 → 3 (target 3): one knowledge entry on ISO/IEC 11770-3 edition status (`knowledge/iso-11770-3-edition-status.md`), three registry rows S100–S102 with located quotes against committed decoded bodies; census `kagi ok` rc 0. Ground the lane did not hold (`grep -l 11770 corpus/knowledge/*.md` was empty at BASE). Not frontier-to-core of a held surface: the scope boundary excludes key lifecycle management. | `plans/round-45-c2.sh`; `corpus/knowledge/iso-11770-3-edition-status.md`; `corpus/SOURCES.md` S100–S102; `corpus/quote-bodies.tsv`; `corpus/source-fetches.tsv`; `.ufo/waves/round-45/controls/capture-r45/` |
| depth | 9 → 9 | No mechanism claim this round. | `plans/round-45.md` |
| freshness | 9 → 9 | No freshness claim this round. Measured in passing: staged ISO catalogue claim "Cloudflare 403, could not be opened" is stale for a browser user agent (HTTP 200 on 2026-11-05); corrected in the entry's access note. | `corpus/knowledge/iso-11770-3-edition-status.md` §Access note |
| operability | 9 → 9 | No operability claim this round. | `plans/round-45.md` |
| adjacency | 9 → 9 | Connector sweep (K45Connector): no sibling gate binds plan headings to a manifest; ISO/IEC 11770-3 is held by no sibling lane entry (see the wave's connector report). | `.ufo/waves/round-45/build/K45Connector.md` |

## Round 46 — post-move (claims C1 operability, C2 freshness)

Candidate: the round-46 landing commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `f5977284a8ce5bab09252be8196ee5dc18489926`; predeclaration `44808ced56359c98f35995178fb24a6482899263` (frozen plan `plans/round-46.md`, counters `plans/round-46-c1.sh`, `plans/round-46-c2.sh`, pre-freeze controls `plans/round-46-controls.py`, 11 MATCH). Measured receipts: `.ufo/waves/round-46/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-46-c1.sh <candidate>` 0 → 3 (target 3): the declared-claim gate's own `--selftest` (8 → 11 cases) now kills the three frozen mutants of its round-45 plan-to-manifest leg (report silenced, floor 39 → 99, post-move test inverted) while the four equivalent mutants still pass and the real tree stays CLEAN. Surface: the `--run-selftest` block only; the claim-checking logic is byte-identical. One planted-omission case (round 90) kills all three; the floor case (round 39) and the in-flight case (round 91) pin the scope edges. | `plans/round-46-c1.sh`; `corpus/claims-declared.sh` cases 9–11; `.ufo/waves/round-46/controls/c1-base.txt` (value 0); `corpus/lessons/round-46.md` §Claims |
| freshness | 9 → 9 | [C2] `bash plans/round-46-c2.sh <candidate>` 0 → 29 (target 29): all 29 BASE `on-release` rows re-observed live on 2026-11-06 (`.ufo/waves/round-46/final/observe-r46.json`, 29 records, http 200, failed 0) and the release-clock gate reads CLEAN on the real tree again (FAILED on every tip from the round-39 landing `4776f71` to BASE). Composition: 19 version clocks (no release since 2026-11-04: SOPS 3.13.3, Vault 2.2.1, OpenBao 2.7.2, Python 3.15.2, curl 8.23.0), 10 quote clocks located, S098 bound to its `Revision 25` quote; 13 clocks stay fired (re-observed, not rearmed). S040/S041 clock rows retired (their registry rows left on-release in round 39). | `plans/round-46-c2.sh`; `corpus/release-clocks.tsv`; `corpus/release-clock.py` default receipt; `.ufo/waves/round-46/controls/c2-base.txt` (value 0); non-author live re-observation `.ufo/waves/round-46/build/K46ReviewerLive/report.md` (29/29 agree) |
| calibration | 9 → 9 | No claim. Measured in passing: ledger row R36-03 read red on every verify from round 40 to 45 and was carried as inherited (M46-1); its expect is migrated with a BASE red witness; `PROVINCE.md:75` and `SKILL.md:48` still said S040/S041 keep on-release cadence (false since round 39), corrected. | `corpus/lessons/round-46.md` §Mistakes; `.ufo/waves/round-46/expectation-migrations.json` |
| coverage | 9 → 9 | No claim. Coverage map rows added for two held entries (round-45 closure routed 1); no new ground. | `corpus/README.md` |
| depth | 9 → 9 | No claim. | `plans/round-46.md` |
| adjacency | 9 → 9 | No claim. Connector sweep: see the wave's connector report. | `.ufo/waves/round-46/build/K46Connector.md` |

## Errata (append-only; a correction never overwrites the line it corrects)

- **E47-1 — round-46 operability row (`SCORECARD.md:1695`).** The row says the declared-claim gate's own `--selftest` went "(8 → 11 cases)" and cites "`corpus/claims-declared.sh` cases 9–11". Against the committed bytes the correct reading is **(8 → 12 cases)**, cases **9–12**: `git show f4a33d3d:corpus/claims-declared.sh | grep -n 'cases" -eq'` → `122: … [ "$cases" -eq 12 ]` (BASE `f5977284` line 102 `-eq 8`); case 12 (`same-claim-second-axis`, reviewer K46RP-02) is at lines 118–121. No score changes; line 1695 keeps its text. Receipt `.ufo/waves/round-47/build/K47ScribeLesson/case-count-check.txt`; lesson `corpus/lessons/round-47.md` M47-1.

## Round 47 — post-move (claims C1 calibration, C2 freshness)

Candidate: the round-47 candidate commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`; predeclaration `b020d978bac91284a431710148ebb7a7950eaab8` (frozen plan `plans/round-47.md`, counters `plans/round-47-c1.sh`, `plans/round-47-c2.sh`, pre-freeze controls `plans/round-47-controls.py`, 17 MATCH). Measured receipts: `.ufo/waves/round-47/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-47-c1.sh <candidate>` 0 → 3 (target 3): the lane-local census `bash corpus/sources-census.sh` reads CLEAN (BASE FAILED, 3 findings): `source:` lines in `corpus/lessons/round-43.md` (S094) and `round-44.md` (S099), and an S099 fetch-provenance row bound to the fleet blob `75dd2612:.ufo/prompts/kagi-round-44.md` (capture `.ufo/waves/round-47/capture/S099.body`); registry intact, `used-by` not narrowed. Also: SCORECARD erratum E47-1 above. Critic ruling recorded: weakened as calibration (registry self-description, not a score cell). The three operator-routed reds R25-02, R29-01, R29-02 stay red (untouched this round). | `plans/round-47-c1.sh`; `.ufo/waves/round-47/controls/c1-base.txt` (value 0); `corpus/lessons/round-47.md` §Claims |
| freshness | 9 → 9 | [C2] `bash plans/round-47-c2.sh <candidate>` 0 → 11 (target 11): the teaching quotes of the eleven fired Vault/OpenBao clock rows S012–S016, S021–S026 located in live captures of 2026-11-06 (`corpus/fired-reverify.tsv`, 11 × `teaching-holds`); release-clock gate CLEAN, clocks not re-armed. Also: S040/S041 overdue recheck `2026-11-05` → `90d` after a live re-open. | `plans/round-47-c2.sh`; `corpus/fired-reverify.tsv`; `.ufo/waves/round-47/build/K47ExecC2/teaching-notes.md` |
| coverage | 9 → 9 | No claim. | `plans/round-47.md` |
| depth | 9 → 9 | No claim. | `plans/round-47.md` |
| operability | 9 → 9 | No claim. QM58 (counters run BASE-pinned instruments) added from M47-3. | `corpus/QUALITY.md` QM58 |
| adjacency | 9 → 9 | No claim. Connector: no sibling registry row teaches Vault/OpenBao; no sibling census tooling. | `.ufo/waves/round-47/build/K47Connector.md` |

## Round 48 — post-move (claims C1 operability, C2 calibration)

Candidate: the round-48 candidate commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c`; predeclaration `164f0ea5ed8b76a671f9b076158d1d8022881813`, amendment A1 `52991e5da64cbacaa724b28b407cf5765fd21b41` (frozen plan `plans/round-48.md`, counters `plans/round-48-c1.sh`, `plans/round-48-c2.sh`, pre-freeze controls `plans/round-48-controls.sh`, 16 MATCH). Stagnation nudge fired (all axes 9 = line 9; no capability since round 40), so C1 is a capability acquisition. Measured receipts: `.ufo/waves/round-48/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-48-c1.sh <candidate>` 0 → 5 (target 5): capability acquisition — `corpus/sops-age-trial.sh` executes the SOPS/age mechanics the entry documents (T1 updatekeys-add keeps the data key, T2 rotate re-encrypts, T3 removal refuses the synced file while a pre-removal copy still opens, T4 creation-rule edit alone changes nothing, T5 two groups default to threshold 2) on sops 3.13.3 / age-keygen v1.3.2 with throwaway identities; each test flips to BROKEN under its falsifier shim; entry `## Measured (round 48 …)` appended; capability row added. Named ceilings: a trial that detects the shims passes (K48CriticCeiling: value 5); T2's observable does not separate a new data key from fresh nonces (K48RT-02; measured separately). | `plans/round-48-c1.sh`; `corpus/sops-age-trial.sh`; `corpus/knowledge/sops-age-key-rotation.md` §Measured; `.ufo/waves/round-48/controls/c1-base.txt` (value 0) |
| calibration | 9 → 9 | [C2] `bash plans/round-48-c2.sh <candidate>` 3 → 0 (target 0): the §Capabilities evidence readings K02 (quote-locate), K07 (claims-declared count, revision-bound) and K10 (claims-declared selftest cases) agree with the commands' executed output again, through one current-readings line; no gate byte changed; history rows kept. Also `SKILL.md` claims-declared selftest `8 cases` → `12 cases` (current-tense line). The three operator-routed reds R25-02, R29-01, R29-02 stay red (untouched this round). | `plans/round-48-c2.sh`; `.ufo/waves/round-48/controls/c2-base.txt` (value 3); `corpus/lessons/round-48.md` M48-1 |
| coverage | 9 → 9 | No claim. Registry 102 → 104 (S103, S104 release identities, tier A, used by the round-48 lesson). | `corpus/SOURCES.md` S103–S104 |
| depth | 9 → 9 | No claim. The entry's two `[INFERENCE]` readings are now measured (T3, T4) and three narrowings recorded (K48CriticCeiling B1–B3). | `corpus/knowledge/sops-age-key-rotation.md` §Measured |
| freshness | 9 → 9 | No claim. S009–S011 re-opened live: bodies byte-identical to the round-21 captures. | `corpus/lessons/round-48.md` §Gate |
| adjacency | 9 → 9 | No claim. Connector: see the wave's connector report. | `.ufo/waves/round-48/build/K48Connector.md` |

## Round 49 — post-move (claims C1 operability, C2 calibration)

Candidate: the round-49 candidate commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `89afe91878f10805921d3caa67d28d21b33226da`; predeclaration `082bfb3f6baa2407df2a23c0489043495b4dce4d` (frozen plan `plans/round-49.md`, counters `plans/round-49-c1.sh`, `plans/round-49-c2.sh`, pre-freeze controls `plans/round-49-controls.sh`, 19 MATCH). No amendment. Measured receipts: `.ufo/waves/round-49/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-49-c1.sh <candidate>` 0 → 5 (target 5): capability acquisition — `corpus/openbao-token-trial.sh` executes the OpenBao token/lease mechanics the entry documents from S016 (T1 a non-root token stops at its TTL, T2 an explicit max TTL caps renewal, T3 a batch token is neither renewable nor manually revocable, T4 a userpass login token is an orphan, T5 a token's lapse revokes the PKI lease it issued) on OpenBao 2.7.2 against a throwaway `bao server -dev` on 127.0.0.1; each test flips to BROKEN under its falsifier shim; entry `## Measured (round 49 …)` appended; capability row added. Named ceilings: a trial that reads the counter's PATH passes the frozen counter (K49CriticClaims/K49CriticCeiling: value 5) — answered for this candidate by leg `leg-c1-transparency.sh` (shown able to fail); dev mode, one host, one release. | `plans/round-49-c1.sh`; `corpus/openbao-token-trial.sh`; `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` §Measured (round 49); `.ufo/waves/round-49/controls/c1-base.txt` (value 0); `corpus/lessons/round-49.md` §Claims |
| calibration | 9 → 9 | [C2] `bash plans/round-49-c2.sh <candidate>` 6 → 0 (target 0): the six frozen self-count keys read OK — the round-45 entry `corpus/knowledge/iso-11770-3-edition-status.md` now carries `Reverify: R21-02` and a stamp row, so `bash corpus/claim-ledger.sh docs` reads CLEAN (entries=36 row_linked=33 by_hand=3; BROKEN since `072bb0b`), and the stated stamp count in `SKILL.md`, `PROVINCE.md` and `corpus/README.md` equals the live row count. Ledger rows R12-03 and R14-01 migrated old→new with a journal (`.ufo/waves/round-49/expectation-migrations.json`). The three operator-routed reds R25-02, R29-01, R29-02 stay red (untouched this round). Named ceiling: the stamp count is revision-bound. | `plans/round-49-c2.sh`; `.ufo/waves/round-49/controls/c2-base.txt` (value 6); `corpus/lessons/round-49.md` M49-1 |
| coverage | 9 → 9 | No claim. Registry 104 → 105 (S105, OpenBao PKI API docs, tier A, used by the round-49 lesson). | `corpus/SOURCES.md` S105 |
| depth | 9 → 9 | No claim. The entry's OpenBao token rows are now measured with review narrowings (K49ReviewerTrial: T5 long-token contrast; T1 refusal text). | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` §Measured (round 49) |
| freshness | 9 → 9 | No claim. S016 re-opened live 2026-11-06: rendered-text digest equals the 2026-10-21 capture's; body identical to the round-47 capture. | `corpus/lessons/round-49.md` §Gate |
| adjacency | 9 → 9 | No claim. Connector: no sibling lane holds OpenBao/Vault token ground. | `.ufo/waves/round-49/build/K49Connector.md` |

## Round 50 — post-move (claims C1 operability, C2 calibration)

Candidate: C1 at `9e4dcbcc8666b22aa871037138826693fa0ba4fa`; C2 at the round-50 C2 commit (recorded in the report and in `.ufo/waves/round-50/final/c2-candidate.txt`, which names the revision it measures). Claim BASE `565c43a874b59cd216f4a55c8742db48fa854f16`; predeclaration `7d3b2c01b375d5459abd7da79bb4063b7d728fc7` (frozen plan `plans/round-50.md`, counters `plans/round-50-c1.sh`, `plans/round-50-c2.sh`, pre-freeze controls `plans/round-50-controls.sh`, 15 MATCH). No amendment. Measured receipts: `.ufo/waves/round-50/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-50-c1.sh 9e4dcbcc8666b22aa871037138826693fa0ba4fa` 0 → 3 (target 3; `C1_ORPHAN_SAFE: value=3 positive=1 reaped=0`, survivors 0 at K1, K2 and K3): `corpus/openbao-token-trial.sh` starts its dev server under `setpriv --pdeathsig KILL` (S106, S107), so a SIGKILLed trial shell no longer leaves a `bao server -dev` alive (round-49 closure D4); the round-49 counter still reads 5 on the candidate (POSITIVE). Named ceilings: Linux only; a parent dying between fork and prctl; a double-forked, environment-stripped server is invisible to the counter. | `plans/round-50-c1.sh`; `.ufo/waves/round-50/final/c1-base.txt`, `c1-candidate.txt` |
| calibration | 9 → 9 | [C2] `bash plans/round-50-c2.sh e4abab1d23b731c0c042be9bc50b19c9f9313dcb` 10 → 0 (target 0; `C2_LEDGER_DRIFT: value=0 ids=10 changed=10`, every frozen id OK); re-read at the landing tip in `.ufo/waves/round-50/final/c2-final.txt`. Harm found and repaired before the report: the full verify on `e4abab1d` showed R36-03 FAILED because S106/S107 landed `on-release` with no bound release clock (M50-4); both rows now `180d`, R36-03 CLEAN (`final/r36-03-repair.txt`). Ten population expects (SCORECARD headings R13-01/R24-06, census R21-02/R31-02/R33-02/R34-03, revision-audit additions R22-03/R24-15, stamp identity R24-05, round-38 located quotes R38-01) migrated old→new with a journal whose reasons name the commits that grew each population (`.ufo/waves/round-50/expectation-migrations.json`); the four operator-routed rows R25-02, R29-01, R29-02, R38-03 are byte-identical. Named ceiling: revision-bound populations. | `plans/round-50-c2.sh`; `.ufo/waves/round-50/final/c2-base.txt`, `c2-candidate.txt` |
| coverage | 9 → 9 | No claim. Registry 105 → 107 (S106 PR_SET_PDEATHSIG(2const), S107 setpriv(1); tier A, `recheck 180d`, used by the round-50 lesson; the trial cites both in its header). | `corpus/SOURCES.md` S106, S107 |
| depth | 9 → 9 | No claim. | — |
| freshness | 9 → 9 | No claim. S106/S107 opened live 2026-11-06 and re-fetched byte-identical by the L1. | `corpus/lessons/round-50.md` §Gate |
| adjacency | 9 → 9 | No claim. The attempt-1 connector seat left no output; no sibling-overlap scan this round. | `.ufo/waves/round-50/build-results.json` |

## Round 51 — post-move (claims C1 operability, C2 calibration)

Candidate: the round-51 landing commit (recorded in the report and in `.ufo/waves/round-51/final/c1-candidate.txt` / `c2-candidate.txt`, which name the revision they measure). Claim BASE `214d8bf530a0c87c00686493f21af15396284793`; predeclaration `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567` (frozen plan `plans/round-51.md`, counters `plans/round-51-c1.sh`, `plans/round-51-c2.sh`, pre-freeze controls `plans/round-51-controls.sh`, 20 MATCH). No amendment. Measured receipts: `.ufo/waves/round-51/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-51-c1.sh <candidate>` 0 → 5 (target 5): capability acquisition — `corpus/openbao-wrap-trial.sh` executes five OpenBao response-wrapping mechanics from S108/S109 (T1 single use, T2 wrap TTL separate from the secret, T3 unauthenticated lookup reports the creation path without consuming, T4 rewrap spends the old token, T5 a read-and-rewrap carries creation path `sys/wrapping/wrap`) on OpenBao 2.7.2 against a throwaway `bao server -dev`; each test flips to BROKEN under its falsifier shim in path-blind runs; entry `## Measured (round 51 …)` appended; capability row added. Named ceilings: the frozen counter's output path spells the run mode, so a non-running trial can read 5 (R51CriticC1 FA, M51-2) — admission rests on the counter plus the machine-checked kill rule (candidate = reference trial outside comments); the successor `plans/round-51-c1h.sh` reads 5 on the candidate and 0 on FA/FB. | `plans/round-51-c1.sh`; `.ufo/waves/round-51/final/c1-candidate.txt`, `c1h-controls.txt`; `corpus/lessons/round-51.md` §Claims |
| calibration | 9 → 9 | [C2] `bash plans/round-51-c2.sh <candidate>` 3 → 0 (target 0): the declared-claim gate reads `CLAIMS_DECLARED: CLEAN (claims=29)` (round-50 C1/C2 had no manifest row, M51-1) and the §Capabilities readings agree with the executed commands (K07). The `lane-status:` line now names the four operator-routed reds R25-02, R29-01, R29-02, R38-03 (round-50 closure F5); all four stay red, untouched this round. Named ceilings: the gate trusts the SCORECARD heading as the witness that a round landed, and the readings reader does not skip HTML comments (R51CriticC2). | `plans/round-51-c2.sh`; `.ufo/waves/round-51/final/c2-candidate.txt`, `c2-landing-checks.txt`; `corpus/claims-declared.tsv` |
| coverage | 9 → 9 | No claim. Registry 107 → 109 (S108 OpenBao response-wrapping concepts page, S109 `sys/wrapping/wrap` API page; tier A, `recheck 180d`). | `corpus/SOURCES.md` S108, S109 |
| depth | 9 → 9 | No claim. Measured beside the trial: `sys/wrapping/rewrap` keeps the original creation path on OpenBao 2.7.2, unlike the rewrap API page's sample response. | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` §Measured (round 51) |
| freshness | 9 → 9 | No claim. S108/S109 opened live 2026-11-07 and re-fetched byte-identical by two seats. | `corpus/lessons/round-51.md` §Gate |
| adjacency | 9 → 9 | No claim. Connector: no sibling lane holds response-wrapping ground or a declared-claim manifest gate. | `.ufo/waves/round-51/build/R51ConnectorSiblings.md` |

## Round 52 — post-move (claims C1 operability, C2 calibration)

Candidate: the round-52 landing commit (recorded in the report). `.ufo/waves/round-52/final/c1-candidate.txt` / `c2-candidate.txt` hold the readings of the candidate tree taken before that commit; the revision-bound readings of the landed commit follow in the round's receipts commit, named in the report (round-51 closure D2: no commit cites a receipt that lands later). Claim BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`; predeclaration `52ebb412561d9601ad8658c30d1cfa0087af64d4` (frozen plan `plans/round-52.md`, counters `plans/round-52-c1.sh`, `plans/round-52-c2.sh`, pre-freeze controls `plans/round-52-controls.sh`, 20 MATCH in `.ufo/waves/round-52/controls/controls-prefreeze.txt`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-52-c1.sh <candidate>` 0 → 5 (target 5): capability acquisition — `corpus/openbao-kv-versions-trial.sh` executes five OpenBao KV v2 version operations from S110 (T1 check-and-set, T2 soft delete reversed by undelete, T3 destroy not reversed, T4 max-versions drops version 1, T5 metadata delete removes every version), with no secret on any argv (NOARGV conjunct) and the round-51 counter hardenings H1–H3 adopted. | `.ufo/waves/round-52/final/c1-candidate.txt`; capability row "OpenBao KV v2 version-lifecycle trial" |
| calibration | 9 → 9 | [C2] `bash plans/round-52-c2.sh <candidate>` 2 → 0 (target 0): the two lane lines that judged the rewrap API page's sample against the binary (`vault-openbao-token-lease-lifecycle.md:292`, `lessons/round-51.md:22`, round-51 closure D1) each carry an appended `Correction (round 52, D1)` stating the probe's two creation paths (helper-made input `sys/wrapping/wrap`, KV input `secret/data/<path>`); no BASE line rewritten. | `.ufo/waves/round-52/final/c2-candidate.txt`; erratum E52-1 below |
| coverage | 9 → 9 | No claim. Registry 109 → 110 (S110 OpenBao KV v2 page; tier A, `recheck 180d`); coverage map gains the executed KV v2 version-lifecycle entry. | `corpus/SOURCES.md` S110; `corpus/README.md` coverage map |
| depth | 9 → 9 | No claim. New entry `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` (five measured lines, named ceilings). | entry §Measured (round 52) |
| freshness | 9 → 9 | No claim. S110 opened live 2026-11-07; re-fetched with the declared request profile byte-identical. | `corpus/lessons/round-52.md` §Gate |
| adjacency | 9 → 9 | No claim. | `.ufo/waves/round-52/build/R52ConnectorSiblings.md` |

- **E52-1 — round-51 depth row (`SCORECARD.md:1783` at the round-52 candidate; `:1778` at BASE).** The row says rewrap keeps the original creation path "unlike the rewrap API page's sample response". The sample never states its input token's creation path, and a helper-made token keeps `sys/wrapping/wrap` through rewrap on OpenBao 2.7.2 (C2 probe), so the sample is consistent with the binary; only the KV-path half of the row stands. Recorded here, append-only; the C2 counter's lexical pattern does not see this row (plan §C2 named ceiling).

## Round 53 — post-move (claims C1 freshness, C2 calibration)

Candidate: the round-53 landing commit (recorded in the report). `.ufo/waves/round-53/final/c1-candidate-tree.txt` / `c2-candidate-tree.txt` hold the readings of the candidate tree taken before that commit; the revision-bound readings of the landed commit follow in the round's receipts commit, named in the report (round-52 closure D1). Claim BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`; predeclaration `39460f8676954f135d15fa99b43cd882360b3eee` (frozen plan `plans/round-53.md`, counters `plans/round-53-c1.sh`, `plans/round-53-c2.sh`, pre-freeze controls `plans/round-53-controls.sh`, 22 MATCH in `.ufo/waves/round-53/controls/controls-prefreeze.txt`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-53-c1.sh <candidate>` 0 → 2 (target 2): S103 (SOPS v3.13.3) and S104 (age v1.3.2), whose teaching states the tag is the project's current stable release, move from a `90d` cadence to `on-release` clocks bound to the S033 SOPS feed and the new S111 age feed (opened 2026-11-07); all 31 clocks observed live into the new default receipt `observe-r53.json` (no new release: both pins `not-fired`, the 13 fired rows unchanged). Ceiling: a self-consistent forged receipt scores; the live re-fetch is the non-author check. | `.ufo/waves/round-53/controls/c1-base.txt`; `.ufo/waves/round-53/final/c1-candidate-tree.txt`; `corpus/release-clocks.tsv`; `corpus/SOURCES.md` S103, S104, S111 |
| calibration | 9 → 9 | [C2] `bash plans/round-53-c2.sh <candidate>` 5 → 0 (target 0): the five STALE self-count bindings left by the round-52 landing (stamps 124 → 125 in SKILL.md, PROVINCE.md, README.md; knowledge entries 33/36 → 34/37 row-linked/pinned in README.md) state the live numbers; the BASE checker and table run on the measured tree under a guard on the bound ledger commands, `claim-ledger.sh`, the stamp population and the entry list. | `.ufo/waves/round-53/controls/c2-base.txt`; `.ufo/waves/round-53/final/c2-candidate-tree.txt`; QM68 |
| coverage | 9 → 9 | No claim. Registry 110 → 111 (S111 age releases Atom feed; tier A, `recheck 90d`). | `corpus/SOURCES.md` S111 |
| depth | 9 → 9 | No claim. | — |
| operability | 9 → 9 | No claim. | — |
| adjacency | 9 → 9 | No claim. | — |

## Round 54 — post-move (claim C1 freshness)

Candidate: the round-54 landing commit (recorded in the report). `.ufo/waves/round-54/final/c1-candidate-tree.txt` holds the reading of the candidate tree taken before that commit; the revision-bound reading of the landed commit follows in the round's receipts commit, named in the report (round-52 closure D1). Claim BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`; predeclaration `27aa53fd40b0b385b3cf2ffeea49977f9e0ff690` (frozen plan `plans/round-54.md`, counter `plans/round-54-c1.sh`, pre-freeze controls `plans/round-54-controls.sh`, 16 MATCH in `.ufo/waves/round-54/controls/controls-prefreeze.txt`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-54-c1.sh <candidate>` 0 → 2 (target 2): the op-ref entry's `recheck: on-release of op` (`op-ref-consumption.md:371,397`) is watched — S072 `180d` → `on-release`, clock bound to the new S112 1Password Releases feed (opened 2026-11-07) under the declared title prefix `1Password CLI`, observed live 2.42.0 in the new default receipt `observe-r54.json` (32 clocks, 0 failures), so the clock fired — and the fired release is measured: op 2.42.0 (signature-verified vendor binary, run from scratch) passes the six-class dotenv byte contract (`OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`), entry §11.2. Ceiling: a self-consistent forged receipt and a hand-written op receipt score; the live re-fetch and an independent op 2.42.0 run are the non-author checks. The installed CLI stays 2.41.1 (ledger `R21-01`). | `.ufo/waves/round-54/controls/c1-base.txt`; `.ufo/waves/round-54/final/c1-candidate-tree.txt`; `.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`; `corpus/release-clocks.tsv`; `corpus/SOURCES.md` S072, S112 |
| calibration | 9 → 9 | No claim. Measured at BASE for a separable mismatch: `self-counts.py` `stale=0`; the lane-owned unresolved citations behind R11-08 sit in non-owned spot-checks (plan §Axes). The receipt and selftest-count statements this landing moves (`SKILL.md:48`, `SKILL.md:787`, `PROVINCE.md:75`) were updated in the same commit (QM68). | `plans/round-54.md` §Axes |
| coverage | 9 → 9 | No claim. Registry 111 → 112 (S112 1Password CLI releases RSS feed; tier A, `recheck 90d`). | `corpus/SOURCES.md` S112 |
| depth | 9 → 9 | No claim. Entry §11.2 adds a fourth measured op release (2.40.0, 2.41.0, 2.41.1, 2.42.0); no new byte class. | `corpus/knowledge/op-ref-consumption.md` §11.2 |
| operability | 9 → 9 | No claim. The release-clock gate reads a vendor RSS feed with multi-word product titles under a per-feed declared prefix (selftest 116 → 121 cases); counted under C1, not booked twice. | `corpus/release-clock.py` `FEED_TITLE_PREFIXES` |
| adjacency | 9 → 9 | No claim. | — |

## Round 55 — post-move (claims C1 calibration, C2 freshness)

Candidate: the round-55 landing commit (recorded in the report). `.ufo/waves/round-55/final/c1-candidate-tree.txt` / `c2-candidate-tree.txt` hold the readings of the candidate tree taken before that commit; the revision-bound readings of the landed commit follow in the round's receipts commit, named in the report (round-52 closure D1). Claim BASE `ebe095857a734caf5efdd7bd776feb22b4e23972`; predeclaration: the round-55 predeclaration commit (frozen plan `plans/round-55.md`, counters `plans/round-55-c1.sh`, `plans/round-55-c2.sh`, pre-freeze controls `plans/round-55-controls.sh`, 22 MATCH in `.ufo/waves/round-55/controls/controls-prefreeze.txt`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-55-c1.sh <candidate>` 25 → 0 (target 0): the registry's used-by cells — the lane's own statement of which entries cite a row — now list every knowledge entry that names the row. Ten entries record the ids they name outside their support line on one column-1 `cites:` line (cross-references, later-section sources, and S072/S112 in the legacy op-ref entry, round-54 closure D1); 25 used-by cells gain the entry; `corpus/sources-census.sh` gains SC_BODY_CITE and accepts a `cites:` record for SC_USEDBY_NOCITE (selftest 70 → 78 cases). Named ceilings: lessons are outside the population; ids in a form the token rule does not match are not counted. | `.ufo/waves/round-55/controls/c1-base.txt`; `.ufo/waves/round-55/final/c1-candidate-tree.txt`; QM71 |
| freshness | 9 → 9 | [C2] `bash plans/round-55-c2.sh <candidate>` 0 → 2 (target 2): the ISO/IEC 11770-3 entry names the amendment now in force on the 2021 edition, ISO/IEC 11770-3:2021/Amd 1:2025 (TFNS identity-based key agreement, 2025-04, stage 60.60), from S113/S114 opened 2026-11-07; its `recheck:` line states the counts the committed captures give (S101 `-> 2`, was `-> 1` against a body that gives 2 since round 45; S113 `-> 3`; after the wave the S113 command counts every 2021-edition amendment and an S114 command watches the amendment's own stage). Ceiling: a non-discriminating but true recheck quote scores; the live re-fetch is the non-author check. | `.ufo/waves/round-55/controls/c2-base.txt`; `.ufo/waves/round-55/final/c2-candidate-tree.txt`; `corpus/SOURCES.md` S113, S114 |
| coverage | 9 → 9 | No claim. Registry 112 → 114 (S113, S114; tier A, `recheck 180d`). | `corpus/SOURCES.md` S113, S114 |
| depth | 9 → 9 | No claim. | — |
| operability | 9 → 9 | No claim. The census gate change is counted under C1, not booked twice. | `corpus/sources-census.sh` SC_BODY_CITE |
| adjacency | 9 → 9 | No claim. | — |

## Round 56 — post-move (claim C1 freshness)

Candidate: the round-56 landing commit (recorded in the report). Claim BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`; predeclaration: epoch-F `9cbe9d5f803de2518d4c11c6bc6b9a585e5120ad` (epoch-E `dd31b786` and interim candidate `bcf07e7` read FAIL under F — gate bytes changed for the date fix) (frozen plan `plans/round-56.md`, counter `plans/round-56-c1.sh`, gate `corpus/recheck-replay.py`, manifest `corpus/recheck-captures.tsv`, pre-freeze controls `plans/round-56-controls.sh`, 23 MATCH in `.ufo/waves/round-56/controls/controls-prefreeze-epochF.txt`; epochs A `42070de`, B `5d9a157`, C `711e6393`, D `d362318` and E `dd31b786` superseded by wave-found instrument holes and declaration nits — M56-3).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-56-c1.sh <candidate>` 0 → 10 (target 10): capability acquisition — lane-wide stated-clock offline replay. `corpus/recheck-replay.py` replays every `recheck:` clock of `corpus/knowledge/*.md` (10 clocks, 8 entries, grep/pdf/locate forms) against committed capture bodies bound by `corpus/recheck-captures.tsv` (sha256+bytes+registry-row+capture-path confined, column-0 header refusal, manifest ISO/2xx/bijection) with the locate normaliser's bytes pinned; `RECHECK_REPLAY: CLEAN` only at 10/10 MATCH, `--selftest` 20 cases. Counter r1–r5 + GUARD per the frozen predicate; BASE reads `value=0`, prior epochs read FAIL/0. Named ceilings: committed bytes only (hand-written capture + consistent manifest scores; provenance = fetch receipt + non-author live re-fetch); population closed at 10 (any added clock reads DRIFT); column-0 header refusal may refuse a body quoting an HTTP trace at column 0; bijection refuses byte-identical bodies under two ids. | `.ufo/waves/round-56/controls/c1-base.txt`-equivalent readings in report; `plans/round-56-c1.sh`; `corpus/recheck-replay.py`; `corpus/lessons/round-56.md` |
| calibration | 9 → 9 | No claim. | — |
| coverage | 9 → 9 | No claim. Registry stays 114; three source-fetches provenance rows updated to the 2026-11-07 attestations (S057/S070/S074). | `corpus/source-fetches.tsv`; `corpus/SOURCES.md` |
| depth | 9 → 9 | No claim. | — |
| operability | 9 → 9 | No claim. The replay gate is a new `corpus/` gate counted under C1, not booked twice. | `corpus/recheck-replay.py` |
| adjacency | 9 → 9 | No claim. | — |

## Round 57 — pre-move (repo HEAD `1cda9e7`, round-56 spot-check tip)

Claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`; predeclaration `7aa1f4726e1f6bcdc8411d1a8b21828d49785173` (frozen plan `plans/round-57.md`, checker `plans/round-57-c1-check.py`, counters `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, controls `plans/round-57-controls.sh`); freeze epoch B `03cbf656943b33bf93607f607bbbeb55d500b0f9` (A1 observable contract, A2 measured enable path; plan §Amendments, receipt `.ufo/waves/round-57/controls/controls-prefreeze-epochB.txt`, 11 MATCH). All six axes stand at 9.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`). | round 29 |
| coverage | 9 | 114 registry rows at the BASE, census `kagi ok` (`.ufo/waves/round-57/controls/census-start.txt`). | round 56 |
| operability | 9 | Unchanged as a score; measured BASE gap: `C2_AUDIT_TRIAL: value=0` (no audit-device trial). | round 52 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the round-56 replay gate is green. | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: `C1_CURRENT: value=3 population=16` — three stale self-descriptions in the audited round-56 surface, found by the non-author spot-check (D5/D6), read by no lane gate. | round 56 |
| adjacency | 9 | Ownership partition gate green (`R17-02`). | round 17 |

Declared claims: **C1 calibration** (the audited surface's numeric self-descriptions agree with
their machine authorities; `C1_CURRENT` 3 → 0, floor 8) and **C2 operability capability**
(OpenBao audit-device custody trial, `C2_AUDIT_TRIAL` 0 → 5, S115/S116 opened this round).
No retirement, split or stagnation waiver is claimed: a capability entered round 56, and C2 is a
capability acquisition by choice.

## Round 57 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-57 landing commit (recorded in the report; `.ufo/waves/round-57/final/`
holds the candidate-tree readings taken before that commit). Claim BASE
`1cda9e7ae4767b4133e283bfbc08266d4c86362d`; predeclaration `7aa1f472`, freeze epoch B `03cbf656`
(frozen plan `plans/round-57.md` with §Amendments A1/A2, checker `plans/round-57-c1-check.py`,
counters `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, controls `plans/round-57-controls.sh`,
11 MATCH in `.ufo/waves/round-57/controls/controls-prefreeze-epochB.txt`), and freeze epoch C
`8d8e0588` (the hardened instruments; 13-control epoch-C receipt
`.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt`, regenerated over the shipped bytes in
round 58 as `controls-prefreeze-epochC-final.txt`, `CONTROLS: match=15 mismatch=0` — round-58 closure D1/D3).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-57-c1.sh <candidate>` 3 → 0 (target 0, population 16, gate=1): the three stale self-descriptions in the audited round-56 surface (self-test cases 18 → 20; LOG "four freeze epochs" → six; lesson "Three freeze epochs" → Six) now agree with their authorities, and the class is checked by `corpus/current-claims.py` (`--selftest` 13 cases) instead of by hand. The capability row's epoch-E/22-MATCH reference and the round-56 note's epoch-D reference were repaired to epoch F/23 MATCH (reference defects, not counted). Controls: K1-BASE 3, K1-F1..F3 2, K1-F4 0, K1-F5 FAIL (population 1), K1-F6 6, K1-F7 3. Named ceilings: a forged authority passes; the class set is closed; the audited surface is the previous round. | `plans/round-57-c1.sh`; `plans/round-57-c1-check.py`; `corpus/current-claims.py`; `.ufo/waves/round-57/controls/controls-prefreeze-epochB.txt`; `.ufo/waves/round-57/final/` |
| operability | 9 → 9 | [C2] `bash plans/round-57-c2.sh <candidate>` 0 → 5 (target 5): capability acquisition — `corpus/openbao-audit-trial.sh` executes five audit-device mechanics on throwaway OpenBao 2.7.2 dev servers (T1 the documented CLI enable is refused on a default server and accepted with `unsafe_allow_api_audit_creation`; T2 salted-HMAC value form, request/response echo, no plaintext; T3 log_raw writes the value and the client token in cleartext; T4 disable + re-enable rotates the salt; T5 `sys/seal-status` is non-audited) with five shims, a no-bao SETUP leg and a PATH-wrapper leg. Entry `corpus/knowledge/openbao-audit-device-custody.md`; rows S115/S116. Named ceilings: a zero-mechanics trial that shape-keys the shim vectors and introspects the PATH wrapper (a symlink for the real legs, a regular file for the wrap leg) passes — demonstrated in `.ufo/waves/round-57/final/ceiling-mock-receipt.txt`, so the counter is necessary, not sufficient; one binary, one host, dev storage only. | `plans/round-57-c2.sh`; `corpus/openbao-audit-trial.sh`; `corpus/knowledge/openbao-audit-device-custody.md`; `corpus/SOURCES.md` S115/S116; `.ufo/waves/round-57/final/` |
| depth | 9 → 9 | No claim. The measured divergence (the docs' `bao audit enable` refused by default; the undocumented flag) and the log_raw token disclosure are recorded in the entry. | `corpus/knowledge/openbao-audit-device-custody.md` |
| coverage | 9 → 9 | No claim. Registry 114 → 117 (S115, S116, S117; all tier A, `mined`); coverage map gains the audit-device entry. Corrected in round 58 (closure D5, plan A3): the landing count is 117 and the tip count = 120 at the round-58 candidate (S118/S119/S120 added this round); `.ufo/waves/round-57/final/gates.txt` predates S117 and reads `rows=116`. | `corpus/SOURCES.md` S115, S116, S117; `corpus/README.md` |
| freshness | 9 → 9 | No claim. Both pages opened live 2026-11-07 with a browser user agent (200, decoded-body digests in the rows); the `on-release` clocks bind to the S090 OpenBao releases feed. | `corpus/SOURCES.md` S115, S116; `.ufo/waves/round-57/capture/` |
| adjacency | 9 → 9 | No claim. Connector sweep recorded in `corpus/lessons/round-57.md` §Adjacency; nothing absorbed. | `R17-02` |

## Round 58 — pre-move (repo HEAD `1b13f5d`, round-57 spot-check tip)

Claim BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`; predeclaration
`0085a5f76c9dc7e977f6606324e873d25b4fc44d` (frozen plan `plans/round-58.md`, §Amendments
A1/A2 landed before any candidate reading; counters `plans/round-58-c1.sh`,
`plans/round-58-c2.sh`, checker `plans/round-58-c1-check.py`, controls
`plans/round-58-controls.sh`). All six axes stand at 9.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 58 adds an executed authorization entry, counted under operability/coverage, not re-scored here. | round 29 |
| coverage | 9 | 117 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` (`.ufo/waves/round-58/controls/census-start.txt`). | round 57 |
| operability | 9 | Unchanged as a score; measured BASE gap: no executed ACL-policy mechanic (`C2_POLICY_TRIAL: value=0`, the trial does not exist at BASE). | round 57 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the round-56 replay gate is green. | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: `C1_ROUTED: value=8 population=8` — the eight fixable round-57 routed record defects (D1, D3, D4, D5, D6, D7, D8, D12) plus the live stale basis (D11) are unresolved at BASE and no lane gate reads them. | round 57 |
| adjacency | 9 | Ownership partition gate reads `stale_basis=1` at BASE (`.ufo/waves/round-58/controls/scope-gate-base.txt`); cleared under C1 item I8. | round 57 |

Declared claims: **C1 calibration** (the round-57 routed record defects are resolved and
re-checkable; `C1_ROUTED` 8 → 0, population 8) and **C2 operability capability** (an executed
OpenBao ACL-policy semantics trial; `C2_POLICY_TRIAL` 0 → 5, S118/S119 opened this round).
No retirement, split or stagnation waiver is claimed: a capability entered round 57 (audit
devices) and C2 is a capability acquisition by choice.

## Round 58 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-58 landing commit (recorded in the report; `.ufo/waves/round-58/final/` holds the candidate-tree readings taken before that commit). Claim BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`; predeclaration `0085a5f76c9dc7e977f6606324e873d25b4fc44d` (frozen plan `plans/round-58.md` with §Amendments A1–A4, every amendment landed before the recorded candidate reading; checker `plans/round-58-c1-check.py`, counters `plans/round-58-c1.sh`/`plans/round-58-c2.sh`, controls `plans/round-58-controls.sh`, receipt `.ufo/waves/round-58/controls/controls-prefreeze.txt`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-58-c1.sh <candidate>` FAIL (diagnostic 8/8 unresolved) → 0 (target 0, population 8, guard=1): the eight fixable round-57 routed record defects are resolved and each is re-derived from committed bytes by the frozen checker — D1 the epoch-C record in LOG/SCORECARD, D3 the epoch-C receipt re-run over the shipped instrument bytes (`CONTROLS: match=15 mismatch=0`, five pins), D4 the S117 Gate row plus its `source:`/`used-by` agreement, D5 the landing-117/tip-119 count split, D6 the gate-registry row, D7+D8 the round-parameterized `current-claims.py`, D12 the live heading; I8 clears the last stale basis (`SCOPE STALE-BASIS` gone, `stale_basis=0`). Controls `plans/round-58-controls.sh` (`.ufo/waves/round-58/controls/controls-prefreeze.txt`). Named ceilings: eight items is a closed set read structurally, a forged authority that satisfies an item passes, and the I6 literal scan ignores the module docstring, the fixture bodies and `.replace/.write/.remove` fixture plumbing. | `plans/round-58-c1.sh`; `.ufo/waves/round-58/controls/controls-prefreeze.txt`; `.ufo/waves/round-58/final/c1-candidate-tree.txt` |
| operability | 9 → 9 | [C2] `bash plans/round-58-c2.sh <candidate>` 0 → 5 (target 5): capability acquisition — `corpus/openbao-policy-trial.sh` executes five ACL-policy mechanics on throwaway OpenBao 2.7.2 dev servers (T1 deny-by-default and exact-path reach; T2 `*` only as the last character with the sibling `bars` refused; T3 `deny` outranking a broader allow; T4 `+` bounded to one segment; T5 same-pattern union vs highest-priority match through client-side introspection) with five shims, a no-bao SETUP leg and a PATH wrapper that lies on the introspection (flips T5 only). Entry `corpus/knowledge/openbao-acl-policy-semantics.md`; rows S118/S119. Named ceilings: a shape-keyed zero-mechanics trial that introspects the wrapper reads 5, one binary (2.7.2), dev-server in-memory storage, the `secret/data/…` half only, `sudo` and `scan` unmeasured. | `plans/round-58-c2.sh`; `.ufo/waves/round-58/build/R58ExecTrial/receipt-ref-real.txt`; entry §Measured |
| depth | 9 → 9 | No claim. The measured limits are stated in the entry (§Measured): the 403 preflight text rather than the literal `permission denied`, the `secret/data/` half only, one policy pair for the priority half. | `corpus/knowledge/openbao-acl-policy-semantics.md` |
| coverage | 9 → 9 | No claim. Registry 117 → 120 (S118, S119, S120; tier A, `mined`, `180d`); coverage map gains the ACL-policy entry. | `corpus/SOURCES.md` S118, S119; `corpus/README.md` |
| freshness | 9 → 9 | No claim. Observed and repaired: S115–S117 landed round 57 as `on-release` with no bound clock, so `plans/round-36-c3.sh` read `RELEASE_CLOCK: FAILED … unbound=3` at BASE; all three moved to `180d` (logged old→new), the gate reads `CLEAN (on_release=32 bound=32 unbound=0 …)`, and S118/S119 are `180d` for the same reason (version-scoped docs pages, no currency claim). | `corpus/SOURCES.md`; `.ufo/waves/round-58/final/release-clock-candidate.txt` |
| adjacency | 9 → 9 | No claim. The stale basis named by the round-57 spot-check (D11) is cleared under I8; the other three `SCOPE` breadth drifts are host-state movement carried as named debt in the lesson, not absorbed. | `corpus/adjacency.tsv`; `corpus/lessons/round-58.md` §Routed dispositions |

## Round 59 — pre-move (repo HEAD `5fa6e65`, round-58 spot-check tip)

Claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`; predeclaration `af7b6651`
(frozen plan `plans/round-59.md` with §Amendment A1 at 14 seats). All six axes stand at 9.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 59 adds an executed transit-engine entry, counted under operability/coverage, not re-scored here. | round 29 |
| coverage | 9 | 120 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` rc 0 (`.ufo/waves/round-59/controls/census-start.txt`). | round 58 |
| operability | 9 | Unchanged as a score; measured BASE gap: no executed transit-engine mechanic (`C2_TRANSIT_TRIAL: value=0`, the trial does not exist at BASE). | round 58 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the round-56 replay gate is green. | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: `C1_ROUTED: value=FAIL` (diagnostic `value=5 population=5`) — the five round-58 spot-check routed defects (D1–D5) are unresolved at BASE and no lane gate reads any of them. | round 58 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the settled `ADJACENCY_SCOPE: DEFECT` breadth drifts are carried debt, not absorbed. | round 58 |

Declared claims: **C1 calibration** (the five routed record defects are resolved and
re-checkable from derived numbers; `C1_ROUTED` FAIL/5 → 0, population 5) and **C2
operability capability** (an executed OpenBao transit-engine trial with a clean-room leg;
`C2_TRANSIT_TRIAL` 0 → 5, S121/S122 opened this round). No retirement, split or
stagnation waiver is claimed: a capability entered round 58 and C2 is a capability
acquisition by choice.

## Round 59 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-59 landing commit (recorded in the report). Claim BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`; predeclaration `af7b6651` (frozen plan
`plans/round-59.md` with §Amendments A1–A4, each landed before the recorded candidate reading;
counters `plans/round-59-c1.sh`, `plans/round-59-c2.sh`; checker `plans/round-59-c1-check.py`;
controls `plans/round-59-controls.sh`, receipt `.ufo/waves/round-59/controls/controls-prefreeze.txt`;
the two never-shipped round-58 controls ship in `plans/round-58-controls-supplement.sh`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-59-c1.sh <candidate>` `value=FAIL` (diagnostic `value=5 population=5`, guard=0) → ``C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1`` (target 0, population 5, guard=1): the five round-58 spot-check routed defects (D1–D5) become an item set whose every compared number is derived from a named revision — D1 the registry `117 → 120` statement (rows at `1b13f5da` and `be8705f8`), D2 the six-row `corpus/source-fetches.tsv` delta, D3 the 20 = 9 `C1-F` + 7 `C2-F` control census plus the identity of the two never-shipped controls and their receipt (`SUPPLEMENT: match=2 mismatch=0`), D4 the committed post-fix citation reading and the lesson line that states its `unresolved=<U>`, D5 the 101-minute mission stated `progressing`. Controls `plans/round-59-controls.sh` (21 controls; K1-BASE, K1-BASE-GUARD, K2-BASE, K1-REF plus C1-F1..F8 and C2-F1..F8) read `CONTROLS: match=20 mismatch=0`. Named ceilings: the item set is a structural read — `value=0` means five text conditions read true, never that a defect's substance was re-derived by a run; I3(b) is a naming test; I4 accepts any `unresolved=<U>` (the reading is `BROKEN`, not clean); D2's defective line lives in the fleet report this lane may not edit, so the erratum survives and the lesson restates the derived delta; the guard needs a writable challenge parent (`plans/round-59-c1.sh`), and the BASE census is taken with `--no-challenge` because the guard-bearing line reads `value=FAIL` both for an unresolved item and for an unavailable challenge. | `.ufo/waves/round-59/final/c1-candidate-tree.txt`; `.ufo/waves/round-59/controls/controls-prefreeze.txt`; `corpus/lessons/round-58.md` §Correction (round 59); `.ufo/waves/round-59/final/supplement-receipt.txt`; `.ufo/waves/round-59/final/citation-gate-r59.txt` |
| operability | 9 → 9 | [C2] `bash plans/round-59-c2.sh <candidate>` `value=0 … (absent)` → `value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1`: capability acquisition — `corpus/openbao-transit-trial.sh` executes five transit encryption-as-a-service mechanics on throwaway OpenBao 2.7.2 dev servers (T1 `vault:v1:` round trip, plaintext absent from the ciphertext, tampered ciphertext refused; T2 rotate advances the version while the old ciphertext still decrypts; T3 rewrap migrates the ciphertext with no client-side plaintext and survives the retirement floor; T4 `min_decryption_version` refuses the old version and lowering re-enables it; T5 convergent determinism for equal plaintext+context, separating on context and on key mode) with five shims, a no-bao SETUP leg and a clean-room leg where a second dev server refuses the first server's ciphertext. Entry `corpus/knowledge/openbao-transit-engine.md`; rows S121/S122. Named ceilings: the counter verifies a transcript the trial prints (a shape-keyed stub that never executes `bao` reads 5 — critic Q1-C2), so "executed" rests on the receipts and a non-author probe; the two "independent" runs are two invocations on one host; the clean-room server's independence is asserted by the trial's own transcript; one binary, one key type (`aes256-gcm96`), no signing/HMAC/import/trim/AAD/stored-data re-encryption. | `.ufo/waves/round-59/final/c2-candidate-tree.txt`; `.ufo/waves/round-59/build/R59ExecTrial/receipt-ref-real*.txt`, `receipt-shim-SH1..SH5.txt`, `receipt-none.txt`, `receipt-cleanroom.txt` |
| depth | 9 → 9 | No claim. The entry records the measured-vs-documented split (seven `Docs vs binary` rows) and the scout's G1–G10 page gaps as the bounds behind each measured leg. | `corpus/knowledge/openbao-transit-engine.md` |
| coverage | 9 → 9 | No claim. Registry 120 → 122 (S121, S122; tier A, `mined`, `180d`); coverage map gains the transit-entry and round-59 rows. | `corpus/SOURCES.md`; `corpus/README.md` |
| freshness | 9 → 9 | No claim. Both new rows take `180d` (version-scoped docs), so `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`; S121's stale-capture note resolves the round-58 staging-file id collision on the row itself. | `corpus/SOURCES.md`; `.ufo/waves/round-59/final/release-clock-candidate.txt` |
| adjacency | 9 → 9 | No claim. Connector sweep: no sibling lane holds transit-engine ground or the supplement-controls pattern; the shokuknow `merge/kagi/` package stages no transit material. The carried `ADJACENCY_SCOPE: DEFECT` (`breadth_drift=5 breadth_unverified=1`) is unchanged and named, not absorbed. | `.ufo/waves/round-59/build/R59ConnectorSiblings/sweep.md` |

## Errata — round 59 controls census

- Correction (round-60 plan I4, spot-check D4): supersedes SCORECARD.md:1971 — the round-59 calibration row's parenthetical control census overcounts the battery; `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt` reads 20 controls (4 K + 8 C1-F + 8 C2-F), superseding the row's stated 21-controls parenthetical.

## Errata — round 59 gate evidence and measured commit

- Correction (round-60 plan I5, spot-check D5): `supersedes the round-59 gate-evidence pointer` — the round-59 freshness row cites `.ufo/waves/round-59/final/release-clock-candidate.txt`, which was never written (`.ufo/waves/round-59/final` holds six files, none a release-clock, DOC_AUDIT or SCOPE receipt). The three readings are re-taken on the round-60 candidate and committed: `.ufo/waves/round-60/final/release-clock-candidate.txt` (`RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`), `.ufo/waves/round-60/final/doc-audit-candidate.txt` (`DOC_AUDIT: CLEAN (entries=41 row_linked=38 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`), and `.ufo/waves/round-60/final/scope-candidate.txt` (`ADJACENCY_SCOPE: DEFECT (census=35 … stale_basis=0 … breadth_drift=5 breadth_unverified=1)`, the carried debt, unchanged and named).
- Correction (round-60 plan I6, spot-check D6): `supersedes the round-59 measured-commit citation` — the round-59 Before → after table named `75165a07` as the measured commit while the committed receipt `.ufo/waves/round-59/final/c1-landed.txt` reads `c1-driver: measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c`; the receipt's revision is the reading's revision, and the round-59 landing commit is the commit that carries the receipts.

## Round 60 — pre-move (repo HEAD `a677c78e`, round-59 spot-check tip)

Claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`; predeclaration `cd631737`
(frozen plan `plans/round-60.md`, §Amendments A1–A6, every amendment landed before the
recorded candidate reading). All six axes stand at 9.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 60 adds an executed AppRole custody entry, counted under operability/coverage, not re-scored here. | round 29 |
| coverage | 9 | 122 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` rc 0. | round 59 |
| operability | 9 | Unchanged as a score; measured BASE gap: no executed AppRole mechanic (`C2_APPROLE_TRIAL: value=0 … (absent)`). | round 59 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the round-56 replay gate is green. | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: `C1_ROUTED: value=7 population=7` — the seven round-59 spot-check routed defects (D1–D7) are unresolved at BASE and no lane gate reads any of them. | round 59 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 calibration** (the seven routed record defects are resolved and
re-checkable; `C1_ROUTED` 7 → 0, population 7) and **C2 operability capability** (an
executed OpenBao AppRole `secret_id` custody trial with its own fixture-driven
`--selftest`; `C2_APPROLE_TRIAL` 0 → 5, S123/S124 opened this round). No retirement,
split or stagnation waiver is claimed: capabilities entered rounds 57–59 and C2 is a
capability acquisition by choice.

## Round 60 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-60 landing commit (recorded in the report). Claim BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`; predeclaration `cd631737`; amendments
A1–A6 (`5e1649a3`, `a177161c`, `b662e114`, `cad84270` and the instrument commits);
counters `plans/round-60-c1.sh`, `plans/round-60-c2.sh`; checker
`plans/round-60-c1-check.py`; controls `plans/round-60-controls.sh`, receipt
`.ufo/waves/round-60/controls/controls-prefreeze.txt`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-60-c1.sh <candidate>` `value=FAIL` (diagnostic `value=7 population=7`, guard=0) → `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1` (target 0, population 7, guard=1): the seven round-59 spot-check routed defects (D1–D7) become an item set whose every compared number is derived from a named revision or the measured tree — D1 the dead-seat census against `w1-results.json` (14/0), D2 the 33-case receipt, D3 the routed-id uniqueness plus the superseded duplicate ids, D4 the 20-control receipt, D5 the three re-taken gate receipts, D6 the receipt's `measured=revision`, D7 the transit selftest plus its mutation leg. | `plans/round-60-c1.sh`; `.ufo/waves/round-60/final/c1-landed.txt`; `.ufo/waves/round-60/build/R60ExecCounterC1/selftest.txt` (`PASS (46 cases)`) |
| operability | 9 → 9 | [C2] `bash plans/round-60-c2.sh <candidate>` `value=0 … (absent)` → `C2_APPROLE_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1`: capability acquisition — `corpus/openbao-approle-trial.sh` executes five AppRole custody mechanics on throwaway OpenBao 2.7.2 dev servers (T1 `bind_secret_id`; T2 `secret_id_num_uses`; T3 `secret_id_ttl`; T4 accessor lookup/destroy; T5 `secret_id_bound_cidrs`) with five shims, a no-bao leg, and its own fixture-driven `--selftest` (45 cases, no `bao`, no network) that fails with named `FINDING` ids on a mutated copy. Entry `corpus/knowledge/openbao-approle-secret-id-custody.md`; rows S123/S124. | `.ufo/waves/round-60/final/c2-landed.txt`; `.ufo/waves/round-60/build/R60ExecTrial/`; `.ufo/waves/round-60/final/l1-probe.txt` |
| depth | 9 → 9 | No claim. The entry records the measured-vs-documented split (seven `Docs vs binary` rows, including both pages' silence on refused-login shapes) and the trial's bounds. | `corpus/knowledge/openbao-approle-secret-id-custody.md` |
| coverage | 9 → 9 | No claim. Registry 122 → 124 (S123, S124; tier A, `mined`, `180d`); coverage map gains the AppRole-entry and round-60 rows. | `corpus/SOURCES.md`; `corpus/README.md` |
| freshness | 9 → 9 | No claim. Both new rows take `180d` (version-scoped docs), so `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`; the round-59 dead pointer is replaced by three committed receipts (I5). | `.ufo/waves/round-60/final/release-clock-candidate.txt` |
| adjacency | 9 → 9 | No claim. Connector sweep: no sibling lane holds AppRole/`secret_id` ground or the trial+shim+counter-with-selftest pattern; the shokuknow `merge/kagi/` package stages no AppRole material. The carried `ADJACENCY_SCOPE: DEFECT` (`breadth_drift=5 breadth_unverified=1`, `stale_basis=0`) is unchanged and named. | `.ufo/waves/round-60/build/R60ConnectorSiblings/sweep.md`; `.ufo/waves/round-60/final/scope-candidate.txt` |

## Round 61 — pre-move (repo HEAD `c940f516`, round-60 spot-check tip)

Claim BASE `c940f51689d702f1786989d56ad4663833c1452e`; predeclaration `85950181`
(frozen plan `plans/round-61.md`). All six axes stand at 9. Saturation line 9,
stagnation window N=3; capabilities entered rounds 57–60, so no stagnation waiver.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 61 adds an executed seal-key entry, counted under operability/coverage, not re-scored here. | round 29 |
| coverage | 9 | 124 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` rc 0. | round 60 |
| operability | 9 | Unchanged as a score; measured BASE gap: no executed seal/unseal key-share mechanic (`C2_SEAL_TRIAL: value=0 … (absent)`). | round 60 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the round-56 replay gate is green. | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: `C1_ROUTED: value=7 population=7` — the seven round-60 spot-check routed defects (D1–D7) are unresolved at BASE and no lane gate reads any of them. | round 60 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 calibration** (the seven round-60 routed record defects are resolved and
re-checkable; `C1_ROUTED` 7 → 0, population 7) and **C2 operability capability** (an executed
OpenBao seal / unseal key-share custody trial with its own fixture-driven `--selftest`;
`C2_SEAL_TRIAL` 0 → 5, S125–S127 opened this round). No retirement, split or stagnation waiver
is claimed: capabilities entered rounds 57–60 and C2 is a capability acquisition by choice.

## Round 61 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-61 landing commit (recorded in the report). Claim BASE
`c940f51689d702f1786989d56ad4663833c1452e`; predeclaration `85950181`; counters
`plans/round-61-c1.sh` + `plans/round-61-c1-check.py`, `plans/round-61-c2.sh`; controls
`plans/round-61-controls.sh`, receipt `.ufo/waves/round-61/controls/controls-prefreeze.txt`
(`CONTROLS: match=17 mismatch=0`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-61-c1.sh c940f51689d702f1786989d56ad4663833c1452e` ⇒ `C1_ROUTED: value=FAIL population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0` (diagnostic `value=7 population=7`), rc 1 → `bash plans/round-61-c1.sh --tree .` ⇒ `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1`, rc 0 (target 0, population 7): the seven round-60 spot-check routed defects (D1–D7) become an item set whose every compared number is derived from the named revision or the measured tree — D1 the R60MutCounters output byte length against `w1-results.json` (16/3824), D2 a fixture-driven `--selftest` on `plans/round-60-c2.sh` (36 cases) plus its SKILL row, D3 the `## Amendment A7` withdrawal of §A3 item 2 plus the M60-2 second instance, D4 the quality-trend correction naming D1–D3, D5 the LOG rewrite correction (`insertions=1 deletions=1`), D6 the driver launch line plus four `%ci` stamps, D7 the attack-share fractions derived from the results role mix (3/16, 4/16). Checker `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (52 cases)`; the guard fires (a `deletions=2` delta reads value+1; a constant-0 stub fails). | `plans/round-61-c1.sh`; `plans/round-61-c1-check.py`; `.ufo/waves/round-61/build/R61ExecCounterC1/`; `.ufo/waves/round-61/controls/controls-prefreeze.txt` |
| operability | 9 → 9 | [C2] `bash plans/round-61-c2.sh c940f516…` ⇒ `C2_SEAL_TRIAL: value=0 … (absent)`, rc 1 → `bash plans/round-61-c2.sh --tree .` ⇒ `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 … cases=63)`, rc 0: capability acquisition — `corpus/openbao-seal-trial.sh` executes five Shamir-seal custody mechanics on throwaway OpenBao 2.7.2 servers (T1 init share/threshold arithmetic and non-persistence; T2 unseal threshold with the duplicate-share refusal; T3 seal and the 503 sealed-state request; T4 generate-root with the OTP decode; T5 rekey refused under the default config on raft and inmem while `rotate-keys` completes a rotation), with five shims, a no-bao leg, an argv-shape ops witness and its own fixture-driven `--selftest` (63 cases, no `bao`, no network). Entry `corpus/knowledge/openbao-seal-key-custody.md`; rows S125–S127. | `plans/round-61-c2.sh`; `corpus/openbao-seal-trial.sh`; `.ufo/waves/round-61/build/R61ExecTrial/`; `.ufo/waves/round-61/build/R61ExecCounterC2/` |
| depth | 9 → 9 | No claim. The entry records the measured-vs-documented split, including the rekey root cause (default-off endpoint registration plus nil-callback stub, not a removed feature) and the anonymous-rekey hazard when `disable_unauthed_rekey_endpoints = false`, with bounds and falsifiers. | `corpus/knowledge/openbao-seal-key-custody.md`; `.ufo/waves/round-61/build/R61Revenger/rekey.md` |
| coverage | 9 → 9 | No claim. Registry 124 → 127 (S125–S127; tier A, `mined`, `180d`); coverage map gains the seal-key entry and round-61 lesson rows. | `corpus/SOURCES.md`; `corpus/source-fetches.tsv`; `corpus/README.md` |
| freshness | 9 → 9 | No claim. All three new rows take `180d`, so `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`; the new entry declares its `recheck:` clock and its `Reverify:` row. | `.ufo/waves/round-61/` receipts; `corpus/claim-ledger.sh docs` |
| adjacency | 9 → 9 | No claim. Connector sweep over 21 lanes: no sibling holds OpenBao/Vault seal, Shamir, rekey or generate-root ground (the hits are homonyms — memfd seals, "sealed envelope", SEAL acronym); the shokuknow `merge/kagi/` package stages no seal material. The carried `ADJACENCY_SCOPE: DEFECT` (`breadth_drift=5 breadth_unverified=1`, `stale_basis=0`) is unchanged and named. | `.ufo/waves/round-61/build/R61Connector/sweep.md` |

Named ceilings (recorded, not smoothed): the seven C1 items are structural reads — a tree that
negates the statement while keeping every token (`not withdrawn`, `no three`, `not rewritten in
place`) or swaps a pairing (`3/16 = 25 %`) reads satisfied (reviewer §C1 I3–I7; QM79 is the
next-round hardening); I6's literal `-03:00` text is unsatisfiable against `%ci`'s `-0300`, so
the checker compares instants after offset normalisation; C2's `guard` is near-constant and the
counter's `--selftest` does not execute the main aggregation (reviewer §C2-4/§C2-5, open
instrument debts); the C2 counter's first ops witness accepted a `--help` stub and was
strengthened to argv shapes in-round (QM80).

## Planned (next axis-move — round 61 close)

All six axes stand at 9; the lane rule is "pick the lowest-scoring axis", so the next round
breaks the tie by measurement, as rounds 61 and 16 did:

- **calibration candidate — close QM79.** Harden the C1 item grammar so a negated or
  swapped-pairing sentence reads unresolved (a polarity test per item: the asserting verb must
  not be preceded by a negator within the clause; the fraction and its percentage must be
  paired by derivation), and add the reviewer's five bypass trees as controls. Falsifiable
  target: the five bypass trees read `value=5` today and must read `value=0` with the
  hardened checker while the seven real corrections still read 0.
- **operability candidate — close C2-4/C2-5.** Give the C2 counter a challenge leg for
  `guard` (a tree whose trial sha256 is valid but whose legs are incomplete must read
  `guard=0`) and extend its `--selftest` to execute the main aggregation (mutation A: the
  aggregation replaced by `value=5` must fail). Falsifiable target: the reviewer's two
  surviving mutations must be killed.

Ceilings are named so they are not mistaken for saturations:

- **calibration** — pointer relevance remains unverifiable; a structural item cannot prove the
  corrected sentence true, only that it asserts the correction (QM79 narrows, never closes,
  this).
- **operability** — nothing schedules the gates; the checklist's by-hand duties remain by-hand;
  the seal trial is one host, one version pair, default config.
- **depth** — the remaining OpenBao seal increments (auto-unseal, recovery keys, seal
  migration) need a second config surface and, for auto-unseal, a KMS/HSM stand-in; they are
  reachable but not cheap.
- **coverage** — the census declaration is untouched; the new ground is a behaviour surface,
  not a path surface.

## Errata — round 61 controls count

- Correction (round-62 routed D1): supersedes the round-61 controls count in §Round 61 — post-move (`SCORECARD.md:2056`, `CONTROLS: match=17 mismatch=0`). The committed receipt `.ufo/waves/round-61/controls/controls-prefreeze.txt` carries 18 `CONTROL ` lines and the line `CONTROLS: match=18 mismatch=0`, and `LOG.md:1990` reads `match=18`. The receipt is the authority; the round-61 row's number is superseded, not rewritten (QM78).

## Round 62 — pre-move (repo HEAD `60b5b7b6`, round-61 spot-check tip)

Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`; predeclaration `8e5463c7`
(frozen plan `plans/round-62.md`). All six axes stand at 9. Saturation line 9,
stagnation window N=3; capabilities entered rounds 57–61, so no stagnation waiver.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 62 moves no domain surface. | round 29 |
| coverage | 9 | 127 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` rc 0 (`.ufo/waves/round-62/census-start.txt`). | round 61 |
| operability | 9 | Unchanged as a score; measured BASE gap: the C2 counter's `guard` is a near-constant (a valid-sha256 stub trial reads `guard=1`) and its `--selftest` does not execute the aggregation (M-A and M-B survive) — `C2_HARDENED` 0/3 (`R62-02`). | round 61 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the round-56 replay gate is green. | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: the five reviewer bypass trees each read `C1_ROUTED: value=0` (accepted) on the BASE checker — `C1_BYPASS` 5/5 (`R62-01`). | round 61 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 calibration** (the C1 checker's negation / swapped-pairing
bypass class is closed and the seven round-61 corrections still resolve;
`C1_BYPASS` accepted 5 → 0, population 5) and **C2 operability** (the C2 counter's
guard and self-invocation mode can fail; `C2_HARDENED` killed 0 → 3, population 3).
No retirement, split or stagnation waiver is claimed: capabilities entered rounds
57–61 and both claims are instrument hardening by the round-61 close's own plan.

## Round 62 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-62 candidate commit (recorded in the report; `.ufo/waves/round-62/final/`
holds the candidate-revision readings). Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`;
predeclaration `8e5463c7`; amendments A1 (I6's denial clause), A2 (the I4/I5 statement scope and
the M-A/M-B needle) and A3 (C1 guard leg (e), the checker challenge), each landed before any
candidate reading (`7b291538`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-62-c1.sh 60b5b7b6` ⇒ `C1_BYPASS: accepted=5 population=5 guard=0` rc 1 → `bash plans/round-62-c1.sh --tree .` ⇒ `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1 chal=1)` rc 0 (target 0, population 5): the five round-61 reviewer bypass fixtures (a negation or a swapped pairing that keeps every token) are rejected by the hardened checker while the seven round-61 corrections still resolve and the three paraphrase fixtures stay resolved; the checker's own selftest carries 75 cases including the five bypass cases, the three paraphrase cases and the I6 denial clause; guard leg (e) refuses a stub that self-attests a PASS line. Named ceilings: the five fixtures are the reviewer's five (a sixth negation class is a new routed defect); a structural read proves the sentence asserts the correction, not that it is true (QM79 narrows, never closes, this); the negator window is a floor. | `plans/round-62-c1.sh`; `.ufo/waves/round-62/final/c1-base.txt`; `.ufo/waves/round-62/final/candidate.txt`; `plans/round-61-c1-check.py` (75 cases) |
| operability | 9 → 9 | [C2] `bash plans/round-62-c2.sh 60b5b7b6` ⇒ `C2_HARDENED: killed=0 population=3 guard=0` rc 1 → `bash plans/round-62-c2.sh --tree .` ⇒ `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` rc 0 (target 3, population 3): the measured counter's `--selftest` now executes its own aggregation (a constant-aggregation mutant and an unconditional-shim mutant each fail with a named `FINDING`), and its guard reads 0 on a valid-sha256 stub trial that prints no expected observable; the real trial still reads `value=5 shims=5 vectors=ok/5`. Named ceilings: two mutation classes, not a complete mutation set; one stub shape; the real leg needs `bao`; the counter still trusts the trial's printed observables. | `plans/round-62-c2.sh`; `plans/round-61-c2.sh` (21 cases); `.ufo/waves/round-62/final/c2-base.txt`; `.ufo/waves/round-62/final/candidate.txt` |
| coverage | 9 → 9 | No claim. Registry 127 → 134 (S128–S131 tier A `mined`; S132–S134 tier C `rejected`); coverage map gains the instrument-falsifiability entry. | `corpus/SOURCES.md`; `corpus/source-fetches.tsv`; `corpus/README.md` |
| depth | 9 → 9 | No claim. The entry `corpus/knowledge/claim-instrument-falsifiability.md` adds the bypass class, the polarity and pairing rules, the mutation-kill contract and the guard-observable rule with bounds and falsifiers. | `corpus/knowledge/claim-instrument-falsifiability.md` |
| freshness | 9 → 9 | No claim. Four admitted rows opened live 2026-11-07 with located quotes and reproducible captures (S130/S131 re-pinned to the token-free NLM XML after the article HTML's per-request token made its digest irreproducible); three rejects carry reason and flip. | `corpus/SOURCES.md`; `.ufo/waves/round-62/capture/notes.md` |
| adjacency | 9 → 9 | No claim. Connector sweep over 21 lanes: chousa holds lexical polarity-flip detection and kumitate a `gate-mutants.mjs` battery — adjacent, reported, not absorbed; the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named. | `.ufo/waves/round-62/build/R62Connector/sweep.md` |

Named ceilings (recorded, not smoothed): the C1 predicate's I4/I5 conditions are line-scoped
(A2) and the I6 superseded-stamp conjunct accepts any non-derived time (reviewer D-3, routed);
the I7 pairing does not bind the fraction to its subject (reviewer D-4, routed); the negator
window is before-only and five tokens (reviewer D-5, the plan's floor); the C1 counter's
verdict-mode stub composition and `stub_leg` negative vector are not exercised by its selftest
(MutC1 CM2a/CM2b, routed); the checker's I6 clause (c) has no isolating selftest case (MutC1
GM5, routed); the C2 counter's guard leg (c) is `ma ∧ mb`, not a constant-verdict copy (critic
D12); nothing schedules the gates.

## Round 63 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-63 candidate commit (recorded in the report; `.ufo/waves/round-63/final/`
holds the candidate-revision readings). Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc`
(round-62 verifier spot-check tip); predeclaration `12c9e4284d6de52ba61fcc656165cd24e8b74480`;
amendments A1 (wave shape), A2 (C2 population 6→5, L5 vacuous at BASE), A3 (C1 guard leg (f)
checker challenge; C1-2/3/4 restatements; C2 leg mechanics), each landed before any candidate
reading.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-63-c1.sh 0c07aab8` ⇒ `C1_RESIDUAL: accepted=10 rejected=6 population=10/6 guard=0` rc 1 → candidate ⇒ `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1 chal=1)` rc 0 (target 0/0, population 10/6): the ten reviewer forgery fixtures rejected, six benign rewrites stay resolved, seven round-61 corrections still resolve, guard leg (f) refuses an emptied-negator checker. Named ceiling: guard leg (f) distinguishes a grammar from a string lookup only through the negator-set needle — a lookup-table checker carrying a literal empty set passes leg (f) but is not the hardened grammar; the count floor `cases>=91` is a count, not a class-coverage proof (M63-6). | `plans/round-63-c1.sh`; `.ufo/waves/round-63/final/c1-residual.txt`; checker `--selftest` `PASS (cases=102)` |
| operability | 9 → 9 | [C2] BASE `killed=0` over the five non-vacuous legs → candidate `C2_REFUSAL: killed=5 population=5 guard=1` rc 0: leg L1 kills CM2a, L2 kills CM2b, L3/L4 read mismatch on the battery's two stub controls, L6 kills the I6-conjunct drop. Named ceiling: the C2 instrument hangs in its nested controls-battery leg at integration time (the battery re-runs both counters, including C2 itself — unbounded recursion); the candidate verdict was reproduced leg-by-leg from the seats' scratches but not by one budget-bounded end-to-end run, so the number 5 carries this caveat and the honest-stop alternative (M63-LEN) is on record in `claim-falsification.tsv`. | `plans/round-63-c2.sh`; `.ufo/waves/round-63/build/R63ExecC2Counter/`, `.ufo/waves/round-63/build/R63MutC2/mutants.md` |
| coverage | 9 → 9 | No claim. Registry 134 → 143 (S135–S144 except S136; six `mined` S135/S137/S139/S140/S141/S143; three `rejected` S138/S142/S144); `corpus/source-fetches.tsv` +9; entry `corpus/knowledge/negation-scope-grammar.md` (S135+S137) extends the polarity/scope ground. | `corpus/SOURCES.md`; `corpus/source-fetches.tsv` |
| depth | 9 → 9 | No claim. `negation-scope-grammar.md` carries the pseudo-trigger/termination-term/idiom ground with `source:` trio S135+S137+S130. | `corpus/knowledge/negation-scope-grammar.md` |
| freshness | 9 → 9 | No claim. Ten pages opened live 2026-11-07 (S135–S144; S136 opened but unregistered: 0-byte challenge body). | `.ufo/waves/round-63/capture/notes.md` |
| adjacency | 9 → 9 | No claim. Connector swept 21 lanes; breadth debt unchanged, carried not absorbed. | `.ufo/waves/round-63/build/R63Connector/sweep.md` |

No axis is re-scored: all six stay 9 → 9 (L1 reading, for the operator's ruling). No
stagnation waiver, retirement or split.

## Round 63 — planned

From the round-63 lesson's mined mistakes (M63-1–M63-9) and the C1/C2 ceilings:
1. **Calibration** — close M63-6: add a held-out fixture not in the committed TSVs to the
   C1 guard, so a fixture-lookup checker cannot reach `accepted=0` on the held-out set;
   re-run the `R63Critic` lookup-table checker against the new guard.
2. **Operability** — fix the C2 nested-battery recursion: the run-64 C2 counter (or the
   controls battery's delegation) gets an explicit recursion bound/environment flag so one
   `bash plans/round-63-c2.sh --tree .` terminates inside its own `timeout 2400` budgets, and
   the leg-by-leg reproduction is replaced by a single end-to-end candidate line.
3. **Freshness** — re-verify the S143 BioC endpoint (volatile digest) and the S138/S144
   flips; if the BioC XML shape changed, supersede S143 per CORPUS.md rule 2.

## Round 64 — pre-move (repo `09cbee8`, round-63 spot-check tip)

Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`; predeclaration
`dff0929c0e084822b0fe32e0d164534c768f97fe` (frozen plan `plans/round-64.md`, including
Amendment A1, which re-measured the held-out population per fixture before any candidate
work). All six axes stand at 9. Saturation line 9, stagnation window N=3; capabilities
entered rounds 57–63, so no stagnation waiver is claimed.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 64 moves an instrument surface, not the domain tables. | round 29 |
| coverage | 9 | 143 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` rc 0 (`.ufo/waves/round-64/base/census-start.txt`). | round 63 |
| operability | 9 | Unchanged as a score; measured BASE gap: the round-63 C2 counter does not terminate — `timeout 240 bash plans/round-63-c2.sh --tree .` ⇒ rc 124, no verdict line (`.ufo/waves/round-64/base/c2-e2e-head.txt`, 7 B). | round 63 |
| freshness | 9 | Every knowledge entry declares its re-verification (`R14-01`); the S143 carrier is re-opened this round (one-byte date-stamp delta, shape unchanged). | round 56 |
| calibration | 9 | Unchanged as a score; measured BASE gap: the C1 checker accepts 5 of the 5 held-out forgeries and rejects all 3 held-out benign rewrites — `heldout=8 population=8` (`.ufo/waves/round-64/base/census-a1.md`), and the A4 lookup-table vehicle reaches `accepted=0 rejected=0` on the committed tables (M63-6). | round 63 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 calibration** (a held-out fixture set sealed before the hardening
defeats the lookup-table checker: `C1_HELDOUT` heldout 8 → 0 over population 8, with the
A4 vehicle refused) and **C2 operability** (the C2 counter terminates end-to-end inside
its own budget and prints one verdict line: `terminates` 0 → 1 with `killed=5`).
No retirement, split or stagnation waiver is claimed.

## Round 64 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-64 candidate commit (recorded in the report;
`.ufo/waves/round-64/final/` holds the integration readings). Claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`; predeclaration
`dff0929c0e084822b0fe32e0d164534c768f97fe`; Amendment A1 (the held-out census re-measured
per fixture: H = F2,F6,F8,F10,B4; Q = P6,B5,P7; seal re-cut to `b0f51e2a…`) landed before
any candidate work.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-64-c1.sh 09cbee83` ⇒ `C1_HELDOUT: heldout=8 population=8 guard=0 (real=1 selftest=0 resid=1 stub=1 vehicle=1)` rc 1 → candidate ⇒ `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)` rc 0: the five held-out forgeries each read `value>=1` (F2=value1 F6=value1 F8=value1 F10=value1 B4=value1), the three benign rewrites each read `value=0` (P6 B5 P7), the unmodified copy still reads `value=0` with all seven i-bits 1, the round-63 tables still close (`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1`), a printer-stub checker is refused, and the A4 lookup-table vehicle reads `heldout=5` on the sealed set while reading `accepted=0 rejected=0` on the round-63 tables (the M63-6 defect). Named ceilings: eight fixtures are eight fixtures, not a grammar proof; the vehicle leg is the only witness against a lookup table carrying one fresh entry per class; a structural read cannot prove the corrected sentence true. | `plans/round-64-c1.sh`; `.ufo/waves/round-64/final/c1-heldout.txt`, `c1-base-counter.txt`; `.ufo/waves/round-64/base/census-a1.md` |
| operability | 9 → 9 | [C2] BASE `timeout 240 bash plans/round-63-c2.sh --tree .` ⇒ rc 124, no verdict line (7-byte receipt) → candidate `bash plans/round-64-c2.sh --tree .` ⇒ `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` rc 0 in 285 s, one line; `C2_RECURSION_BOUND=0 … timeout 240` ⇒ rc 124, no line. The bound is explicit and its refutation leg fires. Named ceilings: `terminates=1` is a termination claim, not a correctness claim about the number 5 (the five legs are round-63's); the bound is a flag, and a caller setting 0 gets the old behaviour; the real-trial leg is host-load sensitive (`real-attempts=` is printed). | `plans/round-64-c2.sh`; `.ufo/waves/round-64/final/c2-refusal.txt`, `c2-bound-off.txt` |
| coverage | 9 → 9 | No claim. Registry 143 → 153 (S145–S154: S145/S146/S147 tier A, S148 `supersedes S143 —` the re-verified BioC deposit, S149–S154 rejected with reasons and flips); `corpus/source-fetches.tsv` +10; entry `corpus/knowledge/claim-instrument-heldout.md` (45 entries, row-linked, pinned). | `corpus/SOURCES.md`; `corpus/source-fetches.tsv`; `corpus/knowledge/claim-instrument-heldout.md` |
| depth | 9 → 9 | No claim. The entry adds the held-out rule, the vehicle argument, the bound contract and their bounds/falsifiers. | `corpus/knowledge/claim-instrument-heldout.md` |
| freshness | 9 → 9 | No claim. The S143 BioC carrier is re-opened on the current endpoint: the served body differs from the pin by exactly one byte (the service's `<date>` stamp 20261107→20261108, `cmp -l` at offset 127) while `<passage>` 182 and `<text>` 180 are unchanged — so the shape did not change and the superseding row S148 records the measurement rather than asserting the pin still holds. | `corpus/SOURCES.md` S148; `.ufo/waves/round-64/capture/notes.md` §S143 |
| adjacency | 9 → 9 | No claim. Connector swept the sibling lanes for held-out sets, kill contracts and recursion bounds; the carried `ADJACENCY_SCOPE: DEFECT` breadth debt (`breadth_drift=5 breadth_unverified=1`) is named, not absorbed. | `.ufo/waves/round-64/build/R64Connector/sweep.md`; `bash corpus/scope-gate.sh` |

Gate readings on the candidate: `SOURCES_CENSUS: CLEAN (rows=153 A=137 B=2 C=14
queued=3 mined=134 rejected=16 …)`; `DOC_AUDIT: CLEAN (entries=45 row_linked=42 by_hand=3
undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`; `RELEASE_CLOCK: CLEAN
(on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`;
`ADJACENCY_SCOPE: DEFECT` unchanged (the carried breadth debt);
`CITATION_GATE: BROKEN (cites=4918 docs=163 unresolved=22 ephemeral=0 labeled=24)` — all 22
unresolved citations are pre-existing (round-34/35/43/44/51/53/54/58/59/60/62 historical
documents), none in a round-64 document; `CLAIM_LEDGER: POLICY (claims=96 policy=5
stamped=161)` — the five POLICY findings are pre-existing MISSING-ID readings in
round-37/38/46 lessons.

No axis is re-scored: all six stay 9 → 9 (L1 reading, for the operator's ruling). No
stagnation waiver, retirement or split.

## Round 64 — planned (next)

1. **Calibration** — close the remaining C1 ceiling the plan names: the held-out set is
   eight fixtures over five forgery and three benign shape classes; grow it to a class
   matrix (one held-out instance per class the checker claims) and make the vehicle leg's
   needle structural rather than a 15-string lookup, so the vehicle reduction the counter
   documents stops being total.
2. **Operability** — the round-63 controls receipt that leg `d3` names was never
   committed (`ls .ufo/waves/round-63/final/` lists five receipts and no controls one; the
   round-63 battery's receipt lives under `build/R63ExecControls/`), so `ROUTED: d3=0`. Either commit a
   reconstructed receipt with its own provenance or correct the routed leg's population
   to the five receipts the tree actually holds — a leg whose expectation no tree can meet
   is a defect (QM57).
3. **Freshness** — the S143 endpoint stamps a request date into the body each day; a
   second carrier (or a declaration that the row is `decoded-http-body-volatile-v1` with
   a shape census instead of a digest) would make the re-verification reproducible.

## Round 65 — pre-move (repo `b17887f`, round-64 spot-check tip)

Claim BASE `b17887f03179b61d49e3e0f10ce1a9add21829e7`; predeclaration `ab1cedc4`
(`plans/round-65.md`, Amendments A1–A3 recorded before their readings). All six axes
stand at 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57–64, so no stagnation waiver is claimed.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 65 moves an instrument surface. | round 29 |
| coverage | 9 | 153 registry rows at BASE (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`), census `kagi ok` rc 0. | round 64 |
| operability | 9 | Measured BASE gap: the round-63 routed leg's population expects six final receipts and the tree holds five (`.ufo/waves/round-65/base/routed-base.txt` ⇒ `d3=0 mismatch=1`). | round 64 |
| freshness | 9 | Measured BASE gap: the S148 carrier's re-verification needs a refetch and a hand diff, and the live endpoint answers 429 on this host (S156). | round 64 |
| calibration | 9 | Measured BASE gap: five fresh forgery classes are accepted and `R65-H5` exercised no item (`C1_MATRIX: matrix=5 population=8 guard=0`). | round 64 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 calibration** (the class matrix rejects five forgery classes and
keeps three benign classes accepted), **C2 operability** (the routed population is
derived and its unsatisfiable expectation corrected), **C3 freshness** (the volatile
carrier's re-verification is reproducible). No retirement, split or stagnation waiver.

## Round 65 — post-move (claims C1 calibration, C2 operability, C3 freshness)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] `bash plans/round-65-c1.sh --tree <BASE>` ⇒ `C1_MATRIX: matrix=5 population=8` → candidate ⇒ `C1_MATRIX: matrix=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)`, per fixture `H1..H5=value1 Q1..Q3=value0`, the round-63 tables still `C1_RESIDUAL: accepted=0 rejected=0`, the checker `C1_CHECK_SELFTEST: PASS (cases=111)`, and the structural lookup vehicle reading `matrix=5` (the falsifier, Amendment A3). Named ceilings: eight fixtures are eight fixtures, not a grammar proof; a checker memorising the eight strings is not detected. | `plans/round-65-c1.sh`; `.ufo/waves/round-65/final/c1-matrix.txt`; `plans/round-61-c1-check.py` |
| operability | 9 → 9 | [C2] `bash plans/round-65-routed.sh --tree <BASE>` ⇒ `ROUTED: d1=1 d2=1 d3=0` (mismatch=1) → candidate ⇒ `ROUTED: d1=1 d2=1 d3=1` rc 0 (`mismatch=0`, five held receipts), with `--legacy` ⇒ `d3=0` so the superseded six-receipt expectation still fails. Ceiling: d3 is a presence-and-derivation claim, not a freshness claim about receipt contents. | `plans/round-65-routed.sh`; `.ufo/waves/round-65/base/routed-base.txt`; `corpus/lessons/round-65.md` §C2 correction record |
| freshness | 9 → 9 | [C3] no artifact → `VOLATILE_SHAPE: match=1 passages=182 texts=180 date=20261108 pin_sha=3b8d4e15…` rc 0; a count mutation reads `match=0` rc 1; `--selftest` PASS (cases=7); guard `cmp -l` shows one differing byte at offset 128. Ceiling: a shape claim over counts and one stamp, not over the deposit's wording. | `corpus/volatile-shape.py`; `.ufo/waves/round-65/final/c3-*.txt`; `corpus/SOURCES.md` S155/S156 |
| coverage | 9 → 9 | No claim. Registry 153 → 155 (S155 admitted, S156 rejected with its flip); `corpus/source-fetches.tsv` gains both captures; entry `corpus/knowledge/claim-instrument-class-matrix.md`. | `corpus/SOURCES.md`; `corpus/knowledge/claim-instrument-class-matrix.md` |
| depth | 9 → 9 | No claim. The entry states the three instrument defects, the closed clash vocabulary and its exclusions, and five falsifiers. | `corpus/knowledge/claim-instrument-class-matrix.md` |
| adjacency | 9 → 9 | No claim. The carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed; no sibling holds a class-matrix instrument (connector sweep not run this round — see the report's wave section). | `bash corpus/scope-gate.sh` |

Gate readings on the candidate: `SOURCES_CENSUS: CLEAN (rows=155 …)`;
`CLAIMS_DECLARED: CLEAN (claims=56)`.

No axis is re-scored: all six stay 9 → 9 (L1 reading, for the operator's ruling).

## Round 66 — pre-move (repo `d549ee6`, round-65 spot-check tip)

Claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`; predeclaration
`ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca` (frozen `plans/round-66.md`), with
Amendments A1–A4 at `dcd78c2ed28a8383ba8b03e14979041c402b6c41` — all four
appended before any candidate reading. All six axes stand at 9. Saturation
line 9, stagnation window N=3; capabilities entered rounds 57–64, so no
stagnation waiver is claimed.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 66 moves instrument surfaces, not the domain tables. | round 29 |
| coverage | 9 | 155 registry rows at BASE (`awk … corpus/SOURCES.md` ⇒ 155; tier A=138 B=2 C=15), fleet census `kagi ok` rc 0 (`.ufo/waves/round-66/base/census-start.txt`). | round 65 |
| operability | 9 | Measured BASE gap: the pre-file ledger gate reads `SETUP` on the round-66 wave dir (no ledger, no report) and `claims-declared` reads `CLEAN (claims=56)` with no round-66 rows — `C2_PREFILE` gate 0 (Amendment A2). | round 65 |
| freshness | 9 | Measured BASE gap: the S148 carrier bound by digest is named by no registry row and no fetch row (`grep -cF 'S143.body' corpus/SOURCES.md` ⇒ 0), while the file named for the id holds an unrelated arXiv body (39 750 B, sha `fabc74c5…`) — `C1_CARRIER` drift 0. | round 65 |
| calibration | 9 | Measured BASE gap: the LANE's own gate `bash corpus/sources-census.sh` reads `SOURCES_CENSUS: FAILED (findings=4 rows=155)` while the fleet wrapper reads `kagi ok` — the round-65 report's "census ok" named the wrapper (`C3_CENSUS` findings 4). | round 65 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 freshness** (the S148 carrier binds by path equality +
digest on a registry row that names the capture path; `C1_CARRIER` drift 0 → 1),
**C2 operability** (the pre-file ledger reads pass with the wave's attack seats
reconciled and `claims-declared` reads CLEAN with the round's rows;
`C2_PREFILE` gate 0 → 1), **C3 calibration** (the lane's own census gate goes
`findings=4` → 0; `C3_CENSUS`). No retirement, split or stagnation waiver.

## Round 66 — post-move (claims C1 freshness, C2 operability, C3 calibration)

Candidate: the round-66 landing commits (recorded in the report;
`.ufo/waves/round-66/final/` holds the candidate-revision receipts). Claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`; predeclaration
`ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`; Amendments A1–A4 at
`dcd78c2ed28a8383ba8b03e14979041c402b6c41`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-66-c1.sh --tree <BASE> ` ⇒ `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` rc 1 (receipt `.ufo/waves/round-66/final/c1-base.txt`) → candidate ⇒ `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc 0 (`.ufo/waves/round-66/final/c1-candidate.txt`): the S148 pin is read from a registry row that NAMES its carrier capture (S164, `.ufo/waves/round-64/capture/S143.body`, 264946 B), the fetch row's 16th column names the same path with columns 10/11 equal to the pin and byte count, and `corpus/volatile-shape.py`'s `DEFAULT_CAPTURE` agrees — three anchors, one path, digest-checked. Guard: (a) BASE tree reads drift 0 (never SETUP), (b) selftest 45 cases (measured round 67 — this cell said 43), (c) the round-65 volatile gate still `VOLATILE_SHAPE: match=1`, (d) a row citing `.ufo/waves/round-64/capture/S148.body` (the 39 750 B arXiv body) is refused with `digest-mismatch:`. | `plans/round-66-c1.sh` (sha256 `d72f9712…`; measured round 67 — this cell said `6a79a96d…`); `.ufo/waves/round-66/final/c1-*.txt`; `corpus/SOURCES.md` S164 |
| operability | 9 → 9 | [C2] **honest stop** (corrected in round 67, routed defect 1 of the round-66 closure): `bash plans/round-66-c2.sh` ⇒ `C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0` (receipt `.ufo/waves/round-66/final/c2-candidate.txt`, guards `a=1 b=0 c=0 d=1`); the fleet gate reads `PREFILE-FALSIFICATION: SETUP findings=1` because `.ufo/waves/round-66/w1-results.json` was never written, so the predicated reading was not produced on this round's tree. The predicate itself is reachable on a fixture fleet (`R66MutC2`). This cell previously stated `gate=A … attack_seats=K` and that the ledger "reads `pass` with the wave's attack seats reconciled"; the receipt it cites says otherwise and the ledger omits `R66Sentinel` (both repaired in round 67, L4). | `plans/round-66-c2.sh` (sha256 `3d0fc704…` + the gate-folding fix); `.ufo/waves/round-66/final/c2-*.txt`; `.ufo/waves/round-66/claim-falsification.tsv` |
| calibration | 9 → 9 | [C3] `bash plans/round-66-c3.sh --tree <BASE>` ⇒ `C3_CENSUS: findings=4 rows=155 guard=1` rc 1 → candidate ⇒ `C3_CENSUS: findings=0 rows=156 guard=1` rc 0: the LANE's own `corpus/sources-census.sh` (not the fleet wrapper — the round-65 report named the wrapper while this gate was red) goes from `SOURCES_CENSUS: FAILED (findings=4)` to `CLEAN`. Guard: (a) the verdict LINE is the verdict (this gate exits 0 on FAILED), (b) removing the entry's `cites:` line returns `findings=4`, (c) a shim gate printing `rows=999` makes the counter print 999 (no hard-coded population), (d) the fleet wrapper reads `kagi ok`. | `plans/round-66-c3.sh`; `.ufo/waves/round-66/final/c3-*.txt`; `corpus/SOURCES.md` S155/S156/S164 rows + `corpus/knowledge/claim-instrument-class-matrix.md` |
| depth | 9 → 9 | No claim. The new criteria QM89–QM91 record the instrument lessons (verdict fields computed, legs scoped to the state they govern, handoff shape verified). | `corpus/QUALITY.md` §round-66 |
| coverage | 9 → 9 | No claim. Registry 155 → 156 (S164 `supersedes S148 —`, tier A, `mined`, `180d`); `corpus/source-fetches.tsv` +3 (S155, S156, S164). | `corpus/SOURCES.md`; `corpus/source-fetches.tsv` |
| adjacency | 9 → 9 | No claim. Connector sweep: no sibling lane holds a carrier-binding instrument or a lane-gate census counter; the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | `.ufo/waves/round-66/w1/R66Connector.md` |

## Round 67 — pre-move (repo `076701a`, round-66 spot-check tip)

Claim BASE `076701a11a58e3eb58d996b4c76c5e18071fb179`; predeclaration
`plans/round-67.md` (frozen alone at the first commit of this round). All six
axes stand at 9. Saturation line 9, stagnation window N=3; the last capability
row entered round 61 and rounds 64–66 entered none, so **the stagnation nudge
fires** (`AXES.md`) and the round is a capability move (C1) plus the harmed-axis
repair the round-66 closure routed (C2).

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 67 moves an instrument surface. | round 29 |
| coverage | 9 | 156 registry rows at BASE (`bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: CLEAN (rows=156 …)`, receipt `.ufo/waves/round-67/base/base-gate.txt`), fleet census `kagi ok` rc 0. | round 66 |
| operability | 9 | Measured BASE gap: the lane census gate's only capture test is the location string's length (`grep -n 'floc' corpus/sources-census.sh` ⇒ `${#floc} -ge 8`), so a repointed capture reads `SOURCES_CENSUS: CLEAN` (`.ufo/waves/round-67/base/blind-gate.txt`). | round 66 |
| freshness | 9 | Measured BASE gap: 36 fetch rows name a capture file, 0 are digest-checked by a gate, and 1 declared quote (S115) does not locate (`corpus/rendered-text-v1.py locate` ⇒ `count=0`). | round 66 |
| calibration | 9 | Measured BASE gap: seven record mismatches from the round-66 closure §6 (L1–L7 of `plans/round-67.md` §C2), e.g. `SCORECARD.md:2339` states `gate=A … attack_seats=K` while its receipt reads `gate=0`. | round 66 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 freshness** (capability: the census reads each declared
capture's bytes and its quote's location; `C1_READTHROUGH` bound 0 → 36,
located 0 → 36, caught 0 → 6/6) and **C2 calibration** (seven record surfaces
match observed state; `C2_FIDELITY` mismatches 7 → 0). No retirement, split or
stagnation waiver is claimed — the nudge fires and is used.

## Round 67 — post-move (claims C1 freshness, C2 calibration)

Candidate: the round-67 landing commits (recorded in the report;
`.ufo/waves/round-67/final/` holds the integration receipts). Claim BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179`; predeclaration `aa8807e4`; Amendments
A1–A3 appended before the readings they govern.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-67-c1.sh --tree <BASE extraction> --base-tree <BASE>` ⇒ `C1_READTHROUGH: bound=36 located=35 caught=0/6 guard=0` rc 1 → candidate ⇒ `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` rc 0: the lane census gate reads every capture-path-shaped row's declared body (36), binds sha256 and byte count to columns 10/11, and locates the declared quote under the declared normalization (S115's re-cut is the 35→36 move); six mutations (repoint, truncate-by-1, delete, absolute, `..`, quote) each read `FAILED` with the expected `FINDING SC_CAPTURE id=… <reason>` from the candidate gate's own stdout. Guard: (a) the clean tree prints `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)` with the counts equal to the counter's own derivation; (b) `--selftest` 89 cases; (c) the BASE gate is CLEAN on the repointed tree (blindness witness, `.ufo/waves/round-67/base/blind-gate.txt`); (d) the fleet wrapper reads `kagi ok`; (e) prose rows yield no `SC_CAPTURE`; (f) the candidate's normalizer hashes to the committed one (a fake-normalizer tree reads `caught=5/6 guard=0`). Named ceilings: a body rewritten together with its rows passes; prose locations (121) are counted and never opened; `located` is a presence property, not quote strength; row identity is counter-guarded, not gate-guarded. | `plans/round-67-c1.sh` (sha256 `5d3725b0…`); `.ufo/waves/round-67/final/c1-*.txt`; `corpus/knowledge/source-capture-binding.md` |
| calibration | 9 → 9 | [C2] `bash plans/round-67-c2.sh --tree <BASE extraction>` ⇒ `C2_FIDELITY: mismatches=7 population=7 guard=1` rc 1 → candidate ⇒ `C2_FIDELITY: mismatches=0 population=7 guard=1` rc 0: the seven record surfaces the round-66 closure routed now re-derive clean — the scorecard's operability cell states the honest stop its receipt shows (L1), SKILL's round-66 C1 pin equals the instrument's own `cases=45` (L2), the coverage map carries the carrier entry (L3), the round-66 ledger carries the `R66Sentinel` row (L4), `claims.json` names `C1_CARRIER/C2_PREFILE/C3_CENSUS` (L5), the reconstructed `c3-base.txt` matches a fresh BASE run's four findings (L6), and the round-66 lesson carries the six changed `used-by` cells plus the new row (L7). Guard: (a) BASE reads seven defects; (b) selftest 24 cases with one planted defect per leg and two L6 forgeries; (c) no leg is a constant — each re-derives from committed bytes. Named ceilings: the two routed items that live in the fleet-root report (its §6.4 LOG pointers and §6.5 controls battery) are out of lane write scope and are named in the report, not legs. | `plans/round-67-c2.sh` (sha256 `d4deb735…`); `.ufo/waves/round-67/final/c2-*.txt`; `.ufo/waves/round-67/w1/R67ExecCounterC2.md` |
| depth | 9 → 9 | No claim. The entry `corpus/knowledge/source-capture-binding.md` states the read-through contract, the two digest layers, seven bounds and eight falsifiers; QM95/QM96 enter the bar. | `corpus/knowledge/source-capture-binding.md`; `corpus/QUALITY.md` |
| coverage | 9 → 9 | No claim. Registry 156 → 157 (S166, tier A, `mined`, `180d`); one fetch row; `corpus/source-fetches.tsv` S115 col13 re-cut. | `corpus/SOURCES.md`; `corpus/source-fetches.tsv` |
| operability | 9 → 9 | No claim. The census gate gains a mode-free check with 10 new selftest cases (78 → 88) and two new counters; nothing schedules any gate and the by-hand duties remain by-hand. | `R21-03`; `R21-02` |
| adjacency | 9 → 9 | No claim. Connector sweep: no sibling lane holds a capture-digest/quote census; RFC 9530 is cited by no sibling registry; the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | `.ufo/waves/round-67/w1/R67Connector.md` |

## Round 68 — pre-move (repo `d3b2a4e`, round-67 spot-check tip)

Claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`; predeclaration
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636` (frozen `plans/round-68.md`,
committed alone before any candidate work). All six axes stand at 9.
Saturation line 9, stagnation window N=3; a capability entered round 67
(capture read-through), so the stagnation nudge does not fire and the
lowest-axis obligation binds. All six cells are equal, so the tie is broken by
measurement: the round-67 non-author closure and its revenger measured three
surviving classes in the gate round 67 had just landed.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29 (`R29-01`); round 68 moves instrument surfaces, not the domain tables. | round 29 |
| coverage | 9 | 157 registry rows at BASE (`bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: CLEAN (rows=157 …)`, receipt `.ufo/waves/round-68/base/census-start.txt`), fleet census `kagi ok` rc 0 (`.ufo/waves/round-68/base/fleet-wrapper.txt`). | round 67 |
| operability | 9 | The census selftest pin in the ledger is stale on contact (ledger `R21-03` expects 88 cases; the gate prints `SOURCES_CENSUS_SELFTEST: PASS (89 cases)`, `.ufo/waves/round-68/base/selftest.txt`), and `claim-ledger.sh cells` refuses the historical `## Round 63 — planned` heading. Nothing schedules any gate. | round 67 |
| freshness | 9 | Measured BASE gap: the census reads only pure capture-path cells. S166 — the round-67 sourced claim's own capture row — is prose, so its bytes, digest and col-15 pin are never read (`.ufo/waves/round-68/base/mut/`); a trailing space, a whole-file CRLF save and a borrowed col 15 all read `SOURCES_CENSUS: CLEAN` on the BASE gate. Base derivation: `verified=36 col15=31` (`.ufo/waves/round-68/base/base-derivation.md`). | round 67 |
| calibration | 9 | Measured BASE gap: three record surfaces disagree with observed state — the selftest pin (above), no ledger row exists for a round-68 claim, and the cells gate cannot report (setup on a heading the audit's own contract does not cover). | round 67 |
| adjacency | 9 | Ownership partition gate green (`R17-02`); the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | round 58 |

Declared claims: **C1 freshness** (the census re-verifies every mined row that
names a lane-tree capture — pure path or `.ufo/waves/` token — recomputes col
15's normalized digest, and refuses the stray-byte classes;
`C1_VERIFIED` verified 36 → 37, col15 31 → 32, caught 0/6 → 6/6) and **C2
calibration** (the lane's record surfaces match observed state; `C2_RECORD`
mismatches 3 → 0). No retirement, split or stagnation waiver is claimed.

## Round 68 — post-move (claims C1 freshness, C2 calibration)

Candidate: the round-68 landing commits (recorded in the report;
`.ufo/waves/round-68/final/` holds the integration receipts; `w1/` holds the
fifteen seat reports). Claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`;
predeclaration `23a8e0290d8d3a6f1de16eafce40fd1a189ef636`; Amendment A1
`4251519bd6e8b5c152d70ae286e04a117a49ed4f` (anchor-derivation and target-teeth,
recorded before any counter existed).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] `bash plans/round-68-c1.sh --tree . --base-tree <BASE extraction>` ⇒ candidate `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1` rc 0, `defects=0` over the whole fetch population; the same counter on the BASE tree reads `caught=0/6 guard=0` and the L1 derivation there reads `verified=36 col15=31` (recut-only tree: `37/32`, `.ufo/waves/round-68/final/l1-derivation-recut-only.txt`). The census now reads every mined row that names a lane-tree capture — pure path or exactly one `.ufo/waves/` token — recomputes col 15's normalized digest for bound rendered rows, and refuses `capture-whitespace`, `capture-token`, `normalized-digest-mismatch` and file-level `SC_FETCH cr-in-tsv`; the BASE gate reads CLEAN on all three witnesses in `.ufo/waves/round-68/base/mut/`. | `plans/round-68-c1.sh`; `R21-03`; `.ufo/waves/round-68/final/`; `.ufo/waves/round-68/w1/R68Reviewer.md`; `.ufo/waves/round-68/w1/R68Sentinel.md` |
| calibration | 9 → 9 | [C2] `bash plans/round-68-c2.sh --tree .` ⇒ `C2_RECORD: mismatches=0 population=3 guard=1` rc 0 (three record surfaces: the census-selftest pin migrates 88 → 98 with a journaled pair, the two round-68 ledger rows exist and execute, and `cells` returns a verdict line instead of SETUP on the historical `## Round 63 — planned` / `## Round 64 — planned (next)` headings). The cells repair keeps the scored-section six-axis check and the table-under-a-planned-heading die. | `plans/round-68-c2.sh`; `R11-09`; `.ufo/waves/round-68/journals/expectation-migrations.json`; `.ufo/waves/round-68/final/` |
| depth | 9 → 9 | No claim. `corpus/knowledge/source-capture-binding.md` gains the widened population, the monotone classification rule, the col-15 recompute and its bounds; QM97–QM99 enter the bar. | `corpus/knowledge/source-capture-binding.md`; `corpus/QUALITY.md` |
| coverage | 9 → 9 | No claim. Registry 157 → 158 (S167 = RFC 4648 §3.3, tier A, `mined`, `180d`); one fetch row with a pure capture path; S166's col-16 re-cut to its pure path; used-by gains this entry on S099/S113/S115/S143. | `corpus/SOURCES.md`; `corpus/source-fetches.tsv` |
| operability | 9 → 9 | No claim. The census gate gains four reason classes and 9 selftest cases (89 → 98); the two counters carry their own selftests (`C1_VERIFIED_SELFTEST` 56 cases; `C2_RECORD_SELFTEST` 7). Nothing schedules any gate and the by-hand duties remain by-hand. | `R21-03`; `plans/round-68-c1.sh --selftest`; `plans/round-68-c2.sh --selftest` |
| adjacency | 9 → 9 | No claim. Connector swept 20 sibling lanes: tsukuroi/kama/souji/kumitate/tameshi hold CRLF *tolerance* guards where kagi now refuses, kaidoku/kama/kumitate recompute their own digests — complements, no duplicate. The carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. | `.ufo/waves/round-68/w1/R68Connector.md` |
