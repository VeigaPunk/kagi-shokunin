#!/usr/bin/env python3
"""acme-probe.py — R70Scout: does an UNAUTHENTICATED ACME client get a certificate from the
OpenBao PKI mount? Exercises RFC 8555 newNonce/newAccount/newOrder with an RS256 JWS.
Prints only status codes, key names and challenge type — never a private key, an EAB HMAC
key, or a certificate body. Args: <base-addr> <identifier-name>."""
import base64, json, os, sys, urllib.request, urllib.error
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization

addr = sys.argv[1].rstrip("/")
ident = sys.argv[2] if len(sys.argv) > 2 else "acme-probe.r70.test"

key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
kid = None

def b64u(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()

def jws(url, payload_obj):
    payload = b64u(json.dumps(payload_obj).encode())
    protected = {"alg": "RS256", "nonce": NONCE, "url": url}
    if kid:
        protected["kid"] = kid
    else:
        protected["jwk"] = jwk
    prot = b64u(json.dumps(protected).encode())
    signing_input = (prot + "." + payload).encode()
    sig = key.sign(signing_input, padding.PKCS1v15(), hashes.SHA256())
    return {"protected": prot, "payload": payload, "signature": b64u(sig)}

jwk = {"e": b64u(key.public_key().public_numbers().e.to_bytes(3, "big")),
       "kty": "RSA", "n": b64u(key.public_key().public_numbers().n.to_bytes(256, "big"))}

def request(url, payload_obj, method="POST", extra_headers=None):
    global NONCE
    body = b"" if payload_obj is None else json.dumps(jws(url, payload_obj)).encode()
    headers = {"Content-Type": "application/jose+json"}
    if extra_headers:
        headers.update(extra_headers)
    if body:
        headers["Content-Length"] = str(len(body))
    req = urllib.request.Request(url, data=body if body else None, method=method, headers=headers)
    try:
        r = urllib.request.urlopen(req, timeout=30)
        return r.status, dict(r.headers), r.read()
    except urllib.error.HTTPError as e:
        return e.code, dict(e.headers), e.read()
    except Exception as e:
        return 0, {}, str(e).encode()

# 1. directory
st, hd, b = request(addr + "/v1/pki/acme/directory", None, method="GET")
if st != 200:
    print("DIRECTORY status=%d" % st); sys.exit(0)
dirc = json.loads(b)
print("DIRECTORY status=200 keys=%s" % ",".join(sorted(dirc.keys())))

# 2. newNonce
NONCE = ""
st, hd, b = request(dirc["newNonce"], None, method="GET")
if st == 0:
    print("NEWNONCE_ERR %s" % b[:200].decode("utf-8","replace")); sys.exit(0)
NONCE = ""
for k, v in hd.items():
    if k.lower() == "replay-nonce":
        NONCE = v
        break
print("NEWNONCE status=%d nonce_present=%s" % (st, bool(NONCE)))

# 3. newAccount
st, hd, b = request(dirc["newAccount"], {"termsOfServiceAgreed": True})
print("NEWACCOUNT status=%d location_set=%s body_len=%d" % (st, bool(hd.get("Location")), len(b)))
if st not in (200, 201):
    print("NEWACCOUNT_ERR %s" % b[:200].decode("utf-8", "replace"))
    sys.exit(0)
kid = (hd.get("Location") or "").rstrip("/").split("/")[-1]
for k, v in hd.items():
    if k.lower() == "replay-nonce":
        NONCE = v
        break
NONCE = NONCE or globals().get("NONCE", "")

# 4. newOrder
st, hd, b = request(dirc["newOrder"], {"identifiers": [{"type": "dns", "value": ident}]})
print("NEWORDER status=%d" % st)
if st not in (200, 201):
    print("NEWORDER_ERR %s" % b[:250].decode("utf-8", "replace"))
    sys.exit(0)
order = json.loads(b)
for k, v in hd.items():
    if k.lower() == "replay-nonce":
        NONCE = v
        break
NONCE = NONCE or globals().get("NONCE", "")
print("NEWORDER keys=%s identifiers=%s" % (",".join(sorted(order.keys())),
      json.dumps(order.get("identifiers"))))
for auth in order.get("authorizations") or []:
    print("AUTH url=%s status=%s" % (auth, order.get("status")))
    st2, hd2, b2 = request(auth, {"status": "pending"})
    print("AUTHZ_POLL status=%d" % st2)
    ch = json.loads(b2).get("challenges") or []
    print("CHALLENGES types=%s" % ",".join(sorted(c.get("type", "") for c in ch)))
    for c in ch:
        if c.get("type") == "http-01":
            print("HTTP01 url=%s token_len=%d" % (c.get("url"), len(c.get("token") or "")))
        if c.get("type") == "dns-01":
            print("DNS01 type=dns-01 identifier=%s" % ident)
    # The probe does NOT satisfy the challenge: it measures the unauthenticated request
    # path, not the validation. Report the challenge inventory only.
    break
sys.exit(0)
