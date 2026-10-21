source: S001, S002, S003, S004, S005, S006, S007, S008, S009, S010, S011, S012, S013, S014, S015, S016, S027, S028, S029, S031
  S032 (round-24 recovery exact-quote correction; located quote in the recovery Gate)
verified-at: 2026-10-21 (public documentation pages reopened over HTTPS with the declared profile; no account, vault, or handler probe)
recheck: on-release — reopen the Python `re`/`html` docs, the curl man page and the WHATWG standards when a version route changes; recapture S001-S016 when their docs version routes change.

# Round 24 — host-safe ledger entry points, legacy pins classified under one normalizer, membership-bound count rows

Frozen starting revision: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (round-23
non-author spot-check, MANIFEST rounds[379]). Claims are frozen in
`plans/round-24.md`: C1 operability (safe-by-default `verify`/`cells`, routed
D4 plus the audit's R11-08 red, single-backslash guard and SKIP-SELF/rows_run
debts), C2 freshness (S001-S016 recaptured and classified under the single
declared normalizer, routed D5/D6), C3 calibration (membership identity for
the fifteen count-only rows). The L1 holds the frozen planner seat. No vault or
account action, no credential read, no host-private gate on the real tree.

## Plan corrections (named, append-only)

- **R24-C1** — `plans/round-23.md:13` says the closure gate resolves pointers
  "in the commit tree". It resolves each `fixed` pointer as a filesystem path
  under `--root` (default `.`), i.e. the working tree, and never invokes git
  (`corpus/closure-dispositions.py:111-113`, `:378`).
- **R24-C2** — `plans/round-23.md:9-10` ("Consume the non-author closure's
  decisions") and `corpus/closure-dispositions.py:2`: the gate consumes the
  closure's obligation ids (`D1`-`D9`, `SPOT-NN`, `ADJ`), not its verdicts
  (`corpus/closure-dispositions.py:41-43`).
- **R24-C3** — the round-23 fleet report's sentence that other parent-built
  reports "remain parent-owned and uncommitted" was true at fleet commit
  `00cfe25d` and is stale since lane commit `46fac5a` committed all 67.
- **R24-C4** — `plans/round-24.md` §C2 inherited the round-23 spot-check's
  reading that S008 is non-reproducing ("6 (S008, S012–S016)"). S008's in-row
  pin reproduces the raw body (also stated in `corpus/lessons/round-23.md`).
  The correct before value: the round-23 lesson named 5 of the 12
  non-reproducing pins (S012-S016) and correctly named S008 as reproducing;
  S001-S007 were silent. The C2 metric is unchanged (16 → 0 rows whose only
  provenance is a historical pin).

## Gate — sources opened and decided this round

New rows (each opened by the L1 on 2026-10-21 with
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`,
quote located with `python3 corpus/rendered-text-v1.py locate`, count 1 each;
the wave-1 Src seats opened the same pages independently):

| id | URL | quote (≤25 words) and location | decision |
|---|---|---|---|
| S027 | https://docs.python.org/3/library/re.html | “For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ).” (`\s` entry) | admit (mined): grounds v1's whitespace class |
| S028 | https://docs.python.org/3/library/html.html | “Convert all named and numeric character references (e.g. &gt; , &#62; , &#x3e; ) in the string s to the corresponding Unicode characters.” (`html.unescape`) | admit (mined): grounds the entity step |
| S029 | https://curl.se/docs/manpage.html | “(HTTP) Request a compressed response using one of the algorithms curl supports, and automatically decompress the content.” (`--compressed`) | admit (mined): grounds decoded-http-body-v1 |
| S030 | https://infra.spec.whatwg.org/ | “ASCII whitespace is U+0009 TAB, U+000A LF, U+000C FF, U+000D CR, or U+0020 SPACE.” (§4.6 Code points) | **reject**: an ASCII-only collapse reproduces only 7 of 10 round-23 normalized digests (S022, S023, S024 differ); flip: a declared v2 that re-captures every row |
| S031 | https://html.spec.whatwg.org/multipage/syntax.html | “The text is allowed to end with the string " <! ", as in <!--My favorite operators are > and <!--> .” (§13.1.6 Comments) | admit (mined): comment data may contain `>`, so v1's tag-only comment rule is a declared leak bound |

Other decisions recorded explicitly (QM17):

- **reject** the looser script/style opener `<(script|style)\b.*?</\1\s*>`
  that the first round-24 draft used: wave-1 CritC2Metric showed it disagrees
  with the round-23 generator on a malformed opener
  (`L<script broken</script>secret</script>R`); v1 adopts the round-23
  generator's exact opener `\b[^>]*>` and the case is in the selftest.
- **reject** reclassifying R21-01 (`op-ref-probe.sh --dotenv-bytes`) as a host
  row (wave-1 HostOpRefProbe, HostSurfaceCensus): it executes the installed
  `op` binary but under `env -i` with scratch HOME/XDG and no account, ref or
  handler; it reads no host-private path. Recorded as a bound in SKILL.md.
- **reject** reclassifying `claim-ledger.sh citations` (R11-08) as a host row
  (wave-1 HostClaimLedger): it reads lane docs and stats sibling/fleet paths
  for existence only; no content outside the lane is read.
- **reject** committing the captured page bodies as a conformance fixture
  (CritC2Metric's suggestion): 1.2 MB vendor pages are not lane material; the
  replay of all ten round-23 normalized digests on fresh bodies is wave
  evidence instead (`.ufo/waves/round-24/normalizer-replay.json`).
- **demote, not delete**: the sixteen historical in-row pins stay in their
  registry rows; 12 are classified non-reproducing in `corpus/inrow-pins.tsv`.

Recaptures (no registry cell changed; status/recheck/used-by old→new: none):

| id | verdict vs same-day capture | capture quote located | note |
|---|---|---|---|
| S001 | non-reproducing | rendered, count 1 | |
| S002 | non-reproducing | raw-literal (img alt text) | the registry quote is the diagram's alt attribute, absent from rendered text |
| S003 | non-reproducing | rendered, count 1 | |
| S004 | non-reproducing | rendered, count 1 | |
| S005 | non-reproducing | rendered, count 1 | |
| S006 | non-reproducing | rendered, count 1 | seat RecapS006: Actions preview vs custom-OIDC beta split (already S020) |
| S007 | non-reproducing | rendered, count 1 | seat RecapS007: one registry quote is lowercase; live text starts “The” |
| S008 | reproduces-raw | raw-literal, README at getsops/sops `453e7e6ab01b1340dca9f9025fd8430229320f97` | rejected row stays rejected |
| S009 | reproduces-raw | rendered (backticks rendered as code) | |
| S010 | reproduces-raw | rendered, count 1 | |
| S011 | reproduces-raw | rendered (backticks rendered as code) | |
| S012 | non-reproducing | rendered, count 1 | seat RecapS012: JWT-role scope holds; OIDC part is S022's correction |
| S013 | non-reproducing | rendered, count 1 | |
| S014 | non-reproducing | rendered (lowercase form) | superseded by S025 |
| S015 | non-reproducing | rendered (code span rendered plain) | |
| S016 | non-reproducing | rendered, count 1 | superseded by S026 |

## Routed defect dispositions (round-23 spot-check D1-D8 and the 66-seat audit)

- **D1 fixed** — `SCORECARD.md` §Capabilities main table gains the closure
  disposition review row; the trailing prose names round 23 as the latest.
- **D2 fixed** — `SKILL.md` §Gate registry — round-23/24 contracts adds the
  closure disposition review row, the normalizer, the row identity reader and
  the census row with `corpus/source-fetches.tsv` and `corpus/inrow-pins.tsv`
  in its pinned values.
- **D3 fixed** — ledger row R24-02 runs `closure-dispositions.py --selftest`
  (14 cases); `.ufo/waves/round-24/final-verification.json` records
  `measured_commit` as the final code commit and every run names the revision
  it measured.
- **D4 fixed** — C1 (`corpus/claim-ledger.sh`): `[host]` tag on R18-01,
  default HOST-SKIP for `[host]`/`[substrate]`, consent only by
  `--allow-host-rows`, POLICY `untagged-host`, `host-path` (`~`, absolute,
  `..`), `bash-option`, `script-symlink`; selftest cases name each.
- **D5 fixed** — C2: every in-row pin classified against a same-day capture
  (`corpus/inrow-pins.tsv`, census SC_INROW recomputes the verdict); the
  in-row-only exemption is restricted to S001-S016; the CLEAN line carries
  `captures= inrow= inrow_only= inrow_nonreproducing=`. All 12 non-reproducing
  pins are named (S001-S007, S012-S016).
- **D6 fixed** — `corpus/rendered-text-v1.py` is the one declaration; the TSV
  header and the census comment cite it instead of restating it.
- **D7 process** — every wave artifact (specs, dispatch, registries, every seat
  report, tools, evidence JSON) is committed through the lane helper before the
  fleet report is written; the report cites that landed hash.
- **D8 fixed** — this Gate records rejects and the demotion explicitly
  (QM17); R24-C1/R24-C2 correct the round-23 plan wording.
- **Audit R11-08** — fixed in the gate: quote/comma-joined lists split and
  `.ufo/` resolves lane-first (`citations` unresolved 2 → 0).
- **Audit count rows** — C3 (below).
- **Audit single-backslash guard** — fixed (`*\\*`); R18-02 rewritten to a
  bracket class, the only row that used a backslash.
- **Audit SKIP-SELF / rows_run** — fixed: only a `bash corpus/claim-ledger.sh`
  invocation is self; `rows_run` counts executed rows only.

## C3 identity contract

`corpus/row-identity.sh <selector>` prints `count=N sha256=<64hex>` over the
membership each population row's note claims (table in the script header).
R24-03..R24-16 pin both numbers; the old count rows stay. Calibration framing
(QM13): the decisions are the ledger's admissions of fifteen count-preserving
identity swaps — one per population row, each expected to be REFUSED because
the row's own note claims that membership — plus fifteen pristine controls
expected to be ADMITTED. Wave-1 Ident seats constructed their own independent
swaps (`.ufo/waves/round-24/build/Ident*.md`); wave 2 re-applies them to the
candidate. A legitimate membership change is now an explicit, migrated
expectation (QM14), which is the intended cost.

## Mistakes

| id | class | evidence | captured-by | fix |
|---|---|---|---|---|
| M24-1 | a reading inherited without re-measurement | `plans/round-24.md` §C2 copied the spot-check's "S008 non-reproducing"; S008 reproduces raw (`.ufo/waves/round-24/build/RecapS008.md`) | none at plan time; QM16 now (the verdict is recomputed by SC_INROW, case `inrow-verdict-lie`) | R24-C4; census refuses a classification the capture contradicts — shown failing first by selftest case `inrow-verdict-lie` |
| M24-2 | a safety comment promising more than the code | `corpus/claim-ledger.sh` comment promised `g\it` refusal since round 11; the guard `*'\\'*` matched only two backslashes (`.ufo/waves/round-24/build/ProbeBackslash.md`, `RevBackslashHistory.md`) | none (the round-11 case `policy-split-verb` never fed one backslash) | guard `*\\*` + case `policy-single-backslash`, which fails on the old guard |
| M24-3 | a count standing in for a membership | 15/15 count-preserving swaps survived at BASE (`.ufo/waves/round-24/tools/identity-swap.py`) | none; QM18 now | R24-03..R24-16; the same harness must report 0/15 after |
| M24-4 | round-start census not run at round start | the start-of-round fleet census was reproduced on a BASE clone after implementation began (`.ufo/waves/round-24/census-start.txt`) | the prompt's §2b step 2 | reproduced on an exact BASE clone with the same command; future rounds run it before the first edit |
| M24-5 | the first draft normalizer diverged from the generator it declares | CritC2Metric's malformed-opener counterexample | none until wave 1 | adopt the round-23 opener; case `script-malformed-opener` fails on the draft regex |
| M24-6 | comment updated, code not | the candidate `a3eb6c75` widened the python allowlist COMMENT for `rendered-text-v1.py` but not `PYTHON_SCRIPT_RE`, so R24-01 was POLICY-refused; the identity harness's pristine control caught it (`.ufo/waves/round-24/identity-after-a3eb6c75.txt`, every control `INVALID-CONTROL` on R24-01) | the harness control (QM3: a failing control invalidates the run) | regex fixed; re-measured on the fix commit |
| M24-7 | a note spelling a semantic tag | R24-13's first note contained the bracketed substrate tag, so the gate treated it as a host row and R18-02 counted 12 (final real-tree verify at `ce9c544d`: `FAIL R18-02 reason=verdict-not-final`, `host_skipped=13`) | the real-tree `verify`, runnable for the first time because of C1 | note reworded; re-verified on the final commit |

Seat safety deviations (disclosed, not credited): IdentR1111 edited the live
lane's `corpus/surface-census.tsv` once (wrong relative path), restored it from
BASE, and admitted it when asked; the stamp taken during that window was wrong
and was re-taken at `ce9c544d`. IdentR1604 ran a default `verify` in its BASE
scratch clone without an isolated HOME (at BASE that reaches R18-01's
host-path reads); no values were copied. ProbeAbsPath died at spawn (Codex
`turn_rate_limit_exceeded`), never replaced.

## Measured outcome (final commit in `.ufo/waves/round-24/final-verification.json`)

- C1: `host-tripwire.sh` BASE `total=35` → `735123d5` `total=0 complete=4/4`,
  every verify run `population_skipped=12/12`; `citations` `unresolved=2` → 0;
  ledger selftest 121 → 140 cases.
- C2: rows whose only provenance is a historical in-row pin 16 → 0; census
  `captures=31 inrow=16 inrow_only=0 inrow_nonreproducing=12`; non-reproducing
  pins named 5 → 12; normalizer declarations 3 → 1 (20-case selftest; 10/10
  round-23 normalized digests reproduced).
- C3: `identity-swap.py` BASE `survived=15` → `ce9c544d` `survived=0
  killed=12 invalid=3`; the three invalid rows (R13-02, R18-02, R21-04) are
  the claim-ledger mutants whose pristine control failed on M24-7, re-measured
  on the final commit.

## Recovery — inherited work and fresh falsification

This writer resumed the SAME round/attempt at
`c5ef9e92201b6c36396301f12b23740565bf86a0`. The filed report and all
committed code/data/build reports were inherited, not newly authored.
Seven claimed code/data files were byte-identical to the inherited measured
revision and all 83 stamp tuples matched immutable Git bytes
(`.ufo/waves/round-24/recovery-inheritance.json`). No inherited production
work was discarded. The missing second wave was dispatched fresh, after
eight atomic job-cap refusals spaced 180 seconds apart; refusal is not a
started or dead seat. Its registry is
`.ufo/waves/round-24/falsify/swarm-registry.json`.

### Gate — correction and rejected readings

- **S032 admitted/mined:** public guide
  https://www.1password.dev/brokered-access, opened 2026-10-21, location
  Add an integration → GitHub Actions / Custom Workflow (OIDC), quote:
  “The token value is your integration key” (8 words). The declared-profile
  capture returned HTTP 200; the case-sensitive locator returned count 2.
  This supersedes ONLY S007's lowercase quote; S019's release-status
  correction remains active. S001–S031 status/recheck/used-by changes:
  **none**. New capture and exact exits:
  `.ufo/waves/round-24/recovery-source-S032.json`.
- **Reject** the original lowercase S007 excerpt as an exact quote:
  the same locator returned exit 1/count 0. This is a repaired quote defect,
  not evidence of changed mechanism or a false historical capture.
- **Reject** build RecapS002's inference that a normalized miss disproves
  its raw image-alt quote, and RecapS012's query retaining Markdown
  backticks as evidence the rendered quote is absent. Fresh reports
  `FRecapS002.md` and `FRecapS012.md` under the falsify directory locate
  the source support in the correct representation. The inherited lesson's
  raw-literal and rendered-text distinctions were correct.
- **Reject** the broad reading that all of a row's behavioral semantics are
  bound by C3. Its actual projections are those in `plans/round-24.md` R24-C6. In
  particular R22-04 changes a case label, not its assertion body. No
  semantic-equivalence or asset/runtime-partition capability is claimed.
- **Reject** the old instrument's inference that no printed FAIL means a
  clean control. Several fresh subset invocations exited 1 on unrelated
  unresolved IDs. The new instrument supplies selected-ID-only docs and
  requires exit/terminal-summary/claim-count/failure-count/skip agreement;
  the legacy gate emits no per-row PASS, so that is not fabricated.
- **Reject** the normalizer's “same element” prose as an HTML guarantee:
  its prefix regex can swallow a malformed hyphenated opener, and an
  attribute-bearing closer may leave body text. The regex is retained
  unchanged; explicit bounds and two fixed expected-byte cases record
  what v1 actually does (`FNormElements.md`).
- **Bound, not a source correction:** S005/S006 build-seat raw hashes and
  the L1 capture rows came from independently volatile requests. Their
  request identity is unproven; equal normalized digests do not establish
  one request. No original capture falsity is inferred.
- **Bound, not host authorization:** citations stats sibling/fleet paths
  for existence as already documented; it is not an arbitrary outside-root
  content-read guarantee. New/copied wrapper scripts remain trusted,
  reviewed code, not a sandboxed hostile-program surface.

### Mistakes — fresh falsifiers retained

| id | class | evidence | captured-by | fix |
|---|---|---|---|---|
| M24-8 | scope | fresh `FPolicyPath.md` and `FPolicyUntagged.md` show lexical checks losing to expansion, attached file options, ancestor aliases and a prefix-only fixture exception | QM15; literal-only tests missed the variants | script invocations reject expansion, attached pattern-file operands receive path checks, every script component is checked for symlinks, and fixture invocation arguments are closed |
| M24-9 | vacuous | `FPolicyRowsRun.md` and `FPolicySkipSelf.md`: policy-invalid, host-tagged or nonexistent self scripts became CLEAN self-skips | QM3/QM15 | policy/host classification precedes recursion skips; missing self script is refused; eleven isolated regression/control cases added |
| M24-10 | survivor | fresh identity reviews show nonzero pristine processes; old instrument inspected only FAIL/POLICY text | QM3/QM13 | isolate selected docs and validate whole receipts; synthetic receipt selftest includes timeout, empty, truncation, short count and inconsistent failure controls |
| M24-11 | reference-drift | `FRecapS007.md`: lowercase quote locates zero times | QA6/QM16 | append S032 with the opened exact excerpt; preserve S007 historical cells |
| M24-12 | scope | `FNormElements.md`: a regex prefix is described as an element-name match | QA3/QM16 | keep v1 bytes unchanged, correct the prose and pin the two malformed-input outputs |
| M24-13 | provider | dead fresh seats and both repair executors exhausted Codex capacity retries | none | retain identities/errors, do not replace seats; L1 integrates the reachable narrow repairs |

The original fleet report's absent-wave statement and late-seat text are
filed history, not silently rewritten. Recovery evidence precedes its
append-only report erratum. This wave is author-side falsification, not
independent admission or a SHONEN promotion review.

Recovery correction M24-14 (reference-drift; captured-by QA1): the first
committed S032 `used-by` path cited the row in the lesson body but omitted
it from the first `source:` field. The actual census at
`277a0d4f1d9bc6c5cea9b1d0ab92e33e5c17bb56` refused it with
`SC_USEDBY_NOCITE`; the full ledger therefore failed R21-02 and no other
claim row (`.ufo/waves/round-24/recovery-checks.json`). The original source
line is preserved and a whitespace-led provenance continuation adds S032.
The failed receipt remains evidence; it is not booked as CLEAN.

### Measured recovery outcome

At `017cc4c5eb87f7942fa41ff8893e8737fd14cfb4`, the fixed source handshake
and safe full ledger both exit0. Actual outputs are in
`.ufo/waves/round-24/recovery-checks.json`: claims61, stamped83,
host_skipped12; source rows32, captures32, inrow16, inrow_only0,
inrow_nonreproducing12. The first failed candidate is retained.

The paired gate regression ran identical151-case fixture suffixes on the
inherited versus repaired logic: old exit1, repaired exit0. The receipt
parser selftest passes12 cases. Fresh C1 tripwire runs show35 → 0 population
executions and12/12 HOST-SKIPs in all four after cases. Their stub-induced
FAIL/BROKEN outcomes are not promoted to CLEAN.

The repaired C3 instrument remeasured the SAME fifteen projected-identity
trials: BASE survivors15/kills0/invalid0; measured survivors0/kills15/invalid0,
every pristine process exit0 and each after mutant exit1. The original
weaker control inference is superseded. This does not bind assertion bodies
or prove vendor/host currentness. Repro commands and receipt paths are in
the recovery SCORECARD append and `recovery-final.json`.

Fleet source census recovery-start and recovery-end both exit0; end adds
the expected S032 duplicate-URL warning. The original late start census
(M24-4) remains a timing defect, not retroactively repaired. No old source
status/recheck/used-by cell changed. No outside spot-check or promotion was
self-certified.

The causal-separation experiments also completed: the recorder
`python3 .ufo/waves/round-24/tools/claim-separability.py` ran c1-only,
c2-only and c3-only over BASE plus committed digest-pinned inputs
(`e6210511a25ddd98ce54be346367f991ce9ff3ed`). All three processes exit0.
C1 alone has host executions0/complete4/4; C2 alone has CLEAN32 captures
and inrow_only0; C3 alone kills all15 unchanged projected-identity trials,
survivors0/invalid0, with clean controls. Its only new executable is the
row reader: the old gate and old source artifacts remain BASE bytes.
Baseline-adapted bookkeeping (80 pins /59 rows) is explicit in the
committed C3-only snapshot. Full records and every input digest live in
`.ufo/waves/round-24/separability`; no absent-phase result is inferred.

The S030 rejection's quantitative basis was freshly remeasured rather than
left at the scoped review's UNKNOWN: `python3 .ufo/waves/round-24/tools/normalizer-replay.py .ufo/waves/round-24/recovery-normalizer-replay.json`
at `31c8421407ec2c1776d52c49be85c2d4f0d40167` returns exit0, rows10,
v1_matches10, ascii_matches7. Only step 5's collapse class changes for the
alternative; trim remains v1. All requests and raw/normalized digests are
in the committed receipt, which does not preserve the public page bodies
or certify future byte stability.
