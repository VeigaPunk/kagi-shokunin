# R69ScoutSource — frontier source opening (RFC 9162 / Wikipedia "Merkle tree")

SEAT-STATUS: complete

Scope: reconnaissance only. No lane file was written except this report and the
receipts directory named below. The registry rows, the fetch rows, the captures
and the knowledge entry are the registry scribe's to land; this report supplies
the measured facts they need.

Files written by this seat

- `.ufo/waves/round-69/w1/R69ScoutSource.md` (this report)
- `.ufo/waves/round-69/w1/R69ScoutSource/S168.fetch.txt` — RFC 9162 fetch receipt
- `.ufo/waves/round-69/w1/R69ScoutSource/S169.fetch.txt` — Wikipedia fetch receipt
- `.ufo/waves/round-69/w1/R69ScoutSource/rfc9162.body` — 128266 B, sha256 `a0e432ce…5081f`
- `.ufo/waves/round-69/w1/R69ScoutSource/merkle.body` — 209875 B, sha256 `ad8de3b9…6a27c`
- `.ufo/waves/round-69/w1/R69ScoutSource/locate-matrix.txt` — the locate / raw-grep matrix
- `.ufo/waves/round-69/w1/R69ScoutSource/adjacency-sweep.txt` — the lane sweep

Scratch (`${HYAKU_SCRATCH}/kagi-r69/R69ScoutSource/`) was deleted before this
report was finalised; every number below is reproducible from the receipts.

Tooling: none installed or upgraded this seat. `curl 8.23.0` (host binary) and
the lane's own `python3 corpus/rendered-text-v1.py` did the work; both are
already present, so the operator's tooling directive (channel order: pacman →
uv → release binary → cargo/npm) has nothing to do. No pacman transaction was
run — pacman is paused host-wide.

---

## 1. The two fetches

Both fetched with the lane's declared profile (`curl -fsSL --compressed`,
browser user agent `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36
(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36`), from
`/home/vgpnk/Projects/shokunin/kagi-shokunin`.

| | S168 candidate | S169 candidate |
|---|---|---|
| URL | `https://www.rfc-editor.org/rfc/rfc9162.txt` | `https://en.wikipedia.org/wiki/Merkle_tree` |
| HTTP status | **200** | **200** |
| final URL | unchanged | unchanged |
| content-type | `text/plain;charset=utf-8` | `text/html; charset=UTF-8` |
| decoded bytes | **128266** (gzip wire 35935) | **209875** (gzip wire 39619) |
| raw sha256 | **`a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f`** | **`ad8de3b95bd73e8bb93ac1bb37fb17f0c050e53660a1f5619dba1136bd36a27c`** |
| refetch | **byte-identical** (`cmp` rc 0) | **byte-identical** (`cmp` rc 0) |
| rendered-text-v1 normalized sha256 | `03802e0b592da2cf7f9e3f6e26c92b98a85791310fc752be2f1f1c1da505fbf5` (88723 B) | `b3c065eb8b12abc368ef9bc236edc31057fdcfe1e29df03715f10bc2815f4cbc` (17020 B) |

RFC 9162 self-identifies as *Request for Comments: 9162, Obsoletes: 6962,
Category: Experimental, ISSN 2070-1721, December 2021*; its body begins with a
UTF-8 BOM (`efbbbf`) and is 2962 lines.

The Wikipedia page carries `oldid=1383668961` and the text *"This page was last
edited on 4 November 2026, at 01:57 (UTC)"*. **One caution for the scribe:** the
revision permalink
`https://en.wikipedia.org/w/index.php?title=Merkle_tree&oldid=1383668961`
answers HTTP 200 but its decoded body is **213195 B, sha256
`94dcb50c3b3328d58815245d1eb4de39b0bab1942433fb1dcd4a72d130bc356f`** — *not*
byte-identical to the `/wiki/Merkle_tree` body (different rendered chrome), and
it is reproducible on its own (`cmp` rc 0 on a second fetch). If the row pins
the revision, the row must pin **one** of the two bodies and its digest; the
two digests are not interchangeable. This mirrors the lane's existing
Wikipedia precedent: S133 and S149 are both Wikipedia rows and S149 pins
`revision oldid=1373580212` in the anchor cell with a separate body digest.

---

## 2. Where RFC 9162 states the append-only property, and the located quotes

Measured: `grep -n 'append-only' rfc9162.body` returns **7 hits**, in five
sections. The property is *not* in §2.1 or §2.1.1:

```
$ sed -n '310,363p' rfc9162.body | grep -ci 'append'      # 2.1 + 2.1.1
0
```

`§2.1 Merkle Trees` and `§2.1.1 Definition of the Merkle Tree` (lines
310–363) contain **zero** occurrences of "append". The plan's frontier step
names "§2.1 / §2.1.1" as the section for the append-only property; that anchor
is not where the sentence lives. The sentence lives in **§2.1.4 Merkle
Consistency Proofs** (body line 475) and, as a general framing, in **§1
Introduction** (body lines 207–210). Both are reported here; the row's anchor
cell should name the section that actually carries the quote.

Occurrences, with their sections:

| body line | section | text |
|---|---|---|
| 160 | 1. Introduction | "…providing append-only logs of issued certificates." |
| 207 | 1. Introduction | "The append-only property of each log is achieved using Merkle Trees," |
| **475** | **2.1.4. Merkle Consistency Proofs** | **"Merkle consistency proofs prove the append-only property of the tree."** |
| 777 | 4. Log Format and Operation | "A log is a single, append-only Merkle Tree of submitted certificate…" |
| 2081 | 8.3. Auditing | "* the append-only property" |
| 2602 | 11.3. Misbehaving Logs | "Violation of the append-only property or the STH issuance rate limit" |
| 2609 | 11.3. Misbehaving Logs | "…proving violation of the append-only property." |

### Located quotes (lane normalizer, `python3 corpus/rendered-text-v1.py locate`)

Every quote below was run against this seat's own copy of the body:

| # | quote | words | section | locate count | raw byte-exact grep |
|---|---|---|---|---|---|
| Q1 | "Merkle consistency proofs prove the append-only property of the tree." | 10 | §2.1.4 (line 475) | **count=1** | **1** |
| Q2 | "any particular instance of the log is a superset of any particular previous instance" | 14 | §1 (lines 208–209) | **count=1** | 0 (RFC line wrap) |
| Q3 | "Note that this is a general mechanism that could be used for transparently logging any form of binary data" | 19 | §1 (lines 163–164) | **count=1** | 0 (RFC line wrap) |
| Q4 | "The append-only property of each log is achieved using Merkle Trees" | 11 | §1 (line 207) | **count=1** | 1 |
| Q5 | "there are four properties of log behavior that should be checked" | 11 | §8.3 (line 2074) | **count=1** | 0 (RFC line wrap) |
| Q6 | "Violation of the append-only property or the STH issuance rate limit" | 11 | §11.3 (line 2602) | **count=1** | 1 |

**Normalizer caveat, stated because it changes which quote the row may carry.**
The lane's `rendered-text-v1` tag rule (`<[^>]+>` → space, step 3) eats RFC
9162's ASN.1 and pseudo-code angle-bracket spans. Measured: the normalizer
removes **39 543 of 128 264 raw characters (30.8 %)** of this body, in 15
spans; the largest single swallowed span is **17 452 characters covering body
lines 536–953** (from `2.1.4.2 Verifying Consistency between Two Tree Heads`
through `4.4 Log ID`), because that region contains `<= n`, `< first < second`
and `opaque LogID<2..127>`. Consequences, measured:

- "A log is a single, append-only Merkle Tree of submitted certificate and
  precertificate entries." (§4, line 777) → **locate count=0** under
  rendered-text-v1; the byte-exact raw grep for the single line
  `"A log is a single, append-only Merkle Tree of submitted certificate"` is **1**
  and for `"and precertificate entries."` is **1**. The sentence is present in
  the raw bytes and absent from the normalized text.
- "the first m inputs D[0:m] are equal in both trees" (§2.1.4, line 479) →
  **locate count=0** under rendered-text-v1; raw grep for the single line
  `"first m inputs D[0:m] are equal in both trees"` is **1**.
- The two §1 sentences that carry the property's *substance* (Q2, Q3) are
  **RFC line-wrapped**, so raw byte-exact grep is 0 while rendered-text-v1
  count=1. Each half is byte-exact: `"Note that this is a general mechanism
  that"` = 1, `"could be used for transparently logging any form of binary
  data"` = 1, `"any particular instance"` = 1, `"of the log is a superset of
  any particular previous instance"` = 1.

So the RFC's own strongest sentences are the ones the lane's normalizer
**rescues** (Q2, Q3, Q5: raw grep 0, rendered count=1), while two sentences a
reader might prefer (the §4 log definition, the §2.1.4 tail) are the ones the
normalizer **destroys** (rendered count=0, raw grep 1). If the row declares
`rendered-text-v1` in fetch-row column 14, the quote must be one of the six in
the table above. If it declares `raw-literal-v1`, the quote must be
byte-exact on one line — Q1 and Q4 satisfy that; Q2, Q3, Q5 do not.

### Which sentences are strongest, and which do not transpose

**Strongest grounding (three sentences, in this order):**

1. **§2.1.4, line 475 — Q1.** *"Merkle consistency proofs prove the
   append-only property of the tree."* This is the single sentence that states
   the rule the round needs: the append-only property is not asserted, it is
   **proved**, and the proof object is a consistency proof between two tree
   heads. It is 10 words, on one physical line, and locates under both
   normalizations (rendered count=1, raw grep=1). It is also exactly the shape
   the round's C1 claim needs: C1's L3/L4/L5 require an appended
   `Correction (round 69)` block that names the superseded text while the
   original bytes stay present — the same shape as "the later state is
   verified against the earlier state", not "the earlier state is replaced".
2. **§1, lines 207–210 — Q4+Q2.** *"The append-only property of each log is
   achieved using Merkle Trees, which can be used to efficiently prove that
   any particular instance of the log is a superset of any particular previous
   instance…"* This is the **superset** semantics — the later state *contains*
   the earlier state. It grounds the append-only rule in a content relation
   (containment), not in a file-format convention, which is what makes it
   transpose to a lesson/LOG/ledger record. Locate count=1 rendered, raw grep
   0 (wrapped).
3. **§1, lines 163–164 — Q3.** *"Note that this is a general mechanism that
   could be used for transparently logging any form of binary data, subject to
   some kind of inclusion criteria."* The RFC itself says the mechanism is
   general and only the *use* is certificate-specific ("In this document, we
   only describe its use for public TLS server certificates"). This is the
   sentence that licenses the transposition away from certificates to the
   lane's own record surfaces. Locate count=1 rendered, raw grep 0 (wrapped).

**Does NOT transpose (certificate-specific; must not be the grounding):**

- §1 line 160 — "…append-only logs of **issued certificates**." The purpose
  clause, not the mechanism.
- §4 line 777 — "A log is a single, append-only Merkle Tree of **submitted
  certificate and precertificate entries**." CT's entry types; a record
  surface is not a submitted certificate. (Also the sentence the normalizer
  drops — see the caveat above.)
- §8.3 line 2081 — the append-only property as one of *four CT log-behaviour
  properties* alongside MMD, STH Frequency Count and log-view consistency.
  Transposing the whole bullet list would import CT's monitoring regime.
- §11.3 lines 2602/2609 — misbehaving-log detection against an **STH issuance
  rate limit**. CT's rate-limit policy is not the lane's rule.
- The whole of §2.1.4.2's verification algorithm (lines 536–580) — LSB
  arithmetic over two tree heads. It is the *shape* of the obligation (prove
  the earlier head is a prefix of the later), not the algorithm, that
  transposes; the algorithm is CT's Merkle variant and the lane has no Merkle
  tree.

---

## 3. Wikipedia "Merkle tree" — S169

Locate counts under the lane normalizer, all `count=1`:

| quote | words | locate count | raw byte-exact grep |
|---|---|---|---|
| "One simple fix is defined in Certificate Transparency" | 8 | 1 | 0 (the article wraps the linked title in an `<a …>` tag) |
| "the Certificate Transparency framework" | 4 | 1 | 0 (same) |
| "A Merkle tree is therefore an efficient example of a cryptographic commitment scheme" | 13 | 1 | 0 |
| "A hash tree allows efficient and secure verification of the contents of a large data structure" | 16 | 1 | 0 |

The absence sweep over the article's rendered text is the decisive measurement:

```
append-only   0      consistency   0      MUST   0
append        0      superset      0      SHOULD 0
proof         2      RFC           1 (RFC6962, in the reference list)
Certificate Transparency  3
```

The article **never states an append-only property**, never mentions
consistency proofs, never mentions a superset relation, and carries zero
normative keywords. It names Certificate Transparency three times: once in the
uses list ("the Certificate Transparency framework"), once in the second-preimage
section ("One simple fix is defined in Certificate Transparency"), and once as
the reference to RFC 6962. Its two "proof" hits are the second-preimage
discussion, not a proof obligation.

---

## 4. The lane's own answers

### (a) Does any existing registry row already carry this rule?

**No.** `grep -niE 'append.only|merkle|consistency proof' corpus/SOURCES.md`
returns exactly **one** line — row **S094**, the lane's own `own-work` row for
the fleet `CORPUS.md`:

> `| S094 | CORPUS.md — https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba…/CORPUS.md | own-work | A | registry append-only discipline: which cells may change in place | SOURCES.md Rules item 2, line 116, revision f47ad6ba… | Only status, recheck and used-by change in place; an in-place anchor rewrite violates this rule | mined | 2026-11-05 | 90d | corpus/lessons/round-39.md, corpus/lessons/round-42.md, corpus/lessons/round-43.md |`

Counts over the whole registry: `merkle` = **0**, `consistency proof` = **0**,
`append-only` = **1** (S094). Twenty-nine registry rows carry the word
"supersede" — but every one of them uses it in the *row-supersession* sense
("supersedes S0NN —" opening a `teaches` cell), which is the registry's own
row-replacement convention, not a rule about superseding a *record*.

So S168 would be the lane's first registry row grounding an append-only /
consistency-proof rule from an external primary source, and the first row
whose subject is a **record** rather than a registry cell.

### (b) Does any existing knowledge entry already state a supersession rule?

**No — but two entries state the closest passages.** Read as asked:

**`corpus/knowledge/claim-instrument-carrier-binding.md`, §4 "The repair that
landed, and what it did not touch" (lines 112–121) — the closest passage in the
corpus:**

> "The correction is a **binding** change, never a rename, and never an edit
> to the superseded row:
>
> * `S148`'s row text is preserved **verbatim** — `git diff` of that row
>   between `8abab0f` and the candidate tree is empty."

This is the lane's only *stated* supersession rule inside `corpus/knowledge/`.
It is scoped to **one registry row** (S148 → S164) and to a **binding change**
(a capture path/digest), not to a general rule about record surfaces.

**`corpus/knowledge/source-capture-binding.md` — the closest passage is §1's
narrowing record, lines 62–75.** That file contains **zero** occurrences of
"supersed" (measured `grep -c 'supersed'` → 0). Its closest passage is the
passage that records a *widening* of a rule and an in-place recut of one cell:

> "Under the old rule the classifier asked only 'is this string shaped like a
> path?', and anything else was prose and was silently skipped. … The widened
> rule cannot be escaped that way, because it classifies on what the cell
> *mentions*, not on whether the cell happens to match a shape: a cell that
> mentions a lane capture is bound to it, so a cell that mentions one and is
> not exactly that path is refused rather than skipped. S166's own cell was the
> proof that this matters … the round-68 landing recuts that cell to the pure
> path."

i.e. that entry documents how a rule was *widened* and how one cell was
*recut in place* — the opposite of an append-only supersession rule, and it
never states one.

Two further adjacent statements exist outside `corpus/knowledge/`:
`corpus/knowledge/claim-ledger.md:502-504` ("append-only old/new migration
evidence belongs in the round lesson and journal. Duplicate active rows are not
a valid way to preserve history.") and `corpus/knowledge/negation-scope-grammar.md:57-59`
("a quotation of the superseded text is not the correction's own assertion").

### (c) Is the lane's supersession practice a stated RULE or only PRACTISED?

**Both, but never as an *external-grounded* rule for record surfaces, and never
covering the property C1 actually measures.** This is a partial rule state, and
the honest reading matters for the frontier step.

Where a rule *is* stated:

- **Fleet root** `CORPUS.md` §Rules item 2 (line 116) — the authoritative
  registry rule: *"**Append-only.** Only `status`, `recheck` and `used-by`
  change in place, and each change is logged old→new in the round lesson. A
  correction is a new row whose `teaches` opens `supersedes S0NN —`."*
  Registered as S094. **This governs registry rows only** — it says nothing
  about lesson/LOG/ledger records.
- **Fleet root** `PROTOCOL.md:366` — *"A falsified claim in an append-only file
  gets a named correction entry in the lane's next round — appended, never
  rewritten; it stays on the routed-defect queue until it lands."* This is the
  rule C1's L3/L4/L5 would enforce, but it lives in the fleet root and no lane
  instrument reads it.
- **`corpus/QUALITY.md:8-9`** — *"Criteria are append-only: a criterion is
  superseded by a new row that names the row it replaces, never rewritten."*
  Scoped to *criteria*.
- **`corpus/QUALITY.md` QM78** (line 276) — the closest existing lane-side
  statement of the rule C1 needs, and the row I did not find on the first
  sweep: *"A correction that supersedes a record line states the measured
  values it substitutes and the command that derived each one; a correction
  whose numbers are copied from a plan, a report or an earlier correction is a
  second record defect, not a repair. **The superseded text stays and the
  correction points at it.**"* (cites `corpus/lessons/round-61.md`
  §Mistakes M61-1/M61-2 and the L1 corrections; the seven round-60
  corrections each name their derivation — `corpus/lessons/round-60.md:176-180`,
  `LOG.md:1982`).
  QM78 states the *discipline* ("the superseded text stays and the correction
  points at it") but not the *mechanism* the frontier step would ground: it
  says nothing about an append-only extension being **verifiable** against the
  earlier state, and it has no external source row.
- **`corpus/QUALITY.md` QM17** (line 99) — a review Gate must record each
  admitted, rejected, superseded/demoted or withdrawn candidate with its
  decision and basis. **QM50** (line 233) — a supersession path a counter cites
  must resolve to a blob at the named candidate revision. **QM40** (line 208) —
  a superseded release-feed row's anchor cell is bound to a committed sha256
  pin and an in-place rewrite of it is reported. **QM80/QM83** mention
  "superseded"/"not rewritten in place" only as *negation tokens* for the
  polarity checker.
- **`corpus/knowledge/claim-ledger.md:502-504`** — *"The active TSV files are
  unique-ID/unique-path **current snapshots**; append-only old/new migration
  evidence belongs in the round lesson and journal. Duplicate active rows are
  not a valid way to preserve history."*

What is **not** stated anywhere, and is what S168 would ground:

- No registry row carries the rule: `merkle` = 0, `consistency proof` = 0,
  `append-only` = 1 (S094, own-work, registry cells only). No **external,
  primary** source grounds the append-only property or any proof obligation.
- No `QUALITY.md` criterion states that a supersession must be **provable** —
  that the later state is an append-only extension of the earlier one, checked
  rather than asserted. QM78 requires the correction to *name its derivation*
  (provenance of its numbers), which is a different property: a correction may
  name a command that re-derives its figures and still restate the superseded
  sentence in place.
- `corpus/README.md` coverage-map rows naming supersession / append-only /
  record-supersession: **0**.
- `corpus/knowledge/` has **48** `.md` files at HEAD and **48** at BASE
  `264917aa8fc9e71b6595d0d5166c4b615120fb8b`; none is named
  `record-supersession.md` or matches `record*`/`supersess*`. The entry the
  plan names as the round's expansion product does not yet exist.

Where the practice lives in the lane (measured counts):

- `Correction (round NN)` blocks: **7** lesson files carry one (round-51, -52,
  -52-verifier-spotcheck, -58, -59, -60, -68); **3** carry it as a
  `## Correction (round NN)` heading (round-58, -60, -68).
- `Supersession note (append-only entry):` blocks: **2** knowledge entries
  (sops-age-key-rotation.md, vault-openbao-token-lease-lifecycle.md).
- `QUALITY.md` criteria naming a `Correction (round NN)` block: **0**
  (`grep -c 'Correction (round' corpus/QUALITY.md` → 0) — the convention
  itself is practised 7 times and named by no criterion.

**Answer to the sweep question:** the lane's supersession practice is
**partly stated and mostly practised**. QM78 states the discipline (the
superseded text stays; the correction points at it) and QM17/QM50/QM40 cover
adjacent registry-side mechanics; `CORPUS.md` rule 2 (S094) and
`PROTOCOL.md:366` state the governing rules for registry cells and for
append-only files respectively. What is missing — and what S168 plus the
planned `corpus/knowledge/record-supersession.md` would supply — is an
**externally grounded** statement of the append-only-extension property with
its **proof obligation** attached, for the record surfaces C1 measures, and a
coverage-map row and a registry row for it. As it stands the lane's rule is
`own-work` + fleet-protocol + one criterion, with zero external source row.

---

## 5. Decision

### S168 — **ADMIT**

RFC 9162 (Certificate Transparency v2), `https://www.rfc-editor.org/rfc/rfc9162.txt`,
opened 2026-11-08 with a browser user agent, HTTP 200, decoded body 128266 B,
raw sha256 `a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f`,
byte-identical on refetch.

- **Located quote (≤25 words, locates):** "Merkle consistency proofs prove the
  append-only property of the tree." — 10 words, **§2.1.4 Merkle Consistency
  Proofs**, body line 475. Locate under the lane's normalizer:
  `python3 corpus/rendered-text-v1.py locate <copy> '<quote>'` ⇒
  `RENDERED_TEXT_V1_LOCATE: count=1` (rc 0). Byte-exact raw grep is also 1, so
  the quote is safe under **either** declared normalization.
- **Second and third supporting quotes (same body, both locate count=1):**
  "any particular instance of the log is a superset of any particular previous
  instance" (§1, lines 208–209 — the containment relation) and "Note that this
  is a general mechanism that could be used for transparently logging any form
  of binary data" (§1, lines 163–164 — the RFC's own statement that the
  mechanism is general and only its use is certificate-specific). Both are RFC
  line-wrapped: rendered-text-v1 count=1, byte-exact raw grep 0.
- **Anchor correction the scribe must make:** the plan's frontier step names
  "§2.1 / §2.1.1" for this property. Those sections contain **zero**
  occurrences of "append" (measured). The property sentence is in **§2.1.4**
  (line 475); §1 (lines 163–164, 207–210) carries the framing. The row's
  anchor cell should name §2.1.4 (and §1 if the general-mechanism quote is
  carried).
- **Fetch-row shape the census will demand** (from `corpus/sources-census.sh`
  lines 529–560, read not guessed): col 6 `200`; col 7
  `curl-fsSL-compressed-v1`; col 9 `decoded-http-body-v1`; col 10 the raw
  sha256 above; col 11 `128266`; col 13 the quote (≤25 words, enforced at
  `words -le 25`); col 14 `rendered-text-v1`; col 15 the **recomputed**
  normalized digest `03802e0b592da2cf7f9e3f6e26c92b98a85791310fc752be2f1f1c1da505fbf5`;
  col 16 a pure `.ufo/waves/…` capture path (the census binds path → digest →
  bytes → quote → normalized digest, and a prose or mixed cell is a
  `capture-token` defect). Col 3 must be the row-identity digest of
  `id\tstatus\turl` — verified by reproducing S167's committed value
  (`7b4c8e2b…0d4dd`) with the same formula.
- **Kind/tier:** `spec` / `A`, matching the lane's other RFC rows (S052
  RFC 4287, S166 RFC 9530, S167 RFC 4648 — all `spec`/`A`).
- **Recheck cadence:** the RFC is immutable (Obsoletes 6962, December 2021) —
  `on-release` is the lane's convention for such clocks; `180d` is also
  defensible. Flagged, not decided: the scribe owns the cell.
- **Status:** `mined`.

### S169 — **REJECT**

Wikipedia "Merkle tree", `https://en.wikipedia.org/wiki/Merkle_tree`, opened
2026-11-08 with a browser user agent, HTTP 200, decoded body 209875 B, raw
sha256 `ad8de3b95bd73e8bb93ac1bb37fb17f0c050e53660a1f5619dba1136bd36a27c`,
byte-identical on refetch, revision `oldid=1383668961`.

- **Reason:** the article is a tertiary, community-edited summary with **no
  normative mechanism and no consistency-proof obligation**. Measured over
  its rendered text: `append-only` **0**, `append` **0**, `consistency` **0**,
  `superset` **0**, `MUST` **0**, `SHOULD` **0**. It names Certificate
  Transparency three times and cites RFC 6962 once, but never states the
  append-only property and never states that any proof is owed. It therefore
  cannot ground the rule S168 grounds, and it is the wrong authority for the
  lane's own admission bar (`corpus/QUALITY.md` QA1: "A tier C row never
  stands alone"; a community row is never tier A — the fleet census's E10).
- **Located quote (≤25 words, locates) for the reject row:** "One simple fix
  is defined in Certificate Transparency" — 8 words, §Second preimage attack;
  `RENDERED_TEXT_V1_LOCATE: count=1` (rc 0). Byte-exact raw grep is 0 because
  the article wraps the linked title in an `<a …>` tag (raw window: `One
  simple fix is defined in <a rel="mw:WikiLink" href="…/Certificate_Transparency"
  title="Certificate Transparency" id="mwug">Certificate Transparency<`), so the
  row must declare `rendered-text-v1`, not `raw-literal-v1`. The quote also
  names the flip directly — the article's own pointer is to Certificate
  Transparency, i.e. to the RFC.
- **Flip:** the article defers to Certificate Transparency for the normative
  mechanism — *"One simple fix is defined in Certificate Transparency"* — and
  its own reference list names RFC 6962. The flip condition is therefore
  stated as: cite RFC 9162 (§2.1.4 and §1) instead; the flip is discharged by
  the admitted S168 row, and the article remains a lead that points at it, not
  a source the registry mines.
- **Kind/tier/status:** `community` / `C` / `rejected`, matching the lane's
  two existing Wikipedia rows S133 and S149 (both `community`/`C`, both
  `rejected`, S149 pinning `revision oldid=1373580212` in the anchor cell).
- **Id freedom:** ids S168 and S169 are unused — registry `grep -c '^| S16[89] '`
  = 0, fetch ledger `grep -c '^S16[89]\t'` = 0.

### Adjacency note for the entry the plan names (coverage/adjacency axis)

The plan's expansion product is a new entry `corpus/knowledge/record-supersession.md`
("the entry is the round's expansion product, not a claim"). Measured
adjacency for that entry:

- It does **not** exist at BASE or HEAD (§4 above), and no coverage-map row in
  `corpus/README.md` names supersession, append-only or record-supersession
  (0 hits) — so on the `LEARNING.md` §3 expansion observable ("admitted
  `knowledge/` entries on ground the coverage map did not hold") the ground is
  genuinely uncovered.
- It must **not** restate QM78. QM78 already owns "the superseded text stays
  and the correction points at it"; the new entry's added content is the
  *external grounding* of the append-only-extension property and its *proof
  obligation* (S168 §2.1.4: consistency proofs prove the append-only property;
  §1: the later instance is a superset of any previous one), plus the
  binding rule S168 does **not** supply — how the lane proves its own
  append-only property over a record surface. That binding is the open part,
  and it belongs to the instrument seat, not to the source row.
- It must not duplicate S094 (`CORPUS.md` rule 2, own-work, registry cells) or
  QM17/QM40/QM50 (registry-side mechanics); S168's subject is the *record*
  class, which no existing row or entry covers.
- It must name S168 in its `source:`/`cites:` header and S168's `used-by` must
  name the entry, or the lane census reads `SC_ENTRY_CITE` /
  `SC_USEDBY_NOCITE` (both directions are checked, `corpus/sources-census.sh`
  lines 609–640).

---

## 6. What the registry scribe must not inherit from this report

1. **Do not carry "§2.1 / §2.1.1" as the S168 anchor.** Those sections carry
   zero "append" occurrences; use §2.1.4 (and §1).
2. **Do not carry a §4 or §2.1.4-tail quote under `rendered-text-v1`.** Both
   are destroyed by the lane normalizer's tag rule (locate count=0) although
   they are present in the raw bytes. Q1 is the quote that survives both
   normalizations.
3. **Do not mix the two Wikipedia bodies.** `/wiki/Merkle_tree` (209875 B,
   `ad8de3b9…`) and `?oldid=1383668961` (213195 B, `94dcb50c…`) are different
   byte strings; a row pinning the revision must pin the permalink's digest,
   and a row pinning the article URL must pin the article's digest.
4. **Do not read the lane's `kagi ok` census as a statement about this
   report.** `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
   printed `kagi ok /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`,
   rc 0, with 25 W04 duplicate-URL warnings (historical, unchanged by this
   seat). The
   lane's own gate `bash corpus/sources-census.sh` printed
   `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)` and
   `SOURCES_CENSUS: CLEAN (rows=158 …)`, rc 0 — measured at BASE/HEAD state,
   **before** any S168/S169 row exists. A new row changes both counts; the
   scribe re-runs both.
5. **`corpus/knowledge/record-supersession.md` does not exist.** The plan names
   it as the round's expansion product; at BASE and at HEAD
   `corpus/knowledge/` holds 48 `.md` files and none matches
   `record*`/`supersess*`. The census requires a `mined` row's `used-by` to
   name an existing file that cites the row id, so the row and the entry must
   land together or the census reads `SC_USEDBY_MISSING` / `SC_USEDBY_NOCITE`.

## 7. Dead ends and measurements that did not pay off (reported as required)

- **`corpus/laneguard.sh run -- kagi -- …` → `LANE_GUARD: SETUP not-a-repo
  kagi`** (rc 0). The lane id is not a git repo name here; the guard wants a
  path. Not pursued; the two censuses above are the lane's own gates.
- **Reading the RFC's own TOC for the §2.1.4 body text** — the normalizer
  collapses the double space in headings, so `n.find('2.1.4.  Merkle
  Consistency Proofs')` returns -1 on the normalized text (it matches the
  *table of contents* occurrence with single spacing first). The body copy
  was located by raw line numbers instead. Dead end, no effect on the result.
- **Locating the §2.1.4.2 algorithm text under the normalizer** — impossible
  for the same tag-swallow reason (the whole 17 452-char span is gone). The
  raw single-line fragments were used instead and are recorded in
  `locate-matrix.txt`.
- **The `oldid` permalink as a drop-in replacement for the article body** —
  rejected: the two bodies differ in size and digest, so a row cannot carry
  one URL and the other body's digest.
- **`grep -n 'consistency' merkle.body`** → 0, and `'append'` → 0. This is the
  measurement that decided S169, not a style judgment.
