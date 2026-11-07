# R52ReviewerTrial — correctness review of the reference C1 trial

Seat: `R52ReviewerTrial` (leaf; no subagent dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`, BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`.

Subject: `.ufo/waves/round-52/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh` (203 lines,
sha256 `3b0b0f812a978a99af85828f0382a41418712143a5e5fb9c09b5af2b348554af`). The lane's untracked
`corpus/openbao-kv-versions-trial.sh` is byte-identical (same sha256, `diff -q` empty), so the
kill-rule comparison holds at review time.

Environment: OpenBao `v2.7.2 (9e0a0d3c…)` at `~/.local/bin/bao`, sha256 `9c5f3628…b788` (the counter
pin); bash 5.3.20; iproute2 `ss` 7.3.0; `setpriv --pdeathsig KILL` supported.

Method: every run executes a copy of the fixture in `/fast/scratch/hyaku/kagi-r52/R52ReviewerTrial`
under `env -i`, each server a throwaway `bao server -dev` on a random 127.0.0.1 port, killed before
exit. Malformed client answers were injected with a dispatcher named `bao` that logs `$*` and then
execs the pinned binary (the same technique as the counter's SH shims; named ceiling: client-side).
No token or nonce value appears in this report or in `build/R52ReviewerTrial/receipts.txt`.
No language server answers a shell script in this session; shell semantics were checked by execution,
not by LSP. Text grep was used only for file line numbers.

Receipts: `.ufo/waves/round-52/build/R52ReviewerTrial/receipts.txt` (§R1–R8). The scratch scripts
(`trial.sh`, `dispatch`, `sigtest.sh`, `probe.sh`, `probe2.sh`, `stubborn.sh`, `mkreceipts.sh`) are in
the scratch dir named above.

Baseline: `bash trial.sh --work …` → T1–T5 all HOLDS, `OPENBAO_KV_TRIAL: HOLDS holds=5 …`,
rc 0, empty stderr, no leftover scratch dir (R1). The five shim-falsifier vectors were not
re-measured as a set (only the real path and individual shims); the frozen pre-freeze receipt
(`controls-prefreeze.txt`, K1-P) covers the full vector.

**Verdict: no false HOLDS found.** T1–T5 each require their mechanic's observable, and the
canonical falsifiers (SH1–SH5) produce BROKEN in the designated test only (pre-freeze K1-P, and my
per-shim runs agree where they overlap). Five defects follow, all in classification, cleanup and
comment accuracy; none blocks C1 as frozen, but D1 breaks the trial's own parse contract, D2 leaves
the entry's "accepted" clause unmeasured, and D3 can hang a run.

---

## Defects, by severity

### D1 (medium-low) — the "answer does not parse → ERROR (3)" path is incomplete; a malformed JSON answer is recorded as BROKEN in T4/T5 and prints Python tracebacks

**Lines:** getv body 109–114 (the `try/except` covers only `json.load`; the extraction at 113 is
unguarded); consequences at 179 (T4) and 196 (T5); the same answer is ERROR at 135 (T1) and 150 (T2).

**What.** `getv` documents (107–108) and the header states (22–23) that an answer that does not parse
is `ERROR`, never a refusal. The implementation returns 3 only when `json.load` raises. A document
that *is* JSON but not a KV answer escapes the guard:

- top-level non-object (`[]`, `"x"`, `5`, `null`): the extraction at 113 raises `AttributeError` →
  python exits 1 and prints a traceback to the trial's stderr; `getv` returns 1, not 3.
  T1/T2/T3 treat any non-zero rc as ERROR (135, 150, 165), but T4/T5 test only `-eq 3` (179, 196), so the
  run states `TRIAL T4 BROKEN version1-dropped=0 …` — a server-behaviour claim produced by a
  client-side parse crash.
- `{"data": []}`: the `or {}` fallbacks at 113 turn it into an empty value with rc 0, so
  `refused` never fires and T1/T4/T5 report BROKEN with an empty value.

**Reproduction (R2, modes `arr`, `shape`, `notjson`, `empty`).**
`arr` → `T1 ERROR read-failed(rc=1)`, `T2 ERROR read-failed(state=3 get=1)`, `T3 ERROR
read-failed(state=3)`, **`T4 BROKEN version1-dropped=0 …`**, **`T5 BROKEN version1-gone=0 …`**,
7 `Traceback` blocks on stderr, summary `ERROR holds=0 broken=2 error=3`.
`shape` → **`T1 BROKEN`**, **`T4 BROKEN`**, **`T5 BROKEN`** (rc 0 with an empty value).
`notjson`/`empty` → all five ERROR with rc 3 (the intended path works for genuine
non-JSON/empty answers).

**Why it matters.** The five tests disagree about the same client anomaly, and T4/T5 can accuse the
server of not implementing max-versions / metadata-delete when the client merely returned a shape it
cannot read. No false HOLDS, but the trial's documented parse-failure contract is violated.

**Fix (fixture frozen; not applied).** Wrap the extraction in the same `try/except → sys.exit(3)`;
alternatively, in T4/T5 treat "non-zero rc that is not a `refused` match" as ERROR. A shape check
(`isinstance(d, dict) and isinstance(d.get("data"), dict)`) covers the rc-0-empty half.

### D2 (low) — T3 and T5 discard the `kv undelete` exit status, so the entry's "is accepted" half is never measured

**Lines:** T3 163 (`bao kv undelete … >/dev/null 2>&1`, rc dropped); T5 191 (same); contrast T2 148,
which captures `ur` and requires `ur = 0` at 151.

**What.** The knowledge entry's Measured T3 line (line 49 of
`corpus/knowledge/openbao-kv-v2-version-lifecycle.md`) says "after `kv destroy -versions=1` an
`kv undelete -versions=1` is accepted but restores nothing". The trial checks only the second half.
A server/CLI that **refuses every undelete** is indistinguishable from one that accepts it and
restores nothing: T3 and T5 report HOLDS with an undelete rc of 2. T2 classifies the same failure as
BROKEN, so the trial treats one command's failure two ways. The T3/T5 details do not print the rc, so
a reader cannot tell which case was observed.

**Reproduction (R2, mode `nouref`; a shim where `kv undelete` exits 2 with a 403 text).**
`T2 BROKEN … undelete-rc=2 …`, **`T3 HOLDS`**, **`T5 HOLDS`**, summary `BROKEN holds=4 broken=1`.
Control on the pinned binary (R6): `kv undelete` after `kv destroy` → rc 0, 0-byte stderr, and the
state reads `data-null=1 deletion-time=0 destroyed=1`, so the entry's sentence is true for 2.7.2 even
though the trial does not discriminate it.

**Fix.** Capture `ur` and either require 0 for HOLDS (consistent with T2) or include
`undelete-rc=$ur` in the HOLDS/BROKEN detail so the observation is attributable.

### D3 (low) — the retry path's `kill "$SRV"; wait "$SRV"` is unbounded; a live, wedged server that ignores SIGTERM hangs the trial forever

**Line:** 87 (inside `start_server`, after the 30 s `ss` readiness window at 73–77). Cleanup
(44–56) does bound the same operation: SIGTERM, 50 × 0.1 s, then `kill -9`.

**What.** If the server process is alive but never listens (readiness fails), the code sends SIGTERM
and waits with no timeout. A server that ignores SIGTERM blocks `wait` indefinitely; the three-attempt
retry at 67 never advances and the SETUP path at 92 never runs.

**Reproduction (R7, mode `stubborn`: a `server ` stand-in that ignores TERM and never listens).**
At t=33 s and t=39 s the trial is still alive, `ps` state `S do_wait`, `server_calls=2` in the log
(the `version` probe plus one `server` call — no retry started), past the 30 s window. `kill -9` of
the trial ends it; the stand-in dies via `pdeathsig`.

**Operational bound.** The counter runs the trial as `timeout 600 bash "$TRIAL"` (round-52-c1.sh
`run()`), and a hung `kv get` under `timeout 8` exits 124 with clean cleanup, no leftover scratch dir
and no orphan server whose environ names the scratch tree (R2b) — so the counter caps the damage at
600 s per run, but a direct run can hang.
**Fix:** bound the retry wait exactly as `cleanup` does.

### D4 (low, inherent) — SIGKILL leaves the scratch directory behind

**Lines:** traps 57–60 (`EXIT`, `INT`, `TERM`, `HUP`) and `cleanup` 44–56; explicit cleanup call 202.

**What.** SIGKILL cannot be trapped, so `$D` is not removed. All trappable signals are clean:
`INT` rc 130, `TERM` rc 143, `HUP` rc 129, each with the server gone and `leftover_dirs=0`
(R5; the INT run had SIGINT's disposition restored to SIG_DFL first — a background job of a
non-interactive shell inherits SIG_IGN, which is a launch-context property, not a trap defect).
For SIGKILL: rc 137, server gone (`--pdeathsig KILL`), `leftover_dirs=1`.

**Secret exposure of the leftover (R8):** at t=1.2 s the only files under `$D` are `err` (0 B at
sampling) and `home/` (0 files; `-dev-no-store-token` and `HOME=$D/home`), all under `umask 077`.
The CLI's stderr names the URL/path and the server's error text, never the token or a value; the
values are only ever on stdin. So the leak is a directory, not a secret; the caller (the counter)
owns and removes its scratch tree.

**Fix:** none possible for KILL; document that the caller must clean `--work`.

### D5 (nit, non-behavioural) — the T1 header sentence overstates the mechanic

**Line:** 6 ("T1 check-and-set: a write is accepted only with cas = the current version"). A write
with no `cas` is accepted by 2.7.2, and the trial itself relies on that at 174 and 188
(`put secret/t4 …`, `put secret/t5 …` without `-cas`). The accurate sentence is the entry's: *if*
`cas` is set it must equal the current version. Comment only — the kill rule constrains non-comment
lines, and the entry's T1 text (entry line 40) is accurate.

---

## Areas with no defect (what was run)

**T1 HOLDS/BROKEN/ERROR logic (129–139): none.** Baseline HOLDS. Positive control `othererr`
(a 403 without the CAS text for every `-cas` put) → `cas0-refused=0 … cas-current-rc=2 stale-refused=0`
→ BROKEN (R2), so the helper does not treat an arbitrary non-zero exit as a refusal. The sequence
(cas=0 on an existing key refused → cas=current accepted as v2 → stale cas refused → read = v2 value)
is internally consistent and discriminates a dropped `-cas` (the pre-freeze K1-P receipt reads
SH1 → `BHHHH`, i.e. T1 BROKEN under SH1).

**T2 logic (143–154): none.** `vstate` is read before the undelete and expects `1 1 0`; `ur` is
required to be 0; the value must be restored. On the real binary (R6) a soft delete reads
`data-null=1 deletion-time=1 destroyed=0` with rc 0, and `get -version=1` after a soft delete is also
rc 0 — matching `vstate`'s rc-0 JSON path. A failing undelete is caught here (`nouref` → BROKEN with
`undelete-rc=2`, R2); the pre-freeze K1-P receipt reads SH2 (undelete lies) → `HBHHH`.

**T3 state check (159–168):** the state assertion itself is correct (destroy + undelete →
`1 0 1`; probe R6 agrees); only the ignored rc is D2.

**T4 logic (172–183): none beyond D1.** `metadata put -max-versions=2` then three cas-less puts;
version 1 refused with `No value found at`, versions 2/3 read their values. The pinned binary's
`get -version=1` after an in-place `destroy` returns rc 0 (`data-null=1 destroyed=1`, R6b), so T4's
`refused`-based check specifically measures "version absent from the version list" — which is what
max-versions does on 2.7.2 and what the entry records. SH4 (drop `-max-versions`) → BROKEN
(pre-freeze K1-P).

**T5 logic (187–198): none beyond D1/D2.** Metadata delete then both version reads and
`metadata get` refused; SH5 (metadata delete → delete latest) → BROKEN (pre-freeze K1-P).

**Refusal helper (106): none.** Requires non-zero rc **and** the fixed text; `$D/err` is truncated
by each `2>"$D/err"` redirect, so no stale text can satisfy a later check. `notjson` and `empty`
answers produce rc 3 → ERROR in all five tests (R2). The `othererr` control above shows a 403 with
the wrong text is not a refusal.

**Server start (65–91): none beyond D3.** Dev root token only via `BAO_DEV_ROOT_TOKEN_ID` (command
prefix, never argv); the client token via `BAO_TOKEN`; `-dev-no-store-token` leaves `HOME` empty
(R6: 0 files). The `ss` pid check works on this host: the listener line is
`LISTEN … users:(("bao",pid=<SRV>,fd=3))` and the trial's `grep "pid=$SRV,"` matches (R6). Failure
path: a `server` that exits immediately is retried 3× with a **fresh random port each time**
(45455 / 39499 / 53105, R4) and then `SETUP dev server did not start`, exit 2, `$D` removed (R2
`noserver`). The probe port is bound and closed before the server starts (TOCTOU), but the ss-pid
check converts a lost race into a retry, not a false success.

**Secret channels (argv, log, stdout): none.** A real run makes 31 `bao` calls and the argv log
(elements joined by US, the counter's NOARGV technique) carries 0 token/nonce-shaped hits (R3);
the sample shows `kv put secret/t1 v=-` and `server -dev -dev-listen-address=… -dev-no-store-token`
— no value, no token. Trial stdout/stderr contain no `r52-[0-9a-f]{24}` or token-shaped string
(R1, R5); `/proc/<server>/cmdline` is clean while the token is in `BAO_DEV_ROOT_TOKEN_ID`
(1 match in environ, R5); the server's own output is `/dev/null` (line 70). No value is ever
printed, including in BROKEN details (booleans only).

---

## Residual risk and verification gaps

- The full five-verdict shim vector was not re-measured as a set by this seat; the frozen
  pre-freeze K1-P receipt is the authority for EXPECT_VEC. I re-ran the real path (5/5 HOLDS) and
  the shims I needed for the findings.
- T4's discriminator is the CLI/API returning `No value found at` for a dropped version; on 2.7.2 a
  version that is *destroyed in place* still reads back rc 0 with `destroyed: true` (R6b). An
  implementation that destroyed v1 but kept its version entry would therefore read BROKEN in T4 —
  a named ceiling of the chosen observable, not exercised by the frozen falsifiers.
- The trial has no internal timeout; the counter's `timeout 600` is the outer bound (D3).
- The root token lives in the environment of each `bao` child (the S-1 design choice); it is
  readable by the same user via `/proc/<pid>/environ`, never via argv/log/stdout. If the lane's
  threat model widens to same-user `/proc` readers, the env channel itself would need review.
- `$D/err` (CLI stderr) is not scanned for secrets by the trial; the binary writes URL/path and
  error text only, and the file is 0600 under `umask 077` while it exists. The SIGKILL leftover is
  the only persistent copy (D4), and at the sampled moment it was empty.
- The lane's `corpus/openbao-kv-versions-trial.sh` is untracked at review time; identity with the
  fixture was checked by sha256. If the executor later edits it, the counter's kill rule (non-comment
  lines must match the fixture) is the gate, not this report.

SEAT-STATUS: complete
