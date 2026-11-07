#!/usr/bin/env python3
"""recheck-replay.py -- round 56 gate: replay every stated `recheck:` clock on its committed capture.

A knowledge entry's `recheck:` line states a fetch command and the result it gave when it
was written (`... | grep -c 'Q'` -> N). Round 55 found one such statement false since round
45 (M55-2): the clock reported a change on every run, so a real change was indistinguishable
from the standing false fire. This gate replays each stated clock offline: the fetch stage is
replaced by the committed capture registered for that URL, the filter stages run unchanged,
and the result must equal the stated N.

Population: every backticked command on a column-1 `recheck:` line of corpus/knowledge/*.md
that starts with `curl` and is followed by `-> N` or `-> count=N`.

Accepted command forms (anything else is UNSUPPORTED, never guessed):
  curl <flags> '<URL>' | grep -c '<BRE>'
  curl <flags> '<URL>' | pdftotext -layout - - | grep -c '<BRE>'
  curl <flags> '<URL>' | python3 corpus/rendered-text-v1.py locate /dev/stdin '<quote>'
curl flags: -fsSL, -sSL, -fsL, --compressed, --max-time N, -A '<agent>'; exactly one URL.
grep runs as the host `grep -c -e '<BRE>'` (the statement's own semantics); pdftotext and the
lane's rendered-text-v1.py run on the capture exactly as the pipe would.

Capture manifest: corpus/recheck-captures.tsv, header
  id<TAB>url<TAB>body_path<TAB>fetched<TAB>http_status<TAB>bytes<TAB>sha256
url must equal the command's URL byte-for-byte and appear in that id's registry row in
corpus/SOURCES.md; body_path is repo-relative (no absolute path, no `..`, no symlink component)
and the body's byte count and sha256 must equal the row. Bodies only: a capture that begins
with an HTTP status line or carries a `Set-Cookie:` header line is refused (QM72).

Verdicts, one line per clock: MATCH, MISMATCH (replayed != stated), NO-CAPTURE (no manifest
row for the URL), BAD-CAPTURE (manifest row fails a check), UNSUPPORTED (form), TOOL (filter
tool missing or failed).
Exit 0 `RECHECK_REPLAY: CLEAN (...)` only when every clock is MATCH; exit 1 `RECHECK_REPLAY:
DRIFT (...)` otherwise; exit 2 `RECHECK_REPLAY: SETUP <reason>`.

Named ceilings: committed bytes only. A MATCH says the statement is true of the capture, not
that the live page still says it (the live run of the command is the freshness check), and a
hand-written capture with a consistent manifest row would MATCH; capture provenance is the
fetch receipt beside the body, re-fetched by a non-author.
"""
import hashlib
import os
import re
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

MANIFEST = "corpus/recheck-captures.tsv"
REGISTRY = "corpus/SOURCES.md"
KNOWLEDGE = "corpus/knowledge"
NORMALIZER = "corpus/rendered-text-v1.py"
HEADER = ["id", "url", "body_path", "fetched", "http_status", "bytes", "sha256"]
CLOCK_RE = re.compile(r"`(curl [^`]*)`\s*->\s*(?:count=)?(\d+)")
CURL_BOOL = {"-fsSL", "-sSL", "-fsL", "--compressed"}
CURL_ARG = {"--max-time", "-A"}
# the locate normaliser is an input the gate executes; its bytes are pinned like
# the gate's own (epoch-C, R56ReviewGate-2 F5): a stub helper cannot forge CLEAN
NORMALIZER_SHA256_PIN = "14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9"


def setup(reason):
    print("RECHECK_REPLAY: SETUP %s" % reason)
    return 2


def clocks(root):
    out = []
    kdir = root / KNOWLEDGE
    for path in sorted(kdir.glob("*.md")):
        rel = path.relative_to(root).as_posix()
        if path.is_symlink():
            # a symlinked entry is outside the replayable population by contract;
            # report it as a clock-less UNSUPPORTED row so the gate cannot go CLEAN
            out.append((rel, 0, "<symlinked-entry>", -1))
            continue
        if not path.is_file():
            # fifo/socket/device: never block on read_text; treat like an
            # unreadable entry — a clock-less UNSUPPORTED row keeps CLEAN out
            out.append((rel, 0, "<non-regular-entry>", -1))
            continue
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if not line.startswith("recheck:"):
                continue
            for m in CLOCK_RE.finditer(line):
                out.append((rel, lineno, m.group(1), int(m.group(2))))
    return out


def parse(cmd):
    """Return (url, filter) or (None, reason). filter is ('grep', bre) | ('pdf', bre) | ('locate', q)."""
    stages = [s.strip() for s in cmd.split(" | ")]
    try:
        argv = [shlex.split(s) for s in stages]
    except ValueError as exc:
        return None, "unparsable:%s" % exc
    curl = argv[0]
    if not curl or curl[0] != "curl":
        return None, "first-stage-not-curl"
    url = None
    i = 1
    while i < len(curl):
        tok = curl[i]
        if tok in CURL_BOOL:
            i += 1
        elif tok in CURL_ARG and i + 1 < len(curl):
            i += 2
        elif re.match(r"https?://", tok) and url is None:
            url = tok
            i += 1
        else:
            return None, "curl-token:%s" % tok
    if url is None:
        return None, "no-url"
    rest = argv[1:]
    if len(rest) == 1 and len(rest[0]) == 3 and rest[0][:2] == ["grep", "-c"]:
        return url, ("grep", rest[0][2])
    if (len(rest) == 2 and rest[0] == ["pdftotext", "-layout", "-", "-"]
            and len(rest[1]) == 3 and rest[1][:2] == ["grep", "-c"]):
        return url, ("pdf", rest[1][2])
    if (len(rest) == 1 and len(rest[0]) == 5
            and rest[0][:4] == ["python3", "corpus/rendered-text-v1.py", "locate", "/dev/stdin"]):
        return url, ("locate", rest[0][4])
    return None, "filter-form"


def registry_rows(root):
    rows = {}
    for line in (root / REGISTRY).read_text(encoding="utf-8").splitlines():
        m = re.match(r"^ {0,3}\|\s*(S\d{3,})\s*\|", line)
        if m:
            rows[m.group(1)] = line
    return rows


def manifest(root):
    path = root / MANIFEST
    if not path.is_file() or path.is_symlink():
        return None, "manifest-missing"
    rows = {}
    seen_path = {}
    seen_sha = {}
    header_seen = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        cols = line.split("\t")
        if not header_seen:
            if cols != HEADER:
                return None, "manifest-header"
            header_seen = True
            continue
        if len(cols) != len(HEADER):
            return None, "manifest-columns:%s" % cols[0]
        rid = dict(zip(HEADER, cols))
        if cols[1] in rows:
            return None, "manifest-duplicate-url:%s" % cols[1]
        # fetched must be an ISO date and http_status a 2xx — a capture records
        # a successful fetch, not a placeholder
        if not re.match(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$", rid["fetched"]):
            return None, "manifest-fetched:%s" % cols[0]
        if not re.match(r"^2[0-9]{2}$", rid["http_status"]):
            return None, "manifest-http:%s" % cols[0]
        # bijection: no two rows share a body_path or a sha256 — the real
        # manifest is a 10/10/10 mapping; a shared body would let one capture
        # satisfy two clocks (and a byte-identical body under a second id is
        # refused by design, named in the failure)
        for key, seen, tag in ((rid["body_path"], seen_path, "body_path"),
                               (rid["sha256"], seen_sha, "sha256")):
            if key in seen:
                return None, "manifest-shared-%s:%s+%s" % (tag, seen[key], cols[0])
            seen[key] = cols[0]
        rows[cols[1]] = rid
    if not header_seen:
        return None, "manifest-header"
    return rows, None


def capture_confined(rel):
    """body_path must live under .ufo/waves/<round>/<...>/capture*/ — a capture
    artifact, not any committed file. Component-wise so the round-45
    `controls/capture-r45/` depth and the round-55/56 `capture/` depth both fit."""
    parts = Path(rel).parts
    return (len(parts) >= 5 and parts[:2] == (".ufo", "waves")
            and any(p.startswith("capture") for p in parts[2:-1]))


def check_capture(root, row, registry):
    sid = row["id"]
    reg = registry.get(sid)
    if reg is None:
        return None, "not-a-registry-row:%s" % sid
    if not re.search(r"(?<![^\s(<])" + re.escape(row["url"]) + r"(?=[\s|>)]|$)", reg):
        return None, "url-not-in-row:%s" % sid
    rel = row["body_path"]
    if rel.startswith("/") or ".." in Path(rel).parts or not rel:
        return None, "body-path:%s" % rel
    if not capture_confined(rel):
        return None, "body-not-capture:%s" % rel
    cur = root
    for part in Path(rel).parts:
        cur = cur / part
        if cur.is_symlink():
            return None, "symlink:%s" % rel
    if not cur.is_file():
        return None, "body-missing:%s" % rel
    data = cur.read_bytes()
    if str(len(data)) != row["bytes"]:
        return None, "bytes:%s" % rel
    if hashlib.sha256(data).hexdigest() != row["sha256"]:
        return None, "sha256:%s" % rel
    # a capture is a body, never a transcript: refuse a line at column 0 that is
    # an HTTP status line or a set-cookie header, including `curl -v`/`curl -i`
    # trace prefixes (`< `). Column 0 only — spec bodies legitimately quote
    # indented HTTP examples (S067), and real transcripts never indent headers.
    if re.search(rb"(?im)^(?:HTTP/\d|< HTTP/\d|< set-cookie\s*:|set-cookie\s*:)", data):
        return None, "header-bytes:%s" % rel
    return cur, None


def replay(root, body, flt):
    kind, arg = flt
    try:
        if kind == "grep":
            res = subprocess.run(["grep", "-c", "-e", arg, str(body)], capture_output=True, timeout=60)
            if res.returncode not in (0, 1):
                return None, "grep-rc%d" % res.returncode
            return int(res.stdout.strip() or b"-1"), None
        if kind == "pdf":
            txt = subprocess.run(["pdftotext", "-layout", str(body), "-"], capture_output=True, timeout=120)
            if txt.returncode != 0:
                return None, "pdftotext-rc%d" % txt.returncode
            res = subprocess.run(["grep", "-c", "-e", arg], input=txt.stdout, capture_output=True, timeout=60)
            if res.returncode not in (0, 1):
                return None, "grep-rc%d" % res.returncode
            return int(res.stdout.strip() or b"-1"), None
        res = subprocess.run([sys.executable, "-I", "-B", str(root / NORMALIZER),
                              "locate", str(body), arg], capture_output=True, timeout=120)
        # the normaliser exits 0 on a successful locate and 1 for count=0; any
        # other rc means the producer failed, not that the count is zero
        if res.returncode not in (0, 1):
            return None, "locate-rc%d" % res.returncode
        m = re.search(rb"RENDERED_TEXT_V1_LOCATE: count=(\d+)", res.stdout)
        if not m:
            return None, "locate-output"
        return int(m.group(1)), None
    except FileNotFoundError as exc:
        return None, "tool-missing:%s" % exc.filename
    except subprocess.TimeoutExpired:
        return None, "tool-timeout"


def confined(root, rel):
    """True iff every component of root/rel (including rel itself when it names a
    directory or file) is free of symlinks — same rule check_capture applies to
    body_path, extended to every input the gate reads."""
    cur = root
    for part in Path(rel).parts:
        cur = cur / part
        if cur.is_symlink():
            return False
    return True


def run(root):
    inputs = [KNOWLEDGE, REGISTRY, MANIFEST, NORMALIZER]
    for rel in inputs:
        if not confined(root, rel):
            return setup("symlinked-input:%s" % rel)
    if not (root / KNOWLEDGE).is_dir() or not (root / REGISTRY).is_file():
        return setup("not-a-lane-tree:%s" % root)
    norm_path = root / NORMALIZER
    if not norm_path.is_file():
        return setup("normalizer-missing")
    if hashlib.sha256(norm_path.read_bytes()).hexdigest() != NORMALIZER_SHA256_PIN:
        return setup("normalizer-digest")
    found = clocks(root)
    if not found:
        return setup("no-stated-clocks")
    rows, err = manifest(root)
    if err:
        return setup(err)
    registry = registry_rows(root)
    tally = {"MATCH": 0, "MISMATCH": 0, "NO-CAPTURE": 0, "BAD-CAPTURE": 0, "UNSUPPORTED": 0, "TOOL": 0}
    for rel, lineno, cmd, stated in found:
        where = "%s:%d" % (rel, lineno)
        if cmd in ("<symlinked-entry>", "<non-regular-entry>"):
            tally["UNSUPPORTED"] += 1
            print("UNSUPPORTED %s reason=%s" % (where, cmd[1:-1]))
            continue
        url, flt = parse(cmd)
        if url is None:
            tally["UNSUPPORTED"] += 1
            print("UNSUPPORTED %s reason=%s" % (where, flt))
            continue
        row = rows.get(url)
        if row is None:
            tally["NO-CAPTURE"] += 1
            print("NO-CAPTURE %s url=%s" % (where, url))
            continue
        body, why = check_capture(root, row, registry)
        if body is None:
            tally["BAD-CAPTURE"] += 1
            print("BAD-CAPTURE %s id=%s reason=%s" % (where, row["id"], why))
            continue
        got, why = replay(root, body, flt)
        if got is None:
            tally["TOOL"] += 1
            print("TOOL %s id=%s reason=%s" % (where, row["id"], why))
            continue
        verdict = "MATCH" if got == stated else "MISMATCH"
        tally[verdict] += 1
        print("%s %s id=%s form=%s stated=%d replayed=%d" % (verdict, where, row["id"], flt[0], stated, got))
    total = len(found)
    summary = "clocks=%d match=%d mismatch=%d no_capture=%d bad_capture=%d unsupported=%d tool=%d" % (
        total, tally["MATCH"], tally["MISMATCH"], tally["NO-CAPTURE"], tally["BAD-CAPTURE"],
        tally["UNSUPPORTED"], tally["TOOL"])
    if tally["MATCH"] == total:
        print("RECHECK_REPLAY: CLEAN (%s)" % summary)
        return 0
    print("RECHECK_REPLAY: DRIFT (%s)" % summary)
    return 1


def selftest():
    cases = []
    body_txt = b"alpha\nThe needle line\nthe needle again\nomega\n"

    CAPDIR = ".ufo/waves/r/capture"
    # the fixture tree must carry the pinned normalizer bytes — copy them from
    # this gate's own repo (the file the pin names)
    norm_bytes = (Path(__file__).resolve().parent.parent / NORMALIZER).read_bytes()

    def tree(tmp, entry_line, manifest_rows, body=body_txt, url="https://example.test/a", row_url=None):
        root = Path(tmp)
        (root / KNOWLEDGE).mkdir(parents=True)
        (root / "corpus").mkdir(parents=True, exist_ok=True)
        (root / NORMALIZER).write_bytes(norm_bytes)
        (root / ".ufo/waves/r/capture").mkdir(parents=True)
        (root / (CAPDIR + "/b.body")).write_bytes(body)
        ru = row_url or url
        (root / REGISTRY).write_text("| id | source |\n|---|---|\n| S001 | Doc — %s | docs |\n" % ru, encoding="utf-8")
        (root / KNOWLEDGE / "e.md").write_text("source: S001\nrecheck: 90d — %s\n" % entry_line, encoding="utf-8")
        lines = ["\t".join(HEADER)]
        for r in manifest_rows:
            lines.append("\t".join(r))
        (root / MANIFEST).write_text("\n".join(lines) + "\n", encoding="utf-8")
        return root

    def good_row(body=body_txt, url="https://example.test/a", path=CAPDIR + "/b.body"):
        return ["S001", url, path, "2026-11-07", "200", str(len(body)), hashlib.sha256(body).hexdigest()]

    cmd = "`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2"
    cases.append(("match", cmd, [good_row()], {}, 0, "MATCH"))
    cases.append(("stale-expectation", cmd.replace("-> 2", "-> 1"), [good_row()], {}, 1, "MISMATCH"))
    cases.append(("count-form", cmd.replace("-> 2", "-> count=2"), [good_row()], {}, 0, "MATCH"))
    cases.append(("bre-not-substring", "`curl -fsSL 'https://example.test/a' | grep -c 'need.e'` -> 2",
                  [good_row()], {}, 0, "MATCH"))
    cases.append(("no-capture", cmd, [], {}, 1, "NO-CAPTURE"))
    tampered = good_row()
    tampered[6] = "0" * 64
    cases.append(("sha-mismatch", cmd, [tampered], {}, 1, "BAD-CAPTURE"))
    cases.append(("url-not-in-row", cmd, [good_row()], {"row_url": "https://example.test/other"}, 1, "BAD-CAPTURE"))
    cases.append(("escape-path", cmd, [good_row(path="../b.body")], {}, 1, "BAD-CAPTURE"))
    cases.append(("not-capture-path", cmd, [good_row(path=".ufo/b.body")], {}, 1, "BAD-CAPTURE"))
    hdr = b"HTTP/2 200\r\nset-cookie: x=1\r\n\r\nThe needle line\nthe needle again\n"
    cases.append(("header-bytes", cmd, [good_row(body=hdr)], {"body": hdr}, 1, "BAD-CAPTURE"))
    # curl -v transcript shape: status and set-cookie lines at a NON-ZERO
    # offset with `< ` trace prefixes — must be refused like offset-0 headers
    trc = b"noise preamble\n< HTTP/1.1 200 OK\n< set-cookie: x=1\n\nThe needle line\nthe needle again\n"
    cases.append(("trace-headers", cmd, [good_row(body=trc)], {"body": trc}, 1, "BAD-CAPTURE"))
    # locate form (epoch-C, R56ReviewGate-2 F1): the normaliser is pinned, and
    # both a match and a mismatch must round-trip through the real helper
    lcmd = "`curl -fsSL 'https://example.test/a' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'needle'` -> 2"
    cases.append(("locate-match", lcmd, [good_row()], {}, 0, "MATCH"))
    cases.append(("locate-mismatch", lcmd.replace("-> 2", "-> 3"), [good_row()], {}, 1, "MISMATCH"))
    # pdf form: a minimal valid PDF whose text layer carries the needle once
    mini_pdf = (b'%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n'
                b'2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n'
                b'3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>\nendobj\n'
                b'4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n'
                b'5 0 obj\n<< /Length 51 >>\nstream\nBT /F1 12 Tf 72 720 Td (needle needle needle) Tj ET\nendstream\nendobj\n'
                b'xref\n0 6\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \n0000000241 00000 n \n0000000311 00000 n \n'
                b'trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n412\n%%EOF\n')
    pcmd = "`curl -fsSL 'https://example.test/a' | pdftotext -layout - - | grep -c 'needle'` -> 1"
    cases.append(("pdf-match", pcmd, [good_row(body=mini_pdf)], {"body": mini_pdf}, 0, "MATCH"))
    # canonical header spellings are case-insensitive (epoch-D, R56MutCounter F9):
    # `Set-Cookie:` and `Http/2` at column 0 must be refused like lowercase
    cap1 = b"Set-Cookie: x=1\n\nThe needle line\nthe needle again\n"
    cases.append(("header-case-cookie", cmd, [good_row(body=cap1)], {"body": cap1}, 1, "BAD-CAPTURE"))
    cap2 = b"Http/2 302 Found\n\nThe needle line\nthe needle again\n"
    cases.append(("header-case-status", cmd, [good_row(body=cap2)], {"body": cap2}, 1, "BAD-CAPTURE"))
    cases.append(("unsupported-form", "`curl -fsSL 'https://example.test/a' | sed -n 1p | grep -c 'needle'` -> 2",
                  [good_row()], {}, 1, "UNSUPPORTED"))
    cases.append(("extra-curl-flag", "`curl -fsSL -o /tmp/x 'https://example.test/a' | grep -c 'needle'` -> 2",
                  [good_row()], {}, 1, "UNSUPPORTED"))
    cases.append(("second-clock-mismatch", cmd + "; `curl -fsSL 'https://example.test/a' | grep -c 'omega'` -> 3",
                  [good_row()], {}, 1, "MISMATCH"))
    failed = 0
    for name, line, mrows, kw, want_rc, want_tok in cases:
        with tempfile.TemporaryDirectory(prefix="recheck-replay-") as tmp:
            root = tree(tmp, line, mrows, **kw)
            result = subprocess.run([sys.executable, "-I", "-B", str(Path(__file__).resolve()),
                                     "--root", str(root)], capture_output=True, text=True, timeout=180)
            rc, out = result.returncode, result.stdout
            ok = rc == want_rc and want_tok in out
            if not ok:
                failed += 1
            print("%s %s rc=%d want=%d token=%s" % ("PASS" if ok else "FAIL", name, rc, want_rc, want_tok))
    # symlinked capture component (path stays capture-confined so the symlink
    # check, not the confinement check, is what fires)
    with tempfile.TemporaryDirectory(prefix="recheck-replay-") as tmp:
        root = tree(tmp, cmd, [good_row(path=".ufo/waves/r/capture-link/b.body")])
        os.symlink("capture", root / ".ufo/waves/r/capture-link")
        result = subprocess.run([sys.executable, "-I", "-B", str(Path(__file__).resolve()),
                                 "--root", str(root)], capture_output=True, text=True, timeout=180)
        rc = result.returncode
        ok = rc == 1 and "symlink:" in result.stdout
        failed += 0 if ok else 1
        print("%s symlink-component rc=%d want=1 token=symlink:" % ("PASS" if ok else "FAIL", rc))
    total = len(cases) + 1
    if failed:
        print("RECHECK_REPLAY_SELFTEST: FAIL (%d of %d cases)" % (failed, total))
        return 1
    print("RECHECK_REPLAY_SELFTEST: PASS (%d cases)" % total)
    return 0


def main(argv):
    if argv[1:2] == ["--selftest"]:
        return selftest()
    root = Path(__file__).resolve().parent.parent
    if argv[1:2] == ["--root"] and len(argv) == 3:
        root = Path(argv[2]).resolve()
    elif len(argv) > 1:
        return setup("usage: recheck-replay.py [--root DIR | --selftest]")
    return run(root)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
