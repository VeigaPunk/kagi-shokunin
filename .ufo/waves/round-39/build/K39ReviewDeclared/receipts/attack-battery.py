#!/usr/bin/env python3
# Attack battery for corpus/claims-declared.sh (C2 declared-axis gate), seat K39ReviewDeclared.
# Mutations are done in Python (exact string edits) to avoid sed BRE pitfalls.
import os, shutil, subprocess

S = "/fast/scratch/hyaku/kagi-r39/K39ReviewDeclared"
GATE = f"{S}/cand/corpus/claims-declared.sh"
D = f"{S}/attack"

PLAN_T = "# fixture plan\n\n## C1 — freshness: fixture claim one\n\n## C2 — calibration: fixture claim two\n"
CARD_T = (
    "# fixture scorecard\n\n## Round 39 — post-move (fixture)\n\n"
    "| Axis | Before | What moved | Evidence |\n|---|---|---|---|\n"
    "| freshness | 9 | [C1] fixture move one | none |\n"
    "| calibration | 9 | [C2] fixture move two | none |\n\n"
    "## Round 38 — post-move (fixture)\n\n"
    "| Axis | Before | What moved | Evidence |\n|---|---|---|---|\n"
    "| calibration | 9 | [C2] older row, must not be read | none |\n"
)
TSV_T = "round\tclaim\taxis\n39\tC1\tfreshness\n39\tC2\tcalibration\n"


def fixture(name, plan=None, card=None, tsv=None):
    d = f"{D}/{name}"
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(f"{d}/corpus", exist_ok=True)
    os.makedirs(f"{d}/plans", exist_ok=True)
    open(f"{d}/corpus/claims-declared.tsv", "w").write(tsv if tsv is not None else TSV_T)
    open(f"{d}/plans/round-39.md", "w").write(plan if plan is not None else PLAN_T)
    open(f"{d}/SCORECARD.md", "w").write(card if card is not None else CARD_T)
    return d


def run(d):
    p = subprocess.run(["bash", GATE, "--root", d], capture_output=True, text=True)
    out = (p.stdout + p.stderr).strip().replace("\n", " || ")
    print(f"{os.path.basename(d):26s} rc={p.returncode} out=[{out}]")
    return p.returncode, p.stdout


results = {}

results["base"] = run(fixture("base"))

d = fixture("a1_dup_manifest", tsv=TSV_T + "39\tC2\tcalibration\n")
results["a1_dup_manifest"] = run(d)

d = fixture("a1b_dup_conflict", tsv=TSV_T + "39\tC2\tdepth\n")
results["a1b_dup_conflict"] = run(d)

plan = PLAN_T.replace("## C1 — freshness: fixture claim one",
                      "```sh\n## C1 — freshness: fixture claim one\n```")
results["a2_fence_heading"] = run(fixture("a2_fence_heading", plan=plan))

plan = PLAN_T.replace("## C1 — freshness: fixture claim one", "")
plan += "<!-- ## C1 — freshness: fake inside comment -->\n"
results["a2b_comment_heading"] = run(fixture("a2b_comment_heading", plan=plan))

plan = PLAN_T.replace("## C2 — calibration:", "##  C2 — calibration:")
results["a2c_spacing"] = run(fixture("a2c_spacing", plan=plan))

card = CARD_T.replace("| freshness | 9 | [C1] fixture move one | none |\n", "")
results["a3_missing_row"] = run(fixture("a3_missing_row", card=card))

card = CARD_T.replace("| freshness | 9 | [C1] fixture move one | none |",
                      "| calibration | 9 | [C2] fixture move one | none |")
results["a4_dup_tag"] = run(fixture("a4_dup_tag", card=card))

card = CARD_T.replace("[C2] older row, must not be read", "[C2] fixture move two")
results["a4b_cross_section_tag"] = run(fixture("a4b_cross_section_tag", card=card))

card = CARD_T.replace("| calibration | 9 | [C2] fixture move two | none |\n", "")
card = card.replace("[C2] older row, must not be read", "[C2] fixture move two")
results["a5_wrong_section"] = run(fixture("a5_wrong_section", card=card))

tsv = TSV_T.replace("39\tC2\tcalibration", "39\tC2\tdepth")
plan = PLAN_T.replace("## C2 — calibration:", "## C2 — depth:")
card = CARD_T.replace("| calibration | 9 | [C2]", "| depth | 9 | [C2]")
results["a6_axis_relevance"] = run(
    fixture("a6_axis_relevance", plan=plan, card=card, tsv=tsv))

plan = PLAN_T.replace("## C2 — calibration:", "## C2 — depth:")
results["a6b_heading_only"] = run(fixture("a6b_heading_only", plan=plan))

plan = PLAN_T.replace("## C1 — freshness: fixture claim one",
                      "## C1 — freshness: fixture claim one ANCHOR-TAIL")
results["a7_suffix_after_colon"] = run(fixture("a7_suffix_after_colon", plan=plan))

card = CARD_T.replace("| freshness | 9 | [C1]", "|   freshness   | 9 | [C1]")
results["a8_padded_first_cell"] = run(fixture("a8_padded_first_cell", card=card))

card = CARD_T.replace("## Round 39 — post-move", "## Round  39 — post-move")
results["a9_double_space_heading"] = run(fixture("a9_double_space_heading", card=card))

plan = PLAN_T.replace("## C1 — freshness: fixture claim one",
                      "## C1 — freshness:  trailing")
results["a10_trailing_after_colon"] = run(fixture("a10_trailing_after_colon", plan=plan))

results["base_again"] = run(fixture("base_again"))

print("\n== ASSESSMENT ==")
checks = [
    ("a1_dup_manifest", 0, "red: duplicate identical manifest row NOT caught; claims counter inflated"),
    ("a1b_dup_conflict", 1, "duplicate manifest row with conflicting axis caught"),
    ("a2_fence_heading", 1, "heading inside code fence caught"),
    ("a2b_comment_heading", 1, "heading inside HTML comment caught"),
    ("a2c_spacing", 1, "double-space heading caught"),
    ("a3_missing_row", 1, "missing tagged row caught"),
    ("a4_dup_tag", 1, "duplicate tags within section caught"),
    ("a4b_cross_section_tag", 1, "tag counted across sections caught"),
    ("a5_wrong_section", 1, "tagged row in wrong section caught"),
    ("a6_axis_relevance", 1, "consistent wrong-axis relabel caught"),
    ("a6b_heading_only", 1, "heading-only relabel caught"),
    ("a7_suffix_after_colon", 0, "suffix after heading colon over-matches"),
    ("a8_padded_first_cell", 1, "padded first cell not trimmed -> mismatch"),
    ("a9_double_space_heading", 1, "double-space Round heading caught"),
    ("a10_trailing_after_colon", 0, "infix match accepts altered heading text"),
    ("base_again", 0, "baseline determinism"),
]
ok = True
for name, want, why in checks:
    rc, _ = results[name]
    bad = rc != want
    if bad:
        ok = False
    tag = ("DETECT-AS-EXPECTED" if want == 1 and not bad else
           "PASS-THROUGH-AS-EXPECTED" if want == 0 and not bad else
           ("DEFECT: undetected" if want == 1 else "DEFECT: over-match/false-clean"))
    print(f"{name:26s} rc={rc} want={want}  {'!! ' + tag if bad else tag}  // {why}")
print("ALL-AS-EXPECTED" if ok else "ANOMALIES-PRESENT")
