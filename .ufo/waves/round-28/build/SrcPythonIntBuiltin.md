# SrcPythonIntBuiltin — round-28 opening: `functions.html#int`

## Verdict
**ADMIT** — one tier **A** `docs` row, scope = *`int()` is not a canonicality oracle*. Not a
**REJECT**. Caveat: this is **not** the "integer string conversion limit" doc the plan names for C1
— `4300` occurs **0 times** on the page; the limit is linked to `stdtypes.html#int-max-str-digits`
(`int-functions.html:161361`), whose default is not opened here. It grounds *acceptance* semantics
(why lexical canonicality is required), not the fixture's numeric bound; if the lesson must cite
4300, L1 needs that second row too.

## Fetch record (access date 2026-10-21)
| field | value |
|---|---|
| requested | `https://docs.python.org/3/library/functions.html#int` (fragment never sent) |
| final | `https://docs.python.org/3/builtins/functions.html` — first hop HTTP/2 **301** with `location:` |
| status / type | **200**, `text/html` |
| bytes | **330313** (equals `content-length`; etag `"6ad8b85d-50a49"` ⇒ 0x50a49 = 330313) |
| raw sha256 | `15ae2918baa5b317e728f7d2bce252a149e485a70a458971f1d007cbfd1858b6` |
| last-modified | `Wed, 21 Oct 2026 13:04:29 GMT` (same day ⇒ volatile) |
| exact title | `Built-in functions — Python 3.15.1 documentation` |
| canonical link | `https://docs.python.org/3/builtins/functions.html` |
| heading / entry | H1 `Built-in functions¶`; `class int(number=0, /)` / `class int(string, /, base=10)` |
| anchor | `id="int"` unique; 12 in-page `href="#int"` |

Saved in `.ufo/waves/round-28/sandboxes/SrcPythonIntBuiltin/`: `int-functions.html`,
`int-functions.headers`, BASE copies `rendered-text-v1.py` and `base-release-clock.py`.

## Required quote (verbatim, 17 words, locator `#int`)
> Base 0 also disallows leading zeros: int('010', 0) is not legal, while int('010') and int('010', 8) are.

Locator: Built-in functions → `class int(string, /, base=10)` → base-0 paragraph (last sentence of
the paragraph starting "A base-n integer string contains digits"). Located `True` under the four
committed `rendered-text-v1` steps copied from BASE `corpus/rendered-text-v1.py:70-84`
(script/style drop, tags→space, `html.unescape`, Unicode whitespace collapse); ASCII apostrophes
only. Normalized point-digest `f3fbf6198bc73b8b1ad952314e616e1ffb9c2cddb6c6b668abd90e24a4283625`
(81846 chars; chrome-coupled — the census enforces shape, not equality: `sources-census.sh:281`).

Supporting verbatim fragments (same locator, each ≤25 words): “have leading zeros, be surrounded by
whitespace, and have single underscores interspersed between digits” (14) — page example
`int('   -12_345\n')` → `-12345`; “The values 0–9 can be represented by any Unicode decimal digit.”
(11); “A ValueError is raised when the limit is exceeded while converting a string to an int” (16,
3.11 versionchanged, sentence continues).

## Why `int()` cannot decide canonicality — BASE
`int()` is the bridge that makes two disagreeing comparisons look consistent:

- `corpus/release-clock.py:366-380` — `NUMERIC_VERSION_RE = [0-9]+\.[0-9]+\.[0-9]+` then
  `tuple(int(part) …)`: `3.15.01` and `3.15.1` map to the **same** `(3,15,1)`, so the token is
  accepted as well-formed and no inconsistency is raised.
- `corpus/release-clock.py:582-583` — `norm_version` strips only a leading `v`
  (`:362-363`), so string inequality makes that same pair read **fired**: the plan's defect.
- `corpus/release-clock.py:404-409` (feed floor), `:759-761` (`max(… key=tuple(int(part)…))` over
  feed titles), `:443-444` (receipt `parsed_version` by `norm_version` string equality): the same
  int-collapse applies to anchors, feed titles and receipts.
- Oversize: `int()` at `:380`/`:760` raises a bare `ValueError` and nothing catches it around
  `numeric_version` — F2/F4's traceback. The 3.11 note grounds this as *documented* behaviour, so the
  fix is lexical validation **before** conversion plus a typed finding, not catching an accident.
- Narrow-fix counterexample: rejecting leading zeros only at `:582` still lets `is_regression`
  (`:567-568`) treat `3.15.01` as equal; canonicalising only `observed_version` leaves anchors
  (`:404`), feed titles (`:760`) and receipts (`:444`) open. Canonicality is needed at all five sites.

Local probes (`python3 -I -B`, 3.14.8, `sys.get_int_max_str_digits()`=4300): `int('010')==int('10')`
→ `True`; `int(' 15 ')`→15; `int('1_5')`→15; `int('١٥')`→15 (Arabic-Indic); `int('１５')`→15
(fullwidth); `int('1'*4300)` ok; `int('1'*4301)` → `ValueError: Exceeds the limit (4300 digits) …`.
Runtime observation of documented behaviour, not a new documentation claim.

## Duplicate / W04
None. `grep -rn functions.html corpus/` → no registry row; no `/3/builtins/` URL in
`corpus/SOURCES.md`. BASE python.org duplicates only `re.html` (S027 `:33`, S040 `:47`), `html.html`
(S028 `:34`, S041 `:48`), the downloads feed (S039) — all already W04 in
`.ufo/waves/round-28/census-start.txt`. This row adds no W04. Do not register the pre-redirect
`/3/library/functions.html` as a second row: one page under two URL strings would be a new W04.

## Proposed wording (id|source|kind|tier|scope|anchor|teaches|status|opened|recheck|used-by)
- id `S044` (BASE max S043; L1 reassigns if taken, then recompute the identity digest).
- source `Built-in functions — int() — https://docs.python.org/3/builtins/functions.html`;
  kind `docs`; tier `A`; status `mined`; opened `2026-10-21`; recheck **`90d`**;
  used-by `corpus/lessons/round-28.md`.
- scope `version-token canonicality: Python int() accepts leading zeros, sign, whitespace, single underscores and any Unicode decimal digit — lexical rules, not int(), decide a canonical token`
- anchor `Built-in functions → int() → class int(string, /, base=10) base-argument paragraph; #int; title Python 3.15.1 documentation, fetched 2026-10-21; served at /3/builtins/functions.html (301 from /3/library/functions.html)`
- teaches `A version token cannot be canonicalised by int(): default base accepts leading zeros, so int('010') == int('10') and a 3.15.01 component collapses to 3.15.1's value; surrounding whitespace, single underscores and non-ASCII decimal digits are also accepted; components past the conversion limit raise ValueError (3.11+). Canonicality is therefore lexical and decided before conversion, and an out-of-bounds component becomes a typed finding. Quote: “Base 0 also disallows leading zeros: int('010', 0) is not legal, while int('010') and int('010', 8) are.” (#int, base-0 paragraph). The 4300 default is not stated here; it is at https://docs.python.org/3/library/stdtypes.html#int-max-str-digits, linked from the 3.11 note.`

### Recheck must stay off `on-release`
`on_release` = rows whose recheck is `on-release` (`release-clock.py:509-512`), and the frozen
control pins `on_release=30 bound=30 observed=30` — 30 rows at BASE (column 11: 27 mined + 1 queued
+ 2 rejected). A new `on-release` row would need a clock row + receipt (else `UNBOUND`/`NOT OBSERVED`,
`:518`) **and** change the frozen control to 31. `90d` keeps it byte-identical and needs no
`release-clocks.tsv` row (a clock row for a non-on-release row is `ORPHAN`, `:518-521`). Do not mark
it `derived:` either — `derived=15` is frozen.

### Fetch-provenance row (16 columns, `corpus/source-fetches.tsv`)
`S044  mined  <identity>  https://docs.python.org/3/builtins/functions.html  https://docs.python.org/3/builtins/functions.html  200  curl-fsSL-compressed-v1  2026-10-21  decoded-http-body-volatile-v1  15ae2918…d1858b6  330313  -  <quote>  rendered-text-v1  f3fbf6…4283625  Built-in functions, int(), base-argument paragraph (#int)`
`<identity>` = sha256 of `S044\tmined\thttps://docs.python.org/3/builtins/functions.html\n` =
`1a91d01cb191e09d4c37876ffce0ef06bde07db126bea8941ca58171f93a804f`. `volatile` because of the
same-day `last-modified` and version-switcher chrome (matches S040/S041). The census requires this
row for every id (`sources-census.sh:328`) and byte-equality of `url` with the source cell (`:261`).

## Calibration ties
- Page title **3.15.1** equals S040/S041 anchors (`corpus/release-clocks.tsv:30-31`): no docs-version
  drift at opening. The fixtures' `3.15.01` is lexically non-canonical yet numerically equal — this
  source explains *why* (int collapse), not merely that.
- `safe_receipt_url` drops fragment/query (`release-clock.py:224-244`) and `source_url` applies it
  (`:50-55`), so `#int` in the cell is clock-safe; the census regex would keep it, so omit it to keep
  source-cell URL, fetch `url` and receipt URL byte-equal.

## Commands run (all exit 0 unless noted)
`curl -sS -L -o int-functions.html -w …` (200/330313); `sha256sum`; `curl -sS -o /dev/null -D
int-functions.headers -L …`; `curl -o /dev/null -w '%{redirect_url}'` (301 hop); `python3 -I -B`
normalizer-locate run (5/5 `located=True`) and int() probes (4301-digit ValueError captured);
`git show 3553d49:corpus/{SOURCES.md,release-clocks.tsv,release-clock.py,rendered-text-v1.py}`
(read-only, BASE line numbers); `grep` duplicate audit; `awk` status/recheck census.

## Did NOT check
- Did not open `stdtypes.html#int-max-str-digits`; 4300 is evidenced by the local interpreter and the
  page's link, not the limit document.
- Did not run the lane census, `release-clock.py --selftest`, or any round-28 fixture; all
  `release-clock.py` claims are static reads of the BASE blob.
- Did not test cache/`Accept-Encoding` variance; the digest is one decoded body.
- Did not confirm S044 is free at integration time, nor inspect other seats' proposed rows.
