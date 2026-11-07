# R56MutCounter — pre-freeze mutation report (kagi round 56)

Seat R56MutCounter (mutation tester, leaf; no subagent dispatch, no task tool).
Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Observed answering model: `amr/deepseek-v4.1-flash` (declared by the session's project-context
block, not inferred from this prompt).

The lane re-froze three times while I tested; every reading names its epoch, and the audit is
anchored to the latest predeclaration, **epoch D = `d36231871c864c930d3e7e33f9c5345b30ab4f98`**.

| epoch | counter `plans/round-56-c1.sh` | gate `corpus/recheck-replay.py` | notes |
|---|---|---|---|
| A `42070de` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | controls `633326a5…`, plan `d1bf8d26…` |
| B `5d9a157` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | controls `63cf8061…`, plan `033f2104…` |
| C `711e6393` | `7992ee6a97c9f1cfaf627c61322ecaf6aa0c31126a65f591567d7b6f7ee2802c` | `e9b7e4b7aa1e8173c4bfc2e536ce6d1ed29c4c0d6ee5f46bfa1e63d3692a62b4` | controls `b675baa5…`, plan `8beb24e9…` |
| **D `d362318`** | `82acbb2056aac6055a79f223a0e0abbb2cb24f11f01ca5ed12a230c8338bdc6a` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` | `GATE_SHA256_PIN=5165da2a…`, `NORMALIZER_SHA256_PIN=14f6ca6a…`, selftest `PASS (20 cases)` |

All four epochs share manifest `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`.
No production file was edited; every mutation ran on copies under
`/fast/scratch/hyaku/kagi-r56/R56MutCounter/`.

## 0. Verdict

**No open finding against epoch D.** Every defect I raised in epochs A/B/C is closed, and each
closure is demonstrated by the identical recipe that used to survive it:

| finding | raised at | proof at D |
|---|---|---|
| F1 printer/symlinked/unpinned gate read 10 | A | R5b/R5c/R5g now **FAIL** (`guard=0`, unpinned gate), pin enforced |
| F2 vacuous `--selftest` read 10 | A | G3 now **FAIL**; literal `PASS (20 cases)` |
| F3 `http_status`/`fetched` unconstrained | A/B | R2i **0**, C2 (`2026-11-7`) **0**, C3 (`302`) **0** |
| F4 cross-wired captures (S101/S114→S113 page) | A/B | R2j/R2k **0**, C4 (shared sha) **0**, C1 (out-of-capture path) **0** |
| F5 FIFO entry hung gate and counter | A/B | C8 **0** in ~2 s; gate prints `UNSUPPORTED … reason=non-regular-entry` |
| F6 control-quality (bash printer control, inert edits, cascade coupling) | A | controls rewritten; residual note in §6 |
| F7 `sha256sum`/`cut`/`tail` outside the SETUP guards | B | **still open as a declaration nit** (§6.7); readings stay fail-closed |
| F9 header refusal lost case-insensitivity | C | R3f **0**; five case probes all **0** (§5) |

Epoch D baselines: `d362318` ⇒ `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`, rc 0;
BASE `832ba6a` ⇒ `value=0 present=10 replayed=0 gate=0 guard=1`, rc 0; gate `--selftest` ⇒
`RECHECK_REPLAY_SELFTEST: PASS (20 cases)`, rc 0.

The only readings at 10 are the named-ceiling and predicate-allowed cases: R3g (hand-written
self-consistent capture), R1e (`-> count=N`), R1g (date/prose edit).

## 1. Method

Reference trees: `tar -cf - corpus .ufo/waves/round-45/controls/capture-r45
.ufo/waves/round-55/capture .ufo/waves/round-56/capture` from the working tree (epoch A) and
`git archive <rev>` for B/C/D, so there is no drift. Every mutant is `cp -a <ref> <mutant>` plus one
recipe from `mutate.py` (sha256
`4a5a780b45c101aa76c609baf7007cda3b12d3c16003f8111b1542f80b082d11`), with `assert t != s` on every
edit; recipes whose anchor changed between epochs fail loudly (`RECIPE-ERROR`, seen once for the
R5d/e/f print anchors, which were then re-derived).

Because the lane's counter changed repeatedly mid-wave, epochs B/C/D were run against **pinned
snapshots**: a `git clone --shared --no-checkout` of the lane in scratch (read-only on the lane) with
the epoch's counter copied to `<clone>/plans/round-56-c1.sh`, so `REPO`,
`BASE:corpus/rendered-text-v1.py` and the two SHA256 pins are frozen to the bytes under test:

```
cd /fast/scratch/hyaku/kagi-r56/R56MutCounter
HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r56/R56MutCounter \
  bash <pinned counter> --tree <mutant tree>
```

`HYAKU_SCRATCH` was redirected into my own scratch so the counter's `$SCR` never collided with a
sibling's `c1.*`. Every non-SETUP run exited **0** (43 A, 44 B, 53 C, 61 D): the `C1_REPLAY:` line is
the only verdict channel; rc 0 is not a pass.

## 2. Baselines

| epoch | tree | reading | rc |
|---|---|---|---|
| A | landing working tree / `832ba6a` | `value=10 … guard=1 (bad=none)` / `value=0 … gate=0 guard=1` | 0 |
| A | gate direct / `--selftest` | `CLEAN (clocks=10 match=10 … tool=0)` / `PASS (13 cases)` | 0 |
| B | `git archive 5d9a157` / `832ba6a` | `value=10 …` / `value=0 …` | 0 |
| C | `git archive 711e6393` / `832ba6a` | `value=10 …` / `value=0 …`; gate `PASS (18 cases)` | 0 |
| D | `git archive d362318` / `832ba6a` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` / `value=0 present=10 replayed=0 gate=0 guard=1` | 0 |

The positive run binds these ten ids: S055, S070, S101, S113, S114, S074, S078, S067, S054, S057.

## 3. Matrix — 59 recipes, readings per epoch

Full 64-hex digests of every mutated file are in `R56MutCounter.d/matrixABCD.tsv` (per-epoch JSON:
`resultsC711.json`, `resultsE.json`, `resultsD.json`, `resultsD2.json`); findings carry their digests
inline.

| id | recipe (one edit) | A | B | C | D | verdict |
|---|---|---|---|---|---|---|
| R1a | delete trufflehog `recheck:` line body | FAIL | FAIL | FAIL | FAIL | killed |
| R1b | betterleaks `-> 1` → `-> 2` | FAIL | FAIL | FAIL | FAIL | killed |
| R1c | append a second `recheck:` line to betterleaks | FAIL | FAIL | FAIL | FAIL | killed |
| R1d | betterleaks command URL `'…'` → `"…"` | FAIL | FAIL | FAIL | FAIL | killed |
| R1e | betterleaks `-> 1` → `-> count=1` | 10 | 10 | 10 | 10 | allowed form |
| R1f | betterleaks `-> 1` → `-> 10` | FAIL | FAIL | FAIL | FAIL | killed |
| R1g | betterleaks `(ran 2026-10-23)` → `(ran 2026-11-06)` | 10 | 10 | 10 | 10 | prose only |
| R2a | delete manifest S054 row | 0 | 0 | 0 | 0 | killed |
| R2b | duplicate manifest S054 row | 0 | 0 | 0 | 0 | killed |
| R2c | duplicate registry S054 row (outside fences) | 9 | 9 | 9 | 9 | counter-only kill |
| R2d | registry S113 status `mined` → `staged` | 9 | 9 | 9 | 9 | counter-only kill |
| R2e | registry S070 URL moved source → teaches cell | 9 | 9 | 9 | 9 | counter-only kill |
| R2f | registry S074 row only inside a ``` fence | 9 | 9 | 9 | 9 | counter-only kill |
| R2g | manifest header `bytes\tsha256` → `sha256\tbytes` | 0 | 0 | 0 | 0 | killed |
| R2h | manifest S054 `id` → `S055` | 0 | 0 | 0 | 0 | killed |
| R2i | S054 `http_status=404`, `fetched=1999-01-01` | **10** | **10** | 0 | 0 | closed at C |
| R2j | S101 `body_path` → round-55 `S113.body` + its bytes/sha | **10** | **10** | 0 | 0 | closed at C |
| R2k | S114 `body_path` → round-55 `S113.body` + its bytes/sha | **10** | **10** | 0 | 0 | closed at C |
| R3a | append `x` to S054.body | 0 | 0 | 0 | 0 | killed |
| R3b | S054 `body_path` → absolute path | 0 | 0 | 0 | 0 | killed |
| R3c | S054 `body_path` → `../../S054.body` | 0 | 0 | 0 | 0 | killed |
| R3d | S055.body moved to root, capture entry symlinked | 0 | 0 | 0 | 0 | killed |
| R3e | S057.body prefixed `HTTP/2 200\r\nset-cookie: x=1\r\n\r\n`, manifest refixed | 0 | 0 | 0 | 0 | killed |
| R3f | `\nSet-Cookie: y=2\n` mid S074.body, manifest refixed | 0 | 0 | **10** | 0 | closed at D (F9) |
| R3g | S054.body → one line carrying the pattern once, manifest refixed | 10 | 10 | 10 | 10 | named ceiling |
| R4a | one extra pattern line in S054.body, manifest refixed | 0 | 0 | 0 | 0 | killed |
| R4b | *flawed recipe* (quote edited in the CDP entry) | FAIL | FAIL | FAIL | FAIL | superseded by R4b2 |
| R4c | delete tree `corpus/rendered-text-v1.py` | 0 | 0 | FAIL | FAIL | killed (normalizer pin) |
| R5a | gate → bash `CLEAN` printer (epoch-A control F5) | FAIL | 0 | FAIL | FAIL | killed |
| R5b | gate → Python printer: ten exact `MATCH` lines + `CLEAN` + `PASS`, rc 0 | **10** | 0 | FAIL | FAIL | closed at B/C |
| R5c | same printer, run path `sys.exit(1)` | **10** | 0 | FAIL | FAIL | closed at B/C |
| R5d | real gate print patched: betterleaks `id=S055`→`S999` | 9 | 0 | FAIL | FAIL | killed |
| R5e | real gate print patched: cdp `form=locate`→`grep` | 9 | 0 | FAIL | FAIL | killed |
| R5f | real gate `clocks()` skips `betterleaks*` | 9 | 0 | FAIL | FAIL | killed |
| R5g | gate → absolute symlink to the printer outside the tree | **10** | 0 | FAIL | FAIL | closed at B/C |
| R5h | real gate `main`: `return rc if rc else 1` | FAIL | 0 | FAIL | FAIL | killed |
| G1 | selftest prints `PASS` then `return 1` | FAIL | 0 | FAIL | FAIL | killed |
| G2 | selftest prints `PASS` then a noise line | FAIL | 0 | FAIL | FAIL | killed |
| G3 | `selftest()` gutted to `print("…PASS (0 cases)"); return 0` | **10** | 0 | FAIL | FAIL | closed at B/C |
| G4 | gate replaced by a directory | FAIL | 0 | FAIL | FAIL | killed |
| N2 | gate file deleted, tree otherwise intact | 0 | 0 | 0 | 0 | BASE shape |
| C1 | body copied to `corpus/S054copy.body`, row points there (valid bytes/sha) | – | – | 0 | 0 | killed (not-capture) |
| C2 | S054 `fetched=2026-11-7` | – | – | 0 | 0 | killed |
| C3 | S054 `http_status=302` | – | – | 0 | 0 | killed |
| C4 | S101 points at a byte-identical copy of S054.body (shared sha) | – | – | 0 | 0 | killed |
| C5 | tree normaliser + `# mutant` comment | – | – | FAIL | FAIL | killed |
| C6 | tree normaliser deleted | – | – | FAIL | FAIL | killed |
| C7 | `< HTTP/2 200` trace prefix at column 0 in S057.body | – | – | 0 | 0 | killed |
| C8 | `mkfifo corpus/knowledge/zzz-fifo.md` | – | TIMEOUT | 0 | 0 | killed, no hang |
| C9 | `corpus/knowledge` replaced by a symlink | – | – | FAIL | FAIL | killed |
| C10 | betterleaks `-> 1` → `-> 1x` | – | – | FAIL | FAIL | killed |
| D1 | `Set-Cookie: x=1` at column 0 (S057 body refixed) | – | – | 10 | 0 | F9 probe, closed at D |
| D2 | `SET-COOKIE: x=1` at column 0 | – | – | 10 | 0 | F9 probe |
| D3 | `set-cookie: x=1` at column 0 | – | – | 0 | 0 | control |
| D4 | `http/2 302 Found` at column 0 (S074 body refixed) | – | – | 10 | 0 | F9 probe |
| D5 | `< Set-Cookie: x=1` at column 0 | – | – | – | 0 | trace-prefix case |
| D6 | betterleaks `-> 1.` | – | – | – | FAIL | boundary `(?![0-9A-Za-z_.])` |
| D7 | betterleaks `-> 1.0` | – | – | – | FAIL | boundary |
| D8 | betterleaks `-> 1_0` | – | – | – | FAIL | boundary |

Epoch D totals: 59 recipe runs + 2 baselines = 61 counter runs; 56 killed, 3 by-design survivors, 0
inconclusive, 0 hangs. Epoch-D boundary probes R3f/D6/D7/D8 read `present=9 replayed=9 gate=1
guard=0` — the counter's PRESENT refuses the restatement while the gate stays CLEAN, so the kill does
not depend on the DRIFT cascade.

## 4. F9 (closed at D) — the one regression this audit found

Epoch C rewrote the r3 header refusal and dropped `(?i)`: gate line 216 and counter line 287 both
used `rb"(?m)^(?:HTTP/\d|< HTTP/\d|< set-cookie\s*:|set-cookie\s*:)"`, where epoch B had
`re.search(rb"(?im)^set-cookie:", data)`. On `711e6393` the canonical spellings passed:

| inserted line at column 0 | C reading | D reading |
|---|---|---|
| `set-cookie: x=1` | 0 | 0 |
| `Set-Cookie: x=1` (manifest `9b12b75d7627c1652386eda7d9936ba514bcdd879b1a8bb2e876ebe44594afe8`, S057.body `21cddee3d9b2bd9d3f5b5a621f3d2b2c67d7c32843d7e299675267d32aa7a05c`) | **10** | 0 |
| `SET-COOKIE: x=1` | **10** | 0 |
| `http/2 302 Found` (manifest `74db40edf770fe270bd76f1b5471191da8df284ed7aafcfd62fb838a61b973b1`, S074.body `4a278f2876f9955feb2046b90cdd1b8df716f0fa1e57210ceeb7e7f7d136b912`) | **10** | 0 |
| R3f standard recipe (body `f34217439caaa630ac2ed5ea9123dd54a639bc2a3e96e6830518359e8a80c9f2`, manifest `51ea192e16a8f50cafea3890d0908e46b07a46997e0a4d6fc51604c6556f236b`) | **10** | 0 |

Gate-level proof on the identical mutant tree: `711e6393` gate `e9b7e4b7` → `RECHECK_REPLAY: CLEAN`;
`d362318` gate `5165da2a` → `BAD-CAPTURE corpus/knowledge/nist-key-management-guidance-status.md:3
id=S074 reason=header-bytes:.ufo/waves/round-56/capture/S074.body` + `DRIFT (clocks=10 match=9 …
bad_capture=1)`. Epoch D also adds the `Set-Cookie:`/`Http/2` column-0 cases to the 20-case selftest
and the `(?![0-9A-Za-z_.])` N boundary (D6/D7/D8).

Receipt: `R56MutCounter.d/F9-header-case.txt`.

## 5. By-design survivors at D

- R3g: a one-line hand-written body carrying the stated pattern once with a self-consistent manifest
  row (body `253e48238dc9b10bef7685dacc4ef9fd429804b6dee719b6fb6c4d30f72156b7`, manifest
  `d8d9c2093cff9606ce17154dacad9c5b4142080736458fb044d347011d1474dc`) reads **10**. This is the
  plan's named ceiling verbatim; only the fetch receipt plus a non-author live re-fetch can close it.
- R1e (`-> count=N`) and R1g (date/prose) read 10 in every epoch — predicate-allowed, correctly not
  killed.

## 6. Residual notes (not defects against the frozen predicate)

1. **r4 normaliser isolation is real and twice-enforced.** R4b2 (A and B) doctored the S070 body
   (BASE normaliser count **0**), faked the *tree* normaliser to `count=1` and refixed the manifest
   (body `c279f654514d0a43f0c97a0e3fbbb4d2fe43357c82f2d3b5a5d85e27286c6302`, manifest
   `70fabf3510ab9a47bd49f020132c16adf0fb564668f43241534b7e3a71d63726`, fake normaliser
   `924062d3a903f1cb7d29a79dcf50dbdf27e54194e47a4ebf40ccaf9670f1db12`): the gate went CLEAN while
   the counter read `value=9 … bad=r4-replay0:cdp-bridge-1password-oidc-workflow.md:custom-workflow`.
   From C on, `NORMALIZER_SHA256_PIN=14f6ca6a…` refuses any changed normaliser before replay
   (C5/C6 → FAIL). Keep both.
2. **Counter stricter than the gate on r2**: duplicate registry row, `staged` status, URL outside the
   source cell and a fenced-only row each read **9** while the gate says CLEAN. The gate's
   `registry_rows` keeps the last row per id, has no fence handling, no cell count and no status
   check — latent if r2 is ever loosened to the gate's rules.
3. **F7 (declaration nit, still open)**: epoch B/C/D use `sha256sum`, `cut` and `tail` outside the
   three `command -v` guards. With `cut` absent: `line 94: cut: command not found` → `value=0 …
   gate=0` (`r5-gate` ×10), rc 0; with `tail` absent: `value=FAIL … (bad=selftest)`, rc 0 —
   fail-closed in value, not labelled SETUP. Fix: `command -v sha256sum cut tail`. All seven declared
   paths exit 2 in every epoch (16 probe runs: seven twice plus `cut`-absent and `tail`-absent).
4. **F6 (control quality)**: the epoch-A control F5 wrote a **bash** printer that the counter runs
   with `python3` (rejected with `SyntaxError: unmatched ')'`, i.e. not by the MATCH-line rule);
   epoch-A F2 had two inert edits; epoch-A F3/F4/F6/F7/F8 read 0 only via the gate-DRIFT cascade.
   The B/C/D controls replace the printer with Python, add gate-edit/gate-symlink/byte-drift cases
   and (per KagiR56a3) pipefail + hash lines; the cascade coupling in F3/F4 remains worth stating
   (if r5 ever becomes non-blocking those rows read 9, not 0). Epoch-D controls report 21/21 MATCH
   (KagiR56a3); I did not re-run that script.
5. **Governance**: `GATE_SHA256_PIN` couples counter and gate, while the kill rule names only
   `plans/round-56.md plans/round-56-c1.sh plans/round-56-controls.sh`. I observed the coupling
   twice — counter `d2bcb790…` pinning `637c8184…` while the gate was `2e9dfde3…` (reading
   `value=0`, `r5-gate` ×10), and counter `842c014f…` pinning `e9b7e4b7…` while the gate was
   `5165da2a…`. `d362318` is coherent (`82acbb20…` pins `5165da2a…`); any future gate edit must bump
   the pin in the same commit, and adding the gate to the kill-rule pathspec makes that explicit.

## 7. Restoration / no-production-edit evidence

- Committed bytes equal what I tested at every epoch: `git show 42070de:<path>` (counter `096251c9…`,
  gate `b7782f35…`, manifest `df46be5c…`, controls `633326a5…`, plan `d1bf8d26…`), `git show
  5d9a157:<path>` (counter `6b132ea1…`, gate `2e9dfde3…`), `git show 711e6393:<path>` (counter
  `7992ee6a…`, gate `e9b7e4b7…`), `git show d362318:<path>` (counter `82acbb20…`, gate `5165da2a…`,
  manifest `df46be5c…`). Epoch-A instrument hashes were identical at 07:22 and 07:34, and all 22
  instrument inputs (SOURCES.md, manifest, gate, normaliser, the 8 entries, S101.raw,
  S113/S114/S054/S055/S057/S067/S070/S074/S078) compared byte-for-byte between lane and tested tree.
- Lane access was read-only throughout (`rev-parse`, `log`, `status`, `show`, `archive`, `clone`); no
  git/jj mutation in the lane or a sibling; no write to `~/.local/bin` or any PATH dir; no tool
  installed; no network call (the gate and counter replay committed bytes only — no `curl` ran).
- Scratch collision, recorded because it destroyed an artifact: a sibling mutation seat wrote into my
  seat path at 07:46 (`driver.py`, `mut-m01…m32`, `clone/`, `ref*/snap*`, several hundred MB each),
  overwrote my scratch `results.json` with its own schema and removed some of my mutant trees. My runs
  used explicit paths and were unaffected; the preserved epoch-A artifact is
  `R56MutCounter.d/matrix.tsv` (copied at 07:34). I deleted only my own artifacts and left the
  sibling's live files in place.
- Seat receipt: `.ufo/waves/round-56/build/R56MutCounter.d/` — `matrixABCD.tsv`, `matrixABC.tsv`,
  `matrixAB.tsv`, `matrix.tsv`, `resultsC.json`, `resultsC711.json`, `resultsE.json`,
  `resultsD.json`, `resultsD2.json`, `mutate.py`, `followups.py/.json`, `F9-header-case.txt`,
  `gate-A.py`, `gate-C.py`, `gate-D.py`, `gate-E-d362318.py`, `gate-W-f9fix.py`,
  `counter-D.sh`, `counter-E-d362318.sh`, `versions.txt`, `epochB-anchored.txt`, `probes.txt`,
  `probesD.txt`, `hashes.txt`.

## 8. Unrun / not passed

Every assigned axis was executed in at least one epoch and re-verified at D: no-work, positive, r1,
r2, r3, r4, r5, guard, gate invocation rc, selftest rc and last line, normaliser isolation, the SETUP
paths, and (C onward) capture confinement, fetched/2xx, body_path/sha bijection, normaliser pin,
trace prefixes, non-regular entries, symlinked knowledge, the N right-boundary and the header-case
class. Not tested, stated so it is not mistaken for passed: live re-fetch currency on the day
(network, another seat), the honesty of `capture/fetch-receipt.json` (neither instrument reads it),
and the epoch-D controls script itself (KagiR56a3 reports 21/21 MATCH; I did not re-run it).
