# RSourcesContract — C3 contract check (round 25)
Seat KagiR25.RSourcesContract-2 · reviewer, leaf · base 4587c61a348e4528717404a68912c373f3ef4d03 (lane HEAD = base).
Lane untracked: `.ufo/waves/round-25/`, `corpus/__pycache__/`, `plans/round-25.md`. Sandbox /fast/scratch/kagi-r25/RSourcesContract-2/lane (clone + checkout at base; `env -i PATH=/usr/bin:/bin HOME=…/home`). Tools installed/updated: none. No fetches, no lane edits, no gate verify/cells on the lane tree.
Axes: calibration (F1,F3,F7,F9) · freshness (F1–F3,F10) · operability (F5,F6,F8,F12).

## Contract lines (verbatim; CORPUS.md unless noted)
C1 :112-115 rule 1 — "The round lesson's `## Gate` records, for every new row, the URL, the access date, and a ≤25-word quote with its location grounding `teaches`. Non-author verification re-opens a sample."
C2 :116-118 rule 2 — "Only `status`, `recheck` and `used-by` change in place, and each change is logged old→new in the round lesson. A correction is a new row whose `teaches` opens `supersedes S0NN —`."
C3 :119-122 rule 3 — "No second method. Claim admission stays in `corpus/QUALITY.md`; the research method stays chousa's … `SOURCES.md` duplicates neither."
C4 :103-104 — "`status` — `queued` (opened, worth mining) · `mined` (cited by ≥1 path in `used-by`) · `rejected` (kept — a rejection is evidence of taste)."
C5 :105-106 — "`opened` — ISO date the row's author opened the source. `recheck` — ISO date or cadence (`90d`, `180d`, `on-release`)."
C6 :19-20 — "each `lessons/round-<N>.md` carries a `## Gate` section (candidates, admitted, rejected with reasons, spot-check result)."
C7 :67-68 — "A change is a new contract version, never an edit to this section."
C8 :80 — "## Registry … the one table below"

## Answers
Q1 Second method (rule 3)? Literal reading: no; C3 bars duplicating admission and the research method, and the TSV does neither. Substance: yes, twice.
- (a) Second definition of the freshness field. `recheck` is the cadence cell (C5), the registry is "the one table" (C8), and the lane says "`recheck:` is the content clock" (knowledge/onepassword-machine-credentials.md:6; sops-age-key-rotation.md:7; vault-openbao-token-lease-lifecycle.md:7). The census never reads that column (E4), so the TSV would be the only validator.
- (b) Second capture/receipt store. source-fetches.tsv:1 is "one capture row per registry id" (sources-census.sh:286 duplicate-provenance). The rendered-quote branch and `--observe` re-run that capture+locate.
- Recommendation: do not land the TSV as designed. Every binding input already lives in the row and source-fetches.tsv; only the feed pointer lacks a home (see Recommended).
Q2 Does binding change a recheck cell; must it be logged? Side-file binding leaves cells unchanged: no C2 entry, but the round lesson must still state "recheck old→new: none" (precedent lessons/round-24.md:74).
- Any cell rewrite is a C2 change and must stay in C5's domain. A clock name is out of domain (C7: new contract version). Use an in-domain cadence or ISO due date; never write an observation date into the cell, since it reads as a due date.
Q3 Must feed pages be SOURCES rows (tier/kind)? Yes. plans/round-25.md:60-61 requires "an official release feed opened this round as its own SOURCES row"; C1 requires it too.
- Census: a capture row is required (sources-census.sh:328 missing-provenance); no in-row `Fetch sha256:` after S016 (:326); used-by may name only knowledge/lessons paths (:215, :227).
- kind from CORPUS.md:91-92. Tier A only as a maintainer statement for scope "<product> release identity"; `community` is never A (:97). Anchor = feed entry + version + publication date, never a bare feed URL (:99-100). Rejected candidates are rows (`REJECTED: …; flip: …`, :103-104; sources-census.sh:219-220). Unopened candidates stay Leads bullets (:83).
Q4 What must the lesson `## Gate` carry per new row? (C1, C6; LEARNING.md:42-45; QUALITY.md:99)
- Candidate and decision (admit / rejected / queued); every rejected candidate listed individually (QM17).
- Canonical URL; access date (= `opened`); ≤25-word quote (`wc -w`, sources-census.sh:277-278) with location and grounding of `teaches`.
- Capture profile curl-fsSL-compressed-v1 and the `rendered-text-v1.py locate` count (precedent lessons/round-24.md:38-43).
- Feed rows: publication date and the version the anchor uses.
- Header `source:` line naming each id whose used-by lists the lesson (sources-census.sh:229-231; precedent round-24.md:1).
- C2 log (old→new per recheck change, or "none"); non-author spot-check with ≥1 admit and ≥1 reject, agree/disagree plus reason (LEARNING.md:42-45).
- Search note goes in SOURCES.md `## Search log` (CORPUS.md:126-128); `## Mistakes` classes come from CORPUS.md:171-176.
Q5 Is `fired` a status change? No. status is closed to queued|mined|rejected (C4; sources-census.sh:191, 195 SC_ENUM). A fired row is a receipt or Gate event; a claim change needs a `supersedes S0NN —` row (C2). anchor and opened are not mutable (C2). Fleet precedent: kaidoku-shokunin/corpus/lessons/round-20-verifier-spotcheck.md:182. A capture re-pin needs an old/new migration record (QM14, QUALITY.md:73).

## Evidence (sandbox, base)
E1 `bash corpus/sources-census.sh; echo exit=$?` → `SOURCES_CENSUS: CLEAN (rows=32 A=30 B=0 C=2 queued=1 mined=29 rejected=2 entries_sourced=4 legacy=21 captures=32 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit=0
E2 awk recheck column ($11) → `on-release=28 90d=4`; status ($9) → `mined=29 queued=1 rejected=2`
E3 awk on-release ids → `S005 … S032`, `on_release=28` (matches plans:69). Of these: queued S005; rejected S008, S030; mined 25.
E4 `grep 'recheck|opened|\$1[01]' corpus/sources-census.sh` → hits are comment text (:47), the knowledge-entry header check (:340, under `for f in "$kdir"/*.md`, :335), the section check that matches the literal "(unopened)" heading (:205), and selftest fixtures (:382–594). verify() (:160–368) never reads column 10 or 11.
E5 `diff CORPUS.md:76-148 .ufo/waves/kaika/SOURCES-CONTRACT-v1.md:9-81` → 3 differing lines, all heading depth (### vs ##); rule and census text identical. exit=1 (diff).
E6 source-fetches.tsv: normalization rendered-text-v1=30, raw-literal-v1=2 (S002, S008); fetched 2026-10-21 = 32 of 32.
E7 S008 declared quote (raw-literal-v1): "You can find the SOPS documentation on `getsops.io <https://getsops.io/>`_" (RST markup).
E8 `python3 corpus/rendered-text-v1.py --selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)` exit=0.
E9 fleet, 21 SOURCES.md: rows=1045, on-release=587, ISO dates=19. Non-listed triggers in 5 lanes = 40 (mado 28 incl. on-change 22; kama 6 everyround; audio 2 frozen; kotoba 2 on-commit; souji 2).
E10 claim-ledger.tsv:52 pins the R21-02 census line verbatim (rows=32 … captures=32); :28 R12-03 pins stamp count 83; :68 R24-05 pins its identity digest; stamps.tsv:72, :74 stamp source-fetches.tsv and SOURCES.md.
E11 release-clock.py, release-clocks.tsv, self-counts.*, lessons/round-25.md and .ufo/waves/round-25/tools/* are absent at base and in the lane tree (glob).
E12 Fixture (sandbox): one-line RST body carrying the declared S008 quote → `rendered-text-v1.py locate` → `RENDERED_TEXT_V1_LOCATE: count=0` exit=1 (TAG_RE, rendered-text-v1.py:66, strips `<https://getsops.io/>`). Fixture, not the upstream bytes.

## Findings (severity order)
F1 high · calibration. Premise "no named release identity" (plans:56-58) is false for 10 of 28: S012 (Vault "v1.21.x" selector label, lessons/round-22-source-errata.md:24-26), S014–S016, S021, S025, S026 (OpenBao 2.7.x), S027–S028 (Python 3.15.0), S029 (curl 8.23.1). The other 18 name none: S022 "Vault 1.17" is a feature note; S023 "v2.x" is a route. The `feed` comparator "the version the anchor names" (plans:60-61) is undefined for series and selector labels. Use "release published after `opened`".
F2 high · freshness. 17 content-bound rows would bind rendered-quote while their cells keep `on-release`. That trigger cannot fire on unversioned pages, which is the defect the plan names. QA4 requires "a `recheck:` trigger (cadence or release event)" (QUALITY.md:23). plans:64 counts on_release apart from bound, which implies cells stay unchanged.
F3 high · calibration. S008 cannot bind either clock: normalization is raw-literal-v1 (E6, E7), and rendered-text-v1 `locate` returns count=0, exit=1 on the declared quote (E12). `bound=28` (plans:69) is unreachable under the two-clock taxonomy.
F4 high · rule 3. See Q1. A kagi-only side table forks a fleet contract in which 587 of 1045 rows already use on-release (E9).
F5 medium · census. The TSV cannot be a used-by citer (:215, :227). A feed row cited only by the TSV must stay `queued`. `mined` needs the citing lesson's `source:` line to name the id (:229-231).
F6 medium · operability. Landing re-pins: R21-02, R12-03, R24-05 (E10); stamps for SOURCES.md and source-fetches.tsv (E10); README index rows only once files exist (CORPUS.md:46-48); gate registry rows at SKILL.md:699 and PROVINCE.md:53. Each lands in the same commit as its stamp and claim row (QM5, QUALITY.md:43).
F7 medium · calibration. `observed=N` can be satisfied by existing captures: 32 of 32 `fetched` dates are 2026-10-21 (E6). Bind the counter to receipt identity and pin the 28-row membership by identity (QM18, QUALITY.md:100).
F8 medium · operability. `CLEAN` with fired=K>0 rows awaiting re-verification is the QM3 weak signal (QUALITY.md:41). Such a verdict must be non-clean.
F9 medium · scope. "every on-release recheck clock" overclaims. Nine on-release declarations sit outside the 28: knowledge feature-bound-credential-review.md:3, onepassword-machine-credentials.md:4, op-ref-consumption.md:371, sops-age-key-rotation.md:5, vault-openbao-token-lease-lifecycle.md:5; lessons round-22-source-errata.md:3, round-22.md:4, round-23.md:3, round-24.md:4. The title "bound and fired today" also conflicts with the criterion "observation for every row"; K may be 0.
F10 low · design. One clock per row means a row whose claim spans release and page text gets one check. S030's flip ("rendered-text-v2") is an internal re-declaration, not an external event.
F11 low · lesson. "current-tense self-description drift" (plans:84) is outside the CORPUS.md:174-176 vocabulary; use `number-drift`.
F12 low · hygiene/terminology. Untracked corpus/__pycache__/: gates must not write bytecode (PYTHONDONTWRITEBYTECODE=1). "Frontier step" (plans:80) misuses README `## Frontier` (README.md:106-112; PROVINCE.md:64 defines frontier as leads, not rows). No README Frontier edit is needed for C3.

## Recommended for L1 (no lane edits made)
- At most 4 new feed rows S033+ (Vault, OpenBao, Python, curl): kind docs or code, tier A for the release-identity scope, opened 2026-10-21 by the author, capture row, no in-row pin, mined via the round-25 lesson.
- Feed-bound (10 rows): keep `on-release`; fired = a release published after `opened`.
- Content-bound (17 rows): recheck → 90d or an ISO due date (kengaku uses ISO cells, E9), logged old→new per row; the clock re-locates the source-fetches quote under rendered-text-v1.
- S008: decide explicitly (leave unbound and say so). Do not claim bound=28.
- Feed↔row pointer: an append-only table in the round-25 Gate. No new TSV unless fleet contract v2 is approved.
- Receipts are dated Gate rows with old/new digests (QM14). Fired rows keep the verdict non-clean (QM3).

## Unrun / residual
- UNRUN: feed existence, versions and quotes (no fetch; rule 1 needs the author to open each source); non-author spot-check; release-clock.py and c3-measure.py (absent); census `--selftest`; claim-ledger verify (forbidden on the lane tree).
- Residual risk: S012's docs-selector label can mis-fire a version comparator (F1).
