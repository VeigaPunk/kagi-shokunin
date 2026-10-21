# XSelfCounts — C1 implementation and measured declaration conflict

Axes: calibration (implemented); operability/freshness (preserved boundaries; no C2/C3 edits).
Frozen revision: `4587c61a348e4528717404a68912c373f3ef4d03` (sandbox `git rev-parse HEAD`, exit 0).
Sandbox S: `/fast/scratch/kagi-r25/KagiR25.XSelfCounts-2`; implementation clone: `$S/lane`.
Production files were not edited. Patch contains only new `corpus/self-counts.py` and `corpus/self-counts.tsv`.
Patch: `.ufo/waves/round-25/patches/XSelfCounts.patch` (20139 bytes).
SHA-256: `5f3286d3977178e0bfa12c9788305f25818ff59f20206359be92e1a0bd04071c` (`sha256sum`, exit 0).

## Design and pointers
- `corpus/self-counts.py:129`: six-column TSV, one-capture regexes, nonnegative integers, nonempty population; Python 3 stdlib only.
- `corpus/self-counts.py:145`: rejects missing ledger IDs, host/substrate tags, nonallowlisted first tokens, explicit/default verify or cells recursion; no consent bypass.
- `corpus/self-counts.py:176`: shlex argv, shell=False, cwd=root, ledger timeout/expected exit, strict UTF-8, combined stdout/stderr's last nonblank line. Does not reuse pinned expect as the live count.
- `corpus/self-counts.py:195`: unique-line locations, deterministic row verdicts, source-output caching, error accounting; POLICY/SETUP override partial numeric results with exit 2.
- `corpus/self-counts.py:335`: --root/--table/--selftest; root defaults to the script's repo, relative table resolves under root, explicit absolute table supported.
- `corpus/self-counts.tsv:12-20`: nine bindings: stamps, claims, census rows, scope/source/closure/normalizer/ledger/census selftest counts.
- Explicit historical round observations are excluded; the undated current SKILL.md:243 tally is included, exposing a third stale claim. Numeric locators do not pin the old numeral.
- This is a reviewed-command executor, not a transitive hostile-wrapper sandbox; first-token policy cannot prove an arbitrary new script host-free.
- LSP unavailable: the mounted tool inventory exposes REA tools, no source-language LSP route; no supported symbol service was available. New symbols only; no existing references/refactors changed.

## Exact exercised commands and results
Setup: `mkdir -p $S/home && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin $S/lane && git -C $S/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03` — exit 0, empty stdout.
Created `$S/tmp`; later processes used `env -i PATH=/usr/bin:/bin HOME=$S/home` (plus `TMPDIR=$S/tmp` for all Python measurements and their child commands).
Interpreter: `env -i PATH=/usr/bin:/bin HOME=$S/home python3 --version` — exit 0, `Python 3.14.8`.
From `$S/lane`: `env -i PATH=/usr/bin:/bin HOME=$S/home TMPDIR=$S/tmp python3 corpus/self-counts.py --selftest` — exit 0:
```text
SELF_COUNTS_SELFTEST: PASS (29 cases)
```
Covers clean/stale/unlocated/ambiguous, host and substrate nonexecution, unknown ID, verify/cells/default/quoted recursion refusal, rows/comments/blanks, invalid regex/groups/integers, last-line extraction, command allowlist/exit/timeout/empty output, stderr, path escape and malformed/empty tables.
From `$S/lane`: `env -i PATH=/usr/bin:/bin HOME=$S/home TMPDIR=$S/tmp python3 corpus/self-counts.py` — exit 2, exact stdout:
```text
STALE SC-SKILL-STAMPS SKILL.md:46 claimed=63 live=83
STALE SC-SKILL-CLAIMS SKILL.md:46 claimed=39 live=61
OK SC-SCOPE-ROWS SKILL.md:35 claimed=35 live=35
OK SC-SCOPE-SELFTEST SKILL.md:35 claimed=61 live=61
OK SC-SOURCES-SELFTEST SKILL.md:47 claimed=70 live=70
OK SC-CLOSURE-SELFTEST SKILL.md:749 claimed=14 live=14
OK SC-RENDERED-SELFTEST SKILL.md:750 claimed=22 live=22
STALE SC-LEDGER-SELFTEST SKILL.md:243 claimed=97 live=151
POLICY SC-CENSUS-SELFTEST ledger:R11-03 host/substrate row refused
SELF_COUNTS: POLICY (claims=9 stale=3 unlocated=0 ambiguous=0 policy=1 setup=0)
```
Retained exact BASE output: `$S/base-self-counts.txt` (includes `EXIT: 2`).
Export: from `$S/lane`, `env -i PATH=/usr/bin:/bin HOME=$S/home git add -N -- corpus/self-counts.py corpus/self-counts.tsv` — exit 0; `env -i PATH=/usr/bin:/bin HOME=$S/home git -C $S/lane diff -- corpus/self-counts.py corpus/self-counts.tsv` — exit 0, retained verbatim in the assigned patch via write.
Fresh clone: `env -i PATH=/usr/bin:/bin HOME=$S/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin $S/apply-check && env -i PATH=/usr/bin:/bin HOME=$S/home git -C $S/apply-check checkout -q 4587c61a348e4528717404a68912c373f3ef4d03` — exit 0.
From `$S/apply-check`: `env -i PATH=/usr/bin:/bin HOME=$S/home git apply --check /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-25/patches/XSelfCounts.patch` — exit 0, empty stdout.

## Integration blocker and scope
The requested SKILL.md:36 case count binds to R11-03 (`corpus/claim-ledger.tsv:17`), whose note explicitly carries the substrate tag. The required policy therefore forbids executing it. It was NOT executed; the binding is retained rather than silently omitted or credited as passing (`corpus/self-counts.tsv:8-11,20`).
L1 must resolve the declaration/scope conflict before expecting CLEAN: review an actually host-free source, or explicitly replace the present claim with a dated historical observation and review its population change. Never relabel the existing present-tense claim or drop its binding merely to clear the gate. This seat cannot authorize a host row or edit SKILL.md/the ledger. Merely fixing the three stale numerals does not remove this POLICY result.
The three numerical repairs are SKILL.md:46 `63→83`, `39→61`, and SKILL.md:243 `97→151` at BASE; integrated membership counts must be measured again after L1 adds rows/stamps.
Retained peer evidence: `KagiR25.RHistoricalVsCurrent-2` reply `[15aed0b822696cdb]` classifies SKILL.md:36 as CURRENT/UNBOUND (not historical), SKILL.md:243's leading 97 as CURRENT and its “94 until round 18” tail as HISTORICAL; SKILL.md:669-671 does not exempt selftest tallies. This corroborates retaining the refused binding.
UNRUN: corrected-doc CLEAN, independent one-digit mutation, explicit external --table invocation, full ledger verify/cells, builds/linters/formatters. Parent owns integration gates.
Installs/updates: none. No credentials, vault/account/handler/CDP/op operations, host configuration changes, lane index mutations, commits or pushes.
