# R66Sentinel — secret-discipline and write-scope audit (kagi round 66, wave 1)

Seat: sentinel (attack seat). Scope: credential material, write-scope violations,
parked secrets, refusal-boundary respect, and the zero-mutation property of the
canonical run logic's refusal paths. Read-only apart from this report and its
receipt; no secret value is printed in either.

Full receipt with every command and its output:
`.ufo/waves/round-66/w1/R66Sentinel/audit.md`.

**Disclosure:** my audit ran the round's own control battery
(`plans/round-66-controls.sh`) to measure its write scope. That battery installs
its receipt into a sibling seat's directory by default, so my run **overwrote**
`.ufo/waves/round-66/w1/R66ExecControls/controls-last.txt` (untracked; the seat's
committed `controls-live.txt` is untouched); the second measurement used
`R66_CONTROLS_RECEIPT` pointed at my own scratch. No lane source, no protected
fleet path and no sibling repo was written by me.

## Headline

**No credential material anywhere in the round's artifacts.** A 30-needle sweep
over every file the round created or changed returns **0 credential values**; the
only hits are needle *names* in the scout's own sweep list
(`R66ScoutSources/notes.md:253-254`, `R66ScoutSources.md:254-255`). Every ≥40-char
string in every receipt is either a hex digest or a path — no token-shaped value
is parked anywhere.

**One HIGH write-scope defect, closed on the landed bytes; its read-side twin is
still open.** The C1 counter resolved the carrier from *text inside the measured
tree* and used that string as a **copy destination**. `os.path.join(dst,
"/abs/path")` discards the fixture prefix, so a tree naming an absolute path made
the counter overwrite a file outside both the measured tree and its scratch root
(measured: a victim outside tree+scratch, and on a lane copy the tree's own
committed `capture/S143.body`, overwritten with the S157 404-page body). That blob
(`72c9592…`) is the one the wave's mutation seat graded. The L1's later bytes
(`bd3310b5…` landed, `6a79a96d…` in the worktree) do not reproduce the write.

The **read** variant survives on the landed bytes: `resolve_volatile` accepts any
`DEFAULT_CAPTURE` with no shape check, so `os.path.join(root, p)` **reads a file
outside the measured tree** and prints that absolute path in the receipt
(measured on landed `bd3310b5…`: `volatile:digest-mismatch:/…/OUTSIDE-SCOPE.txt`).
No content and no digest prefix are disclosed, but it is the same untrusted path
that was one character away from a write sink.

**One protected-path write in the fleet root:** `scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc`
(created 06:28:08, inside the wave window) sits in a never-edit path, is **staged**
in the fleet's jj working copy, and the fleet `.gitignore` has no `__pycache__`
rule (the lane's does). A plain script run cannot create it — only importing the
gate as a module or `py_compile`-ing it does (both reproduced); the wave's own
counters invoke the gate as a subprocess and cannot. I could not attribute it to
a seat from local evidence.

## The four checks

| check | verdict | named items |
|---|---|---|
| credential material | **CLEAN** — 0 values, 2 name-only hits | I-1 |
| write scope | 1 HIGH (closed on landed bytes), 1 MEDIUM open, 1 MEDIUM (fleet path), 2 LOW/INFO | V-1…V-5 |
| parked secrets | **CLEAN** — no secret-named or secret-bearing file in scope | — |
| refusal boundaries | **RESPECTED** — lane refusals and the wave's no-secret rule both hold | — |
| canonical run logic: rejection ⇒ zero mutation | **CONFIRMED** on the gate that exists here | R-1 |

## Refusal boundaries — respected

The lane's declared refusals (`PROVINCE.md:83`) hold: **0** `op://` reference
paths and **0** vault item/field names in any round-66 artifact (the lane's only
`op://` is the synthetic placeholder in the pre-existing tracked
`corpus/op-ref-probe.sh`); **no** `op` invocation; **no** CDP adjudication; **no**
host substrate touched (no `bao`/`age`/`sops` run, no package install, no
`~/.local/bin` file with today's mtime); **no** credential-bearing URL or
scp/ssh target; **no** secret value printed, copied or exfiltrated.

The scout's withheld Springer body — the one secret-shaped artifact of the round —
is **not parked in any file**: only its two public digests were recorded, and a
sweep for `_csrf=<value>` across the round returns 0. Third-party instruction text
in a captured body was not complied with and is not reproduced in any lane
artifact (corrected attribution in I-1).

## Parked secrets — clean

Filename sweep for `*.env`, `op.env`, `*.key`, `*.pem`, `*.netrc`, `pip.conf`,
`root_token`, `token*`, `secrets.json`, `*credential*` over the wave scratch and
the fleet root ⇒ 0 hits (only pre-existing *lane corpus filenames* whose content
holds no secret). The lane's own secret state is absent on this host
(`~/.config/the-janitor/op.env`, `~/.config/opencode/agents/janitor.md`,
`~/.local/state/the-janitor` do not exist; no `janitor` session runs); no
`~/.netrc`, no `pip.conf`, no venv. Prior-round kagi scratch `kagi-r61` scans
0/0/0/0/0/0 across six credential shapes; `kagi-r62`/`kagi-r65` did **not**
finish inside my request budget and are reported as *not measured*, not as clean.

## Zero mutation on rejection (the `resume_continuity_v1` analogue)

`resume_continuity_v1` has **no implementation in this lane** (active-source search
over `corpus/`, `plans/`, `tools/` — absent — and the fleet's `scripts/hyaku/`:
no implementation; only prose mentions in other lanes' reports, the same absence
kengaku recorded for its round 66). I substituted the run logic that does exist
here — the fleet pre-file gate `scripts/hyaku/prefile-falsification.py`, invoked
by the C2 counter and the control battery — and measured, on a scratch copy of the
fleet (never the real tree): **setup refusal** (`SETUP findings=4`, exit 2) leaves
the file set and sizes byte-identical, and the **`--init` overwrite refusal**
(`refusing to overwrite …`, exit 2) leaves the tree digest identical. Both
refusals are zero-mutation. The dispatcher's own defer/cap paths write only
`<ready>.partial` bookkeeping, which the round-66 wave dir does not retain.

## Named findings

| id | severity | finding | smallest remediation |
|---|---|---|---|
| **V-1** | **HIGH** (closed on landed bytes) | C1 blob `72c9592…` used a tree-supplied path as its mutation leg's **copy destination**; an absolute/`../` path overwrote a file outside the tree **and** outside scratch (and, on a lane copy, the tree's own committed carrier) | keep the landed confinement; shape-check **every** tree-supplied path |
| **V-2** | **MEDIUM** (OPEN) | landed C1 `resolve_volatile` accepts any `DEFAULT_CAPTURE`; the counter then **reads a file outside the measured tree** and prints its absolute path in the receipt | apply `PATH_RE.fullmatch` to `DEFAULT_CAPTURE` as `resolve_fetch` already does for column 16 |
| **V-3** | **MEDIUM** | `scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc` in a protected fleet path, staged in the fleet jj working copy, not covered by the fleet `.gitignore` | `rm -rf scripts/hyaku/__pycache__`; add `__pycache__/` to the fleet `.gitignore`; ask the seats whether any imported the gate as a module |
| **V-4** | LOW | the L1's 06:37 commit captured `R66MutC1`/`R66MutC2` receipts mid-flight; 18 wave files diverge from the worktree | re-commit the wave's final receipts before the round closes |
| **V-5** | LOW/INFO | the control battery writes its receipt into the lane (a sibling seat's dir) by default | default the receipt to the invoking seat's scratch (`R66_CONTROLS_RECEIPT`) |
| **I-1** | INFO | the third-party-instruction disclosure attributes the text to `CAND_arxiv2404_html.body`; that file has 0 `robot`/`emoji` hits (the 5 are CSS font names in `LEAD_dlacm_403.body`) | note the corrected attribution in the lesson; the substance (not complied with, not reproduced) is confirmed |
| **I-2** | INFO | `claims.json` still carries the pre-amendment `C2_CLAIMS`/`C3_SELFREF` pairs while the landed counters measure `C2_PREFILE`/`C3_CENSUS` (A2/A3) | re-derive `claims.json` from the amended plan, or state which pairs are the round's claims |
| **R-1** | — | `resume_continuity_v1` unimplemented here; the substitute gate's two refusal paths measured zero-mutation | none; record the substitution |

## L1 calibration note (adjacent, not a scope claim)

On the landed bytes I measure: C2's exact leg reads **1 on the untouched tree**
(`claims.json` already carries the frozen headings) while `guard-c prefile=0 rc=2`
(the wave results file and the round report do not exist yet) and `guard-d`
reads `claims=56`, not 59; C3 reads `findings=4` at BASE (lane gate:
SC_FETCH S155/S156 + SC_BODY_CITE S148/S156) and `findings=0` on the repaired
tree; the control battery reads `match=8 mismatch=2`, the two mismatches being
the C2 legs that cannot reach expectation while the pre-file gate still reads
SETUP. One sentinel-specific addition to the attack seats' findings: on the landed
C1 the `--selftest` reports `cases=43 failed=2 names=volatile-path-shape,…` on a
tree whose `DEFAULT_CAPTURE` is not a repo-relative capture path — the counter's
own selftest **detects** the bad shape and the counter proceeds anyway (V-2).

Frozen-item discipline checked and clean: `plans/round-66.md` is append-only
since the freeze (`git diff dcd78c2 -- plans/round-66.md` ⇒ 0 deletion lines);
the frozen predicate text was not rewritten.

Tools: none installed or upgraded; no pacman transaction. Scratch
`/fast/scratch/hyaku/kagi-r66/R66Sentinel/` held every fixture and tree copy and
was deleted on exit.

SEAT-STATUS: complete
