Seat K41ReviewDocs notes — commands, exit codes, last outputs (all executed 2026-11-05)

Scratch lifecycle: S=/fast/scratch/hyaku/kagi-r41/K41ReviewDocs (created mkdir -p; clone
git clone --shared <lane> "$S/work"; git -C work checkout --detach 5142b52;
git -C "$S/work" rev-parse --show-toplevel -> /fast/scratch/hyaku/kagi-r41/K41ReviewDocs/work,
verified BEFORE any write). Scratch deleted (rm -rf) after all receipts were copied into the
deliverable dir; a second sandbox S2 (K41ReviewDocs2) served the final frozen-counter re-runs
and was deleted at teardown.

Tooling installs: NONE. Used git, python3 (3.14.8 runtime, unicodedata 16.0.0), bash, awk,
sha256sum, curl-equivalents (urllib). pacman never invoked.

BASE-state facts (receipts already in base-check.txt):
- git show 19025d9:corpus/rendered-text-v1.py -> Sources paragraph carries NO S### id
  ("Sources (opened round 24, see corpus/SOURCES.md): ...").
- plans/round-41-c2.sh at 5142b52 predeclared tree: stdout "1", exit 0 (twice: original clone
  and fresh S2 clone).
- plans/round-41-c1.sh at 5142b52: stdout "0", exit 0 (no gate file).
- plans/round-41-controls.sh at 5142b52: rc 0, lines
  CONTROL c1-blanket-refuse N=0 / c1-blanket-accept N=0 / c1-no-gate N=0 /
  c2-decoy-superseded N=2 / C2 BASE N=1 — byte-identical to the precommitted receipts
  .ufo/waves/round-41/controls/*.txt (1,0,0,0,2,1).
- selftest: RENDERED_TEXT_V1_SELFTEST: PASS (cases=22), exit 0.

S095/S096 binding (round-40 committed captures):
- sha256 .ufo/waves/round-40/capture/S095.body = ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1
  == source-fetches.tsv row S095 column 10; 257722 bytes.
- S096 body 570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5; 20100 bytes.
- locate on S095 body, frozen quote: RENDERED_TEXT_V1_LOCATE: count=1, exit 0 (raw offset 75897).
- Full S040-era sentence locating (normalized) at count=1 exit 0; raw-literal of the same
  sentence with markup absent (count 0) — recorded as M40-14/QM44 boundary evidence E3.
- S095 body token counts: b"\u3000"==0, b"U+3000"==0, b"\xc2\xa0"==0, "str.isspace"==3
  occurrences; non-breaking-spaces sentence present at normalized count 1.

Code-point derivations (python3, unicodedata 16.0.0):
  U+00A0 cat=Zs isspace=True; U+3000 cat=Zs isspace=True;
  U+001C..U+001F cat Cc, bidi B/B/B/S, isspace True (all four) — the S098 reject diff;
  U+0020 U+205F U+2000-200A isspace True; U+200B U+FEFF U+180E isspace False;
  str-pattern \s matches U+3000/U+00A0/U+001C (re.match True each).

S097 body (scout's committed capture, byte-identical to this seat's own live fetch:
cmp exit 0, "S097 identical"):
  sha256 e2992e17d9b8f15f09b2971e356d06c5e0f1572fefa6ce733eb6d7d48466e2b3, 815447 bytes,
  title "Built-in Types — Python 3.15.2 documentation"; URL path /3/library/stdtypes.html
  301-redirects to /3/builtins/stdtypes.html (both hops measured).
  Post-landing check dry-run: python3 corpus/rendered-text-v1.py locate <S097.body>
  "A character is whitespace if in the Unicode character database"
  -> RENDERED_TEXT_V1_LOCATE: count=1, exit 0. The str.isspace definition's membership
  sentence grounds cat Zs OR bidi WS/B/S — it does NOT say White_Space.

S098 body (scout capture, sha256 68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d):
  title "UTS #18: Unicode Regular Expressions"; the compatibility table maps
  space(\s) -> \p{Whitespace} with "See PropList for the definition of Whitespace";
  "\p{White_Space}" locate count=0 (absent as a regex literal), "White_Space" count=4.
  This SURPLUS finding must be routed to the S098 row: the plan's reject reason cites
  "\s as \p{White_Space}" while the served page writes "\p{Whitespace}" (same property,
  different case); the row's quote should carry the served spelling.

Attack-sandbox measurements (frozen counter plans/round-41-c2.sh, exit codes 0):
  exec candidate (K41ExecDocs/rendered-text-v1.py run in a 5142b52 layout): N=3 rc 0
  TA1 quote split across two lines:      N=2
  TA2 cite superseded S040:              N=2
  TA3 S097-cited-for-White_Space-eq:     N=3 (counter-green; ungrounded page claim)
  TA4 step-5 sentence uncited:           N=3 (both sub-cases)
  TA5 quote only in a code comment:      N=2
  TA6 paragraph cites S095 only, U+3000 kept: N=3 (counter-green)
  BASE shape: N=1; decoy: N=2.

Defects routed (not fixed in lane):
1. plans/round-41-c2.sh cannot see TAS3/TA4/TA6 — paragraph-green while a page claim is
   unsupported. Coverage is this seat's checklist, executed by the L1 at landing.
2. S098 served spelling is \p{Whitespace}, not \p{White_Space} — S098 row wording must
   carry the served token (route to K41ScribeRegistry).
3. S097 has no registry row at 5142b52 (executor cites it; counter cannot check row
   existence — frozen as written). S097 row must carry url AND final_url with
   http_status 200 on the final hop, else the census classifies it non-reproducing.
4. The plan cites S096/S097 for the stdtypes hop; stdtypes path is the 301-redirect;
   registry row for S097 must record the final URL (dupe of 3, by scout and here).
