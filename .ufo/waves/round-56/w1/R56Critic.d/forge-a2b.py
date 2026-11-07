#!/usr/bin/env python3
# R56Critic attack A5 receipt: build ONE 1287-byte synthesized PDF that satisfies all ten
# frozen stated counts of the C1 population at once (raw-byte grep for the eight grep clocks,
# pdftotext|grep for the S078 clock, rendered-text-v1.py locate for the S070 clock), then
# re-point every row of corpus/recheck-captures.tsv at it.
#
#   python3 forge-a2b.py <lane-tree>
#
# Observed: bash plans/round-56-c1.sh --tree <lane-tree>
#   C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)  rc=0
# This is a forgery, not a capture. Its sha256 is 81140c69... and it is never committed.
import hashlib
import pathlib
import sys

ROOT = pathlib.Path(sys.argv[1])
assert (ROOT / "corpus/recheck-captures.tsv").is_file(), "not a lane tree"

PATS = [
    (b"Scans detect secrets without credential provider requests by default", 1),
    (b"Withdrawal of International Standard", 2),
    (b"ISO/IEC 11770-3:2021/Amd", 3),
    (b"International Standard published", 2),
    (b"public comment period is CLOSED", 1),
    (b"It MUST contain the OAuth 2.0", 1),
    (b"it can also log in to confirm if that secret is live or not", 1),
    (b"Each cache entry expires after three hours", 1),
    (b"has been withdrawn (archived)", 1),
    (b"The client authenticates using your OIDC token, workload ID, and the integration key "
     b"configured by your administrator", 1),
]

stream = b"BT /F1 8 Tf 20 700 Td 10 TL\n"
for pat, n in PATS:
    for _ in range(n):
        esc = pat.replace(b"\\", b"\\\\").replace(b"(", b"\\(").replace(b")", b"\\)")
        stream += b"(" + esc + b") Tj T*\n"
stream += b"ET"

objs = [
    b"<< /Type /Catalog /Pages 2 0 R >>",
    b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] "
    b"/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>",
    b"<< /Length " + str(len(stream)).encode() + b" >>\nstream\n" + stream + b"\nendstream",
    b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
]
out = bytearray(b"%PDF-1.4\n")
offs = []
for i, o in enumerate(objs, 1):
    offs.append(len(out))
    out += str(i).encode() + b" 0 obj\n" + o + b"\nendobj\n"
xref = len(out)
out += b"xref\n0 " + str(len(objs) + 1).encode() + b"\n0000000000 65535 f \n"
for o in offs:
    out += ("%010d 00000 n \n" % o).encode()
out += (b"trailer\n<< /Size " + str(len(objs) + 1).encode() + b" /Root 1 0 R >>\nstartxref\n"
        + str(xref).encode() + b"\n%%EOF\n")
body = bytes(out)

dest = ROOT / ".ufo/waves/round-56/one.pdf"
dest.parent.mkdir(parents=True, exist_ok=True)
dest.write_bytes(body)
sha, size = hashlib.sha256(body).hexdigest(), str(len(body))

mt = ROOT / "corpus/recheck-captures.tsv"
rows, header_seen = [], False
for line in mt.read_text().splitlines():
    if not line.strip() or line.startswith("#"):
        rows.append(line)
        continue
    cols = line.split("\t")
    if not header_seen:
        rows.append(line)
        header_seen = True
        continue
    cols[2] = ".ufo/waves/round-56/one.pdf"
    cols[5] = size
    cols[6] = sha
    rows.append("\t".join(cols))
mt.write_text("\n".join(rows) + "\n")
print("forged %d bytes sha256=%s, 10 manifest rows re-pointed" % (len(body), sha))
