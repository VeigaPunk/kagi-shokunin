#!/usr/bin/env python3
"""Round-48 C2 control fixtures: rewrite a scratch SCORECARD.md copy in one named mode.

reference  one current-readings line inside `## Capabilities` for K02, K07, K10
delete     the three stale `cmd` => `out` pairs lose their reading (pairs deleted)
elsewhere  the reference line appended at the end of the file (outside the section)
partial    current reading for K10 only
wrongnum   reference line with claims=22 for K07
"""
import sys

K02 = ("python3 -I -B corpus/quote-locate.py", "QUOTE_LOCATE: CLEAN located=8 rows=8")
K07 = ("bash corpus/claims-declared.sh --root .", "CLAIMS_DECLARED: CLEAN (claims=21)")
K10 = ("bash corpus/claims-declared.sh --selftest", "CLAIMS_DECLARED_SELFTEST: PASS (12 cases)")
STALE = {
    K02[0]: "QUOTE_LOCATE: CLEAN located=5 rows=5",
    K07[0]: "CLAIMS_DECLARED: CLEAN (claims=2)",
    K10[0]: "CLAIMS_DECLARED_SELFTEST: PASS (8 cases)",
}


def line(pairs):
    return "Current readings (fixture): " + "; ".join(f"`{c}` ⇒ `{o}`" for c, o in pairs) + ".\n"


def main():
    mode, path = sys.argv[1], sys.argv[2]
    text = open(path, encoding="utf-8").read()
    lines = text.splitlines(keepends=True)
    start = lines.index("## Capabilities\n")
    end = next(i for i in range(start + 1, len(lines)) if lines[i].startswith("## "))
    if mode in ("reference", "partial", "wrongnum"):
        pairs = {"reference": [K02, K07, K10], "partial": [K10],
                 "wrongnum": [K02, (K07[0], "CLAIMS_DECLARED: CLEAN (claims=22)"), K10]}[mode]
        lines.insert(end, line(pairs) + "\n")
    elif mode == "elsewhere":
        if not lines[-1].endswith("\n"):
            lines[-1] += "\n"
        lines.append("\n" + line([K02, K07, K10]))
    elif mode == "delete":
        for i in range(start, end):
            for cmd, out in STALE.items():
                lines[i] = lines[i].replace(f"`{cmd}` ⇒ `{out}`", f"`{cmd}`")
    else:
        sys.exit(f"unknown mode {mode}")
    open(path, "w", encoding="utf-8").write("".join(lines))


if __name__ == "__main__":
    main()
