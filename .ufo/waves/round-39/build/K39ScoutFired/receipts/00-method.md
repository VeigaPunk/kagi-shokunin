# K39ScoutFired — receipts index

Scratch (single extraction, deleted after this report):
`/fast/scratch/hyaku/kagi-r39/K39ScoutFired/`
  ext/       candidate 6742fdef0e261dd06a38a0fb0b66b1bc027d1bee (git archive, one extraction)
  base/      BASE overlay 06144518d3b3745e7fdf82d4207b4a3b5532a7a7 (ext/ with BASE blobs for the
             17 changed paths; every changed file verified sha256-identical to `git show BASE:path`)
  pre/       predeclaration overlay 1909e3876341cc90246516886def37a7c9ea92f9 (same method; 8 files verified)
  mut/       candidate + one in-place SOURCES.md anchor rewrite each
  live/      live vendor fetches (2026-11-05), read-only

`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse --show-toplevel`
  -> /home/vgpnk/Projects/shokunin/kagi-shokunin   (all git reads used `git -C <lane>`; no mutation)
No clone was made. No commit, no push, no git/jj state change. No tool was installed (see 09-tools.md).

Command transcripts: 01-counters.md, 02-instruments.md, 03-mutants.md, 04-repoint.md,
05-ledger.md, 06-sweep.md, 07-live.md, 08-plan-provenance.md, 09-tools.md
