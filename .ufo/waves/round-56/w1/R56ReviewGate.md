# R56ReviewGate — adversarial review of the round-56 replay gate

Seat `R56ReviewGate`, 2026-11-07. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
**Observed answering model:** `amr/deepseek-v4.1-flash` (workstation project-context `Model:` field; not inferred from this prompt).
**Scope:** `corpus/recheck-replay.py`, `corpus/recheck-captures.tsv`, the 10 committed captures, and the counter's r5 conjunct. Read-only on the lane: every mutation ran in scratch fixtures; no production file, git/jj state, fleet-root file. Only this report and `R56ReviewGate.d/` were written. No network (the live re-fetch leg is another seat).

## 0. Target bytes — and a mid-review epoch change

The seat spec named the predeclaration commit `42070de…` and said the gate was unchanged. It was not unchanged for long: the L1 re-froze mid-wave. Every finding below names the bytes it was measured on.

| artifact | epoch A — 42070de (the seat-spec target) | epoch B — 5d9a157 (declared re-freeze) |
|---|---|---|
| gate `corpus/recheck-replay.py` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` (333 L) | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` (356 L) |
| counter `plans/round-56-c1.sh` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` |
| plan `plans/round-56.md` | `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` |
| controls `plans/round-56-controls.sh` | `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` |
| manifest `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | same |
| `corpus/SOURCES.md` | `fa69564f610e5192093b05ae17c9ee385aa607586cc219d0e33460985ab12936` | same at the commit; worktree edit after |

An uncommitted draft existed 07:35:34–07:41 (gate `637c8184…`, counter `d2bcb790…`, pinning that draft); it was never committed and no finding is anchored to it. **After epoch B, a third uncommitted draft appeared while this report was being written** (observed 07:50–07:52, HEAD still `5d9a157`): gate `d4392ffe831560397fa35b4e84198b6ac75d5da8505a302ef3dcf6991080b274` (15 selftest cases, adds `not-capture-path` and `trace-headers`; still **0** pdf/locate cases), counter `be4af051…` (`GATE_SHA256_PIN=d4392ffe…`), plan `46d05217…`, controls `57a18b4a…`. It is not reviewed in depth here; it does not close F1, F5, F6, F7, F8, F9, F10, F11 or F12 by inspection, and it shows the epoch churn is not a one-off. My snapshots `epochB-gate-2e9dfde3.py` / `epochB-counter-6b132ea1.sh` are byte-identical to `git show 5d9a157:…`.

Readings I took (commands in `R56ReviewGate.d/raw/`):

| command | result |
|---|---|
| frozen counter (A) `--tree`/rev `42070de` | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` rc0 (`raw/40`) |
| frozen counter (A) rev `832ba6a` (BASE) | `value=0 present=10 replayed=0 gate=0 guard=1` rc0 (`raw/55`) |
| epoch-B counter rev `5d9a157` | `value=10 … gate=1 guard=1 (bad=none)` rc0 (`raw/35`) |
| epoch-B counter rev `42070de` | `value=0 … gate=0 guard=1 (bad=r5-gate ×10)` rc0 — the gate pin, by design |
| epoch-B counter `--tree <lane>` (worktree) | `value=10 … gate=1 guard=1 (bad=none)` rc0 (`raw/36`) |
| epoch-A gate on the lane tree | 10 MATCH + `CLEAN` rc0 |

## 1. Findings

### F1 — HIGH (gate artifact) / MEDIUM (the C1 number): the 13-case selftest proves nothing about two of the three accepted filter forms, and a gate whose `pdf`+`locate` branches are dead prints `CLEAN` and earns `value=10`
- **applies:** epoch A (measured); epoch B structurally identical (the sha pin blocks *this* mutant, not the gap).
- **where:** A `corpus/recheck-replay.py:184-196` (pdf/locate replay), `:273-312` (13 cases, every one `grep`); B `:187-203`, `:300-340`.
- **repro:**
  ```
  python3 -I -B R56ReviewGate.d/mutants/A-pdf-locate-constant.py --selftest
  python3 -I -B R56ReviewGate.d/mutants/A-pdf-locate-constant.py --root <base>
  python3 -I -B R56ReviewGate.d/mutants/A-pdf-locate-constant.py --root <liar>
  bash R56ReviewGate.d/frozen-counter-runner.sh --tree <base-mutantA>
  ```
  Mutant A = frozen gate + `if kind in ("pdf","locate"): return 1, None` (sha256 `f6eb6aac…`).
- **observed:** `--selftest` → `PASS (13 cases)` rc0. `--root <base>` → `CLEAN (clocks=10 match=10 …)` rc0. On `<liar>` (S078's row re-pointed at S074.body, S070's at S055.body, bytes/sha recomputed) the unmutated gate emits `TOOL … id=S078 reason=pdftotext-rc1` and `MISMATCH … id=S070 form=locate stated=1 replayed=0` → `DRIFT` rc1 (`raw/53`), while mutant A emits `CLEAN (clocks=10 match=10 …)` rc0 (`raw/51`). The frozen counter on `<base-mutantA>` returns `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` (`raw/40`).
- **expected:** a dead branch should fail the artifact's own proof. It cannot: both live `pdf`/`locate` clocks state **1**, so a constant-1 branch is indistinguishable from a correct one on the real tree, and the selftest has no `pdf` or `locate` case. The C1 number is protected only by the counter's independent r4 implementation (which does replay both forms with BASE's helper); r5's gate conjunct contributes no proof for 2/10 clocks. The epoch-B `GATE_SHA256_PIN` converts "these bytes were tested" into an assertion about bytes, not a proof that the bytes replay the forms.
- **fix shape:** add a committed fixture PDF and a fixed-quote locate case to `--selftest`, or drop r5 as redundant (r4 already catches a wrong count).

### F2 — MEDIUM (evidence chain): the epoch-A→B re-freeze makes predeclaration-revision readings depend on which counter you run, and the epoch-B receipt is not byte-bound
- **applies:** both (process).
- **evidence:** `raw/10-drift.txt`, `raw/34`, `raw/35`, `raw/40`.
- **observed:**
  - `bash plans/round-56-c1.sh 42070de` (epoch-B bytes) → `value=0 … gate=0`; the same revision with the epoch-A counter → `value=10 … gate=1`. Both are correct and the two sentences "42070de reads 10" and "42070de reads 0" are both true of a different instrument. Any closure sentence that names a revision must name the counter sha256 beside it.
  - Three wave reports pinned the epoch-A gate: `R56Connector.md:24`, `R56Critic.md:14,239`, `R56ExecVerify.d/sha256sums.txt:3,7` (`b7782f35…`). `R56ExecVerify`'s assigned check "the archive at 42070de reproduces 10" is an epoch-A statement; a re-run with the epoch-B counter reads 0 by design.
  - The epoch-B controls receipt `.ufo/waves/round-56/controls/controls-prefreeze-epochB.txt` carries **75 embedded `tar:` errors** (paths like `.ufo/waves/round-56/build-dispatch.json` that are deleted in the worktree but still in the index — `mk_ref`'s `git ls-files -co --exclude-standard`) and **no instrument sha256 lines**. Its last line, `CONTROLS: match=16 mismatch=0`, and 16 `CONTROL … MATCH ::` lines do check out.
  - The epoch-B plan still names the **epoch-A** receipt in `plans/round-56.md:27` (`Receipt: .ufo/waves/round-56/controls/controls-prefreeze.txt`), not the epoch-B file.
  - A third uncommitted instrument draft appeared at 07:50–07:52 (gate/counter/plan/controls shas in §0), so the distance between "frozen" and "being edited" was minutes, not hours.
  - The re-freeze commit `5d9a157` includes 351 files of in-flight seat evidence (`.ufo/waves/round-56/w1/…`, `attempt1-build/…`), so later seat writes appear as diffs against the "predeclaration". My `.d` is in that set; the `epochC-*`→`epochB-*` renames appear as delete+add.
- **expected:** a receipt that binds an instrument names the instrument's sha256; a plan cites its own epoch's receipt; `mk_ref` should fail on (or exclude) missing paths rather than emit 75 error lines into evidence.
- **impact:** the claim is still measured; the *audit trail* is ambiguous exactly where the wave's other seats split their attestations.

### F3 — MEDIUM (epoch A only; fixed in B): a symlinked knowledge entry is silently dropped from the population
- **where:** A `:66-68` (`if path.is_symlink(): continue`); B `:68-72` + `:236-239` (reports `UNSUPPORTED … reason=symlinked-entry`).
- **repro:** `<symentry>` = frozen tree + `.ufo/false-entry.md` stating `-> 9` for a URL whose body yields 0, plus `corpus/knowledge/z-false.md → ../../.ufo/false-entry.md`.
  ```
  python3 -I -B <A-gate> --root <symentry>     # raw/53
  python3 -I -B <B-gate> --root <symentry>     # raw/22
  ```
- **observed:** A → `CLEAN (clocks=10 match=10 …)` rc0, no line about the entry (the false clock is invisible; QM3 skip not counted). B → `UNSUPPORTED corpus/knowledge/z-false.md:0 reason=symlinked-entry` + `DRIFT (clocks=11 … unsupported=1)` rc1.
- **expected:** the docstring says the population is "every backticked command on a column-1 `recheck:` line of corpus/knowledge/*.md"; on A a false clock can be hidden by making the entry a symlink. The frozen counter's `read()` also rejects symlinked entries, so a C1 *inflation* is blocked — the gate's `CLEAN` is still compatible with a false clock in the tree.
- **F3b (both):** B's new branch is untested by the 13 cases. `mutants/G-probeB-drop-symlink-branch.py` (B minus the block, sha `92475bc6…`) → `--selftest` `PASS (13 cases)` and `<symentry>` `CLEAN` rc0 (`raw/28-29`).

### F4 — MEDIUM (epoch A): a symlinked `corpus/knowledge` directory is followed; the gate replays bytes outside the tree
- **where:** A `:63-65` (no check on the knowledge path); B fixes it in `confined()` `:207-217` + preflight `:219-224`.
- **repro:** `<klink>` = frozen tree with `corpus/knowledge → ../../klink-out` (all entries outside the root).
  ```
  python3 -I -B <A-gate> --root <klink>   # raw/53: CLEAN 10 match
  python3 -I -B <B-gate> --root <klink>   # raw/23: SETUP symlinked-input:corpus/knowledge rc2
  ```
- **observed:** A → `CLEAN (clocks=10 match=10 …)` rc0 while reading `klink-out`; B → `RECHECK_REPLAY: SETUP symlinked-input:corpus/knowledge` rc2.
- **expected:** the component policy `check_capture` applies to `body_path` (A `:160-163`) should cover every input. On A `CLEAN` does not mean the replayed bytes are in the tree. The counter is safe (its `read()` rejects symlink components; a committed absolute symlink would resolve in `cp -a`'s copy and still be rejected) — but only the counter is.

### F5 — MEDIUM-HIGH (A and B): the `locate` form executes the measured tree's unpinned `corpus/rendered-text-v1.py`, and because r5 is conjunctive on a **global** gate `CLEAN`, one forged helper turns `value=0` into `value=9` on a corpus with one false clock
- **where:** A `:191-196`; B `:195-200`; the counter's r4 deliberately uses BASE's copy (`plans/round-56-c1.sh:172`) but r5 uses the measured tree's gate, which uses the measured tree's helper.
- **repro:** `<locate-stub>` (single clock, body has 0 occurrences, clock `-> 1`, helper prints `count=1`) and `<stubB>` (the frozen tree + epoch-B gate + the same stub helper, with S070's row pointed at a unique body whose real quote count is 0).
  ```
  python3 -I -B <A-gate> --root <locate-stub>      # raw/52: CLEAN rc0
  python3 -I -B <B-gate> --root <locate-stub>      # raw/25: CLEAN rc0
  python3 -I -B <A-gate> --root <locate-real>      # raw/52: MISMATCH/DRIFT rc1
  python3 -I -B <A-gate> --root <locate-nohelper>  # raw/52: TOOL locate-output rc1
  bash <epoch-B counter runner> --tree <stubB>      # raw/57: value=9 … gate=1 guard=1 (bad=r4-replay0:S070)
  bash <epoch-B counter runner> --tree <stubB-real> # raw/57: value=0 … gate=0 guard=1
  ```
- **observed (same corpus, only the helper differs):** with BASE's real helper the gate prints `DRIFT (clocks=10 match=9 mismatch=1 …)` and the counter reads `value=0 present=10 replayed=0 gate=0 guard=1` — one bad clock zeroes all ten r5 conjuncts. With the stub helper the gate prints `CLEAN (clocks=10 match=10 …)` and the counter reads `value=9 present=10 replayed=9 gate=1 guard=1 (bad=r4-replay0:cdp-bridge-…)`. The stub is a **regular** file, so the epoch-B `confined()` preflight passes it; only r4 refuses the lying clock.
- **expected:** the gate should run BASE's helper (as r4 does) or its helper bytes should be pinned like the gate's; otherwise a single in-tree file forges the global `CLEAN` on which every clock's r5 depends. r4 caps the reachable reading at 9, so C1's target 10 is not reachable this way — but the printed partial-progress number and the gate's verdict are forgeable, and the plan's named ceilings do not mention the helper.

### F6 — MEDIUM (A and B): uncaught exceptions replace the documented `SETUP` verdict
- **where:** A `:70` (entry read), `:130` (manifest read), `:166` (body read); B `:73`, `:133`, `:169`. Docstring contract A `:32-34`.
- **repro / observed:**
  - non-UTF-8 entry (`corpus/knowledge/bad.md` with `\xff\xfe`) → `UnicodeDecodeError` traceback, rc1, **no** `RECHECK_REPLAY:` line (`raw/50` `e-nonutf8-knowledge`; B: `raw/27`).
  - manifest `chmod 000` → `PermissionError` traceback, rc1, no verdict (`raw/50` `e-unreadable-manifest`).
  - body `chmod 000` → `PermissionError` traceback, rc1, stdout's last line is a `MATCH` line (`raw/55`).
- **expected:** exit 2 with `RECHECK_REPLAY: SETUP <reason>` for an unreadable/undecodable tree; exit 1 only with the `DRIFT` summary. The counter is fail-closed (`gate_clean=0`) but a human or an rc-only caller cannot distinguish a corpus setup failure from drift, and the partial `MATCH` lines are misleading.

### F7 — LOW/MEDIUM (A and B): `RECHECK_REPLAY: CLEAN` is not the plan's r2 — the registry check accepts rows r2 refuses
- **where:** A `:115-121` and `:150-155`; B `:118-124` and `:153-158`.
- **repro:** `<reg2>` (S054 row reduced to 2 cells, URL kept), `<fence>` (S054 row inside a ``` fence), `<r-url-in-claim-cell>`, `<r-dup-id-last-*>`, `<r-2cell-row-with-url>`.
- **observed:** the gate keys rows by id with **last-row-wins**, searches the URL anywhere in the row line (any cell), and does not check 11 cells or `mined`:
  - `<reg2>`/`<fence>` → gate `CLEAN (clocks=10 match=10 …)` rc0 (`raw/53`); frozen counter `value=9 present=10 replayed=9 gate=1 guard=1 (bad=r2-registry:secret-scanning-…)` (`raw/41`); epoch-B counter on `<reg2B>`/`<fenceB>` → `value=9 … gate=1` (`raw/31-32`).
  - duplicate id rows: URL in the **last** row → MATCH; URL only in the first → `BAD-CAPTURE` (`raw/50` `r-dup-id-*`): the verdict depends on line order.
  - URL token in the claim cell or a 2-cell row → MATCH (`raw/50` `r-url-in-claim-cell`, `r-2cell-row-with-url`).
- **expected:** the docstring says only "appear in that id's registry row", so this is a documented-scope limitation, not a false C1 (r2 is a separate conjunct). But any citation of the gate's `CLEAN` as "the registry contract holds" is wrong, and the last-row-wins map is a silent order dependence.

### F8 — LOW (A and B): the QM72 refusal is byte-anchored for the status line and LF-anchored for `set-cookie`
- **where:** A `:174`; B `:174` (`re.match(rb"HTTP/\d", data) or re.search(rb"(?im)^set-cookie:", data)`).
- **observed (frozen gate, `raw/50`):** accepted as MATCH — a body starting `\nHTTP/2 200\r\n…` (`b-leading-blank-then-HTTP`), a body starting `HTTP/ x` (`b-http-nodigit-first-byte`), a line ` set-cookie: a=b` with a leading space (`b-set-cookie-leading-space`), and CR-only lines `\rSet-Cookie: a=b` (`b-set-cookie-CR-only-lines`). Refused as `BAD-CAPTURE` — `HTTP/2 200` at byte 0 (`b-http-first-byte`) and LF-anchored `set-cookie:`/`SeT-CoOkIe:` (`b-set-cookie-lf-line`, `b-set-cookie-mixed-case`).
- **expected:** literal docstring wording ("begins with an HTTP status line", "a line starting `set-cookie:`") makes these conforming; the plan's r3 and the counter use the same shapes (`startswith(b"HTTP/")` + the same regex). Practical exposure is a hand-edited body (a `curl -i` body always begins with the status line), which is inside the named ceiling.

### F9 — LOW (A and B): `http_status` and `fetched` are carried but never validated
- **where:** A `:124-147`; the counter's r2/r3 never read those columns.
- **observed:** a row with `http_status=404` and `fetched=""` → gate `CLEAN` and counter `value=10` (`raw/50` `m-http-status-404-unchecked`, `m-fetched-empty`).
- **expected:** the capability sentence is "re-verified true against a committed body capture"; a capture the manifest itself labels 404 should not score, and the plan's r3 does not require 2xx either. This is a predicate weakness to route, not a gate-only defect.

### F10 — LOW (A and B): one malformed manifest row anywhere aborts every verdict
- **where:** A `:138-140`; B `:141-143`.
- **repro/observed:** `<poison>` = frozen tree + an 8-column row for an unused URL → `RECHECK_REPLAY: SETUP manifest-columns:S999` rc2, zero per-clock lines (`raw/54`; B `raw/26`).
- **expected:** the bad row should be `BAD-CAPTURE` for the clock that uses it, or the `SETUP` line should say no clock was evaluated. Fail-closed, but ten verdicts are discarded for an unrelated row and the summary carries no `clocks=`.

### F11 — LOW (A and B): remaining selftest gaps and assertion looseness
- **where:** A `:284` (header case body), `:167` (bytes guard), `:141` (duplicate guard), `:299` (`want_tok in out`), `:321-328` (arg handling); B `:307`, `:170`, `:144`, `:322`, `:344-351`.
- **observed (single-point mutants of the frozen gate; `--selftest` all `PASS (13 cases)`; `raw/51`):**
  - `C-drop-status-line-guard` (`961a0ec7…`) — the `header-bytes` case's body also contains `set-cookie:`, so removing the status-line refusal still passes; on `<mut/b2>` the mutant is `CLEAN` where the frozen gate is `BAD-CAPTURE`.
  - `D-drop-bytes-guard` (`942d9b4b…`) — bytes-column mismatch accepted; `<mut/b8>` `CLEAN` vs `BAD-CAPTURE`.
  - `B-drop-dup-url-guard` (`91c1e129…`) — duplicate URL rows accepted; `<mut/m1>` `CLEAN` vs `SETUP`.
  - `E-follow-symlinked-entries` (`a597130f…`) — population gap in F3.
  - `G-probeB-drop-symlink-branch` (`92475bc6…`) — epoch-B branch untested (F3b).
  - `F-drop-registry-check` (`67cb0801…`) **is** caught: `FAIL (1 of 13 cases)`.
  - `want_tok in out` is a substring test: `"MATCH"` is a substring of `"MISMATCH"`; the `rc == want_rc` conjunct is what prevents a false PASS for the MATCH cases.
  - `--selftest extra` runs the selftest (rc0) instead of `usage`/SETUP: `main` checks `argv[1:2] == ["--selftest"]` and ignores the rest.

### F12 — LOW (A and B): the replay is locale-dependent
- **where:** A `:179-181`; B `:182-185` (host `grep`/`pdftotext` invoked without `LC_ALL`; the counter's r4 is the same at `plans/round-56-c1.sh:164,170` in the frozen counter).
- **repro/observed:** one fixture, body bytes `a\xc3\xa9c\n`, pattern `a.c`, stated 1: `LC_ALL=C.UTF-8` → `MATCH` rc0; `LC_ALL=C` (and `POSIX`,`LANG=C`) → `MISMATCH` rc1 (`raw/50` `l-dot-*`). Same tree and bytes, different verdict.
- **expected:** an offline replay of a committed tree should be a function of the committed bytes. None of the 10 current patterns crosses a multibyte character with `.` (their dots match literal periods), so today's reading is unaffected; the gate should pin the locale (or say it does not).

## 2. Does the 13-case selftest cover these classes?

`--selftest` on the frozen bytes: `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` rc0 (12 `cases` + 1 standalone symlink case; A `:252-318`). Coverage against the classes above:

| class | covered by the 13 cases? | evidence |
|---|---|---|
| grep form MATCH/MISMATCH, `-> N`/`-> count=N`, BRE `.` | yes | cases 1–4 |
| one clock per line / a second clock mismatching | yes (MISMATCH only) | case 12 |
| NO-CAPTURE | yes | case 5 |
| sha256 mismatch, `..` path, symlink body component | yes | cases 6, 8, 13 |
| registry URL token | yes | case 7 |
| header bytes | **partially** — body carries both a status line and `set-cookie:`; not isolating | F11, mutant C |
| UNSUPPORTED (`sed` stage, unknown curl flag) | yes | cases 10–11 |
| pdf form (`pdftotext`), locate form | **no (0 cases each)** | F1, mutant A |
| TOOL class | **no** | F1/F5 |
| SETUP paths (`not-a-lane-tree`, `no-stated-clocks`, manifest header/columns/duplicate, usage) | **no** | F6/F10 |
| manifest bytes column, body-missing, dir/FIFO, duplicate URL | **no** | F10/F11, mutants B/D |
| second URL, quoted URL with spaces, `|` inside a quoted pattern | **no** (all correctly UNSUPPORTED when run) | `raw/50` p-* |
| symlinked entry / symlinked knowledge dir | **no (A)**, no (B branch untested) | F3/F4 |
| registry 11-cell/`mined`/order | **no** | F7 |
| locale determinism | **no** | F12 |

So: **refuted** that the selftest covers the classes found here. It is honest about its count (13) and hermetic (temp dirs, no network, no substrate; the `-o /tmp/x` case is parse-only and never executed), but it exercises one of three accepted forms.

## 3. Cannot-break confirmations (rc recorded)

- Frozen gate on the frozen tree (`git archive 42070de`): 10 MATCH + `CLEAN` rc0; epoch-B gate on 5d9a157: same (`raw/20-21`).
- Frozen/epoch-B counters: `value=10 … guard=1` at their own revisions; `value=0` at BASE (`raw/35`, `raw/40`).
- BRE semantics are the statement's, not ERE: `cat|dog`→0, `cat\|dog`→2, `cat+`→0, per-line counting (`raw/50` `bre-*`, `grep-per-line-count`); invalid BRE → `TOOL … grep-rc2`.
- `UNSUPPORTED` vs `MISMATCH`: sed stage, second URL, unknown flag, `grep -c -e`, `grep -Ec`, `--max-time=30` → UNSUPPORTED rc1; a supported form with the wrong count → MISMATCH; missing row → NO-CAPTURE; non-PDF in the pdf form → TOOL (`raw/50`, `raw/53`).
- Exit codes on every path I exercised: CLEAN rc0; any non-MATCH rc1; not-a-lane-tree/no-stated-clocks/manifest-header/manifest-columns/manifest-duplicate/usage rc2 — except the traceback class F6.
- Body checks: `..`, absolute, empty, symlink component (dir, final, internal target), directory, FIFO → BAD-CAPTURE rc1, no hang; hardlink accepted (path confinement, not inode).
- Manifest/captures: all 10 rows' bytes+sha match the committed bodies; the 7 new captures' `fetch-receipt.json` URLs/status/bytes/sha equal the manifest rows; the 10 registry rows are 11 cells with `mined` at cell 8 and carry the URL as a whitespace token (`raw/10`, and the cross-check printed in session).
- No shell is used (`subprocess` argv lists throughout); a URL token containing `?`/`&` is inert.

## 4. Residual risk and verification gaps

- **Named ceiling is the load-bearing one.** A hand-written capture with a self-consistent manifest row scores; capture provenance is the receipt (not read by either instrument) plus the live re-fetch leg (another seat). The gate cannot tell a transcript from a page.
- **r5 is not independent.** F1 shows the gate conjunct adds nothing r4 does not for two of three forms; the epoch-B sha pin makes r5 a checksum of an artifact, not a second opinion.
- **Gate immutability under the pin.** Any fix to F5/F6/F8 requires editing the gate *and* `GATE_SHA256_PIN` in the frozen counter; the epoch-B kill rule binds `plans/round-56.{md,-c1.sh,-controls.sh}` (the L1 notes the gate is outside the pathspec but coupled by the pin). Land no gate edit between 5d9a157 and the candidate; schedule these as epoch C.
- **Not run by me (out of seat):** the 16-control epoch-B battery; the live `curl` re-fetch of the 10 URLs; `sources-census`; the claim-ledger. My receipts cover only the gate, manifest, captures and the counter readings above.
- **Receipt-dir note:** the epoch-B commit `5d9a157` captured my `.d` as it stood at 07:44 (files named `epochC-*`); the current `.d` has them renamed to `epochB-*` and three receipts added after the commit, so `git status` will show those as working-tree changes. Content is byte-identical where the sha matches `sha256sums.txt`.

## 5. Receipts

`R56ReviewGate.d/` (44 files, `sha256sums.txt` over all): `frozen-gate.py` (`b7782f35…`), `frozen-counter.sh` (`096251c9…`), `frozen-counter-runner.sh` (same bytes, one `REPO=` line changed so it can run outside the lane; sha `a11c4750…`), `epochB-gate-2e9dfde3.py`, `epochB-counter-6b132ea1.sh`, `probe.py`, `sweep.py`, `locate-probe.py`, `fixtures.md` (exact fixture construction), `mutants/A…G`, `raw/10-drift.txt`, `raw/20-36`, `raw/40-41`, `raw/50-55`, `raw/57` (stub-helper vs real-helper counter contrast), `raw/53` (frozen symentry/klink/reg2/fence/liar), `raw/54` (frozen poison), `raw/55` (frozen counter at BASE; body `chmod 000`).

Scratch `/fast/scratch/hyaku/kagi-r56/R56ReviewGate/` was deleted before yield (it was also lost once mid-review and rebuilt from `git archive 42070de`; `fixtures.md` documents the rebuild).
