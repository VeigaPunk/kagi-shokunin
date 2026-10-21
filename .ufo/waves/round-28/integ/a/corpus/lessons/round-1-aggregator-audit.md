# Round-1 aggregator audit — findings and verdicts

Scope: conformance of this corpus against `~/projects/shokunin/CORPUS.md`
(layout, citations, falsifiability) as seeded by the round-1 aggregator,
re-verified in round 2 against the live files (2026-09-28).

## Audit findings

| Corpus rule | Verdict | Evidence |
|---|---|---|
| `corpus/README.md` index + coverage map + gaps | kept, after repair | index named 7 entries but 6 were missing on disk — repaired in round 2, not deleted |
| `knowledge/` cites file/command/URL | pass | every entry names source files with line ranges + read date |
| `lessons/` cites round + evidence | pass after round 2 | `round-1.md` cites `MANIFEST.json rounds[1]`; this file cites CORPUS.md |
| falsifiable or marked opinion | pass | all entries end in a "Falsification" section with runnable checks |
| no generic filler | pass | all content is host-specific (ports, paths, exit codes, exact error strings) |

## Boundary compliance observed

- No `op` vault command was run during seeding or round-2 verification
  (`op --version` only). No `the-janitor request`, no tmux `janitor` session.
- `op.env` (0600, 1078 B) content never read — only path + mode recorded.
- `config.json` (0600, 406 B): round 1 left it unread; round 2 read its
  **key shape only** (types, no values) — it is a second OpenCode overlay
  carrying `provider.qwen-local`, `agent.janitor.options/steps/permission`
  and `$schema`. Nothing in this corpus asserts its values.
- `tac-daybreak-blue.json` read for path/mode only; checksum value lives in
  `handoff-status.json`, already public to the host.

## Residual risk accepted

Line numbers cite the 2026-09-28 read of `the-janitor` (333 lines) and
`client.py` (117 lines); both files carry "re-grep before trusting a number"
warnings — intentional, since script edits would silently stale exact refs.
