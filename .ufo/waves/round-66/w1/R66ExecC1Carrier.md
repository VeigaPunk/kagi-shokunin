# R66ExecC1Carrier — C1_CARRIER counter (executor)

Seat: `R66ExecC1Carrier` (executor). Assignment: `plans/round-66-c1.sh`
per `plans/round-66.md` §C1 **as amended by Amendment A1** (the L1's
restatement; the original "header-ID" term is gone and its K2 is withdrawn).

Lane file: **`plans/round-66-c1.sh` sha256
`bd3310b5351f028c972fd2a7d3b9475f8015696b9f07558bb95125ae2ce67440`**
(43 selftest cases). History this seat was party to:
`72c95923…` (this seat's first version, superseded by the L1's A1 rewrite)
→ `f2e59dce…` (L1's A1 counter, 316 lines) → `221a2cd7…` (this seat's
hardening, landed by the L1 at 06:37) → `1a738c9e…` → **`bd3310b5…`**
(equivalent-survivor fixes + the QM74 selftest-scratch fix).

## Behavior

Resolve three anchors to ONE path P hashing to the registry pin:
`registry` = the capture path in the anchor cell of the row carrying the
pin and naming a path (id `S164`, which supersedes S148); `fetches` = that
row's `source-fetches.tsv` 16th column (a full-match capture path, with
columns 10/11 equal to the pin and its byte count); `volatile` =
`corpus/volatile-shape.py` `DEFAULT_CAPTURE`.

`paths`/`hex`/`match` come from three mutated copies (one wrong-id body at
the resolved carrier slot each). `match` and the exit code both come from
`verdict_of(drift, paths_n, hex_n, refused_n, guard)` — computed after the
guard, so neither the printed `match=` nor the exit code can be a literal.

Guard: (a) a `--base-tree` extraction of `d549ee6` reads `drift=0`;
(b) `--selftest` exits 0; (c) the round-65 gate reads
`VOLATILE_SHAPE: match=1` **on the candidate** (`TREE/corpus/volatile-shape.py`,
`--capture <candidate carrier>` when falling back to the lane copy);
(d) a copy whose anchors name `.ufo/waves/round-64/capture/S148.body`
reads `drift=0` naming `digest-mismatch:`.

## Measurements (lane tree, `--base-tree` = `git archive d549ee6`)

```
candidate : C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1     rc=0
            c1-carrier: row=S164 path=.ufo/waves/round-64/capture/S143.body
            guard a=1 b=1 c=1 d=1
BASE      : C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0     rc=1
            guard a=1 b=0 c=1 d=1   (b=0: the BASE tree resolves no carrier;
                                     the counter cannot pass there — intended)
selftest  : c1-carrier: selftest cases=43 failed=0                rc=0
```

Receipts: `hard-candidate.txt`, `hard-base.txt`, `hard-selftest.txt`,
`hard-mutants.txt`, `round-66-c1.hardened.sh` (byte-identical to the lane
file). Earlier receipts (`base.txt`, `full-candidate.txt`, `k2-control.txt`,
`scratch-arg.txt`, `selftest.txt`) belong to the superseded `72c95923`
version and are kept because R66MutC1's first battery cites them.

## Defects measured and fixed (D-numbers continue the earlier report)

- **D6 `match=1` was a literal in the verdict printer** (L1's `f2e59dce`, and
  again reproduceable at the call site) — the constant-printer class. `match`
  is now a return value of `verdict_of`, and a `m = 1` mutant inside it dies
  on `verdict-of-partial-refusal` / `verdict-of-paths2` / `verdict-of-base`.
- **D7 mutation legs ran on a tree resolving no carrier**: at BASE the
  volatile anchor alone supplied `path`, so the control printed
  `paths=3 hex=3 match=1` with `drift=0` — the M65-1 do-nothing shape. Legs
  now run only when `drift == 1`; BASE reads `paths=0 hex=0 match=0`.
- **D8 guard (c) measured the script's own lane, not the candidate.** Now
  `TREE/corpus/volatile-shape.py` first, with a lane fallback that passes
  `--capture <candidate carrier>`.
- **D9 per-leg digest refusal had no selftest case** (R66MutC1 W2). Three
  independent cases now: `registry-digest-refused`, `fetches-digest-refused`,
  `volatile-digest-refused`, each asserting the named leg fails alone.
- **D10 exit aggregation untestable** (R66MutC1 W6/W9/W10/W11). `verdict_ok`
  + `verdict_of` with `hex=2`, `hex=4`, `paths=2`, `drift=0`, `guard=0`,
  `match=0` and `verdict-of-*` cases.
- **D11 mutation slot reachable only via the live carrier** (R66MutC1 W7).
  `mutation_leg(tree, carrier, wrong_rel, dst)` + an alternate-carrier
  fixture: `mutation-leg-writes-carrier-slot`, `mutation-leg-hex-zero-on-pin`,
  `mutation-leg-same-bytes-not-refused`.
- **D12 QM74: `--selftest` built its fixtures with
  `tempfile.mkdtemp(dir=TREE)` — inside the measured tree.** Now both fixture
  roots are created in the counter scratch (`selftest(root, scratch)`); after
  a run no `selftest-*` directory exists anywhere under the lane.
- **D13 population constant** (R66MutC1 P3): `wrong-body-population-3` and
  `wrong-bodies-are-distinct`.
- **D14 prose col16 accepted** (R66MutC1 W5): `fetch-prose-refused` — a cell
  that quotes the carrier path in prose is `col16-is-not-a-capture-path`.

## Mutant kills on the final bytes (`hard-mutants.txt`, selftest-only)

| mutant | kill |
|---|---|
| P3 population (4th wrong path) | 2 cases: `wrong-body-population-3`, `wrong-bodies-are-distinct` |
| W5 `fullmatch`→`search` | `fetch-prose-refused` |
| W8 `refused=1` constant | `mutation-leg-same-bytes-not-refused` |
| W2 registry digest dropped | `registry-digest-refused` |
| W7 constant mutation slot | `mutation-leg-writes-carrier-slot`, `mutation-leg-refuses-wrong-bytes` |
| aggregation ignores paths/hex | 4 cases incl. `verdict-of-hex2` |
| `m = 1` inside `verdict_of` | `verdict-of-partial-refusal`, `verdict-of-paths2`, `verdict-of-base` |

**One named equivalent survivor** (not killable and not a defect): replacing
the *call site* with `match, exit_code = 1, verdict_ok(…, 1, guard)` is
indistinguishable, because every input that reaches that line has
`match == 1` by construction (the caller only runs the legs when `drift == 1`,
and drift implies the binding refused nothing). Named so the battery does not
re-find it as live.

## Open items for the L1

1. **Plan text**: A1's sentence names `(S143/S156/S157)` as the three
   wrong-id bodies; `S143.body` **is** the carrier on the repaired tree (its
   bytes are the pin), so a copy of it measures nothing. The counter mutates
   the three round-64 bodies whose bytes are not the pin: `S148.body`,
   `S156.body`, `S157.body`. The counter asserts the property (three distinct
   bodies, each hashing differently from the pin), not the id list; the
   sentence is the L1's to correct in the amendment record (R66MutC1 shipped
   finding 3).
2. **A1's command line** shows only `--tree`, but guard (a) needs
   `--base-tree <d549ee6 extraction>`; without it `guard=0` by design
   (R66MutC1 shipped finding 2).
3. `resolve_anchor` takes the newest row carrying the pin and a path; with
   two such rows the newest wins — a named ceiling, measured by the battery.
4. The live carrier re-open is not a leg of this counter: R66ScoutSources
   measured the served body byte-identical to the pin (200, 264946 B,
   `3b8d4e15…`) and the 429 to be burst-dependent, so a live leg would be
   flaky without adding a delta.

## Scratch

`$HYAKU_SCRATCH/kagi-r66/R66ExecC1Carrier/` (`/fast/scratch/hyaku/…`),
`TMPDIR` exported, deleted on exit. Nothing was written inside the lane tree
by any counter or selftest run.
