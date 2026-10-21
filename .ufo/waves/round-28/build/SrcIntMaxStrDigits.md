# SrcIntMaxStrDigits — opening: `stdtypes` integer-string conversion length limitation

**Verdict: ADMIT** — one tier **A**, kind `docs`, `recheck 90d` (**not** `on-release`), **no** `release-clocks.tsv` row, **no** in-row `Fetch sha256:`. It grounds only the **4300-default / ValueError** half of C1; the leading-zero half is not on this page (S042 + the sibling `int()` row carry it). Id is L1's: **do not assume S044** — see the collision note.

## Fetch record (access date 2026-10-21; nothing installed)

| field | value |
|---|---|
| requested → final | `https://docs.python.org/3/library/stdtypes.html#integer-string-conversion-length-limitation` (fragment never sent) answers **HTTP/2 301** with `location: https://docs.python.org/3/builtins/stdtypes.html` (curl 8.23.0, `-D -` without `-L`); final URL is **HTTP 200** |
| request profile | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` → exit 0; body byte-identical to a no-UA/no-compress fetch (`cmp`) |
| body | **814482 bytes** decoded at `https://docs.python.org/3/builtins/stdtypes.html`; sha256 `7dcb450d84d0176f7d7d996853d7be8b19b3e9a49479f67c5f8efc74627e1ff2`; transfer 102358 gzip bytes |
| headers | `last-modified: Wed, 21 Oct 2026 13:04:29 GMT`; `etag: "6ad8b85d-c6d92"` (0xc6d92 = 814482) |
| exact title | `Built-in Types — Python 3.15.1 documentation` (`<title>Built-in Types &#8212; Python 3.15.1 documentation</title>`) |
| section / date | H2 `Integer string conversion length limitation`; `id="integer-string-conversion-length-limitation"` and alias `id="int-max-str-digits"` occur once each; footer `Last updated on Oct 21, 2026 (13:02 UTC).`; section ends `Added in version 3.11.` |
| canonical link | `<link rel="canonical" href="https://docs.python.org/3/builtins/stdtypes.html">` |

Saved as `stdtypes.html`, `stdtypes.compressed.html`, `stdtypes.ua.html` under `.ufo/waves/round-28/sandboxes/SrcIntMaxStrDigits/` (all three identical bytes/digest); BASE tree extracted there with `git archive 3553d49…` (exit 0).

## Required quote (verbatim, located under rendered-text-v1)

Primary (11 words): **“The default limit is 4300 digits as provided in sys.int_info.default_max_str_digits .”** Locator: §Integer string conversion length limitation (#integer-string-conversion-length-limitation, alias #int-max-str-digits), the paragraph after the traceback example; `rendered-text-v1.py locate` → `count=1`, exit 0.
Second (11 words): **“When an operation would exceed the limit, a ValueError is raised:”** same heading, preceding paragraph; `count=1`, exit 0.
The space before the final `.` is the committed normalizer's artifact (`</a>` → one SPACE, then `.`); S040's `str.isspace() )` is the same shape (`corpus/SOURCES.md:47`). The “clean” form without that space returns `count=0` (exit 1) — do not tidy it. Normalized page point-digest (`rendered-text-v1.py digest`): `c6c84fedcf90996487ec8bd7d20ed025134db15a7495b22c04deac5cd97bd938` (normalized bytes 197388).

## Why it grounds C1 (BASE evidence, static + sandbox probe)

- `corpus/release-clock.py:380` `tuple(int(part) …)` is a base-10 string→int conversion; `:760` does the same in `max(stable, key=…)` over feed titles; both admit a 4301-digit component to `int()`.
- `:567-568` (`is_regression`, via `:385-386`) and `:404-408` (`feed_floors`) reach `numeric_version` unguarded; `main` catches only `SetupError` (`:1749`), so the `ValueError` escapes as a traceback — the plan's F2/F4 premise (`plans/round-28.md:33`).
- Sandbox import of BASE: `"3.15."+"1"*4300` → tuple; `+4301×"1"` → `ValueError: Exceeds the limit (4300 digits) for integer string conversion…`. 4300 is the boundary, exactly as the page states.
- Non-goal proved on the same function: `numeric_version("3.15.01") == (3,15,1)` and `version_is_named(anchor,"3.15.01") == False`; int-collapse is why a lexical rule is needed, but that fact is §int() on the sibling page, and the rule is S042 (`corpus/SOURCES.md:49`).

## Duplicate / W04

`grep -n 'library/stdtypes\|builtins/stdtypes\|integer-string-conversion' corpus/SOURCES.md` → **no match, exit 1**. Registering `/3/builtins/stdtypes.html` adds **no** W04 line (START census lines 2–12 are other URLs). Existing python.org rows: S027/S040 (`re.html`), S028/S041 (`html.html`), S039 (downloads feed). Register **one** URL: the `/3/library/` alias and the `/3/builtins/` final are one page; two rows would be one page under two strings (the trap the sibling flags for `functions.html`).

## Proposed registry row (11 cells; substitute a real id for `S0NN` — the census row regex rejects literals)

```
| S0NN | Built-in Types, Integer string conversion length limitation — https://docs.python.org/3/builtins/stdtypes.html | docs | A | CPython's default decimal int-string conversion limit (4300 digits, ValueError on excess): the outer bound that makes a lexical version-component bound necessary; not a canonicality rule and not a feed rule | §Integer string conversion length limitation (#integer-string-conversion-length-limitation, alias #int-max-str-digits), default-limit paragraph; title Python 3.15.1 documentation, Last updated on Oct 21, 2026 (13:02 UTC), fetched 2026-10-21; requested /3/library/stdtypes.html answers 301 to the registered /3/builtins/stdtypes.html (page canonical link) | CPython's default int-string conversion length limit is 4300 digits and an over-limit base-10 conversion raises ValueError; the limit is configurable and does not apply to base 2/4/8/16/32. Quotes: “The default limit is 4300 digits as provided in sys.int_info.default_max_str_digits .”; “When an operation would exceed the limit, a ValueError is raised:” (rendered text). A version component parsed with int() must be bounded well below 4300 and typed as a finding, never a crash. This does not establish leading-zero canonicality (S042) or feed semantics. | mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |
```

Mechanics: 12 `|` → 13 awk fields; the anchor carries `3.15.1`, so `version_is_named` matches `3.15.1`/`v3.15.1` and rejects `3.15.10`, `3.15`, `3.15.01` (probed). `used-by` cites the round-28 lesson, which must exist and carry `S0NN` on its `source:` line (`corpus/sources-census.sh:227-231`).
**Why `90d`, not `on-release`:** `on_release` is exactly the `recheck == "on-release"` set (`corpus/release-clock.py:509-513`), and a clock row for a non-`on-release` source is `ORPHAN` (`:518-519`). A 31st `on-release` row needs a clock row + receipt and changes the frozen control line `on_release=30 bound=30 …` (`plans/round-28.md:42`) to 31; `90d` keeps it byte-identical. This row is not `derived:`, so C2 does not bind it (and `derived=15` stays frozen).

## Proposed provenance row (`corpus/source-fetches.tsv`, 16 tab columns)

```
S0NN	mined	<IDENTITY>	https://docs.python.org/3/builtins/stdtypes.html	https://docs.python.org/3/builtins/stdtypes.html	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	7dcb450d84d0176f7d7d996853d7be8b19b3e9a49479f67c5f8efc74627e1ff2	814482	-	The default limit is 4300 digits as provided in sys.int_info.default_max_str_digits .	rendered-text-v1	c6c84fedcf90996487ec8bd7d20ed025134db15a7495b22c04deac5cd97bd938	Integer string conversion length limitation, default-limit paragraph (#integer-string-conversion-length-limitation)
```

`<IDENTITY>` = `printf '<id>\tmined\thttps://docs.python.org/3/builtins/stdtypes.html\n' | sha256sum` (trailing newline is part of the key, `sources-census.sh:262`). Example only if L1 gives this row S044: `5cb1b37e07b5025c2caa71b90ddffaf26cafa1cd1eba9d0590704450d45cbc55`; the alias URL would hash `fc2d71bf…`. Representation is `volatile` (same-day `last-modified`, version-switcher chrome; S040/S041 precedent, `corpus/source-fetches.tsv:83-84`). Quote is 11 words (census cap 25); `missing-provenance` is enforced at `sources-census.sh:328`.

## Tier, reject decision, limits

- **Tier A** for CPython-runtime behaviour (the clock executes CPython; this is the CPython project's own documentation). It would be **B** if cited as a Python *language* rule: the page says “CPython has a global limit”, the limit is configurable, and the language reference is elsewhere.
- **Do not reject.** Conditional rejects: (a) if cited for leading-zero canonicality or as a hard language bound; (b) if L1 wants one row covering both canonicality and the bound — this page cannot carry the canonicality half, so admit the sibling `SrcPythonIntBuiltin` row beside it rather than stretching this one.
- **Counterexamples (measured, host Python 3.14.8):** `PYTHONINTMAXSTRDIGITS=0` → current limit 0 and `int('1'*4301)` **accepted**; `=640` → raises at 640 digits; with `-I` the env is ignored (current 4300), so the frozen `python3 -I -B` command is what makes F2/F4 stable. `-X int_max_str_digits=…` changes it too (reviewer `RevC1Bound.md` documents this). The page: hex/octal/binary and bases 2/4/8/16/32 are unlimited; underscores/sign do not count toward the limit.

## Calibration interactions for L1

- Page title `3.15.1` equals S039's located anchor (`corpus/SOURCES.md:46`) and S040/S041's clock anchors (`corpus/release-clocks.tsv:30-31`); opening it adds no docs-version drift.
- **Id collision:** `SrcFrontierOidc.md:65` and `SrcGoSemverCanon.md:31` both propose S044, and BASE-tracked `.ufo/waves/round-27/build/SrcPythonVersions.md:126-129` proposed S044 too. Allocate a fresh id; recompute `<IDENTITY>` after choosing.
- `safe_receipt_url` drops fragment/query (`corpus/release-clock.py:214-231`), so the registry cell must carry no fragment for all views to agree.

## Commands run (exit 0 unless noted)

`curl -fsSL --compressed … -w` (200, final builtins, 102358 transfer) · `curl -sS -D -` no-L (301, location) · `sha256sum`/`cmp` (identical bodies) · `python3 -I -B corpus/rendered-text-v1.py digest` (exit 0) · `locate` ×4: primary artifact 1/exit0, primary clean 0/exit1, ValueError-with-colon 1/exit0, colonless 1/exit0 · `python3 -I -B` int probes (4300 ok, 4301 `ValueError`, base16 unlimited, `int('01')==1`) · `PYTHONINTMAXSTRDIGITS` probes (0 / 640 / with `-I`) · `git archive 3553d49… | tar -x` (exit 0) · `git cat-file -e …:round-27/SrcPythonVersions.md` (exit 0) · `grep`/`awk` line and count pins above. No tools installed.

## Did NOT check

- Did not run C1 fixtures F1–F4, `c1-measure.py`, the lane census, or `release-clock.py --selftest`; the traceback path is a static call-chain read plus a direct `numeric_version` probe, not a CLI reproduction.
- Did not fetch the python.org downloads feed; S039's `3.15.1` is taken from the pinned registry row.
- Did not verify the sibling `SrcPythonIntBuiltin.md` claim that `functions.html` lacks the string `4300` (read its report only) and did not open its URL.
- Did not test cache/Accept-Encoding variance beyond the identity and gzip captures above, and did not check whether a future CPython 3.16 docs tree keeps the `/3/builtins/` path (only the page's canonical link).
