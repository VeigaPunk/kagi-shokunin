#!/usr/bin/env python3
"""Red witness for M45-1 (stamp drift must be able to fail).

Reads corpus/stamps.tsv (columns: path, sha256, lines, bytes) under a
given root, recomputes sha256 of each path, prints
  STAMP_DRIFT: rows=N drift=D
plus one `DRIFT <path>` line per mismatch or missing file.
Exit 0 when D=0, else 1.
"""
import hashlib
import sys
from pathlib import Path


def sha256_of(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <root>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).resolve()
    stamps = root / "corpus" / "stamps.tsv"
    if not stamps.is_file():
        print(f"STAMP_DRIFT: missing {stamps}", file=sys.stderr)
        return 2
    rows = 0
    drift = 0
    drifts = []
    for raw in stamps.read_text(encoding="utf-8").splitlines():
        if not raw or raw.startswith("#"):
            continue
        parts = raw.split("\t")
        if len(parts) < 2:
            continue
        path_s, want = parts[0].strip(), parts[1].strip()
        rows += 1
        target = root / path_s
        if not target.is_file():
            drift += 1
            drifts.append(path_s)
            continue
        if sha256_of(target) != want.lower():
            drift += 1
            drifts.append(path_s)
    print(f"STAMP_DRIFT: rows={rows} drift={drift}")
    for p in drifts:
        print(f"DRIFT {p}")
    return 0 if drift == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
