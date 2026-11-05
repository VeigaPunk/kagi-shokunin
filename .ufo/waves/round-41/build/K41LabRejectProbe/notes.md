# notes.md — seat K41LabRejectProbe (S098 reject falsification probe)

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master, predeclaration 5142b52).
Scratch S = /fast/scratch/hyaku/kagi-r41/K41LabRejectProbe (created with mkdir -p, deleted at end).
No git clone was created: the probe reads no lane file, and no lane tree path was edited except the
three deliverables below (the seat-named build dir). No git/jj mutation anywhere.

## Commands executed (cwd = /home/vgpnk/Projects/shokunin unless stated)

1. `mkdir -p "$S"` -> mkdir_scratch_rc=0
2. `mkdir -p ".../kagi-shokunin/.ufo/waves/round-41/build/K41LabRejectProbe"` -> mkdir_deliv_rc=0
3. `python3 --version` -> `Python 3.14.8`, rc 0
4. `python3 -c 'import unicodedata; print("unidata_version", unicodedata.unidata_version)'`
   -> `unidata_version 16.0.0`, rc 0
5. `curl -fsSL -o "$S/PropList.txt" 'https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt'`
   -> curl_rc=0; 149040 bytes;
   sha256 = f438f532e8737bb8a2702126cdf9c4af5e357c58c7acf9d9eb2fc7c1a1d955d6;
   header line 1 `# PropList-18.0.0.txt`, line 2 `# Date: 2026-08-07, 16:20:14 GMT` (fetched 2026-11-05);
   `grep -c 'White_Space'` = 17 (property lines + comment mentions)
6. `python3 "$D/probe.py" --proplist "$S/PropList.txt" > "$D/probe.txt" 2>&1` -> probe_rc=0,
   probe.txt is 21 lines, exact canonical outputs (deliverable).
7. Version-matched cross-check (supplementary, kept out of the lane; outputs in scratch, now deleted;
   key lines quoted verbatim from the run):
   `curl -fsSL -o "$S/PropList-16.0.0.txt" 'https://www.unicode.org/Public/16.0.0/ucd/PropList.txt'`
   -> curl160_rc=0; sha256 = 53d614508e2a0b2305a8aa21cd60d993de9326cdf65993660dfcce4503548583
   `python3 "$D/probe.py" --proplist "$S/PropList-16.0.0.txt" > "$S/probe-16.0.0.txt" 2>&1`
   -> probe160_rc=0; grepped lines:
   `proplist_version_line: # PropList-16.0.0.txt` / `A_size: 29` / `B_size: 25` /
   `A_minus_B_count: 4` / `A_minus_B_members: U+001C U+001D U+001E U+001F` /
   `B_minus_A_count: 0` / `VERDICT: H0 holds (A_minus_B_count=4, U+001C..U+001F all in A-B)`
8. `rm -rf -- "$S"` -> rm_scratch_rc=0; `test -d "$S"` -> scratch_absent.

## Result

VERDICT: H0 holds (A_minus_B_count=4, U+001C..U+001F all in A-B).
A (str.isspace, CPython 3.14.8 / unicodedata 16.0.0) = 29 code points.
B (White_Space, UCD 18.0.0 PropList) = 25 code points from 11 range lines.
A-B = {U+001C, U+001D, U+001E, U+001F} exactly; B-A = empty.

## Step-5 version analysis

unidata_version (16.0.0) differs from the fetched latest PropList (18.0.0). A reflects the Unicode
version bundled in CPython's unicodedata (16.0.0); B reflects the fetched latest UCD (18.0.0). The
membership of U+001C..U+001F does not depend on that version difference, measured: with B rebuilt
from the version-matched PropList-16.0.0.txt (the exact UCD CPython bundles), A-B is still exactly
the same four code points and B-A is still empty. The difference is definitional to str.isspace,
not a version artifact.

## Installs

none (no tool installed or upgraded; pacman untouched).

## Defects observed

none. Deliverables: probe.py, probe.txt, notes.md (this file) under
.ufo/waves/round-41/build/K41LabRejectProbe/; seat report at
.ufo/waves/round-41/build/K41LabRejectProbe.md.
