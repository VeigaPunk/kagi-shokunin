# R58MutCounter — instrument pins and bases

## Tested instruments (lane, read-only)

| revision | checker sha256 | wrapper sha256 | base | result |
|---|---|---|---|---|
| **primary** `6b9c0c9d` (lane at 12:38) | `6b9c0c9d25149a0115eee3d8b952d5c00f6f7dbc93eabb20116a55a3a5145586` | `48eab526ff9bb8c10a7ed9462addafe9f035223f835c7540c0b044e958df0d15` | `cand04` | 8/8 killed; survivor probes killed |
| `59f6eba4` (12:35, reviewer-hardened) | `59f6eba46b9f0c1721ae65fb3d1732a25a24d99d23da51b70cfb109bb28522d8` | same | `cand04` | 8/8 killed; S1-S3 survived |
| `d37829c0` (executor-pinned) | `d37829c017aabe789336c853bb09604d0c30978c84914a20a2d4de185040c77f` | same | `cand03` | 8/8 killed; S1-S3 survived |

Copies kept here: `round-58-c1-check.6b9c0c9d.py`,
`round-58-c1-check.59f6eba4.py`, `round-58-c1-check.d37829c0.py`,
`round-58-c1.48eab526.sh`. Earlier drafts observed while the executor wrote (not
tested): `round-58-c1-check.py.pin` (1218b23e…), `round-58-c1-check.ff38d690.py`
(content `410b05e7…`), `round-58-c1.9cfa9c89.sh`.

## Base trees

- `cand04` — full rsync snapshot of the lane worktree, excluding `.git` and all
  `.ufo/waves/*` except rounds 56, 57, 58. Round 56 is required by the I6
  `--round` probe, which runs the tree's `current-claims.py` over round 56.
  Per-file sha256: `BASE-cand04-pins.txt`.
- `cand03` — same but without round-56 waves; used with `d37829c0` (no probe then).
  Per-file sha256: `BASE-cand03-pins.txt`.

Lane key-file hashes at both snapshots are in those files
(`SCORECARD.md 4488e18b…`, `LOG.md d7d39772…`, `SKILL.md c0a51626…`,
`corpus/current-claims.py 6f3a5324…`, `corpus/adjacency.tsv 5b921893…`,
`corpus/lessons/round-57.md a00b462d…`, `corpus/SOURCES.md 7e4b5c88…`,
`controls-prefreeze-epochC-final.txt f9f0d488…`).

## Patch bundles (verified; historical derivation for the two earlier pins)

| bundle | for | sha256 | verification |
|---|---|---|---|
| `checker-patched.8a2fa2e1.py` | `59f6eba4` | `8a2fa2e13cf3b92aa1385e44db95bb2beebbd0c04c8866d99e0984d67d2150c3` | base value=0 guard=1; probes x1/x2/x3 value=1 with i3/i5/i1=0 (`c4p-*.out`) |
| `checker-patched.58e530b2.py` | `d37829c0` | `58e530b21f32f0f7857b992da5a22604db9320d622dbbd89acba90521818e389` | base value=0 guard=1; probes value=1 with i3/i5/i1=0 (`c3p-*.out`) |

`6b9c0c9d` already carries equivalent bindings (lines 253-254, 314, 401-405), so no
bundle is pending for the final bytes.

## Tools

`tools/drive.py` (mutations), `tools/run_battery.py` (parallel battery),
`tools/audit.py` (independent literal audit), `tools/mutate.py` (earlier harness).
No host tool was installed, upgraded or reconfigured; no pacman/uv/npm operation.
