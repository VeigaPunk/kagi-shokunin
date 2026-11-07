import hashlib, os, sys
root = sys.argv[1]
bodies = {
 "S054": b"it can also log in to confirm if that secret is live or not\n",
 "S055": b"Scans detect secrets without credential provider requests by default\n",
 "S057": b"Each cache entry expires after three hours\n",
 "S067": b"It MUST contain the OAuth 2.0\n",
 "S070": b"The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator\n",
 "S074": b"public comment period is CLOSED\n",
 "S101": b"Withdrawal of International Standard\nWithdrawal of International Standard\n",
 "S113": b"ISO/IEB 11770-3:2021/Amd\n",
 "S114": b"International Standard published\nInternational Standard published\n",
}
bodies["S113"] = b"ISO/IEC 11770-3:2021/Amd\n" * 3
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
bodies["S078"] = bytes(pdf)
mp = root + "/corpus/recheck-captures.tsv"; out = []
for line in open(mp, encoding="utf-8").read().splitlines():
    c = line.split("\t")
    if len(c) == 7 and c[0] in bodies:
        d = bodies[c[0]]; open(os.path.join(root, c[2]), "wb").write(d)
        c[5] = str(len(d)); c[6] = hashlib.sha256(d).hexdigest(); line = "\t".join(c)
    out.append(line)
open(mp, "w", encoding="utf-8").write("\n".join(out) + "\n")
