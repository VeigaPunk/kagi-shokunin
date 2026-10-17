# kagi-shokunin — secrets & vault ops

**Handle hygiene evidence and flows. Never handle secret material.**

This is a [shokunin](https://github.com/VeigaPunk/shokunin) lane for the
janitor substrate, 1Password CLI `op` ref discipline, evidence receipts,
and credential-hygiene checklists. Rank: shonen.

The hard rule is load-bearing: never print, copy, or exfiltrate a secret
value, session token, cookie, or vault field. Ref *paths* (`op://…`) are
internal metadata — usable in a plan, never pasted into a durable
artifact. Vault-side structure (which vaults, items, or fields exist)
stays unmapped. Mapping it would put ref paths in a durable record.

## Province

**Owns:** the-janitor handler surfaces (shape and verbs, not values);
`op` env-file ref contract; transcript-leak scanning over the durable
DB; credential-hygiene checklist as executable rows; ownership partition
against adjacent lanes; the claim ledger that stamps every scorecard
cell to live evidence.

**Refuses:** anything outside secrets & vault ops. Report cross-domain
evidence back to the orchestrator. The CDP lease / Chrome-profile
question is contested with kake and is declared presence-only
(`corpus/adjacency.tsv`) — drifting that directory to an exact mode pin
is `OVERCLAIM`.

Host fact, recorded 2026-10-14 (`PROVINCE.md` round-18 erratum): the
janitor substrate was measured **absent** on the training host. Live
gates correctly fail `DRIFT` / `SETUP` / `DEFECT` while it is gone;
`claim-ledger` defers substrate-tagged rows. Unblock is reinstall, after
which every pin is re-verifiable in one run. The surface declaration is
preserved as the record of what the substrate was.

Full boundary and surface census: [`PROVINCE.md`](PROVINCE.md).

## Start here

1. [`SKILL.md`](SKILL.md) — vault-ops decision table and the never-print rule.
2. [`PROVINCE.md`](PROVINCE.md) — surfaces, gates, deliberate refusals.
3. [`corpus/`](corpus/) — the executable gates and their TSV contracts.

## Gates

Every gate is fail-closed, self-testing, and shape-only toward secrets.

| Gate | What it proves |
|---|---|
| `corpus/surface-census.sh` | Declared assets and runtime shape; `UNLISTED` children of enumerable dirs |
| `corpus/drift-pins.sh` | Byte / line / symbol drift against `drift-baseline.tsv` |
| `corpus/transcript-scan.sh` | Transcript-leak gate over the durable DB |
| `corpus/op-ref-probe.sh` | `op.env` contract: `refs` vs `op run --env-file`, never resolving a reference |
| `corpus/checklist-run.sh` | SKILL.md hygiene items as runnable or by-hand rows |
| `corpus/scope-gate.sh` | Ownership partition + shared-directory breadth (no child names or bytes) |
| `corpus/claim-ledger.sh` | Calibration: revision stamps, claim rows, citations, scorecard cells |

```
bash corpus/surface-census.sh --selftest
bash corpus/op-ref-probe.sh --selftest
bash corpus/checklist-run.sh --selftest
bash corpus/scope-gate.sh --selftest
bash corpus/claim-ledger.sh --selftest
```

Typical exits: `0` clean, `1` drift / failed check, `2` policy or setup.
`--selftest` proves the gate on scratch fixtures and never starts the
handler, never reads `$CONFIG_DIR/op.env`, never resolves a reference.

## What's in the repo

```
kagi-shokunin/
├── SKILL.md          executable craft
├── PROVINCE.md       domain boundary (historical surfaces + live-gate status)
├── SHONEN.md         promotion checklist
├── LOG.md            append-only audit trail
├── SCORECARD.md      axis verdicts
├── AGENTS.md         operating rules
├── plans/            round plans
└── corpus/           gates, TSV contracts, knowledge/, lessons/
```

Protocol: append-only corpus; every claim separates observation /
inference / unknown; rounds are non-author-verified. See the fleet
[README](https://github.com/VeigaPunk/shokunin#readme) for how a lane
learns.
