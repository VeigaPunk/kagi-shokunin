# Source capture binding — a declared capture is evidence only when its bytes hash to the row

source: S166 (https://www.rfc-editor.org/rfc/rfc9530.txt, §1.2 Concept Overview, 2026-11-08); S164 (https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode, §3.1.2, 2026-11-08)
verified-at: 2026-11-08 (both opened live today; captures `.ufo/waves/round-67/capture/S166.body`, 67152 B, and `.ufo/waves/round-64/capture/` (the carrier body, 264946 B))
recheck: 180d — re-open S166 and S164 and re-hash both captures
Reverify: R21-02

A registry row that names a capture is making a claim about bytes, not about a
path. The claim holds only when the gate opens the named file and re-derives
three things the row already declares: the sha256 (column 10), the byte count
(column 11), and the declared locator quote's presence (column 13) under the
declared normalization (column 14). A string check on the path — existence, or
its length — proves none of them.

## The two digest layers, and why both are kept

The lane stores two digests per capture and they answer different questions.
Column 10 is the sha256 of the decoded HTTP body exactly as served
(`decoded-http-body-v1`): it answers "are these the bytes the fetch produced?".
Column 15 is the sha256 of that body after `rendered-text-v1` normalization: it
answers "is the *text* the same?" when the carrier's markup or line wrapping
changes between fetches and the prose does not.

RFC 9530 draws the same distinction one layer up (S166, §1.2): a `Content-Digest`
field carries a digest over the HTTP content bytes, while a `Repr-Digest` field
carries one computed over the selected representation, which is what a recipient
should validate when the transfer may have altered the content's form. The
correspondence is a *structural* one — the RFC defines HTTP fields, not file
columns — and it stops at the boundary the RFC itself states: integrity fields
apply to content or representations, never to messages or their metadata, and
the specification defines no authentication, authorization or privacy. A digest
proves the bytes match the pin; it proves nothing about who served them.

## What the read-through catches, measured

`corpus/sources-census.sh` gained a capture read-through in round 67: 36
capture-path rows at BASE, every one bound by sha256 and size, six mutation
classes caught with a named `FINDING SC_CAPTURE id=<S-id> <reason>` — repoint to
a different body (`capture-digest-mismatch`), truncation
(`capture-bytes-mismatch` + `capture-digest-mismatch`), deletion
(`capture-missing`), an absolute location and a `..` escape
(`capture-outside-root`), a quote that does not locate (`quote-not-located`).
The BASE gate reads `CLEAN` on all six (receipt
`.ufo/waves/round-67/base/blind-gate.txt`): the blindness was real, not
hypothetical. One declared quote did not locate at BASE (the OpenBao audit-device row);
the re-cut is that row's column 13 in `corpus/source-fetches.tsv`.

## Bounds — what this does not establish

1. **A body rewritten together with its row passes.** Replace the bytes and
   update columns 10, 11, 13 and 15 coherently and every in-row check agrees.
   The binding is row-local; it is not a second witness.
2. **Prose locations are counted and never opened.** 120 rows name a section,
   a thread or an offset rather than a file; 17 of them contain `/`. They are
   outside this check by construction, not because they were judged safe.
3. **`located` is a location property, not a quote-strength property.** A
   one-token quote locates trivially (the token `a` occurs 580 times in the
   audit-device body); the predicate measures presence under the declared
   normalization, nothing about whether the passage supports the row's
   teaching.
4. **Row identity is not gate-enforced.** A row whose every dependent column is
   rerouted to another row's body — id, path, digest, size, quote — reads
   `CLEAN`; the counter closes that class by binding the capture-path id set and
   each id's path/digest to the BASE blob, which is a guard around the gate, not
   a property of the gate.
5. **`raw-literal-v1` and `rendered-text-v1` are not interchangeable.** A quote
   wrapped across two physical lines locates only after normalization: the RFC
   body is plain text, and its §1.2 sentence reads `count=0` raw and `count=1`
   rendered. A row declares which one it means.
6. **Two digests are not two witnesses.** Columns 10 and 15 are computed from
   the same bytes; a coherent rewrite moves both.
7. **No network.** Every check is over committed bytes; a page that has changed
   since capture is invisible here.

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
| F8 | reroute one bound row's columns 16/10/11/13/14/15 to a sibling row's values | the gate reads CLEAN; the round-67 counter reads the identity guard `defect` |

## Reproduction

```
bash corpus/sources-census.sh                 # SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)
bash corpus/sources-census.sh --selftest      # PASS (89 cases), one case per reason + the guards
bash plans/round-67-c1.sh --tree .            # C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1
```
