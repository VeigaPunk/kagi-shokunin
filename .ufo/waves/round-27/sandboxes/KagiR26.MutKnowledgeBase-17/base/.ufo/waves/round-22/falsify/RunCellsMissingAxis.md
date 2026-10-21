# Round 22 falsification — RunCellsMissingAxis

## Scope and verdict

Project axes: **C1 calibration** and **C2 freshness**. This assigned probe tests only the `cells` completeness boundary (a calibration-adjacent scorecard-integrity check); it does **not** adjudicate E1/E3 feature claims or measure C2 pin freshness.

**PASS for the assigned rejection criterion.** On a private fixture copied from the frozen integrated scorecard, removing the `calibration` row from the actual Round 22 pre-move scored table made `claim-ledger.sh cells` reject the section with exit 2 and the exact missing-axis diagnostic. The pre-existing blocked Round 20 prose and heading remained in the fixture. No implementation or live tree files were changed.

## Frozen inputs and fixture identity

The observed `integration-manifest.json` SHA-256 was `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`. Observed source identities matched the corresponding frozen manifest entries:

| Input | SHA-256 | observed lines / bytes |
|---|---|---:|
| `SCORECARD.md` before fixture mutation | `748790b416547fbbc66dcdc33907c7a2aa3fcb01badb1dd99965398a82bf132d` | 771 / 93172 |
| `corpus/claim-ledger.sh` | `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5` | 1371 / 83655 |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 / 17770 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 / 7213 |

The private fixture root was `/tmp/kagi-r22-w2-CellsMissingAxis`. Its copied `corpus/claim-ledger.sh` retained the frozen SHA above. The full copied scorecard was changed only by deleting this exact line from `## Round 22 — pre-move (master `c2cab35bc92e57e39e5489bac3386db078345b3f`)`:

```text
| calibration | 9 | `corpus/lessons/round-21-verifier-spotcheck.md` rejects prior E1/E3 admits and authored-row calibration; executable feature-bound adjudication capability absent at base. Scalar is held, not a current outside agreement score. |
```

Fixture scorecard SHA-256 after that single-line deletion: `acb4120bcd7bb25ca81dafd42558247bb976c672cada0d0ae4e2a670ac29d890` (770 lines, 92925 bytes). The preserved blocked section still begins `## Round 20 — interactive attempt; blocked, not completed (2026-10-15)` and its blocked prose remains in the copied scorecard.

To keep a failed completeness guard from ever dispatching host-bound ledger commands, the fixture supplied a separate 43-row safe claim table (`fixture-claims.tsv`, SHA-256 `675a1e97dcea8839647899edeeb71027dc3ed0029832032c97c6da3ec1117ad2`): it retained the actual ledger IDs but mapped each to the local read-only command `grep -c '^# kagi-shokunin' SCORECARD.md` with expected output `1`. The fixture stamp table contained one nonmatching local anchor only: `fixture-stamps.tsv` SHA-256 `117764a3c1988dca293849556bb4bb896cf83951b22992f1664b9a1b8f900c8e`; anchor SHA-256 `35ba965d04befbc0978dda1c960645dfa6ab770d754988b0304715734a65a4e0` (1 line, 24 bytes). These safety fixtures are not production inputs or evidence for C1/C2. The rejection occurred during `cells` parsing, before its `cells_evidence` phase, so no claim command was run.

## Exact execution evidence

Working directory: `/tmp/kagi-r22-w2-CellsMissingAxis`

Exact argv:

```text
bash /tmp/kagi-r22-w2-CellsMissingAxis/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsMissingAxis --claims /tmp/kagi-r22-w2-CellsMissingAxis/corpus/fixture-claims.tsv --stamps /tmp/kagi-r22-w2-CellsMissingAxis/corpus/fixture-stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsMissingAxis/SCORECARD.md --docs /tmp/kagi-r22-w2-CellsMissingAxis/SCORECARD.md
```

Process exit: **2**.

Exact stdout:

```text
LABELED-ID SCORECARD.md:108 R13-99 (labelled on its line)
UNCITED SCORECARD.md:16 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:17 coverage (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:18 operability (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:19 freshness (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:20 calibration (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:21 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:27 freshness (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:29 coverage (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:30 calibration (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:31 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:32 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:38 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:39 coverage (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:42 calibration (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:43 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:51 freshness (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:53 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:54 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:60 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:64 calibration (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:65 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:72 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:73 coverage (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:76 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:82 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:87 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:98 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:109 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:116 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:120 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:185 freshness (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:187 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:196 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:198 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:206 operability (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:209 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:217 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:220 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:231 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:238 calibration (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:239 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:304 calibration (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:305 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:306 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:314 freshness (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:326 adjacency (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:327 depth (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:707 freshness (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:708 adjacency (no resolving row id and no pinned artifact)
```

Exact stderr:

```text
claim-ledger: scorecard section '## Round 22 — pre-move (master `c2cab35bc92e57e39e5489bac3386db078345b3f`)' does not carry all six axes exactly once (found=5 missing=calibration)
```

## Limits and handoff

- This establishes rejection for one missing-axis mutation of the actual Round 22 pre-move section, while keeping the blocked prose intact. It does not test every malformed-section shape or a post-move mutation.
- The safe fixture substitutions deliberately do not establish real pointer coverage or rerun the actual claim set; the noisy `UNCITED` stdout is expected from the isolated stamp fixture and is not the rejection criterion. The decisive evidence is the exact section-completeness diagnostic and exit 2.
- No source-currentness or revision-accounting claim follows from this `cells` execution. C2 remains unmeasured here.
- No installs, host-private gates, network probes, service probes, builds, linters, tests, formatters, or production edits were performed.

Files written: this report and the private fixture under `/tmp/kagi-r22-w2-CellsMissingAxis` only. No main-agent follow-up check is implied for this scoped falsification result; integration verification remains parent-owned.
Report: .ufo/waves/round-22/falsify/RunCellsMissingAxis.md
