# Round 52 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b` (branch `master`; the
round-51 verifier spot-check landed at this tip and admitted round 51).
Counters: `plans/round-52-c1.sh`, `plans/round-52-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-52-controls.sh`
(fixtures `.ufo/waves/round-52/controls/fixtures/ref/`; receipt
`.ufo/waves/round-52/controls/controls-prefreeze.txt`; run 1 kept as `controls-prefreeze-run1.txt`: K2-P,
K2-F3 and K2-F6 read one higher than written because the C2 counter took a `<!--` inside an inline code
span at `corpus/lessons/round-51.md:15` for an HTML comment opener; the counter now masks code spans and
control K2-F8 was added, both before the freeze). Census at round start:
`.ufo/waves/round-52/controls/census-start.txt` (`kagi ok`, rc 0). Predeclaration commit: recorded in
the report. No earlier attempt of this round exists (`.ufo/watchdog.log`: one launch line for round 52).

## Axes and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation: line 9, window N = 3).
Capabilities entered in rounds 49 and 51 inside the window of rounds 49–51, so the nudge does not fire.
Every axis is tied lowest at 9, so each claim works a lowest-scoring non-retired axis. C1 is a capability
acquisition booked under operability; C2 works the owned calibration axis. No axis is retired or split.

Causal separability: C1 adds `corpus/openbao-kv-versions-trial.sh`, the knowledge entry
`corpus/knowledge/openbao-kv-v2-version-lifecycle.md` and one registry row (expected id S110); its
counter reads no file C2 changes. C2 appends one correction line to each of
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md` and `corpus/lessons/round-51.md`; its counter
runs its own probe and reads no trial, entry or registry row C1 adds. Control K1-P (C1 change only)
reads 5 and K2-P (C2 change only) reads 0.

## C1 — operability: the lane executes the OpenBao KV v2 version-lifecycle mechanics its source documents, 0 → 5

Capability acquisition (`AXES.md` §Capabilities). Ground the lane did not hold: at BASE no corpus file
names `undelete` (`git grep -il undelete 1d984ada -- corpus` prints nothing); the only KV v2 row (S024)
is Vault's `max_versions` backend parameter as documentation, never executed, and no row cites the
OpenBao KV v2 page. Source (opened this round, 2026-11-07, capture `.ufo/waves/round-52/capture/S110.body`,
decoded body sha256 `6cfd72eca347d0dfbcea73ad429ae5db3f01f2710cd794a473b00047e02b1587`, 83532 B, OpenBao
docs Version 2.7.x): https://openbao.org/docs/secrets/kv/kv-v2/.

Change: `corpus/openbao-kv-versions-trial.sh` (reference fixture
`.ufo/waves/round-52/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh`) runs five tests against a
throwaway `bao server -dev` on 127.0.0.1: T1 check-and-set, T2 soft delete is recoverable, T3 destroy is
permanent, T4 max-versions drops the oldest version, T5 metadata delete removes every version. It carries
the round-51 routed fixes: no secret on any argv (root token by `BAO_DEV_ROOT_TOKEN_ID`, values by `v=-`
on stdin; S-1), no server log (S-2), the probed port must be held by our server pid (S-3), a refusal needs
a non-zero exit AND the server's refusal text, an unparsed answer is ERROR (M51-3). New entry
`corpus/knowledge/openbao-kv-v2-version-lifecycle.md` with `## Measured (round 52 …)`, one `- T<n> ` line per
test; registry row S110 (tier A, `mined`, `recheck 180d`).

Frozen predicate:
`C1_OPENBAO_KV: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and NOARGV = 1 and SRC = 1, else 0; target 5 (BASE 0, trial absent).`
DISCRIMINATE(T): both real runs print exactly one `TRIAL T HOLDS` line, and under T's designated
falsifier (SH1 `kv put` drops -cas, SH2 `kv undelete` answers success without acting, SH3 `kv destroy`
becomes `kv delete`, SH4 `kv metadata put` drops -max-versions, SH5 `kv metadata delete` becomes
`kv delete`) the trial prints the full verdict vector `EXPECT_VEC` (sh1 BHHHH, sh2 HBHHH, sh3 HHBHH,
sh4 HHHBH, sh5 HHHHB), and the entry's round-52 Measured section holds a `- T<n> ` line naming
`OpenBao 2.7.2`. The counter adopts the round-51 hardenings (routed item 2): random log ids (H1), the
real run twice at random positions (H2), full vectors (H3). NOARGV: each real run makes ≥ 20 recorded bao
calls and no argv element is token- or nonce-shaped. Details in the counter header.

Controls (expected values written before the run; `plans/round-52-controls.sh`): K1-0 BASE 0; K1-P
reference 5; K1-F1 constant-HOLDS printer 0; K1-F2 values on argv 0; K1-F3 `.mode` reader 5 (named
ceiling, expected to pass); K1-F4 registry row absent 0; K1-F5 Measured section absent 0; K1-F6 trial
leaks one nonce 0; K1-F7 registry row `queued` 0; K1-F8 round-51 FA (reads its own stdout path) 0.

Kill rules (any fires ⇒ C1 not admitted): `plans/round-52-c1.sh`, `plans/round-52-c2.sh`,
`plans/round-52-controls.sh`, this plan or the fixtures differ between the predeclaration and the
candidate; the candidate's `corpus/openbao-kv-versions-trial.sh` differs from the reference fixture in any
line that does not start with `#`; any committed file at the candidate matches `r52-[0-9a-f]{24}`;
`~/.local/bin/bao` is replaced (the pin).

Named ceilings: a trial that reads the `.mode` file or the `.argv` log beside its bao (K1-F3 reads 5), or
keeps state outside its own HOME/TMPDIR/--work across runs, still tells the runs apart; the shims are
client-side; one OpenBao version (2.7.2), the dev server's KV v2 mount only; T3/T4 show data is no longer
served, not that storage erased it.

## C2 — calibration: the lane's committed statements about rewrap agree with the pinned binary, 2 → 0

Problem (round-51 closure D1, `corpus/lessons/round-51-verifier-spotcheck.md:104`; measured at BASE,
`bash plans/round-52-c2.sh 1d984ada` → `value=2`): `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292`
and `corpus/lessons/round-51.md:22` say the rewrap API page's sample shows `sys/wrapping/wrap` "for a
rewrapped token, which this binary does not do". The probe reads `sys/wrapping/wrap` for a rewrapped
helper-made token and `secret/data/<path>` for a rewrapped KV token: the sample omits its input's path and
is consistent with the binary. The lane's self-description of what it measured disagrees with the binary.

Change: append one correction line (`Correction (round 52, D1) …`) to each of the two files, naming the
corrected `<file>:<line>` and stating both measured creation paths. No BASE line is rewritten
(append-only errata).

Frozen predicate:
`` C2_REWRAP_STATEMENTS: value = U, the number of lane-authored assertion lines that pair `rewrap` with a judgement of the documentation or the binary and carry no truth-bound correction, when GUARD = 1 and PROBE = 1, else SETUP; target 0 (BASE 2). ``
Scope, assertion pattern, correction syntax, PROBE and GUARD are defined in the counter header.

Controls: K2-0 BASE 2; K2-P both corrections 0; K2-F1 corrections with the two literals swapped 2;
K2-F2 corrections inside HTML comments 2; K2-F3 entry correction points at `:29` 1; K2-F4 a BASE line
rewritten SETUP; K2-F5 corrections appended to LOG.md instead 2; K2-F6 positive plus a new uncorrected
assertion in another entry 1; K2-F7 only the entry corrected 1; K2-F8 entry correction whose two
literals sit in a same-line HTML comment 1.

Kill rules: the instruments differ between predeclaration and candidate; any BASE line of the two
files changes (the counter's GUARD reads SETUP).

Named ceilings: the assertion pattern is lexical; the probe measures OpenBao 2.7.2 only; the counter
checks the correction's pointer and literals, not its prose; seat evidence under `.ufo/` (R51ScoutSource
§4a) is out of scope by construction and is corrected by reference in the round-52 lesson. The lexical
ceiling has a known instance at BASE: `SCORECARD.md:1778` (round-51 depth row, "unlike the rewrap API
page's sample response") states the same over-read in words the pattern does not match; it gets an
appended SCORECARD erratum this round and is not counted (BASE 2 stays the frozen population).

## Frontier step and non-claim work (no counter; recorded in the lesson)

- Sourced claim: C1 rests on S110, opened this round; quotes located with
  `corpus/rendered-text-v1.py locate` against the committed capture (`count=1` each).
- Mined mistake: the round-51 over-read (D1, class `doc-over-read`: a rejection reason asserted a
  documentation/binary disagreement the sample does not state); captured-by none; the C2 counter is the
  fix shown able to fail (K2-0 reads 2, K2-F1 reads 2).
- Round-51 closure defects: D1 → C2; D2 → every receipt the candidate cites lands in or before the
  candidate commit; D3 → S-1/S-2/S-3/M51-3 fixed in the new trial (the round-51 trial is not edited this
  round), c1h hardenings adopted in C1's counter, R51CriticC2 N7/N8/N11/N13 and R11-08/R36-01 stay routed.
- Harm check: full `claim-ledger.sh verify` on a clean clone of BASE and of the landing tip, FAIL/POLICY
  ids compared.
