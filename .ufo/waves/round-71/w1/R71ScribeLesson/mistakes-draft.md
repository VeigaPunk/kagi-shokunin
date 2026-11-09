# Round 71 — mistakes draft (R71ScribeLesson, uncommitted draft)

Lane `kagi`, round 71, attempt 1. Claim BASE `e0e9603a`, candidate `39e76bc7`. Draft only: nothing
here is landed. Format per candidate: class · evidence pointer · captured-by · fix · how the fix is
shown able to fail. Receipts for the "shown able to fail" legs: `receipts.txt`, `sweep.sh`,
`anchors.sh` in this directory (copies of the scratch fixtures; scratch itself is removed).

## Answer to the lead's question

No lane rule could catch the POST overwrite before the trial ran. The S170 capture did carry the
sentence ("It does not update only the provided fields.", count 2) and the heading "Update issuer"
(count 2) at the round-70 capture, so a locate check would have passed at any time. No QUALITY row
(QA1–QA10, QM1–QM101) names the write semantics of a mutating call, no gate reads the `§` anchors
of a registry row against the entry that cites it, and the trial's own verdict only fired after the
write had already reset the issuer. The catch came from the first T6 run and the L1 probe.

## Candidates

- **M71-1 — a trial wrote to an existing issuer with a partial POST and reset `issuer_name`.**
  class: mutating-call semantics unread before a trial runs (the source sentence existed in the
  mined capture; no rule asked that each write the trial makes be checked against it).
  evidence: `.ufo/waves/round-71/final/l1-probe-observations.txt` lines 2–5 (`after-write`
  `issuer_name: ''`; `read-by-name-after-write: unable to find PKI issuer for reference: r71short`;
  `patched` restores it); `corpus/openbao-pki-issuer-trial.sh:32-33` (the comment that records the
  reset) and `:142` (landed: `q write pki/issuer/r71short issuer_name=r71short
  leaf_not_after_behavior=truncate`); `.ufo/waves/round-70/capture/S170.body` ("It does not update
  only the provided fields.", "Update issuer"); `corpus/knowledge/openbao-pki-issuer-revocation-channels.md:35`.
  captured-by: none before the trial. The trial's T6 verdict fired after the reset (see M71-4 for
  the wrong reason it would print).
  fix: (a) landed at `:142` — re-send `issuer_name` (done on the candidate). (b) proposed QM row: a
  trial write to an existing registry object either uses `patch` or names every field it relies on,
  and the sentence stating that object's update semantics is located in the cited capture
  (`corpus/rendered-text-v1.py locate`, count ≥ 1) before the write is coded.
  shown able to fail: `sweep.sh` (SWEEP-POSTWRITE, comment lines excluded, any `write`/`patch` to
  `pki/issuer/<ref>` without `issuer_name=`): CLEAN rc 0 on the landed trial; FLAG rc 1 on the
  pre-fix line (`q write pki/issuer/r71short leaf_not_after_behavior=truncate`, a scratch fixture).
  Ceiling of the sweep: it reads one field name. A write that re-sends `issuer_name` but drops
  another relied-on field passes it.

- **M71-2 — the S170 registry row's anchor cell does not name four sections the entry cites.**
  class: record (registry anchor coverage; QA1 requires an anchor per claim, and the row is what
  a reader follows to the section).
  evidence: `corpus/SOURCES.md:170` anchor cell names §Generate key, §Create/Update role parameters,
  §Generate certificate and key (`ttl`), §Revoke certificate; the entry's `source:` line (line 3)
  cites §Update issuer, §Set revocation configuration, §OCSP request, §Revoke certificate with
  private key. All four headings are present in `.ufo/waves/round-70/capture/S170.body` (counts
  2, 2, 3, 2). The plan §Frontier step says "S170 re-opened … without a row change", so the gap was
  a choice, not an accident. S173's anchor cell covers its own one cited section.
  captured-by: none. `git grep '§'` over `corpus/*.sh`, `corpus/*.py`, `plans/*.sh` finds prose
  mentions only; the census checks `used-by` resolution, not anchors.
  fix: extend the S170 anchor cell with the four sections; record the old and new cell values in the
  lesson (QM14 journal form: the cell changed, the pin did not).
  shown able to fail: `anchors.sh <entry> corpus/SOURCES.md S170` → `SWEEP-ANCHORS: FLAG missing=4`
  rc 1 on the landed tree; the same check on a scratch copy of `SOURCES.md` with the four sections
  appended → `SWEEP-ANCHORS: CLEAN row=S170` rc 0; `anchors.sh … S173` CLEAN rc 0 on the landed tree
  (the check is not failing on everything). Scratch copy: `SOURCES.S170-anchors-fixture.md` here.

- **M71-3 — the counter's verdict line carries no named ceiling; the ceiling lives in prose.**
  class: instrument reporting (a declared limit of a frozen counter does not travel with its
  value).
  evidence: `plans/round-71.md:81-85` ("Named ceiling (not closed by this counter)"); the counter's
  header `plans/round-71-c1.sh:49`; the verdict-line probe
  `grep -E 'C1_PKI_ISSUER_TRIAL: (value|SETUP)' plans/round-71-c1.sh | grep -c -i ceiling` → 0
  (receipts.txt). The round-70 spot-check (§5 item 3, M70-5) routed the same ceilings to the next
  PKI counter in prose; the entry's "Does not establish" carries them again.
  captured-by: partial — QM55 requires an open named *defect* to be quoted beside its verdict
  (`KNOWN_DEFECT <id>`). A declared ceiling is a limit the freeze accepted, not a defect, so QM55's
  text does not reach it, and it did not fire on this freeze.
  fix: proposed QM102 (text only; the counter is frozen and must not change this round): a quoted
  value of a frozen counter carries its named ceiling beside it in the quoting artifact (report,
  entry or lesson).
  shown able to fail: not exercised on a report (none is written). The rule's grep leg:
  `grep -n 'C1_PKI_ISSUER_TRIAL: value' <quoting file>` with no `ceiling` token in the next 3 lines
  must flag. [INFERENCE] until run on the round-71 report.

- **M71-4 — the trial reports every failed `issue` as `BROKEN long-leaf-refused`.**
  class: verdict-reason honesty (a BROKEN verdict names a cause the test did not measure).
  evidence: `corpus/openbao-pki-issuer-trial.sh:144-151`: when the T6 `issue` call fails for any
  reason, the else-branch prints `verdict T6 BROKEN "long-leaf-refused"`. The POST reset of M71-1
  makes the issuer reference fail, and the trial would print a refused long leaf, not a lost issuer
  name (the probe's `unable to find PKI issuer for reference` line, `l1-probe-observations.txt:5`,
  is the text the trial never reads). The first-run output is not in the tree (no receipt under
  `.ufo/waves/round-71/final/` holds it); this reading is from the code, not from a run. [INFERENCE
  about the first run; the code path is measured.]
  captured-by: none. The counter reads verdict tokens (HOLDS/BROKEN) under shims, not reason
  strings. SH6 (drop `leaf_not_after_behavior`) and a lost `issuer_name` both produce the same
  BROKEN token and the same reason, so the counter cannot tell them apart.
  fix: on issue failure, re-read `pki/issuer/<ref>`; if the reference is gone, verdict ERROR
  `issuer-reference-lost`; BROKEN only when the issuer reads back and the server refuses the leaf.
  This changes the trial, so it is a new candidate and not an in-place edit of the frozen counter's
  control set; the integrator decides.
  shown able to fail: proposed fixture — a stub `bao` that answers `server`/`status` and fails
  `write pki/issuer/.../issue/...` with the reference-lost text. Not exercised (a fixture stub that
  starts a server through the trial's launch block is not built in this seat).
