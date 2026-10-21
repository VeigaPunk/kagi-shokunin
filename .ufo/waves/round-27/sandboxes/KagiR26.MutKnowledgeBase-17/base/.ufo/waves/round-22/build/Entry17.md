# Entry17 — read-only freshness/calibration audit: `op-env-refs.md` + its stamp row

Seat: KagiR22.Entry17 (scout, read-only). Axes: calibration, freshness.
Frozen base read: `c2cab35bc92e57e39e5489bac3386db078345b3f`. No production file was written; no host gate was run; no live vault/account/credential operation; no install performed.

Working-tree state observed during the audit (not mine; sibling lanes were writing concurrently, recorded so revision claims stay exact). At first read: modified `corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; untracked `.ufo/waves/`, `corpus/lessons/round-22.md`, `plans/round-22.md`. At draft completion, additionally: modified `corpus/claim-ledger.sh` (edits at lines ≥669, so the cited comment lines 13–23 are unaffected) and untracked `corpus/knowledge/feature-bound-credential-review.md`. All byte measurements of the audited file and its stamp row are unaffected (both match the frozen-base blobs; see §2).

---

## 1. Verdict in one line

**The stamp row is byte-fresh, not stale.** The entry is **substantively stale in two bounded sentences (composition, enforcement) plus a missing `recheck:` trigger**, and its source is absent from this host, so no current-tense source claim can be re-established here. An **append-only erratum is needed**; it must not be a restamp-only edit.

## 2. Byte pin: fresh (high confidence)

| Artifact | Observed | Recorded (`corpus/stamps.tsv:25`) |
|---|---|---|
| `corpus/knowledge/op-env-refs.md` | `sha256 6ca40a73286c038f7e431d84f2ba0fb55693dd1e217584eaafd1ec1dd2dbaf86`; `wc -l` 55; `wc -c` 2693 | same hash; 55; 2693 |

Commands run (read-only): `sha256sum`, `wc -lc`, `grep -n op-env-refs corpus/stamps.tsv`, `git show 2486643:corpus/knowledge/op-env-refs.md | sha256sum`, `python3` set-comparison of all 63 rows.

- The row is a single row (line 25), no duplicate, and `corpus/stamps.tsv` has 63 non-blank rows (`grep -c '[^[:space:]]'` → 63), matching claim row `R12-03`'s current `^63$` expectation.
- Frozen-before ledger is identical to live: `sha256sum` of `.ufo/waves/round-22/frozen/before/corpus/stamps.tsv` and `corpus/stamps.tsv` both `0ce7fa4f…e5b`; the frozen row for this path is the same four fields.
- No working-tree drift: `git diff --stat HEAD -- corpus/knowledge/op-env-refs.md corpus/stamps.tsv` is empty, and `git status --short` on both paths is empty.

**Rejected overclaim (C1):** "the `op-env-refs` stamp is stale / one of the stale revision stamps." Recomputation falsifies it. Any report that asserts byte staleness for this entry is a false admission.

## 3. Row provenance (freshness axis, exact historic evidence)

| Revision | Blob sha256 of `corpus/knowledge/op-env-refs.md` | Stamp row state |
|---|---|---|
| `9b3e49f` (round-2 authoring) | `3fe7ae5dcaae7610896c9a50d0803def9045baa0a53f6ae9da95140ceff16b62` | no row yet |
| `4b8c018` (round-13) | `60cb3af0b2bfa082fedbc27b983bdc223554049fb23fae4a24ae020c3eacf71b` | not yet listed |
| `2486643` (round-14, 2026-09-28) | `6ca40a73…dbaf86` | row added with exactly this hash/55/2693 |
| `c2cab35b` (frozen base) | `6ca40a73…dbaf86` (unchanged) | row unchanged |

Evidence: `git log -S 'op-env-refs.md' --format='%h %ad %s' -- corpus/stamps.tsv` returns only `2486643`; `git show 2486643 -- corpus/knowledge/op-env-refs.md` shows the round-14 edit was the addition of the `Reverify:` line only. **No deletion, rewrite, or re-pin event exists for this path**; `round21-migrations.json` (`changed_stamp_records` = 9 paths, `removed_members` = []) does not name it.

## 4. Substantive freshness: partially stale (medium-high confidence)

Claim-by-claim adjudication against the corpus at the same frozen base. "Host" = `~/.local/bin/the-janitor` and `~/.config/the-janitor/op.env`, both absent now (§5).

| # | Claim (line) | Evidence | Decision |
|---|---|---|---|
| A | Source basis and stat are 2026-09-28 observations (3–6, 18) | Dated in text; past-tense "File observed"; no hash prefix is asserted (so this is not the round-19 `af8873ca…` defect class) | **ADMIT as a dated historical control** for the stat line. The defect is entry-level and mechanism-level voice, not this sentence. |
| B | "Secret bytes never live in the file — only pointers into the vault" (15–16) | Contradicted for the composition half: `corpus/knowledge/janitor-env-contract.md:73-76` records, from 2026-09-28 on the same host, **8 of 10 keys hold `op://` refs, 2 hold raw identifier-class values** (the two are named in `janitor-env-contract.md:74-75`, described there as "identifier-class, not secrets"). That text is present in the stamped round-14 blob (`git show 2486643:corpus/knowledge/janitor-env-contract.md`, line 74) as well as current bytes. The target itself says contents were not read (5–6) | **REJECT "only pointers"** as an observation; it was never measured by this entry and is falsified by a sibling measured record. **"Secret bytes never live" remains unestablished expectation**, not a fact (QA6 negative without a sweep; QA3 widening). Bound the correction to this, not to "secrets leak". |
| C | "Convention enforced by `cmd_refs`'s awk filter" (12–13) | A filter that prints matching lines cannot enforce; `op-ref-consumption.md` §2 shows `export K=`, spaced, indented and lowercase lines bypass `refs`, and `janitor-env-contract.md:76` states the convention is "aspirational, not enforced" | **REJECT the enforcement attribution.** Keep "recognised/presented by", not "enforced". |
| D | `cmd_refs` is `L228–235` (3) | Internal corpus conflict: `op-ref-consumption.md:4` says `L228–236`; `janitor-command-surface.md:19` says `L228–235`; both date to 2026-09-28; host absent | **UNDETERMINED.** Do not change to either value without source restoration. Record the conflict; changing it on majority vote would be laundering. |
| E | `run` failure modes and exits (33–36) | Values are consistent with `janitor-env-contract.md:82-90`, including env-file check preceding missing-command check; none was re-run in this round (host absent) | **ADMIT as 2026-09-28 observations**; must carry that measurement context (QM2), not "current behaviour". |
| F | `refs` prints `KEY=op://…` verbatim or `KEY=<redacted-non-op-value>`; no `op` call (25) | Matches `op-ref-consumption.md` §1/§2 (quoted `"op://…"` is additionally reported as non-ref; not a contradiction, a coverage gap) | **ADMIT.** |
| G | Checklist item 1, `^[A-Z][A-Z0-9_]*=` gating and `0600` (40–45) | Matches `op-ref-consumption.md` §2 rows; `drift-baseline.tsv` still records `op.env` mode `600`, 17 lines | **ADMIT** (mode/line count are historical expectations of an absent file; see §5). |
| H | Falsification items (53–55) | Not runnable now; item 1 is a restatement of the implementation ("output format matches the awk line"), not an observation that could call the entry wrong | **PARTIALLY ADMIT**: items 2–3 are real behavioural falsifiers, currently SETUP-blocked; item 1 is not a falsifier of the world. |
| I | No `recheck:` trigger anywhere in the entry | `grep -c 'recheck:'` → 0; QA4 requires one (`corpus/QUALITY.md:23`); sibling `op-ref-consumption.md:369` carries `recheck: on-release of op` | **GAP** (freshness). Needs a trigger keyed to handler restoration/update, not to op release alone. |

## 5. Absent-source limits (verified, not inferred)

- `ls -la ~/.local/bin/the-janitor` → `No such file or directory`; `command -v the-janitor` → not found.
- `ls -la ~/.config/the-janitor/` → `No such file or directory` (the parent `~/.config` and `~/.local/bin` exist).
- `/usr/bin/op` exists, version `2.41.0`.
- Consequences, stated without running anything: `R11-04` (`drift-pins.sh`) would report MISSING for the handler and `op.env` against `drift-baseline.tsv` (`333`-line handler, `17`-line `op.env`); `R12-01` (`op-ref-probe.sh`) documents SETUP exit 2 without the handler; `R11-02` would exit 1 with `SURFACE_CENSUS_VERBS: DEGRADED (pass=0 …)` by its own fail-closed branch (`corpus/surface-census.sh:869-883`, which refuses to print `CLEAN` when zero probes pass). The entry's declared `Reverify:` pointers **resolve and are relevant**, but all three are currently host-blocked. That is a substrate limit, not an entry defect — do not score it as a failed re-verification and do not run the gates to prove it.
- Therefore: the `1078` bytes / `0600` / mtime, the line ranges, and the exit strings **cannot be re-established in this round**. Only corpus-internal consistency was measured.

## 6. Proposed appended correction — scope only (no header drafted)

Needed: **yes**. Required shape: an append-only erratum following the precedent at `f4a8dd9` (`round-16: qualify historical janitor source claims`), which added a dated historical-source section naming the original line ranges while leaving the original text verbatim. Do **not** rewrite lines 1–55, do not "fix" the range, do not restamp-and-call-it-fresh (QM14: a fresh hash does not make historical source facts current).

Exact scope the erratum must cover:

1. **Entry-level source status** (lines 3–6): the source read is historical (2026-09-28) and the cited paths are absent at the frozen base; re-verification requires restored, authorized reads. This is the same class the round-16 commit applied to four sibling entries; `op-env-refs.md` was outside that measured set (`SCORECARD.md:490` names only four files), so this is newly identified, not a failed round-16 claim.
2. **Composition claim** (15–16): retain the original sentence; add the measured split (8 refs / 2 raw identifier-class values, 2026-09-28, `janitor-env-contract.md:73-76`) and restate the invariant as an expectation, not an observation. Do not introduce secret values, key names beyond the two already committed, or any new reference-shaped literal.
3. **Enforcement wording** (12–13): record that the awk is an inventory filter, not enforcement, citing `op-ref-consumption.md` §2 and `janitor-env-contract.md:76`.
4. **Range conflict** (3): leave `L228–235` as recorded; name the unreconciled `L228–236` in `op-ref-consumption.md:4` as open until the source is restored.
5. **Recheck trigger**: add one keyed to handler restoration or source change (plus the inherited op-release clock for `run`/masking via `R12-01`/`R21-01`), explicitly not claimed as run.
6. **Do not touch**: the `Reverify:` line (`R11-02, R11-04, R12-01` all resolve in `claim-ledger.tsv` and are relevant), the `refs`/`run` table, or the checklist items.

### Exact proposed recheck scope (restoration-conditional, vault-free)

Run only on a host that again carries the cited paths; record exit code and last line for each. If a prerequisite is missing, record SETUP/SKIP and leave the entry historical — do not substitute another host's copy.

1. `sed -n '1,20p' ~/.local/bin/the-janitor` — confirm the `THE_JANITOR_ENV`/`ENV_FILE` default at L7. Settles line 19.
2. `sed -n '226,238p' ~/.local/bin/the-janitor` — settle the `cmd_refs` span (228–235 vs 228–236) and the awk predicate at L234. Settles lines 3 and 12–13; do not pick a value by majority vote before this read.
3. `sed -n '237,250p' ~/.local/bin/the-janitor` — confirm the `exec op run --env-file="$ENV_FILE" -- "$@"` line (the `drift-symbols.tsv` pin is line 248) and the order of the three error checks. Settles lines 26 and 33–36.
4. `stat -c '%a %s %Y' ~/.config/the-janitor/op.env` — compare `600`, `1078`, and mtime 2026-08-27; any difference is drift to record with its date, not a silent row update.
5. Key-class counts only, never values: count lines matching the `refs` filter and how many values begin with the ref scheme; record `total/refs/raw` and the date. This is what re-measures the 8/2 split; never print a key, value, or ref path.
6. `op --version`, then re-run `R12-01` and `R21-01` (scratch fixtures only, no ref resolution, no sign-in) — `run`'s dotenv and masking behaviour is delegated to `op` and carries the op-release clock, not this entry's source clock.
7. Re-run `R11-02`, `R11-04`, `R12-01`; then update entry text, the single stamp row, and the migration record in one reviewed commit (QM5/QM12/QM14).

Out of scope for any recheck: `op read`, `op inject`, `op signin`, account or vault listing, or copying `op.env` anywhere. The entry's own premise (contents not read) remains in force.


Append-only preservation requirement (non-negotiable):

- Original 55 lines stay byte-identical; the erratum is appended after line 55. Prove it by comparing `git show 2486643:corpus/knowledge/op-env-refs.md` against the first 55 lines of the new file.
- Record the pre-erratum pin `6ca40a73…` (55 lines / 2693 bytes, added at `2486643`) in the migration record with the post-erratum hash, the reason, and the check performed. The migration record, not the erratum prose, is where old→new lives (QM14; `.ufo/waves/round-22/historical-migrations.json` snapshot semantics).
- Re-pin in the **same reviewed commit**. Do **not** run a whole-set `stamp` naming all paths: `stamp` replaces the entire row set, and the ledger currently holds six genuinely stale rows (§7); a full regeneration would silently re-pin those six — the exact laundering QM14 forbids. Use a scoped single-row update (tab-exact), or regenerate only after each of the six has its own old/new adjudication.
- Keep `checklist.tsv` row E4 intact: the target's line 14 is one of the five allowlisted `[reference metadata redacted]` literals (`raw=5`, `excluded=5` measured now with the row's own regex). Adding another such literal would break the pinned `raw=5`; the erratum must reference the existing line instead.
- No `--prune`, no row deletion, no `sha256`-only "freshness" claim in prose.

## 7. Ledger expectation migration (freshness axis, exact historic evidence)

Recomputation semantics matter and produced one avoidable false overclaim in this audit:

- The ledger's line column is `wc -l` (`claim-ledger.sh` `stamp()` uses `wc -l`). A naive `str.splitlines()` count reports 26 mismatches; **20 of those are phantom** (hash and bytes identical; the file's last line lacks a trailing newline). Correct result with `wc -l`/`wc -c`/`sha256sum`: **6 stale rows, 57 fresh, 0 missing, 0 duplicate**.
- Stale rows and their last commits, each of which **did not touch `corpus/stamps.tsv`** (verified with `git show --name-only`): `config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md` ← `f4a8dd9`; `lessons/round-18.md` ← `bad9088`; `LOG.md` ← `c2cab35b` (the base integration commit itself).
- The ledger's written expectation is a **mutable snapshot with a membership invariant**, not an append-only log: `claim-ledger.sh:13-19` states "Regenerating is a reviewed commit, not an automatic re-pin"; `stamp()` refuses to shrink unless `--prune` and checks membership per path (the round-12 loss of 18 rows in an in-flight `stamp` is recorded at `claim-ledger.sh:22-23`). `historical-migrations.json` states the same: "stamps and claim-ledger expected rows are mutable gate inputs, not append-only LOG/QUALITY/SOURCES immutable columns"; `deleted_stamps` is `[]`; one rewritten claim row `R21-03` is preserved with old/new.
- **The "nine previously dropped stamps" is itself an overclaim as worded.** `round21-migrations.json` records `removed_members: []` and exactly **9 changed stamp records** (`LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`), i.e. nine deleted **diff lines** whose replacements keep the same path. Its own `interpretation` field says exactly that. No member was dropped, and `op-env-refs.md` is not among the nine. The correct control to admit is the recorded 9-line diff; the rejected reading is "nine lost stamps".
- Committed history contains no removal: all 9 commits that touch `stamps.tsv` add or modify rows, never delete (`28` at `301b9ec` → `33` → `44` → `48` → `52` → `54` → `56` → `63`, with `e1544c1` rewriting 13 rows in place).

This entry's contribution to the reconciliation is therefore negative and useful: its row is **not** stale, **not** rewritten, **not** deleted, and must not be cited as any of those.

## 8. Calibration decisions measured (C1 — decisions, not authored counts)

Known bad admits rejected, each against independent corpus evidence:

1. "Stamp stale for `op-env-refs.md`" → rejected by exact hash/bytes/lines (§2).
2. "Byte freshness implies substantive freshness" → rejected; fresh pin, stale composition/enforcement sentences (§4).
3. "Handler behaviour is current" → rejected; both cited paths absent (§5).
4. "`Secret bytes never live … only pointers`" → composition half rejected against the 8/2 measured record at the same revision (§4-B).
5. "Convention is enforced by `cmd_refs`" → rejected; a filter observes, and the sibling entry says not enforced (§4-C).
6. "Twenty more stamps are stale" → rejected as a line-count-semantics artifact (20 phantom vs 6 real; §7).
7. "Nine stamp members were dropped" → rejected; nine changed lines, same members, `removed_members: []` (§7).

Correctly bounded controls admitted (so the correction does not overreach):

8. The dated stat line (18) as a historical observation, not an overclaim — distinct from the round-19 present-tense-hash defect.
9. The `Reverify: R11-02, R11-04, R12-01` declaration — all three ids resolve exactly once in `claim-ledger.tsv` (`sed -n '16p;18p;26p'`) and are relevant; the entry is revision-pinned, satisfying the `docs` mode's structural requirement.
10. The `refs`/`run` split, redaction direction, and `^[A-Z][A-Z0-9_]*=` gating — consistent with the byte-fresh `op-ref-consumption.md`; not disturbed.

## 9. Remaining unknowns (explicit, not resolved by inference)

- True `cmd_refs` end line (235 vs 236) and whether any sentence about `run`'s error ordering is complete.
- Whether `1078`/`0600`/mtime 2026-08-27 still match the file at restoration.
- Whether the 8/2 split moved after 2026-09-28 (cannot know without the file; the count must be re-measured, never assumed).
- Whether `op 2.41.0` (present) changes `op run --env-file` masking relative to the 2026-09-28 observation; inherited trigger `R21-01` owns that, not this entry.

## 10. Checks the parent/integrator should run (not run here)

- Recompute the single row: `sha256sum`, `wc -l`, `wc -c` on the post-erratum file and compare to the updated row; assert the first 55 lines equal `git show 2486643:corpus/knowledge/op-env-refs.md`.
- `bash corpus/claim-ledger.sh docs` (repo-only structural audit; confirms `Reverify`/stamp presence after the erratum). Do **not** run `verify`'s host-bound rows on this host; if run, apply QM12's substitute and list the skipped ids (`R11-02`, `R11-04`, `R12-01`) with reasons.
- Re-run the E4 regex from `corpus/checklist.tsv` row E4 and assert `hits=0 excluded=5 raw=5`.
- Confirm `grep -c '[^[:space:]]' corpus/stamps.tsv` remains 63 (no membership change) and that only the `op-env-refs.md` row differs old→new.
- Confirm the migration record names old pin `6ca40a73286c038f7e431d84f2ba0fb55693dd1e217584eaafd1ec1dd2dbaf86` (55/2693) → new pin with reason and check, and that no other row was re-pinned without its own evidence.

No depth move, no legacy-header count, and no score change are claimed by this report.


Integration privacy note (round 22): reference-shaped example metadata was redacted before first landing under corpus QUALITY QA5. No original reference path is retained in this report.
