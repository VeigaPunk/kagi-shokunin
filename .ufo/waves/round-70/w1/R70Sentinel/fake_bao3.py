#!/usr/bin/env python3
"""Fake OpenBao PKI API — counter-forgery fixture for the round-70 sentinel audit.

Modes:
  single <workdir> <port>            : listen on one port.
  delayed-noreuse <workdir> <port> <s>: bind (NO SO_REUSEADDR) then listen after <s> seconds.
  range <workdir> <lo> <hi> <scratch>: hold every port in [lo,hi) bound-but-not-listening,
                                       learn the port each run actually selected from the
                                       trial's own server.log (which records the EADDRINUSE),
                                       and listen on it.

Per-run state is keyed on the dev root token the trial presents, because the counter runs
the trial seven times and each run must be answered independently.
"""
import glob
import hashlib
import json
import os
import re
import selectors
import socket
import sys
import threading
import time

WORK = sys.argv[1]
MODE = sys.argv[2]
LO = int(sys.argv[3]) if MODE != "range" else int(sys.argv[3])
HI = int(sys.argv[4]) if MODE == "range" else LO
SCRATCH = sys.argv[5] if MODE == "range" else ""


def rd(p):
    with open(p) as f:
        return f.read()


leaf1h = rd(os.path.join(WORK, "leaf1h.crt"))
leaf24h = rd(os.path.join(WORK, "leaf24h.crt"))
ca_pem = rd(os.path.join(WORK, "ca", "ca.crt"))
crl_with = rd(os.path.join(WORK, "crl_with.pem"))
crl_empty = rd(os.path.join(WORK, "crl_empty.pem"))

S4 = os.environ.get("FAKE_S4", "")
S5 = "AAAA1111BBBB2222CCCC3333DDDD4444EEEE5555"
S5C = "1111222233334444555567777888899990000"
S2 = "2222333344445555666677778888999900001111"

LOG = os.path.join(WORK, "requests.log")
LOCK = threading.Lock()
RUNS = {}


def st(tok):
    s = RUNS.get(tok)
    if s is None:
        s = {"roles": {}, "store": [], "no_store": [], "revoked": False}
        RUNS[tok] = s
    return s


def logline(s):
    with LOCK:
        with open(LOG, "a") as f:
            f.write(s + "\n")


def body_fields(raw):
    raw = raw.decode("utf-8", "replace")
    if raw.strip().startswith("{"):
        try:
            return json.loads(raw)
        except Exception:
            return {}
    out = {}
    for part in raw.split("&"):
        if "=" in part:
            k, v = part.split("=", 1)
            out[k] = v.replace("%2F", "/").replace("+", " ")
    return out


def reply_json(obj, code=200):
    body = json.dumps(obj).encode()
    head = ("HTTP/1.1 %d %s\r\nContent-Type: application/json\r\n"
            "Content-Length: %d\r\nConnection: keep-alive\r\n\r\n"
            % (code, "OK" if code == 200 else "Error", len(body))).encode()
    return head + body


SEAL = {"initialized": True, "sealed": False, "standby": False,
        "performance_standay": False, "server_time_utc": 1700000000,
        "version": "2.7.2", "cluster_name": "fake-cluster", "cluster_id": "fake",
        "storage_type": "inmem"}


def handle(method, path_q, headers, raw):
    path = path_q.split("?")[0]
    tok = headers.get("x-vault-token", "")
    logline("%s %s token_len=%d token_sha8=%s" % (
        method, path_q, len(tok),
        hashlib.sha256(tok.encode()).hexdigest()[:8] if tok else "-"))
    f = body_fields(raw)
    s = st(tok)

    if path in ("/v1/sys/seal-status", "/v1/sys/health", "/v1/sys/leader",
                "/v1/sys/ha-status", "/v1/sys/init"):
        return reply_json(SEAL)
    if path.startswith("/v1/sys/"):
        return reply_json({"data": {}})

    m = re.match(r"^/v1/pki/roles/([^/]+)$", path)
    if m and method in ("PUT", "POST"):
        s["roles"][m.group(1)] = f
        return reply_json({"data": {}})

    if path == "/v1/pki/root/generate/internal":
        return reply_json({"data": {"certificate": ca_pem, "issuer_id": "i",
                                    "issuer_name": "r70root", "key_id": "k",
                                    "key_name": "kn", "serial_number": S4,
                                    "expiration": 0}})
    if path == "/v1/pki/root/generate/exported":
        return reply_json({"data": {"certificate": ca_pem, "private_key": leaf1h,
                                    "private_key_type": "rsa", "issuer_id": "i",
                                    "key_id": "k", "serial_number": S4,
                                    "expiration": 0}})
    if path == "/v1/pki/config/issuers":
        return reply_json({"data": {}})

    m = re.match(r"^/v1/pki/issue/([^/]+)$", path)
    if m and method in ("PUT", "POST"):
        role = m.group(1)
        r = s["roles"].get(role, {})
        cn = f.get("common_name", "")
        if r.get("allow_any_name") != "true":
            doms = [d.strip() for d in (r.get("allowed_domains") or "").split(",") if d.strip()]
            ok = False
            for d in doms:
                if cn == d or cn.endswith("." + d):
                    ok = True
            if not ok:
                return reply_json({"errors": ["common name not allowed"]}, 400)
        cert = leaf24h if r.get("max_ttl", "") == "" else leaf1h
        ser = S4 if role == "t4" else (S5 if role == "t5" else (S5C if role == "t5c" else S2))
        if r.get("no_store") == "true":
            if ser not in s["no_store"]:
                s["no_store"].append(ser)
        else:
            if ser not in s["store"]:
                s["store"].append(ser)
        return reply_json({"data": {"certificate": cert, "private_key": leaf1h,
                                    "private_key_type": "rsa", "serial_number": ser,
                                    "issuing_ca": ca_pem, "ca_chain": [ca_pem],
                                    "not_before": 0, "expiration": 0}})

    if path == "/v1/pki/revoke":
        s["revoked"] = True
        return reply_json({"data": {"revocation_time": 1, "state": "revoked",
                                    "revocation_time_rfc3339": "2023-11-14T22:13:20Z"}})

    if path == "/v1/pki/cert/crl":
        return reply_json({"data": {"certificate": crl_with if s["revoked"] else crl_empty,
                                    "revocation_time": 1 if s["revoked"] else 0}})

    if path == "/v1/pki/certs":
        return reply_json({"data": {"keys": list(s["store"])}})

    m = re.match(r"^/v1/pki/cert/(.+)$", path)
    if m:
        ser = m.group(1)
        if ser in s["store"]:
            return reply_json({"data": {"certificate": leaf1h, "serial_number": ser,
                                        "expiration": 0}})
        return reply_json({"errors": []}, 404)

    return reply_json({"errors": []}, 404)


def serve_conn(conn):
    buf = b""
    try:
        while True:
            while b"\r\n\r\n" not in buf:
                chunk = conn.recv(65536)
                if not chunk:
                    return
                buf += chunk
            head, buf = buf.split(b"\r\n\r\n", 1)
            lines = head.decode("latin1").split("\r\n")
            parts = lines[0].split()
            method, path_q = (parts[0], parts[1]) if len(parts) >= 2 else ("GET", "/")
            headers = {}
            for line in lines[1:]:
                if ":" in line:
                    k, v = line.split(":", 1)
                    headers[k.strip().lower()] = v.strip()
            n = int(headers.get("content-length") or 0)
            while len(buf) < n:
                chunk = conn.recv(65536)
                if not chunk:
                    break
                buf += chunk
            raw, buf = buf[:n], buf[n:]
            conn.sendall(handle(method, path_q, headers, raw))
    except Exception:
        pass
    finally:
        try:
            conn.close()
        except Exception:
            pass


def find_selected_port():
    for f in glob.glob(os.path.join(SCRATCH, "**", "server.log"), recursive=True):
        try:
            txt = open(f, errors="replace").read()
        except Exception:
            continue
        m = re.search(r"listen tcp 127\.0\.0\.1:(\d+): bind: address already in use", txt)
        if m:
            return int(m.group(1))
    return None


sel = selectors.DefaultSelector()

if MODE == "range":
    socks = {}
    for p in range(LO, HI):
        s = socket.socket()
        try:
            s.bind(("127.0.0.1", p))
            socks[p] = s
        except OSError:
            s.close()
    seen = set()

    def watcher():
        while True:
            p = find_selected_port()
            if p is not None and p in socks and p not in seen:
                try:
                    socks[p].listen(64)
                    sel.register(socks[p], selectors.EVENT_READ, None)
                    seen.add(p)
                    logline("FAKE now listening on the trial's selected port %d" % p)
                except OSError:
                    pass
            time.sleep(0.02)

    threading.Thread(target=watcher, daemon=True).start()
    while True:
        if not sel.get_map():
            time.sleep(0.02)
            continue
        for key, _ in sel.select(timeout=0.1):
            try:
                conn, _addr = key.fileobj.accept()
            except Exception:
                continue
            threading.Thread(target=serve_conn, args=(conn,), daemon=True).start()
else:
    s = socket.socket()
    if MODE != "delayed-noreuse":
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", LO))
    if MODE == "delayed-noreuse":
        time.sleep(float(sys.argv[4]))
    s.listen(64)
    sel.register(s, selectors.EVENT_READ, None)
    while True:
        for key, _ in sel.select(timeout=0.2):
            try:
                conn, _addr = key.fileobj.accept()
            except Exception:
                continue
            threading.Thread(target=serve_conn, args=(conn,), daemon=True).start()
