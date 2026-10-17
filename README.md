# kagi-shokunin

Secrets and vault operations: the-janitor handler flows, credential-hygiene
evidence, and the gates that keep a secret value out of the record.

Rank: **shonen**. [`SHONEN.md`](SHONEN.md) records four boxes a non-author
reviewer has checked, with the round evidence under each box. Promotion
is that file's state, not a claim this README adds.

Fleet: [shokunin](https://github.com/VeigaPunk/shokunin).

## The question

> What is the shape of this credential surface, and which check proves the
> hygiene claim without ever reading the secret?

Hard rule, from `SKILL.md`: never print, copy, or exfiltrate a secret
value, session token, cookie, or vault field. A reference path (`op://…`)
may appear in a plan. It does not go into a report, a commit, a handoff,
or a corpus entry.

## Boundary

**Owns:** handler flows, env-file reference discipline, evidence receipts,
surface census, drift pins, and the claim ledger over this lane's own
declarations.

**Hands off:** vault-side structure (which vaults, items, and fields
exist) stays unmapped. `op` item-level reads stay unexercised. The CDP
lease and profile ownership question is reported to the integrator.

`PROVINCE.md` records that the janitor substrate was measured absent on
the round-18 host. The surface declaration is kept as history. Live gates
fail closed while it is gone. Reinstalling the substrate is what makes
the pins re-verifiable.

## Gates

All of these live under `corpus/` and refuse to resolve a real reference.
Read each script's header before trusting a verdict; the counts in
`PROVINCE.md` are stamped to the round that measured them.

| Script | Job |
|---|---|
| `corpus/surface-census.sh` | declared paths vs the host: mode, unlisted children, runtime shape |
| `corpus/drift-pins.sh` | byte, line, and symbol drift against the baseline |
| `corpus/transcript-scan.sh` | transcript-leak gate over the durable DB |
| `corpus/op-ref-probe.sh` | `op.env` contract: `refs` vs `op run`, on generated fixtures |
| `corpus/checklist-run.sh` | the `SKILL.md` hygiene checklist as executable rows |
| `corpus/scope-gate.sh` | ownership partition; breadth as counts, never child names |
| `corpus/claim-ledger.sh` | revision stamps, citations, scorecard cells, doc re-verification |

```sh
bash corpus/surface-census.sh --selftest
bash corpus/op-ref-probe.sh --selftest
```

## Map

| Path | What it is |
|---|---|
| [`SKILL.md`](SKILL.md) | the executable layer: decision table, failures, checklist |
| [`PROVINCE.md`](PROVINCE.md) | surfaces, gates, deliberate refusals |
| [`corpus/README.md`](corpus/README.md) | coverage index |
| [`corpus/knowledge/`](corpus/knowledge/) | sourced detail |
| [`LOG.md`](LOG.md), [`SCORECARD.md`](SCORECARD.md) | audit trail and axis verdicts |

A round is one axis-move, non-author verified, recorded in `LOG.md`.
