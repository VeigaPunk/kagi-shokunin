# kagi-shokunin — round-1 deferral & seed lessons (aggregator-authored)

Round: 1, written by the **aggregator L1** on 2026-09-28 and amended after the
round-2 kagi lane landed (`9b3e49f`). Kept separate from
`lessons/round-1.md` (kagi-lane authored) so neither writer clobbers the other —
see "Lesson 5" for why that separation is now a rule.

## Evidence

- `~/projects/shokunin/MANIFEST.json` → `rounds[1].lanes.kagi =
  "not-dispatched"`; `rounds[1].notes` ends "kagi deferred by round-robin to
  round 2".
- `.ufo/waves/round-1.json` → `items[]` holds six lanes (kasegi, kengaku, kake,
  kumitate, kotoba, protocol); no kagi item.
- `~/projects/shokunin/.ufo/watchdog.log` → `2026-09-28T15:50:56-03:00 launch
  kagi round=1`, then `15:52:38 steer kagi -> round 2 via
  m_574d9f1f956e499dabaa59de9834bdc0`; `MANIFEST.json` `rounds[]` entry
  `"round": 1.5, "type": "ops"` records "kagi-shokunin lane joined … fleet now
  8 L1s".
- `kagi-shokunin/LOG.md` at round-1 close → header + round-0 mint line only, no
  round-1 entry (correct: no lane ran).
- `kagi-shokunin/SKILL.md` at round-1 close → 12-line seed stub ("Shonen seed.
  Develop: decision tables, error patterns, production checklists,
  anti-patterns, cited sources"); `SHONEN.md` 0/4 boxes.

## Lesson 1 — deferral must not mean zero memory

A deferred lane leaves its domain with no corpus, so the next lane re-discovers
the same surfaces from nothing. Fix applied: the aggregator seeded `corpus/`
from **read-only inspection** of the domain's real surfaces
(`~/.local/bin/the-janitor`, `~/.local/bin/tac-check`,
`~/.config/the-janitor/{client.py,opencode.json}`,
`~/.config/opencode/agents/janitor.md`, `stat` on the state dirs). No vault
access, no `op` invocation, no handler start (`tmux ls` at seed time showed only
`ufo_sighting`). Falsifier: any `knowledge/` fact that cannot be re-derived from
those files with the cited command means the seed was fabricated — grep it.

Outcome (observed, round 2): the kagi lane consumed the seed instead of
re-walking the host — `LOG.md` round-2 entry cites the same five surfaces plus
two the aggregator did not read (`~/.config/opencode/tools/janitor_auth.ts`,
`~/.config/the-janitor/config.json` key-shape only) and rewrote `SKILL.md` from
12 → 104 lines in one round.

## Lesson 2 — a secrets corpus stores mechanisms, never material

`knowledge/op-env-refs.md` records the *shape* of the vault-ref env file and the
`the-janitor refs` redaction rule, and deliberately omits both values **and**
`op://` ref paths (refs carry vault + item UUID + field name). A corpus is a
durable artifact that may later be published or fed to a model. Marked POLICY
(opinion) in that entry, with its premise stated so it can be argued with. The
round-2 lane independently adopted the same rule (`LOG.md`: "No vault access, no
secret values, no ref paths recorded"), which is the strongest available signal
that the rule is domain-correct rather than one writer's preference.

## Lesson 3 — the cheap end-to-end task was real, and it got run

At seed time this was a **code-read inference**: `the-janitor status`,
`the-janitor refs`, and `the-janitor tac-check` looked like free, offline,
non-mutating probes (`cmd_status` never calls `ensure_started`; `cmd_refs` reads
one file and redacts literals; `tac-check` does sha256 + field comparison with
no network). The aggregator did not execute them — a fresh subagent must not do
vault work.

Round 2 confirmed part of it by execution (`LOG.md` round-2: live probes
`the-janitor status` → `state stopped`, `cdp-bridge status` → `nmh present, cdp
down`, `op --version` → `2.35.0`). Still unexercised: `the-janitor refs` and
`tac-check`, and the real end-to-end item — one `the-janitor request` against a
benign prompt. That last one is what `SHONEN.md` box 2 actually needs.

## Lesson 4 — index truth beats index size

The seeded `corpus/README.md` named 7 entries while only some existed on disk;
the kagi lane's audit (`lessons/round-1-aggregator-audit.md`) records the
drift and the repair. Rule extracted: an index row is a claim — write the row
when the file lands, not before. This is filed fleet-wide as a `CORPUS.md`
amendment proposal in
`~/projects/shokunin/.ufo/reports/round-2/AGGREGATE.md`.

## Lesson 5 — concurrent writers in one `corpus/` need a namespace

This file exists because of a real collision: the aggregator wrote
`corpus/lessons/round-1.md` at 15:56 while the kagi lane wrote and committed its
own `corpus/lessons/round-1.md` at 15:56:42 (`9b3e49f`). One writer's bytes won
the working tree; the lane's committed version was restored with
`git checkout -- corpus/lessons/round-1.md` and the aggregator's content moved
here. Convention proposed: **lanes own `lessons/round-<N>.md`; the aggregator
writes only `lessons/round-<N>-aggregator-*.md`**, and never edits a
lane-authored corpus file in place — corrections are filed as new aggregator
entries (same append-only discipline `PROTOCOL.md` gives `LOG.md`).

## Gaps filed for the next round

1. One real `the-janitor request` round-trip (benign prompt) logged as
   trigger → action → outcome → pointer: the missing `SHONEN.md` box 2.
2. `the-janitor refs` + `tac-check` outputs captured (metadata only) to close
   the unexercised-probe gap.
3. Rotation/revocation practice: no evidence found in any inspected surface.
4. Shared-browser ownership with the kake province (CDP 9222 + musketeer
   profile): contested scope, reported to the integrator per `PROTOCOL.md`
   "Invariants", not absorbed.
5. Dormancy watch: `PROTOCOL.md` flags dormancy after two consecutive completed
   rounds with no `LOG.md` activity. Round 1 had none for kagi; round 2 landed
   one, so the counter is reset — but only if the integrator records round 2 as
   a completed round for kagi.
