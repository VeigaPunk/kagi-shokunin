author: hyaku closure (non-author integrator, @m_zfl)

# Round 52 — verifier spot-check (non-author closure)

Lane-round: kagi r52. BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b` → lane HEAD `282849f7ef236549f06e551dc294f7cfee4fc01d`.
Report: fleet `.ufo/reports/round-52/kagi.md`. Dispatched prompt: fleet `.ufo/prompts/kagi-round-52.md`.
Driver digest (copied from the mutable fleet `.ufo/watchdog.log`):

    2026-11-06T22:30:18-03:00 launch kagi round=52 pgid=2300562 driver=hyaku-inline attempt=1
    2026-11-06T23:48:32-03:00 complete kagi round=52; hyaku-inline attempt=1

`grep -n 'kagi round=52' .ufo/watchdog.log` ⇒ two lines (one launch, one complete; single attempt).

## 1. Step-1 conformance

| Check | Command | Observed | Result |
|---|---|---|---|
| Report committed by lane identity, lands last | `git log --format='%an <%ae> %H' -- .ufo/reports/round-52/kagi.md`; `git log -1 --format='%cd' 418a2839` (fleet) | `kagi-shokunin <kagi@shokunin.local> 418a28396965d114dd4c95282e4e4f626ba1e093`; committed 23:47:34 −03:00, after the lane tip `282849f7` (23:46:20) and before the driver `complete` line (23:48:32) | ok |
| `## SHONEN` heading, one line per box | `grep -cE '^\s*- \[[ x~]\]' SHONEN.md` ⇒ `4`; report §SHONEN box lines ⇒ `4` (all `[~]`, no `[x]`) | 4 = 4 | ok |
| Cited commits exist and are ancestors of `master` | `git cat-file -t <h>`; `git merge-base --is-ancestor <h> master` for `1d984ada`, `52ebb412`, `a2cb69b7`, `282849f7` | all `commit`, all ancestors | ok |
| Lane pushed, nothing left | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin` | `branch=master local=282849f7… remote=282849f7… ahead=0 behind=0 head=detached tracked=0 untracked=0` | ok |
| No leftovers | `git -C kagi-shokunin status --porcelain` | empty | ok |
| Remote tip | `git ls-remote origin refs/heads/master` | `282849f7ef236549f06e551dc294f7cfee4fc01d` | ok |
| Prompt carries the template contract | `diff <(sed -n 1,140p .ufo/prompts/kagi-round-52.md) kimi-shokunin/templates/round-prompt.md` | only `{{LANE}}`/`{{ROUND}}`/`{{FLEET_ROOT}}`/`{{AXES}}` substitutions differ; §6 hyaku addendum, §7 scratch and run-15 notes follow | ok |
| Lane commits by lane identity | `git log --format='%h %an' 1d984ada..master` | 3 commits, all `kagi-shokunin` | ok |

Not a marker: three landed commits, `git diff --stat 1d984ada 282849f7 | tail -1` ⇒ `251 files changed, 10570 insertions(+), 24 deletions(-)`. LOG.md carries `## Round 52` (line 1887, 8 body lines).

## 2. Claims — re-check

### C1 operability (capability) — five OpenBao KV v2 version-lifecycle mechanics executed, 0 → 5 (target 5)

Re-measured (my own runs over committed bytes):

- Ground absent at BASE: `git grep -il undelete 1d984ada -- corpus | wc -l` ⇒ `0`; at tip ⇒ 5 files (`README.md`, `SOURCES.md`, the entry, `lessons/round-52.md`, the trial). Trial and entry absent at BASE (`git ls-tree -r --name-only 1d984ada -- <both paths> | wc -l` ⇒ `0`).
- The trial executes: `git show 282849f7:corpus/openbao-kv-versions-trial.sh > $S/trial.sh; env -i HOME=$S/home PATH=~/.local/bin:/usr/bin:/bin TMPDIR=$S/tmp LANG=C bash $S/trial.sh --work $S/work` (fresh scratch, OpenBao v2.7.2) ⇒

      TRIAL T1 HOLDS cas0-on-existing-refused=1 cas-current-accepted=1 stale-cas-refused=1
      TRIAL T2 HOLDS deleted-data-null=1 deletion-time-set=1 undelete-restores-value=1
      TRIAL T3 HOLDS after-destroy-and-undelete data-null=1 destroyed=1
      TRIAL T4 HOLDS version1-dropped=1 version2-kept=1 version3-kept=1
      TRIAL T5 HOLDS version1-gone=1 version2-gone=1 metadata-gone=1
      OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2
      rc=0   (2.75 s)

- Kill rules re-run: `git diff --stat 52ebb412 a2cb69b7 -- plans/round-52-c1.sh plans/round-52-c2.sh plans/round-52-controls.sh plans/round-52.md .ufo/waves/round-52/controls/fixtures` ⇒ empty (also empty to `282849f7`); `diff <(git show a2cb69b7:corpus/openbao-kv-versions-trial.sh | grep -v '^#') <(git show a2cb69b7:.ufo/waves/round-52/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh | grep -v '^#')` ⇒ identical; `git grep -lE 'r52-[0-9a-f]{24}' <a2cb69b7|282849f7> | wc -l` ⇒ `0`/`0`; `sha256sum ~/.local/bin/bao` ⇒ `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (= the pin in `final/kill-rules.txt`).
- Entry: `git show 282849f7:corpus/knowledge/openbao-kv-v2-version-lifecycle.md | grep -cE '^- T[1-5] .*OpenBao 2\.7\.2'` ⇒ `5` under `## Measured (round 52 …)` (line 23). Registry: S110 row `status= mined`, `recheck= 180d`, 13 fields; registry rows `grep -cE '^\| S[0-9]{3} '` ⇒ 109 → 110. Capability row `| OpenBao KV v2 version-lifecycle trial |` appended in `SCORECARD.md`.

Evidence-verified (frozen counter not executed by me): `final/c1-base.txt` `value=0 absent=1 pins=1`; `final/c1-candidate-rev.txt` `value=5 discriminating=5 … noargv=1(real=31,real2=31) src=1(S110)`, shim vectors BHHHH/HBHHH/HHBHH/HHHBH/HHHHB as frozen; `final/c1-execution-evidence.txt` 31 recorded calls including `kv put -cas=…`, `kv undelete`, `kv destroy`, `kv metadata put/delete`, 0 token-shaped argv elements. The counter's printed-protocol hole (M52-4: F2/F5b/F6 score 5, K1-F8 vacuous) is disclosed and routed; admission here rests on the counter **plus** my independent execution above, which shows the committed trial runs the five mechanics against a live dev server.

Verdict: **verified** — operability `improved` (scalar 9 → 9, capability added).

### C2 calibration — lane statements about rewrap agree with the pinned binary, 2 → 0 (target 0)

Re-measured:

- BASE population: `git show 1d984ada:<file> | grep -n -i rewrap` — `vault-openbao-token-lease-lifecycle.md:292` and `lessons/round-51.md:22` carry the over-read ("…`sys/wrapping/wrap` for a rewrapped token, which OpenBao 2.7.2 does [not]…"); the other rewrap lines (`:279`, `round-51.md:9/19/50/56`) state mechanics, not a doc-vs-binary judgement. 2 uncorrected.
- Tip: `grep -n 'Correction (round 52'` ⇒ `vault-openbao-token-lease-lifecycle.md:294` (points at `:292`) and `round-51.md:66` (points at `:22`), each naming both measured creation paths. Append-only: `git diff --numstat 1d984ada 282849f7 -- <file>` ⇒ `2 0` for each, and the BASE bytes are an identical prefix of the tip file. 0 uncorrected.
- Truth of the correction, independent probe (my own throwaway `bao server -dev`, 127.0.0.1, OpenBao 2.7.2): KV read with `-wrap-ttl` → `creation_path=secret/data/p`; `sys/wrapping/rewrap` of it → `secret/data/p` (lookup agrees); `sys/wrapping/wrap` token → `sys/wrapping/wrap`; its rewrap → `sys/wrapping/wrap`. Live rewrap API page (`https://openbao.org/docs/api/system/wrapping-rewrap/`, sha256 `7173f3a6…`, same bytes as the lane's) has `creation_path` once, inside the sample response `"creation_path": "sys/wrapping/wrap"`, with no statement of the input token's path. The corrected statements agree with the binary.

Evidence-verified: `final/c2-base.txt` `value=2 … uncorrected=[…:292 …round-51.md:22]`; `final/c2-candidate-rev.txt` and `final/tip-counters.txt` `value=0 … uncorrected=[]`. E52-1 (SCORECARD round-51 depth row, lexical ceiling) appended as an erratum, uncounted as declared.

Verdict: **verified** — calibration `improved`.

### Harm check

- `git diff 1d984ada 282849f7 -- SCORECARD.md`: pure appends (20 lines, 0 deletions) — capability row, round-52 readings, post-move table with every axis 9 → 9, erratum E52-1. No axis score lowered.
- Ledger (evidence-verified): `build/R52ExecHarm-verify-base.txt` FAIL R11-08/R25-02/R36-01, POLICY R29-01/R29-02/R38-03; `final/verify-tip.txt` the same six ids (`CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`). The candidate read four extra FAILs (R12-03/R22-03/R24-05/R24-15, stamp population 124 → 125), migrated in `282849f7` with journal (M52-5) — not present at the tip.
- Gate amendment `corpus/claims-declared.sh` (M52-2): diff is code-span masking in both awk readers plus selftest case 13; red witness `final/gate-m52-2.txt` ⇒ `CLAIMS_DECLARED_SELFTEST: FAIL (passed=12/13)` on the BASE gate, `PASS (13 cases)` amended; `final/harm-counters.txt` K07 `CLEAN (claims=31)`, K10 `PASS (13 cases)`, `C2_CAPABILITY_READINGS: value=0`.
- Spot reads: SKILL.md, PROVINCE.md, SHONEN.md unchanged (`git diff --numstat` lists none); QUALITY.md +2 (QM66/QM67), README.md +1.

### Per-axis verdicts

| Axis | Verdict | Basis |
|---|---|---|
| operability | improved | C1 re-measured (trial run, kill rules) + counter evidence |
| calibration | improved | C2 re-measured (grep, append-only prefix, independent probe) |
| depth | unchanged | 9 → 9; new entry, no claim |
| coverage | unchanged | 9 → 9; S110 + coverage row, no claim |
| freshness | unchanged | 9 → 9; no claim |
| adjacency | unchanged | 9 → 9; no claim |

Re-measured: C1 ground/trial execution/kill rules/entry/registry; C2 population before→after and the correction's truth. Evidence-verified: both frozen counters' readings, ledger verify ids, gate selftest/red witness, harm counters.

## 3. Discernment spot-check (LEARNING.md)

| Item | Decision | Re-opened source | Agree/disagree | Reason |
|---|---|---|---|---|
| S110 OpenBao KV v2 page | admit (tier A, mined) | `curl -fsSL --compressed https://openbao.org/docs/secrets/kv/kv-v2/` ⇒ 200, sha256 `6cfd72eca347d0dfbcea73ad429ae5db3f01f2710cd794a473b00047e02b1587` (byte-identical to the lane capture) | agree | All four Gate quotes located once in the tag-stripped text (row quote "When deleting data the standard bao kv delete command will perform a soft delete." 14 words, count 1; T1 19 w, T3/T4 20 w, T5 9 w — all ≤ 25); page states undelete (7), destroy (28), metadata delete; official docs for the scope ⇒ tier A is correct. |
| `https://openbao.org/docs/api/secret/kv/kv-v2/` | reject | re-fetched ⇒ 200, sha256 `9c1fa5b1e88f…` (= lane's `9c1fa5b1…`) | agree | HTTP API reference; the entry cites only CLI-level mechanics S110 states. The flip is well-chosen: the page holds `cas_required` (9×), `delete_version_after` (15×) — exactly the engine parameters a future claim would need. |
| `https://openbao.org/docs/commands/kv/undelete/` | reject | re-fetched ⇒ 200 | agree | Command reference page; every mechanic the trial runs is already stated on S110; flip (a documented CLI default/validation claim) is concrete. |
| `https://openbao.org/docs/api/system/wrapping-rewrap/` | not re-registered (C2 evidence) | re-fetched ⇒ 200, sha256 `7173f3a6b1bc…` | agree | One `creation_path`, inside the sample response; no sentence states the input's path — supports the withdrawal. |

SOURCES row re-opened: S110 (above); its `teaches` (versions, check-and-set, soft delete reversed by undelete, destroy) is grounded on the page. Census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ `kagi ok …/corpus/SOURCES.md`, rc 0, 19 W04 duplicate-url warnings (S019…S091, none on S110); manual census malformed rows `0`, duplicate ids `0`.

## 4. Trend verdicts

- **expansion: improved** — new executed ground (`undelete` corpus files 0 → 5; trial + entry + S110; capability row), re-run by the closure.
- **quality: improved** — the declared-axis gate no longer drops headings after a backticked `<!--` (red witness 12/13 → 13); new trial closes round-51 S-1/S-2/S-3/M51-3 (no argv secrets per `c1-execution-evidence.txt`); ledger FAIL/POLICY ids unchanged BASE → tip.
- **discernment: improved** — the round-51 over-read is withdrawn by truth-bound corrections that the closure's own probe confirms; admit/reject decisions carry reasons and flips the closure agrees with (4/4); the counter weakness found by the wave is recorded, not claimed fixed.

## 5. Routed defects (lane fixes next round)

- **D1 (recurrence of r51 D2, status-neutral):** candidate `a2cb69b7` still cites a receipt that lands later — `corpus/lessons/round-52.md:56` → `.ufo/waves/round-52/final/census-end.txt` (`git ls-tree a2cb69b7 .ufo/waves/round-52/final/census-end.txt | wc -l` ⇒ `0`; `final/citations-candidate.txt` `unresolved=5`). Disclosed by the lane; the round-51 D2 fix ("every receipt the candidate cites lands in or before the candidate") did not hold for the census-end receipt.
- **D2 (M52-4, routed by the lane):** harden the C1-class trial counter so it checks execution, not printed verdicts (F2 shim fingerprinting, F5b run-dir order, F6 printed T2–T5; make K1-F8 non-vacuous) — the receipt `c1-execution-evidence.txt` is the stopgap.
- **D3 (M52-5):** the ledger's stamp-population coupling surfaced only on the full candidate verify (four FAILs migrated after the candidate); run the full verify before freezing the candidate.
- **D4:** R52ReviewerTrial D1–D4 trial defects and R52CriticC2 A2/A13/A17/A24/A26, R52ReviewerC2 F1 ceilings stay open as the lane routed them; R11-08/R36-01 remain.

Operator note: SHONEN boxes 2 (end-to-end task) and 3 (instructions executable without oral context) were exercised by this non-author closure — the committed trial ran from committed bytes with no lane context and reproduced T1–T5 HOLDS. Promotion is operator-owned; nothing is marked `[x]` here.
