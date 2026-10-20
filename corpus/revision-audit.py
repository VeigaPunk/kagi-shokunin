#!/usr/bin/env python3
"""Read-only audit of stamps against current worktree files and immutable history."""

from __future__ import annotations

import argparse
import errno
import hashlib
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Iterable

STAMP_PATH = "corpus/stamps.tsv"
HEX_DIGEST = re.compile(r"[0-9a-f]{64}\Z")
FULL_OID = re.compile(r"(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\Z")
DECIMAL = re.compile(r"(?:0|[1-9][0-9]*)\Z")
SAFE_PATH = re.compile(r"[A-Za-z0-9._+/-]+\Z")
MAX_STAMPS_BYTES = 8 * 1024 * 1024


class ReadFailure(Exception):
    def __init__(self, finding: str):
        super().__init__(finding)
        self.finding = finding


class AuditResult:
    def __init__(self, exit_code: int, findings: Iterable[tuple[str, str]], counts: dict[str, int]):
        self.exit_code = exit_code
        self.findings = list(findings)
        self.counts = counts


def git_env() -> dict[str, str]:
    env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
    env["GIT_OPTIONAL_LOCKS"] = "0"
    env["GIT_CONFIG_NOSYSTEM"] = "1"
    env["GIT_CONFIG_GLOBAL"] = os.devnull
    env["GIT_NO_LAZY_FETCH"] = "1"
    env["GIT_NO_REPLACE_OBJECTS"] = "1"
    env["LC_ALL"] = "C"
    return env


def git_read(root: Path, args: list[str]) -> bytes | None:
    try:
        result = subprocess.run(
            ["git", "-C", os.fspath(root), *args],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            env=git_env(),
            check=False,
        )
    except OSError:
        return None
    if result.returncode != 0:
        return None
    return result.stdout


def parse_path(path: str) -> str | None:
    """Return PATH-ESCAPE for traversal forms, otherwise MALFORMED for invalid names."""
    if (
        path.startswith("/")
        or path.startswith("\\")
        or "\\" in path
        or re.match(r"[A-Za-z]:", path)
        or any(part in (".", "..") for part in path.split("/"))
    ):
        return "PATH-ESCAPE"
    if not path or not SAFE_PATH.fullmatch(path):
        return "MALFORMED"
    if any(not part for part in path.split("/")):
        return "MALFORMED"
    return None


def parse_stamps(data: bytes, history: bool = False) -> tuple[dict[str, tuple[str, int, int]] | None, list[tuple[str, str]]]:
    prefix = "HISTORY-" if history else ""
    findings: list[tuple[str, str]] = []
    if not data:
        return None, [(prefix + "EMPTY", "")]

    lines = data.split(b"\n")
    if lines[-1] == b"":
        lines.pop()
    records: dict[str, tuple[str, int, int]] = {}

    for number, raw_line in enumerate(lines, 1):
        line_id = str(number)
        if (
            not raw_line
            or b"\r" in raw_line
            or any(byte < 32 and byte != 9 for byte in raw_line)
            or any(byte == 127 for byte in raw_line)
        ):
            findings.append((prefix + "MALFORMED-LINE", line_id))
            continue
        try:
            line = raw_line.decode("ascii")
        except UnicodeDecodeError:
            findings.append((prefix + "MALFORMED-LINE", line_id))
            continue
        fields = line.split("\t")
        if len(fields) != 4:
            findings.append((prefix + "MALFORMED-LINE", line_id))
            continue
        path, digest, lines_text, bytes_text = fields
        path_error = parse_path(path)
        if path_error == "PATH-ESCAPE":
            findings.append((prefix + "PATH-ESCAPE", line_id))
            continue
        if (
            path_error is not None
            or not HEX_DIGEST.fullmatch(digest)
            or not DECIMAL.fullmatch(lines_text)
            or not DECIMAL.fullmatch(bytes_text)
            or len(lines_text) > 20
            or len(bytes_text) > 20
        ):
            findings.append((prefix + "MALFORMED-LINE", line_id))
            continue
        if path in records:
            findings.append((prefix + "DUPLICATE", path))
            continue
        try:
            records[path] = (digest, int(lines_text), int(bytes_text))
        except ValueError:
            findings.append((prefix + "MALFORMED-LINE", line_id))

    if findings:
        return None, findings
    return records, []


def open_regular_at(root_fd: int, path: str, root_device: int) -> int:
    """Open a worktree path without following symlink components or crossing devices."""
    parts = path.split("/")
    directory_fd = os.dup(root_fd)
    try:
        for part in parts[:-1]:
            try:
                next_fd = os.open(
                    part,
                    os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                    dir_fd=directory_fd,
                )
            except FileNotFoundError:
                raise ReadFailure("MISSING") from None
            except OSError as error:
                if error.errno in (errno.ELOOP, errno.ENOTDIR):
                    try:
                        info = os.stat(part, dir_fd=directory_fd, follow_symlinks=False)
                    except FileNotFoundError:
                        raise ReadFailure("MISSING") from None
                    except OSError:
                        raise ReadFailure("READ-ERROR") from None
                    if stat.S_ISLNK(info.st_mode):
                        raise ReadFailure("PATH-ESCAPE") from None
                    raise ReadFailure("NOT-FILE") from None
                raise ReadFailure("READ-ERROR") from None
            info = os.fstat(next_fd)
            if info.st_dev != root_device:
                os.close(next_fd)
                raise ReadFailure("PATH-ESCAPE")
            os.close(directory_fd)
            directory_fd = next_fd

        try:
            file_fd = os.open(
                parts[-1],
                os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
                dir_fd=directory_fd,
            )
        except FileNotFoundError:
            raise ReadFailure("MISSING") from None
        except OSError as error:
            if error.errno in (errno.ELOOP, errno.ENOTDIR):
                try:
                    info = os.stat(parts[-1], dir_fd=directory_fd, follow_symlinks=False)
                except FileNotFoundError:
                    raise ReadFailure("MISSING") from None
                except OSError:
                    raise ReadFailure("READ-ERROR") from None
                if stat.S_ISLNK(info.st_mode):
                    raise ReadFailure("PATH-ESCAPE") from None
                raise ReadFailure("NOT-FILE") from None
            raise ReadFailure("READ-ERROR") from None
        info = os.fstat(file_fd)
        if not stat.S_ISREG(info.st_mode):
            os.close(file_fd)
            raise ReadFailure("NOT-FILE")
        if info.st_dev != root_device:
            os.close(file_fd)
            raise ReadFailure("PATH-ESCAPE")
        return file_fd
    finally:
        os.close(directory_fd)


def fingerprint_fd(file_fd: int) -> tuple[str, int, int]:
    digest = hashlib.sha256()
    line_count = 0
    byte_count = 0
    while True:
        chunk = os.read(file_fd, 65536)
        if not chunk:
            break
        digest.update(chunk)
        line_count += chunk.count(b"\n")
        byte_count += len(chunk)
    return digest.hexdigest(), line_count, byte_count


def read_bytes_at(root_fd: int, path: str, root_device: int, limit: int) -> bytes:
    file_fd = open_regular_at(root_fd, path, root_device)
    try:
        chunks: list[bytes] = []
        size = 0
        while True:
            chunk = os.read(file_fd, min(65536, limit + 1 - size))
            if not chunk:
                break
            size += len(chunk)
            if size > limit:
                raise ReadFailure("TOO-LARGE")
            chunks.append(chunk)
        return b"".join(chunks)
    finally:
        os.close(file_fd)


def history_tree(root: Path, oid: str) -> tuple[set[bytes] | None, str | None]:
    output = git_read(root, ["ls-tree", "-rz", "-r", "--full-tree", oid])
    if output is None or (output and not output.endswith(b"\0")):
        return None, "HISTORY-UNAVAILABLE"
    regular: set[bytes] = set()
    for entry in output.split(b"\0")[:-1]:
        try:
            metadata, path = entry.split(b"\t", 1)
            mode, object_type, _object_id = metadata.split(b" ", 2)
        except ValueError:
            return None, "HISTORY-UNAVAILABLE"
        if object_type == b"blob" and mode in (b"100644", b"100755"):
            regular.add(path)
    return regular, None


def parse_history(root: Path, history_arg: str) -> tuple[bytes | None, set[bytes] | None, str | None]:
    if not FULL_OID.fullmatch(history_arg):
        return None, None, "HISTORY-INVALID"
    oid = history_arg.lower()
    if git_read(root, ["cat-file", "-t", oid]) != b"commit\n":
        return None, None, "HISTORY-UNAVAILABLE"
    history_files, tree_error = history_tree(root, oid)
    if tree_error is not None or history_files is None:
        return None, None, tree_error or "HISTORY-UNAVAILABLE"
    if STAMP_PATH.encode("ascii") not in history_files:
        return None, None, "HISTORY-UNAVAILABLE"
    stamp_blob = git_read(root, ["cat-file", "blob", oid + ":" + STAMP_PATH])
    if stamp_blob is None:
        return None, None, "HISTORY-UNAVAILABLE"
    return stamp_blob, history_files, None


def finding_order(finding: tuple[str, str]) -> tuple[int, str, str]:
    order = {
        "STALE": 0,
        "MISSING": 1,
        "DROPPED": 2,
        "ADDED": 3,
        "PATH-ESCAPE": 4,
        "NOT-FILE": 5,
        "READ-ERROR": 6,
        "MALFORMED-LINE": 7,
        "HISTORY-MALFORMED-LINE": 8,
        "DUPLICATE": 9,
        "HISTORY-DUPLICATE": 10,
        "EMPTY": 11,
        "HISTORY-EMPTY": 12,
        "TOO-LARGE": 13,
        "HISTORY-NOT-TRACKED": 14,
        "HISTORY-INVALID": 15,
        "HISTORY-UNAVAILABLE": 16,
        "ROOT-INVALID": 17,
        "ROOT-NOT-REPOSITORY": 18,
        "GIT-ERROR": 19,
    }
    kind, identifier = finding
    return order.get(kind, 99), identifier, kind


def make_result(exit_code: int, findings: Iterable[tuple[str, str]]) -> AuditResult:
    all_findings = sorted(findings, key=finding_order)
    counts = {key: 0 for key in ("stale", "missing", "dropped", "added", "invalid")}
    for kind, _identifier in all_findings:
        if kind == "STALE":
            counts["stale"] += 1
        elif kind == "MISSING":
            counts["missing"] += 1
        elif kind == "DROPPED":
            counts["dropped"] += 1
        elif kind == "ADDED":
            counts["added"] += 1
        else:
            counts["invalid"] += 1
    return AuditResult(exit_code, all_findings, counts)


def audit(root_arg: str | os.PathLike[str] | None, history_arg: str) -> AuditResult:
    if not FULL_OID.fullmatch(history_arg):
        return make_result(2, [("HISTORY-INVALID", "")])
    try:
        root = Path(root_arg).resolve(strict=True) if root_arg is not None else Path(__file__).resolve().parent.parent
        if not root.is_dir():
            return make_result(2, [("ROOT-INVALID", "")])
    except (OSError, RuntimeError, TypeError):
        return make_result(2, [("ROOT-INVALID", "")])

    prefix = git_read(root, ["rev-parse", "--show-prefix"])
    if prefix is None or prefix.strip():
        return make_result(2, [("ROOT-NOT-REPOSITORY", "")])
    history_bytes, history_files, history_error = parse_history(root, history_arg)
    if history_error is not None or history_bytes is None or history_files is None:
        return make_result(2, [(history_error or "HISTORY-UNAVAILABLE", "")])

    try:
        root_fd = os.open(os.fspath(root), os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    except OSError:
        return make_result(2, [("ROOT-INVALID", "")])
    try:
        root_device = os.fstat(root_fd).st_dev
        try:
            current_bytes = read_bytes_at(root_fd, STAMP_PATH, root_device, MAX_STAMPS_BYTES)
        except ReadFailure as error:
            return make_result(2, [(error.finding, STAMP_PATH)])

        current_rows, current_errors = parse_stamps(current_bytes)
        history_rows, history_errors = parse_stamps(history_bytes, history=True)
        findings = current_errors + history_errors
        if current_rows is None or history_rows is None:
            return make_result(2, findings)

        for path in history_rows:
            if path.encode("ascii") not in history_files:
                findings.append(("HISTORY-NOT-TRACKED", path))
        if findings:
            return make_result(2, findings)

        current_members = set(current_rows)
        history_members = set(history_rows)
        for path in sorted(history_members - current_members):
            findings.append(("DROPPED", path))
        for path in sorted(current_members - history_members):
            findings.append(("ADDED", path))

        for path, expected in current_rows.items():
            try:
                file_fd = open_regular_at(root_fd, path, root_device)
            except ReadFailure as error:
                findings.append((error.finding, path))
                continue
            try:
                actual = fingerprint_fd(file_fd)
            except OSError:
                findings.append(("READ-ERROR", path))
                continue
            finally:
                os.close(file_fd)
            if actual != expected:
                findings.append(("STALE", path))
    finally:
        os.close(root_fd)

    exit_code = 1 if any(kind in ("STALE", "MISSING", "DROPPED") for kind, _ in findings) else 0
    if any(kind not in ("STALE", "MISSING", "DROPPED", "ADDED") for kind, _ in findings):
        exit_code = 2
    return make_result(exit_code, findings)


def print_result(result: AuditResult) -> None:
    for kind, identifier in result.findings:
        print(kind if not identifier else f"{kind} {identifier}")
    counts = result.counts
    if result.exit_code == 0:
        verdict = "CLEAN"
    elif result.exit_code == 1:
        verdict = "DRIFT"
    else:
        verdict = "SETUP"
    print(
        "REVISION_AUDIT: "
        f"{verdict} (stale={counts['stale']} missing={counts['missing']} "
        f"dropped={counts['dropped']} added={counts['added']} invalid={counts['invalid']})"
    )


def stamp_line(path: str, data: bytes) -> bytes:
    line_count = data.count(b"\n")
    return f"{path}\t{hashlib.sha256(data).hexdigest()}\t{line_count}\t{len(data)}\n".encode("ascii")


def fixture_git(root: Path, *args: str) -> bytes | None:
    return git_read(root, list(args))


def selftest() -> int:
    cases = 0
    failed = 0

    def check(name: str, expected_exit: int, expected_finding: str | None, result: AuditResult) -> None:
        nonlocal cases, failed
        cases += 1
        if expected_finding is None:
            matched = not result.findings
        else:
            actual = [kind if not identifier else f"{kind} {identifier}" for kind, identifier in result.findings]
            matched = expected_finding in actual
        if result.exit_code == expected_exit and matched:
            finding = expected_finding or "NONE"
            print(f"SELFTEST_CASE: PASS (name={name} exit={expected_exit} finding={finding})")
        else:
            failed += 1
            finding = expected_finding or "NONE"
            print(f"SELFTEST_CASE: FAIL (name={name} expected_exit={expected_exit} expected_finding={finding})")

    with tempfile.TemporaryDirectory(prefix="revision-audit-") as temporary:
        base = Path(temporary)
        root = base / "repo"
        root.mkdir()
        (root / "corpus").mkdir()
        keep = b"keep\n"
        drop = b"drop\n"
        original_stamps = stamp_line("corpus/keep.txt", keep) + stamp_line("corpus/drop.txt", drop)
        (root / "corpus" / "keep.txt").write_bytes(keep)
        (root / "corpus" / "drop.txt").write_bytes(drop)
        (root / STAMP_PATH).write_bytes(original_stamps)

        if fixture_git(root, "init", "-q") is None:
            print("REVISION_AUDIT_SELFTEST: FAIL (cases=0 failed=1)")
            return 1
        if fixture_git(root, "add", "--", STAMP_PATH, "corpus/keep.txt", "corpus/drop.txt") is None:
            print("REVISION_AUDIT_SELFTEST: FAIL (cases=0 failed=1)")
            return 1
        if fixture_git(
            root,
            "-c", "core.hooksPath=/dev/null",
            "-c", "user.name=revision-audit-fixture",
            "-c", "user.email=revision-audit-fixture@example.invalid",
            "commit", "-q", "-m", "fixture",
        ) is None:
            print("REVISION_AUDIT_SELFTEST: FAIL (cases=0 failed=1)")
            return 1
        history_bytes = fixture_git(root, "rev-parse", "HEAD")
        if history_bytes is None:
            print("REVISION_AUDIT_SELFTEST: FAIL (cases=0 failed=1)")
            return 1
        history = history_bytes.decode("ascii").strip()

        check("clean-control", 0, None, audit(root, history))

        duplicate_history_stamps = stamp_line("corpus/keep.txt", keep) * 2
        (root / STAMP_PATH).write_bytes(duplicate_history_stamps)
        if fixture_git(root, "add", "--", STAMP_PATH) is None or fixture_git(
            root,
            "-c", "core.hooksPath=/dev/null",
            "-c", "user.name=revision-audit-fixture",
            "-c", "user.email=revision-audit-fixture@example.invalid",
            "commit", "-q", "-m", "duplicate-history-fixture",
        ) is None:
            print("REVISION_AUDIT_SELFTEST: FAIL (cases=1 failed=1)")
            return 1
        duplicate_history_bytes = fixture_git(root, "rev-parse", "HEAD")
        if duplicate_history_bytes is None:
            print("REVISION_AUDIT_SELFTEST: FAIL (cases=1 failed=1)")
            return 1
        duplicate_history = duplicate_history_bytes.decode("ascii").strip()
        (root / STAMP_PATH).write_bytes(original_stamps)
        check("duplicate-history-id", 2, "HISTORY-DUPLICATE corpus/keep.txt", audit(root, duplicate_history))

        (root / STAMP_PATH).write_bytes(stamp_line("corpus/keep.txt", keep))
        check("dropped-member", 1, "DROPPED corpus/drop.txt", audit(root, history))

        (root / STAMP_PATH).write_bytes(original_stamps)
        (root / "corpus" / "keep.txt").write_bytes(b"changed\n")
        check("modified-worktree-stale", 1, "STALE corpus/keep.txt", audit(root, history))

        (root / "corpus" / "keep.txt").unlink()
        check("missing-file", 1, "MISSING corpus/keep.txt", audit(root, history))

        (root / STAMP_PATH).write_bytes(b"malformed\n")
        check("malformed-current-row", 2, "MALFORMED-LINE 1", audit(root, history))

        row = stamp_line("corpus/drop.txt", drop)
        (root / STAMP_PATH).write_bytes(row + row)
        check("duplicate-current-id", 2, "DUPLICATE corpus/drop.txt", audit(root, history))

        (root / STAMP_PATH).write_bytes(stamp_line("../outside", keep))
        check("path-traversal", 2, "PATH-ESCAPE 1", audit(root, history))

        outside = base / "outside"
        outside.mkdir()
        (outside / "sentinel.txt").write_bytes(b"fixture-only\n")
        (root / "corpus" / "linked").symlink_to(outside, target_is_directory=True)
        (root / STAMP_PATH).write_bytes(stamp_line("corpus/linked/sentinel.txt", b"fixture-only\n"))
        check("parent-symlink", 2, "PATH-ESCAPE corpus/linked/sentinel.txt", audit(root, history))

        os.mkfifo(root / "corpus" / "fifo")
        (root / STAMP_PATH).write_bytes(stamp_line("corpus/fifo", b"fixture-only\n"))
        check("fifo-not-file", 2, "NOT-FILE corpus/fifo", audit(root, history))

        check("option-history", 2, "HISTORY-INVALID", audit(root, "--output=fixture"))

    verdict = "PASS" if failed == 0 else "FAIL"
    print(f"REVISION_AUDIT_SELFTEST: {verdict} (cases={cases} failed={failed})")
    return 0 if failed == 0 else 1


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="revision-audit.py", description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--history", help="full hexadecimal commit id to compare stamp membership")
    mode.add_argument("--selftest", action="store_true", help="run isolated fixture cases only")
    parser.add_argument("--root", help="repository root (defaults to this script's repository)")
    args = parser.parse_args(argv)

    if args.selftest:
        if args.root is not None:
            print("ROOT-INVALID")
            return 2
        return selftest()
    if args.history is None:
        parser.print_usage(sys.stderr)
        print("HISTORY-INVALID", file=sys.stderr)
        return 2
    result = audit(args.root, args.history)
    print_result(result)
    return result.exit_code


if __name__ == "__main__":
    raise SystemExit(main())
