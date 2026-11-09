author: hyaku closure (non-author integrator, @m_zfl)

# kagi round 70 — verifier spot-check (non-author closure)

Closed 2026-11-09 (UTC). Lane HEAD before `7bd34832c94b81d4cf9bf34113c4952a7f6d9b04`, after
`66f0662b2038c85e98173c3240da610a10989b7c`. Report `.ufo/reports/round-70/kagi.md` (fleet repo).
Verdict: **status ok, admitted=true** — the one declared claim (C1 coverage, capability
acquisition) re-measures at its frozen target on the landed revision. Its filed wording is the
narrowed one, and no axis is harmed.

Driver digest (copied from the mutable `.ufo/watchdog.log`):

- 2026-11-08T21:37:52-03:00 launch kagi round=70 pgid=713008 driver=hyaku-inline attempt=1
- 2026-11-08T23:31:27-03:00 complete kagi round=70; hyaku-inline attempt=1

## 1. Step-1 conformance

| check | command | observed | result |
|---|---|---|---|
| report landed by lane | `git log --format='%an %H %ci' -- .ufo/reports/round-70/kagi.md` | `kagi-shokunin 1e4c27e9fd0a05eeefa481b713218153627c626f 2026-11-08 23:30:50 -0300` | ok |
| report lands last | `git -C kagi-shokunin log -1 --format=%ci 66f0662b` | `2026-11-08 23:30:31 -0300`, 19 s before the report commit | ok |
| SHONEN heading | report §SHONEN | four lines, all `[~]`, each with a pointer | ok |
| cited hashes exist and are ancestors of `master` | `git cat-file -t` + `git merge-base --is-ancestor <h> refs/heads/master` for `7bd34832`, `430cee23`, `0d225553`, `ba8c7305`, `17a89648`, `66f0662b` | all `commit`, all ancestors | ok |
| lane commits by lane identity | `git log --format='%h %an' 7bd34832..master` | 5 commits, all `kagi-shokunin` | ok |
| lane pushed | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin` | `branch=master local=66f0662b… remote=66f0662b… ahead=0 behind=0 head=detached tracked=0 untracked=0` | ok |
| no leftovers | `git -C kagi-shokunin status --porcelain` | empty | ok |
| remote tip | `git ls-remote origin refs/heads/master` | `66f0662b2038c85e98173c3240da610a10989b7c` | ok |
| prompt carries the contract | grep over `.ufo/prompts/kagi-round-70.md` (1002 lines, committed `d6b8c15e` by `kagi-shokunin`) | MISSION/AXES binding; "at least 8 L2 subagents in ONE batched AgentSwarm call" (l.82); §5 commit/push scope/L0 side channel (l.131–135); write scope (l.448); "report lands last and cites the pushed lane hash" (l.516); frontier step §2b (l.42); SHONEN; report path | ok |
| wave dispatched | `jq .counts .ufo/waves/round-70/w1-dispatch.json` | `{"spawn":12,"resume":0,"total":12}`; 12 seat reports under `w1/`, none missing `SEAT-STATUS: complete` | ok |
| lowest-axis duty | SCORECARD round-70 pre-move | all six axes at 9, so any claim satisfies it | ok |

Not a marker: the report names real round work. `git diff --stat 7bd34832 66f0662b` shows 202
files changed and 16038 insertions.

## 2. Claims

**C1 — coverage (capability acquisition), `C1_PKI_TRIAL: value=5` (BASE 0).** Re-measured.

The counter is a frozen claim counter, not a registered gate. I re-ran it over committed bytes from
a `git clone` of the lane checked out at `66f0662b` (scratch `/fast/scratch/hyaku/close-kagi-r70`,
`HYAKU_SCRATCH` pointed there; the scratch is not evidence by itself, and the commands are
reproducible). The counter archives the named revision itself.

- Freeze: `sha256sum plans/round-70-c1.sh` at `66f0662b` and `git show 430cee23:plans/round-70-c1.sh | sha256sum`
  both give `8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed`. The diff `430cee23..66f0662b` does not
  touch `plans/round-70-c1.sh`. Plan §C1 predicate/target/kill rule unchanged; A1–A3 are appended
  below it.
- BASE: `bash plans/round-70-c1.sh 7bd34832c94b81d4cf9bf34113c4952a7f6d9b04` →
  `C1_PKI_TRIAL: value=0 absent=1 pins=1`, rc 1.
- After: `bash plans/round-70-c1.sh 66f0662b2038c85e98173c3240da610a10989b7c` (32 s) →
  `C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2`,
  T1–T5 each `real=HOLDS,shim=BROKEN,spec=1,entry=1,ok=1`, rc 0. No `bao server` process left
  afterwards (`pgrep -af 'bao server'` empty). `bao version` → `OpenBao v2.7.2`.
- Both readings match the report. They also match the committed receipts
  `final/c1-final.txt`, `final/c1-landed.txt`, `final/c1-candidate.txt` (all value=5 rc 0) and
  `controls/receipts/f0-base.txt` (value=0 absent=1).
- Controls, evidence-verified: `controls/receipts/` P1 reads value=5. F1/F2/F3 read value=0
  (F1/F3 shim=HOLDS, F2 spec=0). F4 reads `sourced=0`, F5 `noleak=0` and F6 `nosecret=0`, each
  value=0. Each reads as the report states.
- **Post-wave hardening diff reviewed by me** (A3 hands it to the closure):
  `git diff 0d225553 66f0662b -- corpus/openbao-pki-trial.sh` touches only the header comment and
  the launch block:
  - `setpriv`/`ss` presence checks and `umask 077`;
  - a kernel-chosen port (python `bind(("127.0.0.1",0))`);
  - the token passed via `BAO_DEV_ROOT_TOKEN_ID`/`BAO_TOKEN` env only, with `-dev-no-store-token`;
  - `setpriv --pdeathsig KILL bao server -dev …`;
  - readiness gated on `ss -Hltnp "sport = :$port" | grep "pid=$SP,"` before `bao status`, with
    three retries.

  `setpriv` execs its command, so `$SP` is the server pid, and the ownership check refuses a
  squatter (SE-1 closed in the bytes). T1–T5 bodies are unchanged. The trial's only touch of the
  binary is `command -v bao`. There is no sha/cksum/`/proc`/readlink, so it never reads the shim's
  bytes (agrees with R70Reviewer RV-5). T5's code is a true conjunction: BROKEN if the no_store
  serial is readable **or** listed. Agree with the hardening.
- Measured domain fact (T2 clamp, not refusal): S170 re-opened (below) does carry "Cannot be
  greater than the role's max_ttl value" (count=2). The trial's T2 HOLDS branch requires an issued
  leaf with lifetime ≤ 3660 s. The divergence the entry records is therefore consistent with the
  re-measured run.
- Wording: the filed claim is the narrowed A1 sentence (a count of shim-discriminating verdicts).
  Execution of the mechanics is a reviewed property, not a counted one. I verify the claim **as
  filed**.

**Harm check.**
- `git diff 7bd34832 66f0662b -- SCORECARD.md` is additive only. It adds the capability row "OpenBao
  PKI certificate-lifecycle trial" and the round-70 pre/post-move sections, with all six axes 9 → 9.
  No existing row is rewritten.
- Claim ledger, evidence-verified (lane gate, not executed by me):
  - `final/claim-ledger-verify-final.txt` reads `CLAIM_LEDGER: POLICY (claims=102 policy=5
    stamped=177)` with 0 `STALE` lines (`grep -c STALE` → 0).
  - `final/claim-ledger-verify-final-vs-base.txt`: "diff of verdict classes … BASE vs 17a89648
    full verify: empty, diff rc 0". The only FAIL is `R36-01 reason=verdict-not-final`, also in
    the BASE set.
- `final/harm-rechecks.txt`, evidence-verified:
  - `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 …)`;
  - `DOC_AUDIT: CLEAN (entries=50 row_linked=47 by_hand=3 … unpinned=0 …)`;
  - `SELF_COUNTS: POLICY (… stale=4 …)` with the same four ids as BASE.
- `final/self-description-sweep-landed.txt` reads `SELF_DESCRIPTION: MISMATCH n=28 (… SD5=4 SD6=23 …
  SD8=1 …)`, equal to BASE per the report.
- Plain counts, BASE → after (`git show <rev>:…`):
  - `grep -cE '^ {0,3}\| *S[0-9]{3}' corpus/SOURCES.md`: 160 → 163;
  - `corpus/knowledge/*.md`: 49 → 50;
  - `corpus/claim-ledger.tsv` non-empty lines: 120 → 120;
  - `git diff --stat` on `PROVINCE.md` +1, `SKILL.md` +4, `corpus/README.md` +3/−2,
    `corpus/QUALITY.md` +1, `LOG.md` +24.

**Per-axis verdicts**

| axis | verdict | basis |
|---|---|---|
| coverage | improved | C1 re-measured: BASE `value=0 absent=1` rc 1 → `66f0662b` `value=5` rc 0 on the frozen counter (sha unchanged since freeze); new capability row; the hardening diff is reviewed and agreed |
| depth | unchanged | no claim; the new entry separates enforced from observed lines |
| operability | unchanged | no claim; the trial is runnable but nothing schedules it |
| freshness | unchanged | no claim; S170/S171 recheck `180d`, entry `recheck: on-release` bound (RELEASE_CLOCK bound=32/32) |
| calibration | unchanged | no claim; no new claims-declared mismatch (A2 heading) |
| adjacency | unchanged | no claim; R70Connector CN-2/CN-3 sweep; PROVINCE core line names kake as TLS consumer side |

C1 is not exploratory, so no `unprovable-but-better` ruling applies. Re-measured: the C1 counter
at BASE and after, freeze sha, the trial diff and source read, plain counts, census, and the
sampled sources. Evidence-verified only: the claim-ledger verify, docs audit, release clock,
self-counts, self-description sweep, R36-01 and the eight prefreeze controls.

## 2b. Pre-file falsification ledger

- As prompted: `python3 scripts/hyaku/prefile-falsification.py --lane kagi --round 70` →
  `FINDING wave-missing …/.ufo/waves/round-70/w1-results.json`,
  `PREFILE-FALSIFICATION: SETUP findings=1`, **exit 2**.
- With the wave the lane names: `… --wave kagi-r70-w1` →
  `PREFILE-FALSIFICATION: pass claims=1 rows=10 attack_seats=7 findings=0`, exit 0 (matches the
  report).
- Adjudication: the SETUP is spurious as to the claim. It is the same driver/tool naming mismatch
  routed at round 69 (`kagi-r70-w1-results.json` vs the default `w1-results.json`). The ledger
  covers C1 (the only `claims.json` key) and all seven attack seats. Its five `falsifies-wording`
  rows (Critic, MutTester, Revenger, Sentinel, Connector) each name `plans/round-70.md` (A1/A3) as
  the narrowing, and I read A1/A3 as covering each finding. The R70Sentinel row is seat-marked
  falsifies-number but filed as wording. I agree: SE-1 is a hypothetical squatter the counter cannot
  see. The landed bytes refuse it (pid check above), and my re-run reads 5 with the real server. The
  one `falsifies-number` row (R70ExecGates GX-1/GX-2) is gate harm on the candidate, not the C1
  value. It is repaired: DOC_AUDIT unpinned=0 and RELEASE_CLOCK bound=32/32 on the landed tree.
  No row is unreconciled.

## 3. Discernment spot-check (`corpus/lessons/round-70.md` §Gate)

Re-opened live 2026-11-09 with `curl -fsSL --compressed` and a browser user agent. Quotes were
located in tag-stripped, whitespace-collapsed text (python `re`/`html.unescape`).

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S170 OpenBao PKI API | admit, tier A, `mined` | https://openbao.org/docs/api/secret/pki/ → HTTP 200, sha256 `9fa7693967f3…5e5c1123`, byte-identical to the recorded capture (and to S105's) | agree | the quote "if it is internal the private key will not be returned and cannot be retrieved later" is found count=2 (16 words, ≤25). It is the product's own primary API reference for every T1–T5 mechanic. The lane's own correction (S105 already registers the URL; W04 25 → 26) is accurate: my census shows `S170 duplicate url … across scopes` |
| S172 HashiCorp Vault PKI API | reject, tier A, `rejected`, flip | https://developer.hashicorp.com/vault/api-docs/secret/pki → HTTP 200, sha256 `65104f6b661d…6e061ddd`, byte-identical | agree | the quote "Cannot be greater than the role's max_ttl value" is found count=2 (8 words). "openbao" occurs 0 times and "Vault" 186 times. A different product line cannot ground OpenBao behaviour, and S170 carries the same sentence (count=2). The flip (a Vault-binary measurement) is the right condition |

New `corpus/SOURCES.md` row re-opened: **S171** (https://openbao.org/docs/secrets/pki/) → HTTP 200,
sha256 `c0ec7fbc2243…5c66ab695`, byte-identical to the row's recorded capture. The quote "By keeping
TTLs relatively short, revocations are less likely to be needed, keeping CRLs short" is found
count=1, 15 words (≤25). "OpenBao" occurs 11 times. `corpus/SOURCES.md` names the new entry 2
times in used-by.

Census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit 0.
stdout `kagi	ok	…/corpus/SOURCES.md` plus 26 W04 lines, stderr 0 bytes, which matches the
report's round-end receipt.

## 4. Trend verdicts

| trend | verdict | evidence |
|---|---|---|
| expansion | improved | knowledge 49 → 50 (`openbao-pki-certificate-lifecycle.md`, `source:` S170/S171 both `mined`); new `corpus/README.md` coverage-map row "OpenBao PKI certificate lifecycle (executed)"; one executed capability row; registry 160 → 163. Agrees with the report |
| quality | improved | No admitted entry fails its re-check: the C1 trial is re-executed green and both admitted sources re-open byte-identical. The new entry splits counter-enforced from observed lines and records a measured doc/behaviour divergence (T2 clamp vs S170 "cannot be greater"). The round-69 routed defects (report miscounts, census stderr capture) are corrected in this report, and the stderr receipts are now committed. Agrees with the report |
| discernment | unchanged | both sampled gate decisions agree on re-open. But the S170 admit missed the existing S105 row for the same URL (M70-1, caught by a seat). The freeze named one of four forgery classes (M70-5), and the L1's first harm diff filtered out eight STALE lines (M70-7). Agrees with the report |

## 5. Defects (status-neutral) and items routed to the lane for round 71

1. **SCORECARD freshness sentence stale**: the round-70 post-move freshness row says "S170/S171
   carry `on-release` recheck clocks", but both rows were moved to `180d` at integration (GX-2,
   report §Sources). This was not swept (§Evidence standard, "corrections sweep every mention").
   Append a correction; do not rewrite.
2. **Wave-results name binding still unrepaired** (carried from the round-69 closure item 3): the
   pre-file tool's default `w1-results.json` vs the driver's `kagi-r70-w1-results.json`. The
   prescribed command reads SETUP exit 2. This is operator-side tooling. Name it in `.ufo/l0-questions.md`
   if it is not already there.
3. **Counter blind spots carried** (A1/A3, RE-1 forgeries A/C/D, MT-1 T5 disjunction, SE-1 squatter,
   SE-3 stream-only NOSECRET): the number does not prove execution. A future PKI counter should
   carry legs for these before freezing (M70-5).
4. **Counter header date** (CN-5): comment says S170 was opened 2026-11-09, the registry says
   2026-11-08. Comment only.
5. **SHONEN**: all four boxes are `[~]` (asserted by the author). Box 2 (end-to-end task executed
   and logged) is checkable by a non-author: I re-executed the trial through the frozen counter on
   `66f0662b` and it reads HOLDS 5/5. That is a pointer for the operator. Promotion is operator-owned
   and not done here.
