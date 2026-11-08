# R67ScribeEntry — seat report (round 67, wave 1, kagi)

**Seat**: R67ScribeEntry (scribe). **Scope**: the sourced claim's knowledge entry
`corpus/knowledge/source-capture-binding.md` and the drafting of the two registry
artifacts for S166 (the `corpus/SOURCES.md` row and the `corpus/source-fetches.tsv`
row).

**Status of my deliverable**: the L1 landed the entry and both S166 rows itself,
mid-wave, and asked this seat to review the landed files instead of writing them.
**This seat therefore edited no lane file and committed nothing.** The two
registry artifacts this seat was asked to draft are reported below as *drafted vs
landed* (a diff, no edits), together with the checks the L1 asked for. Everything
here is a review of the landed tree, and every number carries the command that
produced it. Receipts: `.ufo/waves/round-67/w1/R67ScribeEntry/`
(`README.txt`, `population.txt`, `s166-capture.txt`, `falsifiers.txt`).

---

## 1. Did I open RFC 9530, and did I make the capture?

**I opened RFC 9530; I did not make the capture — I found it.**

- The capture `.ufo/waves/round-67/capture/S166.body` already existed when this
  seat opened its work (mtime 2026-11-08 07:42, still untracked at that point;
  the L1 committed it). This seat never fetched anything from the network and
  never wrote to that file.
- I read the capture's bytes directly and measured them
  (receipt `s166-capture.txt`):

  ```
  sha256  544dbb7d9afceafa8c993dd9924ca6cff2b4807274166d7ed2483342ef2cdd6a
  bytes   67152
  rendered-text-v1 digest  normalized_sha256=652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b
                            normalized_bytes=58365
  ```

- I opened the RFC's §1.2 and §§2–3 in that capture to ground the entry's
  two-digest-layer argument, and I read the whole of §1.2 (lines 163–215).
  The mandated quote locates **count=1** under `rendered-text-v1`
  (`RENDERED_TEXT_V1_LOCATE: count=1`, rc=0) — the round's requirement.

- **The capture has no fetch receipt beside it.** Every other round's capture
  directory I checked keeps a `.meta`/headers sibling; `round-67/capture/` holds
  only `S166.body`. The S166 row's anchor cell asserts "opened live 2026-11-08
  with a browser user agent (HTTP 200, 67152 B, same sha256)". The bytes are
  verifiable (sha256 + size + locate all reproduce); **the "HTTP 200 / browser
  user agent" half of that sentence has no committed receipt in the tree**, so it
  rests on the L1's word. Not a claim I can close from the tree. See finding 1.

## 2. My drafted registry artifacts vs the landed rows

I drafted both rows from the seat brief (which specified the S166 URL, HTTP
status, profile, fetch date, representation, `revision -`, the quote, the
normalization, the normalized digest and the location), with the digest and byte
count measured by me from the capture. **Two fields in my draft differ from the
landed row, and in both cases the landed value is the correct one** — my draft
followed the seat brief literally, and the brief's values are wrong for this
capture.

### (a) `corpus/source-fetches.tsv` — S166 row (16 columns)

Landed row, verbatim (tab-separated):

```
S166	mined	8b120c456013d67fa77b40f71c506927e21b823adef69b6d29deb521e2f8eb2b	https://www.rfc-editor.org/rfc/rfc9530.txt	https://www.rfc-editor.org/rfc/rfc9530.txt	200	curl-fsSL-compressed-v1	2026-11-08	decoded-http-body-v1	544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a	67152	-	Receivers can validate the digest for integrity purposes.	rendered-text-v1	652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b	§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body
```

Diff, drafted → landed (only the two differing columns):

| column | my draft (from the seat brief) | landed | why the draft was wrong |
|---|---|---|---|
| 14 normalization | `raw-literal-v1` | `rendered-text-v1` | the RFC `.txt` body hard-wraps the §1.2 sentence across lines 168/169, so the literal byte substring does **not** occur in the raw body: `grep -cF` = 0. Under `raw-literal-v1` the row's own quote does not locate. |
| 15 normalized_sha256 | `-` | `652d3116…43436b` | `raw-literal-v1` rows carry `-`; `rendered-text-v1` rows must carry a 64-hex digest (the census's `SC_FETCH` normalizes-digest check). |
| 16 location | `.ufo/waves/round-67/capture/S166.body` | `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body` | a bare capture path is **capture-path-shaped**, so it would have become a 37th capture-path row and moved the frozen `path_rows=36`. |

**The brief's combination is not landable.** I measured it in a scratch copy of
the landed tree with S166 set to the brief's exact values:

```
FINDING SC_CAPTURE id=S166 quote-not-located
SOURCES_CAPTURES: FAILED (defects=1 path_rows=37 bound=37 located=36 prose=120)
```

— the gate goes FAILED and `path_rows` moves 36 → 37, breaking the frozen
`C1_READTHROUGH: bound=36 located=36` target. The landed row's three values are
the ones that keep the gate CLEAN and the population at 36. This is recorded as
**the L1's correction of my brief**, not a defect in the landed row.

Checks against the landed row, all reproduced by me:

- **col 3 row-identity digest**: `sha256("S166\tmined\thttps://www.rfc-editor.org/rfc/rfc9530.txt\n")`
  = `8b120c456013d67fa77b40f71c506927e21b823adef69b6d29deb521e2f8eb2b` — **matches** the landed col 3. I confirmed the gate's exact formula (`printf '%s\t%s\t%s\n' | sha256sum`) reproduces the stored digests of existing rows (checked S115: stored `d29af8f0…` = `sha256("S115\tmined\thttps://openbao.org/docs/audit/\n")`). ✔
- **col 10 / col 11**: sha256 `544dbb7d…2cdd6a` and 67152 both reproduce from the capture bytes. ✔
- **col 13 quote / col 14 normalization**: the quote locates **count=1** under the declared `rendered-text-v1`; the raw-literal count is 0 (why the landed normalization matters). ✔
- **col 9 representation**: `decoded-http-body-v1`, one of the two values the census accepts (34 of the 36 capture rows use it; 2 use `decoded-http-body-volatile-v1`). ✔
- **col 12 revision**: `-`, allowed (the URL is not a moving-ref form). ✔
- **col 16 location**: prose-shaped, so S166 is **not** in the capture read-through population — the deliberate choice recorded in the plan's Amendment A3.3. Consequence: **S166's own capture is not gate-checked**; its sha256/size/locate are hand-verified (receipt `s166-capture.txt`) and the entry says so. ✔

### (b) `corpus/SOURCES.md` — S166 registry row (11 columns)

Landed row, verbatim:

```
| S166 | RFC 9530 — HTTP Digest Fields (Content-Digest and Repr-Digest) — https://www.rfc-editor.org/rfc/rfc9530.txt | spec | A | provenance integrity: a digest recomputed over the named bytes validates a representation (Repr-Digest) or the content after normalization (Content-Digest); an identifier or path is not a digest | §1.2 Concept Overview; capture `.ufo/waves/round-67/capture/S166.body` (67152 B, sha256 `544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a`); opened live 2026-11-08 with a browser user agent (HTTP 200, 67152 B, same sha256; quote locate count=1 under rendered-text-v1) | Receivers can validate the digest for integrity purposes. | mined | 2026-11-08 | 180d | corpus/knowledge/source-capture-binding.md |
```

Diff, drafted → landed:

| cell | my draft | landed | note |
|---|---|---|---|
| kind | `docs` (per the brief's "tier A, docs") | `spec` | landed is right: RFC 9530 is a specification, and the lane's other RFC rows use `spec` (S052 RFC 4287, S068 RFC 9700). |
| tier / status / opened / recheck | A / mined / 2026-11-08 / 180d | same | ✔ |
| used-by | `corpus/knowledge/source-capture-binding.md` | same | ✔ (exactly the one path the brief named) |

- **tier A / spec**: consistent with the lane's contract (`kind` enum includes
  `spec`; tier A = primary or authoritative for that scope). RFC 9530 is the
  primary source for the digest-field distinction the entry grounds itself in. ✔
- **used-by**: `corpus/knowledge/source-capture-binding.md` only — the entry is
  the sole citer, and the census's `SC_USEDBY_NOCITE` leg is satisfied because
  the entry's `source:` line names S166. ✔
- **teaches cell**: the RFC quote, verbatim, 8 words. ✔
- **anchor cell**: names §1.2, the capture path, its byte count and sha256 — all
  four reproduce. ✔
- **census reading at the landed tree**: `SOURCES_CENSUS: CLEAN (rows=157 …)`,
  rc=0 — the S166 row introduces no `SC_FETCH` finding (status mined matches the
  registry, URL matches, row-identity digest matches, quote ≤25 words, digest
  format, size format, location length ≥ 8). ✔

## 3. Defects I see in the landed entry

Four findings, ordered by severity. Two are calibration defects in claims the
entry makes; one is a bound the entry states without its counter-evidence; one is
a token that does not exist in the instrument it names.

### Finding 1 — the S166 anchor cell's fetch half has no receipt in the tree (calibration, medium)

The S166 registry row's anchor cell asserts two separable things: the bytes
(reproducible — sha256, size and locate count all verify) and **"opened live
2026-11-08 with a browser user agent (HTTP 200 …)"** (no receipt). The round-67
capture directory holds only `S166.body`; there is no `.meta`, headers file or
fetch log beside it, unlike the capture directories of rounds 37/38/39 which keep
their bodies. The RFC 9530 `.txt` is a stable public document and the body is
byte-verified, so the risk is low — but the lane's own rule (QM: a re-verification
mechanism must be a committed instrument) and the registry's own `Fetch sha256:`
convention make an unverifiable "HTTP 200 with a browser user agent" a claim
without a receipt in the tree. The entry's `verified-at:` line repeats it
("both opened live today"). **Not fixable by me** (not my surface). Either the
L1 commits a fetch receipt for the capture, or both sentences are narrowed to
what the tree carries (the sha256, the byte count, the locate count).

### Finding 2 — the F8 row names a token the counter never prints (calibration, medium)

The falsifier table's F8 row reads:

> | F8 | reroute one bound row's columns 16/10/11/13/14/15 to a sibling row's
> values | the gate reads CLEAN; the round-67 counter reads the identity guard
> `defect` |

The **gate half is exactly right** — I rerouted S115's columns 16/10/11/13/14/15
to S116's values in a scratch copy and the landed gate reads
`SOURCES_CAPTURES: CLEAN` and `SOURCES_CENSUS: CLEAN (rows=157 …)`. The
counter half is right in substance and **wrong in its token**: on that same tree
the counter prints

```
c1-readthrough: guard-pop base_ids=36 missing=none extra=none changed=S115 source=base-tree …
C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=0
```

The identity guard fires and the verdict is `guard=0`, but the string `defect`
never appears on that leg — the counter's `defect` token belongs to its
`derived-defect` line, a different leg. A falsifier table is a set of
expectations a future reader will run; quoting a token the instrument does not
print sends that reader looking for output that cannot appear. **Fix**: replace
`reads the identity guard `defect`` with the observed pair
(`guard-pop … changed=<id>` and `guard=0`).

### Finding 3 — bound 4 overstates what the gate does not check, and the counter's guard is narrower than the bound claims (calibration, medium)

Bound 4 says:

> A row whose every dependent column is rerouted to another row's body — id,
> path, digest, size, quote — reads `CLEAN`; the counter closes that class by
> binding the capture-path id set and each id's path/digest to the BASE blob,
> which is a guard around the gate, not a property of the gate.

Measured, in two steps:

- Rerouting S115's **capture-dependent** columns (16/10/11/13/14/15) to a
  sibling's values: the gate reads `SOURCES_CENSUS: CLEAN (rows=157 …)`. So the
  "reads CLEAN" half is true for the capture-dependent subset — which is the
  subset the counter's guard-pop covers (`changed=S115`, `guard=0`). ✔
- Rerouting a row's **identity** columns as well (col 2 row-identity digest and
  col 4 url, alongside the capture columns): the gate does **not** read CLEAN. It
  prints

  ```
  FINDING SC_FETCH id=S115 url-mismatch
  FINDING SC_FETCH id=S115 row-identity-digest-mismatch
  SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)
  SOURCES_CENSUS: FAILED (findings=2 rows=157)
  ```

  The `SC_FETCH` legs already refuse a row whose id, url and row-identity digest
  do not cohere. The gate's blindness is bounded to the capture-dependent
  columns; the identity columns are enforced by a different class.

So the bound names "id, path, digest, size, quote" as one reroute that reads
CLEAN, when in fact two of those five (`id`, and the url/row-identity pair the
id implies) are caught by `SC_FETCH`, and the counter's guard-pop checks only
the id set plus col 16 and col 10 — **not** the quote, the size, the
normalization, the normalized digest or the row-identity digest. The bound's
second clause ("the counter closes that class by binding the capture-path id set
and each id's path/digest") is accurate about the counter, but the first clause
("every dependent column … reads CLEAN") is not: the counter's guard is
narrower than the sentence, and the gate is not blind to the identity reroute.
**Fix**: narrow the bound to the columns the gate really does not check, and say
which class catches the identity reroute (`SC_FETCH`, not `SC_CAPTURE`).

### Finding 4 — the RFC correspondence is stated more strongly than the RFC's own text supports (calibration, low–medium)

The entry says the RFC "draws the same distinction one layer up", and the
registry row's scope cell maps the lane's two digest layers onto the RFC's two
fields: *"a digest recomputed over the named bytes validates a representation
(Repr-Digest) or the content after normalization (Content-Digest)"*.

The RFC's own definitions, read in the capture (lines 284–286 and 335–337):

- §2 Content-Digest: "digests that are calculated using a hashing algorithm
  applied to **the actual message content** (see Section 6.4 of [HTTP])".
- §3 Repr-Digest: "digests that are calculated using a hashing algorithm applied
  to **the entire selected representation data** (see Section 8.1 of [HTTP])".

Two things follow, and both cut against the landed wording:

1. The RFC's two fields differ in **which bytes are covered** (message content
   vs. selected representation data) — two scopes over one resource. The lane's
   two columns differ in **normalization** (raw decoded body vs. the same body
   rendered to text) — one byte string, two views. The entry's own hedge helps
   ("the correspondence is a *structural* one — the RFC defines HTTP fields, not
   file columns"), but the scope cell's mapping is stated as if the two were the
   same distinction, and it maps the *named bytes* to Repr-Digest, whereas the
   RFC's Content-Digest is the digest of the message content — the fetched body.
   The normalized text is a rendering of the same content, which the RFC does
   not have a field for.
2. The entry adds "which is what a recipient should validate when the transfer
   may have altered the content's form". RFC 9530 §1.2 gives a different reason
   for Repr-Digest — "the message content requires some sort of manipulation to
   be considered as representation of the resource or the content conveys a
   partial representation of a resource, such as range requests" (lines 178–186)
   — while the "multiple different digest values when transferred" sentence
   (lines 200–202) is about Content-Encoding/Content-Type, not about which field
   a recipient should validate. The RFC never says recipients *should* validate
   one field rather than the other.

**Fix**: state the correspondence as the lane's own convention (two digests over
one body, raw and normalized) and cite the RFC only for the narrower claim it
does make — that a digest is scoped to the data it was computed over, and that
integrity fields apply to content or representations and not to messages or
fields (lines 205–209) — which the entry already gets right, along with the RFC's
no-authentication/no-privacy boundary (lines 213–215).

### Non-defects I checked and cleared

- **The header contract** (`corpus/claim-ledger.md` §Class 6): one column-1
  `source:` line naming S166 and S164 (both `mined`); `verified-at:` present;
  `recheck:` present; one `Reverify:` line naming the live ledger row `R21-02`;
  the entry is stamped (`corpus/stamps.tsv` row present, sha256
  `7192e621…da9e6`, 94 lines, 5925 B). `bash corpus/claim-ledger.sh docs` reads
  `DOC_AUDIT: CLEAN (entries=48 row_linked=45 by_hand=3 undeclared=0
  missing_ids=0 unpinned=0 duplicate_reasons=0)`. ✔
- **Every registry id named in the body is recorded**: `body_ids` over the entry
  yields exactly `S164` and `S166`, both on the `source:` line; the landed
  census prints no `SC_BODY_CITE` / `SC_ENTRY_CITE` finding. ✔
- **`Reverify: R21-02` is a live ledger row** (`bash corpus/sources-census.sh`)
  — the census is the instrument that re-derives the digests this entry teaches
  about, so the pairing is right in kind. (Its `expect` pin is stale for reasons
  the round already owns; see §5.)
- **All eight falsifier rows re-run**: F1–F6 and F8 produce exactly the
  reasons the table claims, with the right defect counts; F7 increments prose
  and emits no finding. Receipt `falsifiers.txt`.
- **The blindness witness is real**: the BASE gate (076701a) reads
  `SOURCES_CENSUS: CLEAN` with rc=0 on all six mutated copies I built. ✔
- **The RFC quotations the entry leans on are in the capture**: §1.2 lines
  163–215, §2 lines 282–286, §3 lines 333–337; the "content or representations,
  never messages or fields" sentence (205–209) and the "no authentication,
  authorization, or privacy" sentence (213–215) are both present verbatim. ✔
- **The `S164` half of the `source:` line**: S164 is `mined`, tier A, and its
  carrier body `.ufo/waves/round-64/capture/S143.body` (264946 B, sha256
  `3b8d4e15…`) reproduces; the entry's recheck line names both captures. ✔

## 4. What I did not get to

- I did **not** read the landed `plans/round-67-c1.sh` / `plans/round-67-c2.sh`
  end to end or re-derive their verdict lines from source; I ran
  `bash plans/round-67-c1.sh --tree .` and read its output, and read the
  `guard_pop`/`guard_e`/`guard_d` functions, but a full instrument review was
  not my seat's.
- I did **not** run the c2 counter or the claim-ledger `cells` mode, and I did
  not check the round-67 lesson's `used-by` old→new log (leg L7's material) for
  the S166/S164 additions.
- I did **not** verify the census's `SC_FETCH` selftest case count by reading
  the 88 cases individually; I confirmed the tally
  (`SOURCES_CENSUS_SELFTEST: PASS (88 cases)`) and read the five new
  `SC_CAPTURE` reason strings in the gate's source.
- My scratch (`${HYAKU_SCRATCH}/kagi-r67/R67ScribeEntry/`, incl. the six
  throwaway tree copies) is **deleted** at yield; the durable receipts are the
  four files under `.ufo/waves/round-67/w1/R67ScribeEntry/`.

## 5. Note for the L1 — the ledger pins this round's census output

Both census-ledger rows are pinned to a census summary the instrument no longer
prints, which the round's own work changed:

| row | expect pin | live output | verdict |
|---|---|---|---|
| R21-02 | `SOURCES_CENSUS: CLEAN (rows=114 … captures=114 …)` | `… (rows=157 … captures=157 …)` | **RED** at BASE too (BASE printed rows=156) — pre-existing staleness, not this round's doing; the landed tree also moves it 156 → 157 |
| R21-03 | `SOURCES_CENSUS_SELFTEST: PASS (88 cases)` | `PASS (88 cases)` | **GREEN** (re-pinned in the worktree) |

R21-02's expect was already stale at BASE (rows=114 vs. the BASE tree's 156), so
it is inherited debt rather than a round-67 regression — but this round's census
rewrite is what makes it *visible* in the ledger's own `verify` output, and
`Reverify: R21-02` in the landed entry points at a row that reads red. If the
entry's `Reverify:` line is to name a row that passes, `R21-03` is the green
counterpart of the same instrument. Flagging it for the L1's decision; I did not
edit the ledger.

---

**Seat status: complete** — review delivered; no lane file edited; no commit made.
