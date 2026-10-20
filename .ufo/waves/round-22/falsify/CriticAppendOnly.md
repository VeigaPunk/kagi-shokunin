# CriticAppendOnly — nine deleted lines vs zero removed members

Axes attacked: **freshness** (primary — rollback/rewrite falsification of the
migration records), **calibration** (secondary — expectation rewrites must be
measured, not target-chosen). Seat: read-only falsifier. Exact read revision:
integrated landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` ("Integrate
round-22 build wave"; verified with `git rev-parse`), against
`aea7a4301`…`e1544c194fddf1bb073b3946847b4526f326ad73` and base
`c2cab35bc92e57e39e5489bac3386db078345b3f`. Method: `git show` extracts,
`sha256sum`/`wc` recomputation, `git merge-base` ancestry — no lane gates, no
package managers, no launchers, no host probes; one authorized fixture
execution (`python3 corpus/feature-claims.py`, exit 0). Frozen input hashes
named from `integration-manifest.json` (e.g. `corpus/stamps.tsv`
`88bbe15b…`, `corpus/claim-ledger.tsv` `87fed349…`, `corpus/feature-claims.py`
`9f6a7e35…`, `corpus/revision-audit.py` `ac19e186…`).

## Verdict: HOLDS — the zero-removed-members record is byte-exact against git; no rollback or laundered rewrite found

## What I actually re-derived (not trusted)

### 1. `round21-migrations.json` (`aea7a4301` → `e1544c19`) — byte-exact

- `corpus/stamps.tsv`: 56 → 63 members. Path-set diff over `git show`
  extracts: **0 removed, 7 added** (`QUALITY.md`, `SOURCES.md`,
  `sources-census.sh`, `knowledge/onepassword-machine-credentials.md`,
  `knowledge/sops-age-key-rotation.md`,
  `knowledge/vault-openbao-token-lease-lifecycle.md`,
  `lessons/round-21.md`). `git diff` confirms exactly **9 deleted lines**, all
  nine re-added at the same path with fresh pins. So the outside verifier's
  count was real but its referent was wrong: nine *rewrites*, zero drops.
  `removed_members: []` is **true**.
- All 9 `changed_stamp_records` old/new strings are **byte-identical** to the
  git rows at both ends (verified field-for-field for all 9).
- All 5 `rewritten_claim_rows` (R12-02, R12-03, R13-01, R13-02, R14-01) are
  byte-identical to the ledger rows at both revisions. Ledger path-set diff:
  0 removed; additions (R21-01…R21-04 + one comment line) are real and match
  the lesson's "round-21 added R2x rows" note.
- `historical-migrations.json` (`c41af82` → `e1544c19`): R21-03 old/new rows
  byte-exact; `deleted_stamps: []` consistent. `c41af82` is a descendant of
  `aea7a4301` and ancestor of `e1544c19` (`git merge-base`), so the sub-span
  artifact genuinely nests inside, not substitutes for, the full-span record —
  the lesson's claim holds.

### 2. No unjustified rollback — every rewrite direction is forward

- Every `new_stamp` hash equals `sha256(git show e1544c19:<path>)` for all 9
  (recomputed). No stamp points backward to older bytes.
- `corpus/op-ref-probe.sh`: file bytes at `aea7a4301` and `e1544c19` are
  identical (`0f1945e8…`; no commit touched it in the span — same observation
  as build/ReviewStamps.md F1 row 3). The old stamp `509f084a` (660/28660)
  pinned bytes that were **already absent at `aea7a4301`**: the rewrite
  *corrected* a stale inherited pin, it did not roll the file back.
- In fact at `aea7a4301`, four of the nine "old" stamps did not match their
  files (`LOG.md`, `SCORECARD.md`, `corpus/README.md`, `op-ref-probe.sh` —
  measured). The artifact records the stale values honestly rather than
  pretending they were live pins.

### 3. `pin-migrations-integration.json` (base `c2cab35` → tip `8ada17a5`) — complete and byte-exact

- Stamps: 63 → 69 members. Re-derived: **0 removed, 6 added**
  (`feature-claims.json`, `feature-claims.py`,
  `knowledge/feature-bound-credential-review.md`,
  `lessons/round-21-verifier-spotcheck.md`, `lessons/round-22.md`,
  `revision-audit.py`), **32 changed**. Artifact `stamp_changes` = 38 =
  32 changed + 6 added (`old_stamp: null`), exactly the union — no omitted
  record.
- For all 32 changed rows: `old_stamp` byte-exact to base rows, `new_stamp`
  byte-exact to tip rows **and** `sha256` equal to tip file content;
  `base_observed` (sha/lines/bytes) equals recomputed base file content for
  every row — including `LOG.md`, where `base_observed` (`51e76cf1…`,
  1050/75404) correctly diverges from `old_stamp` (`60a8fd36…`), i.e. the
  sixth base mismatch is on the record, not hidden.
- `claim_changes` = 12 = 8 rewritten (R11-09, R12-03, R13-01, R14-01,
  R18-02, R18-03, R21-02, R21-04) + 4 added (R22-01…04). Every old/new row
  byte-exact to git. R18-02's change is a note-only honest withdrawal
  ("Historical ten-plus-own-pattern explanation withdrawn (round-22 Entry20
  static audit); expectation remains 11") — preserved, not erased.
- Full-set staleness sweep at tip: all 69 stamp rows' sha/lines/bytes equal
  tip file content — **zero unexplained mismatch**, zero absent stamped
  files. So no member was silently dropped in either direction, and no
  stamp was left pointing at pre-integration bytes.
- Manifest `expected.revision_audit` (added=6, dropped=0, invalid=0,
  missing=0, stale=0) matches this measurement. `before-runnable.json`'s
  recorded run (stale=6 incl. `LOG.md`, dropped=0, exit 1) matches my
  independent base re-derivation (exactly the six names
  `before.json` lists).

### 4. Migrated expectations are measured values, not targets

- `R12-03` `^63$→^69$`: tip `stamps.tsv` has 69 non-blank rows (measured).
- `R21-04` `^39$→^43$`: 43 claim rows at tip (measured); R22-01…04 exactly
  account for +4.
- `R13-01` `^23$→^25$`: 25 `## Round ` headings in tip `SCORECARD.md`.
- `R21-02` `rows=16→21`: `SOURCES.md` has 21 `S`-prefixed rows.
- `R11-09`/`R18-03` `97→108`: consistent with the manifest's
  `ledger_selftest_cases: 108` (selftest itself not rerun — lane gate,
  parent's job).
- All expectation rewrites carry old+new in the artifact and reasons in the
  ledger note fields — the QM14 contract.

### 5. C1 fixture spot-check (authorized local fixture only)

`python3 corpus/feature-claims.py` (no args, phase=after) exits 0:
4 bounded controls admitted, 0 false admissions, 0 unjudgeable — matches
`R22-01`'s expectation verbatim.

## Strongest remaining counterexample I could construct — and why it fails

*Rollback hypothesis:* a rewrite that reverts a file's pin to older bytes
would surface as `new_stamp` ≠ tip content, or a tip stale row. Measured:
zero (§3). *Laundering hypothesis:* old rows deleted and replaced
untraceably would surface as missing `old` records or a
`removed_members`/`deleted_stamps` mismatch. Measured: every old byte
preserved, and the outside-verifier diff lines map 1-to-1 onto the recorded
pairs. *Restore-trap hypothesis:* nothing was "restored" — correctly,
because per ReviewStamps F1 there is nothing to restore; the remote-side
`c03e12c` `LOG.md`/`claim-ledger.tsv` rows were not adopted.

## Holds-with-limit (real defect class, bounded severity)

1. **Asymmetric completeness in `round21-migrations.json`.** The schema
   records `removed_members` and `changed_stamp_records` but has no
   `added_members`/`added_rows` field; the 7 stamp additions, 4 ledger
   additions and 1 comment line are absent from the artifact. A future
   consumer treating it as an exhaustive member diff could miss a
   remove-then-re-add identity swap. Low severity: git history and
   `pin-migrations-integration.json` cover the gap, and nothing in the
   artifact claims exhaustiveness of additions. Smallest safe correction:
   add `added_members`/`added_rows` arrays to the generator schema (they
   are computable from the same two `git show` extracts).
2. **Same asymmetry in `historical-migrations.json`** (`deleted_stamps`
   present, no `added_stamps`/`added_rows`). Same correction.
3. **Artifact is a round-22 reconstruction, not a contemporaneous record.**
   `round21-migrations.json` was produced in this round from `git show`
   replays (it lives in the round-22 wave dir). It is byte-exact, so the
   content is sound; the limit is only that the lesson's phrasing
   "preserves each old and new TSV record" should not be read as a
   round-21-emitted artifact. No misattribution found — the lesson does
   not claim a round-21 timestamp for it.
4. **No generative provenance.** Neither artifact names the script/command
   that produced it; reproducibility rests on the falsifier re-running the
   same git extracts. A one-line `produced_by:` field would close this.

## Impacted axes

- **freshness**: holds — revision accounting is complete, byte-exact,
  attribution-preserving, and contains zero unexplained
  mismatch/deletion at tip. The "nine dropped stamps" adjudication is
  correctly rejected as rewrites-with-evidence.
- **calibration**: holds — all 12 migrated expectations equal measured
  values at the frozen tip; note-only corrections (R18-02) are preserved
  rather than laundered.
- **no-harm**: the remote-side rows (`c03e12c`) were not restored; no
  false provenance introduced.

## Limits of this review

- I did not execute lane gates (`claim-ledger.sh verify`, `docs`,
  `--selftest`, `sources-census.sh`) — read-only seat; the manifest's
  `ledger_selftest_cases: 108` and feature `selftest_cases: 10` are
  trusted from `repaired-checks.json`/manifest, not re-measured.
- `git merge-base`/`git show` over the lane repo is the falsification
  substrate; jj state deliberately untouched (snapshot side effects).
- The `.ufo` artifacts under review are wave outputs (not frozen manifest
  inputs); claims about them are verified against frozen-input git bytes.

## Smallest safe correction

Add symmetric `added_members`/`added_rows` (and `produced_by`) fields to
the two migration-artifact writers; record the generator command in each
artifact. No content correction needed — the accounting itself survives
the strongest rollback/rewrite counterexample available locally.

## Installs

None. No tools installed, no host state touched.

Checks the parent may run post-integration: `bash corpus/claim-ledger.sh
verify`, `bash corpus/claim-ledger.sh --selftest`,
`python3 corpus/revision-audit.py --selftest`, and
`bash corpus/sources-census.sh` (rows=21 path).

Trailer: .ufo/waves/round-22/falsify/CriticAppendOnly.md
