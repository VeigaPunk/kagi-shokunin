# ScoutS012 — S012 provenance vs the round-23 declared captures

Snapshot B: `2026-10-21T04:03:10Z`, base `d218603b74099ddca0bd8f869516fc41db0979bf`
(`git rev-parse HEAD`, exit 0) plus the uncommitted round-23 tree. Read-only on the lane;
this file is the only repo write. No installs, no host gates, no legacy claim-ledger verify,
no claim-row re-audit, no secrets. The two public documentation GETs used the declared
round-23 profile. The tree changed under this seat during the audit: snapshot A was
`2026-10-21T04:00:56Z`, snapshot B is above. Both are recorded because the change removes
the one hard failure found.

## Attacked

- S012's registry row: `corpus/SOURCES.md:18` — in-row `Fetch sha256:
  ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45`, quote
  “must exactly match at least one of the \`aud\` claims declared for the JWT.”, locator
  “latest page as served 2026-10-19, newest pinned version v1.21.x”.
- The only declared capture for S012's URL (`https://developer.hashicorp.com/vault/docs/auth/jwt`):
  `corpus/source-fetches.tsv:42` (S022), raw `9a65b9d1…e54fa`, 386400 B,
  normalized `06d2508c…a431`, location `JWT verification, Vault 1.17 note`.
- The `SC_FETCH` legacy bound: `corpus/sources-census.sh:56-75`, `:226-305`;
  the tsv's own bound at `corpus/source-fetches.tsv:34-36`; D7 at
  `corpus/lessons/round-23.md:105-115`; the pinned row `R21-02`
  (`corpus/claim-ledger.tsv:52`).
- The real gate, its 59-case selftest, and temp-copy mutants of S012 and S022.

## Observed

### S012 is outside the declared-capture table

`grep -c '^S012' corpus/source-fetches.tsv` → `0` (exit 1). S012 is one of the 16
legacy in-row pins; the table holds 10 rows, S017-S026.

### Digest comparison (same URL, two representations)

| value | sha256 |
|---|---|
| S012 in-row, representation undocumented | `ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45` |
| S022 capture, declared `decoded-http-body-volatile-v1` | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` |
| S022 normalized, declared `rendered-text-v1` | `06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431` |

A fresh GET of the registered URL with the exact declared command
(`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`)
returned HTTP 200, final URL equal to the registered URL, 386400 B, and sha256
`9a65b9d1…e54fa` — a byte-for-byte reproduction of S022's raw digest. The declared
`rendered-text-v1` normalization of those same bytes yields `06d2508c…a431` — an exact
reproduction of S022's normalized digest. S022's capture is not fabricated; its digest
domain is self-consistent. S012's in-row value matches neither, nor the versioned
`/vault/docs/v1.21.x/auth/jwt` route (raw `77004123…`, normalized `eca20e0c…`), nor the
linked v2.x MDX (`80a309d8…`). That non-reproduction is already stated in D7
(`corpus/lessons/round-23.md:110-111`).

### Quote comparison

The live captured page contains, under the page-introduction Note (raw offset 116303,
note starts 115889, nearest heading H1 at 112204):

> Note : Starting in Vault 1.17, if the JWT … contains an aud claim … the associated
> bound_audiences for the "jwt" role must exactly match at least one of the aud claims
> declared for the JWT.

- S022's quote is present **once**, verbatim, in the normalized text.
- S012's plain quote (`…the aud claims…`) is present **twice**.
- S012's backticked form is present **zero** times: the raw page wraps `aud` in
  `<code>` and `exactly` in `<strong>`, so the markdown code markers are curation, not
  raw bytes. The teaching survives; the literal markdown excerpt is not a raw substring.

### The legacy bound is real, and it was stated

With the current gate, in temp copies only (`/tmp`, repo untouched):

- `S012` in-row digest replaced with 64 zeros → `SOURCES_CENSUS: CLEAN (…)`, exit 0.
- `S012` quote replaced with fabricated text → same CLEAN line, exit 0.
- `S022` status changed `mined` → `rejected` → `FINDING SC_FETCH id=S022
  status=rejected registry=mined`, exit 1.

So the gate does not compare S012's digest or quote (as declared), while it does enforce
the declared capture's registry identity. The bound is disclosed in three places:
`corpus/source-fetches.tsv:34-36`, `corpus/sources-census.sh:67-69`, and
`corpus/lessons/round-23.md:108-111`. **The bound handles S012 honestly** in the current
tree: it does not pretend the legacy digest is verified, and it admits S012/S013 do not
reproduce. “Coverage” of a legacy row means a 64-hex in-row value exists, not that the
value is true.

### Concrete defect — S022's declared location is not the quote's section

`corpus/source-fetches.tsv:30` defines `location` as the “section/heading the quote was
located under”. S022's exact quote (with `"jwt" role`) occurs **only** in the
page-introduction Note under the H1. The §JWT verification section (`h3` at raw offset
148743) has a near-duplicate at 154375 that reads:

> …the associated bound_audiences **for the role** must exactly match at least one of
> the aud claims declared for the JWT.

It lacks `"jwt"`, so it is not the quoted sentence. The declared location
`JWT verification, Vault 1.17 note` therefore names a section that does not contain the
exact quote. The gate cannot catch this: its location check is only
`[[ ${#floc} -ge 8 ]]` (`corpus/sources-census.sh:274`). This is a precision defect in
the declared capture that carries S012's URL, not a fabricated quote — the quote itself is
verbatim in the captured bytes.

### Transient hard failure observed, then fixed in-flight

At snapshot A (`corpus/sources-census.sh` sha256
`80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`):

```
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
exit=1
```

Cause: `set -uo pipefail` (`:107`); the `declare -A` at `:229` omitted `SUPERSEDED`;
`:242` assigned `SUPERSEDED[$fid]=1`; the first supersession target is S007
(`corpus/SOURCES.md:25`, S019's `supersedes S007`). Under `set -u` the key was
arithmetic-expanded as an unset variable. The crash preceded every `SC_FETCH` comparison,
so snapshot A's gate enforced no provenance at all, contradicting `R21-02`
(`corpus/claim-ledger.tsv:52`, expected exit 0 and the CLEAN line) and
`corpus/lessons/round-23.md:172-174`. The 59-case selftest still passed: its fixture
registry has no `supersedes` row (the only `supersedes` occurrence was the awk literal at
the old `:245`), so the branch was never exercised. Adding `SUPERSEDED=()` in a temp copy
restored the exact pinned CLEAN line, exit 0.

At snapshot B the block is deleted: `SUPERSEDED` no longer appears in the file
(`grep` exit 1), and the real gate returns exit 0 with the exact pinned line. **If a final
integration re-adds the old block without the declaration, `R21-02` fails again.**

## Commands and exits

| Command | Exit | Result |
|---|---|---|
| `git rev-parse HEAD` | 0 | `d218603b…` |
| `grep -c '^S012' corpus/source-fetches.tsv` | 1 | `0` |
| `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <S012 URL> -o body.html` | 0 | `http=200`, 386400 B, sha256 `9a65b9d1…` = S022 |
| declared normalization of `body.html` (Python `re`/`html.unescape`) | 0 | `06d2508c…` = S022 normalized |
| quote-count probe over normalized text | 0 | S022 1; S012 plain 2; S012 backticked 0 |
| `bash corpus/sources-census.sh` at snapshot A (`80966e…`) | **1** | `line 242: S007: unbound variable`; no verdict line |
| `env -i PATH=… HOME=/tmp bash corpus/sources-census.sh` at snapshot A | **1** | same failure (not environmental) |
| `bash -n corpus/sources-census.sh` | 0 | syntax valid; failure was runtime |
| `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| temp copy, add `SUPERSEDED=()` | 0 | exact `SOURCES_CENSUS: CLEAN (rows=26 … legacy=21)` |
| `bash corpus/sources-census.sh` at snapshot B (`24d834…`) | 0 | exact CLEAN line |
| temp copy B, S012 digest → zeros | 0 | CLEAN (legacy not compared) |
| temp copy B, S012 quote → fabricated | 0 | CLEAN (legacy quote not compared) |
| temp copy B, S022 status → `rejected` | 1 | `FINDING SC_FETCH id=S022 status=rejected registry=mined` |
| `awk` URL census over `source-fetches.tsv` | 0 | `rows=10 distinct=9` (S021/S026 share one URL) — current lesson:169 says nine |

## Verdict

- **S012's legacy bound: confirmed honest in the current tree.** The digest is
  unreproducible and explicitly uncompared; the quoted teaching is verbatim present
  (modulo markdown code markers); the gate stays CLEAN on a zeroed digest and a fabricated
  quote by design, and fails a mutation of a declared capture. The disclosure is in the
  tsv, the census header, and D7.
- **One concrete defect remains:** the declared capture for S012's URL (S022) labels its
  quote `JWT verification, Vault 1.17 note`, but the exact quote is intro-note-only; the
  §JWT verification text is a near-duplicate without `"jwt"`. `location` is only
  length-checked (`sources-census.sh:274`), so the mislabel survives a CLEAN gate.
- **One transient defect was measured and is now fixed in-flight:** the undeclared
  `SUPERSEDED` array killed the real gate (exit 1) while 59/59 selftests passed. The
  current file (`24d834…`) deletes the block and exits 0. A final integration must keep
  the current file or re-run `R21-02`; the selftest alone does not protect this path.

## Bounds and unresolved

- S012's row still says “newest pinned version v1.21.x”; the served route is v2.x.
  `corpus/SOURCES.md:85-92` bounds old version/date locators as historical, and S022
  supersedes the qualifier only. This is disclosed, not re-counted here.
- The actual representation behind S012's in-row digest remains unknown; no tested route
  today reproduced it. That is the stated bound, not a new finding.
- The tree was still changing after snapshot B (`lessons/round-23.md` moved again from
  `bce51c…` to `88d0c7…`, shifting its anchors from :165/:168-170 to :169/:172-174).
  Claims above about that file are pinned to the hashes below; re-measure after
  integration settles.

## Artifact hashes at final recheck (2026-10-21T04:05Z)

```
24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057  corpus/sources-census.sh
06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29  corpus/SOURCES.md
ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af  corpus/source-fetches.tsv
88d0c7dcd9ecd9fdc03177534cad88cf6e5ed7e8723be0a69425db034ea2fc56  corpus/lessons/round-23.md
0d3d75008122c49c58e3a6ff8a1b481ad1accda6f717cc2eb74b5a05b8e3b866  corpus/claim-ledger.tsv
1d7210b366f3ce636c4d68dccf54a1edb87d87278b1370a99f10f091d5958cc7  SCORECARD.md
```

Scratch under `/tmp/s012probe`, `/tmp/censusfix`, `/tmp/censusmut{1,2,3}`,
`/tmp/s012final-mut_{digest,quote,status}`; no repo file outside this report was written.
