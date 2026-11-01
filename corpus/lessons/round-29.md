source: S052, S045
verified-at: 2026-10-31 — RFC 4287 fetched by the L1 with the declared curl profile (HTTP 200, raw text), quote located once under raw-literal-v1; no vault/account/handler/CDP contact, nothing installed or provisioned
recheck: 90d — re-open RFC 4287 §4.2.14 and SemVer §2; re-run `.ufo/waves/round-29/tools/c1-measure.py`, `c2-measure.py` and the release-clock selftest after any change to `corpus/release-clock.py`

# Round 29 — feed-token right boundary; differential extractor agreement gate

Frozen BASE: `c49023b773b69de983f0e6eb7e5867ceb5c2c634`; plan + START census
committed alone in `66d1a2c`; plan corrections 1–2 committed alone in
`47a46d1` BEFORE any work commit (QM29); instruments, gate and BASE
before-receipts committed in `0229375` while `corpus/release-clock.py` still
held BASE bytes. The round executes on a NEW Windows host
(plans/round-29.md Correction 1). Stagnation nudge: all six axes at the
saturation line 9 and rounds 26–28 landed no capability, so the nudge fires
and the lowest-axis obligation is waived — C2 is the frontier/capability
move. Claims: C1 freshness (routed D1 closure, frozen round-28 recipe) and
C2 capability acquisition (`considerthese/2026-10-25.md` proposal 1).

## Gate — sources opened and decided this round

| Candidate | Decision and basis | URL, access date, located quote |
|---|---|---|
| S052 The Atom Syndication Format (RFC 4287) | ADMIT tier A spec, 180d: grounds the right-boundary half — an Atom entry title is a Text construct, so a trailing period is content and an extractor may not treat end-of-title as a token edge. | https://www.rfc-editor.org/rfc/rfc4287.txt ; 2026-10-31; "The "atom:title" element is a Text construct" (§4.2.14, raw text; located once, capture digest `3bd71d76…f2d89c`, 81922 bytes, `corpus/source-fetches.tsv`) |
| Re-opened S045 (SemVer 2.0.0 §2) | NO CHANGE: canonical-form teaching unchanged; cited by the new entry and by QM27 as before. | https://semver.org/spec/v2.0.0.html ; reopened 2026-10-31 via the round-28 capture; no new row (same URL, zero new information) |

**Existing registry cells (status/recheck/used-by), old → new:** S045
`used-by`: `corpus/lessons/round-28.md` → `corpus/lessons/round-28.md,
corpus/knowledge/feed-token-boundaries.md` (the new entry cites S045 for
canonical form; the census handshake requires the used-by back-reference;
SC_ENTRY_CITE fired once on first contact and is closed by this cell).
Sources 51 → 52 (one tier A, mined, used-by the new knowledge entry).
START census exit 0 (14 W04, `.ufo/waves/round-29/census-start.txt`,
committed pre-move; re-run on this host exit 0 — same 14 W04 + ok).

## C1 — feed-token right boundary (freshness; routed D1 closure)

Applied the frozen round-28 recipe verbatim
(`corpus/lessons/round-28.md` §Attempt-3 corrigenda 1): the three feed
extractors take the `STABLE_TOKEN_RE` right boundary
`(?![A-Za-z0-9+-]|\.[0-9])` instead of `$`/`[ \t]*$`, plus the recipe's one
positive and one negative selftest case on the feed path. Grounded by S052
(a title's trailing period is content). BASE behavior re-verified on this
host by direct probe (`.ufo/waves/round-29/final/base-probes.txt`: P1/P4
return the OLDER canonical token; P2/P3 report the wrong typed error; P5
control fine), then measured by the frozen instrument
(`.ufo/waves/round-29/tools/c1-measure.py`): NF fixtures MISHANDLED 5/7 →
see the measured outcome below; round-28 counter replay F1–F4 (verbatim
construction, re-hosted child interpreter) stays green; default control
CLEAN. The selftest case count grows 114 → 116, only by the recipe's two
cases (Correction 1 additionally POSIX-scopes the pre-existing receipt-mode
case — see Mistakes).

## C2 — capability: differential feed-token agreement gate

`corpus/feed-token-agree.py` (grounds `considerthese/2026-10-25.md`
proposal 1): imports the live extractors AND the shared token grammar from
`corpus/release-clock.py` (reference, never copy), runs a fixed shape
corpus (trailing period, comma-prose, close-paren, leading zeros, 19-digit
component, prerelease, build metadata, four-component, v-prefix,
two-component, series-x, plain) through all three extractors in their
natural wrappers, and fails naming shape + extractor when any extractor's
extracted-vs-refused decision or token deviates from the grammar's
adjudication. `--selftest` proves the checker on synthetic extractors
(seeded `$`-anchored divergence caught; refusal-side leak caught;
wrong-token extraction caught) and never imports the live file, so it stays
green on a red tree — demonstrated: the gate's selftest passed at the
pre-fix commit while its live run read DISAGREE (receipt
`c2-base-gate.json`, m1=1 m2=1 m3=0 m4=1). The capability row enters the
SCORECARD capabilities table on the measured after-state.

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M29-1 | stale-premise (host) | `python -I -B corpus/release-clock.py --selftest` → `FAIL receipt mode or fields` exit 1 on the round-29 Windows host at BASE `c49023b` AND at the START tip (committed probe `.ufo/waves/round-29/final/base-selftest-host.txt`): the case asserts POSIX `0o600` on an NTFS file (no POSIX mode bits) | none (QM2 carries the command+host, but no criterion covered a host-property assertion inside a selftest) | plans/round-29.md Correction 1: the mode assertion is POSIX-scoped (declared limit in the case comment, lesson §Limits, PROVINCE bullet); the fields half is universal; on POSIX hosts the case is byte-identical to BASE. Red-before = the committed BASE FAIL line; after = `PASS (116 cases)` exit 0 with an explicit SKIP line on nt |
| M29-2 | provider (host environment) | `python3` on this host is the Microsoft Store stub (exit 49) — the frozen commands' interpreter token and every hardcoded `python3` child spawn break; separately, `git archive` of every relevant revision carries `…/CritCounting/{BASE,base}` whose names collide on NTFS, so a full `tarfile.extractall` fails (the frozen round-28 c1-measure tool is unrunnable here for both reasons) | none | plans/round-29.md Corrections 1–2 (committed before any work commit): the round-29 instruments spawn children with `sys.executable` and export a declared sparse projection (`corpus/**` + the one default-receipt path), aborting loudly on any case-colliding pair inside the projection; Correction 1 also re-hosts the round-28 counter replay (fixtures/predicates verbatim) so it runs here |
| M29-3 | landing | `claim-ledger.sh verify` (>300 s) and `corpus/self-counts.py` (>240 s) do not complete on this host (per-row process-spawn cost; partial output recorded with FAILs R11-05/R11-07 from the already-broken drift/transcript selftests), so a full green verify receipt is unmeasurable here | QM12 (anticipates exactly this substitution) | QM12 substitute executed: every touched/added ledger row re-run individually against the commit tree (exit + last line recorded below and in LOG.md), stamps refreshed through the ledger's own `stamp` command, new self-counts bindings verified individually (12/12, 4/4, 116); the round-28 Linux-host full-verify receipt remains the record for the ledger-wide CLEAN claim |

## Limits

- C2 adjudicates EXTRACTION agreement only — it never orders versions,
  decides canonicality, resolves references or fetches; a forger who edits
  the grammar and the extractors together still passes (the same
  consistency-not-tamper limit as round-28 C2/QM28).
- The dropped `$` anchor widens acceptance on prose-suffixed lines (a text
  line `Version: 8.23.0 is out` now yields `8.23.0`); declared in
  `knowledge/feed-token-boundaries.md` §Bounds 3, judged downstream by the
  unchanged canonicality/ordering rules.
- The Windows selftest prints one explicit SKIP line (receipt-mode `0o600`
  is a POSIX-only property); the case still counts (116), the verdict-line
  shape pinned by R25-03 is unchanged, and a POSIX host runs the original
  assertion.
- Real feeds observed so far carry no period-suffixed stable tokens; the
  boundary move is proven on synthetic feeds and declares no current-vendor
  drift.
- The measured after-receipts and the frozen command exits are appended in
  the measured-outcome block below once the measured revision lands; no
  unrun result is stated in this lesson.

## Measured outcome (appended; measured revision `fc6511263a233f3db018fd7355568f4cf239727f`)

Frozen commands run with the Correction-1 host interpreter (`python -I -B`);
receipts in `.ufo/waves/round-29/final/`:

    python -I -B .ufo/waves/round-29/tools/c1-measure.py <rev> <label> <out.json>
    python -I -B .ufo/waves/round-29/tools/c2-measure.py <rev> <label> <out.json>

- C1 before (`c49023b`, `c1-before.json`, exit 1): NF MISHANDLED 5/7,
  CORRECT 2/7 (NF1–NF5 mishandled: silent drop to the older canonical
  token, invisible canonical release, wrong-typed text error; NF6/NF7
  refused-controls correct), replay F1–F4 MISHANDLED 0/4 TYPED 4/4,
  control CLEAN exit 0.
- C1 after (`fc65112`, `c1-after.json`, exit 0): NF MISHANDLED **0/7**,
  CORRECT **7/7**; replay MISHANDLED **0/4**, TYPED **4/4**; control CLEAN
  exit 0. Separability: the gate file existed with BASE instrument bytes at
  `0229375` and C1 still measured red there (`c1-before.json` is rev-pinned
  to `c49023b`), so C1 does not rest on C2.
- C2 before: at `c49023b` (`c2-base-plain.json`) m1=0 m2=0 m3=0 m4=0 (no
  artifact); at `0229375` with the gate present and BASE instrument bytes
  (`c2-base-gate.json`) m1=1 m2=1 **m3=0** (live DISAGREE, 9 findings over
  trailing-period/comma-prose/close-paren × 3 extractors) **m4=1**.
- C2 after (`fc65112`, `c2-after.json`, exit 0): **m1=1 m2=1 m3=1 m4=1** —
  gate present and runnable, selftest PASS (4 cases, seeded divergence
  caught), live `FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)`, and
  the red witness: the gate vs the BASE instrument exits 1 DISAGREE naming
  `shape=trailing-period`.
- Regression battery at `fc65112`: release-clock `--selftest` ⇒
  `PASS (116 cases)` exit 0 (one explicit SKIP line on nt, M29-1's declared
  limit; count grew only by the recipe's two cases); default ⇒
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30
  fired=3 derived=15)` exit 0 (R25-04 unchanged); checklist-run selftest
  PASS 34; op-ref-probe selftest PASS 36; lane census ⇒ CLEAN
  (rows=52 A=50 mined=48 captures=52 entries_sourced=5) exit 0 — one
  SC_ENTRY_CITE finding on first contact (S045 used-by back-reference,
  logged above) closed in place.
- Touched/added ledger rows re-run individually (QM12 substitute,
  M29-3): R25-03 substitute exit 0 `PASS (116 cases)` (regex migrated
  114→116 with the old value and reason in the row note); R25-04 exit 0
  CLEAN30; R29-01 exit 0 `PASS (4 cases)`; R29-02 exit 0 `AGREE (shapes=12
  disagreements=0)`. Full `claim-ledger.sh verify` and `self-counts.py`
  remain unmeasurable in time on this host (>300 s/>240 s, M29-3); the
  round-28 Linux-host full-verify receipt stands for the ledger-wide claim.
- New self-counts bindings verified individually: PV-FEEDTOKEN-SHAPES
  doc 12 == R29-02 capture 12; PV-FEEDTOKEN-SELFTEST doc 4 == R29-01
  capture 4; PV-CLOCK-SELFTEST/SC-CLOCK-SELFTEST read R25-03 → 116, held
  by the direct selftest run.
- Stamps: 91 → 94 paths (membership + the three new artifacts), refreshed
  through the ledger's `stamp` command (LC_ALL=C) and verified 94/94
  against the working tree bytes.

Outside admit/reject judgment stays with the operator/closure judge; the
L1's verdicts end here.
