# ConsiderStatus — round-31 BUILD seat report

Seat: `ConsiderStatus` (leaf; no dispatch). Wave: `kagi-r31-build`.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Lane tip at report time
`91f7752`; frozen BASE `655e620`. Date: 2026-11-03.

**Item:** mine exactly ONE still-unimplemented proposal from the latest
`considerthese/` file — proposal 2, "Machine-readable lane status" — and ground
it through the lane's bar.

**Verdict in one line:** proposal 2 is **still unimplemented** and **still
worth landing**, but **not as filed** — its example value is stale (the HOLD it
describes was lifted), its key (`status:`) is already overloaded twice in this
lane, and its separator (`;`) is *un-bindable by the lane's own claim-ledger
policy*. The draft fixes all three and splits the falsifier lane-local vs.
cross-boundary.

## Behaviour (what I did)

1. Read `plans/round-31.md` (the frozen claims contract) first, then
   `considerthese/2026-10-26.md` (the latest file in `considerthese/`).
2. **Unimplemented check** (required before landing): grepped for any
   existing machine-readable status convention — `grep -rn 'status:' SCORECARD.md`
   (1 hit, and it is an embedded `node -e` script, not a status line), anchored
   `^status:` across all 8 lane root docs (0), `corpus/self-counts.py` /
   `.tsv` for a status binding (only the per-claim `OK`/`STALE` verdict), any
   `STATUS*` file in the lane (none), and `^status:` in the 11 sibling lanes'
   `SCORECARD.md` (0 everywhere — fleet-absent, not lane-absent). **Proposal 2
   stands; no fallback proposal needed.**
3. **Grounded it through the lane's bar**: what the line establishes (a
   lane-authored self-declaration with a date) vs. what it cannot (it is not a
   driver control; the operator's holds live in the fleet root's
   `.ufo/l0-questions.md` and `MANIFEST.json`, and the lane cannot release a
   hold); the falsifier, including the finding that the task's named witness —
   the watchdog log — **carries no hold vocabulary at all** (0 hits on any kagi
   line) and therefore cannot witness the state; and the recheck trigger.
4. **Measured the coupling** of a candidate line against the lane's own gates
   (`cells`, `citations`, `idref_audit`, the stamp file, the ledger policy) in a
   scratch clone/fixtures under
   `/fast/scratch/hyaku/kagi-r31/ConsiderStatus/`.
5. **Recorded proposal 3's staleness** against `corpus/lessons/round-29.md` §C1
   (do not mine it) and wrote the draft + lesson snippet.

## Gates / measurements (all lane files READ-ONLY; mutations only in scratch)

| # | measurement | result |
|---|---|---|
| 1 | proposal-2 unimplemented, checks A–H | receipt `build/ConsiderStatus-receipts-unimplemented.txt` |
| 2 | `cells` with a `## Lane status` section (shaped scorecard, scratch clone at reshaped BASE) | `cells=210` before and after — **unchanged**; `R13-01` count 36 and `R24-06` digest `5193d55b…` **identical** before/after |
| 3 | `cells` with a `## Round 31 status` heading | `claim-ledger: unrecognised round heading … '## Round 31 status'` → **exit 2** (would fail the plan's C1 predicate) |
| 4 | `cells` with a *trailing* `## Lane status` after a 5-axis round section | `does not carry all six axes exactly once (found=5 missing=adjacency)` → **exit 2** ⇒ place the status section **before** the first `## Round` heading |
| 5 | `cells` after adding bytes to `SCORECARD.md` (no re-stamp) | `STALE-POINTER SCORECARD.md sha=f4eb6ec481f1->bdb7c41cabcc lines=1252->1256 bytes=134670->134788` ⇒ the line costs a stamp re-pin + `R24-05`/`R12-03` identity migration |
| 6 | ledger policy on candidate binding rows | `;` and `|` inside a row command → `POLICY … reason=metachar` (e.g. `grep -cE '^status: (open\|frozen) '`, `grep -c '^status: open; '`); the four **proposed** rows (`;`-free, em-dash form) → **`failed=0 policy=0`** |
| 7 | the negative-control row's exit code | `grep -c '^lane-status: held'` returns count 0 and **exit 1**; with expected exit 0 it reads `FAIL … exit-mismatch exit=1 want=0` ⇒ the row must declare **expected exit 1** |
| 8 | `idref_audit` with an unresolvable id on the status line | `MISSING-ID SCORECARD.md:6 R25-02` … → `CELL_AUDIT: BROKEN (… missing_ids=3)` **exit 1** ⇒ the three routed ids must exist in `corpus/claim-ledger.tsv` (they do: lines 81/84/85) |
| 9 | `MARK_RE` words on the status line | `no longer` turns an unresolvable id into `LABELED-ID` and a fleet path into `LABELED` — the line would *appear* to satisfy a check it does not ⇒ the proposed wording avoids every `MARK_RE` word |
| 10 | `citations` gate, fleet layout, status line citing `.ufo/l0-questions.md` | `CITATION_GATE: CLEAN (cites=289 …)`, exit 0 — but the **same** line in a lone clone gives `FLEET-ABSENT` → `CITATION_GATE: INCOMPLETE (… fleet_absent=1)`, **exit 3** ⇒ the lane's own line must stay **fleet-path-free** |
| 11 | watchdog log as a hold witness | `grep -iE 'kagi' .ufo/watchdog.log \| grep -icE 'hold\|block\|frozen'` → **0**; event vocabulary = `launch / complete / lane-dead-no-report / lane-round-failed / wrap / steer / tick / launch-fail` ⇒ the watchdog **cannot** witness dispatch authorisation |
| 12 | operator's current state | run-15 directive verbatim: *"No holds; kagi's refusal boundary … stay binding"*; `MANIFEST.json` `rounds[].lanes.kagi` = `"ok"` (rounds 29 and 30 — but the *round-level* `verdict`/`admitted` differ: round 29 `admitted: true`, round 30 `rejected-honest-stop`/`admitted: false`); `.ufo/l0-questions.md` = **6** open `kagi \|` lines (rounds 10, 16, 28 ×2, 30 ×2); round-28 HOLD row at `.tower/comms/inbox/20261024-r100-recovery-census-tower-survey-summary.md:37` |
| 13 | proposal 3's premise vs `corpus/lessons/round-29.md` §C1 | at round-28 `5e84747`, `corpus/release-clock.py:781` was `…([0-9]+\.[0-9]+\.[0-9]+)$` (a `$` anchor); at round-29 `fc65112` and at BASE it is `…([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]\|\.[0-9])` at `:789`, recipe comment at `:781-783`; round-29 measured outcome "NF MISHANDLED 5/7 → **0/7**, CORRECT 2/7 → **7/7**" ⇒ **premise stale**, proposal 3 **not mined** |

## Touched surfaces

**Written (both under the wave dir, both mine):**

- `.ufo/waves/round-31/build/ConsiderStatus.md` — the draft: the unimplemented
  check, the bar grounding (establishes / does not establish), the falsifier
  split, the exact proposed line format and current value, the four proposed
  binding rows, the lesson snippet for `corpus/lessons/round-31.md`, the
  staleness note on proposal 3, and the honesty ledger.
- `.ufo/waves/round-31/build/ConsiderStatus-receipts-unimplemented.txt` — the
  unimplemented-check receipt (checks A–H).
- `.ufo/waves/round-31/ConsiderStatus-report.md` — this file (the item's
  declared report path).

**Read-only, unmodified:** every lane production file (`plans/`, `SCORECARD.md`,
`LOG.md`, `corpus/**`, `considerthese/**`). No lane file was created, edited or
deleted — including `corpus/lessons/round-31.md`, which does not exist yet; the
lesson snippet in the draft is a **proposal** for the L1 to land. No lane git/jj
mutation; nothing committed or pushed; no fleet-repo or sibling-lane edit.

**Scratch:** `/fast/scratch/hyaku/kagi-r31/ConsiderStatus/` (clone + fixtures +
receipts) — **deleted before this yield**; every receipt I quote is reproduced
above and the unimplemented-check receipt was copied into the wave dir first.

## Findings

**F1 — Proposal 2 is still unimplemented, and the key `status:` is already
overloaded twice in this lane.** Anchored `^status:` is 0 in all 8 lane root
docs and 0 in all 11 sibling lanes' scorecards. The only `status:`-shaped
vocabularies are `Source-status: historical — …` (14 knowledge entries, per-entry
source freshness) and `self-counts.py`'s per-claim `OK`/`STALE` verdict. Hence
the draft proposes **`lane-status:`**, not `status:`.

**F2 — The proposal's example value is stale.** It was filed 2026-10-26 while
the lane was held; the round-28 HOLD was lifted by the operator's run-15
directive ("No holds"), rounds 29 and 30 were dispatched and run (watchdog
`launch`/`complete kagi round=30`, 2026-11-03; `MANIFEST.json`
`rounds[].lanes.kagi` = `"ok"` for both), and round 31 was dispatched on
2026-11-03. The value lands as `open`, and the *scope* must be "dispatch
unblocked" — not "no holds", because the 2026-10-21 content-safety refusal
boundary stays binding and two round-28 L0 lines (90, 158) await a documentary
disposition. "no holds" would be a **false** claim. The converse conflation is
also forbidden: round 30's *closure* was `rejected-honest-stop`/`admitted:
false` while its dispatch ran fine, so "open" must never be read as "the last
round was admitted" — which is why the proposed line carries an explicit `scope`
field.

**F3 — The task's named falsifier witness does not carry the fact.** The
watchdog log has **zero** hold/block/frozen hits on any kagi line; its vocabulary
is dispatch *lifecycle*, never dispatch *authorisation*. The records that carry
the fact are all fleet-root: `.ufo/l0-questions.md` (6 open kagi lines),
`MANIFEST.json` `rounds[].lanes.kagi`, and the round-28 HOLD row at
`.tower/comms/inbox/…:37`. A lane-side gate cannot reach any of them, and
should not try: citing a fleet path from a lane doc makes the lane's own
citations gate read `INCOMPLETE`/exit 3 in a lone clone (measured) — QM22's
typed state, correct behaviour, not a defect. **Hence the falsifier is split:
the lane binds shape/count; the operator/closure judge binds truth.**

**F4 — A `;`-separated status line is un-bindable by the lane's own ledger.**
`claim-ledger.sh`'s `META_RE` refuses `;` and `|` anywhere in a claim row's
command, including inside quotes (measured `POLICY … reason=metachar` on three
candidate needles). A `;`-separated value could therefore never be matched by
a lane binding row — the convention would be un-enforceable by the lane's own
machinery. **The em-dash ` — ` separator binds cleanly under both `LC_ALL=C`
and `en_US.UTF-8`.**

**F5 — Two non-obvious failure modes the L1 must know before landing.**
(a) The negative-control row must declare **expected exit 1** (`grep -c` exits 1
at zero matches) or it reads FAIL on a correct tree. (b) `idref_audit` turns an
unresolvable id on the status line into `MISSING-ID` + `CELL_AUDIT: BROKEN`
exit 1 — so naming the routed reds is a feature (the line cannot go stale in
silence) *and* a coupling (a future round that renumbers those rows must update
the line in the same landing). Separately, any `MARK_RE` word on the line
(`no longer`, `historical`, …) downgrades its ids/paths to `LABELED`/`LABELED-ID`,
i.e. the line would *appear* to satisfy a check it does not.

**F6 — Placement and cost.** `## Lane status` is safe and moves neither
`R13-01` (count 36) nor `R24-06` (digest) — measured identical before/after —
but it must sit **before** the first `## Round` heading: a status section after
the last round section makes `cells` close that section and enforce its six-axis
check (measured exit 2). Any added byte invalidates `SCORECARD.md`'s stamp, so
the line **rides the C1 landing and the plan's `LC_ALL=C` re-stamp**; landed
separately, every status change would cost a fresh stamp re-pin plus an
`R24-05`/`R24-06` identity migration. That is the one point I would press: the
mechanism is worth one migration, not one per round.

**F7 — Proposal 3 is not mined (premise stale).** The D1 fail-open it would
label was closed at round 29: the recipe comment at `corpus/release-clock.py:781-783`
and the right-boundary `STABLE_TITLE_RE` at `:789` replace the `$`-anchored
form at round-28's `:781`, and round-29's measured outcome is "NF MISHANDLED
5/7 → 0/7, CORRECT 2/7 → 7/7". A `KNOWN_DEFECT: D1` qualifier on a `CLEAN`
verdict today would announce a defect that no longer exists. The still-open
items it must not be confused with are a *ruling* (L0 line 158) and a *policy
registration* (`R25-02`/`R29-01`/`R29-02`), both operator-routed.

## Out of scope (not done, deliberately)

- **No lane file was modified**, so the `## Lane status` section and the four
  `R31-S0x` rows are **proposed only** — no row was added to
  `corpus/claim-ledger.tsv`, and `corpus/lessons/round-31.md` was not created.
  The L1 lands or rejects.
- **No QM32.** That slot is frozen for M30-4 by the plan; the durable form of
  this proposal is a *new* QM33, proposed separately so it does not contend.
- **No full live-lane `claim-ledger.sh verify`** (>300 s in the clone; round-29
  lesson M29-3 records the same cost). The live-lane run I did execute is the
  15.8 s `citations` mode over the real `SCORECARD.md` and a status-line copy.
- **No `op` contact of any kind** — not even `--version`, since nothing in this
  item needed it. No credential, vault, account, handler or CDP surface touched.
- **No network fetch** (the declared fetch re-opens were not needed for this
  item). **No pacman transaction; no tool installed or upgraded** — nothing in
  this item needed one, so the "install useful tools" directive was a no-op here
  (no tool/version/channel entry to record; `python3` 3.14.8 and `op` 2.41.1 were
  the pre-existing host facts, neither invoked).
- **No git/jj mutation anywhere**, in the lane or in the fleet root; the scratch
  clone's only git operations were `clone`/`checkout`/`rev-parse` for reading
  BASE bytes, and `git rev-parse --show-toplevel` was asserted to be the scratch
  clone before any fixture mutation.

## Artifact paths

- Draft: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-31/build/ConsiderStatus.md`
- Receipt: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-31/build/ConsiderStatus-receipts-unimplemented.txt`
- This report: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-31/ConsiderStatus-report.md`
- Scratch (deleted before yield): `/fast/scratch/hyaku/kagi-r31/ConsiderStatus/`
