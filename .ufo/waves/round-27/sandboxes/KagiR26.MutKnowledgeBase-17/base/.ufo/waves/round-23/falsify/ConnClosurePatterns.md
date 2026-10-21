# ConnClosurePatterns — cross-lane closure/disposition pattern comparison (round 23)

Seat: connector, falsification wave. Axes: calibration (C1), freshness (C2/D7),
operability (C3/D9). Assignment: read-only scan of sibling lanes for
closure/verifier-disposition patterns; report reusable precedent or contradiction with
kagi's gate; no edits outside this file.

Everything below ran host-free: the only writes by this seat were `/tmp/r23probe*` copies
and this report. No git/jj mutation, no installs or updates (none performed), no network, no
host gate, no execution of a legacy verify or a host-bound claim row.

The tree moved **under this seat** while it ran, by another agent, not by any command here:

- attacked snapshot (hashes at 01:01, matching `MutClosurePointer.md`'s pre-probe values):
  `closure-dispositions.json` `f20f00d1…`, `round-23.md` `d5520988…`,
  `source-fetches.tsv` `ccc9ae6e…`;
- live at 01:03: `closure-dispositions.json` `5de116d1…` (D9's pointer repointed),
  `round-23.md` `bce51c92…`, `claim-ledger.tsv` `0d3d7500…`, fixture `SCORECARD.md`
  `23583252…` (untracked; mtime 01:03:02).

Every mutant names the snapshot it measured. The two probes that decide the findings —
M1 (captures deleted) and the M6 analogue (R23-01 repointed to an absent root) — were
re-run on the live 01:02 bytes and still print the identical `CLEAN` line with exit 0.

## 1. What I attacked

- `corpus/closure-dispositions.py` (gate, 406 lines) and `corpus/closure-dispositions.json`
  (15 rows), the C1 artifact pair.
- The source closure `corpus/lessons/round-22-verifier-spotcheck.md` and its pin
  (`closure-dispositions.json:4`).
- The two `fixed` rows whose pointers leave the lesson file:
  D7 → `corpus/source-fetches.tsv` (`closure-dispositions.json:91-95`) and, at the attacked
  snapshot, D9 → `corpus/claim-ledger.tsv` (`closure-dispositions.json:105-109`). Live at
  01:02:31 the D9 pointer was repointed to `corpus/fixtures/cells-hermetic/SCORECARD.md`,
  whose only D9 token is the HTML comment at line 1
  (`<!-- D9: hermetic cells fixture; executable via R23-01 in corpus/claim-ledger.tsv -->`).
- The claim row that certifies C1: `corpus/claim-ledger.tsv:60` (R23-02).
- Sibling patterns: kotodama round-26, tameshi evidence-disposition v1/v2, lore
  obligation-map contract, kake citation-disposition, audio r89 (observer, not a gate).

Method: replay the gate on the production tree, then run deletion/substitution mutants on
`/tmp` copies with `--root`, so the detector never sees a mutated production file.

## 2. Commands and exits (all reproduced)

Production, unmutated:

```
python3 corpus/closure-dispositions.py --selftest
  CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)                     exit 0
python3 corpus/closure-dispositions.py
  CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1
    no_action=5 rejected=0 pointers=15)                              exit 0
sha256sum corpus/lessons/round-22-verifier-spotcheck.md
  65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7   == json:4
grep -n 'closure-dispositions.py --selftest' corpus/claim-ledger.tsv  (no output) exit 1
grep -n 'round-22-verifier-spotcheck' corpus/stamps.tsv               (no output) exit 1
grep -c '^S0' corpus/source-fetches.tsv                                10        exit 0
bash corpus/sources-census.sh --selftest
  SOURCES_CENSUS_SELFTEST: PASS (59 cases)                             exit 0
bash corpus/sources-census.sh
  (stdout empty) corpus/sources-census.sh: line 242: S007: unbound variable   exit 1
awk -F'\t' 'NR>=37 && NR<=46 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
                                                                       9        exit 0
```

Two C2 measurements matter to the C1 reading and are reproduced here, not merely cited:
the 10 declared captures S017–S026 (`source-fetches.tsv:37-46`) span **9 distinct
`url` values**, not the 7 in the round's claim (S026 re-captures S021's page
`openbao.org/docs/concepts/tokens/` as a correction row); and the census gate itself exits
1 with an empty stdout at `corpus/sources-census.sh:242` (`SUPERSEDED` is never declared
under `set -uo pipefail` at `:107`), before any `SC_FETCH` check runs. The 59-case
selftest passes while the production path is dead. This is `MutFetchRemove.md` F1,
independently reproduced; it is C2's finding, not mine to own, but it decides what C1's
CLEAN may be cited for.

Mutants (each on a fresh `cp -a corpus /tmp/r23probeN/corpus`, command run from the lane
root with `--root /tmp/r23probeN`):

| # | mutation (scratch only) | result | exit |
|---|---|---|---|
| M1 | `source-fetches.tsv` reduced to its first two comment lines — all 10 declared captures S017–S026 deleted | `CLEAN (obligations=15 … pointers=15)` | 0 |
| M2 | same file, only the `D7` token removed from line 2 | `DISPOSITION POINTER-ID D7 corpus/source-fetches.tsv` → `FAILED (… unresolved=1)` | 1 |
| M3 | D4 pointer replaced by a new one-line file `corpus/bare-note.txt` containing `D4` | `CLEAN` | 0 |
| M4 | every disposition record under `## Routed defect dispositions` deleted; body replaced by `D1 D2 D3 D4 D5 D6 D8 — tokens only`; heading kept | `CLEAN` | 0 |
| M5 | anchored heading `## Routed defect dispositions` renamed `## Routed notes`, tokens kept | `POINTER-ANCHOR` ×7 → `FAILED (… unresolved=7)` | 1 |
| M6 | R23-01 (claim-ledger.tsv) command `--root corpus/fixtures/cells-hermetic` → `corpus/fixtures/absent`, note still says `routed D9` | `CLEAN` | 0 |
| M7 | D9 bullet deleted from the source closure **and** D9 row dropped **and** `source_sha256` re-pinned | `CLEAN (obligations=14 …)` | 0 |
| M7b | M7 without re-pinning | `SETUP (source digest mismatch …)` | 2 |
| M8 | D9 bullet text rewritten to “No debt: the outside seat withdraws this item …”, count preserved, re-pinned | `CLEAN (obligations=15 fixed=7 … pointers=15)`; stdout is byte-identical to R23-02's expected ERE | 0 |

M6 was measured at the snapshot; the same class on the live 01:02 bytes (D9 now pointing at
the fixture scorecard, R23-01 root repointed to `corpus/fixtures/absent`) still prints
`CLEAN (obligations=15 … pointers=15)`, exit 0.

M8 also passes the claim row mechanically: the mutated CLEAN line matches
`^CLOSURE_DISPOSITIONS: CLEAN \(obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15\)$`
(`corpus/claim-ledger.tsv:60`, re `True`).

M7 independently reproduces the bound probe in `MutClosureDropD5.md` (coordinated
source+pin edit → `obligations=14`, exit 0); M8 is the extension that matters: a
**count-preserving** rewrite of an obligation's text keeps even R23-02's externally pinned
count satisfied, so no gate in the tree distinguishes the outside reviewer's D9 from a
fabricated withdrawal.

## 3. What holds (confirmations)

1. The 15 obligations parse as claimed: D1–D9 (9, `^- D\d+` under `## Routed defects`),
   SPOT-01..05 (5, `admit`/`reject` cells under `## Discernment spot-check`), ADJ (1,
   `**ADMITTED.**` under `## Adjudication`). Row classes match their source classes; a class
   mismatch exits 2 (`:173`), duplicates and unknown kinds exit 2 (`:166`, `:170`).
2. Fail-closed behaviour is real for shape errors: missing/unknown obligation exit 1, source
   drift exit 1, stale pin exit 2, pointer escape/missing/anchor/id exit 1. The selftest
   exercises the real CLI (`subprocess.run` at `:279-288`), not a stubbed copy, and 13/13
   cases pass.
3. The anchor and the token are both required (M5, M2), and the source digest pin is
   enforced (M7b).
4. The gate is host-free and reads only the tree; no network, no `$HOME`, no subprocess
   other than its own selftest replays.

## 4. What does not hold — the docstring overclaim and its demos

`corpus/closure-dispositions.py:44-45` states: “A `fixed` pointer proves a reviewed record
exists at that path, not that its content is correct.”

M1, M3, M4 and M6 falsify the first clause as written. Not even a record is required:

- **M1** deletes the entire D7 evidence artifact (10 rows, `source-fetches.tsv:37-46`) and
  leaves only the header comment `source-fetches.tsv:2` (`# D7: bind every mined row…`).
  The `fixed` pointer survives on that comment. So C1's CLEAN can coexist with total
  absence of the C2 artifact it is dispositioning.
- **M3** replaces a six-line disposition record with a one-line file containing `D4`; the
  gate is green. Any file containing the id token is accepted as “the record”.
- **M4** deletes every disposition record in `round-23.md` §Routed defect dispositions and
  leaves a bare token dump; the gate is green because the heading still matches the anchor
  (`:113-114`) and the tokens still occur somewhere in the file (`:117-120`). The token need
  not be under the anchor — anchor and token are two independent, unrelated tests.
- **M6** shows the same for C3: D9's `fixed` pointer does not track R23-01's command. The
  fixture root can be repointed to an absent directory and C1 stays green; the only thing
  that reds is R23-01 itself (independently confirmed live by `MutFixtureDelete.md`).

The live tree then supplied the cleanest instance of the same defect without any mutation:
at 01:02:31 D9's pointer was repointed to `corpus/fixtures/cells-hermetic/SCORECARD.md`,
whose only D9 token is the HTML comment at line 1 naming where the claim row lives. The gate
prints CLEAN, exit 0. That is M3's bare-token substitution performed in production.

Mechanism, exactly: `resolve_pointer` (`:104-121`) checks path existence, a `#`-line
substring anchor, and — only for `kind == "fixed"` — a standalone-token regex anywhere in
the file (`:118`). No paragraph, heading scope, row identity, or byte binding.

**The obligation text is not anchored either.** The pin (`json:4`) lives in the same file
the gate verifies, and `stamps.tsv` does not cover the source closure (`grep` exit 1 above).
M8 rewrites the outside reviewer's D9 defect into its withdrawal, keeps the count at 15,
re-pins, and prints the exact CLEAN line R23-02 expects. M7 shows the count itself can be
lowered with re-pinning (14) — though there R23-02's `obligations=15` fails, which is the
only external anchor in the system: the count, not the identity, of obligations.

So the literal C1 claim (“15 outside obligations, one typed disposition each, fixed
pointers resolve”) is **true**; the round framing “outside decisions become obligations”
(`corpus/lessons/round-23.md:5`) and the docstring's “record exists” are **not** supported.
State the contradiction; do not average it.

## 5. Cross-lane precedent (reusable) and the contradiction

| lane | artifact | mechanism | line cites |
|---|---|---|---|
| kotodama r26 open-questions | `reports/round-26/open-questions/{build,verify}-dispositions.py` | verifier re-derives the row set from raw carriers “without trusting dispositions.json for the row set”; V4 re-runs each entry's evidence command and compares an expected token | verify `:11-13`, `:20`, `:87-91`; builder vocabulary `FIXED = "fixed-with-evidence"` |
| tameshi r14/r17 | `tools/evidence-disposition.py` | every input path pinned to sha256 in the dispositions document; integrity-first live check; v2 binds waived inputs to a committed anchor and refuses uncommitted edits; explicit “never executes receipt argv … does not prove any recorded command was rerun” | `:9-12`, `:18`, `:41-45`, `:1557`, `:1642` |
| lore | `corpus/tools/map_obligations.py` + `map-obligations-contract.json` | contract must pin every implemented selftest case; a contract that drops a pinned case exits 2 rather than passing on a subset | `:9-11`, `:796-810` |
| kake r20 | `.ufo/round-20/resume/citation-disposition.json` | each row carries `disposition` **and** an `evidence` string holding an executed observation (`test -e … => ABSENT`), not just a pointer | `locations[0].evidence` |
| audio r89 | `corpus/live/r89-critic/sigdisposition.py` | read-only observer of live process signal masks; not a ledger gate | `:1-11` |

Kagi's gate is the only one of the four ledger gates in which the evidence artifact can be
**deleted** while the gate stays green (M1). Every sibling binds evidence bytes or probes;
kagi binds a literal token.

**Contradiction to state, not smooth:** kotodama's V4 is the closest guarantee, and it is
**not directly transferable**. V4 runs each row's `command` through a shell
(`verify-dispositions.py:87`); kagi's evidence surface is `corpus/claim-ledger.tsv`, whose
rows include host-bound commands this round's contract forbids executing. A naive port
would either weaken the guarantee (only run “safe” rows, unstated) or violate the contract.
The compatible synthesis is tameshi's byte pin, not kotodama's probe: keep the gate
non-executing, but make the pointed bytes immutable-by-review.

## 6. Affected axes, second-order

- **Calibration (C1):** capability confirmed, but `fixed` is token-level. The claim row
  R23-02 certifies only the count-and-shape line; it cannot distinguish a token dump from
  the lane's actual disposition records (M4/M8 both match its ERE). Calibration should be
  read as “the lane recorded one typed row per obligation and each pointer nominally
  resolves”, no stronger.
- **Freshness (C2/D7):** C1's CLEAN transfers **zero** assurance to the 10 declared
  captures (M1), and the C2 gate that was supposed to carry that assurance is not running at
  this tree state: `bash corpus/sources-census.sh` exits 1 with empty stdout at `:242`
  (`SUPERSEDED` unset under `set -uo pipefail` `:107`), reproduced here and matching
  `MutFetchRemove.md` F1, while its 59-case selftest passes. Freshness is therefore
  evidenced only by static artifacts (`source-fetches.tsv`, `SOURCES.md`); the capture count
  is 10 but the distinct-URL count is **9, not 7**. Do not cite C1's green line as freshness
  evidence, and do not cite R21-02 as a live pass.
- **Operability (C3/D9):** D9's pointer is independent of R23-01's command. At the snapshot
  it pointed at `claim-ledger.tsv` and survived retargeting the row to an absent fixture
  (M6); live it points at an HTML comment inside the fixture scorecard (`SCORECARD.md:1`),
  which is one of the fixture's own inputs, not evidence that R23-01 executed. The M6
  analogue on live bytes is still CLEAN, exit 0. C3 assurance must rest on R23-01's exact
  `CELL_AUDIT` line, which is live and falsifiable (`MutFixtureDelete.md` killed two
  behavioral mutants); it must not rest on the D9 disposition.
- **Verification surface:** the 13-case selftest is not executed by any claim row
  (`grep` exit 1) and its case set is not pinned by any artifact — unlike kagi's own
  `R11-05` (`DRIFT_SELFTEST: PASS (13 cases)`) and `R11-09` (`SELFTEST: PASS (121 cases)`,
  `claim-ledger.tsv:19,23`) and unlike lore's contract. A case deletion would be silent
  except for the printed N. The same failure shape appears in C2: `SOURCES_CENSUS_SELFTEST:
  PASS (59 cases)` while `bash corpus/sources-census.sh` dies at `:242` before any finding.
  A green selftest over a synthetic path is not evidence that the production path runs.

## 7. Proposed move (one, bounded)

**Make each `fixed` row a byte pin, and pin its falsifiers.**

Add to every `fixed` row in `corpus/closure-dispositions.json` an additive field

```json
"pin": {"select": "^D4\\.", "sha256": "<hex>"}
```

where `select` is an ERE and `sha256` is the digest of the LF-joined lines of the pointer
target that match it (ordered as they appear). Scope the seven selectors to the evidence,
not the file:

- D1–D6, D8: `^D<N>\.` through the next `^D\d+\.` or `^## ` (the disposition paragraph);
- D7: `^S0` (the 10 capture rows; the D7 comment alone no longer suffices);
- D9: `^R23-01\t` (the claim row that actually enforces the fixture). D9's pointer must
  therefore stay on `corpus/claim-ledger.tsv`; the 01:02 move to the fixture
  `SCORECARD.md` points at an input, and a pin over the scorecard would certify the
  fixture's bytes, not that the row executed.

`resolve_pointer` recomputes the digest after the existing anchor/token checks and emits
`DISPOSITION POINTER-PIN <oid> <select>` → exit 1 on mismatch. Add the five mutants
M1/M3/M4/M6/M8 to the selftest as cases (18 total), and add claim row `R23-03`
`python3 corpus/closure-dispositions.py --selftest` expecting
`^CLOSURE_DISPOSITIONS_SELFTEST: PASS \(18 cases\)$`, which is the lore pattern applied to
kagi's native surface and closes the unpinned-case-count gap. R23-02's expected line gains
`pins=7`.

Why this is the non-obvious, compatible synthesis: the obvious repair is kotodama's V4
probe re-run, which kagi's contract forbids for claim-ledger rows; the pin borrows V4's
guarantee (“the evidence the disposition names cannot silently vanish”) without borrowing
its execution. It is additive — no schema break, no host coupling, no new artifact.

## 8. Risks

1. **Churn is the point, but it is real.** Every edit to a pinned record becomes a two-file
   edit (record + pin). Selector-scoping keeps unrelated claim-row or lesson edits from
   reddening the gate; whole-file pins would not.
2. **The pin is still re-computable by the same author.** It raises the cost of M1/M4/M8
   from “edit one artifact” to “edit the artifact and its pin”, and makes the change visible
   in the JSON diff; it does **not** create external authority. Only an outside commit
   (tameshi's anchor A) or a claim row whose expected digest lives in `claim-ledger.tsv`
   does. Do not sell the pin as authentication.
3. **Selector fragility.** Reformatting a D-paragraph changes the pinned bytes. That is
   intended (the record changed), but the selector rule must be stated in the docstring so
   the red is interpretable.
4. **Unfixed bounds must stay stated:** anchor is a `#`-line substring test
   (`:113-114`, also `MutClosurePointer.md` P1), non-`fixed` rows are path-only, obligation
   *identity* is not anchored (M8). The move does not touch any of these.
5. **Host safety:** verification remains hashing only; no row execution is added, so the
   “never execute a legacy verify or a host-bound row” contract holds.
6. **The pin is not a live census.** D7's pin would make the capture rows immutable, but
   while `SC_FETCH` crashes at `:242` the disposition still proves only that bytes exist.
   Landing the pin without the C2 fix invites citing C1 for freshness it cannot supply; fix
   the census first or state both bounds together.

## 9. Bound the C1 claim must state

> `fixed` means: a lane-relative pointer with no absolute or `..` component names a file
> whose bytes contain the obligation id as a standalone token, and if the pointer carries
> `#anchor`, some line beginning with `#` contains that substring anywhere in the file.
> It does not establish that the file contains a disposition record, that any record lies
> under the anchor, that the fix works, or that the obligation text is the outside
> reviewer's. The source digest is pinned only inside the file the gate verifies, so a
> simultaneous edit of the closure document and the pin — including a count-preserving
> rewrite of an obligation's text (M8) — yields CLEAN. Only the obligation count is
> externally anchored, by R23-02's expected line. The 13-case selftest is not executed by
> any claim row and its case set is not pinned.

C2 bound (reproduced here, owned by the C2 seat): the 10 captures S017–S026 are over
**9** distinct URLs, not 7 (S026 re-captures S021's page); `bash corpus/sources-census.sh`
exits 1 with empty stdout at `:242` (`SUPERSEDED` never declared under `set -uo pipefail`
`:107`), so `SC_FETCH` currently enforces nothing on production and R21-02's CLEAN regex is
unreachable. The 59-case selftest does not exercise that path. Any round statement that
cites `SC_FETCH` as freshness evidence must say so or the statement is false at this tree
state.

Adjacent closure bounds found by other seats and not re-run here:
`RevClosureExit.md` F1/F2 (invalid UTF-8 or unreadable pointer target exits 1 with a
traceback instead of the documented SETUP 2) and F3 (containment is lexical; a symlink
inside the root resolves outside and still yields CLEAN). The proposed pin does not change
any of these.

## 10. Verification for the integrator

Re-run, in order, from the lane root (all host-free):

```
python3 corpus/closure-dispositions.py            # CLEAN, exit 0, production unmutated
python3 corpus/closure-dispositions.py --selftest # PASS (13 cases), exit 0
```

To confirm the finding without touching production, replay M1 exactly:

```
rm -rf /tmp/r23replay && mkdir -p /tmp/r23replay && cp -a corpus /tmp/r23replay/corpus
sed -n '1,2p' /tmp/r23replay/corpus/source-fetches.tsv > /tmp/r23replay/sf \
  && mv /tmp/r23replay/sf /tmp/r23replay/corpus/source-fetches.tsv
python3 corpus/closure-dispositions.py --root /tmp/r23replay   # CLEAN, exit 0 expected today
```

After the proposed move the same replay must exit 1 with `DISPOSITION POINTER-PIN D7`.
The attacked snapshot was `closure-dispositions.json` `f20f00d1…`; live at 01:03 it is
`5de116d1…`. The lane moved during this seat, so re-run the gate and re-hash immediately
before landing rather than trusting either value.
