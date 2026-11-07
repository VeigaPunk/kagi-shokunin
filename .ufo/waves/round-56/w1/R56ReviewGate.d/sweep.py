#!/usr/bin/env python3
"""R56ReviewGate mutation sweep against the FROZEN gate (sha256 b7782f35...).

Each mutant is built from .d/frozen-gate.py by one literal replacement (asserted to
change the file), then run: --selftest, --root <base>, and the fixture that the
mutant is supposed to break. Fixtures live in the scratch tree named in fixtures.md.
"""
import hashlib, pathlib, subprocess, sys

HERE = pathlib.Path(__file__).resolve().parent
FROZEN = (HERE / "frozen-gate.py").read_text()
SCR = pathlib.Path("/fast/scratch/hyaku/kagi-r56/R56ReviewGate")

def mut(name, old, new, count=1):
    assert old in FROZEN, name
    t = FROZEN.replace(old, new, count)
    assert t != FROZEN, name
    p = HERE / "mutants" / (name + ".py")
    p.write_text(t)
    return p

M = {}
M["A-pdf-locate-constant"] = mut("A-pdf-locate-constant", '''    kind, arg = flt
    try:''', '''    kind, arg = flt
    if kind in ("pdf", "locate"):
        return 1, None
    try:''')
M["B-drop-dup-url-guard"] = mut("B-drop-dup-url-guard", '''        if cols[1] in rows:
            return None, "manifest-duplicate-url:%s" % cols[1]
''', '')
M["C-drop-status-line-guard"] = mut("C-drop-status-line-guard",
    '''    if re.match(rb"HTTP/\\d", data) or re.search(rb"(?im)^set-cookie:", data):''',
    '''    if re.search(rb"(?im)^set-cookie:", data):''')
M["D-drop-bytes-guard"] = mut("D-drop-bytes-guard", '''    if str(len(data)) != row["bytes"]:
        return None, "bytes:%s" % rel
''', '')
M["E-follow-symlinked-entries"] = mut("E-follow-symlinked-entries", '''        if path.is_symlink():
            continue
''', '')
M["F-drop-registry-check"] = mut("F-drop-registry-check", '''    if not re.search(r"(?<![^\\s(<])" + re.escape(row["url"]) + r"(?=[\\s|>)]|$)", reg):
        return None, "url-not-in-row:%s" % sid
''', '')

FIX = {
    "A-pdf-locate-constant": ["base", "liar"],
    "B-drop-dup-url-guard": ["mut/m1"],
    "C-drop-status-line-guard": ["mut/b2"],
    "D-drop-bytes-guard": ["mut/b8"],
    "E-follow-symlinked-entries": ["symentry"],
    "F-drop-registry-check": ["mut/r1"],
}

def run(argv):
    r = subprocess.run([sys.executable, "-I", "-B"] + argv, capture_output=True, text=True, timeout=300)
    lines = [l for l in r.stdout.splitlines() if l.strip()]
    return r.returncode, (lines[-1] if lines else "<no stdout>"), r.stderr.strip().splitlines()[-1:] 

print("frozen gate sha256 =", hashlib.sha256((HERE / "frozen-gate.py").read_bytes()).hexdigest())
for name, path in M.items():
    st_rc, st_last, _ = run([str(path), "--selftest"])
    print("\n%s sha256=%s" % (name, hashlib.sha256(path.read_bytes()).hexdigest()))
    print("  selftest rc=%d last=%s" % (st_rc, st_last))
    for fx in FIX[name]:
        rc, last, err = run([str(path), "--root", str(SCR / fx)])
        print("  --root %-12s rc=%d last=%s%s" % (fx, rc, last[:150], (" stderr=" + err[0][:80]) if err else ""))
