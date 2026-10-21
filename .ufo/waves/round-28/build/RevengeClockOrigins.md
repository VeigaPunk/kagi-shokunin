# RevengeClockOrigins: why BASE release-clock compares fired by string and regression by int tuple

Scope: `corpus/release-clock.py` at BASE `3553d499577084a6c98d7078906017840bbf7b28`. All `:N` are BASE lines.
Verified: lane working-tree `corpus/release-clock.py` sha256 equals the BASE blob (`53823416…a136dc`); `corpus/` is identical between BASE and lane HEAD `b9a42c0` (`git diff --stat` empty). Axes: freshness (a non-canonical token read as a release) and calibration (verdict accepted or refused by spelling).

## Findings

**F0. Origin of the leading-zero "string-unequal → fired" (answer).**
- Table rows: `corpus/release-clock.py:582-584`: `elif verdict == "fired" and norm_version(observed_version) != norm_version(anchored):` then `row_fired = True`. `norm_version` (`:362-363`) strips only a leading `v`, so `3.15.01` and `3.15.1` are string-unequal.
- Observe path: `:798` `norm_version(parsed) == norm_version(anchored)` is false, so `:800-801` writes `"fired"`.
- Why the token gets that far: every version regex accepts leading zeros (`:30-31`, `:366`, `:710-712`). `numeric_version` (`:369-380`) maps `3.15.01` to `(3,15,1)`, so the regression gate (`:567-568`, `:794-796`) and the INCONSISTENT guard (`:576-579`, esp. `:577`) both pass it.

**F1. Calibration: the verdict is decided by spelling, not by state.** Same state (anchor `3.15.1`, feed `3.15.1`). Recorded `fired` with `3.15.01` → CLEAN, counted as a release (CX1). Recorded `not-fired` with `3.15.01` → `INCONSISTENT` at `:585` → `:587-589` (CX1b). The false record passes; the honest one is refused.

**F2. Freshness, observe path: raw token becomes a receipt.** `:710` `STABLE_TITLE_RE` captures `3.15.01`; `:752` takes it; `:760` `max(..., key=int tuple)` returns the raw string; `:798`/`:801` write `fired`. `receipt_matches` (`:441-444`) string-compares again, so the fired receipt is self-consistent with a table row (CX2).

**F3. Freshness: feed verdict depends on item order.** `:760` returns the first maximal element. The docstring at `:718` says "Entry order is not trusted". Two items, `3.15.01` and `3.15.1`: order A → `fired`; order B → `not-fired` (CX3).

**F4. Side origin, oversize.** `:380` `int(part)` runs on any-length digit runs; reached via `:567-568` → `:386`, and via `:760`. Function-level ValueError executed (CX5). The table-path traceback is traced by reading only. The observe-path catch is executed: receipt `error`, `parsed_version` null (`observe_one` try at `:781`).

**F5. Latent, untested.** `git grep` for multi-digit leading-zero tokens in `corpus/SOURCES.md`, `corpus/release-clocks.tsv`, `corpus/source-fetches.tsv` at BASE: no match (exit 1). The BASE selftest (79 cases, PASS) has no leading-zero case: the only line in `release-clock.py` matching `3\.15\.01|zero|leading|0[1-9]\.[0-9]` is `:370` ("optional leading v"). The defect is reachable only via a feed title or a hand-edited table/receipt.

**F6. Dead code, not the origin.** `VERSION_RE` (`:30-31`) has no call site at BASE (definition only). It is not on any decision path.

**F7. Frozen counting set: defects reported, not redefined.**
- Frozen F1 as written (TSV-only) is vacuous at BASE. It ends `RECEIPT-MISMATCH S040`, exit 1 (CX1c), because the pinned receipt check (`:434` verdict, `:444` parsed version; default receipt `:497` `.ufo/waves/round-26/observe-2.json`, sha `:28`) fires before any canonicality logic. The plan's receipt-mirroring correction is required for F1 to reach `:582`.
- Frozen F3 "`--observe` over a local copy" is not executable. `request_body` (`:669-670`) requires `valid_public_https_url` (`:176-212`): https only, `localhost`/`.local` refused, non-global IP literals refused. Only in-process stubbing reaches `observe_one`, as in CX2.
- Frozen F3 with a single item never reaches the order tie at `:760` (F3 above). A two-item case is needed.

## Reconstruction (history)

| When / commit | Change | Evidence |
|---|---|---|
| round 25, `82745e2` | fired `!=` (`:428` in that commit; BASE `:582`), not-fired `==` (`:432`; BASE `:585`), observe verdict `==` (`:611-613`); newest-stable `max` with int-tuple key (`:580`; BASE `:760`) | `git blame -L 582,585` and `760` → `82745e2`; `git show 82745e2:corpus/release-clock.py` |
| round 25 lesson | R25-C7: "newest stable X.Y.Z over every entry wins" (numeric order for newest), `corpus/lessons/round-25.md:59-70`; R25-C8 derived anchors `:71-77`; S012 non-numeric anchor `v1.21.x` fired by inequality `:116-119` | lesson text |
| round 25 rule | QM23: "names one observable release identity", `corpus/QUALITY.md:120` | QUALITY |
| round 27, `144babc` | `NUMERIC_VERSION_RE` `:366`, `numeric_version` `:369-380`, `is_regression` `:383-387`, REGRESSED `:567-575`, observe regression `:794-797`. Docstring `:370-376`: non-numeric, two-component and prerelease residue "alone" keeps the inequality rule. `3fb7727` added the `:577` guard and `:795-796` terms | `git blame` → `144babc`/`3fb7727`; `corpus/lessons/round-27.md:83-90` |
| round 27 lesson | M27-1 `corpus/lessons/round-27.md:104`: "round25 R25-C7/C8 chose `observed != anchor`; QM23 asks for an observable identity, not an ordered one". Named debt `:222-224`: "`3.15.01` is still compared by string for fired/not-fired (inherited)" | lesson |
| QM25 | `corpus/QUALITY.md:132` lists "`observed != anchor` treated as a release" as a failure pattern | QUALITY |
| registry | S042 `corpus/SOURCES.md:49` locates §11.2 only ("always compared numerically"); scope says "strict" X.Y.Z. No BASE row locates SemVer §2 | SOURCES |

Reconstructed intent:
- **Identity for fired.** Round 25 needed a rule that fires non-orderable anchors (S012 `v1.21.x`). [INFERENCE] The code applies it to every pair; there is no branch that restricts it to that residue.
- **Numeric order for regression.** S042 §11.2 plus the round-27 REGRESSED rule, so downgrades are not read as releases.
- **Open question nobody decided.** What fired means when two strict X.Y.Z tokens are numerically equal but differ as strings. "Strict" (`SOURCES.md:49`, `QUALITY.md:132`, `:370`) implies canonical cores; `[0-9]+` does not enforce it. SemVer §2 says cores "MUST NOT contain leading zeroes" (scout capture `.ufo/waves/round-28/sandboxes/SrcSemverSec2/semver.html:445`; §9 at `:486`). [INFERENCE] oversight; round 27 itself calls it "inherited".
- **Separate issue.** S043 zero-padding (`X.Y` = `X.Y.0`) is a different declared limit (`corpus/lessons/round-27.md:26`; `corpus/SOURCES.md:50`).

## Intent vs behavior

| Stated intent | BASE behavior | Divergence |
|---|---|---|
| Fired = observable identity differs (QM23 `QUALITY.md:120`) | string `!=` after v-strip (`:582`, `:798-801`) | Yes for orderable pairs: order says equal, identity says different; never reconciled |
| `observed != anchor` as release is a failure (QM25 `:132`) | fires on `3.15.01` vs `3.15.1` (CX1, CX2) | Yes; round-27 REGRESSED covers only older observations |
| Strict X.Y.Z (`SOURCES.md:49`, `:370`) | `[0-9]+` accepts leading zeros (`:30`, `:366`, `:710-712`) | Yes |
| Inequality only for unordered residue (`:372-375`) | applied to every pair (`:582`, `:585`, `:798`) | Yes |
| Entry order not trusted (`:718`) | first-seen tie-break (`:760`) | Yes (CX3) |
| Leading-zero debt recorded as inherited (round-27 `:222-224`) | unchanged | None; the record says "string compare", not "the comparators disagree" |

## Counterexamples (executed in sandbox BASE copy; no network, no lane writes)

Sandbox: `.ufo/waves/round-28/sandboxes/RevengeClockOrigins-7/` (`base/` = `git archive 3553d…`, sha verified). Probe: `probe_origin.py`, output `probe_origin.out`. Fixtures `f1-fired/` and `f1-notfired/` mirror table `corpus/release-clocks.tsv:30` and receipt `.ufo/waves/round-26/observe-2.json` lines 318 and 321.
- **CX0 control** (BASE, default): `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0. `--selftest`: `RELEASE_CLOCK_SELFTEST: PASS (79 cases)`, exit 0.
- **CX1** `f1-fired`: S040 observed `3.15.01`, verdict `fired`, receipt mirrored (sha `a93cfb98…2465`) → `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 derived=15)`, exit 0.
- **CX1b** `f1-notfired`: same token, `not-fired`, receipt mirrored (sha `1f62f500…61de6`) → `INCONSISTENT S040` / `RELEASE_CLOCK: FAILED (… observed=29 fired=3 …)`, exit 1.
- **CX1c** frozen F1 as written (TSV-only, BASE receipt sha `13b8540c…`) → `RECEIPT-MISMATCH S040` / FAILED, exit 1.
- **CX2** observe, stubbed feed, anchor `3.15.1`: `Python 3.15.1` → not-fired; `Python 3.15.2` → fired; `Python 3.15.01` → parsed `3.15.01`, verdict `fired`.
- **CX3** order: `[3.15.01, 3.15.1]` → `fired`; `[3.15.1, 3.15.01]` → `not-fired`.
- **CX4** helpers: `numeric_version('3.15.01') == numeric_version('3.15.1') == (3,15,1)`; `norm_version` strings unequal; `is_regression('3.15.1','3.15.01') = False`.
- **CX5** oversize: `numeric_version('3.15.' + '1'*4301)` → `ValueError: Exceeds the limit (4300 digits)`. Observe receipt `error` carries the same text.

## Commands and exits

- `git blame -L` on BASE for 340-390, 566-590, 708-762, 780-802 → exit 0.
- `git show 82745e2:…` and `git show 144babc^:…` piped to `grep -n` → exit 0 each.
- `git log -1` for 82745e2, 144babc, 3fb7727 → exit 0 each.
- `git archive 3553d… | tar -x -C …/base` → exit 0; sandbox blob sha = BASE blob sha; `python3 --version` = 3.14.8; `sys.get_int_max_str_digits()` = 4300.
- `python3 -I -B corpus/release-clock.py` (sandbox base) → exit 0 (CX0). `--selftest` → exit 0.
- `grep -n -E "3\.15\.01|0[1-9]\.[0-9]|zero|leading" corpus/release-clock.py` → exit 0; only `:370`.
- `python3 -I -B probe_origin.py <base>` → exit 0.
- `cp -a base f1-fired` and `cp -a base f1-notfired` → exit 0. `edit` on the two copies (TSV `:30`; receipt `:318`, `:321`). `diff` against base → exit 1, differences only where intended.
- `python3 -I -B corpus/release-clock.py --receipt … --receipt-sha …` → CX1 exit 0; CX1b exit 1; CX1c exit 1.
- `git grep -n -E '(^|[^0-9.])0[0-9]+\.[0-9]|\.0[0-9]+' <BASE> -- corpus/SOURCES.md corpus/release-clocks.tsv corpus/source-fetches.tsv` → exit 1 (no match).
- `git grep -n -E 'VERSION_RE\b|def request_body|valid_public_https_url' <BASE> -- corpus/release-clock.py` → exit 0.
- `sha256sum` lane file vs BASE blob → equal. `git status --short -- corpus/release-clock.py` → exit 0, empty. `git diff --stat <BASE> HEAD -- corpus/` → exit 0, empty. Lane vs BASE sha equal for `release-clocks.tsv`, round-25/27 lessons, `QUALITY.md`, `SOURCES.md`.

## Not checked

- No live python.org fetch; `--observe` never run. Observe checks are in-process with `request_body` stubbed.
- Table-path oversize traceback (`:567-568` → `:386` → `:380`) traced by reading only, not executed end-to-end.
- The frozen `c1-measure.py` and `c2-measure.py` were not run; CX fixtures are my own variants.
- SemVer §2 and the PyPA S043 page were not fetched; I used the scout capture and lane lessons.
- Whether any real feed emits a leading-zero title: no evidence either way.
- Leading-zero anchors (`version_is_named` `:341-346`, derived bypass `:566`, `feed_floors` `:390`) not executed.
- The full `--observe` → receipt → CLI chain was not run; equivalence to CX1's receipt shape is by field inspection.
- No lane gate or selftest run in the lane checkout; no commits; no host-private, vault, or CDP reads.

## Advice for C1 (not implemented)

- Canonicalize before both comparators: reject leading-zero components at ingress (`:30`, `:366`, `:710-712`, table and anchor parse), so string identity and numeric identity agree. A non-canonical token is a typed finding, never `fired`.
- `parse_latest_version` (`:760`): refuse non-canonical titles rather than return raw strings; make the tie independent of order (or reject duplicate cores with differing spellings).
- Check length before every `int()` (`:380`, `:760`).
- Add selftest cases for CX1, CX1b, CX2, CX3 and CX5. BASE has none.

## Tools

None installed or updated. Python 3.14.8 (already present) was used as is.
