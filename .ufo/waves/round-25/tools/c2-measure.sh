#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
lane_dir=$(cd -- "$script_dir/../../../.." && pwd -P)
exec python3 - "$lane_dir" "$@" <<'PY'
import json
from pathlib import Path
import re
import subprocess
import sys

PHASE = "argument validation"
CLEAN_ENV = None


def emit(value):
    print(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")))


def command_result(argv, cwd, env=None, timeout=None):
    try:
        result = subprocess.run(
            argv,
            cwd=str(cwd) if cwd is not None else None,
            env=env,
            capture_output=True,
            text=True,
            errors="replace",
            timeout=timeout,
            check=False,
        )
        return {
            "exit": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "timed_out": False,
        }
    except subprocess.TimeoutExpired as exc:
        def text(value):
            if value is None:
                return ""
            if isinstance(value, bytes):
                return value.decode("utf-8", "replace")
            return value
        return {
            "exit": 124,
            "stdout": text(exc.stdout),
            "stderr": text(exc.stderr),
            "timed_out": True,
        }


def checked(argv, cwd, env=None):
    result = command_result(argv, cwd, env=env, timeout=600)
    if result["exit"] != 0:
        detail = result["stderr"].strip() or result["stdout"].strip()
        raise RuntimeError(
            "command failed (exit %s): %s%s"
            % (result["exit"], " ".join(argv), (": " + detail) if detail else "")
        )
    return result


def clone_at(source, destination, revision, env):
    checked(["git", "clone", "-q", "--no-hardlinks", str(source), str(destination)], destination.parent, env)
    checked(["git", "-C", str(destination), "checkout", "-q", "--detach", revision], destination.parent, env)
    result = checked(["git", "-C", str(destination), "rev-parse", "HEAD"], destination.parent, env)
    return result["stdout"].strip()


def citation_docs(root):
    fixed = [
        "AGENTS.md", "LOG.md", "PROVINCE.md", "SCORECARD.md", "SHONEN.md",
        "SKILL.md", "corpus/README.md",
    ]
    paths = [root / rel for rel in fixed]
    for subdir in (root / "corpus/knowledge", root / "corpus/lessons"):
        if subdir.is_dir():
            paths.extend(sorted(subdir.glob("*.md")))
    return [path for path in paths if path.is_file()]


def cited_sibling_names(root, lane_name):
    name_re = re.compile(r"(?<![A-Za-z0-9_.-])([A-Za-z0-9][A-Za-z0-9._-]*-shokunin)/")
    names = set()
    for path in citation_docs(root):
        text = path.read_text(encoding="utf-8", errors="replace")
        names.update(match.group(1) for match in name_re.finditer(text))
    names.discard(lane_name)
    return sorted(names)


def summarize_citations(result, command):
    class_names = ("local", "shorthand", "ufo", "sibling", "rootdoc")
    class_re = re.compile(r"\b(" + "|".join(class_names) + r")\b")
    counts = {"UNRESOLVED": {}, "FLEET-ABSENT": {}}
    for line in result["stdout"].splitlines():
        kind = line.split(maxsplit=1)[0] if line.strip() else ""
        if kind not in counts:
            continue
        payload = line.rsplit("(", 1)[-1].rstrip(")") if "(" in line else ""
        match = class_re.search(payload)
        cls = match.group(1) if match else "unknown"
        counts[kind][cls] = counts[kind].get(cls, 0) + 1
    terminal = next((line for line in reversed(result["stdout"].splitlines()) if line.strip()), None)
    counts["UNRESOLVED"] = dict(sorted(counts["UNRESOLVED"].items()))
    counts["FLEET-ABSENT"] = dict(sorted(counts["FLEET-ABSENT"].items()))
    return {
        "command": command,
        "exit": result["exit"],
        "terminal_line": terminal,
        "counts_by_class": counts,
        "unresolved_total": sum(counts["UNRESOLVED"].values()),
        "fleet_absent_total": sum(counts["FLEET-ABSENT"].values()),
        "timed_out": result["timed_out"],
    }


def citations_run(lane_root, home):
    command = "env -i PATH=/usr/bin:/bin HOME=%s bash corpus/claim-ledger.sh citations" % home
    result = command_result(
        ["bash", "corpus/claim-ledger.sh", "citations"],
        lane_root,
        env=CLEAN_ENV,
        timeout=600,
    )
    return summarize_citations(result, command), result


def append_cite_and_run(lane_root, home, cite):
    readme = lane_root / "corpus/README.md"
    original = readme.read_bytes()
    addition = (b"" if original.endswith(b"\n") else b"\n") + ("see `%s` control\n" % cite).encode("utf-8")
    try:
        readme.write_bytes(original + addition)
        summary, result = citations_run(lane_root, home)
    finally:
        readme.write_bytes(original)
    matching = [
        line for line in result["stdout"].splitlines()
        if line.startswith("UNRESOLVED ") and cite in line
    ]
    return {
        "cite": cite,
        "exit": summary["exit"],
        "terminal_line": summary["terminal_line"],
        "counts_by_class": summary["counts_by_class"],
        "unresolved_total": summary["unresolved_total"],
        "fleet_absent_total": summary["fleet_absent_total"],
        "matched_unresolved_lines": matching,
        "ok": summary["exit"] == 1 and bool(matching),
    }


def verify_record(lane_root, home, command_args, label):
    command_text = "env -i PATH=/usr/bin:/bin HOME=%s %s" % (home, " ".join(command_args))
    result = command_result(command_args, lane_root, env=CLEAN_ENV, timeout=610)
    combined = result["stdout"] + ("\n" if result["stdout"] and result["stderr"] else "") + result["stderr"]
    matched = [line for line in combined.splitlines() if "R11-08" in line or "LAYOUT-SKIP" in line]
    terminal = next((line for line in reversed(result["stdout"].splitlines()) if line.strip()), None)
    return {
        "layout": label,
        "command": command_text,
        "exit": result["exit"],
        "timed_out": result["timed_out"],
        "terminal_line": terminal,
        "R11-08_or_LAYOUT-SKIP_lines": matched,
    }


def main():
    global PHASE, CLEAN_ENV
    if len(sys.argv) != 4:
        raise ValueError("usage: c2-measure.sh <rev> <label>")
    lane = Path(sys.argv[1]).resolve()
    revision, label = sys.argv[2], sys.argv[3]
    if not revision or revision.startswith("-") or any(ch in revision for ch in "\r\n\0"):
        raise ValueError("revision must be a non-empty git revision without a leading dash or newline")
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", label) or label in (".", ".."):
        raise ValueError("label must be one safe path component")
    if not lane.is_dir() or not (lane / "corpus/claim-ledger.sh").is_file():
        raise ValueError("lane root does not contain corpus/claim-ledger.sh: " + str(lane))

    parent = lane.parent
    manifest = parent / "MANIFEST.json"
    fleet_ufo = parent / ".ufo"
    for name in ("reports", "waves", "prompts"):
        if not (fleet_ufo / name).is_dir():
            raise ValueError("required fleet source directory is missing: " + str(fleet_ufo / name))
    if not manifest.is_file():
        raise ValueError("fleet source MANIFEST.json is missing: " + str(manifest))

    scratch = Path("/fast/scratch/kagi-r25/XMeasureC2") / label
    if scratch.exists():
        raise FileExistsError("scratch label already exists; choose a new label: " + str(scratch))
    scratch.mkdir(parents=True)
    home = scratch / "home"
    home.mkdir()
    CLEAN_ENV = {"PATH": "/usr/bin:/bin", "HOME": str(home)}

    result = {
        "tool": "c2-measure.sh",
        "requested_revision": revision,
        "label": label,
        "scratch": str(scratch),
        "layouts": {},
    }

    PHASE = "creating lone layout"
    lone_parent = scratch / "lone"
    lone_parent.mkdir()
    lone_root = lone_parent / "lane"
    lone_commit = clone_at(lane, lone_root, revision, CLEAN_ENV)
    lone_marker_absent = not (lone_parent / ".ufo/MANIFEST.json").exists()
    result["resolved_revision"] = lone_commit
    result["layouts"]["lone"] = {
        "root": str(lone_root),
        "fleet_marker_sibling_absent": lone_marker_absent,
    }

    PHASE = "creating fleet layout"
    fleet_root = scratch / "fleet"
    fleet_root.mkdir()
    fleet_manifest = fleet_root / "MANIFEST.json"
    fleet_manifest.write_bytes(manifest.read_bytes())
    ufo_dest = fleet_root / ".ufo"
    ufo_dest.mkdir()
    checked([
        "cp", "-r", "--",
        str(fleet_ufo / "reports"), str(fleet_ufo / "waves"),
        str(fleet_ufo / "prompts"), str(ufo_dest),
    ], fleet_root, CLEAN_ENV)

    cited_names = cited_sibling_names(lone_root, lane.name)
    discovered = {
        source.name: source
        for source in sorted(parent.glob("*-shokunin"))
        if source.is_dir() and not source.is_symlink() and source.name != lane.name
    }
    missing_sources = [name for name in cited_names if name not in discovered]
    cloned_siblings = []
    for name in cited_names:
        source = discovered.get(name)
        if source is None:
            continue
        clone_at(source, fleet_root / name, revision="HEAD", env=CLEAN_ENV)
        cloned_siblings.append(name)
    fleet_lane_root = fleet_root / lane.name
    fleet_commit = clone_at(lane, fleet_lane_root, revision, CLEAN_ENV)

    result["layouts"]["fleet"] = {
        "root": str(fleet_lane_root),
        "fleet_root": str(fleet_root),
        "manifest_copied": fleet_manifest.is_file(),
        "copied_ufo_trees": ["reports", "waves", "prompts"],
        "cited_sibling_lanes": cited_names,
        "cloned_sibling_lanes": cloned_siblings,
        "missing_cited_sibling_sources": missing_sources,
        "fleet_lane_revision": fleet_commit,
    }
    result["layouts"]["lone"]["lane_revision"] = lone_commit

    PHASE = "running citation measurements"
    lone_baseline, _ = citations_run(lone_root, home)
    fleet_baseline, _ = citations_run(fleet_lane_root, home)
    lone_local = append_cite_and_run(lone_root, home, "corpus/nope-r25.md")
    fleet_local = append_cite_and_run(fleet_lane_root, home, "corpus/nope-r25.md")
    fleet_ufo_missing = append_cite_and_run(fleet_lane_root, home, ".ufo/waves/nope-r25.md")
    result["layouts"]["lone"]["citations"] = {
        "baseline": lone_baseline,
        "lane_local_broken_cite": lone_local,
    }
    result["layouts"]["fleet"]["citations"] = {
        "baseline": fleet_baseline,
        "lane_local_broken_cite": fleet_local,
        "missing_fleet_ufo_cite": fleet_ufo_missing,
    }

    PHASE = "selecting verify invocation"
    help_result = command_result(
        ["bash", "corpus/claim-ledger.sh", "--help"],
        lone_root,
        env=CLEAN_ENV,
        timeout=30,
    )
    help_text = help_result["stdout"] + "\n" + help_result["stderr"]
    id_filter = bool(re.search(r"(?:^|\s)--ids(?:\s|=|$)", help_text, flags=re.MULTILINE))
    result["verify_usage"] = {
        "help_exit": help_result["exit"],
        "id_filter_supported": id_filter,
    }
    verify_runs = []
    if id_filter:
        for layout_name, root in (("lone", lone_root), ("fleet", fleet_lane_root)):
            verify_runs.append(verify_record(
                root, home,
                ["timeout", "600s", "bash", "corpus/claim-ledger.sh", "verify", "--ids", "R11-08"],
                layout_name,
            ))
    else:
        verify_runs.append(verify_record(
            lone_root, home,
            ["timeout", "600s", "bash", "corpus/claim-ledger.sh", "verify"],
            "lone",
        ))
    result["verify"] = verify_runs

    checks = {
        "lone_lane_local_broken_cite_is_unresolved_exit_1": lone_local["ok"],
        "fleet_lane_local_broken_cite_is_unresolved_exit_1": fleet_local["ok"],
        "fleet_missing_ufo_cite_is_unresolved_exit_1": fleet_ufo_missing["ok"],
        "lone_marker_absent": lone_marker_absent,
        "all_cited_sibling_sources_cloned": not missing_sources and len(cloned_siblings) == len(cited_names),
        "fleet_baseline_citations_clean": fleet_baseline["exit"] == 0 and fleet_baseline["unresolved_total"] == 0 and fleet_baseline["fleet_absent_total"] == 0,
    }
    result["checks"] = checks
    result["checks_passed"] = all(checks.values())
    emit(result)
    return 0 if result["checks_passed"] else 1


if __name__ == "__main__":
    try:
        exit_code = main()
    except Exception as exc:
        emit({"phase": PHASE, "error": str(exc)})
        exit_code = 2
    raise SystemExit(exit_code)
PY
