# Round 67 — R67Revenger: capture-binding bypass battery

Seat: revenger (attack, 1 of 13). Lane `kagi-shokunin`, branch master, claim BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179`. Read-only: every tree under test is a
hardlink copy of `git archive HEAD`; every mutation replaces the file inode
(temp + `os.replace`) or creates a new name, so no shared byte was written. The
lane was never edited, no git command mutated anything, nothing was committed,
and no fleet path was touched. Scratch root
`/fast/scratch/hyaku/kagi-r67/R67Revenger` (deleted after the receipts were copied
here).

## What was tested and against which bytes

| role | sha256 | state |
|---|---|---|
| BASE gate (`git archive HEAD`, registry gate before the round's `SC_CAPTURE`) | `e9ae2620ff4ad8e3122f8e7c04c19d16afccf03f0feec7c72edcce78bdd58252` | blindness control |
| landed gate, revision 1 (`232fd182…`, 07:51) | `232fd182900cdc3a5d6ad09607767e06814678146b1feff7ec9c2e1b93fcbfab` | observed on read, not snapshotted; superseded mid-wave |
| landed gate, revision 2 (`34cc1064…`, 07:52) | `34cc1064997bdb379ac59cff70c62a9f6da4279bccce162a103718e9b6fc92ed` | superseded; its own selftest was red at that revision (10/88: fixture rows carried `col15=-` under `rendered-text-v1`) |
| landed gate, revision 3 (`59350492…`, 07:55) | `593504926fecea49f1390685df5623430bdd277bb01cf26c6cbb54f2c99bc57b` | superseded |
| landed gate, revision 4 (`46de3d8c…`, 07:59) | `46de3d8c115ee121e0ae2a0fe55da34c7f821635a0f9ecb651e49f6e5498dbac` | full battery; differs from the final gate on two shapes only (below) |
| **landed gate, final, tested in full** (`e7aacecd…`, 08:23) | **`e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`** | every class result below; selftest `PASS (89 cases)` |
| `corpus/source-fetches.tsv` in the class table | `60fa5d1059ecac55bf4d60f5c6cb2a3db0ca20cd9f48845a89f859f8a80ed1da` | landed S115 re-cut (period dropped), 156 rows |
| `corpus/source-fetches.tsv` at receipt time | `90dd4a2cbc006cdf0a90e42f45917eb9fba9ee7645a9299fb49e79481d38291d` | 157 rows: S166 added; its capture is prose (see C0) |

No class result depends on a network call, `op`, or any sibling lane. The class
tree is the BASE tree with the landed `source-fetches.tsv` and the tested gate
injected at `corpus/sources-census.sh`, so the invocation is exactly the lane's
`bash corpus/sources-census.sh verify --root .`; on that tree the gate reads

```
SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)
SOURCES_CENSUS: CLEAN (rows=156 A=139 B=2 C=15 queued=3 mined=136 rejected=17 entries_sourced=26 legacy=21 captures=156 inrow=16 inrow_only=0 inrow_nonreproducing=12)
```

and this seat's independent recount (its own code, not the gate's) reads the same
four numbers and no defect: `path_rows=36 bound=36 located=36 prose=120`. On the
live lane at the same gate, at receipt time (TSV `90dd4a2c`, 157 rows after S166
landed): `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)` /
`SOURCES_CENSUS: CLEAN`, fleet wrapper `kagi ok` rc 0, selftest `PASS (89 cases)`,
and this seat's independent recount of the live TSV reads
`path_rows=36 bound=36 located=36 prose=121 defects=[]`. The one-row/one-prose
delta is S166 and is the subject of C0.

## 1. Reconstructed check order (final gate `e7aacecd`, `verify()` = lines 292–529)

The gate runs *every* check on *every* row; there is no skip count. Order, with
the line numbers of the tested bytes:

1. **Setup, exits 2** — root dir (292), root canonicalises (293), `SOURCES.md`
   readable (295), `knowledge/` (296), `realpath(1)` present (297),
   `CAP_ROOT=realpath -e ROOT` (298), normalizer selection (299–302,
   `SCRIPT_DIR`-anchored with a hard SETUP if absent). A `setup` here prints one
   `SOURCES_CENSUS: SETUP (…)` and nothing else.
2. **Registry census** — row count, `SC_ZERO` (310); malformed rows `SC_MALFORMED`
   (312–316); tier/status histograms (318, 322); `SC_DUP` (326); `SC_ENUM`/
   `SC_INFLATION` (329–334); `SC_USEDBY_MISSING` existence (338); `SC_SECTIONS`
   (344); registry row shape `SC_MALFORMED "line=… row id not in contract shape"`
   (348); per mined row `SC_REJECT_SHAPE` (358), `SC_MINED_UNUSED` (360),
   `SC_USEDBY_MISSING "not a repo corpus path"` and `SC_USEDBY_NOCITE` (365–369).
3. **Fetch provenance** — file-level `NF!=16` lines → `SC_FETCH line=… nf=…` (392).
   Then, per row **in file order**, with an empty first cell short-circuiting the
   whole row (`[[ -n ${fid:-} ]] || continue`):
   a. **`cap_row` (398) — the new capture read, before every pre-existing row
      check.** Inside: not shaped → `CAP_PROSE++`, return (259); `CAP_PATH++`
      (260); `loc == /*` → `capture-outside-root` (263); `realpath -m` empty or not
      under `CAP_ROOT` → `capture-outside-root` (267–269); not `-e`/`-f` →
      `capture-missing` (272); `stat -Lc %s` ≠ col 11 → `capture-bytes-mismatch`
      (274–277); `sha256sum` ≠ col 10 → `capture-digest-mismatch` (280); if either
      failed, **return** (no quote check); else `CAP_BOUND++` (283); quote empty
      after whitespace strip or `cap_locate` false → `quote-not-located` (286);
      else `CAP_LOCATED++` (288).
   b. `FSEEN`/`FRAW`/`FNORM`/`FFET` are assigned at 395–397, before `cap_row`;
      a duplicate row increments `FSEEN` twice.
   c. registry-row existence → `SC_FETCH not-a-registry-row` (399), the only
      per-row `continue`; then status, url, row-identity digest, final-url, http,
      profile, fetched, representation, digest format, bytes format, revision,
      moving-ref, quote word count, normalization enum, normalized-digest format,
      location length, duplicate-provenance (400–426).
4. **Historical in-row pins** `SC_INROW` (440–468), including
   `SC_FETCH missing-provenance` for every registry row with no provenance (468).
5. **Credential scan** of SOURCES.md (222/471); **knowledge entries**
   `SC_BODY_CITE`, `SC_ENTRY_HEADER`, `SC_ENTRY_CITE`, credential scan (479–511).
6. **Verdict**: `SOURCES_CAPTURES:` line printed at 518 (CLEAN) or 521 (FAILED),
   immediately before `SOURCES_CENSUS:` (524–529); exit 0/1.

Two consequences the counter must respect: (i) `cap_row` runs *before* the
registry-row check, so an unknown-id row is still bound and then also flagged
`not-a-registry-row`; (ii) findings are additive — a row may carry several
`SC_CAPTURE` lines (bytes + digest), and `defects=` counts lines, not rows.

## 2. The nine requested classes — gate verdict, reason, counter count

`BASE` column: the same mutation on the pre-round gate (blindness control).

| # | class, exact input | BASE | tested gate | reason emitted | counter |
|---|---|---|---|---|---|
| 1a | symlink in tree → another body, bytes differ: `.ufo/waves/round-55/capture/S113-sym.body` → `S114.body`, `S113.col16` = that path | `CLEAN` | `FAILED`, rc 1 | `capture-bytes-mismatch`, `capture-digest-mismatch` (id=S113) | counted if the expected reason is digest (repoint leg) — both are present |
| 1b | symlink in tree → same-byte body: `S143-alias.body` → `S143.body`, `S164.col16` = that path | `CLEAN` | **`CLEAN`** | none — bound (36/36/36). On revision 4 this read `FAILED capture-bytes-mismatch` because `stat -c %s` lstat's the link; `e7aacecd` fixes it with `stat -Lc %s` and pins it with the `capture-symlink-intree-control` selftest case | accepted — bytes are the evidence; the earlier refusal was a false positive (C7) |
| 2 | symlink escaping the tree, same bytes: `.ufo/waves/round-55/capture/S113-esc.body` → `../../../../../outside/S113.body` | `CLEAN` | `FAILED`, rc 1 | `capture-outside-root` (id=S113) | yes, for a `..`/outside leg |
| 3a | hardlink in tree → another body, bytes differ: `S113-hard.body` linked to `S114.body`, col16 = link | `CLEAN` | `FAILED`, rc 1 | `capture-bytes-mismatch`, `capture-digest-mismatch` | would count on a digest expectation |
| 3b | hardlink in tree → **out-of-tree** body, same bytes: `S113-hard2.body` (`nlink=2`, inode `1831868836`) linked to `outside/S113-hard.body` | `CLEAN` | **`CLEAN`** | none | **SURVIVED** — see C2 |
| 4a | `./`-prefixed: `./.ufo/waves/round-55/capture/S113.body` | `CLEAN` | `CLEAN` | none | accepted (bound) — correct normalisation |
| 4b | doubled slash: `.ufo//waves/round-55/capture/S113.body` | `CLEAN` | `CLEAN` | none | accepted |
| 4c | inner `./` and inner `../capture`: `.ufo/waves/round-55/capture/./S113.body`, `…/capture/../capture/S113.body` | `CLEAN` | `CLEAN` | none | accepted (realpath inside) |
| 4d | `./../outside/S113.body` (same bytes) | `CLEAN` | `FAILED`, rc 1 | `capture-outside-root` | caught |
| 5a | trailing `0x20`: `.ufo/waves/round-55/capture/S113.body\x20` | `CLEAN` | **`CLEAN`** | none; `path_rows=35 bound=35 located=35 prose=121` | **SURVIVED** — see C1 |
| 5b | trailing `0x09` (17th empty field): `.ufo/…/S113.body\t` | `FAILED` | `FAILED`, rc 1 | `SC_FETCH line=156 nf=17` + `SC_FETCH id=S113 missing-provenance`; no `SC_CAPTURE` | caught by a pre-existing class, not by the binding |
| 5c | leading `0x20`, interior `0x20`, eight spaces, trailing `0x0d` | `CLEAN` | **`CLEAN`** each | none; `path_rows=35 prose=121` (the 0x0d row is `prose=121`) | **SURVIVED** — same as C1 |
| 6a | `\r` at the end of a `rendered-text-v1` quote (S135.col13) | `CLEAN` | `CLEAN` | none — rendered-text-v1 steps 5–6 collapse/strip whitespace, so the quote still locates | accepted (correct per the declared normalizer) |
| 6b | `\r` at the end of a `raw-literal-v1` quote (S113.col13) | `CLEAN` | `FAILED`, rc 1 | `quote-not-located` (id=S113) | caught |
| 6c | `\r` *inside* a rendered quote (space replaced) | `CLEAN` | `CLEAN` | none — whitespace collapse | accepted |
| 6d | literal LF inside the quote (S113.col13) | `FAILED` | `FAILED`, rc 1 | `SC_FETCH line=156 nf=13`, `line=157 nf=4`, `id=S113 missing-provenance`; no `SC_CAPTURE` | caught by the record shape, not the binding |
| 7a | quote that locates only in raw bytes: `<italic toggle="yes">negated</italic>` with col14 `rendered-text-v1` | `CLEAN` | `FAILED`, rc 1 | `quote-not-located` (id=S135) | caught |
| 7b | same span, col14 `raw-literal-v1`, col15 `-` (control) | `CLEAN` | `CLEAN` | none | accepted — correct |
| 1c | symlink chain `S164` → `hop2` → `hop` → `S143.body` (same bytes) | `CLEAN` | `CLEAN` | none — bound (chain resolved by `realpath`) | accepted (revision 4 refused it by the same lstat bug) |
| 8a | 17th column `EXTRA` (or empty) | `FAILED` | `FAILED`, rc 1 | `SC_FETCH line=156 nf=17` + `missing-provenance`; the row never reaches `cap_row` | caught by NF, not by the binding |
| 8b | duplicate row for `S113` | `FAILED` | `FAILED`, rc 1 | `SC_FETCH id=S113 duplicate-provenance`; both rows bound (`path_rows=37 bound=37 located=37`) | caught by the pre-existing class |
| 8c | duplicate location under another id: `S114.col16` = `S113.body` | `CLEAN` | `FAILED`, rc 1 | `capture-bytes-mismatch`, `capture-digest-mismatch` (id=S114) | caught |
| 8d | two paths in one cell: `.ufo/…/S113.body,.ufo/…/S114.body` | `CLEAN` | **`CLEAN`** | none; `path_rows=35 prose=121` | **SURVIVED** — same escape as C1 |
| 9a | `090604`, `+90604`, ` 90604`, `90604 ` in col 11 (file bytes 90604, digest matches) | `FAILED` (SC_FETCH bytes) | `FAILED`, rc 1 | `capture-bytes-mismatch` **and** `SC_FETCH id=S113 bytes`; the capture comparison is a string comparison, so no non-canonical spelling passes | caught twice; counted if a leg expects `capture-bytes-mismatch` |
| 9b | different number `90605` (control) | `CLEAN` | `FAILED`, rc 1 | `capture-bytes-mismatch` | caught |

Extras measured on the same gate: absolute inside the tree → `capture-outside-root`
by the lexical rule (the target resolves inside; the reason string is a policy
label, not a resolved-location fact, and A2.1 legalises that policy); `/./etc/passwd`
→ `capture-outside-root`; `//etc/passwd` → **prose, `CLEAN`** (see C1); `~/S113.body`
→ **prose, `CLEAN`** (C1); `.` → prose but still `SC_FETCH location` (length < 8);
directory location and a self-referential symlink → `capture-missing`; a row whose
id cell is emptied is parsed with a one-field shift (`read` strips the leading
tab) and reported `SC_FETCH id=mined not-a-registry-row` + `S113 missing-provenance`
— caught, not invisible; an unknown id (`S999`) is bound and then
`not-a-registry-row`; a trivially short quote (`the`, count=90) reads CLEAN.

## 3. Survived classes (ceilings) — exact bytes and proposed checks

Every row below is `SOURCES_CENSUS: CLEAN` on the class tree, i.e. the gate does
not fail on the input at all. Receipts: `R67Revenger/receipts/results-live.tsv`,
`survivor-inputs.tsv`, `whole-crlf.txt`, `hardlink-mutability.txt`,
`setup-decode.txt`, `stat-lstat.txt`, `s166-live-addendum.txt`.

### C0 — the round's own sourced-claim row is outside the population (live lane)

Landed after the class table was taken, and measured on a byte copy of the lane at
gate `e7aacecd` / TSV `90dd4a2c` (157 rows):

```
S166.col16 = "§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body"
S166.col10 = 544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a
S166.col11 = 67152        S166.col13 = "Receivers can validate the digest for integrity purposes."   (locate count=1)
whole .ufo/waves/round-67/capture/S166.body: sha256 544dbb7d…, 67152 B
```

The cell contains `/` but not the grammar (it starts `§`), so the row is **prose**:
its declared capture is never read, and `prose` moves 120 → 121. Six probes on the
live copy, every one `SOURCES_CENSUS: CLEAN`:

```
s166-clean              CLEAN (path_rows=36 bound=36 located=36 prose=121)
s166-body-byte          CLEAN (same)   # one byte appended to S166.body
s166-body-delete        CLEAN (same)   # S166.body removed
s166-quote-garbage      CLEAN (same)   # col13 = "zzz absent phrase zzz"
s166-sha-zeros          CLEAN (same)   # col10 = 64 x '0'
s166-loc-shaped         CLEAN (path_rows=37 bound=37 located=37 prose=120)   # col16 = ".ufo/waves/round-67/capture/S166.body"
```

The last line is the control that makes the finding precise: the body, digest and
quote are correct and bind perfectly when the cell is shaped. The round's new
capability therefore covers 36 of the 37 rows that *declare* a capture — the 37th
is the row the round's own sourced claim rests on. A2.2's narrowed sentence is
literally true (it says "capture-path-shaped row"), and **A3.3 now records the
choice and the hand verification** (sha256 `544dbb7d…`, 67152 B, quote count=1 —
this seat re-measured all three). What remains is a standing residual, not a
predicate failure: **no gate re-checks S166**; a later tamper of
`.ufo/waves/round-67/capture/S166.body` or of its col 10/13 is invisible until a
human re-opens it, which is what the six probes demonstrate. Proposed
check: a row with a non-empty `used-by` (i.e. a mined row a knowledge entry
cites) must carry a capture-path-shaped col 16 if it carries any repo-path
evidence — or, more generally, extract whitespace-delimited tokens from a prose
cell, and if any token is capture-shaped and resolves to an existing repo file,
require the row to bind it. Both are rule additions, not implementation fixes;
record as a ceiling or amend.

### C1 — the prose escape hatch: any col-16 deviation silently disengages the binding

`cap_is_shaped` (231–236) admits only `^[A-Za-z0-9._][A-Za-z0-9._/-]*$` (plus the
absolute form); everything else is `CAP_PROSE++` with **no finding** (259). Exact
inputs that leave a capture row unread, with the gate's own summary:

```
S113.col16 = ".ufo/waves/round-55/capture/S113.body\x20"          -> CLEAN (path_rows=35 bound=35 located=35 prose=121)
S113.col16 = "\x20.ufo/waves/round-55/capture/S113.body"          -> CLEAN (path_rows=35 ... prose=121)
S113.col16 = ".ufo/waves/round-55/capture/S113\x20.body"          -> CLEAN (path_rows=35 ... prose=121)
S113.col16 = ".ufo/waves/round-55/capture/S113.body\r"            -> CLEAN (path_rows=35 ... prose=121)
S113.col16 = "\x20\x20\x20\x20\x20\x20\x20\x20"                   -> CLEAN (path_rows=35 ... prose=121)
S113.col16 = ".ufo/…/S113.body,.ufo/…/S114.body"                  -> CLEAN (path_rows=35 ... prose=121)
S113.col16 = "//etc/passwd"                                       -> CLEAN (path_rows=35 ... prose=121)
S113.col16 = "~/S113.body"                                        -> CLEAN (path_rows=35 ... prose=121)
whole source-fetches.tsv saved LF->CRLF (156 rows)                -> CLEAN (path_rows=0 bound=0 located=0 prose=156)
```

The whole-file CRLF variant is the sharpest: every col-16 cell ends in `\r`, every
row becomes prose, and the entire capture check disengages while the gate prints
`SOURCES_CENSUS: CLEAN`. Two of these are *intended* prose under A2.1
("`//etc/passwd`", "`~/S113.body`", a comma-joined value); the trailing/leading
whitespace and the whole-file CRLF are not "prose" in any meaningful sense — they
are a path with one stray byte. Under A2.1's pinned `prose=120` and guard (a)'s
exact line, the *counter* catches a mutation of the real tree, but the *gate*
does not, and a future registry edit that saves the TSV with CRLF would read
CLEAN at every gate level. Proposed checks (either is one line; both are outside
the frozen predicate, so record as a ceiling or amend before use):
(a) file level — `grep -q $'\r' corpus/source-fetches.tsv && finding SC_FETCH cr-in-tsv`;
(b) cell level — if `loc` contains `/`, and `trim(loc)` (both ends, `[[:space:]]`)
is shaped while `loc` is not, emit `capture-missing` for the value as written
(the declared path does not exist) or a new `SC_FETCH location-whitespace`.
Note that (b) does not violate A2.1's "prose … never checked" if it is framed as
a *file-format* finding (SC_FETCH), not an `SC_CAPTURE` read.

### C2 — an in-tree hardlink to an out-of-tree body passes every specified check

```
col16 = ".ufo/waves/round-55/capture/S113-hard2.body"
in-tree  nlink=2 inode=1831868836 size=90604
out-tree nlink=2 inode=1831868836 size=90604
A: no external write              -> CLEAN (path_rows=36 bound=36 located=36 prose=120)   rc 0
B: one byte appended to OUTSIDE/S113-hard.body (no in-tree path touched)
                                  -> FAILED (defects=2) capture-bytes-mismatch + capture-digest-mismatch (id=S113)
```

The realpath is the in-tree name, `-f` is true, size and digest are of the shared
inode, so the row binds; the attested bytes can then change from outside the tree
after the census, and only a *second* run sees it (B). The round's binding is
point-in-time by design (`SC_FETCH` header: "A provenance digest is a point
attestation"), so this is a durability ceiling, not a falsification of the C1
predicate. Proposed check: `[[ $(stat -c %h -- "$file") -eq 1 ]]` for a bound row
(refuse `capture-bytes-mismatch`? no — reason set is frozen; use a new `SC_FETCH
capture-multilink` or record explicitly that a re-verify must precede any use).

### C3 — the declared normalized digest (col 15) is never recomputed

```
S155.col15 = 4d966ff9535cdbd8faa00ad925f60e2fb38892bdb07cd48bb587c9da8aac72d5   # S164's digest
-> CLEAN (path_rows=36 bound=36 located=36 prose=120)
```

The gate checks col 15's **format** only (418) and `C1` binds col 10/11 and the
quote; M66-10's borrowed-normalized-digest class (QM92) is therefore still blind
at the gate. This is outside C1's frozen `bound`/`located`, but it is inside the
round's own motivating evidence, so it belongs in the round report's ceilings.
Proposed check: for a bound row with `norm=rendered-text-v1`, run
`rendered-text-v1.py digest FILE` once and require `normalized_sha256 == col15`;
for `raw-literal-v1`, require `col15 == -` (already enforced by SC_FETCH).

### C4 — the in-tree normalizer is the instrument that decides `located`

```
S135.col13 = "zzz phrase absent from body zzz"
corpus/rendered-text-v1.py replaced by:
    #!/usr/bin/env python3
    import sys
    print('RENDERED_TEXT_V1_LOCATE: count=1')
    sys.exit(0)
-> CLEAN (path_rows=36 bound=36 located=36 prose=120)
```

On revision 4 `CAP_NORM` was `$ROOT/corpus/rendered-text-v1.py` (299), so the
tree under audit chose the instrument. `e7aacecd` moves the anchor to
`$SCRIPT_DIR/rendered-text-v1.py` and hard-fails (`SETUP`) if absent — but in the
lane's own invocation (`bash corpus/sources-census.sh verify --root .`)
`SCRIPT_DIR == ROOT/corpus`, so the gate still reads the tree's own normalizer and
this seat's probe still reads `CLEAN` on the final gate. The class is closed at
the **counter**, not at the gate: R67ExecCounterC1's guard (f) requires the
candidate `corpus/rendered-text-v1.py` to hash byte-identically to BASE
(`14f6ca6a…`) and its own derivation uses the trusted copy (their receipt
`lane-final.txt`; not re-run by this seat). A gate-level pin would be the same
check against a constant embedded in the gate.

### C5 — `located` can be satisfied by a one-token quote

```
S115.col13 = "the"   -> CLEAN (path_rows=36 bound=36 located=36 prose=120)
```

`cap_locate` is a substring/count>=1 test; a 1-word quote locates 90 times in
S115's body. A2.2 already records this as out of the narrowed sentence ("quote
length, provenance and evidentiary strength are not measured") and the landed
S115 re-cut is an 18-word verbatim span by choice. Name it as a ceiling; a
minimum-length rule (e.g. ≥4 words or ≥24 chars for a bound row) would make the
`located` number mean more, but it is a predicate change, not an implementation
bug.

### C6 — a coherent row with an undecodable body aborts the whole census to SETUP

```
S135 body + one 0xFF byte, S135.col10/col11 updated to match (so the row is bound)
-> SOURCES_CENSUS: SETUP (rendered-text-v1 locate failed (rc=2)); rc 2; no SOURCES_CAPTURES line
```

Fail-closed, and the plan already says a SETUP line is never a pass — but one row
can stop the gate from reporting the other 35. Proposed: in `cap_locate`, treat
normalizer rc 2 as a per-row `quote-not-located` (or a named finding) and keep
verifying; reserve SETUP for a missing/non-executable normalizer.

### C7 — `stat` and `sha256sum` disagree about what the location names

**Fixed in `e7aacecd`.** On revision 4, `stat -c %s` did not follow a symlink
while `sha256sum` did (`stat-lstat.txt`: link string 1 B vs target 10 B), so an
in-tree symlink whose realpath is a regular file was refused as
`capture-bytes-mismatch` unless the link-string length happened to equal the
declared byte count (class 1b/1c). `e7aacecd` changes it to `stat -Lc %s` and adds
`capture-symlink-intree-control` (selftest 88 → 89 cases, PASS); class 1b now
binds and reads `CLEAN`. Kept here as the measured history and as the reason the
selftest case exists.

### C8 — the summary line can read CLEAN while a capture row was never checked

```
trailing-tab / 17th-column case: SOURCES_CAPTURES: CLEAN (path_rows=35 …)  and
                                 SOURCES_CENSUS: FAILED (findings=2)       (SC_FETCH nf=17)
```

The `NF==16` filter drops the row before `cap_row`, so the capture summary is
CLEAN with `path_rows=35`. The census verdict is FAILED, so no pass is reachable,
but a consumer that reads the `SOURCES_CAPTURES:` line alone would conclude the
capture class is clean. Proposed: print the data-row count in the summary
(`rows=N`) and have the selftest's `path_rows+prose == data_rows` invariant
enforced by the gate, not only by the selftest.

## 4. Counter implications (C1's six legs and five guards)

Run against the tested gate on the class tree, filtering by the mutated id:

| frozen leg (A2.3) | gate finding for the mutated id | expected reason present? |
|---|---|---|
| M1 repoint (S164 → `S156-429.body`) | `S164 capture-bytes-mismatch`, `S164 capture-digest-mismatch` | yes (`digest`) |
| M2 truncate-by-1 (S113.body −1 B) | `S113 capture-bytes-mismatch`, `S113 capture-digest-mismatch` | yes (both) |
| M3 delete (S113.body) | `S113 capture-missing` | yes |
| M4 absolute (`$TREE/.ufo/…/S113.body`) | `S113 capture-outside-root` | yes |
| M5 `..` (`../outside/S113.body`, same bytes) | `S113 capture-outside-root` | yes |
| M6 quote (`zzz…` on S135) | `S135 quote-not-located` | yes |

So `caught=6/6` is reachable on these bytes — provided the counter accepts **more
than one** `SC_CAPTURE` finding for a row (M1/M2 emit two) and requires the
mutated id (A2.3's own rule). Guard status measured independently:

- (a) met **via A3's derivation** (gate `prose=121` compared to the candidate's
  registry derivation; counter's claim, not re-run here); the gate's line and
  the shaped population are in `lane-gate-verify.txt`. A2.6's `located 35 → 36`
  is the honest delta.
- (b) `SOURCES_CENSUS_SELFTEST: PASS (89 cases)` (`selftest.txt`), `89 >= 84`.
- (c) the BASE gate on the repointed tree prints `SOURCES_CENSUS: CLEAN`
  (`base-blindness.tsv`: the same for every one of the six legs).
- (d) `scripts/sources-census.sh validate --root … kagi` → `kagi ok`, rc 0
  (`fleet-wrapper.txt`).
- (e) the prose rows produce no `SC_CAPTURE` finding (120 on the class tree,
  121 live with S166; clean runs).

### 4.1 Frozen guard (a) is unsatisfiable on the landed 157-row tree

The plan's guard (a) is a literal line comparison (`plans/round-67.md:60-63`):

```
(a) the unmodified candidate tree prints
    SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120);
(e) the 120 prose-location rows produce no SC_CAPTURE finding.
```

On the landed tree (gate `e7aacecd`, TSV `90dd4a2c`; revision 4 printed the same line) the gate prints
`prose=121`; the shaped-S166 control prints `path_rows=37`. Both terms are
156-row properties and the round's own sourced-claim row is the 157th row, so
**no landing of an S166 provenance row can satisfy the literal guard (a)**: a
prose row moves `prose` 120→121, a shaped row moves `path_rows` 36→37, and
omitting the row leaves the round's sourced claim with no capture. The gate is
not at fault; the frozen counter is being measured on a state its term does not
govern (the QM90 class). **Dispositioned after this measurement:** Amendment A3 §2 (landed) re-pins
guard (a) to compare the gate's four counts to the candidate's derivation rather
than to a literal 120, and A3 §3 records S166's capture as hand-verified and
outside the gate. The counter implements that derivation and reads
`C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1`, exit 0
(R67ExecCounterC1's receipt `lane-final.txt`; not re-run by this seat). The
measurement above stands as the reason A3 exists; the round report/lesson must
cite A3 and must never quote `prose=120` as the measured line. Receipt:
`receipts/guard-a-prose.txt`.

BASE blindness, for the record: of the 58 mutation shapes in
`base-blindness.tsv`, the pre-round gate reads `CLEAN` on 46 — all six C1 legs,
the repoint/delete/absolute/`..`/quote classes, both escaping-symlink variants,
the hardlink, every `./`/`//` form, every whitespace form, both CRLF variants, the
raw-only quote, the comma-joined cell, the borrowed normalized digest and the
tampered normalizer. The twelve `FAILED` BASE readings are all pre-existing
`SC_FETCH` classes (NF counts, bytes spelling, duplicate row, the empty-id
shift, the unknown id) or the location-length check (`.`), i.e. QM94's blind
spot is real and the new class is what closes it.

## 5. Calibration and freshness bearing

- **Freshness.** The gate now reads the body at every declared capture location:
  my independent recount of col 10/col 11 and the quote (own code, not the gate)
  matches the gate's `36/36/36/120` exactly, and the mutation battery shows the
  gate changes verdict when a byte changes and does not when only the path
  spelling changes. The re-verification mechanism the round adds is real.
- **Calibration.** The doc/record surfaces must state what this battery shows:
  the gate's numbers are honest, the six frozen reasons are producible, and the
  ceilings are *not* covered. The strongest is **C0**: the census binds 36 rows
  while the registry now *declares* 37 captures, and the 37th is S166 — the row
  the round's own sourced claim cites. A report sentence such as "the census
  reads each declared capture's bytes and quote" is false on the current tree
  unless it says "each capture-path-shaped row"; S166's body, digest and quote
  are read only by hand. C1 (deviation bytes, including the whole-file CRLF
  disengage), C5 (vacuous quote), C6 (SETUP abort), C7 (`stat -L`) and C8
  (summary CLEAN with a dropped row) qualify the same sentence. A2.1/A2.2
  already narrow `prose` and quote strength, so C0/C1/C5 belong in the round's
  ceiling list; C3 (col 15) and C7 (`stat -L`) are cheap in-scope repairs the
  gate can take without touching a frozen predicate; C4/C2 are
  durability/policy ceilings.
- **A2.1's absolute rule.** The landed classifier counts an absolute location in
  `path_rows` (231–236) and A2.1 legalises it; note that `//etc/passwd` (absolute,
  doubled slash) is still prose, so "an absolute location is always
  `capture-outside-root`" holds only for the grammar form `^/[A-Za-z0-9._]…`.
  That is a one-sentence gap between A2.1's two sentences, worth a pin in the
  gate's selftest rather than a plan change.

## 6. Confidence and limits

High confidence in every table entry above: each is a gate run on a fresh tree,
captured verbatim; the class tree's clean control reads the frozen CLEAN line and
the gate's own selftest is green on the tested bytes. Limits, named honestly:
the lane moved during the seat (five gate revisions and two TSV revisions; the
final gate is `e7aacecd…`). Every shape was run on the final gate; the only
outcome changes against revision `46de3d8c` are classes 1b and 1c (now bound, the
`stat -L` fix), and the previous revision's per-case table is kept as
`receipts/results-46de3d8c.tsv`. The class table was taken on TSV `60fa5d10` (156
rows, prose 120); the live-lane addendum was re-taken on TSV `90dd4a2c` (157
rows, prose 121) with the final gate, and the gate and this seat's independent
recount agree on `36/36/36` for the shaped population at both revisions. Everything about S166 is measured on the 157-row tree; the class
table's numbers must be re-derived, not carried, if the registry moves again.
Bind mounts and concurrent-writer races were not tested (the hardlink case is
their deterministic proxy); no network, no `op`, no subagent, no lane write.

## 7. Receipts (paths relative to the lane root)

```
.ufo/waves/round-67/w1/R67Revenger.md                       this report
.ufo/waves/round-67/w1/R67Revenger/receipts/check-order.txt          check-order map of e7aacecd
.ufo/waves/round-67/w1/R67Revenger/receipts/gate-sha256.txt          every gate revision tested
.ufo/waves/round-67/w1/R67Revenger/receipts/lane-gate-verify.txt     live lane, CLEAN + sha
.ufo/waves/round-67/w1/R67Revenger/receipts/selftest.txt             89 cases PASS
.ufo/waves/round-67/w1/R67Revenger/receipts/fleet-wrapper.txt        kagi ok, rc 0
.ufo/waves/round-67/w1/R67Revenger/receipts/independent-counters.txt own recount 36/36/36/120
.ufo/waves/round-67/w1/R67Revenger/receipts/results-live.tsv         all 58 shapes on e7aacecd, verdict + reasons
.ufo/waves/round-67/w1/R67Revenger/receipts/results-46de3d8c.tsv      the previous revision's 56-shape table
.ufo/waves/round-67/w1/R67Revenger/receipts/previous-revision-deltas.txt  46de3d8c -> e7aacecd: 2 outcome changes
.ufo/waves/round-67/w1/R67Revenger/receipts/base-blindness.tsv       BASE verdict per shape
.ufo/waves/round-67/w1/R67Revenger/receipts/survivor-inputs.tsv      exact escaped surviving bytes
.ufo/waves/round-67/w1/R67Revenger/receipts/hardlink-mutability.txt  C2, inode + both runs
.ufo/waves/round-67/w1/R67Revenger/receipts/whole-crlf.txt          C1, path_rows=0
.ufo/waves/round-67/w1/R67Revenger/receipts/s166-live-addendum.txt   C0, six probes on the live 157-row tree
.ufo/waves/round-67/w1/R67Revenger/receipts/guard-a-prose.txt        §4.1, frozen guard (a) vs prose=121
.ufo/waves/round-67/w1/R67Revenger/receipts/setup-decode.txt         C6, SETUP abort
.ufo/waves/round-67/w1/R67Revenger/receipts/stat-lstat.txt           C7, lstat vs follow
.ufo/waves/round-67/w1/R67Revenger/fixtures/driver.py                the battery (mutation + injection)
.ufo/waves/round-67/w1/R67Revenger/fixtures/cases.txt                case → mutation map
```

Report: .ufo/waves/round-67/w1/R67Revenger.md
