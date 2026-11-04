# ConnOverlap — round-34 sibling ownership scan

## Verdicts

- **AccessKey ground:** no sibling claims Alibaba Cloud RAM AccessKey credential custody in the requested surfaces; keep C3 scoped to credential lifecycle, not Alibaba-wide product ownership.
- **Self-description instrument class:** kama already documents lane-local self-description reconciliation and registry/tree auditing; C1 is kagi-local coverage extension, not acquisition of a fleet-unique instrument class.

## Evidence and counting method

Read the frozen `plans/round-34.md` first. Scanned all 20 other immediate `*-shokunin` directories. Counts below are **matching lines**, case-sensitive, for the exact requested alternatives, not occurrences, files, or ownership counts. Credential search covers PROVINCE.md, SKILL.md, corpus/SOURCES.md and corpus/knowledge recursively; instrument search covers PROVINCE.md and SKILL.md; key-management search covers corpus/knowledge/*.md. Structured tool results, file-level counts, missing paths and excerpts are in `ConnOverlap-receipts.txt` alongside this report. Positive excerpt displays can truncate long lines; counts come from search metadata, not displayed-line counting. These are live sibling-tree observations, not claims about their frozen revisions.

In the table, C/I/K are credential/instrument/key-management matching-line counts. Status concerns the requested ground, not any appearance of a vendor name. A nonzero lexical count alone is not a custody or instrument ownership claim.

| Sibling lane | C | I | K | AccessKey status | Instrument status | Key-management status / disposition |
|---|---:|---:|---:|---|---|---|
| audio-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim; SKILL.md absent |
| chousa-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| game-dev-2d-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim; SKILL.md absent |
| game-dev-3d-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| kaidoku-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| kake-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| kama-shokunin | 4 | 5 | 0 | no-claim | **claims** | no-claim; instrument evidence below |
| kasegi-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| kengaku-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| kotoba-shokunin | 3 | 0 | 0 | no-claim | no-claim | no-claim; model-fact routing, not custody |
| kotodama-shokunin | 0 | 1 | 0 | no-claim | no-claim | no-claim; handoff claim typing, not this sweep |
| kumitate-shokunin | 7 | 0 | 0 | no-claim | no-claim | no-claim; managed agents / routing, not custody |
| lore-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| mado-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| mori-shokunin | 1 | 0 | 0 | no-claim | no-claim | no-claim; NAS quotas, not custody |
| revenger-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| souji-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| tabi-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |
| tameshi-shokunin | 0 | 3 | 0 | no-claim | no-claim | no-claim; quotations about surveyed kagi gates |
| tsukuroi-shokunin | 0 | 0 | 0 | no-claim | no-claim | no-claim |

No contested custody claim was found. All 20 key-management scans returned zero for `11770|17901|Key Management`; this bounded lexical result is not proof that no other spelling or adjacent cryptography topic exists.

### Owning sentences and lexical false positives

All paths below are absolute; quotations are at most 20 words each.

**Instrument claim (kama):**

- `/home/vgpnk/Projects/shokunin/kama-shokunin/SKILL.md:1448`: “Round-42 C1 self-description reconcile (SCORECARD head plus README and PROVINCE)”. Its documented command is `python3 tools/round42-selfdesc-reconcile.py`; the row describes comparison against the selected commit, including unresolved receipts and unlisted top-level entries.
- `/home/vgpnk/Projects/shokunin/kama-shokunin/SKILL.md:1449`: “Round-43 C1 instrument registry vs tree”. This is the adjacent SD7-class surface, documenting `tools/round43-registry-audit.py` and `tools/gate-registry-check.py`.
- `/home/vgpnk/Projects/shokunin/kama-shokunin/SKILL.md:317`: “lane-local; reads SCORECARD.md and the frozen plan only”. The self-description canon v2 row limits its own scope; it does not claim kagi's corpus or identical SD7–SD9 predicates.

**Credential-search hits that do not claim custody:**

- `/home/vgpnk/Projects/shokunin/kama-shokunin/corpus/knowledge/serving-alias-contract.md:33`: “Chinese vendor contract (Alibaba Cloud PAI-EAS, zh).” The adjacent sentence concerns the served model identifier, not RAM keys. The other hits are the ACK equivalent and their source rows.
- `/home/vgpnk/Projects/shokunin/kotoba-shokunin/corpus/knowledge/sibling-description-rewrites-round8.md:376`: “Aliyun/Bailian model facts”. This is an anti-trigger routing model facts elsewhere, not a credential-custody claim.
- `/home/vgpnk/Projects/shokunin/kumitate-shokunin/corpus/SOURCES.md:148`: “the vendor's own coordinator-formation contract for its managed-agent runtime”. Bailian managed-agent topology is not AccessKey lifecycle.
- `/home/vgpnk/Projects/shokunin/kumitate-shokunin/corpus/knowledge/route-probe-cluster.md:143`: “with OMP as the only credential authority”. The surrounding claim concerns whether a model route serves, not custody of Alibaba RAM credentials.
- `/home/vgpnk/Projects/shokunin/mori-shokunin/corpus/SOURCES.md:261`: “Alibaba NAS directory quotas only”. Vendor overlap does not transfer quota ownership into kagi.

**Instrument-search hits that do not establish the same sweep class:**

- `/home/vgpnk/Projects/shokunin/kotodama-shokunin/SKILL.md:79`: “Every handoff claim-ledger row carries”. This specifies uncertainty typing on handoff claims, not a doc-vs-implementation sweep over its own lane gates.
- `/home/vgpnk/Projects/shokunin/tameshi-shokunin/SKILL.md:183`: “claim-ledger pin was once surveyed from a dirty intermediate state”. The three hits concern surveyed kagi gate behavior and errata, not a sibling-owned SD7–SD9 sweep.

## One bounded proposed move

**Describe the two forms of novelty separately in the round-34 record:** C3 adds kagi's previously absent RAM AccessKey custody coverage; C1 extends kagi's local implementation of an already-shared self-description hygiene class. Cite kama's registry/reconcile precedent as adjacent method, without importing its implementation, predicates, receipts, or ownership.

Affected axes: **calibration improves** by eliminating a fleet-uniqueness implication; **coverage is preserved** because the credential-lifecycle addition remains distinct from model serving, managed agents and NAS quotas. **Operability and freshness are unchanged**: this move adds no executable dependency or source-opening substitution. These effects are proposed, not measured axis awards.

Second-order effects:

- Runtime: no sibling executable is run or made a kagi dependency; no vault or network contact.
- Contract: C1's exact SD7/SD8/SD9 population, counters, 5→0 target and SD6 exclusion stay frozen; C2's 12-case and named M7 obligations stay frozen; C3 still requires its own five reopened sources and census.
- Substrate: documentation of an instrument is not an executed receipt. This scan establishes local documented precedent, not that kama currently passes its own tools on this host.
- Verification: the L1 still measures the frozen commands after installation; this overlap scan is neither a substitute for those receipts nor a reason to widen their populations.

Contradictions held explicitly: a statement that self-description auditing is new fleet ground would conflict with kama's existing rows; it does **not** contradict kagi's frozen claim of three newly covered local checks. Alibaba name overlap exists, while a sibling AccessKey custody claim was not found. Those observations must not be collapsed into one ownership score.

Risks: claiming broad Alibaba/cloud-IAM ownership would absorb unrelated serving and agent-runtime ground; claiming universal absence from exact-token zeroes would overstate this scan; copying kama semantics could silently change the frozen predicates. Keep all three boundaries explicit.

Verification performed: only the requested local searches and evidence reads; no gates, lint, build, full suites, sibling runtime, vault access, network or tool installs. L1 verification: use the frozen round-34 counters, independently of this recommendation. Scratch was confined to the named seat directory with explicit TMPDIR and EXIT cleanup; only these two delivered files were retained. No lane-tracked files were edited.
