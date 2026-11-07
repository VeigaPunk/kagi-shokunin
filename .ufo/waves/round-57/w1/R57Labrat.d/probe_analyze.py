#!/usr/bin/env python3
"""R57Labrat probe analyzer: shapes, counts and digests only.

Never prints a written value, a token, or any audit log line. The two probe
values arrive via PROBE_NONCES (comma separated) so they never touch argv.
"""
import argparse
import hashlib
import json
import os
import re
import sys


def digest(s: str) -> str:
    return hashlib.sha256(s.encode()).hexdigest()[:16]


def walk(obj, path=""):
    if isinstance(obj, dict):
        for k, v in obj.items():
            p = f"{path}.{k}" if path else k
            yield from walk(v, p)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            p = f"{path}[{i}]"
            yield from walk(v, p)
    else:
        yield path, obj


def analyze(path, label, nonces, token):
    rows = []
    nonce_hits = []
    token_hits = 0
    bad = 0
    hmac_paths = {}
    value_rows = []
    if not os.path.exists(path):
        return {"label": label, "file": os.path.basename(path), "present": False}
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                e = json.loads(line)
            except Exception:
                bad += 1
                continue
            req = e.get("request") or {}
            idx = len(rows)
            vfields = []
            for p, v in walk(e):
                if not isinstance(v, str):
                    continue
                if v in nonces:
                    nonce_hits.append({"entry": idx, "json_ptr": p, "len": len(v)})
                if token and v == token:
                    token_hits += 1
                if v.startswith("hmac-sha256:"):
                    hmac_paths[p] = hmac_paths.get(p, 0) + 1
                leaf = p.split(".")[-1].split("[")[0]
                if leaf == "value":
                    if v.startswith("hmac-sha256:"):
                        prefix, hexlen = "hmac-sha256:", len(v.split(":", 1)[1])
                    elif v in nonces:
                        prefix, hexlen = "plain-nonce", len(v)
                    else:
                        prefix, hexlen = "other", len(v)
                    vfields.append({"json_ptr": p, "prefix": prefix,
                                    "hexlen": hexlen, "digest": digest(v)})
                    value_rows.append({"entry": idx, "type": e.get("type"),
                                       "json_ptr": p, **vfields[-1]})
            rows.append({"i": idx, "type": e.get("type"),
                         "operation": req.get("operation"),
                         "api_path": req.get("path"),
                         "value_fields": vfields})
    types = {}
    for r in rows:
        types[r["type"]] = types.get(r["type"], 0) + 1
    return {"label": label, "file": os.path.basename(path), "present": True,
            "entries": len(rows), "bad_lines": bad, "types": types,
            "nonce_count": len(nonce_hits), "nonce_hits": nonce_hits,
            "token_plaintext_hits": token_hits,
            "hmac_field_paths": sorted(hmac_paths),
            "entry_rows": rows, "value_rows": value_rows}


def req_vals(doc):
    return [v for v in doc.get("value_rows", [])
            if v["type"] == "request" and v["json_ptr"].endswith("request.data.data.value")]


def resp_vals(doc):
    return [v for v in doc.get("value_rows", [])
            if v["type"] == "response" and v["json_ptr"].endswith("response.data.data.value")]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--default", required=True)
    ap.add_argument("--raw", required=True)
    ap.add_argument("--after", required=True)
    a = ap.parse_args()
    nonces = [x for x in os.environ.get("PROBE_NONCES", "").split(",") if x]
    token = os.environ.get("PROBE_TOKEN", "")
    if len(nonces) != 2:
        print("PROBE: SETUP missing nonces", file=sys.stderr)
        return 2
    d = analyze(a.default, "default", nonces, token)
    raw = analyze(a.raw, "raw", nonces, token)
    aft = analyze(a.after, "after", nonces, token)

    dreq, dresp = req_vals(d), resp_vals(d)
    areq = req_vals(aft)
    dset = sorted({v["digest"] for v in dreq})
    dresp_set = sorted({v["digest"] for v in dresp})
    a_set = sorted({v["digest"] for v in areq})
    checks = {
        "default_entries": d["entries"],
        "default_types": d["types"],
        "default_hmac_value_req_count": len(dreq),
        "default_hmac_value_resp_count": len(dresp),
        "default_req_prefixes": sorted({v["prefix"] for v in dreq}),
        "default_req_hexlens": sorted({v["hexlen"] for v in dreq}),
        "default_nonce_plaintext_count": d["nonce_count"],
        "default_token_plaintext_count": d["token_plaintext_hits"],
        "default_req_unique_digests": len(dset),
        "default_resp_unique_digests": len(dresp_set),
        "default_req_digest": dset[0] if len(dset) == 1 else None,
        "default_req_resp_digest_equal": bool(dset) and dset == dresp_set,
        "raw_entries": raw["entries"],
        "raw_nonce_plaintext_count": raw["nonce_count"],
        "raw_nonce_field_prefixes": sorted({v["prefix"] for v in raw["value_rows"]}),
        "raw_token_plaintext_count": raw["token_plaintext_hits"],
        "after_entries": aft["entries"],
        "after_req_unique_digests": len(a_set),
        "after_req_digests_in_order": [v["digest"] for v in areq],
        "after_req_prefixes": sorted({v["prefix"] for v in areq}),
        "after_nonce_plaintext_count": aft["nonce_count"],
        "salt_rotated": bool(dset) and bool(areq) and dset[0] != areq[0]["digest"],
        "within_salt_before_deterministic": len(dset) == 1 and len(dreq) >= 2,
        "within_salt_after_deterministic": len(areq) >= 2 and areq[0]["digest"] == areq[1]["digest"],
        "value_dependence_after": len(areq) >= 3 and areq[0]["digest"] != areq[2]["digest"],
        "nonce1_digest": digest(nonces[0]),
        "nonce2_digest": digest(nonces[1]),
        "value_space_bits": 160,
    }
    out = {"default": d, "raw": raw, "after": aft, "checks": checks}
    json.dump(out, sys.stdout, indent=1, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
