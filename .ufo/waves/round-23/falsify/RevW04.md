# RevW04 — W04 duplicate-URL quote falsification (round 23)

Falsification seat, `RevW04`. Scoped assignment: run the fleet census for `kagi`,
verify every W04 line is quoted verbatim in `corpus/lessons/round-23.md` D1, and
check that the expected duplicate-URL set matches S019/S020/S021/S022/S023.
READ-ONLY on the lane: the only lane write is this file. Diagnostics ran from
`/tmp` copies. No git/jj mutation, no installs, no host/package/service changes,
no vault or credential reads, no legacy `claim-ledger verify`, no host-bound
row. The parent-held 43-row audit was not re-run.

The lane moved during the review (HEAD `d218603` → `e1884c6` → `b55e0e7` →
`638d44c` → `def9bc2` → `57776b2` → `31f24e0` → `3f9fe72`; worktree lesson
`130d70e0…` at 01:26). D1 was repaired at `58bd8d7` and reworded at `57776b2`;
the W04 text is unchanged through the last observed worktree. Both states are
recorded with hashes below. The assignment's verification **failed on the
dispatched tree** and **passes on the last measured tree**. The distinction is
the point of this report.

## Verdict

| Snapshot | Assigned check | Result |
|---|---|---|
| Dispatch → `def9bc2` (dispatch-time lesson `2f53cf69…`; D1 at `def9bc2` `49632920…`) | 7 census W04 lines quoted verbatim in D1 | **FALSIFIED.** Census printed 7; D1 quoted 5. S025/S026 absent. The five present were byte-exact. The round-end gate sentence was unsatisfiable as one command. |
| Last measured (HEAD `3f9fe72`, worktree lesson `130d70e0…`, 01:26) | Same | **PASS.** Census prints 7; D1 quotes 7/7 byte-exact, with no extras. D1 now states five at base / seven at round end, and the gate names two executable measurements. |

Final gate re-measurements at `3f9fe72`/worktree `130d70e0…`: C1 `CLEAN` with its claim row matching,
C2 lane census `CLEAN rows=26`, C3 `CELL_AUDIT: CLEAN` exact. The independent
live provenance re-fetch reproduced 10/10 normalized digests and 10/10 quotes.

## Snapshot measured (final)

| Artifact | SHA-256 | Note |
|---|---|---|
| `HEAD` | `3f9fe72f4905a898346f90fc2b566fc81a41b364` | measured 01:25–01:26; worktree advanced after |
| `corpus/lessons/round-23.md` | `130d70e0244b67720bff8369f9eaa2d21a352844e3c5f6eb770cf45248fdb331` | worktree at 01:26; W04 section unchanged from `cfb4d5e9…`; D1 at :66-79, gate at :183-184 |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | committed; 26 rows |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | 10 rows, lines 38-47 |
| `corpus/sources-census.sh` (lane) | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` | worktree |
| `corpus/closure-dispositions.py` | `8cfaa52fc2ef527600779fb38d01f6335473c754feeb4370ceada949fed7429c` | selftest 14 |
| `corpus/closure-dispositions.json` | `67ac1a42427eca7bc38a0f6785385a3b8039f1e61de24a1716ab76c8bbc5ff60` | D3 is now `reported`: 6 fixed / 3 reported |
| `corpus/fixtures/cells-hermetic/SCORECARD.md` | `2358325254a1e7eae0d8b0a6a6b201c7a3b5ea4766a24af3b4849564eb58566e` | committed |
| `LOG.md` | `9b4cc94a9ccb91ebe28c8d64bdcf21dc7a7ecb922620635429820fac9f09f90b` | line 1193 still stale (F2) |
| `corpus/claim-ledger.tsv` | `87e0217d4eccb442cf86d324281566f5156e248bb61fa7f4ba74f2a47c8208f0` | `R23-02` pins `fixed=6 reported=3` |
| `scripts/sources-census.sh` (fleet) | `3fb7261569f46423dd80ecc23e0a23789a7926f667c7a3fc559d2439d4a64e30` | static since 2026-10-19 |

The pre-repair snapshot measured for F1 was HEAD `def9bc2…`, lesson
`49632920e11189562ade4410c002f51206b33c66e9ce57805efcc940fa81f699`; the census
input `corpus/SOURCES.md` was already `c6ea91ab…` and did not change.

## F1 — historical falsification: 7 printed, 5 quoted at dispatch/def9bc2

### Exact command and output (unchanged by the repair)

```
$ cd /home/vgpnk/Projects/shokunin
$ bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
kagi	W04	S019 duplicate url www.1password.dev/brokered-access across scopes
kagi	W04	S020 duplicate url 1password.com/blog/1password-credential-broker-public-preview across scopes
kagi	W04	S021 duplicate url openbao.org/docs/concepts/tokens across scopes
kagi	W04	S022 duplicate url developer.hashicorp.com/vault/docs/auth/jwt across scopes
kagi	W04	S023 duplicate url developer.hashicorp.com/vault/docs/concepts/lease across scopes
kagi	W04	S025 duplicate url openbao.org/docs/auth/jwt across scopes
kagi	W04	S026 duplicate url openbao.org/docs/concepts/tokens across scopes
kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
$ echo $?
0
```

Run twice at different times; identical order and bytes. `--today` is irrelevant
to W04 (it only gates `opened`/`recheck` in the same awk pass). The W04 emission
is `scripts/sources-census.sh:645`; it fires whenever a later row repeats a
normalized URL under a different scope cell. The E04 `supersedes S0xx`
exemption at `:648` applies only within the same scope key; it does not exempt
W04.

### What the old D1 contained

At `def9bc2`, `corpus/lessons/round-23.md:66-72` said “The census prints five
W04 duplicate-URL warnings” and quoted only S019-S023. A backtick-bounded
extraction against the census output measured:

- Census W04 count: **7**.
- Old D1 quoted count: **5**.
- Exact matches among the five: **5/5** (none paraphrased).
- Missing: `W04 S025 duplicate url openbao.org/docs/auth/jwt across scopes` and
  `W04 S026 duplicate url openbao.org/docs/concepts/tokens across scopes`.

The base set was genuinely five. From a full `d218603` archive extracted in
`/tmp`:

```
$ bash scripts/sources-census.sh validate --root "$T" --file "$T/corpus/SOURCES.md" kagi
file	W04	S019 duplicate url www.1password.dev/brokered-access across scopes
file	W04	S020 duplicate url 1password.com/blog/1password-credential-broker-public-preview across scopes
file	W04	S021 duplicate url openbao.org/docs/concepts/tokens across scopes
file	W04	S022 duplicate url developer.hashicorp.com/vault/docs/auth/jwt across scopes
file	W04	S023 duplicate url developer.hashicorp.com/vault/docs/concepts/lease across scopes
file	ok	/tmp/tmp.uKOOpPUO9Y/corpus/SOURCES.md
$ echo $?
0
```

Base = five, exit 0. Round end = seven, exit 0. Root cause is in the registry:
S025 (`corpus/SOURCES.md:31`) repeats S014’s URL (`:20`) and S026 (`:32`)
repeats S016’s URL (`:22`); their scope cells are prose-distinct, so W04 fires
by construction. The old D1 inherited the round-start count without
re-measuring.

The old round-end gate (`:178-180` at `def9bc2`) said “census at round end must
exit 0 with the same W04 warnings and `rows=26`.” No single invocation did both:

```
$ bash scripts/sources-census.sh census kagi | grep -c W04
0
$ bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi | grep -c 'rows=26'
0
```

`validate` contains the W04 printf inside `if (mode=="validate")`
(`scripts/sources-census.sh:634`); `census` only reaches the END block that emits
rows (`:690`). The lane `corpus/sources-census.sh` emits `rows=26` but has no
W04 check at all.

### Repair verified at HEAD

Commit `58bd8d7` (“D3 reported, W04 seven…”) added the two missing quotes;
`57776b2` reworded the base/end sentence and gate; the text is unchanged
through the last observed worktree (`130d70e0…`). Current D1
(`corpus/lessons/round-23.md:66-79`) now reads “prints five W04 duplicate-URL
warnings at the base and seven at round end” and quotes all seven. The gate
(`:183-184`) now says “at round end the fleet wrapper emits seven and the lane
census exits 0 with `rows=26`” — two executable measurements, both true.

Re-measured at `4e971e3d…`, `cfb4d5e9…`, and the worktree `130d70e0…` (01:26):

```
census 7 quoted 7
missing []
extras []
all_exact True
```

The seven quoted lines are at `:69-75`; all seven are byte-equal to the census
detail fields. No missing or paraphrased warning remains. The last observed
worktree (`03247f44…`, 01:28) still compares 7/7, with no W04-section change
from `130d70e0…`.

## F2 — LOG.md still carries the pre-D3 disposition counts (live, low)

At the last measured snapshot, the gate emits:

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)
```

`corpus/claim-ledger.tsv:60` (`R23-02`) was updated to the same `fixed=6
reported=3` and its regex matches. `corpus/lessons/round-23.md:60` uses an
ellipsis and does not pin the classes. But `LOG.md:1193` still says “After:
`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 …)` exit0 with a
14-case selftest”. D3 was changed from `fixed` to `reported` at `58bd8d7`; the
LOG “After” paragraph was updated for the 14-case count but not for the 6/3
class split. One-line reconciliation, no gate impact.

## F3 — D1 rationale accounts for six of seven warnings (live, nit)

The parenthetical at `corpus/lessons/round-23.md:76-79` explains S019, S020,
S022, S023 (over S007/S006/S012/S013), and S025/S026 (over S014/S016). S021 is
quoted and expected, but its duplicate target S016 is not named. This is a
rationale gap, not a missing or paraphrased warning: all seven lines are
present and exact. Adding “S021 is a product-bound review over S016” would close
it.

## F4 — transient: lane census crash on the dispatched tree (repaired)

At `corpus/sources-census.sh` hash
`80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`
(mtime 00:57:55), the primary C2 counting command failed:

```
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
$ echo $?
1
```

Reproduced twice, including under `bash -x`. `SUPERSEDED[$fid]=1` was assigned
at line 242 without `declare -A SUPERSEDED`; with `set -u`, Bash evaluated
`S007` arithmetically. The base script `d218603:corpus/sources-census.sh` has no
`SUPERSEDED` token, and the base tree runs `SOURCES_CENSUS: CLEAN (rows=23 …)`
exit 0, so this was a round-23 regression. The 59-case selftest passed
throughout, so it did not exercise that real-tree branch. It was removed at
01:02:21 (hash `24d834cc…`; the map was never read). Current worktree
`2d1bbbe3…` exits 0 with `CLEAN (rows=26 …)` and `--selftest` `PASS (59 cases)`.

## F5 — transient: R23-01 failed on the then-worktree fixture (repaired)

At 01:01 the fixture’s `SCORECARD.md:1` comment read “executable via R23-01 in
corpus/claim-ledger.tsv”; the cells scanner extracts `R23-01` from that comment
and treats it as a cited row:

```
MISSING-ID SCORECARD.md:1 R23-01
CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=1 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
$ echo $?
1
```

The committed fixture (`23583252…`) rewrites the comment to “rows are declared
in claims.tsv”. The exact R23-01 command now prints
`CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`,
exit 0. A `/tmp` copy with only that token removed reproduced the claimed CLEAN
line, isolating the cause. The fixture path was mutable during the wave; the
parent may want to confirm the final committed bytes (`23583252…`) are the
intended ones.

## Independent positive re-measurements (attacks that found no defect)

- **Lane census:** `bash corpus/sources-census.sh` → exit 0,
  `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1
  entries_sourced=4 legacy=21)`. `--selftest` → exit 0, `PASS (59 cases)`.
- **C1:** `python3 corpus/closure-dispositions.py` → exit 0, `CLEAN
  (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0
  pointers=15)`. 15 JSON dispositions; class counts sum to 15. `--selftest` →
  exit 0, `PASS (14 cases)`. The claim row `R23-02`
  (`corpus/claim-ledger.tsv:60`) pins `fixed=6 reported=3` and matches.
- **C3:** the exact command from `corpus/claim-ledger.tsv:59` printed the exact
  claimed `CELL_AUDIT: CLEAN` line, exit 0.
- **Provenance re-fetch (10/10):** each of the ten `source-fetches.tsv` URLs was
  fetched with the declared profile
  `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation
  verification)' <url>`; all returned HTTP 200, curl exit 0. Implementing the
  declared normalization (strip `script`/`style`, tags→space, `html.unescape`,
  collapse whitespace, trim, UTF-8) reproduced **10/10** declared
  `normalized_sha256` values and found **10/10** declared quotes present in the
  normalized text. Raw bytes matched **9/10**; S020 drifted
  (`53dfeac5…` declared → `eab91845…` live, both 190261 bytes) exactly as the
  declared `decoded-http-body-volatile-v1` permits.
- **Row identities:** recomputing `sha256(id<TAB>status<TAB>url<LF>)`
  reproduced **10/10** column-3 values.
- **Coverage/accounting:** 26 registry rows partition exactly into 16 in-row
  pins (S001-S016) and 10 provenance rows (S017-S026), no overlap, no gap.
  Distinct URLs are 19 at round end vs 18 at base, only the KV v2 URL new; the
  tsv has 10 rows over 9 distinct URL strings, matching the lesson and LOG.

## Residual risk and verification gaps

- The W04 repair is verified through worktree `130d70e0…`/HEAD `3f9fe72`; the tree advanced
  repeatedly during the review. A later edit could change the set again. Re-run
  the two commands below before integrating.
- All seven W04 warnings are genuine under the fleet tool’s scope-sensitive
  rule; W04 exits 0 by design, so “seven” is not a failure signal.
- The live fetch is today’s representation of the ten pages, not an authorship
  or truth check; quote/location content remains a declared point attestation,
  as the lesson’s bounds now state.
- S020’s raw drift proves raw volatile captures are not re-verifiable; only the
  normalized digest is. The declared UA was honored today, not guaranteed.
- The C1 pointer test remains presence-only (file + anchor substring + id
  token); it cannot distinguish “D1 fixed” from “D1 re-quoted incompletely.”
  That is why F1 coexisted with a CLEAN C1 gate at `def9bc2`.
- The 43-row parent audit was not re-run, per instruction. No host gates were
  opened, no installs performed, no secrets read.

## Command / exit appendix (final HEAD unless noted)

| Command | Exit | Last line / observation |
|---|---|---|
| `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | 7 W04 + `kagi ok` |
| `bash scripts/sources-census.sh census kagi` | 0 | `kagi rows 26`; 0 W04 |
| base `d218603` archive: `… validate --root "$T" --file "$T/corpus/SOURCES.md" kagi` | 0 | 5 W04 (S019-S023) + `file ok` |
| `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=26 …)` |
| `bash corpus/sources-census.sh --selftest` | 0 | `PASS (59 cases)` |
| `python3 corpus/closure-dispositions.py` | 0 | `CLEAN (… fixed=6 reported=3 … pointers=15)` |
| `python3 corpus/closure-dispositions.py --selftest` | 0 | `PASS (14 cases)` |
| `bash corpus/claim-ledger.sh cells …` (R23-01) | 0 | exact `CELL_AUDIT: CLEAN (… missing_ids=0 …)` |
| 10 × declared `curl` profile | 0 | all HTTP 200; 10/10 normalized + quote; 9/10 raw (S020 volatile) |
| **historical** old `bash corpus/sources-census.sh` (`80966e20…`) | 1 | `line 242: S007: unbound variable` |
| **historical** R23-01 on old fixture | 1 | `MISSING-ID SCORECARD.md:1 R23-01` / `BROKEN … missing_ids=1` |
