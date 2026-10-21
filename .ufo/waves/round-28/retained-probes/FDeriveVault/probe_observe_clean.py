#!/usr/bin/env python3
"""Clean observe-mode probe for the G2 (Vault S034) carrier, candidate tree.

Only the vault feed is served from the AUTHENTIC cached body
(sha256 e41bc579... == corpus/source-fetches.tsv S034 and every vault receipt
record). Every other feed/URL returns a benign 200 body, so the only
DERIVATION findings are the vault group's; the RECEIPT-MISMATCHs from other
rows are artifacts of the stub, not of the rule.

Question: for the G2-lowered rows, what does --observe WRITE into the receipt,
and does the run exit non-zero with a typed DERIVATION finding?
"""
import hashlib
import importlib.util
import io
import contextlib
import json
import shutil
import sys
from pathlib import Path

GROUP = ["S013", "S022", "S023", "S024"]
LOWER = "2.1.9"
FEED_URL = "https://github.com/hashicorp/vault/releases.atom"
FEED_BODY = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-26/"
                 "build/ClockS024-artifacts/vault-releases.atom")
TREE = Path(sys.argv[1]).resolve()
WORK = Path("/fast/scratch/kagi-r28-fdderivevault/o4")


def load_mod():
    spec = importlib.util.spec_from_file_location("rc_o4", TREE / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    mod = load_mod()
    if WORK.exists():
        shutil.rmtree(WORK)
    root = WORK / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(TREE / "corpus" / rel, root / "corpus" / rel)
    lines = (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in GROUP:
            fields[4] = LOWER
            fields[5] = LOWER
            fields[7] = "not-fired"
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")

    body = FEED_BODY.read_bytes()
    print("feed_body_sha256=%s" % hashlib.sha256(body).hexdigest())

    def fake_request_body(url, **kwargs):
        if url == FEED_URL:
            return 200, body, None
        return 200, b"<html><body>stub</body></html>", None

    mod.request_body = fake_request_body
    mod.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
    out = root / "observe-out.json"
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        exit_code = mod.main(["--root", str(root), "--observe", str(out)])
    print("exit=%d" % exit_code)
    for line in buf.getvalue().splitlines():
        if "RECEIPT-MISMATCH" in line:
            continue
        print("  |", line)
    data = json.loads(out.read_text(encoding="utf-8"))
    print("--- vault rows in the WRITTEN receipt ---")
    for record in data.get("observations", []):
        if record.get("id") in GROUP or record.get("id") == "S012":
            print("  %s parsed_version=%r verdict=%r error=%r"
                  % (record.get("id"), record.get("parsed_version"),
                     record.get("verdict"), record.get("error")))
    fired_forged = [r["id"] for r in data.get("observations", [])
                    if r.get("id") in GROUP and r.get("verdict") == "fired"]
    print("forged_rows_with_fired_verdict_in_receipt=%s" % fired_forged)
    print("run_exit_zero=%s" % (exit_code == 0))


if __name__ == "__main__":
    raise SystemExit(main())
