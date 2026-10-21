# ScoutMisroot: fleet-root misroot sweep, kagi round 23 (falsification seat)

Seat `KagiR23.ScoutMisroot` (scout, leaf, read-only). I wrote only this file, using the absolute lane path. I moved, copied and deleted nothing in either repo. I sent one peer message, a misroot notice to `KagiR23.ScoutInherited`. No installs, no host gates, no secret or private-config reads, no legacy verify.

## 0. Revisions: the lane moved during the audit

The audit started at lane HEAD `d218603` plus the uncommitted tree. The integrator landed these commits while I was working (reflog `export from jj`, committer times −03:00): `e1884c6` (01:04:19) → `ea5b734` (01:05:47) → `b55e0e7` (01:07:08, "relocated seat reports") → `7af07b4` (01:09:01) → `284d40e` (01:09:41) → `638d44c` (01:11:12) → `def9bc2` (01:11:47).

Final pins are at `def9bc2e12534ae2c2492bae1034eb8122c2c179`. At that point `git diff --quiet HEAD -- corpus/sources-census.sh corpus/closure-dispositions.py corpus/closure-dispositions.json corpus/source-fetches.tsv corpus/claim-ledger.tsv corpus/fixtures` returned exit 0. Each observation below holds only for the sweep or run it names.

## 1. Attack (assigned): untracked fleet-root files that name kagi or round-23

All commands ran from cwd `/home/vgpnk/Projects/shokunin`. Every one exited 0.

| sweep | command | kagi/round-23 lines |
|---|---|---|
| T1 | `git -C /home/vgpnk/Projects/shokunin status --porcelain` | `?? .ufo/state/kagi.report-baseline`, `?? .ufo/waves/round-23/` (directory collapsed, no file named) |
| T1b | `git status --porcelain -uall` | `?? .ufo/waves/round-23/parent-build/ClaimR11X11.md` (+ baseline) |
| T2 | `git status --porcelain -uall \| grep -E 'kagi\|round-23'` | baseline, `falsify/RevS017.md`, `falsify/RevS019.md`, `falsify/ScoutMigration.md`, `parent-build/ClaimR11X11.md` |
| T3 (after `b55e0e7`) | same | baseline only. `ls .ufo/waves/round-23/parent-build/`: No such file or directory |
| T4 | `status --porcelain`, `-uall \| grep` and `--ignored -uall \| grep` | baseline, `?? .ufo/waves/round-23/falsify/ScoutInherited.md`. Ignored paths: only `!! kagi-shokunin/` |
| T5 (final) | `git status --porcelain -uall \| grep -E 'kagi\|round-23'` | baseline only. `find .ufo/waves/round-23 -type f` found no files |

### Findings

**1. `.ufo/waves/round-23/parent-build/ClaimR11X11.md`: seat misroot (parent-build seat ClaimR11X11)**
- Seat's trailer: `Report: write your scoped findings to .ufo/waves/round-23/parent-build/ClaimR11X11.md`.
- At T1 the file was 13006 B with mtime 00:54:00. Its header is `# ClaimR11X11 — audit of claim-ledger row R11-11` and it cites HEAD d218603.
- In the lane at the same time, `ls .ufo/waves/round-23/parent-build/ | grep R11X11 || echo NO_R11X11_IN_LANE` printed `NO_R11X11_IN_LANE`.
- The seat kept writing to the fleet-root path. The file grew to 228 lines / 14187 B, sha256 `642636bd3381e8cb1c0471b9bdf1d98dcaf1becdbfcea6f9e75983858690a43c`.
- **State at T5:** the integrator relocated it in commit `b55e0e7`. The lane copy has sha256 `642636bd…`, so it is **byte-identical**. The fleet copy is gone.

**2. `.ufo/waves/round-23/falsify/RevS017.md`: seat misroot (falsify seat RevS017)**
- Seen at T2 only. I never hashed the fleet copy.
- **State at T5:** the fleet copy is gone. The lane copy is untracked: 14818 B, mtime 01:11:00, sha256 `01dfbb4b…`. Whether it matches the fleet copy is **not established**.

**3. `.ufo/waves/round-23/falsify/RevS019.md`: seat misroot**
- Seen at T2.
- **State at T5:** relocated in `b55e0e7` and tracked. The lane shows it as ` M`, so it was edited after relocation.

**4. `.ufo/waves/round-23/falsify/ScoutMigration.md`: seat misroot**
- Seen at T2.
- **State at T5:** relocated in `b55e0e7` and tracked. The lane shows it as ` M`.

**5. `.ufo/waves/round-23/falsify/ScoutInherited.md`: seat misroot, live at T4**
- At T4: 18688 B, mtime 01:10:47, sha256 `ec20156590aedb1d9932b6c196b5197f6981726793e5c923ff2591f18e84adc1`. The lane path did not exist (`ls` exit 2).
- I messaged the seat. It replied that it rewrote the report at the lane path and removed the fleet copy. That is the peer's statement, not my measurement.
- **State at T5:** the fleet copy is gone. The lane copy is 19264 B, mtime 01:11:58, sha256 `e0ff9e54…`. The seat refined the text, so the two copies are not byte-identical.

**6. `.ufo/state/kagi.report-baseline`: not a seat misroot. This is driver-owned state.**
- The file is 68 B. It contains `23 e3b0c442…b855`: round 23 plus the sha256 of empty input.
- Its mtime is 2026-10-21 00:38:34. The round-23 parent-build wave did not exist yet: the spec's mtime is 00:41 and `parent-build/swarm-registry.json` has createdAt `2026-10-21T03:42:05.695Z` (00:42:05 −03:00). No round-23 seat can have written it.
- All 14 lanes have an untracked file of this kind.
- The fleet driver regression script writes and reads it: fleet `.ufo/waves/kaika-w3/driver-retry-regression.sh:110` and `:155-159`.
- What the empty digest means is defined at `.ufo/waves/kaika-w3/canonical-review.md:273`.
- An earlier closure classified the same kind of file as driver-owned: `.ufo/reports/round-18/tsukuroi.md:135`.
- **State at T5:** untouched. The contract forbids editing `.ufo/state`.

**7. ` M .ufo/watchdog.log`**
- Its name contains neither kagi nor round-23. It is the driver log and is out of scope.

**8. Empty directories `.ufo/waves/round-23/` and `.ufo/waves/round-23/falsify/`: leftovers from relocation**
- `find … -printf '%y %p'` shows two `d` entries and no files.
- No form of `git status` shows them, because git does not list empty directories.
- Older empty `round-21/w1` and `round-17/w1` have the same shape. They are not round-23; I note them only as precedent.
- **State at T5:** left in place. Deleting is forbidden, and they are not mine.

**Count:** across five sweeps I saw **5 distinct seat misroots**: 1 in parent-build and 4 in falsify. By T5 each had been relocated or fixed by its seat, and **0** kagi/round-23-named untracked seat files remained. This is a **lower bound**: a seat that misrooted and was relocated between two sweeps would not show up.

### Cause: measured vs inferred

- **Measured: the instructions cannot explain which seats misrooted.**
  - Both wave contexts state the lane anchor. `parent-build-dispatch.json` taskCall.context says: "Every Report: trailer is RELATIVE TO /home/vgpnk/Projects/shokunin/kagi-shokunin". The `falsify-dispatch.json` context says: "write it at /home/vgpnk/Projects/shokunin/kagi-shokunin/<that path>".
  - The anchor also appears in the task text of every seat I checked. That covers both misrooted seats (ClaimR11X11, RevS017, RevS019, ScoutMigration, ScoutInherited) and clean ones (ClaimR11X10, RevS018, ScoutMisroot).
  - Every trailer is the bare relative path `.ufo/waves/round-23/<wave>/<Seat>.md`.
  - Both specs set `reportDir` to a relative path.
- **[INFERENCE] Likely mechanism: the seat harness runs with the fleet root as cwd.**
  - This seat's own session cwd is `/home/vgpnk/Projects/shokunin`. A seat that resolves the relative trailer against cwd writes into the fleet root.
  - The fleet `.gitignore:1` rule `*-shokunin/` hides the lane from the fleet repo (`git check-ignore -v kagi-shokunin` exit 0). A correct write therefore never shows in the fleet sweep; only misroots do.

### Bounds the closure must state

1. The assigned command on its own (`status --porcelain` without `-uall`) prints only `?? .ufo/waves/round-23/`. It names no file and no seat; attributing seats needed `-uall`.
2. `git status` cannot see leftover empty directories or files under fleet-ignored paths. At T4, `--ignored -uall` showed no kagi/round-23 file beyond `!! kagi-shokunin/`.
3. Misroots are transient because they get relocated mid-wave. "Zero misroots" is true only for a sweep run after the last seat lands, and the 5-seat count is a lower bound.
4. Byte-identical relocation is proven only for ClaimR11X11. The RevS019, ScoutMigration and ScoutInherited lane copies were edited after relocation. The RevS017 fleet copy was never hashed.

## 2. Side measurements of C1/C2/C3 (taken during the sweep; time-bound, outside the assigned question)

### C2: transient census crash, removed before any commit
- The first run of `bash corpus/sources-census.sh` exited 1 with empty stdout. Stderr was `corpus/sources-census.sh: line 242: S007: unbound variable`.
- `env -i PATH=/usr/bin:/bin bash corpus/sources-census.sh` gave the same result, exit 1.
- `bash -x` showed `SUPERSEDED[$fid]=1` with `fid=S007`: the array was never declared, so the line aborted under `set -u`.
- In the same tree state, `--selftest` printed `PASS (59 cases)` with exit 0. So no selftest case reached the supersedes path; a crash would have failed that case's finding-id check.
- The loop is absent from `e1884c6` and `ea5b734` (`git show <rev>:corpus/sources-census.sh | grep -c SUPERSEDED` printed 0 for each). It is also absent from the final file, which is identical to `def9bc2` (`grep -c supersedes` printed 0).
- **Not a current defect.** Bound: a green R21-03 (selftest) is not evidence for R21-02 (verify). A crash exits 1 with no verdict line, so R21-02's anchored regex catches it; it cannot produce a false clean.

### C2 at the final pin
- `bash corpus/sources-census.sh` exited 0, and its line matches R21-02 (`grep -Eq` exit 0). `--selftest` printed `PASS (59 cases)`, exit 0.
- The 10 provenance rows cover **9** distinct registered URLs: S021 and S026 share `openbao.org/docs/concepts/tokens/`.
- The wave context `.ufo/waves/round-23/falsify-spec.json:3` still says "over 7 URLs". That is wrong. `corpus/lessons/round-23.md:174` now says nine; the pre-commit tree said seven.
- I re-fetched all 9 URLs with the declared profile, `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`. Every curl exited 0.
  - Raw sha256 and byte count matched exactly for S017, S018, S019, S021/S026, S022, S023, S024 and S025.
  - S020's raw digest differed (`ee9c6ca4…` vs declared `53dfeac5…`, both 190261 B). Its normalized digest `20b4fd86…` matched.
  - The rendered-text-v1 normalized digests matched for all 9 URLs.
  - All 10 quotes appear in the rendered text. All 10 row-identity digests recompute (python `hashlib`), and every quote is ≤ 22 words.
- **Bounds:**
  - This is same-day reproduction only.
  - All 10 rows are declared `decoded-http-body-volatile-v1`, but 8 of the 9 URLs were byte-stable. Volatility is declared, not measured.
  - `location` is only checked for length ≥ 8 (`corpus/sources-census.sh:274`), not for correctness. S022's location read "JWT verification, Vault 1.17 note" in the first tree and "Introduction, Vault 1.17 Note" later; both pass. The quote actually sits in an introduction Note callout under the H1 "Use JWT/OIDC authentication".

### C1
- `python3 corpus/closure-dispositions.py` exited 0, and its line matches R23-02 (`grep -Eq` exit 0). The final output line is identical.
- The selftest printed `PASS (13 cases)` on the first run and `PASS (14 cases)` at the final pin, after `pointer-symlink` was added. The wave's "selftest 13" is out of date.
- No ledger row pins the C1 selftest count: `grep -n closure-dispositions corpus/claim-ledger.tsv` returns only `:60` (R23-02).
- D9's `fixed` pointer moved from `corpus/claim-ledger.tsv` to `corpus/fixtures/cells-hermetic/SCORECARD.md`. Line 1 of that file is `<!-- D9: hermetic cells fixture; rows are declared in claims.tsv -->`.
- So POINTER-ID is satisfied by a comment that just names the id. That matches the bound stated at `corpus/closure-dispositions.py:44`: `fixed=7` means 7 records that resolve, not 7 verified fixes.

### C3
- The exact R23-01 command exited 0, and its last line matches the R23-01 regex (`grep -Eq` exit 0) at both the first and the final pin.
- I ran a manual mutant: a temp copy with one `# no-enumerate` line deleted. It exited 1 with `FAIL R90-02 reason=verdict-not-final`, `STALE-POINTER corpus/adjacency.tsv` and `CELL_AUDIT: BROKEN (… row_failures=1 stale_pointers=1 …)`.
- The mutant result reproduced before and after the fixture edits. Running from the lane as cwd gave the same result; the lane's own `corpus/adjacency.tsv` (5660 B) is not read.
- **Bound:** no committed mechanism runs that mutant (`grep -ln cells-hermetic corpus/*.sh corpus/*.py` exit 1). "A fixture mutation fails" (`corpus/lessons/round-23.md:62`, `plans/round-23.md:38`) rests on manual or seat runs, not on a ledger row or selftest case.

## 3. Not done

- I did not move, copy or delete any fleet-root file, did not edit `.ufo/state`, and left the empty directories in place.
- I did not re-audit the parent's 43 ledger rows or run any host-bound row.
- Whether the RevS017 fleet copy matched its lane copy cannot be known now; the fleet copy was removed before I hashed it.
- My own /tmp scratch (re-fetched bodies, a census copy, mutant copies) was removed after this report was written.
