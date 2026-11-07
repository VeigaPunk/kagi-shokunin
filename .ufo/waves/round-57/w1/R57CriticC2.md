# R57CriticC2 — C2 (OpenBao audit-device custody trial) attack report

Seat: R57CriticC2 (critic, C2). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`, claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`.
Report only; no production edit. Scratch `/fast/scratch/hyaku/kagi-r57/R57CriticC2/` deleted before yield.

Snapshot of the audited state (all commands below run against it):

| item | revision / sha256 | note |
|---|---|---|
| predeclaration (epoch A) | `7aa1f47` | plan `5773c1a4…`, c2 `3de6b4de…`, controls `6796ae70…` |
| freeze epoch B | `03cbf65` (2026-11-07 11:20:45 −0300) | plan `b130bb83…`, c2 `140a8f2b…`, controls `09f334cb…`, epoch-B receipt `707a5320…` |
| landing (C2 admitted) | `d857f34` | trial `7e64519466bfd7baf51f66d4bc71da09f30845d41d0fb10f36fcf24eec5b0bd3` (10922 B), entry `c9492597…`, c2 counter `140a8f2b…` |
| trial superseded | `3e8bcc4c3993980ca41f7781f2fb8f2b8ca19b9a4257b08b70ac79d8e61487fb` (10674 B) | argv-leaking draft, documented in the landed entry's provenance paragraph |
| binary | OpenBao v2.7.2 (`9e0a0d3c…`), `sha256 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` | `/home/vgpnk/.local/bin/bao` |
| answering model (observed label) | `amr/deepseek-v4.1-flash` | stated, not guessed |
| tools/versions | bash 5.x, python3 3.14, GNU grep, iproute2 `ss`, `setpriv`; no installs, no pacman | all in `/usr/bin` |

Counter reading on the landed tree (`git archive d857f34` → scratch; `bash plans/round-57-c2.sh --tree <tree>`):
`C2_AUDIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=5/5 guard=1 (real=1 none=1 wrap=1 secret=1)`, rc 0
(receipt `counter-landed-d857f34.txt`). The landed trial's own run: `OPENBAO_AUDIT_TRIAL: HOLDS holds=5
broken=0 error=0 bao=v2.7.2`, rc 0 (receipt `trial-real.txt`).

## Per-attack verdicts

### (a) A PASS-printer that ignores the mechanics

- New-grammar STUB (prints `TRIAL T<n> HOLDS`, summary, exit 0; ignores `KAGI_AUDIT_SHIM`):
  `bash plans/round-57-c2.sh --tree <stub tree>` → `value=0 … shims=0 vectors=0/5`, rc 1
  (`stub-recording.txt`). Caught: a printer that does not honour the shim variable earns nothing.
- Zero-mechanics shape-keyed MOCK (prints the five designated vectors, the summary, and flips T1
  when the PATH-resolved `bao` is not the pinned binary): **`value=5 … vectors=5/5 … wrap=1`,
  rc 0** (`mock-shape.txt`). It executes **zero** `bao` commands (recording-wrapper count
  unchanged at 21→21, `stub-recording.txt`). This is the surviving hole: the counter's five is a
  statement about the trial's printed shape, not about the server.
- Counter's reading: value=5 in both the honest and the mock case. The counter cannot tell them
  apart; only a non-author re-derivation (or an invocation-recording leg) can.

### (b) A shim that breaks two tests or none

- None: the vector is `HHHHH` for that shim → `shims` does not increment → value 0 (STUB run above).
- Two: the FAIL line reports `pass=4` only because the **trial itself** counts its tests; the
  counter parses the five `TRIAL T<n>` lines and the summary, never the test internals. A trial
  that actually breaks T2 and T3 but prints the designated `HBHHH` vector is indistinguishable
  from one that breaks only T2. The M2 mock is the extreme (breaks all five, prints five
  vectors). The exact-one property is a property of the trial's own accounting, not of the counter.

### (c) T4's salt claim — can a fresh server reproduce an equal HMAC by accident?

- Two fresh dev servers, same input, same device path: different HMACs (`fresh-server-salt.txt`:
  `server1=hmac-sha256:2d0e190c… server2=hmac-sha256:e16a167f… equal=0`). The salt is random per
  device instance; accidental equality needs equal salts (≈2^-256) or an HMAC collision.
- Same instance, `bao audit disable file/` then re-enable at the same path: the same input's
  `sys/audit-hash/file` value changes (`trial-real.txt` T4: `same-input-same-hash=0`). The doc
  sentence ("a new salt will be created") holds on the API path.
- Verdict: no accidental-equality hole. Bounds: one binary, dev in-memory storage; the trial
  measures the hash oracle, not a line-by-line comparison of two log files (the entry states this).

### (d) T5's non-audited claim — does `bao status` really skip audit?

- `TRIAL T5 HOLDS seal-status-entries=0 kv-entries=4 log-grew=4` (`trial-real.txt`).
- The literal used by the trial is correct: `grep -cF '"path":"sys/seal-status"' audit.log` = 0
  while `'"path":"secret/data/t2"'` = 4 on the same compact-JSON log (`t2-decomp.txt`).
- Verdict: holds for `bao status` as a whole command (zero log bytes), not just for the named
  path. Precision note: `kv-entries=4` counts the earlier put as well; the window proof is
  `log-grew=4` (the KV read's request+response plus the mount-lookup pair). Smallest precision
  fix: count the *delta* of `secret/data/t5` request entries between the before/after snapshots.

### (e) T2/T3 plaintext scan — encoded or truncated forms that evade it

- JSON escaping is real: a probe value containing `<`, `>` and `&` in the `log_raw=true` device is
  written JSON-escaped (`\u003c`, `\u0026`, `\u003e`); a literal `grep -F` finds **0**, the escaped form **2**, and
  JSON-decoding the request body finds the exact value **1** (`json-escaping.txt`). In the default
  device: literal 0, escaped 0.
- Consequence: for a value containing `<`, `>`, `&`, the trial's literal raw-positive scan would
  report BROKEN even though the raw device did log the value; and a literal *negative* scan could
  miss an escaped plaintext leak. The trial's nonce is `r57-<hex24>` (JSON-safe), so the landed
  trial is not affected. Bound the claim to the nonce shape, or JSON-decode the scan.
- Truncation / very long values were not exercised (unrun; see the unrun list).

### (f) Missing tool and port-collision behaviour (rc2 path)

- No `bao` on PATH: the trial prints `OPENBAO_AUDIT_TRIAL: SETUP no bao on PATH` and exits 2
  (`missing-tool-port.txt`); the counter's `none` leg reads `none=1` (`counter-tree.txt`).
- Occupied port: `bao server -dev -dev-listen-address=127.0.0.1:<busy>` exits 1 with
  `bind: address already in use` (`missing-tool-port.txt`); the trial probes a fresh port, checks
  with `ss -Hltnp` that the listener belongs to its own server pid, and retries three times. A
  forced collision-race was not exercised; the failure path is retry, then SETUP rc2.
- Unrun: missing `ss`/`setpriv`/`python3` (source inspection shows the same SETUP rc2 path; the
  counter only removes `bao`).

### (g) Secret hygiene — argv, logs, receipts, stdout

- Current landed trial `7e6451…`: 21 `bao` invocations, **0** value-shaped argv; 15 `grep`
  invocations, **0** value/token-shaped argv; trial output contains 0 token/value shapes
  (`argv-current.txt`). `bao write … sys/audit-hash/file -` with the value in a JSON body on
  stdin produces the same hash as the argv form (`body-stdin.txt`: `equal=1`), and
  `grep -cF -f -` reads the pattern from stdin.
- Superseded draft `3e8bcc4c…` (10674 B): the landed entry records that it "placed the
  audit-hash input and the token-pattern on `grep`/`bao` argv"; my measurement of that draft
  before the 11:25:22 fix counted `bao value-on-argv=5` (five `write` calls) and
  `grep secret-shaped-arg=5` (T2 value, T3 value ×2, T3 token ×2). That draft would have
  violated the plan's `no secret on any argv` POP precondition and the trial's own header
  sentence, and the counter still read 5: the counter's hygiene sweep (`nosecret`) scans only
  the trial's captured output, never argv.
- Verdict: the landed trial is clean; the *counter* cannot detect an argv regression. The entry
  documents the history honestly.

## Surviving holes, ranked, with the smallest safe correction

1. **`value=5` is not evidence of the mechanics (M2).** A zero-mechanics trial that prints the
   designated vectors and inspects `command -v bao`/`readlink -f` scores 5. The epoch-B named
   ceiling is mis-stated: "a trial that resolves bao by absolute path … can pass (the wrapper leg
   does not reach it)" is false — M1 (absolute-path, no introspection) reads **0** because the
   wrap run then prints `HHHHH` instead of `BHHHH`; the *actual* exploit is PATH introspection,
   not absolute-path resolution.
   *Smallest fix:* correct the ceiling sentence to the measured mechanism and treat value=5 as
   necessary-but-not-sufficient. Add the new-grammar mock as the named-ceiling control (expected
   5), and/or add a recording-wrapper leg: a PATH `bao` wrapper that logs every invocation's
   subcommand/path (no args) and argv secret-shapes, with the counter asserting the expected
   call sequence (`server` ×2, `audit enable/list`, `write sys/audit-hash`, `kv put/get`,
   `audit disable/enable`, `status`) and zero secret-shaped argv. A zero-mechanics mock has an
   empty invocation log (21 vs 0 measured); the current trial's log has 21 calls.
2. **The epoch-B control battery does not contain the new-grammar mock.** K2-MOCK in
   `controls-prefreeze-epochB.txt` is the *old-grammar* printer (`AUDIT_TRIAL: CLEAN…`); it
   reads 0 because the parser now expects `TRIAL T<n>`, not because the counter rejects a
   shape-keyed A1 mock. The plan's sentence "both false-green shapes are now rejected" is
   therefore not demonstrated. *Smallest fix:* add `K2-MOCK-A1` (the M2 shape, expected 5 as the
   declared ceiling) to the next battery and receipt; do not claim rejection.
3. **Freeze provenance, epochs A→B→C.** Epoch B is committed (`03cbf65`) before the landing
   (`d857f34`), and the plan's Amendments section names A1/A2 and the epoch-A supersession — so
   the C2 predicate was committed before the landing measurement. But the *same paths* were
   amended in place (the wave instruction says not to); epoch A's receipt (`bb5c6093…`) binds
   hashes that no longer exist in the tree and its K2-MOCK=5 no longer reproduces (I re-ran the
   frozen controls: `INSTRUMENT 140a8f2b… / 09f334cb… / b130bb83…`, `K2-MOCK expect=0`).
   *State:* acceptable only because epoch B is committed and documented; epoch A must remain
   labelled as superseded in LOG/lesson (the plan already says so in the pre-freeze section).
4. **Post-landing epoch-C attempt is aborted and uncommitted (live).** The working tree now has
   `plans/round-57-c1.sh` `6fcbdec7…` (A3: census pin, gate sha256 pin, forged-tree challenge)
   and `plans/round-57-controls.sh` `ef6b99fa…` (A3: K1-F8/F9), plus untracked
   `.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt` (11:31). That receipt **ends in a
   Python traceback** (`AssertionError:  \`--selftest\` 20 cases;` in the K1-F8 fixture), has no
   `CONTROLS:` line and no K2 lines: it cannot bind A3. The fixture is built with `mk_base` from
   BASE, whose SCORECARD says 18 cases, not the landed 20. *Smallest fix:* build K1-F8 from the
   landed tree (or delete the BASE strings), re-run to `CONTROLS: match=N mismatch=0`, and commit
   epoch C before using it; do not commit the aborted receipt. (C1-adjacent, same instrument set,
   L1-owned.)
5. **T2's plan wording vs the measured shape.** The landed entry is precise ("request and
   response echo"; the write's response *entry* echoes the request), but the plan's POP still says
   "request and response (the same hash twice)" for a KV write. Measured decomposition
   (`t2-decomp.txt`): h1 appears in `/request/data/input` (the `sys/audit-hash` request entry and
   its response entry's echoed request), `/request/data/data/v` (the write's request entry and its
   echoed response), and `/response/data/data/v` (a subsequent **read**'s response body). The
   write's response *body* does not carry the value hash. *Smallest fix:* align the plan sentence
   with the entry; assert the field path (`request.data.data.v`) in the trial instead of a
   whole-log count.
6. **Literal plaintext scan.** JSON-escaped forms evade it (section e). The landed nonce is safe;
   bound the claim or JSON-decode. Not a blocker for the landed trial.
7. **T5 positive control redundancy.** `kv-entries` counts the pre-window put; the window evidence
   is `log-grew`. Count the window delta instead. Not a blocker.
8. **The landing commit swept a seat's in-progress receipts (false provenance).** `d857f34`
   contains `.ufo/waves/round-57/w1/R57CriticC2.d/` files as they stood at 11:28–11:29,
   including `counter-tree.txt` committed as a single `cmd:` line **with no reading** (the reading
   was appended after the commit; `git diff` now shows the +2 lines). A reader of the landing
   would see a receipt with no result. *Smallest fix:* a follow-up commit with the completed
   receipts and this report; in the landing procedure, stage seat `.d/` trees only after the seat
   reports, or exclude in-progress seat dirs. Evidence: `landing-hygiene.txt`.

## What this does not establish (unrun)

- No real vault, no deployed sink, no policy/identity; all servers were throwaway `bao server -dev`
  on 127.0.0.1 with `setpriv --pdeathsig KILL`, output discarded, in-memory storage.
- Not exercised: a forced port-collision race in `start_server`; missing `ss`/`setpriv`/`python3`;
  a value larger than one audit entry / truncation; socket/syslog devices; blocked/blocking audit
  semantics; non-dev storage; the config-managed (declarative `audit` stanza) route beyond the
  entry's second-hand labrat note.
- The M2 mock's five is the counter's **named ceiling**, not a defect of the landed trial: the
  landed trial's mechanics were independently measured (T1 refusal+flag, T2 HMAC form/stable/
  distinct/plaintext 0, T3 raw value 7 + token 17, default 0/0, T4 rotation, T5 status 0/log grew).

## Receipts (`.ufo/waves/round-57/w1/R57CriticC2.d/`)

- `counter-landed-d857f34.txt` — counter on the landed tree: `value=5 … vectors=5/5`, rc 0.
- `counter-tree.txt` — counter on the working tree at 11:29, same reading.
- `trial-real.txt` — landed trial run: T1–T5 HOLDS, summary, rc 0.
- `mock-shape.txt` — M2 (wrap-detecting zero-mechanics mock) `value=5`, rc 0; M1 (absolute-path) `value=0`, rc 1.
- `stub-recording.txt` — new-grammar STUB ignoring shims `value=0 … vectors=0/5`, rc 1; M2 mock under the recording wrapper: 21→21 `bao` invocations (zero).
- `argv-current.txt` — landed trial: 21 `bao` calls, value-on-argv 0; 15 `grep` calls, secret-shaped argv 0; output secret-scan 0.
- `body-stdin.txt` — `bao write … sys/audit-hash/file -` body-on-stdin hash equals the argv form.
- `t2-decomp.txt` — h1 entry/field decomposition (7 occurrences) and the T5 path literals.
- `fresh-server-salt.txt` — two fresh servers, same input: `equal=0`.
- `json-escaping.txt` — raw literal 0 / escaped 2 / decoded 1; default 0/0.
- `missing-tool-port.txt` — occupied port `bao server` rc 1 `bind: address already in use`; no-bao trial rc 2 `SETUP no bao on PATH`.
- `instrument-state.txt`, `freeze-epochB.txt`, `gate-pin.txt` — hashes, mtimes, committed blobs, epoch B commit, A3 gate pin (`e36472b3…` matches the landed `corpus/current-claims.py`).
- `landing-hygiene.txt` — the seat receipts that `d857f34` contains, and the committed `counter-tree.txt` with no reading (the working tree adds it).

## Verdict

The C2 **capability** (the five audit-device mechanics on OpenBao 2.7.2) is real and was measured
independently here and by the second seat: admit the entry and the trial. The C2 **counter's
value=5 is not self-authenticating**: the named ceiling must say so with the measured mechanism
(PATH introspection, not absolute-path resolution), and the next battery should carry the
new-grammar mock control and/or a recording-wrapper invocation leg. The landed trial is
argv-clean; the superseded draft was not, and the counter's sweep could not see it. Do not commit
the aborted epoch-C receipt; fix K1-F8 before any epoch-C claim.
