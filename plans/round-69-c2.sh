#!/usr/bin/env bash
# plans/round-69-c2.sh — C2_TEETH counter (kagi round 69, claim C2, operability).
#
#   bash plans/round-69-c2.sh --tree DIR [--base-tree DIR] [--scratch DIR] [--verbose]
#   bash plans/round-69-c2.sh --selftest [--scratch DIR]
#
# Frozen predicate: plans/round-69.md §C2 (never amend or reinterpret a predicate,
# population, kill rule or target; this file enforces it).
#
#   C2_TEETH: subfloor=<0|1> ledger=<0|1> guard=<0|1>
#
# subfloor  1 iff
#   (a) the measured tree's plans/round-68-c1.sh `predicate_ok`, extracted as source
#       and executed, refuses (36,31,6,1,0), accepts (37,32,6,1,0) and (38,33,6,1,0),
#       and refuses (38,33,5,1,0), (38,33,6,0,0), (38,33,6,1,1);
#   (b) `bash plans/round-68-c1.sh --selftest` on the measured tree and on the BASE
#       copy each print `C1_VERIFIED_SELFTEST: PASS (N cases)`, and N_tree == N_base + 1;
#   (c) the BASE copy's predicate ACCEPTS (36,31,6,1,0) (the blindness witness).
# ledger    1 iff, on a scratch copy of the measured tree whose corpus/claim-ledger.tsv
#           holds only the comments and the single R68-02 row (row read from the tree):
#   (a) `bash corpus/claim-ledger.sh verify` exits 0, last line `CLAIM_LEDGER: CLEAN (claims=1`;
#   (b) the same scratch with R68-02's command field replaced by `true` exits 1 with a
#       `FAIL R68-02` line (the row is executed, not text-matched);
#   (c) `bash corpus/expect-journal.sh --base-ledger <BASE> --ledger <tree> --journals
#       <tree>/.ufo/waves/round-69/journals` exits 0 with `EXPECT_JOURNAL: CLEAN`;
#   (d) `bash corpus/row-identity.sh ledger-ids` (on the measured tree) matches the
#       expectation the tree's own R24-14 row pins (parsed from that row, never a literal).
#   Scratch-only mechanics: the ledger file is itself a stamped artifact (corpus/stamps.tsv),
#   so a reduced or `true`-edited ledger would read STALE on its own pin. The scratch copy's
#   stamp row for corpus/claim-ledger.tsv is re-pinned to the bytes of the file it runs.
#   The measured tree is never written.
# guard     1 iff (a) the measured run reads subfloor=1 and ledger=1; (b) the BASE run reads
#           subfloor=0 and ledger=0; (c) a comment-only copy (`# verified >= 37, col15 >= 32`
#           above the unchanged predicate body) reads subfloor=0; (d) `--selftest` prints
#           Reading (c): the copy is built from the BASE predicate body, because a comment on the
#           candidate's fixed body would read subfloor=1 and make guard (c) unsatisfiable.
#           `C2_TEETH_SELFTEST: PASS (N cases)` with N >= 10.
#
# Exit 0 iff subfloor=1 and ledger=1 and guard=1; 1 otherwise; 2 on SETUP (missing or
# unreadable tree, bad argument, scratch inside the measured tree, nested invocation).
# The last stdout line is the verdict (or `C2_TEETH: SETUP <reason>`).
#
# BASE is the claim BASE 264917aa8fc9e71b6595d0d5166c4b615120fb8b, extracted with
# `git archive` from the lane repo unless --base-tree is given.
# A nested invocation (env R69_C2_NESTED=1, set by this counter around its own
# `claim-ledger.sh verify`) refuses with SETUP: a claim row may not re-run the counter.
# Scratch: --scratch, else ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r69/R69ExecCounterC2/.
# Each run works in a fresh run.* directory there, removed on exit.
set -u
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
SELF="$HERE/$(basename -- "${BASH_SOURCE[0]}")"
LANE=$(cd -- "$HERE/.." && pwd) || exit 2
BASE_REV=264917aa8fc9e71b6595d0d5166c4b615120fb8b

setup() { printf 'C2_TEETH: SETUP %s\n' "$1"; exit 2; }

TREE=""; BASE_TREE=""; SCRATCH=""; SELFTEST=0; VERBOSE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) [ $# -ge 2 ] || setup "--tree needs a dir"; TREE=$2; shift ;;
    --base-tree) [ $# -ge 2 ] || setup "--base-tree needs a dir"; BASE_TREE=$2; shift ;;
    --scratch) [ $# -ge 2 ] || setup "--scratch needs a dir"; SCRATCH=$2; shift ;;
    --verbose) VERBOSE=1 ;;
    --selftest) SELFTEST=1 ;;
    *) setup "unknown argument: $1" ;;
  esac
  shift
done

if [ "${R69_C2_NESTED:-0}" = 1 ]; then
  setup "nested invocation refused (a claim row must not re-run the counter)"
fi
command -v python3 >/dev/null 2>&1 || setup "no python3"
command -v git >/dev/null 2>&1 || setup "no git"
[ -n "$SCRATCH" ] || SCRATCH="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r69/R69ExecCounterC2"
mkdir -p -- "$SCRATCH" || setup "scratch not creatable: $SCRATCH"
S=$(mktemp -d "$SCRATCH/run.XXXXXX") || setup "scratch mktemp failed under $SCRATCH"
trap 'rm -rf -- "$S"' EXIT
mkdir -p -- "$S/tmp" || setup "scratch tmp mkdir failed"
TMPDIR="$S/tmp"; export TMPDIR

if [ "$SELFTEST" -eq 0 ]; then
  [ -n "$TREE" ] || setup "--tree is required"
  [ -d "$TREE" ] || setup "bad tree: $TREE"
fi

python3 -I -B - "$S" "$TREE" "$LANE" "$BASE_REV" "$BASE_TREE" "$SELF" "$VERBOSE" "$SELFTEST" "$SCRATCH" <<'PY'
import hashlib, os, re, subprocess, sys

S, TREE, LANE, BASE_REV, BASE_TREE, SELF, VERBOSE, SELFTEST, SCRATCH = sys.argv[1:10]
VERBOSE = (VERBOSE == "1")
C1_REL = os.path.join("plans", "round-68-c1.sh")
ROW = "R68-02"
LEDGER_REL = "corpus/claim-ledger.tsv"
PASS_RE = re.compile(r"^C1_VERIFIED_SELFTEST: PASS \((\d+) cases\)\s*$", re.M)
C2_PASS_RE = re.compile(r"^C2_TEETH_SELFTEST: PASS \((\d+) cases\)\s*$", re.M)


def real(p):
    return os.path.realpath(p)


def setup(msg):
    print("C2_TEETH: SETUP %s" % msg)
    sys.exit(2)


def vlog(msg):
    if VERBOSE:
        print("  | " + msg)


def run(args, cwd=None, env=None, timeout=900):
    e = dict(os.environ)
    if env:
        e.update(env)
    try:
        p = subprocess.run(args, cwd=cwd, env=e, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, timeout=timeout)
        return p.returncode, p.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired as ex:
        out = ex.stdout.decode("utf-8", "replace") if isinstance(ex.stdout, bytes) else ""
        return 124, out + "\n[c2] timeout after %ss" % timeout
    except OSError as ex:
        return 127, "[c2] exec failed: %s" % ex


def last_line(out):
    lines = [l for l in out.splitlines() if l.strip()]
    return lines[-1] if lines else ""


def read(p):
    try:
        with open(p, encoding="utf-8", newline="") as fh:
            return fh.read()
    except (OSError, UnicodeDecodeError):
        return None


def write(p, text):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)


def within(child, parent):
    try:
        return os.path.commonpath([real(child), real(parent)]) == real(parent)
    except ValueError:
        return False


def copy_tree(src, dst):
    if os.path.exists(dst):
        setup("copy destination exists: %s" % dst)
    os.makedirs(dst)
    tar = subprocess.Popen(["tar", "-C", src, "--exclude=.git", "--exclude=.jj",
                            "--exclude=__pycache__", "-cf", "-", "."],
                           stdout=subprocess.PIPE)
    ex = subprocess.run(["tar", "-xf", "-", "-C", dst], stdin=tar.stdout)
    tar.stdout.close()
    rc = tar.wait()
    if rc != 0 or ex.returncode != 0:
        setup("tree copy failed (tar %d / extract %d)" % (rc, ex.returncode))


def base_dir():
    if BASE_TREE:
        b = real(BASE_TREE)
        if not os.path.isdir(b):
            setup("bad base tree: %s" % BASE_TREE)
        return b
    rc, top = run(["git", "-C", LANE, "rev-parse", "--show-toplevel"], timeout=60)
    if rc != 0 or real(top.strip()) != real(LANE):
        setup("lane is not its own git toplevel; pass --base-tree")
    dst = os.path.join(S, "base")
    os.makedirs(dst)
    arch = subprocess.Popen(["git", "-C", LANE, "archive", BASE_REV], stdout=subprocess.PIPE)
    ex = subprocess.run(["tar", "-xf", "-", "-C", dst], stdin=arch.stdout)
    arch.stdout.close()
    rc = arch.wait()
    if rc != 0 or ex.returncode != 0:
        setup("git archive of BASE %s failed" % BASE_REV)
    return dst


# ---------------------------------------------------------------- subfloor --
def extract_predicate(text):
    lines = text.split("\n")
    start = None
    for i, l in enumerate(lines):
        if re.match(r"def predicate_ok\(", l):
            start = i
            break
    if start is None:
        return None
    out = [lines[start]]
    for l in lines[start + 1:]:
        if l.strip() and not l[0].isspace():
            break
        out.append(l)
    return "\n".join(out) + "\n"


def load_predicate(path):
    text = read(path)
    if text is None:
        return None, "unreadable %s" % path
    src = extract_predicate(text)
    if src is None:
        return None, "no def predicate_ok"
    ns = {}
    try:
        exec(compile(src, path, "exec"), ns)
    except Exception as ex:
        return None, "exec-error %s" % ex.__class__.__name__
    f = ns.get("predicate_ok")
    if not callable(f):
        return None, "predicate_ok not callable"
    return f, "loaded"


SUBFLOOR_CASES = [((36, 31, 6, 1, 0), False), ((37, 32, 6, 1, 0), True),
                  ((38, 33, 6, 1, 0), True), ((38, 33, 5, 1, 0), False),
                  ((38, 33, 6, 0, 0), False), ((38, 33, 6, 1, 1), False)]


def predicate_check(f):
    ok = True
    parts = []
    for args, want in SUBFLOOR_CASES:
        try:
            got = bool(f(*args))
            err = ""
        except Exception as ex:
            got = None
            err = " raise=%s" % ex.__class__.__name__
        good = (got is want)
        ok = ok and good
        parts.append("%s want=%s got=%s%s %s" % (args, want, got, err, "ok" if good else "MISS"))
    return ok, parts


C1_CACHE = {}


def c1_selftest(tree, sc):
    key = real(tree)
    if key in C1_CACHE:
        return C1_CACHE[key]
    os.makedirs(os.path.join(sc, "hyaku"), exist_ok=True)
    rc, out = run(["bash", os.path.join(key, C1_REL), "--selftest"], cwd=key,
                  env={"HYAKU_SCRATCH": os.path.join(sc, "hyaku"), "TMPDIR": sc}, timeout=1200)
    found = PASS_RE.findall(out)
    n = int(found[-1]) if (rc == 0 and len(found) == 1) else None
    res = (n, rc, last_line(out))
    C1_CACHE[key] = res
    vlog("c1-selftest tree=%s rc=%d cases=%s last=%r" % (key, rc, n, last_line(out)))
    return res


def subfloor_leg(tree, base, tag):
    det = []
    f, why = load_predicate(os.path.join(tree, C1_REL))
    if f is None:
        a = 0
        det.append("a=0 predicate: %s" % why)
    else:
        ok, parts = predicate_check(f)
        a = 1 if ok else 0
        det += ["  a " + p for p in parts]
    n_t, rc_t, _ = c1_selftest(tree, os.path.join(S, "c1-%s-tree" % tag))
    n_b, rc_b, _ = c1_selftest(base, os.path.join(S, "c1-%s-base" % tag))
    b = 1 if (n_t is not None and n_b is not None and n_t == n_b + 1) else 0
    det.append("b tree_cases=%s(rc=%s) base_cases=%s(rc=%s) need tree=base+1" % (n_t, rc_t, n_b, rc_b))
    fb, whyb = load_predicate(os.path.join(base, C1_REL))
    c = 0
    if fb is not None:
        try:
            c = 1 if bool(fb(36, 31, 6, 1, 0)) else 0
        except Exception:
            c = 0
    det.append("c base_predicate_accepts_36_31_6_1_0=%d (%s)" % (c, whyb))
    sub = 1 if (a and b and c) else 0
    return sub, a, b, c, det


# ------------------------------------------------------------------ ledger --
def reduce_ledger(text):
    lines = text.split("\n")
    keep = [l for l in lines if l.startswith("#")]
    rows = [l for l in lines if l and not l.startswith("#") and l.split("\t")[0] == ROW]
    if len(rows) != 1:
        return None, len(rows)
    return "\n".join(keep + rows) + "\n", 1


def with_command(row, cmd):
    f = row.split("\t")
    f[1] = cmd
    return "\t".join(f)


def repin_ledger_stamp(d):
    """Scratch-only: re-pin the stamp row of the ledger file this scratch copy runs."""
    sp = os.path.join(d, "corpus", "stamps.tsv")
    text = read(sp)
    if text is None:
        return False
    data = open(os.path.join(d, LEDGER_REL), "rb").read()
    hits = 0
    out = []
    for l in text.split("\n"):
        f = l.split("\t")
        if l and not l.startswith("#") and f[0] == LEDGER_REL and len(f) >= 4:
            f[1] = hashlib.sha256(data).hexdigest()
            f[2] = str(data.count(b"\n"))
            f[3] = str(len(data))
            l = "\t".join(f)
            hits += 1
        out.append(l)
    if hits != 1:
        return False
    write(sp, "\n".join(out))
    return True


def verify_lines(out):
    hits = [l for l in out.splitlines()
            if re.match(r"(STALE |MISSING |NOT-A-FILE |FAIL |POLICY|CLAIM_LEDGER)", l)]
    return hits[:40]


def ledger_ab(tree, base, tag):
    det = []
    text = read(os.path.join(tree, LEDGER_REL))
    if text is None:
        return 0, 0, ["no %s" % LEDGER_REL]
    red, n = reduce_ledger(text)
    if red is None:
        return 0, 0, ["%s rows=%d (need exactly 1)" % (ROW, n)]
    row = [l for l in red.split("\n") if l.startswith(ROW + "\t")][0]
    d = os.path.join(S, "ledger-%s" % tag)
    copy_tree(tree, d)
    lp = os.path.join(d, LEDGER_REL)
    write(lp, red)
    if not repin_ledger_stamp(d):
        return 0, 0, ["scratch stamp re-pin failed"]
    rc_a, out_a = run(["bash", "corpus/claim-ledger.sh", "verify"], cwd=d,
                      env={"R69_C2_NESTED": "1"}, timeout=3700)
    last_a = last_line(out_a)
    a = 1 if (rc_a == 0 and last_a.startswith("CLAIM_LEDGER: CLEAN (claims=1")) else 0
    det.append("a verify-reduced rc=%d last=%r" % (rc_a, last_a))
    for l in verify_lines(out_a):
        vlog("verify-reduced: " + l)
    write(lp, red.replace(row, with_command(row, "true"), 1))
    if not repin_ledger_stamp(d):
        return a, 0, det + ["scratch stamp re-pin failed (true variant)"]
    rc_b, out_b = run(["bash", "corpus/claim-ledger.sh", "verify"], cwd=d,
                      env={"R69_C2_NESTED": "1"}, timeout=3700)
    fail_hit = bool(re.search(r"\bFAIL %s\b" % ROW, out_b))
    b = 1 if (rc_b == 1 and fail_hit) else 0
    det.append("b verify-true rc=%d fail-line=%s last=%r" % (rc_b, fail_hit, last_line(out_b)))
    for l in verify_lines(out_b):
        vlog("verify-true: " + l)
    return a, b, det


def journal_check(tree, base):
    bl = os.path.join(base, LEDGER_REL)
    cl = os.path.join(tree, LEDGER_REL)
    jd = os.path.join(tree, ".ufo", "waves", "round-69", "journals")
    rc, out = run(["bash", os.path.join(tree, "corpus", "expect-journal.sh"),
                   "--base-ledger", bl, "--ledger", cl, "--journals", jd], cwd=tree, timeout=600)
    last = last_line(out)
    c = 1 if (rc == 0 and last.startswith("EXPECT_JOURNAL: CLEAN")) else 0
    return c, ["c expect-journal rc=%d last=%r" % (rc, last)]


def identity_check(tree):
    text = read(os.path.join(tree, LEDGER_REL)) or ""
    pins = [l.split("\t") for l in text.split("\n")
            if l and not l.startswith("#") and l.split("\t")[0] == "R24-14"]
    if len(pins) != 1 or len(pins[0]) < 3:
        return 0, ["d R24-14 rows=%d (need exactly 1 with an expect)" % len(pins)]
    expect = pins[0][2]
    rc, out = run(["bash", os.path.join(tree, "corpus", "row-identity.sh"), "ledger-ids"],
                  cwd=tree, timeout=600)
    last = last_line(out)
    try:
        m = re.search(expect, last) is not None
    except re.error:
        m = False
    d = 1 if (rc == 0 and m) else 0
    return d, ["d row-identity rc=%d last=%r pinned=%r" % (rc, last, expect)]


def ledger_leg(tree, base, tag):
    a, b, det = ledger_ab(tree, base, tag)
    c, cdet = journal_check(tree, base)
    d, ddet = identity_check(tree)
    led = 1 if (a and b and c and d) else 0
    return led, (a, b, c, d), det + cdet + ddet


# -------------------------------------------------------------- mutants/guard
def comment_mutant(tree):
    dst = os.path.join(S, "mutant-comment")
    copy_tree(tree, dst)
    p = os.path.join(dst, C1_REL)
    text = read(p)
    if text is None:
        setup("mutant: unreadable predicate file")
    lines = text.split("\n")
    idx = [i for i, l in enumerate(lines) if re.match(r"def predicate_ok\(", l)]
    if len(idx) != 1:
        setup("mutant: predicate def count %d" % len(idx))
    lines.insert(idx[0], "# verified >= 37, col15 >= 32")
    write(p, "\n".join(lines))
    return dst


def guard_selftest():
    rc, out = run(["bash", SELF, "--selftest", "--scratch", SCRATCH], timeout=900)
    found = C2_PASS_RE.findall(out)
    n = int(found[-1]) if (rc == 0 and len(found) == 1) else 0
    return (1 if n >= 10 else 0), n


def verdict_line(sub, led, guard):
    return "C2_TEETH: subfloor=%d ledger=%d guard=%d" % (sub, led, guard)


# -------------------------------------------------------------- selftest ----
def selftest():
    fx = os.path.join(S, "fx")
    os.makedirs(fx)
    res = []

    def case(name, ok):
        res.append((name, bool(ok)))

    def pred_file(name, text):
        p = os.path.join(fx, name + ".sh")
        write(p, text)
        return p

    SIG = "def predicate_ok(verified, col15, caught, guard, defects):\n"
    FLOORS = SIG + "    return (guard == 1 and caught == 6 and defects == 0 and verified >= 37 and col15 >= 32)\n"
    BLIND = SIG + "    return (guard == 1 and caught == 6 and defects == 0)\n"
    fl, _ = load_predicate(pred_file("floors", FLOORS))
    case("floors-fixture-accepted-by-leg", fl is not None and predicate_check(fl)[0])
    bl, _ = load_predicate(pred_file("blind", BLIND))
    case("blind-fixture-refused-by-leg", bl is not None and not predicate_check(bl)[0])
    cm, _ = load_predicate(pred_file("commented", "# verified >= 37, col15 >= 32\n" + BLIND))
    case("comment-only-fixture-refused-by-leg", cm is not None and not predicate_check(cm)[0])
    ct, _ = load_predicate(pred_file("const-true", SIG + "    return True\n"))
    case("constant-true-mutant-refused", ct is not None and not predicate_check(ct)[0])
    cf, _ = load_predicate(pred_file("const-false", SIG + "    return False\n"))
    case("constant-false-mutant-refused", cf is not None and not predicate_check(cf)[0])
    nd, _ = load_predicate(pred_file("nodef", "x = 1\n"))
    case("missing-def-not-loadable", nd is None)
    case("blind-witness-accepts-36", bl is not None and bool(bl(36, 31, 6, 1, 0)))
    src = extract_predicate(FLOORS + "x = 1\n")
    case("extract-stops-at-column-0", src is not None and "x = 1" not in src)

    LED = ("# header comment\n"
           "R68-01\tbash plans/round-68-c1.sh\t^a$\t0\t900\tnote\n"
           "R68-02\tbash plans/round-68-c2.sh\t^C2_RECORD: mismatches=0 population=3 guard=1$\t0\t3600\tnote\n"
           "R24-14\tbash corpus/row-identity.sh ledger-ids\t^ROW_IDENTITY: ledger-ids count=101 sha256=0$\t0\t30\tnote\n")
    red, n = reduce_ledger(LED)
    ids = [l.split("\t")[0] for l in (red or "").split("\n") if l and not l.startswith("#")]
    case("reducer-keeps-comments-and-one-r68-02", n == 1 and red is not None
         and red.split("\n")[0] == "# header comment" and ids == [ROW])
    case("reducer-refuses-missing-row", reduce_ledger("# c\nR1-01\tx\ty\t0\t1\tn\n")[0] is None)
    case("reducer-refuses-duplicate-row", reduce_ledger(LED + "R68-02\ttrue\t^x$\t0\t1\tdup\n")[0] is None)
    row = [l for l in red.split("\n") if l.startswith(ROW + "\t")][0]
    tr = with_command(row, "true").split("\t")
    case("true-command-keeps-expect-and-columns", tr[1] == "true" and tr[2] == row.split("\t")[2]
         and len(tr) == len(row.split("\t")))

    # scratch stamp re-pin: the stamp row must equal the bytes of the file it now pins
    rp = os.path.join(fx, "repin")
    write(os.path.join(rp, LEDGER_REL), red)
    write(os.path.join(rp, "corpus", "stamps.tsv"),
          "# header\ncorpus/claim-ledger.tsv\t" + "0" * 64 + "\t1\t1\nother.md\t" + "1" * 64 + "\t1\t1\n")
    rp_ok = repin_ledger_stamp(rp)
    srow = [l.split("\t") for l in read(os.path.join(rp, "corpus", "stamps.tsv")).split("\n")
            if l.startswith(LEDGER_REL + "\t")]
    data = read(os.path.join(rp, LEDGER_REL)).encode("utf-8")
    case("scratch-repin-matches-reduced-bytes", rp_ok and len(srow) == 1 and srow[0][1]
         == hashlib.sha256(data).hexdigest() and srow[0][2] == str(data.count(b"\n"))
         and srow[0][3] == str(len(data)))

    # executed ledger leg on fixtures: a row-executing stub must pass (a) and fail (b) on `true`
    ROWEXEC = (
        "#!/usr/bin/env bash\n"
        "row=$(awk -F'\\t' '$1==\"R68-02\"' corpus/claim-ledger.tsv)\n"
        "cmd=$(printf '%s\\n' \"$row\" | cut -f2)\n"
        "exp=$(printf '%s\\n' \"$row\" | cut -f3)\n"
        "out=$(bash -c \"$cmd\" 2>&1)\n"
        "last=$(printf '%s\\n' \"$out\" | awk 'NF{l=$0} END{print l}')\n"
        "if printf '%s\\n' \"$last\" | grep -Eq \"$exp\"; then\n"
        "  echo 'CLAIM_LEDGER: CLEAN (claims=1 deferred=0)'; exit 0\n"
        "fi\n"
        "echo 'FAIL R68-02 expect-mismatch'; echo 'CLAIM_LEDGER: FAILED (claims=1)'; exit 1\n")
    FIXROW = "R68-02\techo ok\t^ok$\t0\t30\tnote\n"
    fx_real = os.path.join(fx, "tree-real")
    write(os.path.join(fx_real, "corpus", "claim-ledger.sh"), ROWEXEC)
    write(os.path.join(fx_real, LEDGER_REL), "# c\n" + FIXROW)
    write(os.path.join(fx_real, "corpus", "stamps.tsv"), "corpus/claim-ledger.tsv\t" + "0" * 64 + "\t1\t1\n")
    a, b, _ = ledger_ab(fx_real, fx_real, "fx-real")
    case("row-executing-stub-passes-a-and-b", a == 1 and b == 1)

    fx_const = os.path.join(fx, "tree-const")
    write(os.path.join(fx_const, "corpus", "claim-ledger.sh"),
          "#!/usr/bin/env bash\necho 'CLAIM_LEDGER: CLEAN (claims=1 deferred=0)'\nexit 0\n")
    write(os.path.join(fx_const, LEDGER_REL), "# c\n" + FIXROW)
    write(os.path.join(fx_const, "corpus", "stamps.tsv"), "corpus/claim-ledger.tsv\t" + "0" * 64 + "\t1\t1\n")
    a2, b2, _ = ledger_ab(fx_const, fx_const, "fx-const")
    case("constant-clean-stub-fails-true-leg", a2 == 1 and b2 == 0)

    fx_id = os.path.join(fx, "tree-id")
    write(os.path.join(fx_id, LEDGER_REL),
          "R24-14\tbash corpus/row-identity.sh ledger-ids\t"
          "^ROW_IDENTITY: ledger-ids count=2 sha256=ab$\t0\t30\tnote\n")
    write(os.path.join(fx_id, "corpus", "row-identity.sh"),
          "#!/usr/bin/env bash\necho 'ROW_IDENTITY: ledger-ids count=2 sha256=ab'\n")
    d_ok, _ = identity_check(fx_id)
    case("identity-matches-row-pinned-expect", d_ok == 1)
    fx_id2 = os.path.join(fx, "tree-id2")
    write(os.path.join(fx_id2, LEDGER_REL),
          "R24-14\tbash corpus/row-identity.sh ledger-ids\t"
          "^ROW_IDENTITY: ledger-ids count=2 sha256=ab$\t0\t30\tnote\n")
    write(os.path.join(fx_id2, "corpus", "row-identity.sh"),
          "#!/usr/bin/env bash\necho 'ROW_IDENTITY: ledger-ids count=3 sha256=ab'\n")
    d_bad, _ = identity_check(fx_id2)
    case("identity-mismatch-refused", d_bad == 0)

    case("verdict-line-format", verdict_line(1, 1, 1) == "C2_TEETH: subfloor=1 ledger=1 guard=1")

    rc_n, out_n = run(["bash", SELF, "--tree", fx_real, "--scratch", os.path.join(S, "nest")],
                      env={"R69_C2_NESTED": "1"}, timeout=120)
    case("nested-invocation-refused-setup", rc_n == 2 and "C2_TEETH: SETUP" in out_n)
    rc_x, _ = run(["bash", SELF, "--bogus"], timeout=120)
    case("unknown-argument-refused", rc_x == 2)

    failed = [n for n, ok in res if not ok]
    if failed:
        print("C2_TEETH_SELFTEST: FAIL (%d cases, %d failed) names=%s"
              % (len(res), len(failed), ",".join(failed)))
        return 1
    print("C2_TEETH_SELFTEST: PASS (%d cases)" % len(res))
    return 0


def main():
    if SELFTEST == "1":
        return selftest()
    if not os.path.isdir(TREE):
        setup("bad tree: %s" % TREE)
    tree = real(TREE)
    if within(SCRATCH, tree):
        setup("scratch inside the measured tree")
    base = base_dir()
    print("c2-teeth: tree=%s base=%s" % (tree, base))

    sub_c, a, b, c, det = subfloor_leg(tree, base, "cand")
    print("LEG subfloor tree=cand a=%d b=%d c=%d subfloor=%d" % (a, b, c, sub_c))
    for l in det:
        vlog(l)
    led_c, (la, lb, lc, ld), ldet = ledger_leg(tree, base, "cand")
    print("LEG ledger tree=cand a=%d b=%d c=%d d=%d ledger=%d" % (la, lb, lc, ld, led_c))
    for l in ldet:
        vlog(l)

    sub_b, ba, bb, bc, bdet = subfloor_leg(base, base, "base")
    print("LEG subfloor tree=base a=%d b=%d c=%d subfloor=%d" % (ba, bb, bc, sub_b))
    for l in bdet:
        vlog(l)
    led_b, (lba, lbb, lbc, lbd), lbdet = ledger_leg(base, base, "base")
    print("LEG ledger tree=base a=%d b=%d c=%d d=%d ledger=%d" % (lba, lbb, lbc, lbd, led_b))
    for l in lbdet:
        vlog(l)

    mut = comment_mutant(base)
    sub_m, _, _, _, mdet = subfloor_leg(mut, base, "mut")
    print("LEG subfloor tree=comment-mutant subfloor=%d" % sub_m)
    for l in mdet:
        vlog(l)

    g_a = 1 if (sub_c == 1 and led_c == 1) else 0
    g_b = 1 if (sub_b == 0 and led_b == 0) else 0
    g_c = 1 if sub_m == 0 else 0
    g_d, n_cases = guard_selftest()
    guard = 1 if (g_a and g_b and g_c and g_d) else 0
    print("GUARD a=%d (measured reads subfloor=1 ledger=1) b=%d (BASE reads subfloor=0 ledger=0) "
          "c=%d (comment-only mutant subfloor=0) d=%d (selftest cases=%d)"
          % (g_a, g_b, g_c, g_d, n_cases))
    print(verdict_line(sub_c, led_c, guard))
    return 0 if (sub_c == 1 and led_c == 1 and guard == 1) else 1


sys.exit(main())
PY
rc=$?
exit "$rc"
