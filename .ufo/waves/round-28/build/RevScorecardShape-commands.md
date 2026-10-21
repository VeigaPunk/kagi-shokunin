# RevScorecardShape — commands run, with exits

Companion artifact to `RevScorecardShape.md` (the report). Every command was run
by the reviewer in the sandbox
`.ufo/waves/round-28/sandboxes/RevScorecardShape-7/` — `base` = `git archive` of
BASE `3553d499577084a6c98d7078906017840bbf7b28`; `clone` = `git clone --no-local`
of the lane checkout, checked out at BASE, at candidate `62a33b1` (`@cand`), or
with the candidate's `SCORECARD.md` locally edited (each edit is stated).
No production file was modified in the lane; only this wave directory was written.

| # | Command | Where | Exit |
|---|---|---|---|
| 1 | `bash corpus/claim-ledger.sh cells` | base, clone@BASE | **2** (`unrecognised round heading … '## Round 26 — bounded release-drift response'`) |
| 2 | `bash corpus/claim-ledger.sh cells --allow-host-rows` | base | **2** (same) |
| 3 | `bash corpus/claim-ledger.sh verify` | clone@BASE | **1** — `CLAIM_LEDGER: INCOMPLETE (claims=65 layout_incomplete=1 deferred=0 stamped=90 ids=65 cited=55 labeled_ids=20 orphans=10 host_skipped=12)` |
| 4 | `bash corpus/claim-ledger.sh verify --allow-host-rows` | clone@BASE | **1** — `INCOMPLETE (… deferred=11 … host_skipped=0)` |
| 5 | `python3 -I -B corpus/release-clock.py` | clone@BASE | 0 — `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| 6 | `python3 -I -B corpus/release-clock.py --selftest` | clone@BASE | 0 — `RELEASE_CLOCK_SELFTEST: PASS (79 cases)` |
| 7 | F1 fixture: S040 `observed_version=3.15.01`, `verdict=fired`, receipt record mirrored to `parsed_version=3.15.01`/`verdict=fired`, run with `--receipt <copy> --receipt-sha <sha>` | clone@BASE | 0 — `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)` → **the leading-zero lie is accepted as a fired release** (plan's C1 premise) |
| 8 | F2 fixture: S040 `observed_version=3.15.` + 4301×`1`, `verdict=fired` | clone@BASE | **1** — `ValueError: Exceeds the limit (4300 digits) for integer string conversion` traceback at `corpus/release-clock.py:380` (`numeric_version`) |
| 9 | `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d499577084a6c98d7078906017840bbf7b28 base-check /tmp/c2-base.json` | lane checkout (read-only tool) | 0 — `C2_MEASURE base-check: groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0` |
| 10 | `bash corpus/row-identity.sh scorecard-rounds` | clone@BASE | 0 — `ROW_IDENTITY: scorecard-rounds count=33 sha256=cb0f57e0ac92dcac02001d55b70ece7daca8b5e6a71467de21abf6598490bbac` |
| 11 | `bash corpus/row-identity.sh scorecard-rounds` (26+27+28 headings renamed to `pre-move\|post-move` form) | clone@candidate | 0 — `count=34 sha256=069aac650e92ef56559dc3724afb3290af161aadc290d647f846a1329272fca7` ≠ candidate's pinned `c59f5341b350064bddb6a7ae79a68bf2ca9a02cf77ccdac7c979ab7b3873e661` |
| 12 | `bash corpus/row-identity.sh stamps` / `ledger-ids` / `revision-added` | clone@BASE | 0 — `count=90 sha256=b88b27f4…` / `count=65 sha256=f06ca9d5…` / `count=27 sha256=76b102b8…` |
| 13 | `bash corpus/claim-ledger.sh cells` (three headings made conforming; candidate's own tables) | clone@candidate | **1** — `UNCITED SCORECARD.md:1121 freshness`, `:1122 calibration`, `:1124 coverage`; `CELL_AUDIT: BROKEN (cells=198 row_pointed=143 stamp_pointed=89 uncited=3 missing_ids=0 rows_run=36 row_failures=1 stale_pointers=1 self_skipped=5 orphans=10 host_skipped=12)` |
| 14 | same, plus `corpus/lessons/round-28.md` added to the three uncited cells | clone@candidate | **1** — `uncited=0 stamp_pointed=92`; the remaining reds are my own `STALE-POINTER SCORECARD.md` (my edit) and `FAIL R22-03` (needs the real `c2cab35` history, absent in the archive copy) |
| 15 | `bash corpus/claim-ledger.sh cells` (26+27 renamed, round 28 left as landed) | clone@candidate | **2** — dies on `## Round 28 — canonical version tokens; derived anchors bound to feed rows` |
| 16 | `bash corpus/claim-ledger.sh cells` (26+27+28 renamed, six-axis table present) | clone@candidate | **1** — the audit now reaches round 28; only `STALE-POINTER SCORECARD.md` (my edit) and `FAIL R22-03` remain |
| 17 | `bash corpus/claim-ledger.sh stamp SCORECARD.md` (alone) | clone@BASE | **2** — `refusing to shrink …/corpus/stamps.tsv: 'LOG.md' is pinned and would be dropped (existing 90 rows, new 1; pass --prune to accept)` |
| 18 | `bash corpus/claim-ledger.sh stamp <all 90 pinned paths> corpus/lessons/round-28.md` | clone@BASE | 0 — `STAMPED: n=91 out=…/corpus/stamps.tsv` |
| 19 | `bash corpus/claim-ledger.sh verify` (one comment line appended to `SCORECARD.md`, not re-stamped) | clone@BASE | **1** — `STALE SCORECARD.md sha=e314c2979860->d4bc3e764079 lines=1107->1109 bytes=121132->121148`; `CLAIM_LEDGER: FAIL (claims=65 failed=2 … stale=1 …)` |
| 20 | `bash corpus/claim-ledger.sh verify` (simulated full landing: + `corpus/lessons/round-28.md` pinned, + round-28 SCORECARD section appended, stamps refreshed, ledger pins **not** migrated) | clone@BASE | **1** — `FAIL` on R12-03, R13-01, R22-03, R24-05, R24-06, R24-15, R25-02; `CLAIM_LEDGER: FAIL (claims=65 failed=7 deferred=0 stamped=91 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)` |
| 21 | `python3 corpus/self-counts.py` (same simulated landing) | clone@BASE | **1** — `STALE SC-SKILL-STAMPS SKILL.md:46 claimed=90 live=91`, `STALE PV-STAMPS PROVINCE.md:52 claimed=90 live=91`, `STALE RD-STAMPS corpus/README.md:65 claimed=90 live=91`; `SELF_COUNTS: STALE (claims=60 stale=3 unlocated=0 ambiguous=0)` |
| 22 | `bash corpus/claim-ledger.sh verify` | clone@candidate `62a33b1` | **1** — `CLAIM_LEDGER: INCOMPLETE (claims=65 layout_incomplete=1 deferred=0 stamped=91 ids=65 cited=55 labeled_ids=20 orphans=10 host_skipped=12)` (no `FAIL` rows) |
| 23 | `bash corpus/claim-ledger.sh cells` | clone@candidate `62a33b1` | **2** (round-26 heading, as at BASE) |
| 24 | `python3 -I -B corpus/release-clock.py` / `--selftest` | clone@candidate | 0 — `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` / `PASS (106 cases)` — matching the candidate's `R25-04`/`R25-03` pins |
| 25 | `bash corpus/row-identity.sh stamps` | clone@candidate | 0 — `count=91 sha256=14663dcd2ee9f3528c6c233cf426f13b6db93ca9767eda0758fd7a2196d4b264` (matches candidate's `R24-05` pin) |
| 26 | policy probe: ledger row `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d49 x /tmp/o.json` | clone@BASE | **2** — `POLICY R28-99 reason=python-script` (`claim-ledger.sh:262-278` `ALLOWED_RE` / `PYTHON_SCRIPT_RE`) |
| 27 | `grep -c '^## Round ' SCORECARD.md` / `grep -o "python3 -I -B [^ ]* <rev> <label> <out[^>]*>"` | clone@candidate | 0 / 0 — count `34`; the candidate renders `<out>` where `plans/round-28.md:29,59` freeze `<out.json>` |
| 28 | `awk -F'\t' '$1=="R13-03"{print ($6 ~ /\[substrate\]/)?"SUBSTRATE-tagged":"not tagged"}' corpus/claim-ledger.tsv` | lane | 0 — `SUBSTRATE-tagged` (so `verify` HOST-SKIPs it by default) |
| 29 | `bash corpus/claim-ledger.sh verify` | clone@BASE (real `.git` present, so `revision-audit` works) | **1** — `CLAIM_LEDGER: INCOMPLETE (claims=65 layout_incomplete=1 deferred=0 stamped=90 …)`; no `FAIL` rows |
| 30 | `git diff --stat 3553d49..HEAD` (read-only, lane) | lane | 0 — 119 files; `SCORECARD.md` +22 lines (the candidate's round-28 section), `corpus/claim-ledger.tsv` pin migrations for R12-03/R13-01/R22-03/R24-05/R24-06/R24-15/R25-03, `corpus/stamps.tsv` +1 (round-28 lesson), `corpus/release-clock.py` +357/-…, `corpus/SOURCES.md` +19 (S044–S049) |
