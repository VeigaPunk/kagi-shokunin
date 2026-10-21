import hashlib, importlib.util, json, shutil, sys, tempfile
from pathlib import Path
HERE = Path(__file__).resolve().parent
CAND = HERE / "cand"
spec = importlib.util.spec_from_file_location("c2m", CAND / ".ufo/waves/round-28/tools/c2-measure.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}

# Probe A: receipt-only failure. Unmodified candidate table; receipt copy gives G1 rows a
# non-canonical receipt error. No table edit, so no DERIVATION is possible.
root = HERE / "probeA"; shutil.rmtree(root, ignore_errors=True); (root / "corpus").mkdir(parents=True)
for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py", "release-clocks.tsv"):
    shutil.copyfile(CAND / "corpus" / rel, root / "corpus" / rel)
receipt = json.loads((CAND / ".ufo/waves/round-26/observe-2.json").read_text())
g1 = m.GROUPS["G1"]["rows"]
for rec in receipt["observations"]:
    if rec["id"] in g1:
        rec["error"] = m_err = "non-canonical version token: 3.13.03"
rp = root / "receipt.json"; rp.write_text(json.dumps(receipt, indent=2) + "\n")
argv = ["python3", "-I", "-B", str(CAND / "corpus/release-clock.py"), "--root", str(root),
        "--receipt", str(rp), "--receipt-sha", hashlib.sha256(rp.read_bytes()).hexdigest()]
r = m.classify("probeA", g1, m.run(argv, CAND, env), [], g1)
print("A exit=%d findings=%s categories=%s derivation_exact=%s" % (r["exit"], r["findings"], r["finding_categories"], r["derivation_exact"]))

# Probe B: mutant clock relabels DERIVATION -> NON-CANONICAL (then -> UNTYPED); frozen fixtures.
for label in ("NON-CANONICAL", "UNTYPED"):
    with tempfile.TemporaryDirectory(dir=str(HERE)) as td:
        temp = Path(td); clone = temp / "clone"
        shutil.copytree(CAND / "corpus", clone / "corpus")
        (clone / ".ufo/waves/round-26").mkdir(parents=True)
        shutil.copyfile(CAND / ".ufo/waves/round-26/observe-2.json", clone / ".ufo/waves/round-26/observe-2.json")
        p = clone / "corpus/release-clock.py"; src = p.read_text()
        assert src.count('errors.add(("DERIVATION", source_id))') == 1
        p.write_text(src.replace('errors.add(("DERIVATION", source_id))', 'errors.add(("%s", source_id))' % label))
        res = m.measure_clone(clone, temp, env)
        print("B[%s] exact=%d/4 accepted=%d/4 control_clean=%s sample=%s" % (label,
              sum(res[g]["derivation_exact"] for g in m.GROUPS), sum(res[g]["accepted_clean"] for g in m.GROUPS),
              res["control"]["control_clean"], res["G4"]["findings"]))
