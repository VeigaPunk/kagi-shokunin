# ConnOverlap — C3 sibling-overlap scan (round 30, BUILD wave)

Seat: `ConnOverlap` (connector, leaf — no subagents dispatched).
Scope: **read-only** sweep of `/home/vgpnk/Projects/shokunin/*-shokunin/` siblings + report only.
Lane: `kagi-shokunin`. Frozen BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336`; plan `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c`.
No lane file was modified. No git/jj mutation in any lane. No credential reads, no `op` contact, no installs.

**Verdict in one line: no sibling lane claims secret-scanning, credential-validation, NIST key-management or
OIDC-federation ground at current tips, and no sibling cites any of the 8 URLs C3 adopts — the round-21 sweep
result re-verifies, and C3's three entries do not contest any sibling's mechanism.**

One lane-internal finding is attached below (§5): the staged entry `secret-scanning-detection-vs-validation.md`
mischaracterises the lane's own row **S048** as a "lead". That is a C3-gate honesty issue, not a sibling contest.

---

## 1. Method — commands and their results (all reproducible)

Sibling set swept: the 20 `*-shokunin` lanes other than `kagi` (audio, chousa, game-dev-2d, game-dev-3d,
kaidoku, kake, kama, kasegi, kengaku, kotoba, kotodama, kumitate, lore, mado, mori, revenger, souji, tabi,
tameshi, tsukuroi). No other lane-shaped tree exists at the fleet root
(`find . -maxdepth 3 -name SKILL.md -not -path '*/node_modules/*'` → every hit inside a `*-shokunin/`).

| # | command (run at fleet root `/home/vgpnk/Projects/shokunin`) | result |
|---|---|---|
| 1 | `git -C <lane> rev-parse HEAD` (20 lanes) | tips recorded in §2 |
| 2 | `git -C <lane> status --porcelain -- PROVINCE.md SKILL.md corpus/SOURCES.md corpus/knowledge corpus/README.md` | `dirty=0` for all 20 → the four surfaces are at tip |
| 3 | `grep -rIn -iE 'gitleaks\|trufflehog\|betterleaks\|secret[- ]scan' <lane>/{PROVINCE.md,SKILL.md,corpus/SOURCES.md,corpus/README.md,corpus/knowledge}` | hits only in the lanes tabulated in §3, and every one is a hygiene filter (§3) |
| 4 | `grep -rIn -iE 'credential[- ]valid\|validat[a-z]* (a )?credential\|credential custody'` | kake `PROVINCE.md:44`, kotoba `PROVINCE.md:63` — both are *deferrals to kagi*, not claims (§4) |
| 5 | `grep -rIn -iE 'NIST (SP )?800-5[0-9]\|key[- ]management\|key management service\|\bKMS\b'` | 7 hits, **all false positives** (§6) |
| 6 | `grep -rIn -iE '\bOIDC\b\|federat(ion\|ed identity)\|OpenID Connect'` | 5 hits, **all false positives** (§6) |
| 7 | `grep -rIn -iE 'detection versus verification\|detection-vs-verification\|validity check\|verified secret'` | only kengaku (benchmark task-validity) and kumitate (clock-validity) — different subjects |
| 8 | `grep -rIn -iE 'false[- ]positive\|triage (trigger\|signal)\|not (an? )?incident\|credential (is\|was) live\|live check'` | no sibling states the credential-validity semantics C3 adopts |
| 9 | `git -C <lane> grep -In -E 'gitleaks/gitleaks\|trufflesecurity/trufflehog\|betterleaks/betterleaks\|trufflesecurity\.com/docs/\|api\.github\.com/search/repositories\?q=betterleaks' HEAD --` | **0 hits in all 20 lanes** (tip-level) |
| 10 | `git -C <lane> log --all --oneline -S'<url>'` × 4 URL needles × 20 lanes (**full history, 265 s wall**) | **0 hits in all 20 lanes** — no sibling ever cited any of the 8 URLs |
| 11 | `grep -rIn -iE 'github\.com/(gitleaks\|trufflesecurity\|betterleaks)\|gitleaks\.com\|trufflesecurity\.com\|betterleaks\.(com\|dev)'` over all 20 lanes' four surfaces | 0 hits (alternate URL forms) |
| 12 | `grep -rIn --exclude-dir=.git --exclude-dir=.jj -E '<the 8 URLs>'` at fleet root | exactly **one** non-lane file: `.ufo/waves/kaika-w1/kagi-art.md` (§5) |

Commands 9–10 are the decisive ones for the acceptance question "does any sibling already cite the same 8
source URLs": the answer is **no**, at tips *and* across the entire history of every sibling lane.

Scratch: `/fast/scratch/hyaku/kagi-r30/ConnOverlap/` (created, used for nothing persistent; the sweep was
read-only, so no fixtures were materialised — the directory is empty and removed at close).

---

## 2. Per-sibling verdict — 20 lanes, current tips

Legend: **NO CLAIM** = the lane's province/corpus contains no secret-scanning, credential-validation,
NIST-key-management or OIDC-federation ground. **DEFER-TO-KAGI** = the lane's own file explicitly routes that
ground to kagi (strongest non-contest evidence). **ADJACENT** = the lane holds a neighbouring mechanism
(own-artifact hygiene scanner, or a *different* tool's detection-vs-confirmation semantics).

| # | lane | tip (HEAD) | verdict | evidence pointer |
|---|---|---|---|---|
| 1 | audio | `f9da7ee97e0ba95da1803c2afe9c616c519bae18` | NO CLAIM | `PROVINCE.md:3` "game audio production"; no secret/scan token in any of the four surfaces |
| 2 | chousa | `f748abbb6bf58388e732facd4ecec5612419c457` | **ADJACENT (hygiene filter)** + DEFER-TO-KAGI | `tools/research-gate.sh:1069` `scan_secrets()`, emit at `:1087`; `corpus/knowledge/verification-r16.md:35`; `PROVINCE.md:14` "secret values in any record (→ kagi for custody; shape-only here)" |
| 3 | game-dev-2d | `1e033ef053beedf9a201daa21fbeb9c8b2f72dc3` | NO CLAIM | `PROVINCE.md:3` "2D game production"; `corpus/knowledge/` holds 5 files, none secret-scanning |
| 4 | game-dev-3d | `39ca3973c7865456d97fae18033f3f460c6cf8c1c` | NO CLAIM | `SKILL.md:75` "scanner-relative datum" = its own Unreal pointer scanner, unrelated to secret scanning |
| 5 | kaidoku | `c7fe6898e9a8b3ff04486b4a1d672e9db37610c9` | **ADJACENT (hygiene filter)** | `PROVINCE.md:298` "embedded TLS secrets in a test capture are a property of that input"; wave artifacts `.ufo/waves/round-14/w1/CustodySafety.md:79`, `round-15/w1/SourceCustody.md:146` propose `gitleaks dir` as a **pre-commit hygiene sweep** of its own fixtures — no corpus entry, no registry row, `used-by —` |
| 6 | kake | `dbcfef0b80868dc3f677ccf2caa51110094e6d26` | **DEFER-TO-KAGI** | `PROVINCE.md:44` "`kagi` owns secrets and credential custody; kake records no secret values."; `corpus/knowledge/vault-properties.md` = *web-vault PROPERTIES[] page audit* (a website property list, not a credential vault) |
| 7 | kama | `6035e952c2521999e192d6f236331f265ac98392` | **ADJACENT (hygiene filter)** + DEFER-TO-KAGI | `SKILL.md:670` "Exact argv is not secret scanning or effective-config attestation"; `.ufo/waves/round-56/w1/out/S03SecretScan.md` = bounded credential/`op://`-URI sweep of its own scratch; `PROVINCE.md:42` "credential material & auth flows (kagi)" |
| 8 | kasegi | `cd3029876eac7189aaff0d32b26031c0defa35aa` | **ADJACENT (hygiene filter + nearest epistemic cousin)** + DEFER-TO-KAGI | `SKILL.md:676` "secret scans must tolerate inert fixtures (Airtable's one-char `Bearer x`)"; `.ufo/waves/round-36/wave1/SentSecrets.md:27,41,204` runs `gitleaks 8.30.1` over its own wave output; `PROVINCE.md:48` "kagi — secrets and vault handling"; **cousin**: `corpus/knowledge/ai-assisted-finding-validation.md:7` and `corpus/knowledge/openssf-scorecard-checks.md:54` — see §3b |
| 9 | kengaku | `9ebde3a73502ef210f3e2f6d0c1e0edfc90de0f3` | NO CLAIM | `corpus/SOURCES.md:233` "the task's own definition names OpenSSL key management and permissions as the graded surface" = a Terminal-Bench grader surface, not NIST key-management guidance; `PROVINCE.md:27,141` route kagi's endpoint/credential config to kagi |
| 10 | kotoba | `1c8f37edf2e5ac0fb3c2be1c88e32406313fe47b` | **DEFER-TO-KAGI** | `PROVINCE.md:63` "kagi owns secrets and vault ops, credential custody and hygiene evidence (SKILL.md:3, PROVINCE.md:3)" |
| 11 | kotodama | `c285b2afb19d4b64320e18df1f55e426bf2d0b0c` | NO CLAIM | `PROVINCE.md:3` linguistic-cultural worldbuilding; `corpus/SOURCES.md` "federation" = World Federation of the Deaf; "kms" = kilometres / museum catalogue IDs |
| 12 | kumitate | `3c369336218329e30248b5d69c41348c02658169` | **ADJACENT (hygiene filter)** + **EXPLICIT DEFERRAL** | `corpus/knowledge/kimi-binary-secrets.md:217-218` "**UNKNOWN:** token validity, credential schema, expiry — none is inferable without reading the files, which this lane did not do. Full credential/minting anatomy belongs to the kagi lane, not here."; `PROVINCE.md:30` "MCP/OAuth security practice (token passthrough, confused deputy) → kasegi / kagi"; `.ufo/waves/round-51/w1/SentReceipt.md:15-32` proposes a `gitleaks dir` close-time sweep of receipts, explicitly "not a proof that arbitrary secret-looking argv values are absent" |
| 13 | lore | `0f044aa7c7e4e17cfd5b6278179709b60db45d61` | NO CLAIM | fictional-world records; `corpus/knowledge/` holds 26 files, none secret-scanning |
| 14 | mado | `524fa1f90b1f2de44b3019bacf833d54e0af13a0` | **ADJACENT (hygiene filter)** + DEFER-TO-KAGI | `corpus/knowledge/province-accuracy-selfaudit.md:235,314` "Secret scans (§4) \| 14 policy-text hits / 0 key-shaped" (counts its own config corpus); `PROVINCE.md:14` "secrets in configs (shape-only, → kagi)" |
| 15 | mori | `84c6cbc3b47c536a504aaee329c77897d389935e` | **DEFER-TO-KAGI** | `PROVINCE.md:68` "kagi \| Owns secrets, vault operations, and credential-hygiene evidence; mori never reads or reports credential material."; `PROVINCE.md:15` "credential material (→ kagi)" |
| 16 | revenger | `5915ad8d71c19ad377829d130ba1c35445eb32a4` | **ADJACENT (nearest epistemic cousin)** | `corpus/SOURCES.md:335` (S320 FwHunt Community Scanner README) + `corpus/knowledge/round-73-re-resource-atlas.md:301` "A rule match on a UEFI module is a detection lead tied to a rule ID… A rule hit does not confirm a vulnerability." — **UEFI firmware rule matching, a different tool class and object**; see §3b |
| 17 | souji | `ab8c1fcfa9b079a425c4eb8b12d517118a56e65e` | **DEFER-TO-KAGI (explicit)** | `PROVINCE.md:137` "this is a refusal fence, **not credential hygiene or a secret-content scanner. Kagi retains credential operations.**"; `PROVINCE.md:90` "kagi-shokunin owns credential hygiene evidence; souji routes any credential-shaped finding to kagi" |
| 18 | tabi | `faee4cb27982388b18e9a45f292cdfb9dfd1ebc8` | **DEFER-TO-KAGI** | `PROVINCE.md:16` "secrets (→ kagi — session material is …)"; `.ufo/waves/round-23/w2/W2Secrets.md` is a security sweep of its own browser fixtures |
| 19 | tameshi | `f20ba482c7441d4c75818e7cd8a3165fee7821a1` | **DEFER-TO-KAGI** | `PROVINCE.md:18` "Credential material (→ kagi), endpoint health (→ kama)"; `corpus/knowledge/gates-survey-kagi.md` **surveys** kagi's gates read-only — it holds no scanner ground itself |
| 20 | tsukuroi | `2f3061ef725abebd8cd157b778203f1cf5c0cb0c` | **DEFER-TO-KAGI** | `PROVINCE.md:25` "secrets (→ kagi)"; `PROVINCE.md:47` ADJ-02 routes a "credential-bearing helper" question to kagi |

**Aggregate: 0 lanes claim the ground; 11 lanes explicitly defer it to kagi; 7 lanes hold only hygiene filters;
2 lanes (kasegi, revenger) hold the *epistemic pattern* on other objects (§3b).**

---

## 3. Why the three tripwire lanes do not contest the three adopted entries

The round-21 lesson recorded the adjacency as "chousa/kasegi/kumitate hygiene tripwires"
(`corpus/lessons/round-21.md:42`). Re-verified at current tips, and the reason is now precise.

### 3a. chousa — a shape classifier over its own artifacts, not a scanner

`chousa-shokunin/tools/research-gate.sh:1069` defines `scan_secrets()`; `:1087` emits
`emit_finding SECRET_SHAPED crit secrecy "path=$file:$lineno class=$class"`. The classes are a fixed regex
list: `op://`, `Bearer <8+>`, `sk-<10+>`, `ghp_<20+>`, `github_pat_<10+>`, `AKIA<12+>`, OPENSSH/PRIVATE KEY
headers, `server.token=`, `api[_-]?key=`, `password=`. Call sites are `:1260`, `:2058`, `:2548`, `:2846`, `:3104`
— chousa's own `record` and `claims` files.

Three reasons it does not contest C3:
1. **Subject**: it matches secret-*shaped* strings in chousa's own corpus files. It never asks whether a
   credential works, and it has no notion of a scan report, a finding status, or a verdict.
2. **Object of study**: chousa studies *source-research method* (`PROVINCE.md:3` "the reusable craft of source
   research"). A secret-shape regex list is hygiene for its own records, not a curriculum claim about how
   scanners behave.
3. **Its own recorded limit agrees**: `corpus/knowledge/verification-r16.md:35` names the gap as **named debt** —
   "Secret scan doesn't cover cited local source files (scan_secrets runs on record+claims, not resolved source
   paths)". A lane that records its scanner's blind spot as debt is not claiming scanner ground.

### 3b. kasegi and revenger — the *pattern* is already held elsewhere, on other objects

These two lanes are the nearest cousins, and the L1 should know them before landing C3:

- `revenger-shokunin/corpus/SOURCES.md:335` (S320, FwHunt Community Scanner README) +
  `corpus/knowledge/round-73-re-resource-atlas.md:301`: *"A rule match on a UEFI module is a detection lead tied
  to a rule ID. Record the rule revision, not just 'vulnerable'. A rule hit does not confirm a vulnerability."*
- `kasegi-shokunin/corpus/knowledge/openssf-scorecard-checks.md:54`: *"a Critical-tier failing check is not
  evidence of compromise — the tier is the program's impact prior, not a finding about a specific project"*;
  and `:7` of `ai-assisted-finding-validation.md`: *"Treat an AI-originated finding as a candidate, not a
  confirmed vulnerability…"*.

Under QA7's own wording — *"the entry restates another lane's mechanism (endpoints, prompts, scanning tooling)"* —
these are **not** restated by the C3 entries: the objects differ (UEFI firmware rules; repository security-health
scoring; AI-generated vulnerability findings vs **credential findings**), the tools differ (FwHunt, Scorecard,
a bounty-package review vs Gitleaks/TruffleHog/Betterleaks), and the verbs differ (rule-ID attribution, risk
tier, evidence package vs scan/validation stage semantics). C3 is the fleet's first application of the
detection-vs-verification pattern to **credential scanning**; the pattern itself is not new to the fleet.

`kasegi`'s `corpus/knowledge/openssf-scorecard-checks.md` was checked against its own pinned capture
`corpus/source-snapshots/round-54/S086.txt`: the Scorecard check list is Binary-Artifacts … Webhooks
(SAST, Token-Permissions, SBOM …) and contains **no secret-scanning check** — kasegi holds repository-security
scoring, not credential-scanner semantics.

### 3c. kumitate — an explicit hand-off to kagi

`kumitate-shokunin/corpus/knowledge/kimi-binary-secrets.md:217-218` is the strongest single piece of
non-contest evidence in the fleet: it names token validity and credential schema **UNKNOWN** and states
"Full credential/minting anatomy belongs to the kagi lane, not here." `PROVINCE.md:30` routes MCP/OAuth security
practice to kasegi/kagi. Its `gitleaks` mentions (`SentReceipt.md:21`) are a proposed receipt-hygiene sweep it
declines to call a proof.

### 3d. kaidoku, kama, mado — same shape, same conclusion

All three mention `gitleaks`/`secret scan` only as a **sweep over their own working tree** (kaidoku
`CustodySafety.md:79`, kama `S03SecretScan.md`, mado `province-accuracy-selfaudit.md:235`) and all three route
credential ground to kagi (`mado/PROVINCE.md:14`, `kama/PROVINCE.md:42`, `kaidoku/PROVINCE.md:298`).

**Conclusion for §3**: no sibling holds secret-scanner detection/verification *ground*; the four adopted C3
sources (Gitleaks README, TruffleHog README, Betterleaks README + its repo-search response, four
trufflesecurity.com docs pages) are unclaimed by any sibling. C3's three entries are admissible under QA7.

---

## 4. Sibling scope statements that point *toward* kagi (evidence of non-contest)

Twelve lanes name kagi as the owner of credential/secret ground in their own committed `PROVINCE.md`:
chousa `:14` · kake `:44` · kama `:42` · kasegi `:48` · kotoba `:63` · kumitate `:30` + `kimi-binary-secrets.md:218` ·
mado `:14` · mori `:15`, `:68` · souji `:90`, `:137` · tabi `:16` · tameshi `:18` · tsukuroi `:25`, `:47`.

souji's is the most explicit: *"this is a refusal fence, not credential hygiene or a secret-content scanner.
Kagi retains credential operations."*

This is the mirror image of the round-21 sweep's finding (`corpus/lessons/round-21.md:42` and
`.ufo/reports/round-21/kagi.md:112` "connector sweep … — no sibling claims the new ground"): the round-21 sweep
found no sibling claim; this sweep finds the same absence **plus** a positive, current, committed deferral
mechanism in every lane that touches secrets at all.

---

## 5. Lane-internal overlap (not a sibling contest) — two items for the C3 Gate

### 5a. The fleet ART dossier already opened 2 of the 8 URLs — under different ids and anchors

`.ufo/waves/kaika-w1/kagi-art.md` (fleet repo, committed `f47ad6ba8d306f8125597401cb2ce45c1297a593`,
2026-10-25) is the round-21 ART dossier **for kagi itself**:

- `:172` `|S028|Gitleaks upstream README — https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md|code|A|Gitleaks scans Git history and directories, supports baselines and redaction, **and upstream says feature work has moved to Betterleaks.**|watch|2026-10-19|on-release|—|`
- `:173` `|S029|TruffleHog upstream README — …/trufflehog/main/README.md|code|A|…|watch|2026-10-19|on-release|—|`
- `:93` `### Candidate 5 — secret-scanning-detection-verification-and-response.md` — the falsifiable claim, the
  two quotes, the recheck and the quality gate.
- `:85` Candidate 4 = OIDC federation trust policy; `:101` Candidate 6 = NIST key-management draft status —
  the two sibling topics of this seat's mandate, likewise deferred.

These ART rows were **never landed** in the lane registry (no `S028`/`S029` gitleaks/trufflehog rows exist in
`kagi-shokunin/corpus/SOURCES.md`; the lane's `S028`/`S029` are `docs.python.org/…/html.html` and `curl.se/…/manpage.html`).
Round 21 deferred Candidate 5 to the Frontier because "sources not opened this round, so no row and no entry"
(`corpus/lessons/round-21.md:41-42`). C3 is the correct landing of that deferred candidate — **but the ART
dossier had already opened two of the same URLs on 2026-10-19**, and the 2026-10-19 date proves nothing now
(the plan says so explicitly). The peer re-grounding seat re-opened all 8 on 2026-11-03 and recorded the digest
movement in `.ufo/waves/round-30/final/c3/assimilation/drift-findings.md`; that satisfies the plan's
re-grounding requirement.

**Corroboration for the peer's finding §2** (Gitleaks' "feature complete → Betterleaks" statement missing from
the staged S053 scope): the same fact was already observed on 2026-10-19 and is recorded at
`.ufo/waves/kaika-w1/kagi-art.md:53` and `:172`. The in-repo evidence for adding it to S053's scope cell is
already there.

**No id collision, no duplicate URL, no census consequence.** The ART dossier lives in the fleet repo, not in
any lane registry; the lane's `SOURCES.md` will hold 52 rows before C3 and 60 after; the 8 new URLs are absent
from every lane's registry (command 9/10) and absent from the lane's own registry
(`grep -cF <url> corpus/SOURCES.md` → 0 for all 8). Fleet census W04 ("same URL across scopes") is therefore
not armed by C3.

### 5b. The staged entry mischaracterises the lane's own S048 — flag for the C3 Gate

`merge/kagi/knowledge/corpus/knowledge/secret-scanning-detection-vs-validation.md:68-69` reads:

> "It does not extend to GitHub's own secret-scanning product, whose validity-check semantics the lane already
> holds as a **prose-absent lead (row S048)**."

Against the lane's actual registry at BASE, S048 is **not a lead**:
`kagi-shokunin/corpus/SOURCES.md:55` — `| S048 | Secret scanning, GitHub concepts — https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning | docs | A | GitHub Secret Protection's distinction between automatic secret detection and opt-in validity checks; GitHub only, concept level, no scanner-independent verification semantics | §Customizability → About validity checks (#about-validity-checks); H1 Secret scanning; no displayed version/date; requested /introduction/about-secret-scanning 301s here; opened 2026-10-21 | Detection and verification are separate steps: a detected secret is a candidate, and validity checks (opt-in) verify whether it is still active… | **mined** | 2026-10-21 | **90d** | corpus/lessons/round-28.md |`

Status `mined` (not `queued`), a located quote, a 90d recheck, `used-by corpus/lessons/round-28.md`, and the
row's `teaches` cell already states the detection-vs-validity distinction. It was ADMITted in
`corpus/lessons/round-28.md:35` ("ADMIT tier A docs, 90d, frontier lead (detection versus verification); GitHub
only, no scanner-independent semantics"). Only the *knowledge-entry* half is absent (`grep -rl S048
corpus/knowledge/` → 0 files), which is what "prose-absent" may intend; but the words "lead" and "row S048"
together misdescribe a mined row whose teaching is already registered.

**Recommended wording for the re-grounded entry** (L1's call, QA3/QA6/QA10 adjacency): "…whose
validity-check semantics the lane already holds as the mined row **S048** (GitHub-only, concept level, no
scanner-independent semantics)." This keeps the substantive limitation (C3 does not extend to GitHub's product)
and drops the false status claim. It also makes the entry's own "does not establish" list accurate about the
lane it lands in.

---

## 6. False positives explicitly cleared (so nobody re-litigates them)

| hit | file:line | why it is not the ground |
|---|---|---|
| kengaku "key management" | `corpus/SOURCES.md:233` | OpenSSL key management **as a benchmark grader surface** (Terminal-Bench `openssl-selfsigned-cert` task) — no NIST guidance, no registry claim about key-management standards |
| mado "KMS roles" | `corpus/SOURCES.md:20` | **Wayland/DRM graphics KMS** roles (drm/kms), in a compositor protocol row — not Key Management Service |
| kotodama "kms" ×2 | `corpus/SOURCES.md` (S185 Silbo Gomero "2 or 3 kms"; museum "KMS7/KMS8/KMS9" catalogue IDs) | kilometres and collection record ids |
| tsukuroi "kms" ×4 | `corpus/knowledge/degraded-triage-r4.md:67,75`, `journal-boot-plane.md:245,433,436` | **initramfs `kms` kernel module** / `dkms`, in a boot-plane lesson |
| mori "Workload Identity Federation" | `corpus/evidence/recheck-r32/S049.src:4481` | a **navigation sidebar link inside a captured OWASP Logging cheat-sheet HTML**; mori's own S049 is `cheatsheetseries.owasp.org/…/Logging_Cheat_Sheet.html` (`corpus/SOURCES.md:55`) — log data-class treatment, not federation trust policy |
| tabi "OpenID" / "wif" | `corpus/evidence/round-13/aria/node_modules/playwright-core/…` | vendored Playwright JS bundle strings |
| kotodama "federation" | `corpus/SOURCES.md:107,150,727,907` | World Federation of the Deaf / World Lacrosse |
| chousa "federations" | `corpus/knowledge/archives-verified-r9.md:166,227` | sign-language archive exports |

`mori`, `tabi` and `kotodama` hold **no** NIST SP 800-57/800-133 row and **no** OIDC-federation row
(`grep -rIn -E '800-57|800-133'` → 0 hits across all 20 lanes' corpora).

---

## 7. What C3 must do with this (no action required of this seat)

1. **C3's coverage claim is unopposed.** No sibling contests the three entries; no sibling cites any of the 8
   URLs; QA7 lane-fit is satisfied. The C3 Gate can record "no sibling claims the ground; 11 lanes defer it to
   kagi; the only sibling-held scanners are hygiene filters over their own artifacts."
2. **Cite the deferral mechanism in the lesson** (it is the strongest, cheapest QA7 evidence): souji
   `PROVINCE.md:137`, kumitate `kimi-binary-secrets.md:218`, plus the 12-lane deferral list in §4.
3. **Adopt §3b/§5a corrections** (L1's edit, not this seat's): the ART dossier's Gitleaks maintenance-status
   fact (`.ufo/waves/kaika-w1/kagi-art.md:53`, `:172`) corroborates the peer's drift finding; and the staged
   entry's "prose-absent lead (row S048)" wording should be corrected to "mined row S048".
4. **Do not cite the sibling tripwires as sources.** They are the lane's own hygiene machinery; no S-row may
   cite them, and no sibling lane may be reported as holding the adopted ground.

## 8. Not checked / limits of this seat

- Sibling **wave-internal** artifacts (`.ufo/waves/**`) were read only where they name a scanner on the record
  (kaidoku, kama, kasegi, kumitate). A sibling's untracked scratch could contain anything; the claim is about
  **committed** corpus/province surfaces, which is what QA7 asks about.
- No sibling's `corpus/source-snapshots/**` captures were opened beyond the one Scorecard capture needed to
  test whether kasegi holds a secret-scanning check (§3b). A capture could contain a scanner page the row does
  not teach; that would not be a *claim*.
- No network fetch was performed; every statement above is about **committed bytes at the tips in §2**.
- The fleet-level non-lane trees (`.ufo/`, `MANIFEST.json`, `scripts/`) were swept for the 8 URLs; the only hit
  is the kaika-w1 dossier in §5a. `MANIFEST.json` contains the two tool names only inside unrelated
  recheck prose.

**Tools**: no installation was performed or needed. `gitleaks 8.30.1` was observed at
`/home/vgpnk/.local/bin/gitleaks` (pre-existing, not installed by this seat, not executed by this seat).
`op` was not invoked at any level. No pacman transaction was attempted (host-wide pacman is paused).

`13 rows of evidence · 20 sibling lanes · 0 contests · 0 sibling citations of the 8 URLs · 2 lane-internal items flagged`
