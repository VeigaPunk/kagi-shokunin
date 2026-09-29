# Claim ledger, revision stamps, citation durability, claim ids, scorecard cells

Source basis: written 2026-09-28 (round 11) from the shipped gate itself —
`corpus/claim-ledger.sh` (436 lines at the frozen wave revision, sha256
`d63c60b0821b5388…`; the shipped revision is stamped in `corpus/stamps.tsv`),
`corpus/claim-ledger.tsv` (9 rows at that revision; 14 at round-12 close, 17 at
round-13 close), and the runs quoted below. Nothing here is
copied from a draft: every verdict string in this entry was produced by a
command in the round-11 evidence set; the round-13 classes (`Class 4`, `Class 5`)
carry their own measured before→after table below.

## Why this gate exists (the measured calibration failure)

Calibration was the lane's lowest cell after round 10. Three facts set the
score, each checkable against the repo, not felt:

- The round-10 *report* made 62 claims that were adjudicated **by hand** by one
  reviewer lane (49 VERIFIED / 9 STALE / 4 UNCHECKABLE) because no claim carried
  a command. A claim that carries no command cannot be re-checked by the next
  reader at a fixed cost.
- Two committed citations named session-scoped scratch: the scratch URI
  `local://round-10/connector.md` at `SCORECARD.md:54`, and a second scratch
  scratch URI `local://round-10/critic.md` at `corpus/lessons/round-10.md:50`. Neither
  resolves in a fresh session; the protocol lane logged the same class for
  another repo (`.ufo/reports/round-10/protocol.md` D-19, OPEN, 9 occurrences).
- The scorecard cells were self-scored. `AXES.md` asks the score to be "the
  strength of a *verifiable* claim about this repo" — with prose pointers, the
  reader re-derives the claim instead of re-running it.

The gate makes the three classes mechanical: a **revision** is a hash row, a
**claim** is a command row with a verdict, a **citation** is a resolver result.

## Class 1 — revision stamps (`corpus/stamps.tsv`)

```
path <TAB> sha256 <TAB> lines <TAB> bytes
```

- One row per artifact the round cites. `lines` is `wc -l` (a file without a
  trailing newline counts one less — the same measurement is used when writing
  and when verifying, so the comparison is consistent; it is a *line-count*
  assertion, not a byte assertion, though sha256 covers bytes too).
- `verify` recomputes sha256 + lines and prints `STALE <path> sha=<old12>-><new12>`
  or `MISSING <path>` (or `NOT-A-FILE` for a symlink/non-regular file) — one line
  per drifted artifact, exit 1; `CLAIM_LEDGER: CLEAN (claims=N stamped=M)` when
  both classes pass.
- Regenerating is `stamp PATH... [--out F]` — a reviewed commit. There is no
  auto-re-pin: a drifted stamp is a question ("was this edit intended?"), and
  the default answer must be visible in the report, not silently repaired.
- Refusals: absolute path args, whitespace/TAB in a path, the output file
  itself, missing files, non-regular files. `--out` is not constrained to the
  repo (a wave-input stamp may be written to scratch); the *committed* default
  is `corpus/stamps.tsv`.

Why stamps and not "git is enough": a reviewer must be able to state the
revision it read. `git` gives that only if the artifact is committed; the
stamp makes it answerable while the round is still in flight (the L2 wave is
dispatched against a stamped revision, and the round report cites the hash
prefix). Round 10's loss was exactly this: the critic read an in-flight
mid-edit revision and four of its clauses described files that never shipped.

## Class 2 — claims (`corpus/claim-ledger.tsv`)

```
id <TAB> command <TAB> expect <TAB> exit <TAB> timeout <TAB> note
```

A claim passes **only when both hold**:

1. the command's exit code equals `exit` (exact integer; `R11-06` carries
   `1` because the recorded baseline of the transcript gate *is* a firing
   gate); and
2. `expect` (an ERE) matches the **last non-empty line** of combined
   stdout+stderr.

The last-line half exists because a verdict is a summary line by construction:
a command that prints `SURFACE_CENSUS: CLEAN` at minute one and dies later
still ends with its own error or progress line, so the token alone cannot pass.
`reason=verdict-not-final` is the verdict for that class, and selftest case 16
pins it with a fixture that prints the expected token then a trailer.

Per-row verdicts: nothing on success (`OK` is silence), else
`FAIL <id> reason=verdict-not-final|exit-mismatch|timeout exit=<rc> [want=<n>]`,
or `POLICY <id> reason=first-token:<w>|metachar|backslash|empty-quotes|inline-shell|denied-verb:<v>`.
Exit codes: 0 clean · 1 any FAIL/STALE/MISSING · 2 any POLICY/malformed
row/missing file. The gate never echoes a claim's output (that output can
contain anything); it prints only id, reason, exit code and timeout.

Timeouts: each row declares its own bound (300 s for the gates, 120 s for
drift); the runner adds `timeout -k 5`, so a hung claim is killed at
`tmo`+5 s and reported `reason=timeout` with rc 124 (TERM) or 137 (KILL).

The shipped rows (round 11) verify the three sibling gates end-to-end:
`surface-census.sh` verify/`--verbs`/`--selftest`, `drift-pins.sh`
verify/`--selftest`, `transcript-scan.sh` baseline/`--selftest`, plus this
gate's own `citations` and `--selftest` modes. A future claim about a knowledge
entry (a sqlite row floor, a JSON key set) is a row here — the ledger is the
place claims go to be re-runnable.

## Class 3 — citation durability (`citations`)

Checked classes, by token shape (a token is the first word inside a backtick
span, after stripping `./`, trailing `,.:;` and line refs `:N`, `:N-M`,
`:N,:M,…`, `:N-M,:K`):

| Shape | Resolves against | Example |
|---|---|---|
| `corpus/…`, root docs (`SKILL.md` …) | `$ROOT/…` | `corpus/knowledge/drift-gate.md:12-20` |
| `knowledge/…`, `lessons/…` | `$ROOT/corpus/…` (the two corpus shorthands) | `lessons/round-9.md` |
| `<lane>-shokunin/…` | `$ROOT/../…` (sibling lane repo) | `kotoba-shokunin/corpus/knowledge/alwayson-checklist-round7.md:25-33` |
| `ufo/…`, `.ufo/…` | `$ROOT/../.ufo/…` (main-repo tree) | `.ufo/reports/round-10/protocol.md` |
| `{a,b}` brace set | every alternative must resolve | `lessons/round-{4,5}.md` |

Anything else is a *reference*, not a path, and is not checked by rule: bare
filenames (`PROTOCOL.md`, `janitor.md`), host paths and fragments
(`~/.config/…`, `xdg-data/…`, `usr/bin/op`), API routes (`v1/models`,
`session/{id}/shell`), `$VAR/…` templates. No rule can anchor those without a
host, and the corpus convention is a full path at first mention.

A token that fails to resolve, and any session-scoped scratch URI — `local://`,
`artifact://` / `agent://` / `proc://` (all scratch) — fails the run as
`UNRESOLVED` / `EPHEMERAL` — **unless the citing line labels it** with one of the markers `scratch`, `ephemeral`,
`relocat`, `formerly`, `no longer`, `removed`, `renamed`, `historical`. A
labelled token prints a `LABELED <doc>:<line> <token> (session URI|unresolved, labelled on its line)` line and counts into `labeled=`. The line is the audit path: `labeled` is a count of *tolerated* tokens, not of defects.

The marker rule is the honest half: dead citations happen (a file is moved,
a scratch artifact is not retained), and the rule is not "no dead citations
ever" but "**a dead citation must be labelled dead where it is cited**". The
`labeled=1` residual in the round-11 baseline is real: the round-5 aggregator
lesson cites the **relocated** `.ufo/reports/round-2/AGGREGATE.md` on a line
that already says so — labelled, resolved, kept.

Both counter kinds mean the same thing mechanically, which is why they are one
class: the reader's question is "can I open this?".

## Class 4 — claim ids (`verify`)

Round 11 built a ledger that could only be iterated **forward** (rows →
commands). A document citing an id that no row defines was therefore invisible:
at the round-12 close, a doc citing the fabricated `R13-99` produced `CITATION_GATE: CLEAN`,
exit 0. `verify` now resolves the other direction:

- **Vocabulary.** `R<digits>-<digits>`, matched as a **whole word**
  (`[A-Za-z0-9_-]*R[0-9]+-[0-9]+[A-Za-z0-9_-]*`). The *word* is what must be a
  row id, so the illustrative `R12-03a` and `xR12-01` are `MISSING-ID` rather than resolving as
  their prefix, and a range notation (`R12-01..03`, which this corpus uses)
  validates its head only — the tail is prose, not a claim. Bound: the
  vocabulary is upper-case `R`; a lower-case `r13-99` is not scanned for.
- **Rows come from row lines.** An id named in a *comment* in
  `corpus/claim-ledger.tsv` creates no row, so the header comments' `R11-06`
  and `R11-10/11` mentions are harmless only because real rows also exist
  (pinned by selftest `verify-comment-id`).
- **Failure.** `MISSING-ID <doc>:<line> <id>` per occurrence, the count in the
  summary (`unresolved_ids=`), exit 1. Rows cited **nowhere** are `ORPHAN`s:
  counted, informational, listed with `--orphans`. At the round-12 close five
  rows were orphans (`R11-01/02/04/05/07`) and nothing in the repo could say so.
- **Empty id universe is a setup error.** Zero rows ⇒ exit 2.

## Class 5 — scorecard cells (`cells`)

The round-11 plan ("each score cell names the claim ids it rests on") is what
this mode enforces, and it is deliberately narrower than the plan's wording:

- **Checked set.** A table row inside a `## Round <N> — pre-move|post-move`
  section whose first cell — whitespace and `*` stripped — is exactly one of
  `depth coverage operability freshness calibration adjacency`. The `Retired`
  table and every other section are prose. Every recognised section must carry
  **all six axes exactly once**; a missing or re-spelled row is a setup error
  (exit 2), because the global count cannot see one section losing rows while
  another keeps the total positive (round-13 planner T2-1/T2-2; the mutation
  lane showed a partial rename shrinking 12 cells to 11 in silence). A heading
  that starts `## Round` but does not match the expected shape (`## Round 13
  pre-move`, a colon, an en-dash) is refused outright — silently skipping it
  would drop six cells while the count stayed positive (round-13 sentinel).
- **Pointer.** A resolving claim-row id, or a path listed in
  `corpus/stamps.tsv`. Membership is an **exact first-field match** — the first
  implementation used an unanchored substring search and every score digit
  (`7`, `9`) matched a sha256/line field followed by a TAB, so all 48 real
  cells looked pointed (see the lesson; pinned by selftest
  `cells-numeric-anchored`).
- **The teeth.** A pointer counts only if it still holds. The cited rows are
  re-run through the ordinary claims machinery (exit equality + last-line
  verdict ⇒ a cell cannot rest on a failing row: `row_failures`), and the cited
  pinned artifacts are re-compared against their stamp rows (`STALE-POINTER`,
  `MISSING-POINTER`). Membership alone was the round-13 critic's executed
  counterexample: a poisoned stamp row (`deadbeef/0/0`) and a cell citing an
  unrelated row both passed a membership-only audit.
- **Non-vacuity.** Zero checked cells, a scorecard outside the id audit's doc
  set, or a scorecard whose cells cite no row at all are each exit 2 — a green
  run must never mean "there was nothing to check".
- **Nesting.** `cells` is reachable from a claim row, so a row that re-invokes
  this gate is **skipped** inside the cell audit (`SKIP-SELF`, counted as
  `self_skipped`) and a nested `verify` is refused outright (exit 2): the audit
  re-runs the rows a scorecard cites, and a scorecard may cite the audit.
  Bounded by construction, not by luck (scribe lane F3).
- **Summary.** `CELL_AUDIT: CLEAN (cells=N row_pointed=R stamp_pointed=S
  uncited=0 missing_ids=0 rows_run=R row_failures=0 stale_pointers=0
  self_skipped=K orphans=O)`. `row_pointed`/`stamp_pointed` are independent
  counts, so the line itself shows how many scores rest on a re-run command
  rather than on a frozen document.

## Round-13 before → after (same file, measured both ways)

| Claim | Before (round-12 close) | After |
|---|---|---|
| an id a doc cites that no row defines | invisible: `citations --docs <doc citing the fabricated R13-99>` ⇒ `CLEAN`, exit 0 | `MISSING-ID <doc>:1 R13-99` + `CLAIM_LEDGER: FAIL … unresolved_ids=2 labeled_ids=0`, exit 1 |
| a scorecard cell with no pointer | invisible: no mode read the file | `UNCITED SCORECARD.md:38 depth`, 20 of 48 cells, `CELL_AUDIT: BROKEN … uncited=20`, exit 1 |
| a cell citing a row that fails today | not expressible | `row_failures=1`, exit 1 (selftest `cells-row-fails`) |
| a cell citing a pin that has moved | not expressible | `STALE-POINTER corpus/claim-ledger.sh`, `stale_pointers=1`, exit 1 |
| a section missing an axis | not expressible | `scorecard section '## Round …' does not carry all six axes exactly once`, exit 2 |

## Round-11 before → after (same defects, measured both ways)

| Scan | Result |
|---|---|
| gate v1 rule set, pre-fix docs | `CITATION_GATE: BROKEN (cites=268 docs=37 unresolved=3 ephemeral=2)` — v1 also treated bare names (`README.md`, `AGENTS.md.bak-20260908`) as paths |
| gate v2 (class-aware, pre-fix docs) | `BROKEN (cites=374 docs=37 unresolved=2 ephemeral=2 labeled=1)` — the two remaining *doc* defects plus one gate bug (line-ref stripper) |
| after the doc fixes + gate fixes, end of round | `CITATION_GATE: CLEAN (cites≈500 docs=39 unresolved=0 ephemeral=0 labeled=13)` — `cites`/`docs`/`labeled` move with **every** edit (this entry and the round-11 lesson are themselves scanned), so the shipped figure is quoted in the round report next to the revision stamp it was measured at; the ledger row asserts only the verdict + the non-zero shape of the counts |

Defects fixed: `SCORECARD.md:54` and `corpus/lessons/round-10.md:50` (dead
scratch URIs → durable pointers, with the class named in place);
`corpus/README.md:61` (kotoba's file cited as if local → `kotoba-shokunin/…`,
which the sibling class now resolves); `corpus/README.md:157` (bare host file
`AGENTS.md.bak-20260908` → `$HOME/.agents/…`). The gate bug: the line-ref
stripper's greedy `.*` left the separator behind (`…:136,:164,`), fixed by
dropping the trailing `[,:]` after each match — found by real data
(`corpus/lessons/round-6-aggregator-audit.md:110`), pinned by selftest case 21.

**Counting a gate that reads its own docs.** `cites`/`docs`/`labeled` change
whenever any scanned doc changes — including the LOG entry that quotes them. So
this corpus quotes those figures with `≈` and lets the *verdict* and the count
*shape* (non-zero, `unresolved=0`, `ephemeral=0`) be the claims; the exact tuple
is measured once, last, and quoted in the round report (which is outside the
scanned set). Measured this way in round 11: `CITATION_GATE: CLEAN (cites=517
docs=39 unresolved=0 ephemeral=0 labeled=13)`.

## Reproduction

```
bash corpus/claim-ledger.sh verify      # stamps + claims + claim ids → CLAIM_LEDGER: CLEAN (claims=17 stamped=33 ids=17 cited=17 labeled_ids=13 orphans=0)
bash corpus/claim-ledger.sh citations   # citation durability → CITATION_GATE: CLEAN (cites=700 docs=43 unresolved=0 ephemeral=0 labeled=13)
bash corpus/claim-ledger.sh cells       # scorecard audit    → CELL_AUDIT: CLEAN (cells=60 row_pointed=25 stamp_pointed=41 uncited=0 missing_ids=0 rows_run=14 row_failures=0 stale_pointers=0 self_skipped=3 orphans=0)
bash corpus/claim-ledger.sh --selftest  # 72 scratch cases   → SELFTEST: PASS (72 cases)
bash corpus/claim-ledger.sh stamp corpus/claim-ledger.sh …    # re-pin (reviewed commit)
```

## Bounds (what this gate cannot see)

1. **Claims inherit the runner's environment.** A claim can be green on this
   host and red on another (paths, ports, host state). `R11-06` is the sharp
   case: the transcript baseline is host state, and a legitimate new session
   would flip it — the note says to re-baseline, not to trust it as a
   regression.
2. **The deny-list is a text guard, not a sandbox.** It refuses a closed list
   of verbs and every shell metacharacter; a future row is reviewed by a human,
   and review is the real control. (The round-11 sentinel and labrat lanes
   attacked this surface; see the lesson.)
3. **The last-line rule trusts the *gate's own* summary line.** If a sibling
   gate's summary degrades while still printing the expected token (e.g. a
   `CLEAN` line over zero probes), the claim is green. The countermeasure is
   the sibling gate's own selftest, not this one.
4. **A stamp is a point check.** Restoring a file to the stamped bytes (after a
   real change) re-verifies; the stamp says "this is the revision I read", not
   "this file never changed".
5. **No mode in a stamp row.** A mode-only change under an unchanged hash is
   invisible here; `surface-census.tsv` owns modes for the host surfaces.
6. **Bare names are unchecked by rule** (see above) — a stale `PROTOCOL.md`
   reference is invisible to this gate by construction, stated here so the
   bound is not discovered later as a surprise.
7. **Markdown only.** The shell scripts' own citations (header comments, `# ---`
   sections) are not scanned; scripts cite via variables and are covered by the
   census/drift gates.
8. **One root.** `--root` defaults to this repo; the sibling/`.ufo` classes
   assume the checkout layout (`…/shokunin/<lane>-shokunin`, `…/shokunin/.ufo`)
   — a relocated checkout turns those rows UNRESOLVED, which is a real signal
   about the reader's tree, not about the cited file. Observed end-to-end in
   round 11 on a `git clone` of this repo into `/tmp`: `--selftest` is
   `PASS (39 cases)` and `verify` is `FAIL R11-08 reason=exit-mismatch exit=1
   want=0` (the `citations` scan cannot resolve the sibling/`.ufo` citations
   without the fleet present). That is the bound working, not a gate bug — and
   it is why `R11-08`'s note names the layout requirement.
9. **Claims are not scheduled.** Nothing runs `verify` on a timer; the round
   discipline is "run it before you cite it".
10. **`POLICY` rows are not run at all** — a policy refusal is a failure of the
    ledger, not of the claim (exit 2, distinct from FAIL's exit 1).
11. **`bash <reviewed script>` is still arbitrary execution.** The allowlist
    (five commands) and the refusal of `bash -c`, backslashes, empty quote pairs
    and denied verbs shrink the surface that the round-11 sentinel and executor
    probed; they do not close it. The control is that the ledger is a reviewed,
    committed file.
12. **`--out` can overwrite a regular file** and an `expect`-crafted row is a
    1-bit oracle over anything the runner can read (sentinel F6/F8). Both are
    operator/review surfaces, not sandbox properties.
13. **The selftest cannot prove its own honesty.** It exercises the shipped code
    paths on scratch data; the *default wiring* is pinned by the claim row that
    runs the real docs (`R11-08`) and by the case count (`R11-09`), and a liar
    stub that prints `SELFTEST: PASS` is caught by the reviewer lane reading the
    `FAIL-case` lines it printed alongside (critic CE4).
14. **The marker rule is line-granular.** A line that says "removed" for one
    reason also excuses a different dead token on the same line; every tolerated
    token is printed as `LABELED`, which is the audit path (critic CE3).
15. **A citation of a generated file is order-dependent.** `corpus/stamps.tsv`
    is cited in this corpus and does not exist before the first `stamp` — the
    citation is `UNRESOLVED` until then (reviewer addendum, observed live).
16. **`stamp` replaces the row set; it does not merge.** Any invocation that
    would drop a path already pinned is refused (exit 2) unless `--prune` is
    passed — round 12 lost 18 rows to an in-flight 10-path `stamp` before the
    guard existed, and `verify` cannot report the loss (it iterates the file's
    rows, so a shrunken file is silently smaller coverage). The round-12
    mutation lane then showed the first rule (new rows < existing rows) was a
    *length* rule: an equal-count **path swap** and a missing-final-newline
    off-by-one both slipped through, so the guard is now per-path membership and
    counts non-blank lines. A **blank line** inside the file is a setup error
    (`malformed stamps row (blank line)`), because a blank row reduced coverage
    while a `grep -c` count still saw a row. Row count is pinned by claim row
    `R12-03` (non-blank-line count, not `^#`-inverted); four selftest cases cover
    the guard (`stamp-shrink-refused`, `stamp-prune-allowed`,
    `stamp-swap-refused`, `stamps-blank-row`).

17. **An id audit is a liveness check, not a semantic one.** A document can cite
    the correct id beside the wrong sentence; the audit says "this id exists",
    not "this id supports that claim". The reviewer lane is the control.
18. **A cell pointer can be irrelevant to the score it sits next to.** The
    critic's executed counterexample: a `calibration | 9 | R11-10` cell is
    `CLEAN` while `R11-10`'s command only counts rows in `state-shape.tsv`. The
    rule raises a cell from *token existence* to *a currently passing
    measurement or a hash-pinned revision*; it does not establish relevance.
    `row_pointed` vs `stamp_pointed` is printed so the reader sees which kind of
    support each score has.
19. **The ledger cannot pin its own `verify` summary.** A row running `verify`
    from inside `verify` recurses; `verify` refuses a nested self-audit
    (selftest `nested-audit-refused`). `cells` may be pinned because the cell
    audit skips the rows that re-invoke the gate (`self_skipped`).
20. **`STALE-POINTER` is a question, not a verdict.** A moved pinned revision
    means either the edit was intended (re-stamp, a reviewed commit) or the cell
    points at the wrong artifact (re-point it).
21. **The six-axis completeness rule is a shape rule.** A section can carry all
    six axes and still score nonsense; and a *sub-axis* name (a split, e.g.
    `freshness (host)`) is not recognised — splitting an axis therefore requires
    keeping the parent row, which is stated here so a future split is not
    discovered as a surprise setup error.

22. **Stamp rows are read under the same containment rule they are written
    under.** `stamp` has refused absolute paths and `..` since round 11; the
    *reader* did not, and the round-13 sentinel demonstrated the asymmetry end to
    end — a hand-edited row naming `../outside.txt` made `verify` hash a file
    outside `--root` (a hash oracle) and let a scorecard cell point at it. Both
    sides now refuse (exit 2, selftest `stamps-dotdot-row` /
    `stamps-absolute-row`). The bound that remains: this is a **text** check on
    the row, not a canonical-path check, so a row naming a path that *reaches*
    outside through a symlinked directory is refused on the write side (which
    resolves the canonical path) but not re-checked on the read side.
23. **`verify --docs <one doc with no ids>` is CLEAN with `cited=0`.** An
    explicitly narrowed doc set can legitimately contain no claim ids; the
    count in the summary is the signal, and the non-vacuity guards live in
    `cells` (zero cells, zero row-pointed cells, empty id universe) rather than
    in the id audit.

## Falsifiers (each must break something, or the claim behind it is wrong)

```
bash -c 'cp corpus/claim-ledger.sh /tmp/g.sh; sed -i "s/CLEAN/STILL_CLEAN/" /tmp/g.sh'   # selftest must notice? (no — it asserts its own strings; check)
bash -c 'printf "x\n" >> corpus/claim-ledger.tsv; bash corpus/claim-ledger.sh verify'    # malformed row → POLICY exit 2
bash -c 'cp corpus/stamps.tsv /tmp/s.tsv; printf "\n" >> corpus/claim-ledger.sh'        # STALE + exit 1 on the shipped stamp
bash -c 'bash corpus/claim-ledger.sh stamp --out corpus/stamps.tsv corpus/stamps.tsv'    # refused: output file itself
bash -c 'bash corpus/claim-ledger.sh citations --root /tmp'                              # die: doc not found (setup error, exit 2)
bash -c 'bash corpus/claim-ledger.sh verify --stamps /dev/null'                          # EMPTY stamp set → is that CLEAN? (size bound)
bash -c 'bash corpus/claim-ledger.sh verify --claims <(printf "c1\tbash x\tY\t0\t5\n")'  # process substitution as a claims file
# --- round 13 -----------------------------------------------------------------
printf 'doc cites R13-99\n' >>/tmp/f.md; bash corpus/claim-ledger.sh verify --docs /tmp/f.md  # fabricated id → MISSING-ID, exit 1 (before: CLEAN); add the word 'illustrative' to the line and it becomes LABELED-ID, counted as labeled_ids
bash -c 'cp SCORECARD.md /tmp/sc.md; printf "| calibration | 9 | nothing |\n" >>/tmp/sc.md; bash corpus/claim-ledger.sh cells --scorecard /tmp/sc.md --docs /tmp/sc.md'  # UNCITED (section may also fail the six-axis rule)
bash -c 'cp corpus/stamps.tsv /tmp/s.tsv; sed -i "s/^corpus\/claim-ledger.sh\t[0-9a-f]*/corpus\/claim-ledger.sh\tdeadbeef/" /tmp/s.tsv; printf "| depth | 7 | \`corpus/claim-ledger.sh\` |\n" >>/tmp/sc2.md'  # STALE-POINTER once the audit re-compares it
CLAIM_LEDGER_DEPTH=1 bash corpus/claim-ledger.sh verify   # refusing a nested self-audit, exit 2
```
