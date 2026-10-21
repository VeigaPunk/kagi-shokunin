#!/usr/bin/env python3
"""Sandbox property checks for the patched corpus/release-clock.py helpers (XC1).

Usage: python3 -I -B c1_checks.py RELEASE_CLOCK_PY
Loads the module by path, never writes into the lane, prints one line per check.
"""
import importlib.util
import random
import re
import sys
from pathlib import Path

path = Path(sys.argv[1]).resolve()
spec = importlib.util.spec_from_file_location("rc_checks", path)
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

failed = []


def check(name, condition):
    print("%s %s" % ("PASS" if condition else "FAIL", name))
    if not condition:
        failed.append(name)


# bound: 18 digits canonical, 19 digits non-canonical, leading zero non-canonical
check("18-digit component canonical", not rc.non_canonical_version("1.2.999999999999999999"))
check("19-digit component non-canonical", rc.non_canonical_version("1.2.1000000000000000000"))
check("leading zero non-canonical", rc.non_canonical_version("1.2.03"))
check("zero component canonical", not rc.non_canonical_version("0.0.0"))
check("double-zero component non-canonical", rc.non_canonical_version("1.00.0"))
check("v-prefixed leading zero non-canonical", rc.non_canonical_version("v01.2.3"))
check("series anchor not flagged", not rc.non_canonical_version("1.2.x"))
check("two-component not flagged", not rc.non_canonical_version("1.3"))
check("suffix token not flagged (not strict X.Y.Z)", not rc.non_canonical_version("1.2.3-rc.01"))

# numeric_version gates before any ordering; never raises on oversize text
check("numeric_version canonical tuple", rc.numeric_version("v1.2.3") == rc.version_order("1.2.3"))
check("numeric_version None for leading zero", rc.numeric_version("1.2.03") is None)
check("numeric_version None for 5000-digit component",
      rc.numeric_version("3.15." + "1" * 5000) is None)
check("feed_floors ignores leading-zero anchor", rc.feed_floors([
    {"malformed": False, "fields": ["S1", "feed", "S2", "https://x.test/f", "1.2.04",
                                    "1.2.04", "2026-10-21", "not-fired", "n"]},
    {"malformed": False, "fields": ["S3", "feed", "S2", "https://x.test/f", "1.2.3",
                                    "1.2.3", "2026-10-21", "not-fired", "n"]},
]) == {"https://x.test/f": "1.2.3"})

# newest_stable: canonical max; non-canonical refused only when it can be newest
cases = (
    (["3.15.1", "3.15.01"], "refuse"),
    (["3.15.0", "3.14.01"], "refuse"),
    (["3.14.01", "3.15.0"], "refuse"),
    (["3.15.01"], "refuse"),
    (["3.15.0", "3.15.01"], "refuse"),
    (["1.2.3", "1.2.3"], "1.2.3"),
    (["3.15.0", "3.15." + "1" * 4301], "refuse"),
    (["3.15.0", "3.14." + "1" * 4301], "refuse"),
)
for index, (tokens, wanted) in enumerate(cases):
    try:
        got = rc.newest_stable(tokens)
    except ValueError as exc:
        got = "refuse" if "canonical" in str(exc) else "untyped: %s" % exc
    check("newest_stable case %d (%s) == %s" % (index, ", ".join(t[:14] for t in tokens),
                                                wanted), got == wanted)

# ordering equivalence with integer order for canonical tokens (seeded)
rng = random.Random(28)


def canonical_component():
    if rng.random() < 0.3:
        return "0"
    width = rng.randint(1, 18)
    return str(rng.randint(1, 9)) + "".join(rng.choice("0123456789") for _ in range(width - 1))


def canonical_token():
    return ".".join(canonical_component() for _ in range(3))


equal = True
for _ in range(20000):
    a, b = canonical_token(), canonical_token()
    int_a = tuple(int(part) for part in a.split("."))
    int_b = tuple(int(part) for part in b.split("."))
    if ((rc.version_order(a) < rc.version_order(b)) != (int_a < int_b)
            or (rc.version_order(a) == rc.version_order(b)) != (int_a == int_b)):
        equal = False
        break
check("version_order equals integer order on 20000 canonical pairs", equal)

# leading zeros never change value: a padded token orders equal to its canonical form
padded_equal = True
for _ in range(5000):
    token = canonical_token()
    padded = ".".join(("0" * rng.randint(1, 3)) + part if rng.random() < 0.5 else part
                      for part in token.split("."))
    if rc.version_order(padded) != rc.version_order(token):
        padded_equal = False
        break
check("leading zeros do not change version_order (5000 tokens)", padded_equal)

# no int() call remains in the module (comments excluded)
code_lines = [line for line in path.read_text(encoding="utf-8").splitlines()
              if not line.lstrip().startswith("#")]
check("no int() call remains in the module",
      re.search(r"(?<![A-Za-z_])int\(", "\n".join(code_lines)) is None)

print("CHECKS: %s (failed=%d)" % ("CLEAN" if not failed else "FAILED", len(failed)))
sys.exit(0 if not failed else 1)
