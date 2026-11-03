# self-counts: "six STALE cells" in the plan vs 8 observed (C1 note, not C2)

Plan round-30 (round context) says at BASE: `self-counts.py ⇒ exit 2, six STALE cells`.
Measured at BASE `f67232c` (lone clone, `/fast/scratch/hyaku/kagi-r30/XEol/raw-base`):

    STALE SC-SKILL-STAMPS    SKILL.md:46      claimed=91 live=94
    STALE SC-SKILL-CLAIMS    SKILL.md:46      claimed=65 live=67
    STALE PV-STAMPS          PROVINCE.md:73   claimed=91 live=94
    STALE PV-CLAIMS          PROVINCE.md:73   claimed=65 live=67
    STALE RD-LEDGER-ROWS     corpus/README.md:64 claimed=65 live=67
    STALE RD-STAMPS          corpus/README.md:65 claimed=91 live=94
    STALE RD-DOCS-ROWLINKED  corpus/README.md:67 claimed=22 live=23
    STALE RD-DOCS-ENTRIES    corpus/README.md:67 claimed=25 live=26

8 STALE, not 6. The plan's C1 scope enumerates exactly six routed doc cells
(SC-SKILL-STAMPS, SC-SKILL-CLAIMS, PV-STAMPS, PV-CLAIMS, RD-STAMPS,
RD-LEDGER-ROWS); the extra two are the RD-DOCS-* pair the plan routes as D4
("docs ⇒ CLEAN entries=26 row_linked=23 vs pinned 25/22"). So the C1 position is
consistent if the D4 cells are counted as well, but the round-context sentence
undercounts. Reported for the C1 seat; C2 changes none of these (identical 8
before and after the EOL repair).

Exit shape: `SELF_COUNTS: POLICY (claims=62 stale=8 unlocated=0 ambiguous=0 policy=2 setup=1)`
at BASE → `setup=0` after the repair (the SETUP line was the checklist ratio).
