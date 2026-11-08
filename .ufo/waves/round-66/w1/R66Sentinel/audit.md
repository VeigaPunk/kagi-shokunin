# R66Sentinel — secret-discipline and write-scope audit (kagi round 66, wave 1)

Seat: sentinel (attack seat, leaf member — no subagent dispatch).
Scope: credential material, write-scope violations, parked secrets, refusal-boundary
respect, and the zero-mutation property of the canonical run logic's refusal paths.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`).
Claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`; frozen plan `ddcd46bb4f93…`
with Amendments A1–A4 at `dcd78c2ed28a…`; instrument commit `cfafdb1169ed…`.
Read-only except this receipt; **no secret value is printed anywhere in this file**
(only shape names, counts, and public digests).

---

## Headline

**No credential material anywhere in the round's artifacts.** A 30-needle sweep over
every file the round created or changed (wave tree, plan, all four counter scripts,
both capture bodies, every seat receipt, the scout's seven stored bodies, the
landed lesson and knowledge entries) returns **0 credential values**. Every hit is a
shape *name* inside a needle list the scout wrote about its own sweep.

**One write-scope violation, now closed on the landed bytes:** a counter that runs
on *tree-controlled text* used that text as a **write destination**, so a tree that
names an absolute or `../` path made the counter overwrite a file outside both the
measured tree and its scratch root. Measured on the blob the wave graded
(`72c9592…`); the L1's later bytes do not reproduce it. A **read** variant of the
same defect is still open on the landed bytes (§V-2).

**One protected-path write in the fleet root** (`scripts/hyaku/__pycache__/…pyc`),
staged into the fleet's next commit and not covered by the fleet `.gitignore` (§V-3).

---

## The four checks

| check | verdict | named items |
|---|---|---|
| 1 — credential material | **CLEAN** (0 values, 2 name-only hits) | I-1 |
| 2 — write scope | 1 HIGH (closed on landed bytes), 1 MEDIUM open, 1 LOW, 1 INFO | V-1, V-2, V-3, V-4, V-5 |
| 3 — parked secrets | **CLEAN** (no secret-named or secret-bearing file anywhere in scope) | — |
| 4 — refusal boundaries | **RESPECTED** (lane refusals + the wave's no-secret rule) | — |
| 5 — canonical run logic: rejection ⇒ zero mutation | **CONFIRMED** on the gate that exists here | R-1 |

---

## Check 1 — credential material (counts only, no values)

Needles swept over `.ufo/waves/round-66/`, `plans/round-66*.sh`, `plans/round-66.md`,
`corpus/lessons/round-66.md`:

```
op:// 0 · Set-Cookie 0 · Cookie: 0 · Authorization: 2 · Bearer 0 · AKIA[0-9A-Z]{16} 0
ghp_/gho_/github_pat_ 0 · xox[baprs]- 0 · AIza 0 · sk-[A-Za-z0-9]{16} 0 · hvs. 0
eyJ… 0 · BEGIN [A-Z ]*PRIVATE KEY 0 · VAULT_TOKEN 0 · X-Vault-Token 0
OP_SERVICE_ACCOUNT_TOKEN 0 · _csrf=[A-Za-z0-9]{16} 0 · csrfmiddlewaretoken 2
```

Both `Authorization:` and both `csrfmiddlewaretoken` hits are **the scout's own
needle list**, in prose, at `.ufo/waves/round-66/w1/R66ScoutSources/notes.md:253-254`
and `.ufo/waves/round-66/w1/R66ScoutSources.md:254-255`. The surrounding text is
the list of patterns it swept with; no value accompanies any of them.

*Capture bodies* (`.ufo/waves/round-66/capture/S148.body`, `S155.body`; and the
scout's seven bodies): a 16-needle sweep ⇒ **0 hits in every body**. Both round-66
captures are XML/HTML (no NUL bytes, no `<script>`, no external-entity DOCTYPE
beyond NCBI's own). The only `token` hits in them are the English word in the
ConText paper's prose ("six-token window") — not credential material.

*Long-string sweep* over all 130+ non-body wave artifacts: every ≥40-char string is
either a lowercase hex digest or a filesystem path/URL. Zero base64-shaped
non-hex strings ⇒ no token-shaped value is parked in any receipt.

*Credential-bearing URLs* (`https://user:pass@host`): 0 in every round-66 artifact.

**I-1 (INFO).** The scout disclosed that one captured body carries third-party
instruction text and that it deliberately did not store that body (only its two
digests), reporting the token rotation as the measurement. I confirmed the
substantive claim independently: no file in the lane contains a `_csrf=<value>`
string; the stored Springer artifact is the 3038-byte challenge shell
(sha `32ed6315…`), which is clean. The disclosed *attribution* is slightly off:
`CAND_arxiv2404_html.body` contains **0** occurrences of `robot`/`emoji`
instruction shapes; the 5 hits live in `LEAD_dlacm_403.body` and are CSS font names
(`Roboto`, `Noto Color Emoji`) plus `meta name="robots"`. Either way the third-party
text was not complied with and **no lane artifact reproduces it**
(`grep -rniE 'robot|emoji'` over the round-66 tree, `corpus/`, `plans/`: 0 hits
outside the stored body itself).

---

## Check 2 — write scope

### V-1 (HIGH at the time; closed on the landed bytes) — a tree-controlled path used as the counter's write destination

`plans/round-66-c1.sh` blob `72c9592362e356d42a7744b0d8581f100f0866ac0402821114d3331ed8c5a549`
(the blob `R66MutC1` graded) resolved the carrier from **text inside the measured
tree** and then used that same string as a copy destination:

```
slot = cand_body or CANON
shutil.copyfile(src_body, os.path.join(dst, slot))
```

`os.path.join(dst, "/abs/path")` returns `/abs/path` — the fixture prefix is
discarded — so the mutated body was written wherever the tree pointed. Measured,
with the tree's own `corpus/volatile-shape.py` `DEFAULT_CAPTURE` set to an absolute
path (all fixtures built under my own scratch; the real lane was never a target):

1. A file **outside the measured tree and outside the scratch root** was
   overwritten: sha `3b8d4e15…` (the S143 carrier) → `49dd5ac4…` (the S157
   404-page body). `=> C1 WROTE OUTSIDE TREE+SCRATCH: True`.
2. On a full copy of the lane tree, the **tree's own committed carrier**
   `.ufo/waves/round-64/capture/S143.body` was overwritten with the S157 body.
   `=> COUNTER OVERWROTE THE TREE'S OWN COMMITTED CAPTURE: True`.

*Impact:* a counter that runs against attacker-influenced trees (the mutation
battery's whole method is to mutate tree text and re-run the counter) is an
arbitrary-file-overwrite primitive with the invoking user's rights. In the
round's own workflow the mutation seats do exactly this.

*Current state:* the landed blob `bd3310b5…` and the present worktree bytes
`6a79a96d…` **do not reproduce it** — the slot is confined and the anchor/fetch
paths are shape-checked. Re-measured on both blobs: victim sha unchanged
(`3b8d4e15…` → `3b8d4e15…`), `=> C1 WROTE OUTSIDE TREE+SCRATCH: False`. The
same class was present in the C3 blob `bbf69b51…` (registry-cited path used as a
copy destination; victim overwritten with the arXiv body); the landed C3 blob
`a6c36b87…` does not reproduce it.

*Smallest remediation (already applied by the L1's hardening):* the carrier path
must be shape-checked (`PATH_RE.fullmatch`) and the copy destination must be
re-derived under the fixture root rather than joined from tree text.

### V-2 (MEDIUM, OPEN on the landed bytes) — the same tree-controlled path used as the counter's *read* target

`resolve_volatile` in the landed C1 returns the raw `DEFAULT_CAPTURE` string with
**no shape check** (unlike `resolve_fetch`, which applies
`PATH_RE.fullmatch`), and `drift_of` then does `os.path.join(root, p)`. For an
absolute `p` that join returns `p`, so the counter reads a file **outside the
measured tree** and prints that absolute path in its receipt. Measured on the
landed blob `bd3310b5…`:

```
c1-carrier: diag volatile:digest-mismatch:/…/OUTSIDE-SCOPE.txt
=> out-of-tree file READ (hashed): True
=> out-of-tree PATH printed in the receipt: True
=> 12-hex digest prefix of the out-of-tree file printed: False
```

Impact is bounded (hash only; no content and no digest prefix are disclosed), but
it is a scope violation the instrument's own header claims ("the measured tree is
only ever read"), and it is the same untrusted-input path that was V-1's write
sink — a one-character change away from a write sink again. The present worktree
bytes `6a79a96d…` behave the same.

*Smallest remediation:* apply the same `PATH_RE.fullmatch` to
`DEFAULT_CAPTURE` that `resolve_fetch` already applies to column 16, and refuse a
path that is not repo-relative under `.ufo/waves/`.

### V-3 (MEDIUM) — a bytecode artifact inside a protected fleet path, staged into the fleet's next commit

`/home/vgpnk/Projects/shokunin/scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc`
exists (29127 B, created **2026-11-08 06:28:08**, i.e. inside the wave window;
the source file's own mtime/size are recorded in the pyc header, and
`co_filename` points at the fleet gate). It is **not tracked by git history**
(`git log` empty) but **is staged in the fleet's jj working copy**:

```
$ git status --porcelain scripts/hyaku/
 A scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc
$ jj status      # fleet root
A scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc
```

The fleet `.gitignore` has **no** `__pycache__` rule (the lane's does), so the
next fleet-root commit can sweep it in. `scripts/` is on the never-edit list.

Mechanism, proven by reproduction: a plain `python3 <script>` run creates **no**
`__pycache__` (verified: running the gate as `__main__` leaves the directory
absent); only *importing* it as a module or `py_compile`-ing it does — I
reproduced the exact artifact shape with
`importlib.util.spec_from_file_location(...)` + `exec_module`, and with
`py_compile.compile(...)`. The wave's own counters all invoke the gate as a
subprocess (`run([sys.executable, GATE, …])`), which cannot create it, and no
round-66 seat artifact names such an import, so **I cannot attribute it to a
seat from local evidence** — it is left open. The time (06:28:08) falls inside
the wave window.

*Smallest remediation:* `rm -rf scripts/hyaku/__pycache__` and add `__pycache__/`
to the fleet `.gitignore` (the lane's `.gitignore` already has it). The L1 should
ask the wave seats whether any imported the fleet gate as a module.

### V-4 (LOW) — the L1's commit captured attack-seat receipts mid-flight

The L1 committed at **06:37:46** (`cfafdb1`, "round-66: instruments …"). The
attack seats `R66MutC1`/`R66MutC2` were still producing receipts at **06:45**
(`R66MutC1/mutants.md` 06:45:02, `R66MutC2/mutants.md` 06:45:16). The commit and
the current worktree therefore disagree on 18 files under
`.ufo/waves/round-66/w1/R66MutC1*/`, `R66MutC2/`, and
`.ufo/waves/round-66/final/c1-selftest.txt` (444 insertions / 5831 deletions of
divergence, including 4 receipt files the commit carries that the worktree no
longer has). The committed tree is not the wave's final receipt set. No seat
committed: the only two round-66 commits are `kagi-shokunin`'s own (`dcd78c2`,
`cfafdb1`).

### V-5 (LOW/INFO) — the control battery writes into the lane by default

`plans/round-66-controls.sh` installs its receipt at
`$REPO/.ufo/waves/round-66/w1/R66ExecControls/controls-last.txt` by default
(`R66_CONTROLS_RECEIPT` re-points it). An instrument whose header says "the
measured tree is only ever read" therefore writes a file inside the tree it
measures — inside a *sibling seat's* receipt directory. **My own audit run of the
battery overwrote that sibling receipt** (`R66ExecControls/controls-last.txt`,
06:45 and again 06:48); it is untracked and the seat's own `controls-live.txt`
(committed) is untouched. I re-ran the battery with the receipt pointed at my own
scratch for the second measurement. The battery did **not** mutate the measured
tree's source: a digest over `corpus/`, `plans/`, `.ufo/waves/round-64`,
`.ufo/waves/round-66/{base,final}` was byte-identical before and after
(`e6d0c1fc…` both sides). My run also left the fleet's protected paths unchanged
(`scripts/`, `templates/`, `.ufo/reports/` digests identical before/after).

### Write scope — what is clean

* **No seat wrote outside the lane repo.** Every lane write is under
  `.ufo/waves/round-66/` (wave dir, base/, capture/, final/, w1/<seat>/) or
  `plans/round-66-{c1,c2,c3,controls}.sh`; the L1 additionally owns
  `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
  `corpus/knowledge/claim-instrument-class-matrix.md`, `corpus/lessons/round-66.md`,
  `SKILL.md`, `SCORECARD.md`.
* **No sibling lane repo** contains a kagi round-66 artifact (swept
  `*/.ufo/waves/round-66/` across every lane: only `kagi-shokunin` and the
  unrelated `kengaku-shokunin` round-66 — checked, not kagi).
* **Protected fleet paths untouched by seats**: `MANIFEST.json` mtime 05:47,
  `.ufo/watchdog.log` 05:47 (host-written), `.ufo/state/` writes are the host's
  own (disk-guard / inline-dispatcher), `templates/` untouched, `shokuknow` and
  `scripts/` (apart from V-3) untouched.
* **No mutating git/jj by a seat**: `git reflog` shows only `export from jj`
  entries; the only round-66 commits carry the `kagi-shokunin` identity
  (`kagi@shokunin.local`) — the L1, the declared sole committer. No push, no
  bookmark move by a seat.
* **No tool installs**: no `pacman -S`, `pip install`, `uv tool install`,
  `npm install` in any round-66 artifact; `~/.local/bin` has no file with today's
  mtime.
* **No model alias hardcoded** in any round-66 artifact (`claude-*`, `gpt-*`,
  `gemini-*`, `qwen`, `llama-*` … : 0 hits).

### Frozen-item discipline (adjacent, not my lane but checked)

`plans/round-66.md` is **append-only** since the freeze: `git diff dcd78c2 --
plans/round-66.md` has **0 deletion lines**, and the A1–A4 amendments are appended
below the freeze with the measurements that forced them. The frozen predicate text
was not rewritten. The counters were re-authored afterwards (blob churn:
`72c9592…` → `178a369d…` → `221a2cd7…` → `bd3310b5…`/`6a79a96d…` for C1), which is
the executor's own file, not the frozen plan.

---

## Check 3 — parked secrets

* **No secret-named file** anywhere in scope: a filename sweep for `*.env`,
  `op.env`, `*.key`, `*.pem`, `*.netrc`, `pip.conf`, `root_token`, `token*`,
  `secrets.json`, `*credential*` over `/fast/scratch/hyaku/kagi-r66/` and the
  fleet root ⇒ **0 hits** (the only matches are pre-existing lane corpus *names*
  like `corpus/knowledge/openbao-approle-secret-id-custody.md`, tracked files
  whose content holds no secret).
* **The lane's own secret state is absent on this host**: `~/.config/the-janitor/op.env`,
  `~/.config/opencode/agents/janitor.md` and `~/.local/state/the-janitor` do not
  exist; no `janitor` tmux session is running; no `~/.netrc`, no `pip.conf`,
  no venv in the lane.
* **Prior-round kagi scratch** (`kagi-r61`, `kagi-r65`, `chousa-r89`, …): needle
  scan of `kagi-r61` ⇒ 0/0/0/0/0/0 across six credential shapes. The
  `kagi-r62`/`kagi-r65` scans did not complete inside my request budget — I
  report them as **not measured**, not as clean.
* **Host-wide**: no OpenBao/vault state directory and no credential file parked
  under `/fast/scratch/hyaku/`.
* The scout's withheld Springer body is the one "secret-shaped" artifact of the
  round and it was **not** parked: it exists in no file; only its two public
  digests were recorded.

---

## Check 4 — refusal boundaries

The lane's declared refusals (`PROVINCE.md:83`) are intact in this round:

* **vault-side structure stays unmapped** — 0 `op://` reference paths, 0 vault item
  or field names in any round-66 artifact (the only `op://` in the lane is the
  single synthetic placeholder in the pre-existing, tracked
  `corpus/op-ref-probe.sh`, whose literal carries placeholder words).
* **`op` item-level reads stay unexercised** — no `op` invocation, no
  `op signin`/`op whoami`/`op vault list` in any round-66 artifact.
* **the CDP lease/profile ownership question is reported, not adjudicated** — no
  CDP adjudication in the round's artifacts.
* **no host substrate was touched**: no `bao server`, `age-keygen`, `sops` run; no
  package install; `~/.local/bin` untouched.
* **the wave's own no-secret rule held**: no seat printed, copied or exfiltrated a
  secret value, token, cookie or vault ref path. The one body carrying a live
  CSRF token was deliberately withheld by its owner and only its digests kept
  (confirmed by scanning every artifact for `_csrf=<value>`: 0).
* **no credential-bearing URL or scp/ssh target** in any artifact.
* **third-party instruction text** in a captured body was not complied with and
  is not reproduced in any lane artifact (I-1).

---

## Check 5 — the canonical run logic's rejection ⇒ zero mutation

The named gate `resume_continuity_v1` has **no implementation in this lane**: an
active-source search over `corpus/`, `plans/`, `tools/` (absent) and the fleet's
`scripts/hyaku/` finds no implementation — only prose mentions in other lanes'
reports (the same absence the kengaku lane recorded for its own round 66). There
is therefore no such artifact to attack here.

I substituted the run logic that **does** exist for this round — the fleet
pre-file gate `scripts/hyaku/prefile-falsification.py`, which the C2 counter and
the control battery both invoke, and whose refusal paths are the round's
rejection behaviour — and measured zero mutation on both refusal paths, on a
scratch copy of the fleet (never the real tree):

* **setup refusal** (missing claims.json / wave results / ledger / report ⇒
  `PREFILE-FALSIFICATION: SETUP findings=4`, exit 2): the whole scratch tree's
  file set and sizes were byte-identical before and after
  ⇒ **ZERO-MUTATION ON SETUP REFUSAL: confirmed**.
* **`--init` overwrite refusal** (`refusing to overwrite …`, exit 2): the scratch
  tree digest was identical before and after
  ⇒ **ZERO-MUTATION ON REFUSAL: confirmed**.

The dispatcher's own rejection/defer paths (`disk-defer`, `host-defer`,
`spawn-cap`) write only `<ready>.partial` bookkeeping under the wave dir and
remove it on completion — the round-66 wave dir holds **no** `*.partial*` residue
now, and the lane tree is unchanged by them.

---

## Named findings

| id | severity | finding | smallest remediation |
|---|---|---|---|
| **V-1** | **HIGH** (closed on landed bytes) | `plans/round-66-c1.sh` blob `72c9592…` used a path read out of the measured tree as the mutation leg's **copy destination**; an absolute or `../` path made it overwrite a file outside the tree **and** outside the scratch root, and (on a lane copy) the tree's own committed carrier `capture/S143.body` | landed bytes confine the slot and shape-check the anchor/fetch paths — keep that check on **every** tree-supplied path, including `DEFAULT_CAPTURE` |
| **V-2** | **MEDIUM** (OPEN) | landed C1 `resolve_volatile` accepts any `DEFAULT_CAPTURE` string; `os.path.join(root, p)` then **reads a file outside the measured tree** and prints its absolute path in the receipt | apply `PATH_RE.fullmatch` to `DEFAULT_CAPTURE` exactly as `resolve_fetch` applies it to column 16 |
| **V-3** | **MEDIUM** | `scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc` (created 06:28:08, inside the wave window) sits in a protected fleet path, is staged in the fleet's jj working copy, and is not covered by the fleet `.gitignore` | `rm -rf scripts/hyaku/__pycache__`; add `__pycache__/` to the fleet `.gitignore`; ask the seats whether any imported the fleet gate as a module |
| **V-4** | LOW | the L1's 06:37 commit captured `R66MutC1`/`R66MutC2` receipts mid-flight (18 files diverge from the worktree) | re-commit the wave's final receipts before the round closes |
| **V-5** | LOW/INFO | `plans/round-66-controls.sh` writes its receipt into the lane (a sibling seat's receipt dir) by default | default the receipt to the invoking seat's scratch; point `R66_CONTROLS_RECEIPT` at scratch |
| **I-1** | INFO | the scout's third-party-instruction disclosure attributes the text to `CAND_arxiv2404_html.body`; that file has 0 `robot`/`emoji` hits (the 5 are CSS font names in `LEAD_dlacm_403.body`) | note the corrected attribution in the lesson; the substance (not complied with, not reproduced) is confirmed |
| **I-2** | INFO | `.ufo/waves/round-66/claims.json` still carries the pre-amendment `C2_CLAIMS`/`C3_SELFREF` title+target pairs while the landed counters measure `C2_PREFILE`/`C3_CENSUS` (Amendments A2/A3) | re-derive `claims.json` from the amended plan, or state in the lesson which pairs are the round's claims |
| **R-1** | — | `resume_continuity_v1` has no implementation in this lane; the substitute run logic's two refusal paths were measured zero-mutation | none; record the substitution |

---

## Note for the L1 on the milestone wording (calibration, not a scope claim)

The wave's milestone says "C2 claims.json exact 0->1 (frozen plan + amendments)".
After Amendments A2/A3 the C2 and C3 counters no longer measure a
`(title,target)` equality against `claims.json`: landed C2 measures the pre-file
gate (`C2_PREFILE: gate=A claims=3 rows=R attack_seats=K guard=G`) and landed C3
measures the lane census's own `findings=` line (`C3_CENSUS: findings=0 rows=R
guard=G`). The pre-amendment tags `C2_CLAIMS` / `C3_SELFREF` still printed by the
earlier blobs are gone from the landed instruments. My own readings on the landed
bytes:

```
C2_CLAIMS/C2_PREFILE : exact leg reads 1 on the untouched tree (claims.json already
                       carries the frozen headings) — guard-c prefile=0 rc=2 while
                       the wave results file and the round report do not exist,
                       guard-d claims-declared reads claims=56 (not 59)
C3_CENSUS            : findings=4 (lane gate, SC_FETCH S155/S156 + SC_BODY_CITE
                       S148/S156) at BASE; findings=0 on the L1's repaired tree
CONTROLS             : match=8 mismatch=2 — C2-FORGE and C2-VALID are the two
                       that cannot reach their expectation while the pre-file gate
                       still reads SETUP
```

That is the same condition `R66Reviewer` F5/F6 and `R66Critic` filed. I add one
sentinel-specific datum: on the **landed** C1 blob the `--selftest` reports
`cases=43 failed=2 names=volatile-path-shape,three-anchors-one-path` on a tree
whose `DEFAULT_CAPTURE` is not a repo-relative capture path — the counter's own
selftest already *detects* the bad shape and the counter proceeds anyway (V-2).

---

Tools: none installed or upgraded (no pacman transaction; the host's pacman pause
respected). Only pre-installed `bash`, `python3`, `git`, `jj` (read-only queries),
`grep`, `find`, `sha256sum`, `stat`, `du`, `cmp`, `cmp -l`, `sed -n`.

Scratch: `/fast/scratch/hyaku/kagi-r66/R66Sentinel/` — every fixture, tree copy
and probe was built there, never in the lane, the fleet root, or a sibling repo.
Deleted on exit.

SEAT-STATUS: complete
