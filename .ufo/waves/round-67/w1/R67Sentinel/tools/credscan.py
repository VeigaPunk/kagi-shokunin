#!/usr/bin/env python3
"""Credential-shape scanner for round-67.

Prints file:line and CLASS only. Never prints the matched bytes.
Classes are regex-based; a match is a SHAPE, not a confirmed secret.
"""
import os, re, sys, json

# class -> (regex, description of shape only)
PATTERNS = [
    ("op-ref",            re.compile(r"op://[^\s\"'`)\]]+")),
    ("pem-block",         re.compile(r"-----BEGIN [A-Z ]*(PRIVATE KEY|CERTIFICATE|KEY)-----")),
    ("gh-token",          re.compile(r"\bgh[pousr]_[A-Za-z0-9]{16,}\b")),
    ("aws-access-key",    re.compile(r"\b(?:AKIA|ASIA|ABIA|ACCA)[0-9A-Z]{16}\b")),
    ("age-secret-key",    re.compile(r"AGE-SECRET-KEY-1[0-9A-Z]{20,}")),
    ("jwt",               re.compile(r"\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}")),
    ("long-hex-blob",     re.compile(r"(?<![0-9a-fA-F])[0-9a-fA-F]{40,}(?![0-9a-fA-F])")),
    ("long-b64-blob",     re.compile(r"(?<![A-Za-z0-9+/=])[A-Za-z0-9+/]{60,}={0,2}(?![A-Za-z0-9+/=])")),
    ("bearer-header",     re.compile(r"(?i)\bauthorization\s*:\s*bearer\s+\S+")),
    ("set-cookie",        re.compile(r"(?i)\bset-cookie\s*:")),
    ("private-key-openssh", re.compile(r"-----BEGIN OPENSSH PRIVATE KEY-----")),
    ("slack-token",       re.compile(r"\bxox[abprs]-[A-Za-z0-9-]{10,}")),
    ("npm-token",         re.compile(r"\bnpm_[A-Za-z0-9]{20,}")),
    ("anthropic-key",     re.compile(r"\bsk-ant-[A-Za-z0-9_-]{20,}")),
    ("generic-api-secret", re.compile(r"(?i)\b(api[_-]?key|secret[_-]?key|password|passwd|token)\s*[:=]\s*[\"']?[A-Za-z0-9/+_-]{16,}")),
]

# Known-benign long-hex shapes in this lane: sha256/sha1 digests pinned by
# receipts and registry rows. These are content digests, not credential
# material; they are reported separately as class long-hex-blob with a
# "digest-shaped" note by the caller, never suppressed silently.
def sha256_of(path):
    import hashlib
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

def scan_file(path):
    out = []
    try:
        with open(path, "rb") as f:
            data = f.read()
    except OSError as e:
        return [("unreadable", 0, str(e))]
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = data.decode("utf-8", "replace")
    for i, line in enumerate(text.splitlines(), 1):
        hex_spans = [(m.start(), m.end()) for m in
                     re.finditer(r"(?<![0-9a-fA-F])[0-9a-fA-F]{40,}(?![0-9a-fA-F])", line)]
        for cls, rx in PATTERNS:
            for m in rx.finditer(line):
                # a base64-shaped match that lies entirely inside a hex digest is
                # the same bytes as the hex class, not a second finding
                if cls == "long-b64-blob":
                    s, e = m.span()
                    if any(hs <= s and e <= he for hs, he in hex_spans):
                        continue
                    # a base64-alphabet run that is really a filesystem path
                    # (contains '/' and no '=') is not a blob
                    seg = m.group(0)
                    if "/" in seg and "=" not in seg and seg.count("/") >= 3:
                        continue
                out.append((cls, i, ""))
    return out

def main():
    roots = sys.argv[1:]
    findings = []
    scanned = 0
    for root in roots:
        if os.path.isfile(root):
            paths = [root]
        else:
            paths = []
            for dp, dn, fn in os.walk(root):
                dn[:] = [d for d in dn if d not in (".git", ".jj", "__pycache__")]
                for f in fn:
                    paths.append(os.path.join(dp, f))
        for p in sorted(paths):
            scanned += 1
            for cls, line, _ in scan_file(p):
                findings.append((p, line, cls))
    print(f"SCANNED_FILES={scanned}")
    print(f"SHAPE_MATCHES={len(findings)}")
    by_class = {}
    for p, line, cls in findings:
        by_class.setdefault(cls, 0)
        by_class[cls] += 1
    for cls in sorted(by_class):
        print(f"CLASS {cls} {by_class[cls]}")
    print("--- per-match (file:line class) ---")
    for p, line, cls in findings:
        print(f"{p}:{line} {cls}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
