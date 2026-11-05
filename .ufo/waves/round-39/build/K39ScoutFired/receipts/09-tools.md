# 09 — tools, installs, and what was NOT touched

## Tool installs: NONE.
No package was installed, updated or removed in this seat. The host directive
(/home/vgpnk/.omp/agent/RULES.md) permits installs, but nothing this seat needed was missing:
  git, python3, bash, curl, sed, awk, sha256sum, cmp — all already present.
  $ git --version   -> git version 2.4x (system, Arch)
  $ python3 --version -> system python3 (used via `python3 -I -B`, the lane's own convention)
No `pacman` transaction was run (all pacman transactions are paused by the operator directive).
No PATH directory was touched; nothing was written to ~/.local/bin.

## Not touched (host guard)
  - The lane checkout /home/vgpnk/Projects/shokunin/kagi-shokunin: READ ONLY. Every git call
    used `git -C <lane>` with an explicit revision; no checkout, no commit, no push, no branch
    or worktree change, no jj call.
  - No tracked lane file was modified. `git status --porcelain` in the lane shows only the
    orchestrator's own untracked wave files (.ufo/waves/round-39/…), unchanged by this seat.
  - No fleet-root file (LOG.md, SCORECARD.md, MANIFEST.json, …) was written.
  - No sibling lane was read for writing; the only fleet paths read were the fleet MANIFEST.json
    (read) and /fast/scratch/.../l1/census/*.txt (read).
  - Everything this seat wrote lives under
    /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-39/build/K39ScoutFired/
    plus this seat's report file K39ScoutFired.md in the same directory.
  - Scratch /fast/scratch/hyaku/kagi-r39/K39ScoutFired/ was deleted after the receipts were
    preserved.

## Live network use
  Read-only GETs to five public vendor surfaces (three release feeds, python.org docs, vault/openbao
  docs) with the lane's declared User-Agent, to perform the assignment's "concrete next domain
  recheck". No credentialed endpoint, no POST, no vendor state changed.
