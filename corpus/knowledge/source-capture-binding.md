# Source capture binding — a declared capture is evidence only when its bytes hash to the row

source: S166 (https://www.rfc-editor.org/rfc/rfc9530.txt, §1.2 Concept Overview, 2026-11-08); S164 (https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode, §3.1.2, 2026-11-08); S167 (https://www.rfc-editor.org/rfc/rfc4648.txt, §3.3 Interpretation of Non-Alphabet Characters in Encoded Data, 2026-11-08)
cites: S099, S113, S115, S143 — the fleet-root `.ufo/prompts/` row whose class no lane-rooted gate can bind (named in §Bounds 5); the row whose `~/`-prefixed location cell the round-67 revenger measured as a surviving bypass (named in §3); the audit-device row whose one-token quote locates trivially (named in §Bounds 3); and the carrier row whose capture file the S164 row names (named in the `verified-at:` line). Cross-references, not this entry's support; recorded round 68.
verified-at: 2026-11-08 (all three opened live today; captures `.ufo/waves/round-67/capture/S166.body`, 67152 B, `.ufo/waves/round-64/capture/S143.body` (the carrier body, 264946 B) and `.ufo/waves/round-68/capture/S167.body`, 35491 B; the S166 fetch receipt is `.ufo/waves/round-67/capture/S166.fetch.txt` - HTTP 200, 67152 B, refetch byte-identical)
recheck: 180d — re-open S166, S164 and S167 and re-hash all three captures
Reverify: R21-03

A registry row that names a capture is making a claim about bytes, not about a
path. The claim holds only when the gate opens the named file and re-derives
three things the row already declares: the sha256 (column 10), the byte count
(column 11), and the declared locator quote's presence (column 13) under the
declared normalization (column 14). A string check on the path — existence, or
its length — proves none of them.

## 1. The population the census reads, and the rule that classifies a cell

The read-through used to cover only the cells that *looked* like a capture
path. Round 68 widens it to every mined row that names a lane-tree capture,
and the classification is a single monotone rule over one column — column 16,
the location cell.

**The rule.** A column-16 cell is classified into exactly one of three
shapes, by one monotone decision procedure:

- **path** — the cell's entire content is one capture path in the pure
  `CAPTURE-PATH-SHAPED` form (repo-relative or absolute, including `./` and
  doubled-slash spellings that canonicalize inside the root). A path cell is
  read: the named file must canonicalize inside the lane root, be a regular
  file, and match the row's declared sha256 and byte count.
- **prose** — the cell names no `.ufo/waves/` whitespace-delimited token and
  carries no `~/` or `//` expansion form. Prose is never read and never
  produces a finding. It keeps exactly its round-67 meaning: a cell that does
  not mention a lane capture is out of scope by construction, not because it
  was judged safe. S099's fleet-root `.ufo/prompts/…` cell is prose here.
- **defect** — every other shape that names a `.ufo/waves/` path or an
  expansion form. Defect rows count as *path* rows, not prose, so a defect
  never silently shrinks the read population.

**Every other shape that mentions a `.ufo/waves/` path is a defect.** The
rule is monotone in one direction only: a cell is either prose, or a pure path,
or a defect. There is no fourth class and no "close enough" reading. An
absolute or `..`-escaping cell is path population (so it keeps its
`capture-outside-root` binding verdict), never prose: an escape must not be
able to hide by looking like a location string.

The counting command, run over the tree this entry was written against
(`awk -F'\t' 'NF==16 {c=$16; n=split(c,t,/ +/); w=0; for(i=1;i<=n;i++) if (t[i] ~ /\.ufo\/waves\//) w=1; if(w==0){p++; if(c ~ /\//) s++} else if (c ~ /^\.ufo\/waves\/[^ ]+$/) pp++; else d++} END{print "pure path:"pp, "prose:"p, "defect:"d, "prose-with-slash:"s}' corpus/source-fetches.tsv`)
reads:

```
pure path:38 prose:120 defect: prose-with-slash:17
```

(`defect:` is empty — zero — on this tree: every cell that names a
`.ufo/waves/` path is exactly that path.) The census's own summary line
agrees, at `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38
prose=120)`: 38 path rows, every one bound and located, and 120 prose rows.
The 38 pure paths are the 36 that were already there at BASE plus S166
(recut to the pure path by this round) and S167 (this round's new row).

**Why a mixed-prose cell naming a lane capture is a defect, not prose.** Under
the old rule the classifier asked only "is this string shaped like a path?",
and anything else was prose and was silently skipped. That made the escape
hatch: one stray byte — a trailing space, a CR, a comma-joined second value —
turned a *bound* row into an *unread* row while the summary still printed
`CLEAN`, and the whole-file CRLF variant disengaged every row at once
(`path_rows=0`). The widened rule cannot be escaped that way, because it
classifies on what the cell *mentions*, not on whether the cell happens to
match a shape: a cell that mentions a lane capture is bound to it, so a cell
that mentions one and is not exactly that path is refused rather than skipped.
S166's own cell was the proof that this matters — it named
`.ufo/waves/round-67/capture/S166.body` inside a sentence, so the round's
sourced claim rested on a capture the gate never opened; the round-68 landing
recuts that cell to the pure path.

S167 grounds the *choice* this lane makes, and the RFC's own structure is what
makes it a choice rather than a command (RFC 4648 §3.3, opened 2026-11-08):
*"Implementations MUST reject the encoded data if it contains characters outside
the base alphabet when interpreting base-encoded data, unless the specification
referring to this document explicitly states otherwise."* The default is
refusal; a referring specification may instead declare that such characters are
ignored — MIME does, and in that liberal branch *"any adjacent carriage return/
line feed (CRLF) characters constitute 'non-alphabet characters' and are
ignored"*. RFC 4648 §12 then records the cost of the liberal branch: ignored
non-alphabet bytes are a covert channel. This lane takes the default branch, so
a location cell that carries a stray byte is refused rather than normalised
away, and the census's column-16 rule is that choice made mechanical. The RFC
speaks of base-encoded data, not of a TSV cell; the transposition is the lane's,
stated here rather than attributed to the source.

## 2. The two digest layers, and the third check that closes them

The lane stores two digests per capture and they answer different questions.
Column 10 is the sha256 of the decoded HTTP body exactly as served
(`decoded-http-body-v1`): it answers "are these the bytes the fetch produced?".
Column 15 is the sha256 of that body after `rendered-text-v1` normalization: it
answers "is the *text* the same?" when the carrier's markup or line wrapping
changes between fetches and the prose does not.

Round 67 bound columns 10 and 11 to the file and located the quote, but only
*format-checked* column 15: the gate verified that column 15 was a 64-hex
string and never recomputed it. A row whose column 15 was copied from another
row therefore read `CLEAN` — a borrowed normalized digest was invisible. The
round-68 gate adds the third check: for every row that is bound and declares
`rendered-text-v1`, the normalized digest is **recomputed** from the bound
file with `corpus/rendered-text-v1.py digest` and compared to column 15; a
difference is a finding (`normalized-digest-mismatch`), not a format note.

The three layers therefore answer three separate questions, and none of them
substitutes for another:

| layer | what it answers | what it cannot see |
|---|---|---|
| column 10 (raw sha256) | are these the bytes the fetch produced? | whether the *text* is unchanged after normalization |
| column 15 (normalized digest, declared) | what the text hashes to, as declared | whether the declaration matches the file on disk |
| column 15 (recomputed, round 68) | does the file on disk hash to what the row declares? | — |

The recomputation is what makes the third layer an independent check rather
than a restatement: column 10 and column 15 are computed from the same bytes,
so a coherent rewrite of the body moves both. The recomputed column 15 is
compared against the *declared* column 15, so a rewrite that forgets to
recompute the normalized digest is caught where the old gate was blind.

RFC 9530 draws a related two-scope distinction (S166): a `Content-Digest` field
carries a digest over "the actual message content" (§2), while `Repr-Digest`
carries one over "the entire selected representation data" (§3), and the RFC's
stated reason for the second scope is manipulation or a partial representation —
range requests, for example — not normalization. The lane's two columns are not
those two scopes: both hash the same served body, once raw and once after
`rendered-text-v1` normalization. The correspondence is analogical (a digest
over named bytes versus a digest over a named transformation of them), and it
stops where the RFC says: integrity fields apply to content or representations,
never to messages or their metadata, and the specification defines no
authentication, authorization or privacy. A digest proves the bytes match the
pin; it proves nothing about who served them.

## 3. What the read-through catches, measured

`corpus/sources-census.sh` gained a capture read-through in round 67 and
widened its population and its reason set in round 68. The round-68 reasons
and the exact input that produces each, as the gate emits them:

| reason | one failing input | the gate's own line (verbatim) |
|---|---|---|
| `capture-whitespace` | the anchor's column 16 with one trailing space (0x20) appended | `FINDING SC_CAPTURE id=S167 capture-whitespace` |
| `capture-token` | the anchor's column 16 rewritten to a mixed-prose cell that still names a lane capture (`§1.2 Concept Overview; capture .ufo/waves/round-68/capture/S167.body`) | `FINDING SC_CAPTURE id=S167 capture-token` |
| `normalized-digest-mismatch` | the anchor's column 15 replaced by another row's 64-hex digest of the same normalization | `FINDING SC_CAPTURE id=S167 normalized-digest-mismatch` |
| `SC_FETCH cr-in-tsv` | `corpus/source-fetches.tsv` rewritten with a CR at every line end | `FINDING SC_FETCH cr-in-tsv` |

Every row of that table was run on a copy of the candidate tree with the
mutation applied to `corpus/source-fetches.tsv` (or to the anchor's capture
body), and the gate's own stdout pasted back. The **anchor** is not a name
picked by hand: it is derived as the LAST row in file order whose first
`.ufo/waves/` token binds its declared bytes (raw sha256, size and quote
locate) on the unmodified tree. On the candidate tree that is **S167**
(`.ufo/waves/round-68/capture/S167.body`, 35491 B) — it is last in file order
and it binds — so every mutated id in the table below is S167, and the same
six reasons fire identically when the anchor is S166. The receipts name the
gate's sha256, the mutated tree, the exit code and the gate's full stdout.
Two cases in full, from `.ufo/waves/round-68/w1/R68ScribeEntry/`:

```
=== M1-trailing-space (rc=1) ===
FINDING SC_CAPTURE id=S167 capture-whitespace
SOURCES_CAPTURES: FAILED (defects=1 path_rows=38 bound=37 located=37 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158)

=== M3-whole-file-crlf (rc=1) ===
FINDING SC_FETCH cr-in-tsv
FINDING SC_CAPTURE id=<every capture row> capture-whitespace
… (one per capture row, 38 in all)
SOURCES_CAPTURES: FAILED (defects=38 path_rows=38 bound=0 located=0 prose=120)
SOURCES_CENSUS: FAILED (findings=39 rows=158)
```

A whole-file CRLF fails on **two** levels, and that is deliberate. The
file-level `SC_FETCH cr-in-tsv` fires because a CR byte appears anywhere in
`corpus/source-fetches.tsv`; and each capture row's cell now ends in a CR, so
the cell-level classifier reads it as `capture-whitespace` — the gate keeps
the CR in the cell for classification and strips it only for the binding
step, which never runs because the classification already refused the cell.
That is why the M3 line reads `defects=38 … bound=0 located=0`: the CRLF
save disengages every capture row rather than merely being noticed. The
round-67 gate read the same input `CLEAN` with `path_rows=0`.

`capture-whitespace` covers a cell that trims to a `.ufo/waves/` path but
carries stray whitespace, a comma-joined second value, or a CR; `capture-token`
covers a non-pure cell that names a `.ufo/waves/` file — a mixed-prose cell, a
`~/` or `//` form, or a token that does not resolve in-lane. Both are measured:
the comma-joined duplicate and the mixed-prose cell each produce exactly one
finding naming the mutated id, and the `~/`-prefixed form produces
`FINDING SC_CAPTURE id=S167 capture-token` as well. A pure path to a missing
file keeps its own binding reason (`capture-missing`), because the
classification judges the cell's form and the binding judges its target. Any
`SC_CAPTURE`/`SC_FETCH` finding makes the verdict `FAILED` (exit 1), and the
summary line keeps its shape:
`SOURCES_CAPTURES: CLEAN (path_rows=N bound=N located=N prose=N)` or
`SOURCES_CAPTURES: FAILED (defects=N path_rows=N bound=N located=N prose=N)`.

The round-67 reasons are unchanged and still produced by the same code path:
`capture-digest-mismatch` (raw sha256 ≠ column 10), `capture-bytes-mismatch`
(size ≠ column 11), `capture-missing` (no regular file at that path),
`capture-outside-root` (absolute location, or a repo-relative one whose
canonical path leaves the root), `quote-not-located` (column 13 does not
locate under the column-14 normalization on a row whose bytes otherwise bind).

At BASE the gate was blind to all three new classes. Seven witnesses were
re-measured on the BASE bytes this round (`git archive d3b2a4e…` extracted to
scratch, the mutation applied to `corpus/source-fetches.tsv`, the BASE gate run
on the mutated tree — receipts under
`.ufo/waves/round-68/w1/R68ScribeEntry/base-witnesses/`). Every one reads
`CLEAN` on the BASE gate:

| BASE witness (S164's column 16 unless stated) | BASE gate's line |
|---|---|
| one trailing space (0x20) appended | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| `,` + the same path again (comma-joined duplicate) | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| one trailing CR (0x0d) appended | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| `//etc/passwd` | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| `~/.ufo/waves/round-64/capture/S143.body` | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| column 15 replaced by another row's normalized digest | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| the whole file rewritten with CR at every line end | `SOURCES_CAPTURES: CLEAN (path_rows=0 bound=0 located=0 prose=157)` |

Each witness drops one row out of the path population (`path_rows` 36 → 35) or
disengages all of them (the CRLF file: `path_rows=0`), and the verdict stays
`CLEAN` — the blindness was real, not hypothetical. The same seven inputs on
the widened gate are the four round-68 reasons plus the three round-67 binding
reasons listed above.

## Bounds — what this does not establish

1. **Re-verification is a point-in-time attestation.** The gate binds the
   bytes that are on disk when it runs. A body that changes after the run is
   invisible until the next run; the lane's own header calls a provenance
   digest "a point attestation, not a drift pin". Nothing here says the page
   behind the URL still serves those bytes.
2. **Hardlink durability is a ceiling.** An in-tree capture that is a hardlink
   to an out-of-tree file binds while the bytes match; an external write to the
   shared inode then changes what the row attests to, and only a later run
   sees it. The round-67 revenger measured this class surviving the
   round-67 gate (`.ufo/waves/round-67/w1/R67Revenger.md` §3, class C2). The
   round-68 gate does not detect it; a re-verify must precede any use.
3. **One-token quotes are unmeasured.** `located` counts a quote that occurs at
   least once under the declared normalization. It says nothing about whether
   the passage supports the row's teaching. A one-word quote locates
   trivially — measured on the audit-device body:
   `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-57/capture/S115.body "the"`
   → `RENDERED_TEXT_V1_LOCATE: count=90`; the same command with the token
   `"a"` → `RENDERED_TEXT_V1_LOCATE: count=580`. The round-68 gate does not
   raise a minimum quote length.
4. **The gate's own normalizer is the gate's own instrument.** The
   `rendered-text-v1` normalizer that decides `located` and recomputes
   column 15 is the copy sitting beside the gate. A tree that ships a stub
   normalizer could, in principle, move the verdict; round 67 closed this at
   the *counter* (guard (f) binds the candidate's normalizer to the committed
   one) and the gate cannot vouch for itself. The gate anchors the normalizer
   at its own sibling path (`$SCRIPT_DIR/rendered-text-v1.py`) rather than
   inside the audited tree, which removes the copy-inside-the-tree variant but
   not the sibling-substitution variant.
5. **The fleet-root `.ufo/prompts/` class cannot be bound by a lane-rooted
   gate.** A column-16 cell that names a fleet-root path — S099's
   `.ufo/prompts/kagi-round-44.md §6 item 9, line 561 (byte offset 52924)` —
   carries no `.ufo/waves/` token, so under the rule in §1 it is prose: it is
   never read and no gate may claim it. The file itself lives in the fleet
   tree, outside the lane, so no lane-rooted `realpath` can bind it. It was
   verified by hand this round (2026-11-08), against
   `/home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-44.md`:
   `sha256sum` → `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`;
   `wc -c <` → `97077`; the declared quote
   (`The claim is judged on the counter, kill rule and predicate declared before data. A rule`)
   locates at byte offset 52924 (line 561), raw-literal count 1 — matching the
   row's declared columns 10, 11 and 13. This is a hand measurement, not a
   gate verdict: the row's bytes are attested here and by no committed
   instrument. Its flip condition is a later round's: a fleet-root class that
   a lane-rooted gate can bind.
6. **A body rewritten together with its row passes.** Replace the bytes and
   update columns 10, 11, 13 and 15 coherently and every in-row check agrees.
   The binding is row-local; it is not a second witness. The column-15
   recomputation does not change this: a coherent rewrite recomputes the
   normalized digest too.
7. **Prose locations are counted and never opened.** 120 rows name a section,
   a thread or an offset rather than a file; 17 of them contain `/` (measured
   with the token test in §1). They are outside this check by construction,
   not because they were judged safe.
8. **Row identity is not gate-enforced for the capture columns.** A row whose
   capture-dependent columns (path, digest, size, quote, normalization) are
   rerouted to another row's body reads `CLEAN`: the URL and row-identity digest
   still bind the id, but they say nothing about which body the row names. The
   counter closes that class by binding the capture-path id set and each id's
   path/digest to the BASE blob — a guard around the gate, not a property of
   the gate.
9. **`raw-literal-v1` and `rendered-text-v1` are not interchangeable.** A quote
   wrapped across two physical lines locates only after normalization: the RFC
   body is plain text, and its §1.2 sentence reads `count=0` raw and `count=1`
   rendered — measured:
   `grep -c "Receivers can validate the digest for integrity purposes." .ufo/waves/round-67/capture/S166.body`
   → `0`, and
   `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-67/capture/S166.body "Receivers can validate the digest for integrity purposes."`
   → `RENDERED_TEXT_V1_LOCATE: count=1`. A row declares which one it means.
10. **Two digests are not two witnesses.** Columns 10 and 15 are computed from
    the same bytes; a coherent rewrite moves both.
11. **No network.** Every check is over committed bytes; a page that has
    changed since capture is invisible here.

## Falsifiers

| # | input | expected |
|---|---|---|
| F1 | repoint one capture-path row's column 16 to a body of the same size and a different sha256 | `capture-digest-mismatch` naming that row |
| F2 | truncate one bound body by one byte | `capture-bytes-mismatch` and `capture-digest-mismatch` |
| F3 | delete one bound body | `capture-missing` |
| F4 | set one row's column 16 to an absolute path inside the tree | `capture-outside-root` |
| F5 | set one row's column 16 to a `..` path that canonicalizes outside the tree | `capture-outside-root` |
| F6 | replace one row's quote with a string that does not occur in its body | `quote-not-located` |
| F7 | add a prose location with `/` in it | no `SC_CAPTURE` finding; `prose` increments |
| F8 | reroute one bound row's columns 16/10/11/13/14/15 to a sibling row's values | the gate reads CLEAN; the round-67 counter prints `guard-pop … changed=<id>` and `guard=0`, rc 1 |
| F9 | append one space to a bound row's column 16 | `FINDING SC_CAPTURE id=<that row> capture-whitespace`; `SOURCES_CAPTURES: FAILED` |
| F10 | rewrite a bound row's column 16 as a mixed-prose cell that still names a lane capture | `FINDING SC_CAPTURE id=<that row> capture-token`; `SOURCES_CAPTURES: FAILED` |
| F11 | replace a bound rendered-text-v1 row's column 15 with another 64-hex digest | `FINDING SC_CAPTURE id=<that row> normalized-digest-mismatch`; `SOURCES_CAPTURES: FAILED` |
| F12 | rewrite `corpus/source-fetches.tsv` with a CR at every line end | `FINDING SC_FETCH cr-in-tsv`; `SOURCES_CENSUS: FAILED`, rc 1 |

## Reproduction

```
bash corpus/sources-census.sh                 # SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
                                              # SOURCES_CENSUS: CLEAN (rows=158 …)
bash corpus/sources-census.sh --selftest      # SOURCES_CENSUS_SELFTEST: PASS (N cases) — one case per reason + the guards
bash plans/round-68-c1.sh --tree .            # C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1
```

The three counts in the first line are the census's own, not this entry's:
`path_rows` is the number of cells the classifier read as a path, `bound` the
number whose bytes and digest match, `located` the number whose quote
locates, `prose` the number of cells that name no lane capture at all. The
selftest case count is printed by the gate and moves with its reason set —
read it from the gate's own line rather than from a number quoted here.

The counter's `verified=38 col15=33` is the candidate reading of the
population derived in §1: 38 binding rows, of which 33 declare
`rendered-text-v1` and carry a col 15 equal to the digest recomputed from
their bound file. `plans/round-68.md` §Amendment A1 (landed
`4251519bd6e8b5c152d70ae286e04a117a49ed4f`, before any counter existed on
disk) states that this is the reading of the tree the round's own frontier
step produces, and that the frozen `37/32` is the recut-only reading measured
before the S167 row landed. The three are not interchangeable: read the
counter's own line.
