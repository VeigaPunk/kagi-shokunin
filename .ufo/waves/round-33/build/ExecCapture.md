# ExecCapture — the two append blocks, the id map and the collision guard

Seat: `ExecCapture` (executor, leaf). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`, plan `plans/round-33.md` (commit `880824b`).
Scratch `/fast/scratch/hyaku/kagi-r33/ExecCapture/` — created with `mkdir -p`, `TMPDIR` exported,
removed at exit (no residue).

## Result

The three drafts exist in the lane schema and validate. The lane also moved under me: the L1
already landed a version of this change (registry rows, capture rows and both entries) while the
seat ran, so this report separates **what I drafted**, **what the tree now measures**, and the
**deltas the L1 should decide on**.

| deliverable | path (absolute) | shape |
|---|---|---|
| registry append | `…/.ufo/waves/round-33/build/sources-append.md` | 10 rows × 11 cells, NF=13, no pipe and no `\|` in any cell, `status=mined`, `opened=2026-11-04`, `recheck` ∈ {180d, 90d, 365d}, `used-by` one entry |
| capture append | `…/.ufo/waves/round-33/build/fetches-append.tsv` | 10 rows × 16 tab fields, one row per id, `fetched=2026-11-04` |
| id map | `…/.ufo/waves/round-33/build/id-map.txt` | 10 staged→lane pairs, URL proof per line, arithmetic refutation, 2 non-adopted staged rows |
| receipts | `…/.ufo/waves/round-33/build/assimilation/` | collisions, guard proof + fixture, quotes, row identities, scout reconciliation, landed diff, capture log, `validate/` |

No lane-tracked file was written by this seat; every lane edit remains the L1's.

## The id map is by document, not arithmetic

```
S061 S073 https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final            MATCH
S062 S074 https://csrc.nist.gov/pubs/sp/800/133/r3/ipd                 MATCH
S063 S075 https://csrc.nist.gov/pubs/sp/800/133/r2/final               MATCH
S079 S076 https://csrc.nist.gov/pubs/sp/800/57/pt2/final               MATCH
S080 S077 https://csrc.nist.gov/pubs/sp/800/57/pt3/final               MATCH
S083 S078 https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf  MATCH
S084 S079 https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p3.pdf  MATCH
S085 S080 https://csrc.nist.gov/pubs/sp/800/57/pt2/r1/final            MATCH
S086 S081 https://csrc.nist.gov/pubs/sp/800/57/pt3/r1/final            MATCH
S087 S082 https://csrc.nist.gov/pubs/sp/800/131/a/r2/final             MATCH
```

`id-map.txt` is generated with a machine check: the URL parsed out of the staged row's source cell
is compared with the URL parsed out of this wave's lane row for the mapped id; all ten `MATCH`. The
observed offsets are `-5, -3, +12`, so no constant shifted-id rule reproduces the map (recorded as
the arithmetic refutation).

Two staged rows are deliberately **not** adopted and get no lane id:
`S081` (Rev. 6 IPD PDF — substance, and the lane already holds the Rev. 6 IPD publication page as
`S049`/`S051`) and `S082` (Part 1 Rev. 5 PDF — substance, deferred with the Part 2/Part 3 substance
entry). Staged `S082` is cited **once in prose** by the withdrawal entry ("Rev. 5 remains the final
Part 1"); since that is a status claim, the cite is re-pointed to the Part 1 status row `S073`,
which supports it verbatim. `S073`'s `used-by` stays the guidance entry (single-entry rule); the
census parses only a `source:` line, so the prose pointer is unconstrained.

## Collision guard

Pattern (0-3 leading spaces, matching the census `table_re='^ {0,3}\|'`), run over the BASE
registry and the staged append, ids normalised, intersected:

- `grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}'` — BASE registry 72 ids, staged 172 ids,
  intersection **21** (`S052`–`S072`), written to `assimilation/collisions`.
- The intersection is non-empty and contains `S061`/`S062`/`S063` — exactly the staged ids this
  wave re-points. That is the justification for mapping by document.
- Re-run against the post-landing lane: intersection **31**; the delta is this wave's own
  `S073`–`S082` (`assimilation/collisions-current.txt`). A freshly assigned lane id that is also a
  staged-namespace number is not a collision, and conflating the two would make the guard useless
  after every append.

Falsification (`assimilation/guard-proof.txt`, fixture `assimilation/guard-fixture.md`): a registry
with a column-0 `| S002 |` row plus a two-space-indented `  | S002 |` duplicate gives

```
grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}'  →  | S001  | S002    | S002     (S002 seen 2×)
grep -oE '^\|[[:space:]]*S[0-9]{3,}'        →  | S001  | S002              (S002 seen 1×)
```

The column-zero-only guard reports the duplicate as absent; the 0-3-space guard catches it.

## Mirror validation

Mirror = BASE extracted with `git archive 76f4eea corpus` (read-only), ten registry rows inserted
after `S072`, ten capture rows appended, and the wave's own entries
(`build/knowledge/nist-key-management-{guidance-status,parts-withdrawal}.md`) placed at the
`used-by` paths. Copied to `assimilation/validate/corpus/`.

```
bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate \
  --file <mirror>/corpus/SOURCES.md
→ 16 × W04 (all pre-existing duplicate-url warnings, unchanged from BASE)
→ file  ok  <mirror>/corpus/SOURCES.md            exit 0

bash <mirror>/corpus/sources-census.sh verify --root <mirror>
→ SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 \
   entries_sourced=12 legacy=21 captures=82 inrow=16 inrow_only=0 inrow_nonreproducing=12)
→ exit 0
```

The lane census is the stricter gate (`src_field` reads only the **first** column-1 `source:` block,
so a multi-id entry must name every id there, and `SC_ENTRY_HEADER` rejects a second `source:` line).
Both wave entries already satisfy it; I did not edit them.

Landed tree, copied read-only and gated the same way (`validate/landed-tree-gates.txt`): fleet
exit 0, lane `CLEAN (rows=82 … entries_sourced=12 legacy=22 captures=82)` — `legacy=22` is the C1
seat's `prefreeze-controls.md`, not part of C2.

## Calibration findings

**1. The plan's C2 counter is wrong (M33-1/M33-3 class, in this plan).** The plan declares BASE
`captures=101` and target `captures=111`. Measured with the delivered counter at the frozen BASE:
`captures=72`, and post-change `82` (= 72 + 10). Rows (72→82), `entries_sourced` (10→12) and
`legacy=21` all agree with the plan; only `captures` does not, by −29. The counter cannot exceed one
capture row per registry id. Receipt: `assimilation/validate/base-vs-declared.txt`. This agrees with
the L1's independently produced `captures-101.controls.tsv` witness (their command also measures
72). I did not change the predicate; the plan's `captures=111` clause is simply unreachable.

**2. The CSRC HTML pages are response-coupled; two consecutive fetches differ at identical byte
counts.** I fetched each URL twice a second apart: 47203/45351/42741 bytes both times, different raw
`sha256`. So the eight HTML rows are labelled `decoded-http-body-volatile-v1`, and the stable
identity is the `rendered-text-v1` digest. ScoutNist's `build/nist-captures.tsv` (landed after this
seat started) captured the same ten URLs on the same day and agrees on URL, final URL, HTTP status,
date, byte count and **all eight HTML normalized digests**; it differs only on the raw digest and on
labelling those pages `decoded-http-body-v1`. `assimilation/reconcile-scout.txt` has the field-level
comparison.

**3. The two PDFs are stable** (`decoded-http-body-v1`, byte-identical to the campaign pins from
2026-10-23) but the declared normalizer cannot process them: `rendered-text-v1.py digest` on the PDF
body prints `RENDERED-TEXT-V1: SETUP (not strict UTF-8)` and exits 2. Their rows therefore declare
`normalization=raw-literal-v1`, `normalized_sha256=-`, and locate the quote with
`pdftotext -layout` (PDF text streams are compressed, so no raw-byte search exists). The landed
block instead carries `rendered-text-v1` digests for these two rows; those values are reproducible
only as `sha256(normalize_text(pdftotext output))` (I reproduced both: `00bae3f7…`, `36ce8fed…`),
i.e. through an undeclared pre-step, not from the decoded body the contract names. The census passes
them because it only shape-checks 64 hex. **This is the one place where the landed block and the
schema disagree; the L1 decides** — either relabel those two rows `raw-literal-v1`, or declare the
pdftotext representation in the contract.

**4. My own draft had one defect, now corrected.** My first version said the Part 2/Part 3 pages
carry only a "Superseded by" banner. The pages also say the withdrawal day in the same alert block
("Withdrawn on May 23, 2019", "Withdrawn on January 22, 2015") — present in my own capture;
`grep -c 'Withdrawn on'` → 1 on each. The delivered rows, their anchors and the capture quotes carry
that fact. The landed rows had already found it.

## Decisions recorded

- `recheck` cells are a plain cadence (`180d`/`90d`/`365d`); the staged rows' long `365d — <curl
  pipeline>` prose cells are illegal here (they carry `|` and fail `E09`), so the recheck command
  lives in the entry, not the registry row.
- No row carries `Fetch sha256:`; each anchor ends "captured 2026-11-04
  (corpus/source-fetches.tsv)", which keeps `SC_INROW inrow-pin-not-historical` silent. Verified: 0
  occurrences in the ten rows.
- Capture `sha256` values in `fetches-append.tsv` are **this seat's own** fetches. On volatile pages
  they legitimately differ from the scout's and from the landed block (same bytes, different
  response) — that is a point attestation, not drift. `row_identity_sha256`,
  `normalized_sha256`, URL, status and dates agree with the landed block.
- Quote verification is recorded per row: eight `rendered-text-v1.py locate` exit 0 / count 1, two
  `pdftotext` + `grep -c` = 1 (`assimilation/quotes.txt`). All ten row-identity digests recompute
  `MATCH` (`assimilation/row-identities.txt`).
- The staged withdrawal recheck wrote to `/tmp`; it was not copied into any lane artifact and not
  executed by this seat.

## Deltas against the block already landed

`assimilation/landed-diff.txt` is a cell-level diff (8–9 of 11 cells identical per row). The landed
rows are a rewrite with better evidence (an alert-block locator, the withdrawal day, the `(Final)`
line contradiction) and are not superseded by mine. Remaining substantive deltas: the PDF
`normalization` label (finding 3) and the capture raw digests (finding 2). Titles/scope/anchor prose
differ in wording only. The L1 should keep the landed rows and take from this seat only the two
findings above.

## Tooling

No install or upgrade was performed (curl, gawk, python3, pdftotext, sha256sum were already present),
so the operator's tooling directive is satisfied with no host change. Network use was limited to the
ten NIST URLs named in the plan, `curl -fsSL --compressed`, no credentials, no POST. No `op` call was
made; the-janitor handler is absent as expected and nothing under `~/.config` or any `op.env` was
read.

## Limits

- The four C1 clauses are other seats' work; this seat measured only the C2 counter they touch.
- The entries are the scribes' artifacts; this seat validated them, did not author them.
- `legacy` moving 21→22 on the landed tree is the C1 capability entry (`prefreeze-controls.md`), not
  a C2 effect.
