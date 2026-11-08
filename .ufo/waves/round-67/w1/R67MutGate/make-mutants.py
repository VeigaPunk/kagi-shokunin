#!/usr/bin/env python3
"""make-mutants.py PRISTINE OUTDIR — seven census mutants, one-point each."""
import hashlib
import os
import sys

src_path, outdir = sys.argv[1], sys.argv[2]
src = open(src_path, encoding="utf-8").read()
os.makedirs(outdir, exist_ok=True)


def one(old, new, text, label):
    n = text.count(old)
    assert n == 1, f"{label}: anchor count {n}"
    return text.replace(old, new)


def span(text, start_marker, end_marker, label):
    a = text.index(start_marker)
    b = text.index(end_marker, a)
    return a, b


mutants = {}

start, end = span(src, "cap_row() { # id sha bytes quote norm loc",
                  "\nverify() {", "M1 span")
m1_body = """cap_row() { # id sha bytes quote norm loc
  local id=$1 sha=$2 bytes=$3 quote=$4 norm=$5 loc=$6
  if ! cap_is_shaped "$loc"; then CAP_PROSE=$((CAP_PROSE + 1)); return 0; fi
  CAP_PATH=$((CAP_PATH + 1))
  [[ ${#loc} -ge 8 ]] || { finding SC_CAPTURE "id=$id capture-missing"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); return 0; }
  CAP_BOUND=$((CAP_BOUND + 1))
  CAP_LOCATED=$((CAP_LOCATED + 1))
}
"""
mutants["M1-length-only"] = src[:start] + m1_body + src[end:]

m2 = one('''  size=$(stat -Lc %s -- "$CAP_ROOT/$loc" 2>/dev/null) || size=""
  got=$(sha256sum -- "$CAP_ROOT/$loc" 2>/dev/null); got=${got%% *}
''', '''  size=$(stat -Lc %s -- "$CAP_ROOT/$loc" 2>/dev/null) || size=""
''', src, "M2 stat")
m2 = one('''  if [[ $got != "$sha" ]]; then
    finding SC_CAPTURE "id=$id capture-digest-mismatch"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); bad=1
  fi
''', "", m2, "M2 digest block")
mutants["M2-size-only"] = m2

m3 = one('''  if [[ -z $q ]] || ! cap_locate "$CAP_ROOT/$loc" "$quote" "$norm"; then''',
         '''  if [[ -z $q ]]; then''', src, "M3 locate condition")
mutants["M3-quote-nonempty"] = m3

m4 = one('''    printf 'SOURCES_CAPTURES: CLEAN (path_rows=%d bound=%d located=%d prose=%d)\\n' \\
      "$CAP_PATH" "$CAP_BOUND" "$CAP_LOCATED" "$CAP_PROSE"''',
         '''    printf 'SOURCES_CAPTURES: CLEAN (path_rows=%d bound=36 located=36 prose=%d)\\n' \\
      "$CAP_PATH" "$CAP_PROSE"''', src, "M4 clean printf")
m4 = one('''    printf 'SOURCES_CAPTURES: FAILED (defects=%d path_rows=%d bound=%d located=%d prose=%d)\\n' \\
      "$CAP_DEFECTS" "$CAP_PATH" "$CAP_BOUND" "$CAP_LOCATED" "$CAP_PROSE"''',
         '''    printf 'SOURCES_CAPTURES: FAILED (defects=%d path_rows=%d bound=36 located=36 prose=%d)\\n' \\
      "$CAP_DEFECTS" "$CAP_PATH" "$CAP_PROSE"''', m4, "M4 failed printf")
mutants["M4-constant-counts"] = m4

m5 = one('''  if ! cap_is_shaped "$loc"; then CAP_PROSE=$((CAP_PROSE + 1)); return 0; fi
''', "", src, "M5 prose skip")
mutants["M5-prose-as-paths"] = m5

m6 = one('''  printf 'SOURCES_CENSUS: FAILED (findings=%d rows=%d)\\n' "$FINDINGS" "$rows"
  exit 1''',
         '''  printf 'SOURCES_CENSUS: FAILED (findings=%d rows=%d)\\n' "$FINDINGS" "$rows"
  [[ $CAP_DEFECTS -gt 0 ]] && exit 0
  exit 1''', src, "M6 exit")
mutants["M6-exit-zero-on-capture"] = m6

m7 = one('''  # absolute locations never satisfy "repo-relative", whatever they name
  if [[ $loc == /* ]]; then
    finding SC_CAPTURE "id=$id capture-outside-root"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); return 0
  fi
''', "", src, "M7 absolute block")
m7 = one('''  if [[ -z $rp || ( $rp != "$CAP_ROOT" && $rp != "$CAP_ROOT"/* ) ]]; then''',
         '''  if [[ -z $rp ]]; then''', m7, "M7 containment")
mutants["M7-no-containment"] = m7

os.makedirs(os.path.join(outdir, "diffs"), exist_ok=True)
open(os.path.join(outdir, "pristine.sh"), "w", encoding="utf-8").write(src)
print("pristine", hashlib.sha256(src.encode()).hexdigest(), len(src.splitlines()), "lines")
for name, text in mutants.items():
    assert text != src, f"{name}: mutation inert"
    p = os.path.join(outdir, name + ".sh")
    open(p, "w", encoding="utf-8").write(text)
    os.chmod(p, 0o755)
    print(name, hashlib.sha256(text.encode()).hexdigest())
