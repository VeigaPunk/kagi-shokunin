# kagi-shokunin corpus — index

Proprietary memory for the secrets & vault ops domain (the-janitor flows,
credential-hygiene evidence). Seeded 2026-09-28 by the round-1 **aggregator L1**
because kagi was deferred that round (`MANIFEST.json` →
`rounds[1].lanes.kagi: "not-dispatched"`); filled and reconciled in round 2
by the kagi L1.

Every entry was written from read-only inspection of real files on this host.
No vault access was performed: no `op` vault command, no `the-janitor request`,
no janitor tmux session was started (`tmux ls` showed only `ufo_sighting`).
No secret value, session token, or vault ref path is copied into this corpus —
see `lessons/round-1.md` for the rule and its rationale.

## Coverage map

| Area | Entry | Source basis (read 2026-09-28) |
|---|---|---|
| CLI command surface + failure texts | `knowledge/janitor-command-surface.md` | `~/.local/bin/the-janitor` (333 lines), `~/.config/the-janitor/client.py` (117 lines) |
| Credential isolation of the handler | `knowledge/credential-isolation.md` | `the-janitor` `cmd_serve`, `~/.config/the-janitor/opencode.json`, `~/.config/opencode/agents/janitor.md`, `~/.config/opencode/tools/janitor_auth.ts` |
| Vault-ref env file discipline | `knowledge/op-env-refs.md` | `the-janitor` `cmd_refs` / `cmd_run`, `stat` on `~/.config/the-janitor/op.env` (path + mode only) |
| TAC / local-evidence integrity | `knowledge/tac-evidence-integrity.md` | `~/.local/bin/tac-check` (88 lines), `~/.local/state/tac/handoff-status.json`, `~/.agents/AGENTS.md` |
| 1Password ↔ Chrome CDP bridge | `knowledge/cdp-bridge-1password.md` | `the-janitor` `cmd_cdp_ensure` / `cmd_cdp_status`, live `cdp-bridge status` output, `op --version` |
| Round-1 status + lessons | `lessons/round-1.md` | `MANIFEST.json rounds[1]`, `LOG.md`, `SKILL.md`, `SHONEN.md` |
| Round-1 aggregator audit | `lessons/round-1-aggregator-audit.md` | corpus conformance check per `~/projects/shokunin/CORPUS.md` |
| Round-1 deferral & seed lessons (aggregator) | `lessons/round-1-aggregator-seed.md` | `MANIFEST.json rounds[1]`, `.ufo/watchdog.log`, `.ufo/waves/round-1.json`, `LOG.md` round-2 entry, commit `9b3e49f` |
| `op` CLI auth states + endpoint drift | `knowledge/op-cli-surface.md` | live `op account list`, `the-janitor whoami`, `the-janitor request` attempt, `ss`/`curl` port probes, `cmd_stop` read |
| Round-3 attempt + drift lesson | `lessons/round-3.md` | the same probes; `the-janitor stop` idempotence observed |
| Env-var contract + auth selectors | `knowledge/janitor-env-contract.md` | `~/.local/bin/the-janitor` L7–27, L194–210; live `op account get` shape; `refs` output |
| Session-id / lock lifecycle, rotation & revocation surfaces | `knowledge/janitor-lifecycle.md` | `the-janitor` L128–249 (`cmd_request`/`stop`/`run`/`refs`), `client.py` L41–95, `janitor_auth.ts`; live `status`/`whoami`/dir/tmux/curl probes |
| Round-5 lifecycle lesson | `lessons/round-5.md` | same probes; no drift vs round-4 |
| Opencode config layering + inert `config.json` | `knowledge/config-layering.md` | `opencode debug config`/`debug agent janitor` under the `_serve` env (resolved dump: 9 providers, 23 agents, global plugin loaded; `steps: 4`); `the-janitor` `cmd_serve`; binary `customize-opencode` doc |
| Credential-hygiene checklist, executed (gate + data) | `corpus/checklist-run.sh` + `corpus/checklist.tsv` | one row per SKILL.md checklist item (8 columns: `id class lead check expect_exit expect_last reason note`); `lead` ERE ⇒ bijection over the 16 items both ways; `runnable` rows execute with an expected exit + last line, `by-hand` rows declare a closed class + a unique ≥24-char reason; ratio line splits `delegated`/`direct`; modes `verify`/`--ratio`/`--list`/`--only ID`/`--selftest` (34 cases); POLICY refuses a `check` naming a denied surface (op.env, `op run|read|inject`, handler start/stop/run, `claim-ledger.sh`); the ref-path sweep prints counts only. Baseline `CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7 failed=0)` + `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` |
| Checklist-execution contract (entry) | `knowledge/checklist-execution.md` | the 8-column schema, verdict/exit table, delegation map, the premise-vs-duty rule and the competing `3/13` and `8/8` readings, 12 bounds (incl. the constant-`printf` counterexample and the `vault`-name allowlist), 10 falsifiers |
| Round-15 lesson | `lessons/round-15.md` | operability axis-move: the checklist becomes an executed declaration; 16-item census vs the stale `15-item` scorecard cell; nine execution-found defects (two silent-death `uniq -d`/`grep` sites, H4's newline-less front-matter, E4's three placeholders, the swallowed E4 verdict, H8's wildcard blind spot, H1's comment-text match, H7's purged-DB false defect, `$0` from a foreign cwd) |
| Drift gate (script) | `corpus/drift-pins.sh` | compares live host vs the committed baselines; exit 0/1/2, `--pin`, `--selftest` (13 cases: content/mode drift, missing, symlink+hardlink, symbol moved/gone/ambiguous, count drift, dotenv shape drift, clean); vocabulary incl. `POLICY`/`EXTRA`/`DUP`/`EMPTY`/`SHAPE` |
| Drift baseline (data) | `corpus/drift-baseline.tsv` | 15 cited host files, `$HOME`-relative path + mode + lines + sha256 (v1 was a printer with no stored values); 6 private 0600 files carry `-` (hash withheld: offline oracle — L2 sentinel review) |
| Drift symbol pins (data) | `corpus/drift-symbols.tsv` | 20 content claims the corpus makes (`path<TAB>line<TAB>ERE[<TAB>shape]`): value pins on the two endpoint declarations, key-presence pins, `#10`+`shape` on `op.env`; `--pin` moves a line only while the ERE still matches exactly once and refuses count/claim changes |
| Drift-gate contract (entry) | `knowledge/drift-gate.md` | schemas, verdict table, hash policy + sentinel dissent, `--pin` refusals, bounds, reproduction; 13-case selftest evidence |
| Declared-surface census (gate) | `corpus/surface-census.sh` | kind/exact-mode per declared path, `UNLISTED` children of the 4 enumerable dirs, runtime shape pins, write-side verb probes; exit 0/1/2; `--verbs`, `--verbs --deep`, `--selftest` (16 cases) |
| Surface declaration (data) | `corpus/surface-census.tsv` | 35 rows (20 asset / 15 runtime) over the-janitor config/state, the opencode layer that reaches the handler, evidence/custody, network-adjacent paths; 4 `# scan` directives; one `mode = -` row (the contested chrome-profile dir) |
| Runtime shape pins (data) | `corpus/state-shape.tsv` | 22 rows (count pinned by ledger row `R11-10`): sqlite magic (16-byte, NUL-exact), modes, table/row floors at 1/3 of observed, log size floor, JSON key **names**; no content, no hashes |
| Ownership + breadth gate | `corpus/scope-gate.sh` | fail-closed partition and citation checks plus count-only breadth drift; exit 0/1/2; `--map`, `--breadth`, `--selftest` (61 cases), `--falsify` (18/18 mutations) |
| Ownership + breadth data | `corpus/adjacency.tsv` | 5 owned prefixes (27/35 census rows), 4 shared groups (8 rows), 8 no-enumerate boundaries, 4 derived leaf breadth pins; `path owner status claim basis token note` rows; live leaf ratios 20/4, 105/2, 4/1, 53/1 |
| Round-16 lesson | `lessons/round-16.md` | adjacency axis-move: prose ownership becomes an enforced partition; stale-basis defect; L2 falsification findings |
| Shared-directory breadth contract | `knowledge/adjacency-breadth.md` | derived leaf-membership rule, count semantics, privacy choice, verdict/exit table, 9 numbered bounds (13 is its failure-token count), reproduction, 18 mutation classes |
| Round-17 lesson | `lessons/round-17.md` | coverage axis-move: four shared-directory breadth ratios become fail-closed declarations; pre-state counterexample, defects caught, L2 synthesis |
| Surface-census contract (entry) | `knowledge/surface-census.md` | schemas column by column, verdict+exit table, shape-pin policy (floors, snapshot reads, two-pass sqlite), cross-check invariant, 10 probes + safety overrides, round-10 findings (refs prefix-match leak, `run` non-determinism, NMH dir on refusal), bounds, reproduction, 11 falsifiers |
| Round-6 layering lesson | `lessons/round-6.md` | same probes |
| Handler on-disk state: transcript DB, error log, lock topology, wedge recovery | `knowledge/handler-on-disk-state.md` | `xdg-data/opencode/opencode.db` sqlite introspection (row counts, `$.type` shapes only), `opencode.log` forensics (8 runs since 2026-08-29), `the-janitor` lock pairs L130–131/139–140/175–176, measured wedge timings |
| Control-plane trust boundary: unauthenticated port 40961, `/session/{id}/shell` direct exec, agent/`tools`-map ceiling scope, daemon-env inheritance, squat-phish surface | `knowledge/handler-trust-boundary.md` | scratch `opencode serve` repros (no-auth 200 vs `OPENCODE_SERVER_PASSWORD` 401/Basic-only; `/doc` 162 routes; shell route 51 ms no-model; `tools` override under `agent:"janitor"`; fake `OP_*` env echo; clean-shell `op` negative control), `client.py` header audit, `ServerAuthConfig` + plugin-loader strings in binary, tmux 3.7b env-passthrough test |
| Control-plane hardening handoff (operator recipe) | `knowledge/control-plane-hardening.md` | the same probes; `client.py` Authorization gap; sequencing analysis |
| Round-7 boundary lesson | `lessons/round-7.md` | same probes + L2 verification wave |
| Transcript hygiene gate (script) | `transcript-scan.sh` | snapshot-scans db+wal copies in `mktemp`; 888 cells × 32+5 patterns (LIKE metachars escaped) + 5 credential-table tripwires; `--selftest` seeded-hit/wal-resident check; `--classify` bounded triage (key_shaped vs prose, no content) |
| Transcript hygiene (entry) | `knowledge/transcript-hygiene.md` | schema census (text columns + credential tripwires), two-tier semantics, round-8 vs round-9 baselines (the recorded 0-HIT figure describes a narrower revision), read-side snapshot design, `xai-` prose-collision class |
| Round-8 lesson | `lessons/round-8.md` | false-positive taxonomy on first contact; WARN-as-hygiene-metric; README rot fix |
| Round-4 env-contract lesson | `lessons/round-4.md` | `the-janitor` L7–27/L194–210 re-read; live `whoami`/`refs`/`run`/`op account get`; endpoint-drift probes |
| Round-4 aggregator audit | `lessons/round-4-aggregator-audit.md` | aggregator conformance pass at round 4 (independent re-execution of the cited probes) |
| Round-5 aggregator audit | `lessons/round-5-aggregator-audit.md` | aggregator pass at round 5 |
| Round-5 aggregator mirror/bare-path defect | `lessons/round-5-aggregator-mirror-bare-path-and-unclosed-prereq.md` | aggregator finding: `handoff-status.json` cited bare in SKILL.md; the absolute path existed only in corpus files |
| Round-9 lesson | `lessons/round-9.md` | baselines-not-printers (a printer with no stored values has no verdict); `UNPINNED` fired during landing and is the designed signal; per-symbol pins vs per-file hashes; overclaim sweep |
| Round-10 lesson | `lessons/round-10.md` | declared surfaces are prose until a gate reads them; the undeclared-child class (round-6 vector) and the two xdg-data artifacts get verdicts; selftest caught two real gate defects (dropped-table ⇒ SKIP false clean; scan-scope fixture); `--deep` split for probes with real-world effect; ref-literal hygiene via runtime-assembled prefix |
| Claim ledger + revision stamps + citation gate (gate) | `corpus/claim-ledger.sh` | `verify` = stamps (`STALE`/`MISSING`/`NOT-A-FILE`, every stamped column compared) + claims (exit equality AND last-non-empty-line ERE, both `expect` and `timeout` guarded against bare-anchor/unbounded forms; `substrate`-tagged rows `DEFER` when the handler is absent — round 18); `stamp PATH… [--out F] [--prune]` rewrites the revision file from exactly the paths given — it replaces the row set, so a run that would DROP a pinned path is refused unless `--prune` is passed (round 12: an in-flight 10-path stamp silently dropped 18 rows; the guard is per-path, so an equal-count path swap is refused too) — a reviewed commit that refuses absolute/whitespace paths and the output file, in either argument order; `citations` checks five citation classes + brace sets over every token in a code span and fails `UNRESOLVED`/`EPHEMERAL` unless the citing line labels the token (`scratch|ephemeral|relocat|formerly|no longer|removed|renamed|historical` → printed as `LABELED` and counted); since round 25 a lone clone is explicit (`FLEET-ABSENT` lines, `CITATION_GATE: INCOMPLETE` exit 3, verify `LAYOUT-INCOMPLETE` + `CLAIM_LEDGER: INCOMPLETE`); `verify` also fails on any `R…-…` whole word a checked doc cites that is not a row (`MISSING-ID`); `cells` audits this file's score card (see `knowledge/claim-ledger.md`); `docs` audits the knowledge surface (every `corpus/knowledge/*.md` entry declares its re-verification and is revision-pinned); `--selftest` 170 cases; POLICY refuses non-simple commands without running (exit 2) |
| Ledger rows (data) | `corpus/claim-ledger.tsv` | 65 rows (39 at round 21, 35 after round 18; round 25 added `R25-01..04`): runnable checks for the shipped gates, fixed count guards, score-cell audit, round-17 breadth assertions `R17-01..03`, round-18 substrate-deferral pins `R18-01..03`, and the round-21 byte-contract and source-census rows; expectations are anchored and time-bounded; a row tagged `substrate` defers (never fails) when the handler is absent |
| Revision stamps (data) | `corpus/stamps.tsv` | 88 rows (63 at round 21, 56 after round 18, 54 at round 17): every cited in-repo artifact, checked as `path sha256 lines bytes`; regeneration is a reviewed `stamp` commit, never an automatic re-pin |
| Claim-ledger contract (entry) | `knowledge/claim-ledger.md` | why the gate exists (the round-10 hand-adjudication), the six classes column by column (stamps, claims, citations, ids, scorecard cells, knowledge entries), the last-line rule and why, the citation class table + marker rule, the three audit teeth (re-run the cited rows, re-compare the cited pins, re-resolve the declared entry ids), before→after, reproduction, 30 bounds, falsifiers |
| Knowledge-entry declarations (data) | `corpus/knowledge/*.md` + `claim-ledger.sh docs` | one `Reverify:` line per entry: 22 row-linked / 3 by-hand / 25 pinned (21/3/24 at round 21, 18/3/21 after round 18, 20/17/3 at round 17); the floor is `ceil(entries/2)`, by-hand reasons are unique, and every entry is revision-stamped (ledger `R14-01`) |
| Round-14 lesson | `lessons/round-14.md` | freshness axis-move: the knowledge surface gets a re-verification link; the round-13 `row_pointed ≥ half` plan falsified by measurement (35 stamp-only cells, at most 5–7 honestly reachable); the wave's counterexamples and what happened to each |
| `op.env` contract probe (gate) | `corpus/op-ref-probe.sh` | the two-parser contract + masking scope as a verdict: fixture-generated plain-value env files, `op run` vs `the-janitor refs` key sets, dotenv edge classes (`#`/quote/CRLF/duplicate/`${:-}`/single-quote), two-file precedence **and union**, the hard-failure class (malformed line / BOM / directory — resolver refuses, inventory clears), six error signatures; `--evaluate` (pure comparison), `--fixture`, `--selftest` (36 cases incl. the four POLICY-bypass cases the round-12 sentinel found and the hard-failure class); POLICY refuses any op-side file carrying a ref token, so the gate has no vault contact by construction |
| `op.env` consumption (entry) | `knowledge/op-ref-consumption.md` | the divergence table line shape by line shape, the masking contract (refs masked, plain values not), dotenv semantics `refs` cannot see, the three ref-consuming verbs (`run`/`inject`/`read`), decision table, bounds (mask token unmeasured), reproduction, falsifiers |
| Round-13 lesson | `lessons/round-13.md` | calibration axis-move: a citation becomes a resolvable object and a score becomes a re-verified pointer; the unanchored-lookup defect that made all 48 cells look pointed; the recursion the audit would have had; what the L2 wave broke and what happened to each item |
| Round-12 lesson | `lessons/round-12.md` | depth axis-move: a reachable ceiling was narrower than the scorecard claimed; what the L2 wave broke in the probe and what happened to each item |
| Round-11 lesson | `lessons/round-11.md` | a claim without a command is not a claim; four real doc defects found on first contact; the four gate defects and which run caught each; the L2 wave's counterexamples and what happened to each; design calls (last-line rule, no auto-re-pin, marker rule, shape-based classes) |
| Substrate-deferral contract (entry) | `knowledge/substrate-deferral.md` | why a claim row that measures an absent substrate must defer rather than fail: the `substrate` note tag, `substrate_present()`, `DEFER`/`deferred=N`/`row_deferred=N`, `KAGI_SUBSTRATE` override, census selftest skip-cases, 5 bounds, reproduction, falsifiers |
| Round-18 lesson | `lessons/round-18.md` | OMP/ufo-fsd re-census: zero origin-tree references in-lane (vacuous `--src` repair); the real drift class is total substrate loss — measured host state, the two genuine lane defects found and fixed, superseded-revision erratum, carried debt |
| Machine credential custody boundaries | `knowledge/onepassword-machine-credentials.md` | 1Password CLI process delivery, Service Account scope, Connect tokens, and Broker preview key custody (SOURCES.md S001–S007; read 2026-10-19) |
| SOPS age recipient and data-key rotation | `knowledge/sops-age-key-rotation.md` | recipient access, multi-key recovery, data-key rotation, and compromise order (SOURCES.md S009–S011; read 2026-10-19) |
| Vault/OpenBao auth, token, and lease lifecycle | `knowledge/vault-openbao-token-lease-lifecycle.md` | distinct authentication, token, dynamic-secret lease, and KV boundaries (SOURCES.md S012–S016; read 2026-10-19) |
| Round-19 re-census lesson | `lessons/round-19-recensus.md` | re-census verdicts, historical-marking audit, and named path/substrate debt |
| Round-6 aggregator audit | `lessons/round-6-aggregator-audit.md` | nonconformance verdict and re-executed citation/count findings |
| Round-9 aggregator corpus verdict | `lessons/round-9-aggregator-corpus-verdict.md` | corpus literal-text, count, and gate review verdict |
| Adjacency scope contract | `knowledge/adjacency-scope.md` | checked ownership partition and shared-directory breadth boundaries |
| Source registry | `corpus/SOURCES.md` | contract-v1 registry, study paths, bounded search record, and unopened leads |
| Admission quality bar | `corpus/QUALITY.md` | knowledge-entry admission bar and criteria from mistakes |
| Source registry census gate | `corpus/sources-census.sh` | read-only registry and citation consistency gate with selftest |
| Round-21 lesson | `lessons/round-21.md` | round mistakes, evidence pointers, and corresponding quality criteria |

The **overlap table is machine-checked** since round 16: each row is a group in
`corpus/adjacency.tsv`, its owner and the citation proving that lane's claim are
verified by `corpus/scope-gate.sh`, and the `owner=integrator` row names the
arbiter of a pending ruling, not a found owner. Contested scope is monitored
here, owned elsewhere — reported, not ruled (see `PROVINCE.md`):

| Overlap | Other lane | Status |
|---|---|---|
| `$HOME/.config/opencode` (+ the 4 children that reach the handler) | multi-claimed: kotoba owns the instruction/agent surface and the provider declaration is operator-owned (`kama-shokunin/corpus/knowledge/cross-lane-scope.md:12-13,29`), kama the endpoint identity, kengaku wrote a temporary provider and restored it byte-identical | **`unresolved`** — no fleet artifact names a single owner (24/14/9/2 files in kotoba/kama/kengaku/kumitate); kagi claims credential/request hygiene on those children only; ruling owed to the integrator |
| `$HOME/.agents/AGENTS.md` | kotoba (`kotoba-shokunin/corpus/knowledge/alwayson-checklist-round7.md:30`) audits the same file as an always-on checklist surface — sole fleet claimant | kagi pins its bytes; kotoba owns the checklist/shape reading — no adjudication needed, both are read-only |
| `$HOME/.local/share/the-musketeer/chrome-profile` (+ the NMH dir below it) | kake leases the musketeer chrome profile machine-wide (`kake-shokunin/SKILL.md:161` — *not* `:104-107`, which is webzites/probe material and was cited here until round 16); kake names kagi as the rival claimant (`kake-shokunin/corpus/lessons/round-1-aggregator-audit.md:72-75`) | profile dir: **contested**, presence-only here (`mode = -`); kagi owns only the NMH dir + manifest it writes via `cdp-bridge ensure` (`lessons/round-8-aggregator-box3-coldrun.md:64`); the lease stays with kake/integrator |

## Interactive attempt record (2026-10-15)

| Attempt | Entry | Evidence and admission status |
|---|---|---|
| Round 20, depth; blocked before specialist submission | `lessons/round-20.md` | Canonical 32-scope plan validated but undispatched; effective role bindings and connector fallback do not meet the operator contract. Bounded op 2.40.0 byte observations on the inherited dirty probe are retained as investigation evidence, not an admitted feature, knowledge entry or verified completed round. |

## Frontier

- **Observable release clocks** — entered in round25 (S033–S037; S038 empty-feed reject); on-demand observation of declared identities, not continuous vendor-truth monitoring.

Areas being explored, not held as lane knowledge:

- **OIDC workload federation trust policy** — issuer, audience, identity-claim binding, and resulting permissions; see `SOURCES.md` §Leads (unopened), GitHub/Google Cloud/AWS federation.
- **Secret scanning: detection versus verification** — adjacent to the hygiene tripwires in chousa, kasegi, and kumitate; see `SOURCES.md` §Leads (unopened), Gitleaks/Betterleaks and TruffleHog.
- **NIST key-management draft status** — distinguish final guidance from IPDs before adopting controls; see `SOURCES.md` §Leads (unopened), SP 800-57 Rev. 5/Rev. 6 and SP 800-133 Rev. 3.

## Known gaps

- **Legacy entry headers:** 21 existing knowledge entries lack `source:`, `verified-at:`, and `recheck:`; `grep -L '^source:' corpus/knowledge/*.md | wc -l` → 21 after E1–E3 land (the command counts missing `source:`; the other field gaps are recorded in the W1 STATE dossier §3).
- **The-janitor substrate:** the last recorded host observation says it was absent; see `PROVINCE.md` §Surfaces, Round-18 erratum. Recheck on substrate return rather than treating the historical path list as current.
- **Vault-side structure:** deliberately unmapped per `PROVINCE.md` §Deliberate refusals; this corpus does not inventory which vaults, items, or fields exist.

## Round-22 active corrections and evidence

| Item | Active path | Scope |
|---|---|---|
| Feature-bound credential review | `knowledge/feature-bound-credential-review.md` | Replaces defective active readings of E1/E3 status/eligibility and product-bound token rows on already-held ground; not new coverage |
| Round-22 learning record | `lessons/round-22.md` | Outside admit disagreement, source opening quotes, old/new revision accounting and bounded claim verdict evidence |
| Historical pin migration record | `kagi-shokunin/.ufo/waves/round-22/round21-migrations.json` | Nine replaced diff lines, zero lost stamp members, old/new expectation values |

Correction to the old adjacency-breadth index wording: its numbered
**Bounds** list is not the failure-token inventory. Use the entry's named
Bounds and failure sections rather than the old “13 bounds” count
(`kagi-shokunin/.ufo/waves/round-22/build/Entry01.md`).
All old index totals retain their recorded-round context; current totals
come from the executed gates. Legacy-header migration remains intentionally
unclaimed, and absent host sources are not restored by adding headers or
restamping their descriptions. Expansion is unchanged: these are
corrections to already-held ground.

Final round-22 qualifier: the earlier “live leaf ratios” wording names the
historical 2026-09-29 observation, not a new host probe. Late Vault
role/locator corrections are in `lessons/round-22-source-errata.md`
(S022/S023); the active Broker/token review remains the same held ground.

Trend precision: the earlier round-22 index statement “Expansion is
unchanged” describes **knowledge-coverage ground only**. The repertoire
does gain one demonstrated typed-review capability (SCORECARD, first
working round22); final trend judgment separates that executable expansion
from the unchanged coverage map. Neither is independent round admission.

## Round-24 active contracts

The current gate/helper inventory is `SKILL.md` §Gate registry —
round-23/24 contracts and `PROVINCE.md` §Gates and supporting helpers.
Historical case totals above retain their recorded-round context; current
expectations are R11-09/R18-03 (ledger) and R24-01 (normalizer).

Host-tagged ledger rows default to HOST-SKIP in both verify and cells;
static policy runs before recursion skips. This is a reviewed-row boundary,
not a hostile-script sandbox. `corpus/rendered-text-v1.py` declares a
regex normalization, not browser parsing; `corpus/row-identity.sh` binds
named projections, not all row semantics. S032 corrects only S007's
case-sensitive integration-key quotation.

`lessons/round-24.md` records the fresh falsifiers, rejected broader
readings, learned criteria and measured repairs; `SCORECARD.md`'s recovery
append links the executable counters. The knowledge coverage map and the
OIDC/scanning/NIST frontier list above are intentionally unchanged.

## Round-25 active contracts

- `corpus/self-counts.py` + `corpus/self-counts.tsv` (C1, ledger R25-01/R25-02):
  38 reviewed current-tense numbers in SKILL.md, PROVINCE.md and this file bound to
  `rows:`, a non-host row's live `ledger:` verdict, or a host row's committed
  `expect:` pin; knowledge-entry numbers are outside its population (named
  debt in `lessons/round-25.md`).
- `corpus/claim-ledger.sh` lone layout (C2, R11-08/R11-09): `FLEET-ABSENT`,
  `CITATION_LAYOUT: lone-clone`, `CITATION_GATE: INCOMPLETE` exit 3,
  `LAYOUT-INCOMPLETE` + `CLAIM_LEDGER: INCOMPLETE` in `verify`; self-references
  resolve in-tree; the last token of a line is now checked.
- `corpus/release-clock.py` + `corpus/release-clocks.tsv` (C3, R25-03/R25-04):
  the 28 `on-release` registry rows bound to S033–S037 release feeds or to
  their declared capture quote; observation receipt
  `.ufo/waves/round-25/observe-1.json` (S012 fired and was re-verified).
- `lessons/round-25.md`: plan corrections R25-C1..C8, the five-row Gate, clock
  observations, M25-1..M25-5. The frontier gains one path, below; the OIDC /
  scanning / NIST rows are unchanged.

Frontier path added in round 25: **release clocks** — a source's `on-release`
recheck is a claim only when it names a feed that can be observed to move
(S033–S037); next steps are a superseding row for S029's development-label
anchor and a second locator for multi-claim unversioned rows (ClockS017/S020).
