# R56MutGate — mutation probe of the frozen replay gate and C1 counter

Seat: R56MutGate (mutation-tester). Lane `kagi-shokunin`, branch `master`.
**Epoch F (current instruments) is anchored to `9cbe9d5f803de2518d4c11c6bc6b9a585e5120ad` (tip `c90e6709`) — see the epoch-F addendum at the end; that is the binding result.** The epoch-E (`dd31b786`), epoch-D (`d362318`), epoch-C (`711e6393`), epoch-B (`5d9a157`) and epoch-A (`42070de`) results are kept as history.
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

## Epoch C addendum — re-frozen instruments at `711e6393e68658f396918c07de253e5a5c74d1b4`

Supplier note: epoch C supersedes epoch B (L1 predeclaration, `round-56: predeclaration epoch C`). Everything in this section is anchored to that revision; it is the binding result.

| artifact | sha256 at `711e6393` |
|---|---|
| `corpus/recheck-replay.py` | `e9b7e4b7aa1e8173c4bfc2e536ce6d1ed29c4c0d6ee5f46bfa1e63d3692a62b4` |
| `plans/round-56-c1.sh` | `7992ee6a97c9f1cfaf627c61322ecaf6aa0c31126a65f591567d7b6f7ee2802c` |
| `plans/round-56-controls.sh` | `b675baa5fad95bc663f49ca76ea13be84627db457af443f3b957144cd8ddd16c` |
| `plans/round-56.md` | `8beb24e94a08c3961f5217a3b4b98aadc46d56561fe3ec2254f13185d4cf6c9f` |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` |
| harness | `harness-eC.py` `d27da7a7b5b7bee39d2072e5e2c2473273f3dbb174d72956ada696ef9e58336f` |

Baseline at `711e6393` on a fixture tree extracted from the commit: gate `--selftest` rc 0 `PASS (18 cases)`; gate `--root` rc 0 `CLEAN (clocks=10 match=10 … 0)`; counter rc 0 `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`.

Epoch-C surface added since B: `capture_confined(body_path)` into `.ufo/waves/*/…/capture*/`; column-0 header refusal incl. `< ` trace prefixes; manifest `fetched`-ISO / `http_status`-2xx / body_path+sha256 bijection; `NORMALIZER_SHA256_PIN=14f6ca6a…`; locate producer rc ∈ {0,1}; non-regular knowledge entries reported as clock-less UNSUPPORTED; 18-case selftest. The counter repeats capture confinement (r3-notcapture), manifest ISO/2xx/bijection (`r2-manifest-malformed`), the 18-case selftest string and keeps the gate digest pin.

Same method and readings (P / M / M′ as defined above); selftest is staged in a pristine tree with the mutant at `corpus/recheck-replay.py` because the epoch-C selftest loads the local normaliser.

| id | mutation at `711e6393` | selftest | P counter | M counter (pin) | M′ (pin bypassed) | verdict |
|---|---|---|---|---|---|---|
| M1 | gate drop set-cookie alternatives from header regex (`HTTP/\d`, `< HTTP/\d` kept) | PASS 18 | 0 (DRIFT bad_capture=1) | FAIL (gate=0) | 9 `r3-headers:secret-scanning…` | killed (pin; counter r3) |
| M2 | gate drop HTTP alternatives (set-cookie kept) | PASS 18 | 0 | FAIL | 9 `r3-headers:…` | killed (pin; counter r3) |
| M4 | gate sha256 verify → `if False` | FAIL 1/18 | 0 | FAIL | FAIL `r3-digest…,selftest` | killed (pin, selftest, counter) |
| M5 | gate drop `..` path reject | PASS 18 | 0 | FAIL | 9 `r3-path:…` | killed (pin; counter r3) |
| M6 | gate symlink check → `if False` | FAIL 1/18 | 0 | FAIL | FAIL `r3-file…,selftest` | killed (pin, selftest, counter) |
| M7 | gate `UNSUPPORTED` tally → `MATCH` (url-less form) | FAIL 2/18 | 0 | FAIL | FAIL guard 0 | killed (pin, selftest) |
| M8 | gate `grep -e` → `grep -F -e` | FAIL 1/18 | 10 (tree BRE-true) | FAIL | FAIL gate=0 | killed (pin; selftest discriminates) |
| M9 | gate drop duplicate-URL check | PASS 18 | 0 (SETUP manifest-duplicate-url) | FAIL | 0 `r2-manifest-malformed` | killed (pin; duplicate rows also hit the new bijection: mutant gate itself SETUP `manifest-shared-body_path:S054+S054`; counter r2) |
| M12 | gate drop `confined()` over the four inputs | PASS 18 | 0 (SETUP `symlinked-input:corpus/SOURCES.md`) | FAIL | 0 (gate=1, every clock `r2-registry`: counter's own `read()` confinement) | killed (pin; counter). Selftest still does not cover input confinement |
| M13 | gate drop the symlinked-entry UNSUPPORTED row | PASS 18 | FAIL (present=9) | FAIL | FAIL (present=9; CLEAN needs clocks=10) | killed (counter present/guard). Selftest does not cover |
| M15 | gate drop `capture_confined` | PASS 18 | 0 (DRIFT body-not-capture) | FAIL | 9 `r3-notcapture:…` | killed (pin; counter; controls F13). Selftest's `not-capture-path` case passes because its fixture body does not exist at the non-capture path, so body-missing fires instead |
| M16 | gate drop the normaliser pin | PASS 18 (staging tree carries pinned normaliser) | FAIL (SETUP normalizer-digest) | FAIL | FAIL `r4-replay0:cdp-bridge…,selftest` | killed (pin; counter replays with the BASE normaliser, so a count-forging stub is caught) |
| M17 | gate drop manifest fetched/ISO + 2xx checks | PASS 18 | 0 (SETUP manifest-fetched:S054) | FAIL | 0 `r2-manifest-malformed` | killed (pin; counter). No selftest case |
| M18 | gate drop manifest body_path/sha bijection | PASS 18 | 0 (SETUP manifest-shared-body_path:S054+S999) | FAIL | 0 `r2-manifest-malformed` | killed (pin; counter; controls F15). No selftest case |
| M3 | counter drop registry status `mined` | n/a (pinned gate, PASS 18) | 9 `r2-registry:iso-11770-3-edition-status.md:60237.html` | `value=10 (bad=none)` | 9 | **SURVIVED** |
| M10 | counter drop 11-cell arity | n/a | 9 `r2-registry:…60237.html` | `value=10 (bad=none)` | 9 | **SURVIVED** |
| M11 | counter weaken MATCH regex to `^MATCH %s:\d+ id=%s` | n/a | FAIL (truncated stub gate fails pin+selftest) | FAIL | 0 (pristine regex) | **latent**: M11 + pin-bypass combined reads `10 present=10 replayed=10 gate=1 guard=1 (bad=none)`; unreachable while the pin holds, under-checked if it is relaxed |
| M14 | counter drop the pin condition (`if true`) | n/a | FAIL (full-MATCH stub gate is unpinned) | `value=10 (bad=none)` | 10 | **SURVIVED** |

Hostile-tree byte identity (epoch C; only the rows that differ from epoch B are listed): S054 set-cookie body 38540 B `6a3e9f9f…`; HTTP/ body 38536 B `71df0cc7…`; stale-digest body 38524 B `65e260c7…` (manifest left `7cf6efb5…`); S067 `65d51d51…`; S070 quote-broken body `c2bdd2ecf283…` (manifest `10290bd559b8…`, real locate count 0); manifest digests `9a291178…` (M5), `ba39ff2f…` (M9), `c11e46ae…` (M15), `1c42bb41…` (M17), `231cc880…` (M18); SOURCES `9a8fb793…` (M3 status `drafted`), `7862b032…` (M10 10 cells), symlinked (M12); knowledge entry symlink (M13). Stub gates: truncated-MATCH `2833f9802258bfe5a44ead96c780bd39a97bb23327cd644f6fce22d0424f8778` (M11), exact full-MATCH + `PASS (18 cases)` `3c2e4b40cddaf95bf4fae8c82c20b5a84b61675e6ba1a8b1c596425eb803173d` (M14).

### Epoch-C kill proposals

1. **M3** — control on REF with S101 status cell `drafted`, expect `9` (epoch-C reads 9, M3 reads 10).
2. **M10** — control with S101 row truncated to 10 cells, expect `9` (epoch-C reads 9, M10 reads 10).
3. **M14** — control with the tree gate replaced by the full-MATCH stub that also prints `RECHECK_REPLAY_SELFTEST: PASS (18 cases)` (`3c2e4b40…`), expectation **`FAIL`**; epoch-C reads FAIL (unpinned gate ⇒ SELF_OK=0), M14 reads `10`. Epoch-C's K1-F5/F5b/F5c do **not** cover this: F5's printer prints a 0-case selftest PASS, so F5 fails even with the pin dropped; only a stub that fabricates both the ten MATCH lines and the exact 18-case selftest string isolates the pin.
4. **M11 (latent)** — no control can reach it while the pin holds; if the pin is relaxed, add the truncated-MATCH stub `2833f980…` (combined M11+pin-bypass reads 10).
5. Not survivors, but controls F13/F15 cover M15/M18 only at the counter level; add for completeness: **F16** normaliser-stub tree (body quote removed, `c2bdd2ec…`) expect `FAIL` — no epoch-C control exercises `NORMALIZER_SHA256_PIN`; **F17** manifest `fetched` non-ISO expect `0` — no control exercises the ISO/2xx cells.

Epoch-C verdict summary: **3 survivors (M3, M10, M14) plus one latent (M11)** out of 18 mutants. The gate digest pin again kills every gate-byte mutation before any conjunct check, so a candidate's gate-side mutation surface is zero; the live counter surface is registry status, registry arity and the pin condition itself. The 18-case selftest now adds locate/pdf/trace-header cases, but still does not cover input confinement, capture confinement (its fixture is a nonexistent file), normaliser pinning, or the manifest ISO/2xx/bijection cells — each of those is caught only by the counter's duplicated conjuncts. Duplicate-URL rejection is now redundant with the bijection: dropping it alone makes the gate SETUP `manifest-shared-body_path`.

## Epoch D addendum — re-frozen instruments at `d36231871c864c930d3e7e33f9c5345b30ab4f98`

Epoch D supersedes epoch C (R56MutCounter F9 + R56ReviewCounter G1/G2). Everything in this section is anchored to that revision; it is the binding result.

| artifact | sha256 at `d3623187` |
|---|---|
| `corpus/recheck-replay.py` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` |
| `plans/round-56-c1.sh` | `82acbb2056aac6055a79f223a0e0abbb2cb24f11f01ca5ed12a230c8338bdc6a` |
| `plans/round-56-controls.sh` | `9445a1ec208f2b8dad55da2694f4b7ebd2554e3ecd4196f15c5d5da4958882ce` |
| `plans/round-56.md` | `4d837eb2d467064efedb9e25173c5bde82830e88c31754d7af1ac253c87b8b74` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` |
| harness | `harness-eD.py` `0ec8f3e8d426f946bda56262efae1d98e98bfb6158459105e4098398e163e8f8` |

Baseline at `d3623187`: gate `--selftest` rc 0 `PASS (20 cases)`; gate `--root` rc 0 `CLEAN (clocks=10 match=10 … 0)`; counter rc 0 `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`.

Changes since C: header refusal is case-insensitive (`(?im)` in gate and counter); the N boundary is `(?![0-9A-Za-z_.])`; selftest has 20 cases (adds single-signal `Set-Cookie:` and `Http/2` column-0 bodies — so M1/M2 are no longer selftest-blind); controls 21 MATCH. Same method and P/M/M′ readings.

| id | mutation at `d3623187` | selftest | P counter | M counter (pin) | M′ (pin bypassed) | verdict |
|---|---|---|---|---|---|---|
| M1 | gate drop set-cookie alternatives (case-insensitive regex) | **FAIL 1/20** (`header-case-cookie`) | 0 (DRIFT bad_capture=1) | FAIL (gate=0) | FAIL `r3-headers…,selftest` | killed (selftest now catches the single-signal case; pin; counter r3) |
| M2 | gate drop HTTP alternatives | **FAIL 1/20** (`header-case-status`) | 0 | FAIL | FAIL `r3-headers…,selftest` | killed (selftest; pin; counter r3) |
| M4 | gate sha256 verify → `if False` | FAIL 1/20 | 0 | FAIL | FAIL `r3-digest…,selftest` | killed (pin, selftest, counter) |
| M5 | gate drop `..` path reject | PASS 20 | 0 | FAIL | 9 `r3-path:…` | killed (pin; counter r3) |
| M6 | gate symlink check → `if False` | FAIL 1/20 | 0 | FAIL | FAIL `r3-file…,selftest` | killed (pin, selftest, counter) |
| M7 | gate `UNSUPPORTED` tally → `MATCH` (url-less form) | FAIL 2/20 | 0 | FAIL | FAIL guard 0 | killed (pin, selftest) |
| M8 | gate `grep -e` → `grep -F -e` | FAIL 1/20 | 10 (tree BRE-true) | FAIL | FAIL gate=0 | killed (selftest; pin) |
| M9 | gate drop duplicate-URL check | PASS 20 | 0 (SETUP manifest-duplicate-url) | FAIL | 0 `r2-manifest-malformed` | killed (pin; bijection: mutant gate itself SETUP `manifest-shared-body_path:S054+S054`; counter r2) |
| M12 | gate drop `confined()` over the four inputs | PASS 20 | 0 (SETUP `symlinked-input:corpus/SOURCES.md`) | FAIL | 0 (every clock `r2-registry`) | killed (pin; counter read() confinement). Selftest still does not cover input confinement |
| M13 | gate drop the symlinked-entry UNSUPPORTED row | PASS 20 | FAIL (present=9) | FAIL | FAIL (present=9) | killed (counter present/guard). Selftest does not cover |
| M15 | gate drop `capture_confined` | PASS 20 | 0 (DRIFT body-not-capture) | FAIL | 9 `r3-notcapture:…` | killed (pin; counter; controls F13). Selftest `not-capture-path` fixture body is absent at that path, so body-missing fires instead |
| M16 | gate drop the normaliser pin | PASS 20 | FAIL (SETUP normalizer-digest) | FAIL | FAIL `r4-replay0:cdp-bridge…,selftest` | killed (pin; counter replays with the BASE normaliser) |
| M17 | gate drop manifest fetched/ISO + 2xx checks | PASS 20 | 0 (SETUP manifest-fetched:S054) | FAIL | 0 `r2-manifest-malformed` | killed (pin; counter). No selftest case |
| M18 | gate drop manifest body_path/sha bijection | PASS 20 | 0 (SETUP manifest-shared-body_path:S054+S999) | FAIL | 0 `r2-manifest-malformed` | killed (pin; counter; controls F15). No selftest case |
| M3 | counter drop registry status `mined` | n/a | 9 `r2-registry:iso-11770-3-edition-status.md:60237.html` | `value=10 (bad=none)` | 9 | **SURVIVED** |
| M10 | counter drop 11-cell arity | n/a | 9 `r2-registry:…60237.html` | `value=10 (bad=none)` | 9 | **SURVIVED** |
| M11 | counter weaken MATCH regex to `^MATCH %s:\d+ id=%s` | n/a | FAIL (truncated stub gate unpinned) | FAIL | 0 (pristine regex) | **latent**: M11 + pin-bypass combined reads `10 … (bad=none)`; unreachable while the pin holds |
| M14 | counter drop the pin condition (`if true`) | n/a | FAIL (stub gate unpinned) | `value=10 (bad=none)` | 10 | **SURVIVED** |
| M19 | counter weaken N boundary to `(?![0-9A-Za-z])` | n/a | FAIL `present=9 replayed=9 gate=1 guard=0 (bad=absent:betterleaks…README.md)` | `value=10 (bad=none)` | FAIL | **SURVIVED** |

M19 hostile tree: the betterleaks `recheck:` line restated as `… \` -> 1.0 (ran 2026-10-23)` (command text unchanged). The gate reads `stated=1` and stays CLEAN; the pristine counter's `(?![0-9A-Za-z_.])` refuses the statement (absent), the mutant accepts it and replays 1 == 1, scoring 10. This is exactly the G2 class the epoch-D boundary was written for — it is closed in the instrument but not covered by any selftest case or control, so a future edit can reopen it silently.

### Epoch-D kill proposals

1. **M3** — control on REF with S101 status cell `drafted`, expect `9` (epoch-D counter 9, M3 10).
2. **M10** — control with S101 row truncated to 10 cells, expect `9` (epoch-D 9, M10 10).
3. **M14** — control with the tree gate replaced by the full-MATCH stub that also prints `RECHECK_REPLAY_SELFTEST: PASS (20 cases)` (`1bc2406c…`), expectation **`FAIL`**; epoch-D reads FAIL, M14 reads 10. K1-F5/F5b/F5c still do not cover it (F5's printer prints a 0-case selftest PASS).
4. **M19** — control with the betterleaks clock restated `-> 1.0` (command unchanged), expectation **`FAIL`** (pristine `present=9 … (bad=absent:…)`; M19 reads 10). Equivalently a 21st/22nd selftest case asserting `-> 1.0` is not a statement.
5. **M11 (latent)** — no control reaches it while the pin holds; with pin bypassed it reads 10 (truncated stub `df84639efc2e9113…`).
6. Not survivors but uncovered instrument cells: **F16** normaliser-stub tree (`c2bdd2ec…`) expect FAIL (no control exercises `NORMALIZER_SHA256_PIN`); **F17** manifest `fetched` non-ISO expect `0` (no control exercises the ISO/2xx cells).

Epoch-D verdict summary: **4 survivors (M3, M10, M14, M19) plus one latent (M11)** out of 19 mutants. The gate digest pin still kills every gate-byte mutation before any conjunct check, so a candidate's gate-side mutation surface is zero. Epoch D closed the case-insensitivity hole: M1 and M2 now fail the 20-case selftest through the new single-signal fixtures (the epoch-C double-signed-fixture weakness is gone). The remaining live counter surface is registry status, registry arity, the pin condition and now the N boundary; the N boundary and the manifest ISO/2xx/bijection cells still have no selftest or control coverage.

## Epoch E addendum — re-frozen instruments at `dd31b7867723f89fc8f83e88cc7d98e17de26cf2`

Epoch E is the current predeclaration (supersedes `d362318`). It adds counter tool guards, fixes the plan's selftest token (18→20) and adds control F11b (`-> 1.0` boundary); verdict semantics are unchanged by design. All evidence below is anchored to `dd31b786`.

| artifact | sha256 at `dd31b786` |
|---|---|
| `corpus/recheck-replay.py` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` (unchanged from D) |
| `plans/round-56-c1.sh` | `d468533fbf593c4b2a3a97dc513b9feb2cff765892c126c02d7c6ef40273a954` |
| `plans/round-56-controls.sh` | `01060f254b2ecfdb23f341a5cf0937aec32243230560809403ed67ea38b196e7` |
| `plans/round-56.md` | `212e2dd7ae71e3f056111e1a2c59d33151a3c51fee9f932bf2209ad2cb3d805d` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` (unchanged) |
| harness | `harness-eE.py` `56d10691aa5a4aa0288e6721ded743f514c9f91d85d76af572d4dacf66448e5d` |

Baseline at `dd31b786`: gate `--selftest` rc 0 `PASS (20 cases)`; gate `--root` rc 0 `CLEAN (clocks=10 match=10 … 0)`; counter rc 0 `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`.

The full 19-mutant sweep was re-run against the epoch-E counter (the gate bytes are identical, so every anchor is unchanged). **All 19 P/M/M′ readings are identical to the epoch-D table above**, with two verdict-relevant differences:

| changed item | epoch-D | epoch-E |
|---|---|---|
| M19 (counter N boundary weakened to `(?![0-9A-Za-z])`) | survivor: pristine `FAIL present=9 … (bad=absent:betterleaks…)`, mutant `10` | **killed by control F11b**: the new control builds the same `-> 1.0` restatement and expects `FAIL`; epoch-E reads FAIL, M19 reads 10 → control MISMATCH |
| counter tool guards (`sha256sum`/`cut`/`tail`/`timeout`/`git`/`tar` → SETUP) | n/a | no verdict change on this host (all tools present); untested by mutation here — a dropped guard is only observable on a host missing the tool, which is outside an offline committed-bytes probe |

Gate-side mutants M1–M18 remain killed exactly as in epoch D (all die at the pin; M1/M2/M4/M6/M7/M8 also fail the 20-case selftest; the M′ diagnostics hit `r3-headers`, `r3-path`, `r3-file`, `r3-notcapture`, `r2-registry`, `r2-manifest-malformed`, `r4-replay0`, present/guard as tabulated). M11 remains latent: M11 + pin-bypass combined reads `10 present=10 replayed=10 gate=1 guard=1 (bad=none)` at `dd31b786` (truncated stub `df84639efc2e9113…`).

### Epoch-E survivors and kills

- **SURVIVED: M3** (registry status `mined`), **M10** (11-cell arity), **M14** (gate pin condition). Proposed controls unchanged from epoch D: S101 status `drafted` expect `9`; S101 row truncated to 10 cells expect `9`; full-MATCH stub + `PASS (20 cases)` (`1bc2406c…`) expect `FAIL`.
- **M19** is now covered by F11b; no further control is needed, but a selftest case for `-> 1.0` would put the boundary in the gate's own detector rather than only in the shell control.
- **M11 latent**: no control reaches it while the pin holds; if the pin is relaxed, the truncated stub `df84639e…` kills it.
- Still uncovered by any selftest case: input confinement, symlinked-entry row, capture confinement (its fixture body is absent at the non-capture path), normaliser pin, manifest ISO/2xx and bijection. Counter r2/r3/r4 catch all of them today; the gate 20-case selftest does not.

Epoch-E verdict summary: **3 survivors (M3, M10, M14) plus one latent (M11)** out of 19 mutants; M19 moved from survivor to control-killed. The gate pin still makes the candidate's gate-side mutation surface zero, and the remaining live counter surface is registry status, registry arity and the pin condition.

## Epoch F addendum — re-frozen instruments at `9cbe9d5f803de2518d4c11c6bc6b9a585e5120ad`

Epoch F is the current predeclaration (supersedes `dd31b786`); tip `c90e6709` carries it. Two post-E findings are folded in: control F15 made non-vacuous (real shared-body witness) and manifest `fetched` now requires shape **and** `datetime.date.fromisoformat` (calendar validity) in both gate and counter, with new control F28. All results below are anchored to `9cbe9d5f`.

| artifact | sha256 at `9cbe9d5f` |
|---|---|
| `corpus/recheck-replay.py` | `b6959d6c7afb9380c043cbd40530e6a70ee8da2bf79f1ea9d0669706f50bb5a3` |
| `plans/round-56-c1.sh` | `f4c1de312e4a566dfde6c0699fb66a94c2e71e459eb97afbddb5c4073ffd2382` |
| `plans/round-56-controls.sh` | `644cde80a7f1a05f6f3543c2b52a37c7e1dc82f40942199f4cb2b728d01b53ce` |
| `plans/round-56.md` | `d0a8e402da2ac7a5c40eb3352a91918830253ba5502aae66442740d0c9dc025b` |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` (unchanged) |
| harness | `harness-eF.py` `2c4885c4100259fb95712da915e221dfb14d840c18076a2e9a6d43d5324684f7` |

Baseline at `9cbe9d5f`: gate `--selftest` rc 0 `PASS (20 cases)`; gate `--root` rc 0 `CLEAN (clocks=10 match=10 … 0)`; counter rc 0 `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`.

The 20-mutant sweep (the epoch-E 19 plus **M20**, calendar-validity drop) was run against the epoch-F counter. **All 19 carried-over readings are identical to epoch E**; the additions/changes are:

| id / item | mutation | selftest | P | M (pin) | M′ | verdict |
|---|---|---|---|---|---|---|
| **M20** | gate drops the `try: datetime.date.fromisoformat(rid["fetched"])` block (shape regex kept) | PASS 20 | 0 (SETUP manifest-fetched:S054) | FAIL (pin) | 0 `r2-manifest-malformed` | **killed** (pin; counter's own `fromisoformat`; control F28). Hostile tree `fetched=2026-13-40`; mutant gate itself CLEAN (`clocks=10 match=10`) |
| M17 | gate drops fetched shape + calendar block and http 2xx block | PASS 20 | 0 (SETUP manifest-fetched) | FAIL | 0 `r2-manifest-malformed` | killed (pin; counter); hostile `fetched=not-a-date` |
| M18 | (unchanged hostile tree) | PASS 20 | 0 (SETUP manifest-shared-body_path:S054+S999) | FAIL | 0 `r2-manifest-malformed` | killed (pin; counter; F15 is now a real witness after the epoch-F fix) |

The counter-side date check cannot be discriminated by a single-conjunct mutation: with an unmutated gate, any calendar-invalid manifest makes the gate SETUP, so `gate_ok=0` masks the counter's own check; only a joint gate+counter mutant would reach it, and such a tree is already killed by the gate digest pin.

### Epoch-F survivors and kills

- **SURVIVED: M3** (registry status), **M10** (11-cell arity), **M14** (gate pin condition) — same evidence as epochs D/E: pristine `9`/`9`/`FAIL`, mutants `10`/`10`/`10`, all `bad=none`.
- **M19** stays killed by control F11b (`-> 1.0`, expect FAIL); **M11** stays latent (pin masks it; M11 + pin-bypass combined reads `10 … (bad=none)` at `9cbe9d5f`).
- Kill proposals unchanged: S101 status `drafted` expect `9`; S101 row 10 cells expect `9`; full-MATCH stub + `PASS (20 cases)` (`1bc2406c…`) expect `FAIL`. M20 is already covered by F28.
- Gate 20-case selftest still has no case for calendar validity (M20 PASS), input confinement (M12), symlinked-entry row (M13), capture confinement (M15; fixture body absent at the non-capture path), normaliser pin (M16) or bijection/2xx (M17/M18); the counter's duplicated r2/r3/r4 checks catch each today.

Epoch-F verdict summary: **3 survivors (M3, M10, M14) plus one latent (M11)** out of 20 mutants; M20 is killed by pin + counter + F28. The gate pin remains the dominant detector on the gate side; the live counter surface is unchanged: registry status, registry arity and the pin condition.

## State and restoration

- Production bytes were not modified by this seat. In each epoch the tested blobs equal that revision's committed blobs (`git cat-file blob <rev>:<path>` hashes above: `42070de`, `5d9a157`, `711e6393`).
- Lane state: the working tree moved under this seat between epochs (the wave was landing the next predeclaration each time); at epoch-C probe time `HEAD=711e6393…`, epoch-D probe time `HEAD=d3623187…`, epoch-E probe time `HEAD=dd31b786…`, epoch-F probe time `HEAD=9cbe9d5f…`. None of the working-tree edits are this seat's work; results bind only to the six named revisions and their committed blobs.
- Scratch `R56MutGate/` (A), `-eB/`, `-eC/`, `-eD/`, `-eE/` and `-eF/` (F: clone at `9cbe9d5f`, 40 fixture trees, logs) were deleted after writing this report and `R56MutGate.d/`; receipts kept at `.ufo/waves/round-56/w1/R56MutGate.d/results.json`, `results-epoch{B,C,D,E,F}.json`, `harness*.py`, `commands.txt`.
- Epoch-F production bytes were not modified by this seat; the tested blobs are the `9cbe9d5f` blobs hashed in the epoch-F addendum. `HEAD` at epoch-F probe time was `9cbe9d5f`.
- Unrun: the live re-fetch leg (outside this seat; no network was used). Mutant verdicts are offline readings of committed bytes only.
