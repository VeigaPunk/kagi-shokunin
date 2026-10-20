# AttackEntry22 — falsify C2 for `corpus/knowledge/tac-evidence-integrity.md`

Seat: `KagiR22.AttackEntry22` (leaf, no subagent dispatch). Axes: **calibration, freshness**.
Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (historical BEFORE, not the falsification
input). Falsification input: integration manifest
`.ufo/waves/round-22/integration-manifest.json` + landed integration
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (2026-10-20 19:13:44 -0300,
"round-22: feature-bound review capability and audited revision repairs").
All measurements fresh 2026-10-20; no host gate, no install, no production write.

## Verdict (one line)

**ADMIT** — the landed change is a pure 12-line EOF erratum that marks every identified
false reading (including the exact ones build/Entry22.md named), withdraws the dangling
citation instead of re-asserting it, migrates the stamp with exact old/new tuples in
dedicated evidence, and leaves the `Reverify:` declaration and ledger semantics untouched.

## 1. Byte identity: frozen vs current — unchanged prefix proven

| probe | value |
|---|---|
| manifest input tuple | `d53339af7683bb5036621ee620c75a68e476f0b960515f65f817cb6179023191` / 92 ln / 4437 B |
| current working tree (`sha256sum`, `wc -lc`) | `d53339af…23191` / 92 / 4437 — **exact match, file frozen-clean** |
| base `c2cab35` bytes (`git show …:…` ) | `c77312306f2e6708d47aeaa4a483a27e3dbb9597b6b281f6cab4a71103f89665` / 80 / 3757 |
| arithmetic | 80+12=92 lines, 3757+680=4437 bytes — **pure append, zero edited bytes** |
| strict `git diff c2cab35 8ada17a -- <path>` | single hunk `@@ -78,3 +78,15 @@` — additions only |
| frozen/before snapshot | `frozen/before/corpus/stamps.tsv:30` carries old tuple `c7731230…/80/3757`; the pre-append file itself is not in `frozen/before/corpus/knowledge/` (only `onepassword-machine-credentials.md`, `vault-openbao-token-lease-lifecycle.md` are) — base bytes therefore taken from `git show c2cab35…`, cross-confirmed by that stamp row |

**Unchanged-prefix claim: PROVEN.** Lines 1–80 are byte-identical to the base revision;
the diff is 12 appended lines (680 bytes) at EOF.

## 2. Stamp reconciliation (freshness core)

| item | evidence |
|---|---|
| stamp row, landed | `corpus/stamps.tsv:33` = `d53339af…23191` / 92 / 4437 |
| stamp row, frozen/before | `frozen/before/corpus/stamps.tsv:30` = `c7731230…f89665` / 80 / 3757 |
| migration record | `pin-migrations-integration.json:326–338`: `old_stamp` = exact old tuple, `base_observed` = `{sha256: c7731230…, lines: 80, bytes: 3757}` (independently re-derived from git — matches), `new_stamp` = exact new tuple, `disposition` = "Reviewed current round-22 artifact; historical source facts remain historical…" |
| historic evidence quality | old tuple re-derivable from `git show c2cab35…` and from `frozen/before/corpus/stamps.tsv:30`; **not laundered** — no silent overwrite |
| stamp-set integrity | `stamps.tsv` 63 → 69 rows; diff shows every base path re-appearing (re-pins), **zero path deletions**; the 6 added rows are the six new files (`feature-claims.json/.py`, `feature-bound-credential-review.md`, `round-21-verifier-spotcheck.md`, `round-22.md`, `revision-audit.py`) — matches manifest `revision_audit: {added: 6, dropped: 0}` |
| this entry vs the "nine dropped" | **not among the nine**; `e1544c1`'s nine were QUALITY/README/SOURCES/claim-ledger.tsv/onepassword/sops-age/vault-openbao/round-21/sources-census.sh (build Entry22 §6 table, confirmed by its diff excerpt). Tac row was constant `c7731230…` across 8 revisions until round 22's own legitimate append |

**No silent deletion, no laundering.** The stamp change is earned by the append and
documented with exact historic evidence.

## 3. Ledger expectation migrations (documented, not silent)

| expectation | base (`c2cab35`) | landed (8ada17a) | driver |
|---|---|---|---|
| `R12-03` (`claim-ledger.tsv:28`) | `^63$` | `^69$` — text names "Historical 56->63 and all old/new tuples remain in round-22 migration evidence" | six new stamp rows; **not** this entry |
| `R14-01` (`claim-ledger.tsv:32`) | `entries=24 row_linked=21 by_hand=3` | `entries=25 row_linked=22 by_hand=3` — text names "24/21/3 at round 21 … Old/new expectation preserved in round-22 journal" | new feature-bound entry; **not** this entry |
| `Reverify: R11-01, R11-04` (entry line 6) | present | present, untouched | erratum adds no second declaration |

`R11-01` (`claim-ledger.tsv:15`) and `R11-04` (`:18`) remain resolvable `[substrate]` rows;
`R14-01`'s counts did not move because of this entry — the build-Entry22 warning against an
unearned 21→20 migration was heeded. Parser safety re-verified: the appended block contains
no line starting `Reverify`/`Source` (only `Source-status:` inside the block body, line 84);
`claim-ledger.sh:871–884` requires exactly one `Reverify: ` declaration — satisfied.

## 4. Pointer freshness vs unavailable source facts — independently re-measured 2026-10-20

| source the entry names | state (my measurement) | classification |
|---|---|---|
| `~/.local/bin/the-janitor` | ABSENT | unavailable source fact (host state) |
| `~/.local/bin/tac-check` (baseline `af95ca97…`/88 ln, `drift-baseline.tsv:10`) | ABSENT | unavailable source fact |
| `~/.local/state/tac/daybreak-blue-access.json` | ABSENT (parent dir absent) | unavailable source fact |
| `~/.local/state/the-janitor/tac-daybreak-blue.json` | ABSENT (parent dir absent) | unavailable source fact |
| `~/.local/state/tac/handoff-status.json` | ABSENT | unavailable source fact |
| `~/.agents/AGENTS.md` | PRESENT, 949 B, sha256 `7b06a503110ca86373c1da0daf3694d5ce57f4ae9a792dd09fcf3c4ae4b1896e`, `grep -ci 'janitor\|tac-register\|daybreak'` = **0** | **stale pointer** — present file no longer carries the quoted sentence |

So: the substrate absence (deferral of `R11-01`/`R11-04`) is an **unavailable-source** fact;
the AGENTS.md citation is a **pointer-freshness** fact. These are distinct failure classes
and the landed erratum keeps them distinct.

## 5. Erratum coverage — does it mark every false reading?

Landed erratum (`tac-evidence-integrity.md:81–92`) clauses vs false readings:

| false reading a reader could take | marked? | clause |
|---|---|---|
| receipt fields/custody paths/checker output are current facts | ✅ | "Source-status: historical — … belong to their original measurement, not current authorization or integrity" |
| absent substrate can be "reverified" by refreshing the byte pin | ✅ | "Missing substrate sources cannot be reverified by refreshing this document's byte pin" |
| deferred `R11-01`/`R11-04` count as passes | ✅ | "deferred rows are not passes" |
| the AGENTS.md janitor quote still resolves | ✅ | "source attribution is withdrawn as a current locator" |
| recheck may capture receipt values | ✅ | "without recording receipt values" |
| historical text was rewritten to match today | ✅ (implicitly) | strict diff proves untouched prefix; old tuple preserved in migration evidence |

Convention compliance: `Source-status: historical —` matches 13 sibling knowledge entries
(e.g. `adjacency-scope.md:317`, `transcript-hygiene.md:153`); `Audit:` line style matches 5
siblings (`Entry05/Entry10/Entry16/Entry17/Entry20`); heading `## Erratum (round 22 — …)`
matches `transcript-hygiene.md:151`. Every current-tense claim in the erratum is true as
measured today (absences, dangling pointer).

**Laundering check: PASS.** No historical line edited; withdrawal is by demotion, not
deletion; the 2026-09-28 reading stays attributed to its original date.

## 6. Build/Entry22.md reconciliation (advisory, per wave contract)

Build Entry22 (440 ln) demanded exactly: (1) no re-pin before append, (2) append-only dated
erratum at EOF, (3) no `Reverify:` edit / no expectation migration, (4) reviewed full-set
re-stamp in a quiet tree with old tuple recorded. The landed tree satisfies all four:
append-only (§1), declaration untouched (§3), re-stamp executed with old tuple in
`pin-migrations-integration.json:326–338` (§2). Wording differs from the build draft
(build proposed a host-metadata-laden recheck block; landed is the compact corpus-convention
form) — build artifacts are advisory, no defect. Build Entry22's "six stale at HEAD" table
(`config-layering`, `handler-on-disk-state`, `handler-trust-boundary`,
`janitor-env-contract`, `round-18`, `LOG.md`) is out of this entry's scope; all six now
carry landed tuples in the stamps diff.

## 7. Residual risk / verification gaps

1. **Subsection granularity (negligible):** the `Handoff rules (from handoff-status.json,
   verified fields)` subsection is demoted by the blanket historical declaration but not
   individually enumerated in the `Source-status` noun list. No admissibility impact.
2. **AGENTS.md history unverified:** the quote's 2026-09-28 existence rests on session
   transcripts; the erratum correctly treats only the *current* absence as measured. Cannot
   be closed from the corpus.
3. **Deferred-not-run state:** `R11-01`/`R11-04` remain deferred on this host (predicate
   `-x ~/.local/bin/the-janitor` false — code path `claim-ledger.sh:138–145, 397–398`;
   predicate operand absence re-measured). Parent's single revision-audit rerun is its duty;
   I did not run any gate.
4. Frozen/before does not contain a copy of this entry's pre-append bytes (only 2 knowledge
   files are snapshotted); base bytes were taken from `git show c2cab35…` and
   cross-confirmed against `frozen/before/corpus/stamps.tsv:30`. Exactness unaffected.

No installs performed (none needed). No production file, lane state, config, or host state
was modified; the only write is this report.
