# kagi-shokunin

**Secrets and vault ops — hygiene evidence, never secret material.**

Kagi watches the-janitor flows, 1Password CLI `op` ref discipline, surface
census, and custody receipts. It answers "is this credential *path* and
this handler *shape* still the contract we pinned?" It never answers by
printing a secret.

This is a **shokunin lane** of the [shokunin fleet](https://github.com/VeigaPunk/shokunin).
Rank: **shonen**.

## Hard rule

Never print, copy, or exfiltrate a secret value, session token, cookie, or
vault field. `op://…` ref *paths* are internal metadata — usable in a plan,
never pasted into a durable artifact (report, commit, handoff, corpus
entry). Handle hygiene evidence and flows, not secret material.

Vault-side structure (which vaults, items, or fields exist) stays unmapped.
`op` item-level reads stay unexercised. See [`PROVINCE.md`](PROVINCE.md)
and [`SKILL.md`](SKILL.md).

## The craft

- Surface census of the janitor handler, its config dir, runtime-state
  *shape*, and TAC custody files — kind and mode, never content.
- Drift pins on declared files and symbols.
- Transcript-leak scan over the durable OpenCode DB.
- `op.env` two-parser contract: what `the-janitor refs` lists vs what
  `op run --env-file` actually loads. The gate never resolves a reference.
- Credential-hygiene checklist as executable rows (`corpus/checklist.tsv`).
- Ownership partition vs sibling lanes (`corpus/adjacency.tsv`,
  `corpus/scope-gate.sh`).
- Claim ledger: revision stamps, citations, scorecard cells, re-verification
  declarations.

Round-18 record: the janitor substrate was measured **absent** on the host
that last re-censused this lane. Pins in `PROVINCE.md` are historical; live
gates correctly fail `DRIFT` / `SETUP` / `DEFECT` while it is gone.
`claim-ledger` defers substrate-tagged rows. Unblock is a reinstall, then
every pin is re-verifiable in one run. See
`corpus/knowledge/substrate-deferral.md`.

## Province

Owns: secrets & vault ops — the-janitor flows, credential hygiene evidence.

**Refuses:** mapping vault contents; resolving refs into artifacts; starting
the handler from a gate; adjudicating the contested CDP / musketeer Chrome
profile (reported as contested with kake, never absorbed). Anything outside
this domain is reported to the integrator.

## What's in this repository

```
kagi-shokunin/
├── SKILL.md              decision tables for handler verbs, refs, masking, gates
├── PROVINCE.md           surface list (historical pins) + refusals
├── SHONEN.md             promotion checklist
├── LOG.md                append-only trail
├── SCORECARD.md          per-axis verdicts
├── AGENTS.md             operating rules
├── plans/                round plans
└── corpus/
    ├── surface-census.sh / surface-census.tsv / state-shape.tsv
    ├── drift-pins.sh / drift-baseline.tsv / drift-symbols.tsv
    ├── transcript-scan.sh
    ├── op-ref-probe.sh
    ├── checklist-run.sh / checklist.tsv
    ├── scope-gate.sh / adjacency.tsv
    ├── claim-ledger.sh
    ├── knowledge/        sourced notes
    └── lessons/          per-round lessons
```

## Start here

From this repo root. These gates are shaped to refuse real `op.env` and
never start the handler:

```sh
bash corpus/surface-census.sh --selftest
bash corpus/op-ref-probe.sh --selftest
bash corpus/checklist-run.sh --selftest
bash corpus/scope-gate.sh --selftest
bash corpus/claim-ledger.sh --selftest
```

`--selftest` proves the gate on scratch fixtures. A live `verify` against
the host will `DRIFT` / `SETUP` while the janitor substrate is absent —
that is the correct answer, not a broken script.

`SKILL.md` is the executable playbook. If a command would need a secret
to "go green", it is out of province.

## How a round works

One axis-move. Evidence or it didn't happen. Lane identity:
`kagi-shokunin <kagi@shokunin.local>`.

## Fleet

[VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin) ·
[kimi-shokunin](https://github.com/VeigaPunk/kimi-shokunin)
