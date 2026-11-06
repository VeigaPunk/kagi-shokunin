# K48CriticClaims — round-48 claims falsification (attack leg)

Seat: critic. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Measured at BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c` (claim tip) with the frozen
instruments at predeclaration `164f0ea5` + amendment A1 `52991e5d`. Scratch
`/fast/scratch/hyaku/kagi-r48/K48CriticClaims/` (removed is not required; every fixture is
throwaway). Binaries on PATH-visible `~/.local/bin` verified at their pinned digests
(`sops e5bec334…7fef6b`, `age-keygen 0a0009db…37899`). The candidate is not landed at
measurement time, so every attack below is on the **frozen instruments and the frozen plan**,
not on candidate bytes.

Receipts in `.ufo/waves/round-48/build/K48CriticClaims/` (one file per counter line quoted below;
the two forged trial scripts and the fabricated entry tail are kept there verbatim).

Nothing here edits the plan, the counters, the controls, SCORECARD.md or any registry row.

---

## 0. Do-nothing leg, re-measured (non-author)

| # | command | observed | rc |
|---|---|---|---|
| N-1 | `bash plans/round-48-c1.sh 76da518fcc…` | `C1_SOPS_AGE_TRIAL: value=0 absent=1 pins=1` | 0 |
| N-2 | `bash plans/round-48-c2.sh 76da518fcc…` | `C2_CAPABILITY_READINGS: value=3 keys=10 rev=76da518…` — K02 `located=5 rows=5` vs `located=8 rows=8`; K07 `claims=2` vs `claims=21`; K10 `PASS (8 cases)` vs `PASS (12 cases)` | 0 |

Both BASE readings reproduce the plan's declared BASE. `c2-base-remeasure.txt`.

---

## 1. Verdict table (D-1 … D-13)

| id | claim | dimension | verdict | basis (counter line) |
|---|---|---|---|---|
| D-1 | C1 | axis fit (operability) | **holds** | The landing set is a runnable artifact that answers with a verdict; a capability acquisition is a legal claim form (`AXES.md` §Capabilities) and the nudge is correctly read (D-5). Caveat in D-13. |
| D-2 | C1 | do-nothing control | **holds** | `C1_SOPS_AGE_TRIAL: value=0 absent=1` at BASE; controls `K1-0` 0 (`controls-prefreeze.txt`). |
| D-3 | C1 | forgery resistance | **weakened — named ceiling verified *sufficient*** | Four forgeries read 5 (§2.1): PATH sniff `value=5`, shim-byte sniff `value=5`, fabricated entry `value=5`, both legs forged `value=5`. The counter measures "a script that answers differently when handed the falsifier", not "the mechanics ran". |
| D-4 | C1 | separability | **holds (measured, not just argued)** | C2 at a commit holding only the C1 change → `value=3` (§3 S1); C1 on a tree holding only the C2 change → `value=0 absent=1` (S2); both landed → 5 and 0 (S3). |
| D-5 | C1 | stagnation-nudge reading | **holds** | All six axes 9 (round-47 post-move table); `SCORECARD.md` §Saturation line 9, N = 3; `SCORECARD.md:714` "latest first-working round in this table is 40"; rounds 41–47 = 7 completed rounds with no capability → the nudge fires and the lowest-axis obligation is waived. |
| D-6 | C1 | claim sentence ("the lane executes … mechanics") | **weakened** | `value=5` is a proxy for the sentence; only a reading of the committed script distinguishes the reference shape from §2.1. The plan names this as a ceiling and makes the reviewer leg load-bearing — that leg is not optional. |
| D-7 | C2 | axis fit (calibration) | **holds, thin** | One added current-readings line moves a self-description defect. True to the axis; the increment is one line and one revision-bound number. |
| D-8 | C2 | do-nothing control | **holds** | `value=3` at BASE; controls `K2-0` 3 (reproduced, N-2). |
| D-9 | C2 | forgery resistance | **falsified at the claim's sentence** | Three shapes read `value=0` while the table still states the old readings: duplicate `## Capabilities` section (`value=0`), fenced `## Capabilities` heading (`value=0`), HTML comment inside the section (`value=0`). §2.2. |
| D-10 | C2 | separability | **holds** | Same three measurements as D-4. |
| D-11 | C2 | stagnation-nudge reading | **holds** | C2 works calibration (owned, tied-lowest); no waiver claimed for it. |
| D-12 | C2 | durability of 3 → 0 | **weakened** | K07 is revision-bound: measured `claims=23` at a candidate-shaped revision, `claims=25` one round later with the SCORECARD untouched → `value=1` (`c2-decay.txt`). The named ceiling is real; the 0 decays without a defect. |
| D-13 | both | axis harm | **one open item** | C1 lands a `## Measured` section in an entry whose line 9–10 still says "Nothing here was executed on this host; every mechanism is documented, not measured", and whose `verified-at: 2026-10-19` predates the measured content; the C1 kill rule (no `-` line in the entry) forbids the direct repair. §4. No axis score moves; this is content staleness the counters cannot see. |

Population check (closes the "cherry-picked keys" attack): the `## Capabilities` section at BASE
holds **10 parseable `cmd` ⇒ `out` pairs and they are exactly K01–K10**. One further `⇒`
(`corpus/feed-token-agree.py --instrument <BASE tree>` ⇒ `DISAGREE naming trailing-period`) is
outside the pair grammar and is not measured. `SCORECARD.md:712`'s prose reading "8 cases each" is
**not** a pair and is false at BASE (claims-declared executes 12 cases, K10) — see §2.3.

---

## 2. Counterexamples (each with the counter line)

Setup for every C1 case: `git -C <lane> archive 76da518fcc… | tar -x -C <tree>`, then the fixture,
then `bash plans/round-48-c1.sh --tree <tree>`.

### 2.1 C1 — four forgeries the frozen controls do not cover

Control coverage first: `K1-F1` (constant `HOLDS`, no `BROKEN` at all) = 0 and `K1-F2` (reference
trial with the real `~/.local/bin` prepended, i.e. the shims **bypassed**) = 0. The uncovered gap is
the middle case: **do not bypass the falsifier, inspect it**. All four read 5 with *zero* SOPS
execution where noted.

| id | forgery | counter line | rc |
|---|---|---|---|
| F-C1-a | trial prints `HOLDS` unless `$PATH` matches `*/bin/sh<N>:*`, then prints `BROKEN` for that T; never runs `sops` (`forge-c1-path-sniff.sh`) | `C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 …` | 0 |
| F-C1-b | same, keyed on the **bytes** of the `sops` on PATH (`grep` for `rotate -i`, `= rotate ] && exit 0`, `STASH/last`, `collapsed.yaml`); never runs it (`forge-c1-byte-sniff.sh`) | `… value=5 …` | 0 |
| F-C1-c | the **reference** trial + an entry section of fabricated bullets (`- T1 updatekeys-add: not measured, sops 3.13.3.` ×5) | `… value=5 …` | 0 |
| F-C1-d | F-C1-a **and** the fabricated entry — nothing executed, nothing measured | `C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 …` (`c1-fab.txt`) | 0 |

Reading of the three conjuncts against F-C1-d: `PINS=1` (unpinned binaries never touched),
`SETUP_OK=1` (`command -v sops` fails under `bin/none` → exit 2, no `HOLDS` lines), `NOSECRET=1`
(nothing generated). The entry conjunct is satisfied by a version string:
`entry_line()` requires only a line starting `- T<n> ` that contains `sops 3.13.3`.

F-C1-a and F-C1-b are **exactly** the ceiling the plan names ("a trial that detects the counter's
shims (e.g. by reading its own PATH or the shim bytes) and answers BROKEN only under them passes"),
so they confirm the ceiling rather than discover one: it is reachable, it is cheap (≈20 lines), and
it reaches the full target. F-C1-c/d are a second, unnamed weakness of the same landing: the
documentation conjunct is a substring check.

### 2.2 C2 — three forgeries reach 0 with the table untouched

Fixture: `git clone --shared <lane> $S/c2repo`, `--detach 76da518fcc…`, assert
`rev-parse --show-toplevel` = `$S/c2repo`, copy the frozen counter into
`$S/c2repo/plans/round-48-c2.sh.frozen` (the counter derives `LANE` from its own path), commit with
`-c user.name=fixture -c user.email=fixture@scratch.invalid`, run `bash <that copy> <commit>`.

| id | forgery | observed |
|---|---|---|
| F-C2-a | append **a second `## Capabilities` section at EOF** holding the three current pairs; the real table on line 696 keeps `located=5 rows=5`, `claims=2`, `PASS (8 cases)` | `C2_CAPABILITY_READINGS: value=0 keys=10 rev=135fd48b…` (`c2-fg1.txt`) |
| F-C2-b | append a fenced block whose first line is `## Capabilities` and whose body holds the three current pairs (the awk extractor is fence-blind) | `C2_CAPABILITY_READINGS: value=0 keys=10 rev=bc6bdf83…` (`c2-fg2.txt`) |
| F-C2-c | an **HTML comment** inside the real section holding the three current pairs — invisible in rendered Markdown | `C2_CAPABILITY_READINGS: value=0 keys=10 rev=ebc8e936…` (`c2-fg3.txt`) |

Lineage, not novelty: F-C2-b/F-C2-c are the exact defect class the lane already fixed in its own
gate — `corpus/claims-declared.sh` header, round-40 amendment **D2**: "the plan heading must match at
column 0 **outside fenced code blocks and HTML comments**". The round-48 C2 counter re-introduces the
class it fixed two rounds ago, and its `stated_of` reads the whole section text (last occurrence),
not a table cell.

Consequence for the claim sentence: the sentence is "the capabilities table's stated evidence
readings agree with the commands' executed output". F-C2-a/b/c leave the **table** stating three
readings the commands do not produce and still read 0. The predicate the plan froze is narrower than
the sentence it is labelled with; the predicate is honest to its own text, the sentence is not.

### 2.3 C2 — a surviving stale reading at `value=0`

`SCORECARD.md:712` (BASE), What-it-can-do cell: "…and that a constant-CLEAN mutant of the gate
diverges from the real gate, **8 cases each**". Executed at BASE: `anchor-pins.sh --selftest` = 8
cases (K09 MATCH), `claims-declared.sh --selftest` = **12** cases (K10 DIFF). The number is not a
`cmd` ⇒ `out` pair, so it is invisible to the counter; the intended fix adds a current-readings line
that states `PASS (12 cases)` three lines away, leaving the same section asserting "8 cases each".
No counter reaches it. (Population is otherwise clean: `sources-census.sh --selftest` really is 70
cases — the static `CASES=(…)` array holds 70 entries — so row 701's "70 cases" is current.)

### 2.4 C1 — the entry the landing makes self-contradictory

`corpus/knowledge/sops-age-key-rotation.md:9-10` (BASE):

```
Scope: the SOPS documentation as served on 2026-10-19. Nothing here was executed
on this host; every mechanism is documented, not measured.
```

C1 appends `## Measured (round 48 — sops 3.13.3 …)` and the frozen kill rule says the candidate
"removes or rewrites no pre-existing line" (`git diff BASE candidate -- <entry>` shows no `-` line).
Therefore the candidate lands an entry that says, in its scope paragraph, that nothing was executed,
and, 200 lines later, that five tests were executed. `verified-at: 2026-10-19` and `recheck:
on-release` are also pre-existing lines: they cannot be refreshed either, so the entry's freshness
header will predate its newest content. Neither counter reads the scope sentence. The repair is
append-only and cheap (§5.2).

### 2.5 C2 — the K07 number, measured

Same fixture shape as a candidate would have (`plans/round-48.md` from `164f0ea`, the two claim rows
`48 C1 operability` / `48 C2 calibration` appended to `corpus/claims-declared.tsv`, a `## Round 48 —
post-move` section with the two tagged rows):

| fixture | stated K07 | executed K07 | value |
|---|---|---|---|
| candidate shape, line written with the BASE number | `claims=21` | `claims=23` | `value=1` (`c2-fg3b.txt`) |
| candidate shape, line written with the candidate number | `claims=23` | `claims=23` | `value=0` (`c2-fg3a.txt`) |
| **one round later** (two more claim rows, SCORECARD untouched) | `claims=23` | `claims=25` | `value=1` (`c2-decay.txt`) |

So the number the L1 must write is **23** for a two-claim round, and it is invalid the moment round
49's rows land. The plan's named ceiling says this; the measurement fixes the arithmetic and shows
the 0 is a point value, not an invariant.

---

## 3. Causal separability, measured (not argued)

| id | tree / commit | counter | observed |
|---|---|---|---|
| S1 | commit holding **only** the C1 change (reference trial + measured section) | C2 | `C2_CAPABILITY_READINGS: value=3 keys=10` (`c2-s1-c1only.txt`) |
| S2 | tree holding **only** the C2 change (current-readings line, no trial file) | C1 | `C1_SOPS_AGE_TRIAL: value=0 absent=1 pins=1` |
| S3 | both changes + plan + claim rows + post-move section | C1 / C2 | `value=5 …` / `value=0 keys=10` (`c2-s3-full.txt`) |

The plan's K1-P/K2-P controls only measure each counter against its own change; they do **not** run
C1 against a C2-only tree or C2 against a C1-only tree. The three rows above close that gap: the two
claims are separable in the direction that matters (neither counter moves because of the other's
landing), and they coexist.

---

## 4. Is any axis harmed?

- **No score moves** (both claims 9 → 9) and no instrument is bent: the C2 kill rule correctly
  forbids touching `corpus/*.sh`, `corpus/*.py`, `plans/round-39-c*.sh` and forbids removing tsv rows.
  Verified by construction in the fixtures: every forgery above edits **only** `SCORECARD.md`
  (C2) or adds a script + appends to the entry (C1).
- **Open item (C1):** the entry lands self-contradictory (§2.4). Impacted axes: freshness and
  calibration of an artifact the round itself touches. Repairable append-only; if it lands
  un-repaired, the round's own landing is stale on arrival.
- **Open item (C1, counter-invisible):** the plan declares no **capability-table row**. `AXES.md`
  §Capabilities makes the repertoire table the record ("rows enter only through a round that
  demonstrates the capability running") and the stagnation nudge reads that table; `SCORECARD.md:714`
  still says "the latest first-working round in this table is 40". A round whose claim is a
  *capability acquisition* that adds no row leaves the clock where it was (round 49 fires the nudge
  again) and leaves 714 true. If a row is added, 714's sentence must be updated in the same commit or
  the file contradicts itself. Neither counter sees either state.
- **C2:** no harm; durability defect recorded (D-12).

---

## 5. Smallest safe corrections

### 5.1 C1 counter (route to a pre-data amendment; do not edit the frozen file)

The predicate does not change; only the run harness does. Two edits, both cheap:

1. **Remove the identity signal.** Give the real run and every shim run the *same* PATH string:
   build `$W/bin/{real,sh1..sh5}` and, per run, `ln -s`/`cp -R` the chosen directory to
   `$W/bin/run`, passing `PATH=$W/bin/run:/usr/bin:/bin`. F-C1-a then answers `HOLDS` under every
   run and reads 0.
2. **Require the tool to have been invoked.** Wrap the **real** `sops` too (a pass-through that logs
   `$1` to `$W/calls/<test>` and execs the pinned binary). Require, per T, at least one logged
   `encrypt`, and the operation the test names (`updatekeys`, `rotate`, `decrypt`). F-C1-a/b/d then
   read 0; the reference trial is unaffected (it really calls them).
3. **Tighten the entry conjunct** (same amendment): require the `- T<n> ` line to carry at least one
   `key=value` token, or a `sops <version>` *and* a measured token from a closed set (`refused`,
   `decrypts`, `values-unchanged`, `shamir_threshold=2`). F-C1-c then reads 0.

Residual after (1)–(3): a trial that reads the shim **bytes** still distinguishes the falsifier
(F-C1-b) — one named ceiling instead of three, and it is the only one that survives. The reviewer
leg remains required for that.

### 5.2 C1 landing (satisfiable under the frozen kill rule)

- Inside the new `## Measured (round 48 …)` section, append one bullet that names and supersedes
  `:9-10` and the `verified-at:` line verbatim ("the entry's scope sentence 'Nothing here was
  executed on this host' is superseded by this section; `verified-at` above is the documentation
  clock, not the execution date"). Append-only → no `-` line → kill rule untouched.
- Add the capability row (`SOPS/age rotation trial` → evidence `bash corpus/sops-age-trial.sh` +
  this entry's section → first-working `48`) **and** update `SCORECARD.md:714`'s "latest
  first-working round … is 40" in the same commit; or state in the report why no row enters.

### 5.3 C2 counter (pre-data amendment)

- Extract only the **first** `## Capabilities` section, and **fail closed (SETUP)** on a second
  `## Capabilities` heading anywhere in the file → F-C2-a.
- Make the extractor fence-aware and comment-aware (the lane's own D2 rule) → F-C2-b/F-C2-c.
- Replace "last occurrence wins" with "every parseable pair inside the section must MATCH, or carry
  an explicit supersession marker" — that is the claim sentence, and it also closes the
  table-vs-line gap. F-C2-a/b/c then read ≥1.
- Repair the row-712 prose ("8 cases each" → the executed counts) as part of the C2 landing; it is
  not a pair and no counter will ask.
- Write the K07 reading as **`claims=23`** for a two-claim round, and say in the line that it is
  revision-bound (already a named ceiling) — the 0 is not durable into round 49.

---

## 6. Bounds of this review

- Attacked the frozen instruments and plan only; the candidate's own `corpus/sops-age-trial.sh` does
  not exist at measurement time, so whether *its* bytes are the reference shape is outside this leg.
- I did not run the lane's full `claim-ledger verify`, self-counts or `self-description-sweep.sh`
  (seat bound). SDK7 (a `corpus/*.sh` mentioning `--selftest` must be named in `SKILL.md`) was read,
  not run: the reference trial contains no `--selftest` token, so the reference landing does not
  trip it; a candidate trial that adds one must be named in `SKILL.md`.
- Every quoted reading was produced by the command shown in this file at the revision shown. The
  C2 receipts hold the counter's full stdout; the C1 receipts hold its final
  `C1_SOPS_AGE_TRIAL: …` line (the only line the counter emits on that path). No value was retyped.
  Exit codes measured directly: `c1 base=0`, `c2 base=0`, `c1 on the both-legs forgery=0` (the
  counter exits 0 on any measured value; only SETUP exits 2).
- Refusal boundary observed: only the reference trial (run under the counter in the F-C1-c fixture)
  generated identities, inside its own scratch work dir, deleted by its own trap; the forged trials
  never invoked `sops` or `age-keygen` at all. No private key, `op://` path, vault or
  `~/.config/sops` / `~/.ssh` access occurred; no host state, package or PATH entry was touched.

SEAT-STATUS: complete
