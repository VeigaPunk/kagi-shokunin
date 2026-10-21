# AttackEntry12 — falsification of integrated C2 for `corpus/knowledge/janitor-command-surface.md`

Axes: freshness (primary), calibration. Wave: kagi-r22 falsify, fresh attack of the integrated tree.
Read revisions, all observed this session 2026-10-20:

- Landing/HEAD/master: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` ("round-22: feature-bound review capability and audited revision repairs"). `git rev-parse HEAD` = `master` = this hash; working tree clean for the entry and `corpus/stamps.tsv` (`git status --porcelain` empty).
- Historical BEFORE base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (git blob read, not the falsification input).
- Freeze authority: `.ufo/waves/round-22/integration-manifest.json`.

## Verdict

**ADMISSIBLE.** The integrated C2 handling of this entry survives attack: the pre-existing 88 lines are byte-identical to the frozen-before blob (pure append proven), the stamp row moved atomically with the append and its old/new tuples are preserved in committed migration evidence, pointer freshness is cleanly distinguished from the unavailable source facts, and the appended erratum marks every present-tense reading as historical without deletion, rewrite, or restamp-as-revalidation. No blocking defect found.

## Byte comparison (observed)

| artifact | sha256 | lines/bytes | match against |
|---|---|---|---|
| base blob `git show c2cab35:corpus/knowledge/janitor-command-surface.md` | `4d447b25ffb49c85ef845da47bb2df92131c3fc55d5df4da7a0fd52cccaf16dc` | 88 / 5764 | frozen/before/corpus/stamps.tsv row; build/Entry12.md observed triple — identical |
| working tree `corpus/knowledge/janitor-command-surface.md` | `69cb9c8859c35b92dea656254eeb7a670e69d20ea2c5cf1327ae7f7ad7d61456` | 99 / 6386 | integration-manifest input hash; current stamps.tsv row — identical |
| `corpus/stamps.tsv` (current) | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 / 7213 | manifest hash — identical |
| `corpus/claim-ledger.tsv` (current) | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 / 17770 | manifest hash — identical |
| `corpus/drift-baseline.tsv` (pre-loss source pins) | `90c2d7a52360e97201b6fb766cd8f26fc653daa2a38bcefc40edcac6576c1bda` | 15 / 1341 | identical on both sides — untouched, as required |

**Unchanged prefix proven.** `diff <(git show c2cab35:…) <working tree>` reports exactly `88a89,99` — an 11-line append (blank separator + `## Erratum (round 22 — historical source boundary)` block), zero deleted or modified lines. The base blob's tail ends `…rather than hanging (health timeout 2 s).\n`, which is line 88 of the current file. The landed erratum text is NOT the block proposed in build/Entry12.md; build artifacts are advisory, the measured landing and manifest are authoritative, and the landed text is the manifest-pinned one.

## Stamp record (C2 accounting)

- Before row (frozen/before/corpus/stamps.tsv): `corpus/knowledge/janitor-command-surface.md → 4d447b25… / 88 / 5764`.
- Current row (corpus/stamps.tsv, exactly one row for the path): `… → 69cb9c88… / 99 / 6386`.
- Migration evidence: `pin-migrations-integration.json` lines 226–236 carry both exact old/new tuples plus `base_observed` and disposition "Reviewed current round-22 artifact; historical source facts remain historical. See round-22 lesson and named per-entry audit." `old_members` 63 → `new_members` 69, `removed_members: []` — my path is one of the 38 stamp *changes*, not an add or drop. The six added members are the two new Python tools, feature-claims JSON, the corrected review entry, the round-22 lesson and the round-21 spotcheck, matching ledger row R12-03 (expectation migrated `^63$`→`^69$` with the documented ladder; measured 69 rows).
- `historical-correction-pins.json` does not mention this path — correct, since it covers only the later post-landing span; the full old/new record for this entry lives in `pin-migrations-integration.json`.
- Ledger rows R11-02/R11-04 (the entry's `Reverify:` targets) are textually unchanged from the before snapshot and still carry `[substrate]`; `grep -c '\[substrate\]'` = 11, matching migrated R18-02 `^11$`.

## Pointer freshness vs unavailable source facts

- Pointer integrity is FRESH: entry bytes == manifest pin == stamps.tsv pin == HEAD blob; stamps.tsv/claim-ledger.tsv byte-hash to their manifest values; nothing was inferred from a mid-build report.
- Source facts remain UNAVAILABLE: fresh read-only stat probes this session — `$HOME/.local/bin/the-janitor` absent, `~/.config/the-janitor/` absent, `~/.local/state/the-janitor/` absent (all `test -e` → exit 1). `corpus/knowledge/substrate-deferral.md` records the round-18 absence census and its round-22 erratum re-marks its own historical counters. The entry's two recheck rows therefore defer (`DEFER reason=substrate-absent` semantics), they do not confirm; the new stamp pins the document's bytes, never the handler's currentness.

## Erratum sufficiency (no laundering)

Every false reading the original carried — present-tense source line counts, verb/failure/HTTP/status tables, and the four falsifier recipes — falls under the appended `Source-status: historical` mark plus the explicit statements that the substrate is absent since round 18, the recheck rows declare deferred work, and recipes require restoring the authorized source first. Nothing above the erratum changed; exactly one `Reverify:` declaration remains (line 8, unchanged); no new declaration, heading claim, or source-token was introduced; the audit pointer `.ufo/waves/round-22/build/Entry12.md` exists and matches this seat's build report. The old stamp triple is not restated inline in the landed erratum (a deviation from Entry12's proposed text), but it remains visible in three committed places: the frozen before snapshot, `pin-migrations-integration.json:227-234`, and the base git blob — the stamp move is documented, not silent.

## Findings by severity

| severity | finding | evidence |
|---|---|---|
| none (blocking) | — | — |
| informational | Landed erratum is a shorter text than build/Entry12.md proposed; Entry12's requirement that the historical triple appear *inside the appended text* is met only via external committed evidence (migrations JSON, before snapshot, git history). Substance of QM5/QM14 (same-commit re-pin, old/new preserved) holds. | diff `88a89,99`; pin-migrations-integration.json:227-236 |
| informational | Erratum omits the pre-loss source pins (`2408b0c9…`/`8179b241…`); they survive only in `corpus/drift-baseline.tsv` (byte-identical both sides — correctly not re-pinned to the empty host) and build/Entry12.md. | drift-baseline.tsv hash equal before/current |
| informational | "this round did not execute the handler" is an author attestation; consistent with all evidence and with the substrate's absence making execution impossible — `[INFERENCE]`, not independently provable. | probes above; no contrary record |

## Limits

No corpus gate executed (boundary: no host gates; assigned fixture runs do not include this seat's entry — nothing here to execute without the substrate). Absence probes are point-in-time stats. `.ufo` wave artifacts are not manifest-frozen; contents named as read at HEAD `8ada17a5` this session. No installations (none needed).

## Checks the parent should run after this wave

- The single global revision-audit rerun (parent duty): for this path expect changed-not-added with the exact old/new tuples above, stale=0, dropped=0.
- `bash corpus/claim-ledger.sh docs corpus/knowledge` → `DOC_AUDIT: CLEAN` (single-declaration rule).
- `bash corpus/claim-ledger.sh citations --docs corpus/knowledge/janitor-command-surface.md` → labeled count unchanged.
- `bash corpus/claim-ledger.sh cells` → the entry's stamp pointer resolves to `69cb9c88…/99/6386`.
- Do NOT accept `drift-pins.sh` or `surface-census.sh --verbs` output as entry verification: they defer or fail by design while the substrate is absent.

## Report

`.ufo/waves/round-22/falsify/AttackEntry12.md` (this file), written at landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. No production file touched.
