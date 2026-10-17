# kagi-shokunin — 鍵

**Secrets and vault ops.** Prove credential hygiene, handler isolation,
and env-file ref discipline — without ever printing a secret.

A **shokunin lane**: an expert agent for one domain, minted and trained
under the [shokunin skill](https://github.com/VeigaPunk/shokunin).
Rank: **shonen**. Promotion is a named non-author review of
[`SHONEN.md`](SHONEN.md), never self-attestation.

This lane answers: *can we show that the janitor/vault path is the shape
we declared, and that nothing in this repo had to read a vault value to
say so?*

## Hard rule

Never print, copy, or exfiltrate a secret value, session token, cookie,
or vault field. `op://…` ref *paths* are internal metadata — usable in a
plan, never pasted into a durable artifact. Handle **evidence and
flows**, not secret material.

## Domain

From [`PROVINCE.md`](PROVINCE.md): the-janitor flows, 1Password CLI `op`
hygiene, TAC receipts, CDP bridge shape. Round-18 erratum: the janitor
substrate was measured **absent** on the recording host. The surface
list in `PROVINCE.md` is preserved as the record of what the substrate
was; live gates correctly fail `DRIFT` / `SETUP` / `DEFECT` while it is
gone. Unblock: reinstall the substrate.

Vault-side structure (which vaults/items/fields exist) stays **unmapped**
on purpose. Mapping it would put ref paths in a durable artifact.

CDP `9222` + the musketeer Chrome profile are **contested with kake** —
reported, never adjudicated here.

## What's here

| Path | Role |
|---|---|
| [`SKILL.md`](SKILL.md) | decision table for every janitor/`op` intent |
| [`PROVINCE.md`](PROVINCE.md) | surface census, refusals, gate inventory |
| [`corpus/surface-census.sh`](corpus/surface-census.sh) | declared-path / UNLISTED-child / runtime-shape gate |
| [`corpus/drift-pins.sh`](corpus/drift-pins.sh) | byte/line/symbol drift vs committed baselines |
| [`corpus/op-ref-probe.sh`](corpus/op-ref-probe.sh) | `refs` vs `op run` contract; never resolves a real ref |
| [`corpus/checklist-run.sh`](corpus/checklist-run.sh) | SKILL.md checklist as executable rows |
| [`corpus/scope-gate.sh`](corpus/scope-gate.sh) | ownership partition + count-only breadth |
| [`corpus/claim-ledger.sh`](corpus/claim-ledger.sh) | calibration: stamps, citations, scorecard cells |
| [`corpus/transcript-scan.sh`](corpus/transcript-scan.sh) | transcript-leak gate over the durable DB |
| [`SCORECARD.md`](SCORECARD.md) · [`LOG.md`](LOG.md) · [`SHONEN.md`](SHONEN.md) | axes, trail, promotion |

## The gates

Hermetic proofs (scratch trees only; no `op` against live vaults):

```sh
bash corpus/surface-census.sh --selftest
bash corpus/drift-pins.sh --selftest
bash corpus/op-ref-probe.sh --selftest
bash corpus/checklist-run.sh --selftest
bash corpus/scope-gate.sh --selftest
bash corpus/claim-ledger.sh --selftest
```

Live verify (shape-only; will `DRIFT`/`SETUP` while the substrate is
absent):

```sh
bash corpus/surface-census.sh
bash corpus/drift-pins.sh
```

`--verbs --deep` on the census is operator-present: it can raise the
1Password desktop prompt.

## How a lane learns

Append-only corpus; every claim separates observation / inference /
unknown; rounds are non-author-verified. See the fleet
[README](https://github.com/VeigaPunk/shokunin#readme).
