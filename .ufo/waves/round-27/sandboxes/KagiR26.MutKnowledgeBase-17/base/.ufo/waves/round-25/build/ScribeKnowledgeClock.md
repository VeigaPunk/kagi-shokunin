# ScribeKnowledgeClock — round-25 knowledge draft (C1 self-count, C3 release clocks)

Base: `4587c61a348e4528717404a68912c373f3ef4d03`. Lane tree untouched. Draft tested only in sandbox `/fast/scratch/kagi-r25/ScribeKnowledgeClock-2/lane`. Tools installed: none.

## Insertion points (lane paths; apply bottom-up within each file)

1. `corpus/knowledge/claim-ledger.md` — after line 455 (end of Bounds item 30; before blank 456 and `## Falsifiers`). Paste Block C.
2. `corpus/knowledge/claim-ledger.md` — after line 305 (`stamp` command inside the Reproduction fence; before the closing fence at 306). Paste Block B.
3. `corpus/knowledge/claim-ledger.md` — after line 250 (end of Class 6 summary, `verdict is the last line…`; before blank 251 and `## Round-14 before → after`). Paste Block A.
4. `corpus/SOURCES.md` — after line 38 (row S032; before blank 39 and `## Paths`). Paste Block D.

### Block A (claim-ledger.md, new section)

```
## Class 7 — release clocks and self-count binding (`corpus/release-clocks.tsv`, `corpus/self-counts.tsv`)

Two offline bindings. A doc's current-tense number must equal the live value it describes, and every `on-release` recheck must name the release clock it watches. Neither is a verdict on the source; each is a trigger a reader can re-run.

**Self-count binding.** `corpus/self-counts.tsv` holds one row per current-tense number in a committed doc. Each row locates exactly one line with a one-group regex (zero matches is `UNLOCATED`, several is `AMBIGUOUS`) and names its live source. `rows:<path>` counts the non-blank, non-`#` lines of a committed table. `ledger:<ID>` runs that claim-ledger row's own command (argv, no shell) and reads the number from the last non-empty line with the row's declared regex. The ledger stays the only definition of a live quantity: a doc quotes the value and never restates it independently. A row is `OK` when the doc value equals the live value and `STALE` otherwise. A number explicitly dated to a past round (lessons, scorecard history, round sections of this ledger) is outside the population by rule and is not bound. A new current-tense count added without a row is not caught by the gate; the change that adds it adds the row.

**Release clocks.** `corpus/release-clocks.tsv` binds each row of the `on-release` population (membership set by the registry `recheck` cell) by row id to exactly one clock; no registry cell is rewritten:

- `feed`: an official release feed opened in the same round as its own registry row, plus the version the source row's anchor names. The clock fires when the feed's newest release is not that version.
- `rendered-quote`: unversioned live docs. The row's quote must still locate in a fresh fetch under `rendered-text-v1` (`corpus/rendered-text-v1.py`). The clock fires when it does not.

**Fired verdict.** A fired clock is a re-verification obligation, not a failure of the source. The summary reports it as `fired=K`. The fired row is re-opened and its outcome recorded; its anchor, version or quote is not silently re-pinned. A changed reading becomes a new registry row that says `supersedes Sxxx`, as S019, S022 and S025 do, and the superseded row keeps the verdict it was given.

**Observation receipt.** `release-clock.py --observe` appends one dated line per bound row: date, row id, clock kind, the observed value (the feed version, or the `rendered-text-v1` locate result with its fetch digest) and the outcome `unchanged` or `fired`. Receipts are append-only. A later observation never replaces an earlier one, so a clock's history is the sequence of its receipts.

Summary lines: `SELF_COUNTS: CLEAN (claims=N stale=0)`, `SELF_COUNTS: STALE (claims=N stale=K unlocated=J)` (exit 1), and `RELEASE_CLOCK: CLEAN (on_release=N bound=N unbound=0 observed=N fired=K)`.
```

### Block B (claim-ledger.md, Reproduction fence; two lines)

```
python3 corpus/self-counts.py           # → SELF_COUNTS: CLEAN (claims=N stale=0), exit 0
python3 corpus/release-clock.py         # → RELEASE_CLOCK: CLEAN (on_release=N bound=N unbound=0 observed=N fired=K)
```

### Block C (claim-ledger.md, Bounds items 31–33)

```
31. **Self-count binding sees only the rows it is given.** A current-tense number in
    a sentence that no row names is invisible; the gate measures the table, not the
    prose. Round-dated history is excluded by rule, so a current-tense statement
    written as history is a reviewer's miss, not a gate miss.
32. **A clock is a trigger, not a verdict.** `unchanged` says the feed version or the
    quote did not move at that observation; it does not say the source is still
    right. A `rendered-quote` clock cannot see a change the declared normalizer
    discards.
33. **The offline check does not fetch.** A `CLEAN` run reports the receipts already
    on disk; only `--observe` reaches the source. A receipt is a dated observation,
    so a clock last observed earlier than the current round is not evidence of
    today's state.
```

### Block D (SOURCES.md, paragraph after the registry table; leading blank line included)

```

Release clocks (round 25). A row in the `on-release` population is bound by row id to one clock in `corpus/release-clocks.tsv`. The `recheck` cell sets population membership only; no cell is rewritten, and existing rows keep their text. A `feed` clock needs its own docs row opened in the round, naming the release identity its anchor relies on. That row keeps its own fixed recheck (for example `90d`), so it stays outside the on-release population. A `rendered-quote` clock uses the row's quote under `rendered-text-v1`. Clock kinds, the fired verdict and observation receipts are defined in `corpus/knowledge/claim-ledger.md` (Class 7). A fired clock does not change a row's status; a changed reading is recorded as a new row that supersedes the old one.
```

## Sandbox measurements (BASE + Blocks A–D, `env -i PATH=/usr/bin:/bin`)

- `claim-ledger.sh docs` → `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`, exit 0.
- `sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=32 A=30 B=0 C=2 queued=1 mined=29 rejected=2 entries_sourced=4 legacy=21 captures=32 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0; identical to BASE.
- `claim-ledger.sh citations --docs "corpus/knowledge/claim-ledger.md corpus/SOURCES.md"` → exit 1. The six tokens the draft adds are `UNRESOLVED` (claim-ledger.md:251, :255, :257, :322, :323; SOURCES.md:41): `corpus/release-clocks.tsv`, `corpus/self-counts.tsv`, `corpus/self-counts.py`, `corpus/release-clock.py`. These files do not exist at BASE. The remaining `UNRESOLVED` lines are pre-existing lone-clone `.ufo`/sibling tokens (C2 scope). BASE citations run for comparison: UNRUN.
- Whole-tree default `citations` in this lone clone: `CITATION_GATE: BROKEN (cites=1378 docs=67 unresolved=93 ephemeral=0 labeled=25)`, exit 1. Pre-existing layout effect, not caused by the draft.
- Wording delta: the tested sandbox copy says "as S019 through S032 do"; the block above says "as S019, S022 and S025 do" (those are the rows that carry `supersedes` for registry rows S007, S012 and S014 — S019 supersedes S007, S022 supersedes S012, S025 supersedes S014). No backtick token changed.

## Decisions L1 must confirm before paste (implementation-dependent; the draft asserts them)

1. File names: the draft uses the plan's names (`corpus/release-clock.py`, `corpus/release-clocks.tsv`, `corpus/self-counts.py`, `corpus/self-counts.tsv`). If the build chooses other names, edit Blocks A–B and D. Paste after those files land, or `citations` goes red by six tokens.
2. Receipt content and location: Block A lists the receipt fields (date, row id, clock, observed value, digest, outcome). The plan does not name a receipt path or field set. [INFERENCE]
3. Exit codes for `RELEASE_CLOCK` with `fired>0`: the plan's CLEAN line carries `fired=K`, which implies exit 0; not confirmed.
4. `observed=N` counting rule: Block C item 33 says receipts already on disk. [INFERENCE from "checks bindings offline" plus "--observe records"]

## Findings for the C1 and C3 critics

- `claim-ledger.md:301–304` (Reproduction) quote current-looking numbers (`claims=17`, `cites=700`, `cells=60`, `SELFTEST … 72 cases`), while the Erratum at `claim-ledger.md:474–480` says those summaries are historical round-13 outputs. The C1 population rule must exempt these by that erratum, or the binding will report them stale or unlocated. Counterexample to hand the C1 critic.
- Knowledge-entry `recheck:` headers carry prose after the key (e.g. `recheck: on-release — on a SOPS release…`, `sops-age-key-rotation.md:5`), while registry cells are the bare token `on-release`. C3 binds by row id in `corpus/release-clocks.tsv`; the registry `recheck` cell sets population membership only. Do not bind on the entry header, or its prose will be read as a different clock.
- The draft quotes no current-tense counts of its own. Placeholders (`N`, `K`, `J`) are summary shapes. C1 must not bind them.
