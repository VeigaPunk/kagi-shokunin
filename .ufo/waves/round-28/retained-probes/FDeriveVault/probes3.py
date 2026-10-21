#!/usr/bin/env python3
"""Observe-mode + receipt-isolation probes for the G2 (Vault S034) carrier.

O1 observe mode offline: run the candidate's real `--observe` code path with
   request_body overridden to serve the AUTHENTIC cached Vault feed body
   (sha256 e41bc579... == the sha256 recorded in corpus/source-fetches.tsv for
   S034 and in every S012/S013/S022-S024 receipt record). No network.
   Question: for the G2-lowered rows, does --observe write a `fired` verdict,
   and what typed findings does evaluate() raise afterwards?

O2 receipt isolation: same G2 table edit but the receipt is NOT mirrored.
   Question: which categories appear? (Confirms the frozen fixture's receipt
   mirror is what keeps the finding typed as DERIVATION rather than a generic
   RECEIPT-MISMATCH.)
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
FEED_BODY = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-26/"
                 "build/ClockS024-artifacts/vault-releases.atom")
TREE = Path(sys.argv[1]).resolve()
WORK = Path("/fast/scratch/kagi-r28-fdderivevault")
FEED_URL = "https://github.com/hashicorp/vault/releases.atom"


def load_mod(tree):
    spec = importlib.util.spec_from_file_location("rc_obs", tree / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def build(work: Path, mirror_receipt: bool):
    if work.exists():
        shutil.rmtree(work)
    root = work / "root"
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
    records = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    if mirror_receipt:
        for record in records["observations"]:
            if record.get("id") in GROUP:
                record["parsed_version"] = LOWER
                record["verdict"] = "not-fired"
    receipt = root / "receipt.json"
    receipt.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    return root, receipt


def observe_probe():
    mod = load_mod(TREE)
    root, _ = build(WORK / "o1", True)
    body = FEED_BODY.read_bytes()
    print("== O1 observe mode (offline, authentic cached feed body) ==")
    print("   feed_body_sha256=%s" % hashlib.sha256(body).hexdigest())

    def fake_request_body(url, **kwargs):
        if url == FEED_URL:
            return 200, body, None
        return 200, b"<html>ok</html>", None

    mod.request_body = fake_request_body
    mod.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
    out = root / "observe-out.json"
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        exit_code = mod.main(["--root", str(root), "--observe", str(out)])
    print("   exit=%d" % exit_code)
    for line in buf.getvalue().splitlines():
        print("   |", line)
    if out.is_file():
        data = json.loads(out.read_text(encoding="utf-8"))
        print("   --- receipt records for the vault feed rows ---")
        for record in data.get("observations", []):
            if record.get("id") in GROUP or record.get("id") == "S012":
                print("     %s parsed_version=%r verdict=%r error=%r"
                      % (record.get("id"), record.get("parsed_version"),
                         record.get("verdict"), record.get("error")))
    else:
        print("   NO RECEIPT WRITTEN")


def verify_no_mirror():
    mod = load_mod(TREE)
    root, receipt = build(WORK / "o2", False)
    import subprocess
    argv = ["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(receipt),
            "--receipt-sha", hashlib.sha256(receipt.read_bytes()).hexdigest()]
    proc = subprocess.run(argv, cwd=TREE, text=True, capture_output=True)
    print("== O2 same table edit, receipt NOT mirrored ==")
    print("   exit=%d traceback=%s" % (proc.returncode,
          "Traceback" in proc.stdout or "Traceback" in proc.stderr))
    for line in proc.stdout.splitlines():
        print("   |", line)


if __name__ == "__main__":
    observe_probe()
    verify_no_mirror()
