#!/usr/bin/env bash
# plans/round-56-c1.sh -- round 56 C1 counter (freshness: every stated `recheck:` clock
# of the BASE population is replayed true by a lane gate on a committed capture).
#
# Frozen predicate (the same sentence appears in plans/round-56.md section C1):
#   C1_REPLAY: value = REPLAYED when GUARD = 1, else FAIL; target 10 (BASE 0).
#   POP: the 10 stated clocks of BASE (listed in POP below: entry, URL, filter form,
#     pattern, stated N) -- every backticked `curl ...` command on a column-1
#     `recheck:` line of corpus/knowledge/*.md at BASE that is followed by `-> N` or
#     `-> count=N`.
#   PRESENT(c) iff the measured entry is a regular non-symlink file with exactly one
#     column-1 `recheck:` line, and that line contains c's BASE command text,
#     backticked, followed by `-> N` / `-> count=N` with c's BASE N.
#   REPLAYED = number of POP clocks c with all of:
#     (r1) PRESENT(c);
#     (r2) the measured corpus/recheck-captures.tsv has exactly one data row whose
#          url column equals c's URL; that row's id names exactly one registry row
#          (outside ``` fences) whose cells number 11, status `mined`, and whose
#          source cell contains c's URL as a whitespace-delimited token;
#     (r3) the row's body_path is repo-relative, has no `..` and no symlinked
#          component, names a regular file of the measured tree whose byte count and
#          sha256 equal the row's bytes and sha256 columns, and the body neither
#          begins with `HTTP/` nor has a line starting `set-cookie:` (any case);
#     (r4) the counter's own replay of c's filter on that body equals c's N: grep
#          form -> host `grep -c -e <pattern> <body>`; pdf form -> host `pdftotext
#          -layout <body> -` piped to `grep -c -e <pattern>`; locate form -> BASE's
#          corpus/rendered-text-v1.py (taken from BASE, not from the measured tree)
#          `locate <body> <quote>` count;
#     (r5) the measured tree's `python3 -I -B corpus/recheck-replay.py --root <tree>`
#          prints a line `MATCH <c's entry>:<L> id=<that row's id> form=<form>
#          stated=<N> replayed=<N>` and its last line starts `RECHECK_REPLAY: CLEAN`.
#   GUARD = 1 iff every POP clock is PRESENT (no clock deleted or restated) and, when
#     the measured tree carries corpus/recheck-replay.py, its `--selftest` exits 0
#     with a last line starting `RECHECK_REPLAY_SELFTEST: PASS`.
# Fail closed: a bad revision, unreadable BASE, unusable scratch, missing python3,
#   grep or pdftotext is SETUP (exit 2); a missing or unreadable file reads its
#   conjunct as 0; a producer with empty output reads as not-CLEAN.
# Named ceilings: committed bytes only. A capture hand-written to carry the stated
#   counts, with a self-consistent manifest row, scores; the capture's provenance is
#   its fetch receipt and a non-author live re-fetch. A true but non-discriminating
#   pattern scores. The live run of each command is the check of currency on the day.
# Input: a revision, or --tree DIR. Output: one line
#   C1_REPLAY: value=V present=P replayed=R gate=G guard=G (bad=<reasons>)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=832ba6a53d6a76706b5c80bce2278683dea33d42
setup() { echo "C1_REPLAY: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v grep >/dev/null 2>&1 || setup no-grep
command -v pdftotext >/dev/null 2>&1 || setup no-pdftotext
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/c1.$$
mkdir -p -- "$SCR/t" "$SCR/b" "$SCR/tmp" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR/tmp
T=$SCR/t
if [ "${1:-}" = --tree ]; then
  [ -n "${2:-}" ] && [ -d "$2" ] || setup tree
  cp -a "$2"/. "$T"/ || setup tree-copy
else
  REV=${1:-}
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
git -C "$REPO" show "$BASE:corpus/rendered-text-v1.py" > "$SCR/b/rendered-text-v1.py" 2>/dev/null || setup base-normaliser
[ -s "$SCR/b/rendered-text-v1.py" ] || setup base-normaliser-empty
GATE_OUT=$SCR/gate.out; SELF_OUT=$SCR/self.out
HAVE_GATE=0; SELF_OK=1
if [ -e "$T/corpus/recheck-replay.py" ]; then
  HAVE_GATE=1
  (cd "$SCR" && python3 -I -B "$T/corpus/recheck-replay.py" --root "$T" > "$GATE_OUT" 2>&1)
  SELF_OK=0
  if (cd "$SCR" && python3 -I -B "$T/corpus/recheck-replay.py" --selftest > "$SELF_OUT" 2>&1); then
    last=$(grep -v '^[[:space:]]*$' "$SELF_OUT" | tail -n 1)
    case $last in "RECHECK_REPLAY_SELFTEST: PASS"*) SELF_OK=1 ;; esac
  fi
else
  : > "$GATE_OUT"
fi
cd "$SCR" || setup cd
python3 -I -B - "$T" "$SCR/b/rendered-text-v1.py" "$GATE_OUT" "$HAVE_GATE" "$SELF_OK" <<'PY'
import hashlib, re, subprocess, sys
from pathlib import Path
T, NORM, GATE_OUT, HAVE_GATE, SELF_OK = Path(sys.argv[1]), sys.argv[2], sys.argv[3], int(sys.argv[4]), int(sys.argv[5])
UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
K = "corpus/knowledge/"
# (entry, command text as backticked at BASE, form, URL, pattern, N)
POP = [
 (K+"betterleaks-detection-vs-validation.md", "curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -c 'Scans detect secrets without credential provider requests by default'", "grep", "https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md", "Scans detect secrets without credential provider requests by default", 1),
 (K+"cdp-bridge-1password-oidc-workflow.md", "curl -fsSL --max-time 30 'https://www.1password.dev/brokered-access/custom-workflow' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator'", "locate", "https://www.1password.dev/brokered-access/custom-workflow", "The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator", 1),
 (K+"iso-11770-3-edition-status.md", "curl -fsSL -A '%s' 'https://www.iso.org/standard/60237.html' | grep -c 'Withdrawal of International Standard'" % UA, "grep", "https://www.iso.org/standard/60237.html", "Withdrawal of International Standard", 2),
 (K+"iso-11770-3-edition-status.md", "curl -fsSL -A '%s' 'https://www.iso.org/standard/82709.html' | grep -c 'ISO/IEC 11770-3:2021/Amd'" % UA, "grep", "https://www.iso.org/standard/82709.html", "ISO/IEC 11770-3:2021/Amd", 3),
 (K+"iso-11770-3-edition-status.md", "curl -fsSL -A '%s' 'https://www.iso.org/standard/85929.html' | grep -c 'International Standard published'" % UA, "grep", "https://www.iso.org/standard/85929.html", "International Standard published", 2),
 (K+"nist-key-management-guidance-status.md", "curl -fsSL 'https://csrc.nist.gov/pubs/sp/800/133/r3/ipd' | grep -c 'public comment period is CLOSED'", "grep", "https://csrc.nist.gov/pubs/sp/800/133/r3/ipd", "public comment period is CLOSED", 1),
 (K+"nist-key-management-parts-withdrawal.md", "curl -fsSL 'https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf' | pdftotext -layout - - | grep -c 'has been withdrawn (archived)'", "pdf", "https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf", "has been withdrawn (archived)", 1),
 (K+"oidc-federation-trust-policy.md", "curl -fsSL --max-time 30 'https://openid.net/specs/openid-connect-core-1_0.html' | grep -c 'It MUST contain the OAuth 2.0'", "grep", "https://openid.net/specs/openid-connect-core-1_0.html", "It MUST contain the OAuth 2.0", 1),
 (K+"secret-scanning-detection-vs-validation.md", "curl -fsSL 'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md' | grep -c 'it can also log in to confirm if that secret is live or not'", "grep", "https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md", "it can also log in to confirm if that secret is live or not", 1),
 (K+"trufflehog-verification-lifecycle.md", "curl -fsSL 'https://trufflesecurity.com/docs/verification-caching' | grep -c 'Each cache entry expires after three hours'", "grep", "https://trufflesecurity.com/docs/verification-caching", "Each cache entry expires after three hours", 1),
]
bad = []

def read(rel):
    p = T / rel
    cur = T
    for part in Path(rel).parts:
        cur = cur / part
        if cur.is_symlink():
            return None
    if not p.is_file():
        return None
    try:
        return p.read_text(encoding="utf-8")
    except Exception:
        return None

def present(c):
    txt = read(c[0])
    if txt is None:
        return False
    rl = [l for l in txt.splitlines() if l.startswith("recheck:")]
    if len(rl) != 1:
        return False
    pat = re.escape("`" + c[1] + "`") + r"\s*->\s*(?:count=)?%d(?!\d)" % c[5]
    return re.search(pat, rl[0]) is not None

def registry():
    txt = read("corpus/SOURCES.md") or ""
    rows, fence = {}, False
    for l in txt.splitlines():
        if l.lstrip().startswith("```"):
            fence = not fence
            continue
        if fence:
            continue
        m = re.match(r"^ {0,3}\|\s*(S\d{3,})\s*\|", l)
        if m:
            cells = [x.strip() for x in l.strip().strip("|").split("|")]
            rows.setdefault(m.group(1), []).append(cells)
    return rows

def manifest():
    txt = read("corpus/recheck-captures.tsv")
    if txt is None:
        return None
    out = []
    hdr = None
    for l in txt.splitlines():
        if not l.strip() or l.startswith("#"):
            continue
        cols = l.split("\t")
        if hdr is None:
            hdr = cols
            if hdr != ["id", "url", "body_path", "fetched", "http_status", "bytes", "sha256"]:
                return None
            continue
        if len(cols) == 7:
            out.append(dict(zip(hdr, cols)))
    return out

def replay(c, body):
    form, pat, n = c[2], c[4], c[5]
    try:
        if form == "grep":
            r = subprocess.run(["grep", "-c", "-e", pat, str(body)], capture_output=True, timeout=60)
            return int(r.stdout.strip() or b"-1") if r.returncode in (0, 1) else None
        if form == "pdf":
            t = subprocess.run(["pdftotext", "-layout", str(body), "-"], capture_output=True, timeout=120)
            if t.returncode != 0:
                return None
            r = subprocess.run(["grep", "-c", "-e", pat], input=t.stdout, capture_output=True, timeout=60)
            return int(r.stdout.strip() or b"-1") if r.returncode in (0, 1) else None
        r = subprocess.run([sys.executable, "-I", "-B", NORM, "locate", str(body), pat], capture_output=True, timeout=120)
        m = re.search(rb"RENDERED_TEXT_V1_LOCATE: count=(\d+)", r.stdout)
        return int(m.group(1)) if m else None
    except Exception:
        return None

gate_lines = []
try:
    gate_lines = [l for l in open(GATE_OUT, encoding="utf-8", errors="replace").read().splitlines() if l.strip()]
except Exception:
    pass
gate_clean = 1 if gate_lines and gate_lines[-1].startswith("RECHECK_REPLAY: CLEAN") else 0
reg = registry()
man = manifest()
P = R = 0
for c in POP:
    tag = "%s:%s" % (c[0].rsplit("/", 1)[1], c[3].rsplit("/", 1)[1] or c[3])
    if not present(c):
        bad.append("absent:" + tag)
        continue
    P += 1
    if man is None:
        bad.append("r2-manifest:" + tag); continue
    rows = [m for m in man if m["url"] == c[3]]
    if len(rows) != 1:
        bad.append("r2-rows%d:%s" % (len(rows), tag)); continue
    m = rows[0]
    rr = reg.get(m["id"], [])
    if len(rr) != 1 or len(rr[0]) != 11 or rr[0][7] != "mined" or c[3] not in rr[0][1].split():
        bad.append("r2-registry:" + tag); continue
    rel = m["body_path"]
    if not rel or rel.startswith("/") or ".." in Path(rel).parts:
        bad.append("r3-path:" + tag); continue
    cur, link = T, False
    for part in Path(rel).parts:
        cur = cur / part
        link = link or cur.is_symlink()
    if link or not cur.is_file():
        bad.append("r3-file:" + tag); continue
    data = cur.read_bytes()
    if str(len(data)) != m["bytes"] or hashlib.sha256(data).hexdigest() != m["sha256"]:
        bad.append("r3-digest:" + tag); continue
    if data.startswith(b"HTTP/") or re.search(rb"(?im)^set-cookie:", data):
        bad.append("r3-headers:" + tag); continue
    got = replay(c, cur)
    if got != c[5]:
        bad.append("r4-replay%s:%s" % (got, tag)); continue
    want = re.compile(r"^MATCH %s:\d+ id=%s form=%s stated=%d replayed=%d$" % (re.escape(c[0]), re.escape(m["id"]), c[2], c[5], c[5]))
    if not (gate_clean and any(want.match(l) for l in gate_lines)):
        bad.append("r5-gate:" + tag); continue
    R += 1
guard = 1 if (P == len(POP) and SELF_OK == 1) else 0
if SELF_OK != 1:
    bad.append("selftest")
val = str(R) if guard else "FAIL"
print("C1_REPLAY: value=%s present=%d replayed=%d gate=%d guard=%d (bad=%s)" % (val, P, R, gate_clean, guard, ",".join(bad) or "none"))
PY
