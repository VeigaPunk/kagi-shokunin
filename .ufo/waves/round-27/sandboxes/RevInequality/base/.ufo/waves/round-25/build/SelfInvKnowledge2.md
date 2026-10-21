# SelfInvKnowledge2 — C1 self-count inventory, 8 knowledge entries

Revision: BASE `4587c61a348e4528717404a68912c373f3ef4d03`; sandbox clone `/fast/scratch/kagi-r25/SelfInvKnowledge2/lane` (HEAD verified). Real-tree tracked files = BASE (porcelain shows untracked only). Static re-derivations ran on sandbox BASE. Lane edits: none. Installs/upgrades: none. Host reads: none.
Classes: CURRENT = present tense, gate/registry, or undated; HISTORICAL = dated to a round/revision/read date, or under an erratum. CURRENT* = own wording says current, but the round-22 erratum (adjacency-scope.md:317-318) says historical. Bound: L = non-host ledger row replays it; HS = host-tagged row (HOST-SKIP by default); U = no ledger row.

## Runs (sandbox, BASE)
- `bash corpus/scope-gate.sh --selftest` → `SCOPE_SELFTEST: PASS (61 cases)`, exit 0 (R16-02)
- `bash corpus/claim-ledger.sh --selftest` → `SELFTEST: PASS (151 cases)`, exit 0; 151 `ok-case` lines, 0 FAIL
- Ledger replays: R11-11 `grep -cv '^#' corpus/surface-census.tsv` = 35; R16-04 = 5; R16-05 = 4; R16-06 = 8; R17-02 = 4; `grep -cE '^# scan'` = 4; owner/status/claim = 4/4/2
- Static, gate rules: owned 27, shared 8, prefixes 5/1/1/17/3, group census 4/1/2/1, adjacency.tsv arity {7}, breadth leaves 4 (scope-gate.sh:499-517; `# scan` at surface-census.tsv:17-20), own prefixes declared (census:30-31, scan:17-20), falsify invocations 18 (scope-gate.sh:673-812; `total=18` at :677)
- sops literal `grep -rliE 'sops|openbao|hashicorp' corpus/knowledge --exclude=sops-age-key-rotation.md --exclude=vault-openbao-token-lease-lifecycle.md; echo exit=$?` → `corpus/knowledge/feature-bound-credential-review.md`, `exit=0`; sops-only and hashicorp-only → no output
- UNRUN by contract: scope-gate default / `--breadth` / `--falsify`; `verify` / `citations` / `cells` / `docs`

## Inventory
| file:line | phrase | class | claimed | live | source | STALE? |
|---|---|---|---|---|---|---|
| adjacency-scope.md:4-6 | "5 `# own` prefixes … 4 group rows … 4 `# owner` / 4 `# status` / 2 `# claim` / 8 `# no-enumerate` / 4 `# breadth`" | CURRENT | own 5, group 4, owner 4, status 4, claim 2, noenum 8, breadth 4 | same | L R16-04, R16-05, R16-06, R17-02; owner/status/claim U | NO |
| adjacency-scope.md:7 | "surface-census.tsv (35 rows, 4 `# scan`" | CURRENT | 35 rows, 4 scan | 35, 4 | L R11-11; scan U | NO |
| adjacency-scope.md:11-16 | "Current gates: ADJACENCY_SCOPE: CLEAN" partition subset: census 35, owned 27, shared 8, groups 4, owners 4, unresolved 1, contested 1, foreign 0, orphans 0, own_unlisted 0, breadth_pins 4, breadth_required 4 | CURRENT* | as listed | same (static; own_unlisted via census:30-31, scan:17-20) | HS R16-01 (static only) | NO (subset) |
| adjacency-scope.md:11-16 | same line, host subset: escapes 0, inbound 0, stale_basis 0, basis_escape 0, breadth_checked 4, breadth_ok 4, breadth_drift 0, breadth_unverified 0 | CURRENT* | as listed | UNRUN (host and sibling-lane reads) | HS R16-01 | UNRUN |
| adjacency-scope.md:16, 155 | `SCOPE_SELFTEST: PASS (61 cases)` | CURRENT | 61 | 61, exit 0 | L R16-02 | NO |
| adjacency-scope.md:17, 155, 269 | `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`; "runs 18 mutations" | CURRENT | 18/18 | 18 invocations, `total=18`; PASS not run | HS R16-03 | UNRUN |
| adjacency-scope.md:46 | census rows 35 | CURRENT | 35 | 35 | L R11-11 | NO |
| adjacency-scope.md:47-48 | owned by the 5 prefixes 27; shared 8 | CURRENT | 27 / 8 | 27 / 8 | U (static) | NO |
| adjacency-scope.md:49-52 | group rows 4; owner 4; status / claim 4 / 2; no-enumerate 8 | CURRENT | 4 / 4 / 4 / 2 / 8 | same | L R16-05, R16-06; rest U | NO |
| adjacency-scope.md:54-56 | "Prefix coverage is 5 / 1 / 1 / 17 / 3 … = 27"; "The two `bin` entries" | CURRENT | 27; 2 | 27; 2 (bin/the-janitor, bin/tac-check) | U (static) | NO |
| adjacency-scope.md:61-68 | group census counts 4 / 1 / 2 / 1; "8 = 4 + 1 + 2 + 1" | CURRENT | 4/1/2/1 = 8 | 4/1/2/1 = 8 (longest match) | U (static) | NO |
| adjacency-scope.md:82 | "`corpus/adjacency.tsv` — 7 columns" | CURRENT | 7 | 7 (NF on 4 group rows) | U | NO |
| adjacency-scope.md:100 | "the four derived leaf boundaries" | CURRENT | 4 | 4 (gate rule, scope-gate.sh:504-515) | U | NO |
| adjacency-scope.md:121, 247 | "`R11-11` pins 35" | CURRENT | 35 | 35 | L R11-11 | NO |
| adjacency-scope.md:147 | `BREADTH_AUDIT: CLEAN (required=4 pins=4 … children=182 declared=8 undeclared=174)` | CURRENT | 182 / 8 / 174 | pin sums 182 and 8 (static); live host counts UNRUN | HS R17-01 | UNRUN |
| claim-ledger.md:81 | "selftest case 16 pins it" (verdict-not-final) | CURRENT | case 16 = verdict-not-final | case 16 = policy-python-boundary-refused; verdict-not-final = case 27 | U (selftest ok-case index) | **YES** |
| claim-ledger.md:91-92 | "300 s for the gates, 120 s for drift"; `timeout -k 5` | CURRENT | 300 / 120 | column 300 (R11-01), 120 (R11-04); `timeout -k 5` at claim-ledger.sh:575 | HS R11-01, R11-04 (column only) | NO |
| claim-ledger.md:170, 435-436 | "all six axes exactly once"; "six-axis completeness rule" | CURRENT | 6 | 6 (claim-ledger.sh:862-865, `-eq 6`) | U | NO |
| claim-ledger.md:212-213 | "in one of two strict forms" | CURRENT | 2 | 2 (claim-ledger.sh:1001-1003; parser :1040-1097) | U | NO |
| claim-ledger.md:224, 394 | "By-hand classes (four, closed)"; "Four classes" | CURRENT | 4 | 4 (claim-ledger.sh:1006) | U | NO |
| claim-ledger.md:226, 394 | "reason must be ≥24 characters"; "≥24-char reason floor" | CURRENT | 24 | 24 (claim-ledger.sh:1081, `-ge 24`) | U | NO |
| claim-ledger.md:347-348 | "The allowlist (five commands)" | CURRENT | 5 | 6: bash, grep, sha256sum, wc, test, python3 (claim-ledger.sh:247) | U | **YES** |
| claim-ledger.md:377-379 | "four selftest cases cover the guard" (4 names listed) | CURRENT | 4 | 4 present (claim-ledger.sh:1526, 1527, 1530, 1533) | U | NO |
| claim-ledger.md:430, 446-447 | selftest `nested-audit-refused`; `stamps-dotdot-row` / `stamps-absolute-row` | CURRENT | 3 names | present (:1557, :1566, :1567) | U | NO |
| sops-age-key-rotation.md:68-70 | "kagi does not run SOPS today: grep (3-term -E) → no file, exit 1 (2026-10-19)" | CURRENT | no file, exit 1 | exit 0; 1 file (openbao term); sops-only: none | U (R21-02 checks citations only) | **YES** |
| adjacency-scope.md:56-57 | "`$HOME/.local/bin` holds 105 children … the other 103" | HISTORICAL (host read 2026-09-29; erratum :317) | 105 / 103 | host, not computed | — | n/a |
| adjacency-scope.md:134-139 | "Measured before the gate ran": 4/5/5/2 = 16 children; 20 (4 declared); 19 by ls; `~/.agents` 4 | HISTORICAL (pre-gate host read; erratum :317) | host | UNRUN | — | n/a |
| adjacency-scope.md:200-201 | critic CE-A1 `census=36 owned=27 shared=9`, CLEAN | HISTORICAL (critic experiment) | 36 / 27 / 9 | not a state | — | n/a |
| adjacency-scope.md:23-27 | "three prose places"; "a two-row overlap table" (pre-round-16 prose) | HISTORICAL (rounds 1–15) | 3 / 2 | n/a | — | n/a |
| adjacency-scope.md:249-304 | "## Reproduction (2026-09-29)"; "## Evidence" (groups 4/1/2/1; host 20, 105, 4) | HISTORICAL (section date; erratum :317) | as stated | selftest 61 ✓; 4/1/2/1 ✓; host UNRUN | — | n/a |
| claim-ledger.md:3-6 | "written 2026-09-28 (round 11) … 436 lines … 9 rows; 14; 17" | HISTORICAL (round 11, revision) | 436 / 9 | 1646 lines (sha 27e4e158…); 61 R-rows | — | n/a |
| claim-ledger.md:19, 23 | round-10 report 62 claims (49/9/4); two citations | HISTORICAL (round 10) | as stated | n/a | — | n/a |
| claim-ledger.md:62, 157, 173, 176, 180, 208, 235, 256, 268, 277, 288, 295, 339, 368, 399 | round-dated tables and incidents: orphans (r12), 12→11 and six cells (r13), 48 cells, 1/17 0/17 10/17 (4b8c018), 20/48 (r13), cites 268/374/517 (r11), PASS (39 cases) (r11), 18 rows (r12), nine/eight (r14); :288 "case 21" (r11 section; live 21 = stamp-stale) | HISTORICAL | as stated | n/a | — | n/a |
| claim-ledger.md:301-304 | "## Reproduction": `claims=17 stamped=33`, `cites=700 docs=43`, `cells=60 …`, `72 scratch cases → PASS (72 cases)` | HISTORICAL by erratum :474-476 (undated inline) | 72 | selftest 151; gate modes UNRUN | — | n/a |
| sops-age-key-rotation.md:4 | "verified-at 2026-10-19 (the three rendered pages … read in full)" | HISTORICAL (dated event) | 3 | 3 source ids on :3 (S009–S011) | — | n/a |
| credential-isolation.md:5, 18, 31, 44 | "All read 2026-09-28"; 20 vars; 759 bytes; 14 lines | HISTORICAL (host; **no erratum**) | host | UNRUN | — | n/a |
| handler-on-disk-state.md; janitor-env-contract.md; op-cli-surface.md; tac-evidence-integrity.md (bodies) | host counts: 333 lines, 84 log lines, 7/39/55/238 rows, 20 vars, 10 keys, op 2.35.0, 88 lines, 9-line block | HISTORICAL (erratum :250-288, :92-122, :119-129, :82-92) | host | UNRUN | — | n/a |

Summary: CURRENT 25 rows = 19 live-match, 3 UNRUN, 3 STALE. **CURRENT stale claims: 3** (claim-ledger.md:81; claim-ledger.md:347-348; sops-age-key-rotation.md:68-70).

## Findings
1. Binding is the gap. All 3 stale CURRENT claims are U. Of 25 CURRENT rows: 14 wholly U, 5 HS-only, 4 L-only, 2 mixed. Ledger rows replay only count rows; prose counts (sops grep, allowlist, case index, class and name counts) have no row.
2. Population-rule counterexamples: (a) claim-ledger.md:301-304 is undated inline; only the erratum at :474-476 qualifies it. An inline-date rule marks it CURRENT → STALE (72 vs 151). (b) The header "written 2026-09-28 (round 11)" does not make the body historical; the erratum scopes to the reproduction block, so :347-348 stays CURRENT. (c) adjacency-scope.md:11 says "Current gates"; :317-318 says the CLEAN output "describe[s] the recorded 2026-09-29 observation, not this host now". Both cannot hold.
3. Freshness hole: credential-isolation.md has no erratum though its four siblings do (handler :250, janitor-env :92, op :119, tac :82). Its source is ENOENT on 2026-10-15 (handler-on-disk-state.md:261).
4. Drift by a sibling, not an edit: feature-bound-credential-review.md (verified-at 2026-10-20; openbao.org URL at line 1) flipped the sops literal. The sops-only sub-claim still holds; erratum :99 reads the claim that way.
5. Operability: the sops recipe's `|` alternation is refused by the ledger metachar policy (claim-ledger.sh:250 META_RE), so it cannot be a row as written [read from source; not run]. Use one `-e` per term.
6. Index claims drift: verdict-not-final moved from case 16 to 27. Bind by case name. Also: a naive breadth-leaf derivation gives 5 (ignores `# scan` descendants of .local/state); the gate's rule gives 4. Reuse the gate's rule.
7. Host-bound: R16-01, R16-03, R17-01, R11-01, R11-04 carry [substrate] and HOST-SKIP by default. C1 can bind only the static parts (total=18; pin sums) without DEFER.
8. Not mine: real-lane porcelain went from 2 to 3 untracked entries during this run (`corpus/__pycache__/` appeared). Integrator to check.
