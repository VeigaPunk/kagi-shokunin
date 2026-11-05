# K41LabRejectProbe — S098 reject falsification probe (round 41, 2026-11-05)

VERDICT: **H0 holds** (A_minus_B_count=4, U+001C..U+001F all in A-B). The S098 reject premise is
measured, not falsified: `str.isspace()` and Unicode `White_Space` differ on exactly
U+001C, U+001D, U+001E, U+001F.

## Measured sets

- A = {c in 0..0x10FFFF : chr(c).isspace()} under CPython 3.14.8, unicodedata 16.0.0: **29** code points.
- B = White_Space parsed from `https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt`
  (fetched 2026-11-05; `# PropList-18.0.0.txt`, `# Date: 2026-08-07, 16:20:14 GMT`;
  sha256 `f438f532e8737bb8a2702126cdf9c4af5e357c58c7acf9d9eb2fc7c1a1d955d6`; 11 range lines): **25** code points.
- A−B = **4**: U+001C U+001D U+001E U+001F (each `isspace=True White_Space=False`).
- B−A = **0** (empty).

## Step-5 version analysis

unidata_version 16.0.0 ≠ PropList 18.0.0: A reflects the UCD bundled in CPython (16.0.0); B reflects
the fetched latest UCD (18.0.0). Membership of U+001C..U+001F in A−B does **not** depend on that gap —
measured, version-matched cross-check with `PropList-16.0.0.txt` (sha256
`53d614508e2a0b2305a8aa21cd60d993de9326cdf65993660dfcce4503548583`, curl rc 0) gives the identical
A−B = the four code points, B−A empty, VERDICT identical. The difference is definitional to
`str.isspace`, not a version artifact; White_Space is identical across the two fetched versions
(25 cps both).

## Bearing on the round

S098 reject (UTS #18 `\s` as `\p{White_Space}` cannot ground the normalizer class `str.isspace()`)
is confirmed on fresh data; the frozen flip condition (normalizer class redefined to White_Space)
remains the only path to reversing it. No defect found in the premise; no lane defect to route.

## Receipts and bounds

- Deliverables: `build/K41LabRejectProbe/probe.py` (script), `build/K41LabRejectProbe/probe.txt`
  (exact canonical outputs, 21 lines, probe rc 0), `build/K41LabRejectProbe/notes.md` (commands, rc).
- Scratch `/fast/scratch/hyaku/kagi-r41/K41LabRejectProbe` deleted (rc 0, verified absent).
- No lane tree edits outside the seat-named build dir; no installs (none); no git/jj mutation;
  `claim-ledger.sh verify` never run. Supplementary cross-check outputs stayed in scratch and are
  quoted in notes.md only.
