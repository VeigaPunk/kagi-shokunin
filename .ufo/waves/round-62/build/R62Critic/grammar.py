#!/usr/bin/env python3
"""Literal implementation of plans/round-62.md §C1 'hardened grammar' I3/I4/I5,
to test whether the frozen wording can reject the B3/B4/B5 forgeries and
whether it rejects benign rewrites.

Rule text (quoted from the frozen plan):
  I3  at least one occurrence of `withdrawn` whose 12-token window before it
      contains `A3 item 2` and whose 5-token window before it (truncated at the
      nearest `.`, `;` or `:`) contains no negator
  I4  `three` occurs with no negator in its 5-token window before it (truncated)
  I5  `rewritten in place` occurs with no negator in its 5-token window before it
Negator set: not, no, never, neither, nor, without, none, n't (case-insensitive,
word-boundary).  The bigram `not only` immediately before the match is an idiom.
"""
import re, sys

NEG = re.compile(r"(?i)(?<![\w'])(?:not|no|never|neither|nor|without|none)(?![\w'])|n't\b")
TOK = re.compile(r"[A-Za-z0-9_/%.=+-]+")

def tokens_before(text, pos, n):
    """Last n tokens of text[:pos], plus the truncated window."""
    pre = text[:pos]
    toks = TOK.findall(pre)
    return toks[-n:]

def trunc_window(text, pos, n):
    """Last n tokens before pos, truncated at the nearest . ; : in the window.

    Literal reading: find the nearest . ; : before pos; if it lies inside the
    last-n-token span, the window starts after it."""
    pre = text[:pos]
    m = None
    for ch in ".;:":
        i = pre.rfind(ch)
        if i >= 0 and (m is None or i > m):
            m = i
    toks = TOK.findall(pre)
    win = toks[-n:]
    if m is not None:
        # tokens that begin after the truncation char
        tail = pre[m+1:]
        win = TOK.findall(tail)[-n:]
    return win

def has_neg(toks):
    s = " ".join(toks)
    if re.search(r"(?i)\bnot\s+only\b", s):
        # the bigram immediately before the match is an idiom: remove it
        s = re.sub(r"(?i)\bnot\s+only\b", " ", s)
    return NEG.search(s) is not None

def i3(text):
    out = []
    for m in re.finditer(r"(?i)\bwithdrawn\b", text):
        w12 = tokens_before(text, m.start(), 12)
        w5 = trunc_window(text, m.start(), 5)
        if "a3 item 2" in " ".join(w12).lower():
            out.append((m.start(), has_neg(w5), w12, w5))
    ok = any(not neg for _, neg, _, _ in out)
    return ok, out

def i4(text):
    out = []
    for m in re.finditer(r"(?i)\bthree\b", text):
        w5 = trunc_window(text, m.start(), 5)
        out.append((m.start(), has_neg(w5), w5))
    ok = any(not neg for _, neg, _ in out)
    return ok, out

def i5(text):
    out = []
    for m in re.finditer(r"(?i)rewritten\s+in\s+place", text):
        w5 = trunc_window(text, m.start(), 5)
        out.append((m.start(), has_neg(w5), w5))
    ok = any(not neg for _, neg, _ in out)
    return ok, out

def main():
    path, item = sys.argv[1], sys.argv[2]
    text = open(path, encoding="utf-8", errors="replace").read()
    if len(sys.argv) > 3:
        import re as _re
        pat = _re.compile(sys.argv[3])
        lines = [ln for ln in text.splitlines() if pat.search(ln)]
        if not lines:
            print(f"{item} resolved=0 scope=line-missing"); return 1
        text = lines[-1]  # the evaluated (LAST) correction line
    fn = {"i3": i3, "i4": i4, "i5": i5}[item]
    ok, occ = fn(text)
    print(f"{item} resolved={int(ok)} occurrences={len(occ)}")
    for row in occ[:8]:
        pos, neg, w5 = row[0], row[1], row[-1]
        print(f"  pos={pos} negated={int(neg)} window={w5}")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
