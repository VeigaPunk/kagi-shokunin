# kagi-shokunin — secrets and vault hygiene

The question this lane answers is how credential-hygiene evidence and the-janitor flows are checked without copying a secret value into a durable artifact (`SKILL.md`, `PROVINCE.md`).

**Rank:** `SKILL.md` frontmatter says `Rank: shonen`. `SHONEN.md` boxes are `[x]`, each with named reviewers (`KagiR9Reviewer`, `KagiR10Reviewer`, `R11Reviewer`, and the round-11 seats named in that file). The file is still titled a promotion checklist. This README does not call that a promotion above shonen.

## Owns / refuses

Owns the domain knowledge, playbooks, error patterns, and checklists for secrets and vault ops (`PROVINCE.md`). The hard rule in `SKILL.md` is: never print, copy, or exfiltrate a secret value, session token, cookie, or vault field. Reference paths are internal metadata and are not pasted into a report, commit, handoff, or corpus entry.

Refuses anything outside that domain, including vault-side structure (which vaults, items, or fields exist). Mapping that structure would put reference paths in a durable artifact. `op` item-level reads stay unexercised. The CDP lease and profile-ownership question is reported, not adjudicated here (`PROVINCE.md`).

## Start here

`PROVINCE.md` records a round-18 erratum: the janitor substrate was measured absent on the host (no `the-janitor`, no `~/.config/the-janitor`, no `~/.local/state/the-janitor`, no `tac-check`, no musketeer profile). The surface list below that erratum is historical. A live census may `DRIFT` while the substrate is gone.

The declaration gate, from `PROVINCE.md`:

```sh
bash corpus/surface-census.sh
```

That compare is read-only against `corpus/surface-census.tsv` and `corpus/state-shape.tsv`. Do not point it at secret material, and do not treat a green edit of a TSV as a fix (`SKILL.md`). `--selftest` is the hermetic case suite (16 cases in the province gates paragraph). `--verbs` and `--deep` are separate; `--deep` is operator-present and is not the start command.

Other gates named in `PROVINCE.md`, all in `corpus/`: `drift-pins.sh`, `transcript-scan.sh`, `op-ref-probe.sh`, `checklist-run.sh`, `scope-gate.sh`, `claim-ledger.sh`. Read each header before a live run. This page does not repeat reference paths or vault recipes.

## How to read the corpus

`corpus/README.md` is the index. It is line-cited (`corpus/knowledge/adjacency-scope.md`, `corpus/knowledge/claim-ledger.md`, lessons). It was not reflowed. The round-18 substrate absence is the erratum in `PROVINCE.md`, not a rewrite of the historical index rows.

## Map

| Path | What it is |
|---|---|
| `PROVINCE.md` | Boundary, historical surfaces, gate list, round-18 absence |
| `SKILL.md` | Decision table and the hard rule on secret values |
| `SHONEN.md` | Checklist boxes checked by named reviewers |
| `LOG.md` | Append-only record |
| `SCORECARD.md` | Axis verdicts |
| `AGENTS.md` | Operating rules |
| `corpus/` | Gates (`*.sh`), TSVs, `knowledge/`, `lessons/` |
| `plans/` | Round plans |
| `.ufo/` | Round machinery |

## Neighbors

kake holds the contested CDP lease and musketeer profile question. kotoba overlaps `~/.agents/AGENTS.md`. kumitate, kotoba, kengaku, and kasegi verifiers are mapped as siblings in `SHONEN.md`, not absorbed. Report cross-domain evidence; do not absorb it (`PROVINCE.md`).

Fleet protocol: [VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).
