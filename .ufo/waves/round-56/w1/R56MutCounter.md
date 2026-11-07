# R56MutCounter-2 — mutation test of the round-56 C1 counter (epochs A → B → C → D → E → F)

Seat `R56MutCounter-2` (mutation tester, attack share ≥25%). Lane `kagi-shokunin`,
branch `master`. Observed answering model: **amr/deepseek-v4.1-flash** (runtime project
context, not inferred from the prompt).

Anchors — every reading is labelled with the anchor that produced it:

| epoch | commit | status |
|---|---|---|
| BASE | `832ba6a53d6a76706b5c80bce2278683dea33d42` | no-work reading |
| A | `42070de7770e1558adcf6aa7a7bc59309a9654d7` | assignment anchor |
| B | `5d9a1571911ec38a456a40b443e19640abb9a88b` | superseded |
| C | `711e6393e68658f396918c07de253e5a5c74d1b4` | superseded |
| D | `d36231871c864c930d3e7e33f9c5345b30ab4f98` | superseded (verdict-identical to E) |
| **E** | **`dd31b7867723f89fc8f83e88cc7d98e17de26cf2`** | **current anchor** |

Instrument identity (git blob from `ls-tree`; sha256 of the extracted bytes;
`git hash-object` of the extracted file equals the blob id — verified for every row):

| file | epoch A 42070de | epoch F 42070de → 9cbe9d5f (current) |
|---|---|---|
| `plans/round-56-c1.sh` | blob `35a16e682a…`, sha256 `096251c9b7a7…` | blob `8a6850a5264d4e00213b7db48d1837f141b6e9e7`, sha256 `f4c1de312e4a566dfde6c0699fb66a94c2e71e459eb97afbddb5c4073ffd2382`, `GATE_SHA256_PIN=b6959d6c…` |
| `corpus/recheck-replay.py` | blob `821da99ce83e…`, sha256 `b7782f35c0c8…` | blob `737451d8d255c7604d8a2091604788bd1f5f9979`, sha256 `b6959d6c7afb9380c043cbd40530e6a70ee8da2bf79f1ea9d0669706f50bb5a3`, `NORMALIZER_SHA256_PIN=14f6ca6a…` |
| `corpus/recheck-captures.tsv` | blob `7c85dc4da34b…`, sha256 `df46be5c92c7…` | identical (`df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`) |
| `plans/round-56-controls.sh` | blob `07d0e234fc45…`, sha256 `633326a563c6…` | blob `8ee46844a3fe0802941da7ce0a6b3a33d809a362`, sha256 `644cde80a7f1a05f6f3543c2b52a37c7e1dc82f40942199f4cb2b728d01b53ce` |
| `plans/round-56.md` | blob `106be490947c…` | blob `0e90b9ec8d059e942a5b2362e2459cd8cdd3bf7b`, sha256 `d0a8e402da2ac7a5c40eb3352a91918830253ba5502aae66442740d0c9dc025b` |

The normaliser `corpus/rendered-text-v1.py` hashes
`14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` (= its pin). The F
tree's sorted relative-path content digest is
`2f633fc439ecad874eaf07e3e99612b8d8916edc6bdf6d2191289b842457667e`, identical from two
independent extractions. The E tree digest was
`9647e73e5a73c6f528bf6dc0e620d72eeb4ced758c1ca1e9eef9606064f65532`. Full A/B/C/D identity,
baselines, lane-drift record and restoration evidence: `R56MutCounter.d/anchors.txt`.

## Method

For each shape: `git archive <anchor> | tar -x -C <tree>`, apply one byte-level edit to the
copy, run `bash <counter-at-anchor> --tree <tree>` with `HYAKU_SCRATCH` inside the seat
scratch, record rc and the full `C1_REPLAY:` line; where the gate verdict matters, run
`<anchor>/corpus/recheck-replay.py --root <tree>` too. One read-only clone (HEAD `42070de`)
supplies `git show BASE:corpus/rendered-text-v1.py`; the lane is never used as a fixture and
never written by this seat. No network request was made.

Pristine baselines (actual lines):

```
F counter / F tree 9cbe9d5f  : rc=0  value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
F counter / E tree dd31b786  : rc=0  value=FAIL present=10 replayed=0 gate=0 guard=0 (r5-gate ×10, selftest, gate-digest)
F counter / BASE 832ba6a     : rc=0  value=0 present=10 replayed=0 gate=0 guard=1 (r2-manifest ×10)
```

These reproduce the planner's epoch-F readings (`9cbe9d5f→10`; `dd31b786→FAIL` because the
gate bytes/pin changed; `BASE→0`). All 29 shapes were re-run under epoch E and the
`value/present/replayed/gate/guard` tuples are **identical** to the epoch-D column
(programmatic diff of `results-epochD.tsv` vs `results-epochE.tsv`: zero deltas). Under
epoch F the **13 verdict-bearing shapes** were re-run (`m02, m05, m06, m08, m09, m15, m16,
m21, m24, m29, m30, m31, m32`; `results-epochF.tsv`, `raw-F/`): m31 flips 10→0, every other
F reading equals its E/D tuple. The remaining 16 shapes were not re-run at F; their D/E
readings are carried and their failure reasons (r2/r3/r5/PRESENT) do not traverse the
fetched-calendar parse that F adds, while the F pin matches every mutant tree by
construction. The planner's 23/23 epoch-F controls receipt was **not re-run by this seat**.

### Lane drift and scratch loss (observed, not caused by this seat)

During the epoch-A sweep the lane's working `plans/round-56-c1.sh` was rewritten by another
process: one run died `line 80: syntax error near unexpected token `('` (line text
`TEST: PASS (13 cases)`, rc=2), another with `TypeError: list indices must be integers or
slices, not str` (`<stdin>` line 121, rc=1), and bad tokens (`r5-cleanish`, `gate-digest`)
appeared that do not exist in the 42070de blob. That sweep is **inconclusive** and kept only
as `raw-drift/`; every reading here was re-run from an immutable clone at 42070de (A) and
from `git archive <anchor>` (B/C/D). Separately, at ~07:53 the pristine `ref/`/`refB/` trees
were absent from seat scratch; both were re-extracted from the anchors and verified against
the exact hashes used in the tables (`anchors.txt`).

## Mutant table — 29 shapes, readings at A / B / C / D (D == E verified; F targeted)

Legend: `10` = `value=10 present=10 replayed=10 gate=1 guard=1`; `0` = `value=0`;
`FAIL` = `value=FAIL`; `(g0)` = gate=0; `P8` = present=8. Full lines: `raw-A/`,
`raw-B/`, `raw-C/`, `raw-D/`, `raw-E/`, `raw-F/`.

| # | shape / setup | A 42070de | B 5d9a157 | C 711e6393 | D d362318 = E|F | D/E verdict | proposed control |
|---|---|---|---|---|---|---|---|
| m01 | manifest URL cells swapped S054↔S057 (entries untouched) | 0 (g0) | 0 (g0) | 0 (g0) | 0 (g0) | killed (r2-registry + gate BAD-CAPTURE) | existing F4 family |
| m02 | S054 `body_path` → secret-scanning **entry** (bytes/sha real; grep count 1) | 10 | 10 | 0 (g0) | 0 (g0) | killed by `r3-notcapture` | C F13-not-capture-path |
| m03 | ISO entry 3→1 clocks (82709, 85929 removed) | FAIL (P8,g1) | FAIL (P8) | FAIL (P8,g0) | FAIL (P8,g0) | killed (PRESENT/GUARD) | existing F1 |
| m04 | clock moved to a second column-1 `recheck:` line | FAIL (P9,g1) | FAIL (P9,g1) | FAIL (P9,g1) | FAIL (P9,g1) | killed (exactly-one-line) | existing F1 family |
| m05 | betterleaks entry rewritten CRLF | 10 | 10 | 10 | 10 | scores; encoding-neutral | **F33-crlf** (expect 10) |
| m06 | duplicate S054 registry row as `S199`, same URL | 10 | 10 | 10 | 10 | scores; no URL-uniqueness rule | **F30-dup-registry-url** |
| m07 | `capture/S054.body` replaced by a directory | 0 (g0) | 0 (g0) | 0 (g0) | 0 (g0) | killed (r3-file + gate) | existing F6 family |
| m08 | betterleaks `-> 1` → `-> count=1` | 10 | 10 | 10 | 10 | scores; `count=` is a BASE form | **F32-count-form** (expect 10) |
| m09 | betterleaks `recheck:` line wrapped in ``` fences | 10 | 10 | 10 | 10 | scores; no fence rule for clocks | **F31-fenced-clock** |
| m10 | betterleaks `-> 1` → `-> 0` | FAIL (P9) | FAIL (P9) | FAIL (P9) | FAIL (P9) | killed (PRESENT) | existing F2 |
| m11 | gate replaced by a **Python** MATCH+CLEAN printer, `--selftest PASS` | 10 | 0 (g0) | FAIL (g0) | FAIL (g0) | survived A only; killed by pin + `SELF_OK=0` | F5b (B/C/D); **F5d-python-printer** for A |
| m12 | `corpus/knowledge` → symlink to `corpus/knowledge-real` | FAIL (P0,g1) | FAIL (P0,g0) | FAIL (P0,g0) | FAIL (P0,g0) | A false negative; B/C/D kill (input confinement) | **F16-inputsym-knowledge** |
| m13 | gate file deleted | 0 (g0) | 0 (g0) | 0 (g0) | 0 (g0) | killed (r5 has no MATCH line) | **F24-gate-absent** (expect 0) |
| m14 | new `zz-extra-clock.md` with a matching clock on the S054 URL | 10 | 0 (g0) | 0 (g0) | 0 (g0) | survived A only; killed by exact `clocks=10` summary | existing F12 |
| m15 | new hand-written `capture/hand.body` (60 B, pattern×1), S054 row repointed; absent from `fetch-receipt.json` | 10 | 10 | 10 | 10 | scores; **named ceiling** | **F34-receipt-bind** only if revoked |
| m16 | S054 registry status `mined` → `candidate` | 9 | 9 | 9 | 9 | predicate-correct partial; gate still CLEAN 10/10 | **F25-registry-status** (expect 9) |
| m17 | S070 (`locate`) `body_path` → cdp **entry** (locate count 1) | 10 | 10 | 0 (g0) | 0 (g0) | killed by `r3-notcapture` | C F13-not-capture-path |
| m18 | S101 (`grep`, N=2) `body_path` → ISO **entry** (grep count 2) | 10 | 10 | 0 (g0) | 0 (g0) | killed by `r3-notcapture` | C F13-not-capture-path |
| m19 | `corpus/SOURCES.md` → symlink to `SOURCES-real.md` | 0 (g1) | 0 (g0) | 0 (g0) | 0 (g0) | A false negative; B/C/D kill (input confinement) | **F17-inputsym-registry** |
| m20 | `corpus` → symlink to `corpus-real` | FAIL (P0,g1) | FAIL (P0,g0) | FAIL (P0,g0) | FAIL (P0,g0) | A false negative; B/C/D kill (input confinement) | **F18-inputsym-corpus** |
| m21 | S054 row `http_status=500`, body unchanged | 10 | 10 | 0 (g0) | 0 (g0) | killed by C/D `r2-manifest-malformed` | **F35-http-status** |
| m22 | S054 row `fetched=07/11/2026` (non-ISO) | — | — | 0 (g0) | 0 (g0) | killed by C/D `r2-manifest-malformed` | **F35b-fetched-form** |
| m23 | manifest header prefixed `< ` | — | — | 0 (g0) | 0 (g0) | killed (header mismatch) | **F36-hdr-prefix** (expect 0) |
| m24 | `capture/S054.body` replaced by a **FIFO** | — | — | 0 (g0) | 0 (g0) | killed, no hang, rc=0 fast | C F14 (entry side) + **F37-fifo-body** |
| m25 | S054 body copied to `corpus/hand.body`, row repointed | — | — | 0 (g0) | 0 (g0) | killed by `r3-notcapture` | C F13-not-capture-path |
| m29 | betterleaks `-> 1` → `-> 1.0` | — | — | 10 | FAIL (P9) | **fixed in D, holds in E** (boundary `(?![0-9A-Za-z_.])`) | F27 (implemented) |
| m30 | betterleaks `-> 1` → `-> 1.5` | — | — | 10 | FAIL (P9) | **fixed in D, holds in E** | F27 (implemented) |
| m31 | S054 row `fetched=2026-13-40` (impossible date) | — | — | 10 | 0 at F (10 at D/E) | **fixed in F** — `r2-manifest-malformed` after `date.fromisoformat` | **F28-fetched-calendar** (implemented) |
| m32 | S054 body prefixed `Set-Cookie: sid=x` at column 0 | — | — | 10 | 0 (g0) | **fixed in D, holds in E** (`(?im)` header refusal) | F29 (implemented) |

`—` = not run at that anchor (shape added later). All runs that reached the counter exited
`rc=0`; only SETUP exits 2. `m12`/`m20` read `FAIL` because the counter header's PRESENT
(definitions verbatim in the counter header, per the plan) rejects a symlinked path
component. `m11` reads FAIL at B/C/D/E because a present-but-unpinned gate sets `SELF_OK=0`.

## Surviving mutants at epoch F — none behaviour-bearing; m31 fixed

My epoch-C/D/E surviving mutant was m31: the row's `fetched` cell accepted the
calendar-invalid `2026-13-40` because the check was the shape regex
`^[0-9]{4}-[0-9]{2}-[0-9]{2}$`, while r3 requires "an ISO `fetched` date". Epoch F adds
`datetime.date.fromisoformat` in both instruments. Verified at F:

```
S054 … .ufo/waves/round-56/capture/S054.body  2026-13-40  200  38524  7cf6efb5…
F reading : C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1
            (bad=r2-manifest-malformed:<10 clocks>)
```

So **no behaviour-bearing surviving mutant remains from this set at epoch F**. The other
value=10 shapes are predicate-permitted variants or the named ceiling (below). Proposed
control **F28-fetched-calendar** is now implemented in F (and in its controls); the same
class (`2026-02-30`, `0000-00-00`) is covered by the parser.

### Fixed at D/E and still fixed at F (evidence, same method)

| shape | C | D | D mechanism |
|---|---|---|---|
| m30 `-> 1.5` (and m29 `-> 1.0`) | 10 (C) | `FAIL present=9 replayed=9 gate=1 guard=0 (bad=absent:betterleaks…)` | `(?![0-9A-Za-z_.])`: the `.` no longer right-bounds the integer |
| m32 `Set-Cookie:` at column 0 | 10 (C) | `0 (g0)`, `bad=…,r3-headers:secret-scanning-detection-vs-validation.md:README.md,…` | `(?im)` header refusal; D selftest adds Set-Cookie/Http-2 cases |
| m31 `fetched=2026-13-40` | 10 (C/D/E) | `0 (g0)`, `bad=r2-manifest-malformed:<10 clocks>` at F | F parses `date.fromisoformat` in gate+counter |

Both were my findings from the C sweep; the D instrument table credits `R56MutCounter F9`
(case) and the boundary change (also `R56ReviewCounter G2`). Verified independently above:
the D/E counter on the C tree reads FAIL (pin), on the D and E trees read 10.

### Predicate-permitted / ceiling shapes that also score 10 at F

| shape | F reading (E/D identical) | proposed control |
|---|---|---|
| m05 CRLF entries | 10 | **F33-crlf** (expect 10; encoding neutral) |
| m06 duplicate registry row for the URL | 10 | **F30-dup-registry-url** (10, or 0 if uniqueness is intended) |
| m08 `-> count=N` form | 10 | **F32-count-form** (10; the BASE cdp clock uses it) |
| m09 clock inside ``` fences | 10 | **F31-fenced-clock** (10, or 0 if fenced clocks are not authoritative) |
| m15 hand-written body under `capture/`, absent from `fetch-receipt.json` | 10 | **F34-receipt-bind** (named ceiling; 0 only if revoked) |

## Closed by B/C/D/E/F (evidence)

| shape | A | B | C | D=E=F (except m31) | mechanism |
|---|---|---|---|---|---|
| self-referential body (m02/m17/m18) | 10 | 10 | 0 | 0 | `capture_confined` (C) → `r3-notcapture` |
| real body outside `capture*/` (m25) | — | — | 0 | 0 | same |
| `http_status=500` (m21) | 10 | 10 | 0 | 0 | manifest 2xx rule (C) |
| non-ISO `fetched` shape (m22) | — | — | 0 | 0 | manifest ISO-shape rule (C) |
| manifest header prefix (m23) | — | — | 0 | 0 | header mismatch |
| body directory / FIFO (m07/m24) | 0 | 0 | 0 | 0 | `r3-file`; FIFO returns rc=0 fast |
| extra matching clock (m14) | 10 | 0 | 0 | 0 | exact `CLEAN (clocks=10 match=10 … 0)` |
| Python printer gate (m11) | 10 | 0 | FAIL | FAIL | gate pin; unpinned gate ⇒ `SELF_OK=0` |
| symlinked knowledge/registry/corpus (m12/m19/m20) | FAIL/0 (g1) | FAIL/0 (g0) | FAIL/0 (g0) | FAIL/0 (g0) | gate `SETUP symlinked-input` + counter `read()` |
| URL swap/deleted/moved clocks/N=0 (m01/m03/m04/m10) | killed | killed | killed | killed | r2/PRESENT/GUARD |

Epoch-A false negatives m12/m19/m20 are the only cases found where a non-10 reading
occurred while the epoch-A gate was CLEAN and the entry files themselves were regular; B
and C/D/E close them by refusing symlinked inputs at r5. At epoch F no shape in this set
fails while satisfying the F predicate, and the last behaviour-bearing survivor (m31) is
closed.

## Gate/counter divergence (not a mutant)

m16 (`status: mined → candidate`) reads `value=9 present=10 replayed=9 gate=1 guard=1
(bad=r2-registry:secret-scanning-detection-vs-validation.md:README.md)` at every epoch: the
gate still prints `CLEAN (clocks=10 match=10 …)` because it checks the registry row's URL
but not its `status` cell; the counter's r2 does check `mined`. A reader trusting only the
gate sees CLEAN while the counter says 9. Proposed **F25-registry-status** pins 9 and
documents the divergence.

## Actual outputs (verbatim; full sets in `raw-D/`, `raw-C/`, `raw-A/`, `raw-B/`)

```
# F baseline
C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
# m31 (F) — fixed
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest-malformed:<10 clocks>)
# m29 / m30 (E) — fixed
C1_REPLAY: value=FAIL present=9 replayed=9 gate=1 guard=0 (bad=absent:betterleaks-detection-vs-validation.md:README.md)
# m32 (E) — fixed
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=…,r3-headers:secret-scanning-detection-vs-validation.md:README.md,…)
# m24 (E) — FIFO body, fast
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=…,r3-file:secret-scanning-detection-vs-validation.md:README.md,…)
# m02 / m17 / m18 (E) — closed by capture confinement
C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=…,r3-notcapture:<clock>,…)
```

## Before/after hashes (operative edits; full tables in `mutant-hashes-E.tsv`, `mutant-hashes-D.tsv`, `mutant-hashes-C.tsv`)

All shapes are copies of the anchor tree; only the listed path changed. `before` is the
anchor's sha256, `after` the mutant's.

| mutant | path | before | after |
|---|---|---|---|
| m01 | `corpus/recheck-captures.tsv` | `df46be5c…` | `bd96f4d2eb5cd9603f47e59f9311f944787c10f2960352ed9db121199775eb76` |
| m02 | `corpus/recheck-captures.tsv` | `df46be5c…` | `370f738252c6f7c424f3fecef1927286c041f806bdde627747fd0f617b0a27b2` |
| m03 | `iso-11770-3-edition-status.md` | `d758ff46…` | `0a85056a433f35dc2ec1cfbc27d162a0e5e7295f62a6b96751669d0a967ba97a` |
| m04 | `betterleaks-…md` | `40dc9af0…` | `191e3bc16da35b5d9a5ca7e295c8e6327844da9e4faab14c976c78f9ad265dea` |
| m05 | `betterleaks-…md` | `40dc9af0…` | `7307694320a1160ccaff9e1345a06dc53a026326c4282f88aea7b18b3e252bfd` |
| m06 | `corpus/SOURCES.md` | `fa69564f…` | `4d6bb3870b78535a977855c82579197294fbd4ae214170605016b97a7e4046c0` |
| m07 | `capture/S054.body` | `7cf6efb5…` | directory |
| m08 | `betterleaks-…md` | `40dc9af0…` | `71fa2b7d15595c5683bba2cc471349e709e323005fb62374f2136fb3d45cf55d` |
| m09 | `betterleaks-…md` | `40dc9af0…` | `887bf159fc9093317df477595d286165697bfbb0cf30cbbdaf90f510fd6938e6` |
| m10 | `betterleaks-…md` | `40dc9af0…` | `5bc2b346f686c6c4541d0ed3562b82cafb4d8246d06fba99e8b13b0c785b2c6b` |
| m11 | `corpus/recheck-replay.py` | `5165da2a…` | `332d0679c0249ab0704a9e852ab84ee334e0c2bf36c8df52483802bbea4442f6` |
| m12 | `corpus/knowledge` | directory | symlink → `knowledge-real` (files byte-identical) |
| m13 | `corpus/recheck-replay.py` | `5165da2a…` | deleted |
| m14 | `corpus/knowledge/zz-extra-clock.md` | absent | `851161799b21015e95b710a72df8ce1ea2cdbc5d442748cf6226e34c5a819ae6` |
| m15 | `capture/hand.body` / manifest | absent / `df46be5c…` | `253e48238dc9b10bef7685dacc4ef9fd429804b6dee719b6fb6c4d30f72156b7` / `8a1ee84f…` |
| m16 | `corpus/SOURCES.md` | `fa69564f…` | `25e1656c30980b9e17b7e54afabc262923b509d17b57bc05ff83186fb36709d2` |
| m17 | `corpus/recheck-captures.tsv` | `df46be5c…` | `53a09cc985625f10e06fae7cfb60c0c0ac1df5cab4722d1483a2e5171f1a5fe2` |
| m18 | `corpus/recheck-captures.tsv` | `df46be5c…` | `7a5d4aef86141561c188f27cf2fcdc739effe0003c94bdd0f3cbdc821beb7be4` |
| m19 | `corpus/SOURCES.md` / `SOURCES-real.md` | regular / absent | symlink → `SOURCES-real.md` (same bytes `fa69564f…`) |
| m20 | `corpus` / `corpus-real` | directory / absent | symlink → `corpus-real` (files byte-identical) |
| m21 | `corpus/recheck-captures.tsv` | `df46be5c…` | `84237c2ddf5208a269b56a22569e97b84e95dfa7c18f5644de551b5ffd9fd4cf` |
| m22 | `corpus/recheck-captures.tsv` | `df46be5c…` | `42303383a51cc20ca32718fbf45c9635b2ed4fb9486f2eed3f013aa0f194f07b` |
| m23 | `corpus/recheck-captures.tsv` | `df46be5c…` | `d8750a81d900dd9864956be2a458fb6582e39d1cbd67579bac9dddd9e3974229` |
| m24 | `capture/S054.body` | `7cf6efb5…` | FIFO (no bytes read; rc=0) |
| m25 | `corpus/hand.body` / manifest | absent / `df46be5c…` | `7cf6efb5…` (same bytes) / `7cb07681…` |
| m29 | `betterleaks-…md` | `40dc9af0…` | `ec28f28dd0c8a18ccb06d932f411576828e028ba6531005fd85a997f83989f80` |
| m30 | `betterleaks-…md` | `40dc9af0…` | `934522690e8e9b5d747c8020e84a41c69c295b22b30a69d3f00b877fc5f46dd1` |
| m31 | `corpus/recheck-captures.tsv` | `df46be5c…` | `3806569c4ed57a4c9f9c9409d6fc21341a80e759869c3008e9a1051a8357bced` |
| m32 | `capture/S054.body` / manifest | `7cf6efb5…` / `df46be5c…` | `2afa47b395a4e9312afad9abb5565f0fac5f0277169d54725204096ef7bbe792` / `4b20e1b7…` |

Anchor values: manifest `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`;
`betterleaks-…md` `40dc9af0b99d2bb486872581321bc2e8f99165b8a8d6efe36586dfcb0a681383`;
`iso-…md` `d758ff464aa0edb0d703b0164dbb9691b82714a7090c3976c2043c25f80ea2ae`;
`SOURCES.md` `fa69564f610e5192093b05ae17c9ee385aa607586cc219d0e33460985ab12936`;
`capture/S054.body` `7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7`;
D/E gate `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f`.

## Proposed controls (ids avoid the 21 epoch-D ids where they exist)

| id | setup | expected | why |
|---|---|---|---|
| F28-fetched-calendar | row `fetched=2026-13-40` | FAIL | **implemented in F** (verified: value=0) |
| F30-dup-registry-url | duplicate registry row, same URL, new id | 10 (or 0 with a uniqueness rule) | pins the interpretation |
| F31-fenced-clock | `recheck:` line inside ``` fences | 10 (or 0 if fenced clocks are not authoritative) | asymmetry with the registry fence rule |
| F32-count-form | `-> count=N` | 10 | already a BASE form |
| F33-crlf | entry rewritten CRLF | 10 | encoding neutrality |
| F34-receipt-bind | hand-written body in `capture/`, absent from `fetch-receipt.json` | 10 under the named ceiling; 0 only if revoked | the receipt is not consulted |
| F35-http-status / F35b-fetched-form | `http_status=500` / non-ISO `fetched` | 0 | pins the C manifest rules in controls |
| F36-hdr-prefix | manifest header prefixed `< ` | 0 | pins fail-closed header handling |
| F37-fifo-body | `capture/*.body` as a FIFO | 0, rc 0 fast | fifo-safety currently covers entries |
| F24-gate-absent | delete the gate | 0 | r5 cannot be produced |
| F25-registry-status | registry `status` → `candidate` | 9 | gate CLEAN vs counter 9 |
| F5d-python-printer | Python MATCH+CLEAN printer gate | 0 under D pin; 10 under A | A's F5 only covers a bash printer |
| F16/F17/F18-inputsym-* | symlink knowledge / registry / corpus | 0/FAIL | locks B/C/D input confinement |

## Reproduction

```
git -C <lane> archive <anchor> | tar -x -C <tree>
# apply one edit (rows above); printer: R56MutCounter.d/m11-printer-gate.py
HYAKU_SCRATCH=<seat-scratch> bash <counter-at-anchor> --tree <tree>   # rc + C1_REPLAY line
python3 -I -B <tree>/corpus/recheck-replay.py --root <tree>           # optional gate verdict
```

Counter sources: A blob `35a16e6…` (pin absent), B blob `23111d5…` (pin `2e9dfde3…`),
C blob `3945a0f…` (pin `e9b7e4b7…`), D blob `321c2d9…` and E blob `cc27f35…` (pin
`5165da2a…`), F blob `8a6850a…` (pin `b6959d6c…`). The lane
working file is **not** an admissible instrument for any anchor (it drifted mid-run).

## Limits / unrun

* Offline only; no live re-fetch, no currency check on the day. No network request, no
  credential/header material captured or printed.
* Not tested: `--tree` with a `.git` inside the measured tree; mutant commits (none
  committed); C2 (none this round); the epoch-F candidate beyond the frozen `9cbe9d5f` tree; the epoch-F targeted re-run
  covers 13 of 29 shapes (listed above), the other 16 carry their D/E readings unrun at F;
  the epoch-F controls battery (planner-reported 23/23, not re-run here).
* The first sweep is inconclusive because of the concurrent lane write and is not used as a
  reading. Shapes added after the A sweep are `—` at A (unrun, not passed).
* Restoration: pristine trees were never written by this seat; the E tree re-read
  `value=10` after all 29 mutants, the F tree read `value=10` before the targeted re-run,
  and two independent `git archive 9cbe9d5f` extractions gave the same content digest
  (`2f633fc4…`); scratch is disposable per tasking and is
  deleted before yield.
