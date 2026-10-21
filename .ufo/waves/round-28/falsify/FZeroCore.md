# FZeroCore — round-28 falsify: `0.0.0` canonical control / zero-core (patch) component

**Verdict: PASS on the carrier (F1, F2); one candidate/rule divergence recorded as F2a.**
Carrier: `corpus/release-clock.py` only, at pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; BASE `3553d499577084a6c98d7078906017840bbf7b28`. Axes: freshness, calibration. No network; no production file written; no lane gate/selftest run in the lane checkout.

## Method (independent of the frozen counters)

Sandbox `…/round-28/sandboxes/FZeroCore/`: own `git archive` exports of cand+BASE (deleted at completion, 213 MB reclaimed); harnesses I wrote — `harness.py` (module probes + `main()` over a mini corpus), `probe2.py` (feed/text parse), `probe3.py` (observe→receipt→evaluate round trip, module's own `request_body` stubbed as in its selftest), `probe4.py` (exhaustive 0..40³ ordering). Receipts in `sandboxes/FZeroCore/receipts/`. Nothing installed (CPython 3.14.8).

## F1 — `0.0.0` canonical control: PASS

- `non_canonical_version("0.0.0")` → `False`: candidate `corpus/release-clock.py:405` exempts exactly the component `"0"` (`part != "0" and (part[0]=="0" or len(part)>18)`), so `0.0.0` is canonical while `0.0.01`, `0.00.0`, `1.2.03`, `3.15.01` are not (`probe2-out.json` `zero_core`).
- Ordering rewrite is order-equivalent to BASE: over all 68,921 canonical triples in 0..40³, candidate `version_order` sort == BASE `numeric_version` sort — `sort_identical: true`, 0 pair mismatches (`probe4-out.json`). Candidate `:409-415` returns `(len(digits), digits)` per component, so `0.0.0` → `((0,''),(0,''),(0,''))`, the zero component length-0 and lowest, exactly BASE's `(0,0,0)`.
- Feed/text paths: `parse_latest_version` → `"0.0.0"` for `<title>v0.0.0</title>` and `Version: 0.0.0`; `v0.0.01` → `ValueError: non-canonical version token: feed has no canonical stable X.Y.Z entry`; `Version: 0.0.01` → `… : text release version` (`probe2-out.json` `zero_core_feed_positions`, `texts`).
- End-to-end `main()` on a mini corpus, `0.0.0` anchor+observation: exit 0, `RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=0 derived=0)` — same as BASE (`harness-out.json` `zero_canonical_000`). `version_is_named` still binds `0.0.0` in a feed anchor cell (`vin_0.0.0: true`) and does not confuse `10.0.0` with `0.0.0` (`false`).

## F2 — exact typed category for the zero-core component: PASS at the candidate

Zero-padded **core/patch** component (`1.2.03`, `3.15.01`, `0.0.01`) is typed exactly `NON-CANONICAL`, exit 1, no `Traceback`, no fired verdict written, in all three carriers. Sources `harness-out.json` (`cand_runs`/`base_runs`), `probe3-out.json`:

| carrier | candidate | BASE |
|---|---|---|
| table observation `1.2.03` + mirrored receipt | exit 1 `NON-CANONICAL S001`, `fired=0` | exit 0 `CLEAN … fired=1` (lie fired) |
| table anchor `1.2.03` | exit 1 `NON-CANONICAL S001` | exit 1 `INCONSISTENT S001` |
| derived-row anchor `1.2.03` | exit 1 `NON-CANONICAL S001` only | exit 0 `CLEAN … derived=1` |
| `--observe` feed newest `v1.2.03` | receipt `error="non-canonical version token: feed has no canonical stable X.Y.Z entry"`, `parsed_version=null`, `verdict=null`; re-evaluated → exit 1 `NON-CANONICAL S001` | receipt wrote `verdict:"fired", parsed_version:"1.2.03"` |
| `--observe` row anchor/obs `1.2.03` | receipt `error="non-canonical version token: row anchor or observation; no verdict written"`, `verdict=null` | receipt wrote `verdict:"fired"`/`"not-fired"` |

Candidate code: `:617` computes `non_canonical` from anchor+observation; `:627-631` raises the typed `NON-CANONICAL`; `:679-681` types a receipt whose `error` starts with `NON_CANONICAL_PREFIX` (`:391`) as `NON-CANONICAL`, not a generic `RECEIPT-MISMATCH`. Proof it is the rule's own finding, not receipt noise: the unmirrored run yields `NON-CANONICAL`+`NOT OBSERVED`, the mirrored run yields `NON-CANONICAL` alone. No case printed `Traceback`.

### F2a — candidate/rule divergence (already dispositioned upstream; not re-litigated)

At the candidate a non-canonical feed entry ordering *below* the newest canonical entry is silently ignored: `corpus/release-clock.py:795-797` refuses only when `version_order(token) >= version_order(newest)`. Counterexample (probe4 `zero_core_feed_positions`): Atom feed `v3.15.2` + `v3.15.01` → candidate returns `"3.15.2"`, no typed finding (BASE also returned `"3.15.2"`), so this narrows C1's rule text ("a version token used for … a feed entry must be canonical … otherwise the row or feed gets a typed finding"). The candidate's selftest encodes the narrowing (`:1383-1388`, "older oversize entry was not ignored"). Upstream already accepted this (`corpus/lessons/round-28.md` FALSIFY section: FFeedOlder/FRssZero/FEnv640, "Ignoring lower non-canonical entries was a narrowing, not an allowable limit"); L1 states repair `5e847472` covers total feed rejection. Recorded because it is the one place in my carrier where candidate code and C1 text diverge.

## F3 — BASE comparison and frozen counter

BASE `corpus/release-clock.py:369-380` (`numeric_version`→`int(part)`) and `:760` (`max(stable, key=lambda v: tuple(int(part) …))`) accept zero-padded tokens as release identities: `parse_latest_version` returned `"3.15.01"`, `"0.0.01"`, `"3.15.1"`; the table-lie fixture exited 0 `CLEAN … fired=4` (`build/XC1Measure-base-c1.json`, F1 `MISHANDLED`). The candidate refuses all with the typed category. My independent re-run of the lane's frozen counter: `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… FZeroCore-cand …` → exit 0, `mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` (`receipts/c1-cand.json`).

## Commands (exit codes as observed)

- `git -C <lane> archive 62a33b1 | tar -x -C …/sandboxes/FZeroCore/cand` → 0; `3553d49` → `base` → 0; both trees deleted at completion.
- `python3 -I -B corpus/release-clock.py --selftest` (cand) → 0, `PASS (106 cases)`; BASE → 0, `PASS (79 cases)`.
- `python3 -I -B corpus/release-clock.py` (cand) → 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`; BASE → 0, identical.
- `harness.py` → 0, `probe2.py` → 0, `probe3.py` → 0, `probe4.py` → 0 (`receipts/*-out.json`).
- `c1-measure.py 62a33b1… FZeroCore-cand …` → 0.

## Not checked

Live network `--observe` on the five real feeds (observe runs used the stubbed transport); C2 beyond the `0.0.0` anchor-cell probes (`derived_0.0.0`: `0.0.0` binds, `0.0.1`/`0.0.01` do not — `probe2-out.json`); repair `5e847472` and the 106→114 selftest growth (not re-run, per L1); non-canonical tokens of 19–4300 digits (only the 4301-digit fixture; the 18-digit bound is declared lane policy in `corpus/lessons/round-28.md`); no `lsp` server was available, so call-site evidence is code-read + `grep` on the exported tree, not server-resolved.
