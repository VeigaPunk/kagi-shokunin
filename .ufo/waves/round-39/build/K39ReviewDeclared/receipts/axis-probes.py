#!/usr/bin/env python3
# Tag-central = the exact middle row; padded/left-shifted variants of the C2 scorecard axis cell.
import os, shutil, subprocess
S="/fast/scratch/hyaku/kagi-r39/K39ReviewDeclared"
GATE=f"{S}/cand/corpus/claims-declared.sh"
D=f"{S}/attack"; card0=open(f"{D}/base/SCORECARD.md").read()
plan0=open(f"{D}/base/plans/round-39.md").read()
tsv="round\tclaim\taxis\n39\tC1\tfreshness\n39\tC2\tcalibration\n"

def run(name, card):
    d=f"{D}/{name}"
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(f"{d}/corpus"); os.makedirs(f"{d}/plans")
    open(f"{d}/corpus/claims-declared.tsv","w").write(tsv)
    open(f"{d}/plans/round-39.md","w").write(plan0)
    open(f"{d}/SCORECARD.md","w").write(card)
    p=subprocess.run(["bash",GATE,"--root",d],capture_output=True,text=True)
    print(f"{name:30s} rc={p.returncode} out=[{p.stdout.strip().replace(chr(10),' || ')}]")

# real C2 row '| calibration | 9 | [C2] fixture move two | none |'
run("k1_pad_axis_left",   card0.replace("| calibration | 9 | [C2]","|    calibration | 9 | [C2]"))
run("k2_pad_axis_right",  card0.replace("| calibration | 9 | [C2]","| calibration    | 9 | [C2]"))
run("k3_axis_uppercase",  card0.replace("| calibration | 9 | [C2]","| CALIBRATION | 9 | [C2]"))
run("k4_axis_typo",       card0.replace("| calibration | 9 | [C2]","| calibratoin | 9 | [C2]"))
run("k5_axis_c2_first",   card0.replace("| calibration | 9 | [C2]","| C2 | 9 | [C2]"))
# tag variant separators: ' [C2]' inside cell with leading space vs pipe-adjacent
run("k6_tag_in_middle_cell", card0.replace("| [C2] fixture move two |","| mid [C2] mid |"))
# axis cell missing entirely but tag there (damp8 variant) plus evidence mention
run("k7_axis_cell_evidence", card0.replace("| calibration | 9 | [C2] fixture move two | none |","| [C2] fixture move two | 9 | evidence | none |"))
