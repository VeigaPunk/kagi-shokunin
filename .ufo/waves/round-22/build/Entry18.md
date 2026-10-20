# Entry18 — freshness/calibration audit: `op-ref-consumption.md` and its stamp row

Seat: `KagiR22.Entry18` (scout, read-only). Axes: **calibration**, **freshness**.
Milestone: Build source-bound calibration and pin-debt reconciliation.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD`).
Working tree: clean for corpus; only untracked `.ufo/waves/` and `plans/round-22.md`.
No host gate was executed; every count below is a static read plus `sha256sum`/`wc`/`git show`.
No install or update was performed.

## Verdict (one line)

**No stale-byte mismatch for this entry or its stamp row.** The substantive defect is
internal: `§10` still states the selftest proves `21` cases; the committed probe proves
**36**, and the entry's existing end-note corrects only `§9`'s `29`. An append is warranted;
a re-stamp is *not* warranted until that append lands.

## 1. Byte identity — row 26 of `corpus/stamps.tsv`

Stamped row (line 26):

```
corpus/knowledge/op-ref-consumption.md	b195cc69840b0b6df65e578d86c0457a4a74b1660dca2e8f4513275a190143dd	372	25290
```

Measured at the frozen base:

| Field | Stamp | Measured | Match |
|---|---|---|---|
| sha256 | `b195cc69…0143dd` | `b195cc69…0143dd` (`sha256sum`) | yes |
| lines | `372` | `372` (`wc -l`) | yes |
| bytes | `25290` | `25290` (`wc -c`) | yes |

Field semantics are not guessed: `corpus/claim-ledger.sh` `stamp()` computes
`sha=$(sha256sum -- "$f")`, `lines=$(wc -l <"$f")`, `bytes=$(wc -c <"$f")`, so the row is
`sha256 / newline count / byte count`. There is exactly one row for this path
(`grep -c` = 1) and the registry is sorted.

**Byte note (matters for any append).** The document ends without a final newline
(last byte `2e` = `.`; `awk 'END{print NR}'` = 373 logical lines, `wc -l` = 372). A naive
`printf '**Correction…' >>` would concatenate onto `§9 is left as written.`. The proposed
append below therefore starts with a blank line separator, and the re-stamp must be
computed after the append, not before.

## 2. Pin history — honest at every committed revision

`git log -- corpus/knowledge/op-ref-consumption.md` has three revisions; each one's committed
stamp matches that revision's bytes exactly (recomputed with `git show <rev>:… | sha256sum | wc -lc`):

| Revision | Commit date | Stamp | Recomputed |
|---|---|---|---|
| `4b8c018` | 2026-09-28T21:50:42-03:00 | `b9e9e86…` / 305 / 21130 | identical |
| `2486643` | 2026-09-28T22:27:11-03:00 | `dcd9389…` / 307 / 21164 | identical |
| `c41af82` | 2026-10-19T19:29:35-03:00 | `b195cc69…` / 372 / 25290 | identical |

`e1544c1` (2026-10-19T19:45:42-03:00) refreshed other rows but left this row — and this file —
untouched. So the row has been refreshed for every content change, not re-pinned over one.

**"Nine dropped stamps" — not reproduced for this row.** Across every committed revision of
`corpus/stamps.tsv` (9 commits, `301b9ec` → `e1544c1`), the distinct path set is 63 and the
current set is 63; no commit removes a path (per-commit set delta prints zero removals). This
row is present from its first appearance (`4b8c018`) to HEAD. Whatever the outside verifier
counted as nine dropped members is not a deletion in committed registry membership; it is not
adjudicable from this row and must stay an explicit C2 unknown for the pin-audit seats. Do not
"restore" rows that were never committed — that would launder an expectation, not repair a pin.

## 3. Substantive freshness — one real defect, one calibration defect

### F1 (freshness, confirmed): `§10` total is an unlabelled historic count

`corpus/knowledge/op-ref-consumption.md` lines 296–297:

> "`--selftest` proves the comparator on 21" / "cases, including fifteen seeded mutations"

`21` was a real pin, but an intermediate one: `corpus/lessons/round-12.md` line 116 records the
sequence "they moved twice: 34→44 checks, 15→21→29 cases". The committed probe now proves 36
(`corpus/claim-ledger.tsv` `R12-02`: expect `^OP_REF_SELFTEST: PASS \(36 cases\)`; round-20 and
round-21 lessons record `PASS (36 cases)` observations). The entry's existing end-note
("§9's comment … is superseded: the selftest now proves 36 cases", lines 371–373) corrects `§9`
only and explicitly leaves §9 as written; it does not cover §10.

The sentence's clause "including fifteen seeded mutations" is still true, but the number `21`
has inverted meaning at HEAD: 36 = 15 seeded-mutation cases + **21** non-mutation checks. So a
reader now reads the complement as the total, and `15 of 21` as a composition that no longer
exists.

### F2 (calibration, confirmed): one of the four `Reverify` pointers cannot re-verify this entry

Line 23: `Reverify: R11-01, R12-01, R12-02, R21-01`.

`R11-01` runs `bash corpus/surface-census.sh` — the declared surface/runtime-shape census. It
touches no `op` parser behaviour and no claim in this entry. `R12-01`, `R12-02`, `R21-01` are
relevant (live two-parser contract, comparator, byte contract). This is exactly the docs-mode
caveat written into `corpus/claim-ledger.sh`: "The declaration is a POINTER, not relevance".
The declaration form still passes the audit; the control is admitted without being a control.
This is C1 calibration debt, not a factual overclaim.

### F3 (negative result, so it is not laundered later): §9's counts are current

Static re-derivation from `corpus/op-ref-probe.sh` at HEAD reproduces `§9`'s example verbatim:
`OPRUN_CONTRACT` 12, `REFS_CONTRACT` 7, `DIVERGENT_CONTRACT` 5, `edge` observation rows 10
(9 contract classes + the precedence probe row), `SIG_CONTRACT` 6, and 44 `C_N` increments
(12+1+1+1+9+1+1+1+2+6+6+1+1+1 = 44). `§11`'s "seven `--selftest` byte cases" and
`checks=6` also match the script. No other numeric claim in this entry is stale.

### F4 (composition of the current selftest, for the append text)

Static count in `corpus/op-ref-probe.sh` `selftest()`:

- 28 source `tcase` invocations; one is the body of `policy_case`, invoked 4 times
  → 28 − 1 + 4 = **31** case checks;
- 5 extra `S_N` increments: 1 after `policy-ref-token` (empty-stub-log assertion) + 4 inside
  `policy_case` → **5** paired assertions;
- **31 + 5 = 36**, matching `R12-02` and the round-20/21 recorded observations.
- Seeded-mutation cases: 15 (the classes §10 names). Non-mutation remainder: 21 =
  1 faithful baseline + 3 SETUP (`canned-missing-file`, `op-binary-missing`,
  `janitor-binary-missing`) + 5 POLICY pairs / 10 checks (`policy-ref-token` and four
  `policy_case` mutations) + 7 byte-comparator cases.

`[INFERENCE]` The arithmetic is unambiguous from source, but was not executed here; the runtime
count is asserted only by the committed ledger expectation and the round-20/21 lesson records.

## 4. Absent-source limits (named, not implied)

1. **Handler absent.** `$HOME/.local/bin/the-janitor` does not exist on this host (`ls`). `R12-01`
   cannot run; the probe's designed answer is `SETUP (janitor binary not executable)` exit 2
   (entry §Bounds.8). This is a host-state limit, not drift.
2. **`op` version skew.** Host has `/usr/bin/op` **2.41.0**; `§1`–`§8` were measured on **2.35.0**
   and `§11` on 2.40.0/2.41.0. The 2.35.0 parser table cannot be re-measured on this host, and no
   gate was run to convert the probe into a cross-version verdict.
3. **Vault-dependent bounds stay unmeasurable by construction:** masking of resolved refs, the
   mask token, `--no-masking` × ref, and `inject`/`read` execution (entry §Bounds.1–5). No vault,
   account, or credential operation was attempted.
4. **No gate executed** (assignment). The byte contract (`R21-01`) and selftest (`R12-02`) are
   read as committed expectations, not observed here.
5. **Scope of the nine-stamp claim.** Only this path's membership was audited; registry-wide
   "nine dropped" reconciliation belongs to the pin-audit seat and remains open for C2.

## 5. Proposed correction — append only, exact text

Append after the existing round-21 correction note (after line 373), separated by a blank line.
Do **not** edit §10 or §9; the existing pattern is "historic text stays, correction names it".

```
**Correction note (round 22, freshness audit).** §10's `--selftest` sentence
("proves the comparator on 21" / "cases, including fifteen seeded mutations",
lines 296–297) is superseded: `21` was round 12's intermediate pin
(`corpus/lessons/round-12.md` line 116 records `15→21→29`), and the committed
probe at this revision proves **36** cases (ledger `R12-02`). Composition from
`corpus/op-ref-probe.sh`: 28 `tcase` source calls, one being the body of
`policy_case` invoked four times → 31 case checks; plus 5 paired log
assertions (1 in `policy-ref-token`, 4 in `policy_case`) → 36. Fifteen of the
36 are the seeded mutations §10 names; the remaining 21 are the faithful
baseline, three SETUP cases, five POLICY pairs (ten checks) and seven
byte-comparator cases — so `21` now names the complement, not the total. §9's
`29` is covered by the preceding note; the rest of §10 stands.
```

Append mechanics and pin duty:

- Add the leading newline (current last byte is `.` with no newline), then the note, then a
  terminating newline. Preserve every existing byte unchanged; `git diff` must show a pure
  addition.
- Re-stamp `corpus/knowledge/op-ref-consumption.md` in the **same reviewed integration commit**
  as the append (new sha/lines/bytes). Never re-pin silently: `corpus/claim-ledger.sh` states
  "Regenerating is a reviewed commit, not an automatic re-pin."
- If integration prefers not to touch the entry, leave it; the defect is then recorded as open
  C2 debt with this report as evidence. Do not rewrite `21` in place.

## 6. Recheck scope — exact, trigger-bound

| Row | Command | Expect | Trigger |
|---|---|---|---|
| `R12-02` | `bash corpus/op-ref-probe.sh --selftest` | `OP_REF_SELFTEST: PASS (36 cases)`, exit 0 | any edit to `corpus/op-ref-probe.sh`, and at the next freshness wave |
| `R21-01` | `bash corpus/op-ref-probe.sh --dotenv-bytes` | `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0 | any `op` version change from `2.41.0` (currently equal, so no trigger today) |
| `R12-01` | `bash corpus/op-ref-probe.sh` | `CLEAN (checks=44 …)`, exit 0 | only on a host with `op` **and** an executable `$HOME/.local/bin/the-janitor`; expect `SETUP` exit 2 here |
| stamp | manual `sha256sum` / `wc -lc` against row 26 | exact 4-field match | after the append only; otherwise no re-pin |
| `R11-01` | `bash corpus/surface-census.sh` | unrelated | remove from this entry's pointer set at the next docs-audit edit, or accept as labelled pointer debt |

Do not run the live probe against the real `op.env`; the contract's no-vault posture stands. The
`--fixture` path is for plain-value files only and the POLICY guard refuses ref tokens.

## 7. Provenance

- Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f`; document and registry read from that
  tree; `git status --porcelain` shows no modification to either file.
- Identity: `corpus/knowledge/op-ref-consumption.md` — `sha256sum`, `wc -lc`; row 26 of
  `corpus/stamps.tsv`; field semantics read from `corpus/claim-ledger.sh` `stamp()` lines 223–293.
- History: `git log -- corpus/stamps.tsv` (9 commits), per-commit path-set deltas, and
  `git show <rev>:corpus/knowledge/op-ref-consumption.md | sha256sum | wc -lc` for
  `4b8c018`, `2486643`, `c41af82`.
- Expectations: `corpus/claim-ledger.tsv` rows `R11-01`, `R12-01`, `R12-02`, `R21-01`.
- Counts: `corpus/op-ref-probe.sh` contract arrays (`OPRUN_CONTRACT`, `REFS_CONTRACT`,
  `DIVERGENT_CONTRACT`, `EDGE_CONTRACT`, `SIG_CONTRACT`, `DOTENV_BYTE_CONTRACT`) and the
  `selftest()`/`evaluate()` bodies.
- Historic count chain: `corpus/lessons/round-12.md` line 116; `corpus/lessons/round-20.md`
  line 21; `corpus/lessons/round-21.md` row M5.
- Host facts: `command -v op` → `/usr/bin/op`; `op --version` → `2.41.0`;
  `ls ~/.local/bin/the-janitor` → absent. No vault/account call was made.

## 8. Confidence

- Stamp byte match and pin history: **high** (three independent computations, same tree).
- `§10` staleness and 36-case composition: **high** statically; runtime not observed (no gates).
- `R11-01` irrelevance: **high** (command and target are a different surface).
- "Nine dropped stamps" attribution: **unresolved** — the committed registry shows zero path
  removals and this row was never dropped; the verifier's nine are out of this row's reach.

## 9. Checks for parent after integration

1. `bash corpus/op-ref-probe.sh --selftest` → `PASS (36 cases)`, exit 0 (only if gates are in
   scope for the integration step).
2. `sha256sum`/`wc -lc` of `corpus/knowledge/op-ref-consumption.md` vs its `stamps.tsv` row —
   must be identical; expect a changed row only if the append landed.
3. `bash corpus/claim-ledger.sh verify` (or the docs mode) once in the integration wave:
   entry must still carry one valid `Reverify:` line and one stamp row; pointer count must not
   drop below one.
4. If the append lands: `git diff` on the entry must be purely additive, and the re-stamp must
   be in the same commit.

No depth move, no legacy-header count claim.
