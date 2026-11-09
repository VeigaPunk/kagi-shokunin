Author: R71ScribeLesson (scribe)

# Round 71 — scribe seat (mistake mining and considerthese)

Lane `kagi`, round 71, attempt 1, wave `w1`. Read-only on the lane; no commit, no mutating git or jj,
no `bao` server started. Drafts are in `.ufo/waves/round-71/w1/R71ScribeLesson/`:
`mistakes-draft.md`, `considerthese.md`, `receipts.txt`, `sweep.sh`, `anchors.sh`, and the scratch
fixture `SOURCES.S170-anchors-fixture.md`.

## Read

`corpus/lessons/round-70.md` (shape of `## Claims`, `## Gate`, `## Mistakes`); `corpus/lessons/round-66-verifier-spotcheck.md` through `round-70-verifier-spotcheck.md` (the spot-check shape; round 70 §5 item 3 routed the counter blind spots to the next PKI counter); `considerthese/2026-10-26.md`; `corpus/QUALITY.md` (QA1–QA10, QM1–QM101, the bar); `.ufo/waves/round-71/final/l1-probe-observations.txt` and `l1-probe-issuer-update.sh`; `corpus/openbao-pki-issuer-trial.sh`; `corpus/knowledge/openbao-pki-issuer-revocation-channels.md`; `corpus/SOURCES.md` rows S170 and S173; `plans/round-71.md` and `plans/round-71-c1.sh` (header and verdict lines only); `corpus/release-clock.py:789`.

## Mistakes (drafted; detail and receipts in `mistakes-draft.md`)

- **M71-1** — the POST overwrite (`bao write pki/issuer/<ref>` reset `issuer_name` to `""`). No lane rule could have caught it before the trial ran: the S170 capture carried "It does not update only the provided fields." and the "Update issuer" heading at round 70, but no QUALITY row covers the write semantics of a mutating call. Landed fix: `issuer_name` re-sent at `corpus/openbao-pki-issuer-trial.sh:142`. Proposed sweep `sweep.sh`: CLEAN on the landed trial (rc 0), FLAG on the pre-fix line (rc 1).
- **M71-2** — the S170 row's anchor cell omits four sections the entry cites (§Update issuer, §Set revocation configuration, §OCSP request, §Revoke certificate with private key). All four headings are in the capture. No gate compares anchors. `anchors.sh … S170` → FLAG missing=4 on the landed tree, CLEAN on a scratch copy with the four appended; S173 CLEAN.
- **M71-3** — the frozen counter's named ceiling is in prose only; its verdict line carries no ceiling (`grep -c -i ceiling` over the verdict lines → 0). QM55 covers open defects, not declared ceilings. Proposed QM102 (text only).
- **M71-4** — the trial's T6 `else` branch prints `BROKEN long-leaf-refused` for any failed `issue` call, including a lost issuer reference. Code-read ([INFERENCE] for the first run, whose output is not in the tree). Proposed fix: ERROR `issuer-reference-lost` after a re-read; not exercised.

## considerthese

Proposal 3 (`considerthese/2026-10-26.md` lines 60–62, "Mark known-defective instrument output") is the one still-unimplemented proposal that fits round 71. Mechanism unimplemented (`KNOWN_DEFECT` in `corpus/release-clock.py`: 0). Its premise is stale: the regex at `corpus/release-clock.py:789` matches `Python 3.15.1.` (measured with Python `re.match`; the whole clock was not run). It cannot land as proposed. Its transferable part can land as a text-only QUALITY row (proposed QM102, from M71-3) without editing the frozen counter. Details in `considerthese.md`.

## Tooling and process

No tools installed. No `bao` process started. Scratch `/fast/scratch/hyaku/kagi-r71/R71ScribeLesson` used for the planted fixture and the anchor fixture; receipts copied into the wave dir; scratch removed before yield.

## Not exercised

- The fix for M71-4 (stub `bao` fixture through the trial launch block).
- QM102's grep leg on a quoting artifact (no round-71 report exists yet in this seat's view).
- The whole `release-clock` run for the proposal-3 premise.
- Host state at yield: one `bao server -dev` (pid 3655587, 127.0.0.1:47753) was running. This seat started none and did not kill it (not its process; a sibling seat's dev server is the likely owner, unverified).

SEAT-STATUS: complete mistakes-draft and considerthese written; four candidates with receipts for the sweep legs; two proposed fixes and one check not exercised (M71-4 fixture, QM102 leg, whole clock run)
