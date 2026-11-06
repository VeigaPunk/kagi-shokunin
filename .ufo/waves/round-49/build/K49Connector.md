# K49Connector — sibling-overlap scan, round 49 (read-only)

Seat: connector. Scope: the 20 sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/`
(kagi excluded), read-only. Lane BASE `89afe91878f10805921d3caa67d28d21b33226da`.
Receipt for every scan below: `.ufo/waves/round-49/build/K49Connector-scan.txt`.

I did **not** run `claim-ledger verify`, `self-counts.py`, `plans/round-49-c1.sh` or
`plans/round-49-c2.sh` (seat bounds). Every red-row number in §4 is a direct measurement of the
row's own cheap command, not a `verify` run.

Host note that changes readings: `grep` on this host is **`grep (pi-uu-grep) 0.2.0`**, not GNU
grep. It rejects EREs GNU accepts (`[[]substrate[]]` → `unclosed character class`). One ledger row
is red for that reason alone (§4, E4).

---

## 1. OpenBao / Vault token / lease ground in the siblings — none

Exact command, per lane, as the assignment specifies:

```
grep -rliE 'openbao|bao server|vault token|explicit.max.ttl|batch token|orphan token' \
     --include=*.md --include=*.sh <lane>/corpus
```

Result (`K49Connector-scan.txt`, 2026-11-06T21:12:54Z): **19 of 20 lanes `rc=1 hits=0`**
(audio, chousa, game-dev-2d, game-dev-3d, kaidoku, kake, kama, kengaku, kotoba, kotodama,
kumitate, lore, mado, mori, revenger, souji, tabi, tameshi, tsukuroi). One lane returns a hit:

| lane:path:line | text | overlaps C1? |
|---|---|---|
| `kasegi-shokunin/corpus/instruments/README.md:795` | "orphan token and no `FAIL` line of any class" | **No.** "orphan" here is an unbound instrument record, not an OpenBao orphan token. Different sense of the same two words. |

Widened to the product names (`grep -rliE 'openbao|hashicorp'`), two lanes hit, neither on
Vault/OpenBao token ground:

| lane:path:line | what it is | overlaps C1? |
|---|---|---|
| `kumitate-shokunin/corpus/SOURCES.md:183` (S228), `:188` (S234) | HashiCorp **Terraform** CLI docs (`plan -detailed-exitcode`, dependency lock file) | No — Terraform, not Vault/OpenBao. |
| `kumitate-shokunin/corpus/knowledge/shape-receipt-live-drift.md:1,3,28`; `snapshot-bound-derived-scores.md:1` | the two entries grounded on S228/S234 | No. |
| `kumitate-shokunin/corpus/lessons/round-78-verifier-spotcheck.md:119`; `round-80-verifier-spotcheck.md:186`; `round-80.md:30,31` | verifier rows for S228/S234 | No. |
| `revenger-shokunin/corpus/snapshots/claude-red-offensive-reporting.md:257` | a quoted remediation line: "Centralize secrets in HashiCorp Vault; rotate hardcoded creds" | No — a report snapshot sentence, no token/lease mechanic, no source row. |

`openbao` alone: **zero matches in all 20 sibling lanes** (grep tool, `!**/.ufo/**`, case-insensitive;
and the host-grep per-lane run above). No sibling holds a token TTL, explicit-max-TTL, batch-token,
orphan-token or lease-revocation claim.

This re-confirms the lane's own standing statement at `PROVINCE.md:94` ("Sweep: round-21 connector
over every `*-shokunin` PROVINCE.md/SKILL.md/corpus — no sibling claims SOPS, OpenBao/Vault,
Credential Broker or workload-identity ground") at 2026-11-06. **C1 has no sibling overlap to
declare, and no sibling prior art to cite for the OpenBao mechanics themselves.**

---

## 2. Calibration gates and counter-shim prior art

### 2a. `self-counts` / `stamps.tsv` / `claimed=…live=`

`glob` with `gitignore:false` (the fleet root ignores child repositories, so the default glob is
blind here):

- `/home/vgpnk/Projects/shokunin/*/corpus/stamps.tsv` → **`kagi-shokunin/corpus/stamps.tsv` only.**
- `/home/vgpnk/Projects/shokunin/*/corpus/self-counts*` → **`kagi-shokunin/corpus/self-counts.tsv`
  and `self-counts.py` only.**
- `grep -rniE 'claimed=.*live='` over all 20 siblings (`!**/.ufo/**`) → **No matches found.**

So the *instrument* is unique to kagi; the *method family* is not:

| lane:path:line | instrument | relation to C2 |
|---|---|---|
| `revenger-shokunin/corpus/self_assessment_check.py` (registry `revenger-shokunin/SKILL.md:307-313`; index `corpus/README.md:28`) | six bounded mismatch classes SM1–SM6 over README/SHONEN/SCORECARD, `--root`/`--self-test`, exit 0/1/2/64 | same job, different instrument: stated self-description vs repo bytes |
| `tabi-shokunin/scripts/check-selfassessment.mjs` (registry `tabi-shokunin/SKILL.md:2479`; `corpus/README.md:584`; LOG `LOG.md:1754-1756`) | m1 stale-tally / m2 enumeration / m3 live-tree / m4 nudge-state classes, `--rev` | same job; its m1 class is kagi's STALE class |
| `souji-shokunin/census/round-39/c1-counter.py` (`souji-shokunin/PROVINCE.md:318-321`; registry `SKILL.md:283`) | "binds the lane's own self-assessment to observed repo state and does not certify authorship" | same job, near-identical sentence to C2's predicate |
| `mori-shokunin/tools/mori-freeze-order.py` (`mori-shokunin/PROVINCE.md:132-133`; registry `SKILL.md:179`) | frozen claim inputs vs implementation commit order | adjacent: temporal, not count-vs-bytes |
| `tameshi-shokunin/corpus/knowledge/executable-self-assessment.md` (index `corpus/README.md:463`) | a SCORECARD row is a claim checked by running the row's own command at the same revision | adjacent: the method statement C2 instantiates |

No sibling has a *stamp table* (path/sha256/lines/bytes with a shrink-refusing `stamp`). C2's
novelty is the instrument, not the idea; the report should say so in those words.

### 2b. Counter shim designs (PATH shims for a CLI)

The direct predecessor is **in-lane**, not in a sibling: `plans/round-48-c1.sh:64-85` defines
`mkshim()` and SH1–SH5 for the SOPS/age trial, and `PROVINCE.md:93` records round 48 as "each test
flips under a falsifier shim (`plans/round-48-c1.sh`)". C1's SH1–SH5 is the same design against a
different CLI; `corpus/sops-age-trial.sh` itself carries no shim (`grep -n 'shim'` → empty), i.e. the
shim lives in the counter, which is exactly C1's split.

Sibling prior art is about PATH shims as an **attack on** a gate, not as a falsifier:

| lane:path:line | what it establishes | use for C1 |
|---|---|---|
| `chousa-shokunin/corpus/evidence/round35/c1-count.py:12-15` | S1 shim-first PATH, S2 `BASH_ENV` function shim, S3 PATH-less host — the three ways a PATH shim can intercept a CLI | the shim's reachability classes; C1's `env -i` + fixed PATH closes S2 by construction |
| `chousa-shokunin/corpus/evidence/round36/c1-count.py:17-20` | the same four cells as a counter's own arms | shape precedent: one cell per swap class |
| `chousa-shokunin/corpus/QUALITY.md:364-367`, `:448-452` | a "no PATH shim" claim that survived while `LD_PRELOAD` moved verdicts 4/7 and 3/7 | the residual class C1 must **not** claim to close |
| `chousa-shokunin/tools/research-gate.sh:508-511`, `:8642-8645` | a PATH `sha256sum` shim wrote hostile bytes into a manifest while the run stayed CLEAN | why the *real* run's output cannot be trusted to identify the binary it ran |
| `mado-shokunin/corpus/lessons/round-48.md:359` | "PATH shim fakes the replay judge — fixed (C2 v2 `/usr/bin/xkbcli`, clean env)" | the inverse case: there the shim was the cheat; here it is the falsifier. Same remedy (clean env + one binary) |
| `kotoba-shokunin/corpus/lessons/round-55.md:48` (M51) | "a PATH shim that bash's hash table bypassed" | **hazard**: a trial that caches `command -v bao` or calls `bao` before the shim is on PATH defeats SH1–SH5 |
| `kumitate-shokunin/scripts/cap-run.mjs:28-31` | a PATH shim under `/run/user/...` vanishes under `--tmpfs /run` | hazard only if a seat relocates the shim dir under `/run` |

---

## 3. Ownership partition — unchanged; one sibling citation is stale

kagi's partition, at the current revision:

- `PROVINCE.md:3` — "**Domain:** secrets & vault ops — the-janitor flows, credential hygiene evidence".
- `PROVINCE.md:83` — deliberate refusal: "vault-side structure … stays unmapped".
- `PROVINCE.md:89` — Core is "Vault/OpenBao token, lease and KV clocks
  (`knowledge/vault-openbao-token-lease-lifecycle.md`) … **none is deployed or probed on this host**".
- `PROVINCE.md:93` — the round-48 executed precedent: "SOPS/age access, rotation and key groups,
  executed: `corpus/sops-age-trial.sh` … and each test flips under a falsifier shim".
- `PROVINCE.md:94` — the standing sweep claim (re-confirmed in §1).

**Partition verdict: does not change.** C1 starts a throwaway `bao server -dev` on 127.0.0.1 with a
scratch root token, contacts no account, vault, service or real secret, and the domain line is
untouched. No sibling claims the ground; nothing is routed to another lane.

**One sibling citation is stale and should be reported, not edited.**
`kasegi-shokunin/.ufo/waves/round-23/build/OverlapVault.md:18` reads "Kagi owns secrets and vault ops
(`…/kagi-shokunin/PROVINCE.md:3`) and runtime auth plus credential custody (`:63`). Core there is
1Password machine-credential custody, SOPS/age rotation, and Vault/OpenBao token, lease, and KV
clocks (`:61`)." At the current revision `PROVINCE.md:61` is "Network surfaces:" — the Vault/OpenBao
clock line is now `:89`. The *ownership* claim is correct (`:3`); the *locator* drifted. Kasegi's
row is a historical artifact of its round 23 and is outside this lane's write scope; record it as a
cross-lane citation defect, do not absorb it.

**Cross-lane citations the lane should carry** (all from this scan, none currently in the corpus):

1. `chousa-shokunin/corpus/QUALITY.md:448-452` — the `LD_PRELOAD` residual that killed a sibling's
   "no PATH shim" claim. C1's named ceiling should cite it and say C1 closes S1/S2/S3 but **not**
   `LD_PRELOAD`/`BASH_FUNC_*` (its `env -i` drops the environment, which is the honest bound).
2. `kotoba-shokunin/corpus/lessons/round-55.md:48` — the bash hash-table bypass. A one-line "the
   trial invokes `bao` by bare name on every call and never caches `command -v`" constraint in the
   trial's header is the cheapest defence, and it is a fleet-known failure.
3. `mado-shokunin/corpus/lessons/round-48.md:359` — the inverse shim case (shim as cheat, fixed by
   absolute binary + clean env). C1 should state the inversion explicitly so a reader does not read
   C1's shims as the mado defect.
4. `tameshi-shokunin/corpus/knowledge/executable-self-assessment.md` (index `corpus/README.md:463`)
   and `souji-shokunin/PROVINCE.md:318-321` — the same-job calibration family for C2's method
   provenance (kotoba r62 F16 was raised precisely because this provenance was missing).

---

## 4. Second-order effects the plan's separability claim does not cover

The plan's separability argument is about *counters* ("C1's counter reads neither the stamps file nor
any self-count"). It is true. The *artifacts* are not separable, and four of the couplings below can
silently cost a claim.

### E1 — C1's entry append makes stamps row 55 STALE, and `stamp` refuses to shrink

`corpus/stamps.tsv:55` pins the entry:
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md  4932f37f…  176  12404`.
C1 appends `## Measured (round 49 …)` to that file, so the row goes STALE. `claim-ledger.sh:394-413`
replaces the **whole row set** and dies on any pinned path not named again ("refusing to shrink …
pass `--prune` to accept"). A seat that stamps only the entry drops 123 rows, which trips C2's G4
(`G4-stamp-rows-removed`) and the plan's kill rule "any ledger row loses its row".

Consequence: **one terminal restamp, naming all paths, after every claim's edits have landed.** The
C1 seat cannot do it alone — C2's edits to `SKILL.md`, `PROVINCE.md`, `corpus/README.md` and the iso
entry re-stale their own rows (`stamps.tsv:123`, `:120`, `:96`; the iso entry has **no** row today).

### E2 — C2's target number is 124, not 123

The plan's prose says "the three stamp counts set to the live count", and the live count at BASE is
123 (`grep -vc '^#' corpus/stamps.tsv` → 123). But the C2 fix also **adds a stamp row** for the iso
entry (R14-01's `unpinned=1`), so the live count after the fix is **124**. The frozen reference does
it in this order and only this order — `plans/round-49-controls.sh:44-55`:

```
fix_docs()   # appends the iso row to stamps.tsv, then rewrites README 33/3/36
fix_stamps() # n=$(grep -vc '^#' stamps.tsv); writes $n into SKILL:46, PROVINCE:73, README:65
gclone k2-p; fix_docs k2-p; fix_stamps k2-p   # K2-P observed 0
```

A seat that writes 123 (the BASE count) while also adding the iso row reads
`SC-SKILL-STAMPS=STALE PV-STAMPS=STALE RD-STAMPS=STALE` → `value=3`, and K2-F4's expected 3 becomes
indistinguishable from the honest attempt. This is the single most likely way to lose C2.

### E3 — R12-03 is already red at BASE, and C2 makes its delta worse

`corpus/claim-ledger.tsv:28` — `R12-03  grep -c '[^[:space:]]' corpus/stamps.tsv  ^122$  exit 0`.
Measured now: **123** (stamps.tsv has 0 comment lines). So R12-03 is **FAIL at BASE**, and after E2 it
reads **124** — the row's delta from its pin grows from 1 to 2.

The three self-count keys do not see this: `corpus/self-counts.tsv:20,39,52` bind SC-SKILL-STAMPS,
PV-STAMPS and RD-STAMPS to `ledger:R12-03`'s **output**, not its verdict. So C2 can read `value=0`
(six keys OK) while the ledger's own stamp-membership row is further from its pin than at BASE.
That is a calibration claim that improves the six keys and degrades the row they read — state it, do
not smooth it.

The plan does not name R12-03 anywhere (`grep -n 'R12-03' plans/round-49*.md plans/round-49-c2.sh
plans/round-49-controls.sh` → only `corpus/self-counts.tsv` rows).

### E4 — two more red rows at BASE that the plan does not enumerate

Measured directly (each row's own command, no `verify`):

| row | command | expect | live | verdict |
|---|---|---|---|---|
| `R13-01` (`claim-ledger.tsv:29`) | `grep -c '^## Round ' SCORECARD.md` | 56 | **66** | FAIL at BASE |
| `R18-02` (`claim-ledger.tsv:49`) | `grep -cE '[[]substrate[]]' corpus/claim-ledger.tsv` | 11 | grep parse error, rc=2 | FAIL at BASE **on this host only** (`pi-uu-grep 0.2.0` rejects the ERE; the intent `grep -cE '\[substrate\]'` returns 11) |
| `R12-03` (`claim-ledger.tsv:28`) | see E3 | 122 | 123 | FAIL at BASE |
| `R25-02` (`claim-ledger.tsv:81`) | `python3 corpus/self-counts.py` | `CLEAN (claims=60 stale=0)` | `POLICY (claims=63 …)`, rc=2 (`controls/c2-base.txt`) | FAIL at BASE, frozen by the round's kill rule |

`corpus/QUALITY.md:154-160` (QM32) requires a plan that touches a gate to enumerate **every** red row
that gate prints at BASE, from a measured run committed with the plan, and to name each as claimed or
routed. Round 49's kill rule names R25-02, R29-01 and R29-02 only. R12-03, R13-01 and R18-02 are
unnamed. R13-01/R18-02 are outside this round's claims (route them); R12-03 is *inside* C2's surface
(E3) and cannot be routed without saying so.

### E5 — `verify` cannot be green at the tip, so the kill rule needs an explicit reading

The C2 kill rule reads "the round's ledger verify reads a STALE stamp the candidate created and did
not restamp". At the tip, `verify` still prints FAIL on R25-02 (frozen: the kill rule says R25-02 must
not change state or expectation), R13-01 and R12-03, and POLICY on R29-01/R29-02. The admissible
reading is **"no `STALE`/`MISSING`/`NOT-A-FILE` stamp line"**, not "exit 0". A seat that chases exit 0
by editing R25-02's `claims=60` fires the kill rule; a seat that reads exit 0 as required will report
a false failure. The report must state which reading it used.

### E6 — the entry will contradict itself unless the appended section carries a scope sentence

C1's kill rule forbids deleting any line present at BASE
(`git diff BASE <candidate> -- <entry> | grep -cE '^-[^-]'` = 0). Two BASE lines then remain false
once the trial runs:

- `:9` "Scope: vendor documentation only; nothing was deployed or probed."
- `:74-78` "kagi runs neither product …" and the `## Does not establish` bullet "no vault or account
  was contacted".

The round-48 precedent (`PROVINCE.md:93`) shows the shape the lane uses: a new bullet that states
what was executed and its bounds, leaving the older text standing. C1's `## Measured (round 49 …)`
section therefore needs its own scope sentence — throwaway in-memory `bao server -dev` on 127.0.0.1,
random root token in scratch only, no account/vault/real secret, one host, one release — or the entry
says both "nothing was probed" and "T1–T5 measured". The reference fixture's section
(`controls/fixtures/entry-measured.ref.md`) has five `- T<n> … (OpenBao 2.7.2)` lines and **no scope
sentence**; the counter does not require one, so this is a prose defect the counter cannot catch.

### E7 — shim-design constraints the reference already satisfies (state them, don't rediscover them)

From `controls/fixtures/openbao-token-trial.ref.sh:30-36`: `HOME` is scratch, the port comes from a
socket bound to `127.0.0.1:0`, the root token is `r49-<24 hex>` (which is exactly the NOSECRET
pattern the counter greps for, so any echo of it fails the run), and `BAO_ADDR`/`BAO_TOKEN` are
exported per run. The trial must invoke `bao` by **bare name** on every call (E-hazard, kotoba M51);
`env -i` in the counter already drops `BASH_ENV`, `LD_PRELOAD` and exported functions, which is the
bound C1 can honestly claim.

---

## 5. Proposed move (one, bounded)

**Give the terminal restamp to the C2 seat, and make it a declared step with the count recomputed
after the iso row lands — including a declared migration of R12-03 to the same number.**

Concretely, one ordered step at the end of the wave, owned by whoever lands C2:

1. land C1's entry append and C2's doc/entry edits;
2. append the iso entry's stamp row (R14-01's `unpinned=1`);
3. `n=$(grep -vc '^#' corpus/stamps.tsv)` → 124; write `124` into `SKILL.md:46`, `PROVINCE.md:73`,
   `corpus/README.md:65` (by content, not by line number — the reference's `sed -i "46s/…"` is a
   fixture convenience);
4. migrate `R12-03`'s expect `^122$` → `^124$` with a note naming the BASE drift (122 stated / 123
   held) — a migration whose value is re-derived from the file, not an expectation edited to hide a
   defect;
5. one `stamp` invocation naming **all 124 paths** (`cut -f1 corpus/stamps.tsv`), then
   `verify | grep -E '^(STALE|MISSING|NOT-A-FILE)'` → 0 lines.

**Axes.** Calibration: C2 reaches 0 *and* the ledger row that the six keys read stops disagreeing
with the file (today it disagrees by 1; without step 4 it would disagree by 2). Operability: C1's
entry stays stamped, so its measured section is admissible and the round does not carry a STALE row
it created. Neither axis is harmed: C1's counter reads neither `stamps.tsv` nor the ledger; C2's G1/G2
freeze `self-counts.py`, `claim-ledger.sh` and six `self-counts.tsv` rows — `claim-ledger.tsv` is not
frozen; R25-02/R29-01/R29-02 are untouched, so no kill rule fires.

**Why it is not the obvious move.** The plan treats C1 and C2 as separable because their counters do
not read each other. The stamps row is the one artifact both claims touch, and it is read by the
gate's kill rule, not by either counter. The seat that can see it is the one holding the stamps
counter — not the one that edited the entry.

**Risks.**
- Restamp churn: any edit after the restamp re-stales a row. The restamp must be the last write before
  the measured revision.
- The 124/123 misread (E2) is the most likely single failure; the count must be computed, never
  typed from the plan's "123".
- Step 4 is an expectation change and must be *declared* as a migration with its BASE drift named;
  done silently it is exactly the "changing an expectation to force green" refusal in `SKILL.md:46`.
- If the wave decides R12-03 is out of scope, it must route it explicitly (QM32) and say that C2's
  `value=0` does not certify the stamp membership row.

---

## 6. Verification (not run by this seat)

| check | command | expected |
|---|---|---|
| C1 | `bash plans/round-49-c1.sh <rev>` | `C1_OPENBAO_TRIAL: value=5 … setup_ok=1 nosecret=1` |
| C2 | `bash plans/round-49-c2.sh <rev>` | `C2_SELF_COUNTS: value=0 keys=6 …` |
| stamp count | `grep -vc '^#' corpus/stamps.tsv` | `124` |
| R12-03 | `grep -c '[^[:space:]]' corpus/stamps.tsv` vs `awk -F'\t' '$1=="R12-03"{print $3}' corpus/claim-ledger.tsv` | `124` vs `^124$` |
| no stale stamps | `bash corpus/claim-ledger.sh verify 2>&1 \| grep -E '^(STALE\|MISSING\|NOT-A-FILE)'` | 0 lines (FAIL on R25-02/R13-01/R12-03 may remain; name them) |
| entry append-only | `git diff 89afe91878f10805921d3caa67d28d21b33226da <rev> -- corpus/knowledge/vault-openbao-token-lease-lifecycle.md \| grep -cE '^-[^-]'` | `0` |
| no token shape committed | `git grep -nE 'r49-[0-9a-f]{24}' <rev>` | empty |

---

## 7. Refusals and bounds observed

No write outside `.ufo/waves/round-49/build/K49Connector*` and
`/fast/scratch/hyaku/kagi-r49/K49Connector/`. No git mutation. No `bao` started, no vault, account,
`op`, `~/.ssh` or `~/.config/sops` contact. No sibling tree written. `claim-ledger verify`,
`self-counts.py` and both counters were not run (seat bounds); §4's red rows are direct measurements
of the rows' own cheap commands, and the plan still owes its own measured BASE enumeration (QM32).
