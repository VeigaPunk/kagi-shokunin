# R56MutGate — mutation probe of the frozen replay gate and C1 counter

Seat: R56MutGate (mutation-tester). Lane `kagi-shokunin`, branch `master`.
**Epoch B (current instruments) is anchored to `5d9a1571911ec38a456a40b443e19640abb9a88b` — see the addendum at the end; that is the binding result.** The first part records the original probe of the epoch-A pre-freeze instruments at `42070de7770e1558adcf6aa7a7bc59309a9654d7`, kept as history.
Tested revision (epoch A): `42070de7770e1558adcf6aa7a7bc59309a9654d7`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
Answering model: `amr/deepseek-v4.1-flash` (as stated by the runtime project context; not independently observed).
No network, no production-file edits, no git/jj mutation in the lane. Scratch `/fast/scratch/hyaku/kagi-r56/R56MutGate/` (one clone + fixture trees), deleted after the probe.

## Bytes under test

| artifact | rev | sha256 |
|---|---|---|
| `corpus/recheck-replay.py` | `git cat-file blob HEAD:corpus/recheck-replay.py` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` |
| `plans/round-56-c1.sh` | `git cat-file blob HEAD:plans/round-56-c1.sh` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` |
| harness | `harness.py` (copy in `R56MutGate.d/`) | `00a67594620538b5b5aefa72092f1d9ec4da577dcbff2d4d07a3fc4b0cf54cee` |

Baseline on a fixture tree built from those bytes (corpus + the three capture dirs), commands:
`python3 -I -B corpus/recheck-replay.py --selftest` → rc 0, `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`;
`python3 -I -B corpus/recheck-replay.py --root T` → rc 0, `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`;
`bash plans/round-56-c1.sh --tree T` (HYAKU_SCRATCH in scratch) → rc 0, `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`.

Every mutant is one literal replacement (the harness asserts the anchor occurs exactly once). For each mutant the harness builds two identical hostile trees: **P** = pristine gate + hostile tree + frozen counter (hostility witness), **M** = mutant detector on the same hostile tree. Detector set: gate `--selftest`, gate `--root`, frozen counter `--tree`.

## Mutant table

Gate-side mutants (file `corpus/recheck-replay.py`, line numbers at the tested rev):

| id | mutation (anchor → replacement) | gate selftest | P: pristine gate / frozen counter on hostile tree | M: mutant gate `--root` / mutant counter | verdict |
|---|---|---|---|---|---|
| M1 | L174 `HTTP/\d \|\| (?im)^set-cookie:` → drop set-cookie conjunct | rc 0, PASS (13) | rc 1 `DRIFT … bad_capture=1`; counter `value=0` | CLEAN; counter `value=9 present=10 replayed=9 gate=1 guard=1 (bad=r3-headers:secret-scanning-detection-vs-validation.md:README.md)` | **killed** (frozen counter's own r3 header check) |
| M2 | L174 drop `HTTP/\d` conjunct, keep set-cookie | rc 0, PASS (13) | rc 1 `DRIFT … bad_capture=1`; counter `value=0` | CLEAN; counter `value=9 … (bad=r3-headers:secret-scanning…)` | **killed** (counter r3) |
| M4 | L172 `if hashlib.sha256(data).hexdigest() != row["sha256"]:` → `if False:` | rc 1, `FAIL (1 of 13 cases)` | rc 1 `DRIFT … bad_capture=1`; counter `value=0` | CLEAN; counter `value=FAIL present=10 replayed=9 gate=1 guard=0 (bad=r3-digest:secret-scanning…,selftest)` | **killed** (selftest `sha-mismatch`; counter r3-digest) |
| M5 | L160 drop `".." in Path(rel).parts` | rc 0, PASS (13) | rc 1 `DRIFT … bad_capture=1`; counter `value=0` | CLEAN; counter `value=9 … (bad=r3-path:secret-scanning…)` | **killed** (counter r3 path) |
| M6 | L165 `if cur.is_symlink():` → `if False:` | rc 1, `FAIL (1 of 13 cases)` | rc 1 `DRIFT … bad_capture=1`; counter `value=0` | CLEAN; counter `value=FAIL present=10 replayed=9 gate=1 guard=0 (bad=r3-file:secret-scanning…,selftest)` | **killed** (selftest `symlink-component`; counter r3-file) |
| M7 | L221 `tally["UNSUPPORTED"] += 1` → `tally["MATCH"] += 1` | rc 1, `FAIL (2 of 13 cases)` | rc 1 `DRIFT (clocks=11 match=10 … unsupported=1)`; counter `value=0` | CLEAN; counter `value=FAIL present=10 replayed=10 gate=1 guard=0 (bad=selftest)` | **killed** (selftest only; counter replay logic blind — replayed=10, gate=1) |
| M8 | L183 `grep -c -e arg` → `grep -c -F -e arg` | rc 1, `FAIL (1 of 13 cases)` | rc 0 `CLEAN`; counter `value=10` (tree is BRE-true) | not CLEAN (MISMATCH on S067); counter `value=FAIL … gate=0 guard=0`, all ten `r5-gate` | **killed** (selftest `bre-not-substring`; counter via gate output) |
| M9 | L144 `if cols[1] in rows:` → `if False:` | rc 0, PASS (13) | rc 2 `SETUP manifest-duplicate-url:https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md`; counter `value=0` | CLEAN; counter `value=9 … (bad=r2-rows2:secret-scanning…)` | **killed** (counter r2 rows) |

Counter-side mutants (`plans/round-56-c1.sh`; the frozen gate has no registry-status or cell-count conjunct, so these two of the tasking's list land in the counter where the conjunct lives; M11 likewise):

| id | mutation (anchor → replacement) | gate selftest | P: frozen counter on hostile tree | M: mutant counter | verdict |
|---|---|---|---|---|---|
| M3 | L243 drop `rr[0][7] != "mined" or ` | unchanged (PASS 13) | `value=9 present=10 replayed=9 gate=1 guard=1 (bad=r2-registry:iso-11770-3-edition-status.md:60237.html)` | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` | **SURVIVED** |
| M10 | L243 drop `len(rr[0]) != 11 or ` | unchanged (PASS 13) | `value=9 … (bad=r2-registry:iso-11770-3-edition-status.md:60237.html)` | `value=10 … (bad=none)` | **SURVIVED** |
| M11 | L262 `want` regex → `^MATCH %s:\d+ id=%s` (drop `form=… stated=… replayed=…$`) | unchanged (PASS 13) | `value=0 present=10 replayed=0 gate=1 guard=1 (bad=r5-gate:` ×10`)` | `value=10 … (bad=none)` | **SURVIVED** |

Hostile-tree constructions (all inside the fixture copy; manifest bytes/sha256 updated where the body changed, unless stated):

- M1: `.ufo/waves/round-56/capture/S054.body` prefixed `set-cookie: s=1\n` → 38540 B, sha256 `6a3e9f9f0baf7fc2bcdfca143386b474cf44af3684272b3bb03b6b6a51d650ba`; manifest row S054 bytes/sha updated.
- M2: same body prefixed `HTTP/2 200\r\n` → 38536 B, sha256 `71df0cc791cdcaf0b9560342a7ec522b0393a6c6c459852ed867ebc2118a3580`; row updated.
- M4: S054.body byte changed in place (same 38524 B) → sha256 `65e260c7934cfb767a9f4043b688b68a5996c7ec01adc5eb5ad9e9c8218b0f40`; manifest row left at `7cf6efb5…` (stale digest, byte count unchanged — isolates the sha conjunct from the bytes conjunct).
- M5: manifest S054 `body_path` = `.ufo/waves/round-56/capture/../capture/S054.body` (a `..` that resolves to the real file); bytes/sha unchanged.
- M6: S054.body renamed to S054.real and replaced by symlink `S054.body -> S054.real`; manifest unchanged.
- M7: extra entry `corpus/knowledge/zz-extra.md` with ``recheck: 90d — `curl -fsSL 'https://example.test/x' | sed -n 1p` -> 0`` (11th clock, unsupported form).
- M8: S067.body `It MUST contain the OAuth 2.0` → `It MUST contain the OAuth 2x0` → 437508 B, sha256 `65d51d513b4f7bbfe14f40f6ebeafd22778665e6b92ff991a84ff441ebd9614f`; row updated (BRE count still 1, `-F` count 0).
- M9: duplicate S054 manifest data row appended.
- M3: `corpus/SOURCES.md` row S101 cell 8 (1-based) `mined` → `drafted` (tree sha `9a8fb793edafb37b83314d0d7ec756af49b281016ee3983d13eeb3318806bd90`).
- M10: S101 row 11 → 10 cells (trailing cell dropped, status cell still index 7 `mined`; tree sha `7862b0320e13028ce2e6caf1ceeae4d5d431104fe832ad8612879c012221efb0`).
- M11: gate replaced by a stub that prints `MATCH <entry>:1 id=<id>` (no `form=/stated=/replayed=`), a PASS selftest line and a CLEAN last line (stub sha `794dea4f9319bcdae8121c8d397bb8395cbcd6eb5a13a58d2fda5c0a2ddb074c`).

## Surviving mutants and proposed kills

Survivors: **M3, M10, M11** (3/11). Each was demonstrated discriminating on the frozen counter: pristine reads `9`/`0`, mutant reads `10 bad=none`.

1. **M3 — registry status not checked.** Proposed control row (a future round's control set; the frozen controls are not to be edited in this round), on the REF tree:
   `K1-F11-status-not-mined`: set `corpus/SOURCES.md` S101 status cell to `drafted`, expect `9`.
   Observed: frozen counter `value=9 … (bad=r2-registry:iso-11770-3-edition-status.md:60237.html)`; M3 counter `value=10 (bad=none)`. Kills M3.
2. **M10 — 11-cell check dropped.** Proposed control row `K1-F12-registry-cells-10`: drop S101's trailing cell (10 cells), expect `9`.
   Observed: frozen `value=9 … bad=r2-registry…`; M10 `value=10 (bad=none)`. Kills M10.
3. **M11 — MATCH-line regex weakened.** Proposed control row `K1-F13-truncated-match-line`: replace the tree's gate with a stub emitting `MATCH <entry>:1 id=<id>` for the ten BASE clocks plus PASS selftest and CLEAN last line, expect `0`.
   Observed: frozen `value=0 … (bad=r5-gate:`×10`)`; M11 `value=10 (bad=none)`. Kills M11.

Gate `--selftest` additions for the four gate mutants that only the frozen counter killed (the gate's own selftest passed them):

- M1: capture body carrying only `set-cookie: x=1` (no `HTTP/` line), digest-consistent → expect BAD-CAPTURE `header-bytes:`.
- M2: body beginning `HTTP/2 200\r\n` with no set-cookie line → expect BAD-CAPTURE `header-bytes:`.
- M5: manifest `body_path=.ufo/../.ufo/b.body` resolving to the real body → expect BAD-CAPTURE `body-path:`.
- M9: two manifest rows for one URL → expect `SETUP manifest-duplicate-url` rc 2.

M7 needs no new case: `unsupported-form` and `extra-curl-flag` already FAIL under it, and pre-freeze control F8 (unsupported clock added to a non-POP entry, expect `0`) also catches it at value level (mutant → CLEAN would read `10`).

## Coverage findings (not contract changes)

- The selftest header fixture is doubly signed (`HTTP/2 200` **and** `set-cookie:` in the same body, L291), so dropping either single conjunct leaves the selftest green (M1, M2 both PASS).
- The selftest escape fixture uses `../b.body`, which does not exist at the escaped path, so BAD-CAPTURE fires through `body-missing`, not through the `..` reject; dropping the `..` check passes the selftest (M5 PASS).
- There is no duplicate-URL selftest case (M9 PASS).
- The frozen counter re-implements r2/r3 independently; it is the sole killer of M1, M2, M5, M9, and a co-killer of M4 and M6. Gate `--selftest` alone would miss four of the eight gate-side mutants.
- The counter's POP is fixed at the ten BASE commands, so an added unsupported clock changes only `gate_clean`/`guard`; M7 left the counter's replay logic untouched (`replayed=10 gate=1`) and died only through the selftest guard.
- Frozen control F3 (append one byte) changes the byte count, so it does not isolate the sha256 conjunct; F5 (CLEAN printer with no MATCH lines) does not cover M11's truncated-MATCH-line form; F7 (header bytes) injects both header signals, so it does not isolate M1/M2 either. Frozen controls F11–F13 above are the missing rows.
- M8's hostile tree is BRE-true, so the frozen counter reads `10` on it; the only discriminating detector is the gate selftest's `bre-not-substring` case (plus the derived gate-output check).

## Epoch B addendum — re-frozen instruments at `5d9a1571911ec38a456a40b443e19640abb9a88b`

L1 re-froze the round at epoch B after R56ReviewCounter F1–F7 and R56Sentinel confinement. All evidence below is anchored to that revision.

| artifact | sha256 at `5d9a157` |
|---|---|
| `corpus/recheck-replay.py` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` |
| `plans/round-56-c1.sh` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` |
| `plans/round-56-controls.sh` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` |
| `plans/round-56.md` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| harness | `harness-eB.py` `428699f270c7d0dd7bbea8ace68469f5c2d72bc61d2b6b005612135a8bc5e18c` |

Baseline at `5d9a157` on a fixture tree extracted from the commit: gate `--selftest` rc 0 `PASS (13 cases)`; gate `--root` rc 0 `CLEAN (clocks=10 match=10 …)`; counter rc 0 `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`.

Epoch-B changes that move the mutation surface: the counter now pins the gate bytes (`GATE_SHA256_PIN=2e9dfde3…`) and requires `HAVE_GATE`, `--root` rc 0 and the exact `CLEAN (clocks=10 match=10 … 0)` summary; the gate adds input confinement for `corpus/knowledge`, `corpus/SOURCES.md`, `corpus/recheck-captures.tsv` and the locate normaliser (SETUP `symlinked-input:`), and reports a symlinked knowledge entry as a clock-less UNSUPPORTED row instead of skipping it silently.

Method: the same single-point replacements re-applied to the epoch-B bytes (every anchor still unique; M7 anchored with its `if url is None:` line because epoch B has two `UNSUPPORTED` tallies), plus M12/M13 for the new confinement conjuncts and M14 for the pin conjunct. Three readings per run: **P** = pristine pinned gate + hostile tree + epoch-B counter; **M** = mutant detector with the pin active; **M′** = a *diagnostic* pin-bypass counter (`if true; then`, not a candidate) to read the conjunct-level detector apart from the pin.

| id | mutation at `5d9a157` | selftest | P counter | M counter (pin active) | M′ (pin bypassed, diagnostic) | verdict |
|---|---|---|---|---|---|---|
| M1 | gate L174 drop set-cookie conjunct | PASS 13 | 0 (DRIFT bad_capture=1) | 0 (gate=0, all r5) | 9 `r3-headers:secret-scanning…` | killed (pin; conjunct caught by counter r3) |
| M2 | gate L174 drop `HTTP/\d` conjunct | PASS 13 | 0 | 0 | 9 `r3-headers:…` | killed (pin; counter r3) |
| M4 | gate L172 sha verify → `if False` | FAIL 1/13 | 0 | 0 | FAIL `r3-digest…,selftest` | killed (pin, selftest, counter r3-digest) |
| M5 | gate L160 drop `..` path reject | PASS 13 | 0 | 0 | 9 `r3-path:…` | killed (pin; counter r3 path) |
| M6 | gate L165 symlink check → `if False` | FAIL 1/13 | 0 | 0 | FAIL `r3-file…,selftest` | killed (pin, selftest, counter r3-file) |
| M7 | gate L242 `UNSUPPORTED` tally → `MATCH` | FAIL 2/13 | 0 (DRIFT clocks=11) | 0 | FAIL (gate not clean; guard 0) | killed (pin, selftest) |
| M8 | gate L183 `grep -e` → `grep -F -e` | FAIL 1/13 | 10 (tree is BRE-true) | 0 (gate bytes not pinned) | FAIL gate=0 guard=0 | killed (pin; selftest is the discriminating detector) |
| M9 | gate L144 duplicate-URL check → `if False` | PASS 13 | 0 (SETUP manifest-duplicate-url) | 0 | 9 `r2-rows2:…` | killed (pin; counter r2) |
| M12 | gate drop `confined()` over the four inputs | PASS 13 | 0 (SETUP `symlinked-input:corpus/SOURCES.md`) | 0 | 0, gate=1 but every clock `r2-registry` (counter's own `read()` confinement empties the registry) | killed (pin; counter's independent confinement). Selftest does not cover input confinement |
| M13 | gate drop the symlinked-entry UNSUPPORTED row | PASS 13 | FAIL (present=9 guard=0) | FAIL | FAIL (present=9; gate_clean requires clocks=10) | killed (counter present/guard + CLEAN(10/10)). Selftest does not cover it |
| M3 | counter L248 drop `rr[0][7]!="mined"` | n/a (gate pinned, PASS 13) | 9 `r2-registry:iso-11770-3-edition-status.md:60237.html` | `value=10 (bad=none)` | 9 | **SURVIVED** |
| M10 | counter L248 drop `len(rr[0])!=11` | n/a (gate pinned) | 9 `r2-registry:…60237.html` | `value=10 (bad=none)` | 9 | **SURVIVED** |
| M11 | counter L267 weaken MATCH regex to `^MATCH %s:\d+ id=%s` | n/a (gate pinned) | 0 (truncated-line stub gate fails the pin) | 0 | 10 with M11+pin-bypass **combined** | **latent survivor**: unreachable while the pin holds; the regex itself is still under-checked |
| M14 | counter L96 drop the pin condition (`if true`) | n/a | 0 (full-MATCH stub gate fails the pin) | `value=10 (bad=none)` | 10 | **SURVIVED** |

Byte identity for the epoch-B hostile trees (same constructions as epoch A unless noted): S054 38540 B `6a3e9f9f…` (set-cookie), 38536 B `71df0cc7…` (HTTP/), 38524 B `65e260c7…` with stale manifest `7cf6efb5…` (M4), manifest `body_path=…/capture/../capture/S054.body` (M5), `S054.body -> S054.real` (M6), `S067.body` `65d51d51…` (M8), duplicate S054 row (M9), S101 status `drafted` (M3), S101 10 cells (M10), `corpus/SOURCES.md -> SOURCES.real` (M12), `corpus/knowledge/oidc-federation-trust-policy.md -> ../oidc-entry.real` (M13). Printer stubs: truncated-MATCH `d5befcce069afd8ff21acc45f1f36bac91f31b218770c76a1522715797c67dea` (M11), exact full-MATCH `159d4221ccac90cd96a7618f06b381cbe41b941f17bb5fcdf1622975d7f68156` (M14).

### Epoch-B kill proposals

1. **M3** — control on the REF tree with S101 status cell `drafted`, expect `9`; epoch-B counter reads 9 (`bad=r2-registry:iso-11770-3-edition-status.md:60237.html`), M3 reads 10.
2. **M10** — control with S101 row truncated to 10 cells, expect `9`; epoch-B reads 9, M10 reads 10.
3. **M14** — control with the tree's gate replaced by the exact full-MATCH printer stub `159d4221…` (all ten `MATCH … form=… stated=… replayed=…` lines, `CLEAN (clocks=10 match=10 … 0)`, `--selftest` PASS 13), expect `0`; epoch-B reads 0, M14 reads 10. Epoch-B's K1-F5 printer control does **not** cover this: F5 emits no MATCH lines, so it fails r5 even with the pin dropped; only a stub that fabricates the exact MATCH lines isolates the pin.
4. **M11 (latent)** — no control can expose it while the pin holds; if the pin is ever relaxed, add the truncated-MATCH stub `d5befcce…` expecting `0` (with the pin removed, M11 reads 10).

Epoch-B verdict summary: **3 survivors (M3, M10, M14) plus one latent (M11)** out of 14 mutants. The gate digest pin is the dominant epoch-B detector: every gate-byte mutation (M1–M9, M12, M13) is killed by it before any conjunct check, so on epoch B the counter's gate-side mutation surface is effectively zero for a candidate. The remaining live surface is the counter's own conjuncts: registry status (M3), registry arity (M10) and the gate-pin condition itself (M14). The 13-case gate selftest still does not cover input confinement (M12) or symlinked-entry reporting (M13); both are killed only by the counter's duplicated checks.

## State and restoration

- Production bytes were not modified by this seat. The tested blobs equal `git cat-file HEAD:` at `42070de` (hashes above).
- Lane state: during the epoch-A probe the working tree was mid-landing of epoch B (that is why the epoch-A blobs and the working tree diverged). At epoch-B probe time `HEAD=5d9a157…`; afterwards the floating working tree carried candidate edits again (`corpus/recheck-replay.py` `d4392ffe831560397fa35b4e84198b6ac75d5da8505a302ef3dcf6991080b274`, `plans/round-56-c1.sh` `d4dc9ddca15c059c5e1a119343f1e1a51c845faf83a793437b97c3aaa52a77c3`, `plans/round-56-controls.sh` `aa2479fffff247ce28445f33008c945eb75d7542c42cddd5cedeefbc5aa8bf98`, `corpus/SOURCES.md` `299903cf…`). None of this is this seat's work; results bind to the two named revisions and the `5d9a157` blobs hashed in the addendum.
- Scratch `/fast/scratch/hyaku/kagi-r56/R56MutGate/` (epoch A: clone, 22 fixture trees, logs) and `/fast/scratch/hyaku/kagi-r56/R56MutGate-eB/` (epoch B: clone at `5d9a157`, 28 fixture trees, logs) were deleted after writing this report and `R56MutGate.d/`; receipts kept at `.ufo/waves/round-56/w1/R56MutGate.d/results.json`, `results-epochB.json`, `harness.py`, `harness-eB.py`, `commands.txt`.
- Epoch-B production bytes were not modified by this seat; the tested blobs are the `5d9a157` blobs hashed above. The lane working tree may keep moving under the wave; results here bind to the two named revisions only.
- Unrun: the live re-fetch leg (outside this seat; no network was used). Mutant verdicts are offline readings of committed bytes only.
