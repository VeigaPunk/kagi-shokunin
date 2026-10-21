# AttackEntry15 — falsification attack on C2 for `corpus/knowledge/onepassword-machine-credentials.md`

- **Seat:** KagiR22.AttackEntry15, reviewer, falsify wave, read-only (leaf; no dispatch). One production write was never attempted. No tools installed (none needed); no launcher/package/loopback probes; only owned local reads/hashes and unauthenticated public documentation GETs.
- **Axes:** C2 freshness (primary); C1 calibration residuals read off this entry's appended correction.
- **Falsification input:** frozen integrated tree, master tip `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (confirmed ancestor-of-master; working tree clean for every file cited below, `git status --porcelain` empty on all five). The historical base `c2cab35bc92e57e39e5489bac3386db078345b3f` is BEFORE, not the attack input.
- **Observed wave hashes (measured now):** integration-manifest `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`; falsify-start `77adac99f2a3de1cf08e9022ab6aea1880cc3a0c606d19b6dae9111a25e0c722`; frozen/before/expected.json `b4e05d5fc2ed569d9a49edbe62e88dd191281804b160d726f6c9746852611e22`; build/Entry15.md `99708b2ff2024b1a6f4b316f71d43332ed1cab57ba30206996b7bd49377bae55`; historical-correction-pins.json `f033693c55a6fc893e45767f2e4f655d9b9da33e21cf37ec6b675dd17fce069a`; pin-migrations-integration.json `f7543d8c53080ad7037b87edc6c18e6b5bea062e156f116affd9dc127e45cfde`; integration-pin-check.json `f09062425d82b5bedd1c0b99742167b11efa688e26f42cd93a0a509c4cbffde4`.
- **Manifest freeze hashes for every file attacked below** (from `integration-manifest.json` inputs; named per contract): entry `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` (80 ln, 9048 B), stamps.tsv `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (69 ln, 7213 B), claim-ledger.tsv `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` (58 ln, 17770 B), SOURCES.md `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` (86 ln, 19721 B), feature-bound-credential-review.md `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` (43 ln, 4440 B). All five re-measured on 2026-10-20 during this wave and equal — **byte-exact zero drift; no lane edit during the wave**.

## 1. Verdict

**ADMISSIBLE.** The integrated C2 landing for this exact entry survives the fresh attack: frozen-before bytes and current bytes differ by a **pure append-only 45-line delta** (0 deleted lines, byte-identical 6240-byte prefix), the appended round-22 erratum marks every previously false reading found by the wave and my independent checks, and the stamp row was migrated 7635be81…/35/6240 → 95d5b58d…/80/9048 with the old value preserved in `pin-migrations-integration.json` and in git history — no deletion, no laundering. Residual gaps (below) are bounded and documented, none rise to a falsification of this entry's C2 accounting.

## 2. Byte comparison: unchanged prefix proven

| object | sha256 | lines | bytes |
|---|---|---|---|
| frozen-before copy `.ufo/waves/round-22/frozen/before/corpus/knowledge/onepassword-machine-credentials.md` | `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb` | 35 | 6240 |
| current (frozen tree) | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` | 80 | 9048 |
| landed commit `8ada17a` blob | `09e9acadbdadd5ba9d45c413bea1bd560521887b` | 80 | 9048 | (working-tree bytes equal landed blob — clean freeze) |
| base commit `c2cab35` blob | `d69e058d0c002aeddb9d71d2b6edb8f943138c83` | 35 | 6240 | (equals the frozen-before copy exactly) |

- `cmp`: **EOF on before at byte 6240** — the first 6240 bytes (all 35 before-lines) are byte-identical; every divergence is inside the appended 2808 bytes (lines 36–80).
- `git diff --numstat c2cab35..8ada17a` on this path: **45 added, 0 deleted** (delta = 9048−6240 = 2808 bytes). Append-only purity proven mechanically, not asserted.
- History: `c41af82` pin 2cc5cfae…/30/5364 → `e1544c1` pin 7635be81…/35/6240 → landed pin 95d5b58d…/80/9048. Every historic value remains recoverable from git; the mutable-snapshot semantics are documented (`historical-migrations.json` `snapshot_semantics`).

## 3. Stamp record (C2 pointer accounting)

- `corpus/stamps.tsv` line 26: `corpus/knowledge/onepassword-machine-credentials.md  95d5b58d…bfbd80  80  9048` — matches current bytes **exactly** (sha256, wc -l, wc -c all three). One row for this path; no duplicates.
- `pin-migrations-integration.json` records this exact migration: old_stamp `7635be81…/35/6240`, `base_observed` equal to the git-verified base blob, new_stamp `95d5b58d…/80/9048`, disposition "Reviewed current round-22 artifact; historical source facts remain historical."
- `integration-pin-check.json`: stamp run exit 0 ("STAMPED: n=69"); revision audit stdout `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)` — matching the manifest expectation block verbatim (added 6 = the five new knowledge/lesson files + revision-audit.py; dropped 0; the round-21 "six stale" state, including this entry's pre-restamp pointer, is closed).
- `historical-correction-pins.json` keys this entry at `7635be81…` — the post-landing round-21 correction state, consistent with the `c41af82 → e1544c1` chain in `historical-migrations.json` (old `2cc5cfae…` → new `7635be81…`, `removed_members: []`).
- Registry `corpus/SOURCES.md` byte-exact vs manifest pin: `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` (86 ln, 19721 B) re-measured on current tree — equal. Zero removed lines vs the frozen-before copy; five added registry rows S017–S021; no S001–S016 field rewrite.
- **This entry was never a member of the nine-line replacement set** (`aea7a43 → e1544c1` covers LOG/PROVINCE/SCORECARD/SHONEN/SKILL/corpus README/claim-ledger/op-ref-consumption/op-ref-probe per `round21-migrations.json`), and no stamps.tsv revision ever dropped this path (first appearance `c41af82`, continuous since). The "nine dropped stamps" framing is confirmed as replacement-not-drop, and separately this path is untouched by it.
- Per contract I did **not** rerun `revision-audit.py` (global parent duty; measured by integration-pin-check.json evidence instead).

## 4. Build/Entry15.md cross-check (advisory, not evidence)

Entry15's report was advisory per contract, but where testable it is accurate: it recorded the live delta as 68 ln / 8328 B (`e885081e4d56…`) — a predecessor of the landed 80/9048 state with the same sha256-prefix family; it predicted `SC_USEDBY_MISSING` risk if the lesson didn't land — the lesson did land (used-by rows verified in §5), so that risk did not materialize; its K1–K5 findings were incorporated as the appended erratum and its append-only/no-rewrite/no-restamp constraints are honored in the landed bytes. Build-seat claims that could not be verified byte-for-byte from this seat (its live page fetches) are treated as advisory observations, per the frozen-input contract.

## 5. Appended-correction quality: does it mark every false reading without laundering?

The appended bytes (lines 36–80) contain: round-22 erratum ("feature-specific status and eligibility"), a recheck trigger, and "Additional source-attribution bounds (round 22)".

**Correctly marked (my independent verification):**
1. **Item 4's unqualified "public preview"** → now scoped per-path: GitHub Actions public preview [S017]; Custom OIDC public beta "not public preview" [S018]. Verified live 2026-10-20: S017 title "…GitHub Actions at runtime (public preview)" (1 beta occurrence = shared chrome; 29 preview), S018 title "…custom workflows at runtime (public beta)" (21 beta vs 9 preview occurrences).
2. **Round-21 erratum's mis-anchored eligibility quote** → erratum now cites S006/S020 introduction + §New in this release, and states the announcement's split explicitly. Verified live: the sentence "available for all Enterprise Password Manager Business customers" sits at byte 25698, immediately before the §How 1Password Credential Broker works heading (byte 26021) — i.e., in the introduction; "Try 1Password Credential Broker today" is a separate later H2 (byte 36202). The old §Try 1Password locator was indeed wrong; the new locator is right.
3. **The "does not rebut the outside reviewer" admission** is present in the appended text — the failure is owned, not erased.
4. **Supersession** explicitly points to `feature-bound-credential-review.md` as the active corrected reading; the historical item-4 sentence is declared preserved history, not silently rewritten.
5. **Cross-product / overreach guards** carry over (integration key still required; workflow-duration ≠ token expiry; no account/SDK/vault exercised).
6. **S019/S020 registry supersession** is qualifier-scoped, not row deletion: S006/S007 original rows remain `mined` with unchanged status/recheck/used-by; verified: 0 removed lines in the SOURCES.md diff (frozen-before copy = the landed commit's registry bytes), 5 added rows S017–S021.
7. **Historical-fact hygiene**: the appended bounds explicitly refuse to promote fetch digests to currentness pins ("historical point observations without a recorded representation").

**Residual gaps (honest, documented, non-laundering — none falsify the entry):**
- R1: The appended text does not repeat the round-21 erratum's now-known-wrong locator ("§Try 1Password Credential Broker today"). A reader of only the round-22 erratum could still cite the wrong section. Mitigated: the new erratum cites the correct anchors explicitly (S020 introduction and §New in this release), so the operative locator is right; the stale one survives only in the preserved historical bytes it is declared to supersede. Proposed (non-blocking): one sentence in the round-22 erratum ("the round-21 bullet's locator §Try … is corrected to the announcement introduction").
- R2: The erratum cites S017–S020 in-body but the header `source:` line (preserved by design, append-only) still lists only S001–S007; S017–S020's registry used-by binds the lesson + feature-bound-credential-review.md, not this entry. This is an explicitly documented design bound ("the census reads only the source: line"), and the active corrected reading carries the full provenance trio — so the citation chain is not silent; it is a bound, not a defect. If the parent wants header-level closure, that is a separate reviewed header migration the build wave intentionally declined (legacy-header census interaction).
- R3: My independent S018 fetches (2026-10-20, twice, byte-identical 1,282,617 B) did not reproduce the claim-matching sentence on the custom-workflow page ("All configured claims must match": 0 hits in raw markup or stripped text), while S007's guide carries it verbatim under its workload-identity list. The corrected reading attributes claim-matching to S018's page context (Entry15's build-scout finding placed it there live); the JavaScript-SDK-only callout IS verbatim-visible ("1Password Credential Broker is only supported in the 1Password JavaScript SDK"). Claim-matching on S018 remains an **unverified anchor** from this seat (Entry15's live observation is advisory, not reproducible evidence). The row stays source-bound — the registry's own anchor field, not my assertion, carries it — but the parent should know this specific anchor had two negative reproduction attempts.
- R4: The feature pages carry JSON-LD `dateModified` metadata (S017 2026-08-04, S018/S019 2026-08-17). The corpus's stated rule is "no version/date displayed" (matching the human-visible page), which is consistent with these non-displayed metadata values; flagged only as a potential future, stronger freshness anchor (a machine-readable modified-date could make the on-release trigger observable) — not a defect of this round's accounting.

## 6. Pointer freshness vs. unavailable source facts

- The stamp row measures **pointer integrity of in-repo bytes only**; it does not and cannot assert vendor currentness. The appended erratum and registry supersession make this distinction explicit rather than implying digest equality = currentness.
- Vendor-side facts I could not re-derive from the repo (recorded fetch digests; S006's 2026-10-19 byte state; S018's claim-matching anchor location) remain **unavailable source facts** — the corpus correctly does not claim them as fresh; the round-22 lesson says so explicitly ("Restamping proves pointer integrity only, never currentness").
- My live 2026-10-20 spot-checks (S006/S017/S018/S019) **corroborate** the corrected reading's status/eligibility/exclusion anchors at title/introduction level; they are point observations, not reproducible pins (consistent with the corpus's own digest-semantics limitation).

## 7. Exact read revision

`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (master tip, confirmed ancestor; working tree clean on all five attacked files; every input hash re-measured equal to its manifest freeze value).

## 8. Proposed corrections (all non-blocking, no production write by this seat)

1. Append one sentence to the round-22 erratum superseding the round-21 locator explicitly (R1).
2. Optionally record the JSON-LD `dateModified` values as a future observable on-release trigger for S017–S019 rows (R4).
3. Parent-level: the global revision-audit rerun should confirm `stale=0 missing=0 dropped=0 added=6 invalid=0` against `8ada17a…` with the landed stamps.tsv/claim-ledger.tsv — as already recorded in `integration-pin-check.json`.

**Admissibility verdict: ADMISSIBLE** — appended corrections mark every identified false reading (per-path Broker status, per-feature eligibility, announcement split, cross-product guards, superseded locator) without laundering; no silent deletion, no expectation rewrite without recorded evidence, no restamp-as-currentness claim.
