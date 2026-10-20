# Entry05 — freshness/calibration audit: `corpus/knowledge/claim-ledger.md` and its stamp row

Seat: `KagiR22.Entry05` (scout, read-only). Axes: **calibration**, **freshness**.
Milestone: Build source-bound calibration and pin-debt reconciliation.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD`; also the
frozen base). The document and its stamp row are unmodified in the working tree.
No host gate was executed; no install or update was performed. All counts below are static
reads plus `sha256sum`/`wc`/`git show`.

**Working-tree note.** During the audit other lanes left production files modified (observed at
audit time: `corpus/QUALITY.md`, `corpus/SOURCES.md`,
`corpus/knowledge/onepassword-machine-credentials.md`,
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; `corpus/claim-ledger.sh` was modified by
the `FixCellParser` lane after the audit snapshot). Those are not mine and are *not* used below;
every frozen-base statement, including every `corpus/claim-ledger.sh` line citation, is computed
from `git show c2cab35:<path>` (HEAD objects). The audited ledger and `corpus/stamps.tsv` are
byte-identical in HEAD and in the working tree (`git diff --stat` empty for both).

## Verdict (one line)

**The stamp row is fresh — no stale-byte mismatch, at the base or at any committed revision since
the row existed.** The substantive defect is internal and invisible to stamps: `§Reproduction`
(lines 301–304) is an **unlabelled round-13 (`4b8c018`) snapshot** whose exact counts and whose
`cells` verdict are no longer true at the base. An append-only erratum is warranted; a rewrite is
not; a re-stamp is required only in the same reviewed commit as the append.

## 1. Byte identity — row 13 of `corpus/stamps.tsv`

Stamped row (line 13):

```
corpus/knowledge/claim-ledger.md	f1575725ccd845f3af87cb65ddbd38565bfefe028ea1e698e37143b039664630	472	32297
```

Measured at the frozen base:

| Field | Stamp | Measured | Match |
|---|---|---|---|
| sha256 | `f1575725…664630` | `f1575725ccd845f3af87cb65ddbd38565bfefe028ea1e698e37143b039664630` (`sha256sum`) | yes |
| lines | `472` | `472` (`wc -l`; last byte is `0a`, so `wc -l` = logical lines) | yes |
| bytes | `32297` | `32297` (`wc -c`) | yes |
| type | — | regular file, mode `644` (`stat -c '%F %a'`) | consistent |

Field semantics are the script's own: `stamp()` writes `sha256sum`, `wc -l`, `wc -c`; `verify`
recomputes all three. There is exactly one row for this path.

**History — the stamp matched at every committed revision, not just at the base.** (Rows are
`git show <rev>:corpus/stamps.tsv` for the path vs `git show <rev>:corpus/knowledge/… | sha256sum`,
`wc -l`, `wc -c`.)

| Revision | Role | Stamp row (sha12 / lines / bytes) | Match |
|---|---|---|---|
| `301b9ec` | round 11 | `09dda83d2adb` / 232 / 14580 | yes |
| `4b8c018` | round 13 | `477393695fb8` / 374 / 25215 | yes |
| `2486643` | round 14 | `f1575725ccd8` / 472 / 32297 | yes |
| `587fda0` … `e1544c1` | rounds 15–21 (6 commits) | `f1575725ccd8` / 472 / 32297 | yes |
| `c2cab35` | frozen base (merge) | `f1575725ccd8` / 472 / 32297 | yes |

So: **there is no stale-byte mismatch to repair and no historic drop of this row.** The content
has simply not been edited since round 14 (`2486643`).

## 2. What the stamp cannot see — substantive freshness

### 2.1 `§Reproduction` is an unlabelled round-13 transcript

`git blame -L 301,304` puts all four command/verdict lines in `4b8c018` (round 13); none has been
edited since. The tuple is *internally exact for that revision*, which is why it should be
preserved as a record rather than rewritten:

| Field in the block | Round-13 value (`4b8c018`) | Frozen base (`c2cab35`) | Evidence |
|---|---|---|---|
| `claims=` | 17 | **39** claim rows / 39 distinct ids | `git show <rev>:corpus/claim-ledger.tsv`, rows with ≥6 tab fields and no `#` |
| `stamped=` | 33 | **63** non-blank stamp rows | `git show <rev>:corpus/stamps.tsv` |
| `ids=` | 17 | **39** | id set of the current claims file |
| `--selftest` | 72 cases | **97** cases | static count `grep -cE '^ *tcase(_last)? ' corpus/claim-ledger.sh` = 97; pins `R11-09` / `R18-03` expect `PASS (97 cases)` |
| `cells=` | 60 (= 6 axes × 10 scored sections) | **132** (= 6 × 22 scored sections) before any refusal | `git show <rev>:SCORECARD.md \| grep -cE '^## Round [0-9]+ — (pre\|post)-move'`: 10 / 12 / 22 for `4b8c018` / `2486643` / HEAD |
| summary fields | no `deferred=` | `deferred=` (verify) and `row_deferred=` (cells) are emitted | `corpus/claim-ledger.sh:954`, `:983` (round-18 additions) |

The block's counts are therefore stale *as a reproduction*, even though the stamp is correct. The
entry's own convention (lines 290–296) says exact citation tuples move with every doc edit and
should be quoted with `≈`; the reproduction block contradicts it by presenting an exact tuple with
no revision label.

### 2.2 The `cells` verdict on line 303 is not reproducible at the base

`cells` is refused (exit 2) by the round-20 attempt heading:

- `SCORECARD.md:558` — `## Round 20 — interactive attempt; blocked, not completed (2026-10-15)`;
- `corpus/claim-ledger.sh:671` — `SEC_RE='^## Round [0-9]+ — (pre|post)-move'`;
- `corpus/claim-ledger.sh:714-715` — a heading starting `## Round ` that fails `SEC_RE` calls `die`;
- `corpus/claim-ledger.sh:112` — `die()` exits **2**.

So line 303's `CELL_AUDIT: CLEAN …` cannot be produced today. This is already recorded as
round-21 debt (`corpus/lessons/round-21.md` §Named debt, first bullet) and is a separate round-22
fix item (`FixCellParser`); the knowledge entry does not mention it. `R13-03` carries `[substrate]`
in its note and `substrate_present()` (`claim-ledger.sh:138-145`) is true only for
`KAGI_SUBSTRATE=present` or an executable `$HOME/.local/bin/the-janitor` (absent on this host), so
`verify` would **defer** `R13-03` here; on a substrate-present host it would **FAIL exit-mismatch**
until the parser change lands. Either way, line 303 is not a current verdict.

### 2.3 Contract-shape drift (round-18 deferral)

The entry does not mention deferral at all (`grep -n 'defer\|DEFER\|row_deferred'` → 0 matches),
while the shipped gate:

- prints `DEFER <id> reason=substrate-absent` for a `[substrate]` row (`claim-ledger.sh:397-399`);
- includes `deferred=` in `CLAIM_LEDGER: CLEAN` (`:954`) and `row_deferred=` in `CELL_AUDIT` (`:983`).

The quoted shapes at lines 47 (`CLAIM_LEDGER: CLEAN (claims=N stamped=M)`), 84–88 (per-row verdicts
list `FAIL`/`POLICY` only) and 198–199 (`CELL_AUDIT` without `row_deferred`) are the round-11/13
shapes. This is substantive for a contract entry, though lower severity than an incorrect verdict:
a reader would not know a row can be counted-but-not-run.

### 2.4 Two provenance overclaims in the source basis

- **The wave-revision blob is absent.** Lines 3–5 cite `corpus/claim-ledger.sh` at **436 lines,
  sha `d63c60b0821b5388…`**. `git cat-file -t d63c60b0821b5388` → *not a valid object*;
  `git rev-list --all --objects | grep -c d63c60b` → 0. It is the **unlanded round-11 L2 wave**
  revision, independently described at `corpus/lessons/round-11.md:130` (`d63c60b0…` 436 lines)
  and `LOG.md:265`. The committed round-11 revision is a different artifact: `301b9ec` →
  540 lines, sha `8120f7d7d29a053a…`. The sentence is honest about "frozen wave revision" and is
  *not* a restamp target — but the exact hash is unverifiable from this repository and should be
  labelled a provenance limit, not treated as a current pin.
- **"every verdict string in this entry … round-11 evidence set" (lines 7–9) is overbroad.**
  Class 4/5 verdicts come from the `4b8c018` (round-13) fixtures; Class 6 from round 14. The
  sentence was true for the round-11 classes and was never narrowed when the later tables were
  appended. This is a wording overclaim, not a fabricated measurement: each later class carries its
  own dated before→after table.

The `9 rows at that revision` (line 6) and `14 at round-12 close` are consistent but partly
unreachable: the wave revision's ledger blob `3d6fe4ba…` is likewise absent (0 objects), and there
is **no standalone round-12 commit** in this repository (`git log --all` has no round-12 subject;
the round-12 rows first appear in `4b8c018`, which has 17 rows). The committed round-11 close has
**11** rows (`R11-10`/`R11-11` added at landing). So the historic ladder is:
9 (unlanded wave) → 11 (committed `301b9ec`) → 14 (uncommitted round-12 close, arithmetic only) →
17 (committed `4b8c018`). That should be remembered, not "corrected" by editing the wave numbers.

## 3. "Nine previously dropped stamps" — calibration reconciliation

The wave brief's phrase is not supported as stated. Three independent checks:

1. **Path membership never decreased.** Per-consecutive-commit path-set deltas over all nine
   `corpus/stamps.tsv` revisions: `301b9ec→4b8c018 +5 / 0 removed`; `→2486643 +11/0`;
   `→587fda0 +4/0`; `→8a6ec16 +4/0`; `→bc1af88 +2/0`; `→fecee87 +2/0`; `→c41af82 +7/0`;
   `→e1544c1 0/0`; `→c2cab35 0/0`. Row counts: 28 → 33 → 44 → 48 → 52 → 54 → 56 → 63 → 63 → 63.
   **Zero paths dropped, ever.** No duplicate rows at any revision.
2. **Claim ids never decreased either.** `corpus/claim-ledger.tsv` id sets: 11 → 17 → 18 → 23 →
   29 → 32 → 35 → 39 → 39 → 39; every commit adds ids only.
3. **The nine are re-stamps and/or stale rows, not deletions.**
   - `c41af82` has exactly **9 deleted stamp lines** (`LOG.md`, `PROVINCE.md`, `SCORECARD.md`,
     `SHONEN.md`, `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`,
     `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`). Each of the nine paths is
     re-added in the **same commit** with a new hash (verified: each has exactly one `+` row), and
     all nine are present at HEAD. They are replacements, not drops.
   - The only "nine" with independent numeric evidence is **9 stale rows at `aea7a43`**, recorded
     at `LOG.md:983` ("Stamp drift at `aea7a43`: 9 rows mismatched") and reproduced from the tree:
     the same four knowledge entries named in the base set below, `corpus/lessons/round-18.md`,
     `corpus/op-ref-probe.sh`, `corpus/README.md`, `LOG.md`, `SCORECARD.md`.
   - At the **frozen base**, the stale set is **6**, not 9 and not 5: the five named round-21 debt
     paths (`knowledge/config-layering.md`, `knowledge/handler-on-disk-state.md`,
     `knowledge/handler-trust-boundary.md`, `knowledge/janitor-env-contract.md`,
     `lessons/round-18.md`) **plus `LOG.md`**. `LOG.md` was correctly re-stamped at `e1544c1`
     (1043/74864) and then the frozen-base merge `c2cab35` appended 7 lines/540 bytes
     (`git diff --stat e1544c1 c2cab35 -- LOG.md`), so the base itself introduced one stale row.
     `corpus/knowledge/claim-ledger.md` is **not** in any of these sets.

Wave artifact corroboration (not authority): `.ufo/waves/round-22/historical-migrations.json`
reports `"deleted_stamps": []`; `.ufo/waves/round-22/round21-migrations.json` reports
`"removed_members": []` and exactly 9 `changed_stamp_records` (the same nine paths). That is the
right referent for "nine": **nine changed records**, not nine removed stamps.

**Limit.** An uncommitted or in-flight nine cannot be ruled out from `git`; no committed artifact
records one. What the committed history does contain is one nine-row **mismatch** set
(`aea7a43`), one nine-line **replacement** diff (`c41af82`), and zero removed paths/ids. If the
wave's "dropped nine" came from an uncommitted working state, it is an absent source and must not
be laundered into "restored" by re-pinning anything.

**Calibration decisions.**

| Proposition | Decision | Basis |
|---|---|---|
| `claim-ledger.md` stamp row is stale at the base | **Reject** | exact 4-field match; matched at all 9 revisions |
| nine stamp paths were dropped and need restoring | **Reject** | 0 removals at every consecutive revision; 9 `c41af82` deletions are same-commit re-stamps |
| nine stamp rows were stale at `aea7a43` | **Accept** | `LOG.md:983` + recomputed list |
| six stamp rows are stale at the base, including `LOG.md` | **Accept** | recomputed from HEAD objects |
| the reproduction block's counts/verdict are current | **Reject** | exact round-13 mapping above; `cells` refuses at base |
| no mode re-runs or compares `§Reproduction`'s counts | **Accept** | `docs` checks declarations/membership; `verify` checks the entry's stamp; neither reads §Reproduction |
| no verification/re-pin of the quoted wave blobs (`d63c60b…`/`3d6fe4ba…`) is possible | **Accept, bounded** | absent from the object database; labelled as wave revision |

## 4. Appended correction — needed; exact content and preservation rule

**Needed: yes.** The reproduction verdict is a current-state assertion that is false at the base,
and the contract shapes predate the shipped deferral fields. **Do not rewrite lines 1–472**;
append a new section after the closing falsifier fence (line 472; the file ends with a newline, so
a normal append starts cleanly). The appended section should carry all of the following, and may
be merged with the separate `DraftHistory` erratum (facts must agree; do not duplicate a second
contradicting paragraph).

Proposed append (exact facts; wording can be reconciled):

```markdown
### Errata — round 22 at frozen base `c2cab35` (appended, history above unchanged)

- `§Reproduction` lines 301–304 were measured at `4b8c018` (round 13) and are preserved as that
  record: 17 claim rows, 33 stamp rows, 72 selftest cases, 60 cells (10 scored sections). At
  `c2cab35` the statically verifiable counts are 39 claim rows / 39 ids, 63 stamp rows, 97
  selftest cases (`tcase` count; pinned by `R11-09`/`R18-03`), and 22 scored sections / 132 cells.
  These are counts, not a gate verdict.
- At `c2cab35` `cells` is refused with exit 2 by the round-20 blocked heading
  (`SCORECARD.md:558`) against the pre/post-move heading rule (`corpus/claim-ledger.sh:671,714-715`).
  `R13-03` is `[substrate]`-deferred where `$HOME/.local/bin/the-janitor` is absent or
  `KAGI_SUBSTRATE=absent`; on a substrate-present host it fails until that parser change lands.
- The round-18 deferral mechanism (`DEFER <id> reason=substrate-absent`; `deferred=` and
  `row_deferred=` summary fields) postdates the Class 1/2/5 summary shapes quoted above; those
  quotes are the round-11/13 shapes, not the shipped ones.
- Source basis: the round-11 wave revision `d63c60b…` (436 lines; ledger `3d6fe4ba…`, 9 rows) is
  absent from this repository's object database. The committed round-11 revision is 540 lines,
  `8120f7d7…`, with 11 claim rows; the 14-row round-12 close has no standalone commit. These are
  provenance limits, not restamp targets.
- "Every verdict string … round-11 evidence set" applies to the round-11 classes; the Class 4/5
  (round 13) and Class 6 (round 14) tables carry their own dated measurements.
```

**Append-only preservation requirement.**

1. The append must be a pure addition: `git diff -- corpus/knowledge/claim-ledger.md` shows only
   `+` lines; lines 1–472 and every byte above the insertion point stay identical.
2. The historical numbers (17/33/72/60, the `cells` transcript, the `d63c60b` quote) are **not**
   edited in place. They are dated records; the erratum labels them.
3. Re-stamp in the **same reviewed integration commit**: `corpus/claim-ledger.sh stamp
   corpus/knowledge/claim-ledger.md …` (or a full reviewed row set that does not drop any path —
   the guard refuses shrink without `--prune`). Never re-pin silently, and never update row 13
   without the append that caused it.
4. After the append the new stamp must be the measured 4-field row; the entry's `Reverify:` line
   stays `R11-08, R11-09, R13-03, R14-01` (all four ids exist) unless the integration deliberately
   narrows it.
5. If integration declines the append, record it as open C2 debt with this report as evidence;
   do not edit `cells=60` or the 72-case line in place.

## 5. Recheck scope — exact, post-integration

Static checks (already performed here; repeat only if bytes change):

| Check | Command | Expected at base |
|---|---|---|
| stamp identity | `sha256sum corpus/knowledge/claim-ledger.md; wc -l <…; wc -c <…` vs row 13 | exact match today; new row after append |
| claim rows | `awk -F'\t' 'NF>=6 && $1 !~ /^#/' corpus/claim-ledger.tsv \| wc -l` | 39 today |
| claim ids | same, `$1` | 39 distinct |
| stamp rows | `awk 'NF{n++} END{print n}' corpus/stamps.tsv` | 63 today |
| selftest case count | `grep -cE '^ *tcase(_last)? ' corpus/claim-ledger.sh` | 97 today (matches both pins) |
| scored sections / cells | `grep -cE '^## Round [0-9]+ — (pre\|post)-move' SCORECARD.md` × 6 axis rows each | 22 / 132 today |
| entry declarations | `grep -l '^Reverify: ' corpus/knowledge/*.md \| wc -l`; by-hand count | 24 entries; 21 row-linked; 3 by-hand (matches `R14-01`) |

Execution checks for the parent (not run here):

1. `bash corpus/claim-ledger.sh docs` → `DOC_AUDIT: CLEAN (entries=24 row_linked=21 by_hand=3
   undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`, exit 0 (`R14-01`).
2. `bash corpus/claim-ledger.sh verify` — expect `claims=39` and `deferred=11` on this host if
   substrate stays absent: the `[substrate]` rows are `R11-01`, `R11-02`, `R11-03`, `R11-04`,
   `R11-06`, `R12-01`, `R13-03`, `R15-01`, `R16-01`, `R16-03`, `R17-01` (`awk -F'\t' '$6 ~
   /\[substrate\]/'`). `R11-08`'s citation scan needs the sibling/`.ufo` layout. This is the
   entry's re-verification duty.
3. `bash corpus/claim-ledger.sh cells` **only after `FixCellParser` lands**; before that, expect
   exit 2 on `SCORECARD.md:558`. After the fix, expect 132 cells and `row_deferred=` in the shape.
4. `bash corpus/claim-ledger.sh citations` — no static substitute; requires execution.
5. `bash corpus/claim-ledger.sh --selftest` → `SELFTEST: PASS (97 cases)`, exit 0, unless the wave
   adds cases (then both `R11-09` and `R18-03` must move together).
6. After the append: `git diff` pure-addition check; `sha256sum`/`wc -lc` vs the **new** row;
   `docs` must stay CLEAN; `verify` must report no `STALE` for
   `corpus/knowledge/claim-ledger.md`.

## 6. Provenance

- Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f`; `git status --porcelain` shows the
  audited file unmodified (other lanes' files noted above were excluded).
- Identity: `corpus/knowledge/claim-ledger.md` — `sha256sum`, `wc -l`, `wc -c`, `stat`; row 13 of
  `corpus/stamps.tsv`; field semantics from `corpus/claim-ledger.sh` `stamp()`/`verify`.
- History: `git log --oneline -- corpus/stamps.tsv` (9 revisions); per-revision
  `git show <rev>:corpus/stamps.tsv` path sets; per-revision `git show <rev>:corpus/claim-ledger.tsv`
  row/id sets; `git show <rev>:corpus/knowledge/claim-ledger.md | sha256sum | wc -lc`;
  `git blame -L 296,306`; `git cat-file -t d63c60b0821b5388`; `git rev-list --all --objects`.
- Expectations: `corpus/claim-ledger.tsv` rows `R11-08`, `R11-09`, `R13-03`, `R14-01`, `R18-03`;
  `corpus/claim-ledger.sh:112,138-145,397-399,671,714-715,946-985`.
- Cell/score geometry: `SCORECARD.md` at `4b8c018` (10 pre/post sections), `2486643` (12), HEAD (22);
  six axis rows in every section (static count).
- Nine-stamp reconciliation: `LOG.md:983`; `git show c41af82 -- corpus/stamps.tsv`;
  `git diff e1544c1 c2cab35 -- LOG.md`; `.ufo/waves/round-22/historical-migrations.json`,
  `.ufo/waves/round-22/round21-migrations.json` (corroboration only).
- Host fact: `test -x "$HOME/.local/bin/the-janitor"` → absent. No vault/account/credential call,
  no service or boot change, no package transaction, no host gate.

## 7. Confidence and limits

- Stamp byte identity and per-revision match: **high** (independent recomputation from working tree
  and HEAD objects; all nine revisions).
- Reproduction-block age and round-13 tuple mapping: **high** (`git blame`, and 17/33/72/60/10 all
  recomputed from `4b8c018` objects).
- `cells` refusal at base: **high** statically (regex + `die` path + the exact heading); runtime not
  observed (no gate execution).
- Deferral shape drift: **high** statically (`:397-399`, `:954`, `:983`; zero mentions in the entry).
- Wave-revision provenance (`d63c60b…`, `3d6fe4ba…`) and the 14-row round-12 close: **unverifiable
  by construction** — absent objects / no commit. Treated as labelled historic provenance, not as
  false and not as a re-pin target.
- The current `verify`/`citations`/`cells`/`--selftest` verdict tuples are **not asserted**; only
  the statically derivable counts are. Any exact tuple must be measured by the parent after
  integration, at the then-current revision.

No depth move; no legacy-header count claim.
