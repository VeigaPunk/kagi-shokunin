# R56MutCounter-2 — mutation test of the round-56 C1 counter

Seat `R56MutCounter-2` (mutation tester, attack share). Lane `kagi-shokunin`, branch
`master`. Observed answering model: **amr/deepseek-v4.1-flash** (runtime project context,
not inferred from the prompt).

Assignment anchor: **epoch A `42070de7770e1558adcf6aa7a7bc59309a9654d7`** (predeclaration;
BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`). Mid-wave the planner predeclared
**epoch B `5d9a1571911ec38a456a40b443e19640abb9a88b`** and asked that epoch-B evidence be
anchored there; every reading below carries its anchor column. Instrument identity,
baselines, lane-drift observation and restoration evidence are in
`R56MutCounter.d/anchors.txt`; raw stdout for every run is in `R56MutCounter.d/raw-A/`
and `R56MutCounter.d/raw-B/`.

## Method

For each shape: `git archive <anchor> | tar -x -C <tree>`, apply one byte-level edit to
the copy, run `bash <counter-at-anchor> --tree <tree>` with `HYAKU_SCRATCH` inside the
seat scratch, record rc and the full `C1_REPLAY:` line. Where the gate verdict mattered,
the anchor's `corpus/recheck-replay.py --root <tree>` was also run and its output kept.
No clone of the lane was used as a fixture; one read-only clone (HEAD `42070de`) was used
only to run the frozen counter, because the counter reads `BASE:corpus/rendered-text-v1.py`
through `git -C "$REPO"`. No lane file was written; no fixture git mutation was made; no
network request was made.

Instrument identity (git blob = `hash-object` of the extracted bytes):

| file | epoch A 42070de | epoch B 5d9a157 |
|---|---|---|
| `plans/round-56-c1.sh` | blob `35a16e6…`, sha256 `096251c9…` | blob `23111d5…`, sha256 `6b132ea1…`, `GATE_SHA256_PIN=2e9dfde3…` |
| `corpus/recheck-replay.py` | blob `821da99…`, sha256 `b7782f35…` | blob `850e1ba…`, sha256 `2e9dfde3…` |
| `corpus/recheck-captures.tsv` | blob `7c85dc4…`, sha256 `df46be5c…` | same |
| `plans/round-56-controls.sh` | blob `07d0e23…`, sha256 `633326a5…` | blob `fda5491…`, sha256 `63cf8061…` |

Pristine baselines (full lines in `anchors.txt`):

```
epoch A counter / epoch A tree : rc=0  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
epoch B counter / epoch B tree : rc=0  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
epoch B counter / 42070de      : rc=0  C1_REPLAY: value=0  present=10 replayed=0  gate=0 guard=1 (r5-gate ×10; gate-digest)
epoch B counter / BASE 832ba6a : rc=0  C1_REPLAY: value=0  present=10 replayed=0  gate=0 guard=1 (r2-manifest ×10)
```

The two epoch-B baseline readings reproduce the planner's IRC claim exactly.

### Lane drift during the run, and scratch loss (observed, not caused by this seat)

The lane's working `plans/round-56-c1.sh` was rewritten by another process *while my first
sweep was running*: one run died with `plans/round-56-c1.sh: line 80: syntax error near
unexpected token `('` (text `TEST: PASS (13 cases)`), rc=2; another with
`TypeError: list indices must be integers or slices, not str` at `<stdin>` line 121, rc=1;
a third emitted bad tokens (`r5-cleanish`, `gate-digest`) that do not exist in the 42070de
blob. That first sweep is **inconclusive** and is kept only as `raw-drift/` evidence
(76K); every number below was re-run from an immutable clone at 42070de and, for epoch B,
from `git archive 5d9a157`. Later the working file hashed `d2bcb790…` (pin `637c8184…`) and
the lane committed epoch B. Separately, at ~07:53 the pristine `ref/` and `refB/` trees
were absent from seat scratch; they were re-extracted from the anchors and verified
file-for-file against the hashes used in the before/after table (details in
`anchors.txt`).

## Mutant table (21 shapes; actual first lines in `raw-A/`, `raw-B/`)

`A` = epoch A counter on epoch A tree. `B` = epoch B counter on epoch B tree. `P` = present.

| # | shape / setup | A: 42070de | B: 5d9a157 | verdict | proposed control |
|---|---|---|---|---|---|
| m01 | manifest URL cells swapped S054↔S057 (entries untouched) | `value=0 gate=0 guard=1` (r2-registry ×2) | `value=0 gate=0 guard=1` | killed both (r2-registry + gate BAD-CAPTURE) | existing F4/S054 family |
| m02 | S054 `body_path` → `corpus/knowledge/secret-scanning-detection-vs-validation.md`, bytes/sha of that file (grep count 1) | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | **SURVIVED B — circular body** | **F13-selfbody-grep** |
| m03 | ISO entry 3→1 clocks (delete 82709, 85929 clauses) | `FAIL P=8 replayed=8 gate=1 guard=0` | `FAIL P=8 replayed=0 gate=0 guard=0` | killed both (PRESENT/GUARD) | existing F1 |
| m04 | betterleaks clock moved to a second column-1 `recheck:` line | `FAIL P=9 replayed=9 gate=1 guard=0` | `FAIL P=9 replayed=9 gate=1 guard=0` | killed both (exactly-one-line) | existing F1 family |
| m05 | betterleaks entry rewritten with CRLF endings | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | scores; encoding-neutral (no claim violation) | **F19-crlf-entry** (expect 10) |
| m06 | duplicate S054 registry row as `S199` with the same URL | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | scores; r2 constrains only the named id's row | **F20-dup-registry-url** |
| m07 | `capture/S054.body` replaced by a directory | `value=0 gate=0 guard=1` (r3-file) | `value=0 gate=0 guard=1` | killed both | existing F6 family |
| m08 | betterleaks `-> 1` → `-> count=1` | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | scores; count= is an explicit BASE form (cdp clock) | **F21-count-form** (expect 10) |
| m09 | betterleaks recheck line wrapped in ``` fences | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | scores; no fence rule for clocks (asymmetry with registry fences) | **F22-fenced-clock** |
| m10 | betterleaks `-> 1` → `-> 0` | `FAIL P=9 gate=0 guard=0` | `FAIL P=9 gate=0 guard=0` | killed both (PRESENT) | existing F2 |
| m11 | `corpus/recheck-replay.py` replaced by a **Python** MATCH+CLEAN printer with `--selftest PASS` | `value=10 gate=1 guard=1` | `value=0 gate=0 guard=1` (pin mismatch) | survived A; **killed by B** (gate pin) | F5b covers B; **F5d-python-printer** for A |
| m12 | `corpus/knowledge` → symlink to `corpus/knowledge-real` (entries regular files) | `FAIL P=0 gate=1 guard=0` | `FAIL P=0 gate=0 guard=0` (gate `SETUP symlinked-input:corpus/knowledge`) | **A false negative** (gate CLEAN, PRESENT text held); killed by B confinement | **F16-inputsym-knowledge** |
| m13 | gate file deleted | `value=0 gate=0 guard=1` | `value=0 gate=0 guard=1` | killed both (r5 has no MATCH lines) | **F24-gate-absent** (expect 0) |
| m14 | new `zz-extra-clock.md` with a matching clock on the S054 URL | `value=10 gate=1 guard=1` (gate `CLEAN clocks=11`) | `value=0 gate=0 guard=1` (exact summary requires clocks=10) | survived A; **killed by B** | existing F12 |
| m15 | new hand-written `capture/hand.body` (60 B, pattern×1) + S054 row repointed; body absent from `fetch-receipt.json` | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | scores; **named ceiling** (hand-written capture) | **F26-receipt-bind** only if ceiling revoked |
| m16 | S054 registry status `mined` → `candidate` | `value=9 gate=1 guard=1` (one r2-registry) | `value=9 gate=1 guard=1` | predicate-correct partial; gate still CLEAN 10/10 (gate ignores status) | **F25-registry-status** (expect 9) |
| m17 | S070 (`locate` form) `body_path` → `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` (locate count 1) | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | **SURVIVED B — circular body** | **F14-selfbody-locate** |
| m18 | S101 (`grep` N=2) `body_path` → `corpus/knowledge/iso-11770-3-edition-status.md` (grep count 2) | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | **SURVIVED B — circular body** | **F15-selfbody-iso-n2** |
| m19 | `corpus/SOURCES.md` → symlink to `SOURCES-real.md` | `value=0 gate=1 guard=1` (r2-registry ×10) | `value=0 gate=0 guard=1` (gate `SETUP symlinked-input:corpus/SOURCES.md`) | **A false negative**; killed by B confinement | **F17-inputsym-registry** |
| m20 | `corpus` → symlink to `corpus-real` (whole corpus) | `FAIL P=0 gate=1 guard=0` | `FAIL P=0 gate=0 guard=0` (gate `SETUP symlinked-input:corpus/knowledge`) | **A false negative**; killed by B confinement | **F18-inputsym-corpus** |
| m21 | S054 row `http_status` → `500`, body unchanged (replays 1) | `value=10 gate=1 guard=1` | `value=10 gate=1 guard=1` | scores; manifest status column is unvalidated by both instruments | **F23-http-status** |

All non-`SETUP` runs exited `rc=0`; the counter exits 2 only on SETUP. `m03`/`m12`/`m20`
`FAIL` values are `guard=0` (PRESENT/confirmation), the rest of the non-10 values are `0`.

## Surviving mutants on epoch B (score 10)

### SM-1 — the body can be the entry that states the clock (m02, m17, m18) — primary finding

The manifest row's `body_path` is any confined regular file of the tree; nothing requires
it to be a capture of the row's URL or to appear in `capture/fetch-receipt.json`. Pointing
it at the knowledge entry that *states* the clock makes the replay count the entry's own
words, so r1–r5 all pass with no captured source at all:

* m02 (grep, N=1): S054 row body → `corpus/knowledge/secret-scanning-detection-vs-validation.md`
  (5129 B, sha256 `94c94cf6…`); `grep -c` of the stated pattern on the entry = **1**;
  counter/gate: `value=10 … gate=1 guard=1 (bad=none)`, gate `CLEAN (clocks=10 match=10 …)`.
* m17 (locate, N=1): S070 row body → `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`
  (9742 B, sha256 `bf6052bc…`); BASE normaliser: `RENDERED_TEXT_V1_LOCATE: count=1`;
  `value=10 … gate=1 guard=1`; gate CLEAN.
* m18 (grep, N=2): S101 row body → `corpus/knowledge/iso-11770-3-edition-status.md`
  (6958 B, sha256 `d758ff46…`); `grep -c` = **2**; `value=10 … gate=1 guard=1`; gate CLEAN.

Rows after mutation are in `R56MutCounter.d/surviving-mutant-rows.txt`. This is circular
evidence, not freshness evidence: the claim "the stated clock is true on a committed
capture" is satisfied by the document that states it. It is stronger than the named
"hand-written capture" ceiling, because the file is not a capture at all. Proposed
control (needs an r3 rule change, not a counter-only change):

```
# F13-selfbody-grep / F14-selfbody-locate / F15-selfbody-iso-n2
# repoint S054 / S070 / S101 body_path at the entry, set bytes+sha to the entry,
# leave entries and gate untouched; expectation once r3 requires a capture root
# (and/or fetch-receipt.json id+sha binding): 0
```

### SM-2 — manifest `http_status` (and `fetched`) is decorative (m21)

S054 row `http_status=500`, body unchanged (`S054.body` 38524 B sha `7cf6efb5…`, replays 1):
`value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`; the gate is CLEAN 10/10. The
manifest's `http_status`/`fetched` columns are not read by either instrument, so a row may
record a failed fetch and still certify freshness. Predicate-permitted as written (r2/r3
never mention those columns), but a freshness claim should pin them. Proposed
**F23-http-status** (expect 0 if rows admitted to the manifest must carry `200`).

### SM-3 — duplicate registry rows for the URL (m06)

Copying S054's 11-cell `mined` row to id `S199` keeps the same URL: `value=10 … gate=1
guard=1`. r2 only constrains the manifest row's own id, so URL uniqueness across the
registry is unasserted. If uniqueness is intended, this is a hole; if not, the reading is
correct. Proposed **F20-dup-registry-url** (record 10; change to 0 only with a plan rule).

### SM-4 — a clock inside a ``` fence scores (m09)

Wrapping the betterleaks `recheck:` line in fences leaves `value=10 … gate=1 guard=1`.
The clock population has no fence exclusion (the *registry* population does: the counter
skips fenced rows). Textually permitted by r1 ("column-1 `recheck:` line"); flagged as an
asymmetry. Proposed **F22-fenced-clock** (record 10; change to 0 only with a plan rule).

### SM-5 — encoding and form variants (m05, m08)

CRLF entries (m05) and the `-> count=N` form (m08) both read `value=10 … gate=1 guard=1`.
Neither changes the claim: CRLF is the same text, and `count=` is already used by the BASE
cdp clock. Proposed **F19-crlf-entry** and **F21-count-form**, both expecting 10, so the
non-discrimination is recorded rather than accidental.

### SM-6 — hand-written body absent from the receipt (m15) — named ceiling

`hand.body` (60 B, sha `253e4823…`) contains the pattern once; the S054 row points at it;
`value=10 … gate=1 guard=1`. `fetch-receipt.json` lists only the seven fetched bodies
(S054/S055/S057/S067/S070/S074/S078), so the receipt does not bind this body — the named
ceiling ("a hand-written capture with a self-consistent manifest row scores") is confirmed
live. Proposed **F26-receipt-bind**, tenable only if the ceiling is revoked.

## Epoch-A survivors killed by epoch B (evidence)

| shape | A reading | B reading | B mechanism |
|---|---|---|---|
| m11 Python printer gate (`R56MutCounter.d/m11-printer-gate.py`) | `value=10 present=10 replayed=10 gate=1 guard=1` | `value=0 present=10 replayed=0 gate=0 guard=1` | `GATE_SHA256_PIN` mismatch → `HAVE_GATE=0`; the printer still prints MATCH×10 + CLEAN (rc=0), the counter no longer accepts it. The pre-freeze F5 control used a **bash** printer run with `python3`, which failed at parse; a Python printer passes epoch A. |
| m14 extra matching clock (`zz-extra-clock.md`) | `value=10 … gate=1 guard=1`; gate `CLEAN (clocks=11 match=11 …)` | `value=0 … gate=0 guard=1` | epoch-B `gate_clean` requires the exact `CLEAN (clocks=10 match=10 … 0)` summary; clocks=11 fails it. |

## Epoch-A false negatives closed by epoch B (FAIL/0 when epoch-A PRESENT held)

| shape | A reading | A gate | B reading | B gate |
|---|---|---|---|---|
| m12 knowledge dir symlink | `FAIL P=0 gate=1 guard=0` | CLEAN 10/10 (glob follows the symlink; entry files are regular) | `FAIL P=0 gate=0 guard=0` | `SETUP symlinked-input:corpus/knowledge` (rc=2) |
| m19 SOURCES.md symlink | `value=0 gate=1 guard=1` (r2-registry ×10) | CLEAN 10/10 | `value=0 gate=0 guard=1` | `SETUP symlinked-input:corpus/SOURCES.md` |
| m20 corpus dir symlink | `FAIL P=0 gate=1 guard=0` | CLEAN 10/10 | `FAIL P=0 gate=0 guard=0` | `SETUP symlinked-input:corpus/knowledge` |

On epoch A, r1's PRESENT text ("the measured entry is a regular non-symlink file") held —
the *entry files* are regular; only a parent directory was a symlink — yet the counter
returned FAIL/0 while its own gate certified the tree. Epoch B closes this through r5
(pinned gate refuses symlinked `knowledge`/`registry`/`manifest`/normaliser inputs), which
is why the same shapes now read FAIL/0 with `gate=0`. No epoch-B shape in this set fails
while satisfying the epoch-B predicate: **the epoch-B readings are predicate-conforming
for all 21 shapes.** Proposed controls to lock the confinement (they pass on B):
**F16-inputsym-knowledge**, **F17-inputsym-registry**, **F18-inputsym-corpus**.

## Shapes that reach `value=10` (explicit answer)

On epoch B, nine uncovered shapes reach `value=10 … gate=1 guard=1`: **m02, m05, m06, m08,
m09, m15, m17, m18, m21**. Of those, the three **self-referential bodies (m02/m17/m18)**
are the surviving mutants that defeat the freshness intent; **m21** exposes decorative
manifest columns; **m15** is the named ceiling; **m05/m08/m09/m06** are predicate-permitted
variants. On epoch A, two more reach 10 (**m11**, **m14**), both killed by epoch B.

## Actual outputs (verbatim; full set in `raw-A/`, `raw-B/`)

```
# m02 epoch B
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
# m17 epoch B
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
# m18 epoch B
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
# m11 epoch A
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
# m11 epoch B
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate:<10 clocks>)
# m12 epoch A
C1_REPLAY: value=FAIL present=0 replayed=0 gate=1 guard=0 (bad=absent:<10 clocks>)
# m12 epoch B
C1_REPLAY: value=FAIL present=0 replayed=0 gate=0 guard=0 (bad=absent:<10 clocks>)
# m14 epoch A
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
# m14 epoch B
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate:<10 clocks>)
# m16 epoch B
C1_REPLAY: value=9 present=10 replayed=9 gate=1 guard=1 (bad=r2-registry:secret-scanning-detection-vs-validation.md:README.md)
# m19 epoch A
C1_REPLAY: value=0 present=10 replayed=0 gate=1 guard=1 (bad=r2-registry:<10 clocks>)
# m21 epoch B
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
```

Gate outputs for the quoted cases: m12-B `RECHECK_REPLAY: SETUP symlinked-input:corpus/knowledge`
(rc=2); m14-B `RECHECK_REPLAY: CLEAN (clocks=11 match=11 mismatch=0 no_capture=0
bad_capture=0 unsupported=0 tool=0)` (rc=0); m02-B `CLEAN (clocks=10 match=10 … 0)` (rc=0);
m16-B `CLEAN (clocks=10 match=10 … 0)` (rc=0) while the counter reads 9 — the gate does not
check the registry `status` cell, the counter does.

## Proposed controls (ids avoid the 16 epoch-B ids)

| id | setup | expected | why |
|---|---|---|---|
| F13-selfbody-grep | S054 row → `corpus/knowledge/secret-scanning-detection-vs-validation.md`, bytes/sha real | 0 | circular body; needs r3 capture-root or receipt binding |
| F14-selfbody-locate | S070 row → `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` | 0 | same, locate form |
| F15-selfbody-iso-n2 | S101 row → `corpus/knowledge/iso-11770-3-edition-status.md` | 0 | same, N=2 |
| F16-inputsym-knowledge | `corpus/knowledge` → symlink to a real dir | 0/FAIL | locks epoch-B confinement |
| F17-inputsym-registry | `corpus/SOURCES.md` → symlink | 0/FAIL | locks epoch-B confinement |
| F18-inputsym-corpus | `corpus` → symlink to a real dir | 0/FAIL | locks epoch-B confinement |
| F19-crlf-entry | rewrite an entry with CRLF | 10 | record encoding neutrality |
| F20-dup-registry-url | duplicate a registry row under a new id, same URL | 10 (or 0 if URL uniqueness is intended) | record interpretation |
| F21-count-form | restate `-> N` as `-> count=N` | 10 | count= is a BASE form |
| F22-fenced-clock | wrap a `recheck:` line in ``` fences | 10 (or 0 if clocks inside fences are not authoritative) | asymmetry with registry fences |
| F23-http-status | manifest row `http_status=500`, body unchanged | 0 if rows must be 2xx, else 10 | status column is decorative |
| F24-gate-absent | delete `corpus/recheck-replay.py` | 0 | r5 cannot be produced |
| F25-registry-status | registry `status` `mined` → `candidate` | 9 | documents gate/counter divergence |
| F5d-python-printer | Python MATCH+CLEAN printer gate (epoch A only) | 0 under epoch-B pin; 10 under epoch A | F5 only covers a bash printer |
| F26-receipt-bind | body under `capture/` absent from `fetch-receipt.json` | 10 under the named ceiling; 0 only if revoked | provenance is not enforced |

## Before/after hashes (full table in `mutant-hashes.tsv`)

Every mutant is a copy of the anchor tree; only the listed path changed. `before` is the
anchor's sha256 (or `absent`/`symlink`); `after` is the mutant's.

| mutant | path | before | after |
|---|---|---|---|
| m01 | `corpus/recheck-captures.tsv` | `df46be5c…` | `bd96f4d2…` |
| m02 | `corpus/recheck-captures.tsv` | `df46be5c…` | `370f7382…` |
| m03 | `corpus/knowledge/iso-11770-3-edition-status.md` | `d758ff46…` | `0a85056a…` |
| m04 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | `40dc9af0…` | `191e3bc1…` |
| m05 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | `40dc9af0…` | `73076943…` |
| m06 | `corpus/SOURCES.md` | `fa69564f…` | `4d6bb387…` |
| m07 | `.ufo/waves/round-56/capture/S054.body` | `7cf6efb5…` | directory |
| m08 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | `40dc9af0…` | `71fa2b7d…` |
| m09 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | `40dc9af0…` | `887bf159…` |
| m10 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | `40dc9af0…` | `5bc2b346…` |
| m11 | `corpus/recheck-replay.py` | `2e9dfde3…` | `332d0679…` |
| m12 | `corpus/knowledge` | directory | symlink → `knowledge-real` |
| m13 | `corpus/recheck-replay.py` | `2e9dfde3…` | deleted |
| m14 | `corpus/knowledge/zz-extra-clock.md` | absent | `85116179…` |
| m15 | `.ufo/waves/round-56/capture/hand.body` / manifest | absent / `df46be5c…` | `253e4823…` / `8a1ee84f…` |
| m16 | `corpus/SOURCES.md` | `fa69564f…` | `25e1656c…` |
| m17 | `corpus/recheck-captures.tsv` | `df46be5c…` | `53a09cc9…` |
| m18 | `corpus/recheck-captures.tsv` | `df46be5c…` | `7a5d4aef…` |
| m19 | `corpus/SOURCES.md` / `SOURCES-real.md` | `fa69564f…` / absent | symlink / `fa69564f…` |
| m20 | `corpus` / `corpus-real` | directory / absent | symlink / directory |
| m21 | `corpus/recheck-captures.tsv` | `df46be5c…` | `84237c2d…` |

## Reproduction

```
git -C <lane> archive <anchor> | tar -x -C <tree>
# apply the one edit (rows above; printer: R56MutCounter.d/m11-printer-gate.py)
HYAKU_SCRATCH=<seat-scratch> bash <counter-at-anchor> --tree <tree>    # rc + C1_REPLAY line
python3 -I -B <tree>/corpus/recheck-replay.py --root <tree>            # optional gate verdict
```

Counter source used per anchor: epoch A `clone/plans/round-56-c1.sh` (blob `35a16e6`),
epoch B `git show 5d9a157:plans/round-56-c1.sh` (blob `23111d5`). The lane working file is
**not** an admissible instrument for either anchor (it drifted mid-run; see above).

## Limits / unrun

* Offline only: no live re-fetch, no currency check on the day; the captures are committed
  bytes. No network request and no credential/header material was involved.
* Not tested: `--tree` with a `.git` inside the measured tree; `REV`-mode reads of mutant
  commits (no mutant was committed); anything in C2 (none this round); the epoch-B
  *candidate* beyond the frozen `5d9a157` tree.
* The first sweep is inconclusive due to the concurrent lane write and is not used as a
  reading; `m21` on epoch A was run after the main sweep (same result as B: 10).
* Restoration: pristine trees never written by this seat; epoch-B tree re-read
  `value=10` after all 21 mutants and its relative content digest was unchanged
  (`6b4e9588…`); scratch deleted before yield.
