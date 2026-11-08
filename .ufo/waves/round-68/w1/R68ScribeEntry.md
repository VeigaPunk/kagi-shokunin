# R68ScribeEntry — knowledge entry for the widened capture binding, and the S167 row drafts

Seat: scribe (R68ScribeEntry). Lane `kagi-shokunin`, branch master, claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`, frozen predeclaration
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636` (`plans/round-68.md`).
Sole writer of `corpus/knowledge/source-capture-binding.md` this round. No
other lane file was edited: `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
`corpus/stamps.tsv` and every ledger file were read only. No git mutation, no
commit, no push. Scratch root
`/fast/scratch/hyaku/kagi-r68/R68ScribeEntry` (deleted after the receipts were
copied here).

## 1. What changed

`corpus/knowledge/source-capture-binding.md` — one file, rewritten in place,
same structure as before (`source:` line, `cites:` line, `verified-at:`,
`recheck:`, `Reverify:`, numbered sections, a bounds section, a falsifier
table, a reproduction block).

- **`source:` line** now names **S166, S164 and S167** (S167 appended, with
  its RFC 4648 §3.3 URL, section and access date).
- **`cites:` line added** — `S099, S113, S115, S143`, each named in the body
  (§Bounds 5, §3, §Bounds 3, `verified-at:`) and each cross-referenced rather
  than used as this entry's support.
- **§1 The population the census reads, and the rule that classifies a
  cell** — the widened population: which col-16 shapes are read, the
  monotone classification rule (path / prose / defect), and why a mixed-prose
  cell naming a lane capture is now a defect rather than prose.
- **§2 The two digest layers, and the third check that closes them** — the
  new third check (col 15 recomputed for bound `rendered-text-v1` rows) and
  what each of the three layers answers and cannot see.
- **§3 What the read-through catches, measured** — the four new reasons with
  one failing input each and the gate's verbatim line for each, two cases
  pasted in full, and the seven BASE blindness witnesses re-measured.
- **§Bounds** — now eleven items, adding the five the seat spec named:
  point-in-time attestation (1), hardlink durability (2), one-token quotes
  unmeasured (3), the gate's own normalizer (4), and the fleet-root
  `.ufo/prompts/` class (5, with S099's hand measurement pasted).
- **§Falsifiers** — F9–F12 added, one per added check, each runnable by a
  reader.
- **§Reproduction** — the census's current line pasted verbatim, the
  selftest's case count left as the gate's own print rather than a quoted
  number, and the C1 counter's candidate reading
  (`verified=38 col15=33 caught=6/6 guard=1`) with Amendment A1 cited for
  why 37/32 is the recut-only reading.

Every number in the entry now carries the command that produced it (the
critic's P-5/P-6/P-7 audit): the classification one-liner, the
`rendered-text-v1.py locate` / `digest` invocations, the `grep -c` for the
raw-vs-rendered quote count, and the `sha256sum` / `wc -c` / `grep -nF` for
S099's hand measurement.

## 2. What I measured (all receipts under `.ufo/waves/round-68/w1/R68ScribeEntry/`)

### 2.1 The widened gate, on the candidate tree

```
$ bash corpus/sources-census.sh verify --root .
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: CLEAN (rows=158 A=141 B=2 C=15 queued=3 mined=138 rejected=17 entries_sourced=27 legacy=21 captures=158 inrow=16 inrow_only=0 inrow_nonreproducing=12)
```

`bash corpus/claim-ledger.sh docs --root .` →
`DOC_AUDIT: CLEAN (entries=48 row_linked=45 by_hand=3 undeclared=0
missing_ids=0 unpinned=0 duplicate_reasons=0)`.

### 2.2 The four new reasons, run by me on copies of the candidate tree

`mutations/anchor-S167/` (gate sha256 `65bc4020300c10afe9b67e1f555d3193bedb6ab12a165eec8f3b7f1a944746b1`).
Every case: rc=1, `SOURCES_CENSUS: FAILED`, exactly one finding naming the
mutated id.

| case | input | the gate's line |
|---|---|---|
| M1 | anchor col 16 + one 0x20 | `FINDING SC_CAPTURE id=S167 capture-whitespace` |
| M2 | anchor col 16 + `,` + its own path | `FINDING SC_CAPTURE id=S167 capture-whitespace` |
| M3 | whole TSV rewritten with CR at every line end | `FINDING SC_FETCH cr-in-tsv` |
| M4 | anchor col 10, one hex digit flipped | `FINDING SC_CAPTURE id=S167 capture-digest-mismatch` |
| M5 | anchor col 15 swapped for another 64-hex digest | `FINDING SC_CAPTURE id=S167 normalized-digest-mismatch` |
| M6 | one byte appended to the anchor's capture body | `FINDING SC_CAPTURE id=S167 capture-bytes-mismatch` + `FINDING SC_CAPTURE id=S167 capture-digest-mismatch` |
| X1 | anchor col 16 rewritten as mixed prose naming a lane capture | `FINDING SC_CAPTURE id=S167 capture-token` |
| X2 | anchor col 16 rewritten to an in-lane-shaped path that does not exist | `FINDING SC_CAPTURE id=S167 capture-missing` |
| X3 | anchor col 16 rewritten to a `~/`-prefixed form | `FINDING SC_CAPTURE id=S167 capture-token` |
| control | unmodified copy | `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)`, rc 0 |

`mutations/anchor-S166/` is the same battery against the same gate with S166
as the mutated id; every reason fires identically. Both sets are kept
because the plan names S166 while the derived anchor is S167 (§4, conflict 2).

### 2.2b The battery re-run on the gate's final bytes

The gate's bytes moved once more after §2.2, and the **final** landing
bytes are `b93f06148a73fd9b7c896056662b3ab1d2a2fe0091506d2f300710824ff2183c`
— the bytes on which the gate's own selftest is finally green:
`SOURCES_CENSUS_SELFTEST: PASS (98 cases)`. The full battery was re-run
against them (`mutations/anchor-S167-gate-b93f0614/`), and **every reason
string reproduces identically**, with one behavioural difference worth
recording (M3, below).

```
[M1-trailing-space]          rc=1  FINDING SC_CAPTURE id=S167 capture-whitespace
[M2-comma-joined]            rc=1  FINDING SC_CAPTURE id=S167 capture-whitespace
[M3-whole-file-crlf]         rc=1  FINDING SC_FETCH cr-in-tsv
                                          FINDING SC_CAPTURE id=<every capture row> capture-whitespace
                                          … (one per capture row, 38 in all)
                                SOURCES_CAPTURES: FAILED (defects=38 path_rows=38 bound=0 located=0 prose=120)
                                SOURCES_CENSUS: FAILED (findings=39 rows=158)
[M4-col10-hex-digit]         rc=1  FINDING SC_CAPTURE id=S167 capture-digest-mismatch
[M5-col15-swapped]           rc=1  FINDING SC_CAPTURE id=S167 normalized-digest-mismatch
[M6-body-byte-appended]      rc=1  FINDING SC_CAPTURE id=S167 capture-bytes-mismatch
                                          FINDING SC_CAPTURE id=S167 capture-digest-mismatch
[X1-mixed-prose-names-capture] rc=1 FINDING SC_CAPTURE id=S167 capture-token
[X2-token-does-not-resolve]  rc=1  FINDING SC_CAPTURE id=S167 capture-missing
[X3-home-relative-token]     rc=1  FINDING SC_CAPTURE id=S167 capture-token
[control]                    rc=0  SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
```

(The per-row ids are elided here as `id=<every capture row>` because
naming two of them literally in the entry would make the census read
`SC_BODY_CITE … id=<that row> unrecorded` — every registry id an entry names
must be on its `source:` or `cites:` line. The full per-row listing is in the
receipt file.)

**M3's behaviour changed on the final bytes, and it is stricter.** On the
earlier bytes the gate stripped a trailing CR before classifying, so a
whole-file CRLF left the rows classifying as paths and still binding, and the
run failed only on the file-level `SC_FETCH cr-in-tsv` (`SOURCES_CAPTURES:
CLEAN … prose=120`). On the final bytes the gate keeps the CR in the cell for
classification and strips it only for the binding step, so each capture
row's CR-terminated cell is classified `capture-whitespace` and the line
reads `SOURCES_CAPTURES: FAILED (defects=38 path_rows=38 bound=0 located=0
prose=120)` — 38 cell-level findings plus the file-level one, 39 findings in
all. The CRLF save now disengages every capture row instead of merely being
noticed. The reason set is unchanged (`capture-whitespace`, `SC_FETCH
cr-in-tsv`); what changed is that the cell-level class now fires too. My
entry's §3 was corrected to describe the final behaviour and to paste the
final M3 lines.

### 2.2c The battery re-run on the gate's then-latest bytes

The gate's bytes moved again after §2.2 was measured. The full battery was
re-run against `6f18c608052fccf9d15e2f48ef4d68b13d164c0ac5c342872582702da9fb5f21`
and **every reason string reproduces identically** — the four round-68
reasons, the three round-67 binding reasons and the control all as recorded
above. Receipts: `mutations/anchor-S167-gate-6f18c608/`.

```
[M1-trailing-space]          rc=1  FINDING SC_CAPTURE id=S167 capture-whitespace
[M2-comma-joined]            rc=1  FINDING SC_CAPTURE id=S167 capture-whitespace
[M3-whole-file-crlf]         rc=1  FINDING SC_FETCH cr-in-tsv
[M4-col10-hex-digit]         rc=1  FINDING SC_CAPTURE id=S167 capture-digest-mismatch
[M5-col15-swapped]           rc=1  FINDING SC_CAPTURE id=S167 normalized-digest-mismatch
[M6-body-byte-appended]      rc=1  FINDING SC_CAPTURE id=S167 capture-bytes-mismatch
                                          FINDING SC_CAPTURE id=S167 capture-digest-mismatch
[X1-mixed-prose-names-capture] rc=1 FINDING SC_CAPTURE id=S167 capture-token
[X2-token-does-not-resolve]  rc=1  FINDING SC_CAPTURE id=S167 capture-missing
[X3-home-relative-token]     rc=1  FINDING SC_CAPTURE id=S167 capture-token
[control]                    rc=0  SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
```

At these bytes the gate's own selftest was still red
(`FAIL (98 cases, 2 failed)`: `capture-whitespace-cr`,
`capture-token-slashslash`) — the gate seat's open landing surface, not mine.
The final green bytes and the battery run against them are §2.2b.

### 2.2d The landed counter's final reading

With the gate green, the landed counter `plans/round-68-c1.sh` reads, on the
candidate tree against the L1's hash-verified read-only BASE extraction
(`/fast/scratch/hyaku/kagi-r68/l1/base-clean`):

```
c1-verified: guard a=1 b=1 c=1 d=1 e=1 defe defects=0
C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1
```

rc 0. All five guards are green, `caught=6/6`, and the population reads
38/33 — the candidate reading Amendment A1.2 pins (see §4 conflict 1).
Receipt: `c1-counter-final.txt`.

### 2.3 BASE blindness, re-measured on the BASE bytes

`base-witnesses/` — seven witnesses, each on a `git archive d3b2a4e…`
extraction with one mutation applied, run through the **BASE** gate
(sha256 `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`).
Every one reads CLEAN:

| BASE witness | BASE gate's line |
|---|---|
| col 16 + one trailing space (0x20) | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)` |
| col 16 + `,` + its own path (comma-joined) | same |
| col 16 + one trailing CR (0x0d) | same |
| col 16 = `//etc/passwd` | same |
| col 16 = `~/.ufo/waves/round-64/capture/S143.body` | same |
| col 15 replaced by another row's normalized digest | same |
| whole TSV rewritten with CR at every line end | `SOURCES_CAPTURES: CLEAN (path_rows=0 bound=0 located=0 prose=157)` |

Each witness drops one row out of the path population (36 → 35) or disengages
all of them (the CRLF file: `path_rows=0`), and the verdict stays `CLEAN`.

### 2.4 S167's capture, verified independently by me

`S167-verification.txt` — I re-derived every declared value from the
committed capture, without relying on the scout's report:

```
sha256sum .ufo/waves/round-68/capture/S167.body
  84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f     (= col 10)
wc -c < .ufo/waves/round-68/capture/S167.body
  35491                                                                   (= col 11)
python3 corpus/rendered-text-v1.py digest .ufo/waves/round-68/capture/S167.body
  RENDERED_TEXT_V1: raw_sha256=84e14418… b178f bytes=35491
    normalized_sha256=30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9
    normalized_bytes=28542                                                (= col 15)
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-68/capture/S167.body \
  "Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data"
  RENDERED_TEXT_V1_LOCATE: count=1                                          (>= 1)
```

The quote's 20 words sit inside RFC 4648 §3.3, which states the rule the
entry's classification leans on: *"Implementations MUST reject the encoded
data if it contains characters outside the base alphabet when interpreting
base-encoded data"*, and the RFC's own note that *"any adjacent carriage
return/line feed (CRLF) characters constitute 'non-alphabet characters'"* —
the CR case the widened gate now refuses.

### 2.5 S099's hand measurement (fleet-root class, §Bounds 5)

`base-witnesses/S099-fleet-root-hand-measurement.txt` — measured against
`/home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-44.md`, the fleet
tree, outside the lane root:

```
sha256sum → e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c   (= col 10)
wc -c <   → 97077                                                                (= col 11)
grep -nF "The claim is judged on the counter, kill rule and predicate declared before data. A rule"
           → 561:   - The claim is judged on the counter, kill rule and predicate declared before data. A rule
byte offset of first occurrence → 52924      raw-literal count → 1
```

S099's column 16 names `.ufo/prompts/…`, not a `.ufo/waves/` token, so under
the widened classification it stays **prose**: never read, never flagged. No
lane-rooted gate can bind it — `realpath` from the lane root cannot reach the
fleet tree. This is a hand measurement, not a gate verdict.

### 2.6 The population, derived independently

`derivation.txt` — my own row-by-row derivation over
`corpus/source-fetches.tsv` on the candidate tree (own code, not the gate's):
**verified 37 / col15 32** on the pure-path reading, and **38 / 33** once
S167's row is counted. See §4 conflict 1 — this is the load-bearing finding of
this seat.

## 3. The two layer claims in the entry, stated with their evidence

**Why a mixed-prose cell naming a lane capture is a defect, not prose.** The
round-67 classifier asked only "is this string shaped like a path?" and
counted everything else as prose. That made the escape hatch: one stray byte
— a trailing space, a CR, a comma-joined second value — turned a *bound* row
into an *unread* row while the summary still printed `CLEAN`, and the
whole-file CRLF variant disengaged every row at once (`path_rows=0`). The
widened rule classifies on what the cell *mentions*, not on whether the cell
happens to match a shape, so a cell that mentions a lane capture is bound to
it, and a cell that mentions one but is not exactly that path is refused
rather than skipped. S166's own cell was the proof that this matters: it
named `.ufo/waves/round-67/capture/S166.body` inside a sentence, so the
round-67 sourced claim rested on a capture the gate never opened. This round
recuts that cell to the pure path.

**What each digest layer answers.** Column 10 (raw sha256) answers "are these
the bytes the fetch produced?". Column 15 (declared normalized digest)
answers "is the *text* the same?". The new third check — column 15
*recomputed* from the bound file — answers "does the file on disk hash to
what the row declares?", which is the question neither of the first two
answers: columns 10 and 15 are computed from the same bytes, so a coherent
rewrite of the body moves both, while the recomputation compares the
declared column 15 against the file and catches a rewrite that forgot to
recompute.

## 4. Conflicts — reported verbatim for the canonical Rust judge

Both conflicts are between the **frozen** plan's §C1 text and the tree the
round actually produced. I did not amend, reinterpret, or work around either;
the plan's text is quoted exactly.

**Both were already ruled, before my measurement, by `plans/round-68.md`
§Amendment A1 — landed `4251519bd6e8b5c152d70ae286e04a117a49ed4f`
(2026-11-08 09:23:57), before `plans/round-68-c1.sh` existed on disk and
before any seat scored anything.** I read §C1 before A1 landed, measured, and
reported the disagreement; A1 then confirmed my measurements and supplied the
ruling. A1.1: "the anchor is the derivation, not the parenthetical […]
Measured: the LAST capture-path-shaped row in file order is `S156` at BASE
(the TSV is not in id order) and, once the round's own S167 fetch row lands at
the file's end, `S167` at the candidate. The derivation decides." A1.2:
"the final candidate reading is 38/33 with zero defect rows. The round's own
S167 row is a landing, not a target change." So my §4.1 finding (38/33,
measured two ways) and §4.2 finding (derived anchor S167 at the candidate,
S156 at BASE) are the readings A1 adopts, and the frozen `37/32` is the
recut-only reading A1.2 pins separately. The entry now cites A1 where it
states the population (§Reproduction) and quotes the candidate reading
`C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1`. This section stays as
the record of how the disagreement was found.

**BASE-extraction integrity.** The L1 reports that the *shared* BASE
extraction `/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e` was mutated by some
seat (its `corpus/source-fetches.tsv` now hashes `aa6fa31862f266d2ff65e7f6d10a05cc20006d3c87fb5a50cbe7036dbfcd8f8c`
against the committed blob's `90dd4a2cbc006cdf0a90e42f45917eb9fba9ee7645a9299fb49e79481d38291d`).
**None of my receipts read that path.** Every BASE measurement in this seat
ran on my own private extraction, `/fast/scratch/hyaku/kagi-r68/R68ScribeEntry/base`,
made with `git archive d3b2a4e8eed710277951e430efd3d27b5983033c` and
hash-verified after the fact: its `corpus/source-fetches.tsv` hashes
`90dd4a2cbc006cdf0a90e42f45917eb9fba9ee7645a9299fb49e79481d38291d`, byte
for byte the committed BASE blob
(`git show d3b2a4e8eed710277951e430efd3d27b5983033c:corpus/source-fetches.tsv | sha256sum`
→ the same value). Every base-witness receipt names its own tree path under
`/fast/scratch/hyaku/kagi-r68/R68ScribeEntry/mut…`. The mutated shared
extraction did not touch my evidence.

### Conflict 1 — the frozen C1 population is one row short of the tree the plan's own frontier step produces

The plan freezes, verbatim (`plans/round-68.md` §C1):

```
C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1
```

and defines `verified` as rows whose col 16 "is a repo-relative capture path
**or** whose col 16 contains a whitespace-delimited token that is a
repo-relative `.ufo/waves/` capture path", adding:

> S166's row, re-cut to the pure path `.ufo/waves/round-67/capture/S166.body`,
> is the +1.

and the kill rule:

> Kill rules: the target is missed if `verified < 37`, `col15 < 32`,
> `caught < 6` or `guard = 0`.

The plan's **own frontier step** then opens a second source and lands a second
capture row, verbatim:

> One source opened this round, to be named before the wave (the seat opens
> it): **S167**, an rfc-editor text RFC whose § states the rule the census
> gate now enforces for location cells […] — opened to ground C1's
> `capture-whitespace` rule and the S166 col16 re-cut. One row admitted,
> tier A if the § is primary, `mined`, `checked-out-side capture`.

S167's landed row carries col 16 `.ufo/waves/round-68/capture/S167.body` — a
`rendered-text-v1` lane capture, verified by me in §2.4 above. So the tree the
plan's own frontier step produces carries **two** capture rows added this
round (S166's recut and S167's new row), not one, and the `verified` /
`col15` populations are one higher than the frozen numbers.

Measured, on the candidate tree, by my own derivation (`derivation.txt`):

```
verified: 38
rendered col15 match: 33
```

and by the landed counter `plans/round-68-c1.sh` (sha256
`60e3f680a226d5143ee1fcc62b229c5695f76d562f8445b8b382300354b84c59`):

```
c1-verified: derived verified=38 col15=33 path_rows=38 bound=38 located=38 prose=120 mixed=none total=158 malformed=0
C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=0
```

`caught=6/6` — every leg of the plan's own six-leg table fires with the
expected reason. The kill rule as written (`verified < 37`, `col15 < 32`) is
**not** tripped: 38 ≥ 37 and 33 ≥ 32. But the frozen predicate *label* names
`verified=37 col15=32`, and the tree does not produce those numbers. My
derivation also confirms the L1's BASE receipt (`.ufo/waves/round-68/base/
base-derivation.md`: "BASE verified= 36 rendered= 31 col15match= 31") is
right for BASE, and that 36 → 38 is exactly the two rows the round adds.

**Disposition for the judge, not for me:** the frozen predicate text and the
plan's own frontier step cannot both hold. Either the predicate's numbers
move to 38/33 (which would amend a frozen plan), or the round's own new
source row is excluded from the population (which would contradict "the
census re-verifies every mined row that names a lane-tree capture"). I
changed nothing. The entry quotes no C1 numbers of my own; its §Reproduction
prints the plan's frozen predicate line as the plan's, and the census's own
`path_rows=38` line as the measured one.

### Conflict 2 — the plan names an anchor the plan's own derivation rule does not produce

The plan freezes, verbatim:

> The **anchor** is derived, never named: the LAST capture-path-shaped row in
> file order that binds its declared bytes on the unmodified candidate tree
> (`S166` at the candidate, `S164` at BASE); its id is the mutated id for all
> six legs, and no anchor is a SETUP.

The rule and the parenthetical disagree, in both directions:

- **At the candidate** the rule gives **S167**, not S166: S167's row is last
  in file order (line 201 of `corpus/source-fetches.tsv`) and it binds (sha256
  and byte count verified by me in §2.4). The landed counter derives
  `anchor id=S167 token=.ufo/waves/round-68/capture/S167.body pure=True`.
- **At BASE** the rule gives **S156**, not S164: S156's row (line 199) is
  later in file order than S164's (line 197) and it binds. The parenthetical
  names the *round-67* BASE anchor, which is a different revision's tree.

I measured the anchor both ways and ran the full battery under each
(`mutations/anchor-S167/`, `mutations/anchor-S166/`): all six plan legs plus
three extra shapes produce the same reasons under either anchor, so the
conflict does not change the gate's behaviour — only which id the finding
line names. My entry therefore states the *derived* rule and quotes S167, and
says the same six reasons fire identically with S166 as the anchor.

### Resolved — the landed counter's `guard=0` (now `guard=1`)

The landed counter first printed `guard=0`, with `guard a=1 b=0 c=1 d=1
e=1`. Guard (b) was the census selftest, and at the moment of measurement the
gate's selftest read `SOURCES_CENSUS_SELFTEST: FAIL (98 cases, 2 failed)`
— the two failures were `capture-symlink-escape` and `capture-whitespace-cr`,
both in the gate seat's own landing surface. The gate seat landed them; the
gate's final bytes are `b93f06148a73fd9b7c896056662b3ab1d2a2fe0091506d2f300710824ff2183c`
with `SOURCES_CENSUS_SELFTEST: PASS (98 cases)`, and the counter now reads
`C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1` (rc 0) — see §2.2d.
The gate's bytes moved underneath eight of my measurements (sha256
`e7aacecd` → `127e039b` → `cab6b632` → `65bc4020` → `d74a4183` →
`704a29a3` → `fd3cb598` → `6f18c608` → `b93f0614`), so the battery was re-run
against the last three and every receipt names the sha256 it ran against. I
did not edit the gate.

## 5. S167 registry row and fetch row — drafted, for the L1 to append

Both texts are derived from the bytes I measured in §2.4 and from the lane's
own contract-v1 row shapes (S166's row, the fetch TSV's 16 columns). **I did
not write either** — `corpus/SOURCES.md` and `corpus/source-fetches.tsv` are
not my files.

### 5.1 `corpus/SOURCES.md` — the registry row (11 columns)

```
| S167 | RFC 4648 — Base 16, Base 32, and Base 64 encodings, non-alphabet characters — https://www.rfc-editor.org/rfc/rfc4648.txt | spec | A | record-level strictness: a conforming parser accepts a field's exact form or refuses the record; characters outside the declared alphabet are never silently normalised away | §3.3 Interpretation of Non-Alphabet Characters in Encoded Data; capture `.ufo/waves/round-68/capture/S167.body` (35491 B, sha256 `84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f`); opened live 2026-11-08 with a browser user agent (HTTP 200, 35491 B, same sha256; quote locate count=1 under rendered-text-v1) | Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data | mined | 2026-11-08 | 180d | corpus/knowledge/source-capture-binding.md |
```

Columns, in the registry's order: id · source (title + URL) · kind `spec` ·
tier `A` · scope · anchor (section + capture path + byte count + sha256 +
access date + receipt note) · teaches (the located quote) · status `mined` ·
opened `2026-11-08` · recheck `180d` · used-by.

**Recommendation and reasons.**

- **tier `A`** — RFC 4648 §3.3 is the primary, normative source for the rule
  the census's new `capture-whitespace` / `capture-token` / `SC_FETCH
  cr-in-tsv` reasons enforce (a conforming parser accepts the field's exact
  form or refuses the record). The § is primary: it is the RFC's own
  normative text, not a secondary write-up.
- **status `mined`** — the § states the rule directly; the row carries the
  located quote and the capture it is read from. The row is *not* rejected:
  the § is in scope for the rule it grounds.
- **recheck `180d`** — RFC 4648 is a standards document with no release
  cadence that would fire an `on-release` clock; a dated cadence is the
  honest choice. If the L1 prefers `on-release`, that needs a bound release
  identity (QM23), and RFC 4648 has no version feed in this registry — so
  `180d` is the recommendation.
- **old → new relevance** — the round's own *old* registry state is the
  absence of this row: the round-67 registry's last row is S166, and the
  census's widened reasons had no registry row naming the standards record
  that grounds them. The *new* row adds (i) the S167 id, (ii) the §3.3
  anchor with the capture path and its digest, (iii) the located quote, and
  (iv) `used-by: corpus/knowledge/source-capture-binding.md`, which is what
  closes the `SC_USEDBY_NOCITE id=S167` finding the census prints until the
  entry cites the id. No `status`/`recheck`/`used-by` cell of any existing
  row changes with this append, so no other old→new pair is created by it.
- The used-by cell must name `corpus/knowledge/source-capture-binding.md`
  **and** the entry's `cites:` line must name `S167`; both sides of the
  `SC_USEDBY_NOCITE` / `SC_BODY_CITE` pair are required, and the entry's
  side is done.

### 5.1a Two direct answers to the L1

**S167's fetch-row col 16 is a pure path.** `col16 =
.ufo/waves/round-68/capture/S167.body` — the cell's entire content is one
repo-relative `.ufo/waves/` capture path with no other bytes, so it
classifies as **path** under the widened rule, and S167 is in the census's
read population: it is bound (raw sha256 and byte count both match the
capture) and located (its col-13 quote locates count=1 under
`rendered-text-v1`). Measured on the tree: `path_rows=38 bound=38
located=38 prose=120`, with S167 among the 38.

**Did any of my extra shapes produce a reason §3 does not list? No.** Six
shapes beyond the plan's six legs were run (X1–X3 in the receipts, plus the
`//etc/passwd` and `~/`-form BASE witnesses re-run on the widened gate). Every
reason any of them produced is already named in the entry's §3:

| shape | reason produced | named in §3? |
|---|---|---|
| mixed-prose cell naming a lane capture (X1) | `capture-token` | yes — the round-68 reason table |
| `~/`-prefixed form (X3, `home-tree`) | `capture-token` | yes — the round-68 reason table |
| in-lane-shaped path that does not exist (X2) | `capture-missing` | yes — the round-67 reason list |
| `//etc/passwd` (`slash-tree`, on the widened gate) | `capture-outside-root` | yes — the round-67 reason list |
| trailing CR inside a cell (`cr-cell-tree`, widened gate) | `SC_FETCH cr-in-tsv` (file-level) + `capture-token` for the row | yes — the round-68 reason table |
| comma-joined duplicate (`comma-tree`, widened gate) | `capture-whitespace` | yes — the round-68 reason table |

No shape produced a reason outside the entry's two lists, and no shape
produced a *silent* pass: every one exited 1 with `SOURCES_CENSUS: FAILED`.
One measurement is worth stating precisely, because it is a shape the entry's
§3 table does not list as a separate row: on the widened gate the
`//etc/passwd` cell is classified **path** (an absolute location is path
population, never prose) and therefore keeps the round-67 binding reason
`capture-outside-root` rather than the round-68 `capture-token` — the
classification judges the cell's form and the binding judges its target. The
entry says this in §3 and in §1 ("An absolute or `..`-escaping cell is path
population … never prose").

### 5.2 `corpus/source-fetches.tsv` — the fetch row (16 tab-separated columns)

```
S167	mined	7b4c8e2b5a9b2ca755ccad80d44f0a42b3680c3b07d68fa7f447895b2bd0d4dd	https://www.rfc-editor.org/rfc/rfc4648.txt	https://www.rfc-editor.org/rfc/rfc4648.txt	200	curl-fsSL-compressed-v1	2026-11-08	decoded-http-body-v1	84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f	35491	-	Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data	rendered-text-v1	30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9	.ufo/waves/round-68/capture/S167.body
```

Columns 1–16 as the contract names them: id · status · row-identity digest
(sha256 of `id<TAB>status<TAB>url`) · URL · final URL · HTTP status · request
profile · fetched · representation · raw sha256 (col 10) · decoded byte count
(col 11) · revision · quote (col 13) · normalization (col 14) · normalized
sha256 (col 15) · location (col 16).

Every value is measured, not copied: col 10 and col 11 from `sha256sum` and
`wc -c <` on the committed capture; col 13 located with
`rendered-text-v1.py locate` (count=1, 20 words, within the ≤25-word limit);
col 15 from `rendered-text-v1.py digest`; col 16 the pure repo-relative
capture path, so S167 is in the census's **path** population and is bound and
located by the gate (measured: `path_rows=38 bound=38 located=38`).

**The old → new pair this row creates** (contract v1 rule 2, for the lesson):
the registry had no S167 row and the fetch TSV had no S167 provenance row;
the round adds both, and the *only* pre-existing cell that changes is
S166's col 16 (the recut, owned by `R68ExecRecut`):

- S166 col 16 OLD: `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body`
- S166 col 16 NEW: `.ufo/waves/round-67/capture/S166.body`

## 6. Bounds and limits of this seat's report

1. **The gate's bytes moved eight times under this seat.** The sha256
   sequence I observed on `corpus/sources-census.sh` was `e7aacecd` (BASE) →
   `127e039b` → `cab6b632` → `65bc4020` → `d74a4183` → `704a29a3` →
   `fd3cb598` → `6f18c608` → `b93f0614` (final, selftest PASS 98 cases).
   Every receipt I kept names the gate sha256 it ran against. Three battery
   runs are kept: `65bc4020`, `6f18c608` and the final `b93f0614`; the
   BASE-witness receipts ran against the BASE gate `e7aacecd`. The receipts
   are the evidence and are re-runnable from `driver.py`.
2. **M3's behaviour changed between the gate's byte revisions** (whole-file
   CRLF: from one file-level finding to 39). See §2.2b — the reason set did
   not change, but the cell-level class now fires as well. The entry quotes
   the final behaviour.
3. **The `verified` / `col15` numbers in §2.6 are my own derivation and the
   landed counter's, and both disagree with the plan's frozen label** (38/33
   vs 37/32) — see §4 conflict 1. I did not reconcile it by amending
   anything; the disagreement is the finding.
4. **The `path_rows=38` / `prose=120` figures are the census's own** and are
   re-derived by the command quoted in the entry's §1. They move whenever the
   registry moves; the entry's Reproduction block says so.
5. **My entry's bytes are now final** (sha256
   `81fcf2b9b1971df19847762fdbdbb6fb2e532d732a35ef9f9a150ed279565d5e`, 328
   lines, 22257 bytes) — but this is *before* the ledger seat's last stamp
   (`9cc623b9…`, 314/21196), so **the stamp row is stale again** and the
   ledger seat must re-stamp from the live file. I have told them; I did not
   edit `corpus/stamps.tsv`.
6. **No tool was installed or upgraded** this seat. `/home/vgpnk/.omp/agent/
   RULES.md` (operator rule, 2026-10-19) was read; pacman is paused
   host-wide and was not run. Only the system `python3` (3.14.8,
   `/usr/bin/python3`) stdlib and bash were used.

## 7. Receipts (paths relative to the lane root)

```
.ufo/waves/round-68/w1/R68ScribeEntry.md                       this report
.ufo/waves/round-68/w1/R68ScribeEntry/driver.py                the mutation driver (its own receipt headers)
.ufo/waves/round-68/w1/R68ScribeEntry/mutations/anchor-S167/    the full battery with the derived anchor (10 receipts)
.ufo/waves/round-68/w1/R68ScribeEntry/mutations/anchor-S166/    the same battery with S166 as the mutated id (10 receipts)
.ufo/waves/round-68/w1/R68ScribeEntry/mutations/anchor-S167-gate-6f18c608/
                                              the same battery on the gate's then-latest bytes (10 receipts)
.ufo/waves/round-68/w1/R68ScribeEntry/mutations/anchor-S167-gate-b93f0614/
                                              the same battery on the gate's FINAL bytes, selftest PASS (98 cases) (9 receipts)
.ufo/waves/round-68/w1/R68ScribeEntry/base-witnesses/           seven BASE blindness witnesses + S099's hand measurement
.ufo/waves/round-68/w1/R68ScribeEntry/S167-verification.txt     S167's capture bytes, digests and quote locate, verified by me
.ufo/waves/round-68/w1/R68ScribeEntry/derivation.txt            my independent C1 population derivation + the gate's own line
.ufo/waves/round-68/w1/R68ScribeEntry/c1-counter-final.txt         the landed counter's final reading on the candidate tree
```

Report: .ufo/waves/round-68/w1/R68ScribeEntry.md
