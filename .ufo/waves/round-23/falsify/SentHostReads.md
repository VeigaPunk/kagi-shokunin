# SentHostReads — round-23 host-read / socket / handler trace

Seat: falsification, round 23 (`SentHostReads`). Scope: every filesystem/network
access reachable from `corpus/closure-dispositions.py`, the `SC_FETCH` block in
`corpus/sources-census.sh`, and claim rows `R23-01`/`R23-02`. Contract honoured:
no lane writes except this file, no git/jj mutation, no installs, no host gates,
no legacy `verify`, no secret contents read. Scratch fixtures were created under
`mktemp -d /tmp/...` and removed (`rm -rf` exit 0).

## Snapshot pin

All results below are for the live tree at **2026-10-21T01:05:26-03:00**:

```
bf6154b1…  corpus/closure-dispositions.py      (17,551 B)
00fbf48d…  corpus/closure-dispositions.json
c20c2d04…  corpus/claim-ledger.sh
0d3d7500…  corpus/claim-ledger.tsv
1a073771…  corpus/fixtures/cells-hermetic/claims.tsv
401ebb3c…  corpus/fixtures/cells-hermetic/stamps.tsv
23583252…  corpus/fixtures/cells-hermetic/SCORECARD.md
fa15a53c…  corpus/fixtures/cells-hermetic/corpus/adjacency.tsv
29f98fba…  corpus/fixtures/cells-hermetic/corpus/fx-ok.sh
24d834cc…  corpus/sources-census.sh
a78fde7b…  corpus/source-fetches.tsv
```

The tree moved during the audit (this is a live integration wave, not a quiet
checkout): `closure-dispositions.py` was 17,085 B at 00:46 and gained symlink
containment at 01:02:21 (now 17,551 B, `:113-119`); `closure-dispositions.json`
changed at 01:02:31 (D9 pointer moved from `corpus/claim-ledger.tsv` to
`corpus/fixtures/cells-hermetic/SCORECARD.md`) and again at 01:04:15 (the
pinned `00fbf48d…` bytes); fixture `SCORECARD.md`
(mtime 01:03:02), `claims.tsv`/`adjacency.tsv` (01:03:17), and `stamps.tsv`
(01:03:24) were rewritten. A strace-instrumented `R23-01` run at ~01:03
returned exit 1 during those rewrites; after them, 4/4 runs returned the pinned
CLEAN line.
If these hashes differ at review time, re-run; this report does not certify a
different tree.

## Verdict (short)

For the three exact commands, **no socket, no `op` execution, no handler
access, and no sibling-lane read is reachable**. `R23-02` reads only the two
named lane files plus six in-repo pointer targets; `R23-01` reads only the
fixture root and the gate, executes only fixture-local content, and writes one
`/tmp` temp file; `SC_FETCH` never fetches. Three bounds are not enforced by the
artifacts and must be stated (F1-F3); F4 is environment dependence.

## Exact commands and exits

### R23-02 (from `corpus/claim-ledger.tsv:60`, run at lane root)

```
$ python3 corpus/closure-dispositions.py
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
exit=0
```

Byte-identical to the ledger expectation (`corpus/claim-ledger.tsv:60`).

```
$ python3 corpus/closure-dispositions.py --selftest
CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)
exit=0
```

### R23-01 (exact field 2 of `corpus/claim-ledger.tsv:59`)

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --claims corpus/fixtures/cells-hermetic/claims.tsv \
    --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
    --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
    --docs corpus/fixtures/cells-hermetic/SCORECARD.md
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
exit=0
```

Byte-identical to the ledger expectation (`corpus/claim-ledger.tsv:59`).

### C2 gate and selftest

```
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit=0

$ bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit=0
```

## Reachability matrix (measured, not inferred)

Tracing method: `strace -f -qq -e trace=openat,open,execve,connect` (plus a
separate `-e trace=network` pass) around each exact command, then classifying
every absolute `openat` against the repo prefix, `/usr`, `/lib`, `/lib64`,
`/etc/ld.so.cache`, `/proc`, `/sys`, `/dev`, `/tmp`. `$HOME` here is
`/home/vgpnk`; the repo itself lives under `$HOME`, so "outside repo" is the
discriminator.

| Surface | $HOME content read | `op` | handler (`$HOME/.local/bin/the-janitor`) | socket | sibling lane | Writes |
|---|---|---|---|---|---|---|
| R23-02 `python3 corpus/closure-dispositions.py` | none outside repo; interpreter only `openat($HOME/.local/lib/python3.14/site-packages, O_DIRECTORY)` | not referenced | not referenced | 0 network syscalls | none outside repo | none |
| R23-01 `cells` fixture | none outside repo; 16 **failed** `execve` probes of `$HOME` PATH entries (0 succeeded) | not referenced | not reached (`[substrate]` absent, `claims.tsv:1-2`) | 0 network syscalls | none outside repo/fixture | one `mktemp` file in `/tmp`, removed by EXIT trap (`claim-ledger.sh:806`) |
| SC_FETCH / census verify | none outside repo | string `scheme='op'` at `sources-census.sh:128` only builds a credential regex; `op` never executed | not referenced | 0 network syscalls | none outside repo | none |
| census selftest | none outside repo | no | no | 0 network syscalls | none | `/tmp/tmp.*` fixture only; 59/59 PASS |

R23-01's relative opens `corpus/fx-ok.sh` and `corpus/adjacency.tsv` occur under
cwd `$ROOT` (`claim-ledger.sh:426`), i.e. the fixture root: the real lane has no
`corpus/fx-ok.sh` (`test -e` -> absent) and the row still prints `FX: OK`, so
the executed script cannot be a real-lane file. The stamp comparison opens the
fixture path `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv` explicitly
(`claim-ledger.sh:358`). Successful execs in R23-01 were only
`/usr/bin/{bash,timeout,grep,sha256sum,wc,tr,tail,mktemp,rm,dirname}`.

## Findings

### F1 — Low — `cells` row language is not contained to `--root`; `~`/absolute arguments reach `$HOME`

`policy_check` refuses metacharacters (`claim-ledger.sh:163`, `$` included) and
denied verbs (`:167`), but the command is then run by the ambient shell
(`:426-427`) with inherited environment and PATH. Neither `~` nor absolute
argument paths are refused. Evaluating the gate's own regexes against candidates
(extracted verbatim from the file, no row executed):

```
$ # META_RE / DENY_WORD_RE / ALLOWED_RE taken from corpus/claim-ledger.sh:163,167,160
cmd='bash ~/probe.sh' allow=yes metachar=no denyword=no
cmd='grep -c D9 ~/.config/probe' allow=yes metachar=no denyword=no
cmd='grep -c D9 /etc/hostname' allow=yes metachar=no denyword=no
$ HOME=/tmp/fakehome bash -c 'printf "%s\n" ~/probe.sh'
/tmp/fakehome/probe.sh
```

So a future/mutated fixture row can name `~/...` or `/home/...` and `cells`
will run it with cwd `$ROOT` but a real `$HOME`. The current fixture is safe
(`claims.tsv:1-2` use relative paths; R90-02 deliberately writes `.HOME/` rather
than `$HOME/` because `$` is refused). Impact: the "no `$HOME`" property of
`R23-01` is a property of the two committed rows, not an invariant of the gate;
row stdout is not echoed on failure (`:429-438`), so this is host read/exec, not
content exfiltration. Smallest remediation: refuse `~` and argument tokens
starting `/` in `policy_check` (one condition), or pin the runner as
`env -i PATH=/usr/bin:/bin HOME="$ROOT" timeout … bash …`; either way state the
bound in the lesson.

### F2 — Low — symlink containment in `closure-dispositions.py` is real but untested by the 13 selftest cases

Probe on a scratch root (`mktemp -d`), live script `bf6154b1…`:

```
ln -s /etc/hostname root/leak.md
# dispositions row: {id:D1, disposition:reported, pointer:"leak.md"}
DISPOSITION POINTER-ESCAPE D1 leak.md
CLOSURE_DISPOSITIONS: FAILED (obligations=3 dispositions=3 missing=0 unknown=0 unresolved=1)   exit=1
strace: newfstatat(AT_FDCWD, "/etc/hostname", {st_mode=S_IFREG|0644, …}, AT_SYMLINK_NOFOLLOW) = 0
        no openat("/etc/hostname") at all
```

Containment is checked at `:113-119` (`target.resolve()` under `root.resolve()`)
before `read_text`. Good. But the selftest's escape case is only
`$r[0].update(pointer="../notes.md#Routed")` (`:311`); no symlink case exists in
the 13, and `:363` reports the fixed count. The guard added at 01:02 is
therefore regression-unprotected. Smallest remediation: add a symlink mutation
case (link `notes.md` to a file outside the scratch root, expect
`POINTER-ESCAPE`) and move the claim to 14 cases.

### F3 — Info — pointer containment is path-based; an in-root hardlink reads an outside inode

Scratch root with `ln $tmp/outside.md $R/hard.md`, pointer `hard.md` (fixed):

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=3 fixed=1 reported=1 operator_owned=0 no_action=1 pointers=2)
openat(AT_FDCWD, "/tmp/cd-escape…/root/hard.md", O_RDONLY|O_CLOEXEC) = 3
```

The resolved path is in-root, so the guard passes and the inode is shared with
the outside name. This is not a privilege boundary on a single-user lane (the
lane owner can read the file directly), but the claim must not say "cannot read
outside `--root`" without this caveat. No current pointer is a hardlink:
all 15 pointers resolve to six regular, non-symlink, in-repo files.

### F4 — Info — environment dependence around an otherwise clean read set

- `python3` startup stats `$HOME/.local/lib/python3.14/site-packages` as a
  directory (`O_RDONLY|O_DIRECTORY`) and reads no file inside it; that dir has
  no `usercustomize`, `sitecustomize`, or `.pth` (name listing only), so no host
  code is imported. `/etc/localtime` and `/etc/ssl/openssl.cnf` are read by the
  interpreter, not by lane code. A host with a user-site startup hook would
  change this, independent of the gate.
- R23-01 resolves `bash` through inherited PATH: 16 `execve` attempts under
  `$HOME` (`.grok/bin`, `.kimi-code/bin`, `.local/share/mise`, `.local/bin`,
  `.opencode/bin`, …) all failed `ENOENT`; `/usr/bin/bash` ran. A `bash` earlier
  in PATH would be executed. PATH is not pinned.
- `cells_evidence` writes `mktemp` output in `/tmp` (`claim-ledger.sh:806`,
  removed by trap `:153-155`); `mktemp` is a host write, not a read.
- `substrate_present` is the only `$HOME/.local/bin/the-janitor` access
  (`claim-ledger.sh:140-146`), gated on a literal `[substrate]` note tag
  (`:416`); fixture rows carry no tag (`claims.tsv:1-2`) and the trace shows no
  `the-janitor` stat.

## Bounds the claims must state

1. **R23-02**: with the committed JSON, the gate reads two lane files plus six
   in-repo pointer targets and nothing outside the repo. Escape guards are
   absolute/`..` (`:107-110`) and symlink resolution (`:113-119`), but the guard
   is path-based (hardlinks, F3), `--root`/`--source`/`--dispositions` are
   unrestricted CLI paths, and the tool is not a sandbox. The 13-case selftest
   does not cover the symlink guard (F2). Interpreter startup touches the user
   site directory as metadata (F4).
2. **R23-01**: "host-free" means the two committed rows at the pinned fixture
   hashes read only fixture files and execute only fixture content with cwd
   `$ROOT`; it does not mean the gate sandboxes row commands (F1), pins PATH
   (F4), or avoids `/tmp` writes. The substrate probe is reached only by a
   `[substrate]`-tagged row. `rows_run` counts selected rows, including deferred
   ones — the line also pins `row_deferred=0 self_skipped=0`.
3. **SC_FETCH**: it verifies declared capture rows (shape, row-line identity,
   URL, representation, same-URL agreement, `source-fetches.tsv:282,288`) and
   **never fetches**: the only `curl` occurrences are the declared profile
   string and comments (`sources-census.sh:70-72,255`; TSV data). Freshness is a
   dated attestation, not a live re-measurement. `--root` is caller-supplied and
   reads are `$ROOT/corpus/...` only (`:153,227`).

## Context correction (not this seat's verdict)

The dispatch brief says "10 declared captures S017-S026 over 7 URLs". The live
artifact measures **10 captures over 9 distinct URL strings** (`awk -F'\t'
'!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l` -> 9),
and the live lesson was corrected to match: `corpus/lessons/round-23.md:170`
says "over nine distinct URLs". The stale "7" in the brief is not a defect in
the current tree. (S021/S026 share
`https://openbao.org/docs/concepts/tokens/`.)

## Evidence index

- `corpus/closure-dispositions.py:104-126` pointer resolution; `:107-110`
  absolute/`..` refusal; `:113-119` symlink containment; `:145-160` source read
  and digest; `:290-291` selftest subprocess (self only); `:300-312` mutation
  table (no symlink case); `:363` PASS line; `:369-399` CLI paths.
- `corpus/claim-ledger.sh:140-146` substrate stat; `:154-156` temp cleanup;
  `:160-190` policy; `:163` META_RE; `:167` DENY_WORD_RE; `:400-441`
  `verify_claims`; `:416` substrate tag; `:426-427` cwd + inherited-env exec;
  `:355` stamp path; `:806` mktemp.
- `corpus/sources-census.sh:128-129` `op` scheme regex; `:153,227` root inputs;
  `:247-298` SC_FETCH checks; `:282,288` same-URL agreement; `:504,558+`
  selftest/case table.
- Fixture: `corpus/fixtures/cells-hermetic/claims.tsv:1-2`,
  `stamps.tsv:1-2`, `SCORECARD.md:1` (`D9` token),
  `corpus/adjacency.tsv:1-8` (literal `$HOME` data, never expanded).
- Ledger rows: `corpus/claim-ledger.tsv:59-60`; lesson bounds:
  `corpus/lessons/round-23.md:163` ("No real host path is read"),
  `:170` ("nine distinct URLs").

## Not run (deliberately)

The legacy `claim-ledger.sh verify` and the 43 parent rows were not executed;
no host-bound row was run; no host gate, install, or package transaction was
performed. The only executions were the three named host-free commands above,
their selftests, and scratch probes under `/tmp` with fake roots/HOME.
