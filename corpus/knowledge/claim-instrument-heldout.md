source: S145 — Kushigian, Kaufman, Featherman, Potter, Madadi & Just, "Equivalent Mutants in the Wild: Identifying and Efficiently Suppressing Equivalent Mutants for Java Programs", ISSTA '24 (33rd ACM SIGSOFT Int. Symp. on Software Testing and Analysis), Vienna, 12 pages, DOI 10.1145/3650212.3680310, read from the authors' own University of Washington publication page (https://homes.cs.washington.edu/~rjust/publ/equi_mutants_ems_issta_2024.pdf; opened 2026-11-08; §1 Introduction, the paragraph defining killability, PDF page 2); located quote (13 words): `An equivalent mutant is a mutant which cannot be killed by any test`
verified-at: 2026-11-08 — claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047` (the frozen predeclaration `plans/round-64.md`, commit `dff0929c0e084822b0fe32e0d164534c768f97fe`, Amendment A1); the located quote is in the committed pdftotext text layer of the captured PDF (74040 B, sha256 `28c22757733c1e4dd02503849b52e5bb25e8b75b6acc359816ab4d2012958120`; the PDF body itself is 509057 B, sha256 `066f44388d042384987edcb61c1938472970f89af68a3ba887edea19e232ae28` — the PDF bytes are not strict UTF-8, so the lane's round-63 PDF-text-layer precedent applies; the capture file names and the locate command are in the round's capture ledger `.ufo/waves/round-64/capture/notes.md`, whose locate transcript is `.ufo/waves/round-64/build/R64ScoutSources/locate-output.txt` — `RENDERED_TEXT_V1_LOCATE: count=1` for the quote above); the BASE readings below are the L1's committed re-measurement (`.ufo/waves/round-64/base/census-a1.md`, slim-tree extraction of `09cbee8`, each fixture applied once, anchor count asserted 1); the candidate readings below are this seat's own run of the frozen counter against the working tree on the counter's frozen bytes sha256 `e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484`, which printed `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)` rc 0 in 496 s (`.ufo/waves/round-64/build/R64ScribeEntry/entry.md`, receipts `c1-worktree-6-verdict.txt`); the held-out table's seal was verified by digest only (`sha256sum plans/round-64-heldout.tsv` ⇒ `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`, matching the frozen seal) — this seat did not open the sealed table's rows, and quotes no fixture string from it
recheck: 180d — re-verify the seal (`sha256sum plans/round-64-heldout.tsv` ⇒ `b0f51e2a…`), re-extract the claim BASE and re-measure every held-out fixture's BASE reading, then re-run `bash plans/round-64-c1.sh --tree <candidate>` (expect `C1_HELDOUT: heldout=0 population=8 guard=1`) and `bash plans/round-64-c2.sh --tree <candidate>` (expect one `C2_REFUSAL: killed=5 population=5 guard=1 …` line with `terminates=1` and `bound=1`); re-open the ISSTA '24 paper if the killability sentence is re-quoted (the row's flip is a revision that drops it or renames the venue), and re-run `bash plans/round-64-controls.sh --selftest` (the battery's own cases) before quoting any count
Reverify: R21-02

# Held-out sets: a checker's own fixture table is not evidence for that checker

Scope: the round-64 C1 claim of the kagi lane, measured on `kagi-shokunin` at BASE
`09cbee8` — the C1 checker's polarity grammar tested against a **held-out** fixture set
sealed before the hardening (`C1_HELDOUT: heldout=0 population=8`, five held-out forgeries
rejected, three held-out benign rewrites accepted). The entry is written in two voices and
keeps them apart: the *rule* below is grounded in the sourced mutation-testing literature,
while every instrument reading is a line a lane command printed on a named tree. The entry
is about instruments, not about OpenBao: it makes no claim about a vault, a server or a
secret, and the lane's domain evidence stays in `corpus/knowledge/openbao-seal-key-custody.md`.

It extends two entries rather than restating them. `corpus/knowledge/negation-scope-grammar.md`
says what a *sentence* must look like for a token to be asserted (the closed negator /
denial / idiom lists, the sentence scope, the quotation mask). `corpus/knowledge/claim-instrument-falsifiability.md`
says that an item whose only test is token presence is a declared ceiling, and that a gate's
`--selftest` must execute its own aggregation. Neither of them asks the prior question:
**on what evidence may a claim that an instrument implements a rule rest?** This entry asks
it, and the answer is: not on the instrument's own fixture tables.

## The held-out rule

A checker's committed fixture tables are the checker's own **outputs**. Running them against
the checker and reading `accepted=0 rejected=0` proves that the checker answers the way the
table says it answers; it cannot distinguish an implementation from a table that stores the
answers. The distinction is not a matter of style: a lookup table with one row per fixture
passes every leg of such a guard, and the round-63 critic built exactly that — a 15-string
fixture lookup over the committed tables, a constant `C1_CHECK_SELFTEST: PASS (cases=91)`
and a dead `NEGATORS = frozenset(())` line — and it read `accepted=0 rejected=0` against
every guard leg the round-63 counter carried (round-63 lesson M63-6). The claim it was
offered against was therefore unfalsifiable on the evidence offered.

The literature names the shape. S145 states the consequence in one sentence: `An equivalent
mutant is a mutant which cannot be killed by any test`. A checker that memorises its
committed table is, **on that table, exactly an equivalent mutant of the grammar**: the two
agree on every input the table contains, so no test drawn from the table can tell them
apart. Only an input the table does not contain can. That is the whole of the held-out
rule: the evidence for "this instrument implements a rule" must include at least one case
the instrument's own fixtures do not contain, and the set holding those cases must be
**sealed before the hardening** — otherwise the instrument's builder can see the answers and
fit them.

Three conditions travel with the rule, and each is separately falsifiable:

1. **Sealed before the hardening.** The set carries a digest that is fixed in the frozen
   predeclaration and re-verified by the counter before any work (`plans/round-64-heldout.tsv`,
   sha256 `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`, Amendment A1).
   A set sealed afterwards is a set the builder could have read.
2. **Held out from the instrument.** The instrument and its own `--selftest` are built
   without the set; the seat that builds them is told the set is sealed and does not read
   it. A seat that reads it must disclose that, and the disclosure is recorded as a defect,
   not as a pass.
3. **The instrument's own tables are re-run as a separate guard leg.** The committed tables
   are still checked — but as a **regression leg**, not as the evidence for the claim. A
   regression there fails the *guard*, not the claim: the instrument is not allowed to
   trade precision for recall on the shapes it already knew, and a hardened checker that
   begins rejecting benign rewrites is repaired rather than counted as a gain.

The consequence for the shape of a held-out set: it must be populated from the instrument's
**shape classes**, not from strings the instrument reads. A held-out fixture that is a
verbatim copy of a committed fixture adds no evidence, and a fixture whose answer is
readable off the instrument's own tables is a self-description. The round-64 set is
populated that way: each held-out row states a *class* of forgery or benign rewrite, and the
class is named in the plan without quoting the fixture (six classes, Amendment A1).

## The two-sided population

A held-out set that only contains forgeries measures recall alone; a checker that rejects
everything reaches `heldout=0` on a forgery set. The set is therefore **two-sided**: forgeries
the BASE checker accepts, and benign rewrites the BASE checker rejects. The hardened
checker must move both sides at once, and the unmodified copy must stay resolved.

The BASE readings are the L1's committed re-measurement at `09cbee8` over a slim extraction
of the tree (`.ufo/waves/round-64/base/census-a1.md`); each fixture is applied once to a
fresh copy and the anchor must occur exactly once, or the fixture is refused. The candidate
readings are this seat's own run of the frozen counter against the working tree; the
per-fixture line is the counter's own (`c1-heldout: per-fixture …`). **They are measure-leg
readings, not a verdict**: the runs that produced them printed the measure lines and then
stopped before the counter's `C1_HELDOUT:` line, so the guard legs were never certified
green by this seat (the counter's own re-measurement on its final bytes is the L1's to
land). What the right column shows is that the **hardened checker's answers on the
held-out set are the intended ones** — the point the entry is about — and nothing more.

| side | id | shape class (named in the plan, no fixture string quoted) | BASE reading | candidate reading |
|---|---|---|---|---|
| H (forgery) | F2 | denial **after** the bound pair — the pair's assertion must not be followed by a denial predicate | `value=0` (accepted) | `value=1` (rejected) |
| H | F6 | duplicated mechanism — one mechanism asserted twice; the item must require a single occurrence | `value=0` (accepted) | `value=1` (rejected) |
| H | F8 | quoted denial — a denial inside a quotation of the superseded text | `value=0` (accepted) | `value=1` (rejected) |
| H | F10 | unbound duplicate pair — a second pair not bound to its own subject | `value=0` (accepted) | `value=1` (rejected) |
| H | B4 | negated subject — the subject of the pair is itself negated | `value=0` (accepted) | `value=1` (rejected) |
| Q (benign) | P6 | binding window widened by an em-dash aside | `value=1` (rejected) | `value=0` (accepted) |
| Q | B5 | idiom class the closed list did not carry | `value=1` (rejected) | `value=0` (accepted) |
| Q | P7 | parenthetical between the subject and the pair | rejected at mechanism level | `value=0` (accepted) |

Reading: the five forgeries move `accepted` to 0 and the three benign rewrites move
`rejected` to 0 — the population's held-out count `8 → 0` over `POP = 8`, with the
unmodified copy still `value=0` and every item bit `1` (no false positive). The counter's
own measure line reads `c1-heldout: H accepted=0/5 (each counted when value=0) Q
rejected=0/3 (each counted when value>=1)`; its per-fixture line is the source of the right
column above; and its verdict line on the candidate is
`C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)`
rc 0 (496 s), exit 0 iff `guard=1` and `heldout=0`. The committed candidate receipt is
still the L1's to land — this entry does not put a counter verdict in the place of a
measurement, and it names the bytes the verdict was read on.

Two guard legs are the reason the right column is evidence rather than a coincidence. The
**vehicle** leg re-runs the A4 lookup-table checker as the measured instrument on the
held-out set: a table that answers the committed fixtures correctly must **not** reach
`heldout=0` on the set it never saw, and that is the leg that separates a grammar from a
table (the counter builds the vehicle from the plan's description and copies nothing from a
seat). The measured vehicle leg reads `c1-heldout: vehicle heldout=5 r63=1` — the A4
table is refused on the held-out set with five of the eight fixtures counted against it,
while still reading `accepted=0 rejected=0` on the committed tables it *does* answer. The
**stub** leg refuses a printer-stub checker — no `C1_HELDOUT:` line and a non-zero exit —
because a counter that reads a constant line reads no evidence at all; the measured stub
leg reads `stub e1_rc=2 e1_ok=1 e2_rc=2 e2_ok=1` (both stub shapes refused, neither
reaching a verdict). The **resid** leg reads
`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1` — the round-63 counter's own
verdict still holds on the candidate, so the committed tables did not regress.

## Bounds

1. **Eight fixtures are eight fixtures, not a grammar proof.** The held-out set measures
   five forgery shapes and three benign shapes. A seventh forgery shape the grammar misses,
   or a fourth benign shape the grammar over-reads, is a new routed defect, not a failure of
   the claim and not a success of it.
2. **A lookup table carrying one fresh entry per held-out fixture would also reach
   `heldout=0`.** The set is sealed, not secret-from-the-builder: a builder who had read it
   could fit it. What the set rules out is the *cheap* table — one that answers the
   committed fixtures — and the vehicle leg is the only witness that separates even a
   well-fitted table from the grammar, because it asks the table a question its own entries
   do not answer. A table that fits the held-out set as well is indistinguishable from the
   grammar by this evidence, and no claim is made that it is distinguishable.
3. **A structural read cannot prove the corrected sentence true.** The checker proves the
   sentence *asserts* the correction; it cannot prove the correction is factually right.
   QM79 and QM81 narrow that gap and never close it, and this entry inherits it unchanged.
4. **The set's rows are sealed; their shapes are named.** The class names in the table
   above are the plan's; the fixture strings are not reproduced anywhere in this entry, and
   a reader who needs them reads the sealed table under the counter's discipline.
5. **The counter's guard legs are separate from the claim.** `real`, `selftest`, `resid`,
   `stub` and `vehicle` are the guard; `heldout` is the claim. A guard leg that fails
   blocks the exit code but does not change the measured held-out count — and a guard leg
   that fails for the *wrong* reason (an instrument invoked on the wrong tree, as the
   round-63 residual counter did when it was run from inside the measured copy) is a
   defect of the invocation, not a finding about the claim.
6. **A gate a reader cannot run inside a budget is not a witness.** The measured C1 run
   took 496 s of which the `resid` leg alone took 298 s, so a reader with the plan's own
   1200 s budget gets a verdict line; the same counter earlier in the wave exceeded a
   1500 s outer timeout inside that leg. The reading is a property of the tree *and* of the
   clock it ran on, and both are named here.
7. **The bound on the C2 side is the same shape.** A counter whose delegating legs can
   re-enter needs an explicit bound, and the bound's **refutation** leg — the bound off,
   which must *not* terminate inside a fixed timeout — is part of the claim. A bound that
   cannot fail is a comment (QM86).

## Falsifiers

Each of these is stated so a reader can run it; none of them is a matter of taste.

1. **The seal does not match.** `sha256sum plans/round-64-heldout.tsv` reads anything but
   `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2` ⇒ the held-out set
   is not the predeclared one, and every reading taken against it is void.
2. **A tree byte-identical to BASE reads `heldout` below 8.** The five held-out forgeries
   are read as accepted at BASE and the three held-out benign rewrites as rejected; a
   lower count means a fixture is vacuous and voids the claim (the plan's K1).
3. **Any held-out forgery reads `value=0` on the hardened checker** ⇒ the class it names
   is not closed.
4. **Any held-out benign rewrite reads `value>=1` on the hardened checker** ⇒ the
   hardening rejects a benign rewrite; that fails the guard leg, not the claim.
5. **The A4 vehicle reaches `heldout=0` on the candidate** ⇒ the vehicle leg does not
   separate a grammar from a table and the held-out evidence is weaker than claimed.
6. **A printer-stub checker reaches a `C1_HELDOUT:` verdict line** ⇒ the stub refusal is
   broken and the counter can read a constant.
7. **The unmodified copy reads `value>=1`** ⇒ the hardening bought recall with a false
   positive on the ordinary tree.
8. **The counter's own `--selftest` passes on a mutated copy** (a checker with an emptied
   shape list, a counter with a constant aggregation) ⇒ the counter's self-invocation does
   not execute its own measurement, and the `heldout` field is not a measurement.
9. **The bound's refutation leg terminates.** With `C2_RECURSION_BOUND=0` the counter
   reaches a verdict line inside the fixed timeout ⇒ the bound is decorative, and the C2
   half of the round claims a termination that the bound does not deliver (QM86).
