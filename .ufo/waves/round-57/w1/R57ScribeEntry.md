# R57ScribeEntry — seat report (kagi round 57, wave 1)

Seat: R57ScribeEntry (scribe; axes coverage, depth). Date 2026-11-07. Lane
`kagi-shokunin`, branch master, claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`.
Seat opened at lane HEAD `7aa1f47` (predeclaration), closed at `03cbf65` (L1 freeze
epoch B); production edits during the seat are other seats', not mine. Answering
model observed: `amr/deepseek-v4.1-flash` (harness project-context line; no model
was supplied by any task).

## Deliverable

- Draft entry: `.ufo/waves/round-57/w1/R57ScribeEntry.d/corpus/knowledge/openbao-audit-device-custody.md`
  — 22086 B, sha256 `bb2ad8c106ddf2e56f9ddef622494a4134af9f127e0285421a2d76abfbad36f3`
  (at 11:26:35 -0300). Prose only; front matter `source:` (S115+S116 with URLs and
  headings), `verified-at: 2026-11-07`, `recheck:` on-release bound to feed S090.
  Sections: audit device definition; HMAC-SHA256-with-salt value form; `log_raw`
  and `hmac_accessor` (+ `prefix`/`skip_test`/`format`/`elide_list_responses`);
  documented non-audited paths; new-salt-on-re-enable; cluster-wide enablement;
  multiple-device failure rule; `## Measured (round 57)` table + T1–T5; bounds;
  gaps G1–G4 + self-review. Every doc paragraph names its S-id and heading and
  ends with a `Quote/locate` line.
- Captures: `.d/capture/audit.browser.html` (S115, 41787 B, sha256
  `76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6`) and
  `.d/capture/commands_audit.browser.html` (S116, 33338 B, sha256
  `3dc8873201fdb3a971eb5fb1c1cee6a804462510c962ea5df6121cad0d9905ce`).
- Preserved precondition receipt: `.d/precondition-bare-dev-receipt.txt` (sha256
  `4136b779a2d3a3d10db834909f4d99fe3b8d585d7c453d89dd38e87ed39de901`), copied
  from the executor's first `receipt-real.txt` at 11:18 before its rerun.
- Receipt log: `.d/receipt.txt`.

No `corpus/` edit, no `plans/` edit, no production edit, no git/jj mutation,
no install.

## Gates run (observed)

1. Fetch identity, two UAs per page, bodies only:
   `curl -sS -L --compressed --max-time 60 -A '<Chrome UA>' -o <name>.browser.html URL`
   and the same without `-A`; both returned HTTP 200 and byte-identical decoded
   bodies per page (wire 10378 B / 6852 B, decoded 41787 B / 33338 B). Hashes above.
   Cross-checked independently against `R57ScoutSources`'s
   `.ufo/waves/round-57/capture/fetch-receipt.txt` and `R57ScribeLesson`'s
   `R57ScribeLesson.d/fetch-receipts.txt`: same bytes and hashes on both pages.
2. Quote location: 51 distinct curly-quoted phrases extracted from the draft and
   run through `python3 -I -B corpus/rendered-text-v1.py locate <capture> "<quote>"`;
   51/51 return `count>=1` on the named page (the evidence quotes are `count=1`;
   page-navigation phrases are not used as evidence). Instrument selftest:
   `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, rc 0.
3. Trial verdicts, read from the executor's REF receipts (not rerun by me):
   `receipt-ref-real.txt` and `receipt-ref-real2.txt` rc 0, vectors `HHHHH`,
   `OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`;
   `receipt-ref-sh1.txt`..`receipt-ref-sh5.txt` rc 1, label vectors `BHHHH`,
   `HBHHH`, `HHBHH`, `HHHBH`, `HHHHB`; `receipt-ref-wrap.txt` rc 1, T1 BROKEN
   (`listed=0/0`); `receipt-ref-none.txt` rc 2,
   `OPENBAO_AUDIT_TRIAL: SETUP no bao on PATH`. The entry's Measured table mirrors
   these shapes exactly, never a value.
4. Entry lint by scan: no `hvs.`/`hvb.`/`s.<20+>`/`vault:vN`/`secret/data` strings,
   no HMAC or nonce value, no vault ref path; only sha256 of public pages/tools.

Not run (unrun is not passed): `plans/round-57-c2.sh` counter at the landing tip
(L1's post-landing run), `plans/round-57-c1.sh` and the C1 checker, the controls
REF legs, and any build/test suite (none applies to a prose entry).

## Touched surfaces

Wrote only: `.ufo/waves/round-57/w1/R57ScribeEntry.md`, and under
`.ufo/waves/round-57/w1/R57ScribeEntry.d/`: the draft entry, the two captures,
the preserved receipt, and `receipt.txt`.
Read-only: `plans/round-57*.{md,sh,py}` (epoch A then epoch B), `corpus/SOURCES.md`,
`corpus/openbao-audit-trial.sh`, `corpus/rendered-text-v1.py`, executor receipts
and report, sibling fetch receipts. Scratch was `/fast/scratch/hyaku/kagi-r57/R57ScribeEntry/`
(capture source; deleted at close).

## Findings

- **F1 doc/binary divergence (measured, feeds G4).** On a 2.7.2 default dev server,
  `bao audit enable` is refused; with `unsafe_allow_api_audit_creation = true` in
  `-config` it succeeds. S115 documents the v2.3.2 opt-in; S116 §Examples shows the
  bare CLI succeeding and does not restate it. The landed T1 records both legs:
  `TRIAL T1 HOLDS default-enable-refused=1 flagged-enable=1 devices-listed=2`.
  The executor's diagnostic records the refusal as `400: cannot enable audit device
  via API; use declarative, config-based audit device management instead`
  (`.ufo/waves/round-57/w1/R57ExecTrial.md`).
- **F2 prefix not documented.** The literal `hmac-sha256:` occurs 0 times in both
  decoded bodies; the entry reports it only as a measured T2 shape.
- **F3 CLI/path identity gap.** S115 lists `sys/seal-status` as non-audited; that
  `bao status` issues that path is not stated on S115/S116 (G1).
- **F4 stale prospective sentence.** S115, rendered at “Version 2.7.x”, still says
  “In future releases (v2.4+), we will enable a new model where audit devices are
  managed within the server configuration itself” (G3).
- **F5 `log_raw` custody consequence (measured).** T3 counts the value and the
  client token in cleartext on the raw device (`raw-value-plaintext=7`,
  `raw-token-cleartext=17`) and neither on the default device (`0`/`0`); counts
  only, no value or token recorded.
- **F6 frozen-instrument conflict, verbatim.** At seat open (HEAD `7aa1f47`) the
  C2 counter read: “C2_AUDIT_TRIAL: value = PASS when the trial's real run is
  `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` and each of the five falsifier shims flips
  exactly one test to BROKEN (`AUDIT_TRIAL: FAIL ... pass=4`), else 0; target 5
  (BASE 0).” At HEAD `03cbf65` the counter reads: “C2_AUDIT_TRIAL: value = PASS
  when the trial's real run is HOLDS 5/5 twice, each of the five falsifier shims
  flips exactly its designated test (vectors below), a PATH with no bao reads SETUP
  rc2 with no HOLDS, and a client-side wrapper whose `bao audit list` is empty flips
  T1; else 0. Target 5 (BASE 0).” Commit `03cbf65` message: “round-57: freeze
  epoch B — C2 counter adopts the lane TRIAL convention (A1) and the measured
  default-refusal/flag enable path (A2); plan predicate and 11-control battery
  re-run.” I read epoch A before work and did not amend anything; the entry follows
  epoch B because that is the landing authority. `plans/round-57.md` §C2 at HEAD
  carries the epoch B predicate and POP.
- **F7 wave-level custody note (from R57ExecTrial.md, not inspected by me).** Two
  sibling dev servers carried `-dev-root-token-id=<value>` on argv (ps-visible);
  the executor flagged it to R57ScoutSources and recorded shape only. I did not
  read the processes or any value.
- **F8 script hash drift.** `corpus/openbao-audit-trial.sh` was sha256
  `41fd8096d53c6584f362cdcbc62c90ff3426738b03753b1765aba6e89ce7b343` when the REF
  receipts were written (11:21–11:22) and `7e64519466bfd7baf51f66d4bc71da09f30845d41d0fb10f36fcf24eec5b0bd3`
  at 11:25 after the L1's edit. The current copy prints the same detail keys and
  summary shape as the receipts; the entry pins neither hash and defers the
  post-landing counter reading to the L1.

## Out of scope

C1 (calibration) and its checker/counter; the production landing itself; registry
rows S115/S116 (scout/L1); capability/coverage rows; counter executions; sibling
seats; any git/jj mutation; any `corpus/` or fleet-root tracked file.

## Artifact paths (relative to the lane root)

- Draft entry: `.ufo/waves/round-57/w1/R57ScribeEntry.d/corpus/knowledge/openbao-audit-device-custody.md`
- Captures: `.ufo/waves/round-57/w1/R57ScribeEntry.d/capture/audit.browser.html`, `.../commands_audit.browser.html`
- Preserved first-run receipt: `.ufo/waves/round-57/w1/R57ScribeEntry.d/precondition-bare-dev-receipt.txt`
- Receipt log: `.ufo/waves/round-57/w1/R57ScribeEntry.d/receipt.txt`
- This report: `.ufo/waves/round-57/w1/R57ScribeEntry.md`
- Trial receipts cited by the entry: `.ufo/waves/round-57/w1/R57ExecTrial.d/receipt-ref-*.txt`

## Environment / tools

Linux 7.2.11-arch1-1 x64; Python 3.14.8; curl 8.23.0 (OpenSSL 3.6.5); OpenBao
v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379) preexisting at
`/home/vgpnk/.local/bin/bao` (no install); `corpus/rendered-text-v1.py` selftest
PASS 22. All pacman transactions untouched. No files created outside the lane wave
dir and my scratch; scratch deleted at close.
