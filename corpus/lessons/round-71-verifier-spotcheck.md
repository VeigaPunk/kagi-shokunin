# Round 71 — verifier spot-check (non-author)

author: hyaku closure (non-author integrator, @m_zfl)

Closed 2026-11-09 (UTC). Lane-round kagi r71; report `.ufo/reports/round-71/kagi.md` (fleet repo);
lane BASE `e0e9603a924d73d9621924cc507b50474d11dae7`, tip `7e7b3927f436a4a1fe335c26b299d7887e3ce4ba`.
Driver digest (copied from the mutable `.ufo/watchdog.log`):

    2026-11-08T23:35:33-03:00 launch kagi round=71 pgid=991863 driver=hyaku-inline attempt=1
    2026-11-09T00:49:44-03:00 complete kagi round=71; hyaku-inline attempt=1

## 1. Conformance (step 1)

| check | command | observed | result |
|---|---|---|---|
| report committed by lane identity | `git log --format='%an %ae %H %ad' -- .ufo/reports/round-71/kagi.md` (fleet) | `kagi-shokunin kagi@shokunin.local 9cc6da776e5fc9937cd9884c0d98bd99ec4f30c5 Mon Nov 9 00:32:21 2026 -0300` (before the 00:49:44 completion line) | ok |
| `SHONEN` heading, one line per box | read report §SHONEN | one `## SHONEN` heading, four `[~]` lines; `git show 7e7b3927:SHONEN.md \| grep -c '\[x\]'` → 0 (0 at BASE) | ok |
| cited commits exist and are ancestors of `master` | `git cat-file -t <h>`; `git merge-base --is-ancestor <h> master` for e0e9603a, 11992955, 39e76bc7, 5b5483a6, 7e7b3927 | all `commit`, all ancestors; linear chain `e0e9603a → 11992955 → 39e76bc7 → 5b5483a6 → 7e7b3927`, all authored `kagi-shokunin <kagi@shokunin.local>` | ok |
| lane pushed, no leftovers | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin`; `git status --porcelain \| wc -l`; `git ls-remote origin refs/heads/master` | `ahead=0 behind=0 head=detached tracked=0 untracked=0`; 0; `7e7b3927…	refs/heads/master` | ok |
| prompt carries template contract | read `.ufo/prompts/kagi-round-71.md` | §1 MISSION/AXES, §2 claims, §2b frontier, §3 L2 floor, §4 report contract (SHONEN line rule), §5 commit/push/L0, §6 hyaku addendum, §7 scratch | ok |
| wave settled | `git show 7e7b3927:.ufo/waves/round-71/w1-dispatch.json \| jq -c .counts`; `w1-results.json` seat count | `{"spawn":12,"resume":0,"total":12}`; 12 | ok |

Not a marker: four landed commits, measured claim, receipts. Status `ok`.

Defect (status-neutral): the report's ledger tally "6 `falsifies-wording` and 3 `neutral`" is wrong.
Its own command `awk -F'\t' '$1 !~ /^#/ && NF>0 {print $3}' .ufo/waves/round-71/claim-falsification.tsv | sort | uniq -c`
at `7e7b3927` prints `5 falsifies-wording`, `4 neutral` (the ledger was not changed after `5b5483a6`).

## 2. Claims

### C1 — depth: OpenBao PKI issuer and revocation channels (sourced S173)

Frozen counter `plans/round-71-c1.sh`, frozen in `11992955` before the candidate `39e76bc7`.

**Re-measured** (I ran the frozen counter myself, from a fresh clone of the lane repo checked out
at `7e7b3927`, scratch `/fast/scratch/hyaku/closure-kagi-r71`, removed afterwards):

    sha256sum plans/round-71-c1.sh
    4d77f19c47c159768f648338f3fe59472301618e2ef1f679ef1b9f504ab8117b   (= controls/receipts/counter.sha256; same bytes at 11992955 and 7e7b3927)
    bash plans/round-71-c1.sh 5b5483a6…  → C1_PKI_ISSUER_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2 T6..T9: real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1   rc=0
    bash plans/round-71-c1.sh 7e7b3927…  → identical line, rc=0
    bash plans/round-71-c1.sh e0e9603a…  → C1_PKI_ISSUER_TRIAL: value=0 absent=1 pins=1   rc=1
    pgrep -a bao → none left                  (wall time 85.6 s)

Reported BASE 0 → after 4: **reproduced exactly**.

**Plain counts over committed bytes** (BASE `e0e9603a` → tip `7e7b3927`):

- `corpus/openbao-pki-issuer-trial.sh`: absent at BASE (`git cat-file -e` fails) → present; candidate
  bytes `diff`-identical to the frozen positive control `controls/p1/…/openbao-pki-issuer-trial.sh`
  at `11992955`; no change between `39e76bc7` and `7e7b3927`.
- knowledge entries `git ls-tree --name-only <rev> corpus/knowledge/ | grep -c '\.md$'`: 50 → 51.
- registry rows `grep -cE '^ {0,3}\| *S[0-9]{3}' corpus/SOURCES.md`: 163 → 164; S173 rows 0 → 1.
- `corpus/stamps.tsv` non-comment lines: 177 → 181 (report: 177 → 181).

**Evidence-verified only** (committed receipts read, not re-executed): nine prefreeze controls
(`controls/receipts/`: F0 value=0 absent=1 rc1; P1 value=4; F2 value=0 with every `art=0` while
`shim=BROKEN spec=1`; F7 value=3 with T7 `art=0`); harm set `final/harm-diff-base-vs-landed.txt`
(21 FAIL / 58 MISSING-ID / 5 POLICY at both, differences only SCORECARD line shifts +3);
`final/harm-rechecks-landed.txt` (DOC_AUDIT CLEAN unpinned=0; RELEASE_CLOCK CLEAN bound=32/32;
CLAIMS_DECLARED MISMATCH mismatch=2 = the carried round-69 pair; SOURCES_CENSUS CLEAN rows=164);
`final/self-counts-landed.txt` (STALE SC-SKILL-STAMPS, SC-SKILL-CLAIMS … same four ids as BASE per the
report); round-70 counter on the landed tree `final/c1-r70-on-landed.txt` value=5 rc0.

**Wording.** The wave falsified the wider wording, not the number (RE-1 verdict–artifact binding,
MT-1 uncounted T9 serial refusal, SE-7 NOSECRET regex, CN-1/CN-2 pre-move sentences, SR-1/SR-2).
Plan Amendments A1/A2 narrow each; the entry's T9 line (line 52) and the SKILL T9 row carry the
MT-1 caveat; the entry carries `[INFERENCE]` on the OCSP/CRL consequences. C1 as filed (A1: four
shim-discriminating verdicts whose real-run artifacts pass the counter's openssl checks) is what the
counter enforces. **C1 verifies.**

SCORECARD harm check: `git diff e0e9603a 7e7b3927 -- SCORECARD.md` is purely additive (capability
row, round-71 note, errata, round-71 pre/post-move sections; all six axes 9 → 9). No owned axis harmed.

### Pre-file falsification ledger (step 2b)

`python3 scripts/hyaku/prefile-falsification.py --lane kagi --round 71` →
`PREFILE-FALSIFICATION: pass claims=1 rows=9 attack_seats=7 findings=0`, exit 0. Ledger
`.ufo/waves/round-71/claim-falsification.tsv`: 9 rows covering C1, 5 `falsifies-wording` each naming
an Amendment A1/A2 narrowing, 4 `neutral`. I checked each named narrowing exists in
`plans/round-71.md` §Amendment A1 / §Amendment A2 and says what the row claims. No failing row to
adjudicate.

### Per-axis verdicts

| axis | verdict | reason |
|---|---|---|
| depth | improved | C1 re-measured 0 → 4 on the frozen counter; new executed trial and entry on ground BASE lacked (score at ceiling 9 → 9) |
| coverage | unchanged | no claim; registry 163 → 164 (S173) is additive, census clean |
| operability | unchanged | no claim |
| freshness | unchanged | no claim; S173 `180d` registry clock, entry `on-release` |
| calibration | unchanged | no claim; `claims-declared` MISMATCH pair carried from round 69, no new mismatch |
| adjacency | unchanged | no claim; S173 adds no W04 (census 26 W04 at start and end) |

## 3. Discernment spot-check (`corpus/lessons/round-71.md` §Gate)

Re-opened 2026-11-09 with `curl -fsSL --compressed` (browser UA); text read after tag stripping.

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S173 | admit, tier A, `mined` | https://openbao.org/docs/secrets/pki/considerations/ — 96207 B, sha256 `42ef7582befb…` (same as the lane's capture) | agree | quoted sentence found once; the page also says "When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL" — the default-issuer/departed-issuer ground that T7 and the entry cite. Vendor documentation, tier A is right. URL absent from the BASE registry (M70-1 search holds). |
| rotation-primitives | reject (not admitted this round, deferred) | https://openbao.org/docs/secrets/pki/rotation-primitives/ — 64986 B | agree, with a note | the page's subject is rotation (34 `cross-sign`, 20 `reissu` mentions; 0 `ocsp`, 0 `revoke-with-key`), outside T6–T9. Note: it does carry one sentence relevant to T6 — "OpenBao's /pki/issuer/:issuer_ref configuration endpoint maintains the leaf_not_after_behavior per-issuer rather than per-role" — which the Gate reason ("not any T6–T9 mechanic") overlooks; S170 §Update issuer already covers the mechanic, so deferral costs nothing. |
| S170 (re-opened, no new row) | re-open | https://openbao.org/docs/api/secret/pki/ — 620683 B, sha256 `9fa7693967f3…` (same as capture) | agree | "It does not update only the provided fields." present (3 occurrences in my tag-stripped text vs the lane's rendered-text count=2: different text renderers, the quote locates either way); this is the POST-overwrite fact behind M71-1. |

New `corpus/SOURCES.md` row S173: quote "For backwards compatibility, the default issuer is used to
service PKI endpoints without an explicit issuer (either via path selection or role-based
selection)." — 23 words (≤25), located once in the live page; status `mined`, opened `2026-11-08`,
recheck `180d`, used-by the new entry.

Fleet census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` →
`kagi	ok	…/corpus/SOURCES.md` plus 26 `W04` lines (S170's is the only PKI one, pre-existing), exit 0 —
matches the report's round-end receipt.

## 4. Trend verdicts

- **expansion: improved** — knowledge 50 → 51, registry 163 → 164, one new executed trial on issuer
  NotAfter policy, per-issuer CRLs, token-less OCSP and proof-of-possession revocation (re-measured).
- **quality: improved** — the counter gained an artifact leg with executed teeth (F2 value=0 only by
  `art=0`; F7 value=3 only by T7 `art=0`) and a wrapper on the real run; wording narrowed on the
  wave's own findings; harm sets equal BASE.
- **discernment: unchanged** — both sampled gate decisions hold on re-open (one with a note), but
  the freeze again named two of three forgery classes (M71-4 repeats M70-5) and left T9's refusal
  conjunct uncounted (MT-1); two frozen pre-move sentences were false against BASE (M71-3).

## 5. Routed defects (lane fixes next round)

1. SCORECARD capability row "OpenBao PKI issuer and revocation-channel trial" says "a `no_store`
   leaf is refused revocation by serial" and "Each verdict flips under its own falsifier shim"
   without the A2 caveat (serial refusal not counted, MT-1) or the A1 binding caveat (RE-1); the
   entry and SKILL carry them. Append a correction note (QM97), do not rewrite.
2. Lesson §Gate reason for rotation-primitives says it bears on no T6–T9 mechanic; the page states
   `leaf_not_after_behavior` is per-issuer (T6). Append a one-line correction to the reason.
3. Freeze design: the forgery classes named in the ceiling keep missing one (M70-5 → M71-4). The
   next freeze must enumerate verdict-from-read-back (forgery C) and uncounted HOLDS conjuncts before
   the wave, or count them.
4. Carried: the four `self-counts` STALE ids and the round-69 `claims-declared` MISMATCH pair remain
   open from earlier rounds.
5. The round-71 report's falsification-ledger tally (6/3) contradicts the ledger (5/4); state the
   corrected count in the next report and LOG (the report itself is fleet-committed history).

## 6. For the operator (promotion is operator-owned)

SHONEN boxes 2 (end-to-end domain task executed and logged) and 3 (instructions executable without
oral context) look checkable by a non-author: this closure re-executed the trial through the frozen
counter (value=4), and R71ExecReplica wrote an independent trial from plan + entry that reads
value=4. Not ticked here.
