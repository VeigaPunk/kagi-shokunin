# R56MutCounter — pre-freeze mutation report (kagi round 56)

Seat R56MutCounter (mutation tester, leaf; no subagent dispatch, no task tool).
Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Observed answering model: `amr/deepseek-v4.1-flash` (declared by the session's project-context
block; not inferred from this prompt).

The lane re-froze while I tested, so every reading below names its epoch. All epoch-B evidence is
anchored to `5d9a1571911ec38a456a40b443e19640abb9a88b`.

| epoch | counter `plans/round-56-c1.sh` | gate `corpus/recheck-replay.py` | manifest |
|---|---|---|---|
| A = `42070de` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| B = `5d9a157` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | same `df46be5c…` |

Epoch-A controls `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094`, plan
`d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07`. Epoch-B controls
`63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f`, plan
`033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679`, SOURCES.md
`299903cfb8d38760440d16ae3a5119154f14ec128619710101ca8c59af3a4edb`.

At 07:52 (after the epoch-B matrix, not tested by me) the lane gate was
`d4392ffe831560397fa35b4e84198b6ac75d5da8505a302ef3dcf6991080b274` and SOURCES.md
`fa69564f610e5192093b05ae17c9ee385aa607586cc219d0e33460985ab12936`, and at 07:53 the counter was
`be4af051425a764d66c91da1506bd77bab7cf24c9b33e5880c14072533d97fd5` with
`corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` also modified — the epoch-C re-freeze
KagiR56a3 announced.

No production file was edited. All mutation ran on copies under
`/fast/scratch/hyaku/kagi-r56/R56MutCounter/`.

## 0. Verdict

On epoch B the counter is **sound relative to its frozen r1–r5 predicate**: 41 recipes, each
varying one conjunct, and every one either reduced the reading or zeroed it; the detector
separates no-work (`832ba6a` ⇒ `value=0`) from positive (`5d9a157` ⇒ `value=10`), and all seven
SETUP paths exit 2. The epoch-A printer-gate and vacuous-selftest holes are closed by the
`GATE_SHA256_PIN` digest, the `--root` rc requirement, the exact `CLEAN (clocks=10 match=10 …)`
summary and the literal `PASS (13 cases)` selftest line (§5).

Three defects are outside what r1–r5 as frozen require, and they still read 10 on `5d9a157`:

- **F3** r2 ignores the manifest's `http_status` and `fetched` cells (a 404-dated row scores).
- **F4** nothing binds a row's `body_path` to its URL beyond the digest, so S101 (and S114) can be
  "replayed" against the S113 page while the pinned gate itself prints `MATCH … id=S101`.
- **F5** a FIFO at `corpus/knowledge/*.md` hangs both gate and counter (rc 124), because
  `clocks()` reads every `*.md` without a regular-file test and the counter bounds no gate run.

Plus one declaration gap (**F7**: `sha256sum`/`cut`/`tail` are new undeclared tool dependencies;
their absence yields 0/FAIL with rc 0 instead of SETUP) and one governance note (**F8**: the pin
couples counter and gate, but the kill-rule pathspec omits the gate).

KagiR56a3 has confirmed in-channel that F3, F4 and F5 are being folded into the epoch-C re-freeze.

## 1. Method

Reference tree = `tar -cf - corpus .ufo/waves/round-45/controls/capture-r45
.ufo/waves/round-55/capture .ufo/waves/round-56/capture` (216 files, 6.3 MB). Every mutant is
`cp -a <ref> <mutant>` plus exactly one recipe from `mutate.py`
(sha256 `4a5a780b45c101aa76c609baf7007cda3b12d3c16003f8111b1542f80b082d11`), applied with
`assert t != s` on every edit so an inert recipe fails loudly.

Epoch A was run against the lane's own counter (which resolved `REPO` to the lane). Because the
lane's counter changed four times between 07:34 and 07:46, epoch B was run against a **pinned
snapshot**: `git clone --shared --no-checkout` of the lane into scratch (read-only on the lane),
the counter copied to `<clone>/plans/round-56-c1.sh`, so `REPO`, `BASE:corpus/rendered-text-v1.py`
and `GATE_SHA256_PIN` are frozen to the bytes under test. Invocation, one per tree:

```
cd /fast/scratch/hyaku/kagi-r56/R56MutCounter
HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r56/R56MutCounter \
  bash <pinned counter> --tree <mutant tree>
```

`HYAKU_SCRATCH` was redirected into my own scratch so the counter's `$SCR` never collided with a
sibling's `c1.*`. Every non-SETUP run exited **0** (43/43 in epoch A, 44/44 in epoch B): the
`C1_REPLAY:` line is the only verdict channel; rc 0 is not a pass.

## 2. Baselines

| epoch | tree | reading | rc |
|---|---|---|---|
| A | landing working tree | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| A | `832ba6a` via `--tree` | `value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:…×10)` | 0 |
| A | `832ba6a` via revision arg | identical to the previous line | 0 |
| A | gate direct on the tree | 10 `MATCH` lines + `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` | 0 |
| A | gate `--selftest` | `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` | 0 |
| B | tree from `git archive 5d9a157` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| B | `832ba6a` via `--tree` | `value=0 present=10 replayed=0 gate=0 guard=1` | 0 |

The positive run binds these ten ids: S055, S070, S101, S113, S114, S074, S078, S067, S054, S057.

## 3. Matrix — 41 recipes, readings in both epochs

`A` = epoch A reading, `B` = epoch B reading. Full 64-hex digests of every mutated file are in
`R56MutCounter.d/matrixAB.tsv` (and `matrix.tsv` = epoch A, `resultsE.json` = epoch B). Digests are
given in full in §4/§5 for every finding; a † marks rows whose mutated-file digest differs between
epochs because the recipe edits bytes of the epoch's own gate (or embeds the mutant tree path).

| id | recipe (one edit) | A | B | verdict |
|---|---|---|---|---|
| R1a | delete trufflehog `recheck:` line body → `recheck: 180d — on-change — …` | FAIL | FAIL | killed (r1 absent) |
| R1b | betterleaks `-> 1` → `-> 2` | FAIL | FAIL | killed (r1 absent) |
| R1c | append a second `recheck:` line to betterleaks | FAIL | FAIL | killed (not one recheck line) |
| R1d | betterleaks command URL `'…'` → `"…"` | FAIL | FAIL | killed (command bytes pinned) |
| R1e | betterleaks `-> 1` → `-> count=1` | 10 | 10 | allowed form (predicate r1) |
| R1f | betterleaks `-> 1` → `-> 10` | FAIL | FAIL | killed (`(?!…)` + gate MISMATCH) |
| R1g | betterleaks `(ran 2026-10-23)` → `(ran 2026-11-06)` | 10 | 10 | prose only (correct) |
| R2a | delete manifest S054 row | 0 | 0 | killed (r2-rows0 + gate DRIFT) |
| R2b | duplicate manifest S054 row | 0 | 0 | killed (r2-rows2; gate SETUP) |
| R2c | duplicate registry S054 row (outside fences) | 9 | 9 | killed by counter only (gate CLEAN) |
| R2d | registry S113 status `mined` → `staged` | 9 | 9 | killed by counter only |
| R2e | registry S070 URL moved source → teaches cell | 9 | 9 | killed by counter only |
| R2f | registry S074 row only inside a ``` fence | 9 | 9 | killed by counter only |
| R2g | manifest header `bytes\tsha256` → `sha256\tbytes` | 0 | 0 | killed (header) |
| R2h | manifest S054 `id` → `S055` | 0 | 0 | killed (r2-registry) |
| **R2i** | manifest S054 `http_status=404`, `fetched=1999-01-01` | **10** | **10** | **survived — F3** |
| **R2j** | manifest S101 `body_path` → round-55 `S113.body` + its bytes/sha | **10** | **10** | **survived — F4** |
| **R2k** | manifest S114 `body_path` → round-55 `S113.body` + its bytes/sha | **10** | **10** | **survived — F4** |
| R3a | append `x` to S054.body | 0 | 0 | killed (r3-digest) |
| R3b | manifest S054 `body_path` → absolute path † | 0 | 0 | killed (r3-path) |
| R3c | manifest S054 `body_path` → `../../S054.body` | 0 | 0 | killed (r3-path) |
| R3d | S055.body moved to tree root, capture entry symlinked | 0 | 0 | killed (r3-file) |
| R3e | S057.body prefixed `HTTP/2 200\r\nset-cookie: x=1\r\n\r\n`, manifest refixed | 0 | 0 | killed (r3-headers) |
| R3f | `\nSet-Cookie: y=2\n` mid S074.body, manifest refixed | 0 | 0 | killed (r3-headers) |
| **R3g** | S054.body → one line carrying the pattern once, manifest refixed | **10** | **10** | **survived — named ceiling** |
| R4a | one extra pattern line in S054.body, manifest refixed | 0 | 0 | killed (r4-replay2) |
| R4b | *flawed recipe* (quote edited in the CDP **entry**) | FAIL | FAIL | superseded by R4b2 |
| R4b2 | S070 body doctored + tree normaliser faked, manifest refixed (§7) | 9 | 9 | killed (`r4-replay0`), gate CLEAN |
| R4c | delete tree `corpus/rendered-text-v1.py` | 0 | 0 | killed (gate TOOL / pin) |
| R5a | gate → bash `CLEAN` printer (epoch-A controls' F5) | FAIL | 0 | killed (A: python SyntaxError; B: pin) |
| **R5b** | gate → Python printer: ten exact `MATCH` lines + `CLEAN` + `PASS (13 cases)`, rc 0 † | **10** | 0 | epoch-A hole, closed by pin |
| **R5c** | same printer, run path `sys.exit(1)` † | **10** | 0 | epoch-A hole (rc ignored), closed by pin |
| R5d | real gate print patched: betterleaks `id=S055`→`S999` † | 9 | 0 | A killed by r5 id; B by pin |
| R5e | real gate print patched: cdp `form=locate`→`grep` † | 9 | 0 | A killed by r5 form; B by pin |
| R5f | real gate `clocks()` skips `betterleaks*` † | 9 | 0 | A killed by per-clock MATCH; B by pin |
| **R5g** | gate → absolute symlink to the printer outside the tree | **10** | 0 | epoch-A hole (gate file unconfined), closed by pin |
| R5h | real gate `main`: `return rc if rc else 1` † | FAIL | 0 | A killed by selftest; B by pin |
| G1 | selftest prints `PASS (13 cases)` then `return 1` † | FAIL | 0 | A killed (selftest rc); B by pin |
| G2 | selftest prints `PASS (13 cases)` then a noise line † | FAIL | 0 | A killed (last line); B by pin |
| **G3** | `selftest()` gutted to `print("…PASS (0 cases)"); return 0` † | **10** | 0 | epoch-A hole, closed by pin+literal |
| G4 | gate replaced by a directory | FAIL | 0 | A killed; B by pin |
| N2 | gate file deleted, tree otherwise intact | 0 | 0 | predicate-consistent (guard 1, value 0) |
| Z1 | `mkfifo corpus/knowledge/zzz-fifo.md` | TIMEOUT | TIMEOUT | **no reading — F5** |

Epoch-B divergences from epoch A are all explained by the pin: any tree whose
`corpus/recheck-replay.py` differs from `2e9dfde3…` gets `HAVE_GATE=0 ⇒ gate_ok=0 ⇒ r5` fails on
all ten clocks (reading 0, guard still 1 because all ten clocks are PRESENT). That is why
R5b/R5c/R5g/G3 fall from 10 to 0 in epoch B.

## 4. Open findings (with exact recipes on `5d9a157`)

### F3 — r2 ignores `http_status` and `fetched` (medium)

Recipe: `corpus/recheck-captures.tsv`, S054 row, column 4 → `404`, column 3 → `1999-01-01`.
Mutant manifest sha256 `fd3266526f683fd18dcb1b506f948ecdf45b14e6848f42fcdd1250888e3e091e`.
Reading: `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` (rc 0), on both
epochs. The pinned gate also prints `MATCH … id=S054 form=grep stated=1 replayed=1`, because it
never reads those two cells either.

Real data is uniform: all ten rows have `http_status = 200`; `fetched ∈ {2026-11-05, 2026-11-07}`
(measured over `corpus/recheck-captures.tsv` at `df46be5c…`). Note S101's row is `2026-11-05` and
S113/S114 are `2026-11-07`, so an `== 200` binding holds for all ten; if the lane ever records a
non-200 capture deliberately, bind `status is 3-digit` + `fetched parses as an ISO date` instead.

Proposed r2 addition: "…and the row's `http_status` cell is `200` and its `fetched` cell is an
ISO-8601 date not in the future." Control (expectations).

```bash
# F17 forged fetch status/date: r2 must not accept a row recorded as a 404 fetch
mk_ref f17; py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; lines=open(p).read().splitlines(); out=[]
for l in lines:
    c=l.split("\t")
    if c and c[0]=="S054": c[4]="404"; c[3]="1999-01-01"; l="\t".join(c)
    out.append(l)
open(p,"w").write("\n".join(out)+"\n")' "$SCR/f17"
check K1-F17-forged-fetch-status 9 f17      # 10 today; 9 after the r2 addition
```

### F4 — no row↔URL binding beyond the digest (medium)

Recipe: `corpus/recheck-captures.tsv`, S101 row → `body_path=.ufo/waves/round-55/capture/S113.body`,
`bytes=90604`, `sha256=d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357` (the
82709 page, not the 60237 page the S101 clock cites). Mutant manifest sha256
`f3bcd94b60487fa53cd2a78bb453c60a95649f5e5e230cdd733d342ff0687bc5`.
Reading: `value=10 … (bad=none)`, and the gate prints
`MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S101 form=grep stated=2 replayed=2`
followed by `RECHECK_REPLAY: CLEAN`. The string `Withdrawal of International Standard` occurs
twice on the S113 page as well (`grep -c` measured 2 on `S101.raw`, `S113.body`, `S114.body`), so
the count matches by coincidence of content, not of provenance. R2k is the same trick for S114
(`International Standard published` occurs twice on `S113.body`); mutant manifest
`6e6e7e8e5c76e87361408d991e00d00d565696c2fda57bc849afc705b36f9eac`.

Real manifest is a bijection: 10 rows, 10 distinct `body_path`, 10 distinct `sha256`.

Proposed r2 addition: "no two manifest rows share a `body_path` or a `sha256`." Control:

```bash
# F18 cross-wired capture: two rows pointing at one body must not both replay
mk_ref f18; py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; lines=open(p).read().splitlines(); out=[]
for l in lines:
    c=l.split("\t")
    if c and c[0]=="S101":
        c[2]=".ufo/waves/round-55/capture/S113.body"; c[5]="90604"
        c[6]="d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357"; l="\t".join(c)
    out.append(l)
open(p,"w").write("\n".join(out)+"\n")' "$SCR/f18"
check K1-F18-crosswire-capture 9 f18         # 10 today; 9 after the r2 addition
```

### F5 — FIFO in `corpus/knowledge/` hangs gate and counter (medium, availability)

Recipe: `mkfifo corpus/knowledge/zzz-fifo.md` on the `5d9a157` tree. Reading: none —
`timeout 20 bash <counter> --tree <tree>` returns **124**; the gate alone also hangs
(`python3 -I -B corpus/recheck-replay.py --root <tree>` blocked until killed). Cause:
`clocks()` iterates `sorted(kdir.glob("*.md"))`, skips symlinks only, then
`path.read_text(...)`; the counter puts no timeout on the gate invocation (the only `timeout=`
arguments are inside `replay()`). Epoch A behaves identically.

Proposed gate edit in `clocks()`, after the symlink branch: `if not path.is_file(): continue`;
proposed counter hardening: run the gate under `timeout 300` and treat a timeout as not-CLEAN.
Control (must itself be bounded, or the control script hangs):

```bash
# F19 FIFO entry: not a file, so not a clock; must not hang and must not zero the claim
mk_ref f19; mkfifo "$SCR/f19/corpus/knowledge/zzz-fifo.md"
timeout 60 bash "$C1" --tree "$SCR/f19" > "$SCR/f19.out" 2>&1 || true
check K1-F19-fifo-entry 10 f19               # today: no reading (rc 124); 10 after the gate edit
```

### F7 — undeclared tool dependencies do not fail closed as SETUP (low)

Epoch B added `sha256sum` and `cut` (gate pin) and still uses `tail` (selftest line) outside the
`command -v` guards, which cover only `python3`, `grep`, `pdftotext`. With a PATH that has the
guarded three but not `cut`:

`line 94: cut: command not found` → `C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1`
(`r5-gate` ×10), rc 0 — the pin silently never matched. Without `tail`:
`C1_REPLAY: value=FAIL present=10 replayed=10 gate=1 guard=0 (bad=selftest)`, rc 0. Both fail
closed in *value*, but the header's contract says a missing tool is SETUP (exit 2). The genuine
SETUP paths still hold: no-python3, no-pdftotext, no-grep, bad-revision, no-revision,
missing-tree, and `HYAKU_SCRATCH=/proc/nope` → `SETUP scratch`, all rc 2 (probes in
`R56MutCounter.d/probes.txt` for epoch A and `probesD.txt` for epoch B).

Proposed: add `command -v sha256sum cut tail` to the setup block (or use `sha256sum` via python3).

## 5. Closed during this wave (documented so the mechanism is not lost)

- **F1 (epoch A, medium) — r5 counted a gate that never replayed.** Evidence at `42070de`:
  R5b (Python printer printing the ten real `MATCH` lines + `CLEAN`, rc 0; printer sha256
  `48b75d82a57b61d300105bca2909744989c468606039b39036853d723b05ce8e`) read **10**, and its stdout
  was byte-identical to the real gate's; R5c (`… 1cc536c98fc4ef06a903fa5119b8bbbcd70f02e6a5ffd713f90ea3bbef8f557b`)
  printed the same and exited 1 and still read **10** (gate rc was ignored); R5g (gate as an
  absolute symlink to that printer) read **10**. A discrimination probe I ran by appending one byte
  to `S054.body` showed `ref-real-gate rc=1 BAD-CAPTURE=yes`, `R5b rc=0 BAD-CAPTURE=no`,
  `R5c rc=1 BAD-CAPTURE=no`, `R5g rc=0 BAD-CAPTURE=no`.
  Epoch B closes it structurally: `GATE_SHA256_PIN=2e9dfde3…`, the gate must be a regular
  non-symlink file of that digest, its `--root` run must exit 0, and its last line must match
  `^RECHECK_REPLAY: CLEAN \(clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0\)$`.
  R5b/R5c/R5g now read 0.
- **F2 (epoch A, medium) — GUARD accepted a vacuous selftest.** G3 (gutted `selftest()` printing
  `RECHECK_REPLAY_SELFTEST: PASS (0 cases)`, sha256
  `f2e16726e97005205667eb7d8051687834b274c9aee794f4bd85c6653174c337`) read **10** at `42070de`
  because the check was the prefix `"RECHECK_REPLAY_SELFTEST: PASS"*`. Epoch B pins the literal
  `PASS (13 cases)`, so G3 reads 0 (digest) and a same-digest vacuity is impossible without a
  counter edit.
- **F6 (control quality, partially closed).** The epoch-A controls' F5 wrote a **bash** printer that
  the counter runs with `python3`, so it was rejected with `SyntaxError: unmatched ')'` rather than
  by the MATCH-line rule (mechanism probed directly). Epoch-B controls replace it with a Python
  printer, add F5b (one-conjunct gate edit) and F5c (symlinked gate), and F9 now deletes the
  selftest case by byte drift — all exercise the pin. Two further epoch-A recipe defects remain
  worth fixing: F2's first `sub` raises `inert edit …` (swallowed by `|| true`) so only the third
  regex actually restates the N; and F3/F4/F6/F7/F8 read **0** through the gate-DRIFT cascade
  rather than through the labelled conjunct (their `bad=` lists show `r3-digest`/`r2-rows0`/… for
  the mutated clock plus `r5-gate` for all ten), so their `expect=0` silently assumes the cascade.

## 6. By-design survivors (named ceiling, not a defect)

- R3g: `S054.body` replaced by one line carrying the stated pattern once, with a self-consistent
  manifest row (body sha256 `253e48238dc9b10bef7685dacc4ef9fd429804b6dee719b6fb6c4d30f72156b7`,
  manifest `d8d9c2093cff9606ce17154dacad9c5b4142080736458fb044d347011d1474dc`), reads **10** on both
  epochs. This is the plan's named ceiling verbatim; only a receipt plus a non-author live
  re-fetch can close it.
- R1e (`-> count=N`) and R1g (date/prose) read 10: predicate-allowed, correctly not killed.
- N2 (gate absent) reads `value=0 … guard=1`: the documented BASE shape, not a scoring path.

## 7. Held strengths (do not weaken these in the re-freeze)

- **r4 normaliser isolation works and is load-bearing.** R4b2 doctors the S070 body (its BASE
  normaliser count is **0**) and fakes the *tree* normaliser to `count=1`, with the manifest
  refixed (body `c279f654514d0a43f0c97a0e3fbbb4d2fe43357c82f2d3b5a5d85e27286c6302`, manifest
  `70fabf3510ab9a47bd49f020132c16adf0fb564668f43241534b7e3a71d63726`, faked tree normaliser
  `924062d3a903f1cb7d29a79dcf50dbdf27e54194e47a4ebf40ccaf9670f1db12`, BASE normaliser
  `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9`). The gate goes CLEAN, the
  counter reads `value=9 … bad=r4-replay0:cdp-bridge-1password-oidc-workflow.md:custom-workflow` in
  both epochs. Keeping r4 on the BASE copy is what makes the gate's tree normaliser irrelevant.
- **r1 is pinned tightly**: command bytes (R1d), N restatement (R1b/R1f), one-recheck-line (R1c),
  clock deletion (R1a) all kill, while prose and the sanctioned `count=` form do not.
- **r3 is killed on its whole declared surface**: digest (R3a), absolute and `..` paths
  (R3b/R3c), symlink component (R3d), HTTP status prefix (R3e) and mid-file `Set-Cookie` (R3f);
  the last two carried self-consistent bytes/sha, so the header clause itself did the work.
- **The counter is stricter than the gate on r2**: duplicate registry row, `staged` status, URL
  outside the source cell and a fenced-only row each read **9** while the gate still says CLEAN.
  The gate's `registry_rows` keeps the last row per id, has no fence handling, no cell count and
  no status check — latent weaknesses if r2 is ever loosened to the gate's rules.
- **BASE stays the documented shape**: `value=0 … gate=0 guard=1` on `832ba6a` in both epochs (an
  intermediate working-tree version at 07:37 tied `guard` to the gate digest and returned
  `guard=0` there; epoch B ties only r5 to the digest, so the BASE reading survives).

## 8. Governance note (F8)

`GATE_SHA256_PIN` couples the counter to the gate bytes, but the plan's kill rule names only
`plans/round-56.md plans/round-56-c1.sh plans/round-56-controls.sh`. I observed the consequences
live: at 07:41 counter `d2bcb790…` pinned `637c8184…` while the working-tree gate was already
`2e9dfde3…`, and that pair reads `value=0 … gate=0 guard=1` with `r5-gate` on all ten clocks.
KagiR56a3 states the candidate must carry the same gate bytes; the epoch-B predeclaration
(`5d9a157`) is coherent. For epoch C, add `corpus/recheck-replay.py` to the kill-rule pathspec (or
state that a gate edit requires a re-predeclaration with a bumped pin), so the coupling is explicit
rather than implicit in a constant.

## 9. Restoration / no-production-edit evidence

- Lane instruments before (07:22) and after (07:34) the epoch-A matrix were identical:
  counter `096251c9…`, gate `b7782f35…`, manifest `df46be5c…`; `git show 42070de:<path>` equals the
  working-tree bytes for plan, counter, controls, gate, manifest, `S054.body`, `S078.body`.
- For epoch B, `git show 5d9a157:<path>` yielded counter `6b132ea1…`, gate `2e9dfde3…`, manifest
  `df46be5c…`, controls `63cf8061…`, plan `033f2104…` — the bytes I tested (the snapshot clone holds
  the counter, `R56MutCounter.d/counter-D.sh`).
- All 22 instrument inputs (SOURCES.md, manifest, gate, normaliser, the 8 entries, S101.raw,
  S113/S114/S054/S055/S057/S067/S070/S074/S078) were compared byte-for-byte between lane and the
  tested tree: identical at the epoch-A snapshot.
- Every mutation lived under `/fast/scratch/hyaku/kagi-r56/R56MutCounter/{m,mb,mbE,md-*,mb-*,t5d9,…}`;
  the lane was only read (`rev-parse`, `log`, `status`, `show`, `archive`, `clone`). No git/jj
  mutation in the lane or a sibling; no write to `~/.local/bin` or any PATH dir; no tool installed;
  no network call (the gate and counter replay committed bytes only — no `curl` ran).
- Scratch is deleted after this report; a sibling mutation seat had written into my seat path at
  07:46 (`driver.py`, `mut-m01-*`, `mut-m02-*`, `clone/`) and overwrote my scratch `results.json`
  with its own schema. My runs used explicit paths and were unaffected; the preserved epoch-A
  artifact is `R56MutCounter.d/matrix.tsv` (copied at 07:34), and I left the sibling's files in
  place rather than delete live work.
- Seat receipt: `.ufo/waves/round-56/build/R56MutCounter.d/` — `matrixAB.tsv`, `matrix.tsv`,
  `matrixC.tsv`, `resultsC.json`, `resultsE.json`, `mutate.py`, `followups.py`,
  `followups.json`, `versions.txt`, `epochB-anchored.txt`, `probes.txt`, `probesD.txt`,
  `hashes.txt`, `gate-A.py`, `gate-C.py`, `gate-D.py`, `counter-D.sh`.

## 10. Unrun / not passed

Every assigned axis was executed at least once: no-work, positive, r1, r2, r3, r4, r5, guard, gate
invocation rc, selftest rc and last line, normaliser isolation, and the SETUP paths (16 setup runs
across the two epochs: the seven declared paths twice, plus `cut`-absent and `tail`-absent).

Not tested, stated so it is not mistaken for passed: live re-fetch currency on the
day (network, another seat), the honesty of `capture/fetch-receipt.json` (neither instrument reads
it), the epoch-C bytes (`d4392ffe…` gate observed at 07:52) which landed after my matrix, and any
future re-freeze in which the three open findings are folded in.
