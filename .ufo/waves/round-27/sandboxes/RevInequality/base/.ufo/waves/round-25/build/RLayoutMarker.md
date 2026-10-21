# RLayoutMarker: round-25 C2 fleet-layout marker (design attack)
Seat KagiR25.RLayoutMarker-2 · lane BASE 4587c61a348e4528717404a68912c373f3ef4d03 · plan C2 = plans/round-25.md:38-55 · sandbox /fast/scratch/kagi-r25/RLayoutMarker-2 (lane/ fx/ plants/ tsv/ out/ rec-marker.sh markers.sh)

## Verdict
Use the two-view union in §2. FLEET-ABSENT only if NO fleet-root identity entry (`.ufo`, `MANIFEST.json`, `MISSION.md`, `AXES.md`) and NO other `*-shokunin` sibling sits beside the lane, checked in the physical AND the logical parent. Over 22 fixture rows: 0 safety failures, 1 operability cost (F13). Two spec gaps block C2 as written: a LAYOUT-SKIP counted like HOST-SKIP prints CLEAN exit 0 (§5), and "unresolved=88" depends on the lone clone's basename (§4).

## 1. Axes and evidence
Axes: S safety (a fleet miss is never FLEET-ABSENT; hard) · O operability (a lone clone is FLEET-ABSENT) · P portability (symlinked, renamed, `--root .` lanes classify by the layout present) · K count calibration.
- claim-ledger.sh:118-119 ROOT = logical `cd … && pwd`; :321 `--root` taken verbatim (`--root .` accepted: F06/x BROKEN 88, F01 CLEAN).
- :620-636 resolver: `$ROOT/../…` tests are kernel-resolved ⇒ PHYSICAL parent; `.ufo/` is lane-first (:627-632).
- :116 `set -euo pipefail`; :677 and :1022 `shopt -s nullglob`; :411 already uses `readlink -f` (no new dependency).
- :738-744 path tokens on marker-word lines are LABELED, not UNRESOLVED. :554-556 HOST-SKIP is not a failure; :1126-1132 CLEAN prints host_skipped; :1611 selftest pins it.
- claim-ledger.tsv:22 R11-08. corpus/knowledge/claim-ledger.md:334-337 calls a relocated checkout's UNRESOLVED "a real signal" (C2 reverses this; doc needs update).
- shokunin.conf:6-7 fleet root = "the repo holding MISSION.md, AXES.md, MANIFEST.json, .ufo/"; :51 lists kagi-shokunin.
- Lane `git ls-files -- .ufo | wc -l` = 575 ⇒ `$ROOT/.ufo` always exists: a lane-local marker is vacuous. Fleet tracks `.ufo` (2760), MANIFEST.json, shokunin.conf.

## 2. Recommended test (rec-marker.sh v2; code below minus comment lines; full text tested, bash -n rc=0)
```bash
fleet_entry_in() {
  local p=$1 self=$2 d
  [[ -n $p ]] || return 1
  for d in .ufo MANIFEST.json MISSION.md AXES.md; do
    [[ -e $p/$d || -L $p/$d ]] && return 0
  done
  for d in "$p"/*-shokunin; do
    [[ ( -e $d || -L $d ) && $(readlink -f -- "$d") != "$self" ]] && return 0
  done
  return 1
}
fleet_root_present() {
  local root=$1 self lp
  self=$(readlink -f -- "$root")
  lp=$(cd -- "$root/.." 2>/dev/null && pwd) || lp=
  fleet_entry_in "$root/.." "$self" && return 0
  fleet_entry_in "$lp" "$self"
}
```
Use in if-context only, and only in the ufo|sibling branch: `if fleet_root_present "$ROOT"; then <UNRESOLVED> else <FLEET-ABSENT> fi`. A bare call aborts under the gate's set -e when LONE (measured: bare-call F06/x rc=1; if-context F06 LONE, F01 FLEET). Each term is the sole positive for some fixture: `.ufo` F03; MANIFEST F02; MISSION/AXES F16; siblings F04; `-e` F12 (file); `-L` F11 (dangling); logical view F10; physical view F09 and RR; self-exclusion keeps F07/F14/F15 LONE.

## 3. Matrix (22 rows; S = fleet truth → FLEET-ABSENT; O = lone clone → FLEET)
| candidate | S | O |
|---|---|---|
| `-d $ROOT/../.ufo` | 7: F02 F04 F10 F11 F12 F16 D5 | 0 |
| `-e $ROOT/../MANIFEST.json` | 7: F03 F04 F10 F11 F12 F16 D5 | 1: F13 |
| any `$ROOT/../*-shokunin`, self counted | 3: F08 F10 D5 | 4: F07 F14 F15 D6 |
| any sibling, self excluded | 8: F02 F03 F08 F10 F11 F12 F16 D5 | 0 |
| basename `*-shokunin` | 5: F08 F09 D2 D4 D5 | 3: F07 F14 F15 |
| `-d $ROOT/.ufo` (lane's own) | 0 | 8 (vacuous) |
| `.ufo`/MANIFEST, physical parent only | 4: F04 F10 F16 D5 | 1: F13 |
| v1 union, `dirname` logical view | 0 | 3: F13 D1 D6 (`--root .` bug) |
| **v2 union (recommended)** | **0** | **1: F13** |
| v2 physical only / logical only | 2: F10 D5 / 3: F09 RR D4 | 1: F13 each |

Fixtures: F01 full fleet · F02 MANIFEST only · F03 `.ufo` only · F04 siblings only · F06 lone `x` · F07 lone `kagi-shokunin` · F08 renamed lane + identity · F09 lane symlink INTO fleet · F10 lane symlink TO lone clone · F11 dangling `.ufo` · F12 `.ufo` is a file · F13 lone beside foreign MANIFEST.json · F14 lane alone · F15 fleet 4 levels up · F16 MISSION+AXES only · RR live lane via read-only symlink · D1–D6 = `--root .` / `./x` run from inside the lane dir.
Simulated on the real BASE UNRESOLVED lists (rule applied to citations output; no lane patch): `-d .ufo` on F02 prints `unresolved=0 fleet_absent=46` (hides 46 real misses); v2 keeps `unresolved=46`. F04: `.ufo`-dir hides 31; v2 keeps 31. F05 (fleet + planted misses): v2 `unresolved=4` (ufo 2, sibling 1, local 1).

## 4. Count facts for the C2 spec
- Lone clone named `x` (= plan's /tmp/x): `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)` rc=1. 88 = ufo 31 (all `.ufo/` prefix) + sibling 57 (42 `kagi-shokunin/…`, 15 other). Plan :51 matches.
- Same clone named `kagi-shokunin` (default clone name): `unresolved=46` (31 + 15), because its 42 self-named cites resolve to itself. The "88" is name-dependent.
- Fleet clone F01 and live RR: `CITATION_GATE: CLEAN (cites=1371 docs=67 unresolved=0 ephemeral=0 labeled=13)` rc=0; unresolved symmetric difference = []. Lone labelled=25 vs fleet 13 ⇒ 12 layout-dependent path misses are LABELED (:738-740), in neither unresolved nor fleet_absent.
- Commands: `env -i PATH=/usr/bin:/bin HOME=$S/home bash $S/lane/corpus/claim-ledger.sh citations --root <root>`; verify with `--claims $S/tsv/r1108.tsv --stamps <root>/corpus/stamps.tsv --docs $S/plants/p3-local-miss.md`.

## 5. Verdict discipline (blocks C2 if omitted)
- Live HOST-SKIP analog (F01, ID-free `--docs`): `HOST-SKIP HX-1 reason=host-row-not-authorized` then `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=83 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=1)` exit 0.
- So a LAYOUT-SKIP counted like host_skipped gives CLEAN exit 0 on a lone clone (false pass). Fix: `layout_skipped>0` joins the FAIL predicate (:1126) and cells (:1155); citations (:1165) gains `fleet_absent>0` ⇒ INCOMPLETE exit 1.
- BASE controls: F06/x and F07 `verify --claims r1108.tsv` ⇒ `FAIL R11-08 reason=exit-mismatch exit=1 want=0` + `CLAIM_LEDGER: FAIL (claims=1 failed=1 …)` exit 1. F01 ⇒ `CLAIM_LEDGER: CLEAN (claims=1 … host_skipped=0)` exit 0.

## 6. Residuals (the marker cannot fix)
1. F13: an unrelated MANIFEST.json or `foo-shokunin` beside a lone clone ⇒ FLEET. Safe direction; costs the label only.
2. F15: fleet 4 levels up ⇒ LONE. FLEET-ABSENT must read "documented one-level root absent", not "no fleet".
3. Lane-first `.ufo/` misses (31 in lone) are all fleet-resolvable today (0 hidden real misses measured), but a future lane-local `.ufo/` miss is indistinguishable in lone. Split counts: `ufo_lane_first` / `ufo_shorthand`.
4. Self-named cites (42 in lone `x`): `kagi-shokunin/SKILL.md` is FLEET-ABSENT though `$ROOT/SKILL.md` exists (plant p4). Self-rule `<basename(ROOT)>/…` ⇒ `$ROOT/…` in both layouts: no-op in fleet (same file), name-independent in lone (predicted 46 for `x`, equal to measured F07).

## 7. Hygiene, UNRUN, tools
- Lane: no writes by me. One early `git -C kagi-shokunin status --short` without GIT_OPTIONAL_LOCKS=0 (may refresh index stat cache; no add/commit/stash/checkout/reset). Later git calls were read-only with GIT_OPTIONAL_LOCKS=0.
- Real tree: read-only `citations` via sandbox symlink RR, `test -e`, `ls`. verify only on sandbox clones F01/F06/F07. No host rows, no vault/CDP/op, no `--allow-host-rows`.
- Single-row verify without `--docs` gives `unresolved_ids=508` idref noise; runs used ID-free docs.
- Unexplained: first 4-way concurrent batch gave F01 R11-08 `failed=1` (FAIL line not captured); 5 later runs (3 concurrent) gave failed=0. Not isolated.
- UNRUN: LAYOUT-SKIP / `[fleet]` / `layout_skipped` (no implementation in BASE); `--selftest`. C1 and C3 out of scope. Tools: none installed or updated (bash 5.3.20, git, python3 present).
