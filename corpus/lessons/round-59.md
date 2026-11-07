# Round 59 — the five round-58 routed record defects become an audited item set (C1, calibration); an executed OpenBao transit-engine trial measures encryption-as-a-service (C2, operability, capability)

source: S121 (https://openbao.org/docs/secrets/transit/), S122 (https://openbao.org/docs/api/secret/transit/), both opened 2026-11-07; `corpus/lessons/round-58-verifier-spotcheck.md` (the non-author closure that routed D1–D5).

Frozen plan: `plans/round-59.md` (predeclaration `af7b6651`; §A1 corrects the wave shape 13 → 14 seats before any candidate reading). Claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`.
Instruments: `corpus/openbao-transit-trial.sh`, `plans/round-59-c1-check.py`, `plans/round-59-c1.sh`,
`plans/round-59-c2.sh`, `plans/round-59-controls.sh`, `plans/round-58-controls-supplement.sh`.

## Claims

- **C1 calibration — the five round-58 routed record defects, resolved and re-checkable.** Items
  I1–I5 are each a structural read over committed bytes, with every compared number derived by the
  checker from a named revision; the round starts at five unresolved items and targets zero. Frozen
  predicate (as declared in `plans/round-59.md` §C1):

  ```
  C1_ROUTED: value = the number of UNRESOLVED items over POP = 5 fixed routed-defect
  items (I1..I5 below), when GUARD = 1, else FAIL; target 0 (BASE 5).
  An item is UNRESOLVED iff its named condition does not hold on the measured tree.
  GUARD = 1 iff the checker evaluates all five items (prints population=5 with
  i1..i5 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
  is the digit after the arrow on the LAST `Registry N → M at the candidate` line of
  corpus/lessons/round-58.md changed from M to M+1, prints exactly value+1, and a
  printer stub that always prints value=0 fails that same challenge.
  ```

  Derived numbers (re-derived at the claim BASE `5fa6e658`, receipt
  `.ufo/waves/round-59/build/R59ScribeLesson/derived-base.txt`):

  | id | condition | derived number | command |
  |---|---|---|---|
  | I1 | the last `Registry N → M at the candidate` line states the row counts at the round-58 claim BASE and at the round-58 landing | N=117, M=120 | `git show 1b13f5da:corpus/SOURCES.md \| grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` = 117; `git show be8705f8:…` = 120 |
  | I2 | the last line naming `corpus/source-fetches.tsv` states the added-row count of the round-58 diff | 6 | `git diff 1b13f5da be8705f8 -- corpus/source-fetches.tsv \| grep -c '^+S'` = 6 |
  | I3 | (a) the last line naming `controls-prefreeze.txt` states all three control counts; (b) the supplement script names both `C1-F10` and `C2-F4` and the supplement receipt ends `match=2 mismatch=0` | 20 total / 9 `C1-F` / 7 `C2-F`; the supplement receipt must end `SUPPLEMENT: match=2 mismatch=0` | `grep -c '^CONTROL ' \| '^CONTROL C1-F' \| '^CONTROL C2-F'` on `.ufo/waves/round-58/controls/controls-prefreeze.txt` |
  | I4 | the last line of the round-58 lesson naming `.ufo/waves/round-59/final/citation-gate-r59.txt` states the same `unresolved=<U>` as that receipt's last `CITATION_GATE:` line | U = whatever that line carries; at this capture the receipt ends on an `UNRESOLVED` line, i.e. no `CITATION_GATE:` line yet | `tail -1 .ufo/waves/round-59/final/citation-gate-r59.txt` |
  | I5 | the round-58 lesson carries a `stale-lane:` line stating the mission duration in whole minutes and the word `progressing` | 101 min (11:54:48 → 13:36:19) | the two driver-digest lines in `corpus/lessons/round-58-verifier-spotcheck.md` |

  Counters at the claim BASE: `bash plans/round-59-c1.sh 5fa6e658…` prints
  `C1_ROUTED: value=FAIL population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0`
  (`.ufo/waves/round-59/build/R59ExecCounterC1/driver-base-5fa6e658.txt`); the diagnostic
  `--no-challenge` census reads `value=5 population=5` (`R59CriticClaims` Q2, same checker bytes),
  so no item is vacuous at BASE (K2). The checker's positive reference — a synthetic tree carrying all
  five corrections — reads `C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1`, and a
  forgery on that tree (D2 stating 7) reads exactly `value=1` with `i2=0`
  (`.ufo/waves/round-59/build/R59ExecCounterC1/reference-fixed-tree.txt`, `reference-forged-i2.txt`).

  On the lane tree the guard-bearing reading before the repairs was 3 (counter receipt
  `base-guard-reading-current-tree.txt` and the reviewer's independent reading D03:
  `C1_ROUTED: value=3 population=5 i1=1 i2=1 i3=0 i4=0 i5=0 guard=1`), and the final candidate reading
  is **0**: `C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1`, rc 0
  (`.ufo/waves/round-59/final/c1-candidate-tree.txt`; the guard's own evidence line is
  `copy delta arrow 120->121: value=1 expect=1`, and the fail-closed leg
  `C1_CHALLENGE_PARENT=<uncreatable>` prints `value=FAIL … guard=0` with all five items holding, so
  the 0 is not a printer artifact). The three intermediate misses were **M59-1** (wrapped bullets:
  I3 and I5), the missing supplement receipt (I3b) and a gate receipt with no `CITATION_GATE:` line
  (I4); each was repaired and each repair is what the item reads.
  Ceilings, stated: `value=0` means five *text conditions* now read true against derived numbers —
  it is not a claim that a defect's substance was re-derived by a run (I3b is a naming test and I4
  accepts any `unresolved=<U>`: measured `unresolved=6`, a BROKEN reading, one lane-owned malformed
  citation at `SCORECARD.md:1856` plus five in integrator-authored spot-checks). The defective D2
  line lives in the fleet report `.ufo/reports/round-58/kagi.md:107` (still "+4 rows"), which this
  lane may not edit; the derived delta is 6 and that is what I2 reads.

- **C2 operability — an executed OpenBao transit-engine trial (capability acquisition).** Five
  documented encryption-as-a-service mechanics executed on throwaway OpenBao 2.7.2 dev servers:
  T1 `transit/encrypt` returns `vault:v1:<base64>`, `transit/decrypt` returns the exact plaintext, the
  ciphertext does not contain the plaintext, and a ciphertext with one base64 character changed is
  refused (round trip and tamper refusal); T2 `transit/keys/<key>/rotate` makes a fresh encryption
  carry `vault:v2:` while the pre-rotation `vault:v1:` ciphertext still decrypts; T3 `transit/rewrap`
  re-encrypts under the newest version without the client supplying the plaintext, and the rewrapped
  value still decrypts after `min_decryption_version` is raised to 2 while the original `vault:v1:`
  ciphertext is refused; T4 `min_decryption_version` refuses version-1 ciphertext with a named error
  and lowering it back to 1 re-enables the same ciphertext; T5 a key created
  `derived=true convergent_encryption=true` gives byte-identical ciphertext for equal plaintext +
  context, a different context gives different ciphertext, and a non-convergent key gives different
  ciphertext for identical plaintext. Frozen predicate (as declared in `plans/round-59.md` §C2):

  ```
  C2_TRANSIT_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two independent
  runs, each of the five falsifier shims flips exactly its designated test (baseline
  vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB),
  a PATH with no bao reads SETUP rc2 with no HOLDS, and a second, independent throwaway
  dev server refuses to decrypt the first server's T1 ciphertext; else 0.
  Target 5 (BASE 0: the trial does not exist at BASE).
  ```

  Shim vectors: baseline `HHHHH`; `SH1 → BHHHH`, `SH2 → HBHHH`, `SH3 → HHBHH`, `SH4 → HHHBH`,
  `SH5 → HHHHB`. Clean-room leg: a second `bao server -dev` with its own storage must refuse the
  first server's T1 ciphertext with a decrypt error (K4 names the ceiling: the counter cannot prove
  the second server is independent from printed output; the receipts and a non-author probe are the
  check). Readings, from `.ufo/waves/round-59/build/R59ExecTrial/`: two independent real runs print
  `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc 0, vector `HHHHH`
  (`receipt-ref-real.txt`, `receipt-ref-real2.txt`); the five shim receipts print exactly
  `BHHHH`, `HBHHH`, `HHBHH`, `HHHBH`, `HHHHB` with `BROKEN holds=4 broken=1 error=0`, rc 1
  (`receipt-shim-SH1..SH5.txt`); the no-bao leg prints `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH`,
  rc 2, zero `TRIAL` lines (`receipt-none.txt`); both real runs carry
  `TRIAL CLEANROOM HOLDS own-storage-refused=1`, and the clean-room driver records server A
  `pid=2027056 port=36317` and server B `pid=2030813 port=54837` refusing A's T1 ciphertext with
  `Code: 400 … * encryption key not found` (`receipt-cleanroom.txt`). The counter's own reading,
  `C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1
  secret=1)` (`.ufo/waves/round-59/build/R59ExecCounterC2/receipt-candidate.txt`), was measured on a
  **contract-conforming reference fixture, not the wave's trial bytes**; the same seat's BASE receipt
  is `value=0 … guard=0 (absent)`. The counter reading on the landed trial is the L1's to take and is
  **not** reported here as taken (routed R18).

## Gate

Registry effect: `corpus/SOURCES.md` moves 120 → 122 data rows (S121, S122; both tier A, `mined`),
and `corpus/source-fetches.tsv` gains 2 `S121`/`S122` rows — `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'`
on the working tree = 122, at the claim BASE = 120, `git diff 5fa6e658 -- corpus/source-fetches.tsv |
grep -c '^+S'` = 2 (`.ufo/waves/round-59/build/R59ScribeLesson/registry-delta.txt`). Neither row reuses
an id that carried a registry row before; the round-58 capture tree's `S121.body` is a different,
rejected page (routed R7).

- **Admit S121** — https://openbao.org/docs/secrets/transit/, opened 2026-11-07 with a desktop
  browser user agent (HTTP 200, 48604 B, sha256
  `d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19`,
  `.ufo/waves/round-59/capture/S121.body`). Located quotes (each `count=1` under
  `corpus/rendered-text-v1.py locate`, `.ufo/waves/round-59/build/R59ScribeLesson/locate-receipt.txt`):
  “The returned ciphertext starts with vault:v1:” (§Usage, 7 words) — T1's prefix; “Future encryptions
  will use this new key.” (§Working set management, 7 words) — T2; “This process does not reveal the
  plaintext data.” (§Usage rewrap example, 8 words) — T3; “min_decryption_version can be moved back to
  allow for legitimate decryption” (§Working set management, 11 words) — T4's lowering leg;
  “Convergent encryption is a mode where the same set of plaintext+context always result in the same
  ciphertext.” (§Convergent encryption, 18 words) — T5. Tier A for OpenBao 2.7.x transit mechanics;
  the trial measures T1–T5.
- **Admit S122** — https://openbao.org/docs/api/secret/transit/, opened 2026-11-07 with a desktop
  browser user agent (HTTP 200, 267984 B, sha256
  `ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e`,
  `.ufo/waves/round-59/capture/S122.body`). Located quotes (each `count=1`, same receipt): “This
  endpoint rotates the version of the named key.” (§Rotate key, 9 words) — T2's write path; “To upgrade
  ciphertext to be encrypted with the latest version of the key, use the rewrap endpoint.” (§Rewrap,
  19 words) — T3; “Specifies the minimum version of ciphertext allowed to be decrypted.” (§Configure
  key, 10 words) — T4; “If enabled, the key will support convergent encryption, where the same
  plaintext creates the same ciphertext” (§Create key parameter table, 16 words) — T5. Tier A; it is
  the documented endpoint set the trial calls.
- **Admit the knowledge entry** `corpus/knowledge/openbao-transit-engine.md` (drafted this round as
  `.ufo/waves/round-59/build/R59ScribeEntry/openbao-transit-engine.md`, 227 lines): documented
  mechanics with located quotes from S121/S122, a `§Measured` section whose lines are this round's
  trial receipts, a bounds block that keeps unmeasured legs open (the tamper and version-refusal
  error names are the trial's to measure, not the pages'), and a `recheck:` clock that says what to
  re-read and re-run on a release.
- **Reject: the transit CLI page** — https://openbao.org/docs/commands/transit/, opened 2026-11-07
  (HTTP 200, 30020 B, sha256
  `beacc41e63e7ecf92a9651e8aed75169f0c3ffb53af1be1a2c0c6466a23f2424`; rendered body 1675 chars,
  `.ufo/waves/round-59/build/R59ScribeLesson/reject-probe.txt`). The page renders the group sentence
  and one `bao transit import` (BYOK) example only: 0 occurrences of `decrypt`, `rotate`, `rewrap`,
  `min_decryption_version`, `convergent_encryption` and `vault:v` in the rendered text, and the single
  `encrypt` hit is inside the import wrapping narration. A row could not anchor any tested mechanic,
  and key import is this round's named ceiling. Flip: a transit CLI page that renders the
  `encrypt`/`decrypt`/`rewrap` subcommand syntax.
- **Reject: the seal/unseal concepts page** as an additional row — https://openbao.org/docs/concepts/seal/
  (opened 2026-11-07, HTTP 200, 44279 B, sha256
  `643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65`; same receipt): the rendered
  text carries 0 occurrences of `transit`, `rewrap` and `min_decryption_version`, so it adds no claim
  this round makes. Flip: a seal page section that states a transit key-wrapping or key-ring custody
  mechanic.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M59-1 | `format-blind-item-read` — every C1 item selects one **physical line**, and the artifact it reads is Markdown whose bullets wrap. Both directions are measured: a bullet whose first line satisfies the item and whose indented continuation restates the defect reads `C1_ROUTED: value=0 … guard=1`, rc 0, on all five items (A01–A05); and the lane's own correction block, written the same wrapped way, reads `value=3 … i3=0 i4=0 i5=0 guard=1` although a human reads the counts, the `unresolved=` and `101 … progressing` on the continuation lines (D03) | `.ufo/waves/round-59/build/R59ReviewerCounters/attacks.md` rows A01–A05 and D02/D03 (reproducer trees built by `mkw.py`); the live false-red reading is also `.ufo/waves/round-59/build/R59ExecCounterC1/base-guard-reading-current-tree.txt` (`ints=[3, 58, 20]`, `lesson_line=missing`) | the reviewer seat's attacks; the criterion that should have caught it — “the item set must read the artifact as written, not as one physical line per fact” — is what the wrapped-form control per item would have been, and the battery has none (`plans/round-59-controls.sh` F1–F8 all mutate a single line) | join an indented continuation line into its parent bullet (or paragraph) before the last-occurrence selection, add one wrapped-form control per item, and reflow the lesson's D3/D4/D5 so each subject and its operative tokens sit on one physical line; until then neither a green nor a red reading is evidence |

## Routed dispositions

Every attack finding this wave produced, and what happened to it. “Routed” means the seat report
that raised it is in `.ufo/waves/round-59/w1/` and the disposition is one this lesson or the plan
can be read against; nothing here is silently absorbed.

| # | finding (seat) | disposition |
|---|---|---|
| R1 | rewrap is gated by the decryption path — a derived key refuses a context-free rewrap, a wrong context fails the MAC, and `min_decryption_version=2` refuses `vault:v1:` with `(too old)` (`R59RevContext`, `transcript-run4.txt:177,192,391`; page-side: `R59ScoutSources` N3 / Q34) | **accepted, not a predicate change.** The frozen POP line survives read as “the client never supplies the plaintext”; the trial's T3 line says exactly that. The explanatory parenthetical is not repeated in the entry or this lesson. |
| R2 | T5's key needs `derived=true`; `convergent_encryption=true` alone is refused with `* convergent encryption requires derivation to be enabled` (`R59RevContext` §2, `transcript-run4.txt:24`) | **absorbed in the instrument.** `corpus/openbao-transit-trial.sh:164` creates the convergent key with `derived=true convergent_encryption=true`; the T5 claim above states it; the frozen row is not amended. |
| R3 | convergence is a key-creation value and cannot be enabled later (`R59ScoutSources` N4: Q12/Q31/Q37) | **routed to the entry's bounds**; no trial change (the trial creates the key once). |
| R4 | convergent mode has a nonce requirement/reuse hazard, and determinism is documented for a fixed plaintext+context+nonce (`R59ScoutSources` N5: Q26/Q29/Q32/Q35) | **routed to the entry:** the measured determinism is the derived-nonce mode; the client-nonce mode is named as unmeasured. |
| R5 | the pages name no error text for the tamper refusal or the `min_decryption_version` refusal (`R59ScoutSources` §4 G1/G2) | **routed to the entry as measured-not-documented.** The trial's receipts carry the two texts (`.ufo/waves/round-59/build/R59ExecTrial/notes.md` §Observed error texts). |
| R6 | key-type limits: rotate/rewrap only on encrypt/decrypt keys; imported keys need `allow_rotation`; external keys cannot do convergence (`R59ScoutSources` N6) | **routed to the entry's scope** (one default `aes256-gcm96` key type measured). |
| R7 | a capture-tree id collision: `.ufo/waves/round-58/capture/S121.body` is the rejected token-CLI page (different URL) (`R59ScoutSources` §5) | **routed to the L1:** no registry row ever carried S121 before this round, so the registry has no collision; the note belongs on the row. |
| R8 | a do-nothing construction reaches `C1_ROUTED: value=0 … guard=1`: five right-looking lines appended, a comment-only supplement, and any `unresolved=` value in the gate receipt (`R59CriticClaims` Q1-C1) | **ceiling, to be stated in the report/lesson.** I3(b) is a naming test and I4 accepts any U; the claim is “five text conditions now read true”, never “the five defects were repaired”. |
| R9 | a shape-keyed stub that never executes `bao` reads `C2_TRANSIT_TRIAL: value=5 … guard=1`, and C2-F5 covers only a smaller forgery (no shim vectors) (`R59CriticClaims` Q1-C2) | **ceiling, to be stated.** The counter verifies a transcript; “executed” rests on the trial receipts and a non-author probe, per the plan's K2 ceiling. |
| R10 | the C2 counter (13:58 bytes, sha256 `9bc3da95…`) printed `value=0 … guard=0 (absent)` and **exited 0**, while the frozen plan's C2 §Commands says `Exit 0 iff value=5; 1 otherwise; 2 SETUP` (`R59CriticClaims` Q2) | **repaired in the same wave:** `plans/round-59-c2.sh:93-94` now exits 1 on that line, with the source comment naming the defect; the exit status is now encodable by a runner. |
| R11 | `value=FAIL … guard=0` at BASE is indistinguishable from an unavailable challenge scratch; the documented bare command needs `C1_CHALLENGE_PARENT` (`R59CriticClaims` Q6.6) | **routed to the report:** the BASE census must name `--no-challenge` (the counter's own receipt does: `base-reading-current-tree.txt` header). |
| R12 | D2's defective line (`+4 rows`) lives in the fleet report, which this lane may not edit; I2 reads the lane lesson instead (`R59CriticClaims` Q5) | **ceiling, to be stated:** the fleet erratum survives; this round's lesson restates the derived delta (6) and I2 reads that. |
| R13 | the 14:07 bytes of the round-59 pre-freeze battery did not implement the plan's `C2-F4` (single-run leg): its `C2-F4` was “a shim that flips two tests”, `C2-F2` was the summary leg and `C2-F6` was the no-bao leg. The single-run *substance* ships in `plans/round-58-controls-supplement.sh` (`report C2-F4 "<5"`, a copy that permits exactly one empty-shim run), i.e. in a different battery that is not part of this round's `CONTROLS:` line (`R59CriticClaims` Q5/Q6.7; static id census `.ufo/waves/round-59/build/R59ScribeLesson/controls-composition.txt`: 20 rows, 8 `C2-F`, none single-run) | **repaired in the same wave.** The L1 revised the battery at 14:16 (`plans/round-59-controls.sh` sha256 `0d8647a0…`): `C2-F2` is now the no-bao SETUP/rc2 leg, `C2-F4` the single-run leg, `C2-F5` the fabricated transcript, `C2-F6` the shim-cross leg (`:159-178`). The round's `CONTROLS:` line must be read from a complete run; run5 (`.ufo/waves/round-59/controls/controls-prefreeze-run5.txt`) stops after `C1-F4`. |
| R14 | T4 must rotate before raising `min_decryption_version` (the API refuses a raise above `latest_version`: `* cannot set min decryption version of 2, latest key version is 1`) (`R59ExecTrial` D1) | **accepted deviation:** the measured observable is unchanged; recorded in the trial notes and here. |
| R15 | the trial prints a sixth `TRIAL CLEANROOM` line and the summary's `holds=` counts T1..T5 only (`R59ExecTrial` D2) | **accepted interface**, agreed with the C2 counter seat; the counter greps the clean-room line separately. |
| R16 | the trial does not sha-pin `bao`; the pin is counter/battery-side (`R59ExecTrial` D4) | **accepted:** `plans/round-59-c2.sh` enforces `PIN_BAO` and reads it from `plans/round-57-c2.sh`; control C2-F7 covers a wrong-sha binary. |
| R17 | 2.7.2 transit auto-creates an absent key on first encrypt (`R59ExecTrial` D5) | **routed to the entry** as a measured note; the trial still creates keys explicitly. |
| R18 | the C2 counter's `value=5` was measured against a **contract-conforming reference fixture**, not the wave's trial bytes (`R59ExecCounterC2` §Contract measured) | **closed:** the L1 re-ran `bash plans/round-59-c2.sh --tree .` on the landed trial and the receipt reads `C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)`, rc 0 (`.ufo/waves/round-59/final/c2-candidate-tree.txt`). The fixture reading is superseded. |
| R19 | the C1 checker's first frozen bytes selected the I5 lesson line line-scoped, so a wrong `stale-lane:` line could pass — caught by the battery's `C1-F5` control before any candidate reading | **repaired and disclosed:** the checker's freeze history is in `R59ExecCounterC1.md` §Frozen bytes (first freeze `e6c079f6…`, current `6844c1d4…`); `reference-f5probe.txt` shows a later wrong line (`96 min`) reading `value=1 … i5=0`. |
| R20 | the round's pre-freeze battery needed four revisions before it read clean (`match=17 mismatch=3` at run 4: `C1-F5` the I5 existential predicate, `C1-F7` a stub the battery replaced instead of challenging, `C2-F2` a `SETUP` prefix that the trial prints with an `OPENBAO_TRANSIT_TRIAL: ` prefix) (`R59MutCounters`, `R59ReviewerCounters`) | **repaired before the candidate reading:** `plans/round-59-controls.sh` §A4 records the composition; the final receipt is `.ufo/waves/round-59/controls/controls-prefreeze.txt`. The run-4 receipt stays committed as `.ufo/waves/round-59/controls/controls-prefreeze-run4.txt`. |
| R21 | the default `citations` doc set (which walks `LOG.md`, all 60 lesson files and the `.ufo/` wave trees) did not complete three times under the fleet's round-59 load (~25 min, no output; one doc alone measured 750 cites in 3m35s) | **scoped and disclosed:** the committed receipt `.ufo/waves/round-59/final/citation-gate-r59.txt` names its scope in a header line (48 docs: the lane's authored judgment surface) and ends `CITATION_GATE: BROKEN (cites=1618 docs=48 unresolved=6 ephemeral=0 labeled=9)`. The full-corpus reading is a named ceiling, not a claim. |
| R22 | `bash corpus/self-description-sweep.sh` did not complete within 600 s on the candidate (it delegates to `citations`) | **named, not claimed:** the sweep is a ceiling this round; `python3 corpus/self-counts.py` was run instead and its `stale=` field read 0 after the three stamp-count statements were moved 146 → 147. |
| R20 | the 14:16 regeneration of `.ufo/waves/round-59/final/citation-gate-r59.txt` failed and wrote `claim-ledger: unexpected positional argument for citations` (59 B), so I4 cannot hold until a correct `bash corpus/claim-ledger.sh citations` run writes the summary line | **open — routed to the L1.** This lesson records the file as it stands; a later correct reading supersedes it. |
| R21 | every C1 item reads one physical line, so a wrapped continuation restates a defect invisibly (A01–A05, five reproducers) and the live wrapped fix reads red (D03) (`R59ReviewerCounters`) | **recorded as this round's mined mistake (M59-1)**; fix = join continuations + a wrapped-form control per item. |
| R22 | the challenge copy follows a symlinked `corpus/lessons/round-58.md` and rewrites a file outside the copy (A12, canary `Registry 117 → 120` → `… 121`; counter still `value=0 guard=1`) — the M58-3/QM74 class | **open defect — routed to the L1.** `symlinks=False`, or refuse a symlinked lesson, or assert every written realpath is under the copy. Evidence: `R59ReviewerCounters/attacks.md` A12. |
| R23 | the battery could not read `mismatch=0` as first shipped: the plan's `C1-F7` (printer stub fails the challenge) was unreachable because `c1()` prefers the tree's checker, and `C2-F2`'s `sed` matched nothing (C01/C02); the reviewer's run B reads `CONTROLS: match=17 mismatch=3` | **partly repaired:** the 14:16 battery (`0d8647a0…`) rewrites `C2-F2` as a prefixed `SETUP/rc2` leg and redefines `C1-F7` as the guard-fail-closed leg plus a new `C1-F7b`; the plan's printer-stub substance now lives only in the supplement's `C1-F10` (`SUPPLEMENT: match=2 mismatch=0`). No recorded run of the revised battery reads a final `CONTROLS:` line (run5 stops after `C1-F6`). |
| R24 | `item3` is role-blind (`9 total, 20 C1 and 7 C2` reads `i3=1`) and I1/I2 selectors miss lower-case `registry`, ASCII `->`, `at candidate` and the bare basename (A06–A11) | **named predicate-form gaps — routed.** If the frozen per-line reading stays, they are ceilings and the green must not be banked as more than it is. |
| R25 | the C2 summary is read with `grep -q`, so `… error=0 error=1` or two summary lines both read `value=5` (B09/B10) | **open — routed to the C2 counter seat/L1:** exactly-one summary line with field-parsed counts. |
| R26 | the default challenge parent is a fixed shared path that is not created, so a direct checker call reads `value=FAIL guard=0` on a resolved tree (D01) | **routed:** `makedirs(exist_ok=True)` or `mkdtemp()` per call; the wrapper is the only self-contained entry point today. |
| R27 | battery `INSTRUMENT` pins hash the lane while `c1()` executes the REF tree's copies (C04), so pins and executed bytes can disagree | **routed:** pin the executed bytes, or make `c1()` always use `$CHECKER`. |
| R28 | `C2-F5` rejects only a shim-blind fabricated transcript (a shim-aware stub scores 5, B01) and `wrap_trial` is defined twice (C05/C06) | **routed:** the control text must not overstate coverage; delete the dead first definition. |
| R29 | “two independent real runs” is not observable from output — a trial that measures once and replays reads 5 (B12) | **unnamed ceiling — must be added to the report's ceiling list** beside K2/K4. |
| R30 | sentinel hardening notes: the counter's scratch is `${HYAKU_SCRATCH}/…/c2-counter.$$` under the default umask (logs 644), and the K3 secret scan covers captured output, not the trial's self-deleted work dir | **routed as hardening, no defect found:** `umask 077` + `mktemp -d`; the sentinel's cleanup-disabled probe covers the work dir. |
| R31 | the C1 counter's report says `--selftest` runs 33 cases while its committed receipt reads `C1_CHECK_SELFTEST: PASS (32 cases)` | **routed as a number check:** the receipt is the evidence; whichever count the landed bytes produce must be quoted with its receipt. |
