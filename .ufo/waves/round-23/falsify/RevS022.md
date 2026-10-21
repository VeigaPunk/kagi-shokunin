# RevS022 — round-23 falsification: S022 provenance + C1/C2/C3 re-measure

Seat: RevS022 (falsification). Date: 2026-10-21. Base: `d218603b74099ddca0bd8f869516fc41db0979bf`
plus the uncommitted round-23 working tree at `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Host facts: bash 5.3.20(1), curl 8.23.0. Read-only seat: no lane edits, no git mutation,
no installs, no host-bound gates; scratch work only under `/tmp/revS022`.

**The tree moved under this audit.** The round-23 files were rewritten during measurement
(mtimes 04:02:21–04:14:03 UTC). Findings are therefore state-scoped:

- **State A** — the tree as it stood when the falsification wave began and as I measured it
  (03:56–04:01 UTC). At State A: the C2 census gate aborted with no verdict, the C2
  cardinality text said seven URLs (measured nine), and S022's `location` field named the
  wrong section. S022's digests/bytes/identity/quote were correct.
- **State B** — last measured snapshot, 04:15:26 UTC (five rewrites landed during the audit:
  04:02:21–04:04:32 UTC, 04:06:58, 04:08:16–04:09:41, 04:10:37–04:11:27, and a lesson-only
  rewrite at 04:14:03 UTC; the S022 row bytes are unchanged and the census still exits 0).
  The three State A defects are gone:
  census exits 0, the cardinality text says nine, and S022's location now says
  `Introduction, Vault 1.17 Note`. C1 and C3 pass at both states. Finding N (a transient
  header/code contradiction inside the census) was live at 04:09:42 and resolved at
  04:10:59–04:11:27 when the cross-capture rule was removed and the header/lesson were aligned;
  only unused `FDIG`/`FNRM`/`seen_key` declarations remain as cosmetic residue.

No attributed blame is implied; the editor is not identified. Any final verification must
pin a commit or the State B hashes below, because a check against "the tree" is not stable.

| file | State B sha256 | State B mtime (UTC) |
|---|---|---|
| `corpus/sources-census.sh` | `511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58` | 04:10:59 |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | 04:10:37 |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | 04:11:27 |
| `corpus/lessons/round-23.md` | `93df7d345554b99c1daf87fb75234ba273cff0d2fc8be691a4d5df56f0242cb4` | 04:14:03 |
| `LOG.md` | `57dc73966c6f9e56dcd83b035ca851054ee80fe512866de5607039d1486ef43f` | 04:11:27 |
| `SCORECARD.md` | `7dc220f625bea84146e17e9fe67230a7eb6e504ff4aab718beda6e05987805d7` | 04:11:27 |
| `corpus/claim-ledger.tsv` | `5986945977b658d9f02b6af0f80146da6065eab41a28265d67b590394992069c` | 04:10:37 |
| `corpus/closure-dispositions.json` | `00fbf48d3ea233d01a7d56ae6ca3291955df82ea522a91e3f3d7dc5644c535e8` | 04:04:15 |
| `corpus/fixtures/cells-hermetic/claims.tsv` | `1a0737717ddc5b0ca053ac3677621be36f598d4158f34956d58dadf1feae7915` | 04:03:17 |

State A census bytes are recoverable only by reconstruction from my `/tmp` copy:
`80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`, 36,022 bytes
(patched copy minus the inserted ` SUPERSEDED=()` token, 14 bytes including the leading
space). It is labelled reconstructed, not observed.

---

## 1. S022 re-measurement — digests and identity reproduce at both states

Registered row `corpus/SOURCES.md:28`; provenance row `corpus/source-fetches.tsv:42`
(16 fields, no embedded tabs; the census malformed-row mask returns no lines).

### 1.1 Fetch with the declared profile (State A and State B, independently)

```console
$ mkdir -p /tmp/revS022 && cd /tmp/revS022
$ curl -fsSL --compressed \
    -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    -D hdr.txt -o body.html \
    -w 'http=%{http_code} final=%{url_effective} size_download=%{size_download}\n' \
    https://developer.hashicorp.com/vault/docs/auth/jwt
http=200 final=https://developer.hashicorp.com/vault/docs/auth/jwt size_download=53338
exit=0
$ wc -c body.html
386400
$ sha256sum body.html
9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa  body.html
```

Headers: `HTTP/2 200`, `content-encoding: br`, `date: Wed, 21 Oct 2026 03:57:31 GMT`,
`etag: W/"989fbb89c19fdad8a8a4da184f1acb16"`, `age: 6228`. curl reported
`size_download=53338`; the decoded body is 386,400 bytes, and both the declared `sha256`
and the declared `bytes` match exactly. A second GET at 04:00:45 GMT (`age: 6422`, same
ETag) produced the identical raw hash, byte count, normalized digest and quote presence.
The declared `decoded-http-body-volatile-v1` is conservative for this capture, not false.

### 1.2 Row identity, normalization and quote

```console
$ printf 'S022\tmined\thttps://developer.hashicorp.com/vault/docs/auth/jwt\n' | sha256sum
4e184ddb7e9a08e1f86a9a9b82cf1c17f9b7a350657262c6a105702ee47f48b0  -
```

= field 3. `status=mined` equals the registry status (`SOURCES.md:28` field 9); the census's
own extraction prints `id=S022 url=https://developer.hashicorp.com/vault/docs/auth/jwt`.
URL string, final URL, HTTP 200, request profile and fetched date all equal the declared
fields.

`rendered-text-v1` recomputed independently (strip `script`/`style` with contents, tags to a
single space, `html.unescape`, collapse `\s+`, trim, UTF-8):

```console
norm_bytes 18609
norm_sha256 06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431
quote_found True
quote_index 3538
quote_words 21
```

`06d2508c…a431` equals field 15; 21 words ≤ 25. The quote occurs exactly once in the
rendered text and is byte-identical to field 13:
`the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT.`

### Finding L (low at State A; fixed at State B) — `location` named the wrong section

- State A (`source-fetches.tsv:42` field 16): `JWT verification, Vault 1.17 note`.
  The quote's own raw-HTML offsets (116102–116471, mapped through the same normalization)
  put it under `H1 Use JWT/OIDC authentication` (raw 112204) and before
  `H2 OIDC authentication` (118483); `H3 JWT verification` starts at raw 148743 and carries
  only a variant (`…bound_audiences for the role…`, without `"jwt"`). The registry row
  (`SOURCES.md:28` field 7) and the round-22 errata
  (`corpus/lessons/round-22-source-errata.md:16`) both say `Introduction Vault 1.17 note`.
  The gate could not catch this: at State A it checked only `${#floc} -ge 8`
  (then line 280; current line 274), and the current lesson now admits the bound that
  "quote text is not substring-checked" (`corpus/lessons/round-23.md`, Falsification bounds).
- State B (`6e26e140…`; `846b2037…` at the 04:07 snapshot, `a78fde7b…` at 04:05): field 16 is
  `Introduction, Vault 1.17 Note` — matches the page and
  the earlier records. The other S022 fields are unchanged; the State B row still reproduces
  every digest above.

---

## 2. Finding H (high at State A; fixed at State B) — census gate aborted with no verdict

### State A evidence

```console
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
exit=1
```

No `SOURCES_CENSUS:` line was printed, violating the script's own
"VERDICT (last line, always)" contract (`corpus/sources-census.sh:93`). `bash -x` showed:

```
+ [[ -n S007 ]]
+ SUPERSEDED[$fid]=1
corpus/sources-census.sh: line 242: S007: unbound variable
```

Root cause: State A line 229 declared
`declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()` and omitted `SUPERSEDED`;
line 242 then assigned `SUPERSEDED[$fid]=1`. With no associative declaration the subscript
is arithmetic, so the first printed value `S007` expanded as variable `S007` and `set -u`
(`corpus/sources-census.sh:107`) aborted the run. `S007` is printed by the
`supersedes S…` awk for `SOURCES.md:25` (row S019, first such row). `SUPERSEDED` was never
read anywhere else (only reference: line 242) — the loop was otherwise dead code.
`git show HEAD:corpus/sources-census.sh | grep -c SUPERSEDED` → `0`, so this was new in the
round-23 diff.

Data-vs-code isolation at State A: copying the script and adding only `SUPERSEDED=()` to
line 229 (`/tmp/revS022/patched.sh`) gave
`SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`,
exit 0. The provenance data was consistent; the gate was not.

Selftest blind spot at State A: `bash corpus/sources-census.sh --selftest` →
`PASS (59 cases)`, exit 0, while the real tree crashed. The fixture registry rows' teaches
cells were `teaches one/two`, `lead three`, `product four` — no `supersedes` clause — and
`grep -n 'supersedes' corpus/sources-census.sh` returned only the crashing loop and its awk,
so no case executed line 242.

### State B attestation

`corpus/sources-census.sh` (current `511deb27…`, 04:10:59 UTC; the crash loop was removed at
04:02:21 and the fetch-section header/cross-capture policy was reworked at 04:08:48–04:10:59)
no longer contains the `SUPERSEDED` loop; line 242 is now `if [[ -f $fetchf ]]`. Re-run at
04:12:33 UTC:

```console
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit=0
$ bash corpus/sources-census.sh --selftest | tail -1
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit=0
```

So the claimed end-of-round evidence (`corpus/lessons/round-23.md:61` and the end-of-round
statement at current line 179; `LOG.md:1194`) reproduces at State B but did **not** reproduce
at State A. Independent corroboration of the State A failure:
`.ufo/waves/round-23/falsify/ScoutAppendOnly.md:31-33`. The fix landed silently in the working
tree; the lesson's "Falsification bounds" section does not record the mid-wave C2 repair.

---

## 3. Finding M (medium at State A; fixed at State B) — URL cardinality

```console
$ awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
9
$ grep -c '^S0' corpus/source-fetches.tsv
10
$ # S017–S023 subset:
$ awk -F'\t' '$1 ~ /^S01[7-9]$/ || $1 ~ /^S02[0-3]$/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
7
$ # S024–S026 subset:
$ awk -F'\t' '$1 ~ /^S02[4-6]$/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
3
```

The 10 rows S017–S026 cover 9 distinct URL strings: S021 and S026 share
`https://openbao.org/docs/concepts/tokens/` with identical raw digest `52295218…` and
identical normalized digest `ed949658…`. Seven is the distinct count of the S017–S023 subset
only.

- State A text: `corpus/lessons/round-23.md:165` — "10 declared provenance rows (S017-S026)
  over seven distinct URLs"; `LOG.md:1202` — "10 declared captures over 7 URLs";
  `SCORECARD.md:840` — "S024-S026 are correction rows over seven distinct URLs"
  (measured: 3 distinct URLs for that subset). No counting command accompanied the seven.
- State B text: `corpus/lessons/round-23.md:175` and `LOG.md:1202` both say nine;
  `SCORECARD.md:840` now says "the 10 captures cover nine distinct URLs". Re-measured: 9.
  The registry-side count remains correct: 26 rows / 19 distinct URLs, consistent with the
  "18 → 19" sentence at `corpus/lessons/round-23.md:173-174`.

No data defect: the State B census run is CLEAN; S021/S026 have identical raw and normalized
digests. The same-URL agreement rule that the State A/early-State-B code enforced was removed
at 04:10:59 UTC, and the header and M23-1 were aligned with the removal (see Finding N).

---

## 4. Finding N (low, transient) — census header/cross-capture rule contradiction

Live window: 04:08:48–04:10:59 UTC. At 04:09:42 the fetch-section header
(`corpus/sources-census.sh:64-66`) said "Captures are point attestations: no cross-capture
equality is enforced, only one provenance row per id", while the code still enforced raw
same-URL agreement for non-volatile representations and normalized agreement for
`rendered-text-v1` (then lines 282/288), and the selftest's `fetch-disagree` case expected
2 findings (duplicate-provenance + same-url disagreement). Lesson M23-1 simultaneously said
"same-URL captures must agree" (then line 145; current line 146).

Resolution at 04:10:59 UTC (`511deb27…`): the same-URL comparisons were removed
(`grep -n 'same-url' corpus/sources-census.sh` → no code hits), the selftest expectation became
1 finding (`corpus/sources-census.sh:553`), the header now matches the code, and M23-1 now says
"captures are point attestations and no cross-capture equality is enforced"
(`corpus/lessons/round-23.md:146`). The lesson's hash-domain paragraph agrees
(`corpus/lessons/round-23.md:54`). The current state is internally consistent.

Residue: `corpus/sources-census.sh:228-229` still declares `seen_key`, `FDIG` and `FNRM` after
the checks that used them were removed; `grep -n 'FDIG\|FNRM\|seen_key'` returns only those two
lines. Cosmetic dead declarations, no behavioral effect.

Effect while live: the stated bound understated the gate (no false-pass risk), and M23-1
contradicted the header. The window is recorded because the wave packet's claim "captures are
point attestations" was true of the policy while the code of that revision still enforced
cross-capture equality.

---

## 5. C1 and C3 — pass at both measured states

**C1 calibration.** Current `python3 corpus/closure-dispositions.py` → exit 0:
`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`.
`corpus/closure-dispositions.json` (`00fbf48d…`) holds 15 dispositions: 7 fixed / 2 reported /
1 operator-owned / 5 no-action (classes 9 routed-defect, 5 spot-decision, 1 adjudication);
`source_sha256` matches `corpus/lessons/round-22-verifier-spotcheck.md`. `--selftest` →
`PASS (13 cases)`, exit 0 (missing / duplicate / unknown / pointer-missing / pointer-id /
pointer-anchor / bad-kind / short-note / pointer-escape / class-mismatch / source-drift /
digest-mismatch mutants all killed). The JSON changed at 04:04:15 UTC but the verdict line and
counts are identical to State A.

**C3 operability.** `corpus/claim-ledger.tsv:59` R23-01 current command →
`CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`,
exit 0 — byte-for-byte the expected line. Three independent `/tmp` mutations of the current
fixture (`1a073771…`) each fail with exit 1: uncited cell → `CELL_AUDIT: BROKEN … uncited=2
orphans=1`; renamed claim id → `MISSING-ID` ×3, `missing_ids=3`; failing command →
`FAIL R90-01 reason=exit-mismatch`, `row_failures=1`. The fixture is host-free:
`corpus/fixtures/cells-hermetic/corpus/fx-ok.sh` only prints `FX: OK`, the adjacency file is
local, and no cited row invokes `claim-ledger.sh` (so `self_skipped=0` is real). The fixture
changed at 04:03:17 UTC (second claims row's numeric field 10→30; the adjacency
stamp hash changed) and still passes; the mutation checks above used the current bytes. A
pre-change fixture run also passed CLEAN with the same expected line and failed the same three
mutations.

---

## 6. Residual risk and verification gaps

- **Moving target.** The audited files were rewritten at 04:02:21–04:14:03 UTC, between my
  State A measurements and the State B snapshot, in five waves (04:02:21–04:04:32, 04:06:58,
  04:08:16–04:09:41, 04:10:37–04:11:27, and a lesson-only rewrite at 04:14:03 UTC).
  `source-fetches.tsv`, the lesson and the census script each changed twice or more;
  `corpus/lessons/round-23.md`, `LOG.md`, `SCORECARD.md` and `corpus/SOURCES.md` were all
  touched in the 04:11:27 wave. The gates were last run at 04:12:33 UTC; the 04:14:03 lesson
  rewrite shifted the cited passages by one line but did not change their substance. A final
  verdict must pin the State B hashes (or a commit), because "the tree" changed mid-wave. My
  report deliberately records both states; the State A falsifications were real at launch and
  are remediated at State B.
- **Narrative gap.** The current lesson says the wave "reported on the three claims"
  (line 184; it said "confirmed" at 04:06), which is honest, but it still does not date or
  record the mid-wave C2/location repairs or the same-URL policy reversal; those are visible
  only through mtimes/hashes and this report. A reader of only the final tree cannot
  distinguish launch state from remediated state.
- **Point attestation only.** Both S022 GETs hit the same CDN object (`age` 6228/6422 s, same
  weak ETag). The origin may have changed since; the declared volatile representation is the
  right bound and the normalized digest is the stable identity.
- **Crash mechanism portability.** Reproduced on bash 5.3.20; the indexed-array subscript
  arithmetic under `set -u` is deterministic (`bash -uc 'SUPERSEDED[S007]=1'` → unbound).
- I did not run the external fleet `kagi` census / W04 warnings (out of lane, host/fleet-bound);
  the in-repo `sources-census.sh` is the gate under audit.
- The S022 location finding rests on my normalization→raw-offset mapping; the exact match of
  the declared normalized digest `06d2508c…` anchors that mapping to the same representation
  the author hashed.
- Tool installs/updates this seat: none.

---

## 7. Post-snapshot churn — latest check 04:19:36 UTC (gates re-run 04:18:50)

The working tree changed again after the body's 04:15:26 snapshot. Latest measured state:

| file | sha256 | mtime (UTC) |
|---|---|---|
| `corpus/sources-census.sh` | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` | 04:16:11 |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | 04:10:37 (unchanged) |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | 04:11:27 (unchanged) |
| `corpus/lessons/round-23.md` | `4e971e3d4101d6e28b13d02acbef9adf3ccf16101cfe95831c243891d24029a5` | 04:18:44 |
| `LOG.md` | `d052458cfc0854b1825efb6e9837061270e76443bb9c15aeebcf61ac0a2eced9` | 04:16:11 |
| `SCORECARD.md` | `94a34c9fd0de49e8d0d6e79843335dc9cc6bb1479d4d84002e2b2297282fe331` | 04:15:47 |
| `corpus/claim-ledger.tsv` | `ed125ca5aefb4bc60d445b018fc35c2ac876dc45d14252c3625b3bb9df779b38` | 04:15:27 |
| `corpus/closure-dispositions.json` | `67ac1a42427eca7bc38a0f6785385a3b8039f1e61de24a1716ab76c8bbc5ff60` | 04:18:18 |
| `corpus/fixtures/cells-hermetic/claims.tsv` | `1a0737717ddc5b0ca053ac3677621be36f598d4158f34956d58dadf1feae7915` | 04:03:17 (unchanged) |

Re-measured at 04:17:18–04:18:01 UTC:

- `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1
  mined=24 rejected=1 entries_sourced=4 legacy=21)`, exit 0; `--selftest` → `PASS (59 cases)`,
  exit 0.
- `python3 corpus/closure-dispositions.py` → `CLOSURE_DISPOSITIONS: CLEAN (obligations=15
  fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)`, exit 0;
  `--selftest` → `PASS (14 cases)`, exit 0. This supersedes the body's 7-fixed/2-reported and
  13-case figures: D3 moved `fixed` → `reported` ("id-shaped positionals remain debt"), and
  `corpus/claim-ledger.tsv:60` (R23-02 expected line), `SCORECARD.md:843`, and the lesson C1
  row (`corpus/lessons/round-23.md:60`, "selftest 14 cases") are all consistent with the new
  mix. `corpus/closure-dispositions.json` contains 15 dispositions with that mix.
- C3 unchanged: `corpus/claim-ledger.tsv:59` R23-01 still matches
  `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0
  rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`,
  exit 0 (regex check exit 0).
- S022 unchanged: `corpus/source-fetches.tsv:42` still has
  `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` / 386400 /
  `06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431` /
  `Introduction, Vault 1.17 Note`; row-identity digest still `4e184ddb…`.
- Census cleanup at 04:16:11: the unused `FDIG`/`FNRM` declarations are gone
  (`corpus/sources-census.sh:229` now declares only `FURL`, `FINROW`, `FSEEN`); `seen_key`
  remains declared but unused at line 228. Finding N's residue note is narrowed to that token.
- Lesson line shifts and one rewrite: the body's snapshot citations (M23-1 line 146, nine
  distinct 175, census-end 179, "reported on" 184) now sit at lines 151, 180, 183–184 and 188
  respectively. The census-end sentence itself was rewritten: it now says "Census at round
  start: exit 0 with five W04 warnings at base …; at round end the fleet wrapper emits seven
  and the lane census exits 0 with `rows=26`". The substantive claim this seat checked (lane
  census exit 0 with rows=26) is unchanged.
- C1 selftest count is now 14 cases (`python3 corpus/closure-dispositions.py --selftest` →
  `PASS (14 cases)`, exit 0), matching the lesson C1 row (`corpus/lessons/round-23.md:60`).

The churn itself is the top residual risk: the round-23 tree changed at least six times
during this audit (04:02:21–04:16:35 UTC), including closing the exact defects this seat and
its peers measured. A final integration/verification must pin the commit or the hashes above;
no check in this report should be read as a statement about the tree's final bytes.

