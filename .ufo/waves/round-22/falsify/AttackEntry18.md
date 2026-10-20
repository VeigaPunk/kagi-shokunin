# AttackEntry18 — falsify integrated C2 for `corpus/knowledge/op-ref-consumption.md`

Seat: `KagiR22.AttackEntry18` (falsification wave, read-only + this report). Axes: **calibration**, **freshness**.
Frozen inputs: `.ufo/waves/round-22/integration-manifest.json` (write-freeze); integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (`falsify-start.json`). Historical base `c2cab35bc92e57e39e5489bac3386db078345b3f` used only as documentation of the BEFORE bytes, never as the falsification input.
Method: static reads, `sha256sum`/`wc`/`cmp`, read-only `git show <hash>:<path>`, scratch under `/tmp/kagi-r22-AttackEntry18`. No gate executed, no install performed, no host/vault/loopback/launcher action, no production write.

## 1. Observed hashes (falsify wave, this tree)

| Item | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/knowledge/op-ref-consumption.md` (current) | `4b89d3b91f41039c12a3fca349b3154a4d8a8d0cd08b2c182b0b4cf6b6a75e9c` | 384 (`wc -l`) | 25991 |
| same — manifest `inputs` entry | `4b89d3b9…75e9c` | 384 | 25991 | **equal → tree is the frozen integrated input** |
| `corpus/stamps.tsv` (current) | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | 7213 | **equal to manifest input** |
| `corpus/claim-ledger.tsv` (current) | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 | 17770 | **equal to manifest input** |
| BEFORE bytes (`git show c2cab35:corpus/knowledge/op-ref-consumption.md`) | `b195cc69840b0b6df65e578d86c0457a4a74b1660dca2e8f4513275a190143dd` | 372 | 25290 |
| Appended delta (bytes 25291→EOF of current) | `3abba8bdd0641b06b336018e124f291572fb9f79115d66c136d7253e79d628fb` | 12 | 701 |

`cmp` of BEFORE vs the first 25290 current bytes: **identical** (`PREFIX-IDENTICAL`). Delta arithmetic closes exactly: 372+12=384 newlines, 25290+701=25991 bytes. The change from the historical BEFORE is a **pure append** — zero edited or deleted prefix bytes. The file keeps its historical no-final-newline convention (385 logical lines, 384 newlines).

## 2. Stamp record (pointer freshness)

- Current row (`corpus/stamps.tsv` line 29, exactly 1 row for the path): `corpus/knowledge/op-ref-consumption.md⇥4b89d3b91f41…75e9c⇥384⇥25991` — recomputed sha/newlines/bytes match the live file exactly. **Pointer integrity holds.**
- Round-22 pin migration documented (`pin-migrations-integration.json` lines 281–291): `old_stamp b195cc69…/372/25290` → `new_stamp 4b89d3b9…/384/25991`, with `base_observed` confirming the base bytes and disposition "Reviewed current round-22 artifact; historical source facts remain historical." QM14 old/new evidence present.
- Nine-stamp reconciliation as it touches this entry: `round21-migrations.json` preserves this path's replaced row verbatim — old `dcd9389415efff26…/307/21164` → new `b195cc69…/372/25290` — with `removed_members: []`; the row was replaced because round 21 appended §11 (six byte observations and bounded reading), not dropped. Current registry: 69 rows = 63 retained + 6 reviewed additions (`R12-03` 63→69; manifest `revision_audit` stale=0 dropped=0 missing=0 added=6 invalid=0 as frozen expectation).

## 3. What the append corrects — coverage check

The 701-byte append is exactly `## Erratum (round 22 — comparator history)` (lines 375–385). Against current bytes:

1. **§10's stale count is marked.** Lines 296–297 still read "`--selftest` proves the comparator on 21 cases, including fifteen seeded mutations" — untouched historic text. The Erratum names this sentence, calls `21` "an intermediate historical count", and pins the current contract at **36**. `corpus/claim-ledger.tsv` line 27 (`R12-02`) indeed expects `^OP_REF_SELFTEST: PASS \(36 cases\)`.
2. **§9's stale count was already marked.** §11's correction note (pre-existing) supersedes §9's `PASS (29 cases)` → 36 and leaves §9 as written. The Erratum extends this explicitly to §10 so neither stale count survives unmarked.
3. **No in-place rewrite anywhere.** The byte-identical prefix proves no false reading was silently edited away or re-stamped over; corrections are appended, historic text stays historic. No laundering mechanism exists in this diff.
4. **The R11-01 pointer debt is labelled, not erased.** Line 23 `Reverify: R11-01, R12-01, R12-02, R21-01` is unchanged; the Erratum states "The surface-census pointer in this entry is not evidence for dotenv semantics." This is the build seat's offered alternative ("accept as labelled pointer debt") — disclosed, not removed. Residual calibration debt, explicitly visible.
5. **Numbers audited beyond the erratum:** §9's `checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6` and §11's `checks=6`/seven byte-comparator cases are consistent with ledger rows `R12-01` (v2 counts 12/7/5 sig=6), `R21-01` (`checks=6 failed=0`), and the `R12-02` note (29 until aea7a43 added 7 → re-pinned 36). No other stale numeric found in this entry's prose.

**Wording nuance (non-defect):** the Erratum's "The existing §11 correction to '36' *also* supersedes that §10 count, not just §9" reads an application into §11's note that §11's text does not literally make (it names §9 only). The current-state claim "the selftest now proves 36 cases" does supersede any stale count, so the extension is a clarification; it does not create a false statement.

## 4. Pointer freshness vs unavailable source facts

The re-stamp proves **pointer integrity only**; no hash promotes any fact to current:

- **Handler-derived rows are unverifiable on this host.** `$HOME/.local/bin/the-janitor` absent (observed, read-only); by §Bounds.8 the probe's designed answer is `SETUP` exit 2. The Erratum explicitly retains "unavailable-substrate limits" on handler observations — accurate.
- **Version pinning.** §1–§8 measured on op 2.35.0, §11 on 2.40.0/2.41.0. Host now has `/usr/bin/op` **2.41.0** (observed read-only; `op --version`). The 2.35.0 parser tables are version-pinned history (§Bounds.6); the byte arm's recheck trigger ("on-release of op") is not fired by today's host, but no gate was run here to assert anything about op behaviour.
- **Vault-dependent bounds §Bounds.1–5** (masking of resolved refs, mask token, `--no-masking` × ref, `inject`/`read` execution) remain unmeasurable by construction; no vault/account/credential operation was attempted or needed.
- **Runtime counts are asserted, not observed, in this wave.** The 36-case composition (31 case checks + 5 paired assertions, 15 seeded mutations) rests on the committed ledger expectation and the Erratum's own instruction that "reading the expected regex is not a measurement". I ran no selftest (assignment: no gates); execution is parent scope.

## 5. Admissibility verdict

**ADMIT.** The integrated C2 treatment of this entry is admissible: the pre-integration and integrated states are reconciled by a pure 701-byte append (prefix byte-identical to the historical BEFORE), the stamp row is re-pinned to exactly the integrated bytes in documented old/new migration evidence with zero removed members, every known stale reading (§9's 29, §10's 21) is marked by appended correction without in-place rewriting, and the one retained defect (irrelevant `R11-01` Reverify pointer) is disclosed as labelled debt rather than laundered. Restamping nowhere claims source currentness.

Residual (explicit, none inadmissible): (a) `R11-01` pointer stays in the Reverify set — labelled non-evidence, removal deferred to a future docs-audit edit; (b) selftest/byte-arm/revision-audit execution unobserved in this wave — parent duty (rerun revision-audit once globally; `bash corpus/op-ref-probe.sh --selftest` → `PASS (36 cases)` if gates are authorized); (c) 2.35.0-era tables remain historical unless an op release trigger fires.

## 6. Limits

Static analysis of frozen bytes only; no fixture or gate executed (assignment forbids live host gates), so no runtime output is cited. `git show c2cab35:…` was used solely to obtain historical BEFORE bytes for the prefix proof; the falsification input is the manifest-frozen integrated tree, whose hashes this tree reproduces exactly. Host observations (`op` present/2.41.0, handler absent) are read-only binary-presence checks, not probes of vault or account state.
