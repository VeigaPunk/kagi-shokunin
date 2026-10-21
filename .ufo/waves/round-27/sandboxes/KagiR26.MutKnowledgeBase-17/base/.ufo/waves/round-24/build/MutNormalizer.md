# MutNormalizer — round-24 isolated mutation probe

Axes: **operability** (bounded CLI detectors), **freshness** (one re-fetched round-23 digest), **calibration** (survivors and sampling limits explicit). Advisory evidence only; no round judgment or integration.

## Scope and exact commands

Scratch root `S=/fast/scratch/kagi-r24/seats/MutNormalizer-2`; evidence directory `P=$S/probes`. All `P/...:line` references below expand to that absolute directory. Only this report was written in the lane; no lane source, ledger, state, git/jj mutation, account/handler command, or host-private gate was used. No subagents dispatched.

Setup commands, each exit **0**:
```sh
git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/MutNormalizer-2
git -C /fast/scratch/kagi-r24/seats/MutNormalizer-2 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105
cp /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py /fast/scratch/kagi-r24/seats/MutNormalizer-2/corpus/rendered-text-v1.py
cp /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv /fast/scratch/kagi-r24/seats/MutNormalizer-2/corpus/source-fetches.tsv
```
Target is the copied **working-tree snapshot**, not an assertion that BASE already contains these candidate bytes. Ten independent `probes/M01.py`–`M10.py` copies were made byte-identical to that snapshot, each changed at one behavior-bearing point, then restored exactly.

From `S`, executed `python3 probes/probe.py pristine`, then `python3 probes/probe.py mutated`, then `python3 probes/probe.py restored` (each recorder exit **0**). The recorder is not a verdict gate: actual child exit codes/stdout/stderr are preserved in `P/pristine.json`, `P/mutated.json`, `P/restored.json`.
Each stage ran `/usr/bin/python3 probes/Mnn.py --selftest` and `/usr/bin/python3 probes/Mnn.py digest S024.html` for every copy, plus the three witness assertions below. Detectors use empty scratch HOME, explicit PATH/locale, no bytecode writes, 15-second timeout per child, maximum four workers (`P/probe.py:12-15,31-55,62-68`).

## Selftest results: 7 killed / 3 survived / 0 inconclusive

Every pristine and restored selftest exited **0**, printing `RENDERED_TEXT_V1_SELFTEST: PASS (cases=16)`. Expected mutation detector: selftest exit **1**; survivors below are coverage findings, not revised contracts. `N` below means the copied `corpus/rendered-text-v1.py`; unchanged selftest cases are `N:115-160`.

| ID | Single-point mutation | Mutated selftest / actual failing cases | S024 normalized digest |
|---|---|---|---|
| M01 | `N:62`: replace script/style substitution with `s = text` | **KILLED**, exit 1; failed=3: script-removed, style-removed-case-multiline, script-close-must-match | Changed |
| M02 | `N:63-64`: swap tag removal and html.unescape | **KILLED**, exit 1; failed=1: escaped-tag-survives | Changed |
| M03 | `N:58`: `re.compile(r"\s+", re.A)` | **KILLED**, exit 1; failed=4: nbsp-entity-collapses, nbsp-raw-collapses, ideographic-space-collapses, quote-collapse-only | Changed |
| M04 | `N:66`: `return s` (omit strip) | **KILLED**, exit 1; failed=2: tags-to-space, trim-both-ends | Changed |
| M05 | `N:70`: `errors="replace"` | **KILLED**, exit 1; failed=1: strict-utf8 | Same |
| M06 | `N:57`: tag regex `<[^>]*>` instead of `<[^>]+>` | **SURVIVED**, exit 0; PASS (cases=16) | Same |
| M07 | `N:56`: script/style regex greedy `.*` instead of `.*?` | **SURVIVED**, exit 0; PASS (cases=16) | Changed |
| M08 | `N:56`: remove the opening-element `\b` guard | **SURVIVED**, exit 0; PASS (cases=16) | Same |
| M09 | `N:56`: `(?s)` instead of `(?is)` (case-sensitive) | **KILLED**, exit 1; failed=1: style-removed-case-multiline | Same |
| M10 | `N:74`: quote side returns `normalize_text(q)` | **KILLED**, exit 1; failed=1: quote-collapse-only | Same |

Actual failure examples: M01 `script-removed` got `"x var y=' z '; w"`, want `'x w'`; M02 got `'a c'`, want `'a <b> c'`; M03 raw NBSP got `'a\xa0b'`, want `'a b'`; M04 trim got `' a '`, want `'a'`; M05 printed `case strict-utf8: FAIL (decoded)`; M09 got `'x p{} w'`, want `'x w'`; M10 printed `case quote-collapse-only: FAIL`.
Complete actual outputs: `P/mutated.json:33,59,85,111,137,163,202,241,280,306`.

## Exact additional case that kills each survivor — exercised, not conjectured

| Survivor | Input bytes | Pristine/restored expected output | Mutant actual output | Assertion exits pristine → mutant → restored |
|---|---|---|---|---|
| M06 | `b"a<>b"` | `'a<>b'` | `'a b'` | **0 → 1 → 0** |
| M07 | `b"a<script>1</script>M<script>2</script>b"` | `'a M b'` | `'a b'` | **0 → 1 → 0** |
| M08 | `b"a<scripture>keep</script>b"` | `'a keep b'` | `'a b'` | **0 → 1 → 0** |

These distinguish the already-declared `+` quantifier, shortest match, and opening word boundary (`N:15-18,56-57`); no contract changes. Exact witness argv, including literal `python3 -c` assertion, hex input and expected output: `P/mutated.json:165-176,204-215,243-254`. The identical assertions/inputs ran in all three stages (`P/probe.py:17-27,50-53`); restoration outputs are `P/restored.json:176,215,254`. Production selftest was not extended.

## Fresh page / round-23 pin comparison

Selected S024, one of the ten rendered-text-v1 rows S017–S026 (`S/corpus/source-fetches.tsv:38-47`; selected pin at line 45). Exact fetch from `S`, exit **0**:
```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 --output /fast/scratch/kagi-r24/seats/MutNormalizer-2/S024.html --write-out 'FETCH: http_status=%{http_code} final_url=%{url_effective} bytes=%{size_download}\n'
```
Actual: `FETCH: http_status=200 final_url=https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 bytes=43111` (curl transfer-size field, not decoded body length).
Decoded body: **586181 bytes**, raw SHA-256 `9842a375f0c30115c5b34d1a1c47c6a59a924f58fa2d5221cd74680a28f18b8e`. This differs from the recorded raw point capture, **586146 bytes**, `aaf52ac25695b1bb8ac6cba4f5e67abe27a35700619c9fa88b7bb292571c1008`.
Pristine normalized output **24395 bytes**, SHA-256 **`7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715`**, exactly reproduces S024's round-23 normalized pin. All ten pristine/restored copies reproduce it. Every digest invocation, including mutated ones, exited **0**; mismatches are string comparisons against that pin, not digest-command failures.

| Mutant(s) | Actual S024 normalized SHA-256 | Normalized bytes |
|---|---|---:|
| M01 | `6c0a2dce491ddd4d66e8ca130857d96f6eb0bd80312b2a133428eb8d6ede574d` | 230645 |
| M02 | `c4b74e1b3ee9a26cceab158b59ea915d0cfc55343159f188bb9b2e03ea391557` | 23967 |
| M03 | `463ddab2f9138650caba50b1abf74d36c618c4248496373d4fd96563153e81c4` | 24400 |
| M04 | `6cf9ddbe2c076a2888c1598232e2208d3a574ba2f9520226881c761ba7f04a98` | 24397 |
| M07 | `cbf8e96974b97a5042c876b1ab88dfbbadba2ce0167d4d6e2c15510df3072bc9` | 61 |
| M05, M06, M08, M09, M10 | `7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715` | 24395 |

Evidence: `P/mutated.json:23,49,75,101,127,153,192,231,270,296`.
**At least one of the ten pins changes for M01/M02/M03/M04/M07**, witnessed by S024. In particular, greedy M07 survives all 16 selftests while collapsing this page from 24395 to 61 normalized bytes.
For M06/M08/M09, no change was observed on the requested single-page sample; whether any of the other nine rows changes is **not established**, not “none.” [INFERENCE] M05 cannot alter a successfully strict-UTF-8-decoded page's digest; M10 cannot alter page digests at all because `cmd_digest` never calls `collapse_quote` (`N:69-74,90-97`). No all-ten recapture is claimed.

## Source hashes and exact restoration

Common pristine **and restored** SHA-256 for every copy: **`0bf06adbde3cf6235553d819d6a748c186dc34c918124a221018c27b9e5e78e6`**. `sha256sum` also matched the original lane file and scratch `corpus/rendered-text-v1.py` before probing. Mutation-stage source hashes:

| ID | Mutated SHA-256 |
|---|---|
| M01 | `b5d9f70535bfd957184b9bbb976d0d8df47000738f355617935f61a7581f7453` |
| M02 | `255c401ecffd41a3ef423459bd32ad3f676056470248277d966f060940543c69` |
| M03 | `49e39f7f23f2c3661e474ace97c250f913aca416a54b4ac3f79137e302b76dfe` |
| M04 | `f95bb30e1d0a681dd01ec869c21fd35d401983fb8ed1c5f16801df18fae57246` |
| M05 | `d50ab376cb1f239ef66234c79a9080754fc9b34425ebb6b9f300a8a99d2ff1b9` |
| M06 | `80ffceb41e4dfce4b90bf62ebef5fb1d80cd71e9cb96c44beca2a505c0cd0eb1` |
| M07 | `1805c467fe062a930f3a778fcb60c5f3e42237066af75f3a9c7caa9ac17518f7` |
| M08 | `62dc255e5b64f61605e7ca4a6ccca5eee0a32269e8ffedd359f6253bd1b6026d` |
| M09 | `88b68c0b0c0d55f952b0cb7676a9b6d17340885c9117694a0c5c3c3a2a995332` |
| M10 | `dfb946706c1098e30873413753566f0ac40c2358dd7ea09b0a74624bea8ac345` |

Per-copy hashes in each stage's JSON: lines `12,38,64,90,116,142,181,220,259,285`. All ten exact source restorations were followed by the same passing 16-case detector and original S024 digest; all three additional assertions returned to exit 0. No source mutation remains in these scratch copies. Scratch evidence is retained; lane source was never edited by this seat.
Existing tools: Python **3.14.8**, curl **8.23.0**. **No installs or updates**; no package transactions. Probe complete; no broader gates/build/lint or all-ten fetch performed.
