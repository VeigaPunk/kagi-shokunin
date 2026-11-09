# Round 70 — kagi (secrets & vault ops) — predeclaration (frozen)

Lane: kagi. Round 70, attempt 1. L1 `KagiR70` (holds the §3 planner seat; the validator rejects a
`planner` swarm role). Claim BASE `7bd34832c94b81d4cf9bf34113c4952a7f6d9b04` (lane tip at round
start = round-69 spot-check tip). Host: this Linux/omp host; OpenBao 2.7.2 official release
binary at `~/.local/bin/bao` (sha256 `9c5f3628…b788`, the pin rounds 49–57 used).

## Pre-move state

All six axes stand at 9 (SCORECARD `## Round 69 — post-move`). The lowest-axis duty is satisfied by
any claim. The last capability entered round 67 (capture read-through); rounds 68 and 69 added
none (2 of 3 in the stagnation window), so the nudge does not yet fire — but the last two rounds
were rejected-honest-stops on calibration/operability record claims, so this round moves
frontier ground instead: one capability claim on domain mechanics the lane has never executed.

## Claim C1 — coverage (capability acquisition): OpenBao PKI certificate lifecycle, executed

Surface moved: frontier → core, a new operation class. Before this round the lane holds no
knowledge entry, trial, source row or capability for the OpenBao PKI secrets engine (X.509
certificate issuance, TTL bounds, name constraints, revocation/CRL, `no_store`). Command that
would show it unmoved: the frozen counter on the BASE revision (`value=0 absent=1`).

**Frozen predicate (the same sentence as the header of `plans/round-70-c1.sh`):**
`C1_PKI_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and SOURCED = 1, else 0; target 5 (BASE 0).`

DISCRIMINATE(T): the measured tree's `corpus/openbao-pki-trial.sh` prints exactly one
`TRIAL T HOLDS` line with the real binary, exactly one `TRIAL T BROKEN` line under T's designated
falsifier shim, and exactly one `TRIAL T HOLDS` line under each of the other four shims
(specificity), AND `corpus/knowledge/openbao-pki-certificate-lifecycle.md` carries a
`## Measured (round 70` line `- T<n> …OpenBao 2.7.2…`. Shims: SH1 root-internal-becomes-exported,
SH2 role-drops-max_ttl, SH3 role-allows-any-name, SH4 revoke-swallowed, SH5 role-drops-no_store.
SOURCED: the entry's `source:` line names S170 and `corpus/SOURCES.md` holds an S170 row with
status `mined` (S170 = OpenBao PKI secrets-engine API docs, opened this round — the round's
sourced claim, §2b item 4).

- Counter: `plans/round-70-c1.sh` (frozen; sha256 recorded in
  `.ufo/waves/round-70/controls/receipts/counter.sha256`).
- Counting command: `bash plans/round-70-c1.sh <landed lane revision>`.
- Target: `value=5`, rc 0. **Kill rule:** `value < 5` on the landed revision → C1 missed (honest
  stop; never narrowed after landing).
- Tests (each sourced in S170; measured on the probe before freezing):
  T1 root-internal — `root/generate/internal` returns a certificate and no `private_key`;
  T2 ttl-clamp — a 24h request on a `max_ttl=1h` role is issued with a lifetime ≤ 1h + 60s (the
  doc says the ttl "Cannot be greater than the role's max_ttl value"; the server clamps with a
  warning rather than refusing — measured);
  T3 domain-refuse — a CN outside `allowed_domains` is refused while one inside is issued;
  T4 revoke-crl — a serial revoked via `pki/revoke` appears on the mount's CRL (openssl-parsed);
  T5 no-store — a `no_store=true` role's certificate is neither readable at `cert/<serial>` nor
  listed, while a stored control certificate is.

### Prefreeze controls (executed and committed with this freeze)

Runner `plans/round-70-controls.sh`; receipts `.ufo/waves/round-70/controls/receipts/`; fixtures
`.ufo/waves/round-70/controls/{p1,f1..f6}` (each fixture carries a control scaffold entry and an
S170 fixture row so it fails only on the property it forges). Expected verdicts were written into
the runner header before its first run:

| control | what it is | expected |
|---|---|---|
| F0 | BASE revision `7bd34832` (do no work) | `value=0 absent=1`, rc 1 |
| P1 | positive reference trial | `value=5`, rc 0 (blanket refusal is not a gain) |
| F1 | echo forgery (prints HOLDS, runs nothing) | `value=0`, rc 1 (no shim flips) |
| F2 | shim-sniffing forgery (BROKEN whenever `bao` is a script) | `value=0`, rc 1 (specificity fails) |
| F3 | no-teeth trial (runs bao; every BROKEN branch rewritten to HOLDS) | `value=0`, rc 1 |
| F4 | P1 trial with no entry and no S170 row | `value=0 sourced=0`, rc 1 |
| F5 | P1 trial whose dev server is never killed | `value=0 noleak=0`, rc 1 |
| F6 | P1 trial that prints the dev root token | `value=0 nosecret=0`, rc 1 |

Named ceiling: a trial that reads the shim's own bytes and knows each shim's body could pass the
specificity leg; the attack wave reads the landed trial for any read of the `bao` binary's bytes.

## Routed defects from the round-69 spot-check (dispositions)

1. Report miscount (8 vs 6 `falsifies-wording` rows): corrected in the round-70 report, citing
   `.ufo/waves/round-69/claim-falsification.tsv`.
2. Census warning miscount (2 vs 25 W04): measured this round — the W04 lines go to **stdout**
   (`.ufo/waves/round-70/base/census-round-start.stdout.txt`, 25 W04 lines; stderr empty). Both
   census receipts this round capture stdout, stderr and rc separately.
3. Wave-results name binding (M69-9): this round binds every settlement read to the driver's
   actual artifact — `<wave>-results.json` beside the dispatch file, with `<wave>` = the spec's
   wave id — and the prefile gate is run with `--wave`.
4. Frozen legs falsified before freeze (M69-10): C1's legs were run against eight controls
   before freezing (table above).
5. C2 unsatisfiable on the production gate: no successor claim this round; carried as a named
   debt, not re-declared.
6. No sourced claim in round 69: C1 is sourced (S170).
7. Settlement loss: recorded; this round reads `<wave>-results.json` and the seats' report files.
8. SHONEN: unchanged; boxes stay `[~]`.

## Frontier step

Census before/after with stdout/stderr/rc; new rows S170 (admit, tier A) and S171 (OpenBao PKI
overview, opened for the same mechanics — decision recorded in the lesson Gate); one mistake mined
into `corpus/lessons/round-70.md` `## Mistakes`; considerthese: at most one proposal, or a line.
