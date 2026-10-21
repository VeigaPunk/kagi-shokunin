# Round 20 attempt — depth frontier measured; dispatch unavailable

source: `LOG.md` section “20 — interactive attempt blocked before specialist dispatch”; `SCORECARD.md` section “Round 20 — interactive attempt”; lane-local evidence at `kagi-shokunin/.ufo/round-20/inspection.json`, `kagi-shokunin/.ufo/round-20/local-checks.json` and `kagi-shokunin/.ufo/round-20/wave/validation.json`.
verified-at: 2026-10-15, documentary base `f4a8dd92674e95231c50f361e8c69eb00c7e713b` plus inherited uncommitted probe digest recorded below.
recheck: from the fleet root, run `node kagi-shokunin/.ufo/round-20/route-admission.mjs`; live op-only smoke and selftest commands below are bounded to generated/scratch inputs, not real env files.

## What was actually inherited

The highest recorded local round is 19. A later interrupted execution reused driver launch number 16; its historical-source errata are committed at `f4a8dd92674e95231c50f361e8c69eb00c7e713b`, with outcome bookkeeping still dirty at interactive entry. Preserve that history; do not treat either a reused launch number or a report's presence as a verified-round total. The inherited nine-seat batch does not satisfy this dispatch's 32-seat requirement.

The working-tree probe already contained an op-only `--dotenv-bytes` arm. Its SHA-256 at measurement was `0f1945e8d8a8fc56aaee256180cd7badde466bc8ac91503aa1e1853e79044f4c`. This attempt observed it but did not author, overwrite, admit or commit it. The ordinary handler-dependent gate and its op 2.35.0 historical claims are not re-verified by these observations.

## Byte frontier, narrowly observed

`op --version` returned `2.40.0`, exit 0. `bash corpus/op-ref-probe.sh --dotenv-bytes` returned six PASS rows (escaped-lf, trailing-lf, newline-only, single-literal, double-multiline, single-multiline), then the full verdict:

```text
OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)
```

Exit 0. The reviewed arm constructs plain-valued fixtures in a private scratch tree, runs with isolated HOME/XDG and an empty inherited environment, and captures file bytes before hex comparison. It neither consumes the real op.env nor calls the handler. `bash corpus/op-ref-probe.sh --selftest` returned `OP_REF_SELFTEST: PASS (36 cases)`, exit 0.

A separate generated shell substitution of `alpha` followed by two LFs emitted hex `61 6c 70 68 61`, exit 0; the LFs were lost. This is the concrete representation limit in the old `collect()` command-substitution path, not proof that every dotenv behavior or secret masking contract is now understood.

## Gate

Candidates considered:

- Byte-faithful newline observations on generated plain values: retain only as bounded investigation evidence, tied to op 2.40.0 and the inherited dirty implementation.
- Promote six PASS rows to “complete dotenv contract”, “handler works”, “masking verified” or “round complete”: reject; these claims exceed the measured path.
- Dispatch the rendered 32-scope wave on mid/fast/strong: reject before submission; these effective roles are not the operator-required aliases.
- Manufacture a receipt from a run/session name and a computed arbitrary task key: reject; schema validity would not supply authentic acceptance bindings.

Admitted knowledge entries: **none**. No implementation admitted. No outside spot-check occurred; neither author selftests nor a lane-dispatched reviewer would constitute the required non-author admit/reject agreement. QUALITY.md is currently absent process debt, not an invented quality bar.

The read-only canonical wave validator returned exit 0 with spawn=32, resume=0, total=32; all names and prompts are distinct, and the canonical renderer supplied the leading invocation. No native task call or registry persistence followed. Local admission returned:

```text
KAGI_ROUTE_ADMISSION: BLOCKED (roles=7 mismatched=7 missing_aliases=0 connector_fallback=missing dispatched=0)
```

Exit 2. Required effective roles: executor/scribe → @m_composer; critic/revenger/reviewer/sentinel → @m_grok; connector → @m_antigravity, with @m_zfl fallback. All seven currently use other aliases, and the connector fallback is empty. The explicitly requested scout → @m_grok binding is also missing. The operator/integrator, not this lane, owns the unblock.

## Results and limits

Depth, coverage, operability, freshness, calibration and adjacency: unchanged. Expansion, quality and discernment: unchanged. Verified-round increment is zero; this is not saturation, canonical judgment or three consecutive blocked rounds.

The original interactive TUI remained bound to kagi: the pane ancestry attestation identifies the original omp process under Sighting, kagi cwd, @m_sol and the same controlling tty for input/output. A mistaken helper launch is recorded separately in the inspection artifact; it was not a specialist batch and supplies no round credit.

Manual launch metadata supplies run/session/mission/pane identity, but no authentic taskKey, expected result/receipt path or prompt/config acceptance digests. No receipt was minted or validated, and Sighting was not completed. A successor must be a fresh authorized session after binding restoration; this session does not start another round. Missing MINT.md, inherited stamp/substrate debt and contested ownership remain named debt in the local report, not absorbed fixes.
