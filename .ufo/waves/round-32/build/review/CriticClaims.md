# CriticClaims — adversarial review of the frozen round-32 claims contract

Seat: CriticClaims (critic, leaf). Target: `plans/round-32.md` as committed at `507dd9f`, with its routed items and frontier step.
Lane HEAD at review: `76241c0` (round-31 late-seat evidence commit, after the freeze; touches only `.ufo/waves/round-31/*`).
Frozen BASE: `32c35fe`. Predicate inputs are byte-identical BASE→HEAD: `corpus/op-ref-probe.sh` sha256 `0f1945e8…44f4c` and `corpus/knowledge/op-ref-consumption.md` sha256 `b819652c…8326` at both revisions; `SCORECARD.md`, `PROVINCE.md`, `corpus/README.md`, `corpus/SOURCES.md`, `corpus/lessons/round-31.md` unchanged (`git diff --stat 32c35fe HEAD`: only `plans/round-32.md` and round-31 evidence files).
No lane file was edited. No predicate was edited; where I think one is wrong I say so below.

## Verdict

**Freeze needs amendment before data.** Three blockers (F1, F2, F11) make the frozen text unmeetable or mis-stated as written; the rest are should-fix items that can be carried in the same amendment commit (a new lane commit naming `507dd9f`, not a re-freeze).

- C2's count-and-probe pair is measurably reachable: on `2.41.1` the probe is CLEAN (exit 0), so the honest path exists.
- C1 is not reachable as routed: SD6 (2 UNRESOLVED citations) has no routed item, and two BASE expectations are false (SD5 and the BASE sum).

## Findings

Severity: **blocker** = freeze cannot be admitted as written; **should-fix** = amend in the same commit or record as a named ceiling; **note** = observation.

### C1 — calibration (self-description sweep)

**F1 — blocker — the frozen BASE expectations are wrong (SD5, sum, SD1 unit).**
- Claim: "SD5 = 3 at BASE"; "BASE sum = 10".
- What breaks: the latest `## Round` section is `## Round 31 — post-move` (SCORECARD.md:1281); its only calibration row is line 1285. That row names `R29-01` and `R29-02` but not `R25-02`. Searching the whole section (lines ≥1281) for `R25-02` returns nothing. So SD5 at BASE is **1**, not 3.
- SD1 is not a line count of 2 either: PROVINCE.md:90 is the only line naming both themes in a Frontier bullet (line count **1**; occurrence count **2**). A literal "line containing `frontier` (case-insensitive)" reading gives **3**, because lines 88 and 89 contain the word `frontier` in prose ("Moved from the frontier list…", "The round-21 frontier lead…") while each names one theme. The plan does not say what makes a line a "Frontier bullet".
- BASE sum therefore measures **7** (SD1 by lines), **8** (by occurrences) or **9** (naive substring), not 10. The do-nothing control still reads n>0, so the claim's logic survives, but the frozen expected column is false and the sweep will disagree with it on day one.
- Evidence: `sed -n '1285p' SCORECARD.md | grep -oE 'R25-02|R29-01|R29-02'` → `R29-01`, `R29-02`; `awk 'NR>=1281' SCORECARD.md | grep -n 'R25-02'` → empty; `grep -niE 'OIDC workload-federation|secret[- ]scanning' PROVINCE.md` → lines 88, 89, 90; `grep -ni 'frontier' PROVINCE.md` → lines 88, 89, 90 (each contains `frontier`, two of them in prose).
- Amendment: state the unit (lines or occurrences) and the bullet rule (e.g. the line begins `- **Frontier`); correct SD5 BASE to 1 and the sum to the measured value.

**F2 — blocker — SD6 (2 UNRESOLVED citations) has no routed item; C1's n=0 target is unreachable under R1–R6.**
- Claim: SD6 target 0 "after the round's landed edits"; routed items R1–R6 are the only edits named.
- What breaks: the two UNRESOLVED lines are not README-frontier or PROVINCE issues. They are `corpus/README.md:64/65/67` written as a slash-list in a line-range shorthand: `corpus/lessons/round-30-verifier-spotcheck.md:41` and `corpus/lessons/round-31.md:121` (the latter sits in `## Migrations`, not in the Corrigenda that R3/R4 append to). R6 removes README lines 117–118; the cited lines 64/65/67 are above that and untouched. Rewriting the token in place edits a historical verifier record; appending a corrigendum that repeats the token leaves the body token unresolved. So under the frozen text the only route to n=0 is an unrouted body edit, or a gate change (see F9).
- The gate itself names the legitimate route: a citation whose LINE carries one of the markers `scratch | ephemeral | relocat | formerly | no longer | removed | renamed | historical` is LABELED, not UNRESOLVED (`corpus/claim-ledger.sh` header lines 42–48: "a dead citation must be labelled dead where it is cited").
- Evidence: `bash corpus/claim-ledger.sh citations` → `UNRESOLVED corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)`, `UNRESOLVED corpus/lessons/round-31.md:121 corpus/README.md`:64/65/67 (local)`, `CITATION_GATE: BROKEN (cites=1988 docs=84 unresolved=2 ephemeral=0 labeled=13)`, exit 1 (run at lane HEAD; identical at BASE since the lessons are unchanged).
- Amendment: add routed item R7: "relabel the two SD6 tokens on their own lines with the gate's `historical` marker (or `no longer`), body text otherwise unchanged; the correction goes in a corrigendum". This is the gate's documented rule, not a predicate change.

**F3 — should-fix — SD4 is satisfied by the string `| M31-6 ` anywhere in the file.**
- What breaks: the counter's regex is `^\| M31-n ` on any line. A row in a fenced block, a corrigendum paragraph or a code sample passes. R4 says the row goes into the Mistakes table, but the counter does not check the section.
- Evidence: `grep -cE '^\| M31-6 ' corpus/lessons/round-31.md` → 0 at BASE; the id is named once, at line 214 (`M31-6 (new mistake)`), inside `## Limits`.
- Amendment (or record as named ceiling): either bound the row to the `## Mistakes` section, or say in the ceiling that SD4 counts row presence, not placement.

**F4 — should-fix — SD5 is closed by naming, not by work.**
- What breaks: adding `R25-02` to the round-32 calibration row makes SD5 zero while the row still reads "9" with no reason; the plan's named ceiling admits the score is author-assigned but says nothing about the row. Rigged zero, legal under the frozen text.
- Evidence: SD5 is a pure string-presence check on the row (plan line 31).
- Amendment: require the round-32 calibration row to state each red's status as `RED (operator-owned)` in the same sentence, and say in the ceiling that SD5 measures naming only.

**F5 — should-fix — SD1/SD2 are keyed on literal prefixes that a rename evades.**
- What breaks: SD2 matches `^## Frontier` (README.md:111) and SD1 matches a "Frontier bullet". Renaming the heading to `## Frontier (archived)` or the bullet to `- **Explored**` yields zero with the tombstones still in place.
- Evidence: `grep -n '^## Frontier' corpus/README.md` → 111 (SD2 scope); `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md | grep -c 'moved to core'` → 2 (lines 117, 118).
- Amendment: record as a named ceiling, or assert the heading and bullet text in the selftest fixtures.

**F6 — should-fix — the M32-1 class is wider than SD1–SD6; the plan overclaims coverage.**
- What breaks: C1 says "self-description mismatches counted". But `corpus/SOURCES.md` `## Leads (unopened)` (lines 113–119) still lists as unopened: OIDC workload-federation (opened S061–S071 in round 31), Gitleaks/Betterleaks/TruffleHog (S053–S060, round 30) and NIST SP 800-57 Rev. 6 IPD (S049, S051, round 28). `SHONEN.md` box 1 quotes a `CITATION_GATE: CLEAN` run, which the gate no longer produces. None of SD1–SD6 counts these.
- Evidence: `sed -n '113,120p' corpus/SOURCES.md`; `grep -nE '^\| S04[89] |^\| S051 ' corpus/SOURCES.md`; `grep -n 'CITATION_GATE: CLEAN' SHONEN.md`.
- Amendment: either add an SD7 for the Leads section before data, or narrow C1's stated scope to SD1–SD6 in the ceiling.

**F7 — should-fix — "measured revision" is undefined and "partial move" is a relabel vocabulary.**
- What breaks: the kill rule fires "at the measured revision". The plan does not say which commit, nor whether it is re-measured after the landing commit. The kill rule's wording "reported as a partial move" is the vocabulary round-30/31 calibration rows already use ("C1 partial", SCORECARD.md:1261). A nonzero SD sum could be reported as partial progress.
- Evidence: `grep -n 'C1 partial' SCORECARD.md`.
- Amendment: define the measured revision as the commit that the receipt names, and restrict calibration wording to `admitted` / `not admitted`.

**F8 — should-fix — the do-nothing control cannot be run as written.**
- What breaks: "BASE sweep output itself" presumes a sweep that does not exist at `32c35fe`. The plan does not say how to run it there.
- Evidence: `ls corpus/self-description-sweep.sh` → absent at HEAD.
- Amendment: name the method, e.g. `git clone --shared` at `32c35fe`, copy the new sweep in, run it, record the output.

**F9 — should-fix — the SD6 counter's gate is editable in-round.**
- What breaks: SD6 reads the output of `corpus/claim-ledger.sh citations`. The plan does not freeze that file, so editing the gate's message or its citation scan would zero SD6 without repairing any citation.
- Amendment: add `git diff --quiet 32c35fe -- corpus/claim-ledger.sh` to the measurement receipt, or state that the gate is out of scope.

**F10 — should-fix — the stamps and ledger are not updated by the plan, and M32-1 stays uncaptured.**
- What breaks: `corpus/stamps.tsv` pins `PROVINCE.md`, `corpus/README.md`, `SCORECARD.md`, `corpus/lessons/round-31.md`, `SHONEN.md` and `LOG.md`. Every routed edit makes `claim-ledger.sh verify` report STALE until those stamps are re-pinned; round-31 did this explicitly ("stamps re-pin, receipts re-taken"), round-32 does not mention it. And no `corpus/claim-ledger.tsv` row covers the SD sweep or the BYTE_PIN counter, so the mistake M32-1 stays `Captured-by: none` after the round, which is the plan's own problem statement.
- Evidence: `grep -c '^PROVINCE.md	' corpus/stamps.tsv` → 1 (same for the other five); `grep -c '' corpus/claim-ledger.tsv`.
- Amendment: name the stamp re-pin step and add R32-xx ledger rows for the two counters.

### C2 — freshness (byte-evidence pin on installed op)

**F11 — blocker — the sourced clause of C2 (S072) has no URL, no fallback, and cannot carry the byte claim.**
- Claim: "C2 rests on a new S072 row (1Password CLI release history entry for 2.41.1)".
- What breaks: (a) no URL is named, so the row cannot be checked against a fixed target. (b) My one web search for "1Password CLI 2.41.1 release notes" returned no 2.41.1 entry and described 2.41.0 as the latest; that is one query, not proof, but it means the sourced clause may be unmeetable. (c) The installed binary is the Arch package `1password-cli 2.41.1-1` (`pacman -Q 1password-cli`; `/usr/bin/op` owned by it). So the version is real on this host, but the release-history entry the plan names is unverified. (d) Even if S072 opens, a release-history entry supports "a 2.41.1 build is published"; it does not support the six byte classes. The byte claim is carried by the probe, so "C2 rests on S072" overstates.
- Evidence: `web_search` query above (1 call); `command -v op` → `/usr/bin/op`; `pacman -Q 1password-cli` → `1password-cli 2.41.1-1`; `grep -nE 'product_history|CLI2|release history' corpus/SOURCES.md` → only S001 (no existing CLI-history row, so S072 would be new, not duplicate).
- Amendment: name the official upstream page the seat must open (the 1Password CLI product/release history page, to be confirmed in-round); state the fallback (if no upstream 2.41.1 entry is found, the sourced clause is recorded as unmet and the pacman package is cited as the local evidence, not substituted for S072); narrow S072's claim to "2.41.1 is a published build"; state that the byte claim is measured-only.

**F12 — should-fix — the count and the probe are not bound to the same binary.**
- What breaks: the counter's `V` comes from `op --version` in one command; the probe resolves `op` itself (`OP_BIN=$(command -v "$OP_BIN")`, `corpus/op-ref-probe.sh` ~line 525) and never prints the version. A CLEAN receipt does not record which binary ran. Nothing in the frozen predicate ties the two.
- Evidence: `grep -n 'op --version\|OP_DOTENV_BYTES: CLEAN' corpus/op-ref-probe.sh` → the CLEAN line only; the probe output on my run had no version field.
- Amendment: the measurement receipt must include `op --version` and `pacman -Q 1password-cli` output in the same file as the probe line.

**F13 — should-fix — the probe's expected bytes are not pinned; a DRIFT can be "fixed" by editing the contract.**
- What breaks: the six expected hex strings sit in `DOTENV_BYTE_CONTRACT` (`corpus/op-ref-probe.sh:135–142`). A DRIFT on 2.41.1 could be relabelled CLEAN by editing those strings. The kill rule says not to rewrite §11 to hide a DRIFT; it does not say the probe's expectations are frozen.
- Evidence: `sha256sum corpus/op-ref-probe.sh` = `0f1945e8d8a8fc56…44f4c` at both BASE and HEAD (unchanged).
- Amendment: pin that sha in the receipt and require `git diff --quiet 32c35fe -- corpus/op-ref-probe.sh` at measurement.

**F14 — note — the C2 count is reachable without any new measurement; the AND is what protects it.**
- The count `grep -c "op \`2.41.1\`"` over the §11 range can be met by prose in §11 ("not measured on op `2.41.1`"). The AND with a CLEAN probe is the only thing that binds it. Keep the AND; do not weaken it.
- Evidence (measured): `V=2.41.1; awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md | grep -c "op \`$V\`"` → `0`. The BASE count is therefore 0, as the plan says.

**Measured probe (for the target, not a pass):** `bash corpus/op-ref-probe.sh --dotenv-bytes` → six `DOTENV_BYTES_CASE … status=PASS` lines, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0 on `op 2.41.1`. So the honest C2 target is achievable with a `### 11.1` subsection; the attack surfaces are F11–F13, not the measurement.

### Kill rules

**F15 — should-fix — a non-CLEAN outcome has one relabel path left open: editing the probe (F13) or the gate (F9).** Covered above. The plan's kill rules themselves are sound: C1 "any SD check nonzero → not admitted" and C2 "non-CLEAN probe → harmed/unprovable" both keep the AND. The gap is what counts as the "measured" state.

### M32-1 fix

**F16 — note — the fix is shown able to fail only by fixtures the sweep author writes.**
- The plan names planted-mismatch fixtures inside the sweep selftest. The sweep and its fixtures come from the same author, so the selftest checks the sweep against its own idea of a mismatch. Name who runs the planted fixtures (the L1 or a second seat) and commit the fixtures as files so they can be replayed.
- The SD6 fixture depends on `claim-ledger.sh citations --root` (the gate takes a `--root`); that is usable.

### Sourced claims and considerthese

**F17 — should-fix — the NIST deferral premise is not checkable as written.**
- Claim: NIST `merge/kagi/` entries `nist-key-management-family-status.md` and `nist-key-management-parts-withdrawal.md` "need in-round re-grounding that the two-claim cap cannot absorb".
- What breaks: neither file exists. `find /home/vgpnk/Projects/shokunin -maxdepth 6 -name 'nist-key-management*'` → no match; there is no `merge/` directory at the fleet root or in the lane. The NIST Rev. 6 IPD status is already in the registry (S049, and S051 "supersedes S049"; census prints a W04 duplicate-URL warning for S051), so the reason "needs re-grounding" is not visible in the artifacts the plan names.
- Amendment: name the real candidate artifact or restate the deferral as "not selected under the two-claim cap" (honest and checkable).

**F18 — verified — considerthese proposal 4 reject is checkable and holds.**
- `considerthese/2026-10-26.md:64` is "Create `considerthese/BACKLOG.md`" (carried from 2026-10-24). `SCORECARD.md:14` carries the `lane-status:` line; `corpus/lessons/round-31.md:145` is the section "Considerthese — proposal 2, machine-readable lane status" (the adoption is recorded). Flip condition is stated. No finding.

### Report contract and round shape

**F19 — note — the frozen plan defines no report sections.** The plan names "SHONEN" and "Sources & frontier" only indirectly (its frontier step and routed items). The precedent is `corpus/lessons/round-31.md` (Round shape / Gate / Migrations / Considerthese / Mistakes / Limits / Corrigenda). Name the section list in the amendment or say it follows round-31. SHONEN: the plan changes no box (4 `[~]` boxes stay); state that explicitly.

**F20 — verified — round shape matches the run-15 rules.** Seats: scout 2 + executor 3 + scribe 3 + connector 1 + reviewer 2 + critic 1 + mutation-tester 1 = **13**. Band 8–16 (`scripts/hyaku/ufo-wave-policy.json`, `waveMinLanes 8 / waveMaxLanes 16`). Attack seats (reviewer + critic + mutation-tester; lane-addendum run 15 also counts labrat) = 4 → **30.8 %** ≥ 25 %. Connector = 1 ≤ 2. Scout route `@m_antigravity` matches the run-15 map (`scripts/hyaku/lane-addendum.md:4`).
- Note: the run-15 map sets mutation-tester to `@m_flash`; the plan says "m_flash / m_zfl". Pick one.
- Unverified: "the validator refuses labrat". `grep -rniE 'labrat' scripts/hyaku/*.py scripts/hyaku/*.sh` with refuse/reject terms → no match. `ufo-wave-policy.json` defines a labrat probe role (omp-native-v1 `probe`, count 1). The refusal claim is not checkable from these files.

**F21 — note — census command path.** The plan's `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` resolves only from the fleet root (`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh`, present). The lane's `corpus/sources-census.sh` differs (`cmp` DIFFER). Name the cwd in the plan. Measured: `validate` exit 0, with W04 duplicate-URL warnings (S045, S050, S051, S069, S070) and `kagi ok`.

**F22 — note — output path conflict.** The item says `.ufo/waves/round-32/build/review/CriticClaims.md`; the Report trailer says `.ufo/waves/round-32/build/CriticClaims.md`. Both are written (this file and an identical copy).

## Commands run and exit codes

All read-only, except the probe (allowed `op` use) and temp files under my scratch dir.

| command | exit | result |
|---|---|---|
| `git rev-parse 507dd9f^`; `git log --oneline -5`; `git show --stat 507dd9f`, `76241c0`; `git diff --stat 32c35fe HEAD`; `git diff --quiet 32c35fe HEAD -- <probe, §11>`; `git status --short` | 0 | parent of 507dd9f = 32c35fe; probe and §11 unchanged; only `?? .ufo/waves/round-32/` untracked |
| `git show 32c35fe:corpus/op-ref-probe.sh \| sha256sum` and HEAD equivalent | 0 | identical hash `0f1945e8…44f4c` |
| `op --version` | 0 | `2.41.1` |
| `awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md \| grep -c "op \`2.41.1\`"` | 1 (grep count 0) | `0` |
| `bash corpus/op-ref-probe.sh --dotenv-bytes` | 0 | six PASS lines; `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)` |
| `bash corpus/claim-ledger.sh citations` (TMPDIR scratch) | 1 | `CITATION_GATE: BROKEN (cites=1988 docs=84 unresolved=2 ephemeral=0 labeled=13)` |
| `grep`/`sed`/`awk` measurements of SD1–SD6 inputs (PROVINCE, README, SHONEN, SCORECARD, lessons, SOURCES) | 0 / 1 for empty greps | as cited in F1–F6 |
| `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (fleet root cwd) | 0 | `kagi ok`, W04 warnings only |
| `pacman -Q 1password-cli`; `command -v op`; `pacman -Qo /usr/bin/op` | 0 | `1password-cli 2.41.1-1`; `/usr/bin/op` |
| `web_search` "1Password CLI 2.41.1 release notes" | — | no 2.41.1 entry found (one query) |
| `find` for NIST candidate files; `ls merge` | 1 | not found |

No install or upgrade was performed. No `pacman -S/-Sy/-Syu/-U/-R` was run. No `op signin/account/item/read/inject/run` was run. No subagent was spawned.

## SD BASE measurement (critic's count, for the L1)

| check | counted at BASE | plan says | note |
|---|---|---|---|
| SD1 | 1 (lines) / 2 (occurrences) / 3 (naive `frontier` substring) | 2 | F1 |
| SD2 | 2 | 2 | match |
| SD3 | 0 | 0 | all SHONEN tokens exist (`corpus/claim-ledger.sh`, `corpus/lessons/round-19-recensus.md`, `corpus/op-ref-probe.sh`, `corpus/scope-gate.sh`, `LOG.md`, `PROVINCE.md`, `SKILL.md`) |
| SD4 | 1 | 1 | M31-6 only; the row is absent |
| SD5 | 1 | 3 | F1 (R25-02 only) |
| SD6 | 2 | 2 | F2 (unrouted) |
| sum | 7 / 8 / 9 | 10 | F1 |

## Freeze verdict, restated

**Freeze needs amendment before data.** Amendment commit (new lane commit naming `507dd9f`, not a re-freeze) must:

1. Correct the C1 BASE column: SD1 unit and bullet rule (F1, F5); SD5 BASE = 1 (F1); the BASE sum from the measured values.
2. Add routed item R7: relabel the two SD6 tokens with the gate's `historical` marker, in a corrigendum; name the lessons (F2).
3. Rewrite C2's sourced clause: name the upstream URL, the fallback when no 2.41.1 entry exists, and the narrowed S072 claim (F11).
4. Bind the C2 receipt to the binary: `op --version` and `pacman -Q` in the same receipt; pin the probe and gate by sha / `git diff --quiet 32c35fe` (F9, F12, F13).
5. Define the measured revision; restrict calibration vocabulary to admitted / not admitted; name the BASE method for the do-nothing control (F7, F8).
6. Name the stamp re-pin step and add ledger rows for both counters (F10).
7. Correct the NIST deferral premise (F17) and the C1 scope ceiling for SOURCES Leads and SHONEN (F6).
8. Record as named ceilings: F3 (SD4 placement), F4 (SD5 naming), F5 (heading rename), F16 (fixture authorship).

Nothing here is a judgment on the operator-owned reds (R25-02, R29-01, R29-02) or on the considerthese reject.
