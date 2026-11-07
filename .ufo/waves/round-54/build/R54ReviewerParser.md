# Round 54 — R54ReviewerParser: code review of the release-clock parser change

Scope: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff 1a0f43a9220bb0e995462c2aef745ac0124c3317 ede4373afa07a33e24cbd35e9fd33fc2fddf2f14 -- corpus/release-clock.py`
(one file, 4 textual hunks: receipt digest, receipt path, `FEED_TITLE_PREFIXES`/`prefixed_title_re`/`parse_latest_version`, selftest + help text).
All work below ran in scratch `/fast/scratch/hyaku/kagi-r54/R54ReviewerParser`; the lane was read-only.

Receipts for every command quoted below: `.ufo/waves/round-54/build/R54ReviewerParser-receipts/`
(`selftest-baseline.txt`, `mutants.txt`, `gate.txt`). Scratch root `/fast/scratch/hyaku/kagi-r54/R54ReviewerParser`.

## Verdict per check

| Check | Verdict | One-line evidence |
|---|---|---|
| (a) prefix consulted only in `observe_one`, with the clock row's `feed_url`; `evaluate()` and undeclared feeds unchanged | **PASS** | AST: the only production call site is `observe_one:898` (`argc=2`, prefix `FEED_TITLE_PREFIXES.get(url)` where `url = values["feed_url"]` for `clock=="feed"`); `evaluate()` contains no call to `parse_latest_version`/`observe_one`/`prefixed_title_re`; base vs candidate gate output on the same receipt is byte-identical; 10/10 differential parser probes identical |
| (b) prefixed title regex anchored at both ends and escapes the prefix | **PASS** | `release-clock.py:805-807` → `^` + `re.escape(title_prefix)` + ` v?([0-9]+\.[0-9]+\.[0-9]+)$`; metacharacter probe with prefix `1P.x+` extracts `1P.x+ 1.0.0` and refuses `1PAx+ 2.0.0` |
| (c) the five new selftest cases each fail on a plausible wrong implementation | **FAIL as stated** (test-coverage defect, low severity) | 4 of 5 bite real wrong implementations; case 5 is a map-content guard that no parser implementation can trip, and two implementation-adjacent wrongs (`re.escape` removed, `observe_one` wiring reverted) keep `PASS (121 cases)` |
| (d) default receipt digest / path / help lines match the committed receipt | **PASS** | `sha256(observe-r54.json) = 9513690e…98af` = `DEFAULT_RECEIPT_SHA256` (line 28); path line 547 resolves to the committed file (32 records, 0 errors); help line 2157 names round-54 + the retained older receipts; tampered copy → `RECEIPT-MISMATCH` |
| (e) S052/round-29 canonicality still applies under a declared prefix; `1Password CLI 2.42.01` never observed | **PASS** | `1Password CLI 2.42.01` → `ValueError: non-canonical version token: feed stable entry`; a feed mixing `2.42.0` with `2.42.01` is refused whole, never observed |

## Evidence

### (a) scoping and non-interference
```
AST map of parse_latest_version call sites (candidate):
  898 argc=2 -> observe_one          (production)
  1399 1430 1443 1463 1469 1482 1490 1501 1713 1724  argc=1 -> selftest
evaluate() calls parse_latest_version/observe_one/prefixed_title_re: False
```
`release-clock.py:898`: `parsed_version = parse_latest_version(body, FEED_TITLE_PREFIXES.get(url))`, reached only under `if clock == "feed":`, with `url = values["feed_url"] if clock == "feed" else source["url"]` (line ~880) — i.e. the clock row's declared feed URL, matching the registry row `S072  feed  S112  https://releases.1password.com/developers/cli/index.xml …` in `corpus/release-clocks.tsv`.

Undeclared feeds: `title_re = STABLE_TITLE_RE if title_prefix is None else …` (line 851) — the map miss returns `None`, so the *same compiled object* is used. Differential run of BASE vs CANDIDATE `parse_latest_version` over 10 bodies (Python RSS, "Python install manager 26.4.1", SOPS, age, curl-with-period, `v2.2.0-rc1` Atom, `v2.1.2` Atom, `Version:` text, leading-zero) → **SAME 10/10**; `STABLE_TITLE_RE.pattern` identical.

`evaluate()` unchanged at the observable level:
```
cand: RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)   rc=0
base: RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)   rc=0
SAME=yes        # both with --receipt observe-r54.json --receipt-sha 9513690e…
```
So the 0→2 move comes from the table/receipt, not from gate logic.

### (b) anchoring and escaping
`release-clock.py:805-807`
```python
def prefixed_title_re(title_prefix):
    return re.compile(r"^" + re.escape(title_prefix)
                      + r" v?([0-9]+\.[0-9]+\.[0-9]+)$")
```
Used with `.match()` (line 858), so `^` is redundant but harmless; `$` is authoritative. `$` in Python also matches before one trailing newline, and titles are `.strip()`ed before matching, so no newline can leak a suffix (probed: `" 1Password CLI 2.42.0 "` → `2.42.0`).

### (c) mutant matrix (each mutant is a scratch copy at `$S/<name>/corpus/release-clock.py`, run `--selftest`)

| mutant | selftest | caught by |
|---|---|---|
| baseline candidate | `PASS (121 cases)` rc=0 | — |
| BASE (for the 116→121 delta) | `PASS (116 cases)` rc=0 | — |
| **M2** trailing `$` dropped ("trailing text allowed") | `FAIL version parser declared product prefix: '2.44.0' != '2.42.0'` | case 1 |
| **M1b** `^` dropped **and** `.match`→`.search` (genuinely unanchored) | `FAIL version parser declared prefix is anchored and space-delimited: '5.0.0' != '2.42.0'` | case 2 |
| **M1** `^` dropped under `.match` | `PASS (121 cases)` | — (behaviourally null: `.match` anchors at pos 0, so this is not a wrong implementation) |
| **M3** prefix applied to every feed (`prefixed_title_re(title_prefix or "1Password CLI")`) | `FAIL` case 3 + 7 others | case 3 |
| **M6** prefix ignored, generic `^(?:[A-Za-z0-9]+ )*v?X.Y.Z$` | `FAIL` cases 1, 2, 4 | cases 1/2/4 |
| **M4** `re.escape` removed | `PASS (121 cases)` | — (declared prefix has no metacharacters) |
| **M5** `observe_one` wiring reverted to `parse_latest_version(body)` | `PASS (121 cases)` | — (wiring untested) |

Case 5 (`release-clock.py:1434-1437`, "title prefix declared for an undeclared feed") asserts the *absence* of a sops entry in the map. It is a map-content guard: no parser implementation can trip it, and it cannot fail if `FEED_TITLE_PREFIXES` were emptied or misspelled.

### (d) receipt binding
```
sha256sum .ufo/waves/round-54/final/observe-r54.json
9513690e3b58ad2198038df888ccb12537553d12ba4f141f9a9d8d0121ce98af   = DEFAULT_RECEIPT_SHA256 (line 28)
```
`receipt_path()` line 547 → `.ufo/waves/round-54/final/observe-r54.json` (exists, 32 observations, 0 `error` fields, `format release-clock-observations-v1`).
Gate on a `git archive ede4373a` tree: `RELEASE_CLOCK: CLEAN (… observed=32 fired=14 derived=17)` rc=0.
Tamper control (one byte appended to the receipt, original digest pinned): `RECEIPT-MISMATCH S005…` rc=1 — the digest pin is live, not decorative.
BASE's default (`round-53/final/observe-r53.json`, digest `f927b431…7c9a`, still present) reads 31 observations in the same tree (`NOT OBSERVED S072`, `observed=31`): retained receipts stay citable as the help text claims.
Help line 2157: `default is the round-54 observe-r54 receipt; the round-53, round-46, round-36 and round-26 receipts stay citable with --receipt/--receipt-sha` — matches reality (all four receipt files present).

Live-row consistency (S072): receipt record `parsed_version 2.42.0`, `verdict fired`, `http_status 200`, `sha256 2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2` — identical to `sha256(.ufo/waves/round-54/capture/S112.body)`. Offline replay of that capture through the candidate parser: `parse_latest_version(body, "1Password CLI") -> '2.42.0'`; without the prefix: `ValueError: feed has no stable X.Y.Z release entry`. The receipt is therefore reproducible from the committed capture by the committed code.

### (e) canonicality under a prefix
```
1Password CLI 2.42.0     -> 2.42.0
1Password CLI v2.42.0    -> 2.42.0
1Password CLI 2.42.01    -> ValueError: non-canonical version token: feed stable entry
2.42.0 + 2.42.01 mixed   -> ValueError: non-canonical version token: feed stable entry
1Password CLI 2.44.0.    -> ValueError: feed has no stable X.Y.Z release entry
1Password CLI 2.42.0 beta-> ValueError: feed has no stable X.Y.Z release entry
1Password CLI 2.42.0.1   -> ValueError: feed has no stable X.Y.Z release entry
1Password CLI 2.42.0-rc1 -> ValueError: feed has no stable X.Y.Z release entry
1Password CLI  2.42.0    -> ValueError: feed has no stable X.Y.Z release entry   (two spaces)
```
`newest_stable()` still runs `non_canonical_version` over every extracted token (line 812-814), and `evaluate()` still types a non-canonical receipt as `NON-CANONICAL`. Nothing in the diff relaxes the round-29/S052 judge.

## Findings by severity

**F1 — low/medium, test coverage.** `corpus/release-clock.py:898` (the `FEED_TITLE_PREFIXES.get(url)` wiring) has no selftest case: reverting it to `parse_latest_version(body)` yields `RELEASE_CLOCK_SELFTEST: PASS (121 cases)` (mutant M5). The five `observe_one` calls in the selftest use `example.test` / `feed.example.test` URLs only; the 1Password feed URL appears in the selftest solely as a dict key (line 1414) and in parser bodies. Today the behaviour is correct (verified by reading the call site and by the digest-pinned live receipt), but a regression here would be caught only by a future live `--observe` run, not by the standing selftest.

**F2 — low, test coverage.** `re.escape` (line 806) is unexercised: removing it keeps 121/121 PASS because the only declared prefix (`1Password CLI`) has no regex metacharacters. The code is correct today (probe with prefix `1P.x+`: `1P.x+ 1.0.0` → `1.0.0`, `1PAx+ 2.0.0` → refused); the guard is simply absent for the day a prefix contains `.`/`+`/`(`.

**F3 — low, spec divergence / gate blindness.** The prefixed grammar reintroduces `$`, so `<prefix> 3.15.1.` (and `, out now`, `)`) is *dropped* instead of extracted-then-judged — the round-29/S052 boundary rule says a punctuation-carrying token is extracted and refuses at the judge. The change comment states this is deliberate ("nothing after the version … refuses"), and it is what keeps `2.44.0 beta` and `2.43.0-beta.01` out, so the trade is defensible. The consequence is a silent-staleness class: if 1Password ever publishes the *new* release title with trailing punctuation while older clean titles remain, the clock reads `not-fired` without an error. The new extractor is also invisible to `corpus/feed-token-agree.py`, whose `EXTRACTORS` tuple lists only `STABLE_TITLE_RE`, `STABLE_TAG_HREF_RE`, `TEXT_VERSION_RE` (line 61); that gate prints `FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)` rc=0 on **both** BASE and CANDIDATE, i.e. the round-29 C2 standing agreement check is silent about the fourth grammar by construction. Live risk is currently nil: the committed capture has 27 items, all exactly `1Password CLI X.Y.Z`, none with punctuation or a prerelease suffix.

**F4 — low, maintainability.** `FEED_TITLE_PREFIXES` keys are not cross-checked against the `feed_url` values actually declared in `corpus/release-clocks.tsv`; a URL typo (trailing slash, `www.`) makes the declaration silently inert and the S072 clock would fall back to the one-word rule and error with `feed has no stable X.Y.Z release entry`. The selftest guard on this map (line 1437) only asserts one *absence*, so it cannot catch a typo'd key. The failure is loud at the next `--observe` (observation failure → gate exit 1), so this is a maintainability, not a correctness, gap.

**F5 — informational.** Under a declared prefix the `/releases/tag/` fallback stays product-blind: an item titled `1Password Connect 9.9.9` carrying a `/releases/tag/v9.9.9` link would be accepted as a CLI release. The live feed has 0 `/releases/tag/` links (56 `/developers/cli/` links), so no live impact; the same product-blindness exists for undeclared feeds and is pre-existing.

## Things checked and found sound
- Four-hunk diff only; `newest_stable`, `version_order`, `numeric_version`, `non_canonical_version`, `is_canonical`-family, `receipt_matches`, `evaluate`, `load_receipt_bundle` are untouched (`git diff` shows no hunk inside them), confirmed empirically by the byte-identical gate output base vs candidate on one receipt.
- No second parse path exists that could bypass the prefix: there is no `--capture`/capture-replay mode in the script (`grep` for `args.capture`/`capture_body` → none); `run_observe` only calls `observe_one`. The `S112.body` capture is provenance data, and it reproduces the receipt.
- Feed-entry caps unaffected: the live capture (27 items, 45175 bytes) parses under the unchanged `MAX_FEED_ENTRIES`/`MAX_XML_ELEMENTS` limits.
- No secret material touched: only public release pages/archives are referenced, and no token/vault value appears in any artifact I read or wrote.

## Residual risk and verification gaps
- I did not perform any network observation; the live leg and the op-archive/signature measurement are other seats' items. My live evidence is the committed receipt + capture pair, which I re-derived offline.
- I did not run `plans/round-54-c1.sh` (counter), `claim-ledger.sh verify`, or the controls: out of scope for this seat and forbidden for the full verify.
- Mutants were exercised only through `--selftest`; no mutant was run against the network path.
- Judgement call recorded for main: F1/F2/F3 are coverage/robustness findings, not behavioural defects; the shipped parser is correct on every input I could construct within the contract, and the S072→S112 clock is reproducible from committed artifacts.
