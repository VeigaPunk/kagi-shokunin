# Round 22 falsification — feature claim input and authority paths

Axes: **calibration** and **freshness**. Surface: `corpus/feature-claims.py` caller input, pinned `--claims` authority, JSON parsing, and root/symlink confinement. No production input was modified; all adversarial files were temporary local fixtures and were removed at test completion.

Read revision: integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, tree `d12afd7a545e86f21eb9acac567d10de774df50f`. Observed hashes:

- `.ufo/waves/round-22/integration-manifest.json`: `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`
- `corpus/feature-claims.py`: `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` (matches manifest)
- `corpus/feature-claims.json`: `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` (matches manifest)
- `plans/round-22.md`: `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` (matches manifest)
- `corpus/lessons/round-22.md`: `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` (matches manifest)
- `.ufo/waves/round-22/build/SafetyPaths.md`: `bdd7772dfd91fedb83a6c11d2a340a098292e4feadc7ed815097a4cd047c1395`

## Finding — Medium: FIFO input can hang adjudication

**Exploit path:** An untrusted fixture writer creates a FIFO at the caller-selected `--input` path or `--claims` path beneath the explicit root. With no writer attached, the gate blocks while opening the FIFO instead of promptly returning its documented cannot-evaluate result.

**Evidence:** `_read_beneath` opens the final component at `corpus/feature-claims.py:263` using `O_RDONLY | O_NOFOLLOW`, then only checks `stat.S_ISREG` at lines 264–266. In a temporary fixture root, both a FIFO passed as `--input` and one passed as `--claims` remained blocked for the full 1.0-second subprocess timeout; the harness terminated each child. Neither invocation returned a finding or exit code. This is an exercised failure, not a static-only concern.

**Impact:** A local untrusted record/path can indefinitely stall a review process before parsing or adjudication. No file content disclosure, network access, or fixture mutation was observed; the fixture-tree and outside-sentinel snapshots were unchanged.

**Smallest remediation:** Add `O_NONBLOCK` to the final-component open (retaining `O_NOFOLLOW`), then `fstat` that same descriptor and reject the FIFO as non-regular. Add writer-free FIFO regressions for both `--claims` and `--input` asserting prompt exit 2 with a stable file/path finding.

## Exercised controls and limits

- `python3 corpus/feature-claims.py --selftest` → exit 0, `FEATURE_CLAIMS_SELFTEST: PASS cases=10`.
- `--phase after` → exit 0: four bounded controls admitted, `false_admissions=0`, `misses=0`, `unjudgeable=0`.
- `--phase before` → exit 1 as intended: ten known-bad claims rejected (two `reject:false-claim`, eight `reject:bar-fail`), zero false admissions/misses/unjudgeables.
- `--phase boundary` → exit 2 as intended: three `cannot-evaluate` cases (unknown feature, unknown field, unknown source), scored `no`.
- Temporary `--input` records: bounded control → exit 0 / `FC-ADMITTED`; same-page status overclaim → exit 1 / `FC-STATUS-MISMATCH`; URI-shaped source ID (payload redacted) → exit 2 / `FC-UNKNOWN-SOURCE`; duplicate JSON key → exit 2 / `FC-JSON-DUPLICATE-KEY`; unknown field and forged `expected_decision`/`label_authority` fields → exit 2 / `FC-UNKNOWN-FIELD`. The typed caller record reaches adjudication without supplying or overriding expected labels; unknown label metadata is not accepted.
- Temporary `--claims` tampering: changed expected decision → exit 2 / `FC-RECORD-MANIFEST`; source URL mutation (payload redacted) → exit 2 / `FC-SOURCE-MANIFEST`; unknown top-level field → exit 2 / `FC-INPUT-SCHEMA`; duplicate key → exit 2 / `FC-JSON-DUPLICATE-KEY`. No mutation was admitted.
- Root confinement: traversal, final symlink, and intermediate-directory symlink attacks were exercised through both `--claims` and `--input`; each returned exit 2 / `FC-CLAIMS-PATH`. With an explicit root missing its default claims file while the process CWD contained the real corpus, the gate returned exit 2 / `FC-CLAIMS-PATH` rather than falling back to CWD. Fixture and outside-sentinel snapshots remained unchanged.
- Source-URI payloads remained only in temporary fixtures and are redacted here. Code declares source URLs inert metadata; inspected operations contain no URL fetch/client path. No host loopback, health, service, account, or vault access was attempted.

The decision checks above establish behavior against the frozen artifact's labels and prior bounded controls; they do **not** independently re-adjudicate vendor truth or establish a calibration score. The matching hashes establish frozen input identity only, not source currentness or a C2 revision-audit verdict. No race-swap, changing/oversized-file, or permission-denial probe was run; those are not claimed as passes. No installations or production edits. Parent should run the targeted FIFO regressions after remediation, then the authorized feature-gate selftest and decision phases; no build/lint/format checks were run here.
