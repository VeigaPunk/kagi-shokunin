# Round 25 — independent C3 measurement

## Files changed

- `.ufo/waves/round-25/tools/c3-measure.py` — new executable; uses only the standard library and Git CLI (`show` plus `cat-file` to distinguish an absent optional file), does not import `corpus/release-clock.py`.
- `.ufo/waves/round-25/build/XMeasureC3.md` — this evidence report.

## Behavior

The tool derives its repository root from its path, reads `corpus/SOURCES.md` and the optional `corpus/release-clocks.tsv` from the requested commit, and parses the `## Registry` pipe table by cells. It counts exact `on-release` values, IDs with exactly one binding, zero-binding IDs, orphan binding rows, ISO-8601 extended dates/timestamps, and exact `fired` verdicts. Setup/input errors print `C3_MEASURE: SETUP (...)` to stderr and return 2; a measurement returns 0 with the requested `C3_MEASURE` line.

Implementation pointers: Git revision reads and optional-file handling `tools/c3-measure.py:28-50`; robust registry table parsing `:53-98`; TSV schema and ISO-date parsing `:101-133`; counts `:136-154`; CLI/exit behavior `:157-177`.

## Evidence

Sandbox clone command (exit 0):

```sh
git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/XMeasureC3-2/lane && git -C /fast/scratch/kagi-r25/XMeasureC3-2/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03
```

BASE run, using the tool copied into that BASE clone (exit 0):

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XMeasureC3-2/home python3 /fast/scratch/kagi-r25/XMeasureC3-2/lane/.ufo/waves/round-25/tools/c3-measure.py 4587c61a348e4528717404a68912c373f3ef4d03
```

Stdout:

```text
C3_MEASURE rev=4587c61a348e4528717404a68912c373f3ef4d03 on_release=28 bound=0 unbound=28 orphan=0 observed=0 fired=0
```

Synthetic TSV test was committed only in the scratch clone at `708687f0fa42202a49f064ec12b5c219443fa8c9`. Its fixture has five `on-release` rows, two bindings for S002, no bindings for S004–S006, and a binding for non-`on-release` S003. The S001 date and S002 timestamp are ISO; two `not-a-date` values are not. S001 and orphan S003 carry `fired` verdicts.

Synthetic run (exit 0):

```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XMeasureC3-2/home python3 /fast/scratch/kagi-r25/XMeasureC3-2/lane/.ufo/waves/round-25/tools/c3-measure.py 708687f0fa42202a49f064ec12b5c219443fa8c9
```

Stdout:

```text
C3_MEASURE rev=708687f0fa42202a49f064ec12b5c219443fa8c9 on_release=5 bound=1 unbound=3 orphan=1 observed=2 fired=2
```

## Risks and blockers

- `orphan` means a binding ID is not among the `on-release` IDs (including IDs that exist in the registry with another recheck cadence). `observed` and `fired` count all TSV binding rows, including orphans; the synthetic fixture exercises that distinction.
- Invalid-revision/setup-error execution: UNRUN. No other checks, installs, or external operations were performed.
- Blockers: none.
