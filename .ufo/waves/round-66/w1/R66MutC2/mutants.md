# R66MutC2 — mutation test of plans/round-66-c2.sh and plans/round-66-c3.sh

Seat: R66MutC2 (mutation-tester). Scope: the two counters only; read-only on lane
source; every mutant applied to a disposable reflink copy under
`/fast/scratch/hyaku/kagi-r66/R66MutC2/`. Base of the measured tree: lane HEAD
`ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca` (frozen plan) extracted with
`git archive`, plus the untracked round-66 wave inputs (`claims.json` sha256
`f54cc0ac9d79c252d7a02a4ac63979333174d582b0f8d7485964c895ab6b87dd`,
`base/`, `capture/`).

Counters under test (final bytes, as landed by their executor seats):

| counter | bytes | sha256 |
|---|---|---|
| `plans/round-66-c2.sh` | 20260 | `82ed8b991f3e07c65375f964a599f153c71762d431826ea925b54b82afef1f18` |
| `plans/round-66-c3.sh` | 22866 | `bbf69b5168d7d239a7a84133c01e647b55d0f087fc599d58c3a623730b18f470` |

C3 landed after C2; both executors declared these hashes final (C2's first ping
named `ab3ab234…`; the executor corrected it to `82ed8b99…`).

## Fixtures

`cand-target` is the plan-faithful candidate: the frozen plan's append-only
carrier repair — S148 row preserved verbatim; one new registry row `S157` whose
anchor cell cites `.ufo/waves/round-64/capture/S143.body` and carries the S148
pin `3b8d4e15…cba40`; S157 `source-fetches.tsv` row with col16 naming the same
path and col10 the pin; `claims-declared.tsv` gains the three round-66 rows
(claims=59); `SCORECARD.md` gains `## Round 66 — post-move` with `[C1]/[C2]/[C3]`
rows. `corpus/volatile-shape.py DEFAULT_CAPTURE` already names the round-64
capture at BASE (round-65 M65-4), so it was not touched. Input hashes:

| fixture | SOURCES.md | source-fetches.tsv | volatile-shape.py | capture S143.body | plan |
|---|---|---|---|---|---|
| `cand-target` | `559d4d30e31f` | `830cc473dbd4` | `48fd3e2753bb` | `3b8d4e159a0b` | `e24165577fc10516` |
| `cand-bare` (no repair) | `d443890a0c15` | `5cb3a15a0f8f` | `48fd3e2753bb` | `3b8d4e159a0b` | `e24165577fc10516` |

(hashes printed truncated to 12 hex; full hashes in `receipts/hashes.txt`)

## Baselines (read before any mutation)

**C2 on `cand-target`** — `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3 guard=0`,
rc 1. Legs: `guard-a selftest=1 rc=0` (PASS cases=11), `guard-b stale-mutation=1
named=C2`, `guard-c prefile=0 rc=2` (the fleet pre-file gate reads SETUP while
`kagi-r66-w1-results.json`/ledger/report are absent), `guard-d claims-declared=1
rc=0 claims=59`. The **exact leg is at target**; exit 0 is blocked only by
guard-c, which is L1 integration state, not counter state. Per-mutant verdicts
below are therefore judged on the exact-leg fields (`exact/titles/targets` and
the named mismatch lines), which are attributable; exit-code verdicts are
inconclusive while guard-c=0.

**C2 on `cand-bare` (BASE image + round-66 claims.json, zero repair)** —
`C2_CLAIMS: exact=1 claims=3 titles=3 targets=3 guard=0` (guard-d claims=56).
The default invocation reads the target on a do-nothing tree. The frozen K1
("at BASE the counter reads `exact=0`", measured over the round-65
claims/plan pair) is only reachable through the executor's added interface:
`--plan plans/round-65.md --claims .ufo/waves/round-65/claims.json` ⇒
`exact=0 titles=0 targets=0` with C1/C2/C3 title+target mismatches. Recorded as
control finding C2-K1 below, not as a mutant kill.

**C3 on `cand-target`** — `C3_SELFREF: resolved=0 checks=3 failures=0 guard=0`,
rc 1. Carrier legs at target (`checks=3`: registry anchor 1 + fetch col16 1 +
volatile 1; `failures=0`, `designated=S157`). Guard: `a=1 b=1 c=1 d=0`; the lane
census reads `SOURCES_CENSUS: FAILED (findings=6 rows=156)` (the four
round-65 S155/S156 findings plus two from the new row), so guard-d=0. Per-mutant
verdicts below are judged on `checks`/`failures` and the named failure lines,
which are attributable; the printed `resolved=`/exit code cannot move while
guard-d=0 (finding C3-RESOLVED below).

**C3 on `cand-bare`** — `C3_SELFREF: resolved=0 checks=1 failures=1 guard=0`
with `failure designated S148 cites-no-carrier-path pin=3b8d4e159a0b`: K1 reads
the failing value at BASE.

## C2 mutants

Baseline claims.json sha256 `f54cc0ac9d79c252…`; plan sha `e24165577fc10516…`
(both full hashes in `receipts/hashes.txt`).

| # | mutant (input edit) | mutated claims.json sha256 | expected detector | observed | verdict |
|---|---|---|---|---|---|
| C2-1 | `title-swap-C2`: C2.title → round-65 stale wording `C2_ROUTED: routed-leg population proves the six round-64 receipts` | `8f8ec88abc7ec47c` | exact=0, C2 named | `exact=0 titles=2`, `mismatch C2 title` | **killed** |
| C2-2 | `title-trailing-space-C1`: one trailing space on C1.title | `b9eae4ab50e1454d` | exact=0, C1 named | `exact=0 titles=2`, `mismatch C1 title` | **killed** |
| C2-3 | `extra-claim-C4` (flat): fourth claim `C4` beside C1..C3 | `3f222987f5bda85e` | exact=0, population | `exact=0 claims=4`, `population extra=C4 missing=-` | **killed** |
| C2-4 | `drop-claim-C2`: C2 removed | `80c0e079db749357` | exact=0, population | `exact=0 claims=2`, `population extra=- missing=C2` | **killed** |
| C2-5 | `extra-key-C1`: `note` added to C1 entry | `120555ae3d25b988` | exact=0 entry-shape | `exact=0 titles=2 targets=2`, `C1 entry-shape` | **killed** |
| C2-6 | `target-swap-C3`: C3.target stale | `93e69409ba013b29` | exact=0, C3 target named | `exact=0 targets=2`, `mismatch C3 target` | **killed** |
| C2-7 | `axis-swap-C3`: C3.axis → `depth` | `b3d60ffd73492aac` | exact=0, C3 axis named | `exact=0`, `mismatch C3 axis` | **killed** |
| C2-8 | `wrapper-only`: claims wrapped as `{"claims": {…}}` | `1f6f3be5d2e3e151` | accepted shape; verdict must not change | `exact=1 …` | benign (accepted by design) |
| C2-9 | `wrapper-extra-top-key`: `{"claims": {…}, "note": "extra top-level key"}` | `66d5ae43f1d0f01d` | exact=0 under the frozen "no extra key exists" | `exact=1 claims=3 titles=3 targets=3` | **SURVIVED** |
| C2-10 | `wrapper-sibling-C4` (probe): `{"claims": {C1,C2,C3}, "C4": {axis,title,target}}` | `b9f4efe1fdc0e372` | exact=0 (a fourth claim exists in the file) | `exact=1 claims=3 titles=3 targets=3` | **SURVIVED** |
| C2-11 | `plan-no-print-no-output`: §C2 loses the backticked `prints …` line and the `Output line:` line | claims unchanged; plan `e62d796effb71b78` | tier-3 label derivation; exact=0 naming C2 target | `exact=0 targets=2`, `mismatch C2 target`; `derive C2 target=exact = 1 iff … (BASE exact=0)` | **killed** |
| C2-12 | `amendment-restate-same`: `## Amendment A1 — C2` restates the identical printed body | plan `3a3c1b5aa88e05e0` | exact=1 (override path is value-preserving) | `exact=1 …` | benign (correct) |
| C2-13 | `amendment-restate-different`: amendment restates `claims=4 titles=4 targets=4` | plan `76fdf6e36a3a5deb` | exact=0 naming C2 target | `exact=0 targets=2`, `mismatch C2 target` | **killed** |
| C2-14 | `benign-key-order`: C1/C3 key order reversed | `27b194e2d1d46e9b` | exact=1 (order-independent) | `exact=1 …` | benign (correct) |
| C2-15 | no-op control (`json.dump` rewrite only) | `b8fd58115c94358e` | exact=1 | `exact=1 …` | control |
| C2-16 | missing claims.json (`--claims …/nope.json`) | — | SETUP exit 2 (K4) | `C2_CLAIMS: SETUP missing-claims …` rc 2 | correct |
| C2-17 | invalid JSON claims.json | — | SETUP exit 2 | `C2_CLAIMS: SETUP bad-json …` rc 2 | correct |

Survivor root cause (C2-9/C2-10): `as_claims()` unwraps `{"claims": {...}}` and
`compare()` then evaluates only the inner map. Any sibling top-level key —
including a fourth claim `C4` — is invisible to the population and extra-key
rules, so a claims file carrying an extra claim beside the wrapper reads
`exact=1`, contrary to the frozen "no extra key exists".

**Control finding C2-K1 (not a mutant kill).** The frozen K1 says "at BASE the
counter reads `exact=0` (titles diverge: round-65 claims.json vs plans/round-65.md
+ Amendments A1–A3); a tree that reads `exact=1` at BASE voids the claim". The
frozen Commands block exposes only `[--tree DIR] [--selftest]`. On a
byte-identical BASE image carrying the round-66 `claims.json`, the default
reading is `exact=1` (target reached with zero candidate work); on a true BASE
extract (`d549ee6`) the round-66 plan/claims do not exist, so the default
reading is SETUP, not `exact=0`. The K1 value is reachable only via the added
`--plan/--claims` extension, and it is not part of `guard`/exit.

## C3 mutants

Baseline `checks=3 failures=0`. Full fixture hashes in `receipts/hashes.txt`;
each row shows the file(s) changed relative to `cand-target`.

| # | mutant (input edit) | changed input sha256 | expected detector | observed | verdict |
|---|---|---|---|---|---|
| C3-1 | `path-missing`: S157 anchor path → `.ufo/waves/round-64/capture/S999.body` | SOURCES `bb46e36402a5` | named missing-path failure; resolved 0 | `checks=3 failures=2`: `registry S157 missing-path:…S999.body`; `designated S157 digest-mismatch-carrier` | **killed** (designated line mislabels a missing path) |
| C3-2 | `digest-mismatch-file`: S157 anchor path → round-64 `S148.body` (arXiv, `fabc74c5…`) | SOURCES `c0dd91df8eeb` | named digest-mismatch; resolved 0 | `checks=3 failures=2`: `registry S157 digest-mismatch:…S148.body sha=fabc74c534e4`; designated line | **killed** |
| C3-3 | `digest-mismatch-bytes`: one byte flipped in `.ufo/waves/round-64/capture/S143.body` | capture `a123bfef26bd` | named digest-mismatch on all three stands | `checks=3 failures=4`: registry, fetches, volatile, designated each name `sha=a123bfef26bd` | **killed** |
| C3-4 | `wrong-dir`: S157 anchor path → `.ufo/waves/round-63/capture/S143.body` (exists, sha `8522a79e…`) | SOURCES `e09886829f31` | stand outside `round-64/capture` refused | `checks=2 failures=1`: `designated S157 digest-mismatch-carrier` (no line names the outside-dir citation) | **killed** (message gap) |
| C3-5 | `uncited-carrier`: S157 anchor path removed | SOURCES `80db3d17bb0b` | K1 shape: failures≥1 | `checks=2 failures=1`: `designated S157 cites-no-carrier-path pin=3b8d4e159a0b` | **killed** |
| C3-6 | `extra-round64-citation`: S157 anchor cites the carrier **and** `S148.body` | SOURCES `b775e19bd486` | checks≠3 and named digest-mismatch | `checks=4 failures=1`: `registry S157 digest-mismatch:…S148.body sha=fabc74c534e4` | **killed** |
| C3-7 | `fetch-missing`: S157 fetch col16 → `-` | fetches `e652d753648f` | checks≠3 | `checks=2 failures=0` (verdict falls on checks only, no named failure) | **killed** (check-count only) |
| C3-8 | `fetch-path-missing`: S157 fetch col16 → `…/NOPE.body` | fetches `945ad90db658` | named missing-path | `checks=3 failures=1`: `fetches S157 missing-path:…NOPE.body` | **killed** |
| C3-9 | `fetch-wrong-file`: S157 fetch col16 → `S148.body` | fetches `cc6977ca3a3e` | named digest-mismatch (vs col10) | `checks=3 failures=1`: `fetches S157 digest-mismatch:…S148.body sha=fabc74c534e4` | **killed** |
| C3-10 | `fetch-digest`: S157 fetch col10 → 64×`0` | fetches `8155f489497f` | named digest-mismatch + pin cross-check | `checks=3 failures=2`: `registry S157 pin=anchor-pins=1-vs-fetch=000000000000`; `fetches S157 digest-mismatch:… sha=3b8d4e159a0b` | **killed** |
| C3-11 | `volatile-wrong`: `DEFAULT_CAPTURE` → `S148.body` | volatile `fac4f8055ac5` | named digest-mismatch | `checks=3 failures=1`: `volatile digest-mismatch:…S148.body sha=fabc74c534e4` | **killed** |
| C3-12 | `anchor-vs-teaches-cell`: S157's carrier path moved out of the **anchor** cell into the **teaches** cell (row line still contains it) | SOURCES `7893d1f120a8` | anchor cell uncited → checks≠3 or a named anchor failure | `checks=3 failures=0` (target read) | **SURVIVED** |
| C3-13 | `fetch-unrelated-row`: S157 fetch col16 → `-`; S143 fetch row col10/col16 repointed to the carrier pin/path | fetches `78180efd6f6a` (SOURCES unchanged) | carrier row's own 16th column must name the capture | `checks=3 failures=0` (target read) | **SURVIVED** |
| C3-14 | `benign-uncited-row`: extra registry row citing no capture | SOURCES `c5481baa1d29` | checks/failures unchanged | `checks=3 failures=0` | benign (correct) |
| C3-15 | `benign-wrong-round-cite`: extra row citing a round-63 path whose digest ≠ its in-row pin | SOURCES `4c34d1c9c7b6` | ignored (not round-64) | `checks=3 failures=0` | benign (correct) |

Survivor C3-12 root cause: `parse_sources()` computes
`cites = PATH_RE.findall(line)` over the **whole table row**, not the anchor
cell (`cells[6]`). A capture path cited in the teaches/used-by cell therefore
counts as an anchor stand and satisfies the designated-carrier rule.

Survivor C3-13 root cause: the fetch surface counts **any** fetch row whose
col16 cites a round-64 path. It never binds that stand to the carrier
(pin-carrying / S148-superseding) row, so moving the citation to an unrelated
row with a matching col10 keeps `checks=3 failures=0`.

Message/behaviour gaps (killed mutants, but the detector line is weaker than
the frozen wording):
- C3-1: designated leg reports `digest-mismatch-carrier` for a **missing** path.
- C3-4: no line names the outside-`round-64` citation; the only evidence is
  `checks=2`.
- C3-7: a missing fetch stand yields `failures=0`; only `checks=2` carries the
  refusal.

## Fixes for the surviving mutants

**F-C2-1 (kills C2-9/C2-10).** In `as_claims()`/`compare()`, reject sibling
top-level keys when unwrapping the accepted wrapper:

```python
def as_claims(obj):
    if isinstance(obj, dict) and isinstance(obj.get("claims"), dict):
        extra = set(obj) - {"claims"}
        if extra:
            return ("extra-top-level", extra)   # compare() prints
            # exact=0, "population extra-top-level=" + ",".join(sorted(extra))
        return obj["claims"]
    return obj
```

Simplest form: pass the sibling set into `compare()` and return
`0,0,0,["population extra-top-level=note"]` so the mismatch names the hidden
key; the flat-shape rules then stay unchanged. Dropping wrapper tolerance
entirely (require the flat `{C1,C2,C3}` map) also kills both, but changes the
accepted interface.

**F-C2-2 (control C2-K1).** Make the K1 cross-reading part of the frozen
verdict: add a guard/read leg that runs the same derivation with
`--plan plans/round-65.md --claims .ufo/waves/round-65/claims.json` and requires
`exact=0` (and carries its own `c2-claims: base-cross=…` line). The K1 sentence
already names that pair, so no plan amendment is needed; alternatively the L1
re-bases `exact=0` on a sealed pre-round claims snapshot for the round-66 pair.
Without one of the two, the default reading reaches `exact=1` on a do-nothing
tree.

**F-C2-3 (guard-b independence).** `guard-b` derives the stale wording from the
live claims (`base=live`). On `drop-claim-C2` it printed
`guard-b stale-phrase-not-found` (leg 0) even though the compare correctly read
exact=0. Derive the stale literal from the committed
`.ufo/waves/round-65/claims.json` (present in every candidate tree) so guard-b
is independent of the measured file.

**F-C3-1 (kills C3-12).** Restrict the citation scan to the anchor cell:

```python
cites = [scrape_path(p) for p in PATH_RE.findall(anchor)]
```

Keep the whole-line scan only for the population report (`reg_cites_all`), and
never feed it into `checks`, `failures`, or `designated`.

**F-C3-2 (kills C3-13).** Bind the fetch stand to the carrier row family:
compute `carrier_ids = {r["id"] for r in rows if vpin in r["anchor"]}` (the
pin-carrying rows) and count a `fetch_r64` entry only when `f["id"] in
carrier_ids`; if the last pin-carrying row has no round-64 col16 citation,
emit `fetches <id> col16-not-a-round-64-citation` as a failure. This keeps the
`candidate 1 + 1 + 1` geometry and refuses the unrelated-row substitution.

**F-C3-3 (`resolved` conflates guard).** The frozen output line is
`C3_SELFREF: resolved=1 checks=3 failures=0 guard=G` and exit 0 iff guard=1 and
resolved=1; the counter currently computes
`resolved = 1 if (checks == 3 and not failures and guard)`. Compute the
carrier quantity independently and leave the conjunction to the exit:

```python
resolved = 1 if (checks == 3 and not failures) else 0
raise SystemExit(0 if (resolved and guard) else 1)
```

Then a plan-faithful candidate with a dirty census prints
`resolved=1 checks=3 failures=0 guard=0` (frozen shape), instead of masking the
carrier reading behind the guard.

**F-C3-4 (message precision).** Split the designated/outside-dir diagnostics:
name `missing-path:<p>`, `digest-mismatch:<p> sha=…`, and
`outside-round-64:<p>` distinctly (the current line says
`digest-mismatch-carrier` for a missing path and has no outside-dir line).
Also print which row supplied each counted stand (`stand registry=S157`,
`stand fetches=S157`, …) so `checks=3` cannot be satisfied by a substitution
invisible in the receipt.

**F-C3-5 (guard-d baseline, not a counter defect).** The frozen guard (d)
requires `SOURCES_CENSUS: CLEAN`; on the plan-faithful candidate the lane census
reads `FAILED findings=6 rows=156` (the four round-65 S155/S156 findings plus
two from the new row). The frozen carrier repair does not include those
repairs, so guard-d (and therefore `resolved`/exit) cannot reach target until
the L1 lands them (or the plan is amended). The counter's requirement is
faithful to the freeze; the baseline blocker is integration state, and the
executor's own conforming-fixture receipt shows guard=1 is satisfiable.

## Restoration and write-scope evidence

- No write to lane source: the lane's `plans/round-66-c2.sh` and
  `plans/round-66-c3.sh` hashes are identical before and after every run
  (`82ed8b99…`, `bbf69b51…`); all mutant fixtures live in
  `/fast/scratch/hyaku/kagi-r66/R66MutC2/fix/` (reflink copies of the
  `git archive ddcd46b` image). Lane `git status --porcelain` after the tests
  shows only the pre-existing untracked round-66/round-66 scripts and the
  inherited round-65 `.ready.void` artefacts.
- Every mutant's before/after input hashes are in the C2/C3 tables above and in
  `receipts/hashes.txt`; the scratch fixtures are disposable and deleted on
  exit (`rm -rf`), so no restoration of lane bytes is required.
- Tools installed: none (bash, python3, sha256sum, cp reflink only).

## Receipts

`receipts/` in this seat directory: `c2-summary.txt` (per-mutant output for the
final bytes), `c3-summary.json` and `c3-<mutant>.txt` (verbatim counter output
per run), `c2-<mutant>.txt`, `hashes.txt` (full fixture/input hashes), and
`counter-sha.txt`. The probe runs (`wrapper-sibling-C4`, `fetch-unrelated-row`)
are included.

## Post-test note — the plan was amended while this battery ran

At 06:32:25 (after the readings above) the L1's working-tree
`plans/round-66.md` changed (`sha256 42b88af415a4bbfc9bcb86c9a7d07c71dcc515aa480a14b1a62a0ff0d82d84c2`,
uncommitted at the time of writing) with Amendments A1/A2/A3. A1 restates §C1;
**A2 replaces §C2's claims-exactness predicate with `C2_PREFILE`** (pre-file
gate + `claims-declared`); **A3 replaces §C3's registry-anchor predicate with
`C3_CENSUS`** (the lane census findings count).

Every reading above was taken against the freeze-time blocks in commit
`ddcd46b` (fixture plan `sha256 e24165577fc10516…`), with the counters at the
hashes stated at the top. They are therefore **not** readings against A2/A3,
and the two counters as landed no longer implement the plan's current §C2/§C3
text. The battery remains evidence about the instruments the L1 amended (A2
names the very C2 vacuity measured here as survivor 4; A3 withdraws the
hard-coded anchor sample). A new counter built to A2/A3 needs a fresh mutation
battery; the fixes above for the old instruments are not substitutes.

## Second battery — the amended instruments (A2/A4 C2_PREFILE, A3/A4 C3_CENSUS)

The plan changed twice while the first battery ran: at 06:32:25 (A1–A3) and
again by 06:34:18 (`plans/round-66.md` sha
`6841fcde7bbf099ab49cac4b065e46b51c6fbbbc0481af1e7ce9719cda82a1d5`, 22774 B,
adding A4). `plans/round-66-c2.sh` is now the L1's `C2_PREFILE` (first read at
`2a9101f14a4c5237787badf8b37963d841b2e5d3935c3eea245d1eef2aefe4e1`, 11598 B;
the L1 fixed the defects reported here in `add9f9991feac56a92c6062253973a585f9d5cbe7b8f1a2ddf3c4c2aed059e3c`
and then `3d0fc704531a46b3cff4d5be056d2f7596c3f7d7c63c57d8a9615f269c6913b6`,
10751 B — the final bytes re-tested below) and `plans/round-66-c3.sh` the L1's
`C3_CENSUS` (sha `a6c36b87a4ae22f95b3f8cbc7369dfba8f588a20d308fbf0a8eede3fcef85683`,
8015 B). Both replace the instruments tested above; the first battery is
history against withdrawn claims and is retained because A2 cites its vacuity
measurement.

### C3_CENSUS (A3/A4) — battery and verdicts

Fixture: a 4.2 MB corpus-only copy of the lane's current `corpus/` (the census
gate reads corpus only); counter invoked with `--tree <fixture> --fleet <real
fleet> --scratch <mine>`. The counter's main leg reads the measured tree's
`corpus/sources-census.sh`; guard-d reads the fleet wrapper's own lane.

Baseline: lane tree ⇒ `C3_CENSUS: findings=0 rows=156 guard=1` rc 0; fixture ⇒
same. Target reachable; all four guard legs 1.

| # | mutant (input edit) | expected | observed | verdict |
|---|---|---|---|---|
| C3A-1 | `cites-removed`: strip `cites:` lines from `corpus/knowledge/claim-instrument-class-matrix.md` | findings≥1 | `findings=4 rows=156 guard=1`, rc 1 (`SC_BODY_CITE … unrecorded`) | **killed** |
| C3A-2 | `s155-provenance-removed`: drop S155's `source-fetches.tsv` row | findings≥1 | `findings=1 rows=156 guard=1`, rc 1 (`SC_FETCH`) | **killed** |
| C3A-3 | `stub-clean`: gate always prints `CLEAN (rows=156)` rc 0 | guard-b refuses the forgery | `findings=0 guard=0` (guard-b findings=0 on the stripped copy), rc 1 | **killed** |
| C3A-4 | `stub-failed-2`: gate prints `FAILED (findings=2 rows=156)` rc 0 | findings read, exit not trusted | `findings=2 guard=1`, rc 1 | **killed** |
| C3A-5 | `stub-failed-0`: `FAILED (findings=0 rows=156)` rc 0 | guard-b refuses | `findings=0 guard=0`, rc 1 | **killed** |
| C3A-6 | `stub-no-line`: gate exits 0 with no verdict line | guard-a=0, no pass | `findings=-1 rows=-1 guard=0`, rc 1 | **killed** |
| C3A-7 | `stub-failed-3-rc0`: `FAILED (findings=3 …)` rc 0 | findings=3 ⇒ exit 1 | `findings=3 guard=1`, rc 1 | **killed** |
| C3A-8 | `stub-clean-rc1`: `CLEAN (rows=156)` rc 1 | line read; guard-b refuses | `findings=0 guard=0`, rc 1 | **killed** |
| C3A-9 | `stub-clean-rows999`: `CLEAN (rows=999)` rc 0 | rows read from the line; guard-b refuses | `findings=0 rows=999 guard=0`, rc 1 | **killed** |
| C3A-10 | `fake-fleet-guard-d`: fleet wrapper prints `kagi E01 …` rc 1 | guard-d=0 | `findings=0 guard=0` (guard d=0), rc 1 | **killed** |

No surviving mutant in this battery. Named ceilings observed: (i) guard-d
measures `$FLEET/kagi-shokunin`, not `--tree` when the two differ (fixture tree
+ real fleet ⇒ guard-d=1); on the default invocation they coincide; (ii)
guard-b's anti-forgery leg depends on the tree's own gate being
removal-sensitive — a gate that lies consistently on the tree and on the
stripped copy is the inherent gate-forgery ceiling; (iii) `rows` is read and
printed, never asserted (A4 item 3 supersedes the population), so a lying gate
may print any row count.

### C2_PREFILE (A2/A4) — first read (2a9101f1), fix, and final re-test (3d0fc704)

Fixture fleet `fix/a2-fleet`: the repaired candidate tree plus
`.ufo/waves/round-66/{claims.json, w1-results.json, claim-falsification.tsv}`
(3 claims × 3 attack seats = 9 neutral rows, artifacts present),
`.ufo/reports/round-66/kagi.md`, and a copy of
`scripts/hyaku/prefile-falsification.py`. With `--fleet` the gate reads
`PREFILE-FALSIFICATION: pass claims=3 rows=9 attack_seats=3 findings=0` rc 0;
`claims-declared` on the same tree reads `CLEAN (claims=59)` rc 0.

**First read (2a9101f1) found two blocking defects**, both since fixed by the
L1 (`add9f9991` → `3d0fc704`):

1. **`--fleet` was parsed but never passed to the gate.** `run_gate()` and all
   three guard invocations called `prefile-falsification.py` without
   `--fleet`; the default root is `/home/vgpnk/Projects/shokunin`, so the
   counter measured the default fleet, not the measured tree (`--tree` reached
   the gate only as `cwd`, which the gate ignores). Measured: gate `--fleet
   <fixture>` ⇒ pass; same gate without `--fleet` ⇒ `SETUP findings=2`; the
   counter ⇒ SETUP.
2. **Guard-b could not be satisfied.** It built `rfleet/kagi-shokunin` empty
   (only guard-c populated its copy) and both guards invoked the gate without
   `--fleet`; a PASS ledger contains no `claim-uncovered`/`attack-seat-unread`
   finding, so b=c=0 and guard=0 on a perfect integration.

On those bytes, input mutants were invisible to the counter while the gate
saw them: all-C3-rows-removed ⇒ gate `FINDING claim-uncovered` / `FAIL …
findings=1`; all-`R66Critic`-rows-removed ⇒ gate `FINDING attack-seat-unread`
/ `FAIL … findings=1`; the counter read the same `SETUP findings=2`, gate=0.

**Final re-test on `3d0fc704` (fixed; per-run counter-hash asserted identical
for every row).** Target fixture: `C2_PREFILE: gate=1 claims=3 rows=9
attack_seats=3 guard=1`, rc 0, `gate-line PREFILE-FALSIFICATION: pass
claims=3 rows=9 attack_seats=3 findings=0`. `guard a=1 b=1 c=1 d=1
claims-declared=1`. Input mutants:

| # | mutant | expected | observed | verdict |
|---|---|---|---|---|
| C2F-1 | all C3 rows removed from the ledger | gate=0 (`claim-uncovered`) | `gate=0 claims=3 rows=6 … guard=1`, rc 1; gate line `FAIL findings=1` | **killed** |
| C2F-2 | all `R66Critic` rows removed | gate=0 (`attack-seat-unread`) | `gate=0 rows=6 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-3 | first data-row artifact → `R66Reviewer/nope.md` | gate=0 (`artifact-missing`) | `gate=0 rows=9 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-4 | first data-row artifact → `../../escape.md` | gate=0 (`artifact-outside-wave`) | `gate=0 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-5 | first data row verdict→`falsifies-wording`, narrowing `-` | gate=0 (`narrowing-missing`) | `gate=0 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-6 | `C4` added to claims.json | gate=0 (claims=4, gate requires 3) | `gate=0 claims=4 rows=9 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-7 | claims.json removed | gate=0 (SETUP, no line) | `gate=0 claims=0 rows=0 attack_seats=0 guard=0`, rc 1 | **killed** |
| C2F-8 | duplicate first data row appended | gate=0 (`artifact-repeated`) | `gate=0 rows=10 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-9 | `C1\tonly-two` row appended | gate=0 (`row-shape`) | `gate=0 rows=9 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-10 | first data row verdict → `meh` | gate=0 (`verdict-token`) | `gate=0 … guard=1`, rc 1; `FAIL findings=1` | **killed** |
| C2F-11 | round-66 rows stripped from `corpus/claims-declared.tsv` | gate=0 by the A2 conjunction (`claims-declared` CLEAN is part of `gate`) | `C2_PREFILE: gate=1 claims=3 rows=9 attack_seats=3 guard=1`, rc 1; provenance `claims-declared=0` | **SURVIVED at the verdict-line level** |

C2F-11 root cause and fix: the counter computes the printed `gate` from the
pre-file line only and folds `claims-declared` into the exit
(`exit 0 iff gate and guard and cd_ok`). A2's predicate says `gate = 1 iff
prefile PASS **AND** claims-declared CLEAN`, so the line must read
`gate=0` here. Fold `cd_ok` into `gate` (or add a `cd=`/`claims_declared=`
field to the verdict line) so the receipt and the exit agree; the exit code
is already correct.

The lowercase `pass` trap (A4 item 1) is handled by `re.I` +
`status.lower()`; `claims-declared` is tree-scoped (59 ⇒ 1, 56 ⇒ 0); the
fixed guard-b/c build and read their own fixture fleets (all four guards 1 on
the target).


### Second-battery receipts

`receipts/a2-prefile-scoping.txt`, `receipts/a2-a2-mut-claim.txt`,
`receipts/a2-a2-mut-seat.txt`, `receipts/a2-fixture/*`,
`receipts/a2fixed/*` (final 3d0fc704 battery and per-run counter sha),
`receipts/c3a3-lane-baseline.txt`, `receipts/c3a3-*.txt`,
`receipts/c3a3-summary.json`. Lane source was untouched: C3
`a6c36b87…` at both ends; C2 moved from `2a9101f1…` to the L1's
`add9f9991…`/`3d0fc704…` while the battery ran (edits by the L1, not this
seat), and every row of the final battery asserted the same per-run counter
sha `3d0fc704…`.


