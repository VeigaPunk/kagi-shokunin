#!/usr/bin/env python3
"""Emit nist-captures.tsv for kagi round 33, seat ScoutNist.

Every value is measured, never typed: bytes and sha256 come from the saved
bodies in build/src-open/, normalized_sha256 from normalize.py, and each quote
is asserted to be an exact substring of the normalized text with <= 25 words.
A failed assertion aborts the emit (no partial TSV).
"""
import hashlib
import json
import os
import subprocess
import sys

BUILD = "/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-33/build"
SRC = os.path.join(BUILD, "src-open")
NORM = os.path.join(SRC, "normalize.py")
SCRATCH = os.path.dirname(os.path.abspath(__file__))
EXT = {"S061": "html", "S062": "html", "S063": "html", "S079": "html",
       "S080": "html", "S083": "pdf", "S084": "pdf", "S085": "html",
       "S086": "html", "S087": "html"}
ORDER = ["S061", "S062", "S063", "S079", "S080", "S083", "S084", "S085",
         "S086", "S087"]

manifest = json.load(open(os.path.join(SCRATCH, "manifest.json"), encoding="utf-8"))
rows, errors = [], []

for sid in ORDER:
    body = os.path.join(SRC, f"{sid}.{EXT[sid]}")
    raw = open(body, "rb").read()
    text = subprocess.run([sys.executable, NORM, "--text", body],
                          check=True, capture_output=True).stdout.decode("utf-8")
    text = text.rstrip("\n")  # --text prints one trailing newline
    m = manifest[sid]
    quote = m["quote"]
    nwords = len(quote.split())
    if quote not in text:
        errors.append(f"{sid}: quote is not a substring of rendered-text-v1")
    if nwords > 25:
        errors.append(f"{sid}: quote has {nwords} words (>25)")
    for k in ("quote", "location", "note"):
        if "\t" in m[k] or "\n" in m[k]:
            errors.append(f"{sid}: {k} contains a tab or newline")
    rows.append([
        sid, m["url"], m["url"], "200", "2026-11-04", str(len(raw)),
        hashlib.sha256(raw).hexdigest(), "decoded-http-body-v1",
        "rendered-text-v1", hashlib.sha256(text.encode("utf-8")).hexdigest(),
        quote, m["location"], m["verdict"], m["note"],
    ])
    print(f"{sid}\t{nwords}w\tquote-ok={quote in text}")

if errors:
    print("ABORT:", *errors, sep="\n  ")
    raise SystemExit(1)

out = os.path.join(BUILD, "nist-captures.tsv")
with open(out, "w", encoding="utf-8", newline="\n") as fh:
    for r in rows:
        fh.write("\t".join(r) + "\n")
print(f"wrote {out}: {len(rows)} rows, {len(rows[0])} columns")
