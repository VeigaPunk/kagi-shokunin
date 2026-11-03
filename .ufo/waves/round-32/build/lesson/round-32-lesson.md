source: S072
verified-at: [L1-FILL] — the L1 records the landing verification date and the landing receipts here
recheck: 180d — re-run `bash corpus/self-description-sweep.sh` (C1, expect `SELF_DESCRIPTION: CLEAN n=0`), `bash corpus/op-ref-probe.sh --dotenv-bytes` (C2, expect last line `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0) and `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` after any registry, entry, scorecard-heading or ledger-row change

# Round 32 — self-description sweep (SD1–SD6); op 2.41.1 byte pin

author: lane kagi (`kagi-shokunin <kagi@shokunin.local>`).
round: 32 (kagi; one v1 wave, 13 seats).
plan: `plans/round-32.md`, committed alone at `507dd9f` before any round-32 data
(every predicate, counter, kill rule and target is fixed there; this lesson does not
restate them as new decisions).
BASE: `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b` (round-31 verifier spot-check, lane
`master`).

Sources this lesson reads: `plans/round-32.md` (frozen contract); `corpus/lessons/round-31.md`
(header and Gate/Mistakes table shapes; Corrigenda item 2 is the M31-6 text reproduced in
§Corrigenda R4); `corpus/lessons/round-31-verifier-spotcheck.md` §3 and §7 (the routed
defects R1–R6 and the measured S063 count); `considerthese/2026-10-26.md` proposal 4;
`.ufo/waves/round-32/build/src-open/S072-body.html` (the ScoutOp capture of the 1Password
CLI release history, opened 2026-11-03); `corpus/SOURCES.md` and `corpus/source-fetches.tsv`
(row and capture shapes). Measurement receipts: `.ufo/waves/round-32/build/probe/`
(`op-version.txt`, `base-probe.txt`, `base-counter.txt`, `selftest.txt`).

## Gate

This round opened one new page and mined one carried proposal. The new registry row is
**S072** (1Password CLI release history — the version-identity source C2 rests on); its
capture is the ScoutOp seat's fetch of the page (`curl -fsSL --max-time 30`; HTTP 200,
decoded-body sha256 `d1fc423ba0ec4119679d9f9631031fb30834fb4da13cd701a410057b256d8209`,
516927 bytes — the seat's fetch record, 2026-11-03; the body is on disk at
`src-open/S072-body.html`). The seat's row and capture-row drafts are on disk
(`S072-row.md`, `S072-capture-row.tsv`; the capture row binds the quote below, HTTP 200,
same digest and byte count); the seat's report `ScoutOp.md` was not yet on disk when this
draft was written — the L1 re-cites it at landing. The quote below is copied from the
capture's 2.41.1 entry (heading inside
`article id="v2410101"`, capture lines 815–818) in the lane's `rendered-text-v1` locating
form — the normalizer converts the link tag before `)` to a space, so the space before `)`
is required for the locate to match (count=1), not paraphrased. The 2.41.1 entry carries
`Downloads`, `Improvements` and `Security` headings, a lead note and three bullets (Go and
CLI base-image security updates; an `op read` help-text example) — it carries no
dotenv/`op run` text, so the row is cited for release identity only.

| Candidate | Decision and basis | URL, access date, located quote |
|---|---|---|
| **S072** 1Password CLI release history (new row) | ADMIT, tier A docs, 180d; scope "op CLI 2.41.1 release identity"; status `mined`; used-by `corpus/knowledge/op-ref-consumption.md` (all plan-fixed) | https://app-updates.agilebits.com/product_history/CLI2 ; 2026-11-03; quote "2.41.1 (build #2410101 ) – released 2026-10-21" located at the `article id="v2410101"` heading (capture `src-open/S072-body.html` lines 815–818; `rendered-text-v1` form, locate count=1) |
| `considerthese/2026-10-26.md` proposal 4 — a `considerthese/BACKLOG.md` status table | **REJECT.** The lane-status surface the proposal asks for already exists: the `SCORECARD.md` `lane-status:` line adopted in round 31 from proposal 2. `considerthese/` is operator input and is never edited by the lane. Flip condition: a second lane-status surface appears that the SCORECARD line cannot carry. | `considerthese/2026-10-26.md` line 64–65, read 2026-11-03; quote "a status table would make these files a short diff instead of a re-read" (the line-65 half of the proposal sentence) |
| NIST SP 800-57 family status (`merge/kagi/` entries `nist-key-management-family-status.md`, `nist-key-management-parts-withdrawal.md`) | **DEFERRED to the next round.** Its entries need in-round re-grounding that the two-claim cap cannot absorb with the routed fixes. No registry row, no page opened this round. | none this round — no URL, no access, no quote (deferral, not an admission) |

Non-author spot-check: `pending — the round's non-author verifier records agree/disagree here`.

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M32-1 | doc self-description outlived a state change (frontier bullets and a tombstone kept after two themes moved to core; a stale citation; a lesson table missing a row named in its own text) | `corpus/lessons/round-31-verifier-spotcheck.md` §7 R1, R4, R6; the `citations` BASE output (SD6) | `none` — no gate compared frontier-vs-core, mistake-table-vs-corrigenda, or red-set-vs-calibration cells | `corpus/self-description-sweep.sh` SD1–SD6, with planted-mismatch selftest fixtures that each fail red before the fix (the fix is shown able to fail) |

## Corrigenda

Appended corrections to `corpus/lessons/round-31.md` (appended, not rewritten — the
round-30/31 corrigenda pattern). Each cites the superseded text it corrects.

- **R3 — appended correction: S063 `Audience` count precision.** Superseded text
  (round-31 `## Gate`, S063 row): "`Audience` occurs twice, both in the response section".
  Corrected: `Audience` occurs on two lines of the fetched page — line 343 (Response
  Elements) and line 593 (inside an example XML response) — so line 593 sits in an example
  response, not in the request section. Basis: `corpus/lessons/round-31-verifier-spotcheck.md`
  §7 R3 and §3 (measured 2026-11-03 on the capture whose sha matches). The round-31 Gate text
  stays as written; this item supersedes it.
- **R4 — appended correction: the M31-6 row was missing from the round-31 Mistakes table.**
  Superseded state: M31-6 existed only in the round-31 Corrigenda (item 2), while CORPUS
  requires one row per mistake under `## Mistakes`, and SD4 counts an `M31-n` id named in the
  lesson with no `^| M31-n ` row. The row below reproduces M31-6's content from that
  Corrigenda text (class, evidence, captured-by, fix), appended without changing the
  Corrigenda item itself.

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M31-6 | absence-sweep-language-blindness | the round-31 gate asserted "the JP product page carries no release status (0 status hits)" from an English-needle sweep (`パブリックプレビュー`/`public preview`/`ベータ` → 0); the late seat's Japanese needles (`一般提供されていません`, `プレビュー版`, `カスタムOIDC構成`) located the page's product-level status — 「まだ一般提供されていません。Credential Brokerは現在、すべてのEnterprise Password Managerのお客様向けにプレビュー版が公開されています。これにはGitHub ActionとカスタムOIDC構成が含まれます。」 — recorded as product-level and explicitly not used as a per-feature status (the round-22 uniform-preview rejection still governs) | QA6/QM10 (a negative claim carries its sweep — the sweep's needles must cover the source's own languages, not only the entry's) | the landed entry quotes the JP status with its sweep limitation; the S071 row's scope cell records it; a future absence sweep over a non-English source runs needles in that source's language (shown able to fail: the English-needle sweep IS the red witness — it reported the absence the page contradicts) |

## Registry changes

- **New row S072** (1Password CLI release history): status `—` → `mined`; opened
  `—` → `2026-11-03`; recheck `—` → `180d`; used-by `—` →
  `corpus/knowledge/op-ref-consumption.md`. Landing census row count expected
  71 → 72 (`plans/round-32.md` §Frontier step); measured before/after values are
  `[L1-FILL]` from the census commands in §Measurements.
- **Capture row:** `corpus/source-fetches.tsv` gains one S072 capture row in the S070/S071
  column order (draft path `.ufo/waves/round-32/build/S072-capture-row.tsv`); its line number,
  sha256 and byte count at landing are `[L1-FILL]`.
- **Pre-existing rows:** the plan expects no `status` / `recheck` / `used-by` change on any
  existing row (S001–S071). Any other old→new is to be listed here at landing: `[L1-FILL]`.

## Measurements

Exact commands from `plans/round-32.md`; the L1 fills every measured cell. Expected values
are the plan's frozen expectations, not results.

| Claim | Command (exact) | Predicate / expected | Measured |
|---|---|---|---|
| C1 (do-nothing control at BASE) | `bash corpus/self-description-sweep.sh` at BASE `32c35fe` | SD1=2 SD2=2 SD3=0 SD4=1 SD5=3 SD6=2, sum 10 (plan table) | `[L1-FILL]` |
| C1 (target) | `bash corpus/self-description-sweep.sh` at the measured revision | `SELF_DESCRIPTION: CLEAN n=0 — the sum of checks SD1–SD6 is zero at the measured revision.` | `[L1-FILL]` |
| C1 (fix-pinning) | the sweep's planted-mismatch selftest — the plan fixes the requirement, not an invocation string; the L1 records the exact command here | all six fixtures fail red, each exit 1 naming its check; a fixture that stays clean is a defect | `[L1-FILL]` |
| C2 (version in §11 range) | `V=$(op --version \| awk '{print $1}')` then `awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md \| grep -c "op \`$V\`"` (lane root) | BASE 0 (range names 2.40.0/2.41.0 only — receipt `probe/base-counter.txt`); target ≥ 1 for `V=2.41.1` | `[L1-FILL]` |
| C2 (probe) | `bash corpus/op-ref-probe.sh --dotenv-bytes; echo "exit=$?"` | last line `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, `exit=0` | `[L1-FILL]` |
| Frontier census before | `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | exit 0, rows = 71 | `[L1-FILL]` |
| Frontier census after | same command at the landed revision | exit 0, rows = 72 (S072 only) | `[L1-FILL]` |
| Row count | `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` | 71 before, 72 after | `[L1-FILL]` |

## Limits

- **C1/SD5 counts naming, not the score's honesty.** SD5 checks whether the red ids named on
  the `lane-status:` line appear in the latest `calibration` row; the calibration score
  remains author-assigned. R25-02, R29-01 and R29-02 stay red (operator-owned), and the
  sweep closing SD5's three names does not make those rows pass.
- **C1/SD3 covers path existence only,** not the claims the SHONEN lines cite. A line whose
  path exists can still be substantively wrong.
- **C1's fix-pinning is the selftest, not the green run.** Each SD check needs a
  planted-mismatch fixture that exits 1 naming that check; a sweep that reports CLEAN
  without those red witnesses is not shown able to fail.
- **C2 is representation fidelity for six classes only, on the exact installed version.** The
  probe shows what bytes the child receives for the six `DOTENV_BYTES_CASE` ids on
  `op 2.41.1`; it says nothing about ref-resolved values, item reads, vault/account facts, or
  handler behaviour. The downstream `$(...)` trailing-LF loss is a shell fact and was not
  re-measured.
- **C2's version binding is a string match, not a probe input.** The first counter half counts
  any `` op `2.41.1` `` mention inside the §11 range (the §11.1 scope disclaimer alone
  satisfies it) and the probe never reads the version; the binding is the frozen string match
  plus two separate receipts, in sequence. The build-stage reviewer reports this as `ReviewOp.md`
  F2/F3; the predicate is frozen, so it is reported, not edited.
- **No vault contact.** Allowed op use was `op --version` and
  `bash corpus/op-ref-probe.sh --dotenv-bytes`; no signin/account/item/read/inject/run. The
  `the-janitor` handler is absent from this host — expected, not a defect, and nothing ran
  through it.
- **S072 is release metadata.** The page establishes the 2.41.1 version identity and release
  date; it is not evidence about dotenv bytes. Its 2.41.1 entry carries no dotenv/`op run`
  text (capture `article id="v2410101"`).
- **Scope of the sweep is the measured revision's files only** (PROVINCE.md, corpus/README.md,
  SHONEN.md, the round-31 lesson, the SCORECARD `lane-status:` line, the `citations` output);
  it does not audit claims outside those cells.
- **This file is a draft.** Measured cells are `[L1-FILL]`; the L1 lands the lesson at
  `corpus/lessons/round-32.md` and fills them from the gate receipts. An unrun check is not a
  passed check.
