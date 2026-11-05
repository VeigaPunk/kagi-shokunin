# K41ExecDocs (round-41 C2 docs seat) — findings

Deliverables: .ufo/waves/round-41/build/K41ExecDocs/ (rendered-text-v1.py, diff.txt, selftest.txt, c2-counter-readings.txt, unicodedata.txt, notes.md)

- Edited Sources paragraph (lines 45-48): cites S095, S096, S097; carries the frozen quote on one physical line; no superseded id; no blank line inside. Usage/Exit and step 5 unchanged.
- rendered-text-v1.py --selftest: rc=0, `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`.
- plans/round-41-c2.sh at candidate: rc=0, N=3 (target 3). At 5142b52 original (RTV1 override): rc=0, N=1 (no-work reading).
- Sub-terms at candidate: (a) cited S095 S096 S097, superseded hits none; (b) S095 body sha matches row col10, locate count=1; (c) PASS.
- unicodedata: category(U+3000)=Zs, U+3000.isspace()=True, U+001C.isspace()=True, unidata_version=16.0.0.
- Edited file sha256 14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9.
- Defects routed: S097 has no registry row at 5142b52 (cited but not yet in corpus/SOURCES.md; K41ScribeRegistry to add). Counter does not check row existence (frozen as written). No counter defect found.
- Install record: none. Sandbox removed on exit.
