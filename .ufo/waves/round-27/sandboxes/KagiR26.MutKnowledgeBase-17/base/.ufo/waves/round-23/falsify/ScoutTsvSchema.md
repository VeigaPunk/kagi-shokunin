# ScoutTsvSchema — round-23 falsification: `source-fetches.tsv` schema vs `SC_FETCH` field order

Seat: `KagiR23.ScoutTsvSchema` (leaf; no dispatch). Measured 2026-10-21T04:00Z–04:22Z against
base `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree at
`/home/vgpnk/Projects/shokunin/kagi-shokunin`. Read-only on the lane; the only lane write is
this file. No installs, no host gates, no claim-ledger rows executed.

LSP note: this session has no `lsp` device mounted (the tool inventory exposes no LSP route),
and the artifacts under test are a TSV and a bash script. All tracing is exact-text reading of
the only two definition sites (`corpus/source-fetches.tsv` header; `corpus/sources-census.sh`
`SC_FETCH`) plus executed shell commands. No text-grep result is presented as semantic proof;
the executed checks are the proof.

## 1. Verdict at the final pin

| assigned question | result |
|---|---|
| every row exactly 16 tab-separated fields per the header contract | **PASS** — 10/10 rows, `NF==16`, 15 tabs each |
| `SC_FETCH` reads the same field order | **PASS** — 16 variables in exact header order (`sources-census.sh:245`) |
| row/column drift | **none** — all 10 `row_identity_sha256` recompute, status/URL match the registry |
| quoting risk: tabs in cells | none present; no empty cells, CR, BOM, or boundary whitespace; one structural hazard remains (F-7) |
| header comment matches the parser | **YES at the final pin**; **NO between 01:04:32 and 01:10:59**, closed by deleting the checks (F-2) |
| C2 "10 captures S017–S026 over 7 URLs" | **9 distinct URL strings at every pin**; shipped lesson/LOG were corrected to nine during the audit (F-4) |
| gate / selftest at the final pin | `SOURCES_CENSUS: CLEAN …` exit 0; `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` exit 0 |

The target was genuinely in flight: the TSV was rewritten five times and the census four
times during the measurement window, and two of the assigned claims were false for part of
that window. The sections below separate the final-state result from the chronology, because
a frozen-state audit would have reached a different verdict than the current bytes.

## 2. Pins and chronology

Final pin (all §1/§3/§4 results):

| artifact | sha256 | mtime (-0300) |
|---|---|---|
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | 01:10:37 |
| `corpus/sources-census.sh` | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` | 01:16:11 |
| `corpus/SOURCES.md` (registry) | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | 00:49:17 |
| `corpus/lessons/round-23.md` (claim text) | `93df7d345554b99c1daf87fb75234ba273cff0d2fc8be691a4d5df56f0242cb4` | 01:14:03 |

Observed snapshots and what each one changed:

| time (-0300) | artifact | hash | observed state |
|---|---|---|---|
| 00:55:22 | TSV | `ccc9ae6e…` | 10 rows / 9 URLs; header said raw agreement applies only to non-volatile |
| 00:57:55 | census | `80966e20…` | live verify crashed, exit 1 (`line 242: S007: unbound variable`), no verdict |
| 01:02:21 | census | `24d834cc…` | crash block deleted; verify CLEAN exit 0; same-URL equality checks present |
| 01:04:32 | TSV | `a78fde7b…` | header rewritten to "No cross-capture equality is enforced" (false vs code then) |
| 01:06:58 | TSV | `846b2037…` | header edits |
| 01:08:48 | census | `6d4190a7…` | doc block rewritten to "no cross-capture equality", contradicting its own code |
| 01:09:29 | TSV | `7101bdd0…` | header edits |
| 01:10:37 | TSV | `6e26e140…` | **final TSV pin** |
| 01:10:59 | census | `511deb27…` | same-URL checks deleted, `fetch-disagree` expectation 2→1 |
| 01:11:27 | lesson | `49632920…` | C2 row drops the same-URL claim; source accounting changed "seven"→"nine" |
| 01:14:03 | lesson | `93df7d34…` | nine distinct URLs at `:175`, `SCORECARD.md:840` reworded to nine |
| 01:16:11 | census | `2d1bbbe3…` | **final census pin**; dead `FDIG`/`FNRM` declarations removed, `seen_key` still declared |

Each result in §1/§3/§4 was re-run against the final artifacts. Field counts, identities,
quote bounds and locations were re-measured on `6e26e140…`; the gate and selftest were
re-run on `2d1bbbe3…`/`6e26e140…` (CLEAN, exit 0; PASS 59, exit 0). The SC_FETCH field
order, every check and the doc text are identical at all line anchors cited here between
`511deb27…` and `2d1bbbe3…`; the only measured change at 01:16:11 was the removal of the dead
`FDIG`/`FNRM` declarations (`seen_key` remains declared).

## 3. Field mapping and checks at the final pin

`corpus/source-fetches.tsv:4` declares "16 tab-separated columns, no tabs inside a cell",
naming the columns at lines 5-30. `corpus/sources-census.sh:245` reads exactly those 16, in
that order:

| # | header name (TSV lines 5-30) | parser var (`:245`) | contract check (final census line) |
|---|---|---|---|
| 1 | id | `fid` | registry membership (`:248`) |
| 2 | status | `fstatus` | exact registry status (`:249`) |
| 3 | row_identity_sha256 | `frow` | sha256 of `id\tstatus\turl\n` (`:251-252`) |
| 4 | url | `furl` | exact registered URL string (`:250`) |
| 5 | final_url | `ffinal` | `^https?://[^[:space:]]+$` (`:253`) |
| 6 | http_status | `fhttp` | `^[0-9]{3}$` (`:254`) |
| 7 | request_profile | `fprof` | `curl-fsSL-compressed-v1` (`:255`) |
| 8 | fetched | `ffet` | `YYYY-MM-DD` (`:256`) |
| 9 | representation | `frep` | `decoded-http-body-v1` or `-volatile-v1` (`:257`) |
| 10 | sha256 | `fsha` | 64 lower-hex (`:258`) |
| 11 | bytes | `fbytes` | `^[1-9][0-9]*$` (`:259`) |
| 12 | revision | `frev` | `-` or 40-hex; 40-hex forced for `*/main*`/raw URLs (`:261-265`) |
| 13 | quote | `fquote` | non-empty, `wc -w <= 25` (`:266-267`) |
| 14 | normalization | `fnorm` | `rendered-text-v1` or `raw-literal-v1` (`:268`) |
| 15 | normalized_sha256 | `fnsha` | 64-hex for rendered-text-v1, else `-` (`:269-273`) |
| 16 | location | `floc` | length >= 8 (`:274`) |

Structural gate: `sources-census.sh:243` rejects any non-comment row whose `NF!=16`; the data
loop at `:276` re-filters with `NF==16`. There is no column-order drift and no skipped or
duplicated field.

## 4. Measurements and exact exits (final pin)

```
# field count, empties, whitespace/control/CR
$ awk -F'\t' 'length($0)>0&&$0!~/^#/{print NF}' corpus/source-fetches.tsv | sort -u
16
$ awk -F'\t' '$0!~/^#/{for(i=1;i<=NF;i++)if($i=="")c++}END{print c+0}' corpus/source-fetches.tsv
0
$ awk -F'\t' '$0!~/^#/{for(i=1;i<=NF;i++)if($i~/^[[:space:]]|[[:space:]]$/)c++}END{print c+0}' corpus/source-fetches.tsv
0
$ awk -F'\t' '$0!~/^#/{for(i=1;i<=NF;i++)if($i~/[[:cntrl:]]/)c++}END{print c+0}' corpus/source-fetches.tsv
0
$ tr -dc '\r' < corpus/source-fetches.tsv | wc -c
0
$ awk -F'\t' '$0!~/^#/{print gsub(/\t/,"\t")}' corpus/source-fetches.tsv | sort -u
15
$ file corpus/source-fetches.tsv
UTF-8 text; first bytes 23 20 73 6f ("# so"): no BOM

# identity and registry binding (TSV cells and the registry the parser actually uses)
S017..S026  identity=OK  registry status=SAME  registry url=SAME        # exit 0

# gate and selftest
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
                                                                        # exit 0
$ bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (59 cases)                                # exit 0
$ bash -n corpus/sources-census.sh                                      # exit 0
$ <CASES array count> ; <fetch case count>
59 ; 12
```

Per-row result (all rows: `status=mined`, `representation=decoded-http-body-volatile-v1`,
`normalization=rendered-text-v1`, `revision=-`, `fetched=2026-10-21`, `http_status=200`,
`request_profile=curl-fsSL-compressed-v1`):

| id | url (short) | identity | quote words (`wc -w`) | location len |
|---|---|---|---|---|
| S017 | 1password.dev/.../github-actions/ | OK | 14 | 13 |
| S018 | 1password.dev/.../custom-workflow/ | OK | 14 | 13 |
| S019 | 1password.dev/brokered-access | OK | 12 | 12 |
| S020 | 1password.com/blog/...public-preview | OK | 19 | 19 |
| S021 | openbao.org/docs/concepts/tokens/ | OK | 20 | 18 |
| S022 | developer.hashicorp.com/vault/docs/auth/jwt | OK | 21 | 29 |
| S023 | developer.hashicorp.com/vault/docs/concepts/lease | OK | 11 | 24 |
| S024 | developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 | OK | 12 | 56 |
| S025 | openbao.org/docs/auth/jwt/ | OK | 18 | 23 |
| S026 | openbao.org/docs/concepts/tokens/ (dup of S021) | OK | 22 | 35 |

Distinct URL strings: **9**. Only `https://openbao.org/docs/concepts/tokens/` repeats
(`S021`, `S026`). Registry duplicate groups touching these rows: tokens `S016,S021,S026`;
brokered-access `S007,S019`; openbao jwt `S014,S025`; lease `S013,S023`; hashicorp jwt
`S012,S022`; blog `S006,S020`.

## 5. Findings

**F-1 (schema and field order) — PASS, high confidence.**
Ten rows, sixteen fields each, exact header order, exact 16-variable `read` order, every
identity digest recomputes, every enum/regex/quote/location bound passes, no drift across the
five TSV snapshots.

**F-2 (header vs parser, mid-audit) — resolved against the header, medium severity, high confidence.**
From 01:04:32 to 01:10:59 the TSV header line 21 said "**No cross-capture equality is
enforced**", while the census at `24d834cc…`/`6d4190a7…` enforced two:
`:279-284` raw `sha256` equality for non-volatile representations and `:285-289`
`normalized_sha256` equality for every `rendered-text-v1` row. All ten live rows are
volatile + rendered-text-v1, and `S021`/`S026` share a URL, so the normalized equality was
live on that pair (both `ed949658…`). The 00:55:22 and 01:04:32 header wording ("Same-URL raw
agreement applies only to non-volatile representations") was accurate; the 01:09:29 rewrite
made it absolute. At 01:10:59 the census deleted the same-URL checks (`:275` is now
`duplicate-provenance`; the dead `FDIG`/`FNRM` declarations were removed at 01:16:11), so at
the final pin line 21 is true. The check was closed by removing enforcement, not by
correcting the sentence.

**F-3 (census doc block, mid-audit) — same closure, medium severity, high confidence.**
At `6d4190a7…` `corpus/sources-census.sh:64-66` said "no cross-capture equality is enforced,
only one provenance row per id", directly contradicting the inline comment at `:275-278` and
the checks at `:279-289` in the same file. At `511deb27…` the doc block is true because the
checks are gone. `corpus/claim-ledger.tsv` R21-03 now records the absence explicitly ("no
cross-capture agreement case: captures are point attestations"), and the lesson C2 row at
`corpus/lessons/round-23.md:61` no longer claims same-URL agreement.

**F-4 (C2 URL count) — measured 9 at every pin; shipped text corrected during the audit.**
The file always held 10 rows over **9 distinct URL strings** (`S021` = `S026`). The dispatch
claim and the earlier shipped text said seven: `LOG.md:1202` and
`corpus/lessons/round-23.md:164-165` at the 01:0x snapshots, plus `SCORECARD.md:840`'s
"seven distinct URLs". Seven matched only the pre-correction subset `S017`–`S023`;
`plans/round-23.md:20` still mixed "seven mined rows" with `:22` "ten registry rows". At the
final pin the lesson says "over nine distinct URLs" (`corpus/lessons/round-23.md:175`),
`LOG.md:1202` says "10 declared captures over 9 distinct URLs", and `SCORECARD.md:840` was
reworded to "the 10 captures cover nine distinct URLs". The C2 context text in the
round-23 falsify spec is now stale relative to the artifacts.

**F-5 (gate crash at the earlier pin; self-healed) — reproduced, informational.**
At `sources-census.sh` `80966e20…` (00:57:55) `bash corpus/sources-census.sh` exited 1 with
`corpus/sources-census.sh: line 242: S007: unbound variable` and no verdict line. Root cause:
`SUPERSEDED` was missing from `declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()`, so
`SUPERSEDED[S007]=1` was parsed as an indexed-array assignment whose subscript was
arithmetically evaluated under `set -u`. Minimal repro:
`bash -uc 'fid=S007; SUPERSEDED[$fid]=1'` → rc 127, `S007: unbound variable`;
`bash -uc 'declare -A SUPERSEDED=(); fid=S007; SUPERSEDED[$fid]=1'` → rc 0. A stream-patched
control copy (declaration restored; no file written) produced the exact CLEAN line with
rc 0, proving the TSV/`SC_FETCH` logic was not the cause. At `24d834cc…` the unused block was
deleted and the gate exits 0. Sibling `MutFetchRemove.md` owns the crash analysis; this seat
independently reproduced it at the same hash and records the resolution. The 59-case selftest
passed at every pin because no fixture row carries a `supersedes S###` teach cell.

**F-6 (residual selftest blind spots) — coverage gap, medium severity, high confidence.**
59 cases total (`sources-census.sh:494`), 12 `fetch-*`, all PASS. With the same-URL checks
deleted, the remaining gaps are:
- No case mutates field count or column order. The fetch mutations edit fields
  2,3,4,10,13,14,15,16 (`:410-425`) or append rows; `m_fetch_location` (`:417`) empties the
  last cell only. The `NF!=16` guard at `:243` has no test.
- No fixture row uses `decoded-http-body-volatile-v1`: the base fixture (`:376-380`) is all
  `decoded-http-body-v1`, while all 10 live rows are volatile. The volatile representation is
  accepted by shape only and never exercised end-to-end.
- `fetch-disagree` (`:426-430`) now expects one finding (`:553`), because it only appends a
  duplicate `S002` row with a different raw digest and only `duplicate-provenance` fires. The
  case name still promises a disagreement check that no longer exists.
- No fixture contains `supersedes S###`, which is why F-5's crash was invisible to the gate's
  own selftest.
- The fixture gives every one of its four registry rows a provenance row, so the non-mined
  branch of `missing-provenance` (`:283`) is not separately targeted; only `m_fetch_missing`
  removes a `mined` row's provenance.

**F-7 (adjacent-tab empty cell) — residual quoting hazard, low severity, high confidence.**
`while IFS=$'\t' read -r ...` (`:245`) treats tab as IFS whitespace, so consecutive tabs
collapse: `printf 'a\t\tb\n' | { IFS=$'\t' read -r x y z; ...; }` yields `x=a y=b z=` (the
empty middle field disappears and later fields shift left). `awk -F'\t'` still reports
`NF=16` for such a row, so the `NF!=16` gate does not fire. On the current data the hazard is
not live: zero empty cells, and a shifted row ends with an empty `location`, which fails
`:274`. But the diagnostic would be `location`, not field drift, and no selftest covers this
path. "No tabs inside a cell" holds here only because `NF==16` plus zero empty cells makes a
compensating empty cell impossible.

**F-8 (dead declarations) — resolved except one, low severity.**
At `511deb27…` `sources-census.sh:228-229` declared `seen_key`, `FDIG=()` and `FNRM=()` after
the same-URL checks were removed. At the final `2d1bbbe3…` pin `FDIG`/`FNRM` are gone; only
`seen_key` remains in the `local` list at `:228`, assigned and read nowhere. Harmless under
`set -u`, but it still names a value the gate no longer computes.

## 6. Not checked / remaining unknowns

- Quote *content* against the live pages was not re-fetched: this slice tests the schema and
  the parser contract, not the truth of each located quote. The gate itself only enforces
  presence, word bound, and location length (`:266-274`), so "located quote" and
  "section/heading" remain author attestations, not machine-checked facts.
- Whether the final pins survive after this report: the tree moved five TSV and five census
  times in ~21 minutes, including during drafting. §2 pins the exact bytes measured; if the
  owner edits again, F-2/F-3/F-4 describe the trajectory, not necessarily the next snapshot.
- The C1/C3 claims were outside this seat and were not audited; no legacy claim-ledger verify
  and no host-bound row was executed, per the lane contract.
- The registry's `S001`–`S016` in-row pins were not re-verified for digest shape beyond the
  census's `inrow-digest-malformed` check; that belongs to the freshness owner.
