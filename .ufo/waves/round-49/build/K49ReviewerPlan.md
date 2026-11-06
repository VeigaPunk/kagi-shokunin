# K49ReviewerPlan — review of the frozen round-49 instruments (false-green hunt)

Seat: K49ReviewerPlan (leaf). Inputs verified frozen before review: `sha256sum` of
`plans/round-49.md`, `plans/round-49-c1.sh`, `plans/round-49-c2.sh`,
`plans/round-49-controls.sh` and both `controls/fixtures/` files equals
`.ufo/waves/round-49/controls/instrument-sha256.txt` line for line; `~/.local/bin/bao`
sha256 `9c5f3628…b788` = the counter's `PIN_BAO`, `bao version` = `OpenBao v2.7.2
(9e0a0d3c…)`. Every experiment below ran in
`/fast/scratch/hyaku/kagi-r49/K49ReviewerPlan/` (receipts under `receipts/`, removed at
seat end); git commits only in scratch clones with `rev-parse --show-toplevel` asserted;
no token value ever printed (masked to first 2 chars + length).

## Verdict summary

The frozen instruments are word-for-word faithful to the plan's predicate sentences, and
19/19 pre-freeze control outcomes reproduce. One real **false green** exists in C2
(K49RP-1, guard gap: `corpus/claim-ledger.tsv` is unpinned). C1 has no false green found;
its residual defects are false-red/latency (K49RP-2) and a cleanup dependency (K49RP-3).
Everything else attacked was tried and held, with receipts.

## Predicate ↔ code, word by word

C1 (`plans/round-49-c1.sh`, line numbers of the working tree = receipt-hashed bytes):

- Plan: "value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
  SETUP_OK = 1 and NOSECRET = 1, else 0; target 5" ↔ code `value` accumulates
  `rv=HOLDS && sv=BROKEN && ev=1` (l.113-119), `final=$value` zeroed unless
  `setup_ok=1 && nosecret=1 && pins=1` (l.123-124). **MATCH.**
- DISCRIMINATE: "exactly one `TRIAL T HOLDS …` … AND exactly one `TRIAL T BROKEN …`
  under T's designated falsifier shim AND the entry carries a `## Measured (round 49`
  section with a `- T<n> ` line naming `OpenBao 2.7.2`" ↔ `verdict()` returns
  NONE/DUP/status on count≠1 (l.91-94); shims sh1–sh5 match their one-line descriptions
  (SH1 lookup→`{}`; SH2 drops `-explicit-max-ttl=`; SH3 drops `-type=batch`; SH4
  `login`→child of caller's token; SH5 drops `-ttl=`); `entry_line()` awk requires the
  heading regex `^## Measured \(round 49` and a line whose first 4+ chars are `- T<n> `
  containing `OpenBao 2.7.2` (l.104-109). **MATCH.**
- SETUP_OK: "with no bao on PATH the trial exits 2 and prints no HOLDS line" ↔
  `none_rc -eq 2 && ! grep -qE '^TRIAL T[1-5] HOLDS'` (l.100-101), with
  `PATH="$W/bin/none:/usr/bin:/bin"` and a pre-guard that SETUPs if /usr/bin or /bin
  carries a bao (l.53). **MATCH.**
- NOSECRET: sentence ERE `(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}` or
  `r49-[0-9a-f]{24}` or `password=`+32 hex ↔ code l.121 identical, scanned over every
  `*.out` and `*.out.err`. **MATCH** (adequacy: K49RP-5).
- Fail closed: "real run with no final `OPENBAO_TRIAL: ` line is SETUP" ↔ l.98;
  "absent trial reads `value=0 absent=1` (exit 0)" ↔ l.57. **MATCH.**
- PINS: sha256 of the PATH'd bao = `PIN_BAO`, else SETUP exit 2 (l.50-52). **MATCH**
  (one cosmetic note, K49RP-10).

C2 (`plans/round-49-c2.sh`):

- "value = number of the six frozen BASE keys whose line … does not start `OK ` (a
  missing line counts), when GUARD = 1, else SETUP; target 0 (BASE 6)" ↔ per-key
  `grep -E "^[A-Z]+ $k( |\$)" | head -1`, first token ≠ OK (or MISSING) increments
  (l.80-85); guards run before and each fails SETUP (l.51-78). **MATCH** (first-token
  check is stricter than "starts `OK `" — e.g. a hypothetical `OKX …` counts as not-OK —
  fail-closed direction, and the pinned emitter never prints such a token).
- "clean `git clone --shared` checkout … timeout 600 s. No final `SELF_COUNTS: ` line, a
  timeout or a clone failure is SETUP" ↔ l.38-46, l.70-72. **MATCH.**
- G1 both scripts byte-identical to BASE (l.51-55); G2 six `self-counts.tsv` rows
  (l.56-59); G3 BASE `corpus/knowledge/*.md` present (l.60-63); G4 BASE stamps path
  column preserved (l.64-68); G5 POLICY names exactly
  `PV-FEEDTOKEN-SELFTEST,PV-FEEDTOKEN-SHAPES` (l.73-75); G6 ≥63 verdict lines
  (l.76-78). **MATCH** on all six sentences. G3 uses non-recursive `ls-tree` — safe
  because `corpus/knowledge/` is flat at BASE (36 top-level .md = 36 recursive; verified)
  — noted as a residual for future rounds (K49RP-10).

## Findings

### K49RP-1 — C2 FALSE GREEN (high): the six keys' ledger-source rows in `corpus/claim-ledger.tsv` are pinned by nothing

G1 pins `self-counts.py` + `claim-ledger.sh`; G2 pins the six `self-counts.tsv` rows.
The `ledger:<ID>` sources those rows point at live in `corpus/claim-ledger.tsv`, which no
guard covers — the kill rules cover only row *removal* ("any ledger row loses its row").
`ledger_command()` accepts any row whose expected-exit column matches the command's exit.

BASE R14-01 (read via `git show BASE:corpus/claim-ledger.tsv`): command
`bash corpus/claim-ledger.sh docs`, expect `^DOC_AUDIT: CLEAN \(entries=35 …`,
**expected_exit=0**. At BASE the audit exits 1 (BROKEN), so RD-DOCS-ROWLINKED/BYHAND/
ENTRIES read SETUP. A candidate that (a) sets that one column 0→1 and (b) writes README's
"pinned" number to the BROKEN audit's own `entries=36` (instead of fixing the audit)
reads OK on all three with zero real work — the iso entry stays undeclared.

Repro (fixture clone, BASE detached, committed; scratch
`fx-c2att.*`, receipts `c2-ledgerattack-withedit.txt`, `c2-ledgerattack-noedit.txt`,
`c2-attack-selfcounts-direct.txt`):

```
awk -F'\t' 'BEGIN{OFS="\t"} $1=="R14-01"{$4="1"} {print}' corpus/claim-ledger.tsv  # only ledger edit
sed -i 's#per entry: 32 row-linked / 3 by-hand / 35 pinned#per entry: 32 row-linked / 3 by-hand / 36 pinned#' corpus/README.md
sed -i "46s/(122 stamps + /(123 stamps + /" SKILL.md          # live stamp count fixes
sed -i "73s/(122 revision stamps/(123 revision stamps/" PROVINCE.md
sed -i "65s/| 122 rows (/| 123 rows (/" corpus/README.md
# NO Reverify line, NO stamp row for the iso entry
```

Observed (frozen counter on the fixture):

```
C2_SELF_COUNTS: value=0 keys=6 lines=63 self_counts_rc=2 SC-SKILL-STAMPS=OK PV-STAMPS=OK RD-STAMPS=OK RD-DOCS-ROWLINKED=OK RD-DOCS-BYHAND=OK RD-DOCS-ENTRIES=OK
SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)
```

A/B control, same fixture with ONLY the ledger column restored: `value=3`
(RD-DOCS-* = SETUP) — the ledger edit is the load-bearing step. Direct
`python3 corpus/self-counts.py` on the attack tree shows the mechanism:
`OK RD-DOCS-ENTRIES corpus/README.md:67 claimed=36 live=36` where "live=36" is extracted
from the still-BROKEN audit's last line (`row_linked=32 by_hand=3 entries=36`); the tree
has `iso_reverify_lines=0`, `iso_stamp_rows=0`.

Same mechanism OKs any of the six keys without touching its document (e.g. rewriting
R12-03's command to print 122). Proposed killing controls (route, do not apply): extend
G1 to pin the ledger rows R14-01/R12-03/R21-04 byte-identical to BASE, or stronger and
intent-matching: assert the docs audit's last line starts `DOC_AUDIT: OK `.

### K49RP-2 — C1 false red / latency (medium): a shim-wedged trial burns 600 s per run and reads NONE

`run()` is `timeout 600 bash "$TRIAL"` with no `--kill-after` and no per-run timeout
marker. The reference trial's T1 waits for a TTL lapse by polling `bao token lookup`;
under SH1 (lookup always exits 0) or SH5 (`-ttl` dropped → token effectively immortal)
that wait never ends. A correct-in-spirit trial therefore reads `shim=NONE` (not ERROR —
nothing distinguishes "wedged" from "silent") after the full 600 s, per wedged shim run;
the test scores ok=0 purely from wait-logic×shim interaction. Fail-closed (value<5), but
a fully wedged trial costs 5×600 s ≈ 50 min of wall and gives no timeout signal.
`timeout` also sends only SIGTERM: a trial that ignores TERM (`trap '' TERM`) hangs the
counter forever (shim-detection ceiling family, but worth a `-k 5`).

Evidence (frozen counter on the fixture, receipt `hang-counter.txt`): the reference
trial with T1's `sleep 4` replaced by `while alive "$t"; do sleep 2; done` wedges under
SH1 and SH5. Observed:

```
C1_OPENBAO_TRIAL: value=3 discriminating=3 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=NONE,entry=1,ok=0 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=NONE,entry=1,ok=0
counter_rc=0
elapsed_sec=1266
```

Two silent 600 s wedges (T1/T5 `shim=NONE`, no timeout marker, `counter_rc=0`); 1266 s
wall vs ≈120 s for a healthy six-run counter (the k1f7 repro). Correct real runs read
below target (value=3) purely from wait-logic × shim interaction. `timeout` also sends
only SIGTERM: a trial that ignores TERM (`trap '' TERM`) hangs the counter forever.
Killing control: `timeout -k 5 600` plus a timeout marker (e.g. rc=124 → `shim=TIMEOUT`)
in the detail line for shim runs.

### K49RP-3 — C1 hygiene (medium, demonstrated): a wedged run's dev server outlived the counter

`run()` is `timeout 600 bash "$TRIAL"` with no `--kill-after` and no process-group
containment; containment depends on the trial's EXIT trap. Empirically that dependency
broke: after the K49RP-2 counter run exited (both wedges already `timeout`-killed), one
live `bao server -dev` from a wedged trial remained on the host — found by my fixture's
unique root-token-id marker (`receipts/hang-orphan.txt`: pid 3304553, port 45507) and
killed by explicit pid. So a wedged timeout-killed trial can leak a live dev server
(bound port + root token in memory) past the counter. A mechanism mini-test
(`timeout 2 bash mini.sh`, background child + EXIT-trap kill) showed the trap CAN run on
timeout-SIGTERM, so the trap is unreliable rather than never-run; which of the two
wedges leaked and why its kill failed was not determined. Live corroboration on this
host: at review end (18:45 local) eight `bao server -dev` processes with `r49-*` root
ids were still running (started 18:12–18:22). fd/2 attribution (by K49ExecTrial):
**one of the eight was this seat's own** — pid 4144156, my batch-shape probe server,
whose `kill $SRV; wait` failed to reap it and whose random root id evaded my
marker-based leftover check; killed by explicit pid and swept by the lane at 21:43Z.
This seat therefore reproduced the leak class twice: once from a `timeout`-killed trial
and once from a plain `kill`-based cleanup that silently failed to reap. The other seven
belonged to K49CriticClaims (5, `tokenprobe.*`) and K49Sentinel (2, `dbg.*`); all eight
were terminated by the lane (~21:43Z, recorded). Same defect class, three owners.
Proposed (route): `setsid` +
negative-pgid kill in `run()` plus `timeout -k`, or name the trial-cleanup requirement
in the plan like the other ceilings.

### K49RP-4 — K1-F7 receipt reproduced and its mechanism explained (held; fail-closed)

Rebuilt the k1-f7 fixture exactly per the controls script and ran the frozen counter:
output byte-equivalent to the pre-freeze receipt
(`value=0 discriminating=4 … T1:real=NONE,shim=NONE … nosecret=0`).
The T1=NONE mechanism: `bao token create -field=token` emits **no trailing newline**;
the injected leak pipeline `… | sed "s/^/token: /"` therefore leaves an unterminated
line and T1's `report` echo fuses onto it —
`token: s.<24hex>TRIAL T1 HOLDS ttl=2s …` (xtrace shows `report T1 HOLDS` executed,
`holds=5`). The `^TRIAL T1 ` anchor then misses (real=NONE, ok=0) AND the byte-level
NOSECRET scan still catches the token on the fused line (nosecret=0). Both effects force
0; line-anchored verdict/final-line checks fail closed under line fusion; NOSECRET is
fusion-proof because it scans raw bytes. No defect; recorded so nobody "fixes" the
receipt later. (Receipts `k1f7-counter.txt`, `k1f7-direct.txt`, xtrace in-session.)

### K49RP-5 — NOSECRET adequacy vs real OpenBao 2.7.2 shapes (held)

Probe (throwaway `bao server -dev`, random 127.0.0.1 ports, root tokens never printed;
receipt `token-shapes.txt`): default dev root token `first2='s.' len=26`
service_ERE=True; `token create -field=token` child `'s.' len=26` True; userpass login
token `'s.' len=26` True; `token create -type=batch -policy=default` `'b.' len=164`
True; counter-pinned `r49-<24hex>` root matches the r49 alternative by construction; the
no-`-field` table row with the token value also matches. `token_accessor` values do not
match the ERE — accessors are not bearer secrets. A `password=` leak is caught only when
32 hex — the reference trial generates `token_hex(16)` = 32 hex. All real shapes of this
release are covered.

### K49RP-6 — C2 duplicate frozen-ident row (held, fails SETUP)

Appended a second `SC-SKILL-STAMPS` row (copy of the PV-STAMPS row under the frozen
ident, pointing at a fixed PROVINCE.md) and committed: counter →
`SETUP reason=G2-row-SC-SKILL-STAMPS` (rc=2). G2's `grep -P "^key\t"` returns *all*
matching rows per side, so any added frozen-ident row breaks equality with BASE's single
row; even past G2, `tsv_rows()` SETUPs on duplicate ids inside self-counts itself.
Receipt `c2-dup-row.txt`.

### K49RP-7 — C2 `--tree` measures HEAD, not the dirty worktree (by design; cosmetic)

Fixture clone at BASE with the full reference fix applied but **uncommitted** (git status
shows 5 modified files): counter `--tree` → `value=6 keys=6 … STALE/SETUP` — identical
to k2-0. Uncommitted state cannot green the counter (fail-safe), and the verifier's
rev-mode archives the commit anyway; but a seat that self-checks on a dirty tree sees
BASE numbers and may misread the counter as broken. Receipt `c2-dirty-tree.txt`.

### K49RP-8 — G6 word list vs the frozen emitter (held)

`corpus/self-counts.py` (BASE, G1-pinned) can only start lines with `OK`, `STALE`,
`UNLOCATED`, `AMBIGUOUS`, `POLICY`, `SETUP` (verdict/status prints) and the final
`SELF_COUNTS: ` — all counted by G6's list (`MISSING` is extra and inert; the emitter
never prints it). A "different case/format" key line is unreachable without changing the
emitter, which is exactly k2-f3 → SETUP. BASE count 63 reproduced in every C2 run above.

### K49RP-9 — stamps-dup deletion path (held)

BASE `corpus/stamps.tsv`: 123 data rows, 123 unique path column values (no duplicates) —
so any single-row deletion removes a path and trips G4; the count cannot be lowered
row-wise without SETUP. (Also exercised: K2-P/K2-F2 controls already cover the direct
cases.)

### K49RP-10 — cosmetic notes

- `R49_BAO` env override selects the binary the PINS check hashes; fine for controls,
  but a verifier shell that happens to export `R49_BAO` would pin-check a different
  binary while still reporting `pins=1`. Suggest a header sentence marking R49_BAO as
  controls-only.
- C1's `entry_line` accepts a `## Measured (round 49` section anywhere in the entry and
  accepts multiple such sections — consistent with the predicate sentence, no fix needed.
- C2 G3's non-recursive `ls-tree` narrows silently if `corpus/knowledge/` ever gains
  subdirectories (flat at BASE: 36=36). Future-round note only.

### Named ceilings confirmed (already disclosed in the plan, not re-counted)

A trial that detects the counter's shims via its PATH or the shim bytes passes C1 (the
shims live at deterministic `$W/bin/shN` paths ahead of /usr/bin); a curl-speaking trial
bypasses every shim and reads 0. Both are recorded in plan §C1 "Named ceilings" — the
frozen instrument honestly discloses them.

## Incident record (honesty)

One scratch mechanism test used a broad `pgrep -f 'sleep 30'` and killed 5 pids
(3513857 3514266 3514643 3514805 3514867) that were not mine. The reference trial sleeps
only 2/4/5/7 s, so OpenBao trial timing was unlikely affected; K49ExecTrial was notified.
Exact-pid kill discipline was restored for all subsequent steps; the hang-run orphan
(pid 3304553, identified by the fixture's unique marker) was killed by explicit pid.
Follow-up on that kill: my cleanup script's `pgrep -f <marker>` also matched its own
shell (the marker literal appears in the script text), so the kill list TERMed my own
service wrapper (its exit 143) alongside the intended bao process; the fixture dir was
left behind and removed manually afterwards. No third-party process was in that list.
Second incident, self-caught by peer attribution: my batch-shape probe's dev server
(pid 4144156) leaked — its `kill $SRV; wait` cleanup silently failed — and my
marker-based "no leftovers of mine" check missed it because that probe used a random
root id. Killed by explicit pid; the lane's sweep terminated it independently at
~21:43Z. Both of this seat's leaks (and the seven sibling ones) are the same
`kill`-does-not-contain failure class recorded as K49RP-3.

## Receipts

Copied to `.ufo/waves/round-49/build/K49ReviewerPlan-receipts/` (scratch deleted after
copy): `token-shapes.txt`, `k1f7-counter.txt`, `k1f7-direct.txt`, `c2-dirty-tree.txt`,
`c2-ledgerattack-withedit.txt`, `c2-ledgerattack-noedit.txt`,
`c2-attack-selfcounts-direct.txt`, `c2-dup-row.txt`, `hang-counter.txt`,
`hang-orphan.txt`.

## Verification status

- C1: predicate↔code MATCH; k1-f7 reproduced; token shapes probed; hang/timeout receipt
  appended below; no false-green path found beyond the plan's named ceilings.
- C2: false green K49RP-1 demonstrated with A/B; duplicate-row, dirty-tree, G6-words,
  case/format and stamps-dup paths all tried and held with receipts.
