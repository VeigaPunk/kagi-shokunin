# AttackEntry08 — falsify integrated C2 for `corpus/knowledge/credential-isolation.md`

Seat: `KagiR22.AttackEntry08` (leaf reviewer, no dispatch). Wave: round-22 falsify, axes
**calibration** and **freshness**. All work read-only; no host gate, no launcher/package tool, no
loopback probe, no install (none needed). Production files untouched; this report is the only file I
wrote.

Read revisions: frozen-before context at `c2cab35bc92e57e39e5489bac3386db078345b3f`; measured
integration landing at `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (current tree HEAD == master tip
== landing, detached-HEAD identity not used to infer anything); history anchors `2486643` (round 14,
last content edit), `51c9d30` (round 7), `e1544c1` (post-landing round-21 correction).

## Verdict

| Question | Measured answer |
|---|---|
| Did the entry's bytes change between frozen-before and integrated tree? | **No — zero-byte diff, full-file identity.** |
| Unchanged prefix? | **Trivially the whole file: 3986/3986 bytes.** |
| Stamp record consistent, no restamp, no laundering? | **Yes.** Same row in frozen-before, in all 9 revisions, at tip; no migration row needed and none exists. |
| Does the integrated tree mark every false reading of this entry? | **Yes, the one actionable defect (inbound pointer drift) is marked in the neighbor**, with prefix-preserving append, same-commit restamp, recorded migration. |
| Unavailable source facts distinguished from pointer freshness? | **Yes** — all six host sources absent today; nothing was promoted to "current". |
| Admissibility verdict | **ADMITS** (see §7). |

## 1. Byte identity: frozen-before = current = every historical revision

- Integration manifest `corpus/knowledge/credential-isolation.md` entry: `bytes 3986, lines 78,
  sha256 03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3`.
- Current tree measurement: `sha256sum` = `03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3`,
  `wc -c` = 3986, `wc -l` = 78. Exact match; the file is also line-identical (same 78 lines).
- Frozen-before snapshots: `.ufo/waves/round-22/frozen/before/corpus/stamps.tsv` pins the identical
  row (line 16) and `.ufo/waves/round-22/frozen/before/expected.json` carries the same six-entry
  stale list as the base measurement — the frozen-before input and the base revision agree.
- History: `git show <rev>:corpus/knowledge/credential-isolation.md | sha256sum` = same digest at
  `c2cab35` (frozen base), at `2486643` (last content edit), and HEAD. `git diff --stat
  c2cab35..HEAD` over this path is **empty**. The file was never touched by the integration span.
- Last content edit remains `2486643` (`--numstat` 2 added / 0 deleted: the `Reverify: R11-01,
  R11-04` declaration + blank line at L7). Blob identity holds back to that commit.

**Prefix proof:** with zero bytes changed anywhere, the unchanged prefix is the entire file; every
sentence, the header (`Source: … All read 2026-09-28`, L3–5) and all 7 headings are the frozen
bytes. No appended correction exists in this entry, so there is nothing to launder.

## 2. Stamp record

Frozen-before row (`frozen/before/corpus/stamps.tsv:16`):

```
corpus/knowledge/credential-isolation.md	03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3	78	3986
```

Current row (`corpus/stamps.tsv`, one exact match; file now 69 rows vs 63 at base): identical digest,
78 lines, 3986 bytes. The identical row greps 1/1 in every revision `2486643, 587fda0, 8a6ec16,
bc1af88, fecee87, c41af82, e1544c1, c2cab35…, HEAD` — no restamp, no drift window since creation
(pin and content share commit `2486643`).

- `.ufo/waves/round-22/round21-migrations.json` has **no** `credential-isolation` record (correct:
  nothing to migrate); its `removed_members` is `[]`.
- `.ufo/waves/round-22/pin-migrations-integration.json` has **no** `credential-isolation` record and
  exactly one `control-plane-hardening` record (see §5).
- Integration ran `claim-ledger.sh stamp` with the path in its explicit list
  (`integration-pin-check.json`, `STAMPED: n=69`), re-emitting the identical tuple — a no-op restamp
  (hash unchanged) that could not and did not mask any content change, given the byte identity in §1.
- The entry is in neither the historical "nine" replaced lines nor the post-landing thirteen; it is
  not among `before.json.stale_stamps` (6 entries: the four round-16-qualified files, `round-18.md`,
  `LOG.md`).

**Freshness scope, stated honestly:** the stamp proves pointer integrity (no corpus-text drift since
round 14). It does not prove any host claim. That distinction is exactly what the integrated tree's
own artifacts assert, and it is where the entry's limits live (§4).

## 3. Build/Entry08.md cross-check

`.ufo/waves/round-22/build/Entry08.md` exists (340 lines) and adjudicated this entry at the frozen
base: stale-byte mismatch **No**; substantive freshness **not measurable (sources absent)**;
member of six-stale set **No**; member of the nine **No**; appended correction to the entry
**not required**; only an external inbound-pointer repair required (its §4b), with an optional
entry-local erratum shape defined but not recommended (its §7) and an append-only contract
(§9: 3986-byte prefix preservation, 7-heading census, single `Reverify:` line, same-commit stamp
coupling).

My independent attacks agree with every checkable claim in it, including two it uniquely verified:
(a) round-16's measured defect class was current-voice hash assertions in exactly four entries; this
entry contains no `sha256` fragment, so appending "historical" prose purely for symmetry would be a
calibration judgment, not a correction — correctly not done; (b) the round-14 heading-loss incident
for this file is recorded in `corpus/lessons/round-14.md:123-127`, and the current file still carries
all 7 headings.

Residual (advisory, not a defect): Entry08 §4b pre-computed `NEW 74130fc1b8ec…` for the pointer fix
against a clean file, while `pin-migrations-integration.json` records the landed new stamp
`a259b7d266d9…` (200/11558). The delta is explained by the landed append carrying the round-22
erratum prose (the pre-computed value assumed the mechanical edit alone). The landed artifact is
self-consistent (§5); only the build report's in-memory prediction differs, and build artifacts are
advisory per the wave contract.

## 4. Unavailable source facts vs pointer freshness (measured today, 2026-10-20)

`test -e` result 1 (absent) for **all six** surfaces the entry cites or depends on:
`~/.local/bin/the-janitor`, `~/.config/the-janitor/opencode.json`,
`~/.config/the-janitor/client.py`, `~/.config/opencode/agents/janitor.md`,
`~/.config/opencode/tools/janitor_auth.ts`, `~/.local/state/tac/handoff-status.json`.

Consequences, none laundered:

1. The entry's `Reverify: R11-01, R11-04` links to real ledger rows (both `[substrate]`-tagged,
   `claim-ledger.tsv:15,18`); absent substrate ⇒ DEFER, never PASS. Nothing in the tree claims these
   re-verified.
2. `R18-01` remains the recorded all-GONE drift verdict (`files_ok=0 files_bad=15`); a byte pin and
   the stamp row never resurrect any of these facts as current. `drift-baseline.tsv` (single commit
   `e64e81b`, same day as the entry's read date) makes the entry conditionally re-verifiable: if the
   substrate returns with the pinned hashes, every static claim is against exactly the bytes it was
   written against — pointer freshness only, and the integrated lesson says precisely this.
3. No sentence in the entry is asserted current anywhere in the integrated round-22 surfaces
   (SCORECARD/LOG/SOURCES/QUALITY greps: the only hit is the round-7 LOG work record — historical
   prose, untouched).

## 5. The one actionable defect is marked, not erased (no laundering)

`corpus/knowledge/control-plane-hardening.md:31` cites `credential-isolation.md L37–51` for the
"Agent permissions are deny-all + one tool" block. Independently reproduced:

- At `51c9d30` (round 7, when the pointer was written): L37 = `## Agent permissions are deny-all +
  one tool`, L51 = `JANITOR_ACTION_REQUIRED; no spawning agents, no unrelated work.` — the exact
  intended 15-line section.
- The round-14 diff for this path is +3/−1 (net +2); the same texts now sit at **L39–53** (measured
  at current revision), so the stale numeric span no longer resolves to its target.

Integrated handling, all verified:

- `control-plane-hardening.md` grew 182/10575 → 200/11558 (`dad0b983…` → `a259b7d266d9…`), and
  `cmp <(git show c2cab35:…control-plane-hardening.md) <(head -c 10575 current)` exits 0 — the
  original 182 lines/10575 bytes are a preserved prefix; the round-22 erratum is a pure append at
  L184 `## Historical-source erratum (round 22)`, which names its own historical status, instructs
  readers to use the **Agent permissions** heading instead of the stale numeric span, and cites
  `build/Entry07.md` + `build/Entry08.md` as audits. History is kept; the false reading is marked.
- Same-commit restamp: `pin-migrations-integration.json` records the exact old/new tuple for
  `corpus/knowledge/control-plane-hardening.md` with disposition "historical source facts remain
  historical". No other row was migrated for this path; no `--prune`; membership 63→69 with the only
  adds being new members (`R12-03` expectation text confirms this composition).

## 6. Count/path/hash evidence summary

| Artifact | Value |
|---|---|
| Entry sha256 (current = frozen = manifest = stamp = every revision) | `03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3` |
| Entry bytes/lines | 3986 / 78 (both measured; stamp columns agree) |
| Zero-byte diff span | `c2cab35..HEAD` over the path: empty |
| Stamp row occurrences across history | 9/9 revisions byte-identical |
| round21-migrations / pin-migrations records for this path | 0 / 0 (none required) |
| Neighbor old/new | `dad0b983369f558bfd130f68d598561ba0a07974cff1c50cae583b7d7e2feaa7` 182/10575 → `a259b7d266d9e8930b8b7ff5466d25e6fe4261ccd92e50f6dbe707007b116907` 200/11558; 10575-byte prefix `cmp` clean |
| Host sources present | 0 of 6 |
| Falsify wave writes by this seat | this report only |

## 7. Admissibility verdict

**ADMITS.** The integrated C2 treatment of `credential-isolation.md` is correct and complete: the
entry is byte-identical to the frozen base and to its round-14 form; the stamp row is exact and
unmigrated because there is nothing to migrate; the single real defect associated with the entry
(the `+2` inbound pointer drift) is repaired in the owning neighbor via a prefix-preserving appended
erratum with a recorded old→new stamp migration; unavailable source facts remain explicitly
unavailable (DEFER rows, all-GONE drift verdict) and were never promoted to current by hashes or
restamps. The build wave's "no correction required in this entry" decision holds under fresh attack.

Residual risk / verification gaps (parent duties, not defects in this entry):

- The revision-audit rerun is a parent-owned global check; per my seat contract I did not execute it.
  Parent checks worth running: `python3 corpus/revision-audit.py --history c2cab35…` (expect
  `stale=0 missing=0 dropped=0 added=6`), `bash corpus/claim-ledger.sh docs` (expect
  `entries=25 … unpinned=0`), and `bash corpus/claim-ledger.sh citations --docs
  corpus/knowledge/control-plane-hardening.md`.
- `claim-ledger.md` §Bounds Class 6 still names this entry's "20 vars" and "759 bytes" counts as
  unasserted-by-any-row; they are conditionally reproducible from the hash-pinned `the-janitor`
  bytes and must not be called "unverifiable" — no integrated surface does so (verified by grep).
- If the janitor substrate ever returns with hashes differing from `drift-baseline.tsv`, this entry
  must be re-adjudicated by a fresh human read, never silently restamped — the integrated lesson
  already encodes this stop condition; nothing in the current tree contradicts it.
- Four W1 scribe seats remain uncredited per the wave contract; this seat neither replaces nor
  credits them. No depth claim and no legacy-header count claim made.
