#!/usr/bin/env python3
"""Round-26 evidence recorder. All gate executions use fresh scratch clones."""
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
LANE = Path(__file__).resolve().parents[4]
BASE = "1bf3eec48d3761580ffd375c88143232485ae814"
HISTORICAL_SHA = "b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92"
CURRENT_SHA = "13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169"
REL = ".ufo/waves/round-26"


def load_module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    revision, output = sys.argv[1:]
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise SystemExit("full measured revision required")
    records = []
    with tempfile.TemporaryDirectory(prefix="kagi-r26-measure-", dir="/fast/scratch") as temp:
        temp = Path(temp)
        mirror = temp / "fleet"
        mirror.mkdir()
        root = mirror / "kagi-shokunin"
        subprocess.run(["git", "clone", "--quiet", "--no-hardlinks", "--no-checkout", str(LANE), str(root)], check=True)
        subprocess.run(["git", "-C", str(root), "checkout", "--quiet", "--detach", revision], check=True)
        for entry in LANE.parent.iterdir():
            if entry.name == "kagi-shokunin" or entry.name in (".git", ".jj"):
                continue
            if entry.name.endswith("-shokunin") or entry.name == ".ufo" or entry.is_file():
                (mirror / entry.name).symlink_to(entry, target_is_directory=entry.is_dir())
        home = temp / "empty-home"
        home.mkdir()
        env = dict(os.environ, HOME=str(home), PYTHONDONTWRITEBYTECODE="1")
        for key in list(env):
            if key.startswith("OP_SESSION") or key in ("OP_SERVICE_ACCOUNT_TOKEN", "OP_CONNECT_TOKEN", "OP_CONNECT_HOST", "OP_ACCOUNT"):
                del env[key]

        def record(name, passed, **detail):
            records.append(dict(name=name, passed=bool(passed), **detail))

        def run(name, args, expected_exit=0, contains=(), cwd=root):
            process = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True, timeout=900)
            passed = process.returncode == expected_exit and all(text in process.stdout for text in contains)
            record(name, passed, argv=args, cwd=str(cwd), exit=process.returncode,
                   expected_exit=expected_exit, expected_contains=list(contains),
                   stdout=process.stdout, stderr=process.stderr)
            return process

        wrapper = str(root / REL / "tools/replay-current.sh")
        for profile in ("frozen", "rearmed"):
            expected = json.loads((root / REL / profile / "expected.json").read_text())
            for mode in ("before", "after"):
                spec = expected[mode]
                run(profile + "-" + mode, ["bash", wrapper, mode, str(root / REL / profile)],
                    spec["exit"], [spec["summary"], *spec.get("findings", spec.get("finding_ids", []))])

        run("active-default", ["python3", "-B", "corpus/release-clock.py"], 0,
            ["RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)"])
        run("clock-selftest", ["python3", "-B", "corpus/release-clock.py", "--selftest"], 0,
            ["RELEASE_CLOCK_SELFTEST: PASS (67 cases)"])
        run("source-census", ["bash", "corpus/sources-census.sh"], 0,
            ["SOURCES_CENSUS: CLEAN (rows=41 A=39 B=0 C=2 queued=1 mined=37 rejected=3"])
        run("self-counts", ["python3", "-B", "corpus/self-counts.py"], 0,
            ["SELF_COUNTS: CLEAN (claims=38 stale=0)"])
        run("ledger-default-host-exclusion", ["bash", "corpus/claim-ledger.sh", "verify"], 0,
            ["CLAIM_LEDGER: CLEAN", "claims=65", "stamped=89", "host_skipped=12"])

        lone_parent = temp / "lone"
        lone_parent.mkdir()
        lone = lone_parent / "checkout"
        subprocess.run(["git", "clone", "--quiet", "--no-hardlinks", "--no-checkout", str(LANE), str(lone)], check=True)
        subprocess.run(["git", "-C", str(lone), "checkout", "--quiet", "--detach", revision], check=True)
        run("lone-citations-honesty", ["bash", "corpus/claim-ledger.sh", "citations"], 3,
            ["CITATION_GATE: INCOMPLETE", "unresolved=0", "fleet_absent=48"], cwd=lone)
        run("lone-verify-honesty", ["bash", "corpus/claim-ledger.sh", "verify"], 1,
            ["LAYOUT-INCOMPLETE R11-08", "CLAIM_LEDGER: INCOMPLETE", "layout_incomplete=1", "host_skipped=12"], cwd=lone)

        historical = root / ".ufo/waves/round-25/observe-1.json"
        old_bytes = subprocess.check_output(["git", "-C", str(root), "show", BASE + ":.ufo/waves/round-25/observe-1.json"])
        record("historical-receipt-immutable", historical.read_bytes() == old_bytes and hashlib.sha256(old_bytes).hexdigest() == HISTORICAL_SHA,
               sha256=hashlib.sha256(historical.read_bytes()).hexdigest(), expected_sha256=HISTORICAL_SHA)
        current = root / REL / "observe-2.json"
        record("current-receipt-literal-pin", hashlib.sha256(current.read_bytes()).hexdigest() == CURRENT_SHA,
               sha256=hashlib.sha256(current.read_bytes()).hexdigest(), expected_sha256=CURRENT_SHA)
        old = json.loads(old_bytes)["observations"]
        first = json.loads((root / REL / "observe-1.json").read_text())["observations"]
        fields = ("id", "clock", "url", "http_status", "error", "parsed_version", "located", "verdict")
        left = {entry["id"]: tuple(entry.get(key) for key in fields) for entry in old}
        right = {entry["id"]: tuple(entry.get(key) for key in fields) for entry in first}
        changed = sorted(key for key in left if left[key] != right.get(key))
        record("id-exact-drift", len(left) == len(old) == 28 and len(right) == len(first) == 28 and left.keys() == right.keys() and changed == ["S027", "S028"],
               identity_fields=fields, changed_ids=changed, timestamps_and_digests_excluded=True,
               note="One shared Python feed, two teaching/clock dispositions; not two independent release observations")

        clock = load_module(root / "corpus/release-clock.py", "r26clock")
        sources = clock.parse_sources(root)
        bindings = clock.parse_bindings(root)
        by_id = {row["id"]: dict(zip(clock.HEADER, row["fields"])) for row in bindings}
        fake_feed = b"<rss><channel><item><title>Python 3.15.2</title></item></channel></rss>"
        clock.request_body = lambda *args, **kwargs: (200, fake_feed, None)
        future = [clock.observe_one(sources[sid], by_id[sid], None) for sid in ("S040", "S041")]
        record("successors-fire-next-release", all(entry.get("parsed_version") == "3.15.2" and entry.get("verdict") == "fired" and "error" not in entry for entry in future),
               observations=future, anchored_versions={sid: by_id[sid]["anchored_version"] for sid in ("S040", "S041")})
        for sid in ("S040", "S041"):
            fixture = temp / ("missing-" + sid)
            shutil.copytree(root / REL / "rearmed/after", fixture)
            table = fixture / "corpus/release-clocks.tsv"
            table.write_text("".join(line for line in table.read_text().splitlines(keepends=True) if not line.startswith(sid + "\t")))
            run("missing-binding-" + sid, ["python3", "-B", str(root / "corpus/release-clock.py"), "--root", str(fixture), "--receipt", str(current), "--receipt-sha", CURRENT_SHA], 1, ["UNBOUND " + sid, "RELEASE_CLOCK: FAILED"])

        for together in (False, True):
            fixture = temp / ("tamper-pair" if together else "tamper-input")
            shutil.copytree(root / REL / "rearmed", fixture)
            receipt = fixture / "observe-2.json"
            receipt.write_bytes(receipt.read_bytes() + b" ")
            if together:
                manifest = fixture / "inputs.sha256"
                lines = manifest.read_text().splitlines()
                manifest.write_text("\n".join(hashlib.sha256(receipt.read_bytes()).hexdigest() + "  observe-2.json" if line.endswith("  observe-2.json") else line for line in lines) + "\n")
            run("tamper-input-plus-manifest" if together else "tamper-input-only", ["bash", wrapper, "after", str(fixture)], 2, ["ROUND26_REPLAY: snapshot_tampered"])

        normalizer = load_module(root / "corpus/rendered-text-v1.py", "r26normalizer")
        metadata = json.loads((root / REL / "captures/metadata.json").read_text())
        clauses = []
        for entry in metadata:
            body = (root / REL / "captures" / (entry["id"] + ".body")).read_bytes()
            clauses.append(dict(id=entry["id"], kind="input-digest", passed=hashlib.sha256(body).hexdigest() == entry["sha256"]))
        re_body = (root / REL / "captures/S040.body").read_text()
        re_scope = re_body.split('<dl id="index-32">', 1)[1].split('<dl id="index-33">', 1)[0]
        normalized_re = normalizer.normalize_text(re_scope)
        html_scope = normalizer.normalize_bytes((root / REL / "captures/S041.body").read_bytes()).decode()
        checks = [
            ("unicode", normalized_re, "Matches Unicode whitespace characters (as defined by str.isspace() )."),
            ("nbsp", normalized_re, "non-breaking spaces mandated by typography rules in many languages."),
            ("ascii", normalized_re, "if the ASCII flag is used."),
            ("named-numeric", html_scope, "Convert all named and numeric character references"),
            ("unicode-result", html_scope, "to the corresponding Unicode characters."),
            ("html5", html_scope, "This function uses the rules defined by the HTML 5 standard for both valid and invalid character references"),
        ]
        for label, text, quote in checks:
            clauses.append(dict(id=label, quote=quote, quote_words=len(quote.split()), count=text.count(quote), passed=quote in text and len(quote.split()) <= 25))
        record("per-clause-source-check", all(entry["passed"] for entry in clauses), clauses=clauses,
               local_code_scope="rendered-text-v1.py:65-75; no runtime3.15.1 or global semantic-equivalence assertion")
        feed = (root / REL / "captures/S039.body").read_bytes()
        first_title = re.search(rb"<item>.*?<title>(.*?)</title>", feed, re.S).group(1).decode()
        parsed = clock.parse_latest_version(feed)
        record("backport-first-parser-control", first_title == "Python 3.14.9" and parsed == "3.15.1", first_title=first_title, max_stable=parsed,
               rejected_first_entry_expected="Python 3.15.1", rejected_first_entry_would_fail=first_title != "Python 3.15.1")

    result = dict(format="kagi-round26-final-measure-v1", measured_revision=revision, base_revision=BASE,
                  checks=records, passed=sum(entry["passed"] for entry in records), total=len(records))
    Path(output).write_text(json.dumps(result, indent=2) + "\n")
    for entry in records:
        print(("PASS " if entry["passed"] else "FAIL ") + entry["name"])
    print("ROUND26_MEASURE: %d/%d" % (result["passed"], result["total"]))
    return 0 if result["passed"] == result["total"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
