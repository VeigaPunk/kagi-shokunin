# K41ScoutSources — notes (round 41, kagi, attempt 1)

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Predeclaration commit: `5142b52` (frozen plan `plans/round-41.md`).
Claim BASE: `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`.
Round-40 landed state (C1 positive control P0): `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`.
Round-40 claim BASE: `6cc8850dfc5757927699e5a53a876f47c8df21aa`.

Scratch (created, used, removed on yield):
`/fast/scratch/hyaku/kagi-r41/K41ScoutSources` — `S=$S` below.
No lane file was created, edited, or deleted. No `git add/commit/stash/checkout/
switch/reset/pull/push`, no mutating `jj`, no `corpus/SOURCES.md` edit, no
`claim-ledger.sh verify` run, no pacman/uv/cargo install (tooling: **none**
needed; `curl`, `python3`, `cmp`, `sha256sum`, `wc`, `git show` all present).

Deliverables (this directory):
- `notes.md` (this file)
- `s095-cmp.txt`
- `datawalk-c1.txt`
- `capture/S095.body`, `capture/S096.body`, `capture/S097.body`, `capture/S098.body`
  (live bodies, staged so the integrator can copy them to `.ufo/waves/round-41/capture/`)
- Report: `.ufo/waves/round-41/build/K41ScoutSources.md`

---

## 1. S095 re-open — IDENTICAL to the round-40 capture

```
S=/fast/scratch/hyaku/kagi-r41/K41ScoutSources
curl -fsSL --compressed https://docs.python.org/3/library/re.html -o "$S/S095-live.body"   # exit 0
sha256sum "$S/S095-live.body"
  ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1
wc -c "$S/S095-live.body"   -> 257722
cmp "$S/S095-live.body" /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-40/capture/S095.body
  exit 0, no output  -> IDENTICAL, no differing byte offsets
```

`<title>` (live): `<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>`
HTTP: `http=200`, `final_url=https://docs.python.org/3/library/re.html`, `redirects=0`.

Frozen quote locate (live body):

```
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py \
  locate $S/S095-live.body 'Matches Unicode whitespace characters (as defined by'
  RENDERED_TEXT_V1_LOCATE: count=1     exit 0
```

Same locate on the **committed** round-40 capture body
(`.ufo/waves/round-40/capture/S095.body`): `count=1`, exit `0`.
Raw byte offset of the quote: live `75897`, committed capture `75897` — matches the
S095 fetch-row location cell (`...raw-byte-offset-75897`) and the S095 registry row.

Digest of the committed capture:
`raw_sha256=ef2d8abe...469b1 bytes=257722 normalized_sha256=dc9e4eba75965de6f08c8163635d758e923c94d13dee170a7380673a1c39e1c9 normalized_bytes=69356`.

**C2 (b) precondition, measured on committed bytes:** the S095 row's column-10
sha256 in `corpus/source-fetches.tsv` is `ef2d8abe...469b1`, equal to the
`sha256sum` of the capture body, and the locate on that body exits 0 for the
frozen quote. The binding holds today, before any edit.

## 2. S096 re-open — IDENTICAL to the round-40 capture

```
curl -fsSL --compressed https://docs.python.org/3/library/html.html -o "$S/S096-live.body"  # exit 0
sha256sum  -> 570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5
wc -c      -> 20100
cmp "$S/S096-live.body" .../round-40/capture/S096.body   -> exit 0, no output (IDENTICAL)
```

`<title>` (live): `<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>`
HTTP: `http=200`, no redirect.
Quote locate, live body: `python3 corpus/rendered-text-v1.py locate "$S/S096-live.body" 'This function uses the rules defined by the HTML 5 standard'` -> `count=1`, exit `0`.
Same locate on the committed capture body: `count=1`, exit `0`.
Raw offset of the quote: live `13521`, committed capture `13521` (matches the S096
fetch-row cell `html5-unescape-rules-raw-byte-offset-13521`).
Digest: `normalized_sha256=da6d2f57b5f29b9b43016218f3a6fe4eb331779539d1b3b290ae47705b89d68d normalized_bytes=2395`.

**Freshness note:** both pages re-download byte-identically to the round-40
captures, so the round-40 committed bytes are a faithful representation of the
served pages as of today (2026-11-05). No re-capture is needed for S095/S096.

## 3. Supplementary live opens (plan §Shape: scout opens S095, S097, S098)

**S097 candidate — Python 3.15.2 stdtypes, `str.isspace()`:**
`https://docs.python.org/3/library/stdtypes.html` -> `http=200` final
`https://docs.python.org/3/builtins/stdtypes.html` (**301 redirect on the first
hop** — a fetch row must record `url` and `final_url` separately, `http_status 200`).
sha256 `e2992e17d9b8f15f09b2971e356d06c5e0f1572fefa6ce733eb6d7d48466e2b3`, bytes `815447`.
`<title>Built-in Types &#8212; Python 3.15.2 documentation</title>`.
`normalized_sha256=1a84e37d72a3ca5ea93a089dbc861eba281bb1adfff26732bd8c1715ccdc2f3e normalized_bytes=197526`.
Locates (live body): `Return True if there are only whitespace characters in the
string and there is at least one character, False otherwise.` -> `count=1` exit 0;
`A character is whitespace if in the Unicode character database` -> `count=1` exit 0;
`IDEOGRAPHIC SPACE` -> `count=1` exit 0 (raw offset `296299`).

**S098 candidate — Unicode UTS #18 (the plan's REJECT):**
`https://www.unicode.org/reports/tr18/` -> `http=200`, no redirect.
sha256 `68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d`, bytes `199607`.
`<title>UTS #18: Unicode Regular Expressions</title>`.
Locates: `White_Space` -> `count=4` exit 0; `Unicode Regular Expressions` -> `count=2` exit 0;
`UTS #18` -> `count=1` exit 0; `\p{White_Space}` -> `count=0` exit 1.
The literal text `\p{White_Space}` does not occur in the served body (raw find
`-1`); `White_Space` occurs at raw offset `45641` as a property-name table cell.
A registry row for UTS #18 could not carry a raw-literal `\p{White_Space}` quote
from this body.

**Reject corroboration for S098 (independent, read-only probe):** comparing
`str.isspace()` against the 25 UTS #18 `White_Space` code points over all of
U+0000..U+10FFFF (python 3.14.8, unicodedata 16.0.0): **4 differences**, all
`isspace()==True` but not `White_Space`: `0x1c 0x1d 0x1e 0x1f`; zero code points
the other way. This reproduces the plan's stated reject reason.

**U+3000 (M40-5) — re-measured:** the literal U+3000 byte sequence is **not**
present in the served 3.15.2 stdtypes body nor in the served `re` body (raw
`in` test: `False` for both). The stdtypes page shows the escape form `\u3000`
inside the doctest plus the comment word `IDEOGRAPHIC SPACE`; the class
definition itself is present ("...either its general category is `Zs`
("Separator, space"), or its bidirectional class is one of `WS`, `B`, or `S`.",
raw offset of `its general category is` = `296702`). Consequence for C2: the
U+3000 derivation may be sourced to S097's `Zs` sentence, **not** to S095, and
not to a raw-literal U+3000 quote.

## 4. C1 data-walk (read-only; `git show` only)

Full output: `datawalk-c1.txt`. Summary:

**(a) Ledger debt — expects with an unescaped regex metacharacter in the interior**
(interior = the expect minus a leading `^` and a trailing `$`; metacharacter set
`. [ ] ( ) * + ? { } | ^ $`; a backslash escapes the next character).

**COUNT = 8** at P0 `6f1588c`:

| id | interior metachars | anchored `^...$`? |
|---|---|---|
| R11-01 | `[ ] * [ ] * [ ] + [ ] *` | no (trailing `*`, not `$`) |
| R11-02 | `[ ] * [ ] +` | no |
| R11-04 | `[ ] * [ ] *` | no |
| R11-06 | `[ ] *` | no |
| R11-08 | `[ ] * [ ] *` | no |
| R12-01 | `[ ] * [ ] * [ ] * [ ] *` | no |
| R13-03 | `[ ] +` x8 | **yes** |
| R31-01 | `[ ] +` x3 | **yes** |

Split: 2 anchored (`R13-03`, `R31-01`) + 6 unanchored. All 8 have bracket-class
and quantifier metacharacters; none has an unescaped `(`/`)`/`.`/`|`/`{`/`}`
(the parens in the ledger are already backslash-escaped, e.g. `\(`, `\)`).

Full R3 projection over **all** 86 P0 rows (R3 = anchored AND no unescaped
interior metachar): **71 satisfy, 15 do not**. The 15 = the 8 above plus 7
rows that are simply not `^...$` anchored with no metachar in the interior
(`R11-03`, `R11-05`, `R11-07`, `R11-09`, `R12-02`, `R14-01`, `R25-04`).
These 15 are **pre-existing debt**: R3 only refuses a *changed* expect, so
today's tree is not refused by it. Any future change to one of the 8 in (a)
would be refused, and the gate author needs to know the debt exists.

**(b) ids present in BASE `6cc8850` but absent at P0 `6f1588c`: COUNT = 0.**
Symmetrically, ids present at P0 but absent at BASE: **0**. Both ledgers carry
**86** rows; the row set is identical (additions/deletions only, no id churn).

**(c) changed ids BASE -> P0 (command col 2 or expect col 3): COUNT = 6**
(6 field-level changes, all in column 3; no command was rebound at round 40):

| id | kind | old -> new |
|---|---|---|
| R13-01 | expect | `^50$` -> `^54$` |
| R21-02 | expect | SOURCES_CENSUS rows=93/A=89 -> rows=96/A=92 |
| R24-06 | expect | ROW_IDENTITY count=50 sha `0cbb2da2…` -> count=54 sha `52e7ba8d…` |
| R31-02 | expect | same census summary as R21-02 |
| R33-02 | expect | same census summary as R21-02 |
| R34-03 | expect | same census summary as R21-02 |

Round-40 journal ids (`.ufo/waves/round-40/expectation-migrations.json`) = the
same **6** ids. **changed == journal: True**; changed-not-journaled = `[]`;
journaled-not-changed = `[]`. No orphaned journal entry, no unjournaled change:
the round-40 journal is exactly the R1 changed set.

**R2 binding check (all six, all True):** each journal entry's `old_expect`
equals the BASE expect literally, its `command` equals the candidate ledger
command literally, and its `new_expect` equals the candidate expect literally.
So on the six round-40 migrations the gate's R2 checks would all pass.

**R3 on the six migrations at P0: all six are R3-satisfying** (anchored, every
interior metacharacter backslash-escaped: `\(`, `\)`). Their journal
`new_expect` values are byte-identical to the candidate expects, so R3 on the
journal side agrees with R3 on the ledger side. The C1 kill rule
("none of the six round-40 migrations is refused by the gate at the landing")
is satisfiable from the committed bytes — the migrations are literal, anchored,
and correctly journaled.

## 5. Frozen counters and controls as they read at the predeclaration tree

Executed read-only from the lane root at `5142b52` (the tree still carries the
round-40 normalizer docstring and no `corpus/expect-journal.sh`):

```
bash plans/round-41-c1.sh      -> prints 0        exit 0     (no gate file yet: N=0)
bash plans/round-41-c2.sh      -> prints 1        exit 0     (a=0, b=0, c=1: BASE-equivalent)
bash plans/round-41-controls.sh:
  CONTROL c1-blanket-refuse N=0
  CONTROL c1-blanket-accept N=0
  CONTROL c1-no-gate N=0
  CONTROL c2-decoy-superseded N=2
  C2 BASE N=1
  exit 0
```
These match the plan's stated control expectations (every C1 control 0; C2 decoy
<= 2; C2 BASE 1). They are the pre-change readings, not the candidate readings.

## 6. Calibration notes for the executor / reviewer seats

1. **The C2 counter's binding already holds** on the committed bytes: S095's
   fetch-row column-10 sha256 equals the committed capture body sha256 and the
   locate on that body exits 0 for the frozen quote. A C2 rewrite of the Sources
   paragraph does **not** require a new capture; it requires the paragraph to
   cite a non-superseded `S###` id and to contain the frozen quote.
2. **Superseded-id list** (from `grep -oE 'supersedes S[0-9]{3}' corpus/SOURCES.md`,
   `S###` extracted): `S006 S007 S012 S013 S014 S016 S027 S028 S034 S035 S036
   S039 S040 S041 S047 S049`. `S095` is **not** superseded; `S027` **is** (which
   is why the C2 decoy control reads (a)=0). `S097`, if added as a row citing
   S095/S097, must not cite any id in that list.
3. **R3 debt is real but currently dormant**: 8 of 86 P0 expects carry unescaped
   bracket/quantifier metacharacters; 2 of them (`R13-03`, `R31-01`) are
   `^...$` anchored. If the gate's R3 is written to apply to *all* rows rather
   than only changed rows, the positive control P0 would be refused and the C1
   counter would read 0. R3 must be scoped to changed rows (as the plan says).
4. **The `locate` command is read-only** on the named file: it prints
   `RENDERED_TEXT_V1_LOCATE: count=<n>` and exits 0 when `n>=1`, 1 when `n==0`,
   2 on setup failure. Exit 1 is "quote not found", not a crash — the S098
   `\p{White_Space}` probe above legitimately exited 1.
5. **U+3000 is not raw-literal on the served pages** (re-measured, see §3). Any
   C2 docstring sentence that asserts the U+3000 example must be grounded in
   S097's `Zs` sentence or recorded in the round lesson's Gate, not in a raw
   byte offset claim on S095.
6. **S097's URL 301-redirects** (`/3/library/stdtypes.html` ->
   `/3/builtins/stdtypes.html`). A `source-fetches.tsv` row for S097 must record
   `url` and `final_url` and take `http_status` from the final hop, or the
   census will read it as a non-reproducing capture.
