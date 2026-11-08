# R67Reviewer — C1 wording and reachability falsification (round 67, w1)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch master), BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179`, frozen plan `plans/round-67.md` @
`aa8807e443166f45485e1aada2989f646efc707c` (C1 at lines 33–69; L1's later
Amendment A1 is C2-scope). Reviewed 2026-11-08T11:09Z. Read before working:
`plans/round-67.md` §C1, `corpus/lessons/round-66-verifier-spotcheck.md` §6
(item 8 = S115 `count=0`), `corpus/lessons/round-66.md` M66-10/11/13,
`corpus/QUALITY.md` QM89–QM94.

Leaf seat: no subagents, no lane edits, no commits, no `git add`/`stash`.
Scratch `/fast/scratch/hyaku/kagi-r67/R67Reviewer/` was removed after the
receipts were copied here. Receipts:
`.ufo/waves/round-67/w1/R67Reviewer/receipts/` (A1–A5 files; every number below
is reproducible from one of them).

Method. BASE bytes from `git archive 076701a` (corpus + the capture dirs the 36
rows name; BASE gate `e9ae2620ff4ad8e3…`). Candidate gate
`corpus/sources-census.sh` sha256 `46de3d8c115ee121…` and counter
`plans/round-67-c1.sh` sha256 `67fb72e5b7518b6e…`, both as they stood at run
time (mtimes 07:59 and 07:55; the TSV's one-line S115 col-13 re-cut is applied,
mtime 08:01). The gate changed under this review (observed shas `232fd18…`,
`2bddc9c5…`, `4247468a…`, `46de3d8c…`); fixture receipts pin the revision
they used and A5-counter-* is the final-revision run. C2 is outside this seat's
scope and is not judged.

## Counter runs (the landed instrument, read by this seat)

| run | tree | verdict | rc | receipt |
|---|---|---|---|---|
| candidate | lane worktree | `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` | 0 | `A5-counter-lane.txt` |
| do-nothing control | BASE `076701a` extract | `C1_READTHROUGH: bound=36 located=35 caught=0/6 guard=0` | 1 | `A5-counter-base.txt` |
| identity-swap candidate | scratch shadow lane, S115→S116 triplet | `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` | 0 | `A5-counter-identity-swap.txt` |
| counter selftest | — | `C1_READTHROUGH_SELFTEST: PASS (32 cases)` | 0 | `A5-counter-selftest.txt` |

The candidate reading is honest: the lane's S115 quote is really re-cut and the
gate/counter agree row by row. The third row is the finding: the same predicate
also passes a tree whose S115 row certifies S116's body and quote, with S115's
own repair absent (see S2).

## Findings by severity

| id | severity | finding | attack | amendment |
|---|---|---|---|---|
| S1 | **blocking (record)** | The landed gate and counter classify an **absolute** location as capture-intent (gate header "always a violation"; `cap_is_shaped`; counter `capture_shaped`), but the frozen plan defines capture-path-shaped as `/` present **and** `^[A-Za-z0-9._][A-Za-z0-9._/-]*$` only. Under the plan's text the "absolute location" mutation is classified prose and never read (strict measure: `path_rows=35 prose=121`, no finding, receipt A2-absolute-strict-vs-built), so `caught=6/6` would be unreachable; the landed instruments reach it only by behaviour the plan does not state. The candidate's own numbers are identical under both definitions (no absolute rows on the clean tree), so this is an authorization/record defect, not a wrong number. | A1+A2 | A-67-1 |
| S2 | **blocking** | Population **identity** is unbound. Swapping S115's col 10/11/13/14/15/16 to S116's values on a scratch replica of the candidate (same gate, wrapper and conf; no fleet file touched) reads the full frozen target: `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1`, rc 0 — with S115's own quote repair absent (A5-counter-identity-swap). Every guard passes: (a) the gate and counter both derive 36/36/120, (b) selftest 88, (c) BASE gate CLEAN on the repointed copy, (d) wrapper `kagi ok` on the shadow registry, (e) prose clean. This is QM92's sibling-row copy one level up: the whole row moves coherently, so no in-row check can see it. | A3 | A-67-4 |
| S3 | medium (record) | The plan does not record what "the expected reason" is, that the mutated id must carry it, or that `defects` counts findings. The landed counter supplies all three (header `EXPECT` table; `leg_caught` requires the mutated id; truncate reads `defects=2`; selftest includes constant-CLEAN and constant-FAILED stub gates, A5-counter-selftest), so the immediate hole is closed by the instrument. Residual: the expected reasons for repoint/truncate are present only because this gate prints **both** content reasons; a conforming gate that checks size first and stops would be judged uncaught. | A4 | A-67-3 |
| S4 | high (record) | C1's sentence overclaims. 17 of the 120 prose locations contain `/` and three name a file or an offset the census never opens (S008 `README.rst at getsops/sops 453e7e6a`, S099 `.ufo/prompts/kagi-round-44.md §6 item 9, line 561 (byte offset 52924)`, S105 `rendered-text offset 120622`); and `located` is satisfied by a one-token quote — `a` locates **580** times in S115's body (A1-classification, A1-degenerate-quote). Amendment 59 requires the narrowing or an honest stop. | A1 | A-67-2 |
| S5 | low (record) | Guard (d) is venue-bound: the counter implements `kagi ok` only when the measured tree is a `kagi-shokunin` lane; a bare scratch root exits 2 (no `shokunin.conf`) and `--file` prints `file ok` (A2-guard-d). The counter's header states this; the plan text does not. | A2 | A-67-5 |
| S6 | low | `raw-literal-v1` as built is `grep -qF` while the interface says "literal substring" — equivalent for the five current single-line raw quotes, divergent for a quote containing a newline/NUL. Also, empty col 16 increments `prose` in the built gate while the existing SC_FETCH `location` check owns it (no current row has an empty location). | A1 | note only |

## Attack verdicts

### A1 — Wording width: **FALSIFIES**

Command/receipt: `A1-classification.txt`, `A1-degenerate-quote.txt`,
`A2-base-numbers.txt`, `A2-base-blindness.txt`.

- Population on the committed BASE TSV: 43 comment/section lines, **36**
  path-shaped, **120** prose (17 contain `/`), 0 empty locations, 0
  non-16-column non-comment lines. Exactly the plan's numbers.
- The 17 slash-prose rows are never read; three name a file/offset (S008, S099,
  S105 above). The plan's phrase "each declared capture" includes them; the
  gate does not.
- `located` is `count >= 1` only. On S115's body the one-character quote `a`
  gives `RENDERED_TEXT_V1_LOCATE: count=580`, rc 0; an empty quote is a SETUP
  (rc 2). A row re-cut to `a` reaches `located=36` while the "quote" carries no
  evidence. (The landed repair is a real 18-word quote, `count=1`,
  R67ExecQuoteFix.md — but that is the seat's choice, not the predicate.)
- BASE blindness confirms the read-through is new: the BASE gate prints
  `SOURCES_CENSUS: CLEAN` on (i) an identity-swapped TSV, (ii) an
  absolute-location TSV, and (iii) a corpus whose `.ufo` bodies are entirely
  absent (A2-base-blindness). It reads no capture bytes at all.

Verdict: the sentence "the census reads each declared capture's bytes and
quote" claims more than the gate enforces. Narrow it (A-67-2).

### A2 — Do-nothing reachability: **FALSIFIES** (split by field)

Command/receipt: `A5-counter-base.txt`, `A2-absolute-strict-vs-built.txt`,
`A2-base-blindness.txt`, `A5-counter-lane.txt`, `A5-counter-identity-swap.txt`,
`A2-guard-b-selftest.txt`, `A2-guard-d.txt`, `A2-gate-revision.txt`.

- `bound=36`: **already true on BASE** under the plan's definition; the landed
  counter on a BASE extract reads `bound=36 located=35 caught=0/6 guard=0`
  (A5-counter-base). The dispatch milestone's "bound 0→36" is true only in the
  *gate* sense (the BASE gate has no capture read; A2-base-blindness t3), never
  in the counter sense. A report or SCORECARD writing "bound 0→36" from the
  counter would contradict the plan's own BASE measurement (plan lines 36–40).
- `located=36`: reachable by TSV-only edits with zero gate work — quote `a`
  (A1-degenerate) or the identity reroute (A3-identity-swap) both read 36/36.
  On BASE it is 35, so this is one real unit of the round's work.
- `caught=6/6`: 0/6 on BASE (A5-counter-base). It is reachable on a candidate
  only because the gate prints `SC_CAPTURE` for an absolute location — a
  classifier clause the plan text omits (S1/A-67-1). With the strict text a
  perfect gate scores at most 5/6.
- `guard=1`: reachable on the candidate (A5-counter-lane) and on the
  identity-swap replica (A5-counter-identity-swap). (a) compares the gate's
  counts to the counter's independent derivation; (b) `PASS (88 cases)`;
  (c) BASE gate CLEAN on the repointed copy; (d) wrapper `kagi ok`;
  (e) prose clean. The counter's selftest replays the mutation logic against
  constant-CLEAN and constant-FAILED stub gates
  (`C1_READTHROUGH_SELFTEST: PASS (32 cases)`, A5-counter-selftest), so the
  "counter prints constants" cheat is refused at the instrument level.
- The do-nothing *reading* is the honest BASE line above: the measured move is
  `located 35→36, caught 0→6, guard 0→1`; `bound` is unchanged.

### A3 — Population derivation: **FALSIFIES**

Command/receipt: `A5-counter-identity-swap.txt`, `A3-identity-swap.txt`,
`A3-registry-binding.txt`, `A1-classification.txt`.

- No shrink is needed. Guard (a)'s literal `path_rows=36 … prose=120` and the
  counter's derivation block *count* changes (a dropped or added row moves
  both), but neither binds **which** 36 rows they are. A fixed-count identity
  reroute of S115 to S116's body/digest/size/quote/normalization reaches the
  full predicate on a scratch replica of the fleet (A5-counter-identity-swap)
  with S115's own quote still `count=0` in its own body.
- The registry is not a complete identity source: for the 36 rows, the id's
  `SOURCES.md` row text contains its col-16 path for **21/36** and its col-10
  digest for **31/36**; 5 rows have neither (S100–S102, S113, S114).
  `git show 076701a:corpus/source-fetches.tsv` is the only complete, derivable
  identity anchor.
- A cheating candidate could shrink another population only by leaving the
  class, which drops `path_rows` below 36 and fails guard (a). The reachable
  cheat is substitution at constant 36.

### A4 — The `caught` mapping: **FALSIFIES** as plan text; **closed by the counter** as instrument

Command/receipt: `A4-mutation-legs.txt`, `A5-counter-selftest.txt`,
`A5-counter-lane.txt`.

Measured on the built gate (one mutation per tree, receipt A4):

| leg | construction | built-gate output |
|---|---|---|
| repoint (same size) | S143 → round-64/S143.body (both 264946 B, different digest) | `capture-digest-mismatch`, defects=1 |
| repoint (different size) | S130 → S131.body | `capture-bytes-mismatch` + `capture-digest-mismatch`, defects=2 |
| repoint (identical body) | S130 → S135.body (`cmp` rc 0) | **CLEAN** — no defect exists |
| truncate-by-1 | S116.body minus last byte | bytes + digest, defects=2 |
| delete | S116.body removed | `capture-missing`, defects=1 |
| absolute | S115 col16 → absolute lane path | `capture-outside-root`, defects=1 |
| `..` | S115 col16 → `../../outside.body` | `capture-outside-root`, defects=1 |
| quote | S116 col13 → non-locating string | `quote-not-located`, defects=1 |

- The plan's six mutation names do not fix the expected reasons, the mutated
  id, or `defects`; the landed counter does (header `EXPECT`, `leg_caught`,
  `defects` = findings). That closes the immediate ambiguity for this
  candidate. What remains unrecorded in the plan is the dependence on the gate
  printing **both** content reasons for the repoint and truncate legs; a
  conforming gate that reports only the first failing check would be judged
  uncaught even though it caught the mutation.
- A natural repoint target (S130 → S135) is not a mutation at all: the bodies
  are byte-identical (`cmp` rc 0), so no correct gate can report it. The landed
  counter's target (S164 → round-64/S148.body, 39750 B vs 264946 B) is valid
  and exists in the lane.
- Sub-question "caught by a finding a correct gate also prints": **neutral**.
  Guard (a) requires the clean tree to be CLEAN, and the built gate emits no
  `SC_CAPTURE` there (A5-counter-lane). No clean-tree finding is available for
  a mutation to piggyback on.

## Proposed amendments (exact text for the L1; plan §Amendments)

The plan is frozen; these are proposed to the sole integration owner, not
applied by this seat. A-67-1, A-67-2 and A-67-4 are required for the landed
numbers to rest on the plan's own text; A-67-3 records the counter's mapping;
A-67-5 pins the guard (d) venue.

### A-67-1 (record — interface classifier)

Replace the frozen interface's shape sentence with:

> Capture-path-shaped location = column 16 of `corpus/source-fetches.tsv`
> contains `/` and either matches `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`
> (repo-relative) or matches `^/[A-Za-z0-9._][A-Za-z0-9._/-]*$` (absolute).
> An absolute location is always `capture-outside-root` and is counted in
> `path_rows`. Every capture-path-shaped row is read: a repo-relative location
> must resolve repo-relatively, realpath inside the tree, to a regular file;
> sha256 == column 10; size == column 11; a row bound by those checks must
> locate its col-13 quote count>=1 under the col-14 normalization. A defect
> prints `FINDING SC_CAPTURE id=<S-id> <reason>`, reason in
> {capture-outside-root, capture-missing, capture-digest-mismatch,
> capture-bytes-mismatch, quote-not-located}. A row may print more than one
> reason when more than one check fails. Prose = every other non-empty col-16
> value (120 at BASE, 17 containing `/`); prose is counted and never checked.
> An empty col-16 value stays an SC_FETCH `location` defect and is outside the
> capture summary.

Why: the landed gate and counter already implement the absolute clause; the
frozen text does not, and under the frozen text the plan's own absolute-location
mutation is prose and never read (receipt A2-absolute-strict-vs-built), so
`caught=6/6` rests on behaviour the plan does not state.

### A-67-2 (Amendment 59 narrowing of the C1 sentence)

Replace the C1 heading and the sentence "the census reads each declared
capture's bytes and quote" with:

> C1 — freshness (capability): the census reads the bytes and the declared
> locator quote of every capture-path-shaped row (36 rows at this round).
>
> `bound`, `located`, `path_rows` and `prose` cover those rows only; the 120
> prose locations are counted and never opened; `located` means only that the
> declared locator occurs at least once under the row's declared normalization
> — quote length, provenance and evidentiary strength are not measured.

Why: 17 slash-bearing prose rows name files/offsets that are never opened
(S008, S099, S105), and a one-token quote `a` locates 580 times in S115's body
yet satisfies `located` (receipts A1-classification, A1-degenerate-quote).

### A-67-3 (record — `caught` construction and evidence)

Add under C1:

> The six legs and their expected reasons are the counter's `EXPECT` table and
> are part of this predicate: repoint → `capture-digest-mismatch` (target
> `.ufo/waves/round-64/capture/S148.body`, 39750 B, different digest and size
> from S164's 264946 B), truncate-by-1 → `capture-bytes-mismatch`, delete →
> `capture-missing`, absolute → `capture-outside-root`, `..` →
> `capture-outside-root`, quote → `quote-not-located`. `defects=N` on the
> `SOURCES_CAPTURES: FAILED` line counts FINDING SC_CAPTURE lines, not rows
> (truncate reads `defects=2`). A leg is caught only when the counter captured
> the candidate gate's own stdout for that copy and it carries the expected
> reason on the **mutated row's id**; findings for other ids do not count. The
> expected reason for repoint/truncate is present because this gate prints both
> content reasons; a gate that reports only the first failing check would not
> be caught on those legs. A repoint to a byte-identical body (S130 → S135,
> `cmp` rc 0) is not a mutation and cannot be a leg.

Why: the plan's mutation names were underdetermined (A4); the counter defines
them, and the plan should carry the definition so the number is falsifiable
without reading the counter.

### A-67-4 (blocking — population identity)

Add under C1's guard:

> Population identity: the 36-id set and each id's col-16/col-10 values are
> derived from `git -C <lane> show 076701a:corpus/source-fetches.tsv` (never a
> literal list). For `guard=1`, the candidate's capture-path-shaped id set must
> be exactly that 36-id set, and each id's col 16 and col 10 must be
> byte-identical to BASE. Any id entering or leaving the class, or any changed
> location/digest for those ids, is a defect.

Why: guard (a)'s constant counts do not bind row identity. The measured S115 →
S116 reroute reaches `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1`
with S115's own quote still `count=0` (receipt A5-counter-identity-swap) — the
frozen target is reachable while the required S115 repair is skipped, and
QM92's sibling-row-copy defect is still invisible. The registry cannot supply
the identity (21/36 paths, 31/36 digests; A3-registry-binding); the BASE blob
can.

### A-67-5 (record — guard (d) venue)

> Guard (d) runs the fleet wrapper as
> `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
> with the measured tree at the `kagi-shokunin` lane path. On a copy the
> wrapper exits 2 (no `shokunin.conf`) or prints `file ok` (`--file`), neither
> of which is the required `kagi ok`.

## Residual risk and verification gaps

- **The candidate is honest.** The lane reads the full target
  (`A5-counter-lane`); S2 is a reachability-of-shortcut finding, not evidence
  that the landed work is fake. The predicate would also accept the dishonest
  tree; A-67-4 closes that.
- **The gate and counter are uncommitted** (both `??` in the lane; the plan is
  modified only by L1's C2-scope Amendment A1). Re-run the counter on the final
  committed revisions and re-measure the `PROVINCE.md`/`SKILL.md` pins. The
  gate's `--selftest` reads `PASS (88 cases)` (`88 >= 84`) at review time; the
  plan should pin the final tally.
- **`located` quote strength** has no floor; the landed S115 re-cut is a real
  18-word quote with `count=1` (R67ExecQuoteFix.md), which is the right repair
  but is not enforced by the predicate. A-67-2 records the ceiling.
- **`raw-literal-v1` semantics**: gate uses `grep -qF`; the interface says
  "literal substring". Equivalent on today's five raw rows; a quote with a
  newline or NUL would diverge. Pin the comparison or record the ceiling.
- **Empty col 16** increments `prose` in the built gate while SC_FETCH owns the
  `location` defect; no current row exercises it.
- **The "0→36" milestone** is only true in the gate sense; the counter's BASE
  reading is `bound=36 located=35`. The round report/SCORECARD must state which
  reading it uses (A5-counter-base, A2-base-blindness).
- The shadow-fleet identity run used scratch copies of
  `scripts/sources-census.sh` and `shokunin.conf` (its `SHOKUNIN_ROOT` rewritten
  to the scratch root); no fleet or lane file was modified.
- C2 was not reviewed by this seat; no verdict is offered.

## Receipts

`.ufo/waves/round-67/w1/R67Reviewer/receipts/`

| file | content |
|---|---|
| `A1-classification.txt` | BASE population: 43 comment lines, 36 path-shaped, 120 prose (17 slash-prose listed), 0 empty |
| `A1-degenerate-quote.txt` | `locate S115.body 'a'` ⇒ count=580; empty quote ⇒ SETUP rc 2; S115 col13=`a` ⇒ 36/36 |
| `A2-base-numbers.txt` | committed BASE TSV: bound=36, located=35, S115 `count=0` |
| `A2-base-blindness.txt` | BASE gate CLEAN on swap, absolute, and all-bodies-absent trees |
| `A2-absolute-strict-vs-built.txt` | strict classifier 35/121 vs built classifier 36/35 + `capture-outside-root` |
| `A2-guard-a-reachable.txt` | S115 re-cut ⇒ exact frozen CLEAN line, rc 0 |
| `A2-guard-b-selftest.txt` | BASE 78 cases; latest gate PASS (88 cases) |
| `A2-guard-d.txt` | wrapper `kagi ok` on the lane; rc 2 on a bare scratch root; `file ok` via `--file` |
| `A2-gate-revision.txt` | gate revisions and the per-fixture latest-revision confirmation |
| `A3-identity-swap.txt` | S115→S116 reroute ⇒ 36/36 and gate CLEAN |
| `A3-registry-binding.txt` | col16 in registry 21/36; col10 31/36 |
| `A4-mutation-legs.txt` | all eight mutation constructions and their gate output; identical-body `cmp` |
| `A5-counter-lane.txt` | counter on the lane ⇒ `bound=36 located=36 caught=6/6 guard=1`, rc 0 |
| `A5-counter-base.txt` | counter on a BASE extract ⇒ `bound=36 located=35 caught=0/6 guard=0`, rc 1 |
| `A5-counter-identity-swap.txt` | counter on the shadow lane with the S115→S116 reroute ⇒ the full frozen target, rc 0 |
| `A5-counter-selftest.txt` | `C1_READTHROUGH_SELFTEST: PASS (32 cases)`, including constant-CLEAN/FAILED stub gates |
| `measure.py` | the plan-definition counter used for the A1/A3/A4 counts (`python3 measure.py <tsv>`) |
| `anchors.txt` | HEAD, plan commit, C1 plan line numbers, working-tree status |
| `commands.txt` | commands and cwd for every receipt |

No lane file was edited, staged, or committed by this seat.

## Post-amendment verification (A2/A3 landed; instruments re-read)

The L1 filed A2.1–A2.6 and A3 after the findings above; the severity table is
the pre-amendment record. Status with the landed plan and the latest instruments
(counter `3aed2ac6…`, gate `e7aacecd…`, TSV 157 rows; both shas stable across
the runs in `A6-*`):

| finding | status | evidence |
|---|---|---|
| S1 | resolved by A2.1 (absolute shape legalized) | A2.1 text; the built gate emits `capture-outside-root` on the absolute mutation (A2-absolute-strict-vs-built) |
| S2 | resolved by A2.4; measured | identity-swap shadow: `guard-pop base_ids=36 missing=none extra=none changed=S115`, `pop=0`, `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=0`, rc 1 (A6-counter-identity-swap-amended) |
| S3 | resolved by A2.3 | counter `EXPECT`/`leg_caught`; A2.3 text |
| S4 | resolved by A2.2 | narrowed sentence; A2.2 text |
| S5 | resolved by A2.5 | A2.5 text |
| S6 | note only, unchanged | — |

Latest live reading (157 rows, S166 prose): `C1_READTHROUGH: bound=36
located=36 caught=6/6 guard=1`, rc 0; `guard a=1 b=1 c=1 d=1 e=1 f=1 pop=1`;
`guard-a … derived=…prose=121 gate_fields=match`; `guard-f … verdict=same`
(receipt A6-counter-live-157).

### S7 — S166 vs the C1-section literals (R67Revenger §4.1): real, dispositioned by A3

Confirmed on the live tree: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36
located=36 prose=121)` and `SOURCES_CENSUS: CLEAN (rows=157 …)`. The C1
section's literal guard (a) (`prose=120`) and guard (e) ("the 120
prose-location rows") are stale against the 157-row tree; S166's col16 is prose,
so no landing of an S166 fetch row satisfies the bare literal (a shaped S166
gives `path_rows=37` and breaks A2.4's exact-BASE-36 identity). A3.2 is the
disposition: guard (a) compares the gate's four counts to the candidate's
derivation, target line unchanged; the counter implements it (`guard-a …
prose=121 gate_fields=match`). Non-blocking after A3, but the round report must
cite A3 and never quote `prose=120` as the measured line; if the L1 wants
textual hygiene, the two stale literals should be updated in the C1 body.

### S8 — normalizer tamper (R67Revenger C4): closed at the counter, gate-level ceiling

The candidate's `corpus/rendered-text-v1.py` decides `located`; a tampered
normalizer makes every quote "locate". The counter's guard-f pins the candidate
normalizer to BASE (`guard-f candidate=14f6ca6a… base=14f6ca6a… verdict=same`,
live run; a tampered copy reads `verdict=DIFFERS` → f=0). The gate alone remains
vulnerable to a tree that ships a fake normalizer; the instrument of record
(counter) is not. Recommend the gate pin the normalizer digest in a later round.

### R67Revenger C0–C8 verdicts

| revenger finding | my verdict | disposition |
|---|---|---|
| C0 S166 outside the class | real; the round's own sourced row is not gate-read; A3.3 records it as a hand-verified ceiling | honest-stop ceiling after A2.2/A3; QM94 stays open for S166; shaping it is a round-68 capability move (A2.4 forbids extra ids) |
| C1 whitespace/CRLF escape | real gate-level survivor (lexical classifier); the counter refuses the count path (whole-file CRLF ⇒ derived `path_rows=0` ≠ population 36 ⇒ guard 0) but `SOURCES_CENSUS` alone reads CLEAN | record; later-round SC_FETCH CR / trim-shape finding |
| C2 hardlink to out-of-tree body | real durability ceiling, not a C1 predicate falsification (point-in-time binding; gate header names it) | record; optional `nlink==1` SC_FETCH check later |
| C3 col15 borrowed digest | real survivor but outside C1's frozen predicate (bytes+quote); it is a QM92 gap | record as QM92 ceiling; a later instrument can recompute col15 |
| C4 normalizer tamper | real; closed at the counter by guard-f (measured) | gate-level ceiling only |
| C5 one-token quote | real; A2.2 records it | ceiling, no predicate change |
| C6 undecodable body ⇒ whole-census SETUP | real boundary bug; SETUP never passes, but one row blocks the other 35 | recommend per-row `quote-not-located` (A2.1: the quote does not locate); low |
| C7 `stat -c %s` vs `sha256sum` on an in-tree symlink | real false positive: lstat size vs followed digest; a legitimate in-tree symlink is refused | fix `stat -Lc %s` (or `wc -c`) + a selftest case; low-medium |
| C8 NF=17 row absent from the summary | real; `SOURCES_CENSUS` is FAILED so no pass is reachable, but the summary alone misleads | add `rows=N` / `path_rows+prose==data_rows` invariant in the gate; low |

Instrument flux: counter `67fb72e5…` → `5d3725b0…` → `3aed2ac6…` and gate
`46de3d8c…` → `e7aacecd…` during the review; each receipt pins its run's shas.
Re-run on the final committed revisions.

Receipts added: `A6-counter-live-157.txt`,
`A6-counter-identity-swap-amended.txt`.
