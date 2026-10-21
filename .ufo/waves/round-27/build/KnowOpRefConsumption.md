# KnowOpRefConsumption — C1 inventory: `corpus/knowledge/op-ref-consumption.md`

Round-27 C1 scout (calibration/freshness). BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Target state: `M corpus/knowledge/op-ref-consumption.md` (+13/−4 vs BASE). The worktree
carries two round-27 C1 edits: line 276 migrated 29→36 (present at my first read) and, at
12:23:38 while this report was being written, line 296 migrated 21→36 with the history
clause on line 297; the round-27 erratum is appended after BASE line 387 (BASE 386 lines,
worktree 395). Lines 1-275, 278-295 and 298-387 are byte-identical at BASE (276 and 296-297
changed). I cite BASE for the before-state and the worktree for the after-state, and mark
which is which.
The `KN-OPREF-*` rows at `corpus/self-counts.tsv:70-71,79` are worktree additions (absent
at BASE). The ledger pins cited — R12-02 `36 cases`, R21-01 `checks=6`, R12-01 shape-only
— are byte-identical at BASE and in the worktree.

No ledger row was executed; no gate, selftest, probe, linter or formatter was run; no
handler, `op.env`, vault, account or host-private path was read.

## Population and result

Rule: QUALITY QM21 (`corpus/QUALITY.md:118`), R25-C6 (`corpus/lessons/round-25.md:49-55`),
QM26 (`corpus/QUALITY.md:133`). A number is current when it states an artifact's present
size and no newer value sits in the same clause; an explicit history clause beside a
newer value is out. Sources are only `rows:<repo file>`, non-host `ledger:<ID>`, or
`expect:<ID>` (a host/op-executing row's committed pin, never executed).

**Result (BASE): 16 current-tense numbers about this lane's own artifacts. 14 are OK;
2 are STALE — line 276 `29` and line 296 `21`, both against the 36 pin. At my first read
(line 276 already migrated) the count was 15 OK / 1 STALE; in the current worktree both
are corrected and bound, so 16 OK.** Backed by an exact ledger pin: 3 (`:276`, `:319`,
`:374`; `:276` and `:374` are bound, `:319` is a proposed row below). Statically bound but
not pinned by the ledger regex: 12 (`:62`, `:63`×2, `:275`×6, `:282`, `:283`, `:291`).

The line-296 number is the sixth against the round-27 lesson's five
(`corpus/lessons/round-27.md:49-52`), which already includes line 276's 29→36. The
concurrent L1 edit fixed line 296 before this report landed; the finding is recorded as
BASE evidence and the fix is verified below.

## Inventory

| # | line | exact text | defining live source | pinned / live value | status |
|---|---|---|---|---|---|
| 1 | 62 | `` `op run` injects 12 keys `` | `expect:R12-01` (`corpus/claim-ledger.tsv:26`) | 12, static: `OPRUN_CONTRACT` 12 entries, `corpus/op-ref-probe.sh:77-88`; the row regex pins shape only | OK (static) |
| 2 | 63 | `` `refs` lists 7 `` | `expect:R12-01` | 7, static: `REFS_CONTRACT` 7 entries, `op-ref-probe.sh:93`; shape-only pin | OK (static) |
| 3 | 63 | `` `divergent=5` `` | `expect:R12-01` | 5, static: `DIVERGENT_CONTRACT` 5 entries, `op-ref-probe.sh:92`; shape-only pin | OK (static) |
| 4 | 275 | `checks=44` | `expect:R12-01` | 44, static: 15 `C_N` sites (`op-ref-probe.sh:365,374,379,385,394,399,403,407,415,417,424,438,444,448,453`); loops 12+9+6+6, eleven single = 44; shape-only pin | OK (static) |
| 5 | 275 | `oprun=12` | `expect:R12-01` | 12 (as row 1) | OK (static) |
| 6 | 275 | `refs=7` | `expect:R12-01` | 7 (as row 2) | OK (static) |
| 7 | 275 | `divergent=5` | `expect:R12-01` | 5 (as row 3) | OK (static) |
| 8 | 275 | `edge=10` | `expect:R12-01` | 10, static: 9 `EDGE_CONTRACT` classes (`:99-108`) + the `edge` KAGI12_P8 row written by `collect` (`:347-348`) | OK (static) |
| 9 | 275 | `sig=6` | `expect:R12-01` | 6, static: `SIG_CONTRACT` 6 entries (`:119-125`) | OK (static) |
| 10 | 276 | `OP_REF_SELFTEST: PASS (36 cases)` | `expect:R12-02` (`corpus/claim-ledger.tsv:27`) | 36 (`^OP_REF_SELFTEST: PASS \(36 cases\)$`); BASE said 29 and was STALE | OK (corrected before first read; bound by `corpus/self-counts.tsv:70`) |
| 11 | 282 | `` `oprun.env` (the 12-key divergence fixture `` | `expect:R12-01` | 12 (as row 1) | OK (static) |
| 12 | 283 | `` `edge.env` (10 classes `` | `expect:R12-01` | 10 edge-tagged rows (9 classes + the P8 precedence row); number matches `edge=10`, but the noun "classes" is 9 classes + 1 precedence row (`op-ref-probe.sh:99-108`, `:335-348`) | OK (static, noun caveat) |
| 13 | 291 | `CLEAN (checks=44 …)` | `expect:R12-01` | 44 (as row 4) | OK (static) |
| 14 | 296 | `` `--selftest` proves the comparator on 36 `` | `expect:R12-02` (+ `corpus/self-counts.tsv:79`) | 36 (`^OP_REF_SELFTEST: PASS \(36 cases\)$`); BASE text said 21 and was STALE | OK (corrected 12:23:38; bound) |
| 15 | 319 | `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)` | `expect:R21-01` (`corpus/claim-ledger.tsv:51`) | 6 (`^OP_DOTENV_BYTES: CLEAN \(checks=6 failed=0\)$`) | OK |
| 16 | 374 | `the selftest now proves 36 cases` | `expect:R12-02` | 36 (bound by `corpus/self-counts.tsv:71`) | OK |

"OK (static)" means: the number states the present size of a committed lane artifact and
agrees with the committed generator code/arrays read here, but the row's committed regex
does **not** capture the digit, so a one-digit knowledge mutation is invisible to the
binder. Concretely, `expect:R12-01`'s pin is the fragment
`^OP_REF_PROBE: CLEAN \(checks=[1-9][0-9]* oprun=[1-9][0-9]* …` — regex syntax, not a
number — so any digit extract applied to it fails SETUP. Those 12 are therefore outside
the binder population (the lesson's named exclusion at `corpus/lessons/round-27.md:47`,
using `checks=44` as its example), recorded here rather than silently promoted to a pin.

Population-boundary call: §2's header dates the inspection (`2026-09-28`). If L1 reads the
whole section as a dated measurement, rows 1-3 fall out of the population instead of
binding; they are fresh under either reading. Row 16 sits in the dated §11, but the
existing `KN-OPREF-CORRECTION-SELFTEST` row already treats that correction note as
in-population, so I kept it.

### Regex locators (each exactly one capture group; validated to match exactly one line)

```
row  line  locator
1    62    injects ([0-9]+) keys,
2    63    ^`refs` lists ([0-9]+),
3    63    ^`refs` lists [0-9]+, `divergent=([0-9]+)`
4    275   ^bash corpus/op-ref-probe\.sh +# OP_REF_PROBE: CLEAN \(checks=([0-9]+) oprun=
5    275   oprun=([0-9]+) refs=
6    275   refs=([0-9]+) divergent=
7    275   divergent=([0-9]+) edge=
8    275   edge=([0-9]+) sig=
9    275   edge=[0-9]+ sig=([0-9]+)\)
10   276   ^bash corpus/op-ref-probe\.sh --selftest +# OP_REF_SELFTEST: PASS \(([0-9]+) cases\)
11   282   ^`oprun\.env` \(the ([0-9]+)-key divergence fixture:
12   283   `edge\.env` \(([0-9]+) classes:
13   291   ^- `bash corpus/op-ref-probe\.sh` → `CLEAN \(checks=([0-9]+) …\)`, exit 0 \(live\)\.
14   296   ^\s+corresponding `FAIL` line and exit 1; `--selftest` proves the comparator on ([0-9]+)$
15   319   ^`OP_DOTENV_BYTES: CLEAN \(checks=([0-9]+) failed=0\)`
16   374   ^superseded: the selftest now proves ([0-9]+) cases
```

Validation performed (Python `re.search` over the file, read-only): every pattern above
returned exactly one hit, at the line shown. The three worktree rows for this doc
(`corpus/self-counts.tsv:70-71,79`) hit `:276`, `:374` and `:296` respectively; none is
ambiguous. At BASE none matched `:296` (the before-state counterexample below).

## BASE→worktree finding (fixed and bound) — `corpus/knowledge/op-ref-consumption.md:296`

Text at BASE (`:295-299`):

```
- Change any contract value (e.g. add `export ` to a fixture key) → the
  corresponding `FAIL` line and exit 1; `--selftest` proves the comparator on 21
  cases, including fifteen seeded mutations (value, masking, edge, quoting,
  precedence, union, inherited trim, signatures, refs classification, the
  malformed-blindness pair).
```

- Live pin: `corpus/claim-ledger.tsv:27` R12-02 requires
  `^OP_REF_SELFTEST: PASS \(36 cases\)$`. Static corroboration of 36 without executing
  `op`: 27 literal `tcase` calls outside `policy_case` (`op-ref-probe.sh:603-677`,
  `:723-743`) + 4 `policy_case` invocations (`:708-711`, body `tcase` at `:695`) + 5
  unconditional `S_N` log checks (`:679`, `:697`×4) = 36.
- Provenance of 21: `corpus/lessons/round-12.md:116` records the selftest moving
  "15→21→29 cases" inside round 12; `:21` of the same lesson records the final 29.
  So 21 is an intermediate **selftest total**, superseded first by 29 and now by 36.
- Why it was current at BASE despite the round-22 Erratum: QM21 makes a remote correction
  note insufficient — only an explicit history clause beside a newer value exempts a
  number. QM26 names exactly this shape as the weak signal: "a correction note elsewhere
  instead of a history clause beside the number". §10 is a live falsification section, not
  the Erratum section; "proves" was present tense.
- Concrete BASE counterexample to "a one-digit knowledge mutation turns the binder STALE":
  change `:296` `21`→`99`. At BASE no `KN-OPREF-*` locator matched that line (validated);
  the other 15 numbers were unchanged, so the binder's claimed/pinned set was unchanged
  and its verdict could not move. The mutation was invisible. The new row at
  `corpus/self-counts.tsv:79` closes this: the same mutation now captures 99 against the
  36 pin (simulated statically), which is a STALE verdict.
- Calibration trap: today's mutated-case count is **also** 21 by coincidence
  (15 `canned-*` mutations, `op-ref-probe.sh:606-662`, + 6 non-faithful `bytes-*` cases,
  `:727-743`). Do not "validate" the stale 21 against that coincidence; the round-12
  series fixes its referent as the selftest total.

### Fix applied in the worktree (12:23:38) — verified, not assumed

Current text (`:295-297`):

```
- Change any contract value (e.g. add `export ` to a fixture key) → the
  corresponding `FAIL` line and exit 1; `--selftest` proves the comparator on 36
  cases (21 when §10 was written), including fifteen seeded mutations (value, masking, edge, quoting,
```

The history clause sits beside the new value (QM21). Read as "the §10 text carried 21 when
written", the clause is true (`git blame` puts the paragraph in `4b8c018`, 2026-09-28).
Read as "the live selftest was 21 then", it would be wrong — it was 29
(`corpus/lessons/round-12.md:116`); the wording could be tightened, but it does not
restate a stale value as current, so it satisfies QM21. Cosmetic: line 297 is ~110
columns, unlike the entry's wrap.

### Applied binding (verified)

The worktree now carries `corpus/self-counts.tsv:79`:

```
KN-OPREF-FALSIFY-SELFTEST	corpus/knowledge/op-ref-consumption.md	`--selftest` proves the comparator on ([0-9]+)$	expect:R12-02	\(([0-9]+) cases	§10; R12-02 pin (said 21 at BASE)
```

Verified statically (Python `re.search`; the binder itself was not run): the locator
matches line 296 only, has exactly one group, and captures 36; `\(([0-9]+) cases` on
R12-02's committed pin captures 36; a simulated 36→99 yields 99, so the binder would flag
STALE. The locator has no leading anchor; it is unique today, and adding
`^\s+corresponding `FAIL` line and exit 1; ` would turn a future duplicate phrase into an
explicit ambiguous/SETUP failure instead of a second accidental match. Robustness
suggestion only, not a defect.

### Recommended additional row (cheap, closes the only pin-bound gap I found)

`:319` is current and correct but unbound; `checks=6` is already the exact R21-01 pin:

```
KN-OPREF-BYTES-CHECKS	corpus/knowledge/op-ref-consumption.md	^`OP_DOTENV_BYTES: CLEAN \(checks=([0-9]+) failed=0\)`	expect:R21-01	checks=([0-9]+)	§11 byte-arm output; R21-01 pin (op-executing row): read, never run
```

Optional hardening for rows 1-9/11-13 (not required by this round's rule, and with a
bookkeeping cost): R12-01's regex is shape-only, so the six `OP_REF_PROBE` digits cannot
be bound through it. An exact-pin substrate row, e.g.
`^OP_REF_PROBE: CLEAN \(checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6\)$`, would let
`expect:<new id>` bind all six and both fixture counts. Adding a ledger row moves
R21-04 (65→66), so it cascades into the claim/stamp and SKILL/README bindings; unless L1
wants that cascade this round, the lesson's named exclusion stands and the static values
above are the best available evidence.

## Excluded numbers (and why)

Vendor facts (`op` behaviour, not lane artifacts): `2.35.0` (`:5-6,100,184,219,267`),
`2.41.0`/`2.40.0` (`:315-316,359`), exit codes 1/2 and the "1-vs-2 split"
(`:171-176,179-180,363`), `0600` file mode and "three ways" (`:184-187`), "zero keys
injected" (`:85-87`), error positions "line 2 column 7", "line 1 column 5", "line 1
column 1" (`:85-88`), "exit 0" (`:143`).

Host-artifact / host measurements of absent substrate: handler line citations `ENV_FILE`
L7, `cmd_refs` L228-236/L234, `cmd_run` L237-249/L248, `need_op` L58 (`:3-4,29-30,305`);
`~2 s` (`:57,173`); `timeout 6` (`:240`); the observed `op.env` "10 keys, 8 of which are
`op://` refs and 2 raw" (`:125`) — the sibling entry repeats it dated
(`corpus/knowledge/janitor-env-contract.md:73-74`), and neither this report nor the
binder may read the host file; "on this host" hex (`:345-346`).

Dated measurements / round history: `2026-09-28` (`:3`), `2026-10-19` (`:315`), `round 12`
(`:1,13`), `round 10` (`:199`), `round-20`/`round 21`/`Round-21` (`:310,316,359`),
`round 22` (`:377`), `round 27` (`:389`), "three measured blind spots" (`:245`, spelled,
round-12 mutation-lane history), `R12ScoutHelp` "enumerated 14 such items" (`:269`,
past-tense attributed finding; no `.ufo/waves/round-12/` report exists in this checkout
to re-count), `m10` (`:261`), `F1/F2` (`:13-14`).

Explicit history clauses (out by QM21): "29 when §9 was written" (`:276`), "21 when §10
was written" (`:297`), "§9 is left as written"/"re-pinned this round" (`:375`, a round-21
temporal claim), "§10 '21 cases' … intermediate historical count" and the quoted "36"
(`:379-380`, Erratum), "the historical
29" and "current 36" (`:392`, Erratum; the Erratum section is excluded by QM26 and the 36
agrees with the pin anyway), "added seven" (`:374`).

Positional indexes / IDs (QM26): §8 bounds 1-13 (`:207-270`), `§Bounds.10` (`:119`),
`§8.4` (`:202`), `§2b`/`§3`/`§4`/`§11` section refs, `op-ref-probe.sh:525-526` (`:364`,
verified correct — `command -v` at 525, `die` at 526 — but a positional code citation, not
a count), row IDs `R11-01, R12-01, R12-02, R21-01` (`:23`, `:366`, `:371`), case names
`policy-ref-token`, `janitor-refs-missing`, `DOTENV_OBS-*`, key names
`KAGI12_*`/`KAGI16_VALUE`.

Fixture-input multiplicities / data: `K=a ×3` and "listed 3×" (`:51,53` — input shape and
a measured awk property, not an artifact's present size; no numeric pin), hex payloads
(`:324-343,345`), `P8`/`P9` examples (`:150-151`), `×`/`|` syntax.

Spelled-out counts (no digit capture group is possible, so they are outside the TSV
contract; verified where a static source exists): "five symmetric-difference keys"
(`:60`; = 5, `op-ref-probe.sh:92`), "exactly two of these rows" (`:116`; = printenv and
mask-equality, `evaluate` `:363-418`), "three ways" (vendor), "fifteen seeded mutations"
(`:297`; = exactly 15 `canned-*` mutation cases, `op-ref-probe.sh:606-662` — current and
accurate, but a future added mutation is unbound), "six `DOTENV_BYTES_CASE … lines`"
(`:318`; = 6, `DOTENV_BYTE_CONTRACT` `:135-142`, digit form bound at `:319`), "seven
`--selftest` byte cases" (`:360`) and "added seven" (`:374`; = 7 `bytes-*` cases,
`op-ref-probe.sh:723-743` — current, unbound). These are named debt, not staleness.

## What I did NOT check (unrun checks are not passes)

- Did not execute `corpus/op-ref-probe.sh` (any mode), `corpus/self-counts.py`, or
  `corpus/claim-ledger.sh`. The R12-01 live `CLEAN (checks=44 …)` verdict and the R21-01
  byte run are therefore **not observed**; 44 and the other summary digits are a static
  derivation from the committed code, not a run.
- Did not run the binder on the new `KN-OPREF-FALSIFY-SELFTEST` row; I applied its
  locator and extract with Python against the entry and the committed pin (one hit,
  capture 36) and simulated the 36→99 mutation. The gate's own verdict is unrun.
- Did not execute `op` at all; no reference resolved, no handler invoked.
- Did not re-read the handler or `~/.config/the-janitor/op.env`; the handler line
  citations and the 10/8/2 host counts remain unverified here by contract.
- Did not re-count the R12ScoutHelp 14-item list (report absent from this checkout).
- Did not audit any other knowledge entry or the global `self-counts.tsv` population;
  this report is limited to `corpus/knowledge/op-ref-consumption.md`.
- Did not verify the ledger's own `verify --allow-host-rows` re-measurement of R12-01 or
  R21-01.

## Tooling

No installs or upgrades were needed or performed (no pacman, uv, npm, cargo, or binary
download).

Report: .ufo/waves/round-27/build/KnowOpRefConsumption.md
