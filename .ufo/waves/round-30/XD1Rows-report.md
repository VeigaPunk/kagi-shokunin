# XD1Rows — round-30 C1 pre-integration result (pointer)

Full report: `build/XD1Rows.md`. Drafts and receipts: `final/c1/`.

Tree measured: `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (frozen BASE `f67232c` + plan).
Method: each row read from `corpus/claim-ledger.tsv` and run with the gate's own semantics
(`timeout -k 5 T bash -o pipefail -c CMD`, cwd = tree root, exit equality + last-non-empty-line
ERE); cross-checked by running `claim-ledger.sh verify` over the unmodified twelve rows and over
the drafted file. No tree writes, no installs, no lane git mutation.

| Row | Pin (old) | Live now | Drafted new | Kind |
|---|---|---|---|---|
| R12-03 | 91 | 94 | `^94$` | count |
| R13-01 | 34 | 35 | `^35$` | count |
| R14-01 | entries=25 row_linked=22 | entries=26 row_linked=23 (+`duplicate_reasons=0` past the pinned prefix) | full line | count |
| R21-02 | rows=51 A=49 mined=47 entries_sourced=4 captures=51 | rows=52 A=50 mined=48 entries_sourced=5 captures=52 | full line | count |
| R21-04 | 65 | 67 | `^67$` | count |
| R22-03 | added=28 | added=31 | full line | count |
| R24-05 | count=91 sha 14663dcd | count=94 sha 94df9364 | full line | count+digest |
| R24-06 | count=34 sha 567453c9 | count=35 sha 92016a58 | full line | count+digest |
| R24-14 | count=65 sha f06ca9d5 | count=67 sha 917ef251 | full line | count+digest |
| R24-15 | count=28 sha 80f8f3d7 | count=31 sha b0d0f6f5 | full line | count+digest |
| R29-01 | `python -I -B …`; PASS(4) | PASS(4) but gate = POLICY first-token:python | `python3 -B …`; same expect | **not a number** |
| R29-02 | `python -I -B …`; AGREE(12,0) | AGREE(12,0) but gate = POLICY first-token:python | `python3 -B …`; same expect | **not a number** |

Causes: the three round-29 stamp paths (`corpus/feed-token-agree.py`,
`corpus/knowledge/feed-token-boundaries.md`, `corpus/lessons/round-29.md`) drive R12-03/R22-03/
R24-05/R24-15 (91→94, added 28→31); `R29-01/R29-02` entering the ledger drives R21-04/R24-14
(65→67); the round-29 `## Round ` heading drives R13-01/R24-06 (34→35); S052 + the new
knowledge entry drive R21-02 (52) and R14-01 (26/23). All match spot-check D1/D2's snapshot.

**Flag — non-number:** the plan's prescribed R29 fix (`python3 -I -B …`) still reads
`POLICY reason=python-script`. Leading flags break `PYTHON_SCRIPT_RE`'s
`^python3[[:space:]]+corpus/…` shape (proved with a registered script:
`python3 -I -B corpus/revision-audit.py --selftest` → POLICY), and `feed-token-agree.py` is not
in that alternation at all. Passing needs gate code (registration + flag tolerance), so per
C1's kill rule those two rows cannot be claimed migrated by value alone. `-B` is kept in the
draft because the live mode otherwise writes `corpus/__pycache__/release-clock.cpython-314.pyc`
(gitignored, but a write into the audited tree); `-I` is not load-bearing.

**Flag — outside my rows, advisory:** C2's frozen counter
`grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l` prints **166** at this tree
(3 production + 163 committed `.ufo/` capture/receipt/fixture files), so it cannot reach `0`
without rewriting committed evidence. Population defect in the counter, not an EOL defect.

Values are PROVISIONAL (C2 re-stamp, C3 rows/entries, round-30 heading and new ledger rows all
move them). Ten of twelve drafts pass the gate's own runner today (`_draft-verify.txt`: zero
`FAIL`); the two POLICY rows await the integrator's decision.

Evidence: `final/c1/migrations.tsv`, `final/c1/<row>.txt` ×12,
`final/c1/_gate-subset-original-rows.txt`, `_draft-verify.txt`, `_policy-matrix.txt`,
`_feed-token-no-flags.txt`, `_bytecode-attribution.txt`.
