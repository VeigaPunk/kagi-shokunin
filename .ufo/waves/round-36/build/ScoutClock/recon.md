# ScoutClock — recon of the C2 reading and the F3/F4 edit

Seat: ScoutClock (scout). Lane: `kagi-shokunin`. Read-only on the lane;
all writes are under `.ufo/waves/round-36/build/ScoutClock/`.

All line references are to the **committed** BASE bytes
(`git show HEAD:<path>`, HEAD = `09f27e2` plan / `cb8cb65` instrument), unless
marked "working tree".

---

## 1. The constraints a table row must satisfy to pass `evaluate`

Source: `corpus/release-clock.py` (committed, 2151 lines). `evaluate` is at
lines 552–713; `receipt_matches` at 475–506; `derived_anchor_bound` at
349–364; `is_regression` at 433–438; `feed_floors` at 440–461.

### 1a. `receipt_matches` (L475–506) — the receipt must agree field-by-field

For **every** bound row (not only feed rows):

| field | required equality | note |
|---|---|---|
| `id` | `receipt["id"] == source_id` | exact string |
| `clock` | `receipt["clock"] == values["clock"]` | `feed` vs `rendered-quote` |
| `url` | `receipt["url"] == values["feed_url"]` (feed) **or** `source["url"]` (quote) | |
| `verdict` | `receipt["verdict"] == values["verdict"]` | |
| `observed_at` | `receipt_date(receipt["observed_at"]) == values["observed_at"]` | **date only** — the receipt's `2026-11-04T23:42:53Z` must equal the cell `2026-11-04` |
| `http_status` | `type(status) is int and 200 <= status < 300` | |
| `sha256` | `re.fullmatch(r"[0-9a-f]{64}", ...)` | |
| `error` | must be absent | `"error" in receipt` ⇒ mismatch |

Feed rows additionally: `parsed_version` must be a string with
`norm_version(parsed_version) == norm_version(observed_version)`, and
`receipt["located"] is None`. Quote rows additionally: `parsed_version is None`
and `located` is a `bool` equal to `verdict == "quote-located"`.

**This is the load-bearing constraint the plan's §Fix prose under-specifies.**
`receipt_matches` compares `observed_at` on **all thirty** bound rows, not
only the fifteen drifting ones. The frozen C2 operability kill rule requires
`python3 corpus/release-clock.py` to print CLEAN at the landing revision
against the repointed default receipt — so every bound row must be re-dated
to `2026-11-04`, including the fifteen rows whose version and verdict do not
move. See §2/§5.

### 1b. The `is_derived` note-prefix rule (L617)

`is_derived = values["note"].startswith("derived:")` — the prefix is literal
and must be the **first** characters of the note cell. Consequences:

- When `is_derived` is true, `anchor_ok` is satisfied unconditionally, but the
  row must additionally pass `derived_anchor_bound` (§1c) or it is a typed
  `DERIVATION` finding.
- When `is_derived` is false, the row must satisfy
  `version_is_named(sources[source_id]["anchor"], anchored)` or it is typed
  `INCONSISTENT`.
- Therefore **the note text of a derived row may be extended but must keep
  `derived:` as its first characters**. Appending a receipt citation after
  the existing text is safe; prepending one breaks the row.

Measured over the committed BASE table, the derived rows are
S008–S011, S013–S016, S021–S026, S029 (15 rows). Non-derived: S012, S027,
S028, S040, S041.

### 1c. `derived_anchor_bound` (L349–364) — the anchor cell is the binding

For a derived row the bound version is the one strict X.Y.Z token named in
the **feed source row's anchor cell** (`corpus/SOURCES.md` column 6, index 5
in `parse_sources` L52–89), never the `teaches` cell. The rule is
`set(STABLE_TOKEN_RE.findall(feed_anchor)) == {norm_version(anchored)}`:
a cell naming two versions binds none; a prerelease/build sibling
(`v2.2.0-rc1`) or a longer component (`3.13.30`) is a different token.

Committed BASE anchor cells:

| feed row | anchor cell names | binds |
|---|---|---|
| S033 | `v3.13.3` | 3.13.3 (S008–S011) |
| S034 | `v2.2.0` | 2.2.0 (S013, S022–S024) |
| S035 | `v2.7.1` | 2.7.1 (S014–S016, S021, S025, S026) |
| S036 | `Python 3.15.0` | 3.15.0 (S027, S028 — but those notes are not `derived:`) |
| S037 | `8.23.0` | 8.23.0 (S029) |
| S039 | `Python 3.15.1` | 3.15.1 (S040, S041 — notes not `derived:`) |

**Consequence:** because the anchored_version of the drifting rows is
untouched, rewriting the S034/S035 anchor cells to the newly observed
`v2.2.1` / `v2.7.2` would **break** the binding for four + seven rows. I
measured this trap in an isolated fixture (scratch `fx7`): editing S034's
anchor cell to `v2.2.1` produced

```
DERIVATION S013
DERIVATION S022
DERIVATION S023
DERIVATION S024
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=11 derived=11)
```

A second trap (scratch `fx8`): editing S040's own anchor cell to
`Python 3.15.2` produced `INCONSISTENT S040` / `INCONSISTENT S041`
(their rows are not `derived:`, so they need
`version_is_named(sources["S040"]["anchor"], "3.15.1")`).

Both are reasons the F3 edit must not touch `corpus/SOURCES.md`. The working
tree currently has **no** `corpus/SOURCES.md` diff, which is the correct
state.

### 1d. `is_regression` against `feed_floors` (L433–461)

`feed_floors` computes, per feed URL, the highest **strict numeric** anchor
over all well-formed feed rows on that URL; non-numeric anchors (S012's
`v1.21.x`) contribute nothing. `is_regression(floor, observed)` is true when
both are canonical strict X.Y.Z and `observed < floor`.

Committed BASE floors:

| feed URL | floor | source rows |
|---|---|---|
| `github.com/getsops/sops/releases.atom` | 3.13.3 | S008–S011 |
| `github.com/hashicorp/vault/releases.atom` | 2.2.0 | S013, S022–S024 (S012's `v1.21.x` is non-numeric) |
| `github.com/openbao/openbao/releases.atom` | 2.7.1 | S014–S016, S021, S025, S026 |
| `www.python.org/downloads/feed.rss` | **3.15.1** | S027 (3.15.0), S028 (3.15.0), **S040 (3.15.1)**, S041 (3.15.1) |
| `curl.se/info` | 8.23.0 | S029 |

The Python floor is the one that matters: it is `3.15.1`, not `3.15.0`,
because S040/S041 anchor at 3.15.1 on the same feed URL. The new Python
observation `3.15.2` is **above** that floor, so it is not a regression.

### 1e. Fired / not-fired consistency (L645–656)

```
verdict == "fired"      and norm(observed) != norm(anchored)  -> fired row
verdict == "not-fired"  and norm(observed) == norm(anchored)  -> not-fired row
otherwise                                                  -> INCONSISTENT
```

So a `fired` verdict **requires** the observation to differ from the anchor,
and a `not-fired` verdict **requires** them to be equal. Any other pairing is
typed `INCONSISTENT` and fails the run.

---

## 2. The receipt and the per-row proposal

Receipt: `.ufo/waves/round-36/controls/observe-live.json`
sha256 `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`
(measured: `sha256sum` matches the frozen plan's stated digest; the file is
committed — `git ls-files` confirms the path is tracked).

It carries **30** records, one per bound row (S005–S032, S040, S041), all
`http_status` 200, all `observed_at` on **2026-11-04** (timestamps
23:42:50Z–23:42:58Z).

Full machine-readable proposal: **`proposal.tsv`** (sibling file).

### The fifteen drifting `clock=feed` rows

| id | old obs | new obs | old verdict | new verdict | anchored (untouched) | derived-note prefix |
|---|---|---|---|---|---|---|
| S012 | 2.2.0 | **2.2.1** | fired | fired | `v1.21.x` | n/a (not derived) |
| S013 | 2.2.0 | **2.2.1** | not-fired | **fired** | 2.2.0 | keep `derived:` |
| S014 | 2.7.1 | **2.7.2** | not-fired | **fired** | 2.7.1 | keep `derived:` |
| S015 | 2.7.1 | **2.7.2** | not-fired | **fired** | 2.7.1 | keep `derived:` |
| S016 | 2.7.1 | **2.7.2** | not-fired | **fired** | 2.7.1 | keep `derived:` |
| S021 | 2.7.1 | **2.7.2** | not-fired | **fired** | 2.7.1 | keep `derived:` |
| S022 | 2.2.0 | **2.2.1** | not-fired | **fired** | 2.2.0 | keep `derived:` |
| S023 | 2.2.0 | **2.2.1** | not-fired | **fired** | 2.2.0 | keep `derived:` |
| S024 | 2.2.0 | **2.2.1** | not-fired | **fired** | 2.2.0 | keep `derived:` |
| S025 | 2.7.1 | **2.7.2** | not-fired | **fired** | 2.7.1 | keep `derived:` |
| S026 | 2.7.1 | **2.7.2** | not-fired | **fired** | 2.7.1 | keep `derived:` |
| S027 | 3.15.1 | **3.15.2** | fired | fired | 3.15.0 | n/a (not derived) |
| S028 | 3.15.1 | **3.15.2** | fired | fired | 3.15.0 | n/a (not derived) |
| S040 | 3.15.1 | **3.15.2** | not-fired | **fired** | 3.15.1 | n/a (not derived) |
| S041 | 3.15.1 | **3.15.2** | not-fired | **fired** | 3.15.1 | n/a (not derived) |

Twelve change verdict `not-fired → fired`; three keep `fired`
(S012, S027, S028). This matches the plan's §C2 prose exactly (measured, not
assumed).

### Note text that keeps a row valid

Every drifting row's note gains a citation of the receipt. The safe form is
**append** to the existing note, keeping `derived:` first for derived rows:

- Derived rows (S013, S014–S016, S021–S026):
  `derived: <existing text>; re-observed by the round-36 receipt observe-live.json (2026-11-04), observed <version>, past the anchor, so the clock FIRED`
- Non-derived rows (S012, S027, S028, S040, S041): the existing note text
  with a receipt clause appended, e.g.
  `... ; round-36 receipt observe-live.json (2026-11-04) observes <version>`

The receipt name must be spelled so a reader can find it; the
`.ufo/waves/round-36/controls/observe-live.json` path plus the date is
sufficient. What is **not** sufficient is a bare version with no receipt
name — the note is the only place the row records which observation it
rests on, and QM14/QM21 require the current-tense number to be bound to its
source.

### The other fifteen rows (not in the C2 counter population)

S005–S011, S017–S020, S029–S032 keep their version and verdict but must be
**re-dated** `2026-10-21 → 2026-11-04`, or `receipt_matches` rejects them on
`observed_at` and the gate prints `RECEIPT-MISMATCH` for each. Measured in
scratch `fx2` (F3 applied to only the fifteen drifting rows + F4):

```
RECEIPT-MISMATCH S005 ... S011, S017 ... S020, S029 ... S032   (15 rows)
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=15 fired=15 derived=10)
```

while `bash plans/round-36-c2.sh` still printed **0** — the counter's
population is only `clock=feed` rows and it compares `parsed_version` and
`verdict` only. This is the sharpest reading in this recon: **the C2 counter
reading 0 does not imply the gate is CLEAN**; the operability kill rule is a
separate, necessary check, and it is what forces the thirty-row re-date.

---

## 3. Which rows trip REGRESSED / DERIVATION / INCONSISTENT

**Answer: with the proposed values and the anchor cells untouched, none.**

The arithmetic, per feed:

- **Vault (S012, S013, S022–S024), floor 2.2.0.**
  Observed 2.2.1 > floor 2.2.0 → not a regression.
  S012 anchored `v1.21.x`: `numeric_version("1.21.x")` is `None` (two-component
  / series anchor), so `is_regression` is false on the anchor by construction;
  the floor check carries the comparison and 2.2.1 > 2.2.0.
  Fired consistency: S012 observed `2.2.1` ≠ anchor `v1.21.x` ⇒ `fired`
  valid. S013/S022–S024 observed `2.2.1` ≠ anchor `2.2.0` ⇒ `fired` valid.
  Derivation: S013/S022–S024 are `derived:` and `derived_anchor_bound(S034.anchor,
  "2.2.0")` holds because S034's anchor cell still names `v2.2.0` → bound.
- **OpenBao (S014–S016, S021, S025, S026), floor 2.7.1.**
  Observed 2.7.2 > 2.7.1 → not a regression. Observed 2.7.2 ≠ anchor 2.7.1 ⇒
  `fired` valid. `derived_anchor_bound(S035.anchor, "2.7.1")` holds (S035's
  anchor cell still names `v2.7.1`) → bound.
- **Python (S027, S028, S040, S041), floor 3.15.1.**
  Observed 3.15.2 > 3.15.1 → not a regression. S027/S028 observed 3.15.2 ≠
  anchor 3.15.0 ⇒ `fired` valid. S040/S041 observed 3.15.2 ≠ anchor 3.15.1 ⇒
  `fired` valid (and their notes are not `derived:`, so
  `version_is_named(S040.anchor, "3.15.1")` must hold — it does, because
  S040's anchor cell names `Python 3.15.1`).
  This floor is the trap: had the observation stayed at 3.15.0 it would be
  `< 3.15.1` ⇒ `REGRESSED`.
- **SOPS (S008–S011), floor 3.13.3.** Unchanged observation 3.13.3 == anchor
  ⇒ `not-fired` valid; not a regression (equal to floor is a declared limit,
  not a finding). `derived_anchor_bound(S033.anchor, "3.13.3")` holds.
- **curl (S029), floor 8.23.0.** Unchanged 8.23.0 == anchor ⇒ `not-fired`
  valid; `derived_anchor_bound(S037.anchor, "8.23.0")` holds.

Rows that **would** trip, if the edit went further than proposed:

| would trip | condition | measured evidence |
|---|---|---|
| DERIVATION ×4 (S013, S022, S023, S024) | S034's anchor cell rewritten to `v2.2.1` | scratch `fx7`, printed DERIVATION for exactly those four |
| DERIVATION ×7 (S014–S016, S021, S025, S026) | S035's anchor cell rewritten to `v2.7.2` | same rule, same cells |
| INCONSISTENT ×2 (S040, S041) | S040's own anchor cell rewritten to `Python 3.15.2` | scratch `fx8`, printed INCONSISTENT for exactly those two |
| REGRESSED ×2 (S027, S028) | observed left at 3.15.0 (feed floor is 3.15.1, not 3.15.0) | arithmetic above |
| INCONSISTENT ×1 (S012) | observed set equal to its anchor while verdict stays `fired` | rule at L645 |

---

## 4. `receipt_path`, `DEFAULT_RECEIPT_SHA256`, and stale round-26 citations

### What they must become

| symbol | committed BASE | must become |
|---|---|---|
| `DEFAULT_RECEIPT_SHA256` (L28) | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` | `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727` |
| `receipt_path(root, None)` (L545–547) | `root/".ufo"/"waves"/"round-26"/"observe-2.json"` | `root/".ufo"/"waves"/"round-36"/"controls"/"observe-live.json"` |
| argparse `--receipt` help (L2105) | `default is the round-26 rearmed receipt` | `default is the round-36 observation receipt` |

Measured: the round-26 receipt file still exists at
`.ufo/waves/round-26/observe-2.json` with sha256
`13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` —
byte-identical to the old default. It is **not** rewritten or deleted; it
stays citable via `--receipt .ufo/waves/round-26/observe-2.json --receipt-sha
13b8540c…`. That satisfies the plan's kill rule "any historical receipt is
rewritten or deleted rather than superseded → C2 fails" (the file is
untouched).

### Call sites / prose that still cite the round-26 receipt as the default

Grep over `corpus/*.py corpus/*.sh corpus/*.md corpus/*.tsv SKILL.md
PROVINCE.md SCORECARD.md` for `round-26`:

**Stale after F4 (these are the findings):**

| location | text | why it is stale |
|---|---|---|
| `SKILL.md:48` | "`python3 corpus/release-clock.py` replays the **pinned round-26 rearmed receipt**" | the default is now the round-36 receipt |
| `SKILL.md:787` | "default is the byte-pinned **round-26 rearmed receipt**" | same |
| `PROVINCE.md:75` | "default is the pinned round-26 rearmed receipt, NOT live vendor truth" | same |

The working tree currently still carries all three unchanged — I read them
after the L1's latest edits. Each is a self-description claim about the
lane's own artifact and is the class QM21 covers ("a current-tense number a
committed doc states about this lane's own artifacts is bound to the live
source"); here the "live source" is `receipt_path`/`DEFAULT_RECEIPT_SHA256`.
Neither `corpus/self-counts.py` nor the sweep reads these three lines, so
they will not trip a counter — they are honest-reporting findings for the
L1, not counter failures.

**Correctly historical — do not change:**

- `corpus/claim-ledger.tsv` R25-04 note: "round26 explicit migration to the
  NEW pinned rearmed receipt `.ufo/waves/round-26/observe-2.json`" — the row
  *records* the round-26 migration; it is a historical statement.
- `corpus/README.md:193`, `corpus/README.md:205–218` — the "Round-26 bounded
  drift response" section, and the `.ufo/waves/round-26/tools/replay-current.sh`
  / `.ufo/waves/round-26/frozen` references (those paths still exist).
- `corpus/QUALITY.md:122,126` (QM24), `corpus/SOURCES.md:46–48,108`,
  `corpus/lessons/round-26.md`, `SCORECARD.md:1038–1066`,
  `LOG.md:1423–1454` — round-26 history.
- `corpus/release-clock.py:1160` — a comment about a round-26 receipt
  comparison, in `selftest`.

**Selftest cases referencing the round-26 receipt:** none. `selftest()`
builds its own synthetic receipts; it does not read
`.ufo/waves/round-26/observe-2.json` or the round-36 receipt. The only
consumer of `DEFAULT_RECEIPT_SHA256` is `main()` (L2138), and only when
`args.receipt is None`. `grep -n "round-26" corpus/release-clock.py` returns
exactly one hit — the L1160 comment. So no selftest case needs migrating.

---

## 5. What the candidate as written would break elsewhere (measured)

These are outside C2's counter population but inside the same landing, and
each one is a gate FAIL at the landing revision.

The candidate adds three ledger rows (`R36-01..R36-03`), which moves
`corpus/claim-ledger.tsv` from 79 to 82 data rows, and adds two
`## Round 36 — …` headings to `SCORECARD.md`, moving 44 → 46. Five
committed ledger expectations then no longer match their live source:

| row | command | committed expectation | live with the candidate |
|---|---|---|---|
| R13-01 | `grep -c '^## Round ' SCORECARD.md` | `^44$` | `46` |
| R21-04 | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | `^79$` | `82` |
| R24-06 | `bash corpus/row-identity.sh scorecard-rounds` | `count=44 sha256=40f9c938…` | `count=46 sha256=accc4d54…` |
| R24-14 | `bash corpus/row-identity.sh ledger-ids` | `count=79 sha256=36ce51df…` | `count=82 sha256=bf834978…` |
| R25-04 | `python3 corpus/release-clock.py` | `fired=3 derived=15` | `fired=15 derived=15` |

Measured `bash corpus/claim-ledger.sh verify` on the working tree printed
`FAIL` for exactly R13-01, R21-04, R24-06, R24-14, R25-04 (plus the four
FAILs already present at BASE: R11-08, R22-03, R24-15, R25-02 — those are
pre-existing and unrelated).

The three self-count declarations that name the claim-row count were
rebound 79 → 82 in the working tree (`SKILL.md:46`, `PROVINCE.md:73`,
`corpus/README.md:64`) — measured `stale=3 → 0` for
`SC-SKILL-CLAIMS` / `PV-CLAIMS` / `RD-LEDGER-ROWS`. That is the
self-inflicted stale that the append caused; it is now repaired.

The three new ledger rows R36-01..R36-03 are themselves the C1/C2/C3
counter rows; R36-03's expectation is
`^RELEASE_CLOCK: CLEAN \(on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15\)$`
and the live gate prints exactly that. `plans/round-36-c3.sh` (new, untracked
in the working tree) is a thin `exec python3 corpus/release-clock.py`
wrapper so the ledger row matches the gate's own last line.

---

## 6. Current measurements at the landing revision (working tree)

| check | command | BASE | working tree |
|---|---|---|---|
| C1 | `bash plans/round-36-c1.sh` | 4 | **0** |
| C2 | `bash plans/round-36-c2.sh` | 15 | **0** |
| C3 | `bash plans/round-36-c3.sh` | n/a (script is new) | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` |
| gate | `python3 -I -B corpus/release-clock.py` | CLEAN(fired=3 derived=15) | CLEAN(fired=15 derived=15) |
| census | `bash corpus/sources-census.sh` | CLEAN rows=88 | CLEAN rows=88 |
| sweep | `bash corpus/self-description-sweep.sh` | SD5=3 SD6=5 | SD5=0 SD6=5 |

SD6 is preserved at its BASE value of 5, satisfying the C1 kill rule. (One
transient: while the connector's `ConnOverlap.md` had not landed, the
round's own new SCORECARD pointer to it added a sixth SD6 citation; it
resolved once that file landed. A sixth SD6 hit is a C1 kill-rule trip, so
the pointer must keep resolving at the landing revision.)

---

## 7. Honest limits of this recon

- All measurements are over the **working tree** at the moment of reading
  (the L1 was actively landing throughout), plus isolated `git archive HEAD`
  fixtures under `/fast/scratch/hyaku/kagi-r36/ScoutClock/`. Every number
  above names the command that produced it.
- The `SD6` baseline of 5 was measured on the real tree, where the five
  non-author spot-check lessons resolve as UNRESOLVED; a lone `git archive`
  fixture measures 3 because two of those lessons cite a sibling-lane
  absolute path. The plan's frozen BASE value (5) matches the real tree, so
  the real tree is the right reference.
- `bash corpus/claim-ledger.sh verify` takes ~3 minutes; its per-row FAIL
  list was captured once per tree state and the trees changed under me.
  The five-row list in §5 was re-confirmed by running each row's command
  directly, which is the version I stand behind.
- I did not re-run `corpus/claim-ledger.sh cells`, `citations` or `docs`
  against the final landing tree; the last full `verify` I saw predates the
  last two L1 edits (the `corpus/lessons/round-36.md` addition and the
  `corpus/stamps.tsv` re-pin).
- No tool was installed or upgraded for this recon; nothing was written to
  the lane except the three files under my build directory.
