#!/usr/bin/env bash
# corpus/expect-journal.sh -- round-41 C1 calibration gate (frozen interface, plans/round-41.md C1).
#
# Compares a candidate claim ledger against a base ledger. Every ledger-expectation or command
# change must carry a migration journal entry whose old_expect/command/new_expect match literally,
# and every changed expect must be a fully literal anchored expression (no loosening to a pattern).
#
# Ledger: tab-separated, id(0) command(1) expect(2); lines beginning with # and empty lines skipped.
# Journals: every *.json file under --journals (recursive); each has migrations[] entries with
# id, command, old_expect, new_expect (all four required strings).
#
# Frozen rules (plans/round-41.md C1):
#   R1 UNJOURNALED <ID>        row in both ledgers whose command or expect differs from base
#                              with no migration entry with that id in any journal
#   R2 OLD_MISMATCH <ID>       entry old_expect is not the base expect (rule: it must equal it literally)
#   R2 COMMAND_MISMATCH <ID>   entry command is not the candidate command (must equal literally)
#   R2 NEW_MISMATCH <ID>       entry new_expect is not the candidate expect (must equal literally)
#   R3 NOT_LITERAL <ID>        changed candidate expect is not fully literal anchored: must start
#                              with ^, end with $, and every interior metacharacter of
#                              . [ ] ( ) * + ? { } | ^ $ must be backslash-escaped
#   R4 WARN ORPHAN <ID>        journal entry for a row that did not change: warning only, never refuses
#   MISSING_ROW <ID>           journal id absent from the candidate ledger (refusal)
#   DELETED <ID>               base-ledger id absent from the candidate ledger (refusal;
#                              unconditional - plans/round-42.md C1: there is no journal
#                              form for a deletion in this round)
#
# Output (stdout): one `EXPECT_JOURNAL: WARN ORPHAN <ID>` line per warning, one
# `EXPECT_JOURNAL: REFUSE <CLASS> <ID>` line per violation, then the final line
# `EXPECT_JOURNAL: CLEAN (changed=<n> journaled=<n>)` exit 0, or
# `EXPECT_JOURNAL: REFUSED (violations=<n>)` exit 1.
# Setup errors (missing/unreadable file, unreadable JSON, unreadable ledger, duplicate ledger id)
# print to stderr only and exit 2 with no stdout and no integer.
# bash + python3 stdlib only; set -u. Normal mode writes no files anywhere.
# --selftest builds its fixtures under ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41ExecJournal/selftest-$$
# from committed bytes (BASE 6cc8850 ledger, P0 6f1588c ledger + round-40 journal) and removes them on exit.
set -u

selftest=0
base_ledger=""
cand_ledger=""
journals_dir=""
while [ $# -gt 0 ]; do
  case "$1" in
    --selftest) selftest=1 ;;
    --base-ledger) base_ledger="${2-}"; shift ;;
    --ledger) cand_ledger="${2-}"; shift ;;
    --journals) journals_dir="${2-}"; shift ;;
    *) printf 'expect-journal: setup error: unknown argument %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

# ---------------------------------------------------------------- selftest --
if [ "$selftest" -eq 1 ]; then
  selffail() { printf 'EXPECT_JOURNAL_SELFTEST: FAIL (%s)\n' "$1" >&2; exit 1; }
  SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd) || selffail script-dir
  TOP=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null) || selffail not-a-git-repo
  FX=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41ExecJournal/selftest-$$
  rm -rf -- "$FX"; mkdir -p -- "$FX" || selffail scratch-mkdir
  trap 'rm -rf -- "$FX"' EXIT
  BASE_PIN=6cc8850dfc5757927699e5a53a876f47c8df21aa   # round-40 claim BASE ledger
  P0_PIN=6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0     # round-40 landed state (positive control P0)
  JPIN=.ufo/waves/round-40/expectation-migrations.json
  git -C "$TOP" show "$BASE_PIN:corpus/claim-ledger.tsv" > "$FX/base.tsv" 2>/dev/null || selffail base-pin-unreadable
  git -C "$TOP" show "$P0_PIN:corpus/claim-ledger.tsv" > "$FX/p0.tsv" 2>/dev/null || selffail p0-pin-unreadable
  git -C "$TOP" show "$P0_PIN:$JPIN" > "$FX/p0-journal.json" 2>/dev/null || selffail journal-pin-unreadable

  # Build P0, F1..F5 (the frozen constructions of plans/round-41.md C1 and plans/round-42.md
  # C1) and two synthetic cases (literal anchored expect with \( escapes; orphan journal
  # entry warns).
  python3 - "$FX" <<'PY' || selffail fixture-build
import copy, json, os, sys
fx = sys.argv[1]
base = open(os.path.join(fx, "base.tsv"), encoding="utf-8").read().splitlines()
p0 = open(os.path.join(fx, "p0.tsv"), encoding="utf-8").read().splitlines()
journal = json.load(open(os.path.join(fx, "p0-journal.json"), encoding="utf-8"))

def write_ledger(name, lines):
    with open(os.path.join(fx, name), "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")

def write_journal(name, doc):
    d = os.path.join(fx, name)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "expectation-migrations.json"), "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)

def edit_row(lines, rid, col, value):
    out, hit = [], False
    for line in lines:
        f = line.split("\t")
        if f and f[0] == rid and len(f) > col:
            f[col] = value
            hit = True
            line = "\t".join(f)
        out.append(line)
    if not hit:
        sys.exit(2)
    return out

def mig(doc, rid):
    for m in doc["migrations"]:
        if m["id"] == rid:
            return m
    sys.exit(2)

write_ledger("base-ledger.tsv", base)
# P0: positive control, round-40 landed state unmodified.
write_ledger("p0-ledger.tsv", p0)
write_journal("p0-journals", journal)
# F1: R13-01 expect := ^[0-9]+$, its journal entry removed.
f1j = copy.deepcopy(journal)
f1j["migrations"] = [m for m in f1j["migrations"] if m["id"] != "R13-01"]
write_ledger("f1-ledger.tsv", edit_row(p0, "R13-01", 2, "^[0-9]+$"))
write_journal("f1-journals", f1j)
# F2: R21-02 journal old_expect := its new_expect; ledger unchanged.
f2j = copy.deepcopy(journal)
m = mig(f2j, "R21-02")
m["old_expect"] = m["new_expect"]
write_ledger("f2-ledger.tsv", p0)
write_journal("f2-journals", f2j)
# F3: R13-01 expect := ^[0-9]+$ and its journal new_expect := the same.
f3j = copy.deepcopy(journal)
mig(f3j, "R13-01")["new_expect"] = "^[0-9]+$"
write_ledger("f3-ledger.tsv", edit_row(p0, "R13-01", 2, "^[0-9]+$"))
write_journal("f3-journals", f3j)
# F4: R24-06 command rebound to an echo of its expected line; journal unchanged.
rebound = ("echo 'ROW_IDENTITY: scorecard-rounds count=54 "
           "sha256=52e7ba8d9b4de4a3aa7543b7f0370361dd17c2ae18b98c0c318618917dfe50c7'")
write_ledger("f4-ledger.tsv", edit_row(p0, "R24-06", 1, rebound))
write_journal("f4-journals", journal)
# F5 (plans/round-42.md C1): the P0 ledger with row R17-02 deleted, journal unchanged.
f5 = [line for line in p0 if line.split("\t")[0] != "R17-02"]
if len(f5) != len(p0) - 1:
    sys.exit(2)
write_ledger("f5-ledger.tsv", f5)
write_journal("f5-journals", journal)
# Literal case: changed expect with \( escapes is fully literal anchored -> accepted.
write_ledger("lit-base.tsv", ["LIT-01\tcowsay hello\t^plain$\t0\t5\tnote"])
write_ledger("lit-ledger.tsv", ["LIT-01\tcowsay hello\t^2 \\(two\\) items$\t0\t5\tnote"])
write_journal("lit-journals", {"migrations": [
    {"id": "LIT-01", "command": "cowsay hello",
     "old_expect": "^plain$", "new_expect": "^2 \\(two\\) items$"}]})
# Orphan case: journal entry for a row that did not change -> warning only, accepted.
write_ledger("orp-base.tsv", ["ORP-01\ttrue\t^ok$\t0\t5\tnote"])
write_ledger("orp-ledger.tsv", ["ORP-01\ttrue\t^ok$\t0\t5\tnote"])
write_journal("orp-journals", {"migrations": [
    {"id": "ORP-01", "command": "true", "old_expect": "^ok$", "new_expect": "^ok$"}]})
PY

  GATE="$SCRIPT_DIR/$(basename -- "$0")"
  export GATE_SELF="$GATE"
  python3 - "$FX" <<'PY' || exit 1
import os, subprocess, sys

fx = sys.argv[1]
gate = os.environ["GATE_SELF"]

def j(name):
    return os.path.join(fx, name)

n = 0

def die(case, detail):
    sys.stderr.write("EXPECT_JOURNAL_SELFTEST: FAIL (%s): %s\n" % (case, detail))
    sys.exit(1)

def run(case, ledger, journals, want_rc, base="base-ledger.tsv",
        need_lines=(), forbid_refuse=False, want_final=None):
    global n
    r = subprocess.run(["bash", gate, "--base-ledger", j(base),
                        "--ledger", j(ledger), "--journals", j(journals)],
                       capture_output=True, text=True)
    out = r.stdout.splitlines()
    if r.returncode != want_rc:
        die(case, "rc=%d want=%d stdout=%r stderr=%r" % (r.returncode, want_rc, r.stdout, r.stderr))
    for line in need_lines:
        if line not in out:
            die(case, "missing line %r in %r" % (line, out))
    if forbid_refuse and any(l.startswith("EXPECT_JOURNAL: REFUSE") for l in out):
        die(case, "unexpected refusal in %r" % (out,))
    if want_final is not None and (not out or out[-1] != want_final):
        die(case, "final line %r want %r" % (out[-1:] and out[-1], want_final))
    n += 1

# 1 P0 accept (positive control, round-40 landed state).
run("p0", "p0-ledger.tsv", "p0-journals", 0, forbid_refuse=True,
    want_final="EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)")
# 2 F1 refused with its frozen token.
run("f1", "f1-ledger.tsv", "f1-journals", 1,
    need_lines=("EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01",))
# 3 F2 refused with its frozen token.
run("f2", "f2-ledger.tsv", "f2-journals", 1,
    need_lines=("EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02",))
# 4 F3 refused with its frozen token.
run("f3", "f3-ledger.tsv", "f3-journals", 1,
    need_lines=("EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01",))
# 5 F4 refused with its frozen token.
run("f4", "f4-ledger.tsv", "f4-journals", 1,
    need_lines=("EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06",))
# 6 literal anchored expect with \( escapes accepted.
run("literal", "lit-ledger.tsv", "lit-journals", 0, base="lit-base.tsv", forbid_refuse=True,
    want_final="EXPECT_JOURNAL: CLEAN (changed=1 journaled=1)")
# 7 orphan journal entry only warns.
run("orphan", "orp-ledger.tsv", "orp-journals", 0, base="orp-base.tsv",
    need_lines=("EXPECT_JOURNAL: WARN ORPHAN ORP-01",), forbid_refuse=True,
    want_final="EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)")
# 8 F5 refused with its frozen token (deleted base row, plans/round-42.md C1).
run("f5", "f5-ledger.tsv", "f5-journals", 1,
    need_lines=("EXPECT_JOURNAL: REFUSE DELETED R17-02",))

print("EXPECT_JOURNAL_SELFTEST: PASS (cases=%d)" % n)
sys.exit(0)
PY
  # python3 exits 1 on any failed case; reaching here means PASS was printed.
  exit $?
fi

# ------------------------------------------------------------- normal mode --
[ -n "$base_ledger" ] || { echo 'expect-journal: setup error: --base-ledger required' >&2; exit 2; }
[ -n "$cand_ledger" ] || { echo 'expect-journal: setup error: --ledger required' >&2; exit 2; }
[ -n "$journals_dir" ] || { echo 'expect-journal: setup error: --journals required' >&2; exit 2; }
[ -f "$base_ledger" ] && [ -r "$base_ledger" ] || { echo "expect-journal: setup error: base ledger not readable: $base_ledger" >&2; exit 2; }
[ -f "$cand_ledger" ] && [ -r "$cand_ledger" ] || { echo "expect-journal: setup error: ledger not readable: $cand_ledger" >&2; exit 2; }
[ -d "$journals_dir" ] && [ -r "$journals_dir" ] && [ -x "$journals_dir" ] || { echo "expect-journal: setup error: journals dir not readable: $journals_dir" >&2; exit 2; }

python3 - "$base_ledger" "$cand_ledger" "$journals_dir" <<'PY'
import json, os, sys

META = set(".[]()*+?{}|^$")

def die(msg):
    sys.stderr.write("expect-journal: setup error: %s\n" % msg)
    sys.exit(2)

def read_ledger(path, what):
    rows, order = {}, []
    try:
        fh = open(path, encoding="utf-8")
    except OSError as e:
        die("unreadable %s ledger %s: %s" % (what, path, e))
    with fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            if not line.strip() or line.startswith("#"):
                continue
            f = line.split("\t")
            if len(f) < 3:
                die("%s ledger %s line %d: fewer than 3 tab columns" % (what, path, lineno))
            rid = f[0]
            if rid in rows:
                die("%s ledger %s: duplicate id %s" % (what, path, rid))
            rows[rid] = (f[1], f[2])
            order.append(rid)
    return rows, order

def read_journals(d):
    entries = []
    for dirpath, dirnames, filenames in os.walk(d):
        dirnames.sort()
        for fn in sorted(filenames):
            if not fn.endswith(".json"):
                continue
            p = os.path.join(dirpath, fn)
            try:
                with open(p, encoding="utf-8") as fh:
                    doc = json.load(fh)
            except (OSError, ValueError, UnicodeDecodeError) as e:
                die("unreadable journal json %s: %s" % (p, e))
            if not isinstance(doc, dict) or not isinstance(doc.get("migrations"), list):
                die("journal %s: no migrations list" % p)
            for i, m in enumerate(doc["migrations"]):
                if not isinstance(m, dict):
                    die("journal %s entry %d: not an object" % (p, i))
                for k in ("id", "command", "old_expect", "new_expect"):
                    if not isinstance(m.get(k), str):
                        die("journal %s entry %d: missing string field %s" % (p, i, k))
                entries.append((m["id"], m["command"], m["old_expect"], m["new_expect"]))
    return entries

def literal_anchored(expect):
    if len(expect) < 2 or expect[0] != "^" or expect[-1] != "$":
        return False
    esc = False
    for ch in expect[1:-1]:
        if esc:
            esc = False
        elif ch == "\\":
            esc = True
        elif ch in META:
            return False
    return not esc  # a dangling interior backslash escapes nothing: not fully literal

base_rows, base_order = read_ledger(sys.argv[1], "base")
cand_rows, _ = read_ledger(sys.argv[2], "candidate")
entries = read_journals(sys.argv[3])

entries_by_id = {}
for e in entries:
    entries_by_id.setdefault(e[0], []).append(e)

changed_ids = [rid for rid in base_order
               if rid in cand_rows and cand_rows[rid] != base_rows[rid]]
changed_set = set(changed_ids)

refuses = set()
warns = set()
journaled = 0
# plans/round-42.md C1: a base-ledger id absent from the candidate ledger is a deletion,
# refused unconditionally (no journal form for a deletion in this round; a future
# retirement form is a new contract version, never a loosened migration).
for rid in base_order:
    if rid not in cand_rows:
        refuses.add(("DELETED", rid))
for rid in changed_ids:
    cmd_b, exp_b = base_rows[rid]
    cmd_c, exp_c = cand_rows[rid]
    es = entries_by_id.get(rid)
    if not es:
        refuses.add(("UNJOURNALED", rid))
    else:
        journaled += 1
        for (_id, command, old, new) in es:
            if old != exp_b:
                refuses.add(("OLD_MISMATCH", rid))
            if command != cmd_c:
                refuses.add(("COMMAND_MISMATCH", rid))
            if new != exp_c:
                refuses.add(("NEW_MISMATCH", rid))
    if exp_c != exp_b and not literal_anchored(exp_c):
        refuses.add(("NOT_LITERAL", rid))

for rid in entries_by_id:
    if rid not in cand_rows:
        refuses.add(("MISSING_ROW", rid))
    elif rid not in changed_set:
        warns.add(("ORPHAN", rid))

for _cls, rid in sorted(warns):
    print("EXPECT_JOURNAL: WARN ORPHAN %s" % rid)
for cls, rid in sorted(refuses):
    print("EXPECT_JOURNAL: REFUSE %s %s" % (cls, rid))
if refuses:
    print("EXPECT_JOURNAL: REFUSED (violations=%d)" % len(refuses))
    sys.exit(1)
print("EXPECT_JOURNAL: CLEAN (changed=%d journaled=%d)" % (len(changed_ids), journaled))
sys.exit(0)
PY
exit $?
