# S108 registry row — draft (11 columns, one line, no `|` inside a cell)

| S108 | Response wrapping — OpenBao docs — https://openbao.org/docs/concepts/response-wrapping/ | docs | A | OpenBao response wrapping: single-use wrapping tokens, wrap TTL separate from the secret, unauthenticated lookup reporting the creation path, rewrap, and creation-path validation that exposes a read-and-rewrap | §Overview (single use, wrap TTL, malfeasance detection), §Response-Wrapping token operations (lookup, rewrap), §Response-Wrapping token validation (creation-path check); OpenBao docs Version 2.7.x; fetched 2026-11-07 (decoded body, raw sha256 a555301e…f9cc32ed55, 37186 bytes) | A wrapped response is stored in the cubbyhole of a single-use token whose TTL is set per request and is separate from the wrapped secret's; `sys/wrapping/lookup` is unauthenticated and reveals the creation path, so a read-and-rewrap is detectable by an exact path check; rewrap moves the data to a new token and spends the old one. Measured by `corpus/openbao-wrap-trial.sh` (round 51). Quote: “only a single party can ever unwrap the token and see what's inside” (§Overview, malfeasance-detection bullet). | mined | 2026-11-07 | 180d | corpus/knowledge/vault-openbao-token-lease-lifecycle.md, corpus/lessons/round-51.md |

## Checks run on this row

- Cell count: `awk -F'|' '/^\| S108 /{print NF}'` → `13` (11 cells between 12 pipes).
- No `|` inside a cell: the row above is the whole line; the only pipes are the 12 delimiters.
- Enums (`kind` `docs`, `tier` `A`, `status` `mined`) are inside the census contract (`corpus/sources-census.sh` SC_ENUM list).
- `recheck 180d`: no release feed is bound to this URL, so `on-release` would leave it UNBOUND for R36-03 (the round-50 M50-4 harm).
- `used-by` paths: both must exist and carry `S108` (census SC_USEDBY_MISSING / SC_USEDBY_NOCITE / SC_ENTRY_CITE). The knowledge entry carries it in its `source:` line; the lesson must carry it in `## Gate` — this wave's census read is receipted in `receipts/census-candidate.txt` (`kagi E11 S108 missing used-by corpus/lessons/round-51.md`, rc 1 — the expected pre-landing state).

## What differs from the row currently in the working tree

The working-tree row (`.ufo/waves/round-51/build/…` wave state, `git diff corpus/SOURCES.md`) is sound except that its `scope` cell is a comma list where the draft names the section each mechanism comes from. No defect there.
