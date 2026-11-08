# R64ScribeEntry — receipts (round 64, seat scribe/entry)

Seat: R64ScribeEntry (scribe). Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master.
Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`. Frozen predeclaration `plans/round-64.md`
(commit `dff0929c0e084822b0fe32e0d164534c768f97fe`, Amendment A1).
Scratch for every run below: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ScribeEntry`
(deleted before yield). No git/jj mutation anywhere; no write inside the measured tree.

## Tooling

No tool was installed or upgraded by this seat (no package manager was invoked). The host
guard in `/home/vgpnk/.omp/agent/RULES.md` was read first; the pacman pause (orchestrator
ruling 2026-10-20) was therefore never reached.

## Files written by this seat

- `corpus/knowledge/claim-instrument-heldout.md` (new; 165 lines at write time)
- `corpus/QUALITY.md` (append-only: QM85, QM86 appended under a new
  `## Criteria from the round-64 held-out-set and bounded-delegation work` heading)
- `SKILL.md` (append-only: a new `## Gate registry — round-64 additions` section with three rows)
- `.ufo/waves/round-64/build/R64ScribeEntry/entry.md` (this file)
- `.ufo/waves/round-64/build/R64ScribeEntry/c1-worktree-1.txt`, `c1-worktree-2.txt`,
  `c2-worktree.txt` (counter receipts, copied out of scratch)
- `.ufo/waves/round-64/w1/R64ScribeEntry.md` (the seat report)

No other lane path was written. The sealed held-out table was **not** read by this seat:
its digest was verified with `sha256sum` only, and no fixture string from it is quoted in
any artifact of this seat. (The C1 checker hardening seat is the seat forbidden to read
it; every other seat may. This seat had no need to read it and did not.)

## Commands and outputs

### 1. Seal verification (digest only)

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin && sha256sum plans/round-64-heldout.tsv
b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2  plans/round-64-heldout.tsv
$ wc -l plans/round-64-heldout.tsv
21 plans/round-64-heldout.tsv
```

Matches the frozen seal in `plans/round-64.md` §C1 (Amendment A1). The file's rows were not
opened.

### 2. C1 counter selftest

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ScribeEntry bash plans/round-64-c1.sh --selftest
C1_HELDOUT_SELFTEST: PASS (cases=19)
RC=0
```
(407.88 s wall; the counter's bytes at that moment: sha256
`b07bc51894502f16639e0a71c31b3a476627880682264caa28dbf4320e259196`. The counter owner
reported afterwards that the selftest case count changed with the witness cases it added,
so this count is recorded as the count measured on those bytes and is flagged for
re-reading at integration.)

### 3. C2 counter selftest

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ScribeEntry bash plans/round-64-c2.sh --selftest
C2R64_SELFTEST: PASS (cases=21)
RC=0
```
(5.40 s wall; bytes sha256 `f7cddb0345211beb0163bbd7de7f3e9ad81a535854905ff9da34c59147a29cf1`.)

### 4. Controls battery selftest

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ScribeEntry bash plans/round-64-controls.sh --selftest
CONTROLS_SELFTEST: PASS (cases=34)
RC=0
```
(5.67 s wall; bytes sha256 `7e7492affc22c99def4dfb2eb47f108157fafbea0f57f45c46657b729f173e4f`.)

### 5. C1 counter on the working tree (the candidate reading)

**Final run on the counter's frozen bytes** (sha256
`e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484`, declared frozen by
the counter's owner after its fixes):

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ScribeEntry bash plans/round-64-c1.sh --tree .
c1-heldout: resid reading: C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1 chal=1) (round-63 rc=0)
c1-heldout: seal=sha256 b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2 (frozen)
c1-heldout: selftest rc=0 pass=1 cases=111 (guard floor 109)
c1-heldout: H accepted=0/5 (each counted when value=0) Q rejected=0/3 (each counted when value>=1)
c1-heldout: per-fixture F2=value1 F6=value1 F8=value1 F10=value1 B4=value1 P6=value0 B5=value0 P7=value0
c1-heldout: unmodified value=0 bits=i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1
c1-heldout: resid leg=1 (C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 …)
c1-heldout: stub e1_rc=2 e1_ok=1 e2_rc=2 e2_ok=1
c1-heldout: vehicle heldout=5 r63=1 (must be heldout>=1)
c1-heldout: timing measure=185s real=11s resid=298s stub=0s vehicle=2s total=496s (resid budget 1500s)
C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)
RC=0
```
Receipt `c1-worktree-6-verdict.txt` (496.14 s wall).

This is the round's C1 claim measured by this seat on the counter's frozen bytes:

- **the measure** — the five held-out forgeries each read `value=1` (rejected) and the
  three held-out benign rewrites each read `value=0` (accepted); the unmodified copy reads
  `value=0` with all seven item bits 1. `heldout=0` over `POP = 8`;
- **the vehicle** — `heldout=5 r63=1`: the A4 lookup-table vehicle is refused on the
  held-out set (five of the eight fixtures count against it) while it still reads
  `accepted=0 rejected=0` on the committed tables it answers;
- **the stub** — both printer-stub shapes refused (`e1_rc=2 e1_ok=1 e2_rc=2 e2_ok=1`);
- **the resid** — the round-63 counter still reads
  `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1` on the candidate, so the
  committed tables did not regress;
- **the selftest leg** — the tree's checker reads `cases=111`, above the counter's floor
  109.

Earlier runs on the counter's earlier bytes, kept because they are the seat's independent
reproduction of the two defects the owner then fixed (receipts `c1-worktree-1.txt` …
`c1-worktree-4-timeout.txt`):

```
$ HYAKU_SCRATCH=… bash plans/round-64-c1.sh --tree .            # bytes b07bc518…
c1-heldout: selftest rc=0 pass=1 cases=91 (guard floor 109)
c1-heldout: H accepted=0/5 … Q rejected=0/3
c1-heldout: per-fixture F2=value1 F6=value1 F8=value1 F10=value1 B4=value1 P6=value0 B5=value0 P7=value0
c1-heldout: unmodified value=0 bits=i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1
c1-heldout: resid leg=0 (no C1_RESIDUAL line)
plans/round-64-c1.sh: line 620: stub2_e2: unbound variable
RC=1
```

and on the bytes `dabeffdb…`/`ca6dec9b…` a full `--tree .` run exceeded an outer
`timeout 1500` (rc 124) inside the `resid` leg (receipt `c1-worktree-4-timeout.txt`).

Both were reported to the counter's owner (`R64ExecC1Counter`) with this seat's
reproduction. Two readings this seat measured about the earlier runs:

- `cases=91` is the tree checker's own selftest count at that moment, below the counter's
  guard floor 109 ⇒ the `selftest` leg could not be 1. Measured directly on the working
  tree at 02:35: `python3 -I -B plans/round-61-c1-check.py --selftest` ⇒
  `C1_CHECK_SELFTEST: PASS (cases=110)` (sha256
  `c433dcb25c6a0e5adc4c25e068f949d173f900e693cd54a56451762c291ff7ef`), i.e. the grammar
  seat's checker was still moving while the counter measured it.
- `resid leg=0` — the round-63 counter exits rc 2 with
  `SETUP forgery fixture table not readable: <tree>/plans/round-63-residual.tsv` when it is
  invoked from inside the slim copy (it derives the lane from its own `BASH_SOURCE`). The
  owner reports the invocation now uses the lane's own copy with the tree copy as fallback.

### 6. C2 counter on the working tree (the candidate reading)

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ScribeEntry bash plans/round-64-c2.sh --tree .
c2-refusal: tree=. scratch=… bound=1 elapsed=299s
c2-refusal: guard a=1 r63selftest=1 b=1 c=0 d=1 e=1
C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=0 terminates=1 bound=1)
RC=1
```
Receipt `c2-worktree.txt`. **The headline is the claim's own**: one invocation terminated
end-to-end (299 s, `terminates=1`, `bound=1`) and printed its single `C2_REFUSAL:` line
with all five legs firing (`killed=5` over `population=5`). The round-63 defect (the counter
reading `rc=124` at 900 s and 1500 s, committed receipt 7 bytes `rc=124`) is closed by the
`C2_RECURSION_BOUND` flag. The one red is the guard's `real` leg (the tree's round-62
counter's real-trial leg); the owner reported it ran against the pre-reorder composition,
that the trial is contention-sensitive, and that the leg order was changed (the real trial
now runs first, alone) with a re-measurement in flight.

`bao` resolves on this host (`/home/vgpnk/.local/bin/bao`), so the real leg's failure was
not a missing binary.

**Re-run on the counter's frozen bytes** (`sha256 e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b`,
which the counter's owner declared frozen after changing the leg order — the real trial
first, alone — and the real-trial field parse):

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ScribeEntry bash plans/round-64-c2.sh --tree .
c2-refusal: tree=. scratch=… bound=1 elapsed=625s
c2-refusal: guard a=1 r63selftest=1 b=1 c=1 d=1 e=1 real-attempts=1 real-rc=0
C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)
RC=0
```
Receipt `c2-worktree-2.txt`. **The green reading, measured by this seat**: one invocation
terminates end-to-end (625 s, `terminates=1`, `bound=1`), all five legs fire
(`killed=5` over `population=5`), and every guard leg reads 1 (`guard=1`). The round-63
defect — the counter reading `rc=124` at 900 s and 1500 s with a 7-byte receipt — is
closed by the `C2_RECURSION_BOUND` flag.

### 6b. Later C1 counter runs (the counter's bytes moved while this seat worked)

The counter's owner reported at 02:39 that its bytes had been fixed (the stub globals
initialised, the round-63 counter invoked from the lane rather than from the slim copy,
the measured-tree selftest count saved before the vehicle leg overwrites it) and that its
selftest had gained witness cases. This seat re-ran the counter twice on the later bytes:

```
$ sha256sum plans/round-64-c1.sh          # 02:45, at run time
dabeffdb7c04fa314213cf8af13d1f26efd46ddbe364b3d7b3608f2966a76415  plans/round-64-c1.sh
$ HYAKU_SCRATCH=… bash plans/round-64-c1.sh --tree .
c1-heldout: resid: counter=/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-63-c1.sh tree=…/tree
RC=124                                     # outer timeout 1500 s; receipts c1-worktree-4.txt, c1-worktree-5.txt
```

```
$ HYAKU_SCRATCH=… bash plans/round-64-c1.sh --selftest      # 02:47, 616.58 s
FINDING R64-C1-ST-vehicle-leg-zero
C1_HELDOUT_SELFTEST: FAIL (21/22 checks) failed=vehicle-leg-zero
RC=1
$ sha256sum plans/round-64-c1.sh
ca6dec9bc3db3db4be28812027cedd0a8bcd8063943e5e187559f891a40adcd6  plans/round-64-c1.sh
```

**Final C1 selftest reading** (the counter's bytes moved again; the owner added the
printer-witness cases W1/W2):

```
$ HYAKU_SCRATCH=… bash plans/round-64-c1.sh --selftest      # 03:16, 547.56 s
c1-heldout: witness W1 rc=1 line=C1_HELDOUT: heldout=3 population=8 guard=0 (real=0 selftest=0 resid=0 stub=1 vehicle=1)
c1-heldout: witness W2 rc=1 tamper=1 line=C1_HELDOUT: heldout=5 population=8 guard=0 (real=1 selftest=0 resid=0 stub=1 vehicle=0)
C1_HELDOUT_SELFTEST: PASS (cases=23)
RC=0
$ sha256sum plans/round-64-c1.sh
e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484  plans/round-64-c1.sh
```

So the counter's own selftest is green again on its latest bytes, with the count at 23
(it was 19 on `b07bc518…` and red at 22 on `ca6dec9b…`). The count therefore moves with the
counter's witness cases, which is why the registry row pins it **by digest** and states
that the L1 re-reads it at integration rather than the row claiming a number of its own.

Two findings, both reported to the counter's owner (`R64ExecC1Counter`) with this seat's
reproduction. The first was a transient red that the owner then fixed (the final selftest
reading above is green); the second is a **budget** observation that is the counter's
design call:

1. the counter's own selftest read **red** on the bytes `ca6dec9b…` on its own case
   `plans/round-64-c1.sh:814` (`chk vehicle-leg-zero "$w2_ok"`); the owner fixed it and the
   selftest is green again at 23 cases on `e03a4d69…`;
2. a full `--tree .` run does not finish inside an outer `timeout 1500` — it is inside the
   `resid` leg, whose own budget is `RESID_TIMEOUT=1500` (`plans/round-64-c1.sh:96`), so
   the leg alone can consume the whole budget and the five held-out fixtures, the stub legs
   and the vehicle leg come after it. A reader who runs the gate with the plan's own
   1200 s budget will not get a verdict line.

Consequence for this seat's registry row: it does **not** pin a bare case count for the C1
counter's selftest. The row carries the invocation, the verdict map, the pinned seal and
digests, and the statement that the count is re-read at integration on the landed bytes.
The row's `selftest` cell records this seat's readings with the digest each was measured
on, so a reader can see which bytes the number belongs to.

### 7. Gate-lane health before this seat's landing
```
$ bash corpus/sources-census.sh
FINDING SC_ENTRY_CITE entry=corpus/knowledge/claim-instrument-heldout.md id=S145 not-a-registry-row
FINDING SC_ENTRY_CITE corpus/knowledge/claim-instrument-heldout.md: no tier A/B support (tier C is a lead only)
SOURCES_CENSUS: FAILED (findings=2 rows=143)
```
Expected until the L1 appends the round-64 registry rows: the entry's `source:` id is
**S145** (Kushigian et al., "Equivalent Mutants in the Wild", ISSTA '24), which does not
exist in `corpus/SOURCES.md` yet (the registry ends at S144, 143 data rows). The census
also scans every `S###`-shaped token in an entry as a registry id, so this seat's first
draft named the capture handle (`S154`) and drew
`FINDING SC_ENTRY_CITE entry=… id=S154 not-a-registry-row`; the entry was rewritten to name
no capture handle (it points at `.ufo/waves/round-64/capture/notes.md` and the digests
instead), and that finding is gone. Re-run after the final text: the same two findings
remain, and no third one appeared.

```
$ bash corpus/claim-ledger.sh docs
UNPINNED corpus/knowledge/claim-instrument-heldout.md (knowledge entry is not a row in the stamps file)
ENTRY corpus/knowledge/claim-instrument-heldout.md row_linked=1 by_hand=-
DOC_AUDIT_RATIO: row_linked=42/45 floor=23 by_hand=3 duplicate_reasons=0
DOC_AUDIT: BROKEN (entries=45 row_linked=42 by_hand=3 undeclared=0 missing_ids=0 unpinned=1 duplicate_reasons=0 floor=23)
```
`corpus/stamps.tsv` is not this seat's file; the L1 must add the row for the new entry
(it is regenerated by `bash corpus/claim-ledger.sh stamp …`, a reviewed commit). At the
bytes measured at write time the row is:
`corpus/knowledge/claim-instrument-heldout.md  8145f470de91ddcd99e4f32daf22c603ca0d3597930e988e93f5475bab210c06  185  16677`
(re-measure after the L1's final text; the sha changes with any edit).

The `Reverify:` line names **R21-02** (`bash corpus/sources-census.sh`) — the row the
round-63 entry `corpus/knowledge/negation-scope-grammar.md` also names — so the entry's
host-fact base (the registry row it cites) is re-checked by the census. It is a resolving
claim row, so the entry counts as `row_linked=1` in the docs audit.

The citation gate over this seat's three files only:

```
$ bash corpus/claim-ledger.sh citations --docs "corpus/knowledge/claim-instrument-heldout.md SKILL.md corpus/QUALITY.md"
LABELED SKILL.md:298 local:// (session URI, labelled on its line)
LABELED SKILL.md:638 local://x (session URI, labelled on its line)
CITATION_GATE: CLEAN (cites=442 docs=3 unresolved=0 ephemeral=0 labeled=2)
RC=0
```
(The two LABELED lines are pre-existing in `SKILL.md`, at lines 298 and 638, not in this
seat's rows.) The whole-docset run over the lane reads `UNRESOLVED` only on
pre-existing lines in `SCORECARD.md` and old lessons — none in this seat's files.

### 8. Read-only lane checks run by this seat

```
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin log --oneline -3
eb647d2 round-64: wave spec, dispatch and ready file (kagi-r64-w1, 16 seats)
823855d round-64: C2 BASE re-measurement (timeout 240 rc=124)
dff0929 round-64: frozen plan + Amendment A1 (held-out population re-measured; seal b0f51e2a…)
```
Read-only (`log`, `status`, `ls-files`, `rev-parse`); no `add`, `commit`, `stash`, `push`
or mutating `jj` was run.

```
$ sha256sum plans/round-64-c1.sh plans/round-64-c2.sh plans/round-64-controls.sh
b07bc51894502f16639e0a71c31b3a476627880682264caa28dbf4320e259196  plans/round-64-c1.sh
f7cddb0345211beb0163bbd7de7f3e9ad81a535854905ff9da34c59147a29cf1  plans/round-64-c2.sh
7e7492affc22c99def4dfb2eb47f108157fafbea0f57f45c46657b729f173e4f  plans/round-64-controls.sh
```
(These are the digests pinned in the `SKILL.md` registry rows; the C1 counter's owner
reports its bytes still moving — the rows name the digest they were measured on, and the
L1 re-reads the count at integration.)

## Known limits of this seat's evidence

1. The C1 counter's verdict line **was** observed by this seat on the counter's frozen
   bytes: `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1
   vehicle=1)` rc 0 in 496 s. The entry names the bytes the verdict was read on; the
   committed candidate receipt is still the L1's to land.
2. The C2 counter's verdict line **was** observed twice by this seat: red (`guard=0`,
   `real=0`) on the bytes `f7cddb03…`, and green (`guard=1`, `real=1`, `terminates=1`,
   `bound=1`, `killed=5 population=5`, rc 0) on the counter's frozen bytes `e2d8171f…`.
3. The registry id **S145** is proposed by the round's scout and records seat and is minted
   by the L1; if the L1 allocates a different id, the entry's `source:` line must be
   updated in the same commit (the content does not change). Until the row is appended,
   `corpus/sources-census.sh` reads `FAILED (findings=2 rows=143)` for this entry alone.
4. This seat quoted **no** fixture string from the sealed held-out table; the shape classes
   in the entry are the plan's own names. The sealed table was verified by digest only.
5. The `SKILL.md` registry row for the C1 counter carries **no** pinned case count: the
   counter's selftest count and green-ness both moved with its bytes during this seat's
   work, so the row names the invocation and the two measured readings with the digest
   each belongs to, and the L1 re-reads the count at integration.
6. The stamp row for the new entry is not this seat's to write (`corpus/stamps.tsv` is
   regenerated by a reviewed commit); the L1 must add it, or `DOC_AUDIT` reads `unpinned=1`.
