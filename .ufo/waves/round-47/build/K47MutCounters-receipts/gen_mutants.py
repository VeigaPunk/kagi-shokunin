#!/usr/bin/env python3
"""Generate single-change mutant copies of the frozen round-47 counters.

Each mutation is applied to the pristine copy in mut/ (never to plans/) by one
exact-string replacement; a missing pattern aborts instead of yielding a no-op
mutant. Writes mut/<id>-c1.sh | mut/<id>-c2.sh and mut/<id>.diff.
"""
import difflib
import json
import os
import sys

S = "/fast/scratch/hyaku/kagi-r47/K47MutCounters"
MUT = os.path.join(S, "mut")

PRISTINE = {
    "c1": open(os.path.join(MUT, "c1-pristine.sh"), encoding="utf-8").read(),
    "c2": open(os.path.join(MUT, "c2-pristine.sh"), encoding="utf-8").read(),
}

# (id, counter, description, old, new)
MUTANTS = [
    # ---------------- C1 (C1_CENSUS_CALIBRATION) ----------------
    ("C1-M1-drop-new-conjunct", "c1",
     "value gate no longer requires NEW = 0",
     '[ "$intact" -eq 1 ] && [ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared',
     '[ "$intact" -eq 1 ] && [ "$bound" -eq 1 ] && value=$cleared'),
    ("C1-M2-no-new-scan", "c1",
     "NEW is never computed (new=0)",
     'new=$(printf \'%s\\n\' "$out" | grep \'^FINDING \' | grep -vxF -e "$F1" -e "$F2" -e "$F3" | wc -l)',
     'new=0'),
    ("C1-M3-drop-bound-conjunct", "c1",
     "value gate no longer requires BOUND = 1",
     '[ "$intact" -eq 1 ] && [ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared',
     '[ "$intact" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared'),
    ("C1-M4-drop-intact-conjunct", "c1",
     "value gate no longer requires INTACT = 1",
     '[ "$intact" -eq 1 ] && [ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared',
     '[ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared'),
    ("C1-M5-ignore-status-cell", "c1",
     "registry status comparison dropped (row presence only)",
     '  [ "$mst" = "$st" ] || { intact=0; why="$why status:$id"; }\n', ''),
    ("C1-M6-accept-dup-registry-rows", "c1",
     "duplicate registry ids accepted (exactly-one becomes at-least-one)",
     '| wc -l)" -eq 1 ] || { intact=0; why="$why row-count:$id"; continue; }',
     '| wc -l)" -ge 1 ] || { intact=0; why="$why row-count:$id"; continue; }'),
    ("C1-M7-drop-capture-sha", "c1",
     "committed capture compared by existence only, not sha256",
     '  if [ -f "$C" ]; then\n'
     '    [ "$(sha256sum < "$C" | cut -d\' \' -f1)" = "$bsha" ] || { bound=0; why="$why capture-sha"; }\n'
     '  else\n'
     '    bound=0; why="$why capture-missing"\n'
     '  fi',
     '  [ -f "$C" ] || { bound=0; why="$why capture-missing"; }'),
    ("C1-M8-drop-row-sha", "c1",
     "S099 row column-10 sha256 check dropped (bytes still checked)",
     '  [ "${R[9]:-}" = "$bsha" ] || { bound=0; why="$why sha"; }\n', ''),
    ("C1-M9-accept-non-census-output", "c1",
     "fail-closed census check removed (any output accepted)",
     'case $last in\n'
     '  "SOURCES_CENSUS: CLEAN "*|"SOURCES_CENSUS: FAILED "*) ;;\n'
     '  *) setup "census-output:${last:-empty}" ;;\n'
     'esac',
     ':'),
    ("C1-M10-drop-single-s099-row", "c1",
     "exactly-one S099 row rule made unreachable (count never rejects)",
     'if [ "$n99" -ne 1 ]; then', 'if [ "$n99" -lt 0 ]; then'),
    ("C1-M11-invert-cleared", "c1",
     "CLEARED counts present findings instead of absent ones",
     'printf \'%s\\n\' "$out" | grep -qxF -- "$f" || cleared=$((cleared + 1))',
     'printf \'%s\\n\' "$out" | grep -qxF -- "$f" && cleared=$((cleared + 1))'),
    ("C1-M12-loose-cleared-match", "c1",
     "CLEARED matched by substring instead of whole line",
     'grep -qxF -- "$f"', 'grep -qF -- "$f"'),
    ("C1-M13-relax-base-102-guard", "c1",
     "BASE registry row-count guard relaxed from exactly 102",
     '[ "$nb" -eq 102 ] || setup "base-rows=$nb"',
     '[ "$nb" -ge 1 ] || setup "base-rows=$nb"'),
    ("C1-M14-drop-blob-quote-check", "c1",
     "S099 quote no longer required to occur in the fleet blob",
     '  if [ -z "$q" ] || ! grep -qF -- "$q" "$SCR/b/blob"; then bound=0; why="$why quote"; fi\n',
     ''),

    # ---------------- C2 (C2_FIRED_REVERIFIED) ----------------
    ("C2-M1-drop-date-window", "c2",
     "fetched_at freshness window removed",
     '  [ "$fe" -ge "$FLOOR" ] && [ "$fe" -le "$ASOF" ] || { bad="$bad $id:fetched-window"; continue; }\n',
     ''),
    ("C2-M2-invert-upper-window", "c2",
     "upper bound of the freshness window inverted (-le -> -ge)",
     '[ "$fe" -ge "$FLOOR" ] && [ "$fe" -le "$ASOF" ]',
     '[ "$fe" -ge "$FLOOR" ] && [ "$fe" -ge "$ASOF" ]'),
    ("C2-M3-drop-gate-conjunct", "c2",
     "value no longer multiplied by the release-clock gate",
     '[ "$gate" -eq 1 ] && value=$n', 'value=$n'),
    ("C2-M4-gate-rc-ignored", "c2",
     "gate accepts a non-CLEAN last line and ignores exit code",
     '[ "$grc" -eq 0 ] && [[ $glast == "RELEASE_CLOCK: CLEAN"* ]] && gate=1',
     '[[ $glast == *"RELEASE_CLOCK:"* ]] && gate=1'),
    ("C2-M5-drop-quote-swap", "c2",
     "measured column-13 quote no longer compared to the BASE quote",
     '  [ "$mq" = "$bq" ] || { bad="$bad $id:quote-swapped"; continue; }\n', ''),
    ("C2-M6-drop-quote-count", "c2",
     "located count no longer required to equal quote_count",
     '  [ "$k" = "$qc" ] || { bad="$bad $id:quote-count"; continue; }\n', ''),
    ("C2-M7-accept-zero-count", "c2",
     "not-located threshold relaxed to K >= 0",
     '[ "$k" -ge 1 ] || { bad="$bad $id:not-located"; continue; }',
     '[ "$k" -ge 0 ] || { bad="$bad $id:not-located"; continue; }'),
    ("C2-M8-drop-verdict", "c2",
     "verdict column no longer required to be teaching-holds",
     '  [ "$verdict" = teaching-holds ] || { bad="$bad $id:verdict"; continue; }\n', ''),
    ("C2-M9-drop-capture-bytes", "c2",
     "capture byte count no longer compared",
     '  [ "$(wc -c < "$T/$cap")" = "$bytes" ] || { bad="$bad $id:capture-bytes"; continue; }\n', ''),
    ("C2-M10-drop-dotdot", "c2",
     "..-traversal guard on capture_path removed",
     '  case "/$cap/" in */../*) bad="$bad $id:capture-dotdot"; continue ;; esac\n', ''),
    ("C2-M11-drop-capture-prefix", "c2",
     "capture_path no longer required under .ufo/waves/round-47/capture/",
     '  case $cap in .ufo/waves/round-47/capture/*) ;; *) bad="$bad $id:capture-path"; continue ;; esac\n',
     ''),
    ("C2-M12-accept-dup-ledger-rows", "c2",
     "exactly-one ledger row rule relaxed to at-least-one",
     '[ "$c" -eq 1 ] || { bad="$bad $id:rows=$c"; continue; }',
     '[ "$c" -ge 1 ] || { bad="$bad $id:rows=$c"; continue; }'),
    ("C2-M13-drop-url-check", "c2",
     "ledger url no longer compared to the registry source cell",
     '  [ -n "$rurl" ] && [ "$url" = "$rurl" ] || { bad="$bad $id:url"; continue; }\n', ''),
    ("C2-M14-drop-release-check", "c2",
     "observed_release no longer compared to release-clocks.tsv",
     '  [ -n "$ov" ] && [ "$rel" = "$ov" ] || { bad="$bad $id:release"; continue; }\n', ''),
    ("C2-M15-drop-normalizer-setup", "c2",
     "missing-normalizer fail-closed check removed",
     '[ -f "$T/corpus/rendered-text-v1.py" ] || setup missing-normalizer\n', ''),
    ("C2-M16-drop-capture-sha", "c2",
     "capture sha256 no longer compared to the ledger",
     '  [ "$(sha256sum < "$T/$cap" | cut -d\' \' -f1)" = "$sha" ] || { bad="$bad $id:capture-sha"; continue; }\n',
     ''),

    # ---------------- combined (declared as two changes) ----------------
    ("C2-X1-swap-and-count-off", "c2",
     "quote-swap compare AND quote-count equality both dropped (two changes)",
     '  [ "$mq" = "$bq" ] || { bad="$bad $id:quote-swapped"; continue; }\n', ''),
]


def main():
    manifest = []
    for mid, ctr, desc, old, new in MUTANTS:
        src = PRISTINE[ctr]
        if src.count(old) != 1:
            print("SETUP: pattern count %d in %s for %s" % (src.count(old), ctr, mid))
            return 2
        out = src.replace(old, new, 1)
        if mid.startswith("C2-X1"):
            second = '  [ "$k" = "$qc" ] || { bad="$bad $id:quote-count"; continue; }\n'
            if out.count(second) != 1:
                print("SETUP: second pattern for %s" % mid)
                return 2
            out = out.replace(second, "", 1)
        path = os.path.join(MUT, "%s-%s.sh" % (mid, ctr))
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(out)
        os.chmod(path, 0o755)
        diff = "".join(difflib.unified_diff(src.splitlines(True), out.splitlines(True),
                                            "pristine-%s" % ctr, mid, n=2))
        with open(os.path.join(MUT, mid + ".diff"), "w", encoding="utf-8") as fh:
            fh.write(diff)
        manifest.append({"id": mid, "counter": ctr, "change": desc,
                         "diff": diff.strip().splitlines()})
    with open(os.path.join(MUT, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=1)
    print("MUTANTS: %d" % len(manifest))
    for m in manifest:
        print(m["id"], m["counter"], "|", m["change"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
