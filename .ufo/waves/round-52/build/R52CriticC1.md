# R52CriticC1 — falsification report: C1 (OpenBao KV v2 version-lifecycle trial)

Seat: R52CriticC1 (critic, leaf). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch
`master`, BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`, predeclaration
`52ebb412561d9601ad8658c30d1cfa0087af64d4`. Instruments read, never edited:
`plans/round-52.md`, `plans/round-52-c1.sh`, `plans/round-52-controls.sh`,
`.ufo/waves/round-52/controls/fixtures/ref/`. Scratch (removed bodies/receipts copied here):
`/fast/scratch/hyaku/kagi-r52/R52CriticC1/`.

## Verdict

**C1's counter is falsified at its predicate level.** `value` is reachable without executing any
of T1..T5. Five forgeries outside the counter's named ceilings score ≥ 1; three of them score
**5**: F2 (five junk probes + the published vector table; no server, no KV operation), F5b
(creation-order rank of the sibling `.mode` files; no file content read) and F6 (real T1 only;
T2..T5 printed). F1 and F1b each score 1 from a single junk call.

Cause: the only mode-dependent binding in the predicate is `vec(sh_i)`. A trial that can tell
which run it is in and print `EXPECT_VEC` (published in the counter header) passes every test;
the real runs are checked only for the *presence* of HOLDS lines.

Mitigating fact, stated so the finding is not overstated: the kill rule pins the candidate's
trial to the reference fixture except comment lines, so a forged body cannot ship as this
round's candidate. The defect is in what the instrument *claims to measure* (plan §C1
"DISCRIMINATE", the named-ceiling list, control K1-F8), not evidence that the reference trial is
fake — the reference fixture passed 5 with 31 `bao` calls per real run.

## Environment (measured)

- `sha256sum ~/.local/bin/bao` = `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`
  = `PIN_BAO`; `/usr/bin/bao` and `/bin/bao` absent; `bao version` → `OpenBao v2.7.2
  (9e0a0d3c3504a0a00b45e61355afac5e35c78379)`.
- Fixture: `git archive 1d984ada | tar -x` + reference trial + reference entry + the S110 row
  exactly as `plans/round-52-controls.sh c1_ref/add_row` does; **only the trial is replaced**.
- Counter invocation per fixture: `bash plans/round-52-c1.sh --tree <fixture>`; exit code 0 in
  every run below; stderr empty in every run (`receipts/*.err` are 0 bytes).
- The shims were reproduced verbatim from the counter's `DISPATCH` string into
  `build/R52CriticC1/dispatch.sh` and probed without the counter (`probe.sh`,
  `receipts/probe.txt`); the counter runs then confirmed the same vectors.

## Counterexample table

| # | forgery (body in `build/R52CriticC1/`) | oracle | value | named ceiling? | smallest safe hardening |
|---|---|---|---|---|---|
| F1 | `f1-sh2probe.sh` | `kv undelete` (no `-versions`) exits 0 under SH2, 1 under the real CLI | **1** | no | SH2 must reproduce the CLI's local `No versions provided…` error and only fake when the real CLI would have contacted the server |
| F1b | `f1b-sh1probe.sh` | `kv put -cas=notanumber` reaches the network under SH1 (flag dropped) but fails locally under the real CLI | **1** | no | when dropping `-cas`/`-max-versions`, validate the value first and reproduce `invalid value …` |
| F2 | `f2-fingerprint.sh` | five junk probes (F1, F1b, `metadata put` bogus `-max-versions`, `destroy -h`, `metadata delete -h`) → printed table; no server, no KV call | **5** | no | all of F1/F1b, plus SH3/SH5 must answer `-h` with their own command's help; plus per-test call evidence and a server binding (below) |
| F3 | `f3-moderead.sh` | `cat $(dirname $(command -v bao))/.mode` | **5** | yes (`.mode`) | none — declared; keep as control |
| F4 | `f4-argvread.sh` | reads `.argv`; it records argv *before* the shim rewrites it, so it carries no mode bit | **0** | nominally yes (`.argv`), but it is not an oracle | correct the named-ceiling text: the adjacent oracle is `.mode` (content or metadata), not `.argv` |
| F5a | `f5a-outpath.sh` | own stdout path via `/proc/$$/fd/1`; the log name is random hex | **0** | no | none for this vector; move the logs out of the run-tree root to close F5b |
| F5b | `f5b-ctime.sh` | ctime rank of the seven sibling `.mode` files: the counter creates run dirs in fixed order and shuffles only execution | **5** | adjacent — reads metadata outside HOME/TMPDIR/--work, never `.mode` content | create the eight run dirs in `shuf` order (and/or `touch -d @0` the `.mode` files) |
| F6 | `f6-partial.sh` | real T1 against a dev server; T2..T5 printed HOLDS with no delete/undelete/destroy/metadata call | **5** | no | require each test's subcommand (with a path, not `-h`) in every real run's `.argv` |
| env | measured, no body | normalized `env -i` output is byte-identical in all six modes (`receipts/env-*.txt`, md5 `d7626e04ed9b6582191d98667cec8d84` for real/sh1..sh5) | **0** | no | none |
| ref | reference trial (sanity) | — | **5** | — | — |

Exact counter lines (`build/R52CriticC1/receipts/<name>.out`, one line per run):

```
ref C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=31,real2=31) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHBHH,entry=1,ok=1 T4:real=HOLDS/HOLDS,shimvec=HHHBH,entry=1,ok=1 T5:real=HOLDS/HOLDS,shimvec=HHHHB,entry=1,ok=1
f1 C1_OPENBAO_KV: value=1 discriminating=1 pins=1 setup_ok=1 nosecret=1 noargv=1(real=21,real2=21) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T4:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T5:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0
f1b C1_OPENBAO_KV: value=1 discriminating=1 pins=1 setup_ok=1 nosecret=1 noargv=1(real=21,real2=21) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T3:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T4:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T5:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0
f2 C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=25,real2=25) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHBHH,entry=1,ok=1 T4:real=HOLDS/HOLDS,shimvec=HHHBH,entry=1,ok=1 T5:real=HOLDS/HOLDS,shimvec=HHHHB,entry=1,ok=1
f3 C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=20,real2=20) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHBHH,entry=1,ok=1 T4:real=HOLDS/HOLDS,shimvec=HHHBH,entry=1,ok=1 T5:real=HOLDS/HOLDS,shimvec=HHHHB,entry=1,ok=1
f4 C1_OPENBAO_KV: value=0 discriminating=0 pins=1 setup_ok=1 nosecret=1 noargv=1(real=22,real2=22) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T2:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T3:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T4:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T5:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0
f5a C1_OPENBAO_KV: value=0 discriminating=0 pins=1 setup_ok=1 nosecret=1 noargv=1(real=20,real2=20) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T2:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T3:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T4:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0 T5:real=HOLDS/HOLDS,shimvec=HHHHH,entry=1,ok=0
f5b C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=20,real2=20) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHBHH,entry=1,ok=1 T4:real=HOLDS/HOLDS,shimvec=HHHBH,entry=1,ok=1 T5:real=HOLDS/HOLDS,shimvec=HHHHB,entry=1,ok=1
f6 C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=32,real2=32) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHBHH,entry=1,ok=1 T4:real=HOLDS/HOLDS,shimvec=HHHBH,entry=1,ok=1 T5:real=HOLDS/HOLDS,shimvec=HHHHB,entry=1,ok=1
```

Runs: ref 22 s, f1 13 s, f1b 12 s, f2 18 s, f3 13 s, f4 13 s, f5a 16 s, f5b 10 s, f6 13 s;
all rc 0. `nosecret=1`, `pins=1`, `src=1`, `setup_ok=1` in every run listed.

## Why the counterexample works

1. The predicate's only per-mode signal is the *whole vector* `vec(sh_i)`. `EXPECT_VEC` is in the
   counter header, and the entry lines are static text in the measured tree.
2. The shims are client-side bash dispatchers that rewrite argv; their lie is visible locally
   before any server exists:
   - SH2 answers `kv undelete` without `-versions`, where the real CLI errors locally
     (`No versions provided…`, rc 1) — 17 ms vs ~100 ms for every real invocation;
   - SH1/SH4 drop their flag before the CLI's own flag parser, so a deliberately invalid flag
     value flips a local parse error into `dial tcp … connection refused`;
   - SH3/SH5 pass `-h` through to the command they are rewritten to, so the help header names
     `bao kv delete` instead of `bao kv destroy` / `bao kv metadata delete`.
   `probe.txt` shows the six-way matrix: one call separates every shim from the real CLI.
3. The real runs are not bound to a server or to any call: F2 never starts `bao server` and
   still prints HOLDS in both real runs. `NOARGV` counts calls (≥ 20), so 20 `bao version`
   calls satisfy it (F2: 25 recorded calls, 5 probes + 20 versions).
4. F6 shows the same gap without any classification trick in the real run: one genuine
   mechanic (T1) plus four canned verdicts scores the same as the reference trial.

## Secondary findings

- **Control K1-F8 is vacuous.** Its body runs `p=$(readlink /proc/self/fd/1)` inside a command
  substitution, so `/proc/self` is the `readlink` process and its fd 1 is the substitution
  pipe, not the log file — measured `pipe:[1092481494]`
  (`receipts/fd1-substitution.txt`). The control then compares `"pipe:[…]"` to `sh<i>` and
  prints HOLDS everywhere: it reads 0 for the wrong reason and does not test "reads its own
  stdout path". My F5a uses `/proc/$$/fd/1`, actually obtains `$W/log/<hex>` (measured path in
  the same receipt), and still reads 0 — the log name is random hex, so that channel is
  genuinely closed; the control should be fixed to match its stated intent.
- **The named ceiling overstates `.argv`.** F4 reads it and cannot classify: the log records
  argv before rewriting, and the drops/rewrites are invisible in it. The real adjacent oracle
  is `.mode` — content (F3, 5) or metadata/order (F5b, 5).
- **The entry's Bounds acknowledge shim detection** ("A trial that detects its designated
  client-side shims … excludes those five lying CLIs"), but neither the plan nor the counter
  states the produceable consequence: a trial that detects the shim can print the expected
  vector without executing the mechanic it claims. The plan's named ceilings name `.mode`,
  `.argv` and cross-run state only.
- **Timing**: only SH2 is separable by timing (17 ms vs ~100 ms); the other shims pay the real
  CLI's startup, so a timing-only forger would score at most T2.

## Impacted axes

- **operability** (C1): the counter's `value=5` authenticates a printed protocol, not the five
  measured mechanics; the plan's sentence "DISCRIMINATE(T) … under T's designated falsifier
  prints the full five-verdict vector" is satisfied by F2/F5b/F6.
- No effect on **calibration** (C2 reads no trial/entry/row) and none on the harm baseline.
- Provenance: if this round's report leans on `value=5` as evidence that the mechanics ran,
  the evidence is weaker than written. The reference fixture is the only artefact that
  actually executes them (31 calls/run, server started), and the counter does not verify that
  either.

This is a **fixable defect**, not a tradeoff the canonical judge must accept: the counter can
either declare the ceiling or raise the forgery cost to the mechanic itself. It is not a reason
to reject the axis move by itself, because the kill rule pins the candidate's trial body to the
reference fixture.

## Smallest safe corrections (ordered, smallest first)

1. **Declare it, or harden it.** Amending the counter header + plan named ceilings with "a trial
   that identifies the client shim by behavioural probes (exit status, help text, flag-parse
   errors) and prints the expected vector scores 5 without executing any mechanic; the counter
   checks printed verdicts, not execution" is a two-sentence change and makes the report honest.
   Only if the round wants `value=5` to mean "executed" are 2–5 needed.
2. **Shim fidelity** (edits inside the `DISPATCH` string only):
   - SH2: if the real CLI would refuse locally (no `-versions`, no server), reproduce that
     refusal instead of faking success; only fake after the call would have reached a server.
   - SH1/SH4: validate the flag value before dropping it and print the CLI's
     `invalid value …` error on bad input.
   - SH3/SH5: intercept `-h` and print the claimed command's help (`bao kv destroy …`,
     `bao kv metadata delete …`).
   This removes every junk-call fingerprint measured above; the remaining way to tell the runs
   apart is to perform the mechanic's own call sequence, which is the measurement.
3. **Per-test call evidence.** `NOARGV` currently accepts 20 `version` calls. Require, in each
   real run, ≥ 1 call of `kv put`, `kv get`, `kv delete`, `kv undelete`, `kv destroy`,
   `kv metadata put`, `kv metadata get`, `kv metadata delete`; and in run sh<i> require the
   shim's target subcommand *with a path* (not `-h`). Kills F6's canned T2..T5 in the shim runs
   and the `version` padding.
4. **Bind the real runs to a server.** Require a `server` invocation in each real run's
   `.argv`. F1/F1b/F2/F5b start no server at all.
5. **Close the order channel.** Create the eight run dirs in `shuf` order (`for m in $(… | shuf)`)
   and/or `touch -d @0` every `.mode`; put the logs in a separate `mktemp -d` so `/proc/$$/fd/1`
   does not leak the parent of `run/`.
6. **Add control K1-F9 = F2** (behavioural classifier + canned table) with expectation 0, and
   fix K1-F8's body to read `/proc/$$/fd/1`. If K1-F9 still reads 5 after 2–4, the precondition
   for C1 (that `value` tracks execution) is not met and the counter cannot carry the claim.

None of 3–5 makes the counter *prove* semantics — printed output is always forgeable by a
same-author trial that knows the table; they raise the cost of faking to the mechanic itself.
The honest ceiling remains: without the counter observing the server itself, a trial that can
classify the run can print the vector.

## Reproduction

```
bash plans/round-52-c1.sh --tree <fixture>      # rc 0, last line: C1_OPENBAO_KV: value=… (see table)
```
Fixtures: `/fast/scratch/hyaku/kagi-r52/R52CriticC1/fx-<name>` (recreated per run from
`…/base`: `git archive 1d984ada` + reference trial/entry + S110 row; trial replaced), removed
after each run. Receipts copied to `build/R52CriticC1/receipts/` (`<name>.out`, `<name>.err`,
`probe.txt`, `env-*.txt`). Shim matrix: `build/R52CriticC1/probe.sh` against
`build/R52CriticC1/dispatch.sh`; mock vectors: `build/R52CriticC1/mocktest.sh`.

## Limits

- Only the trial was replaced; entry and SOURCES.md are the reference fixture's, so every run
  had `entry=1` and `src=1` by construction.
- No real secret, token, key or vault was touched; the forgeries never contact a server except
  F6, which starts a throwaway `bao server -dev` on a random free 127.0.0.1 port with a random
  hex root token passed by `BAO_DEV_ROOT_TOKEN_ID` (never argv), kills it in an `EXIT` trap,
  and prints no token. Every receipt reports `nosecret=1` and `noargv=1`.
- One OpenBao version (2.7.2); the `.argv`/`.mode`/order findings are properties of the frozen
  counter, not of OpenBao.
- I did not run `claim-ledger.sh verify` (not this item).
- Unrun checks: none claimed. Every value in the table comes from a counter run whose receipt
  is copied into the build directory.
