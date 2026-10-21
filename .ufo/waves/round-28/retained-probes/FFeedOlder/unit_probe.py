#!/usr/bin/env python3
"""Unit probe: does the candidate's documented ignore limit ever change WHICH
release the feed names, or only whether the feed is typed?

For every token multiset drawn from a canonical/non-canonical pool the probe
compares the candidate's newest_stable() result with a reference "true newest"
computed by integer value (leading zeros are irrelevant to a release's value).
"""
import importlib.util
import itertools
import sys
from pathlib import Path

tree = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location(
    "release_clock", tree / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

CANON = ["3.15.1", "3.14.0", "3.15.0", "2.7.1", "3.15.10", "3.9.9"]
NONCANON = ["3.14.01", "3.15.01", "3.15.001", "3.15.010", "3.9.9", "3.15." + "1" * 4301,
            "3.15." + "0" * 20 + "1"]
POOL = CANON + NONCANON

def value_key(token):
    """Numeric order of a token's release value, computed without int()."""
    return tuple((len(part.lstrip("0")), part.lstrip("0")) for part in token.split("."))


typed = 0
wrong = 0
wrong_examples = []
checked = 0
if not hasattr(module, "newest_stable"):
    print("module=%s has no newest_stable(); BASE picks max(stable, key=int-tuple)"
          % (tree / "corpus" / "release-clock.py"))
    raise SystemExit(0)
for size in (1, 2, 3):
    for combo in itertools.combinations(POOL, size):
        tokens = list(combo)
        reference = max(tokens, key=value_key)
        checked += 1
        try:
            got = module.newest_stable(tokens)
        except ValueError as exc:
            typed += 1
            if not str(exc).startswith(module.NON_CANONICAL_PREFIX):
                print("UNTYPED-VALUEERROR %r -> %s" % (tokens, exc))
            continue
        if value_key(got) != value_key(reference):
            wrong += 1
            if len(wrong_examples) < 5:
                wrong_examples.append((tokens, got, reference))
print("checked=%d typed=%d silently_accepted=%d wrong_newest=%d" % (
    checked, typed, checked - typed, wrong))
for example in wrong_examples:
    print("WRONG_NEWEST tokens=%r got=%s reference=%s" % example)
print("module=%s" % (tree / "corpus" / "release-clock.py"))
print("newest_stable source line=%d" % module.newest_stable.__code__.co_firstlineno)
