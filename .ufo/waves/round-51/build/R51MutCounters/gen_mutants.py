#!/usr/bin/env python3
"""Generate single-point mutants of the frozen round-51 counters into scratch.

Each mutant is exactly one textual change; the script asserts the anchor occurs
exactly once in the pristine source, so a mutant can never quietly be a no-op.
"""
import os
import shutil
import sys

S = "/fast/scratch/hyaku/kagi-r51/R51MutCounters"
LANE = os.path.join(S, "lane")
OUT = os.path.join(S, "mut")


def load(name):
    with open(os.path.join(LANE, "plans", name), "rb") as f:
        return f.read().decode()


def one(text, old, new):
    n = text.count(old)
    if n != 1:
        raise SystemExit("anchor count %d != 1 for %r" % (n, old[:70]))
    return text.replace(old, new, 1)


def blk(text, old, new=""):
    n = text.count(old)
    if n != 1:
        raise SystemExit("block count %d != 1 for %r" % (n, old[:70]))
    return text.replace(old, new, 1)


MUT = []

# ---------------- C1 (plans/round-51-c1.sh) ----------------
C1 = "round-51-c1.sh"


def c1(mid, note, fn):
    t = load(C1)
    MUT.append((mid, C1, note, fn(t)))


c1(
    "C1-M1",
    "drop the shim-BROKEN conjunct in the per-test discriminator",
    lambda t: one(
        t,
        'ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$ev" = 1 ] && ok=1',
        'ok=0; [ "$rv" = HOLDS ] && [ "$ev" = 1 ] && ok=1',
    ),
)

c1(
    "C1-M2",
    "drop the shuf: the seven runs execute in fixed order",
    lambda t: one(
        t,
        "for m in $(printf '%s\\n' real none sh1 sh2 sh3 sh4 sh5 | shuf); do run \"$m\"; RC[$m]=$?; done",
        'for m in real none sh1 sh2 sh3 sh4 sh5; do run "$m"; RC[$m]=$?; done',
    ),
)

c1(
    "C1-M3",
    "fixed, mode-named bin dir instead of a fresh random hex name",
    lambda t: one(t, 'd="$W/$(rhex)"', 'd="$W/bin-$m"'),
)

c1(
    "C1-M4",
    "drop the SRC conjunct from the final guard",
    lambda t: one(
        t,
        '[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] && [ $src -eq 1 ] || final=0',
        '[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] || final=0',
    ),
)

c1(
    "C1-M5",
    "drop the knowledge-entry conjunct (entry=$ev) from the discriminator",
    lambda t: one(
        t,
        'ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$ev" = 1 ] && ok=1',
        'ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && ok=1',
    ),
)

c1(
    "C1-M6",
    "NOSECRET regex loses the r51-<24 hex> nonce alternative",
    lambda t: one(
        t,
        "'(^|[^A-Za-z0-9])(s|b|r|hvs)\\.[A-Za-z0-9]{20,}|r51-[0-9a-f]{24}'",
        "'(^|[^A-Za-z0-9])(s|b|r|hvs)\\.[A-Za-z0-9]{20,}'",
    ),
)

c1(
    "C1-M7",
    "drop the setup_ok conjunct from the final guard",
    lambda t: one(
        t,
        '[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] && [ $src -eq 1 ] || final=0',
        '[ $nosecret -eq 1 ] && [ $pins -eq 1 ] && [ $src -eq 1 ] || final=0',
    ),
)

c1(
    "C1-M8",
    "NOSECRET regex loses the token-shaped alternative (keeps only r51-)",
    lambda t: one(
        t,
        "'(^|[^A-Za-z0-9])(s|b|r|hvs)\\.[A-Za-z0-9]{20,}|r51-[0-9a-f]{24}'",
        "'r51-[0-9a-f]{24}'",
    ),
)

# ---------------- C2 (plans/round-51-c2.sh) ----------------
C2 = "round-51-c2.sh"


def c2(mid, note, fn):
    t = load(C2)
    MUT.append((mid, C2, note, fn(t)))


c2(
    "C2-M1",
    "drop guard g2 (BASE round-*.md byte-identity) entirely",
    lambda t: blk(
        t,
        '# g2\nfor f in "$W"/b/plans/round-*.md; do\n  n=${f#"$W/b/"}\n  cmp -s "$f" "$W/t/$n" || setup "g2-changed:$n"\ndone\n',
        '# g2 (mutant: guard removed)\n',
    ),
)

c2(
    "C2-M2",
    "drop guard g3 (BASE manifest rows present unchanged) entirely",
    lambda t: blk(
        t,
        'grep -vE \'^(#|round\t|$)\' "$W/b/corpus/claims-declared.tsv" > "$W/base-rows" || setup g3-base-empty\n'
        'while IFS= read -r row; do\n'
        '  grep -qxF -- "$row" "$W/t/corpus/claims-declared.tsv" || setup "g3-row-missing:$(printf \'%s\' "$row" | tr \'\\t\' \' \')"\n'
        'done < "$W/base-rows"\n',
        '# g3 (mutant: guard removed)\n',
    ),
)

c2(
    "C2-M3",
    "count MISMATCH without the line anchor (the summary line also matches)",
    lambda t: one(t, "M=$(grep -c '^MISMATCH ' \"$W/cd.out\")", "M=$(grep -c 'MISMATCH' \"$W/cd.out\")"),
)

c2(
    "C2-M4",
    "ignore V: no round-48 capability reading is added",
    lambda t: one(
        t,
        "V=$(sed -nE 's/^C2_CAPABILITY_READINGS: value=([0-9]+) .*/\\1/p' \"$W/r48.out\" | head -n 1)",
        "V=0",
    ),
)

c2(
    "C2-M5",
    "drop guard g1-gate (the claims-declared.sh sha256 pin)",
    lambda t: one(
        t,
        '[ "$(sha256sum < "$W/t/corpus/claims-declared.sh" 2>/dev/null | cut -d\' \' -f1)" = "$PIN_GATE" ] || setup g1-gate-changed\n',
        "",
    ),
)

c2(
    "C2-M6",
    "measure the BASE tree instead of the requested revision",
    lambda t: one(
        t,
        'git -C "$LANE" archive "$REV" | tar -x -C "$W/t" || setup archive',
        'git -C "$LANE" archive "$BASE" | tar -x -C "$W/t" || setup archive',
    ),
)

c2(
    "C2-M7",
    "drop guard g1-r48-working-copy (lane working copy sha256 pin)",
    lambda t: one(
        t,
        '[ "$(sha256sum < "$LANE/plans/round-48-c2.sh" | cut -d\' \' -f1)" = "$PIN_R48" ] || setup g1-r48-working-copy\n',
        "",
    ),
)

c2(
    "C2-M8",
    "drop guard g4's final-line shape check for claims-declared",
    lambda t: one(
        t,
        'printf \'%s\' "$last" | grep -qE \'^CLAIMS_DECLARED: (CLEAN \\(claims=[0-9]+\\)|MISMATCH \\(claims=[0-9]+ mismatch=[0-9]+\\))$\' || setup "g4-claims-declared(rc=$cd_rc)"\n',
        "",
    ),
)


def main():
    shutil.rmtree(OUT, ignore_errors=True) if False else None
    os.makedirs(OUT, exist_ok=True)
    for mid, name, note, text in MUT:
        d = os.path.join(OUT, mid)
        os.makedirs(os.path.join(d, "plans"), exist_ok=True)
        src = os.path.join(LANE, "plans", name)
        dst = os.path.join(d, "plans", name)
        shutil.copyfile(src, dst)
        with open(dst, "w") as f:
            f.write(text)
        with open(os.path.join(d, "note.txt"), "w") as f:
            f.write(note + "\n")
        with open(os.path.join(d, "orig"), "w") as f:
            f.write(os.path.join(LANE, name) + "\n")
    print("wrote", len(MUT), "mutants to", OUT)


if __name__ == "__main__":
    main()
