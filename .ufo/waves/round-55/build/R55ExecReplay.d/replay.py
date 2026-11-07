#!/usr/bin/env python3
"""replay.py — lane-wide recheck replay prototype (round 55 lesson §Routed 2, leg (b) only).

For every corpus/knowledge/*.md `recheck:` line, extracts each backticked
`curl ...` command with a stated expectation (`-> N` / `-> count=N`) and, when
the command is exactly the form  curl ... '<URL>' | grep -c '<PATTERN>',
replays `grep -c -e PATTERN` against the committed capture of the registry row
whose URL the command fetches (row found in corpus/SOURCES.md; capture path
from corpus/quote-bodies.tsv body_path).

Fails closed: every other command form (pdftotext intermediates, rendered-text
locate, parameterized URL, missing expectation), every URL without a registry
row, and every row without a committed capture is reported NOT_REPLAYABLE with
a reason and is never attempted. No network access; reads only the given tree.

Usage: python3 replay.py <lane-root>
Exit:  0 = no MISMATCH among replayed commands (NOT_REPLAYABLE entries do not
           pass, they are excluded and listed);
       1 = at least one MISMATCH;
       2 = setup error (missing lane files or not a directory).
"""
import json
import re
import subprocess
import sys
from pathlib import Path

RECHECK_LINE = re.compile(r"^recheck:")
ROW_LINE = re.compile(r"^\|\s*(S\d+)\s*\|")
FIRST_URL = re.compile(r"https?://\S+")
STATED = re.compile(r"->\s*(count=)?(\d+)")
# the only replayable form: curl ... '<URL>' | grep -c '<PATTERN>'  (nothing between URL and pipe)
GREP_C_FORM = re.compile(r"^curl\s+.*?'(https?://[^']+)'\s*\|\s*grep -c '([^']*)'\s*$")


def parse_sources(lane):
    url2id = {}
    for line in (lane / "corpus/SOURCES.md").read_text(encoding="utf-8").splitlines():
        m = ROW_LINE.match(line)
        if not m:
            continue
        u = FIRST_URL.search(line, m.end())
        if not u:
            continue
        url = u.group(0).rstrip(".,;")
        url2id[url] = m.group(1)
        url2id[url.rstrip("/")] = m.group(1)
    return url2id


def parse_quote_bodies(lane):
    id2body = {}
    for line in (lane / "corpus/quote-bodies.tsv").read_text(encoding="utf-8").splitlines():
        parts = line.split("\t")
        if len(parts) >= 2 and parts[0].startswith("S") and parts[1]:
            id2body[parts[0]] = parts[1]
    return id2body


def commands_from_recheck(text):
    """Backticked curl commands with the stated expectation that follows each."""
    parts = text.split("`")
    out = []
    for i in range(1, len(parts) - 1, 2):
        cmd = parts[i].strip()
        if not cmd.startswith("curl "):
            continue
        after = parts[i + 1] if i + 1 < len(parts) else ""
        m = STATED.search(after)
        out.append((cmd, int(m.group(2)) if m else None, bool(m), m.group(1) if m else None))
    return out


def main():
    if len(sys.argv) != 2:
        print("usage: replay.py <lane-root>", file=sys.stderr)
        return 2
    lane = Path(sys.argv[1])
    missing = [p for p in ("corpus/SOURCES.md", "corpus/quote-bodies.tsv", "corpus/knowledge")
               if not (lane / p).exists()]
    if missing:
        print(f"SETUP-ERROR: missing under {lane}: {missing}", file=sys.stderr)
        return 2

    url2id = parse_sources(lane)
    id2body = parse_quote_bodies(lane)
    rows = []
    for entry in sorted((lane / "corpus/knowledge").glob("*.md")):
        for n, line in enumerate(entry.read_text(encoding="utf-8").splitlines(), 1):
            if not RECHECK_LINE.match(line):
                continue
            for cmd, stated, stated_found, stated_form in commands_from_recheck(line):
                rec = {
                    "entry": str(entry.relative_to(lane)),
                    "line": n,
                    "command": cmd,
                    "stated": stated if stated_found else None,
                    "stated_form": (stated_form or "") + (str(stated) if stated_found else ""),
                }
                m = GREP_C_FORM.match(cmd)
                if not m:
                    rec.update(verdict="NOT_REPLAYABLE", reason="form: not `curl ... '<URL>' | grep -c '<P>'`")
                    rows.append(rec)
                    continue
                if not stated_found:
                    rec.update(verdict="NOT_REPLAYABLE", reason="no stated expectation")
                    rows.append(rec)
                    continue
                url, pattern = m.group(1), m.group(2)
                rec["url"] = url
                rec["pattern"] = pattern
                rid = url2id.get(url) or url2id.get(url.rstrip("/"))
                if rid is None:
                    rec.update(verdict="NOT_REPLAYABLE", reason="no registry row for URL")
                    rows.append(rec)
                    continue
                rec["row"] = rid
                body = id2body.get(rid)
                if body is None:
                    rec.update(verdict="NOT_REPLAYABLE",
                               reason=f"{rid} has no committed capture in corpus/quote-bodies.tsv")
                    rows.append(rec)
                    continue
                capture = lane / body
                if not capture.is_file():
                    rec.update(verdict="NOT_REPLAYABLE", reason=f"capture {body} absent from tree")
                    rows.append(rec)
                    continue
                proc = subprocess.run(["grep", "-c", "-e", pattern, str(capture)],
                                      capture_output=True, text=True)
                if proc.returncode not in (0, 1):
                    rec.update(verdict="ERROR",
                               reason=f"grep exit {proc.returncode}: {proc.stderr.strip()}")
                    rows.append(rec)
                    continue
                replayed = int(proc.stdout.strip() or "0")
                rec["capture_body_path"] = body
                rec["capture_replay"] = replayed
                rec["verdict"] = "MATCH" if replayed == stated else "MISMATCH"
                rows.append(rec)

    replayed = [r for r in rows if r["verdict"] in ("MATCH", "MISMATCH")]
    mismatch = [r for r in replayed if r["verdict"] == "MISMATCH"]
    summary = {
        "commands": len(rows),
        "grep_c_form_replayed": len(replayed),
        "matched": len(replayed) - len(mismatch),
        "mismatched": len(mismatch),
        "not_replayable": sum(1 for r in rows if r["verdict"] == "NOT_REPLAYABLE"),
        "errors": sum(1 for r in rows if r["verdict"] == "ERROR"),
    }
    print(json.dumps({"summary": summary, "rows": rows}, indent=2))
    print(f"REPLAY-SUMMARY: commands={summary['commands']} "
          f"replayed={summary['grep_c_form_replayed']} matched={summary['matched']} "
          f"mismatched={summary['mismatched']} not_replayable={summary['not_replayable']} "
          f"errors={summary['errors']}")
    return 1 if mismatch else 0


if __name__ == "__main__":
    sys.exit(main())
