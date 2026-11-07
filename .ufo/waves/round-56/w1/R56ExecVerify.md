# R56ExecVerify — independent end-to-end verification of the frozen C1 claim

Seat: R56ExecVerify (executor, verify). Round: kagi 56 attempt 3. Date: 2026-11-07 (runs 10:32:17Z–10:32:32Z; archive legs within the same minute).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, HEAD `42070de7770e1558adcf6aa7a7bc59309a9654d7` (= the predeclaration/frozen commit; `git rev-parse HEAD`, rc=0). BASE `832ba6a53d6a76706b5c80bce2278683dea33d42` verified `commit` via `git cat-file -t` (rc=0, both revisions).
Observed answering model: no runtime model identifier was observable from my environment (`env` shows only `AGENT=1`, `OMPCODE=1`; no model variable). Harness-declared project context states `zai/glm-5.3-flashx`; reported as declared context, not independently observed.
Scratch used during run: `/fast/scratch/hyaku/kagi-r56/R56ExecVerify` — deleted after this report (rc=0, verified absent). No clone made (only read-only `git archive`/`show` against the lane repo); the GIT_DIR override below reads lane objects without mutation. Raw receipts: `.ufo/waves/round-56/w1/R56ExecVerify.d/` (15 files).

## Instrument hashes (working tree; `sha256sum`, rc=0)

```
096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a  plans/round-56-c1.sh
b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8  corpus/recheck-replay.py
df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762  corpus/recheck-captures.tsv
```

## Assigned command receipts (cwd = lane; wall via `time.monotonic()`)

| # | Command | rc | Wall | Full last line |
|---|---------|----|------|----------------|
| 1 | `bash plans/round-56-c1.sh 832ba6a53d6a76706b5c80bce2278683dea33d42` | 0 | 1.512s | `C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest:betterleaks-detection-vs-validation.md:README.md,r2-manifest:cdp-bridge-1password-oidc-workflow.md:custom-workflow,r2-manifest:iso-11770-3-edition-status.md:60237.html,r2-manifest:iso-11770-3-edition-status.md:82709.html,r2-manifest:iso-11770-3-edition-status.md:85929.html,r2-manifest:nist-key-management-guidance-status.md:ipd,r2-manifest:nist-key-management-parts-withdrawal.md:nistspecialpublication800-57p2.pdf,r2-manifest:oidc-federation-trust-policy.md:openid-connect-core-1_0.html,r2-manifest:secret-scanning-detection-vs-validation.md:README.md,r2-manifest:trufflehog-verification-lifecycle.md:verification-caching)` |
| 2 | `bash plans/round-56-c1.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin` | 0 | 9.131s | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| 3 | `python3 corpus/recheck-replay.py --root /home/vgpnk/Projects/shokunin/kagi-shokunin` | 0 | 1.260s | `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` |
| 4 | `python3 corpus/recheck-replay.py --selftest` | 0 | 3.150s | `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` |

All four match the frozen expectations: BASE value=0, tree value=10, CLEAN clocks=10, selftest PASS 13. Note the BASE bad-list is exactly the expected `r2-manifest` for all 10 clocks (BASE predates `corpus/recheck-captures.tsv`), with `present=10 guard=1` — the counter's guard predicate holds at BASE while the value reads 0, i.e. the 0→10 delta is carried by the manifest+captures, as declared.

Gate verdict detail (cmd 3, full stdout in `R56ExecVerify.d/gate_root.out`): 10 MATCH lines, one per clock, e.g.
`MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S113 form=grep stated=3 replayed=3`; forms cover all three filter shapes — grep ×8, pdf ×1 (S078), locate ×1 (S070). Manifest `corpus/recheck-captures.tsv` carries exactly 10 data rows (S101, S113, S114, S054, S055, S057, S067, S070, S074, S078), one per URL.

## Archive-rev reading (frozen bytes reproduce 10)

`git -C <lane> archive 42070de7770e1558adcf6aa7a7bc59309a9654d7 | tar -x -C <scratch>/predecl` (rc=0). Extracted instrument hashes are byte-identical to the working tree (same three SHA256s as above; `sha256sums.txt` receipt) — the working tree at HEAD is exactly the frozen bytes. All 10 capture bodies plus fetch receipts are present in the archive (round-56/capture ×7, round-55/capture S113/S114, round-45/controls/capture-r45/S101.raw).

Two compositions, both rc=0:

| Composition | Command shape | rc | Wall | Last line |
|---|---|---|---|---|
| Archived counter → archived tree | `bash <scratch>/predecl/plans/round-56-c1.sh --tree <scratch>/predecl` with `GIT_DIR=<lane>/.git` (counter's `git -C $REPO show BASE:corpus/rendered-text-v1.py` needs a repo; GIT_DIR reads lane objects read-only, no mutation) | 0 | 6.228s | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| Lane counter → archived tree | `bash <lane>/plans/round-56-c1.sh --tree <scratch>/predecl` | 0 | 6.891s | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |

The frozen counter bytes and the frozen tree reproduce value=10 independently of each other and of the working tree.

## Working-tree scope check

`git status --porcelain` (rc=0) shows 19 dirty paths, all wave-orchestration scaffolding under `.ufo/waves/round-56/` (deleted: build-dispatch.json, build-spec.json, build.ready, build/swarm-registry.json; untracked: attempt1-build/, build/*.d receipts, w1*, w1/). No measured input (`corpus/**`, `plans/**`, any capture body) is modified — consistent with the hash equality above. I changed none of them.

## Environment (receipt `versions.txt`)

bash 5.3.20(1)-release · git 2.56.0 · python3 3.14.8 · grep = `pi-uu-grep` 0.2.0 (host `grep` is a pi shim; it reproduced all BRE clocks) · pdftotext 26.10.0 · GNU tar 1.35.

## Verdict

Independent end-to-end reproduction PASSES on this host today: value=0 at BASE, value=10 on the tree, gate CLEAN 10/10 with all three filter forms, selftest PASS 13, frozen archive bytes reproduce 10 under both counter/tree compositions. C1_REPLAY claim verified as stated (0→10, guard=1).

## Ceilings and non-blocking observations

- Per the frozen instruments' own doctrine: committed bytes only. A MATCH proves the statement true of the capture, not of the live page; the live re-fetch leg is a separate seat and I did not run it.
- The `recheck-replay.py` header-refusal (no `HTTP/` first line, no `set-cookie:` line) is enforced on the manifest `body_path` files, and all 10 bodies pass. Non-blocking: `S113.headers`/`S113.meta` sidecars sit beside `S113.body` in `.ufo/waves/round-55/capture/` (committed round-55 provenance); the gate consumes only `body_path`, so this does not touch the predicate.
- Run environment notes the host `grep` is `pi-uu-grep` 0.2.0 rather than GNU grep; all grep-form clocks replayed true under it, so no impact observed.

## Files

- Report: `.ufo/waves/round-56/w1/R56ExecVerify.md` (this file)
- Receipts: `.ufo/waves/round-56/w1/R56ExecVerify.d/{c1_base,c1_tree,gate_root,gate_self}.{out,err}, arch_counter_on_arch_tree.out, lane_counter_on_arch_tree.out, receipts.json, arch-receipts.json, sha256sums.txt, versions.txt, run-meta.txt`
- Scratch `/fast/scratch/hyaku/kagi-r56/R56ExecVerify`: deleted after receipts were copied out (verified absent).
