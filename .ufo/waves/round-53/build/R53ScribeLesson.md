# R53ScribeLesson — round-53 lesson audit (statement table, M53-1 recurrence, QM68/QM69 testability)

Seat `R53ScribeLesson`, round 53 attempt 1, lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Candidate `36d0a86a7539890eb079d893c9a58e37e84d953d` (HEAD at the time of this audit), BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`, predeclaration `39460f8676954f135d15fa99b43cd882360b3eee`.
All paths below are absolute in the receipt dir or repo-relative to the lane. Reads were `git show <rev>:<path>` or the candidate worktree; no product file, plan, counter, ledger, SCORECARD, registry or state file was edited. No counter was re-run; no full `claim-ledger.sh verify`; no commit; no network fetch (the lane's refusal boundary forbids contacting 1Password, so the two rejected 1Password-family feeds were not refetched).

Receipts (copied under the seat's write scope):

```
/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-53/build/R53ScribeLesson/
  sc-base.txt            # seat run of python3 corpus/self-counts.py on a git archive of c1953d4a
  gate-offline.txt       # python3 corpus/release-clock.py --root . (candidate tree)
  docs-live.txt          # bash corpus/claim-ledger.sh docs (candidate tree)
  live-counts.txt        # grep -c '[^[:space:]]' corpus/stamps.tsv
  feed-entry-fields.txt  # Atom parse of the S111 capture: title / published / updated per entry
  word-count.txt         # E49-1 wc -w of the S111 quote, and the byte offset search
  ledger-and-rows.txt    # ledger rows changed BASE..candidate; field-level S103/S104 diff
```

## (a) Statement audit

Every factual sentence in the lesson's `## Claims`, `## Gate` and `## Mistakes` (candidate `corpus/lessons/round-53.md`), with the file/command that backs it. Verdicts: **SUPPORTED** (pointer reproduces the statement), **SUPPORTED (caveat)** (substance holds, wording/splice/scope is imprecise), **FALSE** (pointer contradicts the statement), **UNSUPPORTED** (no artifact at the candidate can be pointed at; not refetched), **INFERENCE** (code-level expectation, not an observed output), **MISATTRIBUTED** (the cited commit is not the one that carries the fact).

### §Claims

| # | Statement (abridged; line in `corpus/lessons/round-53.md`) | Pointer (file:line / command) | Verdict |
|---|---|---|---|
| A1 | S103/S104 teach that the tag `"is the project's current stable release, pinned as the version an installed sops / age-keygen must report"` (:9) | `corpus/SOURCES.md:110-111` at `36d0a86a` (teaching cells: S103 "…installed sops must report"; S104 "…installed age-keygen must report") | SUPPORTED (caveat): the currency sentence is verbatim in both rows; the quoted clause is spliced with "sops / age-keygen" — no single row carries that wording |
| A2 | both "sat on a fixed `90d` recheck that no gate watches" (:9) | BASE rows: `git show c1953d4a:corpus/SOURCES.md` lines 110-111 (`recheck=90d`); `corpus/release-clock.py:561,568,610,962` select only `recheck == on-release`; `corpus/sources-census.sh:340` checks entry headers, not cadence expiry | SUPPORTED |
| A3 | "the lane held no age feed row" (:9) | `git show c1953d4a:corpus/SOURCES.md \| grep -c 'FiloSottile/age/releases.atom'` ⇒ `0` | SUPPORTED |
| A4 | change: S103/S104 → `on-release`; new S111; clocks S103→S033 (3.13.3) and S104→S111 (1.3.2), both `derived:` (:9) | `git diff c1953d4a 36d0a86a -- corpus/SOURCES.md`: only field 10 changes on S103/S104 and S111 is added; `corpus/release-clocks.tsv:31-32` (`feed` / `S033` / `3.13.3` / `not-fired` / `derived:` and `feed` / `S111` / `1.3.2` / `not-fired` / `derived:`); receipt `ledger-and-rows.txt` | SUPPORTED |
| A5 | all 31 clocks observed live 2026-11-07 into `observe-r53.json` (digest `f927…`); 29 old rows moved 2026-11-06 → 2026-11-07, no verdict changed, fired 13 (:9) | `.ufo/waves/round-53/final/observe-r53.json` (`observations` = 31, all `http_status` 200, all `observed_at` 2026-11-07, errors 0, verdicts fired 13 / quote-located 11 / not-fired 7); `sha256sum` of the candidate blob = `f927b431…d37c9a`; `corpus/release-clock.py:28,547`; BASE..candidate clock diff = 29 changed rows, old-row verdict counts identical | SUPPORTED |
| A6 | frozen C1 predicate verbatim (:10) | `plans/round-53.md:52` and `plans/round-53-c1.sh:6-7` (same sentence) | SUPPORTED |
| A7 | at BASE five STALE bindings: `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:65` say 124 (live 125); `corpus/README.md:67` says 33 row-linked / 36 pinned (live 34 / 37) (:11) | `.ufo/waves/round-53/controls/c2-base.txt` (5 ids, `stale=5`); seat run `sc-base.txt` lines 3, 22, 35, 36, 38: `STALE SC-SKILL-STAMPS SKILL.md:46 claimed=124 live=125`, `STALE PV-STAMPS PROVINCE.md:73 claimed=124 live=125`, `STALE RD-STAMPS corpus/README.md:65 claimed=124 live=125`, `STALE RD-DOCS-ROWLINKED …:67 claimed=33 live=34`, `STALE RD-DOCS-ENTRIES …:67 claimed=36 live=37`; `live-counts.txt` stamps=125; `docs-live.txt` `entries=37 row_linked=34` | SUPPORTED |
| A8 | "all left by the round-52 landing" (:11) | stamps 124 at `a74ae53` vs 125 at `a2cb69b`; knowledge entries 36 at `a74ae53` vs 37 at `a2cb69b`; `R14-01` expect migrated at `a2cb69b` (`entries=36 row_linked=33` → `37/34`); `R12-03` expect `^124$` still at `a2cb69b`, migrated to `^125$` at `282849f` | SUPPORTED (caveat): true in the causal sense (the round-52 landing raised the live populations and left the prose); the prose lines were last written in round 49 (`a74ae53`) — see A28 |
| A9 | "the four statements carry the live numbers with a round-53 note; no binding, ledger row or tool changed" (:11) | numbers: `SKILL.md:46` (125), `PROVINCE.md:73` (125), `corpus/README.md:65` (125 + note), `:67` (34/37 + note) at `36d0a86a`. "no … tool/binding": `git diff --name-only c1953d4a 36d0a86a -- corpus/self-counts.tsv corpus/self-counts.py corpus/claim-ledger.sh` empty. "no … ledger row": `corpus/claim-ledger.tsv` changed on 9 rows (`R13-01 R21-02 R24-06 R31-02 R33-02 R34-03 R36-02 R36-03 R38-01`), journal `.ufo/waves/round-53/expectation-migrations.json`; only C2's own bound rows `R12-03`/`R14-01` are unchanged | numbers/tools SUPPORTED; the ledger-row clause is **FALSE as written** (9 rows changed; the journal in the same candidate documents them) |
| A10 | frozen C2 predicate verbatim (:12) | `plans/round-53.md:92` and `plans/round-53-c2.sh:6-8` (same sentence) | SUPPORTED |

### §Gate

| # | Statement (abridged; line) | Pointer | Verdict |
|---|---|---|---|
| A11 | S111 new, capture `…/capture/S111.body`, URL, HTTP 200, decoded sha256 `32517112…`, 40379 B (:16) | `corpus/source-fetches.tsv` S111 row (line 154 at `36d0a86a`: 200, `curl-fsSL-compressed-v1`, 2026-11-07, sha256 `32517112…`, 40379); `sha256sum` of the capture = the same; `corpus/quote-bodies.tsv:10` | SUPPORTED |
| A12 | quote located count 1, offset 725 (:16) | `grep -abo '<title>age v1.3.2</title>' .ufo/waves/round-53/capture/S111.body` ⇒ one hit at `725:` (`word-count.txt`) | SUPPORTED |
| A13 | quote `"<title>age v1.3.2</title>"` is "(3 words)" (:16) | E49-1: `printf '%s' '<title>age v1.3.2</title>' \| wc -w` ⇒ `2`; `od -c` shows one space (`word-count.txt`) | **FALSE** (2, not 3; recurrence of M49-3 `number-drift` — see F1) |
| A14 | the gate's own parser reads `1.3.2` from this body (:16) | executed `corpus/release-clock.py`'s `parse_latest_version` on the capture (imported from the committed file) ⇒ `1.3.2` | SUPPORTED |
| A15 | "the entry's `<updated>` is 2026-08-29T17:55:50Z" (:16) | `feed-entry-fields.txt`: entry `age v1.3.2` `updated = 2026-08-29T18:12:38Z` (no `<published>` element); `2026-08-29T17:55:50Z` is entry `age v1.3.1` | **FALSE** (the claimed value belongs to v1.3.1; `corpus/SOURCES.md:118` repeats the same wrong value — see F2) |
| A16 | "the same release day the S104 tag page shows" (:16) | `corpus/SOURCES.md:111` (S104 support cell: "released this 29 Aug 17:55") — same calendar day, 29 Aug | SUPPORTED (date part only) |
| A17 | admit tier A, kind `code`, `mined`, `recheck 90d`, feed never on-release (gate refuses BADFEED), used-by the lesson (:16) | `corpus/SOURCES.md:118` (fields `code`/`A`/`mined`/`90d`/`corpus/lessons/round-53.md`); `corpus/release-clock.py:613` (`BADFEED`) | SUPPORTED |
| A18 | rejected `https://releases.1password.com/developers/cli/index.xml` (L1: HTTP 200, `text/xml`, 45175 B; titles "1Password CLI 2.25.1") (:17) | no capture, fetch row, quote-body row or receipt in `.ufo/waves/round-53/` or `.ufo/reports/`; `grep -rn '45175\|releases.1password.com/developers/cli\|1Password CLI 2.25'` finds only the seat prompt (`build-spec.json`/`build-dispatch.json`). Not refetched: the refusal boundary forbids contacting 1Password | **UNSUPPORTED** (no stored artifact at the candidate; see F5) |
| A19 | gate title rule takes at most one leading word, so on that body it reads "feed has no stable X.Y.Z release entry" (:17) | `corpus/release-clock.py:801-847` (docstring: only `[Word ]vX.Y.Z` or `/releases/tag/vX.Y.Z` counts; error text at :847) | rule SUPPORTED; the per-body output is **INFERENCE** (no stored 1Password body to execute against) |
| A20 | rejected `https://app-updates.agilebits.com/product_history/CLI2.rss` (L1: HTTP 404, "Unknown product: CLI2.rss") (:18) | no capture/receipt in the wave or reports; not refetched (same boundary) | **UNSUPPORTED** |
| A21 | rows touched: S103/S104 `90d` → `on-release`; status and used-by unchanged (:19) | field-level diff at `36d0a86a`: only field 10 changes for both rows (`ledger-and-rows.txt`) | SUPPORTED |
| A22 | discernment sample (LEARNING.md): admit S111; reject the 1Password CLI feed (:20) | the sample is the Gate's own bullet; the same heading convention is used at `corpus/lessons/round-52.md:25` and `round-51.md:26`; the fleet `/home/vgpnk/Projects/shokunin/LEARNING.md` is a static 88-line framework with no per-round rows | SUPPORTED as the round's record; the named file does not store per-round samples (caveat) |
| A23 | counting rule (E49-1): every Gate word count is `printf '%s' "<quote>" \| wc -w` (:21) | `corpus/lessons/round-49.md:51` (E49-1) | SUPPORTED (but A13 violates it) |
| A24 | rows added 1 (S111, tier A 1), rows touched 2, registry 110 → 111 (:22) | row counts at `c1953d4a` = 110 and at `36d0a86a` = 111; diff 3 insertions / 2 deletions; only S111 added | SUPPORTED |

### §Mistakes

| # | Statement (abridged; line) | Pointer | Verdict |
|---|---|---|---|
| A25 | M53-1 class: checker existed and read STALE, but summary verdict word and exit code are POLICY whenever the two operator-routed POLICY rows are present (:28) | `corpus/self-counts.py:364-373` (`POLICY` return 2 before `STALE` return 1); `c2-base.txt` `SELF_COUNTS: POLICY (… stale=5 … policy=2 …)`; same shape at the seat BASE run | SUPPORTED |
| A26 | M53-1: five `STALE` lines, summary `claims=63 stale=5 …` (:28) | `c2-base.txt`; `sc-base.txt` (same five, with claimed/live values) | SUPPORTED |
| A27 | M53-1: "the five stale statements date from the round-52 landing `a2cb69b7` (new entry pinned and stamped, ledger R12-03/R14-01 migrated, prose not)" (:28) | `git blame` at `c1953d4a`: `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:65,67` all blame `a74ae53` (round-49 candidate, 2026-11-06 18:30). Stamps 124 at `a74ae53` → 125 at `a2cb69b`; entries 36 → 37. `R14-01` migrated at `a2cb69b`; `R12-03` migrated at `282849f`, not at `a2cb69b` | **MISATTRIBUTED**: the lines date from round 49; the round-52 landing made them stale; one of the two named migrations was not in the named commit (see F4) |
| A28 | M53-1 captured-by: none — the round-52 harm check compared ledger FAIL/POLICY ids and ran the round-48 counter, not the self-count numbers (:28) | `corpus/lessons/round-52-verifier-spotcheck.md:68` (ledger FAIL ids BASE/tip and the four extra FAILs migrated in `282849f7`); `corpus/lessons/round-52.md:37` (M52-5) | SUPPORTED |
| A29 | M53-1 fix: C2 corrects the five under a counter that reads per-line findings; shown able to fail (c2-base 5; K2-F1 4); QM68 (:28) | `c2-base.txt`; `.ufo/waves/round-53/controls/controls-prefreeze.txt:29` (`K2-F1 expect=4 got=4`); `corpus/QUALITY.md:251` | SUPPORTED |
| A30 | M53-2 run 1: K2-F5 expected 5, read 7; `UNLOCATED` also `SC-SKILL-CLAIMS` (`SKILL.md:46`) and `RD-DOCS-BYHAND` (`README.md:67`) (:29) | `.ufo/waves/round-53/controls/controls-prefreeze-run1.txt:43-44` (K2-F5 5→7, seven `UNLOCATED` ids); bindings `corpus/self-counts.tsv:21` (`SC-SKILL-CLAIMS`, doc `SKILL.md`) and `:54` (`RD-DOCS-BYHAND`, doc `corpus/README.md`) | SUPPORTED (path caveat: the doc is `corpus/README.md`, the lesson writes `README.md`) |
| A31 | M53-2: expectation corrected to 7 before the freeze, run 2 22/22 MATCH; counter right, unchanged in value (:29) | `controls-prefreeze.txt:37` (`K2-F5 expect=7 got=7`), `:45` (`match=22 mismatch=0`) | SUPPORTED |
| A32 | M53-2: run 1 printed a traceback for K1-F2 (one-line gate file); receipt reader now names `receipt-unnamed`, value unchanged; gate shorter than 547 lines (:29) | `controls-prefreeze-run1.txt:8-11` (traceback); `controls-prefreeze.txt:7` (`K1-F2 … bad=S103:receipt-unnamed S104:receipt-unnamed`); `plans/round-53-c1.sh:103-108` (`len(g) < 547` → `receipt-unnamed`) | SUPPORTED |
| A33 | M53-3 class: S103/S104 at BASE carried `90d` (round-48 rows); the gate watches only `on-release` (:30) | BASE rows 110-111 (`recheck 90d`); `corpus/lessons/round-48.md:25-26` (the rows/quotes); `release-clock.py:561,568` | SUPPORTED |
| A34 | M53-3 fix: both rows on-release with bound feed clocks; QM69; shown able to fail (`c1-base` 0; K1-F1 0) (:30) | candidate rows and `release-clocks.tsv:31-32`; `corpus/QUALITY.md:252`; `controls/c1-base.txt:1` (`value=0`); `controls-prefreeze.txt:5` (`K1-F1 expect=0 got=0`) | SUPPORTED |
| A35 | "Misroot sweep (§3): recorded in the report." (:32) | no lane/fleet report file at `36d0a86a`; the sentence points forward to the L1 report that lands later | **UNSUPPORTED at the candidate** (forward reference) |

Summary: 24 SUPPORTED / 3 SUPPORTED-with-caveat (A1, A8, A22) / 1 mixed (A19: code rule supported, per-body output inference) / 2 FALSE (A13 word count, A15 updated timestamp) / 1 FALSE-as-written (A9 ledger scope) / 1 MISATTRIBUTED (A27) / 3 UNSUPPORTED (A18, A20, A35 forward reference).

## Findings (the lesson at the candidate needs these corrections)

**F1 — Gate word count is wrong (A13).** `"<title>age v1.3.2</title>"` is 2 whitespace tokens by the Gate's own E49-1 command; the lesson says 3. 3 would only arise by splitting the tags, which E49-1 does not do. This is a recurrence of `number-drift` (M49-3, `corpus/lessons/round-49.md:45,51`; M50-1, `corpus/lessons/round-50.md:34`). The admission is unaffected (both counts ≤ 25), but the count must be corrected or the counting rule restated. Proposed row: see M53-6 below.

**F2 — Gate `<updated>` is the previous entry's (A15).** Atom parse of the committed capture: `age v1.3.2` → `2026-08-29T18:12:38Z`; `age v1.3.1` → `2026-08-29T17:55:50Z`; there is no `<published>` element. The lesson's `17:55:50Z` is v1.3.1's `<updated>` (and the S104 tag page's "released this 29 Aug 17:55" is a different datum). The same wrong value is in the admitted registry row `corpus/SOURCES.md:118` ("updated 2026-08-29T17:55:50Z"). The C1 clock does not read this cell, so the claim's predicate is unaffected; the factual sentence and the registry metadata are not. Proposed row: M53-7 below.

**F3 — C2's "no ledger row changed" is false as scoped (A9).** `corpus/claim-ledger.tsv` changed on 9 rows in the same candidate (`R13-01 R21-02 R24-06 R31-02 R33-02 R34-03 R36-02 R36-03 R38-01`), documented by the candidate's own `.ufo/waves/round-53/expectation-migrations.json`. C2's two bound rows (`R12-03`, `R14-01`) and its tools are unchanged. The sentence should read "no binding, no ledger row C2 binds, and no tool changed" — otherwise the lesson contradicts its own journal.

**F4 — M53-1's provenance is misattributed (A27).** All five stale lines blame `a74ae53` (round-49 candidate), not `a2cb69b7` (round-52 candidate). Round 52 made them stale (stamps 124 → 125, entries 36 → 37) and migrated `R14-01` at `a2cb69b`; `R12-03` was migrated only in the round-52 receipts commit `282849f`. Correct pointer: "last written in round 49 (`a74ae53`); made stale by the round-52 landing (`a2cb69b` candidate / `282849f` receipts; `R14-01` migrated at the candidate, `R12-03` at the receipts commit); prose not updated."

**F5 — the two rejected-feed observations have no artifact (A18, A20).** The Gate cites "L1, 2026-11-07" with byte counts, content types and titles, but no capture, fetch row, quote-body row or receipt exists under `.ufo/waves/round-53/` or `.ufo/reports/`. They were not refetched here because the refusal boundary forbids contacting 1Password (and the agilebits property). For the audit these are unrun observations; either store the fetch receipts (status, content-type, bytes, sha256, one located title) or downgrade the wording to "candidate feed, not opened".

**F6 — the misroot sweep is a forward reference (A35).** At the candidate no report carries it. It is legitimate only if the L1 report lands and contains the sweep; otherwise the sentence is unsupported.

## (b) Proposed `## Mistakes` row: the M53-1 recurrence

The class that generates M53-1 — a landing changes a counted population, updates the one consumer it runs (the ledger expectation), and leaves the documents' stated counts stale — is already evidenced twice in rounds 49–52, on the same five lines.

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M53-4 (proposed) | `population-staleness` (a landing that adds a stamped path, a knowledge entry or a registry row migrates the ledger expectation it runs but leaves the documents' stated self-counts stale; the next summary read is `POLICY`, so only a per-line read or the next round's C2 counter sees it) | round 52: `corpus/lessons/round-52.md:37` (M52-5: stamps 124 → 125 moved four ledger FAILs `R12-03/R22-03/R24-05/R24-15`, migrated only in the receipts commit `282849f7`) and `corpus/lessons/round-52-verifier-spotcheck.md:68` (the same four FAILs; the harm check compared ledger FAIL/POLICY ids, not the stated counts). That landing is the one that left this round's five BASE STALE lines: stamps 124@`a74ae53` → 125@`a2cb69b`; entries 36 → 37. round 49: `corpus/lessons/round-49.md:16` (BASE `SELF_COUNTS: POLICY (… stale=3 …)` on the three stamp statements) and `corpus/lessons/round-49-verifier-spotcheck.md:57` ("the round-42 lesson pin left this statement at 122"; the note is still at `corpus/README.md:65` at BASE) | a non-author full verify or the next round's C2 counter; never the landing's own harm check (M53-1) | QM68's per-line read of `python3 corpus/self-counts.py` in the landing, plus the C2 counter's GUARD (population and ledger-command equality); the five statements fixed by C2 in round 53 are the same lines round 49 fixed |

Why this is a recurrence and not a duplicate of M53-1: M53-1 names the *mask* (POLICY verdict word/exit hides STALE); this row names the *generator* (population change with one consumer updated). The round-52 landing is the same event that produced this round's BASE red, so the lesson's own M53-1 pointer and this row should cross-reference. The two prior instances are independent: round 42's landing left the stamps at 122 (round-49 BASE), and round 52's landing left them at 124 (round-53 BASE); the same three stamp statements plus the docs triple have now been corrected twice.

Optional sibling rows, not requested by (b) but evidenced by the audit; both are `number-drift` recurrences (M49-3, M50-1), not M53-1 recurrences:

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M53-6 (proposed) | `number-drift` (a Gate word count does not match `printf '%s' "<quote>" \| wc -w`) | `corpus/lessons/round-53.md:16` says `"<title>age v1.3.2</title>"` is 3 words; `word-count.txt` reads 2; the same class at `corpus/lessons/round-49.md:45,51` (M49-3, 8/12 vs 6/13) and `corpus/lessons/round-50.md:34` (M50-1) | the seat's own read; no gate compares a lesson's stated count with `wc -w` | correct to 2 (or re-quote); the E49-1 command is already stated in the same Gate |
| M53-7 (proposed) | `metadata-misattribution` (an Atom entry's `<updated>` is taken from a neighbouring entry) | `corpus/lessons/round-53.md:16` and `corpus/SOURCES.md:118` say `updated 2026-08-29T17:55:50Z` for `age v1.3.2`; `feed-entry-fields.txt` gives `age v1.3.2` → `18:12:38Z` and `age v1.3.1` → `17:55:50Z` (no `<published>` element) | the seat's parse of the committed capture | correct both cells to `2026-08-29T18:12:38Z`, or state only the release day (29 Aug) that the S104 tag page supports |

## (c) Are QM68 and QM69 testable rules?

`corpus/QUALITY.md:251` (QM68) and `:252` (QM69). Both are checked against the lane's own tools; no host mutation, no network.

### QM68 — verdict: TESTABLE (reviewer-level; not a standing gate)

Rule shape: a landing that changes a stated self-count, or adds a stamped path, a knowledge entry or a registry row, reads `python3 corpus/self-counts.py` by its per-line findings and its `stale=` / `unlocated=` / `ambiguous=` fields, all zero, never by the verdict word or exit code.

- Who can check: any non-author reviewer (or CI) with the lane checkout or a `git archive` of the measured revision; no network, no host writes (the checker's docstring: normal checks write nothing).
- Command and observed output: `python3 corpus/self-counts.py` — seat run on a `git archive` of BASE (`sc-base.txt`): exit 2, 51.1 s (a first run measured 45.3 s), five `STALE` lines with `claimed=/live=` pairs (lines 3, 22, 35, 36, 38) and `SELF_COUNTS: POLICY (claims=63 stale=5 … policy=2 …)`; seat run on the candidate worktree: exit 2, 86.9 s, `stale=0 unlocated=0 ambiguous=0 policy=2 setup=0`. The exit code is 2 in both cases — which is exactly why the rule forbids reading it.
- Trigger recognition: the landing/reviewer must know the trigger fired; `git diff --name-only <landing> -- corpus/stamps.tsv corpus/knowledge corpus/SOURCES.md corpus/self-counts.tsv` shows it. This is procedural, not machine-enforced.
- Limit: the checker executes allowlisted ledger commands that its header calls "trusted, reviewed repo inputs, NOT a hostile-code sandbox"; a forged `ledger:` command can print a passing field. QM68 alone does not close that; the round-53 C2 counter's GUARD (BASE command/expect equality, stamp/entry population equality, exact POLICY pair) does. So QM68 is testable but forgeable in the general case, and it is a process rule (no standing gate runs it on every landing).
- Discriminating witness exists: BASE → 5, candidate → 0; K2-F1 → 4 (`controls-prefreeze.txt:29`).

### QM69 — verdict: PARTLY TESTABLE (consequent mechanical, antecedent semantic)

Rule shape: a registry row whose teaching states that a version is the project's current release is `on-release` with a bound feed clock in the same commit (QM63); a row that only records a release identity keeps a cadence.

- Consequent (mechanically testable): `python3 corpus/release-clock.py --root .` → `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)`, exit 0 (`gate-offline.txt`); the ledger's `R36-03` command is exactly `bash plans/round-36-c3.sh`, a 374-byte wrapper that `exec`s the gate. Same-commit binding: `git diff --name-only <landing>^ <landing> -- corpus/SOURCES.md corpus/release-clocks.tsv`. A violation (on-release without a clock) reads `FAILED (… unbound=N …)` in the same gate; the round-53 controls carry that witness (`K1-F1` 0, `K1-F3` 0).
- Antecedent (not mechanized): deciding that a row's `teaches` cell states currency is a reading. A canonical-phrase probe works for the two instances — `grep -nE "the v[0-9.]+ tag is the project's current stable release" corpus/SOURCES.md` returns exactly `S103`/`S104` at both `c1953d4a` and `36d0a86a` (2 hits); at BASE they carry `90d` (the M53-3 defect), at the candidate `on-release`. But the broader lexical net `grep -nE 'current (stable )?release|newest stable'` returns 12 candidate lines, including the feed rows `S033-S036`/`S089-S091` (release identity for a clock, not a currency statement) and a prose note — false positives — while paraphrases ("latest", "as of today") are missed. So no mechanical classifier exists without a marker cell.
- Counter-case in the rule: `S072` ("op CLI 2.41.1 release identity", `recheck 180d`) — a release identity keeps a cadence; the row supports it (`corpus/SOURCES.md` S072 recheck cell = `180d`).
- Verdict: testable by a reviewer for the canonical phrasing and fully mechanical for the consequent; not a fully mechanical rule as written. To make it mechanical, either enumerate the currency-stating row ids in the rule or add a `currency:`/`current-release:` marker the release-clock gate can read.

## Commands and exit codes (this seat)

| Command | Result |
|---|---|
| `python3 corpus/self-counts.py` (BASE archive `c1953d4a`) | exit 2, 51.1 s (first run 45.3 s), `stale=5`, receipt `R53ScribeLesson/sc-base.txt` |
| `python3 corpus/self-counts.py` (candidate worktree) | exit 2, 86.9 s, `stale=0`, `policy=2`; run output retained in the transcript only (scratch removed) |
| `python3 corpus/release-clock.py --root .` | exit 0, `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)`, receipt `gate-offline.txt` |
| `bash corpus/claim-ledger.sh docs` | exit 0, `DOC_AUDIT: CLEAN (entries=37 row_linked=34 by_hand=3 …)`, receipt `docs-live.txt` |
| `grep -c '[^[:space:]]' corpus/stamps.tsv` | `125`, receipt `live-counts.txt` |
| `printf '%s' '<title>age v1.3.2</title>' \| wc -w` | `2`, receipt `word-count.txt` |
| Atom parse of `capture/S111.body` | `age v1.3.2` updated `18:12:38Z`; `age v1.3.1` updated `17:55:50Z`, receipt `feed-entry-fields.txt` |
| `git diff --name-only c1953d4a 36d0a86a -- corpus/claim-ledger.tsv …` | `corpus/claim-ledger.tsv`; 9 changed ids, receipt `ledger-and-rows.txt` |
| `grep -abo '<title>age v1.3.2</title>' capture/S111.body` | one hit, offset `725` |

Not run by this seat, by instruction: the lane's frozen counters (`plans/round-53-c1.sh`, `-c2.sh`), the pre-freeze controls, the full `claim-ledger.sh verify` (not named for this item). No tool was installed or upgraded. No file outside `.ufo/waves/round-53/build/R53ScribeLesson*` was written; scratch lived under `/fast/scratch/hyaku/kagi-r53/R53ScribeLesson*` and was removed by `trap`.

## Acceptance mapping

- (a) Statement table with a pointer or `unsupported`/false verdict for every statement in §Claims, §Gate and §Mistakes: above (A1–A35), plus findings F1–F6.
- (b) Proposed `## Mistakes` row for the M53-1 recurrence with round and file:line: M53-4 above (rounds 52 and 49, with the round-53 BASE values), plus optional sibling rows M53-6/M53-7.
- (c) Per-criterion verdicts: QM68 TESTABLE (reviewer-level, command and observed outputs given; non-mechanized trigger and forgeability stated); QM69 PARTLY TESTABLE (consequent mechanical and measured; antecedent semantic, canonical-phrase probe demonstrated, false positives stated).

## Known limits

- The two rejected-feed observations (1Password CLI feed, agilebits CLI2.rss) have no artifact and were not refetched: the refusal boundary forbids contacting 1Password; the report records them as unrun.
- The candidate-tree `self-counts.py` run's full output was in scratch and removed by `trap` after the measure; the BASE run's receipt is kept. The candidate run's tail (`stale=0`, `policy=2`, exit 2, 86.9 s) and `c2-candidate-tree.txt` (`value=0`) agree.
- Line numbers are as of `36d0a86a`; `corpus/QUALITY.md` and the lesson may move at the receipts commit.
