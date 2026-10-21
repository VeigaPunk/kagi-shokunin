#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'usage: %s [--mutate ID] <tool-rev> <docs-rev> <label>\n' "${BASH_SOURCE[0]}" >&2
  exit 64
}

positional=()
mutate_id=''
while (($#)); do
  case "$1" in
    --mutate)
      (($# >= 2)) || usage
      [[ -z $mutate_id && -n $2 ]] || usage
      mutate_id=$2
      shift 2
      ;;
    --)
      shift
      while (($#)); do
        positional+=("$1")
        shift
      done
      ;;
    -* )
      usage
      ;;
    *)
      positional+=("$1")
      shift
      ;;
  esac
done

[[ ${#positional[@]} -eq 3 ]] || usage
tool_rev=${positional[0]}
docs_rev=${positional[1]}
label=${positional[2]}
[[ $label =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || usage

script_path=${BASH_SOURCE[0]}
[[ $script_path == /* ]] || script_path="$PWD/$script_path"
script_dir=${script_path%/*}
if ! repo_root=$(git -C "$script_dir/../../../.." rev-parse --show-toplevel 2>/dev/null); then
  printf 'c1-measure: cannot resolve repository root from %s\n' "$script_path" >&2
  exit 2
fi
if ! tool_commit=$(git -C "$repo_root" rev-parse --verify --end-of-options "${tool_rev}^{commit}" 2>/dev/null); then
  printf 'c1-measure: invalid tool revision: %s\n' "$tool_rev" >&2
  exit 2
fi
if ! docs_commit=$(git -C "$repo_root" rev-parse --verify --end-of-options "${docs_rev}^{commit}" 2>/dev/null); then
  printf 'c1-measure: invalid docs revision: %s\n' "$docs_rev" >&2
  exit 2
fi
for file in corpus/self-counts.py corpus/self-counts.tsv; do
  if ! git -C "$repo_root" cat-file -e "$tool_commit:$file" 2>/dev/null; then
    printf 'c1-measure: %s absent at tool revision %s\n' "$file" "$tool_commit" >&2
    exit 2
  fi
done

scratch_parent=/fast/scratch/kagi-r25/XMeasureC1
scratch=$scratch_parent/$label
if ! python3 - "$scratch_parent" "$scratch" <<'PY'
import os
import sys

parent, destination = sys.argv[1:]
os.makedirs(parent, exist_ok=True)
os.mkdir(destination)
PY
then
  printf 'c1-measure: scratch label already exists or cannot be created: %s\n' "$scratch" >&2
  exit 2
fi

git clone -q --no-hardlinks "$repo_root" "$scratch"
git -C "$scratch" checkout -q "$docs_commit"
git -C "$scratch" show "$tool_commit:corpus/self-counts.py" > "$scratch/corpus/self-counts.py"
git -C "$scratch" show "$tool_commit:corpus/self-counts.tsv" > "$scratch/corpus/self-counts.tsv"

run_tool() {
  local emit=${1:-1}
  local output_file="$scratch/.c1-measure-output"
  local status=0
  local summary='' line stale=unknown claims=unknown raw=''

  if (cd "$scratch" && env -i PATH=/usr/bin:/bin HOME="$scratch" python3 corpus/self-counts.py) > "$output_file" 2>&1; then
    status=0
  else
    status=$?
  fi
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line == SELF_COUNTS:* ]]; then
      summary=$line
    fi
  done < "$output_file"
  if [[ $summary =~ claims=([0-9]+) ]]; then
    claims=${BASH_REMATCH[1]}
  fi
  if [[ $summary =~ stale=([0-9]+) ]]; then
    stale=${BASH_REMATCH[1]}
  fi
  if ((emit)); then
    printf 'C1_MEASURE label=%s tool_rev=%s docs_rev=%s exit=%s stale=%s claims=%s\n' \
      "$label" "$tool_commit" "$docs_commit" "$status" "$stale" "$claims"
    IFS= read -r -d '' raw < "$output_file" || true
    printf '%s' "$raw"
    if [[ -n $raw && $raw != *$'\n' ]]; then
      printf '\n'
    fi
  fi
  return "$status"
}

if [[ -n $mutate_id ]]; then
  baseline_status=0
  if run_tool 0; then
    baseline_status=0
  else
    baseline_status=$?
  fi
  if ((baseline_status > 1)); then
    printf 'c1-measure: baseline tool run failed with exit %s; not mutating\n' "$baseline_status" >&2
    exit "$baseline_status"
  fi
  if ! (cd "$scratch" && env -i PATH=/usr/bin:/bin HOME="$scratch" python3 - "$scratch" "$mutate_id" <<'PY'
import csv
import os
import re
import sys

root = os.path.realpath(sys.argv[1])
row_id = sys.argv[2]
table = os.path.join(root, "corpus", "self-counts.tsv")

with open(table, encoding="utf-8-sig", newline="") as stream:
    lines = [line for line in stream if line.strip() and not line.lstrip().startswith("#")]
if not lines:
    raise SystemExit("self-counts table has no header or rows")
reader = csv.DictReader(lines, delimiter="\t")
if not reader.fieldnames:
    raise SystemExit("self-counts table has no header")
normalized = {name.strip().lower().replace("-", "_"): name for name in reader.fieldnames if name}

def field(*names):
    for name in names:
        if name in normalized:
            return normalized[name]
    raise SystemExit("self-counts table lacks a required column: " + "/".join(names))

id_column = field("id", "claim_id")
doc_column = field("doc", "document", "path", "doc_path", "file")
regex_column = field("regex", "pattern", "locator", "line_regex", "match_regex")
rows = [row for row in reader if (row.get(id_column) or "").strip() == row_id]
if len(rows) != 1:
    raise SystemExit("expected exactly one self-count row with ID " + row_id)
row = rows[0]
doc = (row.get(doc_column) or "").strip()
pattern_text = (row.get(regex_column) or "").strip()
if not doc or not pattern_text:
    raise SystemExit("selected self-count row has an empty document path or regex")
if os.path.isabs(doc):
    raise SystemExit("selected self-count document path is absolute")
path = os.path.realpath(os.path.join(root, doc))
if os.path.commonpath((root, path)) != root:
    raise SystemExit("selected self-count document escapes the scratch tree")
pattern = re.compile(pattern_text)
if pattern.groups != 1:
    raise SystemExit("selected self-count regex must contain exactly one capture group")
with open(path, encoding="utf-8", newline="") as stream:
    text = stream.read()
matches = list(pattern.finditer(text))
if len(matches) != 1:
    raise SystemExit("selected self-count regex must match exactly once in its document")
match = matches[0]
number = match.group(1)
if not number.isdecimal():
    raise SystemExit("selected self-count capture is not a decimal number")
start, end = match.span(1)
updated = text[:start] + str(int(number) + 1) + text[end:]
with open(path, "w", encoding="utf-8", newline="") as stream:
    stream.write(updated)
PY
); then
    printf 'c1-measure: could not mutate row %s\n' "$mutate_id" >&2
    exit 2
  fi
  final_status=0
  if run_tool; then
    final_status=0
  else
    final_status=$?
  fi
  if ((final_status != 1)); then
    printf 'c1-measure: --mutate %s expected tool exit 1, observed %s\n' "$mutate_id" "$final_status" >&2
    exit 2
  fi
  exit 1
fi

if run_tool; then
  exit 0
else
  exit $?
fi
