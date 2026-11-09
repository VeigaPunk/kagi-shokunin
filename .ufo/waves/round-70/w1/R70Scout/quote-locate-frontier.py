#!/usr/bin/env python3
"""quote-locate-frontier.py — R70Scout: locate each quote the frontier report cites in a
committed capture body, using the LANE'S COMMITTED normalizer (corpus/rendered-text-v1.py,
imported as a module -- no re-implementation). Prints one row per quote:
QUOTE <id> <body-id> count=<n> offset=<normalized offset> words=<w> <body path>.
No writes, no network, no secret values. Exit 0 iff every quote locates at least once."""
import importlib.util
import os
import sys

ROOT = "/home/vgpnk/Projects/shokunin/kagi-shokunin"

spec = importlib.util.spec_from_file_location("rtv1", os.path.join(ROOT, "corpus/rendered-text-v1.py"))
rtv1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rtv1)

BODIES = {
    "S170": ".ufo/waves/round-70/capture/S170.body",
    "S171": ".ufo/waves/round-70/capture/S171.body",
    "S173": ".ufo/waves/round-70/w1/R70Scout/capture/S173-openbao-pki-considerations.body",
    "S174": ".ufo/waves/round-70/w1/R70Scout/capture/S174-openbao-pki-rotation-primitives.body",
}

QUOTES = [
    ("SC-Q1", "S170", "Behavior of a leaf's NotAfter field during issuance."),
    ("SC-Q2", "S170", "This endpoint can be used both when signing an OpenBao-backed intermediate or when signing an externally-owned intermediate."),
    ("SC-Q3", "S170", "This is a privileged endpoint, as callers are granted a new intermediate certificate, with which they can issue for arbitrary names."),
    ("SC-Q4", "S170", "This endpoint allows an operator to revoke an issuer certificate, marking it unable to issue new certificates and adding it to other issuers' CRLs"),
    ("SC-Q5", "S173", "When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL."),
    ("SC-Q6", "S170", "Note: it is encouraged to use the automatic tidy capabilities to ensure this gets run periodically."),
    ("SC-Q7", "S170", "This endpoint retrieves an OCSP response (revocation status) for a given serial number."),
    ("SC-Q8", "S170", "This endpoint forces a rotation of all issuers' delta CRLs, when enabled."),
    ("SC-Q9", "S170", "Using ACME with a role requires no_store=false to be set on the role"),
    ("SC-Q10", "S170", "to be specified by mount tuning"),
    ("SC-Q11", "S170", "All validation is taken on by the CEL prgraom created by the operator; limited to no validation is performed by OpenBao"),
    ("SC-Q12", "S170", "This endpoint revokes a certificate using its private key as proof that the request is authorized by an appropriate individual"),
    ("SC-Q13", "S170", "the only restriction is that this endpoint will refuse to issue an intermediate CA certificate"),
    ("SC-Q14", "S170", "Specifies the default extended key usage constraint on the issued certificate."),
    ("SC-Q15", "S173", "ACME by default has no external authorization engine and is unauthenticated from an OpenBao perspective"),
    ("SC-Q16", "S173", "permitted_dns_domains parameter to set the Name Constraints extension"),
    ("SC-Q17", "S170", "This endpoint allows tidying up the storage backend and/or CRL by removing certificates that have expired and are past a certain buffer period"),
    ("SC-Q18", "S173", "it is strongly recommended that operators limit a mount to a single issuer"),
    ("SC-Q19", "S170", "Only a single serial number within the request will appear in the response"),
    ("SC-Q20", "S170", "OpenBao allows a single PKI mount to have multiple Certificate"),
    ("SC-Q21", "S170", "This endpoint allows generating a CRL based on the provided parameter data from any external source and signed by the specified issuer."),
    ("SC-Q22", "S173", "up to date and maintained correctly, always pointing to the node's cluster address"),
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
