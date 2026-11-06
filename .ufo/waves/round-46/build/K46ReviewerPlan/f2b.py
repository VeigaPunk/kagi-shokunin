#!/usr/bin/env python3
# F2b: does one extra reference case (a claim with two plan headings on different axes and a
# manifest row for only one of them) separate the strict plan-to-manifest leg from the
# axis-blind leg of F2? Two trees: (i) BASE gate + case 11; (ii) F2 axis-blind gate + case 11.
import importlib.util, os, subprocess

S = os.environ["S"]
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
os.environ["HYAKU_SCRATCH"] = os.path.join(S, "hs")
os.makedirs(os.environ["HYAKU_SCRATCH"], exist_ok=True)
spec = importlib.util.spec_from_file_location("ctl", LANE + "/plans/round-46-controls.py")
ctl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ctl)
FX = os.path.join(S, "fx")
os.makedirs(FX, exist_ok=True)

CASE11 = (
    "  # case 11 (reference, attack K46RP-02): a claim with a second heading axis and no manifest row for it\n"
    "  mfix; printf 'round\\tclaim\\taxis\\n90\\tC1\\tfreshness\\n90\\tC2\\tcalibration\\n' > \"$s/corpus/claims-declared.tsv\"\n"
    "  printf '# fixture plan\\n\\n## C1 — freshness: a\\n\\n## C1 — depth: b\\n\\n## C2 — calibration: c\\n' > \"$s/plans/round-90.md\"\n"
    "  chk same-claim-second-axis \"$GATE_SRC\" 1 'MISMATCH 90 C1 no-manifest-row'\n"
)
TAIL11 = ctl.SELFTEST_TAIL.replace("-eq 8", "-eq 11").replace("(8 cases)", "(11 cases)")


def build(name, axis_blind):
    d = ctl.tree(FX, name)
    ctl.c1_positive(d)
    g = os.path.join(d, "corpus/claims-declared.sh")
    ctl.edit(g, ctl.REF_CASES + ctl.SELFTEST_TAIL.replace("-eq 8", "-eq 10").replace("(8 cases)", "(10 cases)"),
             ctl.REF_CASES + CASE11 + TAIL11)
    if axis_blind:
        ctl.edit(g, 'manifest_set["$mround/$mclaim/$maxis"]=1', 'manifest_set["$mround/$mclaim"]=1')
        ctl.edit(g, 'manifest_set["$rname/$hclaim/$haxis"]', 'manifest_set["$rname/$hclaim"]')
    return d


def score(d):
    env = dict(os.environ, C1_TREE=d)
    p = subprocess.run(["bash", LANE + "/plans/round-46-c1.sh"], env=env, capture_output=True, text=True)
    return p.returncode, (p.stdout.strip().splitlines() or ["<none>"])[-1]


for name, blind in (("f2b-strict", False), ("f2b-axis-blind", True)):
    d = build(name, blind)
    rc, line = score(d)
    print("%s\trc=%d\t%s" % (name, rc, line))
