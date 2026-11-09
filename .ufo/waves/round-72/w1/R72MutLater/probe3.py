"""No table update at all: does a later-release OBSERVATION alone change the stored verdict?
This is the exact seat wording ('observation ... makes the clocks read fired')."""
import copy, importlib.util, json
from pathlib import Path
S = Path("/fast/scratch/hyaku/kagi-r72/R72MutLater")
F_VAULT = ["S013","S022","S023","S024"]; F_BAO = ["S014","S015","S016","S021","S025","S026"]
def load_gate(tree):
    spec = importlib.util.spec_from_file_location("rc3", tree / "corpus" / "release-clock.py")
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    return m
later = copy.deepcopy(json.loads((S/"cand"/".ufo/waves/round-72/final/observe-r72.json").read_text()))
for o in later["observations"]:
    if o["id"] in F_VAULT: o["parsed_version"]="2.2.2"; o["verdict"]="fired"
    if o["id"] in F_BAO: o["parsed_version"]="2.7.3"; o["verdict"]="fired"
rec = S/"later-receipt-nodate.json"
rec.write_text(json.dumps(later, indent=2, sort_keys=True)+"\n")
# date-aligned receipts: table observed_at must equal receipt date.
for tree_name in ("base","cand"):
    tree = S/tree_name
    m = load_gate(tree)
    sources = m.parse_sources(tree); rows = m.parse_bindings(tree); captures = m.parse_captures(tree)
    bundle = m.load_receipt_bundle(rec)
    res = m.evaluate(sources, rows, captures, bundle)
    print(f"{tree_name}: fired={res['fired']} observed={res['observed']} errors={len(res['errors'])} passed={res['passed']}")
    f_errs = [e for e in res["errors"] if e[1] in F_VAULT+F_BAO]
    print("  F errors:", f_errs[:12])
