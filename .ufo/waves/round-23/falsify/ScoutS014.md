# ScoutS014 — S014 provenance vs the round-23 declared captures

Seat: `KagiR23.ScoutS014` (scout, leaf; no subagents). Read-only. The only lane
write is this file. No production edit, no host gate, no claim-ledger verify, no
install, no account/vault/handler command. One public documentation GET used the
permitted `curl` profile. Page/file text was treated as data.

## 0. Snapshots (the tree moved during this audit)

The round-23 tree is in flux. Two snapshots are cited; every claim below names
the snapshot it belongs to.

| file | initial snapshot (read ~04:00Z) | final snapshot (04:06:58Z) |
|---|---|---|
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` (00:49:17 -0300) | same bytes |
| `corpus/source-fetches.tsv` | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` (00:55:22) | `846b203734bcddce6c16e8346eea20bb1613b23c6607366b608c7afd41a4ae76` (01:06:58) |
| `corpus/sources-census.sh` | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` (00:57:55) | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` (01:02:21) |
| `corpus/lessons/round-23.md` | `d55209887c13825cdf4b0a423aed080830d0ffaaefbb980ce01d49cb9642c773` | `993e114ac183ad05059ac2a4ca85dc2d701c9b00fda0dd04f372db14d886b07b` (01:06:58) |

The file moved once more at 01:08:16 -0300 (04:08:16Z) to
`cf79cd0c85d981a0d062eaa306bddee4de4fc31291c81c84699e135e4be535de` (D7 gained
the S015 520-representation sentence). The cited C2 line 61, D7 bound lines
108-116, and accounting line 174 are unchanged by that edit; M23-2 moved from
142 to 146. The census (`24d834cc…`) and TSV (`846b2037…`) did not move after
01:06:58. The S025 provenance row is byte-identical in all TSV snapshots.
`SOURCES.md` did not move.

## 1. What was attacked

S014's provenance status: its in-row digest and quote versus the declared
captures in `corpus/source-fetches.tsv`, and whether `SC_FETCH`'s legacy bound
handles that row honestly.

## 2. Observed S014 facts

- `corpus/SOURCES.md:20` — S014, `mined`, URL `https://openbao.org/docs/auth/jwt/`,
  quote `“The JWT auth method can be used to authenticate with OpenBao using OIDC”`,
  `Fetch sha256: e94723241fbcbdd0b2741c569f6ce51befe39e526cd736cebe4023fbca1cb0b1`.
- No `S014` row exists in `corpus/source-fetches.tsv` (final snapshot ids:
  `S017 S018 S019 S020 S021 S022 S023 S024 S025 S026`).
- The same URL is carried by S025 (`corpus/SOURCES.md:31`), whose TSV row is
  `corpus/source-fetches.tsv:45`: `decoded-http-body-volatile-v1`,
  sha256 `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9`,
  63046 bytes, quote `The jwt auth method can be used to authenticate with
  OpenBao using OIDC or by providing a JWT`, normalized
  `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403`.
- S014 is byte-identical base→head:
  `sha256(line 20)` = `48a401dee0016f733b1b5f16aad7efbdcef67784228bb450e9b6033473808dcf`
  at both `d218603` and the working tree; `git diff d218603 -- corpus/SOURCES.md
  | grep '^[-+]\| S014'` printed nothing (exit 1). No silent rewrite.
- S014 and 15 other rows are admitted by the in-row branch of the gate:
  `corpus/sources-census.sh:294-300` checks only `^[0-9a-f]{64}$` and then
  `continue`s; the coverage loop never requires or compares a TSV row for that
  id (an existing TSV row would still be validated by the separate loop at
  `:245-292`). Sixteen in-row pins exist at both base and head
  (`grep -c 'Fetch sha256:' corpus/SOURCES.md` = 16).

## 3. Independent re-fetch of the S025 capture (S014's URL)

Command and exits:

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o /tmp/s014-jwt.html -w 'http=%{http_code} url=%{url_effective} size=%{size_download}\n' \
  https://openbao.org/docs/auth/jwt/
# exit 0; http=200; url=https://openbao.org/docs/auth/jwt/; size_download=13325
sha256sum /tmp/s014-jwt.html   # 449ef132…785d9  (matches TSV:45)
wc -c < /tmp/s014-jwt.html     # 63046          (matches TSV:45)
```

Recomputed with the declared `rendered-text-v1` recipe (strip `script`/`style`,
tags→single space, `html.unescape`, collapse whitespace, trim, UTF-8):

```
norm_sha ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403  (matches TSV:45)
norm_len 15911
S014 quote: literal 0; case-insensitive 1
S025 quote: literal 1; case-insensitive 1
context: "JWT/OIDC auth method The jwt auth method can be used to authenticate
          with OpenBao using OIDC or by providing a JWT . The OIDC method …"
```

The S025 row-identity digest also recomputes: `printf 'S025\tmined\t
https://openbao.org/docs/auth/jwt/\n' | sha256sum` =
`e91b8e3c1bd4b981e82d0f76c7362c4bc3622165355800972da569f6496d8481`, equal to
TSV column 3.

So the S014 quote is provably non-literal (0/1) and truncated, and the recorded
S014 digest `e9472324…` matches neither the current raw body (`449ef132…`) nor
its declared normalized text (`ca496ad8…`). This matches the round-23 lesson's
own statement (`corpus/lessons/round-23.md:108-116`) and the round-22 record; it
is not a new contradiction.

## 4. Verdict on the legacy bound: CONFIRMED honest for S014

`SC_FETCH` does not compare S014's in-row digest or quote to the S025 capture,
and it says so in three independent places:

- `corpus/source-fetches.tsv:34-36` — legacy in-row digests are historical point
  observations with undocumented representation, "required for coverage but not
  compared to these captures".
- `corpus/sources-census.sh:67-69` — same stated bound in the gate header.
- `corpus/lessons/round-23.md:108-116` — the old rows keep their historical
  values; S025/S026 are the corrected active locators.

The non-comparison is implemented exactly that way (`sources-census.sh:294-300`).
The gate therefore does not launder S014's unreproducible digest as a verified
capture, and it does not rewrite the historical row. The correction is carried
by S025, whose declared representation, digest, byte count, normalized digest and
quote I reproduced exactly. For S014 specifically, the bound is honest.

One transparency caveat, not dishonesty: the gate's CLEAN line
(`sources-census.sh:333-334`) reports `rows=26 … mined=24 … legacy=21`, where
`legacy=21` counts knowledge entries without a `source:` line
(`sources-census.sh:80-81`), not legacy in-row pins. The real 16 legacy-pin /
10 capture split appears in `corpus/lessons/round-23.md:61` and is derivable
from the 10 TSV rows plus the 16 in-row pins. A verdict that cites the CLEAN
line alone must not convert it into "all 24 mined rows have declared
representation".

## 5. Concrete defect — the legacy branch is not covered by the 59-case selftest

**F1 (medium-low; test adequacy).** The only mechanism that admits S014 (and 15
other rows) is unexercised by the selftest that the round presents as its
evidence.

Observed on the final snapshot `24d834cc`:

- `awk '/^base_fixture\(\)/,/^rep\(\)/' corpus/sources-census.sh | grep -c 'Fetch sha256'`
  → `0`. The fixture registry rows (`sources-census.sh:355-358`) carry no in-row
  pin; every fixture row has a complete TSV row.
- All 59 case names (`sources-census.sh:510-570`) contain no `inrow` case; the
  only "legacy" case is `legacy-not-scanned` (`:513`), which is about knowledge
  entries, not pins.
- The malformed-pin finding at `sources-census.sh:296`
  (`inrow-digest-malformed`) has no case that kills it.
- Consequence: deleting the `if [[ -n ${FINROW[$fid]} ]]` block, or removing the
  64-hex check at `:296`, leaves all 59 cases green by construction — the fixture
  rows all have captures, and `fetch-missing` removes a row that has no in-row
  digest in the first place. The 59-case PASS exercises only the capture half of
  `SC_FETCH`.
- Therefore `corpus/lessons/round-23.md:61` ("selftest 59 cases") is true as a
  count but does not validate the half of the contract that covers 16/26 rows,
  including S014. The real-tree run does exercise the branch (this audit's
  `--root .` run is CLEAN), so this is a coverage gap in the test evidence, not a
  false CLEAN.

Minimal cases that would close it (for the gate owner, not applied here):
a mined fixture row with a valid 64-hex in-row pin and no TSV row → CLEAN; the
same with a 63-hex pin → `SC_FETCH id=… inrow-digest-malformed`; optionally an
in-row pin plus a disagreeing capture → CLEAN, labelled as the stated
non-comparison bound.

## 6. Transient defects observed while the tree was moving

These were present in the initial snapshot and are recorded for provenance; the
final snapshot has corrected the first two.

- **O1 (was false, now corrected in the lane).** Initial lesson `d5520988` said
  `source-fetches.tsv` "carries 10 declared provenance rows (S017-S026) over
  seven distinct URLs". The TSV has 10 rows over **nine** distinct exact URLs
  at both snapshots (`awk -F'\t' '$0 !~ /^#/ && NF==16 {print $4}' … | sort -u |
  wc -l` → 9); the registry has 19 distinct URLs. The corrected lesson
  (`993e114a`, carried unchanged into `cf79cd0c`) line 174 correctly says
  "nine". The falsification dispatch context
  (`.ufo/waves/round-23/falsify-spec.json:3`) still says "over 7 URLs"; that
  premise is stale and should not be repeated in the round verdict.
- **O2 (dead code, now removed).** Initial census `80966e20` built a
  `SUPERSEDED[]` array from rows whose `teaches` starts `supersedes S…`
  (S025→S014 among them) at line 242, but never read it. Final census `24d834cc`
  has no `SUPERSEDED` (`grep` exit 1). Supersession remains prose-only, as
  `corpus/lessons/round-23.md:146` (M23-2; was line 142 before the 04:08:16Z
  edit) already records; the S014→S025 edge has no machine effect in either
  snapshot.

## 7. Limits

- `e9472324…`'s 2026-10-19 representation remains unrecoverable from the repo;
  I tested only the current raw body and the declared `rendered-text-v1` text
  (neither matches), not the parent's full seven-representation table.
- No Wayback/archive query, no OpenBao or Vault deployment, no account/vault
  path, no host/loopback/node/CDP probe.
- I did not run `corpus/claim-ledger.sh verify/docs/cells`, `scope-gate`, or any
  host-bound row. Only the host-free census and its selftest were executed.
- Census/selftest exit 0 and PASS were observed on both snapshots; if the tree
  moves again, the hashes above are the measured bytes.
- No tools installed; nothing to record under the tooling directive.

## 8. Exact command/exit log (summary)

```
sha256sum corpus/{SOURCES.md,source-fetches.tsv,sources-census.sh,lessons/round-23.md}  # exit 0
bash corpus/sources-census.sh --root .                    # exit 0
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
bash corpus/sources-census.sh --selftest                  # exit 0
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
curl … https://openbao.org/docs/auth/jwt/                 # exit 0, http=200
sha256sum /tmp/s014-jwt.html                              # 449ef132…785d9
wc -c < /tmp/s014-jwt.html                                # 63046
python3 normalized recompute                              # ca496ad8…a403, 15911 chars
S014 quote literal/ci                                     # 0 / 1
S025 quote literal/ci                                     # 1 / 1
printf 'S025\tmined\thttps://openbao.org/docs/auth/jwt/\n' | sha256sum
                                                          # e91b8e3c…8481 = TSV:45
awk TSV unique URLs                                       # 10 rows / 9 URLs
awk registry unique URLs                                  # 26 rows / 19 URLs
awk fixture 'Fetch sha256' count                          # 0
CASES count                                               # 59; no inrow case
git show d218603…:corpus/SOURCES.md | sed -n '20p' | sha256sum
                                                          # 48a401de… = working tree line 20
git diff d218603… -- corpus/SOURCES.md | grep '^[-+]\| S014'   # no output, exit 1
grep -c 'Fetch sha256:' corpus/SOURCES.md                 # 16 (base also 16)
```

**Bottom line.** S014's legacy handling is honest as bounded: the capture for its
URL is accurate and current, the old row is unchanged and explicitly historical,
and the gate does not pretend to compare them. The live defect is evidentiary:
the 59-case selftest never exercises the in-row branch that admits S014, so its
green result cannot validate that half of `SC_FETCH`. The "7 URLs" premise in the
dispatch is stale; the lane's lesson now says nine and the TSV measures nine.
