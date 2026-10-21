# RevClaimsTsv — round-23 falsification: claim-ledger R23-01/R23-02 and gate policy safety

Seat: reviewer (falsification), leaf. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Read-only except this report. No production edits, no git/jj mutation, no host gates, no secrets.

## Snapshot — premise drift (read this first)

The assignment premise was "base `d218603` plus the uncommitted round-23 tree". That is no longer
the state. The lane advanced HEAD **nine commits** while this review ran:

```
$ git log --oneline d218603b74099ddca0bd8f869516fc41db0979bf..HEAD | wc -l
9
$ git log --oneline d218603b74099ddca0bd8f869516fc41db0979bf..HEAD | head -3
57776b2 round-23: W04 base/end wording, skip semantics, D4 tuple names
58bd8d7 round-23: D3 reported, W04 seven, selftest-adequacy bounds
def9bc2 round-23: lead disposition, frontier/correction row wording
```

HEAD at report time: `57776b2859638d3af26d5443e7fc4b54131b6eab` (2026-10-21 01:18:44 -0300).
This was HEAD `58bd8d7` (01:16:35) at the start of the final pass and `57776b2` by the end; the
measured paths are clean against `57776b2` (`git status --porcelain -- <measured paths>` empty) and
their blobs hash to the table below. Every number is hash-anchored; files changed during
measurement (`round-23.md` changed at least five times between 01:06 and 01:19). Do not re-anchor
any claim below onto a different commit.

The lane kept committing after the final pass (`31f24e0` at 01:22, `d736adf` and then `3f9fe72` by
the last re-check, with `claim-ledger.tsv`, `closure-dispositions.py` and `round-23.md` dirty
again). Verified at those commits with `git cat-file -p HEAD:<path> | sha256sum`:
`claim-ledger.tsv`/`closure-dispositions.json`/`closure-dispositions.py` held the measured blobs
until the `3f9fe72` worktree; `round-23.md` kept moving (`cfb4d5e9…` → `0ffe6568…` → `130d70e0…`)
but kept the full fixture path at `:165` and the same two pre-existing round-22 unresolved tokens.
A final re-run on the `3f9fe72` dirty worktree (`claim-ledger.tsv` `87e0217d…`,
`closure-dispositions.py` `8cfaa52f…`) printed the same three CLEAN verdict lines shown in §1,
exit 0, with both expect EREs matching the current rows. Re-pin to the commit you score.

Artifact hashes at the final measurement pass (sha256, abbreviated):

| Artifact | sha256 | Note |
|---|---|---|
| `corpus/claim-ledger.tsv` | `ed125ca5…` | identical to the HEAD 57776b2 blob |
| `corpus/claim-ledger.sh` | `c20c2d04…` | unchanged since 00:53; policy code in this report is this blob |
| `corpus/closure-dispositions.py` | `d79b08a7…` | selftest now **14** cases, not 13 |
| `corpus/closure-dispositions.json` | `67ac1a42…` | 15 dispositions: 5 no-action / 3 reported / 6 fixed / 1 operator-owned |
| `fixtures/cells-hermetic/SCORECARD.md` | `23583252…` | committed |
| `fixtures/cells-hermetic/claims.tsv` | `1a073771…` | committed, TAB-separated data fields |
| `fixtures/cells-hermetic/stamps.tsv` | `401ebb3c…` | fixture-local, 2 rows |
| `fixtures/cells-hermetic/corpus/adjacency.tsv` | `fa15a53c…` | 9 lines / 307 B, matches fixture stamps |
| `fixtures/cells-hermetic/corpus/fx-ok.sh` | `29f98fba…` | 2 lines / 38 B, matches fixture stamps |
| `corpus/lessons/round-23.md` | `4e971e3d…` | measurement pass; later revisions `cfb4d5e9…`/`0ffe6568…` kept the fixed citation at `:165` (see F1) |

## What I attacked

1. `corpus/claim-ledger.tsv:59` (`R23-01`, hermetic `cells`) and `:60` (`R23-02`,
   `closure-dispositions.py`) — byte-exact last-line verdicts, exit codes, and expect matches.
2. The gate's own policy logic — extracted verbatim from `corpus/claim-ledger.sh:160-192`
   (`ALLOWED_RE` :160, `PYTHON_SCRIPT_RE` :161, `META_RE` :163, `DENY_WORD_RE` :167,
   `policy_check` :170-192) — against near-miss commands.
3. Host-default routing: flags `--claims` :200, `--stamps` :199, `--scorecard` :201,
   `--docs` :202, `--root` :203; defaults `STAMPS=$SCRIPT_DIR/stamps.tsv` and
   `CLAIMS=$SCRIPT_DIR/claim-ledger.tsv` (:104-105), `SCORECARD="$ROOT/SCORECARD.md"` (:240);
   row execution `cd "$ROOT" … bash -c "$cmd"` (:426); `cells` self-skip (:816);
   mutating `stamp()` (:243-303, output default :244, `mv` :300).
4. A command that reads a real host path / host defaults, plus the gate's own mutating mode.

## Exact measurements, commands, exits

### 1. R23-01 and R23-02 pass byte-exactly on the measured snapshot

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --claims corpus/fixtures/cells-hermetic/claims.tsv \
    --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
    --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
    --docs corpus/fixtures/cells-hermetic/SCORECARD.md
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
EXIT=0

$ printf '%s\n' "$out" | grep -qxE "$(awk -F'\t' '$1=="R23-01"{print $3}' corpus/claim-ledger.tsv)"
exit 0
```

```
$ python3 corpus/closure-dispositions.py
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)
EXIT=0

$ printf '%s\n' "$out2" | grep -qxE "$(awk -F'\t' '$1=="R23-02"{print $3}' corpus/claim-ledger.tsv)"
exit 0
```

Re-ran after the 01:03 fixture re-stamp and again at 01:16; the CLEAN lines and exits were stable.
Fixture stamp rows reproduce against the bytes on disk (`sha256sum`, `wc -l/-c`):
`fa15a53c… 9/307` and `29f98fba… 2/38` match `stamps.tsv:1-2`.

```
$ grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv
45        # R21-04 (claim-ledger.tsv:54) still holds after adding R23-01/R23-02
```

### 2. Policy matrix — the gate's own `policy_check`, not a paraphrase

```
$ eval "$(sed -n '160,192p' corpus/claim-ledger.sh)"; type -t policy_check
function
```

Results (the function prints its refusal class; `ALLOW` means exit 0):

```
ALLOW  | bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims …/claims.tsv --stamps …/stamps.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md   (R23-01)
ALLOW  | python3 corpus/closure-dispositions.py                                                                                                                       (R23-02)
ALLOW  | bash corpus/claim-ledger.sh cells
ALLOW  | bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic
ALLOW  | bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --scorecard …/SCORECARD.md --docs …/SCORECARD.md
ALLOW  | bash corpus/claim-ledger.sh stamp corpus/fixtures/cells-hermetic/corpus/fx-ok.sh
ALLOW  | bash corpus/claim-ledger.sh stamp --prune corpus/claim-ledger.tsv
ALLOW  | bash corpus/claim-ledger.sh stamp --out /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/stamps.tsv corpus/x
ALLOW  | bash corpus/claim-ledger.sh cells --claims /home/vgpnk/.local/state/claims.tsv --stamps /home/vgpnk/.local/state/stamps.tsv
ALLOW  | bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh cells
REFUSE[python-script] | python3 corpus/other.py
REFUSE[denied-verb:op] | grep -q op corpus/claim-ledger.tsv
REFUSE[metachar] | bash corpus/claim-ledger.sh cells; rm -f corpus/x
```

Control refusals fire, so the guard is real; but it never inspects the *paths or flags* a `bash`
row passes, and it never checks that a `cells` row names its four inputs.

### 3. Flag-omission attack — host defaults are reachable and read

With `--root` on the fixture but `--claims`/`--stamps` omitted, the gate falls back to the live
repo files (`claim-ledger.sh:104-105`), and the policy above allows it:

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
    --docs corpus/fixtures/cells-hermetic/SCORECARD.md
MISSING-ID SCORECARD.md:8 R90-01
MISSING-ID SCORECARD.md:8 R90-02
…
claim-ledger: no cell in corpus/fixtures/cells-hermetic/SCORECARD.md cites a claim row (nothing to re-run; the audit would be vacuous)
EXIT=2

# strace of that run (openat):
openat(AT_FDCWD, "/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv", O_RDONLY) = 3
openat(AT_FDCWD, "/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/stamps.tsv", O_RDONLY) = 3
```

Omit only `--stamps` (fixture claims/scorecard/docs kept):

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --claims …/claims.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md
STALE-POINTER corpus/adjacency.tsv sha=4d9bfb1145aa->fa15a53c7e58 lines=83->9 bytes=5660->307
CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=1 … stale_pointers=1 …)
EXIT=1
```

It read the live `corpus/stamps.tsv` (`openat` observed) and compared the fixture file against the
live `corpus/adjacency.tsv` pin (`stamps.tsv:9`). Omit `--docs` (fixture-rooted):

```
$ bash corpus/claim-ledger.sh cells --root … --claims … --stamps … --scorecard …
claim-ledger: doc not found: corpus/fixtures/cells-hermetic/AGENTS.md
EXIT=2
```

Omit `--scorecard` only: it defaults to `$ROOT/SCORECARD.md` (`claim-ledger.sh:240`), i.e. the same
fixture file, and prints the identical CLEAN line, exit 0. So the pinned R23-01 line does not
actually require `--scorecard`; it requires `--root`, `--claims`, `--stamps`, `--docs`.

**Every omission shape fails closed on the current tree** (exit 2 / exit 1 / exit 2), so there is
no false CLEAN today. But the policy check itself cannot tell a hermetic invocation from a
host-mixing one: the only guarantee is the literal row text plus the exact expect line. A future
fixture that reuses live row ids would let a near-miss pass while running fixture-rooted commands
against the live ledger/stamps. This is a policy gap, not a defect in R23-01 as written.

### 4. `bash corpus/claim-ledger.sh cells` with no flags is policy-clean

The full host-default invocation (live claims, live stamps, live scorecard, live docs) is ALLOWed
by `policy_check`. I did **not** execute it: `cells_evidence` would re-run the live scorecard's
cited rows, including `[substrate]` rows, and `substrate_present` reads
`$HOME/.local/bin/the-janitor` (`claim-ledger.sh:143-149`). Policy acceptance is measured; live
execution is deliberately unrun (host-bound rows are out of bounds for this seat).

### 5. The gate's own mutating mode is policy-clean

`stamp()` rewrites `corpus/stamps.tsv` (default `$SCRIPT_DIR/stamps.tsv`, `:244`) via
`mv -- "$STAMP_TMP" "$out"` (`:300`); `--out` accepts an absolute path (`:204`). The two `stamp`
commands in the matrix above are ALLOWed. No current claim row invokes `stamp`; `cells` skips any
row containing `claim-ledger.sh` (`:816`), but `verify` would run it (`verify_claims` :400-437).
This is a pre-existing execution-surface gap, not introduced by round 23, but R23-01's "no host"
claim rests on this same policy. I did not execute any mutation.

### 6. Exact-row hermeticity: no host reads, no network — with one wording caveat

`strace -f -e trace=%file,%network` on the exact R23-01 command (fixture hashes above):

- successful `openat` calls are only repo-relative: the gate, fixture `claims.tsv`,
  `SCORECARD.md`, `stamps.tsv`, `corpus/fx-ok.sh`, `corpus/adjacency.tsv`, plus `/tmp` scratch
  from `mktemp` (`cells_evidence`);
- **zero** `socket(`/`connect(` syscalls;
- no `the-janitor` access (fixture rows carry no `[substrate]` tag, so `substrate_present` is not
  called);
- **no successful `openat` under `/home/vgpnk` outside the repo**. However, command lookup does
  probe `$HOME` and the fnm session dir via inherited PATH, all ENOENT:

```
execve("/home/vgpnk/.local/share/fnm/bash", …) = -1 ENOENT
execve("/home/vgpnk/.opencode/bin/bash", …) = -1 ENOENT
execve("/home/vgpnk/.local/bin/bash", …) = -1 ENOENT
execve("/home/vgpnk/.grok/bin/bash", …) = -1 ENOENT
execve("/run/user/1000/fnm_multishells/…/bin/bash", …) = -1 ENOENT
```

So "no real host path is read" (lesson C3) is accurate at the read/open level. "no `$HOME`"
(`claim-ledger.tsv:59` note) is literally false at the lookup level: the run's command resolution
touches `$HOME` paths, and would resolve an earlier-PATH `bash`/`grep` from `$HOME` if one existed.
Phrase it as "no `$HOME` state is read or depended on", or scrub PATH in the fixture run.

### 7. C1 corroboration (independent of the script's own verdict)

```
15 dispositions, 15 unique ids: SPOT-01..05, ADJ, D1..D9
counts: no-action 5, reported 3, fixed 6, operator-owned 1, rejected 0
source = corpus/lessons/round-22-verifier-spotcheck.md
declared source_sha256 = 65a5b3de… = actual sha256, match True
all pointer paths exist; every "fixed" pointer's target text contains the obligation id
$ python3 corpus/closure-dispositions.py --selftest
CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)      EXIT=0
```

The substantive claim holds: 15 obligations, one typed disposition each, pointers resolve, source
digest pinned. Two drifts from the assignment text: the current split is **6 fixed / 3 reported**
(D3 moved to reported in `58bd8d7`) and the selftest is **14** cases, not 13. The row's expect
(`claim-ledger.tsv:60`) matches the current output exactly.

Limitation (already stated by the claim, "records existence, not fix quality"): 4 of 6 fixed
dispositions share the single pointer `corpus/lessons/round-23.md#Routed defect dispositions`, and
the resolver accepts the obligation id anywhere in the file (`closure-dispositions.py:106-122`),
not in the anchored section. Existence is proven; per-obligation evidence is not.

### 8. Committed-ness, now true

At base `d218603` the fixture did not exist (`git cat-file -e d218603:…/claims.tsv` → exit 128).
At HEAD `57776b2` the fixture is committed (`git cat-file -e HEAD:…/claims.tsv` → exit 0) and the
worktree fixture bytes equal HEAD (`git status --porcelain -- corpus/fixtures` empty). The row's
word "committed" is now true; it was not true when the review began.

### 9. Citations regression observed, then fixed under me

At worktree hashes `993e114a…` / `49632920…`, `corpus/lessons/round-23.md:159` cited
`corpus/fx-ok.sh` (not a file; the fixture copy is
`corpus/fixtures/cells-hermetic/corpus/fx-ok.sh`):

```
$ bash corpus/claim-ledger.sh citations        # at lesson sha256 49632920…
UNRESOLVED corpus/lessons/round-23.md:159 corpus/fx-ok.sh (local)
CITATION_GATE: BROKEN (cites=1258 docs=65 unresolved=3 ephemeral=0 labeled=14)
EXIT=1
```

That token is absent at HEAD `57776b2` (`git show HEAD:corpus/lessons/round-23.md` line 165 has
the full fixture path). The gate still exits 1, now on two pre-existing tokens only:

```
$ bash corpus/claim-ledger.sh citations        # lesson sha256 4e971e3d…, before==after
UNRESOLVED corpus/lessons/round-22-verifier-spotcheck.md:53 corpus/lessons/round-18.md','LOG.md'] (local)
UNRESOLVED corpus/lessons/round-22-verifier-spotcheck.md:62 .ufo/waves/round-22/frozen/before/ (ufo)
CITATION_GATE: BROKEN (cites=1258 docs=65 unresolved=2 ephemeral=0 labeled=14)
EXIT=1
```

(The same two-token result was measured earlier at lesson `ae29c16c…`; the final stable run above
is at `4e971e3d…`, HEAD 57776b2.)

Those two lines are byte-identical at `d218603` and at HEAD (both `git show` blobs hash
`65a5b3de…`, which is also the closure-dispositions source digest). They are not round-23
regressions; they still make existing row `claim-ledger.tsv:22` (`R11-08`, expect
`CITATION_GATE: CLEAN`) unpassable on this checkout. I did not run the base gate (would need a
checkout/git mutation), so "already red at base" is `[INFERENCE]` from unchanged bytes and an
unchanged classifier (`claim-ledger.sh:458-470`); the row is certainly red at the measured tree.

## Findings, by severity

**F1 — MEDIUM, resolved by HEAD 57776b2 (was live at `def9bc2`).** The landed `def9bc2` lesson
carried an unresolvable citation `corpus/fx-ok.sh` at `corpus/lessons/round-23.md:159`, which flips
existing row `corpus/claim-ledger.tsv:22` (`R11-08`) red. The HEAD now cites the full fixture path
(`round-23.md:165` at `57776b2`; the line moved 159→162→165 as the lesson was edited) and the
round-23 token is gone. Action: keep the full path; do not resurrect the shorthand. The two
remaining `citations` failures are round-22/agent-tree issues (F1b, out of round-23 scope:
`round-22-verifier-spotcheck.md:53,62`, unchanged since base).

**F2 — MEDIUM, live (policy does not enforce explicit inputs).** `policy_check`
(`claim-ledger.sh:170-192`) accepts any `bash <script> <args>` that clears token/metachar/deny
checks; it does not require `--claims/--stamps/--scorecard/--docs`. Defaults (:104-105, :240)
point `--claims`/`--stamps` at the live repo whenever `--root` is a fixture. Measured: the
near-miss is ALLOWed and the run `openat`s the live `corpus/claim-ledger.tsv` and
`corpus/stamps.tsv` before failing closed (exit 2 with `--claims` omitted; exit 1 STALE-POINTER
with `--stamps` omitted). R23-01 is not falsified — all omissions fail today — but its hermeticity
is guaranteed by its row text plus the exact expect, not by the gate. A fixture reusing live row
ids would let a mixed-root run pass GREEN.

**F3 — MEDIUM, live (mutating mode allowlisted).** `bash corpus/claim-ledger.sh stamp …`
(including `--prune` and an absolute `--out`) is policy-clean and `stamp()` rewrites the pin file
(:244, :300). No current row exploits it, and `cells` self-skips gate-invoking rows (:816), but
`verify` would execute it. Pre-existing; it bounds the same "no host/no mutation" guarantee that
R23-01 relies on. Not executed.

**F4 — LOW, wording.** The row note's "no `$HOME`" is false at lookup granularity: inherited PATH
makes `execve`/`stat` probe `$HOME/.local/bin`, `$HOME/.opencode/bin`, etc. (all ENOENT), though no
`$HOME` file is opened and no network syscall occurs. The lesson's "No real host path is read" is
accurate.

**F5 — INFO, process.** HEAD moved nine commits during the review (d218603 → 57776b2); the "base +
uncommitted" premise, plus the prompt's C1 counts (fixed=7/reported=2, selftest 13), are stale
against `57776b2` (fixed=6/reported=3, selftest 14). At the final pass the measured paths were
clean against `57776b2`; earlier passes saw dirty/untracked states. Re-pin the wave to a commit
before scoring claims.

**F6 — INFO, bound.** C1's pointer closure is an existence check with a shared-anchor fan-out
(4/6 fixed → one heading); the claim says so ("records existence, not fix quality"), so no
falsification, only a limit on what pointers=15 proves.

## Verdict

- R23-01: **not falsified.** The exact command, run against the committed fixture at the measured
  hashes, prints the pinned `CELL_AUDIT: CLEAN` line, exit 0; the expect ERE matches byte-exactly;
  the fixture is stamp-consistent; the run has no host reads and no network syscalls. The
  hermeticity claim is true as executed and false only as a policy guarantee (F2/F3/F4 bounds).
- R23-02: **not falsified.** `obligations=15`, 15 unique typed dispositions, digest match,
  pointers resolve, selftest PASS; current counts are 6/3 not the prompt's 7/2.
- F1 was a real round-23 citation regression at `def9bc2`; it is fixed at HEAD `57776b2`
  (first corrected in `58bd8d7`), but the pre-existing round-22 citation debt keeps `R11-08` red,
  so the full ledger cannot be GREEN on this checkout.

## Residual risk / verification gaps

- I did not run `claim-ledger.sh verify` (forbidden: re-runs host-bound rows), bare
  `claim-ledger.sh cells` (would re-run the live scorecard's cited rows), or any `stamp` mutation.
  Their policy acceptance is measured; execution is not.
- Base-gate citation behavior is `[INFERENCE]` (no checkout/mutation allowed).
- The lane kept committing during measurement; the only reproducible anchors are the hashes in
  the snapshot table and the exact commands above. Re-run `bash corpus/claim-ledger.sh citations`
  after the next commit lands — R11-08's expectation (`CLEAN`) is not currently satisfied by the
  checkout regardless of round-23 rows.
- Not audited by this seat: C2 (`corpus/source-fetches.tsv` / `sources-census.sh SC_FETCH`);
  covered by the census/digest seats.
