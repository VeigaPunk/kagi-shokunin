# R53ReviewerC2 — C2 (self-count calibration) change and counter review

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master.
BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`; candidate `36d0a86a7539890eb079d893c9a58e37e84d953d`.
Scope: `git diff BASE CAND -- SKILL.md PROVINCE.md corpus/README.md`, `plans/round-53-c2.sh`, and the
counter's measured behaviour. Every reading below is from a `git archive CAND` extraction at
`/fast/scratch/hyaku/kagi-r53/R53ReviewerC2` or a `--tree` copy of it; BASE bytes were read with
`git show BASE:<path>`.

## Verdict

No defect found that changes C2's value. The counter reproduces both recorded readings exactly:

| run | command | result | wall |
|---|---|---|---|
| BASE | `bash plans/round-53-c2.sh c1953d4afc19a5a336a58685c00ab5260bcfea1c` | `C2_SELF_COUNTS: value=5 (bad=STALE:SC-SKILL-STAMPS STALE:PV-STAMPS STALE:RD-STAMPS STALE:RD-DOCS-ROWLINKED STALE:RD-DOCS-ENTRIES; summary=SELF_COUNTS: POLICY (claims=63 stale=5 unlocated=0 ambiguous=0 policy=2 setup=0))` exit 0 | 86.9 s |
| CAND | `bash plans/round-53-c2.sh 36d0a86a7539890eb079d893c9a58e37e84d953d` | `C2_SELF_COUNTS: value=0 (bad=; summary=SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0))` exit 0 | 86.9 s |

Both strings are byte-identical to `.ufo/waves/round-53/controls/c2-base.txt` (5) and
`.ufo/waves/round-53/final/c2-candidate-tree.txt` (0). Target 0 / BASE 5 confirmed.

## The four corrected statements — stated vs live

Live sources measured on the CAND extraction: stamps `grep -c '[^[:space:]]' corpus/stamps.tsv` (the
command of ledger row R12-03), claim rows `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` (R21-04),
knowledge declarations `bash corpus/claim-ledger.sh docs` (R14-01).

| statement | file:line | stated | live | agree |
|---|---|---|---|---|
| revision stamps | SKILL.md:46 | 125 | 125 | yes |
| claim rows | SKILL.md:46 | 86 | 86 | yes |
| revision stamps | PROVINCE.md:73 | 125 | 125 | yes |
| claim rows | PROVINCE.md:73 | 86 | 86 | yes |
| revision stamps | corpus/README.md:65 | 125 | 125 | yes |
| row-linked entries | corpus/README.md:67 | 34 | 34 (`row_linked=34`) | yes |
| by-hand entries | corpus/README.md:67 | 3 | 3 (`by_hand=3`) | yes |
| pinned entries | corpus/README.md:67 | 37 | 37 (`entries=37`, `unpinned=0`) | yes |

`bash corpus/claim-ledger.sh docs` last line on the candidate tree:
`DOC_AUDIT: CLEAN (entries=37 row_linked=34 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`,
exit 0. The "37 pinned" wording is backed by `entries=37` with `unpinned=0` enforced by the R14-01 expect
cell; the binding captures `entries=([0-9]+)`.

BASE quantities behind the five STALE readings: stamps 125 (`git show BASE:corpus/stamps.tsv | grep -c
'[^[:space:]]'`), knowledge entries 37 (`git ls-tree --name-only BASE corpus/knowledge/ | grep -c '\.md$'`),
claim rows 86 — i.e. the BASE prose (124 / 33 / 36) was stale against its own tree, exactly as the frozen
predicate states.

Prose attribution spot-checks (same commit):
- README.md:65 "the round-52 KV v2 entry pin made the live count 125": stamps went 124 at round-51
  candidate `47d0959` to 125 at round-52 candidate `a2cb69b`, and `a2cb69b` adds
  `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` to `corpus/stamps.tsv`. Accurate.
- README.md:67 "the round-52 OpenBao KV v2 version-lifecycle entry … had not been counted here": that
  file is the round-52 addition (`git diff --name-status 47d0959 a2cb69b -- corpus/knowledge/`), and it
  carries `Reverify: R21-02` (row-linked) and one stamp row. Accurate.
- SKILL.md:48 / SKILL.md:787 / PROVINCE.md:75 "byte-pinned round-53 receipt `observe-r53.json`":
  `DEFAULT_RECEIPT_SHA256 = f927b4318dee90ad3e2a8e2f899fcd2e37c43e833e7c3c3705aa5b5723d37c9a` equals
  `sha256sum` of the receipt at CAND and in the working tree; `python3 corpus/release-clock.py` on the
  CAND tree ends `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)`,
  exit 0. No `round-46 receipt` default reference remains in the three files.

## Did the corrections break another binding on the same lines?

The BASE checker run over the CAND tree (BASE `corpus/self-counts.py` + BASE `corpus/self-counts.tsv`,
`--root` on the extraction) reports `stale=0 unlocated=0 ambiguous=0` over `claims=63`, so no binding on
the edited lines became STALE, UNLOCATED or AMBIGUOUS. Full capture
(`/fast/scratch/hyaku/kagi-r53/R53ReviewerC2/checker-cand.txt`, 64 lines, exit 2): 61 `OK` + 2 `POLICY`
+ the summary line = 63 claims. Every binding on an edited line:

```
OK SC-SKILL-STAMPS SKILL.md:46 claimed=125 live=125
OK SC-SKILL-CLAIMS SKILL.md:46 claimed=86 live=86
OK SC-CLOCK-SELFTEST SKILL.md:48 claimed=116 live=116
OK PV-STAMPS PROVINCE.md:73 claimed=125 live=125
OK PV-CLAIMS PROVINCE.md:73 claimed=86 live=86
OK PV-CLOCK-SELFTEST PROVINCE.md:75 claimed=116 live=116
OK RD-STAMPS corpus/README.md:65 claimed=125 live=125
OK RD-DOCS-ROWLINKED corpus/README.md:67 claimed=34 live=34
OK RD-DOCS-BYHAND corpus/README.md:67 claimed=3 live=3
OK RD-DOCS-ENTRIES corpus/README.md:67 claimed=37 live=37
```

The two non-OK lines are the frozen policy pair, not the edited files:
`POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted` and
`POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted` — R29-01/R29-02 start with `python`,
and `ALLOWED_COMMANDS = {"bash", "grep", "python3"}` (`corpus/self-counts.py:54`).
A sweep for leftover stale wording (`124 revision stamps|124 stamps|(124 `, `33 row-linked|36 pinned`)
over the three files returns nothing.

The frozen predicate sentence in `plans/round-53-c2.sh:6-8` and in `plans/round-53.md` §C2 is identical
after stripping comment markers (checked programmatically).

## Counter properties → implementation line

| property | line(s) in `plans/round-53-c2.sh` | evidence |
|---|---|---|
| frozen predicate, target 0 / BASE 5 | 6-8, 35 | text identical to plan; BASE run = 5 |
| BASE bytes are the only checker/table used | 51-53 (`git show "$BASE:$f" > "$SCR/b/…"`), 54 (`git ls-tree "$BASE"`), 79 (`python3 "$SCR/b/self-counts.py" --root "$T" --table "$SCR/b/self-counts.tsv"`) | forged-tree run: the tree's `corpus/self-counts.py` replaced by a stub printing `SELF_COUNTS: CLEAN (claims=1 stale=0)` and `corpus/self-counts.tsv` replaced by a one-row table → `C2_SELF_COUNTS: SETUP setup=2`, exit 2. The counter passed the `claims=63` gate (line 86) before failing at `setup=2` (line 87), which is only possible with the BASE table, and the full-tuple regex (line 82) matched, which the stub cannot emit — so the BASE checker ran. The `setup=2` errors are the two claims bound to ledger:R25-01, whose pinned command `python3 corpus/self-counts.py --selftest` executed the tree's forged stub (`extract did not match`) — the named ceiling, turned into SETUP rather than a value |
| GUARD g1 (ledger/expect cells equal BASE) | 60-74 | variants: command forged → `SETUP guard:g1:R12-03:command`; row duplicated → `rows=2`; row deleted → `rows=0`; expect cell forged → `SETUP guard:g1:R12-02:expect`; all exit 2 |
| GUARD g2 (`claim-ledger.sh` byte-equal) | 75 | appended line → `SETUP guard:g2`, exit 2 |
| GUARD g3 (stamp path population) | 76 | first stamp row deleted → `SETUP guard:g3`, exit 2 |
| GUARD g4 (knowledge entry file list) | 77 | added `corpus/knowledge/zz-forged.md` → `SETUP guard:g4`, exit 2 |
| GUARD g5 (policy findings = BASE pair) | 88-89 | shim emitting `POLICY PV-OTHER …` → `SETUP guard:g5:PV-FEEDTOKEN-SELFTEST PV-OTHER`, exit 2 |
| empty checker output is SETUP | 80-81 | python3 shim with no output → `SETUP empty-output`, exit 2 |
| missing / misplaced summary | 82-83 | shim `hello` → `SETUP summary:hello`; valid summary followed by `tail` → `SETUP summary:tail`; both exit 2 |
| extra summary line | 85 | two valid full-tuple summaries → `SETUP summary-count`, exit 2 |
| claims pinned to 63 | 86 | summary `claims=62` → `SETUP claims=62`, exit 2 |
| setup counter pinned to 0 | 87 | exercised by the forged-tree run: the checker summary carried `setup=2` → `SETUP setup=2`, exit 2 |
| summary agrees with per-line findings | 90-92 | one STALE line + summary `stale=0` → `SETUP summary-mismatch:m=1`, exit 2 |
| value = M, exit 0 | 93 | shim with the BASE policy pair + one STALE line → `value=1 (bad=STALE:SC-SKILL-STAMPS; …)`, exit 0 |
| bad revision / no revision / missing tree | 36, 43-49 | `SETUP bad-revision`, `SETUP no-revision`, `SETUP tree`; all exit 2 |
| scratch discipline | 38-40 | `$HYAKU_SCRATCH/kagi-r53/c2.$$`, `trap 'rm -rf' EXIT`; runs left no residue |

Guard coverage of the BASE table: 20 distinct `ledger:`/`expect:` ids (16 ledger + 4 expect); the 4
`rows:` sources are unpinned data files, which is the counter's declared ceiling.

## Findings

No defect that changes C2's value.

- **F1 (low, guard scope, no value effect).** GUARD g1 compares only columns 2-3 of the measured
  `corpus/claim-ledger.tsv` (command compare lines 66-68, expect compare 70-72); columns 4-6 (expected exit, timeout, note) are not compared.
  Column 6 is where the checker reads the `[host]`/`[substrate]` tag (`ledger_command`, BASE
  `corpus/self-counts.py:260`). Of the 20 referenced ids, only R11-03/R16-03 (`[substrate]`) and R18-01
  (`[host]`) are tagged, and all three are `expect:` sources that are never executed; the 16 `ledger:`
  sources are untagged. A forged note cannot change the value: stripping a tag on an expect row is inert,
  and adding one to a ledger row was run — appending `[host]` to R12-03's note makes the counter return
  `SETUP guard:g5:PV-FEEDTOKEN-SELFTEST PV-FEEDTOKEN-SHAPES PV-STAMPS RD-STAMPS SC-SKILL-STAMPS`, exit 2
  (the three claims bound to R12-03 become POLICY findings, and the name set enters g5). Columns 4-5
  (expected exit, timeout) likewise cannot move a number on their own: the command is pinned, and a
  mismatched exit is SETUP; they only matter combined with an unpinned tool, which is the declared ceiling.
  The two real POLICY findings come from the command allowlist, not from tags.
- **F2 (informational).** The value path exists only because the BASE checker prints the full
  `claims=… stale=… unlocated=… ambiguous=… policy=… setup=…` tuple on its POLICY/SETUP branch
  (`corpus/self-counts.py:363-368`); `CLEAN` prints `SELF_COUNTS: CLEAN (claims=63 stale=0)` and `STALE`
  prints a four-field tuple, neither of which matches the counter's regex (line 82). The pair is frozen
  twice over — by the BASE checker bytes and by g1 pinning R29-01/R29-02's commands — so the value path is
  stable for this round; the coupling only matters if a later round changes the BASE allowlist or those
  commands, which is a counter revision, not a defect here.
- **F3 (cosmetic).** At value 0 the `bad=` field is empty, producing `(bad=; summary=…)`. Matches the
  recorded receipt and the predicate's documented output shape.
- **F4 (low, plan-vs-diff accuracy, no value effect).** `plans/round-53.md:88` says "the four statements
  carry the live numbers, each with a round-53 parenthetical naming the correction". Only the two
  `corpus/README.md` rows carry one (`README.md:65`, `README.md:67`); `SKILL.md:46` and `PROVINCE.md:73`
  changed the number alone (`grep -oE 'round.?53'` on each line → 0). The counts are right; the plan's
  description of the change's shape is not. Nothing in the counter reads the prose, so C2's value is
  unaffected.

## Residual risk and verification gaps

- Named ceilings are real and material: the 4 `rows:` data files (`surface-census.tsv`, `state-shape.tsv`,
  `drift-baseline.tsv`, `drift-symbols.tsv`) are not pinned, and a tool invoked by a pinned ledger command
  is not pinned (g2 covers only `claim-ledger.sh`). The BASE checker takes a ledger command's last line as
  live truth and never compares it to the row's expect cell (`last_output` checks only the exit code), so a
  forged tool that prints the doc's number would read OK. The forged-tree run shows the benign half of this:
  a forged `corpus/self-counts.py` broke R25-01 and the counter returned `SETUP setup=2`, not a value.
- The one tool this candidate changes that a binding executes is `corpus/release-clock.py` (R25-03,
  `--selftest`); its live output on the candidate tree is `RELEASE_CLOCK_SELFTEST: PASS (116 cases)`, which
  matches the docs' 116 and the row's expect cell — but C2 itself does not verify that pin (the lane's
  `verify` does), so C2's 0 depends on R25-03's expect cell being honest.
- g3 compares only the stamp *path* population (`cut -f1`), not hashes/line/byte columns; a re-pinned row
  with a wrong hash is invisible to the counter (the lane's `verify` covers it, not this counter).
- I did not run the lane's full `claim-ledger.sh verify` (not named by this item). The recorded candidate
  receipt `.ufo/waves/round-53/final/verify-candidate-tree.txt` ends
  `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)` rc=2 with FAIL rows R11-08/R36-01 (timeout 300),
  R22-03/R24-15/R25-02 (exit 2 in a scratch copy) and MISSING-ID rows — consistent with its own header
  note that R22-03/R24-15 need git history; I did not adjudicate those.
- The round-53 lesson `corpus/lessons/round-53.md` is not in `corpus/stamps.tsv` (the round-52 lesson is
  also unstamped), so the candidate's "restamp" leaves the lesson unstamped; out of C2's scope and
  consistent with the round-52 precedent, but it is a citation-surface question for the landing, not for
  this counter.

## Receipts (commands run, exit codes, last line)

Scratch root `/fast/scratch/hyaku/kagi-r53/R53ReviewerC2` (`HYAKU_SCRATCH` passed per command; no
`c2.*` residue after the runs — the counter's `trap` fired).

```
bash plans/round-53-c2.sh c1953d4afc19a5a336a58685c00ab5260bcfea1c   # exit 0, 86.9 s
  C2_SELF_COUNTS: value=5 (bad=STALE:SC-SKILL-STAMPS STALE:PV-STAMPS STALE:RD-STAMPS STALE:RD-DOCS-ROWLINKED STALE:RD-DOCS-ENTRIES; summary=SELF_COUNTS: POLICY (claims=63 stale=5 unlocated=0 ambiguous=0 policy=2 setup=0))
bash plans/round-53-c2.sh 36d0a86a7539890eb079d893c9a58e37e84d953d   # exit 0, 86.9 s
  C2_SELF_COUNTS: value=0 (bad=; summary=SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0))
python3 <BASE self-counts.py> --root <CAND tree> --table <BASE table>  # exit 2, 96.8 s, 64 lines
  SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)
bash corpus/claim-ledger.sh docs                                        # exit 0
  DOC_AUDIT: CLEAN (entries=37 row_linked=34 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)
python3 corpus/release-clock.py                                         # exit 0
  RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)
python3 corpus/release-clock.py --selftest                              # exit 0
  RELEASE_CLOCK_SELFTEST: PASS (116 cases)
--tree guard variants (each exit 2): guard:g1:R12-03:command | guard:g1:R12-03:rows=2 |
  guard:g1:R12-02:expect | guard:g1:R12-03:rows=0 | guard:g2 | guard:g3 | guard:g4 |
  guard:g5:PV-FEEDTOKEN-SELFTEST PV-OTHER | empty-output | summary:hello | summary-count |
  summary:tail | summary-mismatch:m=1 | claims=62 | no-revision | bad-revision | tree
--tree value control (shim): exit 0 -> C2_SELF_COUNTS: value=1 (bad=STALE:SC-SKILL-STAMPS; …)
--tree forged tool+table: exit 2 -> C2_SELF_COUNTS: SETUP setup=2
--tree forged note ([host] appended to R12-03): exit 2 -> C2_SELF_COUNTS: SETUP guard:g5:PV-FEEDTOKEN-SELFTEST PV-FEEDTOKEN-SHAPES PV-STAMPS RD-STAMPS SC-SKILL-STAMPS
```

Raw copies in this directory: `R53ReviewerC2-receipts.txt` (every run above, exact output),
`R53ReviewerC2-checker-cand.txt` (the 64-line checker capture), `R53ReviewerC2-c2-base-observed.txt`
and `R53ReviewerC2-c2-cand-observed.txt` (byte-identical to the recorded receipts, verified with `diff`).
Stamp attribution check: the round-51→round-52 path-set difference (`LC_ALL=C comm` on the two
`corpus/stamps.tsv` path lists) is exactly one added path,
`corpus/knowledge/openbao-kv-v2-version-lifecycle.md`, 124 → 125.
