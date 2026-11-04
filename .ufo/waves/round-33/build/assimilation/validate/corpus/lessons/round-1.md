# Lessons — round 1

Round context: `MANIFEST.json` `rounds[1]` — `lanes.kagi: "not-dispatched"`
(round-robin deferral to round 2); the aggregator L1 seeded this corpus from
read-only host inspection. `LOG.md` carried only the round-0 mint line; this
file backfills what round 1 actually taught, reconstructed from seeded corpus
+ MANIFEST on 2026-09-28.

## What worked

- **Read-only seeding is the correct first move for this domain.** Every
  corpus fact came from file reads, `stat`, `the-janitor --help`,
  `the-janitor status`, `the-janitor cdp-bridge status` — zero vault access,
  zero `the-janitor request` calls, no tmux session started (`tmux ls` showed
  only `ufo_sighting`). The domain produced real content without touching
  authorization surfaces.
- **The janitor codebase self-documents its boundaries.** Failure texts
  (`required command not found`, `request text must be supplied on stdin`),
  the `open-popup` refusal, and the `unset` credential strip list are all
  in-line — no external docs needed.

## What failed / got deferred

- **No lane output.** kagi was `not-dispatched`, so SKILL.md stayed the
  12-line seed and `SHONEN.md` sat 0/4 at round-1 close.
- **Index drifted from bytes on disk.** The seeded `corpus/README.md` indexed
  7 entries but only 1 file existed until round 2 — an unverifiable index is
  worse than a small one. Fixed this round; keep README truthful per write.

## Rules extracted (carry forward)

1. Index claims = files that exist. If the README names an entry, it exists.
2. Domain evidence never contains secret values *or* `op://` ref paths —
   shape, modes, and mechanism only.
3. A deferred round still counts as a round: log what *didn't* happen and why,
   citing `MANIFEST.json`, not just successes.
