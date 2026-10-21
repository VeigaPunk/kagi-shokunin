# AttackEntry17 — falsification of integrated C2 for `corpus/knowledge/op-env-refs.md`

Seat: KagiR22.AttackEntry17 (leaf, falsify wave). Axes: calibration, freshness.
Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f`. Integration landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (verified as HEAD by `git rev-parse`; lane in detached HEAD, tip not inferred).
No production file was written; no host gate, launcher, package manager, or loopback probe was used; no vault/account/credential operation. Installs: none.

## 1. Verdict in one line

**ADMIT (bounded).** The integrated decision for this entry is correct: the frozen-before bytes survive byte-identical as a prefix, the only edit is an appended 14-line erratum that marks every false reading Entry17 identified without rewriting or deleting any original line, and the stamp re-pin is exactly the documented old→new pair with explicit separation of pointer freshness from unavailable source facts. No laundering found.

## 2. Byte evidence (frozen-before vs current vs landing)

| Artifact | sha256 | lines | bytes |
|---|---|---|---|
| Base blob `git show c2cab35b:corpus/knowledge/op-env-refs.md` | `6ca40a73286c038f7e431d84f2ba0fb55693dd1e217584eaafd1ec1dd2dbaf86` | 55 | 2693 |
| Frozen digest, integration-manifest.json `inputs["corpus/knowledge/op-env-refs.md"]` | `39b3b5419202e2ed18b270ce5dcf3aa23bb0e161b7786a67769fc8fa6853e911` | 69 | 3532 |
| Landing blob `git show 8ada17a:corpus/knowledge/op-env-refs.md` | `39b3b5419202e2ed18b270ce5dcf3aa23bb0e161b7786a67769fc8fa6853e911` | 69 | 3532 |
| Current worktree file | `39b3b5419202e2ed18b270ce5dcf3aa23bb0e161b7786a67769fc8fa6853e911` | 69 | 3532 |

- Frozen-before snapshot files under `frozen/before/corpus/` do not include this entry; its frozen-before identity is carried by the manifest/expected digests above, which I verified against both the landing blob and the live file — all three agree.
- **Unchanged prefix proved, not assumed:** `cmp` of the base blob against `head -c 2693` of the current file → `PREFIX-IDENTICAL`. The original 55 lines are byte-identical to the round-14 blob that Entry17 pinned (`2486643`, same hash family: `6ca40a73…` was also the base value; the round-14 blob equals the base blob). The edit is purely an append: +14 lines / +839 bytes.
- History is clean: only two commits ever touched this file after round-2 authoring lineage — `4b8c018` (round 13) and `2486643` (round 14), then the landing commit `8ada17a`. No intermediate rewrite, no deletion event.
- `git status --short` on `corpus/knowledge/op-env-refs.md`, `corpus/stamps.tsv`, `corpus/claim-ledger.tsv` is empty: the audited tree is exactly the landing state.

## 3. Stamp record and revision accounting (C2, exact evidence)

| | frozen-before row (`frozen/before/corpus/stamps.tsv:25`) | current row (`corpus/stamps.tsv:28`) |
|---|---|---|
| value | `corpus/knowledge/op-env-refs.md` TAB `6ca40a73…dbaf86` TAB `55` TAB `2693` | `corpus/knowledge/op-env-refs.md` TAB `39b3b541…e911` TAB `69` TAB `3532` |

- The old→new pair is recorded verbatim in `.ufo/waves/round-22/pin-migrations-integration.json` (path `corpus/knowledge/op-env-refs.md`, `base_observed` = base blob exactly, disposition: "Reviewed current round-22 artifact; historical source facts remain historical. See round-22 lesson and named per-entry audit.").
- Membership: first-column set difference base→landing gives **dropped = [] (zero)**, added = 6 (`feature-claims.json`, `feature-claims.py`, `feature-bound-credential-review.md`, `round-21-verifier-spotcheck.md`, `round-22.md`, `revision-audit.py`), 63 → 69 members, 38 existing rows re-pinned in place. No member was ever removed — the "nine dropped stamps" narrative stays correctly recorded as nine replaced diff lines (`removed_members: []` in both migration artifacts).
- **Migration record integrity, independently recomputed:** all 38 `stamp_changes` entries verified field-by-field against `git show` blobs of both revisions (old_stamp == base blob fingerprint, new_stamp == landing blob fingerprint, lines = `\n` count, bytes = exact length) — 38/38 OK, including the six added members.
- All 12 ledger claim migrations are itemized (`R11-09, R12-03, R13-01, R14-01, R18-02, R18-03, R21-02, R21-04, R22-01…R22-04`); `R12-03` carries its exact old row (`^63$`, round-21 prose) and new row (`^69$`, "count is not source freshness") — the old expectation was not silently overwritten.
- Executed read-only checks (owned local fixture, no mutation): `python3 corpus/revision-audit.py --history c2cab35b…` → `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0 — byte-identical to `integration-pin-check.json`'s recorded audit output; and `--selftest` → `PASS (cases=11 failed=0)`. Entry's own row therefore contributes **zero** stale/missing/dropped findings. (Global one-time rerun remains the parent's duty; my run was entry-scoped analysis only.)

## 4. Erratum coverage matrix — every Entry17 defect marked?

Entry17 (`.ufo/waves/round-22/build/Entry17.md`) identified defects B, C (reject), D (undetermined), I (missing trigger); A, E, F, G admitted as historical; H partial. The appended erratum (lines 57–69):

| Entry17 finding | Erratum marking | Status |
|---|---|---|
| B — "Secret bytes never live … only pointers" composition claim | "The “only pointers” composition statement … withdrawn: the recorded sibling evidence already distinguished reference-valued keys from plain identifier values" | **Marked.** Sibling basis re-verified by me: `janitor-env-contract.md:73-76` records the 8/2 split (8 `op://`, 2 raw identifier-class `XAI_TEAM_ID`, `TOKEN_PLAN_INFNET_IDENT`) at 2026-09-28, present in the base blob. |
| C — "Convention enforced by `cmd_refs`'s awk filter" | "…and “convention enforced” attribution … withdrawn: … an inventory filter does not enforce a writing policy." | **Marked.** |
| D — line range `L228–235` vs `L228–236` conflict | "The handler line-range disagreement remains unverified until authorized source restoration." | **Marked as unresolved — correctly not resolved by majority vote** (no laundering; no value silently picked). |
| I — missing `recheck:` trigger | "Recheck trigger: restored handler source and a CLI release change, using generated account-free fixtures rather than a real environment file." | **Marked.** Keyed to handler restoration (not op-release alone), fixture-scoped, no live env. |
| A/E/H — dated stat, failure modes, falsifiers as historical observations | "Source-status: historical — original file size/mode, line references, version and handler outcomes above are not remeasured current facts while the substrate is unavailable." | **Marked.** Blanket historical framing covers the falsification section too; no falsifier is claimed runnable. |
| Overreach guard | "This does not assert that a secret leaked." + "Audit: …build/Entry17.md." | **Present.** Provenance pointer recorded. |

Coverage: **every false reading marked, no original sentence rewritten, no claim promoted to current.** The erratum introduces no new `op://` literal (count 5 in base, 5 in current — E4's repo-wide `raw=5` expectation is not perturbed by this file; repo-wide E4 run remains a parent check) and no new redaction-class literal.

## 5. Pointer freshness vs unavailable source facts (the exact C2 distinction)

- Substrate absence re-verified directly: `~/.local/bin/the-janitor` and `~/.config/the-janitor/` both `No such file or directory`. So the `1078`/`0600`/mtime, the `L228–235`/`L237–249` spans, and the `run` exit strings **cannot be re-established** — and the erratum says precisely that instead of letting the fresh stamp imply currency.
- The stamp update proves local-byte identity only; the erratum, the migration disposition, and the reworded `R12-03` note all state this explicitly. Restamping did **not** launder historical claims into present-tense facts: the historical sentences remain untouched and are framed as historical by the appended section.
- `Reverify: R11-02, R11-04, R12-01` untouched; all three rows exist in `corpus/claim-ledger.tsv` (lines 16/18/26) with documented substrate/SETUP dependence — none is claimed green anywhere in the entry.

## 6. Integration-scope checks specific to this entry

- Entry17 §6 conditioned any regeneration: whole-set `stamp` is acceptable only if each of the six genuinely stale rows has its own old/new adjudication. Verified: `integration-pin-check.json` shows the regeneration ran (`STAMPED: n=69`), and all previously stale paths (`config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md`, `round-18.md`, `LOG.md`) appear in `stamp_changes` with exact old/new pairs and dispositions. Condition satisfied — regeneration was not used to launder.
- `checklist.tsv` row E4 untouched (same hash `28bd238e…` in frozen-before and live stamps).
- Landing commit contains exactly the 35 expected production paths (5 added + 30 modified), no unrelated file, no `.git`/state mutation, no deletion of any tracked member.

## 7. Admissibility verdict

**ADMIT — one bounded verdict for this entry's integrated decision.** The erratum + re-pin decision is feature-specific, append-only, migration-documented, and correctly separates pointer integrity (measured: prefix-identical bytes, exact old→new row, CLEAN audit) from source currentness (unavailable; explicitly not claimed). No false reading survives unmarked; no silent deletion; no expectation rewritten without its recorded old value.

## 8. Residual risks and verification gaps (not defects)

1. `cmd_refs` end line (235 vs 236) and `run` error ordering remain genuinely undetermined pending authorized handler-source restoration; the erratum records this instead of guessing — correct, but the unknown is live.
2. Whether `op.env`'s 8/2 key-class split moved after 2026-09-28 is unknowable on this host (file absent); the erratum correctly does not assert it.
3. I verified this file's contribution to E4 is delta-zero (5→5 `op://` literals); the repo-wide `REF_PATH_SCAN: hits=0 excluded=5 raw=5` execution itself was not run here and remains a parent check.
4. Parent duty stands: the single global revision-audit rerun and `bash corpus/claim-ledger.sh docs` (repo-structural, skipping host-bound rows `R11-02/R11-04/R12-01` per QM12) should be run once by the parent on the integrated tree.
