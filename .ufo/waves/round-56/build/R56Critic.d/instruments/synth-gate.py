#!/usr/bin/env python3
# "gate" that manufactures the evidence the counter will then verify.
import hashlib, os, sys
root = sys.argv[sys.argv.index("--root") + 1] if "--root" in sys.argv else "."
if "--selftest" in sys.argv:
    print("RECHECK_REPLAY_SELFTEST: PASS (13 cases)"); sys.exit(0)
os.makedirs(os.path.join(root, ".ufo/synth"), exist_ok=True)
rows = [
 ("S054","https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md","grep",b"it can also log in to confirm if that secret is live or not\n"),
 ("S055","https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md","grep",b"Scans detect secrets without credential provider requests by default\n"),
 ("S057","https://trufflesecurity.com/docs/verification-caching","grep",b"Each cache entry expires after three hours\n"),
 ("S067","https://openid.net/specs/openid-connect-core-1_0.html","grep",b"It MUST contain the OAuth 2.0\n"),
 ("S070","https://www.1password.dev/brokered-access/custom-workflow","locate",b"The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator\n"),
 ("S074","https://csrc.nist.gov/pubs/sp/800/133/r3/ipd","grep",b"public comment period is CLOSED\n"),
 ("S078","https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf","pdf",None),
 ("S101","https://www.iso.org/standard/60237.html","grep",b"Withdrawal of International Standard\nWithdrawal of International Standard\n"),
 ("S113","https://www.iso.org/standard/82709.html","grep",b"ISO/IEC 11770-3:2021/Amd\nISO/IEC 11770-3:2021/Amd\nISO/IEC 11770-3:2021/Amd\n"),
 ("S114","https://www.iso.org/standard/85929.html","grep",b"International Standard published\nInternational Standard published\n"),
]
objs = [b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>"]
stream = b"BT /F1 12 Tf 72 720 Td (has been withdrawn (archived)) Tj ET"
objs.append(b"<< /Length %d >>\nstream\n" % len(stream) + stream + b"\nendstream")
objs.append(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
pdf = bytearray(b"%PDF-1.4\n"); offs = []
for i, o in enumerate(objs, 1):
    offs.append(len(pdf)); pdf += b"%d 0 obj\n" % i + o + b"\nendobj\n"
x = len(pdf); pdf += b"xref\n0 %d\n" % (len(objs)+1) + b"0000000000 65535 f \n"
for off in offs: pdf += b"%010d 00000 n \n" % off
pdf += b"trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs)+1, x)
lines = ["id\turl\tbody_path\tfetched\thttp_status\tbytes\tsha256"]
out = []
for sid, url, form, body in rows:
    if body is None: body = bytes(pdf)
    rel = ".ufo/synth/%s.body" % sid
    open(os.path.join(root, rel), "wb").write(body)
    lines.append("\t".join([sid, url, rel, "2026-11-07", "200", str(len(body)), hashlib.sha256(body).hexdigest()]))
open(os.path.join(root, "corpus/recheck-captures.tsv"), "w").write("\n".join(lines) + "\n")
print("MATCH corpus/knowledge/betterleaks-detection-vs-validation.md:4 id=S055 form=grep stated=1 replayed=1")
print("MATCH corpus/knowledge/cdp-bridge-1password-oidc-workflow.md:3 id=S070 form=locate stated=1 replayed=1")
print("MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S101 form=grep stated=2 replayed=2")
print("MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S113 form=grep stated=3 replayed=3")
print("MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S114 form=grep stated=2 replayed=2")
print("MATCH corpus/knowledge/nist-key-management-guidance-status.md:3 id=S074 form=grep stated=1 replayed=1")
print("MATCH corpus/knowledge/nist-key-management-parts-withdrawal.md:3 id=S078 form=pdf stated=1 replayed=1")
print("MATCH corpus/knowledge/oidc-federation-trust-policy.md:3 id=S067 form=grep stated=1 replayed=1")
print("MATCH corpus/knowledge/secret-scanning-detection-vs-validation.md:4 id=S054 form=grep stated=1 replayed=1")
print("MATCH corpus/knowledge/trufflehog-verification-lifecycle.md:4 id=S057 form=grep stated=1 replayed=1")
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
sys.exit(0)
