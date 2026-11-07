author: hyaku closure (non-author integrator, @m_zfl)

# Round 51 — verifier spot-check (non-author closure)

Lane-round: kagi r51. BASE `214d8bf530a0c87c00686493f21af15396284793` → lane HEAD `affb270bc9288bf08f72a0197d705cc06ec5ac67`.
Report: fleet `.ufo/reports/round-51/kagi.md`. Dispatched prompt: fleet `.ufo/prompts/kagi-round-51.md`.
Driver digest (copied from the mutable fleet `.ufo/watchdog.log`):

    2026-11-06T21:17:15-03:00 launch kagi round=51 pgid=4057123 driver=hyaku-inline attempt=1
    2026-11-06T22:25:22-03:00 complete kagi round=51; hyaku-inline attempt=1

`grep -c 'kagi round=51' .ufo/watchdog.log` ⇒ `2` (one launch, one complete; single attempt).

## 1. Step-1 conformance

| Check | Command | Observed | Result |
|---|---|---|---|
| Report committed by lane identity | `git log --format='%an %ae %H %cI' -- .ufo/reports/round-51/kagi.md` (fleet) | `kagi-shokunin kagi@shokunin.local 88eb606230c8afc77d3d23919975d89f98747417 2026-11-06T22:24:42-03:00` — after the last lane commit (`affb270` 22:24:20), before the driver `complete` line (22:25:22) | ok |
| `## SHONEN` heading, one line per box | `grep -cE '^\s*- \[[ x~]\]' SHONEN.md` ⇒ `4`; report §SHONEN has 4 `[~]` lines, no `[x]` | 4 = 4 | ok |
| Cited commits exist and are ancestors of `master` | `git cat-file -t <h>`; `git merge-base --is-ancestor <h> refs/heads/master` for `214d8bf5`, `4ad8ab7c`, `47d09594`, `7eab7aa4`, `affb270b` | all `commit`, all ancestors | ok |
| Lane pushed, nothing left | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin` | `branch=master local=affb270b… remote=affb270b… ahead=0 behind=0 head=detached tracked=0 untracked=0` | ok |
| No leftovers | `git -C kagi-shokunin status --porcelain` | empty | ok |
| Remote tip | `git ls-remote origin refs/heads/master` | `affb270bc9288bf08f72a0197d705cc06ec5ac67` | ok |
| Prompt carries the template contract | `grep -nE '^#+ ' .ufo/prompts/kagi-round-51.md` | §1 MISSION/AXES, §2 claims, §2b frontier, §3 L2 floor, §4 report contract, §5 commit/push, §6 hyaku addendum, §7 scratch | ok |
| Lane commits by lane identity | `git log --format='%h %an <%ae>' 214d8bf5..affb270b` | 4 commits, all `kagi-shokunin <kagi@shokunin.local>` | ok |

Not a marker: four landed commits, 273 files changed (`git diff --stat 214d8bf5 affb270b | tail -1`).

Conformance note (status-neutral): the candidate `47d09594` cited four `final/` receipts that landed only in `7eab7aa4`, so R11-08 read `unresolved=7` at the candidate (`final/r11-08-candidate.txt`); the tip reads the BASE three (`final/tip-r11-08.txt`). Disclosed by the lane; the claim surfaces were complete at the candidate.

## 2. Claims — re-check

### C1 operability — five OpenBao response-wrapping mechanics executed, 0 → 5 (target 5)

Re-measured (my own runs over committed bytes):

- Ground absent at BASE: `git grep -l 'sys/wrapping' 214d8bf5 -- corpus | wc -l` ⇒ `0`; at tip ⇒ `4` (`SOURCES.md`, the entry, `lessons/round-51.md`, `openbao-wrap-trial.sh`). `git cat-file -e 214d8bf5:corpus/openbao-wrap-trial.sh` ⇒ `fatal: path … not in '214d8bf5…'`.
- The trial executes: `git show affb270b:corpus/openbao-wrap-trial.sh > $S/t.sh; bash $S/t.sh --work $S` (OpenBao v2.7.2 on this host, fresh scratch) ⇒

      TRIAL T1 HOLDS first-unwrap-returns-value=1 second-unwrap-refused=1
      TRIAL T2 HOLDS wrap-ttl=2s unwrap-after-4s-refused=1 secret-still-readable=1
      TRIAL T3 HOLDS lookup-path=secret/data/t3 unwrap-after-lookup=1 lookup-after-unwrap-refused=1
      TRIAL T4 HOLDS new-token-differs=1 old-token-refused=1 new-token-returns-value=1
      TRIAL T5 HOLDS original-path=secret/data/t5 rewrapped-path=sys/wrapping/wrap
      OPENBAO_WRAP_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2
      rc=0   (8.05 s; no `bao server` left: `pgrep -af 'bao server' | grep -c kagi-r51-close` ⇒ 0)

- Candidate = frozen reference outside comments: `diff <(git show affb270b:.ufo/waves/round-51/controls/fixtures/ref/corpus/openbao-wrap-trial.sh | grep -v '^#') <(git show affb270b:corpus/openbao-wrap-trial.sh | grep -v '^#')` ⇒ rc 0; the reference was added in predeclaration `4ad8ab7c` (`git log --diff-filter=A`).
- Instruments frozen: `git diff --stat 4ad8ab7c affb270b -- plans/round-51-c1.sh plans/round-51-c2.sh plans/round-51.md plans/round-51-controls.sh` ⇒ empty.
- Capability row: `grep -c '^| OpenBao response-wrapping trial'` SCORECARD ⇒ BASE 0, tip 1. Entry `## Measured (round 51 …)` at `vault-openbao-token-lease-lifecycle.md:270`.

Evidence-verified (counter not executed by me): `final/c1-base.txt` `value=0 absent=1`; `final/c1-candidate.txt` and `final/tip-counters.txt` `value=5 discriminating=5`, every T `real=HOLDS,shim=BROKEN`; hardened successor `final/c1h-candidate.txt` `value=5` with per-test shim vectors; `final/c1h-controls.txt` FA/FB 5 → 0 on the hardened counter, reference 5 → 5. The frozen counter's FA leak is disclosed (M51-2, QM65); admission rests on the real run above plus the machine-checked identity with the predeclared reference — the shim discrimination itself is evidence-verified only.

Verdict: **verified** — operability `improved` (scalar 9 → 9, capability added).

### C2 calibration — declared-claim manifest and §Capabilities readings agree with the repo, 3 → 0 (target 0)

Re-measured:

- Manifest rows ≥ 48: `git show <rev>:corpus/claims-declared.tsv | awk -F'\t' '$1>=48'` ⇒ BASE `48 C1/C2, 49 C1/C2` (25 data rows); tip adds `50 C1/C2, 51 C1/C2` (29 data rows).
- Post-move headings: `grep -nE '^## Round (4[89]|5[0-9]) — post-move'` ⇒ BASE 48, 49, **50** (round 50 without manifest rows = M 2); tip 48–51, each with rows.
- Readings line: BASE latest readings `CLAIMS_DECLARED: CLEAN (claims=23)` against 25 rows (the K07 stale reading = V 1); tip readings line `CLAIMS_DECLARED: CLEAN (claims=29)` against 29 rows.

So M 2 → 0, V 1 → 0, value 3 → 0, matching `final/c2-base.txt` (`value=3 M=2 V=1`, `MISMATCH 50 C1/C2`, `K07 DIFF stated=…23 executed=…MISMATCH (claims=25 mismatch=2)`) and `final/c2-candidate.txt` / `tip-counters.txt` (`value=0 M=0 V=0`, `CLEAN (claims=29)`). The `claims-declared.sh` gate itself is evidence-verified, not executed. Landing checks `final/c2-landing-checks.txt`: the SCORECARD diff removes only the `lane-status:` line, adds no `<!--`, removes no `## `.

Verdict: **verified** — calibration `improved`.

### No owned axis harmed

- `git diff 214d8bf5 affb270b -- SCORECARD.md`: one `lane-status:` line rewritten (3 → 4 named operator reds, adding R38-03 per round-50 closure F5), one capability row, a round-51 note and readings line, one `## Round 51 — post-move` section with all six axes 9 → 9. No deletions beyond the `lane-status:` line.
- Ledger (evidence-verified): `build/R51ExecHarm/verify-base.txt` FAIL 3 (R11-08, R25-02, R36-01) POLICY 3 (R29-01, R29-02, R38-03); `final/verify-candidate.txt` same ids, FAIL 3 POLICY 3. R11-08 reason exit-mismatch → timeout; `final/tip-r11-08.txt` shows `unresolved=3`, the three BASE non-owned spot-check citations. R36-01 unbounded `0`, rc 0, 367 s (`final/r36-01-candidate.txt`). No new red.
- Lane-authored diff outside corpus/plans/.ufo: `LOG.md +10`, `PROVINCE.md +1`, `corpus/QUALITY.md +2` (QM64, QM65). SKILL.md and SHONEN.md untouched.

| Axis | Verdict | Basis |
|---|---|---|
| operability | improved | C1 re-run 5/5 HOLDS; capability row added |
| calibration | improved | C2 3 → 0 re-derived from tsv/headings/readings |
| coverage | unchanged | registry 107 → 109 (`grep -cE '^\| S[0-9]{3} '`), no claim |
| depth | unchanged | no claim; see D1 for an over-read in the measured note |
| freshness | unchanged | no claim; S108/S109/lookup re-fetched byte-identical today |
| adjacency | unchanged | no claim |

## 3. Discernment spot-check (LEARNING.md)

Re-opened today with `curl -sSL https://openbao.org/docs/<path>/`:

| Item | Decision | Re-opened source | Agree/disagree | Reason |
|---|---|---|---|---|
| S109 `api/system/wrapping-wrap` | admit | HTTP 200, 38865 B, sha256 `ae606220…bf76d7f6c` = lesson | agree | Quote "This endpoint wraps the given user-supplied data inside a response-wrapped token." located `count=1`, 11 words; page carries `sys/wrapping/wrap` (8×), the literal T5 asserts. |
| S108 `concepts/response-wrapping` | admit | HTTP 200, 37186 B, sha256 `a555301e…f9cc32ed55` = lesson | agree | Row quote "only a single party can ever unwrap the token and see what's inside" `count=1`, 13 words; §operations states lookup "is unauthenticated", which T3 runs. |
| `api/system/wrapping-lookup` | reject (L1 overruled seat's admit) | HTTP 200, 38444 B, sha256 `baa2501c…72b05586` = lesson | agree | The page says nothing about authentication (`unauthenticated`/`authenticat` count 0); T3's claim rests on S108; field names come from the binary. |
| `api/system/wrapping-rewrap` | reject | HTTP 200, 38748 B, sha256 `7173f3a6…` (lesson records no sha) | agree on decision, **disagree on one reason** | "S108 already states the rewrap mechanic" holds. But the sample response does not show a contradiction: it never states the input token's creation path, and on OpenBao 2.7.2 a token made by `sys/wrapping/wrap` and then rewrapped reads `sys/wrapping/wrap` (my probe: `orig: sys/wrapping/wrap` / `rewrap resp creation_path: sys/wrapping/wrap` / `lookup rewrapped: sys/wrapping/wrap`). The measured fact (rewrap preserves a KV token's `secret/data/<path>`) is right; "which this binary does not do" is an over-read → D1. |

Census: `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ rc 0, `kagi ok …/kagi-shokunin/corpus/SOURCES.md`, 19 W04 (same count as the lane's `final/census-end.txt`). New row re-opened: S109 (`SOURCES.md:116`), quote 11 words ≤ 25, located on the live page.

## 4. Trend verdicts

- **expansion: improved.** Response wrapping absent at BASE (`git grep -l 'sys/wrapping'` 0 → 4 files), now an executed five-test trial I re-ran, two tier-A `mined` rows (S108, S109) cited by the entry, one capability row.
- **quality: improved.** C2 restores a gate the lane's own manifest had broken (3 → 0, re-derived); ledger FAIL/POLICY ids identical BASE → candidate; QM64/QM65 each grounded in M51-1/M51-2. D1 is an over-read in one sentence of the measured note, routed for a named correction, not a false admitted claim of the trial.
- **discernment: improved.** The spot-check agrees with all four sampled decisions (two admits, two rejects), including the L1's overrule of a seat's admit. The one reason I disagree with (rewrap "contradiction") becomes D1 and must become a lesson next round, or the trend reads harmed then.

## 5. Defects routed to the lane (next round; status-neutral)

- **D1 (quality/discernment).** `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292` and `corpus/lessons/round-51.md:22` say the rewrap API page's sample "shows `sys/wrapping/wrap` for a rewrapped token, which this binary does not do". On 2.7.2 a rewrapped `sys/wrapping/wrap`-origin token does read `sys/wrapping/wrap`; the sample omits its input's path, so it is consistent with the binary. Append a named correction (the measured preservation of `secret/data/<path>` stands) and sweep every mention (R51ScoutSource §4a calls the doc "misleading"/"wrong").
- **D2.** The candidate commit cited `final/` receipts that landed one commit later (R11-08 `unresolved=7` at `47d09594`). Land receipts with, or before, the commit that cites them.
- **D3.** Carry the routed items the report names: R51SentinelSecrets S-1 (secrets on argv; HIGH), S-2, S-3; M51-3; adopt `plans/round-51-c1h.sh` for the next trial claim; R51CriticC2 N7/N8/N11/N13 ceilings; R11-08/R36-01 timeout budget under load.
- **Operator note.** SHONEN boxes 2 (end-to-end task in LOG.md) and 3 (instructions executable without oral context) were exercised by this non-author: I ran `corpus/openbao-wrap-trial.sh` from committed bytes with no lane context and got 5/5 HOLDS. Promotion stays operator-owned; no `[x]` written.
