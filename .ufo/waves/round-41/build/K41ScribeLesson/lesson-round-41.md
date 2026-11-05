source: S095 (docs.python.org/3/library/re.html, re-opened 2026-11-05, byte-identical to the round-40 capture); S097 (docs.python.org/3/library/stdtypes.html → /3/builtins/stdtypes.html, opened 2026-11-05); S098 (unicode.org/reports/tr18/, opened 2026-11-05, REJECTED); the counters' committed bytes and the wave receipts are the evidence for the rest

# Round 41 — expect-journal gate (C1, calibration), rendered-text-v1 source grounding (C2, freshness)

Frozen plan: `plans/round-41.md` at `5142b52` (plan, counters, controls and the measured BASE receipts
land in one commit — `git log --oneline -- 'plans/round-41*'` lists `5142b52` only; there is no separate
plan-alone revision this round). Claim BASE: `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`. Round-40 landed
state (the positive control P0 of C1): `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`. Round-40 claim BASE:
`6cc8850dfc5757927699e5a53a876f47c8df21aa`. Predeclaration: `5142b52`.

Section order follows `corpus/lessons/round-40.md` (Claims before Gate).

## Claims

- **C1 calibration — `bash plans/round-41-c1.sh` 0 → 4.** BASE **0** at `19025d9`: the claim BASE tree
  has no `corpus/expect-journal.sh` (`git ls-tree 5142b52 corpus/expect-journal.sh` → empty), so the
  counter prints 0 (`plans/round-41-c1.sh` → `0`, exit 0, no gate file yet). The BASE reading is
  committed at `.ufo/waves/round-41/controls/c1-control-no-gate.txt` (`0`) and was re-read by the scout
  seat at the predeclaration tree (`bash plans/round-41-c1.sh` → prints `0`, exit 0). Target **4** at the
  round-41 candidate. Ceiling on the BASE reading, named by the critic seat: the counter's
  `[ -f "$GATE" ] || { echo 0; exit 0; }` short-circuit means the 0 proves only that no gate file
  exists — it is not a behavioural do-nothing measurement (the existing `corpus/claim-ledger.sh verify`
  in the gate's role also reads 0, because it accepts all four forgeries). Discrimination therefore
  rests entirely on the frozen target N = 4 together with the positive control P0 being accepted.

  Frozen predicate (copied verbatim from `plans/round-41.md` §C1): *"prints ONE unsigned integer N = the
  number of the four forgeries F1–F4 that the gate refuses with its frozen token (rc 1 and the exact line
  `EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate accepts the positive control P0 (rc 0). If
  P0 is refused or the gate is missing, N = 0."*

- **C2 freshness — `bash plans/round-41-c2.sh` 1 → 3.** BASE **1** at `19025d9`
  (`.ufo/waves/round-41/controls/c2-base-19025d9.txt` → `1`): at the BASE tree the Sources paragraph of
  `corpus/rendered-text-v1.py` carries no `S###` id (a = 0), no frozen quote (b = 0) and the selftest
  passes (c = 1). The BASE docstring is byte-identical to the predeclaration docstring
  (`sha256 7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf` at both `19025d9` and
  `5142b52`), so the BASE reading is the reading at both trees. Target **3** at the round-41 candidate.

  Frozen predicate (copied verbatim from `plans/round-41.md` §C2): *"prints ONE unsigned integer N =
  (a)+(b)+(c), each term 0 or 1:"* —

  - *"(a) the Sources paragraph of `corpus/rendered-text-v1.py` (`RTV1`, default that path) cites at least
    one `S###` id and no cited id is superseded (superseded = an id named in a `supersedes S###` cell of
    `corpus/SOURCES.md`)."*
  - *"(b) the paragraph contains the frozen quote `Matches Unicode whitespace characters (as defined by`,
    and the S095 capture body binds: the S095 row's decoded sha256 (column 10 of
    `corpus/source-fetches.tsv`) equals `sha256sum` of a `.ufo/waves/*/capture/S095.body`, and `python3
    corpus/rendered-text-v1.py locate` on that body exits 0 for the quote."*
  - *"(c) `python3 corpus/rendered-text-v1.py --selftest` exits 0 and prints `PASS`."*

  Candidate readings (the L1's landing run is the number that counts; see `notes.md`): C1
  `⟨SLOT: c1 candidate reading⟩`, C2 `⟨SLOT: c2 candidate reading⟩`. Controls at the predeclaration
  (`plans/round-41-controls.sh`, receipts under `.ufo/waves/round-41/controls/`): `c1-control-refuse-all.txt`
  → `0`, `c1-control-accept-all.txt` → `0`, `c1-control-no-gate.txt` → `0`, `c2-control-decoy.txt` → `2`
  (the decoy reads (a) = 0, so N ≤ 2, as the plan requires). The L1's landing re-read of every control is
  `⟨SLOT: control re-reads⟩`.

  A claim-side consequence the L1 must close: appending two registry rows (S097, S098) moves the census
  summary that four ledger rows bind (`R21-02`, `R31-02`, `R33-02`, `R34-03` — all expect the
  `SOURCES_CENSUS` summary line). Those rows therefore need round-41 old→new migration entries in the
  round-41 journal, or the C1 gate refuses them as `UNJOURNALED`/`NEW_MISMATCH`. Exact old→new values and
  the journal path: `⟨SLOT: migration old→new values and journal path⟩`.

  Ceiling on C2, measured by the critic seat with the frozen counter itself: a degenerate paragraph that
  merely name-drops `S095 S097` and carries the frozen quote as decoration reads **3** (a = 1, b = 1,
  c = 1) — the counter certifies citation shape, one quote substring, and a body binding that does not
  depend on the paragraph. Term (b)'s `locate` invokes the hard-coded lane
  `corpus/rendered-text-v1.py`, not `$RTV1`, so the binding always tests the landed lane file. The
  grounding-quality check of each sentence is the round's reviewer item K41ReviewDocs, as the plan's
  ceiling says.

## Gate

- **ADMIT (re-open) S095** — `https://docs.python.org/3/library/re.html`, tier A docs. Access: re-fetched
  2026-11-05 with `curl -fsSL`; served `<title>re — Regular expression operations &#8212; Python 3.15.2
  documentation</title>`; live body 257722 bytes, sha256
  `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1`, `cmp` against the committed
  `.ufo/waves/round-40/capture/S095.body` exits 0 with no output — byte-identical, no drift. Located quote
  (7 whitespace tokens ≤ 25): “Matches Unicode whitespace characters (as defined by” at raw body byte
  offset **75897**, count 1 (`python3 corpus/rendered-text-v1.py locate` → `RENDERED_TEXT_V1_LOCATE:
  count=1`, exit 0). The teaching grounds C2's refresh: the backslash-s entry's Unicode-whitespace
  declaration is the basis of `corpus/rendered-text-v1.py`'s whitespace class. Scout receipts:
  `.ufo/waves/round-41/build/K41ScoutSources/` (`s095-cmp.txt`, `notes.md`, `capture/S095.body`).
- **ADMIT S097** — `https://docs.python.org/3/library/stdtypes.html` → final
  `https://docs.python.org/3/builtins/stdtypes.html` (301 on the first hop; a fetch row must record `url`
  and `final_url` separately and take `http_status` from the final hop), tier A docs, opened 2026-11-05.
  Served `<title>Built-in Types &#8212; Python 3.15.2 documentation</title>`. Body 815447 bytes, sha256
  `e2992e17d9b8f15f09b2971e356d06c5e0f1572fefa6ce733eb6d7d48466e2b3`. Located quote (locate form, ≤ 25
  words): “Return True if there are only whitespace characters in the string and there is at least one
  character, False otherwise.” — `locate` → `count=1`, exit 0. The same sentence is split by markup in the
  raw bytes; the contiguous raw run “if there are only whitespace characters in the string and there is
  \n at least one character,” sits at raw offset **295179**; the class-defining clause “its general category
  is” at raw offset **296702**; “IDEOGRAPHIC SPACE” at raw offset **296299**. The teaching: the
  `str.isspace()` definition (whitespace = general category `Zs`, or bidirectional class `WS`/`B`/`S`) is
  the class `rendered-text-v1.py` step 5 actually uses, so S097 — not S095 — grounds the class. Registry
  row id, quote cell and anchor cell as committed: `⟨SLOT: S097 row id / quote cell / anchor cell⟩`.
  Scout receipts: `.ufo/waves/round-41/build/K41ScoutSources/` (`notes.md` §3, `capture/S097.body`).
  The committed capture path after the L1's copy: `⟨SLOT: committed capture path⟩`.
- **REJECT S098** — `https://www.unicode.org/reports/tr18/` (Unicode UTS #18, Regular Expressions), tier A
  spec, opened 2026-11-05; body 199607 bytes, sha256
  `68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d`. Served
  `<title>UTS #18: Unicode Regular Expressions</title>`. Two independent grounds, both measured:
  (1) **class mismatch** — `str.isspace()` accepts **U+001C, U+001D, U+001E, U+001F**, which the UTS #18
  `White_Space` property does not (over all of U+0000..U+10FFFF: A = 29 code points, B = 25 code points,
  A − B = {U+001C, U+001D, U+001E, U+001F}, B − A = ∅; probe receipt
  `.ufo/waves/round-41/build/K41LabRejectProbe/probe.txt`, independently re-derived at the same sha256
  `f438f532e8737bb8a2702126cdf9c4af5e357c58c7acf9d9eb2fc7c1a1d955d6` for
  `https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt`); (2) **the served page does not carry the
  claimed form** — the literal `\p{White_Space}` does not occur in the served body (`locate` → count 0,
  exit 1; raw find → not found), so a registry row could not quote it from this body. Reason: the
  normalizer's whitespace class is `str.isspace()`, and UTS #18's `White_Space` cannot ground it.
  **Flip condition:** the normalizer's class is redefined to `White_Space` (then S098 becomes the
  grounding source, and its `\s`-as-`\p{White_Space}` form would have to appear in the served page).
  Registry row id, status cell and rejection-text cell as committed: `⟨SLOT: S098 row id / status cell /
  rejection text⟩`.
- **Rows touched old → new** (every row the round changes): `⟨SLOT: rows-touched table — the L1 fills it
  from the committed `corpus/SOURCES.md` diff⟩`. Expected shape, not yet measured: S097 appended (new row,
  tier A docs); S098 appended (new row, tier A spec, status rejected); no existing row's mutable cell
  edited in place (CORPUS.md SOURCES rule 2), and the census-derived ledger rows that follow from the two
  appended rows are migrated, not rewritten.
- **Id collision guard** (run before the two new ids are used):

  ```
  git show 5142b52:corpus/SOURCES.md | grep -oE '^\| S[0-9]{3}' | tr -d '| ' | sort -u > reg-ids.txt
  printf 'S097\nS098\n' | sort -u > new-ids.txt
  comm -12 reg-ids.txt new-ids.txt          # -> no output, rc 0
  ```

  Measured output: **empty** (96 registry ids at `5142b52`; S097 and S098 collide with none of them).
  Against the eight quarantined absent-defect-register ids listed in `corpus/lessons/round-37.md`
  §Quarantine (S053, S071, S081, S090, S091, S093, S108, S113), `comm -12 new-ids.txt` is likewise empty
  (rc 0). The same comparison of the *lane's* ids against those eight names is **not** empty — S053,
  S071, S081, S090, S091, S093 — which is the spelling collision recorded in the round-37 and round-38
  lessons and the reason a later adoption must re-key first. Limit: the register file itself
  (`/home/vgpnk/Projects/shokunin/shokuknow/.ufo/waves/corpus-expansion-1/absent-defect-register.md`) is
  **not present on this host** (`ls` → no such file or directory), so the eight-id list was taken from the
  committed round-37 lesson table, not re-read from the register.
- **Quarantine: none.** kagi is not a wave-4 lane: the r100 directive's wave-4 quarantine-first obligation
  names tabi, revenger, chousa, kotodama
  (`.tower/comms/missions/M13-r100-assimilation-prompt-contract.md`, `.tower/comms/reviews/…` review), and
  kagi is not among them; no adoption is attempted this round and the `merge/kagi/` package is not opened.
  The round-37 absent-defect-register slice for kagi (8 rows) stays unadopted as recorded there — this
  round neither adopts nor re-reads it (`⟨SLOT: L1 confirms whether the round-37 eight-row slice is
  restated in this round's Gate⟩`).

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M41-1 | counter accepted loosened expects (a counter that cannot tell a migration from a loosening) | `corpus/lessons/round-40-verifier-spotcheck.md` §2 and `.ufo/waves/round-40/build/K40CriticClaims/verify-forge-c1-loosened-expects.txt` (committed; the round-41 reviewer seat re-ran the pre-change `claim-ledger.sh verify` on the four forged copies and observed F1–F3 accepted silently, receipts under `.ufo/waves/round-41/build/K41ReviewJournal/`) | `none` | C1 gate: `corpus/expect-journal.sh` (R1 `UNJOURNALED`, R2 `OLD_MISMATCH`/`COMMAND_MISMATCH`/`NEW_MISMATCH`, R3 `NOT_LITERAL`, R4 warn-only `WARN ORPHAN`); the fix counts only once F1–F4 are shown refused — the C1 candidate reading `⟨SLOT: c1 candidate reading⟩` and the four refusal tokens `⟨SLOT: F1–F4 refusal lines⟩` are the evidence |
| M41-2 | normalizer Sources cited unidentified or superseded documentation (a declaration whose sources are named by name only, with a superseded id and a class claim the cited page does not carry) | `corpus/rendered-text-v1.py` Sources paragraph at `5142b52` cites S-less docs — the paragraph reads "Sources (opened round 24, see corpus/SOURCES.md): Python `re` \\s for str / patterns and Python `html.unescape`." (lines 45–46 at `5142b52`); round-40 spot-check §5 and §7 item 5 (the same paragraph "cites superseded S027; states U+3000 is in the class the page grounds, and the 3.15.2 page has no U+3000 token") | `none` | C2: re-ground the Sources paragraph on S095 and S097 (the paragraph the executor seat drafted cites S095, S096, S097, carries the frozen quote on one physical line, and cites no superseded id) |
| M41-3 | wave seat count conformance (the wave's L2 role split had no planner seat) | round-40 spot-check §1 ("planner seat missing (the L1 held the planner role; §3 requires 1× planner) — conformance defect, status-neutral") | `none` | the L1 holds the planner seat and the report names it: round 41 is one v1 build wave, 11 seats, the planner role is the L1 (`plans/round-41.md` §Shape), and the report's §Round shape states it |

## Frontier

- What this round advances, on the **rendered-text ground**: S095 re-opened and byte-identical, S097
  admitted as the grounding row for the whitespace class (`str.isspace()`), and S098 **rejected** on two
  measured grounds (the `isspace` ⊃ `White_Space` difference of four code points, and the absence of the
  literal `\p{White_Space}` from the served page). The `rendered-text-v1.py` Sources paragraph moves from
  S-less prose to named, non-superseded ids with one bound quote.
- What this round advances, on the **calibration ground**: the expect-journal gate — the first committed
  instrument that distinguishes a *migration* from a *loosening* of a ledger expectation, and the first
  counter whose target (4) is unreachable by doing nothing (BASE 0) and unreachable by refusing
  everything (blanket-refuse control 0) or accepting everything (blanket-accept control 0).
- Rows added: S097 (tier A, docs) and S098 (tier A, spec, rejected). Rows touched old → new:
  `⟨SLOT: rows-touched table⟩`. No frontier-to-core move; no new `corpus/knowledge/` entry.
- Mistakes mined this round: M41-1, M41-2, M41-3 (table above). Captured-by: none for all three — the
  fixes are routed, not yet shown able to fail by a committed control.
- Sourced claim: C2 rests on S095 and S097, both opened this round (scout K41ScoutSources, receipts under
  `.ufo/waves/round-41/build/K41ScoutSources/` and the capture bodies the L1 copies to
  `.ufo/waves/round-41/capture/`). The knowledge entries that consume the teaching are unchanged.
- Assimilation: none this round.

## Routed

Carried to **round 42**, named here so the closure can check that they were carried:

1. **C3 counter defect** — M40-9 (counter reads the verdict token only, so a stub selftest reads 2),
   M40-10 (a constant-6 counter passes the battery), M40-17 (selftest case coverage: the HTML-comment D2
   heading variant is not in the eight cases). The C3 counter must exercise the gate's own case list or a
   committed case-count receipt, with a stub-selftest red witness. Not claimed this round.
2. **Gate-selftest scratch default** — the five gates still create their selftest fixtures under
   `${TMPDIR:-/tmp}` (measured: `corpus/anchor-pins.sh:37`, `corpus/claims-declared.sh:37`,
   `corpus/prefreeze-control.sh:94` and `:274`, `corpus/self-description-sweep.sh:226`,
   `corpus/surface-census.sh:275`). The round-41 gate and counters use
   `${HYAKU_SCRATCH:-/fast/scratch/hyaku}`; the older defaults are round-42 work.
3. **Round-40 report amendment** — the round-40 report was amended in place
   (`.ufo/reports/round-40/kagi.md`, commit `14f47cbd`); the correction belongs in an appended erratum,
   never a rewrite. Round-42 work; the round-41 report is filed once.
4. **Round-41 gate blind spot (new this round)** — the frozen classes referee *changes* only: a row
   deleted from the candidate ledger is in neither population, so no frozen class speaks about it
   (reviewer attack A6, `.ufo/waves/round-41/build/K41ReviewJournal/attacks.md`). One sentence in the
   round's disclosed ceilings; a `MISSING_ROW` rule is round-42 instrument work.
5. **Plan §C1 existing-gate-control sentence** — "accepts F1–F4 by construction" is measured FALSE for F4's
   echo construction: the old gate's policy allowlist refuses the rebind before execution
   (`first-token:echo`). The report must not state blanket acceptance of F4; the sentence is corrected by
   erratum, not by rewriting the frozen plan.
6. **C2 BASE receipt is unpinned (critic defect)** — `plans/round-41-controls.sh` writes
   `c2-base-19025d9.txt` by running the C2 counter in the lane working tree with no commit pin, so a
   post-landing re-run of the controls would overwrite the BASE receipt with the candidate's reading and
   leave a self-contradicting file. The committed receipt reads `1` today because the worktree equals
   `19025d9` (the docstring sha256 is identical at both revisions). The L1 must either run the C2 BASE
   control from a `git archive 19025d9` extraction or re-read the committed receipt rather than
   regenerate it; the fix to the controls runner is round-42 work (the frozen counter is not edited).
7. **C1 landing-check base ledger (critic ambiguity)** — the C1 kill rule's "any of the six round-40
   migrations is refused by the gate at the round-41 landing" is only testable with the round-40 claim
   BASE ledger `6cc8850` as `--base-ledger`; against `19025d9` the six rows are unchanged from base and
   the clause is vacuous. The round report must record the `6cc8850` interpretation.
8. **C2 selftest case count at the landing (critic gap)** — the kill rule's "the selftest drops below 22
   cases" needs an explicit case-count measurement at the landing tree (measured at BASE:
   `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exactly at the floor); the counter's term (c) checks
   only rc 0 and the `PASS` token, not the count.

## considerthese

The latest file is `considerthese/2026-10-26.md`. Its self-improvement proposals: **proposal 3**
("mark known-defective instrument output" — append a `KNOWN_DEFECT: D1` qualifier to a `CLEAN` verdict)
and **proposal 1** ("a repair-only release path under a HOLD") **remain unimplemented**; proposal 2
("machine-readable lane status") landed in round 31 (`lane-status:` line, `SCORECARD.md:14`) and proposal 4
was refused in round 32 (`corpus/lessons/round-33.md` §considerthese records both dispositions).
Measured anchors: `grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → 0 at `5142b52`, so proposal 3's
qualifier was never added; no repair-only ticket mechanism exists in the lane, so proposal 1 was never
built (it is operator policy). **No proposal is taken this round — reason: no separable claim slot.** The
round's two claims are fixed by the frozen plan (C1 calibration, C2 freshness), and neither proposal
carries a claim this round could hold without widening a frozen predicate.
