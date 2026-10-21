# KnowSopsAgeKeyRotation — round-27 C1 inventory

**Seat:** `KagiR26.KnowSopsAgeKeyRotation-17`
**Frozen BASE:** `0a47dd189356ea66ec83c3891eed54526e95b89b` (`git rev-parse HEAD`)
**Target:** `corpus/knowledge/sops-age-key-rotation.md` — 112 lines; BASE blob sha256
`a6b14ff7555fb972368d23e1e57bfb62170daa65ee4f2bd34521ff6819d407a7`, identical to the
working-tree file (`git status --porcelain --` empty for this path). All line numbers below
are that blob.
**Milestone:** round-27 build — C1 knowledge-entry number binding, C2 regression refusal.
**Writes:** this report only. No production file, ledger, stamp, or sandbox code was written.

**Source state:** every line cited from `corpus/knowledge/sops-age-key-rotation.md`,
`corpus/SOURCES.md:15-17`, `corpus/source-fetches.tsv:62-64`, `corpus/release-clocks.tsv:6-8` and
`corpus/self-counts.py` is byte-identical at BASE (`git show 0a47dd1:<path>`) and in the build tree
(`diff` over those ranges). `corpus/self-counts.tsv` and `corpus/claim-ledger.tsv` are modified
elsewhere in the build tree, so their round-27 content is marked WT and BASE was read with
`git show` (BASE has 0 `^KN-` rows). The round-27 planning artifacts are **working-tree only**
(`?? plans/round-27.md`, `?? corpus/lessons/round-27.md`, ` M corpus/QUALITY.md`); citations to
QM26 / M27-2 / the plan are WT and not BASE-committed.

| Godspeed axis | This slice |
|---|---|
| Calibration completeness | every digit token and every spelled number word in the entry classified, with line numbers |
| Freshness | clock state of the entry's three `on-release` rows read from pins, not re-fired |
| Honest exclusion | QM21/QM26 classes named per excluded number; zero invented bindings |
| Minimal action | no `KN-*` row minted where no `rows:`/`ledger:`/`expect:` source kind exists |
| Reproducibility | proposed locators simulated with the binder's own per-line `search` semantics |

## Verdict

1. **Zero bindable current-tense digit numbers** about this lane's artifacts. This entry
   contributes **no `KN-*` row** to `corpus/self-counts.tsv`, and **no digit in it is stale**.
2. **One current-tense count is stale and unbindable:** `corpus/knowledge/sops-age-key-rotation.md:70`
   states `→ no file, exit 1 (2026-10-19)` for the corpus sweep at lines 68-70. At BASE the same
   command returns **one file and exit 0**. The count is spelled (`no file`), so the binder cannot
   capture it (`corpus/self-counts.py:121` requires a `[0-9]+` capture), and no `rows:`/`ledger:`/
   `expect:` source defines a knowledge-directory sweep. QM26's unbindable branch applies: correct
   the prose with a round-tagged history clause; do not mint a fake binding.
3. **Three spelled counts are current and correct** (`three` pages, `three` objects, `three`
   steps); all three are structurally unbindable — a `[0-9]+` capture is mandatory.

Consequence for C1: on the after binding table this entry moves no counter. The wave's "five
STALE knowledge numbers" (`corpus/lessons/round-27.md` M27-2) are digit
numbers; this entry's defect is a spelled count and therefore sits in the same places round 25
left it (`corpus/lessons/round-25.md:158-163`, item at `:161`:
`knowledge/sops-age-key-rotation.md:68-70` — "grep now exits 0"), not in the five.

## Method

- Read all 112 lines of the BASE blob; enumerated every line matching `[0-9]` mechanically
  (34 lines) and every spelled number word (`one|two|three|…|both`).
- Read the binder's constraints instead of running it: locator = exactly one capture group,
  exactly one matching doc line (`corpus/self-counts.py:8-9`, `:116`, `:327-333`); captured value
  must match `[0-9]+` (`:121`); source must be `rows:<path>` with `-`, or `ledger:<ID>`/`expect:<ID>`
  with an extract (`:142-148`).
- Re-ran only the entry's own lane-local sweep (a corpus grep, not a gate) and `git grep` against
  historical trees. No gate, selftest, ledger verify, build, lint or formatter was executed.

## Table 1 — current-tense numbers (population), one stale candidate

| id | line | exact text (BASE) | defining live source | pinned live value (BASE) | status | locator (simulated) |
|---|---|---|---|---|---|---|
| K-SOPS-GREP-SWEEP | 70 | `→ no file, exit 1 (2026-10-19). This entry is a comparison` | **none** among `rows:` / `ledger:` / `expect:` — no TSV defines a `corpus/knowledge` sweep; apart from the observation date, the only digit is a shell exit status | `1` matching entry (`corpus/knowledge/feature-bound-credential-review.md`), exit `0`; 23 of 25 entries scanned (2 excluded), command at lines 68-69 | **STALE** | `^→ no file, exit ([0-9]+) \(2026-10-19\)` → exactly 1 match (line 70), `group(1)="1"` |

The locator is unique and one-group, but it captures the **exit code**, not the reported size
(`no file` = 0 matching files). Registering it would bind a false quantity — the line cannot be
bound without rewording, and even reworded (`1`) no binder source kind exists. This is the concrete
reason the entry needs a prose correction rather than a row.

Zero rows are otherwise available: nothing on this entry states a selftest case count, row/stamp/
claim/pin count, bound, line count of a lane-owned file, or finding count in digit form.

## Table 2 — current spelled counts (verified, non-digit)

| id | line | exact text (BASE) | asserted | measured at BASE | status | locator (1 group, 1 line) |
|---|---|---|---|---|---|---|
| K-SOPS-THREE-PAGES | 4 | `verified-at: 2026-10-19 (the three rendered getsops.io pages above, read in full; …` | 3 pages | `source:` line 3 carries exactly `S009`, `S010`, `S011` (3 unique ids) | OK | `\(the (three) rendered getsops\.io pages` |
| K-SOPS-THREE-OBJECTS | 12 | `## Three different objects` | 3 objects | table data rows at 16, 17, 18 (header 14, separator 15) | OK | `^## (Three) different objects$` |
| K-SOPS-THREE-STEPS | 94 | `… or the compromise section reorders or drops its three steps.` | 3 steps | numbered list at 54, 56, 57 | OK | `drops its (three) steps\.$` |

All three are outside the binder by type, not by staleness: `corpus/self-counts.py:121` rejects a
non-`[0-9]+` capture. Simulated per line with `re.search`: each locator matches exactly 1 line
(4, 12, 94). I did not propose converting them to digits; QM26 asks for labelled history,
not cosmetic digitization, and none is stale.

Non-numeric self-description, checked because a lane-local file defines it: line 7 says every
`source:` id "resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry".
At BASE `corpus/SOURCES.md:15-17` holds S009/S010/S011, each status `mined`, each `used-by` =
`corpus/knowledge/sops-age-key-rotation.md`. True; not a number.

## Table 3 — excluded numbers and why (full digit census)

| class | lines (BASE) | tokens | why excluded |
|---|---|---|---|
| Vendor page metadata | 3, 5 | `2026-05-15` ×3, `9b7b84e` ×4 | vendor "Last modified" date and docs commit id; not lane artifacts |
| Provenance dates | 4, 9 (and the date inside 70) | `2026-10-19` | verification/scope dates, not sizes; the one inside line 70 belongs to the stale row above |
| Source ids | 3, 5, 16, 17, 18, 20, 27, 28, 36, 37, 43, 46, 52, 60, 62, 84, 98, 105 | `S009`, `S010`, `S011` | identifiers, not counts |
| Row / quality ids | 6, 7, 22 | `R21-02`, `QA8` | identifiers; `R21-02` is the citation-chain row, not a count |
| Algorithm names | 37, 38 | `ssh-rsa`, `ssh-ed25519` | vendor key-type names |
| Positional ordinals / case indexes | 54, 56, 57, 60, 82, 83 | `1.`, `2.`, `3.`, `steps 1–2`, `step 3`, `step 2` | positional indexes (QM26 exclusion class), not sizes |
| History / attribution tags | 96, 101, 111, 112 | `round 21`, `round 22`, `round-22` review paths | Round-N history and review attribution |
| Spelled vendor counts | 36, 44, 60, 61 | `one able`, `one fragment`, `two cases`, `two calls` | vendor mechanism/quote, not this lane's artifacts |
| Anaphora / section names | 74, 76, 77 | `§Two verbs`, `the two`, `one … the other's` | reference names/pronouns, not counts |

No other digit-bearing token exists in the 112 lines. The census covers every line returned by
`[0-9]` (34 lines) and every spelled count word.

## The stale claim, with counterexample

BASE text (`corpus/knowledge/sops-age-key-rotation.md:68-70`):

```68:70:corpus/knowledge/sops-age-key-rotation.md
kagi does not run SOPS today: `grep -rliE 'sops|openbao|hashicorp' corpus/knowledge
--exclude=sops-age-key-rotation.md --exclude=vault-openbao-token-lease-lifecycle.md`
→ no file, exit 1 (2026-10-19). This entry is a comparison
```

Executed at BASE on this checkout:

```
$ grep -rliE 'sops|openbao|hashicorp' corpus/knowledge \
    --exclude=sops-age-key-rotation.md --exclude=vault-openbao-token-lease-lifecycle.md
corpus/knowledge/feature-bound-credential-review.md
$ echo $?
0
```

`corpus/knowledge` holds 25 `.md` entries; two are excluded, 23 scanned, one matches via
`openbao` (`corpus/knowledge/feature-bound-credential-review.md:1,3,9,19,20,33`), not via `sops`.

The counterexample is sharpened by ancestry (read-only `git grep`, no checkout, no index change):

- `git grep -liE 'sops|openbao|hashicorp' 8ada17a^ -- corpus/knowledge` → only the two excluded files.
- `git grep -liE … 8ada17a -- corpus/knowledge` → adds `feature-bound-credential-review.md`.
- `8ada17a` ("round-22: feature-bound review capability and audited revision repairs",
  2026-10-20) **added that entry and appended this entry's round-22 Clarification in the same
  commit** (`git show --stat 8ada17a -- corpus/knowledge/sops-age-key-rotation.md` = 13 insertions).
  The sweep's parenthetical date `2026-10-19` was falsified by its own commit one day later, and
  has stayed false at `4be5da3` and at BASE.

Adjacent non-numeric falsification, same cause — **outside my C1 number scope but the fix is
incomplete without it**: `corpus/knowledge/sops-age-key-rotation.md:99` (round-21 erratum) says
"the sweep supports only that no *other corpus knowledge entry* mentions SOPS, OpenBao or
HashiCorp". One other entry now does (OpenBao). The erratum's narrowed reading of the headline
sentence ("no kagi corpus entry documents SOPS use") is **not** contradicted as to SOPS — no other
entry contains the token `sops` (`grep -ril sops corpus/knowledge` → this entry and the excluded
Vault/OpenBao entry only). So the correct calibration is: *the family sweep returns one entry on
OpenBao; no entry documents SOPS use* — not "the OpenBao mention proves SOPS use".

### Proposed correction (draft for L1; QM21 + QM26, not applied)

Replace the sweep sentence at BASE lines 68-70 (line 71 continues `reference, not adoption. An
encrypted-file workflow…` and is kept) with a current result plus a round-tagged history clause:

```
kagi does not run SOPS today: a round-21 sweep of `corpus/knowledge` (`grep -rliE
'sops|openbao|hashicorp' … --exclude=sops-age-key-rotation.md
--exclude=vault-openbao-token-lease-lifecycle.md`) returned no file, exit 1; the same
sweep at round 27 returns one file — `feature-bound-credential-review.md`, which names
OpenBao as a token backend and does not document SOPS use. This entry is a comparison
reference, not adoption.
```

and align line 99's universal ("no other entry mentions … OpenBao") with the same fact.
No `corpus/self-counts.tsv` row accompanies this: the new value is still spelled/unbindable, and
minting a digit only to bind it would assert a quantity no source kind can measure.

## Freshness (C2 interface)

- The entry's `recheck: on-release` (`:5`) is bound to `corpus/release-clocks.tsv:6-8`
  (S009/S010/S011, feed `S033` = `https://github.com/getsops/sops/releases.atom`): anchored
  `3.13.3` (derived), observed `3.13.3`, observed_at `2026-10-21`, verdict `not-fired`. **No
  recheck is due**, and no history clause is required now.
- Page identity is unchanged since the entry's `verified-at` 2026-10-19: the in-row fetch sha256
  in `corpus/SOURCES.md:15-17` equals the 2026-10-21 capture sha256 in
  `corpus/source-fetches.tsv:62-64` (`a840727e…`, `fed6b2e1…`, `d0ab8b20…`). [INFERENCE] the
  bodies are byte-identical to the ones read for the entry, since the in-row pin is the entry's
  own capture record.
- C2 relevance: these three rows use a **derived numeric anchor equal to the observation**. If a
  cropped or rolled-back feed were observed at `3.13.2` (< `3.13.3`), BASE's `observed != anchor`
  rule would read S009-S011 `fired` and spuriously re-open this entry on a non-release. Under
  QM25/C2 that observation must be a typed `REGRESSED` finding (exit1), never fired and never
  CLEAN. This entry is a consumer of the C2 rule, not a source of one; I did not execute
  `corpus/release-clock.py` or the wave's C2 fixtures.

## What I did NOT check (unrun is not a pass)

- No gate/selftest/ledger run: `corpus/self-counts.py`, `corpus/sources-census.sh`,
  `corpus/release-clock.py`, `corpus/claim-ledger.sh verify/citations`, or the wave's
  `c1-measure`/`c2-measure` scripts. Only the entry's own grep and read-only `git grep` were run.
- No network re-fetch of the getsops.io pages, no SOPS execution, no audit of the quoted vendor
  content (threshold default, compromise ordering) beyond the committed registry quotes.
- No host/substrate measurement, no vault/op/account/handler/CDP contact, no `~/.config` reads.
- Did not audit numbers in other knowledge entries; the five-digit stale set and `KN-*` integration
  are L1's.
- `.ufo/waves/round-27/c1-before.json` is absent at write time, so I could not read the wave's own
  BASE binding table; my population statement is derived from the binder's code, the table's HEAD
  state, and this entry alone.
- Locators in Tables 1-2 were simulated with Python `re.search` per line, not by the gate.

## Tooling record

No tool installed, upgraded, or reconfigured (no `uv`, `npx`, `cargo`, or pacman transaction).
Read-only Git queries (`rev-parse`, `cat-file`, `show`, `grep`) and `grep`/`wc` only.

## Confidence and open items

- **High**: the digit/spelled census (mechanical over all 112 lines), zero bindable current-tense
  lane numbers, and the stale sweep (command run twice plus historical `git grep`).
- **Medium**: whether L1 wants the line-70/line-99 prose fix inside this round versus keeping it as
  round-25 debt. C1 asks for stale current-tense numbers to be corrected with a history clause, and
  this is one, but it cannot be bound; the correction is the only QM26-compliant disposition I see.
- **Unknown**: whether the integration's five "STALE knowledge numbers" count this entry (it has no
  digit to be STALE); if L1 expects a `KN-*` row here, the honest answer is that none exists.
