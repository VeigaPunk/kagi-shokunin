#!/usr/bin/env python3
"""Declare the round-59 C1/C2 mutants as exact textual edits.

Writes one JSON spec per mutant under specs/ and validates every anchor against
the pristine fixture tree (exactly `count` occurrences). Idempotent.
"""
import json
import os
import sys

TREE = sys.argv[1]
OUT = sys.argv[2]
C1 = "plans/round-59-c1-check.py"
C2 = "plans/round-59-c2.sh"
TR = "corpus/openbao-transit-trial.sh"

M = {}


def add(mid, note, edits):
    M[mid] = {"id": mid, "note": note, "edits": edits}


add("M01", "C1: == flipped to != in item1's count comparison", [{
    "file": C1,
    "old": "    ok = (int(m.group(1)), int(m.group(2))) == (n_base, n_land)\n",
    "new": "    ok = (int(m.group(1)), int(m.group(2))) != (n_base, n_land)\n",
}])
add("M02", "C1: item2 returns FAIL unconditionally", [{
    "file": C1,
    "old": ('    det = f"fetches lesson first-int-after-name={stated} derived diff(+S lines)={delta}"\n'
            "    return (HOLD if stated == delta else FAIL), det\n"),
    "new": ('    det = f"fetches lesson first-int-after-name={stated} derived diff(+S lines)={delta}"\n'
            "    return FAIL, det\n"),
}])
add("M03", "C1: guard hardcoded 1 (challenge/stub legs no longer gate the value)", [{
    "file": C1,
    "old": "        guard = 1 if (population == POP and chal_ok is True and stub_fails is True) else 0\n",
    "new": "        guard = 1\n",
}])
add("M04", "C1: last_line() returns the first match (last-occurrence rule lost)", [{
    "file": C1,
    "old": ("def last_line(text: str | None, pred) -> str | None:\n"
            "    hit = None\n"
            "    for ln in (text.splitlines() if text else []):\n"
            "        if pred(ln):\n"
            "            hit = ln\n"
            "    return hit\n"),
    "new": ("def last_line(text: str | None, pred) -> str | None:\n"
            "    for ln in (text.splitlines() if text else []):\n"
            "        if pred(ln):\n"
            "            return ln\n"
            "    return None\n"),
}])
add("M05", "C1: I1 missing line defaults to the derived (target) pair", [{
    "file": C1,
    "old": ('    if line is None:\n'
            "        return FAIL, \"no 'Registry N → M at the candidate' line in the lesson\"\n"
            "    m = REGISTRY_LINE_RE.search(line)\n"
            "    n_base, n_land = derive_registry_counts(ctx)\n"),
    "new": ("    n_base, n_land = derive_registry_counts(ctx)\n"
            "    if line is None:\n"
            '        return HOLD, "registry line absent; defaulted to the derived pair"\n'
            "    m = REGISTRY_LINE_RE.search(line)\n"),
}])
add("M06", "C1: challenge copies the measured tree in place (QM74 lost)", [{
    "file": C1,
    "old": ('        copy = os.path.join(tmp, "tree")\n'
            "        shutil.copytree(root, copy, symlinks=True,\n"
            '                        ignore=shutil.ignore_patterns(".git", ".jj"))\n'
            "        if os.path.realpath(copy) == root_abs:\n"
            '            return None, None, "challenge copy resolves to the measured tree (refused)"\n'),
    "new": ("        copy = root\n"
            "        if os.path.realpath(copy) == root_abs and False:\n"
            '            return None, None, "challenge copy resolves to the measured tree (refused)"\n'),
}])
add("M07", "C1: an absent input line returns SKIP (population can shrink)", [{
    "file": C1,
    "old": ('    if line is None:\n'
            "        return FAIL, \"no 'Registry N → M at the candidate' line in the lesson\"\n"),
    "new": ('    if line is None:\n'
            "        return SKIP, \"no 'Registry N → M at the candidate' line in the lesson\"\n"),
}])
add("M08", "C1: I3(a) verifies only the total control count", [{
    "file": C1,
    "old": "    a_ok = line is not None and all(n in lesson_ints for n in (total, c1, c2))\n",
    "new": "    a_ok = line is not None and all(n in lesson_ints for n in (total,))\n",
}])
add("M09", "C1: internal printer-stub leg hardcoded to fail the stub", [{
    "file": C1,
    "old": "        stub_fails = not (isinstance(sv, int) and sv == expect)\n",
    "new": "        stub_fails = True\n",
}])

add("N01", "C2: shim-vector comparison removed (any vector with rc=1 counts)", [{
    "file": C2,
    "old": '  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] && shims_ok=$((shims_ok+1))\n',
    "new": '  [ "${RC[sh$n]}" = 1 ] && shims_ok=$((shims_ok+1))\n',
}])
add("N02", "C2: pass counter counts printed T-lines", [{
    "file": C2,
    "old": 'pass=0\n[ "$real_ok" = 1 ] && pass=5\n',
    "new": "pass=$(grep -cE '^TRIAL T[1-5] ' \"${OUT[real]}\")\n",
}])
add("N03", "C2: secret scan removed", [{
    "file": C2,
    "old": ('nosecret=1\n'
            "if cat \"$SCR\"/log/* 2>/dev/null | grep -qE 'r59-[0-9a-f]{24}|(^|[^A-Za-z0-9])(hvs|hvb)\\.'; then nosecret=0; fi\n"),
    "new": "nosecret=1\n",
}])
add("N04", "C2: real2 leg dropped (a single real run is accepted)", [{
    "file": C2,
    "old": ('real_ok=0; [ "${RC[real]}" = 0 ] && [ "${RC[real2]}" = 0 ] \\\n'
            '  && [ "$(vec "${OUT[real]}")" = HHHHH ] && [ "$(vec "${OUT[real2]}")" = HHHHH ] && real_ok=1\n'
            "grep -q '^OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0' \"${OUT[real]}\" || real_ok=0\n"
            "grep -q '^OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0' \"${OUT[real2]}\" || real_ok=0\n"),
    "new": ('real_ok=0; [ "${RC[real]}" = 0 ] \\\n'
            '  && [ "$(vec "${OUT[real]}")" = HHHHH ] && real_ok=1\n'
            "grep -q '^OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0' \"${OUT[real]}\" || real_ok=0\n"),
}])
add("N05", "C2: no-bao leg dropped from the conjunction", [{
    "file": C2,
    "old": ('none_ok=0\n'
            "[ \"${RC[none]}\" = 2 ] && ! grep -q 'HOLDS' \"${OUT[none]}\" && none_ok=1\n"),
    "new": "none_ok=1\n",
}])
add("N06", "C2: value hardcoded 5 once the trial exists", [{
    "file": C2,
    "old": ('pass=0\n[ "$real_ok" = 1 ] && pass=5\n'
            'value=0\n[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] && [ "$clean_ok" = 1 ] && value=5\n'),
    "new": "pass=5\nvalue=5\n",
}])
add("N07", "C2: clean-room verdict check removed (missing leg still passes)", [{
    "file": C2,
    "old": ('clean_ok=1\n'
            "for m in real real2; do\n"
            '  [ "$(verdict "${OUT[$m]}" CLEANROOM)" = HOLDS ] || clean_ok=0\n'
            "done\n"),
    "new": "clean_ok=1\n",
}])
add("N08", "C2 trial: clean-room leg reuses the first server and inverts the verdict", [{
    "file": TR,
    "old": ('  local baddr btok bsrv ok=1\n'
            '  start_server || { RVCR="CLEANROOM ERROR second-server-start=0"; export BAO_ADDR="$oa" BAO_TOKEN="$ot"; SRV="$os"; return; }\n'
            '  baddr="$BAO_ADDR"; btok="$BAO_TOKEN"; bsrv="$SRV"\n'
            '  BAO_ADDR="$baddr" BAO_TOKEN="$btok" bao secrets enable transit >/dev/null 2>"$D/err" || ok=0\n'
            '  if [ "$ok" = 1 ]; then\n'
            '    if printf \'{"ciphertext":"%s"}\' "$CT1" | BAO_ADDR="$baddr" BAO_TOKEN="$btok" bao write -format=json "transit/decrypt/$K1" - >/dev/null 2>"$D/err"; then\n'
            '      RVCR="CLEANROOM BROKEN own-storage-refused=0"\n'
            "    else\n"
            '      RVCR="CLEANROOM HOLDS own-storage-refused=1"\n'
            "    fi\n"
            "  else\n"
            '    RVCR="CLEANROOM ERROR second-transit-enable=0"\n'
            "  fi\n"
            '  kill "$bsrv" 2>/dev/null; wait "$bsrv" 2>/dev/null\n'),
    "new": ('  local baddr btok bsrv ok=1\n'
            '  baddr="$oa"; btok="$ot"; bsrv="$os"\n'
            '  if printf \'{"ciphertext":"%s"}\' "$CT1" | BAO_ADDR="$baddr" BAO_TOKEN="$btok" bao write -format=json "transit/decrypt/$K1" - >/dev/null 2>"$D/err"; then\n'
            '    RVCR="CLEANROOM HOLDS own-storage-refused=1"\n'
            "  else\n"
            '    RVCR="CLEANROOM BROKEN own-storage-refused=0"\n'
            "  fi\n"),
}])

add("N09", "C2: value fixed at 0 (do-nothing counter)", [{
    "file": C2,
    "old": ('value=0\n[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] && [ "$clean_ok" = 1 ] && value=5\n'),
    "new": "value=0\n",
}])

os.makedirs(OUT, exist_ok=True)
bad = 0
for mid in sorted(M):
    ok = True
    for e in M[mid]["edits"]:
        p = os.path.join(TREE, e["file"])
        s = open(p, encoding="utf-8").read()
        n = s.count(e["old"])
        if n != 1:
            print(f"{mid}: ANCHOR {n} != 1 in {e['file']} :: {e['old'][:70]!r}")
            ok = False
    if ok:
        with open(os.path.join(OUT, mid + ".json"), "w", encoding="utf-8") as f:
            json.dump(M[mid], f, indent=1, ensure_ascii=False)
        print(f"{mid}: spec ok")
    else:
        bad += 1
print(f"specs: {len(M) - bad}/{len(M)} valid")
sys.exit(1 if bad else 0)
