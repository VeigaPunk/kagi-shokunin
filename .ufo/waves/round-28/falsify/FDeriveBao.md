# FDeriveBao — round-28 falsify, carrier C2/G3 (OpenBao feed S035, six derived rows lowered)

**Verdict: PASS** for the C2/G3 carrier as claimed, with two residual observations (one
medium, one low). The candidate's typed finding is reproduced independently of the frozen
instrument and is not a receipt artifact.

Target: lane repo @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (BASE
`3553d499577084a6c98d7078906017840bbf7b28`). Carrier: `corpus/release-clock.py`. Isolation:
candidate/BASE trees exported with `git archive` into `.ufo/waves/round-28/sandboxes/FDeriveBao/`
(heavy trees relocated to `/fast/scratch/hyaku/kagi-r28/FDeriveBao/`, deleted at completion).
No network, no production edit; lane `git status` unchanged apart from my sandbox + this report.

## Findings

1. **MEDIUM (residual, not a claim failure) — `--observe` writes a *fired* verdict for
   C2-mismatched derived rows.** `corpus/release-clock.py:879-891` (candidate) derives the
   receipt verdict from the table anchor alone; the C2 binding is never consulted in the
   observe path (`corpus/release-clock.py:618-626` lives only inside `evaluate`). Counterexample
   (offline; `request_body` patched to a fake OpenBao Atom whose newest stable is `v2.7.1`,
   i.e. what registry row S035 locates — `corpus/SOURCES.md:41`):
   `RELEASE_CLOCK_OBSERVE: wrote 6 observations (failed=0 fired=6 regressed=0)`, receipt
   `verdict="fired" parsed_version="2.7.1"` for S014/S015/S016/S021/S025/S026 — the forged
   lowering yields a *release event* in the receipt file, although the same run's `evaluate`
   still reports `DERIVATION` ×6 (exit 1), so the forgery is not laundered. Asymmetric with
   C1, whose non-canonical guard (`corpus/release-clock.py:870-873`) writes no verdict at all.
   C2's claim text (`plans/round-28.md` §C2, `corpus/lessons/round-28.md:77`) requires only "a
   mismatch is a typed finding (exit 1)" — outside the claim, but a "no fired verdict written"
   reading of C2 is not met. Evidence:
   `.ufo/waves/round-28/sandboxes/FDeriveBao/probe_observe.out` (+ the two receipt JSONs).
2. **LOW — declared limit, not a defect.** Editing the feed row's anchor cell *together with*
   table + receipt passes: rename S035's cell to `v2.6.0` and lower the six rows to `2.6.0` →
   `RELEASE_CLOCK: CLEAN`, exit 0. Declared at `corpus/lessons/round-28.md:95-97` ("C2 is
   error detection, not tamper evidence").

No claim-breaking defect found for this carrier.

## Independent reproduction (commands, actual exit codes)

Fixture = frozen §C2 G3 (six derived rows S014,S015,S016,S021,S025,S026 of feed S035 lowered to
one lower canonical version, observed version equal, verdict `not-fired`) plus the plan
correction's receipt mirror (`build_g3.py`; receipt sha256 `18495533aa3cb381995039b8df5cfc5e9a8e2b96be03de0469419270fd4cdc8c`).

| # | command (cwd) | exit | result |
|---|---|---|---|
| 1 | `python3 build_g3.py` | 0 | fixture + mirrored receipt written |
| 2 | `python3 -I -B corpus/release-clock.py --root <g3> --receipt <g3-receipt.json> --receipt-sha <sha>` (candidate) | **1** | `DERIVATION S014/S015/S016/S021/S025/S026`; `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=24 fired=3 derived=9)`; no `Traceback`; no `RECEIPT-MISMATCH` |
| 3 | same command, BASE tree, identical fixture | **0** | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` — BASE silently accepts the forgery |
| 4 | `python3 -I -B corpus/release-clock.py --root <cand>` (unmodified tree, default receipt) | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` — control matches the plan's control line |
| 5 | `python3 probes.py` (P1–P6) | 0 | see probes below |
| 6 | `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1… cand <out.json>` | 0 | `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True`; G3 `finding_categories=['DERIVATION'×6]`, `named_ids=[S014,S015,S016,S021,S025,S026]`, exit 1 — agrees with my run |
| 7 | same tool on BASE `3553d49` | 0 | `groups_accepted_clean=4/4 derivation_exact=0/4` — BASE accepts G3 |
| 8 | `python3 -I -B cand/corpus/release-clock.py --selftest` / `base/…` | 0 / 0 | `PASS (106 cases)` vs BASE `PASS (79 cases)` (+27 = 18 C1 + 9 C2, the lesson's counts) |

Probes (`probes.py`, transcript `probes.out`; candidate tree; exit 1 unless stated):
- **P1** registry-driven, not vacuous: rename only S035's anchor cell (`v2.7.1`→`v2.6.0`),
  table untouched → `DERIVATION` ×6, exit 1 — the finding follows the registry cell.
- **P2** exact binding: cell `v2.6.0` + rows lowered to `2.6.0` → `CLEAN`, exit 0.
- **P3** receipt liveness: rows lowered, receipt **not** mirrored → `DERIVATION` ×6 **and**
  `RECEIPT-MISMATCH` ×6, exit 1 ⇒ the typed finding is independent of the generic receipt
  mismatch (my G3 run shows only `DERIVATION`).
- **P4** only S014 lowered → `DERIVATION S014` + pre-existing `REGRESSED S014` (feed floor
  2.7.1), exit 1 — the finding names exactly the touched row.
- **P5/P6** evasion by dropping the `derived:` prefix → `INCONSISTENT` ×6, exit 1 (still typed);
  anchors *raised* to 2.8.0 instead of lowered → `DERIVATION` ×6, exit 1 (direction-symmetric).
- Lower value `2.7.0` (the frozen instrument's G3 value) reproduces identically to my `2.6.0`:
  `DERIVATION` ×6, exit 1.

## Exact candidate locations

- `corpus/release-clock.py:618-626` — C2 branch `errors.add(("DERIVATION", source_id))`.
- `corpus/release-clock.py:349-363` — `derived_anchor_bound` (anchor cell only; one stable
  `X.Y.Z`); `:345` `STABLE_TOKEN_RE`; `:615` `is_derived` detection. BASE `3553d49`
  `corpus/release-clock.py:565-567` — `anchor_ok = is_derived or …`: the derived anchor was
  never bound to its feed row (the defect C2 removes).
- `corpus/SOURCES.md:41` — S035 OpenBao feed row, located anchor `v2.7.1`.
- `corpus/lessons/round-28.md:69-77` and `SKILL.md:48` name the same category string
  (`DERIVATION`), so the builder's proposed `DERIVATION-MISMATCH` wording changed consistently.

## Not checked

- Live network paths (`--observe` against github.com / python.org / curl.se) — deliberately
  offline; the observe probe patched `request_body` in-process, so real HTTP status/sha capture
  is unverified, as is the `--observe` write path for the other 24 on-release rows.
- G1/G2/G4 fixtures (other feeds), C1's F1–F4 fixtures, `separability.py`, ledger/claim pins,
  the lane's own gate/selftest scripts — outside this seat's carrier.
- Whether `DERIVATION` is consumed by any non-`release-clock.py` tool — grep found it only in
  `corpus/release-clock.py`, `SKILL.md`, `corpus/lessons/round-28.md` and wave-28 build files.

Tooling: no installs, upgrades or network fetches. Report: `.ufo/waves/round-28/falsify/FDeriveBao.md`
(lane-authored advice; no SHONEN marks).
