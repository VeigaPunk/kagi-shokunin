# MutFetchRemove — round-23 falsification: SC_FETCH provenance gate (C2/D7)

Seat: `KagiR23.MutFetchRemove` (leaf, no dispatch). Measured 2026-10-21T03:59Z against
base `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree.
Read-only on the lane: the only lane write is this file. All mutation work ran in the
scratch directory `/tmp/r23mut.umxTlq`; no production byte was modified.

## 1. Attacked surface and pinned identities

- `corpus/sources-census.sh` SC_FETCH block, lines 226-298 (verify function).
- `corpus/source-fetches.tsv` (10 data rows, S017-S026).
- `corpus/SOURCES.md` registry (26 rows).

Identities at measurement time (the tree is in flight; these hashes pin what was measured):

| artifact | sha256 | mtime |
|---|---|---|
| corpus/sources-census.sh | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` | 2026-10-21 00:57:55 -0300 |
| corpus/source-fetches.tsv | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` | 2026-10-21 00:55:22 -0300 |
| corpus/SOURCES.md | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` | 2026-10-21 00:49:17 -0300 |

## 2. Baseline on the exact production bytes — the gate does not run

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin
$ bash corpus/sources-census.sh >prod.out 2>prod.err; echo exit=$?
exit=1
$ wc -l prod.out   # 0
$ cat prod.err
corpus/sources-census.sh: line 242: S007: unbound variable
```

Exit 1, **zero stdout lines**: no `FINDING` line and no `SOURCES_CENSUS:` verdict line.
The failure is at line 242, which precedes the TSV loop at line 247, so **no SC_FETCH
check executes at all on the production corpus**. Minimal reproduction of the exact fault:

```
$ bash -c 'set -u; SUPERSEDED[S007]=1'
bash: line 1: S007: unbound variable            # exit 127
$ bash -c 'set -u; declare -A SUPERSEDED=(); SUPERSEDED[S007]=1; echo ok'
ok                                               # exit 0
```

Host-free selftest (R21-03 gate) passes:

```
$ bash corpus/sources-census.sh --selftest; echo exit=$?
...
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit=0
```

12 of the 59 cases are `fetch-*` (table at lines 548-559). `grep -c supersedes
corpus/sources-census.sh` = **1**, and that one occurrence is the verify-time awk pattern
at line 245 — no selftest fixture row carries a `supersedes S###` teach cell. The selftest
therefore cannot reach line 242 and cannot detect this crash.

## 3. Assigned mutation probes

Hermetic copy: `work=$(mktemp -d /tmp/r23mut.XXXXXX)`; `cp -a <lane>/corpus
"$work/root/corpus"`; pristine copies of `source-fetches.tsv` (`sha256
ccc9ae6e…`) kept outside the tree. To isolate SC_FETCH from the line-242 crash, a
**scratch-only** copy of the script was patched at one line (production untouched):

```
$ diff census.prod census.patched
229c229
<   declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()
>   declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=() SUPERSEDED=()
```

`census.prod` sha256 `80966e20…` (identical to production); `census.patched` sha256
`ece39d32a33d482c818ded082e5eafdfa24be59998cb032665afdde8fc4724f3`.

### 3.0 Control: patched detector on pristine bytes

```
$ bash "$work/census.patched" verify --root "$work/root"; echo exit=$?
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit=0
```

This matches R21-02's expected regex (`corpus/claim-ledger.tsv:52`) exactly;
`grep -Eq` on the literal regex returned 0. Baseline is clean, so the probes are diagnostic.

Independent digest check: for each of S017-S026, `sha256(id<TAB>status<TAB>url<LF>)`
equals the declared field 3 — **10/10 OK** (all declared digests recompute).

### 3.1 Probe A — remove S024's provenance row

```
$ awk -F'\t' '$1!="S024"' fetch.pristine > root/corpus/source-fetches.tsv   # 10 -> 9 data rows
$ bash census.prod verify --root "$work/root"; echo exit=$?
line 242: S007: unbound variable            # exit 1, zero FINDING
$ bash census.patched verify --root "$work/root"; echo exit=$?
FINDING SC_FETCH id=S024 missing-provenance
SOURCES_CENSUS: FAILED (findings=1 rows=26)
exit=1
```

S024's registry row (`corpus/SOURCES.md:30`) contains **0** in-row `Fetch sha256:`
occurrences, so coverage genuinely depends on the removed row. Exactly one finding fires.

Restore: `cp fetch.pristine` back; `cmp` identical; sha256 `ccc9ae6e…`.

### 3.2 Probe B — corrupt S022's row-identity digest

```
$ awk -F'\t' 'BEGIN{OFS="\t"} $1=="S022"{$3="000…000"} {print}' fetch.pristine > …
$ bash census.prod verify --root "$work/root"; echo exit=$?
line 242: S007: unbound variable            # exit 1, zero FINDING
$ bash census.patched verify --root "$work/root"; echo exit=$?
FINDING SC_FETCH id=S022 row-identity-digest-mismatch
SOURCES_CENSUS: FAILED (findings=1 rows=26)
exit=1
```

Exactly one finding fires. Restore: `cmp` identical (`CMP=identical`), sha256
`ccc9ae6e…`; restored patched baseline re-runs `CLEAN … rows=26`, exit 0.

## 4. Findings

### F1 — BLOCKER (operability): `SUPERSEDED` is undeclared; SC_FETCH is dead on production

- `corpus/sources-census.sh:242` writes `SUPERSEDED[$fid]=1`, but the `declare -A` at
  `corpus/sources-census.sh:229` declares only `FURL FINROW FSEEN FDIG FNRM`.
  `grep -n SUPERSEDED` finds line 242 only — it is never read. [INFERENCE] The
  `FDIG`/`FNRM` same-URL checks appear to have replaced a superseded-row check, and the
  declaration (or the dead while-loop) was not removed.
- Under `set -uo pipefail` (line 111) an undeclared name is an indexed array; subscript
  `S007` is arithmetic, so the first output (the id `S007`, superseded by S019) is an
  unbound variable. Trigger set: the six rows whose teaches cell begins `supersedes S###`
  (`corpus/SOURCES.md:25,26,28,29,31,32`).
- Consequence: stdout empty, exit 1. This contradicts the script's own contract
  `VERDICT (last line, always)` (`corpus/sources-census.sh:93`) and `Nothing is skipped`
  (`:98`), and makes R21-02's required stdout regex + exit 0 (`corpus/claim-ledger.tsv:52`)
  unreachable at this tree state. An exit-code-only harness would misread the crash as
  "findings present".
- The crash sits **before** every SC_FETCH check (line 242 < 247), so the provenance
  gate contributes nothing on the lane; C2's "census `SC_FETCH` enforces …" is not
  observable.

### F2 — Claim arithmetic: "seven distinct URLs" is contradicted; measured 9

- Claim text: `corpus/lessons/round-23.md:164-165` ("10 declared provenance rows
  (S017-S026) over seven distinct URLs"), repeated at `LOG.md:1202` ("10 declared
  captures over 7 URLs") and `SCORECARD.md:840` ("S024-S026 are correction rows over
  seven distinct URLs").
- Measured from the 10 `source-fetches.tsv` data rows: distinct `url` strings = **9**,
  distinct `final_url` = **9**, distinct hosts = **4**. The only duplicated URL is
  `https://openbao.org/docs/concepts/tokens/` (S021, S026). S017-S023 alone are **7**
  distinct URLs — i.e. the pre-round-23 subset; the number was not updated when S024-S026
  were appended (`LESSON:162-164` itself says only the KV v2 URL is new).
- Since SC_FETCH enforces exact per-row URL string equality (`sources-census.sh:256`),
  "seven" cannot be a URL-family count without a declared collapsing rule; none exists.
- Required bound: C2 must say **10 captures over 9 distinct URL strings** (7 in the
  S017-S023 subset; S024 adds one URL; S026 reuses S021's), or state the family rule.

### F3 — Confirmation: when the crash is neutralized, the two probes are killed correctly

- Patched baseline CLEAN, exit 0, matches R21-02's exact verdict regex.
- Probe A produces exactly `SC_FETCH id=S024 missing-provenance` + `FAILED (findings=1)`;
  Probe B exactly `SC_FETCH id=S022 row-identity-digest-mismatch` + `FAILED (findings=1)`.
- All ten row-identity digests recompute correctly; the domain is id+status+registered
  URL, so re-pointing a row is detected independently of the TSV body.
- Declared volatile bound is honored: raw same-URL digest comparison is skipped for
  `decoded-http-body-volatile-v1` (`:284-289`); normalized-digest agreement still runs
  (`:290-295`), and S021/S026 agree (`ed9496…`). This matches `source-fetches.tsv:20`.

### F4 — Bounds the claim must state

- A digest is a point attestation; the gate does not re-fetch or compare to the deployed
  page (`sources-census.sh:75`, `source-fetches.tsv:32`). Freshness of a capture is
  asserted, not machine-checked by this gate.
- 16 legacy in-row pins (S001-S016) satisfy coverage with an undocumented representation
  and are never compared (`:67-70`); `missing-provenance` can never fire for those rows.
  S017-S026 have no in-row pin, so the probe is valid for them only.
- `quote` is only checked non-empty and ≤25 words; its presence in the normalized text,
  and whether the declared normalization was actually applied, are not verified.
- While F1 stands, the gate is inert on the production tree; the 59-case selftest passes
  because no case exercises a `supersedes S###` teach cell.

## 5. Verdict

| Probe | Detector | Expected | Observed (patched, same bytes) | Verdict |
|---|---|---|---|---|
| A: remove S024 row | SC_FETCH | `id=S024 missing-provenance` | exact line, exit 1, findings=1 | killed |
| B: S022 digest → 0^64 | SC_FETCH | `id=S022 row-identity-digest-mismatch` | exact line, exit 1, findings=1 | killed |

- On the **unmodified production script** both mutants (and pristine baseline) end at
  `line 242: S007: unbound variable`, exit 1, zero findings — a baseline failure, so the
  production-detector verdict for the mutants is **inconclusive-by-crash**, not a kill.
- C2 operability at the measured tree state: **REFUTED** — `bash corpus/sources-census.sh`
  exits 1 with no verdict. C2 freshness accounting: the "seven distinct URLs" statement
  is **contradicted**; measured 9.
- Restoration evidence: every mutated TSV restored byte-identical (`cmp`, sha256
  `ccc9ae6e…`); production artifacts re-hashed at end of run unchanged
  (`80966e20…`, `ccc9ae6e…`, `06dde644…`). No production edits, no host gates, no
  installs, no git/jj operations.

## 6. Exact reproduction

```sh
lane=/home/vgpnk/Projects/shokunin/kagi-shokunin
work=$(mktemp -d /tmp/r23mut.XXXXXX); mkdir -p "$work/root"
cp -a "$lane/corpus" "$work/root/corpus"
cp "$work/root/corpus/source-fetches.tsv" "$work/fetch.pristine"
sed 's/declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()/& SUPERSEDED=()/' \
  "$lane/corpus/sources-census.sh" > "$work/census.patched"

bash "$work/census.patched" verify --root "$work/root"            # CLEAN, exit 0
awk -F'\t' '$1!="S024"' "$work/fetch.pristine" \
  > "$work/root/corpus/source-fetches.tsv"
bash "$work/census.patched" verify --root "$work/root"            # id=S024 missing-provenance, exit 1
cp "$work/fetch.pristine" "$work/root/corpus/source-fetches.tsv"
awk -F'\t' 'BEGIN{OFS="\t"} $1=="S022"{$3=sprintf("%064d",0)} {print}' \
  "$work/fetch.pristine" > "$work/root/corpus/source-fetches.tsv"
bash "$work/census.patched" verify --root "$work/root"            # id=S022 row-identity-digest-mismatch, exit 1
cp "$work/fetch.pristine" "$work/root/corpus/source-fetches.tsv"
cmp -s "$work/fetch.pristine" "$work/root/corpus/source-fetches.tsv" && echo restored

bash "$lane/corpus/sources-census.sh";               echo "prod_exit=$?"  # crash, no verdict
bash "$lane/corpus/sources-census.sh" --selftest;    echo "selftest_exit=$?"  # PASS (59 cases)
```
