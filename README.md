# kagi-shokunin

Secrets and vault operations — credential hygiene with the values left
unread.

Kagi's question is whether the janitor handler, its pins, and its
checklists still match the declaration. The lane measures modes, shapes,
citations, and command contracts. It does not map which vault items exist,
and it does not resolve a 1Password reference.

Rank: **shonen**. `SHONEN.md` is still here. Registered in the fleet
`MANIFEST.json` roster since 2026-09-28.

## Province

**Owns.** The janitor flows and the credential-hygiene evidence around
them: surface census, byte and symbol drift, transcript-leak shape,
`op.env` contract probes, the checklist as executable rows, the ownership
partition, and the claim ledger.

**Hands off.** Vault-side structure (which vaults, items, and fields
exist). `op` item-level reads. The CDP lease and profile-ownership
question, which is reported to the integrator. Anything outside secrets
and vault ops.

`PROVINCE.md` records the surface list and a round-18 erratum: on the host
where that erratum was measured, the janitor substrate was absent. The
declaration is kept as history. Live gates are expected to fail closed
while it stays gone. `corpus/knowledge/substrate-deferral.md` is the
deferral record.

## Start here

1. `PROVINCE.md` — surfaces, gates, and the deliberate refusals.
2. `SKILL.md` — decision table, failure texts, hygiene checklist.
3. `corpus/README.md` — the coverage map.
4. The gates below. Each one has a `--selftest` that builds a scratch tree.
5. `SCORECARD.md` — every cell names an evidence pointer. `LOG.md` is
   append-only.

## The gates

All of these live under `corpus/` and are read-only toward the real
handler. `--selftest` is the hermetic proof.

| Script | Question it answers |
|---|---|
| `surface-census.sh` | Does every declared path still have the declared kind and mode? |
| `drift-pins.sh` | Have the pinned bytes, lines, or symbols moved? |
| `transcript-scan.sh` | Does the durable transcript DB leak secret-shaped content? Counts only. |
| `op-ref-probe.sh` | Does the `op.env` contract hold on generated fixtures, without resolving a reference? |
| `checklist-run.sh` | Does every `SKILL.md` checklist item have exactly one runnable or by-hand row? |
| `scope-gate.sh` | Is the ownership partition intact, and are shared directories within their breadth pins? |
| `claim-ledger.sh` | Do scorecard cells, citations, and knowledge re-verification stamps still resolve? |

```sh
bash corpus/surface-census.sh --selftest
bash corpus/claim-ledger.sh --selftest
```

Exit 0 / 1 / 2 is the gate's own map (clean, defect, policy or setup).
Read the script header before treating a live exit as a domain emergency:
a missing substrate is a named deferral, and several gates are specified
to fail closed on it.

## How to read a score

A score is the strength of a verifiable claim about this repository. The
scorecard names its ceilings in the same cell. An unqualified high score
is the calibration failure the file exists to prevent.

## Fleet

Minted under [shokunin](https://github.com/VeigaPunk/shokunin).
