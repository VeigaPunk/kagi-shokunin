#!/usr/bin/env python3
"""Third C2 experiment set: comparison precision and plan-enumeration gaps.

P  string equality on the canonical token (v-stripped) vs NUMERIC tuple
   equality -- a forged leading-zero anchor "3.13.03" compares EQUAL
   numerically to "3.13.3" (int("03") == 3).
G  the plan's parenthetical "the feed row S033-S037" as a HARD-CODED id list:
   S039 is also a loaded feed-kind registry row (S040/S041 name it) and it is
   OUTSIDE the S033-S037 range.
"""
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work4"

STRICT = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
LEADING_ZERO = re.compile(r"(^|\.)0[0-9]")


def numeric(value):
    value = value[1:] if value[:1].lower() == "v" else value
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", value):
        return None
    return tuple(int(part) for part in value.split("."))


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    root = WORK / "v"
    shutil.copytree(BASE, root)

    print("== P: string vs numeric comparison of a leading-zero anchor ==")
    for token in ("3.13.3", "3.13.03", "v3.13.3", "03.13.3"):
        numeric_equal = numeric(token) == numeric("3.13.3")
        string_equal = (token[1:] if token[:1].lower() == "v" else token) == "3.13.3"
        print("  %-10s numeric_eq=%-5s string_eq=%-5s leading_zero=%s" % (
            token, numeric_equal, string_equal, bool(LEADING_ZERO.search(token))))

    print()
    print("== P2: does the BASE table accept a leading-zero derived anchor? ==")
    sys_path = root / "corpus/release-clock.py"
    code = sys_path.read_text(encoding="utf-8")
    # a prototype that binds by NUMERIC equality (the tempting implementation)
    helper = '''
def _ver_tokens_num(text):
    out = set()
    for m in re.finditer(r"(?<![0-9A-Za-z.])v?([0-9]+\\.[0-9]+\\.[0-9]+)(?![0-9A-Za-z.])",
                         text or ""):
        out.add(m.group(1))
    return out
'''
    patch_num = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = _ver_tokens_num(feed_source["anchor"])
                target = numeric_version(values["anchored_version"])
                if av and not any(numeric_version(t) == target for t in av):
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''
    patch_str = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = _ver_tokens_num(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''
    for name, patch in (("NUM", patch_num), ("STR", patch_str)):
        vroot = WORK / ("v" + name)
        shutil.copytree(BASE, vroot)
        p = vroot / "corpus/release-clock.py"
        c = p.read_text(encoding="utf-8")
        c = c.replace("def evaluate(sources, rows, captures=None, receipt_bundle=None):\n",
                      helper.lstrip("\n") + "\n\ndef evaluate(sources, rows, captures=None, receipt_bundle=None):\n", 1)
        c = c.replace('            is_derived = values["note"].startswith("derived:")\n', patch, 1)
        p.write_text(c, encoding="utf-8")
        # forge a leading-zero derived anchor on S008 (3.13.3 -> 3.13.03)
        fx = WORK / ("fx" + name)
        if fx.exists():
            shutil.rmtree(fx)
        (fx / "corpus").mkdir(parents=True)
        for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                    "release-clock.py"):
            shutil.copy2(vroot / "corpus" / rel, fx / "corpus" / rel)
        lines = (vroot / "corpus/release-clocks.tsv").read_text(
            encoding="utf-8").splitlines(keepends=True)
        out = []
        for line in lines:
            f = line.rstrip("\n").split("\t")
            if f[0] == "S008":
                f[4], f[5], f[7] = "3.13.03", "3.13.03", "not-fired"
                line = "\t".join(f) + "\n"
            out.append(line)
        (fx / "corpus/release-clocks.tsv").write_text("".join(out), encoding="utf-8")
        import hashlib
        import json
        receipt = json.loads((vroot / ".ufo/waves/round-26/observe-2.json").read_text())
        for rec in receipt["observations"]:
            if rec["id"] == "S008":
                rec["parsed_version"], rec["verdict"] = "3.13.03", "not-fired"
        rp = fx / "receipt.json"
        rp.write_text(json.dumps(receipt, indent=2) + "\n")
        sha = hashlib.sha256(rp.read_bytes()).hexdigest()
        proc = subprocess.run(
            ["python3", "-I", "-B", str(fx / "corpus/release-clock.py"), "--root", str(fx),
             "--receipt", str(rp), "--receipt-sha", sha],
            capture_output=True, text=True, timeout=120)
        lines = [l for l in proc.stdout.splitlines() if l.strip()]
        findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
        print("  %s forged anchor 3.13.03: exit=%d findings=%s" % (
            name, proc.returncode, findings or "[]"))

    print()
    print("== G: the plan's 'S033-S037' vs the feed-kind rows the clock loads ==")
    import importlib.util
    spec = importlib.util.spec_from_file_location("rc", BASE / "corpus/release-clock.py")
    rc = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rc)
    sources = rc.parse_sources(BASE)
    rows = rc.parse_bindings(root)
    feed_kind = sorted(sid for sid, s in sources.items()
                       if s["kind"].lower() in rc.FEED_KINDS and s["recheck"] != "on-release")
    in_range = [sid for sid in feed_kind if "S033" <= sid <= "S037"]
    print("  feed-kind, non-on-release registry rows:", feed_kind)
    print("  inside the plan's S033-S037 range:", in_range)
    print("  OUTSIDE the range but loaded and named by clock rows:",
          [sid for sid in feed_kind if sid not in in_range])
    named = set()
    for r in rows:
        if r["malformed"]:
            continue
        v = dict(zip(rc.HEADER, r["fields"]))
        if v["clock"] == "feed":
            named.add(v["feed_source_id"])
    print("  feed_source_ids actually named by clock rows:", sorted(named))
    print("  named but outside the plan's range:", sorted(named - set(in_range)))


if __name__ == "__main__":
    main()
