# R56ExecHarm — BASE vs candidate harm evidence, kagi round 56 (freshness / C1_REPLAY)

Seat: R56ExecHarm (executor, w1 wave; duplicate seat R56ExecHarm-2 active in parallel — scratch collision coordinated, no shared file writes). BASE 832ba6a53d6a76706b5c80bce2278683dea33d42. During this audit the lane moved 832ba6a → 42070de (epoch-A predeclaration) → 5d9a157 (B) → 711e6393 (C) → d362318 (D) → dd31b786 (E) → 9cbe9d5f (F, THE predeclaration) → bcf07e7 (**C1 landing commit**) → c90e6709 (tip: receipts + doc sync). Epoch re-anchoring was performed at every step; final evidence anchored to 9cbe9d5f/c90e6709, with the epoch-A finding trail retained because it is the harm evidence the later epochs closed.

All scratch work under /fast/scratch/hyaku/kagi-r56/R56ExecHarm/w1exec/ (one live clone: `w1exec/clone`, `--no-hardlinks --no-local`); snapshots were `git archive <rev> | tar` extractions, never clones. No lane writes except this report and build/R56ExecHarm.d/ receipts. No git/jj mutation in lane, fleet or siblings. No secrets, cookies or credential material read (capture receipt checked by shape + `grep -ci set-cookie` count only). Answering model: this seat made **no LLM/judge calls** — no observed answering model for any instrument; seat model per workstation context is zai/glm-5.3-flashx (context-provided, not observed from outputs).

## 1. Instruments (epoch-F, the frozen set) — exact SHA256

| file | sha256 |
|---|---|
| corpus/recheck-replay.py (gate) | b6959d6c7afb9380c043cbd40530e6a70ee8da2bf79f1ea9d0669706f50bb5a3 |
| plans/round-56-c1.sh (counter) | f4c1de312e4a566dfde6c0699fb66a94c2e71e459eb97afbddb5c4073ffd2382 |
| plans/round-56-controls.sh | 644cde80a7f1a05f6f3543c2b52a37c7e1dc82f40942199f4cb2b728d01b53ce |
| plans/round-56.md | d0a8e402da2ac7a5c40eb3352a91918830253ba5502aae66442740d0c9dc025b |
| corpus/recheck-captures.tsv | df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762 |

- Manifest bytes **unchanged across every epoch** (df46be5c… at 42070de, 5d9a157, 711e6393, d362318, dd31b786, 9cbe9d5f — measured each time).
- NORMALIZER_SHA256_PIN check: `git show 832ba6a:corpus/rendered-text-v1.py | sha256sum` → `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` = the pin. Pin binds BASE's normalizer exactly.
- GATE_SHA256_PIN: measured gate file at candF = b6959d6c… = pin (gate run + counter both bind it).
- Capture bodies S054/S055/S057/S067/S070/S074/S078 (.ufo/waves/round-56/capture/): sha256s in receipts `mut-*` runs and equal to manifest rows (gate r3 digest pass); earlier recording: 7cf6efb5…, f61c3993…, 221d80fa…, 4d016752…, 5c226c06…, df32e64b…, 68266cb1…. fetch-receipt.json sha256 080a04836c32ced34ffcd93c1e9574d395dacf0a0ffba720ce54d134292298bd; keys {author, command_template, date, header_policy, observed_rows[7]}; row keys {id,url,body_path,curl_rc,decoded_bytes,final_url,http_status,sha256}; `grep -ci set-cookie` → 0; header_policy states headers not stored (QM72).

## 2. Counter readings (bash plans/round-56-c1.sh; rc=0 each; HYAKU_SCRATCH inside my scratch)

| target | reading |
|---|---|
| BASE 832ba6a (rev arg) | `C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:…×10)` — matches the plan's stated BASE reading |
| candF tree (--tree, epoch-F archive) | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| 9cbe9d5f (rev arg) | `value=10 present=10 replayed=10 gate=1 guard=1` |
| d362318 / 5d9a157 / 42070de (rev args, epoch-F counter) | FAIL — old gate pin (matches L1's stated epoch readings) |

Gate on candF: `python3 -I -B corpus/recheck-replay.py --root <candF>` → 10× `MATCH …` + `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`, rc=0. `--selftest` → `RECHECK_REPLAY_SELFTEST: PASS (20 cases)`, rc=0. (Epoch-A gate b7782f35…: CLEAN + PASS (13 cases) — inherited attempt-1 instrument re-verified.)

## 3. Independent controls re-runs (frozen plans/round-56-controls.sh, REFTREE = lane worktree, my scratch)

| epoch | result | wall |
|---|---|---|
| A (42070de) | `CONTROLS: match=12 mismatch=0` rc=0 | 81.6s |
| B (5d9a157) | `match=16 mismatch=0` rc=0 | 118s |
| C (711e6393) | `match=20 mismatch=0` rc=0 | 40s |
| D (d362318) | `match=21 mismatch=0` rc=0 | 55s |
| E (dd31b786) | `match=22 mismatch=0` rc=0 | 34s |
| F (9cbe9d5f) | `match=23 mismatch=0` rc=0 | 38s |

All reproduce L1's receipts (controls-prefreeze{,-epochB,-epochC,-epochD,-epochE}.txt; epoch-F receipt seen at controls-prefreeze-epochF.txt). Zero mismatches at every epoch.

## 4. Mutation attacks on sandbox copies (my probes; cp -a of the epoch tree, single-field forgeries)

**Epoch-A finding trail (the harm evidence that drove B→F):**
- M-d2 python-native printer gate (emits the 10 exact MATCH lines + CLEAN + `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`): **value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)** — r5 was forgeable at epoch-A. The frozen F5 control's `got=FAIL` was an interpreter artifact (bash printer run under `python3 -I -B`), not tamper-evidence. **Closed at epoch-B**: GATE_SHA256_PIN → same probe reads `value=0 present=10 replayed=0 gate=0 guard=1` (bad=r5-gate×10); still FAIL at C/D/E/F (printer probe re-run at each epoch).
- M-c metadata-only manifest edit (fetched `2026-11-07→2026-10-01`, http_status `200→500`): **value=10 NOT caught at A and B** (adjacent to the named hand-written-capture ceiling). **Closed at epoch-C** (fetched-ISO/2xx/bijection): reads value=0, bad=r2-manifest-malformed×10, at C/D/E/F.
- M-h case-variant column-0 headers (`Http/2 200\r\nSet-Cookie: x=1\r\n\r\n` prepended to S057.body, manifest digest updated): caught at D/E/F (`value=0`) — epoch-C would have passed it (R56MutCounter F9 / R56ReviewCounter G1 finding; my probe confirms the fix works).
- M-i calendar-invalid `fetched=2026-13-40` (shape-valid): caught at F (`value=0`) — the R56MutCounter-2 m31 fix (fromisoformat) confirmed.
- M-a duplicate manifest URL row (S055 line duplicated): caught at every epoch (A: r2-rows2 + gate manifest-duplicate-url SETUP; F: r2-manifest-malformed).
- M-b registry URL removed from S054's SOURCES row (URL kept only in manifest): caught at every epoch (r2-registry / r5-gate url-not-in-row).

Net: **no surviving hole in my attack set at epoch-F.** Receipts for every probe in R56ExecHarm.d/.

## 5. Assigned census / quote-locate / claims-declared / stamps / SOURCES

- Census: `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → rc=0, `kagi ok`, **19 W04** duplicate-url warnings — id-for-id identical to L1's census-start.txt receipt. No new warnings.
- quote-locate: `python3 -I -B corpus/quote-locate.py` at BASE snapshot and cand snapshot → `QUOTE_LOCATE: CLEAN located=12 rows=12` rc=0 both — unchanged by the round-56 files.
- claims-declared: `bash corpus/claims-declared.sh --root <tree>` → CLEAN **claims=36** at BASE and at all pre-landing epochs (round 56 undeclared pre-freeze, as expected); at landing candF → CLEAN **claims=37** with row `56<TAB>C1<TAB>freshness` (rc=0).
- SOURCES rows / source-fetches: byte-identical BASE ↔ 42070de ↔ 5d9a157 ↔ 711e6393 ↔ d362318 (git blob sha equality measured per file per epoch: SOURCES.md 6a25a13b…, source-fetches.tsv 121e4549…, claim-ledger.tsv 1f852f14…, claims-declared.tsv 844ab3c5…, stamps.tsv 7b610652…, quote-bodies.tsv 8f06d64f…). The landing commit bcf07e7 then edits SOURCES.md/source-fetches.tsv/claims-declared.tsv — that is the declared landing surface (S113 receipt correction, S070/S074/S057 provenance attestations), not a mid-audit drift.

## 6. Full ledger verify in clone, time-bounded — inherited vs change

Command: `cd <scratch clone> && timeout <n> bash corpus/claim-ledger.sh verify` (per-row timeouts from the ledger; one live clone, three runs):

- **BASE 832ba6a** (386s): FAIL = {R11-08 exit=1, R25-02 exit=2, R36-01 verdict-not-final exit=0}; POLICY = {R29-01, R29-02 first-token:python; R38-03 python-script}; HOST-SKIP 13 (host-row-not-authorized); MISSING-ID **57**; LABELED-ID 26; `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`. **The six preserve-ids (R11-08, R25-02, R36-01, R29-01, R29-02, R38-03) are exactly the BASE red set — preserved.**
- **42070de (epoch-A)** (~1068s, run under triple-verify CPU contention): same set **plus R33-01/R34-01/R34-02 FAIL (exit=2)**. Flake adjudication at tip, quiet: `bash corpus/prefreeze-control.sh --selftest` → rc=0 `PREFREEZE_SELFTEST: PASS (25 cases)`; `bash corpus/self-description-sweep.sh --selftest` → rc=0 `SELFTEST: PASS (10 cases)` — both pass their pinned lines, so those three reds were **load artifacts, not candidate regressions**. R11-08/R36-01 flip between timeout and exit-mismatch/verdict-not-final across runs — inherited instability of slow rows, not change (id-level verdict FAIL stable everywhere).
- **TIP c90e6709** (384s): **STALE ×6** — corpus/knowledge/cdp-bridge-1password-oidc-workflow.md (bf6052bc→d16ae5a5), corpus/source-fetches.tsv (3ec6135d→e40274c9), corpus/SOURCES.md (fa69564f→388e39fa), LOG.md (45ea4a71→dfb38c5e), SCORECARD.md (5d7ec54f→990254ae), SKILL.md (e6a74ade→f0be6dd6). **NEW FAIL ×4**: R13-01 (`grep -c '^## Round ' SCORECARD.md` pinned `^73$` — landing added the round-56 heading), R24-06 (`row-identity.sh scorecard-rounds`, pinned count=73+sha), R22-03 (`revision-audit.py --history c2cab35b…` exit=1), R24-15 (`row-identity.sh revision-added`, pinned count=62+sha). Inherited reds unchanged (R11-08 exit=1, R25-02 exit=2, R36-01, POLICY R29-01/02, R38-03); R33-01/R34-01/R34-02 pass; MISSING-ID 57 with identical token set (line refs shifted: SCORECARD 1355→1358, 1455→1458; SKILL 659→660); `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`. **No `.ufo/waves/round-56/expectation-migrations.json` at the tip** — the R13-01/R22-03/R24-06/R24-15 migration + restamp reconciliation is outstanding post-landing work (same class as round-38 M38-6; L1's to land, reported not patched).
- classify: **inherited** = R11-08, R25-02, R36-01, R29-01, R29-02, R38-03 (present at BASE); **change (landing cost)** = STALE×6 + R13-01/R22-03/R24-06/R24-15; **flake** = R33-01/R34-01/R34-02 at 42070de only.
- Note: claim-ledger.tsv is still 86 rows / no R56 row at the tip — C1's own ledger row lands with the post-landing reconciliation; claims-declared.tsv already carries `56 C1 freshness`.

## 7. Current files unstamped from L1 edits (reported, not patched)

Full receipt: `R56ExecHarm.d/unstamped-current.txt`. Observed at HEAD d362318, ~08:12 -03: 125 stamp rows, 119 match, **6 worktree-edited unstamped files** (` M` in git status; exact stamped/live sha256 pairs in the receipt) — subsequently committed by bcf07e7 and reading **STALE at the tip** (§6). Additionally the whole round-56 instrument set (gate, manifest, three plans, 7 captures, fetch-receipt, rejections/, controls receipts, wave bookkeeping) is absent from stamps.tsv (0 of 125 rows match round-56|recheck) — expected until the restamp commit.

## 8. Prior six FAIL/POLICY ids — preserved

R11-08, R25-02, R36-01 (FAIL) and R29-01, R29-02, R38-03 (POLICY) are present with inherited verdicts at BASE, 42070de and the landing tip; the round-56 work introduced **no new red id** beyond the landing-drift class of §6 and removed none.

## 9. Environment and operational notes

- Tool identity: `grep` on PATH is **pi-uu-grep 0.2.0** (a shim, not GNU grep; `command -v grep` → bare `grep`) — all counter r4/gate replays and selftest BRE semantics verified under it (10/10 MATCH incl. the `need.e` BRE case). python3 3.14.8 (/usr/bin/python3), pdftotext 26.10.0, git 2.56.0. No tools installed; RULES.md install gate not triggered.
- Scratch collisions: my seat dir was reset at 07:30 by R56ExecHarm-2's setup (declared, apologized, coordinated); later "disappearances" of w1exec were transient stale-view episodes of the shell/file layer, not deletions — all receipts were exported to R56ExecHarm.d/ immediately after each run (72 files). KagiR56 was rate-limited (429, retry-after ~4.3 days) for the collision question; KagiR56a3's broadcasts supplied every epoch re-anchor.
- Cleanup before yield: I delete my `w1exec/` and `R56ExecHarm.probe` only; R56ExecHarm-2's dirs (base/, cand/, candB/, fbase/, fcand/, logs/) are theirs.

## Verdict

BASE vs candidate harm evidence is complete. BASE reads `value=0 present=10 replayed=0 gate=0 guard=1`; the epoch-F candidate and the landing tip read `value=10 … guard=1` with gate CLEAN, selftest PASS(20), controls 23/23 (independently reproduced at six epochs), and every mutation in my attack set (printer gate, metadata, calendar-invalid fetched, case-variant headers, duplicate row, registry unbinding) fail-closed. The only reds the round adds are the standard landing-drift set (6 STALE stamps + R13-01/R22-03/R24-06/R24-15) awaiting L1's migration/restamp commit, plus the preserved inherited reds.

### Report trailer
- build/R56ExecHarm.md (this file)
- build/R56ExecHarm.d/c1-base.out — counter @BASE, epoch-A counter, rc=0
- build/R56ExecHarm.d/c1-cand.out — counter @cand tree, epoch-A, rc=0, value=10
- build/R56ExecHarm.d/gate-cand.out, selftest-cand.out — epoch-A gate run + selftest
- build/R56ExecHarm.d/quote-base.out, quote-cand.out — QUOTE_LOCATE: CLEAN located=12 rows=12 both
- build/R56ExecHarm.d/declared-base.out, declared-cand.out — CLAIMS_DECLARED: CLEAN (claims=36) both
- build/R56ExecHarm.d/census-live.out — rc=0, 19 W04, kagi ok
- build/R56ExecHarm.d/controls-rerun.out — epoch-A controls 12/12 MATCH
- build/R56ExecHarm.d/mut-a-duplicate-row.out, mut-b-registry-url.out, mut-c-metadata-only.out, mut-d2-python-printer.out — epoch-A probes (M-c and M-d2 are the epoch-A findings)
- build/R56ExecHarm.d/c1-candB.out, c1-base-epB.out, c1-epA-epB.out, gate-candB.out, selftest-candB.out — epoch-B matrix
- build/R56ExecHarm.d/mut-d2B-python-printer.out, mut-aB-duplicate-row.out, mut-bB-registry-url.out, mut-cB-metadata-only.out — epoch-B probes (pin closes M-d2)
- build/R56ExecHarm.d/controls-rerun-epB.out — 16/16
- build/R56ExecHarm.d/c1-candC.out, c1-base-epC.out, c1-epA-epB.out (epoch-C counter), gate-candC.out, selftest-candC.out, mut-cC-metadata-only.out, mut-aC-duplicate-row.out, mut-bC-registry-url.out, mut-d2C-python-printer.out, controls-rerun-epC.out — epoch-C set (M-c closed)
- build/R56ExecHarm.d/c1-candD.out, c1-epD-rev.out, c1-epC-revDcounter.out, gate-candD.out, selftest-candD.out, mut-hD-case-headers.out, mut-cD-metadata-only.out, mut-aD-duplicate-row.out, mut-bD-registry-url.out, mut-d2D-python-printer.out, controls-rerun-epD.out — epoch-D set (case-headers closed)
- build/R56ExecHarm.d/c1-candE.out, c1-epE-rev.out, gate-candE.out, selftest-candE.out, mut-hE-case-headers.out, mut-cE-metadata-only.out, mut-aE-duplicate-row.out, mut-bE-registry-url.out, mut-d2E-python-printer.out, controls-rerun-epE.out — epoch-E set
- build/R56ExecHarm.d/c1-candF.out, c1-epF-rev.out, gate-candF.out, selftest-candF.out, mut-iF-calendar-invalid-fetched.out, mut-hF-case-headers.out, mut-cF-metadata-only.out, mut-aF-duplicate-row.out, mut-bF-registry-url.out, controls-rerun-epF.out, declared-candF.out — epoch-F/landing set
- build/R56ExecHarm.d/verify-base.out — full ledger verify @832ba6a (386s)
- build/R56ExecHarm.d/verify-cand.out — full ledger verify @42070de (epoch-A; R33/R34 load-flakes)
- build/R56ExecHarm.d/verify-tip.out — full ledger verify @c90e6709 (STALE×6, R13-01/R22-03/R24-06/R24-15)
- build/R56ExecHarm.d/flake-r33.out, flake-r34a.out — quiet re-runs passing pinned lines at tip
- build/R56ExecHarm.d/unstamped-current.txt — unstamped report with exact sha pairs
