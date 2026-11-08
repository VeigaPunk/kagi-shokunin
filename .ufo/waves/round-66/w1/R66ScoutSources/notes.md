# R66ScoutSources — round 66 frontier source notes (kagi)

Seat: `R66ScoutSources` (scout; axes freshness, coverage). Lane `kagi-shokunin`,
branch master, claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`, frozen plan
`plans/round-66.md` (landed `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`).
Access date for every page opened below: **2026-11-08**.

Request profile (every fetch, without exception):
`curl -sS -L --compressed -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'`
— the lane's declared `curl-fsSL-compressed-v1` profile with a desktop browser
user agent. Digests are over curl's **decoded** body (`decoded-http-body-v1`).

Quotes are located with the lane's own normalizer:
`python3 corpus/rendered-text-v1.py locate <body> "<quote>"` → `count=N`.
Receipts: `manifest.tsv`, `fetch.sh` (the exact script that produced them) and
the captured bodies sit beside this file in this directory.

---

## 1. BioC deposit re-opened on the current date — the C1 carrier (S148's URL)

**URL** `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode`
**Access date** 2026-11-08 · **HTTP 200** · **264946 B** ·
sha256 `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40` ·
rendered-text-v1 normalized sha256 `4d966ff9535cdbd8faa00ad925f60e2fb38892bdb07cd48bb587c9da8aac72d5` (162347 B normalized)

**Located quote (17 words)** — `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., "no increase", "not cause")`
— §3.1.2 "Trigger Terms, Pseudo-Trigger Terms, and Termination Terms" (BioC XML);
the §3.1.2 heading passage sits at byte 17212, the quote itself at byte **19131**,
inside passage **27 of 182**; `RENDERED_TEXT_V1_LOCATE: count=1`.

**Judgment: ADMIT — and the admitted finding is that the served bytes did NOT drift.**
Measured: the live body is **byte-identical** (`cmp` → no differences) to the
committed capture `.ufo/waves/round-64/capture/S143.body`, and to the S148
registry pin (same sha256, same 264946 B). Shape unchanged and re-measured:
`<passage>` 182, `<text>` 180, `<date>20261108</date>`, one `<date>` element.
So the plan's conditional — *"a `supersedes S148 —` row if the shape changed
since the 2026-11-08 capture"* — is **not** met by content drift: the superseding
row the C1 carrier repair requires carries **the same pin**, and what changes is
the *binding* (which committed capture path the row names), not the bytes.
The carrier's rate-limit behaviour is burst-dependent, not persistent: my very
first isolated request of the session returned 200 with the pin sha256, so the
C1 counter's live leg should read `live_status=200 rate_limited=0`.

## 2. ConText PMC2757457 through the eutils EFetch carrier (S155's URL)

**URL** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml`
**Access date** 2026-11-08 · **HTTP 200** · **189603 B** ·
sha256 `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b` ·
normalized sha256 `5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801` (91565 B normalized)

**Located quote (17 words)** — the same §3.1.2 sentence, verbatim:
`In the current version of ConText there are 17 pseudo-triggers for negated (e.g., "no increase", "not cause")`
— §3.1.2 (PMC XML, `<sec id="S6">` begins at byte 21584, the section title at
21610), quote at byte **23669**; `RENDERED_TEXT_V1_LOCATE: count=1`.

**Judgment: ADMIT as a recheck refresh of the existing S155 row — no new registry
row.** Measured: the digest still matches **S135's pin** exactly
(`cdbb4173…`, 189603 B), i.e. the plan's condition *"recheck refresh if the digest
still matches S135's pin"* holds, and the served body is byte-identical to the
committed capture `.ufo/waves/round-63/capture/S135.body`. Caveat for whoever
writes the refresh: in the **raw XML** the quoted sentence is interrupted —
`<italic toggle="yes">negated</italic>` — so the quote locates **only** after
`rendered-text-v1` normalization (raw-literal locate returns 0). The fetch row's
normalization field must therefore stay `rendered-text-v1` with the normalized
digest above; a `raw-literal-v1` classification would be wrong.

## 3. Equivalent-mutant state-of-the-art page — the designated weak lead

### 3a. SpringerLink, "A Comprehensive Review on Equivalent Mutant Detection Using Machine Learning" (IWSC 2025) — **REJECT**

**URL** `https://link.springer.com/chapter/10.1007/978-3-031-92474-3_4`
(DOI `10.1007/978-3-031-92474-3_4`; the same work resolves via
`https://doi.org/10.1007/978-3-031-92474-3_4` → `link.springer.com/10.1007/…`)
**Access date** 2026-11-08 · **HTTP 200** · **3038 B** ·
sha256 `32ed63159c77e21ee19ca1b9aa3213ccf0218eb59539560b132a8e68ef0e18ea` ·
normalized 305 B

**Located quote (2 words, the served body under the lane's declared profile)** —
`Client Challenge`
— the document `<title>` of the served body; `RENDERED_TEXT_V1_LOCATE: count=1`.
The same body contains **0** occurrences of `equivalent mutant`
(`RENDERED_TEXT_V1_LOCATE: count=0`).

**Judgment: REJECT (tier C, one turn past the gate).** Reason, measured, in three
parts:
1. **Unopenable through the lane's declared request profile.** With the desktop
   browser user agent the carrier answers HTTP 200 with a 3038-byte JavaScript
   interstitial ("Client Challenge"), not the chapter: the review's text is not
   reachable through the profile every registry row is fetched with.
2. **No stable pin even when it is reachable.** With a plain `curl/8.23.0` agent
   the same URL serves the real page — 339418 B, abstract present, the 18-word
   quote `equivalent mutants, which are code changes that do not alter program behavior, making detection computationally expensive and undecidable` locating `count=1` in `<div id="Abs1-content">` and in `meta name="description"` — but two
   consecutive fetches of it differ by **116 bytes** at offset ≈84237: the
   `_csrf` token in the "save research" link rotates. Two shas for one URL
   (`ce7f4294…` then `54a66a64…`) ⇒ no reproducible sha256 to pin.
3. **Abstract-only anyway.** The full chapter is behind the paywall; what the
   open page carries is the publisher's abstract, whose one substantive sentence
   (detection is "computationally expensive and undecidable") the registry
   already holds from peer-reviewed rows (S146 §5.3.1 "well-known undecidable
   problem").

**Flip:** a 200 response serving the chapter's full text (or at least its
abstract) as static HTML under the lane's declared desktop-browser user agent,
with a byte-stable body across two fetches.

### 3b. ACM DL record for the ISSTA '24 equivalent-mutants paper — **REJECT** (the unopened citation chain)

**URL** `https://dl.acm.org/doi/10.1145/3650212.3680310` (also via
`https://doi.org/10.1145/3650212.3680310`) · **Access date** 2026-11-08 ·
**HTTP 403** · 5684 B · sha256 `ad4c63cc8d6290f0d1b56b08abc39fce4b762cabff32b3c2f7d4582ecaf1937e`
(normalized 58 B)

**Located quote (8 words, the served body)** —
`Just a moment... Enable JavaScript and cookies to continue`
— the served interstitial's title line; `RENDERED_TEXT_V1_LOCATE: count=1`; the
body carries **0** occurrences of `equivalent mutant`.

**Judgment: REJECT.** The publisher record is behind a bot wall (403, both
direct and via doi.org), so it grounds nothing; and the paper it points at is
already mined as **S145** from the authors' own open PDF — a duplicate ground
under a different URL, in the same class as the round-64 rejected IEEE records
(S142/S144).
**Flip:** ACM serving the record's abstract as static HTML.

### 3c. Extra candidate found while sweeping (coverage, NOT part of the plan's frozen triple) — **ADMIT candidate**

**Straubinger, Degenhart & Fraser, "An Empirical Evaluation of Manually Created
Equivalent Mutants"** —
`https://arxiv.org/abs/2404.09241` (arXiv:2404.09241 [cs.SE], submitted
2024-04-14; full text `https://arxiv.org/html/2404.09241v1`)
**Access date** 2026-11-08 · **HTTP 200** · abs page **40386 B** ·
sha256 `4bcb20b23ad5046657a65a29595517da973128a289ff75ba13ad8926c5511a80` ·
normalized `3a0eebc8fa834f6a3822988bb9f1e5d05b242cb18e8bffc8b3a5a8fd2bdccfc4` (4518 B);
HTML full text 204025 B, sha256 `b5d93658f6349c67f2396a1be5795632f93bdf4af9ed0703c15aadc0a2dcc898`.
Both digests **stable across two consecutive fetches**.

**Located quote (15 words)** —
`equivalent mutants, i.e., mutants that differ only in syntax but not semantics, hamper this process`
— §Abstract (arXiv abs page; the quote occurs in the abstract blockquote at byte
5826 and in the page's meta description at 2716; after tag-stripping only the
blockquote occurrence survives) `RENDERED_TEXT_V1_LOCATE: count=1`.
Second located quote (9 words) — `less than 10 % of manually created mutants are equivalent`
— §Abstract; `count=1` **only in this spelling**: the abs page renders the
percentage spaced (`10 %`) while the HTML full text renders it unspaced (`10%`),
and each locates `count=0` in the other carrier. Write the quote in the carrier's
own spelling.

**Judgment: ADMIT candidate — the registry has no row for the *manually
created* equivalent-mutant rate.** Measured novelty: `corpus/SOURCES.md` holds
**0** occurrences of `Straubinger`, `Code Defenders`, `Manually Created`, or
`2404.09241`. The registry's equivalent-mutant ground (S137/S139/S140/S145/S146/S147)
is entirely about *tool-generated* mutants; this row adds the human-authored
side and its rate bound (<10 %), which is directly usable as the contrast to
S137's "4% to 39%" tool-generated range. I verified in a scratch copy of the lane
tree that appending it as a `queued` tier-A `spec` row plus its fetch row keeps
the lane census reading `SOURCES_CENSUS: CLEAN (rows=156 …)`.
**Bound:** the arXiv page states no venue, and DBLP was bot-walled on this host
(HTTP 202 "Making sure you're not a bot!"), so I could **not** verify the
ISSTA-2024 venue from a primary record — do not write a venue into the row
without a record that carries it.

---

## Cross-source measurements the L1 and the C1/C3 seats need

### M1 — the lane's own census reads FAILED at BASE (4 findings), while the fleet script reads `ok`

`bash corpus/sources-census.sh` on the **lane** tree at BASE `ddcd46bb` (and at
`d549ee6`, extracted read-only via `git archive`):

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
script's verdict token `SOURCES_CENSUS: CLEAN`, which is exactly what the lane
script prints. So as BASE stands, the C1/C3 guards cannot read CLEAN.

**Minimal repair, measured to reach CLEAN** (verified in a scratch copy of the
lane tree; the lane repo itself was not modified):

1. Append two 16-column rows to `corpus/source-fetches.tsv` — one for `S155`
   (status `mined`) and one for `S156` (status `rejected`). The row-identity
   digest is `sha256("<id>\t<status>\t<url>\n")`; I verified that formula
   reproduces the committed digests of S135, S148 and S151 byte-for-byte.
   Pre-computed values:
   * `S155` rid `2836a65b4d0289cbcedae2ee8ea98ae0010ce1287d43a56086a98920e067da08`
   * `S156` rid `f9e69eccea5a30860e2f9ed118385afbec0d657425040d55305c7f170f1a98e1`
2. Add `cites: S148, S156` to `corpus/knowledge/claim-instrument-class-matrix.md`
   and list that entry in the `used-by` cells of the `S148` and `S156` rows
   (the census requires every `cites:` id's `used-by` to list the entry).

After both steps: `SOURCES_CENSUS: CLEAN (rows=155 A=138 B=2 C=15 queued=3
mined=135 rejected=17 entries_sourced=25 legacy=21 captures=155 inrow=16
inrow_only=0 inrow_nonreproducing=12)`, and the fleet script still prints `ok`.
With the §3c row added as well: `CLEAN (rows=156 A=139 B=2 C=15 queued=4 …)`.

### M2 — the S156 rejected row's 429 body is reproducible, and is not committed as bytes

The round-65 capture pair `.ufo/waves/round-65/capture/bioc-429-first.txt`
(211 B) and `-second.txt` (137 B) *describe* the 429 body; their own sha256s are
`dcac2eea…` / `bfee41d3…`, **not** the pin the S156 row records
(`037c2dbe…`, 899 B). The 899 bytes themselves are nowhere in the tree. I
reproduced them live today: a burst of six requests to the BioC URL returned
**429 with 899 B, sha256 `037c2dbe610ab2a6516d0f0916f7ad3cdfe016739186de59e5eaecd7043d00ba`**
on attempt 1, then HTTP 200 with the pin sha256 on attempts 2–6. So the S156 pin
is a live-reproducible artifact and a capture file that actually contains those
bytes now exists (this directory: `S156_429.body`) — which is what a provenance
row for S156 must point at.

### M3 — the round-64 capture filenames are handles, not registry ids: 11 of 20 resolve to another row's bytes

Measured by sha256 over every `.ufo/waves/round-64/capture/*.body` and matching
each against the registry ids' fetch-row digests:

| capture file | bytes | sha256 | the registry id whose bytes it holds |
|---|---|---|---|
| S143.body | 264946 | `3b8d4e15…` | **S148** (the S148 pin) |
| S145.body | 67033 | `a31331da…` | S150 |
| S146.body | 30253 | `18513008…` | S129 |
| S147.body | 12023 | `b0c7e050…` | S128 |
| S148.body | 39750 | `fabc74c5…` | **S152** (an unrelated arXiv QAOA body) |
| S149.body | 171636 | `4b5a8374…` | S149 (the only name that matches) |
| S150.body | 1930379 | `f996c36d…` | S154 |
| S151.body | 38687 | `00082805…` | S147 |
| S152.body | 17760 | `6e6bffb0…` | none |
| S153.body | 1129278 | `63b7bfca…` | S146 |
| S154.body | 509057 | `066f4438…` | S145 |
| S155.body | 3045 | `2381b66b…` | none |
| S156.body | 20845 | `ccf6ac49…` | S151 |
| S157.body | 9320 | `49dd5ac4…` | S153 |
| S158–S163.body | — | — | none |

So a reader who resolves a registry id to a capture **path** by filename lands on
another row's body in 11 of 20 cases; only `S149.body` matches its name. The
plan's C1 repair direction — bind the row to the capture **by digest** — is
therefore the right direction, and this table is the size of the class it fixes.
(The round-64 offset is a known artefact of that round's handle allocation, not
a new defect; it is measured here because C1/C3 must not resolve paths by name.)

## Secret discipline

* No `set-cookie`/`cookie` header value, CSRF token, clearance cookie or API
  key is stored in any receipt in this directory. Scanned with
  `csrfmiddlewaretoken" value="[A-Za-z0-9]{20,}"`, `"csrfToken":"[A-Za-z0-9]{20,}"`,
  `ncbi_sid=`, `api_key`, `Authorization: Bearer`, `_csrf=[A-Za-z0-9]{20,}`,
  `cf_clearance`, `__cf_bm`: **0 hits** in every stored body.
* The one body that carries a live `_csrf` token — the plain-curl-UA copy of the
  SpringerLink chapter — is **deliberately not stored**; only its digests and the
  116-byte rotation measurement are recorded here. The stored Springer body is
  the 3038-byte challenge shell under the declared profile, which is clean.
* No response headers were captured at all, so no header-borne credential can be
  in a receipt.

### M4 — no census leg can see the borrowed-identity class; the C1 counter can (measured)

M3 is a class of defect that no registry gate can currently see. Measured on a
scratch copy of the L1's **current** tree (which reads `SOURCES_CENSUS: CLEAN
rows=156`): I repointed S164's fetch-row column 16 from
`.ufo/waves/round-64/capture/S143.body` to
`.ufo/waves/round-66/capture/S164.body` and planted **S152's arXiv QAOA body**
(`fabc74c5…`, 39750 B) at that path — so the row's declared digest
(`3b8d4e15…`, 264946 B) and the bytes at the cited path are different bodies.

| instrument | reading on the mis-pointed tree |
|---|---|
| lane gate `corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=156 …)` — **blind** |
| fleet wrapper `scripts/sources-census.sh` | `file ok` — **blind** |
| `plans/round-66-c1.sh --tree <tree> --base-tree <base>` | `diag fetches:digest-mismatch:…/S164.body`, `match=0`, `drift=0`, `guard=0`, rc 1 — **catches it** |

The mechanism is visible in the gate's source: its only capture-related check
is `[[ ${#floc} -ge 8 ]]` — the **length of the location string** — and it never
hashes the file the location names (`grep -cE 'sha256sum .*(capture|body)'` ⇒
**0**). The one leg that compares a declared digest against capture bytes is the
`inrow-pins` classification, and it is bounded to `S001`–`S016`
(`HIST_RE='^S0(0[1-9]|1[0-6])$'`), i.e. exactly the historical set whose rows may
self-certify with a bare in-row pin.

So: a capture path that names another row's body is invisible to both censuses
and is caught only by C1's digest resolution — and C1 resolves the anchor cell
and the fetch column **independently** (the mis-pointed tree produces a
`fetches:digest-mismatch` while `registry:` stays clean, which is precisely the
second-anchor leg). Naming this for the marshal: the class is real, it is
routed to round 67 as a checked class, and the instrument that can see it
exists in this round — `plans/round-66-c1.sh` — so the round-67 lead can be
built on C1's digest resolution rather than on a new census leg.

## Disclosure

* No frozen predicate, counter, kill rule, target or census figure was amended.
  Every number above is measured on the live web or on a scratch copy of the
  lane tree.
* `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
  `corpus/knowledge/claim-instrument-class-matrix.md` and every other lane file
  were **not** edited by this seat — the L1 appends. The repair in M1 and the
  mis-pointing probe in M4 were executed only in scratch copies of the tree.
* Registry ids are the L1's to mint. The next free id at BASE was `S157`; I
  used it only as a *proposal* for the §3c row (the L1 minted **S164**).

## Dispositions (L1, read back from the lane tree after integration)

* **M1 → closed, and promoted to the C3 claim.** Landed: the two provenance
  rows I pre-computed (S155 `2836a65b…`, S156 `f9e69ecc…`, byte-for-byte equal
  to mine), the entry's `cites: S148, S156, S164` line, the S148/S156 `used-by`
  cells, and a new row **S164** (`supersedes S148 —`) whose `anchor` cell names
  the carrier capture `.ufo/waves/round-64/capture/S143.body` with the pin
  `3b8d4e15…cba40`; its fetch row's column 16 names that same path
  (`3b8d4e15…`, 264946 B) rather than anchor prose. Lane gate now reads
  `SOURCES_CENSUS: CLEAN (findings=0 rows=156 …)`; fleet wrapper still `ok`.
* **M2 → adopted as a committed capture.** The 899-byte 429 body this seat
  captured is committed at `.ufo/waves/round-66/capture/S156-429.body`
  (sha `037c2dbe…`, 899 B — the S156 pin) and S156's provenance row binds to
  that path, so the row now *carries* the bytes instead of pointing at a file
  that only describes them.
* **M3 → measured and routed, not silently adopted.** Recorded as the
  borrowed-identity class and routed to round 67 as a checked class.
* **Frontier.** S164 admitted on the BioC re-open; the SpringerLink and ACM
  refusals recorded with reasons and flips; arXiv:2404.09241 (§3c) recorded as
  a **lead** — admit-shaped, both digests stable, quotes locating — and named
  for round 67's first pick, not written as a row this round (no claim of this
  round cites it). The verdict above is this seat's recommendation; the
  disposition is the lane's.
