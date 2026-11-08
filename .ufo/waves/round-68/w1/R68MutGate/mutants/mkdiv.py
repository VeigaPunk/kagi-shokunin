#!/usr/bin/env python3
"""Divider-tree builder for the R68 mutation probe (scratch only).

usage: mkdiv.py SRC VARIANT OUT

Copies SRC (hardlinks) to OUT and applies VARIANT to the copy:
  wrongreason      gate emits `capture-token` where it emitted capture-digest-mismatch
                   (a wrong-reason gate for the M4 leg; selftest expectations move too)
  lowcount         gate --selftest PASS line reports 0 cases (exit 0, all cases run)
  prosefinding     gate prints a raw (uncounted) SC_CAPTURE finding for prose row S099
  normstub         S166 col13 -> non-locating text; rendered-text-v1.py replaced by a
                   stub whose locate always counts 1 and whose digest prints S166's col15
  no-anchor        delete the S166 row (derived anchor falls back to S156)
  no-anchor-164    delete the S166 and S164 rows (derived anchor still S156)
  drop-whitespace  delete the gate's capture-whitespace classifier block
  drop-normdigest  delete the gate's normalized-digest recompute block
  drop-cr          delete the gate's file-level cr-in-tsv check
Every substitution asserts it matched exactly once; a mutant that leaves the copy
byte-identical is a build error, never a pass.
"""
import os
import re
import shutil
import subprocess
import sys

src, variant, out = sys.argv[1], sys.argv[2], sys.argv[3]
if os.path.exists(out):
    shutil.rmtree(out)
subprocess.run(["cp", "-al", src, out], check=True)
gate = os.path.join(out, "corpus/sources-census.sh")
tsv = os.path.join(out, "corpus/source-fetches.tsv")


def edit(path, old, new, count=1):
    with open(path, "r", encoding="utf-8", newline="") as f:
        s = f.read()
    n = s.count(old)
    assert n == count, (path, n, old[:80])
    with open(path + ".x", "w", encoding="utf-8", newline="") as f:
        f.write(s.replace(old, new))
    os.replace(path + ".x", path)


if variant == "wrongreason":
    s = open(gate, encoding="utf-8", newline="").read()
    n = s.count("capture-digest-mismatch")
    assert n >= 2, ("wrongreason", n)
    open(gate + ".x", "w", encoding="utf-8", newline="").write(
        s.replace("capture-digest-mismatch", "capture-token"))
    os.replace(gate + ".x", gate)
elif variant == "lowcount":
    old = ("  if [[ $failed -eq 0 ]]; then printf 'SOURCES_CENSUS_SELFTEST: PASS (%d cases)\\n' \"$cases\"; exit 0; fi\n"
           "  printf 'SOURCES_CENSUS_SELFTEST: FAIL (%d cases, %d failed)\\n' \"$cases\" \"$failed\"; exit 1\n")
    new = "  printf 'SOURCES_CENSUS_SELFTEST: PASS (0 cases)\\n'; exit 0\n"
    edit(gate, old, new)
elif variant == "prosefinding":
    m = re.search(r"prose\) CAP_PROSE=\$\(\(CAP_PROSE \+ 1\)\); return 0 ;;", open(gate).read())
    assert m, "prose arm not found"
    edit(gate, m.group(0),
         "prose) [[ $id == S150 ]] && printf 'FINDING SC_CAPTURE id=S150 capture-token\\n'; "
         "CAP_PROSE=$((CAP_PROSE + 1)); return 0 ;;")
elif variant == "normwrap":
    # A normalizer that delegates to the trusted copy except for one sentinel
    # quote: the gate's own fixtures keep the real behaviour (selftest green),
    # while the tree's S166 garbage quote is made to "locate".
    real = "/fast/scratch/hyaku/kagi-r68/R68MutGate/base/corpus/rendered-text-v1.py"
    wrap = ("#!/usr/bin/env python3\n"
            "import subprocess, sys\n"
            "real = %r\n"
            "args = sys.argv[1:]\n"
            "if len(args) >= 3 and args[0] == 'locate' and 'zzz-guard-e-sentinel' in args[2]:\n"
            "    print('RENDERED_TEXT_V1_LOCATE: count=1'); sys.exit(0)\n"
            "sys.exit(subprocess.run([sys.executable, real] + args).returncode)\n" % real)
    npath = os.path.join(out, "corpus/rendered-text-v1.py")
    open(npath + ".new", "w").write(wrap)
    os.replace(npath + ".new", npath)
    with open(tsv, "r", encoding="utf-8", newline="") as f:
        text = f.read()
    lines = text.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("S166\t"):
            c = line.split("\t")
            c[12] = "zzz-guard-e-sentinel phrase that locates only under the wrapper"
            lines[i] = "\t".join(c)
            break
    else:
        raise SystemExit("S166 row absent")
    open(tsv + ".x", "w", encoding="utf-8", newline="").write("\n".join(lines))
    os.replace(tsv + ".x", tsv)
elif variant == "normstub":
    stub = ('#!/usr/bin/env python3\n'
            'import sys\n'
            'verb = sys.argv[1] if len(sys.argv) > 1 else ""\n'
            'if verb == "locate":\n'
            '    print("RENDERED_TEXT_V1_LOCATE: count=1")\n'
            'elif verb == "digest":\n'
            '    print("normalized_sha256=652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b")\n')
    npath = os.path.join(out, "corpus/rendered-text-v1.py")
    open(npath + ".new", "w").write(stub)
    os.replace(npath + ".new", npath)
    with open(tsv, "r", encoding="utf-8", newline="") as f:
        text = f.read()
    lines = text.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("S166\t"):
            c = line.split("\t")
            c[12] = "zzz phrase that locates in no body at all zzz"
            lines[i] = "\t".join(c)
            break
    else:
        raise SystemExit("S166 row absent")
    open(tsv + ".x", "w", encoding="utf-8", newline="").write("\n".join(lines))
    os.replace(tsv + ".x", tsv)
elif variant in ("no-anchor", "no-anchor-164"):
    with open(tsv, "r", encoding="utf-8", newline="") as f:
        text = f.read()
    lines = text.split("\n")
    drop = {"no-anchor": {"S166"}, "no-anchor-164": {"S166", "S164"}}[variant]
    new = [ln for ln in lines if ln.split("\t", 1)[0] not in drop]
    assert len(new) == len(lines) - len(drop), "row(s) absent"
    open(tsv + ".x", "w", encoding="utf-8", newline="").write("\n".join(new))
    os.replace(tsv + ".x", tsv)
elif variant == "drop-whitespace":
    old = ('  t=$(trim "$loc")\n'
           '  if [[ -n $t ]] && cap_is_shaped "$t" && [[ $loc != "$t" ]]; then\n'
           "    printf 'whitespace'; return 0\n"
           '  fi\n')
    edit(gate, old, "")
elif variant in ("drop-whitespace-clean", "drop-normdigest-clean", "drop-cr-clean"):
    def drop_block():
        old = ('  t=$(trim "$loc")\n'
               '  if [[ -n $t ]] && cap_is_shaped "$t" && [[ $loc != "$t" ]]; then\n'
               "    printf 'whitespace'; return 0\n"
               '  fi\n')
        edit(gate, old, "")
    def drop_line(marker):
        nonlocal_s = open(gate, encoding="utf-8", newline="").read()
        lines = nonlocal_s.split("\n")
        keep = [ln for ln in lines if marker not in ln]
        assert len(keep) == len(lines) - 1, (marker, len(lines) - len(keep))
        open(gate + ".x", "w", encoding="utf-8", newline="").write("\n".join(keep))
        os.replace(gate + ".x", gate)
    if variant == "drop-whitespace-clean":
        drop_block()
        drop_line('"capture-whitespace-space|')
        drop_line('"capture-whitespace-cr|')
    elif variant == "drop-normdigest-clean":
        old = ('  if [[ $norm == rendered-text-v1 ]]; then\n'
               '    normgot=$(cap_normalized_digest "$CAP_ROOT/$loc")\n'
               '    if [[ $normgot != "$nsha" ]]; then\n'
               '      finding SC_CAPTURE "id=$id normalized-digest-mismatch"; CAP_DEFECTS=$((CAP_DEFECTS + 1))\n'
               '    fi\n'
               '  fi\n')
        edit(gate, old, "")
        drop_line('"capture-normalized-mismatch|')
    else:
        old = ("    # round 68 (file-level): a CR byte anywhere disengages capture binding\n"
               "    if grep -q $'" + chr(92) + "r' -- \"$fetchf\" 2>/dev/null; then finding SC_FETCH \"cr-in-tsv\"; fi\n")
        edit(gate, old, "")
        drop_line('"fetch-cr-in-tsv|')
        # the CRLF capture-whitespace case counted the file-level finding too
        s2 = open(gate, encoding="utf-8", newline="").read()
        old2 = '|SC_CAPTURE|2|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-whitespace"'
        new2 = '|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-whitespace"'
        assert s2.count(old2) == 1, s2.count(old2)
        open(gate + ".x", "w", encoding="utf-8", newline="").write(s2.replace(old2, new2))
        os.replace(gate + ".x", gate)
elif variant == "drop-normdigest":
    s = open(gate).read()
    m = re.search(r"\n  if \[\[ \$norm == rendered-text-v1 \]\]; then\n"
                  r"    normgot=\$\(cap_normalized_digest \"\$CAP_ROOT/\$loc\"\)\n"
                  r"    if \[\[ \$normgot != \"\$nsha\" \]\]; then\n"
                  r"      finding SC_CAPTURE \"id=\$id normalized-digest-mismatch\"; CAP_DEFECTS=\$\(\(CAP_DEFECTS \+ 1\)\)\n"
                  r"    fi\n"
                  r"  fi\n", s)
    assert m, "normalized-digest block not found"
    edit(gate, m.group(0), "\n")
elif variant == "drop-cr":
    old = ("    # round 68 (file-level): a CR byte anywhere disengages capture binding\n"
           "    if grep -q $'" + chr(92) + "r' -- \"$fetchf\" 2>/dev/null; then finding SC_FETCH \"cr-in-tsv\"; fi\n")
    edit(gate, old, "")
else:
    raise SystemExit("unknown variant " + variant)

print("MKDIV: %s -> %s ok" % (variant, out))
