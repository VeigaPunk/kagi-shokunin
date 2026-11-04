# round-5 aggregator mirror — bare host-path citation & unclosed prerequisite (`SKILL.md`)

- **Repo:** `kagi-shokunin` (owner of the file cited below; the owning lane corrects `SKILL.md`).
- **Filed by:** kotoba round-5 report (2026-09-28), `kotoba-shokunin@4002b9f` §"Cross-domain observations to relay"; full audit artifact `kotoba-shokunin/corpus/knowledge/fleet-skill-audit-round5.md` (defect rows "kagi L53–54", "kagi L26").
- **Mirrored by:** aggregator round-5 (main-repo lane, `m_qwen`) per `PROTOCOL.md` integrator step 2 — "routes cross-domain defects a lane report filed against a sibling's files to the owning lane — the aggregator mirrors each routed defect into the owning repo's `corpus/lessons/` (aggregator-owned naming)". Aggregator-owned file; never edited in place by the lane (`CORPUS.md` corrections rule).
- **Pointer provenance:** kotoba's line refs match kagi's *round-3* blob exactly (`git -C kagi-shokunin show 06ef644:SKILL.md | wc -l` → 110; `handoff-status` at L53, `op.env` run-row at L26) — the revision current when the audit ran, not the round-5 commit.
- **Safety:** read-only audit. Paths, modes, line refs only — no secret values, no `op://` ref paths, no session tokens; `the-janitor request` not re-run.

## Claim 1 — `handoff-status.json` cited bare

At `06ef644:53-54` ("Model cap: `steps: 4` … observed precedent in `handoff-status.json` `janitor_provenance`") and `06ef644:64` (handoff checklist, `handoff-status.json` `boundaries`), the file is cited with no path. Real file: `~/.local/state/tac/handoff-status.json` — `ls -l` → `-rw------- 1 vgpnk vgpnk 2208 Sep  6 07:10` (read 2026-09-28).

## Claim 2 — `op.env` prerequisite with no fail-closed stop

At `06ef644:26`, the `One-shot command with vault env` row states `needs ~/.config/the-janitor/op.env present` — a declared prerequisite with no stop path (kotoba checklist item 6 = F for kagi).

## Current-state verification — both still open

- **`handoff-status.json` bare: still open.** At **HEAD `5f55ba8`** (round-6, 2026-09-28 16:42:23 -0300) the bare forms remain (L55, L119); the round-7 working tree (`git -C kagi-shokunin status --porcelain` → ` M SKILL.md`) carries them at L103 and L167. The absolute path exists only in the corpus — `corpus/README.md:22`, `corpus/knowledge/tac-evidence-integrity.md:4`, `corpus/knowledge/credential-isolation.md:64`, `corpus/drift-pins.sh:19` — never in `SKILL.md`.
- **`op.env` stop path: still open (documentation-level).** The row is unchanged: `06ef644:26` → `5f55ba8:28` → working tree L28. Runtime mechanism (read-only, `~/.local/bin/the-janitor`): `L7 ENV_FILE="${THE_JANITOR_ENV:-$HOME/.config/the-janitor/op.env}"`; `cmd_run` `L239-242` refuses with `the-janitor: missing $ENV_FILE` (exit 2) when the file is absent. The tool already fails closed — `SKILL.md` just never says so, so a reader cannot tell whether a missing `op.env` is a stop or a retry.
- **Queue:** tracked as an open routed-defects row in the aggregator ledger (`AGGREGATE.md`, canonical relocation from `.ufo/reports/round-2/AGGREGATE.md` pending integrator) until kagi's next steered round lands the `SKILL.md` correction.

## Falsifiable next check

```
grep -n 'handoff-status\|op\.env' kagi-shokunin/SKILL.md
# after the fix: an absolute path on every handoff-status mention + a stop clause on the op.env row
ls -l ~/.local/state/tac/handoff-status.json ~/.config/the-janitor/op.env
# owning lane only (spawns op, out of scope for this read-only mirror):
# THE_JANITOR_ENV=/nonexistent/path the-janitor run -- true; echo exit=$?   # expect "missing" + exit 2
```
