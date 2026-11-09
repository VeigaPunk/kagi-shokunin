"""Post-update probe: table updated to later release (QM24 'fixture must fire the successor').
Does the gate read fired for the successor on CAND, but not (silently re-baseline) on BASE?"""
import copy, hashlib, importlib.util, json
from pathlib import Path
S = Path("/fast/scratch/hyaku/kagi-r72/R72MutLater")
F_VAULT = ["S013","S022","S023","S024"]
F_BAO = ["S014","S015","S016","S021","S025","S026"]

def load_gate(tree):
    spec = importlib.util.spec_from_file_location("rc2", tree / "corpus" / "release-clock.py")
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    return m

cand_obs = json.loads((S/"cand"/".ufo/waves/round-72/final/observe-r72.json").read_text())

# Mutant receipt: later release
later = copy.deepcopy(cand_obs)
for o in later["observations"]:
    if o["id"] in F_VAULT: o["parsed_version"]="2.2.2"; o["verdict"]="fired"
    if o["id"] in F_BAO: o["parsed_version"]="2.7.3"; o["verdict"]="fired"

# Mutant TABLE (post-update): observed_version/verdict cell updated to fired@later,
# observed_at stays 2026-11-09 in both trees (receipt dates match table dates)
# BASE table cells are 2026-11-07; receipt date would be 2026-11-09 -> mismatch.
# To isolate verdict logic, we also produce a date-aligned copy for BASE.
for tree_name in ("base","cand"):
    tree = S/tree_name
    lines = (tree/"corpus/release-clocks.tsv").read_text().splitlines()
    hdr = lines[0].split("\t")
    out = [lines[0]]
    for ln in lines[1:]:
        cells = ln.split("\t")
        row = dict(zip(hdr, cells))
        if row["id"] in F_VAULT:
            row["observed_version"]="2.2.2"; row["verdict"]="fired"; row["observed_at"]="2026-11-09"
        if row["id"] in F_BAO:
            row["observed_version"]="2.7.3"; row["verdict"]="fired"; row["observed_at"]="2026-11-09"
        out.append("\t".join(row[c] for c in hdr))
    dest = S/f"{tree_name}-later-table.tsv"
    dest.write_text("\n".join(out)+"\n")
    print(tree_name, "mutant table ->", dest)
    # receipt for this tree: later; for base also need date 2026-11-09 which later already has
    rec = S/f"{tree_name}-later-receipt.json"
    rec.write_text(json.dumps(later, indent=2, sort_keys=True)+"\n")

for tree_name in ("base","cand"):
    tree = S/tree_name
    # splice mutant table into scratch copy of tree
    import shutil
    dest_tree = S/f"{tree_name}-later"
    if dest_tree.exists(): shutil.rmtree(dest_tree)
    shutil.copytree(tree, dest_tree)
    # mutant table in place
    (dest_tree/"corpus/release-clocks.tsv").write_text((S/f"{tree_name}-later-table.tsv").read_text())
    m = load_gate(dest_tree)
    sources = m.parse_sources(dest_tree)
    rows = m.parse_bindings(dest_tree)
    captures = m.parse_captures(dest_tree)
    bundle = m.load_receipt_bundle(S/f"{tree_name}-later-receipt.json")
    res = m.evaluate(sources, rows, captures, bundle)
    print(f"\n=== {tree_name.upper()} table-updated + later receipt ===")
    from io import StringIO
    import contextlib
    buf = StringIO()
    with contextlib.redirect_stdout(buf):
        m.print_result(res)
    print(buf.getvalue(), end="")
    print("fired=%d derived=%d observed=%d" % (res["fired"], res["derived"], res["observed"]))
    # BASE extra: S012/S027/S028/S072 remain fired; how many of the 10 F are counted fired?
    by_id = {r["id"]: r for r in rows}
    n_fired = 0
    for fid in F_VAULT+F_BAO:
        v = dict(zip(m.HEADER, by_id[fid]["fields"]))
        # fired counts in evaluate only when row_valid; check errors for fid
        errs = [e for e in res["errors"] if e[1]==fid]
        print(f"  {fid}: verdict={v['verdict']} errors={errs}")
