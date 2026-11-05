Attacks on the C2 candidate paragraph — seat K41ReviewDocs
Scope: what each attack hits (counter term (a)/(b)/(c), or a step-5 / Sources sentence
the paragraph is meant to ground), the construction, the PREDICTED counter reading,
and the exact command the L1 runs after landing. All readings below were EXECUTED in
scratch sandboxes (clones of the frozen 5142b52 tree, or of the executor candidate
build/K41ExecDocs/rendered-text-v1.py), against the frozen counter plans/round-41-c2.sh.
Command shape for every reading: run in a scratch dir containing the candidate tree
layout, `bash plans/round-41-c2.sh`, print ONE integer; exit code 0.

Axes (named, godspeed): calibration + freshness. Every attack that moves a reading
without harming another axis is kept on the final check list.

Ground facts measured this seat (needed to predict readings):
  - counter (b) freezes the exact substring `Matches Unicode whitespace characters
    (as defined by` inside the Sources paragraph; a physical newline inside the
    quote makes grep -qF fail -> b=0.
  - (a) fails on any cited id that appears in the `supersedes S###` column set
    (S006 S007 S012 S013 S014 S016 S027 S028 S034 S035 S036 S039 S040 S041 S047 S049).
  - (b)'s sha-binding already holds on committed bytes (S095 row col10 ==
    sha256(.ufo/waves/round-40/capture/S095.body), locate exit 0), so (b) can also
    fail ONLY through the quote text or the paragraph.
  - (c) is PASS cases=22 at both BASE and the candidate; it fails only if the
    selftest is broken or drops below 22.
  - Frozen controls (measured at 5142b52): BASE N=1; decoy (S027 + quote) N=2;
    candidate-shaped paragraphs read N=3 where (a),(b) are constructed to pass.

--------------------------------------------------------------------------------
TA1 — quote split across two physical lines
  Attacks: (b)
  Construction: paragraph keeps the ids and the quote words but broke the frozen
  substring across a line break: "...characters (as\ndefined by\"".
  Predicted: (a)=1 ((c)=1), (b)=0 because grep -qF sees the literal with a newline.
  Measured: N=2 (candidate-shaped start N=3). rc 0.
  Post-landing check: bash plans/round-41-c2.sh  -> 2 (must read 3; this is also
  why the executor statement "carries the frozen quote on one physical line" is a
  required property, not a courtesy).
  NOTE: the counter cannot distinguish TA1 from a body mismatch; both kill only b.

TA2 — a cited id that is superseded
  Attacks: (a); also (b)'s spirit (stale teaching).
  Construction: paragraph cites S040 (the round-26 row, superseded by S095).
  Predicted: (a)=0 (S040 appears in a supersedes cell); (b)=1 IF the quote and
  binding still hold (they do, the S095 body is unchanged); (c)=1. So N<=2.
  Measured: N=2. rc 0.
  Post-landing check: bash plans/round-41-c2.sh  -> must read 3 at the real
  candidate; plus grep the paragraph ids:
    awk '/^Sources \(/{on=1} on && /^$/{exit} on{print}' corpus/rendered-text-v1.py \
      | grep -oE 'S[0-9]{3}' | sort -u
    and cross each id against: grep -oE 'supersedes S[0-9]{3}' corpus/SOURCES.md.

TA3 — S097 cited for a claim its quote does not state
  Attacks: grounds of a paragraph sentence (no counter term can see it; the
  frozen ceiling — the counter binds ids and one quote, it does not check that
  every sentence is grounded — is exactly this hole).
  Construction: candidate-shaped paragraph adds "tied by S097 to exactly the
  White_Space property set". S097's body does NOT say that: its str.isspace()
  definition accepts cat Zs OR bidi WS/B/S, which includes U+001C-001F, which
  White_Space excludes; the UTS #18 mapping line in S098's body reads
  space(\s) -> \p{Whitespace} and delegates to PropList. So the equivalence claim
  is FALSE, and S097's own quote ("A character is whitespace if in the Unicode
  character database... general category is Zs ... bidirectional class WS, B, S")
  never states it.
  Predicted: N=3 — the counter stays green; ONLY the review check catches it.
  Measured: N=3 rc 0. This is the calibration heart of this seat.
  Post-landing check (the S097-quote-vs-body check, prepared per assignment; run
  after the registry seat lands S097 and its capture exists):
    python3 corpus/rendered-text-v1.py locate .ufo/waves/round-41/capture/S097.body \
      "A character is whitespace if in the Unicode character database"
    -> expect RENDERED_TEXT_V1_LOCATE: count=1, exit 0 (measured this seat on the
    scout's committed S097 body, sha256 e2992e17d9b8f15f09b2971e356d06c5e0f1572fefa6ce733eb6d7d48466e2b3,
    815447 bytes, /3/library/stdtypes.html 301-redirects to /3/builtins/stdtypes.html).
    Then the checklist: the paragraph's S097 sentence may only ground str.isspace()
    membership as "cat Zs or bidi class WS/B/S"; any "equals White_Space" clause is
    UNGROUNDED and the check below must record it (this is also the S098 reject reason).
    sha256sum .ufo/waves/round-41/capture/S097.body  must equal the S097 fetch-row
    column 10; and for U+001C..U+001F the row's derivation must not be written as
    "Zs-only" (str.isspace accepts them via bidi B/S; they are NOT White_Space).

TA4 — a sentence of step 5 that cites nothing
  Attacks: no counter term — docking the counter's exact ceiling (plan: "the
  check is the round's reviewer item K41ReviewDocs").
  Construction: step 5 retains the sentence "collapse every run of Unicode
  whitespace ... includes U+00A0 ... and U+3000" while the Sources paragraph is
  fully grounded. Two sub-cases measured:
    TA4a: U+3000 sentence kept as a PAGE claim -> UNSUPPORTED at any tree (S095
    body has no U+3000 token; measured b.count(b"\u3000")==0 and
    b.count(b"U+3000")==0). Predicted and measured N=3, rc 0.
    TA4b: U+3000 sentence rewritten as a lane derivation of S097's membership
    definition (cat Zs; isspace True) and recorded in the round-lesson Gate per
    the plan -> grounded; the Gate line must quote the membership clause, not a
    derivation from S095's body text.
  Post-landing check: python3 -c
    "import unicodedata as u; print(u.category('\u3000'), '\u3000'.isspace())"
    -> 'Zs True' grounds the Gate line; and the Gate must NOT assert it from S095.
  Predicted reading: N stays 3 in both sub-cases; the difference is invisible to
  the counter and is this seat's surviving-defect item if the executor ships TA4a.

TA5 — the quote present in a code comment rather than the paragraph
  Attacks: (b)
  Construction: strip the quote from the Sources paragraph; insert
  "# Sources (decoy): Matches Unicode whitespace characters (as defined by"
  in the module's comment block. If the counter parsed comments, b=1.
  Predicted: (b)=0 (the awk paragraph slice excludes comment lines); (a)=iff ids
  cited in the paragraph; (c)=1.
  Measured: N=2 rc 0 (ids stay; quote gone). A variant with the quote ALSO absent
  from ids' citations keeps N=2.
  Post-landing check: bash plans/round-41-c2.sh  -> must be 3; this is the
  structured twin of the decoy control (c2-control-decoy reading 2).

TA6 — the paragraph cites S095 only and keeps the U+3000 claim
  Attacks: (a) marginally (S095 is not superseded so (a) stays 1) — the real
  target is a step-5/page-conflation defect, and the hidden premise that S095
  grounds membership alone.
  Construction: paragraph cites S095 only; U+3000 sentence stays.
  Predicted and measured: N=3 rc 0 — the counter is fully green while the
  U+3000 sentence remains unsupported by the cited page (TA4a's fact) and the
  membership ground S097 is absent from the paragraph. This is the strongest
  calibration finding of the seat: N=3 admits TA6.
  Post-landing check: read the paragraph ids; require BOTH S095 and S097 to be
  cited (S095 for the located quote, S097 for the membership definition the
  step-5 class turns on), else record a defect even though the counter is green.

Extra discrimination hits (kept — they move an axis and harm none):
  E1. TA1 and the decoy control together show (a)+(b) are separable: the decoy
      control at 5142b52 reads N=2 ((a)=0,(b)=1,(c)=1), TA1 reads N=2
      ((a)=1,(b)=0,(c)=1). DELETE: no control distinguishes (a)-failure from
      (b)-failure by value alone; the detectors are the two-component sub-reads.
  E2. TA3's S097 body binding is NEW evidence this round (scout fetched; this
      seat confirmed sha and locate); it also yields the membership sentence for
      the round-lesson Gate with a locate count of 1 (measured).
  E3. The full S040-era sentence (with str.isspace() tokens) locates at count=1
      in the S095 body AFTER normalization (measured exit 0) but does NOT locate
      as raw-literal bytes (the str.isspace() link is markup). Registry rows
      shipping that full sentence as a VERBATIM raw quote would FAIL locate in
      quote-bodies.tsv form (byte-exact): raw count 0. The registry seat must
      store S095's verbatim quote as the frozen short form (offset 75897), and
      store the full sentence as a derived/normalized-location quote. This is
      the M40-14/QM44 class boundary and is now measured here.

SUMMARY TABLE (measured readings of bash plans/round-41-c2.sh)
  BASE 5142b52/19025d9: N=1 (a0,b0,c1)   [both: same tree content]
  decoy control:        N=2 (a0,b1,c1)
  candidate shape:      N=3 (a1,b1,c1)
  TA1 quote split:      N=2 (a1,b0,c1)
  TA2 cite S040:        N=2 (a0,b1,c1)
  TA3 S097-cited-for-UTS18: N=3 (a1,b1,c1)  <-- survives the counter
  TA4 uncited step-5:   N=3 (a1,b1,c1)      <-- (a) and (b) unchanged; survives
  TA5 comment-quote:    N=2 (a1,b0,c1)
  TA6 S095-only:        N=3 (a1,b1,c1)      <-- survives the counter
  selftest at BASE:     (c) rc0 cases=22 PASS

All bases and readings report only exits that were executed. Defect to route:
the counter can be fully green while the paragraph carries an ungrounded page
claim (TA3/TA4a/TA6); the surviving defense is this seat's checklist, executed by
the L1 at landing. Install record: none.
