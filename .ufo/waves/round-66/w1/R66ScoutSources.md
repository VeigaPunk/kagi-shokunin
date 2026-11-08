# R66ScoutSources — round 66 frontier source scout (kagi)

Seat: `R66ScoutSources` (scout; axes freshness, coverage). Lane `kagi-shokunin`,
branch master, claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`. Frozen plan
`plans/round-66.md` (landed `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`). Access
date for every page opened: **2026-11-08**.

Full ledger with located quotes, digests and judgments:
`.ufo/waves/round-66/w1/R66ScoutSources/notes.md`. Receipts (manifest, the exact
fetch script, and every stored body) sit beside it in the same directory.

**Axes.** freshness — do the two carriers this round's C1 binds still serve the
bytes their registry rows pin? coverage — does the registry hold the grounds the
three claims rest on, and does the frontier carry a source the registry lacks?

---

## 1. What I produced

| artifact | path |
|---|---|
| source ledger (located quotes, judgments, cross-measurements) | `.ufo/waves/round-66/w1/R66ScoutSources/notes.md` |
| fetch manifest (status, bytes, sha256, final URL, timestamp) | `…/R66ScoutSources/manifest.tsv` |
| the exact fetch script used (re-runnable) | `…/R66ScoutSources/fetch.sh` |
| captured bodies (7) | `…/R66ScoutSources/S148_bioc.body`, `S155_eutils.body`, `S156_429.body`, `LEAD_springer_challenge.body`, `LEAD_dlacm_403.body`, `CAND_arxiv2404_abs.body`, `CAND_arxiv2404_html.body` |

Every fetch used the lane's declared profile
`curl -sS -L --compressed -A '<desktop Chrome UA>'`; digests are over curl's
decoded body (`decoded-http-body-v1`). Quotes located with the lane's own
`corpus/rendered-text-v1.py locate` (the only normalizer the census accepts).
No lane file was edited; the census repair in §4 was executed only in scratch
copies of the tree.

## 2. Frontier step 1 — the BioC deposit re-opened (the C1 carrier)

**ADMIT.** `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode`
— HTTP 200, **264946 B**, sha256
`3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`.

> Quote (17 words): `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., "no increase", "not cause")`
> — §3.1.2 (BioC XML), byte 19131, passage 27 of 182 — `count=1`

**The load-bearing measurement: the served bytes did not drift.** The live body
is byte-identical (`cmp`, no differences) to the committed capture
`.ufo/waves/round-64/capture/S143.body` and to the S148 registry pin; shape
re-measured as `<passage>` 182, `<text>` 180, one `<date>20261108</date>`.

Consequence for the plan: *"a `supersedes S148 —` row if the shape changed since
the 2026-11-08 capture"* is **not** met by content drift. The superseding row the
C1 carrier repair requires carries **the same pin**; what changes is the
*binding* — which committed capture path the row names — not the bytes. The
C1 counter's live leg should read `live_status=200 rate_limited=0`: my first
isolated request of the session returned 200 with the pin sha256.

## 3. Frontier step 2 — the eutils EFetch carrier (S155's URL)

**ADMIT as a recheck refresh of S155; no new registry row.**
`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml`
— HTTP 200, **189603 B**, sha256
`cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`.

> Quote (17 words): the same §3.1.2 sentence, verbatim — §3.1.2 (PMC XML,
> `<sec id="S6">` at byte 21584), quote at byte 23669 — `count=1`

The digest still matches **S135's pin** exactly, so the plan's condition
*"recheck refresh if the digest still matches S135's pin"* holds; the served body
is byte-identical to `.ufo/waves/round-63/capture/S135.body`. **Caveat for the
writer:** in the raw XML the sentence is interrupted by
`<italic toggle="yes">negated</italic>`, so the quote locates only under
`rendered-text-v1` (raw-literal locate → 0). Keep the normalization field
`rendered-text-v1` with normalized digest
`5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801`.

## 4. Frontier step 3 — the equivalent-mutant state-of-the-art page (the weak lead)

**REJECT — SpringerLink, "A Comprehensive Review on Equivalent Mutant Detection
Using Machine Learning"** (IWSC 2025, DOI `10.1007/978-3-031-92474-3_4`),
`https://link.springer.com/chapter/10.1007/978-3-031-92474-3_4` — HTTP 200, 3038 B,
sha256 `32ed63159c77e21ee19ca1b9aa3213ccf0218eb59539560b132a8e68ef0e18ea`.

> Quote (2 words, the served body under the lane's declared profile): `Client Challenge`
> — the document `<title>` — `count=1`; the body carries **0** occurrences of `equivalent mutant`

Three measured reasons, any one sufficient: (i) under the declared desktop-browser
profile the carrier serves a JavaScript interstitial, not the chapter; (ii) with a
plain curl agent it does serve the abstract (18-word quote `equivalent mutants,
which are code changes that do not alter program behavior, making detection
computationally expensive and undecidable` locating `count=1`), but two
consecutive fetches differ by **116 bytes** — a rotating `_csrf` token — so there
is no reproducible sha256 to pin; (iii) the full text is paywalled, and the one
substantive sentence it adds (detection is undecidable) the registry already
holds from S146 §5.3.1. Flip: a 200 serving the chapter's text as static HTML
under the declared profile with a byte-stable body.

**REJECT — the ACM DL record** for the ISSTA '24 equivalent-mutants paper,
`https://dl.acm.org/doi/10.1145/3650212.3680310` — HTTP **403**, 5684 B.

> Quote (8 words, the served body): `Just a moment... Enable JavaScript and cookies to continue`
> — `count=1`; **0** occurrences of `equivalent mutant`

A bot wall grounds nothing, and the paper is already mined as **S145** from the
authors' own PDF — the same class as the round-64 rejected IEEE records. Flip:
ACM serving the record's abstract as static HTML.

**ADMIT candidate found while sweeping (outside the plan's frozen triple) —
Straubinger, Degenhart & Fraser, "An Empirical Evaluation of Manually Created
Equivalent Mutants"**, `https://arxiv.org/abs/2404.09241` — HTTP 200, 40386 B,
sha256 `4bcb20b23ad5046657a65a29595517da973128a289ff75ba13ad8926c5511a80`
(abs page) and `b5d93658f6349c67f2396a1be5795632f93bdf4af9ed0703c15aadc0a2dcc898`
(HTML full text) — **both digests stable across two consecutive fetches**.

> Quote (15 words): `equivalent mutants, i.e., mutants that differ only in syntax but not semantics, hamper this process`
> — §Abstract (arXiv abs page; abstract blockquote at byte 5826) — `count=1`
> Second quote (9 words): `less than 10 % of manually created mutants are equivalent`
> — §Abstract — `count=1` **only in this spelling**: the abs page renders the
> percentage spaced (`10 %`), the HTML unspaced (`10%`); each locates 0 in the other.

The registry holds **0** occurrences of `Straubinger`, `Code Defenders`,
`Manually Created` or `2404.09241`. Its equivalent-mutant ground (S137/S139/
S140/S145/S146/S147) is entirely about *tool-generated* mutants; this row adds
the human-authored side and its rate bound, directly usable against S137's
"4% to 39%" tool-generated range. I verified in a scratch copy that appending it
as a `queued` tier-A `spec` row plus its fetch row keeps the lane census
`CLEAN (rows=156 …)`. **Bound:** the arXiv page states no venue and DBLP was
bot-walled here (HTTP 202), so I could not verify the venue from a primary
record — do not write a venue into the row without one.

## 5. Four cross-measurements the L1 and the C1/C3 seats need

**M1 — the lane's own census reads FAILED at BASE; the fleet script reads `ok`.**
`bash corpus/sources-census.sh` on the lane tree at BASE (extracted read-only
via `git archive` for both `d549ee6` and `ddcd46bb`):

```
FINDING SC_FETCH id=S156 missing-provenance
FINDING SC_FETCH id=S155 missing-provenance
FINDING SC_BODY_CITE entry=corpus/knowledge/claim-instrument-class-matrix.md id=S148 unrecorded
FINDING SC_BODY_CITE entry=corpus/knowledge/claim-instrument-class-matrix.md id=S156 unrecorded
SOURCES_CENSUS: FAILED (findings=4 rows=155)
```

The fleet script `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh
validate --root /home/vgpnk/Projects/shokunin kagi` prints `kagi ok` rc 0 on the
same tree (24 W04 duplicate-URL warnings only). The plan's BASE census line
quotes the **fleet** script, but the C1 guard (d) and C3 K4 name the **lane**
script's verdict token `SOURCES_CENSUS: CLEAN` — so at BASE those guards cannot
read CLEAN. Minimal repair, **measured to reach CLEAN** in a scratch copy (lane
repo untouched): append two 16-column rows to `corpus/source-fetches.tsv` for
`S155` (status `mined`) and `S156` (status `rejected`) — the row-identity digest
is `sha256("<id>\t<status>\t<url>\n")`, a formula I verified reproduces the
committed digests of S135/S148/S151 byte-for-byte; pre-computed
`S155` rid `2836a65b4d0289cbcedae2ee8ea98ae0010ce1287d43a56086a98920e067da08`,
`S156` rid `f9e69eccea5a30860e2f9ed118385afbec0d657425040d55305c7f170f1a98e1` —
and add `cites: S148, S156` to
`corpus/knowledge/claim-instrument-class-matrix.md` with that entry listed in
the `S148`/`S156` `used-by` cells. After both steps:
`SOURCES_CENSUS: CLEAN (rows=155 A=138 B=2 C=15 queued=3 mined=135 rejected=17
entries_sourced=25 legacy=21 captures=155 inrow=16 inrow_only=0
inrow_nonreproducing=12)`, fleet script still `ok`; with the §4 arXiv row added
too, `CLEAN (rows=156 A=139 B=2 C=15 queued=4 …)`.

**M2 — the S156 429 body is live-reproducible and was never committed as bytes.**
The round-65 capture pair `bioc-429-first.txt` (211 B) / `-second.txt` (137 B)
*describe* the 429 body; their own digests are `dcac2eea…` / `bfee41d3…`, not the
pin the S156 row records (`037c2dbe…`, 899 B), and those 899 bytes are nowhere in
the tree. I reproduced them today: a burst of six requests to the BioC URL gave
**429 / 899 B / sha256 `037c2dbe610ab2a6516d0f0916f7ad3cdfe016739186de59e5eaecd7043d00ba`**
on attempt 1, then HTTP 200 with the pin sha256 on attempts 2–6. The bytes are now
in `…/R66ScoutSources/S156_429.body` — that file is what a provenance row for
S156 must point at, and the burst result shows the carrier's 429 is
burst-dependent, not persistent.

**M3 — the round-64 capture filenames are handles, not registry ids: 11 of 20
resolve to another row's bytes.** Measured by sha256 over every
`.ufo/waves/round-64/capture/*.body` against the registry ids' fetch digests:
`S143.body` holds **S148's** bytes (`3b8d4e15…`); `S148.body` holds **S152's**
bytes (`fabc74c5…`, an unrelated arXiv QAOA body); `S145→S150`, `S146→S129`,
`S147→S128`, `S150→S154`, `S151→S147`, `S153→S146`, `S154→S145`, `S156→S151`,
`S157→S153`; only `S149.body` matches its own name; `S152/S155/S158–S163` match
no registry row. A reader who resolves a registry id to a capture **path** by
filename lands on another row's body in 11 of 20 cases. That is the size of the
class C1's digest binding fixes, and it is why C1/C3 must resolve carriers by
digest, never by name. (The offset is round 64's known handle-allocation
artefact, not a new defect; it is measured here because the claim depends on it.)

**M4 — no census leg can see the borrowed-identity class; the C1 counter can.**
Measured on a scratch copy of the L1's *current* tree (which reads
`SOURCES_CENSUS: CLEAN rows=156`): I repointed S164's fetch-row column 16 away
from `.ufo/waves/round-64/capture/S143.body` to a path holding **S152's arXiv
QAOA body** (`fabc74c5…`, 39750 B) while the row still declares `3b8d4e15…`
(264946 B).

| instrument | reading on the mis-pointed tree |
|---|---|
| lane gate `corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=156 …)` — **blind** |
| fleet wrapper `scripts/sources-census.sh` | `file ok` — **blind** |
| `plans/round-66-c1.sh --tree <t> --base-tree <b>` | `diag fetches:digest-mismatch:…/S164.body`, `match=0 drift=0 guard=0` rc 1 — **catches it** |

The mechanism is in the gate's source: its only capture-related check is
`[[ ${#floc} -ge 8 ]]` — the **length of the location string** — and it never
hashes the file the location names (`grep -cE 'sha256sum .*(capture|body)'` ⇒
**0**). The only leg comparing a declared digest against capture bytes is the
`inrow-pins` classification, bounded to `S001`–`S016` (`HIST_RE`), the
historical set whose rows may self-certify with a bare in-row pin. So M3's class
is real but invisible to both censuses; C1's digest resolution sees it, and sees
the anchor cell and the fetch column independently (the mis-pointed tree yields a
`fetches:digest-mismatch` while `registry:` stays clean — the second-anchor
leg). The round-67 lead can therefore be built on C1's existing resolution
rather than on a new census leg.

## 6. Coverage / freshness summary

* **Freshness.** Both carriers this round binds were re-opened live today and
  their digests are unchanged: the BioC deposit serves exactly the bytes the
  S148 pin names, and the eutils carrier still matches S135's pin. The C1
  carrier's live re-open should read 200, not a rate-limit.
* **Coverage.** The registry's equivalent-mutant ground is entirely about
  *tool-generated* mutants; the manually-created rate (<10 %) is uncovered and
  now has a stable, located, open-access peer-reviewed-adjacent source
  (arXiv:2404.09241), which the registry holds zero rows on.
* **Quality of the evidence.** Every quote in the ledger resolves with
  `count=1` under the lane's normalizer; every digest is recorded with the
  fetch that produced it; both new-candidate digests were reproduced across two
  consecutive fetches, and the two rejected carriers' instability was measured
  rather than assumed.
* **Gaps named, not papered over.** The SpringerLink chapter is genuinely
  peer-reviewed and openable under a different agent, but it cannot be pinned
  (116-byte per-response token rotation) and is abstract-only behind a
  paywall; the ACM record is a bot wall over ground S145 already holds; the
  arXiv page states no venue and DBLP was bot-walled, so the venue is
  unverified. The lane census reads FAILED at BASE, and the plan's C1/C3 guard
  tokens are the lane script's, not the fleet script's.

## 7. Bounds

* The live re-open is reported, never decisive: a 429 is `rate_limited=1`, never
  a verdict change (round-65 Amendment A1 precedent). My burst probe confirms
  the 429 body byte-for-byte but the row stays `rejected` — the flip is a 200
  serving the deposit, which has now been observed.
* The venue of arXiv:2404.09241 is **unverified** from a primary record on this
  host (DBLP bot-walled, HTTP 202); the arXiv page carries no venue statement.
* The SpringerLink chapter's abstract was located only under a non-declared
  user agent; the stored receipt is the declared-profile challenge shell.
* Registry ids are the L1's to mint; `S157` is used above only as a proposal.
* No package was adopted this round; `merge/kagi/` stays unadopted (recorded in
  the report's Sources & frontier section by the L1, no penalty). No
  `considerthese` proposal was mined this round — proposal 3 was mined in round
  63 (QM83/QM84), so the file stays unmined.

## 8. Secret discipline

No `set-cookie`/`cookie` value, CSRF token, clearance cookie or API key is
stored in any receipt: the needle scan
(`csrfmiddlewaretoken" value="[A-Za-z0-9]{20,}"`, `"csrfToken":"[A-Za-z0-9]{20,}"`,
`ncbi_sid=`, `api_key`, `Authorization: Bearer`, `_csrf=[A-Za-z0-9]{20,}`,
`cf_clearance`, `__cf_bm`) returns **0 hits in every stored body**. The one body
carrying a live `_csrf` token (the plain-curl copy of the SpringerLink chapter)
is deliberately **not** stored — only its digests and the 116-byte rotation
measurement are recorded. No response headers were captured at all.

## 9. Disclosure

* No frozen predicate, counter, kill rule, target or census figure was amended.
* `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
  `corpus/knowledge/claim-instrument-class-matrix.md` and every other lane file
  were **not** edited by this seat — the L1 appends. The census repair in §5 was
  executed only in scratch copies of the lane tree.
* No commit, push or mutating git/jj command was run anywhere. The lane working
  tree carries only the new receipt directory and this report.

## 10. Dispositions (L1, after this seat's findings)

Read back from the lane tree after the L1's integration; nothing here is
self-asserted by this seat.

* **M1 closed, and it became the C3 claim.** The L1 landed the two provenance
  rows I pre-computed (S155 `2836a65b…`, S156 `f9e69ecc…` — byte-for-byte
  agreement with mine), the entry's `cites: S148, S156, S164` line, the
  S148/S156 `used-by` cells, and a new row **S164** (`supersedes S148 —`) whose
  `anchor` cell names the carrier capture
  `.ufo/waves/round-64/capture/S143.body` with the pin
  `3b8d4e15…cba40`. Its fetch row's column 16 names that same path
  (`3b8d4e15…`, 264946 B) — a path, not anchor prose, which is the second
  anchor C1 asks for. The lane gate now reads
  `SOURCES_CENSUS: CLEAN (findings=0 rows=156 …)`; the fleet wrapper still reads
  `kagi ok`.
* **M2 adopted, not merely noted.** The 899-byte 429 body this seat captured is
  committed at `.ufo/waves/round-66/capture/S156-429.body`
  (sha `037c2dbe…`, 899 B — the exact pin the S156 row records) and S156's
  provenance row binds to **that path**. Binding the row to the round-65 pair
  would have repeated the very class this round closes: a row whose cited
  artifact *describes* the bytes instead of carrying them.
* **M3 measured and routed, not silently adopted.** The borrowed-identity class
  (11 of 20 round-64 capture handles carry another row's bytes) is recorded in
  the round report as a checked class routed to round 67.
* **Frontier verdicts.** S164 admitted on the BioC re-open; the SpringerLink and
  ACM refusals recorded with their reasons and flips; the arXiv:2404.09241
  paper (both digests stable, quotes locating `count=1`) is recorded as a
  **lead**, admit-shaped, and named for round 67's first pick — not written as a
  row this round, because no claim of this round cites it and a row without a
  citing claim would be row-padding. My §4 wording above is the seat's
  recommendation; the L1's disposition is the lane's.

## 11. Secret discipline — post-integration re-scan

The re-scan of the L1's landed captures is unchanged from §8: the committed
`.ufo/waves/round-66/capture/` bodies (S148.body `3b8d4e15…`, S155.body
`cdbb4173…`, S156-429.body `037c2dbe…`) carry no cookie, CSRF token, clearance
cookie or API key, and the stored SpringerLink receipt is the clean
declared-profile challenge shell, not the token-bearing plain-curl copy.

SEAT-STATUS: complete
