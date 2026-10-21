# RevOnRelease: how `on-release` entered the kagi registry, and which lanes bind it to a feed

Seat KagiR25.RevOnRelease-2 (leaf, read-only). Lane kagi-shokunin at BASE 4587c61a348e4528717404a68912c373f3ef4d03 (detached HEAD; `merge-base --is-ancestor` exit 0; worktree corpus/SOURCES.md = HEAD). Probe clock 2026-10-21T10:42:03Z (`date -u`). Axes: calibration, operability, freshness.

## Verdict
- Introduced by c41af82dfb11ac74b5cb40284415ed366554262b (round-21, 2026-10-19), the commit that created corpus/SOURCES.md. Later commits added S017–S032, all `on-release`; no existing row's recheck value changed in the six commits.
- Recheck cell: 0 of 587 `on-release` cells in 21 lanes name a feed or release (every cell is the bare token). Kagi: 0 of 28.
- Source cell: 4 lane rows name an enumerating feed or index: kaidoku S029 (`releases.atom`; its tag equals the feed's newest entry), tabi S017, tsukuroi S053, tameshi S005 (mutable `main`). Kagi: none.
- Plan C3 counts reproduce independently: kagi on_release=28 with no feed in any kagi cell, so unbound=28.

## 1. Introduction
`git log -S'on-release' --reverse --format='%H %ad | %s' --date=short -- corpus/SOURCES.md` (exit 0)
| commit | date | rows / on-release after | recheck values added |
|---|---|---|---|
| c41af82dfb11ac74b5cb40284415ed366554262b | 2026-10-19 | 16 / 12 | S001–S004 `90d`; S005–S016 `on-release` (root) |
| 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3 | 2026-10-20 | 21 / 17 | S017–S021 `on-release` |
| 4be5da3cac11a1db64c3e0a77246fd7f2bdee413 | 2026-10-20 | 23 / 19 | S022–S023 `on-release` |
| e1884c6ecb7ccd717965b0d748bc193137118dbf | 2026-10-20 | 26 / 22 | S024–S026 `on-release` |
| a3eb6c756dcc14470442e719d86fb1beadf561ec | 2026-10-21 | 31 / 27 | S027–S031 `on-release` |
| 277a0d4f1d9bc6c5cea9b1d0ab92e33e5c17bb56 | 2026-10-21 | 32 / 28 | S032 `on-release` |
- c41af82 subject: "add SOURCES.md + sources-census gate with three sourced entries (capability/coverage)"; body empty.
- corpus/QUALITY.md:23 (QA4, same at c41af82 and HEAD): "a `recheck:` trigger (cadence or release event)"; `-S'release event'` finds only c41af82.
- Same commit, `git grep` at c41af82: sources-census.sh:236 fixture "| rejected | 2026-10-19 | on-release | — |"; four knowledge entries carry `on-release` (e.g. sops-age-key-rotation.md:5 "recheck: on-release — on a SOPS release or a change to the pages' "Last modified" footer").
- No rationale recorded: commit body empty; corpus/lessons/round-21.md has no on-release text; nothing explains 90d (S001–S004) beside on-release (S005+) in one commit.
- Operability: `git log --all -S'on-release'` without a path also lists other lanes' refs (authors `protocol-shokunin`, `t`); use HEAD plus path.

## 2. Census enforcement (corpus/sources-census.sh at HEAD)
- Enum checks read tier, status and kind (awk $5/$9/$4, line 191). No registry check reads the recheck column: `\$1[01]` hits only line 475 (TSV helper) and 478 (fixture string).
- Line 340 `grep -q '^recheck:' "$f" || finding SC_ENTRY_HEADER …` checks presence only, never the value.

## 3. Counts per lane
Worktree; census row shape (`| S### |`, 11 columns). enum = feed or index named in the source cell; pin = tag or version-pinned URL; docs = other http(s) URL; nourl = no URL (own-work or tool rows).
```
lane           rows  onrel enum  pin docs nourl | lane          rows  onrel enum  pin docs nourl
audio            15     10    0    3    4     3 | kotodama        47      9    0    0    9     0
chousa           33      7    0    0    6     1 | kumitate        33     15    0    2   12     1
game-dev-2d      31     28    0   11   14     3 | lore            32     11    0    0    9     2
game-dev-3d      36     23    0    6   16     1 | mado          120     67    0   51   16     0
kagi             32     28    0    0   28     0 | mori            65     44    0    7   37     0
kaidoku          50     33    1    5   18     9 | revenger        15      6    0    0    4     2
kake             31      5    0    2    2     1 | souji           95     83    0    7   74     2
kama             65     48    0   23   25     0 | tabi           100     77    1   17   59     0
kasegi           30     14    0    0   14     0 | tameshi         76     17    1    0   14     2
kengaku          48      7    0    0    7     0 | tsukuroi   80(76) 51(47)  1    9   27    14
kotoba           11      4    0    2    2     0 | ALL           1045    587    4  145  397    41
```
- Header-keyed parsing misses 16 on-release rows (audio 2, tsukuroi 14): those tables continue after a blank line with no header (audio SOURCES.md:23–24; tsukuroi :72+). Header-keyed total 571 of 587.
- tsukuroi at HEAD: 76 rows, 47 on-release. S077–S080 are uncommitted and all on-release.

## 4. Live probe
`env -i PATH=/usr/bin:/bin HOME=<sandbox>/home curl -fsSL --compressed --max-time 40 -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o <file> <url>`; all exit 0; bodies in /fast/scratch/kagi-r25/RevOnRelease-2/feeds/
- github.com/getsops/sops/releases.atom: newest v3.13.3, 2026-07-23T05:29:11Z → kagi S008–S011.
- github.com/openbao/openbao/releases.atom: v2.7.1, 2026-10-01T18:32:18Z → kagi S014–S016, S021, S025–S026 ("2.7.x" agrees).
- github.com/hashicorp/vault/releases.atom: v2.2.0, 2026-10-15T18:50:14Z → kagi S012–S013, S022–S024.
- github.com/python/cpython/releases.atom: v3.15.0, 2026-10-09T11:16:41Z (alpha v3.16.0a1, 2026-10-13) → kagi S027–S028 (docs "Python 3.15.0 documentation" agrees).
- github.com/curl/curl/releases.atom: 8.23.0, 2026-10-14T06:06:16Z → kagi S029 (see §5).
- github.com/NationalSecurityAgency/ghidra/releases.atom: Ghidra 12.1.4, 2026-09-21T17:38:59Z → kaidoku S029 (tag agrees).
- gitlab.archlinux.org/api/v4/projects/archlinux%2Fmkinitcpio%2Fmkinitcpio/releases (JSON): v42.2 2026-10-01T07:10:00Z, v42.1 2026-09-27T06:44:54Z → tsukuroi S053 (agrees). The `/-/releases` HTML is a 295-character JS shell; use the API.
- playwright.dev/docs/release-notes (HTML): newest "Version 1.64" → tabi S017 (agrees).
- app-updates.agilebits.com/product_history/CLI2 (HTML): stable 2.41.0 (2026-10-12); 2.42.0-beta.01 (2026-10-08). No feed is named by op-ref-consumption.md.

## 5. Findings by axis
- Calibration: the plan's "28" holds (kagi 28 of 32 rows, SOURCES.md:11–38). kagi S029 anchor "curl 8.23.1 man page" (SOURCES.md:35) names an unreleased manual: curl.se/docs/manpage.html reads "This man page describes curl 8.23.1."; curl.se/download.html reads "Version: curl 8.23.0 Release date: 2026-10-14". kagi S012 (:18) "newest pinned version v1.21.x" conflicts with feed v2.2.0 (flagged at .ufo/waves/round-22/build/Source12.md:11). S013 (:19) "no displayed version/date" was found false at Source13.md:53. Both unchanged at HEAD.
- Operability: the recheck cell is free text and no gate reads it, so an unbound or stale trigger cannot fail. The round-22 replacement "Observable trigger to replace 'on-release for S006–S007'" (.ufo/waves/round-22/build/Entry15.md:179–182) never reached corpus/ (no match for "Observable trigger|observable one|observable release|observable surface"); S006–S007 (SOURCES.md:12–13) and onepassword-machine-credentials.md:4 still read on-release. S008 has a main-branch URL under a release clock (Source08.md:55–56).
- Freshness: 18 kagi rows have a vendor release feed (SOPS S008–S011; Vault S012–S013, S022–S024; OpenBao S014–S016, S021, S025–S026; CPython S027–S028; curl S029). 10 have none (Broker S005–S007, S017–S020, S032; WHATWG S030–S031) and need a rendered-quote clock. No probed feed shows a release after any kagi row's verification (earliest open 2026-10-19; latest Vault 2.2.0 on 2026-10-15), so the registry cannot show this check.
- The clause has no fixed meaning: Source12.md:66 calls Vault's clock "already due"; Source09.md:144–146 calls SOPS's "not newly due". Where a version and a feed are both named, they agree (kaidoku:35, tsukuroi:59, tabi:31).
- Unclocked: op-ref-consumption.md:371 "`recheck: on-release of op` — rerun `R21-01` after every op upgrade" names no feed. CLI2 lists stable 2.41.0, while .ufo/waves/round-22/falsify/AttackEntry18.md:43 records §1–§8 measured on op 2.35.0.

## 6. Unrun, limits, tooling
- UNRUN: sources-census.sh, claim-ledger.sh, and the C3 gate (`corpus/release-clock.py`, planned this round); the contract forbids gates on the lane tree. Not searched: Broker and WHATWG feeds (none expected); mutmut releases (S005 cites `main`).
- Installs or updates: none. Tools: git (read-only), /usr/bin/curl, python3 eval kernel. Writes: this file and the sandbox only; no lane file or git state changed.
