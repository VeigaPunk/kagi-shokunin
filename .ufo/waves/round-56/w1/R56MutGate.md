# R56MutGate — mutation probe of the frozen replay gate and C1 counter

Seat: R56MutGate (mutation-tester). Lane `kagi-shokunin`, branch `master`.
Tested revision: `42070de7770e1558adcf6aa7a7bc59309a9654d7` (predeclaration), BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`.
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

## State and restoration

- Production bytes were not modified by this seat. The tested blobs equal `git cat-file HEAD:` at `42070de` (hashes above).
- During the probe the lane working tree moved under this seat. At report-write time `git status --porcelain -- corpus plans` shows `M corpus/SOURCES.md` (sha256 `299903cfb8d38760440d16ae3a5119154f14ec128619710101ca8c59af3a4edb`), `M corpus/recheck-replay.py` (`637c8184bd6ea8635fe582ea5641ea490033405658259c1a78c63899611aa585`), `M plans/round-56-c1.sh` (`d2bcb79094355ef6eb7bdad406ee1ccbeaf386e920950168fc2fa2c74aeb9f44`), `M plans/round-56-controls.sh` (`bb48db9605ede5770582178d6962a5a75acfb9d1086e1f0d3098954685958b3e`) and `M plans/round-56.md` (`033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679`); `corpus/recheck-captures.tsv` still `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`. That drift is not this seat's; all results here are against the frozen `42070de` blobs named in the assignment. The drift itself matters to the C1 kill rule (frozen plan/counter/controls changed after predeclaration) and is outside this probe's contract.
- Scratch `/fast/scratch/hyaku/kagi-r56/R56MutGate/` (clone, 22 fixture trees, logs) deleted after writing this report and `R56MutGate.d/`; receipts kept at `.ufo/waves/round-56/w1/R56MutGate.d/results.json` and `harness.py`.
- Unrun: the live re-fetch leg (outside this seat; no network was used). Mutant verdicts are offline readings of committed bytes only.
