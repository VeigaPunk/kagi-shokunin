#!/usr/bin/env python3
"""quote-locate-r71.py — R71Scout: locate each quote the frontier cites in the round-71 captures,
using the LANE'S COMMITTED normalizer (corpus/rendered-text-v1.py, imported as a module; no
re-implementation). Prints one row per quote:
QUOTE <id> <body-id> count=<n> offset=<normalized offset> words=<w> <body path>.
No writes outside stdout, no network, no secret values. Exit 0 iff every quote locates at least once."""
import importlib.util
import os
import sys

ROOT = "/home/vgpnk/Projects/shokunin/kagi-shokunin"

spec = importlib.util.spec_from_file_location("rtv1", os.path.join(ROOT, "corpus/rendered-text-v1.py"))
rtv1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rtv1)

BODIES = {
    "S170": ".ufo/waves/round-71/capture/S170.body",
    "S173": ".ufo/waves/round-71/capture/S173.body",
}

QUOTES = [
    # mechanic 1 — issuer no longer part of the mount
    ("M1-Q1", "S173", "When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL."),
    ("M1-Q2", "S170", "This endpoint deletes the specified issuer. A warning is emitted and the default is cleared if this issuer is the default issuer."),
    ("M1-Q3", "S170", "Mirroring the behavior of earlier OpenBao versions, we add certificates revoked by an unknown issuer to the default issuer's CRL."),
    # mechanic 2 — leaf_not_after_behavior=permit
    ("M2-Q1", "S170", "permit to allow this issuance to succeed with a NotAfter value exceeding that of this issuer."),
    ("M2-Q2", "S170", "Not all values result in leaf certificates that can be validated through the entire validity period."),
    ("M2-Q3", "S173", "should OpenBao err , preventing issuance of a longer-lived leaf cert than issuer, silently truncate to that of the issuer's NotAfter value, or permit longer expirations."),
    # mechanic 3 — issuer revocation
    ("M3-Q1", "S170", "This endpoint allows an operator to revoke an issuer certificate, marking it unable to issue new certificates and adding it to other issuers' CRLs, if they have signed this issuer's certificate."),
    ("M3-Q2", "S170", "Revoked issuers will not appear on their own CRLs."),
    ("M3-Q3", "S170", "Revoked issuers may not appear on other CRLs if a suitable parent is not present in the same mount point."),
    ("M3-Q4", "S170", "Warning : This operation cannot be undone!"),
    ("M3-Q5", "S170", "Valid options are: read-only , to allow this issuer to be read; implicit; always allowed;"),
    ("M3-Q6", "S170", "preventing new certificate issuance"),
    ("M1-Q4", "S170", "This endpoint deletes the specified issuer."),
]


def main():
    cache = {}
    rc = 0
    for qid, sid, quote in QUOTES:
        body = BODIES[sid]
        path = os.path.join(ROOT, body)
        if not os.path.isfile(path):
            print("QUOTE %s %s MISSING body" % (qid, sid))
            rc = 1
            continue
        if sid not in cache:
            with open(path, "rb") as fh:
                cache[sid] = rtv1.normalize_bytes(fh.read()).decode("utf-8")
        text = cache[sid]
        needle = rtv1.collapse_quote(quote)
        count = text.count(needle)
        off = text.find(needle)
        print("QUOTE %s %s count=%d offset=%d words=%d %s"
              % (qid, sid, count, off, len(needle.split()), body))
        if count < 1:
            rc = 1
    return rc


if __name__ == "__main__":
    sys.exit(main())
