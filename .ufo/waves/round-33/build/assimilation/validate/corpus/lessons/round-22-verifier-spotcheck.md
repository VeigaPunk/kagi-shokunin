author: hyaku closure (non-author integrator, @m_opus)

# round-22 — non-author verification and spot-check (hyaku closure)

Written by the integrator, not the lane (CORPUS.md: outside reviews are new files; the lane owns
`round-22.md`). Inputs: fleet report `.ufo/reports/round-22/kagi.md` (fleet commit
`c5c5d1d26443a5c6f753c9f2424a3e0ed4822cec`), prompt `.ufo/prompts/kagi-round-22.md`, lane BASE
`c2cab35bc92e57e39e5489bac3386db078345b3f` → final `254d632ed2f6174e1ffcfe636a17b5e18284212f`
(measured code/data `4be5da3cac11a1db64c3e0a77246fd7f2bdee413`). Watchdog digest (copied):
`2026-10-20T18:30:55-03:00 launch kagi round=22 pgid=1119391 driver=hyaku-inline attempt=1` /
`2026-10-20T20:24:43-03:00 complete kagi round=22; hyaku-inline attempt=1`. Four read-only review
seats (C1 evidence, discernment, safety, wave/debt) were dispatched by the closure, not the lane.
No lane gate, legacy verifier, vault/account operation, installer or version wrapper was run.

## Step-1 conformance

| check | command | observed |
|---|---|---|
| report author | `git log --format='%an %H' -- .ufo/reports/round-22/kagi.md` | `kagi-shokunin c5c5d1d2…` (20:23:56-03:00, after lane final 20:19:12; pushed to fleet origin) |
| SHONEN heading | report §SHONEN vs `grep -c '^- \[' SHONEN.md` | 4 lines, 4 boxes, all `[~]` with pointers |
| cited hashes | `git merge-base --is-ancestor <h> refs/heads/master` for 8ada17a5, 4be5da3c, 254d632e | all ancestors |
| pushed/clean | `scripts/hyaku/jj-lane.sh state …` ; `git status --porcelain \| wc -l` ; `ls-remote origin refs/heads/master` | `ahead=0 behind=0 tracked=0 untracked=0`; 0; remote = `254d632e…` |
| prompt contract | difflib of template vs prompt lines 1–140 | only placeholder substitutions (22 changed lines); §6 hyaku addendum appended |
| range | `git log c2cab35..254d632` | 3 lane commits + 1 operator `considerthese` commit |

No conformance defect in step 1.

## Claims — re-check

**C1 calibration capability (feature-bound typed credential review).** Evidence-verified, with
plain re-measurement of presence: `git cat-file -e c2cab35:corpus/feature-claims.py` fails,
`git show c2cab35:corpus/revision-audit.py` fails; both present at 4be5da3/254d632 and
`git diff --stat 4be5da3 254d632 -- corpus/feature-claims.{py,json}` empty. All seven
`final-verification-inputs.json` digests equal `sha256(git show 4be5da3:<path>)`. Committed
`final-verification.json`: R22-01 `--phase after` exit0 `admitted=4 … unjudgeable=0`; R22-02
`--selftest` exit0 `PASS cases=12`; `--phase before` exit1 with 10 decisions (2 `reject:false-claim`,
8 `reject:bar-fail`); `--phase boundary` exit2 with 3 `cannot-evaluate scored=no`. Source read:
`--input` takes one record through an 8-key allowlist (a caller label is `FC-UNKNOWN-FIELD`,
cannot-evaluate, never admission); exit map 0/1/2 matches the SKILL.md registry row. The three
boundary records are structurally unjudgeable (unknown source S999, uncatalogued feature, extra
qualifier) and `_run_phase` fails closed if a boundary ever yields a decision — the exclusion does
not hide inconvenient cases. Four `falsify/Mut*.md` mutants killed with exit-0 controls (run on H1
bytes; the H1→final diff leaves detector paths unchanged and final bytes were re-run). Scalar held
9→9; no calibration statistic claimed. Verdict: **verifies as a capability acquisition**.

**C2 freshness / pointer integrity.** Re-measured by me without the lane auditor: parse
`corpus/stamps.tsv` at each revision, compare `sha256`, LF count and byte length of
`git show <rev>:<path>`:

```text
c2cab35 stale=['corpus/knowledge/config-layering.md','corpus/knowledge/handler-on-disk-state.md',
        'corpus/knowledge/handler-trust-boundary.md','corpus/knowledge/janitor-env-contract.md',
        'corpus/lessons/round-18.md','LOG.md'] missing=[]
4be5da3 stale=[] missing=[]     254d632 stale=[] missing=[]
base members 63, final 70, dropped [], added 7 (feature-claims.json/.py,
feature-bound-credential-review.md, round-21-verifier-spotcheck.md, round-22-source-errata.md,
round-22.md, revision-audit.py)
```

Matches the report (6→0, 63→70, dropped 0, added 7) and the committed `before-runnable.json`
(`DRIFT (stale=6 …)`, exit1). Frozen population is source-bound: the six snapshot inputs under
`.ufo/waves/round-22/frozen/before/` are byte-identical to BASE, and its `expected.json`
`expected_stale_original` equals my independently derived six. Drift origins traced through
`git log`: four knowledge pins drifted at `f4a8dd9` (round-16 errata), round-18 lesson at
`bad9088` (round-19 audit), LOG at `584dd67`/`c2cab35` — all committed lane/operator history, so the
re-pins bless reviewed, appended text rather than laundering unknown edits. Verdict: **verifies**.

Retained heading regressions: `heading-regressions-final.json` `case_count=17 passed=17`, bound to
`after_implementation_sha256 cf56f9ea…` = `sha256(git show 4be5da3:corpus/claim-ledger.sh)`.
Selftest tallies evidence-verified in `final-verification.json`: ledger 121 (R11-09/R18-03),
feature 12 (R22-02), revision 17 (R22-04), source 47 (R21-03); `summary` = 31 safe rows, 31 passed,
12 skipped, 0 exit mismatches.

**Exclusions/skips.** The 12 skipped IDs (R11-01/02/03/04/06, R12-01, R13-03, R15-01, R16-01/03,
R17-01, R18-01) are inherited host/substrate rows; none of R22-01…04 is skipped, so no C1/C2
dependency is removed. Residual: R13-03 `claim-ledger.sh cells` is skipped although this round
changed the cell/heading parser; it is covered only by the 17-case fixture set (routed D9).

Re-measured: C2 counts, C1 presence/absence, input digests, frozen-snapshot identity, heading
binding. Evidence-verified only: every gate exit/tally (sibling gates were not executed).

## Per-axis verdicts

SCORECARD diff (`git diff c2cab35 254d632 -- SCORECARD.md`): 132+/1− (the one line is the
capability-table footnote rewritten to add the new row); every axis 9→9. Spot reads: knowledge,
QUALITY, SOURCES, LOG and PROVINCE changes are appends (the single `-` lines are EOF-newline
artifacts re-added verbatim); claim-ledger rows rewritten in place each carry an old/new journal in
`pin-migrations-integration.json` `claim_changes` (12) per `knowledge/claim-ledger.md` §Erratum.

| axis | verdict | basis |
|---|---|---|
| calibration | improved | C1 capability demonstrated (scalar held 9 by the lane) |
| freshness | improved | stale pins 6→0 re-measured, zero members lost (scalar held 9) |
| depth | unchanged | R21-01 unchanged, no depth claim |
| coverage | unchanged | new entry corrects held E1/E3 ground |
| operability | unchanged | R15-05 ratio unchanged |
| adjacency | unchanged | PROVINCE append keeps sibling boundaries; safety deviations are conformance defects, not absorbed ground |

## Discernment spot-check (LEARNING.md)

| item | decision | re-opened source | verdict | reason |
|---|---|---|---|---|
| S018 custom workflows are public beta, need Business OIDC connection, beta desktop app, JS SDK only | admit | https://www.1password.dev/brokered-access/custom-workflow/ (closure re-opened 2026-10-21) | agree | title "(public beta)", "Beta" callout, Step 1 beta app, Step 3 JS-SDK-only note all present |
| S017 GitHub Actions path is public preview with Business prerequisite | admit | https://www.1password.dev/brokered-access/github-actions/ | agree | title "(public preview)" + Business-connected-admin intro |
| S020/S021/S022/S023 announcement split, OpenBao TTL, Vault JWT 1.17 note, lease doc | admit | 1password.com blog; openbao.org/docs/concepts/tokens; developer.hashicorp.com vault jwt + lease | agree | located quotes verbatim, ≤25 words |
| "Credential Broker status is uniformly preview" | reject | both feature pages | agree | sibling pages carry different preview/beta labels |
| "OpenBao TTL only evidenced via Vault docs" / "no lease ⇒ never deleted" | reject | openbao tokens page; vault lease page | agree | OpenBao's own doc carries TTL; KV note makes no retention claim |

Agreement 5/5 admits sampled, 4/4 rejects (round 21: 0/2 admits). New row S017
(`corpus/SOURCES.md:23`, A/mined, opened 2026-10-20): its located quote lives in `round-22.md`
§Gate — the page title "Use 1Password Credential Broker to access secrets in GitHub Actions at
runtime (public preview)", 14 words, verbatim on the page re-opened 2026-10-21; the row's own
cell is a summary, not a quote (see D7).
`scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit0
`kagi ok …/corpus/SOURCES.md`, **plus five W04 lines** (`S019`–`S023 duplicate url … across scopes`).

## Round-21 debts

- E1/E3 admit disagreement → QA10/QM13/QM14 appended to `corpus/QUALITY.md` (22+/0−), each citing
  round-22 §Mistakes and the round-21 spot-check: **learned**.
- E1 erratum (Actions public preview vs custom-OIDC beta): active reading
  `corpus/knowledge/feature-bound-credential-review.md`; original bodies kept with history markers
  (`onepassword-machine-credentials.md` +56/−0, `vault-openbao-token-lease-lifecycle.md` +65/−0):
  **learned**, and confirmed against the live pages above.
- 9 deleted round-21 stamps lines / in-place ledger rewrites: `round21-migrations.json` holds 9
  `changed_stamp_records` whose `old` values equal the 9 `-` lines of `git show c41af82 --
  corpus/stamps.tsv` and `new` values are present at `e1544c194`; `removed_members: []`; LOG.md
  diff is 0 deleted lines: **justified append-only, no fictional restoration**.
- five stale stamps → six at BASE (the later LOG drift), all repaired: **learned**.

## Trend verdicts

- expansion — **improved**: one demonstrated capability row enters the repertoire; coverage held,
  no admitted entry failed its bar (the round-21 harm is not repeated).
- quality — **improved**: 6 stale pins repaired with provenance, superseded readings corrected by
  appended errata, fail-closed defects repaired, 31/31 authorized rows and 17/17 regressions green.
- discernment — **improved**: outside agreement on sampled admits moved 0/2 → 5/5 with rejects
  still 4/4, and the round-21 disagreement became QUALITY criteria.

## Safety / conformance (disclosed; status-neutral)

Verified against `review-evidence-quarantine*.json`, `build/Entry07.md` §8, `build/FixCellParser.md`,
`privacy-redactions.json`, `credential-sweep-final.json`, LOG and SCORECARD: the two unauthorized
legacy full-verify invocations (ReopenSource20 `revision` token, AttackActiveReview positional
selection incl. R18-01) are identified; AttackActiveReview's contradictory claims are withdrawn and
cited nowhere as verification; the positional guard sits at parse time in `claim-ledger.sh`
(4be5da3 :211–227); no blanket secret-access attestation is made; added-line sweep finds 0
`ops_`/`ghp_`/`hvs.`/private-key material and 11 `op://` literals, all pattern names in fixtures
or reports. Wave accounting: build 64 / falsify 66 per role mix as reported; 4 dead Haiku-429
scribes (`replacement_seats: 0`), 60 + 66 reports; no model parameter or planner swarm role.
Host record checked read-only: `~/.local/share/mise/installs/node/26.12.0` exists and global
`~/.config/mise/config.toml` carries one `node` entry, mtime 2026-10-20 18:33:38-03:00 (inside the
round). `/tmp/kagi-shokunin` still exists.

## Adjudication

**ADMITTED.** Both claims verify (C2 re-measured, C1 evidence-verified plus presence
re-measured); no axis harmed. The safety deviations are honest, disclosed conformance defects. The
round's own boundary bounds them and they leave no axis regression; they are routed, not used
to overturn admission. SHONEN boxes stay `[~]`; this closure now supplies box 3's outside check;
promotion remains operator-owned.

## Routed defects (lane owes next round)

- D1 Fleet report quotes only the `kagi ok` census line; it omits five W04 duplicate-URL-across-scopes
  warnings for S019–S023. Report warnings verbatim.
- D2 Install record omits that the mise side effect wrote global `~/.config/mise/config.toml`
  (node latest global). mise is outside the directive's channel list. Name the config write;
  revert is operator-owned (host/tsukuroi ground).
- D3 Two unauthorized full-verify runs left no receipts, so the privacy exposure is unbounded. Make
  every wave context name the forbidden paths. The new guard must reject the exact tokens
  (`revision`, positional ids) under a selftest case id.
- D4 Every stale-pin `disposition` is one boilerplate string. Cite the drift-causing commit per
  tuple (f4a8dd9, bad9088, 584dd67/c2cab35) in an appended journal.
- D5 `CriticNoTrade` names appear in both waves (fresh ID `-2`): 130 spawn IDs, 129 names. State it
  that way.
- D6 `final-verification.json` `.h1` = 8ada17a5, while the measured bytes are 4be5da3, which only
  the inputs-digest file binds. Record the measured commit in the verdict file itself
  (PROTOCOL §Gate standard, Two evidences).
- D7 S017–S023 lack the per-row quote/fetch-digest fields S001–S016 carry. Round-22 §Gate prose
  says "S017–S020 added", which is stale against its own table (S017–S021).
- D8 `/tmp/kagi-shokunin` scratch-collision residue remains; cleanup is operator-owned.
- D9 `claim-ledger.sh cells` (R13-03) stays skipped although the parser changed. Add a hermetic,
  host-free cells run over committed fixtures.
