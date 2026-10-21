# AttackEntry11 — falsify-wave attack of integrated C2 for `corpus/knowledge/handler-trust-boundary.md`

Read revision (named, not inferred): working tree = HEAD = integration landing
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (`git rev-parse HEAD`, observed
2026-10-20). Historical BEFORE reference is
`c2cab35bc92e57e39e5489bac3386db078345b3f` (base), read via `git show`, not
treated as the falsification input. All observed tree/file hashes recorded
below; lane edits are frozen for this wave, so hashes are stable under the
wave's own freeze rule. No live host gate, no source byte read, no launcher,
package tool, or loopback probe used. `git status --porcelain` at wave start
shows only `.ufo` wave bookkeeping (`falsify-spec.json` M;
`falsify-dispatch.json`, `falsify-start.json`, `falsify/`, `safe-row-plan.json`
untracked) — the audited paths `corpus/knowledge/handler-trust-boundary.md` and
`corpus/stamps.tsv` are clean (`git status --porcelain -- <both paths>` = empty,
exit 0). All evidence files read below are git-tracked
(`git ls-files` confirms `build/Entry11.md`, `pin-migrations-integration.json`,
`historical-correction-pins.json`), so their contents are not in-flight edits
read from a dirty tree.

Axes: **C2 freshness** (entry bytes, stamp pointer, migration evidence) and
**C1 calibration** (admissibility of claims about this entry; E1/E3 transfer
check). C1/C2 kept causally separate: the stamp-pointer repair adjudicates no
source, and the source/status decision does not depend on restamping.

## 1. Frozen-input hashes (named from the manifest, not inferred)

`kagi-shokunin/.ufo/waves/round-22/integration-manifest.json` (top-level keys:
`base_revision`, `expected`, `inputs`, `purpose`; `base_revision` =
`c2cab35…`; purpose states "New reports under .ufo may be written; code/docs/
data listed here stay frozen") records:

| input | manifest sha256 | bytes | lines |
|---|---|---|---|
| `corpus/knowledge/handler-trust-boundary.md` | `fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba` | 19410 | 316 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 7213 | 69 |

Independent re-measure of the frozen tree bytes: entry file
`sha256sum` = `fa17fff3…561eba`, `wc -l` = 316, `wc -c` = 19410 — exact match.
`corpus/stamps.tsv` working-tree `sha256sum` = `88bbe15b…14a29` — exact match.
`git log c2cab35..8ada17a -- corpus/stamps.tsv` = exactly one commit
(`8ada17a` "round-22: feature-bound review capability and audited revision
repairs"), and `git show 8ada17a:corpus/stamps.tsv | sha256sum` =
`88bbe15b…14a29` — the only stamps.tsv mutation in the landing window is the
audited re-pin commit itself, and the manifest pinned its output.

## 2. Entry bytes: unchanged-prefix proof

- Historical BEFORE blob (`git show c2cab35…:corpus/knowledge/
  handler-trust-boundary.md`): sha256 `fa17fff3…561eba`, 316 lines / 19410
  bytes — **identical** to current bytes.
- Byte-for-byte: `git show c2cab35…:path | cmp - corpus/knowledge/
  handler-trust-boundary.md` → **CMP-IDENTICAL, exit 0** (whole file, not just
  a bounded prefix — stronger than a `cmp -n` prefix proof).
- `git log c2cab35…..8ada17a… -- corpus/knowledge/handler-trust-boundary.md` →
  **empty**: no commit in the landing window touched the entry.
- Working tree is clean for this path (`git status --porcelain --` both audited
  paths = empty), so current bytes = committed bytes = frozen bytes.

**Finding (entry bytes): unchanged, proven by full-file byte identity against
the manifest-pinned frozen input.** The only structural change in this entry's
C2 story is the stamp pointer, not the bytes.

## 3. Stamp record: stale→fresh reconciliation with exact provenance

Current row (working tree = HEAD, `corpus/stamps.tsv:22`):

```
corpus/knowledge/handler-trust-boundary.md	fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba	316	19410
```

Base-committed row (`git show c2cab35…:corpus/stamps.tsv`, line 19):

```
corpus/knowledge/handler-trust-boundary.md	263c7b0e734c299ae795ac8a5168f1dae562c875959820257c1c6294072dd5e5	285	17669
```

Independent confirmation of the stale pointer's target: `git show
2486643:corpus/knowledge/handler-trust-boundary.md` hashes exactly
`263c7b0e…72dd5e5`, 285 lines / 17669 bytes — the old row's three measured
columns are each correct for the round-14 blob. Row movement:
`git log … -- corpus/stamps.tsv` between base and landing = the single commit
`8ada17a`; numstat for the ledger in that window = `38 32`. The row is keyed to
the same path, one row per path (`grep -c` = 1), no row deleted
(`pin-migrations-integration.json` `removed_members: []`), non-comment row
count 63 → 69 (+6: feature-claims.json/py, feature-bound-credential-review.md,
round-21-verifier-spotcheck, round-22 lesson, revision-audit.py — the same six
`ADDED` lines in `integration-pin-check.json` `audit_stdout`), matching the
manifest's `expected.revision_audit = {added 6, dropped 0, invalid 0, missing
0, stale 0}` and the manifest `expected.legacy_entries` = 21 with
`source_rows` = 21.

**Finding (stamp): the stale row was re-pinned in place to the current bytes'
true measurement.** `wc -l` = 316 (not display 317) matches the ledger's
documented measure (`corpus/knowledge/claim-ledger.md:39-43`; last byte `0x2e`,
no trailing newline), matching `verify_stamps`' byte/line/sha comparison
semantics (`claim-ledger.sh` `stamp_cmp`, reads `wc -l`, sha256, byte count).

## 4. Independent reproduction of the append-attribution chain

I did not trust build/Entry11.md; I re-derived its chain from git:

- Round-14 commit `2486643` (2026-09-28, "round-14: freshness axis-move —
  knowledge-entry re-verification declarations, docs audit mode, scorecard
  row-pointer repair"): blob was exactly `263c7b0e…/285/17669` — the row was
  **accurate when authored**.
- The append: `git log 2486643..c2cab35 -- <entry>` = exactly one commit,
  `f4a8dd9` (2026-10-15, "round-16: qualify historical janitor source claims");
  `git merge-base --is-ancestor f4a8dd9 c2cab35` → ancestor (so the append
  predates the frozen base — the base row was stale on day one of round 22's
  frozen window).
- `git diff --numstat 2486643 f4a8dd9 -- <entry>` = `32 1` (32 additions,
  1 deletion) — matches Entry11's reported numstat exactly.
- Prefix preservation: `cmp -n 17669 <(git show 2486643:path) <(git show
  f4a8dd9:path)` → **PREFIX-PRESERVED, exit 0** (independently rerun).
- `git show --name-only --format= f4a8dd9 | grep -c '^corpus/stamps.tsv$'` = 0
  — round-16 appended the erratum but did not touch stamps.tsv: the stale row
  was a **missing re-pin**, not an unclaimed or hidden edit.
- The append's own preservation claim is consistent: LOG.md:790-799 records
  `SOURCE_PRESERVATION: preserved=4/4` against `15ea78c`, and `git show
  15ea78c:<entry> | sha256sum` = `263c7b0e…` — same pre-append blob, so the
  logged preservation used identical bytes.
- `corpus/lessons/round-22.md` ("Nine deleted diff lines" section) attributes
  the nine-value `e1544c1` replacement to same-path re-pins; this entry's path
  is **not** among them, and `historical-correction-pins.json` (span
  `c41af82d`→`e1544c194…`) contains **zero** rows for `handler-trust` — no
  laundering of this entry's pointer through the nine-line migration either.
- Landing evidence for the re-pin itself: `pin-migrations-integration.json`
  `stamp_changes` (38 entries; numstat 38/32) contains exactly one
  `handler-trust-boundary` record:

```json
{ "path": "corpus/knowledge/handler-trust-boundary.md",
  "old_stamp": "...263c7b0e...	285	17669",
  "base_observed": {"sha256": "fa17fff3…", "lines": 316, "bytes": 19410},
  "new_stamp": "...fa17fff3...	316	19410",
  "disposition": "Reviewed current round-22 artifact; historical source facts
  remain historical. See round-22 lesson and named per-entry audit." }
```

`old_stamp` matches the base-committed row verbatim; `base_observed` matches my
independent measurement; `new_stamp` matches the live row at stamps.tsv:22
verbatim.

**Finding (freshness accounting): no silent deletion, no laundering.** The row
moved from a stale pin (which was provably accurate for round-14 bytes and
provably not refreshed by round-16's logged append) to a pin whose sha/lines/
bytes equal the frozen-manifest-pinned current bytes, with the old/new pair and
a disposition recorded in committed evidence.

## 5. Pointer freshness vs unavailable source facts

The entry's current bytes are a **factual 2026-09-28 measurement narrative**
(abbreviated hashes `2408b0c9…`, `8179b241…`, opencode 1.18.31, auth matrix,
routes A/B/C) plus a **round-16 erratum** (`## Historical-source erratum —
round-16 re-dispatch (2026-10-15)`, `Source-status: historical —`) that
qualifies lines 3-11, the verification marker at 9-10, the by-hand declaration
at 17, and all source-dependent conclusions through line 286, preserving the
old observations as historical evidence and requiring operator-authorized
restoration plus separate authorization before re-verification.

Metadata-only existence check of the six cited source paths (2026-10-20, this
seat): `~/.local/bin/the-janitor`, `~/.config/the-janitor/client.py`,
`~/.config/opencode/agents/janitor.md`,
`~/.config/opencode/tools/janitor_auth.ts`,
`~/.config/opencode/plugin/fnm-nudge.js`, `~/.opencode/bin/opencode` — **all
ABSENT**. Consequence (also asserted by the erratum and Entry11 §4): none of
the abbreviated hashes, the auth matrix, routes A/B/C, or the version can be
re-verified from sources today. The re-pinned stamp records the *artifact
revision*, not current posture: **pointer freshness ≠ source currentness**.
The erratum's own dated absence record ("the opencode binary path was present,
but no version or source bytes were inspected" on 2026-10-15) vs today's
absence is a dated observation delta, not a contradiction of the erratum's
text; the erratum correctly claims no current posture, so nothing in it is
falsified by the binary's later disappearance.

**No appended correction is needed and none was laundered in:** the entry's
falsifiable historical statements are already fully bounded by the erratum;
appending a dated "sources now also absent" note would be new unadjudicated
metadata that forces another re-pin for zero calibration gain. The absence
fact is recorded here and in Entry11 §4 instead.

## 6. C1 calibration check (E1/E3 transfer, bounded control)

The manifest's `expected` block (`feature_before_rejections: 10`,
`feature_after_admits: 4`, `boundary_unjudgeable: 3`, `entries_sourced: 4`)
and `corpus/lessons/round-22.md` show C1 was measured as decisions, not authored
rows, with the E1/E3 corrections landing in
`onepassword-machine-credentials.md` / `vault-openbao-token-lease-lifecycle.md`
(via the new `corpus/knowledge/feature-bound-credential-review.md`, hash
`0d186f58…` in the manifest) — **not** in this entry. This entry carries no
Broker eligibility, feature status, or product-attribution claim; nothing from
E1 (1Password Broker status/eligibility) or E3 (OpenBao token/lease) transfers
to it. The one admissible C2 control for this entry was the single-row re-pin
with provenance — exactly what landed. Adjudication of claims:

| Claim about this entry | Decision |
|---|---|
| "Stale row = unreviewed/hidden edit" | reject — delta is exactly logged `f4a8dd9`, prefix-preserving |
| "Stamp docs mode proves currentness" | reject — `verify_stamps` compares all four columns; `docs` checks membership only |
| "Entry current / socket posture established" | reject — historical only, all cited sources absent today |
| E1/E3 findings attach here | reject — wrong file; no feature decision is made or transferred |
| One-row re-pin with old/new provenance, no entry edit | **admit** — repairs the only demonstrable defect, asserts no vendor fact |

## 7. Residual risks and verification gaps

- The re-pin's freshness is time-boxed to the frozen tree; if any post-landing
  lane work touches the entry, the stamp goes stale again by design. The
  global single `revision-audit` rerun is parent duty (not run here); expected
  clean result for this path given stamps.tsv = frozen bytes.
- The five remaining stale rows at the base (config-layering,
  handler-on-disk-state, janitor-env-contract, round-18 lesson, LOG.md —
  `frozen/before/expected.json` `expected_stale_original` lists six including
  this one) and the nine-value migration journal are other seats' scope; not
  audited here beyond the non-membership cross-checks above.
- No source byte was read (all sources absent), so no currentness claim is
  possible or made — by design, not by omission.
- `historical-correction-pins.json` is committed but not manifest-listed;
  consulted read-only as context.

## Verdict

**ADMISSIBLE.** For `corpus/knowledge/handler-trust-boundary.md`: entry bytes
byte-identical between frozen base, landing commit, and working tree
(`fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba`, 19410 B /
316 wc-l); the stale stamp row was re-pinned exactly once, in place, with
old/new provenance recorded in committed evidence and zero member deletion; the
stale-byte cause is fully attributed to the logged round-16 append (`f4a8dd9`,
numstat 32/1, prefix-preserved) rather than an unclaimed edit; pointer
freshness is correctly separated from unavailable source facts (all six cited
sources absent, verified metadata-only); no appended correction was needed and
none was fabricated; no E1/E3 transfer; C1/C2 causally separate.

---

Report: .ufo/waves/round-22/falsify/AttackEntry11.md
