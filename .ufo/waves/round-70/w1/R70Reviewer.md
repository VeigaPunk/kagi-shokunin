Author: R70Reviewer (reviewer)

# R70Reviewer — C1 freeze + measurement review
Round 70 attempt 1, wave kagi-r70-w1. Review target: frozen predicate/counter, freeze/candidate commits,
LANE base/candidate counter runs, control receipts vs announced expectations, P1-byte-identity and
shim-byte-read ceiling, candidate and frozen-control trial paths.

## Verdicts

### 1. Predicate identity + conjunct implementation — PASS
- plans/round-70.md §C1 frozen predicate (lines 24-25) vs plans/round-70-c1.sh header (lines 6-8): the
  extracted sentences are byte-identical strings; verified with python string comparison (EQUAL=True): 
  `C1_PKI_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and SOURCED = 1, else 0; target 5 (BASE 0).`
- PINS: counter line 41 pins `PIN_BAO=9c5f3628...b788`; line 63-64 `setup bao-missing` / `setup bao-pin-mismatch`
  and sets `pins=1` only after sha256 equality + non-membership in /usr/bin,/bin (line 66). Matches plan
  PINS definition in counter header lines 9-11. Host bao at ~/.local/bin/bao hashes to that pin.
- DISCRIMINATE + specificity: counter lines 140-146 implements per-test: NO? Actually `ok=1` requires
  `real HOLDS && shim_i BROKEN && spec=1 && entry=1`; specificity loop 144 checks all other shims j!=i
  report HOLDS (line 144); line 145 `ok=1` only on all four. `verdict()` (lines 109-114) counts exactly
  one TRIAL line per test (`NONE`/`DUP` fail). `entry_line()` (126-132) enforces `## Measured (round 70`
  section + `- T<n> ` + `OpenBao 2.7.2` on the line; knowledge entry at lines 34 and 40-44 satisfies it.
  Header lines 11-15 state same definition and the shims (17-22: SH1..SH5), as do plan §C1 prose lines 27-35.
- SETUP_OK: lines 120-122 — with no bao (bin/none) the trial must exit 2 AND print no `TRIAL Tn HOLDS`; sets
  setup_ok=1 only in that conjunction. Header line 23 matches.
- NOSECRET: line 149 greps concatenated run stdout/stderr for `PRIVATE KEY`, token ERE, `r70-[0-9a-f]{24}`;
  header line 24-25 matches.
- NOLEAK: `run()` (98-108) generates a per-run R70_C1_NONCE and after each run scans /proc environ for the
  nonce; `leak` toggles; line 150 `noleak=$((1-leak))`; header line 26-27 matches.
- SOURCED: lines 133-137 — entry `source:` line matches `^source:.*S170([^0-9]|$)`, and S170 SOURCES.md row's
  9th pipe column gsub-stripped equals `mined`; header lines 28-29 matches. Candidate SOURCES S170 row is
  `| S170 | ... | docs | A | ... | §Generate key ... | Quote "if it is internal..." | mined | 2026-11-08 | on-release | corpus/knowledge/openbao-pki-certificate-lifecycle.md |`; knowledge entry line 3 starts `source: S170 (...)`. Satisfied.
- Exit codes / fail-closed: line 70-72 absent trial -> `value=0 absent=1 pins=1` rc 1; lines 117-119 no final
  `OPENBAO_PKI_TRIAL: ` line -> `value=0 reason=real-run-no-final-line` rc 1; `setup()` (line 44) prints
  SETUP rc 2; final line 153 zeroes `final` unless setup_ok=nosecret=noleak=sourced=pins=1 and line 154-156
  exit 0 iff final=5 (header lines 30-33).
- Counter bytes: sha256 of plans/round-70-c1.sh at freeze 430cee2, candidate 0d22555 and worktree are all
  `8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed`, equal to
  `.ufo/waves/round-70/controls/receipts/counter.sha256`. Plan bytes also identical freeze vs candidate.
- Conjunction ordering verified: line 153 `final=$value; [...] || final=0` — gate fails closed on any zero leg,
  so even a discriminating=5 run cannot score when a leg fails (matches F5/F6 receipts).

### 2. Commit order and freeze purity — PASS
- `git merge-base --is-ancestor 430cee23eeb81ecf663015851e66332bf16f2a74 0d225553c22f686df24454040102d0502eda5c42`
  succeeds; freeze is an ancestor of the candidate.
- `git ls-tree -r --name-only 430cee2 -- corpus/openbao-pki-trial.sh corpus/knowledge/openbao-pki-certificate-lifecycle.md`
  is empty (rc 0): the freeze adds no lane `corpus/openbao-pki-trial.sh` and no lane knowledge entry.
- `git show 430cee2:corpus/SOURCES.md | grep -c S170` = 0: the freeze adds no S170 row at lane level.
  (It does add 3-line fixture SOURCES stubs under `.ufo/waves/round-70/controls/{p1,f1..f6,scaffold}/`.)
- Candidate `0d22555` adds the lane trial, knowledge entry, S170/S171/S172 rows, source-fetches rows and
  capture bodies — nothing before the freeze does.

### 3. Fresh counter reruns (this seat, two serial runs + base) — PASS
- Candidate `bash plans/round-70-c1.sh 0d225553c22f686df24454040102d0502eda5c42` (57.7s wall):
  `C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2 T1..T5:real=HOLDS,shim=BROKEN,spec=1,entry=1,ok=1`, rc=0,
  identical to `.ufo/waves/round-70/final/c1-candidate.txt` (byte-identical first line).
- BASE `bash plans/round-70-c1.sh 7bd34832c94b81d4cf9bf34113c4952a7f6d9b04`:
  `C1_PKI_TRIAL: value=0 absent=1 pins=1` rc=1 (matches controls receipt `f0-base.txt`).
- Base files saved to dir: `c1-candidate-rerun.txt`, `c1-base-rerun.txt` (+ `c1-f1-rerun.txt`, `c1-f2-rerun.txt`).

### 4. Control receipts vs frozen expected verdicts — PASS
Expected verdicts from plans/round-70-controls.sh header lines 6-8 (identical to plan §Prefreeze controls
lines 59-68). Each committed receipt under `.ufo/waves/round-70/controls/receipts/`:

| control | expected | receipt (rc) | observed value | leg detail (selected) | match |
|---|---|---|---|---|---|
| F0 base | `value=0 absent=1` rc1 | `f0-base.txt` | value=0 absent=1 pins=1 rc=1 | — | PASS |
| P1 | `value=5` rc0 | `p1.txt` | value=5 discriminating=5 all legs 1 rc=0 | ok=1 all T | PASS |
| F1 echo forgery | value=0 rc1 (no shim flips) | `f1.txt` | value=0 shim=HOLDS spec=1 ok=0 rc=1 | real=HOLDS,shim=HOLDS | PASS (rerun byte-identical) |
| F2 shim-sniff | value=0 rc1 (specificity fails) | `f2.txt` | value=0 shim=BROKEN spec=0 ok=0 rc=1 | shim=BROKEN on all, spec=0 | PASS (rerun byte-identical) |
| F3 no-teeth | value=0 rc1 | `f3.txt` | value=0 shim=HOLDS spec=1 ok=0 rc=1 | identical shape to F1 | PASS |
| F4 no entry/S170 | value=0 sourced=0 rc1 | `f4.txt` | value=0 sourced=0 entry=0 ok=0 rc=1 | shim=BROKEN spec=1 entry=0 | PASS |
| F5 leaking server | value=0 noleak=0 rc1 | `f5.txt` | value=0 discriminating=5 noleak=0 rc=1 | 6 `reaped` bao server lines appended | PASS |
| F6 secret print | value=0 nosecret=0 rc1 | `f6.txt` | value=0 discriminating=5 nosecret=0 rc=1 | ok=1 all T but nosecret=0 | PASS |

This seat reran F1 (`bash plans/round-70-c1.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/controls/f1`): `value=0 ... real=HOLDS,shim=HOLDS,spec=1,entry=1,ok=0` rc=1 — first line byte-identical to `f1.txt`.
F2 rerun (`.../controls/f2`): `value=0 ... real=HOLDS,shim=BROKEN,spec=0,entry=1,ok=0` rc=1 — byte-identical to `f2.txt`.

F1/F2 fixture trials inspected: F1 prints `TRIAL T HOLDS forged` unconditionally (only `command -v bao` gate);
F2 tests `head -c2 "$(command -v bao)"` for `#!` and prints BROKEN everywhere when the binary is a script —
so F2 passes the `shim=BROKEN` leg but fails specificity (`spec=0`), exactly the failure the matrix names.

F5-receipt caveat (checked, neutral): `f5.txt` carries six `reaped <pid> bao server -dev ...` lines whose
`-dev-root-token-id=` value was masked to `r70-<redacted-dead-dev-token>` after the run, per
`controls/receipts/README.txt`. The masking is an edit to a committed receipt line — the nonce-exit + `noleak=0`
value line and rc are untouched, so this does not alter the verdict leg.

### 5. Shim-byte-read ceiling (named ceiling in plan line 70-71, counter lines 34-35) — PASS
Grep of `corpus/openbao-pki-trial.sh` (also of committed bytes at 0d22555 — identical to P1 control bytes, sha256
`200efcb2850df8e729631de1772f4423ef0ac90a8bb1b9a06e4fc499bdc8023d`):
- No read of the `bao` binary's bytes: no `sha256sum`/hash/hexdump/strings/`cp`/cat of the binary path,
  no `/dev/tcp` probing of bao, no `curl`/`wget` to the API, no `command -v` arithmetic to detect shims.
  The only `/dev/tcp` use is the trial's own port-freedom probe (lines 71-73) before starting its server;
  `od ... /dev/urandom` (lines 71,75) is generating port/token randomness, not inspecting any binary.
- Every `bao` invocation is via the CLI (`bao version`, `bao server -dev`, `bao status`,
  `bao write/read/list pki/...`), so a shim placed on PATH intercepts the action identically to a real call.
- Byte-identical to the P1 positive control (freeze-commit fixture `p1/corpus/openbao-pki-trial.sh`):
  `cmp` of candidate `corpus/openbao-pki-trial.sh` vs that fixture is `IDENTICAL`, confirming the brief.
  With no `bao` binary-reading logic, the landed trial cannot name each shim's body; it can only measure
  engine behavior through the CLI.

FINDING RV-1 neutral predicate byte-identical and counter implements every conjunct per cited lines
FINDING RV-2 neutral freeze 430cee2 is ancestor of candidate 0d22555 and adds no lane trial/entry/S170 row
FINDING RV-3 neutral fresh reruns reproduce candidate value=5 rc0 and BASE value=0 absent=1 rc1 identically
FINDING RV-4 neutral all eight control receipts match frozen expected verdicts; F1/F2 reruns byte-identical
FINDING RV-5 neutral landed trial never reads the bao binary bytes and measures only through the CLI; byte-identical to P1 control

SEAT-STATUS: complete reviewed freeze/predicate/counter/commits, reran candidate + BASE + F1 + F2, checked all control receipts
