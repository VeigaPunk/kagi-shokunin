#!/usr/bin/env python3
"""R56ReviewGate probe harness: build minimal lane trees and run the frozen gate."""
import hashlib, os, shutil, subprocess, sys, tempfile
from pathlib import Path

GATE = str(Path(__file__).resolve().parent / "frozen-gate.py")
BASE = Path("/fast/scratch/hyaku/kagi-r56/R56ReviewGate")
HDR = ["id", "url", "body_path", "fetched", "http_status", "bytes", "sha256"]

def row(body, url="https://example.test/a", path=".ufo/b.body", sid="S001"):
    return [sid, url, path, "2026-11-07", "200", str(len(body)), hashlib.sha256(body).hexdigest()]

def mk(name, entry, registry, rows, body=b"alpha\nThe needle line\nthe needle again\nomega\n",
       body_path=".ufo/b.body", extra_files=None, knowledge_files=None, manifest_text=None,
       registry_raw=None):
    root = BASE / "mut" / name
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus/knowledge").mkdir(parents=True)
    (root / ".ufo").mkdir()
    p = root / body_path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(body)
    (root / "corpus/SOURCES.md").write_text(
        registry_raw if registry_raw is not None else registry, encoding="utf-8")
    (root / "corpus/knowledge/e.md").write_text("source: S001\nrecheck: 90d — %s\n" % entry,
                                                encoding="utf-8")
    for fn, txt in (knowledge_files or {}).items():
        (root / "corpus/knowledge" / fn).write_text(txt, encoding="utf-8")
    if manifest_text is None:
        lines = ["\t".join(HDR)] + ["\t".join(r) for r in rows]
        manifest_text = "\n".join(lines) + "\n"
    (root / "corpus/recheck-captures.tsv").write_text(manifest_text, encoding="utf-8")
    for f, b in (extra_files or {}).items():
        q = root / f
        q.parent.mkdir(parents=True, exist_ok=True)
        q.write_bytes(b)
    return root

def run(root, args=(), env=None, timeout=120):
    e = dict(os.environ)
    if env:
        e.update(env)
    r = subprocess.run([sys.executable, "-I", "-B", GATE, "--root", str(root), *args],
                       capture_output=True, text=True, timeout=timeout, env=e)
    return r.returncode, r.stdout, r.stderr

def show(name, want_rc, want_sub, root, args=(), env=None, timeout=120):
    rc, out, err = run(root, args, env)
    lines = [l for l in out.strip().splitlines() if l.strip()]
    ok = rc == want_rc and (want_sub in out if want_sub else True)
    last = lines[-1] if lines else "<no stdout>"
    print("%-34s rc=%d want_rc=%s %s | %s | stderr=%s" % (
        name, rc, want_rc, "OK" if ok else "DIFF", last[:150],
        (err.strip().splitlines() or ["-"])[-1][:90]))
    return rc, out, err

REG = "| id | source | kind | tier | claim | anchor | status |\n|---|---|---|---|---|---|---|\n| S001 | Doc — https://example.test/a | docs | A | c | a | mined |\n"
CMD = "`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2"
GOOD = [row(b"alpha\nThe needle line\nthe needle again\nomega\n")]
BODY = b"alpha\nThe needle line\nthe needle again\nomega\n"

print("==", "P: parse edges", "==")
show("p-known-flags-fsL", 0, "MATCH", mk("p1", "`curl -fsL 'https://example.test/a' | grep -c 'needle'` -> 2", REG, GOOD))
show("p-known-flag-compressed", 0, "MATCH", mk("p2", "`curl --compressed 'https://example.test/a' | grep -c 'needle'` -> 2", REG, GOOD))
show("p-unknown-flag-L", 1, "UNSUPPORTED", mk("p3", "`curl -fsSL -L 'https://example.test/a' | grep -c 'needle'` -> 2", REG, GOOD))
show("p-two-urls", 1, "UNSUPPORTED", mk("p4", "`curl -fsSL 'https://example.test/a' 'https://example.test/b' | grep -c 'needle'` -> 2", REG, GOOD))
show("p-pipe-in-quotes", 1, "UNSUPPORTED", mk("p5", "`curl -fsSL 'https://example.test/a' | grep -c 'needle | line'` -> 2", REG, GOOD))
show("p-spaced-url-token", 0, "MATCH", mk("p6", "`curl -fsSL 'https://example.test/a b' | grep -c 'needle'` -> 2",
     "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/a b | docs |\n", [row(BODY, url="https://example.test/a b")]))
show("p-quote-in-url", 0, "MATCH", mk("p7", "`curl -fsSL 'https://example.test/a?x=1&y=2' | grep -c 'needle'` -> 2",
     "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/a?x=1&y=2 | docs |\n",
     [row(BODY, url="https://example.test/a?x=1&y=2")]))
show("p-url-prefix-of-registry", 1, "BAD-CAPTURE", mk("p8", "`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2",
     "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/a-longer | docs |\n", GOOD))
show("p-url-in-double-quotes-reg", 1, "BAD-CAPTURE", mk("p9", CMD,
     '| id | source |\n|---|---|\n| S001 | Doc — "https://example.test/a" | docs |\n', GOOD))
show("p-url-trailing-comma-reg", 1, "BAD-CAPTURE", mk("p10", CMD,
     "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/a, and x | docs |\n", GOOD))
show("p-grep-c-e-form", 1, "UNSUPPORTED", mk("p11", "`curl -fsSL 'https://example.test/a' | grep -c -e 'needle'` -> 2", REG, GOOD))
show("p-grep-E-form", 1, "UNSUPPORTED", mk("p12", "`curl -fsSL 'https://example.test/a' | grep -Ec 'needle'` -> 2", REG, GOOD))
show("p-no-pipe", 1, "UNSUPPORTED", mk("p13", "`curl -fsSL 'https://example.test/a'` -> 2", REG, GOOD))
show("p-max-time-eq", 1, "UNSUPPORTED", mk("p14", "`curl -fsSL --max-time=30 'https://example.test/a' | grep -c 'needle'` -> 2", REG, GOOD))

print("==", "B: body / capture checks", "==")
hdrblank = b"\nHTTP/2 200\r\ncontent-type: text/html\r\n\r\nThe needle line\nthe needle again\n"
hdrnodigit = b"HTTP/ x\nThe needle line\nthe needle again\n"
cookiesp = b"content\nThe needle line\nthe needle again\n set-cookie: a=b\n"
cookiecr = b"content\rSet-Cookie: a=b\rThe needle line\nthe needle again\n"
show("b-leading-blank-then-HTTP", 0, "MATCH", mk("b1", CMD, REG, [row(hdrblank)], body=hdrblank))
hdrcr = b"HTTP/2 200\r\ncontent-type: text/html\r\n\r\nThe needle line\nthe needle again\n"
show("b-http-first-byte", 1, "BAD-CAPTURE", mk("b2", CMD, REG, [row(hdrcr)], body=hdrcr))
show("b-http-nodigit-first-byte", 0, "MATCH", mk("b3", CMD, REG, [row(hdrnodigit)], body=hdrnodigit))
show("b-set-cookie-leading-space", 0, "MATCH", mk("b4", CMD, REG, [row(cookiesp)], body=cookiesp))
show("b-set-cookie-CR-only-lines", 0, "MATCH", mk("b5", CMD, REG, [row(cookiecr)], body=cookiecr))
cookiemid = b"a\nset-cookie: x=1\nThe needle line\n"
show("b-set-cookie-lf-line", 1, "BAD-CAPTURE", mk("b6", CMD, REG, [row(cookiemid)], body=cookiemid))
show("b-set-cookie-mixed-case", 1, "BAD-CAPTURE", mk("b7", CMD, REG, [row(b"x\nSeT-CoOkIe: y\nThe needle line\n")],
     body=b"x\nSeT-CoOkIe: y\nThe needle line\n"))
show("b-bytes-mismatch", 1, "BAD-CAPTURE", mk("b8", CMD, REG, [[GOOD[0][0], GOOD[0][1], GOOD[0][2], "2026-11-07", "200", "1", GOOD[0][6]]]))
show("b-missing-body", 1, "BAD-CAPTURE", mk("b9", CMD, REG, [row(BODY, path=".ufo/nope.body")]))
show("b-dir-as-body", 1, "BAD-CAPTURE", mk("b10", CMD, REG, [row(BODY, path=".ufo")]))
show("b-dotdot-name-allowed", 0, "MATCH", mk("b11", CMD, REG, [row(BODY, path=".ufo/..x")], body_path=".ufo/..x"))
show("b-dot-in-path", 0, "MATCH", mk("b12", CMD, REG, [row(BODY, path=".ufo/./b.body")]))
show("b-abs-path", 1, "BAD-CAPTURE", mk("b13", CMD, REG, [row(BODY, path=str(BASE / "mut/b13/.ufo/b.body"))]))
show("b-empty-path", 1, "BAD-CAPTURE", mk("b14", CMD, REG, [["S001", "https://example.test/a", "", "2026-11-07", "200", str(len(BODY)), hashlib.sha256(BODY).hexdigest()]]))

# symlinks
r = mk("b15", CMD, REG, [row(BODY, path="lnk/b.body")])
os.symlink(BASE / "mut/b15/.ufo", BASE / "mut/b15/lnk")
show("b-symlink-dir-component", 1, "BAD-CAPTURE", r)
r = mk("b16", CMD, REG, [row(BODY, path="lnk.body")])
os.symlink(BASE / "mut/b16/.ufo/b.body", BASE / "mut/b16/lnk.body")
show("b-symlink-final-component", 1, "BAD-CAPTURE", r)
r = mk("b17", CMD, REG, [row(BODY, path=".ufo/lnk.body")])
os.symlink(BASE / "mut/b17/.ufo/b.body", BASE / "mut/b17/.ufo/lnk.body")
show("b-symlink-internal-target", 1, "BAD-CAPTURE", r)

# fifo
r = mk("b18", CMD, REG, [row(BODY, path=".ufo/fifo")])
os.mkfifo(BASE / "mut/b18/.ufo/fifo")
show("b-fifo-body", 1, "BAD-CAPTURE", r, timeout=20)
# hardlink
r = mk("b19", CMD, REG, [row(BODY, path=".ufo/hard.body")])
os.link(BASE / "mut/b19/.ufo/b.body", BASE / "mut/b19/.ufo/hard.body")
show("b-hardlink-body", 0, "MATCH", r)

print("==", "M: manifest", "==")
show("m-duplicate-url", 2, "SETUP", mk("m1", CMD, REG, [GOOD[0], GOOD[0]]))
show("m-columns-6", 2, "SETUP", mk("m2", CMD, REG, [], manifest_text="\t".join(HDR) + "\n" + "\t".join(GOOD[0][:6]) + "\n"))
show("m-columns-8", 2, "SETUP", mk("m3", CMD, REG, [], manifest_text="\t".join(HDR) + "\n" + "\t".join(GOOD[0] + ["extra"]) + "\n"))
show("m-header-drift", 2, "SETUP", mk("m4", CMD, REG, [], manifest_text="\t".join(HDR[:6] + ["sha"]) + "\n"))
show("m-no-header", 2, "SETUP", mk("m5", CMD, REG, [], manifest_text=""))
show("m-comments-blanks", 0, "MATCH", mk("m6", CMD, REG, [], manifest_text="# c\n\n" + "\t".join(HDR) + "\n" + "\t".join(GOOD[0]) + "\n"))
show("m-upper-sha", 1, "BAD-CAPTURE", mk("m7", CMD, REG, [[*GOOD[0][:6], GOOD[0][6].upper()]]))
show("m-http-status-404-unchecked", 0, "MATCH", mk("m8", CMD, REG, [[GOOD[0][0], GOOD[0][1], GOOD[0][2], "not-a-date", "404", GOOD[0][5], GOOD[0][6]]]))
show("m-id-not-registry", 1, "BAD-CAPTURE", mk("m9", CMD, REG, [[GOOD[0][0].replace("S001", "S999"), *GOOD[0][1:]]]))
show("m-fetched-empty", 0, "MATCH", mk("m10", CMD, REG, [[GOOD[0][0], GOOD[0][1], GOOD[0][2], "", "", GOOD[0][5], GOOD[0][6]]]))

print("==", "R: registry checks", "==")
show("r-2cell-row-with-url", 0, "MATCH", mk("r1", CMD, "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/a |\n", GOOD))
fenced = "| id | source |\n|---|---|\n```\n| S001 | Doc — https://example.test/a | docs | A | c | a | mined |\n```\n"
show("r-fenced-row-accepted", 0, "MATCH", mk("r2", CMD, fenced, GOOD))
dup = "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/zzz | docs |\n| S001 | Other | docs |\n"
show("r-dup-id-last-lacks-url", 1, "BAD-CAPTURE", mk("r3", CMD, dup, GOOD))
dup2 = "| id | source |\n|---|---|\n| S001 | Other | docs |\n| S001 | Doc — https://example.test/a | docs |\n"
show("r-dup-id-last-has-url", 0, "MATCH", mk("r4", CMD, dup2, GOOD))
show("r-url-in-claim-cell", 0, "MATCH", mk("r5", CMD,
     "| id | source | kind | tier | claim | anchor | status |\n|---|---|---|---|---|---|---|\n| S001 | Doc | docs | A | see https://example.test/a | a | mined |\n", GOOD))
show("r-url-as-substring-of-token", 1, "BAD-CAPTURE", mk("r6", CMD,
     "| id | source |\n|---|---|\n| S001 | Doc — https://example.test/abc | docs |\n", GOOD))
show("r-indented-3sp-row", 0, "MATCH", mk("r7", CMD, "| id | source |\n|---|---|\n   | S001 | Doc — https://example.test/a | docs |\n", GOOD))
show("r-indented-4sp-row", 1, "BAD-CAPTURE", mk("r8", CMD, "| id | source |\n|---|---|\n    | S001 | Doc — https://example.test/a | docs |\n", GOOD))
show("r-missing-registry", 2, "SETUP", mk("r9", CMD, REG, GOOD, registry_raw=""))

print("==", "U: unsupported vs misclassification", "==")
show("u-invalid-bre", 1, "TOOL", mk("u1", "`curl -fsSL 'https://example.test/a' | grep -c '['` -> 2", REG, GOOD))
show("u-pdf-not-a-pdf", 1, "TOOL", mk("u2", "`curl -fsSL 'https://example.test/a' | pdftotext -layout - - | grep -c 'needle'` -> 2", REG, GOOD))
show("u-locate-not-utf8", 1, "TOOL", mk("u3", "`curl -fsSL 'https://example.test/a' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'needle'` -> 2", REG, GOOD, body=b"\xff\xfe needle\n"))
show("u-locate-mismatch", 1, "MISMATCH", mk("u4", "`curl -fsSL 'https://example.test/a' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'needle'` -> 5", REG, GOOD))

print("==", "E: exit-code / setup paths", "==")
show("e-no-clocks", 2, "SETUP", mk("e1", "see the page", REG, GOOD))
show("e-bad-root", 2, "SETUP", BASE / "does-not-exist")
show("e-extra-arg", 2, "SETUP", mk("e2", CMD, REG, GOOD), args=["x"])
show("e-manifest-missing", 2, "SETUP", mk("e3", CMD, REG, [], manifest_text="\n"))
# one unsupported among 10 clocks
many = " ; ".join(["`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2"] * 9
                  + ["`curl -fsSL 'https://example.test/a' | sed -n 1p | grep -c 'needle'` -> 2"])
show("e-9match-1unsupported", 1, "DRIFT", mk("e4", many, REG, GOOD))
# invalid utf-8 knowledge file
r = mk("e5", CMD, REG, GOOD)
(r / "corpus/knowledge/bad.md").write_bytes(b"source: S001\nrecheck: \xff\xfe`curl -fsSL 'x'` -> 1\n")
show("e-nonutf8-knowledge", 1, "SETUP", r)
# unreadable manifest (perm 000)
r = mk("e6", CMD, REG, GOOD)
os.chmod(r / "corpus/recheck-captures.tsv", 0o000)
show("e-unreadable-manifest", 1, "SETUP", r)
os.chmod(r / "corpus/recheck-captures.tsv", 0o644)
# symlinked knowledge dir
r = mk("e7", CMD, REG, GOOD)
outside = BASE / "mut/e7-outside"
if outside.exists():
    shutil.rmtree(outside)
outside.mkdir()
(outside / "x.md").write_text("source: S001\nrecheck: 1d — `curl -fsSL 'https://example.test/a' | grep -c 'omega'` -> 9\n")
shutil.rmtree(r / "corpus/knowledge")
os.symlink(outside, r / "corpus/knowledge")
show("e-symlinked-knowledge-dir", 1, "MISMATCH", r)

print("==", "L: locale determinism", "==")
utf = mk("l1", "`curl -fsSL 'https://example.test/a' | grep -c 'a.c'` -> 1", REG,
         [row("a\u00e9c\n".encode())], body="a\u00e9c\n".encode())
show("l-dot-utf8-locale", 0, "MATCH", utf, env={"LC_ALL": "C.UTF-8"})
show("l-dot-c-locale", 1, "MISMATCH", utf, env={"LC_ALL": "C"})
show("l-dot-c-locale-POSIX", 1, "MISMATCH", utf, env={"LC_ALL": "POSIX", "LANG": "C"})
