# ConnOverlap — two sibling-overlap sweeps (round 31, BUILD wave `kagi-r31-build`)

Seat: `ConnOverlap` (connector, leaf member — no subagent dispatch).
Scope: **read-only** sweep of `/home/vgpnk/Projects/shokunin/*-shokunin/` siblings + report only.
Lane: `kagi-shokunin`. Frozen BASE `655e620651808ac04bb59bfa35b81227f62a031b`; plan `4767b045773607fc8ab4cb7ba2fea386e05b53c0`.
No lane production file was modified. No git/jj mutation in any lane (read-only `rev-parse` / `status` / `log` / `show` only). No credential reads, no `op` contact at any level, no install, no pacman transaction.

Sibling set swept (20 lanes): audio, chousa, game-dev-2d, game-dev-3d, kaidoku, kake, kama, kasegi, kengaku, kotoba, kotodama, kumitate, lore, mado, mori, revenger, souji, tabi, tameshi, tsukuroi.
Sibling tips at sweep time (2026-11-03T20:06:53Z) are recorded in the receipt §5; three lanes (kengaku, souji, tabi) committed between the first and second tip read — their counts were re-read at the new tips and are unchanged.

**Verdict in one line: sweep 1 = NO-OVERLAP (no sibling claims either adopted ground, and no sibling cites any of the 11 staged URLs, at tips or anywhere in history); sweep 2 = the `## Round <N> — pre-move|post-move` shape is a kagi-local convention no sibling enforces — 1 050 sibling round headings do not continue with `pre-move`/`post-move` (1 019 of them would kill a kagi-style cells gate), but **zero** siblings run a cells-equivalent gate, so none of those headings is a sibling defect.**

Two supporting observations the L1 needs (both measured, both inside the plan's own claims):
- **C1's five-heading scope is exactly right and sufficient** — a faithful re-implementation of the lane's own parser dies at BASE on `SCORECARD.md:1018` and, after the five plan-proposed reshapes, parses to completion: **35 sections, 210 axis cells, 0 section defects**. The lane's two other round-looking headings (`:458`, `:663`) are *inert* to the gate and must not be swept into the reshape.
- **C2's fleet-census warning count moves 14 → 16.** Two of the 11 staged rows (staged `S092`, `S093`) carry URLs the lane already holds under different scopes; each adds one `W04 duplicate-url across scopes` line. `W04` is a warning (fleet census still exits 0), but the L1 should expect **16**, not 14, in the round-31 after-receipt — a 14-vs-16 mismatch would read as an unexplained regression.

---

## 1. Sweep 1 — workload-identity ground (does any sibling claim the adopted ground?)

**Verdict: NO-OVERLAP.** The three questions asked, answered one at a time:

| adopted ground | sibling claim found? | evidence |
|---|---|---|
| OIDC workload-federation **trust policy** (issuer / audience / identity-claim binding → permissions) | **no** | 0 sibling registry rows, 0 sibling knowledge entries; the only `Workload Identity Federation` strings in the fleet are page-navigation chrome (§2) |
| 1Password Credential Broker **custom-OIDC workflow** (issuer URL, conjunctive claim matching, expected audience, integration key, runtime triple) | **no** | 0 sibling rows for `1password.dev/brokered-access*`; the sibling `1Password` hits are all Electron/asar reverse-engineering of the desktop app, a different surface (§2) |
| **cloud-provider federation condition semantics** (AWS STS `AssumeRoleWithWebIdentity`, GCP IAM attribute conditions, Alibaba RAM `oidc:iss/aud/sub`) | **no** | 0 sibling rows for any of the six provider URLs; the sibling Alibaba Cloud rows are LLM-serving / NAS-quota rows, and the sibling `AssumeRoleWithWebIdentity` strings are omp binary strings (§2) |

Round-21 and round-30 sweeps found none; this round **re-confirms** both, one round later, at the current tips.

### 2. Sweep 1 — near misses, each classified (all false positives, none a claim)

`path:line` per hit. Every line below was read in context.

| # | sibling | path:line | what the text is | why it is not a claim of the adopted ground |
|---|---|---|---|---|
| 1 | kaidoku | `PROVINCE.md:49`, `PROVINCE.md:160` | 1Password's 40.7 MB Electron `app.asar` + 188 MB Rust N-API core, enumerated as a reverse-engineering corpus surface | desktop-app **binary** surface; no OIDC, issuer, audience or broker workflow anywhere in the row |
| 2 | kaidoku | `corpus/README.md:23`, `:123`, `:151`, `:179`; `corpus/knowledge/2026-10-13-asar-surface.md:8`, `:36`, `:42-45` | the same asar evidence, filed as knowledge | same |
| 3 | kasegi | `corpus/source-snapshots/round-35/S052.txt:2035` | the word "OIDC" inside a CISA KEV CVE description (SimpleHelp OIDC auth-bypass) | captured third-party text about a *vulnerability*; kasegi's row `S052` (`corpus/SOURCES.md:58`) is scoped to the KEV catalog, not OIDC semantics |
| 4 | kasegi | `corpus/source-snapshots/round-55/S087.txt:56` | the word "OIDC" as one item of a GitHub Docs navigation sidebar | nav chrome in a captured page; kasegi's row `S087` (`corpus/SOURCES.md:94`) is the repository-advisories REST reference |
| 5 | mori | `corpus/evidence/recheck-r32/S049.src:4481`; `corpus/evidence/sources-r37/S222.src:4432` | the phrase "Workload Identity Federation" as a link label in the OWASP cheat-sheet site chrome | nav chrome of the OWASP cheat-sheet index; mori's `S049`/`S222` rows (`corpus/SOURCES.md:55`, `:228`) are the OWASP Logging and SSRF cheat sheets |
| 6 | kama | `.ufo/waves/round-39/assimilation/openai-list.html` (1 occurrence) | OpenAI API reference sidebar link `/api/reference/workload-identity-federation` | nav chrome in a captured OpenAI page; no kama registry row, no knowledge entry |
| 7 | kotoba | `.ufo/round-44/evidence/omp-live-18.12.2-strings.txt:591683`, `:591685`, `:666225`; `.ufo/waves/round-82/build/Kb82E12Loader-omp-18.14.0-strings.txt:688243` | `AssumeRoleWithWebIdentity` **strings inside the omp binary** | a tool binary's string table, not a source claim; kotoba has no registry row and no knowledge entry on it |
| 8 | kake | `.ufo/waves/round-35/sources/S083.txt` (4 occurrences of `openid.net`) | the IANA well-known-URIs registry listing `openid-configuration` / `openid-sharedsignals-framework` suffixes | kake's row `S083` (`corpus/SOURCES.md:91`) is scoped to well-known URI suffixes, not federation trust |
| 9 | tameshi | `.ufo/evidence/round-30/sources/S059-bazel-remote-caching.md:151` | a `cloud.google.com/iam/docs/creating-managing-service-accounts` link inside a Bazel doc capture | service-account **docs link** in an unrelated capture; tameshi's `S059`/`S092` rows (`corpus/SOURCES.md:68`, `:101`) are Bazel remote caching |
| 10 | kake | `corpus/lessons/round-1-aggregator-audit.md:76` | names `kagi-shokunin/corpus/knowledge/cdp-bridge-1password.md` as the contested CDP-9222/profile-lease surface | a **deferral to kagi** ("One owner must be ruled on by the integrator"), not a kake claim |
| 11 | tabi | `corpus/adjacency-screen-browser.tsv:28-42` (10 pinned rows) | tabi's screen **pins kagi's** `cdp-bridge-1password.md` lines as kagi's hold | tabi screening kagi's ground, not claiming it; the pins are `<lane>@<40-hex>:<path>:<line>` (frozen commits), so a new kagi knowledge file cannot break them |
| 12 | kama | `corpus/lessons/round-1-safety.md:86` | "L0 must explicitly name the credential broker, header policy, redaction policy…" | a safety **boundary** for L0 approval; no mechanism, no registry row, no knowledge entry |
| 13 | kama | `corpus/SOURCES.md:209` (`S206`), `:210` (`S209`) | Alibaba Cloud PAI-EAS / ACK **LLM-serving** deployment guides | Chinese-cloud *serving* contract, not Alibaba RAM trusted-IdP federation |
| 14 | kumitate | `corpus/SOURCES.md:141` (`S131`), `:148` (`S196`) | Alibaba Cloud Bailian **Managed Agents** runtime | agent-runtime contract, not RAM OIDC trust |
| 15 | mori | `corpus/SOURCES.md:261` (`S482`) | Alibaba **NAS** directory quotas | storage quota, not RAM |
| 16 | kotoba / mado | `kotoba-shokunin/.ufo/waves/round-71/receipts/census-after.txt:73`, `:80`; `mado-shokunin/.ufo/waves/round-44/w2/RerunCensus/census-fleet.txt:77`, `:84` | fleet-census receipt lines echoing **kagi's own** `W04` warnings for `www.1password.dev/brokered-access` | a copy of kagi's registry state inside a sibling's census receipt; not a sibling row |

**Registry-level proof (tip level).** Grepping every sibling `corpus/SOURCES.md` for the six provider URLs, the two 1Password URLs, `openid.net`, `rfc9700` → **0 hits in all 20 siblings**.

**History-level proof.** `git -C <lane> log --all --oneline -S'<needle>'` for five needles × 20 lanes (336 s wall) returned hits in only three lanes, all already classified above:

| lane | needle | commits | where |
|---|---|---|---|
| kama | `workload-identity-federation` | 579 | one file only: `.ufo/waves/round-39/assimilation/openai-list.html` (OpenAI nav chrome, row 6) |
| kotoba | `AssumeRoleWithWebIdentity` | 3 | omp binary strings dumps (row 7) |
| kotoba | `brokered-access` | 2 | `.ufo/waves/round-71/receipts/census-after.txt` — kagi's own row echoed (row 16) |
| mado | `brokered-access` | 4 | `.ufo/waves/round-44/w2/RerunCensus/census-fleet.txt` — same echo (row 16) |

No sibling has ever cited the AWS create-OIDC guide, the AWS IAM condition-key reference, the AWS STS `AssumeRoleWithWebIdentity` API page, the GCP WIF best-practices page, the GCP WIF ja page, the Alibaba RAM trusted-IdP guide, `openid.net/specs/openid-connect-core-1_0.html`, `rfc9700`, `1password.dev/brokered-access`, `1password.dev/brokered-access/custom-workflow`, or `1password.com/jp/product/credential-broker` — at any commit.

### 3. Sweep 1 — the one cross-lane risk C2 does carry (measured, not speculative)

The fleet census (`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh`) applies `W04` when the same URL appears under a different scope, and `E04` when the same URL appears under the *same* scope without a `supersedes Sxxx` marker. Two of the eleven staged rows land on URLs the lane already holds:

| staged row | staged URL | lane rows already holding that URL (normalized) | lane scope(s) | effect |
|---|---|---|---|---|
| staged `S092` | `https://www.1password.dev/brokered-access` | `S007`, `S019`, `S032` | distinct from the staged scope ("administrator-side **setup steps** … issuer URL, conjunctive claim matching, expected audience") | **one new `W04`** |
| staged `S093` | `https://www.1password.dev/brokered-access/custom-workflow` | `S018` | distinct ("runtime side … OIDC token, workload ID, integration key") | **one new `W04`** |
| staged `S095` | `https://1password.com/jp/product/credential-broker` | — (lane `S005` is the non-`/jp/` URL) | — | none |

Simulation of the census's own `url_of` normalization (trailing `/` stripped, host lower-cased, fragment stripped) over the lane's 60 live rows gives **W04 = 14** — which reproduces the committed START receipt `.ufo/waves/round-31/census-start.txt` exactly (14 `W04` lines, exit 0), so the simulation is faithful. Appending the 11 staged rows raises it to **W04 = 16, E04 = 0**.

Consequences the L1 should act on:
1. The round-31 after-receipt will carry **16** `W04` lines, not 14. `W04` is a warning and the fleet census still exits 0 (its header, `scripts/sources-census.sh:16`, says "0 clean or warnings"), so the plan's exit-0 requirement is unaffected — but the count change must be recorded, or a reviewer will read 16-vs-14 as an unexplained drift.
2. No `E04` is at risk, **provided** the two new rows' scope cells stay textually distinct from `S007`/`S019`/`S032`/`S018` scopes, or carry a `supersedes Sxxx` marker. The staged scope texts are already distinct.
3. The lane's own gate `corpus/sources-census.sh` has **no** URL-duplicate rule at all (`SC_DUP` is a duplicate-*id* rule; `grep -c 'duplicate url' corpus/sources-census.sh` = 0), so C2's own predicate `bash corpus/sources-census.sh` is unaffected by this. Only the fleet-level count moves.

---

## 4. Sweep 2 — the scorecard heading-shape class, cross-lane

**Verdict: the shape class is kagi-local; no sibling runs an equivalent gate; the 1 050 non-conformant sibling headings are a cross-lane *observation*, not 1 050 defects.** No sibling file was edited.

### 4.1 Which siblings run a cells-equivalent gate? — **none.**

| check | result |
|---|---|
| `ls */corpus/claim-ledger.*` | **only** `kagi-shokunin/corpus/claim-ledger.sh` / `.tsv` — the gate is kagi's alone |
| `grep -rIl 'CELL_AUDIT\|unrecognised round heading' */corpus/*.sh */corpus/*.py */scripts/*` | **0 hits in every sibling** (the only fleet hits are kagi's own, plus copies of kagi's `corpus/lessons/round-14.md` prose inside kumitate's own wave scratch) |
| sibling gates that *do* read a SCORECARD.md — kake `scripts/citation_lint.py`, `scripts/ledger_latest_check.py`, `scripts/source_recheck.py`, `scripts/robots_audit.py`; kumitate `scripts/claims-check.mjs`, `scripts/cite-check.mjs`, `scripts/counter-pins.mjs`, `scripts/round-gate.mjs`, `scripts/readme-map.mjs`, `scripts/kimi-census.mjs`; revenger `corpus/self_assessment_check.py`; tabi `scripts/check-cited-receipts.mjs`, `check-cited-receipts-v2.mjs`, `check-freshness.mjs`, `check-round-contract.mjs`, `check-user-round-contract.mjs`, `check-selfassessment.mjs` | **0 occurrences** of `pre-move` / `post-move` in any of them; each uses a **lane-local** convention instead: tabi `scripts/check-selfassessment.mjs:478` matches its own `## Round N — executed disposition`; revenger `corpus/self_assessment_check.py:146` anchors on the literal `## Round 61`; kumitate `scripts/claims-check.mjs:257`/`:496` parse a registry table, not round headings |

So the kagi cells gate is the **only** implementation of the `## Round <N> — pre-move|post-move` shape in the fleet, and the only lane where a non-conformant heading is a *defect*.

### 4.2 Per-lane classification table (the cross-lane observation)

Classification uses the lane's own regexes verbatim (`kagi-shokunin/corpus/claim-ledger.sh:940-944`):
`SEC_RE` = conformant · `ROUND_RE` matches but neither `SEC_RE` nor `BLOCKED_ATTEMPT_RE` → **would kill a kagi-style cells gate** · `BLOCKED_ATTEMPT_RE` → filed exemption · a `## Round…` heading that matches **neither** (`## Round-1`, `## Round27` — glued forms) → **inert** to the gate.

| lane | tip (12) | H2 sections | SEC_CONFORM | would-die | blocked-exempt | inert-glued | runs cells-equiv gate | literal `^## Round` not continuing `pre-move`/`post-move` |
|---|---|---|---|---|---|---|---|---|
| audio | `f9da7ee97e0b` | 107 | 0 | 101 | 0 | 0 | no | 101 |
| chousa | `f748abbb6bf5` | 168 | 0 | 75 | 0 | 7 | no | 82 |
| game-dev-2d | `1e033ef053be` | 36 | 0 | 33 | 0 | 0 | no | 33 |
| game-dev-3d | `39ca3973c786` | 41 | 0 | 36 | 0 | 0 | no | 36 |
| kaidoku | `c7fe6898e9a8` | 97 | 0 | 51 | 0 | 0 | no | 51 |
| kake | `d76ae92656bc` | 103 | 0 | 92 | 0 | 3 | no | 95 |
| kama | `6035e952c252` | 88 | 0 | 73 | 0 | 1 | no | 74 |
| kasegi | `cd3029876eac` | 58 | 0 | 42 | 0 | 7 | no | 49 |
| **kengaku** | `b5032ff8391d` | 70 | **4** | 49 | 0 | 1 | no | 50 |
| kotoba | `1c8f37edf2e5` | 6 | 0 | 0 | 0 | 0 | no | 0 |
| kotodama | `c285b2afb19d` | 82 | 0 | 3 | 0 | 0 | no | 3 |
| kumitate | `3c3693362183` | 52 | 0 | 43 | 0 | 0 | no | 43 |
| lore | `0f044aa7c7e4` | 25 | 0 | 20 | 0 | 0 | no | 20 |
| mado | `524fa1f90b1f` | 74 | 0 | 66 | 0 | 0 | no | 66 |
| mori | `84c6cbc3b47c` | 94 | 0 | 79 | 0 | 4 | no | 83 |
| revenger | `5915ad8d71c1` | 38 | 0 | 29 | 0 | 0 | no | 29 |
| souji | `a1156d857984` | 6 | 0 | 0 | 0 | 0 | no | 0 |
| tabi | `484bde505dc5` | 89 | 0 | 75 | 0 | 1 | no | 76 |
| tameshi | `f20ba482c744` | 89 | 0 | 61 | 0 | 3 | no | 64 |
| tsukuroi | `37c74e27b29d` | 161 | 0 | 91 | 0 | 4 | no | 95 |
| **TOTAL (20 siblings)** | | | **4** | **1 019** | **0** | **31** | **0 of 20** | **1 050** |
| *kagi (own lane — reference only, not a sibling)* | `655e62065180` | 52 | 30 | **5** | 1 | 2 | yes | 5 |

Per-finding `file:line` for all 1 050 non-conformant sibling headings:
**`.ufo/waves/round-31/build/ConnOverlap-headings-nonconformant.txt`** (one line per finding, `path:line:heading`).
The table above, with the regexes it was produced with, is at **`.ufo/waves/round-31/build/ConnOverlap-headings-table.txt`**.

### 4.3 The one conformant sibling — and why it does not generalise

`kengaku-shokunin/SCORECARD.md:56` `## Round 9 — pre-move (measured against \`HEAD\` \`f147a27\` "round-7")`, `:68` `## Round 9 — post-move (calibration axis-move landed)`, `:128` `## Round 10 — post-move (operability axis-move landed)`, `:140` `## Round 11 — post-move (novelty axis-move landed)`.
Introduced by `2575be67 "round-9"` (the lane's only commit ever touching `— pre-move` in its SCORECARD — `git log --all -S'— pre-move' -- SCORECARD.md` → 1 commit, in **kengaku alone** across all 20 siblings). kengaku never ran a cells-equivalent gate (`git log --all --diff-filter=A --name-only | grep -i 'claim-ledger\|cells'` → no kengaku hit for a `claim-ledger`/`cells` gate) and drifted back to its own heading convention; 49 of its round headings still would-die a kagi-style gate.

**Calibration conclusion for the integrator:** the five-heading reshape C1 performs is a **kagi-local** repair. It is not a fleet-wide convention, no sibling is out of compliance with anything, and no sibling needs a change. The reshape therefore creates **no cross-lane obligation** — and conversely, kagi's shape cannot be corroborated by any sibling gate, because there is no second implementation to corroborate it.

---

## 5. Two supporting measurements the L1 asked for by implication

### 5.1 C1's five-heading scope is exactly the die-set, and the reshape is sufficient

A faithful re-implementation of `claim-ledger.sh` `cells()`'s heading/section logic (`corpus/claim-ledger.sh:940-1003`; `AXES_RE`, `SEC_RE`, `SECTION_RE`, `ROUND_RE`, `BLOCKED_ATTEMPT_RE`, `section_check` all copied verbatim) was run over the lane's own `SCORECARD.md` at BASE, and over the same bytes with the five plan-proposed headings substituted:

| run | result |
|---|---|
| BASE bytes | **exit 2**, `die@line=1018: unrecognised round heading in SCORECARD.md: '## Round 26 — bounded release-drift response' (expected '## Round <N> — pre-move|post-move')` — matches the plan's committed control `controls/cells-base.txt` |
| five plan reshapes applied | **exit 0**, `OK sections=35 cells=210`, and **0** section defects (every one of the 35 recognised sections carries all six axes exactly once) |

Two consequences: (a) C1's predicate `cells ≥ 210` is met with the count landing exactly on **210** (= 35 sections × 6 axes); (b) the reshape is *sufficient* — no sixth heading is needed.

### 5.2 Two lane headings that must NOT be swept into the reshape

`kagi-shokunin/SCORECARD.md:458` `## Round-19 correction (appended 2026-10-14) — the describe-don't-pin claim was too strong` and `:663` `## Round-21 correction (post-landing review of \`c41af82\`)`. Both are **glued** forms: `ROUND_RE` requires `Round` followed by a blank or end-of-line, so `Round-19` / `Round-21` do not match it. They are parsed as ordinary (non-round) H2 sections, never as round sections — **inert** to the gate, and changing them would be an unnecessary edit to a filed correction record. The lane's one filed exemption, `SCORECARD.md:558` `## Round 20 — interactive attempt; blocked, not completed (2026-10-15)`, matches `BLOCKED_ATTEMPT_RE` and is likewise excluded from the die-set.

---

## 6. Method — every command run, with its result

All commands were run from `/home/vgpnk/Projects/shokunin` (fleet root) with absolute paths; every command was read-only.

| # | command | result |
|---|---|---|
| 1 | `ls -1d /home/vgpnk/Projects/shokunin/*-shokunin/` | 20 sibling lanes + kagi; no other lane-shaped tree at the fleet root |
| 2 | `git -C <lane> rev-parse HEAD` (20 lanes, twice — tips moved for kengaku/souji/tabi mid-sweep) | tips in §4.2; the three moved lanes re-read and re-counted at the new tips, counts unchanged |
| 3 | `git -C <lane> status --porcelain -- PROVINCE.md SKILL.md SCORECARD.md corpus/SOURCES.md corpus/README.md corpus/knowledge` | dirty for 4 lanes only: kasegi (`SCORECARD.md`, `corpus/knowledge/iso-29147-30111-standard-records.md`), kengaku (`corpus/SOURCES.md`), souji (`corpus/SOURCES.md` + 1 untracked knowledge file), tsukuroi (1 untracked knowledge file); the diffs of the three dirty `SCORECARD.md`/`SOURCES.md` files contain **no** OIDC/federation/broker text and **no** `## Round` heading change that alters the counts |
| 4 | `grep -rInI -iE '\boidc\b\|workload[- .]identity\|workload[- .]federation\|AssumeRoleWithWebIdentity\|credential[- .]*broker\|brokered[- .]*access\|trusted[- .]*idp\|openid\.net\|rfc9700'` over each sibling's `PROVINCE.md`, `SKILL.md`, `corpus/` | hits only in the lanes tabulated in §2; every one classified there |
| 5 | `grep -rInI -E 'sts\.amazonaws\|AssumeRole\|iam\.googleapis\|ram/user-guide\|oidc:iss\|oidc:aud\|oidc:sub\|workload-identity-pool\|provider:sub\|token\.actions\.githubusercontent\.com:aud'` over the same surfaces | **0 sibling hits** (the two `oidc:`-adjacent rows found are kasegi's GitHub-Actions docs nav string and its HackerOne-1Password path, neither a claim) |
| 6 | `grep -rInI --exclude-dir=.git --exclude-dir=.jj -E '1password\.dev\|openid\.net\|docs\.aws\.amazon\.com/STS\|id_roles_providers_create_oidc\|iam-condition-keys\|best-practices-for-using-workload-identity\|create-a-ram-role-for-a-trusted-idp\|rfc9700\|cloud\.google\.com/iam\|docs\.cloud\.google\.com/iam'` over each sibling's **whole tree** | hits only in the §2 rows (kake's S083 well-known-URIs capture; kotoba/mado's census receipts echoing kagi's own W04 lines; tameshi's Bazel capture) — **0 sibling registry or knowledge hits** |
| 7 | `git -C <lane> log --all --oneline -S'<needle>'` × 5 needles × 20 lanes (336 s wall) | hits only in kama (1 file, nav chrome), kotoba (binary strings + a census-receipt echo), mado (census-receipt echo) — see §2 history table; **no sibling ever cited any of the 11 staged URLs** |
| 8 | `git -C <lane> log --all --oneline -S'— pre-move' -- SCORECARD.md` × 20 lanes | **1 commit, in kengaku alone** (`2575be67 "round-9"`) |
| 9 | `ls */corpus/claim-ledger.*`; `grep -rIl 'CELL_AUDIT\|unrecognised round heading' */corpus/*.sh */corpus/*.py */scripts/*` | the cells gate is **kagi's alone**; 0 sibling implementations |
| 10 | heading classification by the lane's own regexes (`claim-ledger.sh:940-944`), applied to all 21 `SCORECARD.md` files | §4.2 table; 1 050 sibling non-conformant `^## Round` headings, 1 019 of them would-die |
| 11 | faithful re-implementation of `cells()`'s heading/section logic over kagi's own `SCORECARD.md`, BASE and five-reshape-applied | §5.1: exit 2 @ line 1018 at BASE; exit 0 / 35 sections / 210 cells / 0 section defects after the reshape |
| 12 | simulation of the fleet census's `url_of` + `W04`/`E04` rules over the lane's 60 rows, then over the 60 + 11 staged rows | W04 14 → 16, E04 0 → 0; the BASE value 14 reproduces `census-start.txt` exactly |
| 13 | `bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (read-only) | exit 0, 14 `W04` lines, `kagi ok …` — the committed START census re-measured, unchanged |

## 7. Not checked / limits of this seat

- The claim is about **committed** sibling surfaces at the tips in §4.2. Sibling **wave-internal** artifacts (`.ufo/waves/**`) were read only where they name the adopted mechanism on the record (kama, kotoba, mado, kake, tameshi). A sibling's untracked scratch could contain anything; that is not a *claim*.
- No sibling's `corpus/source-snapshots/**` captures were opened beyond the four that a keyword hit pointed at (kasegi's two, mori's two, kake's S083) — each was read in context and each is captured third-party text, not a lane claim. A capture could contain a provider page the lane's row does not teach; that would still not be a *claim*.
- **No network fetch was performed** by this seat (the only permitted fetch form is the declared `curl -fsSL --max-time 30` re-open, which this seat does not own). Every statement above is about committed bytes.
- The `W04`/`E04` prediction in §3 is a **simulation of the census's own rules** (re-implemented from `scripts/sources-census.sh:600-650` and validated against the committed 14-warning START receipt), not a run of the post-adoption census. The L1's own after-census is the authority on the final number.
- The `cells ≥ 210` figure in §5.1 is from the **re-implementation** of the heading/section/cell-counting half of `cells()`, not from the gate's own `CELL_AUDIT` line: the real gate also audits rows, stamps and ids, which this seat did not re-implement. The direction and the five-heading scope are solid; the exact audit line remains the L1's to run.
- Four lanes had uncommitted changes at sweep time (§6 row 3). Their committed state was swept; their dirty bytes were inspected for relevance, not adjudicated.

## 8. Tooling

No installation was performed or needed; no pacman transaction was attempted (host-wide pacman is paused). Tools used, all pre-existing: `grep`/`sed`/`awk`/`git` 2.56.0, `bash` 5.3.20(1), `python3` 3.14.8, `ls`/`find`/`wc`/`sort`/`uniq`/`date`. `op` was **not** invoked at any level (not even `--version`). No credential was read; no secret material appears in this report or its receipts — every citation is a mechanism, a path, or a public URL.

**Scratch**: `/fast/scratch/hyaku/kagi-r31/ConnOverlap/` (created for this seat; held only the two classification scripts and two intermediate text tables, all copied into the wave dir as receipts). **The scratch directory was deleted before this report was yielded.**
