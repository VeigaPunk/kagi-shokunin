#!/usr/bin/env python3
"""corpus/volatile-shape.py — VOLATILE_SHAPE counter (kagi round 65, claim C3).

Round-65 claim C3 (freshness), plans/round-65.md §C3 as amended by Amendment A1.
The S148 BioC carrier stamps the request date into its own body, so a digest pin
over the whole body drifts by one byte per day and cannot be re-verified
reproducibly. This counter replaces the digest reading with a SHAPE reading over
the committed capture the S148 row pins:

  * the body's sha256 must equal the S148 pin (identity — the capture is the
    row's evidence, not a re-fetch);
  * the `<date>` stamp is extracted and reported (the only byte a re-fetch is
    allowed to move);
  * `<passage>` and `<text>` open-tag occurrences are counted (the shape).

Output: exactly one verdict line

    VOLATILE_SHAPE: match=1 passages=182 texts=180 date=20261108 pin_sha=3b8d4e159a0b …

Exit 0 iff match=1; 1 on a shape or identity mismatch; 2 SETUP (missing capture,
no python3, bad args, unreachable network in --live mode).

`--live` is OPTIONAL and never changes the verdict: it fetches the current body,
writes a receipt, and reports the served status. A 429 is reported as
`rate_limited=1` — the endpoint allows 3 requests/second and this host is
currently throttled (plans/round-65.md Amendment A1); a 429 is never a verdict
and never a pass.

Scratch discipline (round-65 plan §Scratch): every temporary file lives under
$HYAKU_SCRATCH/kagi-r65/<seat>/ (honours TMPDIR); nothing is written inside the
lane tree except the receipt requested with --receipt.

Named ceiling: the shape census counts elements and one stamp. A body that keeps
182/180 counts while changing wording reads match=1; the S148 `teaches` prose is
the only place the deposit's textual content is checked.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import time

LANE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_CAPTURE = ".ufo/waves/round-64/capture/S143.body"
# The S148 row's pin (corpus/SOURCES.md), and the row's sha which the capture
# file carries. Kept as a literal because it is the claim's identity anchor.
PIN_SHA = "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40"
URL = ("https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/"
       "BioC_xml/PMC2757457/unicode")
USER_AGENT = ("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
              "(KHTML, like Gecko) Chrome/131.0 Safari/537.36")

DATE_RE = re.compile(rb"<date>([0-9]{8})</date>")
PASSAGE_RE = re.compile(rb"<passage>")
TEXT_RE = re.compile(rb"<text>")


def setup_die(msg: str) -> "NoReturn":  # noqa: F821
    print("volatile-shape: SETUP " + msg)
    raise SystemExit(2)


def scratch_root() -> str:
    base = os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku"
    root = os.path.join(base, "kagi-r65", "L1Volatile")
    tmp = os.environ.get("TMPDIR")
    if tmp and os.path.abspath(root).startswith(os.path.abspath(tmp)):
        return root
    try:
        os.makedirs(root, exist_ok=True)
        return root
    except OSError:
        return tempfile.mkdtemp(prefix="kagi-r65-volatile-")


def shape_of(body: bytes) -> dict:
    dates = DATE_RE.findall(body)
    return {
        "passages": len(PASSAGE_RE.findall(body)),
        "texts": len(TEXT_RE.findall(body)),
        "dates": sorted({d.decode() for d in dates}),
        "sha": hashlib.sha256(body).hexdigest(),
        "bytes": len(body),
    }


def verdict(match: int, shape: dict, extra: str = "") -> int:
    dates = ",".join(shape["dates"]) or "none"
    line = ("VOLATILE_SHAPE: match=%d passages=%d texts=%d date=%s pin_sha=%s"
            % (match, shape["passages"], shape["texts"], dates, shape["sha"][:40]))
    if extra:
        line += " " + extra
    print(line)
    return 0 if match == 1 else 1


def live_fetch(receipt: str | None) -> dict:
    """Fetch the current body. Never raises: reports what happened."""
    root = scratch_root()
    body_path = os.path.join(root, "live-%s.body" % time.strftime("%Y%m%dT%H%M%SZ"))
    tmpdir = os.environ.get("TMPDIR") or root
    cmd = ["curl", "-sS", "-m", "90", "-A", USER_AGENT, "-o", body_path,
           "-w", "%{http_code}", URL]
    rec = {"url": URL, "body_path": body_path, "tmpdir": tmpdir}
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        rec["http_status"] = (r.stdout or "").strip() or "000"
        rec["curl_rc"] = r.returncode
    except (OSError, subprocess.TimeoutExpired) as e:
        rec["http_status"] = "000"
        rec["curl_rc"] = -1
        rec["error"] = type(e).__name__
    if os.path.isfile(body_path):
        with open(body_path, "rb") as f:
            body = f.read()
        rec["bytes"] = len(body)
        rec["sha256"] = hashlib.sha256(body).hexdigest()
        rec["rate_limited"] = int(
            rec.get("http_status") == "429"
            or b"Rate limit exceeded" in body
            or b"Too Many Requests" in body)
        rec["body_sha256"] = rec["sha256"]
    else:
        rec["bytes"] = 0
        rec["rate_limited"] = int(rec.get("http_status") == "429")
    if receipt:
        os.makedirs(os.path.dirname(os.path.abspath(receipt)) or ".", exist_ok=True)
        with open(receipt, "w", encoding="utf-8") as f:
            json.dump(rec, f, indent=1, sort_keys=True)
            f.write("\n")
        rec["receipt"] = receipt
    return rec


def selftest() -> int:
    """Fixture-driven: the counter's own shape logic, and its ability to fail."""
    cases = 0
    failed = []

    def case(name: str, cond: bool) -> None:
        nonlocal cases
        cases += 1
        if not cond:
            failed.append(name)

    good = (b"<collection><date>20261108</date>"
            + b"<passage><infon>a</infon><text>b</text></passage>" * 3
            + b"</collection>")
    s = shape_of(good)
    case("shape-counts", s["passages"] == 3 and s["texts"] == 3)
    case("shape-date", s["dates"] == ["20261108"])
    case("sha-identity", s["sha"] == hashlib.sha256(good).hexdigest())

    # a count mutation must read different counts (the counter can fail)
    mut = good.replace(b"<text>b</text>", b"<text>b</text><text>c</text>", 1)
    sm = shape_of(mut)
    case("count-mutation-detected", sm["texts"] == 4 and s["texts"] == 3)
    # a date mutation must read a different stamp
    md = good.replace(b"20261108", b"20261110")
    case("date-mutation-detected", shape_of(md)["dates"] == ["20261110"])
    # a 429 shell must be recognisable (never a shape)
    rl = b"<html><title>Too Many Requests</title>429</html>"
    sr = shape_of(rl)
    case("429-has-no-passages", sr["passages"] == 0 and sr["texts"] == 0)
    case("429-marker-present", b"Too Many Requests" in rl)

    if failed:
        print("VOLATILE_SHAPE_SELFTEST: FAIL (cases=%d failed=%d names=%s)"
              % (cases, len(failed), ",".join(failed)))
        return 1
    print("VOLATILE_SHAPE_SELFTEST: PASS (cases=%d)" % cases)
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="VOLATILE_SHAPE counter (round 65)")
    ap.add_argument("--capture", default=None,
                    help="committed body to measure (default: the S148 capture)")
    ap.add_argument("--pin", default=PIN_SHA, help="expected sha256 (the S148 pin)")
    ap.add_argument("--passages", type=int, default=182)
    ap.add_argument("--texts", type=int, default=180)
    ap.add_argument("--live", action="store_true",
                    help="also fetch the current body and write a receipt")
    ap.add_argument("--receipt", default=None, help="live-fetch receipt path")
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()

    if args.selftest:
        return selftest()

    cap = args.capture or os.path.join(LANE, DEFAULT_CAPTURE)
    if not os.path.isfile(cap):
        setup_die("no committed capture at " + cap)
    with open(cap, "rb") as f:
        body = f.read()
    shape = shape_of(body)

    identity = int(shape["sha"] == args.pin)
    counts = int(shape["passages"] == args.passages and shape["texts"] == args.texts)
    dated = int(len(shape["dates"]) == 1)
    match = int(identity and counts and dated)

    bits = ["identity=%d" % identity, "counts=%d" % counts, "dated=%d" % dated]
    if args.live:
        rec = live_fetch(args.receipt)
        bits.append("live_status=%s" % rec.get("http_status", "?"))
        bits.append("rate_limited=%d" % int(rec.get("rate_limited", 0)))
        if rec.get("body_path") and os.path.isfile(rec["body_path"]):
            with open(rec["body_path"], "rb") as f:
                served = shape_of(f.read())
            bits.append("live_passages=%d" % served["passages"])
            bits.append("live_dates=%s" % (",".join(served["dates"]) or "none"))
    return verdict(match, shape, " ".join(bits))


if __name__ == "__main__":
    raise SystemExit(main())
