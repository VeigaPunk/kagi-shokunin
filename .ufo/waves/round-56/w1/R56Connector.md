# R56Connector — Sibling-lane overlap scan, considerthese mining, and QUALITY gap analysis

**Seat:** `R56Connector` (connector).  
**Round:** kagi 56 attempt 3.  
**Date:** 2026-11-07.  
**Lane:** `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.  
**BASE revision:** `832ba6a53d6a76706b5c80bce2278683dea33d42` (`git cat-file -t` = commit, rc=0).  
**Predeclaration / Frozen commit:** `42070de7770e1558adcf6aa7a7bc59309a9654d7` (`git cat-file -t` = commit, rc=0).  
**Observed answering model:** `google-antigravity/gemini-3.8-flash` (observed from workstation runtime context).  
**Judged on:** freshness, adjacency.  
**Milestone:** C1 capability: lane-wide stated-clock offline replay (C1_REPLAY 0->10); gate/counter attack seats; live re-fetch leg; frontier curation; mistake mining.  
**Receipts directory:** `.ufo/waves/round-56/w1/R56Connector.d/` (5 receipt files).  
**Scratch directory:** `/fast/scratch/hyaku/kagi-r56/R56Connector/` (cleared before yield).

---

## 1. Local Instrument Hashes & Working-Tree State

All sha256 sums verified with `sha256sum` (rc=0):

| Path | SHA256 | Bytes |
|---|---|---|
| `plans/round-56-c1.sh` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | 9,997 |
| `corpus/recheck-replay.py` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | 13,018 |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | 1,845 |
| `considerthese/2026-10-26.md` | `4c0ec69a2be4ef4f876c53cb44999c1ef80846ddade52795cdb97c09bc77241d` | 3,091 |
| `corpus/QUALITY.md` | `c4f35d07443796afd51debc87d0efbc20fd9c028ab68bf02e71acc261634d285` | 36,419 |

---

## 2. Change 1: Sibling Lane Overlap Scan

A read-only sweep was conducted across sibling lanes located under `/home/vgpnk/Projects/shokunin/` searching for existing offline recheck/replay/capture-verify gate patterns (`recheck`, `replay`, `capture`, `drift`).

### 2.1 Sibling Instruments Identified

1. **`kasegi-shokunin`**
   - **`corpus/instruments/source-recheck.py:4-18`** (`fd2e01e88c8c45a949f48d67b3154ae87a95aeba0b6a9c42fbf64641b5b9c003`): Re-checks pinned quotes against checked-in source snapshots (`corpus/source-snapshots/`) using normalized text matching and anchor verification (`anchor=N-ok`). Does not inspect markdown `recheck:` command lines.
   - **`corpus/instruments/recheck-audit.py:4-19`** (`451047eacdc979b0ee972d0637aea9911634232e61210e68094d04e7ab016416`): Audits every `recheck:` line in `corpus/knowledge/*.md` to ensure it is executable, cwd-independent (`bash -n`, foreign cwd test), and references valid repository paths. It verifies command invocability, but does not parse pipeline stages or substitute fetches with local capture replays.
   - **`corpus/instruments/capture-binding-check.py:2-12`** (`6a241ba0e8c8a1fe48bb1528cb619a99818817cb25e2e4b48192a95c97750ee3`): Hardens snapshot manifest records against `corpus/SOURCES.md` registry rows, enforcing URL equality and detecting orphaned captures.
2. **`kake-shokunin`**
   - **`scripts/source_recheck.py:4-15`** (`2ce8c0d9a43bd18bf0b718299eab91ce5839556f006382194c8bd5f418687e1a`): Offline source re-check of recorded fetches; reads manifest and body files to check whether quoted text is still present, enforcing strict input caps (16 MiB body cap, 64 MiB manifest cap) and HTML text decoding. Manifest-driven, not knowledge-line-driven.
3. **`kengaku-shokunin`**
   - **`plans/round80_c1_located_replay.py:8-18`** (`09c39f93a5fcbb283303354761a3e826ac56f61b5eb1ae2cbc9a718b38b6c184`) & **`plans/round100_c1_replay.py:5-23`**: Offline located replay for benchmark grader probes (`tb2-*`), reproducing receipt stdout blocks from frozen fixtures under `bwrap` sandboxing. Domain is benchmark reproduction, not knowledge citation recheck.
4. **`kotodama-shokunin`**
   - **`tools/check-gate-captures.py:2-22`** (`1bea70ee1da0dd1a8b5555657cc905771809734dcafbaac45103544029019a98`): Verifies Gate-table lesson rows bind directly to named capture files matching sha256 digests.
   - **`tools/check-sources-recheck.py:2-10`**: Recheck cadence auditor for `SOURCES.md` registry rows (`NNd`, `ISO date`, `on-release`).
5. **`tsukuroi-shokunin`**
   - **`tools/check-recheck-commands.py:2-12`** (`1c6f349d4c298a3867c7163c7c3fb32f1c768adb0df7110fc7b216a4656b8cd1`): Audits `recheck:` lines in `corpus/knowledge/*.md` to ensure they do not invoke forbidden host-mutating binaries (`pacman`, `yay`).

### 2.2 Overlap and Duplication Analysis

- **Does another lane hold this capability?** No. No sibling lane possesses an offline recheck replay gate that parses shell pipeline filter commands (`curl ... | grep -c`, `curl ... | pdftotext ... | grep -c`, `curl ... | rendered-text-v1.py locate`) directly from column-1 `recheck:` lines in knowledge markdown documents, replaces the `curl` fetch with an authenticated committed body capture registered in a manifest, executes the real pipeline filters on that capture, and asserts the replayed count equals the stated `-> N`.
- **Does kagi's implementation overlap or duplicate?** No duplication. Instead, kagi synthesizes established fleet patterns:
  - From `kasegi`: Registry row binding (`SOURCES.md` row validation) and knowledge `recheck:` line harvesting.
  - From `kake`: Hermetic offline execution without network contact and refusal of credential-shaped tokens (cookies).
  - From `kotodama`: Explicit sha256 binding of committed capture files.
- **Unique capability:** Kagi's `corpus/recheck-replay.py` specifically addresses stated-clock divergence (lesson M55-2, where a stated expectation `-> 1` was permanently false against the live body, masking genuine upstream drift). It provides offline falsifiability for stated counts across 8 knowledge entries and 10 clocks.

---

## 3. Change 2: Considerthese Mining (`considerthese/2026-10-26.md`)

`kagi-shokunin/considerthese/2026-10-26.md` was read in full. It reflects on the lane's idle period under the round-28 documentary close and policy HOLD.

### 3.1 Unimplemented Proposals Relevant to Freshness / Corpus Hygiene

1. **`considerthese/BACKLOG.md`** (`considerthese/2026-10-26.md:64-65`, carrying `2026-10-24.md:38-43`):
   - *Proposal:* "Create `considerthese/BACKLOG.md` (carried from 2026-10-24). Stop re-listing a stale backlog; keep a single tracked list instead (first proposed, status, last touched)."
   - *Relevance to corpus hygiene:* Prevents suggestion rot, unmaintained 8-day carry-overs, and status drift in `considerthese/`.
   - *Status:* Still unimplemented (`test -e considerthese/BACKLOG.md` exited rc 1, file does not exist; receipt `.ufo/waves/round-56/w1/R56Connector.d/considerthese_check.txt`).
2. **`op` release clock on the dotenv contract** (`considerthese/2026-10-26.md:43`, carried from `2026-10-22.md`):
   - *Proposal:* Tie the 1Password CLI `op` dotenv parsing behavior documented in `corpus/knowledge/op-ref-consumption.md` to an official release clock feed so upstream parsing changes or new releases are detected automatically.
   - *Relevance to freshness:* Converts static byte-parsing observations into an actively watched release clock.
   - *Status:* Still unimplemented (no release clock for `op` exists in `corpus/release-clock.py`).
3. **Mark known-defective instrument output** (`considerthese/2026-10-26.md:60-63`):
   - *Status:* Already grounded by round 29 (D1 closure with `feed-token-agree.py`) and recorded in `corpus/QUALITY.md` under criterion QM55.

### 3.2 Proposal Named for Grounding

**Named Proposal:** **`considerthese/BACKLOG.md`** (`considerthese/2026-10-26.md:64-65`).  
*Grounding rationale:* As part of round 56's frontier step ("frontier curation, mistake mining", `plans/round-56.md:29-33`), creating `considerthese/BACKLOG.md` directly curates the reflection backlog, resolving carry-overs that have sat ungrounded across rounds without mutating frozen C1 production code or invalidating pre-freeze controls.

---

## 4. Change 3: Check `corpus/QUALITY.md` for a Criterion the Replay Gate Misses

An audit of `corpus/recheck-replay.py` (`sha256: b7782f35...`) against `corpus/QUALITY.md` (`sha256: c4f35d07...`) reveals a clear, direct gap:

### 4.1 Missed Criterion: **QM56** (`corpus/QUALITY.md:239`)

> **Criterion QM56:**
> *"A counter that reads a locator, census or other instrument gates its value on that instrument's exit code, not only on the lines it prints. A SETUP exit with no failure lines reads as zero failures, and a counter that subtracts failure lines from a row count then passes every row."*  
> *Weak signal:* *"a located-quote counter scoring every added row as located when `quote-locate.py` exits 2 with no NOT-LOCATED lines (reviewer F-1, critic D-5; caught before any candidate was scored, `plans/round-45.md` A1-2)"*  
> *Lesson cited:* `corpus/lessons/round-45.md` §Mistakes M45-2; `plans/round-45-c2.sh`.

### 4.2 How `corpus/recheck-replay.py` Misses QM56

In `corpus/recheck-replay.py:176-202`, `replay()` dispatches three filter kinds:
1. `grep` (lines 180-183):
   ```python
   res = subprocess.run(["grep", "-c", "-e", arg, str(body)], capture_output=True, timeout=60)
   if res.returncode not in (0, 1):
       return None, "grep-rc%d" % res.returncode
   return int(res.stdout.strip() or b"-1"), None
   ```
   *Gates return code: `res.returncode in (0, 1)`.*
2. `pdf` (lines 184-191):
   ```python
   txt = subprocess.run(["pdftotext", "-layout", str(body), "-"], capture_output=True, timeout=120)
   if txt.returncode != 0:
       return None, "pdftotext-rc%d" % txt.returncode
   res = subprocess.run(["grep", "-c", "-e", arg], input=txt.stdout, capture_output=True, timeout=60)
   if res.returncode not in (0, 1):
       return None, "grep-rc%d" % res.returncode
   ```
   *Gates return codes: `txt.returncode == 0` and `res.returncode in (0, 1)`.*
3. `locate` (lines 192-197):
   ```python
   res = subprocess.run([sys.executable, "-I", "-B", str(root / "corpus/rendered-text-v1.py"),
                         "locate", str(body), arg], capture_output=True, timeout=120)
   m = re.search(rb"RENDERED_TEXT_V1_LOCATE: count=(\d+)", res.stdout)
   if not m:
       return None, "locate-output"
   return int(m.group(1)), None
   ```
   **The flaw:** `res.returncode` is NEVER inspected!  
   Per `corpus/rendered-text-v1.py:59`, `locate` exits:
   - `0`: count >= 1
   - `1`: count == 0
   - `2`: SETUP (undecodable UTF-8, unreadable file, usage error)

When `rendered-text-v1.py locate` encounters invalid UTF-8 bytes (demonstrated in `.ufo/waves/round-56/w1/R56Connector.d/quality_gap_qm56.txt`), it exits rc 2 with `RENDERED_TEXT_V1: SETUP (not strict UTF-8)`. `recheck-replay.py` does not check `res.returncode not in (0, 1)`: it falls through to `if not m: return None, "locate-output"`, misattributing a tool setup/crash error as an output format mismatch. Furthermore, if a mutated or wrapper locator emitted a match line before aborting with rc 2, `recheck-replay.py` would silently accept the count and score it as valid, violating QM56.

### 4.3 Additional Structural Check Gap: **QM53** (`corpus/QUALITY.md:236`)

`recheck-replay.py:manifest()` (lines 124-146) parses `corpus/recheck-captures.tsv` by iterating over non-blank lines without checking total row count against expected clocks, and without rejecting unterminated trailing lines. A capture row present in the manifest but omitted from all knowledge clocks is silently ignored.

---

## 5. Bounded Connector Move: Compatible Synthesis

### 5.1 Proposed Move
Synthesize the sibling pattern (`kasegi`'s strict tool exit verification), the mined proposal (`considerthese/BACKLOG.md`), and the QM56 gap repair:

1. **Harden `corpus/recheck-replay.py` for QM56 compliance:**
   Insert the missing returncode validation before parsing output:
   ```python
   if res.returncode not in (0, 1):
       return None, "locate-rc%d" % res.returncode
   ```
   Add a 14th selftest case to `corpus/recheck-replay.py:selftest()` verifying that a locator invocation on an invalid UTF-8 capture triggers rc 2 and is reported as `TOOL ... reason=locate-rc2` rather than `locate-output`.
2. **Ground `considerthese/BACKLOG.md` in the round-56 frontier step:**
   Seed `considerthese/BACKLOG.md` with the 4 proposals from `2026-10-26.md`, documenting the resolution of Proposal 3 (QM55), the grounding of Proposal 4, and tracking open proposals (`op` release clock) with first-proposed dates and status.

### 5.2 Affected Axes
- **`freshness` (improves):** Prevents locator crashes or encoding faults from being masked as output format anomalies or invalid clock counts; guarantees quote locator execution integrity.
- **`adjacency` (improves):** Aligns kagi's tool exit gating with sibling standards (`kasegi` and `kake`).
- **All other axes (`operability`, `discernment`, `depth`, `calibration`):** Strictly non-harmful (improves diagnostic accuracy without altering contract semantics).

### 5.3 Second-Order Effects & Risks
- **Runtime surface:** `recheck-replay.py` runs with identical wall time (~1.2s for 10 clocks).
- **Kill-rule boundary:** In `plans/round-56.md:17`, the kill rule enforces immutability on `plans/round-56.md`, `plans/round-56-c1.sh`, and `plans/round-56-controls.sh`. Updating `corpus/recheck-replay.py` does not touch those three files. However, `plans/round-56-controls.sh:67` embeds a printer-gate control expecting `13 cases` in `--selftest`. If a 14th selftest case is added during wave 1, control `K1-F5` could fail unless preserved or routed to wave 2 / candidate landing.
- **Contract compatibility:** `plans/round-56-c1.sh` checks for `RECHECK_REPLAY: CLEAN` and `RECHECK_REPLAY_SELFTEST: PASS`. As long as selftest passes, C1 predicate evaluation is unaffected.

### 5.4 Verification
1. Run `python3 corpus/rendered-text-v1.py locate <non-utf8-file> needle` -> rc 2, confirmed.
2. Under the patched gate, assert `recheck-replay.py` reports `TOOL ... reason=locate-rc2`.
3. Check `test -f considerthese/BACKLOG.md` -> rc 0 once committed.

---

## 6. Verification Receipts & Files

- **Report:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-56/w1/R56Connector.md`
- **Receipts:**
  - `.ufo/waves/round-56/w1/R56Connector.d/gate_run.txt` (rc 0, 10 MATCH lines, `RECHECK_REPLAY: CLEAN`)
  - `.ufo/waves/round-56/w1/R56Connector.d/gate_selftest.txt` (rc 0, 13 PASS cases)
  - `.ufo/waves/round-56/w1/R56Connector.d/quality_gap_qm56.txt` (rc 0, demonstrates rc 2 on non-UTF-8 input)
  - `.ufo/waves/round-56/w1/R56Connector.d/considerthese_check.txt` (rc 0, confirms absence of BACKLOG.md)
  - `.ufo/waves/round-56/w1/R56Connector.d/sibling_scan.txt` (rc 0, headers of sibling tools)
- **Scratch:** `/fast/scratch/hyaku/kagi-r56/R56Connector/` removed prior to task yield.
