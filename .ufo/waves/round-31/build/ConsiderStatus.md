# ConsiderStatus — considerthese proposal 2, "Machine-readable lane status"

Seat: ConsiderStatus (leaf). Round-31 BUILD, lane `kagi-shokunin`.
Source proposal: `considerthese/2026-10-26.md` §"Self-improvement suggestions", proposal 2.
Drafted: 2026-11-03. Lane files are READ-ONLY to this seat; everything here is a
proposal for the L1 (KagiR31) to land or reject. Nothing in the lane was modified.

## 0. Scope note — proposal 2 as filed, and what changed since

The filed proposal reads:

> **2. Machine-readable lane status.** Put the HOLD (reason, date, who can release
> it) in one file that the tools read, such as a `STATUS` line in `SCORECARD.md`.
> Then `release-clock.py`, the census and my daily pass can all say "lane frozen
> since 2026-10-25" instead of each reconstructing it from `LOG.md` prose.

Two things must be said before the draft, because they change the shape of what
lands:

1. **The HOLD the proposal was written about is gone.** The proposal was filed
   2026-10-26, when the lane was held (round-28 HOLD row, `.tower/comms/inbox/
   20261024-r100-recovery-census-tower-survey-summary.md:37`). The operator's run-15
   directive (`/home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-31.md` §6)
   states: *"No holds; kagi's refusal boundary, mado's credential-material
   rule and mori's settings/session redaction rule stay binding."* The lane has
   since been dispatched and run at rounds 29 and 30 (`.ufo/watchdog.log`:
   `launch kagi round=30` / `complete kagi round=30`, 2026-11-03; `MANIFEST.json`
   `rounds[].lanes.kagi` = `"ok"` for both), and `.ufo/watchdog.log` carries
   `launch kagi round=31` (2026-11-03T16:23:55). So the line's current value is
   **open**, not frozen. The *mechanism* the proposal asks for is still exactly
   right — a machine-readable status is worth having precisely because it does not
   have to be reconstructed from prose — but the value lands as `open` and the
   "frozen since <date>" shape has to be a field, not the whole line.

   Note precisely what "open" must and must not imply: **dispatch** was
   unblocked (both rounds ran), but round 30's *closure* was
   `MANIFEST.json` `rounds[].verdict = "rejected-honest-stop"`, `admitted: false`
   (round 29 was `admitted`; round 28 likewise `rejected-honest-stop`). A status
   line about *dispatch authorisation* must not be read as a statement about
   whether a round's claims were admitted — those are different facts, and
   conflating them would be a false claim in the opposite direction. This is
   exactly why the proposed line carries an explicit `scope` field.

2. **The proposal's own example is the reason the mechanism is still needed.** The
   filed proposal's own preamble says the HOLD lived in *"Fleet records"*, i.e.
   outside the lane, in a Markdown table row in a `.tower/comms/inbox` file and in
   the operator's L0 queue. The lane's own `LOG.md` carried the prose restatement
   (round-28 entry, `LOG.md:1562-1570`), and `SCORECARD.md:1164` cites the fleet L0
   path. So today: the lane's dispatch state is genuinely reconstructed from prose
   across three files, and the proposal's premise ("each reconstructing it from
   `LOG.md` prose") is confirmed, not refuted.

## 1. Unimplemented check (required before landing)

Proposal 2 is **still unimplemented** in the lane. Verified at lane tip
`91f7752` (BASE `655e620`); full receipt:
`.ufo/waves/round-31/build/ConsiderStatus-receipts-unimplemented.txt`.

| # | check | result |
|---|---|---|
| A | `grep -rn 'status:' SCORECARD.md` | 1 hit — `SCORECARD.md:505`, and it is inside an embedded `node -e` one-liner that greps `/^Source-status: historical — /m`. **Not** a lane-status line. |
| B | `grep -rn '^status:' SCORECARD.md` | rc=1, no match. No anchored status line anywhere in the scorecard. |
| C | `corpus/self-counts.py` "status" | 2 hits, both the per-claim verdict variable (`status = "OK" if claimed == value else "STALE"`, printed as `OK`/`STALE` per claim). This is the **self-count staleness verdict**, not a lane-status binding — and note the near-collision of vocabulary. |
| D | `corpus/self-counts.tsv` "status" | rc=1, no match. No status binding in the self-counts table. |
| E | `^status:` in every lane root doc (`SCORECARD.md`, `LOG.md`, `PROVINCE.md`, `SKILL.md`, `SHONEN.md`, `AGENTS.md`, `corpus/README.md`, `corpus/QUALITY.md`) | 0 in all eight. |
| F | any `STATUS*` file in the lane | none. |
| G | `^status:` in the 11 sibling lanes' `SCORECARD.md` | 0 in all 11 — the convention is fleet-absent, not lane-absent. Nothing to be consistent with, and no fleet precedent to copy. |
| H | the one existing `status:`-shaped vocabulary in the lane | `Source-status: historical — …` in **14** `corpus/knowledge/*.md` entries. It is per-entry *source freshness*, not lane dispatch state. |

**Verdict: proposal 2 stands; nothing to pick instead.** Note the two
near-collisions the convention must not be confused with: `Source-status:`
(per-entry, 14 entries) and `self-counts.py`'s `OK`/`STALE` verdict (per-claim).
A lane-status convention therefore wants a **distinct key**; this draft proposes
`lane-status:` rather than a bare `status:` precisely because `status:` alone is
already overloaded twice in this lane.

## 2. The line establishes — and what it does not

This is the grounding question, and the answer is asymmetric.

**What a lane-authored status line CAN establish.** The lane is the authority on
*its own* dispatch posture as *the lane believes it to be*, with a date. It is a
**lane-authored self-declaration**, and it is falsifiable: a claim without a
contradicting record is a claim without a witness.

**What it CANNOT establish — and the lane has no authority here.** The operator's
holds live in the fleet root: `.ufo/l0-questions.md` (6 open `kagi |` lines at
round-30) and `MANIFEST.json` (`rounds[].lanes.kagi`, plus
`rounds[].verdict`/`admitted`). The lane does not own the hold, cannot release
it, and cannot learn of a hold except by reading the operator's file. The lane's
own driver is equally out of reach: `.ufo/watchdog.log` and
`scripts/hokunin-watchdog.sh` read only `.ufo/state/<lane>.{round,mission,
report-baseline}`; `scripts/hyaku/inline.sh` reads `.ufo/state/` and git state.
**Nothing in the driver reads `SCORECARD.md`.** Verified: `grep -rnE 'SCORECARD'`
over `scripts/` returns only closure-prompt prose and a driver comment about
*not* writing the fleet-root `SCORECARD.md`. So a `lane-status:` line in the lane
scorecard is **inert to dispatch** — it is a readout, not a control. That is the
correct and intended property: it must not be able to release a hold, because the
lane cannot release a hold.

**Therefore the line's value must be the LANE's belief, attributed.** A line that
says "open" with no attribution reads as an operator release and is a false claim
whenever the operator holds the lane. The draft format carries the attribution
inline.

## 3. The falsifier (the binding that makes the line a claim, not a decoration)

The task named "the watchdog log" as the witness. **That witness does not carry
the fact.** Measured on `/home/vgpnk/Projects/shokunin/.ufo/watchdog.log`: the
file has **zero** occurrences of `hold|frozen|freeze|block` on any `kagi` line
(`grep -iE 'kagi' .ufo/watchdog.log | grep -icE 'hold|block|frozen'` → 0), and its
whole event vocabulary is `launch / complete / lane-dead-no-report /
lane-round-failed / wrap / steer / tick= / launch-fail`. The watchdog records
*dispatch lifecycle*, never *dispatch authorisation*. The 24 `hold|block|frozen`
hits in the file are other lanes' prose inside reason strings.

So the falsifier must be the record that actually carries the fact. Three
candidates, in decreasing authority:

1. **`.ufo/l0-questions.md`** — the operator's own queue, 6 open `kagi |` lines
   (rounds 10, 16, 28 ×2, 30 ×2). This is where a HOLD or its release would be
   ruled. Fleet-root, outside the lane.
2. **`MANIFEST.json` `rounds[].lanes.kagi`** — the closure ledger's per-round
   lane verdict (`"ok"` at rounds 29/30). Fleet-root. Note its two levels: the
   per-lane `lanes.kagi` field and the per-round `verdict`/`admitted` pair
   (round 29 `admitted`, round 30 `rejected-honest-stop`) are different facts,
   and a *dispatch* status must be read off the first, not the second.
3. **`.tower/comms/inbox/…tower-survey-summary.md:37`** — the round-28 HOLD row
   itself (`| kagi | 28 | — | r27 admitted | 899c50b4 | **HOLD — policy** | Never
   dispatch (content-safety/cyber refusal, 2026-10-21 lifecycle metadata; card
   lines 46-51, 97-99, 388) |`). Fleet-root, and the only *machine-shaped* HOLD
   record in the fleet — a Markdown table row with `**HOLD — policy**` in a fixed
   column.

**A lane-side falsifier cannot reach any of them**, and that is a structural
fact, not a gap to be closed in this round. The lane's own citation gate already
demonstrates the shape: cite a fleet path from a lane doc and the gate reports
`FLEET-ABSENT` in a lone layout and `INCOMPLETE` (exit 3), and `CLEAN` in the
fleet layout. Measured both ways on this host:

- fleet layout, `SCORECARD.md` with `.ufo/l0-questions.md` cited:
  `CITATION_GATE: CLEAN (cites=289 docs=1 unresolved=0 ephemeral=0 labeled=0)`, exit 0
- lone clone, same file: `FLEET-ABSENT SCORECARD.md:5 .ufo/l0-questions.md (ufo)` →
  `CITATION_GATE: INCOMPLETE (… fleet_absent=1)`, exit 3

That is **QM22 territory** (a layout-dependent check that must print a typed
INCOMPLETE/FLEET-ABSENT, never CLEAN, in a lone clone) and the existing
`R11-08` citations row already models it.

**So the falsifier is split, and the split is the honest answer:**

- **Lane-local falsifier (what this draft binds, and what is cheap and safe):**
  the line must be **exactly one** `lane-status:` line in `SCORECARD.md`, must be
  **shape-valid** (`lane-status: <state> — <as-of-date> — …` where `<state>` is one
  of a closed vocabulary), and must not carry a **fleet path** (which would drag
  the lane's own `citations` gate to INCOMPLETE in a lone clone — measured above).
  These are checkable with the lane's existing ledger vocabulary and are the
  binding this draft proposes.
- **Cross-boundary falsifier (not lane-local, and correctly so):** the line's
  *state word* must agree with the operator's records. That comparison needs the
  fleet root, so it belongs to the operator/closure judge, not to a lane gate. The
  lane can make the disagreement **visible** (it is the only place the lane's own
  belief is written down) but it cannot settle it, and it must not pretend to.

**Recheck.** A `lane-status:` line is a **point-in-time claim** about a moving
world, so it decays; the lane's `recheck:` vocabulary in `corpus/SOURCES.md` already
has the right shape for this (`90d`, `30d`, `on-release`, `180d`). The right
recheck trigger here is not a calendar interval but an **event**: a round that
opens or closes, or an operator ruling. Concretely: `recheck: on-release` — the
line is re-asserted whenever the lane's dispatch state changes, and a stale
`as-of:` date is itself the visible staleness signal. A calendar recheck (say
`90d`) would let a line claim "open" for three months after an operator HOLD; the
`as-of:` field makes that impossible to hide.

## 4. The proposed convention (exact line format)

**Key: `lane-status:` — deliberately not `status:`.** `status:` is already
overloaded in this lane (`Source-status:` in 14 knowledge entries;
`self-counts.py`'s `OK`/`STALE` verdict). A distinct key is what makes the line
greppable without ambiguity and prevents the two existing vocabularies from
being read as lane status.

**Format** (one line, in `SCORECARD.md`, in its own `## Lane status` section
placed *before* the first `## Round …` heading — see §6 for why placement is
constrained):

```
lane-status: <state> — <as-of:YYYY-MM-DD> — <scope> — <routed-to-operator-ids>
```

- `<state>` — closed vocabulary, one token, lowercase: `open` | `held`. Any other
  token is a defect, not a new state.
- `<as-of:YYYY-MM-DD>` — the date the lane asserts this state. Mandatory.
- `<scope>` — what the state refers to, so `open` is never ambiguous between
  "the lane may dispatch" and "the operator has no open ruling against it".
- `<routed-to-operator-ids>` — comma-separated ledger ids the lane is *not*
  deciding (empty ⇒ `-`). These are ledger rows, so the id is resolvable and the
  line cannot silently rot.

**Separator: em-dash ` — `, NOT `;`.** This is a hard constraint, not a style
preference, and it was measured. The lane's ledger policy (`corpus/claim-ledger.sh`
`META_RE='[;&|<>$`]'`, `ALLOWED_RE`, `PYTHON_SCRIPT_RE`) refuses `;` and `|` **anywhere
in a claim row's command**, including inside quotes:

- `grep -cE '^status: (open|frozen) '` → `POLICY … reason=metachar`
- `grep -c '^status: open; '` → `POLICY … reason=metachar`
- `grep -cE '^status: open; .*$'` → `POLICY … reason=metachar`

A `;`-separated status line is therefore **un-bindable by the lane's own ledger**:
any row that tried to match the value would be refused as a policy violation
before it ran. The em-dash form binds cleanly under every locale tested
(`LC_ALL=C` and `en_US.UTF-8`, both `1` for `^status: `, `^status: [a-z]+ `, and
`^status: open `). The `;` is used only *after* the em-dash fields, and only in
prose — never inside a needle.

**Proposed current value for round 31** (this is the "if it is cheap and safe"
part of the item — see §6 for the cost verdict):

```
lane-status: open — as-of:2026-11-03 — dispatch unblocked; 3 operator-routed reds (R25-02,R29-01,R29-02) stay red
```

Rationale for each field, against measured facts:

- `open` — the operator's run-15 directive says "No holds"; `MANIFEST.json`
  `rounds[].lanes.kagi` is `"ok"` for rounds 29 and 30; the watchdog launched
  round 31 on 2026-11-03. The lane is not held. (Read `lanes.kagi`, the
  dispatch-level field — *not* the round-level `admitted`, which is false for
  round 30.)
- `as-of:2026-11-03` — today's date; the directive and the dispatch are both
  2026-11-03.
- `dispatch unblocked` — the scope clause, deliberately **not** "no holds". The
  distinction is load-bearing: the operator's run-15 text lifts the *dispatch*
  hold while keeping the 2026-10-21 content-safety refusal boundary binding, and
  the lane has two open L0 lines from round-28 whose documentary disposition is
  still unanswered (L0 line 90 and line 158). "no holds" would be a false claim
  against those; "dispatch unblocked" is exactly what is true.
- the three routed reds — `R25-02` (FAIL), `R29-01` (POLICY), `R29-02` (POLICY)
  are the plan's named operator-routed reds (`plans/round-31.md` §Round context;
  `corpus/lessons/round-30.md` M30-4/M30-5). Naming them in the status line is
  what stops the line from reading as "everything is fine".

## 5. Proposed binding (lane-local, policy-clean, measured)

Four candidate claim-ledger rows, each one `grep` (allowed first token), each
**without** `;` or `|` so none is refused by `META_RE`:

| id | command | expect | exit | what it falsifies |
|---|---|---|---|---|
| `R31-S01` | `grep -c '^lane-status: ' SCORECARD.md` | `^1$` | 0 | more or fewer than one status line (a second line is a silent contradiction) |
| `R31-S02` | `grep -cE '^lane-status: (open) ' SCORECARD.md` | `^1$` | 0 | the state token left the closed vocabulary (note: `(open)` — the alternation `(open\|held)` is refused as `metachar`, so the vocabulary check must be per-state or use a class) |
| `R31-S03` | `grep -c '^lane-status: held' SCORECARD.md` | `^0$` | **1** | the negative control: `grep -c` exits 1 when the count is 0, so the row's expected exit is 1, not 0 |
| `R31-S04` | `grep -c 'R25-02,R29-01,R29-02' SCORECARD.md` | `^1$` | 0 | the routed-red set silently changed without a ledger migration |

Measured end-to-end on a scratch fixture with the exact proposed line: the four
rows produce **`failed=0 policy=0`** — all policy-clean and all passing.
`R31-S03` in particular needed the **expected exit 1**: with expected exit 0 it
reads `FAIL R91-D reason=exit-mismatch exit=1 want=0`. That is a real trap for
whoever lands this.

**A caution on `R31-S02` as written.** `grep -cE '^lane-status: (open) '` binds
the *current* state, so it must be **migrated** (old→new) whenever the state
flips — which is the point, and is exactly the QM14 migration discipline the
lane already applies to `R13-01`/`R24-06` when the round count moves. If the
L1 prefers a state-agnostic row, `grep -cE '^lane-status: [a-z]+ '` is
policy-clean and locale-stable (measured `1` under both `LC_ALL=C` and
`en_US.UTF-8`) and binds the *shape* rather than the value; the value then
changes without a migration, at the cost of losing the state-change witness.
My recommendation: bind **both** — `R31-S02` (shape, migration-free) plus a
state-specific row whose expectation migrates.

**Second caution — the ids make the line a self-verifying claim, but also a
failure mode.** `idref_audit` (run by `claim-ledger.sh cells` and `verify`)
resolves every `R<n>-<n>`-shaped token in the doc set against the ledger, and an
unresolvable one is a hard `MISSING-ID` failure. Measured: adding
`R25-02/R29-01/R29-02` to a fixture whose ledger lacked them yields
`MISSING-ID SCORECARD.md:6 R25-02` … and `CELL_AUDIT: BROKEN (… missing_ids=3)`,
**exit 1**. In the real lane all three ids exist (`corpus/claim-ledger.tsv`
lines 81/84/85), so the live lane is safe — but the coupling is real: **if a
future round retires or renumbers any of those three rows, the status line
breaks the scorecard audit** unless the line is updated in the same landing.
That is a feature (the line cannot go stale in silence) but it must be stated in
the lesson, and it is a strong argument for naming the ids.

**Third caution — `MARK_RE` silently changes the line's meaning.** The lane's
citation and id audits treat a whole line as *labelled* (i.e. exempt from
resolution) if the line contains any of `scratch|ephemeral|relocat|formerly|no
longer|removed|renamed|historical`. Measured: putting `no longer` on the status
line turns an unresolvable id into `LABELED-ID` (counted, tolerated) and a fleet
path into `LABELED` (not unresolved). So a status line worded with "no longer"
would **appear** to satisfy an id/citation check it does not satisfy. The
proposed value avoids every `MARK_RE` word ("dispatch unblocked", "stay red");
the lesson must record the trap.

## 6. Cost, and the placement constraint the shape imposes

This is where proposal 2 turns from "a line" into "a landing with
consequences", and it is why the honest verdict on the current value is
**conditional**.

### 6.1 The line is a `## ` heading, and `cells` parses the scorecard

`corpus/claim-ledger.sh cells` walks `SCORECARD.md` and, for every `## `
heading, either accepts it as a round section (`## Round <N> — pre-move|post-move`)
or **dies**:

```
claim-ledger: unrecognised round heading in SCORECARD.md: '## Round 26 — bounded release-drift response'
```

Measured consequences for a status section:

- A section headed **`## Lane status`** is safe: it is not a `## Round` heading,
  so `cells` treats it as a non-round section (`in_set=0`) and skips its
  content. The scorecard's six-axis `section_check` therefore does **not** apply
  to it, and its prose is not scored.
- A section headed **`## Round 31 status`** is fatal — measured:
  `unrecognised round heading in SCORECARD.md: '## Round 31 status'` → **exit 2**,
  which would fail the plan's own C1 predicate ("prints no `unrecognised round
  heading` setup error"). So the heading must not begin with "Round".
- **Placement matters, and the safe placement is the top.** `cells` closes the
  *current* section when it meets the next heading. A status section placed
  **after** the last round section would terminate that section and make
  `section_check` fire on it — measured, a scorecard whose final round section
  carries 5 of 6 axes and is followed by `## Lane status` dies with
  `scorecard section '## Round 90 — pre-move' does not carry all six axes exactly
  once (found=5 missing=adjacency)`, **exit 2**. Placed **before** the first
  `## Round` heading, the status section is closed by the first round heading
  and never becomes the closed section — no such coupling. **Recommendation:
  place `## Lane status` immediately after the scorecard's preamble, before the
  first `## Round` heading.**

### 6.2 The line moves `R13-01` and `R24-06`

`R13-01` is `grep -c '^## Round ' SCORECARD.md` (expect `^36$`); `R24-06` is the
`scorecard-rounds` identity digest of exactly those heading lines. A
`## Lane status` heading is **not** a `## Round ` heading, so it does **not**
move either row: measured, `grep -c '^## Round ' SCORECARD.md` = 36 with and
without the status section, and `row-identity.sh scorecard-rounds` gives
`count=36 sha256=5193d55b52107f06dcf206b804814e81accadce09ecffb60214984b002deabba`
identically before and after. **Good news for the plan: the status section is
free with respect to the C1 heading-reshape migration set** (the plan's own
correction 1 already widens `R13-01` 36→current for the round's two new
sections; the status section adds nothing to it).

### 6.3 The line moves `SCORECARD.md`'s stamp — and that is the real cost

`SCORECARD.md` is a stamped path (`corpus/stamps.tsv` line 3:
`SCORECARD.md f4eb6ec4… 1252 134670`). **Any** byte added to the scorecard
invalidates that stamp, and the stamp identity is pinned by `R24-05`
(`row-identity.sh stamps`, `count=99 sha256=59cdc390…`) and the membership
count by `R12-03` (`^99$`). Measured in the scratch clone at the reshaped BASE:
adding the status section produced
`STALE-POINTER SCORECARD.md sha=f4eb6ec481f1->bdb7c41cabcc lines=1252->1256 bytes=134670->134788`,
and `cells` then reads `CELL_AUDIT: BROKEN`/`POLICY` with `stale_pointers` non-zero.

This lands **inside the C1 migration set already frozen in the plan**: the
round-31 landing is *already* re-pinning the `SCORECARD.md` stamp (the C1
reshape changes those bytes too, and the plan's correction 1 already lists
`R24-05` and `R12-03` among the ten migrating rows). So the status line is
**nearly free** *if* it rides the same landing as the reshape and the same
`LC_ALL=C` full-set re-stamp the plan already mandates. It is **not** free if
landed later as a separate commit, because then a second SCORECARD stamp
re-pin and a second identity-row migration would be needed for a line that
changes often.

**This is the decisive cost argument, and it points the other way from "cheap
and safe".** A `lane-status:` line is meant to change *often* — every round
close, every operator ruling — while `SCORECARD.md`'s stamp, `R24-05`'s digest
and `R24-06`'s heading digest are all *identity* pins that a status line
mutates on every such change. Landing it inside the C1 landing costs one
migration; landing it in a later round costs a fresh stamp re-pin + identity
migration each time the status changes, and each of those is a `claim-ledger.sh`
row edit — the same bookkeeping churn the plan's correction 1 is already
managing once.

### 6.4 The `considerthese` mining shape and the lesson snippet

The plan's frontier step says the mined proposal "lands as a lesson snippet or
QUALITY.md criterion citing `considerthese/<file>` + date". The proposed lesson
snippet for `corpus/lessons/round-31.md` (the L1 to land; this seat does not
write lane files):

> **§Considerthese — proposal 2, machine-readable lane status**
> Source: `considerthese/2026-10-26.md` §"Self-improvement suggestions" proposal 2
> (Grok Bot, 2026-10-26), mined 2026-11-03. The proposal's premise is confirmed:
> the lane's dispatch state is reconstructed from prose across `LOG.md:1562-1570`
> and `SCORECARD.md:1164` and the fleet's `.tower/comms/inbox/…:37` HOLD row. The
> proposal's *example* is stale — the round-28 HOLD was lifted by the operator's
> run-15 directive ("No holds"; `.ufo/prompts/kagi-round-31.md` §6) and rounds 29
> and 30 were dispatched and ran (`MANIFEST.json` `rounds[].lanes.kagi` = `"ok"`),
> so the value lands as `open` with the 2026-10-21 refusal boundary still
> binding. "Open" is a *dispatch* fact: round 30's closure was
> `rejected-honest-stop`/`admitted: false` while its dispatch ran, so the two
> must never be conflated — hence the line's explicit scope field.
> Convention: one `lane-status:` line in `SCORECARD.md`, in a `## Lane status`
> section placed **before** the first `## Round` heading (a section after the
> last round section makes `cells` close that section and enforce its six-axis
> check — measured exit 2). Fields separated by em-dash ` — `, never `;`: the
> lane's claim-ledger policy refuses `;` and `|` in a claim row's command
> (`META_RE`), so a `;`-separated value is un-bindable by the lane's own ledger.
> The key is `lane-status:`, not `status:` — `Source-status:` (14 knowledge
> entries) and `self-counts.py`'s `OK`/`STALE` verdict already occupy that
> word. The line is a **lane-authored self-declaration, not a control**: nothing
> in `scripts/hokunin-watchdog.sh`, `scripts/hyaku/inline.sh` or
> `inline-dispatcher.py` reads `SCORECARD.md`, so the line cannot release a
> hold (it must not — the operator's holds live in the fleet root's
> `.ufo/l0-questions.md` and `MANIFEST.json`). Falsifier split: lane-locally, the
> line is one line, shape-valid and fleet-path-free (a fleet path would drag the
> lane's own `citations` gate to `INCOMPLETE`/exit 3 in a lone clone — measured;
> the watchdog log carries **no** hold vocabulary at all, so it cannot witness
> the state); cross-boundary, the state word is reconciled against the operator's
> records by the operator/closure judge, not by a lane gate. Recheck:
> `on-release` with a mandatory `as-of:` date, not a calendar interval — a
> calendar recheck would let a line claim "open" for months after a HOLD.
> Cost: the line mutates `SCORECARD.md`'s stamp, so it rides the C1 landing and
> the plan's `LC_ALL=C` re-stamp, and every later status change costs one stamp
> re-pin plus one identity-row migration.

### 6.5 A QUALITY.md criterion is the durable half

The plan's QM32 slot is already claimed by the M30-4 criterion (every red row of
a touched gate claimed or routed before the plan freezes). So the mined
proposal must not claim QM32. If the L1 wants the convention to survive beyond
this lesson, the durable form is a **new QM row** (QM33) stating the shape
rule — "a lane-status declaration is one line, in one file, with a mandatory
`as-of:` date and a closed state vocabulary; it is a self-declaration, never a
control" — plus the falsifier split. The lane's own QM vocabulary is the right
home for "what a status declaration may and may not claim"; the lesson is the
right home for this round's story. Recommended: land the lesson snippet now, and
propose QM33 as a separate, later criterion so it does not contend with the
frozen QM32.

## 7. Honesty ledger — what is verified, what is proposed, what is not run

**Verified by execution on this host (read-only on the lane; all mutations in
`/fast/scratch/hyaku/kagi-r31/ConsiderStatus/`):**

- proposal 2 unimplemented: receipt A–H above (lane tip `91f7752`).
- `cells` parser behaviour for `## Lane status` vs `## Round 31 status` vs a
  trailing status section: measured exit 2 / exit 2-with-six-axis-die / safe.
- `R13-01` count and `R24-06` digest unchanged by a `## Lane status` section.
- `SCORECARD.md` stamp goes stale on any added byte (`STALE-POINTER … lines=1252->1256`).
- ledger policy refuses `;` and `|` in a claim row's command, including inside
  quotes (`POLICY … reason=metachar`); the four proposed rows are policy-clean and
  pass (`failed=0 policy=0`), with `R31-S03` needing expected exit 1.
- `idref_audit` turns an unresolvable id on the status line into
  `MISSING-ID` + `CELL_AUDIT: BROKEN` exit 1.
- `MARK_RE` words on the line downgrade ids/paths to `LABELED`/`LABELED-ID`.
- the citations gate: `CLEAN cites=289` in fleet layout vs
  `INCOMPLETE … fleet_absent=1` exit 3 in a lone clone when the line cites a
  fleet path.
- the watchdog log carries no hold/block/frozen vocabulary on any `kagi` line
  (0 hits); its event vocabulary is launch/complete/lane-dead-no-report/
  lane-round-failed/wrap/steer/tick/launch-fail.
- the operator's current state: run-15 "No holds" (verbatim); `MANIFEST.json`
  `rounds[].lanes.kagi` `"ok"` for rounds 29/30 (and the round-level
  `verdict`/`admitted` pair distinct from it: round 29 `admitted`, round 30
  `rejected-honest-stop`); `.ufo/l0-questions.md` 6 open
  `kagi |` lines; round-28 HOLD row at `.tower/comms/inbox/…:37`.
- the round-29 §C1 closure of the D1 fail-open (proposal 3's premise) — see §8.

**NOT run, and stated as not run:**

- **No lane file was modified.** `corpus/lessons/round-31.md` does not exist yet
  and this seat did not create it; the §6.4 snippet is a proposal for the L1.
- The four `R31-S0x` rows are **proposed ids**; no row was added to
  `corpus/claim-ledger.tsv`. They were exercised in a scratch fixture only.
- `grep -rnE 'SCORECARD'` over the fleet `scripts/` was read, not executed; the
  claim "no driver reads SCORECARD.md" rests on that read plus
  `inline.sh`/`inline-dispatcher.py` reading only `.ufo/state/` and git state.
- The full `claim-ledger.sh verify` over the live lane was **not** run to
  completion on the live tree (>300 s in the clone; the round-29 lesson M29-3
  records the same cost). The live-lane citations run I did execute is the
  15.8 s `citations` mode over the real `SCORECARD.md` and a status-line copy.
- `op` was never contacted; no credential, vault, account, handler or CDP
  surface was touched. `op --version`-level read: **not performed** (nothing in
  this item needed it, so it was not done).
- No network fetch was made. No pacman transaction; no tool installed or
  upgraded.

**Where the draft could be wrong, and how to check it cheaply:**

- The `## Lane status` heading could collide with a future `cells` parser
  change. Cheap check: `grep -n 'SECTION_RE=' corpus/claim-ledger.sh` and confirm
  the section regex still admits non-round headings.
- The `open|held` vocabulary is a proposal. If the operator wants a third state
  (e.g. `refused-boundary`), the vocabulary row must be widened *before* the
  state is used, or `R31-S02` will read FAIL on a legitimate state — a false
  red, which is worse than a missing row.
- The `as-of:` date is a **lane assertion**. If the operator's L0 line for
  round-28's documentary disposition is answered with a hold, the line's value
  becomes false while its shape stays valid. Only the cross-boundary check
  catches that, which is why §3 splits the falsifier rather than pretending a
  lane gate can.

## 8. Staleness note on proposal 3 (recorded, not mined)

Proposal 3 ("Mark known-defective instrument output … append a `KNOWN_DEFECT: D1`
qualifier to a `CLEAN` verdict") rests on the premise that *the D1 fail-open is
live*. Per the item, that premise was checked against
`corpus/lessons/round-29.md` §C1 and **it is stale**:

- Round-29 §C1 ("feed-token right boundary; routed D1 closure") applied the
  frozen round-28 recipe: the three feed extractors take the `STABLE_TOKEN_RE`
  right boundary `(?![A-Za-z0-9+-]|\.[0-9])` instead of `$`/`[ \t]*$`.
- The byte-level confirmation: at round-28's `5e84747`,
  `corpus/release-clock.py:781` was
  `STABLE_TITLE_RE = re.compile(r"^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)$")`
  (a `$` anchor — a period-suffixed title cannot match); at round-29's `fc65112`
  and at BASE `655e620` it is
  `corpus/release-clock.py:789`
  `STABLE_TITLE_RE = re.compile(r"^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]|\.[0-9])")`
  with the recipe comment at lines 781-783 and the shared
  `STABLE_TOKEN_RE` at line 345.
- Round-29's measured outcome (`corpus/lessons/round-29.md` §Measured outcome):
  "NF MISHANDLED 5/7 → **0/7**, CORRECT 2/7 → **7/7**", and the release-clock
  selftest at 116 cases.

So the fail-open proposal 3 wanted to label was closed at round 29; a
`KNOWN_DEFECT: D1` qualifier appended to a `CLEAN` verdict today would be
**false** — it would announce a defect that no longer exists. Proposal 3 is
therefore **not mined**, exactly as instructed. (Note the separate, still-open
item it should not be confused with: the round-28 L0 line 158 asks the operator
to rule on the C1 defect, and `R25-02`/`R29-01`/`R29-02` remain operator-routed
reds — but that is a *ruling* and a *policy registration* question, not a
live fail-open.)

## 9. Recommendation to the L1

1. **Land the lesson snippet (§6.4)** in `corpus/lessons/round-31.md`, citing
   `considerthese/2026-10-26.md` + 2026-11-03. Zero coupling, and it is what
   the plan's frontier step actually asks for.
2. **Land the `lane-status:` line and its four binding rows in the SAME landing
   as the C1 heading reshape and the plan's `LC_ALL=C` full-set re-stamp**, if
   the L1 wants the mechanism rather than only the record. The stamp re-pin is
   already being paid for by C1; the status line then costs one identity-row
   migration, not a new machinery. **If the L1 prefers a separate landing, do not
   land it: a status line that changes every round would force a
   `SCORECARD.md` stamp re-pin plus an `R24-05`/`R24-06` migration on every
   status change.** That is the one recommendation I would press.
3. **Do not claim QM32** (frozen for M30-4). Propose **QM33** separately for the
   shape rule if the convention is to outlive this lesson.
4. **Do not land the proposal as filed.** Its example value (`frozen since
   2026-10-25`) is stale, its key (`status:`) is already overloaded twice in
   this lane, and its separator (`;`) is un-bindable by the lane's own ledger
   policy. The draft fixes all three.
5. **Keep the falsifier split.** The lane binds shape and count; the operator
   binds truth. A lane gate that tried to read the fleet's hold record would
   have to reach outside the lane and would read `FLEET-ABSENT` in a lone clone
   (measured) — QM22 says that is a typed INCOMPLETE, not a CLEAN, and that is
   the correct behaviour, not a defect to fix.
