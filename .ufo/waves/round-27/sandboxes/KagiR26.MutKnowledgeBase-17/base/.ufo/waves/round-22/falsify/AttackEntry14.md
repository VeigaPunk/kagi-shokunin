# AttackEntry14 — integrated C2 attack on `corpus/knowledge/janitor-lifecycle.md`

Axes: **calibration** (does the integrated tree claim more freshness than it measured?) and
**freshness** (pointer integrity vs unavailable source facts). Read-only seat. No host gate,
no live-lane mutation, no installs (none needed; pacman paused — no transaction attempted).

Exact read revision: production tree hashes re-measured 2026-10-20 during the falsify wave
against freeze `.ufo/waves/round-22/integration-manifest.json`; landing
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`; historical base
`c2cab35bc92e57e39e5489bac3386db078345b3f`. `build/Entry14.md` was read but is advisory
(pre-integration snapshot, `HEAD = origin/master = base`); every hash below was re-measured
fresh, none inherited.

## 1. Frozen inputs named (integration-manifest.json)

| input | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/knowledge/janitor-lifecycle.md` | `13c53ed256e6604e5df739c505d7cbd0d7dee865caa3c653502d47bd49dd3fb8` | 81 | 5598 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | 7213 |

`falsify-start.json` confirms landing `8ada17a5` and the write freeze; production inputs were
not modified by me.

## 2. Unchanged prefix — proven for the whole file

- Worktree: `sha256sum` ⇒ `13c53ed2…f3b8`, `wc -l -c` ⇒ `81 5598`. **Byte-identical to the
  frozen manifest input. Zero edits, so the "unchanged prefix" is the entire file.**
- Landing `git show 8ada17a5:…janitor-lifecycle.md | sha256sum` ⇒ `13c53ed2…f3b8`. Git blob
  OID identical at base and landing: `850a544552207f08d3c35cfabf4a66392ebf28c0`.
- `git log --format='%H %ad' -- <path>`: last commits touching the file are all dated
  2026-09-28 (`2486643`, `e64e81b`, `51c9d30`, `244b8c1`); no round-20/21/22 commit touches it.
- Therefore no appended correction exists in this entry — and none was required by the round-22
  correction scope (E1 Broker / E3 OpenBao overclaims; this entry makes no vendor feature-status
  claim). Nothing to launder; history intact.

## 3. Stamp record — fresh at every observed snapshot

Row `corpus/knowledge/janitor-lifecycle.md  13c53ed2…f3b8  81  5598`, exactly 1 row in the
integrated `stamps.tsv` (no duplicate), identical at five independently read snapshots:

| snapshot | evidence |
|---|---|
| base `c2cab35` | `git show <base>:corpus/stamps.tsv` |
| frozen before (`.ufo/.../frozen/before/corpus/stamps.tsv:22`) | digest chain equal to base per build evidence; row re-read directly |
| migration end `e1544c194` | `git show <rev>:corpus/stamps.tsv` |
| landing `8ada17a5` | `git show <rev>:corpus/stamps.tsv`; whole file sha256 ⇒ `88bbe15b…` = manifest |
| production worktree (`corpus/stamps.tsv:25`) | whole file sha256 ⇒ `88bbe15b…` = manifest (freeze respected) |

Not in `before.json`'s six-stale set (`config-layering`, `handler-on-disk-state`,
`handler-trust-boundary`, `janitor-env-contract`, `lessons/round-18`, `LOG`); row matches
current bytes ⇒ not stale in the integrated tree either.

**"Nine dropped stamps" — zero membership loss, this entry uninvolved.** Measured
`git diff aea7a4301 e1544c194 -- corpus/stamps.tsv`: 9 removed rows, each re-added for the same
path (LOG, PROVINCE, SCORECARD, SHONEN, SKILL, README.md, claim-ledger.tsv,
op-ref-consumption.md, op-ref-probe.sh — matches the lessons' nine-path table), plus 7
added-only rows. `janitor-lifecycle` appears in neither the `+` nor `-` set. The single
`-U0` grep hit is the git hunk-header heading (`@@ -22,0 +23 @@ corpus/knowledge/janitor-lifecycle.md…`),
not a changed row. No silent deletion; replacements are documented migrations, not laundering.

## 4. Pointer freshness vs unavailable source facts

- **Pointer freshness: HOLDS.** Hash/newline/byte pin exact at all five snapshots.
- **Source facts: UNAVAILABLE, and the tree does not overclaim.** Fresh stat (this wave):
  `~/.local/bin/the-janitor`, `~/.config/the-janitor/client.py`,
  `~/.config/opencode/tools/janitor_auth.ts`, `~/.local/state/the-janitor` — all ABSENT,
  corroborating `substrate-deferral.md`. Substantive currentness is unmeasurable; I did not
  measure drift and do not claim the reverse.
- The integrated `claim-ledger.tsv` carries `R11-01` (`surface-census.sh`) and `R11-04`
  (`drift-pins.sh`), both tagged `[substrate]` ⇒ they DEFER, never pass, under the recorded
  absence. The entry's `Reverify: R11-01, R11-04` declaration is honest.
- Repo-side corroboration survives absence (fresh reads): `drift-symbols.tsv` pins
  `OP_SERVICE_ACCOUNT_TOKEN` at `the-janitor` L194 (entry cites `_serve` L194) and
  `exec op run --env-file` at L248 (entry cites `cmd_run` L237–249); `client.py` L74 inside the
  cited L41–95; `drift-baseline.tsv` pins `the-janitor` 333 lines and `client.py` 117 lines, so
  every cited line number exists in the committed expectations. These are dated expectations,
  not live checks.

## 5. Finding F-14-1 (medium): inbound numeric pointer survives the integration only generically acknowledged

`corpus/knowledge/control-plane-hardening.md:90–91` cites
"`corpus/knowledge/janitor-lifecycle.md` L18–21" for a sentence whose second clause (stop does
not remove the transcript DB/log) is answered by the table row at **L24** of my entry; L18–21
is header/separator/`client.lock`/`session-id` (verified by direct line read). The integration
appended a "Historical-source erratum (round 22)" to `control-plane-hardening.md`
(182/10575 `dad0b983…` → 200/11558 `a259b7d2…`, = manifest; stamp row migrated in the same
integrated `stamps.tsv` — append-only, no in-place rewrite, no laundering). That erratum fixes
the credential-isolation pointer by heading and acknowledges "the stop/non-purge attribution
also spans more lines than the old helper range alone" — but it does **not** itemize the
janitor-lifecycle `L18–21` migration, and the stale numeric pointer itself is left in place.
A reader following line 91 misses the non-purge row. This is a QM14-style itemization gap in
the pointing document, not a defect in my entry's bytes.

Proposed correction (owner lane, later): when the substrate returns, extend the citation to
`L18–24` (or cite `L24`) and record the old/new range in the next round's migration evidence;
alternatively append an itemized pointer correction to the next lessons file. Do **not** edit
`janitor-lifecycle.md` bytes for this — that would force a cosmetic re-stamp with zero
measurable fact change.

## 6. Finding F-14-2 (low): F1 ambiguity remains unrecorded

Entry line 21 still contains the ambiguous clause "`ensure_started` also removes it when a
foreign server squats the port is ruled out and tmux session is absent (L92–97)" (two
behaviour-divergent readings). `grep -n 'janitor' corpus/lessons/round-22.md` ⇒ zero matches,
so the build seat's recommendation to record this in the round-22 mistakes ledger was not
adopted. Bounded: readability only, no stamp or freshness effect, and no rewrite is verifiable
while the substrate is absent — leaving it unedited is defensible; leaving it **unrecorded**
is the gap. LOG.md's janitor-lifecycle mentions (lines 60, 113) are historic round-5/round-9
records and correctly remain historic.

## Verdict

**ADMISSIBLE.** The integrated C2 treatment of this entry is clean: bytes unchanged from base
through landing to the frozen falsification input and worktree; stamp row fresh, byte-exact,
single-row membership, zero deletion across the "nine dropped" span; no re-pin followed any
content change (none existed); the fresh hash is nowhere promoted to a source-currentness
claim; deferred facts stay deferred via `[substrate]`-tagged ledger rows. Residual risk:
F-14-1 (under-inclusive inbound pointer, generically acknowledged, not itemized) and F-14-2
(unrecorded ambiguity). Neither is an unexplained mismatch, a deletion, or laundering.

Limits: no host gate or fixture execution needed or run; no `revision-audit.py` rerun (parent's
global duty — this report is the single-entry analysis); `stamps.tsv` has no self-row, its
integrity rests on git history plus the frozen manifest digest; `build/Entry14.md` claims about
jj refs and the unreachable `61add15` snapshot were not independently re-derived.

Checks for the parent after integration: (1) `sha256sum corpus/knowledge/janitor-lifecycle.md
corpus/stamps.tsv` ⇒ `13c53ed2…`, `88bbe15b…`; (2)
`awk -F'\t' '$1=="corpus/knowledge/janitor-lifecycle.md"' corpus/stamps.tsv | wc -l` ⇒ 1;
(3) recompute the stale set from blobs, not the dirty worktree ⇒ the six `before.json` paths,
this entry absent; (4) if any later edit touches the entry or `control-plane-hardening.md`,
require the same-commit stamp migration record.

Installs/updates: none.
