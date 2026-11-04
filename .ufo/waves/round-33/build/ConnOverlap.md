# ConnOverlap — round-33 sibling-overlap scan (read-only)

Seat: `ConnOverlap-9`, connector 1/1, wave `kagi-r33-build`, round 33. Lane `kagi-shokunin`
at frozen BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`; frozen claims contract
`plans/round-33.md` (commit `880824b`), read first. No lane file, sibling file, sibling gate,
scratch repo or vault path was written or executed. Every path below is absolute; every
command was a `grep` / `find` / `sed` read from `/home/vgpnk/Projects/shokunin`.

Receipts: `ConnOverlap-receipts.txt`, same directory (394 lines, sections R1–R12). Every
count in this report is a line in that file with its command above it.

Scope: every `/home/vgpnk/Projects/shokunin/*-shokunin` except `kagi-shokunin` — **20 lanes**
(`audio`, `chousa`, `game-dev-2d`, `game-dev-3d`, `kaidoku`, `kake`, `kama`, `kasegi`,
`kengaku`, `kotoba`, `kotodama`, `kumitate`, `lore`, `mado`, `mori`, `revenger`, `souji`,
`tabi`, `tameshi`, `tsukuroi`). `kumitate-shokinin` is a different directory (misspelled) and
does not match `*-shokunin`; it is out of scope by the glob.

Bounds honoured: read-only git only (`rev-parse` on the lane); no sibling gate executed; no
`op` subcommand beyond `--version` (`2.41.1`, host handler absent as expected); no network; no
scratch clone needed (all evidence is committed bytes in the lanes).

---

## 1. Answers

**Q(a) Does any sibling claim NIST key-management ground (SP 800-57 / 800-131A / 800-133 /
`key-management`)? — No. 0 of 20.**

No sibling holds any member of the key-management document family in any of the four scanned
classes. The family scan (SP 800-56/57/108/131/133/152, FIPS 140/186/197) returned `<none>`
for all 20 lanes (receipt R3). The six lanes with *any* NIST-term hit hold five other NIST
documents — SP 800-115, SP 800-216, SP 800-122, SP 800-92, FIPS 180-4 — plus NIST-hosted
distribution surfaces (NVD API, CFTT, csrc), and one false positive (receipts R2, R11).

**Q(b) Does any sibling already run a prefreeze-control equivalent? — Yes, one.** `kasegi`
holds `corpus/instruments/freeze-check.py` (round 44/45), whose stated predicate is the same
class as C1: *replay the declared base value against the claim's own counting command at the
frozen base and refuse the freeze unless they agree*. Four lanes carry weaker base-revision
checks: class B (`kasegi` closure suites, `kumitate` `harm-matrix`, `tabi`
`check-round-contract`, `kake` base guards) compares a declared expectation against a base
revision but never a per-counter declared number; class C (`chousa`, `souji`, `kaidoku`,
`revenger`) reads git objects only to check freeze ordering, digests or instrument pins.
Twelve lanes hold no in-scope gate at all. Detail in §3.

**Contested ground.** One capability-class overlap (§4.1: kasegi `freeze-check.py` vs. the
C1 claim at `plans/round-33.md:32`). Zero source-ground overlap for C2. Not adjudicated here.

---

## 2. Q(a) — NIST ground, per lane

Command (receipt R1; the block below is abridged — R1 carries the exact loop and its output), run
in `/home/vgpnk/Projects/shokunin`:

    for l in *-shokunin; do [ "$l" = kagi-shokunin ] && continue
      grep -cE 'NIST|800-57|800-131A|800-133|key-management' "$l"/{PROVINCE.md,SKILL.md,corpus/SOURCES.md}
      grep -rhE 'NIST|800-57|800-131A|800-133|key-management' "$l/corpus/knowledge" | wc -l
    done

Columns: `P` = `PROVINCE.md` lines, `S` = `SKILL.md` lines, `Src` = `corpus/SOURCES.md` lines,
`K` = `corpus/knowledge/` matching lines. A `0` here is a measurement, not an omission.

| lane | P | S | Src | K | NIST document actually held | summary |
|---|---|---|---|---|---|---|
| audio-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| chousa-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| game-dev-2d-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| game-dev-3d-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| kaidoku-shokunin | 0 | 0 | 0 | 0 | — (FIPS 180-4 and a GnuPG manual live in `.ufo`, §2.3) | no NIST ground in the four classes; no key-management ground. |
| kake-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| kama-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| **kasegi-shokunin** | **2** | 0 | **7** | **27** | SP 800-115, SP 800-216, NVD API 2.0 | **NIST-owning lane, different subfield**: vulnerability disclosure + CVE retrieval. Not key management. |
| kengaku-shokunin | 0 | 0 | **2** | **1** | Terminal-Bench openssl task (S218), + 1 false positive | key management appears only as a *graded task surface*, already disambiguated by a prior sweep (§2.2). |
| kotoba-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| kotodama-shokunin | 0 | 0 | 0 | **6** | SP 800-92, FIPS 180-4 | NIST-owning lane, different subfield: log management + hash standard. Not key management. |
| kumitate-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| lore-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| mado-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| **mori-shokunin** | 0 | 0 | **4** | **3** | SP 800-122 | **NIST-owning lane, different subfield**: PII minimisation. Not key management. |
| **revenger-shokunin** | 0 | **1** | **4** | **9** | FIPS 180-4, CFTT methodology | **NIST-owning lane, different subfield**: digest scope + tool validation. Not key management. |
| souji-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| tabi-shokunin | 0 | 0 | 0 | 0 | — (SP 800-131A appears in a captured `.ufo` page, §2.3) | no NIST ground in the four classes; no key-management ground. |
| tameshi-shokunin | 0 | 0 | 0 | 0 | — | no NIST ground; no key-management ground. |
| tsukuroi-shokunin | 0 | 0 | 0 | **1** | — (DKMS key trust, false positive for this ground) | no NIST ground; no key-management ground. |

Totals: `P`=2, `S`=1, `Src`=17, `K`=47 — all in six lanes; 14 lanes are 0/0/0/0.

### 2.1 Owning sentences, quoted (the six non-zero lanes)

**kasegi — NIST is the CVE/vulnerability-disclosure ground, not keys.**
`PROVINCE.md:192`: “*F33 — NVD API 2.0 (NIST's read-side retrieval interface over the
NVD-enriched CVE record …)*”; `PROVINCE.md:195` F34 is the NVD response schema. Registry:
`corpus/SOURCES.md:25` “*S019 | NIST SP 800-216, Recommendations for Federal Vulnerability
Disclosure Guidelines*”; `:38` “*S032 | NIST SP 800-115, Technical Guide to Information
Security Testing and Assessment*”. Entries: `corpus/knowledge/nist-sp800-216-vdp-framework.md:1`
and `corpus/knowledge/nvd-api-2.0-retrieval-interface.md:1`. No 800-57 / 131A / 133 anywhere.

**mori — PII minimisation.** `corpus/SOURCES.md:57` “*S051 | NIST SP 800-122, Guide to
Protecting the Confidentiality of Personally Identifiable Information (PII)*”; the same
document repeats as `S208` at `:214`. Entry: `corpus/knowledge/evidence-minimization-r18.md:16`
(“*… and NIST's minimum-necessary …*”). Not key management.

**revenger — digest scope and tool validation.** `corpus/SOURCES.md:18` “*S004 | NIST CFTT
Methodology Overview*”; `:20` “*S006 | NIST FIPS PUB 180-4 Secure Hash Standard*”.
`SKILL.md:407`: “*| S007 | `corpus/SOURCES.md` (NIST CFTT report index) | where version-scoped
reports live (tool-claim path) |*”. Entry: `corpus/knowledge/digest-scope-versus-provenance.md:2`.
Not key management.

**kotodama — logging and hashing.** `corpus/knowledge/verification/append-only-record-verification.md:17`
“*KTD-AR-S-0012 — NIST SP 800-92, Guide to Computer Security Log Management (2006)*”;
`corpus/knowledge/verification/gate-frozen-run-standard.md:10` “*KTD-FR-S-0006 — NIST (2015).
Secure Hash Standard (SHS), FIPS PUB 180-4*”. Not key management.

**kengaku — a benchmark task that happens to grade OpenSSL key handling.** `corpus/SOURCES.md:233`
“*S218 | Terminal-Bench 2.0 openssl-selfsigned-cert task definition … declares the graded
objective (a self-signed TLS certificate built with OpenSSL under key-permission, subject and
validity constraints, plus a verification script)*”. This is the nearest semantic neighbor to
“key management” in the fleet, and it is a *graded task surface*, not guidance ground.

**tsukuroi — false positive.** `corpus/knowledge/kernel-taint-r27.md:33`: “*… Trusting it is a
key-management decision for the operator*” — DKMS module-signing key trust. Matched word is
`key-management`, the referent is kernel module signatures, and no NIST document is cited
(R11). Not the NIST ground.

### 2.2 A prior fleet sweep already separated these subfields

`kasegi-shokunin/.ufo/waves/round-40/wave2/ScoutSiblingFinal.md:51` (sibling's own artifact,
read-only): “*`kagi`/`revenger`/`mori`/`kotodama` corpus hits are NIST SP 800-57 / FIPS 180-4 /
SP 800-122 / SP 800-92 / CFTT citations (different NIST documents; none is SP 800-216)*”.
This round's independent scan reproduces that partition exactly and isolates one fact the
scout's grouped sentence leaves implicit: **the SP 800-57 hits are in kagi only** — no sibling
holds an 800-57 row, entry, or province line (R3).

`kasegi-shokunin/.ufo/waves/round-23/build/OverlapVault.md:18`: “*Kagi owns secrets and vault
ops … Kagi's own frontier is OIDC, secret-scanning detection vs verification, and NIST key
management (`kagi-shokunin/corpus/README.md:110-112`), not bounty safe harbor.*” A prior
connector verdict already assigns this ground to kagi, citing kagi's own README Frontier
lines. Nothing in the fleet contradicts it.

`kengaku-shokunin/.ufo/waves/round-65/w1/SiblingOverlap.md:97` records the reciprocal ruling
for the nearest homonym: “*kagi-shokunin/.ufo/waves/round-30/ConnOverlap-report.md:64,228
clears "kengaku 'key management'" as "OpenSSL key management **as a benchmark grader surface**
(Terminal-Bench `openssl-selfsigned-cert` task)" — kagi explicitly classifies this as kengaku's
ground and does not claim it.*” So the two “key management” senses were already bounded in
round 30 from kagi's side.

### 2.3 Explicit non-claims (captured bytes, not citations)

- `tabi-shokunin/.ufo/waves/round-43/sources/crypto.html:7021` — “*Based on the recommendations
  of NIST SP 800-131A*” — a captured dependency documentation page inside a wave source dir.
  No registry row, no entry, no province line references it (R1 shows `tabi` P/S/Src/K all 0).
- `kaidoku-shokunin/.ufo/waves/round-78/l1/sources/gnupg-manual.html:1600,1602,1612,2748,3274,3276,3332`
  — the GnuPG manual's “good key management” prose, same status: captured bytes in `.ufo`.
- `tsukuroi-shokunin/.ufo/waves/round-19/l1-capture/siblings/kagi/c2cab35bc92e/PROVINCE.md:62`
  — a **capture of kagi's own PROVINCE.md** carrying kagi's Frontier line (“NIST
  key-management draft status”). This is an echo of kagi's claim inside a sibling's evidence
  tree, not a competing claim; it will go stale when C2 removes `PROVINCE.md:90`.

### 2.4 The kagi side of the claim (for comparison, not scored)

- `PROVINCE.md:90` — “*Frontier — explored, not held: NIST key-management draft status
  (`corpus/README.md` §Frontier; leads in `corpus/SOURCES.md` §Leads (unopened)).*”
- `corpus/README.md:117` — “*NIST key-management draft status — distinguish final guidance
  from IPDs before adopting controls; see `SOURCES.md` §Leads (unopened), SP 800-57 Rev.
  5/Rev. 6 and SP 800-133 Rev. 3.*”
- `corpus/knowledge/nist-*.md` = **0** (R10); registry rows = **72**; `corpus/prefreeze-control.sh`
  absent (`test -e` exit 1).
- Context worth stating: the registry already carries two status-only rows for the same
  document — `corpus/SOURCES.md:56` S049 and `:58` S051 (“*SP 800-57 Part 1 Rev. 6, Initial
  Public Draft … publication status only … no Rev. 6 final at fetch*”), referenced at
  `corpus/README.md:245`. So C2 converts an existing *lead row* into *entries*, it does not
  create the first 800-57 mention. Both BASE readings the plan declares (0 entries, 72 rows,
  1 Frontier NIST line) reproduce exactly (R10).

---

## 3. Q(b) — prefreeze-control equivalents, per lane

Primary command (receipt R5) — the seat's own filter, run per lane:

    for f in $(grep -rIl 'git archive' <lane>/corpus <lane>/scripts); do
      case "$f" in *.sh|*.py|*.mjs|*.js) ;; *) continue;; esac
      case "$f" in */live/*|*/mut/*) continue;; esac
      grep -qE 'expect|control|declared|claim' "$f" && echo "$f"; done

Secondary (R6, executable `--base` takers under `corpus/` and `scripts/`, excluding
`live/`, `mut/`, `evidence/`, `source-snapshots`); tertiary (R7, instruments named
`*freeze-check*` outside `.ufo`). `.ufo/` wave receipts were excluded throughout: a seat's
per-round receipt is not a lane gate.

| lane | in-scope gate(s) found | class | one-line summary |
|---|---|---|---|
| audio-shokunin | none (`R5: <none>`) | — | `git archive` appears only in `corpus/live/*` receipts and a fixture's prose; no gate. |
| chousa-shokunin | `tools/freeze-check.py` (R7; outside `corpus/`/`scripts/`) | C | claims/spec/dispatch **digest consistency** at pre-ready; no base extraction, no value replay. |
| game-dev-2d-shokunin | none (`R5: <none>`) | — | no gate. |
| game-dev-3d-shokunin | none (`R5: <none>`) | — | no gate. |
| kaidoku-shokunin | `tools/round-30/prefreeze-gate.py` (R7/R9; outside scope dirs) | C | **name** match only: freeze-ordering + instrument sha256 pins at the freeze commit; no declared-value replay. |
| kake-shokunin | `scripts/append_guard.py`, `scripts/ledger_append_guard.py`, `scripts/doc_quote_truth.py` | B/C | base-vs-revision **byte** guards and claim-row presence at `--base`; no counter remeasurement. |
| kama-shokunin | none (`R5: <none>`) | — | no gate. |
| **kasegi-shokunin** | **`corpus/instruments/freeze-check.py`** + `r-defect-closure.sh`, `r35`–`r41-closure.sh`, `r43-closure.sh`, `r43-limbs/k19-freeze.sh` | **A** + B | **The equivalent**: declared base value replayed against the claim's own counter at the frozen base tree. Closure suites add a fixed `BASE_REF` + `git archive` export + declared-blocks and base-digest pins. |
| kengaku-shokunin | none (`R5: <none>`) | — | no gate. |
| kotoba-shokunin | none (`R5: <none>`) | — | no gate. |
| kotodama-shokunin | none (`R5: <none>`) | — | no gate. |
| kumitate-shokunin | `scripts/harm-matrix.mjs` (+`harm-matrix-gates.json`), `scripts/plan-before-ready.sh`, `scripts/counter-pins.mjs`, `scripts/counter-rerun.mjs`, `scripts/control-replay.mjs`, `scripts/receipt-evidence.mjs` | B | closest *mechanism*: runs 36 lane gates at `--base REV` and `--tip REV` in sandbox clones and grades HELD/REPAIRED/HARM; **base reading is derived, not declared**. |
| lore-shokunin | none (`R5: <none>`) | — | no gate. |
| mado-shokunin | none in `corpus/`/`scripts/` (`R6: <none>`) | — | per-round `.ufo/waves/round-67/controls/score-baseline-c{1,2}.py --base` exists but is a round receipt, out of scope. |
| mori-shokunin | none (`R5: <none>`) | — | no gate. |
| revenger-shokunin | `corpus/self_assessment_check.py` | C | `git archive <commit> corpus …` then checks claim citations name a resolving `base`/`tip`; no value replay. |
| souji-shokunin | `tools/souji-freeze-check.py` (R7/R9b) | C | prereg read as the blob at `--rev`; `CONTROL-NOT-RED` requires the declared control be red at base; no remeasurement. |
| tabi-shokunin | `scripts/check-round-contract.mjs`, `check-decision-table.mjs`, `check-bidi-runtime.mjs`, `check-user-round-contract.mjs` | B/C | hard-pinned `HARD_BASELINE` + `--expect N` + census sha256; counts structural rounds, not a declared counter value. |
| tameshi-shokunin | none (`R5: <none>`); holds an **inventory of kagi's** gates (§3.4) | — | no gate of its own; its survey lists kagi's six gates and none is a base-value gate. |
| tsukuroi-shokunin | none (`R5: <none>`) | — | no gate. |

Class key — **A** = same predicate class (declared base value vs. the value its own command
measures at the base); **B** = runs controls at a base revision and compares a declared
expectation, but not a per-counter declared value; **C** = extracts a revision / reads git
objects only to check freeze ordering, digests or instrument pins; **—** = none.

Counts: A=1 lane, B=4 (kasegi also, kumitate, tabi, kake), C=4 (chousa, souji, kaidoku,
revenger), none=12 lanes.

### 3.1 The equivalent, stated exactly (kasegi `freeze-check.py`)

`corpus/instruments/freeze-check.py` (sha256 `6809c99c…`, 394 lines; registry row at
`corpus/instruments/README.md:995`). Its own docstring:

> “*Round-44 defect it closes: a counter frozen as `grep -cE '^\\| F[0-9]+ \\| admitted \\|'
> corpus/README.md` printed 0 at the base AND after landing, because the status is the third
> table cell, so the frozen claim could never go green. The claim text was never replayed at
> the freeze commit. This tool replays every claim's `counter_cmd` at the base tree and refuses
> the freeze unless the counter reads exactly what the claim says.*”

Per claim it runs `counter_cmd` rendered with `{tree}`/`{base}`, and requires: some output
line **equals** `expect_before` (whole line, never substring), **no** output line contains
`expect_after` (the do-nothing guard), `expect_before != expect_after`, ids unique, and the
base tree left byte-identical (`FC-BASE-MUTATED`). Exit 0 only when every claim replays.
Selftest prints `selftest cases=27 failures=0`.

Differences from the C1 target, stated as facts and not as a verdict:

| axis | kasegi `freeze-check.py` | kagi `corpus/prefreeze-control.sh` (plan `:36-46`) |
|---|---|---|
| base input | `--base DIR`; **extraction is the caller's job** | extracts the named **revision internally** with `git archive` |
| controls file | claim schema (JSON/markdown `counter_cmd`, `expect_before`, `expect_after`) | TSV `id<TAB>expect<TAB>command` |
| comparison | whole-line equality to a string | last non-empty stdout line's **final integer** vs `expect` |
| do-nothing guard | in-gate: `expect_after` must be **absent** at base | not in-gate; the plan's do-nothing control is the BASE reading (`plans/round-33.md:67-68`) |
| mutation guard | base tree must be byte-identical after the run | `$TMPDIR` extraction, so the base cannot be touched |
| provenance of the red witness | its own 27-case selftest | replay of `plans/round-32.controls.tsv` at `32c35fe` → MISMATCH 2/2 |

So the class exists in the fleet; the *input shape, extraction ownership, comparison operator
and red-witness target* are all different. Whether that makes round-33's C1 a duplication or a
distinct capability is the L1's call — this seat does not adjudicate.

### 3.2 The mechanism neighbor, stated exactly (kumitate `harm-matrix.mjs`)

`scripts/harm-matrix.mjs` (contract `kumitate-harm-matrix-v2`, round 65) “*runs a registry of
the lane's gates at BASE and at TIP, each revision in its own sandbox clone … and prints one row
per gate with the transition: HELD · REPAIRED · HARM · HARM_ABSENT · NEW_OK · NEW_RED · GONE ·
CARRIED · CARRIED_MOVED*”. Registry: 36 gates (`scripts/harm-matrix-gates.json`).

It is the closest *operational* neighbor to “run the controls at BASE”. It is **not** the same
predicate: it takes the BASE reading as given (it measures it) and grades the base→tip
transition, so a *hand-declared* BASE value that is wrong — the M32-2 defect C1 exists to catch
(`plans/round-33.md:32-34`, lesson R32-2/QM34) — is invisible to it. It also cannot produce a
red witness on a *prior* round's plan.

### 3.3 Freeze gates that only look like the target

- `kaidoku/tools/round-30/prefreeze-gate.py` — the only fleet file whose *name* matches
  `prefreeze`. It checks freeze ordering (instrument/`frozen_inputs` paths exist at the freeze
  commit with the same sha256; evidence files not present at or before the freeze; `tools/`
  paths named in a claim pinned), reading git objects only. No declared-value replay.
- `souji/tools/souji-freeze-check.py` — `CONTROL-NOT-RED` is the sharpest near-clause: the
  prereg's `Control:` path must print a last line `EXIT=<nonzero>` **at the base**. That is a
  red-state assertion, but on a control receipt, not on a declared counter value.
- `chousa/tools/freeze-check.py` — `CLAIMS_NONEMPTY`, `CONTEXT_DIGEST`, `DIGEST_STRAY`,
  `CONTEXT_SPEC_EQ`: digest agreement between claims / spec / dispatch, not measurement.
- `kumitate/scripts/counter-pins.mjs` — sha256 byte pins on counters; `counter-rerun.mjs`
  compares a counter's final summary line **across K runs** (and explicitly disclaims
  correctness: “*never this counter's site-level reading is correct*”); `control-replay.mjs`
  pins control scripts by sha256 and replays them.

### 3.4 A sibling inventory of *kagi's* gates (corroboration, not a competitor)

`tameshi` holds four `*kagi*` knowledge entries (`tameshi-shokunin/corpus/knowledge/`:
`gates-survey-kagi.md` 619 lines, `mutation-case-kagi-{census,checklist,drift-pins}.md`) — a
read-only survey and three mutation cases on kagi's own gates. `gates-survey-kagi.md:19` is
titled “*What the six gates are, in one table*” and lists `surface-census.sh`,
`drift-pins.sh`, `op-ref-probe.sh`, `checklist-run.sh`, `scope-gate.sh`, `claim-ledger.sh` at
kagi HEAD `4e48b77` (2026-10-14). None is a base-value control, and the file contains **0**
occurrences of `prefreeze` / `pre-freeze` / `git archive` (R12).

This is corroboration that kagi's gate inventory as a *sibling measured it* had no
base-value gate — i.e. the C1 “nothing” reading is not merely a `test -e` on one path. It is
also a live dependency: `mutation-case-kagi-drift-pins.md` cites kagi rows by blob sha256, so a
future edit to a surveyed kagi gate is visible from tameshi's side.

---

## 4. Contested ground — stated, not adjudicated

### 4.1 Capability class: kasegi `freeze-check.py` vs. kagi C1

| side | file:line | what it says |
|---|---|---|
| sibling | `kasegi-shokunin/corpus/instruments/freeze-check.py:2-12` | “*replay a kasegi-round-claims-v2 file against the frozen base … refuses the freeze unless the counter reads exactly what the claim says*” |
| sibling, registry | `kasegi-shokunin/corpus/instruments/README.md:995` | gate row with the exact pass/fail contract and `selftest cases=27 failures=0` |
| kagi | `kagi-shokunin/plans/round-33.md:32` | “***What exists now:** nothing. `test -e corpus/prefreeze-control.sh` → exit 1 at BASE.*” |
| kagi | `kagi-shokunin/plans/round-33.md:46` | “*PREFREEZE: CLEAN (controls=N mismatch=0) — every declared BASE value equals the value its own counting command measures on the extracted BASE tree.*” |
| kagi | `kagi-shokunin/.ufo/waves/round-25/build/ConnSiblings2.md:20,39` | a prior kagi connector already read `kasegi/corpus/instruments/resolve.py`; the instruments directory has been screened before, but `freeze-check.py` was not named. |

Reading of the text, no verdict: the C1 “nothing” sentence is **lane-scoped** (`test -e` on
kagi's own path) and is literally true (R10 confirms `exit=1`). The *capability* sentence in
the plan's title (“capability acquisition”) is the part the sibling artifacts touch, because
kasegi has held an executable of that class since round 44/45. Both statements can be true at
once; the record should say which one the round is claiming.

### 4.2 Source ground: none

No sibling holds SP 800-57, 800-131A, 800-133, `key-management` guidance, or any member of the
key-management document family in `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` or
`corpus/knowledge/` (R3: `<none>` on all 20). No sibling registry row exists to be duplicated
or to duplicate kagi's S073–S082. Kagi's own two 800-57 status rows (`corpus/SOURCES.md:56,58`)
are lane-internal and are not duplicated anywhere else in the fleet.

---

## 5. Per-lane detail (the compact record)

Each row: `P/S/Src/K` from R1 → quote or `0` → gate → summary.

1. **audio** — `0/0/0/0` (`R1`). Gate: `R5: audio-shokunin: audio-shokunin/corpus/fixtures/measure_audio.py` only, and that hit is prose (`expected 48kHz mono`) in a 56 712-line fixture, not a base gate. Summary: neither ground.
2. **chousa** — `0/0/0/0` (`R1`). Gate: `tools/freeze-check.py` (R7), class C — pre-ready digest agreement. Summary: no NIST ground; a freeze gate, not a base-value gate.
3. **game-dev-2d** — `0/0/0/0` (`R1`). Gate: `R5: <none>`. Summary: neither ground.
4. **game-dev-3d** — `0/0/0/0` (`R1`). Gate: `R5: <none>`. Summary: neither ground.
5. **kaidoku** — `0/0/0/0` (`R1`). `.ufo` only: `gnupg-manual.html` “key management” prose (§2.3). Gate: `tools/round-30/prefreeze-gate.py`, class C / name-only (§3.3). Summary: no NIST ground; the `prefreeze` name is a freeze-ordering gate.
6. **kake** — `0/0/0/0` (`R1`). Gate: `append_guard.py` (“*committed bytes of every in-scope regular blob at `--base` against `--revision`*”), `ledger_append_guard.py`, `doc_quote_truth.py` (“*A1 claim row present at `--base` (exact text) and gone at the measured …*”) — class B/C, byte and text presence, no counter replay. Summary: no NIST ground; adjacent base guards.
7. **kama** — `0/0/0/0` (`R1`). Gate: `R5: <none>`. Summary: neither ground.
8. **kasegi** — `2/0/7/27` (`R1`), quotes §2.1. Gate: **class A** `corpus/instruments/freeze-check.py` + class B closure suites (`r41-closure.sh` fixes `BASE_REF=5b29ea14…`, exports with `git archive`, and validates `declared-blocks.txt` plus a base digest pin). Summary: **owns a different NIST subfield; holds the only true equivalent of the C1 class**.
9. **kengaku** — `0/0/2/1` (`R1`), quote §2.1; `K` hit is the `DETERMI**NIST**IC` false positive (R11). Gate: `R5: <none>`. Summary: no NIST ground; key management only as a graded OpenSSL task surface, already bounded in round 30/65.
10. **kotoba** — `0/0/0/0` (`R1`). Gate: `R5: <none>`. Summary: neither ground.
11. **kotodama** — `0/0/0/6` (`R1`), quotes §2.1. Gate: `R5: <none>`. Summary: NIST-owning lane, log-management/hash subfield.
12. **kumitate** — `0/0/0/0` (`R1`). Gate: `harm-matrix.mjs` (+5 scripts), class B (§3.2). Summary: no NIST ground; the closest base-matrix mechanism, with a derived (not declared) base reading.
13. **lore** — `0/0/0/0` (`R1`). Gate: `R5: <none>`. Summary: neither ground.
14. **mado** — `0/0/0/0` (`R1`). Gate: `R5`/`R6` `<none>` in scope; per-round `.ufo/waves/round-67/controls/score-baseline-c{1,2}.py --base` is a round receipt (“*the do-nothing baseline for C1 … read at `--base`*”), out of the seat's scope dirs. Summary: no NIST ground; no committed gate.
15. **mori** — `0/0/4/3` (`R1`), quotes §2.1. Gate: `R5: <none>`. Summary: NIST-owning lane, PII subfield.
16. **revenger** — `0/1/4/9` (`R1`), quotes §2.1. Gate: `corpus/self_assessment_check.py`, class C (`git archive <commit> corpus …` then citation-vs-commit checks). Summary: NIST-owning lane, digest/CFTT subfield; no base-value gate.
17. **souji** — `0/0/0/0` (`R1`). Gate: `tools/souji-freeze-check.py`, class C with the `CONTROL-NOT-RED` clause (§3.3). Summary: no NIST ground; closest red-state clause, different object.
18. **tabi** — `0/0/0/0` (`R1`). `.ufo` only: captured page quoting SP 800-131A (§2.3). Gate: `check-round-contract.mjs` (`HARD_BASELINE`, `--expect N`, census sha256) +3, class B/C. Summary: no NIST ground; a baseline count check, not a counter replay.
19. **tameshi** — `0/0/0/0` (`R1`). Gate: `R5: <none>`; it holds four `*kagi*` knowledge entries (`R12`: `gates-survey-kagi.md` + three `mutation-case-kagi-*`), none of which mentions NIST, prefreeze or `git archive`, and whose six-gate table is an inventory of *kagi's* gates (§3.4). Summary: no gate of its own, neither ground; its survey corroborates kagi's pre-C1 inventory.
20. **tsukuroi** — `0/0/0/1` (`R1`); the hit is the DKMS `key-management` phrase (§2.1, R11). Gate: `R5: <none>`. Summary: neither ground; one homonym.

---

## 6. Limits of this scan (stated, so the L1 can weigh the counts)

1. **Scope of (a) is the seat's file list.** I scanned `PROVINCE.md`, `SKILL.md`,
   `corpus/SOURCES.md` recursively and `corpus/knowledge/` recursively. A sibling could name
   NIST key management in `corpus/README.md`, `SCORECARD.md`, `LOG.md` or a lesson without a
   province/skill/registry/entry line. I did not count that surface, by the seat's definition.
   Spot-checked exception: `chousa/SCORECARD.md:3183` mentions a “routed freeze-check host
   drift” — its own tool, not this ground.
2. **`corpus/live/`, `corpus/evidence/` and `.ufo/` are receipts, not instruments.** I excluded
   them from the gate class and reported the three material near-misses separately (§2.3).
   `kasegi`'s closure suites *do* live in `corpus/instruments/` and are therefore included.
3. **`tools/` is outside the seat's stated scan dirs** but three of the four class-C gates live
   there (`chousa`, `souji`, `kaidoku`). Excluding them would have produced a false “no
   equivalent” for the `freeze-check` *name*, so they are named, with their location flagged.
4. **No gate was executed.** “What it checks” comes from each script's own docstring/registry
   row. A docstring can lie; this seat did not run a sibling gate (out of bounds).
5. **The equivalent's own verdict is unverified by me.** I quote `selftest cases=27 failures=0`
   from the README row; I did not run it.
6. **`kasegi`'s NIST counts are the largest in the fleet (27 knowledge lines).** They are 4
   entries, all vulnerability-disclosure or NVD-surface; none is key management. I verified
   each entry's title line rather than trusting the count.

---

## 7. Yield summary

- **Lanes scanned:** 20/20. **Lane writes:** 0. **Sibling gate executions:** 0. **Vault contact:** none (`op --version` 2.41.1 only).
- **(a) NIST-term hits:** `PROVINCE`=2 (`kasegi` only), `SKILL`=1 (`revenger` only),
  `SOURCES`=17 across 4 lanes, `knowledge`=47 lines across 6 lanes (one of them a false
  positive). **Lanes claiming NIST key-management ground: 0.**
- **(a) Key-management document family (SP 800-56/57/108/131/133/152, FIPS 140/186/197) in
  the scoped classes: 0 hits in 20 lanes.** Only non-claim appearances are three captured
  `.ufo` pages (§2.3).
- **(b) Prefreeze-control equivalent: 1 (`kasegi/corpus/instruments/freeze-check.py`, class A).**
  Plus 4 class-B lanes (`kasegi` closure suites, `kumitate`, `tabi`, `kake`) and 4 class-C
  lanes (`chousa`, `souji`, `kaidoku`, `revenger`). 12 lanes hold nothing in scope.
- **Contested ground:** 1 — the capability class in §4.1. Source ground: 0. No decision
  requested of this seat and none given.
- **BASE readings this seat reproduced independently:** registry rows **72**;
  `corpus/knowledge/nist-*.md` **0**; `corpus/prefreeze-control.sh` **absent** (`test -e`
  exit 1); `corpus/README.md` NIST lines in the Frontier section **1** (`:117`);
  `PROVINCE.md:90` Frontier bullet present. Lane HEAD `880824b1d3da5f70b2fe489a34fe866a47314672`.
- **Tooling:** nothing installed or upgraded this seat; `op` 2.41.1, `grep`/`find`/`sed` from
  the host. Scratch used: `/fast/scratch/hyaku/kagi-r33/ConnOverlap/` (generator + receipts),
  removed before yield; both deliverables copied to
  `.ufo/waves/round-33/build/{ConnOverlap.md,ConnOverlap-receipts.txt}`.
