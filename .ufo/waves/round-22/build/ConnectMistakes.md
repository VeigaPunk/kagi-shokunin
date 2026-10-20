# ConnectMistakes — round 22

Axes: calibration, freshness. One move. No production edit. No install.

## Read revision

- Frozen and observed `HEAD`: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
- Committed registry at that revision: `corpus/SOURCES.md` S001–S016; `corpus/QUALITY.md` ends at the locator note (QA9, QM12 present; no QA10/QM13/QM14).
- Dirty, not this seat, excluded from the frozen reading: `corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`. Untracked: `corpus/lessons/round-22.md`, `plans/round-22.md`.
- Stamp comparison below is `git show HEAD:<path>` against `HEAD:corpus/stamps.tsv`.

## Evidence

Round-21 outside disagreement is already on the bar the entries failed.

- `corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication: W3ReviewKagi disagrees with E1 (eligibility omitted; GitHub Actions public preview conflated with custom-OIDC beta) and E3 (one product’s docs stretched to the other). Debt text asks for a new criterion plus an E1 status erratum, and for append-only treatment of in-place `claim-ledger.tsv` rewrites and nine deleted `stamps.tsv` lines, plus five stale stamps.
- `corpus/QUALITY.md:21` QA2 already requires preview and Enterprise-only status in the sentence that uses them. `corpus/QUALITY.md:59` QA9 already requires product, path, plan/eligibility, and per-feature release status; a part with no source is withdrawn; the weak signal is a guide-level preview applied to every workflow, and “never expires” where the page says the store issues no lease.
- Committed E1 erratum (`corpus/knowledge/onepassword-machine-credentials.md:34-35`, stamp MATCH at HEAD) records EPM Business eligibility and leaves custom-OIDC status unverified because the feature sub-page was not opened. Item 4 at line 16 still states one public-preview label. Committed E3 erratum (`vault-openbao-token-lease-lifecycle.md:107-110`, stamp MATCH) withdraws the merged labels while lines 17, 18, and 20 still carry them.
- Fleet `.ufo/waves/kaika-w3/kagi-review.md:100` recommends a new QA10 (“an erratum does not repair a body sentence”). The same review at `:124` (D1) says QA9’s weak-signal list already names that pattern. `:126` (D3) says QM12’s skipped-row id list was not written. `:91` and `:125` (D2) reject calibration-by-row-count (`awk` of `Q[AM]` rows → 21).
- Fleet `.ufo/waves/kaika-w3/kagi-critic.md:15-27` asks for a feature-specific status-link criterion and an appended E1 distinction. It quotes S006 §New in this release (announcement dated 2026-07-28; critic reopened the page): “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” This seat did not re-fetch that page. S006’s committed anchor is §How it works and §Try today (`corpus/SOURCES.md:12`), so that heading was outside the recorded anchor on a URL the row already cites.
- `LEARNING.md:20-21` adds a criterion when no criterion caught the mistake. `LEARNING.md:35` says a disagreement becomes a lesson that adds a criterion. Those two sentences are not the same rule.
- QM5 (`corpus/QUALITY.md:43`) still requires a same-commit stamp and treats byte lag as a defect. QM12 (`corpus/QUALITY.md:60`) supersedes only the “`verify` before commit” clause. D3 shows that substitute is unmet: no skipped-row id list.

The nine “dropped stamps” are nine replaced lines. Path membership dropped by zero.

`git show aea7a4301:corpus/stamps.tsv` versus `git show e1544c194:corpus/stamps.tsv`: `dropped_paths=0`, `added_paths=7`, `changed_lines=9`.

| path | old sha12, lines, bytes | new sha12, lines, bytes |
|---|---|---|
| `corpus/claim-ledger.tsv` | `c8369a51869b`, 49, 13981 | `8a4019cfc1ee`, 54, 16986 |
| `corpus/knowledge/op-ref-consumption.md` | `dcd9389415ef`, 307, 21164 | `b195cc69840b`, 372, 25290 |
| `corpus/op-ref-probe.sh` | `509f084ad332`, 660, 28660 | `0f1945e8d8a8`, 788, 34362 |
| `corpus/README.md` | `6ddda47d8bab`, 86, 18689 | `6837d22b1e14`, 118, 22365 |
| `LOG.md` | `e6db90d2a37c`, 762, 56847 | `60a8fd366c83`, 1043, 74864 |
| `PROVINCE.md` | `ffe644a7b2ce`, 53, 8172 | `4a346e2df81f`, 62, 10586 |
| `SCORECARD.md` | `f3e61bfe2e78`, 446, 66069 | `29f9f0231f2f`, 691, 87010 |
| `SHONEN.md` | `efe81fa75cc1`, 11, 4695 | `1bb89fc5c006`, 12, 1312 |
| `SKILL.md` | `c2b3151c58dd`, 663, 57062 | `df05677fe0dc`, 665, 58395 |

Expectation migrations in the same range, same id kept, expected field rewritten (`corpus/claim-ledger.tsv` field 3):

| id | old expected | new expected |
|---|---|---|
| R12-02 | `^OP_REF_SELFTEST: PASS \(29 cases\)` | `^OP_REF_SELFTEST: PASS \(36 cases\)` |
| R12-03 | `^56$` | `^63$` |
| R13-01 | `^20$` | `^23$` |
| R14-01 | `entries=21 row_linked=18` | `entries=24 row_linked=21` |

R21-01..R21-04 are additions. R13-02’s expected field is unchanged; the note text moved.

Six committed mismatches at `c2cab35` (sha, newline count, and byte count all differ). The outside review’s five did not include `LOG.md`, which moved after `e1544c194` in `584dd67` and `c2cab35` (`git diff --numstat e1544c194 HEAD -- LOG.md` → `7 0`).

| path | stamp lines/bytes/sha12 | HEAD lines/bytes/sha12 |
|---|---|---|
| `corpus/knowledge/config-layering.md` | 109/6621/`848b8e502ea2` | 136/8088/`9d4ac8c24981` |
| `corpus/knowledge/handler-on-disk-state.md` | 247/17609/`811572dcf630` | 277/19329/`df6a5e5d05f4` |
| `corpus/knowledge/handler-trust-boundary.md` | 285/17669/`263c7b0e734c` | 316/19410/`fa17fff38dfb` |
| `corpus/knowledge/janitor-env-contract.md` | 90/5111/`88dca63ac7e6` | 113/6372/`dac43ef97393` |
| `corpus/lessons/round-18.md` | 73/4216/`614335f2a8cb` | 80/4557/`b00b7dd8d5b2` |
| `LOG.md` | 1043/74864/`60a8fd366c83` | 1050/75404/`51e76cf1f69f` |

E1, E3, E2, `QUALITY.md`, and `SOURCES.md` MATCH their stamps at HEAD. The dirty E1/E3/QUALITY/SOURCES bytes are drafts; committing them without a journaled stamp tuple repeats the nine-line replacement.

Working-tree `corpus/QUALITY.md` appends QA10, QM13, and QM14. Untracked `corpus/lessons/round-22.md` M22-1 already lists captured-by-before as QA9, then adds QA10. M22-3 says restore dropped stamp membership. `plans/round-22.md` says the same restore, and also says count decisions rather than authored rows.

## Contradiction

- Reviewer QA10 rewrites the failing sentence. Draft QA10 keeps the rejected reading and appends. Append-only corpus practice and the MATCH stamps on E1/E3 agree with the draft’s preservation half. QA2/QA9 already judge the body sentence, which is the reviewer’s substantive half.
- `LEARNING.md:35` asks for a new criterion id. `LEARNING.md:20-21` asks for one only when none caught the class. QA2 and QA9 caught E1/E3. The missed act was applying them to S006’s unanchored heading and the feature URL.
- QM5’s “lag is a defect, not inherited debt” was carried out as nine in-place line replacements. The five (now six) lags were left, which is the review the lesson required. Restoring the nine old hashes into current `stamps.tsv` would make nine matching pins stale again.
- QM13’s text forbids counting new criterion rows. Landing QM13 is that count.

## Proposed move

Land no new QUALITY id. Keep QA2, QA9, QM5, and QM12 as the rules.

C1 (calibration): adjudicate decisions, and record the tallies. Reject the committed E1 item-4 sentence for missing eligibility and for one preview label across Actions and custom OIDC. Reject the committed E3 clock rows that still say “IdP, Kubernetes”, “Vault/OpenBao”, and “nothing expires”. Admit a control only when each feature’s status, plan, and product has its own cited heading. The dirty S017–S020 rows are that source supersession; they supplement S006/S007 and leave those rows’ immutable fields in place. `captured-by` for this disagreement is QA9 (eligibility and in-sentence status also QA2). The calibration count is those decisions’ correct/incorrect outcomes. It is not `awk` of `Q[AM]` rows.

C2 (freshness): write an append-only migration journal, not a membership restore. Quote the nine old→new stamp tuples and the four expectation old→new strings above. Leave the six committed mismatches as mismatches until a reviewed content pass; do not restamp them to clear the detector. When a later commit appends to a MATCH-stamped file, update that stamp in the same commit and append the previous tuple to the journal. QM12 stays the verify substitute: list skipped ledger ids and the reason. A fresh hash does not make a historic sentence current.

## Affected axes

- Calibration improves: the known overclaims stay failures under QA2/QA9, and the score is decision outcomes. A new QA10/QM13/QM14 trio would repeat the round-21 row-count proxy.
- Freshness improves: the nine replacements stay visible as history, and the six lags stay visible as lags. Restoring old hashes, or deleting them again without the journal, is the harm avoided.
- Neither axis asks for a body rewrite of E1/E3. An appended erratum plus a journaled same-commit stamp is the lawful pair. Rewriting lines 16 and 17–20 in place changes pinned bytes and hides the sentence the outside review disagreed with.

## Risks

- A reader who applies `LEARNING.md:35` alone can call discernment harmed while the lesson’s `captured-by` cell says QA9. The lesson row has to cite both LEARNING sentences and the D1 statement that QA9 already names the pattern.
- Dirty S017–S020 and the E1/E3 draft errata are sibling work. This seat did not re-open the URLs. If those quotes fail a parent re-fetch, the admit control fails with them; the reject decisions on the committed sentences still stand.
- Journaling without the QM12 id list leaves the verify substitute unmet. The journal does not close D3.

## Verification for the parent

Read-only checks already run here: stamp membership diff `aea7a4301`..`e1544c194`; HEAD blob versus stamp for the six stale paths and the five MATCH controls; ledger field diff for R12-02, R12-03, R13-01, R14-01.

After integration, re-run that membership diff and the six-path sha/line/byte compare. Confirm `corpus/QUALITY.md` still has no QA10, QM13, or QM14. Count C1 from the gate’s decision ids (known rejects plus bounded admits), not from criterion-row cardinality. Confirm the journal quotes the nine tuples and four expectation pairs, and that `stamps.tsv` path set did not regain the old hashes. List QM12 skipped ids before any `verify` claim. Skip host-private gates.

## Limits

Local corpus and the fleet kaika-w3 kagi review/critic only. No live vault, account, or page fetch. No package install. Sibling dirty files were read as drafts and are not the frozen base.
