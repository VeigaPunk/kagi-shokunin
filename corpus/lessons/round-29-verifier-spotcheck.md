author: hyaku closure (non-author integrator, zcode subagent (fresh session, non-author))

# Round 29 verifier spot-check — kagi (closure judge, non-author)

Closed against lane HEAD `49d1d46e69bf83283a1b001ec4eff16000d6508e` (branch `master`,
pushed). Pre-round HEAD `66d1a2cc0d06f6f91a19d0c9575f47d21523f29c`; measurement BASE
`c49023b773b69de983f0e6eb7e5867ceb5c2c634`. All commands below were run by this
session (Windows 10.0.26200 x64, Git Bash, `python` 3.13.15, `-I -B` per plan
Correction 1); index-free git only. No lane-authored file was edited.

## Step-1 conformance — all pass

| Check | Result | Evidence (command → observed) |
|---|---|---|
| Report committed by lane identity | PASS | `git -C <fleet> log --format='%an %ae %H' -1 -- .ufo/reports/round-29/kagi.md` → `kagi-shokunin kagi@shokunin.local 5f9a4d9e4e40c98fc6daa22fd12200c9c599c939` |
| `SHONEN` heading present | PASS | report carries `## SHONEN` with one `[~]` line per box (4 boxes), no `[x]` written by the lane (correct — only a non-author may write `[x]`) |
| Cited lane commits exist + are ancestors | PASS | `git cat-file -e <h>^{commit}` + `merge-base --is-ancestor <h> refs/heads/master` for 66d1a2c, 47a46d1, 0229375, fc65112, bc2f3fd, 49d1d46, c49023b → all OK |
| Branch tip pushed | PASS | `git ls-remote origin refs/heads/master` → `49d1d46e69bf…` == local `refs/heads/master` |
| Round work reachable 66d1a2c..49d1d46 | PASS | all cited commits in range; `git diff-tree -r --stat` lists exactly the reported files |
| Not a marker report | PASS | full substance (work, evidence pointers, LOG-tied landed changes, counting commands, SHONEN) |

Conformance defects found are listed under **Routed defects** below; per the
contract they are status-neutral and do not bar admission.

## Lane hard rules — all held

1. **2026-10-21 refused work not retried/rephrased/rerouted.** Grepped the
   round's added bytes (`git diff-tree -r -p 66d1a2c..49d1d46`), the fleet
   report, `corpus/lessons/round-29.md`, `LOG.md` and all five round-29 commit
   subjects/bodies for the refused scope's phrasing (total feed-token
   validation / token totality / punctuation-aware derivation): zero hits. The
   report's one compliance sentence names the refusal without summarizing its
   content. C2 is grounded in `considerthese/2026-10-25.md` proposal 1
   (operator-authored, post-refusal) and claims extraction AGREEMENT on a fixed
   12-shape corpus — the lesson and knowledge entry explicitly decline token
   totality. **HELD.**
2. **C1 applied only via the frozen round-28 recipe** (`corpus/lessons/round-28.md`
   §Attempt-3 corrigenda 1 at base). `git diff-tree -r -p … -- corpus/release-clock.py`
   contains exactly: (a) the three feed extractors `STABLE_TITLE_RE`,
   `STABLE_TAG_HREF_RE`, `TEXT_VERSION_RE` taking the right boundary
   `(?![A-Za-z0-9+-]|\.[0-9])` — byte-identical to `STABLE_TOKEN_RE`'s boundary
   at `:345`, which itself is UNTOUCHED at both revisions; (b) exactly two new
   feed-path selftest cases, one positive (canonical `Python 3.15.1.` observed)
   and one negative (non-canonical `Python 3.15.01.` typed `NON-CANONICAL`);
   (c) the pre-existing receipt-mode case POSIX-scoped, authorized by
   `plans/round-29.md` Correction 1 (committed alone in `47a46d1` before any
   work commit). Selftest count 114 → 116 confirmed by run. **HELD.**
3. **No vault contact.** `.ufo/waves/round-29/final/substrate-absence.txt`
   records the handler and both the-janitor dirs ABSENT (ls exit 2 ×3) and the
   WinGet `op` 2.39.0 present and untouched ("no sign-in, no vault/account
   contact, nothing installed or provisioned"). Every install/sign-in/
   provision/pin mention in the round's added lines is a negative claim
   (nothing done); PROVINCE carries the dated round-29 host erratum; no `op://`
   reference and no secret value appears in any added line (shapes and paths
   only). **HELD.**

## Claim re-checks — both re-measured by this session

### C1 — feed extractor boundary fix (freshness): RE-MEASURED, verifies

Commands (frozen instruments at tip, run from the lane repo; instruments were
introduced at `0229375` and never changed after — `git log` shows one commit
each; working-tree blobs byte-equal the tip blobs via `git hash-object`):

    python -I -B .ufo/waves/round-29/tools/c1-measure.py c49023b773b69de983f0e6eb7e5867ceb5c2c634 verify-before <out>
      → C1_MEASURE verify-before: NF mishandled=5/7 correct=2/7 other=0/7 replay mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True   (exit 1)
    python -I -B .ufo/waves/round-29/tools/c1-measure.py 49d1d46e69bf83283a1b001ec4eff16000d6508e verify-after <out>
      → C1_MEASURE verify-after: NF mishandled=0/7 correct=7/7 other=0/7 replay mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True   (exit 0)

Matches the report exactly (5/7 → 0/7 mishandled; 2/7 → 7/7 correct; round-28
replay green at both; CLEAN30 control at both — control last line at both
revisions: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30
fired=3 derived=15)`). Committed receipts (`final/c1-before.json` rev-pinned to
BASE, `final/c1-after.json` to `fc65112`) agree with the re-runs; the tip
differs from the measured revision only by the S045 used-by cell, which no
fixture reads (confirmed empirically by identical re-run at tip). Do-nothing
control fails the after-target by construction (before receipt predates any
candidate commit). **Verdict: improved.**

### C2 — feed-token-agree.py capability: RE-MEASURED, verifies

    python -I -B .ufo/waves/round-29/tools/c2-measure.py c49023b… verify-base-plain <out>
      → C2_MEASURE verify-base-plain: m1=0 m2=0 m3=0 m4=0   (exit 1)
    python -I -B .ufo/waves/round-29/tools/c2-measure.py 0229375… verify-red-witness <out>
      → C2_MEASURE verify-red-witness: m1=1 m2=1 m3=0 m4=1  (exit 1)
    python -I -B .ufo/waves/round-29/tools/c2-measure.py 49d1d46… verify-after <out>
      → C2_MEASURE verify-after: m1=1 m2=1 m3=1 m4=1        (exit 0)

Red witness reproduces: with the gate present over BASE instrument bytes the
live run reads DISAGREE naming `shape=trailing-period` while the hermetic
selftest stays green — the gate is shown able to fail and separable from C1.
At tip: `FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)` and
`FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)` re-run directly, exit 0 each. The
gate imports the live `release-clock.py` module and asserts the four extractors
are `re.Pattern`s (no copied grammar). The capability row entered the
SCORECARD capabilities table with first-working round 29 and a red-witness
evidence pointer. **Verdict: capability verified.**

Regression battery re-run at tip: `release-clock.py --selftest` →
`RELEASE_CLOCK_SELFTEST: PASS (116 cases)` exit 0 with one explicit
`SKIP receipt mode 0o600 (POSIX-only property; os.name=nt)` line (M29-1's
declared limit); default control CLEAN30 at both revisions (above).

## Honesty receipts — verified

- **Absent-fixture receipt**: `substrate-absence.txt` read; consistent with the
  report and the PROVINCE erratum; live gates failing closed on this host
  (SURFACE_CENSUS/DRIFT_PINS) are disclosed as correct outputs, not defects.
- **POSIX-scoped 0o600 selftest note (authorized Correction 1)**: red-before
  committed (`base-selftest-host.txt`) and reproduced by this session —
  `git archive c49023b corpus` + `python -I -B corpus/release-clock.py --selftest`
  → `RELEASE_CLOCK_SELFTEST: FAIL receipt mode or fields`, exit 1. After: PASS
  116 with the explicit SKIP line. On a POSIX host the case is byte-identical
  to BASE (fields half universal). M29-1's fix is shown able to fail.
- **M29-2 replay re-host**: the round-28 F1–F4 replay is embedded in
  `c1-measure.py` verbatim ("verbatim construction/predicates", BASE-era
  category exclusion set) with `sys.executable` child spawns; green at both
  revisions on this host. The frozen round-28 tool bytes are not modified.
- **M29-3 budget substitute (partially effective — see routed defects)**:
  full `claim-ledger.sh verify` / `self-counts.py` non-completion disclosed
  (>300 s / >240 s). The QM12 substitute's re-runs themselves verified: R25-03
  migrated 114→116 with old value + reason in the row note (read at tip);
  R29-01 `PASS (4 cases)` and R29-02 `AGREE (shapes=12 disagreements=0)`
  re-run by this session, exit 0. New self-counts bindings (12/12, 4/4, 116)
  hold (re-derived from the tip's self-counts.tsv against the gate's live
  output and R25-03). **But** the substitute's scope (touched/added rows only)
  missed untouched membership-count pins that this round's own bookkeeping
  invalidated — routed defects D1/D2 below.

## Per-axis verdicts (this session)

| Axis | Verdict | Basis |
|---|---|---|
| freshness | improved | C1 re-measured 5/7→0/7 mishandled, 2/7→7/7 correct, recipe-exact, replay+control green |
| calibration | unchanged | mistakes M29-1..3 with committed, reproduced red-befores; QM30 added; new bindings verified; stale-pin defects routed (status-neutral) |
| depth | unchanged | knowledge entry adds bounded detail on the lane's own token-extraction surface; 9→9 |
| coverage | unchanged | registry 51→52 on opened ground; lane census CLEAN rows=52 (re-run, exit 0) |
| operability | unchanged | the new runnable gate is booked under capabilities (no double-count); census/selftests re-run green |
| adjacency | unchanged | gate adjudicates the lane's own instrument only; new host reported in PROVINCE, not absorbed; R17-02 untouched |

No axis is harmed. SCORECARD diff: all six axes 9→9 with per-axis increments
recorded; capabilities row added; no scalar moved.

## Discernment spot-check (non-author)

| Item | Decision | Re-opened source | Agree/disagree | Reason |
|---|---|---|---|---|
| S052 RFC 4287 (new row) | admit, tier A, 180d | fresh fetch `https://www.rfc-editor.org/rfc/rfc4287.txt` with the declared profile | **agree** | re-fetched body 81,922 bytes, sha256 `3bd71d76289560c9e860151f39cebbdc402cfd8b788a62048d8dc42824f2d89c` — byte-identical to the recorded capture digest; quote `The "atom:title" element is a Text construct` located exactly once in §4.2.14; the quote grounds the teaches cell and the tier-A choice is right for the boundary rule |
| S045 SemVer §2 (re-opened row) | no change | fresh fetch `https://semver.org/spec/v2.0.0.html` | **agree** | `…MUST NOT contain leading zeroes` present at the cited anchor; canonical-form teaching unchanged; the used-by old→new change is logged in the lesson |
| Reject side | — | — | n/a | the round's Gate records no reject decision (report: "No source was rejected this round"), so there is no reject to sample; noted for the operator |

`bash <fleet>/scripts/sources-census.sh validate --root <fleet> kagi` → exit 0,
14 W04 duplicate-url warnings + ok (same as the report's END census);
`bash <lane>/corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=52 A=50
B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5 legacy=21 captures=52
inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0 — matches the report.

## Trend verdicts (this session)

- **expansion: unchanged** — one registry row on opened ground (S052, verified
  above); the knowledge entry sits on the lane's own token-extraction surface;
  the capability is booked in the capabilities table, not as coverage.
- **quality: improved** — a real fail-open closed by the frozen recipe and
  re-measured green; the D1 class became a standing gate with a retained red
  witness; the re-opened row did not fail its re-check.
- **discernment: unprovable-but-better** — three mistakes mined with fixes
  shown able to fail (red-befores committed and reproduced); QM30 added; the
  red witness kept instead of smoothed; my spot-check agrees with the sampled
  admit. Full outside judgment stays with the operator; no reject decision
  existed to sample.

## Routed defects (the lane must fix next round)

- **D1 (number-drift, ledger):** the round's bookkeeping invalidated four
  untouched ledger membership pins and none was migrated: `R12-03` pins `^91$`
  (actual stamps 94), `R13-01` pins `^34$` (actual SCORECARD round headings
  35), `R21-04` pins `^65$` (actual ledger rows 67), `R24-14` pins
  `count=65` + sha (actual 67 + new digest). The QM12 substitute (M29-3)
  re-ran only touched/added rows, so it structurally could not catch these;
  the round-28 Linux full-verify receipt cannot cover the tip's 67-row ledger.
  First full `claim-ledger.sh verify` on a capable host will read STALE.
  Fix: migrate the four rows old→new with the migration recorded, then re-run.
- **D2 (number-drift, doc cells):** six self-counts-bound cells still state
  the BASE numbers: SKILL.md "`(91 stamps + 65 claims`" (SC-SKILL-STAMPS,
  SC-SKILL-CLAIMS), PROVINCE.md "`verify` (91 revision stamps + 65 claim
  rows" (PV-STAMPS, PV-CLAIMS), corpus/README.md revision-stamps and
  ledger-rows index rows (RD-STAMPS, RD-LEDGER-ROWS). `self-counts.py` at tip
  will read STALE on all six. Fix: correct the cells to 94/67 (or the then-
  current values) and re-run self-counts.
- **D3 (reference-drift, minor):** QM30's lesson column cites
  `corpus/lessons/round-29.md M29-1`, but M29-1 is the host-property mistake;
  the criterion's actual grounding is the D1 extraction class (lesson §C1/§C2;
  round-28 §Attempt-3 corrigenda 1). Fix: a correcting note in the next lesson.
- **D4 (plan adherence, minor):** the frozen plan's frontier step named the D1
  scanner-extractor class as the mistake to mine into §Mistakes; §Mistakes
  carries M29-1..3 (host/landing) instead, with the D1 class documented in
  §C1/§C2 and QM30. The frontier minimum (≥1 mistake) is met; record the
  deviation in the next lesson.
- **D5 (hygiene, minor):** three files were silently converted LF→CRLF
  (SKILL.md, corpus/SOURCES.md, corpus/claim-ledger.tsv); the repo is now
  mixed-EOL. Stamps were re-pinned to the new bytes (94/94 verified by this
  session against the tip blobs), but the churn inflates every future diff.
  Fix: restore LF or declare one EOL convention repo-wide.

## SHONEN note for the operator

All four boxes remain `[~]` with resolvable pointers; the lane correctly wrote
no `[x]`. Box 1 (SKILL.md tables/citations) is mechanically re-checkable by a
non-author on the committed bytes; boxes 2–4 are blocked on this host by the
documented substrate absence (box 2 needs an end-to-end handler task), so no
promotion evidence is derivable this round.
