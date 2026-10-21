# Connector — sibling overlap: kumitate-shokunin (round 28: C1 freshness / C2 calibration)

**Revisions read.** kumitate `git rev-parse HEAD` → `2fa28e5761220ee5b1c625bbb81ed5677c4522d6` (exit 0),
`git status --porcelain` 0 lines. kagi live HEAD is `b9a42c0e…` (= BASE + `bdf90f5` claims + `b9a42c0` plan
clarification), **not** BASE; `git diff --quiet 3553d499… --` over every kagi file cited here → exit 0, so all
kagi lines below are BASE-valid. The sibling pin records origin revision `31c465f…` (`.ufo/pins/origin.json`),
not a kumitate object (`git merge-base --is-ancestor … HEAD` exit 128).

## Findings
1. **`REGRESSED` is an anchor-truth kind in the sibling, not a version kind.** `scripts/anchor-truth.mjs:41`
   (doc), `:309` (`expect true`, token absent), `:311` (unchecked entry carrying a token); selftest AT06
   `:583-588` pins it (hand-edited pin token → exit 1, `/REGRESSED/`); design
   `.ufo/waves/round-38/gate-design.md:42`. The pin holds 4 notes / 811 entries / **0 version-like tokens**.
2. **kagi already has two REGRESSED meanings; kumitate one.** kagi BASE `corpus/release-clock.py:574`
   (observation below anchor/feed floor) and `:617` (receipt verdict `regressed`); the sibling's single
   meaning is anchored-token truth. Round-28 prose should contract-qualify the word.
3. **No version-ordering or SemVer-canonicality code in kumitate.** `grep -rniq 'semver\|S042' scripts/` exit 1;
   `grep -rqE '[0-9]+\.[0-9]+\.[0-9]+' scripts/` exit 1. The only `parseInt` sites are round numbers and proxy
   counts (`round-gate.mjs:255,516`; `proxy-check.mjs:1004,1091`). Freshness there is recheck cadence
   (`sources-check.mjs:307-337`), never a version comparison.
4. **"canonical" collides in four non-numeric senses.** canonical JSON digest `surface-probe.mjs:339-352`;
   canonical candidate directory `cite-check.mjs:101-112`; canonical member identity by exact path
   `proxy-check.mjs:150,778,824`; canonical left-first pairing `claims-check.mjs:300`. Cite SemVer S042, not these.
5. **Same matcher shape, opposite use.** `anchor-truth.mjs:242-256` (`judge`) + `:205` (`wb`) is word-bounded
   literal presence; kagi `release-clock.py:341-346` (`version_is_named`) is the same shape. The sibling states
   the limit ("lexical, not semantic", `.ufo/waves/round-38/gate-design.md:65-66`). Correct for a citation, wrong
   for C2 equality: `3.15.01` is absent from a line that names `3.15.1`. Do not lift `judge()` into C2.
6. **Bounded-token prior art for C1's "bounded" half.** `anchor-truth.mjs:77` `MAX_TOKEN_CHARS = 256`; `:244`
   oversize returns `'false'` (never throws); `:382` refuses an over-long pin token. `sources-check.mjs:332-337`
   uses `BigInt` and a catch that treats an arbitrarily large cadence as not-overdue.
7. **Counterexamples — leading-zero numeric tokens are already accepted, untyped, three sites in kumitate.**
   `round-gate.mjs:252-256`: `^\d+$` + `parseInt` + `isSafeInteger` ⇒ `"007"` → 7. `round-gate.mjs:512,516`:
   `/^round-(\d+)$/` ⇒ `round-7` and `round-007` both → 7; `grep -c 'seenRound\|duplicate'` → 0, so both dirs
   are filed as round 7 and `latestClosedRound` (`:620-623`) picks whichever sorted last.
   `sources-check.mjs:307,334`: `01d` → 1n, `0d`/`000d` → 0n. These are kumitate's contracts (adjacent; report,
   never patch); the defect class C1 closes is fleet-wide, not kagi-local.
8. **SOURCES.md shape is already agreed.** kagi `release-clock.py:78-88` (`len(cells) != 11`; `"anchor": cells[5]`);
   kumitate `sources-check.mjs:261-283` (13 pipe-split fields; `anchor: fields[6]`), same 11-column header
   (kagi `corpus/SOURCES.md:5`, kumitate `corpus/SOURCES.md:12`). Kumitate checks anchor non-emptiness only
   (`:286`), never that it names the row's version ⇒ **C2 is new ground**; the cell index needs no negotiation.
9. **C2 controls are feasible at BASE.** All 15 `derived:` rows match their feed anchor: S033 → 3.13.3 ×2,
   S034 → 2.2.0 ×2, S035 → 2.7.1 ×2, S037 → 8.23.0 ×1 (`corpus/SOURCES.md:39-43`; rows
   S008-S011,S013-S016,S021-S026,S029). Each cell names one distinct version — but S033-S035 name it **twice**;
   C2 should require a unique token, else a cell quoting an excluded release makes "the version named" ambiguous.
10. **C1's frozen predicate can pass for the wrong reason.** `release-clock.py:576-580` already routes a non-numeric
    observation to `INCONSISTENT`; the minimal fix (`numeric_version` → None) makes F1/F2 exit 1 naming the row —
    satisfying "names a typed finding for the fixture's row/feed" with no canonicality-specific kind. Reported,
    not redefined.
11. **F4 (observe oversize) does not discriminate; F3 is ambiguous.** Static reading of BASE: `observe_one`
    catches `ValueError` (`release-clock.py:822-823`), `failures` (`:890`) forces exit 1 (`:1754`), and
    `receipt_matches` fails on `"error" in receipt` (`:430`) ⇒ `RECEIPT-MISMATCH S027/S028` (`:608`). So F4 is
    already exit 1, no Traceback, typed finding naming the row = **TYPED at BASE**. F3 writes
    `parsed_version=3.15.01, verdict=fired`, then fails at `:444` (parsed ≠ observed) ⇒ exit 1; whether that is
    MISHANDLED depends on reading "or a written fired observation" as a separate disjunct. The real F3 harm — a
    **fired observation is written** — survives a compare-side-only fix, so C1's gate must sit in
    `parse_latest_version` (`:760`) / `observe_one` (`:787-799`), not only in the table check.

## Overlap / province verdict

- kagi `PROVINCE.md:67` names kumitate adjacent ("their own secret-shaped tripwires"); round-21's sweep on the
  same line found no sibling claiming SOPS/OpenBao/Vault/credential-broker ground.
- kumitate `PROVINCE.md:24-26` routes kagi adjacent (MCP/OAuth security) and says "reported, never absorbed".
- **Verdict: neither absorb nor contradict.** No shared file, contract or data; nothing in kumitate blocks C1/C2
  and no sibling edit is needed. The only collision is vocabulary (`REGRESSED`, `anchor`, `canonical`).

## Reusable prior art (for L1; not to copy blindly)

| kumitate | what it gives C1/C2 |
|---|---|
| `anchor-truth.mjs:242-256` four-status `judge` | return a status, never throw; separate absent / unresolvable / unchecked |
| `anchor-truth.mjs:77,244,382` bounded token | C1's "bounded" half: cap the token, produce a finding |
| `anchor-truth.mjs:316-335,443-450` + AT03/06/07/08 `:562-604` | pin the expectation, assert the **kind**, monotonic `--base` arm |
| `sources-check.mjs:261-286` | the same 11-cell registry validated by row shape, anchor at content index 5 |
| `sources-check.mjs:141-149` (`isoDay`) | strict canonical form (exact width + calendar) — the shape a version gate should have |

## Proposed move (one, bounded; freshness)

Make C1's canonicality a **status-returning gate at token entry**, with distinct kinds (`NONCANONICAL`,
`OVERSIZE`), asserted by a selftest — not a comparator-side `None` and not an exception.

- Where: one C1-local helper used by `numeric_version` (`release-clock.py:369-381`), `is_regression` (`:383-388`),
  `feed_floors` (`:390-410`), the named/derived branch (`:565-586`), and the observe path (`:760`, `:787-799`, `:444`).
- Why this one: it is the only shape that fixes F3's *written fired observation* as well as F1/F2, and it turns
  finding 10's vacuous TYPED into an observable kind. Sibling evidence: `judge`'s taxonomy, AT06 asserting the
  kind (`anchor-truth.mjs:583-588`).
- Axes: freshness (C1) improves; calibration (C2) untouched — no C2 code, fixture or counting command; the helper
  stays inside C1's own functions, so claim-only overlays still separate.
- Risks: two new kind names enter the FAILED vocabulary (documented, not silent); the selftest count grows ⇒ the
  SC/PV-CLOCK-SELFTEST stamp must move (plan allows new cases); if L1 instead implements C1 as `numeric_version`
  → None, finding 10 stands and F3's receipt still says `fired`.
- Verification (L1 runs, not me): `c1-measure.py 3553d499… base` then landed ⇒ MISHANDLED 0/4, TYPED 4/4, control
  `CLEAN (… derived=15)` exit 0; the F3 artifact must not pair `"parsed_version": "3.15.01"` with `"verdict":
  "fired"`; `c2-measure.py` ⇒ ACCEPTED 0/4, EXACT 4/4, control CLEAN30; default clock CLEAN30 exit 0.

## Commands run (exits)

- `git -C kumitate rev-parse HEAD` 0; `git status --porcelain=v1 | wc -l` → 0.
- `git -C kagi diff --quiet 3553d499… -- <cited files>` 0 (identical to BASE); `git rev-parse HEAD` → b9a42c0… 0.
- `grep -rniq 'semver\|S042' kumitate/scripts` 1; `grep -rqE '[0-9]+\.[0-9]+\.[0-9]+' kumitate/scripts` 1;
  `grep -cq 'seenRound\|duplicate' kumitate/scripts/round-gate.mjs` 1.
- `node -e` on the two sibling regexes: `"007"→7`, `round-007→7`, `01d→1n`, `0d→0n` (exit 0).
- `python3 -c` int limit: `3.14.8`, `sys.get_int_max_str_digits()=4300`; 4301 digits → `ValueError` (exit 0).
- `git show 3553d499…:<file> | grep -n` for every kagi line above (exit 0).
- `git -C kumitate merge-base --is-ancestor 31c465f… HEAD` 128 (origin revision, not a lane object).

## Not checked

- No kumitate script or selftest executed (contract); the leading-zero probe reproduces regexes, not tools.
- No kagi production command run: `release-clock.py`, `c1-measure.py`, `c2-measure.py` were not executed; the
  F3/F4 before-state is a static reading of the BASE lines cited, not a run.
- The F3/F4 harness mechanics (how `c1-measure.py` serves a local feed copy for a public-URL row) are not written
  yet and were not verified.
- No other sibling inspected (scope: kumitate); `/fast/scratch/kumitate-r36/src` existence not verified.
- No network, no host-private reads; nothing written in kumitate; the only kagi write is this report.
