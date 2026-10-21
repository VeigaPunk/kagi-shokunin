# Round 24 — frozen claims

Base: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (round-23 non-author spot-check,
MANIFEST rounds[379]). L1 holds the frozen planner seat; the planning data-walk
rides the wave-1 connector/revenger items. Populations below are frozen before
any implementation change; before-measurements run on scratch clones of BASE.
All six axes sit at 9 (saturation line 9); every claim is a distinct axis and
all three are lane-owned or lowest-tied axes. No vault/account action, no
credential read, no host-private gate on the real tree.

## Claims

1. **C1 operability — safe-by-default ledger entry points (D4, R11-08, guard
   debts).** `corpus/claim-ledger.sh` gains a `[host]` note tag; a row tagged
   `[host]` or `[substrate]` is a host row and `verify`/`cells` print
   `HOST-SKIP <id>` and never run it unless the caller sets
   `KAGI_HOST_ROWS=run`. An untagged row that invokes a declared host-reading
   script outside its declared host-free modes is refused as POLICY
   `untagged-host`; `~`, absolute and `..` arguments are refused; the
   backslash guard refuses a single backslash (R18-02 is rewritten as a
   fixed-string count, the only row that used one); `SKIP-SELF` fires only on
   an actual `bash corpus/claim-ledger.sh` invocation; `rows_run` counts rows
   actually executed. The citation gate splits quote/comma-joined path tokens
   and resolves `.ufo/` lane-first, then fleet (R11-08's two unresolved
   tokens in the non-author round-22 file).
   Population (frozen): the 12 QM12 host IDs of round 23 (R11-01 R11-02 R11-03
   R11-04 R11-06 R12-01 R13-03 R15-01 R16-01 R16-03 R17-01 R18-01).
   Counting: `bash .ufo/waves/round-24/tools/host-tripwire.sh <label> <rev>`
   (scratch clone; every host script stubbed to a logger; HOME scratch) →
   `HOST_TRIPWIRE: … total=N`. Before BASE: total>0 expected (R18-01 runs
   under `verify` with the substrate absent; `cells` re-runs it). After: 0.
   Second count: `bash corpus/claim-ledger.sh citations` `unresolved=2` → 0.
2. **C2 freshness — legacy pins re-captured under one declared normalizer
   (D5, D6; sourced).** `corpus/rendered-text-v1.py` is the single declaration
   (strict UTF-8, script/style, tags, html.unescape, Unicode `\s` collapse,
   trim, UTF-8; no separate comment rule) with a selftest; it must reproduce
   all 10 round-23 normalized digests. S001–S016 get one 2026-10-21 capture
   row each in `corpus/source-fetches.tsv`; `corpus/inrow-pins.tsv`
   classifies every historical in-row pin against that capture (raw /
   normalized / non-reproducing). The census restricts the in-row-only
   exemption to S001–S016, checks the classification rows, and adds
   `captures= inrow= inrow_only= inrow_nonreproducing=` to its CLEAN line. The
   TSV header, census comment and lesson cite the normalizer file instead of
   restating it. Sourced: the whitespace/entity rules cite rows opened this
   round (Python `re`, Python `html`); the ASCII-whitespace alternative is an
   explicit rejected row.
   Counting: rows whose only provenance is an in-row pin
   (`awk` over SOURCES.md × source-fetches.tsv): 16 → 0; named
   non-reproducing in-row pins: 6 (S008, S012–S016; S008 actually reproduces
   raw) → every non-reproducing pin named by `corpus/inrow-pins.tsv`.
3. **C3 calibration — identity-bound count rows (audit: R12-03, R21-04,
   R22-03/04, R11-10/11 blank-line class).** Population (frozen, 15 rows whose
   expectation is a bare cardinality): R11-10 R11-11 R12-03 R13-01 R13-02
   R15-04 R16-04 R16-05 R16-06 R17-02 R17-03 R18-02 R21-04 R22-03 R22-04.
   `corpus/row-identity.sh <selector>` prints
   `ROW_IDENTITY: <selector> count=N sha256=<64hex>` over the membership each
   row claims; new R24 ledger rows pin count and digest; old rows stay.
   Counting: `bash .ufo/waves/round-24/tools/identity-swap.sh <rev>` applies
   one count-preserving identity-swap mutant per population row in a scratch
   clone and reports how many survive every ledger row over that surface.
   Before BASE: 15/15 expected. After: 0/15.

Separability: C1 changes only gate logic and row tags (tripwire and citations
counts do not read C2/C3 files); C2 changes only the source registry, fetch
captures, normalizer and census; C3 adds a reader script and ledger rows that
run identically under the old and new gate. The ledger/stamp snapshots are
shared bookkeeping (QM14 old→new records), not claim coupling.

## Routed debt handled as bookkeeping (not claims)

D1 capability row in the main `## Capabilities` table; D2 SKILL.md gate
registry rows (closure dispositions, rendered-text-v1, row identity) and the
census row's pinned values; D3 ledger row for the closure selftest and a
`measured_commit` naming the final code tree; D7 every wave artifact committed
before the fleet report; D8 explicit rejects in the lesson Gate and named
corrections of `plans/round-23.md` wording ("commit tree" — the gate reads the
working tree; "consume the closure's decisions" — it consumes obligation ids).
Remaining named debt stays named: the other selftest case-count rows (R11-03
R11-05 R11-09 R12-02 R15-02 R16-02 R18-03 R21-03 R22-02) share the count-only
class and are out of C3's frozen population.
