import copy, hashlib, importlib.util, json
from pathlib import Path

S = Path("/fast/scratch/hyaku/kagi-r72/R72MutLater")

def load_gate(tree):
    spec = importlib.util.spec_from_file_location("rc", tree / "corpus" / "release-clock.py")
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    return m

def eval_tree(tree, receipt_path):
    """Run gate's own evaluate() with its own sources/rows/captures + given receipt file."""
    m = load_gate(tree)
    sources = m.parse_sources(tree)
    rows = m.parse_bindings(tree)
    captures = m.parse_captures(tree)
    bundle = m.load_receipt_bundle(receipt_path)
    return m.evaluate(sources, rows, captures, bundle), m

F = ["S013","S014","S015","S016","S021","S022","S023","S024","S025","S026"]

# Build synthetic "later release" receipts (offline, no network)
cand_obs = json.loads((S/"cand"/".ufo/waves/round-72/final/observe-r72.json").read_text())
base_receipt_files = []
for tree_name in ("base","cand"):
    rec = copy.deepcopy(cand_obs)
    for o in rec["observations"]:
        if o["id"] in ("S013","S022","S023","S024"):
            o["parsed_version"] = "2.2.2"; o["verdict"] = "fired"
        if o["id"] in ("S014","S015","S016","S021","S025","S026"):
            o["parsed_version"] = "2.7.3"; o["verdict"] = "fired"
    p = S / f"r72-later-{tree_name}.json"
    p.write_text(json.dumps(rec, indent=2, sort_keys=True) + "\n")
    print(tree_name, "synthetic receipt sha:", hashlib.sha256(p.read_bytes()).hexdigest()[:16], "->", p)

# Note: non-F observations in cand receipt also read 2026-11-09, but BASE table
# rows are 2026-11-07, so BASE gate will report RECEIPT-MISMATCH (or other) for
# every row; the point of the probe is the per-F-id verdict behaviour and
# whether evaluate can express "newly fired" at all.

for tree_name, tree in (("BASE", S/"base"), ("CAND", S/"cand")):
    for rec_name, rec in (("r72-current", S/"cand"/".ufo/waves/round-72/final/observe-r72.json"),
                          ("r72-later", S/"r72-later-cand.json")):
        res, m = eval_tree(tree, rec)
        print(f"\n=== {tree_name} gate x {rec_name} ===")
        print(m.print_result.__self__ if False else "", end="")
        # reproduce print_result summary without double print
        from io import StringIO
        import contextlib
        buf = StringIO()
        with contextlib.redirect_stdout(buf):
            m.print_result(res)
        print(buf.getvalue(), end="")
        print("fired=%d derived=%d observed=%d errors=%d" % (res["fired"], res["derived"], res["observed"], len(res["errors"])))
        # per-F detail via row-level check: verdict cells in table vs receipt
        rows = m.parse_bindings(tree)
        by_id = {r["id"]: r for r in rows}
        bundle = m.load_receipt_bundle(rec)
        for fid in F:
            row = by_id[fid]
            vals = dict(zip(m.HEADER, row["fields"]))
            rr = bundle["records"].get(fid, {})
            print(f"  {fid}: table={vals['verdict']}/{vals['anchored_version']}->{vals['observed_version']} "
                  f"receipt={rr.get('verdict')}/{rr.get('parsed_version')} feed={vals['feed_source_id']}")
