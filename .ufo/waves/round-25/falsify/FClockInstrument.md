# FClockInstrument — round-25 C3 falsification

Axes: **calibration** (observed-count semantics), **operability** (gate response), **freshness** (offline-only boundary).

## Verdict

**MEDIUM finding — the independent counter inflates `observed` for valid-dated orphan and duplicate TSV rows.** Candidate’s unmutated count is correct, and the canonical release-clock gate rejects each mutated fixture; this is a counter-calibration defect, not a demonstrated gate bypass.

`tools/c3-measure.py:149-153` counts `observed` across every binding with an ISO-valid date and counts `fired` across every row with that verdict. It does not restrict either sum to one valid binding for an `on-release` source. In contrast, `corpus/release-clock.py:369-377,384-460` flags orphans, rejects duplicate bindings, validates dates, and increments `observed` only for valid unique rows. Lines cited are from candidate `82745e2c60e726b49499b8f309529935dc4eff2b`.

## Exact revision and execution evidence

- BASE: `4587c61a348e4528717404a68912c373f3ef4d03`.
- Candidate checkout: `82745e2c60e726b49499b8f309529935dc4eff2b` (scratch clone HEAD matched exactly).
- Synthetic TSV revisions, isolated worktrees in `/fast/scratch/kagi-r25/FClockInstrument/`: orphan `1f81ea3427884d0fd6d123c1e1e864392607cd5b`; duplicate `cf2ebea0cb82cf06bc3442d34a96ac4958b8d274`; invalid date `d7ee606eb72d793d31750eab850b009a243887f6`; combined `63a41fd9d6412dc1d5e3a82684a21ecb7f02663b`.
- Python argv prefix for every test: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FClockInstrument/home PYTHONDONTWRITEBYTECODE=1 python3 -B`.
- CWD was `/fast/scratch/kagi-r25/FClockInstrument/lane` for BASE/candidate and each named mutation worktree for its synthetic tests.

| argv after common prefix / fixture | stdout | exit |
|---|---|---:|
| `.ufo/waves/round-25/tools/c3-measure.py 4587c61a348e4528717404a68912c373f3ef4d03` | `C3_MEASURE rev=4587c61a348e4528717404a68912c373f3ef4d03 on_release=28 bound=0 unbound=28 orphan=0 observed=0 fired=0` | 0 |
| `.ufo/waves/round-25/tools/c3-measure.py 82745e2c60e726b49499b8f309529935dc4eff2b` | `C3_MEASURE rev=82745e2c60e726b49499b8f309529935dc4eff2b on_release=28 bound=28 unbound=0 orphan=0 observed=28 fired=1` | 0 |
| `corpus/release-clock.py` at candidate | `RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)` | 0 |
| `corpus/release-clock.py --selftest` at candidate | `RELEASE_CLOCK_SELFTEST: PASS (48 cases)` | 0 |
| `.ufo/waves/round-25/tools/c3-measure.py 1f81ea3427884d0fd6d123c1e1e864392607cd5b` (append valid-date `S999`) | `C3_MEASURE rev=1f81ea3427884d0fd6d123c1e1e864392607cd5b on_release=28 bound=28 unbound=0 orphan=1 observed=29 fired=1` | 0 |
| `corpus/release-clock.py --root /fast/scratch/kagi-r25/FClockInstrument/orphan` | `ORPHAN S999`; `RELEASE_CLOCK: FAILED (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)` | 1 |
| `.ufo/waves/round-25/tools/c3-measure.py cf2ebea0cb82cf06bc3442d34a96ac4958b8d274` (append duplicate valid-date `S005`) | `C3_MEASURE rev=cf2ebea0cb82cf06bc3442d34a96ac4958b8d274 on_release=28 bound=27 unbound=0 orphan=0 observed=29 fired=1` | 0 |
| `corpus/release-clock.py --root /fast/scratch/kagi-r25/FClockInstrument/duplicate` | `INCONSISTENT S005`; `RELEASE_CLOCK: FAILED (on_release=28 bound=27 unbound=0 observed=27 fired=1 derived=15)` | 1 |
| `.ufo/waves/round-25/tools/c3-measure.py d7ee606eb72d793d31750eab850b009a243887f6` (S006 date `2026-02-30`) | `C3_MEASURE rev=d7ee606eb72d793d31750eab850b009a243887f6 on_release=28 bound=28 unbound=0 orphan=0 observed=27 fired=1` | 0 |
| `corpus/release-clock.py --root /fast/scratch/kagi-r25/FClockInstrument/invalid` | `INCONSISTENT S006`; `RELEASE_CLOCK: FAILED (on_release=28 bound=28 unbound=0 observed=27 fired=1 derived=15)` | 1 |
| `.ufo/waves/round-25/tools/c3-measure.py 63a41fd9d6412dc1d5e3a82684a21ecb7f02663b` (all three mutations) | `C3_MEASURE rev=63a41fd9d6412dc1d5e3a82684a21ecb7f02663b on_release=28 bound=27 unbound=0 orphan=1 observed=29 fired=1` | 0 |
| `corpus/release-clock.py --root /fast/scratch/kagi-r25/FClockInstrument/mutant` | `INCONSISTENT S005`; `INCONSISTENT S006`; `ORPHAN S999`; `RELEASE_CLOCK: FAILED (on_release=28 bound=27 unbound=0 observed=26 fired=1 derived=15)` | 1 |

The valid orphan and duplicate each add one to the independent `observed` count; the canonical gate counts neither. The invalid date is excluded from both observed counts and independently fails gate validation. In the combined fixture the counter reports 29 versus gate 26, with all three defects surfaced.

## Residual risk and verification gaps

- `fired` in the independent counter uses the same unfiltered row population (`c3-measure.py:153`); fired orphan/duplicate cases were not separately exercised. [INFERENCE] Those rows can inflate that metric too.
- Offline parsing/gate behavior only; live feeds and clock freshness were not re-fetched. `--observe` is UNRUN by design.
- LSP status was unavailable: `read xd://lsp/status` returned `Tool 'lsp' has no doc topics`; no semantic LSP checks are claimed. Targeted source reads and runtime outputs above are the evidence.
