# R68ScoutSource — the round-68 frontier source, opened and captured

Seat: R68ScoutSource (scout). Lane `kagi-shokunin`, branch master. Sole writer
of `.ufo/waves/round-68/capture/*`. No other lane file was edited: the two
registry/fetch rows below are **drafts for the L1 to append**, not writes.

Claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`. Frozen predeclaration
`plans/round-68.md` (landed `23a8e0290d8d3a6f1de16eafce40fd1a189ef636`).

## 1. Decision: ADMIT, tier A, `mined`

The candidate was opened live and the served text carries the rule C1 now
enforces at the record level. RFC 4648 §3.3 states it normatively:

> Implementations MUST reject the encoded data if it contains characters outside
> the base alphabet when interpreting base-encoded data

(§3.3 "Interpretation of Non-Alphabet Characters in Encoded Data", body lines
200-204; heading at body line 190.) The same section names the two facts the
lane's gate turns on: adjacent CRLF bytes *are* non-alphabet characters
(body lines 206-207), and tolerating non-alphabet characters is a named
implementation-error vector — "exploit implementation errors leading to, e.g.,
buffer overflow attacks" (body lines 196-198). That is precisely the rule the
census gate's `capture-whitespace` / `capture-token` / `cr-in-tsv` reasons
enforce: a field carrying structured data is accepted in its exact declared
form or the record is refused; a stray byte is a defect to refuse, never
formatting to normalise away.

**Why this lane's domain (secrets & vault ops).** The lane stores secret
material, tokens, and vault payloads; a base16/base32/base64 field that a
decoder silently accepts with stray characters is the same defect the census
gate now refuses in a location cell. RFC 4648 is the primary standards text
for exactly that strictness (an IETF Standards Track RFC, `Category: Standards
Track`, obsoletes RFC 3548), so it is tier A for this scope.

**Flip condition.** Flip to `rejected` if a later fetch of the same URL shows
§3.3's MUST sentence withdrawn or softened (e.g. RFC 4648 obsoleted, or its
"be liberal in what you accept" exception generalised to non-alphabet
characters), or if the lane's own gate stops refusing a stray byte in a
location cell — the standard would then no longer ground the rule the gate
enforces. The row is `mined` because `corpus/knowledge/source-capture-binding.md`
cites it (the L1's scribe has already added S167 to that entry's `source:`
line and `recheck:` line — verified below).

## 2. The capture

`.ufo/waves/round-68/capture/S167.body` — raw bytes exactly as served.

```
$ sha256sum .ufo/waves/round-68/capture/S167.body
84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f
$ wc -c < .ufo/waves/round-68/capture/S167.body
35491
$ python3 corpus/rendered-text-v1.py digest .ufo/waves/round-68/capture/S167.body
RENDERED_TEXT_V1: raw_sha256=84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f \
  bytes=35491 normalized_sha256=30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9 \
  normalized_bytes=28542
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-68/capture/S167.body \
  "Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data"
RENDERED_TEXT_V1_LOCATE: count=1
```

Quote: **18 words**, `count=1` under `rendered-text-v1` — the normalization the
row declares. The control matters: the same quote is `raw_count=0` on the raw
bytes (the sentence wraps across lines 200-204), so `rendered-text-v1` is the
correct declared normalization and `raw-literal-v1` would have failed.

**Location.** §3.3 "Interpretation of Non-Alphabet Characters in Encoded Data";
heading at body line 190; the MUST sentence at body lines 200-204.

**Fetch receipt.** `.ufo/waves/round-68/capture/S167.fetch.txt` (copied to
`.ufo/waves/round-68/w1/R68ScoutSource/S167.fetch.txt`) records the URL, the
access date/time (2026-11-08T12:23:20Z / 09:23:20-03:00, from the response
`Date` header), HTTP 200, the byte count 35491, the sha256, and the user agent.
The fetch was made twice with the lane's request profile
(`curl -fsSL --compressed`, desktop browser user agent); the two responses are
byte-identical (`cmp` rc 0), and both are byte-identical to the committed
capture.

Full receipts: `.ufo/waves/round-68/w1/R68ScoutSource/verify.txt`.

## 3. The drafted rows (for the L1 to append)

Both rows are generated and shape-checked by
`.ufo/waves/round-68/w1/R68ScoutSource/mkrows.py` — **34 checks, 0 failures**
(receipt: `.ufo/waves/round-68/w1/R68ScoutSource/drafted-rows.txt`). The
checker verifies the contract v1 shape of the row it emits: 11 cells / NF=13, no
literal `|` inside any cell, the `kind`/`tier`/`status` enums, an ISO `opened`,
a valid `recheck` cadence, `used-by` naming the lane knowledge entry, and — for
the fetch row — 16 tab columns, the row-identity digest the gate recomputes,
a ≤25-word quote, the declared normalization, a 64-hex col 15, and a col 16
that is exactly one whitespace-delimited token (the pure capture path).

### 3.1 `corpus/SOURCES.md` — 11 columns

```
| S167 | RFC 4648 — The Base16, Base32, and Base64 Data Encodings — https://www.rfc-editor.org/rfc/rfc4648.txt | spec | A | record-level strictness: a field carrying structured data is accepted in its exact declared form or the record is refused; characters outside the declared alphabet are never silently normalised away, and the non-alphabet tolerance is a named implementation-error vector | §3.3 Interpretation of Non-Alphabet Characters in Encoded Data (RFC 4648, October 2006; heading at body line 190, the MUST sentence at body lines 200-204); capture `.ufo/waves/round-68/capture/S167.body` (35491 B, sha256 `84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f`); opened live 2026-11-08 with a browser user agent (HTTP 200, 35491 B, same sha256, refetch byte-identical; receipt `.ufo/waves/round-68/capture/S167.fetch.txt`; quote locate count=1 under rendered-text-v1; normalized sha256 `30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9`, 28542 normalized bytes) | a field with a declared alphabet is accepted in that exact form or refused, never read past: RFC 4648 §3.3 makes rejecting characters outside the base alphabet a MUST for an implementation interpreting base-encoded data, names stray CRLF as non-alphabet characters, and records that tolerating them has been used to exploit implementation errors (buffer overflow), so the lane's census refuses a location cell carrying a stray byte instead of normalising it away. Quote (verbatim): "Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data" | mined | 2026-11-08 | 180d | corpus/knowledge/source-capture-binding.md |
```

### 3.2 `corpus/source-fetches.tsv` — 16 tab columns

(Tabs shown as `<TAB>`; the row itself contains real tabs.)

```
S167<TAB>mined<TAB>7b4c8e2b5a9b2ca755ccad80d44f0a42b3680c3b07d68fa7f447895b2bd0d4dd<TAB>https://www.rfc-editor.org/rfc/rfc4648.txt<TAB>https://www.rfc-editor.org/rfc/rfc4648.txt<TAB>200<TAB>curl-fsSL-compressed-v1<TAB>2026-11-08<TAB>decoded-http-body-v1<TAB>84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f<TAB>35491<TAB>-<TAB>Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data<TAB>rendered-text-v1<TAB>30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9<TAB>.ufo/waves/round-68/capture/S167.body
```

Notes on the fetch row's columns:

- **The L1 has already landed an S167 fetch row** in the working tree, and its
  cols 10-16 are **byte-identical to my draft** (raw sha256, byte count, the
  quote, the normalization, the normalized digest, and the pure capture path
  all match exactly; col 3's row-identity digest also matches, `7b4c8e2b…`).
  My drafted SOURCES.md row differs from the landed one only in the `scope`,
  `anchor` and `teaches` prose (the landed row cites the § and the body line
  190/200-204; mine adds the RFC's October 2006 revision and spells out the
  CRLF and buffer-overflow grounds). The L1's choice stands — I am not
  editing `corpus/SOURCES.md`.
- **col 3** is the gate's row-identity digest: `sha256("S167\tmined\t" +
  "https://www.rfc-editor.org/rfc/rfc4648.txt\n")` — the same formula the gate
  applies at `corpus/sources-census.sh:402-403`
  (`printf '%s\t%s\t%s\n' "$fid" "$status" "$url" | sha256sum`).
- **col 6** HTTP 200; **col 7** `curl-fsSL-compressed-v1` (the lane's declared
  request profile, matching what the fetch actually did); **col 8** the
  access date; **col 9** `decoded-http-body-v1` (the body was served
  `content-encoding: gzip` and the captured bytes are the decoded body).
- **col 12** revision `-`: RFC 4648 is not a moving reference (it is a
  published RFC, and the URL is not a `raw.githubusercontent.com` or `*/main/*`
  form), so the gate's moving-ref revision check does not apply. This matches
  the S166 row's col 12.
- **col 16** is the **pure capture path** — one whitespace-delimited token,
  no prose — per the plan's landing surface and the widened gate's
  classification. This is the shape the plan's `verified` population counts.

## 4. Two measured findings, both since ruled in by Amendment A1

### 4.1 The S167 row's own landing shifts the C1 population by one

The plan freezes `C1_VERIFIED: verified=37 col15=32` and says the +1 over BASE
comes from "S166's row, re-cut to the pure path". I re-derived both
populations independently, row by row, from the plan's own population rule
(`verified` = col 16 is a repo-relative capture path **or** contains a
whitespace-delimited token that is a repo-relative `.ufo/waves/` capture path,
whose first such token binds sha256/bytes/quote; `col15` = of those, the
`rendered-text-v1` rows whose recomputed normalized digest equals col 15).
Receipt: `.ufo/waves/round-68/w1/R68ScoutSource/population.txt`; script
`derive.py` in the same directory.

| tree | verified | col15 | prose |
|---|---|---|---|
| BASE (`d3b2a4e`) | 37 | 32 | 120 |
| candidate, S167 landed as a pure path | **38** | **33** | 120 |
| candidate, S167's col 16 as prose (no `.ufo/waves/` token) | 37 | 32 | 121 |

**The strict-vs-permissive split, which is the cleanest statement of why the
wording matters.** The plan's classification rule is the strict one — a cell is
legal iff it names NO `.ufo/waves/` token (prose) or IS exactly one such path
(path); every other cell naming a token is a defect. Under that rule, S166's
BASE mixed cell is a **defect**, not a population member, so the BASE
population is **36/31 (strict)**; a permissive reading that also counts
token-bearing cells gives **37/32 (permissive)** at BASE, because at BASE
S166's col 16 is the cell
`§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body` and its
whitespace-delimited token `.ufo/waves/round-67/capture/S166.body` binds
(sha256 `544dbb7d…`, 67152 B, quote count=1). The same table's third row
(S167 as prose) is the permissive reading's 37/32 — and it agrees exactly with
the L1's own recut-only derivation
(`.ufo/waves/round-68/final/l1-derivation-recut-only.txt`, `CANDIDATE verified=
37 col15= 32 defects= []`, measured with the S166 recut landed and before the
S167 row existed), so my recount and the L1's are two independent readings of
the same tree that agree. Receipt: `.ufo/waves/round-68/w1/R68ScoutSource/population.txt`.

**Resolution (landed).** Both points below were ruled in by the L1 in
`plans/round-68.md` §Amendment A1, commit `4251519bd6e8b5c152d70ae286e04a117a49ed4f`
(09:23:57, recorded before any counter existed on disk):

- **A1.2 — the target's teeth.** The frozen `verified=37 col15=32` is the
  reading of a tree carrying only the S166 recut (the L1's receipt above); the
  round's own S167 row "is a landing, not a target change: it adds one binding
  row to each population, so the final candidate reading is 38/33 with zero
  defect rows." The claim carries three derived teeth instead of a bare count:
  `defects = 0` over the whole fetch population, `caught = 6/6`, `guard = 1`.
  So the number moved **with** the landing rather than against it, and the
  count I measured (38/33) is the shipped candidate line, not a discrepancy.
- **The S167 row must be inside the population, never prose.** Under the
  strict rule a prose col 16 would keep the count at 37/32 but would put
  S167's own bytes outside the re-verified population — the exact defect class
  (C0) the round is closing, re-created on the round's own new row, and the
  same mistake round 67 made with S166 (`R67Revenger` §C0). A pure capture
  path keeps the row `mined`, its bytes re-verified, and `defects = 0`.

This section was written before I read A1; it is retained because the
measurement behind it is what A1 relies on, and because the strict-vs-
permissive split is the wording A1.2 resolves.

**Third independent confirmation.** The counter seat
(`.ufo/waves/round-68/w1/R68ExecCounterC1.md`) reports, on the live lane with
the S167 row present: `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=0`,
anchor `S167` — "verified 38 = 36 BASE + S166 recut + S167", and its BASE run
reads `C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0`. Its BASE 36/31
and its 38/33 are exactly my strict reading and my candidate reading, from a
separate implementation. The counter seat also reached the same strict/
permissive fork from the other side: its BASE anchor is `S166` under a
token-eligible rule (S166's mixed cell binds) and `S156` under a pure-path-only
rule, while at the candidate **all three readings agree on `S167`**. So the
anchor question is closed for the candidate whichever rule is taken, and the
BASE difference is the same strict-vs-permissive split, not a third dispute.
(The counter seat's live run reports `guard=0`; that is the counter seat's own
leg and guard state, not mine to adjudicate.)

### 4.2 The plan's anchor parenthetical does not match its own anchor rule

The plan derives the mutation anchor as "the LAST capture-path-shaped row in
file order that binds its declared bytes", and names `S166` at the candidate
and `S164` at BASE. Measured on the actual trees:

- **BASE**: the last binding pure-path row in **TSV line order** is **S156**
  (line 199, status `rejected`); in **id order** it is **S164** (line 197).
  The plan's `S164` matches the id ordering, not the file ordering it names.
- **candidate** (with S167's row landed as a pure path): the last binding
  pure-path row is **S167** (line 201) under *both* orderings — S167 is
  appended after S166.

So with the S167 row present, the rule as written derives **S167**, not S166,
and the plan's parenthetical is stale for the candidate. If the counter instead
anchors on the plan's named `S166`, that is a deliberate narrowing of the
"derived, never named" rule. Either way the six mutation legs move from
mutating S166's row to mutating S167's row, and S167's row is the one this
round adds — the legs would then exercise the round's own new row rather
than the row the round re-cut.

**Resolution (landed).** `plans/round-68.md` §Amendment A1.1 rules this in by
name: "the anchor is the derivation, not the parenthetical", recording my
measured values — `S156` at BASE (the TSV is not in id order) and `S167` at the
candidate — and requiring the counter to "print the anchor id it selected and
its same-size/different-digest target, and no leg may name a literal id." The
L1 reports the landed counter prints `anchor id=S167 pure=True`.

**Independent corroboration from the landed tree:** the lane's knowledge entry
`corpus/knowledge/source-capture-binding.md` (the scribe's file) already
treats S167 as the anchor — its falsifier table's legs name
`FINDING SC_CAPTURE id=S167 capture-whitespace` and
`FINDING SC_CAPTURE id=S167 capture-token`, and its prose reads "S166 (recut to
the pure path by this round) and S167 (this round's new row)". So the entry
and the plan's derivation agree on **S167**, and only the plan's parenthetical
disagreed. Receipt: `.ufo/waves/round-68/w1/R68ScoutSource/knowledge-citation.txt`.

## 5. Other measured observations (not claims)

- **The candidate tree's gate is CLEAN with the S167 row landed.**
  `bash corpus/sources-census.sh verify --root .` on the lane prints
  `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)` and
  `SOURCES_CENSUS: CLEAN (rows=158 …)` with **zero** `FINDING` lines. The
  fleet wrapper `scripts/sources-census.sh validate --root … kagi` prints
  `kagi ok` (the W04 duplicate-URL warnings are pre-existing and non-fatal).
- **The S166 re-cut is load-bearing, and I measured that it is.** Reverting
  only S166's col 16 to its BASE prose cell on a full copy of the candidate
  tree gives `FINDING SC_CAPTURE id=S166 capture-token` and
  `SOURCES_CAPTURES: FAILED (defects=1 …)`. The re-cut is what takes S166 out
  of the prose population and into the bound population.
- **The gate's selftest was red for most of my working window, then went
  green.** At 09:39 the lane's `corpus/sources-census.sh --selftest` printed
  `SOURCES_CENSUS_SELFTEST: FAIL (98 cases, 3 failed)`
  (`capture-symlink-escape`, `capture-whitespace-cr`, `capture-token-slashslash`);
  at 09:51 the same command printed `FAIL (98 cases, 1 failed)`
  (`capture-token-slashslash`); at 09:56, after the gate file's mtime moved to
  09:55:22, it printed **`SOURCES_CENSUS_SELFTEST: PASS (98 cases)`**. The
  gate file's mtime moved during my measurements (09:35:50 → 09:51:05 →
  09:55:22), so the red readings were the gate seat's in-flight work, not a
  settled state. The final receipt is in
  `.ufo/waves/round-68/w1/R68ScoutSource/gate-selftest.txt`: PASS, 98 cases,
  which satisfies C1's guard (b) (`N >= 89`). I did not touch the gate (not my
  file). Note that this PASS was measured against the gate bytes as of
  09:55:22; the gate seat may still be editing.
- I read the RFC's own metadata for the anchor: `Category: Standards Track`,
  `Obsoletes: 3548`, October 2006 (body lines 8-10).
- **Dead end, reported honestly: one counter run of mine produced no receipt.**
  I started `bash plans/round-68-c1.sh --tree . --base-tree . --scratch …`
  against the lane to see the counter's own final line for myself. It exceeded
  60 s and was backgrounded; I then deleted its scratch directory during
  cleanup and its output file was lost with it. **I therefore have no
  measurement of my own of the counter's final line**, and I make no claim
  about one. The counter readings quoted in §4 are the counter seat's
  (`.ufo/waves/round-68/w1/R68ExecCounterC1.md`) and the L1's
  (`.ufo/waves/round-68/final/l1-derivation-recut-only.txt`), both of which I
  read from the tree. My own measurements are the population recount
  (§4.1), the anchor derivation (§4.2), and the capture verification (§2).

## 6. Tooling

No tool was installed or upgraded: the fetch used the system `curl 8.23.0
(x86_64-pc-linux-gnu) libcurl/8.23.0 OpenSSL/3.6.5 zlib/1.3.2` and the
digest/locate used the lane's committed
`corpus/rendered-text-v1.py` under the system `python3 3.14.8`
(`/usr/bin/python3`, stdlib only). No package manager was invoked (pacman is
paused host-wide). Operator rules read at `/home/vgpnk/.omp/agent/RULES.md`.

## 7. Scope and scratch

Files written by this seat — all inside the lane, all inside its sole-writer
area plus its report and receipts:

- `.ufo/waves/round-68/capture/S167.body` (35491 B, the served body)
- `.ufo/waves/round-68/capture/S167.fetch.txt` (the fetch receipt)
- `.ufo/waves/round-68/w1/R68ScoutSource.md` (this report)
- `.ufo/waves/round-68/w1/R68ScoutSource/{S167.fetch.txt,verify.txt,
  population.txt,drafted-rows.txt,mkrows.py,derive.py,gate-selftest.txt}`

`corpus/SOURCES.md` and `corpus/source-fetches.tsv` were **not** written by
this seat; the rows in §3 are drafts for the L1 to append. No git mutation of
any kind was performed (read-only `git log/show/diff/status/ls-files/rev-parse`
only). Scratch lived at
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68ScoutSource` and was
deleted after the receipts were copied here.

Report: .ufo/waves/round-68/w1/R68ScoutSource.md
