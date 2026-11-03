# XD2Cells — round-30 C1 doc-cell pre-integration (pointer)

Full report: `build/XD2Cells.md`. Drafts and receipts: `final/c1/`.

Tree measured: `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (frozen BASE `f67232c` + plan).
Method: `python3 corpus/self-counts.py` names the bound stale cells; every unbound current-tense
count in `SKILL.md` / `PROVINCE.md` / `corpus/README.md` was then read against its live source.
Read-only seat: drafts were validated on a scratch mirror only.

| cell | file:line | old | new | live source |
|---|---|---|---|---|
| SC-SKILL-STAMPS | `SKILL.md:46` | `91 stamps` | `94 stamps` | `corpus/stamps.tsv` non-blank rows = 94 |
| SC-SKILL-CLAIMS | `SKILL.md:46` | `65 claims` | `67 claims` | `^R[0-9]+-[0-9]+` rows in `corpus/claim-ledger.tsv` = 67 |
| PV-STAMPS | `PROVINCE.md:73` | `91 revision stamps` | `94 revision stamps` | same |
| PV-CLAIMS | `PROVINCE.md:73` | `65 claim rows` | `67 claim rows` | same |
| RD-LEDGER-ROWS | `corpus/README.md:64` | `65 rows` | `67 rows` | same |
| RD-STAMPS | `corpus/README.md:65` | `91 rows` | `94 rows` | same |
| **RD-DOCS-ROWLINKED** | `corpus/README.md:67` | `22 row-linked` | `23 row-linked` | `claim-ledger.sh docs` ⇒ `row_linked=23` |
| **RD-DOCS-ENTRIES** | `corpus/README.md:67` | `25 pinned` | `26 pinned` | same ⇒ `entries=26` |
| **(unbound)** | `PROVINCE.md:36` | `CLEAN rows=51` | `CLEAN rows=52` | `sources-census.sh` ⇒ `rows=52`; no self-counts binding |

The last three are **not** among the routed six: the measured before-state is eight stale bound
cells (not six), and the `rows=51` cell has no binding at all and was already stale in the commit
that wrote it (`fc65112`). Exact full-line before/after text: `final/c1/cells-draft.md`.
Scratch proof: `stale 8 → 0` with all bindings intact (`final/c1/XD2Cells-after-selfcounts.txt`).

Cross-claim notes the integrator needs (details in `build/XD2Cells.md` §Cross-claim):

- C2's frozen counter 2 prints **166**, not 3 (132 tracked `.ufo` evidence files + the 3 lane
  sources; `--exclude-dir=.ufo` ⇒ 3). Its scope must be named before it can be a 0/3 gate.
- C1's frozen counting command is C2-coupled through `KN-CHECKLIST-FALSIFY-FLOOR` → `R15-05`
  (`setup=1` under CRLF; `setup=0` with CR stripped in scratch).
- `python3 -I -B …` clears `self-counts`' first-token allowlist but still fails
  `claim-ledger.sh`' `PYTHON_SCRIPT_RE` (closed alternation, no flags; `feed-token-agree.py` absent)
  — a semantics change, so C1's kill rule applies to `R29-01/R29-02` unless gate code changes.
- Breadth ratios (`README.md:44`, `PROVINCE.md:72`) are host state with the substrate present and
  differ on this host; `R16-01`/`R17-01` DEFER as `[substrate]`. Do not re-pin here.
