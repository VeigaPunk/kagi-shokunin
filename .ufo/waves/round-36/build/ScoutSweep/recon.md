# ScoutSweep — round-36 C1 reading recon (kagi lane)

Seat: `ScoutSweep`. Scope: reconnaissance of the **C1 calibration reading** with exact
line references. Read-only on the lane; every experiment ran on a copy under
`/fast/scratch/hyaku/kagi-r36/ScoutSweep/`.

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`
Frozen BASE: `cb8cb659e84240a8db12e4f7b4a0def5068baf7e` (instrument + executed controls)
Frozen plan: `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d`

---

## 0. Headline

| fact | value | how measured |
|---|---|---|
| C1 counter at frozen BASE | **4** | `bash plans/round-36-c1.sh` on `git archive cb8cb65` → `4`, rc 0 |
| C1 counter on the L1's landing tree | **0** | `bash plans/round-36-c1.sh` on the live working tree → `0`, rc 0 |
| C2 counter at frozen BASE | **15** | committed control `.ufo/waves/round-36/controls/nowork-c2.out` = `15` |
| C2 counter on the landing tree | **0** | `bash plans/round-36-c2.sh` → `0`, rc 0 |
| SD5 at BASE | **3** | sweep: `R25-02`, `R29-01`, `R29-02` absent from `SCORECARD.md:1374` |
| SD5 at landing | **0** | sweep on live tree: `SD5=0` |
| SD6 at BASE and landing | **3** (not 5) | sweep + `claim-ledger.sh citations` → `unresolved=3` |
| `stale` at BASE | **1** | `STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70` |
| `stale` on the **F1–F4-only** tree | **3** | see §5 — the candidate as specified does **not** reach 0 |

**The single most important finding: the candidate as specified in the seat brief
(F1–F4, "Nothing else changes") does not reach C1 = 0.** Applied to the frozen BASE it
measures **C1 = 0** (F1+F2 only, §5.1) *only because* BASE's ledger has 79 claim rows and
the three doc cells say 79. But on any tree where the ledger has been given the round's
three new claim rows `R36-01..R36-03` — which the plan's Frontier step and the L1's
landing both require — the same F1–F4 bytes measure **C1 = 3**, because three *other*
self-count cells (`SC-SKILL-CLAIMS`, `PV-CLAIMS`, `RD-LEDGER-ROWS`) bind the claim-row
count and go stale the moment the count moves 79 → 82. See §5.2 and §5.3 for the
measured proof and the minimal extra edit set.

---

## 1. `corpus/self-description-sweep.sh` — the SD5 block

### 1.1 The block, quoted (`corpus/self-description-sweep.sh:376-396`)

```bash
# SD5 — lane-status red ids absent from the latest calibration row.
score=$ROOT_ABS/SCORECARD.md
[ -f "$score" ] || die "missing SCORECARD.md under root"
status_line=$(grep -nE '^lane-status:' "$score" | head -n 1 | cut -d: -f1)
[ -n "$status_line" ] || die "no lane-status line in SCORECARD.md"
status_text=$(sed -n "${status_line}p" "$score")
reds=$(printf '%s\n' "$status_text" | grep -oE '\([^()]*\)' | tr -d '()' | grep -oE 'R[0-9]+-[0-9]+' | sort -u)
[ -n "$reds" ] || reds=$(printf '%s\n' "$status_text" | grep -oE 'R[0-9]+-[0-9]+' | sort -u)
round_line=$(grep -nE '^## Round' "$score" | tail -n 1 | cut -d: -f1)
[ -n "$round_line" ] || die "no '## Round' section in SCORECARD.md"
round_end=$(awk -v s="$round_line" 'NR > s && /^## / { print NR; exit }' "$score")
[ -n "$round_end" ] || round_end=$(( $(wc -l < "$score") + 1 ))
cal_line=$(awk -v s="$round_line" -v e="$round_end" 'NR > s && NR < e && /^\| *calibration *\|/ { print NR; exit }' "$score")
[ -n "$cal_line" ] || die "no calibration row in the latest ## Round section (SCORECARD.md:$round_line)"
cal_text=$(sed -n "${cal_line}p" "$score")
while IFS= read -r id; do
  [ -n "$id" ] || continue
  printf '%s\n' "$cal_text" | grep -qE "(^|[^0-9A-Za-z-])$id([^0-9A-Za-z-]|$)" && continue
  sd5=$((sd5 + 1))
  HITS+=("MISMATCH SD5 SCORECARD.md:$status_line red id '$id' is absent from the latest calibration row (SCORECARD.md:$cal_line)")
done <<< "$reds"
```

### 1.2 Exactly which section it reads

`grep -nE '^## Round' "$score" | tail -n 1` — **the last** `^## Round` heading in
`SCORECARD.md`, by **file order, not by round number**. Three consequences, all measured:

* **"Latest" = last heading, not highest number.** At BASE the last `## Round` heading is
  `SCORECARD.md:1368` = `## Round 35 — post-move (producer-result integrity; calibration
  admission withheld)`, whose calibration row is `SCORECARD.md:1374`. The sweep's own BASE
  output names it: `MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest
  calibration row (SCORECARD.md:1374)`.
* **The calibration row is found only inside that section.** `cal_line` searches
  `NR > s && NR < e`, where `e` is the next `^## ` heading. So a calibration row in an
  *earlier* round section is invisible to SD5 — this is exactly what the committed
  control `forge-sd5-early-c1.out` (`4`) plants and does not move.
* **Section order matters; the LAST section wins.** Measured: with the round-36 `pre-move`
  and `post-move` sections swapped so `post-move` precedes `pre-move`, the sweep reads the
  *pre-move* calibration row and reports SD5 = 3 again:
  `MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest calibration row (SCORECARD.md:1410)`.
  So the candidate's post-move calibration row must be the **last** `## Round` section in the file.

### 1.3 The red set, and how it is extracted from `lane-status:`

* `status_line` = the **first** line matching `^lane-status:` (`head -n 1`). On the lane
  tree that is `SCORECARD.md:14`; at BASE also `:14`.
* The red set is extracted in two tiers:
  1. **primary** — every parenthesised group in that line, parens stripped, then
     `grep -oE 'R[0-9]+-[0-9]+'` → `sort -u`;
  2. **fallback** — if that yields nothing, every `R<n>-<n>` token anywhere in the line.
* The lane line is
  `lane-status: open — as-of:2026-11-04 — dispatch unblocked; 3 operator-routed reds (R25-02,R29-01,R29-02) stay red`
  (BASE has `as-of:2026-11-03`). The parenthesised group yields the three ids
  `R25-02, R29-01, R29-02` — so the red set is exactly those three, and the *count* "3" in
  the prose is not what is read.
* Membership test per id: `grep -qE "(^|[^0-9A-Za-z-])$id([^0-9A-Za-z-]|$)"` against
  `cal_text` — i.e. the id must appear in the calibration row with non-alphanumeric,
  non-hyphen boundaries. `R25-02` matches inside `(R25-02, ...)`; `R29-02` does **not**
  match a bare `R29-01` (the `-` is excluded from the boundary class, and `1` vs `2`).
  Note the class excludes `-`, so `R29-0` would not match `R29-02`.

### 1.4 If the last `## Round` section has no calibration row

`die "no calibration row in the latest ## Round section (SCORECARD.md:$round_line)"` →
`die()` prints `SELF_DESCRIPTION: SETUP <reason>` and **exits 2** (`corpus/self-description-sweep.sh:57`).

Measured (fixture `exp-nocal`, calibration row deleted from the last section):

```
SELF_DESCRIPTION: SETUP no calibration row in the latest ## Round section (SCORECARD.md:1398)
sweep rc=2
--- C1 counter on that tree:
C1 SETUP: sweep verdict missing
```

`plans/round-36-c1.sh:13-20` matches only `SELF_DESCRIPTION: CLEAN n=0` or
`*SELF_DESCRIPTION: MISMATCH*`; a SETUP line falls to the `*)` arm →
`echo "C1 SETUP: sweep verdict missing" >&2; exit 2`. **The C1 counter fails closed
(exit 2, no integer) here** — this is the required behaviour, and it is verified.

### 1.5 SD6 — the plan says 5, the instrument reads 3

`plans/round-36.md:35` says "The sweep's SD6 class (5 citations inside non-author
verifier spot-check files) … is preserved unchanged at 5", and the kill rule at
`:43` is "SD6 differs from 5 at the landing revision … → C1 fails".

**Measured SD6 at the frozen BASE is 3, not 5**, and it is still 3 on the landing tree:

```
MISMATCH SD6 corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-32-verifier-spotcheck.md:54 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)
SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)
```

`bash corpus/claim-ledger.sh citations` on the same tree agrees:
`CITATION_GATE: BROKEN (cites=2299 docs=96 unresolved=3 ephemeral=0 labeled=26)`.
The sweep's SD6 counter (`corpus/self-description-sweep.sh:398-416`) increments **once
per `UNRESOLVED` line**, so it reads 3.

**Consequence for the plan, not for the counter.** The C1 counter reads *only* SD5 and
`stale` (`plans/round-36-c1.sh:13-24`), so SD6's numeric value does not enter C1 and the
"preserved unchanged" property **does hold** (3 at BASE, 3 at landing). But the kill rule
as literally written ("SD6 differs from 5") is **already violated at BASE** (3 ≠ 5), so
read literally it would fail C1 at the landing revision for a reason unrelated to the
candidate. Recommend the L1 record SD6 = 3 as the observed BASE value and treat the
class as "3, unchanged" (the five files named are the five non-owned verifier files, and
none was edited — verified: `git diff` shows no change to any
`corpus/lessons/*verifier-spotcheck.md` or `corpus/README.md`).

---

## 2. `corpus/self-counts.py` — the claim-row parser, extract/compare path, and the armed row

### 2.1 The claim-row parser (`corpus/self-counts.py:93-152`)

```python
def tsv_rows(path: Path):
    seen = set()
    for number, line in enumerate(read_text(path).splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) != 6 or any(not field.strip() for field in fields):
            fail("SETUP", f"{path.name}:{number}: expected six nonempty columns")
        ident = fields[0]
        if re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", ident) is None:
            fail("SETUP", f"{path.name}:{number}: invalid id")
        if ident in seen:
            fail("SETUP", f"{path.name}:{number}: duplicate id {ident}")
        seen.add(ident)
        yield fields
```

Six tab-separated non-empty columns; column 3 (`source`) is dispatched at
`:317-322`: `rows:<path>` (extract must be `-`), or `ledger:<ID>` / `expect:<ID>`.
The locator is compiled by `capture_regex` (`:110-118`) which **requires exactly one
capture group**; the extract likewise.

### 2.2 The armed row (`corpus/self-counts.tsv:87`)

```
SA-CAP-CENSUS-SELFTEST	SCORECARD.md	^\| source registry \+ census gate \|.*?`--selftest` ([0-9]+) cases\b	ledger:R21-03	^SOURCES_CENSUS_SELFTEST: PASS \(([0-9]+) cases\)$	capabilities table: present-tense selftest count (round 36 population extension)
```

* **doc** = `SCORECARD.md`; **locator** = the regex above; **source** = `ledger:R21-03`;
  **extract** = `^SOURCES_CENSUS_SELFTEST: PASS \(([0-9]+) cases\)$`.

### 2.3 How the armed row reads SCORECARD.md and ledger R21-03 — the extract/compare path

`check()` (`corpus/self-counts.py:306-374`), per claim:

1. **Locate in the doc** (`:325-330`):
   ```python
   matches = [(number, match) for number, line in enumerate(documents[claim.doc], 1)
              if (match := claim.locator.search(line)) is not None]
   ```
   `claim.locator.search(line)` — a **search**, not a fullmatch, per line. The doc is
   `read_text(doc_path).splitlines()`, so the locator's `^`/`$` are line anchors.
   * 0 matches → `UNLOCATED` printed, `counts["unlocated"] += 1`, claim skipped.
   * >1 matches → `AMBIGUOUS` printed, `counts["ambiguous"] += 1`, claim skipped.
   * exactly 1 → proceed. **Both skip paths leave `stale` untouched.**
2. **Claimed value** (`:338`): `claimed = integer(match.group(1), …)`; `integer()`
   (`:120-127`) fails SETUP unless the capture is all digits.
3. **Live value by source kind** (`:339-356`):
   * `rows:<path>` → count of non-blank non-comment data lines;
   * `expect:<ID>` → the **committed pin** in the ledger row's column 3, never executed;
   * `ledger:<ID>` → **the ledger row's own command is executed**:
     `ledger_command()` (`:255-285`) splits the command, refuses `[host]`/`[substrate]`
     rows, refuses a non-allowlisted first token (`ALLOWED_COMMANDS = {"bash","grep","python3"}`),
     refuses recursion into `claim-ledger.sh verify|cells`, refuses `--allow-host-rows`,
     and refuses release-clock observe mode; `last_output()` (`:287-304`) runs it with
     `cwd=root`, enforces the ledger's expected exit code, and returns **the last
     non-empty line** of combined stdout+stderr.
   For `SA-CAP-CENSUS-SELFTEST` that means: **run `bash corpus/sources-census.sh --selftest`
   (ledger row `R21-03`) and match `^SOURCES_CENSUS_SELFTEST: PASS \(([0-9]+) cases\)$`
   against its last non-empty line** → live = `70` (measured: `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`).
4. **Compare** (`:357-360`): `status = "OK" if claimed == value else "STALE"`;
   `counts["stale"] += claimed != value`. Per-claim lines are printed as
   `OK|STALE <ident> <doc>:<line> claimed=<n> live|pinned=<n>`.

**Measured at BASE:**
```
STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70
SELF_COUNTS: POLICY (claims=63 stale=1 unlocated=0 ambiguous=0 policy=2 setup=0)
```
The `POLICY` verdict and `policy=2` are **pre-existing and unrelated**: rows
`PV-FEEDTOKEN-SHAPES` / `PV-FEEDTOKEN-SELFTEST` bind `ledger:R29-02` / `ledger:R29-01`,
whose commands start with `python` (not `python3`), so `ledger_command()` refuses them →
`POLICY … command not allowlisted`. **This is why the summary line is `POLICY` and not
`CLEAN`, and why the C1 counter must read `stale=` out of a `POLICY` summary rather
than requiring `CLEAN`.**

### 2.4 The exact regex and the second-number question

Locator: `^\| source registry \+ census gate \|.*?`--selftest` ([0-9]+) cases\b`

The `.*?` is **lazy**, and `re.search` finds the **leftmost** match. The capture group is
bound to the first `` `--selftest` N cases `` occurrence **in the line** — so:

* a **second number later in the same cell is harmless** as long as it is not itself
  preceded by `` `--selftest` ``;
* but a **second `` `--selftest` `` occurrence earlier in the cell wins**, because the
  regex is leftmost-first.

Measured directly against the locator:

| cell text | capture |
|---|---|
| ``…`--selftest` 70 cases (`R21-03`; the round-21 record said 59, measured stale by round 36 C1)…`` | **70** ✅ (the L1's actual edit) |
| ``…`--selftest` 59 cases at round 21; now `--selftest` 70 cases…`` | **59** ❌ (leftmost wins) |
| ``…`--selftest` 70 cases (59 cases at round 21)…`` | **70** ✅ (second bare number ignored) |
| ``…`--selftest` 71 cases…`` | 71 (the forbidden forgery) |

So the L1's phrasing — 70 immediately after the first `` `--selftest` ``, with the
historical 59 later in the cell as bare prose — is the correct shape, and it is what
`SCORECARD.md:701` now reads.

**Two ways to make the armed row silently vanish from the `stale` count** (measured):

* **UNLOCATED** — rename the cell's first column so the locator matches nothing.
  Measured: `UNLOCATED SA-CAP-CENSUS-SELFTEST SCORECARD.md` +
  `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=1 ambiguous=0 policy=2 setup=0)`,
  and `bash plans/round-36-c1.sh` printed **`0`**, rc 0.
* **AMBIGUOUS** — duplicate the capability row. Measured:
  `AMBIGUOUS SA-CAP-CENSUS-SELFTEST SCORECARD.md lines=701,702` +
  `stale=0 ambiguous=1`, and the C1 counter printed **`0`**, rc 0.

**This is a fail-open in the C1 counter as frozen**, not in the candidate:
`plans/round-36-c1.sh:22-24` extracts the `stale=` field with
`sed -n 's/^SELF_COUNTS:.*stale=\([0-9][0-9]*\).*/\1/p' | tail -1` and takes **only** that
number. A `POLICY`/`STALE` summary whose population was *not measured* (`unlocated=1`,
`ambiguous=1`) still carries `stale=0`, so the counter reads 0 and exits 0.

**Why this is not a live hazard for the L1's landing bytes, and what to record:**
the landing tree has exactly one `| source registry + census gate |` row
(`grep -c` = 1), the locator matches it, and `stale=0 unlocated=0 ambiguous=0` is what
the L1's own receipt records (`.ufo/waves/round-36/final/self-counts-at-tip.txt`:
`SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`).
The **population is measured, not skipped**. But the counter cannot *prove* that from its
own stdout, and the plan's kill rule "the counter prints 0 on a tree where either
population is non-empty (a removed instrument, a missing reading, a SETUP-shaped output
read as zero) → C1 fails" is exactly the shape this fail-open covers. The two committed
predeclaration controls (`setup-c1-missing-c1.out` → exit 2) cover a *removed instrument*,
not an *unmeasured population*. Recommend the L1 land the reading **with the full
`SELF_COUNTS:` summary line in the receipt**, so `unlocated=0 ambiguous=0` is on the
record next to the integer, rather than the integer alone.

---

## 3. Minimal edit set on `SCORECARD.md` that makes SD5 = 0 and `stale` = 0

### 3.1 SD5 = 0 — minimal edit, and why the post-move row is what SD5 reads

**The proof is in the code path, and it is reproduced by the sweep itself.**

`SD5` compares the red set (§1.3) against `cal_text` = the calibration row of the
**last** `## Round` section (§1.2). Therefore:

> A `## Round 36 — post-move` calibration row naming `R25-02`, `R29-01` and `R29-02`
> satisfies SD5 **iff** that post-move section is the **last** `## Round` heading in
> `SCORECARD.md`, and the ids appear with the boundary class of
> `(^|[^0-9A-Za-z-])id([^0-9A-Za-z-]|$)`.

Verified by reading the code and by measurement:

* On the landing tree the last `## Round` heading is `SCORECARD.md:1398`
  (`## Round 36 — post-move (claims C1 calibration, C2 freshness)`), its section spans
  1398–1411, and its calibration row is `SCORECARD.md:1404`. All three ids are present
  in that row (checked with the sweep's own boundary regex) → SD5 = 0.
* The sweep on the landing tree prints `SD5=0`.
* **Order trap, measured:** swapping the two round-36 sections so `pre-move` is last
  makes SD5 read the *pre-move* row and return to **SD5 = 3**.
* **Section-boundary trap:** the calibration row must be *inside* the last section —
  `cal_line` searches `NR > s && NR < e` and `e` is the next `^## ` heading. A calibration
  row in an earlier section does not count.
* **Row-shape trap:** `cal_line`'s regex is `^\| *calibration *\|` — the row must start
  with `| calibration |` (bold markers are **not** stripped here, unlike
  `claim-ledger.sh`'s `f1=${f1//\*/}`, `corpus/claim-ledger.sh:995`). A `| **calibration** |`
  row would satisfy the `cells` audit but **not** SD5.
* **Copy trap:** the ids must be in the *calibration* row, not merely in the section.

### 3.2 `stale` = 0 — the two cells that must change

1. `SCORECARD.md:701`, the `| source registry + census gate |` row: the `--selftest`
   count must be **70** (the live `R21-03` value) and must be the number captured by the
   locator (see §2.4). BASE reads 59 → `claimed=59 live=70` → STALE. The L1's edit
   (70, with 59 retained later in the same cell as the round-21 record) captures 70 →
   `OK SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=70 live=70`.
2. **Only if the ledger's claim-row count changes** (see §5.2): the three cells
   `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64` must move `79` → `82`, and the
   ledger row `R21-04`'s expect `^79$` → `^82$`. These are **not** on `SCORECARD.md`;
   they are on the three doc cells that `SCORECARD.md` does not own.

### 3.3 Without touching the five non-owned SD6 citation files

Nothing in the SD5/`stale` edit set touches them. The five files are
`corpus/lessons/round-30-verifier-spotcheck.md`,
`corpus/lessons/round-32-verifier-spotcheck.md`,
`corpus/lessons/round-33-verifier-spotcheck.md`,
`corpus/README.md` (cited from the first two) and
`corpus/knowledge/` (shorthand, cited from the third). **Caveat:** `corpus/README.md:64`
is *both* an SD6 citation target *and* the `RD-LEDGER-ROWS` cell that carries the
claim-count number. Editing `corpus/README.md:64`'s **number** (79 → 82) does not
resolve the citation (the SD6 line points at `:64/65/67` of `corpus/README.md` from the
two verifier lessons, and `corpus/README.md` itself is not the unresolved party), and the
SD6 count stays 3 — measured on the landing tree. But this is the one place where the
"do not touch non-owned files" boundary and the "must reach 0" requirement meet, so it
should be called out explicitly rather than left implicit.

### 3.4 Minimal edit set — summary

| # | file:line | edit | fixes |
|---|---|---|---|
| 1 | `SCORECARD.md` — append `## Round 36 — post-move` as the **last** `## Round` section | calibration row naming `R25-02`, `R29-01`, `R29-02` | SD5 3 → 0 |
| 2 | `SCORECARD.md:701` | `` `--selftest` 59 cases `` → `` `--selftest` 70 cases `` (59 kept later in the same cell) | `stale` 1 → 0 (this row) |
| 3 | `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64` | claim count `79` → `82` **iff** the ledger gains `R36-01..03` | `stale` 0 → 0 |
| 4 | `corpus/claim-ledger.tsv` `R21-04` | expect `^79$` → `^82$` **iff** (3) applies | the `R21-04` row itself |

---

## 4. `claim-ledger.sh cells` — what a new round-36 section requires

### 4.1 Heading shape (`corpus/claim-ledger.sh:941-944`)

```bash
AXES_RE='^(depth|coverage|operability|freshness|calibration|adjacency)$'
SEC_RE='^ {0,3}##[[:blank:]]+Round [0-9]+ — (pre|post)-move([[:blank:]]|$)'
SECTION_RE='^ {0,3}##[[:blank:]]+'
ROUND_RE='^ {0,3}##[[:blank:]]*[Rr][Oo][Uu][Nn][Dd]([[:blank:]]|$)'
```

* A round section is recognised only by `SEC_RE`: `## Round <N> — pre-move` or
  `## Round <N> — post-move`, with the **em dash** `—`, optionally up to 3 leading
  spaces, and a space or EOL after `pre-move`/`post-move`.
* `ROUND_RE` catches *any* `## Round…` heading; a heading that matches `ROUND_RE` but
  neither `SEC_RE` nor the blocked-attempt line dies with
  `unrecognised round heading in $SCORECARD` (exit 2). The only exemption is
  `BLOCKED_ATTEMPT_RE` = `^## Round 20 — interactive attempt; blocked, not completed \(2026-10-15\)$`.
* **Every recognised round section must carry all six axes exactly once**
  (`section_check`, `:947-955`): a section missing an axis, or carrying one twice, dies
  with `does not carry all six axes exactly once` (exit 2). The landing tree's round-36
  sections carry all six (`SCORECARD.md:1404-1409` in the post-move section).
* The axis cell's first column is matched after stripping whitespace and `*`
  (`:994-996`), so `| **calibration** |` is fine **for `cells`** — but not for SD5 (§3.1).

### 4.2 Pointer resolution — what makes a cell "pointed"

`cells()` (`:965-1045`): for each axis row, a cell is POINTED if it names

* a **resolving claim row id** — `is_row()` (`:869-874`) against the ids loaded from
  `corpus/claim-ledger.tsv`; the id tokens are harvested by
  `line_ids` with `IDWORD_RE='[A-Za-z0-9_-]*R[0-9]+-[0-9]+[A-Za-z0-9_-]*'` (`:881-882`); or
* a **pinned artifact path** — `stamp_index()` (`:482-486`) against `corpus/stamps.tsv`
  (exact first-field match), with the token normalised by `norm_tok` (`:732-756`),
  which strips backticks/quotes/parens/`./`/line refs/anchors/query strings.

A cell with neither is printed as `UNCITED <file>:<line> <axis>` and increments
`CL_UNCITED`; the run then exits 1 with `CELL_AUDIT: BROKEN`.

Then `cells_evidence()` (`:1052-1090`) gives the pointers teeth:

* every cited claim row is **re-run** through `verify_claims` (rows that invoke this
  gate itself are `SKIP-SELF`; host rows are `HOST-SKIP`; substrate rows `DEFER`);
  a row failure → `row_failures` → exit 1;
* every cited pinned artifact is **re-compared** (`stamp_cmp`); a moved artifact →
  `STALE-POINTER` → `stale_pointers` → exit 1.

**Practical consequence for the L1's post-move rows:** a cell that cites `R36-01`
requires that row to exist in `corpus/claim-ledger.tsv` (it does, at `:98`), and
`R36-01`'s command is `bash plans/round-36-c1.sh` with expect `^0$` — so the cell's
pointer is only "held" if the C1 counter actually prints 0. A round-36 section whose
cells cite `R36-01`/`R36-02` therefore makes `cells` **contingent on the C1/C2 landing**;
a section that cites only already-existing ids is decoupled.

### 4.3 What `cells` requires of the new section — the concrete list

1. Heading exactly `## Round 36 — pre-move` / `## Round 36 — post-move` (em dash).
2. **All six axes, exactly once each**, in each new section.
3. Every axis cell pointed: a resolving `R<n>-<n>` id or a `corpus/stamps.tsv` path.
4. The ids cited must exist in `corpus/claim-ledger.tsv` and, if they are command rows,
   must **pass** when re-run.
5. Any stamped path cited must be **re-pinned** (or it becomes `STALE-POINTER`).
6. `cells` must be run with the scorecard inside the checked doc set (it refuses
   otherwise — `:973-975`).

Measured on the landing tree: `cells` ends
`CELL_AUDIT: POLICY (cells=270 row_pointed=198 stamp_pointed=129 policy=2)` — rc 2,
`policy=2` being the pre-existing `R29-01`/`R29-02` `first-token:python` refusals
(identical to BASE, which ends `CELL_AUDIT: POLICY (cells=258 row_pointed=189 stamp_pointed=128 policy=2)`).
**Note the delta:** BASE `cells=258` → landing `cells=270` (+12 = the two new six-axis
sections), and BASE had **no** `STALE-POINTER` lines while the intermediate candidate tree
showed five (`SCORECARD.md`, `corpus/claim-ledger.tsv`, `corpus/SOURCES.md`,
`corpus/release-clock.py`, `corpus/release-clocks.tsv`) — all cured by the L1's
`corpus/stamps.tsv` re-pin.

### 4.4 Which paths must be re-pinned in `corpus/stamps.tsv`, and how `stamp` treats a partial path list

**Answer to the "partial path list" question first**, because it is the trap:

`stamp()` (`corpus/claim-ledger.sh:381-442`) **replaces the row set**; it does not merge.
The guard is per-path, not per-count:

```bash
if [[ $PRUNE -eq 0 && -f $out ]]; then
  while IFS= read -r old || [[ -n ${old:-} ]]; do
    …
    old=${old%%$'\t'*}
    [[ " ${POS[*]} " == *" $old "* ]] ||
      die "refusing to shrink $out: '$old' is pinned and would be dropped (existing $existing rows, new ${#POS[@]}; pass --prune to accept)"
  done <"$out"
fi
```

Measured on a copy of the frozen BASE tree (`exp-stamp`):

```
$ bash corpus/claim-ledger.sh stamp --root . --out corpus/stamps.tsv SCORECARD.md
claim-ledger: refusing to shrink …/corpus/stamps.tsv: 'LOG.md' is pinned and would be dropped (existing 112 rows, new 1; pass --prune to accept)
rc=2
```

So a **partial** path list is **refused (exit 2)** — it does not silently update one
row. And `--prune` does accept it, but then **drops every un-named row**:

```
$ bash corpus/claim-ledger.sh stamp --root . --out corpus/stamps.tsv SCORECARD.md --prune
STAMPED: n=1 out=…
$ grep -c '[^[:space:]]' corpus/stamps.tsv
1
```

**Therefore the only safe re-pin is the full 112-path list** — verified working:

```
$ bash corpus/claim-ledger.sh stamp --root . --out corpus/stamps.tsv $(cut -f1 corpus/stamps.tsv)
STAMPED: n=112 out=…
```

`--prune` with a partial list is a trap: it silently destroys the other 111 pins.

**The exact paths that must be re-pinned** after the candidate's edits — measured by
recomputing every stamp row's sha/lines/bytes against the landing tree:

| path | why it changes | in `stamps.tsv` at row |
|---|---|---|
| `SCORECARD.md` | F1 adds two sections; F2 rewrites `:701` | 3 |
| `corpus/SOURCES.md` | the four re-dated registry rows | 8 |
| `corpus/claim-ledger.tsv` | three new `R36-` rows | 13 |
| `corpus/release-clock.py` | F4 `DEFAULT_RECEIPT_SHA256` + `receipt_path` default | 98 |
| `corpus/release-clocks.tsv` | F3, 15 rows re-dated + 5 more re-dated | 99 |
| `corpus/self-counts.tsv` | **the armed row `SA-CAP-CENSUS-SELFTEST` was added in the frozen instrument commit `cb8cb65` without re-pinning** | 105 |

That last row is a **pre-existing stamp defect at BASE**, measured:

```
BASE stamp rows: 112 stale: 1
   ('corpus/self-counts.tsv', 'sha 5fff91ce8794->77ad6e22e92b lines 81->87 bytes 12769->13361')
```

and `bash corpus/claim-ledger.sh verify` at BASE prints
`STALE corpus/self-counts.tsv sha=5fff91ce8794->77ad6e22e92b lines=81->87 bytes=12769->13361`.
The landing tree re-pins it (row 105 → `77ad6e22…`, 87/13361), which clears it.

Additionally, `corpus/lessons/round-36.md` exists in the lane tree as an **untracked**
file and is **not** in `stamps.tsv` (32 lesson files are pinned; `round-36.md` is not).
If it is to be landed, it must be pinned too — and that changes the stamp **row count**,
which the ledger row `R12-03` pins as `^112$` (`grep -c '[^[:space:]]' corpus/stamps.tsv`),
and which `SKILL.md:46` / `PROVINCE.md:73` / `corpus/README.md:65` quote as "112".
**Adding one stamp row makes `R12-03` stale and the three doc cells stale** — the same
class of cascade as §5.2. Flagged for the L1: the landing tree's `stamps.tsv` has 112
rows and `round-36.md` is *not* among them.

---

## 5. The decisive finding: the candidate as specified does not reach 0

### 5.1 F1+F2 alone on the frozen BASE → C1 = 0

Fixture `exp-f1f4`: `git archive cb8cb65` + F1 (a `## Round 36 — post-move` section
whose calibration row names the three reds) + F2 (`:701` 59 → 70), **nothing else**.

```
=== C1 counter with F1+F2 ONLY on base (79 claims unchanged):
0
rc=0
```

So F1+F2 is *sufficient* for C1 = 0 **on a tree whose ledger still has 79 rows**.

### 5.2 The same bytes on a tree whose ledger has 82 rows → C1 = 3

The landing tree adds three claim rows `R36-01..R36-03` (`corpus/claim-ledger.tsv:98-100`).
That changes the **live** claim-row count from 79 to 82, and three `self-counts.tsv` cells
bind exactly that number:

| cell | locator | source | BASE claim | landing live |
|---|---|---|---|---|
| `SC-SKILL-CLAIMS` | `SKILL.md:46` `^\| Re-run a claim .*?\([0-9]+ stamps \+ ([0-9]+) claims\b` | `ledger:R21-04` | 79 | **82** |
| `PV-CLAIMS` | `PROVINCE.md:73` `^- \`corpus/claim-ledger\.sh\` — .*?revision stamps \+ ([0-9]+) claim rows` | `ledger:R21-04` | 79 | **82** |
| `RD-LEDGER-ROWS` | `corpus/README.md:64` `^\| Ledger rows(?: at round [0-9]+)? \(data\) \| .*?\| ([0-9]+) rows(?: at round [0-9]+)? \(` | `ledger:R21-04` | 79 | **82** |

Measured on the L1's candidate tree (before the doc migration):

```
STALE SC-SKILL-CLAIMS SKILL.md:46 claimed=79 live=82
STALE PV-CLAIMS PROVINCE.md:73 claimed=79 live=82
STALE RD-LEDGER-ROWS corpus/README.md:64 claimed=79 live=82
POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted
POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted
SELF_COUNTS: POLICY (claims=63 stale=3 unlocated=0 ambiguous=0 policy=2 setup=0)
```
```
=== C1 counter on candidate working tree:
3
rc=0
```

Note the direction: **SD5 was already 0** on that tree (the sweep reported `SD5=0`), and
the whole residual 3 is this *second* population — a population the plan's C1 section
does not name. `plans/round-36.md:26-28` describes `stale` as "declared self-count rows
whose claimed integer differs from the live source" and gives BASE 1; it does not
anticipate that adding the round's own three claim rows creates three new stale cells.

### 5.3 The fix, measured — and it is exactly the extra three edits

Fixture `exp-fix` = the candidate tree + `79 → 82` in `SKILL.md:46`, `PROVINCE.md:73`,
`corpus/README.md:64`:

```
=== C1 counter on exp-fix (79->82 migrated):
0
rc=0
```

Fixture `exp-docs-only` (the three doc cells migrated, `R21-04`'s expect left at `^79$`):
`SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` and
**C1 = 0**, rc 0. So the three **doc** cells are what the C1 counter needs; migrating
`R21-04`'s expect is needed for `claim-ledger.sh verify`, not for C1.

Fixture `exp-full2` = `exp-fix` + a full 112-path stamp re-pin: **C1 = 0**, rc 0.

The L1 has since applied exactly this migration — `SKILL.md:46` reads
`112 stamps + 82 claims + claim ids`, `PROVINCE.md:73` reads
`112 revision stamps + 82 claim rows`, `corpus/README.md:64` reads `82 rows`, and
`R21-04`'s expect is `^82$` — and the landing tree measures:

```
=== C1 counter on LIVE2 (current lane working tree):
0
rc=0
=== C2:
0
rc=0
```

### 5.4 The rest of the cascade the plan does not name

Adding `R36-01..03` and two `## Round 36` sections also moves three **other** ledger
rows that pin counts or digests over the very memberships that changed. The L1 migrated
all three; the plan's C1 section names none of them:

| row | pin at BASE | value on the landing tree | L1's migration |
|---|---|---|---|
| `R13-01` | `grep -c '^## Round ' SCORECARD.md` → `^44$` | **46** | → `^46$` |
| `R24-06` | `row-identity.sh scorecard-rounds` → `count=44 sha256=40f9c938…` | **count=46 sha256=accc4d54…** | → new digest |
| `R24-14` | `row-identity.sh ledger-ids` → `count=79 sha256=36ce51df…` | **count=82 sha256=bf834978…** | → new digest |

These are exactly the rows `cells` re-runs as pointer evidence (`cells_evidence`),
which is why the intermediate candidate tree showed
`FAIL R24-06 reason=verdict-not-final` and `FAIL R24-14 reason=verdict-not-final` in
its `cells` output.

Also: `R25-04` was **re-purposed**, not merely re-pinned — from
`python3 corpus/release-clock.py` (expecting the round-26 `RELEASE_CLOCK: CLEAN … fired=3`)
to `sha256sum .ufo/waves/round-26/observe-2.json` (expecting `^13b8540c…`). That
preserves the round-26 receipt as history (its sha still verifies:
`sha256sum .ufo/waves/round-26/observe-2.json` → `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`),
but it **changes what the row asserts** — the "the table agreed with the round-26
receipt" claim is retired in favour of a byte pin, and the live gate verdict moves to
the new `R36-03`. The row's note records the migration, which is the QM14 shape; a
migration journal under `.ufo/waves/round-36/` (the pattern of
`.ufo/waves/round-26/expectation-migrations.json`) is **not** present — `.ufo/waves/round-36/`
contains only `build/`, `controls/`, `final/` and the dispatch files.

---

## 6. Reproducing every number in this report

All from `/fast/scratch/hyaku/kagi-r36/ScoutSweep/` (scratch root, since removed per the
seat spec; fixtures were disposable copies):

```bash
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive cb8cb659e84240a8db12e4f7b4a0def5068baf7e | tar -x -C base/
cd base && bash plans/round-36-c1.sh        # 4
cd base && bash corpus/self-description-sweep.sh   # SD5=3 SD6=3
cd base && python3 corpus/self-counts.py    # STALE SA-CAP-CENSUS-SELFTEST claimed=59 live=70
# candidate tree = live lane working tree snapshot
cd cand && bash plans/round-36-c1.sh        # 3   (before the doc migration)
cd exp-fix && bash plans/round-36-c1.sh     # 0   (doc migration applied)
cd exp-f1f4 && bash plans/round-36-c1.sh    # 0   (F1+F2 only, on BASE)
cd exp-nocal && bash corpus/self-description-sweep.sh   # SETUP … exit 2
cd exp-ambig3 && python3 corpus/self-counts.py          # AMBIGUOUS … stale=0
cd live2 && bash plans/round-36-c1.sh && bash plans/round-36-c2.sh   # 0  0
```

Fixture recipes are in §2.4, §3, §5 and §4.4 (each names the tree and the exact edit).

---

## 7. Dead ends and honest limits

* **No tool installs.** Nothing in this recon needed a tool that was missing; the whole
  job ran on the host's `bash`, `python3`, `git`, `rsync`, `sha256sum`, `awk`, `sed`,
  `grep`. Nothing to record under the operator's tooling directive.
* **`row-identity.sh revision-added` could not be evaluated** on this host: it prints
  `ROW_IDENTITY: SETUP (revision-audit --history failed)` because the history commit
  `c2cab35b…` is not reachable in this clone. Consequently `R24-15` FAILs in both BASE
  and the landing tree's `cells`/`verify` output — a **pre-existing, host-dependent**
  red, not something round 36 introduced. I did not attempt to fetch the history commit.
* **`R24-15`'s expectation is therefore unverified by me** — I can only report that the
  row is red at BASE for a substrate/history reason.
* **I did not run the full `claim-ledger.sh verify` to completion** on every fixture
  (it runs ~4 min and exits 141 on the inherited `MISSING-ID` history, e.g.
  `MISSING-ID LOG.md:1683 R32-1` …). I ran it fully on BASE and captured its stamp
  section; on the landing tree I relied on the L1's own receipt plus my own
  `stamp_cmp` recomputation of all 112 rows (which is the same comparison `verify`
  makes).
* **`claim-ledger.sh cells` on the F1–F4-only fixture** exits 141 with a large
  `MISSING-ID` list — because that fixture's new post-move row cites `R36-01`, which
  does not exist on a tree without the ledger rows. I did not attempt a variant that
  cites only pre-existing ids; the point (contingency of `cells` on the C1 landing) is
  established by the code path in §4.2.
* **I did not measure SD1–SD4 or SD7–SD9 individually** beyond the summary line; they
  read 0 on both BASE and the landing tree.
* **I did not verify the round-36 receipt's 20 feed rows against the live feeds** — that
  is C2's population and outside this seat's read of the C1 instrument. C2 was measured
  only as the counter's integer (15 at BASE, 0 on the landing tree).
* **The `unlocated`/`ambiguous` fail-open (§2.4) is a property of the frozen counter
  `plans/round-36-c1.sh`, which I am read-only on.** I have not proposed a patch; the
  recommendation is to land the `SELF_COUNTS:` summary line beside the integer in the
  receipt, not to change the frozen instrument.
