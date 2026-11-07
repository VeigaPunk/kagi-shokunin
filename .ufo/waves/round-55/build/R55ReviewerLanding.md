# R55ReviewerLanding — review of the 25 recorded citations and the ISO/IEC 11770-3 entry change

Seat: `R55ReviewerLanding` (kagi round 55, attempt 1). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`. Scope: honesty of classification of the ten column-1 `cites:` lines, the 25 used-by
cells, and the C2 ISO entry change. Read-only: no corpus/plans/registry/SCORECARD/LOG edit was made.

- BASE: `ebe095857a734caf5efdd7bd776feb22b4e23972`.
- PRE: `f2b986fadd8f8551e760cc89f59e0ae0edb0d499`.
- **Measured revision (candidate): `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`**
  (`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`).
- The candidate tree was extracted with `git archive <rev>` into
  `/fast/scratch/hyaku/kagi-r55/R55ReviewerLanding`; every line number below is in that tree.
- Receipts: `.ufo/waves/round-55/build/R55ReviewerLanding.d/` (list at the end).

## Verdict in one paragraph

Both frozen readings reproduce at `348aa3b`, not merely in the candidate-tree reading: I ran
`plans/round-55-c1.sh 348aa3b` → `C1_USEDBY_GAP: value=0 gap=0 citations=90 entries=37 guard=1
(bad=none)` (exit 0), and `plans/round-55-c2.sh 348aa3b` → `C2_ISO_CURRENT: value=2 amd=1 recheck=1
guard=1 (bad=none)` (exit 0). The 25 `cites:` ids map one-to-one onto the 25 used-by paths added to 20
rows; every one of the 25 ids is genuinely named in its entry's prose (not only in the header); no
entry names a registry id outside `source:` ∪ `cites:`; no used-by path is dead and every mined row's
used-by file records the id (independent scan, receipt `independent-scan.txt`). The 25 used-by cells are
therefore truthful, and C1's predicate is honestly `0`. C2's two recheck counts read true on the committed
captures and on a live 2026-11-07 re-fetch (S101 `-> 2`, S113 `-> 3`; bodies byte-identical). The defects
below are classification/placement defects and one gate robustness gap, not inflated readings: 12 of the
25 ids are true cross-references, **13 of the 25 carry support** and are kept on `cites:`; 11 of those 13
belong on `source:` under the assignment's support test (the other 2 are the legacy entry's only possible
record). The clearest case is `nist-key-management-guidance-status.md` S049, where the entry itself says
the Rev. 6 status comes from S049 while the row is deliberately absent from `source:`.

## Per-entry verdict table

`label true?` = is the parenthetical a true description of where/how the id appears in the body.
`support?` = does the id supply evidence for a claim in the entry (assignment's test).
`source:?` = should it instead be on the entry's `source:` line.

| # | entry | ids on `cites:` | parenthetical label (line) | body mentions found | label true? | support? | source:? |
|---|---|---|---|---|---|---|---|
| 1 | `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` | S017, S018, S020 | "named in the body as the Broker feature-status rows that already hold that ground; cross-references, not this entry's support" (4) | 106 only: "the lane's status rows (S017/S018, with S020's announcement distinguishing them) already hold that per-feature split" (94 cross-refs the file) | yes | no | no |
| 2 | `corpus/knowledge/nist-key-management-guidance-status.md` | S049 | "the SP 800-57 Part 1 Rev. 6 draft row the status table cites inline" (4) | 20 (table row states IPD + closed comment period `[S049]`), 25 ("the Rev. 6 status comes from ... S049 ... deliberately absent from this entry's source: line"), 58 ("frozen drafts [S049, S074]"), 62, 100-101 (Rev. 6 dates are "S049's registered values") | yes | **yes** | **yes** |
| 3 | `corpus/knowledge/nist-key-management-parts-withdrawal.md` | S049 | "named in the body as the Rev. 6 draft row; cross-reference" (4) | 65 only: "the lane's Rev. 6 row registers only its draft status (S049)" | yes | no | no |
| 4 | `corpus/knowledge/oidc-federation-trust-policy.md` | S012, S022, S047, S050 | "named in the body as the lane ground this entry does not repeat (GitHub-OIDC rows, Vault JWT audience rows); cross-references, not this entry's support" (4) | 5 (ground), 96 ("the lane already holds that ground (rows S047/S050)"), 99 ("lane rows S012/S022") | yes | no | no |
| 5 | `corpus/knowledge/onepassword-machine-credentials.md` | S017, S018, S019, S020 | "the round-22 feature-bound Broker rows the GitHub Actions section cites inline" (5) | 42-44 (opened list), 49-52 (S017 public preview; S019 Business/GitHub.com), 53-56 (S018 public beta; beta app; JS SDK), 59 (S020 feature split), 64 | yes (section name imprecise, see F2) | **yes** | **yes** |
| 6 | `corpus/knowledge/op-ref-consumption.md` | S072, S112 | "§11.1–§11.2: the op release identity row and the op release clock feed (legacy entry, no source: line)" (2) | 394 ("**Sourced.** ... S072"), 400/402/408 ("**Sourced.** ... S112 ... clock ..."), 412 | yes | **yes** | n/a: legacy, no `source:` line; `cites:` is the only record |
| 7 | `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` | S024 | "named in the body as the Vault KV v2 row this OpenBao entry does not extend; cross-reference" (6) | 11 only: S024 "(max_versions as a backend configuration parameter) is a documentation fact about Vault and is not re-measured here" | yes | no | no |
| 8 | `corpus/knowledge/secret-scanning-detection-vs-validation.md` | S048, S055, S056 | "named in the body as neighbouring scanner rows; cross-references, not this entry's support" (5) | 70 (S048 "opened-but-unwritten row"), 71 (Betterleaks "subject of the Betterleaks entry (rows S055-S056)") | yes | no | no |
| 9 | `corpus/knowledge/sops-age-key-rotation.md` | S103, S104 | "the release identities of the measured sops and age-keygen binaries named in the body" (6) | 124-125: "release identities S103, S104; binaries checked against the release checksums" | yes | **yes** (measurement-scope identity) | yes, or document the measurement exception |
| 10 | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | S021, S022, S023, S105 | "later-section sources: the round-22 product-bound reopen rows and the round-49 PKI role row" (6) | 167 ("S022 records that correction to S012. S023 corrects S013's ... locator"; S021 registered at 173), 233 ("generate_lease ... is documented by S105 ... cited by ... round-49") | yes | **yes** | yes, or document; note its own `source:` already carries S108, a later-section source |

Totals: 25 ids; 12 pure cross-references (entries 1, 3, 4, 7, 8); 13 support ids (entries 2, 5, 6, 9, 10).
The parentheticals are factually true read as descriptions of the body; none of the five "cross-references,
not this entry's support" statements is false. What is *not* honest is the placement of the 13 support ids
off the support line — the `cites:` line's own definition in `plans/round-55.md` is "ids it names outside
its support line", and `cites: does not make an entry sourced`.

## Misclassified ids (with evidence)

**F1 (medium) — S049 in `nist-key-management-guidance-status.md` is support, recorded only on `cites:`.**
The entry's status table line 20 states "SP 800-57 Part 1 Rev. 6 | Initial Public Draft, comment period
closed 2026-02-05 [S049]" and line 101 says every Rev. 6 date (2025-12-05 draft, 2026-02-05 close) "are
S049's registered values"; line 25 says the Rev. 6 status "comes from the lane's existing row S049 ...
deliberately absent from this entry's `source:` line". That is a support row omitted from the support line
by choice. Consequence: SC_ENTRY_CITE reads `source:` only, so the entry's central Rev. 6 status/date
evidence is never tier-checked; a reader of the header cannot see the evidence for the table's Rev. 6 row.
The fix is gate-safe: S049 is tier A, status mined, opened 2026-10-21, and its used-by now lists the entry,
so adding it to `source:` passes SC_ENTRY_CITE. Tested, not inferred: fixture `fx-src` (candidate archive
plus the 11 support ids of F1–F4 appended as tokens to the four entries' `source:` lines) runs
`SOURCES_CENSUS: CLEAN` — no tier/status/used-by blocker (a real edit would add the row descriptions too).
The parenthetical itself ("the ... row the status table cites inline") is true; the defect is the placement.

**F2 (medium) — S017–S020 in `onepassword-machine-credentials.md` are support, recorded only on `cites:`.**
The round-22 erratum is the entry's correction of item 4's feature status; it asserts, with bracket
citations, "GitHub Actions — public preview ... [S017]", "An administrator connects a 1Password Business
account ... [S019]", "Custom OIDC workflows — public beta ... [S018]", "custom-OIDC section explicitly
separates beta rollout from Actions public preview [S020]" (lines 42-64). Those are claims of the entry
resting on those rows. The parenthetical calls them "the round-22 feature-bound Broker rows the GitHub
Actions section cites inline"; the section is in fact `## Erratum (round 22 — feature-specific status and
eligibility)` and covers both GitHub Actions and custom OIDC, so "the GitHub Actions section" is imprecise
on top of the placement. Same gate-safe fix: all four are tier A/mined, used-by lists the entry (covered by
the `fx-src` test in F1).

**F3 (low-medium) — S103, S104 in `sops-age-key-rotation.md` are support for the measurement scope.**
Lines 124-125 pin the measured binaries ("sops 3.13.3", "age-keygen v1.3.2") to the release identities
S103/S104; the entry's `T1`–`T5` claims are version-bound ("with sops 3.13.3 ..."). The label is true but
the ids are support kept off `source:`; if the entry intentionally treats measurement rows as
"later-section sources", say so on the line (the current text says only "release identities ... named in
the body").

**F4 (low-medium) — S021, S022, S023, S105 in `vault-openbao-token-lease-lifecycle.md` are support.**
S022/S023 carry the corrections the erratum states (audience rule applies to JWT roles when aud is
present; S023 corrects S013's locator), S021 registers the OpenBao reopen, and S105 documents the
`generate_lease` parameter T5 relies on (line 233). The label "later-section sources" is true; but the
entry's own `source:` line already carries S108 (a later-section source, opened 2026-11-07), so the
lane's practice is inconsistent. This is not a false statement, but the corrected readings' evidence is
off the support line and unchecked by SC_ENTRY_CITE.

**F5 (low) — S072, S112 in the legacy `op-ref-consumption.md`.** The entry says "**Sourced.** ... S072"
and "**Sourced.** ... S112" (§11.1 line 394, §11.2 lines 402-412). With no `source:` line, `cites:` is the
only record, and the parenthetical says so; this is the plan's documented legacy exception. Residual:
SC_ENTRY_CITE never runs on a legacy entry, so these support rows are recorded but never tier-checked.
No action required by the frozen plan; note it as a named ceiling, not a defect of this landing.

**Not misclassified:** S017/S018/S020 (cdp-bridge), S049 (nist-parts), S012/S022/S047/S050 (oidc), S024
(openbao), S048/S055/S056 (secret-scanning) are genuine non-support pointers; the parentheticals match the
body exactly and no claim rests on them.

## ISO/IEC 11770-3 entry (C2) — header, section, scope

- `source:` (line 1) adds S113 (https://www.iso.org/standard/82709.html) and S114
  (https://www.iso.org/standard/85929.html), both "opened 2026-11-07". Both rows are tier A, mined,
  opened 2026-11-07, and their used-by lists the entry (registry lines 120-121). True.
- `verified-at: 2026-11-05` (line 2) is unchanged while the new sources are dated 2026-11-07. This matches
  lane practice (the vault entry keeps `2026-10-19` while its `source:` carries S108 opened 2026-11-07),
  but a reader can misread it as "all sources verified 2026-11-05". Optional: append the 2026-11-07
  addition to the parenthetical, or leave it and rely on the per-source dates. **F12, minor.**
- `recheck:` (line 3) states S101 `-> 2` (BASE line says `-> 1`) and S113 `-> 3`, both "(ran 2026-11-07)".
  Verified: committed `S101.raw` sha256 `2e4c1524…7b0c80` (85615 B) gives `grep -c` 2; committed
  `S113.body` sha256 `d8dfe354…dfa64357` (90604 B) gives 3; a live 2026-11-07 re-fetch with the declared
  browser user agent returned byte-identical bodies (same sha256s) and the same counts; the default user
  agent returned HTTP 403 for both standard pages. **True.** The S101 explanation "the page carries the
  stage twice, in the stage line and in the life-cycle list" is accurate: matches at byte offsets 45752
  (stage line) and 62765 (life-cycle list).
- New section (lines 39-53) claims: title `ISO/IEC 11770-3:2021/Amd 1:2025` [S114], subtitle
  `Amendment 1: TFNS identity-based key agreement`, stage `International Standard published` (60.60),
  publication date `2025-04` [S114]; S113 lists the amendment in its life cycle and still gives the 2021
  edition as 60.60 [S113]. Verified in the captures: title at byte offset 541, subtitle 670, publication
  date field `2025-04` (stage date 2025-04-28), stage 60.60; S113's life-cycle block names the amendment
  as `Published` (amendment link text at byte 69404; the 2021 edition's stage 60.60 first appears at byte
  51283). **The section claims nothing about the
  amendment's mechanism content** and says so explicitly ("The amendment's mechanism content is outside
  this entry"). **True, scope-clean on content.**
- **F10 (low) — one unmarked applicability inference.** "So a reader holding the 2021 edition holds the
  edition in force; the text that applies is the 2021 edition together with Amendment 1:2025, not the
  2021 text alone." The catalogue states title/stage/date and lists the amendment; it does not state
  applicability in those terms, and "in force" is not the catalogue's word (it says "Published"). The
  entry marks inferences elsewhere. Recommend `[INFERENCE]` or a rephrase ("the amendment is published
  against the 2021 edition; read the edition together with its amendment").
- **F10b (low) — attribution of the first sentence.** "The newer amendment the IEC record points to is
  ISO/IEC 11770-3:2021/Amd 1:2025 [S114]". `S114.body` contains no `2017` and no `supersed` text
  (0 each); its three `withdraw` hits are the generic stage-code dropdown (90.99/95/95.99 at bytes
  62703/63210/63620), not this record's status. The pointing is evidenced by S100, whose body's lifecycles JSON names
  `ISO/IEC 11770-3:2021/AMD1:2025` (S100 is already on `source:`), and by S113's life cycle. The claim is
  true; cite `[S100][S114]` or rephrase.
- **F11 (low-medium residual) — the 180d clock does not watch the amendment.** The recheck's two commands
  fetch the S101 and S113 URLs only; S114 (the amendment's stage) is asserted but never clocked. The S113
  count of 3 counts *lines* containing the amendment name: two hidden reference spans in the top product
  card (byte 53493, 53739) and one life-cycle link (69404). A withdrawal/supersession of Amd 1 would
  change S114, not necessarily this count; conversely, removal of the hidden spans would fire the clock
  without a currency change. The plan's named ceiling allows a "true of the capture but not
  discriminating" quote to score, so this is not a claim miss — it is the freshness residual: recommend a
  second command on the S114 URL (e.g. count of `International Standard published`) before the clock is
  trusted as an amendment-status warning.
- **F6/F7 (low) — lesson receipt precision** (`corpus/lessons/round-55.md`):
  - Lines 16 and 17 say "Quote (4 words)" for `ISO/IEC 11770-3:2021/Amd 1:2025`; under the lesson's own
    E49-1 rule (`printf '%s' "<quote>" | wc -w`) the count is **3**. The S114 subtitle is 6 words, not the
    quoted claim. Concrete, though not claim-invalidating.
  - Line 16 labels offset 53493 "(life-cycle list)"; 53493 is the hidden `itemReference_cs85929` span.
    The life-cycle occurrence is byte 69404 (line 69324). The sentence "the life cycle lists the amendment"
    is true; the offset label is wrong.
  - Line 18 gives S101 "byte offsets 45705 stage line, 62733 life-cycle list". Those are the **line-start**
    offsets of the two matching lines (`grep -b` semantics); the match offsets are 45752 and 62765
    (`grep -bo`). The count 2 is correct. The S113/S114 bullets use match offsets, so the two bullets mix
    conventions without saying so.
  - Line 16's "(identical to an earlier same-day fetch)" for S113 has no committed receipt (S114's refetch
    has `capture/rejections/S114-refetch.meta`). My live fetch today reproduced `d8dfe354…`, so the claim
    is corroborated on the day but not documented in-round.

## Security / refusal-boundary finding

**F8 (medium) — committed response headers carry a `Set-Cookie` field.** `capture/S113.headers:8` and
`capture/S114.headers:8` each contain a `set-cookie:` header (a Cloudflare bot-management cookie; name
and value not reproduced), committed at `348aa3b`. The kagi refusal boundary forbids
committing "any ... cookie", and the C2 counter uses only the body/meta files, so the headers are not
needed. Recommend dropping the two `.headers` files or redacting the `Set-Cookie` line, and fixing the
capture profile to filter it (the same profile will otherwise commit cookies on every future capture).
No credential value is involved (a Cloudflare bot cookie bound to the fetched response), but the rule is
categorical. Receipt `header-cookie.txt` records field names/line numbers only.

## Gate robustness (counter/claim attack)

**F9 (medium, guard robustness) — a padded used-by cell passes when the entry self-records the id on
`cites:`.** From the candidate archive I built `$HYAKU_SCRATCH/kagi-r55/R55ReviewerLanding/fx-pad`, changed
the OpenBao entry's cites line to `cites: S024, S001 (...)` and appended
`corpus/knowledge/openbao-kv-v2-version-lifecycle.md` to S001's used-by; the entry's prose never mentions
S001. Results: `SOURCES_CENSUS: CLEAN (rows=114 ...)` and
`C1_USEDBY_GAP: value=0 gap=0 citations=91 entries=37 guard=1 (bad=none)`. The K1-F2 control ("pad a
used-by cell") expects FAIL, but it pads without a record; the self-cites variant defeats g4 because
SC_BODY_CITE's `body_ids` reads the whole file (the new cites line supplies the token) and SC_USEDBY_NOCITE
now accepts `cites:`. The landed 25 cells are all backed by real prose mentions (verified individually),
so the C1 value at `348aa3b` is honest — this is a discrimination gap in the guard, not a present false
cell. Recommend a control for this forgery (pad + self-cites) and, if the guard is meant to mean "the
entry discusses the row", a check that the id occurs outside the `source:`/`cites:` fields. Receipt
`forged-fixture.txt`.

## Harm to existing entries

None found.

- The ten entries' prose is unchanged: the base→candidate diff adds only the `cites:` line (and the ISO
  entry's header/section/refs). No claim text moved; no id removed.
- `corpus/SOURCES.md`: exactly the 20 rows named in the lesson §Gate list changed, only in the used-by
  column; 25 paths added, **0 dropped**; S100–S102 byte-identical (C2 guard=1 and the row diff shows no
  change); S113/S114 are the only added rows (registry 112 → 114). Every added path corresponds to a
  `cites:` id and vice versa (25↔25 bijection).
- The census is CLEAN at the candidate (`rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4
  entries_sourced=16 legacy=21 captures=114`) and the selftest is `PASS (78 cases)`; the predeclaration's
  four frozen files are unchanged (`git diff --quiet PRE 348aa3b -- plans/round-55.md
  plans/round-55-c1.sh plans/round-55-c2.sh plans/round-55-controls.sh` rc 0).
- Independent scan: 0 used-by gaps, 0 unrecorded mentions, 0 unknown ids, 0 dead used-by paths, 0 g4
  failures.
- Semantic note (not harm): because `cites:` now satisfies the used-by handshake, a used-by cell can list
  an entry that only cross-references the row (e.g. S024 now lists the OpenBao entry that explicitly says
  it does not extend Vault, and S048 lists the scanner entry that says it does not cover GitHub's
  product). This is the plan's definition ("which entries cite it"), but a reader who reads used-by as
  "sources" would be misled; the per-entry parentheticals disambiguate. The registry header does not
  define used-by.
- Policy harm: F8 (committed cookies), not a citation harm.

## Residual risk and verification gaps

- I did **not** rerun the 22 pre-freeze controls; I read `controls/controls-prefreeze.txt` (22 MATCH, 0
  mismatch, exit 0). My own two counter runs and the census/selftest are independent.
- I did **not** run the lane's full `claim-ledger.sh verify` (wave context forbids it).
- Pre-existing used-by paths outside the 25 added ones (across the 20 changed rows and the 92 unchanged
  rows) were checked for record consistency (my g4 scan: 0 failures) but not for prose mentions; only the
  25 added pairs were prose-verified.
- The live ISO re-fetch is 2026-11-07 only; future drift is the clock's job, and F11 says the clock is
  weak on the amendment's stage.
- The S114 default-UA rejection was checked by HTTP status (403) and meta; I did not audit the rejection
  body text.
- Capture provenance beyond sha256/byte offsets/live equality was not re-derived (the C2 counter checks
  the `.meta`/`source-fetches.tsv`/`quote-bodies.tsv` chain and passed).
- The `cites:` parentheticals are prose, not machine-checked; a future `cites:` line could be false while
  the census stays clean (F9 is the same failure mode on the used-by axis).

## Receipts (measured revision `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` in every header)

- `c1-counter.txt` — `C1_USEDBY_GAP: value=0 gap=0 citations=90 entries=37 guard=1 (bad=none)`, exit 0.
- `c2-counter.txt` — `C2_ISO_CURRENT: value=2 amd=1 recheck=1 guard=1 (bad=none)`, exit 0.
- `independent-scan.txt` — own token/used-by scan: 114 rows, 37 entries, GAP 0, unrecorded 0, unknown 0,
  dead 0, g4 0, 25 cites ids.
- `registry-diff.txt` — 20 changed rows, 2 added rows, 25 added used-by paths, 0 dropped.
- `body-mentions.txt` — every cites id's body lines (source:/cites: excluded).
- `iso-captures.txt` — capture sha256/size/counts/offsets; live 2026-11-07 refetch (d8dfe354…, 8bb88d88…,
  2e4c1524…; counts 3/13/0 and 2); default-UA 403 both URLs.
- `census-selftest.txt` — `SOURCES_CENSUS_SELFTEST: PASS (78 cases)`; `SOURCES_CENSUS: CLEAN`; exit 0.
- `forged-fixture.txt` — self-cites padded-cell forgery: census CLEAN; C1 `value=0 ... guard=1`.
- `source-addition-fixture.txt` — the 11 support ids appended to the four `source:` lines: census CLEAN.
- `header-cookie.txt` — header field names only; one `set-cookie` field per capture header; no values.
- `kill-rule.txt` — frozen four files unchanged (diff rc 0).
- `lesson-receipt-checks.txt` — `wc -w` = 3 for the amendment quote, 6 for the subtitle; two "4 words"
  claims in the lesson; measured offsets.
