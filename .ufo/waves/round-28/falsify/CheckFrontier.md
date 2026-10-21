# CheckFrontier — round-28 falsify: S047–S049 frontier-only, no capability/coverage overclaim, leads retained

Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (pinned candidate). Seat scope: source rows S047–S049 only. No host-private ledger rows executed. No production edits.

**Verdict: FAIL (narrow) — one MEDIUM defect in S049, one LOW in S047; frontier-only and lead-retention PASS.** F1 is corroborated by repair revision `5e847472`, which adds `S051 … supersedes S049` for exactly the S049 overreach found here.

## F1 — MEDIUM: S049 asserts two facts its own registered capture does not contain

`corpus/SOURCES.md:56` (S049, tier A, `mined`, used-by `corpus/lessons/round-28.md`) claims scope `… no Rev. 6 final at fetch; not final guidance and not an adopted control`; anchor `publication page fetched 2026-10-21 (Rev. 5 final remains the published Part 1)`; teaches `Rev. 6 exists only as a closed-comment draft, so a key-management control must cite Rev. 5 final, not Rev. 6 IPD text; re-check for a final before adopting any Rev. 6 change.`

Its registered capture `.ufo/waves/round-28/captures/S049.body` (sha256 `783c37dc890c6245006c8e22e66f5c79f173717d70e18074db7c671397f47d4d`, 47,868 B — matches `corpus/source-fetches.tsv:92` and `captures/metadata.json`) contains: `grep -c 'Rev\. 5'` → **0** (exit 1, string absent everywhere); `grep -c -i 'supersed'` → **0** (exit 1, no Supersedes field); `grep -o 'Revision 5' | wc -l` → **1**, only inside `Some of the proposed changes from Revision 5 include:`. So `Rev. 5 final remains the published Part 1` and `no Rev. 6 final at fetch` are **unlocatable in the row's own evidence**; both came from a *different* page (`/r5/final`) plus 404 probes on `/r6/final` — and that `/r5/final` page was **explicitly NOT REGISTERED** by this same round (`corpus/lessons/round-28.md:37`: `NOT REGISTERED: proves "Rev. 5 is final" but carries no forward reference to Rev. 6, so it cannot establish currency`). The row nonetheless uses Rev. 5 finality as the basis of a **control-adoption directive** (`must cite Rev. 5 final`) that the lesson says the unregistered page cannot establish.

Counterexample (reproducible, no network): the capture supports only `Initial Public Draft (2025-12-05)` + `comment period closed 2026-02-05` — `Date Published: December 5, 2025`, `Comments Due: February 5, 2026 (public comment period is CLOSED)`, Document History holding only `12/05/25: SP 800-57 Rev. 6 (Draft)`. Everything about Rev. 5 finality and the "no final exists" negative lives outside the row. Corroboration: repair `5e847472` adds `S051 | NIST SP 800-57 Part 1 Rev. 6 IPD, bounded status — … | supersedes S049 — this page proves Rev. 6 is an Initial Public Draft a…` — the L1 independently judged S049's scope too wide for its capture. Blast radius: registry and calibration only (C1/C2, the release clock and all knowledge entries untouched), but it is a **coverage overclaim inside a mined tier-A row**.

## F2 — LOW: S047's scope omits the GHES exclusion its own capture states

`corpus/SOURCES.md:54` (S047) scope ends `… no audience/issuer matching rule (prose-absent), GitHub only`. Its capture (`captures/S047.body`, sha256 `bb94459dc8226d4cd66e5b0481c7a2d2afddb8d2600c3abf2dd3a493fb04ce2d`, 357,518 B) says `Repositories created after July 15, 2026 use an immutable default subject format that includes owner and repository IDs (not available on GitHub Enterprise Server).` The row's `teaches` repeats the 2026-07-15 immutable-owner/repo-ID fact but drops the GHES exclusion, so `GitHub only` is looser than the evidence it cites; the repair's successor S050 adds `GitHub.com only; immutable-subject default is not available on…`. The rest of S047 narrows rather than overclaims: `audience`/`issuer` appear **0** times in the capture prose (`aud`/`iss` only as JSON claim data in two token examples) and the located sentence occurs exactly once.

## PASS — frontier-only, no knowledge/capability overclaim

- **used-by is the lesson only**: S047/S048/S049 (`corpus/SOURCES.md:54-56`) all carry `used-by=corpus/lessons/round-28.md`; nothing else claims them.
- **No knowledge entry cites them**: `grep -rn -E 'S04[789]' corpus/knowledge/ | wc -l` → **0**; `git diff --numstat BASE..cand -- corpus/knowledge/` → empty (zero knowledge churn).
- **Machine-checkable frontier-only**: census BASE → `rows=43 A=41 mined=39 captures=43 entries_sourced=4 legacy=21 inrow=16`; candidate → `rows=49 A=47 mined=45 captures=49 entries_sourced=4 legacy=21 inrow=16` — exactly +6 rows/+6 tier-A/+6 mined/+6 captures while **knowledge coupling (`entries_sourced`, `legacy`) and `inrow` stay unchanged** → no new in-row pin, no knowledge entry bound to a frontier row; `R21-02`'s expectation matches the measured string exactly.
- **No clock overclaim**: `release-clock.py` default at candidate → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0 — S047–S049 are `90d`, so `on_release` stays 30 and no clock binding was fabricated for them.
- **Round-level claims match**: `SCORECARD.md:1124`, `corpus/README.md:241-243`, `LOG.md:1543`, `corpus/lessons/round-28.md:46-49` agree with the measurements; no QUALITY rule (QM27–QM29) cites S047–S049.

## PASS — unopened leads accurately retained

- The 8 lead bullets carry over **verbatim** (BASE `corpus/SOURCES.md:80-87` → candidate `:91-98`); `diff` of §Leads shows **only** an appended Round-28 disposition paragraph (`:100-106`), zero bullet deletions or rewrites.
- The disposition is accurate item-by-item: GitHub OIDC → S047 with **Google Cloud and AWS federation still leads**; secret scanning → S048 with **Gitleaks/Betterleaks and TruffleHog still leads**; NIST → S049 with **Rev. 5 final opened-but-not-registered** and **SP 800-133 Rev. 3 still a lead**; `No existing status/recheck/used-by field changed` — confirmed by the +19/−0 numstat on `corpus/SOURCES.md` (additions only).
- Search-log arithmetic self-consistent: `Identified 19, screened 19, included 6 (S044–S049), excluded 13` = 6 admitted + 13 excluded (Rev.5 final, PyPA int-norm, Go semver, npm node-semver, GitHub releases REST, git-check-ref-format, CVE NVD, cpython#95778, + 5 re-opened feeds).
- **Observation, not a defect**: retained NIST bullet `:94` still reads `NIST SP 800-57 Rev. 5 final and Rev. 6 IPD publication status — leads only, not evidence`, now half-superseded by the disposition below it. That matches lane append-only precedent (round-22 `:114-118`, round-23 `:108-112`), so not scored; a reader of `:94` alone could still misread it.

## Commands run (sandbox copies only; lane checkout untouched)

| command | exit | result |
|---|---|---|
| `git archive 62a33b1 \| tar -x -C <sb>/cand`; `bash corpus/sources-census.sh` (cand) | 0 | `rows=49 A=47 B=0 C=2 queued=1 mined=45 rejected=3 entries_sourced=4 legacy=21 captures=49 inrow=16 inrow_only=0 inrow_nonreproducing=12` |
| same census on BASE `3553d49` tree | 0 | `rows=43 A=41 … captures=43 entries_sourced=4 legacy=21 inrow=16` |
| `python3 -I -B corpus/release-clock.py` (cand) | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| `grep -c 'Rev\. 5' captures/S049.body` / `-i supersed` / `Revision 5` | 1 / 1 / 0 | 0 / 0 / 1 |
| `grep -rn -E 'S04[789]' corpus/knowledge/ \| wc -l` | 0 | 0 |
| `git diff --numstat BASE..cand -- corpus/SOURCES.md corpus/README.md corpus/knowledge/` | 0 | `19 0 SOURCES.md`, `16 1 README.md`, knowledge empty |
| `git diff BASE..cand -- corpus/SOURCES.md` (Leads) | 0 | 8 bullets identical; +8-line disposition appended |
| sha256 of all 6 committed captures vs `source-fetches.tsv` | 0 | S044–S049 all byte-match |
| `python3 -I -B corpus/rendered-text-v1.py digest captures/S049.body` | 0 | `normalized_sha256=d900f1ea…`, 6,175 B = `source-fetches.tsv:92` |

Receipts: `.ufo/waves/round-28/sandboxes/KagiR28.CheckFrontier/receipts.txt` (30 lines). My two exported trees (`base/` 105 MB, `cand/` 108 MB) were **deleted** after receipts were written; no peer scratch touched.

## What I did NOT check (unverified scope)

- **No network fetch**: every capture fact comes from the committed `.ufo/waves/round-28/captures/` bodies; live-page drift is unmeasured.
- **Not re-verified against repair `5e847472`**: I read its `corpus/SOURCES.md` diff (2 added rows: S050 duplicating S047's URL, S051 superseding S049) but ran **no** census/clock on it. Residual risk: S050 and S051 carry the **same URLs** as S047 and S049, so a duplicate-URL (W04) count would rise from the 11 recorded at `.ufo/waves/round-28/census-start.txt:2-12`; whether the census gate flags or merely counts this is **unmeasured by me**.
- S048's row: I checked its located quote and headings (`customizability` → `about-validity-checks`) only, not every scope-cell word.
- No `corpus/knowledge/*` re-verification, no `claim-ledger.sh verify`, no `sources-census.sh --selftest`, no release-clock `--selftest` — other seats' scope. I did not examine `c1-measure.py`/`c2-measure.py` fixture results (C1/C2 axes).
