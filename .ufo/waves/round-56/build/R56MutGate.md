# Round 56 — mutation test of `corpus/recheck-replay.py` (seat R56MutGate)

Lane `kagi-shokunin`, round 56 attempt 1, one wave. Prompt BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`;
the lane working tree advanced to `42070de7770e1558adcf6aa7a7bc59309a9654d7` while this seat ran (other seats'
commits; this seat made no lane write except `build/R56MutGate.md` and `build/R56MutGate.d/`). Measurements
below are the working-tree bytes, hashed at read. Observed answering model (runtime header, not inferred from
the prompt): `amr/deepseek-v4.1-flash`.

Role: mutation tester. No production edit, no lane/fleet git mutation, no delegation; scratch copies only,
deleted before yield. Everything here is a probe plus a proposed selftest case set, not a patch.

## 1. Instruments measured

| file | sha256 | note |
|---|---|---|
| `corpus/recheck-replay.py` | `637c8184bd6ea8635fe582ea5641ea490033405658259c1a78c63899611aa585` | 15105 B, mtime 07:35:34; 13-case selftest |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | 10 data rows |
| `plans/round-56-c1.sh` | `d2bcb79094355ef6eb7bdad406ee1ccbeaf386e920950168fc2fa2c74aeb9f44` | `GATE_SHA256_PIN=637c8184…`; selftest literal `PASS (13 cases)` |
| `plans/round-56-controls.sh` | `bb48db9605ede5770582178d6962a5a75acfb9d1086e1f0d3098954685958b3e` | |
| `plans/round-56.md` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` | |

Instrument drift seen during the seat (read-only observation, receipt `.d/instrument-drift.txt`): gate
`b7782f35…` at 07:26 → `637c8184…` at 07:35; counter `096251c9…` at 07:26 → `0153f876…` at 07:37 →
`d2bcb790…` at 07:40. At 07:38 the counter still carried the literal placeholder
`GATE_SHA256_PIN=__GATE_SHA256__`, so `HAVE_GATE` stayed 0 and a clean tree read
`C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate:…)` — reported to `agent://KagiR56`.
The pin is now filled and the same tree reads `value=10`; all results below are against the filled
`d2bcb790…` counter. **Any further gate edit invalidates both `GATE_SHA256_PIN` and the literal
`PASS (13 cases)`** (see §6.2).

Baseline (validity of the detectors, QM19):

```
$ python3 -I -B corpus/recheck-replay.py --selftest            → rc 0  RECHECK_REPLAY_SELFTEST: PASS (13 cases)
$ python3 -I -B corpus/recheck-replay.py --root <tree>         → rc 0  RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)
$ bash plans/round-56-c1.sh --tree <tree>                     → rc 0  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
```

## 2. Method

- `<tree>` = `corpus/` + `plans/` + `.ufo/waves/round-45/controls/capture-r45`, `round-55/capture`,
  `round-56/capture` copied from the lane into scratch (`rsync -a`), so the replay population is the real
  lane population and no production byte is touched.
- Each mutant is **one conjunct**: a literal replace asserted to match exactly once in the gate source
  (`src.count(old) == 1`); the mutated source is written to a fresh copy of `<tree>`.
- Detector A: the gate's own `--selftest` (rc + last line).
  Detector B: `--root <mutated tree>` (rc + last line + verdict rows).
  Detector C: the C1 counter on the mutated tree, in a **scratch-derived copy** whose only edits are
  `REPO=` bound to the lane (read-only, for `git show BASE:corpus/rendered-text-v1.py`) and
  `GATE_SHA256_PIN=` filled with **that mutant's own digest**. Without this, the counter's r5 byte pin
  short-circuits every mutant identically (`pinkill` rows in `.d/mutation-sweep.json`: G02/G04/G15 all read
  `value=0 … bad=r5-gate:` under the pristine pin), which measures the pin, not the gate. The derived counter
  was hashed per mutant (recorded in the JSON); the lane counter itself was never edited.
- Fixtures: minimal lane trees in the shape of the gate's own selftest `tree()` helper
  (`corpus/knowledge/e.md`, an 11-cell `corpus/SOURCES.md` row, `corpus/recheck-captures.tsv`, `.ufo/b.body`,
  plus `corpus/rendered-text-v1.py`), each built to isolate one gate conjunct. Two fixtures inject a tool
  failure with a `PATH` shim (`grep` → exit 2; `pdftotext` → emits the needle only when `-layout` is passed);
  no other stub is used. Runs use a neutral cwd unless the case is about cwd.
- Restoration: each run re-hashes the pristine gate; the harness asserts it unchanged at exit
  (`pristine gate sha unchanged: 637c8184…`). Mutants live only in their own tree, so restoration is the
  absence of any write, not a byte restore.

## 3. Mutant inventory — 23 mutants, verdicts

Killed = detected (nonzero/FAIL/DRIFT); survived = the detector reports the mutated gate as clean.

| mutant | conjunct mutated | --selftest | gate --root (real corpus) | counter, pin=mutant | sha256(mutated gate) |
|---|---|---|---|---|---|
| G01-rc-accept-only-1 | grep rc check accepts only 1: a real match (rc 0) becomes TOOL | **FAIL 5/13** | DRIFT | **FAIL** | `db22810fcd93582806175a7035e1e0c5251ff1a3095823de66d3059ab65665c2` |
| G01b-rc-accept-only-0 | grep rc check accepts only 0: a legitimate zero count (rc 1) becomes TOOL | PASS 13/13 | CLEAN 10/10 | 10 | `60af4ee77412840914db578000ea98bfa6e6b88815bd861472c8994463c02568` |
| G02-rc-fail-open | grep rc error (≥2) reads as count 0 | PASS 13/13 | CLEAN 10/10 | 10 | `fe2ad9796f7500571f983ce79b9b8388c800a082c74e4283cc933669db52e3e6` |
| G03-sha-drop | capture sha256 check removed | **FAIL 1/13** | CLEAN 10/10 | **FAIL** | `b333d4209a6ad7255a4cbf6390b21f6b8cfdb560c88b6b43f4f5a57eb14ac367` |
| G04-bytes-drop | capture byte-count check removed | PASS 13/13 | CLEAN 10/10 | 10 | `7ff65c1bfa61f84b3bc805c9111c913a9c04cbf4c07b701ee47195e7eae7f42f` |
| G05-registry-url-skip | registry url membership check removed | **FAIL 1/13** | CLEAN 10/10 | **FAIL** | `c13ef67c7f406766bfdf9cbd38f56f02f766f8c496dbbe12030bd79b4682bcdd` |
| G06-registry-prefix | registry url matched as a substring, not a whitespace-delimited token | PASS 13/13 | CLEAN 10/10 | 10 | `4571755200ecd59aa76bb8ecaea8ef57584020c7529d535ea887f6d9e35a4c69` |
| G07-symlink-body-skip | symlinked capture component refusal removed | **FAIL 1/13** | CLEAN 10/10 | **FAIL** | `e65d0acb1bae88b6c334c8d7ec733230893081fccad3a268d06e6877f4c58063` |
| G08-cookie-case | `set-cookie` refusal made case-sensitive | PASS 13/13 | CLEAN 10/10 | 10 | `5e66f5003a2c85748f4bb077c98944b2d44977d653c75a44bf9d0d1c5e67e39e` |
| G09-first-clock-only | only the first clock per `recheck:` line replayed | **FAIL 1/13** | CLEAN 10/10 | **FAIL** (replayed=0) | `060bad74c307fafe07e0a2fe3eaa2035a8316e2173266c92891ab1f5dba93464` |
| G10-manifest-symlink | symlinked manifest accepted | PASS 13/13 | CLEAN 10/10 | 10 | `b65021927a41522c32407b03062db3cfbe3189c66bb2b86f215b21993997c76d` |
| G11-manifest-dedup-drop | duplicate manifest url no longer refused | PASS 13/13 | CLEAN 10/10 | 10 | `b03d9a8f90747eef22bea35594925d7b6aaab376dfe1274152461cc53a9d0aaf` |
| G12-verdict-match | MISMATCH verdict printed as MATCH | **FAIL 2/13** | CLEAN 10/10 | **FAIL** | `7be90e71b27b97bc502bddc165f370e4a2b427f1a3be06cb2f86d054111cfc80` |
| G13-clean-always | CLEAN summary printed regardless of tallies | **FAIL 10/13** | CLEAN 10/10 | **FAIL** | `2fe1050f197ccbc6cfa98918b39592541b6023663a280b3c590bfb4ce21401de` |
| G14-pdf-rc-fail-open | pdftotext error reads as count 0 | PASS 13/13 | CLEAN 10/10 | 10 | `4eafe36f4aaed05e66191d8533809b6499f17b84a1ee6998e10d02d64ea12f36` |
| G15-pdf-no-layout | pdftotext runs without `-layout` | PASS 13/13 | CLEAN 10/10 | 10 | `f01bcccbaba47ef8e3de8cd394cfe224e63f9aa2c56132e68616f4c19eedc0b9` |
| G16-locate-fail-open | missing locate output reads as count 0 | PASS 13/13 | CLEAN 10/10 | 10 | `3836ee80bee6075d96578c804703583e59c265bd36668dae2a027284018e5f94` |
| G17-locate-relative | locate runs the tree normaliser by cwd-relative path | PASS 13/13 | DRIFT | **0** | `263fc58f13e8d6ac627b7dcb50f97c292b607e3c86033c3c55a05458c5340ff1` |
| G18-unsupported-guess | unknown filter form guessed as grep on the last token | **FAIL 1/13** | CLEAN 10/10 | **FAIL** | `d9cb917e3a43bc43824f555f7bdfa4d90d326e1d678624e2b5f9d788d794ac56` |
| G19-http1-only | status-line refusal narrowed to `HTTP/1.x` | PASS 13/13 | CLEAN 10/10 | 10 | `5aaa0092066965157025ba24b9542ec9626379a326331c2d5be6c3df4211ea16` |
| G20-manifest-header | manifest header equality check removed | PASS 13/13 | CLEAN 10/10 | 10 | `b8a151ce00ce355188f3b2f73c6d000d62e48bf6b7b8d4426c52f1102d2ec30b` |
| G21-symlink-entry-skip | symlinked knowledge entry silently skipped instead of reported | PASS 13/13 | CLEAN 10/10 | 10 | `9fae63e9cf7ff54a458bd75a122421af5a8ca400117dbe9e776c5be45a8955ca` |
| G22-empty-population-clean | empty stated-clock population reads CLEAN instead of SETUP | PASS 13/13 | CLEAN 10/10 | 10 | `53a23686f805dca6ce7dce268d1ea087602389a37bcfc30ea9d8a8c0bf7628c4` |

Totals: killed 9/23 (selftest 8, gate-run 2, counter 9 — G01/G03/G05/G07/G09/G12/G13/G17/G18 overlap);
**14/23 survive all three detectors on the real corpus**. The selftest is the only detector that kills a
*refusal removal* (G03, G05, G07), because the real corpus never violates those refusals.

## 4. Survivors and the control that kills each

Each fixture was run twice: pristine gate (unchanged control) and the mutant. `DET` = the mutant's verdict row.

| survivor | killing fixture | pristine gate | mutated gate | DET (mutant) |
|---|---|---|---|---|
| G01b-rc-accept-only-0 | `F01-zero-count` (clock `-> 0`, pattern absent) | rc 0 CLEAN 1/1 | rc 1 DRIFT | `TOOL corpus/knowledge/e.md:2 id=S001 reason=grep-rc1` |
| G02-rc-fail-open | `F02-grep-rc2` (PATH `grep` exits 2) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `TOOL … reason=grep-rc2` (pristine only) |
| G04-bytes-drop | `F04-bytes-mismatch` (row bytes +1, sha correct) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=bytes:.ufo/b.body` |
| G06-registry-prefix | `F06-registry-prefix` (registry holds `https://example.test/abc`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=url-not-in-row:S001` |
| G08-cookie-case | `F08-cookie-capital` (body starts `Set-Cookie: x=1`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=header-bytes:.ufo/b.body` |
| G10-manifest-symlink | `F13-manifest-symlink` (`recheck-captures.tsv` → `m.tsv`) | rc 2 SETUP `manifest-missing` | rc 0 **CLEAN 1/1** | SETUP (pristine only) |
| G11-manifest-dedup-drop | `F14-manifest-duplicate` (two rows, one url) | rc 2 SETUP `manifest-duplicate-url:https://example.test/a` | rc 0 **CLEAN 1/1** | SETUP (pristine only) |
| G14-pdf-rc-fail-open | `F11-pdf-not-a-pdf` (pdf form, body is text, `-> 0`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `TOOL … reason=pdftotext-rc1` |
| G15-pdf-no-layout | `F23-pdf-layout-argv` (shim prints needle only with `-layout`) | rc 0 CLEAN 1/1 | rc 1 DRIFT | `MISMATCH … form=pdf stated=1 replayed=0` |
| G16-locate-fail-open | `F12-locate-binary` (body `/bin/ls`, locate form, `-> 0`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `TOOL … reason=locate-output` |
| G19-http1-only | `F09-http2-line` (body starts `HTTP/2 200`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=header-bytes:.ufo/b.body` |
| G20-manifest-header | not killable on this corpus: header is already exact; a wrong header makes the gate and the counter disagree, and no fixture changes the *gate's* answer (the row check is positional after the header). Survives as a dead conjunct on any well-formed manifest — see §7. | — | — | — |
| G21-symlink-entry-skip | `F20-entry-symlink` (`corpus/knowledge/z.md` symlinked, its clock states `-> 9`) | rc 1 DRIFT `UNSUPPORTED corpus/knowledge/z.md:0 reason=symlinked-entry` | rc 0 **CLEAN 1/1** | (pristine only) |
| G22-empty-population-clean | `F24-empty-population` (one entry, no clock) | rc 2 SETUP `no-stated-clocks` | rc 0 **CLEAN clocks=0** | SETUP (pristine only) |

## 5. Answers to the seven probes named in the tasking

1. **rc check** — the *narrowing* mutants (G01: accept only rc 1; G01b: accept only rc 0) and the
   *fail-open* mutant (G02: rc ≥ 2 → count 0). G01 is killed three ways (selftest 5/13 because every other
   case then reports TOOL; gate DRIFT; counter FAIL). G01b and G02 **survive all three**: no POP clock is a
   zero count, and the selftest has no zero-count and no grep-error case. F01 kills G01b; F02 kills G02.
   The residual risk is real: a `-> 0` clock plus a grep that errors (permission, ENOMEM) currently reads
   `MATCH` under G02.
2. **capture digest** — `sha256` removal is killed (selftest `sha-mismatch` 1/13 and the counter's own r3,
   `bad=r3-digest`); `bytes` removal **survives all three** and is killed only by F04 (a row whose `bytes`
   column is wrong while `sha256` is right). The bytes conjunct is therefore not redundant, but it is also
   the only one of the two that the shipped selftest cannot reach.
3. **registry url** — membership-check removal is killed (selftest `url-not-in-row`); *token-boundary*
   weakening (G06, substring instead of whitespace-delimited) **survives all three** and is killed by F06.
   Neither gate nor counter checks fence context or cell count/`status mined` — the counter's r2 does, the
   gate does not (F17: a row inside ``` fences reads gate `CLEAN` while r2 refuses it).
4. **symlink** — capture-component refusal is killed (selftest `symlink-component`, counter r3);
   **manifest** symlink (G10) and the **symlinked knowledge entry** (G21) survive all three and are killed
   by F13/F20. G21 matters most: `clocks()` gained the `<symlinked-entry>` → `UNSUPPORTED` branch in
   `637c8184…` and **no selftest case exercises it**; deleting the branch restores a silent skip and the
   gate reads `CLEAN clocks=1` for a tree whose second entry states a false clock.
5. **multiple clocks** — first-clock-per-line (G09) is killed by the selftest (`second-clock-mismatch`) and
   by the counter (r5 needs a MATCH line per POP clock; it reads `replayed=0`). Not covered: **two
   column-1 `recheck:` lines in one entry** (F21 reads gate `CLEAN clocks=2` while C1's r1 PRESENT requires
   exactly one line and refuses), a duplicate clock on one line counting twice, and any clock that is
   *removed* (F18: gate `CLEAN clocks=1`) or **indented** (F19: gate `CLEAN clocks=1`, and the indented
   clock is invisible). The gate has no structure verdict for these; C1's r1/guard is the only barrier.
6. **PDF / locate forms** — the selftest has **zero** pdf and locate cases, so all four mutants of those
   paths survive selftest. `-layout` removal survives the real corpus (S078 still counts 1) and the counter
   (r4 also uses `-layout`, so it agrees); it is killed only by the argv shim fixture F23. pdf rc fail-open
   (G14) and locate fail-open (G16) survive all three and are killed by F11/F12. The cwd-relative normaliser
   path (G17) is killed by the counter only because the counter runs the gate with `cwd=$SCR`, which has no
   `corpus/`: `DRIFT (clocks=10 match=9 tool=1)`. Measured both ways on the same tree —
   `cd <lane>; gate17 --root <lane>` reads `CLEAN (clocks=10 match=10 …)`, `cd <empty>; gate17 --root <lane>`
   reads `DRIFT … tool=1`. So the one mutant that targets the gate's *absolute-path* contract is invisible
   under the natural invocation (from the lane root) and is only caught by luck of the counter's cwd — the
   QM4 class (a case proves only the isolation it actually exercises): a locate case must run from a neutral
   cwd and assert the count, not merely `MATCH`.
7. **PRESENT-like omissions** — the gate's own population is "every backticked clock on a column-1
   `recheck:` line". It cannot report a clock that no longer exists (F18), a clock on an indented line
   (F19), a second `recheck:` line (F21), or an empty population (F24 → SETUP today, `CLEAN clocks=0` under
   G22). Only the symlinked-entry case is reported (§5.4). All four gaps are already carried by C1's
   r1/guard, so the *claim* is not exposed; the *gate's CLEAN* is not a lane-wide statement on its own and
   should not be read as one.

## 6. Proposed selftest cases (not applied)

### 6.1 Cases

Add to `selftest()` after the existing `second-clock-mismatch` case; each uses the existing `tree()`,
`good_row()` and `cmd` helpers. Names, fixtures and expected `(rc, token)`. These close every survivor
that a fixture kills, except G20 (see §7).

```python
    # --- proposed round-56 mutation cases (R56MutGate) ---
    zero = "`curl -fsSL 'https://example.test/a' | grep -c 'absent'` -> 0"
    cases.append(("zero-count-is-match", zero, [good_row()], {}, 0, "MATCH"))
    cases.append(("zero-count-bad-form", zero, [good_row()],
                  {"shim": "grep-rc2"}, 1, "TOOL"))
    badb = good_row(); badb[5] = str(len(body_txt) + 1)          # bytes column wrong, sha right
    cases.append(("bytes-column-mismatch", cmd, [badb], {}, 1, "BAD-CAPTURE"))
    cases.append(("registry-url-prefix", cmd, [good_row()],
                  {"row_url": "https://example.test/abc"}, 1, "BAD-CAPTURE"))
    cookie = b"Set-Cookie: x=1\r\n\r\nThe needle line\nthe needle again\n"
    cases.append(("cookie-case-insensitive", cmd, [good_row(body=cookie)], {"body": cookie}, 1, "BAD-CAPTURE"))
    h2 = b"HTTP/2 200\r\nThe needle line\nthe needle again\r\n"
    cases.append(("http2-status-line", cmd, [good_row(body=h2)], {"body": h2}, 1, "BAD-CAPTURE"))
    pdf = "`curl -fsSL 'https://example.test/a' | pdftotext -layout - - | grep -c 'needle'` -> 2"
    cases.append(("pdf-form-matches", pdf, [good_row()], {}, 0, "MATCH"))
    cases.append(("pdf-form-non-pdf-body", pdf, [good_row()], {}, 1, "TOOL"))
    loc = ("`curl -fsSL 'https://example.test/a' | python3 corpus/rendered-text-v1.py "
           "locate /dev/stdin 'needle'` -> 3")
    cases.append(("locate-form-count", loc, [good_row()], {}, 1, "MISMATCH"))  # measured: count=2, stated 3
    cases.append(("locate-form-output-missing", loc, [good_row(body=b"\xff\xfe\x00")], {"body": b"\xff\xfe\x00"}, 1, "TOOL"))
```

Structural cases need small extra harness code (each also a case, not a rewrite):

```python
    # a second column-1 `recheck:` line in one entry: gate must not read CLEAN as if one clock
    cases.append(("two-recheck-lines", cmd + "\nrecheck: 90d — " + cmd.split(" — ", 1)[1], [good_row()], {}, 1, "STRUCTURE"))
    # an indented clock is outside the population and must be reported, not ignored
    cases.append(("indented-clock", "source: S001\n  recheck: 90d — " + cmd.split(" — ", 1)[1], [good_row()], {}, 1, "STRUCTURE"))
    # a symlinked knowledge entry must be UNSUPPORTED (the 637c8184 branch, currently untested)
    cases.append(("symlinked-entry", "<symlink e.md>", [good_row()], {}, 1, "symlinked-entry"))
    # no stated clock at all is SETUP(2), never a CLEAN(0/0)
    cases.append(("empty-population", "", [good_row()], {}, 2, "SETUP"))
```

Plus two harness-level cases that need no gate change but do need a `PATH` shim and an argv-recording shim:
`grep-error-is-tool` (G02) and `pdftotext-argv-has-layout` (G15), both already exercised here by F02 and F23.

Note the last four cases are **not drop-in**: on today's bytes the two-recheck-lines and indented-clock trees
read `CLEAN clocks=2` / `CLEAN clocks=1` (F21/F19, measured), so asserting them requires a gate behaviour
change and belongs to L1's route, not to a case-list edit. Their tokens (`STRUCTURE`, `symlinked-entry`) are
likewise new vocabulary — the gate today prints `UNSUPPORTED … reason=symlinked-entry` and has no structure
verdict. If the frozen predicate admits no new verdict word, assert the existing `UNSUPPORTED` token instead;
the point of each case is the rc and that the clock is not silently dropped.

### 6.2 Freeze coupling (measured, must move together)

The counter pins the gate in **two** literals: `GATE_SHA256_PIN=<64 hex>` and
`RECHECK_REPLAY_SELFTEST: PASS (13 cases)`. A gate that adds one benign selftest case without touching the
counter reads:

```
gate14 (13+1 cases, sha256 e82522c0792780033bfa5d6efb3303d8d76fc051026b34b465abb056251adbc0)
  --selftest → rc 0 RECHECK_REPLAY_SELFTEST: PASS (14 cases)
  --root     → rc 0 RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)
counter with literal "PASS (13 cases)", pin=gate14
  → C1_REPLAY: value=FAIL present=10 replayed=10 gate=1 guard=0 (bad=selftest)   rc 0
counter with literal "PASS (14 cases)", pin=gate14
  → C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)          rc 0
```

So any accepted selftest-case proposal is a three-file freeze edit (gate, both counter literals), and the
pin must be recomputed *after* the gate's final bytes. Nothing in the counter derives the case count from
the gate's output; that is by design (QM43-style anti-constant), but it means a partial edit reads
`value=FAIL` with `guard=0`, not a loud setup error.

## 7. Residual findings and limits of this probe

- **G20 (manifest header)** cannot be killed by any fixture: once the header check is removed, the row
  `zip(HEADER, cols)` still fails closed on a genuinely wrong header only because the positional mapping
  breaks a later conjunct. It is a *dead* conjunct on well-formed manifests (QM9: a mutant that cannot fire
  is a setup error, not a pass) — propose the case `manifest-header-swap` that permutes two header columns
  and expects `SETUP`/`BAD-CAPTURE`, which does fire.
- **Gate vs frozen predicate**: the gate does not implement r1 (single line / PRESENT), r2's fence, cell
  count and `status mined`, or the "exactly one manifest row" rule at gate level (it refuses duplicates but
  through `SETUP`, not per-row). Those live only in the counter, so the gate's `CLEAN` is narrower than C1's
  `REPLAYED`. Not a defect of the claim; a defect if the gate is cited as the lane-wide freshness check.
- **Not probed**: capture provenance/hand-written bodies (named ceiling in the plan), `--max-time`/`-A`
  token acceptance semantics (only `extra-curl-flag` covers the negative), UTF-8/BOM edges of
  `rendered-text-v1.py`, symlinked *parent directory* of the knowledge dir, and the gate's behaviour on a
  body that is a FIFO/device (path component checks look only for symlinks). Timeouts were never triggered;
  no case here claims they are handled.
- **Counter-side mutation** was out of seat scope beyond the pin/case-count probe in §6.2.

## 8. Restoration and cleanup evidence

- Pristine gate re-hashed at the end of every run by the harness assertion; printed
  `pristine gate sha unchanged: 637c8184bd6ea8635fe582ea5641ea490033405658259c1a78c63899611aa585`
  (equals §1). Each mutant lived in its own scratch tree created by `cp -a` from the pristine copy.
- Lane files: this seat wrote only `.ufo/waves/round-56/build/R56MutGate.md` and
  `.ufo/waves/round-56/build/R56MutGate.d/*`. `corpus/recheck-replay.py`, `corpus/recheck-captures.tsv`,
  `plans/round-56-c1.sh`, `plans/round-56-controls.sh`, `plans/round-56.md` were read only; their hashes
  before and after this seat are in `.d/hashes.txt` and `.d/instrument-drift.txt` (the two later counter
  hashes are other seats' edits, not mine).
- Scratch `/fast/scratch/hyaku/kagi-r56/R56MutGate/` deleted before yield (it was additionally wiped twice
  mid-run by a process outside this seat; receipts were written to the lane dir for that reason).

## 9. Receipts

- `.ufo/waves/round-56/build/R56MutGate.d/mutation-sweep.json` — baseline, all 23 mutants (exact old/new
  text, mutated sha256, all three detector outputs, derived-counter sha256), the three `pinkill` rows, all
  24 fixtures with both runs.
- `.ufo/waves/round-56/build/R56MutGate.d/hashes.txt` — instrument snapshot at measurement.
- `.ufo/waves/round-56/build/R56MutGate.d/instrument-drift.txt` — hash timeline and lane HEAD.
- `.ufo/waves/round-56/build/R56MutGate.d/counter-current-tree.txt` — current lane counter on a real-corpus
  tree: `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`, rc 0, plus
  `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`.
