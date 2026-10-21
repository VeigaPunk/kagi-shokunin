# ScoutSameUrlTokens — same-URL provenance and agreement rule (round-23 falsification)

Scope: the two registry rows sharing `https://openbao.org/docs/concepts/tokens/` (S021, S026)
and the two sharing `https://developer.hashicorp.com/vault/docs/auth/jwt` (S012, S022),
the `SC_FETCH` same-URL code, and the 59-case selftest. Read-only on the lane; no production
edit, no host gate, no credential read, no install. This report is the only lane write;
scratch copies were made under `mktemp -d /tmp/kagi-r23-*` and removed.

**Moving target.** `corpus/sources-census.sh`, `corpus/source-fetches.tsv` and
`corpus/lessons/round-23.md` were edited repeatedly during measurement (00:57–01:09).
Every statement below is pinned to a sha256 + mtime; the final re-measurement was
**2026-10-21 01:09:30 -0300**.

## Answer in one paragraph

S021/S026 are both active (`mined`, tier A) with declared volatile captures whose raw digest,
byte count and normalized digest are identical (`52295218…`, 47384 B, `ed9496…`); today's
served page reproduces both declared digests exactly and both quotes are present. At census
sha `24d834cc…` the agreement rule keyed by URL **catches** an edited normalized digest
(`same-url-normalized-disagreement`, exit 1) and **does not** compare raw digests for volatile
rows (edited raw digest stays CLEAN). S012/S022 are **not** an active/active pair: S012 is a
legacy in-row `Fetch sha256: ec6e7b25…` with no tsv row and is superseded by S022; S022 is the
only active capture (`9a65b9d1…`, 386400 B, `06d2508c…`). The rule never compares legacy pins,
so the unequal legacy/active digests pass by declaration; if a second *active* capture of the
Vault JWT URL is added, a normalized contradiction is caught (mutation E), a volatile raw-only
contradiction is not. The C2 counting command was **broken at the dispatch-time sha**
(`80966e…`: exit 1, `line 242: S007: unbound variable`) and is CLEAN only at `24d834cc…`.

## State timeline (measured, -0300)

| measured | artifact | sha256 | observation |
|---|---|---|---|
| 00:57:55 | `corpus/sources-census.sh` | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` | SC_FETCH same-URL block present; `SUPERSEDED` used at line 242 but absent from the line-229 `declare -A`; real-registry verify **exit 1** |
| 01:00:35 | same | same | reproduced twice: `corpus/sources-census.sh: line 242: S007: unbound variable`, exit 1, no verdict line |
| 01:02:21 | `corpus/sources-census.sh` | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` | `SUPERSEDED` extraction removed; verify CLEAN exit 0; same-URL block still at 275–289; unchanged through 01:07:29 |
| 01:08:48 | `corpus/sources-census.sh` | `6d4190a7302eb001c728860e8825c12f0641dafc5cf242cefcb8a4d282ffa236` | header 64–66 rewritten to "no cross-capture equality is enforced"; same-URL block **still present** at 275–288; verify CLEAN exit 0; A/B re-run identical (A exit 1, B exit 0) |
| 00:55:22→01:07 | `corpus/source-fetches.tsv` | `ccc9ae6e…` → `a78fde7b…` → `846b2037…` | header rewritten twice (01:04:32: "No cross-capture equality is enforced"); only data change is S022 `location` |
| 01:03:36→01:07 | `corpus/lessons/round-23.md` | `88d0c7dc…` → `2f53cf69…` → `993e114a…` | C2 row:61 dropped "same-URL agreement"; lines 53–54 still say "no cross-capture equality is enforced" |
| unchanged | `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` | 26 rows; target rows at 18, 27, 28, 32 |

## Provenance status of the four rows

Registry fields parsed exactly as the gate does (`awk -F'|' … NF==13`, status `$9`, URL from
`$3`). `Fetch sha256:` count in `SOURCES.md` = **16** (`grep -c`, exit 0); tsv data rows = **10**
(`grep -c '^S0' corpus/source-fetches.tsv`, exit 0).

| id | SOURCES.md | tier/status | provenance | representation | raw sha256 | bytes | normalized sha256 | used-by citation |
|---|---|---|---|---|---|---|---|---|
| S012 | line 18 | A / mined | legacy in-row `Fetch sha256: ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45`; **0** tsv rows | undocumented (legacy) | `ec6e7b25…` | — | — | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:3` |
| S021 | line 27 | A / mined | tsv line 42 | `decoded-http-body-volatile-v1` | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` | 47384 | `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` | `corpus/lessons/round-22.md:1`, `corpus/knowledge/feature-bound-credential-review.md:1` |
| S022 | line 28 | A / mined | tsv line 43 | `decoded-http-body-volatile-v1` | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` | 386400 | `06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431` | `corpus/lessons/round-22-source-errata.md:1` |
| S026 | line 32 | A / mined | tsv line 47 | `decoded-http-body-volatile-v1` | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` | 47384 | `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` | `corpus/lessons/round-23.md:1` |

- Supersession: S022 teaches "supersedes S012" (`SOURCES.md:28`); S026 "supersedes S016"
  (`SOURCES.md:32`). S021 and S026 are both active, same URL, distinct quotes and locations.
- S021/S026 are the **only** duplicate URL group in the tsv: 10 rows over **9** distinct URL
  strings (the dispatch summary's "7 URLs" is not what the artifact contains). Their identical
  raw digest, byte count and normalized digest mean one captured body recorded twice, not two
  independent fetches.
- Row identity was independently recomputed with the gate's exact formula
  `printf '%s\t%s\t%s\n' <id> mined <url> | sha256sum`:
  S021 `c921ab09…`, S022 `4e184ddb…`, S026 `0be2cff9…` — all equal tsv column 3. Identity binds
  id/status/URL only; it does not bind the digest.

## The agreement rule (census sha `6d4190a7…`, mtime 01:08:48; identical body at `24d834cc…`)

- `corpus/sources-census.sh:279-282` — raw key `"$furl|$frep"`, compared **only** when
  `frep != decoded-http-body-volatile-v1`; mismatch emits `same-url-digest-disagreement`.
- `corpus/sources-census.sh:285-288` — normalized key `"$furl|norm|$fnorm"`, compared for
  every `rendered-text-v1` row (volatile included); mismatch emits
  `same-url-normalized-disagreement`.
- At `6d4190a7…` the header itself (`corpus/sources-census.sh:64-66`) now says "no
  cross-capture equality is enforced", joining `corpus/source-fetches.tsv:17-21` and
  `corpus/lessons/round-23.md:53-54`; `corpus/lessons/round-23.md:61` (C2) no longer names
  same-URL agreement. **The code at 275-288 enforces exactly what all three prose sites deny.**
  The prose is stale relative to `6d4190a7…`; the current claim is understated, not false, but
  the artifacts contradict themselves and cannot both be accepted.

## Mutation matrix (current script + real corpus copied to `/tmp`)

Setup: `T=$(mktemp -d /tmp/kagi-r23-sameurl2.XXXXXX); cp -a corpus "$T/corpus";
cp corpus/sources-census.sh "$T/census.sh"; cp "$T/corpus/source-fetches.tsv" "$T/pristine.tsv"`.
Baseline: `bash "$T/census.sh" verify --root "$T"` →
`SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, **exit 0**.
Each mutation rewrites the scratch tsv, reruns, then restores pristine. Rows C/D/E were
measured at `24d834cc…`; A and B were re-run against the 01:08:48 `6d4190a7…` script with
identical outputs (A exit 1, B exit 0), and the rule body is textually identical in both.

| # | mutation | result | exit |
|---|---|---|---|
| A | S026 normalized sha → `a`×64 | `FINDING SC_FETCH id=S026 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/`; `FAILED (findings=1 rows=26)` | 1 |
| B | S026 **raw** sha → `b`×64, stays volatile | CLEAN, same verdict line | 0 |
| C | S021 **and** S026 representation → `decoded-http-body-v1`, S026 raw → `b`×64 | `FINDING SC_FETCH id=S026 same-url-digest-disagreement url=…/tokens/` | 1 |
| D | S026 representation → `decoded-http-body-v1` + raw `b`×64, S021 stays volatile | CLEAN (raw keys differ: `url\|volatile` vs `url\|decoded-http-body-v1`) | 0 |
| E | add a second **active** capture of the Vault JWT URL under S012 (volatile, normalized `d`×64; row identity `6f3cadc2…` recomputed) | `FINDING SC_FETCH id=S012 same-url-normalized-disagreement url=https://developer.hashicorp.com/vault/docs/auth/jwt` | 1 |

Commands for A and E (the others are the same `awk -F'\t' -v OFS='\t'` rewrite):

```
awk -F'\t' -v OFS='\t' -v v="$(printf 'a%.0s' {1..64})" '$1=="S026"{$15=v}1' pristine.tsv > corpus/source-fetches.tsv
printf 'S012\tmined\t%s\thttps://developer.hashicorp.com/vault/docs/auth/jwt\thttps://developer.hashicorp.com/vault/docs/auth/jwt\t200\tcurl-fsSL-compressed-v1\t2026-10-21\tdecoded-http-body-volatile-v1\t%s\t100\t-\texact role audience match\trendered-text-v1\t%s\tJWT verification\n' "$ID" "$(printf 'c%.0s' {1..64})" "$(printf 'd%.0s' {1..64})" >> corpus/source-fetches.tsv
```

So: **A contradictory normalized capture of either shared URL is caught; a raw-only
contradiction under a volatile declaration is not; a mixed-representation pair bypasses the
raw comparison entirely.**

## Live re-fetch (allowed profile, 2026-10-21 ~01:04)

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>
```

| URL | HTTP | decoded bytes | sha256 | declared match | normalized sha256 (rendered-text-v1 reimplementation) | quote present |
|---|---|---|---|---|---|---|
| `https://openbao.org/docs/concepts/tokens/` | 200 | 47384 | `5229521866…` | S021 **and** S026 exact | `ed949658b4…` = declared | S021 and S026 quotes both present |
| `https://developer.hashicorp.com/vault/docs/auth/jwt` | 200 | 386400 | `9a65b9d128…` | S022 exact | `06d2508c95…` = declared | S022 quote present |

S012's legacy `ec6e7b25…` differs from today's raw `9a65b9d1…`; that is expected and is exactly
the case the gate deliberately does not compare (undocumented legacy representation).
Locations: S021's quote falls under "Token Time-To-Live, periodic tokens, and explicit max
TTLs"; S026's under "Token hierarchies and orphan tokens"; S022's only normalized occurrence is
in the pre-heading Vault 1.17 Note, so its mid-window correction to "Introduction, Vault 1.17
Note" (tsv line 43) is accurate. `SC_FETCH` only checks `location` length ≥8; accuracy is not
machine-checked.

## Findings

**F1 (operability, historical at `80966e…`, fixed at `24d834cc…`).** At the sha present when the
falsify wave was dispatched, the C2 counting command failed outright:
`bash corpus/sources-census.sh` → `corpus/sources-census.sh: line 242: S007: unbound variable`,
**exit 1**, no verdict. Cause: line 242 wrote `SUPERSEDED[$fid]`, but `SUPERSEDED` was dropped
from the `declare -A` at line 229; the registry has six rows whose `teaches` begins
`supersedes S…` (`SOURCES.md:25,26,28,29,31,32`), the first extracted key being `S007`, so
`set -u` aborted before any provenance check. The 59-case selftest passes on that same sha
because its fixture has no `supersedes` teaches (`base_fixture` rows S001–S004), so the selftest
cannot see this class of break. The 01:02:21 edit removed the superseded extraction entirely;
`24d834cc…` verifies CLEAN. Any CLEAN claim made during 00:57:55–01:02:21 is stale, and the
claim must pin a post-freeze sha.

**F2 (live doc/code contradiction at 01:09).** `sources-census.sh:275-288` enforces same-URL
equality; `sources-census.sh:64-66` (rewritten at 01:08:48), `source-fetches.tsv:17-21` and
`lessons/round-23.md:53-54` all deny cross-capture equality; `lessons/round-23.md:61` does not
claim it. Acceptance must pin one sha at which code and prose agree — either remove the rule or
restore the declaration and claim.

**F3 (selftest coverage).** The 59 cases contain no `same-url-normalized-disagreement` case and
no distinct-id same-URL pair. The only exercise of the rule is incidental: `fetch-disagree`
duplicates non-volatile S002 and expects 2 findings; the retained fixture verifies as
`same-url-digest-disagreement` + `duplicate-provenance`. "Selftest 59 cases" is true but is not
evidence for the normalized arm or for real-registry reachability (F1); the scratch mutations
above are the evidence.

**F4 (bounds the claim must state).** (i) Raw agreement applies only when both rows declare the
same non-volatile representation; volatile raw digests are unconstrained (B). (ii) Mixed
representations skip raw comparison (D). (iii) Normalized agreement applies only to
`rendered-text-v1`; a volatile + `raw-literal-v1` row would be compared by neither arm (none
exists today). (iv) Legacy in-row digests are never compared (S012/S022 baseline CLEAN with
`ec6e7b25…` vs `9a65b9d1…`). (v) Row identity does not bind the digest, so a lone volatile
capture's raw digest can be rewritten without any finding (B). (vi) Normalized equality is a de
facto drift pin and will fail a legitimate second capture when chrome moves the normalized text
— the lesson's own S017 example (sidebar changed, article did not) — which contradicts "point
attestation, never a content-drift pin".

**F5 (cardinality).** S021/S026 are one body recorded twice (identical digest/bytes), not two
independent captures; the tsv holds 10 rows over 9 distinct URLs, one duplicate group, not
"10 captures over 7 URLs".

**F6 (S022 location).** The `location` cell changed during the window from "JWT verification,
Vault 1.17 note" to "Introduction, Vault 1.17 Note"; the latter matches the fetched page
(quote occurs before the first section heading). Flagged for RevS022, not a SC_FETCH finding.

## Remaining unknowns

- Capture bodies are not retained, so digests/quotes are verified only by live re-fetch; the
  volatile raw digest can change without the article changing. One fetch at 01:04 is reported.
- `corpus/sources-census.sh` may change after the 01:09:30 pin; the same-URL findings were
  reproduced on both `24d834cc…` and `6d4190a7…`.
- S012's legacy representation is undocumented by construction; nothing about it can be
  recomputed or compared.

## Verdict for the claim

At `6d4190a7…` (identically at `24d834cc…`) the two shared-URL pairs are internally consistent
and freshly reproducible, and the implemented rule catches normalized contradictions. The
round-23 artifact as a whole does
**not** currently support a same-URL-agreement claim: the prose denies the rule, the selftest
does not cover it, and during the dispatch window the counting command did not run at all. Accept
C2 only with a frozen sha, the F1 fix present, and either the rule removed or the prose/claim
restored to state the exact keying and volatile/legacy bounds in F4.
