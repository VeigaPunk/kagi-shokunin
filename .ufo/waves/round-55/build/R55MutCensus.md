# R55MutCensus — mutation test of the round-55 census additions

Measured revision (candidate, landed): `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`
(obtained with `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`, printed literally).
Pristine `corpus/sources-census.sh`: sha256 `3460ca9e73d3772a155bae4ee2be6177b43fd53bef24b2bcfcf8ba343642fc23`,
md5 `8b04120a02fdf0cc7c522e49f0b32638`.

Scratch: `/fast/scratch/hyaku/kagi-r55/R55MutCensus/` — `rev/` (candidate tree via
`git archive 348aa3b8… | tar -x`), `mut/M01..M16` (16 isolated copies, each
`corpus/` byte-identical to the candidate except the one mutated line), `tmp/` (TMPDIR),
`wit/` (witness fixtures). Receipts: `R55MutCensus.d/` next to this file
(64 files; `SHA256SUMS.txt` covers the other 63).

## Baseline (pristine, unmutated)

| run | command | exit | last line |
|---|---|---|---|
| selftest | `TMPDIR=…/tmp bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (78 cases)` |
| verify | `TMPDIR=…/tmp bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entries_sourced=16 legacy=21 captures=114 inrow=16 inrow_only=0 inrow_nonreproducing=12)` |

Both pristine runs pass, so every selftest failure below is caused by the mutation, not inherited.

## Method

One mutation at a time on a fresh copy of the candidate `corpus/` tree (only
`sources-census.sh` edited; `corpus/` content unchanged). Per mutant, two detectors:

1. `bash <copy>/corpus/sources-census.sh --selftest` — the gate's own 78-case table is the oracle.
2. `bash <copy>/corpus/sources-census.sh` — verify with default root = the copy (the real
   114-row corpus, so this is the live leg: does the mutant change the verdict on real data?).

KILLED = at least one `case …: FAIL` (behaviour changed where the gate's own cases notice).
SURVIVED = all 78 cases pass although the mutant is not semantically equivalent.
EQUIVALENT = no input the gate can receive distinguishes it (reason given per row).

## Mutant table

| # | mutated round-55 line (candidate line no.) | mutation | script md5 | selftest | verify on mutated copy | verdict |
|---|---|---|---|---|---|---|
| M01 | NOCITE field concat (247) | drop the `cites_field` half: `field=$(src_field …)` | `ee952b1c…` | rc=1, 1 failed: `usedby-via-cites-control` | rc=1, **25× SC_USEDBY_NOCITE** | **KILLED** |
| M02 | multiple-cites check (356) | `-le 1` → `-le 2` | `9617e786…` | rc=1, 1 failed: `body-cites-two-lines` | rc=0 CLEAN | **KILLED** |
| M03 | registry-row guard in body loop (359) | delete `[[ -v ST[$bid] ]] \|\| continue` | `635557b9…` | rc=1, 2 failed: `entry-two-source`, `body-digit-suffix-control` | rc=0 CLEAN | **KILLED** |
| M04 | recorded test (360) | drop `\|\| $cfield =~ …` | `6320edfe…` | rc=1, 4 failed: `body-cites-control`, `body-cites-usedby-omits`, `body-cites-two-lines`, `usedby-via-cites-control` | rc=1, **25× SC_BODY_CITE unrecorded** | **KILLED** |
| M05 | cites used-by check (367) | `-eq 1` → `-ge 0` (never flags) | `46a51963…` | rc=1, 1 failed: `body-cites-usedby-omits` | rc=0 CLEAN | **KILLED** |
| M06 | legacy placement (354/369) | move `if ! grep -q '^source:' … continue` **before** the SC_BODY_CITE block | `b2d2237b…` | rc=1, 1 failed: `body-cite-legacy` | rc=0 CLEAN | **KILLED** |
| M07 | unknown-cites-row branch (363) | drop the trailing `continue` | `c2337d98…` | rc=1, 1 failed: `body-cites-not-a-row` (abort: `UB[$bid]: unbound variable`) | rc=0 CLEAN | **KILLED** (by crash) |
| M08 | field clause of recorded test (360) | `([^0-9]\|$)` → `([^0-9])` in the `$field` half only | `07dd5daa…` | rc=0, **PASS (78 cases)** | rc=0 CLEAN | SURVIVED |
| M09 | `cites_field` continuation class (166) | `[[:space:]]` → `[ ]` (tab-led continuation lost) | `ee5fc2e0…` | rc=0, **PASS (78 cases)** | rc=0 CLEAN | SURVIVED |
| M10 | NOCITE field concat (247) | join the two halves with a space instead of `$'\n'` | `a9ed0f0d…` | rc=0, **PASS (78 cases)** | rc=0 CLEAN | EQUIVALENT |
| M11 | cites-loop tokenizer (362) | drop the `grep -oE 'S[0-9]+$'` re-extract stage | `3c07e0a7…` | rc=0, **PASS (78 cases)** | rc=0 CLEAN | SURVIVED |
| M12 | `body_ids` digit floor (168) | `S[0-9]{3,}` → `S[0-9]{2,}` | `462058be…` | rc=0, **PASS (78 cases)** | rc=0 CLEAN | EQUIVALENT |
| M13 | `body_ids` uniqueness (168) | drop `\| sort -u` | `73efa3cc…` | rc=0, **PASS (78 cases)** | rc=0 CLEAN | SURVIVED |
| M14 | `body_ids` leading boundary (168) | drop `(^\|[^A-Za-z0-9_])` (unanchored `S[0-9]{3,}`) | `461e8195…` | rc=1, 1 failed: `body-digit-suffix-control` | rc=0 CLEAN | **KILLED** |
| M15 | `cfield` assignment (357) | `cfield=""` | `f3d80d18…` | rc=1, 4 failed: `body-cites-control`, `body-cites-not-a-row`, `body-cites-two-lines`, `usedby-via-cites-control` | rc=1, **25× SC_BODY_CITE unrecorded** | **KILLED** |
| M16 | unknown-row test (363) | `[[ ! -v ST[$bid] ]]` → `[[ -v ST[$bid] ]]` (inverted) | `5b546063…` | rc=1, 4 failed: `body-cites-control`, `body-cites-not-a-row` (abort), `body-cites-two-lines`, `usedby-via-cites-control` | rc=1, **25× SC_BODY_CITE cites-not-a-registry-row** | **KILLED** |

Full unified diffs: `M0x.diff`; full outputs: `M0x-selftest.txt`, `M0x-verify.txt`.

### Kill ratio

- Killed: 10 / 16 = **62.5 %**.
- Excluding the 2 equivalent mutants: 10 / 14 = **71.4 %**.
- Survived: 4 (M08, M09, M11, M13). Equivalent: 2 (M10, M12).

### Why the two equivalents cannot be killed

- **M10** (newline → space between the `source:` and `cites:` halves): the only consumer is
  `[[ $field =~ (^|[^A-Za-z0-9_])$id([^0-9]|$) ]]`. Both separators are non-alphanumeric and
  non-digit, and each half is a complete field, so no id can straddle the join. Every id that
  matches under one join matches under the other; the trailing-newline strip of command
  substitution only converts a final newline into a final space, which still satisfies
  `[^0-9]`. No legal input distinguishes them.
- **M12** (`{3,}` → `{2,}` in `body_ids`): registry ids are `S` + ≥3 digits by contract
  (row shape `^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|`), so a 2-digit token can never be an
  `ST` key; every extra match is discarded by the `[[ -v ST[$bid] ]] || continue` guard one
  line later. Equivalent for all inputs the gate accepts.

## Survivors: witness evidence and the case that would kill each

Each witness is a fixture the pristine gate accepts (or flags exactly once) and the mutant
gets wrong. Receipts `wit-W*.txt`; driver `witness.sh`.

| witness | fixture change | pristine | mutant | divergence |
|---|---|---|---|---|
| W08 | e1 `source:` line ends with the id (`…; S002`) | rc=0 CLEAN | M08 rc=1 FAILED findings=1 (`id=S002 unrecorded`) | `\|$` in the field clause is load-bearing for an id at end-of-line |
| W09 | `cites: S001` + **tab**-led continuation `\tS003`; S003 used-by e1; body names S003 | rc=0 CLEAN | M09 rc=1 FAILED findings=1 | `cites_field` must accept tab continuation |
| W11 | `cites: (S099)` | rc=1, `FINDING SC_BODY_CITE … id=S099 cites-not-a-registry-row` | M11 rc=1, `… id=(S099 …` | finding id/count identical; only the reported id text is mangled |
| W13 | body names the same unrecorded id twice (`S003 … S003`) | rc=1 FAILED findings=1 | M13 rc=1 FAILED findings=2 | `sort -u` keeps one finding per id |

Proposed selftest cases (harness table format `name|mutation|arg|exit|expected id|findings`):

```
"body-cite-terminal-source|m_body_terminal_source||0|CLEAN|0"      # kills M08
"body-cites-tab-continuation|m_body_cites_tab||0|CLEAN|0"           # kills M09
"body-cite-duplicate-mention|m_body_dup_mention||1|SC_BODY_CITE|1"  # kills M13
```

with mutations (same style as the existing `m_body_*` helpers):

```bash
m_body_terminal_source() {   # id at end of the source: line is recorded
  printf '# entry one\nsource: S001 (https://example.invalid/one, §1, rev 1); S002\nverified-at: 2026-10-19\nrecheck: 90d\n\nBody.\n' >"$(E1_F "$1")"
}
m_body_cites_tab() {         # tab-led continuation of cites: is recorded
  printf '# entry one\nsource: S001 (https://example.invalid/one, §1, rev 1); S002 (https://example.invalid/two, §2, 2026-01-01)\nverified-at: 2026-10-19\nrecheck: 90d\ncites: S001\n\tS003\n\nSee S003.\n' >"$(E1_F "$1")"
  sed -i '/^| S003 /s#| — |$#| corpus/knowledge/e1.md |#' "$(SRC_F "$1")"
}
m_body_dup_mention() { printf '\nThe lead S003 says so. Again S003.\n' >>"$(E1_F "$1")"; }
```

M11 needs a harness capability the table lacks: its finding id and count are unchanged, only
the detail text differs. Proposal: add an optional 7th field `detail` to the case table,
asserted with `grep -qF -- "$detail" <<<"$out"`, and one case
`"body-cites-paren|m_body_cites_paren||1|SC_BODY_CITE|1|id=S099 cites-not-a-registry-row"`
with `m_body_cites_paren() { printf '\ncites: (S099)\n' >>"$(E1_F "$1")"; }`. (The current
harness asserts the exit code, the finding id and the findings count — plus the whole verdict
line for CLEAN cases — but never the finding detail: `M0x-selftest.txt` shows it greps
`^FINDING $xid `, not the detail text.)

## Live-leg observation (C1 mechanism is load-bearing)

Four mutants (M01, M04, M15, M16) fail **verify on the real corpus** with exactly
**25 findings** — the same number as C1's BASE `GAP=25`:

| mutant | verify findings |
|---|---|
| M01 (NOCITE ignores `cites:`) | 25 × `SC_USEDBY_NOCITE` (e.g. `id=S012 path=corpus/knowledge/oidc-federation-trust-policy.md`) |
| M04 (recorded test ignores `cites:`) | 25 × `SC_BODY_CITE … unrecorded` |
| M15 (`cfield=""`) | 25 × `SC_BODY_CITE … unrecorded` |
| M16 (inverted row test) | 25 × `SC_BODY_CITE … cites-not-a-registry-row` |

[INFERENCE] The count equality suggests these are the same 25 used-by cells C1 closed
(the mutant restores the pre-C1 state); I did not diff the finding sets against the C1
counter's output — that is the counter seat's measurement, not mine. The other 12 mutants
verify CLEAN on the real corpus: weakening a rule is invisible on a clean corpus, which is
exactly why the selftest, not verify, is the oracle for this gate.

## Robustness note (not a contract change)

M07 and M16 show that the `continue` after `cites-not-a-registry-row` is also what keeps
`${UB[$bid]}` from being read for a non-row id: without it the gate aborts with
`sources-census.sh: line 365: UB[$bid]: unbound variable` (exit 1, no verdict line) instead of
printing a finding. The selftest catches both, but the production failure mode is an abort,
not a finding.

## Commands actually run (all exit codes as recorded)

```
# baseline
TMPDIR=…/tmp bash rev/corpus/sources-census.sh --selftest      # rc=0  PASS (78 cases)
TMPDIR=…/tmp bash rev/corpus/sources-census.sh                # rc=0  CLEAN (rows=114 …)
# per mutant (16×), driver run-all.sh
TMPDIR=…/tmp bash mut/Mxx/corpus/sources-census.sh --selftest  # rc per table
TMPDIR=…/tmp bash mut/Mxx/corpus/sources-census.sh            # rc per table
# witnesses, driver witness.sh (pristine vs mutant on the same fixture)
TMPDIR=…/tmp bash <script> verify --root wit/Wxx               # rc per witness table
```

Not run (out of seat scope): the lane's `claim-ledger.sh verify`, the C1/C2 counters, any
mutation of non-round-55 code (`src_field`, `SC_ENTRY_CITE`, fetch/in-row checks), and any
write outside this seat's build dir and scratch. No tool was installed or upgraded.
