# AttackEntry05 — falsification of integrated C2 for `corpus/knowledge/claim-ledger.md`

Seat: `KagiR22.AttackEntry05` (falsify reviewer, leaf — no subagent dispatch). Axes: **calibration**, **freshness**.
Milestone: Falsify integrated feature decisions and revision accounting.
Read revision (integration landing): `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` ("round-22: feature-bound review capability and audited revision repairs"); historical BEFORE base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Wave date: 2026-10-20. No host gate executed; no install or update performed; no production file written. Observed tree hashes recorded below per freeze rule; working tree observed CLEAN for both audited paths (`git status --porcelain` empty for `corpus/knowledge/claim-ledger.md` and `corpus/stamps.tsv`).

## Verdict (one admissibility verdict)

**ADMIT.** The integrated change to this entry is an append-only, restamped, migration-documented correction that marks every identified false reading of the reproduction block without laundering; the residual is a bounded, indirectly-marked pair of provenance overclaims inherited from the unchanged prefix (low severity, explicitly pointed at the named audit). No silent deletion, no laundering, no pointer/source-fact conflation observed.

## 1. Byte identity — frozen input, current bytes, stamp record

| Artifact | sha256 (12) | lines | bytes | Check |
|---|---|---|---|---|
| Integration-manifest frozen input (`.ufo/waves/round-22/integration-manifest.json` → `corpus/knowledge/claim-ledger.md`) | `e914e2ac3f73` | 488 | 33222 | read from manifest JSON |
| Current working-tree bytes (`sha256sum`/`wc`) | `e914e2ac3f73…db22e49d734` | 488 | 33222 | exact match to manifest |
| Current `corpus/stamps.tsv` row 15 (stamp record) | `e914e2ac3f73` / 488 / 33222 | — | — | exact 4-field match to bytes |
| Historical BEFORE (`git show c2cab35…:corpus/knowledge/claim-ledger.md`) | `f1575725ccd8…664630` | 472 | 32297 | matches base `stamps.tsv` row 13 exactly |

- **Current == frozen attack input.** The integrated bytes are what I attacked; no mid-build snapshot was inferred.
- **Stamp record is fresh in both epochs**: base row 13 pinned `f1575725…`/472/32297 = base bytes; current row 15 pins `e914e2ac…`/488/33222 = current bytes. The entry was **never stale**; it was an authored round-22 correction plus same-commit restamp, not a staleness repair.
- **Frozen-before snapshot gap (finding, resolved):** `.ufo/waves/round-22/frozen/before/` contains `corpus/claim-ledger.tsv` (the claims TSV) and `expected.json` but **no copy of `corpus/knowledge/claim-ledger.md`** (nor of any knowledge `.md`). The historical BEFORE bytes are therefore taken from the `c2cab35` git object, which independently matches the base stamp row — consistent, not assumed. `frozen/before/expected.json` `expected_stale_original` lists exactly six stale paths at base (`config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md`, `lessons/round-18.md`, `LOG.md`) — **`claim-ledger.md` is not among them**, confirming fresh-at-base.

## 2. Unchanged prefix proven

`diff <(git show c2cab35:corpus/knowledge/claim-ledger.md) corpus/knowledge/claim-ledger.md` → single hunk **`472a473,488`** — pure addition, zero deleted/edited lines. Delta = +16 lines / +925 bytes = exactly the appended erratum block. The base file's final bytes end `…exit 2\n```\n` (od-checked): the append starts after the closing falsifier fence at line 472; base line 472 = current line 472. **Lines 1–472 are byte-identical to the frozen base.** All pre-existing content — including the unqualified `§Reproduction` transcript (§ at line 298, block 300–306) — is preserved verbatim as history.

## 3. Calibration: does the erratum mark every false reading?

Build-seat evidence `.ufo/waves/round-22/build/Entry05.md` (exists; the erratum's own audit pointer resolves to it) identified the defects; I recomputed the statically checkable ones at the base without running any gate: base claim rows = **39**, base stamp rows = **63** (both recomputed; Entry05's figures confirmed), selftest cases 97→108 and scored sections 22→24 base→current (recounted). Cells/verdict values were **not** re-executed (no gate authorization); they rest on Entry05's static derivation plus the shipped parser source.

| False reading in the unchanged prefix | Marked by the appended erratum? |
|---|---|
| `§Reproduction` presents exact round-13 tuple (`claims=17 stamped=33`, `cells=60`, `72 cases`) as if current | **Yes** — lines 476–478: "historical round-13 outputs, not current claim/stamp/selftest/cell totals. Read current totals from the executed gate, never from those sample verdicts." |
| `cells` verdict on line 303 not reproducible at base (refused exit 2 by blocked round-20 heading) | **Yes** — lines 482–484: blocked round-20 heading "preserved as history and excluded from scored sections by the round-22 parser correction"; shipped parser `corpus/claim-ledger.sh:678-680,722` has the exact `BLOCKED_ATTEMPT_RE` exclusion (static read). |
| Round-18 deferral shape (`DEFER <id>`, `deferred=`/`row_deferred=`) absent from quoted contract shapes | **Yes** — lines 479–481. Shipped gate prints `DEFER …reason=substrate-absent` (`:404`) and exposes `deferred=` (`:958`); static read confirms. |
| Active-TSV semantics (unique-ID/path current snapshots; migration evidence location; no duplicate-row history) | **Yes** — lines 485–487; consistent with the shrink guard (`claim-ledger.sh:261`) and lessons/round-22.md. |
| Round-11 wave blob `d63c60b0…`/ledger `3d6fe4ba…` absent from the object DB (lines 3–5, unlabelled provenance limit) | **Indirectly** — not named in the erratum text; the erratum's final line names the audit `build/Entry05.md` whose §2.4 documents it. Still historically referenced at `LOG.md:265`. |
| "every verdict string in this entry was produced by a command in the round-11 evidence set" (lines 7–9) overbroad vs round-13/14 classes | **Indirectly** — same audit pointer; Entry05 §2.4 records the narrowing. Each later class carries its own dated before→after table in the prefix itself. |

**No laundering:** the historic numbers are not edited in place; the false readings are marked by dated erratum, not erased; no claim is silently re-scoped. The erratum itself asserts nothing I could falsify statically (its parser and deferral statements check out against the shipped script).

## 4. Freshness: stamp record, migration documentation, deletion accounting

- **Same-commit coupling:** landing commit `8ada17a` is the only commit in `git log -- corpus/knowledge/claim-ledger.md` since base, and it changed both the entry and `corpus/stamps.tsv` (name-only diff `e1544c1..8ada17a` lists exactly those two of the audited paths). Append and restamp landed in one reviewed commit, satisfying the build report's preservation rule 3. No post-landing drift (working tree CLEAN).
- **Migration documented:** `.ufo/waves/round-22/pin-migrations-integration.json` records this exact path with `old_stamp` (`f1575725…`/472/32297), `base_observed` (matching the base blob) and `new_stamp` (`e914e2ac…`/488/33222), disposition: "Reviewed current round-22 artifact; historical source facts remain historical. See round-22 lesson and named per-entry audit." — the named audit is `build/Entry05.md`, which exists.
- **No silent deletion:** the stamps diff `c2cab35→HEAD` shows only in-place 4-field updates and added rows; zero removed paths. Membership grew 63→69 rows; claim rows 39→43; manifest `expected.revision_audit` = added 6 / dropped 0 / stale 0 is consistent with the observed direction of change (global rerun of the revision audit is parent duty; not executed here).
- **Pointer freshness ≠ source facts:** the restamp proves byte-pointer integrity only. Nothing in the entry or erratum promotes hash agreement into a claim about vendor source currentness; the erratum explicitly routes current totals to "the executed gate", and the corpus rule "byte hashes never promote absent source facts to current" (lessons/round-22.md, QM14) is respected. The unrepeatable round-11 wave hashes are labelled as wave-revision provenance in the audit, not reverified.

## 5. Findings by severity

- **None (blocking).**
- **Low — residual, pre-existing:** two unchanged-prefix provenance overclaims remain live without in-text marking: (a) unlabelled absent-object wave hashes at lines 3–5; (b) the "every verdict … round-11 evidence set" sentence at lines 7–9. Mitigation in place: the erratum's final line points every reader at `build/Entry05.md` §2.4, which documents both with evidence. Proposed correction (optional, parent's call): one further pure append naming the `d63c60b0…`/`3d6fe4ba…` objects as unverifiable provenance limits and narrowing the round-11 sentence to the round-11 classes; would require a same-commit restamp. Not an admission blocker: no measurement is fabricated, and the audit pointer is inside the appended text itself.
- **Note — coverage gap in the frozen-before snapshot:** `frozen/before/` does not carry `.md` knowledge snapshots, so BEFORE bytes for any knowledge entry can only come from git objects. Here the base stamp row independently corroborates the base blob, so the gap had no effect; it is a snapshot-construction limitation to know about, not an integrity defect of this round's evidence.

## 6. Limits

- No gate was executed (`verify`/`cells`/`citations`/`--selftest`); current totals cited are static recounts (stamp rows 69, claim rows 43, `tcase` count 108, scored sections 24), and verdict-shape claims rest on static reads of `corpus/claim-ledger.sh` plus the frozen evidence files. Parent may run the named execution checks once globally.
- Cells-axis completeness/vacuity preservation and the missing-axis cell audit are sibling seats' scope (RunCellsMissingAxis et al.); I only confirmed the parser exclusion lines exist as the erratum describes.
- `d63c60b0…`/`3d6fe4ba…` remain absent from this repository's object database (per Entry05 §2.4; not re-attacked here) — unavailable source facts, correctly kept out of current-pin claims.

## 7. Provenance

- Identity/counts: `sha256sum`, `wc -l`/`wc -c`, `git show <rev>:<path> | sha256sum`, `diff` (base blob vs working tree), `git status --porcelain` (both paths clean), `git log`/`git diff --name-only` for commit coupling.
- Stamp record: `corpus/stamps.tsv` rows 13 (base) and 15 (current); field semantics per `corpus/claim-ledger.sh` `stamp()`/shrink guard (`:261`).
- Evidence files read: `integration-manifest.json`, `frozen/before/expected.json`, `before.json` (stale list via `frozen/before/expected.json`), `pin-migrations-integration.json`, `build/Entry05.md`, `plans/round-22.md`, `corpus/lessons/round-22.md`, `falsify-dispatch.json` (exact task spec).
- No opencode, launcher, mise, npm/npx, package manager, loopback/health/CDP probe, host gate, vault/account/credential call, service, boot, or package transaction. No installs performed (nothing to record).

## Checks the parent may run after integration

1. `bash corpus/claim-ledger.sh verify` — expect `stale=0` for `corpus/knowledge/claim-ledger.md` (and globally consistent with manifest expectations).
2. `bash corpus/claim-ledger.sh --selftest` — expect 108 cases per manifest `ledger_selftest_cases`.
3. Global revision-audit rerun (parent duty, once) — expect added=6, dropped=0, stale=0.
