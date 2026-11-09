# R70ScribeSkill — lane-facing draft for the round-70 OpenBao PKI capability

Author: R70ScribeSkill (scribe — skill text draft for the L1 to integrate)

Draft only. Nothing in this file is landed; the L1 (`KagiR70`) integrates. Every sentence below
is supported by `corpus/knowledge/openbao-pki-certificate-lifecycle.md` §Measured (round 70 —
OpenBao 2.7.2 dev server, 127.0.0.1, one pki mount) and by the frozen counter
`plans/round-70-c1.sh` (sha256 `8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed`).
Anything that is not supported by that §Measured section is marked `[INFERENCE]`.

Measured facts this draft may use (all from the entry's §Measured section unless noted):

- T1 root-internal — enforced — the `root/generate/internal` response has a non-empty
  `certificate` and no `private_key` key; shim SH1 (internal → exported) flips it. Observed: the
  response keys were `certificate expiration issuer_id issuer_name issuing_ca key_id key_name
  serial_number`; the `exported` call added `private_key` and `private_key_type`.
- T2 ttl-clamp — enforced — a `ttl=24h` request on a `max_ttl=1h` role succeeds and the leaf's
  notAfter − notBefore is ≤ 3660 s; shim SH2 (role without `max_ttl`) flips it. Observed: lifetime
  3630 s and the response warning `TTL "24h0m0s" is longer than permitted maxTTL "1h0m0s", so
  maxTTL is being used`. S170's "Cannot be greater than the role's max_ttl value" is a clamp on
  2.7.2, not a refusal.
- T3 domain-refuse — enforced — with `allowed_domains=r70.test allow_subdomains=true` the issue
  for `evil.example` fails and the issue for `ok.r70.test` succeeds; shim SH3 (role gains
  `allow_any_name=true`) flips it. Observed: the refusal text `common name evil.example not
  allowed by this role`, client exit 2.
- T4 revoke-crl — enforced — after `pki/revoke serial_number=<serial>` the serial (colons
  stripped, upper-case) is a `Serial Number:` line of `openssl crl -text` over the CRL read from
  `pki/cert/crl`; shim SH4 (revoke never sent) flips it. Observed: the revoke response carried
  `state revoked` and a `revocation_time`.
- T5 no-store — enforced — a leaf from a `no_store=true` role is not found by serial (the
  counter's shim SH5 flips the verdict; MT-1 shows the counter accepts a trial that checks only
  read or only list, so the conjunction rests on the landed trial's code), while a stored control
  leaf is readable and listed. Observed: `No value found at pki/cert/<serial>`, client exit 2.
- Trial command: `bash corpus/openbao-pki-trial.sh --work <scratch dir>` (exit 0,
  `OPENBAO_PKI_TRIAL: HOLDS holds=5 broken=0 error=0`); the frozen counter
  `bash plans/round-70-c1.sh <rev>` runs the same trial under five falsifier shims (each shim
  breaks its own test and no other).

## 1. PROVINCE.md — Core line

One `**Core, round 70 — …**` bullet in the same style as the round-48/49/51/57 bullets, inserted
after the round-57 bullet in the `## Core / Frontier / Adjacent (round 21)` list.

> - **Core, round 70 — OpenBao PKI certificate lifecycle, executed:** `corpus/openbao-pki-trial.sh`
>   runs five PKI-engine mechanics of `knowledge/openbao-pki-certificate-lifecycle.md` on the
>   pinned OpenBao 2.7.2 binary against a throwaway `bao server -dev` (127.0.0.1, in-memory
>   storage, random root token kept in scratch, synthetic names under `r70.test`): T1
>   `root/generate/internal` returns no CA private key, T2 a 24h request on a `max_ttl=1h` role
>   is issued clamped to ≤ 3660 s rather than refused, T3 a CN outside `allowed_domains` is
>   refused while one inside is issued, T4 a serial revoked by `pki/revoke` is on the mount CRL,
>   T5 a `no_store` leaf is not found by serial while a stored control is; each verdict flips
>   under its own falsifier shim (`plans/round-70-c1.sh`). Entry
>   `knowledge/openbao-pki-certificate-lifecycle.md`; no deployed CA, real certificate, HSM/KMS
>   key or ACME client is touched.

Support for each clause: trial path and the five T-mechanics and the shim flip — §Measured;
127.0.0.1 / in-memory storage / random root token in scratch / synthetic names under `r70.test` —
entry §Scope (the same scope sentence the entry carries) — the "no deployed CA / real certificate /
HSM-KMS key / ACME client" refusal is the entry's own §Scope sentence. The pinned-binary phrase
follows the round-49/51/57 bullets' own wording; the pin digest itself is the counter's
`PIN_BAO` (not the entry's §Measured section) — if the L1 wants the digest in the line it must
cite `plans/round-70-c1.sh`, not the entry.

## 2. SKILL.md — vault-ops decision-table rows

SKILL.md's `## Vault-ops decision table` has four columns: `Intent | Correct surface | Never |
Notes / expected output`. The PKI rows are new intents in that same table, in the same style as
the OpenBao-related row already present ("Judge whether a 'short-lived' / 'rotated' / 'revoked'
claim about a machine credential"). Four rows, one per custody decision the entry measures, each
citing the entry path.

> | Keep the CA signing key inside the mount | `pki/root/generate/internal` | `pki/root/generate/exported` — it returns the CA private key in the response | T1 measured on OpenBao 2.7.2: the internal response carries `certificate` and no `private_key` key; the exported call adds `private_key` and `private_key_type` (`corpus/knowledge/openbao-pki-certificate-lifecycle.md` §Measured) |
> | Bound a leaf's lifetime by the role, not the request | the role's `max_ttl`, and read the issued leaf's notAfter − notBefore | trusting a request's `ttl` to be honoured as sent, or reading a refusal into the API page's "Cannot be greater than the role's max_ttl value" | T2 measured: a `ttl=24h` request on a `max_ttl=1h` role **succeeds**, and the leaf's lifetime is ≤ 3660 s; the response warns `TTL "24h0m0s" is longer than permitted maxTTL "1h0m0s", so maxTTL is being used` — on 2.7.2 the bound is a clamp, not a refusal (same entry §Measured) |
> | Constrain which names a role may sign | the role's `allowed_domains` (with `allow_subdomains`) | `allow_any_name=true` on a role that is meant to be constrained | T3 measured: with `allowed_domains=r70.test allow_subdomains=true` the issue for `evil.example` fails (`common name evil.example not allowed by this role`) and the issue for `ok.r70.test` succeeds; matching was measured for one exact domain with subdomains only (same entry §Measured) |
> | Keep a leaf revocable by serial, or accept that it is not | stored certificates (the default), revoked through `pki/revoke` and found on the mount's CRL | `no_store=true` on a leaf that may have to be revoked later | T5 measured: a leaf from a `no_store=true` role is not found by serial while a stored control leaf is readable and listed; T4 measured: after `pki/revoke serial_number=<serial>` the serial is a `Serial Number:` line of `openssl crl -text` over the CRL read from `pki/cert/crl` (same entry §Measured) |

Notes for the L1 on this block:

- The `never`-column claim "it returns the CA private key in the response" is §Measured
  (T1's observed key list) — it is not marked `[INFERENCE]`.
- The T2 row's "clamp, not a refusal" reading is §Measured. The *operational consequence* of that
  clamp (a caller that reads only the exit status cannot tell it was clamped) is **not** in
  §Measured and is marked `[INFERENCE]` in the entry's own table; it is deliberately **not** put
  in this SKILL.md row, which states only what was measured.
- The T3 row says "one exact domain with subdomains only" because that is the scope of the
  measurement (§Measured T3 and the entry's §Does-not-establish bullet on `allowed_domains`
  matching). It is not a general claim about `allowed_domains`.
- The T5/T4 row does not claim that any relying party fetches or enforces the CRL — the entry's
  §Does-not-establish bullet rules that out.
- If a row wants the "one `pki` mount on a throwaway dev server" scope, say "on a throwaway dev
  server" (as the round-49/51/57 SKILL.md-side wording does) rather than implying a deployed CA.

## 3. corpus/README.md — coverage-map line

One row in the `## Coverage map` table (three columns: `Area | Entry | Source basis`), in the same
shape as the neighbouring "OpenBao … (executed)" rows (round-52 KV v2, round-57 audit-device,
round-60 AppRole, round-61 seal).

> | OpenBao PKI certificate lifecycle (executed) | `knowledge/openbao-pki-certificate-lifecycle.md` + `corpus/openbao-pki-trial.sh` | internal CA key generation, the role `max_ttl` clamp (not refusal), `allowed_domains` refusal, revocation onto the mount CRL, `no_store` leaves not found by serial — five verdicts on OpenBao 2.7.2 each flipped by a falsifier shim (`plans/round-70-c1.sh`); S170/S171; read 2026-11-08 |

Support: the five mechanics and the shim flip — §Measured; `S170/S171` — the entry's `source:`
line; "read 2026-11-08" — the entry's `verified-at:` date.

## 4. SCORECARD.md — capabilities-table row

One row in the lane `SCORECARD.md` `## Capabilities` table (four columns: `Capability | What it
can now do | Evidence pointer | First-working round`), in the same shape as the round-57/58/59/
60/61 OpenBao trial rows. This is the table the round-49/51/52/56/57 notes point at
("the latest first-working round is now N").

> | OpenBao PKI certificate-lifecycle trial | execute five PKI-engine mechanics against a throwaway OpenBao 2.7.2 dev server (127.0.0.1, random root token in scratch, synthetic names under `r70.test`): `root/generate/internal` returns no CA private key; a 24h request on a `max_ttl=1h` role is issued clamped to ≤ 3660 s (not refused); a CN outside `allowed_domains` is refused while one inside is issued; a serial revoked by `pki/revoke` is on the mount CRL; a `no_store` leaf is not found by serial while a stored control is. Each verdict flips under its own falsifier shim and no other | `bash plans/round-70-c1.sh <rev>` ⇒ `C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1` rc 0 (BASE `7bd34832` ⇒ `value=0 absent=1` rc 1); `bash corpus/openbao-pki-trial.sh --work <scratch>` ⇒ `OPENBAO_PKI_TRIAL: HOLDS holds=5`; `corpus/knowledge/openbao-pki-certificate-lifecycle.md`; `.ufo/waves/round-70/final/c1-candidate.txt` | 70 |

(The evidence pointer names the **file** `.ufo/waves/round-70/final/c1-candidate.txt`, not the
directory `.ufo/waves/round-70/final/`: the citations gate resolves a directory token as
`UNRESOLVED`. The candidate receipt holds `C1_PKI_TRIAL: value=5 … rc=0`; the BASE reading is in
`.ufo/waves/round-70/controls/receipts/f0-base.txt`.)

Support: the five mechanics — §Measured; the counter verdict string and the BASE reading —
`plans/round-70-c1.sh` and the receipts `.ufo/waves/round-70/final/c1-candidate.txt` (candidate:
`value=5 … rc=0`) and `.ufo/waves/round-70/controls/receipts/f0-base.txt` (BASE:
`value=0 absent=1`, rc 1); the trial's own final line — §Measured.

## 5. Integration notes for the L1 (not lane text)

These are observations from reading the lane against the four drafts above. They are the L1's to
act on; they are not lane text.

- **The stamp rows for the two new files are missing on the working tree.**
  `bash corpus/claim-ledger.sh docs` reads `DOC_AUDIT: BROKEN (entries=50 row_linked=47
  by_hand=3 undeclared=0 missing_ids=0 unpinned=1 …)` — `UNPINNED
  corpus/knowledge/openbao-pki-certificate-lifecycle.md (knowledge entry is not a row in the
  stamps file)`. At BASE (`7bd34832`) the same gate reads `DOC_AUDIT: CLEAN (entries=49
  row_linked=46 … unpinned=0 …)`, so this is introduced by the candidate, not inherited. Adding
  the two rows (`corpus/knowledge/openbao-pki-certificate-lifecycle.md`,
  `corpus/openbao-pki-trial.sh`) to `corpus/stamps.tsv` restores `DOC_AUDIT: CLEAN` in a scratch
  copy (measured: `entries=50 row_linked=47 by_hand=3 … unpinned=0`). The companion trial script
  `corpus/openbao-pki-trial.sh` also has no stamp row, where its siblings
  `corpus/openbao-audit-trial.sh` and `corpus/openbao-policy-trial.sh` do.
- **The `corpus/README.md` knowledge-entry counts move with the stamp rows.** With the two rows
  added, `python3 corpus/self-counts.py` reads `STALE RD-DOCS-ROWLINKED corpus/README.md:67
  claimed=46 live=47` and `STALE RD-DOCS-ENTRIES corpus/README.md:67 claimed=49 live=50`; the
  README row already states 47/3/50 on the working tree, so the numbers line up once the stamps
  are present (measured on a scratch tree carrying the working-tree README plus the two stamp
  rows: `OK RD-DOCS-ROWLINKED … claimed=47 live=47`, `OK RD-DOCS-BYHAND … claimed=3 live=3`,
  `OK RD-DOCS-ENTRIES … claimed=50 live=50`). The four `SC-SKILL-STAMPS`/`SC-SKILL-CLAIMS`/
  `PV-STAMPS`/`PV-CLAIMS` STALE rows (164 vs 173 stamps, 101 vs 102 claims) are **inherited at
  BASE** — the same four read STALE on a `git archive` extraction of `7bd34832` — so they are not
  this round's move.
- **The stamp count itself is a bound number, so adding rows moves a README sentence.**
  `corpus/self-counts.tsv` binds `RD-STAMPS` to the README's `| Revision stamps (data) |` row,
  which currently says **173 rows**, and `SC-SKILL-STAMPS` / `PV-STAMPS` to the SKILL.md and
  PROVINCE.md `164` figures. Measured on the scratch tree: one new stamp row makes the live count
  174 (`STALE RD-STAMPS … claimed=173 live=174`) and two make it 175 (`claimed=173 live=175`),
  while the same scratch tree still reads `STALE SC-SKILL-STAMPS … claimed=164 live=173` at one
  row and `live=175` at two. The L1 therefore has a choice to make and record: the README's
  "173 rows" sentence and the SKILL.md/PROVINCE.md "164" sentences are current-tense numbers bound
  to the live stamp count, so adding the round-70 stamp rows makes all three stale unless they are
  re-pinned through a journal (QUALITY QM14) — the inherited `164`-vs-`173` gap is the same
  defect one round older, not a new class. Note the `173` and `164` figures are *already* stale at
  BASE for the `164` pair, so the round-70 landing inherits that gap; the README `173` figure is
  current at BASE and would become stale **only** if the L1 adds stamp rows.
- **`corpus/claims-declared.sh` needs the manifest row and the plan heading together.** With the
  working tree's `corpus/claims-declared.tsv` row `70 C1 coverage` but the frozen plan's heading
  spelled `## Claim C1 — coverage (capability acquisition): …`, the gate reads `MISMATCH 70 C1
  plan-heading-not-coverage`; the contract's heading form is `## <claim> — <axis>:`. The
  working tree's plan Amendment A2 supplies that heading (`## C1 — coverage: declared-axis
  heading (Amendment A2, appended with A1)`) — note that the heading's axis text is
  `coverage:` followed by the rest of the line, which the contract's `index($0, want) == 1`
  test accepts. With both in place the gate reads only the two inherited round-69 mismatches
  (`MISMATCH 69 C1 tagged-rows-0`, `MISMATCH 69 C2 tagged-rows-0`), which are also present at
  BASE.
- **The `## Round 70 — post-move` SCORECARD row needs the `[C1]` tag and the `coverage` axis as
  its first cell.** The declared-axis gate's post-move leg reads one table row tagged `[C1]` inside
  `## Round 70 — post-move` and compares that row's first cell to the manifest axis
  (`coverage`). The round-69 rows are tagged `[C1, missed]` / `[C2, missed]` — that spelling is
  why the gate reports `tagged-rows-0` for round 69 at BASE.
- **Self-description sweep SD5 and SD8 counts are inherited; SD6 is not comparable across the
  two trees.** The working tree reads `SELF_DESCRIPTION: MISMATCH n=42 (SD1=0 SD2=0 SD3=0
  SD4=0 SD5=4 SD6=37 SD7=0 SD8=1 SD9=0)`. A `git archive` extraction of BASE reads `n=312 (SD5=4
  SD6=307 SD8=1)`, but SD6 is **not** a like-for-like comparison: SD6 counts the `UNRESOLVED`
  lines of `claim-ledger.sh citations`, and an archive extraction carries none of the untracked
  `.ufo/waves/round-6x/` artifacts, so its citation population is a different set (BASE's 307
  break down as 274 `ufo`, 27 `sibling`, 5 `local`, 1 `shorthand` classes). What **is** comparable:
  SD5's four red ids (`R25-02`, `R29-01`, `R29-02`, `R38-03`) and SD8's `SCORECARD.md:1701` range
  `'M44-1..M44-3'` row are the same four/one at BASE and on the live tree, so both are inherited.
  One live-tree SD6 line does name a round-70 path: `.ufo/waves/round-70/capture/S17x.body` — a
  **placeholder** in the round-70 lesson (the committed captures are `S170.body`, `S171.body`,
  `S172.body`), so it resolves to nothing. That is a lane-text defect the L1 owns, not a gate
  regression.
- **Every other round-70 citation resolves on the live tree.** `bash corpus/claim-ledger.sh
  citations` on the live tree reads `CITATION_GATE: BROKEN (cites=5542 docs=180 unresolved=36
  ephemeral=1 labeled=26)` and **no** `UNRESOLVED` line names a round-70 path: the entry's
  `.ufo/waves/round-70/final/l1-probe-observations.txt`, the lesson's
  `.ufo/waves/round-70/final/c1-candidate.txt`, `.ufo/waves/round-70/w1/R70Connector.md`,
  `.ufo/waves/round-70/w1/R70Scout/frontier.md` and the two
  `.ufo/waves/round-70/w1/R70ScribeLesson/check-*.py` scripts all exist on disk and resolve. The
  36 unresolved lines are the lane's inherited set (a scratch-tree run reports far more only
  because a `git archive` extraction carries none of the untracked wave artifacts — that count is
  an artefact of the measurement, not of lane state). One exception is in the L1's hands: the
  round-70 **SCORECARD capability row** cites `.ufo/waves/round-70/final/` as a *directory*, and
  the citations gate reads that token as `UNRESOLVED` — the pointer must name a **file**
  (`.ufo/waves/round-70/final/c1-candidate.txt`), not the directory.
- **The L1's working-tree edits make seven stamp rows STALE.** `bash corpus/claim-ledger.sh verify`
  on the live tree reads `STALE corpus/QUALITY.md sha=497a67ec2cdc->b823b5f2d9f3 lines=338->339
  bytes=82317->83506`, and the same for `corpus/README.md`, `corpus/source-fetches.tsv`,
  `corpus/SOURCES.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`. Measured attribution: for all
  seven, the stamp's digest equals the **BASE** blob's digest (`git show 7bd34832:<path>`), so the
  stamps were last pinned at BASE and any edit since then — the candidate's `corpus/SOURCES.md` +
  `corpus/source-fetches.tsv` additions **and** the L1's working-tree edits to `PROVINCE.md`,
  `SCORECARD.md`, `corpus/README.md`, `corpus/QUALITY.md`, `LOG.md` — leaves the row stale. A
  reviewed re-pin (`bash corpus/claim-ledger.sh stamp <paths>`) at landing is what the lane's own
  QUALITY QM5 requires: "a pin that lags the artifact's bytes is a defect, not inherited debt".
  Attribution, measured by running `verify` on a `git archive` extraction of the candidate
  (`0d225553`): the candidate commit itself leaves **two** stamp rows stale —
  `STALE corpus/source-fetches.tsv sha=d5af7ba9e9d7->5d0516e9e2ab lines=203->206` and
  `STALE corpus/SOURCES.md sha=9ca0ffaa3ad0->34d37d9085ed lines=322->325` — because it added
  three rows to each without re-pinning. The live tree's other five (`corpus/QUALITY.md`,
  `corpus/README.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`) are stale because of the **L1's
  working-tree edits**, not the candidate.
- **`corpus/claim-ledger.sh verify` reads FAIL rows, and only one of them changes reason because
  of this round.** Measured on the live tree: `FAIL R11-08 reason=exit-mismatch exit=1 want=0`
  (the citations gate, whose `unresolved=0` expectation the lane does not meet), `FAIL R12-03
  reason=verdict-not-final exit=0` (the stamps-count row still expects `^125$` against a live 173),
  `FAIL R13-01 reason=verdict-not-final exit=0` (the round-heading cardinality row still expects
  `^73$`), and `FAIL R14-01 reason=exit-mismatch exit=1 want=0` (the docs gate — the unpinned entry
  of note 1). At BASE the same rows already read FAIL: `R11-08 exit-mismatch`, `R12-03
  verdict-not-final`, `R13-01 verdict-not-final`, and `R14-01 reason=verdict-not-final exit=0` (the
  docs gate was CLEAN at BASE but its *expectation* — `DOC_AUDIT: CLEAN (entries=38 row_linked=35
  …)` — no longer matches the live `entries=49 row_linked=46`). So **R14-01 was already red at
  BASE**; what this round changes is its **reason**, from a stale expectation
  (`verdict-not-final`) to a broken gate (`exit-mismatch`, exit 1), and the fix is the same
  reviewed re-pin the stale expectation needs plus the two new stamp rows. The other FAIL rows
  (R21-02, R22-03, R24-05, R24-06, R24-15, R25-02, R31-02, R33-02, R34-03 and the rest) are present
  at BASE too; the QM12 substitute applies to the host-touching rows.
- **The candidate introduces a release-clock regression that turns the `R36-03` ledger row red.**
  This is the one gate regression this seat measured that is **introduced by the candidate**, and
  it is the L1's to fix. `bash plans/round-36-c3.sh` at BASE (`git archive` extraction of
  `7bd34832`) reads `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14
  derived=17)`; at the candidate (`0d225553`) the same command reads
  `UNBOUND S170` / `UNBOUND S171` and
  `RELEASE_CLOCK: FAILED (on_release=34 bound=32 unbound=2 observed=32 fired=14 derived=17)`.
  Mechanism, read from `corpus/release-clock.py:559-583`: a `SOURCES.md` row whose `recheck` cell
  is `on-release` must have a matching row in `corpus/release-clocks.tsv`; S170 and S171 carry
  `on-release` (field 11 of each row) but **neither has a clock row** — the table has 33 lines and
  no `S170`/`S171` row — so both are UNBOUND. Because `corpus/claim-ledger.tsv` row `R36-03` runs
  that command and expects `RELEASE_CLOCK: CLEAN`, the row reads `FAIL R36-03 reason=exit-mismatch
  exit=1 want=0` on the candidate and on the live tree, while it is **not** FAIL at BASE — the
  clean re-run of `verify` on fresh BASE and candidate extractions gives `BASE FAIL count: 20`,
  `CAND FAIL count: 21`, with `R36-03` the single added row. The lane's own QUALITY **QM63** names
  this exact requirement: "A landing that adds a registry row runs the release-clock gate
  (`bash plans/round-36-c3.sh`, ledger R36-03) on its candidate tree: an `on-release` row needs a
  bound release clock in the same commit, otherwise its cadence is a dated `NNd`." So the L1 has
  two in-contract fixes: bind a release clock for S170/S171 in `corpus/release-clocks.tsv` (the
  OpenBao release feed is a registry row per the round-33/36 clock rows), or change the two
  `recheck` cells from `on-release` to a dated cadence. **Leaving it as-is lands a red ledger
  row.**
  The sibling gate `python3 -I -B corpus/recheck-replay.py` is unaffected: `RECHECK_REPLAY: CLEAN
  (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` on both BASE and
  the candidate (the entry's own `recheck:` line is an on-release clock, which that gate does not
  replay — it replays the ten offline `recheck:` clocks of other entries).
- **The `claim-ledger.sh cells` gate is red at BASE too.** On the live tree it exits 2 with
  `claim-ledger: scorecard section '## Round 69 — pre-move (repo `264917a`, round-68 spot-check
  tip)' does not carry all six axes exactly once (found=0 missing=depth coverage operability
  freshness calibration adjacency)`, plus a set of `UNCITED SCORECARD.md:<line>` rows. A BASE
  extraction reads the **same** messages: normalising away the line numbers, the two runs are
  identical (32 operability, 24 calibration, 22 freshness, 22 adjacency, 14 depth, 4 coverage
  UNCITED rows, and the same round-69 pre-move section error). So the cells gate carries **no**
  round-70-specific message — the round-70 post-move section adds none — and its redness is
  inherited debt about the round-69 pre-move section, not this round's move.

## Provenance of this draft

- Read: `plans/round-70.md`, `plans/round-70-c1.sh`, `plans/round-70-controls.sh`,
  `.ufo/waves/round-70/controls/receipts/{README.txt,counter.sha256,f0-base.txt,p1.txt}`,
  `corpus/openbao-pki-trial.sh`, `corpus/knowledge/openbao-pki-certificate-lifecycle.md`
  (candidate commit `0d225553c22f686df24454040102d0502eda5c42` and the working-tree amendment),
  `corpus/QUALITY.md`, `corpus/SOURCES.md` rows S170–S172, `corpus/source-fetches.tsv`,
  `corpus/lessons/round-70.md`, `SKILL.md`, `PROVINCE.md`, `SCORECARD.md`, `corpus/README.md`,
  `corpus/self-counts.tsv`, `corpus/claims-declared.tsv`, `corpus/claim-ledger.tsv`,
  `corpus/stamps.tsv`, `corpus/claims-declared.sh`, `corpus/claim-ledger.sh`,
  `corpus/self-counts.py`, `corpus/self-description-sweep.sh`.
- Measured by this seat (read-only, no mutating git/jj, no lane write outside this seat dir):
  `bash corpus/claim-ledger.sh docs` on the live tree and on a `git archive` extraction of
  `7bd34832`; `python3 corpus/self-counts.py` on the live tree and on a `git archive` extraction of
  `7bd34832`; `bash corpus/claims-declared.sh --root .` on the live tree and on scratch
  extractions of `7bd34832` and `0d225553` (with and without a `70 C1 coverage` manifest row);
  `bash corpus/self-description-sweep.sh --root .` on the live tree; `sha256sum` of
  `plans/round-70-c1.sh` (matches the committed `counter.sha256`) and of the candidate's
  `corpus/openbao-pki-trial.sh` (matches the P1 positive control's copy).
- No tool was installed or upgraded by this seat.
