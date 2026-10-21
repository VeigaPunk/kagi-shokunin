# ClaimR21X02 — R21-02 semantic audit (read-only)

Observed revision: HEAD `d218603` (2026-10-20), tree clean except untracked
`.ufo/waves/round-23/`. No production file was modified; no gate was executed.
Counts below are independent static parses of the same inputs the row's command
reads, not execution of `corpus/sources-census.sh`.

## Row under audit — exact

`corpus/claim-ledger.tsv:52`

```
R21-02  bash corpus/sources-census.sh
  ^SOURCES_CENSUS: CLEAN \(rows=23 A=21 B=0 C=2 queued=1 mined=21 rejected=1 entries_sourced=4 legacy=21\)$
  exit 0  timeout 60
  note: "current registry snapshot: original16 plus S017-S023, seven A/mined
  correction/feature rows but only two distinct newly registered URLs. Late
  S022/S023 consumed by source-errata lesson; knowledge remains four sourced
  and21 legacy. Original source rows retained; no network/content validation
  by this command."
```

Implementation: `corpus/sources-census.sh` (`verify()` at :130; verdict emitted
at :236-240; `exit 0` only when `FINDINGS=0`). Inputs: `corpus/SOURCES.md`
registry rows at :7-29, all 25 `corpus/knowledge/*.md` entries, and every
`used-by` file.

## 1. Is the expected exit / last line / timeout justified? — SUPPORTED

- Exit 0 is reachable only on `FINDINGS=0` (:236-237); every finding path falls
  through to `FAILED (findings=K rows=N)` exit 1 (:241-242). `SETUP` is exit 2.
  So exit 0 and the CLEAN last line are two consistent conditions, not one.
- Static re-derivation of the pinned line (confidence: high):
  - registry rows :7-29 = **23**; tier A = 21, C = 2 (S005 :11, S008 :14);
    B = 0; status queued = 1 (S005), mined = 21, rejected = 1 (S008);
  - `corpus/knowledge/*.md` = **25** files; column-1 `source:` present in 4
    (`onepassword-machine-credentials.md`, `sops-age-key-rotation.md`,
    `vault-openbao-token-lease-lifecycle.md`,
    `feature-bound-credential-review.md`) → `entries_sourced=4 legacy=21`
    (counting rule `sources-census.sh:208-212`).
  - All nine literals match the ledger row exactly; the ERE is `^…$`-anchored
    with escaped parens, so no substring/partial match can pass.
- Timeout 60 s: the gate is awk/grep over a 118-line registry and 25 small
  entries, with no network and no `op`/handler. Persisted executed receipt
  `.ufo/waves/round-22/final-verification.json` (R21-02 block) records exit 0,
  the identical last line, `seconds: 0.071`. 60 s is ~800× headroom; a timeout
  is not a plausible pass path.
- Note claims: "original16 plus S017-S023" (7 rows, all A/mined) and "two
  distinct newly registered URLs" are supported by
  `.ufo/waves/round-22/registry-census-details.json` `added_ids` (S017-S023),
  `new_urls` (exactly the two Broker feature pages), and `after` histograms
  matching the current row. `immutable_original_rows_equal: true` in that
  receipt is a *point-in-time* BASE-vs-current comparison, not a re-runnable
  row (see §6).

## 2. `[substrate]`, SKIP-SELF, hermetic mode — supported with one hard constraint

- **Substrate deferral: correctly absent.** R21-02's note has no `[substrate]`
  tag and the command touches no host substrate (no `op`, no
  `~/.local/bin/the-janitor`, no network). Deferral is gated on the note text
  (`claim-ledger.sh:131-148, 416-419`). Tagging this row would let handler
  absence count it `DEFER` and remove the only live registry-conformance check;
  the untagged state is the correct one. The round-22 verifier's 12 skipped
  host/substrate IDs (`corpus/lessons/round-22-verifier-spotcheck.md:72-76`) do
  not include R21-02, and it was executed in `final-verification.json`.
- **SKIP-SELF: does not apply.** `cells_evidence` skips only rows whose command
  contains `claim-ledger.sh` (`claim-ledger.sh:816-820`). R21-02 runs
  `sources-census.sh`, so it is re-run live inside `cells`. That is correct:
  there is no recursion (`sources-census.sh` never invokes the ledger), and the
  live re-run is the intended teeth for a snapshot row. A future change making
  the census call `claim-ledger.sh` would silently drop it from the cell audit;
  the self-skipped set should stay pinned.
- **Hermetic mode: root-relative by construction, and volatile to fixture
  fidelity.** `sources-census.sh` resolves `ROOT` from `SCRIPT_DIR/..`
  (script path), not from the ledger's `--root`; the row command is also
  cwd-relative (`verify_claims` runs `cd "$ROOT"`, `claim-ledger.sh:426-427`).
  A hermetic cell therefore must stage the census script *and* its inputs under
  the fixture root. If the script is absent → bash exit 127 → false FAIL; if
  present but the fixture registry/entries differ → count mismatch or `SETUP`
  → false FAIL. See §4.

## 3. C1 closure-disposition integration — what must be retained

Pointer graph that C1 must follow, not merely count:

1. `corpus/knowledge/onepassword-machine-credentials.md:5`,
   `sops-age-key-rotation.md:6`, `vault-openbao-token-lease-lifecycle.md:6`,
   `feature-bound-credential-review.md:4` each declare `Reverify: R21-02`.
2. `R21-02` resolves to `corpus/claim-ledger.tsv:52` → command →
   `corpus/sources-census.sh` → `corpus/SOURCES.md` :7-29, all
   `corpus/knowledge/*.md`, plus used-by lessons
   (`corpus/lessons/round-22.md`, `corpus/lessons/round-22-source-errata.md`).
3. The disposition class is **citation-chain structure only**. All four entries
   state the bound in prose, and `feature-bound-credential-review.md:30-32`
   repeats it: "`R21-02` checks the source-registry citation chain only. It does
   not reopen pages or establish vendor truth." C1 must not upgrade this row to
   content/freshness closure; each entry's `recheck:` is the content clock.
4. **Membership is not closure.** `docs` mode resolves the id through
   `is_row()` (`claim-ledger.sh:619-624`, id-membership only) and counts
   `row_linked` (`:911-915`) without running anything. A C1 checker that stops
   there reproduces the "claim-count assurance" defect. It must reach the
   command and its last line (or delegate to `cells`, which does).
5. **Stated blind spots C1 must preserve:** 21 legacy entries are outside every
   census check including the credential scan (`sources-census.sh:208-212`
   legacy branch; selftest case `legacy-not-scanned` at :367); and the census
   never parses the `supersedes` declarations on S019/S020/S022/S023
   (`SOURCES.md:25,26,28,29`), so a CLEAN cannot mean "active citations avoid
   superseded rows". Both are documented boundaries, not hidden edges.

## 4. C3 hermetic cells — retention requirements for this row

1. Stage `corpus/sources-census.sh` at the same relative path in the cell root,
   plus a byte-faithful `corpus/SOURCES.md` (23 registry rows, no extra
   `| S…` lines outside `## Registry`), exactly 25 `corpus/knowledge/*.md`
   files with exactly 4 column-1 `source:` lines, and both used-by lesson
   files. Anything less turns the row into a fixture-configuration failure.
2. Do **not** tag R21-02 `[substrate]` to quiet a cell. `CELL_AUDIT: CLEAN`
   prints `row_deferred=` but does not fail on it (`claim-ledger.sh:1006-1012`);
   a wrong tag would report CLEAN with the row never executed.
3. The proof should assert R21-02 appears in `rows_run` (no `DEFER R21-02`
   line), not just that the cell is CLEAN — otherwise `row_deferred=1` is an
   accepted false-clean path.
4. A reduced fixture (e.g. the 4-row selftest base shape) **must** fail the
   pinned line — that is the row's intended falsifiability, not a defect. The
   hermetic cell must be a production-fidelity corpus copy, or R21-02 must be
   explicitly excluded and the obligation recorded as dropped (prefer the
   former; C3's mandate is "preserve all command-row obligations").
5. No live substrate command is needed or permitted: the census is pure
   file-reading, so the cell is host-free by construction.

## 5. One consumer-visible false-clean risk + minimal synthetic falsifier

**Risk (false-clean): the pinned line is a histogram, not an identity.** The
row's own note asserts "Original source rows retained", but the command checks
only shape/enums/status/tier counts and citation reciprocity. No check compares
the id set. A same-tier, same-status, uncited row can be renamed and the row
still prints the byte-identical pinned line.

**Minimal synthetic falsifier (proposed; must be run by the integrator in a
scratch copy, not executed here):**

1. Copy the repo to a scratch dir.
2. In `corpus/SOURCES.md`, change the id cell of the S005 row (`:11`) from
   `S005` to `S024`; change nothing else. S005 is tier C / `queued` /
   `used-by —`; it is cited by no entry (only SOURCES.md and historical
   plans/lessons mention it), so `SC_ENTRY_CITE`, `SC_MINED_UNUSED` and the
   used-by checks are untouched.
3. Run `bash corpus/sources-census.sh`.
4. Expected under the note's claim: a finding (retired/replaced id) or a
   non-CLEAN verdict. Observed by construction: identical
   `SOURCES_CENSUS: CLEAN (rows=23 A=21 B=0 C=2 queued=1 mined=21 rejected=1
   entries_sourced=4 legacy=21)`, exit 0 — the id rename is invisible.

Consumer path: `SCORECARD.md:643-645` cites `R21-02` as evidence for the
coverage/operability/freshness cells, so CLEAN is booked as registry
conformance; a replaced original row with preserved histograms would pass.

**Fix (append, do not rewrite):** keep the current histogram line as the
historic snapshot and append a successor row that pins the id set, e.g.
`grep -oE '^\| S[0-9]{3}' corpus/SOURCES.md | tr -d ' |' | paste -sd,`
expecting `S001,…,S023`, or extend the census verdict with an id-set digest.
Round 22's own plan recommended appending a successor and keeping the historic
cell (`.ufo/waves/round-22/build/ConnectSources.md:54,70`); the landing
rewrote R21-02 in place twice instead (journaled, see §6), so the identity
property remains unenforced by any current row. This is a row-level instance of
the already-declared `--mutate` ceiling in `SCORECARD.md:380-390` ("the gate
measures whether a row is well-formed and executes, not whether its assertion
is meaningful"); it is not a new defect class.

## 6. Historical vs current evidence (exact boundaries)

- **Current (authoritative for the live row):** `corpus/claim-ledger.tsv:52`;
  `corpus/SOURCES.md:7-29`; 25 knowledge entries (4 sourced / 21 legacy);
  `corpus/stamps.tsv:61` pins SOURCES.md (sha `a5e1c13e…`, 118 lines, 22843
  bytes) — but the stamp is enforced by `claim-ledger.sh verify`, not by
  R21-02 itself.
- **Executed receipt:** `.ufo/waves/round-22/final-verification.json` R21-02
  block — exit 0, exact last line, `seconds 0.071`. Caveat: the file's `.h1`
  is `8ada17a5` while the measured bytes are `4be5da3`; that discrepancy is
  already routed as D6 (`round-22-verifier-spotcheck.md`). Treat the receipt as
  evidence of the executed epoch, not as a byte-bound HEAD proof.
- **Migration history (16→21):** `.ufo/waves/round-22/pin-migrations-integration.json`
  `claim_changes` R21-02 old (`rows=16 A=14 … entries_sourced=3`) → new
  (`rows=21 A=19 …`).
- **Migration history (21→23):** `.ufo/waves/round-22/pin-migrations-falsifier-repairs.json`
  `claim_changes` R21-02 old (`rows=21 A=19 …`) → new (`rows=23 A=21 …`,
  current text). This is the only receipt whose `new` equals the live row.
- **Stale intermediate artifacts, for the record:** `safe-row-plan.json` still
  pins `rows=21`; `pin-migrations-integration.json` `claim_changes.new` also
  still says `rows=21`. A reader who follows only the file named by
  `round-22-verifier-spotcheck.md:87` ("each carry an old/new journal in
  `pin-migrations-integration.json`") sees the intermediate value; the final
  pair lives in the falsifier-repairs receipt. Add a receipt index or a row
  note pointing at the second migration.
- **Rejected/one-off observations, not current evidence:**
  `.ufo/waves/round-22/build/Source08.md:83` saw `rows=20` CLEAN and a
  mid-write `FAILED (findings=1 rows=21)`; `registry-census-details.json`
  `immutable_original_rows_equal: true` is a point measurement at `4be5da3`.
- **Round-22 source conformance:** `SCORECARD.md:811` before
  `rows=16 A=14 …` → after `rows=23 A=21 …`; consistent with the current row.

## 7. Limits / unresolved

- No gate was executed (contract). The verdict justification rests on
  independent static counts plus the committed executed receipt; the two agree.
- I did not read the BASE tree directly (no live Git operations); identity
  retention is taken from the committed `immutable_original_rows_equal` flag,
  which is a receipt, not a re-runnable row — the point of §5.
- The `supersedes` semantics are prose only; whether S006/S007's remaining
  citations in `onepassword-machine-credentials.md` are adequately bounded is a
  C2 (content-provenance) question outside this row; the entry does carry an
  explicit round-22 erratum and errata are append-only.
- Tool installs: none. No network reads; no source-body dumps.
