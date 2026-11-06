#!/usr/bin/env python3
"""Round-50 C2 control fixtures: rewrite a BASE clone's claim ledger. Usage: migrate.py REPO MODE.
Reference expects are the live last lines measured at BASE 565c43a (L1 receipt c2-base-live.txt)."""
import json, os, re, sys
repo, mode = sys.argv[1:3]
CENSUS = r"^SOURCES_CENSUS: CLEAN \(rows=105 A=101 B=2 C=2 queued=1 mined=100 rejected=4 entries_sourced=15 legacy=21 captures=105 inrow=16 inrow_only=0 inrow_nonreproducing=12\)$"
REF = {
    "R13-01": r"^67$",
    "R21-02": CENSUS, "R31-02": CENSUS, "R33-02": CENSUS, "R34-03": CENSUS,
    "R22-03": r"^REVISION_AUDIT: CLEAN \(stale=0 missing=0 dropped=0 added=61 invalid=0\)$",
    "R24-05": r"^ROW_IDENTITY: stamps count=124 sha256=c7673d14599c6ebde1a5b1f608ccc541f396fe6f24d5c00fdeee3bee35c06534$",
    "R24-06": r"^ROW_IDENTITY: scorecard-rounds count=67 sha256=922413334dda7555b08b6d5905bedd855288f99e751045598a098c5dc89c511e$",
    "R24-15": r"^ROW_IDENTITY: revision-added count=61 sha256=9b7e9b8c9b4bb5526fc8093ff81679db1494083dafbcc0b6d42f65eaa8604e48$",
    "R38-01": r"^8$",
}
IDS = list(REF)
L = os.path.join(repo, "corpus/claim-ledger.tsv")
rows = open(L).read().split("\n")
def set_expect(ids, f, cmd=None):
    out, mig = [], []
    for r in rows:
        c = r.split("\t")
        if len(c) >= 6 and c[0] in ids:
            new = f(c[0])
            mig.append({"id": c[0], "command": c[1], "old_expect": c[2], "new_expect": new, "reason": "fixture"})
            c[2] = new
            if cmd and c[0] == "R13-01":
                c[1] = cmd
        out.append("\t".join(c))
    return out, mig
journal = True
if mode == "ref":
    out, mig = set_expect(IDS, REF.get)
elif mode == "wildcard":
    out, mig = set_expect(IDS, lambda i: ".*")
elif mode == "digitclass":
    out, mig = set_expect(IDS, lambda i: re.sub(r"[0-9]+", "[0-9]+", REF[i]).replace("[0-9]+[0-9a-f]", "[0-9a-f]"))
elif mode == "repoint":
    out, mig = set_expect(IDS, REF.get, cmd="echo 67")
elif mode == "nojournal":
    out, mig = set_expect(IDS, REF.get); journal = False
elif mode == "half":
    out, mig = set_expect(IDS[:5], REF.get)
elif mode == "boundary":
    out, mig = set_expect(IDS, REF.get)
    out = [r.replace("\t0\t", "\t2\t", 1) if r.startswith("R25-02\t") else r for r in out]
elif mode == "producer":
    out, mig = set_expect(IDS, REF.get)
    with open(os.path.join(repo, "corpus/row-identity.sh"), "a") as fh:
        fh.write("\n# fixture edit\n")
else:
    sys.exit("unknown mode")
open(L, "w").write("\n".join(out))
# Restamp the ledger row in corpus/stamps.tsv (the ledger is a stamped artifact: without this the
# revision audit reads DRIFT stale=1 and R22-03/R24-15 print no verdict — pre-freeze run 2, K2-P).
import hashlib
st = os.path.join(repo, "corpus/stamps.tsv")
data = open(L, "rb").read()
row = "corpus/claim-ledger.tsv\t%s\t%d\t%d" % (hashlib.sha256(data).hexdigest(), data.count(b"\n"), len(data))
lines = open(st).read().split("\n")
lines = [row if l.startswith("corpus/claim-ledger.tsv\t") else l for l in lines]
open(st, "w").write("\n".join(lines))
if journal:
    j = os.path.join(repo, ".ufo/waves/round-50/expectation-migrations.json")
    os.makedirs(os.path.dirname(j), exist_ok=True)
    json.dump({"round": 50, "migrations": mig}, open(j, "w"), indent=1)
