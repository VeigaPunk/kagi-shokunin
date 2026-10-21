# S027 — Python Unicode whitespace

## Result: PASS for the scoped S027 claim; no falsifier observed

- **Revision/bounds:** lane HEAD and sandbox checkout both `c5ef9e92201b6c36396301f12b23740565bf86a0` (BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`). Read-only review of `plans/round-24.md` C2, `corpus/SOURCES.md` S027, `corpus/lessons/round-24.md` Gate, and `corpus/rendered-text-v1.py`; one fresh fetch of the exact public URL. No production changes.
- **Fresh source observation:** `https://docs.python.org/3/library/re.html`, fetched 2026-10-21 with `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`. Served title identifies Python 3.15.0. Decoded body: 251,811 bytes; SHA-256 `453e9e17c37426568d91472fded548ba6eddd1a4ff4f3f3a88aa3a49893ed075`.
- **Quote/anchor:** exact Gate quote is “For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ).” (13 whitespace-separated tokens, thus ≤25). Fresh page contains it under the `\s` entry in the special-sequences list, anchored by `#re-special-sequences`; the adjacent text says ASCII-flagged matching uses `[ \\t\\n\\r\\f\\v]` and Unicode matching includes non-breaking spaces. The committed v1 `locate` command found count 1.
- **Tier/scope/disposition:** S027 is tier A, scope “rendered-text-v1 whitespace class: Python `re` `\\s` on str patterns,” status `mined`, opened 2026-10-21, recheck `on-release`. Gate decision is **admit (mined): grounds v1's whitespace class**. S027 itself states no flip condition. The adjacent S030 ASCII alternative has its own rejection/flip (declared v2 adopting ASCII whitespace and re-capturing every row); this probe did not independently verify its 7/10 digest count.
- **Implementation comparison:** v1 has `WS_RE = re.compile(r"\\s+")` (`corpus/rendered-text-v1.py:63`), applies it after `html.unescape` at line 70, then calls `s.strip()` at line 71. This is an unflagged `str` pattern, not ASCII mode, so the source supports the stated Unicode `\\s` class rather than contradicting it. The source supports the class semantics; it does not by itself establish C2's separate requirement that all ten historical normalized digests reproduce.
- **Rendering bound:** v1 removes tags with regexes and unescapes entities; the one-count result is under that normalizer only. It is not evidence that regex rendering equals browser HTML parsing.

## Commands and observed output

Sandbox: `/fast/scratch/kagi-r24-recovery/KagiR24-2.FSourceS027-9`; clone made with `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin <sandbox>/lane`, checked out at the frozen revision. Fetch and locate rerun with `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`:

```text
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://docs.python.org/3/library/re.html -o <sandbox>/dl/re.html
exit=0
sha256sum: 453e9e17c37426568d91472fded548ba6eddd1a4ff4f3f3a88aa3a49893ed075
wc -c: 251811
python3 corpus/rendered-text-v1.py locate <sandbox>/dl/re.html 'For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ).'
RENDERED_TEXT_V1_LOCATE: count=1; exit=0
python3 corpus/rendered-text-v1.py digest <sandbox>/dl/re.html
RENDERED_TEXT_V1: raw_sha256=453e9e17c37426568d91472fded548ba6eddd1a4ff4f3f3a88aa3a49893ed075 bytes=251811 normalized_sha256=bcee6611c77820855f3544716f5b036c6f518c79d3a6a193302ea8deab5f1172 normalized_bytes=69062; exit=0
python3 corpus/rendered-text-v1.py --selftest
RENDERED_TEXT_V1_SELFTEST: PASS (cases=20); exit=0
```

**Remaining unknown:** this scoped source check does not run the historical ten-row digest replay or validate browser-rendered text. **Falsifier:** the fresh source quote/anchor failing to support unflagged Unicode `str`-pattern `\\s`, or the implementation using ASCII mode instead; neither was observed.