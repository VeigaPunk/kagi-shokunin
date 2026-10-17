# kagi-shokunin

**Secrets and vault ops — hygiene evidence and flows, never secret material.**

A **shokunin lane** minted and trained under the
[shokunin](https://github.com/VeigaPunk/shokunin) skill. Kagi owns the
janitor-handler surfaces, 1Password CLI `op` ref discipline, evidence
receipts, and the executable gates that prove those contracts.

**Wiki:** [lane overview](https://app.devin.ai/org/veigapunk/wiki/VeigaPunk/kagi-shokunin?branch=master)

## Hard rule

Never print, copy, or exfiltrate a secret value, session token, cookie,
or vault field. Ref *paths* (`op://…`) are internal metadata — usable in
a plan, never pasted into a durable artifact. `SKILL.md` is the
executable layer; `corpus/knowledge/` holds the sourced detail.

## Domain

Owned surfaces (historical declaration in `PROVINCE.md`; live gates fail
`DRIFT` / `SETUP` / `DEFECT` while the janitor substrate is absent on a
host — round-18 erratum):

- the-janitor CLI and its OpenCode overlay
- env-file ref contract (`op.env` — values never read into an artifact)
- transcript-leak and credential-hygiene checklists
- evidence/custody receipts (`tac-check`, shape-only state)
- ownership partition vs siblings (`corpus/adjacency.tsv`)

Vault-side structure (which vaults, items, or fields exist) stays
**unmapped**. Item-level `op` reads stay unexercised.

## In this repository

```
PROVINCE.md     surface census + gate inventory
SKILL.md        vault-ops decision table
SHONEN.md  SCORECARD.md  LOG.md
corpus/
  surface-census.sh     kind/mode + UNLISTED children
  drift-pins.sh         byte / line / symbol drift
  transcript-scan.sh    durable-DB leak gate
  op-ref-probe.sh       op.env contract (never resolves a ref)
  checklist-run.sh      SKILL.md checklist as executable rows
  scope-gate.sh         ownership partition + breadth pins
  claim-ledger.sh       calibration: verify / citations / cells / docs
```

## Run the gates

From this repository root (no `op` exec on the default path):

```bash
bash corpus/surface-census.sh --selftest
bash corpus/op-ref-probe.sh --selftest
bash corpus/checklist-run.sh --selftest
bash corpus/scope-gate.sh --selftest
bash corpus/claim-ledger.sh --selftest
```

`--deep` / operator-present probes that touch a live `op` are documented
in `PROVINCE.md` and are not the default.

## What it refuses

Anything outside secrets & vault ops. The CDP lease / chrome-profile
question is **contested with kake** and is reported, never adjudicated
here (`corpus/adjacency.tsv`). Endpoint identity is [kama](https://github.com/VeigaPunk/kama-shokunin).
Dispatch is [kumitate](https://github.com/VeigaPunk/kumitate-shokunin).

## How a lane learns

Append-only corpus; every claim separates observation / inference /
unknown; rounds are non-author-verified. See the fleet
[README](https://github.com/VeigaPunk/shokunin#readme).
