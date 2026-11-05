# K41ExecDocs notes (round-41 C2, seat K41ExecDocs)

Commits: frozen predeclaration 5142b52 (lane clone checked out detached at 5142b52).
Sandbox: $S=/fast/scratch/hyaku/kagi-r41/K41ExecDocs (work clone at $S/work); removed on exit.
Edit: corpus/rendered-text-v1.py lines 45-46 (5142b52) replaced by lines 45-48; no other line changed.

## Commands and exit codes
1. git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin $S/work && git -C $S/work checkout --detach 5142b52  -> exit 0 (HEAD 5142b52)
2. git -C $S/work rev-parse --show-toplevel -> exit 0, prints $S/work
3. git -C $S/work show 5142b52:corpus/rendered-text-v1.py > $S/orig-rendered-text-v1.py -> exit 0, sha256 7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf
4. edit $S/work/corpus/rendered-text-v1.py PUT 45.=46 (Sources paragraph, 4 lines) -> applied
5. python3 corpus/rendered-text-v1.py --selftest (cwd $S/work) -> rc=0; last line `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`
6. bash plans/round-41-c2.sh (cwd $S/work) -> rc=0; stdout `3`
7. RTV1={orig} bash plans/round-41-c2.sh -> rc=0; stdout `1` (no-work reading, matches plan)
8. python3 -c unicodedata probe (see unicodedata.txt) -> rc=0
9. diff -u --label 5142b52:... --label edited:... orig edited > diff.txt -> rc=1 (files differ), 15 lines
10. copy of edited file -> /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-41/build/K41ExecDocs/rendered-text-v1.py (byte copy; sha256 14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9, equal to the work-tree file)
11. git -C $S/work rev-parse --show-toplevel asserted before every write in the sandbox.

## Edited file sha256
14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9  rendered-text-v1.py (edited)

## Counter readings
round-41 C2 counter readings (plans/round-41-c2.sh, RTV1 default = corpus/rendered-text-v1.py)
candidate (sandbox work tree, paragraph lines 45-48):  rc=0  N=3  stderr=''
5142b52 original normalizer (RTV1 override):                    rc=0  N=1  stderr=''
sub-terms (candidate, reproduced with the counter predicates):
  (a) cited=['S095', 'S096', 'S097'] superseded=['S006', 'S007', 'S012', 'S013', 'S014', 'S016', 'S027', 'S028', 'S034', 'S035', 'S036', 'S039', 'S040', 'S041', 'S047', 'S049'] hits=[]
  (b) quote lines=1; S095 row col10=ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1; S095.body matched=['.ufo/waves/round-40/capture/S095.body']; locate rc=0 out='RENDERED_TEXT_V1_LOCATE: count=1'
  (c) selftest rc=0; stdout='case tags-to-space: ok\ncase script-removed: ok\ncase style-removed-case-multiline: ok\ncase script-close-must-match: ok\ncase comment-plain: ok\ncase comment-gt: ok\ncase escaped-tag-survives: ok\ncase numeric-entity: ok\ncase nbsp-entity-collapses: ok\ncase nbsp-raw-collapses: ok\ncase ideographic-space-collapses: ok\ncase ascii-runs-collapse: ok\ncase trim-both-ends: ok\ncase zero-width-space-kept: ok\ncase empty-angle-kept: ok\ncase script-shortest-match: ok\ncase script-word-boundary: ok\ncase script-malformed-opener: ok\ncase script-hyphen-prefix: ok\ncase script-attributed-closer: ok\ncase strict-utf8: ok\ncase quote-collapse-only: ok\nRENDERED_TEXT_V1_SELFTEST: PASS (cases=22)'


## Selftest (first lines of selftest.txt)
$ python3 corpus/rendered-text-v1.py --selftest
exit=0

## unicodedata probe
$ python3 -c "import unicodedata; print(unicodedata.category('\u3000')); print('\u3000'.isspace()); print('\x1c'.isspace()); print(unicodedata.unidata_version)"
exit=0
Zs
True
True
16.0.0


## Diff (5142b52 -> edited)
--- 5142b52:corpus/rendered-text-v1.py
+++ edited:corpus/rendered-text-v1.py
@@ -42,8 +42,10 @@
   6. trim        strip leading/trailing whitespace (the same Unicode class).
   7. encode      UTF-8; the normalized digest is sha256 of these bytes.
 
-Sources (opened round 24, see corpus/SOURCES.md): Python `re` \\s for str
-patterns and Python `html.unescape`.
+Sources (re-grounded round 41, see corpus/SOURCES.md): S095, Python 3.15.2 `re` documentation,
+str-pattern whitespace: "Matches Unicode whitespace characters (as defined by" (step 5 class,
+whose membership is str.isspace()); S096, Python 3.15.2 `html.unescape` documentation (HTML 5
+rules, step 4); S097, Python 3.15.2 `str.isspace()` definition (the character class of step 5).
 
 Usage:
   python3 corpus/rendered-text-v1.py digest FILE


## Notes and routed items
- Counter (b) binds through .ufo/waves/round-40/capture/S095.body (tracked in the lane; sha matches S095 row col10). The S095 round-41 capture from K41ScoutSources is not needed for the counter at this base; it reads the round-40 body with the matching sha.
- Paragraph cites S097, which has no row in corpus/SOURCES.md at 5142b52. The counter does not check row existence (plan §C2 frozen). The registry seat must add S097 for the citation to resolve; routed to K41ScribeRegistry and K41ReviewDocs.
- Step-5 rule text unchanged. Usage/Exit text unchanged (diff shows only lines 45-48 changed).
- No counter defect found; plans/round-41-c2.sh not edited.
- Install record: none (no tools installed).
