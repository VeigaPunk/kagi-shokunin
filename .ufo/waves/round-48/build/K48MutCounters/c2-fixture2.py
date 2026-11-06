#!/usr/bin/env python3
"""Proposed round-48 C2 control fixtures (not the frozen c2-fixture.py).

substr  : reference mode, then K07's stated output is reduced to its strict prefix
          `CLAIMS_DECLARED: CLEAN` (executed line is `CLAIMS_DECLARED: CLEAN (claims=21)`).
          Pristine counter must read value=1 (K07 DIFF); a substring-MATCH counter reads 0.
"""
import sys, importlib.util
mode, path = sys.argv[1], sys.argv[2]
spec = importlib.util.spec_from_file_location("fx", sys.argv[3])
fx = importlib.util.module_from_spec(spec); spec.loader.exec_module(fx)
assert mode == "substr", mode
lines = open(path, encoding="utf-8").read().splitlines(keepends=True)
start = lines.index("## Capabilities\n")
end = next(i for i in range(start + 1, len(lines)) if lines[i].startswith("## "))
lines.insert(end, fx.line([fx.K02, (fx.K07[0], "CLAIMS_DECLARED: CLEAN"), fx.K10]) + "\n")
open(path, "w", encoding="utf-8").write("".join(lines))
