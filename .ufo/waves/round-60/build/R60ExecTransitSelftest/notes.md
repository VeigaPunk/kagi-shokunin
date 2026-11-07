# R60ExecTransitSelftest — notes (kagi round 60, item I7 / spot-check D7)

Date: 2026-11-07. Seat: R60ExecTransitSelftest (leaf). Scope: `corpus/openbao-transit-trial.sh` +
the transit row of the SKILL.md gate registry. Nothing else in the lane was written.

## What changed

1. `corpus/openbao-transit-trial.sh`
   - `--selftest` added to the argument parser (usage string extended; `--work` unchanged).
   - Shim selector hardened: `SHIM="${KAGI_TRANSIT_SHIM:-}"` is now bound before any tool
     check and any non-empty value other than SH1..SH5 prints
     `OPENBAO_TRANSIT_TRIAL: SETUP unknown KAGI_TRANSIT_SHIM` and exits 2. The literal
     anchor line `SHIM="${KAGI_TRANSIT_SHIM:-}"` is preserved verbatim (round-58
     controls supplement anchors on it; verified present exactly once).
   - `--selftest` implementation: 9 fixture cases over an isolated per-case fixture PATH.
     Each case runs the real trial script as a subprocess and asserts its exit code and
     output shape; failures print `FINDING TRANSIT-ST-<ID> <detail>`.
   - Selftest work root default is seat-agnostic:
     `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-transit-trial/selftest-work` with a
     per-run `mktemp` subdir. Rationale: the C1 checker, controls battery and reviewers
     invoke `--selftest` without `--work`, possibly concurrently; an earlier draft used a
     seat-named default and collided with an in-flight reviewer run (see Incident below).
2. `SKILL.md` — round-59 gate-registry transit row, `selftest` cell only: now names
   `bash corpus/openbao-transit-trial.sh --selftest` (9 fixture cases; stub-`bao` harness;
   the five shims and the clean-room leg remain the falsifier vectors). All other cells and
   the row's pipe shape are untouched.

## Incident (fixed before yield)

The first draft's default selftest work root was
`$HYAKU_SCRATCH/kagi-r60/R60ExecTransitSelftest/selftest-work`. R60ReviewerC1 ran
`--selftest` (no `--work`) on trial copies under `kagi-r60/R60ReviewerC1/trees/*` while my
receipts were being written; their fixture dirs landed inside my seat scratch, which I
deleted at cleanup time, invalidating those in-flight runs (their processes showed
spurious findings/fail-closed results — the harness failed closed, never silently passed).
Fixed by making the default root seat-agnostic; peer notified via agent message. No lane
file outside my two owned paths was touched by the collision; the reviewer's trees are
their own scratch.

## Selftest design (fixture-driven; no real `bao`, no network)

- The harness writes a stateful stub `bao` (one python3 file, `#!/usr/bin/env python3`)
  into each case's fixture `bin/`. It dispatches exactly the CLI calls the trial makes
  (`version`, `status`, `secrets enable`, `write/read` on `transit/keys/*`,
  `encrypt`/`decrypt`/`rewrap`/`rotate`/`config`) against per-server JSON state under
  `STUB_STATE/<port>/`, so the clean-room leg still proves cross-storage refusal.
- No HTTP anywhere: server mode only opens a loopback listener and holds it (no accept,
  no client ever connects) so the trial's `ss` readiness probe sees the pid. The loopback
  bind is the only socket; nothing is sent or received.
- The stub implements real transit semantics the trial depends on: encrypt auto-creates
  a missing key (T1 relies on this), deterministic ciphertext for convergent keys with
  context, random ciphertext otherwise, version tracking on `rotate`,
  `min_decryption_version` enforcement with the named "too old" error, tamper/unknown
  ciphertext refusal, and `encryption key not found` for a foreign server's storage.
- Cases (N=9): ST-BASELINE (six legs HOLDS, holds=5 → exit 0), ST-SHIM-SH1..SH5 (each
  shim flips exactly its own test, all others HOLDS → exit 1, summary
  `BROKEN holds=4 broken=1 error=0`), ST-ERROR-EXIT (injected stub encrypt fault →
  summary ERROR → exit 2), ST-SHIM-UNKNOWN (`KAGI_TRANSIT_SHIM=SH9` → SETUP exit 2, no
  HOLDS; run with an empty PATH so it also proves the validation precedes tool checks),
  ST-NOBAO (empty PATH → `SETUP no bao on PATH` exit 2, no HOLDS). Every case pins its
  whole fixture environment (`KAGI_TRANSIT_SHIM`, `STUB_FAULT`, `STUB_STATE`, `PATH`)
  so no ambient value can leak in; each case has its own `state/` and `work/` dir.
- Pass line: `TRANSIT_SELFTEST: PASS (cases=9)`; fail line:
  `TRANSIT_SELFTEST: FAIL (cases=9 failed=M)` with one `FINDING` line per failed
  assertion, exit non-zero. SETUP (missing python3/timeout/ss/setpriv/pgrep/bash) prints
  `TRANSIT_SELFTEST: SETUP <reason>` and exits 2 (fail-closed).

## Fail-power proof

Scratch copy with the verdict mapping broken (`elif ... S=BROKEN; rc=1` → `rc=0`): the
selftest exits 1 and prints five named findings
(`FINDING TRANSIT-ST-SHIM-SH1..SH5 exit=0 want=1`). Receipt: `selftest-mutant.txt`
(regenerated on the final bytes after the default-root fix).
The same harness also catches summary-line/counting mutations (exact-string asserts on
the `OPENBAO_TRANSIT_TRIAL:` line and per-leg `TRIAL T<n>` lines) and `exit $rc`
mutations (every rc assertion).

## Real-run compatibility

- `bash corpus/openbao-transit-trial.sh --work <scratch>` after the edit: six legs HOLDS
  (T1–T5 + CLEANROOM), `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`,
  rc 0. bao resolved through PATH only; sha256 matches the pinned OpenBao 2.7.2
  (`9c5f36287c…41b788`). Receipt: `trial-still-holds.txt`.
- Main-flow stdout/exit contract unchanged: same TRIAL lines, same summary format, same
  exit codes. The only new production behavior is the unknown-shim SETUP (previously
  silently ignored) and the `--selftest` mode.
- `plans/round-59-c2.sh` is unaffected: it drives the trial with `KAGI_TRANSIT_SHIM` ∈
  {"", SH1..SH5} and `env -i`; the no-bao leg still prints the identical SETUP line/rc 2.
- round-58 controls supplement's `SHIM="${KAGI_TRANSIT_SHIM:-}"` anchor still matches
  (line moved earlier in the file, text identical, count 1).

## Tool installs

None. Everything needed was already present (bash 5.3, python3 3.14, setpriv, ss,
timeout, pgrep, OpenBao 2.7.2 at `~/.local/bin/bao`). Pacman guard respected; no
package transactions.

## Secrets

No token, secret_id, secret-shaped string or request body appears in any receipt or
printed line. The selftest's stub accepts the trial's `BAO_TOKEN` env without reading
or printing it; all fixture values are random in-process nonces. Receipts were scanned:
no `hvs.`/`hvb.`-shaped or token material.

## Risks / notes for the integrator

- The stub is a test double, not OpenBao: it covers the trial's CLI surface as used by
  the trial (encrypt/decrypt/rewrap/rotate/config/read + server lifecycle). If the trial
  later adds a CLI call the stub does not know, the affected case fails closed with a
  named finding (never a silent pass).
- Selftest needs python3 + loopback `bind()` only; it deliberately does NOT require
  setpriv/ss/bao for its own dispatch (it checks them and returns SETUP rc 2 if absent,
  because the trial subprocesses it spawns need them).
- Runtime ≈ 7–10 s for 9 cases (two dev-server lifecycles per stub case).
- `SKILL.md` row kept at 8 cells / unchanged separator count; only the `selftest` cell
  text changed.
