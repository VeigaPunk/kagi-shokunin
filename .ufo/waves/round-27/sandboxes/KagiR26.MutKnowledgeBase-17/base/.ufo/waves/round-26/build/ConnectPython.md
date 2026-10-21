# ConnectPython — round 26 sibling-overlap scan: Python source drift vs tsukuroi package state

Seat: `KagiR26.ConnectPython` (connector, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git -C kagi-shokunin rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE).
Production writes: none. Sibling writes: none. Installs: none. Host reads: none (no `python3 --version`, no `pacman -Q`; installed-interpreter facts below are cited from sibling corpus only).

## Bounded result

**C1 remains in-lane.** No sibling province claims Python documentation teachings, the python.org release feed, or S027/S028/S036. Tsukuroi owns *installed package state* (read-only), and installation stays operator-owned. Neither touches kagi's documentation-freshness claim. There is one calibration hazard at the boundary (CX-1), and two freshness-instrument counterexamples come from the round-26 cache (CX-2, CX-3).

## Inspected scope (exact)

- Province files: `ls */PROVINCE.md` under `/home/vgpnk/Projects/shokunin` found 21 province files. The Glob tool returned 0 matches for `*/PROVINCE.md`, so I used `ls` instead.
- Searched all 21 with `rg -n -i 'python|pacman|uv tool|pip|package manag|system package|cpython|3\.15' */PROVINCE.md`. Hits were only in audio (pipewire, irrelevant), kaidoku, kama (L96, irrelevant), kengaku (its own `python3` gate entry points, irrelevant), mori, and tsukuroi.
- Read in full: `kagi-shokunin/PROVINCE.md` and `tsukuroi-shokunin/PROVINCE.md`. Read kaidoku L100–115 and mori L1–20 and L108–120.
- Tsukuroi corpus: `rg -n -i 'python|3\.15|cpython'` over the repo, excluding `.ufo`. Also searched `SKILL.md`, `corpus/knowledge/update-safety-v2.md` and `arch-news-gate-2026.md`.
- Kagi: `corpus/SOURCES.md` rows S027/S028/S036, `corpus/release-clocks.tsv:24-25`, `corpus/release-clock.py:649-699`, shebangs of `corpus/{rendered-text-v1,release-clock,self-counts}.py`, and `corpus/claim-ledger.tsv:83` (R25-04).
- Round cache: `.ufo/waves/round-26/observe-1.json:247-268`, `build/ClockS027-artifacts/*` and `build/ClockS028-evidence/*` (titles, sha256 prefixes, headers).

Pins, all with clean `PROVINCE.md` (`git status --porcelain PROVINCE.md` printed 0 lines):

| Province | HEAD | `PROVINCE.md` sha256 |
|---|---|---|
| kagi | `1bf3eec4` | `22ed8900…2cdaa`, byte-identical to `git show 1bf3eec:PROVINCE.md` |
| tsukuroi | `e99303c7ca75363b99a3d1937e65329b815c50f2` | `a296da87…9b7a79` |
| kaidoku | `2ee3d9f51c6a995d1aefe48f6a44cfd08d492d67` | `69c4f61e…4bf4e66dc` |
| mori | `77a5bbe8a0b41dfbfd2546d024d36e294b814bd0` | `31b2ca62…fbb2d4` |

## Boundary evidence (source anchors)

| Side | Anchor | Text (verbatim fragment) |
|---|---|---|
| tsukuroi owns | `tsukuroi-shokunin/PROVINCE.md:3-14` | "package state, systemd, drivers/firmware, boot health" … "pacman state (`pacman -Qkk` verify loops, foreign/AUR census …" … "Update-safety questions: what an -Syu would touch" |
| tsukuroi refuses | `tsukuroi-shokunin/PROVINCE.md:26-29` | "secrets (→ kagi) … Never installs, upgrades, or removes packages; never restarts services. Detection and report; the operator remediates." |
| tsukuroi→kagi route | `tsukuroi-shokunin/PROVINCE.md` ADJ-02 | credential-helper permission/auth-flow only; "package drift is not proof of credential exposure". No Python-docs route exists. |
| mori routes package state | `mori-shokunin/PROVINCE.md:11-13` | "OS package, systemd unit, driver/firmware and boot state (→ tsukuroi)" |
| kaidoku refuses installs | `kaidoku-shokunin/PROVINCE.md:108-113` | "Installing engines, Python packages, or editing client configs — … all **operator-owned**" |
| kagi domain | `kagi-shokunin/PROVINCE.md:3,57` | secrets & vault ops. `release-clock.py` binds "every `on-release` registry row … to one fireable clock … `--observe` writes a dated receipt and never rewrites the table" |
| kagi adjacency | `kagi-shokunin/PROVINCE.md` §Adjacent (round 21) | "tsukuroi tracks the 1Password packages — kagi owns runtime auth and credential custody" |
| kagi Python rows | `corpus/SOURCES.md:33,34,42`; `corpus/release-clocks.tsv:24-25` | S027 = `re` `\s` and S028 = `html.unescape`, both "Python 3.15.0 documentation", `on-release`, clocked by S036 (python.org RSS). Tsv anchor `3.15.0`, `not-fired`. |
| tsukuroi Python mentions | `tsukuroi-shokunin/corpus/knowledge/*` | Incidental only: an OOM victim named `python3` (`oom-event-plane.md:28`), an omarchy shebang patch `env python3`→`/bin/python3` (`degraded-triage-r4.md:63,151`), `python3.14` SIGSEGV coredumps (`degraded-triage-r4.md:252`, `host-health-report-r3.md:254`; probes dated 2026-10-14), and Python used as a counting tool. None is a documentation, feed or release-clock claim. |

Taken together, the partition is:

- **Kagi** owns the freshness of documentation teachings that ground its normalizer (S027/S028) and the feed clock (S036).
- **Tsukuroi** owns read-only detection of which `python` package is installed and what an `-Syu` would change.
- **The operator** owns any install or upgrade.

No sibling text claims kagi's ground, and the round-26 plan already disclaims "installed Python upgrade" (`plans/round-26.md:7`). Arbitration is not needed and none is proposed.

## Actionable counterexamples

**CX-1 — documentation version ≠ interpreter that runs the normalizer (calibration hazard at the tsukuroi boundary).**
`corpus/rendered-text-v1.py`, `release-clock.py` and `self-counts.py` all start with `#!/usr/bin/env python3`, which is unpinned. Tsukuroi's dated records name the host interpreter `python3.14` (`degraded-triage-r4.md:252`, 2026-10-14). [INFERENCE] The installed interpreter was the 3.14 branch at that date; its current version is unobserved by this seat.

Re-verifying S027/S028 against the 3.15.1 docs therefore shows only that the *documented* behaviour is unchanged. It does not show that the host interpreter behaves this way, and the normalizer's recorded digests are produced by that interpreter. Establishing the installed version is tsukuroi's surface (pacman state) and upgrading it is the operator's.

C1 stays in-lane only if the new receipt and any superseding rows say "documentation teaching" and leave the executing interpreter out of their scope. Pitfalls:

- Running `python3 --version` or `pacman -Q python` inside kagi to "close" the gap would absorb tsukuroi ground.
- Phrasing the teaching as verified host behaviour would overclaim.

**CX-2 — newest-published item is an older branch (freshness parser).**
The round-26 feed is `build/ClockS027-artifacts/feed.body`, fetched 2026-10-21T13:36:43Z, `last-modified` 13:08:09 GMT. Its items appear in this order:

| Order | Title | pubDate (2026-10, UTC) |
|---|---|---|
| 1 (first) | Python 3.14.9 | Wed 21, 13:08:09 |
| 2 | Python 3.15.1 | Wed 21, 09:59:50 |
| 3 | Python 3.16.0a1 | Tue 13 |
| 4 | Python install manager 26.4 | Fri 9 |
| 5 | Python 3.15.0 | Fri 9 |
| 6 | Python 3.15.0rc3 | — |

A first-entry or latest-pubDate reading yields **3.14.9**. That would either make S027/S028 look regressed or, compared as unequal to `3.15.0`, report a false fire. `release-clock.py:655-699` takes the max X.Y.Z over stable titles (`STABLE_TITLE_RE` at L649 rejects `3.16.0a1`, `3.15.0rc3` and the three-word install-manager title), and `observe-1.json:252,263` correctly records `parsed_version: "3.15.1"`, `verdict: "fired"`.

Any round-26 counting instrument or reviewer that re-derives the version independently must use the same max-stable rule. The 3.14.9 item belongs to the installed 3.14 branch (CX-1), so it is tsukuroi/operator update-safety material, not a kagi clock event.

**CX-3 — a "version-pinned" capture floats to the patch release.**
In `build/ClockS028-evidence/`:

- `html.body` and `html3150.body` are byte-identical (sha256 prefix `8a54138162e47f1b`) and both titled "Python 3.15.1 documentation".
- Only `html3150rel.body` (`ed0ca0adbea5e061`) is titled "Python 3.15.0 documentation".

The same holds in `ClockS027-artifacts/`, where `re3.body` and `re315.body` are identical (`0724d8159158bdc1`) and titled 3.15.1. [INFERENCE] The seats fetched `/3/`, `/3.15/` and a release-specific path; the URLs are not in the header files.

So a capture named for 3.15 is not evidence of 3.15.0 bytes. The superseding rows must cite the served `<title>` version per URL, not the path name. Otherwise an "old vs new" comparison can silently compare 3.15.1 with 3.15.1 and report no drift for the wrong reason.

## Proposed move (one, bounded)

L1 integrates this, and it only affects text in the new receipt and the new superseding rows. Historical rows S027, S028 and S036, `release-clocks.tsv`, `.ufo/waves/round-25/observe-1.json` and R25-04 stay untouched.

1. Each new S027/S028 superseding row should carry the **served documentation title** (`Python 3.15.1 documentation`) and the URL that served it. It should also carry one limit clause: "documentation teaching only; the interpreter executing `corpus/*.py` is unpinned (`#!/usr/bin/env python3`) and its installed version is tsukuroi/operator package state, not asserted here."
2. The C1 counting instrument should count a drift disposition only when the old and new evidence differ in their **served title version** (3.15.0 → 3.15.1). It must never treat a path-named capture as the old version (CX-3), and it must reuse release-clock's max-stable rule rather than taking the feed's first item (CX-2).

**Axes:**

- **Calibration improves:** this removes a host-behaviour overclaim, and drift can no longer be counted from a path name.
- **Freshness is unchanged:** the same 3.15.1 observation is used.
- **No axis harmed:** there is no new surface, no sibling text, and no host read.
- It also preserves the lone-clone result: C2 stays INCOMPLETE/48, untouched.

## Risks

- The limit clause could be misread as kagi claiming the interpreter surface. Keep it phrased as an exclusion with the owner named, never as a measured version.
- The `python3.14` anchor is stale by design (2026-10-14 record, tsukuroi HEAD `e99303c7`). Cite it only as the reason for the exclusion, never as the current installed version.
- CX-3's URL attribution is inferred from filenames. The ClockS028 and ClockS027 seat reports are authoritative for which URL each file came from.

## Verification

Run here (all read-only):

```
git -C kagi-shokunin rev-parse HEAD
git show 1bf3eec:PROVINCE.md | sha256sum
ls */PROVINCE.md
rg -n -i 'python|pacman|uv tool|pip|package manag|system package|cpython|3\.15' */PROVINCE.md
rg -n -i 'python|3\.15|cpython' tsukuroi-shokunin   # corpus scan, .ufo excluded
rg -o '<title>[^<]*</title>|<pubDate>[^<]*</pubDate>' .ufo/waves/round-26/build/ClockS027-artifacts/feed.body
sha256sum, plus a <title> grep, over re3/re315/html/html3150/html3150rel .body files
sed -n 240,272p .ufo/waves/round-26/observe-1.json
```

Not run (L1-only, after integration): `release-clock.py` (offline or `--selftest`), `claim-ledger.sh`, `sources-census.sh`, `self-counts.py`. No pass is claimed for any of them.

Suggested L1 checks after integration:

- `rg -n 'served|documentation title|tsukuroi' corpus/SOURCES.md` on the new superseding rows, to confirm the limit clause and served title are present.
- `git diff 1bf3eec -- corpus/release-clocks.tsv .ufo/waves/round-25/` must show no rewrite of the historical anchors or receipt.
