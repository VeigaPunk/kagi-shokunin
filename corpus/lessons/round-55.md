# Round 55 — registry used-by records every entry that names a row (C1, calibration); the ISO/IEC 11770-3 entry names the amendment in force and its recheck clock reads true (C2, freshness)

source: S113 (https://www.iso.org/standard/82709.html, life-cycle list naming `ISO/IEC 11770-3:2021/Amd 1:2025`, opened 2026-11-07); S114 (https://www.iso.org/standard/85929.html, title `ISO/IEC 11770-3:2021/Amd 1:2025`, opened 2026-11-07)

Frozen plan: `plans/round-55.md` (predeclaration `f2b986fadd8f8551e760cc89f59e0ae0edb0d499`; BASE `ebe095857a734caf5efdd7bd776feb22b4e23972`; no amendment). Counters `plans/round-55-c1.sh`, `plans/round-55-c2.sh`; pre-freeze controls `plans/round-55-controls.sh` (22 controls, all MATCH, each line carrying the counter's own reason: `.ufo/waves/round-55/controls/controls-prefreeze.txt`).

## Claims

- **C1 calibration — used-by gaps 25 → 0.** The registry's used-by cell is the lane's statement of which entries cite a row. At BASE, 25 (row, entry) pairs had an entry naming the row while the cell omitted it (`.ufo/waves/round-55/controls/c1-base.txt`); the census never saw them because SC_USEDBY_NOCITE and SC_ENTRY_CITE read only `source:` lines. Ten entries now carry one column-1 `cites:` line, the 25 cells list the entry, and the census reports SC_BODY_CITE for any future unrecorded mention.
  - Frozen predicate (verbatim, plan §C1 and counter header): `C1_USEDBY_GAP: value = GAP when GUARD = 1, else FAIL; target 0 (BASE 25).`
- **C2 freshness — ISO/IEC 11770-3 entry currency 0 → 2.** The round-45 entry said the IEC record names "a newer amendment to the 2021 edition" without naming it; it is ISO/IEC 11770-3:2021/Amd 1:2025 (S114, listed in the 2021 record's life cycle, S113). The entry's recheck stated `-> 1` for a page that gives 2 (`c2-base.txt`: `recheck:S101-count-2-stated-1`).
  - Frozen predicate (verbatim, plan §C2 and counter header): `C2_ISO_CURRENT: value = AMD + RECHECK when GUARD = 1, else FAIL; target 2 (BASE 0).`

## Gate

- **S113 — new, opened 2026-11-07** (capture `.ufo/waves/round-55/capture/S113.body`, L1, request profile `curl-fsSL-compressed-v1` with the browser user agent the S101 row already declares; the default user agent receives HTTP 403, receipt `capture/rejections/default-ua_85929.meta`): `https://www.iso.org/standard/82709.html`, HTTP 200, `text/html;charset=UTF-8`, decoded body sha256 `d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357`, 90604 B (identical to an earlier same-day fetch). Quote (4 words, `printf '%s' … | wc -w`): `ISO/IEC 11770-3:2021/Amd 1:2025` at byte offset 53493 (life-cycle list); the stage line reads `International Standard published [ 60.60 ]` after tag stripping. Tier A (the publisher's own catalogue record), recheck `180d`.
- **S114 — new, opened 2026-11-07** (capture `.ufo/waves/round-55/capture/S114.body`, same profile): `https://www.iso.org/standard/85929.html`, HTTP 200, decoded body sha256 `8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf`, 85138 B; a refetch later in the round gave the same digest (`capture/rejections/S114-refetch.meta`). Quote (4 words): `ISO/IEC 11770-3:2021/Amd 1:2025` at byte offset 541 (title); subtitle `Amendment 1: TFNS identity-based key agreement` at offset 670; after tag stripping `Publication date : 2025-04` and `Stage : International Standard published [ 60.60 ]`. Tier A, recheck `180d`.
- **S101 re-opened** (not a new row): the 2026-11-07 live body is byte-identical to the round-45 capture (`2e4c1524…7b0c80`, 85615 B), and `grep -c 'Withdrawal of International Standard'` gives 2 on both (byte offsets 45705 stage line, 62733 life-cycle list). The round-45 `-> 1` was wrong when written (M55-2).
- **Rejected — `https://www.iso.org/contents/data/standard/08/27/82709.detail.rss`** as a clock for the entry (L1, 2026-11-07: HTTP 200, `application/rss+xml;charset=UTF-8`, 1371 B, sha256 `d17018559e7eb539…`; receipt `capture/rejections/www_iso_org_contents_data_standard_08_27_82709_detail_rss.{meta,body}`): its single item says the 2021 edition "reached stage 60.60 on 2021-10-22" and carries no item for Amendment 1:2025, published 2025-04, so it did not move when the amendment appeared. REJECTED: a per-standard feed that does not record amendments cannot watch this entry's currency; flip: the feed gains an item per amendment or stage change.
- **Rejected — `https://webstore.iec.ch/en/publication/107179`** (the IEC co-publisher record of the same amendment; staged as S172 in the shokuknow package `merge/kagi/SOURCES.append.md:127`; L1, 2026-11-07: HTTP 200, `text/html; charset=UTF-8`, 429695 B decoded, sha256 `6a557e1d8c4eab3d…`; receipt `capture/rejections/webstore_iec_ch_en_publication_107179.{meta,body}`; `ISO/IEC 11770-3:2021/AMD1:2025` at offset 187): REJECTED: duplicate ground — S114 is ISO's own record of the same publication with stage and date; flip: the ISO record becomes unreachable or the two records disagree on stage or date.
- **Rows touched (old → new), used-by cells only (append-only rule; status and recheck unchanged):** S012 `…vault-openbao-token-lease-lifecycle.md` → `+ corpus/knowledge/oidc-federation-trust-policy.md`; S017 and S018 `…round-22.md, …feature-bound-credential-review.md` → `+ cdp-bridge-1password-oidc-workflow.md, onepassword-machine-credentials.md`; S019 → `+ onepassword-machine-credentials.md`; S020 → `+ cdp-bridge-1password-oidc-workflow.md, onepassword-machine-credentials.md`; S021, S023, S105 → `+ vault-openbao-token-lease-lifecycle.md`; S022 `corpus/lessons/round-22-source-errata.md` → `+ oidc-federation-trust-policy.md, vault-openbao-token-lease-lifecycle.md`; S024 → `+ openbao-kv-v2-version-lifecycle.md`; S047, S050 → `+ oidc-federation-trust-policy.md`; S048, S055, S056 → `+ secret-scanning-detection-vs-validation.md`; S049 → `+ nist-key-management-guidance-status.md, nist-key-management-parts-withdrawal.md`; S072 → `+ op-ref-consumption.md`; S112 `corpus/lessons/round-54.md` → `+ corpus/knowledge/op-ref-consumption.md` (round-54 closure D1); S103, S104 `corpus/lessons/round-48.md` → `+ sops-age-key-rotation.md`. Each added path is `corpus/knowledge/<name>.md`; `git diff ebe09585 -- corpus/SOURCES.md` shows the exact cells.
- **Discernment sample (LEARNING.md):** admit — S114 (quote located at its offset, stage and date read from the body). Reject — the IEC co-publisher record of the same amendment (duplicate ground), and the per-standard RSS as a clock (it never recorded the amendment).
- **Counting rule (E49-1):** every word count here is `printf '%s' "<quote>" | wc -w`.
- **Rows added:** 2 (S113, S114; tier A 2). **Rows touched:** 20 (used-by cells, 25 added paths). Registry 112 → 114.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M55-1 | `unrecorded-citation` (an entry names a registry row in its text while the row's used-by omits the entry, so the lane's statement of who cites a row is short of what the files say) | 25 pairs at BASE `ebe09585` (`.ufo/waves/round-55/controls/c1-base.txt`); round-54 closure D1 found one (S112 ↔ `op-ref-consumption.md`, §11.2) | none: SC_USEDBY_NOCITE and SC_ENTRY_CITE read only the `source:` line, and legacy entries are outside every census check | `cites:` record + SC_BODY_CITE in `corpus/sources-census.sh`, QM71. Shown able to fail: selftest `body-cite-unrecorded`, `body-cite-legacy`, `body-cites-usedby-omits`, `body-cites-not-a-row`, `body-cites-two-lines` (each exit 1 with SC_BODY_CITE), and controls K1-F8 (the landing on the BASE census reads FAIL) and K1-F9 (one record withdrawn reads FAIL) |
| M55-2 | `stale-recheck-expectation` (a `recheck:` command states a result its own source never gave, so the clock reports a change on every run and a real change is indistinguishable from the standing false fire) | `corpus/knowledge/iso-11770-3-edition-status.md:3` at BASE: `-> 1` for `grep -c 'Withdrawal of International Standard'`; the round-45 capture `.ufo/waves/round-45/controls/capture-r45/S101.raw` (sha256 = the 2026-11-07 live body) gives 2 | none: no gate replays an entry's recheck command against the capture of the row it fetches | the C2 RECHECK conjunct replays this entry's commands on committed captures (control K2-F1: the BASE expectation restored reads `recheck=0`). A lane-wide replay gate is routed (§Routed 2), not landed |

## Closure defects of round 54 (spot-check `corpus/lessons/round-54-verifier-spotcheck.md:88-93`)

- **D1 (S112 used-by omits the op-ref entry):** fixed by C1 (S112 used-by lists `corpus/knowledge/op-ref-consumption.md`; the legacy entry records S072/S112 on its `cites:` line) and generalised: the 24 other pairs of the same class are fixed and the class is gated (M55-1, QM71).
- **D2 (seat receipts with an unexpanded revision header):** the round-55 wave context requires every seat receipt to name the measured revision as a 40-hex hash produced by `git rev-parse`, never a literal `$(…)`.
- **D3 (counter hardening, carried):** the round-55 counters adopt three of the routed hardenings — `python3 -I -B` reading a stdin program from a scratch cwd (M54-5), a fence-aware registry parse, and a symlink-component check on capture paths; the release-clock selftest gaps (R54ReviewerParser F1–F2) and feed-URL normalisation stay routed (the gate is not touched this round).
- **D4 (R11-08, R25-02, R36-01 FAIL; R29-01, R29-02, R38-03 POLICY):** unchanged and untouched; operator-routed rows are not migrated.

## Routed (named, not claimed this round)

1. Round-54 routed items 1–8 stand except 1's op items (closed in round 54) and the D1 part of the census (closed here).
2. A lane-wide recheck replay: every entry `recheck:` command of the form `curl … '<URL>' | grep -c '<Q>'` -> N replayed on the committed capture of the row whose URL it fetches (M55-2 generalised). Six other entries carry `grep -c` commands and one a rendered-text `locate` command; several fetch URLs whose capture is a rendered-text normalisation, not a raw body, so the replay needs the normalisation declared per row before it can be a gate.
3. `cites:` is a header line for entries; lessons keep their `source:` lines. Lessons were outside C1's population.

## Frontier

- Coverage-map ground advanced: the ISO/IEC 11770-3 entry now names the amendment in force (ISO/IEC 11770-3:2021/Amd 1:2025) from the publisher's own records; registry 112 → 114.
- Census gate: entries' body citations join the citation handshake (SC_BODY_CITE), legacy entries included.

## Assimilation

Assimilation: none adopted. Sweep `grep -rlE '11770|iso\.org/standard/(82709|85929)' /home/vgpnk/Projects/shokuknow/merge/kagi` ⇒ 10 files: the staged GB/T 17901 entries (sibling-national ground outside this round's claims) and the staged rows S161 (iTeh preview PDF of the 2021 edition) and S172 (IEC record of the AMD1:2025). S172 was read as a lead and opened (rejected above as duplicate ground of S114); no staged row or entry is appended.

## considerthese

Newest file `considerthese/2026-10-26.md`; none taken. The C2 recheck correction touches `considerthese/2026-10-20.md` proposal 5 ("check quotes, not page hashes, for source freshness"): this entry's recheck already checks a quote; M55-2 shows the quote's stated count must itself be checked against the capture, which §Routed 2 carries.
