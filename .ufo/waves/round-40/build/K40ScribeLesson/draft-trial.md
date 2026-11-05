# K40ScribeLesson — draft-trial.md

**Draft text for the round-40 lesson's `## Trial on real domain work` section.**
Read-only. Nothing outside this seat directory was written; no lane file was
mutated. Evidence: the commands and their outputs are reproduced after the
draft, and the same measurements are in `overstatement-audit.md` and
`quote-counts.md`.

---

## Draft (proposed lesson text)

> ## Trial on real domain work
>
> The round's real domain work is the Python documentation surface itself: the
> two pages the lane's own render-normalizer rests on. The trial reads the
> lane's knowledge entries that consume the `re` whitespace teaching and the
> `html` entity teaching, and records, read-only, whether each version-sensitive
> statement still matches the served 3.15.2 identity.
>
> **The two teachings, and where they are consumed.** `corpus/rendered-text-v1.py`
> is the lane's single declared normalizer; its step 5 collapses whitespace with
> the Unicode class and its step 4 applies `html.unescape`. Two entries consume
> the whitespace teaching and one consumes the entity teaching:
> `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (its absence-sweep
> command inlines `re.sub(r'\s+',' ', …)` and `html.unescape`, i.e. the same
> whitespace class and the same entity step), and the four entries that pin
> `rendered-text-v1` normalized digests for their own pages
> (`nist-key-management-guidance-status.md`,
> `nist-key-management-parts-withdrawal.md`,
> `cdp-bridge-1password-oidc-workflow.md`, `oidc-federation-trust-policy.md`).
> `corpus/source-fetches.tsv` rows S040/S041, the registry rows superseded this
> round, carried the 3.15.1 identity of these two pages.
>
> **Result: both teachings still hold on the served 3.15.2 pages.** The
> whitespace teaching is unchanged: the full S040 quote — "Matches Unicode
> whitespace characters (as defined by str.isspace() )." — locates in the
> 3.15.2 capture at count=1 under `corpus/rendered-text-v1.py locate`, and the
> surrounding sentences the round-26 lesson also quoted still locate there
> ("non-breaking spaces mandated by typography rules in many languages." →
> count=1; "if the ASCII flag is used." → count=6). The entity teaching is
> unchanged: "This function uses the rules defined by the HTML 5 standard for
> both valid and invalid character references" locates at count=1 in the 3.15.2
> html capture, as does the first sentence "Convert all named and numeric
> character references (e.g. &gt; , &#62; , &#x3e; ) in the string s to the
> corresponding Unicode characters." The two pages serve
> `<title>re — Regular expression operations &#8212; Python 3.15.2
> documentation</title>` and `<title>html — HyperText Markup Language support
> &#8212; Python 3.15.2 documentation</title>`, byte-exact in the committed
> capture bodies.
>
> **Three version-sensitive statements do not match, and none of the three is
> the documentation's.** (i) `corpus/rendered-text-v1.py` step 5 names the
> whitespace class as "the characters `str.isspace()` accepts, which includes
> U+00A0 NO-BREAK SPACE and U+3000". The served 3.15.2 `re` page still grounds
> `str.isspace()` and still names the non-breaking spaces, but it does not name
> U+3000 — the served body carries no "U+3000" and no "ideographic" token. The
> statement is true of the lane's Python, not of the cited page. (ii) The new
> S095 teaches cell's *verbatim* quote is a raw-literal truncation: it stops at
> an HTML tag boundary, "Matches Unicode whitespace characters (as defined by",
> with `str.isspace()` living inside an `<a class="reference internal">` tag
> and therefore absent from the quoted bytes; the S096 verbatim quote is
> truncated the same way at a line boundary, stopping at "HTML 5 standard"
> before "for both valid and invalid character references". The *teachings* are
> unchanged; the quoted segments the registry now binds are not the sentences
> the teachings turn on. (iii) The rendered-text-v1 docstring's step-5 comment
> still cites the round-24 source S027 — a row superseded twice — so the
> normalizer's own declared basis has not been re-pointed at the rows this
> round opened, although S095/S096 now teach the same teaching.
>
> **The re-observation is therefore a version-label refresh, not a content
> change.** Nothing in the lane's consumed knowledge needed correction because
> of 3.15.1 → 3.15.2; what needed correcting was the registry's version label
> and the pinned anchor, which is what C2 delivers. The trial records one
> residual: the round's own two new verbatim quotes are raw-literal fragments,
> so a reader who checks the *quote* rather than the *teaching* will find a
> shorter string than the sentence the normalizer's comment cites. That is
> recorded as an erratum, not as a change to either teaching.

---

## Evidence for every claim in the draft

Commands executed from the lane root `/home/vgpnk/Projects/shokunin/kagi-shokunin`
(read-only; the lane tree was not modified):

**1. The two served titles are byte-exact in the committed capture bodies.**

```
python3 - <<'PY'
for f,t in [(".ufo/waves/round-40/capture/S095.body",
             "<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>"),
            (".ufo/waves/round-40/capture/S096.body",
             "<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>")]:
    b=open(f,'rb').read(); print(f, t in b.decode('utf-8'), len(b))
PY
```
→ `S095.body True 257722` · `S096.body True 20100`

**2. Both new quotes locate in their committed bodies; the S040/S041 full
sentences also still locate on the 3.15.2 bodies.**

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body \
  'Matches Unicode whitespace characters (as defined by str.isspace() ).'      # count=1
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body \
  'Matches Unicode whitespace characters (as defined by'                        # count=1
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S096.body \
  'This function uses the rules defined by the HTML 5 standard for both valid and invalid character references'  # count=1
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S096.body \
  'This function uses the rules defined by the HTML 5 standard'                # count=1
```

**3. The round-26 auxiliary sentences still locate on 3.15.2.**

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body \
  'non-breaking spaces mandated by typography rules in many languages.'        # count=1
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body \
  'if the ASCII flag is used.'                                                  # count=6
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body \
  'For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ).'  # count=1
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S096.body \
  'Convert all named and numeric character references (e.g. &gt; , &#62; , &#x3e; ) in the string s to the corresponding Unicode characters.'  # count=1
```

**4. The two new verbatim quotes are raw-literal truncations.**

```
python3 - <<'PY'
b=open(".ufo/waves/round-40/capture/S095.body",encoding="utf-8").read()
i=b.find("Matches Unicode whitespace characters (as defined by")
print(repr(b[i:i+230]))
PY
```
→ `'Matches Unicode whitespace characters (as defined by <a class="reference internal" href="../builtins/stdtypes.html#str.isspace" title="str.isspace"><code class="xref py py-meth docutils literal notransla'`

```
python3 - <<'PY'
b=open(".ufo/waves/round-40/capture/S096.body",encoding="utf-8").read()
print(repr(b[13400:13700]))
PY
```
→ `'ranslate"><span class="pre">&amp;#x3e;</span></code>) in the string <em>s</em> to the corresponding Unicode\ncharacters.  This function uses the rules defined by the HTML 5 standard\nfor both valid and invalid character references, and the <a class="reference internal" href="html.entities.html#html.en'`

Both raw bodies carry the quoted needles contiguously (so the C2 counter's
whitespace-normalised locate succeeds — the needles are raw-literal substrings),
and in both cases the quoted segment ends *before* the clause the teaching
turns on (`str.isspace()`; "for both valid and invalid character references").

**5. The rendered-text-v1 whitespace class names U+3000; the served page does not.**

```
grep -n "U+3000\|U+00A0\|isspace" corpus/rendered-text-v1.py
```
→ `37: str pattern, i.e. the characters str.isspace() accepts, which`
→ `38: includes U+00A0 NO-BREAK SPACE and U+3000 -- to one U+0020.`

```
grep -c "U+3000\|ideographic\|IDEOGRAPHIC" .ufo/waves/round-40/capture/S095.body
```
→ `0`

**6. The normalizer's step-5 comment still cites the round-24 source.**

`corpus/rendered-text-v1.py` header, "Sources (opened round 24, see
corpus/SOURCES.md): Python `re` \s for str patterns and Python `html.unescape`."
Round 24 opened S027 (re whitespace) and S028 (html entity); both were
superseded by S040/S041 (round 26) and those by S095/S096 (this round).

**7. Which knowledge entries consume the two teachings.**

```
grep -rn "rendered-text-v1" corpus/knowledge/*.md
```
→ `cdp-bridge-1password-oidc-workflow.md` (2), `nist-key-management-guidance-status.md` (3),
`nist-key-management-parts-withdrawal.md` (1), `oidc-federation-trust-policy.md` (2)

```
grep -n "isspace\|HTML 5\|unescape" corpus/knowledge/vault-openbao-token-lease-lifecycle.md
```
→ line 92, the absence-sweep one-liner:
`curl -sL "$U" | python3 -c "import sys,re,html;t=html.unescape(re.sub(r'<[^>]+>',' ',re.sub(r'(?s)<script.*?</script>','',sys.stdin.read())));t=re.sub(r'\s+',' ',t).lower();print(t.count('$P'))"`

Note that this inline command is a **lane-local re-implementation** of the two
steps, not a call to `corpus/rendered-text-v1.py` — so it is the one place
where the two teachings are consumed as *code* rather than as *citations*.

**8. The superseded rows carried the 3.15.1 identity.**

`corpus/SOURCES.md` S040 scope: "… title Python 3.15.1 documentation, fetched
2026-10-21"; S041 scope: "… title Python 3.15.1 documentation, fetched
2026-10-21". `git diff 6cc8850 cb3f642 -- corpus/SOURCES.md` shows two added
lines only (S095, S096) — no in-place edit of S040/S041 (CORPUS.md rule 2).

## Scope note

The trial is read-only by construction: no knowledge entry, registry row,
capture body or instrument was edited. The three mismatches above are recorded
as findings for the round's report and lesson (an erratum on the two raw-literal
quote shapes, and a re-point of the normalizer's source comment), **not** as
claims of this seat — the lesson's `## Mistakes` table and the round report are
the L1's to write.

Tool installs: **none**.
