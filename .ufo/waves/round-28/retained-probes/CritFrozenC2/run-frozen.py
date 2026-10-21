import importlib.util, sys
from pathlib import Path
spec = importlib.util.spec_from_file_location("c2m", sys.argv[1])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
m.LANE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
sys.argv = ["c2-measure.py"] + sys.argv[2:]
raise SystemExit(m.main())
