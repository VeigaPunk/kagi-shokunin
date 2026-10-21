# MutDowngradeBase — C2 red-before mutation probe

Axes: **calibration, freshness**. Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`.

## Result

**S040 downgrade SURVIVED at BASE:** with anchor `3.15.1`, observed `3.15.0`, and matching TSV/receipt verdict `fired`, the offline detector exited **0** and printed:

```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)
```

**S027 un-fire also SURVIVED at BASE:** changing its observation from `3.15.1`/`fired` to `3.15.0`/`not-fired` exited **0** and printed:

```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=2 derived=15)
```

Both pristine controls and both restored controls exited 0 with `fired=3`. Neither finding depends on a failing baseline. These are bounded mutation-probe classifications, not round acceptance or non-author closure.

**Calibration distinction:** S040 is strictly below its numeric anchor and directly exercises C2. S027 returns to its own `3.15.0` anchor; it is not below that anchor. It demonstrates loss of the prior fired state, but does **not** establish that the planned below-anchor guard must reject this equality case. [INFERENCE] A guard limited to `observed < anchor` would not by itself prevent the S027 un-fire. No after implementation was run.

## Scope and isolation

All six input files were extracted with read-only `git cat-file blob BASE:path`, not copied from the concurrently changing working tree. BASE `corpus/release-clocks.tsv` is byte-identical to BASE `.ufo/waves/round-26/rearmed/after/corpus/release-clocks.tsv`: SHA-256 `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd`.

**Location deviation:** the requested `/fast/scratch` location conflicts with the higher-priority write boundary permitting only this lane's unique wave sandbox/report. Consequently, execution used separate scratch roots:

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027`

No production script or production input was executed or changed. The only behavior-bearing mutations were the selected row's observed version/verdict in a copied TSV and the same record's parsed version/verdict in a copied receipt. Code, anchors, URLs, timestamps, receipt body-digest fields, and all other records were unchanged. Independent cases ran concurrently, with a 30-second timeout per invocation and bytecode writes disabled (`-B`, `PYTHONDONTWRITEBYTECODE=1`). The retained-receipt branch was used; no `--observe` invocation occurred.

Full six-run argv arrays, exit codes, stdout/stderr, per-run input hashes, mutation diffs and byte-equality restoration evidence are preserved in:

`.ufo/waves/round-27/sandboxes/MutDowngradeBase/probe-evidence.json`

## Exact BASE locations and expected detector

All production-style `path:line` references in this report refer to **BASE**, not the current working tree. The extracted readable copies are under `.ufo/waves/round-27/sandboxes/MutDowngradeBase/pristine/` with the same relative paths and line numbering.

- `corpus/release-clocks.tsv:30` — S040 anchors `3.15.1`, observes `3.15.1`, verdict `not-fired`; its note identifies the rearmed successor. Corresponding source anchor: `corpus/SOURCES.md:47`. Original receipt record: `.ufo/waves/round-26/observe-2.json:312-322`, parsed version at line 318 and verdict at line 321.
- `corpus/release-clocks.tsv:24` — S027 anchors `3.15.0`, observes `3.15.1`, verdict `fired`. Corresponding source anchor: `corpus/SOURCES.md:33`. Original receipt record: `.ufo/waves/round-26/observe-2.json:246-256`, parsed version at line 252 and verdict at line 255.
- `corpus/release-clock.py:362-363` — normalization only removes an optional leading `v`; it does not establish version precedence.
- `corpus/release-clock.py:517-531` — an otherwise-valid feed row is accepted as fired when observed and anchor differ, or not-fired when they are equal. No older-than-anchor branch exists here.
- `corpus/release-clock.py:378-399` — receipt validation binds the selected row's verdict and observed version to the receipt. Mutating both copies consistently avoids a mere `RECEIPT-MISMATCH` test.
- `corpus/release-clock.py:411-424` — the explicit receipt digest checks the selected receipt's bytes. The probe deliberately passes each synthetic receipt's newly computed digest; it does **not** claim to defeat the unchanged default pin.
- `corpus/release-clock.py:558-560,578-590` — accepted rows increment observed/fired totals; no errors yields CLEAN.
- `corpus/release-clock.py:1583-1604` — absent `--observe`, the command loads the retained receipt, evaluates it and returns 0 on a passed result.
- `corpus/release-clock.py:727-734` — the observation branch also selects fired solely by inequality. This was read, **not exercised** by this offline assignment.

For the S040 mutant, the C2 detector specified in `plans/round-27.md:24-35` should instead return **exit 1**, identify **REGRESSED S040**, and never accept the downgrade as CLEAN/a release event. BASE's concrete counterexample is the exit-0 CLEAN output above. For the separately requested S027 equality case, only the observed BASE un-fire is claimed.

## Mutations

| Case | Unchanged anchor | Pristine observed/verdict | Mutant observed/verdict | Paired receipt edits |
| --- | --- | --- | --- | --- |
| S040 | `3.15.1` | `3.15.1` / `not-fired` | `3.15.0` / `fired` | `parsed_version` → `3.15.0`; `verdict` → `fired` |
| S027 | `3.15.0` | `3.15.1` / `fired` | `3.15.0` / `not-fired` | `parsed_version` → `3.15.0`; `verdict` → `not-fired` |

These are caller-crafted synthetic metadata fixtures. Retaining the original body SHA field is not evidence that an authentic body actually parsed to the mutated version. Feed-body replay, authenticity and live vendor truth were not tested.

## Exact argv, exits and last lines

Each command below ran with `cwd` equal to its `--root`. No shell variable expansion or wrapper substitutions are needed. Each control argv was used twice: once before mutation and once after exact restoration. All six invocations produced empty stderr; their entire stdout consisted of the single last line recorded below.

### S040 pristine and restored — identical argv, executed once in each state

```sh
python3 -B /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040/corpus/release-clock.py --root /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040 --receipt /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040/.ufo/waves/round-26/observe-2.json --receipt-sha 13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169
```

Both runs: **exit 0**.

```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)
```

### S040 mutated

```sh
python3 -B /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040/corpus/release-clock.py --root /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040 --receipt /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S040/.ufo/waves/round-26/observe-2.json --receipt-sha f09761b39a8f70566c6a83ae8a6f9b4fcf0329362260bb0fbfd7f6902414674e
```

**Exit 0**.

```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)
```

### S027 pristine and restored — identical argv, executed once in each state

```sh
python3 -B /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027/corpus/release-clock.py --root /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027 --receipt /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027/.ufo/waves/round-26/observe-2.json --receipt-sha 13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169
```

Both runs: **exit 0**.

```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)
```

### S027 mutated

```sh
python3 -B /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027/corpus/release-clock.py --root /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027 --receipt /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/MutDowngradeBase/S027/.ufo/waves/round-26/observe-2.json --receipt-sha f7de548fe11d699e68a228b7b647db973be3c6c8cbbea215ff06f4ca202a3d99
```

**Exit 0**.

```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=2 derived=15)
```

## Before / mutated / restored hashes

SHA-256 of `corpus/release-clocks.tsv`:

| State | S040 scratch | S027 scratch |
| --- | --- | --- |
| Pristine | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` |
| Mutated | `807b7eb68e30cc5cc6bb8f84eee81fbdd30db35f7f5ef2547b15111474a17436` | `a49ca5c68a5b3fb4f97baa2011e3ebf9c55172a878a6c9ae7252d57dad4ebfd2` |
| Restored | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` |

SHA-256 of `.ufo/waves/round-26/observe-2.json`:

| State | S040 scratch | S027 scratch |
| --- | --- | --- |
| Pristine | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` |
| Mutated | `f09761b39a8f70566c6a83ae8a6f9b4fcf0329362260bb0fbfd7f6902414674e` | `f7de548fe11d699e68a228b7b647db973be3c6c8cbbea215ff06f4ca202a3d99` |
| Restored | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` |

The detector code was unchanged in every phase and both cases: `corpus/release-clock.py` SHA-256 `ef17654e0b7fcdee1cdf35d40dc359b194ce4b0711247877dedfa43ff6ef45cc`.

After reversing the exact targeted edits, all six extracted files in each scratch root were compared byte-for-byte to the captured BASE blobs; every comparison was true. The restored detector outputs independently returned to `fired=3`. The JSON evidence includes each unchanged supporting file's hash and each exact-byte comparison. No active mutated input remains in either case root; the mutation diffs remain as evidence.

## Not checked

- No production or after implementation, final gate, claim-ledger row, selftest, build, linter or formatter was run. Ledger expectations were read, not executed.
- No network fetch, public-document refresh, authentic cropped/stale feed body, parser replay or HTTP body-digest reproduction was performed. No vault/account/handler/CDP runtime was contacted.
- No unchanged-default-pin tampering test: explicit digests were intentionally recomputed for the synthetic receipts.
- No cross-row same-feed consistency or stored-history monotonicity detector was exercised. Other Python rows deliberately stayed pristine; these probes isolate the selected row's acceptance.
- No assertion about C1 binders, corpus-wide number coverage, nonnumeric anchors, prereleases, or other numeric comparisons is made.
- No package/tool installation or update occurred. No subagent, secondary orchestration runtime, Git index/jj state change, commit or push occurred.

Unrun checks are not passes. This report supplies the requested BASE counterexamples and restoration evidence only; L1 retains integration and final verification authority.
