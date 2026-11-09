Author: R70MutTester (mutation-tester)

# Round-70 C1 mutation probe (R70MutTester)

Claim: `C1_PKI_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when
PINS=1 SETUP_OK=1 NOSECRET=1 NOLEAK=1 SOURCED=1, else 0; target 5 (BASE 0)`.
Detector: frozen counter `bash plans/round-70-c1.sh --tree $S/m<k>` (sha256
`8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed`, matches
`.ufo/waves/round-70/controls/receipts/counter.sha256`). Each mutant lives in its own
fixture tree `$S/m<k>/` containing `corpus/openbao-pki-trial.sh` (mutated),
`corpus/knowledge/openbao-pki-certificate-lifecycle.md` and `corpus/SOURCES.md` copied
from the lane. Predictions were written before running (`$S/predict.tsv`); the frozen
counter was run once per mutant (max 1 concurrent, ~50 s each, 7 trial runs per counter).
Pristine baseline: `plans/round-70-controls.sh` P1 receipt
(`.ufo/waves/round-70/controls/receipts/p1.txt`, value=5 rc=0) — the landed trial is
bytes-identical to P1; not re-run by this seat (detector is the frozen counter itself).

## Results (6 killed, 2 survived)

| id | class | diff summary | predicted | observed | verdict |
|---|---|---|---|---|---|
| M1 | drop private_key check (T1 always HOLDS) | removed `jhas private_key` branch; unconditional HOLDS when certificate present | value=4 killed | value=4 (`T1:real=HOLDS,shim=HOLDS,spec=1,entry=1,ok=0`) | killed |
| M2 | widen T2 bound 3660 -> 100000 | `[ "$lt" -le 100000 ]` | value=4 killed | value=4 (`T2:real=HOLDS,shim=HOLDS,spec=1,entry=1,ok=0`) | killed |
| M3 | T3 checks only inside CN | removed outside-CN write; unconditional HOLDS after control issued | value=4 killed | value=4 (`T3:real=HOLDS,shim=HOLDS,spec=1,entry=1,ok=0`) | killed |
| M4 | T4 greps serial without colon-strip | `want` keeps colons (`tr -d ':'` removed); openssl CRL text has no colons | value=4 killed (T4 real=BROKEN) | value=4 (`T4:real=BROKEN,shim=BROKEN,spec=0,entry=1,ok=0`, `real_rc=1`) | killed |
| M5 | T4 checks serial nonempty not CRL | HOLDS iff `-n $ser` instead of `openssl crl -text` grep | value=4 killed | value=4 (`T4:real=HOLDS,shim=HOLDS,spec=1,entry=1,ok=0`) | killed |
| M6 | T5 drops list check | removed `\|\| grep` list; read-only BROKEN condition | predicted SURVIVED value=5 | value=5, rc=0 (all legs ok=1) | **survived** |
| M7 | T5 drops read check | removed `q read`; list-only BROKEN condition | predicted SURVIVED value=5 | value=5, rc=0 (all legs ok=1) | **survived** |
| M8 | prints root token on stderr | added `echo "root token: $TOK" >&2` before server start | value=0 killed (`nosecret=0`) | value=0 (`discriminating=5 nosecret=0`, rc=1) | killed |

Full `mutants.tsv` (id, class, diff summary, predicted, observed value line, killed) and
per-mutant counter receipts `run-m<k>.txt` are in `.ufo/waves/round-70/w1/R70MutTester/`;
mutant byte hashes in `hashes.txt` there. Mutants were scratch-only; the lane trial was
never edited (pristine sha256 `200efcb2850df8e729631de1772f4423ef0ac90a8bb1b9a06e4fc499bdc8023d`
unchanged); no commit, no lane mutation.

## Analysis of survivors

### M6 (T5 drops list check) and M7 (T5 drops read check) — survived, falsifies-wording

The frozen plan (round-70.md §C1) and the knowledge entry both state T5's property as a
conjunction: "a `no_store=true` role's certificate is **neither readable** at `cert/<serial>`
**nor listed**, while a stored control certificate is" (trial header, entry T5 line, entry
table row, entry falsifier 5: "readable **or** listed"). The trial implements this as
`elif q read pki/cert/"$s5" || grep -q "\"$s5\"" "$S/certs.json"; then BROKEN`.

The counter's only T5 falsifier is SH5 (role drops `no_store=`): under SH5, the no_store
leaf is **both** readable **and** listed, so either single half alone (read-only M6,
list-only M7) still goes BROKEN under SH5, HOLDS on real, and passes specificity (no other
shim affects T5). Hence both mutants read `value=5`. The counter therefore does **not**
distinguish the stated conjunction from either half: a trial that checked only one of the
two (un)availability legs would be indistinguishable from the shipped trial under all five
falsifier shims plus the real binary. This is precisely a stated-property weakening the
instrument cannot see — the measured value certifies "T5 discriminates" while the
disjunctive-enumeration half (or the readability half) could be absent without any counter
leg moving.

That is falsifies-wording, not falsifies-number: the number 5 is correctly computed from
the instrument's own definition of DISCRIMINATE; what is falsified is the prose/wording
that T5 (and the C1 claim via it) covers both legs — the entry/trial header promise
"neither ... nor" more than the five shims can enforce. A second, asymmetric falsifier
(e.g. a shim that lists but does not store, or stores but does not list) would be needed to
kill M6/M7; per scope rules, this is recorded as a coverage finding, not a contract change.

Why M6/M7 are the strongest surviving mutants: SH5 is maximally breaking on T5 (drops the
whole `no_store` flag, so both legs break together). Any falsifier that breaks only one
leg would separate them; none exists in the frozen set, and the counter is frozen, so the
gap is a property of the frozen instrument, not of this mutation.

## Notes on killed mutants (instrument health)

- M1/M2/M3/M5 (check removal / bound widening / half-check): each killed by the designated
  shim returning HOLDS where BROKEN was required (`ok=0` on exactly that test, others
  `ok=1`). The specificity leg held: no mutant broke a foreign test (all `spec=1` except
  M4's `T4 spec=0`, a real-run failure, not a specificity leak).
- M4 (format-preserving mutation: serial without colon-strip): killed by the real run
  itself (`T4:real=BROKEN`, `real_rc=1`). The CRL-text comparison is load-bearing and
  brittle to formatting — the counter catches it via the real leg, not the shim leg.
- M8 (secret print): killed via `nosecret=0` → `final=0` even with `discriminating=5`.
  The NOSECRET leg is independent of the trial's verdicts, as designed (cf. F6 prefreeze
  control). The dev root token value itself is never printed here; only the counter's
  `nosecret` verdict is cited.
- No mutant triggered `setup_ok`/`noleak`/`sourced` movement: settlement-only and
  hygiene legs were stable across all eight runs (all `pins=1 setup_ok=1 noleak=1
  sourced=1 none_rc=2`).

## Method / scope compliance

- 8 mutants, 8 counter runs, 1 concurrent, each `--tree $S/m<k>` from the lane dir.
- Predictions (`$S/predict.tsv`) written before any run; all 8 predictions matched
  (6 killed value=4/0, 2 survived value=5).
- Lane was not modified; scratch `$S` (disposable) holds mutant trees; receipts and
  `mutants.tsv` copied to `.ufo/waves/round-70/w1/R70MutTester/` before yield.
- No tool installs were needed; no pacman/uv used. No `bao server -dev` was started by
  hand (all servers were trial/counter-owned and reaped); counter reports
  `noleak=1` on every run.
- This seat judges nothing and ships nothing: surviving mutants are reported as a
  coverage finding for the round's disposition.

FINDING MT-1 falsifies-wording T5's stated conjunction (neither readable nor listed) is not enforced by the frozen instrument: either half alone still reads value=5 (M6/M7 survived)
SEAT-STATUS: complete mutation probe of 8 mutants (6 killed, 2 survived, headline finding MT-1); receipts in .ufo/waves/round-70/w1/R70MutTester/
