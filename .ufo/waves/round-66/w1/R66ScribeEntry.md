# R66ScribeEntry — the carrier-binding knowledge entry and its QUALITY rows (round 66, kagi)

Seat: `R66ScribeEntry` (scribe; axes depth, freshness). Lane `kagi-shokunin`
(branch master). Claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8` (round-65 verifier spot-check tip).
Frozen plan `plans/round-66.md` (landed `ddcd46bb`, read with
`corpus/lessons/round-65.md` and `corpus/lessons/round-66.md`).

Scope: the round's knowledge entry `corpus/knowledge/claim-instrument-carrier-binding.md`
and the `corpus/QUALITY.md` append-only rows. **Read-only on lane source**
except those two files. Receipts copied first into
`.ufo/waves/round-66/w1/R66ScribeEntry/`. Scratch
`/fast/scratch/hyaku/kagi-r66/R66ScribeEntry`, `TMPDIR` exported explicitly,
removed on exit. No git/jj mutation, no commit, no push.

## Verdict summary

| # | Assigned check | Verdict | Confidence |
|---|---|---|---|
| 1 | Knowledge entry drafted (capture-path↔registry-row binding rule, digest pin over a committed capture, wrong-id drift class, bounds, falsifiers, citing S148) | **LANDED** — `corpus/knowledge/claim-instrument-carrier-binding.md` committed at `967afd4`, `cites:`/`used-by`/`stamps.tsv` wired, `Reverify: R21-03`, `DOC_AUDIT: CLEAN` | high |
| 2 | QUALITY rows QM89/QM90 (if their lessons ground them) | **NOT MINE — ids taken, and the two classes my lessons ground are stated by no row.** QM89–QM94 landed by the L1 in `f2d5868`; QM89 states the M66-7 class, QM90 the M66-8/M66-9 class. M66-1 and M66-2 are uncovered — §5 | high |
| 3 | C1 carrier drift 0→1 (S148 capture-path bound by digest) | **CONFIRMED and independently re-derived** from the landed artifacts — §3 | high |
| 4 | Entry's own numbers audited against the landed tree | **THREE DEFECTS FOUND** in the landed entry (§2): the anchor-cell exception population (1 stated, 2 measured), the counter's coverage of the drift class (2 of 11 stated, 3 measured), and the "git diff is empty" claim on the S148 row (not empty — the `used-by` cell changed) | high |
| 5 | Lane census / docs audit at HEAD | **CLEAN** at `d1e127a`: `SOURCES_CENSUS: CLEAN (rows=156 …)`, `DOC_AUDIT: CLEAN (entries=47 row_linked=44 …)` | high |

## 1 — What landed

**`corpus/knowledge/claim-instrument-carrier-binding.md`** (196 lines), added in
`967afd4` "round-66: carrier-binding entry wired (cites/used-by/stamps),
class-matrix Reverify+stamp, M66-14, final gate receipts". Its header, as
committed:

```
cites: S164, S143, S145, S113 — the row that supersedes S148 and names the
       carrier capture path; the row whose own id the carrier file's name
       borrows; the handle family S145–S152 named as a class; and the row
       whose anchor cites a rejections body from its own capture directory.
source: `corpus/SOURCES.md` S148 (ConText / NCBI BioC XML deposit for
       PMC2757457, re-opened 2026-11-08; the row that carries the pin
       `3b8d4e15…cba40` while naming no capture path at all) and the lane's
       own executed counter `plans/round-66-c1.sh` with its carrier reader
       `corpus/volatile-shape.py`.
verified-at: `round-66` (2026-11-08), claim BASE `d549ee6…`
recheck: 180d — re-run `bash plans/round-66-c1.sh --tree . --base-tree
       <extraction of d549ee6>` (expect `C1_CARRIER: drift=1 paths=3 hex=3
       match=1 guard=1`), `python3 -I -B corpus/volatile-shape.py` …
Reverify: R21-03
```

The `cites:`/`used-by`/`stamps.tsv` wiring is complete and the entry passes
both gates that read it:

```
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=156 A=139 B=2 C=15 queued=3 mined=136 rejected=17
  entries_sourced=26 legacy=21 captures=156 inrow=16 inrow_only=0
  inrow_nonreproducing=12)
$ bash corpus/claim-ledger.sh docs
DOC_AUDIT: CLEAN (entries=47 row_linked=44 by_hand=3 undeclared=0
  missing_ids=0 unpinned=0 duplicate_reasons=0)
$ grep -F 'claim-instrument-carrier-binding.md' corpus/stamps.tsv
corpus/knowledge/claim-instrument-carrier-binding.md
  d29258309adc9a81482e1088b29d5db3c185f8d798d9e2116f7489b2088122d9  196  10995
```

The stamp's digest equals the file's live sha256 — the entry is pinned, not
merely present.

**The entry's substance**, re-derived independently on the landed tree
(not read back from the entry):

- **The binding rule.** A registry row binds a carrier by *path equality plus
  digest equality*, never by filename. Three surfaces must resolve to one
  path *P* whose sha256 is the row's pin: the registry anchor cell, the fetch
  ledger's column 16 (with col 10 = pin, col 11 = byte count), and the
  instrument's `DEFAULT_CAPTURE`. Measured:
  `S164` anchor cell → `.ufo/waves/round-64/capture/S143.body`; `S164` fetch
  col16 → the same path; col10 = `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`;
  col11 = 264946; `corpus/volatile-shape.py` `DEFAULT_CAPTURE` → the same
  path; `sha256sum` of that path = the pin. The counter `plans/round-66-c1.sh`
  reads `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` on the candidate
  and `drift=0` with `registry:no-row-carries-pin-with-path;fetches:no-row`
  on a BASE extraction — i.e. **at BASE no row carried the pin *and* named a
  path**. The defect was in the binding, never in the bytes: the pin was
  always right.
- **The digest pin is over committed bytes.** The carrier is the committed
  capture; the live endpoint is re-opened only to be reported. The served body
  stamps its own request date into itself, so the live byte string differs by
  one byte from the committed one on a different day, and the endpoint
  answered HTTP 429 (899 B, sha256 `037c2dbe…`) on the same date it answered
  200 (264946 B, sha256 `3b8d4e15…`, byte-identical to the pin).
- **The wrong-id drift class is a population, not one file.** A filename is a
  *handle*, not an identity — the round-64 capture notes say so outright
  ("**Capture handle ≠ registry id.** … the L1 owns the ids and may
  renumber", `.ufo/waves/round-64/capture/notes.md:21`).
- **The census never opens a capture body.** At the round-66 commit
  (`d1e127a`), `corpus/sources-census.sh` has exactly **five** `sha256sum`
  call sites — line 282 (the row-identity digest) and the four selftest
  fixtures at 451–454 — and **none** of them hashes a file named in column 16
  or in an anchor cell; `grep -c 'capture-digest-mismatch\|cap_row'` on the
  committed script ⇒ **0**. So at BASE and at the round-66 close,
  `SOURCES_CENSUS: CLEAN` was evidence that the registry's *cells* are shaped
  correctly, never that any row binds a carrier.

  **Scope note (this is a round-67 development, not a round-66 defect).** The
  *working tree* census is now a different instrument: round 67 added
  `SC_CAPTURE`, which reads the bytes at each declared capture location and
  checks them (`SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36
  prose=120)`; the two extra `sha256sum` sites are at lines 275 and 745). The
  committed census at `d1e127a` — the tree this round's claims were measured
  on — has neither. So the blindness this entry measured is a property of the
  **committed** round-66 gate, and round 67 is closing it. The counter
  `plans/round-66-c1.sh` remains the instrument that binds *one* carrier by
  path+digest (`drift=1 paths=3 hex=3 match=1 guard=1`), which is a different
  obligation from the census reading *every* declared location.
- **The same filename can mean two bodies.** `round-63/capture/S143.body`
  (`8522a79e…`) and `round-64/capture/S143.body` (`3b8d4e15…`) differ by
  exactly one byte — `cmp -l` reports offset 128, `67`→`70` octal — the
  service's own `<date>` stamp. Only the digest identifies bytes.

## 2 — Audit of the entry's own numbers against the landed tree

I re-measured every population the entry states. Three of its figures do not
reproduce. **Scope matters here**: the entry's figures are over *committed*
`.body` captures in wave capture directories (waves ≤ 66 = 96 files). My first
re-measurement walked `.ufo/waves/round-*/capture/` including round 67 and
therefore counted 97 files and 22 unpinned ones — **that was my error, not
the entry's**; the entry's "21" is correct for the committed scope, and I
withdraw the discrepancy I initially suspected. The three defects below
survive the corrected scope.

Reproducing command (all three defects), scoped to committed waves ≤ 66:

```
python3 - <<'PY'
import re,hashlib,os,glob
rows=set(re.findall(r'^\| (S\d+) \|', open('corpus/SOURCES.md').read(), re.M))
pins={}
for line in open('corpus/source-fetches.tsv'):
    f=line.rstrip('\n').split('\t')
    if len(f)>15 and f[0] and re.match(r'^S\d+$',f[0]):
        pins.setdefault(f[0],set()).add(f[9])
def sha(p):
    h=hashlib.sha256()
    with open(p,'rb') as fh:
        for b in iter(lambda: fh.read(1<<20), b''): h.update(b)
    return h.hexdigest()
files=[]
for wave in sorted(glob.glob('.ufo/waves/round-*')):
    if int(re.search(r'round-(\d+)',wave).group(1))>66: continue
    cap=os.path.join(wave,'capture')
    if os.path.isdir(cap):
        for fn in sorted(os.listdir(cap)):
            if fn.endswith('.body'): files.append(os.path.join(cap,fn))
# … for each file: owners = rows whose fetch-row col10 == sha256(file);
#    stem = leading S### of the filename; classify against `rows` …
PY
```

### Defect A — the anchor-cell exception population is 2, not 1

The entry §3 states: *"22 registry rows cite a capture `.body` path in the
anchor cell; **21** of the cited files hash to the citing row's own pin, and
**1** does not — `S113`"*. Measured on the landed tree:

```
HEAD d1e127a: rows=22  citations=23  hash-equal-to-own-pin=21  exceptions=2
   S113 -> .ufo/waves/round-56/capture/rejections/S113-default-ua.body  (ce3cb7f2…, 5448 B)
   S121 -> .ufo/waves/round-58/capture/S121.body                        (37e706c2…, 32638 B)
BASE d549ee6: rows=21  citations=22  hash-equal=20  exceptions=2  (the same two rows)
```

The row count 22 is right; the citation count is **23**, not 22 (S121 cites
two `.body` paths), and there are **two** exceptions, not one. The second is
`S121`, whose anchor deliberately co-cites the rejected token-CLI staging
page: *"the round-58 staging file of the same id,
`.ufo/waves/round-58/capture/S121.body`, is the rejected token-CLI page and
not this source"* — a body whose sha256 `37e706c2…` is not the row's pin
`d8879a2a…` (which is the round-59 body the row does name).

Both exceptions are the same shape: a **deliberate co-citation of a rejected
body**, and the registry says so in its own words — S113's anchor: *"the
default user agent receives HTTP 403 — probed on this URL 2026-11-07, receipt
`.ufo/waves/round-56/capture/rejections/S113-default-ua.body`, HTTP 403,
5448 B"*. This strengthens rather than weakens the entry's argument: the
deliberate co-citations are exactly the shape a naive digest rule would
mis-flag, so the binding rule must be stated over *the carrier path*, never
over every path a cell mentions — which the entry's Bounds paragraph already
says. The fix is to make §3's count agree with it.
(`R66ScoutPreState` §3 independently reports the same two exceptions and
notes that a whole-registry "cited path sha == row pin" rule reads
`failures >= 2` at BASE regardless of the S148 repair.)

### Defect B — the counter covers three of the eleven drift files, not two

The entry §2 states: *"Two of the eleven are the ones the counter exercises as
wrong-id bodies."* The counter's wrong-id set is three paths
(`plans/round-66-c1.sh:94`):

```
WRONG_PATHS = [".ufo/waves/round-64/capture/S148.body",
               ".ufo/waves/round-64/capture/S156.body",
               ".ufo/waves/round-64/capture/S157.body"]
```

All three are inside the eleven, and the classification (owner = the registry
row whose fetch-row pin equals the file's sha256) confirms it per file:
`S148.body` → pinned by `S152`; `S156.body` → pinned by `S151`; `S157.body` →
pinned by `S153`. Measured round-64 partition (20 files): 1 name==owner,
10 name-is-a-row-pinned-by-another, 1 name-is-no-row-pinned-by-another
(`S157.body`), 8 pinned by no row. So the eleven = 10 + 1, and **three** of
them are the counter's wrong-id bodies, not two. This understates the
counter's reach over the class it was built for.

### Defect C — "git diff of that row … is empty" is not empty

The entry §4 states: *"`S148`'s row text is preserved **verbatim** — `git
diff` of that row between `8abab0f` and the candidate tree is empty."* The
diff is **not** empty:

```
$ diff <(git show 8abab0f:corpus/SOURCES.md | grep '^| S148 ') \
       <(grep '^| S148 ' corpus/SOURCES.md)
1c1   (1025 B -> 1130 B)
```

Field-by-field, the only changed cell is the **`used-by`** cell — fields
`id`…`recheck` (source, kind, tier, scope, anchor, teaches, status, opened,
recheck) are byte-identical, and BASE→HEAD differs only in `used-by` too
(`corpus/lessons/round-64.md` → `… , corpus/knowledge/claim-instrument-class-matrix.md,
corpus/knowledge/claim-instrument-carrier-binding.md`). So the entry's
*substance* holds — the carrier content of S148's row was not rewritten, and
the repair is the new row `S164` — but the stated command output is false as
written. The correct statement is: the row's carrier content is preserved
verbatim and only its `used-by` cell grew, because the census requires every
citing entry to be listed there.

None of the three defects changes a claim, a verdict, or a count the entry's
argument rests on: the drift class remains a population of the same order,
the census blindness is unaffected, the binding rule and its falsifiers are
unaffected. They are the kind of number and command-output a downstream
reader will copy, so they should be corrected.

### What reproduces exactly

- §2's four-class table over the 96 committed captures: 64 / 10 / 1 / 21 —
  reproduces exactly, and agrees with the committed receipt
  `.ufo/waves/round-66/w1/R66ScribeEntry/drift-class-taxonomy.txt`
  (A-exact 64, C-borrowed-identity-other-row 10, E-name-prefix-not-a-row 1,
  F-bytes-pinned-by-no-row 21).
- §2's round-64 breakdown "1 … 11 … 8" (of 20) — reproduces exactly
  (1 + 10 + 1 + 8). One phrasing nit: the eleven are "files whose pin
  belongs to a row other than the one their name denotes"; only **ten** of
  them *name* another registry row's id — `S157.body` names no row at all
  (`S157` is not a registry row) while carrying `S153`'s pin. The lesson's own
  wording is the accurate one: "11 of 20 round-64 files carry another row's
  pin" (`corpus/lessons/round-66.md` §Routed dispositions, `D-66-1`).
- §2's "12 across the lane's capture directories" — reproducible, but only
  under a definition the entry does not state. Lane-wide, files whose bytes
  are claimed by a row other than the one their filename names = 15
  (10 + 1 + 4 co-pinned files); excluding the three files that share the
  single `S130`/`S135`/`S155` body, it is **12**. Under the entry's own
  four-class table the lane-wide figure is 11 (all of them inside round 64).
  A number that needs a definition to be read is a QM6-class observation, not
  a wrong number.
- §3's "33 fetch rows name a capture `.body` path in column 16; all 33 files
  hash to their own row's column-10 digest" — reproduces exactly (33 rows,
  33 equal, 0 mismatch; 30/30 at BASE). Note the 33 is the count of `.body`
  locations; the committed census at `d1e127a` does not read them, so this
  was a measurement of the *files*, not a gate reading (round 67's
  `SC_CAPTURE` now reads them: `path_rows=36` — the 33 `.body` locations
  plus three `.raw` locations (S100–S102), `bound=36 located=36 prose=120`;).

### A note on the census blindness, scoped

§1 of this report originally stated the blindness as a property of
`corpus/sources-census.sh` without naming a revision. That was loose, and
the working tree shows why: round 67 has since added `SC_CAPTURE` to the
census, which reads every declared capture location
(`SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)`,
`grep -c 'capture-digest-mismatch\|cap_row'` on the **committed**
`d1e127a` script ⇒ **0**, on the working tree ⇒ present). The blindness is
real **at the round-66 commit** — the tree C1 and C3 were measured on — and
is being closed in round 67. The entry's own §3 sentence ("the census never
opens a capture body") was written against the round-66 census and is
correct for it; a reader running the *current* script would see a different
instrument. This is the same "a number carries its command" (QM6) lesson
the entry itself teaches, applied to my own prose — the command belongs
beside the claim, and the revision belongs beside the command.

## 3 — C1, independently re-derived

The entry's §1 rests on C1. I re-derived the binding measurement from the
landed artifacts rather than quoting the receipt:

- `S164`'s anchor cell, fetch row col 16 and `corpus/volatile-shape.py`'s
  `DEFAULT_CAPTURE` all name `.ufo/waves/round-64/capture/S143.body`;
  `sha256sum` of that file = `3b8d4e15…cba40` = the row's col-10 pin, and
  its byte count 264946 = col 11.
- The landed counter receipt `.ufo/waves/round-66/final/c1-candidate.txt`
  reads `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1`, with the three
  wrong-id mutations each refused by a named
  `digest-mismatch:.ufo/waves/round-64/capture/S143.body` on all three
  surfaces, the BASE-tree leg reading
  `registry:no-row-carries-pin-with-path;fetches:no-row`, and guard (d) — a
  copy whose anchor and fetch column name the wrong file — reading `drift=0`
  with `digest-mismatch:.ufo/waves/round-64/capture/S148.body`.
- The guard-(d) wrong-path body is `.ufo/waves/round-64/capture/S148.body`,
  sha256 `fabc74c5…` — the arXiv 1909.02196 body, i.e. the very wrong-id
  file the round repaired. The falsifier is the defect.

The C1 milestone (carrier drift 0→1) is therefore measured, and the
mechanism that produces it (path+digest equality, not filename) is the
subject of the landed entry.

## 4 — QUALITY rows: QM89/QM90 were taken, and two classes are uncovered

My assignment was the `corpus/QUALITY.md` append-only rows "QM89/QM90 **if
their lessons ground them**". The conditional fails, and it fails in a way
worth recording:

- QM89 and QM90 were **already landed by the L1** in `f2d5868` ("round-66:
  integration — scorecard pre/post, claims rows, LOG, lesson (13 mistakes +
  Gate addendum), QM89-QM94"). The landed QM89 states the *counter verdict
  field computed from its legs* class and its lesson cell cites **M66-7**;
  the landed QM90 states the *mutant/guard leg runs on the state its claim
  governs* class and cites **M66-8/M66-9**. QM91 cites M66-6, QM92 cites
  M66-10, QM93 cites M66-11, QM94 cites M66-13.
- My lessons are **M66-1** ("a predicate term with no implementation surface,
  frozen") and **M66-2** ("a kill rule that defines the candidate's own
  action as the failing control"). Neither class is stated by any landed row:
  `grep -cE 'implementation surface|name an existing mechanism|kill-rule
  self|candidate.s own action' corpus/QUALITY.md` ⇒ **0**.
- The lesson's own `captured-by` lines point at the *other* ids: M66-1 says
  "New criterion QM89" and M66-2 says "New criterion QM90", while the rows
  landed under those ids state M66-7 and M66-8/9 instead. So the lesson's
  cross-references and the landed QUALITY rows disagree about which id
  carries which class.

**Consequence for the corpus:** the round-66 lesson claims QM89/QM90
"capture" M66-1 and M66-2, but the rows bearing those ids carry different
classes. As long as the ids are occupied, M66-1 and M66-2 are ungrounded.
Append-only means the fix is a **new id**, not a rewrite: the next free ids
are QM95 and QM96. I did **not** append them — `corpus/QUALITY.md` is a
lane-wide append-only file that other seats appended to in this same round
(QM92–QM94 landed in the same integration commit), and id allocation for a
closed round belongs to the L1 as sole integration owner and sole committer.
The two row texts are specified here for the L1 to land, exactly as the
lesson's own `captured-by` phrasing would require:

> **QM95** — A frozen predicate's central term names a mechanism that exists
> in the lane: a predicate asking for a resolution step no instrument
> performs is a defect of the predicate, restated in the mechanism that
> exists and measured there. *Weak signal*: `grep -rn "header-ID\|header_id"
> plans/ corpus/` matched only the plan's own line, while the lane's two real
> mechanisms are a path-keyed read plus a pin comparison
> (`corpus/volatile-shape.py`) and a row-identity digest over registry
> columns (`corpus/sources-census.sh` SC_FETCH) — neither derives an id from
> bytes. *Lesson*: `corpus/lessons/round-66.md` §Mistakes M66-1;
> `plans/round-66.md` Amendment A1.
>
> **QM96** — A kill rule's failing control is not the candidate's own
> action: a guard that refuses what the candidate must do is vacuous, and
> the falsifier is a state the candidate does not share an act with.
> *Weak signal*: §C1's K2 named a path-only edit (carrier-path string
> repointed, no bytes changed) as the control while the candidate repair is
> a path string landing on a registry row — the counter would have had to
> read the repair as its own failure. *Lesson*:
> `corpus/lessons/round-66.md` §Mistakes M66-2; `plans/round-66.md`
> Amendment A1 guard leg (d) (the wrong-path file
> `.ufo/waves/round-64/capture/S148.body`, refused with `digest-mismatch:`).

If the L1 prefers to keep the lesson's cross-references verbatim, the
alternative is to renumber the lesson's two `captured-by` pointers to the ids
that actually state M66-1 and M66-2 — but the lesson file is
`R66ScribeRecords`'s, and a QUALITY.md row cannot be renumbered once landed.
The append-a-new-id route is the only append-only-consistent one.

**This is a routed defect, not a claim failure.** The round-66 claims are
C1 (measured), C3 (measured, `C3_CENSUS: findings=0 rows=156 guard=1`), and
C2 (honest stop — `w1-results.json` absent, as recorded in the close commit
`d1e127a`: "13 of 14 seats filed; `R66ScribeEntry` did not"). The QM coverage
gap is a corpus-completeness defect in the QUALITY.md/lesson pairing, routed
to the L1 (sole integration owner) and to round 67.

## 5 — Round-67 handoff: this class is already in flight

The round-67 wave is live in this lane (`plans/round-67-c2.sh` untracked,
`.ufo/waves/round-67/` present, claim BASE `076701a1…`), and its milestone
reads *"C1_READTHROUGH bound 0->36 located 0->36 caught 0->6/6 (census reads
captures + quotes, BASE blind)"*. That is the same class this entry measures
— the census reading captures — built on the committed carrier rows. Three
things from this seat's measurement are directly usable there and are stated
above: the **two** deliberate rejected-body co-citations (S113, S121) that a
naive digest rule would mis-flag; the counter's true reach over the drift
class (**three** wrong-id bodies, not two); and the scope discipline that
makes the population count reproducible (committed waves ≤ 66 = 96 files).

The round-66 lesson already routed this population: `D-66-1` records
"borrowed-identity capture handles (11 of 20 round-64 files carry another
row's pin; both census gates blind) — routed to round 67 as a checked class,
not silently adopted". My §2 numbers agree with the lesson's 11-of-20.

## 6 — Out of scope (not touched)

- `corpus/lessons/round-66.md` — owned by `R66ScribeRecords`; not edited.
- `corpus/SOURCES.md` — owned by `R66ScribeRecords`; the `used-by` cells for
  my entry were wired by the L1 in `967afd4`; not edited by me.
- `corpus/QUALITY.md` — **appended by no one in this seat**; §4 for why the
  new ids are the L1's to allocate.
- `corpus/stamps.tsv` — L1's; my entry's stamp row landed with the entry.
- The lesson's `captured-by` cross-references (§4) — the lesson owner's.
- `plans/`, counters, claims.json, `MANIFEST.json`, `.ufo/state/`,
  `.ufo/watchdog.log`, fleet-root `scripts/` and `templates/` — not writable,
  not written.

## 7 — Receipts

| file | content |
|---|---|
| `.ufo/waves/round-66/w1/R66ScribeEntry/carrier-binding-census.txt` | the three-anchor binding measurement (registry anchor cell / fetch col 16 / instrument default) with the digests |
| `.ufo/waves/round-66/w1/R66ScribeEntry/drift-class-per-wave.txt` | the wrong-id class per wave capture directory, and the same-filename/two-bodies pair |
| `.ufo/waves/round-66/w1/R66ScribeEntry/drift-class-taxonomy.txt` | the per-file ownership table over every committed `.body` capture |
| `.ufo/waves/round-66/w1/R66ScribeEntry/authoritative-census.txt` | the scoped drift census re-measured on the landed tree (the §2 defect audit), with the per-file classification |
| `.ufo/waves/round-66/w1/R66ScribeEntry/ledger-verify-full.txt` | `bash corpus/claim-ledger.sh verify` on the candidate tree — 43 rows reached before the 900 s budget expired |
| `.ufo/waves/round-66/w1/R66ScribeEntry/citations-gate.txt` | `bash corpus/claim-ledger.sh citations` — 5186 cites, 171 docs |

Scratch (removed on exit): `/fast/scratch/hyaku/kagi-r66/R66ScribeEntry` —
holds the working copies of the six receipts above.

**The citation gate is BROKEN and does not implicate my entry.**
`CITATION_GATE: BROKEN (cites=5186 docs=171 unresolved=30 ephemeral=0
labeled=24)` — and `grep -c 'claim-instrument-carrier-binding'` over the
gate's own findings is **0**. The 30 unresolved are in `SCORECARD.md` (4),
`corpus/lessons/round-62.md` (3), the round-65/66 verifier spot-checks (4),
and older lessons — pre-existing debt, plus the round-66/67 spot-check and
lesson files that landed after this seat's wave closed. This is the same
`CITATION_GATE` / `CLAIM_LEDGER` debt the round-65 spot-check named (D-65-3)
and the round-66 lesson carried; my entry is not among the findings.

**`bash corpus/claim-ledger.sh verify`** reached 43 of the ledger's 99 rows
before the 900 s budget expired (`rc=124`): 18 FAIL, 5 POLICY, 13 HOST-SKIP,
7 STALE. Every FAIL is a stale-expectation or stale-pin row predating this
round (`R21-02`/`R31-02`/`R33-02`/`R34-03` expect `rows=114` where the
census now prints `rows=156`; `R12-03`/`R13-01` expect old pin counts), and
the 7 STALE rows are the files the L1 edited during integration
(`corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
`LOG.md`, `SCORECARD.md`, `SKILL.md`, `plans/round-61-c1-check.py`) — i.e.
the integration window, not a defect of this seat's landing. No row in this
receipt names my entry. The run is truncated, so it is a **partial**
reading, not a verdict on the other 56 rows.

### Cross-check against the round-66 verifier spot-check

`corpus/lessons/round-66-verifier-spotcheck.md` (landed 07:34, after this
seat's wave closed) independently confirms the seat accounting this report
closes: *"Witnesses: 14 seats are declared in `w1-spec.json`/
`w1/swarm-registry.json`; 13 `*.md` seat reports exist in `w1/`;
`R66ScribeEntry` has receipts but no report; `w1-results.json` is absent at
the tip"*. This report is that fourteenth file.

It also names two corpus defects that touch my landing, both already
repaired in the tree by the time I measured (§2-§5 above): the SOURCES
`used-by` old→new logging (spot-check §1.6 items 6–7) is now carried by
the lesson's appended **Corrigendum — round 66** (seven rows tabulated
old→new, including the six rows whose `used-by` gained
`corpus/knowledge/claim-instrument-carrier-binding.md`); and the coverage-map
row (spot-check §6 item 6) now exists — `corpus/README.md:119` reads
*"| Claim-instrument carrier binding: a registry row names its carrier by
path *and* digest (entry, round 66) | `corpus/knowledge/claim-instrument-carrier-binding.md` | …"*.

The spot-check did not audit my entry's own numbers; §2 of this report is
the first pass that does, and it finds three defects (D-66-3 … D-66-5).

## 8 — Routed dispositions

| id | what | state |
|---|---|---|
| D-66-3 | the landed entry's §3 states 1 anchor-cell exception where the census over the landed tree measures **2** (S113, S121 — both deliberate rejected-body co-citations), and **23** citations across 22 rows, not 22 | **routed to the L1** (sole integration owner, sole committer) — §2 gives the reproducing command and the corrected numbers; the entry's own Bounds paragraph already states the rule that makes both co-citations legitimate, so only the counts need to agree with it |
| D-66-4 | the landed entry's §2 says "two of the eleven" are the counter's wrong-id bodies; the counter's `WRONG_PATHS` has **three** (`S148.body`, `S156.body`, `S157.body`), all three inside the eleven | **routed to the L1** — same file, same correcting commit; the counter's own reach over the class is understated |
| D-66-5 | the landed entry's §4 says "git diff of that row between `8abab0f` and the candidate tree is empty"; it is **not** empty — the `used-by` cell grew by the two citing entries (all other fields byte-identical) | **routed to the L1** — the substance (carrier content preserved; repair is the new row `S164`) holds, but a stated command output is false as written and a reader would copy it |
| D-66-6 | the round-66 lesson's M66-1/M66-2 `captured-by` pointers name QM89/QM90, but those ids carry the M66-7 and M66-8/9 classes; M66-1 and M66-2 are stated by **no** QUALITY.md row (`grep -c` ⇒ 0) | **routed to the L1** — append-only fix is QM95/QM96; both row texts are specified verbatim in §4 for the L1 to land |

## 9 — Gate result

The round's knowledge entry is landed, wired and green on both gates that
read it (`SOURCES_CENSUS: CLEAN`, `DOC_AUDIT: CLEAN`, stamp digest matching
the file), and the citation gate does not name it among its 30 unresolved
findings. C1 is measured and independently re-derived (§3); C3 is measured
(`C3_CENSUS: findings=0 rows=156 guard=1`). C2 is an honest stop recorded
by the L1 (`w1-results.json` absent — this seat's report is the missing 14th
file, and it is this report).

Four corpus-completeness defects (D-66-3 … D-66-6) are routed to the L1 with
reproducing commands, the exact corrected numbers, and — for D-66-6 — the
exact row text to land. Three of them are in the file this seat drafted; the
fourth is the QUALITY.md/lesson pairing that leaves M66-1 and M66-2
ungrounded.

Nothing in this seat's scope was left undone: the entry is landed and
audited, the receipts are filed, the gate readings are recorded, and the
remaining work is the L1's integration call on four routed items — no
commit, no push, no product-code edit was made by this seat.
