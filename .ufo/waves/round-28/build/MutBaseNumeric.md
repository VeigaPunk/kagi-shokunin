# MutBaseNumeric — BASE numeric/stable-release mutation probe

## Findings first

- **8 of 16 one-line mutants survived** the unchanged selftest; 8 were killed, 0 inconclusive. This is BASE coverage evidence, not a verdict on the round-28 implementation. Axes: **freshness** (reject false release events) and **calibration** (do not equate green selftests with canonical-token coverage).
- At BASE `3553d499577084a6c98d7078906017840bbf7b28`, `corpus/release-clock.py:366,378,380` lacks coverage against Unicode digits, an extra component, prefix-only matching, and silent oversized-component truncation (M01/M03/M04/M10).
- `corpus/release-clock.py:710-712` has asymmetric boundary coverage: widening each feed regex to Unicode digits survives (M11–M13); removing the terminal anchor is detected for XML titles/links but **not** plain-text `Version:` lines (M16). Direct offline observation witnesses actually return `fired` for the surviving feed-regex defects.
- The pristine helper witness also reproduces C1's named defect: `numeric_version("3.15.01")` gives `(3,15,1)` and a `Python 3.15.01` RSS item against anchor `3.15.1` produces `parsed_version="3.15.01", verdict="fired"`, while selftest remains green (`corpus/release-clock.py:380,710,794-801`).

## Detector and isolation

Frozen BASE was exported read-only into `.ufo/waves/round-28/sandboxes/MutBaseNumeric-7/base`; M01–M16 are independent copies of that export. Only each copy's `corpus/release-clock.py` was mutated, at one line. No sibling or production source was edited.

Expected detector: `python3 -I -B corpus/release-clock.py --selftest`, unchanged at BASE, bounded to 45 seconds. A killed mutant requires pristine exit 0, mutant exit 1, restored exit 0, and exact restored bytes. A mutant exit 0 is a survival/coverage finding, not permission to change the contract.

All 16 pristine runs and all 16 restored runs exited **0**, stdout exactly `RELEASE_CLOCK_SELFTEST: PASS (79 cases)`, stderr empty. All mutant stderr was empty; table gives mutant exit and observed summary. Python: **3.14.8**; witness-observed integer conversion limit: **4300** digits. Runs used at most 8 concurrent Python processes and a per-copy `TMPDIR` inside the sandbox.

## Mutant table

Locations below are exact **BASE** `corpus/release-clock.py` lines. Diffs are single-line substitutions; complete patches and complete detector outputs are retained in [mutants.diff](../sandboxes/MutBaseNumeric-7/mutants.diff) and [results.json](../sandboxes/MutBaseNumeric-7/results.json). SHA column is the first 12 hexadecimal digits of the mutated file's SHA-256; JSON retains every full before/mutated/restored hash.

| Mutant | BASE line | Diff | Selftest exit / summary | Verdict | Mutated SHA prefix |
|---|---:|---|---|---|---|
| M01 | 366 | Numeric regex: every `[0-9]+` → `\d+` | 0 / PASS (79 cases) | survived | `7cdd1ce44df8` |
| M02 | 366 | Make patch component optional | 1 / FAIL non-strict observation refused | killed | `15151af3ffb3` |
| M03 | 366 | Append optional fourth component `(?:\.[0-9]+)?` | 0 / PASS (79 cases) | survived | `92846b144e47` |
| M04 | 378 | `NUMERIC_VERSION_RE.fullmatch(value)` → `.match(value)` | 0 / PASS (79 cases) | survived | `0abfd27df8ab` |
| M05 | 380 | `int(part)` → `str(part)` | 1 / FAIL numeric not lexical | killed | `5462804a898f` |
| M06 | 380 | `value.split(".")` → `value.split(".")[:2]` | 1 / FAIL downgrade fired lie refused; feed-floor/live-observation failures | killed | `e87a115f775d` |
| M07 | 380 | `value.split(".")` → `value.split(".")[1:]` | 1 / FAIL major component compared | killed | `f62674bb137c` |
| M08 | 387 | `seen < anchor` → `seen <= anchor` | 1 / FAIL unchanged feed; equality/receipt failures | killed | `6c836a48d339` |
| M09 | 387 | Compare against `(anchor[0], anchor[1], anchor[2] - 1)` | 1 / FAIL downgrade fired lie refused; feed-floor/live-observation failures | killed | `ca954daf6b4f` |
| M10 | 380 | `int(part)` → `int(part[:4300])` | 0 / PASS (79 cases) | survived | `9f4c9c2d7ff0` |
| M11 | 710 | Stable-title regex: every `[0-9]+` → `\d+` | 0 / PASS (79 cases) | survived | `c5e08d4b2ed5` |
| M12 | 711 | Stable-tag-link regex: every `[0-9]+` → `\d+` | 0 / PASS (79 cases) | survived | `cd441d71f114` |
| M13 | 712 | Text-version regex: every `[0-9]+` → `\d+` | 0 / PASS (79 cases) | survived | `45bb342803a1` |
| M14 | 710 | Remove terminal `$` | 1 / FAIL version parser rss product titles (`3.16.0` != `3.15.0`); no stable entry accepted | killed | `3d87ff3ce2f9` |
| M15 | 711 | Remove terminal `$` | 1 / FAIL version parser no stable entry: accepted | killed | `127567d7b24f` |
| M16 | 712 | Remove terminal `$` | 0 / PASS (79 cases) | survived | `35178f57e769` |

## Concrete surviving counterexamples

The retained [witness.py](../sandboxes/MutBaseNumeric-7/witness.py) imports the sandbox target only, catches exceptions for reporting, and replaces its HTTP request function with supplied in-memory bytes. Its exit 0 means the witness ran, **not** that the invariant held. Full commands, outputs and exits are in `results.json`.

| Mutant | Input / surface | Pristine → mutated actual output |
|---|---|---|
| M01 | `numeric_version("٣.١٥.١")` (Arabic-Indic digits) | `None` → `(3,15,1)` |
| M03 | `numeric_version("1.2.3.4")` | `None` → `(1,2,3,4)` |
| M04 | `numeric_version("1.2.3-rc1")` | `None` → `ValueError: invalid literal for int() with base 10: '3-rc1'` |
| M10 | `numeric_version("1.2." + "1" * 4301)` | `ValueError` for 4301 digits → accepted tuple with component digit lengths `[1,1,4300]` (silent data loss) |
| M11 | RSS title `Python ٣.١٥.١`; anchor `3.15.1` | parser `ValueError`, observation error/no verdict → raw Unicode token, observation `fired` |
| M12 | XML link ending `/releases/tag/v٣.١٥.١`; same anchor | parser `ValueError`, observation error/no verdict → raw Unicode token, observation `fired` |
| M13 | Text `Version: ٣.١٥.١\n`; same anchor | parser `ValueError`, observation error/no verdict → raw Unicode token, observation `fired` |
| M16 | Text `Version: 8.23.0-rc1\n`; anchor `8.22.0` | parser `ValueError`, observation error/no verdict → parsed `8.23.0`, observation `fired` |

C1 selftests need cases capable of rejecting these non-canonical/partial tokens, preserving whole-token validation, and rejecting oversize components rather than silently truncating them. The leading-zero witness demonstrates why ordinary numeric equality is insufficient. XML title, tag-link and plain-text ingress need independent coverage. These are additional selftest-coverage findings; the frozen F1–F4/control counting command and fixture set were neither edited nor redefined.

## Commands, exits, and restoration evidence

- Extraction actually run (exit **0**): `mkdir -p /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/MutBaseNumeric-7/base && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d499577084a6c98d7078906017840bbf7b28 | tar -x -C /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/MutBaseNumeric-7/base`.
- For each M01–M16, cwd was its own sandbox copy; environment `TMPDIR=<copy>/.tmp`; command `python3 -I -B corpus/release-clock.py --selftest` ran pristine → mutated → restored. **48 detector runs**: pristine/restored exits all 0, mutant exits as table; no timeout.
- From pristine `base`, `python3 -I -B ../witness.py Mxx` ran for M01–M16 plus `C1-leading-zero`; from each mutated and restored copy, the same command ran for its own Mxx. **49 witness commands**, all exit **0**; JSON contains caught target exceptions and actual results. Every witness subprocess had a 15-second bound.
- SHA-256 of pristine and restored `corpus/release-clock.py`, identical in every copy: **`53823416d267e886d780fc347f6ef6f347592ba117ebc296e2148e88a2a136dc`**. All 16 restored files also compared byte-for-byte equal to the original export, not merely hash-equal. Mutant-specific full hashes, exact diffs and all phase stdout/stderr/exit codes are in `.ufo/waves/round-28/sandboxes/MutBaseNumeric-7/results.json`.
- Tools installed/updated: **none**. No subagent dispatch, commits, index writes or production integration.

## Not checked

No round-28 candidate implementation, C2 derived-anchor binding, frozen C1/C2 measure scripts, default receipt command, lane gates, host-ledger commands, live/public feeds, account/vault/handler/CDP surface, alternate interpreter, or altered integer-limit configuration was executed. The observation witnesses are offline function-level probes, not CLI `--observe` runs. No claim is made that these mutations enumerate all C1 gaps or that helper witnesses replace the frozen acceptance fixtures. This is lane-authored advice, not non-author closure.
