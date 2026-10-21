#!/usr/bin/env python3
"""CritSeparability-8 probe: derived S029 (feed S037, cell names 8.23.0) with a
non-canonical token, on base / c1-only / c2-only / candidate trees. Uses the
committed separability.py table-fixture builder (table edit + mirrored receipt)."""
import importlib.util, json, sys, tempfile
from pathlib import Path
X = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location("sep", X / "lane/.ufo/waves/round-28/tools/separability.py")
sep = importlib.util.module_from_spec(spec); spec.loader.exec_module(sep)
cases = {"P1_derived_anchor_leading_zero": {"S029": ("8.23.00", "8.23.00", "not-fired")},
         "P2_derived_lowered_obs_leading_zero": {"S029": ("8.22.0", "8.22.00", "not-fired")},
         "P3_derived_lowered_canonical": {"S029": ("8.22.0", "8.22.0", "not-fired")}}
for tree in ("base", "wt-c1only", "wt-c2only", "cand"):
    with tempfile.TemporaryDirectory(dir=str(X)) as t:
        temp = Path(t); env = sep.make_env(temp)
        for name, edits in cases.items():
            r = sep.build_table_fixture(X / tree, temp, env, name, edits)
            print("%-10s %-36s exit=%s tb=%s findings=%s" % (tree, name, r["exit"], r["traceback"], r["findings"]))
