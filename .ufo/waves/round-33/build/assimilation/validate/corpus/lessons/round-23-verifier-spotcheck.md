author: hyaku closure (non-author integrator, @m_opus)

# round-23 — non-author verification and spot-check (hyaku closure)

Written by the integrator, not the lane (CORPUS.md: outside reviews are new files; the lane owns
`round-23.md`). Inputs: fleet report `.ufo/reports/round-23/kagi.md` (fleet commit
`00cfe25d154c8cc4648a4f5bb51194ee0cc3e45e`), prompt `.ufo/prompts/kagi-round-23.md`, lane BASE
`d218603b74099ddca0bd8f869516fc41db0979bf` → round final `8a4ecbbd578398ce097c801081761348ba920325`
(declared code/data `e1884c6e`, verdict file `measured_commit` `57776b28`); lane tip at closure
`46fac5a29e4e2a8cfb41f451671f005f2b3ee85e` (wave-evidence-only commit, see conformance). Watchdog
digest (copied): `2026-10-21T00:38:35-03:00 launch kagi round=23 pgid=2971557 driver=hyaku-inline
attempt=1` / `2026-10-21T02:22:20-03:00 complete kagi round=23; hyaku-inline attempt=1`. Five
read-only review seats (C1, C2, C3+safety, waves/findings critic, discernment) were dispatched by
the closure, not the lane. No lane gate, selftest, drift pin, vault/account operation or installer
was run by the closure or its seats; gate behaviour is judged from committed code and committed
evidence. Tool installs: none.

## Step-1 conformance

| check | command | observed |
|---|---|---|
| report author | `git log --format='%an %H' -- .ufo/reports/round-23/kagi.md` | 14 commits, all `kagi-shokunin`; latest `00cfe25d` (01:34:58-03:00, 19 s after lane `8a4ecbbd`), on fleet `origin/master` |
| SHONEN heading | report §SHONEN vs SHONEN.md boxes | 4 lines, 4 boxes, all `[~]` with pointers |
| cited hashes | `git merge-base --is-ancestor <h> master` for d218603b, e1884c6e, ea5b7348, 7af07b4d, 284d40e0, def9bc2e, 58bd8d70, 57776b28, 5dd14116, 31f24e07, 89344643, 3764bc57, 17858cf1, c349fc7f, 8a4ecbbd | all resolve, all ancestors |
| pushed/clean | `scripts/hyaku/jj-lane.sh state …`; `git status --porcelain`; `ls-remote origin refs/heads/master` | `ahead=0 behind=0 tracked=0 untracked=0`; empty; remote = `46fac5a2…` |
| prompt contract | difflib of `templates/round-prompt.md` (140 lines) vs prompt | 11 placeholder lines replaced, nothing removed; §6 hyaku addendum appended (256 lines) |
| range | `git log d218603b..46fac5a` | 19 lane-identity commits; `46fac5a` touches only `kagi-shokunin/.ufo/waves/round-23/` paths |

Conformance defects (status-neutral): `46fac5a` (02:24:03-03:00) landed the 66 parent-build and
remaining falsify reports after the report (01:34:58) and after the driver's `complete` line
(02:22:20), while the report still says other parent-built reports "remain parent-owned and
uncommitted". The contract asks for all wave evidence before the report (routed D7).

## Claims — re-check

Re-measured by the closure: every count below. Evidence-verified only: every gate exit and
selftest tally (`kagi-shokunin/.ufo/waves/round-23/final-verification.json`, `measured_commit`
`57776b28`, and falsify reports at `46fac5a`).

**C1 calibration — closure disposition review (capability acquisition).** Plain measurement:
`git cat-file -e d218603b:corpus/closure-dispositions.py` fails (absent at BASE); round-22
spot-check carries 9 `^- D[0-9]` lines + 5 discernment rows + 1 adjudication = 15 obligations;
`corpus/closure-dispositions.json` at 8a4ecbbd has 15 dispositions (`SPOT-01..05`, `ADJ`, `D1..D9`),
tally `fixed 6 / reported 3 / operator-owned 1 / no-action 5` — equal to the claimed line and to the
committed R23-02 result (`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3
operator_owned=1 no_action=5 rejected=0 pointers=15)`, exit 0). `source_sha256` `65a5b3de…` equals
`sha256(git show 8a4ecbbd:corpus/lessons/round-22-verifier-spotcheck.md)`. The six `fixed`
dispositions were checked for substance, not token presence: D1 (seven W04 lines quoted verbatim in
the report), D4 (per-tuple drift commits f4a8dd9 / bad9088 / 584dd67+c2cab35 in the lesson), D5
(130 spawn IDs / 129 names), D6 (`measured_commit` field now inside the verdict file), D7
(`corpus/source-fetches.tsv`, 10 rows) and D9 (R23-01) are real fixes. The gate itself only proves
presence (file + `#`-line anchor substring + id token, comments count) against the working tree, and
its source digest lives in the same lane-writable JSON. The lane states both bounds. Selftest
`PASS (14 cases)`: the closure counts 14 cases in committed code, but the only 14-case run record
is a falsify seat report over an uncommitted tree. The verdict file has no selftest entry, and no
ledger row runs it (routed D3). Verdict: **verifies** (bounded as declared).

**C2 freshness — declared source provenance (D7).** Plain measurement at BASE / 8a4ecbbd: registry
rows 23 / 26; in-row `Fetch sha256:` 16 / 16; `corpus/source-fetches.tsv` absent / 10 data rows
(S017–S026) over 9 distinct URLs; rows with neither an in-row pin nor a declared capture **7 → 0**;
census `source-fetches` references 0 / 4; static selftest case table 47 / 59 (12 `fetch-*`).
Evidence-verified: R21-02 `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1
entries_sourced=4 legacy=21)` and R21-03 `PASS (59 cases)`, exit 0, census bytes at 57776b28
byte-identical to 8a4ecbbd. Live re-open (seat, declared curl profile): S025 and S026 raw decoded
bodies reproduce the declared sha256/bytes exactly; S024's raw body differs by 35 B of chrome, as its
volatile representation predicts; the normalized digests of all three reproduce under the declared
`rendered-text-v1`. Bounds confirmed by code reading and stated by the lane: `SC_FETCH` checks
shape/identity, not page content. Legacy in-row digests pass on presence. The CLEAN line does not
split captures from in-row pins. Supersession is prose only (S014/S016 stay `mined` and cited).
Verdict: **verifies** (bounded as declared).

**C3 operability — hermetic `cells` (D9).** Plain measurement: `git grep -c cells-hermetic --
corpus/claim-ledger.tsv` 0 at BASE → 1 (R23-01) at 8a4ecbbd. The fixture is five files under
`corpus/fixtures/cells-hermetic/`. Its two rows run a local `printf` script and a `grep -c` over a
fixture data file, with no host path, network or `op` use. The closure recomputed both fixture
stamps (sha256/LF/bytes) and they match. Evidence-verified: R23-01 pass, exit 0, last line
byte-equal to the pinned `CELL_AUDIT: CLEAN (cells=6 … rows_run=2 row_deferred=0 row_failures=0 …
self_skipped=0 …)`. Fixture and gate blobs are identical at 57776b28, 8a4ecbbd and 46fac5a. The
deletion mutant is killed (`falsify/MutFixtureDelete.md`, `row_failures=1`). Verdict:
**verifies**. Hermeticity rests on row text plus the exact line: `policy_check` still admits `~`
and absolute arguments, PATH is unpinned, and SKIP-SELF is a substring test.

Whole-tree re-measurement: every one of the 79 `corpus/stamps.tsv` rows at 8a4ecbbd matches
`git show 8a4ecbbd:<path>` on sha256, LF count and byte length (0 stale, 0 missing). The QM12
safe-row substitute shows 45 rows, 32 pass and 12 skips. The skips are the same inherited host and
substrate IDs as round 22, and none is R23-01 or R23-02. The one fail is R11-08, inherited
(`unresolved=3` in the verdict file): a falsify seat traced its tokens to the round-22 non-author
file, not to lane work. This file avoids unresolvable class-shaped tokens.

## Per-axis verdicts

`git diff d218603b 8a4ecbbd -- SCORECARD.md`: +41/−1. The `-` line updates the census
row's selftest count from 47 to 59. The appended round-23 pre/post tables keep every axis at 9→9. The
SKILL/PROVINCE edits update the same 47→59 count and a 29→36 probe count.

| axis | verdict | basis |
|---|---|---|
| calibration | improved | C1 capability demonstrated; 15/15 obligations typed, re-counted |
| freshness | improved | rows lacking any provenance 7→0 re-measured; 79/79 stamps fresh |
| operability | improved | host-free `cells` rows 0→1 (R23-01), fixture stamps re-derived |
| depth | unchanged | no depth claim; R21-01 untouched |
| coverage | unchanged | S024 opens a frontier lead; S025/S026 are corrections; no governed surface added |
| adjacency | unchanged | PROVINCE boundaries unchanged; parent-held sibling findings reported, not absorbed |

## Discernment spot-check (LEARNING.md)

The round-23 Gate records 3 admits, "excluded 0", and no explicit reject. The reject sample is
therefore the Gate's two supersession decisions: the old S014/S016 locators are demoted from the
active role.

| item | decision | re-opened source | verdict | reason |
|---|---|---|---|---|
| S024 KV v2 `max_versions` | admit | https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 (closure re-opened 2026-10-21) | agree | “max_versions (int: 0) – The number of versions to keep per key.” found in rendered text; separate `delete_version_after` parameter confirms the declared scope |
| S025 OpenBao JWT locator | admit | https://openbao.org/docs/auth/jwt/ | agree | “The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT” found once |
| S026 OpenBao token hierarchy | admit | https://openbao.org/docs/concepts/tokens/ | agree | “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.” found; raw digest reproduces |
| S014 old locator (uppercase “The JWT auth method …”, truncated) | reject as active locator | https://openbao.org/docs/auth/jwt/ | agree | rendered text: uppercase form 0 occurrences, lowercase form 1 |
| S016 old in-row pin `c083fdca…` | reject as active pin | https://openbao.org/docs/concepts/tokens/ | agree | live raw (`52295218…`) and normalized (`ed949658…`) digests both differ |

Agreement 3/3 sampled admits, 2/2 rejects. New-row check: S024 (`corpus/SOURCES.md`, A/mined, opened
2026-10-21) quote is 12 words and verbatim; S025 has 18 words and S026 has 22, both verbatim. All three
strings agree across the SOURCES row, the lesson Gate and `corpus/source-fetches.tsv`. QUALITY.md
diff is empty, so no criterion is added without a lesson. No self-certified outside agreement was
found. `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit 0
`kagi ok …/corpus/SOURCES.md` plus seven W04 lines (S019–S023, S025, S026 duplicate url across
scopes), matching the report verbatim.

## Round-22 debts

D1, D4, D5, D6, D7 and D9 were fixed on substance (above). D2 (mise global config write) and D8
(`/tmp/kagi-shokunin` residue) are named and operator-owned. D3 is reported: the mode token is
guarded, while id-shaped positionals remain debt. The M23-5 deviation below shows this debt is live.

## Weighing the waves and the safety deviation

Wave accounting at 46fac5a: parent-build has 66 spec items and 66 reports. Falsify has 64 items and
64 reports: 19 reviewer, 12 critic, 19 scout, 4 mutation-tester, 4 connector, 4 revenger, 2 sentinel.
That registry mix differs from the report's stated 20/10/20 split. The run had 0 resumes and 0
replacements, `falsify-dispatch.err` is empty, and 4 misroots were relocated (M23-4).
HIGH findings were fixed, not hidden. The fixes cover the census `S007: unbound variable` crash, the
contradictory cross-capture equality rule, the premature "wave confirmed" wording, and the 7→9 URL
count. The pointer-presence-only, legacy-digest-presence, vacuous `fetch-disagree`, 17 surviving
`SC_FETCH` mutants and supersession-prose-only findings all bound the claims rather than falsify
them, and the report states each one. Partly dropped: the normalizer is declared three ways
(`corpus/source-fetches.tsv` says Python `\s`; `corpus/sources-census.sh` and the lesson say only
"collapse whitespace"; the comment rule is undeclared). `plans/round-23.md` still says "commit tree"
and "consume the closure's decisions", though the gate reads the working tree and consumes ids. A
falsify critic measured 12 of 16 legacy pins as non-reproducing, while the lesson names only S008 and
S012–S016.

Safety (M23-5): the L1's real-tree `cells` run executed R18-01 (`corpus/drift-pins.sh`). That row is
untagged and reads 15 host-private paths, using stat, wc, sha256sum and grep only; it prints paths,
verdicts and 12-hex digest prefixes, never contents. The run contradicts the plan's frozen boundary
("no host/private gate"). It was disclosed in the same round in the report, LOG and lesson. R18-01 is
`skipped` in the verdict file and is credited nowhere. A secret-shape sweep of all added lines in
`git diff d218603b 46fac5a` (35,547 lines) finds no `ops_`, `ghp_`, `hvs.`, `eyJ` or `AKIA`
material. Its only key-header hit is a sentinel's pattern list, and every `op://` hit is a
documentation placeholder. Grade: a status-neutral conformance defect, not axis harm, because no
claim rests on that run.

## Trend verdicts

- expansion — **improved**: one demonstrated capability (closure disposition review) enters
  SCORECARD; one frontier lead (KV v2 retention parameters) opened as S024; no admitted entry failed
  its bar.
- quality — **improved**: two weak locators (S014/S016) are superseded by stronger rows whose quotes
  and digests reproduce live. Provenance-less rows fell 7→0, and 79/79 stamps are fresh. A crash in
  the production census was caught and fixed before landing. Residual legacy-pin staleness is
  declared historical, not left unmarked as current.
- discernment — **improved**: outside agreement 3/3 admits, 2/2 rejects. The round-22 closure's
  decisions became typed, machine-checked obligations, and no self-certified agreement is claimed.

## Adjudication

**ADMITTED.** All three claims verify (C1 counts and digest re-measured with tallies
evidence-verified; C2 counts re-measured and three captures reproduced live; C3 counts and fixture
stamps re-measured). No axis is harmed. The M23-5 safety deviation and the post-report evidence
commit are honest, disclosed conformance defects. They are routed, not used to overturn admission.
SHONEN boxes stay `[~]`. Box 3 (instructions executable without oral context) now has an outside
check for R23-01/R23-02. Promotion remains operator-owned.

## Routed defects (lane owes next round)

- D1 SCORECARD's repertoire table (`## Capabilities`, main table) lacks the closure disposition
  review row; it sits only in the round-23 section table, and the trailing prose still names round
  22 as the latest. Add the row.
- D2 Gate registry: SKILL.md §Gate registry has no `corpus/closure-dispositions.py` row. Until it
  does, PROTOCOL §Gate standard (Delivery) grades the gate non-conformant. The census row's pinned
  values omit `corpus/source-fetches.tsv`.
- D3 Bind the closure selftest. Add a ledger row or verdict-file entry for `--selftest` (14 cases)
  measured on a committed revision. Refresh `measured_commit` to the final code tree:
  `closure-dispositions.py` changed after 57776b28 in 3764bc57. Make the report's "measured
  against" column name the revision each run measured instead of `e1884c6e`.
- D4 Safety: real-tree `cells` executes every SCORECARD-cited row, and that is how R18-01 ran. Tag
  host rows (R18-01 and peers) or make `cells` refuse untagged host rows, under a selftest case id.
  Also refuse `~`/absolute arguments in `cells` row policy.
- D5 Legacy pins: name every non-reproducing in-row pin (S001–S004, S009–S011 are silent). Add
  `captures=`/`inrow=` to the census CLEAN line. Restrict the in-row exemption to the historical
  S001–S016 set, so a new row cannot self-certify with a bare digest.
- D6 Declare `rendered-text-v1` once, including its whitespace class and comment/element rules, and
  make the TSV header, census comment and lesson cite that one declaration.
- D7 Commit all wave evidence before the fleet report: `46fac5a` landed after both the report and
  the driver's `complete` line, and the report's "uncommitted" sentence is now stale.
- D8 The round-23 Gate logged no rejects. Record rejected candidates explicitly, including
  supersession demotions. Plan wording ("commit tree", "consume decisions") should get a named
  correction rather than stand.
