# Round 56 — mutation test of `corpus/recheck-replay.py` (seat R56MutGate)

Lane `kagi-shokunin`, round 56 attempt 1, one wave. Prompt BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`;
the lane tree advanced to `42070de7770e1558adcf6aa7a7bc59309a9654d7` while this seat ran (other seats' work;
this seat's only lane writes are `build/R56MutGate.md` and `build/R56MutGate.d/`). Observed answering model
(runtime header, not inferred from the prompt): `amr/deepseek-v4.1-flash`.

Role: mutation tester. No production edit, no lane/fleet git mutation, no delegation, scratch copies only.
Everything below is a probe plus a proposed selftest case set, not a patch.

## 1. Instruments measured (and their drift)

Final snapshot — every result in §3–§6 is keyed to these bytes:

| file | sha256 | note |
|---|---|---|
| `corpus/recheck-replay.py` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | 356 lines; `confined()` preflight added; 13-case selftest |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | 10 data rows |
| `plans/round-56-c1.sh` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `GATE_SHA256_PIN=2e9dfde3…`; literal `PASS (13 cases)` |
| `plans/round-56-controls.sh` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` | |
| `plans/round-56.md` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` | |

Drift seen during the seat (receipt `.d/instrument-drift.txt`): gate `b7782f35…` (07:26) → `637c8184…`
(07:35) → `2e9dfde3…`; counter `096251c9…` (07:26) → `0153f876…` (07:37) → `d2bcb790…` (07:40) → `6b132ea1…`.
An earlier sweep of the same 23-conjunct set ran against gate `637c8184…` with counter `d2bcb790…`; its
verdicts are identical for every conjunct that survived that revision (console transcript
`.d/run3-637c8184-summary.txt`).
At 07:38 the counter still carried the literal placeholder `GATE_SHA256_PIN=__GATE_SHA256__`, so `HAVE_GATE`
stayed 0 and a clean tree read `C1_REPLAY: value=0 … gate=0 guard=1 (bad=r5-gate:…)` — reported to
`agent://KagiR56`; it is now filled and reads `value=10`.

**Epoch-B anchor.** Every blob measured here is byte-identical to epoch-B predeclaration commit
`5d9a1571911ec38a456a40b443e19640abb9a88b`: `git show 5d9a157:<path> | sha256sum` gives gate `2e9dfde3…`,
manifest `df46be5c…`, counter `6b132ea1…`, controls `63cf8061…`, plan `033f2104…` (the five §1 rows). The
sweep was run against the working tree at 07:43 −03:00 and the lane blobs still hash identically at
07:46 −03:00, so no re-run is needed to bind these results to epoch B.

Baseline (detector validity, QM19):

```
$ python3 -I -B corpus/recheck-replay.py --selftest   → rc 0  RECHECK_REPLAY_SELFTEST: PASS (13 cases)
$ python3 -I -B corpus/recheck-replay.py --root <tree> → rc 0  RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)
$ bash plans/round-56-c1.sh --tree <tree>              → rc 0  C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
```

## 2. Method

- `<tree>` = the lane's `corpus/` + `plans/` + the three capture dirs (`round-45/controls/capture-r45`,
  `round-55/capture`, `round-56/capture`) copied into scratch, so the replay population and the manifest are
  the real ones and no production byte is touched.
- Each mutant is **one conjunct**: a literal replace asserted to occur exactly once in the gate source
  (`src.count(old) == 1`, else the mutant is reported as a setup error, never as a pass — QM9).
- Detector A: the gate's own `--selftest` (rc + last line). Detector B: `--root <mutated tree>` (rc, last
  line, verdict rows). Detector C: the C1 counter on the mutated tree, run from a **scratch-derived copy**
  whose only edits are `REPO=` bound to the lane (read-only, for `git show BASE:corpus/rendered-text-v1.py`)
  and `GATE_SHA256_PIN=` filled with **that mutant's own digest**. Under the pristine pin every mutant dies
  identically at r5 (`pinkill` rows: `value=0 … bad=r5-gate:`), which measures the pin, not the gate; the
  pin-matched run is the informative one. The lane counter was never edited; each derived copy is hashed in
  the receipt.
- Fixtures: minimal lane trees in the shape of the gate's own selftest `tree()` helper (`corpus/knowledge/e.md`,
  an 11-cell `corpus/SOURCES.md` row, `corpus/recheck-captures.tsv`, `.ufo/b.body`, `corpus/rendered-text-v1.py`),
  each isolating one gate conjunct. Two fixtures inject tool failure with a `PATH` shim (`grep` → exit 2;
  `pdftotext` → prints the needle only when `-layout` is passed); there is no other stub. Runs use a neutral
  cwd unless the case is about cwd.
- Restoration: the harness re-hashes the pristine gate at exit and asserts it unchanged
  (`pristine gate sha unchanged: 2e9dfde3…`). Mutants are separate `cp -a` trees, so "restore" is the absence
  of any write, and the receipt records before/after digests of both the pristine gate and the lane files.

## 3. Mutant inventory — 24 mutants

Killed = at least one detector reports the mutated gate as not-clean. Selftest column is cases failed, not
lines emitted.

| mutant | conjunct mutated | --selftest | gate --root (real corpus) | counter, pin=mutant | sha256(mutated gate) |
|---|---|---|---|---|---|
| G01-rc-accept-only-1 | grep rc: accept only 1 (real match rc 0 becomes TOOL) | **FAIL** 5 of 13 cases | DRIFT | **FAIL** | `8dcb998c2f5fdb0a51f190dc89c65a3b1505327547202963e69820d67633e264` |
| G01b-rc-accept-only-0 | grep rc: accept only 0 (a legitimate zero count rc 1 becomes TOOL) | PASS 13/13 | CLEAN 10/10 | 10 | `8ac556c8baea9477d6c833dca4c505f6a1700c8510163ce75168eaf1e6f677b5` |
| G02-rc-fail-open | grep rc error (>=2) reads as count 0 | PASS 13/13 | CLEAN 10/10 | 10 | `81255b0f432c260a7de502163060e24b99a82abe0a02866ae9d3f65b3fa8cad5` |
| G03-sha-drop | capture sha256 check removed | **FAIL** 1 of 13 cases | CLEAN 10/10 | **FAIL** | `c8470f9c48ffa505a516358467aab828ac9570c074faee8fb8992f822101f3a8` |
| G04-bytes-drop | capture byte-count check removed | PASS 13/13 | CLEAN 10/10 | 10 | `52a98617e7676f773083476854ed9e1d440c2cf250ba2938ab05d3a12a49a572` |
| G05-registry-url-skip | registry url membership check removed | **FAIL** 1 of 13 cases | CLEAN 10/10 | **FAIL** | `bd6cc26e7e7e428e853342967c94bd8251f453b88e2e4b3fdbec64048a4fb1f8` |
| G06-registry-prefix | registry url matched as a substring, not a whitespace-delimited token | PASS 13/13 | CLEAN 10/10 | 10 | `c8046468dc083f7a27c200e2e023fd360acfb68cd793922a53f62577aa4062b0` |
| G07-symlink-body-skip | symlinked capture component refusal removed | **FAIL** 1 of 13 cases | CLEAN 10/10 | **FAIL** | `e71d1617e540e134b6670bf1ba7eb40e06d37cb2e69899199a7605bceec3ba8b` |
| G08-cookie-case | set-cookie refusal made case-sensitive | PASS 13/13 | CLEAN 10/10 | 10 | `417e91744dd518331b26a60ecd38a5ba770e6fdb2245fa06b8e01778f4057157` |
| G09-first-clock-only | only the first clock per recheck line replayed | **FAIL** 1 of 13 cases | CLEAN 10/10 | **FAIL** (replayed=0) | `4b7bae57227830acdf5ffe9d02d9b2e060b739641e5b1c54732d4409b9f0d3f8` |
| G10-manifest-symlink | symlinked manifest accepted (`manifest()`) | PASS 13/13 | CLEAN 10/10 | 10 | `54172e15fd339434db9b580ddc726928ead6bbac93b78a522df37b81bc62add6` |
| G11-manifest-dedup-drop | duplicate manifest url no longer refused | PASS 13/13 | CLEAN 10/10 | 10 | `1324fe3918c8c6033e8dd9ceb20fe335bafb23e9214f4e19da81c22483ac70d8` |
| G12-verdict-match | MISMATCH verdict printed as MATCH | **FAIL** 2 of 13 cases | CLEAN 10/10 | **FAIL** | `137bc35d44be12f92d24237b83780ef7fdaa15eabfafd3bb9451cbcfa472c36d` |
| G13-clean-always | CLEAN summary printed regardless of tallies | **FAIL** 10 of 13 cases | CLEAN 10/10 | **FAIL** | `4982e392640c6542da59bd72bedc718276c7e86bbaa88914ad85b5bff6e177c8` |
| G14-pdf-rc-fail-open | pdftotext error reads as count 0 | PASS 13/13 | CLEAN 10/10 | 10 | `111ced877780f6937a11f2b8b9a59e54094fd8fd1468416f5aec3d47aa4da8ee` |
| G15-pdf-no-layout | pdftotext runs without `-layout` | PASS 13/13 | CLEAN 10/10 | 10 | `24192c8460dea3f88af37f26fb838d6afb6a0e3ad1e70d87bb99abca69cc587a` |
| G16-locate-fail-open | missing locate output reads as count 0 | PASS 13/13 | CLEAN 10/10 | 10 | `d9e3b59f0dbbf0e773f2f84ac92ae289946fb1423ca92a573688127a89dfca49` |
| G17-locate-relative | locate runs the tree normaliser by cwd-relative path | PASS 13/13 | DRIFT | **0** | `69ba6f35d7634b87cf65bb4e6028413efec89a213000a8618d70df7c5a275452` |
| G18-unsupported-guess | unknown filter form guessed as grep on the last token | **FAIL** 1 of 13 cases | CLEAN 10/10 | **FAIL** | `449bef0087da71bcd5762c22f6d760fac877c30f7da13ffd5b1a7c6f1055ab88` |
| G19-http1-only | status-line refusal narrowed to `HTTP/1.x` | PASS 13/13 | CLEAN 10/10 | 10 | `49d4aa96e94cecb954a111275e4fd90664e753ec1ed030b53cdb686c34e11383` |
| G20-manifest-header | manifest header equality check removed | PASS 13/13 | CLEAN 10/10 | 10 | `23f40141bc1b692f79a1e829bf7c0c0fe4eb610ba47fbbafb523f4cd0600edbd` |
| G21-symlink-entry-skip | symlinked knowledge entry silently skipped instead of reported | PASS 13/13 | CLEAN 10/10 | 10 | `cccca837cfb657f64d523a100252e58a010bb3551cbaa375f607a464f832eb36` |
| G22-empty-population-clean | empty stated-clock population reads CLEAN instead of SETUP | PASS 13/13 | CLEAN 10/10 | 10 | `e132df5c051100671f827c0c54752f965162f409acf5984c78ac8a61f21010c6` |
| G23-confined-symlink-ok | `confined()` preflight no longer refuses a symlinked input | PASS 13/13 | CLEAN 10/10 | 10 | `b9d8657b99e48570e54fe09bb162c72a10d14370e510ede8a5081519b709887b` |

Totals: **killed 9/24** (selftest 8, gate-run 2, counter 9; G01/G03/G05/G07/G09/G12/G13/G18 overlap plus
G17); **15/24 survive all three detectors on the real corpus**. The selftest is the only detector that kills a
*refusal removal* (G03, G05, G07), because the real corpus never violates those refusals — every remaining
survivor is a refusal or a failure mode the shipped corpus does not exercise.

## 4. Survivors and the control that kills each

Each fixture ran twice: pristine gate (unchanged control) and the mutant. Verdict rows quoted verbatim.

| survivor | killing fixture | pristine gate | mutated gate | DET (mutant) |
|---|---|---|---|---|
| G01b-rc-accept-only-0 | `F01-zero-count` (`-> 0`, pattern absent) | rc 0 CLEAN 1/1 | rc 1 DRIFT | `TOOL corpus/knowledge/e.md:2 id=S001 reason=grep-rc1` |
| G02-rc-fail-open | `F02-grep-rc2` (`PATH grep` exits 2, `-> 0`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `TOOL … reason=grep-rc2` (pristine only) |
| G04-bytes-drop | `F04-bytes-mismatch` (bytes +1, sha correct) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=bytes:.ufo/b.body` |
| G06-registry-prefix | `F06-registry-prefix` (row holds `…/abc`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=url-not-in-row:S001` |
| G08-cookie-case | `F08-cookie-capital` (body starts `Set-Cookie: x=1`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=header-bytes:.ufo/b.body` |
| G10-manifest-symlink | none on this revision — masked, see below | rc 2 SETUP `symlinked-input:corpus/recheck-captures.tsv` | rc 2 SETUP (same) | preflight fires before `manifest()` |
| G11-manifest-dedup-drop | `F14-manifest-duplicate` (two rows, one url) | rc 2 SETUP `manifest-duplicate-url:https://example.test/a` | rc 0 **CLEAN 1/1** | — |
| G14-pdf-rc-fail-open | `F11-pdf-not-a-pdf` (pdf form, text body, `-> 0`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `TOOL … reason=pdftotext-rc1` |
| G15-pdf-no-layout | `F23-pdf-layout-argv` (shim prints needle only with `-layout`) | rc 0 CLEAN 1/1 | rc 1 DRIFT | `MISMATCH … form=pdf stated=1 replayed=0` |
| G16-locate-fail-open | `F12-locate-binary` (body `/bin/ls`, locate form, `-> 0`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `TOOL … reason=locate-output` |
| G19-http1-only | `F09-http2-line` (body starts `HTTP/2 200`) | rc 1 DRIFT | rc 0 **CLEAN 1/1** | `BAD-CAPTURE … reason=header-bytes:.ufo/b.body` |
| G20-manifest-header | none fires — dead conjunct, see §7 | rc n/a | rc n/a | — |
| G21-symlink-entry-skip | `F20-entry-symlink` (`z.md` symlinked, its clock states `-> 9`) | rc 1 DRIFT `UNSUPPORTED corpus/knowledge/z.md:0 reason=symlinked-entry` | rc 0 **CLEAN 1/1** | — |
| G22-empty-population-clean | `F24-empty-population` (one entry, no clock) | rc 2 SETUP `no-stated-clocks` | rc 0 **CLEAN clocks=0** | — |
| G23-confined-symlink-ok | `F25-registry-symlink`, `F26-normalizer-symlink` | rc 2 SETUP `symlinked-input:corpus/SOURCES.md` / `…/rendered-text-v1.py` | rc 0 **CLEAN 1/1** | — |

`F13-manifest-symlink` no longer discriminates G10 on `2e9dfde3…`: the new `confined()` preflight refuses the
tree before `manifest()` runs, so both the pristine and the G10 gate print
`SETUP symlinked-input:corpus/recheck-captures.tsv`. The `manifest()` symlink check is therefore redundant
with the preflight (QM9: a conjunct that cannot fire is a setup error, not a pass) — and neither check has a
selftest case.

## 5. The seven probes named in the tasking

1. **rc check** — G01 (accept only rc 1) is killed three ways (selftest 5/13, gate DRIFT, counter FAIL).
   G01b (accept only rc 0) and G02 (rc ≥ 2 → count 0) **survive all three**: no POP clock is a zero count,
   and the selftest has neither a zero-count nor a grep-error case. F01 kills G01b, F02 kills G02.
   Residual risk is real: a `-> 0` clock meeting a failing grep reads `MATCH`/`CLEAN` under G02.
2. **capture digest** — `sha256` removal dies at the selftest (`sha-mismatch`, 1/13) and at the counter's own
   r3 (`bad=r3-digest`). `bytes` removal **survives all three** and is killed only by F04 (a row whose bytes
   column is wrong while sha256 is right); the two checks are not redundant, but the shipped selftest reaches
   only one of them.
3. **registry url** — membership removal dies at the selftest; token-boundary weakening (G06) **survives all
   three** and dies at F06. Neither the gate nor the counter checks fence context, cell count or `status
   mined` at gate level: F17 (row inside ``` fences) reads gate `CLEAN` while the counter's r2 refuses it.
4. **symlink** — capture-component refusal dies at the selftest and r3. The **new `confined()` preflight**
   (G23) **survives all three** and dies at F25/F26; it has no selftest case at all, and it is the only
   barrier for a symlinked registry or normaliser (`registry_rows()` and the locate call would otherwise read
   through the link). G21 (symlinked knowledge entry) also **survives all three** and dies at F20 — the
   `<symlinked-entry>` branch added in `637c8184…` is likewise untested by the selftest.
5. **multiple clocks** — first-clock-per-line (G09) dies at the selftest (`second-clock-mismatch`) and at the
   counter (r5 needs one MATCH line per POP clock; it reads `replayed=0`). Not covered: two column-1
   `recheck:` lines in one entry (F21 → gate `CLEAN clocks=2` while C1's r1 PRESENT refuses), a clock removed
   (F18 → `CLEAN clocks=1`), a clock on an indented line (F19 → `CLEAN clocks=1`, clock invisible), a
   duplicate clock on one line counting twice, and an empty population (F24 → SETUP today, `CLEAN clocks=0`
   under G22). Only C1's r1/guard holds these; the gate's CLEAN is not a lane-wide statement on its own.
6. **PDF / locate forms** — the selftest has **zero** pdf and locate cases, so all mutants of those paths
   survive it. `-layout` removal survives the real corpus (S078 still counts 1) and the counter (r4 uses
   `-layout` too, so it agrees); it dies only at the argv shim F23. pdf rc fail-open (G14) and locate fail-open
   (G16) survive all three and die at F11/F12. The cwd-relative normaliser (G17) dies at the counter only
   because the counter runs the gate with `cwd=$SCR`, which has no `corpus/`
   (`DRIFT (clocks=10 match=9 tool=1)`); measured both ways on the same tree,
   `cd <lane>; gate17 --root <lane>` prints `CLEAN (clocks=10 match=10 …)`. So the one mutant that targets
   the gate's *absolute-path* contract is invisible under the natural invocation — the QM4 class (a case
   proves only the isolation it exercises): a locate case must run from a neutral cwd and assert the count.
7. **PRESENT-like omissions** — see item 5: the gate cannot report a clock that no longer exists, an
   indented clock, a second `recheck:` line, or an empty population, and it reports a symlinked entry only
   because of the new branch. Gate `CLEAN` is a statement about the clocks the gate found, not about the
   clocks the entries state.

## 6. Proposed selftest cases (not applied)

### 6.1 Cases

Drop-in cases, using the existing `tree()` / `good_row()` / `cmd` helpers (each has a measured counterpart
in §4); add after `second-clock-mismatch`:

```python
    # --- proposed round-56 mutation cases (R56MutGate) ---
    zero = "`curl -fsSL 'https://example.test/a' | grep -c 'absent'` -> 0"
    cases.append(("zero-count-is-match", zero, [good_row()], {}, 0, "MATCH"))
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

Two more need a second tree shape but no new helper: `symlinked-registry` and `symlinked-normaliser`
(symlink `corpus/SOURCES.md` / `corpus/rendered-text-v1.py`, expect rc 2 with `symlinked-input:`), plus
`symlinked-entry` (symlink an entry, expect rc 1 with `reason=symlinked-entry`) — the three behaviours the
`2e9dfde3…` revision added and did not test. Two harness-level cases need a `PATH` shim:
`grep-error-is-tool` (G02) and `pdftotext-argv-has-layout` (G15), exactly as F02/F23 build them here.

Not drop-in: `two-recheck-lines` and `indented-clock` are **not** proposed as code above because on today's
bytes those trees read `CLEAN clocks=2` / `CLEAN clocks=1` (F21/F19, measured). Asserting them requires a gate
behaviour change (or a new `STRUCTURE` verdict word) and belongs to L1's route decision, not to a case-list
edit; if the frozen predicate admits no new word, assert the existing `UNSUPPORTED` token and the rc.

### 6.2 Freeze coupling (measured; three literals must move together)

The counter pins the gate twice: `GATE_SHA256_PIN=<64 hex>` and the literal `PASS (13 cases)`. A gate that
adds one benign case and nothing else:

```
gate14 = 13+1 cases, sha256 e82522c0792780033bfa5d6efb3303d8d76fc051026b34b465abb056251adbc0
  --selftest → rc 0  RECHECK_REPLAY_SELFTEST: PASS (14 cases)
  --root     → rc 0  RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)
counter, pin=gate14, literal "PASS (13 cases)" → value=FAIL present=10 replayed=10 gate=1 guard=0 (bad=selftest)
counter, pin=gate14, literal "PASS (14 cases)" → value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)
```

So any accepted case proposal is a three-file freeze edit (gate, both counter literals), with the pin computed
*after* the gate's final bytes. A partial edit reads `value=FAIL` with `guard=0`, not a loud setup error.

## 7. Residual findings and limits

- **G20 (manifest header) is a dead conjunct** on any well-formed manifest and no fixture can kill it: with
  the header equality removed, the positional `zip(HEADER, cols)` still breaks a later conjunct for a
  genuinely wrong header. Propose `manifest-header-swap` (permute two header columns, expect SETUP/BAD-CAPTURE)
  to give it a firing case — QM9.
- **G10 (`manifest()` symlink) is masked by the new preflight** (§4), i.e. dead while `confined()` runs.
- **Gate vs frozen predicate**: the gate does not implement r1 (single line / PRESENT), r2's fence, cell count
  and `status mined`, nor "exactly one manifest row" as a per-row verdict (it refuses duplicates via SETUP).
  Those live only in the counter, so gate `CLEAN` is narrower than C1 `REPLAYED`; the *claim* is protected,
  the *gate's certificate* is not lane-wide.
- **Not probed**: capture provenance / hand-written bodies (a named ceiling of the plan), `--max-time`/`-A`
  token semantics beyond `extra-curl-flag`, UTF-8/BOM edges of `rendered-text-v1.py`, a symlinked *parent*
  of `corpus/knowledge`, FIFO/device bodies (the component walk looks only for symlinks), and timeouts (never
  triggered; nothing here claims they are handled). Counter-side mutation was out of seat scope beyond §6.2.

## 8. Restoration and cleanup evidence

- Pristine gate re-hashed at exit of the sweep: `2e9dfde3…` = §1 (assert inside the harness; the sweep aborts
  otherwise). Every mutant lives in its own `cp -a` tree.
- Lane writes by this seat: `.ufo/waves/round-56/build/R56MutGate.md` and
  `.ufo/waves/round-56/build/R56MutGate.d/*` only (`git status --porcelain | grep R56MutGate` shows exactly
  those two paths). `corpus/recheck-replay.py`, `corpus/recheck-captures.tsv`, `plans/round-56-c1.sh`,
  `plans/round-56-controls.sh`, `plans/round-56.md` were read only; hashes before/after are in
  `.d/hashes.txt` and `.d/instrument-drift.txt`.
- Scratch `/fast/scratch/hyaku/kagi-r56/R56MutGate/` deleted before yield. (It was additionally wiped twice
  mid-run by a process outside this seat, which is why receipts were written into the lane dir as each step
  finished.)

## 9. Receipts

- `.ufo/waves/round-56/build/R56MutGate.d/mutation-sweep.json` — baseline, all 24 mutants (exact old/new
  text, mutated sha256, three detector outputs, derived-counter sha256), `pin_kill` rows, all 28 fixtures
  with both runs and verbatim verdict rows. Generated against gate `2e9dfde3…`, counter `6b132ea1…`.
- `.ufo/waves/round-56/build/R56MutGate.d/run3-637c8184-summary.txt` — console transcript of the earlier
  23-mutant sweep against gate `637c8184…` (its JSON receipt was lost to the scratch wipe; the transcript is
  pasted unedited). Its verdicts agree with `2e9dfde3…` for every conjunct that survives either revision.
- `.ufo/waves/round-56/build/R56MutGate.d/hashes.txt` — instrument snapshot at measurement.
- `.ufo/waves/round-56/build/R56MutGate.d/instrument-drift.txt` — full hash timeline and lane HEAD.
- `.ufo/waves/round-56/build/R56MutGate.d/probe-log.txt` — exact commands and raw outputs for the baseline,
  the unfilled pin, the pin kills, the 14-case coupling probe, the G17 cwd experiment and the locate counts.
- `.ufo/waves/round-56/build/R56MutGate.d/counter-current-tree.txt` — current lane counter on a real-corpus
  tree: `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`, rc 0.
