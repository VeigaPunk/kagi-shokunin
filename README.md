# kagi-shokunin

Secrets and vault operations: the-janitor flows, credential-hygiene
evidence, and the gates that notice when a declared surface drifts.

The lane handles **evidence and flows**. It does not print, copy, or
record a secret value, a session token, a cookie, or a vault field.
Reference paths (`op://…`) may appear in a plan. They do not go into a
report, a commit, a handoff, or a corpus entry. That rule is the first
paragraph of `SKILL.md`.

## The job

`PROVINCE.md` owns the domain knowledge, playbooks, error patterns, and
checklists for this surface: the janitor handler, its OpenCode overlay,
runtime state pinned by **shape** (mode, magic, floors) rather than
content, and the gates in `corpus/` that re-check the declaration.

It refuses everything outside that domain, including vault-side structure
(which vaults, items, and fields exist). Mapping those would put reference
paths into a durable artifact. `op` item-level reads stay unexercised.
The CDP lease and profile ownership question is reported to the
integrator, not decided here.

## Substrate status

The surface list in `PROVINCE.md` is the historical declaration. The
round-18 erratum (2026-10-14) records the janitor substrate as **absent
on the measured host**: no `the-janitor`, no `~/.config/the-janitor`, no
`~/.local/state/the-janitor`, no `tac-check`, no musketeer profile. The
declaration is kept verbatim so it can be re-verified in one run if the
substrate is reinstalled. Until then the live gates are expected to fail
closed (`DRIFT` / `SETUP` / `DEFECT`), and `claim-ledger` defers the
substrate-tagged rows (`corpus/knowledge/substrate-deferral.md`).

## Read this first

1. [`PROVINCE.md`](PROVINCE.md) — surfaces, the erratum, and the gate index.
2. [`SKILL.md`](SKILL.md) — the hard rule and the executable checklists.
3. [`corpus/README.md`](corpus/README.md) — what the corpus actually holds.

A live census is `corpus/surface-census.sh`. Read its header and the
province note before treating an exit code as news: on a host without
the substrate, failure is the honest result.

## On disk

| Path | Role |
|---|---|
| `SKILL.md` | Playbook. Secret values never enter it. |
| `PROVINCE.md` | Declared surfaces, refusals, and the gate catalog. |
| `corpus/` | Census, drift pins, transcript scan, `op` ref probe, checklist, scope gate, claim ledger. |
| `plans/` | Round plans. |
| `SHONEN.md` | Promotion checklist. Rank is shonen. |
| `LOG.md`, `SCORECARD.md` | Audit trail and axis verdicts. |

## Fleet

Protocol and roster: [shokunin](https://github.com/VeigaPunk/shokunin).
Roster id `kagi`, rank **shonen**. Adjacent lanes named by the province:
kake (the contested CDP profile), and any consumer-endpoint question,
which is reported rather than absorbed.
