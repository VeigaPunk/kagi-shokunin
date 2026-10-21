#!/usr/bin/env python3
"""RC6/RC7/RC8: receipt-carrier variants that go beyond RC1/RC2.

RC6: table AND receipt carry the same malformed token (the round-28 F1/F2
     "mirror" shape) -> shows which side the typed finding comes from.
RC7: receipt parsed_version is a 4301-digit JSON *number* (not a string).
RC8: receipt parsed_version is a small JSON number.
"""
import hashlib
import json
import pathlib
import shutil

HERE = pathlib.Path(__file__).resolve().parent
SRC = HERE / "cand" / ".ufo" / "waves" / "round-26" / "observe-2.json"
OUT = HERE / "fixtures"
base = json.loads(SRC.read_text())


def emit(name, doc):
    path = OUT / (name + ".json")
    path.write_text(json.dumps(doc, ensure_ascii=False, indent=2, sort_keys=True) + "\n")
    print("%s\t%s\t%s" % (name, path, hashlib.sha256(path.read_bytes()).hexdigest()))


# RC7: JSON number with 4301 digits -> json.loads must build a Python int.
doc = json.loads(json.dumps(base))
for r in doc["observations"]:
    if r["id"] == "S040":
        r["parsed_version"] = json.loads("1" + "1" * 4300)
path = OUT / "RC7-huge-json-number.json"
path.write_text(json.dumps(doc, ensure_ascii=False, indent=2, sort_keys=True) + "\n")
print("RC7-huge-json-number\t%s\t%s" % (path, hashlib.sha256(path.read_bytes()).hexdigest()))

# RC8: small JSON number
doc = json.loads(json.dumps(base))
for r in doc["observations"]:
    if r["id"] == "S040":
        r["parsed_version"] = 315
path = OUT / "RC8-small-json-number.json"
path.write_text(json.dumps(doc, ensure_ascii=False, indent=2, sort_keys=True) + "\n")
print("RC8-small-json-number\t%s\t%s" % (path, hashlib.sha256(path.read_bytes()).hexdigest()))
