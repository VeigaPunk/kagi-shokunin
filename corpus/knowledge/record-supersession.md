source: S168 — RFC 9162 (Certificate Transparency v2), §2.1.4 "Merkle Consistency Proofs", https://www.rfc-editor.org/rfc/rfc9162.txt, opened 2026-11-08 with a browser user agent (HTTP 200, 128266 B, raw sha256 a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f; capture `.ufo/waves/round-69/capture/S168.body`); located quote (10 words): `Merkle consistency proofs prove the append-only property of the tree.`
verified-at: 2026-11-08 — opened live this round from https://www.rfc-editor.org/rfc/rfc9162.txt with a browser user agent: HTTP 200, 128266 B, raw sha256 `a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f`, byte-identical to the lane capture `.ufo/waves/round-69/capture/S168.body` (same byte count, same digest). The located quote sits at body line 475 (§2.1.4), raw byte offset 19819, and `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-69/capture/S168.body 'Merkle consistency proofs prove the append-only property of the tree.'` prints `RENDERED_TEXT_V1_LOCATE: count=1` (exit 0). A second sentence, the §1 superset statement, also locates count=1 under rendered-text-v1 and is NOT findable by a raw line grep, because the RFC wraps it across body lines 208–210 — the lane's normalizer is what makes the quote checkable, so the quote is bound to the bytes it was cut from, not to a line number. The RFC's own header classifies it `Category: Experimental` (body line 8) and states at body line 35 that it "is not an Internet Standards Track specification; it is published for examination, experimental implementation, and evaluation"; the transposition below is therefore the lane's own choice, not a requirement the RFC imposes.
recheck: 180d — re-open RFC 9162 and re-hash the capture, re-locate both quotes under rendered-text-v1, then re-run the lane's own supersession checks: the round-68 lesson must still carry its superseded sentence beside the `## Correction (round 69)` block that names it, the claim ledger must still carry the migration journal for any changed row expectation, and the census gate must still read this entry's `source:` line and S168's used-by. A re-cut of RFC 9162 that drops or rewrites §2.1.4, or a lesson rewrite that deletes a superseded sentence without naming it, re-fires the falsifiers below.
Reverify: R21-03

# Record supersession: a correction names what it supersedes, and never rewrites it

Scope: the lane's own record surfaces — lessons, scorecard rows, ledger rows — and the
rule this round repairs. The rule is not invented here: RFC 9162 §2.1.4 states the
append-only property of a Merkle log and the proof that carries it, and that
mechanism is what the lane transposes. The transposition is the lane's own, and
this entry says where it stops.

## 1. The rule, as the source states it

A CT log is a single append-only Merkle tree (§4, body line 777: "A log is a
single, append-only Merkle Tree of submitted certificate and precertificate
entries"); the tree the proof is over is defined in §2.1.1, and the property
that matters is stated in §1 and proved in §2.1.4:

> Merkle consistency proofs prove the append-only property of the tree.

A consistency proof for a Merkle Tree Hash `MTH(D_n)` and a previously advertised
hash `MTH(D[0:m])` is the list of nodes needed to verify that the first `m`
inputs are equal in both trees (§2.1.4, body lines 473–484). §2.1.4.2 gives the
verification algorithm: recompute the tree head from the proof and check that the
supplied `first_hash` matches and that `sn` reaches zero. Two facts follow from
the source itself:

- **The later state extends the earlier one.** The §1 statement (body lines
  207–210) says the append-only property lets a log "efficiently prove that any
  particular instance of the log is a superset of any particular previous
  instance". A consistency proof is therefore a *relation between two states*,
  not a claim about either one alone: it says the earlier tree is contained in
  the later one.
- **The proof is checkable by a third party.** It needs only the two tree heads
  and the node list. A reader can run the verification without trusting the log.

The status of the document matters for what follows: RFC 9162 is
`Category: Experimental` and explicitly not an Internet Standards Track
specification. Nothing in it obliges a lane to keep a record; the lane borrows the
*mechanism* (a checkable relation between two states) and supplies its own
objects.

## 2. The transposition to a lane record

A lane record is a set of committed bytes: a lesson file, a scorecard row, a
ledger row with a frozen expectation. Its states are the revisions. The lane's
transposition of the rule has three parts, and each part has a lane instance
that already exists.

**A correction supersedes; it never rewrites.** The superseded sentence stays in
the record, and the correction names it. The worked instance is round 68's own
lesson, `corpus/lessons/round-68.md`: the C2 bullet at line 18 still reads
"`C2_RECORD` mismatches 3 → 0 (selftest pin, missing ledger rows, cells SETUP)",
and the `## Correction (round 69)` block appended at line 228 quotes that
sentence verbatim and states that no aggregate line was produced on the landed
bytes, so the round-68 C2 claim is `unprovable`. Measured on the tree:
`grep -c 'mismatches 3 → 0' corpus/lessons/round-68.md` reads 2 — the original
sentence at line 18 and its verbatim quotation inside the correction at line
230. A repair that deleted line 18 instead of appending a block would leave the
count at 1 and destroy the only route a reader has to the thing that was
corrected.

**The correction names the receipt that supersedes it.** The lane's proof of
"this supersedes that" is not a memory, it is a committed receipt that a reader
can open. The round-68 correction names
`.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt`, and that receipt's
line 6 reads verbatim:

```
# (no C2_RECORD line; the process was killed at the budget)
```

That is the receipt that makes the correction checkable: the correction asserts
the aggregate was never printed, and the named file is where a reader finds out
for himself. `grep -c 'c2-lane-run.txt' corpus/lessons/round-68.md` reads 1.

**A changed expectation is journaled with its old value.** Where the
supersession changes a machine-checked thing — a ledger row's frozen expectation
— the old value stays, in a migration journal, beside the new one. The round-69
journal `.ufo/waves/round-69/journals/expectation-migrations.json` carries the
`R68-02` row's `old_expect` and `new_expect` verbatim, so the row's own history
is recoverable: the row now points at the surface that carries the honest stop,
and the expectation it used to pin is preserved rather than overwritten.

## 3. What the lane can and cannot establish from this

The bounds are stated here because the transposition is weaker than the source
in two specific ways, and both matter when a reader decides how much weight a
lane claim carries.

**Existence and value, never authorship.** A consistency proof establishes a
relation between two tree heads and lets a third party check it. The lane's
version establishes the same for record states: that a named sentence exists in a
named file, that the file's bytes carry a digest a reader recomputes, and that a
correction beside it names the sentence it replaces. What no lane instrument can
do is establish *who* wrote a sentence or what they intended by it. The
instrument reads committed bytes; the bytes do not carry their author's intent.
So a lane claim of the form "the record says X" is a claim about bytes and is
checkable; a claim of the form "the author believed X" is not a lane claim at
all.

**A named superseded reading is not a false statement.** The append-only rule
keeps the old sentence *because* it was the record's reading at the time. Once
the correction names it and the receipt supersedes it, the old sentence is a
dated reading, not a falsehood: the record says "this was asserted here, and
here is what replaced it". Deleting the false sentence would leave a reader
unable to tell what the round believed, which is a worse record than a wrong
sentence that is explicitly dated and corrected. This is the difference between
supersession and an edit, and it is why the falsifier below counts occurrences
of the superseded sentence rather than looking for its absence.

## 4. Falsifiers

Each of the six below is a command a reader can run against the tree. Each
states the reading that holds while the rule holds, and what a violation looks
like.

**F1 — the source still carries the located sentence.**
`python3 corpus/rendered-text-v1.py locate .ufo/waves/round-69/capture/S168.body 'Merkle consistency proofs prove the append-only property of the tree.'`
reads `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0. A count of 0 means the capture
no longer contains the rule this entry quotes — the entry's ground has moved
and the entry must be re-cut or withdrawn.

**F2 — the capture bytes are the bytes the row pins.**
`sha256sum .ufo/waves/round-69/capture/S168.body` reads
`a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f` over 128266
bytes. A different digest means the quoted bytes are not the bytes the registry
row pins, and the quote can no longer be checked against the source.

**F3 — the superseded sentence is still in the record, and a correction names
it.** `grep -c 'mismatches 3 → 0' corpus/lessons/round-68.md` reads 2 and
`grep -c '^## Correction (round 69)' corpus/lessons/round-68.md` reads 1. A
count of 1 for the first, with the correction still present, means the
superseded bytes were rewritten rather than superseded; a count of 0 for the
second means the record was left asserting a reading no receipt backs.

**F4 — the named receipt says what the correction claims.**
`sed -n '6p' .ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt` reads
`# (no C2_RECORD line; the process was killed at the budget)`. If that line
changes, the correction's quotation no longer matches its receipt, and the
correction has become a memory rather than a checked claim.

**F5 — a changed expectation kept its old value.**
`grep -c 'mismatches=0 population=3 guard=1' corpus/claim-ledger.tsv` reads 0
(the superseded expectation is gone from the live rows) while the same grep over
`.ufo/waves/round-69/journals/expectation-migrations.json` reads 1 (it is kept
in the journal). A live row still carrying the old expectation means the
migration did not land; a journal that lost the old value means the change was
an overwrite, which is the defect the rule exists to prevent.

**F6 — the expansion claim is a new entry, not a widening.**
`git ls-tree -r --name-only 264917aa corpus/knowledge` lists 48 paths and the
same command at the round-68 tip `cd9d66f1` lists 48 as well — round 68 widened
an existing entry (`corpus/knowledge/source-capture-binding.md`) and added no
file, so its expansion verdict had no new ground under it. A round that claims
expansion must show the count rising by one, and `grep -c
'record-supersession.md' corpus/README.md` must read at least 1 so the entry has
its coverage-map row. A flat count with an unchanged coverage map means the
round widened an entry and the expansion verdict was unearned — the QM100
defect.

## 5. Reproduction

- `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-69/capture/S168.body 'Merkle consistency proofs prove the append-only property of the tree.'` → count=1.
- `sha256sum .ufo/waves/round-69/capture/S168.body` → `a0e432ce…`, 128266 B.
- `grep -c 'mismatches 3 → 0' corpus/lessons/round-68.md` → 2;
  `grep -n '^## Correction (round 69)' corpus/lessons/round-68.md` → line 228.
- `sed -n '6p' .ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt` → the
  honest-stop receipt line.
- `grep -c 'mismatches=0 population=3 guard=1' corpus/claim-ledger.tsv` → 0;
  the same grep over `.ufo/waves/round-69/journals/expectation-migrations.json`
  → 1.
- `git ls-tree -r --name-only 264917aa corpus/knowledge` and the same at
  `cd9d66f1` → 48 paths each; the round-69 entry adds the 49th file, and
  `corpus/README.md` carries its coverage-map row.
- The bar that binds these rules is `corpus/QUALITY.md`: QM97 (append-only
  supersession), QM98 (instrument floors), QM99 (ledger-row production) and
  QM100 (trend observable), each naming `corpus/lessons/round-68.md` as its
  source.

## 6. Limits of this entry

- The mechanism is borrowed; the object is the lane's. RFC 9162's consistency
  proof is over a Merkle tree of certificate entries. The lane's records are
  not Merkle-structured, so the lane has no hash chain over its lessons: what it
  has is a named receipt beside a named correction, and a gate that reads both.
  The rule is a discipline backed by receipts, not a cryptographic proof of
  append-onlyness.
- The lane proves existence and value (bytes, digest, quote, receipt), never
  authorship or intent. A lane reading is a reading of committed bytes.
- The RFC is `Category: Experimental`. Nothing here is a standards obligation,
  and the transposition is the lane's own choice — a reader who rejects the
  transposition rejects this entry, not the RFC.
- The falsifiers are runnable today against the tree as committed; each names
  the tree state it depends on, so a later round that legitimately changes a
  surface will make a falsifier read differently. That is the intended
  behaviour: a falsifier that never moves is not a falsifier.
