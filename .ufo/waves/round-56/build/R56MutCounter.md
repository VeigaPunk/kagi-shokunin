# R56MutCounter — pre-freeze mutation report (kagi round 56)

Seat R56MutCounter (mutation tester, leaf; no subagent dispatch, no task tool).
Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Observed answering model: `amr/deepseek-v4.1-flash` (declared by the session's project-context
block, not inferred from this prompt).

The lane re-froze four times while I tested. Every reading names its epoch; the audit is anchored to
the current predeclaration, **epoch E = `dd31b7867723f89fc8f83e88cc7d98e17de26cf2`**.

| epoch | counter `plans/round-56-c1.sh` | gate `corpus/recheck-replay.py` | controls / plan |
|---|---|---|---|
| A `42070de` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `633326a5…` / `d1bf8d26…` |
| B `5d9a157` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | `63cf8061…` / `033f2104…` |
| C `711e6393` | `7992ee6a97c9f1cfaf627c61322ecaf6aa0c31126a65f591567d7b6f7ee2802c` | `e9b7e4b7aa1e8173c4bfc2e536ce6d1ed29c4c0d6ee5f46bfa1e63d3692a62b4` | `b675baa5…` / `8beb24e9…` |
| D `d362318` | `82acbb2056aac6055a79f223a0e0abbb2cb24f11f01ca5ed12a230c8338bdc6a` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` | — |
| **E `dd31b786`** | `d468533fbf593c4b2a3a97dc513b9feb2cff765892c126c02d7c6ef40273a954` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` | `01060f25…` / `212e2dd7…` |

All five epochs share manifest `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`.
Epoch E pins `GATE_SHA256_PIN=5165da2a…`, `NORMALIZER_SHA256_PIN=14f6ca6a…`, selftest
`PASS (20 cases)`, and guards `python3 grep pdftotext sha256sum cut tail timeout git tar`.
No production file was edited; every mutation ran on copies under
`/fast/scratch/hyaku/kagi-r56/R56MutCounter/`.

## 0. Verdict — epoch E

**No open finding.** 59 recipes + 2 baselines = 61 counter runs at E: **56 killed, 3 by-design
survivors, 0 inconclusive, 0 hangs**, with `dd31b786` ⇒ `value=10 present=10 replayed=10 gate=1
guard=1 (bad=none)` and BASE `832ba6a` ⇒ `value=0 present=10 replayed=0 gate=0 guard=1`.

Every defect I raised was closed and each closure is proven by the identical recipe that used to
survive it:

| finding | raised | proof at E |
|---|---|---|
| F1 printer / symlinked / unpinned gate read 10 | A | R5b/R5c/R5g **FAIL** (`guard=0`, unpinned); pin + rc 0 + exact `CLEAN (clocks=10 … tool=0)` |
| F2 vacuous `--selftest` read 10 | A | G3 **FAIL**; literal `PASS (20 cases)` |
| F3 `http_status`/`fetched` unconstrained | A/B | R2i **0**, C2 (`2026-11-7`) **0**, C3 (`302`) **0** |
| F4 cross-wired captures (S101/S114→S113 page) | A/B | R2j/R2k **0**, C4 (shared sha) **0**, C1 (out-of-capture path) **0** |
| F5 FIFO entry hung gate and counter | A/B | C8 **0** in ~2 s; gate prints `UNSUPPORTED … reason=non-regular-entry` |
| F6 control-quality (bash printer control, inert edits, cascade coupling) | A | controls rewritten (Python printer, gate-edit/symlink/byte-drift, pipefail, hash lines); node in §5.4 |
| F7 `sha256sum`/`cut`/`tail` outside the SETUP guards | B | **closed at E**: every guard fires (`SETUP no-<tool>`, rc 2), 13 SETUP probes in §2 |
| F9 header refusal lost case-insensitivity | C | closed at D and held at E: R3f **0**, five case probes **0**, `1.`/`1.0`/`1_0` **FAIL** |

The only recipe readings of 10 are named-ceiling or predicate-allowed: R3g (hand-written
self-consistent capture), R1e (`-> count=N`), R1g (date/prose edit).

## 1. Method

Reference trees: `tar -cf - corpus .ufo/waves/round-45/controls/capture-r45
.ufo/waves/round-55/capture .ufo/waves/round-56/capture` from the working tree (epoch A) and
`git archive <rev>` for B–E, so there is no drift. Every mutant is `cp -a <ref> <mutant>` plus one
recipe from `mutate.py` (sha256
`4a5a780b45c101aa76c609baf7007cda3b12d3c16003f8111b1542f80b082d11`), with `assert t != s` on every
edit; recipes whose anchor changed between epochs fail loudly (`RECIPE-ERROR`, seen once for the
R5d/e/f print anchors, which were then re-derived).

Because the lane's counter changed repeatedly mid-wave, epochs B–E were run against **pinned
snapshots**: a `git clone --shared --no-checkout` of the lane in scratch (read-only on the lane) with
the epoch's counter copied to `<clone>/plans/round-56-c1.sh`, so `REPO`,
`BASE:corpus/rendered-text-v1.py` and both SHA256 pins are frozen to the bytes under test:

```
cd /fast/scratch/hyaku/kagi-r56/R56MutCounter
HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r56/R56MutCounter \
  bash <pinned counter> --tree <mutant tree>
```

`HYAKU_SCRATCH` was redirected into my own scratch so the counter's `$SCR` never collided with a
sibling's `c1.*`. Every non-SETUP run exited **0** (43 A, 44 B, 53 C, 61 D, 61 E): the `C1_REPLAY:`
line is the only verdict channel; rc 0 is not a pass.

## 2. Baselines and SETUP at epoch E

| tree | reading | rc |
|---|---|---|
| `git archive dd31b786` | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | 0 |
| `832ba6a` via `--tree` | `value=0 present=10 replayed=0 gate=0 guard=1` | 0 |
| gate direct | `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` | 0 |
| gate `--selftest` | `RECHECK_REPLAY_SELFTEST: PASS (20 cases)` | 0 |

13 SETUP probes, each with a `/usr/bin`-symlink PATH missing exactly one tool (or an unusable
argument), all `SETUP … ` with exit 2: `no-python3`, `no-grep`, `no-pdftotext`, `no-sha256sum`,
`no-cut`, `no-tail`, `no-timeout`, `no-git`, `no-tar`, `scratch` (`HYAKU_SCRATCH=/proc/nope`),
`bad-revision`, `no-revision`, `tree`. The ten ids bound by the positive run are S055, S070, S101,
S113, S114, S074, S078, S067, S054, S057.

## 3. Matrix — readings per epoch

`A`–`E` are the counter's `value=` token in that epoch. Full 64-hex digests of every mutated file are
in `R56MutCounter.d/matrixABCDE.tsv` (per-epoch JSON: `resultsE.json`, `resultsC711.json`,
`resultsD.json`, `resultsD2.json`, `resultsEp.json`, `resultsEp2.json`); findings carry their digests
inline.

| id | recipe (one edit) | A | B | C | D | E | verdict at E |
|---|---|---|---|---|---|---|---|
| R1a | delete trufflehog `recheck:` line body | FAIL | FAIL | FAIL | FAIL | FAIL | killed |
| R1b | betterleaks `-> 1` → `-> 2` | FAIL | FAIL | FAIL | FAIL | FAIL | killed |
| R1c | append a second `recheck:` line | FAIL | FAIL | FAIL | FAIL | FAIL | killed |
| R1d | command URL `'…'` → `"…"` | FAIL | FAIL | FAIL | FAIL | FAIL | killed |
| R1e | `-> 1` → `-> count=1` | 10 | 10 | 10 | 10 | 10 | allowed form |
| R1f | `-> 1` → `-> 10` | FAIL | FAIL | FAIL | FAIL | FAIL | killed |
| R1g | `(ran 2026-10-23)` → `(ran 2026-11-06)` | 10 | 10 | 10 | 10 | 10 | prose only |
| R2a | delete manifest S054 row | 0 | 0 | 0 | 0 | 0 | killed |
| R2b | duplicate manifest S054 row | 0 | 0 | 0 | 0 | 0 | killed |
| R2c | duplicate registry S054 row | 9 | 9 | 9 | 9 | 9 | counter-only kill |
| R2d | registry S113 status `mined`→`staged` | 9 | 9 | 9 | 9 | 9 | counter-only kill |
| R2e | registry S070 URL moved to teaches cell | 9 | 9 | 9 | 9 | 9 | counter-only kill |
| R2f | registry S074 row only inside a ``` fence | 9 | 9 | 9 | 9 | 9 | counter-only kill |
| R2g | manifest header columns swapped | 0 | 0 | 0 | 0 | 0 | killed |
| R2h | manifest S054 `id` → `S055` | 0 | 0 | 0 | 0 | 0 | killed |
| R2i | S054 `http_status=404`, `fetched=1999-01-01` | **10** | **10** | 0 | 0 | 0 | closed at C |
| R2j | S101 → round-55 `S113.body` + its bytes/sha | **10** | **10** | 0 | 0 | 0 | closed at C |
| R2k | S114 → round-55 `S113.body` + its bytes/sha | **10** | **10** | 0 | 0 | 0 | closed at C |
| R3a | append `x` to S054.body | 0 | 0 | 0 | 0 | 0 | killed |
| R3b | S054 `body_path` → absolute path | 0 | 0 | 0 | 0 | 0 | killed |
| R3c | S054 `body_path` → `../../S054.body` | 0 | 0 | 0 | 0 | 0 | killed |
| R3d | capture entry replaced by a symlink | 0 | 0 | 0 | 0 | 0 | killed |
| R3e | `HTTP/2 200\r\nset-cookie: x=1\r\n\r\n` prefix (manifest refixed) | 0 | 0 | 0 | 0 | 0 | killed |
| R3f | `\nSet-Cookie: y=2\n` mid S074.body (manifest refixed) | 0 | 0 | **10** | 0 | 0 | closed at D (F9) |
| R3g | S054.body → one line carrying the pattern once (refixed) | 10 | 10 | 10 | 10 | 10 | named ceiling |
| R4a | one extra pattern line in S054.body (refixed) | 0 | 0 | 0 | 0 | 0 | killed |
| R4b | *flawed recipe* (quote edited in the CDP entry) | FAIL | FAIL | FAIL | FAIL | FAIL | superseded by R4b2 |
| R4c | delete tree `corpus/rendered-text-v1.py` | 0 | 0 | FAIL | FAIL | FAIL | killed (normalizer pin) |
| R5a | gate → bash `CLEAN` printer | FAIL | 0 | FAIL | FAIL | FAIL | killed |
| R5b | gate → Python printer (ten `MATCH` + `CLEAN` + `PASS`) | **10** | 0 | FAIL | FAIL | FAIL | closed at B/C |
| R5c | same printer, run path `sys.exit(1)` | **10** | 0 | FAIL | FAIL | FAIL | closed at B/C |
| R5d | gate print patched: `id=S055`→`S999` | 9 | 0 | FAIL | FAIL | FAIL | killed |
| R5e | gate print patched: `form=locate`→`grep` | 9 | 0 | FAIL | FAIL | FAIL | killed |
| R5f | gate `clocks()` skips `betterleaks*` | 9 | 0 | FAIL | FAIL | FAIL | killed |
| R5g | gate → absolute symlink to the printer | **10** | 0 | FAIL | FAIL | FAIL | closed at B/C |
| R5h | gate `main`: `return rc if rc else 1` | FAIL | 0 | FAIL | FAIL | FAIL | killed |
| G1 | selftest `PASS` then `return 1` | FAIL | 0 | FAIL | FAIL | FAIL | killed |
| G2 | selftest `PASS` then a noise line | FAIL | 0 | FAIL | FAIL | FAIL | killed |
| G3 | `selftest()` gutted (`PASS (0 cases)`) | **10** | 0 | FAIL | FAIL | FAIL | closed at B/C |
| G4 | gate replaced by a directory | FAIL | 0 | FAIL | FAIL | FAIL | killed |
| N2 | gate file deleted | 0 | 0 | 0 | 0 | 0 | BASE shape |
| C1 | body copied to `corpus/S054copy.body`, row points there | – | – | 0 | 0 | 0 | killed (not-capture) |
| C2 | S054 `fetched=2026-11-7` | – | – | 0 | 0 | 0 | killed |
| C3 | S054 `http_status=302` | – | – | 0 | 0 | 0 | killed |
| C4 | S101 → byte-identical copy of S054.body (shared sha) | – | – | 0 | 0 | 0 | killed |
| C5 | tree normaliser + `# mutant` | – | – | FAIL | FAIL | FAIL | killed |
| C6 | tree normaliser deleted | – | – | FAIL | FAIL | FAIL | killed |
| C7 | `< HTTP/2 200` trace prefix at column 0 | – | – | 0 | 0 | 0 | killed |
| C8 | `mkfifo corpus/knowledge/zzz-fifo.md` | – | TIMEOUT | 0 | 0 | 0 | killed, no hang |
| C9 | `corpus/knowledge` replaced by a symlink | – | – | FAIL | FAIL | FAIL | killed |
| C10 | betterleaks `-> 1` → `-> 1x` | – | – | FAIL | FAIL | FAIL | killed |
| D1 | `Set-Cookie: x=1` at column 0 | – | – | 10 | 0 | 0 | F9 probe |
| D2 | `SET-COOKIE: x=1` at column 0 | – | – | 10 | 0 | 0 | F9 probe |
| D3 | `set-cookie: x=1` at column 0 | – | – | 0 | 0 | 0 | control |
| D4 | `http/2 302 Found` at column 0 | – | – | 10 | 0 | 0 | F9 probe |
| D5 | `< Set-Cookie: x=1` at column 0 | – | – | – | 0 | 0 | trace-prefix case |
| D6 | betterleaks `-> 1.` | – | – | – | FAIL | FAIL | N boundary |
| D7 | betterleaks `-> 1.0` | – | – | – | FAIL | FAIL | N boundary |
| D8 | betterleaks `-> 1_0` | – | – | – | FAIL | FAIL | N boundary |

Boundary and case probes at D/E read `present=9 replayed=9 gate=1 guard=0` — the counter's PRESENT
refuses the restatement while the gate stays CLEAN, so those kills do not depend on the DRIFT cascade.

## 4. The two regressions/gaps this audit found, and their closure

**F9 (epoch C only, closed at D, held at E).** The epoch-C rewrite of the r3 header refusal dropped
`(?i)`: gate line 216 and counter line 287 used
`rb"(?m)^(?:HTTP/\d|< HTTP/\d|< set-cookie\s*:|set-cookie\s*:)"` where epoch B had
`re.search(rb"(?im)^set-cookie:", data)`. On `711e6393` the canonical spellings passed —
`Set-Cookie: x=1` (manifest `9b12b75d7627c1652386eda7d9936ba514bcdd879b1a8bb2e876ebe44594afe8`,
S057.body `21cddee3d9b2bd9d3f5b5a621f3d2b2c67d7c32843d7e299675267d32aa7a05c`), `SET-COOKIE:`, and
`http/2 302 Found` (manifest `74db40edf770fe270bd76f1b5471191da8df284ed7aafcfd62fb838a61b973b1`,
S074.body `4a278f2876f9955feb2046b90cdd1b8df716f0fa1e57210ceeb7e7f7d136b912`) all read **10**, and
the standard R3f recipe (body `f34217439caaa630ac2ed5ea9123dd54a639bc2a3e96e6830518359e8a80c9f2`,
manifest `51ea192e16a8f50cafea3890d0908e46b07a46997e0a4d6fc51604c6556f236b`) read 0/0/**10** across
A/B/C. Gate-level proof on the identical mutant tree: `711e6393` gate `e9b7e4b7` → `CLEAN`;
`5165da2a` → `BAD-CAPTURE … id=S074 reason=header-bytes:.ufo/waves/round-56/capture/S074.body` +
`DRIFT (clocks=10 match=9 bad_capture=1)`. Epochs D/E read 0 on R3f and on all five case probes.

**F7 (epochs B/C/D, closed at E).** `sha256sum`, `cut` and `tail` sat outside the `command -v`
guards: with `cut` absent the counter printed `line 94: cut: command not found` and then
`value=0 … gate=0` (`r5-gate` ×10), rc 0; with `tail` absent `value=FAIL … (bad=selftest)`, rc 0 —
fail-closed in value but not labelled SETUP. Epoch E guards `sha256sum cut tail timeout git tar` and
all nine tool guards plus the four argument guards exit 2 with `SETUP …` (§2).

## 5. Residual notes (not defects against the frozen predicate)

1. **r4 normaliser isolation is real and twice-enforced.** R4b2 (A and B) doctored the S070 body
   (BASE normaliser count **0**), faked the *tree* normaliser to `count=1` and refixed the manifest
   (body `c279f654514d0a43f0c97a0e3fbbb4d2fe43357c82f2d3b5a5d85e27286c6302`, manifest
   `70fabf3510ab9a47bd49f020132c16adf0fb564668f43241534b7e3a71d63726`, fake normaliser
   `924062d3a903f1cb7d29a79dcf50dbdf27e54194e47a4ebf40ccaf9670f1db12`): the gate went CLEAN while
   the counter read `value=9 … bad=r4-replay0:cdp-bridge-1password-oidc-workflow.md:custom-workflow`.
   From C on, `NORMALIZER_SHA256_PIN=14f6ca6a…` refuses any changed normaliser before replay
   (C5/C6 → FAIL). Keep both mechanisms.
2. **Counter stricter than the gate on r2**: duplicate registry row, `staged` status, URL outside the
   source cell and a fenced-only row each read **9** while the gate says CLEAN (`registry_rows` keeps
   the last row per id, no fence handling, no cell count, no status check) — latent if r2 is ever
   loosened to the gate's rules.
3. **By-design survivors**: R3g (hand-written self-consistent body `253e48238dc9b10bef7685dacc4ef9fd
  429804b6dee719b6fb6c4d30f72156b7`, manifest
   `d8d9c2093cff9606ce17154dacad9c5b4142080736458fb044d347011d1474dc`) — the plan's named ceiling;
   only the receipt plus a non-author live re-fetch closes it. R1e/R1g are predicate-allowed.
4. **F6, control quality**: the epoch-A control F5 wrote a **bash** printer that the counter runs with
   `python3` (rejected with `SyntaxError: unmatched ')'`, i.e. not by the MATCH-line rule); epoch-A F2
   had two inert edits; epoch-A F3/F4/F6/F7/F8 read 0 only via the gate-DRIFT cascade. B–E controls
   replace the printer with Python, add gate-edit/gate-symlink/byte-drift cases, and (per KagiR56a3)
   pipefail + instrument hash lines. The cascade coupling in F3/F4 remains worth stating: if r5 ever
   becomes non-blocking those rows read 9, not 0. Epoch-E controls report 22/22 MATCH (KagiR56a3); I
   did not re-run that script.
5. **Governance**: `GATE_SHA256_PIN` couples counter to gate, while the plan's kill rule names only
   `plans/round-56.md plans/round-56-c1.sh plans/round-56-controls.sh`. I observed two incoherent
   pairs mid-wave (counter `d2bcb790…` pinning `637c8184…` while the gate was `2e9dfde3…`; counter
   `842c014f…` pinning `e9b7e4b7…` while the gate was `5165da2a…`) — each reads `value=0` with
   `r5-gate` ×10. `d362318` and `dd31b786` are coherent; any gate edit must bump the pin in the same
   commit, and adding the gate to the kill-rule pathspec makes that explicit.

## 6. Restoration / no-production-edit evidence

- Committed bytes equal what I tested at every epoch: `git show <rev>:<path>` for `42070de`
  (counter `096251c9…`, gate `b7782f35…`, manifest `df46be5c…`, controls `633326a5…`, plan
  `d1bf8d26…`), `5d9a157` (counter `6b132ea1…`, gate `2e9dfde3…`), `711e6393` (counter `7992ee6a…`,
  gate `e9b7e4b7…`), `d362318` (counter `82acbb20…`, gate `5165da2a…`), `dd31b786` (counter
  `d468533f…`, gate `5165da2a…`, manifest `df46be5c…`, controls `01060f25…`, plan `212e2dd7…`).
  Epoch-A instrument hashes were identical at 07:22 and 07:34, and all 22 instrument inputs
  (SOURCES.md, manifest, gate, normaliser, the 8 entries, S101.raw, S113/S114/S054/S055/S057/S067/
  S070/S074/S078) compared byte-for-byte between lane and tested tree.
- Lane access was read-only throughout (`rev-parse`, `log`, `status`, `show`, `archive`, `clone`); no
  git/jj mutation in the lane or a sibling; no write to `~/.local/bin` or any PATH dir; no tool
  installed; no network call (the gate and counter replay committed bytes only — no `curl` ran).
- Scratch collision, recorded because it destroyed an artifact: a sibling mutation seat wrote into my
  seat path from 07:46 (`driver.py`, `mut-m01…m32`, `clone/`, `ref*/snap*`, several hundred MB each),
  overwrote my scratch `results.json` with its own schema and removed some of my mutant trees. My runs
  used explicit paths and were unaffected; the preserved epoch-A artifact is
  `R56MutCounter.d/matrix.tsv` (copied at 07:34). I deleted only my own artifacts and left the
  sibling's live files in place.
- Seat receipt: `.ufo/waves/round-56/build/R56MutCounter.d/` — `matrixABCDE.tsv`, `matrixABCD.tsv`,
  `matrixABC.tsv`, `matrixAB.tsv`, `matrix.tsv`, `resultsE.json`, `resultsC711.json`, `resultsD.json`,
  `resultsD2.json`, `resultsEp.json`, `resultsEp2.json`, `mutate.py`, `followups.py/.json`,
  `F9-header-case.txt`, `gate-A.py`, `gate-C.py`, `gate-D.py`, `gate-E-d362318.py`,
  `gate-W-f9fix.py`, `counter-D.sh`, `counter-E-d362318.sh`, `counter-F-dd31b786.sh`, `e1.log`,
  `e2.log`, `versions.txt`, `epochB-anchored.txt`, `probes.txt`, `probesD.txt`, `probesE.txt`,
  `hashes.txt`.

## 7. Unrun / not passed

Every assigned axis was executed in at least one epoch and re-verified at E: no-work, positive, r1,
r2, r3, r4, r5, guard, gate invocation rc, selftest rc and last line, normaliser isolation, the SETUP
paths, and (C onward) capture confinement, fetched/2xx, body_path/sha bijection, normaliser pin,
trace prefixes, non-regular entries, symlinked knowledge, the N right-boundary and the header-case
class. Not tested, stated so it is not mistaken for passed: live re-fetch currency on the day
(network, another seat), the honesty of `capture/fetch-receipt.json` (neither instrument reads it),
and the epoch-E controls script itself (KagiR56a3 reports 22/22 MATCH; I did not re-run it).
