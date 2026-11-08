# Claim instrument: the carrier binding — a registry row names its carrier by path *and* digest

cites: S164, S143, S145, S113 — the row that supersedes S148 and names the carrier capture path; the row whose own id the carrier file's name borrows; the handle family S145–S152 named as a class; and the row whose anchor cites a rejections body from its own capture directory.
source: `corpus/SOURCES.md` S148 (ConText / NCBI BioC XML deposit for PMC2757457, re-opened 2026-11-08; the row that carries the pin `3b8d4e15…cba40` while naming no capture path at all) and the lane's own executed counter `plans/round-66-c1.sh` with its carrier reader `corpus/volatile-shape.py`.
verified-at: `round-66` (2026-11-08), claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`; every count below is printed by the command shown beside it, receipts under `.ufo/waves/round-66/w1/R66ScribeEntry/`.
recheck: 180d — re-run `bash plans/round-66-c1.sh --tree . --base-tree <extraction of d549ee6>` (expect `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1`), `python3 -I -B corpus/volatile-shape.py` (expect `VOLATILE_SHAPE: match=1 passages=182 texts=180 date=20261108`) and `bash corpus/sources-census.sh` (expect `SOURCES_CENSUS: CLEAN`); §Bounds names what none of these proves.
Reverify: R21-03

## What this entry settles

The lane had one carrier — the BioC XML deposit for PMC2757457 — and one
rule about how a registry row may point at it. The rule was implicit and
partly wrong, and the wrongness was invisible to every gate the lane
already had. This entry states the rule, the population the wrongness
covers, and the checks that would have caught it.

### 1. The binding rule: one path, three anchors, digest equality

A registry row binds a carrier by **path equality plus digest equality**,
never by filename. Three surfaces must resolve to **one** path *P*, and the
sha256 of the bytes at *P* must equal the pin the row carries:

1. the **registry** anchor cell — the capture path the row cites;
2. the **fetch ledger** — `corpus/source-fetches.tsv`, column 16 naming
   that same path, with column 10 equal to the pin and column 11 equal to
   the byte count;
3. the **instrument** that reads the carrier — `corpus/volatile-shape.py`'s
   `DEFAULT_CAPTURE`.

Measured on the candidate tree (2026-11-08):

```
registry : S164 anchor cell  -> .ufo/waves/round-64/capture/S143.body
fetches  : S164 col16 = .ufo/waves/round-64/capture/S143.body
           S164 col10 = 3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
           S164 col11 = 264946
volatile : corpus/volatile-shape.py DEFAULT_CAPTURE = ".ufo/waves/round-64/capture/S143.body"
sha256sum .ufo/waves/round-64/capture/S143.body
           3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
```

All three resolve to one path whose digest **is** the pin, and the pin is
the row's own. The counter that measures it (`plans/round-66-c1.sh`,
frozen predicate `plans/round-66.md` §C1 as amended by Amendment A1)
reads, on the candidate tree:

```
C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1
```

and on a byte-identical BASE extraction of `d549ee6` it reads drift 0 with
a named diagnosis — `registry:no-row-carries-pin-with-path; fetches:no-row`
— because at BASE no row carried the pin *and* named a path. That is the
defect this entry is about, and it is a defect in the **binding**, not in
the bytes: the pin was always right.

### 2. The filename is a handle, not an identity — and the class is a population

Round 64's capture directory names its files `S145…S163`. Those names are
the *fetch handles* of that round's own seat, not registry ids; the
round-64 capture notes say so in their own words: "**Capture handle ≠
registry id.** The capture file names below (`S145…S163`) are *handles for
this seat's fetch ledger*, not registry row ids … the L1 owns the ids and
may renumber."

So the drift class is not one unlucky file. Measured over every committed
`.body` capture under `.ufo/waves/*/capture/` (96 files, command and
per-file table in `.ufo/waves/round-66/w1/R66ScribeEntry/drift-class-taxonomy.txt`):

| class | count | meaning |
|---|---|---|
| name == the id of the row that owns the bytes | 64 | the naming coincidence holds |
| name is **another registry row's** id | 10 | the wrong-id class proper |
| name's id-prefix is **not a registry row** | 1 | a handle with no row at all |
| bytes pinned by **no** registry row | 21 | a capture nothing cites |

Inside round 64's directory alone — the one the defect was found in — 20
`.body` files: **1** names the row that owns its bytes, **11** name a
different row's id, and **8** are pinned by no row at all.

The lane's existing criterion on this (QM88) states the rule for one
file: a capture named after a draft id the registry later renumbered is a
reference defect, and a rename is not a repair. The measurement above
shows the rule has a **population** (11 files in one directory, 12 across
the lane's capture directories) that no gate enumerates. Two of the
eleven are the ones the counter exercises as wrong-id bodies.

### 3. Why the lane's own gates never saw it

`corpus/sources-census.sh` validates the registry's *cells* — row shape,
enums, the used-by links, the fetch row's identity digest, the quote, the
normalization. It never opens a capture body: all five of its
`sha256sum` call sites hash the **row-identity line** (`id<TAB>status<TAB>url`)
or a selftest fixture, and none hashes a file named in column 16 or in an
anchor cell. Measured consequences on the candidate tree:

* 22 registry rows cite a capture `.body` path in the anchor cell; **21** of
  the cited files hash to the citing row's own pin, and **1** does not —
  `S113`, whose anchor deliberately cites a *rejections* body
  (`.ufo/waves/round-56/capture/rejections/S113-default-ua.body`,
  sha256 `ce3cb7f2…`, 5448 B, the HTTP 403 body) beside the row's real
  pin. The census reads this as clean.
* 33 fetch rows name a capture `.body` path in column 16; all 33 files hash
  to their own row's column-10 digest, because column 10 and column 16 are
  written together.

So the census's `SOURCES_CENSUS: CLEAN` is **not** evidence that any row
binds a carrier. It is evidence that the registry's cells are shaped
correctly. The binding was checkable and unchecked, which is why the
round-66 repair had to add a counter rather than a rule.

### 4. The repair that landed, and what it did not touch

The correction is a **binding** change, never a rename, and never an edit
to the superseded row:

* `S148`'s row text is preserved **verbatim** — `git diff` of that row
  between `8abab0f` and the candidate tree is empty.
* `S164` ("supersedes S148 … carrier capture named") adds the missing
  half: the anchor cell now names the carrier capture and its digest, and
  `corpus/source-fetches.tsv` gains S164's row with column 16 naming the
  same path, column 10 the pin, column 11 the byte count.
* The **bytes** were never moved: the carrier is still
  `.ufo/waves/round-64/capture/S143.body`.

One measured caution about the same filename meaning two bodies: the
round-63 and round-64 directories both hold a file called `S143.body`, and
the two are **not** the same body — sha256 `8522a79e…` (2026-11-07) versus
`3b8d4e15…` (2026-11-08), differing in exactly one byte, `cmp -l` offset
128, `67`→`70` octal, i.e. the service's own `<date>` stamp. A filename
plus a directory does not identify bytes; only the digest does.

### 5. The committed capture is the carrier; the live endpoint is reported, never decisive

The deposit stamps the request date into its own body, so the live body
is a different byte string on a different day (the one-byte drift above).
The carrier is therefore the **committed** capture, and the live endpoint
is re-opened only to be reported:

* re-opened 2026-11-08 with a desktop browser user agent: HTTP 200,
  264946 B, sha256 `3b8d4e15…cba40` — byte-identical to the pin
  (`.ufo/waves/round-66/capture/S148.body`);
* on the same date the same carrier answered HTTP 429 (899 B, sha256
  `037c2dbe…`) — the window fact, and the reason the committed capture
  is the carrier. A later 200 does not refute the 429; it clears the
  flip condition.

The shape check remains the live-body instrument: `VOLATILE_SHAPE: match=1
passages=182 texts=180 date=20261108` on the candidate tree.

## Bounds (what none of this establishes)

* The digest binding proves the row reads the bytes it pins. It does not
  prove the live endpoint still serves them, and it does not judge
  whether the anchor's prose is the best citation of the body.
* The census reading `SOURCES_CENSUS: CLEAN` proves nothing about
  carriers (measured above): the lane gate never hashes a capture body.
  Only the counter's `drift` field is a binding measurement.
* The drift-class census is a **snapshot of committed bytes at one
  revision**. It counts names against pins as they stand on 2026-11-08; a
  later renumbering moves the population, and a lane that renumbers
  without re-measuring loses the count.
* The carrier's body is not its content: 182 passages / 180 texts and a
  one-byte date stamp are a shape, not a claim about what the deposit
  says. The registry row's `teaches` cell carries that claim, and the
  census checks that the quote exists in the row — not that the deposit
  still says it.
* A path may legitimately cite a body that is *not* the row's pin (the
  `S113` rejections capture). The rule is about the carrier anchor, not
  about every path a cell mentions.

## Falsifiers

1. A tree whose registry anchor names a path whose sha256 is not the
   row's pin must read `drift=0` with a named `digest-mismatch:` for that
   path — measured on the guard-(d) copy: `drift=0`, diag naming
   `.ufo/waves/round-64/capture/S148.body`.
2. A tree whose three anchors resolve to three different paths must read
   `drift=0` (paths ≠ 1).
3. Each of the three wrong-id bodies written at the resolved carrier
   path must be refused with a named mismatch — measured: `paths=3 hex=3
   refused=3`, every mutation naming the path it refused.
4. A tree whose carrier bytes are replaced by a *different* body of the
   same length must read `drift=0`; byte count is not identity.
5. A BASE tree must read `drift=0` and never SETUP: measured
   `registry:no-row-carries-pin-with-path; fetches:no-row`.
6. A copy whose carrier is renamed (bytes untouched) must still read
   `drift=1` — the binding is the digest, so a rename is invisible to it,
   which is exactly why the wrong-id class needs its own population
   measurement.
7. A registry row that cites this entry without listing it in the row's
   used-by must be read as `SC_ENTRY_CITE` by the census: this entry's
   ids (S148, S164, S143) must each list
   `corpus/knowledge/claim-instrument-carrier-binding.md` in its used-by
   cell, or the lane census goes red on the entry that documents the
   binding.
