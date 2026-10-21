# ReviewHeaders — legacy-header migration risk and detector applicability (round 22)

Axes: **calibration** + **freshness**. Frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Read-only review; no production files, jj/Git state, or host gates touched. No tools installed
(nothing beyond repo built-ins was needed). Read revision: live working tree 2026-10-20; the
`.ufo/waves/round-22/frozen/before/` snapshots used to separate this round's changes from
inherited state.

## Scope and method

The proposed migration (round-21 SCORECARD plan item 1) appends `source:` / `verified-at:` /
`recheck:` header lines to the 21 legacy knowledge entries so `bash corpus/sources-census.sh`
reports `legacy=0`. I audited the detector (`corpus/sources-census.sh`, stamped `03fb300a…`,
450 lines — byte-clean vs its stamp) against the live corpus, and measured current stamp and
expectation state by direct digest comparison (sha256sum/wc only — no gate execution).

## Findings (by severity)

### H1 — Credential-needle collision makes the "all 21" migration fail by construction (HIGH)

The census credential needle `op://[A-Za-z0-9_-]` (sources-census.sh `CRED_RE`, ~L107–116) is
applied to **every sourced entry body** (`cred_scan "$f"` in the entry loop). Two legacy entries
carry the schematic three-segment reference shape in their teaching tables:

- `corpus/knowledge/op-env-refs.md:14` — schematic scheme + three placeholders
- `corpus/knowledge/op-ref-consumption.md:56–58` — three table rows using schematic placeholders

Today these entries are green only because of the gate's stated bound: legacy entries are
outside **every** check, "the credential scan included", until they gain a column-1 `source:`
line (sources-census.sh header, ENTRIES section). Round-21's reviewer already flagged this
("scanning them would fail by construction"; `corpus/lessons/round-21.md` §Post-landing review).
A migration that adds `source:` to all 21 deterministically produces `SC_CREDENTIAL` findings on
both files → `SOURCES_CENSUS: FAILED`, exit 1. This is exactly the E4 tension: the lane's settled
norm (checklist row E4, `corpus/checklist.tsv:29`) excludes the schematic shapes
`op://(vault|FakeVault|wal)/` from its repo-wide sweep, but the census scanner has **no** such
exclusion — a detector/norm mismatch between two gates the lane ships.

Disposition options, in order of preference:
1. **Scope the migration to the 19 clean entries**; keep the two ref-scheme entries legacy with
   the bound restated in place (`corpus/README.md:116` already records the command counts missing
   `source:` only). Zero gate edits, zero corpus rewrites.
2. **Gate edit**: give `cred_scan` a documented schematic-placeholder exclusion equal in scope to
   E4's allowlist, with selftest cases proving both fire and admit directions. Rewording the
   entries is rejected: it breaks E4's pinned `raw=5` (which counts those very lines) and
   violates the corpus append-only discipline.

### H2 — Expectation and stamp debt is already breached on the live tree; the migration must not bury it (HIGH)

Measured by direct digest comparison against `corpus/stamps.tsv` (63 rows), not by running gates:

- **27/63 stamp rows differed on the later direct comparison** (the shared working tree was
  changing during this review; earlier comparison saw 10 stale rows). For each row below,
  recorded tuple order is stamped `sha256 / lines / bytes` → current `sha256 / lines / bytes`.
  This is a read-time snapshot, not a frozen-base result:

  | Path | Stamped → current |
  |---|---|
  | `corpus/claim-ledger.sh` | `93c5827202b9cdecd6874e75c5dac5281eeae07eddeeff3883bd0da14bfbcd29 / 1319 / 79301` → `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5 / 1371 / 83655` |
  | `corpus/knowledge/adjacency-scope.md` | `45ced1ed96ff888d71b392ba40357d02e20ed0c2e1d005e9d943374d8d5c0284 / 312 / 21973` → `468e14cf12fe905c086760db2f4d3bbe7480937ae52869911a48bd5522db8302 / 325 / 22703` |
  | `corpus/knowledge/cdp-bridge-1password.md` | `62020ad1ea4f879f84a9a50be921777ea43f4fe9308ccbf1434d45c7304fe1bb / 88 / 4320` → `5663a7b338b92b911e077435731ef7facd72814a588a70c2dc00e1139a8f0d7f / 100 / 5009` |
  | `corpus/knowledge/claim-ledger.md` | `f1575725ccd845f3af87cb65ddbd38565bfefe028ea1e698e37143b039664630 / 472 / 32297` → `c6506d29e0404d381edba5e40e48b33bdc183fcb389d781351db663248cc273c / 488 / 33208` |
  | `corpus/knowledge/config-layering.md` | `848b8e502ea2046aacd3f8ae1717d6a4882b07c9317d13d012eb5bae6c88fe83 / 109 / 6621` → `9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0 / 136 / 8088` |
  | `corpus/knowledge/control-plane-hardening.md` | `dad0b983369f558bfd130f68d598561ba0a07974cff1c50cae583b7d7e2feaa7 / 182 / 10575` → `6d75c8a719104e95de0ba374d57e2c1f31a32cd0423354c85dad0ce94c3517ae / 200 / 11530` |
  | `corpus/knowledge/drift-gate.md` | `c58dc5787a39c014884410e25cf6b6f6c0d1de77b2ad5d03726c773d04f0d0a0 / 201 / 13232` → `8519fc1d817824ef4abd20e5a069d9058dcd805353bdeb3dab59586058fb225a / 215 / 13986` |
  | `corpus/knowledge/handler-on-disk-state.md` | `811572dcf630efc89e9222ed6c9e545a9b755f05be2908a6e0487a0fa8862be2 / 247 / 17609` → `df6a5e5d05f4fa06cdcf2114c3a212e48c6b697d56cca1ced63342133e649c38 / 277 / 19329` |
  | `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e734c299ae795ac8a5168f1dae562c875959820257c1c6294072dd5e5 / 285 / 17669` → `fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba / 316 / 19410` |
  | `corpus/knowledge/janitor-command-surface.md` | `4d447b25ffb49c85ef845da47bb2df92131c3fc55d5df4da7a0fd52cccaf16dc / 88 / 5764` → `8b3ae436d8732e10fda0199d3d5b1061700a8f10494b0103afc3e12d20e34213 / 99 / 6372` |
  | `corpus/knowledge/janitor-env-contract.md` | `88dca63ac7e6137f6a737439f18e99b9f602f57a065c63c478c364b46d873c1f / 90 / 5111` → `dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4 / 113 / 6372` |
  | `corpus/knowledge/onepassword-machine-credentials.md` | `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb / 35 / 6240` → `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80 / 80 / 9048` |
  | `corpus/knowledge/op-cli-surface.md` | `2ac8f081724c9bd8368211276472da3bdb6ed0d6ccaf4492cea92e94e35da52b / 117 / 6667` → `06e644466ea9b4812ab0097c69b73792d051310473c7f0c0a0f8ad23648517f0 / 129 / 7351` |
  | `corpus/knowledge/op-env-refs.md` | `6ca40a73286c038f7e431d84f2ba0fb55693dd1e217584eaafd1ec1dd2dbaf86 / 55 / 2693` → `2f07e16c72bc2e70096552c8305feb60b54191cd67e92c2a109f25826cdb4101 / 69 / 3518` |
  | `corpus/knowledge/op-ref-consumption.md` | `b195cc69840b0b6df65e578d86c0457a4a74b1660dca2e8f4513275a190143dd / 372 / 25290` → `3e46809bc6fc3e0bbb52f3419e58c3fd2954bcf7254cf5de9ec86ff2ec2b297c / 384 / 25977` |
  | `corpus/knowledge/sops-age-key-rotation.md` | `ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2 / 99 / 6796` → `5eff6628441c848947e43a7550634b8cad6f774bba4797b9b5d62dbe4120e93e / 112 / 7563` |
  | `corpus/knowledge/surface-census.md` | `e07750f1c61e793344816d95a8ba9269975b71292c28a0644c70bf18ba64247f / 287 / 19435` → `163598bf41c38285f961f228e7e4a534940ad2c7783de95a81c1373ad71f04f7 / 305 / 20519` |
  | `corpus/knowledge/tac-evidence-integrity.md` | `c77312306f2e6708d47aeaa4a483a27e3dbb9597b6b281f6cab4a71103f89665 / 80 / 3757` → `fb30626806d11661bc2ba6f1473a77bc8aee01480a3f2ccc68e732ef4c8045c5 / 92 / 4423` |
  | `corpus/knowledge/transcript-hygiene.md` | `cd76590aef62b55e9e72f317d16c391ad57e379bf2d7f18076ec024b7bf49d44 / 149 / 8877` → `3c740e037e59a7f0ace37851e590f1491b166887dc95f7ecd68c2bcee6880a26 / 166 / 9891` |
  | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb / 111 / 8597` → `ff019fed04f4d9ead8a8ef9068d4712375f475cef3a888f555d3e0738fcde740 / 158 / 11291` |
  | `corpus/lessons/round-18.md` | `614335f2a8cbd9507021d4f32a928faca7e4c4d8947f866564b676706cbe9f17 / 73 / 4216` → `b00b7dd8d5b2b469d6633752e4575cc830df4e9bd4e7947b2754ff4b31477b49 / 80 / 4557` |
  | `corpus/QUALITY.md` | `7425f091737fa0d0c6b1c5ce9a4eeae3dc74bb08e068f2cca231958243b2e29d / 65 / 10642` → `3753d4fb28a0a934d08f721d0874f43d90b9f11a9158f8c9f4e86a8cfae6dccd / 73 / 12551` |
  | `corpus/README.md` | `6837d22b1e14a1ace6956f74e2f02c5c171039e03f2a6ba7658334a3c6614c6d / 118 / 22365` → `986a8b306b4114c3f5a6a84997fe6d16f59c6db39cc7bc0a07791e3b2757dacf / 136 / 23587` |
  | `corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332 / 43 / 14261` → `ebf8864654b7cf1669ffb8944d7682cdefbea3234bca3adbbcb32157488f4de2 / 66 / 18222` |
  | `corpus/state-shape.tsv` | `c84939050de8907855fb8b0866bbfbbcaeffdba7550972b5b36817d7fafd9635 / 48 / 4194` → `cbe4be840fe3779a6d51eb8d97d741bb29aa0760afd0c7bd42268024e00d021f / 53 / 4553` |
  | `LOG.md` | `60a8fd366c8340800be603eb4b7bca5ad615de1c415eaccf815194babf341d60 / 1043 / 74864` → `51e76cf1f69f4007c79c27d6f6f84d19371c6add0da60d81dfa5021920fd389a / 1050 / 75404` |
  | `PROVINCE.md` | `4a346e2df81f7b2e649914d0d99da974d6c484caf12fed1c6bd530d106a78523 / 62 / 10586` → `12f8a323c5f3d88009cfc9baf0a2f20df10d0bb59141b1342658fd7a9f339b53 / 79 / 11539` |
- **R21-02's pinned verdict is already false**: it pins `rows=16 A=14 … mined=14
  entries_sourced=3 legacy=21`; the live registry holds 21 rows (S017–S021 added this round,
  all tier A mined; used-by cells correctly extended to both
  `corpus/lessons/round-22.md` and the new entry), so static column arithmetic gives
  `rows=21 A=19 … mined=19 entries_sourced=4 legacy=21`. Two distinct migration events must be
  documented separately with exact historic evidence per QM14: (a) the S017–S021 +
  feature-bound landing already on the tree, (b) any further legacy-header move. Bundling both
  into one silent ERE rewrite is the laundering shape C2 forbids.
- **R14-01 is already false two ways**: it pins `entries=24 row_linked=21 … unpinned=0`; the
  corpus now holds **25** entries and the new `corpus/knowledge/feature-bound-credential-review.md`
  declares `Reverify: R21-02` (row_linked 22) while carrying **no stamps.tsv row** → `docs`
  fails `UNPINNED` as well. This is the QM5/QM12 defect class live right now: the C1 capability
  entry landed mid-wave without its stamp.
- At the membership comparison, stamp paths exactly matched the frozen base (diff empty); this
  shows no restoration or new membership change relative to that read, not which paths were once
  stamped. The current unstamped inventory is not interchangeable with the nine historical
  deletions: only the git-history lane can identify and justify those exact old rows. Present-
  tense unstamped repo docs (excluding plans/, `.ufo/`, README.md, AGENTS.md, stamps.tsv itself):
  14 lesson files — round-1, round-1-aggregator-audit, round-1-aggregator-seed, round-3,
  round-4-aggregator-audit, round-5-aggregator-audit,
  round-5-aggregator-mirror-bare-path-and-unclosed-prereq, round-6, round-7,
  round-9-aggregator-corpus-verdict, round-19-recensus, round-20, round-21-verifier-spotcheck,
  round-22 — plus `corpus/knowledge/feature-bound-credential-review.md`.

### M1 — Double-`Reverify:` trap in the header template (MEDIUM)

The gate's own fixture and the round-21 entries place `Reverify: R21-02` directly under the
three header lines. Every legacy entry **already** carries exactly one `Reverify:` declaration
deeper in the body (docs mode requires exactly one; a second declaration is exit 2,
`corpus/knowledge/claim-ledger.md`). A drafter copying the four-line header block verbatim into
a legacy entry creates a second declaration and `claim-ledger.sh docs` exits 2 across the whole
corpus. Acceptance: migration appends only `source:` / `verified-at:` / `recheck:`; the existing
`Reverify:` line stays where it is.

### M2 — own-work rows are enum-legal but must clear the admission bar, and each batch re-moves R21-02 (MEDIUM)

`own-work` is already inside the kind enum (`spec|docs|…|community|own-work`), so the plan's
registry rows are shape-legal without a contract change. But QA1 still requires tier A *for that
scope* plus an anchor, tier C never sole support; an own-work row needs a named anchor (gate
verdict line + revision), not just "lane evidence". Each migrated entry must also be named in
its row's used-by cell and vice versa (handshake runs both ways). Migrating all 21 takes the
registry from 21 to 42 rows; migrating only the 19 credential-clean entries takes it to 40.
Each batch moves R21-02's expectation again, as its own evidenced step (see H2).

### L1 — S021 provenance is thinner than its siblings (LOW)

The round-22 lesson's search log records 4/4/4 for S017–S020; S021 (OpenBao tokens,
version-scoped qualifier) is recorded only through the new entry's `verified-at:`. When the
migration journal next touches SOURCES.md, add the one-line search decision for S021 rather
than letting it ride on the entry alone.

### L2 — Dispatch path defect for the scribe seats (LOW)

DraftE1/DraftE3 prompts target `corpus/onepassword-machine-credentials.md` and
`corpus/vault-openbao-token-lease-lifecycle.md` — both miss the `knowledge/` directory. The real
files are `corpus/knowledge/*` (errata are present there). Record so the integrator does not
read the nonexistent paths as pending new-file work.

## Acceptance conditions for the legacy-header migration

- **A1 (applicability)**: disposition the two ref-scheme entries first (H1 option 1 or 2); a
  landed `legacy=0` with a red or allowlist-blind credential scan fails review.
- **A2 (header shape)**: each migrated entry has one column-1 `source:` line citing only `mined`
  rows whose used-by names that entry, ≥1 tier A/B; `verified-at:` and `recheck:` present; no
  second `Reverify:` introduced (M1).
- **A3 (registry discipline)**: own-work rows carry kind=`own-work`, tier A/B, an anchor naming
  the verdict line + revision; no existing row's status/used-by silently rewritten.
- **A4 (expectation migrations)**: R21-02 and R14-01 are migrated with a committed record giving
  old value, new value, motivating correction, and the historic evidence for each step — the
  S017–S021/feature-bound step separated from any legacy-header step (QM14).
- **A5 (stamp ordering)**: re-stamp only as reviewed per-file `stamp` commits after inspection,
  covering the exact stale set at integration time (27 rows on the later direct comparison
  above), the migrated entries only when their bytes change, and stamps for the new
  `feature-bound-credential-review.md` and `lessons/round-22.md`; restore or individually justify
  the nine historic drops in the append-only migration journal. No blanket re-pin.
- **A6 (claim shape)**: the freshness axis claim rests on the reconciliation above, not on the
  `legacy=21→0` count (C2 spec: "no legacy-header count claim"; QUALITY QM13).

## Falsifier the round must withstand

**F-H1 (detector applicability).** In a fixture root (`sources-census.sh verify --root`, never
the live tree), take a copy of `corpus/knowledge/op-env-refs.md`, add a compliant three-line
header citing a valid own-work mined row whose used-by names it, and run the census. With the
unchanged detector, `SC_CREDENTIAL` is the expected result (the literal needle matches the
schematic line at :14 and `cred_scan` runs on sourced entries). Therefore an all-21 migration
that proceeds with the current gate has to report this blocker, not claim a clean admission.
If a gate change exempts that shape, the falsifier is the paired selftest: the schematic fixture
must be admitted while a credential-shaped control remains rejected. If either assertion fails,
the claimed migration applicability is falsified.

## Residual risk and verification gaps

- **LSP unavailable**: `read xd://lsp` returned `No such tool` and listed no LSP mount. I used
  literal source reads/searches only; no references, definitions, or diagnostics ran. Search
  output is not treated as semantic proof.
- I did not run any gate (contract); all census/expectation states above are static readings
  of the live bytes. Parent should run after integration: `bash corpus/sources-census.sh`,
  `bash corpus/claim-ledger.sh verify`, `bash corpus/claim-ledger.sh docs`,
  `bash corpus/claim-ledger.sh cells`, and a QM12-style per-row stamp check
  (`sha256sum` + `wc` vs `corpus/stamps.tsv`) listing skipped rows by id.
- `plans/round-22.md:6` records the frozen-base outside-verifier result (five stale, nine
  dropped). Git-history attribution of the nine exact dropped rows and that five-stale baseline
  belongs to ReviewStamps/DraftHistory; this report provides the live membership and staleness
  comparison plus the frozen-base path-set equality, not historic row identities.
- One correction made during review: an early truncated read suggested S017–S020's used-by
  omitted the new entry; targeted column extraction shows the cells were extended correctly.
  The handshake for `feature-bound-credential-review.md` holds.

Report: .ufo/waves/round-22/build/ReviewHeaders.md
