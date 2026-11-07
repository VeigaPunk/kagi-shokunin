# R56MutCounter — pre-freeze mutation report (kagi round 56, attempt 1)

Seat: R56MutCounter (mutation tester, leaf; no subagent dispatch, no task tool).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Lane HEAD at test time: `42070de7770e1558adcf6aa7a7bc59309a9654d7` (round-56 predeclaration). The
counter, plan, controls, gate, manifest, entries and all ten captures are byte-identical between
that commit, the working tree and the tree I mutated (§9).
Observed answering model: `amr/deepseek-v4.1-flash` (declared by the session's project-context
block, not inferred from this prompt).

Target instrument (tested, unmodified):
- `plans/round-56-c1.sh` sha256 `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a`
- `corpus/recheck-replay.py` sha256 `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8`
- `corpus/recheck-captures.tsv` sha256 `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`
- `plans/round-56-controls.sh` sha256 `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094`
- `plans/round-56.md` sha256 `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07`

No production file was edited. The whole attack surface was exercised through `--tree` on copies
under `/fast/scratch/hyaku/kagi-r56/R56MutCounter/`.

## 0. Verdict in one paragraph

The counter is **sound relative to its own frozen predicate** on r1, r3, r4 and on fail-closed
setup: every entry/capture/manifest/symlink/digest/normaliser defect I made either reduced the
reading or zeroed it, and the detector separates no-work (BASE ⇒ `value=0`) from positive
(landing tree ⇒ `value=10`). It is **not yet discriminating on four conjuncts**: (i) r5 counts a
measured-tree `recheck-replay.py` that performs no replay at all, as long as it prints the ten
`MATCH` lines and a `CLEAN` last line — including one reached through a symlink, and including one
that exits 1 (F1); (ii) GUARD accepts a vacuous `--selftest` that prints
`RECHECK_REPLAY_SELFTEST: PASS (0 cases)` (F2); (iii) r2 ignores the manifest's `http_status` and
`fetched` cells, so a capture recorded as a 404 fetch scores (F3); (iv) nothing binds a row's
`body_path` to its URL/id beyond the digest, so S101 and S114 can both be "replayed" against the
S113 page while the gate itself prints `MATCH` (F4). Separately the counter hangs (rc 124 at 25 s)
on a FIFO named `corpus/knowledge/*.md` (F5), and one existing control (F5 printer-gate) passes
for the wrong reason because its printer is bash and the counter runs the gate with `python3`
(F6). These are coverage findings, not licence to change the contract.

## 1. Method

Reference tree = working-tree bytes needed by the two instruments:
`tar -cf - corpus plans/round-56-c1.sh .ufo/waves/round-45/controls/capture-r45
.ufo/waves/round-55/capture .ufo/waves/round-56/capture | tar -xf - -C ref` (216 files, 6.3 MB).
Every mutant is `cp -a ref m/<id>` plus exactly one recipe from `mutate.py`
(sha256 `a3b1d0a2…`, copied verbatim to `R56MutCounter.d/mutate.py`).

Counter invocation, one per tree:

```
cd /fast/scratch/hyaku/kagi-r56/R56MutCounter
HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r56/R56MutCounter \
  bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-56-c1.sh --tree m/<id>
```

`HYAKU_SCRATCH` was redirected into my own scratch so the counter's `$SCR` never touches a
sibling's `/fast/scratch/hyaku/kagi-r56/c1.*`. Every non-SETUP run above exited **0** regardless
of the reading (measured, 43/43): the printed `C1_REPLAY:` line is the only verdict channel, rc 0
must not be read as a pass. SETUP probes exit 2 (§4).

## 2. Baselines (detector is live)

| tree | command | reading | rc |
|---|---|---|---|
| P0 positive | `--tree ref` | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| N0 no-work | `--tree base` (`git archive 832ba6a`) | `value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:…×10)` | 0 |
| N0' no-work | `832ba6a53d6a76706b5c80bce2278683dea33d42` (revision path) | identical to N0 | 0 |
| gate direct | `python3 -I -B ref/corpus/recheck-replay.py --root ref` | 10 `MATCH` lines, then `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` | 0 |
| gate selftest | `… --selftest` | `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` | 0 |

Field detail of the positive run (the ten ids the gate binds): S055, S070, S101, S113, S114, S074,
S078, S067, S054, S057.

## 3. Mutant matrix (43 runs; recipes in `R56MutCounter.d/mutate.py`)

`got` is the counter's `value=` token. Killed = reading fell (a r5/DRIFT cascade is reported as
0 because the gate refuses the same defect, which is fail-closed). Survived = still 10.

| id | axis / exact edit (file:bytes changed) | mutant sha256 of changed file | got | verdict |
|---|---|---|---|---|
| R1a | trufflehog entry `recheck:` line body → `recheck: 180d — on-change — reopen the docs page` | `046469a2…f2b6` | FAIL | killed (r1 absent) |
| R1b | betterleaks `by default'\` -> 1` → `-> 2` | `4fbd339c…6252` | FAIL | killed (r1 absent) |
| R1c | betterleaks + trailing line `recheck: 90d — on-change — reopen` | `29ec920b…a291` | FAIL | killed (2 recheck lines) |
| R1d | betterleaks command URL `'…'` → `"…"` (same URL, other quote bytes) | `8efccd74…d044` | FAIL | killed (command bytes pinned) |
| R1e | betterleaks `-> 1` → `-> count=1` | `71fa2b7d…f55d` | 10 | allowed form (predicate r1) |
| R1f | betterleaks `-> 1` → `-> 10` | `40395778…18b5` | FAIL | killed (`(?!\d)` + gate MISMATCH) |
| R1g | betterleaks `(ran 2026-10-23)` → `(ran 2026-11-06)` | `acac40ee…7fa8` | 10 | prose only (correct) |
| R2a | manifest S054 row deleted | `0c18d1b7…1c11` | 0 | killed (r2-rows0 + gate DRIFT) |
| R2b | manifest S054 row appended twice | `ba39ff2f…5de0` | 0 | killed (r2-rows2; gate SETUP duplicate-url) |
| R2c | registry S054 row appended again (outside fences) | `87fa6f34…53a6` | 9 | killed by counter only (gate CLEAN) |
| R2d | registry S113 status cell `mined` → `staged` | `ee021fd3…f36e` | 9 | killed by counter only (gate ignores status) |
| R2e | registry S070 URL moved from source cell to teaches cell | `ae4a9f5e…89dd` | 9 | killed by counter only (gate regex scans whole line) |
| R2f | registry S074 row deleted, re-added inside a ``` fence | `a2988720…4d54` | 9 | killed by counter only (gate has no fence logic) |
| R2g | manifest header `bytes\tsha256` → `sha256\tbytes` | `93601330…d1cf` | 0 | killed (header) |
| R2h | manifest S054 row `id` → `S055` | `f4b3af25…89d8` | 0 | killed (r2-registry) |
| R2i | manifest S054 `http_status`→`404`, `fetched`→`1999-01-01` | `fd326652…091e` | **10** | **survived — F3** |
| R2j | manifest S101 `body_path`→`.ufo/waves/round-55/capture/S113.body`, bytes `90604`, sha `d8dfe354…4357` | `f3bcd94b…7bc5` | **10** | **survived — F4** |
| R2k | manifest S114 `body_path`→same S113 body/bytes/sha | `6e6e7e8e…9eac` | **10** | **survived — F4** |
| R3a | append `x` to S054.body (digest untouched) | `dd68a339…bd5a` | 0 | killed (r3-digest) |
| R3b | manifest S054 `body_path` → absolute path | `62602295…a386` | 0 | killed (r3-path) |
| R3c | manifest S054 `body_path` → `../../S054.body` | `16440b97…721d` | 0 | killed (r3-path) |
| R3d | S055.body moved to tree root, capture dir entry → symlink `../../../../s055.body` | symlink | 0 | killed (r3-file; gate symlink) |
| R3e | S057.body prefixed `HTTP/2 200\r\nset-cookie: x=1\r\n\r\n`, manifest bytes/sha refixed | `5d28e743…327e` / `04dbd215…91b3` | 0 | killed (r3-headers) |
| R3f | `\nSet-Cookie: y=2\n` inserted mid S074.body, manifest refixed | `f3421743…09f2` / `51ea192e…236b` | 0 | killed (r3-headers) |
| R3g | S054.body replaced by one line `it can also log in to confirm if that secret is live or not`, manifest refixed | `253e4823…56b7` / `d8d9c209…74dc` | **10** | **survived — named ceiling** |
| R4a | one more pattern line appended to S054.body, manifest refixed | `047c3f17…b327` / `6893ac38…07fa` | 0 | killed (r4-replay2) |
| R4b | *flawed recipe*: quote edited in the CDP **entry** (hits r1, not r4) | `00cc0db7…f504` | FAIL | inconclusive for r4 — superseded by R4b2 |
| R4b2 | S070.body quote → `…using a variant OIDC token`; tree normaliser `locate` forced to `count=1`; BASE normaliser untouched; manifest refixed | base count **0**, tree count 1 | **9** | killed by r4 (`r4-replay0`), gate CLEAN — normaliser isolation works |
| R4c | `corpus/rendered-text-v1.py` deleted from tree | (absent) | 0 | killed (gate TOOL ⇒ DRIFT) |
| R5a | gate → bash `CLEAN` printer (plan's F5 recipe) | `c441d71f…a401` | FAIL | killed, **wrong reason** (F6) |
| R5b | gate → Python printer emitting the ten exact `MATCH` lines + `CLEAN` + `PASS (13 cases)`, rc 0 | `48b75d82…ce8e` | **10** | **survived — F1** |
| R5c | same printer, run path `sys.exit(1)` | `1cc536c9…f557b` | **10** | **survived — F1 (rc ignored)** |
| R5d | real gate print patched: betterleaks line `id=S055`→`id=S999` | `803f6676…94b0` | 9 | killed (r5 id pinned) |
| R5e | real gate print patched: cdp line `form=locate`→`form=grep` | `e280ce72…f33a` | 9 | killed (r5 form pinned) |
| R5f | real gate `clocks()` skips `betterleaks*` (clocks=9, still CLEAN) | `b56d7ae8…4af4` | 9 | killed (per-clock MATCH line required) |
| R5g | gate → absolute symlink to the R5b printer outside the tree | symlink | **10** | **survived — F1 (gate file not confined)** |
| R5h | real gate `main`: `return run(root)` → `return rc if rc else 1` | `0a576fe1…5b8d` | FAIL | killed via `selftest` (the gate's own 13 cases assert rc) |
| G1 | selftest prints `PASS (13 cases)` then `return 1` | `ef5aa73c…4e1f` | FAIL | killed (selftest rc) |
| G2 | selftest prints `PASS (13 cases)` then `trailing noise line` | `f0a52f22…1e0b` | FAIL | killed (last line) |
| G3 | `selftest()` gutted: first statement `print("RECHECK_REPLAY_SELFTEST: PASS (0 cases)"); return 0`; run path untouched | `f2e16726…c337` | **10** | **survived — F2** |
| G4 | `corpus/recheck-replay.py` replaced by a directory | (dir) | FAIL | killed (gate 0, guard 0) |
| N2 | gate file deleted, everything else intact | (absent) | 0 | predicate-consistent (guard 1, value 0) |
| Z1 | `mkfifo corpus/knowledge/zzz-fifo.md` | (fifo) | — | **no reading: hangs, timeout 25 ⇒ rc 124 — F5** |

Exact observed first lines for every row are in `R56MutCounter.d/matrix.tsv`; full JSON
(`changed` hash map, rc, stderr tail) in `R56MutCounter.d/results.json`.

## 4. Setup probes (all run; all fail closed, rc 2)

PATH built from `/usr/bin` symlinks so exactly one tool is missing; `HYAKU_SCRATCH` in my scratch:

| probe | command | output | rc |
|---|---|---|---|
| no python3 | PATH=<no python3> `--tree ref` | `C1_REPLAY: SETUP no-python3` | 2 |
| no pdftotext | PATH=<no pdftotext> `--tree ref` | `C1_REPLAY: SETUP no-pdftotext` | 2 |
| no grep | PATH=<no grep> `--tree ref` | `C1_REPLAY: SETUP no-grep` | 2 |
| bad revision | `deadbeefdeadbeef` | `C1_REPLAY: SETUP bad-revision` | 2 |
| no revision | no args | `C1_REPLAY: SETUP no-revision` | 2 |
| tree missing | `--tree /nonexistent/tree` | `C1_REPLAY: SETUP tree` | 2 |
| scratch unusable | `HYAKU_SCRATCH=/proc/nope --tree ref` | `C1_REPLAY: SETUP scratch` | 2 |

The declared fail-closed list in the counter header is therefore verified as written.

## 5. Findings — missing killing inputs (draft-changing, before freeze)

### F1 (medium) r5 counts a gate that never replays; gate rc and gate file identity not checked

Evidence. (a) R5b: `corpus/recheck-replay.py` replaced by a 15-line Python printer that prints the
ten real `MATCH` lines (`MATCH corpus/knowledge/…:N id=… form=… stated=N replayed=N`) then
`RECHECK_REPLAY: CLEAN (clocks=10 …)`; reading `value=10 present=10 replayed=10 gate=1 guard=1`,
rc 0. Its stdout is **byte-identical** to the real gate's stdout (`R5b stdout identical to real
gate: True`). (b) R5c: same printer, `sys.exit(1)` on the run path: still **10** — gate invocation
rc is ignored (`gate_clean` is computed from the last non-empty line only). (c) R5g: tree's gate
replaced by an absolute symlink to that printer outside the tree: still **10**. (d) Discrimination
probe, run by me on each tree after appending one byte to `S054.body`:
`ref-real-gate rc=1 BAD-CAPTURE=yes`, `R5b rc=0 BAD-CAPTURE=no`, `R5c rc=1 BAD-CAPTURE=no`,
`R5g rc=0 BAD-CAPTURE=no`. The predicate's r5 sentence is satisfied by a non-replaying file, so the
"replayed true **by a lane gate**" clause of the claim is unenforced: the substance rests entirely
on r4, and the deliverable's own gate can be any printer.

Note what is *not* broken: with genuine bodies, r4 still replays the ten clocks correctly, so F1
cannot manufacture a true statement out of a false one; it lets a non-discriminating gate ship as
the claimed capability.

Proposed counter edit (r5, after `gate_clean`):

```python
# r5': the measured gate must discriminate. Run it on a copy of the tree with one
# capture byte appended; require nonzero rc and a BAD-CAPTURE or MISMATCH line.
import shutil, tempfile
probe = tempfile.mkdtemp(dir=SCR)
shutil.copytree(str(T), probe, dirs_exist_ok=True)
b = Path(probe) / rel_confined_body_of_first_present_clock   # any r3-confirmed body
b.write_bytes(b.read_bytes() + b"x")
r = subprocess.run([sys.executable, "-I", "-B",
                    str(Path(probe) / "corpus/recheck-replay.py"), "--root", probe],
                   capture_output=True, text=True, timeout=300)
gate_discriminates = (r.returncode != 0
                      and re.search(r"^(BAD-CAPTURE|MISMATCH) ", r.stdout, re.M) is not None)
```

and make r5's gate run rc-bearing: `[ -f "$T/corpus/recheck-replay.py" ] && [ ! -L … ]`; require
`rc == 0` from the `--root` run. Proposed new controls (expectation *today*, before the edit):

```bash
# F13 Python printer gate: exact MATCH lines + CLEAN + PASS selftest, no replay at all
mk_ref f13
py 'import sys,subprocess
root=sys.argv[1]; g=root+"/corpus/recheck-replay.py"
out=subprocess.run([sys.executable,"-I","-B",g,"--root",root],capture_output=True,text=True).stdout.splitlines()
open(g,"w").write("import sys\nLINES=%r\nif sys.argv[1:2]==[\"--selftest\"]:\n    print(\"RECHECK_REPLAY_SELFTEST: PASS (13 cases)\"); sys.exit(0)\nfor l in LINES: print(l)\nsys.exit(0)\n" % out)' "$SCR/f13"
check K1-F13-python-printer-gate 10 f13      # 10 today; must read 0 after r5'
# F16 gate as symlink to that printer, outside the tree
mk_ref f16; rm "$SCR/f16/corpus/recheck-replay.py"; ln -s "$SCR/f13/corpus/recheck-replay.py" "$SCR/f16/corpus/recheck-replay.py"
check K1-F16-gate-symlink 10 f16             # 10 today; must read 0 after r5'
```

### F2 (medium) GUARD accepts a vacuous `--selftest`

Evidence. G3: the gate's `selftest()` replaced at its first statement by
`print("RECHECK_REPLAY_SELFTEST: PASS (0 cases)"); return 0` (dead code below), run path untouched;
gate sha256 `f2e16726e97005205667eb7d8051687834b274c9aee794f4bd85c6653174c337`; reading
`value=10 … gate=1 guard=1 (bad=none)`. The counter's check is a prefix match
(`case $last in "RECHECK_REPLAY_SELFTEST: PASS"*`), so zero executed cases pass. The gate's
*run* is still real here, so this overstates the capability: the 13-case self-test is part of the
declared landing ("a `--selftest` of 13 cases").

Proposed edit (counter, guard block) — pin the case count, matching the real gate's line:

```bash
case $last in "RECHECK_REPLAY_SELFTEST: PASS (13 cases)"*) SELF_OK=1 ;; esac
```

Proposed predicate wording: "…`--selftest` exits 0 with last line
`RECHECK_REPLAY_SELFTEST: PASS (13 cases)`." Control:

```bash
mk_ref f14
py 'import sys
p=sys.argv[1]+"/corpus/recheck-replay.py"; s=open(p).read()
t=s.replace("def selftest():\n    cases = []",
 "def selftest():\n    print(\"RECHECK_REPLAY_SELFTEST: PASS (0 cases)\")\n    return 0\n    cases = []")
assert t!=s; open(p,"w").write(t)' "$SCR/f14"
check K1-F14-vacuous-selftest 10 f14          # 10 today; must read FAIL after the edit
```

### F3 (medium) r2 ignores the manifest's `http_status` and `fetched` cells

Evidence. R2i: `corpus/recheck-captures.tsv` S054 row cells 4/5 changed to `404` / `1999-01-01`
(manifest sha256 `fd3266526f683fd18dcb1b506f948ecdf45b14e6848f42fcdd1250888e3e091e`); reading
`value=10 … (bad=none)`. A capture recorded from an error response, or one that was never fetched
on the stated date, is indistinguishable from a 200 body. The real manifest is uniform
(`http_status {200}`, `fetched {2026-11-05, 2026-11-07}`), so a check costs nothing.

Proposed r2 addition: "…and whose `http_status` cell is `200` and `fetched` cell is an ISO-8601
date not in the future." Control:

```bash
mk_ref f11; py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; lines=open(p).read().splitlines(); out=[]
for l in lines:
    c=l.split("\t")
    if c and c[0]=="S054": c[4]="404"; c[3]="1999-01-01"; l="\t".join(c)
    out.append(l)
open(p,"w").write("\n".join(out)+"\n")' "$SCR/f11"
check K1-F11-forged-fetch-status 10 f11       # 10 today; 9 after the r2 addition
```

### F4 (medium) no row-to-URL binding beyond the digest ⇒ cross-wired captures score

Evidence. R2j: S101 row `body_path=.ufo/waves/round-55/capture/S113.body`, `bytes=90604`,
`sha256=d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357` (S113's page, not S101's
60237 page). The counter reads `value=10`, and the **gate** prints
`MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S101 form=grep stated=2 replayed=2`
followed by `RECHECK_REPLAY: CLEAN` — the string `Withdrawal of International Standard` occurs
twice on the S113 page as well. R2k does the same with S114 (`International Standard published`
occurs twice on the S113 page too). Both survive because r2/r3 bind id↔url and row↔bytes, never
bytes↔url. The real manifest is a bijection (10 rows, **10 distinct `body_path`, 10 distinct
`sha256`**), so the check is free.

Proposed r2 addition: "no two manifest rows share a `body_path` or a `sha256`." Control:

```bash
mk_ref f12; py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; lines=open(p).read().splitlines(); out=[]
for l in lines:
    c=l.split("\t")
    if c and c[0]=="S101":
        c[2]=".ufo/waves/round-55/capture/S113.body"; c[5]="90604"
        c[6]="d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357"; l="\t".join(c)
    out.append(l)
open(p,"w").write("\n".join(out)+"\n")' "$SCR/f12"
check K1-F12-crosswire-capture 10 f12        # 10 today; 9 after the r2 addition
```

(If the lane prefers the receipt to be the binding: `capture/fetch-receipt.json` already names
`id`+`url`+`body_path`+`sha256` for S054/S055/S057/S067/S070/S074/S078, but not for
S101/S113/S114, so a receipt check cannot cover the whole population.)

### F5 (low — availability) a FIFO in `corpus/knowledge/` hangs the counter

Evidence. Z1: `mkfifo corpus/knowledge/zzz-fifo.md` in an otherwise pristine tree ⇒
`timeout 25 bash plans/round-56-c1.sh --tree …` returns **124** with no output; the counter runs
the tree's gate first and the gate's `clocks()` does
`for path in sorted(kdir.glob("*.md")): … path.read_text(...)` without a regular-file test (it
skips only symlinks). The counter's own `read()` is safe (`is_file`), so only the gate hangs. A
hung counter cannot read 10, so this is fail-closed in value but unbounded in time.

Proposed gate edit: in `clocks()`, after the symlink skip, `if not path.is_file(): continue`.
Proposed counter hardening: run the gate under `timeout 300` (and treat a timeout as not-CLEAN).
Control (must be bounded, or the control harness itself hangs):

```bash
mk_ref f15; mkfifo "$SCR/f15/corpus/knowledge/zzz-fifo.md"
check K1-F15-fifo-entry FAIL f15              # today: rc 124 under `timeout 25`; FAIL after the gate edit
```

### F6 (low — control quality) the plan's F5 printer control passes for the wrong reason

Evidence. `plans/round-56-controls.sh` F5 writes a **bash** printer to
`corpus/recheck-replay.py`, but the counter always invokes the gate as
`python3 -I -B "$T/corpus/recheck-replay.py"` (counter header `command -v python3` requirement).
Running that file under python3 gives `rc=1 SyntaxError: unmatched ')'` (`R5a` mechanism probe), so
`gate=0` and `guard=0` — the control's `expect=FAIL got=FAIL MATCH` never exercises the r5
MATCH-line rule. The rule's real behaviour is shown by Python printers: one that prints only
`CLEAN` reads **0** (F5's intended semantics), while one that also prints the ten MATCH lines reads
**10** (F1). Recommend replacing F5's bash printer with a Python printer that prints only
`RECHECK_REPLAY: CLEAN …` (expect 0) and adding K1-F13/K1-F16 above.

Two further control-quality notes, same file: (a) F2's recipe contains two inert edits (the first
`sub` raises `inert edit corpus/knowledge/betterleaks-…` and is swallowed by `|| true`; the second
replaces a string by itself); only the third regex actually restates the N, so the control does not
fail loudly if that last edit ever stops matching; (b) F3/F4/F6/F7/F8 read **0** through the
gate-DRIFT cascade rather than through the labelled conjunct — the bad= list shows
`r3-digest`/`r2-rows0`/`r3-file`/`r3-headers` for the mutated clock and `r5-gate` for all ten, so
their `expect=0` silently assumes the cascade. If r5 is ever made non-blocking (a plausible F1
fix), those controls would read 9, not 0; state the expectation as `not-10` or keep the cascade
deliberately.

## 6. By-design survivors (named ceiling re-stated, not a defect)

- R3g: a one-line hand-written body carrying the stated pattern once, with a self-consistent
  manifest row (bytes `68`, sha `253e48238dc9b10bef7685dacc4ef9fd429804b6dee719b6fb6c4d30f72156b7`),
  reads `10`. This is exactly the plan's named ceiling ("a hand-written capture with a
  self-consistent manifest row scores"); offline instrumentation cannot close it, only the receipt
  plus a non-author live re-fetch can.
- R1e (`-> count=N` form) and R1g (date/prose change) read 10: both are predicate-allowed, so they
  are correct non-kills, not missed mutations.
- N2 (gate absent) reads `value=0 … guard=1`: predicate-consistent (`BASE` reading) and not a
  scoring path.

## 7. What was checked and held (so the draft is not weakened unnecessarily)

- r4's normaliser isolation is real: R4b2 doctors the S070 body (quote gone; BASE normaliser count
  **0**) and fakes the *tree* normaliser to `count=1`; the gate goes CLEAN while the counter reads
  `value=9 … bad=r4-replay0:cdp-bridge-1password-oidc-workflow.md:custom-workflow`. Keeping r4 on
  the BASE copy is load-bearing; do not "simplify" it to the measured tree's script.
- The real gate cannot be silently rc-broken: R5h (`return rc if rc else 1`) is killed by the gate's
  own `--selftest`, whose cases assert `rc`. The rc gap (F1) is only reachable by substitution.
- The counter is *stricter* than the gate on r2: duplicate registry row, `staged` status, URL
  outside the source cell, and a fenced-only row each read **9** while the gate still says CLEAN.
  If r2 is ever loosened to the gate's rules, those four mutants become 10; the four gate-side
  weaknesses (`registry_rows` keeps last row per id, no fence handling, no cell count, no status)
  are latent and should be noted in the gate's own ceiling.
- r1 is pinned tightly: command bytes (R1d), N restatement (R1b/R1f), one-recheck-line (R1c) and
  clock deletion (R1a) all kill; a prose-only edit (R1g) and the sanctioned `count=` form (R1e) do
  not.
- r3 is fully killed on the declared surface: digest (R3a), absolute (R3b) and `..` (R3c) paths,
  symlink component (R3d), HTTP prefix (R3e), mid-file `Set-Cookie` (R3f) — the two header mutants
  carried *self-consistent* bytes/sha, so the header clause itself did the work.

## 8. Proposed ordering for L1 (cheap first)

1. F3 (one cell check, real data uniform) and F4 (uniqueness; kills the crosswire class).
2. F2 (pin `PASS (13 cases)`), F5 (gate `is_file`, bounded run), F6 (replace F5's bash printer).
3. F1 (r5': gate discrimination probe + gate rc 0 + non-symlink gate). This is the only edit that
   changes what "GUARD/gate" means; if it is not taken before freeze, the plan should say in the
   named ceilings that r5 is corroboration only and r4 is the whole substance.
Any edit to `plans/round-56-c1.sh` or `plans/round-56-controls.sh` invalidates the kill rule
`git diff --quiet <predeclaration> <candidate> -- plans/round-56.md plans/round-56-c1.sh
plans/round-56-controls.sh`; the predeclaration commit is `42070de` and the tested hash set is in
§0. I did not edit either file.

## 9. Restoration and no-production-edit evidence

- Lane instruments before and after all runs: `plans/round-56-c1.sh`
  `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a`,
  `corpus/recheck-replay.py` `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8`,
  `corpus/recheck-captures.tsv` `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`
  — identical at 07:22 and 07:34.
- `git show 42070de:<path> | sha256sum` equals the working-tree sha256 for `plans/round-56.md`,
  `plans/round-56-c1.sh`, `plans/round-56-controls.sh`, `corpus/recheck-replay.py`,
  `corpus/recheck-captures.tsv`, `.ufo/waves/round-56/capture/S054.body`, `S078.body`.
- Compared lane vs tested reference tree for all 22 instrument inputs (`SOURCES.md`, manifest, gate,
  normaliser, the 8 entries, S101.raw, S113/S114, S054/S055/S057/S067/S070/S074/S078): 22/22 same.
- Every mutation lived under `/fast/scratch/hyaku/kagi-r56/R56MutCounter/m/<id>`; the counter's own
  scratch was redirected there. No git/jj command in the lane was run (only `rev-parse`, `log`,
  `status`, `show`, `archive` reads). No file was written under `~/.local/bin` or any PATH dir. No
  tool was installed; nothing was fetched (no network call was made — the gate and counter replay
  committed bytes only, and no `curl` ran). Scratch removed before yield (see the seat receipt
  `R56MutCounter.d/` and the deletion check in the same transcript).
- Receipts: `.ufo/waves/round-56/build/R56MutCounter.d/{matrix.tsv,results.json,followups.json,
  mutate.py,followups.py,probes.txt,hashes.txt}`.

## 10. Unrun / not passed

Nothing in the assigned axis list is unrun: no-work, positive, r1, r2, r3, r4, r5, guard, gate
invocation rc, selftest rc and last line, normaliser isolation and the seven SETUP paths were each
executed at least once with the readings above. Not tested (out of scope, stated so it is not
mistaken for passed): live re-fetch currency on the day (network, other seat), the receipt's own
honesty (`capture/fetch-receipt.json` is unverified by both instruments), and any second round of
mutations after L1 edits the counter.
