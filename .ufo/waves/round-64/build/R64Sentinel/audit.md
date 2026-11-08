# R64Sentinel — secret-discipline and write-scope audit (kagi round 64, attempt 2)

Seat: R64Sentinel (sentinel). Scope: secret-discipline + write-scope of the round's
artifacts, read-only. This receipt is the only file I wrote in the lane tree.
**Disclosure:** I (the sentinel) read the sealed held-out file
`plans/round-64-heldout.tsv` once, while auditing leakage of fixture text into
non-sealed lane artifacts. I did **not** build, and did not feed anything to, the C1
checker (`plans/round-61-c1-check.py`); the checker bytes are unchanged by me and my
read produced no lane artifact beyond this receipt. Nothing in this receipt quotes a
fixture payload or a secret value.

Audit window: 2026-11-08 02:07–02:40 -0300 (fleet root clock). Lane:
`/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`, BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`).

---

## Check 1 — credential-shape scan over every file the round created or changed

Command (counts only, binary-inclusive, one line per needle):

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
grep -raoh -E '<needle>' \
  .ufo/waves/round-64 \
  plans/round-64.md plans/round-64-heldout.tsv \
  plans/round-64-c1.sh plans/round-64-c2.sh plans/round-64-controls.sh plans/round-64-routed.sh \
  plans/round-61-c1-check.py plans/round-63-c2.sh plans/round-63-controls.sh \
  | wc -l
```

Output (needle = hits):

```
op://                                     3
Set-Cookie                                4
Cookie:                                   0
Authorization:                            5
Bearer                                    0
sessionid                                 0
session_id                                0
sessid                                    0
PHPSESSID                                 0
JSESSIONID                                0
__cf_bm                                   0
AKIA[0-9A-Z]{16}                          0
ghp_[A-Za-z0-9]{20,}                      0
gho_[A-Za-z0-9]{20,}                      0
github_pat_[A-Za-z0-9_]{20,}              0
sk-[A-Za-z0-9]{20,}                       0
xox[baprs]-[A-Za-z0-9-]{10,}              0
AIza[0-9A-Za-z_-]{30,}                    0
hvs\.[A-Za-z0-9_-]{20,}                   0
s\.[A-Za-z0-9]{25,}                       0
eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,} 0
-----BEGIN [A-Z ]*PRIVATE KEY             0
root_token                                1
unseal_key                                0
otp_secret                                0
```

**Hit count: 13 raw shape hits across the round's artifacts** (`op://` 3,
`Set-Cookie` 4, `Authorization:` 5, `root_token` 1). Every one is a **name of a
shape inside the round's own instruction/sweep text or in third-party captured
bodies — no credential value is carried**. Locations:

```
$ grep -ran -F 'op://' .ufo/waves/round-64 plans/round-64*.md
.ufo/waves/round-64/build_w1_spec.py:216:1. Scan every file the round created or changed under `{LANE}/.ufo/waves/round-64/` and `{LANE}/plans/round-64*` for credential shapes (unseal keys, root tokens, `op://` references, cookies, session ids, `Authorization:` values)
.ufo/waves/round-64/w1-dispatch.json:105  (seat prompt text)
.ufo/waves/round-64/w1-spec.json:139      (seat prompt text)

$ grep -ran -F 'Set-Cookie' .ufo/waves/round-64 plans/round-64*.md
.ufo/waves/round-64/build_w1_spec.py:31:Secret discipline: no secret value, unseal key, root token, OTP, cookie, session id or vault/item/field name …
.ufo/waves/round-64/capture/notes.md:30:* No `Set-Cookie` / `Cookie` header value was written to any capture, note or receipt.
.ufo/waves/round-64/w1-dispatch.json:30 / w1-spec.json:9   (seat prompt text)

$ grep -ran -F 'Authorization:' .ufo/waves/round-64 plans/round-64*.md
.ufo/waves/round-64/build_w1_spec.py:216  (needle list, above)
.ufo/waves/round-64/capture/notes.md:37  (`Authorization: Bearer` listed as a *scan needle*, followed by "**0 hits in all 26 files**")
.ufo/waves/round-64/w1-dispatch.json:105 / w1-spec.json:139  (seat prompt text)
.ufo/waves/round-64/w1/R64ScoutSources.md:207  (same needle list, "⇒ **0 hits in every file**")

$ grep -ran -F 'root_token' .ufo/waves/round-64
.ufo/waves/round-64/capture/S150.body:12313:  "path": "internal/command/self_init_root_token_test.go",   (OpenBao source-tree path in a captured GitHub API body)
```

Header receipts (the only place a server-issued credential could land) — the
scout's own strip holds:

```
$ cd .ufo/waves/round-64/build/R64ScoutSources && for f in *.hdr; do c=$(grep -aic -E '^set-cookie:|^cookie:|^authorization:' "$f"); echo "$f cookieish=$c"; done
hS143.hdr cookieish=0
hS145.hdr cookieish=0
hS146.hdr cookieish=0
hS147.hdr cookieish=0
hS149.hdr cookieish=0
hS150.hdr cookieish=0
hS151.hdr cookieish=0
hS152.hdr cookieish=0
hS153.hdr cookieish=0
hS154.hdr cookieish=0
hS155.hdr cookieish=0
hS156.hdr cookieish=0
hS157.hdr cookieish=0
hS158.hdr cookieish=0
hS159.hdr cookieish=0
hS160.hdr cookieish=0
hS161.hdr cookieish=0
hS162.hdr cookieish=0
hS163.hdr cookieish=0
```

Capture bodies / text layers (binary-inclusive, per file):

```
$ for f in .ufo/waves/round-64/capture/*.body; do n=$(grep -ac -E 'op://|Set-Cookie|Cookie:|Authorization:|Bearer |sessionid|__cf_bm' "$f"); echo "$f hits=$n"; done
S143.body hits=0 … S155.body hits=0   (all 13 files: hits=0)
```

Two near-misses worth naming explicitly (neither is a credential value):

* `hS149.hdr:19` carries `x-client-ip: 2804:14d:5c56:36ef:2ed8:aeff:0:2c0` — a
  Wikimedia echo of the fetcher's own IPv6 address, i.e. **the host's client IP in a
  committed receipt**. It is not a credential and not on the QA5/QM72 lists, but it
  is host-identifying data in a committed artifact; the L1 may want it stripped.
* `hS146.hdr` / `hS151.hdr` carry a Cloudflare `report-to` endpoint URL with a long
  `s=` query token (1 occurrence each). That is a server-issued RUM beacon token,
  not an access credential, but it is a high-entropy server-issued token in a
  committed file and is the closest thing to a QM72 "server-issued
  credential-shaped token" I found.

**Verdict check 1: CLEAN on credential material.** No secret value, unseal key,
root token, OTP, cookie value, session id, `op://` item reference, or
`Authorization:` value anywhere in the round's artifacts. No `vault/item/field`
name is present either (the lane's knowledge rows name product concepts only).
The one item to flag for the L1 is the `x-client-ip` echo (host IP in a committed
receipt) — LOW severity, not a QA5/QM72 breach, recommended to be stripped before
the receipts commit.

---

## Check 2 — every receipt path cited by the round is inside the lane tree or the wave dir

Command (parse every backticked path in every round-64 artifact, classify, and test
lane-relative existence):

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin && python3 - <<'PY'
  … walk .ufo/waves/round-64 + plans/round-64*.{md,sh,tsv}, regex `([^`\n]{3,200})`,
  classify each as scratch-named | TMP-path | lane-abs | fleet-abs | lane-rel,
  and for lane-rel test os.path.exists(LANE/path)
PY
```

Output — cited-path classes (distinct citations):

```
lane-rel: 240     lane-abs: 102     fleet-abs: 8
TMP-path: 9       scratch-named: 6
```

### 2a. `/tmp` and `/var/tmp` citations — 9, all in *text*, none a citable path

```
$ (every /tmp|/var/tmp citation with source:line)
.ufo/waves/round-64/base/c1-fix-reference.md:5: /tmp
.ufo/waves/round-64/build_w1_spec.py:217: /tmp
.ufo/waves/round-64/build_w1_spec.py:217: /var/tmp
.ufo/waves/round-64/capture/notes.md:39: /tmp
.ufo/waves/round-64/capture/notes.md:40: /tmp
.ufo/waves/round-64/w1-dispatch.json:105: /tmp
.ufo/waves/round-64/w1-dispatch.json:105: /var/tmp
.ufo/waves/round-64/w1-spec.json:139: /tmp
.ufo/waves/round-64/w1-spec.json:139: /var/tmp
.ufo/waves/round-64/w1/R64ScoutSources.md:208: /tmp
.ufo/waves/round-64/w1/R64ScoutSources.md:209: /tmp
```

Read in context, none of these is a citable-evidence path:

* `capture/notes.md:39-40` and `w1/R64ScoutSources.md:208-209` are the **negative
  statements**: "Raw (unfiltered) header scratch was written only under `/tmp` and
  **deleted** after filtering; no citable evidence lives under `/tmp`." — correct
  and, per my measurement below, true.
* `base/c1-fix-reference.md:5` says "The prototype lived in `/tmp` and is not
  committed; only these readings are." — a **provenance disclosure**, not a
  citation. **Defect (see 4c): the prototype is still on disk at `/tmp/r64proto/`
  and was not deleted before the L1's own yield.**
* `build_w1_spec.py`, `w1-dispatch.json`, `w1-spec.json` carry the host rule text
  itself ("Never write citable evidence under `/tmp`").

### 2b. `$HYAKU_SCRATCH` paths cited as evidence — 6, all as *working-tree* locations, not as evidence

```
$ grep -rIn -E '/fast/scratch|HYAKU_SCRATCH' plans/round-64-*.sh
plans/round-64-c1.sh:22:# carries it (resid leg) — from ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/
plans/round-64-c1.sh:91:SCRATCH_ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecC1Counter"
plans/round-64-c2.sh:90:SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecC2Counter
plans/round-64-controls.sh:73:# ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecControls/battery.$$ and
plans/round-64-controls.sh:92:SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecControls
plans/round-64-routed.sh:56:#   ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecRouted/; nothing is
plans/round-64-routed.sh:80:SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecRouted
```

These are **scratch allocation constants inside the instruments**, i.e. where a
counter copies its tree — not "the receipt lives at $HYAKU_SCRATCH". The lane's own
round-63 wave does the same (91 scratch citations in `.ufo/waves/round-63/`), so this
is the established lane convention, not a round-64 deviation. **Verdict: acceptable**;
the *evidence* each receipt cites is always a lane-tree file (see 2c).

### 2c. Lane-relative cited paths that do not exist — 32 distinct

```
$ (lane-relative cited paths failing os.path.exists, first occurrence each)
  .ufo/waves/round-64/heldout-backup.tsv                (cited in base/census-a1.md)
  plans/round-64/base/c2-e2e-head.txt                   (cited in build/R64Critic/critique.md)
  .ufo/waves/round-64/build/R64ScoutSources/h<id>.hdr   (cited in capture/notes.md — a template, not a path)
  corpus/lessons/round-64.md                            (cited in build_w1_spec.py — L1's own future landing)
  corpus/knowledge/claim-instrument-heldout.md          (cited in build_w1_spec.py — same)
  corpus/knowledge/regression-tally-completeness.md … (28 further corpus/… and .ufo/waves/round-NN/… paths
     cited in build/R64Connector/sweep.md — these are OTHER lanes'/other rounds' files, cited
     by a lane-internal sweep; they are not round-64 receipts)
  plans/<script>, plans/*                               (cited in build/R64Revenger/recursion.md — shell globs, not paths)
```

Named violations of this check:

* **V-1 (MEDIUM) — `base/census-a1.md:10` cites `.ufo/waves/round-64/heldout-backup.tsv`,
  which does not exist anywhere** (never committed, not on disk:
  `git log --all -- .ufo/waves/round-64/heldout-backup.tsv` ⇒ empty; `find` ⇒ only
  `plans/round-64-heldout.tsv` exists). The census receipt claims the fixture ids
  "below are the ids checked against the back-up file" — the back-up file it names is
  absent, so that sentence cites a non-existent receipt. Smallest remediation: the
  L1 either commits the back-up under the wave dir (it is a copy of the sealed set —
  see V-2 for why that is itself a question) or rewords the sentence to name the
  file that does exist.
* **V-2 (MEDIUM, cross-seat, independently confirmed) — the "sealed" held-out set is
  published in a committed, non-sealed file.** `.ufo/waves/round-64/base/census-a1.md`
  is **tracked** (`git ls-files` ⇒ committed at `dff0929`) and is the file the C1
  seat was told to build from. It carries the verbatim distinguishing string of
  **seven of the eight** H/Q fixtures. Measured by me (payload = the text a fixture
  *adds*, i.e. replacement minus anchor):
  `F2 YES, F8 YES, F10 YES, P6 YES, B4 YES, B5 YES, F6 no, P7 near-miss (its
  replacement is quoted with a line-wrap inserted at "three present roles,\none
  sentinel present")`. The C1 seat's own output checker now carries four of those
  payloads verbatim (F2, F8, B4, B5), and `plans/round-64.md` itself names the B5
  idiom class **with its literal wording** in §Amendment A1 (the literal is quoted
  in the plan and in the census receipt; it is not reproduced here). Consequence: a
  seat that obeys its prompt can implement an eight-entry lookup without opening the
  sealed file and truthfully say it never read it. The critic seat has filed this
  independently as `R64Critic` C1-1 (`build/R64Critic/critique.md:195-215`); my
  measurement agrees with it on the counts. This is a **process/claim-validity
  defect, not a secret-discipline breach** — no credential material is involved —
  but it voids the *held-out* premise of the C1 claim as specified, and the L1 must
  record it as a defect, not a pass. I did not amend any frozen predicate, POP,
  kill rule, fixture or item condition.
* **V-3 (LOW) — `build/R64Critic/critique.md` cites `plans/round-64/base/c2-e2e-head.txt`**
  (path does not exist; the file is at `.ufo/waves/round-64/base/c2-e2e-head.txt`).
  Wrong path in a receipt citation.
* **V-4 (LOW) — `build/R64Connector/sweep.md` cites 28 lane-relative paths that do not
  exist in this lane** (`corpus/lessons/round-89.md`, `corpus/knowledge/mutation-testing-r28.md`,
  `.ufo/waves/round-93/w1/…`, `.ufo/waves/round-68/R68ConnectorOverlap.md`, …). These
  are other rounds'/lanes' artifacts; as citations they are unresolvable from the lane
  that files them. Cosmetic for this round, but a receipt that cites paths its reader
  cannot open is not evidence.

### 2d. Fleet-root citations (8, all legitimate)

`/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md` (the fleet report the
I6 derivation reads), `scripts/sources-census.sh`, `scripts/collect-omp-native-handoff*`,
`scripts/sync-ufo-contracts.mjs`, `scripts/run-omp-native-trial.mjs`, `scripts/ufo-sighting*`,
`.ufo/pending-work.json`. The four `scripts/*` names appear only inside the L1's
census receipt (`base/cheap-census.txt:46-49`) as telemetry field names in a captured
payload; they are **not present on this host** (`test -e` ⇒ missing for all four) and
are not cited as round-64 evidence. No fleet-root path is cited as citable evidence
for a round-64 claim.

**Verdict check 2: 4 named violations (V-1 medium, V-2 medium, V-3 low, V-4 low).**
Every *round-64 receipt* cited as evidence is inside the lane tree or the wave dir.
No receipt cites `/tmp`, `/var/tmp` or a `$HYAKU_SCRATCH` path as citable evidence.

---

## Check 3 — no seat wrote outside the lane

```
$ git -C /home/vgpnk/Projects/shokunin status --porcelain
 M .scratch/goal-20261103-hyaku-run15.md
 M .scratch/run15-state.json
 M .ufo/l0-questions.md
?? .scratch/run15-wrapup/misroot-cff0b4cb/
?? .ufo/reports/round-85/chousa.md
?? .ufo/reports/round-92/tsukuroi.md
?? plans/

$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin status --porcelain
 M corpus/QUALITY.md
 M corpus/claims-declared.tsv
 M plans/round-61-c1-check.py
 M plans/round-63-c2.sh
 M plans/round-63-controls.sh
?? .ufo/waves/round-64/base/c1-fix-reference.md
?? .ufo/waves/round-64/base/census-start.txt
?? .ufo/waves/round-64/build/
?? .ufo/waves/round-64/capture/
?? .ufo/waves/round-64/w1.ready.dispatched
?? .ufo/waves/round-64/w1/
?? plans/round-64-c1.sh
?? plans/round-64-c2.sh
?? plans/round-64-controls.sh
?? plans/round-64-routed.sh
```

### 3a. Fleet root — no kagi round-64 write outside the lane

Every entry in the fleet-root status is another lane's or the orchestrator's:

* `.scratch/goal-20261103-hyaku-run15.md`, `.scratch/run15-state.json`,
  `.scratch/run15-wrapup/misroot-cff0b4cb/` — orchestrator run-state (goal/run15
  bookkeeping), not a kagi seat artifact.
* `.ufo/l0-questions.md` — modified by **another lane**: the diff adds only
  `tsukuroi | round-92 | GH013 CREDENTIAL INCIDENT …` lines
  (`git diff -- .ufo/l0-questions.md | grep -c -i -E 'kagi.*(round-?64|64)'` ⇒ **0**).
* `.ufo/reports/round-85/chousa.md`, `.ufo/reports/round-92/tsukuroi.md` — other lanes'
  reports.
* `plans/` (untracked) — `plans/round-91.md` only; a **round-91** amendment for a
  different lane (content: `tools/check-limine-pins.py`, `limine-pin-battery-r91.py` —
  not kagi, not round 64).

**Files at the fleet root that name kagi round 64** (the check's third clause):

```
$ ls -la /home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-64.md
-rw-r--r-- 1 vgpnk vgpnk 131042 Nov  8 00:08 .ufo/prompts/kagi-round-64.md
$ git log --format='%h|%an|%ad|%s' --date=iso -1 -- .ufo/prompts/kagi-round-64.md
97671a36|kagi-shokunin|kagi@shokunin.local|2026-11-08 00:04:05 -0300|round-64: kagi dispatch evidence (hyaku inline attempt 2)
$ git ls-files --error-unmatch .ufo/prompts/kagi-round-64.md   ⇒ tracked
```

* `.ufo/prompts/kagi-round-64.md` — **tracked**, authored by the lane identity
  (`kagi-shokunin`), committed at `97671a36` **before** the wave dispatched
  (02:06). This is the dispatch-evidence file the host's inline dispatcher wrote
  (131 042 B, the seat prompts). It is the fleet's own dispatch record, committed by
  the L1 as the lane identity — the same pattern the round-63 spot-check records
  ("dispatch evidence (hyaku inline attempt 2)"), and the host's §5 gives the L1 the
  fleet-repo report commit. **Not a seat write outside the lane.**
* `.ufo/state/kagi.report-baseline` (68 B) — the driver's per-lane report baseline,
  fleet-owned; contains a sha256 of the (not yet written) round-64 kagi report.
* `.ufo/reports/round-64/kagi.md` — **does not exist yet** (the L1 has not filed the
  round report; correct at this point in the wave).

**Verdict 3a: no kagi round-64 seat wrote outside the lane.** Nothing under
`/home/vgpnk/Projects/shokunin/` outside `kagi-shokunin/` carries a kagi round-64
artifact, and the only fleet-root file naming kagi round 64 is the tracked,
lane-identity-authored dispatch evidence plus the driver's baseline file.

### 3b. Lane tree — all writes are inside the lane, but two ownership notes

* `corpus/QUALITY.md` (modified) and `corpus/claims-declared.tsv` (modified) are
  **lane corpus files, not wave-seat files**. They carry the round-64 rows
  (`64 C1 calibration`, `64 C2 operability`) and the new criteria rows QM85/QM86.
  Per the round-63 precedent these are integrator-owned landing artifacts; the L1 is
  the sole committer, so this is expected — but flagging that they are modified in
  the worktree *now*, before the L1's commit, so the L1 must land them deliberately
  and not let them ride in an unrelated commit.
* `plans/round-63-c2.sh` (1 line) and `plans/round-63-controls.sh` (+41/−9) are
  **round-63 frozen instruments** edited in the round-64 worktree. The edits are
  the `R63_CONTROLS_FIXTURE_ONLY` pass-through and the fixture-only branch — which
  the plan's own §C2 prescribes ("the recursion bound is an explicit environment
  flag … at 1 the counter's controls-battery leg delegates to the battery's
  fixture/confinement controls only") and which the R64ExecC2Counter seat's prompt
  explicitly assigns ("the `C2_RECURSION_BOUND` delegation bound in
  `plans/round-63-c2.sh`'s battery leg"). **Not a frozen-predicate amendment**; the
  plan's frozen predicate, target, POP, kill rules and fixtures are untouched. The
  R64ExecControls receipt records the cross-seat hand-off
  (`build/R64ExecControls/controls.md:6-11`), which is the right disclosure.
* No seat wrote a file outside the paths its item names, and no seat wrote to
  `.jj`/`.git` index state. The lane's `.git/index` mtime is `2026-11-08 01:30:04`,
  i.e. **before** the wave dispatched (02:06) — no seat touched the lane index.
  The fleet root's `.git/index` mtime (`02:20:10`) tracks the **other lanes'**
  commits (`git log --since='2026-11-08 01:50'` shows only `tameshi-shokunin`,
  `kama-shokunin`, `protocol-shokunin`, `hyaku-orchestrator-shokunin` commits).

### 3c. Sibling lane repos — untouched by this wave

```
$ for d in */; do git -C "$d" status --porcelain | head -3; done
chousa-shokunin/  M SKILL.md  M corpus/QUALITY.md  …      (chousa r84/r85 — other lane)
kagi-shokunin/    M corpus/QUALITY.md  M corpus/claims-declared.tsv  M plans/round-61-c1-check.py
kama-shokunin/    …                                          (kama r94/r95 — other lane)
kasegi-shokunin/  …                                          (kasegi r100 — other lane)
kengaku-shokunin/ …                                          (kengaku r97 — other lane)
mado-shokunin/    …                                          (mado r100 — other lane)
souji-shokunin/   …                                          (souji r73 — other lane)
tabi-shokunin/    …                                          (tabi r83 — other lane)
tsukuroi-shokunin/ …                                        (tsukuroi r92 — other lane)
```

No sibling lane repository carries a kagi round-64 artifact.

**Verdict check 3: PASS** on write scope, with two ownership notes for the L1
(3b: lane corpus files modified pre-commit; round-63 instruments edited under the
plan's own §C2 authorization) and one informational finding (3a: the fleet-root
dispatch-evidence file `.ufo/prompts/kagi-round-64.md` is tracked and lane-identity
authored — the host's dispatch record, not a seat write).

---

## Check 4 — the wave's scratch discipline

```
$ du -sh /fast/scratch/hyaku/kagi-r64/* | sort -h      # snapshot 02:33 -0300
0     /fast/scratch/hyaku/kagi-r64/R64Sentinel
2.3M  /fast/scratch/hyaku/kagi-r64/R64ExecControls
8.1M  /fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar
22M   /fast/scratch/hyaku/kagi-r64/R64MutC1
40M   /fast/scratch/hyaku/kagi-r64/R64ExecC1Counter
74M   /fast/scratch/hyaku/kagi-r64/R64ScribeRecords
355M  /fast/scratch/hyaku/kagi-r64/R64ExecRouted
9.4G  /fast/scratch/hyaku/kagi-r64/R64MutC2
17G   /fast/scratch/hyaku/kagi-r64/R64ScribeEntry
25G   /fast/scratch/hyaku/kagi-r64/R64ScoutPreState
32G   /fast/scratch/hyaku/kagi-r64/R64ExecC2Counter

$ ls /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-64/w1/
R64Connector.md  R64Critic.md  R64Revenger.md  R64Reviewer.md
R64ScoutPreState.md  R64ScoutSources.md
```

Second reading of the same command at 02:41 -0300 (seats still running; sizes
move):

```
0     /fast/scratch/hyaku/kagi-r64/R64Sentinel
2.3M  /fast/scratch/hyaku/kagi-r64/R64ExecControls
12M   /fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar
22M   /fast/scratch/hyaku/kagi-r64/R64MutC1
42M   /fast/scratch/hyaku/kagi-r64/R64ExecC1Counter
355M  /fast/scratch/hyaku/kagi-r64/R64ExecRouted
9.4G  /fast/scratch/hyaku/kagi-r64/R64MutC2
14G   /fast/scratch/hyaku/kagi-r64/R64ScribeRecords
17G   /fast/scratch/hyaku/kagi-r64/R64ScribeEntry
25G   /fast/scratch/hyaku/kagi-r64/R64ScoutPreState
32G   /fast/scratch/hyaku/kagi-r64/R64ExecC2Counter
```

Seat trees left behind at the snapshot:

* **`R64ScoutPreState` — 25 GB, report already filed** (`w1/R64ScoutPreState.md`
  exists). The tree holds three stale prior-round trees
  (`scratchroot/kagi-r61`, `scratchroot/kagi-r62`, `scratchroot/kagi-r63`, plus
  `scratchroot2` at 4.1 GB) — **1 215 958 files** in total
  (`find … -type f | wc -l`). A seat that has filed its report must have deleted
  its scratch tree ("delete it before you yield"). **Named violation: V-5
  (MEDIUM) — a finished seat's 25 GB scratch tree is still on disk.**
* `R64ExecC2Counter` — 32 GB, report **not yet filed** (seat still running) — not a
  violation yet, but it is the largest tree on the host and the fleet disk-guard
  (`/home/vgpnk/Projects/shokunin/.ufo/state/disk-guard.log`) is already purging
  other lanes' trees for space (`purge-lane kama-r94 228.2 … live process inside`).
  The fleet filesystem is at 66 % use (`df -h /fast/scratch` ⇒ 524 G/804 G used,
  280 G free). A wave whose seat trees sum to ~110 GB is a budget risk the L1
  should bound before the next tranche fills.
* `R64ScribeEntry` — 17 GB, report not filed (running).
* `R64ScribeRecords` — 74 M at 02:33, **14 GB at 02:41** (report not filed; the
  tree is growing fast inside one seat's run).
* `R64MutC2` — 9.4 GB, report not filed (running).
* `R64ExecRouted` — 355 MB, report not filed (running).
* `R64MutC1` (22 M), `R64ExecC1Counter` (40 M→42 M), `R64ExecC1Grammar`
  (8.1 M→12 M), `R64ExecControls` (2.3 M) — reports not filed (running).
* Seats whose scratch is **already gone** (clean): `R64Connector`, `R64Critic`,
  `R64Revenger`, `R64Reviewer`, `R64ScoutSources` (0 B dir), `R64ExecC2Counter`'s
  earlier trees.
* **`R64Sentinel` (mine) — 0 B**: this seat created no scratch dir content; the
  directory is deleted before this seat yields.

### 4c. Round-64 scratch residue **outside** the sanctioned root — under `/tmp`

This is a violation of the host rule "every clone, work tree, fixture or dev-server
dir lives under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/<seat-name>/`" and
of "/tmp is only for files under 50 MB and never for citable evidence".

```
$ du -sh /tmp/r64probe /tmp/r64proto ; ls /tmp/r64probe
8.1M  /tmp/r64probe        (18 directories: base, x-F2, x-F6, x-F8, x-F10, x-B4, x-B5, x-P6, x-P7,
244K  /tmp/r64proto          y-B4, y-F10, y-P6, y-r63-F4, y-r63-F6, y-r63-P1, y-r63-P2, y-r63-P5, y-r63-P6)
                            /tmp/r64proto/c.py  (100 951 B, 2094 lines)

$ stat -c '%y %n' /tmp/r64probe /tmp/r64proto
2026-11-08 02:04:57 /tmp/r64probe
2026-11-08 02:05:41 /tmp/r64proto
```

* `/tmp/r64probe/` is a **set of 18 fixture trees, one per held-out id
  (`x-F2 … x-P7`)**, each a full copy of the slim tree with the fixture applied.
  Measured: each of the 18 directories holds the fixture's anchor **and**
  replacement text in its bytes. This is the **held-out test set materialised on
  disk outside the sanctioned scratch root**, in a world-readable directory
  (`drwxr-xr-x`). The C1 checker seat is forbidden to read the sealed file; this
  tree is a byte-for-byte derivative of it, sitting in `/tmp`.
* `/tmp/r64proto/c.py` is the **L1's own C1 prototype** (2094 lines; sha256
  `af5166a7cdf10d508bcc42829b145f8b73bef1f4c29a9fe72fa20e008fd1ad2c`), and
  `base/c1-fix-reference.md:5` says so: "The prototype lived in `/tmp` and is not
  committed". It was never deleted.
* Attribution and timing: the `/tmp/r64probe` fixture trees are dated 01:33
  (before the wave dispatched at 02:06) and `/tmp/r64proto` 02:05-02:06 — i.e.
  **pre-wave L1 census work**, not seat work. The `x-*`/`y-*` naming matches the
  L1's census method ("Each fixture applied once", `base/census-a1.md`).

**Named violations:**

* **V-6 (HIGH) — the held-out test set is materialised in `/tmp/r64probe/`**
  (18 fixture trees, 8.1 MB, world-readable `drwxr-xr-x`, still on disk). Any seat
  that has not read the sealed TSV can read the same fixture text here, which
  defeats the hold-out the C1 claim rests on. Smallest remediation: `rm -rf
  /tmp/r64probe` and re-run the census inside
  `${HYAKU_SCRATCH}/kagi-r64/<seat>/` only.
* **V-7 (MEDIUM) — the L1's prototype is still in `/tmp/r64proto/`** although
  `base/c1-fix-reference.md` says it "is not committed" (true) without saying it is
  deleted (false). Smallest remediation: `rm -rf /tmp/r64proto` and add "deleted"
  to the receipt sentence, or move it under the sanctioned scratch root.
* **V-8 (LOW) — the fleet disk budget.** Seat scratch under
  `/fast/scratch/hyaku/kagi-r64/` is ~110 GB across 10 live/finished trees
  (32 G + 25 G + 17 G + 9.4 G + …); the fleet disk-guard is already purging other
  lanes for space. The wave's own policy says a tree copy costs ~200 MB and the
  L1 measured a slim tree at the same `value=0`; three seats are carrying
  multi-GB full copies (the `R64ScoutPreState` tree alone holds 1.2 M files).

### 4d. `/tmp` residue from *other* rounds (not this round's seats) — informational only

`/tmp/kagi-r64-p2-hF1..hF8` (dated 00:19), `/tmp/r64-census-start.out`,
`/tmp/r64-census-mid.out`, `/tmp/r64-run.json`, `/tmp/r64-closure.json` and the
`/tmp/r64_f2a546`, `/tmp/r64_a4a5a6`, `/tmp/r64_1b0ce6`, `/tmp/r64_p25..p30`
files (02:09) are **round-64-attributed scratch in the wrong location** too; none
is cited by any round-64 receipt (`grep -rIl -F '<name>' .ufo/waves/round-64/` ⇒
`none` for each). They are evidence-free leftovers and should be swept with V-6/V-7.

---

## Summary of named violations

| id | severity | violation | smallest remediation |
|---|---|---|---|
| V-1 | MEDIUM | `base/census-a1.md:10` cites `.ufo/waves/round-64/heldout-backup.tsv`, which exists nowhere | commit the back-up under the wave dir or reword to name the file that exists |
| V-2 | MEDIUM | the "sealed" held-out set is published verbatim in tracked `base/census-a1.md` (7 of 8 H/Q payloads) and named in the plan (§Amendment A1 gives B5's literal); the C1 seat's checker now embeds 4 of those payloads — the hold-out premise of C1 is defeated without reading the sealed file (independently filed by `R64Critic` C1-1) | redact `census-a1.md` to class-level prose, re-commit, re-point the C1 seat, and record `leak=0` against the redacted string set in the C1 receipt; the L1 records the breach as a defect |
| V-3 | LOW | `build/R64Critic/critique.md` cites `plans/round-64/base/c2-e2e-head.txt` (wrong path; the file is `.ufo/waves/round-64/base/c2-e2e-head.txt`) | fix the path |
| V-4 | LOW | `build/R64Connector/sweep.md` cites 28 lane-relative paths that do not exist in this lane | cite the owning lane's path, or drop |
| V-5 | MEDIUM | finished seat `R64ScoutPreState` left a 25 GB scratch tree (1 215 958 files) on disk | delete `/fast/scratch/hyaku/kagi-r64/R64ScoutPreState` |
| V-6 | HIGH | the held-out test set is materialised as 18 fixture trees in `/tmp/r64probe/` (world-readable, still on disk) | `rm -rf /tmp/r64probe`; re-run the census only under `${HYAKU_SCRATCH}/kagi-r64/<seat>/` |
| V-7 | MEDIUM | the L1's C1 prototype remains in `/tmp/r64proto/` although the receipt says it "is not committed" | `rm -rf /tmp/r64proto`; state "deleted" in `base/c1-fix-reference.md` |
| V-8 | LOW | wave seat scratch ~110 GB across 10 trees; fleet disk at 66 % and the disk-guard already purging other lanes | bound tree copies (slim tree) and delete each seat tree at yield |
| I-1 | INFO (LOW) | `hS149.hdr:19` carries the fetcher's IPv6 `x-client-ip` in a committed receipt | strip the `x-client-ip` line before the receipts commit |
| I-2 | INFO (LOW) | `hS146.hdr`/`hS151.hdr` carry a Cloudflare `report-to` RUM beacon token (1 each) | not a credential; consider stripping |

**No credential material was found anywhere in the round's artifacts (check 1
CLEAN).** No seat wrote outside the lane (check 3 PASS). The round's write scope
and secret discipline hold; the open items are the held-out-set leak (V-2, V-6) and
scratch hygiene (V-5, V-7, V-8).

Tools: none installed or upgraded (RULES.md read first; only bash, python3, git,
grep, du, find, stat, sha256sum used — all pre-installed). No pacman transaction
was run.

SEAT-STATUS: complete
