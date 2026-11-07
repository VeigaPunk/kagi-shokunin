#!/usr/bin/env python3
"""R57Labrat probe 4: cross-check the logged value against /sys/audit-hash.

Proves (a) the logged value in the default device is exactly the device HMAC of
the plaintext, (b) the HMAC is salted (not a bare SHA-256), and (c) disable +
re-enable rotates the salt. Prints booleans and 12-hex digests only.
"""
import hashlib
import json
import os
import sys
import urllib.error
import urllib.request

ADDR = os.environ["BAO_ADDR"]
TOKEN = os.environ["BAO_TOKEN"]
WORK = os.environ["PROBE_WORK"]


def call(method, path, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(ADDR + "/v1/" + path, data=data, method=method)
    req.add_header("X-Vault-Token", TOKEN)
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status, json.loads(r.read() or b"{}")
    except urllib.error.HTTPError as e:
        return e.code, {"raw": e.read().decode(errors="replace")[:300]}


def audit_hash(path, value):
    st, body = call("POST", "sys/audit-hash/" + path, {"input": value})
    h = (body.get("data") or {}).get("hash")
    return st, h


def logged_value_hex(logfile):
    hexes = []
    with open(logfile, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            e = json.loads(line)
            if e.get("type") != "request":
                continue
            req = e.get("request") or {}
            if req.get("path") != "secret/data/probe" or req.get("operation") not in ("create", "update"):
                continue
            v = ((req.get("data") or {}).get("data") or {}).get("value", "")
            if isinstance(v, str) and v.startswith("hmac-sha256:"):
                hexes.append(v.split(":", 1)[1])
    return hexes[-1] if hexes else None


def main() -> int:
    nonce = os.environ["PROBE_NONCE"]
    log1 = os.path.join(WORK, "h1.log")
    log2 = os.path.join(WORK, "h2.log")
    out = {}
    st, _ = call("PUT", "sys/audit/file", {"type": "file", "options": {"file_path": log1}})
    out["enable_rc"] = st
    st, b = call("PUT", "secret/data/probe", {"data": {"value": nonce}})
    out["write_rc"] = st
    st, h1 = audit_hash("file", nonce)
    out["audit_hash_rc"] = st
    l1 = logged_value_hex(log1)
    h1hex = (h1 or "").split(":", 1)[-1]
    out["logged_before"] = (l1 or "")[:12]
    out["audit_hash_before"] = h1hex[:12]
    out["logged_equals_hmac_before"] = bool(l1 and h1hex and l1 == h1hex)
    out["logged_len_hex"] = len(l1) if l1 else 0
    out["hmac_is_not_bare_sha256"] = bool(
        l1 and l1.lower() != hashlib.sha256(nonce.encode()).hexdigest())
    out["audit_hash_prefix"] = (h1 or "").split(":", 1)[0] + ":" if h1 else ""
    st, _ = call("DELETE", "sys/audit/file")
    out["disable_rc"] = st
    st, _ = call("PUT", "sys/audit/file", {"type": "file", "options": {"file_path": log2}})
    out["reenable_rc"] = st
    st, h2 = audit_hash("file", nonce)
    out["audit_hash_after_rc"] = st
    st, b = call("PUT", "secret/data/probe", {"data": {"value": nonce}})
    out["write_after_rc"] = st
    l2 = logged_value_hex(log2)
    h2hex = (h2 or "").split(":", 1)[-1]
    out["logged_after"] = (l2 or "")[:12]
    out["audit_hash_after"] = h2hex[:12]
    out["logged_equals_hmac_after"] = bool(l2 and h2hex and l2 == h2hex)
    out["salt_rotated_hmac"] = bool(h1hex and h2hex and h1hex != h2hex)
    out["logged_differs"] = bool(l1 and l2 and l1 != l2)
    json.dump(out, sys.stdout, indent=1, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
