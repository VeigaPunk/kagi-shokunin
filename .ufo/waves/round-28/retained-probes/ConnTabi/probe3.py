import importlib.util, sys
spec = importlib.util.spec_from_file_location("rc", sys.argv[1])
rc = importlib.util.module_from_spec(spec); spec.loader.exec_module(rc)
from pathlib import Path
try:
    src = rc.parse_sources(Path(sys.argv[2]))
    print("tabi parse_sources OK rows=%d" % len(src))
    for sid in ("S029","S033","S034","S035","S037"):
        row = src.get(sid)
        print(sid, "anchor=", (row["anchor"][:70] if row else None))
except rc.SetupError as e:
    print("SETUP", e)
except Exception as e:
    print("OTHER", type(e).__name__, e)
