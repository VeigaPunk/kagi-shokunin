# SrcWhatwgWs — WHATWG Infra `#ascii-whitespace` as C2 normalizer source candidate

Round 24 build wave 1, seat SrcWhatwgWs-2, 2026-10-21. Question: does
https://infra.spec.whatwg.org/#ascii-whitespace ground `corpus/rendered-text-v1.py`'s
whitespace declaration? Verdict: **REJECT** as mined grounding; record as the explicit
rejected row. All numbers below are observed.

## Capture (declared profile, exact bytes)

- Command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D infra.headers.txt -o infra.html https://infra.spec.whatwg.org/` → exit 0.
- Capture: `/fast/scratch/kagi-r24/seats/SrcWhatwgWs-2/infra.html` — 383472 bytes, sha256 `8d43350a0a36ebf7682cfe4146dcd7afb8d9f94da0d80677dcc0da16e43590d7`.
- Headers: HTTP/2 200; `content-type: text/html; charset=utf-8`; `last-modified: Mon, 19 Oct 2026 12:00:03 GMT`; `etag: W/"6ad60643-5d9f0"`; fetch `date: Wed, 21 Oct 2026 06:07:07 GMT`.
- Page revision displayed (infra.html:187): "Living Standard — Last Updated **19 October 2026**" (datetime `2026-10-19`) — matches HTTP last-modified.

## Verbatim quote (14 words, ≤25)

> ASCII whitespace is U+0009 TAB, U+000A LF, U+000C FF, U+000D CR, or U+0020 SPACE.

- Location: infra.html:1472-1473; URL anchor `#ascii-whitespace`; containing heading
  "§ 4.6 Code points" (infra.html:1407, `<h3 data-level="4.6" id="code-points">`); page
  index repeats "ASCII whitespace, in § 4.6" (infra.html:3494).
- Companion definition, same page: "strip and collapse ASCII whitespace" (§ 4.7 Strings,
  infra.html:1950-1953) — replace any run of consecutive ASCII-whitespace code points with a
  single U+0020 SPACE, then remove leading/trailing ASCII whitespace. Same *shape* as v1
  steps 5-6, but over the ASCII-only class.
- Note in the same section (infra.html:1478-1494): "Whitespace" is a mass noun; XML, JSON and
  parts of HTTP exclude U+000C FF from their whitespace; "Prefer using Infra's ASCII whitespace
  definition for new features, unless your specification deals exclusively with XML/JSON/HTTP."
  Spec-author guidance for new web features — not a mandate on a digest-reproducing normalizer.

## Claim vs code (observed)

- `corpus/rendered-text-v1.py:58` — `WS_RE = re.compile(r"\s+")` (str pattern → Unicode class).
- `:65` collapse in `normalize_text`; `:74` collapse in `collapse_quote`; `:33` docstring step 6
  trim uses "the same Unicode class".
- `:27-32` docstring step 5: "collapse every run of Unicode whitespace -- Python re '\s' on a
  str pattern ... includes U+00A0 NO-BREAK SPACE and U+3000"; and: "ASCII-only whitespace is
  NOT v1: it fails to reproduce 3 of the 10 round-23 normalized digests (S022, S023, S024;
  round-24 lesson Gate, rejected source row for the WHATWG ASCII class)."
- `:156` committed selftest case: `collapse_quote(" a\u00a0 <b>\n") == "a <b>"` — requires U+00A0
  to count as whitespace; an ASCII-only class fails this case outright.
- `plans/round-24.md:33-46`: freezes "Unicode `\s` collapse" (line 35) and "the ASCII-whitespace
  alternative is an explicit rejected row" with Python `re`/`html` rows as the mined sources
  (lines 44-45).

## Would an ASCII-only collapse be a valid rendered-text-v1 whitespace class? — No

1. Digest fidelity: 3 of 10 round-23 normalized digests (S022/S023/S024 — the Vault-doc pins at
   `corpus/SOURCES.md:28-30`) fail under ASCII-only per the frozen claim (plan :35, docstring
   :30-31). Ground truth; not independently re-run by me.
2. The class difference is observable (python3 3.14.8, exit 0): for input `"a\x0bb\xa0c\u3000d"`,
   str `\s` matches U+000B, U+00A0, U+3000; with `re.ASCII` only U+000B. U+00A0/U+3000 collapse
   only under the Unicode class v1 declares.
3. Even within "ASCII", the classes disagree: Infra's 5-code-point set has no U+000B VT, while
   Python `\s` matches VT even under `re.ASCII`. So Infra class ≠ Python ASCII class ≠ v1 class.
   The page's own note confirms whitespace is per-normative-system (XML/JSON/HTTP drop FF).

## Recommendation per SOURCES contract (CORPUS.md:78-122)

- **kind** `spec`; **tier** `A` for the scope of the ASCII-whitespace definition itself (primary
  spec); **status** `rejected` — contract v1 keeps rejections as evidence of taste, with teaches
  of the form `REJECTED: <reason>; flip: <what would change the verdict>`.
- **anchor**: "§ 4.6 Code points → ASCII whitespace, https://infra.spec.whatwg.org/#ascii-whitespace;
  Living Standard, Last Updated 19 October 2026 (HTTP last-modified 2026-10-19)" — exact section
  plus revision; not a bare homepage. Satisfies rule 1's located-quote requirement (quote above).
- **scope**: "defines ASCII-only whitespace {U+0009, U+000A, U+000C, U+000D, U+0020}; it is not
  the whitespace class of rendered-text-v1".
- **teaches** (suggested row text): `REJECTED: defines the ASCII-only set {TAB,LF,FF,CR,SPACE};
  rendered-text-v1 declares Unicode re \s (rendered-text-v1.py:58) and 3/10 round-23 digests
  (S022/S023/S024) plus the selftest U+00A0 case (:156) fail under an ASCII-only collapse.
  flip: a v2 normalizer explicitly declared ASCII-only with the full pin population re-captured
  under it.`
- **opened** 2026-10-21; **recheck** 180d (living standard: drift signal is the "Last Updated"
  date line, currently 2026-10-19). Next free id S027 (registry ends at S026,
  `corpus/SOURCES.md:32`); never a bare-homepage anchor; no `|` in cells.

### ADMIT or REJECT

**REJECT** grounding rendered-text-v1's whitespace declaration with infra `#ascii-whitespace`.
Reason: the class it defines is not the class the code declares — v1 collapses Unicode `\s`
(`rendered-text-v1.py:58,:65,:74`); the Infra set is ASCII-only, breaks digest fidelity
(S022/S023/S024) and the committed selftest case (:156, U+00A0), and even as an "ASCII" claim it
diverges from Python's ASCII `\s` on U+000B. The mined grounding for the whitespace rule is the
Python `re` docs row (plan :44-45); the Infra row enters the registry only as the explicit
rejected row (status `rejected`, next id S027). Optional, if the integrator wants a spec-shape
reference: § 4.7 "strip and collapse ASCII whitespace" grounds the collapse *shape* (runs → one
U+0020, then trim) — but per the single-declaration rule the class authority stays
rendered-text-v1.py plus the Python `re` row.

**Flip condition**: (a) rendered-text-v1 redeclared as v2 with an explicit ASCII-only class AND
the full legacy pin population re-captured under v2 with freshly declared digests (a digest-base
bump, not a fact correction); or (b) an Infra revision changes the definition — caught by the
row's 180d recheck against the "Last Updated" date.

## Confidence and unknowns

- Quote/location/revision: high — byte-verified capture, sha256 + last-modified recorded above.
- Code reading: high — every claim carries path:line.
- S022/S023/S024 ASCII digest failures: accepted as frozen ground truth (plan :35, docstring
  :30-31); not re-run. A cheap independent check exists if wanted: run the 10 round-23 digests
  through a copy of the normalizer with `WS_RE = re.compile(r"\s+", re.ASCII)` in a scratch clone.
- No browser/reader-mode cross-check; the declared-profile curl capture is primary evidence.
- Tools installed: none (curl and python3 already present; pacman untouched).
