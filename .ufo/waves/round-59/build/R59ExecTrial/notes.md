# Seat R59ExecTrial — notes: OpenBao transit trial (plans/round-59.md §C2)

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin at claim BASE 5fa6e658… / frozen
predeclaration af7b6651 (plans/round-59.md). Seat write scope: this build dir,
`corpus/openbao-transit-trial.sh`, and `.ufo/waves/round-59/w1/R59ExecTrial.md`.

Binary used for every run below: `bao` resolved through PATH →
`/home/vgpnk/.local/bin/bao`, `bao version` → `OpenBao v2.7.2
(9e0a0d3c3504a0a00b45e61355afac5e35c78379)`, sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`
(= operator pin). Trial file sha256 at receipt time:
`e11e98f6cfc924131a52713fa496481e80efb89ffcdb9b6bc47b3234d8cc3e01`
(sentinel-observed identical). The trial itself never names that binary path
(PATH resolution only, plan K2) and does not sha-pin (C2-F7 pin is
counter/battery-side; the trial reports `bao=<ver>`).

## Receipt inventory (this dir)

| file | run | result |
|---|---|---|
| receipt-ref-real.txt | real run 1, `--work <seat scratch>/trial-work` | `HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc=0 |
| receipt-ref-real2.txt | real run 2, no `--work` (default work dir exercised) | `HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc=0 |
| receipt-shim-SH1.txt | `KAGI_TRANSIT_SHIM=SH1` | `T1 BROKEN`, others HOLDS → `BROKEN holds=4 broken=1 error=0`, rc=1 |
| receipt-shim-SH2.txt | `KAGI_TRANSIT_SHIM=SH2` | `T2 BROKEN` → rc=1 |
| receipt-shim-SH3.txt | `KAGI_TRANSIT_SHIM=SH3` | `T3 BROKEN` → rc=1 |
| receipt-shim-SH4.txt | `KAGI_TRANSIT_SHIM=SH4` | `T4 BROKEN` → rc=1 |
| receipt-shim-SH5.txt | `KAGI_TRANSIT_SHIM=SH5` | `T5 BROKEN` → rc=1 |
| receipt-none.txt | `env PATH=/usr/bin:/bin` | `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH`, rc=2, zero TRIAL lines |
| receipt-cleanroom.txt | clean-room driver (below) | second dev server refuses first server's T1 ciphertext, `CLEANROOM_DRIVER: PASS rc=0` |

Shim vector table (frozen C2 predicate): baseline HHHHH; SH1→BHHHH; SH2→HBHHH;
SH3→HHBHH; SH4→HHHBH; SH5→HHHHB. CLEANROOM HOLDS in all seven full runs. Each
shim rewrites exactly one observed boolean of its test (SH1 `tamper-refused`,
SH2 `old-v1-decrypts`, SH3 `old-v1-refused-after-min2`, SH4
`v1-refused-named-error`, SH5 `diff-ctx-differs`); mechanics and the cleanroom
leg are untouched.

## Exact commands (cwd = lane root /home/vgpnk/Projects/shokunin/kagi-shokunin)

```
B=.ufo/waves/round-59/build/R59ExecTrial
{ bash corpus/openbao-transit-trial.sh --work /fast/scratch/hyaku/kagi-r59/R59ExecTrial/trial-work; echo "rc=$?"; } > "$B/receipt-ref-real.txt" 2>&1
{ bash corpus/openbao-transit-trial.sh; echo "rc=$?"; } > "$B/receipt-ref-real2.txt" 2>&1
for n in 1 2 3 4 5; do { KAGI_TRANSIT_SHIM="SH$n" bash corpus/openbao-transit-trial.sh --work /fast/scratch/hyaku/kagi-r59/R59ExecTrial/trial-work; echo "rc=$?"; } > "$B/receipt-shim-SH$n.txt" 2>&1; done
{ env PATH=/usr/bin:/bin bash corpus/openbao-transit-trial.sh --work /fast/scratch/hyaku/kagi-r59/R59ExecTrial/trial-work; echo "rc=$?"; } > "$B/receipt-none.txt" 2>&1
bash /fast/scratch/hyaku/kagi-r59/R59ExecTrial/cleanroom-driver.sh > "$B/receipt-cleanroom.txt" 2>&1
```

The clean-room driver (seat scratch, deleted after the run; logic restated here)
started two independent `bao server -dev` processes, each under
`setpriv --pdeathsig KILL` with a random `r59-` root token through
`BAO_DEV_ROOT_TOKEN_ID`, distinct free 127.0.0.1 ports, in-memory storage:
server A (pid 2027056, port 36317) enabled transit, created key `r59-t1` and
encrypted a random marker → the T1 ciphertext; server B (pid 2030813, port
54837, own fresh storage) enabled transit and was asked to decrypt A's
ciphertext. Refusal observed; marker, tokens and ciphertext were never printed.

Default work dir of the trial: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecTrial/trial-work`
(HYAKU_SCRATCH unset in this environment → the /fast path; exercised by
receipt-ref-real2.txt). The trial creates its per-run mktemp dir under the work
dir, writes only there, and removes it on exit (server stdout → /dev/null, CLI
stderr → files inside the per-run dir).

## Observed error texts (named refusals)

- T1 tampered ciphertext: `Code: 400. Errors: * cipher: message authentication failed`
- T4 refusal at `min_decryption_version=2`:
  `Code: 400. Errors: * ciphertext or signature version is disallowed by policy (too old)`
- Clean-room cross-server decrypt: `Code: 400. Errors: * encryption key not found`
- Fixture constraint that shaped T4 (see deviation D1):
  `Code: 400. Errors: * cannot set min decryption version of 2, latest key version is 1`

The trial prints booleans only; these texts were read from the CLI stderr of the
probe/dev runs (and, for the clean room, from receipt-cleanroom.txt).

## Deviations from the frozen POP (findings for the L1, not silent rewrites)

- D1 — T4 rotates its key once before raising `min_decryption_version`. The API
  refuses a raise above `latest_version` (error text above, measured), so an
  existing version 2 is prerequisite setup for the raise. The measured
  observable is exactly the frozen one: v1 ciphertext refused at min=2 with the
  named error, re-enabled at min=1. (T3 rotates too — rewrap to `vault:v2:`
  requires a v2; that is already implied by the POP's own T3 wording.)
- D2 — the trial prints a sixth line `TRIAL CLEANROOM HOLDS|BROKEN|ERROR
  <detail>` between the five T-lines and the summary, and the summary's
  `holds=` counts T1..T5 only (max 5) while `broken=`/`error=` count all six
  leg lines. The assignment's output clause names five TRIAL lines + summary;
  the sixth line is the interface agreed with the C2 counter seat
  (R59ExecCounterC2, which greps `^TRIAL CLEANROOM HOLDS ` and counts holds
  over T1..T5 only). The frozen POP's clean-room conjunct is this leg; its
  mechanics (second independent dev server, own storage, refuses server 1's T1
  ciphertext) are unchanged.
- D3 — default work dir is the seat scratch path (assignment mandate), not the
  r58 trial's `${TMPDIR:-/tmp}`.
- D4 — the trial does not sha-pin the `bao` binary. It resolves PATH only and
  reports `bao=<ver>`; the C2-F7 pin must be enforced counter-side (or by a
  PATH wrapper). Flagged so the controls seat does not expect trial-side SETUP
  on a wrong-sha binary.
- D5 — measured, informational: OpenBao 2.7.2 transit auto-creates an absent
  key on first encrypt (`transit/encrypt/<never-created-key>` returns rc=0 and
  the key then reads latest_version=1). The trial still creates its keys
  explicitly with `bao write -f transit/keys/<k>` (rc checked) so key state is
  deterministic; noted because it weakens any "encrypt fails on unknown key"
  assumption in later rounds' instruments.
- D6 — CLI shape notes measured on 2.7.2 (for the lesson, not deviations):
  `bao write <path> -` parses stdin as a JSON object (the `key=value` stdin
  form errors with `Failed to parse K=V data`); a single `field=-` reads that
  field from stdin; two stdin fields need the JSON body form (used here for
  plaintext+context). `bao write <path>` with no data and no `-f` fails
  client-side; `-f` is required for empty writes (key create, rotate).

## Checks

- Secret-shape scan over this receipt dir:
  `grep -rInE 'hvs\.|hvb\.|r59-[0-9a-f]{24}' .` → no matches.
- No plaintext marker, token, ciphertext or context value appears in any
  receipt or TRIAL line (details are booleans and static labels only; values
  travel via stdin JSON bodies; tokens via env).
- Orphan check after my runs: no `bao server -dev` process left from this seat
  (a sibling seat's in-flight run of this trial and one pre-existing
  15-hour `bao` process are visible host-wide; neither belongs to this seat).
- Tooling record (operator rule 2026-10-19): nothing installed or upgraded by
  this seat; `bao` v2.7.2 was already at ~/.local/bin/bao and matches the
  operator sha256 pin. Scratch lived under
  /fast/scratch/hyaku/kagi-r59/R59ExecTrial/ and is removed before yield.

SEAT-STATUS: complete
