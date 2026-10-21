# XSeparability-7 — round-28 claim-separability instrument

Deliverable: `.ufo/waves/round-28/tools/separability.py` (new). Builds C1-only and
C2-only overlays of `corpus/release-clock.py` from a candidate (40-hex rev, patch
file, or `--from-patches C1PATCH C2PATCH`), splitting BASE→candidate hunks with a
JSON manifest (`{"c1":[..],"c2":[..],"shared":[..],"drop":[..]}`, 1-based hunk
indices; coverage enforced unless `--allow-unassigned`), then runs the round-28
frozen fixture logic (plan C1 F1–F4, C2 G1–G4 + controls), the clock selftest and
self-counts on each overlay; writes JSON. Clones LANE read-only into
`/fast/scratch`; never writes or executes in the lane. No tool installs needed.

## Candidate 62a33b1bd15217ed729df2ca40c8a30aba3076c0 (measured)

Rev diff has 17 hunks. Manifest (content-attributed against XC1Patch/XC2Patch):
`c1=[1,5,6,7,8,9,12,14,15,16] c2=[10,11,13] shared=[2,3,4,17]`
(`build/XSeparability-candidate-manifest.json`; attribution evidence in the JSON
and this report, §4). Results:

- **Full candidate** (`c1=[1..17]` single overlay,
  `XSeparability-candidate-full.json`): overlay blob sha256 ==
  `git show 62a33b1:corpus/release-clock.py` (applier exact); selftest
  `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` ✓; F1 `NON-CANONICAL S040` typed,
  F2 `NON-CANONICAL S040` no traceback, F3/F4 `NON-CANONICAL S027/S028/S040/S041`
  with receipt error "non-canonical version token: feed stable entry", no fired
  observation written; control `RELEASE_CLOCK: CLEAN (on_release=30 bound=30
  unbound=0 observed=30 fired=3 derived=15)` exit 0; self-counts exit 1 stale
  exactly `SC-CLOCK-SELFTEST claimed=79 live=106` + `PV-CLOCK-SELFTEST`.
- **c1-only** (`XSeparability-candidate-run.json`): F1/F2 `NON-CANONICAL S040`
  typed, F2 no traceback; F3/F4 `NON-CANONICAL` ×4 typed; control clean30;
  selftest FAIL `feed floor lifts non-numeric anchor: errors {(DERIVATION,S001),
  (REGRESSED,S001)} != {(REGRESSED,S001)}` — the shared evaluate hunk H4 carries
  C2's derived rule while c2's fixture_source update (H11) is absent, so BASE's
  derived selftest rows trip DERIVATION. Coupling, not a C1 defect.
- **c2-only**: G1–G4 exit 1, `DERIVATION` findings naming exactly each group
  (S008–S011 / S013,S022–S024 / S014–S016,S021,S025,S026 / S029) — EXACT 4/4,
  ACCEPTED 0/4; control clean30; selftest FAIL `leading-zero feed observation was
  not typed NON-CANONICAL` — shared selftest hunk H17 carries C1's observe case
  while c1's observe gate (H9) is absent. Coupling, not a C2 defect.
- **Headline**: claim fixtures fully separate (F 3→0 mishandled, 4/4 typed;
  G 4→0 accepted, 4/4 exact; controls clean everywhere). The evaluate core is
  hunk-fused: H4 (shared) calls `non_canonical_version` (defined in c1's H3) and
  `derived_anchor_bound` (defined in c2's H2), so the two selftest failures above
  are unavoidable at hunk granularity; they vanish on the full candidate (106).

## Findings (BASE 3553d499577084a6c98d7078906017840bbf7b28, path:line)

1. **F1 BASE premise confirmed by measurement** — leading-zero observed fires:
   `anchor_ok` (`corpus/release-clock.py:566`) validates only the anchor cell;
   the observed token passes `numeric_version` (`:369-381`, `int("01")==1`) and
   fires on string inequality (`:582-584`). Measured BASE F1: exit 0
   `RELEASE_CLOCK: CLEAN (... fired=4 derived=15)` (fired 3→4).
2. **F4 BASE contradicts the plan's traceback wording (counterexample)** — the
   observe path catches the int-limit ValueError (`except (OSError, ValueError)`
   `:822` inside `observe_one` `:767`): exit 1, NO traceback, receipt error
   "Exceeds the limit (4300 digits)...", generic `RECEIPT-MISMATCH` ×4. The
   traceback exists only on the table path (F2, `evaluate`→`numeric_version`
   uncaught). The frozen TYPED letter is therefore satisfied at BASE by generic
   findings; a counter must require round-28 codes (as the frozen c1 classifier
   does: BASE F4 = OTHER).
3. **BASE before-state, measured** (empty candidate ⇒ overlays ≡ BASE): F1
   mishandled(clean-exit0), F2 mishandled(traceback), F3 mishandled(written-fired
   ×4), F4 other; control clean30; G1–G4 ACCEPTED 4/4 EXACT 0/4; selftest
   `PASS (79 cases)`; self-counts exit 0 `CLEAN (claims=60 stale=0)`.
4. **Candidate manifest derivation** — range overlap against the drafts plus
   added-line content membership (XC2's `-573` change lives inside candidate H4's
   region; pure-range attribution missed it). H2 = L1 helper hunk
   (`STABLE_TOKEN_RE`, `derived_anchor_bound`); H3 = C1 core
   (`non_canonical_version`, `version_order`, `VERSION_COMPONENT_MAX_DIGITS=18`,
   S045/S042/S043 comments); H4 = fused evaluate gates + NONCANONICAL-skips-C2;
   H17 = merged observe-selftest block (both claims' cases). XC2's `-563/-573`
   and XC1's `-564` all land in H4; XC1 `-1696` and XC2 `-1696` land in H17.
5. **Tool defects found and fixed during development** (each caught by a run):
   `dict(GROUP_FEEDS)` keyed by names not feed ids; unified-diff body accounting
   used `old+new` instead of `old+new−context`; `--no-index` header shapes
   (`1/a/... 2/b/...`) and `---`/`+++` section keying; rev diff run outside a
   repo (fell back to `--no-index`) — now `git -C LANE`; rev blob str/bytes;
   `apply_hunks` 3-value unpack; null candidate blob in summary print.

## Commands run (exit 0 unless noted)

- Lane state: `git rev-parse BASE:corpus/release-clock.py HEAD:...` identical
  blob e5fbbd25; `git diff --stat BASE..HEAD` = census + plans only; sandbox via
  `git archive BASE | tar -x` ✓.
- `python3 -m py_compile tools/separability.py` after every edit ✓.
- BASE before: `separability.py build/XSeparability-base-empty.diff
  build/XSeparability-base-manifest.json build/XSeparability-base-before.json
  --label before-empty` ✓ (re-run after classifier alignment).
- Synthetic 4-hunk split demo: manifest `c1=[1,2,4] c2=[3]` →
  `XSeparability-synthetic-run.json` ✓; `--from-patches` variant produced
  byte-identical overlay blobs ✓.
- Drafts: `--from-patches build/XC1Patch.diff build/XC2Patch.diff ...` ✓
  (c1-only F 4/4 typed, selftest 97 PASS; c2-only G exact 4/4, selftest 85
  PASS; union not computable from BASE-relative patches — both edit ~:563).
- Candidate: three runs above ✓.

## What I did NOT check

- The candidate's other files (rev diff scoped to release-clock.py per contract).
- Network observe (F3/F4 are offline via the clock's `request_body` seam; the
  python.org feed fixture bytes are recorded in the JSON).
- c1-measure.py / c2-measure.py outputs (frozen at candidate by L1; I measured
  with this tool's equivalent fixture logic — the JSONs carry raw stdout/receipts
  for cross-checking).
- Whether H17's merged selftest cases are individually correct (Rev* seats).
- No-newline diffs (refused by design); no hunk-application fuzzing.

## Artifacts (`build/XSeparability*`, sandbox `sandboxes/XSeparability-7/`)

`separability.py` (tool), `XSeparability.md` (this report), `-base-before.json`,
`-base-empty.diff`, `-base-manifest.json`, `-synthetic-{candidate.diff,c1.patch,
c2.patch,manifest.json,run.json,frompatches.json}`, `-candidate-manifest.json`,
`-candidate-run.json`, `-candidate-full-manifest.json`, `-candidate-full.json`,
`-attribution-draft.json`, `-drafts-run.json`.
