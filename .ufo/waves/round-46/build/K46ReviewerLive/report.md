# K46ReviewerLive — C2 non-author live re-observation (round 46)

Independent re-observation leg for the C2 freshness counter (sentinel S-10 class): every bound feed clock re-fetched live, parsed by hand, and compared three ways.

## Method

1. `git -C <lane> archive 44808ced56359c98f35995178fb24a6482899263 | tar -x -C $S/tree` (predeclaration tree; lane HEAD == 44808ce).
2. Minimal rebind applied by importing the counter's own fixture op: `plans/round-46-controls.py::c2_rebind(tree, pos_bytes())` — drops clock rows S040/S041, appends the S098 rendered-quote row, writes the positive receipt at `.ufo/waves/round-46/final/observe-r46.json`, syncs tsv observed_version/verdict/observed_at from it, repoints `DEFAULT_RECEIPT_SHA256` (15ae4ead…) and the default receipt path to round-46. Result: 29 clock rows, S040/S041 absent, S098 bound.
3. Live observe run by this seat: `python3 -B corpus/release-clock.py --root "$S/tree" --observe "$S/obs.json"` → **rc=0**; last line `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)`; observe line `RELEASE_CLOCK_OBSERVE: wrote 29 observations (failed=0 fired=13 regressed=0)`.
4. Independent fetch: `curl -sS --max-time 40` on all 14 distinct URLs (5 feed + 9 quote pages; S017/S018 initially 308 → re-fetched with `-L`, same-origin, matching the gate's redirect policy). Hand-parse: own ElementTree/regex extractor for feed stable X.Y.Z maxima; quote locate via the tree's declared `corpus/rendered-text-v1.py` normalizer + `collapse_quote` on my own curl bodies (raw-bytes check for S098's raw-literal-v1 profile).
5. Three-way compare per id: my `obs.json` vs `.ufo/waves/round-46/controls/c2-positive-observe.json` vs my manual parse; plus sha256 of all three bodies.

## Receipts

| step | command | rc | last output line |
|---|---|---|---|
| archive | `git archive 44808ce… \| tar -x -C $S/tree` | 0 | `ARCHIVED` (29-row tsv pre-rebind: 31 lines incl. header) |
| rebind | `python3 -B $S/rebind.py $S/tree` | 0 | `rows: 29 S040/S041 present: False S098 row: […2026-11-06\tquote-located…]` `REBIND-OK` |
| observe | `python3 -B corpus/release-clock.py --root $S/tree --observe $S/obs.json` | 0 | `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` |
| curl feeds | 5 fetches (sops/vault/openbao atom, python rss, curl.info) | 0 | all `200`, e.g. `200 https://github.com/getsops/sops/releases.atom -> sops.atom (253037B)` |
| curl quotes | 9 fetches | 0 | all `200` after `-L` for S017/S018 (initial 308 `Redirecting...` bodies discarded) |

## Comparison table — all 29 ON29 ids

`pv` = parsed_version (feed) / `—` (quote); `v` = verdict. **sha3way** = my obs.json sha256 == pos receipt sha256 == my curl body sha256 (byte-identical content across all three fetches).

| id | clock | feed/source | my observe pv / v | pos receipt pv / v | manual pv / v | agree | sha3way |
|---|---|---|---|---|---|---|---|
| S005 | rendered-quote | 1password.com/product/credential-broker | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S006 | rendered-quote | 1password.com/blog/1password-credential-broker-public-preview | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S007 | rendered-quote | www.1password.dev/brokered-access | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S008 | feed | github.com/getsops/sops/releases.atom | 3.13.3 / not-fired | 3.13.3 / not-fired | 3.13.3 / not-fired | AGREE | yes |
| S009 | feed | github.com/getsops/sops/releases.atom | 3.13.3 / not-fired | 3.13.3 / not-fired | 3.13.3 / not-fired | AGREE | yes |
| S010 | feed | github.com/getsops/sops/releases.atom | 3.13.3 / not-fired | 3.13.3 / not-fired | 3.13.3 / not-fired | AGREE | yes |
| S011 | feed | github.com/getsops/sops/releases.atom | 3.13.3 / not-fired | 3.13.3 / not-fired | 3.13.3 / not-fired | AGREE | yes |
| S012 | feed | github.com/hashicorp/vault/releases.atom | 2.2.1 / fired | 2.2.1 / fired | 2.2.1 / ? | AGREE | yes |
| S013 | feed | github.com/hashicorp/vault/releases.atom | 2.2.1 / fired | 2.2.1 / fired | 2.2.1 / fired | AGREE | yes |
| S014 | feed | github.com/openbao/openbao/releases.atom | 2.7.2 / fired | 2.7.2 / fired | 2.7.2 / fired | AGREE | yes |
| S015 | feed | github.com/openbao/openbao/releases.atom | 2.7.2 / fired | 2.7.2 / fired | 2.7.2 / fired | AGREE | yes |
| S016 | feed | github.com/openbao/openbao/releases.atom | 2.7.2 / fired | 2.7.2 / fired | 2.7.2 / fired | AGREE | yes |
| S017 | rendered-quote | www.1password.dev/brokered-access/github-actions/ | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S018 | rendered-quote | www.1password.dev/brokered-access/custom-workflow/ | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S019 | rendered-quote | www.1password.dev/brokered-access | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S020 | rendered-quote | 1password.com/blog/1password-credential-broker-public-preview | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S021 | feed | github.com/openbao/openbao/releases.atom | 2.7.2 / fired | 2.7.2 / fired | 2.7.2 / fired | AGREE | yes |
| S022 | feed | github.com/hashicorp/vault/releases.atom | 2.2.1 / fired | 2.2.1 / fired | 2.2.1 / fired | AGREE | yes |
| S023 | feed | github.com/hashicorp/vault/releases.atom | 2.2.1 / fired | 2.2.1 / fired | 2.2.1 / fired | AGREE | yes |
| S024 | feed | github.com/hashicorp/vault/releases.atom | 2.2.1 / fired | 2.2.1 / fired | 2.2.1 / fired | AGREE | yes |
| S025 | feed | github.com/openbao/openbao/releases.atom | 2.7.2 / fired | 2.7.2 / fired | 2.7.2 / fired | AGREE | yes |
| S026 | feed | github.com/openbao/openbao/releases.atom | 2.7.2 / fired | 2.7.2 / fired | 2.7.2 / fired | AGREE | yes |
| S027 | feed | www.python.org/downloads/feed.rss | 3.15.2 / fired | 3.15.2 / fired | 3.15.2 / fired | AGREE | yes |
| S028 | feed | www.python.org/downloads/feed.rss | 3.15.2 / fired | 3.15.2 / fired | 3.15.2 / fired | AGREE | yes |
| S029 | feed | curl.se/info | 8.23.0 / not-fired | 8.23.0 / not-fired | 8.23.0 / not-fired | AGREE | yes |
| S030 | rendered-quote | infra.spec.whatwg.org/ | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S031 | rendered-quote | html.spec.whatwg.org/multipage/syntax.html | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S032 | rendered-quote | www.1password.dev/brokered-access | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |
| S098 | rendered-quote | www.unicode.org/reports/tr18/ | — / quote-located | — / quote-located | — / quote-located | AGREE | yes |

## Findings

- **No disagreement on any of the 29 ids.** My live `--observe` (18:53:32–18:53:40Z), the counter's positive receipt (18:45:23–18:45:2xZ), and my independent curl+hand-parse (≈18:55Z) produce identical parsed_version/verdict for every row, and identical body sha256 for every URL — the three fetches saw byte-identical content, so no release or page edit happened in between.
- Feed newest-stable versions (hand-parsed): sops **3.13.3** (entry updated 2026-07-23), vault **2.2.1** (2026-10-23; `v2.2.0-rc1` and `sdk/v0.26.0` correctly excluded as non-stable), openbao **2.7.2** (2026-10-26), python **3.15.2** (pubDate 2026-10-25; backports 3.11.18/3.12.16/3.13.18/3.14.10 correctly below it), curl **8.23.0** (`Version:` line; next release announced 2026-12-09). All newest entries predate all three observation windows.
- Quote ids: all 11 declared capture quotes locate on my independently fetched bodies (10 via rendered-text-v1 normalization, S098 via raw-literal-v1 `<title>` bytes).
- S012 note: anchored_version `v1.21.x` is a non-canonical series anchor, so a naive numeric compare cannot derive its verdict; parsed_version 2.2.1 agrees three ways and `fired` is consistent with 2.2.1 being past the v1.21.x line. Manual verdict column for S012 shows the version; fired-ness asserted by both receipts.
- Gate inside my observe run read CLEAN against my fresh receipt (receipt_matches passed: same observed_at date 2026-11-06 and identical parsed_versions as the synced tsv).

## Verdict

**AGREE on all 29 ids (18 feed rows over 5 feeds, 11 rendered-quote rows).** C2 freshness independently confirmed live this round; the rebind + fresh observe reproduces the counter's positive leg exactly.
