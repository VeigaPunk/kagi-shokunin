# R50bReviewerLesson — review of round-50 curation & lesson (6963a3502ffadffbc1e08da8ca66d5c4254c3c7b)

Seat run 2026-11-06. All commands run from `/home/vgpnk/Projects/shokunin/kagi-shokunin` unless stated; absolute paths throughout; scratch `/fast/scratch/hyaku/kagi-r50/R50bReviewerLesson` (trap rm -rf on exit). No token values, no forbidden paths touched; no git mutations.

## (a) Source re-open S106/S107 vs captures — PASS

- Live fetch (2026-11-06, this seat):
  `curl -sS -o $S/S106.live -w "..." https://man7.org/linux/man-pages/man2/PR_SET_PDEATHSIG.2const.html` → `S106 http=200 size=10684`
  `curl -sS -o $S/S107.live -w "..." https://man7.org/linux/man-pages/man1/setpriv.1.html` → `S107 http=200 size=20601`
  sha256 S106 live `5e72367effe41fab8ca6a0969ed39c201c98a7495c9cbc94b574b4949144fc82` = capture `.ufo/waves/round-50/capture/S106.body` — **byte-identical**.
  sha256 S107 live `3bc0de9949a754b35811837d59d76ee1b4934f1747ab835702a7d017437770fd` = capture `S107.body` — **byte-identical**.
- Quote location: `python3 corpus/rendered-text-v1.py locate <capture> "<quote>"` → S106 `RENDERED_TEXT_V1_LOCATE: count=1` rc 0; S107 `count=1` rc 0.
- Word counts (`printf '%s' "<quote>" | wc -w`): S106 quote → **12** (lesson says 12 ✓); S107 quote → **8** (lesson says 8 ✓).
- Page facts vs SOURCES rows (corpus/SOURCES.md:113 S106, :114 S107):
  - S106 row "delivery when the parent thread terminates; cleared for a forked child, preserved across execve except set-user-ID/set-group-ID or capability binaries" — matches page DESCRIPTION verbatim in substance ("cleared for the child of a fork(2)… cleared when executing a set-user-ID or set-group-ID binary, or a binary that has associated capabilities…; otherwise, this value is preserved across execve(2)"). No overclaim.
  - Thread-vs-process point: page CAVEATS "the 'parent' in this case is considered to be the thread that created this process… rather than after all of the threads in the parent process terminate" — row's "the thread that created it" and §cites (§DESCRIPTION and §CAVEATS) correct.
  - "a parent that dies before the setting is made sends nothing" — matches page ("If the parent thread and all ancestor subreapers have already terminated…, then no parent-death signal is sent").
  - S107 row "sets the parent-death signal, then execve the named program" — supported by the page (SYNOPSIS `setpriv [options] program [arguments]`; DESCRIPTION "wrapper around execve(2)", settings "inherited across execve(2)"); "Some LSMs clear the signal on credential changes" matches the --pdeathsig entry ("Some LSMs, most notably SELinux and AppArmor, clear the signal when the process' credentials change"). No overclaim.
  - Version/date claims: S106 footer "man-pages 6.19 2026-02-08", "built from man-pages-6.19.tar.gz on 2026-09-09" ✓; S107 footer "util-linux 2.43.devel-1062-f… 2026-08-03" ✓; host `setpriv --version` → `setpriv from util-linux 2.42.4`, `setpriv --help` line 25 lists `--pdeathsig keep|clear|<signame>` ✓.
  - prctl(2) rejection evidence: `build/R50ScoutSources/prctl.2.html` sha256 `ef698f6c5aab0224e9bf238ea1820160797c15d0adcee8b37fcaac7297866810` = lesson's `ef698f6c…97866810`, 26266 B ✓; every PDEATHSIG occurrence in `prctl.2.flat.txt` is an enumeration/SEE-ALSO cross-reference to `PR_SET_PDEATHSIG(2const)` — "carries none of the semantics" ✓.
  - "the trial cites S106/S107 in its header comment" ✓ (`corpus/openbao-token-trial.sh:20-21`: "(util-linux, S107)", "(prctl PR_SET_PDEATHSIG, S106)").

## (b) Sources census — PASS

- `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → last line `kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`, **rc 0** (19 `W04 duplicate url … across scopes` warnings, informational, same set as `controls/census-start.txt`).
- `bash corpus/sources-census.sh` (lane) → last line `SOURCES_CENSUS: CLEAN (rows=107 A=103 B=2 C=2 queued=1 mined=102 rejected=4 entries_sourced=15 legacy=21 captures=107 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, **rc 0**.
- Registry arithmetic: `git show BASE:corpus/SOURCES.md | grep -cE '^\| S[0-9]+'` → 105; HEAD → 107; diff removes 0 rows, adds 2 (S106, S107) — lesson's "105 → 107, rows added 2, rows touched none" ✓.

## (c) M50-1 checker fail-ability — PASS (able to fail)

- On the filed round-49 report vs candidate receipt:
  `python3 .ufo/waves/round-50/build/R50ScribeLesson/m50-1-fail-count.py /home/vgpnk/Projects/shokunin/.ufo/reports/round-49/kagi.md .ufo/waves/round-49/final/verify-candidate.txt` →
  `VERDICT: FLAG assertions=4 mismatch=4 receipt_count=12`, **rc 1** (line 111 "with 15 FAIL", 112 "with 13 FAIL", 170 "from 15 to 13", 244 "went 15 → 13" — all 4 MISMATCH). Report lines confirmed by direct read.
- On `m50-1-corrected.txt` → `VERDICT: OK assertions=3 mismatch=0 receipt_count=12`, **rc 0**.
- Receipt-sensitivity (report vs BASE receipt) → `VERDICT: FLAG assertions=4 mismatch=3 receipt_count=15`, **rc 1** — matches the lesson's "FLAG rc 1 again when pointed at the BASE receipt".
- Ground truth: `grep -c '^FAIL' verify-candidate.txt` → 12; `verify-base.txt` → 15; base-minus-candidate FAIL ids = `R12-03 R14-01 R36-01` — E50-1's three ids ✓.
- `mistake-receipts.txt` §S1 exists and carries the same S1a/S1b outputs ✓.

## (d) Factual sweep: §Mistakes (lines 33-36), §Closure defects, QM62

Verified statement-by-statement against the cited files:

- **M50-1 (line 34)**: report lines 111/112/170/244 contain exactly the asserted phrases ✓; `grep -c '^FAIL'` prints 12 ✓; checker behaviour as claimed ✓ (§c); QM62 referenced ✓.
- **M50-2 (line 35)**: `.ufo/waves/round-49/final/orphan-servers.txt` records 8 re-parented `bao server -dev` processes (ppid 1020100, elapsed 1299-1896 s) ✓; BASE trial traps are exactly at lines 48–51 (`trap 'cleanup' EXIT`, INT, TERM, HUP via `git show 565c43a:…`) ✓; K1-0 → `expected=0 got=0 MATCH`, K1-F1 → `0/0 MATCH`, K1-P → `expected=3 got=3 MATCH` in `controls/controls-prefreeze.txt:11,12,16` ✓.
- **M50-3 (line 36)**: `build-results.json` (at `.ufo/waves/round-50/build-results.json`) has 12 results, **all with `output: null`** ✓; seat roles match "2 reviewers, 2 critics, 1 mutation-tester, 1 sentinel" exactly (R50ReviewerPlan/Trial, R50CriticClaims/Ceiling, R50MutCounters, R50Sentinel) ✓; `build/swarm-registry.json` createdAt `2026-11-06T22:20:48Z` = **19:20:48 -03** with 12 members — "dispatched at 19:21 -03" ✓; surviving artifacts' mtimes 19:21:32–19:24:05 (R50ExecTrial empty dir, R50ScoutSources fetch artifacts + report `.md` 19:23:29, R50ScribeLesson receipts 19:23-19:24), nothing between 19:24 and the 20:22:55 restart — "only R50ScoutSources … R50ScribeLesson … before the restart" ✓ in substance.
- **Closure defects**: D1→M50-1/E50-1/QM62 ✓; D2→C2 counter guards G2 (plans/round-50-c2.sh:18,80-82) and G5 (:22,91-92) exist ✓; D3 "round 50's C1 counter does not use shims" → `grep -c shim plans/round-50-c1.sh` → 0 ✓; D4→C1 landed (trial line 64 `setpriv --pdeathsig KILL bao server -dev …`, line 34 guard `OPENBAO_TRIAL: SETUP no setpriv` exit 2) ✓; D5 → PROVINCE.md:94 says exactly "sha256-pinned against the release checksums.txt and the GitHub asset digests; the .gpgsig and .sigstore.json signatures were not verified — round-49 closure D5" ✓, knowledge entry `vault-openbao-token-lease-lifecycle.md:190-192` says the same ✓, `plans/round-49-c1.sh:28` and `plans/round-50-c1.sh:31` both carry `PIN_BAO=9c5f3628…b788` at exactly those lines ✓.
- **QM62** (corpus/QUALITY.md:245): rule sentence, evidence ("13 FAIL"/"15 → 13" against a receipt holding 12 FAIL lines) and fix pointer (M50-1; checker FLAG on filed report / OK on corrected) — every clause matches my re-measurements ✓.
- **Other §Gate/§Frontier facts re-verified**: "12 seats dispatched at 19:21 -03" ✓ (above); watchdog `lane-dead-no-report kagi round=50` at `2026-11-06T20:22:55-03:00` (fleet `/home/vgpnk/Projects/shokunin/.ufo/watchdog.log:3082`) ✓; Assimilation `find …/shokuknow/merge/kagi -type f | grep -icE 'pdeath|prctl|process|orphan|bao|vault|lease|token'` → 0 ✓; considerthese newest file `2026-10-26.md` (newest by mtime and name) with exactly **4** numbered proposals ✓; landed C1 header comment ✓.

## Findings

- **R50bRL-1 — defect (dangling receipt pointer).** `corpus/lessons/round-50.md:60` cites `.ufo/waves/round-50/final/census-end.txt` as the round-end census receipt. Command: `ls .ufo/waves/round-50/final/` → only `c1-base.txt c1-candidate.txt c2-base.txt c2-candidate.txt verify-candidate.txt`; `find .ufo/waves/round-50 -name '*census*'` → only `controls/census-start.txt`. rc 0 (both listing commands). Last output line of the find: `…/round-50/controls/census-start.txt`. The claim's substance is independently reproducible (this seat's census run: `SOURCES_CENSUS: CLEAN (rows=107 …)`, rc 0), so no frozen predicate is falsified — this names a receipt-hygiene defect only. Fix route: file the round-end census receipt at the cited path or repoint the sentence.
- **R50bRL-2 — note (literal overstatement, substance holds).** `corpus/lessons/round-50.md:38`: "`git -C /home/vgpnk/Projects/shokunin status --porcelain` lists only `.scratch/run15-wrapup/misroot-cff0b4cb/`". Current porcelain lists **3** entries: ` M .scratch/goal-20261103-hyaku-run15.md`, ` M .scratch/run15-state.json`, `?? .scratch/run15-wrapup/misroot-cff0b4cb/`. The two modified files are orchestrator run15 state (not lane-seat files), so the sentence's conclusion — "no file of this lane's seats at the fleet root" — remains true; only the word "lists only" is inaccurate against the live output. Does not falsify a frozen predicate.
- **R50bRL-3 — note (true figure, receipt does not carry it).** `corpus/lessons/round-50.md:60`: "Census at round start … → `kagi ok`, rc 0, rows 105." `controls/census-start.txt` ends `kagi ok …` / `rc=0` but the W04 output format prints no row count, so "rows 105" is not carried by the cited receipt; it is separately verified true (`git show BASE:corpus/SOURCES.md | grep -cE '^\| S[0-9]+'` → 105, rc 0). Ceiling named, no predicate falsified.
- **R50bRL-4 — note.** M50-3 (line 36) says "only R50ScoutSources wrote its report file and R50ScribeLesson its receipts"; the build dir additionally holds R50ScoutSources' fetch artifacts (`build/R50ScoutSources/` incl. `fetch-receipt.txt`) and an empty `build/R50ExecTrial/` directory (mtime 19:21:32, zero entries). Neither contradicts the sentence's substance (R50ExecTrial wrote nothing; the fetch artifacts belong to the named scout), and the ten-lost-seats conclusion stands. No falsification.

## False/unsupported sentences

**None found** beyond R50bRL-1..4 above. Full sweep covered: lesson lines 1-19 (§Claims C1/C2 statements cross-checked where they cite §Gate/Mistakes-adjacent facts: trial header, controls names/values), §Gate 21-27 (every sha256, byte count, quote, word count, version/date, row arithmetic, prctl rejection), §Mistakes 33-36 (every evidence pointer opened), Misroot 38, Errata 40-41 (E50-1 verified against both receipts), §Closure defects (all five D-pointers opened at exact lines), Routed/Frontier/Assimilation/considerthese. Every pointer in scope resolved to a real file whose content matches the sentence citing it, except the census-end pointer (R50bRL-1).

## Per-item verdicts

- (a) re-open S106/S107, quotes, word counts, SOURCES rows: **PASS** (byte-identical re-fetch; count=1 ×2; 12/8 words; no overclaim).
- (b) census validate + lane census: **PASS** (rc 0 / rc 0; rows=107 CLEAN).
- (c) M50-1 checker able to fail: **PASS** (FLAG rc 1 on filed report, OK rc 0 on corrected, FLAG rc 1 vs BASE receipt).
- (d) §Mistakes/§Closure/QM62 factual sweep: **PASS with 1 defect + 3 notes** (R50bRL-1..4; no false sentence, no frozen predicate falsified).

Instrument note: no frozen instrument edited; all checks read-only. No tool installs were needed (curl/python3/git/setpriv already present; setpriv read via `--version`/`--help` only, sha256 of `~/.local/bin/bao` untouched).
