# Round 22 falsification — RunCellsMalformed

## Scope and result

Seat: `KagiR22.RunCellsMalformed`. Axes: **calibration** and **freshness**. Assignment: attack the integrated `claim-ledger.sh cells` heading boundary using owned fixtures only. No implementation change, round-admission judgment, depth claim, or legacy-header count claim.

**Observed defect:** six heading variants silently excluded six unpointed score rows and returned exit **0**, `CELL_AUDIT: CLEAN (cells=6 ...)`. Four ordinary malformed/non-blocked headings were correctly refused. Four controls behaved as declared: a normal six-axis section passed; the exact historical blocked attempt remained excluded; a recognized second section with unpointed rows failed; and a five-axis scored section after the blocked attempt remained a setup error.

These are executed parser decisions, not authored-row counts or a claim about vendor-fact adjudication. The bounded requirement that malformed scored headings/non-blocked attempts cannot become invisible and clean is **falsified** for the frozen implementation. This does not independently adjudicate C1's source catalog or C2's stamp-migration history.

## Frozen read identity

Historical BEFORE: `c2cab35bc92e57e39e5489bac3386db078345b3f`; it was not the execution input.

Named integration landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. The read-only command `git rev-parse '8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3^{tree}'` returned exit 0 and exactly `d12afd7a545e86f21eb9acac567d10de774df50f\n`. No detached-HEAD or live-tip inference was made.

Freeze authority: `.ufo/waves/round-22/integration-manifest.json`; observed SHA-256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.

Observed input SHA-256 values below equal their corresponding manifest entries:

| Input | SHA-256 |
|---|---|
| `corpus/claim-ledger.sh` | `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5` |
| `corpus/knowledge/claim-ledger.md` | `e914e2ac3f73534115f597efca41cda91686d425f66b94cfae873db22e49d734` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

The shell implementation was copied unchanged into `/tmp/kagi-r22-w2-CellsMalformed/corpus/claim-ledger.sh`. Its separately measured copy SHA-256 was also `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5`. This establishes the executable bytes under attack; hashes do not establish source currentness.

Input interface was inspected before execution: `claim-ledger.sh:194-227`, `303-327`, `387-432`, `505-515`, `593-665`, `676-770`, `782-807`, and `975-992`. The documented boundary is `corpus/knowledge/claim-ledger.md:166-176` and the round-22 erratum at `482-484`; the round lesson at `42` requires preservation of the guards. All citations here are local frozen source, not public-documentation rechecks.

## Execution isolation and exact argv

The owned scratch directory did not exist before creation. No production ledger, stamps, scorecard, or live-tree gate was executed. Each fixture has its own directory and explicit `--root .`, claims, stamps, scorecard, and one-document docset. Every cited command is only `grep -c EXPECTED corpus/ok.txt` against the owned fixture file. There are no substrate-tagged rows, self-audit rows, external paths, or credential values.

Harness invocation, executed once after integration:

```json
{"argv":["/usr/bin/python3","/tmp/kagi-r22-w2-CellsMalformed/run-fixtures.py"],"cwd":"/tmp/kagi-r22-w2-CellsMalformed","exit":0}
```

The harness collected observations rather than treating expected falsifications as its own error exit. It used at most four concurrent local subprocesses, each with a ten-second bound. No agents, orchestration runtime, background jobs, services, or installations were started.

Every individual fixture invocation used exactly this argv:

```json
["/usr/bin/bash","/tmp/kagi-r22-w2-CellsMalformed/corpus/claim-ledger.sh","cells","--root",".","--claims","claims.tsv","--stamps","stamps.tsv","--scorecard","./SCORECARD.md","--docs","./SCORECARD.md"]
```

For each case ID in the results table, exact cwd was `/tmp/kagi-r22-w2-CellsMalformed/fixtures/<case-id>`; the table supplies each literal case ID. The entire child environment was exactly:

```json
{"PATH":"/usr/bin:/bin","LC_ALL":"C","HOME":"/tmp/kagi-r22-w2-CellsMalformed/home","TMPDIR":"/tmp/kagi-r22-w2-CellsMalformed/tmp","KAGI_SUBSTRATE":"absent","CLAIM_LEDGER_DEPTH":"0"}
```

No inherited shell startup configuration or host HOME was passed. No host-private gate or loopback/health/CDP probe was used. No public GET was necessary. No launcher, opencode, mise, npm/npx, or package manager was invoked.

## Exact observed outputs and exits

Output labels in the table below are lossless references to the following JSON strings. `""` means zero bytes. Each nonempty string includes its final LF.

**C — stdout:**

```json
"CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)\n"
```

**U — stdout:**

```json
"UNCITED SCORECARD.md:18 depth (no resolving row id and no pinned artifact)\nUNCITED SCORECARD.md:19 coverage (no resolving row id and no pinned artifact)\nUNCITED SCORECARD.md:20 operability (no resolving row id and no pinned artifact)\nUNCITED SCORECARD.md:21 freshness (no resolving row id and no pinned artifact)\nUNCITED SCORECARD.md:22 calibration (no resolving row id and no pinned artifact)\nUNCITED SCORECARD.md:23 adjacency (no resolving row id and no pinned artifact)\nCELL_AUDIT: BROKEN (cells=12 row_pointed=6 stamp_pointed=0 uncited=6 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)\n"
```

**F — stderr:**

```json
"claim-ledger: scorecard section '## Round 23 — pre-move' does not carry all six axes exactly once (found=5 missing=adjacency)\n"
```

**M — stderr:**

```json
"claim-ledger: unrecognised round heading in ./SCORECARD.md: '## Round 23 post-move' (expected '## Round <N> — pre-move|post-move')\n"
```

**E — stderr:**

```json
"claim-ledger: unrecognised round heading in ./SCORECARD.md: '## Round 23 – post-move' (expected '## Round <N> — pre-move|post-move')\n"
```

**N — stderr:**

```json
"claim-ledger: unrecognised round heading in ./SCORECARD.md: '## Round 20 — interactive attempt; completed (2026-10-15)' (expected '## Round <N> — pre-move|post-move')\n"
```

**Q — stderr:**

```json
"claim-ledger: unrecognised round heading in ./SCORECARD.md: '## Round 20 — interactive attempt (2026-10-15)' (expected '## Round <N> — pre-move|post-move')\n"
```

| Case ID | Declared exit | Observed exit | stdout | stderr | Observed decision |
|---|---:|---:|---|---|---|
| `control-six-axes` | 0 | 0 | C | `""` | Normal six-axis section admitted |
| `control-exact-blocked` | 0 | 0 | C | `""` | Exact blocked historical heading excluded |
| `control-scored-uncited` | 1 | 1 | U | `""` | All six added unpointed rows detected |
| `control-five-after-blocked` | 2 | 2 | `""` | F | Completeness guard preserved |
| `malformed-missing-separator` | 2 | 2 | `""` | M | Malformed heading refused |
| `malformed-en-dash` | 2 | 2 | `""` | E | Malformed heading refused |
| `nonblocked-completed` | 2 | 2 | `""` | N | Non-blocked attempt refused |
| `nonblocked-unqualified` | 2 | 2 | `""` | Q | Non-blocked attempt refused |
| `malformed-round-tab` | 2 | **0** | C | `""` | **Six unpointed rows invisible** |
| `malformed-round-no-identifier` | 2 | **0** | C | `""` | **Six unpointed rows invisible** |
| `scored-tab-after-hashes` | 1 | **0** | C | `""` | **Six unpointed rows invisible** |
| `nonblocked-tab-after-hashes` | 2 | **0** | C | `""` | **Non-blocked attempt invisible** |
| `scored-three-leading-spaces` | 1 | **0** | C | `""` | **Six unpointed rows invisible** |
| `nonblocked-three-leading-spaces` | 2 | **0** | C | `""` | **Non-blocked attempt invisible** |

The harness's first stdout line was exactly:

```json
{"case_count": 14, "expectation_matches": 8, "implementation_sha256": "2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5", "runner_sha256": "7a58182d594def1e3d006ae8a49fb1f91d171cc6b07e62335fe65774cd4f1877", "silent_clean_attacks": 6, "spec_sha256": "3ae09976b6d009f7fb9db6510718812371d588d8e0ba1fcf6f09bb209c08ba48"}
```

No failing observation was rerun to confirm it or replaced with a narrower passing fixture.

## Retained immutable fixture content

The following is the complete executed specification, not illustrative input. JSON escapes `\t` and `\n` designate actual TAB/LF bytes after decoding; all files use UTF-8, no BOM, and LF endings. Materialization is defined immediately afterward, and every resulting scorecard has its full observed digest below. This records the fixture content in this report rather than relying only on ephemeral scratch paths.

```json
{
  "axes": ["depth", "coverage", "operability", "freshness", "calibration", "adjacency"],
  "shared": {
    "corpus/ok.txt": "EXPECTED\n",
    "claims.tsv": "R1-01\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\towned local fixture\n"
  },
  "base_heading": "## Round 22 — pre-move",
  "boundary": "\n## Notes\n\n",
  "base_pointer": "`R1-01`",
  "attack_pointer": "NO-POINTER",
  "cases": [
    {"id": "control-six-axes", "kind": "control", "heading": null, "expected_exit": 0, "expected_fragment": "CELL_AUDIT: CLEAN (cells=6"},
    {"id": "control-exact-blocked", "kind": "control", "heading": "## Round 20 — interactive attempt; blocked, not completed (2026-10-15)", "target_axes": ["depth"], "expected_exit": 0, "expected_fragment": "CELL_AUDIT: CLEAN (cells=6"},
    {"id": "control-scored-uncited", "kind": "control", "heading": "## Round 23 — post-move", "expected_exit": 1, "expected_fragment": "CELL_AUDIT: BROKEN (cells=12"},
    {"id": "control-five-after-blocked", "kind": "control", "heading": "## Round 20 — interactive attempt; blocked, not completed (2026-10-15)", "target_axes": ["depth"], "extra_scored_five": true, "expected_exit": 2, "expected_fragment": "all six axes exactly once (found=5 missing=adjacency)"},
    {"id": "malformed-missing-separator", "kind": "attack", "heading": "## Round 23 post-move", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "malformed-en-dash", "kind": "attack", "heading": "## Round 23 – post-move", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "nonblocked-completed", "kind": "attack", "heading": "## Round 20 — interactive attempt; completed (2026-10-15)", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "nonblocked-unqualified", "kind": "attack", "heading": "## Round 20 — interactive attempt (2026-10-15)", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "malformed-round-tab", "kind": "attack", "heading": "## Round\t23 — post-move", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "malformed-round-no-identifier", "kind": "attack", "heading": "## Round", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "scored-tab-after-hashes", "kind": "attack", "heading": "##\tRound 23 — post-move", "expected_exit": 1, "expected_fragment": "CELL_AUDIT: BROKEN (cells=12"},
    {"id": "nonblocked-tab-after-hashes", "kind": "attack", "heading": "##\tRound 20 — interactive attempt; completed (2026-10-15)", "expected_exit": 2, "expected_fragment": "unrecognised round heading"},
    {"id": "scored-three-leading-spaces", "kind": "attack", "heading": "   ## Round 23 — post-move", "expected_exit": 1, "expected_fragment": "CELL_AUDIT: BROKEN (cells=12"},
    {"id": "nonblocked-three-leading-spaces", "kind": "attack", "heading": "   ## Round 20 — interactive attempt; completed (2026-10-15)", "expected_exit": 2, "expected_fragment": "unrecognised round heading"}
  ]
}
```

Exact scorecard materialization used by the executed harness (`SPEC` is the JSON object above):

```python
def table(heading, axes, pointer):
    return heading + "\n\n| Axis | Score | Evidence |\n|---|---|---|\n" + "".join(
        f"| {axis} | 9 | {pointer} |\n" for axis in axes
    )

content = table(SPEC["base_heading"], SPEC["axes"], SPEC["base_pointer"])
if case["heading"] is not None:
    content += SPEC["boundary"] + table(
        case["heading"], case.get("target_axes", SPEC["axes"]), SPEC["attack_pointer"]
    )
if case.get("extra_scored_five"):
    content += "\n" + table(
        "## Round 23 — pre-move", SPEC["axes"][:-1], SPEC["base_pointer"]
    )
# SCORECARD.md bytes are content.encode("utf-8").
```

Each case also has the identical shared files from the specification and exactly this `stamps.tsv` content:

```json
"corpus/ok.txt\tfe6c38465f34c6c6cfdb0411f8bf0a604da841f46cea8b4de7238957ca0152c1\t1\t9\n"
```

| Shared file | Bytes | LF count | SHA-256 |
|---|---:|---:|---|
| `corpus/ok.txt` | 9 | 1 | `fe6c38465f34c6c6cfdb0411f8bf0a604da841f46cea8b4de7238957ca0152c1` |
| `claims.tsv` | 65 | 1 | `91c76e92ce3781f2ba1835a0aabdfdff03d08bf1806cb29c12ae529f6aca50c0` |
| `stamps.tsv` | 83 | 1 | `33c959da402f5fe9775b3103efdff4c298af22f0e435579124990236450cb66e` |

Exact executed `SCORECARD.md` fingerprints:

| Case ID | Bytes | LF count | SHA-256 |
|---|---:|---:|---|
| `control-six-axes` | 235 | 10 | `e59edf559468e7e548e253d14dd547f08141b1e4708805bf67d07352ba773fad` |
| `control-exact-blocked` | 389 | 18 | `6458e9ed0d4453bd09a6cfaeb4306a3bcb8fc963aecc28ff53c006fa68d06ebc` |
| `control-scored-uncited` | 500 | 23 | `b67e117103e2bf2527d443f38a87ab93b51eedf2f4636439f8defa4ab59b8bcb` |
| `control-five-after-blocked` | 597 | 28 | `b9a92c5b0c47d4db385b86b61c625d6c8c4a9e612ca4f71facfd5171a4a32596` |
| `malformed-missing-separator` | 496 | 23 | `a63c9e283c084395ac5bd3a75d0caf16a9356e289345e016273ccf93aaa65ee8` |
| `malformed-en-dash` | 500 | 23 | `ce522eaf6fba8ccf9f65af6b027237b31bc3aa962fbefbb48c594eef95fb1f85` |
| `nonblocked-completed` | 534 | 23 | `e9cbf9849d502c5df8ded8788caef7a604eb0b215cbc2e4215208c422633a284` |
| `nonblocked-unqualified` | 523 | 23 | `7339a45244ac1cb24d6314bed8bc975619a653b177e6957075000b1693dc6c42` |
| `malformed-round-tab` | 500 | 23 | `c32dfab23ed6b5278bef00e0f0ce5e219f84f9f72cba7e84afac00ab64e9dd56` |
| `malformed-round-no-identifier` | 483 | 23 | `43a22240acb788f1e5adea368d4f0ef2bf7ff27e897ae386ae2b0f5e0a65cec3` |
| `scored-tab-after-hashes` | 500 | 23 | `57984ff61fdedc474c2710522a06041e541b5b464e455cca795b4ae0eadd7d02` |
| `nonblocked-tab-after-hashes` | 534 | 23 | `1dc5f3da8a8e7900b64c336ae6046b88af727b4625be8747ba494acc60e81e96` |
| `scored-three-leading-spaces` | 503 | 23 | `3c2ab81b7383c7ff2ef73e69021ada101e36a03e2f3d75159fcafb6ea7a023b0` |
| `nonblocked-three-leading-spaces` | 537 | 23 | `cc403f3b4afa35fa45a69740e12654dc81cd59a094c44c6becfa73000e21f40d` |

Additional retained scratch artifacts, explicitly scratch and not durable source authority:

| Artifact under `/tmp/kagi-r22-w2-CellsMalformed/` | SHA-256 |
|---|---|
| `fixture-spec.json` | `3ae09976b6d009f7fb9db6510718812371d588d8e0ba1fcf6f09bb209c08ba48` |
| `run-fixtures.py` | `7a58182d594def1e3d006ae8a49fb1f91d171cc6b07e62335fe65774cd4f1877` |
| `results.json` | `c2b0e3fe600e60198443cb785800e657310b8feb2f474efc3c647bb8518aad69` |

`results.json` retains each exact argv/environment/cwd, stdout/stderr/exit, fixture UTF-8 content, byte/LF counts, and per-file hashes. The report independently retains all fixture byte definitions, command arguments, outputs, and fingerprints needed for the scoped finding.

## Mechanism and proposed correction

Observed source mechanism at `claim-ledger.sh:715-725`:

- The outer boundary only recognizes a line beginning with literal `## `.
- The malformed-Round refusal only runs for literal `## Round `, including the trailing ASCII space.
- `## Round\t23 ...` and bare `## Round` enter the outer boundary but evade the inner Round detector.
- A TAB after `##`, or three leading spaces before `##`, evades the outer boundary entirely.
- The fixtures place `## Notes` after a valid six-axis section, then the target heading and six `NO-POINTER` rows. The valid section keeps the global count positive; the target stays outside the scored set, so completeness/non-vacuity guards cannot see it.

This is a heading-recognition gap, not evidence that the exact blocked-attempt exception was generalized by its regex. The plain non-blocked controls were refused, and the exact blocked title was excluded as intended.

Proposed correction, not implemented here: recognize the heading boundary consistently before classifying Round sections, and fail closed for malformed Round-like headings including a missing identifier or alternate whitespace. For supported heading whitespace, either audit the scored table or explicitly reject its unsupported spelling; never silently treat it as prose. Retain the narrow historical blocked-title exception and all six-axis, row-pointer, and non-vacuity guards. Do not broaden the exception to arbitrary interactive attempts or arbitrary mentions of blocked status.

Risk: an ordinary formatting change can hide score-bearing rows while leaving a clean summary. The measured counterexamples require an already-positive valid section and a prose boundary; this report does not claim that every placement or every Markdown spelling bypasses the gate.

## Files, limits, and parent checks

Production files changed: **none**. Repository write: this exclusive report only. Owned scratch contains the unchanged implementation copy, fixture specification, bounded runner, generated fixtures, and retained results. There is no implementation patch for integration.

No build, lint, formatter, full selftest, host-private gate, source-catalog decision run, live ledger run, or revision-membership audit was executed. Freshness evidence is restricted to the measured freeze identity and copied implementation bytes; no restamping, expectation migration, vendor fact, source epoch, or nine-line historical reconciliation is certified by this task.

LSP: this seat's exposed tool inventory has no LSP interface; no symbol definition/reference/refactor operation was performed. Fixed source ranges were read directly. Installs/updates: **none**. Blockers to the assigned verification: **none**.

After any parent-owned correction and integration, run these retained heading fixtures, the complete claim-ledger scratch selftest, and the parent's authorized post-integration gates. The expected outcome is that all six currently silent-clean attacks become explicit failures or audited unpointed sections, while the exact blocked control and completeness controls preserve their intended behavior. Those future checks were not run here.
## Supplemental H1 probes (three additional executions)

Following `KagiR22`'s bounded follow-up, these cases were run against the immutable landed H1 script extracted from Git, not against a live source path. Existing 14 cases were **not rerun**.

Exact extraction command:

```text
git show 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3:corpus/claim-ledger.sh > /tmp/kagi-r22-w2-CellsMalformed/corpus/claim-ledger-h1.sh
exit 0
```

`git show ... | sha256sum` returned `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5`; the extracted file independently hashed to the same digest (83,655 bytes). This matches the frozen manifest's `corpus/claim-ledger.sh` input and the earlier read-only measurement of tree `d12afd7a545e86f21eb9acac567d10de774df50f`.

Runner invocation:

```json
{"argv":["/usr/bin/python3","/tmp/kagi-r22-w2-CellsMalformed/run-h1-supplement.py"],"cwd":"/tmp/kagi-r22-w2-CellsMalformed","exit":0}
```

The runner stdout summary was:

```json
{"case_count": 3, "expectation_matches": 0, "h1_script_sha256": "2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5", "silent_clean_cases": 3}
```

Each probe used the following exact argv:

```json
["/usr/bin/bash","/tmp/kagi-r22-w2-CellsMalformed/corpus/claim-ledger-h1.sh","cells","--root",".","--claims","claims.tsv","--stamps","stamps.tsv","--scorecard","./SCORECARD.md","--docs","./SCORECARD.md"]
```

For each row below the cwd was `/tmp/kagi-r22-w2-CellsMalformed/h1-supplement/fixtures/<case-id>`. The exact environment was:

```json
{"PATH":"/usr/bin:/bin","LC_ALL":"C","HOME":"/tmp/kagi-r22-w2-CellsMalformed/home","TMPDIR":"/tmp/kagi-r22-w2-CellsMalformed/tmp","KAGI_SUBSTRATE":"absent","CLAIM_LEDGER_DEPTH":"0"}
```

All three executions returned exit **0**, with stderr exactly `""`. Their complete stdout values were:

**All three stdout:**

```json
"CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)\n"
```

**`h1-post-movement-pointed` stdout instead:**

```json
"CELL_AUDIT: CLEAN (cells=12 row_pointed=12 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)\n"
```

| Case ID | Target heading | Target evidence | Expected setup-failure exit | Observed exit | Finding |
|---|---|---|---:|---:|---|
| `h1-upper-round-unpointed` | `## ROUND 23 — post-move` | Six `NO-POINTER` cells | 2 | **0** | Invalid uppercase heading skipped; six unpointed rows invisible |
| `h1-lower-round-unpointed` | `## round 23 — post-move` | Six `NO-POINTER` cells | 2 | **0** | Invalid lowercase heading skipped; six unpointed rows invisible |
| `h1-post-movement-pointed` | `## Round 23 — post-movement` | Six `R1-01`-pointed cells | 2 | **0** | `SEC_RE` prefix accepts malformed `post-movement` as a scored section |

Each complete executed `SCORECARD.md` is preserved below as its UTF-8 bytes; line endings are LF, and the terminal `\n` in each code block is part of the file. Shared exact fixture files were identical in each case:

```text
claims.tsv (65 bytes, LF=1, SHA-256 91c76e92ce3781f2ba1835a0aabdfdff03d08bf1806cb29c12ae529f6aca50c0):
R1-01<TAB>grep -c EXPECTED corpus/ok.txt<TAB>^1$<TAB>0<TAB>5<TAB>owned local fixture<LF>

corpus/ok.txt (9 bytes, LF=1, SHA-256 fe6c38465f34c6c6cfdb0411f8bf0a604da841f46cea8b4de7238957ca0152c1):
EXPECTED<LF>

stamps.tsv (83 bytes, LF=1, SHA-256 33c959da402f5fe9775b3103efdff4c298af22f0e435579124990236450cb66e):
corpus/ok.txt<TAB>fe6c38465f34c6c6cfdb0411f8bf0a604da841f46cea8b4de7238957ca0152c1<TAB>1<TAB>9<LF>
```

In this section's shared-file notation, `<TAB>` and `<LF>` each encode the single literal byte named; each actual file has the indicated terminal LF.

`h1-upper-round-unpointed` — 500 bytes, LF=23, SHA-256 `165d93f6b261b3e4f444cc42a9baaf3344d8fd03344870e6b2782044fdfcdb80`:

```markdown
## Round 22 — pre-move

| Axis | Score | Evidence |
|---|---|---|
| depth | 9 | `R1-01` |
| coverage | 9 | `R1-01` |
| operability | 9 | `R1-01` |
| freshness | 9 | `R1-01` |
| calibration | 9 | `R1-01` |
| adjacency | 9 | `R1-01` |

## Notes

## ROUND 23 — post-move

| Axis | Score | Evidence |
|---|---|---|
| depth | 9 | NO-POINTER |
| coverage | 9 | NO-POINTER |
| operability | 9 | NO-POINTER |
| freshness | 9 | NO-POINTER |
| calibration | 9 | NO-POINTER |
| adjacency | 9 | NO-POINTER |
```

`h1-lower-round-unpointed` — 500 bytes, LF=23, SHA-256 `37724428971f701da6cd20ac1f80e61cc5d89993177e7b5eb0844a9d56ddbd91`:

```markdown
## Round 22 — pre-move

| Axis | Score | Evidence |
|---|---|---|
| depth | 9 | `R1-01` |
| coverage | 9 | `R1-01` |
| operability | 9 | `R1-01` |
| freshness | 9 | `R1-01` |
| calibration | 9 | `R1-01` |
| adjacency | 9 | `R1-01` |

## Notes

## round 23 — post-move

| Axis | Score | Evidence |
|---|---|---|
| depth | 9 | NO-POINTER |
| coverage | 9 | NO-POINTER |
| operability | 9 | NO-POINTER |
| freshness | 9 | NO-POINTER |
| calibration | 9 | NO-POINTER |
| adjacency | 9 | NO-POINTER |
```

`h1-post-movement-pointed` — 486 bytes, LF=23, SHA-256 `e404298ea9b5cae9497e255ecf39235eb99f2ded5a662e3b8b724aa06fe3a6bd`:

```markdown
## Round 22 — pre-move

| Axis | Score | Evidence |
|---|---|---|
| depth | 9 | `R1-01` |
| coverage | 9 | `R1-01` |
| operability | 9 | `R1-01` |
| freshness | 9 | `R1-01` |
| calibration | 9 | `R1-01` |
| adjacency | 9 | `R1-01` |

## Notes

## Round 23 — post-movement

| Axis | Score | Evidence |
|---|---|---|
| depth | 9 | `R1-01` |
| coverage | 9 | `R1-01` |
| operability | 9 | `R1-01` |
| freshness | 9 | `R1-01` |
| calibration | 9 | `R1-01` |
| adjacency | 9 | `R1-01` |
```

The first two supplemental observations independently confirm the case-insensitive/uppercase heading bypass with the same valid-section + `## Notes` + six unpointed-row control arrangement. The third adds a distinct prefix-anchoring defect: the scored-heading expression accepts `post-movement` because it matches the `post-move` prefix, so even six pointed cells do not cause the malformed section to be rejected.

Retained H1 supplement artifacts:

| Scratch artifact | SHA-256 |
|---|---|
| `corpus/claim-ledger-h1.sh` | `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5` |
| `run-h1-supplement.py` | `7cacbe83387d3e484dc4abfcdb8053121e92ef8b392d58127dbc2cfa0962cfc4` |
| `h1-supplement-results.json` | `799f77e5bc34175013c7b17a7df68565673618840736068d4a0d7831ea557466` |

The exact per-case argv/environment/cwd, stdout/stderr/exit, and every executed file's content and digest are retained in that scratch JSON. No production input was edited. Parent's parser correction should enforce a terminal boundary after supported heading forms (`pre-move` or `post-move`) and distinguish malformed Round-like headings, including capitalization variants, without widening the exact blocked-heading exception. The successful exact historical blocked control and prior six-axis controls remain part of the original recorded results; they were not rerun in this supplement.
