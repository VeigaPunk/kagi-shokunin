#!/usr/bin/env python3
"""Probe-only overlay builder (CritSeparability sandbox). NOT a production draft.

usage: overlay.py <out-dir> <claim>...   claims: c1, c2s (string bind), c2n (numeric bind, early)
Copies base/ to <out-dir> and applies the minimal hunks of each claim to
corpus/release-clock.py so overlay separability can be exercised.
"""
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / sys.argv[1]
CLAIMS = sys.argv[2:]
if OUT.exists():
    shutil.rmtree(OUT)
shutil.copytree(HERE / "base", OUT, symlinks=True)
path = OUT / "corpus" / "release-clock.py"
text = path.read_text(encoding="utf-8")


def sub(old, new, count=1):
    global text
    found = text.count(old)
    if found != count:
        raise SystemExit("hunk anchor %r found %d times, expected %d" % (old[:60], found, count))
    text = text.replace(old, new)


C1_HELPER = '''

MAX_COMPONENT_DIGITS = 64
CANONICAL_COMPONENT_RE = re.compile(r"0|[1-9][0-9]*")


def token_defect(value):
    """None when every numeric component is canonical and bounded."""
    core = re.split(r"[-+]", norm_version(value or ""), maxsplit=1)[0]
    for part in core.split("."):
        if part.isdigit() and part.isascii():
            if len(part) > MAX_COMPONENT_DIGITS:
                return "oversize"
            if not CANONICAL_COMPONENT_RE.fullmatch(part):
                return "leading-zero"
    return None


def numeric_version('''

if "c1" in CLAIMS:
    sub("\n\ndef numeric_version(", C1_HELPER)
    # numeric_version itself refuses non-canonical tokens (no int() on them)
    sub('''    if not NUMERIC_VERSION_RE.fullmatch(value):
        return None
    return tuple''', '''    if not NUMERIC_VERSION_RE.fullmatch(value) or token_defect(value):
        return None
    return tuple''')
    # evaluate: typed NONCANONICAL before regression/consistency ordering
    sub('''            if (is_regression(anchored, observed_version)''',
        '''            if token_defect(anchored) or token_defect(observed_version):
                errors.add(("NONCANONICAL", source_id))
                row_valid = False
            elif (is_regression(anchored, observed_version)''')
    # observe: feed entries must be canonical and bounded
    sub('''            if match:
                stable.append(match.group(1))''', '''            if match:
                if token_defect(match.group(1)):
                    raise ValueError("feed entry version token is not canonical")
                stable.append(match.group(1))''')
    sub('''        if match:
            return match.group(1)
        raise ValueError("text release file''', '''        if match:
            if token_defect(match.group(1)):
                raise ValueError("feed entry version token is not canonical")
            return match.group(1)
        raise ValueError("text release file''')

if "c2s" in CLAIMS:
    # string binding via the SHARED helper version_is_named, independent check
    sub('''            is_derived = values["note"].startswith("derived:")
''', '''            is_derived = values["note"].startswith("derived:")
            if is_derived and (feed_source is None or not version_is_named(
                    feed_source["anchor"], anchored)):
                errors.add(("UNDERIVED", source_id))
                row_valid = False
''')

if "c2n" in CLAIMS:
    # numeric binding, placed before the C1 guard, comparing int tuples
    sub('''            is_derived = values["note"].startswith("derived:")
''', '''            is_derived = values["note"].startswith("derived:")
            if is_derived:
                named = [tuple(int(p) for p in m.group(1).split("."))
                         for m in VERSION_RE.finditer(feed_source["anchor"] if feed_source else "")
                         if NUMERIC_VERSION_RE.fullmatch(m.group(1))]
                parts = norm_version(anchored).split(".")
                mine = tuple(int(p) for p in parts) if all(p.isdigit() for p in parts) else None
                if mine is None or mine not in named:
                    errors.add(("UNDERIVED", source_id))
                    row_valid = False
''')

path.write_text(text, encoding="utf-8")
print("built %s with %s" % (OUT.name, CLAIMS or ["base"]))
