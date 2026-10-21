#!/usr/bin/env python3
"""Audit observed receipts, not a replacement for the two frozen instruments."""
import json
import re
import sys


def findings(output):
    if isinstance(output, list):
        output = "\n".join(output)
    return set(re.findall(r"^(.+?) (S[0-9]+)$", output, re.MULTILINE))


def exact(receipt, category, ids):
    out = receipt["stdout"]
    err = receipt.get("stderr", "")
    combined = str(out) + str(err)
    return (receipt["exit"] == 1 and "Traceback" not in combined
            and findings(out) == {(category, row_id) for row_id in ids})


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: strict-receipt-audit.py C1_JSON C2_JSON")
    c1, c2 = (json.load(open(path, encoding="utf-8")) for path in sys.argv[1:])
    checks = {}
    for name, receipt in c1["fixtures"].items():
        checks[name] = exact(receipt, "NON-CANONICAL", ["S040"])
    for name, receipt in c2["results"].items():
        if name.startswith("G"):
            checks[name] = exact(receipt, "DERIVATION", receipt["group"])
    # Adversarial controls for the frozen classifiers' known defects.
    for category, row in [("NOT OBSERVED", "S040"),
                          ("NON-CANONICAL", "S039"), ("UNTYPED", "S040")]:
        assert not exact({"exit": 1, "stdout": category + " " + row},
                         "NON-CANONICAL", ["S040"])
    assert not exact({"exit": 1, "stdout": "NON-CANONICAL S008"},
                     "DERIVATION", ["S008"])
    result = {"revisions": [c1["revision"], c2["revision"]],
              "checks": checks, "controls_rejected": 4,
              "passed": len(checks) == 8 and all(checks.values())}
    print(json.dumps(result, indent=2))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
