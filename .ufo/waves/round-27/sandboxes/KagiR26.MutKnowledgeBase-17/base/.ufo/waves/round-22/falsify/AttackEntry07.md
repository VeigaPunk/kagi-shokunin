# Falsify C2 — AttackEntry07 — `corpus/knowledge/control-plane-hardening.md`

Wave: round-22 falsification. Axes: **freshness** (C2 revision accounting) and **calibration**
(does the appended correction mark every false reading without laundering). Leaf member; no
subagents dispatched; no production file touched; no live gate, host loopback, launcher, or
package tool invoked. Read revision: integration-manifest-frozen inputs, master tip
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, worktree clean for every file cited below.

## Verdict

**The entry changed exactly once since the frozen base, as an 18-line append-only erratum at EOF,
and the append is admissible: PASS with one residual risk (R1, an inherited pointer-freshness
defect the append marks but cannot resolve).** Prefix preserved byte-exact; the new stamp row is
correct; no member was dropped; the erratum marks every false reading that was actually claimed,
with one bounded under-claim of its own scope.

## 1. Identity of the change (measured)

| quantity | base `c2cab35` | current (master `8ada17a` = worktree) |
|---|---|---|
| blob sha256 | `dad0b983369f558bfd130f68d598561ba0a07974cff1c50cae583b7d7e2feaa7` | `a259b7d266d9e8930b8b7ff5466d25e6fe4261ccd92e50f6dbe707007b116907` |
| lines / bytes | 182 / 10575 | 200 / 11558 |
| stamp row | `dad0b983… 182 10575` (row 15, `corpus/stamps.tsv`) | `a259b7d2… 200 11558` (row 17, `corpus/stamps.tsv`) |

- Current blob **equals** `integration-manifest.json` `inputs["corpus/knowledge/control-plane-hardening.md"].sha256`
  — the frozen-input hash and the landed tree agree; nothing drifted between freeze and landing.
- Single commit touches the entry in `c2cab35..master`: `8ada17a` (round-22 integration). One
  commit touches `corpus/stamps.tsv`: the same commit. Worktree `git diff master -- <entry>` is
  empty (`WORKTREE_MATCHES_MASTER` measured).
- **Unchanged prefix proven**: `cmp <(git show c2cab35:<path>) <(head -c 10575 <path>)` exits 0.
  The entire change is a 983-byte suffix (sha256 of the suffix alone:
  `8b2c61b511476d19febf7ff815632b1b600f4a70e212ff26f4d25f2acdec4168`). Zero lines edited or
  deleted from the historic record; no heading lost (the file's heading set is the 182-line
  prefix's plus one new `##` heading).
- The appended block is **byte-for-byte the D4/§4.1 shape proposed by `.ufo/waves/round-22/build/Entry07.md`**:
  `## Historical-source erratum (round 22)`, `Source-status: historical — …`, substrate-absence
  bound, `R11-01`-overclaim bound, credential-isolation re-anchor note, reopen-before-rollout
  bound, audit pointers, and — critically — **no line beginning `Reverify`** (measured: no `^Reverify`
  match in the appended 983 bytes), so it does not trip `claim-ledger.sh`'s single-declaration
  parser hazard. The append's "no server or account action was performed in this round" statement
  is consistent with the wave boundary (and consistent with build/Entry07 §2b, which itself
  recorded a host `opencode --version` probe before the tightened boundary).

## 2. Pointer freshness vs unavailable source facts — distinguished correctly

The erratum keeps the two classes separate, which is the axis requirement:

- **Pointer freshness (provable in-tree):** (a) its own line 11's `Reverify:` pointer overclaim —
  R11-01 pins only shape floors (`state-shape.tsv`: `magic`, `mode 600`, `size_min 1`,
  `tables_min 12`, `tables_required`, `rows_min session:2/message:13/part:18/event:79`) and
  re-derives **neither** the `9,240,576`-byte size **nor** the `7/39/55` row counts; the erratum
  says exactly that, including the `[substrate]` DEFER-not-pass bound. (b) the inbound
  `credential-isolation.md` span drift.
- **Unavailable source facts (not provable):** the janitor handler, `client.py`, and state
  surfaces are absent on this host. The erratum states this and says a byte pin does not check
  retention counts and re-verification requires restored authorized source. It makes **no
  currentness claim from the new stamp** — the stamp row's disposition reads "historical source
  facts remain historical", matching the C2 rule that restamping is pointer integrity only.

## 3. Correction completeness — every claimed false reading marked

Checked against build/Entry07.md findings and the entry's own defect surface:

| false reading | marked by the append? |
|---|---|
| Entry carries no historical-source qualifier while citing absent host sources (round-16 four-entry rule) | yes — `Source-status: historical` section appended |
| `Reverify: … re-measured by R11-01` pointer overclaim (size/rows not re-measured) | yes — bound stated explicitly |
| `credential-isolation.md L37–51` pointer now stale | yes — re-anchor to `Agent permissions` heading |
| Stop/non-purge attribution spanning more than old helper range | yes — marked as over-span |
| Byte stamp implies currentness | prevented — no reverified verb, no new hash, disposition says historical |
| Substantively stale but stamp-fresh confusion | yes — declared, not "passed" |

The `L37–51 → Agent permissions` re-anchor claim is **independently reproduced**: at the revision
the pointer was authored (`51c9d30`), `credential-isolation.md` L37–51 was the `Agent permissions`
section; the `Reverify: R11-01, R11-04` block inserted at L7 in `2486643` shifts it to L39–53
(verified by `git grep -n 'Reverify:'` at both revisions and heading positions at `2486643`:
L39). The erratum's re-anchor is the drift-proof fix Entry08 recommended. No sibling prose was
rewritten; `credential-isolation.md` itself is untouched (manifest hash match — not re-measured
here, named from manifest; its row 18 is byte-identical in both TSV revisions I diffed).

## 4. C2 revision accounting for this row (measured, exact)

- **Stale at base? No.** `before.json` (`revision: c2cab35…`) lists exactly six stale stamps —
  config-layering, handler-on-disk-state, handler-trust-boundary, janitor-env-contract,
  round-18.md, LOG.md. This entry is **not** among them; its base row was exact (blob = row
  triple at `2486643` and at base).
- **Dropped? No.** `pin-migrations-integration.json`: `old_members 63 → new_members 69`,
  `removed_members: []`; one `stamp_changes` entry for this path carrying old row
  `dad0b983… 182 10575` → new row `a259b7d2… 200 11558`. Base-to-master TSV diff: 38 added, 38
  removed lines, **zero paths lost** (6 new members: two Python tools, feature-claims JSON+entry,
  round-22 lesson, round-21 spotcheck). `corpus/stamps.tsv` = 69 rows, sha256
  `88bbe15b…` = manifest hash; `claim-ledger.tsv` = 58 rows, `87fed349…` = manifest hash.
  R12-03's migrated expectation `^69$` matches the actual file.
- **Migration evidence:** old and new tuples are committed in `pin-migrations-integration.json`
  (blob `1103bbd8…`, committed in the same tree, `git ls-tree master` verified) with the
  disposition text; QM14 shape satisfied for this row.
- **Round-21 verdict unchanged.** The round-21 REJECTED-HONEST-STOP result is historical and is
  not re-verified by any new hash in this append. The round-22 lesson also documents the four
  W1 scribe deaths and the launcher/loopback boundary breaches — none re-run here.

## 5. Falsification attempts (all failed to find a laundering path)

1. Rewrite-instead-of-append: disproven — prefix `cmp` identical, 983-byte pure suffix.
2. Restamp without migration record: disproven — `pin-migrations-integration.json` holds the
   old/new tuple for this exact path, committed.
3. Row count / header-count proxy laundering: R12-03 now counts 69 rows but its note explicitly
   says "count is not source freshness"; the round-22 lesson's QM13/M22-2 wording agrees. No
   header-count freshness claim exists in the append or lesson.
4. Overclaim via the append ("no current X claimed" violated): the append asserts nothing about
   the janitor substrate, DB size, row counts, or version; the only forward-looking sentence is
   "reopen authorized source before any operational rollout".
5. Silent sibling mutation: `credential-isolation.md` untouched (base→master commits list empty;
   stamp row 18 byte-identical in both TSVs).
6. Pre-landing vs post-landing substitution: `historical-migrations.json` (R21-03 40→47) is
   kept separate from `round21-migrations.json` full-span record, as the round contract requires;
   this entry's row appears only in the integration-span record.

## Residual risk and verification gaps

- **R1 (low, inherited, pre-dates round 22):** the entry's `Reverify: by-hand:
  control-plane-scratch` declaration remains structurally valid on an absent substrate — honest
  DEFER, never dischargeable until the substrate returns. The append marks the limitation but
  the counted declaration itself stays. This is the documented deferral contract, not a defect
  introduced this round.
- **R2 (informational):** the erratum's "The stop/non-purge attribution also spans more lines
  than the old helper range alone" is directionally supported by Entry14's independent finding
  (lifecycle pointer `janitor-lifecycle.md L18–21` never covered the DB/log clause even at
  authoring revision; substrate needed to adjudicate the helper range) but is **not**
  independently re-derived here from a substrate source. It is a historical-scope bound, not a
  new fact claim; the erratum does not assert a corrected numeric span, which is the honest
  choice given absent sources.
- **R3 (informational):** `credential-isolation.md`'s manifest-hash match is taken from
  `integration-manifest.json` rather than re-measured; the two TSV revisions independently
  agree its row is byte-identical (78/3986), and base→master commits touching it: none.

## Admissibility verdict

**ADMISSIBLE (PASS).** Unchanged-prefix proof holds; the appended erratum is exactly the
pre-specified D4 remedy; every false reading named by the build seat's audit is marked without
rewriting historic bytes; the stamp re-pin is same-commit with a committed old→new migration
record; membership 63→69 with zero removals; the "nine dropped stamps" are restamps, not
deletions, and this row was never one of them. No laundering path found.

Report: `.ufo/waves/round-22/falsify/AttackEntry07.md`
