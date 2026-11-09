# R69ScribeEntry — registry rows S168 / S169 and their fetch rows

SEAT-STATUS: complete. Both registry rows, both fetch rows and both captures are landed;
every gate this seat owns reads its target line:

```
bash corpus/sources-census.sh
  SOURCES_CAPTURES: CLEAN (path_rows=40 bound=40 located=40 prose=120)
  SOURCES_CENSUS: CLEAN (rows=160 A=142 B=2 C=16 queued=3 mined=139 rejected=18 entries_sourced=28 legacy=21 captures=160 inrow=16 inrow_only=0 inrow_nonreproducing=12)
  EXIT=0

bash corpus/sources-census.sh --selftest
  SOURCES_CENSUS_SELFTEST: PASS (98 cases)
  EXIT=0

bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi     # fleet contract v1
  kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
  EXIT=0

bash plans/round-36-c3.sh                                                            # release clock
  RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)
  EXIT=0
```

One routed defect remains open against another seat's file (R68-01, §4); it is not a gate this
seat owns and not a defect in the landed rows.

Written by: R69ScribeEntry (scribe, coverage). Round 69 attempt 2, wave `kagi-r69-w1`.
Claim BASE `264917aa8fc9e71b6595d0d5166c4b615120fb8b`; frozen predeclaration
`adb6972668d176768a0f1d9ffecd25d32f1070f0` (`plans/round-69.md`). I committed nothing and
edited no file outside my scope.

---

## 1. What I landed

Three write surfaces, all mine, nothing else touched:

| surface | change |
|---|---|
| `corpus/SOURCES.md` | two rows appended after S167, in id order (append-only): `S168` at line 168, `S169` at line 169. 11 columns each (`NF=13` under `awk -F'\|'`), no literal `\|` inside any cell, no TAB, no CR. |
| `corpus/source-fetches.tsv` | two rows appended (lines 202, 203), 16 TAB-separated columns each, col 16 a **pure** repo-relative capture path (so `capture-whitespace` and `capture-token` are clear), no CR anywhere in the file. |
| `.ufo/waves/round-69/capture/S168.body`, `S169.body` | the decoded bodies I opened, byte-identical to what the scout fetched independently. |

The rows as landed are byte-exact in `.ufo/waves/round-69/w1/R69ScribeEntry/rows.txt`.

**S168 — RFC 9162, admit.** `spec` / tier `A` / `mined` / opened `2026-11-08` /
recheck `180d` / used-by `corpus/knowledge/record-supersession.md`.
Anchor names **§2.1.4 Merkle Consistency Proofs, body line 475** with §2.1/§2.1.1 as the tree
the proof is over, the capture path, its 128266 B, its raw sha256
`a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f`, the HTTP 200, the
byte-identical refetch, quote locate count=1, and the normalized sha256
`03802e0b592da2cf7f9e3f6e26c92b98a85791310fc752be2f1f1c1da505fbf5` (88723 normalized bytes).
Teaches cell keeps QM42's separation: `Quote (verbatim): "Merkle consistency proofs prove the
append-only property of the tree." (raw byte offset 19819, body line 475; 10 words). Derivation
(paraphrase, outside the quote): …`.

**S169 — Wikipedia "Merkle tree", reject.** `docs` / tier `C` / `rejected` / opened
`2026-11-08` / recheck `180d` / used-by `corpus/lessons/round-69.md`.
Anchor: the lead definition paragraph, page revision `oldid=1383668961`, capture 209875 B, raw
sha256 `ad8de3b95bd73e8bb93ac1bb37fb17f0c050e53660a1f5619dba1136bd36a27c`, normalized sha256
`b3c065eb8b12abc368ef9bc236edc31057fdcfe1e29df03715f10bc2815f4cbc` (17020 normalized bytes).
Teaches cell reads `REJECTED: … ; flip: cite the RFC it summarizes (S168), whose §2.1.4 states
the append-only property and the consistency proof owed for it. Quote: "…" (24 words, locate
count=1).` — it still carries a located quote and its capture path, as my item required.

Every declared value re-derives from the bytes at my yield:

```
capture S168: 128266 B  no CR  sha256 a0e432ce…5081f   col10 match=yes  col11 match=yes
capture S169: 209875 B  no CR  sha256 ad8de3b9…6a27c   col10 match=yes  col11 match=yes
col15 vs recomputed rendered-text-v1 digest: S168 match, S169 match
registry quote (S168) == fetch col13 quote: byte-identical
```

The census's own capture read-through corroborates this independently:
`SOURCES_CAPTURES: CLEAN (path_rows=40 bound=40 located=40 prose=120)` — up from 38/38/38 at
BASE, so both new rows bind through digest → bytes → quote location → normalized digest, and no
`SC_CAPTURE` or `SC_FETCH` finding fired for S168 or S169.

## 2. The two sources, opened by me

Both fetched by this seat with `curl -fsSL --compressed -A '<browser UA>'`, HTTP 200, and a
second fetch with the same profile is **byte-identical** (`cmp` rc 0) for both. Receipts:
`fetch-168.txt`, `fetch-169.txt`.

| | S168 | S169 |
|---|---|---|
| URL | `https://www.rfc-editor.org/rfc/rfc9162.txt` | `https://en.wikipedia.org/wiki/Merkle_tree` |
| HTTP / final URL | 200, unchanged | 200, unchanged |
| decoded bytes | 128266 (gzip wire 35935) | 209875 (gzip wire 39619) |
| raw sha256 | `a0e432ce…5081f` | `ad8de3b9…6a27c` |
| quote | "Merkle consistency proofs prove the append-only property of the tree." | "a hash tree or Merkle tree is a tree in which every "leaf" node is labelled with the cryptographic hash of a data block" |
| words / locate | 10 / `count=1` | 24 / `count=1` |
| section | §2.1.4, body line 475, raw byte offset 19819 | lead definition paragraph |
| third-party revision | — | `oldid=1383668961`, last edited 4 November 2026 |

S169's reject ground is **measured, not asserted**: over the rendered text, `append-only` 0,
`append only` 0, `append` 0, `consistency proof` 0, `consistency` 0, `superset` 0, `MUST` 0.
The article defines the data structure and states no obligation, so it cannot ground the
supersession rule; the flip points at the RFC it summarizes.

## 3. Gates — verdict lines, exit codes, and the dependency that had to clear

**Lane census** (`bash corpus/sources-census.sh`), receipt `census.txt`. Terminal reading:

```
SOURCES_CAPTURES: CLEAN (path_rows=40 bound=40 located=40 prose=120)
SOURCES_CENSUS: CLEAN (rows=160 A=142 B=2 C=16 queued=3 mined=139 rejected=18 entries_sourced=28 legacy=21 captures=160 inrow=16 inrow_only=0 inrow_nonreproducing=12)
EXIT=0
```

This verdict was **blocked for most of my run** on a cross-seat dependency, and the history
matters for anyone auditing the wave. Until `R69ScribeQuality` landed
`corpus/knowledge/record-supersession.md`, the gate read:

```
FINDING SC_USEDBY_MISSING path=corpus/knowledge/record-supersession.md
SOURCES_CAPTURES: CLEAN (path_rows=40 bound=40 located=40 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=160)
EXIT=1
```

That finding is the census's own contract leg "a `mined` row's used-by path does not exist on
disk": S168 is `mined` and its used-by cell names a file another seat owns. It was never a
defect in the landed rows. I did not sit on it — I proved on a scratch copy (stub entry, no lane
edit) that the whole gate reads CLEAN the moment the file exists, messaged the peer with that
exact measurement and the one-line recipe (`source: S168` on its single column-1 source line),
and re-ran the gate the instant their entry appeared. The peer's entry now carries
`source: S168 — RFC 9162 …` and the gate is green, `entries_sourced` 27→28 by their landing.

**Selftest** (`bash corpus/sources-census.sh --selftest`), receipt `selftest.txt`:
`SOURCES_CENSUS_SELFTEST: PASS (98 cases)` EXIT=0. I did not touch the gate, so the case count
is unchanged and R21-03's pin `^SOURCES_CENSUS_SELFTEST: PASS \(98 cases\)$` still holds.

**Fleet wrapper** (`scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin
kagi`): `kagi  ok  /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md` EXIT=0. It had
read `kagi E11 S168 missing used-by …` EXIT=1 during the blocked window — the same dependency
seen by the fleet instrument, which is what convinced me it was ordering and not my row.

**Release clock** (`bash plans/round-36-c3.sh`), a gate my rows touch because `on-release` is a
cadence the brief named for S169:
`RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`
EXIT=0.

**Population delta against BASE** (`git archive 264917aa` ⇒ `SOURCES_CENSUS: CLEAN (rows=158
A=141 B=2 C=15 queued=3 mined=138 rejected=17 entries_sourced=27 legacy=21 captures=158 …)`):
my landing moves `rows 158→160`, `A 141→142`, `C 15→16`, `mined 138→139`, `rejected 17→18`,
`captures 158→160`. (`entries_sourced +1` is the peer's entry, not mine.)

## 4. Routed defect — my landing moves another seat's pinned counts (R68-01)

Measured both ways with the same counter; receipt `r68-01-population-move.txt`.

```
# round-69 tree WITH S168/S169 landed:
derived verified=40 col15=35 path_rows=40 bound=40 located=40 prose=120 mixed=none total=160 malformed=0
C1_VERIFIED: verified=40 col15=35 caught=6/6 guard=1

# identical copy with exactly my two registry rows and two fetch rows removed:
derived verified=38 col15=33 path_rows=38 bound=38 located=38 prose=120 mixed=none total=158 malformed=0
```

`corpus/claim-ledger.tsv` row `R68-01` pins
`^C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1$`, which is green at BASE (158 rows) and
red on the round-69 tree **solely** because the pure-capture-path population grew by my two
mined rows — `plans/round-68-c1.sh` derives `verified`/`col15` by counting exactly such rows.
This is structural, not a mistake in my rows, and I did not fix it: `corpus/claim-ledger.tsv`
is outside my write scope (one writer per file; my item allows only a justified `used-by`
edit). Routed to `R69ExecLedger`, which re-ran both directions independently, confirmed the
158→160 / 38→40 / 33→35 move, replied "outside my assigned seat", left the row untouched and
flagged it to the L1; relayed to Main, which passed it to the L1 (`KagiR69a2`). Remedy shape I
gave, for an owning seat to apply: `old_expect ^C1_VERIFIED: verified=38 col15=33 caught=6/6
guard=1$` → `new_expect ^C1_VERIFIED: verified=40 col15=35 caught=6/6 guard=1$`, journaled in
`.ufo/waves/round-69/journals/expectation-migrations.json` with motive "registry population
158→160". The note in that row also needs the revision the 38/33 holds at, per QM60.

Pre-existing BASE reds I measured so nobody chases them: `R21-02`, `R31-02`, `R33-02`,
`R34-03` each pin `rows=114 …` while BASE already prints `rows=158` — red before this round's
population move, unrelated to S168/S169.

## 5. Deviations from my brief — both deliberate, both measured

**(a) S169's recheck cell is `180d`, not `on-release`.** With `on-release` the release clock
reads a red line, because `corpus/release-clock.py` requires every registry row whose recheck is
`on-release` to be bound in `corpus/release-clocks.tsv` *and* to have an observation record in
the retained receipt. Measured:

```
S169 recheck=on-release, no release-clocks.tsv row:
  UNBOUND S169
  RELEASE_CLOCK: FAILED (on_release=33 bound=32 unbound=1 observed=32 fired=14 derived=17)   EXIT=1
S169 with a release-clocks.tsv row but no receipt record:
  INCONSISTENT S169 / NOT OBSERVED S169
  RELEASE_CLOCK: FAILED (on_release=33 bound=33 unbound=0 observed=32 …)                     EXIT=1
S169 recheck=180d (as landed):
  RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)    EXIT=0
```

Neither `corpus/release-clocks.tsv` nor `corpus/release-clock.py` is in my write scope and no
seat owns them this wave, so `on-release` would have landed a red ledger row (R36-03) behind it.
`corpus/QUALITY.md` QM63 and QM73 state the rule I applied: "an `on-release` row needs a bound
release clock in the same commit, otherwise its cadence is a dated `NNd`". The lane's own
rejected rows use dated cadences too (S149/S150/S153/S154 the opened date, S156 `2026-11-15`,
S132/S133/S134 `180d`). Main replied: keep `180d` unless the L1 (`KagiR69a2`) says otherwise. If
the L1 wants `on-release`, the green recipe is a
`S169<TAB>rendered-quote<TAB>-<TAB>-<TAB>-<TAB>-<TAB>2026-11-08<TAB>quote-located<TAB>note` row
in `corpus/release-clocks.tsv` plus an S169 record in the receipt, after which R36-03's
`on_release=32` becomes `33` and needs its own journaled migration.

**(b) S169's `kind` is `docs`, as my item specified, where the lane's two existing Wikipedia
rows (S133, S149) are `community`.** The scout recommended `community`/C. No gate distinguishes
them — the census accepts both in the `kind` enum and E10 only forbids `community` at tier A
(S169 is tier C) — so I kept my item's value rather than silently reclassify, and flag one cell
for the L1 to flip if the precedent is preferred.

**(c) S168's anchor names §2.1.4, not the plan's "§2.1 / §2.1.1".** Measured: `grep -ci append`
over body lines 310–363 (§2.1 Merkle Trees and §2.1.1 Definition of the Merkle Tree) is **0**.
The property sentence is in §2.1.4 (line 475); §1 carries the superset framing. My anchor cell
names §2.1.4 as the located section and keeps §2.1/§2.1.1 as the tree the proof is over, so the
plan's scope wording is preserved without pointing a reader at a section that does not carry the
rule. The scout reached the same correction independently.

## 6. Findings for the record

- **The used-by cell creates a hard ordering dependency across seats.** A `mined` row's used-by
  path must exist on disk, so the registry scribe cannot deliver a CLEAN census before the
  knowledge-entry scribe lands the entry. Two seats land in the same wave and the census gate is
  only green after both — I could not, within my write scope, make the lane gate read CLEAN on my
  own, and the wave's settlement order decides when a gate can be quoted at all. Worth naming
  because round 68's defect list and this round's C1 legs both assume a gate reading is a
  property of the tree, not of the wave's clock.
- **Two `mined` capture-path rows move a frozen ledger count by +2 each.** Any future round that
  grows the pure-capture-path population re-reds R68-01 unless the row is migrated or bound to a
  revision. The lane's own rule (QM60) requires a current-readings line naming the revision for a
  drifted reading; the journaled old/new pair is the form used this round for R68-02.
- **The scout and I independently agree the plan's §2.1/§2.1.1 pointer is wrong** for the
  append-only sentence (§2.1.4 carries it). The plan is frozen, so the correction lands in the
  row's anchor and in this report rather than in the plan.
- **The Wikipedia revision permalink serves a different body** than `/wiki/Merkle_tree`
  (213195 B vs 209875 B, different sha256). My row pins the `/wiki/` body and records the
  `oldid` as the page revision only, never as a second capture — so the digest and the revision
  label cannot be read as interchangeable (QM88's class).
- **No credential material.** I commit only capture bodies, no headers file; S169's body carries
  MediaWiki's anonymous-user placeholder token field, byte-identical in form to the
  already-committed `S149.body`, never a cookie or session value (QM72).

## 7. Receipts (under `.ufo/waves/round-69/w1/R69ScribeEntry/`)

| file | contents |
|---|---|
| `fetch-168.txt` | S168 URL, UA, HTTP 200, final URL, 128266 B, sha256, byte-identical refetch, curl version, quote section/line/offset, locate count=1, normalized digest, and the §2.1/§2.1.1 zero-`append` measurement |
| `fetch-169.txt` | same for S169, plus `oldid`, the reject measurement (0 occurrences of the five tokens), the permalink caution, and the cookie note |
| `census.txt` | the terminal lane-census and fleet-wrapper verdicts with exit codes, the release-clock line, the blocked-window reading kept as history, the scratch-with-stub CLEAN proof, and the BASE comparison |
| `selftest.txt` | `SOURCES_CENSUS_SELFTEST: PASS (98 cases)` EXIT=0 |
| `rows.txt` | the two registry rows and two fetch rows byte-exact as landed, plus the derived shape checks (NF=13, NF=16, no CR, quote identity) |
| `r68-01-population-move.txt` | the R68-01 count move measured with and without my rows, the BASE census, the remedy shape, and the pre-existing `rows=114` reds |

Scratch (`${HYAKU_SCRATCH}/kagi-r69/R69ScribeEntry/`) was deleted before this report was
finalised; every number above is reproducible from the receipts and the commands recorded in
them.

Tooling: none installed or upgraded by this seat; `curl 8.23.0` and the lane's own
`python3 corpus/rendered-text-v1.py` did the work. No pacman transaction was run (pacman is
paused host-wide).
