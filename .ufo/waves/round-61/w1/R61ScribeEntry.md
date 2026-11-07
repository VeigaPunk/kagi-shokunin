# R61ScribeEntry — OpenBao seal/unseal key-share custody entry + two coverage-map rows

Seat: `R61ScribeEntry` (scribe). Axes: depth, coverage. Lane: kagi-shokunin, round 61
attempt 1, BASE `c940f51689d702f1786989d56ad4663833c1452e`, wave `kagi-r61-w1`.

## Behavior

- Wrote `corpus/knowledge/openbao-seal-key-custody.md` (488 lines): provenance trio on lines
  1–3 (`source:` / `verified-at:` / `recheck:`), then `Reverify: R21-02`, then the title and
  body. Sections: §Why it matters, §Documented mechanics (the five T1–T5 rows as a table with
  located quotes), six documented subsections (the key chain, Shamir as the default,
  stateful/per-node unsealing, sealing as the cheap direction, Auto Unseal, recovery keys,
  seal migration), §Mechanics (the measured table + the five shims + the no-`bao` and
  selftest legs), §Docs vs binary (15 rows), §Page gaps (11 rows), §Custody (six readings plus
  an operator decision table), §Bounds (14 bullets), §Falsifiers (9 lines).
- Added the two `corpus/README.md` coverage-map rows after the round-60 lesson row: the entry
  row (line 94) and the round-61 lesson row (line 95).
- Incorporated the L1-routed Revenger finding: the rekey 405 is a **registration gate**, not
  a removal; the paths are unauthenticated, so the 405 precedes any token check; enabling
  `disable_unauthed_rekey_endpoints = false` exposes unauthenticated start/status/update/
  cancel; and `rotate-keys` completes a full rotation (old shares refused at reconstruction,
  new shares unseal, root token survives). Receipt:
  `.ufo/waves/round-61/build/R61Revenger/rekey.md`.
- Receipts under `.ufo/waves/round-61/build/R61ScribeEntry/`: `notes.md` (every ungrounded
  claim), `quote-locations.md` (57 quote rows + 16 absence checks + capture digests),
  `acceptance.txt` (the acceptance checks below), `doc-audit.txt` (the `claim-ledger.sh docs`
  observation).

## Gates (acceptance, run by this seat)

| check | command | result |
|---|---|---|
| provenance trio on the first three lines | `head -3 corpus/knowledge/openbao-seal-key-custody.md` | `source:` / `verified-at:` / `recheck:` |
| one `source:` line | `grep -c '^source:' corpus/knowledge/openbao-seal-key-custody.md` | `1` |
| every located quote resolves | `python3 corpus/rendered-text-v1.py locate <capture> QUOTE` over all count-annotated quotes | 61 spans, 0 missing |
| no non-page quoted spans | same audit over all `"…"` spans ≥ 8 chars outside code spans | 0 |
| table shape | pipe-count per table | 6 tables, each internally consistent |
| README rows | `grep -n 'openbao-seal-key-custody.md\|Round-61 lesson' corpus/README.md` | lines 94, 95, 3 columns each |
| capture identity | `cmp` this seat's fetch vs each capture | byte-identical, HTTP/2 200 |

## Measured half — landed

The trial's receipts landed and the entry's §Mechanics table is copied from them:

- `receipt-real-1.txt` and `receipt-real-2.txt` are byte-identical (sha256
  `421689decca5043a369988922e0e8bd6d4a45c16edf3222b13c02d5952f44c56`), both end
  `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc 0.
- T1 `shares=1 status=1 nopersist=1`; T2 `progress=1/3 same-share-again=progress=1/3
  progress=2/3 sealed=false t=3 n=5`; T3 `seal=1 auth503=1 status200=1`; T4 `req3=1 prog=1
  dec=1 wrong=1 tlen=26 ls=200 ss=200 wl=26 wls=403 wdrc=0`; T5 `raft405=1 mem405=1`.
- Shims: SH1→`BHHHH`, SH2→`HBHHH`, SH3→`HHBHH`, SH4→`HHHBH`, SH5→`HHHHB`, each rc 1 with
  `holds=4 broken=1 error=0`.
- No-`bao`: `OPENBAO_SEAL_TRIAL: SETUP no bao on PATH`, rc 2, no `TRIAL` line.
- Selftest: `SEAL_SELFTEST: PASS (cases=63)`, rc 0; mutant: `FINDING F-STUB-SH1-VEC` /
  `FINDING F-SHIM-MATRIX`, `SEAL_SELFTEST: FAIL (cases=63 failed=2)`, rc 1.

The rekey half is grounded by the Revenger receipt (D1–D7 and the custody rekey paragraph).

## Findings

- **F1 — the frozen POP's T4 authentication check is vacuous as written.** `plans/round-61.md`
  §C2 T4 says the decoded token "authenticates (HTTP 200 on `sys/seal-status`)". T3 of the
  same POP measures that `sys/seal-status` answers **without a token**, so a 200 there cannot
  distinguish a valid token from garbage. The landed trial checks `/v1/auth/token/lookup-self`
  (auth-required, 200) **and** `sys/seal-status` (200), plus the wrong-OTP leg. This is a
  defect in the frozen predicate's wording, not in the trial; the entry records the
  strengthened check. The L1 should report it, not amend the frozen plan.
- **F2 — `DOC_AUDIT: BROKEN (unpinned=1)` names this entry.** `bash corpus/claim-ledger.sh
  docs` ⇒ `DOC_AUDIT: BROKEN (entries=42 row_linked=39 by_hand=3 undeclared=0 missing_ids=0
  unpinned=1 duplicate_reasons=0 floor=21)`. The entry is row-linked via `Reverify: R21-02`
  and counted; it is unpinned until the L1 adds its `corpus/stamps.tsv` row. Receipt:
  `.ufo/waves/round-61/build/R61ScribeEntry/doc-audit.txt`.
- **F3 — the README declaration-count cell is now stale and is outside this seat's two named
  rows.** `corpus/README.md:67` reads "38 row-linked / 3 by-hand / 41 pinned"; after this
  entry the derived values are **39 / 3 / 42** (`claim-ledger.sh docs`). The self-count rows
  `RD-DOCS-ROWLINKED`/`RD-DOCS-BYHAND`/`RD-DOCS-ENTRIES` bind that cell to ledger row
  `R14-01`, so the L1 must move the cell and the ledger expectation together.
- **F4 — the scout's fetch provenance is not recorded.** The three captures exist and their
  bytes are stable (this seat's independent fetch is byte-identical, HTTP/2 200, no
  `Set-Cookie`/`Cookie` header), but no fetch receipt (command, user agent, headers) for the
  scout's fetch was in the wave tree. The entry states the capture provenance as the scout's
  word plus the bytes rather than inventing a user agent.
- **F5 — S125 documents only the auto-unseal rotation path.** §Rotation describes
  `rotate-keys` authorized by recovery keys and the HSM/KMS wrap; it does not describe the
  Shamir rotation. The entry states the Shamir inference as an inference; the Revenger's
  measured rotation supplies the Shamir-side behaviour.
- **F6 — the S125 §Initialization flags are recovery-key flags only.** The page does not
  document `-key-shares`/`-key-threshold` (those are on the `operator init` command page,
  which this round did not open).
- **F7 — the rekey divergence is wider than the plan's T5 wording.** The plan frames T5 as
  "rekey refused on this build (docs vs binary)". The Revenger shows the refusal is a
  configuration gate with a working successor (`rotate-keys`), that the paths are
  unauthenticated, and that enabling the flag exposes unauthenticated rekey control. The
  entry records all of it in D1–D7; the plan's T5 row is not amended.
- **F8 — the trial script changed four times while this seat read it** (`operator seal
  -format` removed; the unseal stdin newline fixed; the T2 detail extended with
  `progress=1/3`/`progress=2/3`/`sealed=false`/`t=3`/`n=5` for the counter; the T4 wrong-OTP
  leg moved to `/v1/auth/token/lookup-self`). The entry names the script and the receipt
  directory, not a line count, and its T4 row was re-aligned to the final script's path.

## Out of scope / handed to the L1

- `corpus/SOURCES.md` S125–S127 rows (the L1 appends; the entry's `source:` cites them).
- `corpus/claim-ledger.tsv` `R14-01` expectation and `corpus/stamps.tsv` pin for the entry.
- `corpus/README.md:67` declaration counts (F3).
- `corpus/lessons/round-61.md` (the L1 writes; the README row describes it).
- `SCORECARD.md`, the C2 counter, the controls battery, the trial script.

## Artifacts

- `corpus/knowledge/openbao-seal-key-custody.md`
- `corpus/README.md` (lines 94–95)
- `.ufo/waves/round-61/build/R61ScribeEntry/notes.md`
- `.ufo/waves/round-61/build/R61ScribeEntry/quote-locations.md`
- `.ufo/waves/round-61/build/R61ScribeEntry/acceptance.txt`
- `.ufo/waves/round-61/build/R61ScribeEntry/doc-audit.txt`

SEAT-STATUS: complete
