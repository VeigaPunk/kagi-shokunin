# R66ScoutPreState — pre-state census at BASE d549ee6 (round 66, kagi)

Seat: `R66ScoutPreState` (scout; axes operability, calibration). Lane
`kagi-shokunin` (branch master). Claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8` (round-65 verifier spot-check tip).
Frozen plan `plans/round-66.md` (landed `ddcd46bb`), read with
`corpus/lessons/round-65.md` and
`corpus/lessons/round-65-verifier-spotcheck.md`.

Scope: independent pre-state census only. **Read-only on lane source.** The
only lane writes are this report and
`.ufo/waves/round-66/w1/R66ScoutPreState/census.md` (receipts first copied
there). Scratch `/fast/scratch/hyaku/kagi-r66/R66ScoutPreState`, `TMPDIR`
exported explicitly, removed on exit. No git/jj mutation, no commit, no push.

## Verdict summary

| # | Assigned check | Verdict | Confidence |
|---|---|---|---|
| 1 | Round-65 BASE census reproduced (155 rows, tier A=138 B=2 C=15; `sources-census` `kagi ok` rc 0) | **REPRODUCED**, and the lane's `corpus/` is byte-identical to BASE | high |
| 2 | Inherited leftover: `c1-base-counter.txt` working-tree modification reverted to committed blob | **CONFIRMED reverted** (worktree sha256 == committed blob, 484 B, 9 lines, closing line intact) | high |
| 3 | S148 carrier defect: `round-64/capture/S148.body` is an unrelated arXiv body; the S148 pin lives in `S143.body` | **CONFIRMED** — plus the root cause is a whole-directory handle offset, not a one-row anomaly | high |
| 4 | C1 carrier drift 0→1 | pre-state **drift=0** confirmed (no registry/fetch row binds the round-64 carrier by path) | high |
| 5 | C2 claims.json exact 0→1 | pre-state **exact=0** confirmed; `claims=59` reachable only with manifest rows **and** the SCORECARD section | high |
| 6 | C3 selfref failures 1→0 | pre-state **failures>=1** confirmed; but the literal rule over the whole registry already reads **failures>=2** at BASE | high |
| 7 | Root cause of the S148 defect | **not a one-row lapse**: the round-64 capture names are draft handles; only `S149.body` carries its own id's bytes (10 agree with the notes.md proposal table, 6 orphans) | high |
| 8 | Lane census gate (both claims' guard (d) key on it) | **red at BASE**: `SOURCES_CENSUS: FAILED (findings=4 rows=155)`, round-65 debt, not in the plan's population census | high |
| 9 | L1's concurrent amendments A1–A3 | my BASE measurements **corroborate** all three cited readings; A2 additionally **names a token the gate never emits** (`PASS` vs the gate's lowercase `pass`) — §5b | high |

## 1 — Round-65 BASE census: reproduced

Measured on a `git archive d549ee6` extraction (scratch), plan's own awk:

```
rows=155
    138 | A |      2 | B |     15 | C |
    135 | mined |  3 | queued | 17 | rejected |
malformed(NF!=13): 0   dup_ids: 0
```

`bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
⇒ `kagi ok /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`,
**rc=0**, 24 `W04` duplicate-URL warnings (pre-existing class, same count the
committed `.ufo/waves/round-66/base/census-start.txt` records).

The lane tree's `corpus/SOURCES.md`, `corpus/source-fetches.tsv` and
`corpus/volatile-shape.py` are **byte-identical** to BASE (sha256 verified),
so the working tree is a valid stand-in for BASE on every surface this census
reads. The only lane-tree deltas from BASE are `plans/round-66.md` (the plan
itself) and untracked round-66 wave artifacts.

**New finding (operability):** the plan's guard tokens key on the **lane**
script `corpus/sources-census.sh` (`SOURCES_CENSUS: …`), which is a *different
script* from the fleet `scripts/sources-census.sh` (`kagi ok`) the plan's
census command runs. The lane script at BASE reads:

```
SOURCES_CENSUS: FAILED (findings=4 rows=155)   exit 1
```

— 4 findings, all round-65 debt: `SC_FETCH id=S155/S156 missing-provenance`
(round 65 landed S155/S156 registry rows but **no** `source-fetches.tsv` rows
for them — `grep -c '^S15[56]' corpus/source-fetches.tsv` = 0, so the round-65
lesson's "`source-fetches.tsv` gains the two captures" is **not** true of the
committed tree) and `SC_BODY_CITE … id=S148/S156 unrecorded` (the knowledge
entry names S148/S156 in its body but records only S155 on its `source:` line).
Both C1 guard (d) and C3 guard (d) require the `SOURCES_CENSUS: CLEAN` token,
so **both claims' guard=1 is blocked on this repair**, which is not in the
plan's population census. It is pre-existing debt (the round-65 spot-check
§2(c) already names `CITATION_GATE`/`CLAIM_LEDGER` as un-re-run), not a
round-66 defect — but it is a hard precondition.

## 2 — Inherited leftover: confirmed reverted

`.ufo/waves/round-65/base/c1-base-counter.txt`:

- `git status --porcelain` for the path ⇒ **empty** (no working-tree modification).
- worktree sha256 `450e5462d6bea6ea04c6269cec6e5cfd596f7da6f35428effee3ac59dab6b1e9`
  == `git show d549ee6:…` sha256 — **identical**.
- blob id `3112a45ab404f7b68619ccbba27991161523056d` at `3248c15` == at `d549ee6`;
  484 B worktree == 484 B committed; 9 lines.
- last line: `C1_MATRIX: matrix=5 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)`
  — the single closure line the spot-check §2 expects, with **no** truncated
  `atrix=5` overwrite artefact and no intermediate stub line present.

The round-65 spot-check §1 defect 4 (a lane-side race artefact mid-dating the
commit) is therefore **resolved**: the working tree now carries the committed
blob verbatim. Routed defect 4 is closed on the evidence.

## 3 — S148 carrier defect: confirmed, with the root cause

Measured digests:

```
round-64/capture/S148.body  sha=fabc74c5…9f15   39750 B   <- arXiv 1909.02196 (QAOA)
round-64/capture/S143.body  sha=3b8d4e15…cba40  264946 B   <- the BioC/ConText deposit
S148 fetch row col10 pin    = 3b8d4e15…cba40
S148 registry anchor pin    = 3b8d4e15…cba40
volatile-shape.py PIN_SHA   = 3b8d4e15…cba40
volatile-shape.py DEFAULT_CAPTURE = .ufo/waves/round-64/capture/S143.body
```

The file named for S148 holds the arXiv QAOA page — whose owner row is **S152**
(the `rejected` tier-C row), verified by digest lookup, not by the filename.
`S148.body`'s head is `<!DOCTYPE html>… <title>[1909.02196] Effects of Quantum
Noise on Quantum Approximate Optimization Algorithm</title>`. The S148 pin lives
at `round-64/capture/S143.body`. Both halves of the assigned defect are
confirmed exactly as stated.

### Root cause the plan does not price (new)

This is **not** a single misnamed file. The round-64 seat numbered its
captures by its own **draft handle**, and the L1 renumbered the registry ids
before commit — `round-64/capture/notes.md` says so outright ("**Capture handle
≠ registry id** … the L1 owns the ids and may renumber") and ships a
handle→proposed-id table. Measured by digest, **only `S149.body` carries its
own id's bytes**; the other 15 round-64 handles are off by the seat's offset:

```
handle  own sha256   owning registry row   notes.md proposed id
S143    3b8d4e159a   S148                  S148        agree
S145    a31331daf8   S150                  S150        agree
S146    185130082d   S129                  (re-open)   n/a
S147    b0c7e0505c   S128                  (re-open)   n/a
S148    fabc74c534   S152                  S152        agree
S149    4b5a837439   S149                  S149        agree  <- only self-consistent
S150    f996c36df1   S154                  S154        agree
S151    0008280532   S147                  S147        agree
S152    6e6bffb065   (none)                S155        orphan
S153    63b7bfca87   S146                  S146        agree
S154    066f44388d   S145                  S145        agree
S155    2381b66ba0   (none)                —           orphan
S156    ccf6ac493d   S151                  S151        agree
S157    49dd5ac486   S153                  S153        agree
S158-63 (6 files)    (none)                S156-S160   orphan
```

10 of the 16 handle-bearing rows agree exactly with the notes.md proposal
table; 6 handles are orphans whose proposed ids S155-S160 were renumbered past
and never landed as rows. **The plan's three named bodies (S143/S156/S157) are
each bound to a different id than their own** (S148/S151/S153). Any counter
that resolves the carrier by *id* rather than by *the digest the row pins*
reads the wrong body for all three; the digest binding is the only correct
resolution path, and the plan's carrier repair (naming
`.ufo/waves/round-64/capture/S143.body`) is consistent with it. This is
evidence **for** the plan's repair shape, not against it — but it should be
priced, because the same offset silently affects S145-S157.

### Where the S148 pin is and is not cited at BASE

| surface | value at BASE | cites a round-64 path? |
|---|---|---|
| `SOURCES.md` S148 anchor cell | `§3.1.2 …` + sha256 `3b8d4e15…cba40` — pin only, no path | no |
| `source-fetches.tsv` S148 col 16 | `§3.1.2 Trigger Terms, …` — anchor prose, no path | no |
| `volatile-shape.py` `DEFAULT_CAPTURE` | `.ufo/waves/round-64/capture/S143.body` | yes |
| any `source-fetches.tsv` row citing a round-64 capture | **0 rows** | — |
| any registry row citing a round-64 capture | **0 rows** | — |

**Calibration hazard in the plan's own census command.** The plan §C3 census
says `grep -cF 'capture/S143.body' corpus/source-fetches.tsv` ⇒ 1 row (S143).
Measured: the single hit is `S143 … .ufo/waves/round-63/capture/S143.body`
(sha `8522a79e…` — the **S143** pin), i.e. the *round-63* file. The round-64
file that actually carries the S148 pin is cited by **no** fetch row and **no**
registry row. The grep hit is a same-basename coincidence across rounds: a
counter greping by basename can bind the round-63 body and miss the pin. The
plan's §C1 census file `.ufo/waves/round-66/base/census-c1.md` repeats the
same basename reading.

### The anchor-vs-path shape is the L1's uniform landing choice, not an S148 lapse

The round-64 seat's proposed fetch rows
(`.ufo/waves/round-64/build/R64ScribeRecords/sources-block.md`) give col 16 =
a capture path for **all ten** round-64 rows (S148 → `…/round-64/capture/
S143.body`). The landed `source-fetches.tsv` gives col 16 = anchor prose for
all ten (S148 → `§3.1.2 Trigger Terms, …`). So the plan's C1 repair — making
S148's col 16 name a path — reverses the L1's uniform round-64 landing
convention for one row, and any C3 counter must expect prose for S145-S157
and a path for the repaired row.

### Population the C1/C3 predicates rest on (measured)

- registry rows citing a capture path in the anchor cell: **21 rows / 22
  citations** (round-56:1, 57:3, 58:4, 59:2, 60:2, 61:3, 62:7; **round-64: 0**).
- `source-fetches.tsv` col 16 citing a capture path: **30 `.body` rows / 30
  unique paths** (+ 3 `.raw`, + 1 prompt-file cell) — **round-64: 0**.
- all 30 cited `.body` paths exist, and each one's sha256 == its row's col10
  pin with byte count == col 11. The "30 of 30 cited capture files exist" check
  the plan cites is TRUE at BASE — and it is true **without the round-64 family
  participating at all**, so it does not move when the S148 repair lands.

### Two anchor citations already fail a strict "cited path sha == row pin" rule at BASE

| row | cited path | sha | row pin | anchor carries that sha? |
|---|---|---|---|---|
| S113 | `round-56/capture/rejections/S113-default-ua.body` | `ce3cb7f2eb0e…` | `d8dfe35408b1…` | yes (the 403-rejection receipt, dual-attested) |
| S121 | `round-58/capture/S121.body` | `37e706c2b204…` | `d8879a2a4d78…` | **no** (the anchor names the round-59 file as the source and the round-58 file as "the rejected token-CLI page and not this source") |

So a C3 counter that reads "each registry anchor cell's cited carrier path
exists and its sha256 equals the row's pin" over the **whole registry** reads
**failures >= 2 at BASE regardless of the S148 repair** — `failures=0` is
unreachable unless the counter scopes to the round-64 family (as
`R66ExecC3SelfRef`'s counter does) or distinguishes the cited-source path from
a co-cited rejection receipt. `R66Reviewer` F7 names the S121 half; the
S113 dual-attestation case is the one it does not name.

## 4 — Live re-open (reported, never decisive)

`curl -A <desktop browser UA> --compressed …/BioC_xml/PMC2757457/unicode`
on 2026-11-08 ⇒ **HTTP 200**, 264946 B decoded, sha256 `3b8d4e15…cba40` —
byte-identical to the committed round-64 capture and to the S148 pin;
`<passage>` 182, `<text>` 180. `live_status=200`, `rate_limited=0` at this
moment. This does **not** reverse round 65's S156 rejection, which priced
*grounding* on the live carrier, not content.

## 5 — C2 pre-state

- `.ufo/waves/round-66/claims.json` (untracked, in the working tree) already
  carries titles `C1_CARRIER: …` / `C2_CLAIMS: …` / `C3_SELFREF: …` and the
  matching targets. The **frozen plan's** headings are `## C1 — freshness: …`,
  `## C2 — operability: …`, `## C3 — calibration: …` while its frozen
  predicate lines are `C1_CARRIER: …` / `C2_CLAIMS: …` / `C3_SELFREF: …`.
  claims.json uses the **predicate labels**, not the heading axes, so a counter
  comparing titles to heading text verbatim reads a mismatch and one comparing
  to the predicate labels reads a match. **The plan does not say which surface
  is authoritative** — this is the one place where the frozen C2 predicate is
  genuinely under-determined, and the C2 executor's counter resolved it by
  deriving from the predicate label and documenting the derivation. The L1
  should record that resolution as an amendment rather than leave it implicit.
- `corpus/claims-declared.tsv` at BASE has 56 data rows and **no round-66
  rows**; `SCORECARD.md` has **no `## Round 66 — post-move` section**.
  `bash corpus/claims-declared.sh` at BASE reads `CLAIMS_DECLARED: CLEAN
  (claims=56)` — clean *because* round 66 is absent. Simulated on a tree copy:
  adding the 3 round-66 manifest rows **alone** reads `MISMATCH 66 C1
  section-missing` (×3) ⇒ `CLAIMS_DECLARED: MISMATCH (claims=59 mismatch=3)`;
  adding the manifest rows **and** the SCORECARD section reads
  `CLAIMS_DECLARED: CLEAN (claims=59)` exit 0. So the plan's `claims=59` is
  reachable, but **only with both surfaces at once**, and the manifest rows
  alone are a MISMATCH — a sequencing hazard for the L1's landing order.
- `python3 scripts/hyaku/prefile-falsification.py --lane kagi --round 66`
  ⇒ `PREFILE-FALSIFICATION: SETUP findings=3` (exit 2): wave-missing
  (`kagi-r66-w1-results.json`), ledger-missing
  (`.ufo/waves/round-66/claim-falsification.tsv`), report-missing
  (`/home/vgpnk/Projects/shokunin/.ufo/reports/round-66/kagi.md`). The script
  prints `PREFILE-FALSIFICATION: pass` only when all four inputs exist and no
  rule fails, so C2 guard (c) is unreachable at present by construction
  (`R66Reviewer` F5 names the same).

## 5b — Reconciliation with the L1's concurrent amendments (A1–A3)

Observed mid-seat: `plans/round-66.md` is modified in the working tree
(`git status` ⇒ ` M plans/round-66.md`, 119 added lines) with three appended
amendments — A1 (C1: the undefined "header-ID digest" term goes), A2 (C2:
re-frozen as a pre-file gate), A3 (C3: re-frozen on the lane's own census
gate) — all dated 2026-11-08 and stated as "before any candidate reading".
My census read the **committed** freeze (`ddcd46bb`) and measured BASE
`d549ee6`; amendments are appended, not rewritten, so my measurements stand.
Where they corroborate me I say so; where they sharpen or miss something I
say that too.

**Corroborated (independently re-derived by me):**

- A1 and A3 both cite `bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS:
  FAILED (findings=4 rows=155)`. My §1/§K measured exactly that at the BASE
  tree and at the live tree, with the same four finding ids. A3 re-freezes C3
  on this gate with "BASE 4, measured" — my census reproduces the 4
  independently.
- A1's `git cat-file -e d549ee6:.ufo/waves/round-66/claims.json` ⇒ absent:
  confirmed; the BASE tree holds waves round-22…round-65 only.
- A2's `claims-declared.sh` ⇒ `CLEAN (claims=56)` and `guard-c prefile=0
  rc=2`: confirmed exactly (§5) — the gate reads `CLAIMS_DECLARED: CLEAN
  (claims=56)` at BASE (clean *because* round 66 is absent), and
  `prefile-falsification.py` returns **2** on SETUP.
- A2's "claims.json already carries the frozen headings and targets": my §5
  reaches a **sharper** statement — the claims.json titles are the frozen
  **predicate labels** (`C1_CARRIER:` / `C2_CLAIMS:` / `C3_SELFREF:`), while
  the plan's **headings** are `## C1 — freshness: …` / `## C2 — operability: …`
  / `## C3 — calibration: …`. The two surfaces are not byte-equal, so
  "already carries the frozen headings" holds only under the predicate-label
  reading. A2's re-freeze of C2 as a pre-file gate dissolves the ambiguity,
  but the label-shaped claims.json stays on disk and the L1 should note the
  resolution rather than leave it implicit.
- A2 does **not** name the ordering hazard I measured (§5): the 3 round-66
  manifest rows **alone** read `MISMATCH 66 C1 section-missing` (×3) ⇒
  `CLAIMS_DECLARED: MISMATCH (claims=59 mismatch=3)` exit 1. Only manifest
  rows **plus** a `## Round 66 — post-move` SCORECARD section read
  `CLEAN (claims=59)` exit 0. The L1's landing order must add both surfaces
  together or A2's second conjunct is a MISMATCH, not a CLEAN.

**New — not priced by A1–A3: the A2 frozen predicate names a token the gate
never emits (token case).**

A2 requires the gate to print `PREFILE-FALSIFICATION: PASS claims=3 rows=R
attack_seats=K findings=0` — uppercase `PASS`. The gate emits **lowercase**:
`scripts/hyaku/prefile-falsification.py:231` is `status = "pass" if not
findings else "FAIL"`, printed as `PREFILE-FALSIFICATION: %s claims=%d rows=%d
attack_seats=%d findings=%d`. Measured: no uppercase `PASS` is emitted
anywhere in that script; the success token is `PREFILE-FALSIFICATION: pass`.
A literal reader of the frozen A2 sentence therefore cannot observe the target
it names, while the in-flight counter's regex
`re.search(r"PREFILE-FALSIFICATION:\s*pass\b", out, re.I)` is **case-insensitive**
and would accept the lowercase form — so a case-sensitive checker built to the
A2 sentence reads a miss on a fully passing tree.

This is the same class as the round-65 routed defect 3 (`CITATION_GATE` /
`CLAIM_LEDGER` not re-run — a gate read against a token that was never
re-measured) and as the round-65 self-description defect A3 guard (d) itself
names ("census ok" was the fleet wrapper while the lane gate was red). Cheap
fix for the L1: amend the A2 literal to the lowercase `pass` the gate
actually prints, or amend the gate to print `PASS` — but do not leave the
frozen predicate naming a token the tool never emits.

**Also unpriced by A2: the ledger's real shape requirement.** The gate's rules
(`scripts/hyaku/prefile-falsification.py:214-220`) require one ledger row per
claim id (`claim-uncovered`) **and** one referenced artifact per wave attack
seat (`attack-seat-unread`), where the seat set comes from `attack_seats()`
over `kagi-r66-w1-results.json` filtered by `ATTACK_ROLES`. The wave spec
declares 5 attack seats (reviewer, critic, mutation-tester ×2, sentinel), so
`K >= 1` is satisfied but the ledger must reference **each** seat's artifact
by name or the gate reads `attack-seat-unread`. A2's `rows=R` with `R >= 3` is
the floor; the real requirement is one row per claim **plus** one per attack
seat.

**Note on A3's re-freeze.** A3 re-freezes C3 on the lane gate's findings count
with "BASE 4". That is the right move given the frozen §C3's hard-coded
`checks=3` over a 21-row population, and my §3 independently measured that
population (21 registry rows / 22 citations; 30 fetch-side `.body` paths; 0 in
the round-64 family). My §3's additional finding — that **two** registry rows
(S113, S121) already fail a strict "cited path sha == row pin" rule at BASE —
matters to any counter that still binds anchors rather than reading the lane
gate's count.

## 6 — What I did not do / gaps

- No candidate work, no counter of my own, no mutation battery: scout scope.
- I did **not** attempt the round-66 frontier step (opening new sources) — the
  plan assigns that to the L1's `Frontier step` and the `R66ScoutSources`
  seat; a pre-state census seat re-opening sources would double-spend the
  round's frontier budget and risk two seats fetching the same URL.
- The `SOURCES_CENSUS: CLEAN` repair (4 round-65 findings) is **not** in any
  round-66 claim's scope as frozen, yet both C1 and C3 guard (d) depend on it.
  I have measured it and its root cause but not repaired it; the repair touches
  `corpus/SOURCES.md`, `corpus/source-fetches.tsv` and the round-65 knowledge
  entry — L1/L2 work.
- The `.ufo/waves/round-66/capture/S148.body` copy already in the working tree
  (264946 B, sha `3b8d4e15…cba40`, byte-identical to the round-64 carrier) is
  a second binding of the same bytes; `R66Reviewer` F8 prices it. I confirm the
  bytes and that it is untracked, and note it makes "resolve by basename under
  the row's own round directory" an unsound resolution strategy for the
  counters.

## Reproduce

```
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive d549ee6 | tar -x -C <scratch>
cd <scratch>
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {n++} END{print n+0}' corpus/SOURCES.md   # 155
bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi  # kagi ok, rc 0
bash corpus/sources-census.sh            # SOURCES_CENSUS: FAILED (findings=4 rows=155), exit 1
sha256sum .ufo/waves/round-64/capture/S148.body .ufo/waves/round-64/capture/S143.body
```

Full receipts, including every digest table: `.ufo/waves/round-66/w1/R66ScoutPreState/census.md`.

## Tooling

No installs. Host `bash`, `python3`, `awk`, `sha256sum`, `curl`, `git`
(read-only) only. No model alias hardcoded.

### Post-state observed at seat exit (L1 landed the repair concurrently)

- lane census: `SOURCES_CENSUS: CLEAN (rows=156 A=139 B=2 C=15 queued=3 mined=136 rejected=17 entries_sourced=25 legacy=21 captures=156 inrow=16 inrow_only=0 inrow_nonreproducing=12)` — the §K guard-(d) precondition (findings 4 -> 0) has been repaired by the L1, and the registry is 156 rows (the superseding row).
- The §5 ordering hazard is **still live**: `corpus/claims-declared.tsv` still holds **0** round-66 rows and `SCORECARD.md` still has no `## Round 66 — post-move` section, so A2 second conjunct (`CLAIMS_DECLARED: CLEAN (claims=59)`) is not yet reached.
- `corpus/source-fetches.tsv` rows citing a round-64 capture: still 0 at seat exit (the col-16 path binding the L1 lands per A1 sits on the superseding row, pending).
- My census measured the BASE tree (`git archive d549ee6`), which no concurrent landing changes; every BASE number in this report stands.

Report: .ufo/waves/round-66/w1/R66ScoutPreState.md

### Closure — priced into Amendment A4

The L1 appended **Amendment A4** (`plans/round-66.md:415`), naming this seat as
the measuring seat, which adopts all four findings: A2's token corrected to
the lowercase `pass` the gate actually prints; the `claims=59` ordering hazard
named with "both land in the same commit"; §C3's basename-census paragraph
superseded (with the exact digests I measured); and the round-64 col-16 prose
convention recorded as a deliberate, visible departure on S164. My §K lane-census
finding is now C3's measured target (BASE `findings=4` -> candidate `findings=0`,
the four ids I reproduced are exactly the four the repair closes). The 12
borrowed-identity round-64 handles are routed to round 67 as a checked class.
Detail: `.ufo/waves/round-66/w1/R66ScoutPreState/census.md` §P.

Report: .ufo/waves/round-66/w1/R66ScoutPreState.md
