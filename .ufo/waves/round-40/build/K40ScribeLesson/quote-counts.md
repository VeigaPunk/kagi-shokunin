# K40ScribeLesson — quote-counts.md

Round-40 gate-quote whitespace-token counts, with the method stated and the M40-1
precision rule applied.

## Method

The count is the number of **whitespace-separated tokens** in the verbatim quote
string, i.e. Python's `str.split()` on the exact quote characters between the
U+201C and U+201D (the same delimiters `plans/round-40-c2.sh` uses to extract
the quote from the registry row: `re.search("\u201c(.+?)\u201d", row)`).

Two independent implementations agree, so the count does not depend on one
shell's word-splitting rules:

- `python3` — `len(q.split())`
- `wc -w` — `printf '%s' "$q" | wc -w`

Commands executed (in the lane tree, read-only):

```
python3 - <<'PY'
import re
for f,sid in [("corpus/SOURCES.md","S095"),("corpus/SOURCES.md","S096")]:
    row=[l for l in open(f,encoding="utf-8") if l.startswith("| "+sid+" |")][0]
    q=re.search("\u201c(.+?)\u201d",row).group(1)
    print(sid, repr(q), len(q.split()))
PY
```

```
printf '%s' "Matches Unicode whitespace characters (as defined by" | wc -w   # 7
printf '%s' "This function uses the rules defined by the HTML 5 standard" | wc -w  # 11
```

## Counts

| Row | Verbatim quote (between U+201C and U+201D) | `str.split()` | `wc -w` | Lesson claims | Verdict |
|---|---|---|---|---|---|
| S095 | `Matches Unicode whitespace characters (as defined by` | **7** | **7** | **8** (candidate lesson, `corpus/lessons/round-40.md` §Gate) | **MISMATCH — the lesson overstates by one** |
| S096 | `This function uses the rules defined by the HTML 5 standard` | **11** | **11** | 11 (candidate lesson, §Gate) | MATCH |

Token lists, so the count is checkable by eye:

- S095: `Matches` `Unicode` `whitespace` `characters` `(as` `defined` `by` — 7.
- S096: `This` `function` `uses` `the` `rules` `defined` `by` `the` `HTML` `5` `standard` — 11.

Both are ≤ 25, so the CORPUS.md rule-1 bound ("a ≤25-word quote") holds for both
rows; the defect is the **stated count**, not the bound.

## M40-1 precision rule applied

M40-1 (candidate lesson, §Mistakes) is the row-precision class: a registry
teaches cell that mixes the verbatim quote with a derived clause, plus "a word
count was stated wrong". Its fix was QM42 (`corpus/QUALITY.md`): the teaches
cell must separate the verbatim quote (marked as verbatim, with its located
offset) from any derived clause (marked as paraphrase), and a quoted segment
that does not locate in the committed capture body cannot satisfy a counter
item that binds the row to that body.

Applying that rule to the two new rows:

1. **Quote/derivation separation — satisfied.** `corpus/SOURCES.md` S095's
   teaches cell reads "Quote (verbatim): “Matches Unicode whitespace characters
   (as defined by” (raw body offset 75897). Derivation (paraphrase, outside the
   quote): str patterns match Unicode whitespace as defined by str.isspace()
   unless ASCII matching is requested…". S096 is the same shape. The two rows
   are the QM42-clean successor to S094's mixed cell.

2. **Counter binding — satisfied for the locate half, and the quote does
   locate.** The C2 counter's Python locate step normalises whitespace on both
   sides and requires the needle to be a substring of the body. The S095 needle
   is a **raw-literal** substring of the raw capture body (the rendered-text
   form is `Matches Unicode whitespace characters (as defined by str.isspace() ).`,
   whose `str.isspace()` part is wrapped in an `<a class="reference internal">`
   tag and therefore is *not* contiguous in the raw bytes). Verified:

   - raw-body `find()` of the S095 needle → offset **75897**, exactly the
     committed offset; the raw context is
     `Matches Unicode whitespace characters (as defined by <a class="reference internal" href="../builtins/stdtypes.html#str.isspace" …>`,
     i.e. the quote stops at the tag boundary.
   - `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body 'Matches Unicode whitespace characters (as defined by'` → `count=1`.
   - `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S096.body 'This function uses the rules defined by the HTML 5 standard'` → `count=1`.

3. **The count is stated wrong in the candidate lesson — M40-1's second half,
   repeated inside this round.** The candidate's §Gate line reads "Located quote
   (8 whitespace tokens ≤ 25)" for S095. The whitespace count is **7**. This is
   the same class as M40-1 ("a word count was stated wrong"), reproduced in the
   very lesson that mined it. The round-39 S094 erratum (M40-1's evidence
   pointer) is itself a count erratum: round 39's lesson said "9 words" where
   the whitespace count was 8.

   Consequence for a re-checker: the count is a **token count**, not a registry
   cell. It is not machine-checked by any committed gate — the census's
   `wc -w` rule (`corpus/sources-census.sh`, `SC_FETCH`) applies to
   `corpus/source-fetches.tsv` column 9, whose S095/S096 entries hold the
   `<title>…</title>` string, **not** the teaches-cell quote. So no committed
   counter ever counts the tokens of the Gate quote; only a re-reading seat
   (here, `str.split`/`wc -w`) catches it. That is the same "captured-by: none"
   gap M40-1 already records for the quote/derivation separation, and it is why
   the defect survived the pre-freeze gate and the candidate commit.

## Note on the lesson's own correction

The live working-tree lesson (uncommitted, L1 edit after the candidate) already
corrects the S095 count to 7 and adds the `str.split` method to both Gate
lines, citing the critic's re-count as M40-4. This document confirms that
correction independently and states the method and the residual gap (no
committed counter counts quote tokens).

## Receipts

- Counts: this file; method reproducible with the two commands above.
- Offsets and locate: verified against `.ufo/waves/round-40/capture/S095.body`
  and `S096.body` at the candidate `cb3f642479a09644a03874909bb7e44b52697a8d`.
- Tool installs: **none**.
