#!/usr/bin/env python3
"""Build receipt-carrier fixtures: receipt parsed_version malformed, table canonical.

Only the receipt JSON is edited; corpus/release-clocks.tsv, corpus/SOURCES.md and
all code stay untouched (round-28 plan C1/C2 fixture discipline).
"""
import hashlib
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
SRC = HERE / "cand" / ".ufo" / "waves" / "round-26" / "observe-2.json"
OUT = HERE / "fixtures"
OUT.mkdir(exist_ok=True)

base = json.loads(SRC.read_text())
records = {r["id"]: r for r in base["observations"]}


def emit(name, mutate):
    doc = json.loads(json.dumps(base))
    by_id = {r["id"]: r for r in doc["observations"]}
    mutate(by_id)
    path = OUT / (name + ".json")
    path.write_text(json.dumps(doc, ensure_ascii=False, indent=2, sort_keys=True) + "\n")
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    print("%s\t%s\t%s" % (name, path, digest))
    return path, digest


def set_parsed(row_id, value):
    def m(by_id):
        by_id[row_id]["parsed_version"] = value
    return m


emit("RC0-control", lambda by_id: None)
emit("RC1-leading-zero", set_parsed("S040", "3.15.01"))
emit("RC2-oversize", set_parsed("S040", "3.15." + "1" * 4301))
emit("RC3-fired-row-leading-zero", set_parsed("S027", "3.15.01"))
emit("RC4-quote-row-parsed", set_parsed("S005", "3.15.01"))


def rc5(by_id):
    row = by_id["S040"]
    row["parsed_version"] = None
    row["error"] = "non-canonical version token: feed newest stable entry"


emit("RC5-typed-error-control", rc5)
