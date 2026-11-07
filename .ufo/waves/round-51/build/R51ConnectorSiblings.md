# R51ConnectorSiblings — sibling-overlap scan, kagi round 51 wave 1

Seat: R51ConnectorSiblings (connector, leaf — no subagent dispatch). Read-only scan:
no fixture, no clone, no install, no lane-repo write anywhere. The only files this seat
wrote are `build/R51ConnectorSiblings.md` (this report) and
`build/R51ConnectorSiblings/grep-receipts.txt` (the invocation record).

Lane analysed read-only: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`,
HEAD `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567` (predeclaration), ticket BASE
`214d8bf530a0c87c00686493f21af15396284793`. The candidate trial is uncommitted in the
working tree (`corpus/openbao-wrap-trial.sh` is `??`, per `git status --porcelain`); it was
read as data only.

## Axes

- **Adjacency** — this seat's judged axis.
- **Capability (C1) / calibration (C2)** — the round's axes; touched only where a sibling's
  *measured* record changes a risk statement about the frozen counters. Nothing here edits,
  narrows or re-scores a frozen predicate.

## Terms and the exact searches

Every search was executed with the harness `grep` tool (case-insensitive unless noted).
The replayable form is `grep -rnE '<pattern>' <paths>`; the tool's own invocations are
recorded verbatim in `build/R51ConnectorSiblings/grep-receipts.txt`.

| # | Term | Pattern | Path set | Result |
|---|---|---|---|---|
| 1 | response wrapping / sys/wrapping / wrapping token / cubbyhole | `response[- ]wrapping\|sys/wrapping\|wrapping token\|cubbyhole\|wrap[_-]?token` (+ the same run joined with the vault and claims alternatives) | 20 sibling `corpus/` dirs (243,596 files) | **1 matching file, 1 line — a false positive**: `kotoba-shokunin/corpus/knowledge/checklist-execution-round16.md:163` (`unwrap_tokens` contains `wrap_token`) |
| 2 | same four wrapping terms | as row 1 | 38 explicit sibling `SKILL.md`/`PROVINCE.md` | **no matches** |
| 3 | same four wrapping terms + openbao | `response[- ]wrapping\|sys/wrapping\|wrapping token\|cubbyhole\|wrap[_-]?token\|openbao\|OpenBao\|\bbao\b\|Vault server\|vault server\|claims-declared` | `/home/vgpnk/Projects/shokuknow/merge/kagi/` (read-only; nothing executed there) | **no matches** |
| 4 | same terms + `OpenBao\|HashiCorp Vault` | as row 3 | `kimi-shokunin/{skills,commands,README.md,templates}` | **no matches** (kimi-shokunin ships no `corpus/`, `SKILL.md` or `PROVINCE.md`) |
| 5 | OpenBao/Vault dev-server trial | `bao server\|vault server\|server -dev` | 20 sibling `corpus/` dirs | **no matches** |
| 6 | vault client env / dev-root token | `BAO_ADDR\|VAULT_ADDR\|VAULT_TOKEN\|dev-root-token-id\|-dev-root-token\|\bbao\b\|openbao` | 20 sibling `corpus/` dirs | 3 files, **all `Bao` surname false positives** (`chousa …/captures/4132ec1b265e60624523251f.txt:629`, `…/78761b633aee2289e5874ce9.txt:2100`, `kasegi …/source-snapshots/round-75/S110.txt:1437`) |
| 7 | OpenBao/Vault/HashiCorp mentions | `\bOpenBao\b\|\bopenbao\b\|\bVault\b (server\|dev\|token\|policy)\|vault (server\|dev)\|\bHashiCorp\b` | 20 sibling `corpus/` dirs | 3 files, mentions only (hits rows 34–36 below) |
| 8 | a declared-claim manifest gate | `claims-declared\|claims_declared\|declared[-_]claim\|claims\.tsv` | 20 sibling `corpus/` dirs | **no literal hit** (only row 1's false positive under the wider pattern) |
| 9 | the same as a file | glob `*/claims-declared*`, `*/corpus/claims-declared*`, `*/scripts/claims-declared*`, `kimi-shokunin/**/claims-declared*` | sibling lane roots | **no files found** |
| 10 | the family, semantically | `claims file\|claims\.tsv\|claim table\|declared table\|manifest gate\|declared-claim\|declared claim` | 14 lane `corpus/` dirs | 413 files (first page inspected); adjacent implementations at rows 15–17, the rest is frozen-claims prose |
| 11 | shim / falsifier PATH-blindness | `PATH[- ]blind\|path[- ]blindness\|PATH shim\|shim (dir\|PATH)\|PATH=.*shim\|falsifier` | 16 lane `corpus/` dirs | 397 files (first page inspected); the PATH-blindness technique itself is chousa's (rows 18–25) |
| 12 | absolute-path pinning | `PATH-resolved\|PATH resolution\|pinned absolute\|absolute-path pin\|provenance pin` | 15 lane `corpus/` dirs | 66 files; substantive technique rows in chousa (rows 21–25) |
| 13 | owner declarations naming kagi | `\bkagi\b` | 38 explicit sibling `SKILL.md`/`PROVINCE.md` | 586 match lines (tool counter, first 567 shown); the 30-file count belongs to the wider `kagi\|secret\|vault\|credential` run. The routing declarations are hits rows 1–14 and 26–33 |

Nothing in rows 1–4 and 8–9 found the search term: **no sibling lane holds response
wrapping, `sys/wrapping`, a wrapping token, cubbyhole storage, an OpenBao/Vault dev
trial, or a file named after kagi's `claims-declared` gate.** The adjacent families are
(a) declared-claim gates in kasegi and chousa, and (b) the PATH-shim falsification
technique in chousa.

## Coverage

| lane | corpus files | SKILL.md / PROVINCE.md |
|---|---|---|
| audio | 49,569 | PROVINCE.md 6,352 B (no SKILL.md) |
| chousa | 2,264 | 192,185 / 880 B |
| game-dev-2d | 54,480 | PROVINCE.md 2,172 B (no SKILL.md) |
| game-dev-3d | 121,039 | 25,541 / 7,467 B |
| kaidoku | 4,021 | 498,344 / 99,769 B |
| kake | 280 | 281,481 / 53,541 B |
| kama | 243 | 312,184 / 44,022 B |
| kasegi | 677 | 156,153 / 38,869 B |
| kengaku | 1,951 | 374,256 / 110,494 B |
| kotoba | 207 | 92,672 / 25,070 B |
| kotodama | 559 | 150,085 / 1,636 B |
| kumitate | 247 | 120,446 / 12,753 B |
| lore | 1,859 | 20,349 / 4,029 B |
| mado | 270 | 312,025 / 71,981 B |
| mori | 661 | 248,983 / 66,513 B |
| revenger | 724 | 120,861 / 3,789 B |
| souji | 190 | 188,494 / 21,658 B |
| tabi | 3,829 | 322,127 / 20,211 B |
| tameshi | 234 | 229,375 / 11,100 B |
| tsukuroi | 292 | 1,649,325 / 53,008 B |
| **total** | **243,596** | 38 files |

`kimi-shokunin` (the only other `/home/vgpnk/Projects/*-shokunin`) has no `corpus/`,
`SKILL.md` or `PROVINCE.md`; its `skills/`, `commands/`, `README.md` and `templates/`
were searched directly (row 4). `kumitate-shokinin/` (note the spelling; a different path
from `kumitate-shokunin/`) is an empty nested directory —
`kumitate-shokinin/kumitate-shokunin/.ufo` — with no files, corpus or scope document, so
it contributes no surface and no hit.

## Hits

Classification is against kagi's round-51 surfaces: **duplicate** = the sibling already
holds the same predicate/mechanism; **adjacent** = a neighbouring mechanism, boundary
declaration or verification surface that the round must cite or route; **none** = a
string match with no bearing. "Owner" is the lane the surface belongs to.

| # | path:line | Term | Class | Owner | What it is |
|---|---|---|---|---|---|
| 1 | `kasegi-shokunin/PROVINCE.md:48` | vault | adjacent | kagi | "`kagi` — secrets and vault handling" in kasegi's sibling map |
| 2 | `mori-shokunin/PROVINCE.md:68` | vault ops | adjacent | kagi | "kagi \| Owns secrets, vault operations, and credential-hygiene evidence; mori never reads or reports credential material" |
| 3 | `kotoba-shokunin/PROVINCE.md:63` | vault ops | adjacent | kagi | "kagi owns secrets and vault ops, credential custody and hygiene evidence"; the split is kotoba's checklist/shape reading of `$HOME/.agents/AGENTS.md`, which kagi only byte-pins |
| 4 | `souji-shokunin/PROVINCE.md:36-37` | vault refs | adjacent | kagi | "Credentials, secrets, tokens, vault refs — kagi-shokunin's province. Souji cites paths/modes only" |
| 5 | `souji-shokunin/PROVINCE.md:89-90` | credential hygiene | adjacent | kagi | "kagi-shokunin owns credential hygiene evidence; souji routes any credential-shaped finding to kagi" |
| 6 | `souji-shokunin/PROVINCE.md:118-119` | secret removal | adjacent | kagi + operator | `git-filter-repo --sensitive-data-removal` routes to kagi and the operator; souji never rewrites history |
| 7 | `souji-shokunin/SKILL.md:2` | secrets | adjacent | kagi | anti-trigger: "NEVER credentials/secrets handling (kagi-shokunin owns credential hygiene) … publishing and vault actions are operator-owned" |
| 8 | `tsukuroi-shokunin/PROVINCE.md:25` | secrets | adjacent | kagi | "**Refuses:** … secrets (→ kagi)" |
| 9 | `tsukuroi-shokunin/PROVINCE.md:47` | credential exposure | adjacent | kagi | ADJ-02: a credential-bearing helper finding is reported as path/mode/uid only; "no secret values, vault references, session bytes" |
| 10 | `kake-shokunin/PROVINCE.md:44` | secrets | adjacent | kagi | "`kagi` owns secrets and credential custody; kake records no secret values" |
| 11 | `kake-shokunin/PROVINCE.md:300` | key custody | adjacent | kagi | signature generation/verification "with key custody adjacent to `kagi`" |
| 12 | `kama-shokunin/SKILL.md:28,31` | credential material | adjacent | kagi | refuses "credential material, auth flows and secret handling (kagi)"; "the key that would open it is kagi's surface — report, do not absorb" |
| 13 | `kama-shokunin/PROVINCE.md:42` | credential material | adjacent | kagi | same refusal in the province file |
| 14 | `chousa-shokunin/PROVINCE.md:14-15` | secret values | adjacent | kagi | "secret values in any record (→ kagi for custody; shape-only here)"; `SKILL.md:65` repeats it |
| 15 | `kasegi-shokunin/corpus/instruments/freeze-check.py:1-33` | claims-manifest gate | adjacent | kasegi | replays every claim's `counter_cmd` at the frozen base; whole-line equality (`fixed=0` ≠ `xfixed=0`), `expect_before != expect_after`, and `FC-AFTER-AT-BASE` as the do-nothing control; `corpus/instruments/README.md:996` documents it |
| 16 | `kasegi-shokunin/corpus/knowledge/claim-gates.md:18-32` | manifest gates | adjacent | kasegi | the package-manifest gates (`sequence`, `expected_head_sha256`, per-artifact sha256/polarity/resolve-inside) including a secrets regex over package text |
| 17 | `chousa-shokunin/tools/claims-audit.py` + `-v2` (`SKILL.md:159-160`) | claims gate | adjacent | chousa | a frozen claims file + rule TSV (id, rule, anchor, target, expect, note), seven rule classes, `FLAG`/`AUDIT_STALE`/`FLAGGED=k/n`; `corpus/knowledge/self-claim-audit-r63.md` |
| 18 | `chousa-shokunin/corpus/QUALITY.md:365-366` | PATH shim | adjacent | chousa | red witness: "the round-34 gate scores 0/9 (PATH shim and `BASH_ENV` function tripwires both fire; no-grep `PATH` exits 2)" |
| 19 | `chousa-shokunin/corpus/QUALITY.md:442-452` | PATH blindness doctrine | adjacent | chousa | item 54: a claim's general clause must not outrun its counter's cells; a new falsifier class (`LD_PRELOAD`, `BASH_FUNC_*`) must appear in a named limit — "round-37 C1's 'no PATH shim' wording survived while `LD_PRELOAD` moved pin verdicts 4/7 and 3/7" |
| 20 | `chousa-shokunin/corpus/README.md:1056` | PATH-resolved tool | adjacent | chousa | `knowledge/grep-pin-r35.md`: "why a PATH-resolved grep is a behaviour contract hole (PATH shim, `BASH_ENV` function, host `pi-uu-grep` builtin)" |
| 21 | `chousa-shokunin/corpus/knowledge/capture-path-pin-r41.md:11-15` | PATH shim census | adjacent | chousa | 728 PATH-resolved external calls in one `--pin` run, measured "every candidate tool name trapped through a logging PATH shim" |
| 22 | `chousa-shokunin/corpus/evidence/round37/claims.md:25-28` | absolute pin | adjacent | chousa | "hashed through one pinned absolute `sha256sum` and never through the caller's `PATH`, so no PATH shim can move a pin verdict in either direction" |
| 23 | `chousa-shokunin/corpus/evidence/round38/claims.md:221-226` | PATH-resolved mutant | adjacent | chousa | a mutant capture "using PATH-resolved `command env` scores 7/7 while being PATH-poisonable" — **output cannot tell which binary ran** |
| 24 | `chousa-shokunin/corpus/evidence/round35/claims.md:191-195` | tripwire forge | adjacent | chousa | two attack gates "score 9/9 with the shims actually running, because the counter keeps its tripwire inside the fixture root … and checks emptiness only after the run" |
| 25 | `chousa-shokunin/corpus/evidence/round36/c1-count.py:17-22` | shim scenarios | adjacent | chousa | S1 PATH shim first, S2 `BASH_ENV` function, S3 PATH-less, S4 relative override refused, S6 non-GNU stub refused |
| 26 | `tabi-shokunin/PROVINCE.md:189` + `SKILL.md:2969-2977` | vault/1Password boundary | **contested** | kagi ↔ tabi ↔ kake | tabi's adjacency table marks kagi **contested** (CDP 9222 + the-musketeer chrome profile); its `secrets-vault-ops` split cites `kagi-shokunin/SKILL.md:40` (the 1Password `open-popup` refusal) and the vault-DOM ban, and records a wave-2 withdrawal of the map row `cdp-bridge-vault-dom-refusal` |
| 27 | `tabi-shokunin/SKILL.md:685,744,768`; `PROVINCE.md:16` | secrets | adjacent | kagi | "refuse-and-route … secrets → kagi"; A10 out-of-province → kagi |
| 28 | `kumitate-shokunin/PROVINCE.md:31,48,75` | token passthrough | adjacent | kasegi / kagi | "MCP/OAuth security practice (token passthrough, confused deputy) → kasegi / kagi" |
| 29 | `kengaku-shokunin/PROVINCE.md:28,42,162` | credential config | adjacent | kagi | "**kagi:** Janitor consumer-side endpoint/credential config"; any Janitor consumer-endpoint discrepancy routes to kagi |
| 30 | `kengaku-shokunin/PROVINCE.md:435-436` | secret removal | adjacent | kagi + souji | defers history purge/rotation to "kagi's doctrine and souji's routing", citing `.ufo/waves/round-39/build/R39ConnSibling.md` §1 — **the precedent for this seat's report shape** |
| 31 | `chousa-shokunin/PROVINCE.md:14`; `mado-shokunin/PROVINCE.md:14,18,35`; `mori-shokunin/PROVINCE.md:15,130,206` | secret-shaped values | adjacent | kagi | shape-only / redaction boundaries (mado's tripwire redacts three fixed patterns and "secret handling stays kagi's") |
| 32 | `tameshi-shokunin/PROVINCE.md:9,18,31`; `SKILL.md:66,73,103-105,140,172,180-184` | kagi's own gates | adjacent | tameshi ↔ kagi | tameshi holds `corpus/knowledge/gates-survey-kagi.md` (six kagi gates, exit lattice, POLICY refusals, F-1/F-2) and `mutation-case-kagi-census.md` (16-case selftest vs 10 mutants → 8/10 killed); it reads `kagi corpus/*check*.sh` read-only |
| 33 | `tameshi-shokunin/.ufo/waves/round-90/w1/T90CN1-hits.tsv:62-63` | kagi S089/S090 | adjacent | tameshi + kagi | a cross-lane registry scanner's output over kagi's `corpus/SOURCES.md:96-97`: S089 (Vault releases, newest stable v2.2.1) and S090 (OpenBao releases, v2.7.2), class C03 shape-only |
| 34 | `revenger-shokunin/corpus/snapshots/claude-red-offensive-reporting.md:257` | Vault | none | revenger | "Centralize secrets in HashiCorp Vault; rotate hardcoded creds" as a board recommendation in a red-team report; no mechanics |
| 35 | `kumitate-shokunin/corpus/SOURCES.md:183,188` | HashiCorp | none | kumitate | HashiCorp **Terraform** rows (S228 `plan -detailed-exitcode`, S234 dependency lock file); the match is the `developer.hashicorp.com` URL, not Vault |
| 36 | `kasegi-shokunin/corpus/source-snapshots/round-24/S011.txt:380` | HashiCorp | none | kasegi | alphabetical index word in a captured reference list |
| 37 | `kotoba-shokunin/corpus/knowledge/checklist-execution-round16.md:163` | wrapping token | none | kotoba | `unwrap_tokens` — token-unwrapping in a shell-command checker, unrelated to response wrapping |
| 38 | `souji-shokunin/SKILL.md:234` | PATH shim | none | souji | "synthetic HOME and PATH shims" as *fixture isolation* for a process-census matrix, not as an adversary |
| 39 | `audio-shokunin/corpus/fixtures/measure_audio.py:44184-44186,45327-45336` | shim HOME | none | audio | a shimmed `$HOME` so the operator's `~/.config` fragment is never read; isolation, not falsification |

## Findings

**F1 — no duplicate of the round-51 C1 capability exists in any sibling.**
No lane holds response wrapping, `sys/wrapping/*`, a wrapping token, cubbyhole storage, or
any `bao server`/`vault server` trial (rows 1–9 of the term table, 0 true hits over 243,596
corpus files and 38 SKILL/PROVINCE files; `merge/kagi` also 0). The nearest thing to a
"vault" string in a sibling is a *boundary declaration*, not a mechanism. Disposition:
**no route; kagi keeps C1 outright.**

**F2 — thirteen lanes declare kagi the owner of secrets/vault, and four of them name
"vault" explicitly.** kasegi (`PROVINCE.md:48`, "secrets and vault handling"), mori
(`PROVINCE.md:68`, "secrets, vault operations, and credential-hygiene evidence"), kotoba
(`PROVINCE.md:63`, "secrets and vault ops") and souji (`PROVINCE.md:36`, "tokens, vault
refs — kagi-shokunin's province"). The rest refuse and route: souji (three places,
including `git-filter-repo` history purge), tsukuroi, kake, kama, chousa, mado, tabi,
kengaku, kumitate. Consequence for the round: C1's S108 row and the trial's knowledge
section are the *only* place in the fleet where wrapping mechanics are asserted, so the
trial's own honesty controls carry the whole burden — no sibling can corroborate or
contradict a `TRIAL T<n> HOLDS` line. That is an argument for the counter's controls, not
against the capability.

**F3 — the declared-claim family is held twice, adjacent and differently.**
kasegi's `freeze-check.py` replays a claims file's counters at a base and refuses a freeze
unless `expect_before` occurs as a *whole line* and `expect_after` does not (its
`FC-AFTER-AT-BASE` is a do-nothing control). chousa's `claims-audit.py`/`-v2` anchors
free-standing statements in a claims document against repo facts through a rule TSV with
seven classes. Neither is kagi's predicate: `corpus/claims-declared.sh` binds
`claims-declared.tsv` → `plans/round-<n>.md` heading → one `[claim]`-tagged row inside the
`## Round <n> — post-move` section of `SCORECARD.md`. Disposition: **adjacent, cite — no
merge, no adoption.** Two rules are worth borrowing as *comparison*, not as change: (a)
kasegi's whole-line equality for `expect_before` (`fixed=0` must not match `xfixed=0`),
against kagi's plan-heading test, which is a column-0 prefix match on
`## <claim> — <axis>:` (`claims-declared.sh:154-160`; the gate header already names its
colon-suffix over-match window as a ceiling, and the D2 rule keeps fenced and
HTML-commented headings from counting), and (b) kasegi's `FC-AFTER-AT-BASE`, which is
exactly the shape of kagi's C2 do-nothing attack (a `MISMATCH` that survives the landing).

**F4 — chousa's output-blindness class is already in the round's pre-freeze battery, and it
survives exactly where the round says it does.** chousa measured on this host that a
PATH-resolved tool's output cannot tell which binary answered
(`evidence/round38/claims.md:221-226`), that a tripwire kept inside the fixture root and
checked only after the run is forgeable (`evidence/round35/claims.md:191-195`), and that
the answer is an absolute pinned binary with a provenanced echo
(`evidence/round37/claims.md:25-28`, `knowledge/capture-path-pin-r41.md:11-15`). kagi's C1
answers this structurally, and `controls-prefreeze.txt` shows it: the dispatcher is
installed for every mode except `none`, so the trial never sees the real ELF on PATH — not
even in `real` — and the dispatcher bytes are identical across runs. The control battery
kills a constant-HOLDS printer (K1-F1 → 0), a PATH-shape reader (K1-F2 → 0), a
shim-directory-name reader (K1-F3 → 0) and a shim-*content* reader that greps its `bao` for
the sabotage verbs (K1-F4 → 0, because every run sees the same bytes). Only the state
reader survives, at the ceiling the plan names: K1-F5, a trial that cats
`dirname "$(command -v bao)"/.mode`, reads **5**, recorded as expected. That survivor is a
design trade, not an oversight: a same-user shim is always inspectable, and the mode cannot
be hidden while the dispatcher stays byte-identical — which is precisely what kills K1-F4.
The honest limit is therefore the *class* ("a trial that inspects its runtime can
distinguish the modes"), not the one file, and chousa's item-54 rule (a claim's general
clause must not outrun its cells; a limit must name every demonstrated vector class) is the
doctrine the counter's ceiling comment already follows. **No C1 change is needed on this
axis; the connector's contribution is the citation, not an edit.**

**F5 — contradiction stated, not smoothed.** The trial's own header says it drives `bao`
"resolved on PATH only (never the HTTP API, never an absolute bao path)", while the counter
pins a host file `~/.local/bin/bao`. The two are compatible only because the counter owns
PATH: the pin is a *setup* check, and the witness of which binary answered is the sabotage
differential, not the pin. The second-order consequence is F8.

**F6 — tabi's adjacency screen already carries a `secrets-vault-ops` split with kagi, and
marks kagi `contested` on the Chrome-profile lease.** `tabi/PROVINCE.md:189` and
`tabi/SKILL.md:2969-2977` record that the map row `cdp-bridge-vault-dom-refusal` was
withdrawn at wave 2 (the ban is shared, kagi's line is its own rule) and that kagi is
contested only on the 9222 profile lease. Consequence: **round 51's wrapping surface does
not intersect that contest** (no CDP, no 1Password, no vault DOM); the round should not
re-open it. kumitate's token-passthrough boundary (`PROVINCE.md:31,48,75`) is the nearest
token-semantics neighbour, but it is OAuth token passthrough, not wrapping: **adjacent,
no overlap.**

**F7 — tameshi holds prior measured work about kagi's own gates.** `gates-survey-kagi.md`
(six gates, exit lattice, POLICY refusals, F-1/F-2) and `mutation-case-kagi-census.md`
(16-case selftest vs 10 mutants → 8/10 killed) are the fleet's only external record of how
kagi's counters behave under mutation, and tameshi reads `kagi corpus/*check*.sh` read-only.
Consequence: a C2 mutation claim has a sibling precedent to cite, and a C1 claim does not
(the census gate is not the trial). Disposition: **cite, do not absorb.**

**F8 — the measured trial can derive the counter's scratch root from its own `--work`
argument, and two scoring surfaces live there.** In `plans/round-51-c1.sh` the per-mode
directory is `d="$W/$(rhex)"` and the trial is given `--work "$d/work"` (`:105-117`), so
`dirname "$(dirname "$work")"` is `$W`; I verified that arithmetic on this host by building
the same shape under scratch — the derived path resolves to `$W`, `$W/tree` exists, and a
write through it succeeds (receipt §PATHCHECK). Two scoring surfaces are in `$W`:
(a) `OUT[$m]="$W/out.$m"` (`:111`), the per-leg stdout files that `verdict` reads **after
every run has finished** (`:120-124`, called from the value loop at `:142-148`), so a trial
that appends one `TRIAL T<n> BROKEN` line to `$W/out.sh<n>` on every one of its own runs
leaves exactly one BROKEN line in each shim file — a `discriminating=5` reading with no
sabotage actually discriminated; and (b) `$W/tree`, whose
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md` is read for `entry` at `:133-139`
and only called from the value loop *after* the runs at `:127`, so a trial can append the
`## Measured (round 51 …)` section and turn `entry=0` into `entry=1`, defeating K1-F7
(expect 0) directly. `src` is read at `:70-80`, before any run, so that half is safe. The end-to-end forgery is **[INFERENCE]** (I did not run the
counter: this seat is read-only and the counter starts `bao`); it rests on the verified
path arithmetic plus the cited read order. `run()` also never `cd`s (`:114-118`), so a
relative write from a mutated trial lands in the caller's cwd, normally the lane root.
kasegi's `freeze-check.py` carries the tree half of this class under a stable id —
`FC-BASE-MUTATED`, "the counter left the base tree byte-for-byte untouched (relative path +
size + mtime_ns)" — which is the sibling precedent that makes it a named defect rather than
a hypothetical. None of K1-F1…K1-F9 exercises either file channel: every `fixture_trial`
body in `plans/round-51-controls.sh` only writes to stdout, so the battery cannot see a
candidate that writes to `$W`.

## Proposed move (one, bounded)

**Move both post-run readings out of the trial's reach: capture each leg's output in a shell
variable and hoist the entry reading above the run loop.**

- **Where:** `plans/round-51-c1.sh` (frozen; I may not edit it — this is a recommendation to
  the L1/next round, recorded here as the seat's bounded proposal).
- **Size, two mechanical changes, no new dependency:** (1) replace `OUT[$m]="$W/out.$m"` and
  the redirections in `run()` with `out=$( … )` / `err=$( … 2>&1 )` capture (seven small
  outputs; bash variables cannot be written by a child), keeping `nosecret` (`:150`, which
  currently `cat`s `$W/out.*`) and `verdict` reading the captured strings; (2) move the
  `ENTRY`/`entry_line` block (`:133-139`) above the mode loop (`:127`), so both tree
  readings are taken before any candidate code executes. Optional third cell, cheap: a
  content manifest of `$T` before/after (`tar -C "$T" -cf - . | sha256sum`), reported as
  `base_clean=1|0` and added to the `final` gate beside `setup_ok`/`nosecret`/`pins`/`src`.
- **Why it is the right size:** the trial needs `--work` to run the trial's own scratch, so
  the parent chain from that path is unavoidable; the fix is therefore not path hiding but
  *removing the scoring surfaces from the filesystem the trial can name*. After (1) and (2),
  nothing the trial writes can change a verdict — the only remaining filesystem readers are
  pre-run.
- **Affected axes:** operability/capability (C1) **improves** (two false-clean paths closed;
  K1-F7 recovers its meaning); calibration (C2) **untouched** (its counter already archives
  BASE and REV into scratch and reads only those copies, with g1–g4 pinning every input);
  adjacency **improves** (the round adopts and can cite kasegi's `FC-BASE-MUTATED`).
- **Risks:** (a) `mtime`-only checks are useless — a trial can rewrite and reset them, so any
  manifest must hash contents, and an empty manifest must refuse rather than read `0`;
  (b) command substitution strips trailing newlines, and `nosecret`/`verdict` are
  line-oriented — keep a trailing-newline discipline or write the captured text to a
  file reopened *after* the child exits in a directory created after the mode dirs; (c) the
  read-order hoist changes a frozen counter, so the plan text and the pre-freeze receipt need
  a re-run, not a silent edit; (d) `base_clean` must not enter the capability count (C1's
  target stays 5); (e) the cell must be described as "the measured tree is unchanged", never
  "the trial wrote nothing" — `/tmp`, `$HOME` and the live lane stay reachable, and a lane
  write is the operator's to judge.
- **Red witness the L1 would run:** add two fixture-trial rows beside K1-F7 — (i) an honest
  five-HOLDS trial that appends the measured section to
  `$(dirname "$(dirname "$work")")/tree/corpus/knowledge/vault-openbao-token-lease-lifecycle.md`,
  (ii) an honest five-HOLDS trial that appends one `TRIAL T<n> BROKEN` line to
  `$(dirname "$(dirname "$work")")/out.sh<n>` for n=1..5. On the current bytes both are
  expected to read **5** (the defect); after the move they must read **0**. Both reuse the
  existing `fixture_trial` helper in `plans/round-51-controls.sh`.

## Limits of this scan

- The seat's authoritative scope was `corpus/`, `SKILL.md`, `PROVINCE.md`. Rows 10–13 page
  through large match sets and only their first page was inspected; the counts are the
  tool's. Full enumeration — not paging — backs the no-hit and hit statements for rows 1–5,
  8 and 9 (the wrapping, trial, claims-file and merge terms).
- `.ufo/` archives in siblings were not paged beyond their first hits; the kaidoku GnuPG
  "cubbyholes" line and tameshi's round-90 hits file are the two visible out-of-corpus
  matches and both are classified.
- `merge/kagi` was read as text only; nothing was executed there and no merge decision is
  implied.
- No sibling repo was read at a level that would let me judge whether its own counters are
  correct; this report records what they *state*, at the cited lines.

## Evidence

Read-only: `grep` tool invocations and `sed -n` reads over sibling paths; `git status`,
`git ls-tree`, `git show --stat`, `git rev-parse` in the kagi lane; the C1 counter's own text
(`cat -n plans/round-51-c1.sh`), `plans/round-51-controls.sh` and
`.ufo/waves/round-51/controls/controls-prefreeze.txt` (K1/K2 all MATCH, `pass=20 fail=0`,
K1-F5 expect=5 got=5). The F8 path arithmetic was exercised on a synthetic
`$W/<rhex>/work` beside `$W/tree` under this seat's scratch and then deleted — no counter
run, no `bao` process. No `git`/`jj` mutation, no network, no host change, no write outside
`.ufo/waves/round-51/build/R51ConnectorSiblings*`. Receipts:
`build/R51ConnectorSiblings/grep-receipts.txt`.
