#!/usr/bin/env python3
"""Generate the round-57 C1-checker mutants (scratch-only copies).

Each mutant is a byte copy of the frozen plans/round-57-c1-check.py at the
freeze revision with exactly one behaviour-bearing edit applied. A matching
runner copy of plans/round-57-c1.sh sits beside it (byte copy), so the copied
shell's REPO=$(dirname)/.. resolves to the mutant dir and CHECK points at the
mutant. A controls copy points C1 at that runner and REPO at the real lane.
No lane file is modified.
"""
from __future__ import annotations

import hashlib
import os
import shutil
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
S = "/fast/scratch/hyaku/kagi-r57/R57MutChecker"
FROZEN = os.path.join(S, "frozen", "plans")
CHECK = os.path.join(FROZEN, "round-57-c1-check.py")
C1 = os.path.join(FROZEN, "round-57-c1.sh")
CONTROLS = os.path.join(FROZEN, "round-57-controls.sh")

MUTANTS = {
    "M0": [],
    "M1": [("    value = bad if guard else \"FAIL\"",
            "    value = 0 if guard else \"FAIL\"  # M1: value ignores mismatches")],
    "M2": [("    guard = 1 if population >= 8 else 0",
            "    guard = 1 if population >= 0 else 0  # M2: floor 8 -> 0")],
    "M3": [("                        stmt(name, i, \"match\", stated, match_auth.get(L),\n"
            "                             f\"receipt-epoch{L}\")",
            "                        stmt(name, i, \"match\", stated, stated,  # M3: receipt authority ignored\n"
            "                             f\"receipt-epoch{L}\")")],
    "M4": [("                stmt(name, i, \"epochs\", stated if stated is not None else -1,\n"
            "                     epochs_auth, \"receipt-file-count\")",
            "                stmt(name, i, \"epochs\", stated if stated is not None else -1,\n"
            "                     stated if stated is not None else -1, \"receipt-file-count\")  # M4: epoch auth = stated")],
    "M5": [("    clocks_auth = manifest_rows(root)",
            "    clocks_auth = 10  # M5: clocks authority hardcoded to the true value")],
    "M6": [("                    for m in ms:\n"
            "                        before = line[: m.start()]\n"
            "                        letters = LETTER_REV_RE.findall(before)\n"
            "                        L = letters[-1] if letters else None\n"
            "                        stmt(name, i, \"match\", int(m.group(1)),\n"
            "                             match_auth.get(L) if L else None,\n"
            "                             f\"nearest-epoch{L or '-'}\")",
            "                    for m in ms:\n"
            "                        stmt(name, i, \"match\", int(m.group(1)),\n"
            "                             None, \"nearest-epoch-removed\")  # M6: pairing removed")],
    "M7": [("    if not sc or not lg or not ls:\n"
            "        print(\"CURRENT_CLAIMS: value=FAIL population=0 mismatches=0 unbound=0 \"\n"
            "              \"cases=0 match=0 epochs=0 clocks=0\")\n"
            "        return 1",
            "    if not sc or not lg or not ls:\n"
            "        print(\"CURRENT_CLAIMS: value=0 population=16 mismatches=0 unbound=0 \"\n"
            "              \"cases=0 match=0 epochs=0 clocks=0 guard=1\")  # M7: missing surface reads clean\n"
            "        return 0")],
    "M8": [("            pop_spans = []\n"
            "            for m in POP_RE.finditer(line):\n"
            "                pop_spans.append((m.start(), m.end()))\n"
            "                stmt(name, i, \"pop\", int(m.group(1)), clocks_auth, \"pop-size\")\n"
            "                stmt(name, i, \"pop\", int(m.group(2)), clocks_auth, \"pop-match\")",
            "            pop_spans = []\n"
            "            for m in POP_RE.finditer(line):\n"
            "                pop_spans.append((m.start(), m.end()))  # M8: N/N MATCH not counted as pop")],
    "M8b": [("            pop_spans = []\n"
             "            for m in POP_RE.finditer(line):\n"
             "                pop_spans.append((m.start(), m.end()))\n"
             "                stmt(name, i, \"pop\", int(m.group(1)), clocks_auth, \"pop-size\")\n"
             "                stmt(name, i, \"pop\", int(m.group(2)), clocks_auth, \"pop-match\")",
             "            pop_spans = []  # M8b: whole pop block deleted (fall-through probe)")],
    "M9": [("def selftest_cases(root: str) -> int | None:\n"
            "    gate = os.path.join(root, \"corpus\", \"recheck-replay.py\")",
            "def selftest_cases(root: str) -> int | None:\n"
            "    return 20  # M9: selftest case authority hardcoded\n"
            "    gate = os.path.join(root, \"corpus\", \"recheck-replay.py\")")],
    "M10": [("    value = bad if guard else \"FAIL\"",
             "    value = 0  # M10: population counted, value always 0")],
}

SHELL_MUTANTS = {
    "S0": [],
    "S2s": [("[ \"$P\" -ge 8 ] && [ \"$G\" = 1 ] && FLOOR=1",)],
}


def sha(path: str) -> str:
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def main() -> int:
    frozen_check = open(CHECK, encoding="utf-8", newline="").read()
    frozen_c1 = open(C1, encoding="utf-8", newline="").read()
    frozen_controls = open(CONTROLS, encoding="utf-8", newline="").read()
    os.makedirs(os.path.join(S, "mut"), exist_ok=True)
    os.makedirs(os.path.join(S, "bin"), exist_ok=True)
    manifest = []

    for name, edits in MUTANTS.items():
        text = frozen_check
        for old, new in edits:
            n = text.count(old)
            if n != 1:
                raise SystemExit(f"{name}: edit anchor count {n} != 1 for {old[:60]!r}")
            text = text.replace(old, new, 1)
        d = os.path.join(S, "mut", name, "plans")
        os.makedirs(d, exist_ok=True)
        ck = os.path.join(d, "round-57-c1-check.py")
        with open(ck, "w", encoding="utf-8", newline="") as f:
            f.write(text)
        with open(os.path.join(d, "round-57-c1.sh"), "w", encoding="utf-8", newline="") as f:
            f.write(frozen_c1)
        os.chmod(os.path.join(d, "round-57-c1.sh"), 0o755)
        manifest.append((name, "minimal", edits and edits[0][0][:48] or "none",
                         sha(CHECK), sha(ck)))

    # supplementary shell-floor mutant beside M2's runner
    for name, edits in SHELL_MUTANTS.items():
        text = frozen_c1
        for (old,) in edits:
            n = text.count(old)
            if n != 1:
                raise SystemExit(f"{name}: shell anchor count {n} != 1")
            text = text.replace(old, old.replace("-ge 8", "-ge 0"), 1)
        d = os.path.join(S, "mut", name, "plans")
        os.makedirs(d, exist_ok=True)
        # checker: pristine except M2's floor edit for S2s (double mutant later)
        with open(os.path.join(d, "round-57-c1.sh"), "w", encoding="utf-8", newline="") as f:
            f.write(text)
        os.chmod(os.path.join(d, "round-57-c1.sh"), 0o755)
        manifest.append((name, "shell-floor", "P -ge 8 -> -ge 0", sha(C1), sha(os.path.join(d, "round-57-c1.sh"))))

    # combined checker+shell floor mutant (M2 x S2s)
    d = os.path.join(S, "mut", "M2S2", "plans")
    os.makedirs(d, exist_ok=True)
    shutil.copyfile(os.path.join(S, "mut", "M2", "plans", "round-57-c1-check.py"),
                    os.path.join(d, "round-57-c1-check.py"))
    shutil.copyfile(os.path.join(S, "mut", "S2s", "plans", "round-57-c1.sh"),
                    os.path.join(d, "round-57-c1.sh"))
    os.chmod(os.path.join(d, "round-57-c1.sh"), 0o755)
    manifest.append(("M2S2", "double", "checker floor + shell floor", sha(CHECK),
                     sha(os.path.join(d, "round-57-c1-check.py"))))

    # controls copies: REPO fixed to the real lane, C1 pointed at each runner
    for name in list(MUTANTS) + ["S2s", "M2S2"]:
        text = frozen_controls
        old_repo = 'REPO=$(cd "$(dirname "$0")/.." && pwd -P)'
        if text.count(old_repo) != 1:
            raise SystemExit("controls REPO anchor not unique")
        text = text.replace(old_repo, f"REPO={os.path.join(S, 'frozen')}\nLANE={LANE}", 1)
        old_mk = 'git -C "$REPO" archive "$BASE"'
        if text.count(old_mk) != 1:
            raise SystemExit("controls mk_base anchor not unique")
        text = text.replace(old_mk, 'git -C "$LANE" archive "$BASE"', 1)
        old_c1 = 'C1="$REPO/plans/round-57-c1.sh"'
        if text.count(old_c1) != 1:
            raise SystemExit("controls C1 anchor not unique")
        text = text.replace(
            old_c1,
            f'C1={S}/mut/{name}/plans/round-57-c1.sh', 1)
        out = os.path.join(S, "bin", f"controls-{name}.sh")
        with open(out, "w", encoding="utf-8", newline="") as f:
            f.write(text)
        os.chmod(out, 0o755)
        manifest.append((f"controls-{name}", "controls-copy", f"C1->mut/{name}",
                         sha(CONTROLS), sha(out)))

    with open(os.path.join(S, "out", "mutant-manifest.tsv"), "w", encoding="utf-8") as f:
        f.write("name\tkind\tanchor\tfrozen_sha\tmutant_sha\n")
        for row in manifest:
            f.write("\t".join(row) + "\n")
    print("generated", len(manifest), "artifacts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
